*** Settings ***
Documentation     This is Attella PM Scripts
...              Description  : RLI-38974: OpenROADM Device Data Model for 800G transparent transponder targeting Metro/DCI applications
...              Author : amypeng@juniper.net
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
Library         String
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
# ...              Toby Suite Teardown


*** Variables ***

@{auth}     admin    admin
${interval}  10
${timeout}   100
${OPER_STATUS_ON}           inService
${OPER_STATUS_OFF}          outOfService
@{pmInterval}   15min    24Hour   notApplicable
@{EMPTY LIST}
${ALARM CHECK TIMEOUT}      1 min 

*** Test Cases ***     
TC1   
    [Documentation]  Verify current 15min Near-end  OTU all PM statistics on otu4 Client interface
    ...              RLI38965  5.10-1    5.10-2    5.10-3
    [Tags]           Sanity   tc1   
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    10
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}     @{pmInterval}[0]
    @{expectValue}       Create List   1   10   10   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8

TC2   
    [Documentation]  Verify current 15min Near-end  OTU severelyErroredSeconds PM statistics on otu4 Client interface
    ...              RLI38965  5.10-4
    [Tags]             tc2   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    6.3E-05
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8


TC3   
    [Documentation]  Verify current 15min Far-end  OTU all PM statistics on otu4 Client interface
    ...              RLI38965  5.10-5    5.10-6    5.10-7
    [Tags]             tc3   
    @{pmEntryParmater}       Create List     erroredSeconds      farEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      farEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']} 
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BEI   20
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}     @{pmInterval}[0]
    @{expectValue}       Create List   1   20   20   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_OTU4_BEI  



TC4   
    [Documentation]  Verify current 15min Far-end  OTU severelyErroredSeconds PM statistics on otu4 Client interface
    ...              RLI38965  5.10-8
    [Tags]            tc4   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     farEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      farEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    farEnd    rx   
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  
    Retrieve Current Statistics 
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BEI     5.3E-05
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BEI  


TC5   
    [Documentation]  Verify current 15min near-end  ODU all PM statistics on odu4 Client interface
    ...              RLI38965  5.11-1    5.11-2   5.11-3
    [Tags]            tc5   
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd   rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd   rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']} 
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8   30
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}     @{pmInterval}[0]
    @{expectValue}       Create List   1   30   30   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BIP8   



TC6   
    [Documentation]  Verify current 15min Near-end  ODU severelyErroredSeconds PM statistics on odu4 Client interface
    ...              RLI38965  5.11-4
    [Tags]             tc6   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     nearEnd   rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8    6.3E-05
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8  



TC7    
    [Documentation]  Verify current 15min Far-end  ODU erroredBlockCount PM statistics on odu4 Client interface
    ...              RLI38965  5.11-5    5.11-6   5.11-7
    [Tags]             tc7  
    @{pmEntryParmater}       Create List     erroredBlockCount    farEnd    rx 
    @{pmEntryParmater2}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    farEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    farEnd    rx   
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    40
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    @{expectValue}       Create List   40  40   1   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI



TC8   
    [Documentation]  Verify current 15min Far-end  ODU severelyErroredSeconds PM statistics on odu4 Client interface
    ...              RLI38965  5.11-8 
    [Tags]            tc8   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     farEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      farEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    farEnd    rx 
    RPC Clear Pm Statistics   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   current  
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    6.3E-05
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI  


TC9   
    [Documentation]  Verify current 24Hour Near-end  OTU all PM statistics on otu4 Client interface
    ...              RLI38965  5.10-1    5.10-2    5.10-3
    [Tags]              tc9   
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']} 
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    10
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}     @{pmInterval}[1]
    @{expectValue}       Create List   1   10   10   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8



TC10   
    [Documentation]  Verify current 24Hour Near-end  OTU severelyErroredSeconds PM statistics on otu4 Client interface
    ...              RLI38965  5.10-4
    [Tags]              tc10   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8    6.3E-05
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BIP8




TC11   
    [Documentation]  Verify current 24Hour Far-end  OTU all PM statistics on otu4 Client interface
    ...              RLI38965  5.10-5    5.10-6    5.10-7
    [Tags]              tc11   
    @{pmEntryParmater}       Create List     erroredSeconds      farEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      farEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    farEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BEI   20
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}     @{pmInterval}[1]
    @{expectValue}       Create List   1   20   20   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_OTU4_BEI   



TC12   
    [Documentation]  Verify current 24Hour Far-end  OTU severelyErroredSeconds PM statistics on otu4 Client interface
    ...              RLI38965  5.10-8
    [Tags]              tc12   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     farEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      farEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    farEnd    rx   
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']} 
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_OTU4_BEI     6.3E-05
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client otu intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_OTU4_BEI  


TC13   
    [Documentation]  Verify current 24Hour near-end  ODU all PM statistics on odu4 Client interface
    ...              RLI38965  5.11-1    5.11-2    5.11-3
    [Tags]              tc13   
    @{pmEntryParmater}       Create List     erroredSeconds      nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd   rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    nearEnd   rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8   30
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}     @{pmInterval}[1]
    @{expectValue}       Create List   1   30   30   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BIP8   



TC14   
    [Documentation]  Verify current 24Hour Near-end  ODU severelyErroredSeconds PM statistics on odu4 Client interface
    ...              RLI38965  5.11-4
    [Tags]              tc14   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      nearEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     nearEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8    6.3E-05
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8  



TC15    
    [Documentation]  Verify current 24Hour Far-end  ODU erroredBlockCount PM statistics on odu4 Client interface
    ...              RLI38965  5.11-5    5.11-6    5.11-7
    [Tags]             tc15 
    @{pmEntryParmater}       Create List     erroredBlockCount    farEnd    rx 
    @{pmEntryParmater2}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater3}       Create List     erroredSeconds    farEnd    rx
    @{pmEntryParmater4}       Create List      severelyErroredSeconds    farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    nearEnd    rx   
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']} 
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    40
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    @{expectValue}       Create List   40   40   1   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI



TC16   
    [Documentation]  Verify current 24Hour Far-end  ODU severelyErroredSeconds PM statistics on odu4 Client interface
    ...              RLI38965  5.11-8
    [Tags]           Sanity   tc16   
    @{pmEntryParmater}       Create List      severelyErroredSeconds     farEnd    rx 
    @{pmEntryParmater2}       Create List    erroredBlockCount      farEnd    rx
    @{pmEntryParmater3}       Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater4}       Create List     erroredSeconds     farEnd    rx
    @{pmEntryParmaterlist}       Create List   ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}       Create List     preFECCorrectedErrors    farEnd    rx  
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    6.3E-05
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}    ${client intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI  






*** Keywords ***
Retrieve Current Statistics
    [Documentation]   Retrieve Detail history pm data 
    ${r0} =     Get Handle      resource=device0 
    &{payload}   create_dictionary   current-pm-list=${null}
    ${sDatestring}=    Execute shell command on device     device=${r0}       command=date
    log to console    ${sDatestring}
    sleep  5
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8  
    log   ${resp_content}


Test Bed Init
    Set Log Level  DEBUG
    Log To Console      create a restconf operational session
    
    @{dut_list}    create list    device0  device1
    Preconfiguration netconf feature    @{dut_list}

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
	Log   ${odl_sessions}    
	
    ${client intf}       Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    ${client otu intf}   Get OTU Intface Name From ODU Intface  ${client intf}
    ${line odu intf}     Get Line ODU Intface Name From Client Intface  ${client intf}
    ${line otu intf}     Get OTU Intface Name From ODU Intface  ${line odu intf}
    ${line och intf}     Get OCH Intface Name From OTU Intface  ${line otu intf}
    Set Suite Variable    ${client intf}
    Set Suite Variable    ${client otu intf}
    Set Suite Variable    ${line odu intf}
    Set Suite Variable    ${line otu intf}
    Set Suite Variable    ${line och intf}
    
    ${remote client intf}      Get Otu4 Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    ${remote client otu intf}  Get OTU Intface Name From ODU Intface  ${remote client intf}
    ${remote line odu intf}    Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote line otu intf}    Get OTU Intface Name From ODU Intface  ${remote line odu intf}
    ${remote line och intf}    Get OCH Intface Name From OTU Intface  ${remote line otu intf}
    Set Suite Variable    ${remote client intf}
    Set Suite Variable    ${remote client otu intf}
    Set Suite Variable    ${remote line odu intf}
    Set Suite Variable    ${remote line otu intf}
    Set Suite Variable    ${remote line och intf}
    
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}

	Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}
    
    Load Pre Default Provision  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
    Load Pre Default Provision  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}

    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraparam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    Log To Console      Init Test Equipment ${testEquipmentInfo}: protocol otu4
    Init Test Equipment  ${testSetHandle1}  otu4
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraparam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
    Log To Console      Init Test Equipment ${testEquipmentInfo}: protocol otu4
    Init Test Equipment  ${testSetHandle2}  otu4	

    Log To Console     Setting TTI Info	    
    Set OTU FEC            ${testSetHandle1}  ${tv['uv-client_fec']}
    Set OTU FEC            ${testSetHandle2}  ${tv['uv-client_fec']}  
    set OTU SM TTI Traces  ${testSetHandle1}  OPERATOR  ${null}      tx-operator-val
    set OTU SM TTI Traces  ${testSetHandle1}  sapi      Expected     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle1}  dapi      Expected     tx-dapi-val
    set OTU SM TTI Traces  ${testSetHandle1}  sapi      Received     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle1}  dapi      Received     tx-dapi-val

    set ODU PM TTI Traces  ${testSetHandle1}  OPERATOR  ${null}  tx-operator-val
    set ODU PM TTI Traces  ${testSetHandle1}  sapi  Expected  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle1}  dapi  Expected  tx-dapi-val
    set ODU PM TTI Traces  ${testSetHandle1}  sapi  Received  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle1}  dapi  Received  tx-dapi-val
	
	

    set OTU SM TTI Traces  ${testSetHandle2}  OPERATOR  ${null}      tx-operator-val
    set OTU SM TTI Traces  ${testSetHandle2}  sapi      Expected     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle2}  dapi      Expected     tx-dapi-val
    set OTU SM TTI Traces  ${testSetHandle2}  sapi      Received     tx-sapi-val
    set OTU SM TTI Traces  ${testSetHandle2}  dapi      Received     tx-dapi-val  

    set ODU PM TTI Traces  ${testSetHandle2}  OPERATOR  ${null}  tx-operator-val
    set ODU PM TTI Traces  ${testSetHandle2}  sapi  Expected  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle2}  dapi  Expected  tx-dapi-val
    set ODU PM TTI Traces  ${testSetHandle2}  sapi  Received  tx-sapi-val
    set ODU PM TTI Traces  ${testSetHandle2}  dapi  Received  tx-dapi-val
	
    
    Log To Console   Start Traffic
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}

    
    Log To Console   Create Service 
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}


    #Wait Until Interfaces In Traffic Chain Are Alarm Free

    #Log To Console   Verify Traffic Is OK
    #Verify Traffic Is OK

    #Verify Client Interfaces In Traffic Chain Are Up

    Sleep    30

    
Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service
    
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}

	Log To Console  de-provision on both device0 and device1
    Delete all interface  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}
	Delete all interface  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    
    

 
 
 

    
Verify Traffic Is OK
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    Clear Statistic And Alarm  ${testSetHandle1}  
    Clear Statistic And Alarm  ${testSetHandle2}
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  15
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
   
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
    
    [Teardown]  Run Keywords  Start Traffic  ${testSetHandle1}  AND  Start Traffic  ${testSetHandle2}

    
    
Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}
    #Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}
    
Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    #Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


    
Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${OPER_STATUS_ON}
    #Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${OPER_STATUS_ON}

	
Recover OTU TTI on Attella
    [Documentation]   Retrieve system configuration and state information
    [Arguments]       ${InterfaceName}     
    &{intf}           create dictionary   interface-name=${InterfaceName}   otu-tim-detect-mode=SAPI-and-DAPI  otu-expected-sapi=tx-sapi-val     otu-expected-dapi=tx-dapi-val   otu-tx-sapi=tx-sapi-val      otu-tx-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}

	
Recover ODU TTI on Attella
    [Documentation]   Retrieve system configuration and state information
    [Arguments]       ${InterfaceName}     
    &{intf}           create dictionary   interface-name=${InterfaceName}   odu-tim-detect-mode=SAPI-and-DAPI   odu-expected-sapi=tx-sapi-val     odu-expected-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}	
