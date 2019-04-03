*** Settings ***
Documentation    This is Attella 100ge Alarm Scripts
...              If you are reading this then you need to learn Toby
...              Description  : RLI-38964: ACX6180-T: Attella 4x100GE base transponder capability
...              Author: Linda Li
...              Date   : 02/22/2019
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/38964
...              jtms description           : Attella
...              RLI                        : 38964
...              MIN SUPPORT VERSION        : 19.2
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
Library         DateTime
Resource        ../lib/restconf_oper.robot
Resource        ../lib/testSet.robot
Resource        ../lib/attella_keyword.robot


Suite Setup   Run Keywords  Toby Suite Setup
...              Test Bed Init

Test Setup  Run Keywords  Toby Test Setup

Test Teardown  Run Keywords  Toby Test Teardown

Suite Teardown  Run Keywords
...              Test Bed Teardown
...              Toby Suite Teardown


*** Variables ***
@{auth}     admin    admin
${interval}  10
${timeout}   300
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
@{pmInterval}   15min    24Hour   notApplicable
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      5 min 

*** Test Cases ***     
TC0
    [Documentation]  Service Provision
    ...              RLI38964 
    [Tags]  Sanity  test
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK


TC1
    [Documentation]  Verify 100ge PM after warm reload
    ...              RLI38964  
    [Tags]           test
    Log To Console  Warm Reload Device
    Rpc Command For Warm Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0

    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmater3}       Create List     BIPErrorCounter    nearEnd    tx 
    @{pmEntryParmater4}       Create List     erroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmater5}       Create List     severelyErroredSecondsEthernet    nearEnd    rx
    @{pmEntryParmater6}       Create List     severelyErroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}    ${pmEntryParmater4}    ${pmEntryParmater5}    ${pmEntryParmater6} 

    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    log   ${currentMin}

    Log To Console  generate all 100ge pm counter
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   5
    Sleep   5
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   10
    Sleep   5
    Set Laser State  ${testSetHandle1}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle1}  ON
    Set Laser State  ${testSetHandle2}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle2}  ON
    Sleep   5

    Log To Console    Retrieve Current PM Statistics
    @{currentrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${currentrealpm}

    Log To Console    Verify Current PM Statistics after warm reload
    @{expectValue}       Create List   100
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[0]  
    @{expectValue}       Create List   200
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[2]  

    Log To Console    Retrieve History 15min PM Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  @{pmInterval}[0]    
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}  ${hisPmString}  ${pmEntryParmaterlist}  @{pmInterval}[0]
    log  ${realpm}

    Log To Console    Verify History 15min PM Statistics after warm reload
    Lists Should Be Equal   ${currentrealpm}    ${realpm}


TC2
    [Documentation]  Verify 100ge PM after cold reload
    ...              RLI38964  
    [Tags]
    Log To Console  Cold Reload Device
    Rpc Command For Cold Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0

    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmater3}       Create List     BIPErrorCounter    nearEnd    tx 
    @{pmEntryParmater4}       Create List     erroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmater5}       Create List     severelyErroredSecondsEthernet    nearEnd    rx
    @{pmEntryParmater6}       Create List     severelyErroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}    ${pmEntryParmater4}    ${pmEntryParmater5}    ${pmEntryParmater6} 

    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    log   ${currentMin}

    Log To Console  generate all 100ge pm counter
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   5
    Sleep   5
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   10
    Sleep   5
    Set Laser State  ${testSetHandle1}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle1}  ON
    Set Laser State  ${testSetHandle2}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle2}  ON
    Sleep   5

    Log To Console    Retrieve Current PM Statistics
    @{currentrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${currentrealpm}

    Log To Console    Verify Current PM Statistics after cold reload
    @{expectValue}       Create List   100
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[0]  
    @{expectValue}       Create List   200
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[2]  

    Log To Console    Retrieve History 15min PM Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  @{pmInterval}[0]    
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}  ${hisPmString}  ${pmEntryParmaterlist}  @{pmInterval}[0]
    log  ${realpm}

    Log To Console    Verify History 15min PM Statistics after cold reload
    Lists Should Be Equal   ${currentrealpm}    ${realpm}


TC3
    [Documentation]  Verify  100ge History 24Hour PM after warm reload
    ...              RLI38964  
    [Tags]
    Log To Console  Warm Reload Device
    Rpc Command For Warm Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0

    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmater3}       Create List     BIPErrorCounter    nearEnd    tx 
    @{pmEntryParmater4}       Create List     erroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmater5}       Create List     severelyErroredSecondsEthernet    nearEnd    rx
    @{pmEntryParmater6}       Create List     severelyErroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}    ${pmEntryParmater4}    ${pmEntryParmater5}    ${pmEntryParmater6} 

    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    log   ${currentMin}

    Log To Console  generate all 100ge pm counter
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   5
    Sleep   5
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   10
    Sleep   5
    Set Laser State  ${testSetHandle1}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle1}  ON
    Set Laser State  ${testSetHandle2}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle2}  ON
    Sleep   5

    Log To Console    Retrieve Current PM Statistics
    @{currentrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]
    log  ${currentrealpm}

    Log To Console    Verify Current PM Statistics after warm reload
    @{expectValue}       Create List   100
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[0]  
    @{expectValue}       Create List   200
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[2]  

    Log To Console    Retrieve History PM Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  @{pmInterval}[1]    
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}  ${hisPmString}  ${pmEntryParmaterlist}  @{pmInterval}[1]
    log  ${realpm}

    Log To Console    Verify History 24Hour PM Statistics after warm reload
    Lists Should Be Equal   ${currentrealpm}    ${realpm}


TC4
    [Documentation]  Verify  100ge History 24Hour PM after cold reload
    ...              RLI38964  
    [Tags]
    Log To Console  Cold Reload Device
    Rpc Command For Cold Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmater3}       Create List     BIPErrorCounter    nearEnd    tx 
    @{pmEntryParmater4}       Create List     erroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmater5}       Create List     severelyErroredSecondsEthernet    nearEnd    rx
    @{pmEntryParmater6}       Create List     severelyErroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}    ${pmEntryParmater4}    ${pmEntryParmater5}    ${pmEntryParmater6} 

    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    log   ${currentMin}

    Log To Console  generate all 100ge pm counter
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   5
    Sleep   5
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   10
    Sleep   5
    Set Laser State  ${testSetHandle1}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle1}  ON
    Set Laser State  ${testSetHandle2}  OFF
    Sleep   5
    Set Laser State  ${testSetHandle2}  ON
    Sleep   5

    Log To Console    Retrieve Current PM Statistics
    @{currentrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]
    log  ${currentrealpm}

    Log To Console    Verify Current PM Statistics after cold reload
    @{expectValue}       Create List   100
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[0]  
    @{expectValue}       Create List   200
    Verify Pm Should Be Equals  @{expectValue}[0]     @{currentrealpm}[2]  

    Log To Console    Retrieve History PM Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  @{pmInterval}[1]    
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}  ${hisPmString}  ${pmEntryParmaterlist}  @{pmInterval}[1]
    log  ${realpm}

    Log To Console    Verify History 24Hour PM Statistics after cold reload
    Lists Should Be Equal   ${currentrealpm}    ${realpm}


*** Keywords ***
Test Bed Init
    Set Log Level  DEBUG
    Log To Console  init test set to 100ge
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}

    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}

    Init Test Equipment  ${testSetHandle1}  100ge
    Init Test Equipment  ${testSetHandle2}  100ge


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

    Log To Console  load pre-default provision on device0
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Log To Console  load pre-default provision on device1
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    

    Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}


Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
    Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}


*** Keywords ***
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
    Log To Console  Verify Traffic Is OK
    : FOR    ${nLoop}    IN RANGE    1    6
    \    Sleep  20
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


Retrieve Current Statistics
    [Documentation]   Retrieve Detail history pm data 
    ${r0} =     Get Handle      resource=device0
    &{payload}   create_dictionary   current-pm-list=${null}
    ${sDatestring}=    Execute shell command on device     device=${r0}       command=date
    log to console    ${sDatestring}
    sleep  5
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8  
    log   ${resp_content}


Retrieve History Pm Detail Statistics 
    [Documentation]   Retrieve Detail history pm data 
    [Arguments]     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${pmInterval}
    ${r0} =     Get Handle      resource=device0
    Run keyword if    '${pmInterval}'=='15min'       Wait For Next Pm Bin
    ...         ELSE IF   '${pmInterval}'=='24Hour'   Jump To Next Day
    ...         ELSE        FAIL   no other types history pm can be checked
    ${hisPmName}=   RPC Collect Historical Pm     ${odl_sessions}   ${tv['device0__re0__mgt-ip']}     1   2   ${pmInterval}
    sleep  5
    ${sDatestring}=    Execute shell command on device     device=${r0}       command=date
    log   ${sDatestring}
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    ${cmd1}=     Execute shell command on device     device=${r0}     command=ls
    ${deffilelist}=     getdefaultOpenroamdfile   ${cmd1}
    List Should Contain Value     ${deffilelist}      ${hisPmName}
    Switch to superuser    device=${r0}
    Execute shell command on device     device=${r0}       command=who
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    Execute shell command on device     device=${r0}       command=gunzip ${hisPmName}
    ${gethisNamelem}    Evaluate       '${hisPmName}'.split(".")[0]   string
    log to console    ${gethisNamelem}
    ${pmstring}=    Execute shell command on device     device=${r0}       command=cat ${gethisNamelem}
    Set Suite Variable    ${pmstring}
    log     ${pmstring}
    [return]     ${pmstring}

Wait For Next Pm Bin   
    [Documentation]   Retrieve Current 15Min Bin completion time
    [Arguments]
    ${currentMin}=   Returns the given minute of current time   device0
    ${currentMin}=   Convert To Integer  ${currentMin}
    ${waiTime}=    run keyword if    14>=${currentMin}>=0    Evaluate   15-${currentMin}
    ...    ELSE IF  29>=${currentMin}>=15    evaluate   30-${currentMin}
    ...    ELSE IF  44>=${currentMin}>=30    evaluate   45-${currentMin}
    ...    ELSE IF  59>=${currentMin}>=45    evaluate   60-${currentMin}
    ...    ELSE    FAIL   
    log   ${waiTime}  
    sleep  ${waiTime} minutes 10s 
    log to console    remount device to controller
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}


Jump To Next Day 
    [Documentation]   Retrieve Current 15Min Bin completion time
    [Arguments]     
    &{payload}   create_dictionary   current-pm-list=${null}
    sleep  5
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8
    ${root}=                 Parse XML    ${resp_content}
    @{pmEntries}   Get Elements   ${root}   current-pm-entry
    ${currentTime}=  Get Element Text  @{pmEntries}[0]   retrieval-time
    log to console   ${currentTime}
    Set Suite Variable    ${currentTime}
    ${nextDay} =   Add Time To Date    ${currentTime}  24:01:00
    ${date1}=   Replace String   ${nextDay}   ${SPACE}  T
    ${formatnextDay}=   Replace String   ${date1}   .000  Z   
    RPC Set Current Datetime   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${formatnextDay}