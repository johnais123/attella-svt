*** Settings ***
Documentation    This is Attella odu4 traffic Scripts
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

Resource    jnpr/toby/Master.robot

Library         BuiltIn
Library         String
Library         Collections
Library         OperatingSystem
Library         String
Library         ExtendedRequestsLibrary
Library         XML    use_lxml=True

Resource        lib/restconf_oper.robot
Resource        lib/testSet.robot
Resource        lib/attella_keyword.robot


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

${OPER_STATUS_ON}  inService
${OPER_STATUS_OFF}  outOfService

*** Test Cases ***     
TC1
    [Documentation]  Service Provision
    ...              RLI38965  5.1-1  5.1-2  5.1-3  5.1-4
    [Tags]  Sanity  tc1
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}

TC2
    [Documentation]  Traffic Verification
    ...              RLI38965  5.2-1
    [Tags]  Sanity  tc2
    Log To Console  Verify Traffic
    Verify Traffic Is OK
	Verify Client Interfaces In Traffic Chain Are Up

TC3
    [Documentation]  Disable Client Interface And Verify Traffic
    ...              RLI38965  5.2-11
    [Tags]  Advance   tc3
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is One Way Through
	
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}
    
TC4
    [Documentation]  Enable Client Interface And Verify Traffic
    ...              RLI38965  5.2-11
    [Tags]  Advance   tc4
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	Verify Client Interfaces In Traffic Chain Are Up
    
TC5
    [Documentation]  Disable Client Interface And Verify Traffic
    ...              RLI38965  5.2-12
    [Tags]  Sanity  tc5
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${client otu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is One Way Through
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_OFF}

TC6
    [Documentation]  Enable Client Interface And Verify Traffic
    ...              RLI38965  5.2-12
    [Tags]  Sanity  tc6
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${client otu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	Verify Client Interfaces In Traffic Chain Are Up
    
    
TC7
    [Documentation]  Disable Line Odu Interface And Verify Traffic
    ...              RLI38965  5.2-15
    [Tags]  Sanity  tc7
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is Opposite Way Through
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${odu intf}  ${OPER_STATUS_OFF}
    
TC8
    [Documentation]  Enable Line Odu Interface And Verify Traffic
    ...              RLI38965  5.2-15
    [Tags]  Sanity  tc8
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	Verify Client Interfaces In Traffic Chain Are Up
    
TC9
    [Documentation]  Disable Line Otu Interface And Verify Traffic
    ...              RLI38965  5.2-14
    [Tags]  Advance   tc9
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    &{intf}=   create_dictionary   interface-name=${otu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is Opposite Way Through
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${otu intf}  ${OPER_STATUS_OFF}
    
TC10
    [Documentation]  Enable Line Otu Interface And Verify Traffic
    ...              RLI38965  5.2-14
    [Tags]  Advance   tc10
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    &{intf}=   create_dictionary   interface-name=${otu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	Verify Client Interfaces In Traffic Chain Are Up
    
TC11
    [Documentation]  Disable Line Och Interface And Verify Traffic
    ...              RLI38965  5.2-13
    [Tags]  Advance   tc11
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    &{intf}=   create_dictionary   interface-name=${och intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is Opposite Way Through
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${och intf}  ${OPER_STATUS_OFF}
    
TC12
    [Documentation]  Enable Line Och Interface And Verify Traffic
    ...              RLI38965  5.2-13
    [Tags]  Advance   tc12
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    &{intf}=   create_dictionary   interface-name=${och intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	Verify Client Interfaces In Traffic Chain Are Up
    
    
TC13
    [Documentation]  Service De-provision
    [Tags]  Advance   tc13
    Remove OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
	Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    Remove OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}

    
TC14
    [Documentation]  Traffic Verification After Service De-provision
    ...              RLI38965  5.2-1
    [Tags]  Advance   tc14
    Log To Console  Verify Traffic
    Verify Traffic Is Blocked
    
TC15
    [Documentation]  Recreate Service And Verify Traffic
    ...              RLI38965  5.2-1
    [Tags]  Advance   tc15
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}

    Log To Console  Verify Traffic
    Verify Traffic Is OK
	Verify Client Interfaces In Traffic Chain Are Up
	
TC16
    [Documentation]  Service De-provision
    ...              RLI38965  5.2-1
    [Tags]  Sanity  tc16
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
    

Test Bed Teardown
    [Documentation]  Test Bed Teardown
    
    Log To Console  Remove Service
    Remove OTU4 Service   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Remove OTU4 Service   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}
    
    Log To Console  Stopping Traffic    
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}
    
    
Verify Traffic Is One Way Through
    Log To Console  Verify Traffic Is One Way Through
    
    Sleep  20
    
    Clear Statistic And Alarm  ${testSetHandle1}
    Clear Statistic And Alarm  ${testSetHandle2}
       
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
   
	@{lTx}=  create list  ${testSetHandle1}
    @{lRx}=  create list  ${testSetHandle2}
	
    @{lTxFail}=  create list  ${testSetHandle2}
    @{lRxFail}=  create list  ${testSetHandle1}
    
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${lTxFail}  ${lRxFail}
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
	
	
	
Verify Traffic Is Opposite Way Through
    Log To Console  Verify Traffic Is Opposite Way Through
    
    Sleep  20
    
    Clear Statistic And Alarm  ${testSetHandle1}
    Clear Statistic And Alarm  ${testSetHandle2}
       
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
   
	@{lTx}=  create list  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle1}
	
    @{lTxFail}=  create list  ${testSetHandle1}
    @{lRxFail}=  create list  ${testSetHandle2}
    
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${lTxFail}  ${lRxFail}
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

    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
	
	
Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}  ${OPER_STATUS_ON}

    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}  ${OPER_STATUS_ON}
