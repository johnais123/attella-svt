*** Settings ***
Documentation     This is Attella PM Scripts
...              Description  : RLI-38974: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : Barryzhang@juniper.net
...              Date   : N/A
...              JTMS TEST PLAN : https://systest.juniper.net/feature_testplan/59197
...              jtms description           : Attella
...              RLI                        : 38974
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

@{auth}     admin    admin
${interval}  10
${timeout}   300
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
@{pmInterval}   15min    24Hour   notApplicable
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      5 min 

*** Test Cases ***    
###  ethernet port test case 
Verify current 15min total BIPErrorCounter pm statistics on Client port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-2
    [Tags]           Sanity   tc1   done
    @{pmEntryParmater}       Create List     erroredSecondsEthernet   nearEnd    rx 
    @{pmEntryParmater2}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx   
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   10
    Sleep   10
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ett-0/0/6   ${pmEntryParmaterlist}   @{pmInterval}[0]
    log  ${realpm}
    @{expectValue}       Create List   200
    Verify Pm Should Be Equals  @{expectValue}[0]     @{realpm}[1]  
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0] 


Verify current 15min total BIPErrorCounter and erroredSecondsEthernet pm statistics on Client port
    [Documentation]  Retrieve severely Errored Seconds pm statistics on resource
    ...              RLI38974 5.1-2
    [Tags]           Sanity   tc1   done
    @{pmEntryParmater}       Create List     erroredSecondsEthernet   nearEnd    rx 
    @{pmEntryParmater2}       Create List     BIPErrorCounter    nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2} 
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx   
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_ETHERNET_PCS_PCSBIP8   10
    Sleep   10
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ett-0/0/6   ${pmEntryParmaterlist}   @{pmInterval}[0]
    log  ${realpm}
    @{expectValue}       Create List   1   200
    Lists Should Be Equal   ${realpm}    ${expectValue}

###  otu4 port test case
TC3   
    [Documentation]  Verify current 15min Near-end  OTU erroredSeconds PM statistics on otu4 Client interface
    [Tags]           Sanity   tc4   
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    5
    Sleep   10
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    @{expectValue}       Create List   1
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0] 
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  
    
    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8

TC4   
    [Documentation]  Verify current 15min Near-end  OTU severelyErroredSeconds PM statistics on otu4 Client interface
    [Tags]           Sanity   tc4   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx  
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    2.2E-03
    Sleep   10
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  
    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8

    
TC4-1   
    [Documentation]  Verify current 15min Near-end  OTU erroredSeconds PM statistics on otu4 Client interface
    [Tags]           Sanity   tc4   
    @{pmEntryParmater}       Create List     opticalPowerInput      nearEnd    rx 
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater} 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   
    Sleep   10
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    och-0/1/0:0    ${pmEntryParmaterlist}    @{pmInterval}[2]
    @{expectValue}       Create List   -0.1   -0.5
    Verify Pm Should Be In Range    ${expectValue}     @{realpm}[0]


 *** Keywords ***
 Testbed Init
     # Initialize
     log   retrieve system relate information via CLI
     ${r0} =     Get Handle      resource=device0
     Set Suite Variable    ${r0}
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
 
     Log To Console      create a restconf rpc session
     ${rpc_session}    Set variable      rpc_session
     Create Session          ${rpc_session}    http://${tv['uv-odl-server']}/restconf/operations/network-topology:network-topology/topology/topology-netconf    auth=${auth}    debug=1
     Set Suite Variable    ${rpc_session}
         
     @{odl_sessions}    create list   ${opr_session}   ${cfg_session}   ${rpc_session}
     Set Suite Variable    ${odl_sessions}
 
     # Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']} 
     # Mount vAttella On ODL Controller    ${odl_sessions}   ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
 
     # Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
     # Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
# 
# 
# 
# 
#     #  Below code the same as Attella alarm script , include base configuration , test set inital , port/traffic/alarm check
# 
# 	Log To Console  de-provision on both device0 and device1
#	Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
#	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
# 
#     Log To Console  Load Pre Default Provision on both device0 and device1
# 	Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
#     Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
#     
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
# 
#     @{testEquipmentInfo2}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
#     ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo2}
#     Set Suite Variable    ${testSetHandle2}
# 
#     Log To Console      Init Test Equipment ${testEquipmentInfo}:      
#     Init Test Equipment  ${testSetHandle1}  100ge
#     # Init Test Equipment  ${testSetHandle1}  otu4
# 
#     Log To Console      Init Test Equipment ${testEquipmentInfo2}: 
#     Init Test Equipment  ${testSetHandle2}  100ge
#     # Init Test Equipment  ${testSetHandle2}  otu4
# 	
# 	
# 	# Set OTU FEC  ${testSetHandle1}  ${tv['uv-client_fec']}
# 	# Set OTU FEC  ${testSetHandle2}  ${tv['uv-client_fec']}
# 	# set OTU SM TTI Traces  ${testSetHandle1}  OPERATOR  ${null}  tx-operator-val
# 	# set OTU SM TTI Traces  ${testSetHandle1}  sapi  Expected  tx-sapi-val
# 	# set OTU SM TTI Traces  ${testSetHandle1}  dapi  Expected  tx-dapi-val
# 	# set OTU SM TTI Traces  ${testSetHandle1}  sapi  Received  tx-sapi-val
# 	# set OTU SM TTI Traces  ${testSetHandle1}  dapi  Received  tx-dapi-val
# 
# 	# set OTU SM TTI Traces  ${testSetHandle2}  OPERATOR  ${null}  tx-operator-val
# 	# set OTU SM TTI Traces  ${testSetHandle2}  sapi  Expected  tx-sapi-val
# 	# set OTU SM TTI Traces  ${testSetHandle2}  dapi  Expected  tx-dapi-val
# 	# set OTU SM TTI Traces  ${testSetHandle2}  sapi  Received  tx-sapi-val
# 	# set OTU SM TTI Traces  ${testSetHandle2}  dapi  Received  tx-dapi-val
# 
#     Log To Console  Provide 100ge/otu4 traffic service
#     ${client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
#     # ${client intf}       Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
#     # ${client otu intf}   Get OTU Intface Name From ODU Intface  ${client intf}
#     Set Suite Variable    ${client intf}
#     # Set Suite Variable    ${client otu intf}
# 
#     ${remote client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
#     # ${remote client intf}=  Get Ethernet Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
#     Set Suite Variable    ${remote client intf}
# 
#     ${line odu intf}     Get Line ODU Intface Name From Client Intface  ${client intf}
#     ${line otu intf}     Get OTU Intface Name From ODU Intface  ${line odu intf}
#     ${line och intf}     Get OCH Intface Name From OTU Intface  ${line otu intf}
#     ${line transc port}   Evaluate    '${line och intf}'.replace("och","port")   string
#     log    ${line transc port}
#     ${line transc port}   Evaluate    '${line transc port}'.split(":")[0]        string
#     log    ${line transc port}
#     Set Suite Variable    ${client intf}
#     Set Suite Variable    ${line odu intf}
#     Set Suite Variable    ${line otu intf}
#     Set Suite Variable    ${line och intf}
#     Set Suite Variable    ${line transc port}
# 
# 
#     ${remote line odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
#     ${remote line otu intf}=  Get OTU Intface Name From ODU Intface  ${remote line odu intf}
#     ${remote line och intf}=  Get OCH Intface Name From OTU Intface  ${remote line otu intf}
#     Set Suite Variable    ${remote line odu intf}
#     Set Suite Variable    ${remote line otu intf}
#     Set Suite Variable    ${remote line och intf}
# 
#     Create 100GE Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
#     
#     Create 100GE Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}
# 
#     # Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  qpsk
#     
#     # Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  qpsk
# 
#     Log To Console   Verify traffic won't lost packet and no alarm in system
# 
#     Wait Until Interfaces In Traffic Chain Are Alarm Free
#     
#     Verify Client Interfaces In Traffic Chain Are Up
#     
#     ${random}=  Evaluate  random.randint(1, 60)  modules=random
#     Sleep  ${random}
# 
#     Verify Interfaces In Traffic Chain Are Alarm Free
# 
#     Verify Traffic Is OK
# 
# 
# Wait Until Interfaces In Traffic Chain Are Alarm Free
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     # Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     # Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
#     Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
# 
# 
# Verify Client Interfaces In Traffic Chain Are Up
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${OPER_STATUS_ON}
#     # Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${OPER_STATUS_ON}
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${OPER_STATUS_ON}
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${OPER_STATUS_ON}
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${OPER_STATUS_ON}
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${OPER_STATUS_ON}
#     # Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${OPER_STATUS_ON}
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${OPER_STATUS_ON}
#     Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${OPER_STATUS_ON}
# 
# 
# Verify Interfaces In Traffic Chain Are Alarm Free
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}
#     # Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}
#     # Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}
#     Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}
# 
# 
# Verify Traffic Is OK
#     stop Traffic  ${testSetHandle1}
#     stop Traffic  ${testSetHandle2}
#     
#     Clear Statistic And Alarm  ${testSetHandle1}  
#     Clear Statistic And Alarm  ${testSetHandle2}
#     
#     Start Traffic  ${testSetHandle1}
#     Start Traffic  ${testSetHandle2}
#    
#     Sleep  15
#    
#     stop Traffic  ${testSetHandle1}
#     stop Traffic  ${testSetHandle2}
#     
#     @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
#     @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
#     @{EMPTY LIST}=  create list
#     ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
#    
#     Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
#     
#     Start Traffic  ${testSetHandle1}
#     Start Traffic  ${testSetHandle2}
