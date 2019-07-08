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

${OPER_STATUS_ON}  inService
${OPER_STATUS_OFF}  outOfService

*** Test Cases ***     
TC1
    [Documentation]  Service Provision
    ...              RLI38964 5.1-1 5.2-1 5.1-3
    [Tags]  Sanity  tc1
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

TC2
    [Documentation]  Traffic Verification
    ...              RLI38964 5.2-1
    [Tags]  Sanity  tc2
    Log To Console  Verify Traffic
    Verify Traffic Is OK
	
	Verify Client Interfaces In Traffic Chain Are Up
	
	
    
TC3
    [Documentation]  Disable Client Interface And Verify Traffic
    ...              RLI38964 5.1-4 5.2-10
    [Tags]  Sanity  tc3
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
	Verify Traffic Is Blocked
	
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}
    
TC4
    [Documentation]  Enable Client Interface And Verify Traffic
    ...              RLI38964 5.1-3 5.2-10
    [Tags]  Sanity  tc4
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	
	Verify Client Interfaces In Traffic Chain Are Up
    
    
TC5
    [Documentation]  Disable Line Odu Interface And Verify Traffic
    ...              RLI38964 5.2-13
    [Tags]  Advance   tc5
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
	Verify Traffic Is Blocked
	
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${odu intf}  ${OPER_STATUS_OFF}
    
TC6
    [Documentation]  Enable Line Odu Interface And Verify Traffic
    ...              RLI38964 5.2-13
    [Tags]  Sanity  tc6
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	
	Verify Client Interfaces In Traffic Chain Are Up
    
TC7
    [Documentation]  Disable Line Otu Interface And Verify Traffic
    ...              RLI38964 5.2-12
    [Tags]  Advance   tc7
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    &{intf}=   create_dictionary   interface-name=${otu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is Blocked
	
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${otu intf}  ${OPER_STATUS_OFF}
TC8
    [Documentation]  Enable Line Otu Interface And Verify Traffic
    ...              RLI38964 5.2-12
    [Tags]  Advance   tc8
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    &{intf}=   create_dictionary   interface-name=${otu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
	
	Verify Client Interfaces In Traffic Chain Are Up
    
TC9
    [Documentation]  Disable Line Och Interface And Verify Traffic
    ...              RLI38964 5.2-11
    [Tags]  Advance   tc9
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    &{intf}=   create_dictionary   interface-name=${och intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
	Verify Traffic Is Blocked
	
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${och intf}  ${OPER_STATUS_OFF}
    
TC10
    [Documentation]  Enable Line Och Interface And Verify Traffic
    ...              RLI38964 5.2-11
    [Tags]  Advance   tc10
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
    
    
TC11
    [Documentation]  Service De-provision
    ...              RLI38964 5.1-2  5.2-2
    [Tags]  Advance   tc11

	Remove 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    Remove 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}

    
TC12
    [Documentation]  Traffic Verification After Service De-provision
    ...              RLI38964 
    [Tags]  Advance   tc12
    Log To Console  Verify Traffic
    Verify Traffic Is Blocked
	
TC13
    [Documentation]  Recreate Service And Verify Traffic
    ...              RLI38964
    [Tags]  Advance   tc13
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

    Log To Console  Verify Traffic
    Verify Traffic Is OK
	
	Verify Client Interfaces In Traffic Chain Are Up
	
	
TC14
    [Documentation]  Service De-provision
    ...              RLI38964
    [Tags]  Sanity  tc14
	Remove 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    Remove 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}


    
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
    
	Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
           
    Init Test Equipment  ${testSetHandle1}  100ge
    Init Test Equipment  ${testSetHandle2}  100ge


Test Bed Teardown
    [Documentation]  Test Bed Teardown

    Log To Console  Remove Service
    Remove 100GE Service   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Remove 100GE Service   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}

    
Verify Traffic Is One Way Through
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
    @{lRx}=  create list  ${testSetHandle1}
	
    @{lTxFail}=  create list  ${testSetHandle1}
    @{lRxFail}=  create list  ${testSetHandle2}
    
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

	
	
Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}  ${OPER_STATUS_ON}

    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}  ${OPER_STATUS_ON}