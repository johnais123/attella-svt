*** Settings ***
Documentation    This is Attella Robustness Scripts
...              If you are reading this then you need to learn Toby
...              Description  : General Robustness test cases which require restarts
...              Author: John McCann
...              Date   : 06/24/2019
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/38963
...              jtms description           : Attella
...              RLI                        : RLI38963
...              MIN SUPPORT VERSION        : 19.2
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
Library         String
Library         ExtendedRequestsLibrary
Library         XML    use_lxml=True
Library         DateTime
Resource        ../lib/restconf_oper.robot
Resource        ../lib/testSet.robot
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
TC0
    [Documentation]  Perform warm reload
    ...              RLI38963 
    [Tags]           tc0
    Log To Console  Warm Reload Device
    Rpc Command For Warm Reload Device  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${timeout}  ${interval}  device0


TC1
    [Documentation]  Check chassis initialised after reboot
    ...              RLI38963  5.2-1
    [Tags]           tc1
    Log              get shelf administrative-state via Restconf
    #${administrative_state_for_shelf}     evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    &{shelf}   create_dictionary   shelf-name=${tv['uv-shelf_name']}   administrative-state-shelves=inService
    @{shelves}    create list   ${shelf}
    &{dev_shelves}   create_dictionary   shelves=${shelves}
    &{payload}   create_dictionary   org-openroadm-device=${dev_shelves}
    Send Get Request And Verify Output Is Correct  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}   


TC2
    [Documentation]  Check PSU's initialsed after reboot
    ...              RLI38963  5.2-2
    [Tags]           TC2
    Log              get PSU administrative state via Restconf
    &{psm0_info}     create dictionary      circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  vendor-cp=${tv['uv-attella_def_vendor']}   model-cp=${ATTELLA_DEF_PSM0_MODEL.text}
    ...              hardware-version-cp=${ATTELLA_DEF_PSM0_HAREWARE_VERSION.text}       type-cp=PSM  type-cp-category=powerSupply  clei-cp=${ATTELLA_DEF_PSM0_CLEI.text}   product-code-cp=${ATTELLA_DEF_PSM0_PRODUCT_CODE.text}
    ...              administrative-state-cp=inService    software-load-version=${osVersion.text}    
    &{psm1_info}     create dictionary      circuit-pack-name-self=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  vendor-cp=${tv['uv-attella_def_vendor']}   model-cp=${ATTELLA_DEF_PSM1_MODEL.text}
    ...              hardware-version-cp=${ATTELLA_DEF_PSM1_HAREWARE_VERSION.text}       type-cp=PSM  type-cp-category=powerSupply  clei-cp=${ATTELLA_DEF_PSM1_CLEI.text}   product-code-cp=${ATTELLA_DEF_PSM1_PRODUCT_CODE.text}
    ...              administrative-state-cp=inService     software-load-version=${osVersion.text}    
    @{psm_info}      create list            ${psm0_info}   ${psm1_info}
    &{static_info}   create dictionary      circuit-packs=${psm_info}
    &{payload}       create dictionary      org-openroadm-device=${static_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}


TC3
    [Documentation]  Check Fan's initialised after reboot
    ...              RLI38963  5.2-3
    [Tags]           TC3
    Log              get FAN administrative state for circuit-pack FAN via Restconf
    : FOR            ${INDEX}         IN RANGE    0    5
    #\                &{Fan0_info}     create dictionary       circuit-pack-name-self=fan-${INDEX}  vendor-cp=${tv['uv-attella_def_vendor']}                   model-cp=${ATTELLA_DEF_FAN_MODEL.text}
    \                &{Fan0_info}     create dictionary       circuit-pack-name-self=fan-${INDEX}  vendor-cp=${tv['uv-attella_def_vendor']}    model-cp=${tv['uv-attella_def_fan_model']}
    \                ...   type-cp=FTU  type-cp-category=fan     product-code-cp=${tv['uv-attella_def_fan_product_code']}    administrative-state-cp=inService
    \                ...   software-load-version=${osVersion.text}
    \                @{Fan_info}      create list    ${Fan0_info}
    \                &{static_info}   create dictionary       circuit-packs=${Fan_info}
    \                &{payload}       create dictionary       org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}


TC4
    [Documentation]  Check QSFP28 initialised after reboot
    ...              RLI38963  5.2-4
    [Tags]           tc4
    Log              get administrative state for circuit-pack QSFP28 via Restconf
    :FOR             ${INDEX}    IN RANGE    0    7    2
    \                &{ont-capability-100GE}    create dictionary     if-cap-type-ports=${tv['uv-attella_def_circuit_pack_if_cap_type_ge']}             proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                &{ont-capability-OUT4}     create dictionary     if-cap-type-ports=${tv['uv-attella_def_circuit_pack_if_cap_type_odu4']}           proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                @{client-port}             create list           ${ont-capability-100GE}         ${ont-capability-OUT4}
    \                &{ports}                   create dictionary     port-name-p=port-0/0/${INDEX}   port-direction=bidirectional    port-wavelength-type=wavelength    label-ports=0/${INDEX}      if-cap-type-ports=${client-port}     port-power-capability-min-rx=-22.00      port-power-capability-min-tx=-12.00      port-power-capability-max-rx=0.00     port-power-capability-max-tx=2.00
    \                @{portlist}                create list           ${ports}
    \                &{optics_info}             create dictionary     circuit-pack-name-self=xcvr-0/0/${INDEX}    vendor-cp=${tv['uv-attella_def_vendor']}        administrative-state-cp=inService
    \                ...                        software-load-version=${osVersion.text}               ports=${portlist}
    \                @{Transc_info}             create list           ${optics_info}
    \                &{static_info}             create dictionary     circuit-packs=${Transc_info}
    \                &{payload}                 create dictionary     org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


TC5
    [Documentation]  Check CFP2-DCO initialised after reboot
    ...              RLI38963  5.2-5
    [Tags]           tc5
    Log              get administrative state for circuit-pack CFP2DCO via Restconf
    : FOR            ${INDEX}    IN RANGE    0    4
    \                &{ont-capability-Line0}    create dictionary     if-cap-type-cp=${tv['uv-attella_def_circuit_pack_line_if_cap_type']}             proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                &{ont-capability-Line1}    create dictionary     if-cap-type-cp=${tv['uv-attella_def_circuit_pack_line_if_cap_type']}             proactive-DMp-ports=${tv['uv-attella_def_circuit_pack_proactive_dmp']}      tcm-capable-ports=${tv['uv-attella_def_circuit_pack_tcm_dmp_capable']}      proactive-DMt-ports=${tv['uv-attella_def_circuit_pack_proactive_dmt']}
    \                @{line-port}               create list           ${ont-capability-Line0}                         ${ont-capability-Line1}
    \                &{ports}                   create dictionary     port-name-p=port-0/1/${INDEX}  port-direction=bidirectional   port-wavelength-type=wavelength   label-ports=1/${INDEX}  port-type=cfp2dco-port    if-cap-type-ports=${line-port}
    \                @{portlist}                create list           ${ports}
    \                &{optics_info}             create dictionary     circuit-pack-name-self=xcvr-0/1/${INDEX}  vendor-cp=${tv['uv-attella_def_vendor']}      administrative-state-cp=inService
    \                ...                        software-load-version=${osVersion.text}    ports=${portlist}
    \                @{Transc_info}             create list           ${optics_info}
    \                &{static_info}             create dictionary     circuit-packs=${Transc_info}
    \                &{payload}                 create dictionary     org-openroadm-device=${static_info}
    \                Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}  ${payload}


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
    @{auth}=  Create List  ${tv['uv-odl-username']}  ${tv['uv-odl-password']}

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

