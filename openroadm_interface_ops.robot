*** Settings ***
Documentation    This is Attella otu4 client interface alarm Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38965: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author: Jack Wu
...              Date   : 12/26/2018
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/555965
...              jtms description           : Attella
...              RLI                        : 39315
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
Library	         robot.libraries.DateTime
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
${ATTELLA_DEF_OTU4_CLIENT_NAME}    jmc-otu4-client-port
${ATTELLA_DEF_ODU4_CLIENT_NAME}    jmc-odu4-client-port
${ATTELLA_DEF_LINE_OCH_NAME}    jmc-och-line-port
${ATTELLA_DEF_LINE_OTU_NAME}    jmc-otu-line-port
${ATTELLA_DEF_LINE_ODU_NAME}    jmc-odu-line-port

@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      2 min 
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
${OPER_STATUS_DEGRADED}     degraded
@{pmInterval}   15min    24Hour   notApplicable
${interval}                 10
${timeout}                  100
&{delete_headers}           Accept=application/xml
${CFG_SESSEION_INDEX}       1



*** Test Cases ***    

TC0
    [Documentation]  Verify Traffic with user defined interface name
    ...              RLI39315    5.1-7, 5.1-9, 5.1-11, 5.2-5
    [Tags]           Advance  tc0

    @{ifnames}     Create List    ${ATTELLA_DEF_LINE_OCH_NAME}    ${ATTELLA_DEF_LINE_OTU_NAME}    ${ATTELLA_DEF_LINE_ODU_NAME}    ${ATTELLA_DEF_OTU4_CLIENT_NAME}    ${ATTELLA_DEF_ODU4_CLIENT_NAME}            
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}    ${ifnames}
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}    ${ifnames}

    ${t}    get time 
    Log To Console    Created service ${t}
    
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK

TC1
    [Documentation]  Test LOS alarm raise/clear on OTU4 client port
    ...              RLI39315  5.2-7
    [Tags]          Advance   tc1
   
    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 20)  modules=random
	Sleep  ${random}
   
    Log To Console   Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
	
    ${t}    get time 
    Log To Console    Finished checking no alarms / Starting Test ${t}

	Log              Turn tester Laser off
	Set Laser State  ${testSetHandle1}  OFF
	
    ${t}    get time 
    Log To Console    Waiting until LOS alarm raised ${t}
	Log              Verify los alarm raise on local otu4 interface
	@{expectedAlarms}  Create List  Loss of Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
    ${t}    get time 
    Log To Console    Verify Alarm raised ${t}
	${random}=  Evaluate  random.randint(1, 20)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Loss of Signal
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${expectedAlarms}
   
    ${t}    get time 
    Log To Console    Verify Operational Status on local ${t}
    Log             Verify the local otu4/odu4 interface operation status are outOfService, and odu4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${OPER_STATUS_OFF}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${OPER_STATUS_OFF}
   
	Log             Turn tester Laser on
	Set Laser State  ${testSetHandle1}  ON	

    ${t}    get time 
    Log To Console    Wait for alarms to clear ${t}
	Log             Verify los alarm clear on local otu4 interface
	Wait Until Interfaces In Traffic Chain Are Alarm Free

	Verify Interfaces In Traffic Chain Are Alarm Free	
	
    [Teardown]  Set Laser State  ${testSetHandle1}  ON
   

TC2
    [Documentation]  Verify current 15min Near-end  OTU all PM statistics on otu4 Client interface
    ...              RLI39315   5.2-8
    [Tags]            Advance  tc2
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    10
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${ATTELLA_DEF_OTU4_CLIENT_NAME}    ${pmEntryParmaterlist}     @{pmInterval}[0]
    @{expectValue}       Create List   1   10   10   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8
	

TC3
    [Documentation]  Test AIS alarm raised/clear on ODU4 client port   
    ...              RLI39315    5.2-10
    [Tags]           Advance  tc3

    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting ODU4 AIS alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}   ALARM_OTU4_ODU4_AIS
   
    Log              Verify AIS alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 20)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  ODU Alarm Indication Signal
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are inService,and OTU4 interface is alarm free
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${OPER_STATUS_ON}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${OPER_STATUS_ON}

    Log             Stop injecting ODU4 AIS alarm from tester, verify the ODU-AIS alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 20)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
	
    [Teardown]  Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS

TC4
    [Documentation]  Verify current 15min near-end  ODU all PM statistics on odu4 Client interface
    ...              RLI39315    5.2-11
    [Tags]            Advance  tc4
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd   rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd   rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']} 
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8   30
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${ATTELLA_DEF_ODU4_CLIENT_NAME}    ${pmEntryParmaterlist}     @{pmInterval}[0]
    @{expectValue}       Create List   1   30   30   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BIP8  


TC5
    [Documentation]  Disable near-end OCH interface
    ...              RLI39315    5.2-12
    [Tags]           Advance  tc5
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Disable OCH interface Lx
    &{intf}          create dictionary   interface-name=${ATTELLA_DEF_LINE_OCH_NAME}  interface-administrative-state=outOfService
    @{interface_info}    create list     ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_LINE_ODU_NAME}  ODU Alarm Indication Signal
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}

    Log               Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log               Verify ODU-AIS was raised on Ly
    @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_ODU_NAME}  ${expectedAlarms_remote_line}
    
    Log               Verify ODU4-AIS was raised on Test2
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}
    
    Log              Verify OCH/OTU4/ODU4 operation status on Lx are outOfService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OCH_NAME}        ${OPER_STATUS_OFF}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OTU_NAME}        ${OPER_STATUS_OFF}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_ODU_NAME}        ${OPER_STATUS_OFF}
    
    Log              Enable OCH interface on local line port
    &{intf}          create dictionary   interface-name=${ATTELLA_DEF_LINE_OCH_NAME}  interface-administrative-state=inService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_LINE_ODU_NAME}  ODU Alarm Indication Signal  clear
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free 

    [Teardown]  	Enable interface   ${ATTELLA_DEF_LINE_OCH_NAME}
	
TC6
    [Documentation]  Retrieve opticalPowerOutput pm statistics on Local line port
    ...              RLI39315   5.2-13
    [Tags]           Advance  tc6
    @{pmEntryParmater}        Create List       opticalPowerOutput        nearEnd      tx  
    @{pmEntryParmaterlist}    Create List       ${pmEntryParmater}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    
    ${och_tx_power}   evaluate    random.randint(-12,2)      random,string		
    ${och_tx_power}   evaluate    str(${och_tx_power})	
    Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${ATTELLA_DEF_LINE_OCH_NAME}    ${och_tx_power}
    Sleep    30
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[2]
    Log           ${realpm} 
    @{expectValue}       Create List   ${och_tx_power}+2    ${och_tx_power}-2
    log           ${expectValue}	
    Verify Pm Should Be In Range    ${expectValue}     @{realpm}[0]	 
    [Teardown]  	Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${ATTELLA_DEF_LINE_OCH_NAME} 
	
TC7
    [Documentation]  <tim-detect-mode>Enabled and <tim-act-enabled>true : Near-end line OTU4 send wrong SAPI
    ...              RLI39315    5.2-14
    [Tags]          Advance  tc7
    Log    Modify the tx-sapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console   Modify tx-sapi on local line
    Log              Modify the tx-sapi value for OTU4 on local line port
    &{intf}            create dictionary   interface-name=${ATTELLA_DEF_LINE_OTU_NAME}    otu-tx-sapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}

    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_LINE_OTU_NAME}  Trail Trace Identifier Mismatch
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
    
    Log To Console   verify TTIM on remote line
    Log              Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OTU_NAME}  ${expectedAlarms_remote_line}

    Log To Console   verify BDI on local line
    Log              Verify OTU4-BDE=I was raised on local line port
    @{expectedAlarms_local_line}      Create List       Backward Defect Indication  
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OTU_NAME}         ${expectedAlarms_local_line}    

    Log              Verify ODU4-AIS was raised on remote Test Set.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log To Console   verify op status  on local line
    Log              Verify OCH/OTU4/ODU4 operation status on Lx are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OCH_NAME}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_ODU_NAME}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OTU_NAME}        ${OPER_STATUS_ON}  

    Log To Console   reset tx-sapi on local line
    Log              Enable OTU4 tx-sapi back to "tx-sapi-val" on local line port
    &{intf}          create dictionary   interface-name=${ATTELLA_DEF_LINE_OTU_NAME}  otu-tx-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log To Console   clear alarm
    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_LINE_OTU_NAME}  Trail Trace Identifier Mismatch  clear
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log To Console   wait for alarm to clear
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
	
    [Teardown]  	  Recover OTU TTI on Attella    ${ATTELLA_DEF_LINE_OTU_NAME} 
   
TC8  
    [Documentation]  Retrieve current 15min Near-end  ES/SES pm statistics on Remote line port  
    ...              RLI39315   5.2-15  
    [Tags]          Advance  tc8
    Log              Modify the tx-sapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm
    @{pmEntryParmater1}         Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}         Create List      erroredSeconds             nearEnd    rx
    @{pmEntryParmaterlist}      Create List      ${pmEntryParmater1}         ${pmEntryParmater2}   
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']} 
    Retrieve Current Statistics 	

    Log                 Modify the tx-sapi value for OTU4 on local line port
    &{intf}             create dictionary   interface-name=${ATTELLA_DEF_LINE_OTU_NAME}    otu-tx-sapi=012345
    @{interface_info}   create list  ${intf}    
    &{dev_info}         create_dictionary   interface=${interface_info}       
    &{payload}          create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}

    Log                 Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Log                 Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    ${ATTELLA_DEF_LINE_OTU_NAME}  ${expectedAlarms_remote_line}

    Sleep   10
    @{realpm}=        Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${ATTELLA_DEF_LINE_OTU_NAME}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${ATTELLA_DEF_LINE_OTU_NAME}   ${pmEntryParmaterlist}     @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    [Teardown]  	  Recover OTU TTI on Attella    ${ATTELLA_DEF_LINE_OTU_NAME}  

TC9
    [Documentation]  Disable near-end Line ODU4 interface
    ...              RLI39315   5.2-17
    Log              Disable local ODU4 on Lx, remote Line will raise ODU-AIS and Remote Test will raise ODU4-AIS
    [Tags]          Advance  tc9
    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log              Disable OCH interface on local line port
    &{intf}=         create dictionary   interface-name=${ATTELLA_DEF_LINE_ODU_NAME}  interface-administrative-state=outOfService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}

    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_LINE_ODU_NAME}  ODU Alarm Indication Signal
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 30)  modules=random
    Sleep  ${random}
   
    Log              Verify ODU-AIS was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       ODU Alarm Indication Signal    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_ODU_NAME}  ${expectedAlarms_remote_line}

    Log              Verify ODU4-AIS was raised on remote Test Set.
    ${expectedAlarms_remote_Test_Set}      Set variable      ALARM_OTU4_ODU4_AIS
    Is Alarm Raised  ${testSetHandle2}     ${expectedAlarms_remote_Test_Set}

    Log              Verify OTU4/ODU4 operation status on Lx are outOfService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_ODU_NAME}        ${OPER_STATUS_OFF}

    Log              Verify OCH/OTU4 operation status on Lx is inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OCH_NAME}        ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_LINE_OTU_NAME}        ${OPER_STATUS_ON}  

    Log              Enable OTU4 interface on local line port
    &{intf}=         create dictionary   interface-name=${ATTELLA_DEF_LINE_ODU_NAME}  interface-administrative-state=inService
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}  
	
    @{alarmNotification}=  Create List  alarm-notification  ${ATTELLA_DEF_LINE_ODU_NAME}  ODU Alarm Indication Signal  clear
    @{alarmNotifications}=  Create List  ${alarmNotification}
    Notifications Should Raised  ${ncHandle remote}  ${alarmNotifications}
   
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  

    [Teardown]  	Enable interface   ${ATTELLA_DEF_LINE_ODU_NAME}

TC10
    [Documentation]  Verify current 15min Far-end  ODU erroredBlockCount PM statistics on remote odu4 Line interface
    ...              RLI39315   5.2-18  
    [Tags]          Advance   tc10
    @{pmEntryParmater}          Create List     erroredBlockCount         farEnd    rx 
    @{pmEntryParmater2}         Create List     backgroundBlockErrors     farEnd    rx
    @{pmEntryParmater3}         Create List     erroredSeconds            farEnd    rx
    @{pmEntryParmater4}         Create List     severelyErroredSeconds    farEnd    rx
    @{pmEntryParmaterlist}      Create List     ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    40
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${ATTELLA_DEF_LINE_ODU_NAME}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    @{expectValue}       Create List   40  40   1   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    #Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI


TC11
    [Documentation]     De-provision interfaces with used defined names
    ...                 RLI39315  5.1-4, 6, 8, 10, 12
    [Tags]              Advance  tc11
    @{ifnames}     Create List    ${ATTELLA_DEF_LINE_OCH_NAME}    ${ATTELLA_DEF_LINE_OTU_NAME}    ${ATTELLA_DEF_LINE_ODU_NAME}    ${ATTELLA_DEF_OTU4_CLIENT_NAME}    ${ATTELLA_DEF_ODU4_CLIENT_NAME}            
    
    Remove OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}    ${ifnames}
    Remove OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}    ${ifnames}


*** Keywords ***
Test Bed Init
    Set Log Level  DEBUG
    Log To Console      create a restconf operational session
    ${t}    get time 
    Log To Console    Starting Init ${t}
    
    @{dut_list}    create list    device0  device1
    Preconfiguration netconf feature    @{dut_list}
    ${t}    get time 
    Log To Console    Prep Netconf Done ${t}

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
	
    ${t}    get time 
    Log To Console    Session Setup Done ${t}

    ${client intf}       Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    ${client otu intf}   Get OTU Intface Name From ODU Intface  ${client intf}
    ${line odu intf}     Get Line ODU Intface Name From Client Intface  ${client intf}
    ${line otu intf}     Get OTU Intface Name From ODU Intface  ${line odu intf}
    ${line och intf}     Get OCH Intface Name From OTU Intface  ${line otu intf}
    ${line port}          evaluate        str('${line och intf}')[0:-2].replace('och','port')	
    Set Suite Variable    ${client intf}
    Set Suite Variable    ${client otu intf}
    Set Suite Variable    ${line odu intf}
    Set Suite Variable    ${line otu intf}
    Set Suite Variable    ${line och intf}
    Set Suite Variable    ${line port}
    
    ${remote client intf}      Get Otu4 Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    ${remote client otu intf}  Get OTU Intface Name From ODU Intface  ${remote client intf}
    ${remote line odu intf}    Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote line otu intf}    Get OTU Intface Name From ODU Intface  ${remote line odu intf}
    ${remote line och intf}    Get OCH Intface Name From OTU Intface  ${remote line otu intf}
    ${remote line port}          evaluate        str('${remote line och intf}')[0:-2].replace('och','port')	
    Set Suite Variable    ${remote client intf}
    Set Suite Variable    ${remote client otu intf}
    Set Suite Variable    ${remote line odu intf}
    Set Suite Variable    ${remote line otu intf}
    Set Suite Variable    ${remote line och intf}
    Set Suite Variable    ${remote line port}
    
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}

    ${t}    get time 
    Log To Console    Device Setup Done ${t}

	#Log To Console  de-provision on both device0 and device1
    #Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	#Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
    
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}

    ${t}    get time 
    Log To Console    Device default load Done ${t}

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
	    
    ${t}    get time 
    Log To Console    Init testset Done ${t}

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

    ${t}    get time 
    Log To Console    Creating service ${t}

    ${t}    get time 
    Log To Console    Finished Setup ${t}


Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Stop Traffic
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}

    Log To Console  Clean up Interfaces
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}

    
Retrieve Current Statistics
    [Documentation]   Retrieve Detail history pm data 
    ${r0} =     Get Handle      resource=device0 
    &{payload}   create_dictionary   current-pm-list=${null}
    ${sDatestring}=    Execute shell command on device     device=${r0}       command=date
    log to console    ${sDatestring}
    Wait For  5
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8  
    log   ${resp_content}
    

Enable interface 
    [Arguments]       ${interface_name}     
    &{intf}          create dictionary   interface-name=${interface_name}  interface-administrative-state=inService
    @{interface_info}    create list     ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}	


Modify transmit-power for OCH interface
    [Documentation]   Modify transmit-power for OCH interface
    ...                    Args:
    ...                    |- odl_sessions : ODL server
    ...                    |- node : device0 or device1
    ...                    |- strOchIntf  : OCH interface	
	[Arguments]            ${odl_sessions}  ${node}   ${ATTELLA_DEF_LINE_OCH_NAME}   ${och_tx_power}=0
    Log                    Modify och interface tx_power
    &{strOchIntf}          create dictionary   interface-name=${ATTELLA_DEF_LINE_OCH_NAME}   transmit-power=${och_tx_power}
    @{interface_info}      create list     ${strOchIntf}    
    &{dev_info}            create_dictionary   interface=${interface_info}       
    &{payload}             create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Request And Verify Status Of Response Is OK    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	Wait For  10

Verify Traffic Is OK
    ${t}    get time 
    Log To Console    Stoping Traffic ${t}

    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    ${t}    get time 
    Log To Console    Clearing Stats ${t}

    Clear Statistic And Alarm  ${testSetHandle1}  
    Clear Statistic And Alarm  ${testSetHandle2}
    
    ${t}    get time 
    Log To Console    Starting Traffic ${t}

    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  10
   
    ${t}    get time 
    Log To Console    Stoping Traffic ${t}

    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    ${t}    get time 
    Log To Console    Checking Traffic on test sets ${t}

    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
   
    ${t}    get time 
    Log To Console    Checking Traffic Done ${t}

    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
    
    [Teardown]  Run Keywords  Start Traffic  ${testSetHandle1}  AND  Start Traffic  ${testSetHandle2}

    
    
Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}         ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}         ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}
    
Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


    
Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}         ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}         ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_ODU4_CLIENT_NAME}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${ATTELLA_DEF_OTU4_CLIENT_NAME}  ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${OPER_STATUS_ON}

	
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
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}	
	
