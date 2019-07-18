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
Resource        ../lib/restconf_oper.robot
Resource        ../lib/attella_keyword.robot
Resource        ../lib/notification.robot

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
#TC1
#    [Documentation]  Warm reboot system via transfer rpc
#    [Tags]           reload
#    Rpc Command For Warm Reload Device   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${tv['uv-odl-timeout']}   ${tv['uv-odl-interval']}    device0
#    @{filename}    create list
#    :For  ${extrafile}   in   @{remoteTestFile}
#    \   ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
#    \   ${extrafile}=   Replace String    ${extrafile}   1    ${addstr}
#    \   Append To List   ${filename}   ${extrafile}
#    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}   ${tv['uv-remote-sftp-path']}


#TC2
#    [Documentation]  Cold reboot system via transfer rpc
#    [Tags]           relod
#    Rpc Command For Cold Reload Device   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${tv['uv-odl-timeout']}   ${tv['uv-odl-interval']}     device0
#    @{filename}    create list
#    :For  ${extrafile}   in   @{remoteTestFile}
#    \   ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
#    \   ${extrafile}=   Replace String    ${extrafile}   1    ${addstr}
#    \   Append To List   ${filename}   ${extrafile}
#    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}   ${tv['uv-remote-sftp-path']}
  

TC3
    [Documentation]  Collect tech info file in a special directory
    ...              RLI38974 5.3-1
    [Tags]           Sanity   tc13  tech
    ${shelfid}      set variable    shelf-0
    ${logoption}    set variable    all
    ${debugfileName}=    RPC Create Tech Info   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${shelfid}   ${logoption}
    Wait Until Keyword Succeeds   600 sec   60 sec     Wait For Collect Tech Info    ${debugfileName}


TC4
    [Documentation]  Collect tech info file without any leaves in a special directory
    ...              This case doesn't verification file exisitence ,previous case get tech need more time, so this collect can't success
    ...              RLI38974 5.3-2
    [Tags]           Sanity    tc14
    ${urlhead}   set variable    org-openroadm-device:create-tech-info
    ${data}      set variable   <input xmlns="http://org/openroadm/device"></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${urlhead}    ${data}
    check status line    ${resp}     200
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    ${sheflid} =  get element text  ${resp.text}    shelf-id
    Run Keyword If      '${sheflid}' == 'shelf-0'     Log  the shelf information display correct
    ...         ELSE    FAIL    Expect shefl id is shelf-0, but get ${sheflid}
    ${debugfilename} =  get element text  ${resp.text}    log-file-name
    Wait Until Keyword Succeeds   600 sec   60 sec     Wait For Collect Tech Info    ${debugfileName}


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
