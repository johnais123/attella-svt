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
                 
Resource         ../lib/restconf_oper.robot
Resource         ../lib/testSet.robot
Resource         ../lib/attella_keyword.robot


Suite Setup      Run Keywords
...              Toby Suite Setup
...              Test Bed Init

Test Setup  Run Keywords  Toby Test Setup

Test Teardown  Run Keywords  Toby Test Teardown

Suite Teardown   Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      1 min 
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
${OPER_STATUS_DEGRADED}     degraded
${interval}                 10
${timeout}                  100
&{delete_headers}           Accept=application/xml
${CFG_SESSEION_INDEX}       1



*** Test Cases ***    
  
TC1
    [Documentation]  After Attella system cold reload,the OTU4 TTIM alarm still can be raised.
    [Tags]           Advance  tc1
  
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
	${random}=  Evaluate  random.randint(1, 20)  modules=random
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
   
   [Teardown]  	  Recover OTU TTI on Attella    ${client otu intf} 


TC2
    [Documentation]  After Attella system cold reload,the ODU-SD alarm still can be raised.
    [Tags]           Advance  tc2

    Log To Console  Verify Interfaces In Traffic Chain Are Alarm Free
    Wait Until Interfaces In Traffic Chain Are Alarm Free
   
    Log             Injecting ODU4 SD error from tester
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8  MAX
   
    Log              Verify SD alarm raise on local ODU4 interface    
	#@{expectedAlarms}  Create List   Loss of Frame    Degraded defect
	@{expectedAlarms}  Create List   Degraded defect
	Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}  ${expectedAlarms}  ${ALARM CHECK TIMEOUT}
    
    Log              Wait a random time to keep the alarm stable on Attella    
	${random}=  Evaluate  random.randint(1, 20)  modules=random
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
	${random}=  Evaluate  random.randint(1, 20)  modules=random
	Sleep  ${random}
	Verify Interfaces In Traffic Chain Are Alarm Free 

   [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8



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

    ${t}    get time 
    Log To Console    Device Setup Done ${t}
    
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
	
    ${t}    get time 
    Log To Console    Set TTI traces Done ${t}

    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}

    ${t}    get time 
    Log To Console    Creating service ${t}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}

    ${t}    get time 
    Log To Console    Created service ${t}
    
    Wait Until Interfaces In Traffic Chain Are Alarm Free

    ${t}    get time 
    Log To Console    Finished Setup ${t}
    

Test Bed Teardown
    [Documentation]  Test Bed Teardown
    
    Log To Console  Remove Service
    Remove OTU4 Service   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Remove OTU4 Service   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}
    
    Log To Console  Stopping Traffic    
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}
    
    
Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}
    
Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


    
Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
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
	
