*** Settings ***
Documentation     These are keywords for Attella Automation script 
...               Author: Jack & Barryzhang

Library         BuiltIn
Library         String
Library         Collections
Library         OperatingSystem
Library         String
Library         ExtendedRequestsLibrary
Library         XML    use_lxml=True
Library         attella_keyword.py
Library         random

*** Variables ***
&{put_headers}               Accept=application/xml   Content-Type=application/xml
&{get_headers}               Accept=application/xml
&{delete_headers}            Accept=application/xml
&{patch_headers}             Accept=application/yang.patch-status+xml  Content-Type=application/yang.patch+xml  
&{post_headers}              Accept=application/xml   Content-Type=application/xml                  
${OPR_SESSEION_INDEX}  0
${CFG_SESSEION_INDEX}  1
${RPC_SESSEION_INDEX}  2
${succ_meg}        Successful
@{ignorePmList}      preFECCorrectedErrors    nearEnd    rx 

*** Keywords ***
check status line
    [Documentation]   check restconf operation return status line
    [Arguments]    ${get_resp}    ${statusId}  
    ${status_is_expected}              Run Keyword And Return Status    Should Be Equal As Strings    ${get_resp.status_code}    ${statusId} 
    Run Keyword If          '${status_is_expected}' != 'True'    Run Keywords     Fail     check status line and status id isn't ${statusId}    
    ...                                   AND     Log   Response: ${get_resp.content}

check delete OpenRoadm tatus line 
    [Documentation]   check restconf operation return status line
    [Arguments]    ${get_resp}    ${statusId}  
	Log    ${get_resp.status_code}  
	${status_is_expected}    evaluate    str(${get_resp.status_code})  in   @{statusId}
    Run Keyword If          '${status_is_expected}' != 'True'    Run Keywords     Fail     check status line and status id isn't ${statusId}    
    ...   
    

Send Get Request
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${dictNetconfParams}
    Log                     Fetching config via Restconf GET method
    ${urlhead}=    Retrieve URL Parent  ${dictNetconfParams}

    ${resp}=             Get Request  @{odl_sessions}[${OPR_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${urlhead}/    headers=${get_headers}    allow_redirects=False
    #${resp}=       sendRequest    ${node}    ${urlhead}
	Log  ${resp.content}
    [return]  ${resp}


Send Get Request And Verify Status Of Response Is OK
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${resp}=  Send Get Request  ${odl_sessions}  ${node}  ${dictNetconfParams}
	check status line    ${resp}     200
    [return]  ${resp}


Send Get Request And Verify Output Is Correct
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${dictNetconfParams}
    Log                     Fetching config via Restconf GET method
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8
    ${root}=                 Parse XML    ${resp_content}
    ${result}=  verify data    ${root}    ${dictNetconfParams}
    run keyword if   "${result}" != "True"  FAIL  Failed to retrieve leaf value  ELSE  Log  Get ${dictNetconfParams} and vaule show successful  


Send Merge Request
    [Documentation]   Edit system configuration
    [Arguments]     ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${editId}=   random.randint   ${1}   ${100}
    ${urlhead}=    Retrieve URL Parent  ${dictNetconfParams}
    ${url}=     Retrieve set URL  ${dictNetconfParams}
    log    ${urlhead} ${url}
    ${data}=    Set variable    <yang-patch xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-patch"><patch-id>Patch operation</patch-id><edit><edit-id>${editId}</edit-id><operation>merge</operation><target>/</target><value>${url}</value></edit></yang-patch>
    log    ${data}    
    ${resp}=            Patch Request   @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${urlhead}   data=${data}    headers=${patch_headers}    allow_redirects=False
    log    ${resp}
    [Return]  ${resp}


Send Merge Request And Verify Status Of Response Is OK
    [Documentation]   Edit system configuration
    [Arguments]     ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${resp}=  Send Merge Request  ${odl_sessions}  ${node}  ${dictNetconfParams}
    check status line    ${resp}     200    
    [Return]  ${resp}


Send Merge Then Get Request And Verify Output Is Correct
    [Documentation]   Edit system configuration
    [Arguments]     ${odl_sessions}  ${node}  ${dictNetconfParams}
    Send Merge Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${resp}=  Send Get Request And Verify Output Is Correct  ${odl_sessions}  ${node}  ${dictNetconfParams}
    [Return]  ${resp}
    

Send Delete Request
    [Documentation]   delete configuration
    [Arguments]    ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${path}  get instance Path  ${dictNetconfParams}
    Log                     delete configuration
    ${urlhead}    Retrieve URL Parent  ${dictNetconfParams}
    ${resp}             Delete Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${urlhead}/${path}    headers=${delete_headers}    allow_redirects=False
    log    ${resp}
    [return]  ${resp}


Send Delete Request With Complete Url
    [Documentation]   delete configuration
    [Arguments]    ${odl_sessions}  ${node}  ${fullUrl}
    Log                     Delete configuration  
    ${resp}             Delete Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${fullUrl}    headers=${delete_headers}    allow_redirects=False
    check status line    ${resp}     200     
    [return]  ${resp}

Send Delete OpenRoadm Request 
    [Documentation]   delete configuration
    [Arguments]    ${odl_sessions}  ${node}  ${fullUrl}
    Log                     delete configuration
    ${resp}             Delete Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${fullUrl}    headers=${delete_headers}    allow_redirects=False
	@{responseID}   create list   200    404
    check delete OpenRoadm tatus line     ${resp}     ${responseID}   
    [return]  ${resp}		
	
	

Send Put Request
    [Documentation]   Edit system configuration
    [Arguments]     ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${urlhead}=    Retrieve URL Parent  ${dictNetconfParams}
    ${data}=    Retrieve set URL  ${dictNetconfParams}
    log    ${data}
    ${resp}=        Put Request    @{odl_sessions}[${CFG_SESSEION_INDEX}]   /node/${node}/yang-ext:mount/${urlhead}     data=${data}    headers=${put_headers}    
    # ${resp}=       Patch Request   @{odl_sessions}[${CFG_SESSEION_INDEX}]   /node/${node}/yang-ext:mount/${urlhead}   data=${data}    headers=${put_headers}    allow_redirects=False
    [Return]  ${resp}

Send Post Request
    [Documentation]   Edit system configuration
    [Arguments]     ${odl_sessions}  ${node}    ${urlhead}   ${dictNetconfParams}
    ${data}=    Retrieve set URL  ${dictNetconfParams}
    ${resp}=    Post Request    @{odl_sessions}[${CFG_SESSEION_INDEX}]   /node/${node}/yang-ext:mount/${urlhead}     data=${data}    headers=${post_headers}    
    [Return]  ${resp}
    
Send Delete Request And Verify Status Of Response Is OK
    [Documentation]   delete configuration
    [Arguments]    ${odl_sessions}  ${node}  ${dictNetconfParams}
    ${resp}=  Send Delete Request  ${odl_sessions}  ${node}  ${dictNetconfParams}
    check status line    ${resp}     200     
    [return]  ${resp}

    
Send Rpc Command 	
    [Documentation]   send Rpc Command 
    [Arguments]    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    ${resp}=        post Request    @{odl_sessions}[${RPC_SESSEION_INDEX}]   /node/${node}/yang-ext:mount/${urlhead}     data=${data}    headers=${post_headers}  
	[return]  ${resp}
    
    
Rpc Command For Show File
    [Documentation]   Show one or more files in the specified directory
    ...           Args:
    ...           | - odl_sessions : config/operational sessions to ODL controller
    ...           | - node : mount node in ODL
    ...           | - testfile  ： Specify file(s) to be listed (* is allowed as wild-card) and the length "1..255"    
    [Arguments]    ${odl_sessions}   ${node}   ${testfile}
    ${urlhead}    set variable    org-openroadm-file-transfer:show-file 
    :For  ${FileNm}  in   @{testfile}
    \    ${FileNm}    convert to string    ${FileNm}
    \    log   ${FileNm}
    \    ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>${FileNm}</filename></input>
    \    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \    check status line    ${resp}     200  
    \    ${elem} =  get element text  ${resp.text}    status
    \    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    \     ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    \    ${elem2} =     get elements texts    ${resp.text}    status-message
    \    List Should Contain Value    ${elem2}    ${FileNm}


Rpc Command For Show All File
    [Documentation]   display file relate status message via file transfer Rpc command
    ...           Args:
    ...           | - odl_sessions : config/operational sessions to ODL controller
    ...           | - node : mount node in ODL
    ...           | - allfilelist  ： * represent all file need be shown     
    [Arguments]    ${odl_sessions}   ${node}    ${allfilelist}
    ${urlhead}   set variable    org-openroadm-file-transfer:show-file
    ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>*</filename></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200       
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    ${elem2} =     get elements texts    ${resp.text}    status-message
    Log    ${elem2} 
    Sort List   ${elem2}    
    Sort List   ${allfilelist}
    log many    ${elem2}    ${allfilelist}
    Lists Should Be Equal  ${elem2}   ${allfilelist}

    
Rpc Command For Delete File
    [Documentation]   Delete one or more files in the specified directory
    ...           Args:
    ...           | - odl_sessions : config/operational sessions to ODL controller
    ...           | - node : mount node in ODL
    ...           | - testfile  ： Specify file(s) to be listed (* is allowed as wild-card) and the length "1..255"    
    [Arguments]    ${odl_sessions}   ${node}    ${testfile}
    ${urlhead}   set variable    org-openroadm-file-transfer:delete-file
    :For  ${FileNm}  in   @{testfile}
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>${FileNm}</filename></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \     check status line    ${resp}     200    
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    \     ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    \     Sleep   10

    
Rpc Command For Upload File
    # no way to check remote sftp server file ,so i via download to my device again and check new file whether upload to sftp server
    [Documentation]   Upload file via file transfer Rpc command using FTP/SFTP
    ...           Args:
    ...           | - odl_sessions : config/operational sessions to ODL controller
    ...           | - node : mount node in ODL
    ...           | - localfilelist  ： under upload file list with local file name, support mutiple files upload
    ...           | - remotePath  ： Remote file path   Format:sftp://user[:password]@host[:port]/path
    ...           | - newFileNm  ： rename file and upload to remote server    
    [Arguments]    ${odl_sessions}   ${node}   ${localfilelist}    ${remotePath}   ${newFileNm}
    :For  ${FileNm}  in   @{localfilelist}
    \     ${urlhead}   set variable    org-openroadm-file-transfer:transfer
    \     ${fullremotePath}=    set variable     ${remotePath}/${newFileNm}
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><action>upload</action><local-file-path>${FileNm}</local-file-path><remote-file-path>${fullremotePath}</remote-file-path></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}  
    \     check status line    ${resp}     200 
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    \     ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    \     sleep  10
    
Rpc Command For Download File
    [Documentation]   Upload file via file transfer Rpc command
    ...           Args:
    ...           | - odl_sessions : config/operational sessions to ODL controller
    ...           | - node : mount node in ODL
    ...           | - remotePath  ： Remote file path   Format:sftp://user[:password]@host[:port]/path/filename
    ...           | - FileNm  ： download specific remote file to local with FileNm         
    [Arguments]    ${odl_sessions}   ${node}    ${remotePath}    ${FileNm}  
    ${urlhead}   set variable    org-openroadm-file-transfer:transfer
    ${fullremotePath}=    set variable     ${remotePath}/${FileNm}
    ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><action>download</action><local-file-path>${FileNm}</local-file-path><remote-file-path>${fullremotePath}</remote-file-path></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200 
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    Sleep  10


RPC Create Tech Info
    [Documentation]   Collects all logs data for debugging and place it in a location accessible via RPC create-tech-info 
    ...               This model assumes ASYNC operation
    ...               Refer to org-openroadm-device yang file
    ...           Args:
    ...           | - odl_sessions : config/operational sessions to ODL controller
    ...           | - node : mount node in ODL
    ...           | - shelfid  ： This optional field is used to specify the shelf for log collection , only support "shelf-0"
    ...           | - logoption :  The log type a vendor can specify. Maybe used in future, the default value is "all"              
    [Arguments]    ${odl_sessions}   ${node}   ${shelfid}   ${logoption}
    ${urlhead}   set variable    org-openroadm-device:create-tech-info
    ${data}      set variable   <input xmlns="http://org/openroadm/device"><shelf-id>${shelfid}</shelf-id><log-option>${logoption}</log-option></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200 
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    ${sheflid} =  get element text  ${resp.text}    shelf-id
    Run Keyword If      '${sheflid}' == 'shelf-0'     Log  the shelf information display correct
    ...         ELSE    FAIL    Expect shefl id is shelf-0, but get ${sheflid}
    ${debugfilename} =  get element text  ${resp.text}    log-file-name
    log    ${debugfilename}
    [Return]    ${debugfilename}


RPC Led Control
    [Documentation]   Allow user to find an entity on the NE ,the specified entity will have LED blinking
    ...               equipmentLedOn alarm will be raised and cleared for the indication via leaf enabled
    ...               Refer to org-openroadm-device yang file
    ...           Args:
    ...           | - odl_sessions : config/operational sessions to ODL controller
    ...           | - node : mount node in ODL
    ...           | - shelfnm  ： shelf name for the operation , only support "shelf-0"
    ...           | - ledstatflag  :  led-control enabled flag     
    [Arguments]    ${odl_sessions}   ${node}    ${shelfnm}      ${ledstatflag}
    ${urlhead}   set variable    org-openroadm-device:led-control
    ${data}      set variable   <input xmlns="http://org/openroadm/device"><shelf-name>${shelfnm}</shelf-name><enabled>${ledstatflag}</enabled></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200 
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display Successfully
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    
    
RPC Clear Pm Statistics
    [Documentation]   Command to initialize PM data
    [Arguments]    ${odl_sessions}   ${node}    ${pmtype}=all    ${pmInter}=notApplicable
    ${urlhead}   set variable    org-openroadm-pm:clear-pm
    ${data}      set variable   <input xmlns="http://org/openroadm/pm"><pm-type>${pmtype}</pm-type><granularity>${pmInter}</granularity></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200 
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    

RPC Collect Historical Pm
    [Documentation]   Command to collect history pm
    [Arguments]    ${odl_sessions}   ${node}    ${frombin}   ${endbin}  ${granularity}=15min
    ${urlhead}   set variable    org-openroadm-pm:collect-historical-pm-file
    ${data}      set variable   <input xmlns="http://org/openroadm/pm"><from-bin-number>${frombin}</from-bin-number><to-bin-number>${endbin}</to-bin-number><granularity>${granularity}</granularity></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200 
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    ${hispmfile} =  get element text  ${resp.text}    pm-filename
    log    ${hispmfile}
    [return]     ${hispmfile}

    
Rpc Command For Warm Reload Device
    [Documentation]   Restart a resource with warm option via Rpc command 
    [Arguments]    ${odl_sessions}   ${node}   ${timeout}    ${interval}   ${deviceName}
    ${urlhead}   set variable    org-openroadm-de-operations:restart
    ${data}      set variable    <input xmlns="http://org/openroadm/de/operations"><option>warm</option></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200  
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    Reconnect Device And Verification reboot successful    ${deviceName}

    Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${node}
    sleep   15s 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${node}


Rpc Command For Cold Reload Device
    [Documentation]   Restart a resource with cold option via Rpc command

    [Arguments]    ${odl_sessions}   ${node}   ${timeout}    ${interval}   ${deviceName}

    ${urlhead}   set variable    org-openroadm-de-operations:restart
    ${data}      set variable    <input xmlns="http://org/openroadm/de/operations"><option>cold</option></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}  
    check status line    ${resp}     200  
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}
    Reconnect Device And Verification reboot successful    ${deviceName}

    Mount vAttella On ODL Controller    ${odl_sessions}    ${timeout}    ${interval}   ${node}
    sleep   15s 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}   ${timeout}    ${interval}   ${node}


RPC Set Current Datetime
    [Documentation]   Set current-datetime for Attella system. The example for ${datetime} is 2019-03-11T17:51:30Z
    [Arguments]    ${odl_sessions}   ${node}   ${datetime}
    ${urlhead}   set variable    org-openroadm-device:set-current-datetime
    ${data}      set variable   <input xmlns="http://org/openroadm/device"><current-datetime>${datetime}</current-datetime></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    ...         ELSE    FAIL    Expect status is successful, but get ${elem}

    
RPC Command For Password Change
    [Documentation]   Change passord for Attella system. 
    ...               Args:
    ...               | - old_password: old password.SHA-512/Crypt(3)/$6$ encrypted password but without invalid character
    ...               | - new_password: string the sames as new_passwordConfirm  
    ...               | - new_passwordConfirm  SHA-512/Crypt(3)/$6$ encrypted password and also the following characters are not allowed
    ...               | in the password string: \ | ? # @ &, for example,"$6$77ee214844a64bba$qZbg656uG5XHVvP3adQ5XvWusbOvZPGx3jaG.tYLaqQ8mmMe4quXYShI2S07OzDZmoua.PlJ76Y8f4yfmXcP20"
    ...               | is a valid encrypted code for "Embe1mpls". to try encryption,please try https://quickhash.com/
    [Arguments]    ${odl_sessions}   ${node}   ${old_password}   ${new_password}    ${new_passwordConfirm}
    ${urlhead}   set variable    org-openroadm-user-mgmt:chg-password
    ${data}      set variable   <input xmlns="http://org/openroadm/user-mgmt"><currentPassword>${old_password}</currentPassword><newPassword>${new_password}</newPassword><newPasswordConfirm>${new_passwordConfirm}</newPasswordConfirm></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    [Return]    ${resp}


Rpc Command For DB Backup
    [Documentation]   backup database via DB Backup Rpc command 
    [Arguments]    ${odl_sessions}   ${node}   ${filename}
		Log  ${tv}
    ${urlhead}    set variable    org-openroadm-database:db-backup 
    ${data}      set variable    <input xmlns="http://org/openroadm/database"><filename>${filename}</filename></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
	Log  ${resp.content}
    check status line    ${resp}     200  

	
Rpc Command For DB Restore
    [Documentation]   restore database via DB Restore Rpc command 
    [Arguments]    ${odl_sessions}   ${node}   ${filename}  ${nodeIDCheck}=true
    ${urlhead}    set variable    org-openroadm-database:db-restore 

    ${data}      set variable    <input xmlns="http://org/openroadm/database"><filename>${filename}</filename><nodeIDCheck>${nodeIDCheck}</nodeIDCheck></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
	Log  ${resp.content}
    check status line    ${resp}     200 
		
	${urlhead}    set variable    org-openroadm-database:db-activate
	# ${data}      set variable    <input xmlns="http://org/openroadm/database"><rollBackTimer>00:00:00</rollBackTimer></input>
	${data}      set variable    <input xmlns="http://org/openroadm/database"></input>
	
	${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
	Log  ${resp.content}
    check status line    ${resp}     200
	
	# ${deviceName}=  Get Device Name From IP  ${tv}  ${node}
	# Reconnect Device And Verification reboot successful    ${deviceName}

    # Mount vAttella On ODL Controller    ${odl_sessions}    ${timeout}    ${interval}   ${node}
    # sleep   15s 
    # Verfiy Device Mount status on ODL Controller   ${odl_sessions}   ${timeout}    ${interval}   ${node}
    
    
    
Mount vAttella On ODL Controller
    [Documentation]    Mounts vAttella ODl controller and verifies the mounted capabilities of junos device
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node  : mount node in ODL
    ...                    | - timeout : How long time script should wait to check mount status (Time in robot format,e.g. 40 minute, 40 min 30 s)
    ...                    | - interval: Specifies the interval at which script should check for mount status of junos device on controller
    ...                    | - usr: the usr for logging Attella
    ...                    | - pwd: the pwd for logging Attella
    ...                    | Uses global variables "headers", "karaf log file"

    [Arguments]    ${odl_sessions}   ${timeout}  ${interval}  ${node}   ${usr}=openroadm    ${pwd}=openroadm
    ${fullUrl}                Set Variable    <node xmlns="urn:TBD:params:xml:ns:yang:network-topology"><node-id>${node}
    ${resp}             Delete Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}     headers=${delete_headers}    allow_redirects=False
    # check status line    ${resp}     200 
    ${data}                Set Variable    <node xmlns="urn:TBD:params:xml:ns:yang:network-topology"><node-id>${node}</node-id><port xmlns="urn:opendaylight:netconf-node-topology">830</port><password xmlns="urn:opendaylight:netconf-node-topology">${pwd}</password><username xmlns="urn:opendaylight:netconf-node-topology">${usr}</username><tcp-only xmlns="urn:opendaylight:netconf-node-topology">false</tcp-only><host xmlns="urn:opendaylight:netconf-node-topology">${node}</host><keepalive-delay xmlns="urn:opendaylight:netconf-node-topology">0</keepalive-delay><actor-response-wait-time xmlns="urn:opendaylight:netconf-node-topology">100</actor-response-wait-time><schema-cache-directory xmlns="urn:opendaylight:netconf-node-topology">2.2.1</schema-cache-directory><yang-module-capabilities xmlns="urn:opendaylight:netconf-node-topology"><capability>urn:ietf:params:xml:ns:netconf:notification:1.0?module=notifications&amp;revision=2008-07-14</capability><capability>urn:ietf:params:xml:ns:netmod:notification?module=nc-notifications&amp;revision=2008-07-14</capability><capability>urn:ietf:params:xml:ns:netconf:base:1.0?module=ietf-netconf&amp;revision=2011-06-01</capability><capability>urn:ietf:params:xml:ns:yang:ietf-inet-types?module=ietf-inet-types&amp;revision=2013-07-15</capability><capability>urn:ietf:params:xml:ns:yang:ietf-yang-types?module=ietf-yang-types&amp;revision=2013-07-15</capability><capability>urn:ietf:params:xml:ns:yang:iana-afn-safi?module=iana-afn-safi&amp;revision=2013-07-04</capability><capability>http://org/openroadm/user-mgmt?module=org-openroadm-user-mgmt&amp;revision=2017-12-15</capability><capability>http://org/openroadm/tca?module=org-openroadm-tca&amp;revision=2018-10-19</capability><capability>http://org/openroadm/switching-pool-types?module=org-openroadm-switching-pool-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/resource?module=org-openroadm-resource&amp;revision=2018-10-19</capability><capability>http://org/openroadm/resource/types?module=org-openroadm-resource-types&amp;revision=2018-10-19</capability><capability>http://org/openroadm/probableCause?module=org-openroadm-probable-cause&amp;revision=2018-10-19</capability><capability>http://org/openroadm/port/types?module=org-openroadm-port-types&amp;revision=2018-10-19</capability><capability>http://org/openroadm/pm?module=org-openroadm-pm&amp;revision=2018-10-19</capability><capability>http://org/openroadm/pm/types?module=org-openroadm-pm-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/otn-common-types?module=org-openroadm-otn-common-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/manifest-file?module=org-openroadm-manifest-file&amp;revision=2017-12-15</capability><capability>http://org/openroadm/maintenance?module=org-openroadm-maintenance&amp;revision=2018-10-19</capability><capability>http://org/openroadm/layerRate?module=org-openroadm-layerRate&amp;revision=2017-12-15</capability><capability>http://org/openroadm/equipment/states/types?module=org-openroadm-equipment-states-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/common-types?module=org-openroadm-common-types&amp;revision=2018-10-19</capability><capability>http://org/openroadm/alarm?module=org-openroadm-alarm&amp;revision=2018-10-19</capability><capability>http://org/openroadm/database?module=org-openroadm-database&amp;revision=2018-10-19</capability><capability>http://org/openroadm/de/operations?module=org-openroadm-de-operations&amp;revision=2018-10-19</capability><capability>http://org/openroadm/device?module=org-openroadm-device&amp;revision=2018-10-19</capability><capability>http://org/openroadm/ethernet-interfaces?module=org-openroadm-ethernet-interfaces&amp;revision=2018-10-19</capability><capability>http://org/openroadm/file-transfer?module=org-openroadm-file-transfer&amp;revision=2018-10-19</capability><capability>http://org/openroadm/fwdl?module=org-openroadm-fwdl&amp;revision=2018-10-19</capability><capability>http://org/openroadm/interfaces?module=org-openroadm-interfaces&amp;revision=2017-06-26</capability><capability>http://org/openroadm/lldp?module=org-openroadm-lldp&amp;revision=2018-10-19</capability><capability>http://org/openroadm/maintenance-loopback?module=org-openroadm-maintenance-loopback&amp;revision=2017-12-15</capability><capability>http://org/openroadm/maintenance-testsignal?module=org-openroadm-maintenance-testsignal&amp;revision=2017-12-15</capability><capability>http://org/openroadm/media-channel-interfaces?module=org-openroadm-media-channel-interfaces&amp;revision=2018-10-19</capability><capability>http://org/openroadm/network-media-channel-interfaces?module=org-openroadm-network-media-channel-interfaces&amp;revision=2018-10-19</capability><capability>http://org/openroadm/optical-channel-interfaces?module=org-openroadm-optical-channel-interfaces&amp;revision=2018-10-19</capability><capability>http://org/openroadm/optical-transport-interfaces?module=org-openroadm-optical-transport-interfaces&amp;revision=2018-10-19</capability><capability>http://org/openroadm/otn-common?module=org-openroadm-otn-common&amp;revision=2017-06-26</capability><capability>http://org/openroadm/otn-odu-interfaces?module=org-openroadm-otn-odu-interfaces&amp;revision=2018-10-19</capability><capability>http://org/openroadm/otn-otu-interfaces?module=org-openroadm-otn-otu-interfaces&amp;revision=2018-10-19</capability><capability>http://org/openroadm/physical/types?module=org-openroadm-physical-types&amp;revision=2018-10-19</capability><capability>http://org/openroadm/pluggable-optics-holder-capability?module=org-openroadm-pluggable-optics-holder-capability&amp;revision=2018-10-19</capability><capability>http://org/openroadm/port-capability?module=org-openroadm-port-capability&amp;revision=2018-10-19</capability><capability>http://org/openroadm/prot/otn-linear-aps?module=org-openroadm-prot-otn-linear-aps&amp;revision=2018-10-19</capability><capability>http://org/openroadm/rstp?module=org-openroadm-rstp&amp;revision=2018-10-19</capability><capability>http://org/openroadm/de/swdl?module=org-openroadm-swdl&amp;revision=2018-10-19</capability><capability>http://org/openroadm/syslog?module=org-openroadm-syslog&amp;revision=2017-12-15</capability><capability>http://org/openroadm/wavelength-map?module=org-openroadm-wavelength-map&amp;revision=2017-12-15</capability><override>false</override></yang-module-capabilities></node>
    ${resp}                Put Request    @{odl_sessions}[${CFG_SESSEION_INDEX}]   /node/${node}    data=${data}    headers=${put_headers}
    ${status_is_201}       Run Keyword And Return Status     Should Be Equal As Strings  ${resp.status_code}  201   msg=Failed to add config for mouting new device on ODL controller

    Run Keyword If        '${status_is_201}' != 'True'    Run Keywords
    ...                                         Log   Expected response code is 201.
    ...                                   AND   Log   Response: ${resp.content}
    ...                                   AND   FAIL    msg=PUT method failed to add config for mouting a new device on ODL controller
    Verfiy Device Mount status on ODL Controller  ${odl_sessions}  ${timeout}    ${interval}   ${node}

    
Verfiy Device Mount status on ODL Controller
    [Documentation]    Verify Device Mount status on ODL Controller whether connected in timeout duration 
    ...                    | - odl_sessions  : config/operational sessions to ODL controller
    ...                    | - timeout : How long time script should wait to check mount status (Time in robot format,e.g. 40 minute, 40 min 30 s)
    ...                    | - interval: Specifies the interval at which script should check for mount status of junos device on controller
    ...                    | - node  : mount node in ODL
    [Arguments]        ${odl_sessions}  ${timeout}    ${interval}   ${node}
    Wait Until Keyword Succeeds    ${timeout}   ${interval}    Check Mount Status Of Device on ODL Controller   ${odl_sessions}  ${node}

    
Check Mount Status Of Device on ODL Controller
    [Documentation]        Checks the mount status of junos device on ODL controller
    ...                    Fails if status is not connected
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${odl_sessions}  ${node}
    
    Log             Checking Mount status for node ${node}
    
    
    ${resp}                 Get Request    @{odl_sessions}[${OPR_SESSEION_INDEX}]    /node/${node}     headers=${get_headers}
    ${resp_content}              Decode Bytes To String  ${resp.content}    UTF-8
    ${root}                 Parse XML    ${resp_content}

    ${con_status}           Get Element Text    ${root}    connection-status
    Log To Console             Node-id ${node} connection status: ${con_status}
    Should Be Equal As Strings    ${con_status}    connected

    
Ensure Pm Statistics In the Same Bin During Testing Pm 
    [Documentation]        Checks the mount status of junos device on ODL controller
    ...                    Fails if status is not connected
    ...                    Args:
    ...                    | - deviceName : device0 or device1
    [Arguments]             ${odl_sessions}    ${node}      ${pmtype}=all    ${pmInter}=notApplicable    ${deviceName}=device0  
    # Log             Retrieve ${node} Current System Time
    # ${urlhead}      Set Variable     org-openroadm-device:org-openroadm-device/info
    # ${resp}=        Get Request  @{odl_sessions}[${OPR_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${urlhead}/    headers=${get_headers}    allow_redirects=False
    # check status line    ${resp}     200 
    # ${currentTime}=    get element text  ${resp.text}  current-datetime 
    # ${getmin}    Evaluate       '${currentTime}'.split(":")[1]   string
    # ${getmin}=   Convert To Integer  ${getmin} 
    ${getmin}=   Returns the given minute of current time   ${deviceName}
    ${getmin}=   Convert To Integer  ${getmin}
    # run keyword if	 57<=${getmin}<=59 or 12<=${getmin}<=14 or 42<=${getmin}<=44  Run Keywords   sleep  180  AND  LOG  wait for 120s
    # ...    ELSE    log   Continue to test  2 minutes 10 seconds
    ${waiTime}=    run keyword if	60>${getmin}>=58    Evaluate   60-${getmin}
    ...    ELSE IF  45>${getmin}>=43    evaluate   45-${getmin} 
    ...    ELSE IF  30>${getmin}>=28    evaluate   30-${getmin}      
    ...    ELSE IF  15>${getmin}>=13    evaluate   15-${getmin}
    ...    ELSE    evaluate   0  
    sleep  ${waiTime} minutes 10 seconds
    log    Wait for ${waiTime} minutes 10 seconds
    RPC Clear Pm Statistics   ${odl_sessions}   ${node}  
    sleep  5
    [return]  ${getmin}
    
Get Current All Pm Information On Target Resource
    [Documentation]        Get Pm On Target, include port and interface(OCH,OTU4,ODU4)
    ...                    Fails if doesn't exist this kind of resouce pm
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${odl_sessions}  ${node}   ${targetResource}
    
    &{payload}   create_dictionary   current-pm-list=${null}
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8
    Log  ${resp_content}
    ${root}=                 Parse XML    ${resp_content}
    ${sflag}     set variable    False
    @{currentPmRes}  Get Elements  ${root}  current-pm-entry
    Log  ${currentPmRes}

    :FOR  ${pmRes}  IN  @{currentPmRes}
    \   ${restype}=  Get Element  ${pmRes}  pm-resource-type
    \   ${restype_ext}=  Get Element  ${pmRes}  pm-resource-type-extension
    \   ${resinst}=  Get Element  ${pmRes}  pm-resource-instance
    \   @{ret}     Split String      ${resinst.text}    name=
    \   ${lastRes}     Get From List     ${ret}    -1
    \   ${res}     Get Substring     ${lastRes}  0  -1
    \   ${sflag}   Run Keyword If   ${res} == '${targetResource}'    set variable   True
    \   ...        ELSE      set variable    False         
    \   Run Keyword If  ${res} == '${targetResource}'    EXIT For Loop
    log   ${sflag}
    Run Keyword If  '${sflag}' != 'True'    FAIL    no any pm statistics on current ${targetResource}
    log    ${pmRes}
    [return]  ${pmRes}


Get Current All Pm Entry On Target Resource
    [Documentation]       Get ALL special Pm On Target 
    [Arguments]   ${odl_sessions}    ${node}   ${targetResource}   ${Providedpmlist}   ${ignorePmEntryParmater}=${ignorePmList}
    @{testPmList}    Create list    
    @{OthersTestPmList}   Create list 
    ${underTestRes}=      Get Current All Pm Information On Target Resource    ${odl_sessions}   ${node}   ${targetResource} 
    @{currentPmRes}  Get Elements  ${underTestRes}  current-pm 
    ${lenPmRes}=   Get length     ${currentPmRes}
    ${underTestRes1}=       Run keyword if     ${lenPmRes}==0    Get Current All Pm Information On Target Resource    ${odl_sessions}   ${node}   ${targetResource} 
    ...                              ELSE     set variable    ${underTestRes}
    @{currentPmRes}  Get Elements  ${underTestRes1}  current-pm
    :FOR  ${pm1Entry}  IN  @{Providedpmlist}
    \     ${targetPmEntry}=   Get From List   ${pm1Entry}  0
    \     ${tarPmLoc}=     Get From List   ${pm1Entry}   1
    \     ${tarPmDirect}=   Get From List   ${pm1Entry}   2
    \     set global variable   ${targetPmEntry}    
    \     set global variable    ${tarPmLoc}  
    \     set global variable    ${tarPmDirect} 
    \     Get All Under Test Pm Entry      ${currentPmRes}   ${testPmList}   ${OthersTestPmList}   ${ignorePmEntryParmater}
    ${OthersTestPmList}=    Remove Duplicates    ${OthersTestPmList}
    :FOR   ${pmitem}  IN  @${testPmList}
    \      Remove Values From List  ${OthersTestPmList}   @{testPmList}
    log    ${testPmList}
    log    ${OthersTestPmList}
    Set Global variable    ${testPmList}
    Set Global variable    ${OthersTestPmList}


Get All Under Test Pm Entry
    [Documentation]        one by one to reterive all pm entries which be provide by testcase
    ...                    Fails if it doesn't exist special pm statistics on this resource
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node :Under testing Device
    ...                    |  
    [Arguments]           ${currentPmRes}   ${testPmList}   ${OthersTestPmList}   ${ignorePmEntryParmater}
    :FOR  ${pmEntry}  IN  @{currentPmRes}
    \     ${pmtype}=  Get Element  ${pmEntry}  type
    \     ${expmtype_ext}=  Get Element  ${pmEntry}  extension
    \     ${pmlocation}=   Get Element  ${pmEntry}   location
    \     ${pmdirection}=  Get Element  ${pmEntry}   direction
    \     Log many   ${pmtype.text}    ${expmtype_ext.text}    ${pmlocation.text}    ${pmdirection.text}
    \     Run Keyword If    ('${pmtype.text}' == '${targetPmEntry}' or '${expmtype_ext.text}' == '${targetPmEntry}') and '${pmlocation.text}' == '${tarPmLoc}' and '${pmdirection.text}' == '${tarPmDirect}'   Append To List  ${testPmList}   ${pmEntry}
    \     ...        ELSE      Append To List  ${OthersTestPmList}   ${pmEntry} 
    \     Log many  @{ignorePmEntryParmater}[0]     @{ignorePmEntryParmater}[1]    @{ignorePmEntryParmater}[2] 
    \     Run Keyword If  ('${pmtype.text}' == '@{ignorePmEntryParmater}[0]' or '${expmtype_ext.text}' == '@{ignorePmEntryParmater}[0]') and '${pmlocation.text}' == '@{ignorePmEntryParmater}[1]' and '${pmdirection.text}' == '@{ignorePmEntryParmater}[2]'    Remove Values From List  ${OthersTestPmList}   ${pmEntry}
    \     ...     ELSE    Log   no ignore pm statistics


Get All Current Special Pm Statistic
    [Documentation]        one by one to reterive under testing pm entries base on pm interval
    ...                    Args:
    ...                    | - udtPm: under testing pm entry object
    ...                    | - pmInterval :   under teting pm interval
    ...                    | - PmStatisList :  store under testing pm statitics
    [Arguments]     ${udtPm}    ${pmInterval}   ${PmStatisList}
    @{currentPmStatis}  Get Elements  ${udtPm}  measurement
    :FOR  ${pmStat}  IN  @{currentPmStatis}
    \     ${pmGranularity}=  Get Element  ${pmStat}     granularity
    \     ${pmParameterUnit}=  Get Element  ${pmStat}   pmParameterUnit
    \     ${pmParameterValue}=  Get Element  ${pmStat}  pmParameterValue
    \     ${pmvalidity}=  Get Element  ${pmStat}          validity
    \     Log many    ${pmGranularity.text}    ${pmParameterValue.text} 
    \     Run keyword If  '${pmGranularity.text}' == '${pmInterval}'    Append To List   ${PmStatisList}   ${pmParameterValue.text}


Get Current Spefic Pm Statistic
    [Documentation]        Get special Pm Statistics On Target
    ...                    Fails if it doesn't exist special pm statistics on this resource
    ...                    Args:
    ...                    | - pmInterval :   under teting pm interval
    [Arguments]               ${odl_sessions}    ${node}   ${targetResource}   ${Providedpmlist}    ${pmInterval}   ${ignorePmEntryParmater}=${ignorePmList}
    Get Current All Pm Entry On Target Resource    ${odl_sessions}    ${node}   ${targetResource}   ${Providedpmlist}    ${ignorePmEntryParmater}
    @{PmStatisList}    create list  
    log   ${testPmList}
    :FOR  ${udtPm}  IN  @{testPmList}
    \    ${pmtype}=  Get Element  ${udtPm}  type
    \    ${expmtype_ext}=  Get Element  ${udtPm}  extension
    \    ${pmlocation}=   Get Element  ${udtPm}   location
    \    ${pmdirection}=  Get Element  ${udtPm}   direction
    \    Log many    ${pmtype.text}    ${expmtype_ext.text}   ${pmlocation.text}   ${pmdirection.text}
    \    Get All Current Special Pm Statistic  ${udtPm}   ${pmInterval}   ${PmStatisList}
    Log     ${PmStatisList} 
    [return]   ${PmStatisList}


Get History All Pm Information On Target Resource
    [Documentation]        Get Pm On Target, include port and interface(OCH,OTU4,ODU4)
    ...                    Fails if doesn't exist this kind of resouce pm
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${targetResource}    ${resp_content}

    ${root}=                 Parse XML    ${resp_content}
    ${sflag}     set variable    False
    @{hisPmRes}  Get Elements  ${root}  historical-pm-entry
    Log  ${hisPmRes}

    :FOR  ${pmRes}  IN  @{hisPmRes}
    \   ${restype}=  Get Element  ${pmRes}  pm-resource-type
    \   ${restype_ext}=  Get Element  ${pmRes}  pm-resource-type-extension
    \   ${resinst}=  Get Element  ${pmRes}  pm-resource-instance
    \   @{ret}     Split String      ${resinst.text}    name=
    \   ${lastRes}     Get From List     ${ret}    -1
    \   ${res}     Get Substring     ${lastRes}  0  -1
    \   ${sflag}   Run Keyword If   ${res} == '${targetResource}'    set variable   True
    \   ...        ELSE      set variable    False         
    \   Run Keyword If  ${res} == '${targetResource}'    EXIT For Loop
    log   ${sflag}
    Run Keyword If  '${sflag}' != 'True'    FAIL    no any pm statistics on current ${targetResource}
    log    ${pmRes}
    [return]  ${pmRes}


Get history All Pm Entry On Target Resource
    [Documentation]       Get ALL special histroy Pm On Target 
    [Arguments]      ${targetResource}   ${resp_content}  ${Providedpmlist}   ${ignorePmEntryParmater}=${ignorePmList}
    @{testPmList}    Create list    
    @{OthersTestPmList}   Create list 
    ${underTestRes}=      Get History All Pm Information On Target Resource   ${targetResource}  ${resp_content}
    @{currentPmRes}  Get Elements  ${underTestRes}  historical-pm
    :FOR  ${pm1Entry}  IN  @{Providedpmlist}
    \     ${targetPmEntry}=   Get From List   ${pm1Entry}  0
    \     ${tarPmLoc}=     Get From List   ${pm1Entry}   1
    \     ${tarPmDirect}=   Get From List   ${pm1Entry}   2
    \     set global variable   ${targetPmEntry}    
    \     set global variable    ${tarPmLoc}  
    \     set global variable    ${tarPmDirect} 
    \     Get All Under Test history Pm Entry      ${currentPmRes}   ${testPmList}   ${OthersTestPmList}   ${ignorePmEntryParmater}
    ${OthersTestPmList}=    Remove Duplicates    ${OthersTestPmList}
    :FOR   ${pmitem}  IN  @${testPmList}
    \      Remove Values From List  ${OthersTestPmList}   @{testPmList}
    log    ${testPmList}
    log    ${OthersTestPmList}
    Set Global variable    ${testPmList}
    Set Global variable    ${OthersTestPmList}


Get All Under Test history Pm Entry
    [Documentation]        one by one to reterive all pm entries which be provide by testcase
    ...                    Fails if it doesn't exist special pm statistics on this resource
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node :Under testing Device
    ...                    |  
    [Arguments]           ${currentPmRes}   ${testPmList}   ${OthersTestPmList}   ${ignorePmEntryParmater}
    :FOR  ${pmEntry}  IN  @{currentPmRes}
    \     ${pmtype}=  Get Element  ${pmEntry}  type
    \     ${expmtype_ext}=  Get Element  ${pmEntry}  extension
    \     ${pmlocation}=   Get Element  ${pmEntry}   location
    \     ${pmdirection}=  Get Element  ${pmEntry}   direction
    \     Log many   ${pmtype.text}    ${expmtype_ext.text}    ${pmlocation.text}    ${pmdirection.text}
    \     Run Keyword If    ('${pmtype.text}' == '${targetPmEntry}' or '${expmtype_ext.text}' == '${targetPmEntry}') and '${pmlocation.text}' == '${tarPmLoc}' and '${pmdirection.text}' == '${tarPmDirect}'   Append To List  ${testPmList}   ${pmEntry}
    \     ...        ELSE      Append To List  ${OthersTestPmList}   ${pmEntry} 
    \     Log many  @{ignorePmEntryParmater}[0]     @{ignorePmEntryParmater}[1]    @{ignorePmEntryParmater}[2] 
    \     Run Keyword If  ('${pmtype.text}' == '@{ignorePmEntryParmater}[0]' or '${expmtype_ext.text}' == '@{ignorePmEntryParmater}[0]') and '${pmlocation.text}' == '@{ignorePmEntryParmater}[1]' and '${pmdirection.text}' == '@{ignorePmEntryParmater}[2]'    Remove Values From List  ${OthersTestPmList}   ${pmEntry}
    \     ...     ELSE    Log   no ignore pm statistics
    

Get All History Special Pm Statistic
    [Documentation]        one by one to reterive under testing pm entries base on pm interval
    ...                    Args:
    ...                    | - udtPm: under testing pm entry object
    ...                    | - pmInterval :   under teting pm interval
    ...                    | - PmStatisList :  store under testing pm statitics
    [Arguments]      ${udtPm}    ${pmInterval}   ${PmStatisList}
    @{currentPmStatis}  Get Elements  ${udtPm}  measurement
    :FOR  ${pmStat}  IN  @{currentPmStatis}
    \     ${pmGranularity}=  Get Element  ${pmStat}     granularity
    \     ${pmParameterUnit}=  Get Element  ${pmStat}   pmParameterUnit
    \     ${pmParameterValue}=  Get Element  ${pmStat}  pmParameterValue
    \     ${pmvalidity}=  Get Element  ${pmStat}          validity
    \     ${currbin}=  Get Element  ${pmStat}            bin-number
    \     Log many    ${pmGranularity.text}    ${pmParameterValue.text}    ${currbin.text}
    \     Run keyword If  '${pmGranularity.text}' == '${pmInterval}' and '${currbin.text}' == '1'     Append To List   ${PmStatisList}   ${pmParameterValue.text}


Get History Spefic Pm Statistic
    [Documentation]        Get History special Pm Statistics On Target
    ...                    Fails if it doesn't exist special pm statistics on this resource
    ...                    Args:
    ...                    | - pmInterval :   under teting pm interval
    [Arguments]              ${targetResource}   ${resp_content}  ${Providedpmlist}    ${pmInterval}   ${ignorePmEntryParmater}=${ignorePmList}
    @{PmStatisList}    create list  
    Get history All Pm Entry On Target Resource    ${targetResource}   ${resp_content}  ${Providedpmlist}   ${ignorePmEntryParmater}
    log   ${testPmList}
    :FOR  ${udtPm}  IN  @{testPmList}
    \    ${pmtype}=  Get Element  ${udtPm}  type
    \    ${expmtype_ext}=  Get Element  ${udtPm}  extension
    \    ${pmlocation}=   Get Element  ${udtPm}   location
    \    ${pmdirection}=  Get Element  ${udtPm}   direction
    \    Log many    ${pmtype.text}    ${expmtype_ext.text}   ${pmlocation.text}   ${pmdirection.text}
    \    Get All History Special Pm Statistic  ${udtPm}   ${pmInterval}   ${PmStatisList}
    Log     ${PmStatisList} 
    [return]   ${PmStatisList}


Verify Pm Statistic 
    [Documentation]        Verify pm statstics On Target resource
    ...                    Fails if given error expect value
    ...                    Args:
    ...                    | - expectValue :   expect value is list and via test set/sfs/configuartion produce
    ...                    | - realValue :     real value is a variable and  via restconf request retrieve
    ...                    | - operation :     expect verify result means 
    [Arguments]            ${expectValue}   ${realValue}    ${operation}
    ${len}=  Get Length    ${expectValue}
    Run Keyword If         ${len}==1 and '${operation}'=='equal'    Verify Pm Should Be Equals   ${expectValue}     ${realValue}  
    ...         ELSE IF    ${len}==1 and '${operation}'=='increasing'    Verify Pm Should Be Increased   ${expectValue}     ${realValue}
    ...         ELSE IF    ${len}==2 and '${operation}'=='in-range'    Verify Pm Should Be In Range   ${expectValue}     ${realValue}   
    ...         ELSE       FAIL    Please check correct expect Vaule


Verify Pm Should Be Equals
    [Documentation]        Verify pm statstics On Target resource
    ...                    Fails if real value is not the same as expect value
    [Arguments]            ${expectValue}   ${realValue}
    Run Keyword If         '${expectValue}'=='${realValue}'   log   pm statistics is ok\nThe expect value is ${expectValue}\nThe real value is ${realValue}
    ...         ELSE       FAIL    Check pm statistics fail: \n The expect value is ${expectValue}\n The real value is ${realValue}


Verify Pm Should Be Increased
    [Documentation]        Verify pm statstics can be increased by the minute On Target resource 
    ...                    Fails if real value is not the same as expect value
    [Arguments]             ${nextRealValue}    ${realValue}
    Run Keyword If         ${nextRealValue}>${realValue}   log   pm statistics is increasing\nThe previous pm value is ${realValue}\nThe current pm value is ${nextRealValue}
    ...         ELSE       FAIL    Check pm statistics is not increasing: \n The previous pm value is ${realValue}\n The current pm value is ${nextRealValue}


Verify Pm Should Be In Range
    [Documentation]        Verify pm statstics On Target resource
    ...                    Fails if real value is not in expect range
    [Arguments]            ${expectValue}   ${realValue}
    ${maxValue}             set variable     @{expectValue}[0]
    ${minValue}             set variable     @{expectValue}[1]
    log    ${realValue}
    Run Keyword If         ${maxValue} >= ${realValue} >= ${minValue}    log   pm statistics is ok\nThe expect range value is ${minValue} to ${maxValue}\n The real value is ${realValue}
    ...         ELSE       FAIL    Check pm statistics fail: \n The expect range value is ${minValue} to ${maxValue}\n The real value is ${realValue}


Verify others Pm Statistic shoule not be changed
    [Documentation]        Verify others Pm Statistic shoule not be changed only for interface resource
    ...                    Fails if it doesn't exist other pm statistics on this resource
    ...                    Args:
    ...                    | - pmInterval :   under teting pm interval
    [Arguments]             ${pmInterval} 
    @{PmStatisList}    create list  
    # log   ${OthersTestPmList}
    :FOR  ${udtPm}  IN  @{OthersTestPmList}
    \     Get others Pm statistcis   ${udtPm}   ${pmInterval}  


Get others Pm statistcis
    [Documentation]        Get and verify others Pm Statistic shoule be zero
    ...                    Fails if it exist other pm statistics on this resource
    ...                    Args:
    ...                    | - pmInterval :   under teting pm interval
    [Arguments]             ${udtPm}    ${pmInterval}  
    ${pmtype}=  Get Element  ${udtPm}  type
    ${expmtype_ext}=  Get Element  ${udtPm}  extension
    ${pmlocation}=   Get Element  ${udtPm}   location
    ${pmdirection}=  Get Element  ${udtPm}   direction
    @{currentPmStatis}  Get Elements  ${udtPm}  measurement
    :FOR  ${othersPmStat}  IN  @{currentPmStatis}
    \     ${pmGranularity}=  Get Element  ${othersPmStat}        granularity
    \     ${pmParameterUnit}=  Get Element  ${othersPmStat}   pmParameterUnit
    \     ${pmParameterValue}=  Get Element  ${othersPmStat}     pmParameterValue
    \     ${pmvalidity}=  Get Element  ${othersPmStat}           validity
    \     Log many   ${pmtype.text}   ${expmtype_ext.text}  ${pmlocation.text}  ${pmdirection.text}   ${pmGranularity.text} 
    \     Log  ${pmParameterValue.text}
    \     Run keyword If  '${pmGranularity.text}' == '${pmInterval}' and '${pmParameterValue.text}' == '0'   Log   Correct and no ${pmtype.text} ${pmlocation.text} ${pmdirection.text} pm statistics on test resource
    \     ...  ELSE IF   '${pmGranularity.text}' == '${pmInterval}' and '${pmParameterValue.text}' != '0'     FAIL    Found ${pmtype.text} ${pmlocation.text} ${pmdirection.text} pm statistics on test resource: \n The expect value is 0\n The real value is ${pmParameterValue.text}
    \     ...  ELSE    Log   other granularity pm statistics


Get Alarms On Resource
    [Documentation]        Get Alarms On Target
    ...                    Fails if status is not connected
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${odl_sessions}  ${node}  ${targetResource} 
    
    &{payload}   create_dictionary   active-alarm-list=${null}
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8
    ${root}=                 Parse XML    ${resp_content}
   
    @{activeAlarms}  Get Elements  ${root}  activeAlarms
    Log  ${activeAlarms}

    @{activeAlarmList}=  Create List
    :FOR  ${activeAlarm}  IN  @{activeAlarms}
    \   ${id}=  Get Element  ${activeAlarm}  id
    \   ${raiseTime}=  Get Element  ${activeAlarm}  raiseTime
    \   ${additional_detail}=  Get Element  ${activeAlarm}  additional-detail
    \   ${severity}=  Get Element  ${activeAlarm}  severity
    \   ${cause}=  Get Element  ${activeAlarm}  probableCause/cause
    
	
    \   @{resource_cp}=  Get Elements  ${activeAlarm}  resource/resource/circuit-pack-name
    \   @{resource_port}=  Get Elements  ${activeAlarm}  resource/resource/port-name
    \   @{resource_xc}=  Get Elements  ${activeAlarm}  resource/resource/connection-name
    \   @{resource_intf}=  Get Elements  ${activeAlarm}  resource/resource/interface-name
	\   @{resource_shelf}=  Get Elements  ${activeAlarm}  resource/resource/shelf-name
	
    \   Log  ${id.text}
    \   Log  ${raiseTime.text}
    \   Log  ${additional_detail.text}
    \   Log  ${severity.text}
    \   Log  ${cause.text}
	\   ${extension}=  Run Keyword If  '${cause.text}' == 'vendorExtension'  Get Element  ${activeAlarm}  probableCause/extension
	
	\	${alarm}=  Set Variable If  '${cause.text}' == 'vendorExtension'  ${extension.text}  ${additional_detail.text}

    \   @{resource}=  Combine Lists  ${resource_cp}  ${resource_port}  ${resource_xc}  ${resource_intf}  ${resource_shelf}
    \   Log  ${resource}
    \   ${len}=  Get Length    ${resource}
    \   Run Keyword If  '${len}' != '1'  Run Keywords  Log  Get $(len) resources in one active Alarm entity
    \   ...   AND  Continue For Loop
    #\   ...   AND  FAIL
    \   ${resource}=  Get Element  ${activeAlarm}  resource/resource/*
    \   Log  ${resource.tag}
    \   ${resource_name}=  Get Element  ${activeAlarm}  resource/resource/${resource.tag}
    \   Log  ${resource_name.text}
    \   Run Keyword If  '${resource_name.text}' == '${targetResource}'  Append To List  ${activeAlarmList}  ${alarm}
    
    Log  ${activeAlarmList}
    
    [return]  ${activeAlarmList}


Verify Alarms On Resource
    [Documentation]        Get Alarms On Target
    ...                    Fails if status is not connected
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${odl_sessions}  ${node}  ${targetResource}  ${expectAlarmList}
    @{activeAlarmList}=  Get Alarms On Resource  ${odl_sessions}  ${node}  ${targetResource}
    
	Sort List  ${activeAlarmList}
	Sort List  ${expectAlarmList}
    Lists Should Be Equal  ${activeAlarmList}  ${expectAlarmList}  msg=the expect alarm list is ${expectAlarmList} while actually the active alarm list is ${activeAlarmList}
    
    
Wait Until Verify Alarms On Resource Succeeds
    [Documentation]        Get Alarms On Target
    ...                    Fails if status is not connected
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${odl_sessions}  ${node}  ${targetResource}  ${expectAlarmList}  ${timeout}
    Wait Until Keyword Succeeds  ${timeout}  10 sec  Verify Alarms On Resource  ${odl_sessions}  ${node}  ${targetResource}  ${expectAlarmList}
    

Load Pre Default Provision
    [Documentation]        Load Pre Default Provision
    ...                    generally provision xponder, shelves and circuit-packs
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${odl_sessions}  ${node}
    # ${data}=  Set Variable  <yang-patch xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-patch"><patch-id>Load Pre Defualt Provision</patch-id><edit><edit-id>Load Pre Defualt Provision</edit-id><operation>merge</operation><target>/</target><value><org-openroadm-device xmlns="http://org/openroadm/device"><xponder><xpdr-type>tpdr</xpdr-type><xpdr-number>1</xpdr-number><xpdr-port><index>7</index><circuit-pack-name>xcvr-0/1/2</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/2</port-name></xpdr-port><xpdr-port><index>8</index><circuit-pack-name>xcvr-0/1/3</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/3</port-name></xpdr-port><xpdr-port><index>5</index><circuit-pack-name>xcvr-0/1/0</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/0</port-name></xpdr-port><xpdr-port><index>6</index><circuit-pack-name>xcvr-0/1/1</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/1</port-name></xpdr-port><xpdr-port><index>3</index><circuit-pack-name>xcvr-0/0/4</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/4</port-name></xpdr-port><xpdr-port><index>4</index><circuit-pack-name>xcvr-0/0/6</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/6</port-name></xpdr-port><xpdr-port><index>1</index><circuit-pack-name>xcvr-0/0/0</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/0</port-name></xpdr-port><xpdr-port><index>2</index><circuit-pack-name>xcvr-0/0/2</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/2</port-name></xpdr-port></xponder><shelves><shelf-name>shelf-0</shelf-name><shelf-type>SHELF</shelf-type><equipment-state>reserved-for-facility-available</equipment-state><rack>rack-0</rack><shelf-position>0</shelf-position><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></shelves><circuit-packs><circuit-pack-name>xcvr-0/0/6</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/6</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/6</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/6</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>pic-0/0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0</subSlot><parent-circuit-pack><cp-slot-name>slot-0/0</cp-slot-name><circuit-pack-name>fpc-0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>pic-0/1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1</subSlot><parent-circuit-pack><cp-slot-name>slot-0/1</cp-slot-name><circuit-pack-name>fpc-0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/2</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/2</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/2</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/2</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/1</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/1</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/1</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/1</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/2</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/2</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/2</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/2</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/4</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/4</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC-</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/4</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/4</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/3</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/3</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/3</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/3</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-4</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-7</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/0</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/0</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/0</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/0</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/0</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/0</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/0</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/0</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-2</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-5</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>psm-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>PSM</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-1</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-3</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-6</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-3</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-4</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fpc-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FPC</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>psm-1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>PSM</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-2</slot><shelf>shelf-0</shelf><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs></org-openroadm-device></value></edit></yang-patch>
    ${data}=  Set Variable  <yang-patch xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-patch"><patch-id>Load Pre Defualt Provision</patch-id><edit><edit-id>Load Pre Defualt Provision</edit-id><operation>merge</operation><target>/</target><value><org-openroadm-device xmlns="http://org/openroadm/device"><xponder><xpdr-type>tpdr</xpdr-type><xpdr-number>1</xpdr-number><xpdr-port><index>7</index><circuit-pack-name>xcvr-0/1/2</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/2</port-name></xpdr-port><xpdr-port><index>8</index><circuit-pack-name>xcvr-0/1/3</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/3</port-name></xpdr-port><xpdr-port><index>5</index><circuit-pack-name>xcvr-0/1/0</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/0</port-name></xpdr-port><xpdr-port><index>6</index><circuit-pack-name>xcvr-0/1/1</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/1</port-name></xpdr-port><xpdr-port><index>3</index><circuit-pack-name>xcvr-0/0/4</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/4</port-name></xpdr-port><xpdr-port><index>4</index><circuit-pack-name>xcvr-0/0/6</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/6</port-name></xpdr-port><xpdr-port><index>1</index><circuit-pack-name>xcvr-0/0/0</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/0</port-name></xpdr-port><xpdr-port><index>2</index><circuit-pack-name>xcvr-0/0/2</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/2</port-name></xpdr-port></xponder><shelves><shelf-name>shelf-0</shelf-name><shelf-type>SHELF</shelf-type><equipment-state>reserved-for-facility-available</equipment-state><rack>rack-0</rack><shelf-position>0</shelf-position><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></shelves><circuit-packs><circuit-pack-name>xcvr-0/0/6</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/6</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/6</port-name><port-type>qsfp28-port</port-type><circuit-id>1006</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-client</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/6</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>pic-0/0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0</subSlot><parent-circuit-pack><cp-slot-name>slot-0/0</cp-slot-name><circuit-pack-name>fpc-0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>pic-0/1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1</subSlot><parent-circuit-pack><cp-slot-name>slot-0/1</cp-slot-name><circuit-pack-name>fpc-0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/2</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/2</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/2</port-name><port-type>qsfp28-port</port-type><circuit-id>1002</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-client</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/2</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/1</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/1</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/1</port-name><port-type>cfp2dco-port</port-type><circuit-id>1011</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/1</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/2</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/2</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/2</port-name><port-type>cfp2dco-port</port-type><circuit-id>1012</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/2</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/4</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/4</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/4</port-name><port-type>qsfp28-port</port-type><circuit-id>1004</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-client</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/4</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/3</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/3</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/3</port-name><port-type>cfp2dco-port</port-type><circuit-id>1013</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/3</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-4</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FTU</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-7</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/0</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/0</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/0</port-name><port-type>qsfp28-port</port-type><circuit-id>1000</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-client</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/0</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/0</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/0</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>PIC</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/0</port-name><port-type>cfp2dco-port</port-type><circuit-id>1010</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/0</subSlot><equipment-state>reserved-for-facility-available</equipment-state><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-2</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FTU</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-5</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>psm-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>PSM</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-1</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-3</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FTU</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-6</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FTU</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-3</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FTU</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-4</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fpc-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FPC</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>psm-1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>PSM</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-2</slot><shelf>shelf-0</shelf><due-date>2019-02-18T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs></org-openroadm-device></value></edit></yang-patch>
    ${resp}=  Patch Request   @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/org-openroadm-device:org-openroadm-device   data=${data}    headers=${patch_headers}    allow_redirects=False

	check status line    ${resp}     200

	
Verify Interface Operational Status
    [Documentation]        Verify Interface Operational Status 
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    ...                    | - node : interface name
	...                    | - status : expected Interface Operational Status
    [Arguments]             ${odl_sessions}  ${node}  ${interface}  ${status}
	
	&{intf}  Create Dictionary  interface-name=${interface}  interface-operational-state=${status}
	@{intf_info}    Create List    ${intf}
    &{dev_info}   Create Dictionary   interface=${intf_info}       
    &{payload}   Create Dictionary   org-openroadm-device=${dev_info}
	${resp}=  Send Get Request And Verify Output Is Correct  ${odl_sessions}  ${node}  ${payload}
    [Return]  ${resp}


Delete all interface
    [Documentation]   Retrieve system configuration and delete all interfaces
    [Arguments]       ${odl_sessions}  ${node}
    Log               Retrieve all exist interfaces and delete them all
    &{openroadm_xpath}            create dictionary           org-openroadm-device=org-openroadm-device
    ${resp}=                      Send Get Request And Verify Status Of Response Is OK    ${odl_sessions}   ${node}   ${openroadm_xpath}
	${resp_content}=              Decode Bytes To String   ${resp.content}    UTF-8
    @{interfaces_name}            Get Elements      ${resp_content}    /org-openroadm-device/interface/name
	Log List                      ${interfaces_name}
    : FOR    ${interface_name}    IN   @{interfaces_name}
	\        Log                  ${interface_name.text}
    \        &{interface}         create dictionary    interface-name=${interface_name.text}
    \        @{delinter}          create list    ${interface}
    \        &{dev_info}          create dictionary   interface=${delinter}
    \        &{payload}           create dictionary   org-openroadm-device=${dev_info}
    \        Send Delete Request And Verify Status Of Response Is OK    ${odl_sessions}   ${node}    ${payload}

Get Running Config
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${dictNetconfParams}
    Log  Fetching config via Restconf GET method
	Log  ${tv}
    ${urlhead}=    Retrieve URL Parent  ${dictNetconfParams}

    ${resp}=             Get Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${urlhead}/    headers=${get_headers}    allow_redirects=False
	
	check status line    ${resp}     200
	${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8
	Log  ${resp_content}
    [return]  ${resp_content}
