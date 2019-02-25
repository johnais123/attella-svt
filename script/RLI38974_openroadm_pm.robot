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


*** Test Cases ***     
Verify current 15min severely Errored Seconds pm statistics on line otu4 port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1  done
    @{pmParmater}       Create List     otu-0/1/3:0:0    severelyErroredSeconds   nearEnd    rx   15min 
    # @{pmParmater}       Create List     port-0/1/0   totalOpticalPowerInputAvg    nearEnd    rx   15min 
    # @{pmParmater}       Create List     port-0/1/3   totalOpticalPowerInput    nearEnd    rx    notApplicable
    ${realpm}=    Get current Spefic Pm Statistic    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    @{pmParmater}[0]   @{pmParmater}[1]  @{pmParmater}[2]   @{pmParmater}[3]   @{pmParmater}[4]
    log  ${realpm}
    # this expectValue we need testset or configure to produce it 
    @{expectValue}       Create List    535
    Verify Pm Statistic   ${expectValue}    ${realpm}


Verify current 15min total Optical Power InputAvg pm statistics on line port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-2
    [Tags]           Sanity   tc2  done
    @{pmParmater}       Create List     port-0/1/0   totalOpticalPowerInputAvg    nearEnd    rx   15min 
    ${realpm}=    Get current Spefic Pm Statistic    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    @{pmParmater}[0]   @{pmParmater}[1]  @{pmParmater}[2]   @{pmParmater}[3]   @{pmParmater}[4]
    log  ${realpm}
    # this expectValue we need testset or configure to produce it 
    @{expectValue}       Create List    -10  50
    Verify Pm Statistic   ${expectValue}    ${realpm}


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
