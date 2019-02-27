<<<<<<< HEAD
*** Settings ***
Documentation    This is Attella shelf Scripts
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : amypeng@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/54547
...              jtms description           : Attella
...              RLI                        : 38968
...              MIN SUPPORT VERSION        : 19.1
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : MISC
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
##### variables of limitation test#####
${INVALID_SHELF_NAME}  shelf-1
${INVALID_SHELF_TYPE}  other_value
${INVALID_SHELF_POSITION}  other_value
${INVALID_DUE_DATE}  \2018-11-31T00:00:00Z\
${INVALID_FORMAT_DUE_DATE}  \2018-11-30T00:00:00\
${INVALID_EQUIPMENT_STATE_SHELVES}  invalid_state
${INVALID_ADMINISTRATIVE_STATE_SHELVES}  invalid_state
## end of variables of limitation test##

@{auth}    admin    admin
${interval}  120
${timeout}  120





*** Test Cases ***       
TC1
   [Documentation]  Verify shelf-name can be set via openRoadm leaf    
   ...              Mapping  RLI38968  5.2-1 
   [Tags]           Sanity   TC1   
   Log              setting shelf-name via Restconf patch method	
   &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   shelf-type=${tv['uv-shelf_type']}
   @{shelves}    create list   ${shelf}
   &{dev_shelves}   create_dictionary   shelves=${shelves}
   &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
   Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
 

	
 
#TC2
    #[Documentation]  Limitation test for shelf-name via openRoadm leaf   
    #...              Mapping  RLI38968  5.2-2
    #[Tags]           Negative  TC2
    #Log              Limitation test for shelf-name via Restconf patch method                    
    #&{shelf}   create_dictionary    shelf-name=${INVALID_SHELF_name} 
    #@{shelves}    create list   ${shelf}
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400 


	
 
TC3
    [Documentation]  Verify shelf-type can be set via openRoadm leaf    
    ...              Mapping  RLI38968  5.2-3
    [Tags]           Sanity  TC3
    Log              setting shelf-type via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   shelf-type=${tv['uv-shelf_type']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}

    
    
#TC4
    #[Documentation]  Limitation test for shelf-type via openRoadm leaf   
    #...              Mapping  RLI38968  5.2-4
    #[Tags]           Negative  TC4
    #Log              Limitation test for shelf-type via Restconf patch method                    
    #&{shelf}   create_dictionary   shelf-name=shelf-0   shelf-type=${INVALID_SHELF_TYPE} 
    #@{shelves}    create list   ${shelf}
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400    
    
	
TC5
    [Documentation]  Verify the rack of shelf can be set via openRoadm leaf  
    ...              Mapping  RLI38968  5.2-5
    [Tags]           Sanity  TC5   
    Log                     setting rack for shelf via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   rack=${tv['uv-rack']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	

TC6
    [Documentation]  Verify shelf-position can be set via openRoadm leaf   
    ...              Mapping  RLI38968  5.2-6
    [Tags]           Sanity  TC6    
    Log              setting shelf-position via Restconf patch method
    &{shelf}   create dictionary   shelf-name=${tv['uv-shelf_name']}   shelf-position=${tv['uv-shelf_position']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	
    
#TC7
    #[Documentation]  Limitation test for shelf-position via openRoadm leaf    
    #...              Mapping  RLI38968   5.2-7
    #[Tags]           Negative  TC7
    #Log              Limitation test for shelf-position via Restconf patch method
    #&{shelf}   create_dictionary   shelf-name=shelf-0  shelf-position=${INVALID_SHELF_POSITION}  
    #@{shelves}    create list   ${shelf}
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400    



    
TC8
    [Documentation]  Verify administrative-state can be set via openRoadm leaf inService/outOfService/maintenance   
    ...              Mapping RLI38968    5.2-8
    [Tags]           Sanity   TC8 
    Log              setting shelf administrative-state via Restconf patch method
    ${administrative_state_for_shelf}     evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   administrative-state-shelves=${administrative_state_for_shelf}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}   


    
#TC9
	#[Documentation]  Limitation test for administrative-state via openRoadm leaf inService/outOfService/maintenance 
    #...              Mapping RLI38968  5.2-9
	#[Tags]           Negative  TC9
    #Log              Limitation test for shelf administrative-state via Restconf patch method
    #&{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   administrative-state-shelves=${INVALID_ADMINISTRATIVE_STATE_SHELVES}
	#@{shelves}    create list   ${shelf}	
	#&{dev_shelves}   create_dictionary   shelves=${shelves}
	#&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	#check status line  ${patch_resp}  400  set administrative-state with invalid value should failed and return status code 400
	
	
	
TC10
     [Documentation]  Verify equipment-state can be set via openRoadm leaf reserved-for-facility-planned/not-reserved-planned/reserved-for-maintenance-planned/reserved-for-facility-unvalidated/not-reserved-unvalidated/unknown-unvalidated/reserved-for-maintenance-unvalidated/reserved-for-facility-available/not-reserved-available/reserved-for-maintenance-available/reserved-for-reversion-inuse/not-reserved-inuse/reserved-for-maintenance-inuse
     ...            Mapping RLI38968   5.2-19
     [Tags]           Sanity   TC10  
     Log                     setting shelf equipment-state via Restconf patch method
     ${equipment_state_for_shelf}     evaluate    random.choice(["reserved-for-facility-planned", "not-reserved-planned", "reserved-for-maintenance-planned", "reserved-for-facility-unvalidated", "not-reserved-unvalidated", "unknown-unvalidated", "reserved-for-maintenance-unvalidated", "reserved-for-facility-available", "not-reserved-available", "reserved-for-maintenance-available", "reserved-for-reversion-inuse", "not-reserved-inuse", "reserved-for-maintenance-inuse"])    random
     &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   equipment-state-shelves=${equipment_state_for_shelf}
     @{shelves}    create list   ${shelf}
     &{dev_shelves}   create_dictionary   shelves=${shelves}
     &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
     Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}	


#TC11
	#[Documentation]  Limitation test for equipment-state via openRoadm leaf reserved-for-facility-planned/not-reserved-planned/reserved-for-maintenance-planned/reserved-for-facility-unvalidated/not-reserved-unvalidated/unknown-unvalidated/reserved-for-maintenance-unvalidated/reserved-for-facility-available/not-reserved-available/reserved-for-maintenance-available/reserved-for-reversion-inuse/not-reserved-inuse/reserved-for-maintenance-inuse
	#...              Mapping RLI38968   5.2-20
    #[Tags]           Negative  TC11
    #Log              Limitation test for shelf equipment-state via Restconf patch method      
    #&{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   equipment-state-shelves=${INVALID_EQUIPMENT_STATE_SHELVES}
	#@{shelves}    create list   ${shelf}	
	#&{dev_shelves}   create_dictionary   shelves=${shelves}
	#&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	#check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400

	
	
TC12
    [Documentation]  Verify due-date can be set via openRoadm leaf pattern '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?' + '(Z|[\+\-]\d{2}:\d{2})'
    ...              Mapping RLI38968   5.2-21 
    [Tags]           Sanity   TC12  
    Log                     setting due-date via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   due-date-shelves=${tv['uv-valid_due_date']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



#TC13
    #[Documentation]  Limitation test for dur-date via openRoadm leaf pattern '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?' + '(Z|[\+\-]\d{2}:\d{2})'
    #...              Mapping RLI38968   5.2-22
    #[Tags]           Negative   TC13
    #Log              Limitation test for shelf due-date via Restconf patch method
    #&{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   due-date-shelves=${INVALID_DUE_DATE}
    #@{shelves}    create list   ${shelf}	
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set due-date with invalid value should failed and return status code 400	

	
	
TC14
	[Documentation]  Limitation test for due-date via openRoadm leaf pattern '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?' + '(Z|[\+\-]\d{2}:\d{2})'
    ...              Mapping RLI38968   5.2-22
	[Tags]           Negative   TC14
    Log              Limitation test for shelf due-date via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   due-date-shelves=${INVALID_FORMAT_DUE_DATE}
	@{shelves}    create list   ${shelf}	
	&{dev_shelves}   create_dictionary   shelves=${shelves}
	&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
	${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	check status line  ${patch_resp}  400

    
    
TC15
	[Documentation]   This test case mapping to test cases 5.3.1 to 5.3.12 in JTMS for RLI38968     
	[Tags]            Sanity  TC15    
    Log               Configure all R/W leaves for circuit-pack FPC via Restconf 
    &{fpckey}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}   circuit-pack-type=FPC  shelf=shelf-0  slot=slot-0  subSlot=slot-0
    @{fpc_info}    create list    ${fpckey} 
    &{dev_info}   create_dictionary   circuit-packs=${fpc_info}    
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}

    
    
TC16
    [Documentation]  This test case mapping to 5.5-1 ~~~~ 5.5-10 for JTMS RLI-38968
    [Tags]           Sanity  TC16
    Log              Configure all R/W leaves for circuit-pack FAN via Restconf       
    ${administrative_state_for_fan}    evaluate    random.choice(["inService", "outOfService", "maintenance"])     random
    &{fankey}    create_dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-3 
    &{fankey1}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot4_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-4  
    &{fankey2}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot5_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-5  
    &{fankey3}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot6_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-6  
    &{fankey4}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot7_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-7  
    @{fan_info}    create list    ${fankey}  ${fankey1}  ${fankey2}  ${fankey3}  ${fankey4}
    &{dev_info}   create_dictionary   circuit-packs=${fan_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}   



TC17
	[Documentation]  This test case mapping to 5.4-1 ~~~~ 5.4-10 and 5.4-23 for JTMS RLI-38968
	[Tags]           Sanity   TC17   
    Log              Configure all R/W leaves for circuit-pack PSM via Restconf 
	${administrative_state_for_psm}    evaluate    random.choice(["inService", "outOfService", "maintenance"])     random
    &{psmkey}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-PowerSupply  shelf=shelf-0  slot=slot-1
    ...         administrative-state-cp=${administrative_state_for_psm}    equipment-state-cp=reserved-for-facility-available   circuit-pack-product-code=NON-JNPR 
    ...         circuit-pack-mode=NORMAL   subSlot=slot-0    is-pluggable-optics=false   due-date-cp=${tv['uv-valid_due_date']} 
    &{psmkey1}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-PowerSupply  shelf=shelf-0  slot=slot-2 
    ...         administrative-state-cp=${administrative_state_for_psm}    equipment-state-cp=reserved-for-facility-available   circuit-pack-product-code=NON-JNPR 
    ...         circuit-pack-mode=NORMAL   subSlot=slot-0    is-pluggable-optics=false   due-date-cp=${tv['uv-valid_due_date']}  
    @{psm_info}    create list    ${psmkey}  ${psmkey1} 
    &{dev_info}   create_dictionary   circuit-packs=${psm_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}     




TC18
	[Documentation]  Verify can retrieve shelf R/W values via openRoadm leaf   
                ...              Mapping RLI38968   5.2-26
	[Tags]        Sanity   TC18    
    Log                     FeTChing shelf all values via ResTConf GET method 
    ${administrative_state_for_shelf}    Set variable    inService    
    ${equipment_state_for_shelf}     Set variable    reserved-for-facility-planned
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}    rack=${tv['uv-rack']}     equipment-state-shelves=${equipment_state_for_shelf}  
	...     shelf-type=${tv['uv-shelf_type']}    shelf-position=${tv['uv-shelf_position']}   administrative-state-shelves=${administrative_state_for_shelf}
	...     due-date-shelves=${tv['uv-valid_due_date']}   
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



 
TC19
	[Documentation]  Verify can retrieve shelf readonly info via openRoadm leaf      
    ...              Mapping RLI38968   5.2-10  5.2-11  5.2-12  5.2-13   5.2-14   5.2-15   5.2-16   5.2-17   5.2-18  5.2-23   5.2-24   5.2-25
	[Tags]          Sanity  TC19  
    Log                     FeTChing shelf operational values via ResTConf GET method
	&{slot0}	  create_dictionary   slot-name=${tv['uv-attella_def_slot0_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}  
	&{slot1}	  create_dictionary   slot-name=${tv['uv-attella_def_slot1_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  
	&{slot2}	  create_dictionary   slot-name=${tv['uv-attella_def_slot2_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  
	&{slot3}	  create_dictionary   slot-name=${tv['uv-attella_def_slot3_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}  
	&{slot4}	  create_dictionary   slot-name=${tv['uv-attella_def_slot4_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot4_provisioned_circuit_pack']}  
	&{slot5}	  create_dictionary   slot-name=${tv['uv-attella_def_slot5_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot5_provisioned_circuit_pack']}  
	&{slot6}	  create_dictionary   slot-name=${tv['uv-attella_def_slot6_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot6_provisioned_circuit_pack']}  
	&{slot7}	  create_dictionary   slot-name=${tv['uv-attella_def_slot7_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot7_provisioned_circuit_pack']}  
	@{slots}    create list   ${slot0}  ${slot1}  ${slot2}  ${slot3}  ${slot4}  ${slot5}  ${slot6}  ${slot7}	
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}  vendor-shelves=${tv['uv-attella_def_vendor']}  model-shlves=${ATTELLA_DEF_MODEL.text}  
	...     serial-id-shelves=${ATTELLA_DEF_SERIAL_ID.text}  type=${tv['uv-attella_def_type']}  product-code=${ATTELLA_DEF_PRODUCT_CODE.text} 
	...     clei=${ATTELLA_DEF_CLEI.text}  hardware-version=${ATTELLA_DEF_HARDWARE_VERSION.text}
	...     slots=${slots}
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



TC20
    [Documentation]  Verify shelf info can be deleted via openRoadm leaf      
    ...              Mapping RLI38968   5.2-27
    [Tags]           Sanity  TC20 
    Log                     Delete shelf via ResTConf paTCh method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    ${paTCh_resp}  Send Delete Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    check status line  ${paTCh_resp}  200	
    ${paTCh_resp}  Send Delete Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    check status line  ${paTCh_resp}  404


TC21
	[Documentation]  Verify can retrieve shelf R/W values via openRoadm leaf   
    ...              Mapping RLI38968   5.2-26
	[Tags]        Sanity   TC21    
    Log                     FeTChing shelf all values via ResTConf GET method 
    ${administrative_state_for_shelf}    Set variable    inService    
    ${equipment_state_for_shelf}     Set variable    reserved-for-facility-planned
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}    rack=${tv['uv-rack']}     equipment-state-shelves=${equipment_state_for_shelf}  
	...     shelf-type=${tv['uv-shelf_type']}    shelf-position=${tv['uv-shelf_position']}   administrative-state-shelves=${administrative_state_for_shelf}
	...     due-date-shelves=${tv['uv-valid_due_date']}   
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



 
TC22
	[Documentation]  Verify can retrieve shelf readonly info via openRoadm leaf      
    ...              Mapping RLI38968   5.2-10  5.2-11  5.2-12  5.2-13   5.2-14   5.2-15   5.2-16   5.2-17   5.2-18  5.2-23   5.2-24   5.2-25
	[Tags]          Sanity  TC22  
    Log                     FeTChing shelf operational values via ResTConf GET method
	&{slot0}	  create_dictionary   slot-name=${tv['uv-attella_def_slot0_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}  
	&{slot1}	  create_dictionary   slot-name=${tv['uv-attella_def_slot1_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  
	&{slot2}	  create_dictionary   slot-name=${tv['uv-attella_def_slot2_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  
	&{slot3}	  create_dictionary   slot-name=${tv['uv-attella_def_slot3_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}  
	&{slot4}	  create_dictionary   slot-name=${tv['uv-attella_def_slot4_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot4_provisioned_circuit_pack']}  
	&{slot5}	  create_dictionary   slot-name=${tv['uv-attella_def_slot5_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot5_provisioned_circuit_pack']}  
	&{slot6}	  create_dictionary   slot-name=${tv['uv-attella_def_slot6_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot6_provisioned_circuit_pack']}  
	&{slot7}	  create_dictionary   slot-name=${tv['uv-attella_def_slot7_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot7_provisioned_circuit_pack']}  
	@{slots}    create list   ${slot0}  ${slot1}  ${slot2}  ${slot3}  ${slot4}  ${slot5}  ${slot6}  ${slot7}
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}  vendor-shelves=${tv['uv-attella_def_vendor']}  model-shlves=${ATTELLA_DEF_MODEL.text}  
	...     serial-id-shelves=${ATTELLA_DEF_SERIAL_ID.text}  type=${tv['uv-attella_def_type']}  product-code=${ATTELLA_DEF_PRODUCT_CODE.text} 
	...     clei=${ATTELLA_DEF_CLEI.text}  hardware-version=${ATTELLA_DEF_HARDWARE_VERSION.text}
	...     slots=${slots}
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}


  

     
    
    
    
    
*** Keywords ***
Testbed Init
	Set Log Level  DEBUG
    Initialize
    Log To Console      Loading Baseline configurations
    ${device0} =     Get Handle      resource=device0
    @{dut_list}    create list    device0
    Preconfiguration netconf feature    @{dut_list}
    ${Hardware} =  Execute cli command on device    device=${device0}    command=show chassis hardware   format=xml	
    ${ATTELLA_DEF_SERIAL_ID}        Get Element   ${Hardware}  chassis-inventory/chassis/serial-number
    Log To Console   ${ATTELLA_DEF_SERIAL_ID.text}     
    ${ATTELLA_DEF_HARDWARE_VERSION}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/version
    Log To Console   ${ATTELLA_DEF_HARDWARE_VERSION.text}
    ${ATTELLA_DEF_PRODUCT_CODE}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/part-number
    Log To Console   ${ATTELLA_DEF_PRODUCT_CODE.text}
    ${ATTELLA_DEF_CLEI}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/clei-code
    Log To Console   ${ATTELLA_DEF_CLEI.text}
    ${ATTELLA_DEF_MODEL}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/description
    Log To Console   ${ATTELLA_DEF_MODEL.text}
    
    
    Set Global Variable  ${ATTELLA_DEF_SERIAL_ID.text}    
    Set Global Variable  ${ATTELLA_DEF_HARDWARE_VERSION.text}
    Set Global Variable  ${ATTELLA_DEF_PRODUCT_CODE.text}
    Set Global Variable  ${ATTELLA_DEF_CLEI.text}
    Set Global Variable  ${ATTELLA_DEF_MODEL.text}
    
    
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
	
	Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
=======
*** Settings ***
Documentation    This is Attella shelf Scripts
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : amypeng@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/54547
...              jtms description           : Attella
...              RLI                        : 38968
...              MIN SUPPORT VERSION        : 19.1
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : MISC
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
##### variables of limitation test#####
${INVALID_SHELF_NAME}  shelf-1
${INVALID_SHELF_TYPE}  other_value
${INVALID_SHELF_POSITION}  other_value
${INVALID_DUE_DATE}  \2018-11-31T00:00:00Z\
${INVALID_FORMAT_DUE_DATE}  \2018-11-30T00:00:00\
${INVALID_EQUIPMENT_STATE_SHELVES}  invalid_state
${INVALID_ADMINISTRATIVE_STATE_SHELVES}  invalid_state
## end of variables of limitation test##

@{auth}    admin    admin
${interval}  120
${timeout}  120





*** Test Cases ***       
TC1
   [Documentation]  Verify shelf-name can be set via openRoadm leaf    
   ...              Mapping  RLI38968  5.2-1 
   [Tags]           Sanity   TC1   
   Log              setting shelf-name via Restconf patch method	
   &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   shelf-type=${tv['uv-shelf_type']}
   @{shelves}    create list   ${shelf}
   &{dev_shelves}   create_dictionary   shelves=${shelves}
   &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
   Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
 

	
 
#TC2
    #[Documentation]  Limitation test for shelf-name via openRoadm leaf   
    #...              Mapping  RLI38968  5.2-2
    #[Tags]           Negative  TC2
    #Log              Limitation test for shelf-name via Restconf patch method                    
    #&{shelf}   create_dictionary    shelf-name=${INVALID_SHELF_name} 
    #@{shelves}    create list   ${shelf}
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400 


	
 
TC3
    [Documentation]  Verify shelf-type can be set via openRoadm leaf    
    ...              Mapping  RLI38968  5.2-3
    [Tags]           Sanity  TC3
    Log              setting shelf-type via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   shelf-type=${tv['uv-shelf_type']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}

    
    
#TC4
    #[Documentation]  Limitation test for shelf-type via openRoadm leaf   
    #...              Mapping  RLI38968  5.2-4
    #[Tags]           Negative  TC4
    #Log              Limitation test for shelf-type via Restconf patch method                    
    #&{shelf}   create_dictionary   shelf-name=shelf-0   shelf-type=${INVALID_SHELF_TYPE} 
    #@{shelves}    create list   ${shelf}
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400    
    
	
TC5
    [Documentation]  Verify the rack of shelf can be set via openRoadm leaf  
    ...              Mapping  RLI38968  5.2-5
    [Tags]           Sanity  TC5   
    Log                     setting rack for shelf via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   rack=${tv['uv-rack']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	

TC6
    [Documentation]  Verify shelf-position can be set via openRoadm leaf   
    ...              Mapping  RLI38968  5.2-6
    [Tags]           Sanity  TC6    
    Log              setting shelf-position via Restconf patch method
    &{shelf}   create dictionary   shelf-name=${tv['uv-shelf_name']}   shelf-position=${tv['uv-shelf_position']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	
    
#TC7
    #[Documentation]  Limitation test for shelf-position via openRoadm leaf    
    #...              Mapping  RLI38968   5.2-7
    #[Tags]           Negative  TC7
    #Log              Limitation test for shelf-position via Restconf patch method
    #&{shelf}   create_dictionary   shelf-name=shelf-0  shelf-position=${INVALID_SHELF_POSITION}  
    #@{shelves}    create list   ${shelf}
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400    



    
TC8
    [Documentation]  Verify administrative-state can be set via openRoadm leaf inService/outOfService/maintenance   
    ...              Mapping RLI38968    5.2-8
    [Tags]           Sanity   TC8 
    Log              setting shelf administrative-state via Restconf patch method
    ${administrative_state_for_shelf}     evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   administrative-state-shelves=${administrative_state_for_shelf}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}   


    
#TC9
	#[Documentation]  Limitation test for administrative-state via openRoadm leaf inService/outOfService/maintenance 
    #...              Mapping RLI38968  5.2-9
	#[Tags]           Negative  TC9
    #Log              Limitation test for shelf administrative-state via Restconf patch method
    #&{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   administrative-state-shelves=${INVALID_ADMINISTRATIVE_STATE_SHELVES}
	#@{shelves}    create list   ${shelf}	
	#&{dev_shelves}   create_dictionary   shelves=${shelves}
	#&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	#check status line  ${patch_resp}  400  set administrative-state with invalid value should failed and return status code 400
	
	
	
TC10
     [Documentation]  Verify equipment-state can be set via openRoadm leaf reserved-for-facility-planned/not-reserved-planned/reserved-for-maintenance-planned/reserved-for-facility-unvalidated/not-reserved-unvalidated/unknown-unvalidated/reserved-for-maintenance-unvalidated/reserved-for-facility-available/not-reserved-available/reserved-for-maintenance-available/reserved-for-reversion-inuse/not-reserved-inuse/reserved-for-maintenance-inuse
     ...            Mapping RLI38968   5.2-19
     [Tags]           Sanity   TC10  
     Log                     setting shelf equipment-state via Restconf patch method
     ${equipment_state_for_shelf}     evaluate    random.choice(["reserved-for-facility-planned", "not-reserved-planned", "reserved-for-maintenance-planned", "reserved-for-facility-unvalidated", "not-reserved-unvalidated", "unknown-unvalidated", "reserved-for-maintenance-unvalidated", "reserved-for-facility-available", "not-reserved-available", "reserved-for-maintenance-available", "reserved-for-reversion-inuse", "not-reserved-inuse", "reserved-for-maintenance-inuse"])    random
     &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   equipment-state-shelves=${equipment_state_for_shelf}
     @{shelves}    create list   ${shelf}
     &{dev_shelves}   create_dictionary   shelves=${shelves}
     &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
     Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}	


#TC11
	#[Documentation]  Limitation test for equipment-state via openRoadm leaf reserved-for-facility-planned/not-reserved-planned/reserved-for-maintenance-planned/reserved-for-facility-unvalidated/not-reserved-unvalidated/unknown-unvalidated/reserved-for-maintenance-unvalidated/reserved-for-facility-available/not-reserved-available/reserved-for-maintenance-available/reserved-for-reversion-inuse/not-reserved-inuse/reserved-for-maintenance-inuse
	#...              Mapping RLI38968   5.2-20
    #[Tags]           Negative  TC11
    #Log              Limitation test for shelf equipment-state via Restconf patch method      
    #&{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   equipment-state-shelves=${INVALID_EQUIPMENT_STATE_SHELVES}
	#@{shelves}    create list   ${shelf}	
	#&{dev_shelves}   create_dictionary   shelves=${shelves}
	#&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}	
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	#check status line  ${patch_resp}  400  set equipment-state with invalid value should failed and return status code 400

	
	
TC12
    [Documentation]  Verify due-date can be set via openRoadm leaf pattern '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?' + '(Z|[\+\-]\d{2}:\d{2})'
    ...              Mapping RLI38968   5.2-21 
    [Tags]           Sanity   TC12  
    Log                     setting due-date via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   due-date-shelves=${tv['uv-valid_due_date']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Merge Then Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



#TC13
    #[Documentation]  Limitation test for dur-date via openRoadm leaf pattern '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?' + '(Z|[\+\-]\d{2}:\d{2})'
    #...              Mapping RLI38968   5.2-22
    #[Tags]           Negative   TC13
    #Log              Limitation test for shelf due-date via Restconf patch method
    #&{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   due-date-shelves=${INVALID_DUE_DATE}
    #@{shelves}    create list   ${shelf}	
    #&{dev_shelves}   create_dictionary   shelves=${shelves}
    #&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    #${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    #check status line  ${patch_resp}  400  set due-date with invalid value should failed and return status code 400	

	
	
TC14
	[Documentation]  Limitation test for due-date via openRoadm leaf pattern '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?' + '(Z|[\+\-]\d{2}:\d{2})'
    ...              Mapping RLI38968   5.2-22
	[Tags]           Negative   TC14
    Log              Limitation test for shelf due-date via Restconf patch method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   due-date-shelves=${INVALID_FORMAT_DUE_DATE}
	@{shelves}    create list   ${shelf}	
	&{dev_shelves}   create_dictionary   shelves=${shelves}
	&{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
	${patch_resp}  Send Merge Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	check status line  ${patch_resp}  400

    
    
TC15
	[Documentation]   This test case mapping to test cases 5.3.1 to 5.3.12 in JTMS for RLI38968     
	[Tags]            Sanity  TC15    
    Log               Configure all R/W leaves for circuit-pack FPC via Restconf 
    &{fpckey}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}   circuit-pack-type=FPC  shelf=shelf-0  slot=slot-0  subSlot=slot-0
    @{fpc_info}    create list    ${fpckey} 
    &{dev_info}   create_dictionary   circuit-packs=${fpc_info}    
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}

    
    
TC16
    [Documentation]  This test case mapping to 5.5-1 ~~~~ 5.5-10 for JTMS RLI-38968
    [Tags]           Sanity  TC16
    Log              Configure all R/W leaves for circuit-pack FAN via Restconf       
    ${administrative_state_for_fan}    evaluate    random.choice(["inService", "outOfService", "maintenance"])     random
    &{fankey}    create_dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-3 
    &{fankey1}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot4_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-4  
    &{fankey2}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot5_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-5  
    &{fankey3}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot6_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-6  
    &{fankey4}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot7_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-7  
    @{fan_info}    create list    ${fankey}  ${fankey1}  ${fankey2}  ${fankey3}  ${fankey4}
    &{dev_info}   create_dictionary   circuit-packs=${fan_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}   



TC17
	[Documentation]  This test case mapping to 5.4-1 ~~~~ 5.4-10 and 5.4-23 for JTMS RLI-38968
	[Tags]           Sanity   TC17   
    Log              Configure all R/W leaves for circuit-pack PSM via Restconf 
	${administrative_state_for_psm}    evaluate    random.choice(["inService", "outOfService", "maintenance"])     random
    &{psmkey}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-PowerSupply  shelf=shelf-0  slot=slot-1
    ...         administrative-state-cp=${administrative_state_for_psm}    equipment-state-cp=reserved-for-facility-available   circuit-pack-product-code=NON-JNPR 
    ...         circuit-pack-mode=NORMAL   subSlot=slot-0    is-pluggable-optics=false   due-date-cp=${tv['uv-valid_due_date']} 
    &{psmkey1}    create_dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-PowerSupply  shelf=shelf-0  slot=slot-2 
    ...         administrative-state-cp=${administrative_state_for_psm}    equipment-state-cp=reserved-for-facility-available   circuit-pack-product-code=NON-JNPR 
    ...         circuit-pack-mode=NORMAL   subSlot=slot-0    is-pluggable-optics=false   due-date-cp=${tv['uv-valid_due_date']}  
    @{psm_info}    create list    ${psmkey}  ${psmkey1} 
    &{dev_info}   create_dictionary   circuit-packs=${psm_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}     




TC18
	[Documentation]  Verify can retrieve shelf R/W values via openRoadm leaf   
                ...              Mapping RLI38968   5.2-26
	[Tags]        Sanity   TC18    
    Log                     FeTChing shelf all values via ResTConf GET method 
    ${administrative_state_for_shelf}    Set variable    inService    
    ${equipment_state_for_shelf}     Set variable    reserved-for-facility-planned
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}    rack=${tv['uv-rack']}     equipment-state-shelves=${equipment_state_for_shelf}  
	...     shelf-type=${tv['uv-shelf_type']}    shelf-position=${tv['uv-shelf_position']}   administrative-state-shelves=${administrative_state_for_shelf}
	...     due-date-shelves=${tv['uv-valid_due_date']}   
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



 
TC19
	[Documentation]  Verify can retrieve shelf readonly info via openRoadm leaf      
    ...              Mapping RLI38968   5.2-10  5.2-11  5.2-12  5.2-13   5.2-14   5.2-15   5.2-16   5.2-17   5.2-18  5.2-23   5.2-24   5.2-25
	[Tags]          Sanity  TC19  
    Log                     FeTChing shelf operational values via ResTConf GET method
	&{slot0}	  create_dictionary   slot-name=${tv['uv-attella_def_slot0_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}  
	&{slot1}	  create_dictionary   slot-name=${tv['uv-attella_def_slot1_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  
	&{slot2}	  create_dictionary   slot-name=${tv['uv-attella_def_slot2_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  
	&{slot3}	  create_dictionary   slot-name=${tv['uv-attella_def_slot3_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}  
	&{slot4}	  create_dictionary   slot-name=${tv['uv-attella_def_slot4_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot4_provisioned_circuit_pack']}  
	&{slot5}	  create_dictionary   slot-name=${tv['uv-attella_def_slot5_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot5_provisioned_circuit_pack']}  
	&{slot6}	  create_dictionary   slot-name=${tv['uv-attella_def_slot6_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot6_provisioned_circuit_pack']}  
	&{slot7}	  create_dictionary   slot-name=${tv['uv-attella_def_slot7_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot7_provisioned_circuit_pack']}  
	@{slots}    create list   ${slot0}  ${slot1}  ${slot2}  ${slot3}  ${slot4}  ${slot5}  ${slot6}  ${slot7}	
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}  vendor-shelves=${tv['uv-attella_def_vendor']}  model-shlves=${ATTELLA_DEF_MODEL.text}  
	...     serial-id-shelves=${ATTELLA_DEF_SERIAL_ID.text}  type=${tv['uv-attella_def_type']}  product-code=${ATTELLA_DEF_PRODUCT_CODE.text} 
	...     clei=${ATTELLA_DEF_CLEI.text}  hardware-version=${ATTELLA_DEF_HARDWARE_VERSION.text}
	...     slots=${slots}
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



TC20
    [Documentation]  Verify shelf info can be deleted via openRoadm leaf      
    ...              Mapping RLI38968   5.2-27
    [Tags]           Sanity  TC20 
    Log                     Delete shelf via ResTConf paTCh method
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    ${paTCh_resp}  Send Delete Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    check status line  ${paTCh_resp}  200	
    ${paTCh_resp}  Send Delete Request  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
    check status line  ${paTCh_resp}  404


TC21
	[Documentation]  Verify can retrieve shelf R/W values via openRoadm leaf   
    ...              Mapping RLI38968   5.2-26
	[Tags]        Sanity   TC21    
    Log                     FeTChing shelf all values via ResTConf GET method 
    ${administrative_state_for_shelf}    Set variable    inService    
    ${equipment_state_for_shelf}     Set variable    reserved-for-facility-planned
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}    rack=${tv['uv-rack']}     equipment-state-shelves=${equipment_state_for_shelf}  
	...     shelf-type=${tv['uv-shelf_type']}    shelf-position=${tv['uv-shelf_position']}   administrative-state-shelves=${administrative_state_for_shelf}
	...     due-date-shelves=${tv['uv-valid_due_date']}   
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}



 
TC22
	[Documentation]  Verify can retrieve shelf readonly info via openRoadm leaf      
    ...              Mapping RLI38968   5.2-10  5.2-11  5.2-12  5.2-13   5.2-14   5.2-15   5.2-16   5.2-17   5.2-18  5.2-23   5.2-24   5.2-25
	[Tags]          Sanity  TC22  
    Log                     FeTChing shelf operational values via ResTConf GET method
	&{slot0}	  create_dictionary   slot-name=${tv['uv-attella_def_slot0_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}  
	&{slot1}	  create_dictionary   slot-name=${tv['uv-attella_def_slot1_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  
	&{slot2}	  create_dictionary   slot-name=${tv['uv-attella_def_slot2_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  
	&{slot3}	  create_dictionary   slot-name=${tv['uv-attella_def_slot3_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}  
	&{slot4}	  create_dictionary   slot-name=${tv['uv-attella_def_slot4_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot4_provisioned_circuit_pack']}  
	&{slot5}	  create_dictionary   slot-name=${tv['uv-attella_def_slot5_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot5_provisioned_circuit_pack']}  
	&{slot6}	  create_dictionary   slot-name=${tv['uv-attella_def_slot6_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot6_provisioned_circuit_pack']}  
	&{slot7}	  create_dictionary   slot-name=${tv['uv-attella_def_slot7_name']}  provisioned-circuit-pack=${tv['uv-attella_def_slot7_provisioned_circuit_pack']}  
	@{slots}    create list   ${slot0}  ${slot1}  ${slot2}  ${slot3}  ${slot4}  ${slot5}  ${slot6}  ${slot7}
    &{dev_info}   create_dictionary   shelf-name=${tv['uv-shelf_name']}  vendor-shelves=${tv['uv-attella_def_vendor']}  model-shlves=${ATTELLA_DEF_MODEL.text}  
	...     serial-id-shelves=${ATTELLA_DEF_SERIAL_ID.text}  type=${tv['uv-attella_def_type']}  product-code=${ATTELLA_DEF_PRODUCT_CODE.text} 
	...     clei=${ATTELLA_DEF_CLEI.text}  hardware-version=${ATTELLA_DEF_HARDWARE_VERSION.text}
	...     slots=${slots}
	&{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}


  

     
    
    
    
    
*** Keywords ***
Testbed Init
	Set Log Level  DEBUG
    Initialize
    Log To Console      Loading Baseline configurations
    ${device0} =     Get Handle      resource=device0
    @{dut_list}    create list    device0
    Preconfiguration netconf feature    @{dut_list}
    ${Hardware} =  Execute cli command on device    device=${device0}    command=show chassis hardware   format=xml	
    ${ATTELLA_DEF_SERIAL_ID}        Get Element   ${Hardware}  chassis-inventory/chassis/serial-number
    Log To Console   ${ATTELLA_DEF_SERIAL_ID.text}     
    ${ATTELLA_DEF_HARDWARE_VERSION}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/version
    Log To Console   ${ATTELLA_DEF_HARDWARE_VERSION.text}
    ${ATTELLA_DEF_PRODUCT_CODE}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/part-number
    Log To Console   ${ATTELLA_DEF_PRODUCT_CODE.text}
    ${ATTELLA_DEF_CLEI}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/clei-code
    Log To Console   ${ATTELLA_DEF_CLEI.text}
    ${ATTELLA_DEF_MODEL}       Get Element   ${Hardware}  chassis-inventory/chassis/chassis-module[3]/description
    Log To Console   ${ATTELLA_DEF_MODEL.text}
    
    
    Set Global Variable  ${ATTELLA_DEF_SERIAL_ID.text}    
    Set Global Variable  ${ATTELLA_DEF_HARDWARE_VERSION.text}
    Set Global Variable  ${ATTELLA_DEF_PRODUCT_CODE.text}
    Set Global Variable  ${ATTELLA_DEF_CLEI.text}
    Set Global Variable  ${ATTELLA_DEF_MODEL.text}
    
    
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
	
	Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
>>>>>>> 425f76d9753f6cd1b9e0f6702c81ed9f3967b13d
