*** Settings ***
Documentation    This is Attella Signaling Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38964: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author: Jack Wu
...              Date   : 12/26/2018
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
...              jtms description           : Attella
...              RLI                        : 38964
...              MIN SUPPORT VERSION        : 19.1
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



Suite Setup   Run Keywords
...              Toby Suite Setup
...              Test Bed Init


Test Setup  Run Keywords
...              Toby Test Setup

Test Teardown  Run Keywords
...              Toby Test Teardown

Suite Teardown  Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{auth}    admin    admin
${interval}  120
${timeout}  120
${period}  20

${OPER_STATUS_ON}  inService
${OPER_STATUS_OFF}  outOfService
*** Test Cases ***     
TC0
    [Documentation]  Service Provision
    ...              RLI38964 5.1-8
    [Tags]  Sanity
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

    Log To Console  Verify Traffic
    Verify Traffic Is OK

    
TC1
    [Documentation]  near-end inject LF to Client Interface
    ...              RLI38964  5.3-1  
    [Tags]
    Log To Console  near-end inject LFAULT
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  check far-end tester raise LFAULT
    ${result1}=  Is Alarm Raised  ${testSetHandle2}  ALARM_ETHERNET_ETH_LF
    
    Log To Console  check near-end tester raise RFAULT
    ${result2}=  Is Alarm Raised  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF
    
    Run Keyword Unless  '${result1}' == 'True'  FAIL  far-end tester raise LFAULT fails
    Run Keyword Unless  '${result2}' == 'True'  FAIL  near-end tester raise RFAULT fails
    
    Log To Console  near-end stop inject LFAULT
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Sleep   ${period}
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    Verify Client Interfaces In Traffic Chain Are Up
    
    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF


TC2
    [Documentation]  near-end inject RF to Client Interface
    ...              RLI38964 5.3-2 
    [Tags]
    Log To Console  near-end inject RFAULT
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF
    Sleep   ${period}
    
    Log To Console  check far-end tester raise RFAULT
    ${result}=  Is Alarm Raised  ${testSetHandle2}  ALARM_ETHERNET_ETH_RF
    
    Run Keyword Unless  '${result}' == 'True'  FAIL  far-end tester raise RFAULT fails
    
    Log To Console  near-end stop inject RFAULT
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF
    Sleep   ${period}
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    Verify Client Interfaces In Traffic Chain Are Up
    
    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF

TC3
    [Documentation]  fiber break at client side
    ...              RLI38964  5.3-4 
    [Tags]
    Log To Console  near-end fiber break at client side
    Set Laser State  ${testSetHandle1}  OFF
    Sleep   ${period}
    
    Log To Console  check far-end tester raise LFAULT
    ${result1}=  Is Alarm Raised  ${testSetHandle2}  ALARM_ETHERNET_ETH_LF
    
    Log To Console  check near-end tester raise RFAULT
    ${result2}=  Is Alarm Raised  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF
    
    Run Keyword Unless  '${result1}' == 'True'  FAIL  far-end tester raise LFAULT fails
    Run Keyword Unless  '${result2}' == 'True'  FAIL  near-end tester raise RFAULT fails
    
    Log To Console  near-end fiber recovery
    Set Laser State  ${testSetHandle1}  ON
    Sleep   ${period}
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    Verify Client Interfaces In Traffic Chain Are Up
    
    [Teardown]  Set Laser State  ${testSetHandle1}  ON


TC4
    [Documentation]  Admin OOS at Client Interface
    ...              RLI38964  5.3-6
    [Tags]  Sanity 
    Log To Console  Disable near-end client
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    Sleep   ${period}   
    
    Log To Console  check far-end tester raise RFAULT
    ${result1}=  Is Alarm Raised  ${testSetHandle2}  ALARM_ETHERNET_ETH_RF
    
    Log To Console  check near-end tester raise LFAULT
    ${result2}=  Is Alarm Raised  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    
    Run Keyword Unless  '${result1}' == 'True'  FAIL  far-end tester raise RFAULT fails
    Run Keyword Unless  '${result2}' == 'True'  FAIL  near-end tester raise LFAULT fails
    
    Log To Console  Enable near-end client
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    Verify Client Interfaces In Traffic Chain Are Up
    
    [Teardown]
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=inService


TC5
    [Documentation]  Admin OOS at OCH Interface
    ...              RLI38964 5.3-5
    [Tags]  Sanity
    Log To Console  Disable near-end och
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    Sleep   ${period}   

    Log To Console  check far-end tester raise LFAULT
    ${result1}=  Is Alarm Raised  ${testSetHandle2}  ALARM_ETHERNET_ETH_LF

    Log To Console  check near-end tester raise RFAULT
    ${result2}=  Is Alarm Raised  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF
    
    Run Keyword Unless  '${result1}' == 'True'  FAIL  far-end tester raise LFAULT fails
    Run Keyword Unless  '${result2}' == 'True'  FAIL  near-end tester raise RFAULT fails
    
    Log To Console  Disable near-end och
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    Sleep   ${period}   
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    Verify Client Interfaces In Traffic Chain Are Up
    
    [Teardown]
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=inService


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
    
    @{odl_sessions}    create list   ${opr_session}   ${cfg_session}
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

    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}


    Log To Console  load pre-default provision on device0
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Log To Console  load pre-default provision on device1
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  
	
    Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}

  
    
    
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
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}


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
    
Verify Traffic Is Blocked
    Log To Console  Verify Traffic Is Blocked
    
    Sleep  20   

    Clear Statistic And Alarm  ${testSetHandle1}
    Clear Statistic And Alarm  ${testSetHandle2}
       
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
   
    @{lTxFail}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRxFail}=  create list  ${testSetHandle2}  ${testSetHandle1}
    
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${EMPTY LIST}  ${EMPTY LIST}  ${lTxFail}  ${lRxFail}
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails After Service De-provision


Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${OPER_STATUS_ON}

    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${OPER_STATUS_ON}
