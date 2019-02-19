*** Settings ***
Documentation     These are keywords for test equipments provision Automation script 
...               Author: Jack

Library         testSet.py


*** Variables ***


*** Keywords ***
Get Test Equipment Handle
	[Documentation]   Get a Test Equipment Handle
    [Arguments]    ${testEquipmentPortDesc}
	${handle}=  setUp  ${testEquipmentPortDesc}
	[return]  ${handle}
	
Init Test Equipment
	[Documentation]   init test equipment protocol
    [Arguments]    ${testSetHandle}  ${protocol}  ${parameters}=${null}
	# init  ${testSetHandle}  ${protocol}  ${parameters}
	init  ${testSetHandle}  ${protocol}

Start Traffic
	[Documentation]   start send&receive traffic
    [Arguments]    ${testSetHandle}
	startTx  ${testSetHandle}
	
stop Traffic
	[Documentation]   stop send traffic
    [Arguments]    ${testSetHandle}
	stopTx  ${testSetHandle}
    
Clear Statistic And Alarm
	[Documentation]   clear Statistic And Alarm on test equipment
    [Arguments]    ${testSetHandle}
	clear  ${testSetHandle}
            
Get Traffic Test Statistic
	[Documentation]   get Traffic Test Statistic on test equipment
    [Arguments]    ${testSetHandle}
	${result}=  getTestResult  ${testSetHandle}
	[return]  ${result}

Start Inject Alarm On Test Equipment
	[Documentation]   Start Inject Alarm on test equipment
    [Arguments]    ${testSetHandle}  ${strAlarmType}  ${strAlarmParam}=${null}
	startInjectAlarm  ${testSetHandle}  ${strAlarmType}  ${strAlarmParam}
		
Start Inject Error On Test Equipment
	[Documentation]   Start Inject Error on test equipment
    [Arguments]    ${testSetHandle}  ${strErrorType}  ${strErrorParam}=${null}
	startInjectError  ${testSetHandle}  ${strErrorType}  ${strErrorParam}
	
Stop Inject Alarm On Test Equipment
	[Documentation]   Stop Inject Alarm on test equipment
    [Arguments]    ${testSetHandle}  ${strAlarmType}
	stopInjectAlarm  ${testSetHandle}  ${strAlarmType}
		
Stop Inject Error On Test Equipment
	[Documentation]   Stop Inject Error on test equipment
    [Arguments]    ${testSetHandle}  ${strErrorType}
	stopInjectError  ${testSetHandle}  ${strErrorType}

Set Ethernet Stream On Test Equipment
	[Documentation]   Set Ethernet Stream parameters on test equipment
    [Arguments]    ${testSetHandle}  ${streamParameters}
	setEthernetStream  ${testSetHandle}  ${streamParameters}
    
Set Laser State
	[Documentation]   Set Laser State on test equipment
    [Arguments]    ${testSetHandle}  ${strStatus}
	setLaser  ${testSetHandle}  ${strStatus}

Is Alarm Raised
	[Documentation]   check alarm is raised on test equipment
    [Arguments]    ${testSetHandle}  ${strAlarmType}
	${result}=  checkAlarm  ${testSetHandle}  ${strAlarmType}
	Return From Keyword If  '${result}' == 'ON'  ${true}
	Return From Keyword If  '${result}' == 'OFF'  ${false}
	Fail  invalid result from keyword 'Is Alarm Raised'
        
Release Test Equipment
	[Documentation]   Release Test Equipment
    [Arguments]    ${testSetHandle}
	tearDown  ${testSetHandle}

	
	
Set OTU Traces
	[Documentation]   Set OTU Traces
    [Arguments]    ${testSetHandle}  ${strMode}  ${strDirection}  ${strValue}
	set OTU SM TTI Traces  ${testSetHandle}  ${strMode}  ${strDirection}  ${strValue}
	
Set OTU FEC
	[Documentation]   Set OTU FEC
    [Arguments]    ${testSetHandle}  ${strMode}
	Set OTN FEC  ${testSetHandle}  ${strMode}

	
Verify Traffic On Test Equipment
	[Documentation]   Verify Traffic on test equipment
    [Arguments]    ${lTxPort}  ${lRxPort}  ${lTxPortFail}  ${lRxPortFail}
	${len1}=  Get Length  ${lTxPortFail}
	${len2}=  Get Length  ${lRxPortFail}
	
	@{EMPTY LIST}=  create list
	
	${lTxPortFail}=  Set Variable If  ${len1}==0  ${EMPTY LIST}  ${lTxPortFail}
	${lRxPortFail}=  Set Variable If  ${len2}==0  ${EMPTY LIST}  ${lRxPortFail}
	
	${result}=  verifyTraffic  ${lTxPort}  ${lRxPort}  ${lTxPortFail}  ${lRxPortFail}
	
	[return]  ${result}
	
