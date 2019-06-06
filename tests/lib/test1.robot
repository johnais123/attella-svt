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
Library         attella_keyword.py


*** Variables ***

${XmlFile}    ./resources/test.xml

${INDEXS}   0

${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}  xcvr-0/0/
${ATTELLA_DEF_LINE_TRANSC_NAME_PREFIX}  xcvr-0/1/

${ATTELLA_DEF_PORT_CLIENT_PREFIX}  port-0/0/
${ATTELLA_DEF_PORT_LINE_PREFIX}  port-0/1/

${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}  ett-0/0/
${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}  och-0/1/
${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  otu-0/1/
${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}  odu-0/1/


${ATTELLA_DEF_CLIENT_PORT_TYPE}  ethernetCsmacd
${ATTELLA_DEF_OCH_PORT_TYPE}  opticalChannel
${ATTELLA_DEF_OTU_PORT_TYPE}  otnOtu
${ATTELLA_DEF_ODU_PORT_TYPE}  otnOdu

${ATTELLA_INTERFACE_ADMINSTRATION_STATE}  inService
${ATTELLA_INTERFACE_ADMINSTRATION_STATE2}  outOfService
${ATTELLA_INTERFACE_ADMINSTRATION_STATE3}  maintenance


*** Test Cases ***

Test Parser
    [Documentation]  Checking Parser
     ${root} =   Parse XML    ${XmlFile}

     Should Be Equal  ${root.tag}  org-openroadm-device 


Test verify data
    [Documentation]  Checking Verify Data
    ${root} =   Parse XML    ${XmlFile}
    # &{dev_info}   create dictionary   vendor-info=${tv['uv-attella_def_info_vendor']}   model-info=${tv['uv-attella_def_info_model']} 
    # ...   serial-id-info=${serNu_info}  source=static   current-ipAddress=${tv['device0__re0__mgt-ip']}   
    # ...   current-prefix-length=${tv['uv-attella_def_info_current_prefix_length']}
    # ...   current-defaultGateway=${tv['uv-attella_def_info_current_defaultgateway']}   openroadm-version=${tv['uv-attella_def_info_openroadm_version']}
    # ...   softwareVersion=${version_info}     max-srgs=0   max-degrees=0  max-num-bin-15min-historical-pm=96
    # ...   max-num-bin-24hour-historical-pm=1
    #  ...   macAddress=${macadd_info}
    # &{netconfParams}   create dictionary   org-openroadm-device=${dev_info}

    # &{psm0_info}     create dictionary      circuit-pack-name-self=${tv['uv-attella_def_slot1_provisioned_circuit_pack']}  vendor-cp=${tv['uv-attella_def_vendor']}   model-cp=${ATTELLA_DEF_PSM0_MODEL.text}
    # ...              hardware-version-cp=${ATTELLA_DEF_PSM0_HAREWARE_VERSION.text}       type-cp=PSM  type-cp-category=powerSupply  clei-cp=${ATTELLA_DEF_PSM0_CLEI.text}   product-code-cp=${ATTELLA_DEF_PSM0_PRODUCT_CODE.text}
    # ...              software-load-version=${osVersion.text}
    # &{psm1_info}     create dictionary      circuit-pack-name-self=${tv['uv-attella_def_slot2_provisioned_circuit_pack']}  vendor-cp=${tv['uv-attella_def_vendor']}   model-cp=${ATTELLA_DEF_PSM1_MODEL.text}
    # ...              hardware-version-cp=${ATTELLA_DEF_PSM1_HAREWARE_VERSION.text}       type-cp=PSM  type-cp-category=powerSupply  clei-cp=${ATTELLA_DEF_PSM1_CLEI.text}   product-code-cp=${ATTELLA_DEF_PSM1_PRODUCT_CODE.text}
    # ...              software-load-version=${osVersion.text}
    # @{psm_info}      create list            ${psm0_info}   ${psm1_info}
    # &{static_info}   create dictionary      circuit-packs=${psm_info}
    # &{payload}       create dictionary      org-openroadm-device=${static_info}
    
    &{test_info}   create dictionary   softwareVersion=19.2F16-EVO    max-srgs=0   max-degrees=0  max-num-bin-15min-historical-pm=96
    ...   max-num-bin-24hour-historical-pm=1
    ${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/ 
    
    #${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))   random,string
    &{client_otu_interface}    create_dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}:0:0    description=client-otu-traffic_provision    interface-type=otnOtu
    ...    interface-administrative-state=inService   otu-rate=OTU4  otu-tx-sapi=tx-sapi-val  otu-tx-dapi=tx-dapi-val  
    ...    otu-expected-sapi=tx-sapi-val  otu-expected-dapi=tx-dapi-val  otu-tim-detect-mode=SAPI-and-DAPI
    ...    otu-fec=rsfec
    ...    supporting-interface=none    supporting-circuit-pack-name=${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}${INDEXS}     
    ...    interface-circuit-id=1234   supporting-port=${ATTELLA_DEF_PORT_CLIENT_PREFIX}${INDEXS}
    @{interface_info}    create list    ${client_otu_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}


    &{TestParams}   create dictionary   org-openroadm-device=${test_info}
    ${result}=  verify_data    ${root}    ${payload}
    run keyword if   "${result}" != "True"  FAIL
