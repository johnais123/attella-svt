*** Settings ***
Documentation     This is Attella info Scripts
...              Description  : RLI-38968: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : liuliuli@juniper.net
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
## variables of limitation test##        
${INVALID_ATTELLA_DEF_INFO_NODE_ID}  123456
${INVALID_ATTELLA_DEF_INFO_NODE_TYPE}  rdm123
${INVALID_ATTELLA_DEF_INFO_NODE_NUMBER}  123456789012345678901234567890123
${INVALID_ATTELLA_DEF_INFO_DEFAULTGATEWAY}  255.255.255
${INVALID_ATTELLA_DEF_INFO_IPADDRESS}  255.255.255
## end of variables of limitation test## 

@{auth}    admin    admin
${interval}  10
${timeout}   300

*** Test Cases ***     
TC1
    [Documentation]  Setting for org-openroadm-device all info leaves
    ...              RLI38968 5.1-1
    [Tags]           Sanity   tc1   tests
    Log           Configure default Gateway via Restconf Patch method
    ${random-int}    Evaluate    random.randint(0,128)     random 
    ${grandom-length} =   convert To String     ${random-int}
    Set Suite Variable     ${grandom-length}
    ${random-float}   evaluate    random.randint(-89,89) + random.random()    random 
    ${random-latit}       evaluate    '%.16f'%(${random-float})       string 
    ${random-float2}   evaluate    random.randint(-179,179) + random.random()    random    
    ${random-longitu}   evaluate    '%.16f'%(${random-float2})       string 
    ${NodeNb}      Convert to string     ${tv['uv-attella_def_info_node_number']}
    ${prefix_length}      Convert to string     ${tv['uv-attella_def_info_prefix_length']}
    ${Template-name}     Evaluate     "".join(random.sample(string.ascii_letters, random.randint(1,10)))      random,string
    &{dev_info}   create dictionary    node-id=${tv['uv-attella_def_info_node_id']}   node-number=${NodeNb}   defaultGateway=${tv['uv-attella_def_info_defaultgateway']}
    ...  node-type=${tv['uv-attella_def_info_node_type']}   clli=${tv['uv-attella_def_info_clli']}   ipAddress=${tv['device0__re0__mgt-ip']}   prefix-length=${prefix_length}
    ...  latitude=${random-latit}      longitude=${random-longitu}   template=${Template-name}.json
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${payload}  

TC2 
    [Documentation]  Setting for org-openroadm-device/info/node-id
    ...              RLI38968 5.1-2
    [Tags]           Sanity   tc2  
    Log           Configure node-id via Restconf Patch method
    &{dev_info}   create dictionary   node-id=${tv['uv-attella_def_info_node_id']}
    &{payload}    create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}     ${payload}

    
TC3
    [Documentation]  Reject wrong node-id info via openRoadm 
    ...              RLI38968 5.1-3-2
    [Tags]           Negative   tc3  limitation
    Log           Configure node-id via Restconf Patch method
    &{dev_info}   create dictionary   node-id=${INVALID_ATTELLA_DEF_INFO_NODE_ID}
    &{payload}    create dictionary   org-openroadm-device=${dev_info}
    ${resp}  Send Merge Request    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}     ${payload}
    check status line    ${resp}     400

    
TC4
    [Documentation]  Setting for org-openroadm-device/info/node-number
    ...              RLI38968 5.1-3
    [Tags]           Sanity   tc4
    Log           Configure node-number via Restconf Patch method
    ${NodeNb}      Convert to string     ${tv['uv-attella_def_info_node_number']}
    &{dev_info}   create dictionary   node-number=${NodeNb}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload} 

    
TC5
    [Documentation]  Reject wrong node-number info via openRoadm
    ...              RLI38968 5.1-5
    [Tags]           Negative  tc5  limitation
    Log           Configure node-number via Restconf Patch method
    &{dev_info}   create dictionary   node-number=${INVALID_ATTELLA_DEF_INFO_NODE_NUMBER}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${resp}  Send Merge Request    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload} 
    check status line    ${resp}     400

    
TC6
    [Documentation]  Setting for org-openroadm-device/info/node-type
    ...              RLI38968 5.1-4
    [Tags]           Sanity   tc6
    Log          Configure node-type via Restconf Patch method
    &{dev_info}   create dictionary   node-type=${tv['uv-attella_def_info_node_type']}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}

    
TC7
    [Documentation]  Reject wrong node-type info via openRoadm 
    ...              RLI38968 5.1-4-2
    [Tags]           Negative   tc7   limitation
    Log          Configure node-type via Restconf Patch method
    &{dev_info}   create dictionary   node-type= ${INVALID_ATTELLA_DEF_INFO_NODE_TYPE}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${resp}  Send Merge Request    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}    
    check status line    ${resp}     400

    
TC8
    [Documentation]  Setting for org-openroadm-device/info/clli
    ...              RLI38968 5.1-5
    [Tags]           Sanity   tc8
    Log          Configure clli via Restconf Patch method
    &{dev_info}   create dictionary    clli=${tv['uv-attella_def_info_clli']}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}

    
TC9
    [Documentation]  Verify can retrieve all readonly info leave
    ...              RLI38968 5.1-6 5.1-7 5.1-11 5.1-12 5.1-13 5.1-14 5.1-16 5.1-17 5.1-19
    [Tags]           Sanity   tc9 
    Log             Fetching all readonly info leave via Restconf GET method
    &{dev_info}   create dictionary   vendor-info=${tv['uv-attella_def_info_vendor']}   model-info=${tv['uv-attella_def_info_model']} 
    ...   serial-id-info=${serNu_info}  source=static   current-ipAddress=${tv['device0__re0__mgt-ip']}   
    ...   current-prefix-length=${tv['uv-attella_def_info_current_prefix_length']}
    ...   current-defaultGateway=${tv['uv-attella_def_info_current_defaultgateway']}   openroadm-version=${tv['uv-attella_def_info_openroadm_version']}
    ...   softwareVersion=${version_info}     max-srgs=0   max-degrees=0  max-num-bin-15min-historical-pm=96
    ...   max-num-bin-24hour-historical-pm=1
    #  ...   macAddress=${macadd_info}
    &{netconfParams}   create dictionary   org-openroadm-device=${dev_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${netconfParams}
    
    
TC10
    [Documentation]  Setting for org-openroadm-device/info/ipAddress relate leaves
    ...              RLI38968 5.1-8
    [Tags]           Sanity   tc10
    Log           Configure ip Address via Restconf Patch method
    ${prefix_length}      Convert to string     ${tv['uv-attella_def_info_prefix_length']}
    &{dev_info}   create dictionary   ipAddress=${tv['device0__re0__mgt-ip']}   prefix-length=${prefix_length}  defaultGateway=${tv['uv-attella_def_info_defaultgateway']}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${payload}


TC11
    [Documentation]  Reject wrong ipAddress via openRoadm
    ...              RLI38968 5.1-8-1
    [Tags]           Negative   tc11   limitation
    Log           Configure ip Address via Restconf Patch method
    &{dev_info}   create dictionary   ipAddress=${INVALID_ATTELLA_DEF_INFO_IPADDRESS}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${resp}  Send Merge Request    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${payload}
    check status line    ${resp}     400


TC12
    [Documentation]  Reject wrong prefix-length via openRoadm
    ...              RLI38968 5.1-9-1
    [Tags]           Negative    tc12   limitation
    Log           Configure prefix-length via Restconf Patch method
    ${random-int}    Evaluate    random.randint(130,200)    random 
    ${random-length} =   convert To String     ${random-int}
    &{dev_info}   create dictionary     prefix-length=${random-length}
    &{payload}    create dictionary   org-openroadm-device=${dev_info}
    ${resp}  Send Merge Request    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${payload}
    check status line    ${resp}     400


TC13
    [Documentation]  Reject wrong Gateway via openRoadm
    ...              RLI38968 5.1-10-1
    [Tags]           Negative   tc13   limitation
    Log           Configure default Gateway via Restconf Patch method
    &{dev_info}   create dictionary    defaultGateway=${INVALID_ATTELLA_DEF_INFO_DEFAULTGATEWAY}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    ${resp}  Send Merge Request    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}   ${payload}
    check status line    ${resp}    400


TC14
    [Documentation]  Verify can configure Templates info via openRoadm
    ...              RLI38968 5.1-18
    [Tags]           Sanity   tc14  limitation  
    Log           Configure geoLocation latitude via Restconf Patch method
    ${Template-name}     Evaluate     "".join(random.sample(string.ascii_letters, random.randint(1,10)))      random,string
    &{dev_info}   create dictionary       template=${Template-name}.json 
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}


TC15
    [Documentation]  Verify can configure geoLocation latitude info via openRoadm
    ...              RLI38968 5.1-20
    [Tags]           Sanity   tc15     
    Log           Configure geoLocation latitude via Restconf Patch method
    ${random-float}   evaluate    random.randint(-89,89) + random.random()    random 
    ${random-latit}       evaluate    '%.16f'%(${random-float})       string    
    &{dev_info}   create dictionary       latitude=${random-latit} 
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}


TC16
    [Documentation]  Verify can configure geoLocation longitudeinfo via openRoadm
    ...              RLI38968 5.1-21
    [Tags]           Sanity   tc16   
    Log           Configure geoLocation longitude via Restconf Patch method
    ${random-float}   evaluate    random.randint(-179,179) + random.random()    random    
    ${random-longitu}   evaluate    '%.16f'%(${random-float})       string 
    &{dev_info}   create dictionary    longitude=${random-longitu}
    &{payload}   create dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}     ${tv['device0__re0__mgt-ip']}    ${payload}    

    
TC17 
    [Documentation]  Verify can retrieve all info leaves
    ...              RLI38968 5.1-32
    [Tags]           Sanity   tc17   tests
    Log             Fetching all info leave via Restconf GET method
    &{dev_info}   create dictionary   node-id=${tv['uv-attella_def_info_node_id']}   node-number=${tv['uv-attella_def_info_node_number']}
    ...   node-type=${tv['uv-attella_def_info_node_type']}   clli=${tv['uv-attella_def_info_clli']}
    ...   ipAddress=${tv['device0__re0__mgt-ip']}   defaultGateway=${tv['uv-attella_def_info_defaultgateway']} 
    ...   vendor-info=${tv['uv-attella_def_info_vendor']}   model-info=${tv['uv-attella_def_info_model']}  
    ...   serial-id-info=${serNu_info}  source=static   current-ipAddress=${tv['device0__re0__mgt-ip']}   
    ...   prefix-length=${tv['uv-attella_def_info_prefix_length']}
    ...   current-defaultGateway=${tv['uv-attella_def_info_current_defaultgateway']}   openroadm-version=${tv['uv-attella_def_info_openroadm_version']}
    ...   softwareVersion=${version_info}   max-srgs=0   max-degrees=0  max-num-bin-15min-historical-pm=96
    ...   max-num-bin-24hour-historical-pm=1
    # ...    macAddress=${macadd_info}  
    &{netconfParams}   create dictionary   org-openroadm-device=${dev_info}
    Send Get Request And Verify Output Is Correct    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${netconfParams}    

    
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
    
    # Mount vAttella On ODL Controller    ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    # Wait For   15s 
    # Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}

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
