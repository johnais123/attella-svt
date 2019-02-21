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

*** Keywords ***
check status line
    [Documentation]   check restconf operation return status line
    [Arguments]    ${get_resp}    ${statusId}  
    ${status_is_expected}              Run Keyword And Return Status    Should Be Equal As Strings    ${get_resp.status_code}    ${statusId} 
    Run Keyword If          '${status_is_expected}' != 'True'    Run Keywords     Fail     check status line and status id isn't ${statusId}    
    ...                                   AND     Log   Response: ${get_resp.content}
    

Send Get Request
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${dictNetconfParams}
    Log                     Fetching config via Restconf GET method
    ${urlhead}=    Retrieve URL Parent  ${dictNetconfParams}

    ${resp}=             Get Request  @{odl_sessions}[${OPR_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${urlhead}/    headers=${get_headers}    allow_redirects=False
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
    ${data}=    Set variable    <yang-patch xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-patch"><patch-id>Patch operation</patch-id><edit><edit-id>${editId}</edit-id><operation>merge</operation><target>/</target><value>${url}</value></edit></yang-patch>
    log    ${data}    
    ${resp}=            Patch Request   @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${urlhead}   data=${data}    headers=${patch_headers}    allow_redirects=False
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
    [return]  ${resp}


Send Delete Request With Complete Url
    [Documentation]   delete configuration
    [Arguments]    ${odl_sessions}  ${node}  ${fullUrl}
    Log                     delete configuration
    ${resp}             Delete Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/${fullUrl}    headers=${delete_headers}    allow_redirects=False
    check status line    ${resp}     200     
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
    [Documentation]   display file relate status message via file transfer Rpc command 
    [Arguments]    ${odl_sessions}   ${node}   ${testfile}
    ${urlhead}    set variable    org-openroadm-file-transfer:show-file 
    :For  ${FileNm}  in   @{testfile}
    \    ${FileNm}    convert to string    ${FileNm}
    \    log   ${FileNm}
    \    ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>${FileNm}</filename></input>
    \    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \    check status line    ${resp}     200  
    \    ${elem} =  get element text  ${resp.text}    status
    \    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    \    ${elem2} =     get elements texts    ${resp.text}    status-message
    \    List Should Contain Value    ${elem2}    ${FileNm}


Rpc Command For Show All File
    [Documentation]   display file relate status message via file transfer Rpc command 
    [Arguments]    ${odl_sessions}   ${node}    ${allfilelist}
    ${urlhead}   set variable    org-openroadm-file-transfer:show-file
    ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>**</filename></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200       
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    ${elem2} =     get elements texts    ${resp.text}    status-message
    ${allfilelist}=    Remove Duplicates    ${allfilelist}
    Sort List   ${elem2}    
    Sort List   ${allfilelist}
    log many    ${elem2}    ${allfilelist}
    Lists Should Be Equal  ${elem2}   ${allfilelist}

    
Rpc Command For Delete File
    [Documentation]   Delete file via file transfer Rpc command 
    [Arguments]    ${odl_sessions}   ${node}   ${testfile}
    ${urlhead}   set variable    org-openroadm-file-transfer:delete-file
    :For  ${FileNm}  in   @{testfile}
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>${FileNm}</filename></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \     check status line    ${resp}     200    
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    \     ${urlhead}    set variable    org-openroadm-file-transfer:delete-file
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>${FileNm}</filename></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \     check status line    ${resp}     200  
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    \     ${elem2} =     get elements texts    ${resp.text}    status-message
    \     List Should Not Contain Value    ${elem2}    ${FileNm}

    
Rpc Command For Upload File
    # no way to check remote sftp server file ,so i via download to my device again and check new file whether upload to sftp server
    [Documentation]   Upload file via file transfer Rpc command 
    [Arguments]    ${odl_sessions}   ${node}   ${filelist}   ${remotePath}
    :For  ${FileNm}  in   @{filelist}
    \     ${urlhead}   set variable    org-openroadm-file-transfer:transfer
    \     ${fullremotePath}=    set variable     ${remotesftpPath}/${FileNm}
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><action>upload</action><local-file-path>${FileNm}</local-file-path><remote-file-path>${fullremotePath}</remote-file-path></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}  
    \     check status line    ${resp}     200 
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><action>download</action><local-file-path>${FileNm}</local-file-path><remote-file-path>${fullremotePath}</remote-file-path></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \     check status line    ${resp}     200 
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    \     sleep  10
    \     ${urlhead}   set variable    org-openroadm-file-transfer:show-file
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><filename>${FileNm}</filename></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \     check status line    ${resp}     200  
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
    \     ${elem2} =     get elements texts    ${resp.text}    status-message
    \     List Should Contain Value    ${elem2}    ${FileNm}

    
Rpc Command For Download File
    [Documentation]   Upload file via file transfer Rpc command 
    [Arguments]    ${odl_sessions}   ${node}   ${filelist}   ${remotePath}
    ${urlhead}   set variable    org-openroadm-file-transfer:transfer
    :For  ${FileNm}  in   @{filelist}
    \     ${fullremotePath}=    set variable     ${remotesftpPath}/${FileNm}
    \     ${data}      set variable    <input xmlns="http://org/openroadm/file-transfer"><action>download</action><local-file-path>${FileNm}</local-file-path><remote-file-path>${fullremotePath}</remote-file-path></input>
    \     ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    \     check status line    ${resp}     200 
    \     ${elem} =  get element text  ${resp.text}    status
    \     Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful


RPC Create Tech Info
    [Documentation]   Collects all log data for debugging and place it in a location accessible via RPC create-tech-info 
    [Arguments]    ${odl_sessions}   ${node}   ${shelfid}   ${logoption}
    ${urlhead}   set variable    org-openroadm-device:create-tech-info
    ${data}      set variable   <input xmlns="http://org/openroadm/device"><shelf-id>${shelfid}</shelf-id><log-option>${logoption}</log-option></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200 
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful


Rpc Command For Warm Reload Device
    [Documentation]   Restart a resource with warm option via Rpc command 
    ...                    Args:
    ...                    | - deviceName : device0 or device1
    [Arguments]    ${odl_sessions}   ${node}   ${timeout}    ${interval}   ${deviceName}
    ${urlhead}   set variable    org-openroadm-de-operations:restart
    ${data}      set variable    <input xmlns="http://org/openroadm/de/operations"><option>warm</option></input>
    ${resp}=     Send Rpc Command    ${odl_sessions}    ${node}    ${urlhead}    ${data}
    check status line    ${resp}     200  
    ${elem} =  get element text  ${resp.text}    status
    Run Keyword If      '${elem}' == '${succ_meg}'     Log  the status display correct is Successful
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
    Reconnect Device And Verification reboot successful    ${deviceName}
    Mount vAttella On ODL Controller    ${odl_sessions}    ${timeout}    ${interval}   ${node}
    sleep   15s 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}   ${timeout}    ${interval}   ${node}


Mount vAttella On ODL Controller
    [Documentation]    Mounts vAttella ODl controller and verifies the mounted capabilities of junos device
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node  : mount node in ODL
    ...                    | - timeout : How long time script should wait to check mount status (Time in robot format,e.g. 40 minute, 40 min 30 s)
    ...                    | - interval: Specifies the interval at which script should check for mount status of junos device on controller
    ...                    | Uses global variables "headers", "karaf log file"

    [Arguments]    ${odl_sessions}   ${timeout}  ${interval}  ${node} 
    ${fullUrl}                Set Variable    <node xmlns="urn:TBD:params:xml:ns:yang:network-topology"><node-id>${node}
    ${resp}             Delete Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}     headers=${delete_headers}    allow_redirects=False
    # check status line    ${resp}     200 
    ${data}                Set Variable    <node xmlns="urn:TBD:params:xml:ns:yang:network-topology"><node-id>${node}</node-id><port xmlns="urn:opendaylight:netconf-node-topology">830</port><password xmlns="urn:opendaylight:netconf-node-topology">Embe1mpls</password><username xmlns="urn:opendaylight:netconf-node-topology">root</username><tcp-only xmlns="urn:opendaylight:netconf-node-topology">false</tcp-only><host xmlns="urn:opendaylight:netconf-node-topology">${node}</host><keepalive-delay xmlns="urn:opendaylight:netconf-node-topology">0</keepalive-delay><actor-response-wait-time xmlns="urn:opendaylight:netconf-node-topology">100</actor-response-wait-time><schema-cache-directory xmlns="urn:opendaylight:netconf-node-topology">barry</schema-cache-directory><yang-module-capabilities xmlns="urn:opendaylight:netconf-node-topology"><capability>urn:ietf:params:xml:ns:netconf:base:1.0?module=ietf-netconf&amp;revision=2011-06-01</capability><capability>urn:ietf:params:xml:ns:yang:ietf-inet-types?module=ietf-inet-types&amp;revision=2013-07-15</capability><capability>urn:ietf:params:xml:ns:yang:ietf-yang-types?module=ietf-yang-types&amp;revision=2013-07-15</capability><capability>urn:ietf:params:xml:ns:netconf:base:1.0?module=ietf-netconf&amp;revision=2011-06-01</capability><capability>http://org/openroadm/user-mgmt?module=org-openroadm-user-mgmt&amp;revision=2017-12-15</capability><capability>http://org/openroadm/tca?module=org-openroadm-tca&amp;revision=2017-12-15</capability><capability>http://org/openroadm/switching-pool-types?module=org-openroadm-switching-pool-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/resource?module=org-openroadm-resource&amp;revision=2017-12-15</capability><capability>http://org/openroadm/resource/types?module=org-openroadm-resource-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/probableCause?module=org-openroadm-probable-cause&amp;revision=2017-12-15</capability><capability>http://org/openroadm/port/types?module=org-openroadm-port-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/pm?module=org-openroadm-pm&amp;revision=2017-12-15</capability><capability>http://org/openroadm/pm/types?module=org-openroadm-pm-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/otn-common-types?module=org-openroadm-otn-common-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/manifest-file?module=org-openroadm-manifest-file&amp;revision=2017-12-15</capability><capability>http://org/openroadm/maintenance?module=org-openroadm-maintenance&amp;revision=2017-12-15</capability><capability>http://org/openroadm/layerRate?module=org-openroadm-layerRate&amp;revision=2017-12-15</capability><capability>http://org/openroadm/equipment/states/types?module=org-openroadm-equipment-states-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/common-types?module=org-openroadm-common-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/alarm?module=org-openroadm-alarm&amp;revision=2017-12-15</capability><capability>http://org/openroadm/database?module=org-openroadm-database&amp;revision=2017-12-15</capability><capability>http://org/openroadm/de/operations?module=org-openroadm-de-operations&amp;revision=2017-12-15</capability><capability>http://org/openroadm/device?module=org-openroadm-device&amp;revision=2017-12-15</capability><capability>http://org/openroadm/ethernet-interfaces?module=org-openroadm-ethernet-interfaces&amp;revision=2017-12-15</capability><capability>http://org/openroadm/file-transfer?module=org-openroadm-file-transfer&amp;revision=2017-12-15</capability><capability>http://org/openroadm/fwdl?module=org-openroadm-fwdl&amp;revision=2017-12-15</capability><capability>http://org/openroadm/interfaces?module=org-openroadm-interfaces&amp;revision=2017-06-26</capability><capability>http://org/openroadm/lldp?module=org-openroadm-lldp&amp;revision=2017-12-15</capability><capability>http://org/openroadm/maintenance-loopback?module=org-openroadm-maintenance-loopback&amp;revision=2017-12-15</capability><capability>http://org/openroadm/maintenance-testsignal?module=org-openroadm-maintenance-testsignal&amp;revision=2017-12-15</capability><capability>http://org/openroadm/media-channel-interfaces?module=org-openroadm-media-channel-interfaces&amp;revision=2017-12-15</capability><capability>http://org/openroadm/network-media-channel-interfaces?module=org-openroadm-network-media-channel-interfaces&amp;revision=2017-12-15</capability><capability>http://org/openroadm/optical-channel-interfaces?module=org-openroadm-optical-channel-interfaces&amp;revision=2017-12-15</capability><capability>http://org/openroadm/optical-transport-interfaces?module=org-openroadm-optical-transport-interfaces&amp;revision=2017-12-15</capability><capability>http://org/openroadm/otn-common?module=org-openroadm-otn-common&amp;revision=2017-06-26</capability><capability>http://org/openroadm/otn-odu-interfaces?module=org-openroadm-otn-odu-interfaces&amp;revision=2017-12-15</capability><capability>http://org/openroadm/otn-otu-interfaces?module=org-openroadm-otn-otu-interfaces&amp;revision=2017-12-15</capability><capability>http://org/openroadm/physical/types?module=org-openroadm-physical-types&amp;revision=2017-12-15</capability><capability>http://org/openroadm/pluggable-optics-holder-capability?module=org-openroadm-pluggable-optics-holder-capability&amp;revision=2017-12-15</capability><capability>http://org/openroadm/port-capability?module=org-openroadm-port-capability&amp;revision=2017-12-15</capability><capability>http://org/openroadm/prot/otn-linear-aps?module=org-openroadm-prot-otn-linear-aps&amp;revision=2017-12-15</capability><capability>http://org/openroadm/rstp?module=org-openroadm-rstp&amp;revision=2017-12-15</capability><capability>http://org/openroadm/de/swdl?module=org-openroadm-swdl&amp;revision=2017-12-15</capability><capability>http://org/openroadm/syslog?module=org-openroadm-syslog&amp;revision=2017-12-15</capability><capability>http://org/openroadm/wavelength-map?module=org-openroadm-wavelength-map&amp;revision=2017-12-15</capability><capability>urn:ietf:params:xml:ns:yang:iana-afn-safi?module=iana-afn-safi&amp;revision=2013-07-04</capability><override>false</override></yang-module-capabilities></node>
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


Get Current All Pm Information On Target Resource
    [Documentation]        Get Pm On Target
    ...                    Fails if doesn't exist this kind of resouce pm
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node : mount node in ODL
    [Arguments]             ${odl_sessions}  ${node}   ${targetResource}
    
    &{payload}   create_dictionary   current-pm-list=${null}
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8
    ${root}=                 Parse XML    ${resp_content}
   
    @{currentPmRes}  Get Elements  ${root}  current-pm-entry
    Log  ${currentPmRes}

    :FOR  ${pmRes}  IN  @{currentPmRes}
    \   ${restype}=  Get Element  ${pmRes}  pm-resource-type
    \   ${restype_ext}=  Get Element  ${pmRes}  pm-resource-type-extension
    \   ${resinst}=  Get Element  ${pmRes}  pm-resource-instance
    \   Log  ${restype.text}
    \   Log  ${resinst.text}
    \   @{ret}     Split String      ${resinst.text}    name=
    \   ${lastRes}     Get From List     ${ret}    -1
    \   ${res}     Get Substring     ${lastRes}  0  -1
    \   Run Keyword If  ${res} == '${targetResource}'    EXIT For Loop
    # ${args}   run keyword if   '${score}' == '${score1}'   Run Keywords    set variable   dsfsfs  AND  log  222222 
    # \   Log  ${raiseTime.text}
    # \   Log  ${additional_detail.text}
    # \   Log  ${severity.text}
    # \   @{resource}=  Combine Lists  ${resource_cp}  ${resource_port}  ${resource_xc}  ${resource_intf}
    # \   Log  ${resource}
    # \   ${len}=  Get Length    ${resource}
    # \   Run Keyword If  '${len}' != '1'  Run Keywords  Log  Get $(len) resources in one active Alarm entity
    # \   ...   AND  FAIL
    # \   ${resource}=  Get Element  ${activeAlarm}  resource/resource/*
    # \   Log  ${resource.tag}
    # \   ${resource_name}=  Get Element  ${activeAlarm}  resource/resource/${resource.tag}
    # \   Log  ${resource_name.text}
    # \   Run Keyword If  '${resource_name.text}' == '${targetResource}'  Append To List  ${activeAlarmList}  ${additional_detail.text}
    
    # Log  ${activeAlarmList}
    log    ${pmRes}
    [return]  ${pmRes}

Get Current Spefic Pm Entry
    [Documentation]        Get special Pm On Target
    ...                    Fails if it doesn't exist special pm statistics on this resource
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node :Under testing Device
    ...                    |  
    [Arguments]             ${odl_sessions}  ${node}   ${targetResource}   ${targetPmEntry}
    ${underTestRes}=      Get Current All Pm Information On Target Resource    ${odl_sessions}   ${node}   ${targetResource} 
    @{currentPmRes}  Get Elements  ${underTestRes}  current-pm
    :FOR  ${pmEntry}  IN  @{currentPmRes}
    \   ${pmtype}=  Get Element  ${pmEntry}  type
    \   ${expmtype_ext}=  Get Element  ${pmEntry}  extension
    \   Log  ${pmtype.text}
    \   Log  ${expmtype_ext.text} 
    \   Run Keyword If  '${pmtype.text}' == '${targetPmEntry}' or '${expmtype_ext.text}' == '${targetPmEntry}'  EXIT For Loop
    log    ${pmEntry}
    [return]  ${pmEntry}


Get current Spefic Pm Statistic 
    [Documentation]        Get special Pm Statistics On Target
    ...                    Fails if it doesn't exist special pm statistics on this resource
    ...                    Args:
    ...                    | - odl_sessions : config/operational sessions to ODL controller
    ...                    | - node :Under testing Device
    ...                    |  
    [Arguments]             ${odl_sessions}   ${node}    ${targetResource}   ${targetPmEntry}   ${pmInterval}    ${tarPmLoc}  ${tarPmDirect}
    ${underTestPmEntry}=     Get Current Spefic Pm Entry    ${odl_sessions}   ${node}   ${targetResource}    ${targetPmEntry}
    # :FOR  ${pmEntryatt}  IN  @{underTestPmEntry}
    ${pmlocation}=   Get Element  ${underTestPmEntry}   location
    ${pmdirection}=  Get Element  ${underTestPmEntry}   direction
    log    ${pmlocation.text}
    log    ${pmdirection.text}
    Run keyword If  '${pmlocation.text}' == '${tarPmLoc}' and '${pmdirection.text}' == '${tarPmDirect}'  log  current resouce ${targetResource} and current pm ${targetPmEntry} entry exsits ${pmdirection.text} pm on ${pmlocation.text}
    ...       ELSE   Run Keywords    Fail  no pm statistics on current ${targetResource} and current ${targetPmEntry} pm 
    @{currentPmStatis}  Get Elements  ${underTestPmEntry}   measurement
    :FOR  ${pmStat}  IN  @{currentPmStatis}
    \   ${pmGranularity}=  Get Element  ${pmStat}     granularity
    \   ${pmParameterUnit}=  Get Element  ${pmStat}   pmParameterUnit
    \   ${pmParameterValue}=  Get Element  ${pmStat}  pmParameterValue
    \   ${pmvalidity}=  Get Element  ${pmStat}          validity
    \   Log  ${pmGranularity.text}
    \   Log  ${pmParameterUnit.text} 
    \   Log  ${pmParameterValue.text} 
    \   Log  ${pmvalidity.text}
    \   Run keyword If  '${pmGranularity.text}' == '${pmInterval}'   EXIT For Loop
    Log   ${pmParameterValue.text} 
    [return]   ${pmParameterValue.text} 


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
    \   @{resource_cp}=  Get Elements  ${activeAlarm}  resource/resource/circuit-pack-name
    \   @{resource_port}=  Get Elements  ${activeAlarm}  resource/resource/port-name
    \   @{resource_xc}=  Get Elements  ${activeAlarm}  resource/resource/connection-name
    \   @{resource_intf}=  Get Elements  ${activeAlarm}  resource/resource/interface-name
    \   Log  ${id.text}
    \   Log  ${raiseTime.text}
    \   Log  ${additional_detail.text}
    \   Log  ${severity.text}
    \   @{resource}=  Combine Lists  ${resource_cp}  ${resource_port}  ${resource_xc}  ${resource_intf}
    \   Log  ${resource}
    \   ${len}=  Get Length    ${resource}
    \   Run Keyword If  '${len}' != '1'  Run Keywords  Log  Get $(len) resources in one active Alarm entity
    \   ...   AND  FAIL
    \   ${resource}=  Get Element  ${activeAlarm}  resource/resource/*
    \   Log  ${resource.tag}
    \   ${resource_name}=  Get Element  ${activeAlarm}  resource/resource/${resource.tag}
    \   Log  ${resource_name.text}
    \   Run Keyword If  '${resource_name.text}' == '${targetResource}'  Append To List  ${activeAlarmList}  ${additional_detail.text}
    
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
    ${data}=  Set Variable  <yang-patch xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-patch"><patch-id>Load Pre Defualt Provision</patch-id><edit><edit-id>Load Pre Defualt Provision</edit-id><operation>merge</operation><target>/</target><value><org-openroadm-device xmlns="http://org/openroadm/device"><xponder><xpdr-type>tpdr</xpdr-type><xpdr-number>1</xpdr-number><xpdr-port><index>7</index><circuit-pack-name>xcvr-0/1/2</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/2</port-name></xpdr-port><xpdr-port><index>8</index><circuit-pack-name>xcvr-0/1/3</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/3</port-name></xpdr-port><xpdr-port><index>5</index><circuit-pack-name>xcvr-0/1/0</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/0</port-name></xpdr-port><xpdr-port><index>6</index><circuit-pack-name>xcvr-0/1/1</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/1/1</port-name></xpdr-port><xpdr-port><index>3</index><circuit-pack-name>xcvr-0/0/4</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/4</port-name></xpdr-port><xpdr-port><index>4</index><circuit-pack-name>xcvr-0/0/6</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/6</port-name></xpdr-port><xpdr-port><index>1</index><circuit-pack-name>xcvr-0/0/0</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/0</port-name></xpdr-port><xpdr-port><index>2</index><circuit-pack-name>xcvr-0/0/2</circuit-pack-name><eqpt-srg-id>0</eqpt-srg-id><port-name>port-0/0/2</port-name></xpdr-port></xponder><shelves><shelf-name>shelf-0</shelf-name><shelf-type>SHELF</shelf-type><equipment-state>reserved-for-facility-available</equipment-state><rack>rack-0</rack><shelf-position>0</shelf-position><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></shelves><circuit-packs><circuit-pack-name>xcvr-0/0/6</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/6</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>100G-QSFP28</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/6</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/6</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>pic-0/0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0</subSlot><parent-circuit-pack><cp-slot-name>slot-0/0</cp-slot-name><circuit-pack-name>fpc-0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>8X100G-QSFP28</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>pic-0/1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1</subSlot><parent-circuit-pack><cp-slot-name>slot-0/1</cp-slot-name><circuit-pack-name>fpc-0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>4X200G-CFP2DCO</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/2</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/2</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>100G-QSFP28</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/2</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/2</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/1</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/1</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>200G-CFP2DCO</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/1</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/1</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/2</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/2</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>200G-CFP2DCO</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/2</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/2</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/4</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/4</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>100G-QSFP28</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/4</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/4</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/3</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/3</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>200G-CFP2DCO</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/3</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/3</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-4</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-7</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/0/0</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/0/0</cp-slot-name><circuit-pack-name>pic-0/0</circuit-pack-name></parent-circuit-pack><circuit-pack-type>100G-QSFP28</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/0/0</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/0/0</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>xcvr-0/1/0</circuit-pack-name><parent-circuit-pack><cp-slot-name>slot-0/1/0</cp-slot-name><circuit-pack-name>pic-0/1</circuit-pack-name></parent-circuit-pack><circuit-pack-type>200G-CFP2DCO</circuit-pack-type><slot>slot-0</slot><ports><port-name>port-0/1/0</port-name><port-type>qsfp28-port</port-type><circuit-id>bar</circuit-id><logical-connection-point>foo</logical-connection-point><port-qual>xpdr-network</port-qual><administrative-state>inService</administrative-state></ports><shelf>shelf-0</shelf><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0/1/0</subSlot><equipment-state>reserved-for-facility-available</equipment-state><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-2</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-5</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>psm-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-PowerSupply</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-1</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-3</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-6</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-3</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fan-1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-T-Fan-Tray</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-4</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>fpc-0</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>FPC</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-0</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs><circuit-packs><circuit-pack-name>psm-1</circuit-pack-name><circuit-pack-mode>NORMAL</circuit-pack-mode><subSlot>slot-0</subSlot><circuit-pack-type>ACX6180-PowerSupply</circuit-pack-type><equipment-state>reserved-for-facility-available</equipment-state><slot>slot-2</slot><shelf>shelf-0</shelf><is-pluggable-optics>false</is-pluggable-optics><due-date>2018-12-31T00:00:00Z</due-date><administrative-state>inService</administrative-state></circuit-packs></org-openroadm-device></value></edit></yang-patch>
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
	
	&{intf}  Create Dictionary  interface-name=${interface}  interface-administrative-state=${status}
	@{intf_info}    Create List    ${intf}
    &{dev_info}   Create Dictionary   interface=${intf_info}       
    &{payload}   Create Dictionary   org-openroadm-device=${dev_info}
	${resp}=  Send Get Request And Verify Output Is Correct  ${odl_sessions}  ${node}  ${payload}
    [Return]  ${resp}