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
Resource        ../lib/notification.robot

Suite Setup   Run Keywords  Toby Suite Setup
...              Test Bed Init

Test Setup  Run Keywords  Toby Test Setup

Test Teardown  Run Keywords  Toby Test Teardown

Suite Teardown  Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{auth}    admin    admin
${interval}  10
${timeout}  120
${period}  15

@{EMPTY LIST}

${ALARM CHECK TIMEOUT}  2 min
${OPER_STATUS_ON}  inService
${OPER_STATUS_OFF}  outOfService


*** Test Cases ***
#TC0
#    [Documentation]  Service Provision
#   ...              RLI38968 5.1-8
#   [Tags]  Sanity  tc0
#   Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
#
#   Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
#
#   Log To Console  turn Laser on
#   Set Laser State  ${testSetHandle1}  ON
#   Log To Console  Verify Traffic
#   Verify Traffic Is OK


TC1
    [Documentation]  Verify Los alarm in Client Interface
    ...              RLI38964  5.4-1 5.6-1
    [Tags]  Sanity  tc1
    ${random}=  Evaluate  random.randint(20, 60)  modules=random
    Sleep  ${random}
    Log To Console   Waiting for Interfaces to be alarm free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console  turn Laser off
    Set Laser State  ${testSetHandle1}  OFF

    @{alarmNotification}=  Create List  alarm-notification  ${client intf}  Loss of Signal
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify Alarms
    # @{expectedAlarms}  Create List  Loss of Signal  Remote Fault Tx
    @{expectedAlarms}  Create List  Loss of Signal
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}

    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}


    Log To Console  turn Laser on
    Set Laser State  ${testSetHandle1}  ON

    @{alarmNotification}=  Create List  alarm-notification  ${client intf}  Loss of Signal  clear
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console  Verify Alarms
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

    #Verify Client Interfaces In Traffic Chain Are Up

    #Log To Console  Verify Traffic
    #Verify Traffic Is OK

    [Teardown]  Set Laser State  ${testSetHandle1}  ON


TC2
    [Documentation]  Verify Local Fault Rx/Tx alarm in Client Interface
    ...              RLI38964 5.4-2 5.4-6 5.6-2 5.6-6
    [Tags]  tc2
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    Log To Console  near-end inject LFAULT
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF

    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Local Fault Rx
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

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

    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Local Fault Rx  clear
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx  clear
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

    #Verify Client Interfaces In Traffic Chain Are Up

    #Log To Console  Verify Traffic
    #Verify Traffic Is OK

    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF


TC3
    [Documentation]  Verify Remote Fault Rx/Tx alarm in Client Interface
    ...              RLI38964 5.4-3 5.4-7 5.6-2 5.6-6
    [Tags]  tc3
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    Log To Console  near-end inject RFAULT

    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF

    @{alarmNotification}=  Create List  alarm-notification  ${client intf}  Remote Fault Rx
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

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

    @{alarmNotification}=  Create List  alarm-notification  ${client intf}  Remote Fault Rx  clear
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}



    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

    #Verify Client Interfaces In Traffic Chain Are Up

    #Log To Console  Verify Traffic
    #Verify Traffic Is OK

    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_RF


#TC4
#    [Documentation]  Verify HI BER ALARM in 100ge Client Interface
#   ...              RLI38964 5.4-4 5.6-4
#    [Tags]  tc4
#    Wait Until Interfaces In Traffic Chain Are Alarm Free
#    Log To Console  near-end inject HI BER
#    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK  1.0E-02
#    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Loss of Alignment Rx
#    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx
#    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
#    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

#   Log To Console  Verify Alarms
#    @{expectedAlarms}  Create List  Loss of Alignment Rx  Remote Fault Tx
#    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

#    ${random}=  Evaluate  random.randint(1, 60)  modules=random
#    Sleep  ${random}

#    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
#    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}


#    Log To Console  near-end stop inject HI BER
#    Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK
#    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Loss of Alignment Rx  clear
#    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx  clear
#    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
#    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

#    Log To Console  Verify Alarms
#    Wait Until Interfaces In Traffic Chain Are Alarm Free

#    ${random}=  Evaluate  random.randint(1, 60)  modules=random
#    Sleep  ${random}
#    Verify Interfaces In Traffic Chain Are Alarm Free

#    Verify Client Interfaces In Traffic Chain Are Up

#    Log To Console  Verify Traffic
#    Verify Traffic Is OK

    [Teardown]  Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK

TC5
    [Documentation]  Verify Loss of Alignment in 100ge Client Interface
    ...              RLI38964 5.4-5 5.6-5
    [Tags]  tc5
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    Log To Console  near-end inject Loss of Alignment
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK  MAX
    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Loss of Alignment Rx
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify Alarms
    @{expectedAlarms}  Create List  Loss of Alignment Rx  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}

    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}


    Log To Console  near-end stop inject Loss of Alignment
    Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK
    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Loss of Alignment Rx  clear
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx  clear
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify Alarms

    Wait Until Interfaces In Traffic Chain Are Alarm Free

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

    #Verify Client Interfaces In Traffic Chain Are Up

    #Log To Console  Verify Traffic
    #Verify Traffic Is OK

    [Teardown]  Stop Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_BLK


TC6
    [Documentation]  Verify tx LF mask tx RF in 100ge Client Interface
    ...              RLI38964  5.5-5
    [Tags]  Sanity  tc6
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    Log To Console  Step1 Remote Fault Tx raise in client Interface
    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Local Fault Rx
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

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
    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Local Fault Rx  clear
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx  clear
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify Alarms
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

    #Verify Client Interfaces In Traffic Chain Are Up

    #Log To Console  Verify Traffic
    #Verify Traffic Is OK

    [Teardown]
    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
    Stop Inject Alarm On Test Equipment  ${testSetHandle2}  ALARM_ETHERNET_ETH_LF


TC7
    [Documentation]  Verify Los alarm after warm reload in 100ge client interface
    ...              RLI38964
    [Tags]  tc7
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    Log To Console  turn Laser off
    Set Laser State  ${testSetHandle1}  OFF
    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Loss of Signal
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify LOS Alarms in near-end client
    @{expectedAlarms}  Create List  Loss of Signal  Remote Fault Tx
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log To Console  Warm Reload Device
    Destory Netconf Client Handle  ${ncHandle}
    Rpc Command For Warm Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0


    Log To Console  Verify LOS Alarms in near-end client after warm reload
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}

    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}

    ${ncHandle}=  Get Netconf Client Handle  ${tv['device0__re0__mgt-ip']}
    Set Suite Variable    ${ncHandle}

       ${ncHandle remote}=  Get Netconf Client Handle  ${tv['device1__re0__mgt-ip']}
    Set Suite Variable    ${ncHandle remote}

    Log To Console  turn Laser on
    Set Laser State  ${testSetHandle1}  ON
    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Loss of Signal  clear
    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx  clear
    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

    Log To Console  Verify Alarms Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

    #Verify Client Interfaces In Traffic Chain Are Up

    #Log To Console  Verify Traffic OK
    #Verify Traffic Is OK

    [Teardown]  Set Laser State  ${testSetHandle1}  ON


#TC8
#    [Documentation]  Verify Local Fault Rx/Tx alarm after cold reload in Client Interface
#    ...              RLI38964
#    [Tags]  tc8
#    Wait Until Interfaces In Traffic Chain Are Alarm Free
#    Log To Console  near-end inject LFAULT
#    Start Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
#    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Local Fault Rx
#    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx
#    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
#    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}
#
#    Log To Console  Verify LF RX Alarms in near-end client
#    @{expectedAlarms1}  Create List  Local Fault Rx  Remote Fault Tx
#    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}  ${ALARM CHECK TIMEOUT}
#
#    Log To Console  Verify Alarms LF TX Alarms in far-end client
#    @{expectedAlarms2}  Create List  Local Fault Tx  Remote Fault Rx
#    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}  ${ALARM CHECK TIMEOUT}
#
#    Destory Netconf Client Handle  ${ncHandle}
#
#    Log To Console  Cold Reload Device
#    Rpc Command For Cold Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0
#
#
#    ${random}=  Evaluate  random.randint(1, 60)  modules=random
#    Sleep  ${random}
#    Log To Console  Verify LF RX Alarms in near-end client after cold reload
#    @{expectedAlarms1}  Create List  Local Fault Rx  Remote Fault Tx
#    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms1}
#    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
#
#    Log To Console  Verify Alarms LF TX Alarms in far-end client after cold reload
#    @{expectedAlarms2}  Create List  Local Fault Tx  Remote Fault Rx
#    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms2}
#    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
#
#    ${ncHandle}=  Get Netconf Client Handle  ${tv['device0__re0__mgt-ip']}
#    Set Suite Variable    ${ncHandle}
#
#    Log To Console  near-end stop inject LFAULT
#    Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF
#    @{alarmNotification1}=  Create List  alarm-notification  ${client intf}  Local Fault Rx  clear
#    @{alarmNotification2}=  Create List  alarm-notification  ${client intf}  Remote Fault Tx  clear
#    @{alarmNotifications}=  Create List  ${alarmNotification1}  ${alarmNotification2}
#    Notifications Should Raised  ${ncHandle}  ${alarmNotifications}
#
#    Log To Console  Verify Alarms Free
#
#    Wait Until Interfaces In Traffic Chain Are Alarm Free
#
#    ${random}=  Evaluate  random.randint(1, 60)  modules=random
#    Sleep  ${random}
#    Verify Interfaces In Traffic Chain Are Alarm Free

    #Verify Client Interfaces In Traffic Chain Are Up

    #Log To Console  Verify Traffic OK
    #Verify Traffic Is OK

#    [Teardown]  Stop Inject Alarm On Test Equipment  ${testSetHandle1}  ALARM_ETHERNET_ETH_LF


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
	
    Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}


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

    Log To Console   Creating services on devices
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

    #Wait Until Interfaces In Traffic Chain Are Alarm Free

    #Log To Console   Verify Traffic Is OK
    #Verify Traffic Is OK

    #Verify Client Interfaces In Traffic Chain Are Up



Test Bed Teardown
    [Documentation]  Test Bed Teardown

    #Destory Netconf Client Handle  ${ncHandle}

    Log To Console  Remove Service
    #Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    #Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}


#Verify Traffic Is OK
#    Log To Console  Verify Traffic Is OK
#    : FOR    ${nLoop}    IN RANGE    1    6
#    \    Sleep  20
#    \    Log To Console  Check Traffic Status for the ${nLoop} time
#    \    Clear Statistic And Alarm  ${testSetHandle1}
#    \    Clear Statistic And Alarm  ${testSetHandle2}
#
#    \    Start Traffic  ${testSetHandle1}
#    \    Start Traffic  ${testSetHandle2}
#
#    \    Sleep  10
#
#    \    stop Traffic  ${testSetHandle1}
#    \    stop Traffic  ${testSetHandle2}
#    \
#    \    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
#    \    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
#    \    @{EMPTY LIST}=  create list
#    \    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
#
#    \    Exit For Loop If  '${result}' == "PASS"
#    \    Run Keyword Unless  '${result}' == "PASS"  Log To Console  Check Traffic Status fails for the ${nLoop} time
#
#    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
#
#    Clear Statistic And Alarm  ${testSetHandle1}
#    Clear Statistic And Alarm  ${testSetHandle2}
#
#    Start Traffic  ${testSetHandle1}
##    Start Traffic  ${testSetHandle2}
#
#    Sleep  60
#
#    stop Traffic  ${testSetHandle1}
#    stop Traffic  ${testSetHandle2}
#
#    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
#    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
#    @{EMPTY LIST}=  create list
#    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
#
#    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails


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
