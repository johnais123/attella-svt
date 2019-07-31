*** Settings ***
Documentation    This is Attella 100ge Alarm Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38964: ACX6180-T: Attella 4x100GE base transponder capability
...              Author: Linda Li
...              Date   : 02/22/2019
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/39315
...              jtms description           : Attella
...              RLI                        : 39315
...              MIN SUPPORT VERSION        : 19.2
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : OPENROADM
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
Resource        ../lib/notification.robot

Suite Setup   Run Keywords  Toby Suite Setup
...              Test Bed Init

Test Setup  Run Keywords  Toby Test Setup

Test Teardown  Run Keywords  Toby Test Teardown

Suite Teardown  Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
${ATTELLA_DEF_100GE_CLIENT_NAME}    jmc-100ge-client-port
${ATTELLA_DEF_LINE_OCH_NAME}    jmc-och-line-port
${ATTELLA_DEF_LINE_OTU_NAME}    jmc-otu-line-port
${ATTELLA_DEF_LINE_ODU_NAME}    jmc-odu-line-port

@{auth}    admin    admin
${interval}  10
${timeout}  120
${period}  15
@{pmInterval}   15min    24Hour
@{EMPTY LIST}

${ALARM CHECK TIMEOUT}  2 min
${OPER_STATUS_ON}  inService
${OPER_STATUS_OFF}  outOfService


*** Test Cases ***
TC0
    [Documentation]  Verify Traffic
    ...              RLI39315  5.2-1
    [Tags]   tc0

    Log To Console  Verify Traffic
    Verify Traffic Is OK


TC1
    [Documentation]  Verify Los alarm in Client Interface
    ...              RLI39315  5.2-3
    [Tags]   tc1
    ${random}=  Evaluate  random.randint(20, 60)  modules=random
    Sleep  ${random}
    Log To Console   Waiting for Interfaces to be alarm free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console  turn Laser off
    Set Laser State  ${testSetHandle1}  OFF

    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_100GE_CLIENT_NAME}  Loss of Signal
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify Alarms
    # @{expectedAlarms}  Create List  Loss of Signal  Remote Fault Tx
    @{expectedAlarms}  Create List  Loss of Signal
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}

    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${OPER_STATUS_OFF}


    Log To Console  turn Laser on
    Set Laser State  ${testSetHandle1}  ON

    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_100GE_CLIENT_NAME}  Loss of Signal  clear
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    [Teardown]  Set Laser State  ${testSetHandle1}  ON


TC2
    [Documentation]  Verify current 15min PM BIPErrorCounter rx and erroredSecondsEthernet rx
    ...              RLI39315  5.2-4
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 

    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    Log To Console  inject BIP error
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   1
    Sleep   10
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${ATTELLA_DEF_100GE_CLIENT_NAME}   ${pmEntryParmaterlist}    @{pmInterval}[0]

    log  ${realpm}
    @{expectValue}       Create List   20
    Verify Pm Should Be Equals  @{expectValue}[0]     @{realpm}[0]  

    @{expectNextValue}       Create List   1
    Verify Pm Should Be Equals  @{expectNextValue}[0]     @{realpm}[1]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  


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

    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Log To Console  load pre-default provision on device0
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Log To Console  load pre-default provision on device1
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
	

    Log To Console  init test set to 100ge
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    Log To Console      Init Test Equipment ${testEquipmentInfo}: protocol 100ge
    Init Test Equipment  ${testSetHandle1}  100ge

    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
    Log To Console      Init Test Equipment ${testEquipmentInfo}: protocol 100ge
    Init Test Equipment  ${testSetHandle2}  100ge

    ${ncHandle}=  Get Netconf Client Handle  ${tv['device0__re0__mgt-ip']}
    Set Suite Variable    ${ncHandle}
   
    Log To Console    Starting traffic on test sets 
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}

    @{ifnames}     Create List    ${ATTELLA_DEF_LINE_OCH_NAME}    ${ATTELLA_DEF_LINE_OTU_NAME}    ${ATTELLA_DEF_LINE_ODU_NAME}    ${ATTELLA_DEF_100GE_CLIENT_NAME}            

    Log To Console   Creating services on devices
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}    ${ifnames}
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}    ${ifnames}



Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
    @{ifnames}     Create List    ${ATTELLA_DEF_LINE_OCH_NAME}    ${ATTELLA_DEF_LINE_OTU_NAME}    ${ATTELLA_DEF_LINE_ODU_NAME}    ${ATTELLA_DEF_100GE_CLIENT_NAME}            
    Remove 100GE Service   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}    ${ifnames}
    Remove 100GE Service   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}    ${ifnames}

    Log To Console  Stopping Traffic    
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}

    Log To Console  Clean up Interfaces
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}


Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${EMPTY LIST}

    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${EMPTY LIST}


Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}

    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${OPER_STATUS_ON}

    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_100GE_CLIENT_NAME}  ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${OPER_STATUS_ON}
