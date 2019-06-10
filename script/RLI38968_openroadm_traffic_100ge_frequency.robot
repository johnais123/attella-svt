*** Settings ***
Documentation     This is Attella traffic frequency Scripts
...               If you are reading this then you need to learn Toby
...               Author: Jack Wu

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


Suite Teardown  Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{auth}    admin    admin
${interval}  10
${timeout}  100

*** Test Cases ***     
Modify both dut Frequency 191.35 And Verify Traffic
	[Tags]  tc1
    Set Both Frequency And Verify Traffic  191.35
    
Modify both dut Frequency 193.40 And Verify Traffic
	[Tags]  tc2
    Set Both Frequency And Verify Traffic  193.40
    
Modify both dut Frequency 196.10 And Verify Traffic
	[Tags]  tc3
    Set Both Frequency And Verify Traffic  196.10
    
    
    
Service De-provision
	[Tags]  tcTeardown
	Remove 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    Remove 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}

*** Keywords ***
Set Both Frequency And Verify Traffic
    [Documentation]   Set Both Frequency And Verify Traffic
    [Arguments]    ${frequency}
    &{och_interface}    create_dictionary   interface-name=${och intf}  frequency=${frequency}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 
    
    &{och_interface}    create_dictionary   interface-name=${remote och intf}  frequency=${frequency}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}   ${payload} 
    
    Log  Verify Traffic
    Verify Traffic Is OK
    
Modify one dut to a different random Frequency And Verify Traffic
    [Documentation]   Set Both Frequency And Verify Traffic
    [Arguments]    ${frequency}
    
    ${frequencyRandom}=  Get A Random Frequency
    ${frequencyNext}=  Get The Next Frequency  ${frequency}
    ${frequencyNew}=  Set Variable If  '${frequencyRandom}' == '${frequency}'  ${frequencyNext}  ${frequencyRandom}
    
    &{och_interface}    create_dictionary   interface-name=${och intf}  frequency=${frequencyNew}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 
    
    Log  Verify Traffic
    Verify Traffic Is Blocked

Test Bed Teardown
    Log To Console    stop and release test set
    Remove 100GE Service    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Remove 100GE Service    ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}§
    Release Test Equipment    ${testSetHandle1}
    Release Test Equipment    ${testSetHandle2}

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
	
	${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
	Set Suite Variable    ${och intf}
	
	${remote odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote otu intf}=  Get OTU Intface Name From ODU Intface  ${remote odu intf}
    ${remote och intf}=  Get OCH Intface Name From OTU Intface  ${remote otu intf}
	Set Suite Variable    ${remote och intf}
    
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    
	Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}

    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
           
    Init Test Equipment  ${testSetHandle1}  100ge
    Init Test Equipment  ${testSetHandle2}  100ge
    
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

    Verify Traffic Is OK

Verify Traffic Is OK
#    Log To Console  Verify Traffic Is OK
#    : FOR    ${nLoop}    IN RANGE    1    6
#    \    Sleep  10
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

    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    Clear Statistic And Alarm  ${testSetHandle1}  
    Clear Statistic And Alarm  ${testSetHandle2}
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
   
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

    
