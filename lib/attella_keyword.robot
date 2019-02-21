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
# Library        ../lib/PowerModule.py   ${Power_Manager}   WITH NAME   powersv


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
    ...                    | - node : device0 or device1
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