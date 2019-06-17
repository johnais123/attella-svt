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
Library         random

*** Variables ***


*** Keywords ***   
Preconfiguration Netconf Feature
    [Documentation]        Execute Pre-configuration before connecting to controller
    [Arguments]             @{dut_list} 
    @{cmd_list}            Set Variable
    ...                     set system services netconf ssh
    ...                     set system commit ignore-xpath-failure
    ...                     set system services netconf rfc-compliant
    ...                     set system services netconf unified unhide
    ...                     set system services netconf traceoptions file size 100m
    ...                     set system services netconf traceoptions flag all
    ...                     set system services netconf notification
    ...                     set system services extension-service request-response grpc clear-text port 32767
    ...                     set system services extension-service request-response grpc skip-authentication
    ...                     set interfaces lo0 unit 0 family inet address 127.0.0.1/32
                    
    :For  ${res}  in  @{dut_list}
    \    ${rx} =     Get Handle      resource=${res}
    \    Execute config Command On Device     ${rx}     command_list=@{cmd_list}
    \    Commit configuration  ${rx}   
    

Power cycle
    [Documentation]   Perform power cycle via software
    [Arguments]
    Log           Begin to do PowerCycle via software control power managemer  
    powersv.open
    @{Outlet_list}     Set variable   ${OutletItems}
    :FOR    ${Outlet_id}  in  @{Outlet_list}
    \       ${result}=   powersv.set Outlet Ctrl State   ${Outlet_id}   ${Outlet_Status_OFF}
    \       Sleep  10
    \       ${result}=   powersv.set Outlet Ctrl State   ${Outlet_id}   ${Outlet_Status_ON}  
    powersv.close
    
Reconnect Device And Verification reboot successful 
    [Documentation]   Perform power cycle via software
    ...                    Args:
    ...                    |- node : device0 or device1
    [Arguments]      ${node} 
    Log           Begin to do reload via rpc command
    Sleep   300s     reason=Wait before trying to reconnect after reboot
    ${r0} =     Get Handle      resource=${node}
    Wait until keyword succeeds    15 min    10 sec    Reconnect to Device    device=${r0}
    # ${r0} =     Get Handle    resource=r0
    ${output} =     Execute Cli command on device     ${r0}     command=show system uptime | display xml    timeout=${360}
    ${sysup} =  Get Element   ${output}   system-uptime-information/system-uptime-information-brief/time-length
    Log to Console    ${sysup.text}
    @{timelist}     Split String      ${sysup.text}    : 
    ${hours}        Get From List    ${timelist}    0 
    ${mintus}        Get From List    ${timelist}    1
    ${min1}     Evaluate      int('${mintus}'[0])
    run keyword if  ${min1} == 0   log   pass   ELSE  Fail   reboot time shown 10 min and probably reboot unsucessful
    ${mintus}     Evaluate      int('${mintus}'[1])
    log many    ${hours}    ${mintus}
    Run Keyword if   '${hours}'== '00' and ${mintus} < 5    log  reload successful   ELSE   Fail   reboot time excess 5 min
    # 02:32:04

Returns the given minute of current time
    [Documentation]   Returns the given minute of current time
    ...                    Args:
    ...                    |- node : device0 or device1
    [Arguments]      ${node} 
    ${r0} =     Get Handle      resource=${node}
    Wait until keyword succeeds    2 min    10 sec    Reconnect to Device    device=${r0}
    ${sDatestring}=    Execute shell command on device     device=${r0}       command=date
    # ${sDate}   set variable     Mon Mar 18 01:50:07 UTC 2019
    ${sTime} =     Evaluate   '${sDatestring}'.split(" ")[3]     string
    ${sMin} =     Evaluate   '${sDatestring}'.split(":")[1]     string
    log     ${sMin}
    [return]  ${sMin}


Get Ethernet Intface Name From Client Intface
    [Documentation]        Get Ethernet Intface Name From Client Intface
    ...                    Args:
    ...                    | - strClientIntf : client interface
    [Arguments]             ${strClientIntf}
	${resp}=  getEthernetIntfFromClientIntf  ${strClientIntf}
	[return]  ${resp}
	
	
Get Otu4 Intface Name From Client Intface
    [Documentation]        Get Otu4 Intface Name From Client Intface
    ...                    Args:
    ...                    | - strClientIntf : client interface
    [Arguments]             ${strClientIntf}
	${resp}=  getOtu4IntfFromClientIntf  ${strClientIntf}
	[return]  ${resp}
	
Get Line ODU Intface Name From Client Intface
    [Documentation]        Get ODU Intface Name From Client Intface
    ...                    Args:
    ...                    | - strClientIntf : client interface
    [Arguments]             ${strClientIntf}
	${resp}=  getLineOduIntfNameFromClientIntf  ${strClientIntf}
	[return]  ${resp}
	
	
Get OTU Intface Name From ODU Intface
    [Documentation]        Get OTU Intface Name From ODU Intface
    ...                    Args:
    ...                    | - strOduIntf : ODU interface
    [Arguments]             ${strOduIntf}
	${resp}=  getOtuIntfNameFromOduIntf  ${strOduIntf}
	Log  ${resp}
	[return]  ${resp}
	
	
Get OCH Intface Name From OTU Intface
    [Documentation]        Get OCH Intface Name From OTU Intface
    ...                    Args:
    ...                    | - strOtuIntf : OTU interface
    [Arguments]             ${strOtuIntf}
	${resp}=  getOchIntfNameFromOtuIntf  ${strOtuIntf}
	[return]  ${resp}
	
	
	
Get Supporting Port
    [Documentation]        Get Supporting Port
    ...                    Args:
    ...                    | - strIntf : OTU interface
    [Arguments]             ${strIntf}
	${resp}=  getSupportPort  ${strIntf}
	[return]  ${resp}
	
	
Get getSupporting Circuit Pack Name
    [Documentation]        Get getSupporting Circuit Pac kName
    ...                    Args:
    ...                    | - strIntf : OTU interface
    [Arguments]             ${strIntf}
	${resp}=  getSupportCircuitPackName  ${strIntf}
	[return]  ${resp}
	
Speed To Client Rate
    [Documentation]        Speed To Client Rate
    ...                    Args:
    ...                    | - speed : speed rate
    [Arguments]             ${speed}
	${resp}=  speed2ClientRate  ${speed}
	[return]  ${resp}
	
	
	
Speed To ODU Rate
    [Documentation]        Speed To ODU Rate
    ...                    Args:
    ...                    | - speed : speed rate
    [Arguments]             ${speed}
	${resp}=  speed2OduRate  ${speed}
	[return]  ${resp}
	
	
Speed To OTU Rate
    [Documentation]        Speed To OTU Rate
    ...                    Args:
    ...                    | - speed : speed rate
    [Arguments]             ${speed}
	${resp}=  speed2OtuRate  ${speed}
	[return]  ${resp}
	
Speed To OCH Rate
    [Documentation]        Speed To OCH Rate
    ...                    Args:
    ...                    | - speed : speed rate
    [Arguments]             ${speed}
	${resp}=  speed2OchRate  ${speed}
	[return]  ${resp}
	
Get A Random Frequency
    [Documentation]        Get A Random Frequency
    ...                    Args:
	${resp}=  randomFrequency
	[return]  ${resp}
	
Get The Next Frequency
    [Documentation]        Get A Random Frequency
    ...                    Args:
	...                    | - frequency : och frequency
	[Arguments]             ${frequency}
	${resp}=  getNextFrequency  ${frequency}
	[return]  ${resp}
	

Create 100GE Service
    [Documentation]   Create 100GE Service
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}  ${names for interfaces}=default
    ${rate}=  Set Variable  100G
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    ${line support port}=  Get Supporting Port  ${och intf}
    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
    ${client support port}=  Get Supporting Port  ${client intf}
    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
    ${client rate}=  Speed To Client Rate  ${rate}
    ${odu rate}=  Speed To ODU Rate  ${rate}
    ${otu rate}=  Speed To OTU Rate  ${rate}
    ${och rate}=  Speed To OCH Rate  ${rate}
	
	${length}=  Get Length  ${names for interfaces}
	${client intf}=  Set Variable If  ${length}==4  @{names for interfaces}[3]  ${client intf}
	${odu intf}=  Set Variable If  ${length}==4  @{names for interfaces}[2]  ${odu intf}
	${otu intf}=  Set Variable If  ${length}==4  @{names for interfaces}[1]  ${otu intf}
	${och intf}=  Set Variable If  ${length}==4  @{names for interfaces}[0]  ${och intf}
   
    Log To Console     interfaces at ${client intf} ${odu intf} ${otu intf} ${och intf} 
    &{client_interface}    create_dictionary   interface-name=${client intf}    description=ett-${discription}    interface-type=ethernetCsmacd    
    ...    interface-administrative-state=inService   speed=${client rate}
    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}
    Log To Console     client &{client_interface}

    
    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel    
    ...    interface-administrative-state=inService    supporting-interface=none   och-rate=${och rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}  frequency=${frequency}000
    Log To Console     och &{och_interface}
    
    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}    interface-type=otnOtu    
    ...    interface-administrative-state=inService    supporting-interface=${och intf}  otu-rate=${otu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    Log To Console     otu &{otu_interface}
    
    &{odu_interface}    create_dictionary   interface-name=${odu intf}     description=odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService    supporting-interface=${otu intf}     odu-rate=${odu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    Log To Console     odu &{odu_interface}
    
    
    @{interface_info}    create list    ${client_interface}    ${och_interface}    ${otu_interface}    ${odu_interface} 
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Log To Console     payload &{payload}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload}
	

Create OTU4 Service
    [Documentation]   Create OTU4 Service
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}  ${client_fec}  ${names for interfaces}=default
    ${rate}=  Set Variable  100G
    
    Log To Console  ${client intf}
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    ${line support port}=  Get Supporting Port  ${och intf}
    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
    ${client support port}=  Get Supporting Port  ${client intf}
    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
    ${client rate}=  Speed To Client Rate  ${rate}
    ${odu rate}=  Speed To ODU Rate  ${rate}
    ${otu rate}=  Speed To OTU Rate  ${rate}
    ${och rate}=  Speed To OCH Rate  ${rate}
	
	
	${length}=  Get Length  ${names for interfaces}
	${client intf}=  Set Variable If  ${length}==5  @{names for interfaces}[4]  ${client intf}
	${client otu intf}=  Set Variable If  ${length}==5  @{names for interfaces}[3]  ${client otu intf}
	${odu intf}=  Set Variable If  ${length}==5  @{names for interfaces}[2]  ${odu intf}
	${otu intf}=  Set Variable If  ${length}==5  @{names for interfaces}[1]  ${otu intf}
	${och intf}=  Set Variable If  ${length}==5  @{names for interfaces}[0]  ${och intf}

	Log To Console     interfaces at ${client intf} ${odu intf} ${otu intf} ${och intf}

    &{client_otu_interface}    create_dictionary   interface-name=${client otu intf}    description=client-otu-${discription}    interface-type=otnOtu  interface-circuit-id=1234  
    ...    interface-administrative-state=inService   otu-rate=${otu rate}  
    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}
    ...    otu-tx-sapi=tx-sapi-val  otu-tx-dapi=tx-dapi-val  
    ...    otu-expected-sapi=tx-sapi-val  otu-expected-dapi=tx-dapi-val
	...    otu-tim-act-enabled=true  otu-tim-detect-mode=SAPI-and-DAPI
	...    otu-fec=${client_fec}
	...    otu-degm-intervals=5  otu-degthr-percentage=75  
	...    otu-tx-operator=tx-operator-val
    
    &{client_interface}    create_dictionary   interface-name=${client intf}    description=client-odu-${discription}    interface-type=otnOdu  interface-circuit-id=1234  
    ...    interface-administrative-state=inService   odu-rate=${odu rate}    
    ...    supporting-interface=${client otu intf}    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}  
    ...    odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
    ...    odu-expected-sapi=tx-sapi-val  odu-expected-dapi=tx-dapi-val
    ...    odu-tim-act-enabled=true  odu-tim-detect-mode=SAPI-and-DAPI
	...    odu-degm-intervals=5  odu-degthr-percentage=75  
	...    odu-tx-operator=tx-operator-val

    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel  interface-circuit-id=1234
    ...    interface-administrative-state=inService  och-rate=${och rate}  
    ...    supporting-circuit-pack-name=${line circuit pack}  supporting-port=${line support port}  supporting-interface=none  
    ...    modulation-format=qpsk  frequency=${frequency}000
	...    transmit-power=-3.00
    
    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}  interface-type=otnOtu  interface-circuit-id=1234
    ...    interface-administrative-state=inService  otu-rate=${otu rate}
	...    supporting-circuit-pack-name=${line circuit pack}  supporting-port=${line support port}  supporting-interface=${och intf}
	...    otu-tx-sapi=tx-sapi-val  otu-tx-dapi=tx-dapi-val  
    ...    otu-expected-sapi=tx-sapi-val  otu-expected-dapi=tx-dapi-val
    ...    otu-tim-act-enabled=true  otu-tim-detect-mode=SAPI-and-DAPI
	...    otu-fec=scfec  
	...    otu-degm-intervals=5  otu-degthr-percentage=75  
	...    otu-tx-operator=tx-operator-val 
    
    &{odu_interface}    create_dictionary   interface-name=${odu intf}  description=odu-${discription}  interface-type=otnOdu  interface-circuit-id=1234  
    ...    interface-administrative-state=inService  odu-rate=${odu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}  supporting-port=${line support port}  supporting-interface=${otu intf}
	...    odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
    ...    odu-expected-sapi=tx-sapi-val  odu-expected-dapi=tx-dapi-val
    ...    odu-tim-act-enabled=true  odu-tim-detect-mode=SAPI-and-DAPI
	...    odu-degm-intervals=5  odu-degthr-percentage=75  
	...    odu-tx-operator=tx-operator-val
	...    proactive-delay-measurement-enabled=false
	...    monitoring-mode=not-terminated
    
    @{interface_info}    create list    ${och_interface}    ${otu_interface}    ${odu_interface} 
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload} 
    
    @{interface_info}    create list    ${client_otu_interface}    ${client_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload}

	
Remove 100GE Service
    [Documentation]  Remove 100GE Service
	[Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${names for interfaces}=default
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    
    &{intf}=   create_dictionary   interface-name=${odu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${och intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${client intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
	
Remove OTU4 Service
	[Documentation]   Remove OTU4 Service
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${names for interfaces}=default
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    
    ${length}=  Get Length  ${names for interfaces}
	${client intf}=  Set Variable If  ${length}==5  @{names for interfaces}[4]  ${client intf}
	${client otu intf}=  Set Variable If  ${length}==5  @{names for interfaces}[3]  ${client otu intf}
	${odu intf}=  Set Variable If  ${length}==5  @{names for interfaces}[2]  ${odu intf}
	${otu intf}=  Set Variable If  ${length}==5  @{names for interfaces}[1]  ${otu intf}
	${och intf}=  Set Variable If  ${length}==5  @{names for interfaces}[0]  ${och intf}

	Log To Console     interfaces at ${client intf} ${odu intf} ${otu intf} ${och intf}

    &{intf}=   create_dictionary   interface-name=${odu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${och intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${client intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${client otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${node}  ${netconfParams}


Set Loopback To OTU Interface
    [Documentation]   Set Loopback To OTU Interface
    [Arguments]    ${odl_sessions}  ${node}  ${intf}  ${loopback mode}

    &{disable_loopback_interface}    create_dictionary   interface-name=${intf}  otu-maint-enabled=false
    &{enable_loopback_interface}    create_dictionary   interface-name=${intf}  otu-maint-enabled=true  otu-maint-type=${loopback mode}
    &{interface}=  Set Variable If  '${loopback mode}' == 'off'  ${disable_loopback_interface}  ${enable_loopback_interface}
    @{interface_info}    create list    ${interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    # Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload}
    Send Merge Request And Verify Status Of Response Is OK    ${odl_sessions}   ${node}   ${payload}

Get Device Name From IP
	[Documentation]   Get Device Name From IP in global variable tv
    [Arguments]    ${tv}  ${node}
	${resp}=  getDeviceNameFromMgtIP  ${tv}  ${node}
	[return]  ${resp}

Delete All Users
    [Documentation]   Delete all created openroadm users
    [Arguments]    ${odl_sessions}    ${node}    
    ${resp}        Send Delete Request With Complete Url    ${odl_sessions}    ${node}    org-openroadm-device:org-openroadm-device/users/    
    [return]    ${resp} 

Delete User
    [Documentation]   Delete openroadm user
    [Arguments]    ${odl_sessions}    ${node}     ${username} 
    ${resp}             Delete Request  @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/org-openroadm-device:org-openroadm-device/users/user/${username}    headers=${delete_headers}    allow_redirects=False 
    [return]  ${resp}
  
Create New User
    [Documentation]   Create a new User
    [Arguments]    ${odl_sessions}    ${node}    ${username}    ${password}    ${group}
	&{user}    create_dictionary   name=${username}    password=${password}    group=${group}  
    &{payload}   create_dictionary   user=${user}
    ${resp}        Send Post Request    ${odl_sessions}   ${node}  org-openroadm-device:org-openroadm-device/users/     ${payload}
    [return]    ${resp}  

Change User Password
    [Documentation]   Change an existed user password
    [Arguments]    ${odl_sessions}    ${node}    ${username}    ${new_password}    
	&{userattr}    create_dictionary   name=${username}    password=${new_password}    group=sudo  
    &{payload}   create_dictionary   user=${userattr}
    ${url}=     Retrieve set URL  ${payload}
    ${data}=    Set variable    <yang-patch xmlns="urn:ietf:params:xml:ns:yang:ietf-yang-patch"><patch-id>Patch operation</patch-id><edit><edit-id>50</edit-id><operation>merge</operation><target>/</target><value>${url}</value></edit></yang-patch>
    ${resp}=            Patch Request   @{odl_sessions}[${CFG_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/org-openroadm-device:org-openroadm-device/users/user/${username}   data=${data}    headers=${patch_headers}    allow_redirects=False
    [Return]  ${resp}
  
Check User In Openroadm
    [Documentation]   Check if user exists in openroadm configuration
    [Arguments]    ${odl_sessions}    ${node}    ${username}   
    ${resp}=             Get Request  @{odl_sessions}[${OPR_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/org-openroadm-device:org-openroadm-device/users/    headers=${get_headers}    allow_redirects=False
    ${resp_content}=              Decode Bytes To String   ${resp.content}    UTF-8
    Log       ${resp_content}
    @{user_names}            Get Elements      ${resp_content}    /users/user/name
    Log       ${user_names}
    : FOR    ${name}    IN   @{user_names}  
	\        Log        ${name.text}
    \        return from keyword if     """${name.text}""" == """${username}"""     ${TRUE}
    [Return]   ${FALSE}

Get Device Info
    [Documentation]   Check if user exists in openroadm configuration
    [Arguments]    ${odl_sessions}    ${node}      
    ${resp}=             Get Request  @{odl_sessions}[${OPR_SESSEION_INDEX}]    /node/${node}/yang-ext:mount/org-openroadm-device:org-openroadm-device/info/    headers=${get_headers}    allow_redirects=False
    ${resp_content}=              Decode Bytes To String   ${resp.content}    UTF-8
    Log       ${resp_content}
    &{result_dict} =	Create Dictionary
    @{info_list}    create list    max-srgs  serial-id  serial-id  template  max-degrees  model  macAddress
    ...                            node-number  ipAddress  source  defaultGateway   current-datetime  node-type
    ...                            softwareVersion   current-defaultGateway   max-num-bin-15min-historical-pm
    ...                            vendor  prefix-length  max-num-bin-24hour-historical-pm  current-ipAddress
    ...                            openroadm-version  clli  current-prefix-length  node-id
        
    : FOR    ${info}    IN   @{info_list}  
	\       ${value_element}           Get Element      ${resp_content}    /info/${info}
    \       Set To Dictionary	${result_dict}	  ${info}=${value_element.text}
    [return]    &{result_dict}

    
