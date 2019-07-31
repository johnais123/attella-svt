*** Settings ***
Documentation     This is Attella set device date and time testing
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : vzheng@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
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
${NEW_DATE_TIME}    

@{auth}    admin    admin
${interval}  10
${timeout}   300

*** Test Cases ***     
TC1
    [Documentation]  set device date and time and check info, alarm, pm
    ...              RLI38963-1 5.7-1
    [Tags]           Advance    tests
    Log             set device date and time and check info, alarm, pm
    Log to console    retrieve current time and remember it
    &{result}     Get Device Info    ${odl_sessions}     ${tv['device0__re0__mgt-ip']} 
    ${old_time}       Get From Dictionary	${result}    current-datetime 
    Log to Console     ${old_time}
    
    Log to console    change to new time
    RPC Set Current Datetime     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    2018-04-05T19:31:14Z
    Wait For   5s
    &{new_result}     Get Device Info    ${odl_sessions}     ${tv['device0__re0__mgt-ip']} 
    ${new_time}       Get From Dictionary	${new_result}    current-datetime
    Log to Console     ${new_time}
    
    #to do:
    #Check PMs retrieval-time change to new time datetime
    #Check new create alarm timestamp change to new time date time

    Log to Console    restore to old time
    RPC Set Current Datetime     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${old_time}
    Wait For   5s
    &{new_result}     Get Device Info    ${odl_sessions}     ${tv['device0__re0__mgt-ip']} 
    ${new_time}       Get From Dictionary	${new_result}    current-datetime
    Log to Console      ${new_time}
    
    

*** Keywords ***
Testbed Init
    # Initialize
    log   retrieve system relate information via CLI
    Get System Info
    
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
    
    @{odl_sessions}    create list   ${opr_session}    ${cfg_session}     ${rpc_session}
    Set Suite Variable    ${odl_sessions}
    Run Keyword And Ignore Error    Delete All Users    ${odl_sessions}    ${tv['device0__re0__mgt-ip']} 

Get System Info
    ${r0} =     Get Handle      resource=device0
    ${label} =  Execute cli command on device    device=${r0}    command=show version   format=xml
    ${version} =  Get Element   ${label}   software-information/junos-version
    Log    ${version.text}
    ${version_info}  set variable   ${version.text}
    #${label} =  Execute cli command on device    device=${r0}    command=show interfaces mgmtre0   format=xml
    #${macadd} =  Get Element   ${label}   interface-information/physical-interface/hardware-physical-address
    #${macadd_info}   set variable   ${macadd.text}
    ${label} =  Execute cli command on device    device=${r0}    command=show chassis hardware  format=xml
    ${serNu} =  Get Element   ${label}   chassis-inventory/chassis/serial-number
    ${serNu_info}   set variable   ${serNu.text}
    Set Suite Variable   ${version_info}
    # Set Suite Variable   ${macadd_info} 
    Set Suite Variable   ${serNu_info}
    @{dut_list}    create list    device0 
    Preconfiguration netconf feature    @{dut_list}
