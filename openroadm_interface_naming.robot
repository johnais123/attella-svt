*** Settings ***
Documentation     This is Attella interface Scripts
...              Description  : RLI-39315: OpenROADM Device Interface Name Management
...              Author : Barryzhang@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/555965
...              jtms description           : Attella
...              RLI                        : 39315
...              MIN SUPPORT VERSION        : 19.1
...              TECHNOLOGY AREA            : PLATFORM
...              MAIN FEATURE               : Transponder support on ACX6160-T
...              SUB-AREA                   : CHASSIS
...              Feature                    : CHASSIS_MGMT
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
Resource        lib/restconf_oper.robot
Resource        lib/attella_keyword.robot



Suite Setup   Run Keywords
...              Toby Suite Setup
...              Testbed Init

Test Setup  Run Keywords
...              Toby Test Setup

Test Teardown  Run Keywords
...              Toby Test Teardown

Suite Teardown  Run Keywords
...              Testbed Teardown
...              Toby Suite Teardown


*** Variables ***
${ATTELLA_DEF_100GE_CLIENT_NAME}    jmc-100ge-client-port
${ATTELLA_DEF_OTU4_CLIENT_NAME}    jmc-otu4-client-port
${ATTELLA_DEF_ODU4_CLIENT_NAME}    jmc-odu4-client-port
${ATTELLA_DEF_LINE_OCH_NAME}    jmc-och-line-port
${ATTELLA_DEF_LINE_OTU_NAME}    jmc-otu-line-port
${ATTELLA_DEF_LINE_ODU_NAME}    jmc-odu-line-port

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

@{auth}    admin    admin
${interval}  120
${timeout}  120



*** Test Cases ***   

## 100ge Client Interface name tests 

TC1
    [Documentation]  Verify can configure 100ge client interface name attribute via openRoadm leaf
    ...           RLI39315  5.1-1  5.3-9
    Log           Configure client interface name / supporting-port via Restconf Patch method
    [Tags]           Sanity
    ${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/
    #: FOR    ${INDEXS}    IN RANGE    0    1
    &{client_otu_interface}    create_dictionary   interface-name=${ATTELLA_DEF_100GE_CLIENT_NAME}    description=client-otu-0    
    ...    interface-type=ethernetCsmacd    interface-administrative-state=inService     speed=100000
    ...    supporting-circuit-pack-name=${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}0
    ...    supporting-port=${ATTELLA_DEF_PORT_CLIENT_PREFIX}0
    @{interface_info}    create list    ${client_otu_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}

TC2
    [Documentation]  Verify delete all 100ge client interface via openRoadm leaf
    ...              RLI39315 5.1-2  5.3-18
    [Tags]          Sanity
    Log         Verify delete 100ge interface name via Restconf Patch method  
    #: FOR    ${INDEXS}    IN RANGE    0    1
    &{OTUinterface}    create dictionary    interface-name=${ATTELLA_DEF_100GE_CLIENT_NAME} 
    @{delinter}    create list    ${OTUinterface}
    &{dev_info}   create dictionary   interface=${delinter}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line  ${patch_resp}  200    


## OTU4 Client interface name tests

TC3
    [Documentation]  Verify can configure otu4 client interface name attribute via openRoadm leaf
    ...           RLI39315  5.1-3
    Log           Configure client interface name / supporting-port via Restconf Patch method
    [Tags]           Sanity
    ${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/
    ${ATTELLA_DEF_CLIENT_OTU_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/
    #: FOR    ${INDEXS}    IN RANGE    0    1
    ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    &{client_otu_interface}    create_dictionary   interface-name=${ATTELLA_DEF_OTU4_CLIENT_NAME}    description=client-otu-0    interface-type=otnOtu
    ...    interface-administrative-state=inService   otu-rate=OTU4  otu-tx-sapi=777770000077777  otu-tx-dapi=888880000088888
    ...    otu-expected-sapi=exp-sapi-val000  otu-expected-dapi=exp-dapi-val111  otu-tim-detect-mode=SAPI-and-DAPI
    ...    otu-fec=rsfec
    ...    supporting-circuit-pack-name=${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}0
    ...    interface-circuit-id=${circuit-id}   supporting-port=${ATTELLA_DEF_PORT_CLIENT_PREFIX}0
    @{interface_info}    create list    ${client_otu_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}

TC4
    [Documentation]  Verify can configure odu4 client interface name attribute via openRoadm leaf
    ...              RLI39315 5.1-5
    Log           Configure client interface name / supporting-port via Restconf Patch method
    [Tags]           Sanity
    ${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}  1/    0/
    ${ATTELLA_DEF_CLIENT_OTU_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/
    #: FOR    ${INDEXS}    IN RANGE    0    1
    ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    &{client_odu_interface}    create_dictionary   interface-name=${ATTELLA_DEF_ODU4_CLIENT_NAME}    description=client-odu-0    interface-type=otnOdu
    ...    interface-administrative-state=inService   odu-rate=ODU4    odu-tx-sapi=777770000077777   odu-tx-dapi=888880000088888
    ...    odu-expected-sapi=exp-sapi-val000   odu-expected-dapi=exp-dapi-val111   odu-tim-detect-mode=SAPI-and-DAPI
    ...    supporting-interface=${ATTELLA_DEF_OTU4_CLIENT_NAME}   supporting-circuit-pack-name=${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}0
    ...    interface-circuit-id=${circuit-id}   supporting-port=${ATTELLA_DEF_PORT_CLIENT_PREFIX}0
    
    @{interface_info}    create list    ${client_odu_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}


TC5
    [Documentation]  Verify delete odu4 client interface via openRoadm leaf
    ...              RLI39315 5.1-6  5.3.17
    [Tags]          Sanity
    Log         Verify delete odu4 interface name via Restconf Patch method
    #: FOR    ${INDEXS}    IN RANGE    0    1
    &{OTUinterface}    create dictionary    interface-name=${ATTELLA_DEF_ODU4_CLIENT_NAME} 
    @{delinter}    create list    ${OTUinterface}
    &{dev_info}   create dictionary   interface=${delinter}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line  ${patch_resp}  200


TC6
    [Documentation]  Verify delete otu4 client interface via openRoadm leaf
    ...              RLI39315 5.1-4  5.3-15
    [Tags]          Sanity
    Log         Verify delete odu4 interface name via Restconf Patch method    
    #: FOR    ${INDEXS}    IN RANGE    0    1
    &{OTUinterface}    create dictionary    interface-name=${ATTELLA_DEF_OTU4_CLIENT_NAME} 
    @{delinter}    create list    ${OTUinterface}
    &{dev_info}   create dictionary   interface=${delinter}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line  ${patch_resp}  200    

## ODU Line side tests

TC7
    [Documentation]  Verify can configure och interface rate via openRoadm leaf
    ...              RLI39315 5.1-7
    [Tags]           Sanity   tc7 
    Log           Configure och interface rate via Restconf Patch method
    &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_LINE_OCH_NAME}    description=line-och    interface-type=opticalChannel
    ...    interface-administrative-state=inService    och-rate=R100G
    ...    supporting-circuit-pack-name=${ATTELLA_DEF_LINE_TRANSC_NAME_PREFIX}0    supporting-port=${ATTELLA_DEF_PORT_LINE_PREFIX}0
    Log To Console     och &{och_interface}
    @{interface_info}    create list    ${Och_interface} 
    &{dev_info}   create dictionary   interface=${interface_info}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 

TC8
    [Documentation]  Verify can configure otu4 line interface name attribute via openRoadm leaf
    ...           RLI39315  5.1-9  5.3-2
    Log           Configure client interface name / supporting-port via Restconf Patch method
    [Tags]           Sanity
    ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    &{line_otu_interface}    create_dictionary   interface-name=${ATTELLA_DEF_LINE_OTU_NAME}    description=line-otu-0    interface-type=otnOtu
    ...    interface-administrative-state=inService   otu-rate=OTU4  otu-tx-sapi=777770000077777  otu-tx-dapi=888880000088888
    ...    otu-expected-sapi=exp-sapi-val000  otu-expected-dapi=exp-dapi-val111  otu-tim-detect-mode=SAPI-and-DAPI
    ...    otu-fec=scfec
    ...    supporting-interface=${ATTELLA_DEF_LINE_OCH_NAME}   supporting-circuit-pack-name=${ATTELLA_DEF_LINE_TRANSC_NAME_PREFIX}0
    ...    interface-circuit-id=${circuit-id}   supporting-port=${ATTELLA_DEF_PORT_LINE_PREFIX}0
    @{interface_info}    create list    ${line_otu_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}


TC9
    [Documentation]  Verify can configure odu4 line interface name attribute via openRoadm leaf
    ...              RLI39315 5.1-11   5.3-4
    Log           Configure line interface name / supporting-port via Restconf Patch method
    [Tags]           Sanity
    ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    &{line_odu_interface}    create_dictionary   interface-name=${ATTELLA_DEF_LINE_ODU_NAME}    description=line-odu-0    interface-type=otnOdu
    ...    interface-administrative-state=inService   odu-rate=ODU4    odu-tx-sapi=777770000077777   odu-tx-dapi=888880000088888
    ...    odu-expected-sapi=exp-sapi-val000   odu-expected-dapi=exp-dapi-val111   odu-tim-detect-mode=SAPI-and-DAPI
    ...    supporting-interface=${ATTELLA_DEF_LINE_OTU_NAME}   supporting-circuit-pack-name=${ATTELLA_DEF_LINE_TRANSC_NAME_PREFIX}0
    ...    interface-circuit-id=${circuit-id}   supporting-port=${ATTELLA_DEF_PORT_LINE_PREFIX}0
    @{interface_info}    create list    ${line_odu_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}
    

TC10
    [Documentation]  Verify delete odu4 line interface via openRoadm leaf
    ...              RLI39315 5.1-12   5.3-16
    [Tags]          Sanity
    Log         Verify delete odu4 interface name via Restconf Patch method
    #: FOR    ${INDEXS}    IN RANGE    0    1
    &{OTUinterface}    create dictionary    interface-name=${ATTELLA_DEF_LINE_ODU_NAME} 
    @{delinter}    create list    ${OTUinterface}
    &{dev_info}   create dictionary   interface=${delinter}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line  ${patch_resp}  200
     

TC11
    [Documentation]  Verify delete otu4 line interface via openRoadm leaf
    ...              RLI39315 5.1-10, 5.3-13
    [Tags]          Sanity
    Log         Verify delete odu4 interface name via Restconf Patch method    
    #: FOR    ${INDEXS}    IN RANGE    0    1
    &{OTUinterface}    create dictionary    interface-name=${ATTELLA_DEF_LINE_OTU_NAME} 
    @{delinter}    create list    ${OTUinterface}
    &{dev_info}   create dictionary   interface=${delinter}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line  ${patch_resp}  200   
    

TC12
    [Documentation]  Verify delete och line interface via openRoadm leaf
    ...              RLI39315 5.1-8, 5.3-11
    [Tags]          Sanity
    Log         Verify delete och interface name via Restconf Patch method
    &{OTUinterface}    create dictionary    interface-name=${ATTELLA_DEF_LINE_OCH_NAME}
    @{delinter}    create list    ${OTUinterface}
    &{dev_info}   create dictionary   interface=${delinter}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line  ${patch_resp}  200   
    


*** Keywords ***
Testbed Init
    Set Log Level  DEBUG
    # Initialize
    Log To Console      create a restconf operational session
    @{dut_list}    create list    device0 
    Preconfiguration netconf feature    @{dut_list}
    
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
    Wait For   15s 
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}


Testbed Teardown
    Log To Console  Clean up Interfaces
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}