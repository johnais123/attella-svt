*** Settings ***
Documentation     This is Attella interface Scripts
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
Library         String
Library         ExtendedRequestsLibrary
Library         XML    use_lxml=True
Resource        lib/restconf_oper.robot
Resource        lib/attella_keyword.robot
Resource        lib/notification.robot

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
@{auth}    admin   admin


*** Test Cases ***     
TC1 
    [Documentation]  Collect history pm via rpc request and verfiy reply message
    ...              RLI38974 5.3-3
    [Tags]           Sanity   tc1 
    RPC Collect Historical Pm     ${odl_sessions}   ${tv['device0__re0__mgt-ip']}     1   96   15min
    Sleep  10
    RPC Collect Historical Pm     ${odl_sessions}   ${tv['device0__re0__mgt-ip']}     1   1   24Hour


TC2
    [Documentation]  Historical pm file can uploaded to special directory
    ...              RLI38974 5.3-4 
    [Tags]           Sanity   tc2
    ${startbin} =     Evaluate   random.randint(1, 48)    modules=random
    ${endbin} =     Evaluate   random.randint(48, 96)    modules=random
    Verify history pm file upload success    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${startbin}   ${endbin}   15min  


TC3
    [Documentation]  check historcial pm file can get pm statistics following configure bin number 
    ...              RLI38974 5.3-5
    [Tags]           Sanity   tc3
    ${startbin} =     Evaluate   random.randint(1, 48)    modules=random
    ${endbin} =     Evaluate   random.randint(48, 96)    modules=random
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    ${hispmstring}=     Retrieve History Pm Detail Statistics   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}     ${startbin}   ${endbin}   15min
    : FOR    ${INDEX}    IN RANGE    ${startbin}    ${endbin}
    \    Should Contain     ${hispmstring}   <bin-number>${INDEX}</bin-number>
    ${noChooseBin}=   Evaluate   random.choice((0, ${startbin}-1)+(${endbin}+1,96))    modules=random 
    Should Not Contain    ${hispmstring}    <bin-number>${noChooseBin}</bin-number>


TC4
    [Documentation]  check historcial pm file can get pm statistics following configure granularity 
    ...              RLI38974 5.3-6
    [Tags]           Sanity   tc4
    @{pmInterList}    Create List    15min
    ${pmInterval}=   Evaluate   random.choice(${pmInterList})    modules=random 
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    ${hispmstring}=     Retrieve History Pm Detail Statistics   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    1   1   ${pmInterval}
    Should Contain     ${hispmstring}   <granularity>${pmInterval}</granularity>
    Should Not Contain     ${hispmstring}   <granularity>24Hour</granularity>


TC5
    [Documentation]  Upload file via transfer rpc
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc5
    @{curfilelist}=    Get Default Openroadm File
    #${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    @{curfilelist1}=  Get Matches   ${curfilelist}    p*
    ${extrafile}=    Replace String Using Regexp    @{curfilelist1}[0]   \\d{8}-\\d{6}-\\w{3}    ${addstr}
    @{filelist}      create list    @{curfilelist1}[0] 
    Set Suite Variable    ${extrafile} 
    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filelist}   ${tv['uv-remote-sftp-path']}   ${extrafile}


TC6
    [Documentation]  Download file via transfer rpc
    ...              RLI38974 5.1-2   
    [Tags]           Sanity   tc6
    @{curfilelist}=    Get Default Openroadm File
    #${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    @{curfilelist1}=  Get Matches   ${curfilelist}    p*
    ${extrafile}=    Replace String Using Regexp    @{curfilelist1}[0]   \\d{8}-\\d{6}-\\w{3}    ${addstr}
    Rpc Command For Download File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${tv['uv-remote-sftp-path']}   ${extrafile}    


TC7
    [Documentation]  display special transfer file via rpc command 
    ...              RLI38974 5.1-3
    [Tags]           Sanity   tc7
    @{curfilelist}=    Get Default Openroadm File
    #${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    @{curfilelist1}=  Get Matches   ${curfilelist}    p*
    ${extrafile}=    Replace String Using Regexp    @{curfilelist1}[0]   \\d{8}-\\d{6}-\\w{3}    ${addstr}
    @{filename}    create list    ${extrafile}
    Rpc Command For Show File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}


TC8
    [Documentation]  display all transfer file via rpc command 
    ...              RLI38974 5.1-3-1
    [Tags]           Sanity   tc8
    @{curfilelist}=    Get Default Openroadm File
    Rpc Command For Show All File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${curfilelist} 
    
    
TC9
    [Documentation]  Delete special transfer file via rpc command 
    ...              RLI38974 5.1-4   
    [Tags]           Sanity   tc9
    @{curfilelist}=    Get Default Openroadm File
    #${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    @{curfilelist1}=  Get Matches   ${curfilelist}    p*
    ${extrafile}=    Replace String Using Regexp    @{curfilelist1}[0]   \\d{8}-\\d{6}-\\w{3}    ${addstr}
    @{filename}    create list    ${extrafile}
    Rpc Command For Delete File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${filename}  




# TC10
#     [Documentation]  Warm reboot system via transfer rpc
#     [Tags]           reload    
#     Rpc Command For Warm Reload Device   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${tv['uv-odl-timeout']}   ${tv['uv-odl-interval']}    device0
#     @{filename}    create list   
#     :For  ${extrafile}   in   @{remoteTestFile}
#     \   ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
#     \   ${extrafile}=   Replace String    ${extrafile}   1    ${addstr}
#     \   Append To List   ${filename}   ${extrafile}
#     Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}   ${tv['uv-remote-sftp-path']} 
# 
# 
# TC11
#     [Documentation]  Cold reboot system via transfer rpc
#     [Tags]           relod
#     Rpc Command For Cold Reload Device   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${tv['uv-odl-timeout']}   ${tv['uv-odl-interval']}     device0
#     @{filename}    create list   
#     :For  ${extrafile}   in   @{remoteTestFile}
#     \   ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
#     \   ${extrafile}=   Replace String    ${extrafile}   1    ${addstr}
#     \   Append To List   ${filename}   ${extrafile}
#     Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}   ${tv['uv-remote-sftp-path']} 
  

TC12
    [Documentation]  produce tech info file without any leaves in a special directory
    ...              This case doesn't verification file exisitence ,previous case get tech need more time, so this collect can't success
    ...              RLI38963 5.8.1
    [Tags]          Sanity    tc11
    ${shelfnm}   set variable    shelf-0
    ${ledstatflag}      set variable   true
    ${resp}=     RPC Led Control    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${shelfnm}    ${ledstatflag}
    Log              Verify Equipment LED On can be rasied on shelf-0
    Wait For  5
    @{expectedAlarms_led_on}      Create List       Equipment LED On 
    @{activeAlarmList}=  Get Alarms On Resource   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${shelfnm}
    List Should Contain Sub List    ${activeAlarmList}    ${expectedAlarms_led_on}


TC13 
    [Documentation]  produce tech info file without any leaves in a special directory
    ...              This case doesn't verification file exisitence ,previous case get tech need more time, so this collect can't success
    ...              RLI38963 5.8.2 
    [Tags]          Sanity    tc12
    ${shelfnm}   set variable    shelf-0
    ${ledstatflag}      set variable   false
    ${resp}=     RPC Led Control    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${shelfnm}    ${ledstatflag}
    Wait For  5
    Log              Verify Equipment LED On can be cleared on shelf-0
    ${notexpectedAlarms}      set variable      Equipment LED On 
    @{activeAlarmList}=  Get Alarms On Resource   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${shelfnm}
    List Should Not Contain Value   ${activeAlarmList}    ${notexpectedAlarms}

# tech info operation is much too long to automate frequently.
# also fails due to timeout.
# TC14
#     [Documentation]  Collect tech info file in a special directory
#     ...              RLI38974 5.3-1
#     [Tags]           Sanity   tc13  tech  
#     ${shelfid}      set variable    shelf-0
#     ${logoption}    set variable    all  
#     ${debugfileName}=    RPC Create Tech Info   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${shelfid}   ${logoption}  
#     Wait Until Keyword Succeeds   600 sec   60 sec     Wait For Collect Tech Info    ${debugfileName}



# TC15
#     [Documentation]  Collect tech info file without any leaves in a special directory
#     ...              This case doesn't verification file exisitence ,previous case get tech need more time, so this collect can't success
#     ...              RLI38974 5.3-2
#     [Tags]           Sanity    tc14
#     ${urlhead}   set variable    org-openroadm-device:create-tech-info
#     ${data}      set variable   <input xmlns="http://org/openroadm/device"></input>
#     ${resp}=     Send Rpc Command    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${urlhead}    ${data}
#     check status line    ${resp}     200 
#     ${elem} =  get element text  ${resp.text}    status
#     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
#     ...         ELSE    FAIL    Expect status is successful, but get ${elem}
#     ${sheflid} =  get element text  ${resp.text}    shelf-id
#     Run Keyword If      '${sheflid}' == 'shelf-0'     Log  the shelf information display correct
#     ...         ELSE    FAIL    Expect shefl id is shelf-0, but get ${sheflid}
#     ${debugfilename} =  get element text  ${resp.text}    log-file-name
#     Wait Until Keyword Succeeds   600 sec   60 sec     Wait For Collect Tech Info    ${debugfileName}



TC16
    [Documentation]  Verify transfer upload notification can be reported successfully
    ...              RLI38974 5.2-1
    [Tags]           Sanity   tc15
    @{curfilelist}=    Get Default Openroadm File
    #${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    @{curfilelist1}=  Get Matches   ${curfilelist}    p*
    ${extrafile}=    Replace String Using Regexp    @{curfilelist1}[0]   \\d{8}-\\d{6}-\\w{3}    ${addstr}
    @{filelist}      create list    @{curfilelist1}[0] 
    Set Suite Variable    ${extrafile}
    @{uploadNotification}=  Create List  transfer-notification  @{curfilelist1}[0]  Successful
    @{Notifications}=  Create List  ${uploadNotification}
    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filelist}   ${tv['uv-remote-sftp-path']}   ${extrafile}
    Notifications Should Raised   ${ncHandle}   ${Notifications}  30


TC17
    [Documentation]  Verify transfer upload notification can be reported failed with non-exsit file
    ...              RLI38974 5.2-1
    [Tags]           Sanity   tc16
    #${addstr}=      Generate Random String   3      [NUMBERS]abcdef
    @{curfilelist1}=  create list    ${addstr}.txt
    @{uploadNotification}=  Create List  transfer-notification  @{curfilelist1}[0]   Failed
    @{Notifications}=  Create List  ${uploadNotification}
    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${curfilelist1}   ${tv['uv-remote-sftp-path']}   @{curfilelist1}[0]
    Notifications Should Raised   ${ncHandle}   ${Notifications}   30


TC18
    [Documentation]  Verify transfer download notification can be reported successfully
    ...              RLI38974 5.2-3
    [Tags]           Sanity   tc17
    @{uploadNotification}=  Create List  transfer-notification  ${extrafile}  Successful
    @{Notifications}=  Create List  ${uploadNotification}
    @{curfilelist}=    Get Default Openroadm File
    #${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    @{curfilelist1}=  Get Matches   ${curfilelist}    p*
    ${extrafile}=    Replace String Using Regexp    @{curfilelist1}[0]   \\d{8}-\\d{6}-\\w{3}    ${addstr}
    Rpc Command For Download File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${tv['uv-remote-sftp-path']}   ${extrafile}
    Notifications Should Raised   ${ncHandle}   ${Notifications}  30


TC19
    [Documentation]  Verify transfer download notification can be reported failed with non-exsit file
    ...              RLI38974 5.2-4
    [Tags]           Sanity   tc18
    ${nonexistfile}=      Generate Random String   2      [NUMBERS]abcdef
    @{uploadNotification}=  Create List  transfer-notification  ${nonexistfile}  Failed
    @{Notifications}=  Create List  ${uploadNotification}
    Rpc Command For Download File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${tv['uv-remote-sftp-path']}   ${nonexistfile}
    Notifications Should Raised   ${ncHandle}   ${Notifications}   30

# Moved to be run last as some pm files are expected to exist in tests before this

TC20
    [Documentation]  Delete special transfer file via rpc command 
    ...              RLI38974 5.1-4-2
    [Tags]           Sanity   tc10
    @{filename}    create list    pm*
    Rpc Command For Delete File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${filename}
    @{curfilelist}=    Get Default Openroadm File
    Should Not Contain Match    ${curfilelist}   pm*


TC21
    [Documentation]  Create a backup of the device configuration
    ...              RLI38974  
    [Tags]           Sanity  tc21
    # [Arguments]    ${odl_sessions}   ${node}   ${filename}
    @{filename}=    Create List    attella_163.backup
    @{backupNotification}=  Create List  db-backup-notification  @{filename}[0]  Successful
    @{Notifications}=  Create List  ${backupNotification}
    Rpc Command For DB Backup   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   @{filename}[0]
    Notifications Should Raised   ${ncHandle}   ${Notifications}  30


*** Keywords ***
Testbed Init
    log   retrieve system relate information via CLI
    ${r0} =     Get Handle      resource=device0
    Set Suite Variable    ${r0}
    @{dut_list}    create list    device0 
    Preconfiguration netconf feature    @{dut_list}
    Get Default Openroadm File 
    Log To Console      create a restconf operational session   
    ${opr_session}    Set variable      operational_session
    Create Session          ${opr_session}    http://${tv['uv-odl-server']}/restconf/operational/network-topology:network-topology/topology/topology-netconf    auth=${auth}     debug=1
    Set Suite Variable    ${opr_session}
    
    Log To Console      create a restconf config session
    ${cfg_session}    Set variable      config_session
    Create Session          ${cfg_session}    http://${tv['uv-odl-server']}/restconf/config/network-topology:network-topology/topology/topology-netconf    auth=${auth}     debug=1
    Set Suite Variable    ${cfg_session}

    Log To Console      create a restconf rpc session
    ${rpc_session}    Set variable      rpc_session
    Create Session          ${rpc_session}    http://${tv['uv-odl-server']}/restconf/operations/network-topology:network-topology/topology/topology-netconf    auth=${auth}      debug=1
    Set Suite Variable    ${rpc_session}
        
    @{odl_sessions}    create list   ${opr_session}   ${cfg_session}   ${rpc_session}
    Set Suite Variable    ${odl_sessions}

    ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    Set Suite Variable    ${addstr}
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}   ${tv['uv-odl-interval']}    ${tv['device0__re0__mgt-ip']}   openroadm   openroadm
    Wait For   5s 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}   ${tv['uv-odl-timeout']}   ${tv['uv-odl-interval']}  ${tv['device0__re0__mgt-ip']}

    ${ncHandle}=  Get Netconf Client Handle  ${tv['device0__re0__mgt-ip']}
    Set Suite Variable    ${ncHandle}
    
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}

Get Default Openroadm File 
    @{nulllist}  create list 
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    ${cmd1}=     Execute shell command on device     device=${r0}     command=ls
    ${deffilelist}=     getdefaultOpenroamdfile   ${cmd1}
    Set Suite Variable    ${deffilelist}
    log     ${deffilelist}
    [return]    ${deffilelist}


Verify history pm file upload success
    [Documentation]   Verify history pm file upload success
    [Arguments]     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${startbin}   ${endbin}   ${pmInterval}
    ${hisPmName}=   RPC Collect Historical Pm     ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${startbin}   ${endbin}   ${pmInterval}
    Wait For  10
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    ${cmd1}=     Execute shell command on device     device=${r0}     command=ls
    ${deffilelist}=     getdefaultOpenroamdfile   ${cmd1}
    List Should Contain Value     ${deffilelist}      ${hisPmName}
    Set Suite Variable    ${hisPmName}
    [return]     ${hisPmName}


Retrieve History Pm Detail Statistics 
    [Documentation]   Retrieve Detail history pm data 
    [Arguments]     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${startbin}   ${endbin}   ${pmInterval}    
    ${hisPmName}=    Verify history pm file upload success    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${startbin}   ${endbin}   ${pmInterval}   
    Switch to superuser    device=${r0}
    Execute shell command on device     device=${r0}       command=who
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    Execute shell command on device     device=${r0}       command=gunzip ${hisPmName}
    ${gethisNamelem}    Evaluate       '${hisPmName}'.split(".")[0]   string
    ${pmstring}=    Execute shell command on device     device=${r0}       command=cat ${gethisNamelem}
    Set Suite Variable    ${pmstring}
    [return]     ${pmstring}


Wait For Collect Tech Info    
    [Documentation]   Wait for collect tech info file 
    [Arguments]     ${debugfileName} 
    @{filelist}=   Get Default Openroadm File 
    List Should Contain Value     ${filelist}    ${debugfileName}    
