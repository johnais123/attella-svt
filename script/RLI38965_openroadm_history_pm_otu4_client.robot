*** Settings ***
Documentation     This is Attella PM Scripts
...              Description  : RLI-38974: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : amypeng@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
...              jtms description           : Attella
...              RLI                        : 38974
...              MIN SUPPORT VERSION        : 19.1
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : Attella_OpenROADM
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
Library         Collections
Library         OperatingSystem
Library         String
Library         ExtendedRequestsLibrary
Library         DateTime
Library         XML    use_lxml=True
Resource        ../lib/restconf_oper.robot
Resource        ../lib/testSet.robot
Resource        ../lib/attella_keyword.robot

Suite Setup   Run Keywords
...              Toby Suite Setup
...              Testbed Init

Test Setup  Run Keywords
...              Toby Test Setup

Test Teardown  Run Keywords
...              Toby Test Teardown

Suite Teardown  Run Keywords
...              Toby Suite Teardown


*** Variables ***

@{auth}     admin    admin
${interval}  10
${timeout}   100
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
@{pmInterval}   15min    24Hour 
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      1 min 

*** Test Cases *** 
TC1    
    [Documentation]  Verify history 15min Near-end/Far-end OTU PM statistics on otu4 Client interface
    ...              RLI38965  5.12-1
    [Tags]            tc1  
    @{pmEntryParmater}       Create List     erroredBlockCount    nearEnd    rx 
    @{pmEntryParmater2}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmater5}       Create List     erroredBlockCount    farEnd    rx 
    @{pmEntryParmater6}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater7}       Create List     erroredSeconds    farEnd    rx
    @{pmEntryParmater8}       Create List      severelyErroredSeconds    farEnd    rx    
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}     ${pmEntryParmater4}    ${pmEntryParmater5}     ${pmEntryParmater6}     ${pmEntryParmater7}     ${pmEntryParmater8}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current   
    log   ${currentMin}
    sleep  5
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    6.3E-05
    sleep  5    
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8 
    sleep  5    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BEI     6.3E-05
    sleep  5
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BEI       
    Retrieve Current Statistics    
    @{curealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${client otu intf}   ${pmEntryParmaterlist}   @{pmInterval}[0]    
    log  ${curealpm}
    Retrieve Current Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[0]   
    @{realpm}=    Get History Spefic Pm Statistic   ${client otu intf}     ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${realpm}
    Lists Should Be Equal   ${curealpm}    ${realpm}
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]
   

TC2    
    [Documentation]  Verify history 15min Near-end/Far-end  ODU PM statistics on odu4 Client interface
    ...              RLI38965  5.12-3
    [Tags]            tc2  
    @{pmEntryParmater}       Create List     erroredBlockCount    nearEnd    rx 
    @{pmEntryParmater2}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmater5}       Create List     erroredBlockCount    farEnd    rx 
    @{pmEntryParmater6}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater7}       Create List     erroredSeconds    farEnd    rx
    @{pmEntryParmater8}       Create List      severelyErroredSeconds    farEnd    rx    
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}     ${pmEntryParmater4}    ${pmEntryParmater5}     ${pmEntryParmater6}     ${pmEntryParmater7}     ${pmEntryParmater8}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current   
    log   ${currentMin}
    sleep  5
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8    6.3E-05
    sleep  5    
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8 
    sleep  5    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI     6.3E-05
    sleep  5
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BEI       
    Retrieve Current Statistics    
    @{curealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${client intf}   ${pmEntryParmaterlist}   @{pmInterval}[0]    
    log  ${curealpm}
    Retrieve Current Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[0]   
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}     ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${realpm}
    Lists Should Be Equal   ${curealpm}    ${realpm}
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]




TC3    
    [Documentation]  Verify history 24Hour Near-end/Far-end OTU PM statistics on otu4 Client interface
    ...              RLI38965  5.12-2
    [Tags]             tc3  
    @{pmEntryParmater}       Create List     erroredBlockCount    nearEnd    rx 
    @{pmEntryParmater2}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmater5}       Create List     erroredBlockCount    farEnd    rx 
    @{pmEntryParmater6}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater7}       Create List     erroredSeconds    farEnd    rx
    @{pmEntryParmater8}       Create List      severelyErroredSeconds    farEnd    rx    
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}     ${pmEntryParmater4}    ${pmEntryParmater5}     ${pmEntryParmater6}     ${pmEntryParmater7}     ${pmEntryParmater8}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current   
    log   ${currentMin}
    sleep  5
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    6.3E-05
    sleep  5    
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8 
    sleep  5    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BEI     6.3E-05
    sleep  5
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BEI       
    Retrieve Current Statistics    
    @{curealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${client otu intf}   ${pmEntryParmaterlist}   @{pmInterval}[1]    
    log  ${curealpm}
    Retrieve Current Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[1]   
    @{realpm}=    Get History Spefic Pm Statistic   ${client otu intf}     ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[1]
    log  ${realpm}
    Lists Should Be Equal   ${curealpm}    ${realpm}
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]
   

TC4    
    [Documentation]  Verify history 24Hour Near-end/Far-end  ODU PM statistics on odu4 Client interface
    ...              RLI38965  5.12-4
    [Tags]           Sanity   tc4  
    @{pmEntryParmater}       Create List     erroredBlockCount    nearEnd    rx 
    @{pmEntryParmater2}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmater5}       Create List     erroredBlockCount    farEnd    rx 
    @{pmEntryParmater6}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater7}       Create List     erroredSeconds    farEnd    rx
    @{pmEntryParmater8}       Create List      severelyErroredSeconds    farEnd    rx    
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}    ${pmEntryParmater3}     ${pmEntryParmater4}    ${pmEntryParmater5}     ${pmEntryParmater6}     ${pmEntryParmater7}     ${pmEntryParmater8}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current   
    log   ${currentMin}
    sleep  5
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8    6.3E-05
    sleep  5    
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8 
    sleep  5    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI     6.3E-05
    sleep  5
    Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BEI       
    Retrieve Current Statistics    
    @{curealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${client intf}   ${pmEntryParmaterlist}   @{pmInterval}[1]    
    log  ${curealpm}
    Retrieve Current Statistics
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[1]   
    @{realpm}=    Get History Spefic Pm Statistic   ${client intf}     ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[1]
    log  ${realpm}
    Lists Should Be Equal   ${curealpm}    ${realpm}
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]

 
 

*** Keywords ***
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

`
Retrieve History Pm Detail Statistics 
    [Documentation]   Retrieve Detail history pm data 
    [Arguments]     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${pmInterval}
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
    [Arguments]    ${deviceName}=device0
    ${currentMin}=   Returns the given minute of current time   ${deviceName}
    ${currentMin}=   Convert To Integer  ${currentMin}
    ${waiTime}=    run keyword if   14>=${currentMin}>=0    Evaluate   15-${currentMin}
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

	Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
    
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


    #Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK

    Verify Client Interfaces In Traffic Chain Are Up

    
Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
    
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}


	Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    

    
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

	



