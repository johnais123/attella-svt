*** Settings ***
Documentation     This is Attella interface Scripts
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : Barryzhang@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
...              jtms description           : Attella
...              RLI                        : 38968
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
...              Toby Suite Teardown


*** Variables ***

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
TC1
    [Documentation]  Verify can configure all otu4 client interface attribute via openRoadm leaf
    ...              RLI38968 5.4-1
    [Tags]           Sanity   tc1 
    Log           Configure client interface supporting-port via Restconf Patch method
    ${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/ 
    : FOR    ${INDEXS}    IN RANGE    0    8
    \     ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    \     &{client_otu_interface}    create_dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}:0:0    description=client-otu-${INDEXS}    interface-type=otnOtu
    \     ...    interface-administrative-state=inService   otu-rate=OTU4  otu-tx-sapi=777770000077777  otu-tx-dapi=888880000088888  
    \     ...    otu-expected-sapi=exp-sapi-val000  otu-expected-dapi=exp-dapi-val111  otu-tim-detect-mode=SAPI-and-DAPI
    \     ...    otu-fec=rsfec
    \     ...    supporting-interface=none    supporting-circuit-pack-name=${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}${INDEXS}     
    \     ...    interface-circuit-id=${circuit-id}   supporting-port=${ATTELLA_DEF_PORT_CLIENT_PREFIX}${INDEXS}
    \     @{interface_info}    create list    ${client_otu_interface}
    \     &{dev_info}   create_dictionary   interface=${interface_info}       
    \     &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}    

    ${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}  1/    0/   
    ${ATTELLA_DEF_CLIENT_OTU_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/   
    : FOR    ${INDEXS}    IN RANGE    0    8    
    \     ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    \     &{client_interface}    create_dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}:0:0:0    description=client-odu-${INDEXS}    interface-type=otnOdu    
    \     ...    interface-administrative-state=inService    odu-rate=ODU4   odu-tx-sapi=tx-sapi-val   odu-tx-dapi=tx-dapi-val  
    \     ...    odu-expected-sapi=exp-sapi-val   odu-expected-dapi=exp-dapi-val   odu-tim-detect-mode=SAPI-and-DAPI    interface-circuit-id=${circuit-id} 
    \     ...    supporting-interface=${ATTELLA_DEF_CLIENT_OTU_NAME_PREFIX}${INDEXS}:0:0    supporting-circuit-pack-name=${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}${INDEXS}     supporting-port=${ATTELLA_DEF_PORT_CLIENT_PREFIX}${INDEXS}
    \     @{interface_info}    create list    ${client_interface}
    \     &{dev_info}   create_dictionary   interface=${interface_info}       
    \     &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}    

    
TC2
    [Documentation]  Verify delete all otu4 client interface via openRoadm leaf
    ...              RLI38968 5.4-1
    [Tags]          Sanity  tc2
    Log         Verify delete different type of special interface via Restconf Patch method
    ${ATTELLA_DEF_CLIENT_OTU_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}  1/    0/ 
    ${ATTELLA_DEF_CLIENT_ODU_NAME_PREFIX}   Replace String   ${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}  1/    0/     
    : FOR    ${INDEXS}    IN RANGE    0    8 
    \    &{OTUinterface}    create dictionary    interface-name=${ATTELLA_DEF_CLIENT_OTU_NAME_PREFIX}${INDEXS}:0:0 
    \    @{delinter}    create list    ${OTUinterface}
    \    &{dev_info}   create dictionary   interface=${delinter}       
    \    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    \    check status line  ${patch_resp}  200
    
    : FOR    ${INDEXS}    IN RANGE    0    8 
    \    &{ODUinterface}    create dictionary    interface-name=${ATTELLA_DEF_CLIENT_ODU_NAME_PREFIX}${INDEXS}:0:0:0
    \    @{delinter}    create list     ${ODUinterface}
    \    &{dev_info}   create dictionary   interface=${delinter}       
    \    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    \    check status line  ${patch_resp}  200
    
    
TC3
    [Documentation]  Verify can configure all client interface attribute via openRoadm leaf
    ...              RLI38968 5.4-1
    [Tags]           Sanity   tc3
    Log           Configure client interface supporting-port via Restconf Patch method
    ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    : FOR    ${INDEXS}    IN RANGE    0    8
    \     &{100GE_interface}    create dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}    description=ethernet-interface    interface-type=${ATTELLA_DEF_CLIENT_PORT_TYPE}    
    \     ...    interface-administrative-state=${ATTELLA_INTERFACE_ADMINSTRATION_STATE}   interface-circuit-id=${circuit-id}    
    \     ...    supporting-interface=none    supporting-circuit-pack-name=${ATTELLA_DEF_CLIENT_TRANSC_NAME_PREFIX}${INDEXS}     supporting-port=${ATTELLA_DEF_PORT_CLIENT_PREFIX}${INDEXS}
    \     @{interface_info}    create list    ${100GE_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}    


TC4
    [Documentation]  Verify can configure all line interface attribute via openRoadm leaf
    ...              RLI38968 5.4-1
    [Tags]           Sanity   tc4 
    Log           Configure client interface supporting-port via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    \     &{och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0     description=och-interface    interface-type=${ATTELLA_DEF_OCH_PORT_TYPE}    
    \     ...    interface-administrative-state=${ATTELLA_INTERFACE_ADMINSTRATION_STATE}    interface-circuit-id=${circuit-id}    supporting-interface=none   
    \     ...    supporting-circuit-pack-name=${ATTELLA_DEF_LINE_TRANSC_NAME_PREFIX}${INDEX}     supporting-port=${ATTELLA_DEF_PORT_LINE_PREFIX}${INDEX}
    \     ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    \     &{otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0     description=otu-interface    interface-type=${ATTELLA_DEF_OTU_PORT_TYPE}    
    \     ...    interface-administrative-state=${ATTELLA_INTERFACE_ADMINSTRATION_STATE}    interface-circuit-id=${circuit-id}    supporting-interface=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0   
    \     ...    supporting-circuit-pack-name=${ATTELLA_DEF_LINE_TRANSC_NAME_PREFIX}${INDEX}     supporting-port=${ATTELLA_DEF_PORT_LINE_PREFIX}${INDEX}
    \     ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    \     &{odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0     description=odu-interface    interface-type=${ATTELLA_DEF_ODU_PORT_TYPE}    
    \     ...    interface-administrative-state=${ATTELLA_INTERFACE_ADMINSTRATION_STATE}   interface-circuit-id=${circuit-id}    supporting-interface=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0     
    \     ...    supporting-circuit-pack-name=${ATTELLA_DEF_LINE_TRANSC_NAME_PREFIX}${INDEX}     supporting-port=${ATTELLA_DEF_PORT_LINE_PREFIX}${INDEX}
    \     @{interface_info}    create list    ${och_interface}   ${otu_interface}   ${odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 

TC5 
    [Documentation]  Verify can configure interface name and type via openRoadm leaf
    ...              RLI38968 5.4-2
    [Tags]           Sanity  tc5  
    Log           Configure client interface name and type via Restconf Patch method
    &{100GE_interface}   create dictionary   interface-name=${tv['device0__intf4__pic']}    interface-type=${ATTELLA_DEF_CLIENT_PORT_TYPE}
    &{och_interface}    create dictionary   interface-name=${tv['device0__intf1__pic']}    interface-type=${ATTELLA_DEF_OCH_PORT_TYPE} 
    &{otu_interface}    create dictionary   interface-name=${tv['device0__intf2__pic']}    interface-type=${ATTELLA_DEF_OTU_PORT_TYPE}
    &{odu_interface}    create dictionary    interface-name=${tv['device0__intf3__pic']}    interface-type=${ATTELLA_DEF_ODU_PORT_TYPE}
    @{interface_info}    create list    ${100GE_interface}    ${och_interface}   ${otu_interface}    ${odu_interface}  
    &{dev_info}   create dictionary   interface=${interface_info}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}    

TC6 
    [Documentation]  Verify can configure interface description via openRoadm leaf
    ...              RLI38968 5.4-3	
    [Tags]          Sanity   tc6    
    Log           Configure client interface description via Restconf Patch method
    &{100GE_interface}    create dictionary   interface-name=${tv['device0__intf4__pic']}    description=ethernet-interface
    &{och_interface}    create dictionary   interface-name=${tv['device0__intf1__pic']}    description=och-interface
    &{otu_interface}    create dictionary   interface-name=${tv['device0__intf2__pic']}    description=otu-interface
    &{odu_interface}    create dictionary    interface-name=${tv['device0__intf3__pic']}    description=odu-interface
    @{interface_info}    create list    ${100GE_interface}    ${och_interface}   ${otu_interface}   ${odu_interface}  
    &{dev_info}   create dictionary   interface=${interface_info}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}    


TC7 
    [Documentation]  Verify can configure interface administrative-state via openRoadm leaf
    ...              RLI38968 5.4-5
    [Tags]           Sanity   tc7 
    Log           Configure client interface administrative-state via Restconf Patch method
    @{adminstatulist}  create list   ${ATTELLA_INTERFACE_ADMINSTRATION_STATE3}    ${ATTELLA_INTERFACE_ADMINSTRATION_STATE2}   ${ATTELLA_INTERFACE_ADMINSTRATION_STATE}
    :FOR    ${admin-status}  in  @{adminstatulist}
    \     &{100GE_interface}    create dictionary   interface-name=${tv['device0__intf4__pic']}    interface-administrative-state=${admin-status}
    \     &{och_interface}    create dictionary   interface-name=${tv['device0__intf1__pic']}    interface-administrative-state=${admin-status}
    \     &{otu_interface}    create dictionary   interface-name=${tv['device0__intf2__pic']}    interface-administrative-state=${admin-status}
    \     &{odu_interface}    create dictionary    interface-name=${tv['device0__intf3__pic']}    interface-administrative-state=${admin-status}
    \     @{interface_info}    create list    ${100GE_interface}    ${och_interface}   ${otu_interface}   ${odu_interface}  
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC8
    [Documentation]  Verify can configure interface circuit-id via openRoadm leaf
    ...              RLI38968 5.4-7
    [Tags]           Sanity    tc8   
    Log           Configure client interface circuit-id via Restconf Patch method
    ${circuit-id}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,45)))      random,string
    &{100GE_interface}    create dictionary   interface-name=${tv['device0__intf4__pic']}    interface-circuit-id=${circuit-id}
    &{och_interface}    create dictionary   interface-name=${tv['device0__intf1__pic']}    interface-circuit-id=${circuit-id}
    &{otu_interface}    create dictionary   interface-name=${tv['device0__intf2__pic']}    interface-circuit-id=${circuit-id}
    &{odu_interface}    create dictionary    interface-name=${tv['device0__intf3__pic']}    interface-circuit-id=${circuit-id}
    @{interface_info}    create list    ${100GE_interface}    ${och_interface}   ${otu_interface}   ${odu_interface}  
    &{dev_info}   create dictionary   interface=${interface_info}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}  


TC9
    [Documentation]  Verify can configure supporting-interface via openRoadm leaf
    ...              RLI38968 5.4-8
    [Tags]           Sanity   tc9    
    Log           Configure client interface supporting-interface via Restconf Patch method
    &{100GE_interface}    create dictionary   interface-name=${tv['device0__intf4__pic']}    supporting-interface=none
    &{och_interface}    create dictionary   interface-name=${tv['device0__intf1__pic']}    supporting-interface=none
    &{otu_interface}    create dictionary   interface-name=${tv['device0__intf2__pic']}    supporting-interface=${tv['device0__intf1__pic']}
    &{odu_interface}    create dictionary    interface-name=${tv['device0__intf3__pic']}    supporting-interface=${tv['device0__intf2__pic']}
    @{interface_info}    create list    ${100GE_interface}    ${och_interface}   ${otu_interface}   ${odu_interface}  
    &{dev_info}   create dictionary   interface=${interface_info}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC10
    [Documentation]  Verify can configure supporting-circuit-pack-name via openRoadm leaf
    ...              RLI38968 5.4-9
    [Tags]           Sanity   tc10    
    Log           Configure client interface supporting-circuit-pack-name via Restconf Patch method
    &{100GE_interface}    create dictionary   interface-name=${tv['device0__intf4__pic']}    supporting-circuit-pack-name=xcvr-0/0/0
    &{och_interface}    create dictionary   interface-name=${tv['device0__intf1__pic']}    supporting-circuit-pack-name=xcvr-0/1/0
    &{otu_interface}    create dictionary   interface-name=${tv['device0__intf2__pic']}    supporting-circuit-pack-name=xcvr-0/1/0
    &{odu_interface}    create dictionary    interface-name=${tv['device0__intf3__pic']}    supporting-circuit-pack-name=xcvr-0/1/0
    @{interface_info}    create list    ${100GE_interface}    ${och_interface}   ${otu_interface}   ${odu_interface}  
    &{dev_info}   create dictionary   interface=${interface_info}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC11
    [Documentation]  Verify can configure supporting-port via openRoadm leaf
    ...              RLI38968 5.4-10
    [Tags]           Sanity   tc11    
    Log           Configure client interface supporting-port via Restconf Patch method
    &{100GE_interface}    create dictionary   interface-name=${tv['device0__intf4__pic']}    supporting-port=port-0/0/0
    &{och_interface}    create dictionary   interface-name=${tv['device0__intf1__pic']}     supporting-port=port-0/1/0
    &{otu_interface}    create dictionary   interface-name=${tv['device0__intf2__pic']}     supporting-port=port-0/1/0
    &{odu_interface}    create dictionary    interface-name=${tv['device0__intf3__pic']}    supporting-port=port-0/1/0
    @{interface_info}    create list    ${100GE_interface}    ${och_interface}   ${otu_interface}   ${odu_interface}  
    &{dev_info}   create dictionary   interface=${interface_info}       
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


# for ethernet port
TC12 
    [Documentation]  Verify can configure ethernet interface speed via openRoadm leaf
    ...              RLI38968 5.4-12
    [Tags]           Sanity   tc12   ethernet
    Log           Configure ethernet interface speed via Restconf Patch method
    : FOR    ${INDEXS}    IN RANGE    0    8
    \     &{100GE_interface}    create dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}     speed=100000   
    \     @{interface_info}    create list    ${100GE_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}  


TC13
    [Documentation]  Verify can configure ethernet interface fec via openRoadm leaf
    ...              RLI38968 5.4-13
    [Tags]           Sanity   tc13   ethernet
    Log           Configure ethernet interface fec via Restconf Patch method
    : FOR    ${INDEXS}    IN RANGE    0    8
    \     &{100GE_interface}    create dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}   ethernet-fec=off    
    \     @{interface_info}    create list    ${100GE_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 

    
TC14 
    [Documentation]  Verify can configure ethernet interface duplex via openRoadm leaf
    ...              RLI38968 5.4-14
    [Tags]           Sanity   tc14   ethernet
    Log           Configure ethernet interface duplex via Restconf Patch method
    : FOR    ${INDEXS}    IN RANGE    0    8
    \     &{100GE_interface}    create dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}   duplex=full    
    \     @{interface_info}    create list    ${100GE_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC15
    [Documentation]  Delete all clinet port ethernet attribute via openRoadm leaf
    ...              RLI38968 5.4-11
    [Tags]           Sanity   tc15    ethernet
    Log           Delete all clinet port ethernet attribute via openRoadm leaf via Restconf Patch method
    # ${mulit}   set variable   2 
    : FOR    ${INDEXS}    IN RANGE    0    8
    # \     ${INDEXS}   Evaluate   ${INDEX}*${mulit}*1
    \     &{100GE_interface}    create dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}   ethernet=${null} 
    \    @{delinter}    create list    ${100GE_interface}
    \    &{dev_info}   create dictionary   interface=${delinter}       
    \    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \    ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    \    check status line  ${patch_resp}  200   
    
  
TC16
    [Documentation]  Verify can configure all interface ethernet attribute via openRoadm leaf
    ...              RLI38968 5.4-11-2
    [Tags]            Sanity    tc16    ethernet 
    Log           Configure all client interface ethernet via Restconf Patch method
    ${mulit}   set variable   2 
    : FOR    ${INDEXS}    IN RANGE    0    8
    # \     ${INDEXS}   Evaluate   ${INDEX}*${mulit}*1
    \     &{100GE_interface}    create dictionary   interface-name=${ATTELLA_DEF_CLIENT_PORT_NAME_PREFIX}${INDEXS}   duplex=full    ethernet-fec=off   speed=100000  
    \     @{interface_info}    create list    ${100GE_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


# for och port
TC17
    [Documentation]  Verify can configure och interface rate via openRoadm leaf
    ...              RLI38968 5.4-18
    [Tags]           Sanity   tc17  och
    Log           Configure och interface rate via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0    och-rate=R100G     
    \     @{interface_info}    create list    ${Och_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC18
    [Documentation]  Verify can configure och interface frequency via openRoadm leaf
    ...              RLI38968 5.4-19
    [Tags]           Sanity   tc18   och 
    Log           Configure och interface frequency via Restconf Patch method
    ${basefreq}  set variable  191.35
    : FOR    ${INDEX}    IN RANGE    0    4    
    \     ${freId}   evaluate   random.randint(0,95)   random,sys
    \     ${sfrq}    evaluate   '%.2f'%(0.05*${freId}*1+${basefreq})
    \     ${iFrequencyId}   convert to string    ${sfrq}
    \     log   ${iFrequencyId}
    \     &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0   frequency=${iFrequencyId}000   
    \     @{interface_info}    create list    ${Och_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}    


TC19 
    [Documentation]  Verify can configure och interface modulation-format via openRoadm leaf
    ...              RLI38968 5.4-21
    [Tags]           Sanity    tc19   och
    Log           Configure och interface modulation-format via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0   modulation-format=dp-qpsk    
    \     @{interface_info}    create list    ${Och_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}


TC20
    [Documentation]  Verify can configure och interface transmit-power via openRoadm leaf
    ...              RLI38968 5.4-22
    [Tags]           Sanity   tc20   och
    Log           Configure och interface transmit-power via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0   transmit-power=-3.00  
    \     @{interface_info}    create list    ${Och_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}


TC21
    [Documentation]  Verify can delete all och interface attribute via openRoadm leaf
    ...              RLI38968 5.4-17
    [Tags]           Sanity   tc21   och
    Log           Delete och interface all attribute via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0   och=${null}  
    \     @{interface_info}    create list    ${Och_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    \     check status line  ${patch_resp}  200   


TC22
    [Documentation]  Verify can configure all och interface attribute with one time request
    ...              RLI38968 5.4-17-2
    [Tags]           Sanity   tc22   och 
    Log           Configure all och interface attribute via Restconf Patch method
    ${basefreq}  set variable  191.35
    : FOR    ${INDEX}    IN RANGE    0    4    
    \     ${freId}   evaluate   random.randint(0,95)   random,sys
    \     ${sfrq}    evaluate   '%.2f'%(0.05*${freId}*1+${basefreq})
    \     ${iFrequencyId}   convert to string    ${sfrq}
    \     log   ${iFrequencyId}
    \     &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0    och-rate=R100G     frequency=${iFrequencyId}000
    \     ...   modulation-format=dp-qpsk      transmit-power=-3.00 
    \     @{interface_info}    create list    ${Och_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}


TC23
    [Documentation]  Verify can get och interface width via openRoadm leaf
    ...              RLI38968 5.4-20
    [Tags]           Sanity   tc23   och
    Log           get och interface width via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Och_interface}    create dictionary   interface-name=${ATTELLA_DEF_OCH_PORT_NAME_PREFIX}${INDEX}:0   width=50.00000     
    \     @{interface_info}    create list    ${Och_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}


# for Odu port
TC24
    [Documentation]  Verify can configure Odu interface degm-intervals via openRoadm leaf
    ...              RLI38968 5.4-53  5.4-54
    [Tags]           Sanity    tc24  odu
    Log           Configure Odu interface degm-intervals via Restconf Patch method  
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${deginv}=      Evaluate      random.randint(2, 10)     random
    \     ${degpertage}=      Evaluate      random.randint(1, 100)     random
    \     ${deginv}      Convert to string     ${deginv}
    \     ${degpertage}      Convert to string     ${degpertage}   
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-degm-intervals=${deginv}   odu-degthr-percentage=${degpertage}  
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 
  
    
TC25 
    [Documentation]  Verify can configure Odu interface rate via openRoadm leaf
    ...              RLI38968 5.4-40
    [Tags]           Sanity  tc25   odu
    Log           Configure Odu interface rate via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0   odu-rate=ODU4     
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC26 
    [Documentation]  Verify can configure Odu interface monitoring-mode via openRoadm leaf
    ...              RLI38968 5.4-41
    [Tags]           Sanity   tc26  odu
    Log           Configure Odu interface monitoring-mode via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    monitoring-mode=terminated   
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC27
    [Documentation]  Verify can configure Odu interface proactive-delay-measurement-enabled via openRoadm leaf
    ...              RLI38968 5.4-42
    [Tags]           Sanity   tc27   odu
    Log           Configure Odu interface proactive-delay-measurement-enabled via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    proactive-delay-measurement-enabled=false  
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC28
    [Documentation]  Verify can configure Odu interface tx-sapi via openRoadm leaf
    ...              RLI38968 5.4-43
    [Tags]           Sanity   tc28   odu
    Log           Configure Odu interface tx-sapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-tx-sapi=${txsapi}
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC29
    [Documentation]  Verify can configure Odu interface tx-dapi via openRoadm leaf
    ...              RLI38968 5.4-44
    [Tags]           Sanity   tc29  odu
    Log           Configure Odu interface tx-dapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txdapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-tx-dapi=${txdapi} 
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC30
    [Documentation]  Verify can configure Odu interface tx-operator via openRoadm leaf
    ...              RLI38968 5.4-45
    [Tags]           Sanity   tc30   odu
    Log           Configure Odu interface tx-sapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txoper}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,32)))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-tx-operator=${txoper} 
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC31
    [Documentation]  Verify can configure Odu interface expected-sapi via openRoadm leaf
    ...              RLI38968 5.4-49
    [Tags]           Sanity   tc31  odu
    Log           Configure Odu interface expected-sapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${expsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-expected-sapi=${expsapi}  
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC32
    [Documentation]  Verify can configure Odu interface expected-dapi via openRoadm leaf
    ...              RLI38968 5.4-50
    [Tags]           Sanity   tc32   odu
    Log           Configure Odu interface expected-dapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${expsdpi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-expected-dapi=${expsdpi}
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC33
    [Documentation]  Verify can configure Odu interface tim-act-enabled via openRoadm leaf
    ...              RLI38968 5.4-51
    [Tags]           Sanity   tc33  odu
    Log           Configure Odu interface tim-act-enabled via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${timactst}   Evaluate   random.choice(["true", "false"])     random
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-tim-act-enabled=${timactst}
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC34
    [Documentation]  Verify can configure Odu interface tim-detect-mode via openRoadm leaf
    ...              RLI38968 5.4-52
    [Tags]           Sanity   tc34   odu
    Log           Configure Odu interface tim-detect-mode via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${timdetmode}   Evaluate   random.choice(["SAPI", "DAPI", "SAPI-and-DAPI", "Disabled"])     random
    #\     ${timdetmode}   Evaluate   random.choice(["SAPI-and-DAPI", "Disabled"])     random
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-tim-detect-mode=${timdetmode}  
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}  


TC35
    [Documentation]  Verify can configure Odu interface payload-type via openRoadm leaf
    ...              Mapping JTMS RLI-38968 TC 5.4-61
    [Tags]           Sanity   tc34   odu
    Log           Configure Opu interface payload-type via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${payloadty}    Evaluate     "".join(random.sample(string.digits, 2))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    payload-type=${payloadty}  
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}  


TC36
    [Documentation]  Verify can configure Opu interface exp-payload-type via openRoadm leaf
    ...              Mapping JTMS RLI-38968 TC 5.4-62
    [Tags]           Sanity   tc34   odu
    Log           Configure Opu interface exp-payload-type via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${expayloadty}   Evaluate     "".join(random.sample(string.digits, 2))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    exp-payload-type=${expayloadty}  
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}  


TC37
    [Documentation]  Verify can configure Opu interface payload-interface via openRoadm leaf
    ...              Mapping JTMS RLI-38968 TC 5.4-63
    [Tags]           Sanity   tc34   odu
    Log           Configure Opu interface payload-interface via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    payload-interface=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC38
    [Documentation]  Verify can delete all odu interface attribute via openRoadm leaf
    ...              RLI38968 5.4-39
    [Tags]           Sanity   tc35   odu1
    Log           Delete all Odu interface attribute via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0   odu=${null}  
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    \     check status line  ${patch_resp}  200   

    
TC39
    [Documentation]  Verify can configure all Odu interface attribute via openRoadm leaf
    ...              Mapping JTMS RLI-38968 TC 5.4-39, 5.4-46to50, 5.4-53-54, 5.4.61-63
    [Tags]           Sanity    tc36   odu  
    Log           Configure Odu interface tim-detect-mode via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${txdapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${txoper}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,32)))      random,string
    \     ${expsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${expsdpi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${deginv}=      Evaluate      random.randint(2, 10)     random
    \     ${degpertage}=      Evaluate      random.randint(1, 100)     random
    \     ${deginv}      Convert to string     ${deginv}
    \     ${degpertage}      Convert to string     ${degpertage} 
    \     ${timdetmode}   Evaluate   random.choice(["SAPI", "DAPI", "SAPI-and-DAPI", "Disabled"])    random
    \     ${payloadty}    Evaluate     "".join(random.sample(string.digits, 2))      random,string
    \     ${expayloadty}   Evaluate     "".join(random.sample(string.digits, 2))      random,string
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0    odu-rate=ODU4    odu-tim-act-enabled=true    odu-tim-detect-mode=${timdetmode}  
    \     ...   odu-degm-intervals=${deginv}    odu-degthr-percentage=${degpertage}   monitoring-mode=terminated    proactive-delay-measurement-enabled=false
    \     ...   odu-tx-sapi=${txsapi}    odu-tx-dapi=${txdapi}   odu-tx-operator=${txoper}    odu-expected-sapi=${expsapi}    odu-expected-dapi=${expsdpi}
    \     ...   payload-type=${payloadty}    exp-payload-type=${expayloadty}    payload-interface=${ATTELLA_DEF_ODU_PORT_NAME_PREFIX}${INDEX}:0:0:0
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


# for Otu port
TC40
    [Documentation]  Verify can configure Otu interface degm-intervals via openRoadm leaf
    ...              Mapping JTMS RLI-38968 TC 5.4-23
    [Tags]           Sanity   tc37  otu
    Log           Configure Otu interface degm-intervals via Restconf Patch method  
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${deginv}=      Evaluate      random.randint(2, 10)     random
    \     ${degpertage}=      Evaluate      random.randint(1, 100)     random
    \     ${deginv}      Convert to string     ${deginv}
    \     ${degpertage}      Convert to string     ${degpertage}   
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0   otu-degm-intervals=${deginv}   otu-degthr-percentage=${degpertage}  
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}    


TC41
    [Documentation]  Verify can configure Otu interface rate via openRoadm leaf
    ...              RLI38968 5.4-24
    [Tags]           Sanity   tc38   otu
    Log           Configure Otu interface rate via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0   otu-rate=OTU4     
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC42 
    [Documentation]  Verify can configure Otu interface fec via openRoadm leaf
    ...              RLI38968 5.4-25
    [Tags]         Sanity    tc39  otu  
    Log           Configure Otu interface fec via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${otu_fec}   Evaluate   random.choice(["off", "scfec"])     random
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0   otu-fec=${otu_fec}     
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 

    
TC43
    [Documentation]  Verify can configure Otu interface tx-sapi via openRoadm leaf
    ...              RLI38968 5.4-26
    [Tags]           Sanity   tc40   otu
    Log           Configure Otu interface tx-sapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-tx-sapi=${txsapi}
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC44
    [Documentation]  Verify can configure Otu interface tx-dapi via openRoadm leaf
    ...              RLI38968 5.4-27
    [Tags]         Sanity  tc41  otu
    Log           Configure Otu interface tx-dapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txdapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-tx-dapi=${txdapi} 
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC45
    [Documentation]  Verify can configure Otu interface tx-operator via openRoadm leaf
    ...              RLI38968 5.4-28
    [Tags]          Sanity   tc42   otu
    Log           Configure Otu interface tx-sapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txoper}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,32)))      random,string
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-tx-operator=${txoper} 
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC46
    [Documentation]  Verify can configure Otu interface expected-sapi via openRoadm leaf
    ...              RLI38968 5.4-32
    [Tags]           Sanity  tc43  otu
    Log           Configure Otu interface expected-sapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${expsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-expected-sapi=${expsapi}
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC47
    [Documentation]  Verify can configure Otu interface expected-dapi via openRoadm leaf
    ...              RLI38968 5.4-33
    [Tags]        Sanity   tc44   otu
    Log           Configure Otu interface expected-dapi via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${expsdpi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-expected-dapi=${expsdpi}
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC48
    [Documentation]  Verify can configure Otu interface tim-act-enabled via openRoadm leaf
    ...              RLI38968 5.4-34
    [Tags]         Sanity    tc45  otu
    Log           Configure Otu interface tim-act-enabled via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-tim-act-enabled=false  
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 


TC49
    [Documentation]  Verify can configure Otu interface tim-detect-mode via openRoadm leaf
    ...              RLI38968 5.4-35
    [Tags]           Sanity    tc46   otu
    Log           Configure Otu interface tim-detect-mode via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${timdetmode}   Evaluate   random.choice(["SAPI", "DAPI", "SAPI-and-DAPI", "Disabled"])     random
    # \     ${timdetmode}   Evaluate   random.choice(["SAPI-and-DAPI", "Disabled"])     random
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-tim-detect-mode=${timdetmode}  
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}  

TC50
    [Documentation]  Verify can delete all otu interface attribute via openRoadm leaf
    ...              RLI38968 5.4-23
    [Tags]           Sanity   tc47   otu
    Log           Delete all Otu interface attribute via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu=${null}  
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     ${patch_resp}  Send Delete Request   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${payload} 
    \     check status line  ${patch_resp}  200   
    
TC51
    [Documentation]  Verify can configure all Otu interface attribute via openRoadm leaf
    ...              RLI38968 5.4-23
    [Tags]           Sanity  tc48   otu  
    Log           Configure Otu interface all attributes via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${txsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${txdapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${txoper}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,32)))      random,string
    \     ${expsapi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${expsdpi}     Evaluate     "".join(random.sample(string.ascii_letters + string.digits, random.randint(1,15)))      random,string
    \     ${deginv}=      Evaluate      random.randint(2, 10)     random
    \     ${degpertage}=      Evaluate      random.randint(1, 100)     random
    \     ${deginv}      Convert to string     ${deginv}
    \     ${degpertage}      Convert to string     ${degpertage} 
    \     ${timdetmode}   Evaluate   random.choice(["SAPI-and-DAPI", "Disabled"])     random
    \     &{Odu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0   otu-degm-intervals=${deginv}    otu-degthr-percentage=${degpertage}
    \     ...  otu-rate=OTU4       otu-fec=scfec   otu-tim-act-enabled=false    otu-tim-detect-mode=${timdetmode}
    \     ...   otu-tx-sapi=${txsapi}    otu-tx-dapi=${txdapi}   otu-tx-operator=${txoper}    otu-expected-sapi=${expsapi}    otu-expected-dapi=${expsdpi}
    \     @{interface_info}    create list    ${Odu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}     


TC52
    [Documentation]  Verify can Otu interface maint-loopback via openRoadm leaf
    ...              RLI38968 5.4-36
    [Tags]           Sanity   tc49   otu
    Log           Enbale Otu interface maint-loopback via Restconf Patch method
    ${otulbtype}   Evaluate   random.choice(["term", "fac"])     random
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-maint-enabled=false     otu-maint-type=${otulbtype}
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}


TC53
    [Documentation]  Verify can enable Otu interface maint-loopback via openRoadm leaf
    ...              RLI38968 5.4-37
    [Tags]         Sanity    tc50  otu
    Log           Enbale Otu interface maint-loopback via Restconf Patch method
    : FOR    ${INDEX}    IN RANGE    0    4
    \     ${lpstatus}   Evaluate   random.choice(["true", "false"])     random
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-maint-enabled=${lpstatus}
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}      

TC54
    [Documentation]  Verify can Otu maint-loopback type via openRoadm leaf
	...              RLI38968 5.4-38
    [Tags]         Sanity    tc54  otu
    Log           Enbale Otu interface maint-loopback via Restconf Patch method
	${otulbtype}   Evaluate   random.choice(["term", "fac"])     random
    : FOR    ${INDEX}    IN RANGE    0    4
    \     &{Otu_interface}    create dictionary   interface-name=${ATTELLA_DEF_OTU_PORT_NAME_PREFIX}${INDEX}:0:0    otu-maint-type=${otulbtype}
    \     @{interface_info}    create list    ${Otu_interface} 
    \     &{dev_info}   create dictionary   interface=${interface_info}       
    \     &{payload}   create dictionary   org-openroadm-device=${dev_info}
    \     Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}  


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
