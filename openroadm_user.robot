*** Settings ***
Documentation     This is Attella User Mgmt Scripts
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


Resource    jnpr/toby/Master.robot
Library         BuiltIn
Library         String
Library         Collections
Library         OperatingSystem
Library         ExtendedRequestsLibrary
Library         XML    use_lxml=True
Resource        lib/restconf_oper.robot
Resource        lib/attella_keyword.robot


Suite Setup   Run Keywords
...              Toby Suite Setup
...              Testbed Init

Test Setup  Run Keywords
...              Toby Test Setup

Test Teardown  Run Keywords
...              Toby Test Teardown

Suite Teardown  Run Keywords
...              Testbed Teardown
...              Toby Suite Teardown


*** Variables ***
@{INVALID_USER_NAMES}  te  abcdefghijklmnopqrstuvwxyz1234566  Tester  te/ster   test*er  tes@ter  test#er  1tester
@{INVALID_NON_ENCRYPTED_PASSWORDS}  passwor  pass/word  passw|ord  pass?word  pass#word  pass@word  pa&ssword
...                                abcdefghijklmnopqrstuvwxyz1234abcdefghijklmnopqrstuvwxyz1234abcdefghijklmnopqrstuvwxyz1234abcdefghijklmnopqrstuvwxyz1234123456789                              

## encrypted for string 'pass@word' and string 'passwor'
@{INVALID_ENCRYPTED_PASSWORDS}  $6$02a8184e595c55b9$BIgoUHdeVfaJqNHv.CFP0g93a8O0y9xRSEXFd1IxjHLDTNWtqItBj.OJB2IwnnffdNaes1lLWBXe2WxPyH0Ho1   $6$673c059612b1daeb$UYEiyoCflZQJbBv6Lxqnhsy8JORvvlR5Ffno8CYFNSh27ZsmMKQ.yNu98s7EAKat7AlGyX5xDJPsXKP0AxbRl1

${VALID_USER_NAME}    tester123
${ANOTHER_VALID_USER_NAME}   tester1234

##encrypted for string 'password'
${VALID_ENCRYPTED_PASSWORD}  $6$70868120a61c4775$Vv6hxUNoXbti.AtpeLV8mrHy5OSGKAf0bm1eNq7KIJ1CwFenmlIri4DIhSqX518fnDNlysZVAUK8hNOwU3qc00

##encrypted for string 'openroadm'
${NEW_VALID_ENCRYPTED_PASSWORD}    $6$99c4dc65d35e062e$X4wNscNlawKmFMRt7MJa7diCjqQN3SyIHANdmWv7wVlabSI8mVHStmtl41A8cQDyPYTc34HOLpqA4mLK4Svgo.

@{auth}    admin    admin
${interval}  10
${timeout}   300

${plain_text_password}    openroadm123!
${new_plain_text_password}    vincentzhang123!

*** Test Cases ***     
TC1
    [Documentation]  Create new user with invalid username
    ...              Mapping JTMS RLI-38963 TC 5.6-2
    [Tags]           Advance    tests13
    Log              Create user with invalid username
    :FOR    ${username}    IN    @{INVALID_USER_NAMES}
    \        ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${username}    ${plain_text_password}    sudo
    \        Run Keyword If     ${resp.status_code}!=400     FAIL    The expected status code is 400, but it is ${resp.status_code}
    \        Wait For    5s


TC2
    [Documentation]  Create new user with invalid non-encrypted password
    ...              Mapping JTMS RLI-38963 TC 5.6-2
    [Tags]           Advance    tests13
    Log              Create user with invalid non-encrypted password
    :FOR    ${password}    IN    @{INVALID_NON_ENCRYPTED_PASSWORDS}
    \        ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${VALID_USER_NAME}    ${password}    sudo
    \        Run Keyword If     ${resp.status_code}!=400     FAIL    The expected status code is 400, but it is ${resp.status_code}
    \        Wait For    5s


TC3
    [Documentation]  Create new user with valid username and password
    ...              Mapping JTMS RLI-38963 TC 5.6-1
    [Tags]           Advance    tests13
    Log              Create user with valid username and password
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${ANOTHER_VALID_USER_NAME}    ${plain_text_password}    sudo
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}


TC4
    [Documentation]  Change new created user password
    ...              Mapping JTMS RLI-38963 TC 5.6-7
    [Tags]           Advance    tests13
    Log              Change the passowrd for the new created user
    ${resp}      Change User Password    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${ANOTHER_VALID_USER_NAME}    ${new_plain_text_password}    
    Run Keyword If     ${resp.status_code}!=200     FAIL    The expected status code is 204, but it is ${resp.status_code}

    
TC5
    [Documentation]  Create a new user in openroadm but existed in os
    ...              RLI-38963 5.6-1
    [Tags]           Sanity    tests13
    Log             Create a new user in openroadm but existed in os
    ${random_user}   Generate Random String	8	[LOWER]
    Log     Use Cli to create user ${random_user}
    ${r0} =     Get Handle      resource=device0
    @{cmd_list}    Create List    
    ...            set system login user ${random_user} class super-user authentication encrypted-password ${VALID_ENCRYPTED_PASSWORD}  
    Execute config Command On Device     ${r0}    command_list=@{cmd_list}    commit=${TRUE}   detail=${TRUE}   timeout=${600}
    Wait For    10s
    Log             Use ODL to create same user ${random_user} in openroadm
        
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log     ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}

    Wait For    2s
    Log    Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Run Keyword If     ${result}!=${TRUE}     FAIL    User ${random_user} should be in openroadm after provisioning
    Log    ${result}
   
    [Teardown]    Run Keywords    
    ...           Log    Delete openroadm user     
    ...           AND    Delete User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user}     


TC6
    [Documentation]  Create a new user in openroadm but existed in os
    ...              RLI-38963 5.6-2
    [Tags]           Advance    tests13
    Log             Create a new user in openroadm but existed in os
    ${random_user}   Generate Random String	8	[LOWER]
    Log     Use Cli to create user ${random_user}
    ${r0} =     Get Handle      resource=device0
    @{cmd_list}    Create List    
    ...            set system login user ${random_user} class super-user authentication encrypted-password ${VALID_ENCRYPTED_PASSWORD}                    
    Execute config Command On Device     ${r0}    command_list=@{cmd_list}    commit=${TRUE}   detail=${TRUE}   timeout=${600}
    Wait For    10s
    Log             Use ODL to create same user ${random_user} in openroadm
    
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log     ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}
    
    Wait For    2s
    Log    Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Run Keyword If     ${result}!=${TRUE}     FAIL    User ${random_user} should be in openroadm after provisioning
    Log    ${result}
    
    Log    Delete openroadm user 
    ${result}    Delete User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log    ${result}


TC7
    [Documentation]  Create a new user in openroadm but existed in os
    ...              RLI-38963 5.6-3
    [Tags]           Advance    tests13
    Log             Create a new user in openroadm but existed in os
    ${random_user}   Generate Random String	8	[LOWER]
    Log     Use Cli to create user ${random_user}
    ${r0} =     Get Handle      resource=device0
    @{cmd_list}    Create List    
    ...            delete system login user ${random_user}    
    Execute config Command On Device     ${r0}    command_list=@{cmd_list}    commit=${TRUE}   detail=${TRUE}   
    Wait For    10s
    Log             Use ODL to create same user ${random_user} in openroadm
    
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log     ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}

    Wait For    2s
    Log    Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log    ${result}
    Run Keyword If     ${result}!=${TRUE}     FAIL    User ${random_user} should be in openroadm after provisioning
    
    Log   create it again
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log     ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=409     FAIL    The expected status code is 409:Conflict, but it is ${resp.status_code}

    Log    Delete openroadm user 
    ${result}    Delete User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log    ${result}


TC8
    [Documentation]  Create a new user in openroadm but existed in os
    ...              RLI-38963 5.6-4
    [Tags]           Advance    tests13
    Log             Create a new user in openroadm but existed in os
    ${random_user}   Generate Random String	8	[LOWER]
    Log     Use Cli to create user ${random_user}
    ${r0} =     Get Handle      resource=device0
    @{cmd_list}    Create List    
    ...            set system login user ${random_user} class super-user authentication encrypted-password ${VALID_ENCRYPTED_PASSWORD}                    
    Execute config Command On Device     ${r0}    command_list=@{cmd_list}    commit=${TRUE}   detail=${TRUE}   timeout=${600}
    Wait For    10s
    Log             Use ODL to create same user ${random_user} in openroadm
    
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log    ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}
    
    Wait For    2s
    Log    Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Run Keyword If     ${result}!=${TRUE}     FAIL    User ${random_user} should be in openroadm after provisioning
    Log    ${result}
    
    #provision it again.
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log     ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=409    FAIL    The expected status code is 409, but it is ${resp.status_code}
        
    [Teardown]    Run Keywords    
    ...           Log    Delete openroadm user     
    ...           AND    Delete User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user}       


TC9
    [Documentation]  Delete an existing user
    ...              RLI-38963 5.6-5
    [Tags]           Advance    tests13
    ${random_user}   Generate Random String    8	[LOWER]
    Log    Use ODL to create user ${random_user} in openroadm
    
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log     ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}
    
    Wait For    10s
    Log    Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log     ${result}
    Run Keyword If     ${result}!=${TRUE}     FAIL    User ${random_user} should be provisioned in openroadm after provisioning

    Log   Delete openroadm user ${random_user} 
    ${result}    Delete User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log     ${result}    

    Wait For    5s
    Log     Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log     ${result}
    Run Keyword If     ${result}!=${FALSE}     FAIL    User ${random_user} should not be in openroadm after deprovisioning


TC10
    [Documentation]  Delete an inexisting user
    ...              RLI-38963 5.6-6
    [Tags]           Advance    tests13
    ${random_user}   Generate Random String    8	[LOWER]
    Log             Use ODL to create user ${random_user} in openroadm
    
    ${resp}      Create New User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_user}    ${VALID_ENCRYPTED_PASSWORD}    sudo
    Log     ${resp.status_code} 
    Run Keyword If     ${resp.status_code}!=204     FAIL    The expected status code is 204, but it is ${resp.status_code}

    Wait For    10s
    Log   Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log     ${result}
    Run Keyword If     ${result}!=${TRUE}     FAIL    User ${random_user} should be provisioned in openroadm after provisioning
    
    Log   Delete openroadm user ${random_user} 
    ${result}    Delete User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user}
    Log     ${result}
    Run Keyword If     ${result.status_code}!=200    FAIL    User ${random_user} should be deprovisioned by odl    

    Wait For    2s
    Log    Check user ${random_user} in openroadm configuration
    ${result}    Check User In Openroadm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log     ${result}
    Run Keyword If     ${result}!=${FALSE}     FAIL    User ${random_user} should not be in openroadm after deprovisioning

    Log   Delete this inexsitent openroadm user ${random_user} 
    ${result}    Delete User    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}     ${random_user} 
    Log     ${result.status_code}    


TC11
    [Documentation]  Use RPC to change the current user password(user used by ODL to manage the device)
    ...              RLI-38963-1 5.6-7 
    [Tags]           Sanity    tests123
    Log             Change current user password  
    ${r0} =     Get Handle      resource=device0
    @{cmd_list}    Create List    
    ...            set system login user openroadm authentication encrypted-password ${NEW_VALID_ENCRYPTED_PASSWORD} 
    
    Log    Change the openroadm user password from 'openroadm' to 'password'
    #${resp}    RPC Command For Password Change    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${NEW_VALID_ENCRYPTED_PASSWORD}    ${VALID_ENCRYPTED_PASSWORD}    ${VALID_ENCRYPTED_PASSWORD}
    ${resp}    RPC Command For Password Change    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${new_plain_text_password}    ${plain_text_password}    ${plain_text_password}
    
    Log    ${resp}
    Run Keyword If     ${resp.status_code}!=200     FAIL    The expected status code is 200, but it is ${resp.status_code}
    
    #Wait For    120s
    #Log    Check user openroadm can log into with new password by netconf 
    #${device-handle}=  Connect to device   host=${tv['device0__re0__mgt-ip']}   user=openroadm    password=password    

    [Teardown]    Run Keywords    
    ...           Log    Restore openroadm user password to 'openroadm'    
    ...           AND    Execute config Command On Device     ${r0}    command_list=@{cmd_list}    commit=${TRUE}   detail=${TRUE}      
    ...           AND    Wait For    120s   


TC12
    [Documentation]  Use RPC to change the current user password(user used by ODL to manage the device)
    ...              RLI-38963-1 5.6-8 
    [Tags]           Advance     tests123
    Log             Change current user password with wrong currentPassword  
    ${random_password}   Generate Random String	8	[LOWER]
    ${r0} =     Get Handle      resource=device0
    @{cmd_list}    Create List    
    ...            set system login user openroadm authentication encrypted-password ${NEW_VALID_ENCRYPTED_PASSWORD} 
    
    Log    Change the openroadm user password from 'openroadm' to 'password' but with wrong currentPasword in the command
    #${resp}    RPC Command For Password Change    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_password}    ${VALID_ENCRYPTED_PASSWORD}    ${VALID_ENCRYPTED_PASSWORD}
    ${resp}    RPC Command For Password Change    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${random_password}    ${plain_text_password}    ${plain_text_password}
    Log    ${resp.status_code}
    Log    ${resp.text}
    Run Keyword If     ${resp.status_code}!=200     FAIL    The expected status code is 200, but it is ${resp.status_code}     
    
    [Teardown]    Run Keywords    
    ...           Log    Restore openroadm user password to 'openroadm'    
    ...           AND    Execute config Command On Device     ${r0}    command_list=@{cmd_list}    commit=${TRUE}   detail=${TRUE}      
    ...           AND    Wait For    120s 


TC13
    [Documentation]  Use RPC to change the current user password(user used by ODL to manage the device)
    ...              RLI-38963-1 5.6-9 
    [Tags]           Sanity    tests123
    Log             Change current user password with wrong newPasswordConfirm  
    ${random_password}   Generate Random String	8	[LOWER]
    ${r0} =     Get Handle      resource=device0
    @{cmd_list}    Create List    
    ...            set system login user openroadm authentication encrypted-password ${NEW_VALID_ENCRYPTED_PASSWORD} 
    
    Log    Change the openroadm user password from 'openroadm' to 'password' but with wrong currentPasword in the command
    Log    Using ${random_password} as the newpasswordConfirm
    #${resp}    RPC Command For Password Change    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${NEW_VALID_ENCRYPTED_PASSWORD}    ${VALID_ENCRYPTED_PASSWORD}    ${random_password}
    ${resp}    RPC Command For Password Change    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${new_plain_text_password}    ${plain_text_password}    ${random_password}
    Log    ${resp.status_code}
    Log    ${resp.text}
    Run Keyword If     ${resp.status_code}!=200     FAIL    The expected status code is 200, but it is ${resp.status_code}
           
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == 'Failed'     Log    the status display correct is Successful
    ...         ELSE    FAIL    Expect status is Failed, but get ${elem}
      
    [Teardown]    Run Keywords    
    ...           Log    Restore openroadm user password to 'openroadm'    
    ...           AND    Execute config Command On Device     ${r0}    command_list=@{cmd_list}    commit=${TRUE}   detail=${TRUE}      
    ...           AND    Wait For    20s 


    
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


Testbed Teardown
    Log  Testbed Teardown
    Get All Users    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}


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
