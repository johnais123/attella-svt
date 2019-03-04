*** Settings ***
Documentation     This is Attella traffic frequency Scripts
...               If you are reading this then you need to learn Toby
...               Author: Jack Wu

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
...              Test Bed Init


Suite Teardown  Run Keywords
...              Toby Suite Teardown


*** Variables ***
@{auth}    admin    admin
${interval}  120
${timeout}  120

*** Test Cases ***     
Modify both dut Frequency 191.35 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.35
    
Modify one dut to a random Frequency except 191.35 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.35
    
Modify both dut Frequency 191.40 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.40
    
Modify one dut to a random Frequency except 191.40 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.40
    
Modify both dut Frequency 191.45 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.45
    
Modify one dut to a random Frequency except 191.45 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.45
    
    
Modify both dut Frequency 191.50 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.50
    
Modify one dut to a random Frequency except 191.50 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.50
    
Modify both dut Frequency 191.55 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.55
    
Modify one dut to a random Frequency except 191.55 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.55
    
Modify both dut Frequency 191.60 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.60
    
Modify one dut to a random Frequency except 191.60 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.60
    
Modify both dut Frequency 191.65 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.65
    
Modify one dut to a random Frequency except 191.65 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.65

    
Modify both dut Frequency 191.70 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.70
    
Modify one dut to a random Frequency except 191.70 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.70
    
Modify both dut Frequency 191.75 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.75
    
Modify one dut to a random Frequency except 191.75 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.75
    
Modify both dut Frequency 191.80 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.80
    
Modify one dut to a random Frequency except 191.80 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.80
    
Modify both dut Frequency 191.85 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.85
    
Modify one dut to a random Frequency except 191.85 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.85
    
Modify both dut Frequency 191.90 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.90
    
Modify one dut to a random Frequency except 191.90 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.90
    
Modify both dut Frequency 191.95 And Verify Traffic
    Set Both Frequency And Verify Traffic  191.95
    
Modify one dut to a random Frequency except 191.95 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  191.95
    
Modify both dut Frequency 192.00 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.00
    
Modify one dut to a random Frequency except 192.00 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.00    

Modify both dut Frequency 192.05 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.05
    
Modify one dut to a random Frequency except 192.05 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.05

Modify both dut Frequency 192.10 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.10
    
Modify one dut to a random Frequency except 192.10 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.10

    
Modify both dut Frequency 192.15 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.15
    
Modify one dut to a random Frequency except 192.15 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.15
    
Modify both dut Frequency 192.20 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.20
    
Modify one dut to a random Frequency except 192.20 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.20
    
Modify both dut Frequency 192.25 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.25
    
Modify one dut to a random Frequency except 192.25 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.25    
    
Modify both dut Frequency 192.30 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.30
    
Modify one dut to a random Frequency except 192.30 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.30
    

    
Modify both dut Frequency 192.35 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.35
    
Modify one dut to a random Frequency except 192.35 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.35
    
Modify both dut Frequency 192.40 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.40
    
Modify one dut to a random Frequency except 192.40 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.40
    
Modify both dut Frequency 192.45 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.45
    
Modify one dut to a random Frequency except 192.45 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.45
    
    
Modify both dut Frequency 192.50 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.50
    
Modify one dut to a random Frequency except 192.50 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.50
    
Modify both dut Frequency 192.55 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.55
    
Modify one dut to a random Frequency except 192.55 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.55
    
Modify both dut Frequency 192.60 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.60
    
Modify one dut to a random Frequency except 192.60 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.60
    
Modify both dut Frequency 192.65 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.65
    
Modify one dut to a random Frequency except 192.65 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.65

    
Modify both dut Frequency 192.70 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.70
    
Modify one dut to a random Frequency except 192.70 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.70
    
Modify both dut Frequency 192.75 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.75
    
Modify one dut to a random Frequency except 192.75 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.75
    
Modify both dut Frequency 192.80 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.80
    
Modify one dut to a random Frequency except 192.80 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.80
    
Modify both dut Frequency 192.85 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.85
    
Modify one dut to a random Frequency except 192.85 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.85
    
Modify both dut Frequency 192.90 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.90
    
Modify one dut to a random Frequency except 192.90 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.90
    
Modify both dut Frequency 192.95 And Verify Traffic
    Set Both Frequency And Verify Traffic  192.95
    
Modify one dut to a random Frequency except 192.95 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  192.95
    
Modify both dut Frequency 193.00 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.00
    
Modify one dut to a random Frequency except 193.00 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.00    

Modify both dut Frequency 193.05 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.05
    
Modify one dut to a random Frequency except 193.05 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.05

Modify both dut Frequency 193.10 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.10
    
Modify one dut to a random Frequency except 193.10 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.10

    
Modify both dut Frequency 193.15 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.15
    
Modify one dut to a random Frequency except 193.15 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.15
    
Modify both dut Frequency 193.20 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.20
    
Modify one dut to a random Frequency except 193.20 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.20
    
Modify both dut Frequency 193.25 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.25
    
Modify one dut to a random Frequency except 193.25 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.25    
    
Modify both dut Frequency 193.30 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.30
    
Modify one dut to a random Frequency except 193.30 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.30




    
    
    
    

Modify both dut Frequency 193.35 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.35
    
Modify one dut to a random Frequency except 193.35 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.35
    
Modify both dut Frequency 193.40 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.40
    
Modify one dut to a random Frequency except 193.40 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.40
    
Modify both dut Frequency 193.45 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.45
    
Modify one dut to a random Frequency except 193.45 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.45
    
    
Modify both dut Frequency 193.50 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.50
    
Modify one dut to a random Frequency except 193.50 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.50
    
Modify both dut Frequency 193.55 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.55
    
Modify one dut to a random Frequency except 193.55 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.55
    
Modify both dut Frequency 193.60 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.60
    
Modify one dut to a random Frequency except 193.60 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.60
    
Modify both dut Frequency 193.65 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.65
    
Modify one dut to a random Frequency except 193.65 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.65

    
Modify both dut Frequency 193.70 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.70
    
Modify one dut to a random Frequency except 193.70 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.70
    
Modify both dut Frequency 193.75 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.75
    
Modify one dut to a random Frequency except 193.75 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.75
    
Modify both dut Frequency 193.80 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.80
    
Modify one dut to a random Frequency except 193.80 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.80
    
Modify both dut Frequency 193.85 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.85
    
Modify one dut to a random Frequency except 193.85 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.85
    
Modify both dut Frequency 193.90 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.90
    
Modify one dut to a random Frequency except 193.90 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.90
    
Modify both dut Frequency 193.95 And Verify Traffic
    Set Both Frequency And Verify Traffic  193.95
    
Modify one dut to a random Frequency except 193.95 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  193.95
    
Modify both dut Frequency 194.00 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.00
    
Modify one dut to a random Frequency except 194.00 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.00    

Modify both dut Frequency 194.05 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.05
    
Modify one dut to a random Frequency except 194.05 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.05

Modify both dut Frequency 194.10 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.10
    
Modify one dut to a random Frequency except 194.10 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.10

    
Modify both dut Frequency 194.15 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.15
    
Modify one dut to a random Frequency except 194.15 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.15
    
Modify both dut Frequency 194.20 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.20
    
Modify one dut to a random Frequency except 194.20 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.20
    
Modify both dut Frequency 194.25 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.25
    
Modify one dut to a random Frequency except 194.25 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.25    
    
Modify both dut Frequency 194.30 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.30
    
Modify one dut to a random Frequency except 194.30 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.30
    

    
Modify both dut Frequency 194.35 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.35
    
Modify one dut to a random Frequency except 194.35 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.35
    
Modify both dut Frequency 194.40 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.40
    
Modify one dut to a random Frequency except 194.40 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.40
    
Modify both dut Frequency 194.45 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.45
    
Modify one dut to a random Frequency except 194.45 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.45
    
    
Modify both dut Frequency 194.50 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.50
    
Modify one dut to a random Frequency except 194.50 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.50
    
Modify both dut Frequency 194.55 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.55
    
Modify one dut to a random Frequency except 194.55 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.55
    
Modify both dut Frequency 194.60 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.60
    
Modify one dut to a random Frequency except 194.60 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.60
    
Modify both dut Frequency 194.65 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.65
    
Modify one dut to a random Frequency except 194.65 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.65

    
Modify both dut Frequency 194.70 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.70
    
Modify one dut to a random Frequency except 194.70 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.70
    
Modify both dut Frequency 194.75 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.75
    
Modify one dut to a random Frequency except 194.75 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.75
    
Modify both dut Frequency 194.80 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.80
    
Modify one dut to a random Frequency except 194.80 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.80
    
Modify both dut Frequency 194.85 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.85
    
Modify one dut to a random Frequency except 194.85 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.85
    
Modify both dut Frequency 194.90 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.90
    
Modify one dut to a random Frequency except 194.90 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.90
    
Modify both dut Frequency 194.95 And Verify Traffic
    Set Both Frequency And Verify Traffic  194.95
    
Modify one dut to a random Frequency except 194.95 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  194.95
    
Modify both dut Frequency 195.00 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.00
    
Modify one dut to a random Frequency except 195.00 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.00    

Modify both dut Frequency 195.05 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.05
    
Modify one dut to a random Frequency except 195.05 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.05

Modify both dut Frequency 195.10 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.10
    
Modify one dut to a random Frequency except 195.10 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.10

    
Modify both dut Frequency 195.15 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.15
    
Modify one dut to a random Frequency except 195.15 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.15
    
Modify both dut Frequency 195.20 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.20
    
Modify one dut to a random Frequency except 195.20 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.20
    
Modify both dut Frequency 195.25 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.25
    
Modify one dut to a random Frequency except 195.25 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.25    
    
Modify both dut Frequency 195.30 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.30
    
Modify one dut to a random Frequency except 195.30 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.30
    
    
Modify both dut Frequency 195.35 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.35
    
Modify one dut to a random Frequency except 195.35 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.35
    
Modify both dut Frequency 195.40 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.40
    
Modify one dut to a random Frequency except 195.40 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.40
    
Modify both dut Frequency 195.45 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.45
    
Modify one dut to a random Frequency except 195.45 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.45
    
    
Modify both dut Frequency 195.50 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.50
    
Modify one dut to a random Frequency except 195.50 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.50
    
Modify both dut Frequency 195.55 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.55
    
Modify one dut to a random Frequency except 195.55 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.55
    
Modify both dut Frequency 195.60 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.60
    
Modify one dut to a random Frequency except 195.60 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.60
    
Modify both dut Frequency 195.65 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.65
    
Modify one dut to a random Frequency except 195.65 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.65

    
Modify both dut Frequency 195.70 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.70
    
Modify one dut to a random Frequency except 195.70 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.70
    
Modify both dut Frequency 195.75 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.75
    
Modify one dut to a random Frequency except 195.75 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.75
    
Modify both dut Frequency 195.80 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.80
    
Modify one dut to a random Frequency except 195.80 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.80
    
Modify both dut Frequency 195.85 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.85
    
Modify one dut to a random Frequency except 195.85 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.85
    
Modify both dut Frequency 195.90 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.90
    
Modify one dut to a random Frequency except 195.90 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.90
    
Modify both dut Frequency 195.95 And Verify Traffic
    Set Both Frequency And Verify Traffic  195.95
    
Modify one dut to a random Frequency except 195.95 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  195.95
    
Modify both dut Frequency 196.00 And Verify Traffic
    Set Both Frequency And Verify Traffic  196.00
    
Modify one dut to a random Frequency except 196.00 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  196.00    

Modify both dut Frequency 196.05 And Verify Traffic
    Set Both Frequency And Verify Traffic  196.05
    
Modify one dut to a random Frequency except 196.05 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  196.05

Modify both dut Frequency 196.10 And Verify Traffic
    Set Both Frequency And Verify Traffic  196.10
    
Modify one dut to a random Frequency except 196.10 And Verify Traffic
    Modify one dut to a different random Frequency And Verify Traffic  196.10


    
Service De-provision
    Log  Remove Service
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    
    &{intf}=   create_dictionary   interface-name=${odu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${och intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${client intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    &{intf}=   create_dictionary   interface-name=${client otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${netconfParams}
    
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    
    &{intf}=   create_dictionary   interface-name=${odu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${och intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    &{intf}=   create_dictionary   interface-name=${remote client intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    ${remote client otu intf}=  Get OTU Intface Name From ODU Intface  ${remote client intf}
    &{intf}=   create_dictionary   interface-name=${remote client otu intf}
    &{netconfParams}   create_dictionary   org-openroadm-device=${intf}
    Send Delete Request And Verify Status Of Response Is OK  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${netconfParams}
    
    
*** Keywords ***


Set Both Frequency And Verify Traffic
    [Documentation]   Set Both Frequency And Verify Traffic
    [Arguments]    ${frequency}
    &{och_interface}    create_dictionary   interface-name=${och intf}  frequency=${frequency}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 
    
    &{och_interface}    create_dictionary   interface-name=${remote och intf}  frequency=${frequency}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device1__re0__mgt-ip']}   ${payload} 
    
    Log  Verify Traffic
    Verify Traffic Is OK
    
Modify one dut to a different random Frequency And Verify Traffic
    [Documentation]   Set Both Frequency And Verify Traffic
    [Arguments]    ${frequency}
    
    ${frequencyRandom}=  Get A Random Frequency
    ${frequencyNext}=  Get The Next Frequency  ${frequency}
    ${frequencyNew}=  Set Variable If  '${frequencyRandom}' == '${frequency}'  ${frequencyNext}  ${frequencyRandom}
    
    &{och_interface}    create_dictionary   interface-name=${och intf}  frequency=${frequencyNew}000
    
    @{interface_info}    create list    ${och_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${tv['device0__re0__mgt-ip']}   ${payload} 
    
    Log  Verify Traffic
    Verify Traffic Is Blocked

Test Bed Init
    Set Log Level  DEBUG
    # Initialize
    Log To Console      create a restconf operational session
    
    @{dut_list}    create list    device0  device1
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
    
    
    ${client intf}=  Get Otu4 Intface Name From Client Intface  ${tv['device0__client_intf__pic']}
    Set Suite Variable    ${client intf}
    
    ${remote client intf}=  Get Otu4 Intface Name From Client Intface  ${tv['device1__client_intf__pic']}
    Set Suite Variable    ${remote client intf}
    
    Mount vAttella On ODL Controller    ${odl_sessions}    ${tv['device0__re0__mgt-ip']}  ${timeout}   ${interval} 
    Mount vAttella On ODL Controller    ${odl_sessions}    ${tv['device1__re0__mgt-ip']}  ${timeout}   ${interval} 

    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device0__re0__mgt-ip']}
    Verfiy Device Mount status on ODL Controller   ${odl_sessions}  ${timeout}    ${interval}   ${tv['device1__re0__mgt-ip']}
    
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    Set Suite Variable    ${och intf}
    
    ${remote odu intf}=  Get Line ODU Intface Name From Client Intface  ${remote client intf}
    ${remote otu intf}=  Get OTU Intface Name From ODU Intface  ${remote odu intf}
    ${remote och intf}=  Get OCH Intface Name From OTU Intface  ${remote otu intf}
    Set Suite Variable    ${remote och intf}
    
    
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port1-type']}  ${tv['uv-test-eqpt-port1-ip']}  ${tv['uv-test-eqpt-port1-number']}  ${tv['uv-test-eqpt-port1-extraParam']}
    ${testSetHandle1}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle1}
    
    @{testEquipmentInfo}=  create list  ${tv['uv-test-eqpt-port2-type']}  ${tv['uv-test-eqpt-port2-ip']}  ${tv['uv-test-eqpt-port2-number']}  ${tv['uv-test-eqpt-port2-extraParam']}
    ${testSetHandle2}=  Get Test Equipment Handle  ${testEquipmentInfo}
    Set Suite Variable    ${testSetHandle2}
           
    Init Test Equipment  ${testSetHandle1}  otu4
  
    Init Test Equipment  ${testSetHandle2}  otu4
    
    Create OTU4 Service  ${odl_sessions}  ${tv['device0__re0__mgt-ip']}  ${client intf}   191.35  ${tv['uv-service-description']}

    Create OTU4 Service  ${odl_sessions}  ${tv['device1__re0__mgt-ip']}  ${remote client intf}   191.35  ${tv['uv-service-description']}

    

Create OTU4 Service
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}
    ${rate}=  Set Variable  100G
    
    Log  ${client intf}
    ${client otu intf}=  Get OTU Intface Name From ODU Intface  ${client intf}
    
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    ${line support port}=  Get Supporting Port  ${och intf}
    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
    ${client support port}=  Get Supporting Port  ${client intf}
    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
    ${client rate}=  Speed To Client Rate  ${rate}
    ${odu rate}=  Speed To ODU Rate  ${rate}
    ${otu rate}=  Speed To OTU Rate  ${rate}
    ${och rate}=  Speed To OCH Rate  ${rate}

    &{client_otu_interface}    create_dictionary   interface-name=${client otu intf}    description=client-otu-${discription}    interface-type=otnOtu
    ...    interface-administrative-state=inService   otu-rate=${otu rate}  otu-tx-sapi=777770000077777  otu-tx-dapi=888880000088888  
    ...    otu-expected-sapi=exp-sapi-val000  otu-expected-dapi=exp-dapi-val111  otu-tim-detect-mode=SAPI-and-DAPI
    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}
    
    &{client_interface}    create_dictionary   interface-name=${client intf}    description=client-odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService   odu-rate=${odu rate}  odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
    ...    odu-expected-sapi=exp-sapi-val  odu-expected-dapi=exp-dapi-val  odu-tim-detect-mode=SAPI-and-DAPI
    ...    supporting-interface=${client otu intf}    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}

    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel    
    ...    interface-administrative-state=inService    supporting-interface=none   och-rate=${och rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}  frequency=${frequency}000
    
    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}    interface-type=otnOtu    
    ...    interface-administrative-state=inService    supporting-interface=${och intf}  otu-rate=${otu rate}  otu-tx-sapi=tx-sapi-val  otu-tx-dapi=tx-dapi-val  
    ...    otu-expected-sapi=exp-sapi-val  otu-expected-dapi=exp-dapi-val  otu-tim-detect-mode=SAPI-and-DAPI
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    &{odu_interface}    create_dictionary   interface-name=${odu intf}     description=odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService    supporting-interface=${otu intf}     odu-rate=${odu rate}  odu-tx-sapi=tx-sapi-val  odu-tx-dapi=tx-dapi-val  
    ...    odu-expected-sapi=exp-sapi-val  odu-expected-dapi=exp-dapi-val  odu-tim-detect-mode=SAPI-and-DAPI
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    @{interface_info}    create list    ${och_interface}    ${otu_interface}    ${odu_interface} 
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload} 
    
    @{interface_info}    create list    ${client_otu_interface}    ${client_interface}
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload} 
    
    
Create 100GE Service
    [Documentation]   Retrieve system configuration and state information
    [Arguments]    ${odl_sessions}  ${node}  ${client intf}  ${frequency}  ${discription}
    ${rate}=  Set Variable  100G
    ${odu intf}=  Get Line ODU Intface Name From Client Intface  ${client intf}
    ${otu intf}=  Get OTU Intface Name From ODU Intface  ${odu intf}
    ${och intf}=  Get OCH Intface Name From OTU Intface  ${otu intf}
    ${line support port}=  Get Supporting Port  ${och intf}
    ${line circuit pack}=  Get getSupporting Circuit Pack Name  ${och intf}
    ${client support port}=  Get Supporting Port  ${client intf}
    ${client circuit pack}=  Get getSupporting Circuit Pack Name  ${client intf}
    ${client rate}=  Speed To Client Rate  ${rate}
    ${odu rate}=  Speed To ODU Rate  ${rate}
    ${otu rate}=  Speed To OTU Rate  ${rate}
    ${och rate}=  Speed To OCH Rate  ${rate}
    
    &{client_interface}    create_dictionary   interface-name=${client intf}    description=ett-${discription}    interface-type=ethernetCsmacd    
    ...    interface-administrative-state=inService   speed=${client rate}
    ...    supporting-interface=none    supporting-circuit-pack-name=${client circuit pack}     supporting-port=${client support port}

    &{och_interface}    create_dictionary   interface-name=${och intf}     description=och-${discription}    interface-type=opticalChannel    
    ...    interface-administrative-state=inService    supporting-interface=none   och-rate=${och rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}  frequency=${frequency}000
    
    &{otu_interface}    create_dictionary   interface-name=${otu intf}     description=otu-${discription}    interface-type=otnOtu    
    ...    interface-administrative-state=inService    supporting-interface=${och intf}  otu-rate=${otu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    &{odu_interface}    create_dictionary   interface-name=${odu intf}     description=odu-${discription}    interface-type=otnOdu    
    ...    interface-administrative-state=inService    supporting-interface=${otu intf}     odu-rate=${odu rate}
    ...    supporting-circuit-pack-name=${line circuit pack}     supporting-port=${line support port}
    
    
    @{interface_info}    create list    ${client_interface}    ${och_interface}    ${otu_interface}    ${odu_interface} 
    &{dev_info}   create_dictionary   interface=${interface_info}       
    &{payload}   create_dictionary   org-openroadm-device=${dev_info}
    Send Merge Then Get Request And Verify Output Is Correct    ${odl_sessions}   ${node}   ${payload}

Verify Traffic Is OK
    Log  Verify Traffic Is OK
    
    Sleep  100

    Clear Statistic And Alarm  ${testSetHandle1}  
    Clear Statistic And Alarm  ${testSetHandle2}
    
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
    
    @{lTx}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRx}=  create list  ${testSetHandle2}  ${testSetHandle1}
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${lTx}  ${lRx}  ${EMPTY LIST}  ${EMPTY LIST}
   
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails
    
Verify Traffic Is Blocked
    Log  Verify Traffic Is Blocked
    
    Sleep  20    

    Clear Statistic And Alarm  ${testSetHandle1}
    Clear Statistic And Alarm  ${testSetHandle2}
       
    Start Traffic  ${testSetHandle1}
    Start Traffic  ${testSetHandle2}
   
    Sleep  30
   
    stop Traffic  ${testSetHandle1}
    stop Traffic  ${testSetHandle2}
   
   
    @{lTxFail}=  create list  ${testSetHandle1}  ${testSetHandle2}
    @{lRxFail}=  create list  ${testSetHandle2}  ${testSetHandle1}
    
    @{EMPTY LIST}=  create list
    ${result}=  Verify Traffic On Test Equipment  ${EMPTY LIST}  ${EMPTY LIST}  ${lTxFail}  ${lRxFail}
    Run Keyword Unless  '${result}' == "PASS"  FAIL  Traffic Verification fails After Service De-provision
    