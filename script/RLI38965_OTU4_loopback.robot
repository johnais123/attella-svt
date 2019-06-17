*** Settings ***
Documentation    This is Attella 100ge traffic Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author: Jack Wu
...              Date   : 12/26/2018
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
...              jtms description           : Attella
...              RLI                        : 38968
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
${interval}  10
${timeout}  100

${ALARM CHECK TIMEOUT}      1 min 


*** Test Cases ***     	
TC1
    [Documentation]  verify client otu interface facility loopback
    ...              RLI38965   5.9-1
    ...              FAC2 loopack on C1 otu port:
    ...              otu4 traffic is ok.
    ...              Facility Loopback2 Operated on C1 otu port  
    ...              1)Inject ODU-AIS from EXFO1.
    ...              2)C1 odu port raise ODU-AIS, L2 odu port raise ODU-AIS.
    ...              3)EXFO1/EXFO2 will raise AIS. 
    ...              4)Traffic will interrupt.
    ...              5)stop Inject ODU-AIS, traffic will recover.
    [Tags]  Sanity  tc1
	
	@{EMPTY LIST}=  create list
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	Log To Console  Facility Loopback2 Operated on local client otu port  
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  fac2

	
	Log To Console  Inject ODU-AIS from EXFO1.
	Start Inject Alarm On Test Equipment   ${testSetHandle1}   ALARM_OTU4_ODU4_AIS
	
	Log To Console  local client odu port raise ODU-AIS, remote line odu port raise ODU-AIS
	@{expectedAlarms}  Create List  ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	
	Log To Console  EXFO1/EXFO2 will raise AIS. 
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle2}  ALARM_OTU4_ODU4_AIS
	
	Log To Console  Set no Loopback on local client otu interface
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  off

	Log To Console  stop Injecting OTU4 AIS alarm from tester
	Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
	
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	[Teardown]  Run Keywords  Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  off  AND  Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS

	
	
TC2
    [Documentation]  verify client otu interface terminal loopback
    ...              RLI38965   5.9-2
    ...              Terminal Loopback Operated on C1 otu port
    ...              1)Inject ODU-AIS from EXFO2.
    ...              2)C2 odu port raise ODU-AIS, L1 odu port raise ODU-AIS, C2 odu port raise ODU-AIS  
    ...              3)EXFO1/EXFO2 will raise AIS. 
    ...              4)Traffic will interrupt.
    ...              5)stop Inject ODU-AIS, traffic will recover.
    [Tags]  tc2
	
	@{EMPTY LIST}=  create list
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	Log To Console  Terminal Loopback Operated on local client otu port
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  term

	
	Log To Console  Inject ODU-AIS from EXFO2.
	Start Inject Alarm On Test Equipment   ${testSetHandle2}   ALARM_OTU4_ODU4_AIS
	
	Log To Console  remote client odu port raise ODU-AIS, local line odu port raise ODU-AIS
	@{expectedAlarms}  Create List  ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	
	Log To Console  EXFO1/EXFO2 will raise AIS. 
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle2}  ALARM_OTU4_ODU4_AIS
	
	Log To Console  Set no Loopback on local client otu interface
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  off

	Log To Console  stop Injecting OTU4 AIS alarm from tester
	Stop Inject Alarm On Test Equipment    ${testSetHandle2}  ALARM_OTU4_ODU4_AIS
	
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	[Teardown]  Run Keywords  Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  off  AND  Stop Inject Alarm On Test Equipment    ${testSetHandle2}  ALARM_OTU4_ODU4_AIS



TC3
    [Documentation]  verify line otu interface facility loopback
    ...              RLI38966   5.8-1
    ...              FAC2 loopack on L1 otu port:
    ...              otu4 traffic is ok.
    ...              fac2 loopback will raise on L1 otu port   
    ...              1)Inject ODU-AIS from EXFO2.
    ...              2)C2 odu port raise ODU-AIS,L2 odu port raise ODU-AIS, L1 odu port raise ODU-AIS
    ...              3)EXFO1/EXFO2 will raise AIS.
    ...              4)Traffic will interrupt.
    ...              5)stop Inject ODU-AIS, traffic will recover.
    [Tags]  tc3
	
	@{EMPTY LIST}=  create list
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	Log To Console  Facility Loopback2 Operated on local line otu interface  
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  fac2

	
	Log To Console  Inject ODU-AIS from EXFO2.
	Start Inject Alarm On Test Equipment   ${testSetHandle2}   ALARM_OTU4_ODU4_AIS
	
	Log To Console  remote client odu port raise ODU-AIS, remote line odu port raise ODU-AIS, local line odu port raise ODU-AIS
	@{expectedAlarms}  Create List  ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	
	Log To Console  EXFO1/EXFO2 will raise AIS. 
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle2}  ALARM_OTU4_ODU4_AIS
	
	Log To Console  Set no Loopback on local line otu interface
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  off

	Log To Console  stop Injecting OTU4 AIS alarm from tester
	Stop Inject Alarm On Test Equipment    ${testSetHandle2}  ALARM_OTU4_ODU4_AIS
	
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	[Teardown]  Run Keywords  Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  off  AND  Stop Inject Alarm On Test Equipment    ${testSetHandle2}  ALARM_OTU4_ODU4_AIS

TC4
    [Documentation]  verify line otu interface terminal loopback
    ...              RLI38966  5.8-2
    ...              Term loopack on L1 otu port: 
    ...              otu4 traffic is ok.
    ...              Terminal Loopback Operated on L1 otu port
    ...              1)Inject ODU-AIS from EXFO1.
    ...              2)C1 odu port raise ODU-AIS, L1 odu port raise ODU-AIS, L2 odu port raise ODU-AIS  
    ...              3)EXFO1/EXFO2 will raise AIS. 
    ...              4)Traffic will interrupt.
    ...              5)stop Inject ODU-AIS, traffic will recover.

    [Tags]  Sanity  tc4
	
	@{EMPTY LIST}=  create list
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	Log To Console  Terminal Loopback Operated on local line otu port
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  term

	
	Log To Console  Inject ODU-AIS from EXFO1.
	Start Inject Alarm On Test Equipment   ${testSetHandle1}   ALARM_OTU4_ODU4_AIS
	
	Log To Console  local client odu port raise ODU-AIS, local line odu port raise ODU-AIS, remote line odu port raise ODU-AIS
	@{expectedAlarms}  Create List  ODU Alarm Indication Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	
	Log To Console  EXFO1/EXFO2 will raise AIS. 
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
	Wait until keyword succeeds  1 min  5 sec  Is Alarm Raised  ${testSetHandle2}  ALARM_OTU4_ODU4_AIS
	
	Log To Console  Set no Loopback on local line otu interface
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  off

	Log To Console  stop Injecting OTU4 AIS alarm from tester
	Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS
	
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
	[Teardown]  Run Keywords  Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  off  AND  Stop Inject Alarm On Test Equipment    ${testSetHandle1}  ALARM_OTU4_ODU4_AIS

	

*** Keywords ***
Test Bed Init
    Set Log Level  DEBUG
    # Initialize
    Log To Console      create a restconf operational session

    @{dut_list}    create list    device0  device1
    Preconfiguration netconf feature    @{dut_list}
    
    ${opr_session}    Set variable      operational_session
    Create Session          ${opr_session}    http://${tv['uv-odl-server']}/restconf/operational/network-topology:network-topology/topology/topology-netconf    auth=${auth}    debug=1
    Set Suite Variable    ${opr_session}
    
    Log To Console      create a restconf config session
    ${cfg_session}    Set variable      config_session
    Create Session          ${cfg_session}    http://${tv['uv-odl-server']}/restconf/config/network-topology:network-topology/topology/topology-netconf    auth=${auth}    debug=1
    Set Suite Variable    ${cfg_session}
    
    @{odl_sessions}    create list   ${opr_session}   ${cfg_session}
    Set Suite Variable    ${odl_sessions}
    
    
    ${client intf}=  Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    Set Suite Variable    ${client intf}
    
    ${remote client intf}=  Get Otu4 Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    Set Suite Variable    ${remote client intf}
    
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
	
	
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}    
    
	
	Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
	
	Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}


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
	
	
	Set OTU FEC  ${testSetHandle1}  ${tv['uv-client_fec']}
	Set OTU FEC  ${testSetHandle2}  ${tv['uv-client_fec']}
	set OTU SM TTI Traces  ${testSetHandle1}  OPERATOR  ${null}  tx-operator-val
	set OTU SM TTI Traces  ${testSetHandle1}  sapi  Expected  tx-sapi-val
	set OTU SM TTI Traces  ${testSetHandle1}  dapi  Expected  tx-dapi-val
	set OTU SM TTI Traces  ${testSetHandle1}  sapi  Received  tx-sapi-val
	set OTU SM TTI Traces  ${testSetHandle1}  dapi  Received  tx-dapi-val

	set OTU SM TTI Traces  ${testSetHandle2}  OPERATOR  ${null}  tx-operator-val
	set OTU SM TTI Traces  ${testSetHandle2}  sapi  Expected  tx-sapi-val
	set OTU SM TTI Traces  ${testSetHandle2}  dapi  Expected  tx-dapi-val
	set OTU SM TTI Traces  ${testSetHandle2}  sapi  Received  tx-sapi-val
	set OTU SM TTI Traces  ${testSetHandle2}  dapi  Received  tx-dapi-val
	
	Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
	
	Log To Console  Create OTU4 Service
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
	
	Wait until keyword succeeds  ${ALARM CHECK TIMEOUT}  10 sec  Verify Interfaces In Traffic Chain Are Alarm Free
	
    
Test Bed Teardown
    [Documentation]  Test Bed Teardown   
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}
	
	Log To Console  de-provision on both device0 and device1
    Remove OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
	#Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    Remove OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}
 

    
Verify Interfaces In Traffic Chain Are Alarm Free
	@{EMPTY LIST}=  create list
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
