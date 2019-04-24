*** Settings ***
Documentation    This is Attella interface Scripts
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : tsyong@juniper.net
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
@{auth}    admin    admin
${interval}  120
${timeout}  120

*** Test Cases ***
TC1
    [Documentation]   Provsion FPC-0
    ...               TC 5.1-1  RLI-38963
    [Tags]            Sanity   TC1   Set-CP-FPC
    Log               Configure all R/W leaves for circuit-pack FPC via Restconf
    ${administrative_state_for_fpc}           evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    &{fpckey}         create dictionary       circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}                                circuit-pack-type=FPC        shelf=shelf-0     slot=slot-0     subSlot=slot-0
    ...               administrative-state-cp=${administrative_state_for_fpc}                        equipment-state-cp=reserved-for-facility-available    circuit-pack-mode=NORMAL
    ...                          due-date-cp=${tv['uv-valid_due_date']}     circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    @{fpc_info}       create list             ${fpckey}
    &{dev_info}       create dictionary       circuit-packs=${fpc_info}
    &{payload}        createdictionary        org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}

TC2
    [Documentation]  Check all read-only leaves for fpc-0
    ...              TC 5.1-14  RLI-38963
    [Tags]           Sanity  TC2   Get-CP-FPC-READONLY
    Log              Get all read-only leaves(except serial-id) for circuit-pack FPC via Restconf
    &{cp-port1}      create dictionary    slot-name-cp=slot-0/0        label-cp=0          slot-type=other
    &{cp-port2}      create dictionary    slot-name-cp=slot-0/1        label-cp=1          slot-type=other
    @{fpc_cport_info}    create list    ${cp-port1}   ${cp-port2}
    &{fpckey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}   vendor-cp=${tv['uv-attella_def_vendor']}   product-code-cp=${tv['uv-attella_def_product_code_fpc_pic']}   model-cp=${ATTELLA_DEF_FPC_MODEL.text}
    ...                 operational-state-cp=${tv['uv-attella_def_operational_state2']}                  type-cp=FPC                                vendor-cp=${tv['uv-attella_def_vendor']}
    ...              serial-id-cp=${ATTELLA_DEF_FPC_SERIAL_ID.text}    software-load-version=${osVersion.text}            type-cp-category=${tv['uv-attella_def_circuit_pack_category']}
    ...              cp-slots=${fpc_cport_info}
    @{fpc_info}      create list    ${fpckey}
    &{static_info}   create dictionary    circuit-packs=${fpc_info}
    &{payload}       create dictionary    org-openroadm-device=${static_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}

TC3
    [Documentation]  Provison Fan Tray Units
    ...              TC 5.1-9  RLI-38963
    [Tags]           Sanity   TC3   Set-CP-FAN
    Log              Configure all R/W leaves for circuit-pack FAN via Restconf
    ${administrative_state_for_fan}             evaluate          random.choice(["inService", "outOfService", "maintenance"])         random
    &{fankey}        create dictionary          circuit-pack-name-self=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}         circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-3
    ...              administrative-state-cp=${administrative_state_for_fan}    equipment-state-cp=reserved-for-facility-available    circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    ...              circuit-pack-mode=NORMAL   subSlot=slot-0    due-date-cp=${tv['uv-valid_due_date']}
    &{fankey1}       create dictionary          circuit-pack-name-self=${tv['uv-attella_def_slot4_provisioned_circuit_pack']}         circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-4
    ...              administrative-state-cp=${administrative_state_for_fan}    equipment-state-cp=reserved-for-facility-available    circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    ...              circuit-pack-mode=NORMAL   subSlot=slot-0       due-date-cp=${tv['uv-valid_due_date']}
    &{fankey2}       create dictionary          circuit-pack-name-self=${tv['uv-attella_def_slot5_provisioned_circuit_pack']}         circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-5
    ...              administrative-state-cp=${administrative_state_for_fan}    equipment-state-cp=reserved-for-facility-available    circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    ...              circuit-pack-mode=NORMAL   subSlot=slot-0       due-date-cp=${tv['uv-valid_due_date']}
    &{fankey3}       create dictionary          circuit-pack-name-self=${tv['uv-attella_def_slot6_provisioned_circuit_pack']}         circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-6
    ...              administrative-state-cp=${administrative_state_for_fan}    equipment-state-cp=reserved-for-facility-available    circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    ...              circuit-pack-mode=NORMAL   subSlot=slot-0       due-date-cp=${tv['uv-valid_due_date']}
    &{fankey4}       create dictionary          circuit-pack-name-self=${tv['uv-attella_def_slot7_provisioned_circuit_pack']}         circuit-pack-type=ACX6180-T-Fan-Tray  shelf=shelf-0  slot=slot-7
    ...              administrative-state-cp=${administrative_state_for_fan}    equipment-state-cp=reserved-for-facility-available    circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    ...              circuit-pack-mode=NORMAL   subSlot=slot-0       due-date-cp=${tv['uv-valid_due_date']}
    @{fan_info}      create list                ${fankey}  ${fankey1}  ${fankey2}  ${fankey3}  ${fankey4}
    &{dev_info}      create dictionary          circuit-packs=${fan_info}
    &{payload}       create dictionary          org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct      ${odl_sessions}     ${tv['device0__re0__mgt-ip']}     ${payload}

TC4
    [Documentation]  Check all read-only leaves for Fan Tray Units
    ...              TC 5.1-15  RLI-38963
    [Tags]           Sanity  TC4   Get-CP-FAN-READONLY
    Log              Get all read-only leaves(except serial-id) for circuit-pack FAN via Restconf
    : FOR            ${INDEX}         IN RANGE    0    5
    \                &{Fan0_info}     create dictionary       circuit-pack-name-self=fan-${INDEX}  vendor-cp=${tv['uv-attella_def_vendor']}                   model-cp=${ATTELLA_DEF_FAN_MODEL.text}
    \                ...   type-cp=FTU  type-cp-category=fan                    product-code-cp=${tv['uv-attella_def_fan_product_code']}
    \                ...   software-load-version=${osVersion.text}                                 operational-state-cp=${tv['uv-attella_def_operational_state2']}
    \                @{Fan_info}      create list    ${Fan0_info}
    \                &{static_info}   create dictionary       circuit-packs=${Fan_info}
    \                &{payload}       create dictionary       org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}

TC5
    [Documentation]  Provison Power Supply Units
    ...              TC 5.1-6  RLI-38963
    [Tags]           Sanity   TC5   set-CP-PSM
    Log              Configure all R/W leaves for circuit-pack PSM via Restconf
    ${administrative_state_for_psm}       evaluate                random.choice(["inService", "outOfService", "maintenance"])     random
    &{psmkey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-PowerSupply     shelf=shelf-0  slot=slot-1
    ...              administrative-state-cp=${administrative_state_for_psm}       equipment-state-cp=reserved-for-facility-available   due-date-cp=${tv['uv-valid_due_date']}     
	...              circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_psm_product_code']}
    ...              circuit-pack-mode=NORMAL   subSlot=slot-0      
    &{psmkey1}       create dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  circuit-pack-type=ACX6180-PowerSupply     shelf=shelf-0  slot=slot-2
    ...              administrative-state-cp=${administrative_state_for_psm}       equipment-state-cp=reserved-for-facility-available      circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_psm_product_code']}
    ...              circuit-pack-mode=NORMAL   subSlot=slot-0      
	...              due-date-cp=${tv['uv-valid_due_date']}
    @{psm_info}      create list          ${psmkey}  ${psmkey1}
    &{dev_info}      create dictionary    circuit-packs=${psm_info}
    &{payload}       create dictionary    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}

TC6
    [Documentation]  Check all read-oly leaves for Provison Power Supply Units
    ...              TC 5.1-16  RLI-38963
    [Tags]           Sanity   TC6    Get-CP-PSM-READONLY
    Log              Get all read-only leaves(except serial-id) for circuit-pack PSM via Restconf
    &{psm0_info}     create dictionary      circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  vendor-cp=${tv['uv-attella_def_vendor']}   model-cp=${ATTELLA_DEF_PSM0_MODEL.text}
    ...              hardware-version-cp=${ATTELLA_DEF_PSM0_HAREWARE_VERSION.text}       type-cp=PSM  type-cp-category=powerSupply  clei-cp=${ATTELLA_DEF_PSM0_CLEI.text}   product-code-cp=${ATTELLA_DEF_PSM0_PRODUCT_CODE.text}
    ...              software-load-version=${osVersion.text}
    &{psm1_info}     create dictionary      circuit-pack-name-self=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  vendor-cp=${tv['uv-attella_def_vendor']}   model-cp=${ATTELLA_DEF_PSM1_MODEL.text}
    ...              hardware-version-cp=${ATTELLA_DEF_PSM1_HAREWARE_VERSION.text}       type-cp=PSM  type-cp-category=powerSupply  clei-cp=${ATTELLA_DEF_PSM1_CLEI.text}   product-code-cp=${ATTELLA_DEF_PSM1_PRODUCT_CODE.text}
    ...              software-load-version=${osVersion.text}
    @{psm_info}      create list            ${psm0_info}   ${psm1_info}
    &{static_info}   create dictionary      circuit-packs=${psm_info}
    &{payload}       create dictionary      org-openroadm-device=${static_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}

TC7
    [Documentation]  Provison pic-0/0
    ...              TC 5.1-3  RLI-38963	
    [Tags]           Sanity    TC7   Set-CP-PIC0
    Log              Configure all R/W leaves for circuit-pack PIC0 via Restconf
    &{pic0key}       create dictionary            circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     circuit-pack-type=${ATTELLA_DEF_PIC0_MODEL.text}      shelf=shelf-0             slot=slot-0
    ...              administrative-state-cp=inService                 equipment-state-cp=reserved-for-facility-available                                             circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    ...              circuit-pack-mode=NORMAL     subSlot=slot-0/0     
	...              due-date-cp=${tv['uv-valid_due_date']}                cp-slot-name=slot-0/0     circuit-pack-name-parent=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}
    @{pic_info}      create list    ${pic0key}
    &{dev_info}      create dictionary            circuit-packs=${pic_info}
    &{payload}       create dictionary            org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}

TC8
    [Documentation]  Check all read-only leaves for  pic-0/0
    ...              TC 5.1-17  RLI-38963
    [Tags]           Sanity   TC8   Get-CP-PIC0-READONLY
    Log              Get all read-only leaves(except serial-id) for circuit-pack PIC0 via Restconf

    :FOR             ${clientID}                 IN RANGE      0     7    2
    \                &{ont-capability-100GE}     create dictionary      if-cap-type-cp=${tv['uv-attella_def_circuit_pack_if_cap_type_ge']}            proactive-DMp-cp=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-cp=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-cp=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                &{ont-capability-OUT4}      create dictionary      if-cap-type-cp=${tv['uv-attella_def_circuit_pack_if_cap_type_odu4']}             proactive-DMp-cp=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-cp=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-cp=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                @{client-port}              create list            ${ont-capability-100GE}                                                     ${ont-capability-OUT4}
    \                &{pic-client-port}          create dictionary      port-name-cp=port-0/0/${clientID}                                            if-cap-type-cp=${client-port}
    \                @{supported-type-client}    create list            ${pic-client-port}
    \                &{supported-client}         create dictionary      supported-circuit-pack-type-cp=qsfp28-port                                   port-name-cp=${supported-type-client}
    \                @{client-type}              create list            ${supported-client}
    \                &{cp-port}                  create dictionary      slot-name-cp=slot-0/0/${clientID}     label-cp=0/${clientID}                 slot-type=pluggable-optics-holder          supported-circuit-pack-type-cp=${client-type}
    \                @{pic0_cport_info}          create list            ${cp-port}
    \                &{pickey}                   create dictionary      circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}                     vendor-cp=${tv['uv-attella_def_vendor']}   product-code-cp=${tv['uv-attella_def_product_code_fpc_pic']}      model-cp=${ATTELLA_DEF_PIC0_MODEL.text}
    \                ...                              operational-state-cp=${tv['uv-attella_def_operational_state2']}               type-cp=PIC
    \                ...                         software-load-version=${osVersion.text}                      type-cp-category=${tv['uv-attella_def_circuit_pack_category']}                    
    \                ...                         cp-slots=${pic0_cport_info}
    \                @{pic_info}                 create list            ${pickey}
    \                &{static_info}              create dictionary      circuit-packs=${pic_info}
    \                &{payload}                  create dictionary      org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct      ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}

	
	
TC9
    [Documentation]  Provison pic-0/1 
    ...              TC 5.1-5  RLI-38963
    [Tags]           Sanity   TC9   Set-CP-PIC1
    Log              Configure all R/W leaves for circuit-pack PIC1 via Restconf
    &{pic1key}       create dictionary                    circuit-pack-name-self=${tv['uv-attella_def_pic1_name']}   circuit-pack-type=4X200G-CFP2DCO        shelf=shelf-0           slot=slot-0
    ...              administrative-state-cp=inService    equipment-state-cp=reserved-for-facility-available         circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    ...              circuit-pack-mode=NORMAL             subSlot=slot-0/1         
	...              due-date-cp=${tv['uv-valid_due_date']}  cp-slot-name=slot-0/1   circuit-pack-name-parent=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}
    @{pic_info}      create list                          ${pic1key}
    &{dev_info}      create dictionary                    circuit-packs=${pic_info}
    &{payload}       create dictionary                    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}


TC10
    [Documentation]  Check all read-only leaves for  pic-0/1
    ...              TC 5.1-18  RLI-38963
    [Tags]           Sanity   TC10   Get-CP-PIC1-READONLY
    Log              Get all read-only leaves(except serial-id) for circuit-pack PIC1 via Restconf

    :FOR             ${lineID}                  IN RANGE      0     4
    \                &{ont-capability-Line0}    create dictionary     if-cap-type-cp=${tv['uv-attella_def_circuit_pack_line_if_cap_type']}             proactive-DMp-cp=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-cp=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-cp=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                &{ont-capability-Line1}    create dictionary     if-cap-type-cp=${tv['uv-attella_def_circuit_pack_line_if_cap_type']}             proactive-DMp-cp=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-cp=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-cp=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                @{line-port}               create list           ${ont-capability-Line0}                         ${ont-capability-Line1}
    \                &{pic1-line-port}          create dictionary     port-name-cp=port-0/1/${lineID}                 if-cap-type-cp=${line-port}
    \                @{supported-type-line}     create list           ${pic1-line-port}
    \                &{supported-line}          create dictionary     supported-circuit-pack-type-cp=cfp2dco-port     port-name-cp=${supported-type-line}
    \                @{line-type}               create list           ${supported-line}
    \                &{cp-port}                 create dictionary     slot-name-cp=slot-0/1/${lineID}                 label-cp=1/${lineID}          slot-type=pluggable-optics-holder          supported-circuit-pack-type-cp=${line-type}
    \                @{pic1_lport_info}         create list           ${cp-port}
    \                &{pickey}                  create dictionary     circuit-pack-name-self=${tv['uv-attella_def_pic1_name']}                      vendor-cp=${tv['uv-attella_def_vendor']}   product-code-cp=${tv['uv-attella_def_product_code_fpc_pic']}   model-cp=${ATTELLA_DEF_PIC1_MODEL.text}
    \                ...                            operational-state-cp=${tv['uv-attella_def_operational_state2']}                type-cp=PIC
    \                ...                        software-load-version=${osVersion.text}                               type-cp-category=${tv['uv-attella_def_circuit_pack_category']}
    \                ...                        cp-slots=${pic1_lport_info}
    \                @{pic_info}                create list           ${pickey}
    \                &{static_info}             create dictionary     circuit-packs=${pic_info}
    \                &{payload}                 create dictionary     org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}


TC11
    [Documentation]  Provison QSFP28 transceivers
    ...              TC 5.1-10  RLI-38963	
    [Tags]           Sanity   TC11   Set-QPSK28-R/W
    Log              Configure all R/W leaves for circuit-pack QSFP28 via Restconf
    : FOR            ${ClientID}        IN RANGE    0    8
    \                &{ctransc}         create dictionary       port-name-p=port-0/0/${ClientID}               port-type=qsfp28-port                port-qual=xpdr-client            circuit-id=Client-QSFP28     administrative-state=inService    logical-connection-point=foo
    \                @{ctransclist}     create list             ${ctransc}
    \                &{ctransckey}      create dictionary       circuit-pack-name-self=xcvr-0/0/${ClientID}    circuit-pack-type=${tv['uv-attella_def_circuit_pack_type_qsfp28']}     shelf=shelf-0    slot=slot-0
    \                ...                administrative-state-cp=inService      equipment-state-cp=reserved-for-facility-available                   circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_qsfp28_product_code']}
    \                ...                circuit-pack-mode=NORMAL              subSlot=slot-0/0/${ClientID}                 due-date-cp=${tv['uv-valid_due_date']}
    \                ...                circuit-pack-name-parent=${tv['uv-attella_def_pic0_name']}             cp-slot-name=slot-0/0/${ClientID}    ports=${ctransclist}
    \                @{ctransc_info}    create list             ${ctransckey}
    \                &{dev_info}        create dictionary       circuit-packs=${ctransc_info}
    \                &{payload}         create dictionary       org-openroadm-device=${dev_info}
    \                Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}


TC12
    [Documentation]  Check all read-only leaves for  QSFP28 transceivers
    ...              TC 5.1-19  RLI-38963	
    [Tags]           Sanity   TC12   Get-QPSK28-READONLY
    Log              Get all read-only leaves(except serial-id) for circuit-pack QSFP28 via Restconf
    :FOR             ${INDEX}    IN RANGE    0    7    2
    \                &{ont-capability-100GE}    create dictionary     if-cap-type-ports=${tv['uv-attella_def_circuit_pack_if_cap_type_ge']}             proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                &{ont-capability-OUT4}     create dictionary     if-cap-type-ports=${tv['uv-attella_def_circuit_pack_if_cap_type_odu4']}           proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                @{client-port}             create list           ${ont-capability-100GE}         ${ont-capability-OUT4}
    \                &{ports}                   create dictionary     port-name-p=port-0/0/${INDEX}   port-direction=bidirectional    port-wavelength-type=wavelength    label-ports=0/${INDEX}      if-cap-type-ports=${client-port}     port-power-capability-min-rx=-22.00      port-power-capability-min-tx=-12.00      port-power-capability-max-rx=0.00     port-power-capability-max-tx=2.00
    \                @{portlist}                create list           ${ports}
    \                &{optics_info}             create dictionary     circuit-pack-name-self=xcvr-0/0/${INDEX}                        vendor-cp=${tv['uv-attella_def_vendor']}
    \                ...                        software-load-version=${osVersion.text}               ports=${portlist}
    \                @{Transc_info}             create list           ${optics_info}
    \                &{static_info}             create dictionary     circuit-packs=${Transc_info}
    \                &{payload}                 create dictionary     org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC13
    [Documentation]  Provison CFP2-DCO transceivers
    ...              TC 5.1-12  RLI-38963
    [Tags]           Sanity   TC13   Set-CFP2DCO-R/W
    Log              Configure all R/W leaves for circuit-pack CFP2DCO via Restconf
    : FOR            ${ClientID}       IN RANGE    0    4
    \                &{ltransc}        create dictionary     port-name-p=port-0/1/${ClientID}                 port-type=cfp2dco-port      port-qual=xpdr-network   circuit-id=${tv['uv-attella_def_circuit_pack_type_cfp2dco']}   administrative-state=inService    logical-connection-point=foo
    \                @{ltransclist}    create list           ${ltransc}
    \                &{ltransckey}     create dictionary     circuit-pack-name-self=xcvr-0/1/${ClientID}      circuit-pack-type=CFP2DCO   shelf=shelf-0    slot=slot-0
    \                ...               administrative-state-cp=inService     equipment-state-cp=reserved-for-facility-available           circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_cfp2dco_product_code']}
    \                ...               circuit-pack-mode=NORMAL              subSlot=slot-0/1/${ClientID}         due-date-cp=${tv['uv-valid_due_date']}
    \                ...               circuit-pack-name-parent=${tv['uv-attella_def_pic1_name']}             cp-slot-name=slot-0/1/${ClientID}             ports=${ltransclist}
    \                @{ltransc_info}   create list           ${ltransckey}
    \                &{dev_info}       create dictionary     circuit-packs=${ltransc_info}
    \                &{payload}        create dictionary     org-openroadm-device=${dev_info}
    \                Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC14
    [Documentation]  Check all read-only leaves for  CFP2-DCO transceivers
    ...              TC 5.1-20  RLI-38963
    [Tags]           Sanity   TC14   Get-CFP2DCO-READONLY
    Log              Get all read-only leaves(except serial-id) for circuit-pack CFP2DCO via Restconf
    : FOR            ${INDEX}    IN RANGE    0    4

    \                &{ont-capability-Line0}    create dictionary     if-cap-type-cp=${tv['uv-attella_def_circuit_pack_line_if_cap_type']}             proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                &{ont-capability-Line1}    create dictionary     if-cap-type-cp=${tv['uv-attella_def_circuit_pack_line_if_cap_type']}             proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                @{line-port}               create list           ${ont-capability-Line0}                         ${ont-capability-Line1}
    \                &{ports}                   create dictionary     port-name-p=port-0/1/${INDEX}  port-direction=bidirectional   port-wavelength-type=wavelength   label-ports=1/${INDEX}  port-type=cfp2dco-port    if-cap-type-ports=${line-port}
    \                @{portlist}                create list           ${ports}
    \                &{optics_info}             create dictionary     circuit-pack-name-self=xcvr-0/1/${INDEX}  vendor-cp=${tv['uv-attella_def_vendor']}  software-load-version=${osVersion.text}    ports=${portlist}
    \                @{Transc_info}             create list           ${optics_info}
    \                &{static_info}             create dictionary     circuit-packs=${Transc_info}
    \                &{payload}                 create dictionary     org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}

TC15
    [Documentation]  Get-and-Verify-SN-Number-for-QSFP28
    ...              TC 5.3-6  RLI-38968
    [Tags]           Sanity  TC15   Get-and-Verify-SN-Number-for-QSFP28
    Log              Configure circuit-pack-name via Restconf Patch method, then verify the SN number is right for this QSFP28 module.
    &{ctransc}         create dictionary       port-name-p=port-0/0/${QSFP28_INDEX}      port-type=qsfp28-port                port-qual=xpdr-client            circuit-id=Client-QSFP28     administrative-state=inService    logical-connection-point=foo
    @{ctransclist}     create list             ${ctransc}
    &{ctransckey}      create dictionary       circuit-pack-name-self=xcvr-0/0/${QSFP28_INDEX}    circuit-pack-type=${tv['uv-attella_def_circuit_pack_type_qsfp28']}     shelf=shelf-0    slot=slot-0
    ...                administrative-state-cp=inService      equipment-state-cp=reserved-for-facility-available                   circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_qsfp28_product_code']}
    ...                circuit-pack-mode=NORMAL              subSlot=slot-0/0/${QSFP28_INDEX}     
    ...                due-date-cp=${tv['uv-valid_due_date']}
    ...                circuit-pack-name-parent=${tv['uv-attella_def_pic0_name']}             cp-slot-name=slot-0/0/${QSFP28_INDEX}    ports=${ctransclist}
    @{ctransc_info}    create list             ${ctransckey}
    &{dev_info}        create dictionary       circuit-packs=${ctransc_info}
    &{payload}         create dictionary       org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}
    &{optics_info}             create dictionary     circuit-pack-name-self=xcvr-0/0/${QSFP28_INDEX}    serial-id-cp=${QSFP28_SN}
    @{Transc_info}             create list           ${optics_info}
    &{static_info}             create dictionary     circuit-packs=${Transc_info}
    &{payload}                 create dictionary     org-openroadm-device=${static_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC16
    [Documentation]  Get-and-Verify-SN-Number-for-CFP2DCO
    ...              TC 5.3-6  RLI-38968
    [Tags]           Sanity  TC16   Get-and-Verify-SN-Number-for-CFP2DCO
    Log              Configure circuit-pack-name via Restconf Patch method, then verify the SN number is right for this CFP2DCO module.
    &{ctransc}         create dictionary       port-name-p=port-0/1/${CFP2_INDEX}      port-type=cfp2dco-port                port-qual=xpdr-network            circuit-id=CFP2DCO     administrative-state=inService    logical-connection-point=foo
    @{ctransclist}     create list             ${ctransc}
    &{ctransckey}      create dictionary       circuit-pack-name-self=xcvr-0/1/${CFP2_INDEX}    circuit-pack-type=${tv['uv-attella_def_circuit_pack_type_qsfp28']}     shelf=shelf-0    slot=slot-0
    ...                administrative-state-cp=inService      equipment-state-cp=reserved-for-facility-available                   circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_cfp2dco_product_code']}
    ...                circuit-pack-mode=NORMAL              subSlot=slot-0/1/${CFP2_INDEX}     is-pluggable-optics=true    due-date-cp=${tv['uv-valid_due_date']}
    ...                circuit-pack-name-parent=${tv['uv-attella_def_pic1_name']}             cp-slot-name=slot-0/1/${CFP2_INDEX}    ports=${ctransclist}
    @{ctransc_info}    create list             ${ctransckey}
    &{dev_info}        create dictionary       circuit-packs=${ctransc_info}
    &{payload}         create dictionary       org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}
    &{optics_info}             create dictionary     circuit-pack-name-self=xcvr-0/1/${CFP2_INDEX}    serial-id-cp=${CFP2DCO_SN}
    @{Transc_info}             create list           ${optics_info}
    &{static_info}             create dictionary     circuit-packs=${Transc_info}
    &{payload}                 create dictionary     org-openroadm-device=${static_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC17
    [Documentation]  verify the name of circuit-pack can be retrieved and configured
    ...              TC 5.3-2  RLI-38968
    [Tags]           Sanity  TC17   Set-CP-NAME
    Log              Configure circuit-pack-name via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}   circuit-pack-type=${ATTELLA_DEF_PIC0_MODEL.text}    shelf=shelf-0    slot=slot-0
    @{pic_info}      create list          ${pickey}
    &{dev_info}      create dictionary    circuit-packs=${pic_info}
    &{payload}       create dictionary    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC18
    [Documentation]  verify the product-code of circuit-pack can be retrieved
    ...              TC 5.3-8  RLI-38968
    [Tags]           Sanity  TC18   Set-CP-Product-Code
    Log              Configure circuit-pack-product-code via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary     circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    @{pic_info}      create list           ${pickey}
    &{dev_info}      create dictionary     circuit-packs=${pic_info}
    &{payload}       create dictionary     org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC19
    [Documentation]  verify the administrative-state can be retrieved and configured
    ...              TC 5.3-3  RLI-38968	
    [Tags]           Sanity   TC19   Set-CP-ADMIN-STATUS
    Log              Configure administrative-state via Restconf Patch method, here we take PIC0 for example.
    ${administrative_state}     evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    &{pickey}        create dictionary      circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}       administrative-state-cp=${administrative_state}
    @{pic_info}      create list            ${pickey}
    &{dev_info}      create dictionary      circuit-packs=${pic_info}
    &{payload}       create dictionary      org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC20
    [Documentation]  verify the equipment-state of circuit-pack can be retrieved and configured
    ...              TC 5.3-16  RLI-38968
    [Tags]           Sanity  TC20  Set-CP-Equip-STATUS
    Log              Configure equipment-state via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}    equipment-state-cp=reserved-for-facility-available
    @{pic_info}      create list          ${pickey}
    &{dev_info}      create dictionary    circuit-packs=${pic_info}
    &{payload}       create dictionary    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC21
    [Documentation]  verify the circuit-pack-mode can be retrieved and configured
    ...              TC 5.3-17  RLI-38968
    [Tags]           Sanity  TC21   Set-CP-Mode
    Log              Configure circuit-pack-mode via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     circuit-pack-mode=NORMAL
    @{pic_info}      create list          ${pickey}
    &{dev_info}      create dictionary    circuit-packs=${pic_info}
    &{payload}       create dictionary    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}

TC22
    [Documentation]  verify the subSlot of circuit-pack can be retrieved and configured
    ...              TC 5.3-20  RLI-38968
    [Tags]           Sanity  TC22   Set-CP-Subslot
    Log              Configure circuit pack subSlot via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}      subSlot=slot-0/0
    @{pic_info}      create list          ${pickey}
    &{dev_info}      create dictionary    circuit-packs=${pic_info}
    &{payload}       create dictionary    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
		

TC24
    [Documentation]  verify due-date of circuit-pack can be retrieved and configured 
    ...              TC 5.3-22  RLI-38968
    [Tags]           Sanity  TC24   Set-CP-DueDate
    Log              Configure circuit pack due-date via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary     circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     due-date-cp=${tv['uv-valid_due_date']}
    @{pic_info}      create list           ${pickey}
    &{dev_info}      create dictionary     circuit-packs=${pic_info}
    &{payload}       create dictionary     org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}

TC25
    [Documentation]  verify the slot-name of cp-slot can be retrieved
    ...              TC 5.3-27  RLI-38968	
    [Tags]           Sanity  TC25   Set-CP-Slot-Name
    Log              Configure circuit pack cp-slot-name via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}      cp-slot-name=slot-0/0
    @{pic_info}      create list          ${pickey}
    &{dev_info}      create dictionary    circuit-packs=${pic_info}
    &{payload}       create dictionary    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}

TC26
    [Documentation]  verify parent circuit pack name can be retrieved and configured
    ...              TC 5.3-23  RLI-38968
    [Tags]           Sanity  TC26   Set-Parent-cp-name
    Log              Configure circuit pack cp-slot-name via Restconf Patch method, here we take PIC0 for example.
    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}    circuit-pack-name-parent=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}
    @{pic_info}      create list          ${pickey}
    &{dev_info}      create dictionary    circuit-packs=${pic_info}
    &{payload}       create dictionary    org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}



#TC27
#    [Documentation]  This test case mapping to 5.7-8 in JTMS for RLI-38968
#    [Tags]           Sanity  TC27   Set-Invalid-Pluggable-optics-for-un-xcvr-circuit-pack      limitation
#    Log              Configure circuit pack with invalid is-pluggable-optics value via Restconf Patch method, here we take pic0 for example.
#    &{xcvrkey}       create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}   circuit-pack-type=${ATTELLA_DEF_PIC0_MODEL.text}      shelf=shelf-0       slot=slot-0   is-pluggable-optics=true
#    @{xcvr_info}     create list          ${xcvrkey}
#    &{dev_info}      create dictionary    circuit-packs=${xcvr_info}
#    &{payload}       create dictionary    org-openroadm-device=${dev_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
#    check status line  ${patch_resp}  400
#
#
#
#TC28
#    [Documentation]  This test case mapping to 5.7-8 in JTMS for RLI-38968
#    [Tags]           Sanity  TC28   Set-Invalid-Pluggable-optics-value     limitation
#    Log              Configure circuit pack with invalid is-pluggable-optics value via Restconf Patch method, here we take pic0 for example.
#    &{ctransc}         create dictionary       port-name-p=port-0/0/${QSFP28_INDEX}      port-type=qsfp28-port                port-qual=xpdr-client            circuit-id=Client-QSFP28     administrative-state=inService    logical-connection-point=foo
#    @{ctransclist}     create list             ${ctransc}
#    &{ctransckey}      create dictionary       circuit-pack-name-self=xcvr-0/0/${QSFP28_INDEX}    circuit-pack-type=${tv['uv-attella_def_circuit_pack_type_qsfp28']}     shelf=shelf-0    slot=slot-0
#    ...                administrative-state-cp=inService      equipment-state-cp=reserved-for-facility-available                   circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_qsfp28_product_code']}
#    ...                circuit-pack-mode=NORMAL              subSlot=slot-0/0/${QSFP28_INDEX}     is-pluggable-optics=false    due-date-cp=${tv['uv-valid_due_date']}
#    @{ctransc_info}    create list             ${ctransckey}
#    &{dev_info}        create dictionary       circuit-packs=${ctransc_info}
#    &{payload}         create dictionary       org-openroadm-device=${dev_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
#    check status line  ${patch_resp}  400
#
#
#
#TC29
#    [Documentation]  This test case mapping to 5.3-26 in JTMS for RLI-38968
#    [Tags]           Sanity   TC29    Set-Invalid-Admin-Status    limitation
#    Log              Configure invaild value for circuit pack administrative-state
#    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}    administrative-state-cp=${tv['uv-invalid_administrative_state_circuit_pack']}
#    @{pic_info}      create list          ${pickey}
#    &{dev_info}      create dictionary    circuit-packs=${pic_info}
#    &{payload}       create dictionary    org-openroadm-device=${dev_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
#    check status line  ${patch_resp}  400
#
#
#TC30
#    [Documentation]  This test case mapping to 5.3-27 in JTMS for RLI-38968
#    ...              expect value :  pattern '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?' + '(Z|[\+\-]\d{2}:\d{2})'
#    [Tags]           Sanity    TC30    Set-Invalid-Due-Date   limitation
#    Log              Configure invaild value for circuit pack due-date
#    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     due-date-cp=${tv['uv-invalid_due_date']}
#    @{pic_info}      create list          ${pickey}
#    &{dev_info}      create dictionary    circuit-packs=${pic_info}
#    &{payload}       create dictionary    org-openroadm-device=${dev_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
#    check status line  ${patch_resp}  400
#
#
#TC31
#    [Documentation]  This test case mapping to 5.3-28 in JTMS for RLI-38968
#    [Tags]           Sanity  TC31   Set-Invalid-Equip-State   limitation
#    Log              Configure invaild value for circuit pack equipment-state
#    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     equipment-state-cp=${tv['uv-invalid_equipment_state_circuit_pack']}
#    @{pic_info}      create list          ${pickey}
#    &{dev_info}      create dictionary    circuit-packs=${pic_info}
#    &{payload}       create dictionary    org-openroadm-device=${dev_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
#    check status line  ${patch_resp}  400
#
#TC32
#    [Documentation]  This test case mapping to 5.3-29 in JTMS for RLI-38968
#    ...    The the value that not equal to "NORMAL"   is invalude .
#    [Tags]           Sanity  TC32   Set-Invalid-CP-Mode   limitation
#    Log              Configure invaild value for circuit pack circuit-pack-mode
#    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     circuit-pack-mode=REGEN
#    @{pic_info}      create list          ${pickey}
#    &{dev_info}      create dictionary    circuit-packs=${pic_info}
#    &{payload}       create dictionary    org-openroadm-device=${dev_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
#    check status line  ${patch_resp}  400
#
#
#TC33
#    [Documentation]  This test case mapping to 5.7-37 in JTMS for RLI-38968
#    ...    Mandatory string: Type of circuit-pack such as FPC, FTU, PSU, PIC, XCVR.
#    [Tags]           Sanity  TC33   Set-Invalid-CP-Type   limitation
#    Log              Configure invaild value for circuit pack circuit-pack-type
#    &{pickey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}     circuit-pack-type=KKK
#    @{pic_info}      create list          ${pickey}
#    &{dev_info}      create dictionary    circuit-packs=${pic_info}
#    &{payload}       create dictionary    org-openroadm-device=${dev_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
#    check status line  ${patch_resp}  400
#
#
#TC34
#    [Documentation]  This test case mapping to 5.6-29 in JTMS for RLI-38968
#    ...    String: User must set to a vendor defined value . Valid values are “QSFP28” and “CFP2DCO”
#    [Tags]           Sanity  TC34  Set-Invalid-CP-PortType   limitation
#    Log              Configure invaild value for circuit pack port-type
#    &{ports}         create dictionary    port-name=port-0/0/6  port-direction=bidirectional   port-wavelength-type=wavelength   label-ports=0/6   port-type=KKK   logical-connection-point=XPDR<2>N-xpdrETWORK<2>
#    @{portlist}      create list          ${ports}
#    &{optics_info}   create dictionary    circuit-pack-name-self=xcvr-0/0/6  vendor-cp=${tv['uv-attella_def_vendor']}
#    ...              software-load-version=${osVersion.text}      ports=${portlist}
#    @{Transc_info}   create list          ${optics_info}
#    &{static_info}   create dictionary    circuit-packs=${Transc_info}
#    &{payload}       create dictionary    org-openroadm-device=${static_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}
#    check status line  ${patch_resp}      400
#
#
#TC35
#    [Documentation]  This test case mapping to 5.6-30 in JTMS for RLI-38968
#    ...     String: The controller sets this value to the following format:
#    ...     Line:
#    ...     XPDR<n>-NETWORK<m>
#    ...     Client:
#    ...     XPDR<n>N-xpdrETWORK<m>
#    ...     Where:
#    ...     n is set to xpdr-number, key into xponder list
#    ...     m is the max number of client muxponder ports. For a transponder m is always 1.
#    [Tags]           Sanity   TC35   Set-Invalid-LCPoint-QSFP   limitation
#    Log              Configure invaild value for circuit pack port-type
#    &{ports}         create dictionary    port-name=port-0/0/6  port-direction=bidirectional   port-wavelength-type=wavelength   label-ports=0/6    logical-connection-point=XPDR<2>N-xpdrETWORK<2>
#    @{portlist}      create list          ${ports}
#    &{optics_info}   create dictionary    circuit-pack-name-self=xcvr-0/0/6                      vendor-cp=${tv['uv-attella_def_vendor']}
#    ...              software-load-version=${osVersion.text}    ports=${portlist}
#    @{Transc_info}   create list          ${optics_info}
#    &{static_info}   create dictionary    circuit-packs=${Transc_info}
#    &{payload}       create dictionary    org-openroadm-device=${static_info}
#    ${patch_resp}    Send Merge Request   ${odl_sessions}       ${tv['device0__re0__mgt-ip']}    ${payload}
#    check status line   ${patch_resp}        400
#
#TC36
#    [Documentation]  This test case mapping to 5.6-31 in JTMS for RLI-38968
#    ...     String: The controller sets this value to the following format:
#    ...     Line:
#    ...     XPDR<n>-NETWORK<m>
#    ...     Client:
#    ...     XPDR<n>N-xpdrETWORK<m>
#    ...     Where:
#    ...     n is set to xpdr-number, key into xponder list
#    ...     m is the max number of client muxponder ports. For a transponder m is always 1.
#    [Tags]              Sanity  TC36   Set-Invalid-CFP2DCO-LCP   limitation
#    Log                 Configure invaild value for circuit pack port-type
#    &{ports}            create dictionary    port-name=port-0/1/3     port-direction=bidirectional   port-wavelength-type=wavelength   label-ports=0/6    logical-connection-point=XPDR<2>N-xpdrETWORK<2>
#    @{portlist}         create list          ${ports}
#    &{optics_info}      create dictionary    circuit-pack-name-self=xcvr-0/1/3                       vendor-cp=${tv['uv-attella_def_vendor']}
#    ...                 software-load-version=${osVersion.text}       ports=${portlist}
#    @{Transc_info}      create list          ${optics_info}
#    &{static_info}      create dictionary    circuit-packs=${Transc_info}
#    &{payload}          create dictionary    org-openroadm-device=${static_info}
#    ${patch_resp}       Send Merge Request   ${odl_sessions}          ${tv['device0__re0__mgt-ip']}    ${payload}
#    check status line   ${patch_resp}        400


TC37
    [Documentation]  De-provison fpc-0 
    ...              TC 5.1-2  RLI-38968
    [Tags]           Sanity   TC37   Delete-CP-FPC0
    Log              Delete circuit-pack fpc-0 via Restconf patch method
    &{fpc_name}           create dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}
    @{fpc}                create list           ${fpc_name}
    &{dev_fpc}            create dictionary     circuit-packs=${fpc}
    &{netconfParams}      create dictionary     org-openroadm-device=${dev_fpc}
    Send Delete Request And Verify Status Of Response Is OK     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}     ${netconfParams}


#TC38
#    [Documentation]  This test case mapping to 5.4-22 in JTMS for RLI-38968
#    [Tags]           Sanity  TC38   Delete-CP-PSM0
#    Log              Delete circuit-pack PSM-0 via Restconf patch method
#    &{psm0}              create dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}
#    @{fpc}               create list           ${psm0}
#    &{dev_fpc}           create dictionary     circuit-packs=${fpc}
#    &{netconfParams}     create dictionary     org-openroadm-device=${dev_fpc}
#    Send Delete Request And Verify Status Of Response Is OK     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${netconfParams}

TC38
    [Documentation]  de-provison Power Supply Units
    ...              TC 5.1-21 RLI-38963
    [Tags]           Sanity  TC38   Delete-CP-PSM0
    Log              Delete circuit-pack PSM-0 via Restconf patch method
    &{psm0}              create dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}
    @{fpc}               create list           ${psm0}
    &{dev_fpc}           create dictionary     circuit-packs=${fpc}
    &{netconfParams}     create dictionary     org-openroadm-device=${dev_fpc}	
    ${patch_resp}         Send Delete Request      ${odl_sessions}                   ${tv['device0__re0__mgt-ip']}    ${netconfParams} 
    check status line  ${patch_resp}  200 	

 
	

TC39
    [Documentation]  De-provison Fan Tray Units
    ...              TC 5.1-9  RLI-38968
    [Tags]           Sanity  TC39   Delete-CP-FAN0
    Log              Delete circuit-pack FAN-0 via Restconf patch method
    &{fan0}              create dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot3_provisioned_circuit_pack']}
    @{fpc}               create list           ${fan0}
    &{dev_fpc}           create dictionary     circuit-packs=${fpc}
    &{netconfParams}     create dictionary     org-openroadm-device=${dev_fpc}
    Send Delete Request And Verify Status Of Response Is OK     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${netconfParams}


TC40
    [Documentation]  De-provison pic-0/0
    ...              TC 5.1-4  RLI-38968
    [Tags]           Sanity  TC40   Delete-CP-PIC0
    Log              Delete circuit-pack PIC-0 via Restconf patch method
    &{pic0}              create dictionary     circuit-pack-name-self=${tv['uv-attella_def_pic0_name']}
    @{fpc}               create list           ${pic0}
    &{dev_fpc}           create dictionary     circuit-packs=${fpc}
    &{netconfParams}     create dictionary     org-openroadm-device=${dev_fpc}
    Send Delete Request And Verify Status Of Response Is OK     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${netconfParams}


TC41
    [Documentation]  De-provison QSFP28 transceivers
    ...              TC 5.1-11  RLI-38968
    [Tags]           Sanity  TC41   Delete-CP-QSFP28
    Log                   Delete circuit-pack QSFP28-6 via Restconf patch method
    &{qsfp28_6}           create dictionary     circuit-pack-name-self=xcvr-${tv['uv-attella_client_transc_installed_prov']}
    @{fpc}                create list           ${qsfp28_6}
    &{dev_fpc}            create dictionary     circuit-packs=${fpc}
    &{netconfParams}      create dictionary     org-openroadm-device=${dev_fpc}
    Send Delete Request And Verify Status Of Response Is OK     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${netconfParams}

TC42
    [Documentation]  De-provison CFP2-DCO transceivers
    ...              TC 5.1-13 RLI-38963
    [Tags]           Sanity   TC42   Delete-CP-CFP2DCO
    Log              Delete circuit-pack CFP2DCO-3 via Restconf patch method
    &{cfp2dco_3}           create dictionary     circuit-pack-name-self=xcvr-${tv['uv-attella_line_transc_installed_prov']}
    @{fpc}                 create list           ${cfp2dco_3}
    &{dev_fpc}             create dictionary     circuit-packs=${fpc}
    &{netconfParams}       create dictionary     org-openroadm-device=${dev_fpc}
    Send Delete Request And Verify Status Of Response Is OK     ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${netconfParams}


TC43
    [Documentation]  Failed to delete FPC-0/0 twice
    ...              TC 5.1-22 RLI-38963	
    [Tags]           Sanity   TC43  Delete-CP-FPC0-Twice
    Log              Delete circuit-pack fpc-0 twice via Restconf patch method
    ${administrative_state_for_fpc}        evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    &{fpckey}        create dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}   circuit-pack-type=FPC  shelf=shelf-0
    ...              slot=slot-0  subSlot=slot-0
    ...              administrative-state-cp=${administrative_state_for_fpc}     equipment-state-cp=reserved-for-facility-available    circuit-pack-mode=NORMAL
    ...                due-date-cp=${tv['uv-valid_due_date']}     circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    @{fpc_info}      create list    ${fpckey}
    &{dev_info}      create dictionary   circuit-packs=${fpc_info}
    &{payload}       create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}     ${payload}
    &{fpc}           create dictionary   circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}
    @{fpc_name}      create list   ${fpc}
    &{dev_fpc}       create dictionary   circuit-packs=${fpc_name}
    &{netconfParams}   create dictionary   org-openroadm-device=${dev_fpc}
    ${patch_resp}  Send Delete Request  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${netconfParams}
    check status line  ${patch_resp}  200
    ${patch_resp}  Send Delete Request  ${odl_sessions}      ${tv['device0__re0__mgt-ip']}     ${netconfParams}
    check status line  ${patch_resp}  404


TC44
    [Documentation]  Delete a circuit-packs twice
    ...              TC 5.1-23 RLI-38963
    [Tags]           Sanity  TC44  Delete-Non-exist-CP
    Log              Delete a non-exist circuit-pack fpc-0will return 404 error
    ${administrative_state_for_fpc}       evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    &{fpckey}        create dictionary    circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}   circuit-pack-type=FPC  shelf=shelf-0
    ...              slot=slot-0  subSlot=slot-0
    ...              administrative-state-cp=${administrative_state_for_fpc}     equipment-state-cp=reserved-for-facility-available    circuit-pack-mode=NORMAL
    ...                 due-date-cp=${tv['uv-valid_due_date']}     circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    @{fpc_info}    create list    ${fpckey}
    &{dev_info}      create dictionary   circuit-packs=${fpc_info}
    &{payload}       create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
    &{fpc}           create dictionary     circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}
    @{fpc_name}    create list   ${fpc}
    &{dev_fpc}       create dictionary     circuit-packs=${fpc_name}
    &{netconfParams}   create dictionary   org-openroadm-device=${dev_fpc}
    ${patch_resp}  Send Delete Request  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${netconfParams}
    check status line  ${patch_resp}  200
    ${resp}=       Get Request  @{odl_sessions}[${OPR_SESSEION_INDEX}]
    ...            /node/${tv['device0__re0__mgt-ip']}/yang-ext:mount/org-openroadm-device:org-openroadm-device/circuit-packs/${tv['uv-attella_def_slot0_provisioned_circuit_pack']}    headers=${get_headers}    allow_redirects=False
    check status line    ${resp}     404

    
*** Keywords ***
Testbed Init
    Set Log Level  DEBUG

    Log To Console      Loading Baseline configurations
    ${device0} =     Get Handle      resource=device0
    
    ${Version} =  Execute cli command on device    device=${device0}    command=show version   format=xml
    ${osVersion}=  Get Element   ${version}   software-information/junos-version
    Log  The OS version is ${osVersion.text}
    Set Global Variable  ${osVersion.text}

    ${Hardware} =  Execute cli command on device    device=${device0}    command=show chassis hardware   format=xml
    ${ATTELLA_DEF_PSM0_MODEL}              Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[1]/model-number
    Log To Console  ${ATTELLA_DEF_PSM0_MODEL.text}
    ${ATTELLA_DEF_PSM1_MODEL}              Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[2]/model-number
    Log  The vaule for PSM1 model is ${ATTELLA_DEF_PSM0_MODEL.text} 
    ${ATTELLA_DEF_PSM0_PRODUCT_CODE}       Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[1]/part-number
    ${ATTELLA_DEF_PSM1_PRODUCT_CODE}       Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[2]/part-number
    ${ATTELLA_DEF_PSM0_SERIAL_ID}          Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[1]/serial-number
    ${ATTELLA_DEF_PSM1_SERIAL_ID}          Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[2]/serial-number    
    ${ATTELLA_DEF_PSM0_CLEI}               Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[1]/clei-code
    ${ATTELLA_DEF_PSM1_CLEI}               Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[2]/clei-code        
    ${ATTELLA_DEF_PSM0_HAREWARE_VERSION}   Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[1]/version
    ${ATTELLA_DEF_PSM1_HAREWARE_VERSION}   Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[2]/version
    ${ATTELLA_DEF_FPC_PRODUCT_CODE}        Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[3]/part-number
    ${ATTELLA_DEF_FPC_SERIAL_ID}           Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[3]/serial-number
	
    ${ATTELLA_DEF_FPC_MODEL}            Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[3]/description
	
	
	
    ${ATTELLA_DEF_FPC_CLEI}                Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[3]/clei-code        
    ${ATTELLA_DEF_FAN_MODEL}               Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[5]/model-number
	${ATTELLA_DEF_PIC0_MODEL}              Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[4]/chassis-sub-module[1]/description
	${ATTELLA_DEF_PIC1_MODEL}              Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[4]/chassis-sub-module[2]/description
    ${ATTELLA_DEF_PIC0_QSFP28_INDEX_OR}    Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[4]/chassis-sub-module[1]/chassis-sub-sub-module[1]/name
    ${ATTELLA_DEF_PIC0_QSFP28_SN}          Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[4]/chassis-sub-module[1]/chassis-sub-sub-module[1]/serial-number
    ${ATTELLA_DEF_PIC1_CFP_INDEX_OR}       Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[4]/chassis-sub-module[2]/chassis-sub-sub-module[1]/name
    ${ATTELLA_DEF_PIC1_CFP_SN}             Get Element   ${Hardware}   chassis-inventory/chassis/chassis-module[4]/chassis-sub-module[2]/chassis-sub-sub-module[1]/serial-number
        
    Log To Console  ${ATTELLA_DEF_PSM0_MODEL.text}
    Log To Console  ${ATTELLA_DEF_PSM1_MODEL.text}
    Log To Console  ${ATTELLA_DEF_PSM0_PRODUCT_CODE.text}
    Log To Console  ${ATTELLA_DEF_PSM1_PRODUCT_CODE.text}
    Log To Console  ${ATTELLA_DEF_PSM0_SERIAL_ID.text}
    Log To Console  ${ATTELLA_DEF_PSM1_SERIAL_ID.text}
    Log To Console  ${ATTELLA_DEF_PSM0_CLEI.text}
    Log To Console  ${ATTELLA_DEF_PSM1_CLEI.text}
    Log To Console  ${ATTELLA_DEF_PSM0_HAREWARE_VERSION.text}
    Log To Console  ${ATTELLA_DEF_PSM1_HAREWARE_VERSION.text}   
    Log To Console  ${ATTELLA_DEF_FPC_PRODUCT_CODE.text}
    Log To Console  ${ATTELLA_DEF_FPC_SERIAL_ID.text}
    Log To Console  ${ATTELLA_DEF_FPC_CLEI.text}
	Log To Console  ${ATTELLA_DEF_FPC_MODEL.text}
    Log To Console  ${ATTELLA_DEF_FAN_MODEL.text}   
    Log To Console  ${ATTELLA_DEF_PIC0_MODEL.text}
    Log To Console  ${ATTELLA_DEF_PIC1_MODEL.text}


    Log To Console  ${ATTELLA_DEF_PIC0_QSFP28_INDEX_OR.text}
    Log To Console  ${ATTELLA_DEF_PIC0_QSFP28_SN.text}
    Log To Console  ${ATTELLA_DEF_PIC1_CFP_INDEX_OR.text}
    Log To Console  ${ATTELLA_DEF_PIC1_CFP_SN.text}

    ${QSFP28_INDEX}     evaluate    re.findall(".*?\\s(\\d+)", "${ATTELLA_DEF_PIC0_QSFP28_INDEX_OR.text}", re.S)[0]    re
    ${CFP2_INDEX}       evaluate    re.findall(".*?\\s(\\d+)", "${ATTELLA_DEF_PIC1_CFP_INDEX_OR.text}", re.S)[0]     re

    ${QSFP28_SN}        evaluate    re.findall("(.*?)\\s+", "${ATTELLA_DEF_PIC0_QSFP28_SN.text}", re.S)[0]    re
    ${CFP2DCO_SN}       evaluate    re.findall("(.*?)\\s+", "${ATTELLA_DEF_PIC1_CFP_SN.text}", re.S)[0]    re

    Log To Console             ${QSFP28_INDEX}
    Log To Console             ${CFP2_INDEX}
    Log To Console             ${QSFP28_SN}
    Log To Console             ${CFP2DCO_SN}

    Set Suite Variable  ${ATTELLA_DEF_PSM0_MODEL.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM1_MODEL.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM0_PRODUCT_CODE.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM1_PRODUCT_CODE.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM0_SERIAL_ID.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM1_SERIAL_ID.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM0_CLEI.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM1_CLEI.text}       
    Set Suite Variable  ${ATTELLA_DEF_PSM0_HAREWARE_VERSION.text}
    Set Suite Variable  ${ATTELLA_DEF_PSM1_HAREWARE_VERSION.text}       
    Set Suite Variable  ${ATTELLA_DEF_FPC_PRODUCT_CODE.text}
    Set Suite Variable  ${ATTELLA_DEF_FPC_SERIAL_ID.text}
    Set Suite Variable  ${ATTELLA_DEF_FPC_CLEI.text}
	Set Suite Variable  ${ATTELLA_DEF_FPC_MODEL.text}
    Set Suite Variable  ${ATTELLA_DEF_FAN_MODEL.text}   
    Set Suite Variable  ${ATTELLA_DEF_PIC0_MODEL.text}
    Set Suite Variable  ${ATTELLA_DEF_PIC1_MODEL.text}

    Set Suite Variable  ${QSFP28_INDEX}
    Set Suite Variable  ${QSFP28_SN}
    Set Suite Variable  ${CFP2_INDEX}
    Set Suite Variable  ${CFP2DCO_SN}

    Log To Console      pre-cli commands on Attella testbed
    
    @{dut_list}    create list    device0 
    Preconfiguration netconf feature    @{dut_list}


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
    Mount vAttella On ODL Controller    ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    sleep   15s  
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}






    
