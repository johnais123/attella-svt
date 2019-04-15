*** Settings ***
Documentation    This is Attella otu4 client interface alarm Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38965: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author: Jack Wu
...              Date   : 12/26/2018
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
...              jtms description           : Attella
...              RLI                        : 38965
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

Resource         jnpr/toby/Master.robot

Library          BuiltIn
Library          String
Library          Collections
Library          OperatingSystem
Library          String
Library          ExtendedRequestsLibrary
Library          XML    use_lxml=True
                 
Resource         ../lib/restconf_oper.robot
Resource         ../lib/testSet.robot
Resource         ../lib/attella_keyword.robot



Suite Setup      Run Keywords
...              Toby Suite Setup
...              Test Bed Init



Suite Teardown   Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      5 min 
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
${OPER_STATUS_DEGRADED}     degraded
${interval}                 10
${timeout}                  300
&{delete_headers}           Accept=application/xml
${CFG_SESSEION_INDEX}       1



*** Test Cases ***    
 
TC1
   [Documentation]  Test LOS alarm raise/clear on OTU4 client port     
   [Tags]           Sanity  tc1
   
   Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(60, 120)  modules=random
	Sleep  ${random}
   
   Log To Console   Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
	
	Log              Turn tester Laser off
	Set Laser State  ${testSetHandle1}  OFF
	
	Log              Verify los alarm raise on local otu4 interface
	@{expectedAlarms}  Create List  Loss of Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

   Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Loss of Signal
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
   
   Log             Verify the local otu4/odu4 interface operation status are outOfService, and odu4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_OFF}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}

   Log             Verify the remote otu4/odu4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
  
   
	Log             Turn tester Laser on
	Set Laser State  ${testSetHandle1}  ON	

	Log             Verify los alarm clear on local otu4 interface
	Wait Until Interfaces In Traffic Chain Are Alarm Free	

	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free	
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]  Set Laser State  ${testSetHandle1}  ON
   
TC2
   [Documentation]  Test LOF alarm raised/clear on OTU4 client port     
   [Tags]           tc2


   Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free	
   
   Log             Injecting otu4 LOF alarm from tester
   Start Inject Alarm On Test Equipment   ${testSetHandle1}  ALARM_OTU4_OTU4_LOF
   
   Log              Verify lossOfFrame alarm raise on local otu4 interface    
	@{expectedAlarms}  Create List   Loss of Frame
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}


   Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Loss of Frame
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
   
   Log             Verify the local otu4/odu4 interface operation status are outOfService, and odu4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_OFF}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}

   Log             Verify the remote otu4/odu4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

   Log             Stop injecting OTU4 LOF alarm from tester, verify the lossOfFrame alarm is clear
   Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_LOF
   Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free

   Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
   Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]   Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_LOF


TC3
   [Documentation]  Test LOM alarm raised/clear on OTU4 client port     
   [Tags]           tc3


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting OTU4 LOM alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}  ALARM_OTU4_OTU4_LOM

    Log              Verify LOM alarm raise on local OTU4 interface    
	@{expectedAlarms}  Create List   Loss of Multiframe
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	
    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Loss of Multiframe
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are outOfService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_OFF}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting OTU4 LOM alarm from tester, verify the LOM alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_LOM
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free

	
    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]  Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_LOM



TC4
   [Documentation]  Test BDI alarm raised/clear on OTU4 client port     
   [Tags]          tc4


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting OTU4 BDI alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}  ALARM_OTU4_OTU4_BDI
   
    Log              Verify BDI alarm raise on local OTU4 interface    
	@{expectedAlarms}  Create List   Backward Defect Indication
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Backward Defect Indication
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting OTU4 BDI alarm from tester, verify the BDI alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_BDI
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free


    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]  Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_BDI	
   




TC5
   [Documentation]  Test IAE alarm raised/clear on OTU4 client port     
   [Tags]           tc5


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting OTU4 IAE alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}  ALARM_OTU4_OTU4_IAE
   
    Log              Verify IAE alarm raise on local OTU4 interface    
	@{expectedAlarms}  Create List   Incoming Alignment Error
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}


    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Incoming Alignment Error
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are outOfService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting OTU4 IAE alarm from tester, verify the IAE alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_IAE
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]   Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_OTU4_IAE



TC6
    [Documentation]  Test BIAE alarm raised/clear on OTU4 client port     
    [Tags]           tc6


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting OTU4 BIAE alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}  ALARM_OTU4_OTU4_BIAE
   
    Log              Verify BIAE alarm raise on local OTU4 interface    
	@{expectedAlarms}  Create List   Backward Incoming Alignment Error
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Backward Incoming Alignment Error
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote otu4/odu4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting otu4 IAE alarm from tester, verify the IAE alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_OTU4_BIAE
    Log To Console  Verify Alarms
	 Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log            Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
    [Teardown]    Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_OTU4_BIAE


TC7
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-sapi value
    ...              tim-detect-mode is SAPI-and-DAPI, and tim-act-enabled is true 
    
    [Tags]           Sanity  tc7           
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}      otu-expected-sapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    
    Log              Verify AIS alarm raise on local ODU4 line interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}    
    
    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}  otu-expected-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	

   
TC8
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is SAPI-and-DAPI, and tim-act-enabled is true 
    
    [Tags]           tc8           
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}      otu-expected-dapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    @{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Verify AIS alarm raise on local ODU4 line interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}  


    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}  otu-expected-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
  
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK    
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	
  
  
TC9
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is SAPI-and-DAPI, and tim-act-enabled is true 
    
    [Tags]           tc9           
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free 
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}    otu-expected-dapi=012345    otu-expected-sapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Verify AIS alarm raise on local ODU4 line interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}  


    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}   otu-expected-dapi=tx-dapi-val    otu-expected-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  

    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	




TC10
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is SAPI, and tim-act-enabled is true 
    
    [Tags]           tc10          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}    otu-expected-sapi=012345    odu-tim-detect-mode=SAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Verify AIS alarm raise on local ODU4 line interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}  

    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}   otu-expected-sapi=tx-sapi-val    odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	
   
   
TC11
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is DAPI, and tim-act-enabled is true 
    
    [Tags]           tc11          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free    Wait Interfaces In Traffic Chain Are Alarm Free   
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}    otu-expected-dapi=012345    otu-tim-detect-mode=DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Verify AIS alarm raise on local ODU4 line interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}  

    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}   otu-expected-dapi=tx-dapi-val   odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK     
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	




TC12
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-sapi value
    ...              tim-detect-mode is SAPI-and-DAPI, and tim-act-enabled is false 
    
    [Tags]           Sanity  tc12          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}      otu-expected-sapi=012345    tim-act-enabled=false
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    
    Log              Verify AIS alarm raise on local ODU4 line interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}    
    
    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}  otu-expected-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	

   
TC13
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is SAPI-and-DAPI, and tim-act-enabled is false 
    
    [Tags]           tc13          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free   
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}      otu-expected-dapi=012345    tim-act-enabled=false
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    @{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}  otu-expected-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
  
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK    
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	
  
  
TC14
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is SAPI-and-DAPI, and tim-act-enabled is false 
    
    [Tags]           tc14          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free   
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}    otu-expected-dapi=012345    otu-expected-sapi=012345   tim-act-enabled=false
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}


    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}   otu-expected-dapi=tx-dapi-val    otu-expected-sapi=tx-sapi-val    
    
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  

    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	



TC15
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is SAPI, and tim-act-enabled is false 
    
    [Tags]           tc15          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free   
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}    otu-expected-sapi=012345    odu-tim-detect-mode=SAPI   tim-act-enabled=false
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Verify AIS alarm raise on local ODU4 line interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}  

    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}   otu-expected-sapi=tx-sapi-val    odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	
   
   
TC16
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is DAPI, and tim-act-enabled is false 
    
    [Tags]           tc16          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}    otu-expected-dapi=012345    otu-tim-detect-mode=DAPI    tim-act-enabled=false
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and ODU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}


    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client otu intf}   otu-expected-dapi=tx-dapi-val   odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK     
    
    [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 	



TC17
    [Documentation]  Test SD alarm raised/clear on OTU4 client port     
    [Tags]           tc17


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    Log             Injecting OTU4 SD alarm from tester
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8  MAX
    
    Log              Verify SD alarm raise on local otu4 interface    
	@{expectedAlarms}  Create List     Degraded defect
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Degraded defect
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
    
    Log             Verify the local OTU4/ODU4 interface operation status are outOfService, and odu4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_DEGRADED}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting SD alarm from tester, verify SD alarm is clear
    Stop Inject error On Test Equipment    ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
    
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK

    [Teardown]  Stop Inject error On Test Equipment    ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8


TC18
    [Documentation]  Test AIS alarm raised/clear on ODU4 client port     
    [Tags]           Sanity  tc18


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting ODU4 AIS alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}   ALARM_OTU4_ODU4_AIS
   
    Log              Verify AIS alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List   ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}


    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  ODU Alarm Indication Signal
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are inService,and OTU4 interface is alarm free
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}


    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting ODU4 AIS alarm from tester, verify the ODU-AIS alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free


    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
    [Teardown]  Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS



TC19
   [Documentation]  Test OCI alarm raised/clear on ODU4 client port     
   [Tags]           tc19


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting ODU4 OCI alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}   ALARM_OTU4_ODU4_OCI
   
    Log              Verify OCI alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List   ODU Open Connection Indication
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  ODU Open Connection Indication
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are inService, and OTU4 interface is alarm free
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}


    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting ODU4 OCI alarm from tester, verify the OCI alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_ODU4_OCI
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free


    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]  Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_ODU4_OCI	


TC20
    [Documentation]  Test LCK alarm raised/clear on ODU4 client port     
    [Tags]           tc20


    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting ODU4 LCK alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}   ALARM_OTU4_ODU4_LCK
   
    Log              Verify LCK alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List   ODU Locked
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}


    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  ODU Locked
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are inService, and otu4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting ODU4 OCI alarm from tester, verify the OCI alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_ODU4_LCK
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free


    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]  Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_ODU4_LCK
 
TC21
   [Documentation]  Test BDI alarm raised/clear on ODU4 client port     
   [Tags]           Sanity  tc16


   Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting ODU4 LCK alarm from tester
    Start Inject Alarm On Test Equipment   ${testSetHandle1}   ALARM_OTU4_ODU4_BDI
   
    Log              Verify LCK alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List   Backward Defect Indication
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}


    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Backward Defect Indication
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are inService, and otu4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting ODU4 OCI alarm from tester, verify the OCI alarm is clear
    Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_ODU4_BDI
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free


    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK
	
   [Teardown]  Stop Inject Alarm On Test Equipment    ${testSetHandle1}   ALARM_OTU4_ODU4_BDI    
	          

TC22
    [Documentation]  Test TTIM alarm raised/clear on ODU4 interface,with the wrong expected-sapi value
    ...              tim-detect-mode is SAPI, and tim-act-enabled is true 
    
    [Tags]           tc22          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  

    Log              Modify the expected-sapi value for ODU4 on local client interface
    &{intf}            create dictionary   interface-name=${client intf}      odu-expected-sapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local ODU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and OTU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Modify ODU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client intf}  odu-expected-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  
    
    [Teardown]    Recover ODU TTI on Attella   ${client intf}
    
TC23
   [Documentation]  Test TTIM alarm raised/clear on ODU4 interface,with the wrong expected-dapi value
   ...              tim-detect-mode is DAPI, and tim-act-enabled is true 
   
   [Tags]           tc23          
   
   Log              Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free  

   Log              Modify the expected-sapi value for ODU4 on local client interface
   &{intf}            create dictionary   interface-name=${client intf}      odu-expected-dapi=012345
   @{interface_info}    create list  ${intf}    
   &{dev_info}      create_dictionary   interface=${interface_info}       
   &{payload}       create_dictionary   org-openroadm-device=${dev_info}
   Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
   
   Log              Verify TTIM was raised on local ODU4 client interface
   @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and OTU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

   Log              Modify ODU4 expected-sapi back to "expected-sapi" on local client port
   &{intf}          create dictionary   interface-name=${client intf}  odu-expected-dapi=tx-dapi-val
   @{interface_info}    create list  ${intf}    
   &{dev_info}      create_dictionary   interface=${interface_info}       
   &{payload}       create_dictionary   org-openroadm-device=${dev_info}
   Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
   
   Log              Verify Alarms In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   ${random}=  Evaluate  random.randint(1, 60)  modules=random
   Sleep  ${random}
   Verify Interfaces In Traffic Chain Are Alarm Free
   
   Verify Client Interfaces In Traffic Chain Are Up
   
   Log To Console   Verify Traffic Is OK
   Verify Traffic Is OK    
   
   [Teardown]    Recover ODU TTI on Attella   ${client intf}   
   
TC24
   [Documentation]  Test TTIM alarm raised/clear on ODU4 interface,with the wrong expected-dapi value
   ...              tim-detect-mode is SAPI-and-DAPI, and tim-act-enabled is true 
   
   [Tags]           tc24         
   
   Log              Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free   

   Log              Modify the expected-sapi value for ODU4 on local client interface
   &{intf}            create dictionary   interface-name=${client intf}    odu-expected-dapi=012345    odu-expected-sapi=012345
   @{interface_info}    create list  ${intf}    
   &{dev_info}      create_dictionary   interface=${interface_info}       
   &{payload}       create_dictionary   org-openroadm-device=${dev_info}
   Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
   
   Log              Verify TTIM was raised on local ODU4 client interface
   @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and OTU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Modify ODU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client intf}   odu-expected-dapi=tx-dapi-val    odu-expected-sapi=tx-sapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  
    
    [Teardown]    Recover ODU TTI on Attella   ${client intf}
    

TC25
   [Documentation]  Test TTIM alarm raised/clear on ODU4 interface,with the wrong expected-dapi value
   ...              tim-detect-mode is SAPI and DAPI, and tim-act-enabled is true
   
   [Tags]           tc25         
   
   Log              Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free   

   Log              Modify the expected-sapi value for ODU4 on local client interface
   &{intf}            create dictionary   interface-name=${client intf}    odu-expected-sapi=012345    odu-tim-detect-mode=SAPI
   @{interface_info}    create list  ${intf}    
   &{dev_info}      create_dictionary   interface=${interface_info}       
   &{payload}       create_dictionary   org-openroadm-device=${dev_info}
   Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
   
   Log              Verify TTIM was raised on local ODU4 client interface
   @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
   Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and OTU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log              Modify ODU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client intf}   odu-expected-sapi=tx-sapi-val    odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK  
    
    [Teardown]    Recover ODU TTI on Attella   ${client intf}
   
   
TC26
    [Documentation]  Test TTIM alarm raised/clear on OTU4 interface,with the wrong expected-dapi value
    ...              tim-detect-mode is DAPI, and tim-act-enabled is true 
    
    [Tags]           tc26          
    
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  

    Log              Modify the expected-sapi value for ODU4 on local client interface
    &{intf}            create dictionary   interface-name=${client intf}    odu-expected-dapi=012345    odu-tim-detect-mode=DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local ODU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}    


    Log             Verify the local OTU4/ODU4 interface operation status are inService, and OTU4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    
    Log              Modify ODU4 expected-sapi back to "expected-sapi" on local client port
    &{intf}          create dictionary   interface-name=${client intf}   odu-expected-dapi=tx-dapi-val   odu-tim-detect-mode=SAPI-and-DAPI
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
    
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    Verify Interfaces In Traffic Chain Are Alarm Free
    
    Verify Client Interfaces In Traffic Chain Are Up
    
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK            
    
    [Teardown]    Recover ODU TTI on Attella   ${client intf}


TC27
   [Documentation]  Test SD alarm raised/clear on ODU4 client port     
   [Tags]           tc27


   Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   Log             Injecting ODU4 SD error from tester
   Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8  MAX
   
    Log              Verify SD alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List     Degraded defect
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
   Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Degraded defect
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}
   
    Log             Verify the local OTU4/ODU4 interface operation status are outOfService, and odu4 interface is alarm free
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

    Log             Stop injecting SD error from tester, verify the SD alarm is clear
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK    

   [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8


TC28
    [Documentation]  After Attella system warm reload,the LOS alarm on OTU4 interface still can be raised.
    [Tags]           tc28 

  
    Log To Console   Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log               Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(60, 120)  modules=random
	Sleep  ${random}
   
    Log To Console    Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Interfaces In Traffic Chain Are Alarm Free
	
	Log              Turn tester Laser off
	Set Laser State  ${testSetHandle1}  OFF
	
	Log              Verify los alarm raise on local otu4 interface
	@{expectedAlarms}  Create List  Loss of Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	
    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Loss of Signal
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}   
  
    Log               Warm reload the remote Attella NE   
    Rpc Command For warm Reload device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0 
   
    Log              Verify LOS Alarm was raised  
    @{expectedAlarms}  Create List  Loss of Signal
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}   
       
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(30,90)  modules=random
    Sleep  ${random}       
       
    Log              Verify OTU4/ODU4 operation status on local are outOfService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}            ${OPER_STATUS_OFF}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}        ${OPER_STATUS_OFF}
   

    Log              Verify OTU4/ODU4 operation status on remote are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}       ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}   ${OPER_STATUS_ON}
      
    Log              Turn Laser on
    Set Laser State  ${testSetHandle1}  ON
   
    Log              Verify Alarms In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log              Wati a random time the check wether the alarm still exist or not
    ${random}=       Evaluate  random.randint(1, 60)  modules=random
    Sleep            ${random}
   
    Log              Verify interface alarm are error free
    Verify Interfaces In Traffic Chain Are Alarm Free
      
    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK
   
    [Teardown]  Set Laser State  ${testSetHandle1}  ON    


   
TC29
    [Documentation]  After Attella system cold reload,the OTU4 TTIM alarm still can be raised.
    [Tags]           tc29 
  
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free  
    
    Log              Modify the expected-sapi value for OTU4 on local client interface
    &{intf}            create dictionary   interface-name=${client otu intf}      otu-expected-sapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}      
  
    Log               Cold reload the remote Attella NE   
    Rpc Command For Cold Reload device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0 
    
    Log               Verify TTIM was raised on local OTU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
        
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(30,90)  modules=random
    Sleep  ${random}       
    
    Log             Verify the local OTU4/ODU4 interface operation status are inService
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON} 

    Log              Modify OTU4 expected-sapi back to "expected-sapi" on local client port
   &{intf}          create dictionary   interface-name=${client otu intf}  otu-expected-sapi=tx-sapi-val
   @{interface_info}    create list  ${intf}    
   &{dev_info}      create_dictionary   interface=${interface_info}       
   &{payload}       create_dictionary   org-openroadm-device=${dev_info}
   Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
   
   Log              Verify Alarms In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   ${random}=  Evaluate  random.randint(1, 60)  modules=random
   Sleep  ${random}
   Verify Interfaces In Traffic Chain Are Alarm Free
   
   Verify Client Interfaces In Traffic Chain Are Up
   
   Log To Console   Verify Traffic Is OK
   Verify Traffic Is OK  
   
   [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 





TC30
    [Documentation]  After Attella system warm reload,the ODU4 TTIM alarm still can be raised.
    [Tags]           tc30 
  
    Log              Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free 
    
    Log              Modify the expected-sapi value for ODU4 on local client interface
    &{intf}            create dictionary   interface-name=${client intf}      odu-expected-sapi=012345
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Log              Verify TTIM was raised on local ODU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}

    Log              Wait a random time to keep the alarm stable on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List   Trail Trace Identifier Mismatch
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}      
  
    Log               Warm reload the remote Attella NE   
    Rpc Command For warm Reload device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0 
    
    Log               Verify TTIM was raised on local ODU4 client interface
    @{expectedAlarms}      Create List       Trail Trace Identifier Mismatch
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
        
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(30,90)  modules=random
    Sleep  ${random}       
    
    Log             Verify the local OTU4/ODU4 interface operation status are inService
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}

    Log             Verify the remote OTU4/ODU4 interface are alarm free and the operation status are inService
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON} 

    Log              Modify ODU4 expected-sapi back to "expected-sapi" on local client port
   &{intf}          create dictionary   interface-name=${client intf}  odu-expected-sapi=tx-sapi-val
   @{interface_info}    create list  ${intf}    
   &{dev_info}      create_dictionary   interface=${interface_info}       
   &{payload}       create_dictionary   org-openroadm-device=${dev_info}
   Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload} 
   
   Log              Verify Alarms In Traffic Chain Are Alarm Free
   Wait Until Interfaces In Traffic Chain Are Alarm Free
   
   ${random}=  Evaluate  random.randint(1, 60)  modules=random
   Sleep  ${random}
   Verify Interfaces In Traffic Chain Are Alarm Free
   
   Verify Client Interfaces In Traffic Chain Are Up
   
   Log To Console   Verify Traffic Is OK
   Verify Traffic Is OK  
   
   [Teardown]  	  Recover ODU TTI on Attella    ${client intf} 



TC31
    [Documentation]  After Attella system cold reload,the ODU-SD alarm still can be raised.
    [Tags]           tc31 

    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting ODU4 SD error from tester
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8  MAX
   
    Log              Verify SD alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List   Loss of Frame    Degraded defect
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Degraded defect
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms} 
  
    Log               Cold reload the remote Attella NE   
    Rpc Command For Cold Reload device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0 
 
    Log              Verify SD alarm raise on local ODU4 interface    
	@{expectedAlarms}  Create List      Degraded defect
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
        
    Log              Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(30,90)  modules=random
    Sleep  ${random}       
       
    Log              Verify OTU4/ODU4 operation status on local are outOfService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}         ${OPER_STATUS_DEGRADED}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}     ${OPER_STATUS_ON}
   
    Log              Verify OTU4/ODU4 operation status on remote are inService
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}       ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}   ${OPER_STATUS_ON}
    

    Log             Stop injecting SD error from tester, verify the SD alarm is clear
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8
    Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free
    
    Log             Wait a random time to keep the alarm clear on Attella
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
   
    Log             Verify the OTU4 interface status is inService
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log             Verify Traffic Is OK
	Verify Traffic Is OK    

   [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8




	
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

	Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
    
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

    
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}


    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK

    Verify Client Interfaces In Traffic Chain Are Up

    
Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
    
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}
#    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
#    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
#    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
#    
#    &{intf}=   create_dictionary   interface-name=${odu intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
#    
#    &{intf}=   create_dictionary   interface-name=${otu intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
#    
#    &{intf}=   create_dictionary   interface-name=${och intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
#    
#    &{intf}=   create_dictionary   interface-name=${client intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
#    
#    
#    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
#    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
#    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
#    
#    &{intf}=   create_dictionary   interface-name=${odu intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
#    
#    &{intf}=   create_dictionary   interface-name=${otu intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
#    
#    &{intf}=   create_dictionary   interface-name=${och intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
#    
#    &{intf}=   create_dictionary   interface-name=${remote client intf}
#    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
#    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}

#	Log To Console  de-provision on both device0 and device1
#    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
#	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    
    
#Create OTU4 Service
#    [Documentation]   Retrieve system configuration and state information
#    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}  ${modulation}
#    ${rate}=  Set Variable  100G
#    
#    Log To Console  ${client intf}
#    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
#    
#    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
#    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
#    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
#    ${line support port}=  Get Supporting Port  ${och intf}
#    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
#    ${client support port}=  Get Supporting Port  ${client intf}
#    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
#    ${client rate}=  Speed To Client Rate  ${rate}
#    ${odu rate}=  Speed To ODU Rate  ${rate}
#    ${otu rate}=  Speed To OTU Rate  ${rate}
#    ${och rate}=  Speed To OCH Rate  ${rate}
#
#    &{client_otu_interface}    create_dictionary   interface-name=${client otu intf}    description=client-otu-${discription}    interface-type=otnOtu
#    ...    interface-administrative-state=inService   otu-rate=${otu rate}  otu-tx-sapi=tx-sapi-val  otu-tx-dapi=tx-dapi-val  
#    ...    otu-expected-sapi=tx-sapi-val  otu-expected-dapi=tx-dapi-val  otu-tim-detect-mode=SAPI-and-DAPI
#    ...    otu-fec=rsfec
#    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}
#    ...    interface-circuit-id=1234
#    
#    &{client_interface}    create_dictionary   interface-name=${client intf}    description=client-odu-${discription}    interface-type=otnOdu    
#    ...    interface-administrative-state=inService   odu-rate=${odu rate}  odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
#    ...    odu-expected-sapi=tx-sapi-val  odu-expected-dapi=tx-dapi-val  odu-tim-detect-mode=SAPI-and-DAPI
#    ...    interface-circuit-id=1234
#    ...    supporting-interface=${client otu intf}    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}
#
#    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel    
#    ...    interface-administrative-state=inService    supporting-interface=none   och-rate=${och rate}  modulation-format=${modulation}
#    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}  frequency=${frequency}000
#    ...    interface-circuit-id=1234
#    
#    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}    interface-type=otnOtu    
#    ...    interface-administrative-state=inService    supporting-interface=${och intf}  otu-rate=${otu rate}  otu-tx-sapi=tx-sapi-val  otu-tx-dapi=tx-dapi-val  
#    ...    otu-expected-sapi=tx-sapi-val  otu-expected-dapi=tx-dapi-val  otu-tim-detect-mode=SAPI-and-DAPI
#    ...    otu-fec=scfec
#    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
#    ...    interface-circuit-id=1234
#    
#    &{odu_interface}    create_dictionary   interface-name=${odu intf}     description=odu-${discription}    interface-type=otnOdu    
#    ...    interface-administrative-state=inService    supporting-interface=${otu intf}     odu-rate=${odu rate}  odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
#    ...    odu-expected-sapi=tx-sapi-val  odu-expected-dapi=tx-dapi-val  odu-tim-detect-mode=SAPI-and-DAPI
#    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
#    ...    interface-circuit-id=1234
#    
#    @{interface_info}    create list    ${och_interface}    ${otu_interface}    ${odu_interface} 
#    &{dev_info}   create_dictionary   interface=${interface_info}       
#    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
#    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload} 
#    
#    @{interface_info}    create list    ${client_otu_interface}    ${client_interface}
#    &{dev_info}   create_dictionary   interface=${interface_info}       
#    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
#    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload}     
 
 
 
 

    
Verify Traffic Is OK
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    Clear Statistic And Alarm  ${testSetHandle1}  
    Clear Statistic And Alarm  ${testSetHandle2}
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  15
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
   
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
    
    [Teardown]  Run Keywords  Start Traffic  ${testSetHandle1}  AND  Start Traffic  ${testSetHandle2}

    
    
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
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}	
	
