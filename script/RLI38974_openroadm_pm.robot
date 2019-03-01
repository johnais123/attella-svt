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
...              Testbed Init

Test Setup  Run Keywords
...              Toby Test Setup

Test Teardown  Run Keywords
...              Toby Test Teardown

Suite Teardown  Run Keywords
...              Toby Suite Teardown


*** Variables ***

@{auth}     admin    admin
${interval}  120
${timeout}   120
@{pmInterval}   15min    24Hour 

*** Test Cases ***     
Verify current 15min severely Errored Seconds pm statistics on line otu4 port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1  done
    ${pmEntryRes}       set variable      otu-0/1/1:0:0
    @{pmEntryParmater}       Create List     severelyErroredSeconds    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSeconds    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Get Current All Pm Entry On Target Resource    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${pmEntryRes}    ${pmEntryParmaterlist}   ${ignorePmEntryParmater}
    @{realpm}=    Get current Spefic Pm Statistic   @{pmInterval}[0]
    log   ${realpm}
    log   ${retriTimes}
    # this expectValue we need testset or configure to produce it 
    @{expectValue}       Create List   0  1000
    Verify Pm Statistic   ${expectValue}     @{realpm}[0]      in-range 
    @{expectNextValue}       Create List    0  1000    
    Verify Pm Statistic   ${expectNextValue}    @{realpm}[1]    in-range 
    Verify others Pm Statistic shoule not be changed   ${pmInterval} 


Verify current 15min total BIPErrorCounter pm statistics on Client port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-2
    [Tags]           Sanity   tc2  done
    ${pmEntryRes}       set variable      ett-0/0/2
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    tx 
    # @{pmParmater}       Create List     port-0/1/3   totalOpticalPowerInput    nearEnd    rx    notApplicable
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater} 
    Get Current All Pm Entry On Target Resource    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${pmEntryRes}    ${pmEntryParmaterlist} 
    @{realpm}=    Get current Spefic Pm Statistic   @{pmInterval}[0] 
    log  ${realpm}
    @{expectValue}       Create List   0
    Verify Pm Statistic   ${expectValue}     @{realpm}[0]    equal
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0] 


Verify current 15min backgroundBlockErrors pm statistics on line odu4 port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-2
    [Tags]           Sanity   tc3  done
    ${pmEntryRes}       set variable      odu-0/1/1:0:0:0
    @{pmEntryParmater}       Create List     backgroundBlockErrors    nearEnd    rx 
    # @{pmParmater}       Create List     port-0/1/3   totalOpticalPowerInput    nearEnd    rx    notApplicable
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater} 
    Get Current All Pm Entry On Target Resource    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${pmEntryRes}    ${pmEntryParmaterlist} 
    @{realpm}=    Get current Spefic Pm Statistic   @{pmInterval}[0]  
    log  ${realpm}
    Get Current All Pm Entry On Target Resource    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${pmEntryRes}    ${pmEntryParmaterlist} 
    @{nextrealpm}=    Get current Spefic Pm Statistic   ${pmInterval} 
    Verify Pm Statistic   ${nextrealpm}     @{realpm}[0]    increasing
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  


Verify current 15min total BIPErrorCounter pm statistics on Client port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-2
    [Tags]           Sanity   tc4  done
    ${pmEntryRes}       set variable      ett-0/0/2
    @{pmEntryParmater}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmater2}       Create List     erroredSecondsEthernet    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    RPC Clear Pm Statistics   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   current   @{pmInterval}[0]
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   2
    Sleep   5
    Get Current All Pm Entry On Target Resource    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${pmEntryRes}    ${pmEntryParmaterlist} 
    @{realpm}=    Get current Spefic Pm Statistic   @{pmInterval}[0]
    log  ${realpm}
    @{expectValue}       Create List   40
    Verify Pm Statistic   ${expectValue}     @{realpm}[0]    equal
    @{expectNextValue}       Create List   1
    Verify Pm Statistic   ${expectNextValue}     @{realpm}[1]    equal
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
    
    # Mount vAttella On ODL Controller    ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    # sleep   15s 
    # Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}

    @{testEquipmentInfo}=  create list    EXFO    172.27.93.131  5
    ${testSetHandle1}=  Get Test Equipment Handle   ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
    @{testEquipmentInfo}=  create list    EXFO    172.27.93.131  3
    ${testSetHandle2}=  Get Test Equipment Handle   ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}