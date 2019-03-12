*** Settings ***
Documentation    This is Attella 100ge Alarm Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38964: ACX6180-T: Attella 4x100GE base transponder capability
...              Author: Linda Li
...              Date   : 02/22/2019
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/38964
...              jtms description           : Attella
...              RLI                        : 38964
...              MIN SUPPORT VERSION        : 19.2
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : MISC
...              Platform                   : ACX
...              DOMAIN                     : None
...              PLATFORM/PRODUCT SUPPORTED : ACX6160-T
...              MPC/FPC TYPE               : ACX6160-T
...              TESTER                     : N/A
...              TESTER VERSION             :
...              JPG                        : No
...              VIRTUALIZATION SUPPORT     : NO
...              MARKET USE CASES           :
...              CUSTOMER PR                :
...              JTMS DISCRIPTION           :
...              GNATS CATEGORY             :
...              BSD/LINUX                  : LINUX
...              CUSTOMER                   :
...              TOOL NAME                  : None
...              TOOL VERSION               : None
...              THIRDPARTY LICENSE NAME    : None
...              THIRDPARTY LICENSE VERSION : None

Resource    jnpr/toby/Master.robot

Library         BuiltIn
Library         String
Library         Collections
Library         OperatingSystem
Library         String
Library         ExtendedRequestsLibrary
Library         XML    use_lxml=True

Resource        ../lib/restconf_oper.robot
Resource        ../lib/testSet.robot
Resource        ../lib/attella_keyword.robot


Suite Setup   Run Keywords  Toby Suite Setup
...              Test Bed Init

Test Setup  Run Keywords  Toby Test Setup

Test Teardown  Run Keywords  Toby Test Teardown

Suite Teardown  Run Keywords
#...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{auth}    admin    admin
${interval}  120
${timeout}  120
${period}  15

@{EMPTY LIST}

${ALARM CHECK TIMEOUT}  5 min
${OPER_STATUS_ON}  inService
${OPER_STATUS_OFF}  outOfService


*** Test Cases ***     
TC0
    [Documentation]  Service Provision
    ...              RLI38968 5.1-8
    [Tags]  Sanity
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK


TC1
    [Documentation]  Verify Los alarm in Client Interface
    ...              RLI38964  
    [Tags]  Sanity 
    Log To Console  turn Laser off
    Set Laser State  ${testSetHandle1}  OFF
    
    Log To Console  Verify Alarms
    @{expectedAlarms}  Create List  Loss of Signal  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}
    
    
    Log To Console  turn Laser on
    Set Laser State  ${testSetHandle1}  ON
    
    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    
    [Teardown]  Set Laser State  ${testSetHandle1}  ON


TC2
    [Documentation]  Verify Local Fault Rx/Tx alarm in Client Interface
    ...              RLI38964  
    [Tags]  Sanity 
    Log To Console  near-end inject LFAULT
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    @{expectedAlarms1}  Create List  Local Fault Rx  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}  ${ALARM CHECK TIMEOUT}
    
    Log To Console  Verify Alarms
    @{expectedAlarms2}  Create List  Local Fault Tx  Remote Fault Rx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}  ${ALARM CHECK TIMEOUT}
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
    
    Log To Console  near-end stop inject LFAULT
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    
    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF


TC3
    [Documentation]  Verify Remote Fault Rx/Tx alarm in Client Interface
    ...              RLI38964  
    [Tags]
    Log To Console  near-end inject RFAULT
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    @{expectedAlarms1}  Create List  Remote Fault Rx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}  ${ALARM CHECK TIMEOUT}
    
    Log To Console  Verify Alarms
    @{expectedAlarms2}  Create List  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}  ${ALARM CHECK TIMEOUT}
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
    
    Log To Console  near-end stop inject RFAULT
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    
    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF


TC4
    [Documentation]  Verify HI BER ALARM in 100ge Client Interface
    ...              RLI38964  
    [Tags]
    Log To Console  near-end inject HI BER
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK  1.0E-02
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    @{expectedAlarms}  Create List  High Bit Error Ratio Rx  Remote Fault Rx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}
    
    
    Log To Console  near-end stop inject HI BER
    Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK 
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    
    [Teardown]  Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK 


TC5
    [Documentation]  Verify Loss of Alignment in 100ge Client Interface
    ...              RLI38964  
    [Tags]
    Log To Console  near-end inject Loss of Alignment
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK  MAX
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    @{expectedAlarms}  Create List  Loss of Alignment Rx  Remote Fault Rx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}
    
    
    Log To Console  near-end stop inject Loss of Alignment
    Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    
    [Teardown]  Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK


TC6
    [Documentation]  Verify tx LF mask tx RF in 100ge Client Interface
    ...              RLI38964  
    [Tags]  Sanity 
    Log To Console  Step1 Remote Fault Tx raise in client Interface
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    @{expectedAlarms1}  Create List  Local Fault Rx  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}  ${ALARM CHECK TIMEOUT}
    
    Log To Console  Step2 Verify tx LF mask tx RF
    Start Inject Alarm On Test Equipment  ${testSetHandle2}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    @{expectedAlarms2}  Create List  Local Fault Rx  Local Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms2}  ${ALARM CHECK TIMEOUT}
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms2}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    
    Log To Console  Step3  tx RF raise after remove tx LF
    Stop Inject Alarm On Test Equipment  ${testSetHandle2}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}  ${ALARM CHECK TIMEOUT}
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log To Console  Step4 near-end stop inject LFAULT
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    
    [Teardown]  
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Stop Inject Alarm On Test Equipment  ${testSetHandle2}  ALARM_ETHERNET_ETH_LF


TC7
    [Documentation]  Verify Los alarm after warm reload in 100ge client interface
    ...              RLI38964  
    [Tags]  
    Log To Console  turn Laser off
    Set Laser State  ${testSetHandle1}  OFF
    
    Log To Console  Verify LOS Alarms in near-end client
    @{expectedAlarms}  Create List  Loss of Signal  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log To Console  Warm Reload Device
    Rpc Command For Warm Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0
    
    Log To Console  Verify LOS Alarms in near-end client after warm reload
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}
    
    
    Log To Console  turn Laser on
    Set Laser State  ${testSetHandle1}  ON
    
    Log To Console  Verify Alarms Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic OK
    Verify Traffic Is OK
    
    [Teardown]  Set Laser State  ${testSetHandle1}  ON


TC8
    [Documentation]  Verify Local Fault Rx/Tx alarm after cold reload in Client Interface
    ...              RLI38964  
    [Tags]  
    Log To Console  near-end inject LFAULT
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify LF RX Alarms in near-end client
    @{expectedAlarms1}  Create List  Local Fault Rx  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}  ${ALARM CHECK TIMEOUT}
    
    Log To Console  Verify Alarms LF TX Alarms in far-end client
    @{expectedAlarms2}  Create List  Local Fault Tx  Remote Fault Rx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}  ${ALARM CHECK TIMEOUT}
    
    Log To Console  Cold Reload Device
    Rpc Command For Cold Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0


    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Log To Console  Verify LF RX Alarms in near-end client after cold reload
    @{expectedAlarms1}  Create List  Local Fault Rx  Remote Fault Tx    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log To Console  Verify Alarms LF TX Alarms in far-end client after cold reload
    @{expectedAlarms2}  Create List  Local Fault Tx  Remote Fault Rx    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
    
    Log To Console  near-end stop inject LFAULT
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify Alarms Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console  Verify Traffic OK
    Verify Traffic Is OK
    
    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF


*** Keywords ***
Test Bed Init
    Set Log Level  DEBUG
    Log To Console      create a restconf operational session

    @{dut_list}    create list    device0  device1
    Preconfiguration netconf feature    @{dut_list}

    @{auth}=  Create List  ${tv['uv-odl-username']}  ${tv['uv-odl-password']}

    ${opr_session}    Set variable      operational_session
    Create Session          ${opr_session}    http://${tv['uv-odl-server']}/restconf/operational/network-topology:network-topology/topology/topology-netconf    auth=${auth}    debug=1
    Set Suite Variable    ${opr_session}
    
    Log To Console      create a restconf config session
    ${cfg_session}    Set variable      config_session
    Create Session          ${cfg_session}    http://${tv['uv-odl-server']}/restconf/config/network-topology:network-topology/topology/topology-netconf    auth=${auth}    debug=1
    Set Suite Variable    ${cfg_session}
    
    Log To Console      create a restconf rpc session
    ${rpc_session}    Set variable      rpc_session
    Create Session          ${rpc_session}    http://${tv['uv-odl-server']}/restconf/operations/network-topology:network-topology/topology/topology-netconf    auth=${auth}    debug=1
    Set Suite Variable    ${rpc_session}
    
    @{odl_sessions}    create list   ${opr_session}   ${cfg_session}   ${rpc_session}
    Set Suite Variable    ${odl_sessions}
    
    
    ${client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    ${line odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${line otu intf}=  Get OTU Intface Name From ODU Intface  ${line odu intf}
    ${line och intf}=  Get OCH Intface Name From OTU Intface  ${line otu intf}

    Set Suite Variable    ${client intf}
    Set Suite Variable    ${line odu intf}
    Set Suite Variable    ${line otu intf}
    Set Suite Variable    ${line och intf}
    
    ${remote client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    ${remote line odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote line otu intf}=  Get OTU Intface Name From ODU Intface  ${remote line odu intf}
    ${remote line och intf}=  Get OCH Intface Name From OTU Intface  ${remote line otu intf}
    Set Suite Variable    ${remote client intf}
    Set Suite Variable    ${remote line odu intf}
    Set Suite Variable    ${remote line otu intf}
    Set Suite Variable    ${remote line och intf}
    
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Log To Console  de-provision on both device0 and device1
    Delete Request  @{odl_sessions}[1]  /node/${tv['device0__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/
    Delete Request  @{odl_sessions}[1]  /node/${tv['device1__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/
    
    Log To Console  load pre-default provision on device0
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Log To Console  load pre-default provision on device1
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
    
    Log To Console  init test set to 100ge
    Init Test Equipment  ${testSetHandle1}  100ge
    Init Test Equipment  ${testSetHandle2}  100ge


Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
    Delete Request  @{odl_sessions}[1]  /node/${tv['device0__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/
    Delete Request  @{odl_sessions}[1]  /node/${tv['device1__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/


Create 100GE Service
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}
    ${rate}=  Set Variable  100G
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    ${line support port}=  Get Supporting Port  ${och intf}
    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
    ${client support port}=  Get Supporting Port  ${client intf}
    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
    ${client rate}=  Speed To Client Rate  ${rate}
    ${odu rate}=  Speed To ODU Rate  ${rate}
    ${otu rate}=  Speed To OTU Rate  ${rate}
    ${och rate}=  Speed To OCH Rate  ${rate}
    
    &{client_interface}    create_dictionary   interface-name=${client intf}    description=ett-${discription}    interface-type=ethernetCsmacd    
    ...    interface-administrative-state=inService   speed=${client rate}
    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}

    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel    
    ...    interface-administrative-state=inService    supporting-interface=none   och-rate=${och rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}  frequency=${frequency}000
    
    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}    interface-type=otnOtu    
    ...    interface-administrative-state=inService    supporting-interface=${och intf}  otu-rate=${otu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    &{odu_interface}    create_dictionary   interface-name=${odu intf}     description=odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService    supporting-interface=${otu intf}     odu-rate=${odu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    
    @{interface_info}    create list    ${client_interface}    ${och_interface}    ${otu_interface}    ${odu_interface} 
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload}


Verify Traffic Is OK
    Log To Console  Verify Traffic Is OK
    : FOR    ${nLoop}    IN RANGE    1    6
    \    Sleep  20
    \    Log To Console  Check Traffic Status for the ${nLoop} time
    \    Clear Statistic And Alarm  ${testSetHandle1}  
    \    Clear Statistic And Alarm  ${testSetHandle2}

    \    Start Traffic  ${testSetHandle1}
    \    Start Traffic  ${testSetHandle2}

    \    Sleep  10

    \    stop Traffic  ${testSetHandle1}
    \    stop Traffic  ${testSetHandle2}
    \    
    \    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
    \    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
    \    @{EMPTY LIST}=  create list
    \    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}

    \    Exit For Loop If  '${result}' == "PASS"
    \    Run Keyword Unless  '${result}' == "PASS"  Log To Console  Check Traffic Status fails for the ${nLoop} time
    
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails

    Clear Statistic And Alarm  ${testSetHandle1}  
    Clear Statistic And Alarm  ${testSetHandle2}
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  60
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
   
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails


Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${EMPTY LIST}

    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${EMPTY LIST}


Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}

    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${OPER_STATUS_ON}

    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${OPER_STATUS_ON}
