*** Settings ***
Documentation    This is Attella OpenROADM Current PM Data Model Scripts
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : rliu@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/54547
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
Library			random
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

${ATTELLA_DEF_PORT_CLIENT_PREFIX}   port-0/0/
${ATTELLA_DEF_PORT_LINE_PREFIX}   port-0/1/
${ATTELLA_DEF_ETH_CLIENT_IF_NAME_PREFIX}   ett-0/0/
${ATTELLA_DEF_OTU_CLIENT_IF_NAME_PREFIX}   otu-0/0/
${ATTELLA_DEF_ODU_CLIENT_IF_NAME_PREFIX}   odu-0/0/
${ATTELLA_DEF_OCH_IF_NAME_PREFIX}   och-0/1/
${ATTELLA_DEF_OTU_IF_NAME_PREFIX}   otu-0/1/
${ATTELLA_DEF_ODU_IF_NAME_PREFIX}   odu-0/1/

@{auth}    admin    admin
${interval}  10
${timeout}   60
@{Pm_Type_Group_Opt}   totalOpticalPowerInput   totalOpticalPowerInputMax   totalOpticalPowerInputMin   totalOpticalPowerInputAvg
...	   				   opticalPowerOutput   opticalPowerOutputMax   opticalPowerOutputMin   opticalPowerOutputAvg
...					   opticalPowerInput   opticalPowerInputMax   opticalPowerInputMin   opticalPowerInputAvg  
@{Pm_Type_Group_Err}   erroredBlockCount   backgroundBlockErrors   erroredSeconds   severelyErroredSeconds   unavailableSeconds
...					   BIPErrorCounter   erroredSecondsEthernet   severelyErroredSecondsEthernet   unavailableSecondsEthernet
...					   preFECCorrectedErrors   FECCorrectableBlocks   FECUncorrectableBlocks

*** Test Cases ***     
TC1 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/pm-resource-type
    [Documentation]  Verify leaf "pm-resource-type" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/pm-resource-type exists in Yang Model and return value is legal   
	@{value_range}=   create list   device   circuit-pack   port   interface
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/pm-resource-type
	Element Should Exist   ${xmlResult}   ${xpath}   
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	${Rsrc_Type}=    Set Variable  ${get_result.text}
	Set Suite Variable   ${Rsrc_Type}   

	List Should Contain Value   ${value_range}   ${get_result.text}
	
	

TC2 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/pm-resource-type-extension
	[Documentation]  Verify leaf "pm-resource-type-extension" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify pm-resource-type exists in Yang Model and return value is legal   
	@{value_range}=   create list   none
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/pm-resource-type-extension
	Element Should Exist      ${xmlResult}   ${xpath} 
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}	
	List Should Contain Value   ${value_range}   ${get_result.text}


    
TC3 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/pm-resource-instance
    [Documentation]  Verify leaf "pm-resource-instance" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify "org-openroadm-pm:current-pm-list/current-pm-entry/pm-resource-instance" exists in Yang Model and return value is legal
	@{value_range}   Create List
	: FOR		${IDX}   IN RANGE   0   8
	\		Append To List   ${value_range}   ${ATTELLA_DEF_PORT_CLIENT_PREFIX}${IDX}
	: FOR		${IDX}   IN RANGE   0   4
	\		Append To List   ${value_range}   ${ATTELLA_DEF_PORT_LINE_PREFIX}${IDX}	
	: FOR		${IDX}   IN RANGE   0   4
	\		Append To List   ${value_range}   ${ATTELLA_DEF_OCH_IF_NAME_PREFIX}${IDX}:0
	: FOR		${IDX}   IN RANGE   0   4
	\		Append To List   ${value_range}   ${ATTELLA_DEF_OTU_IF_NAME_PREFIX}${IDX}:0:0
	: FOR		${IDX}   IN RANGE   0   4
	\		Append To List   ${value_range}   ${ATTELLA_DEF_ODU_IF_NAME_PREFIX}${IDX}:0:0:0
	: FOR		${IDX}   IN RANGE   0   8
	\		Append To List   ${value_range}   ${ATTELLA_DEF_ETH_CLIENT_IF_NAME_PREFIX}${IDX}
	: FOR		${IDX}   IN RANGE   0   8
	\		Append To List   ${value_range}   ${ATTELLA_DEF_OTU_CLIENT_IF_NAME_PREFIX}${IDX}:0:0
	: FOR		${IDX}   IN RANGE   0   8
	\		Append To List   ${value_range}   ${ATTELLA_DEF_ODU_CLIENT_IF_NAME_PREFIX}${IDX}:0:0:0
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/pm-resource-instance
	Element Should Exist      ${xmlResult}   ${xpath}  
	${get_result}=   Get Element   ${xmlResult}   ${xpath}
	${get_result.text}=   Fetch From Right   ${get_result.text}   name='
	${get_result.text}=   Fetch From Left    ${get_result.text}   '] 
	Log   VALUE: ${get_result.text}
	List Should Contain Value   ${value_range}   ${get_result.text}

	

TC4 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/retrieval-time
	[Documentation]  Verify leaf "retrieval-time" and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/retrieval-time exists in Yang Model and return value is legal
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/retrieval-time
	Element Should Exist   ${xmlResult}   ${xpath}  
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	Should Match Regexp   ${get_result.text}   ^(19[7-9]\\d|20\\d{2})-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])T([0-1]\\d|2[[0-3]):[0-5]\\d:[0-5]\\dZ$
    


TC5 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/type
    [Documentation]  Verify leaf "type" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/type exists in Yang Model and return value is legal
	@{value_range}   Create List   vendorExtension 
	Run Keyword IF   "${Rsrc_Type}" == "port"   	  Append To List   ${value_range}      
	...				  totalOpticalPowerInput   totalOpticalPowerInputMax   totalOpticalPowerInputMin   totalOpticalPowerInputAvg
	...				  opticalPowerOutput   opticalPowerOutputMax   opticalPowerOutputMin   opticalPowerOutputAvg
    ...   ELSE IF     "${Rsrc_Type}" == "interface"   Append To List   ${value_range}
	...   			  bitErrorRate   opticalPowerOutput   opticalPowerInput   erroredSeconds   severelyErroredSeconds   vendorExtension
	...				  erroredBlockCount   preFECCorrectedErrors   FECUncorrectableBlocks   erroredSecondsEthernet   severelyErroredSecondsEthernet
	...			      BIPErrorCounter   opticalPowerInput   opticalPowerInputAvg   opticalPowerInputMax   opticalPowerInputMin   
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/type
	Element Should Exist   ${xmlResult}   ${xpath}  
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	${Pm_Type}=   set variable   ${get_result.text}
	Set Suite Variable   ${Pm_Type}   
	List Should Contain Value   ${value_range}   ${get_result.text}



TC6 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/extension
	[Documentation]  Verify leaf "extension" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/extension exists in Yang Model and return value is legal
	@{value_range}=   create list   backgroundBlockErrors
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/extension
	Element Should Exist   ${xmlResult}   ${xpath}  
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	Run Keyword IF   "${Pm_Type}" == "vendorExtension"
	...    Set Suite Variable    ${Pm_Type}   ${get_result.text}
	...    AND    Run Keywords   List Should Contain Value   ${value_range}   ${get_result.text}    
	...    ELSE   Should Be Equal   ${get_result.text}  none



TC7 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/location
    [Documentation]  Verify leaf "location" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/location exists in Yang Model and return value is legal   
	@{value_range}=   create list   nearEnd   farEnd
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/location
	Element Should Exist   ${xmlResult}   ${xpath}   
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	List Should Contain Value   ${value_range}   ${get_result.text}
	


TC8 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/direction
    [Documentation]  Verify leaf "direction" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/direction exists in Yang Model and return value is legal   
	@{value_range}=   create list   rx   tx
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/direction
	Element Should Exist   ${xmlResult}   ${xpath}   
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	List Should Contain Value   ${value_range}   ${get_result.text}



TC9 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/granularity
    [Documentation]  Verify leaf "granularity" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/granularity exists in Yang Model and return value is legal   
	@{value_range}=   create list   notApplicable   15min   24Hour
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/measurement[${Meas_Idx}]/granularity
	Element Should Exist   ${xmlResult}   ${xpath}   
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	List Should Contain Value   ${value_range}   ${get_result.text}



TC10 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/validity
    [Documentation]  Verify leaf "validity" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/validity exists in Yang Model and return value is legal   
	@{value_range}=   create list   complete   partial   suspect
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/measurement[${Meas_Idx}]/validity
	Element Should Exist   ${xmlResult}   ${xpath}   
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	List Should Contain Value   ${value_range}   ${get_result.text}
	
	
	
TC11 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/pmParameterUnit
    [Documentation]  Verify leaf "pmParameterUnit" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/pmParameterUnit exists in Yang Model and return value is legal   
	@{value_range}   Create List
	Run Keyword IF   '${Pm_Type}' in ${Pm_Type_Group_Opt}
	...				 Append To List   ${value_range}   dBm
	...    ELSE IF   '${Pm_Type}' in ${Pm_Type_Group_Err}
	...				 Append To List   ${value_range}   count
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/measurement[${Meas_Idx}]/pmParameterUnit
	Element Should Exist   ${xmlResult}   ${xpath}   
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	List Should Contain Value   ${value_range}   ${get_result.text}



TC12 Verify leaf org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/pmParameterValue
    [Documentation]  Verify leaf "pmParameterValue" exists and retrieves legal value 
    ...              RLI38974 5.1-1
    [Tags]           Sanity   tc1
	log   Verify org-openroadm-pm:current-pm-list/current-pm-entry/current-pm/measurement/pmParameterValue exists in Yang Model and return value is legal   
	${xpath}=   set variable   current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/measurement[${Meas_Idx}]/pmParameterValue
	Element Should Exist   ${xmlResult}   ${xpath}   
    ${get_result}=   Get Element   ${xmlResult}   ${xpath}
	Log   VALUE: ${get_result.text}
	Run Keyword IF   "${Pm_Type}" in ${Pm_Type_Group_Opt}
	...				 Should Match Regexp   ${get_result.text}    ^-?\\d+\.\\d+$   
	...    ELSE IF   "${Pm_Type}" in ${Pm_Type_Group_Err}
	...				 Should Match Regexp   ${get_result.text}    ^\\d+$
  
  
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
    
    @{odl_sessions}    create list   ${opr_session}   ${cfg_session}
    Set Suite Variable    ${odl_sessions}
    
	Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
	Sleep   15
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
	
	#Create Current PM Instances If No One Exists
	Create Current PM Instances
	log   Retrieve Current PM YangModel
	Get Current PM YangModel
	

   
Get System Info
    ${r0} =     Get Handle      resource=device0
    ${label} =  Execute cli command on device    device=${r0}    command=show version   format=xml
    ${version} =  Get Element   ${label}   software-information/junos-version
    Log  ${version.text}
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




Create Current PM Instances If No One Exists 
	&{payload}         create dictionary        org-openroadm-device= ${null} 
	${resp}=   Send Get Request    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
	Log   ${resp}
	Log   ${resp.content}
	${xmlResult}=      Decode Bytes To String   ${resp.content}   UTF-8
    ${root}=           Parse XML    ${xmlResult}
    @{instanceList}=   Get Elements  ${root}  xponder/xpdr-port
	${ifType}=   Evaluate   random.randint(0,1)  modules=random
	Log To Console   ifType is ${ifType}
	Run Keyword Unless   ${instanceList}   Configure Service And Init Test Set   ${ifType}
	${random_interval}=  Evaluate  random.randint(10, 60)  modules=random
    Sleep  ${random_interval}



Create Current PM Instances
	${ifType}=   Evaluate   random.randint(0,1)  modules=random
	Log To Console   ifType is ${ifType}
	Configure Service And Init Test Set   ${ifType}
	${random_interval}=  Evaluate  random.randint(10, 60)  modules=random
    Sleep  ${random_interval}



Configure 100GE Service
	Log To Console  Provide 100GE traffic service
    ${client intf}=   Get Ethernet Intface Name From Client Intface   ${tv['device0__client_intf__pic']}
    ${line odu intf}     Get Line ODU Intface Name From Client Intface   ${client intf}
    ${line otu intf}     Get OTU Intface Name From ODU Intface   ${line odu intf}
    ${line och intf}     Get OCH Intface Name From OTU Intface   ${line otu intf}
    ${line transc port}   Evaluate    '${line och intf}'.replace("och","port")   string
    log    ${line transc port}
    ${line transc port}   Evaluate    '${line transc port}'.split(":")[0]        string
    log    ${line transc port}
	Create 100GE Service   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${client intf}   ${tv['uv-frequency']}   ${tv['uv-service-description']}



Configure OTU4 Service
	Log To Console  Provide OTU4 traffic service
	${client intf}=   Get Otu4 Intface Name From Client Intface   ${tv['device0__client_intf__pic']}
   #${client otu intf}=   Get OTU Intface Name From ODU Intface   ${client intf}
    ${line odu intf}     Get Line ODU Intface Name From Client Intface   ${client intf}
    ${line otu intf}     Get OTU Intface Name From ODU Intface  ${line odu intf}
    ${line och intf}     Get OCH Intface Name From OTU Intface  ${line otu intf}
    ${line transc port}   Evaluate    '${line och intf}'.replace("och","port")   string
    log    ${line transc port}
    ${line transc port}   Evaluate    '${line transc port}'.split(":")[0]        string
    log    ${line transc port}
	log to console   client int: ${client intf}
	Create OTU4 Service   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${client intf}   ${tv['uv-frequency']}   ${tv['uv-service-description']}   ${tv['uv-client_fec']} 
	
	
	
Configure Service
	[Arguments]   ${clientIfType}
	Log To Console   clientIfType is ${clientIfType}
	Run Keyword IF   ${clientIfType} == 0
    ...				 Configure 100GE Service
	...	      ELSE   Configure OTU4 Service



Init Test Set
	[Arguments]   ${clientIfType}
    Log To Console  inital test set 
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
	Run Keyword IF   ${clientIfType} == 0   Init Test Equipment  ${testSetHandle1}  100GE
	...       ELSE   Init Test Equipment  ${testSetHandle1}  OTU4



Configure Service And Init Test Set
	[Arguments]   ${clientIfType}
    Log To Console  Load Pre Default Provision on device0
	Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	
	Log To Console  De-provision interfaces on device0
    Delete All Interface   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}
	
 	Configure Service   ${clientIfType}
	#Init Test Set       ${clientIfType}



Get Current PM YangModel
	${yangModelName}   Set variable   			current-pm-list
	&{payload}         create dictionary        ${yangModelName}= ${null}
	${resp}=   Send Get Request    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
	Log   ${resp}
	Log   ${resp.content}
	${xmlResult}=      Decode Bytes To String   ${resp.content}   UTF-8
    ${root}=           Parse XML    ${xmlResult}
    @{instanceList}=   Get Elements  ${root}  current-pm-entry
	${Entry_Len}=			   Get Length		${instanceList}
	${Entry_Idx}=   Evaluate   random.randint(1, ${Entry_Len})  modules=random
	@{instanceList}=   Get Elements  ${root}  current-pm-entry[${Entry_Idx}]/current-pm
	${Pm_Len}=			   Get Length		${instanceList}
	${Pm_Idx}=   Evaluate   random.randint(1, ${Pm_Len})  modules=random
	@{instanceList}=   Get Elements  ${root}  current-pm-entry[${Entry_Idx}]/current-pm[${Pm_Idx}]/measurement
	${Meas_Len}=		   Get Length		${instanceList}
	${Meas_Idx}=   Evaluate   random.randint(1, ${Meas_Len})  modules=random
	${Rsrc_Type}   set variable   None
	${Pm_Type}     set variable   None
	Set Suite Variable		${xmlResult}
	Set Suite Variable		${Entry_Idx}
	Set Suite Variable		${Pm_Idx}
	Set Suite Variable		${Meas_Idx}
	Set Suite Variable		${Rsrc_Type}
	Set Suite Variable		${Pm_Type}
	#Log To Console   Entry_Len is ${Entry_Len}
	#Log To Console   Entry_Idx is ${Entry_Idx}
	#Log To Console   Pm_Len is ${Pm_Len}
	#Log To Console   Pm_Idx is ${Pm_Idx}
	#Log To Console   Meas_Len is ${Meas_Len}
	#Log To Console   Meas_Idx is ${Meas_Idx}
