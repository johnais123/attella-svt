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
Resource        lib/testSet.robot
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
    [Documentation]  Retrieve opticalPowerOutput pm statistics on Local line port
    ...              TC 5.9-1 RLI-38966
    [Tags]           Sanity   tc1  
    @{pmEntryParmater}        Create List       opticalPowerOutput        nearEnd      tx  
    @{pmEntryParmaterlist}    Create List       ${pmEntryParmater}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    
    ${och_tx_power}   evaluate    random.randint(-12,2)      random,string		
    ${och_tx_power}   evaluate    str(${och_tx_power})	
    Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${line och intf}    ${och_tx_power}
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}   ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[2]
    Log           ${realpm} 
    @{expectValue}       Create List   ${och_tx_power}+1    ${och_tx_power}-1
    log           ${expectValue}	
    Verify Pm Should Be In Range    ${expectValue}     @{realpm}[0]	 
    [Teardown]  	Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${line och intf}  	


TC2
    [Documentation]  Retrieve opticalPowerOutputMin current 15Min  pm statistics on Local line port 
    ...              TC 5.9-2 RLI-38966
    [Tags]           Advance  tc2  
    @{pmEntryParmater1}        Create List       opticalPowerOutputMin        nearEnd      tx  
    @{pmEntryParmater2}        Create List       opticalPowerOutputAvg        nearEnd      tx 
    @{pmEntryParmater3}        Create List       opticalPowerOutputMax        nearEnd      tx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerOutput           nearEnd      tx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0] 
    Log   ${realpm1}
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    Log   ${realpm_float}	
    ${value} =  evaluate  min(@{realpm_float}) 
    Log   ${value}	
    ${min_value}  set variable   @{realpm_float}[0]
    Log   ${min_value}
    Run keyword if 	     "${min_value}"=="${value}"    Log    opticalPowerOutputMin's value is the minimum , that meet the expectation 
    
    
TC3    
    [Documentation]  Retrieve opticalPowerOutputMin current 24Hour pm statistics on Local line port 
    ...              TC 5.9-3   RLI-38966
    [Tags]           Advance  tc3  
    @{pmEntryParmater1}        Create List       opticalPowerOutputMin        nearEnd      tx  
    @{pmEntryParmater2}        Create List       opticalPowerOutputAvg        nearEnd      tx 
    @{pmEntryParmater3}        Create List       opticalPowerOutputMax        nearEnd      tx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerOutput           nearEnd      tx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0] 
    Log   ${realpm1}
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    Log   ${realpm_float}	
    ${value} =  evaluate  min(@{realpm_float}) 
    Log   ${value}	
    ${min_value}  set variable   @{realpm_float}[0]
    Log   ${min_value}
    Run keyword if 	     "${min_value}"=="${value}"    Log    opticalPowerOutputMin's value is the minimum , that meet the expectation 
    
    	
TC4    
    [Documentation]  Retrieve opticalPowerOutputMax current 15Min pm statistics on Local line port 
    ...              TC 5.9-4   RLI-38966
    [Tags]           Advance  tc4  
    @{pmEntryParmater1}        Create List       opticalPowerOutputMin        nearEnd      tx  
    @{pmEntryParmater2}        Create List       opticalPowerOutputAvg        nearEnd      tx 
    @{pmEntryParmater3}        Create List       opticalPowerOutputMax        nearEnd      tx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    
    @{pmEntryParmater}         Create List       opticalPowerOutput           nearEnd      tx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  max(@{realpm_float})  
    ${max_value}  set variable   @{realpm_float}[2]
    Run keyword if 	     "${max_value}"=="${value}"    Log    opticalPowerOutputMax's value is the maxmum , that meet the expectation 
    
    
    
TC5    
    [Documentation]  Retrieve opticalPowerOutputMax pm current 24Hour statistics on Local line port 
    ...              TC 5.9-5   RLI-38966
    [Tags]           Advance  tc5  
    @{pmEntryParmater1}        Create List       opticalPowerOutputMin        nearEnd      tx  
    @{pmEntryParmater2}        Create List       opticalPowerOutputAvg        nearEnd      tx 
    @{pmEntryParmater3}        Create List       opticalPowerOutputMax        nearEnd      tx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    
    @{pmEntryParmater}         Create List       opticalPowerOutput           nearEnd      tx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  max(@{realpm_float})  
    ${max_value}  set variable   @{realpm_float}[2]
    Run keyword if 	     "${max_value}"=="${value}"    Log    opticalPowerOutputMax's value is the maxmum , that meet the expectation 
    
    
TC6    
    [Documentation]  Retrieve opticalPowerOutputAvg current 15Min  pm statistics on Local line port 
    ...              TC 5.9-6   RLI-38966 
    [Tags]           Advance  tc6  
    @{pmEntryParmater1}        Create List       opticalPowerOutputMin        nearEnd      tx  
    @{pmEntryParmater2}        Create List       opticalPowerOutputAvg        nearEnd      tx 
    @{pmEntryParmater3}        Create List       opticalPowerOutputMax        nearEnd      tx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    
    @{pmEntryParmater}         Create List       opticalPowerOutput           nearEnd      tx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${min_value}  set variable   @{realpm_float}[0]
    ${max_value}  set variable   @{realpm_float}[2]
    ${avg_value}  set variable   @{realpm_float}[1]
    Run keyword if 	     "${min_value}"<"${avg_value}"<"${max_value}"  Log    opticalPowerOutputAvg's value between the min and the max , that meet the expectation 	
    
    
TC7    
    [Documentation]  Retrieve opticalPowerOutputAvg current 24Hour pm statistics on Local line port 
    ...              TC 5.9-7   RLI-38966
    [Tags]           Advance  tc7  
    @{pmEntryParmater1}        Create List       opticalPowerOutputMin        nearEnd      tx  
    @{pmEntryParmater2}        Create List       opticalPowerOutputAvg        nearEnd      tx 
    @{pmEntryParmater3}        Create List       opticalPowerOutputMax        nearEnd      tx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    
    @{pmEntryParmater}         Create List       opticalPowerOutput           nearEnd      tx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device0__re0__mgt-ip']}    ${line port}    ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${min_value}  set variable   @{realpm_float}[0]
    ${max_value}  set variable   @{realpm_float}[2]
    ${avg_value}  set variable   @{realpm_float}[1]
    Run keyword if 	     "${min_value}"<"${avg_value}"<"${max_value}"  Log    opticalPowerOutputAvg's value between the min and the max , that meet the expectation 
    
    
TC8    
    [Documentation]  Retrieve totalOpticalPowerInput pm statistics on remote line port  
    ...              TC 5.9-8   RLI-38966  
    [Tags]           Sanity   tc8  
    @{pmEntryParmater}        Create List       totalOpticalPowerInput        nearEnd      rx  
    @{pmEntryParmaterlist}    Create List       ${pmEntryParmater}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    ${och_tx_power}           evaluate    random.randint(-12,2)      random,string		
    ${och_tx_power}           evaluate    str(${och_tx_power})
    Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${line och intf}    ${och_tx_power}
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist}  @{pmInterval}[2]
    Log   ${realpm} 
    Sleep  10
    @{expectValue}       Create List   ${och_tx_power}+1    ${och_tx_power}-1
    Verify Pm Should Be In Range    ${expectValue}     @{realpm}[0]	
    [Teardown]  	Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${line och intf}  	
    
    
TC9    
    [Documentation]  Retrieve totalOpticalPowerInputMin current 15Min  pm statistics on Remote line port 
    ...              TC 5.9-9   RLI-38966 
    [Tags]           Advance  tc9  
    @{pmEntryParmater1}        Create List       totalOpticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       totalOpticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       totalOpticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       totalOpticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  min(@{realpm_float})  
    ${min_value}  set variable   @{realpm_float}[0]
    Run keyword if 	     "${min_value}"=="${value}"    Log    totalOpticalPowerInputMin's value is the minimum , that meet the expectation 	
    
    
TC10    
    [Documentation]  Retrieve totalOpticalPowerInputMin current 24Hour pm statistics on Remote line port 
    ...              TC 5.9-10   RLI-38966
    [Tags]           Advance  tc10  
    @{pmEntryParmater1}        Create List       totalOpticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       totalOpticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       totalOpticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       totalOpticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  min(@{realpm_float})  
    ${min_value}  set variable   @{realpm_float}[0]
    Run keyword if 	     "${min_value}"=="${value}"    Log    totalOpticalPowerInputMin's value is the minimum , that meet the expectation 	
    
    
TC11    
    [Documentation]  Retrieve totalOpticalPowerInputMax current 15Min  pm statistics on Remote line port 
    ...              TC 5.9-11   RLI-38966
    [Tags]           Advance  tc11  
    @{pmEntryParmater1}        Create List       totalOpticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       totalOpticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       totalOpticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       totalOpticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  max(@{realpm_float})  
    ${max_value}  set variable   @{realpm_float}[2]
    Run keyword if 	     "${max_value}"=="${value}"    Log    totalOpticalPowerInputMax's value is the maxmum , that meet the expectation 
    
    
    
TC12    
    [Documentation]  Retrieve totalOpticalPowerInputMax current 24Hour pm statistics on Remote line port 
    ...              TC 5.9-12   RLI-38966
    [Tags]           Advance  tc12  
    @{pmEntryParmater1}        Create List       totalOpticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       totalOpticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       totalOpticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       totalOpticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  max(@{realpm_float})  
    ${max_value}  set variable   @{realpm_float}[2]
    Run keyword if 	     "${max_value}"=="${value}"    Log    totalOpticalPowerInputMax's value is the maxmum , that meet the expectation 	
    
    
TC13    
    [Documentation]  Retrieve totalOpticalPowerInputAvg current 15Min  pm statistics on Remote line port 
    ...              TC 5.9-13   RLI-38966
    [Tags]           Advance  tc13  
    @{pmEntryParmater1}        Create List       totalOpticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       totalOpticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       totalOpticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       totalOpticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${min_value}  set variable   @{realpm_float}[0]
    ${max_value}  set variable   @{realpm_float}[2]
    ${avg_value}  set variable   @{realpm_float}[1]
    Run keyword if 	     "${min_value}"<"${avg_value}"<"${max_value}"  Log    totalOpticalPowerInputAvg's value between the min and the max , that meet the expectation	
    
    
TC14    
    [Documentation]  Retrieve totalOpticalPowerInputAvg current 24Hour pm statistics on Remote line port 
    ...              TC 5.9-14   RLI-38966
    [Tags]           Advance  tc14  
    @{pmEntryParmater1}        Create List       totalOpticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       totalOpticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       totalOpticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       totalOpticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line port}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${min_value}  set variable   @{realpm_float}[0]
    ${max_value}  set variable   @{realpm_float}[2]
    ${avg_value}  set variable   @{realpm_float}[1]
    Run keyword if 	     "${min_value}"<"${avg_value}"<"${max_value}"  Log    totalOpticalPowerInputAvg's value between the min and the max , that meet the expectation	
    
    
TC15    
    [Documentation]  Retrieve 15min opticalPowerInput pm statistics on remote line port 
    ...              TC 5.9-15   RLI-38966
    [Tags]           Sanity   tc15  
    @{pmEntryParmater}        Create List       opticalPowerInput        nearEnd      rx  
    @{pmEntryParmaterlist}    Create List   ${pmEntryParmater}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    ${och_tx_power}   evaluate  random.randint(-12,2)      random,string		
    ${och_tx_power}             evaluate    str(${och_tx_power})
    Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${line och intf}    ${och_tx_power}
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist}  @{pmInterval}[2]
    Log   ${realpm} 
    @{expectValue}       Create List   ${och_tx_power}+1    ${och_tx_power}-1
    Verify Pm Should Be In Range    ${expectValue}     @{realpm}[0]	
    [Teardown]  	Modify transmit-power for OCH interface    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${line och intf} 
    
    
TC16    
    [Documentation]  Retrieve opticalPowerInputMin current 15Min  pm statistics on Remote line port 
    ...              TC 5.9-16   RLI-38966 
    [Tags]           Advance  tc16  
    @{pmEntryParmater1}        Create List       opticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       opticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       opticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    Log   ${realpm1}
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 
    Log   ${realpm_float}	
    ${value} =  evaluate  min(@{realpm_float}) 
    Log   ${value}		
    ${min_value}  set variable   @{realpm_float}[0]
    Log   ${min_value}		
    Run keyword if 	     "${min_value}"=="${value}"    Log    opticalPowerInputMin's value is the minimum , that meet the expectation	
    
    
TC17    
    [Documentation]  Retrieve opticalPowerInputMin current 24Hour pm statistics on Remote line port 
    ...              TC 5.9-17   RLI-38966
    [Tags]           Advance  tc17  
    @{pmEntryParmater1}        Create List       opticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       opticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       opticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    Log   ${realpm1}
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 
    Log   ${realpm_float}	
    ${value} =  evaluate  min(@{realpm_float}) 
    Log   ${value}		
    ${min_value}  set variable   @{realpm_float}[0]
    Log   ${min_value}		
    Run keyword if 	     "${min_value}"=="${value}"    Log    opticalPowerInputMin's value is the minimum , that meet the expectation		
    
    
TC18    
    [Documentation]  Retrieve opticalPowerInputMax current 15Min  pm statistics on Remote line port 
    ...              TC 5.9-18   RLI-38966 
    [Tags]           Advance  tc18  
    @{pmEntryParmater1}        Create List       opticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       opticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       opticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  max(@{realpm_float})  
    ${max_value}  set variable   @{realpm_float}[2]
    Run keyword if 	     "${max_value}"=="${value}"    Log    opticalPowerInputMax's value is the maxmum , that meet the expectation 
    
    
TC19    
    [Documentation]  Retrieve opticalPowerInputMax current 24Hour pm statistics on Remote line port 
    ...              TC 5.9-19   RLI-38966
    [Tags]           Advance  tc19  
    @{pmEntryParmater1}        Create List       opticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       opticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       opticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${value} =  evaluate  max(@{realpm_float})  
    ${max_value}  set variable   @{realpm_float}[2]
    Run keyword if 	     "${max_value}"=="${value}"    Log    opticalPowerInputMax's value is the maxmum , that meet the expectation 
    
    
    
TC20    
    [Documentation]  Retrieve opticalPowerInputAvg current 15Min pm statistics on Remote line port 
    ...              TC 5.9-20   RLI-38966
    [Tags]           Advance  tc20  
    @{pmEntryParmater1}        Create List       opticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       opticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       opticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist}  @{pmInterval}[0]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${min_value}  set variable   @{realpm_float}[0]
    ${max_value}  set variable   @{realpm_float}[2]
    ${avg_value}  set variable   @{realpm_float}[1]
    Run keyword if 	     "${min_value}"<"${avg_value}"<"${max_value}"  Log    opticalPowerInputAvg's value between the min and the max , that meet the expectation	
    
    
TC21    
    [Documentation]  Retrieve opticalPowerInputAvg current 24Hour pm statistics on Remote line port 
    ...              TC 5.9-21   RLI-38966
    [Tags]           Advance  tc21  
    @{pmEntryParmater1}        Create List       opticalPowerInputMin        nearEnd      rx  
    @{pmEntryParmater2}        Create List       opticalPowerInputAvg        nearEnd      rx 
    @{pmEntryParmater3}        Create List       opticalPowerInputMax        nearEnd      rx 	
    @{pmEntryParmaterlist}     Create List       ${pmEntryParmater1}   ${pmEntryParmater2}   ${pmEntryParmater3}
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm1}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist}  @{pmInterval}[1]
    Log   ${realpm1}
    	
    @{pmEntryParmater}         Create List       opticalPowerInput           nearEnd      rx 	
    @{pmEntryParmaterlist1}    Create List      ${pmEntryParmater}  
    Ensure Pm Statistics In the Same Bin During Testing Pm    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  current 
    @{realpm2}=    Get Current Spefic Pm Statistic   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}    ${remote line och intf}   ${pmEntryParmaterlist1}  @{pmInterval}[2]	
    Log   ${realpm2}	
    
    Append to list  ${realpm1}    @{realpm2}[0]  
    @{realpm_float}             evaluate   list(map(float, @{realpm1})) 	
    ${min_value}  set variable   @{realpm_float}[0]
    ${max_value}  set variable   @{realpm_float}[2]
    ${avg_value}  set variable   @{realpm_float}[1]
    Run keyword if 	     "${min_value}"<"${avg_value}"<"${max_value}"  Log    opticalPowerInputAvg's value between the min and the max , that meet the expectation		
	
	
	

TC22
    [Documentation]  Retrieve current 15min Near-end  ES/SES pm statistics on Remote line port  
    ...              TC 5.10-5/5.10-6   RLI-38966
    [Tags]           Sanity   tc22  
    Log              Modify the tx-sapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm

    @{pmEntryParmater1}         Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}         Create List      erroredSeconds             nearEnd    rx
    @{pmEntryParmaterlist}      Create List      ${pmEntryParmater1}         ${pmEntryParmater2}   
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']} 
    Retrieve Current Statistics 	
	

    Log                 Modify the tx-sapi value for OTU4 on local line port
    &{intf}             create dictionary   interface-name=${line otu intf}    otu-tx-sapi=012345
    @{interface_info}   create list  ${intf}    
    &{dev_info}         create_dictionary   interface=${interface_info}       
    &{payload}          create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}

    Log                 Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Log                 Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    ${remote line otu intf}  ${expectedAlarms_remote_line}

    Sleep   10
    @{realpm}=        Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line otu intf}   ${pmEntryParmaterlist}     @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    [Teardown]  	  Recover OTU TTI on Attella    ${line otu intf}  
	


TC23
    [Documentation]  Retrieve current 24hour Near-end  ES/SES pm statistics on Remote line port  
    ...              TC 5.10-5/5.10-6   RLI-38966
    [Tags]           Sanity   tc23  
    Log              Modify the tx-sapi value for OTU4 on Lx,Ly will raise TTIM alarm/Lx will raise OUT4-BDI alarm and Test 2 will raise ODU4-AIS alarm

    @{pmEntryParmater1}         Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}         Create List      erroredSeconds             nearEnd    rx
    @{pmEntryParmaterlist}      Create List      ${pmEntryParmater1}         ${pmEntryParmater2}   
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']} 
    Retrieve Current Statistics 	
	

    Log                 Modify the tx-sapi value for OTU4 on local line port
    &{intf}             create dictionary   interface-name=${line otu intf}    otu-tx-sapi=012345
    @{interface_info}   create list  ${intf}    
    &{dev_info}         create_dictionary   interface=${interface_info}       
    &{payload}          create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}

    Log                 Wait a random time to keep the alarm stable on Attella
    ${random}=  Evaluate  random.randint(1, 60)  modules=random
    Sleep  ${random}
    
    Log                 Verify TTIM was raised on remote line port
    @{expectedAlarms_remote_line}      Create List       Trail Trace Identifier Mismatch    
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}    ${remote line otu intf}  ${expectedAlarms_remote_line}

    Sleep   10
    @{realpm}=        Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line otu intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line otu intf}   ${pmEntryParmaterlist}     @{pmInterval}[1]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    [Teardown]  	  Recover OTU TTI on Attella    ${line otu intf} 	



TC24   
    [Documentation]  Verify current 15min near-end  ODU all PM statistics on remote odu4 line interface
    ...              TC 5.11-1/5.11-2/5.11-3/5.11-4   RLI-38966
    [Tags]           Advance  tc24  
    @{pmEntryParmater}          Create List     erroredSeconds           nearEnd    rx 
    @{pmEntryParmater2}         Create List     erroredBlockCount        nearEnd    rx
    @{pmEntryParmater3}         Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}         Create List     severelyErroredSeconds   nearEnd    rx
    @{pmEntryParmaterlist}      Create List     ${pmEntryParmater}     ${pmEntryParmater2}    ${pmEntryParmater3}     ${pmEntryParmater4}
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device1__re0__mgt-ip']} 
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8   30
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}     @{pmInterval}[0]
    @{expectValue}       Create List   1   30   30   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BIP8   



TC25   
    [Documentation]  Verify current 15min Near-end  ODU severelyErroredSeconds PM statistics on remote odu4 line interface
    ...              TC 5.11-1/5.11-2/5.11-3/5.11-4   RLI-38966
    [Tags]           Advance  tc25   
    @{pmEntryParmater}           Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}          Create List      erroredBlockCount          nearEnd    rx
    @{pmEntryParmater3}          Create List      backgroundBlockErrors      nearEnd    rx
    @{pmEntryParmater4}          Create List      erroredSeconds             nearEnd    rx
    @{pmEntryParmaterlist}       Create List      ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8    6.3E-05
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic       ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8  



TC26    
    [Documentation]  Verify current 15min Far-end  ODU erroredBlockCount PM statistics on remote odu4 Line interface
    ...              TC 5.11-5/5.11-6/5.11-7/5.11-8   RLI-38966
    [Tags]           Sanity   tc26  
    @{pmEntryParmater}          Create List     erroredBlockCount         farEnd    rx 
    @{pmEntryParmater2}         Create List     backgroundBlockErrors     farEnd    rx
    @{pmEntryParmater3}         Create List     erroredSeconds            farEnd    rx
    @{pmEntryParmater4}         Create List     severelyErroredSeconds    farEnd    rx
    @{pmEntryParmaterlist}      Create List     ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    40
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    @{expectValue}       Create List   40  40   1   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI



TC27   
    [Documentation]  Verify current 15min Far-end  ODU severelyErroredSeconds PM statistics on remote odu4 Line interface
    ...              TC 5.11-5/5.11-6/5.11-7/5.11-8   RLI-38966
    [Tags]           Advance  tc27   
    @{pmEntryParmater}          Create List      severelyErroredSeconds     farEnd    rx 
    @{pmEntryParmater2}         Create List      erroredBlockCount          farEnd    rx
    @{pmEntryParmater3}         Create List      backgroundBlockErrors      farEnd    rx
    @{pmEntryParmater4}         Create List      erroredSeconds             farEnd    rx
    @{pmEntryParmaterlist}      Create List      ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    RPC Clear Pm Statistics   ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   current  
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}
    Retrieve Current Statistics     
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    6.3E-05
    Sleep   10
    Retrieve Current Statistics 
    @{realpm}=    Get Current Spefic Pm Statistic       ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[0]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI  

TC28   
    [Documentation]  Verify current 24Hour near-end  ODU all PM statistics on remote odu4 Line interface
    ...              TC 5.11-1/5.11-2/5.11-3/5.11-4   RLI-38966
    [Tags]           Sanity   tc128   
    @{pmEntryParmater}          Create List     erroredSeconds           nearEnd    rx 
    @{pmEntryParmater2}         Create List     erroredBlockCount        nearEnd    rx
    @{pmEntryParmater3}         Create List     backgroundBlockErrors    nearEnd    rx
    @{pmEntryParmater4}         Create List     severelyErroredSeconds   nearEnd    rx
    @{pmEntryParmaterlist}      Create List     ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    @{ignorePmEntryParmater}    Create List     preFECCorrectedErrors    nearEnd    rx 
    Ensure Pm Statistics In the Same Bin During Testing Pm     ${odl_sessions}    ${tv['device1__re0__mgt-ip']}
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8   30
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}     @{pmInterval}[1]
    @{expectValue}       Create List   1   30   30   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BIP8   



TC29   
    [Documentation]  Verify current 24Hour Near-end  ODU severelyErroredSeconds PM statistics on remote odu4 Line interface
    ...              TC 5.11-1/5.11-2/5.11-3/5.11-4   RLI-38966
    [Tags]           Advance  tc29   
    @{pmEntryParmater}          Create List      severelyErroredSeconds     nearEnd    rx 
    @{pmEntryParmater2}         Create List      erroredBlockCount          nearEnd    rx
    @{pmEntryParmater3}         Create List      backgroundBlockErrors      nearEnd    rx
    @{pmEntryParmater4}         Create List      erroredSeconds             nearEnd    rx
    @{pmEntryParmaterlist}      Create List      ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8    6.3E-05
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=       Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}   ${pmEntryParmaterlist}    @{pmInterval}[1]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}   ERROR_OTU4_ODU4_BIP8  



TC30    
    [Documentation]  Verify current 24Hour Far-end  ODU erroredBlockCount PM statistics on remote odu4 Line interface
    ...              TC 5.11-5/5.11-6/5.11-7/5.11-8   RLI-38966
    [Tags]           Sanity   tc30 
    @{pmEntryParmater}          Create List     erroredBlockCount        farEnd    rx 
    @{pmEntryParmater2}         Create List     backgroundBlockErrors    farEnd    rx
    @{pmEntryParmater3}         Create List     erroredSeconds           farEnd    rx
    @{pmEntryParmater4}         Create List     severelyErroredSeconds   farEnd    rx
    @{pmEntryParmaterlist}      Create List     ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}    ${pmEntryParmater4}
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']} 
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    40
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    @{expectValue}       Create List   40   40   1   0
    Verify Pm Should Be Equals    @{expectValue}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI



TC31   
    [Documentation]  Verify current 24Hour Far-end  ODU severelyErroredSeconds PM statistics on remote odu4 Line interface
    ...              TC 5.11-5/5.11-6/5.11-7/5.11-8   RLI-38966
    [Tags]           Advance  tc31   
    @{pmEntryParmater}          Create List      severelyErroredSeconds     farEnd    rx 
    @{pmEntryParmater2}         Create List      erroredBlockCount          farEnd    rx
    @{pmEntryParmater3}         Create List      backgroundBlockErrors      farEnd    rx
    @{pmEntryParmater4}         Create List      erroredSeconds             farEnd    rx
    @{pmEntryParmaterlist}      Create List      ${pmEntryParmater}    ${pmEntryParmater2}   ${pmEntryParmater3}   ${pmEntryParmater4}
    @{ignorePmEntryParmater}    Create List     preFECCorrectedErrors    farEnd    rx  
    Ensure Pm Statistics In the Same Bin During Testing Pm   ${odl_sessions}    ${tv['device1__re0__mgt-ip']}
    Retrieve Current Statistics    
    Start Inject Error On Test Equipment  ${testSetHandle1}   ERROR_OTU4_ODU4_BEI    6.3E-05
    Sleep   10
    Retrieve Current Statistics
    @{realpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}    ${pmEntryParmaterlist}    @{pmInterval}[1]
    Sleep   5    
    @{nextrealpm}=    Get Current Spefic Pm Statistic   ${odl_sessions}   ${tv['device1__re0__mgt-ip']}    ${remote line odu intf}   ${pmEntryParmaterlist}    @{pmInterval}[0]                 
    Verify Pm Should Be Increased   @{nextrealpm}[0]     @{realpm}[0]
    Verify others Pm Statistic shoule not be changed    @{pmInterval}[1]  

    [Teardown]  Stop Inject Error On Test Equipment     ${testSetHandle1}    ERROR_OTU4_ODU4_BEI     
	


 *** Keywords ***
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
	${line port}          evaluate        str('${line och intf}')[0:-2].replace('och','port')	
    Set Suite Variable    ${client intf}
    Set Suite Variable    ${client otu intf}
    Set Suite Variable    ${line odu intf}
    Set Suite Variable    ${line otu intf}
    Set Suite Variable    ${line och intf}	
    Set Suite Variable    ${line port}
	
    
    ${remote client intf}      Get Otu4 Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    ${remote client otu intf}  Get OTU Intface Name From ODU Intface  ${remote client intf}
    ${remote line odu intf}    Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote line otu intf}    Get OTU Intface Name From ODU Intface  ${remote line odu intf}
    ${remote line och intf}    Get OCH Intface Name From OTU Intface  ${remote line otu intf}
    ${remote line port}          evaluate        str('${remote line och intf}')[0:-2].replace('och','port')	
    Set Suite Variable    ${remote client intf}
    Set Suite Variable    ${remote client otu intf}
    Set Suite Variable    ${remote line odu intf}
    Set Suite Variable    ${remote line otu intf}
    Set Suite Variable    ${remote line och intf}
    Set Suite Variable    ${remote line port}
    
    
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']} 
    Mount vAttella On ODL Controller    ${odl_sessions}   ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${tv['uv-odl-timeout']}    ${tv['uv-odl-interval']}   ${tv['device1__re0__mgt-ip']}
    
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
	
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}

    
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   ${tv['uv-frequency']}  ${tv['uv-service-description']}  ${tv['uv-client_fec']}

    Wait Until Interfaces In Traffic Chain Are Alarm Free

    Log To Console   Verify Traffic Is OK
    Verify Traffic Is OK

    Verify Client Interfaces In Traffic Chain Are Up

    
Test Bed Teardown
    [Documentation]  Test Bed Teardown
    Log To Console  Remove Service   
    Remove OTU4 Service   ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}
    Remove OTU4 Service   ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}
    
    Log To Console  Stopping Traffic  
    Stop Traffic  ${testSetHandle1}
    Stop Traffic  ${testSetHandle2}
    
    
Verify Interfaces In Traffic Chain Are Alarm Free
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}
    Verify Alarms On Resource  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}
    
Wait Until Interfaces In Traffic Chain Are Alarm Free
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}
    Wait Until Verify Alarms On Resource Succeeds  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${EMPTY LIST}  ${ALARM CHECK TIMEOUT}


    
Verify Client Interfaces In Traffic Chain Are Up
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}             ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client otu intf}         ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line odu intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line otu intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${line och intf}           ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}      ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client otu intf}  ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line odu intf}    ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line otu intf}    ${OPER_STATUS_ON}
    Verify Interface Operational Status  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote line och intf}    ${OPER_STATUS_ON}


Modify transmit-power for OCH interface
    [Documentation]   Modify transmit-power for OCH interface
    ...                    Args:
    ...                    |- odl_sessions : ODL server
    ...                    |- node : device0 or device1
    ...                    |- strOchIntf  : OCH interface	
	[Arguments]            ${odl_sessions}  ${node}   ${line och intf}   ${och_tx_power}=0
    Log                    Modify och interface tx_power
    &{strOchIntf}          create dictionary   interface-name=${line och intf}   transmit-power=${och_tx_power}
    @{interface_info}      create list     ${strOchIntf}    
    &{dev_info}            create_dictionary   interface=${interface_info}       
    &{payload}             create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Request And Verify Status Of Response Is OK    ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${payload}
	Wait For  10
	
	
Recover OTU TTI on Attella
    [Documentation]   Retrieve system configuration and state information
    [Arguments]       ${InterfaceName}     
    &{intf}           create dictionary   interface-name=${InterfaceName}   otu-tim-detect-mode=SAPI-and-DAPI  otu-expected-sapi=tx-sapi-val     otu-expected-dapi=tx-dapi-val   otu-tx-sapi=tx-sapi-val      otu-tx-dapi=tx-dapi-val
    @{interface_info}    create list  ${intf}    
    &{dev_info}      create_dictionary   interface=${interface_info}       
    &{payload}       create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}  ${payload}
	
	
Retrieve Current Statistics
    [Documentation]   Retrieve Detail history pm data 
    ${r0} =     Get Handle      resource=device0 
    &{payload}   create_dictionary   current-pm-list=${null}
    ${sDatestring}=    Execute shell command on device     device=${r0}       command=date
    log to console    ${sDatestring}
    Wait For  5
    ${resp}=  Send Get Request And Verify Status Of Response Is OK  ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload}
    ${resp_content}=    Decode Bytes To String   ${resp.content}    UTF-8  
    log   ${resp_content}

	
