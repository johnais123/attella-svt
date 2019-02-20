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
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

TC2
    [Documentation]  Traffic Verification
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc2
    Log To Console  Verify Traffic
    Verify Traffic Is OK
    
TC3
    [Documentation]  Disable Client Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc3
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is One Way Through
    
TC4
    [Documentation]  Enable Client Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc4
    &{intf}=   create_dictionary   interface-name=${client intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
    
    
TC5
    [Documentation]  Disable Line Odu Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc5
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is One Way Through
    
TC6
    [Documentation]  Enable Line Odu Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc6
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${odu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
    
TC7
    [Documentation]  Disable Line Otu Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc7
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    &{intf}=   create_dictionary   interface-name=${otu intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is One Way Through
    
TC8
    [Documentation]  Enable Line Otu Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc8
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    &{intf}=   create_dictionary   interface-name=${otu intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
    
TC9
    [Documentation]  Disable Line Och Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc9
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    &{intf}=   create_dictionary   interface-name=${och intf}  interface-administrative-state=outOfService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is One Way Through
    
TC10
    [Documentation]  Enable Line Och Interface And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc10
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    &{intf}=   create_dictionary   interface-name=${och intf}  interface-administrative-state=inService
    
    @{interface_info}    create list  ${intf}
    
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
    
    Verify Traffic Is OK
    
    
TC11
    [Documentation]  Service De-provision
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc11

	Remove 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    Remove 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}

    
TC12
    [Documentation]  Traffic Verification After Service De-provision
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc12
    Log To Console  Verify Traffic
    Verify Traffic Is Blocked
	
TC13
    [Documentation]  Recreate Service And Verify Traffic
    ...              RLI38968 5.1-8
    [Tags]  Sanity  tc13
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

    Log To Console  Verify Traffic
    Verify Traffic Is OK
	
	
TC14
    [Documentation]  Service De-provision
    ...              RLI38968 5.1-8
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
    Set Suite Variable    ${client intf}
    
    ${remote client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    Set Suite Variable    ${remote client intf}
    
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    
	Log To Console  de-provision on both device0 and device1
    Delete Request  @{odl_sessions}[1]  /node/${tv['device0__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/
    Delete Request  @{odl_sessions}[1]  /node/${tv['device1__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/

	
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
           
    Init Test Equipment  ${testSetHandle1}  100ge
    Init Test Equipment  ${testSetHandle2}  100ge

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

	@{lTx}=  create list  ${testSetHandle1}
    @{lRx}=  create list  ${testSetHandle2}
	
    @{lTxFail}=  create list  ${testSetHandle2}
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