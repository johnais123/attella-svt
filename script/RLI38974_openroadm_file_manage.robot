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
${remotesftpPath}   sftp://atlas:atlas@10.228.0.25/attella_log/Wh_team
# filename should be include number 1 for below testing 
@{remoteTestFile}     tempm1.gz    tempconfig1.txt

*** Test Cases ***     
perform rpc transfer download file
    [Documentation]  Download file via transfer rpc
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1  done
    @{filename}    create list    @{remoteTestFile} 
    Rpc Command For Download File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}   ${remotesftpPath} 
    
    
perform rpc transfer show special file
    [Documentation]  display special transfer file via rpc command 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc2  done 
    @{filename}    create list    @{remoteTestFile}
    Rpc Command For Show File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${filename}


perform rpc transfer show all file
    [Documentation]  display all transfer file via rpc command 
    ...              RLI38974 5.1-2
    [Tags]           Sanity   tc3  done
    @{newfilename}    create list    @{remoteTestFile}
    @{fileall}        Combine Lists    ${deffilelist}   ${newfilename} 
    Rpc Command For Show All File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${fileall} 
    
        
perform rpc transfer upload file
    [Documentation]  Upload file via transfer rpc
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc4   done
    @{filename2}    create list   
    :For  ${extrafile}   in   @{remoteTestFile}
    \   ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    \   ${extrafile}=   Replace String    ${extrafile}   1    ${addstr}
    \   Append To List   ${filename2}   ${extrafile}
    Set Suite Variable    ${filename2}
    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename2}   ${remotesftpPath}  
    
    
perform rpc transfer delete special file
    [Documentation]  Delete special transfer file via rpc command 
    ...              RLI38974 5.1-3
    [Tags]           Sanity   tc5   done
    @{filename}    create list    @{remoteTestFile}
    Rpc Command For Delete File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${filename}  
    Rpc Command For Delete File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${filename2} 


perform rpc transfer delete file via wild-card
    [Documentation]  Delete special transfer file via rpc command 
    ...              RLI38974 5.1-3
    [Tags]           Sanity   tc6    
    @{filename}    create list    temp*
    Rpc Command For Delete File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${filename}


perform rpc create tech info
    [Documentation]  produce tech info file in a special directory
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc7    
    ${shelfid}      set variable    shelf-0
    ${logoption}    set variable    all  
    RPC Create Tech Info   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${shelfid}   ${logoption}


perform rpc transfer can work after warm reload
    [Documentation]  Warm reboot system via transfer rpc
    ...              RLI38974 5.1-1  
    [Tags]           Sanity   tc8   reload    
    Rpc Command For Warm Reload Device   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${timeout}    ${interval}   device0
    @{filename}    create list   
    :For  ${extrafile}   in   @{remoteTestFile}
    \   ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    \   ${extrafile}=   Replace String    ${extrafile}   1    ${addstr}
    \   Append To List   ${filename}   ${extrafile}
    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}   ${remotesftpPath}  


perform rpc transfer can work after cold reload
    [Documentation]  Cold reboot system via transfer rpc
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc9   reload  
    Rpc Command For Cold Reload Device   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${timeout}    ${interval}    device0
    @{filename}    create list   
    :For  ${extrafile}   in   @{remoteTestFile}
    \   ${addstr}=      Generate Random String   2      [NUMBERS]abcdef
    \   ${extrafile}=   Replace String    ${extrafile}   1    ${addstr}
    \   Append To List   ${filename}   ${extrafile}
    Rpc Command For Upload File   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${filename}   ${remotesftpPath}  


*** Keywords ***
Testbed Init
    # Initialize
    log   retrieve system relate information via CLI
    ${r0} =     Get Handle      resource=device0
    Set Suite Variable    ${r0}
    @{dut_list}    create list    device0 
    Preconfiguration netconf feature    @{dut_list}
    Get Default Openroadm File 
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
    
    Mount vAttella On ODL Controller    ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    sleep   15s 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}


Get Default Openroadm File 
    @{nulllist}  create list 
    Execute shell command on device     device=${r0}       command=cd /var/openroadm
    ${cmd1}=     Execute shell command on device     device=${r0}     command=ls
    ${deffilelist}=     getdefaultOpenroamdfile   ${cmd1}
    Set Suite Variable    ${deffilelist}
    log     ${deffilelist}
