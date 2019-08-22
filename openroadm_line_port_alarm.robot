*** Settings ***
Documentation    This is Attella line port alarm testing Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38968: OpenROADM Device Data Model for 400G transparent transponder targeting Metro/DCI applications
...              Author: Jack Wu
...              Date   : 12/26/2018
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
...              jtms description           : Attella
...              RLI                        : 38968
...              MIN SUPPORT VERSION        : 19.1
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : CHASSIS_MGMT
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

Resource         jnpr/toby/Master.robot

Library          BuiltIn
Library          String
Library          Collections
Library          OperatingSystem
Library          String
Library          ExtendedRequestsLibrary
Library          XML    use_lxml=True


Resource         lib/restconf_oper.robot
Resource         lib/testSet.robot
Resource         lib/attella_keyword.robot
Resource         lib/notification.robot



Suite Setup      Run Keywords
...              Toby Suite Setup
...              Test Bed Init

Test Setup  Run Keywords
...              Toby Test Setup

Test Teardown  Run Keywords
...              Toby Test Teardown

Suite Teardown   Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      1 min 
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
${interval}                 10
${timeout}                  100
&{delete_headers}           Accept=application/xml
${CFG_SESSEION_INDEX}       1

*** Test Cases ***
TC1
   [Documentation]  Near-end inject LOS to Client Interface
   ...              Mapping JTMS RLI-38966 TC 5.4-1, 5.4-3
   ...              Description:  Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test ODU-AIS alarm on line port.
   ...              Test1 inject LOS to CX: CX raise OTU4 LOS, Ly will raise ODU-AIS alarm , Test 1 raise BDI and Test 2 will raise ODU4-AIS alarm
   [Tags]           Sanity  tc1   
    
   Log To Console   Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   Log              Turn Laser off
   Set Laser State  ${testSetHandle1}  OFF
   
   @{alarmNotification}=  Create List  alarm-notification  ${client otu intf}  Loss of Signal
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

   Log              Wait a random time to keep the alarm stable on Attella
   ${random}=  Evaluate  random.randint(1, 30)  modules=random
   Sleep  ${random}   
   
   Log              Verify LOS Alarm was raised on Cx 
   @{expectedAlarms}  Create List  Loss of Signal
   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}   
   
   Log              Verify ODU-AIS wasi raised on Ly
   @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
   Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}   
   
   Log               Verify OTU-BDI was raised on Test1.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_OTU4_BDI
   Is Alarm Raised  ${testSetHandle1}     ${expectedAlarms_remote_Test_Set}   

   Log               Verify ODU4-AIS was raised on Test2.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
   Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}  

   Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}          ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}          ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}          ${OPER_STATUS_ON}

   Log              Verify OTU4/ODU4 operation status on Cx are outOfService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}            ${OPER_STATUS_OFF}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}        ${OPER_STATUS_OFF}


   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}   

   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}       ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}   ${OPER_STATUS_ON}


   Log              Turn Laser on
   Set Laser State  ${testSetHandle1}  ON
   
   @{alarmNotification}=  Create List  alarm-notification  ${client otu intf}  Loss of Signal  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

   Log              Verify Alarms In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free

   Log              Wati a random time the check wether the alarm still exist or not
   ${random}=       Evaluate  random.randint(1, 30)  modules=random
   Sleep            ${random}
   
   Log              Verify Cx/Lx and Cy/Ly are error free
   Verify Interfaces In Traffic Chain Are Alarm Free

   
   [Teardown]  Set Laser State  ${testSetHandle1}  ON
   

TC2
    [Documentation]  Disable near-end OCH interface
    ...              Mapping JTMS RLI-38966 TC 5.4-14, 5.4-15
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test ODU-AIS alarm on line port.
    ...              Disable OCH on Lx, Ly will raise ODU-AIS alarm and Test2 will raise ODU4-AIS alarm
    [Tags]           Advance  tc2

    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Disable OCH interface Lx
    &{intf}          create dictionary   interface-name=${line och intf}  interface-administrative-state=outOfService
    @{interface_info}    create list     ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  ODU Alarm Indication Signal
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log               Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log               Verify ODU-AIS was raised on Ly
    @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}
    
    Log               Verify ODU4-AIS was raised on Test2
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}
    
    Log              Verify OCH/OTU4/ODU4 operation status on Lx are outOfService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_OFF}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_OFF}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_OFF}
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}
    
    Log              Enable OCH interface on local line port
    &{intf}          create dictionary   interface-name=${line och intf}  interface-administrative-state=inService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  ODU Alarm Indication Signal  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
  

   [Teardown]  	Enable interface   ${line och intf}
	
	
TC3
    [Documentation]  Disable near-end Line OUT4 interface
    ...              Mapping JTMS RLI-38966 TC5.4-16
    ...              Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test ODU-AIS alarm on line port
    ...              Disable OTU4 on Lx, Ly will raise ODU-AIS alarm and Test 2 will raise ODU4-AIS alarm
    [Tags]           Advance  tc3


    Log              Disable local line OTU4, remote Line will raise ODU-AIS and Remote Test will raise ODU4-AIS

    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
	
    Log              Disable OCH interface on local line port
    &{intf}          create dictionary   interface-name=${line otu intf}  interface-administrative-state=outOfService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}

   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  ODU Alarm Indication Signal
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
   Log              Wait a random time to keep the alarm stable on Attella
   ${random}=  Evaluate  random.randint(1, 30)  modules=random
   Sleep  ${random}
   
   Log              Verify ODU-AIS was raised on remote line port
   @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
   Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}

   Log              Verify ODU4-AIS was raised on remote Test Set.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

   Log              Verify OTU4/ODU4 operation status on Lx are outOfService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_OFF}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_OFF}

   Log              Verify OCH operation status on Lx is inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
   
   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

   Log              Enable OTU4 interface on local line port
    &{intf}=         create dictionary   interface-name=${line otu intf}  interface-administrative-state=inService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}    

   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  ODU Alarm Indication Signal  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
   Log              Verify Alarms In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   ${random}=  Evaluate  random.randint(1, 30)  modules=random
   Sleep  ${random}
   Verify Interfaces In Traffic Chain Are Alarm Free
    

   [Teardown]  	Enable interface   ${line otu intf}
   
TC4
    [Documentation]  Disable near-end Line ODU4 interface
    ...              Mapping JTMS RLI-38966 TC 5.4-17
    ...              Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test ODU-AIS alarm on line port
    ...              Disable ODU4 on Lx, Ly will raise ODU-AIS alarm and Test 2 will raise ODU4-AIS alarm
    [Tags]           Advance  tc4


    Log              Disable local ODU4 on Lx, remote Line will raise ODU-AIS and Remote Test will raise ODU4-AIS

    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

   Log              Disable OCH interface on local line port
    &{intf}=         create dictionary   interface-name=${line odu intf}  interface-administrative-state=outOfService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}

   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  ODU Alarm Indication Signal
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
   Log              Wait a random time to keep the alarm stable on Attella
   ${random}=  Evaluate  random.randint(1, 30)  modules=random
   Sleep  ${random}
   
   Log              Verify ODU-AIS was raised on remote line port
   @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
   Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}

   Log              Verify ODU4-AIS was raised on remote Test Set.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

   Log              Verify OTU4/ODU4 operation status on Lx are outOfService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_OFF}

   Log              Verify OCH/OTU4 operation status on Lx is inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
   
   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

   Log              Enable OTU4 interface on local line port
    &{intf}=         create dictionary   interface-name=${line odu intf}  interface-administrative-state=inService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}  
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  ODU Alarm Indication Signal  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
   Log              Verify Alarms In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   ${random}=  Evaluate  random.randint(1, 30)  modules=random
   Sleep  ${random}
   Verify Interfaces In Traffic Chain Are Alarm Free
    

   [Teardown]  	Enable interface   ${line odu intf}    
   
TC5
    [Documentation]  <tim-detect-mode>Enabled and <tim-act-enabled>true : Near-end line OTU4 send wrong SAPI
    ...              Mapping JTMS RLI-38966 TC 5.3-13, 5.7-1
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM and OUT4-BDI alarm on line port
    ...              Modify the tx-sapi value for OTU4 on Lx, Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm a          ...              will raise ODU4-AIS alarm
    [Tags]           Sanity  tc5
    Log    Modify the tx-sapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console   Modify tx-sapi on local line
    Log              Modify the tx-sapi value for OTU4 on local line port
    &{intf}            create dictionary   interface-name=${line otu intf}    otu-tx-sapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}

   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log To Console   verify TTIM on remote line
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}  ${expectedAlarms_remote_line}

    Log To Console   verify BDI on local line
    Log              Verify OTU4-BDE=I was raised on local line port
    @{expectedAlarms_local_line}      Create List       Backward Defect Indication  
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}         ${expectedAlarms_local_line}    
    
    Log              Verify ODU4-AIS was raised on remote Test Set.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log To Console   verify op status  on local line
    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log To Console   verify op status  on remote line
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log To Console   reset tx-sapi on local line
    Log              Enable OTU4 tx-sapi back to "tx-sapi-val" on local line port
    &{intf}          create dictionary   interface-name=${line otu intf}  otu-tx-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log To Console   clear alarm
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log To Console   wait for alarm to clear
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
	
   [Teardown]  	  Recover OTU TTI on Attella    ${line otu intf}  
   
TC6
    [Documentation]  <tim-detect-mode>Enabled and <tim-act-enabled>true : Near-end line OTU4 send wrong DAPI
    ...              Mapping JTMS RLI-38966 TC 5.3-14
    ...              Description:  Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM and OUT4-BDI alarm on line port
    ...              modify the tx-sapi value for OTU4 on Lx, Ly will raise TTIM alarm/Lx will raise OUT4-BDI,Test2 raise ODU-AIS    
    [Tags]           Advance  tc6


    Log              Modify tx-dapi value for OTU4 ON Lx,Ly will raise TTIM and Test2 raise ODU-AIS alarm.
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the tx-sapi value for OTU4 on local line port
    &{intf}            create dictionary   interface-name=${line otu intf}    otu-tx-dapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}  ${expectedAlarms_remote_line}

    Log              Verify OTU4-BDE=I was raised on local line port
    @{expectedAlarms_local_line}      Create List       Backward Defect Indication  
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}         ${expectedAlarms_local_line}    
    
    Log              Verify ODU4-AIS was raised on remote Test Set.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Enable OTU4 tx-dapi back to "tx-dapi-val" on local line port
    &{intf}          create dictionary   interface-name=${line otu intf}  otu-tx-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free 

   [Teardown]  	  Recover OTU TTI on Attella    ${line otu intf} 	
	
TC7
    [Documentation]  <tim-detect-mode>SAPI-and-DAPI and <tim-act-enabled>true : Near-end line OTU4 send wrong SAPI and DAPI
    ...              Mapping JTMS RLI-38966 TC 5.3-12
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM and OUT4-BDI alarm on line port
    ...              Modify the tx-dapi value for OTU4 on Lx, Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2                 
    ...              will raise ODU4-AIS alarm
    [Tags]           Advance  tc7


    Log    Modify the tx-dapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the tx-sapi and tx-dapi value for OTU4 on local line port
    &{intf}            create dictionary   interface-name=${line otu intf}    otu-tx-sapi=012345   otu-tx-dapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}  ${expectedAlarms_remote_line}

    Log              Verify OTU4-BDE=I was raised on local line port
    @{expectedAlarms_local_line}      Create List       Backward Defect Indication  
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}         ${expectedAlarms_local_line}    
    
    Log              Verify ODU4-AIS was raised on remote Test Set.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Enable OTU4 tx-sapi and tx-sapi back to "tx-dapi-val" on local line port
    &{intf}          create dictionary   interface-name=${line otu intf}  otu-tx-sapi=tx-sapi-val   otu-tx-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Recover OTU TTI on Attella    ${line otu intf} 	
    
TC8
    [Documentation]  <tim-detect-mode>SAPI and <tim-act-enabled>true : Near-end line OTU4 send wrong SAPI
    ...              Mapping JTMS RLI-38966 TC 5.3.9
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM and OUT4-BDI alarm on line port
    ...              Modify the tx-sapi value for OTU4 on Lx, Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2                 
    ...              will raise ODU4-AIS alarm
    [Tags]           Advance  tc8


    Log    Modify the tx-dapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the tx-sapi value for OTU4 on local line port
    &{intf}            create dictionary   interface-name=${line otu intf}    otu-tx-sapi=012345  
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}  ${expectedAlarms_remote_line}

    Log              Verify OTU4-BDE=I was raised on local line port
    @{expectedAlarms_local_line}      Create List       Backward Defect Indication  
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}         ${expectedAlarms_local_line}    
    
    Log              Verify ODU4-AIS was raised on remote Test Set.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Enable OTU4 tx-sapi back to "tx-sapi-val" on local line port
    &{intf}          create dictionary   interface-name=${line otu intf}  otu-tx-sapi=tx-sapi-val   
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Recover OTU TTI on Attella    ${line otu intf} 	
	
TC9
    [Documentation]  <tim-detect-mode>DAPI and <tim-act-enabled>true : Near-end line OTU4 send wrong DAPI
    ...              Mapping JTMS RLI-38966 TC 5.3.10
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM and OUT4-BDI alarm on line port
    ...              Modify the tx-dapi value for OTU4 on Lx, Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2                 
    ...              will raise ODU4-AIS alarm			
    [Tags]           Advance  tc9


    Log    Modify the tx-dapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the tx-dapi value for OTU4 on local line port
    &{intf}            create dictionary   interface-name=${line otu intf}    otu-tx-dapi=012345  
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}  ${expectedAlarms_remote_line}

    Log              Verify OTU4-BDE=I was raised on local line port
    @{expectedAlarms_local_line}      Create List       Backward Defect Indication  
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}         ${expectedAlarms_local_line}    
    
    Log              Verify ODU4-AIS was raised on remote Test Set.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Enable OTU4 tx-dapi back to "tx-dapi-val" on local line port
    &{intf}          create dictionary   interface-name=${line otu intf}  otu-tx-dapi=tx-dapi-val   
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
   @{alarmNotification}=  Create List  alarm-notification  ${remote line otu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free  

   [Teardown]  	  Recover OTU TTI on Attella    ${line otu intf} 	

TC10
    [Documentation]  <tim-detect-mode>SAPI and DAPI, <tim-act-enabled>true : change Near-end line ODU4 <expected-sapi> value
    ...              Mapping JTMS RLI-38966 TC 5.4-8
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM alarm will raised on remote line ODU port
    ...              Modify the <expected-sapi> value for ODU4 on Ly, Ly will raise TTIM alarm to against ODU.                 
    [Tags]           Advance  tc10


    Log              Modify the <expected-sapi> value for OTU4 on Ly,Ly will raise TTIM on ODU layer
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the odu-expected-sapi value for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-sapi=012345    
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}


    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Modify the odu-expected-sapi's value back to "tx-sapi-val" for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}   odu-expected-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload} 
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Recover ODU TTI on Attella	 ${remote line odu intf}
	
TC11
    [Documentation]  <tim-detect-mode>SAPI and DAPI, <tim-act-enabled>true : change Far-end line ODU4 <expected-dapi> value
    ...              Mapping JTMS RLI-38966 TC 5.4-6
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM alarm will raised on remote line ODU port
    ...              Modify the <expected-dapi> value for ODU4 on Ly, Ly will raise TTIM alarm to against ODU.                 
    [Tags]           Advance  tc11


    Log              Modify the <expected-dapi> value for ODU4 on Ly,Ly will raise TTIM on ODU layer
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the <expected-dapi> value for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-dapi=012345    
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}


    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Modify the odu-expected-dapi's value back to "tx-dapi-val" for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload} 
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Recover ODU TTI on Attella	 ${remote line odu intf}	

	
TC12
    [Documentation]  <tim-detect-mode>SAPI and DAPI, <tim-act-enabled>true : change Near-end line ODU4 <expected-sapi>/<expected-dapi> value
    ...              Mapping JTMS RLI-38966 TC 5.4-10
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM alarm will raised on remote line ODU port
    ...              Modify the <expected-dapi> value for ODU4 on Ly, Ly will raise TTIM alarm to against ODU.                 
    [Tags]           Advance  tc12


    Log              Modify the <expected-sapi>/<expected-dapi> value for ODU4 on LY,Ly will raise TTIM alarm on ODU layer
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the odu-expected-dapi value for ODU4 on remote line port
    &{intf}            create dictionary   interface-name=${remote line odu intf}    odu-expected-sapi=012345  odu-expected-dapi=012345    
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}


    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Modify the <expected-sapi>/<expected-dapi> 's value back to "tx-sapi-val"/"tx-dapi-val" for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-sapi=tx-sapi-val    odu-expected-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload} 
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Recover ODU TTI on Attella	 ${remote line odu intf}

	
TC13
    [Documentation]  <tim-detect-mode> SAPI, <tim-act-enabled>true : change Near-end line ODU4 <expected-sapi> value
    ...              Mapping JTMS RLI-38966 TC5.4-7
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM alarm will raised on remote line ODU port
    ...              Modify the <expected-sapi> value for ODU4 on Ly, Ly will raise TTIM alarm to against ODU.                 
    [Tags]           Advance  tc13

    Log              Modify the <expected-sapi> value for ODU4 on Ly,Ly will raise TTIM on ODU layer
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the odu-expected-sapi value for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-sapi=012345    odu-tim-detect-mode=SAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}


    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Modify the odu-expected-sapi's value back to "tx-sapi-val" for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-sapi=tx-sapi-val         odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload} 
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Recover ODU TTI on Attella	 ${remote line odu intf}	
	
TC14
    [Documentation]  <tim-detect-mode>DAPI, <tim-act-enabled>true : change Near-end line ODU4 <expected-dapi> value
    ...              Mapping JTMS RLI-38966 TC 5.4-8
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test TTIM alarm will raised on remote line ODU port
    ...              Modify the <expected-dapi> value for ODU4 on Ly, Ly will raise TTIM alarm to against ODU.                 
    [Tags]           Advance  tc14

    Log              Modify the <expected-dapi> value for ODU4 on Ly,Ly will raise TTIM on ODU layer
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Modify the <expected-dapi> value for ODU4 on remote line port
    # Error - SAPI?: &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-dapi=012345    odu-tim-detect-mode=SAPI
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-dapi=012345    odu-tim-detect-mode=DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload}
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}


    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}        ${OPER_STATUS_ON}  
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}

    Log              Modify the odu-expected-dapi's value back to "tx-dapi-val" for ODU4 on remote line port
    &{intf}          create dictionary   interface-name=${remote line odu intf}    odu-expected-dapi=tx-dapi-val    odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload} 
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line odu intf}  Trail Trace Identifier Mismatch  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Recover ODU TTI on Attella	 ${remote line odu intf}	
 
TC15
    [Documentation]  Delete Near-end OCH/OTU4/ODU4
    ...              Description: Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test LOS alarm on line port
    ...              Delete OCH/OTU/ODU on Lx, the remote OCH will raise LOS alarm on Ly
    ...              Mapping JTMS RLI-38966 TC 5.2-1, 5.3-3
               
    [Tags]           Advance  tc15   Blocked by PR 1419722


    Log              Delete OCH/OTU4/ODU4 on Lx, the remote OCH will raise LOS alarm on Ly    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Delete ODU4 on Lx
    &{Och_interface}      create dictionary        interface-name=${line odu intf}
    @{interface_info}     create list              ${Och_interface}
    &{dev_info}           create dictionary        interface=${interface_info}
    &{payload}            create dictionary        org-openroadm-device=${dev_info}
    ${patch_resp}         Send Delete Request      ${odl_sessions}                   ${tv['device0__re0__mgt-ip']}    ${payload}
    check status line  ${patch_resp}  200

    Log              Delete OTU4 on Lx
    &{Och_interface}      create dictionary        interface-name=${line otu intf}     	
    @{interface_info}     create list              ${Och_interface} 
    &{dev_info}           create dictionary        interface=${interface_info}       
    &{payload}            create dictionary        org-openroadm-device=${dev_info}
    ${patch_resp}         Send Delete Request      ${odl_sessions}                   ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line  ${patch_resp}  200	

    Log              Delete OCH on Lx
    &{Och_interface}      create dictionary        interface-name=${line och intf}
    @{interface_info}     create list              ${Och_interface}
    &{dev_info}           create dictionary        interface=${interface_info}
    &{payload}            create dictionary        org-openroadm-device=${dev_info}
    ${patch_resp}         Send Delete Request      ${odl_sessions}                   ${tv['device0__re0__mgt-ip']}    ${payload}
    check status line  ${patch_resp}  200
	
   @{alarmNotification}=  Create List  alarm-notification  ${remote line och intf}  Loss of Signal
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log              Verify LOS was raised on remote line port(Ly)
    @{expectedAlarms_remote_line}      Create List       Loss of Signal   
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}  ${expectedAlarms_remote_line}
   
    
    Log              Verify ODU4-AIS was raised on Test2.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_OTU4_BDI
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log              Verify ODU4-AIS was raised on Test1.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS  
    Is Alarm Raised  ${testSetHandle1}     ${expectedAlarms_remote_Test_Set}        
    
    Log              Verify OCH/OTU4/ODU4 operation status on Ly are outOfService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_OFF}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_OFF}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_OFF}

    Log              Re-configure OCH/OTU4/ODU4 on Lx  
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}

   @{alarmNotification}=  Create List  alarm-notification  ${remote line och intf}  Loss of Signal  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free

   [Teardown]  	  Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
	
TC16
   [Documentation]  After Attella system warm reload,the ODU-AIS alarm still ca be raised.
   ...              TC 5.5-3 RLI-38966
   ...              Description:  Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test ODU-AIS alarm on line port.
   ...              Test1 inject LOS to CX: CX raise OTU4 LOS, Ly will raise ODU-AIS alarm , Test 1 raise BDI and Test 2 will raise ODU4-AIS alarm. After warm reloadd the Alarm in traffic chain still exist.
   [Tags]           Advance  tc16   
    
   Log To Console   Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   Log              Turn Laser off
   Set Laser State  ${testSetHandle1}  OFF
   
   @{alarmNotification}=  Create List  alarm-notification  ${client otu intf}  Loss of Signal
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

   Log              Wait a random time to keep the alarm stable on Attella
   ${random}=  Evaluate  random.randint(1, 30)  modules=random
   Sleep  ${random}   
   
   Log              Verify LOS Alarm was raised on Cx 
   @{expectedAlarms}  Create List  Loss of Signal
   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}   
   
   Log              Verify ODU-AIS wasi raised on Ly
   @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
   Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}   
   
   Log               Verify OTU-BDI was raised on Test1.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_OTU4_BDI
   Is Alarm Raised  ${testSetHandle1}     ${expectedAlarms_remote_Test_Set}   

   Log               Verify ODU4-AIS was raised on Test2.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
   Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}  
   
   Log               Warm reload the remote Attella NE   
   Destory Netconf Client Handle  ${ncHandle remote}
   Rpc Command For Warm Reload Device   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${timeout}    ${interval}   device1

   Log To Console  Verify LOS Alarms in near-end client after warm reload
   ${random}=  Evaluate  random.randint(20, 30)  modules=random
   Sleep  ${random}
   
   Log              Verify LOS Alarm was raised on Cx 
   @{expectedAlarms}  Create List  Loss of Signal
   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}   
   
   Log              Verify ODU-AIS wasi raised on Ly
   @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
   Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}   
   
   Log               Verify OTU-BDI was raised on Test1.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_OTU4_BDI
   Is Alarm Raised  ${testSetHandle1}     ${expectedAlarms_remote_Test_Set}   

   Log               Verify ODU4-AIS was raised on Test2.
   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
   Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}    

   Log              Wait a random time to keep the alarm stable on Attella
   ${random}=  Evaluate  random.randint(1, 30)  modules=random
   Sleep  ${random}    
   
   Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}          ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}          ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}          ${OPER_STATUS_ON}

   Log              Verify OTU4/ODU4 operation status on Cx are outOfService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}            ${OPER_STATUS_OFF}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}        ${OPER_STATUS_OFF}


   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}   

   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}       ${OPER_STATUS_ON}
   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}   ${OPER_STATUS_ON}

   	${ncHandle remote}=  Get Netconf Client Handle  ${tv['device1__re0__mgt-ip']}
	Set Suite Variable    ${ncHandle remote}
	
   Log              Turn Laser on
   Set Laser State  ${testSetHandle1}  ON
   
   @{alarmNotification}=  Create List  alarm-notification  ${client otu intf}  Loss of Signal  clear
   @{alarmNotifications}=  Create List  ${alarmNotification}
   Notifications Should Raised  ${ncHandle}  ${alarmNotifications}

   Log              Verify Alarms In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free

   Log              Wati a random time the check wether the alarm still exist or not
   ${random}=       Evaluate  random.randint(30, 90)  modules=random
   Sleep            ${random}
   
   Log              Verify Cx/Lx and Cy/Ly are error free
   Verify Interfaces In Traffic Chain Are Alarm Free
   
   [Teardown]  Set Laser State  ${testSetHandle1}  ON     
    

#TC17
#   [Documentation]  After Attella system cold reload,the ODU-AIS alarm still ca be raised.
#   ...              TC 5.5-6  RLI-38966
#   ...              Description:  Test1-----Cx<>Lx----Ly<>Cy-----Test2 /  Test ODU-AIS alarm on line port.
#   ...              Test1 inject LOS to CX: CX raise OTU4 LOS, Ly will raise ODU-AIS alarm , Test 1 raise BDI and Test 2 will raise ODU4-AIS alarm. After cold reload the Alarm in traffic chain still exist.
#   [Tags]           Advance  tc17   
#    
#   Log To Console   Verify Interfaces In Traffic Chain Are Alarm Free
#   Wait Until Interfaces In Traffic Chain Are Alarm Free
#   
#   Log              Turn Laser off
#   Set Laser State  ${testSetHandle1}  OFF
#   
#   @{alarmNotification}=  Create List  alarm-notification  ${client otu intf}  Loss of Signal
#   @{alarmNotifications}=  Create List  ${alarmNotification}
#   Notifications Should Raised  ${ncHandle}  ${alarmNotifications}
#
#   Log              Wait a random time to keep the alarm stable on Attella
#   ${random}=  Evaluate  random.randint(1, 30)  modules=random
#   Sleep  ${random}   
#   
#   Log              Verify LOS Alarm was raised on Cx 
#   @{expectedAlarms}  Create List  Loss of Signal
#   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}   
#   
#   Log              Verify ODU-AIS wasi raised on Ly
#   @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
#   Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}   
#   
#   Log               Verify OTU-BDI was raised on Test1.
#   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_OTU4_BDI
#   Is Alarm Raised  ${testSetHandle1}     ${expectedAlarms_remote_Test_Set}   
#
#   Log               Verify ODU4-AIS was raised on Test2.
#   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
#   Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}  
#   
#   Destory Netconf Client Handle  ${ncHandle remote}
#   Log               Warm reload the remote Attella NE   
#   Rpc Command For Cold Reload device  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${timeout}  ${interval}  device1 
#   
#   Log              Wait a random time to keep the alarm stable on Attella
#   ${random}=  Evaluate  random.randint(20,40)  modules=random
#   Sleep  ${random}   
#   
#   Log              Verify LOS Alarm was raised on Cx 
#   @{expectedAlarms}  Create List  Loss of Signal
#   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}   
#   
#   Log              Verify ODU-AIS wasi raised on Ly
#   @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
#   Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms_remote_line}   
#   
#   Log               Verify OTU-BDI was raised on Test1.
#   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_OTU4_BDI
#   Is Alarm Raised  ${testSetHandle1}     ${expectedAlarms_remote_Test_Set}   
#
#   Log               Verify ODU4-AIS was raised on Test2.
#   ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
#   Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}    
#
#   Log              Wait a random time to keep the alarm stable on Attella
#   ${random}=  Evaluate  random.randint(30,90)  modules=random
#   Sleep  ${random}       
#   
#   Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}          ${OPER_STATUS_ON}
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}          ${OPER_STATUS_ON}
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}          ${OPER_STATUS_ON}
#
#   Log              Verify OTU4/ODU4 operation status on Cx are outOfService
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}            ${OPER_STATUS_OFF}
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}        ${OPER_STATUS_OFF}
#
#
#   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}   ${OPER_STATUS_ON}
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}   ${OPER_STATUS_ON}
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}   ${OPER_STATUS_ON}   
#
#   Log              Verify OCH/OTU4/ODU4 operation status on Ly are inService
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}       ${OPER_STATUS_ON}
#   Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}   ${OPER_STATUS_ON}
#
#
#   Log              Turn Laser on
#   Set Laser State  ${testSetHandle1}  ON
#   
#   @{alarmNotification}=  Create List  alarm-notification  ${client otu intf}  Loss of Signal  clear
#   @{alarmNotifications}=  Create List  ${alarmNotification}
#   Notifications Should Raised  ${ncHandle}  ${alarmNotifications}
#
#   Log              Verify Alarms In Traffic Chain Are Alarm Free
#   Wait Until Interfaces In Traffic Chain Are Alarm Free
#
#   Log              Wati a random time the check wether the alarm still exist or not
#   ${random}=       Evaluate  random.randint(1, 30)  modules=random
#   Sleep            ${random}
#   
#   Log              Verify Cx/Lx and Cy/Ly are error free
#   Verify Interfaces In Traffic Chain Are Alarm Free
#
#   
#   [Teardown]  Set Laser State  ${testSetHandle1}  ON    	
	
	
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
	Log   ${odl_sessions}    
	
    ${client intf}       Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    ${client otu intf}   Get OTU Intface Name From ODU Intface  ${client intf}
    ${line odu intf}     Get Line ODU Intface Name From Client Intface  ${client intf}
    ${line otu intf}     Get OTU Intface Name From ODU Intface  ${line odu intf}
    ${line och intf}     Get OCH Intface Name From OTU Intface  ${line otu intf}
    Set Suite Variable    ${client intf}
    Set Suite Variable    ${client otu intf}
    Set Suite Variable    ${line odu intf}
    Set Suite Variable    ${line otu intf}
    Set Suite Variable    ${line och intf}
    
    ${remote client intf}      Get Otu4 Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    ${remote client otu intf}  Get OTU Intface Name From ODU Intface  ${remote client intf}
    ${remote line odu intf}    Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote line otu intf}    Get OTU Intface Name From ODU Intface  ${remote line odu intf}
    ${remote line och intf}    Get OCH Intface Name From OTU Intface  ${remote line otu intf}
    Set Suite Variable    ${remote client intf}
    Set Suite Variable    ${remote client otu intf}
    Set Suite Variable    ${remote line odu intf}
    Set Suite Variable    ${remote line otu intf}
    Set Suite Variable    ${remote line och intf}
    
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}
    
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}

    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    Log To Console      Init Test Equipment ${testEquipmentInfo}: protocol otu4
    Init Test Equipment  ${testSetHandle1}  otu4
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
    Log To Console      Init Test Equipment ${testEquipmentInfo}: protocol otu4
    Init Test Equipment  ${testSetHandle2}  otu4	
	    
    Set OTU FEC            ${testSetHandle1}  ${tv['uv-client_fec']}
    Set OTU FEC            ${testSetHandle2}  ${tv['uv-client_fec']}  
    set OTU SM TTI Traces  ${testSetHandle1}  OPERATOR  ${null}      tx-operator-val
    set OTU SM TTI Traces  ${testSetHandle1}  sapi      Expected     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle1}  dapi      Expected     tx-dapi-val
    set OTU SM TTI Traces  ${testSetHandle1}  sapi      Received     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle1}  dapi      Received     tx-dapi-val

    set ODU PM TTI Traces  ${testSetHandle1}  OPERATOR  ${null}  tx-operator-val
    set ODU PM TTI Traces  ${testSetHandle1}  sapi  Expected  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle1}  dapi  Expected  tx-dapi-val
    set ODU PM TTI Traces  ${testSetHandle1}  sapi  Received  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle1}  dapi  Received  tx-dapi-val
	
	

    set OTU SM TTI Traces  ${testSetHandle2}  OPERATOR  ${null}      tx-operator-val
    set OTU SM TTI Traces  ${testSetHandle2}  sapi      Expected     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle2}  dapi      Expected     tx-dapi-val
    set OTU SM TTI Traces  ${testSetHandle2}  sapi      Received     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle2}  dapi      Received     tx-dapi-val  

    set ODU PM TTI Traces  ${testSetHandle2}  OPERATOR  ${null}  tx-operator-val
    set ODU PM TTI Traces  ${testSetHandle2}  sapi  Expected  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle2}  dapi  Expected  tx-dapi-val
    set ODU PM TTI Traces  ${testSetHandle2}  sapi  Received  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle2}  dapi  Received  tx-dapi-val
	
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}

	${ncHandle}=  Get Netconf Client Handle  ${tv['device0__re0__mgt-ip']}
	Set Suite Variable    ${ncHandle}
	${ncHandle remote}=  Get Netconf Client Handle  ${tv['device1__re0__mgt-ip']}
	Set Suite Variable    ${ncHandle remote}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}

    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK

    #Verify Client Interfaces In Traffic Chain Are Up
	

    
Test Bed Teardown
    [Documentation]  Test Bed Teardown
	
    Log To Console  Remove Service
    Remove OTU4 Service   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Remove OTU4 Service   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}
    
    Log To Console  Stopping Traffic  
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}
    
    
Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}
    
Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


    
Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${OPER_STATUS_ON}

	
Recover OTU TTI on Attella
    [Documentation]   Retrieve system configuration and state information
    [Arguments]       ${InterfaceName}     
    &{intf}           create dictionary   interface-name=${InterfaceName}   otu-tim-detect-mode=SAPI-and-DAPI  otu-expected-sapi=tx-sapi-val     otu-expected-dapi=tx-dapi-val   otu-tx-sapi=tx-sapi-val      otu-tx-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}

	
Recover ODU TTI on Attella
    [Documentation]   Retrieve system configuration and state information
    [Arguments]       ${InterfaceName}     
    &{intf}           create dictionary   interface-name=${InterfaceName}   odu-tim-detect-mode=SAPI-and-DAPI   odu-expected-sapi=tx-sapi-val     odu-expected-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}  ${payload}
	

Enable interface 
    [Arguments]       ${interface_name}     
    &{intf}          create dictionary   interface-name=${interface_name}  interface-administrative-state=inService
    @{interface_info}    create list     ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}	
	
	
	
