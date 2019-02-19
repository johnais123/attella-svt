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


# Test Setup  Run Keywords
# ...              Toby Test Setup
 
# Test Teardown  Run Keywords
# ...              Toby Test Teardown

Suite Teardown  Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{EMPTY LIST}

${ALARM CHECK TIMEOUT}  5 min
${OPER_STATUS_ON}  inService
${OPER_STATUS_OFF}  outOfService

*** Test Cases ***     
TC1
    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Interfaces In Traffic Chain Are Alarm Free
	
	Log To Console  turn Laser off
	Set Laser State  ${testSetHandle1}  OFF
	
	Log To Console  Verify Alarms
	@{expectedAlarms}  Create List  Loss of Signal
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
	
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	@{expectedAlarms}  Create List  Loss of Signal
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${expectedAlarms}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_OFF}

	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_OFF}

	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}

	
	Log To Console  turn Laser on
	Set Laser State  ${testSetHandle1}  ON
	
	Log To Console  Verify Alarms
	Wait Until Interfaces In Traffic Chain Are Alarm Free
	
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free
	
	Verify Client Interfaces In Traffic Chain Are Up
	
	Log To Console  Verify Traffic Is OK
	Verify Traffic Is OK
	
	[Teardown]  Set Laser State  ${testSetHandle1}  ON
	
    
*** Keywords ***
Test Bed Init
    Set Log Level  DEBUG
    # Initialize
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
    
    @{odl_sessions}    create list   ${opr_session}   ${cfg_session}
    Set Suite Variable    ${odl_sessions}
    
    
    ${client intf}=  Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
	${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    ${line odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${line otu intf}=  Get OTU Intface Name From ODU Intface  ${line odu intf}
    ${line och intf}=  Get OCH Intface Name From OTU Intface  ${line otu intf}
    Set Suite Variable    ${client intf}
    Set Suite Variable    ${client otu intf}
    Set Suite Variable    ${line odu intf}
    Set Suite Variable    ${line otu intf}
    Set Suite Variable    ${line och intf}
    
    ${remote client intf}=  Get Otu4 Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
	${remote client otu intf}=  Get OTU Intface Name From ODU Intface  ${remote client intf}
    ${remote line odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote line otu intf}=  Get OTU Intface Name From ODU Intface  ${remote line odu intf}
    ${remote line och intf}=  Get OCH Intface Name From OTU Intface  ${remote line otu intf}
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
	
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
           
    Init Test Equipment  ${testSetHandle1}  otu4
    Init Test Equipment  ${testSetHandle2}  otu4
	
	Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
	
	Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  qpsk
	
	Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  qpsk
	
	Verify Client Interfaces In Traffic Chain Are Up
	
	Wait Until Interfaces In Traffic Chain Are Alarm Free
	
	${random}=  Evaluate  random.randint(1, 60)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free

	
Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
	
	Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}
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

Create OTU4 Service
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}  ${modulation}
    ${rate}=  Set Variable  100G
    
    Log To Console  ${client intf}
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    ${line support port}=  Get Supporting Port  ${och intf}
    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
    ${client support port}=  Get Supporting Port  ${client intf}
    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
    ${client rate}=  Speed To Client Rate  ${rate}
    ${odu rate}=  Speed To ODU Rate  ${rate}
    ${otu rate}=  Speed To OTU Rate  ${rate}
    ${och rate}=  Speed To OCH Rate  ${rate}

    &{client_otu_interface}    create_dictionary   interface-name=${client otu intf}    description=client-otu-${discription}    interface-type=otnOtu
    ...    interface-administrative-state=inService   otu-rate=${otu rate}  otu-tx-sapi=777770000077777  otu-tx-dapi=888880000088888  
    ...    otu-expected-sapi=exp-sapi-val000  otu-expected-dapi=exp-dapi-val111  otu-tim-detect-mode=SAPI-and-DAPI
    ...    otu-fec=rsfec
    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}
    ...    interface-circuit-id=1234
    
    &{client_interface}    create_dictionary   interface-name=${client intf}    description=client-odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService   odu-rate=${odu rate}  odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
    ...    odu-expected-sapi=exp-sapi-val  odu-expected-dapi=exp-dapi-val  odu-tim-detect-mode=SAPI-and-DAPI
    ...    interface-circuit-id=1234
    ...    supporting-interface=${client otu intf}    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}

    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel    
    ...    interface-administrative-state=inService    supporting-interface=none   och-rate=${och rate}  modulation-format=${modulation}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}  frequency=${frequency}000
    ...    interface-circuit-id=1234
    
    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}    interface-type=otnOtu    
    ...    interface-administrative-state=inService    supporting-interface=${och intf}  otu-rate=${otu rate}  otu-tx-sapi=tx-sapi-val  otu-tx-dapi=tx-dapi-val  
    ...    otu-expected-sapi=exp-sapi-val  otu-expected-dapi=exp-dapi-val  otu-tim-detect-mode=SAPI-and-DAPI
    ...    otu-fec=scfec
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    ...    interface-circuit-id=1234
    
    &{odu_interface}    create_dictionary   interface-name=${odu intf}     description=odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService    supporting-interface=${otu intf}     odu-rate=${odu rate}  odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
    ...    odu-expected-sapi=exp-sapi-val  odu-expected-dapi=exp-dapi-val  odu-tim-detect-mode=SAPI-and-DAPI
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    ...    interface-circuit-id=1234
    
    @{interface_info}    create list    ${och_interface}    ${otu_interface}    ${odu_interface} 
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload} 
    
    @{interface_info}    create list    ${client_otu_interface}    ${client_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload} 
    
    
    
Create 100GE Service
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}
    ${rate}=  Set Variable  100G
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    ${line support port}=  Get Supporting Port  ${och intf}
    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
    ${client support port}=  Get Supporting Port  ${client intf}
    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
    ${client rate}=  Speed To Client Rate  ${rate}
    ${odu rate}=  Speed To ODU Rate  ${rate}
    ${otu rate}=  Speed To OTU Rate  ${rate}
    ${och rate}=  Speed To OCH Rate  ${rate}
    
    &{client_interface}    create_dictionary   interface-name=${client intf}    description=ett-${discription}    interface-type=ethernetCsmacd    
    ...    interface-administrative-state=inService   speed=${client rate}
    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}

    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel    
    ...    interface-administrative-state=inService    supporting-interface=none   och-rate=${och rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}  frequency=${frequency}000
    
    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}    interface-type=otnOtu    
    ...    interface-administrative-state=inService    supporting-interface=${och intf}  otu-rate=${otu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    &{odu_interface}    create_dictionary   interface-name=${odu intf}     description=odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService    supporting-interface=${otu intf}     odu-rate=${odu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    
    @{interface_info}    create list    ${client_interface}    ${och_interface}    ${otu_interface}    ${odu_interface} 
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload}

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
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}

	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}
	Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}

	
Wait Until Interfaces In Traffic Chain Are Alarm Free
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}

	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}

	
Verify Client Interfaces In Traffic Chain Are Up
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${OPER_STATUS_ON}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}  ${OPER_STATUS_ON}

	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}  ${OPER_STATUS_ON}
	Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
