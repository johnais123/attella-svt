*** Settings ***
Documentation     This is Attella PM Scripts
...              Description  : RLI-38974: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : Barryzhang@juniper.net
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
${timeout}   300
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
@{pmInterval}   15min    24Hour 
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      5 min 

*** Test Cases *** 
Verify history pm 
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-1
    [Tags]           Sanity   h1   done
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   current 
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   1
    sleep  5  
    log   ${currentMin}
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[0]   ${currentMin}
    @{realpm}=    Get History Spefic Pm Statistic   ett-0/0/2     ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${realpm}
    @{expectValue}       Create List   160
    Verify Pm Statistic   ${expectValue}     @{realpm}[0]    equal
    @{expectNextValue}       Create List   1
    Verify Pm Statistic   ${expectNextValue}     @{realpm}[1]    equal
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0] 


TC1    
    [Documentation]  Verify current 15min Near-end  OTU erroredBlockCount PM statistics on otu4 Client interface
    [Tags]           Sanity   tc2  
    @{pmEntryParmater}       Create List     erroredBlockCount    nearEnd    rx 
    @{pmEntryParmater2}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    10
    sleep  5  
    log   ${currentMin}
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[0]    ${currentMin}
    @{realpm}=    Get History Spefic Pm Statistic    otu-0/0/6:0:0   ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${realpm}
    @{expectValue}       Create List   478
    Verify Pm Statistic   ${expectValue}     @{realpm}[0]    equal
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

TC2   
    [Documentation]  Verify current 15min Near-end  OTU backgroundBlockErrors PM statistics on otu4 Client interface
    [Tags]           Sanity   tc3   
    @{pmEntryParmater}       Create List     backgroundBlockErrors    nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    10
    sleep  5  
    log   ${currentMin}
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[0]   ${currentMin}
    @{realpm}=    Get History Spefic Pm Statistic    otu-0/0/6:0:0   ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${realpm}
    @{expectValue}       Create List   10
    Verify Pm Statistic   ${expectValue}     @{realpm}[0]    equal
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]


TC3   
    [Documentation]  Verify current 15min Near-end  OTU erroredSeconds PM statistics on otu4 Client interface
    [Tags]           Sanity   tc4  
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx   
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    10
    sleep  5  
    log   ${currentMin}
    ${hisPmString}=     Retrieve History Pm Detail Statistics   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   @{pmInterval}[0]   ${currentMin}
    @{realpm}=    Get History Spefic Pm Statistic    otu-0/0/6:0:0   ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    log  ${realpm}
    @{expectValue}       Create List   1
    Verify Pm Statistic   ${expectValue}     @{realpm}[0]    equal
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

TC4   
    [Documentation]  Verify current 15min Near-end  OTU erroredSeconds PM statistics on otu4 Client interface
    [Tags]           Sanity   tc5   
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx   
    ${currentMin}=    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    10
    sleep  5  
    log   ${currentMin}
    ${hisPmString}=     Retrieve History Pm Detail Statistics    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   @{pmInterval}[0]   ${currentMin}
    @{realpm}=    Get History Spefic Pm Statistic    otu-0/0/6:0:0   ${hisPmString}   ${pmEntryParmaterlist}    @{pmInterval}[0]
    @{expectValue}       Create List   1   10   10   0
    Lists Should Be Equal   ${realpm}    ${expectValue}
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]


*** Keywords ***
Testbed Init
    # Initialize
    log   retrieve system relate information via CLI
    ${r0} =     Get Handle      resource=device0
    Set Suite Variable    ${r0}
    @{dut_list}    create list    device0 
    Preconfiguration netconf feature    @{dut_list}
    Log To Console      create a restconf operational session   
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

    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
    # Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    # Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}

 	Log To Console  de-provision on both device0 and device1
    # Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	# Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}

    Log To Console  Load Pre Default Provision on both device0 and device1
	# Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    # Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
    
    Log To Console  inital test set 
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}

    # @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    # ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    # Set Suite Variable    ${testSetHandle2}
         
    # Init Test Equipment  ${testSetHandle1}  100ge
    # Init Test Equipment  ${testSetHandle2}  100ge

    Log To Console  Provide 100ge/otu4 traffic service
    # ${client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    # Set Suite Variable    ${client intf}
    
    # ${remote client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    # Set Suite Variable    ${remote client intf}

    # ${client intf}       Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    # {client otu intf}   Get OTU Intface Name From ODU Intface  ${client intf}
   # ${line odu intf}     Get Line ODU Intface Name From Client Intface  ${client intf}
   # ${line otu intf}     Get OTU Intface Name From ODU Intface  ${line odu intf}
   # ${line och intf}     Get OCH Intface Name From OTU Intface  ${line otu intf}
   # ${line transc port}   Evaluate    '${line och intf}'.replace("och","port")   string
   # log    ${line transc port}
   # ${line transc port}   Evaluate    '${line transc port}'.split(":")[0]        string
   # log    ${line transc port}
   # Set Suite Variable    ${client intf}
   # # Set Suite Variable    ${client otu intf}
   # Set Suite Variable    ${line odu intf}
   # Set Suite Variable    ${line otu intf}
   # Set Suite Variable    ${line och intf}
   # Set Suite Variable    ${line transc port}

   # ${remote client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
   # ${remote line odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
   # ${remote line otu intf}=  Get OTU Intface Name From ODU Intface  ${remote line odu intf}
   # ${remote line och intf}=  Get OCH Intface Name From OTU Intface  ${remote line otu intf}
   # Set Suite Variable    ${remote client intf}
   # Set Suite Variable    ${remote line odu intf}
   # Set Suite Variable    ${remote line otu intf}
   # Set Suite Variable    ${remote line och intf}

    # Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
    
    # Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}

    # Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  qpsk
    
    # Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  qpsk

    # Log To Console   Verify traffic won't lost packet and no alarm in system
# 
    # Wait Until Interfaces In Traffic Chain Are Alarm Free
    # 
    # Verify Client Interfaces In Traffic Chain Are Up
    # 
    # ${random}=  Evaluate  random.randint(1, 60)  modules=random
    # Sleep  ${random}
# 
    # Verify Interfaces In Traffic Chain Are Alarm Free
# 
    # Verify Traffic Is OK


Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    # Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    # Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${OPER_STATUS_ON}
    # Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${OPER_STATUS_ON}
    # Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${OPER_STATUS_ON}


Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}
    # Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}
    # Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}


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
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}


 Retrieve History Pm Detail Statistics 
    [Documentation]   Retrieve Detail history pm data 
    [Arguments]     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${pmInterval}   ${currentMin}
    Run keyword if    '${pmInterval}'=='15min'    Run Keywords    Wait For Next Pm Bin    ${currentMin}
    ...         ELSE IF   '${pmInterval}'=='24Hour'   Run Keywords    Change To Next Day
    ...         ELSE        FAIL   no other types history pm can be checked
    ${hisPmName}=   RPC Collect Historical Pm     ${odl_sessions}   ${tv['device0__re0__mgt-ip']}     1   2   ${pmInterval}
    sleep  15
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    ${cmd1}=     Execute shell command on device     device=${r0}     command=ls
    ${deffilelist}=     getdefaultOpenroamdfile   ${cmd1}
    List Should Contain Value     ${deffilelist}      ${hisPmName}
    Switch to superuser    device=${r0}
    Execute shell command on device     device=${r0}       command=who
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    Execute shell command on device     device=${r0}       command=gunzip ${hisPmName}
    ${gethisNamelem}    Evaluate       '${hisPmName}'.split(".")[0]   string
    ${pmstring}=    Execute shell command on device     device=${r0}       command=cat ${gethisNamelem}
    Set Suite Variable    ${pmstring}
    log     ${pmstring}
    [return]     ${pmstring}

# Retrieve Current 15Min Bin Finish Time    
#     [Documentation]   Retrieve Current 15Min Bin completion time
#     [Arguments]    ${currentMin}
#     ${endTime}	run keyword if	14>=${currentMin}>=0    set variable    14:59
#     ...     ELSE IF    29>=${currentMin}>=15   set variable    29:59
#     ...     ELSE IF    44>=${currentMin}>=30    set variable    44:59
#     ...     ELSE IF    59>=${currentMin}>=45   set variable    59:59
#     ...     ELSE       FAIL  
#     [return]     ${endTime}    


Wait For Next Pm Bin   
    [Documentation]   Retrieve Current 15Min Bin completion time
    [Arguments]    ${currentMin}
    ${waiTime}=    run keyword if	14>=${currentMin}>=0    Evaluate   15-${currentMin}
    ...    ELSE IF  29>=${currentMin}>=15    evaluate   30-${currentMin}
    ...    ELSE IF  44>=${currentMin}>=30    evaluate   45-${currentMin}
    ...    ELSE IF  59>=${currentMin}>=45    evaluate   60-${currentMin}
    ...    ELSE    FAIL   
    log   ${waiTime}  
    sleep  ${waiTime} minutes 10s 
    log to console    remount device to controller
    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}


Change To Next Day 
    [Documentation]   Retrieve Current 15Min Bin completion time
    [Arguments]     
    &{payload}   create_dictionary   current-pm-list=${null}
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}   ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8
    ${root}=                 Parse XML    ${resp_content}
    @{pmEntries}   Get Elements   ${root}   current-pm-entry
    ${currentTime}=  Get Element Text  @{pmEntries}[0]   retrieval-time
    log to console   ${currentTime}
    ${nextDay} =   Add Time To Date    ${currentTime}  24:01:00
    ${date1}=   Replace String   ${nextDay}   ${SPACE}  T
    ${formatnextDay}=   Replace String   ${date1}   .000  Z   