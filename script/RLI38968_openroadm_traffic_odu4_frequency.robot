*** Settings ***
Documentation     This is Attella traffic frequency Scripts
...               If you are reading this then you need to learn Toby
...               Author: Jack Wu
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/54547
...              jtms description           : Attella
...              RLI                        : 38968
...              MIN SUPPORT VERSION        : 19.1
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : OPENROADM
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

Test Setup  Run Keywords  Toby Test Setup

Test Teardown  Run Keywords  Toby Test Teardown

Suite Teardown  Run Keywords
...              Toby Suite Teardown


*** Variables ***
@{auth}    admin    admin
${interval}  120
${timeout}  120

*** Test Cases ***  

TC1
    [Documentation]     Modify both dut Frequency 191.35 And Verify Traffic
    [Tags]  Sanity      tc1
    Set Both Frequency And Verify Traffic  191.35

TC2
    [Documentation]     Modify both dut Frequency 193.40 And Verify Traffic
    [Tags]  Sanity      tc2
    Set Both Frequency And Verify Traffic  193.40

TC3
    [Documentation]     Modify both dut Frequency 196.10 And Verify Traffic
    [Tags]  Sanity      tc3
    Set Both Frequency And Verify Traffic  196.10
    



*** Keywords ***

Service De-provision
    Log  Remove Service
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    
    &{intf}=   create_dictionary   interface-name=${odu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${och intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${client intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${client otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    
    &{intf}=   create_dictionary   interface-name=${odu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${och intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${remote client intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    ${remote client otu intf}=  Get OTU Intface Name From ODU Intface  ${remote client intf}
    &{intf}=   create_dictionary   interface-name=${remote client otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    

Set Both Frequency And Verify Traffic
    [Documentation]   Set Both Frequency And Verify Traffic
    [Arguments]    ${frequency}
    &{och_interface}    create_dictionary   interface-name=${line och intf}  frequency=${frequency}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 
    
    &{och_interface}    create_dictionary   interface-name=${remote line och intf}  frequency=${frequency}000
    
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
    
    &{och_interface}    create_dictionary   interface-name=${line och intf}  frequency=${frequencyNew}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 
    
    Log  Verify Traffic
    Verify Traffic Is Blocked

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
	
	#Log To Console  de-provision on both device0 and device1
    #Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	#Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}

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

    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
	
	Verify Traffic Is OK

    
Verify Traffic Is Blocked
    Log  Verify Traffic Is Blocked
    
    Sleep  5    

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
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails After Service De-provision
    
