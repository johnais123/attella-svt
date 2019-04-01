*** Settings ***
Documentation     This is Attella alarm Scripts
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
@{INVALID_USER_NAMES}  te  abcdefghijklmnopqrstuvwxyz1234566  Tester  te/ster   test*er  tes@ter  test#er  1tester
@{INVALID_NON_ENCRPTED_PASSWORDS}  passwor  pass/word  passw|ord  pass?word  pass#word  pass@word  pa&ssword
...                                abcdefghijklmnopqrstuvwxyz1234abcdefghijklmnopqrstuvwxyz1234abcdefghijklmnopqrstuvwxyz1234abcdefghijklmnopqrstuvwxyz1234123456789                              

## encrpted for string 'pass@word' and string 'passwor'
@{INVALID_ENCRYPTED_PASSWORDS}  $6$02a8184e595c55b9$BIgoUHdeVfaJqNHv.CFP0g93a8O0y9xRSEXFd1IxjHLDTNWtqItBj.OJB2IwnnffdNaes1lLWBXe2WxPyH0Ho1   $6$673c059612b1daeb$UYEiyoCflZQJbBv6Lxqnhsy8JORvvlR5Ffno8CYFNSh27ZsmMKQ.yNu98s7EAKat7AlGyX5xDJPsXKP0AxbRl1

${VALID_USER_NAME}    tester123
${ANOTHER_VALID_USER_NAME}   tester1234

##encrpted for string 'password'
${VALID_ENCRPTED_PASSWORD}  $6$70868120a61c4775$Vv6hxUNoXbti.AtpeLV8mrHy5OSGKAf0bm1eNq7KIJ1CwFenmlIri4DIhSqX518fnDNlysZVAUK8hNOwU3qc00

##encrpted for string 'openroadm'
${NEW_VALID_ENCRPTED_PASSWORD}    $6$99c4dc65d35e062e$X4wNscNlawKmFMRt7MJa7diCjqQN3SyIHANdmWv7wVlabSI8mVHStmtl41A8cQDyPYTc34HOLpqA4mLK4Svgo.

@{auth}    admin    admin
${interval}  10
${timeout}   300

*** Test Cases ***     
Create new User with invalid username
    [Documentation]  Create new user with invalid username
    ...              RLI38968 
    [Tags]           tests
    Log             Create user with invalid username
    :FOR    ${username}    IN    @{INVALID_USER_NAMES}
    \        ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${username}    ${VALID_ENCRPTED_PASSWORD}    sudo
    \        Run Keyword If     ${resp.status_code}!=400     FAIL    The expected status code is 400, but it is ${resp.status_code}
    \        sleep    5s


Create new User with invalid non-encrypted password
    [Documentation]  Create new user with invalid non-encrpted password
    ...              RLI38968
    [Tags]           tests
    Log             Create user with invalid non-encrypted password
    :FOR    ${password}    IN    @{INVALID_NON_ENCRPTED_PASSWORDS}
    \        ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${VALID_USER_NAME}    ${password}    sudo
    \        Run Keyword If     ${resp.status_code}!=400     FAIL    The expected status code is 400, but it is ${resp.status_code}
    \        sleep    5s
    

Create new User with invalid encrypted password
    [Documentation]  Create new user with invalid encrypted password
    ...              RLI38968 
    [Tags]           tests
    Log             Create user with invalid encrypted password
    :FOR    ${password}    IN     @{INVALID_ENCRYPTED_PASSWORDS}
    \        ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${VALID_USER_NAME}    ${password}    sudo
    \        Run Keyword If     ${resp.status_code}!=400     FAIL    The expected status code is 400, but it is ${resp.status_code}
    \        sleep    5s

Create new User with valid username and password
    [Documentation]  Create new user with valid username and password
    ...              RLI38968 
    [Tags]           tests
    Log             Create user with valid username and password
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${ANOTHER_VALID_USER_NAME}    ${VALID_ENCRPTED_PASSWORD}    sudo
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}

Change new created user password
    [Documentation]  Change new created user password
    ...              RLI38968 
    [Tags]           tests
    Log             Change the passowrd for the new created user
    ${resp}      Change User Password    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${ANOTHER_VALID_USER_NAME}    ${NEW_VALID_ENCRPTED_PASSWORD}    
    log to console     ${resp.status_code}
    Run Keyword If     ${resp.status_code}!=200     FAIL    The expected status code is 204, but it is ${resp.status_code}

#Change user password
#    [Documentation]  Verify can retrieve all info leaves
#    ...              RLI38968 5.1-32
#    [Tags]           Sanity   tc17   tests
#    Log             Change current user password for node 
#    RPC Change Password    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    openroadm    $6$77ee214844a64bba$qZbg656uG5XHVvP3adQ5XvWusbOvZPGx3jaG.tYLaqQ8mmMe4quXYShI2S07OzDZmoua.PlJ76Y8f4yfmXcP20

    
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
