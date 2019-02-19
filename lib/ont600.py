# -*- mode: python; fill-column: 80; python-indent: 4 -*-
# Copyright (C) BTI Systems Inc. 2012-2013. All Rights Reserved.
#
# The information contained herein is the property of BTI Systems
# Inc. and is strictly confidential. Except as expressly authorized
# in writing by BTI Systems Inc., the holder shall keep all
# information contained herein confidential, shall disclose the
# information only to its employees with a need to know, and shall
# protect the information, in whole or in part, from disclosure and
# dissemination to third parties with the same degree of care it uses
# to protect its own confidential information, but with no less than
# reasonable care. Except as expressly authorized in writing by BTI
# Systems Inc., the holder is granted no rights to use the
# information contained herein.
#
# Unpublished. All rights reserved under the copyright laws of
# Canada.

'''
Telnet Session for TL1.

@date: Created on April 29 2013
@author: vzheng
'''

#--------------------------------------------------------------------------Imports
import re
import time

import socket
import select

# from base import Session
# from Tkinter import Tcl
from tkinter import Tcl
tcl = Tcl()
tcl.eval('load ../lib/Act_Tcl_Lib')

import imp
bUseAtlasLog = False
if False:
    try:
        a = imp.find_module("atlasLog")
        atlasLog = imp.load_module("atlasLog", a[0], a[1], a[2])
        bUseAtlasLog = True
    except ImportError as e:
        print(e)


#-----------------------------------------------------------------Class Viavi
class Viavi(object):
    '''
    Creates an Viavi Session to a target.  Use this Session type to talk to the
    Viavi test set CT platform for VOA/optical switch/power meter.
    '''
    _socket = None
    _chunk = 128 # buf size
    _vocal = False
    _timeout = 0.150 # Float timeout in secs
    
    def __init__(self, host, port=5001, timeout=None, vocal=True):
        '''
        The host and port are used to create a Viavi session. 

        @type host:  string
        @param host: ip address like '127.0.0.1'
        @type port: int
        @param port: int default as 5024
        @type timeout: float
        @param timeout: timeout seconds
        @type vocal: boolean
        @param vocal: default as True to indicate if the SCPI output the result
        '''
        self._host = host
        self._vocal = vocal
        self._port = int(port)
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
        self.output = ""        
        if timeout is not None: 
            self._socket.settimeout(float(timeout))
            self._timeout = float(timeout)
                      
            
    def open(self):
        '''
        open the Viavi session
        '''
        try:
            self._socket.connect((self._host, self._port))
            self._connectConfirmed()
        except socket.error as e:
            if self._vocal: print('SCPI>> connect(%s:%d) failed: %s'%(self._host, self._port, e))
            else: raise e

    
    def _connectConfirmed(self):
        '''
        get the output from the Viavi session 
        (need to add timeout check later)
        @rtype: boolean
        @return: True when Viavi has the right response,otherwise false
        '''
        if self._socket is None: raise IOError('disconnected')
        
        buf = bytearray()
        result = False
        data = True
        time.sleep(3)
        self.write("*PROMPT ON")
        
        while data:
            r,w,e = select.select([self._socket], [], [self._socket], self._timeout)
            if r: # socket readable
                print("r is True")
                data = self._socket.recv(self._chunk)
                if data: 
                    buf += data
                    # if (buf.find("> ") != -1):
                    result = True
                    data =False
                else: # Socket readable but there is no data
                    data = True        
            else: 
                print("r is False")
                data = True
        return result

    
    def _write(self, cmd):
        '''
        write command to the Viavi session
        @type cmd:  string
        @param cmd: SCPI command to the Viavi
        @rtype: string
        @return: the command to the Viavi
        '''
        if self._socket is None: raise IOError('disconnected')
        
        # for i in xrange(0, len(cmd), self._chunk):
        # transfer from python2.X to python3
        for i in range(0, len(cmd), self._chunk):
            if (i+self._chunk) > len(cmd): idx = slice(i, len(cmd))
            else: idx = slice(i, i+self._chunk)
            # self._socket.sendall(cmd[idx])
            self._socket.sendall(cmd[idx].encode(encoding='utf-8'))
        # return cmd
        return cmd.encode(encoding='utf-8')
    
    def write(self, cmd):
        '''
        write command to the Viavi session using _write and return the command
        @type cmd:  string
        @param cmd: SCPI command to the Viavi
        @rtype: string
        @return: the command to the Viavi
        '''
        try:
            return self._write(cmd + '\r\n')
        except IOError as e:
            if self._vocal: print('SCPI>> write({:s}) failed: {:s}'.format(cmd.strip(), e))
            else: raise e
    
    def _read(self):
        '''
        get the output from the Viavi session 
        
        @rtype: string
        @return: the output from the Viavi
        '''
        if self._socket is None: raise IOError('disconnected')
        buf = bytearray()
        data = True
        while data:
            # r,w,e = select.select([self._socket], [], [self._socket], self._timeout)
            r,w,e = select.select([self._socket], [], [self._socket])
            if r: # socket readable
                data = self._socket.recv(self._chunk)
                if data: 
                    buf += data
                    print(buf)
                    print(type(buf))
                    # if (buf.find(">") != -1):
                    if (buf.decode('utf-8').find(">") != -1):
                        data = False
                else: # Socket readable but there is no data
                    data = True 
       
            else: 
                data = False
        return buf
        
    def send(self, cmd):
        '''
        send command to the Viavi and get the output from Viavi,normall this is the method to send the command and get the output
        @type cmd:  string
        @param cmd: SCPI command to the Viavi
        @rtype: string
        @return: the output from the Viavi
        '''
        self.output = ""
        try:
            cmd = self._write(cmd + '\r\n')
            ans = self._read()
            print(type(ans))
            i = 0
            for i in range(5):
                if ans == '':       #at first time,self._read() will return null,so try again   
                    time.sleep(5)
                    ans = self._read()
                else:
                    break
            if self._vocal:
                print(cmd)
                print(type(cmd))
                print("Viavi command:  " + cmd.decode('utf-8').strip())
                print("Viavi command:      %s"%cmd.decode('utf-8').strip())
                print(self._host , cmd.decode('utf-8').strip())
            if i == 4:
                cmd = self._write('SYST:ERR?\n')
                err = self._read()
                raise Exception('Viavi error happened in retrieving output')
            else:
                self.output = str(ans.decode('utf-8').strip()).replace("\r\nREADY>","")
                print("Viavi output:   " + self.output)
                print("Viavi output:   %s"%self.output)
        except IOError as e: 
            if self._vocal: 
                print('SCPI>> ask(%s) failed: %s'%(cmd.decode('utf-8').strip(), e))
            else: 
                raise e
        return self.output
        
        
    def close(self):
        ''' close the Viavi session
        '''
        self.__del__()
        
    def __del__(self): 
        ''' close the Viavi session
        '''    
        if self._socket is not None: self._socket.close()
        self._socket = None
    
    def isOpen(self):
        ''' to check if Viavi session is opened
        '''  
        return not self._socket == None
    
    # def takeModule(self,slot):
        # ''' use this command to get the wanted module 
        # @type slot: string
        # @param slot: Viavi module id
        # @rtype: ExfoModule
        # @return: instance of ExfoModule
        
        # '''
        # if self.isOpen():
            # self.send('CONNECT LINS'+str(slot))
            
            # matchobj = re.search(r'.*connected to Module at',str(self.output))
            
            # if matchobj:
                # return ExfoModule(self,slot)
            # else:
                
                # raise Exception('Can not connect to slot' + str(slot) + ' ' + self.output)
        # else:
            # raise Exception('Viavi slot is not connected')
            
            
    def clear(self,slot):
        '''
        clear interface errors, this is on the SCPI interface and is not card specific
        '''
        if self.isOpen():
            self.send("*CLS")
            matchobj = re.search(r'.*mmand executed successfully',self.output)
            if matchobj:
                print("clear SCPI interface successfully on slot: " + str(slot))
                return True
            else:
                print("clearing SCPI interface failed on slot: " + str(slot) + " " + self.output)
                return False    
        else:
            raise Exception('Viavi slot is not connected')   
            
    # def isModuleExisted(self,slot):
        # if self.isOpen():
            # self.send("INST:CAT:FULL?")
            # if ',%s'%(slot) in str(self.output):
                # print "successfully to find specificated module on Viavi" 
            # else: 
                # raise Exception('Can not find specificated module on Viavi')
        # else:
            # raise Exception('Viavi slot is not connected')  
            
    # def showAllModules(self):
        # pass

#-----------------------------------------------------------------Class Ont600
class Ont600(object):
    '''
    Creates a Telnet Session to a JDSU test set(ONT-600).  Use this Session type to talk to the
    target via SCPI commands.
    '''

    #-------------------------------------------------------------------- __init__
    #def __init__(self, target, name,
    def __init__(self, address, port):
        '''
        Address, port are provided from caller
        '''
        self._rcport = tcl.eval(' ont_600::GetPort' +' ' +  address + ' '  + port )
        if bUseAtlasLog:
            print(self._rcport)
        else:
            print(self._rcport)
        _plist = self._rcport.split(":")
        
        # try:
        
            # self.__viaviSession.open()
            # strResponse = self.__viaviSession.send(":SOUR:DATA:TEL:FC2:ERR:MODE BURST_ONCE")
            # strResponse = self.__viaviSession.send(":SOUR:DATA:TEL:FC2:ERR:BURS:ACT 1234")
            # strResponse = self.__viaviSession.send(":SOUR:DATA:TEL:FC2:ERR:INS ON")
            # time.sleep(5)
            # print(strResponse)
            # self.__viaviSession.close()
            # # self.SCPI_session
        # except Exception as e:
            # atlasLog.logger.error(e)
            # self.__viaviSession.close()
            
        # time.sleep(3)
        
        self._adr = "TCP::" + address + "::" + _plist[1]
        self._ifc = tcl.eval('ont_UID::init' + ' ' + self._adr)
        if bUseAtlasLog:
            print(self._rcport)
        else:
            print(self._rcport)
        if bUseAtlasLog:
            print(self._ifc)
        else:
            print(self._ifc)
            
        self.__connectionMode = "TCL_LAYERED_APPLICATION_DRIVER"
        # tcl.eval('ontUID::close' + ' ' + self._ifc)

    def close(self):
        _tempCommand = 'ont_UID::close' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        if "TCL_LAYERED_APPLICATION_DRIVER" == self.__connectionMode:
            self.__connectionMode = None
        return tcl.eval(_tempCommand)    
    
    # automation can not login both SCPI and Tcl Layered Application Driver at the same time
    # so if we need to login viavi in SCPI connection, we should log out Tcl Layered Application Driver connection
    # if we need to login viavi in Tcl Layered Application Driver connection, we should log out SCPI connection
    def __login(self, strMode="TCL_LAYERED_APPLICATION_DRIVER"):
        ''' loginMode could be SCPI or Tcl Layered Application Driver'''
        if self.__connectionMode == strMode:
            pass
        else:
            if "SCPI" == strMode:
                self.close()
                time.sleep(3)
                self.__viaviSession = Viavi(self._adr.split("::")[-2], self._adr.split("::")[-1])
                self.__viaviSession.open()
                self.__connectionMode = "SCPI"
            elif "TCL_LAYERED_APPLICATION_DRIVER" == strMode:
                self.__viaviSession.close()
                time.sleep(3)
                self._ifc = tcl.eval('ont_UID::init' + ' ' + self._adr)
                self.__connectionMode = "TCL_LAYERED_APPLICATION_DRIVER"
            else:
                print("unknown connect mode -- %s"%strMode)
                raise Exception("unknown connect mode -- %s"%strMode)
    
    def isPortProtected(self):
        _tempCommand = 'ont_600::IsPortProtected' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
    
    def loginUser(self,username,password):
        _tempCommand = 'ont_600::LoginUser' + ' ' + self._ifc+ ' ' + username+ ' ' + password
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getCurrentUser(self):
        _tempCommand = 'ont_600::GetCurrentUser' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def setUser(self,username,password):
        _tempCommand = 'ont_600::SetUser' + ' ' + self._ifc+ ' ' + username+ ' ' + password
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
       
    def close(self):
        _tempCommand = 'ontUID::close' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
        
    def send(self,command):
        _tempCommand = 'ontUID::send' + ' ' + self._ifc + ' ' + str(command)
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        tcl.eval(_tempCommand)
        if re.match(r'(.*)PROMPT(.*)', command):
            pass
        else:
            _tempCommand = 'ontUID::receive' + ' ' + self._ifc
            if bUseAtlasLog:
                print(_tempCommand)
            else:
                print(_tempCommand)
            return tcl.eval(_tempCommand)
            
    def setTimeOut(self,timeout):
        _tempCommand = 'ontUID::setTimeOut' + ' ' + str(timeout)
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def isLayered(self):
        _tempCommand = 'ont_LAY::IsLayered' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setLayerStack(self,devmode,laystack):
        _tempCommand = 'ont_LAY::SetLayerStack' + ' ' + self._ifc + ' ' + devmode + ' ' + laystack
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def getAvailableMode(self):
        _tempCommand = 'ont_LAY::GetAvailableModes' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getCurrentLayerStack(self):
        _tempCommand = 'ont_LAY::GetCurrentLayerStack' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def getModuleInfo(self):
        _tempCommand = 'ont_LAY::GetModuleInfo' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def loadApplication(self,application):
        _tempCommand = 'ont_LAY::LoadApplication' + ' ' + self._ifc + ' ' + application
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
         
        
    def loadUserApplication(self,application,directory):
        _tempCommand = 'ont_LAY::LoadUserApplication' + ' ' + self._ifc + ' ' + application + ' ' + directory
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def saveUserApplication(self,application,directory):
        _tempCommand = 'ont_LAY::SaveUserApplication' + ' ' + self._ifc + ' ' + application + ' ' + directory
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getLoadableUserApplication(self,directory):
        _tempCommand = 'ont_LAY::GetLoadableUserApplication' + ' ' + self._ifc + ' ' + directory
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def deleteApplication(self,loadedApplicationString):
        _tempCommand = 'ont_LAY::DeleteApplication' + ' ' + self._ifc + ' ' + loadedApplicationString
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def deleteAllApplication(self):
        _tempCommand = 'ont_LAY::DeleteAllApplication' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getLoadedApplication(self):
        _tempCommand = 'ont_LAY::GetLoadedApplication' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getApplicationType(self):
        _tempCommand = 'ont_LAY::GetApplicationType' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setMtmPortConfig(self,config):
        _tempCommand = 'ont_LAY::SetMtmPortConfig' + ' ' + self._ifc + ' ' + config 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getMtmPortConfig(self):
        _tempCommand = 'ont_LAY::GetMtmPortConfig' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getMtmPortConfigList(self):
        _tempCommand = 'ont_LAY::GetMtmPortConfigList' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def waitOpcComplete(self):
        _tempCommand = 'ont_MEAS::WaitOpcComplete' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setGatingTime(self,gate):
        _tempCommand = 'ont_MEAS::SetGatingTime' + ' ' + self._ifc + ' ' + gate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def startStop(self,measurementMode,measurementTime=-1):
        _tempCommand = 'ont_MEAS::StartStop' + ' ' + self._ifc + ' ' + measurementMode+ ' ' + str(measurementTime)
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getGatingTime(self):
        _tempCommand = 'ont_MEAS::GetGatingTime' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
    
    def waitMeasureDone(self):
        _tempCommand = 'ont_MEAS::WaitMeasureDone' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)      
     
    def getMeasurementStatus(self):
        _tempCommand = 'ont_MEAS::GetMeasurementStatus' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
    
    def getAtim(self):
        _tempCommand = 'ont_MEAS::GetAtim' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
    
    def getEtim(self):
        _tempCommand = 'ont_MEAS::GetEtim' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getStim(self):
        _tempCommand = 'ont_MEAS::GetStim' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    #-------10GigE/MTM4S4X physical layer functions--------
    
    def setPhys1xgTxInterface(self,connector,wavelength,clockSource,freqOffset):
        _tempCommand = 'ont_PHYS1XG::SetTxInterface' + ' ' + self._ifc+ ' ' + interface+ ' ' + connector+ ' ' + wavelength+ ' ' + clockSource+ ' ' + freqOffset 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def setPhys1xgTxTunableWavelength(self,wavelength,unit):
        _tempCommand = 'ont_PHYS1XG::SetTxTunableWavelength' + ' ' + self._ifc+ ' ' + wavelength+ ' ' + unit 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
    
    def setPhys1xgTxFreqDirectRef(self,freqDirectRef):
        _tempCommand = 'ont_PHYS1XG::SetTxFreqDirectRef' + ' ' + self._ifc+ ' ' + freqDirectRef
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xgTxFreqOffset(self,freqOffset):
        _tempCommand = 'ont_PHYS1XG::SetTxFreqOffset' + ' ' + self._ifc+ ' ' + freqOffset
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def setPhys1xgTxLaser(self,state):
        _tempCommand = 'ont_PHYS1XG::SetTxLaser' + ' ' + self._ifc+ ' ' + state
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def setPhys1xgTxConnector(self,connector):
        _tempCommand = 'ont_PHYS1XG::SetTxConnector' + ' ' + self._ifc+ ' ' + connector
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def setPhys1xgTxBitrate(self,bitrate):
        _tempCommand = 'ont_PHYS1XG::SetTxBitrate' + ' ' + self._ifc+ ' ' + bitrate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
    
    
    def setPhys4xgTxConnector(self,connector):
        _tempCommand = 'ont_PHYS4XG::SetTxConnector' + ' ' + self._ifc+ ' ' + connector
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
    
    def setPhys4xgTxBitrate(self,bitrate):
        _tempCommand = 'ont_PHYS4XG::SetTxBitrate' + ' ' + self._ifc+ ' ' + bitrate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
    
    
    def setPhys1xxgTxBitrate(self,bitrate):
        _tempCommand = 'ont_PHYS1XXG::SetTxBitrate' + ' ' + self._ifc+ ' ' + bitrate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def setPhys1xxgTxConnector(self,connector):
        _tempCommand = 'ont_PHYS1XXG::SetTxConnector' + ' ' + self._ifc+ ' ' + connector
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def setPhys1xxgCFP2TxInterface(self,interface,connector="",clockSource="",freqOffset=""):
        _tempCommand = 'ont_PHYS1XXGCFP2::SetTxInterface' + ' ' + self._ifc + ' ' + interface + ' ' + connector + ' ' + clockSource + ' ' + freqOffset 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xxgCFP2TxBitrate(self,bitrate):
        _tempCommand = 'ont_PHYS1XXGCFP2::SetTxBitrate' + ' ' + self._ifc+ ' ' + bitrate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def setPhys1xxgCFP2TxConnector(self,connector):
        _tempCommand = 'ont_PHYS1XXGCFP2::SetTxConnector' + ' ' + self._ifc+ ' ' + connector
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xxgCFP2TxInterface(self):
        _tempCommand = 'ont_PHYS1XXGCFP2::GetTxInterface' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def getPhys1xgTxInterface(self):
        _tempCommand = 'ont_PHYS1XG::GetTxInterface' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def getPhys1xgTxTunableWavelength(self):
        _tempCommand = 'ont_PHYS1XG::GetTxTunableWavelength' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
    
    def getPhys1xgTxFreqDirectRef(self):
        _tempCommand = 'ont_PHYS1XG::GetTxFreqDirectRef' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgTxFreqOffset(self):
        _tempCommand = 'ont_PHYS1XG::GetTxFreqOffset' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def getPhys1xgTxLaser(self):
        _tempCommand = 'ont_PHYS1XG::GetTxLaser' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def getPhys1xgTxConnector(self):
        _tempCommand = 'ont_PHYS1XG::GetTxConnector' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def getPhys1xgTxBitrate(self):
        _tempCommand = 'ont_PHYS1XG::GetTxBitrate' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    #----- alarm insertion-----------------
    
    def setPhys1xgTxAlarmInsConf(self,alarmInsertType,alarmInsertMode):
        _tempCommand = 'ont_PHYS1XG::SetTxAlarmInsConf' + ' ' + self._ifc+ ' ' + alarmInsertType + ' ' +alarmInsertMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xgCFP2TxAlarmInsRange(self,alarmRange, alarmSingle):
        _tempCommand = 'ont_PHYS1XXGCFP2::SetTxAlarmInsRange' + ' ' + self._ifc+ ' ' + alarmRange + ' ' +alarmSingle
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xgTxAlarmInsState(self,state):
        _tempCommand = 'ont_PHYS1XG::SetTxAlarmInsState' + ' ' + self._ifc+ ' ' + state
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgTxAlarmInsConf(self):
        _tempCommand = 'ont_PHYS1XG::GetTxAlarmInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgTxAlarmInsState(self):
        _tempCommand = 'ont_PHYS1XG::GetTxAlarmInsState' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def setPhys1xgRxInterface(self,interface,connector):
        _tempCommand = 'ont_PHYS1XG::SetRxInterface' + ' ' + self._ifc + ' ' + interface + ' ' + connector
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xgRxConnector(self,connector):
        _tempCommand = 'ont_PHYS1XG::SetRxConnector' + ' ' + self._ifc + ' ' + connector
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xgRxBitrate(self,bitrate):
        _tempCommand = 'ont_PHYS1XG::SetRxBitrate' + ' ' + self._ifc + ' ' + bitrate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xgRxInterface(self):
        _tempCommand = 'ont_PHYS1XG::GetRxInterface' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgRxConnector(self):
        _tempCommand = 'ont_PHYS1XG::GetRxConnector' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgRxBitrate(self):
        _tempCommand = 'ont_PHYS1XG::GetRxBitrate' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def getPhys1xgRxSummaryState(self,currHistMode):
        _tempCommand = 'ont_PHYS1XG::GetRxSummaryState' + ' ' + self._ifc  + ' ' + currHistMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgRxPowerFreqOffset(self):
        _tempCommand = 'ont_PHYS1XG::GetRxPowerFreqOffset' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
      
    def getPhys1xgRxResults(self):
        _tempCommand = 'ont_PHYS1XG::GetRxResults' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getPhys1xgEventListCount(self):
        _tempCommand = 'ont_PHYS1XG::GetEventListCount' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def getPhys1xgNextEventListEntry(self):
        _tempCommand = 'ont_PHYS1XG::GetNextEventListEntry' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    def getPhys1xgNextEventsAsList(self,reqcount):
        _tempCommand = 'ont_PHYS1XG::GetNextEventsAsList' + ' ' + self._ifc + ' ' + reqcount
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
             
    def gotoPhys1xgEventListBeginning(self):
        _tempCommand = 'ont_PHYS1XG::GotoEventListBeginning' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
        
        
    def setPhys1xgTxPayload(self,testPattern):
        _tempCommand = 'ont_PHYS1XG::SetTxPayload' + ' ' + self._ifc + ' ' + testPattern
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def setPhys1xgTxPaylErrorInsConf(self,errorInsertionMode,errorInsertionRate):
        _tempCommand = 'ont_PHYS1XG::SetTxPaylErrorInsConf' + ' ' + self._ifc + ' ' + errorInsertionMode + ' ' + errorInsertionRate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
    
    def setPhys1xgTxPaylErrorInsState(self,errorInsertionState):
        _tempCommand = 'ont_PHYS1XG::SetTxPaylErrorInsState' + ' ' + self._ifc + ' ' + errorInsertionState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getPhys1xgTxPayload(self):
        _tempCommand = 'ont_PHYS1XG::GetTxPayload' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getPhys1xgTxPaylErrorInsConf(self):
        _tempCommand = 'ont_PHYS1XG::GetTxPaylErrorInsConf' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
    
    def getPhys1xgTxPaylErrorInsState(self):
        _tempCommand = 'ont_PHYS1XG::GetTxPaylErrorInsState' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPhys1xgRxExpPayload(self,testpattern):
        _tempCommand = 'ont_PHYS1XG::SetRxExpPayload' + ' ' + self._ifc  + ' ' + testpattern 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgRxExpPayload(self):
        _tempCommand = 'ont_PHYS1XG::GetRxExpPayload' + ' ' + self._ifc  
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPhys1xgRxPaylResults(self):
        _tempCommand = 'ont_PHYS1XG::GetRxPaylResults' + ' ' + self._ifc  
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
       
       
    #--------- Mac layer ----------------------------------
    def getRxTotalBandwResults(self):
        _tempCommand = 'ont_MAC::GetRxTotalBandwResults' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 

    def getRxTotalUtilization(self):
        tempResult = self.getRxTotalBandwResults()
        if bUseAtlasLog:
            print(tempResult)
        else:
            print(tempResult)
        match = re.search('{currUtilization (.*?)}',tempResult)
        if match:
            return match.group(1)
        else:
            return False

    def getRxTotalFrameResults(self):
        _tempCommand = 'ont_MAC::GetRxTotalFrameResults' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        print
        return tcl.eval(_tempCommand) 

    def getRxTotalFrameCount(self):
        tempResult = self.getRxTotalFrameResults()
        if bUseAtlasLog:
            print(tempResult)
        else:
            print(tempResult)
        match = re.search('{countFrame (.*?)}',tempResult)
        if match:
            # convert the match to an integer before returning it
            return int(match.group(1))
        else:
            return False
        
    def getRxTotalByteCount(self):
        tempResult = self.getRxTotalFrameResults()
        if bUseAtlasLog:
            print(tempResult)
        else:
            print(tempResult)
        match = re.search('{countByte (.*?)}',tempResult)
        if match:
            # convert the match to an integer before returning it
            return int(match.group(1))
        else:
            return False
        
    def getTxTotalFrameResults(self):
        _tempCommand = 'ont_MAC::GetTxTotalFrameResults' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)

        return tcl.eval(_tempCommand) 

    def getTxTotalFrameCount(self):
        tempResult = self.getTxTotalFrameResults()
        if bUseAtlasLog:
            print(tempResult)
        else:
            print(tempResult)
        match = re.search('{countFrame (.*?)}',tempResult)
        if match:
            # convert the match to an integer before returning it
            return int(match.group(1))
        else:
            return False

    def getTxTotalByteCount(self):
        tempResult = self.getTxTotalFrameResults()
        if bUseAtlasLog:
            print(tempResult)
        else:
            print(tempResult)
        match = re.search('{countByte (.*?)}',tempResult)
        if match:
            # convert the match to an integer before returning it
            return int(match.group(1))
        else:
            return False
            
    def getRxMacResults(self):
        _tempCommand = 'ont_MAC::GetRxMacResults' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
    
    def getRxMacErrored(self):
        tempResult = self.getRxMacResults()
        if bUseAtlasLog:
            print(tempResult)
        else:
            print(tempResult)
        match1 = re.search('{errorCountRUNT (.*?)}',tempResult)
        if match1:
            if bUseAtlasLog:
                print("the RUNT error is:" + match1.group(1))
            else:
                print("the RUNT error is:" + match1.group(1))
            
        match2 = re.search('{errorCountOSIZ (.*?)}',tempResult)
        if match2:
            if bUseAtlasLog:
                print("the OSIZ error is:" + match2.group(1))
            else:
                print("the OSIZ error is:" + match2.group(1))
            
        match3 = re.search('{errorCountFCS (.*?)}',tempResult)
        if match3:
            if bUseAtlasLog:
                print("the FCS error is:" + match3.group(1))
            else:
                print("the FCS error is:" + match3.group(1))
            
        match4 = re.search('{errorCountFRAM (.*?)}',tempResult)
        if match4:
            if bUseAtlasLog:
                print("the FRAM error is:" + match4.group(1))
            else:
                print("the FRAM error is:" + match4.group(1))
            
        if (int(match1.group(1)) > 0) or (int(match2.group(1)) > 0) or (int(match3.group(1)) > 0) or (int(match4.group(1)) > 0):
            return True
        
        else:
            return False
            
    def setTxTrafficSendMode(self,mode):
        '''
        mode:CONT,ONCE
        '''
        _tempCommand = 'ont_MAC::SetTxTrafficSendMode' + ' ' + self._ifc + ' '+ mode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getTxTrafficFrameSize(self): 
        '''
        mode:FIX INC DEC RAND, oversized:OFF ON
        '''
        _tempCommand = 'ont_MAC::GetTxTrafficFrameSize' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)       
        
    def setTxTrafficFrameSize(self,mode,oversized,Size,maxSize='2000',stepSize='1'):
        '''
        mode:FIX INC DEC RAND, oversized:OFF ON
        '''     
        _tempCommand = 'ont_MAC::SetTxTrafficFrameSize' + ' ' + self._ifc + ' ' + mode + ' ' + oversized + ' ' + Size + ' ' + maxSize + ' ' + stepSize
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  

    def getTxTrafficProfile(self): 
        '''
        mode:FIX INC DEC RAND, oversized:OFF ON
        '''
        _tempCommand = 'ont_MAC::GetTxTrafficProfile' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
            
        
    def setTxTrafficProfile(self,onceSize): 
        '''
        only set onceSize, read the rest value and reset with the same value again. 
        '''
        tempResult = self.getTxTrafficProfile()
        
        match1 = re.search('{sustBand (.*?)}',tempResult)
        try:
            sustBand = match1.group(1)
        except:
            print("error:No sustBand match")
            
        match2 = re.search('{b2b (.*?)}',tempResult)
        try:
            back_to_back = match2.group(1)
        except:
            print("error:No back_to_back match")

        match3 = re.search('{mode (.*?)}',tempResult)
        try:
            mode = match3.group(1)
        except:
            print("error:No mode match")
            
        match4 = re.search('{peakBand (.*?)}',tempResult)
        try:
            peakBand = match4.group(1)
        except:
            print("error:No peakBand match")
        
        match5 = re.search('{burstSize (.*?)}',tempResult)
        try:
            burstSize = match5.group(1)
        except:
            print("error:No burstSize match")
            
        _tempCommand = 'ont_MAC::SetTxTrafficProfile' + ' ' + self._ifc + ' ' + sustBand+ ' ' + back_to_back + ' ' + onceSize + ' ' + mode + ' ' + peakBand + ' ' + burstSize
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
        
    def setTxTrafficProfileEx(self,**kw): 
        '''
        read the rest value and reset with the same value again. 
        '''
        tempResult = self.getTxTrafficProfile()
        
        if "sustBand" in kw.keys():
            sustBand = kw["sustBand"]
        else:
            match1 = re.search('{sustBand (.*?)}',tempResult)
            try:
                sustBand = match1.group(1)
            except:
                print("error:No sustBand match")
                
        if "back_to_back" in kw.keys():
            back_to_back = kw["back_to_back"]
        else:
            match2 = re.search('{b2b (.*?)}',tempResult)
            try:
                back_to_back = match2.group(1)
            except:
                print("error:No back_to_back match")
        
        if "mode" in kw.keys():
            mode = kw["mode"]
        else:
            match3 = re.search('{mode (.*?)}',tempResult)
            try:
                mode = match3.group(1)
            except:
                print("error:No mode match")
        
        if "peakBand" in kw.keys():
            peakBand = kw["peakBand"]
        else:
            match4 = re.search('{peakBand (.*?)}',tempResult)
            try:
                peakBand = match4.group(1)
            except:
                print("error:No peakBand match")
        
        if "burstSize" in kw.keys():
            burstSize = kw["burstSize"]
        else:
            match5 = re.search('{burstSize (.*?)}',tempResult)
            try:
                burstSize = match5.group(1)
            except:
                print("error:No burstSize match")
                
        if "onceSize" in kw.keys():
            onceSize = kw["onceSize"]
        else:
            match5 = re.search('{onceSize (.*?)}',tempResult)
            try:
                onceSize = match5.group(1)
            except:
                print("error:No onceSize match")
            
        _tempCommand = 'ont_MAC::SetTxTrafficProfile' + ' ' + self._ifc + ' ' + sustBand+ ' ' + back_to_back + ' ' + onceSize + ' ' + mode + ' ' + peakBand + ' ' + burstSize
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def getSelTxMacAddress(self): 
        '''
        mode:FIX INC DEC RAND, oversized:OFF ON
        '''
        _tempCommand = 'ont_MAC::GetSelTxMacAddress' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setSelTxMacAddress(self,dict): 
        '''
        dict is a dictionnary,like {'destAddr':'1649636540416','destAddrType':'MULTICAST'},{'destAddr':'281474976710655','destAddrType':'BROADCAST'}
        '''
        tempResult = self.getSelTxMacAddress()
        
        match1 = re.search('{sourceAddr (.*?)}',tempResult)  
        try:
            sourceAddr = dict['sourceAddr']
        except:
            print("use current sourceAddr as input")
            try:
                sourceAddr = match1.group(1)
            except:
                print("error:No sourceAddr  match")
        
        match2 = re.search('{sourceAddrType (.*?)}',tempResult)  
        try:
            sourceAddrType = dict['sourceAddrType']
        except:
            print("use current sourceAddrType as input")
            try:
                sourceAddrType = match2.group(1)
            except:
                print("error:No sourceAddrType  match")
                
        match3 = re.search('{destAddr (.*?)}',tempResult)  
        try:
            destAddr = dict['destAddr']
        except:
            print("use current destAddr as input")
            try:
                destAddr = match3.group(1)
            except:
                print("error:No destAddr match")
                
        match4 = re.search('{destAddrType (.*?)}',tempResult)  
        try:
            destAddrType = dict['destAddrType']
        except:
            print("use current destAddrType as input")
            try:
                destAddrType = match4.group(1)
            except:
                print("error:No destAddrType match")
                
        _tempCommand = 'ont_MAC::SetSelTxMacAddress' + ' ' + self._ifc + ' ' + sourceAddr + ' ' + sourceAddrType + ' ' + destAddr + ' ' + destAddrType
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getErrorInsConf(self): 
        '''
        mode:FIX INC DEC RAND, oversized:OFF ON
        '''
        _tempCommand = 'ont_MAC::GetErrorInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
 


    def setErrorInsConf(self,errorInsertionType,activeFrames='1'): 
        '''
        oversize:'{errorInsertionType OV} {errorInsertionMode ONCE} {activeFrames 1} {inactiveFrames 10000} {errorInsertionRate 0.001} {flowRange ALL} {selectedFlow 1}'
        FCS:'{errorInsertionType FCS} {errorInsertionMode ONCE} {activeFrames 1} {inactiveFrames 10000} {errorInsertionRate 0.001} {flowRange ALL} {selectedFlow 1}'
        Undersize:'{errorInsertionType Runt} {errorInsertionMode ONCE} {activeFrames 1} {inactiveFrames 10000} {errorInsertionRate 0.001} {flowRange ALL} {selectedFlow 1}'
        '''
        _tempCommand = 'ont_MAC::SetErrorInsConf' + ' ' + self._ifc + ' ' + errorInsertionType + ' ' + 'ONCE' + ' ' + activeFrames + ' ' + '10000' + ' ' + '0.001' + ' ' + 'ALL' + ' ' + '1' 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
    
    def setErrorInsConfEx(self,errorInsertionType,errorInsertionMode,activeFrames='1',inactiveFrames='10000',errorInsertionRate='0.001',flowRange="ALL",selectedFlow='1'): 
        '''
        oversize:'{errorInsertionType OV} {errorInsertionMode ONCE} {activeFrames 1} {inactiveFrames 10000} {errorInsertionRate 0.001} {flowRange ALL} {selectedFlow 1}'
        FCS:'{errorInsertionType FCS} {errorInsertionMode ONCE} {activeFrames 1} {inactiveFrames 10000} {errorInsertionRate 0.001} {flowRange ALL} {selectedFlow 1}'
        Undersize:'{errorInsertionType Runt} {errorInsertionMode ONCE} {activeFrames 1} {inactiveFrames 10000} {errorInsertionRate 0.001} {flowRange ALL} {selectedFlow 1}'
        '''
        _tempCommand = 'ont_MAC::SetErrorInsConf' + ' ' + self._ifc + ' ' + errorInsertionType + ' ' + errorInsertionMode + ' ' + activeFrames + ' ' + inactiveFrames + ' ' + errorInsertionRate + ' ' + flowRange + ' ' + selectedFlow
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def setErrorInsState(self,state): 
        '''
        OFF ,ON
        '''
        _tempCommand = 'ont_MAC::SetErrorInsState' + ' ' + self._ifc + ' '+ state
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)      
        
        
                    
    def startTesting(self):
        _tempCommand = 'ont_MEAS::StartStop' + ' ' + self._ifc + ' '  + 'START' + ' ' + '-1'
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    
    def stopTesting(self):
        _tempCommand = 'ont_MEAS::Start_Stop' + ' ' + self._ifc + ' ' + 'STOP'
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def isTesting(self):
        _tempCommand = 'ont_MEAS::GetMeasureStatus' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        if "0" == tcl.eval(_tempCommand):
            if bUseAtlasLog:
                print("False")
            return False
        else:
            if bUseAtlasLog:
                print("True")
            return True
            
    def clearTesting(self):
        if bUseAtlasLog:
            print('now clear the current testing result')
        else:
            print('now clear the current testing result')
        self.stopTesting()
        
        self.startTesting()

    def setTrafficGenerator(self,mode):
        if bUseAtlasLog:
            print('Set the traffic generator: ' + mode)
        else:
            print('Set the traffic generator: ' + mode)
        _tempCommand = 'ont_MAC::SetTxTrafficGenerator' + ' ' + self._ifc + ' ' + mode
        return tcl.eval(_tempCommand)
    
    #----------OTN Layer------------------------------------   
    def getOtnTxLayerRate(self):
        _tempCommand = 'ont_OTN::GetTxLayerRate' + ' ' + self._ifc  
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOtuOh(self,overhead):
        _tempCommand = 'ont_OTN::SetTxOtuOh' + ' ' + self._ifc  + ' ' + overhead
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOtuOhByte(self,byte,row,column):
        _tempCommand = 'ont_OTN::SetTxOtuOhByte' + ' ' + self._ifc  + ' ' +byte+ ' ' +row+ ' ' +column
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def setOtnTxOtuSequence(self,sequence,row,column):
        _tempCommand = 'ont_OTN::SetTxOtuSequence' + ' ' + self._ifc  + ' ' +sequence+ ' ' +row+ ' ' +column
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOtuSequenceStatus(self,status):
        _tempCommand = 'ont_OTN::SetTxOtuSequenceStatus' + ' ' + self._ifc  + ' ' +status
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOtuOh(self):
        _tempCommand = 'ont_OTN::GetTxOtuOh' + ' ' + self._ifc  
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
            
        
    def getOtnTxOtuOhByte(self):
        _tempCommand = 'ont_OTN::GetTxOtuOhByte' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
 
        
        
    def getOtnTxOtuSequence(self):
        _tempCommand = 'ont_OTN::GetTxOtuSequence' + ' ' + self._ifc  
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOtuSequenceStatus(self,status):
        _tempCommand = 'ont_OTN::GetTxOtuSequenceStatus' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def setOtnTxOtuSmon(self,montype,value):
        _tempCommand = 'ont_OTN::SetTxOtuSmon' + ' ' + self._ifc + ' ' + montype + ' ' + value
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOtuSmonMode(self,mode):
        _tempCommand = 'ont_OTN::SetTxOtuSmonMode' + ' ' + self._ifc + ' ' + mode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOtuSmon(self):
        _tempCommand = 'ont_OTN::GetTxOtuSmon' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOtuSmonMode(self):
        _tempCommand = 'ont_OTN::GetTxOtuSmonMode' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def setOtnTxOduPmon(self,montype,value):
        _tempCommand = 'ont_OTN::SetTxOduPmon' + ' ' + self._ifc + ' ' + montype + ' ' + value
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOtuSmonMode(self,mode):
        _tempCommand = 'ont_OTN::SetTxOduPmonMode' + ' ' + self._ifc + ' ' + mode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
      
    def setOtnTxOduFtfl(self,forwind,backind,forwoid,backoid,forwosp,backosp):
        _tempCommand = 'ont_OTN::SetTxOduFtfl' + ' ' + self._ifc + ' ' + forwind + ' ' + backind + ' ' + forwoid + ' ' + backoid + ' ' + forwosp+ ' ' + backosp
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOduFtflMode(self,mode):
        _tempCommand = 'ont_OTN::SetTxOduFtflMode' + ' ' + self._ifc + ' ' + mode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOduTcm(self,tcm,tcmtype,value):
        _tempCommand = 'ont_OTN::SetTxOduTcm' + ' ' + self._ifc + ' ' + tcm+ ' ' + tcmtype+  ' ' + value
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def setOtnTxOduTcmMode(self,tcm,mode):
        _tempCommand = 'ont_OTN::SetTxOduTcmMode' + ' ' + self._ifc + ' ' + tcm+ ' ' + mode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOduTcmStatus(self,tcm,status):
        _tempCommand = 'ont_OTN::SetTxOduTcmStatus' + ' ' + self._ifc + ' ' + tcm+ ' ' + status
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
        
    def getOtnTxOduPmon(self,montype):
        _tempCommand = 'ont_OTN::GetTxOduPmon' + ' ' + self._ifc + ' ' + montype 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOtuSmonMode(self):
        _tempCommand = 'ont_OTN::GetTxOduPmonMode' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
      
    def getOtnTxOduFtfl(self):
        _tempCommand = 'ont_OTN::GetTxOduFtfl' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOduFtflMode(self):
        _tempCommand = 'ont_OTN::GetTxOduFtflMode' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOduTcm(self,tcm,tcmtype):
        _tempCommand = 'ont_OTN::GetTxOduTcm' + ' ' + self._ifc + ' ' + tcm+ ' ' + tcmtype
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
        
    def getOtnTxOduTcmMode(self,tcm):
        _tempCommand = 'ont_OTN::GetTxOduTcmMode' + ' ' + self._ifc + ' ' + tcm
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOduTcmStatus(self,tcm):
        _tempCommand = 'ont_OTN::GetTxOduTcmStatus' + ' ' + self._ifc + ' ' + tcm
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    
    def setOtnTxOpuPsiSeq(self,sequence):
        _tempCommand = 'ont_OTN::SetTxOpuPsiSeq' + ' ' + self._ifc + ' ' + sequence
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxOpuPayloadType(self,ptyp):
        _tempCommand = 'ont_OTN::SetTxOpuPayloadType' + ' ' + self._ifc + ' ' + ptyp
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
       
    def setOtnTxOpuPsiMode(self,mode):
        _tempCommand = 'ont_OTN::SetTxOpuPsiMode' + ' ' + self._ifc + ' ' + mode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
    
    def getOtnTxOpuPsiSeq(self):
        _tempCommand = 'ont_OTN::GetTxOpuPsiSeq' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxOpuPayloadType(self):
        _tempCommand = 'ont_OTN::GetTxOpuPayloadType' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
       
    def getOtnTxOpuPsiMode(self):
        _tempCommand = 'ont_OTN::GetTxOpuPsiMode' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
    
    def setOtnTxFecGeneration(self,fec):
        _tempCommand = 'ont_OTN::SetTxFecGeneration' + ' ' + self._ifc  + ' ' + fec 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
      
    def getOtnTxFecGeneration(self):
        _tempCommand = 'ont_OTN::GetTxFecGeneration' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    #----- alarm insertion for OTU -------------
    def setOtnTxAlarmInsConf(self,alarmInsertType,alarmInsertMode,activeFrames,inactiveFrames):
        _tempCommand = 'ont_OTN::SetTxAlarmInsConf' + ' ' + self._ifc + ' ' + alarmInsertType + ' ' + alarmInsertMode + ' ' + activeFrames + ' ' + inactiveFrames
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxAlarmInsState(self,state):
        _tempCommand = 'ont_OTN::SetTxAlarmInsState' + ' ' + self._ifc + ' ' + state
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxAlarmInsConf(self):
        _tempCommand = 'ont_OTN::GetTxAlarmInsConf' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxAlarmInsState(self):
        _tempCommand = 'ont_OTN::GetTxAlarmInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxErrorInsConf(self,errorInsertType,errorInsertMode,errorInsertionRate,activeFrames,inactiveFrames):
        _tempCommand = 'ont_OTN::SetTxErrorInsConf' + ' ' + self._ifc + ' ' + errorInsertType+ ' ' + errorInsertMode+ ' ' + errorInsertionRate + ' ' + activeFrames+ ' ' + inactiveFrames
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxErrorInsState(self,state):
        _tempCommand = 'ont_OTN::SetTxErrorInsState' + ' ' + self._ifc + ' ' + state
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setOtnTxFecErrorConf(self,row,subrow,cnt,pos,mask):
        _tempCommand = 'ont_OTN::SetTxFecErrorConf' + ' ' + self._ifc + ' ' + row+ ' ' + subrow+ ' ' + cnt+ ' ' + pos+ ' ' + mask
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def setOtnTxSmonErrorConf(self,mask,val):
        _tempCommand = 'ont_OTN::SetTxSmonErrorConf' + ' ' + self._ifc + ' ' + mask+ ' ' + val
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def setOtnTxPmonErrorConf(self,mask,val):
        _tempCommand = 'ont_OTN::SetTxPmonErrorConf' + ' ' + self._ifc + ' ' + mask+ ' ' + val
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def setOtnTxTcmErrorConf(self,tcm,mask,val):
        _tempCommand = 'ont_OTN::SetTxTcmErrorConf' + ' ' + self._ifc + ' ' + tcm + ' ' + mask+ ' ' + val
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
        
    
    
    
    def getOtnTxErrorInsConf(self):
        _tempCommand = 'ont_OTN::GetTxErrorInsConf' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxErrorInsState(self):
        _tempCommand = 'ont_OTN::GetTxErrorInsConf' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnTxFecErrorConf(self):
        _tempCommand = 'ont_OTN::GetTxFecErrorConf' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def getOtnTxSmonErrorConf(self):
        _tempCommand = 'ont_OTN::GetTxSmonErrorConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getOtnTxPmonErrorConf(self):
        _tempCommand = 'ont_OTN::GetTxPmonErrorConf' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getOtnTxTcmErrorConf(self,tcm):
        _tempCommand = 'ont_OTN::GetTxTcmErrorConf' + ' ' + self._ifc + ' ' + tcm
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
             
        
        
    def setOtnTxPayloadPattern(self,pattern,dw):
        _tempCommand = 'ont_OTN::SetTxPayloadPattern' + ' ' + self._ifc + ' ' + pattern + ' ' + dw
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def setOtnTxPayloadOffset(self,offset):
        _tempCommand = 'ont_OTN::SetTxPayloadOffset' + ' ' + self._ifc + ' ' + offset
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
          
    def setOtnTxPayloadErrorInsConf(self,errorInsertionMode,errorInsertionRate):
        _tempCommand = 'ont_OTN::SetTxPayloadErrorInsConf' + ' ' + self._ifc + ' ' + errorInsertionMode + ' ' + errorInsertionRate
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def setOtnTxPayloadErrorInsState(self,state):
        _tempCommand = 'ont_OTN::SetTxPayloadErrorInsState' + ' ' + self._ifc + ' ' + state
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
        
    
    def getOtnTxPayloadPattern(self):
        _tempCommand = 'ont_OTN::GetTxPayloadPattern' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getOtnTxPayloadOffset(self):
        _tempCommand = 'ont_OTN::GetTxPayloadOffset' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
          
    def getOtnTxPayloadErrorInsConf(self):
        _tempCommand = 'ont_OTN::GetTxPayloadErrorInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def getOtnTxPayloadErrorInsState(self):
        _tempCommand = 'ont_OTN::GetTxPayloadErrorInsState' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def getOtnRxLayerRate(self):
        _tempCommand = 'ont_OTN::GetRxLayerRate' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand) 
        
        
    def getOtnRxOtnSummary(self,currHistMode):
        _tempCommand = 'ont_OTN::GetRxOtnSummary' + ' ' + self._ifc + ' ' + currHistMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
        
    def getOtnRxSummaryState(self,currHistMode):
        _tempCommand = 'ont_OTN::GetRxSummaryState' + ' ' + self._ifc + ' ' + currHistMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
        
    def getOtnRxTcmSummaryState(self,currHistMode):
        _tempCommand = 'ont_OTN::GetRxTcmSummaryState' + ' ' + self._ifc + ' ' + currHistMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
        
    def getOtnRxPayloadState(self,currHistMode):
        _tempCommand = 'ont_OTN::GetRxPayloadState' + ' ' + self._ifc + ' ' + currHistMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getOtnRxPrevLayer(self):
        _tempCommand = 'ont_OTN::GetRxPrevLayer' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    

    #--------------- OTL Layer commands ---------------------------------------------------
    def setOtlLaneOtu4AlarmInsertCfg(self,alarmType):
        _tempCommand = 'ont_OTL::SetOtlLaneAlarmInsConf' + ' ' + self._ifc + ' ' + alarmType 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
       
    def setOtlLaneOtu4AlarmInsertRange(self,alarmRange, alarmSingle='0'):
        _tempCommand = 'ont_OTL::SetOtlLaneAlarmInsRange' + ' ' + self._ifc + ' ' + alarmRange + ' ' + alarmSingle
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  

    def setOtlLaneOtu4AlarmInsertState(self,alarmState):
        _tempCommand = 'ont_OTL::SetOtlLaneAlarmInsState' + ' ' + self._ifc + ' ' + alarmState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   

    #--------------------SDH LAYER ------------------------
            
    def getRxSummaryState(self,currHistMode):
        _tempCommand = 'ont_SDH::GetRxSummaryState' + ' ' + self._ifc + ' ' + currHistMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)    
        
    
    def isCurrRxErrorAlarm(self):
        _tempResult = self.getRxSummaryState('CST')
        if bUseAtlasLog:
            print(_tempResult)
        else:
            print(_tempResult)
        match1 = re.search('{valid (.*?)}',_tempResult)
        match2 = re.search('{errorAlarmSum (.*?)}',_tempResult)
        
        if match1 == None:
            if bUseAtlasLog:
                print("Can't retrieve current error or alarm,please check your set up")
            else:
                print("Can't retrieve current error or alarm,please check your set up")
            raise Exception('invalid error alarms retrieve')
        
        
        if match2 == None:
            if bUseAtlasLog:
                print("Can't retrieve current error or alarm,please check your set up")
            else:
                print("Can't retrieve current error or alarm,please check your set up")
            raise Exception('invalid error alarms retrieve')
            
        
        if (int(match1.group(1))) == 0:
            if bUseAtlasLog:
                print("Can't retrieve current error or alarm,please check your set up")
            else:
                print("Can't retrieve current error or alarm,please check your set up")
            raise Exception('invalid error alarms retrieve')
            
        if (int(match2.group(1))) == 1:
            if bUseAtlasLog:
                print("there're alarms retrieved")
            else:
                print("there're alarms retrieved")
            return True
         
        if (int(match2.group(1))) == 65536:
            if bUseAtlasLog:
                print("there're errors retrieved")
            else:
                print("there're errors retrieved")
            return True
        
            
        if (int(match2.group(1))) == 0:
            if bUseAtlasLog:
                print("there're no alarms retrieved")
            else:
                print("there're no alarms retrieved")
            return False
         
        if (int(match2.group(1))) == 16:
            if bUseAtlasLog:
                print("there're no errors retrieved")
            else:
                print("there're no errors retrieved")
            return True      
        
        
        return False
        
                  
    #--------------------PCS LAYER ------------------------
    def setPcsRsAlarmInsertCfg(self,alarmType,alarmMode,burstAct,burstInact):
        _tempCommand = 'ont_PCS::SetRsAlarmInsConf' + ' ' + self._ifc + ' ' + alarmType + ' ' + alarmMode + ' ' + burstAct + ' ' + burstInact
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPcsFcAlarmInsertCfg(self,alarmType,alarmMode):
        _tempCommand = 'ont_PCS::SetFcAlarmInsConf' + ' ' + self._ifc + ' ' + alarmType + ' ' + alarmMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
       
    def getPcsRsAlarmInsertCfg(self):
        _tempCommand = 'ont_PCS::GetRsAlarmInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
 
    def setPcsRsAlarmInsertState(self,alarmState):
        _tempCommand = 'ont_PCS::SetRsAlarmInsState' + ' ' + self._ifc + ' ' + alarmState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
        
    def setPcsFcAlarmInsertState(self,alarmState):
        _tempCommand = 'ont_PCS::SetFcAlarmInsState' + ' ' + self._ifc + ' ' + alarmState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
    
    def setPcsAlarmInsertCfg(self,alarmType,alarmMode,burstAct,burstInact):
        _tempCommand = 'ont_PCS::SetAlarmInsConf' + ' ' + self._ifc + ' ' + alarmType + ' ' + alarmMode + ' ' + burstAct + ' ' + burstInact
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
       
    def setPcsAlarmInsertState(self,alarmState):
        _tempCommand = 'ont_PCS::SetAlarmInsState' + ' ' + self._ifc + ' ' + alarmState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
    
    def setPcsLane100GeAlarmInsertCfg(self,alarmType):
        _tempCommand = 'ont_PCS::SetPcsLaneAlarmInsConf' + ' ' + self._ifc + ' ' + alarmType 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setPcsLane100GeErrorInsertCfg(self, errorInsertionType, errorInsertionMode="BURST_CONT",
            burstActive=1, burstInactive=1, errorInsertionRate="1.0E-4", syncHeader=0, blockAlignMarker="170,119,167",
            bip8ErrorMask=255):
        _tempCommand = 'ont_PCS::SetPcsLaneErrorInsConf' + ' ' + self._ifc + ' ' + str(errorInsertionType) + ' ' + str(errorInsertionMode) + ' ' + str(burstActive) + ' ' + str(burstInactive) + ' ' + str(errorInsertionRate) + ' ' + str(syncHeader) + ' ' + str(blockAlignMarker) + ' ' + str(bip8ErrorMask)
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getPcsLane100GeAlarmInsertCfg(self):
        _tempCommand = 'ont_PCS::GetPcsLaneAlarmInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
       
    def setPcsLane100GeAlarmInsertRange(self,alarmRange, alarmSingle):
        _tempCommand = 'ont_PCS::SetPcsLaneAlarmInsRange' + ' ' + self._ifc + ' ' + alarmRange + ' ' + alarmSingle
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)  
        
    def setPcsLane100GeErrorInsertRange(self,errorRange, errorSingle):
        _tempCommand = 'ont_PCS::SetPcsLaneErrorInsRange' + ' ' + self._ifc + ' ' + errorRange + ' ' + errorSingle
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def setPcsLane100GeAlarmInsertState(self,alarmState):
        _tempCommand = 'ont_PCS::SetPcsLaneAlarmInsState' + ' ' + self._ifc + ' ' + alarmState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)      
    
    def setPcsLane100GeErrorInsertState(self,errorState):
        _tempCommand = 'ont_PCS::SetPcsLaneErrorInsState' + ' ' + self._ifc + ' ' + errorState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   
    
    def getRxRsResults(self):
        _tempCommand = 'ont_PCS::GetRxRsResults' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def setTx1027BAlarmInsertCfg(self,alarmType,alarmMode):
        _tempCommand = 'ont_PCS::SetTx1027BAlarmInsConf' + ' ' + self._ifc + ' ' + alarmType + ' ' + alarmMode
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setTx1027BAlarmInsertState(self,alarmState):
        _tempCommand = 'ont_PCS::SetTx1027BAlarmInsState' + ' ' + self._ifc + ' ' + alarmState
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def getTx1027BAlarmInsertCfg(self):
        _tempCommand = 'ont_PCS::GetTx1027BAlarmInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getTxTransErrorInsConf(self):
        _tempCommand = 'ont_PCS::GetTxTransErrorInsConf' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def getTx1027BAlarmInsertState(self):
        _tempCommand = 'ont_PCS::GetTx1027BAlarmInsState' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def getTxTransErrorInsState(self):
        _tempCommand = 'ont_PCS::GetTxTransErrorInsState' + ' ' + self._ifc
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def checkRsAlarms(self,rsAlarm):
        _tempResult = self.getRxRsResults()
        active = False;

        currAlarm = re.search('currentAlarmString (.*?)}',_tempResult)
        lnkdwn = re.search('LNKDWN',currAlarm.group(0))
        if lnkdwn:
            if bUseAtlasLog:
                print("Link Down is Active")
            else:
                print("Link Down is Active")
            if rsAlarm == 'ld':
                active = True
        locf = re.search('LOCF',currAlarm.group(0))
        if locf:
            if bUseAtlasLog:
                print("Local Fault is Active")
            else:
                print("Local Fault is Active")
            if rsAlarm == 'lf':
                active = True
        remf = re.search('REMF',currAlarm.group(0))
        if remf:
            if bUseAtlasLog:
                print("Remote Fault is Active")
            else:
                print("Remote Fault is Active")
            if rsAlarm == 'rf':
                active = True
        return active 

    def isLinkDownActive(self):
        _tempResult = self.getRxRsResults()

        currAlarm = re.search('currentAlarmString (.*?)}',_tempResult)
        lnkdwn = re.search('LNKDWN',currAlarm.group(0))
        if lnkdwn:
            return True
        else:
            return False

    def isLocalFaultActive(self):
        _tempResult = self.getRxRsResults()

        currAlarm = re.search('currentAlarmString (.*?)}',_tempResult)
        locf = re.search('LOCF',currAlarm.group(0))
        if locf:
            return True
        else:
            return False

    def isRemoteFaultActive(self):
        _tempResult = self.getRxRsResults()

        currAlarm = re.search('currentAlarmString (.*?)}',_tempResult)
        remf = re.search('REMF',currAlarm.group(0))
        if remf:
            return True
        else:
            return False

    def getRxResults(self):
        _tempCommand = 'ont_PHYS1XG::GetRxResults' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)   

    def getRxSectionLineResults(self):
        if bUseAtlasLog:
            print('calling getRxSectionLineResults')
        else:
            print('calling getRxSectionLineResults')
        _tempCommand = 'ont_SONET::GetRxSectionLineResults' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def isAisActive(self):
        _tempResult = self.getRxSectionLineResults()
        currAlarms = re.search('currentAlarmString (.*?)}',_tempResult)
        # Check if there is an AIS-L or AIS-P alarm currently active 
        ais = re.search('AIS',currAlarms.group(0))
        if ais:
            return True
        else:
            return False

    def areSonetAlarmsActive(self):
        _tempResult = self.getRxSectionLineResults()

        currAlarms = re.search('(?<=currentAlarms )\d+', _tempResult)
        #currAlarms = re.search('(?<=\: )\w+', data)
        # Check if there is an AIS-L or AIS-P alarm currently active 
        if bUseAtlasLog:
            print('Result:' + str(currAlarms.group(0)))
        else:
            print('Result:' + str(currAlarms.group(0)))
        if (int(currAlarms.group(0)) == 0):
            if bUseAtlasLog:
                print('False')
            else:
                print('False')
            return False
        else:
            if bUseAtlasLog:
                print('True')
            else:
                print('True')
            return True

    def getRxSectionLineResults(self):
        _tempCommand = 'ont_SONET::GetRxSectionLineResults' + ' ' + self._ifc 
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def setMacPauseSendConf(self, mode, frames):
        _tempCommand = 'ont_MAC::SetTxPauseSendConf' + ' ' + self._ifc + ' 20 ' + mode + ' ' + frames
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)
        
    def setMacPauseSendState(self, state):
        _tempCommand = 'ont_MAC::SetTxPauseSendState' + ' ' + self._ifc + ' ' + state
        if bUseAtlasLog:
            print(_tempCommand)
        else:
            print(_tempCommand)
        return tcl.eval(_tempCommand)

    def injectFC2Error(self, nCount):
        self.__login("SCPI")
        self.__viaviSession.send(":SOUR:DATA:TEL:FC2:ERR:MODE BURST_ONCE")
        self.__viaviSession.send(":SOUR:DATA:TEL:FC2:ERR:BURS:ACT %s"%str(nCount))
        self.__viaviSession.send(":SOUR:DATA:TEL:FC2:ERR:INS ON")
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
    def getFC2TrafficStatistics(self):
        self.__login("SCPI")
        dictStatistics = dict()
        dictStatistics["TX_PACKAGE_TOTAL"] = int(self.__viaviSession.send(":FC2:TX:COUN:FRAM?").split("\n")[0].split(",")[-1].strip())
        dictStatistics["RX_PACKAGE_TOTAL"] = int(self.__viaviSession.send(":FC2:COUN:FRAM?").split("\n")[0].split(",")[-1].strip())
        dictStatistics["TX_BYTE_TOTAL"] = int(self.__viaviSession.send(":FC2:TX:COUN:BYTE?").split("\n")[0].split(",")[-1].strip())
        dictStatistics["RX_BYTE_TOTAL"] = int(self.__viaviSession.send(":FC2:COUN:BYTE?").split("\n")[0].split(",")[-1].strip())
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        return dictStatistics
        
        
    def setFcTrafficGenerator(self, strStatus):
        self.__login("SCPI")
        self.__viaviSession.send(":SOUR:DATA:TEL:FC2:TRAF:STAT %s"%strStatus)
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setFcTxBitRate(self, strBitRate):
        '''
        param type strBitRate:string
        param value strBitRate: FC_FULL | FC_DOUB | FC4G | FC8G | FC10G
        '''
        self.__login("SCPI")
        self.__viaviSession.send(":SOUR:DATA:TEL:PHYS:LINE:RATE %s"%strBitRate)
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setFcRxBitRate(self, strBitRate):
        '''
        param type strBitRate:string
        param value strBitRate: FC_FULL | FC_DOUB | FC4G | FC8G | FC10G
        '''
        self.__login("SCPI")
        self.__viaviSession.send(":SENS:DATA:TEL:PHYS:LINE:RATE %s"%strBitRate)
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setOtnTxFecStatus(self, strStatus):
        '''
        param type strBitRate:string
        param value strBitRate: OFF | ON
        '''
        self.__login("SCPI")
        self.__viaviSession.send(":SOUR:DATA:TEL:OTN:OTU:FEC:GEN %s"%strStatus)
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setOtnRxFecStatus(self, strStatus):
        '''
        param type strBitRate:string
        param value strBitRate: OFF | ON
        '''
        self.__login("SCPI")
        self.__viaviSession.send(":SENS:DATA:TEL:OTN:OTU:FEC:EVAL %s"%strStatus)
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
    def setOtnFecCorrectionStatus(self, strStatus):
        '''
        param type strBitRate:string
        param value strBitRate: OFF | ON
        '''
        self.__login("SCPI")
        self.__viaviSession.send(":SENS:DATA:TEL:OTN:OTU:FEC:CORR %s"%strStatus)
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setPcsLosyncAlarm(self, strStatus):
        '''
        param type strBitRate:string
        param value strBitRate: FC_FULL | FC_DOUB | FC4G | FC8G | FC10G
        '''
        if strStatus.upper() not in ["ON", "OFF"]:
            raise Exception('invalid error status')
            
        self.__login("SCPI")
        if "ON" == strStatus.upper():
            self.__viaviSession.send(":SOUR:DATA:TEL:PCS:ALAR:TYPE LOS")
            self.__viaviSession.send(":SOUR:DATA:TEL:PCS:ALAR:MODE CONT")
            self.__viaviSession.send(":SOUR:DATA:TEL:PCS:ALAR:INS ON")
        elif "OFF" == strStatus.upper():
            self.__viaviSession.send(":SOUR:DATA:TEL:PCS:ALAR:INS OFF")
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setPcsFcForceLinkActive(self, strProtocol, strStatus):
        '''
        param type strBitRate:string
        param value strBitRate: FC_FULL | FC_DOUB | FC4G | FC8G | FC10G
        '''
        if strStatus.upper() not in ["ON", "OFF"]:
            raise Exception('invalid status')
            
        if strProtocol not in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            raise Exception('invalid protocol')
            
        self.__login("SCPI")

        if "PHYS_PCS1G_FC2" == strProtocol:
            self.__viaviSession.send(":SOUR:DATA:TEL:PCS:FC:LNK:FORC:ACT %s"%strStatus)
        elif "PHYS_PCS_FC2" == strProtocol:
            self.__viaviSession.send(":SOUR:DATA:TEL:PCS:XGFC:LNK:FORC:ACT %s"%strStatus)
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
    def setPcsFcForceLinkFaultIgnore(self, strProtocol, strStatus):
        '''
        param type strBitRate:string
        param value strBitRate: FC_FULL | FC_DOUB | FC4G | FC8G | FC10G
        '''
        if strStatus.upper() not in ["ON", "OFF"]:
            raise Exception('invalid status')
        if strProtocol not in ["PHYS_PCS1G_FC2", "PHYS_PCS_FC2"]:
            raise Exception('invalid protocol')
            
        self.__login("SCPI")

        if "PHYS_PCS1G_FC2" == strProtocol:
            self.__viaviSession.send(":SENS:DATA:TEL:PCS:FC:LNK:FAUL:IGN %s"%strStatus)
        elif "PHYS_PCS_FC2" == strProtocol:
            self.__viaviSession.send(":SENS:DATA:TEL:PCS:XGFC:LNK:FAUL:IGN %s"%strStatus)
            
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setPhysCFPMDIOStartAddr(self, strStartAddr):
        '''
        param type strStartAddr:string
        param value strStartAddr: MDIO dump start address #h0000 ... #hFF00 
        '''

            
        self.__login("SCPI")
        
        print(self.__viaviSession.send(":SOUR:DATA:TEL:PHYS:CFP:MDIO:RD:ADDR:STRT?"))
        
        self.__viaviSession.send(":SOUR:DATA:TEL:PHYS:CFP:MDIO:RD:ADDR:STRT #h%s"%strStartAddr)

            
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        


        
    def setPhysCFPMDIOCHGridSpacing(self, strSpacing):
        '''
        param type strSpacing:string
        param value strSpacing: Set the TX grid spacing of the transponder (Bits 13 ... 15 of MDIO register 0xB400)
                "B000", "B001", "B010", "B011", "B100", "B101"
        '''

        if strSpacing not in ["100 GHz", "50 GHz", "33 GHz", "25 GHz", "12.5 GHz", "6.25 GHz",
                            "B000", "B001", "B010", "B011", "B100", "B101"]:
            raise Exception('invalid grid spacing')
        
        if "100 GHz" == strSpacing:
            strSpacing = "B000"
        elif "50 GHz" == strSpacing:
            strSpacing = "B001"
        elif "33 GHz" == strSpacing:
            strSpacing = "B010"
        elif "25 GHz" == strSpacing:
            strSpacing = "B011"
        elif "12.5 GHz" == strSpacing:
            strSpacing = "B100"
        elif "6.25 GHz" == strSpacing:
            strSpacing = "B101"
            
        self.__login("SCPI")
        
        print(self.__viaviSession.send(":SOUR:DATA:TEL:PHYS:CFP:MDIO:CH:CTRL:GRID?"))
        
        self.__viaviSession.send(":SOUR:DATA:TEL:PHYS:CFP:MDIO:CH:CTRL:GRID %s"%strSpacing)

            
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        

    def setPhysCFPMDIOCHNo(self, num):
        '''
        param type strSpacing:string
        param value strSpacing: Set the TX grid spacing of the transponder (Bits 13 ... 15 of MDIO register 0xB400)
                "B000", "B001", "B010", "B011", "B100", "B101"
        '''

        if num not in range(1, 1024):
            raise Exception('invalid channel number')
                   
        self.__login("SCPI")
        
        print(self.__viaviSession.send(":SOUR:DATA:TEL:PHYS:CFP:MDIO:CH:CTRL:CHNB?"))
        
        self.__viaviSession.send(":SOUR:DATA:TEL:PHYS:CFP:MDIO:CH:CTRL:CHNB %d"%num)

            
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")
        
        
    def setPhys1xxgCFP2RxBitrate(self, bitrate):
        if bitrate not in ["ETH_40G", "ETH_100G"]:
            raise Exception('invalid bitrate')
        self.__login("SCPI")
        # print(self.__viaviSession.send(":SENS:DATA:TEL:PHYS:LINE:RATE?").encode(encoding='utf-8'))
        print(self.__viaviSession.send(":SENS:DATA:TEL:PHYS:LINE:RATE?"))
        # self.__viaviSession.send((":SENS:DATA:TEL:PHYS:LINE:RATE %s"%bitrate).encode(encoding='utf-8'))
        self.__viaviSession.send(":SENS:DATA:TEL:PHYS:LINE:RATE %s"%bitrate)

            
        self.__login("TCL_LAYERED_APPLICATION_DRIVER")