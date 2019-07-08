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
    [Tags]  Sanity    tc0
    Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    Log To Console  Verify Traffic
    Verify Traffic Is OK


TC1
    [Documentation]  Verify PM Statistics no increase during traffic ok
    ...              RLI38964  5.9-2  5.9-3 
    [Tags]  Sanity  tc1
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    log   ${currentMin}

    Log To Console    Verify PM Statistics no increase during traffic ok
    @{pmEntryParmaterlist}       Create List   
    @{current15mrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${current15mrealpm}
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  

    @{current24hrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]
    log  ${current24hrealpm}
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]  


TC2
    [Documentation]  Verify current 15min PM BIPErrorCounter rx and erroredSecondsEthernet rx
    ...              RLI38964 5.7-2 5.7-3
    [Tags]           Sanity   tc2 
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 

    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    Log To Console  inject BIP error
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   1
    Sleep   10
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]

    log  ${realpm}
    @{expectValue}       Create List   20
    Verify Pm Should Be Equals  @{expectValue}[0]     @{realpm}[0]  

    @{expectNextValue}       Create List   1
    Verify Pm Should Be Equals  @{expectNextValue}[0]     @{realpm}[1]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  
    

TC3
    [Documentation]  Verify current 15min PM BIPErrorCounter tx and erroredSecondsEthernet tx
    ...              RLI38964 5.7-6 5.7-7
    [Tags]           Advance   tc3
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    tx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 

    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    
    Log To Console  inject BIP error
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   1
    Sleep   5
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]

    log  ${realpm}
    @{expectValue}       Create List   20
    Verify Pm Should Be Equals  @{expectValue}[0]     @{realpm}[0]  

    @{expectNextValue}       Create List   1
    Verify Pm Should Be Equals  @{expectNextValue}[0]     @{realpm}[1]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]
    

TC4
    [Documentation]  Verify current 15min PM severelyErroredSecondsEthernet rx
    ...              RLI38964 5.7-4
    [Tags]           Sanity   tc4
    @{pmEntryParmater}       Create List     severelyErroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}

    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    Log To Console  off near-end test set laser
    Set Laser State  ${testSetHandle1}  OFF
    Sleep   10
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]

    Sleep   10
    @{nextrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]

    log  ${realpm}
    Verify Pm Should Be Increased  @{nextrealpm}[0]     @{realpm}[0]  
    [Teardown]  Set Laser State  ${testSetHandle1}  ON


TC5
    [Documentation]  Verify current 15min PM severelyErroredSecondsEthernet tx
    ...              RLI38964 5.7-8
    [Tags]           Advance  tc5
    @{pmEntryParmater}       Create List     severelyErroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}

    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    Log To Console  off near-end test set laser
    Set Laser State  ${testSetHandle2}  OFF
    Sleep   10
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]

    Sleep   10
    @{nextrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]

    log  ${realpm}
    Verify Pm Should Be Increased  @{nextrealpm}[0]     @{realpm}[0]  
    [Teardown]  Set Laser State  ${testSetHandle2}  ON


TC6
    [Documentation]  Verify current 24Hour PM BIPErrorCounter rx and erroredSecondsEthernet rx
    ...              RLI38964 5.7-2 5.7-3 
    [Tags]           Sanity  tc6
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 

    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    Log To Console  inject BIP error
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   1
    Sleep   10
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]

    log  ${realpm}
    @{expectValue}       Create List   20
    Verify Pm Should Be Equals  @{expectValue}[0]     @{realpm}[0]  

    @{expectNextValue}       Create List   1
    Verify Pm Should Be Equals  @{expectNextValue}[0]     @{realpm}[1]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]
    

TC7
    [Documentation]  Verify current 24Hour PM BIPErrorCounter tx and erroredSecondsEthernet tx
    ...              RLI38964 5.7-6 5.7-7
    [Tags]           Advance  tc7
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    tx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    tx 
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    
    Log To Console  inject BIP error
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   1
    Sleep   5
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]

    log  ${realpm}
    @{expectValue}       Create List   20
    Verify Pm Should Be Equals  @{expectValue}[0]     @{realpm}[0]  

    @{expectNextValue}       Create List   1
    Verify Pm Should Be Equals  @{expectNextValue}[0]     @{realpm}[1]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]
    

TC8
    [Documentation]  Verify current 24Hour PM severelyErroredSecondsEthernet rx
    ...              RLI38964 5.7-4
    [Tags]           Sanity  tc8
    @{pmEntryParmater}       Create List     severelyErroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}

    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    Log To Console  off near-end test set laser
    Set Laser State  ${testSetHandle1}  OFF
    Sleep   10
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]

    Sleep   10
    @{nextrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]

    log  ${realpm}
    Verify Pm Should Be Increased  @{nextrealpm}[0]     @{realpm}[0]    
    [Teardown]  Set Laser State  ${testSetHandle1}  ON


TC9
    [Documentation]  Verify current 24Hour PM severelyErroredSecondsEthernet tx
    ...              RLI38964 5.7-8
    [Tags]           Advance   tc9
    @{pmEntryParmater}       Create List     severelyErroredSecondsEthernet    nearEnd    tx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}

    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    current 
    Log To Console  off near-end test set laser
    Set Laser State  ${testSetHandle2}  OFF
    Sleep   10
    
    @{realpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]

    Sleep   10
    @{nextrealpm}=    Get Current Spefic Pm Statistic  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]

    log  ${realpm}
    Verify Pm Should Be Increased  @{nextrealpm}[0]     @{realpm}[0]   
    [Teardown]  Set Laser State  ${testSetHandle2}  ON

TC10
    [Documentation]  Verify History 15min 100ge PM
    ...              RLI38964
    [Tags]           Sanity  tc10
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
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   5
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

    Log To Console    Retrieve History PM Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  @{pmInterval}[0]    
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}  ${hisPmString}  ${pmEntryParmaterlist}  @{pmInterval}[0]
    log  ${realpm}

    Lists Should Be Equal   ${currentrealpm}    ${realpm}


TC11
    [Documentation]  Verify History 24Hour 100ge PM
    ...              RLI38964
    [Tags]           Advance    tc11 
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
    Start Inject Error On Test Equipment  ${testSetHandle2}   ERROR_ETHERNET_PCS_PCSBIP8   5
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

    Log To Console    Retrieve History PM Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  @{pmInterval}[1]
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}  ${hisPmString}  ${pmEntryParmaterlist}  @{pmInterval}[1]
    log  ${realpm}

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


Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
    Remove 100GE Service   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Remove 100GE Service   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}


Retrieve Current Statistics
    [Documentation]   Retrieve Detail history pm data 
    ${r0} =     Get Handle      resource=device0
    &{payload}   create_dictionary   current-pm-list=${null}
    ${sDatestring}=    Execute shell command on device     device=${r0}       command=date
    log to console    ${sDatestring}
    Wait For  5
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
    Wait For  5
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
    Wait For  5
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
