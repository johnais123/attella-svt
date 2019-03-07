import EXFO
import ont600
# import Spirent
# from innocor import InnocorSession
# from nose.tools import ok_
# from Spirent_trans import SpirentSessionTrans
# from Spirent_trans import stc

import time
import re
import random

class TestPortException(Exception):
    def __init__(self, value):
        self.value = value
        print(value)
    def __str__(self):
        return repr(self.value)

def setUp(lTestEquipmentPortDesc):
    # lTestEquipmentPortDesc example:
    # 1. ["EXFO", "172.27.93.131", "6"]
    # 2. ["EXFO", "172.27.93.131", "6", "QSFPP2"] or ["EXFO", "172.27.93.131", "6", "CFP4P1"]
    # 3. ["SPIRENT", "172.27.93.105", "11/9"]
    if "EXFO" == lTestEquipmentPortDesc[0]:
        if 4 == len(lTestEquipmentPortDesc):
            return ExfoPort(lTestEquipmentPortDesc[1], lTestEquipmentPortDesc[2], lTestEquipmentPortDesc[3])
        elif 3 == len(lTestEquipmentPortDesc):
            return ExfoPort(lTestEquipmentPortDesc[1], lTestEquipmentPortDesc[2])
    elif "JDSU" == lTestEquipmentPortDesc[0]:
        return JdsuPort(lTestEquipmentPortDesc[1])
    elif "SPIRENT" == lTestEquipmentPortDesc[0]:
        return SpirentPort(lTestEquipmentPortDesc[1], lTestEquipmentPortDesc[2])
    elif "VIAVI" == lTestEquipmentPortDesc[0]:
        return ViaviPort(lTestEquipmentPortDesc[1], lTestEquipmentPortDesc[2])
    else:
        raise TestPortException("unknown test equipment type -- %s"%lTestEquipmentPortDesc[0])

def verifyTraffic(lTxPort, lRxPort, lTxPortFail=[], lRxPortFail=[]):
    '''
    verify test traffic for 100GE_SR4/8FC/10FC/OTU4 protocol interface
    @type lTxPort: ExfoModule object list
    @param lTxPort: list of ExfoModule objects which send traffic
    @type lRxPort: ExfoModule object list
    @param lRxPort: list of ExfoModule objects which recieve traffic, it is relative with lTxPort, 
    traffic flow from lTxPort[i] to lRxPort[i] should be OK
    @type lTxPortFail: ExfoModule object list
    @param lTxPortFail: list of ExfoModule objects which send traffic(but the traffic should be blocked)
    @type lRxPortFail: ExfoModule object list
    @param lRxPortFail: list of ExfoModule objects which recieve traffic(but the traffic should be blocked), it is relative with lTxPortFail, 
    traffic flow from lTxPortFail[i] to lRxPortFail[i] should failed
    @rtype: string
    @return: True|False
    '''
    result = "PASS"
    
    strProtocol = list(set(lTxPort).union(set(lTxPortFail)))[0].getProtocol()

    if strProtocol in ["100GE_LANE4X25_SR4", "100GE_LANE4X25_CLR4",
        "100GE_LANE4X25_CWDM4", "100GE_LANE4X25_OTHERS", "100GE_LANE10X10", 
        "40GE_LANE4X10", "10GELAN", "10GEWAN", "8X", "10X", "PHYS_PCSL_MAC_40GE", "PHYS_PCSL_MAC_100GE", "10gbelan", 
        "10gfc", "PHYS_PCS_FC2", "PHYS_PCS1G_FC2", "10GE", "40GE", "100GE"]:
        for i in range(len(lTxPort)):
            print("verify traffic flow from %s to %s is OK"%(lTxPort[i], lRxPort[i]))
            tx = lTxPort[i].getTestResult()["TX_PACKAGE_TOTAL"]
            rx = lRxPort[i].getTestResult()["RX_PACKAGE_TOTAL"]
            print("  --%s TX_PACKAGE_TOTAL : %d"%(lTxPort[i], tx))
            print("  --%s RX_PACKAGE_TOTAL : %d"%(lRxPort[i], rx))
            if tx == 0 or tx != rx:
                print("there is error in traffic flow")
                result = "FAIL"
        for i in range(len(lTxPortFail)):
            print("verify traffic flow from %s to %s is blocked"%(lTxPortFail[i], lRxPortFail[i]))
            tx = lTxPortFail[i].getTestResult()["TX_PACKAGE_TOTAL"]
            rx = lRxPortFail[i].getTestResult()["RX_PACKAGE_TOTAL"]
            print("  --%s TX_PACKAGE_TOTAL : %d"%(lTxPortFail[i], tx))
            print("  --%s RX_PACKAGE_TOTAL : %d"%(lRxPortFail[i], rx))
            if tx == 0 or rx != 0:
                print("the traffic should blocked but it is not")
                result = "FAIL"

    elif strProtocol in ["OTU4_LANE4X25", "OTU4_LANE10X10", "OTU3_LANE4X10",
        "OTU2", "OTU2E", "OC192", "STM64", "PHYS_OTL4_OTN", "oc192", "stm64", "11.095fec_10gbelan", "otu2_sonetsdh"]:
        for i in range(len(lTxPort)):
            print("verify traffic flow from %s to %s is OK"%(lTxPort[i], lRxPort[i]))
            txResult = lTxPort[i].getTestResult()["TEST_STATUS"]
            rxResult = lRxPort[i].getTestResult()["TEST_STATUS"]
            print("  --%s TEST_STATUS : %s"%(lTxPort[i], txResult))
            print("  --%s TEST_STATUS : %s"%(lRxPort[i], rxResult))
            # if not ("PASS" == txResult and "PASS" == rxResult):
            if not ("PASS" == rxResult):
                print("the traffic should OK but there is error in traffic flow")
                result = "FAIL"
        for i in range(len(lTxPortFail)):
            print("verify traffic flow from %s to %s is blocked"%(lTxPortFail[i], lRxPortFail[i]))
            txResult = lTxPortFail[i].getTestResult()["TEST_STATUS"]
            rxResult = lRxPortFail[i].getTestResult()["TEST_STATUS"]
            print("  --%s TEST_STATUS : %s"%(lTxPortFail[i], txResult))
            print("  --%s TEST_STATUS : %s"%(lRxPortFail[i], rxResult))
            # if not ("FAIL" == txResult and "FAIL" == rxResult):
            if not ("FAIL" == rxResult):
                print("the traffic should blocked but it is not")
                result = "FAIL"
    else:
        print("unknown protocol type -- %s"%strProtocol)
        result = "FAIL"

    if "FAIL" == result:
        print("traffic Test failed")
    return result

class Ts(object):
    '''
    Base class for test set.
    '''
    # ------------------------------------------------------------------ __init__
    def __init__(self, tsinfo):
        '''
        Setup the test set. 
        create target
        restore the test set port info
        initial the port

        @type tsinfo: list
        @param tsinfo: include all port setup info

        '''
        self.__target = None
        self.__lTsinfo = tsinfo
        '''

        '''
        self.__lPortInfo = None


    # --------------------------------------------------------------------- close
    def tearDown(self):
        '''
        Release the test set
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")


    # -------------------------------------------------------------------- isOpen

    # ================================  Basic  =======================================
    # -------------------------------------------------------------------- initPort
    def init(self, lPortInfo):
        '''
        According to lPortInfo init the port
        
        @type state: List
        @param state: test set Port Info
        lPortconf = [
            "PROTOCOL_ETHERNET_10GE-LAN",  # protocol
            'no-fec',  # fec type
                {
                #'MODEL': 'SR4',
                }  # *arg
            ]
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")
    
    
    # -------------------------------------------------------------------- setLaser
    def setLaser(self, state):
        '''
        set Laser
        
        @type state: Str
        @param state: 'ON'|'OFF'
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")
    
    
    # ================================  Traffic  ======================================
    # -------------------------------------------------------------------- startTraffic
    def startTx(self):
        '''
        start traffic
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")


    # -------------------------------------------------------------------- stopTraffic
    def stopTx(self):
        '''
        stop traffic
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")


    # -------------------------------------------------------------------- getTrafficResult
    def getTestResult(self):
        '''
        get Traffic Result
        
        @rtype: Boolean
        @return: False
        
        @rtype: Dict
        @return: {'TX':'11111', 'RX':'2222222'}/{'TX':'OK','RX':'OK'} 
        '''
        raise TestPortException("not available now!")


    # -------------------------------------------------------------------- clearTx   
    def clear(self):
        '''
        clearCount
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")


    # -------------------------------------------------------------------- setEthernetTraffic
    def setEthernetStream(self, dTrafficinfo):
        raise TestPortException("not available now!")
        
        
    # ================================  Alarm  =======================================
    # -------------------------------------------------------------------- alarmInject
    def startInjectAlarm(self, alarmType):
        '''
        alarm inject
        
        @type alarmType: Str
        @param alarmType: 'Dict Key'
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")
        

    # -------------------------------------------------------------------- alarmClear
    def stopInjectAlarm(self, alarmType):
        '''
        alarm clear
        
        @type alarmType: Str
        @param alarmType: 'Dict Key'
        
        @rtype: Boolean
        @return: True|False
        '''
        raise TestPortException("not available now!")
        

    # -------------------------------------------------------------------- alarmCheck        
    def alarmCheck(self, alarmType):
        '''
        alarm clear
        
        @type alarmType: Str
        @param alarmType: 'Dict Key'
        
        @rtype: Str
        @return: alarmType
        
        @rtype: Boolean
        @return: False
        '''
        raise TestPortException("not available now!")
                
class ExfoPort():
    DICT_ALARM = {
        # ethernet alarm
        "ALARM_ETHERNET_IF_LOS":"LOS",
        "ALARM_ETHERNET_ETH_LOSYNC":"LDOWN",
        "ALARM_ETHERNET_ETH_LF":"LFAULT",
        "ALARM_ETHERNET_ETH_RF":"RFAULT",

        "ALARM_ETHERNET_BER_PATTERNLOSS":"",
        
        
        # OTU2 alarm
        "ALARM_OTU2_IF_LOS":"LOS",
        "ALARM_OTU2_OTU2_LOF":"LOF",
        "ALARM_OTU2_OTU2_OOF":"OOF",
        "ALARM_OTU2_OTU2_LOM":"LOM",
        "ALARM_OTU2_OTU2_OOM":"OOM",
        "ALARM_OTU2_OTU2_AIS":"OTU2_OAIS",
        "ALARM_OTU2_OTU2_BDI":"OTU2_OBDI",
        "ALARM_OTU2_OTU2_IAE":"OIAE",
        "ALARM_OTU2_OTU2_BIAE":"OBIAE",

        "ALARM_OTU2_ODU2_AIS":"ODU2_OAIS",
        "ALARM_OTU2_ODU2_OCI":"OOCI",
        "ALARM_OTU2_ODU2_LCK":"OLCK",
        "ALARM_OTU2_ODU2_BDI":"ODU2_OBDI",
        "ALARM_OTU2_ODU2_FSF":"OFSF",
        "ALARM_OTU2_ODU2_BSF":"OBSF",
        "ALARM_OTU2_ODU2_FSD":"OFSD",
        "ALARM_OTU2_ODU2_BSD":"OBSD",
        "ALARM_OTU2_OPU2_AIS":"",
        "ALARM_OTU2_OPU2_CSF":"",
        "ALARM_OTU2_BER_PATTERNLOSS":"",
        
        # OTU2E alarm
        "ALARM_OTU2E_IF_LOS":"LOS",
        "ALARM_OTU2E_OTU2E_LOF":"LOF",
        "ALARM_OTU2E_OTU2E_OOF":"OOF",
        "ALARM_OTU2E_OTU2E_LOM":"LOM",
        "ALARM_OTU2E_OTU2E_OOM":"OOM",
        "ALARM_OTU2E_OTU2E_AIS":"OTU2E_OAIS",
        "ALARM_OTU2E_OTU2E_BDI":"OTU2E_OBDI",
        "ALARM_OTU2E_OTU2E_IAE":"OIAE",
        "ALARM_OTU2E_OTU2E_BIAE":"OBIAE",

        "ALARM_OTU2E_ODU2E_AIS":"ODU2E_OAIS",
        "ALARM_OTU2E_ODU2E_OCI":"OOCI",
        "ALARM_OTU2E_ODU2E_LCK":"OLCK",
        "ALARM_OTU2E_ODU2E_BDI":"ODU2E_OBDI",
        "ALARM_OTU2E_ODU2E_FSF":"OFSF",
        "ALARM_OTU2E_ODU2E_BSF":"OBSF",
        "ALARM_OTU2E_ODU2E_FSD":"OFSD",
        "ALARM_OTU2E_ODU2E_BSD":"OBSD",
        "ALARM_OTU2E_OPU2E_AIS":"",
        "ALARM_OTU2E_OPU2E_CSF":"",
        "ALARM_OTU2E_BER_PATTERNLOSS":"",
        
        
        # OTU4 alarm
        "ALARM_OTU4_OTL_LOF":"",
        "ALARM_OTU4_OTL_LOL":"",
        "ALARM_OTU4_OTL_LOR":"",
        "ALARM_OTU4_OTL_OOF":"",
        "ALARM_OTU4_OTL_OOR":"",
        
        "ALARM_OTU4_IF_LOS":"LOS",
        "ALARM_OTU4_OTU4_LOF":"LOF",
        "ALARM_OTU4_OTU4_OOF":"OOF",
        "ALARM_OTU4_OTU4_LOM":"LOM",
        "ALARM_OTU4_OTU4_OOM":"OOM",
        "ALARM_OTU4_OTU4_BDI":"OTU4_OBDI",
        "ALARM_OTU4_OTU4_IAE":"OIAE",
        "ALARM_OTU4_OTU4_BIAE":"OBIAE",

        "ALARM_OTU4_ODU4_AIS":"ODU4_OAIS",
        "ALARM_OTU4_ODU4_OCI":"OOCI",
        "ALARM_OTU4_ODU4_LCK":"OLCK",
        "ALARM_OTU4_ODU4_BDI":"ODU4_OBDI",
        "ALARM_OTU4_ODU4_FSF":"OFSF",
        "ALARM_OTU4_ODU4_BSF":"OBSF",
        "ALARM_OTU4_ODU4_FSD":"OFSD",
        "ALARM_OTU4_ODU4_BSD":"OBSD",
        "ALARM_OTU4_OPU4_AIS":"",
        "ALARM_OTU4_OPU4_CSF":"",
        "ALARM_OTU4_BER_PATTERNLOSS":"",
        
        
        # OC192 alarm
        "ALARM_OC192_IF_LOS":"LOS",
        "ALARM_OC192_SECTION_LOFS":"SECTION_LOF1",
        "ALARM_OC192_SECTION_SEF":"SECTION_SEF1",

        "ALARM_OC192_LINE_RDIL":"LINE_RDI",
        "ALARM_OC192_LINE_AISL":"LINE_AIS",


        "ALARM_OC192_STSPATH_AISP":"",
        "ALARM_OC192_STSPATH_ERDIPCD":"",
        "ALARM_OC192_STSPATH_ERDIPPD":"",
        "ALARM_OC192_STSPATH_ERDIPSD":"",
        "ALARM_OC192_STSPATH_LOPP":"",
        "ALARM_OC192_STSPATH_PDIP":"",
        "ALARM_OC192_STSPATH_RDIP":"",
        "ALARM_OC192_STSPATH_UNEQP":"",

        "ALARM_OC192_BER_PATTERNLOSS":"",

        # STM64 alarm
        "ALARM_STM64_IF_LOS":"LOS",
        "ALARM_STM64_RS_RSLOF":"RS_LOF1",
        "ALARM_STM64_RS_RSOOF":"",
        "ALARM_STM64_MS_MSRDI":"MS_RDI",
        "ALARM_STM64_MS_MSAIS":"MS_AIS",

        "ALARM_STM64_AUPATH_AUAIS":"",
        "ALARM_STM64_AUPATH_HPERDIPCD":"",
        "ALARM_STM64_AUPATH_HPERDIPPD":"",
        "ALARM_STM64_AUPATH_HPERDIPSD":"",
        "ALARM_STM64_AUPATH_AULOP":"",
        "ALARM_STM64_AUPATH_HPRDI":"",
        "ALARM_STM64_AUPATH_HPUNEQ":"",

        "ALARM_STM64_BER_PATTERNLOSS":"",
        
        "ALARM_8FC_IF_LOS":"LOS",
        
        "ALARM_10FC_IF_LOS":"LOS",
        
        "LOS":"LOS"
        
        
    }
    
    DICT_ERROR = {
        # ethernet error
        "ERROR_ETHERNET_ETH_BLK":"",
        "ERROR_ETHERNET_ETH_FCS":"FCS",

        "ERROR_ETHERNET_BER_BITERROR":"BER",

        "ERROR_ETHERNET_PCS_BLK":"BLOCk",
        "ERROR_ETHERNET_PCS_INVALIDMARKER":"",
        "ERROR_ETHERNET_PCS_PCSBIP8":"BIP8",
        
        # OTU2 error
        "ERROR_OTU2_OTU2_BIP8":"",
        "ERROR_OTU2_OTU2_FAS":"",
        "ERROR_OTU2_OTU2_MFAS":"",
        "ERROR_OTU2_OTU2_BEI":"",
        "ERROR_OTU2_FEC_FECCORRCW":"",
        "ERROR_OTU2_FEC_FECCORRSYM":"",
        "ERROR_OTU2_FEC_FECCORRBIT":"",
        "ERROR_OTU2_FEC_FECUNCORRCW":"",
        "ERROR_OTU2_FEC_FECSTRESS":"",
        "ERROR_OTU2_ODU2_BIP8":"",
        "ERROR_OTU2_ODU2_BEI":"",
        
        "ERROR_OTU2_BER_BITERROR":"BER",
        
        # OTU2E error
        "ERROR_OTU2E_OTU2E_BIP8":"",
        "ERROR_OTU2E_OTU2E_FAS":"",
        "ERROR_OTU2E_OTU2E_MFAS":"",
        "ERROR_OTU2E_OTU2E_BEI":"",
        "ERROR_OTU2E_FEC_FECCORRCW":"",
        "ERROR_OTU2E_FEC_FECCORRSYM":"",
        "ERROR_OTU2E_FEC_FECCORRBIT":"",
        "ERROR_OTU2E_FEC_FECUNCORRCW":"",
        "ERROR_OTU2E_FEC_FECSTRESS":"",
        "ERROR_OTU2E_ODU2E_BIP8":"",
        "ERROR_OTU2E_ODU2E_BEI":"",
        
        "ERROR_OTU2E_BER_BITERROR":"BER",
        
        
        # OTU4 error
        "ERROR_OTU4_OTU4_BIP8":"OTU4_OBIP8",
        "ERROR_OTU4_OTU4_FAS":"FAS",
        "ERROR_OTU4_OTU4_MFAS":"MFAS",
        "ERROR_OTU4_OTU4_BEI":"OTU4_OBEI",
        "ERROR_OTU4_FEC_FECCORRCW":"FCCW",
        "ERROR_OTU4_FEC_FECCORRSYM":"FCSYMB",
        "ERROR_OTU4_FEC_FECCORRBIT":"FCBIT",
        "ERROR_OTU4_FEC_FECUNCORRCW":"FUCW",
        "ERROR_OTU4_FEC_FECSTRESS":"FCSTRESS",
        "ERROR_OTU4_ODU4_BIP8":"ODU4_OBIP8",
        "ERROR_OTU4_ODU4_BEI":"ODU4_OBEI",
        
        "ERROR_OTU4_BER_BITERROR":"BER",
        
        # FC error
        "ERROR_8FC_BER_BITERROR":"BER",
        "ERROR_10FC_BER_BITERROR":"BER",
        
        # OC192 error
        "ERROR_OC192_SECTION_B1":"",
        "ERROR_OC192_SECTION_FASS":"",
        
        "ERROR_OC192_LINE_B2":"",
        "ERROR_OC192_LINE_REIL":"",
        
        "ERROR_OC192_STSPATH_B3":"",
        "ERROR_OC192_STSPATH_REIP":"",
        "ERROR_OC192_BER_BITERROR":"BER",
        
        # STM64 error
        "ERROR_STM64_RS_B1":"",
        "ERROR_STM64_RS_RSFAS":"",
        "ERROR_STM64_MS_B2":"",
        "ERROR_STM64_MS_MSREI":"",
        "ERROR_STM64_AUPATH_B3":"",
        "ERROR_STM64_AUPATH_HPREI":"",
        "ERROR_STM64_BER_BITERROR":"BER"
    }
    
    DICT_PROTOCOL = {
        # protocol
        "PROTOCOL_OTN_OTU4-4LANE":"OTU4_LANE4X25",
        "PROTOCOL_OTN_OTU4-10LANE":"OTU4_LANE10X10",
        "PROTOCOL_OTN_OTU3-4LANE":"OTU3_LANE4X10",
        "PROTOCOL_OTN_OTU2":"OTU2",
        "PROTOCOL_OTN_OTU2E":"OTU2E",

        "PROTOCOL_SONETSDH_OC192":"OC192",
        "PROTOCOL_SONETSDH_STM64":"STM64",

        "PROTOCOL_ETHERNET_100GE-4LANE-SR4":"100GE_LANE4X25_SR4",
        "PROTOCOL_ETHERNET_100GE-4LANE-CLR4":"100GE_LANE4X25_CLR4",
        "PROTOCOL_ETHERNET_100GE-4LANE-CWDM4":"100GE_LANE4X25_CWDM4",
        "PROTOCOL_ETHERNET_100GE-4LANE-OTHER":"100GE_LANE4X25_OTHERS",
        "PROTOCOL_ETHERNET_100GE-10LANE":"100GE_LANE10X10",
        "PROTOCOL_ETHERNET_40GE-4LANE":"40GE_LANE4X10",
        "PROTOCOL_ETHERNET_10GE-LAN":"10GELAN",
        "PROTOCOL_ETHERNET_10GE-WAN":"10GEWAN",
        
        "PROTOCOL_FC_8FC":"8X",
        "PROTOCOL_FC_10FC":"10X",
        
        "10ge":"10GELAN",
        "otu2":"OTU2",
        "otu2e":"OTU2E",
        "oc192":"OC192",
        "stm64":"STM64",
        "40ge":"40GE_LANE4X10",
        "100ge":"100GE_LANE4X25_OTHERS",
        "100ge_SR4":"100GE_LANE4X25_SR4",
        "otu4":"OTU4_LANE4X25",
        "10gfc":"10X",
        "8gfc":"8X"
    }
    
    def __init__(self, strIP, strSlot, strConnector=""):
        self.__IP = strIP
        self.__slot = strSlot
        self.__equipmentType__ = "EXFO"
        self.__connector = strConnector
        exfo = EXFO.Exfo(self.__IP)
        exfo.open()
        exfo.clear(self.__slot)
        exfo.isModuleExisted(self.__slot)
        self.__target = EXFO.ExfoModule(exfo, self.__slot)
        self.__target.connect()
        self.__protocol = None
    
    def __str__(self):
        if "" == self.__connector:
            return "%s \"%s\" slot %s"%(self.__equipmentType__, self.__IP, self.__slot)
        else:
            return "%s \"%s\" slot %s port %s"%(self.__equipmentType__, self.__IP, self.__slot, self.__connector)
    
    # initPort
    # initial port. set protocol, connector, fec type...
    def init(self, strProtocol, **kw):
        print("set protocol on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        self.__target.connect()
        
        self.__protocol = None
        result = True
        
        if strProtocol not in self.DICT_PROTOCOL.keys():
            raise TestPortException("unsupport protocol -- %s"%strProtocol)
            
        if self.__target.isTesting():
            print("%s %s slot %s is testing, stop testing now and set protocol"%(self.__equipmentType__, self.__IP, self.__slot))
            self.__target.stopTest()

        lProtocol = self.DICT_PROTOCOL[strProtocol].split("_")
        if lProtocol[0] in ["100GE", "40GE", "10GE", "10GELAN", "10GEWAN"]:
            result = result and self.__target.setApplication("EBERT")
            time.sleep(3)
            if len(lProtocol) == 1:
                result = result and self.__target.setIfProtocol(lProtocol[0])
                time.sleep(3)
            elif len(lProtocol) >= 2:
                result = result and self.__target.setIfProtocol(lProtocol[1])
                time.sleep(3)
                if len(lProtocol) >= 3:
                    result = result and self.__target.setETHernetPhyType(lProtocol[2])
        elif lProtocol[0] in ["OTU2", "OTU2E", "OTU4"]:
            result = result and self.__target.setApplication("OTNBERT")
            time.sleep(3)
            if len(lProtocol) == 1:
                result = result and self.__target.setIfProtocol(lProtocol[0])
                time.sleep(3)
            elif len(lProtocol) >= 2:
                result = result and self.__target.setIfProtocol(lProtocol[1])

            
        elif lProtocol[0] in ["OC192", "STM64"]:
            result = result and self.__target.setApplication("SONETSDHBERT")
            time.sleep(3)
            result = result and self.__target.setIfProtocol(lProtocol[0])

        elif lProtocol[0] in ["8X", "10X"]:
            result = result and self.__target.setApplication("FCBERT")
            time.sleep(3)
            result = result and self.__target.setIfProtocol(lProtocol[0])
            time.sleep(3)
            result = result and self.__target.setFCLogin("OFF")
            time.sleep(3)
            result = result and self.__target.setFCBuf2BufFlowCtrl("OFF")
            time.sleep(3)
            result = result and self.__target.setFibrePspStatus("OFF")
            
        else:
            raise TestPortException("Unsupported protocol set with EXFO")
        time.sleep(3)
        if lProtocol[0] in ["OTU4", "100GE", "40GE"] and self.__connector != "":
            self.__target.setConnector(self.__connector)
        time.sleep(3)
        # set framing 
        bFrameSet = False
        if lProtocol[0] in ["OTU4", "100GE", "40GE", "10GE", "10GELAN", "10GEWAN"]:
            for key in kw.keys():
                if "FRAMING" == key.upper():
                    self.__target.modifyEtherStructure(kw[key])
                    bFrameSet = True
            if lProtocol[0] in ["100GE", "40GE", "10GE", "10GELAN", "10GEWAN"] and not bFrameSet:
                self.__target.modifyEtherStructure("FRAMEDLAYER2")
        time.sleep(3)
        # set fec type
        if lProtocol[0] in ["OTU2", "OTU2E", "OTU4"]:
            for key in kw.keys():
                if "FECTYPE" == key.upper():
                    self.__target.setOtnfec(kw[key])
            # if lProtocol[0] in ["OTU4"]:
                # self.__target.setODU4TCMStatus(1, "ON")
                # self.__target.setODU4TCMStatus(2, "ON")
                # self.__target.setODU4TCMStatus(3, "ON")
                # self.__target.setODU4TCMStatus(4, "ON")
                # self.__target.setODU4TCMStatus(5, "ON")
                # self.__target.setODU4TCMStatus(6, "ON")

        if lProtocol[0] in ["OTU2", "OTU2E", "OTU4", "100GE", "40GE", "10GE", "10GELAN", "10GEWAN", "OC192", "STM64"]:
            result = result and self.__target.setBertDisruptionMonitoringStatus("ON")
        
        time.sleep(3)
        result = result and self.setLaser("ON")
        
        time.sleep(3)
        if "EBERT" == self.__target.getApplication():
            result = result and self.__target.startTest()
            result = result and self.__target.setEthTrafficTx("OFF")
            result = result and self.clear()
        if result:
            self.__protocol = self.DICT_PROTOCOL[strProtocol]
        else:
            raise TestPortException("failed in setting up protocol on %s"%self)
    
    # get test equipment port protocol,
    # used internal, not available outside
    def getProtocol(self):
        if self.__protocol is None:
            strProtocol = self.__target.getIfProtocol()
            if strProtocol in ["10GELAN", "10GEWAN", "OTU2", "OTU2E", "OC192", "STM64", "8X", "10X"]:
                self.__protocol = strProtocol
            else:
                strApplication = self.__target.getApplication()
                if strApplication in ["OTNBERT"]:
                    if strProtocol in ["LANE4X25", "LANE10X10"]:
                        self.__protocol = "OTU4_%s"%strProtocol
                    elif strProtocol in ["LANE4X10"]:
                        self.__protocol = "OTU3_%s"%strProtocol
                    else:
                        raise TestPortException("unknown protocol type")
                elif strApplication in ["EBERT"]:
                    if strProtocol in ["LANE4X10"]:
                        self.__protocol = "40GE_%s"%strProtocol
                    elif strProtocol in ["LANE10X10"]:
                        self.__protocol = "100GE_%s"%strProtocol
                    elif strProtocol in ["LANE4X25"]:
                        strPhyType = self.__target.getETHernetPhyType()
                        self.__protocol = "100GE_%s_%s"%(strProtocol, strPhyType)
                    else:
                        raise TestPortException("unknown protocol type")
                else:
                    raise TestPortException("unknown protocol type")
        return self.__protocol
    
    # start to send traffic
    def startTx(self):
        print("start tx on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        if "EBERT" == self.__target.getApplication():
            self.__target.setEthTrafficTx("ON")
        else:
            self.__target.startTest()
            
    # stop sending traffic
    def stopTx(self):
        print("stop tx on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        if "EBERT" == self.__target.getApplication():
            self.__target.setEthTrafficTx("OFF")
        else:
            self.__target.stopTest()
    
    # clear statics/error status/alarm status on test port
    def clear(self):
        print("disable rx on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        if self.__target.isTesting():
            return self.__target.RestTotalResult()

    # get test result on test port
    def getTestResult(self):
        print("get statics from %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        strApplication = self.__target.getApplication()
        if "EBERT" == strApplication:
            return self.__target.getEthPortTrafficDetail()
        elif "FCBERT" == strApplication:
            return self.__target.getFCPortTrafficDetail()
        else:
            dictInfo = dict()
            dictInfo["TEST_STATUS"] = self.__target.getTotalResult()
            return dictInfo
    
    # start to inject alarm
    def startInjectAlarm(self, strAlarmType, strAlarmParam=None):
        print("start to inject alarm on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        if "LOS" == self.DICT_ALARM[strAlarmType]:
            if None == strAlarmParam:
                self.__target.startInjectInterfaceAlarm(self.DICT_ALARM[strAlarmType])
            else:
                self.__target.startInjectInterfaceAlarm(self.DICT_ALARM[strAlarmType], strAlarmParam)
        elif self.DICT_ALARM[strAlarmType] in ["LDOWN", "LFAULT", "RFAULT"]:
            if self.getProtocol() in ["10GELAN", "10GEWAN"]:
                self.__target.set10GEtherPhyAlarm(self.DICT_ALARM[strAlarmType])
                self.__target.enable10GEtherPhyAlarm("ON")
            else:
                self.__target.set100GEtherPhyAlarm(self.DICT_ALARM[strAlarmType])
                self.__target.enable100GEtherPhyAlarm("ON")
        elif re.match(r"OTU\dE?_O((BDI)|(AIS))", self.DICT_ALARM[strAlarmType]):
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                self.__target.setProtocolAlarm("OTN", strProtocol, self.DICT_ALARM[strAlarmType].split("_")[1])
                self.__target.enableProtocolAlarm("OTN", strProtocol, "ON")
            else:
                raise TestPortException("unknown protocol type")
        
        elif re.match(r"ODU\dE?_O((BDI)|(AIS))", self.DICT_ALARM[strAlarmType]):
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                self.__target.setProtocolAlarm("OTN", strProtocol.replace("T", "D"), self.DICT_ALARM[strAlarmType].split("_")[1])
                self.__target.enableProtocolAlarm("OTN", strProtocol.replace("T", "D"), "ON")
            else:
                raise TestPortException("unknown protocol type")
        elif self.DICT_ALARM[strAlarmType] in ["LOF", "OOF", "LOM", "OOM", "OBIAE", "OIAE"]:
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                self.__target.setProtocolAlarm("OTN", strProtocol, self.DICT_ALARM[strAlarmType])
                self.__target.enableProtocolAlarm("OTN", strProtocol, "ON")
            else:
                raise TestPortException("unknown protocol type")
        elif self.DICT_ALARM[strAlarmType] in ["OLCK", "OOCI", "OFSF", "OBSF", "OFSD", "OBSD"]:
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                self.__target.setProtocolAlarm("OTN", strProtocol.replace("T", "D"), self.DICT_ALARM[strAlarmType])
                self.__target.enableProtocolAlarm("OTN", strProtocol.replace("T", "D"), "ON")
            else:
                raise TestPortException("unknown protocol type")
        elif re.match(r"((SECTION)|(RS))_((SEF)|(LOF))1", self.DICT_ALARM[strAlarmType]):
            self.__target.setProtocolAlarm("SDHSONET", "SECTION", self.DICT_ALARM[strAlarmType].split("_")[1])
            self.__target.enableProtocolAlarm("SDHSONET", "SECTION", "ON")
        elif re.match(r"((LINE)|(MS))_((RDI)|(AIS))", self.DICT_ALARM[strAlarmType]):
            self.__target.setProtocolAlarm("SDHSONET", "LINE", self.DICT_ALARM[strAlarmType].split("_")[1])
            self.__target.enableProtocolAlarm("SDHSONET", "LINE", "ON")
        else:
            raise TestPortException("unknown alarm type")
            
            
    # start to inject error
    def startInjectError(self, strErrorType, strErrorParam=None):
        print("start to inject error on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        if "BER" == self.DICT_ERROR[strErrorType]:
            if str(strErrorParam).isdigit():
                self.__target.startInjectFCBer(strErrorParam, "MANUAL")
            else:
                self.__target.startInjectFCBer(strErrorParam, "AUTOMATED")
        elif "FCS" == self.DICT_ERROR[strErrorType]:
            # self.__target.set10GEtherPhyAlarm(self.DICT_ERROR[strErrorType])
            # self.__target.enable10GEtherPhyAlarm("ON")
            if strErrorParam is None:
                self.__target.startInjectProtocolError(self.DICT_ERROR[strErrorType], "1.0E-06")
            else:
                self.__target.startInjectProtocolError(self.DICT_ERROR[strErrorType], strErrorParam)
        elif self.DICT_ERROR[strErrorType] in ["OTU2_OBIP8", "OTU4_OBIP8", "ODU2_OBIP8", "ODU4_OBIP8", "OTU2E_OBIP8", "ODU2E_OBIP8"]:
            if str(strErrorParam).isdigit():
                self.__target.startInjectOTNBip8(self.DICT_ERROR[strErrorType], strErrorParam, "MANUAL")
            else:
                self.__target.startInjectOTNBip8(self.DICT_ERROR[strErrorType], strErrorParam, "AUTOMATED")
        elif self.DICT_ERROR[strErrorType] in ["FAS", "MFAS"]:
            self.__target.startInjectOTNError("OTU4", "OTU4", self.DICT_ERROR[strErrorType], strErrorParam)
        elif self.DICT_ERROR[strErrorType] in ["OTU4_OBEI", "ODU4_OBEI"]:
            self.__target.startInjectOTNError("OTU4", self.DICT_ERROR[strErrorType].split("_")[0], 
                                            self.DICT_ERROR[strErrorType].split("_")[1], strErrorParam)
        elif self.DICT_ERROR[strErrorType] in  ["FCCW", "FCSYMB", "FCBIT", "FUCW", "FCSTRESS"]:
            self.__target.startInjectOTNError("OTU4", "FEC", 
                                            self.DICT_ERROR[strErrorType], strErrorParam)
        elif self.DICT_ERROR[strErrorType] in ["BLOCk", "BIP8"]:
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["100GE"]:
                self.__target.injectEthernePcsError(self.DICT_ERROR[strErrorType], strErrorParam)
            else:
                raise TestPortException("unsupport protocol type")
        else:
            raise TestPortException("unknown error type")
    
    # stop injecting alarm
    def stopInjectAlarm(self, strAlarmType):
        print("stop injecting alarm on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        if "LOS" == self.DICT_ALARM[strAlarmType]:
            self.__target.stopInjectInterfaceAlarm(self.DICT_ALARM[strAlarmType])
        elif self.DICT_ALARM[strAlarmType] in ["LDOWN", "LFAULT", "RFAULT"]:
            if self.getProtocol() in ["10GELAN", "10GEWAN"]:
                self.__target.enable10GEtherPhyAlarm("OFF")
            else:
                self.__target.enable100GEtherPhyAlarm("OFF")
        elif re.match(r"OTU\dE?_O((BDI)|(AIS))", self.DICT_ALARM[strAlarmType]):
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                
                self.__target.enableProtocolAlarm("OTN", strProtocol, "OFF")
            else:
                raise TestPortException("unknown protocol type")
        
        elif re.match(r"ODU\dE?_O((BDI)|(AIS))", self.DICT_ALARM[strAlarmType]):
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                
                self.__target.enableProtocolAlarm("OTN", strProtocol.replace("T", "D"), "OFF")
            else:
                raise TestPortException("unknown protocol type")
        elif self.DICT_ALARM[strAlarmType] in ["LOF", "OOF", "LOM", "OOM", "OBIAE", "OIAE"]:
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                self.__target.enableProtocolAlarm("OTN", strProtocol, "OFF")
            else:
                raise TestPortException("unknown protocol type")
        elif self.DICT_ALARM[strAlarmType] in ["OLCK", "OOCI", "OFSF", "OBSF", "OFSD", "OBSD"]:
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["OTU2","OTU2E","OTU4"]:
                self.__target.enableProtocolAlarm("OTN", strProtocol.replace("T", "D"), "OFF")
            else:
                raise TestPortException("unknown protocol type")
        elif re.match(r"((SECTION)|(RS))_((SEF)|(LOF))1", self.DICT_ALARM[strAlarmType]):
            self.__target.enableProtocolAlarm("SDHSONET", "SECTION", "OFF")
        elif re.match(r"((LINE)|(MS))_((RDI)|(AIS))", self.DICT_ALARM[strAlarmType]):
            self.__target.enableProtocolAlarm("SDHSONET", "LINE", "OFF")
        else:
            raise TestPortException("unknown alarm type")
            
            
    # stop injecting error
    def stopInjectError(self, strErrorType):
        print("stop injecting error on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__slot))
        if "BER" == self.DICT_ERROR[strErrorType]:
            self.__target.stopInjectFCBer()
        elif "FCS" == self.DICT_ERROR[strErrorType]:
            self.__target.stopInjectProtocolError(self.DICT_ERROR[strErrorType])
        elif self.DICT_ERROR[strErrorType] in ["OTU2_OBIP8", "OTU4_OBIP8", "ODU2_OBIP8", "ODU4_OBIP8", "OTU2E_OBIP8", "ODU2E_OBIP8"]:
            self.__target.stopInjectOTNBip8(self.DICT_ERROR[strErrorType])
        elif self.DICT_ERROR[strErrorType] in ["FAS", "MFAS"]:
            self.__target.stopInjectOTNError("OTU4", "OTU4", self.DICT_ERROR[strErrorType])
        elif self.DICT_ERROR[strErrorType] in ["OTU4_OBEI", "ODU4_OBEI"]:
            self.__target.stopInjectOTNError("OTU4", self.DICT_ERROR[strErrorType].split("_")[0], 
                                            self.DICT_ERROR[strErrorType].split("_")[1])
        elif self.DICT_ERROR[strErrorType] in  ["FCCW", "FCSYMB", "FCBIT", "FUCW", "FCSTRESS"]:
            self.__target.stopInjectOTNError("OTU4", "FEC", 
                                            self.DICT_ERROR[strErrorType])
        elif self.DICT_ERROR[strErrorType] in ["BLOCk", "BIP8"]:
            strProtocol = self.getProtocol().split("_")[0]
            if strProtocol in ["100GE"]:
                self.__target.stopInjectEthernePcsError(self.DICT_ERROR[strErrorType])
            else:
                raise TestPortException("unsupport protocol type")
        else:
            raise TestPortException("unknown error type")
    
    # set ethernet stream before test ethernet traffic
    def setEthernetStream(self, **kw):
        strApplication = self.__target.getApplication()
        if "EBERT" == strApplication:
            for key in kw.keys():
                if "FRAMESIZE" == key.upper():
                    #self.__target.setFrameSizeType("1", "FIXED")
                    self.__target.setFrameSize(str(kw[key]))
                elif "TXRATE" == key.upper():
                    self.__target.setFrameRate(str(kw[key]))
                elif "DSTMAC" == key.upper():
                    self.__target.setEthDesMAC(str(kw[key]))
                elif "FCS" == key.upper():
                    if kw[key] is True:
                        self.__target.startInjectProtocolError("FCS", "MAXRATE")
                    else:
                        self.__target.stopInjectProtocolError("FCS")
                else:
                    print("unsupport parameter %s"%key)
                    # raise TestPortException("unsupport parameter %s"%key)
        else:
            print("setEthernetStream is not available when application is %s on %s"%(strApplication, self))
            raise TestPortException("setEthernetStream is not available when application is %s on %s"%(strApplication, self))
            
    def generateEthPm(self, strPmItem, nDuration=30, **kw):
        if strPmItem in ["OCTSTX", "PKTSTX"]:
            if "FRAMESIZE" not in kw.keys():
                kw["FRAMESIZE"] = random.randint(48, 16000)

        elif strPmItem in ["OCTSTXOK", "PKTSTXOK"]:
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False

        elif strPmItem == "PKTSMCSTTX":
            if "DSTMAC" in kw.keys():
                if "ff:ff:ff:ff:ff" == kw["DSTMAC"] or not int(kw["DSTMAC"].split(":")[0], 16) & 0b00000001:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "01:00:00:00:00:01"

            
        elif strPmItem == "PKTSBCSTTX":
            if "DSTMAC" in kw.keys():
                if "ff:ff:ff:ff:ff" != kw["DSTMAC"]:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "ff:ff:ff:ff:ff:ff"
                
        elif strPmItem == "PKTSUCSTTX":
            if "DSTMAC" in kw.keys():
                if int(kw["DSTMAC"].split(":")[0], 16) & 0b00000001:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "00:01:00:00:00:01"
            
        elif strPmItem == "PKTSUSZETX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) >= 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(48, 63)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "PKTSOSZETX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) <= 9600:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(9601, 16000)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "FRGMTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) >= 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(48, 63)
            if "FCS" in kw.keys():
                if kw["FCS"] is not True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = True
            
            
        elif strPmItem == "JABBERTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) <= 9600:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(9601, 16000)
            if "FCS" in kw.keys():
                if kw["FCS"] is not True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = True
            
            
        # elif strPmItem == "PKTSPAUSTX":
            # if "PAUSE" in kw.keys():
                # if kw["PAUSE"] is not True:
                    # print("PAUSE should not be %s when pm item is %s"%(kw["PAUSE"], strPmItem))
            # else:
                # kw["PAUSE"] = True
                
        elif strPmItem == "PKTS64OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) != 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = 64
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS65-127OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 127 or int(kw["FRAMESIZE"]) < 65:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(65, 127)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS128-255OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 255 or int(kw["FRAMESIZE"]) < 128:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(128, 255)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS256-511OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 511 or int(kw["FRAMESIZE"]) < 256:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(256, 511)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS512-1023OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 1023 or int(kw["FRAMESIZE"]) < 512:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(512, 1023)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS1024-1518OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 1518 or int(kw["FRAMESIZE"]) < 1024:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(1024, 1518)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "PKTSOVER-1518OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) < 1518:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(1518, 9600)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
                
                
        if "FCS" not in kw.keys():
            kw["FCS"] = False
        # if "PAUSE" not in kw.keys():
            # kw["PAUSE"] = False
            
        bFCS = kw["FCS"]
        # bPause = kw["PAUSE"]
        
        kw["FCS"] = False
        # del kw["PAUSE"]
        
        # if bFCS and bPause:
            # print("FCS and PAUSE should not be injected at the same time")
            # return False
        
            
        self.stopTx()
        self.clear()
        
        self.setEthernetStream(**kw)
        
        self.startTx()
        timer0 = time.time()
        nFCS = 0
        # nPause = 0

        if bFCS:
            while (time.time() - timer0) < nDuration:
                temp = random.randint(1, 50)
                self.__target.startInjectProtocolError("FCS", temp)
                nFCS += temp
                time.sleep(1)
        # elif bPause:
            # while (time.time() - timer0) < nDuration:
                # self.__target.ethInjectPause(self.getProtocol(), "single")
                # nPause += 1
        while (time.time() - timer0) < nDuration:
            time.sleep(1)
        self.stopTx()
        
        time.sleep(10)
        # provide pm item your self
        # related to package framesize/dstmac/crc/pause
        if "FRAMESIZE" in kw.keys():
            framesize = kw["FRAMESIZE"]
        else:
            framesize = self.__target.getFrameSize()
        if "DSTMAC" in kw.keys():
            dstmac = kw["DSTMAC"]
        else:
            dstmac = self.__target.getEthDesMAC()
        
        print("framesize:%s"%framesize)
        print("dest mac:%s"%dstmac)
        
        dictTxPM = dict()
        
        timer0 = time.time()
        
        preTxTotal = -1
        bFinalResult = False
        while (time.time() - timer0) < 30:
            portTrafficDetail = self.__target.getEthPortTrafficDetail()
            if preTxTotal == portTrafficDetail["TX_PACKAGE_TOTAL"]:
                bFinalResult = True
                break
            else:
                preTxTotal = portTrafficDetail["TX_PACKAGE_TOTAL"]
                time.sleep(3)
                
        if not bFinalResult:
            print("the test statics keeps changing for 30 seconds after traffic stop on %s"%self)
            raise TestPortException("the test statics keep changing for 30 seconds after traffic stop on %s"%self)
        
        dictTxPM["PKTSTX"] = portTrafficDetail["TX_PACKAGE_TOTAL"]
        dictTxPM["OCTSTX"] = portTrafficDetail["TX_PACKAGE_TOTAL"] * framesize
        
        # broadcast/multicast/unicast
        if "FF:FF:FF:FF:FF:FF" == dstmac.upper():
            dictTxPM["PKTSBCSTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTSMCSTTX"] = 0
            dictTxPM["PKTSUCSTTX"] = 0
        elif int(dstmac.split(":")[0], 16) & 0b00000001:
            dictTxPM["PKTSBCSTTX"] = 0
            dictTxPM["PKTSMCSTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTSUCSTTX"] = 0
        else:
            dictTxPM["PKTSBCSTTX"] = 0
            dictTxPM["PKTSMCSTTX"] = 0
            dictTxPM["PKTSUCSTTX"] = dictTxPM["PKTSTX"]
            
        if framesize < 64:
            dictTxPM["PKTSUSZETX"] = dictTxPM["PKTSTX"] - nFCS
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = nFCS
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
            
        elif framesize == 64:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 128:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 256:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 512:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 1024:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize <= 1518:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize <= 9600:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = dictTxPM["PKTSTX"]
        else:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = dictTxPM["PKTSTX"] - nFCS
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = nFCS
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
            
        for key in dictTxPM.keys():
            print("%s:%s"%(key, str(dictTxPM[key])))
        return dictTxPM
    
    # set Laser status
    def setLaser(self, strStatus):
        return self.__target.setLaserState(strStatus)
    
    # get alarm info on test port
    def checkAlarm(self, strAlarmType):
        if self.DICT_ALARM[strAlarmType] in ["LOF", "OOF", "LOM"]:
            if "PRESENT" == self.__target.getCurrentOTU4Alarm(self.DICT_ALARM[strAlarmType]):
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] in ["ODU4_OAIS", "ODU4_OBDI"]:
            if "PRESENT" == self.__target.getCurrentODU4Alarm(self.DICT_ALARM[strAlarmType].split("_")[1]):
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] in ["LINE_RDI", "MS_RDI"]:
            if "PRESENT" == self.__target.getCurrentSONETAlarm(self.DICT_ALARM[strAlarmType]):
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] == "OTU4_OBDI":
            if "PRESENT" == self.__target.getCurrentOTU4Alarm("OBDI"):
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] == "ODU2_OBDI":
            if "PRESENT" == self.__target.getCurrentODU2Alarm(self.DICT_ALARM[strAlarmType]):
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] == "ODU2E_OBDI":
            if "PRESENT" == self.__target.getCurrentODU2eAlarm(self.DICT_ALARM[strAlarmType]):
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] in ["LFAULT", "RFAULT"]:
            if "PRESENT" == self.__target.getCurrentEthernetAlarm(self.DICT_ALARM[strAlarmType]):
                return "ON"
            else:
                return "OFF"    
        else:
            raise TestPortException("unknown test alarm type -- %s"%strAlarmType)
    
    def setOTUSMTTITraces(self, strMode, strDirection, strValue):
        if  strMode.upper() in ["DAPI", "SAPI"]:
            if "Expected" == strDirection:
                self.__target.setOTUSMTTITracesStatus(strMode, "ON")
                self.__target.setOTUSMTTITracesExpected(strMode, strValue)
            elif "Received" == strDirection:
                self.__target.setOTUSMTTITracesReceived(strMode, strValue)
        elif "OPERATOR" == strMode.upper():
            self.__target.setOTUSMTTITracesOperator(strValue)
        else:
            raise TestPortException("unknown strMode -- %s"%strMode)
            
    def setODUPMTTITraces(self, strMode, strDirection, strValue):
        if  strMode.upper() in ["DAPI", "SAPI"]:
            if "Expected" == strDirection:
                self.__target.setODUPMTTITracesStatus(strMode, "ON")
                self.__target.setODUPMTTITracesExpected(strMode, strValue)
            elif "Received" == strDirection:
                self.__target.setODUPMTTITracesReceived(strMode, strValue)
        elif "OPERATOR" == strMode.upper():
            self.__target.setODUPMTTITracesOperator(strValue)
        else:
            raise TestPortException("unknown strMode -- %s"%strMode)

    def setOTNFEC(self, strMode):
        self.__target.setOtu2fec(strMode)


    # release the test port
    def tearDown(self):
        self.setLaser("OFF")
        self.__target.stopTest()
        self.__target.disconnect()

    
class JdsuPort():
    '''
    class for test set - JDSU.
    '''
    DICT_ALARM = {
        # OTU2 alarm
        "ALARM_OTU2_IF_LOS":"los",
        "ALARM_OTU2_OTU2_LOF":"lof",
        # "ALARM_OTU2_OTU2_OOF":"OOF",
        "ALARM_OTU2_OTU2_LOM":"lom",
        # "ALARM_OTU2_OTU2_OOM":"OOM",
        "ALARM_OTU2_OTU2_AIS":"otu2_ais",
        "ALARM_OTU2_OTU2_BDI":"otu2_bdi",
        "ALARM_OTU2_OTU2_IAE":"iae",
        "ALARM_OTU2_OTU2_BIAE":"biae",

        "ALARM_OTU2_ODU2_AIS":"odu2_ais",
        "ALARM_OTU2_ODU2_OCI":"oci",
        "ALARM_OTU2_ODU2_LCK":"lck",
        "ALARM_OTU2_ODU2_BDI":"odu2_bdi",
        # "ALARM_OTU2_ODU2_FSF":"OFSF",
        # "ALARM_OTU2_ODU2_BSF":"OBSF",
        # "ALARM_OTU2_ODU2_FSD":"OFSD",
        # "ALARM_OTU2_ODU2_BSD":"OBSD",
        # "ALARM_OTU2_OPU2_AIS":"",
        # "ALARM_OTU2_OPU2_CSF":"",
        # "ALARM_OTU2_BER_PATTERNLOSS":"",
        
        # OTU2E alarm
        "ALARM_OTU2E_IF_LOS":"los",
        "ALARM_OTU2E_OTU2E_LOF":"lof",
        # "ALARM_OTU2E_OTU2E_OOF":"OOF",
        "ALARM_OTU2E_OTU2E_LOM":"lom",
        # "ALARM_OTU2E_OTU2E_OOM":"OOM",
        "ALARM_OTU2E_OTU2E_AIS":"otu2e_ais",
        "ALARM_OTU2E_OTU2E_BDI":"otu2e_bdi",
        "ALARM_OTU2E_OTU2E_IAE":"iae",
        "ALARM_OTU2E_OTU2E_BIAE":"biae",

        "ALARM_OTU2E_ODU2E_AIS":"odu2e_ais",
        "ALARM_OTU2E_ODU2E_OCI":"oci",
        "ALARM_OTU2E_ODU2E_LCK":"lck",
        "ALARM_OTU2E_ODU2E_BDI":"odu2e_bdi",
        # "ALARM_OTU2E_ODU2E_FSF":"OFSF",
        # "ALARM_OTU2E_ODU2E_BSF":"OBSF",
        # "ALARM_OTU2E_ODU2E_FSD":"OFSD",
        # "ALARM_OTU2E_ODU2E_BSD":"OBSD",
        # "ALARM_OTU2E_OPU2E_AIS":"",
        # "ALARM_OTU2E_OPU2E_CSF":"",
        # "ALARM_OTU2E_BER_PATTERNLOSS":"",
        
        # OC192 alarm
        "ALARM_OC192_IF_LOS" : "los",
        "ALARM_OC192_SECTION_LOFS" : "lof",
        "ALARM_OC192_LINE_AISL" : "lais",
        "ALARM_OC192_LINE_RDIL" : "lrdi",
        "ALARM_OC192_STSPATH_AISP" : "pais",
        "ALARM_OC192_STSPATH_LOPP" : "plop",
        "ALARM_OC192_STSPATH_RDIP" : "prdi",
        "ALARM_OC192_STSPATH_ERDIPPD" : "perdipayload",
        "ALARM_OC192_STSPATH_ERDIPSD" : "perdiserver",
        "ALARM_OC192_STSPATH_ERDIPCD" : "perdiconn",
        "ALARM_OC192_STSPATH_UNEQP" : "puneq",
        
        # STM64 alarm
        "ALARM_STM64_IF_LOS" : "los",
        "ALARM_STM64_RS_RSLOF" : "lof",
        "ALARM_STM64_MS_MSAIS" : "msais",
        "ALARM_STM64_MS_MSRDI" : "msrdi",
        "ALARM_STM64_AUPATH_AUAIS" : "auais",
        "ALARM_STM64_AUPATH_AULOP" : "aulop",
        "ALARM_STM64_AUPATH_HPRDI" : "hprdi",
        "ALARM_STM64_AUPATH_HPERDIPPD" : "hperdipayload",
        "ALARM_STM64_AUPATH_HPERDIPSD" : "hperdiserver",
        "ALARM_STM64_AUPATH_HPERDIPCD" : "hperdiconn",
        "ALARM_STM64_AUPATH_HPUNEQ" : "hpuneq",
        
        # 10FC alarm
        "ALARM_10FC_IF_LOS":"los",
        "ALARM_10FC_PCS_LOSYNC":"losync",
        "ALARM_10FC_PCS_LF":"lf",
        "ALARM_10FC_PCS_RF":"rf",
        "ALARM_10FC_PCS_HIBER":"hi_ber",
        
        # Ethernet alarm
        "ALARM_ETHERNET_IF_LOS":"los",
        "ALARM_ETHERNET_ETH_LOSYNC":"losync",
        "ALARM_ETHERNET_ETH_LF":"lf",
        "ALARM_ETHERNET_ETH_RF":"rf",
        "ALARM_ETHERNET_PCS_HIBER":"hi_ber"
    }
    
    
    DICT_ERROR = {
        # OTU2 error
        "ERROR_OTU2_OTU2_BIP8":"otu2_bip8",
        # "ERROR_OTU2_OTU2_FAS":"",
        # "ERROR_OTU2_OTU2_MFAS":"",
        "ERROR_OTU2_OTU2_BEI":"otu2_bei",
        # "ERROR_OTU2_FEC_FECCORRCW":"",
        # "ERROR_OTU2_FEC_FECCORRSYM":"",
        # "ERROR_OTU2_FEC_FECCORRBIT":"",
        # "ERROR_OTU2_FEC_FECUNCORRCW":"",
        # "ERROR_OTU2_FEC_FECSTRESS":"",
        "ERROR_OTU2_ODU2_BIP8":"odu2_bip8",
        "ERROR_OTU2_ODU2_BEI":"odu2_bei",
        
        # "ERROR_OTU2_BER_BITERROR":"BER",
        
        # OTU2E error
        "ERROR_OTU2E_OTU2E_BIP8":"otu2e_bip8",
        # "ERROR_OTU2E_OTU2E_FAS":"",
        # "ERROR_OTU2E_OTU2E_MFAS":"",
        "ERROR_OTU2E_OTU2E_BEI":"otu2e_bei",
        "ERROR_OTU2_OTU2_FEC":"fec",
        # "ERROR_OTU2E_FEC_FECCORRCW":"",
        # "ERROR_OTU2E_FEC_FECCORRSYM":"",
        # "ERROR_OTU2E_FEC_FECCORRBIT":"",
        # "ERROR_OTU2E_FEC_FECUNCORRCW":"",
        # "ERROR_OTU2E_FEC_FECSTRESS":"",
        "ERROR_OTU2E_ODU2E_BIP8":"odu2e_bip8",
        "ERROR_OTU2E_ODU2E_BEI":"odu2e_bei",
        
        # "ERROR_OTU2E_BER_BITERROR":"BER",
        
        
        "ERROR_OC192_SECTION_B1" : "b1",
        "ERROR_OC192_LINE_B2" : "b2",
        "ERROR_OC192_STSPATH_B3" : "b3",
        "ERROR_OC192_LINE_REIL" : "lrei",
        "ERROR_OC192_STSPATH_REIP" : "prei",
        "ERROR_OC192_BER_BITERROR":"BER",

        "ERROR_STM64_RS_B1" : "b1",
        "ERROR_STM64_MS_B2" : "b2",
        "ERROR_STM64_AUPATH_B3" : "b3",
        "ERROR_STM64_MS_MSREI" : "msrei",
        "ERROR_STM64_AUPATH_HPREI" : "hprei",
        "ERROR_STM64_BER_BITERROR":"BER",
        
        "ERROR_10FC_FC2_CRC": "fc2crcerror",
        "ERROR_10FC_PCS_INVALIDBLOCKTYPE": "invalidblocktype",
        "ERROR_10FC_BER_BITERROR":"BER",
        
        "ERROR_ETHERNET_BER_BITERROR":"BER",
        "ERROR_ETHERNET_ETH_FCS":"FCS",
        "ERROR_ETHERNET_MAC_PAUSE":"pause"
    }
    DICT_PROTOCOL = {
        "PROTOCOL_OTN_OTU2":"otu2_sonetsdh",
        "PROTOCOL_OTN_OTU2E":"11.095fec_10gbelan",
        "PROTOCOL_SONETSDH_OC192":"oc192",
        "PROTOCOL_SONETSDH_STM64":"stm64",
        "PROTOCOL_ETHERNET_10GE-LAN":"10gbelan",
        "PROTOCOL_FC_10FC":"10gfc",
        # protocol
        "10ge":"10gbelan",
        "oc192":"oc192",
        "stm64":"stm64",
        "10gfc":"10gfc",
        "otu2":"otu2_sonetsdh",
        "otu2e":"11.095fec_10gbelan"
    }

    # ------------------------------------------------------------------ __init__
    def __init__(self, strIP):
        '''
        Setup the test set. 
        create target
        restore the test set port info
        initial the port

        @type tsinfo: List
        @param tsinfo: include all port setup info

        '''
        self.__equipmentType__ = "JDSU"
        self.__ip = strIP
        self.__tsTout = '1200'
        self.__target = InnocorSession(self.__ip, self.__tsTout) # ip, timeout
        self.__target.open()
        ok_(self.__target.isOpen())
        self.__target.testStop()
        self.__lPortInfo = None # update in self.init() e.g. ['10ge','no-fec']
        
        

    # ------------------------------------------------------------------ __srt__
    def __str__(self):
        '''
        Return test set info
        
        @rtype: Str
        @return: "JDSU - IP: xxx.xxx.xxx.xxx ;"
        '''
        
        return "JDSU - [IP: %s ; Timeout: %s]" % (self.__ip, self.__tsTout)
        
        
    # --------------------------------------------------------------------- close
    def tearDown(self):
        '''
        Release the test set
        
        @rtype: Boolean
        @return: True|False
        '''
        self.__target.testStop()
        self.__target.close()


    # -------------------------------------------------------------------- isOpen
    def isOpen(self):
        '''
        Check if the test set if open

        @rtype: Boolean
        @return: True|False
        '''
        
        return self.__target.isOpen()


    # ================================  Basic  =======================================
    # -------------------------------------------------------------------- init
    def init(self, strProtocol, **kw):
        '''
        init the port
        
        @type: strProtocol: Str
        @param: strProtocol: protocol
        
        @rtype: Boolean
        @return: True|False
        '''
        if strProtocol not in self.DICT_PROTOCOL.keys():
            raise TestPortException("unsupport protocol")
            
        self.__target.testStop()
        
        self.__protocol = None

        protocol = self.DICT_PROTOCOL[strProtocol]

        # restore portinfo
        # self.__lPortInfo = [protocol, fec]
        
        cr = True  # Call return
        
        # Set protocol
        if protocol in ['oc192', 'stm64']:  # oc192, stm64 & otu2
            cr &= self.__target.setSysProtocols("sonetsdh") is 0
            if protocol == 'oc192':
                self.__target.setCarrierType("sonet")
            elif protocol == 'stm64':
                self.__target.setCarrierType("sdh")
        elif protocol in ['otu2_sonetsdh']:
            cr &= self.__target.setSysProtocols(protocol) is 0
        elif protocol in ['11.095fec_10gbelan', '10gbelan', 'otu2_10gbewan',
                '11.049fec_10gbelan']:  # otu2e
            cr &= self.__target.setSysProtocols(protocol) is 0
            cr &= self.__target.set10geTxFrameSendMode("continuous") is 0  # Set frame send mode (according to lib_TDM, only 10ge do this. Frame?)
            # cr &= self.__target.StatsMonStart() is 0  # Start stats moniter (according to lib_TDM, only 10ge do this. Frame?)
        elif protocol in ['10gfc']:
            cr &= self.__target.setSysProtocols(protocol) is 0
            cr &= self.__target.set10gfcTxFrameSendMode("continuous") is 0  # Set frame send mode (according to lib_TDM, only 10ge do this. Frame?)
            # cr &= self.__target.StatsMonStart() is 0  # Start stats moniter (according to lib_TDM, only 10ge do this. Frame?)
        else:
            raise TestPortException('Invalid protocol')
        
        
        # Set fec
        for key in kw.keys():
            if 'FECTYPE' == key.upper():
                if "no-fec" == kw[key]:
                    cr &= self.__target.setOtnFecMode('all0s') is 0 
                    cr &= self.__target.setOtnFecErrorSuppression('fec') is 0
                elif 'g-fec' == kw[key]:
                    cr &= self.__target.setOtnFecMode('gfec') is 0 
                    cr &= self.__target.setOtnFecErrorSuppression('-fec') is 0
                else:
                    raise TestPortException('Invalid fec -- %s'%kw[key])
            else:
                raise TestPortException('Invalid attribution -- %s'%key)
                
        if protocol in ['11.095fec_10gbelan', '10gbelan', 'otu2_10gbewan',
                '11.049fec_10gbelan', '10gfc']:
            cr &= self.__target.StatsMonStart() is 0  # Start stats moniter (according to lib_TDM, only 10ge do this. Frame?)
            
        # Open laser
        cr &= self.setLaser('ON')
        
        # Delay for swap protocol
        # time.sleep(3)
        

                
        # if protocol is '10gbelan':  # 10ge have *None* fec value
            # pass
        
        # elif fec is 'no-fec':  # no-fec
            # cr &= self.__target.setOtnFecMode('all0s') is 0 
            # cr &= self.__target.setOtnFecErrorSuppression('fec') is 0 
            
        # elif fec is 'g-fec':  # g-fec
            # cr &= self.__target.setOtnFecMode('gfec') is 0 
            # cr &= self.__target.setOtnFecErrorSuppression('-fec') is 0 
        
        # else:
            # self.__errorPrint('Invalid fec')
            # return False

        if cr:  # Call all success
            self.__protocol = self.DICT_PROTOCOL[strProtocol]
            return True
        raise TestPortException("failed in setting up protocol on %s"%self)
        
    
    # get test equipment port protocol,
    # used internal, not available outside
    def getProtocol(self):
        if self.__protocol is None:
            strProtocol = self.__target.getSysProtocols()
            if strProtocol in ["10gfc", "10gbelan"]:
                self.__protocol = strProtocol
            elif strProtocol in ["sonetsdh"]:
                strCarrierType = self.__target.getCarrierType()
                if "sdh" == strCarrierType:
                    self.__protocol = "stm64"
                elif "sonet" == strCarrierType:
                    self.__protocol = "oc192"
                else:
                    raise TestPortException("unexpected Carrier Type -- %s on %s"%(strCarrierType, self))
            else:
                print("unexpected protocol -- %s on %s"%(strProtocol, self))
        return self.__protocol
        
    # -------------------------------------------------------------------- setLaser
    def setLaser(self, state):
        '''
        set Laser
        
        @type state: Str
        @param state: 'ON'|'OFF'
        
        @rtype: Boolean
        @return: True|False
        '''
        
        cr = True  # Call return
        
        if state is 'ON':  # Turn On laser
            cr &= self.__target.setCarrierTxlaser('on') is 0
            
        elif state is 'OFF':  # Turn Off laser
            cr &= self.__target.setCarrierTxlaser('off') is 0
            
        else:
            raise TestPortException('Invalid state')

        if cr:  # Call all success
            return True
        return TestPortException("failed in setting laser on %s"%self)
    
    
    # ================================  Traffic  ======================================
    # -------------------------------------------------------------------- startTx
    def startTx(self):
        '''
        start traffic
        
        @rtype: Boolean
        @return: True|False
        '''
        
        cr = True  # Call return
        
        # Start Tx
        if self.getProtocol() in ['11.095fec_10gbelan', '10gbelan', 'otu2_10gbewan',
                '11.049fec_10gbelan', "10gfc"]:
            cr &= self.__target.TrafficStart() is 0
        else:
            cr &= self.__target.testStart() is 0
            
        # if self.__lPortInfo[0] is '10gbelan':  # 10ge
            # cr &= self.__target.TrafficStart() is 0
        
        # else:
            # cr &= self.__target.testStart() is 0
            
        if cr:  # Call all success
            return True
        raise TestPortException("failed in starting tx on %s"%self)
            

    # -------------------------------------------------------------------- stopTx
    def stopTx(self):
        '''
        stop traffic
        
        @rtype: Boolean
        @return: True|False
        '''
        
        cr = True  # Call return
        
        # Stop Tx
        if self.getProtocol() in ['11.095fec_10gbelan', '10gbelan', 'otu2_10gbewan',
                '11.049fec_10gbelan', "10gfc"]:
            cr &= self.__target.TrafficStop() is 0
        else:
            cr &= self.__target.testStop() is 0
            
        # if self.__lPortInfo[0] is '10gbelan':  # 10ge
            # cr &= self.__target.TrafficStop() is 0
        
        # else:
            # cr &= self.__target.testStop() is 0
            
        if cr:  # Call all success
            return True
        raise TestPortException("failed in stoping tx on %s"%self)


    # -------------------------------------------------------------------- getTestResult
    def getTestResult(self):
        '''
        get Test Result
        
        @rtype: Boolean
        @return: False
        
        @rtype: Dict
        @return: {'TX':'11111', 'RX':'2222222'}/{'TX':'OK','RX':'OK'} 
        '''
        
        dTrafficResult = {}
        cr = True  # Call return
        
        
        # Get Tx result
        if self.getProtocol() in ['10gbelan']:  # 10ge
            dTrafficResult["TX_PACKAGE_TOTAL"] = int(self.__target.get10geTxFrames())
            dTrafficResult["RX_PACKAGE_TOTAL"] = int(self.__target.get10geRxFrames())
            dTrafficResult["TX_BYTE_TOTAL"] = int(self.__target.get10geTxOctets())
            dTrafficResult["RX_BYTE_TOTAL"] = int(self.__target.get10geRxOctets())
        elif "10gfc" == self.getProtocol():  # Other protocol
            dTrafficResult["TX_PACKAGE_TOTAL"] = int(self.__target.get10gfcTxFrames())
            dTrafficResult["RX_PACKAGE_TOTAL"] = int(self.__target.get10gfcRxFrames())
            dTrafficResult["TX_BYTE_TOTAL"] = int(self.__target.get10gfcTxOctets())
            dTrafficResult["RX_BYTE_TOTAL"] = int(self.__target.get10gfcRxOctets())
        elif self.getProtocol() in ["oc192", "stm64", '11.095fec_10gbelan', 'otu2_10gbewan',
                '11.049fec_10gbelan', 'otu2_sonetsdh']:
            majError = self.__target.getTestMajorerror()
            minError = self.__target.getTestMinorerror()
            print(majError)
            print(minError)
            # Check result
            for i in [majError, minError]:
                getSuccess = False
                if 'hist' in i:
                    getSuccess = True
                elif 'off' in i:
                    getSuccess = True
                elif 'on' in i:
                    getSuccess = True
                if not getSuccess:
                    raise TestPortException("failed in getting test result on %s"%self)
                
            # Generate Rx
            if 'off' == majError.strip() and 'off' == minError.strip():
                dTrafficResult["TEST_STATUS"] = 'PASS'
            else:
                dTrafficResult["TEST_STATUS"] = 'FAIL'
        if cr:  # Call all success
            return dTrafficResult

    # -------------------------------------------------------------------- clear
    def clear(self):
        '''
        clear status
        
        @rtype: Boolean
        @return: True|False
        '''
        
        cr = True  # Call return
        
        
        if self.getProtocol() in ["otu2_sonetsdh", "11.095fec_10gbelan"]:
            self.startTx()
            time.sleep(3)
            self.stopTx()
        # Clear status
        cr &= self.__target.ClearAll() is 0
        
        if cr:  # Call all success
            return True
        raise TestPortException("failed in clearing %s"%self)


    # -------------------------------------------------------------------- setEthernetTraffic
    def setEthernetStream(self, **kw):
        for key in kw.keys():
            if "FRAMESIZE" == key.upper():
                #self.__target.tengeTxConf('lenth_mode', 'fixed')
                self.__target.tengeTxFrameConf('length', str(kw[key])) # int 8-65535
            elif "TXRATE" == key.upper():
                self.__target.tengeTxThroughputConf('bw_percent', str(kw[key])) # real 0.00-100.00
            elif "DSTMAC" == key.upper():
                self.__target.tengeTxMACConf('dest_address', str(kw[key])) # ff:ff:ff:ff:ff:ff
            elif "FCS" == key.upper():
                pass
            else:
                print("unsupport parameter %s"%key)

    # ================================  Alarm  =======================================
    # -------------------------------------------------------------------- alarmInject
    def startInjectAlarm(self, strAlarmType, strAlarmParam=None):
        '''
        alarm inject
        
        @type strAlarmType: Str
        @param strAlarmType: 'Dict Key'
        
        @rtype: Boolean
        @return: True|False
        '''
        print("start to inject alarm on %s"%self)
        strAlarm = self.DICT_ALARM[strAlarmType]
        strProtocol = self.getProtocol()
        print(strProtocol)
        if strAlarm in ["los", "lof"]:
            if "oc192" == strProtocol:
                self.__target.SonetInject("+%s"%strAlarm)
            elif "stm64" == strProtocol:
                self.__target.SdhInject("+%s"%strAlarm)
            elif "10gfc" == strProtocol:
                self.__target.fcInjectAlarm(strProtocol, strAlarm, "on")
            elif "10gbelan" == strProtocol:
                self.__target.ethInjectAlarm(strProtocol, strAlarm, "on")
            elif strProtocol in ["otu2_sonetsdh", "11.095fec_10gbelan"]:
                self.__target.OtnInject("+%s"%strAlarm)
            else:
                raise TestPortException("unknown protocol %s on %s"%(strProtocol, self))
        elif strAlarm in ["hi_ber"]:
            if "10gbelan" == self.getProtocol():
                if strAlarmParam is not None:
                    self.__target.tengeTxPCSConf("sync_bits", strAlarmParam)
                self.__target.tengeTxPCSConf("inject_sync_bit_error", "hi_ber")
                
            elif "10gfc" == self.getProtocol():
                if strAlarmParam is not None:
                    self.__target.fcTxPCSConf(self.getProtocol(), "sync_bits", strAlarmParam)
                self.__target.fcTxPCSConf(self.getProtocol(), "inject_sync_bit_error", "hi_ber")
            else:
                raise TestPortException("%s alarm is not available when %s is on %s protocol"%(self.DICT_ALARM[strAlarmType], self, self.getProtocol()))
                
        elif strAlarm in ["lais", "lrdi", "pais", "plop", "puneq", "prdi", 
            "perdipayload", "perdiserver", "perdiconn"]:
            self.__target.SonetInject("+%s"%strAlarm)
        elif strAlarm in ["msais", "msrdi", "auais", "aulop", "hprdi", 
            "hperdipayload", "hperdiserver", "hperdiconn", "hpuneq"]:
            self.__target.SdhInject("+%s"%strAlarm)
        elif strAlarm in ["losync", "rf", "lf"]:
            if "10gfc" == strProtocol:
                self.__target.fcInjectAlarm(strProtocol, strAlarm, "on")
            elif "10gbelan" == strProtocol:
                self.__target.ethInjectAlarm(strProtocol, strAlarm, "on")

        elif strAlarm in ["iae", "biae"]:
            self.__target.OtuInject("+%s"%strAlarm)
        elif strAlarm in ["oci", "lck"]:
            self.__target.OduInject("+%s"%strAlarm)
        elif strAlarm in ["otu2e_ais", "otu2e_bdi", "otu2_ais", "otu2_bdi"]:
            self.__target.OtuInject("+%s"%strAlarm.split("_")[-1])
        elif strAlarm in ["odu2e_ais", "odu2e_bdi", "odu2_ais", "odu2_bdi"]:
            self.__target.OduInject("+%s"%strAlarm.split("_")[-1])
        elif strAlarm in ["lom"]:
            self.__target.OtnInject("+%s"%strAlarm)
        else:
            raise TestPortException("unknown alarm type -- %s on %s"%(strAlarm, self))
        return True

    # -------------------------------------------------------------------- alarmClear
    def stopInjectAlarm(self, strAlarmType):
        '''
        alarm clear
        
        @type alarmType: Str
        @param alarmType: 'Dict Key'
        
        @rtype: Boolean
        @return: True|False
        '''
        print("stop injecting alarm on %s"%self)
        strAlarm = self.DICT_ALARM[strAlarmType]
        strProtocol = self.getProtocol()
        if strAlarm in ["los", "lof"]:
            if "oc192" == strProtocol:
                self.__target.SonetInject("-%s"%strAlarm)
                
            elif "stm64" == strProtocol:
                self.__target.SdhInject("-%s"%strAlarm)
            elif "10gfc" == strProtocol:
                self.__target.fcInjectAlarm(strProtocol, strAlarm, "off")
            elif "10gbelan" == strProtocol:
                self.__target.ethInjectAlarm(strProtocol, strAlarm, "off")
            elif strProtocol in ["otu2_sonetsdh", "11.095fec_10gbelan"]:
                self.__target.OtnInject("-%s"%strAlarm)
            else:
                print("unknown protocol %s on %s"%(strProtocol, self))

        elif strAlarm in ["hi_ber"]:
            if "10gbelan" == self.getProtocol():
                self.__target.tengeTxPCSConf("inject_sync_bit_error", "none")
                
            elif "10gfc" == self.getProtocol():
                self.__target.fcTxPCSConf(self.getProtocol(), "inject_sync_bit_error", "none")
            else:
                raise TestPortException("%s alarm is not available when %s is on %s protocol"%(self.DICT_ALARM[strAlarmType], self, self.getProtocol()))
        
        elif strAlarm in ["lais", "lrdi", "pais", "plop", "puneq", "prdi", 
            "perdipayload", "perdiserver", "perdiconn"]:
            self.__target.SonetInject("-%s"%strAlarm)
        elif strAlarm in ["msais", "msrdi", "auais", "aulop", "hprdi", 
            "hperdipayload", "hperdiserver", "hperdiconn", "hpuneq"]:
            self.__target.SdhInject("-%s"%strAlarm)
        elif strAlarm in ["losync", "rf", "lf"]:
            if "10gfc" == strProtocol:
                self.__target.fcInjectAlarm(strProtocol, strAlarm, "off")
            elif "10gbelan" == strProtocol:
                self.__target.ethInjectAlarm(strProtocol, strAlarm, "off")
        elif strAlarm in ["iae", "biae"]:
            self.__target.OtuInject("-%s"%strAlarm)
        elif strAlarm in ["oci", "lck"]:
            self.__target.OduInject("-%s"%strAlarm)
        elif strAlarm in ["otu2e_ais", "otu2e_bdi", "otu2_ais", "otu2_bdi"]:
            self.__target.OtuInject("-%s"%strAlarm.split("_")[-1])
        elif strAlarm in ["odu2e_ais", "odu2e_bdi", "odu2_ais", "odu2_bdi"]:
            self.__target.OduInject("-%s"%strAlarm.split("_")[-1])
        elif strAlarm in ["lom"]:
            self.__target.OtnInject("-%s"%strAlarm)
        else:
            raise TestPortException("unknown alarm type -- %s on %s"%(strAlarm, self))
        return True
        
    # start to inject error
    def startInjectError(self, strErrorType, strErrorParam=None):
        print("start to inject error on %s"%self)
        strError = self.DICT_ERROR[strErrorType]
        strProtocol = self.getProtocol()
        if strError in ["b1", "b2", "b3"]:
            if str(strErrorParam).isdigit():
                for n in range(int(strErrorParam)):
                    if "oc192" == strProtocol:
                        self.__target.SetSonetBipInjectMode("linear")
                        if "b1" == strError:
                            self.__target.SetSonetB1InjectRate("single")
                        elif "b2" == strError:
                            self.__target.SetSonetB2InjectRate("single")
                        elif "b3" == strError:
                            self.__target.SetSonetB3InjectRate("single")
                        self.__target.SonetInject("+%s"%strError)
                        
                    elif "stm64"  == strProtocol:
                        self.__target.SetSdhBipInjectMode("linear")
                        if "b1" == strError:
                            self.__target.SetSdhB1InjectRate("single")
                        elif "b2" == strError:
                            self.__target.SetSdhB2InjectRate("single")
                        elif "b3" == strError:
                            self.__target.SetSdhB3InjectRate("single")
                        self.__target.SdhInject("+%s"%strError)
                    else:
                        raise TestPortException("%s error is not available when %s is on %s protocol"%(self.DICT_ERROR[strErrorType], self, self.getProtocol()))
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    if "oc192" == strProtocol:
                        self.__target.SetSonetBipInjectMode("linear")
                        if "b1" == strError:
                            self.__target.SetSonetB1InjectRate(strErrorParam)
                        elif "b2" == strError:
                            self.__target.SetSonetB2InjectRate(strErrorParam)
                        elif "b3" == strError:
                            self.__target.SetSonetB3InjectRate(strErrorParam)
                        self.__target.SonetInject("+%s"%strError)
                        
                    elif "stm64"  == strProtocol:
                        self.__target.SetSdhBipInjectMode("linear")
                        if "b1" == strError:
                            self.__target.SetSdhB1InjectRate(strErrorParam)
                        elif "b2" == strError:
                            self.__target.SetSdhB2InjectRate(strErrorParam)
                        elif "b3" == strError:
                            self.__target.SetSdhB3InjectRate(strErrorParam)
                        self.__target.SdhInject("+%s"%strError)
                    else:
                        raise TestPortException("%s error is not available when %s is on %s protocol"%(self.DICT_ERROR[strErrorType], self, self.getProtocol()))
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
                
        elif strError in ["lrei", "prei"]:
            if str(strErrorParam).isdigit():
                self.__target.SetSonetErrorInjectRate("%s_inject_rate"%strError, "single")
                for n in range(int(strErrorParam)):
                    self.__target.SonetInject("+%s"%strError)
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    self.__target.SetSonetErrorInjectRate("%s_inject_rate"%strError, strErrorParam)
                    self.__target.SonetInject("+%s"%strError)
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)

        elif strError in ["msrei", "hprei"]:
            if str(strErrorParam).isdigit():
                self.__target.SetSdhErrorInjectRate("%s_inject_rate"%strError, "single")
                for n in range(int(strErrorParam)):
                    self.__target.SdhInject("+%s"%strError)
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                        
                    self.__target.SetSdhErrorInjectRate("%s_inject_rate"%strError, strErrorParam)
                    self.__target.SdhInject("+%s"%strError)
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)

        elif strError in ["BER"]:
            if str(strErrorParam).isdigit():
                for n in range(int(strErrorParam)):
                    self.__target.InjectPayloadError("single")
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    self.__target.InjectPayloadError(strErrorParam)
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
                
        elif strError in ["otu2_bip8", "otu2e_bip8"]:
            if str(strErrorParam).isdigit():
                self.__target.SetOtuBip8InjectRate("single")
                for n in range(int(strErrorParam)):
                    self.__target.OtuInject("+%s"%strError.split("_")[-1])
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    self.__target.SetOtuBip8InjectRate(strErrorParam)
                    self.__target.OtuInject("+%s"%strError.split("_")[-1])
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
                
        elif strError in ["odu2_bip8", "odu2e_bip8"]:
            if str(strErrorParam).isdigit():
                self.__target.SetOduBip8InjectRate("single")
                for n in range(int(strErrorParam)):
                    self.__target.OduInject("+%s"%strError.split("_")[-1])
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    self.__target.SetOduBip8InjectRate(strErrorParam)
                    self.__target.OduInject("+%s"%strError.split("_")[-1])
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
                
        elif strError in ["otu2_bei", "otu2e_bei"]:
            if str(strErrorParam).isdigit():
                self.__target.SetOtuBeiInjectRate("single")
                for n in range(int(strErrorParam)):
                    self.__target.OtuInject("+%s"%strError.split("_")[-1])
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                        
                    self.__target.SetOtuBeiInjectRate(strErrorParam)
                    self.__target.OtuInject("+%s"%strError.split("_")[-1])
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
                
        elif strError in ["odu2_bei", "odu2e_bei"]:
            if str(strErrorParam).isdigit():
                self.__target.SetOduBeiInjectRate("single")
                for n in range(int(strErrorParam)):
                    self.__target.OduInject("+%s"%strError.split("_")[-1])
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    self.__target.SetOduBeiInjectRate(strErrorParam)
                    self.__target.OduInject("+%s"%strError.split("_")[-1])
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)

                    
        elif strError in ["fec"]:
            if str(strErrorParam).isdigit():
                self.__target.SetOtuFecInjectRate("single")    
                for n in range(int(strErrorParam)):
                    self.__target.OtuInject("+%s"%strError.split("_")[-1])
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)  
                        
                    self.__target.SetOtuFecInjectRate(strErrorParam)
                    self.__target.OtuInject("+%s"%strError.split("_")[-1])
                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
                    
                    
        elif "fc2crcerror" == strError:
            if str(strErrorParam).isdigit():
                for n in range(int(strErrorParam)):
                    self.__target.fc2InjectCRC(self.getProtocol(), "single")
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    self.__target.fc2InjectCRC(self.getProtocol(), strErrorParam)

                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
                    
        elif "invalidblocktype" == strError:
            if str(strErrorParam).isdigit():
                for n in range(int(strErrorParam)):
                    self.__target.fcTxPCSConf(self.getProtocol(), "inject_invalidblocktype", "single")
            else:
                r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
                if r:
                    if int(r.group(1)) < 5:
                        strErrorParam = "1e-%d"%(int(r.group(3)))
                    else:
                        strErrorParam = "1e-%d"%(int(r.group(3)) - 1)
                    self.__target.fcTxPCSConf(self.getProtocol(), "inject_invalidblocktype", strErrorParam)

                else:
                    raise TestPortException("error rate is not support -- %s"%strErrorParam)
        elif "pause" == strError:
            if str(strErrorParam).isdigit():
                for n in range(int(strErrorParam)):
                    self.__target.ethInjectPause(self.getProtocol(), "single")
            else:
                raise TestPortException("error rate is not support -- %s"%strErrorParam)
        elif "FCS" == strError:
            if str(strErrorParam).isdigit():
                for n in range(int(strErrorParam)):
                    self.__target.ethInjectCRC(self.getProtocol(), "single")
            else:
                raise TestPortException("error rate is not support -- %s"%strErrorParam)
        else:
            raise TestPortException("unknown error type")

            
    # stop injecting error
    def stopInjectError(self, strErrorType):
        print("stop injecting error on %s"%self)
        strError = self.DICT_ERROR[strErrorType]
        if strError in ["b1", "b2", "b3"]:
            strProtocol = self.getProtocol()
            if "oc192" == strProtocol:
                self.__target.SonetInject("-%s"%strError)
                
            elif "stm64"  == strProtocol:
                self.__target.SdhInject("-%s"%strError)
            else:
                raise TestPortException("%s error is not available when %s is on %s protocol"%(self.DICT_ERROR[strErrorType], self, self.getProtocol()))

        elif strError in ["lrei", "prei"]:
            # self.__target.SetSonetErrorInjectRate(strError, strErrorParam)
            self.__target.SonetInject("-%s"%strError)
        elif strError in ["msrei", "hprei"]:
            # self.__target.SetSdhErrorInjectRate(strError, strErrorParam)
            self.__target.SdhInject("-%s"%strError)
        elif strError in ["BER"]:
            self.__target.InjectPayloadError("none")
        elif strError in ["fec"]:
            self.__target.OtuInject("-%s"%strError.split("_")[-1]) 
        elif strError in ["otu2_bip8", "otu2e_bip8"]:
            self.__target.OtuInject("-%s"%strError.split("_")[-1])
        elif strError in ["odu2_bip8", "odu2e_bip8"]:
            self.__target.OduInject("-%s"%strError.split("_")[-1])
        elif strError in ["otu2_bei", "otu2e_bei"]:
            self.__target.OtuInject("-%s"%strError.split("_")[-1])
        elif strError in ["odu2_bei", "odu2e_bei"]:
            self.__target.OduInject("-%s"%strError.split("_")[-1])
        elif "fc2crcerror" == strError:
            self.__target.fc2InjectCRC(self.getProtocol(), "none")
        elif "invalidblocktype" == strError:
            self.__target.fcTxPCSConf(self.getProtocol(), "inject_invalidblocktype", "none")
        elif "pause" == strError:
            raise TestPortException("don\'t need to stop pause frame manually")
        elif "FCS" == strError:
            raise TestPortException("don\'t need to stop FCS frame manually")
        else:
            raise TestPortException("unknown error type")
            
            
    def generateEthPm(self, strPmItem, nDuration=30, **kw):
        if strPmItem in ["OCTSTX", "PKTSTX"]:
            if "FRAMESIZE" not in kw.keys():
                kw["FRAMESIZE"] = random.randint(8, 65535)

        elif strPmItem in ["OCTSTXOK", "PKTSTXOK"]:
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False

        elif strPmItem == "PKTSMCSTTX":
            if "DSTMAC" in kw.keys():
                if "ff:ff:ff:ff:ff" == kw["DSTMAC"] or not int(kw["DSTMAC"].split(":")[0], 16) & 0b00000001:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "01:00:00:00:00:01"

            
        elif strPmItem == "PKTSBCSTTX":
            if "DSTMAC" in kw.keys():
                if "ff:ff:ff:ff:ff" != kw["DSTMAC"]:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "ff:ff:ff:ff:ff:ff"
                
        elif strPmItem == "PKTSUCSTTX":
            if "DSTMAC" in kw.keys():
                if int(kw["DSTMAC"].split(":")[0], 16) & 0b00000001:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "00:01:00:00:00:01"
            
        elif strPmItem == "PKTSUSZETX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) >= 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(8, 63)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "PKTSOSZETX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) <= 9600:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(9601, 65535)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "FRGMTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) >= 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(8, 63)
            if "FCS" in kw.keys():
                if kw["FCS"] is not True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = True
            
            
        elif strPmItem == "JABBERTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) <= 9600:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(9601, 65535)
            if "FCS" in kw.keys():
                if kw["FCS"] is not True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = True
            
            
        elif strPmItem == "PKTSPAUSTX":
            if "PAUSE" in kw.keys():
                if kw["PAUSE"] is not True:
                    print("PAUSE should not be %s when pm item is %s"%(kw["PAUSE"], strPmItem))
            else:
                kw["PAUSE"] = True
                
        elif strPmItem == "PKTS64OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) != 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = 64
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS65-127OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 127 or int(kw["FRAMESIZE"]) < 65:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(65, 127)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS128-255OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 255 or int(kw["FRAMESIZE"]) < 128:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(128, 255)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS256-511OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 511 or int(kw["FRAMESIZE"]) < 256:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(256, 511)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS512-1023OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 1023 or int(kw["FRAMESIZE"]) < 512:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(512, 1023)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS1024-1518OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 1518 or int(kw["FRAMESIZE"]) < 1024:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(1024, 1518)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "PKTSOVER-1518OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) < 1518:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(1518, 9600)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
                
                
        if "FCS" not in kw.keys():
            kw["FCS"] = False
        if "PAUSE" not in kw.keys():
            kw["PAUSE"] = False
            
        bFCS = kw["FCS"]
        bPause = kw["PAUSE"]
        
        del kw["FCS"]
        del kw["PAUSE"]
        
        if bFCS and bPause:
            raise TestPortException("FCS and PAUSE should not be injected at the same time")
        
            
        self.stopTx()
        self.clear()
        
        self.setEthernetStream(**kw)
        
        self.startTx()
        timer0 = time.time()
        nFCS = 0
        nPause = 0

        if bFCS:
            while (time.time() - timer0) < nDuration:
                self.__target.ethInjectCRC(self.getProtocol(), "single")
                nFCS += 1
        elif bPause:
            while (time.time() - timer0) < nDuration:
                self.__target.ethInjectPause(self.getProtocol(), "single")
                nPause += 1
        while (time.time() - timer0) < nDuration:
            time.sleep(1)
        self.stopTx()
        
        # provide pm item your self
        # related to package framesize/dstmac/crc/pause
        if "FRAMESIZE" in kw.keys():
            framesize = kw["FRAMESIZE"]
        else:
            framesize = self.__target.getEthFrameSizeConf(self.getProtocol(), "length")
        if "DSTMAC" in kw.keys():
            dstmac = kw["DSTMAC"]
        else:
            dstmac = self.__target.getEthDstMacConf(self.getProtocol()).replace("-", ":")
        
        print("framesize:%s"%framesize)
        print("dest mac:%s"%dstmac)
        
        dictTxPM = dict()
        
        dictTxPM["PKTSTX"] = int(self.__target.getEthTxFrames(self.getProtocol()))
        dictTxPM["OCTSTX"] = int(self.__target.getEthTxOctets(self.getProtocol()))
        
        # broadcast/multicast/unicast
        if "FF:FF:FF:FF:FF:FF" == dstmac.upper():
            dictTxPM["PKTSBCSTTX"] = dictTxPM["PKTSTX"] - nPause
            dictTxPM["PKTSMCSTTX"] = nPause
            dictTxPM["PKTSUCSTTX"] = 0
        elif int(dstmac.split(":")[0], 16) & 0b00000001:
            dictTxPM["PKTSBCSTTX"] = 0
            dictTxPM["PKTSMCSTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTSUCSTTX"] = 0
        else:
            dictTxPM["PKTSBCSTTX"] = 0
            dictTxPM["PKTSMCSTTX"] = nPause
            dictTxPM["PKTSUCSTTX"] = dictTxPM["PKTSTX"] - nPause
            
        if framesize < 64:
            dictTxPM["PKTSUSZETX"] = dictTxPM["PKTSTX"] - nPause - nFCS
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = nFCS
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
            
        elif framesize == 64:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = dictTxPM["PKTSTX"]
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 128:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = dictTxPM["PKTSTX"] - nPause
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 256:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = dictTxPM["PKTSTX"] - nPause
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 512:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = dictTxPM["PKTSTX"] - nPause
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize < 1024:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = dictTxPM["PKTSTX"] - nPause
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize <= 1518:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = dictTxPM["PKTSTX"] - nPause
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif framesize <= 9600:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = dictTxPM["PKTSTX"] - nPause
        else:
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = dictTxPM["PKTSTX"] - nPause - nFCS
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = nFCS
            dictTxPM["PKTS64OCTTX"] = nPause
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
            
        for key in dictTxPM.keys():
            print("%s:%s"%(key, str(dictTxPM[key])))
        return dictTxPM

    # -------------------------------------------------------------------- checkAlarm        
    # get alarm info on test port
    def checkAlarm(self, strAlarmType):
        if self.DICT_ALARM[strAlarmType] == "lrdi":
            if "ERR" == self.__target.getCurrentSONETlrdiAlarm(self.DICT_ALARM[strAlarmType]):
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] == "msrdi":
            if "ERR" == self.__target.getCurrentSDHmsrdiAlarm(self.DICT_ALARM[strAlarmType]):
                return "ON"
            else:
                return "OFF"                             
        elif self.DICT_ALARM[strAlarmType] == "odu2_bdi":
            if "ERR" == self.__target.getCurrentODU2bdiAlarm():
                return "ON"
            else:
                return "OFF"
        elif self.DICT_ALARM[strAlarmType] == "odu2e_bdi":
            if "ERR" == self.__target.getCurrentODU2ebdiAlarm():
                return "ON"
            else:
                return "OFF"                                
        else:
            raise TestPortException("unknown test alarm type -- %s"%strAlarmType) 

        
class ViaviPort():
    DICT_ALARM = {
        # ethernet alarm
        "ALARM_ETHERNET_IF_LOS":"LOS",
        "ALARM_ETHERNET_ETH_LOSYNC":"LOAML",
        "ALARM_ETHERNET_ETH_LF":"LOC_FAULT",
        "ALARM_ETHERNET_ETH_RF":"REM_FAULT",
        "ALARM_ETHERNET_BER_PATTERNLOSS":"",
        "ALARM_ETHERNET_PCS_LOBL":"LOBL",
        # same with ALARM_ETHERNET_ETH_LOSYNC, dont known which one is right for now
        "ALARM_ETHERNET_PCS_LOAML":"LOAML",
        "ALARM_ETHERNET_PCS_HIBER":"HIBER",
        
        # OTU4 alarm
        "ALARM_OTU4_IF_LOS":"LOS",
        "ALARM_OTU4_OTU4_LOF":"LOFOTL",
        "ALARM_OTU4_OTU4_LOL":"",
        "ALARM_OTU4_OTU4_LOR":"",
        "ALARM_OTU4_OTU4_OOF":"OOFOTL",
        "ALARM_OTU4_OTU4_OOR":"",

        # "ALARM_OTU4_OTU4_LOF":"LOF",
        # "ALARM_OTU4_OTU4_OOF":"OOF",
        "ALARM_OTU4_OTU4_LOM":"LOM",
        "ALARM_OTU4_OTU4_OOM":"OOM",
        "ALARM_OTU4_OTU4_BDI":"SM_BDI",
        "ALARM_OTU4_OTU4_IAE":"SM_IAE",
        "ALARM_OTU4_OTU4_BIAE":"SM_BIAE",
        
        "ALARM_OTU4_ODU4_AIS":"ODU_AIS",
        "ALARM_OTU4_ODU4_OCI":"ODU_OCI",
        "ALARM_OTU4_ODU4_LCK":"ODU_LCK",
        "ALARM_OTU4_ODU4_BDI":"PM_BDI",
        "ALARM_OTU4_ODU4_FSF":"SIGNAL_FAIL_FW",
        "ALARM_OTU4_ODU4_BSF":"SIGNAL_FAIL_BW",
        "ALARM_OTU4_ODU4_FSD":"SIGNAL_DEG_FW",
        "ALARM_OTU4_ODU4_BSD":"SIGNAL_DEG_BW",
        "ALARM_OTU4_OPU4_AIS":"",
        "ALARM_OTU4_OPU4_CSF":"",
        "ALARM_OTU4_BER_PATTERNLOSS":"",
        
        "ALARM_8FC_IF_LOS":"LOS",
        "ALARM_8FC_PCS_LOSYNC":"LOSYNC",
        
        "ALARM_10FC_IF_LOS":"LOS",
        "ALARM_10FC_PCS_LF":"LOC_FAULT",
        "ALARM_10FC_PCS_RF":"REM_FAULT",
        "ALARM_10FC_PCS_LOBL":"LOBL",
        "ALARM_10FC_PCS_HIBER":"HIBER"
    }
    DICT_ERROR = {
        # ethernet error
        "ERROR_ETHERNET_ETH_BLK":"",
        "ERROR_ETHERNET_ETH_FCS":"FCS",
        
        "ERROR_ETHERNET_PCS_BLK":"",
        "ERROR_ETHERNET_PCS_INVALIDMARKER":"",
        "ERROR_ETHERNET_PCS_PCSBIP8":"BIP8",
        
        # OTU4 error
        "ERROR_OTU4_OTU4_BIP8":"SM_BIP",
        "ERROR_OTU4_OTU4_FAS":"FAS",
        "ERROR_OTU4_OTU4_MFAS":"MFAS",
        "ERROR_OTU4_OTU4_BEI":"SM_BEI",
        "ERROR_OTU4_FEC_FECCORRCW":"FEC_CORR",
        "ERROR_OTU4_FEC_FECCORRSYM":"FEC_ADV",
        "ERROR_OTU4_FEC_FECCORRBIT":"FEC_CORR",
        "ERROR_OTU4_FEC_FECUNCORRCW":"FEC_UNCORR",
        "ERROR_OTU4_FEC_FECSTRESS":"",
        "ERROR_OTU4_ODU4_BIP8":"PM_BIP",
        "ERROR_OTU4_ODU4_BEI":"PM_BEI",
        # "ERROR_OTU4_BER_BITERROR":"RAND",
        
        "ERROR_8FC_FC2_CRC":"FCS",
        "ERROR_10FC_FC2_CRC":"FCS"
    }
    DICT_PROTOCOL = {
        # protocol
        "PROTOCOL_OTN_OTU4-4LANE":"PHYS_OTL4_OTN",

        "PROTOCOL_ETHERNET_100GE-4LANE-OTHER":"PHYS_PCSL_MAC_100GE",

        "PROTOCOL_FC_8FC":"PHYS_PCS1G_FC2",
        "PROTOCOL_FC_10FC":"PHYS_PCS_FC2",
        
        
        
        "100ge":"PHYS_PCSL_MAC_100GE",
        
        "40ge":"PHYS_PCSL_MAC_40GE",

        "otu4":"PHYS_OTL4_OTN",
        "10gfc":"PHYS_PCS_FC2",
        "8gfc":"PHYS_PCS1G_FC2"
        
    }
    
    def __init__(self, strIP, strLocation):
        self.__IP = strIP
        self.__location = strLocation
        self.__equipmentType__ = "VIAVI"

        self.__target = ont600.Ont600(self.__IP, self.__location)
        self.__protocol = None
    
    def __str__(self):
        return "%s \"%s\" port %s"%(self.__equipmentType__, self.__IP, self.__location)

    # initial port. set protocol, connector, fec type...
    def init(self, strProtocol, **kw):
    
        print("set protocol on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        self.__protocol = None
        
        # if the port is no application, provision "New-Application" on the port
        if "" == self.__target.getLoadedApplication():
            self.__target.loadApplication("New-Application")
        
        if strProtocol not in self.DICT_PROTOCOL.keys():
            raise TestPortException("unsupport protocol")
        
        if self.__target.isTesting():
            print("%s %s slot %s is testing, stop testing now and set protocol"%(self.__equipmentType__, self.__IP, self.__location))
            self.__target.startStop("STOP")
            
        if self.DICT_PROTOCOL[strProtocol] in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            self.__target.setMtmPortConfig("DEEP_ANALYSIS")
        
        if "PHYS_PCSL_MAC" in self.DICT_PROTOCOL[strProtocol]:
            self.__target.setLayerStack("TERM", "PHYS_PCSL_MAC")
            if "PHYS_PCSL_MAC_100GE" == self.DICT_PROTOCOL[strProtocol]:
                self.__target.setPhys1xxgCFP2TxBitrate("ETH_100G")
                self.__target.setPhys1xxgCFP2RxBitrate("ETH_100G")
                
                # self.__target.setPhysCFPMDIOCHGridSpacing("B001")
                # self.__target.setPhysCFPMDIOCHNo(44)

                self.__target.setPhysCFPMDIOStartAddr("900B")
                
            elif "PHYS_PCSL_MAC_40GE" == self.DICT_PROTOCOL[strProtocol]:
                self.__target.setPhys1xxgCFP2TxBitrate("ETH_40G")
                self.__target.setPhys1xxgCFP2RxBitrate("ETH_40G")
        else:
            self.__target.setLayerStack("TERM", self.DICT_PROTOCOL[strProtocol])
        
        # Set fec
        for key in kw.keys():
            if 'FECTYPE' == key.upper():
                if "no-fec" == kw[key]:
                    self.__target.setOtnTxFecStatus("OFF")
                    self.__target.setOtnRxFecStatus("OFF")
                    self.__target.setOtnFecCorrectionStatus("OFF")
                elif 'g-fec' == kw[key]:
                    self.__target.setOtnTxFecStatus("ON")
                    self.__target.setOtnRxFecStatus("ON")
                    self.__target.setOtnFecCorrectionStatus("ON")
                else:
                    raise TestPortException('Invalid fec -- %s'%kw[key])
            else:
                raise TestPortException('Invalid attribution -- %s'%key)
        
        if self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            if "PHYS_PCS1G_FC2" == self.getProtocol():
                self.__target.setFcTxBitRate("FC8G")
                self.__target.setFcRxBitRate("FC8G")
            elif "PHYS_PCS_FC2" == self.getProtocol():
                self.__target.setFcTxBitRate("FC10G")
                self.__target.setFcRxBitRate("FC10G")
                
            time.sleep(3)
            self.__target.setPcsFcForceLinkActive(self.getProtocol(), "ON")
            time.sleep(3)
            self.__target.setPcsFcForceLinkFaultIgnore(self.getProtocol(), "ON")

        self.setLaser("ON")
        time.sleep(3)

        # if self.getProtocol() in ["PHYS_PCSL_MAC", "PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
        if self.getProtocol() in ["PHYS_PCSL_MAC_40GE", "PHYS_PCSL_MAC_100GE", "PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            self.__target.startStop("START")
            # if "PHYS_PCSL_MAC" == self.getProtocol():
            if "PHYS_PCSL_MAC" in self.getProtocol():
                self.__target.setTrafficGenerator("OFF")
                self.__target.setTxTrafficFrameSize("RAND", "ON", str(random.randint(64, 10000)))
            else:
                self.__target.setFcTrafficGenerator("OFF")
            self.clear()

        # self.__protocol = self.DICT_PROTOCOL[strProtocol]
    
    # get test equipment port protocol,
    # used internal, not available outside
    def getProtocol(self):
        if self.__protocol is None:
            layerStack = self.__target.getCurrentLayerStack()
            match = re.search('{laystack {(.*?)}}', layerStack)
            if match:
                if match.group(1) in ["PHYS_OTL4_OTN", "PHYS_PCS_FC2", "PHYS_PCS1G_FC2"]:
                # if match.group(1) in ["PHYS_PCSL_MAC_40GE", "PHYS_PCSL_MAC_100GE", "PHYS_OTL4_OTN", "PHYS_PCS_FC2", "PHYS_PCS1G_FC2"]:
                    self.__protocol = match.group(1)
                elif match.group(1) in ["PHYS_PCSL_MAC"]:
                    print("----------------")
                    interface = self.__target.getPhys1xxgCFP2TxInterface()
                    interfaceMatch = re.search('{interface {(.*?)}}', interface)
                    if interfaceMatch:
                        if interfaceMatch.group(1) == "ETH_100G":
                            self.__protocol = match.group(1) + "_100GE"
                        elif interfaceMatch.group(1) == "ETH_40G":
                            self.__protocol = match.group(1) + "_40GE"
                        else:
                            raise TestPortException("unknown protocol -- %s on %s"%(interface, self))
                    print(self.__protocol)
                    print("----------------")
                else:
                    raise TestPortException("unknown protocol -- %s on %s"%(layerStack, self))
            else:
                raise TestPortException("unknown protocol -- %s on %s"%(layerStack, self))

        return self.__protocol
    
    # start to send traffic
    def startTx(self):
        print("start tx on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        # if self.getProtocol() in ["PHYS_PCSL_MAC"]:
        if "PHYS_PCSL_MAC" in self.getProtocol():
            self.__target.setTrafficGenerator("ON")
        elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            self.__target.setFcTrafficGenerator("ON")
        else:
            self.__target.startStop("START")
            
    # stop sending traffic
    def stopTx(self):
        print("stop tx on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        # if self.getProtocol() in ["PHYS_PCSL_MAC"]:
        if "PHYS_PCSL_MAC" in self.getProtocol():
            self.__target.setTrafficGenerator("OFF")
        elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            self.__target.setFcTrafficGenerator("OFF")
        else:
            self.__target.startStop("STOP")
        
    def startStop(self, strStatus):
        self.__target.startStop(strStatus)
        
    # clear statics/error status/alarm status on test port
    def clear(self):
        print("disable rx on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        if self.__target.isTesting():
            return self.__target.clearTesting()

    # get test result on test port
    def getTestResult(self):
        print("get statics from %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        dictTrafficDetail = dict()
        print(self.__protocol)
        if self.getProtocol() in ["PHYS_OTL4_OTN"]:
            testResult = self.__target.getOtnRxOtnSummary("HST")
            match = re.search('{sum_valid (.*?)}', testResult)
            if match:
                # convert the match to an integer before returning it
                if 1 == int(match.group(1)):
                    match = re.search('{sum_value (.*?)}', testResult)
                    if match:
                        if 0 == int(match.group(1)):
                            dictTrafficDetail["TEST_STATUS"] = "PASS"
                        else:
                            dictTrafficDetail["TEST_STATUS"] = "FAIL"
                else:
                    raise TestPortException("unexpected test result --%s from %s"%(testResult, self))
            else:
                raise TestPortException("failed in getting test result from %s"%self)
            
            r = self.__target.getOtnRxSummaryState("HST")
            print(r)
        # elif self.getProtocol() in ["PHYS_PCSL_MAC"]:
        elif "PHYS_PCSL_MAC" in self.getProtocol():
            rxResult = self.__target.getRxTotalFrameResults()
            match = re.search('{countByte (.*?)}', rxResult)
            if match:
                # convert the match to an integer before returning it
                dictTrafficDetail["RX_BYTE_TOTAL"] = int(match.group(1))
            else:
                raise TestPortException("failed in getting test result from %s"%self)
                
            match = re.search('{countFrame (.*?)}', rxResult)
            if match:
                # convert the match to an integer before returning it
                dictTrafficDetail["RX_PACKAGE_TOTAL"] = int(match.group(1))
            else:
                raise TestPortException("failed in getting test result from %s"%self)
            
            
            txResult = self.__target.getTxTotalFrameResults()
            match = re.search('{countByte (.*?)}', txResult)
            if match:
                # convert the match to an integer before returning it
                dictTrafficDetail["TX_BYTE_TOTAL"] = int(match.group(1))
            else:
                raise TestPortException("failed in getting test result from %s"%self)
                
            match = re.search('{countFrame (.*?)}', txResult)
            if match:
                # convert the match to an integer before returning it
                dictTrafficDetail["TX_PACKAGE_TOTAL"] = int(match.group(1))
            else:
                raise TestPortException("failed in getting test result from %s"%self)
        elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            dictTrafficDetail = self.__target.getFC2TrafficStatistics()
        return dictTrafficDetail
    
    # start to inject alarm/error
    def startInjectAlarm(self, strAlarmType, strAlarmParam=None):
        print("start to inject alarm on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        if self.DICT_ALARM[strAlarmType] in ["LOC_FAULT", "REM_FAULT"]:
            # if "PHYS_PCSL_MAC" == self.getProtocol(): 
            if "PHYS_PCSL_MAC" in self.getProtocol(): 
                self.__target.setPcsRsAlarmInsertCfg(self.DICT_ALARM[strAlarmType], "CONT", "-1", "-1")
                self.__target.setPcsRsAlarmInsertState("ON")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPcsFcAlarmInsertCfg(self.DICT_ALARM[strAlarmType], "CONT")
                self.__target.setPcsFcAlarmInsertState("ON")
                
        elif self.DICT_ALARM[strAlarmType] in ["LOBL", "LOAML"]:
            # if "PHYS_PCSL_MAC" == self.getProtocol(): 
            if "PHYS_PCSL_MAC" in self.getProtocol():
                # if "LOBL" == self.DICT_ALARM[strAlarmType]:
                if self.DICT_ALARM[strAlarmType] in ["LOBL", "LOAML"]:
                    self.__target.setPcsLane100GeAlarmInsertCfg(self.DICT_ALARM[strAlarmType])
                    self.__target.setPcsLane100GeAlarmInsertRange("ALL", "0")
                    self.__target.setPcsLane100GeAlarmInsertState("ON")
                # elif "LOAML" == self.DICT_ALARM[strAlarmType]:
                    # self.__target.setPcsLane100GeErrorInsertCfg("SYNC_HEADER_INV", "BURST_CONT", 1, 1)
                    # self.__target.setPcsLane100GeErrorInsertRange("ALL", "0")
                    # self.__target.setPcsLane100GeErrorInsertState("ON")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPcsAlarmInsertCfg(self.DICT_ALARM[strAlarmType], "CONT", "-1", "-1")
                self.__target.setPcsAlarmInsertState("ON")
            else:
                raise TestPortException("%s alarm is not available when %s is on %s protocol"%(self.DICT_ALARM[strAlarmType], self, self.getProtocol()))
                
        elif self.DICT_ALARM[strAlarmType] in ["OTU_AIS", "LOF", "OOF", "LOM", "OOM", "ODU_AIS", "ODU_OCI", "ODU_LCK",
                "SM_IAE", "SM_TIM", "SM_BDI", "SM_BIAE", "PM_TIM", "PM_BDI", "LOMFI", "OOMFI",
                "CSF", "SIGNAL_FAIL_FW", "SIGNAL_FAIL_BW", "SIGNAL_DEG_FW", "SIGNAL_DEG_BW"]:
            self.__target.setOtnTxAlarmInsConf(self.DICT_ALARM[strAlarmType], "CONT", "-1", "-1")
            self.__target.setOtnTxAlarmInsState("ON")
            
        elif self.DICT_ALARM[strAlarmType] in ["LOFOTL", "OOFOTL"]:
            self.__target.setOtlLaneOtu4AlarmInsertCfg(self.DICT_ALARM[strAlarmType])
            self.__target.setOtlLaneOtu4AlarmInsertRange("ALL")
            self.__target.setOtlLaneOtu4AlarmInsertState("ON")
            
        elif self.DICT_ALARM[strAlarmType] in ["HIBER"]:
            # if "PHYS_PCSL_MAC" == self.getProtocol():
            if "PHYS_PCSL_MAC" in self.getProtocol():
                # self.__target.setTx1027BAlarmInsertCfg(self.DICT_ALARM[strAlarmType], "CONT")
                # self.__target.setTx1027BAlarmInsertState("ON")
                self.__target.setPcsAlarmInsertCfg(self.DICT_ALARM[strAlarmType], "CONT", "-1", "-1")
                self.__target.setPcsAlarmInsertState("ON")
                
            elif "PHYS_OTL4_OTN"  == self.getProtocol():
                self.__target.setPhys1xgTxAlarmInsConf(self.DICT_ALARM[strAlarmType], "CONT")
                self.__target.setPhys1xgTxAlarmInsState("ON")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPcsAlarmInsertCfg(self.DICT_ALARM[strAlarmType], "CONT", "-1", "-1")
                self.__target.setPcsAlarmInsertState("ON")
            else:
                raise TestPortException("%s alarm is not available when %s is on %s protocol"%(self.DICT_ALARM[strAlarmType], self, self.getProtocol()))
                
        elif "LOS" == self.DICT_ALARM[strAlarmType]:
            # if "PHYS_PCSL_MAC" == self.getProtocol():
            if "PHYS_PCSL_MAC" in self.getProtocol():
                self.__target.setPhys1xgTxAlarmInsConf(self.DICT_ALARM[strAlarmType], "CONT")
                self.__target.setPhys1xgCFP2TxAlarmInsRange("ALL", "0")
                self.__target.setPhys1xgTxAlarmInsState("ON")
            elif "PHYS_OTL4_OTN"  == self.getProtocol():
                self.__target.setPhys1xgTxAlarmInsConf(self.DICT_ALARM[strAlarmType], "CONT")
                self.__target.setPhys1xgTxAlarmInsState("ON")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPhys1xgTxAlarmInsConf(self.DICT_ALARM[strAlarmType], "CONT")
                self.__target.setPhys1xgTxAlarmInsState("ON")
            else:
                raise TestPortException("LOS alarm is not available when %s is on %s protocol"%(self, self.getProtocol()))
        elif "LOSYNC" == self.DICT_ALARM[strAlarmType]:
            self.__target.setPcsLosyncAlarm("ON")
        else:
            raise TestPortException("unknown alarm type")
            
    # start to inject error
    def startInjectError(self, strErrorType, strErrorParam=None):
        print("start to inject error on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        # print "#########################"
        # print self.DICT_ERROR[strErrorType]
        r = re.match(r"^(\d).(\d)[eE]-0(\d)$", strErrorParam)
        if r:
            strErrorParam = strErrorParam[:5] + strErrorParam[-1]
        else:
            raise TestPortException("error rate is not support -- %s"%strErrorParam)
        
        if self.DICT_ERROR[strErrorType] in ["MFAS", "SM_BIP", "SM_BEI", "PM_BIP", "PM_BEI", "FEC_CORR", "FEC_ADV", "FEC_UNCORR"]:
            if str(strErrorParam).isdigit():
                if self.DICT_ERROR[strErrorType] in ["FEC_CORR", "FEC_ADV", "FEC_UNCORR"]: 
                    self.__target.setOTNErrorFec(self.DICT_ERROR[strErrorType], "BURST_ONCE")
                else:
                    self.__target.setOtnTxErrorInsConf(self.DICT_ERROR[strErrorType], "BURST_ONCE", "-1", str(strErrorParam), "-1")
            else:
                if self.DICT_ERROR[strErrorType] in ["FEC_CORR", "FEC_ADV", "FEC_UNCORR"]: 
                    self.__target.setOTNErrorFec(self.DICT_ERROR[strErrorType])
                else:   
                    self.__target.setOtnTxErrorInsConf(self.DICT_ERROR[strErrorType], "RATE", strErrorParam, "-1", "-1")
            
            self.__target.setOtnTxErrorInsState("ON")

        elif "FCS" == self.DICT_ERROR[strErrorType]:
            if self.getProtocol() in ["PHYS_PCS_FC2", "PHYS_PCS1G_FC2"]:
                if str(strErrorParam).isdigit():
                    self.__target.injectFC2Error(str(strErrorParam))
                else:
                    raise TestPortException("not support injecting FCS rate on %s"%self)
            # elif "PHYS_PCSL_MAC"  == self.getProtocol():
            elif "PHYS_PCSL_MAC" in self.getProtocol():
                if str(strErrorParam).isdigit():
                    self.__target.setErrorInsConfEx(self.DICT_ERROR[strErrorType], "BURST_ONCE", str(strErrorParam))
                else:
                    self.__target.setErrorInsConfEx(self.DICT_ERROR[strErrorType], "RATE", errorInsertionRate=str(strErrorParam))
                self.__target.setErrorInsState("ON")
            else:
                raise TestPortException("%s error is not available when %s is on %s protocol"%(self.DICT_ERROR[strErrorType], self, self.getProtocol()))
        elif "BIP8" == self.DICT_ERROR[strErrorType]:
            if str(strErrorParam).isdigit():
                self.__target.setPcsLane100GeErrorInsertCfg("BIP8", "BURST_ONCE", str(strErrorParam))
            else:
                self.__target.setPcsLane100GeErrorInsertCfg("BIP8", "RATE", errorInsertionRate=str(strErrorParam))
            self.__target.setPcsLane100GeErrorInsertRange("ALL", "0")
            self.__target.setPcsLane100GeErrorInsertState("ON")
        else:
            raise TestPortException("unknown error type")
    # stop injecting alarm
    def stopInjectAlarm(self, strAlarmType):
        print("stop injecting alarm on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))
        
        if self.DICT_ALARM[strAlarmType] in ["LOC_FAULT", "REM_FAULT"]:
            # if "PHYS_PCSL_MAC" == self.getProtocol(): 
            if "PHYS_PCSL_MAC" in self.getProtocol(): 
                self.__target.setPcsRsAlarmInsertState("OFF")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPcsFcAlarmInsertState("OFF")
        
        elif self.DICT_ALARM[strAlarmType] in ["LOBL", "LOAML"]:
            # if "PHYS_PCSL_MAC" == self.getProtocol(): 
            if "PHYS_PCSL_MAC" in self.getProtocol():
                # if "LOBL" == self.DICT_ALARM[strAlarmType]:
                if self.DICT_ALARM[strAlarmType] in ["LOBL", "LOAML"]:
                    self.__target.setPcsLane100GeAlarmInsertState("OFF")
                # elif "LOAML" == self.DICT_ALARM[strAlarmType]:
                    # self.__target.setPcsLane100GeErrorInsertState("OFF")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPcsAlarmInsertState("OFF")
            else:
                raise TestPortException("%s alarm is not available when %s is on %s protocol"%(self.DICT_ALARM[strAlarmType], self, self.getProtocol()))
            
        elif self.DICT_ALARM[strAlarmType] in ["OTU_AIS", "LOF", "OOF", "LOM", "OOM", "ODU_AIS", "ODU_OCI", "ODU_LCK",
                "SM_IAE", "SM_TIM", "SM_BDI", "SM_BIAE", "PM_TIM", "PM_BDI", "LOMFI", "OOMFI",
                "CSF", "SIGNAL_FAIL_FW", "SIGNAL_FAIL_BW", "SIGNAL_DEG_FW", "SIGNAL_DEG_BW"]:
            self.__target.setOtnTxAlarmInsState("OFF")
            
        elif self.DICT_ALARM[strAlarmType] in ["LOFOTL", "OOFOTL"]:
            self.__target.setOtlLaneOtu4AlarmInsertState("OFF")
        elif self.DICT_ALARM[strAlarmType] in ["HIBER"]:
            # if "PHYS_PCSL_MAC" == self.getProtocol():
            if "PHYS_PCSL_MAC" in self.getProtocol():
                # self.__target.setTx1027BAlarmInsertState("OFF")
                self.__target.setPcsAlarmInsertState("OFF")
                
            elif "PHYS_OTL4_OTN"  == self.getProtocol():
                self.__target.setPhys1xgTxAlarmInsState("OFF")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPcsAlarmInsertState("OFF")
            else:
                raise TestPortException("%s alarm is not available when %s is on %s protocol"%(self.DICT_ALARM[strAlarmType], self, self.getProtocol()))
                
        elif "LOS" == self.DICT_ALARM[strAlarmType]:
            # if "PHYS_PCSL_MAC" == self.getProtocol():
            if "PHYS_PCSL_MAC" in self.getProtocol():
                self.__target.setPhys1xgTxAlarmInsState("OFF")
            elif "PHYS_OTL4_OTN"  == self.getProtocol():
                self.__target.setPhys1xgTxAlarmInsState("OFF")
            elif self.getProtocol() in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
                self.__target.setPhys1xgTxAlarmInsState("OFF")
            else:
                raise TestPortException("LOS alarm is not available when %s is on %s protocol"%(self, self.getProtocol()))
        elif "LOSYNC" == self.DICT_ALARM[strAlarmType]:
            self.__target.setPcsLosyncAlarm("OFF")
        else:
            raise TestPortException("unknown alarm type")
            
    def stopInjectError(self, strErrorType):
        print("stop injecting error on %s %s slot %s"%(self.__equipmentType__, self.__IP, self.__location))

        if self.DICT_ERROR[strErrorType] in ["MFAS", "SM_BIP", "SM_BEI", "PM_BIP", "PM_BEI", "FEC_CORR", "FEC_ADV", "FEC_UNCORR", "FAS"]:
            self.__target.setOtnTxErrorInsState("OFF")
        elif "FCS" == self.DICT_ERROR[strErrorType]:
            if self.getProtocol() in ["PHYS_PCS_FC2", "PHYS_PCS1G_FC2"]:
                pass
            # elif "PHYS_PCSL_MAC"  == self.getProtocol():
            elif "PHYS_PCSL_MAC" in self.getProtocol():
                self.__target.setErrorInsState("OFF")
            else:
                raise TestPortException("%s error is not available when %s is on %s protocol"%(self.DICT_ERROR[strErrorType], self, self.getProtocol()))
        elif "BIP8" == self.DICT_ERROR[strErrorType]:
            self.__target.setPcsLane100GeErrorInsertState("OFF")
        else:
            raise TestPortException("unknown error type")
                
    # set ethernet stream before test ethernet traffic
    def setEthernetStream(self, **kw):
        strProtocol = self.getProtocol()
        #if strProtocol in ["PHYS_PCSL_MAC"]:
        if "PHYS_PCSL_MAC" in strProtocol:
            for key in kw.keys():
                if "FRAMESIZE" == key.upper():
                    self.__target.setTxTrafficFrameSize("FIX", "ON", str(kw[key]), str(kw[key]))
                elif "TXRATE" == key.upper():
                    print(self.__target.getTxTrafficProfile())
                    self.__target.setTxTrafficProfileEx(sustBand=str(1000*float(kw[key])), mode="CONST", back_to_back="OFF")
                elif "DSTMAC" == key.upper():
                    self.__target.startStop("STOP")
                    print(self.__target.getSelTxMacAddress())
                    self.__target.setSelTxMacAddress({'destAddr':str(int("0x%s"%kw[key].replace(":",""), 16)),'destAddrType':'FIX'})
                    self.__target.startStop("START")
                elif "FCS" == key.upper():
                    if kw[key] is True:
                        self.__target.setErrorInsConfEx("FCS", "CONT")
                        self.__target.setErrorInsState("ON")
                    else:
                        self.__target.setErrorInsState("OFF")
                else:
                    print("unsupport parameter %s"%key)
        else:
            print("setEthernetStream is not available when application is %s on %s"%(strProtocol, self))
            raise TestPortException("setEthernetStream is not available when application is %s on %s"%(strProtocol, self))
    
    def generateEthPm(self, strPmItem, nDuration=30, **kw):
        if strPmItem in ["OCTSTX", "PKTSTX"]:
            if "FRAMESIZE" not in kw.keys():
                kw["FRAMESIZE"] = random.randint(64, 10000)

        elif strPmItem in ["OCTSTXOK", "PKTSTXOK"]:
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False

        elif strPmItem == "PKTSMCSTTX":
            if "DSTMAC" in kw.keys():
                if "ff:ff:ff:ff:ff" == kw["DSTMAC"] or not int(kw["DSTMAC"].split(":")[0], 16) & 0b00000001:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "01:00:00:00:00:01"

            
        elif strPmItem == "PKTSBCSTTX":
            if "DSTMAC" in kw.keys():
                if "ff:ff:ff:ff:ff" != kw["DSTMAC"]:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "ff:ff:ff:ff:ff:ff"
                
        elif strPmItem == "PKTSUCSTTX":
            if "DSTMAC" in kw.keys():
                if int(kw["DSTMAC"].split(":")[0], 16) & 0b00000001:
                    print("DSTMAC should not be %s when pm item is %s"%(kw["DSTMAC"], strPmItem))
            else:
                kw["DSTMAC"] = "00:01:00:00:00:01"
            
        elif strPmItem == "PKTSUSZETX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) >= 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(48, 63)
                pass
                
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "PKTSOSZETX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) <= 9600:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(9601, 10000)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        # elif strPmItem == "FRGMTTX":
            # if "FRAMESIZE" in kw.keys():
                # if int(kw["FRAMESIZE"]) >= 64:
                    # print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            # else:
                # kw["FRAMESIZE"] = random.randint(48, 63)
            # if "FCS" in kw.keys():
                # if kw["FCS"] is not True:
                    # print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            # else:
                # kw["FCS"] = True
            
            
        # elif strPmItem == "JABBERTX":
            # if "FRAMESIZE" in kw.keys():
                # if int(kw["FRAMESIZE"]) <= 9600:
                    # print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            # else:
                # kw["FRAMESIZE"] = random.randint(9601, 16000)
            # if "FCS" in kw.keys():
                # if kw["FCS"] is not True:
                    # print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            # else:
                # kw["FCS"] = True
            
            
        elif strPmItem == "PKTSPAUSTX":
            if "PAUSE" in kw.keys():
                if kw["PAUSE"] is not True:
                    print("PAUSE should not be %s when pm item is %s"%(kw["PAUSE"], strPmItem))
            else:
                kw["PAUSE"] = True
                
        elif strPmItem == "PKTS64OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) != 64:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = 64
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS65-127OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 127 or int(kw["FRAMESIZE"]) < 65:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(65, 127)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS128-255OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 255 or int(kw["FRAMESIZE"]) < 128:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(128, 255)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS256-511OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 511 or int(kw["FRAMESIZE"]) < 256:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(256, 511)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS512-1023OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 1023 or int(kw["FRAMESIZE"]) < 512:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(512, 1023)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
            
        elif strPmItem == "PKTS1024-1518OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) > 1518 or int(kw["FRAMESIZE"]) < 1024:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(1024, 1518)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
            
        elif strPmItem == "PKTSOVER-1518OCTTX":
            if "FRAMESIZE" in kw.keys():
                if int(kw["FRAMESIZE"]) < 1518:
                    print("FRAMESIZE should not be %s when pm item is %s"%(kw["FRAMESIZE"], strPmItem))
            else:
                kw["FRAMESIZE"] = random.randint(1518, 9600)
            if "FCS" in kw.keys():
                if kw["FCS"] is True:
                    print("FCS should not be %s when pm item is %s"%(kw["FCS"], strPmItem))
            else:
                kw["FCS"] = False
                
                
        if "FCS" not in kw.keys():
            kw["FCS"] = False
        if "PAUSE" not in kw.keys():
            kw["PAUSE"] = False
            
        bFCS = kw["FCS"]
        bPause = kw["PAUSE"]
        
        kw["FCS"] = False
        del kw["PAUSE"]
        
        if bFCS and bPause:
            raise TestPortException("FCS and PAUSE should not be injected at the same time")
        
            
        self.stopTx()
        self.clear()
        
        dictTxPM = dict()
        
        if not bFCS and not bPause:
            self.setEthernetStream(**kw)
            
            self.startTx()
            timer0 = time.time()
            nFCS = 0
            # nPause = 0

            if bFCS:
                while (time.time() - timer0) < nDuration:
                    temp = random.randint(1, 50)
                    self.__target.startInjectProtocolError("FCS", temp)
                    nFCS += temp
                    time.sleep(1)
            # elif bPause:
                # while (time.time() - timer0) < nDuration:
                    # self.__target.ethInjectPause(self.getProtocol(), "single")
                    # nPause += 1
            while (time.time() - timer0) < nDuration:
                time.sleep(1)
            self.stopTx()
            
            time.sleep(10)
            # provide pm item your self
            # related to package framesize/dstmac/crc/pause
            if "FRAMESIZE" in kw.keys():
                framesize = kw["FRAMESIZE"]
            else:
                framesize = self.__target.getFrameSize()
            if "DSTMAC" in kw.keys():
                dstmac = kw["DSTMAC"]
            else:
                dstmac = self.__target.getEthDesMAC()
            
            print("framesize:%s"%framesize)
            print("dest mac:%s"%dstmac)
            
            timer0 = time.time()
            
            preTxTotal = -1
            bFinalResult = False
            while (time.time() - timer0) < 30:
                portTrafficDetail = self.getTestResult()
                if preTxTotal == portTrafficDetail["TX_PACKAGE_TOTAL"]:
                    bFinalResult = True
                    break
                else:
                    preTxTotal = portTrafficDetail["TX_PACKAGE_TOTAL"]
                    time.sleep(3)
                    
            if not bFinalResult:
                print("the test statics keeps changing for 30 seconds after traffic stop on %s"%self)
                raise TestPortException("the test statics keep changing for 30 seconds after traffic stop on %s"%self)
            
            dictTxPM["PKTSTX"] = portTrafficDetail["TX_PACKAGE_TOTAL"]
            dictTxPM["OCTSTX"] = portTrafficDetail["TX_PACKAGE_TOTAL"] * framesize
            
            # broadcast/multicast/unicast
            if "FF:FF:FF:FF:FF:FF" == dstmac.upper():
                dictTxPM["PKTSBCSTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTSMCSTTX"] = 0
                dictTxPM["PKTSUCSTTX"] = 0
            elif int(dstmac.split(":")[0], 16) & 0b00000001:
                dictTxPM["PKTSBCSTTX"] = 0
                dictTxPM["PKTSMCSTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTSUCSTTX"] = 0
            else:
                dictTxPM["PKTSBCSTTX"] = 0
                dictTxPM["PKTSMCSTTX"] = 0
                dictTxPM["PKTSUCSTTX"] = dictTxPM["PKTSTX"]
                
            if framesize < 64:
                dictTxPM["PKTSUSZETX"] = dictTxPM["PKTSTX"] - nFCS
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = nFCS
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
                
            elif framesize == 64:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
            elif framesize < 128:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
            elif framesize < 256:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
            elif framesize < 512:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
            elif framesize < 1024:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
            elif framesize <= 1518:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = dictTxPM["PKTSTX"]
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
            elif framesize <= 9600:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = 0
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = 0
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = dictTxPM["PKTSTX"]
            else:
                dictTxPM["PKTSUSZETX"] = 0
                dictTxPM["PKTSOSZETX"] = dictTxPM["PKTSTX"] - nFCS
                dictTxPM["FRGMTTX"] = 0
                dictTxPM["JABBERTX"] = nFCS
                dictTxPM["PKTS64OCTTX"] = 0
                dictTxPM["PKTS65-127OCTTX"] = 0
                dictTxPM["PKTS128-255OCTTX"] = 0
                dictTxPM["PKTS256-511OCTTX"] = 0
                dictTxPM["PKTS512-1023OCTTX"] = 0
                dictTxPM["PKTS1024-1518OCTTX"] = 0
                dictTxPM["PKTSOVER-1518OCTTX"] = 0
        elif bFCS:
            nFCS = random.randint(1,50)
            self.__target.setErrorInsConfEx("FCS", "BURST_ONCE", str(nFCS))
            self.__target.setErrorInsState("ON")
            
            portTrafficDetail = self.getTestResult()
            
            dictTxPM["PKTSTX"] = portTrafficDetail["TX_PACKAGE_TOTAL"]
            if nFCS != dictTxPM["PKTSTX"]:
                raise TestPortException("tx FCS packages not match setting on %s"%self)
            dictTxPM["PKTSTX"] = portTrafficDetail["TX_BYTE_TOTAL"]
            
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
            # how to catalog all this statics?
        elif bPause:
            nPause = random.randint(1,50)
            self.__target.setMacPauseSendConf("ONCE", str(nPause))
            self.__target.setMacPauseSendState("ON")
            
            portTrafficDetail = self.getTestResult()
            
            dictTxPM["PKTSTX"] = portTrafficDetail["TX_PACKAGE_TOTAL"]
            if bPause != dictTxPM["PKTSTX"]:
                raise TestPortException("tx FCS packages not match setting on %s"%self)
            dictTxPM["PKTSTX"] = portTrafficDetail["TX_BYTE_TOTAL"]
            
            dictTxPM["PKTSUSZETX"] = 0
            dictTxPM["PKTSOSZETX"] = 0
            dictTxPM["FRGMTTX"] = 0
            dictTxPM["JABBERTX"] = 0
            dictTxPM["PKTS64OCTTX"] = 0
            dictTxPM["PKTS65-127OCTTX"] = 0
            dictTxPM["PKTS128-255OCTTX"] = 0
            dictTxPM["PKTS256-511OCTTX"] = 0
            dictTxPM["PKTS512-1023OCTTX"] = 0
            dictTxPM["PKTS1024-1518OCTTX"] = 0
            dictTxPM["PKTSOVER-1518OCTTX"] = 0
            # how to catalog all this statics?
        
        for key in dictTxPM.keys():
            print("%s:%s"%(key, str(dictTxPM[key])))
        return dictTxPM
    # set Laser status
    def setLaser(self, strStatus):
        return self.__target.setPhys1xgTxLaser(strStatus)
    
    # get alarm info on test port
    def checkAlarm(self, strAlarmType):
        if self.DICT_ALARM[strAlarmType] == "LOFOTL":
            strAlarmStatus = self.__target.getOTLCstAlarm()
            
            # choose a random lane to check alarm status
            lAlarmStatus = strAlarmStatus.split(",")
            if int(lAlarmStatus[random.randint(1,len(lAlarmStatus)-1)]) & 0x02:
                return "ON"
            else:
                return "OFF"
        else:
            raise TestPortException("unknown test alarm type -- %s"%strAlarmType)
            
    
    # release the test port
    def tearDown(self):
        self.setLaser("OFF")
        self.__target.stopTesting()
        self.__target.close()
        self.__target = None
        time.sleep(3)
        
        



class SpirentPort():
    # protocol and module relationship
    DICT_MODULE = {
        "10GE" : ["DX2-10G-Q8"],
        "40GE" : ["FX2-40G-Q4"],
        "100GE" : ["DX2-100GO-P4"]
    }
    
    DICT_PROTOCOL = {
        # protocol
        "PROTOCOL_ETHERNET_100GE-4LANE-SR4":"100GE",
        "PROTOCOL_ETHERNET_100GE-4LANE-CLR4":"100GE",
        "PROTOCOL_ETHERNET_100GE-4LANE-CWDM4":"100GE",
        "PROTOCOL_ETHERNET_100GE-4LANE-OTHER":"100GE",
        "PROTOCOL_ETHERNET_40GE-4LANE":"40GE",
        "PROTOCOL_ETHERNET_10GE-LAN":"10GE",

        "10ge":"10GE",
        "40ge":"40GE",
        "100ge":"100GE",
        "100ge_SR4":"100GE"
    }
    

    
    _chassis = None
    _iTrafficSteamId = 0
    _session = None
        
    def __init__(self, chassis, port):
        self.port = port
        
        self.__protocol = None
        
        if SpirentPort._session is None:
            SpirentPort._chassis = chassis
            # 1.setup connection
            # Create a SpirentSessionTrans instance 'SpirentSession'
            SpirentPort._session = SpirentSessionTrans(SpirentPort._chassis, "test")
            # Connect to the spirent Chassis. This Part can also write in local function 'setUp'
            SpirentPort._session.connectChassis()
            # Create a project
            SpirentPort._session.create()

        elif chassis != SpirentPort._chassis:
            raise Exception("not able to use two different spirent chassis at the same time.")
            
        # Reserving ports and Subscribe result
        # port format should be slot/port 
        SpirentPort._session.reserveSubscribePort(port.split("/")[0], port.split("/")[1])
        
        # Create Raw IP Stream
        SpirentPort._session.CreateStreamBlockRaw('%d'%SpirentPort._iTrafficSteamId, "//%s/%s"%(SpirentPort._chassis, self.port))
        SpirentPort._iTrafficSteamId += 1
        
        # Save Spirent Xml
        SpirentPort._session.save2xml()
        
    # initPort
    # initial port. set protocol, connector, fec type...
    def init(self, strProtocol, **kw):
    
        self.__protocol = None
        result = True
        
        if strProtocol not in self.DICT_PROTOCOL.keys():
            raise TestPortException("unsupport protocol -- %s"%strProtocol)
            
        lProtocol = self.DICT_PROTOCOL[strProtocol].split("_")
        
        phyManager = stc.get("system1", "children-PhysicalChassisManager")
        # print type(phyManager)
        # print phyManager
        phy = stc.get(phyManager, "children-PhysicalChassis")
        # print type(phy)
        # print phy
        
        module = None
        for moduleTemp in stc.get(phy, "children-PhysicalTestModule").split(" "):
            # print moduleTemp
            if self.port.split("/")[0] == stc.get(moduleTemp, "Index"):
                module = moduleTemp
                # print type(module)
                # print module
                break
        if module is None:
            raise Exception("can not find target module")
        
        strModuleType = stc.get(module, "Model")
        print("module Type of slot %s: %s"%(self.port.split("/")[0], strModuleType))
        if strModuleType not in self.DICT_MODULE[lProtocol[0]]:
            raise Exception("port //%s/%s not support protocol %s"%(SpirentPort._chassis, self.port, lProtocol[0]))
        
        # FX2-40G-Q4 module support 10ge/40ge, should set it the 40ge
        if "FX2-40G-Q4" == strModuleType:
            port = None
            for portTemp in stc.get(SpirentPort._session._project, "children-Port").split(" "):
                # print stc.get(portTemp, "Location")
                if "//%s/%s"%(SpirentPort._chassis, self.port) == stc.get(portTemp, "Location"):
                    port = portTemp
                    break
            if port is None:
                raise Exception("can not find target port")
                
            ethFiber = stc.get(port, "children-EthernetFiber")
            
            print("set LineSpeed on port %s to SPEED_40G"%(self.port))
            stc.config(ethFiber, LineSpeed="SPEED_40G")
            stc.apply()
            
            speed = stc.get(ethFiber, "LineSpeed")
            print("get LineSpeed on port %s: %s"%(self.port, speed))
            if "SPEED_40G" != speed:
                raise Exception("set LineSpeed on port %s failed"%(self.port))
            
        self.__protocol = lProtocol[0]
        
    # release the test port
    def tearDown(self):
        SpirentPort._iTrafficSteamId -= 1
        if 0 == SpirentPort._iTrafficSteamId:
            # Tear down spirent
            SpirentPort._session.delete()
            SpirentPort._session.disconnectChassis()

    # -------------------------------------------------------------------- startTx
    def startTx(self):
        '''
        '''
        SpirentPort._session.TrafficStart("//%s/%s"%(SpirentPort._chassis, self.port))
        
    def stopTx(self):
        SpirentPort._session.TrafficStop("//%s/%s"%(SpirentPort._chassis, self.port))
        
    def getTestResult(self):
        dTrafficResult = dict()
        
        iTxPre = int(SpirentPort._session.GetGeneratorResult("//%s/%s"%(SpirentPort._chassis, self.port), "GeneratorSigFrameCount"))
        bTxStop = False
        timer0 =time.time()
        while time.time() - timer0 < 60:
            time.sleep(2)
            iTxTemp = int(SpirentPort._session.GetGeneratorResult("//%s/%s"%(SpirentPort._chassis, self.port), "GeneratorSigFrameCount"))
            if iTxTemp == iTxPre:
                bTxStop = True
                break
            iTxPre = iTxTemp
            
        if not bTxStop:
            raise Exception("traffic is on, not allow to get test result")
            
        iRxPre = int(SpirentPort._session.GetAnalyzerResult("//%s/%s"%(SpirentPort._chassis, self.port), "SigFrameCount"))
        bRxStop = False
        timer0 =time.time()
        while time.time() - timer0 < 60:
            time.sleep(2)
            iRxTemp = int(SpirentPort._session.GetAnalyzerResult("//%s/%s"%(SpirentPort._chassis, self.port), "SigFrameCount"))
            if iRxTemp == iRxPre:
                bRxStop = True
                break
            iRxPre = iRxTemp
            
        if not bRxStop:
            raise Exception("port still receive packages, not allow to get test result")
            
        dTrafficResult["TX_PACKAGE_TOTAL"] = int(SpirentPort._session.GetGeneratorResult("//%s/%s"%(SpirentPort._chassis, self.port), "GeneratorSigFrameCount"))
        dTrafficResult["RX_PACKAGE_TOTAL"] = int(SpirentPort._session.GetAnalyzerResult("//%s/%s"%(SpirentPort._chassis, self.port), "SigFrameCount"))
        for key in dTrafficResult.keys():
            print("port %s %s:%s"%(self.port, key, dTrafficResult[key]))
        return dTrafficResult
        
    def getProtocol(self):
        return self.__protocol
    
    def clear(self):
        SpirentPort._session.ResultsClearAll()

        
def init(testSetHandle, strProtocol, **kw):
    return testSetHandle.init(strProtocol, **kw)
    
def startTx(testSetHandle):
    return testSetHandle.startTx()
        
def stopTx(testSetHandle):
    return testSetHandle.stopTx()
            
def clear(testSetHandle):
    return testSetHandle.clear()
               
def getTestResult(testSetHandle):
    return testSetHandle.getTestResult()
                   
def startInjectAlarm(testSetHandle, strAlarmType, strAlarmParam=None):
    return testSetHandle.startInjectAlarm(strAlarmType, strAlarmParam)
                      
def startInjectError(testSetHandle, strErrorType, strErrorParam=None):
    return testSetHandle.startInjectError(strErrorType, strErrorParam)
                       
def stopInjectAlarm(testSetHandle, strAlarmType):
    return testSetHandle.stopInjectAlarm(strAlarmType)
                      
def stopInjectError(testSetHandle, strErrorType):
    return testSetHandle.stopInjectError(strErrorType)
    
def setEthernetStream(testSetHandle, **kw):
    return testSetHandle.setEthernetStream(**kw)
    
def setLaser(testSetHandle, strStatus):
    return testSetHandle.setLaser(strStatus)

        
def checkAlarm(testSetHandle, strAlarmType):
    return testSetHandle.checkAlarm(strAlarmType)
        
def tearDown(testSetHandle):
    return testSetHandle.tearDown()
    
def setOTUSMTTITraces(testSetHandle, strMode, strDirection, strValue):
    return testSetHandle.setOTUSMTTITraces(strMode, strDirection, strValue)
    
def setODUPMTTITraces(testSetHandle, strMode, strDirection, strValue):
    return testSetHandle.setODUPMTTITraces(strMode, strDirection, strValue)

    
def setOTNFEC(testSetHandle, strMode):
    return testSetHandle.setOTNFEC(strMode)