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
...              Toby Suite Teardown


*** Variables ***
@{auth}    admin    admin
${interval}  10
${timeout}  300

*** Test Cases ***     
TC1
    [Documentation]  Service Provision
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc1
	Log To Console  Create OTU4 Service
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}


TC2
    [Documentation]  Traffic Verification
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc2
    Log To Console  Verify Traffic
    Verify Traffic Is OK
	
	Set Loopback To ODU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  term
	Verify Traffic Is Local To Remote One Way Through
	
	Set Loopback To ODU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  off
	Verify Traffic Is OK
	

	

TC3
    [Documentation]  Traffic Verification
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc3
    Log To Console  Verify Traffic
    Verify Traffic Is OK
	
	Set Loopback To ODU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  fac
	Verify Traffic Is Remote To Local One Way Through
	
	Set Loopback To ODU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  off
	Verify Traffic Is OK
	
TC4
    [Documentation]  Traffic Verification
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc4
    Log To Console  Verify Traffic
    Verify Traffic Is OK
	
	${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  term
	Verify Traffic Is Local To Remote One Way Through
	
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  off
	Verify Traffic Is OK
	

	

TC5
    [Documentation]  Traffic Verification
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc5
    Log To Console  Verify Traffic
    Verify Traffic Is OK
	
	${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
	
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  fac
	Verify Traffic Is Remote To Local One Way Through
	
	Set Loopback To OTU Interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  off
	Verify Traffic Is OK
	
	
TC6
    [Documentation]  Service De-provision
    [Tags]  Sanity  tc6
    Remove OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
	Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    Remove OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}

	
	

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
    
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}    
    
	Log To Console  de-provision on both device0 and device1
    Delete Request  @{odl_sessions}[1]  /node/${tv['device0__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/
    Delete Request  @{odl_sessions}[1]  /node/${tv['device1__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/

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
    

Verify Traffic Is OK
    Log To Console  Verify Traffic Is OK
    : FOR    ${nLoop}    IN RANGE    1    6
    \    Sleep  10
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
    
Verify Traffic Is Local To Remote One Way Through
    Log To Console  Verify Traffic Is One Way Through
    
    Sleep  10
    
    Clear Statistic And Alarm  ${testSetHandle1}
    Clear Statistic And Alarm  ${testSetHandle2}
       
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
   
	@{lTx}=  create list  ${testSetHandle1}
    @{lRx}=  create list  ${testSetHandle1}
	
    @{lTxFail}=  create list  ${testSetHandle2}
    @{lRxFail}=  create list  ${testSetHandle2}
    
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${lTxFail}  ${lRxFail}
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
	
Verify Traffic Is Remote To Local One Way Through
    Log To Console  Verify Traffic Is One Way Through
    
    Sleep  10
    
    Clear Statistic And Alarm  ${testSetHandle1}
    Clear Statistic And Alarm  ${testSetHandle2}
       
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
   
	@{lTx}=  create list  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle2}
	
    @{lTxFail}=  create list  ${testSetHandle1}
    @{lRxFail}=  create list  ${testSetHandle1}
    
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${lTxFail}  ${lRxFail}
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
	
Verify Traffic Is Blocked
    Log To Console  Verify Traffic Is Blocked
    
    Sleep  10
    
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

    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails