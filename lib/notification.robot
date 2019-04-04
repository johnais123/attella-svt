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
Library         notification.py

*** Variables ***



*** Keywords ***   
Notifications Should Raised
	[Documentation]   Verify Notifications Should Raised
    ...                    Args:
    ...                    |- ncHandle : netconf client handle
    ...                    |- Notifications : notification description 
    ...                    |- timeout : timeout for the notification, default value is 60 seconds

    [Arguments]      ${ncHandle}  ${listNotifications}  ${timeout}=60
	${resp}=  wait4ExpectedNotifications  ${ncHandle}  ${listNotifications}  ${timeout}
	Should Be True  ${resp}  Not all the expected notifications are raised
	
	
Get Netconf Client Handle
	[Documentation]   Init Netconf Client
    ...                    Args:
    ...                    |- strHost : device IP
    ...                    |- strUsername : user name for netconf client
    ...                    |- strPassword : user password for netconf client

    [Arguments]      ${strHost}  ${strUsername}=root  ${strPassword}=Embe1mpls
	${ncHandle}=  ncHandleInit  ${strHost}  ${strUsername}  ${strPassword}
	[return]  ${ncHandle}
	
Destory Netconf Client Handle
	[Documentation]   Destory netconf client
    ...                    Args:
    ...                    |- ncHandle : netconf client handle


    [Arguments]      ${ncHandle}
	ncHandleDestory  ${ncHandle}
