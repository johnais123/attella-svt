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
Exfo ExfoModule.

@date: Created on Sept 21 2014
@author: vzheng
'''

#--------------------------------------------------------------------------Imports
# import pexpect
import re
import time

import socket
import select

#-----------------------------------------------------------------Class Exfo
class Exfo(object):
    '''
    Creates an Exfo Session to a target.  Use this Session type to talk to the
    Exfo test set CT platform for VOA/optical switch/power meter.
    '''
    _socket = None
    _chunk = 128 # buf size
    _vocal = False
    _timeout = 0.150 # Float timeout in secs

    def __init__(self, host, port=5024, timeout=None, vocal=True):
        '''
        The host and port are used to create a exfo session.

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
        open the exfo session
        '''
        try:
            self._socket.connect((self._host, self._port))
            self._connectConfirmed()
        except socket.error as e:
            if self._vocal: print('SCPI>> connect(%s:%d) failed: %s'%(self._host, self._port, e))
            else: raise e


    def _connectConfirmed(self):
        '''
        get the output from the exfo session
        (need to add timeout check later)
        @rtype: boolean
        @return: True when exfo has the right response,otherwise false
        '''
        if self._socket is None: raise IOError('disconnected')
        buf = bytearray()
        result = False
        data = True
        while data:
            r,w,e = select.select([self._socket], [], [self._socket], self._timeout)
            if r: # socket readable
                data = self._socket.recv(self._chunk)
                if data:
                    buf += data
                    print(buf)
                    print(type(buf))
                    
                    if (buf.decode('utf-8').find("Connected to Toolbox/IQS Manager") != -1):
                        result = True
                        data = False
                else: # Socket readable but there is no data
                    data = True
            else:
                data = True
        return result

    def _write(self, cmd):
        '''
        write command to the exfo session
        @type cmd:  string
        @param cmd: SCPI command to the exfo
        @rtype: string
        @return: the command to the exfo
        '''
        if self._socket is None: raise IOError('disconnected')
        
        # for i in xrange(0, len(cmd), self._chunk):
        for i in range(0, len(cmd), self._chunk):
            if (i+self._chunk) > len(cmd): idx = slice(i, len(cmd))
            else: idx = slice(i, i+self._chunk)
            self._socket.sendall(cmd[idx].encode(encoding='utf-8'))
        return cmd
        
    def write(self, cmd):
        '''
        write command to the exfo session using _write and return the command
        @type cmd:  string
        @param cmd: SCPI command to the exfo
        @rtype: string
        @return: the command to the exfo
        '''
        try:
            return self._write(cmd + '\r\n')
        except IOError as e:
            if self._vocal: print('SCPI>> write({:s}) failed: {:s}'.format(cmd.strip(), e))
            else: raise e

    def _read(self):
        '''
        get the output from the exfo session

        @rtype: string
        @return: the output from the exfo
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
                    if (buf.decode('utf-8').find("\r\nREADY>") != -1):
                        data = False
                else: # Socket readable but there is no data
                    data = True

            else:
                data = False
        return buf

    def send(self, cmd):
        '''
        send command to the exfo and get the output from exfo,normall this is the method to send the command and get the output
        @type cmd:  string
        @param cmd: SCPI command to the exfo
        @rtype: string
        @return: the output from the exfo
        '''
        self.output = ""
        try:
            cmd = self._write(cmd + '\r\n')
            ans = self._read()
            i = 0
            for i in range(5):
                if ans == '':       #at first time,self._read() will return null,so try again
                    time.sleep(5)
                    ans = self._read()
                else:
                    break
            if self._vocal:
                print("Exfo command:      %s"%cmd.strip())
            if i == 4:
                cmd = self._write('SYST:ERR?\n')
                err = self._read()

                raise Exception('Exfo error happened in retrieving output')
            else:
                self.output = ans.decode("utf-8").strip().replace("\r\nREADY>", "")
                print("Exfo output:   " + self.output)
                print("Exfo output:   %s"%self.output)
        except IOError as e:
            if self._vocal:
                print('SCPI>> ask(%s) failed: %s'%(cmd.strip(), e))
            else:
                raise e
        return self.output


    def close(self):
        ''' close the exfo session
        '''
        self.__del__()

    def __del__(self):
        ''' close the exfo session
        '''
        if self._socket is not None: self._socket.close()
        self._socket = None

    def isOpen(self):
        ''' to check if exfo session is opened
        '''
        return not self._socket == None

    def takeModule(self,slot):
        ''' use this command to get the wanted module
        @type slot: string
        @param slot: exfo module id
        @rtype: ExfoModule
        @return: instance of ExfoModule

        '''
        if self.isOpen():
            self.send('CONNECT LINS'+str(slot))

            matchobj = re.search(r'.*connected to Module at',str(self.output))

            if matchobj:
                return ExfoModule(self,slot)
            else:

                raise Exception('Can not connect to slot' + str(slot) + ' ' + self.output)
        else:
            raise Exception('EXFO slot is not connected')


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
            raise Exception('EXFO slot is not connected')

    def isModuleExisted(self,slot):
        if self.isOpen():
            self.send("INST:CAT:FULL?")
            if ',%s'%(slot) in str(self.output):
                print("successfully to find specificated module on EXFO")
            else:
                raise Exception('Can not find specificated module on EXFO')
        else:
            raise Exception('EXFO slot is not connected')

    def showAllModules(self):
        pass

#-----------------------------------------------------------------Class ExfoModule
class ExfoModule(object):
    '''
    Creates an Exfo Module 88200NGE. Use this module to set SDH/SONET/OTU2/OTU2E interface.

    '''

    #-------------------------------------------------------------------- __init__
    #def __init__(self, target, name,
    def __init__(self, session,slot):
        '''The ExfoModule is the main object to operate in testing
        @type session: instance of Exfo class
        @param session: the host exfo session of this module
        @type slot: string
        @param slot: slot id(usually 1,3,5,7,9)

        '''


        assert(isinstance (session, Exfo)), "Please use an Exfo instance to be the first parameter"
        self.shelf = ""
        self._slot = slot
        self._session = session
        self.output = ''


    def disconnect(self):
        ''' disconnect the module so others can use this module
        @rtype: Boolean
        @return: True|False

        '''
        self._session.send('CLOSE LINS'+str(self._slot))
        matchobj = re.search(r'.*is closed by this client',str(self._session.output))
        if matchobj:
            print("You have disconnected to the exfo module: " + str(self._slot))
            return True
        else:
            return False

    def connect(self):
        ''' connect the module so the script can run against this module
        @rtype: Boolean
        @return: True|False
        '''
        self._session.send('CONNECT LINS' +str(self._slot))
        # matchobj = re.search(r'(.*connected to Module at|.* is already connected to other session)' ,str(self._session.output))
        if "connected to Module at LINS%s now"%self._slot in str(self._session.output):
            print("You have connected to the exfo module: " + str(self._slot))
            return True

        elif "LINS%s is already connected to session"%self._slot in str(self._session.output):
            self._session.send('KILL LINS' +str(self._slot))
            time.sleep(10)
            self._session.send('CONNECT LINS' +str(self._slot))
            if "LINS%s is terminated by this client"%self._slot in str(self._session.output):
                print("By force successful to take up the exfo module: " + str(self._slot))

                return True
            else:
                print("By force fail to take up the exfo module: " + str(self._slot))
                return False
        else:
            print("You can not connect to the exfo module: " + str(self._slot))
            return False

    def isTesting(self):
        ''' verify if the testing is running currently
        @rtype: Boolean
        @return: True|False

        '''
        command = "LINS" + str(self._slot) + ":SOURCE:DATA:TELECOM:TEST?"
        self._session.send(command)
        output = self._session.output.strip()
        print("the out put is " + output)
        if "0" == output[-1]:

            return False
        elif "1"== output[-1]:

            return True
        else:
            raise Exception("command failed" + str(self._session.output))

    def clear(self):
        ''' to clearn the current running testing,have to set up again in order to do some testing after this command
        @rtype: Boolean
        @return: True|False

        '''
        command = "LINS"+ str(self._slot) + ":SOURce:DATA:TELecom:CLEar"
        self._session.send(command)

        output = self._session.output.strip()

        matchobj = re.search(r'.*Previous test cleared successfully' ,output)
        if matchobj:
            print("testing clear successfully on module: " + " " + str(self._slot)+self._session.output)

            return True
        else:
            print("testing clear not successfully on exfo module: "+ str(self._slot) + self._session.output)

            return False



    def setMode(self, mode="NORMAL"):
        ''' set moudle mode to NORMAL|NI/CSU,normally use NORMAL
        @type mode: string
        @param mode: NORMAL|NI/CSU
        @rtype: Boolean
        @return: True|False

        '''
        mode = str(mode)
        assert (mode == "NORMAL"),"The mode should be NORMAL only"
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:MODE " + str(mode)
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set mode successfully on module: " + str(self._slot))
            return True
        else:
            print("set mode not successfully on exfo module: " + str(self._slot) + output)
            return False



    def getMode(self):
        ''' retrieve current set up mode
        @rtype: String
        @return: NORMAL|EMULATION

        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:MODE?"
        self._session.send(command)
        output = self._session.output.strip()

        if "NORMAL" == output:
            print("get mode successfully on module: " + str(self._slot))
            return "NORMAL"
        elif "2" == output:
            print("get mode successfully on module: " + str(self._slot))
            return "EMULATION"
        else:
            raise Exception("getting mode failed on module:" + str(self._slot)+ output)



    def setConnector(self, connector):
        ''' set connector to OPTICAL|BNC|BANTAM|RJ48C
        @type connector:string
        @param connector: RJ45|XFP|SFPPLUS|QSFPP2
        @rtype: Boolean
        @return: True|False

        '''
        connector = str(connector)
        assert (connector in ["RJ45","XFP","SFPPLUS","QSFPP2"]),"The connector type should be one of RJ45|XFP|SFPPLUS|QSFPP2"
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:PORT:TRANsceiver " + str(connector)
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set connector successfully on exfo module: " + str(self._slot))
            return True
        else:
            print("set connector not successfully on exfo module: "+ str(self._slot) + output)
            return False

    def getConnector(self):
        ''' retrieve current connector type
        @rtype: string
        @return: RJ45|XFP|SFPPLUS|NONE

        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:PORT:TRANsceiver?"
        self._session.send(command)
        output = self._session.output.strip()

        if (output in ["RJ45","XFP","SFPPLUS","NONE"]):
            print("get connector successfully on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("getting connector failed on module:" + str(self._slot) + output)

    def setApplication(self,application):
        ''' set module interface to specific protocol
        @type protocol: string
        @param protocol: OTNBER|SONETSDHBERT|EBERT|FCBERT
        @rtype: Boolean
        @return: True|False
        '''
        assert (application in ["OTNBERT","SONETSDHBERT","EBERT","FCBERT"]),"The interface protocol should be one of OTNBER|SONETSDHBERT|EBERT|FCBERT"
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:TEST:TYPE " + application
        self._session.send(command)
        time.sleep(10)
        output = self._session.output
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("choose application successfully on exfo module: " + str(self._slot) +' '+application)
            return True
        else:
            print("Failed to set interface protocol on exfo module: " + str(self._slot) +' '+application)
            return False

    def setIfProtocol(self, protocol):
        ''' set module interface to specific protocol
        @type protocol: string
        @param protocol: OC3|OC12|OC48|OC192|STM1|STM4|STM16|STM64|OTU2|OTU2E|10GELAN|LANE4X10|LANE4X25|8X|10X
        @rtype: Boolean
        @return: True|False
        '''
        protocol = str(protocol)
        assert (protocol in ["OC3","OC12","OC48","OC192","STM1","STM4","STM16","STM64","OTU2","OTU2E","10GELAN","LANE4X10", "LANE4X25","8X","10X"]),"The interface protocol should be one of OC3|OC12|OC48|OC192|STM1|STM4|STM16|STM64|OTU2|OTU2E|10GELAN|8X|10X"
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ITYPe " + str(protocol)
        self._session.send(command)
        output = self._session.output
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set interface protocol successfully on exfo module: " + str(self._slot))
            return True
        else:
            print("Failed to set interface protocol on exfo module: " + str(self._slot) +' '+protocol)
            return False

    def getIfProtocol(self):
        ''' get module interface protocol
        @rtype: string
        @return: OC3|OC12|OC48|OC192|STM1|STM4|STM16|STM64|OTU2|OTU2E|10GELAN|LANE4X10|LANE4X25
        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ITYPe?"
        self._session.send(command)
        output = self._session.output.strip()

        if (output in["NONE","OC3","OC12","OC48","OC192","STM1","STM4","STM16","STM64","OTU2","OTU2E","10GELAN","LANE4X10","LANE4X25"]):
            print("get interface protocol successfully on module: "  + str(self._slot))
            return output
        else:
            raise Exception("getting interface protocol failed on module:" + str(self._slot) + output)


    def setIfHop(self, typ):
        ''' set module interface hop type
        @type typ: string
        @param typ: STS1|STS3C|STS6C|STS9C|STS12C|STS24C|STS48C|STS96C|STS192C|AU3|AU4|AU42C|AU43C|AU44C|AU48C|AU416C|AU432C|AU464C
        @rtype: Boolean
        @return: True|False

        '''
        typ = str(typ)
        assert (typ in ["STS1","STS3C","STS6C","STS9C","STS12C","STS24C","STS48C","STS96C","STS192C","AU3","AU4","AU42C","AU43C","AU44C","AU48C","AU416C","AU432C","AU464C"]),"The interface protocol should be one of STS1|STS3C|STS6C|STS9C|STS12C|STS24C|STS48C|STS96C|STS192C|AU3|AU4|AU42C|AU43C|AU44C|AU48C|AU416C|AU432C|AU464C"
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:HOP:TYPE " + str(typ)
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set interface hop successfully on exfo module: " + str(self._slot))
            return True
        else:
            print("set interface hop not successfully on exfo module: "+ str(self._slot) + output)
            return False

    def getIfHop(self):
        ''' get module interface hop type
        @rtype : string
        @return: STS1|STS3C|STS6C|STS9C|STS12C|STS24C|STS48C|STS96C|STS192C|AU3|AU4|AU42C|AU43C|AU44C|AU48C|AU416C|AU432C|AU464C

        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:HOP:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()

        if (output in["STS1","STS3C","STS6C","STS9C","STS12C","STS24C","STS48C","STS96C","STS192C","AU3","AU4","AU42C","AU43C","AU44C","AU48C","AU416C","AU432C","AU464C"]):
            print("get interface hop successfully on module: " + str(self._slot))
            return output
        else:
            raise Exception("getting interface hop failed on module:" + str(self._slot) + output)


    def setIfHopPosition(self,position):
        ''' set module interface hop position
        @type position: string
        @param position: 1-192
        @rtype: Boolean
        @return: True|False

        '''
        position = str(position)
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:POS HOPP " + position
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set hop position = " + position + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return True
        else:
            print("set hop position = " + position + " not successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return False



    def setIfLop(self, typ):
        ''' set module interface lop type
        @type typ: string
        @param typ:  VT15|VT2|VT6|TU11|TU12|TU2|TU3
        @rtype: Boolean
        @return: True|False

        '''
        typ = str(typ)
        assert (typ in ["VT15","VT2","VT6","TU11","TU12","TU2","TU3"]),"The interface protocol should be one of VT15|VT2|VT6|TU11|TU12|TU2|TU3"
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:LOP:TYPE " + str(typ)
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set interface lop successfully on exfo module: " + str(self.shelf) + " " + str(self._slot))
            return True
        else:
            print("set interface lop not successfully on exfo module: "+ str(self.shelf) + " " + str(self._slot) + output)
            return False

    def getIfLop(self):
        ''' get module interface lop type
        @rtype : string
        @return:  VT15|VT2|VT6|TU11|TU12|TU2|TU3

        '''
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:LOP:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()

        if (output in ["VT15","VT2","VT6","TU11","TU12","TU2","TU3"]):
            print("get interface lop successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return output
        else:
            raise Exception("getting interface lop failed on module:" + str(self.shelf) + " " + str(self._slot) + output)



    def setOdu(self, protocol):
        ''' set module interface odu type
        @type protocol: string
        @param protocol:  O1OC48|O1STM16|O2OC192|O2STM64|ODU1|ODU2|O2O1OC48|O2O1STM16|O2ODU1
        @rtype: Boolean
        @return: True|False

        '''
        protocol = str(protocol)
        assert (protocol in ["O1OC48","O1STM16","O2OC192","O2STM64","ODU1","ODU2","O2O1OC48","O2O1STM16","O2ODU1"]),"The interface protocol should be one of O1OC48|O1STM16|O2OC192|O2STM64|ODU1|ODU2|O2O1OC48|O2O1STM16|O2ODU1"
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:ODU:TYPE " + str(protocol)
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set interface odu successfully on exfo module: " + str(self.shelf) + " " + str(self._slot))
            return True
        else:
            print("set interface odu not successfully on exfo module: "+ str(self.shelf) + " " + str(self._slot) + output)
            return False

    def getOdu(self):
        ''' get module interface odu type
        @rtype: string
        @return:  O1OC48|O1STM16|O2OC192|O2STM64|ODU1|ODU2|O2O1OC48|O2O1STM16|O2ODU1


        '''
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:odu:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()

        if (output in ["O1OC48","O1STM16","O2OC192","O2STM64","ODU1","ODU2","O2O1OC48","O2O1STM16","O2ODU1"]):
            print("get interface odu successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return output
        else:
            raise Exception("getting interface odu failed on module:" + str(self.shelf) + " " + str(self._slot) + output)

    def setOtu2fec(self,clientFec_type):
        ''' This command enables/disables the Forward Error Correction (FEC) for the Transmitter (TX)mode.
        @type flag: string
        @para flag: ON|OFF
        '''
        if clientFec_type == "g-fec" or clientFec_type == "rsfec":
            flag = "ON"
        elif clientFec_type == "no-fec" or clientFec_type == "off":
            flag = "OFF"
        else:
            raise Exception("The clientFec_type should be one of g-fec|rsfec|no-fec|off")
            return False
        # command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:FEC " + flag
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:OTN:FEC " + flag
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set otu2 fec " + flag + " successfully on module: " + str(self._slot))
            return True
        else:
            print("fail to set otu2 fec " + flag + " on module: " + str(self._slot) + output)
            return False

    def setOtnfec(self,clientFec_type):
        ''' This command enables/disables the Forward Error Correction (FEC) for the Transmitter (TX)mode.
        @type flag: string
        @para flag: ON|OFF
        '''
        if clientFec_type == "g-fec":
            flag = "ON"
        elif clientFec_type == "no-fec":
            flag = "OFF"
        else:
            raise Exception("The clientFec_type should be one of g-fec|no-fec")
            return False
        # command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:FEC " + flag
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:OTN:FEC " + flag
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set otn fec " + flag + " successfully on module: " + str(self._slot))
            return True
        else:
            print("fail to set otn fec " + flag + " on module: " + str(self._slot) + output)
            return False

    def setLaserState(self, mode="ON"):
        ''' set laser to ON|OFF
        @type mode: string
        @param mode:  ON|OFF
        @rtype: Boolean
        @return: True|False
        '''
        mode = str(mode)
        assert (mode in ["ON","OFF"]),"The mode should be ON|OFF only"
        command = "LINS" + str(self._slot) + ":OUTP:TEL:LASer " + str(mode)
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set laser " + mode + " successfully on module: " + str(self._slot))
            return True
        else:
            print("set laser " + mode + " successfully on module: " + str(self._slot) + output)
            return False

    def getLaserState(self):
        ''' to check if the current testing is running
        @rtype: Boolean
        @return: True|False
        '''
        command = "LINS" + str(self._slot) + ":OUTP:TEL:LASer?"
        self._session.send(command)
        output = self._session.output.strip()

        if "0" == output:
            print("Laser is OFF on module: " + str(self._slot))
            return False
        elif "1" == output:
            print("Laser is ON on module: " + str(self._slot))
            return True
        else:
            raise Exception("Retrieving Laser status failed" + output)


    def startTest(self):
        ''' start the testing(same as hit start button from GUI),also it will clear the RES and HRES errors

        @rtype: Boolean
        @return: True|False

        '''
        if (self.isTesting() == True):
            print("the module is already started")
            return False
        else:
            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:TEST ON"
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*est started successfully', output)
            matchobj1= re.search(r'.*Not allowed to perform start operation at this time',output)
            if matchobj:
                print("set test on successfully on module: " + str(self._slot))
            elif matchobj1:
                raise Exception("Not allowed to perform start operation at this time")
            else:
                print("set test on failed on module: " + str(self._slot) + output)
                return False
        return True


    def RestTotalResult(self):
        ''' Reset Total test result during start traffic
        @rtype: Boolean
        @return: True|False
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:RESet"
        self._session.send(command)
        output = self._session.output
        time.sleep(5)
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("Reset during starting testing successfully on module: " + str(self._slot))
            return True
        else:
            print("Reset during starting testing failed on module: "  + str(self._slot) + output)
            return False


    def switchtx(self, mode="ON"):
        ''' set TX to ON|OFF
        @type mode: string
        @param mode:  ON|OFF
        @rtype: Boolean
        @return: True|False
        '''
        mode = str(mode)
        assert (mode in ["ON","OFF"]),"The mode should be ON|OFF only"
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:TX:STAT " + str(mode)
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set TX " + mode + " successfully on module: " + str(self._slot))
            return True
        else:
            print("set laser " + mode + " successfully on module: " + str(self._slot) + output)
            return False


    def stopTest(self):
        ''' stop the current testing(same as hit stop button from GUI)

        @rtype: Boolean
        @return: True|False

        '''
        if (self.isTesting() == False):
            print("the module is already stopped")
            return True

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:TEST OFF"
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*est stopped successfully', output)
        matchobj1= re.search(r'.*Not allowed to perform stop operation at this time',output)
        if matchobj:
            print("set test off successfully on module: "  + str(self._slot))
            return True
        elif matchobj1:
             raise Exception("Not allowed to perform stop operation at this time")
        else:
            print("set test off failed on module: " + str(self._slot) + output)
            return False


    def isTesting(self):
        ''' to check if the current testing is running
        @rtype: Boolean
        @return: True|False
        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:TEST?"
        self._session.send(command)
        output = self._session.output.strip()
        print(output)
        print(type(output))
        if "0" in output.split('\r\n'):
            print("Testing is not started on module: " + str(self._slot))
            return False
        elif "1" in output.split('\r\n'):
            print("Testing is started on module: " + str(self._slot))
            return True
        else:
            raise Exception("Retrieving testing state failed" + output)

    def getTotalResult(self):
        ''' This query returns Global Test Status verdict status.
        @rtype: string
        @return:True|False
        '''
        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:TEST:STATus:VERDict?"
        self._session.send(command)
        output = self._session.output.strip()
        if "PASS" in output:
            print("Total test result is PASS on %s port %s"%(self._session._host, self._slot))
            return "PASS"
        elif "FAIL" in output:
            print("Total test result is FAIL on %s port %s"%(self._session._host, self._slot))
            return "FAIL"
        else:
            raise Exception("fail to get total result on LINS" + str(self._slot) + " " + output)

    def getTotalEvent(self):
        '''This query returns the list of test events.
        @rtype: string
        @return:output
        '''
        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:LOGGer:LIST?"
        self._session.send(command)
        output = self._session.output.strip()
        if "00:00:00" in output:
            print("It remains alarm during test")
        return output

    def modifyEtherStructure(self, layer="FRAMEDLAYER2"):
        '''' This command sets the framing type.
        @type num: string
        @param layer:FRAMEDLAYER2 |UNFRAMEDPCS | UNFRAMEDCAUI | UNFRAMEDXLAUI |UNFRAMEDWITHOUTSYNC | UNFRAMEDWITHSYNC | FRAMEDLAYER1
        @rtype: Boolean
        @return: True|False
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:BERT:FRAM " + layer
        self._session.send(command)
        output = self._session.output

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set Ethernet frame type " + layer + " successfully on module:" + str(self._slot))
            return True
        else:
            print("Failed to set Ethernet frame type " + layer + "on module:" + str(self._slot))
            return False

    def getEtherFrameCount(self,direction):
        '''' This command sets the framing type.
        @type direction: string
        @param direction:TX|RX
        @rtype: string
        @return: count, like 9999.00000
        '''
        assert (direction in ["TX","RX"]),"The mode should be TX|RX only"
        command = "LINS" + str(self._slot) + ":SENS:DATA:TEL:ETH:PACK:FRAM:COUN? " + direction
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'[0-9]+', output)
        if matchobj:
            print("Total frame " + direction + " is " + output)
            return output
        else:
            print("Failed to get ethernet frame count")
            return False

    def setTransmitterEnable(self,switch):
        '''' This command enables/disable the transmitter.
        @type switch: string
        @param switch:ON|OFF
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:TX:STAT " + switch
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set transmitter enabled successfully")
            return True
        else:
            print("Failed to set transmitter enabled")
            return False

    def setStreamEnable(self,flowid,switch):
        '''' This command enables/disables the selected stream.
        @type flowid: string
        @param flowid:from 1to 16
        @type switch: string
        @param switch:ON|OFF
        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:STReam:ENABled " + flowid + "," + switch
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set stream " + flowid + " successfully")
            return True
        else:
            print("Failed to set stream " + flowid)
            return False
    def setStreamTransMode(self,flowid,mode):
        '''' This command sets the transmitter mode for the selected stream.
        string mode:
            CONTinuous: transmitter mode as Continuous
            BURSt: Burst
            RAMP: Ramp
            NFRame: Number of Frame
            NBURst: Number of Burst
            NRAMp: Number of Ramp
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:MODE " + flowid + "," + mode
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set the transmitter mode for the selected stream " + " successfully on module:" + str(self._slot))
            return True
        else:
            print("Failed to set the transmitter mode for the selected stream" + "on module:" + str(self._slot))
            return False

    def setStreamTransCount(self,flowid,number):
        '''' This command counts the number of frames transmitted for the selected traffic stream.
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:FCO " + flowid + "," + number
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set the counts the number of frames transmitted successful")
            return True
        else:
            print("Failed to set the counts the number of frames transmitted")
            return False

    def getEthDesMAC(self,flowid="1"):
        '''' This This query returns the MAC destination address.
        @output:"XX:XX:XX:XX:XX:XX"
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:ADDR:DEST? " + flowid
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'[0-9]+', output)
        if matchobj:
            print("the MAC destination address is" + output)
            return output
        else:
            print("Failed to get ethernet frame count")
            return False
    def injectEtherneFcsError(self,num):
        ''''to trigger ethernet FCS errors manully
        @type num: string
        @param num: it's range from 1 to 50
        @rtype: Boolean
        @return: True|False
        '''
        result = True

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:MAC:MANual:TYPE FCS"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set ethernet error type as FCS successfully on module: " + str(self._slot))
        else:
            print("Failed to set ethernet error type as FCS on module: " + str(self._slot))
            result = False

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:MAC:AMOunt " + str(num)
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("configure ethernet FCS error amount =" + str(num) + " successfully on module: " + str(self._slot))
        else:
            print("Failed to configure ethernet FCS error amount =" + str(num) + " on module: " + str(self._slot))
            result = False

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:MAC:INJect"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("Inject ethernet FCS error amount =" + str(num) + " successfully on module: " + str(self._slot))
        else:
            print("Failed to Inject ethernet FCS error amount =" + str(num) + " on module: " + str(self._slot))
            result = False
        return result
        
        
    def injectEthernePcsError(self, strType, strAmount):
        ''''to trigger ethernet FCS errors manully
        @type num: string
        @param num: it's range from 1 to 50
        @rtype: Boolean
        @return: True|False
        '''
        result = True
        
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:ALAN ON"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set ethernet error type as PCS successfully on module: " + str(self._slot))
        else:
            print("Failed to set ethernet error type as PCS on module: " + str(self._slot))
            result = False
            
        if str(strAmount).isdigit():
            command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:MANual:TYPE " + str(strType)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("configure ethernet PCS error amount =" + str(strAmount) + " successfully on module: " + str(self._slot))
            else:
                print("Failed to configure ethernet PCS error amount =" + str(strAmount) + " on module: " + str(self._slot))
                result = False
                
            command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:AMOunt " + str(strAmount)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set ethernet error type as PCS successfully on module: " + str(self._slot))
            else:
                print("Failed to set ethernet error type as PCS on module: " + str(self._slot))
                result = False
                
            command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:INJect"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("Inject ethernet PCS error amount =" + str(strAmount) + " successfully on module: " + str(self._slot))
            else:
                print("Failed to Inject ethernet PCS error amount =" + str(strAmount) + " on module: " + str(self._slot))
                result = False
                
            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:ALAN OFF"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set ethernet error type as PCS successfully on module: " + str(self._slot))
            else:
                print("Failed to set ethernet error type as PCS on module: " + str(self._slot))
                result = False
        
        else:
            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:AUT:TYPE " + str(strType)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("configure ethernet PCS error amount =" + str(strAmount) + " successfully on module: " + str(self._slot))
            else:
                print("Failed to configure ethernet PCS error amount =" + str(strAmount) + " on module: " + str(self._slot))
                result = False

            if str(strAmount) == "MAX":
                command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:AUT:CONTinuous ON"
                self._session.send(command)
                output = self._session.output.strip()
                matchobj = re.search(r'.*ommand executed successfully', output)
                if matchobj:
                    print("Inject ethernet PCS error amount =" + str(strAmount) + " successfully on module: " + str(self._slot))
                else:
                    print("Failed to Inject ethernet PCS error amount =" + str(strAmount) + " on module: " + str(self._slot))
                    result = False
            else:
                command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:AUT:RATE " + str(strAmount)
                self._session.send(command)
                output = self._session.output.strip()
                matchobj = re.search(r'.*ommand executed successfully', output)
                if matchobj:
                    print("Inject ethernet PCS error amount =" + str(strAmount) + " successfully on module: " + str(self._slot))
                else:
                    print("Failed to Inject ethernet PCS error amount =" + str(strAmount) + " on module: " + str(self._slot))
                    result = False
                    
            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:AUT ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("Inject ethernet PCS error amount =" + str(strAmount) + " successfully on module: " + str(self._slot))
            else:
                print("Failed to Inject ethernet PCS error amount =" + str(strAmount) + " on module: " + str(self._slot))
                result = False
                
        
        return result
        
    def stopInjectEthernePcsError(self, strType):
        ''''to trigger ethernet FCS errors manully
        @type num: string
        @param num: it's range from 1 to 50
        @rtype: Boolean
        @return: True|False
        '''
        result = True

        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:AUT OFF"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("stop Inject ethernet PCS error successfully on module: " + str(self._slot))
        else:
            print("Failed to Inject ethernet PCS error on module: " + str(self._slot))
            result = False

        
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:ERR:PHYS:ALAN OFF"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set ethernet error type as PCS successfully on module: " + str(self._slot))
        else:
            print("Failed to set ethernet error type as PCS on module: " + str(self._slot))
            result = False
            
        return result

    def injectEthernetLOS(self,mode='10ge'):
        ''''to trigger optical LOS for 10ge and 100ge client.
        @mac:"XX:XX:XX:XX:XX:XX"
        '''
        result = True
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:OPT:ALAR:PORT:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()

        if "LOS" == output:
            print("The ethernet interface LOS has already been configured on module: "+ str(self._slot))
            if mode == '100ge':
                command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:OPT:ALAR:PORT:ALAN ON"
                self._session.send(command)
                output = self._session.output.strip()
                matchobj = re.search(r'.*ommand executed successfully', output)

            command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT on"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("start to inject LOS with interface successfully on module: " + str(self._slot))
            else:
                print("Failed to start to inject LOS with interface on module: " + str(self._slot))
                result = False
            time.sleep(3)

            command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT off"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("stop to inject LOS with interface successfully on module: " + str(self._slot))
            else:
                print("Failed to stop to inject LOS with interface on module: " + str(self._slot))
                result = False
        else:
            print("Error:interface LOS has not already been configured on module: "+ str(self._slot))
            result = False
        return result

    def injectEthernetPhyBer(self, num):
        '''' to trigger ethernet PHY errors

        @type num: string
        @param num: it's range from 1 to 50

        @rtype: Boolean
        @return: True|False

        '''
        result = True

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:MANual:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()
        if "SYMBOL" == output:
            print("The ethernet error type SYMBOL has already been set up on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:MANual:TYPE SYMBol"
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set ethernet physical error type as SYMBOL successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set ethernet physical error type as SYMBOL not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:AMOunt " + str(num)
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("configure ethernet physcial error amount =" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("configure ethernet physical error amount =" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:AMOunt?"
        self._session.send(command)
        output = self._session.output.strip()
        if str(num) == output:
            print("retrieved ethernet physical error configured amount =" + str(num) + " successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved ethernet physical error configured amount =" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False


        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:PHYSical:INJect"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("Inject ethernet physical error amount =" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("Inject ethernet physical error amount =" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        return result

    def startInjectSonetBer(self,layer,num,typ="MANUAL"):
        ''' to trigger B3/B2/B1 errors by MANUAL or AUTOMATED,when using MANUAL, it will trigger amount of errors.when using AUTOMATED,it will trigger errors continuously with a rate
        @type layer: string
        @param layer: B3|B2|B1|OBIP8
        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50.when using AUTOMATED,it's a rate like 4.0E-07 or MIN|MAX|DEF
        @type typ: string
        @param: MANUAL|AUTOMATED
        @rtype: Boolean
        @return: True|False

        '''
        layer = str(layer)
        assert(layer in ["B3","B2","B1","OBIP8"]), "inject sonet|OTN Ber,please choose B3|B2|B1|OBIP8 for the first parameter"

        typ = str(typ)
        assert(typ in ["MANUAL","AUTOMATED"]), "inject sonet Ber,please choose MANUAL|AUTOMATED for the third parameter,MANUAL means manully injecting errors by number, AUTOMATED means contineously injecting errors by rate"

        num = str(num)
        r= re.compile('.{3}E-0.{1}')

        assert (num in ["MAX","MIN","MAXIMUM", "MINIMUM","DEF"] or r.match(num) or int(num) in range(1,51)),"Please choose the correct value for the second parameter, if MANUAL type choosed, please use a number between 1 to 50, if AUTOMATED type choosed,please set the second parameter with a rate like 4.0E-06 or MIN|MAX|DEF" + ":  " + str(num)
        protocol = "SDHSONET"
        if "OBIP8" == layer:
            protocol = "OTN"
            errorLayer = "ODU2"
        elif "B3" == layer:
            errorLayer = "HOP:PATH"
        elif "B2" == layer:
            errorLayer = "LINE"
        else:
            errorLayer = "SECT"

        result = True
        if "MANUAL" == typ:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:SON:ERR:"+errorLayer + ":AUT OFF"
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:" + errorLayer + ":MANual:TYPE BERRor"
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error type as BERRor successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:" + errorLayer+":MANual:TYPE?"
            self._session.send(command)
            output = self._session.output.strip()
            if "BERROR" == output:
                print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:"+errorLayer + ":AMOunt " + str(num)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:"+errorLayer + ":AMOunt?"
            self._session.send(command)
            output = self._session.output.strip()
            if str(num) == output:
                print("retrieved  error amount=" + str(num) + " successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:"+errorLayer+":INJect"
            self._session.send(command)
            output = self._session.output.strip()

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("Inject error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("Inject error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

        else:

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:SDHSONET:ERR:"+errorLayer + ":AUT OFF"
            self._session.send(command)


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SDHSONET:ERRor:" + errorLayer + ":AUTOmated:TYPE " + layer
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error type as BERRor successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SDHSONET:ERRor:" + errorLayer+":AUTOmated:TYPE?"
            self._session.send(command)
            output = self._session.output.strip()
            if layer == output:
                print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TEL:SDHSONET:ERR:"+errorLayer + ":AUT:CONT OFF"
            self._session.send(command)


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:SDHSONET:ERR:"+ errorLayer + ":AUTomated:RATE " + str(num)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error rate =" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error rate =" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TEL:SDHSONET:ERR:"+errorLayer + ":AUT:CONT ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:SDHSONET:ERR:" + errorLayer+":AUT:CONT?"
            self._session.send(command)
            output = self._session.output.strip()
            if "1" == output:
                print("retrieved automated continuous successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved automated continuous not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:SDHSONET:ERR:"+errorLayer + ":AUT ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

        return result

    def startInjectOTNBip8(self,layer,num,typ="MANUAL"):
        ''' to trigger B3/B2/B1 errors by MANUAL or AUTOMATED,when using MANUAL, it will trigger amount of errors.when using AUTOMATED,it will trigger errors continuously with a rate
        @type layer: string
        @param layer: OTU2_OBIP8|OTU4_OBIP8|ODU2_OBIP8|ODU4_OBIP8|OTU2E_OBIP8|ODU2E_OBIP8
        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50.when using AUTOMATED,it's a rate like 4.0E-07 or MIN|MAX|DEF
        @type typ: string
        @param: MANUAL|AUTOMATED
        @rtype: Boolean
        @return: True|False

        '''
        layer = str(layer)
        assert layer in ["OTU2_OBIP8", "OTU4_OBIP8", "ODU2_OBIP8", "ODU4_OBIP8", "OTU2E_OBIP8", "ODU2E_OBIP8"], "inject sonet|OTN Ber,please choose OTU2_OBIP8|OTU4_OBIP8|ODU2_OBIP8|ODU4_OBIP8|OTU2E_OBIP8|ODU2E_OBIP8 for the first parameter"

        typ = str(typ)
        assert typ in ["MANUAL","AUTOMATED"], "inject sonet Ber,please choose MANUAL|AUTOMATED for the third parameter,MANUAL means manully injecting errors by number, AUTOMATED means contineously injecting errors by rate"

        num = str(num)
        r= re.compile('.{3}E-0.{1}')

        assert (num in ["MAX","MIN","MAXIMUM", "MINIMUM","DEF"] or r.match(num) or int(num) in range(1,51)),"Please choose the correct value for the second parameter, if MANUAL type choosed, please use a number between 1 to 50, if AUTOMATED type choosed,please set the second parameter with a rate like 4.0E-06 or MIN|MAX|DEF" + ":  " + str(num)

        # if "OBIP8" == layer:

            # errorLayer = "ODU2"
        # elif "B3" == layer:
            # errorLayer = "HOP:PATH"
        # elif "B2" == layer:
            # errorLayer = "LINE"
        # else:
            # errorLayer = "SECT"
        errorLayer = layer.split("_")[0]
        if "OTU2E" == errorLayer:
            errorLayer = "OTU2:E"
        elif "ODU2E" == errorLayer:
            errorLayer = "ODU2:E"
        layer = layer.split("_")[1]

        result = True
        if "MANUAL" == typ:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+errorLayer + ":AUT OFF"
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:" + errorLayer + ":MANual:TYPE %s"%layer
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error type as BERRor successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:" + errorLayer+":MANual:TYPE?"
            self._session.send(command)
            output = self._session.output.strip()
            if "BERROR" == output:
                print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:"+errorLayer + ":AMOunt " + str(num)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:"+errorLayer + ":AMOunt?"
            self._session.send(command)
            output = self._session.output.strip()
            if str(num) == output:
                print("retrieved  error amount=" + str(num) + " successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:"+errorLayer+":INJect"
            self._session.send(command)
            output = self._session.output.strip()

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("Inject error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("Inject error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

        else:

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+errorLayer + ":AUT OFF"
            self._session.send(command)


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:" + errorLayer + ":AUTOmated:TYPE " + layer
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error type as BERRor successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:" + errorLayer+":AUTOmated:TYPE?"
            self._session.send(command)
            output = self._session.output.strip()
            if layer == output:
                print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False
                
                
            if "MAX" == num:
                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TEL:OTN:ERR:"+errorLayer + ":AUT:CONT ON"
                self._session.send(command)
                output = self._session.output.strip()
                matchobj = re.search(r'.*ommand executed successfully', output)
                if matchobj:
                    print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot))
                else:
                    print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                    result = False

                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:" + errorLayer+":AUT:CONT?"
                self._session.send(command)
                output = self._session.output.strip()
                if "1" == output:
                    print("retrieved automated continuous successfully on module: "+ str(self.shelf) + " " + str(self._slot))
                else:
                    print("retrieved automated continuous not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                    result = False
            else:
                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TEL:OTN:ERR:"+errorLayer + ":AUT:CONT OFF"
                self._session.send(command)


                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUTomated:RATE " + str(num)
                self._session.send(command)
                output = self._session.output.strip()
                matchobj = re.search(r'.*ommand executed successfully', output)
                if matchobj:
                    print("set error rate =" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
                else:
                    print("set error rate =" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                    result = False

                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TEL:OTN:ERR:"+errorLayer + ":AUT:CONT ON"
                self._session.send(command)
                output = self._session.output.strip()
                matchobj = re.search(r'.*ommand executed successfully', output)
                if matchobj:
                    print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot))
                else:
                    print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                    result = False

                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:" + errorLayer+":AUT:CONT?"
                self._session.send(command)
                output = self._session.output.strip()
                if "1" == output:
                    print("retrieved automated continuous successfully on module: "+ str(self.shelf) + " " + str(self._slot))
                else:
                    print("retrieved automated continuous not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                    result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+errorLayer + ":AUT ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

        return result

    def stopInjectSonetBer(self,layer,typ="AUTOMATED"):
        ''' to stop B3/B2/B1 errors triggering,normally it means AUTOMATED continuous triggering stopped,when triggering B3|B2|B1 errors by MANUAL, we don't need this proc since it's one time operation
        @type layer: string
        @param layer: B3|B2|B1

        @type typ: string
        @param: AUTOMATED
        @rtype: Boolean
        @return: True|False

        '''
        layer = str(layer)
        assert(layer in ["B3","B2","B1"]), "inject sonet Ber,please choose B3|B2|B1 for the first parameter"

        typ = str(typ)
        assert(typ in ["AUTOMATED"]), "stop inject sonet Ber,please choose AUTOMATED only or don't set the second parameter,only automated continuous need to stop injection errors,for MANUAL, it's a one time command"


        if "B3" == layer:
            errorLayer = "HOP:PATH"
        elif "B2" == layer:
            errorLayer = "LINE"
        else:
            errorLayer = "SECT"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SDHSONET:ERRor:" + errorLayer+":AUTomated?"
        self._session.send(command)
        output = self._session.output.strip()
        if "1" == output:
            print("Automated is running now,you can stop now: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("it's not automated continuous error injection currently, don't need to stop it: " + str(self.shelf) + " " + str(self._slot) + output + ", you may need to check your testing logic")


        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SDHSONET:ERRor:"+errorLayer + ":AUTOmated OFF"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return True
        else:
            print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            return False


    def stopInjectOTNBip8(self,layer,typ="AUTOMATED"):
        ''' to stop OBIP8 errors triggering,normally it means AUTOMATED continuous triggering stopped,when triggering B3|B2|B1 errors by MANUAL, we don't need this proc since it's one time operation
        @type layer: string
        @param layer: OTU2_OBIP8|OTU4_OBIP8|ODU2_OBIP8|ODU4_OBIP8|OTU2E_OBIP8|ODU2E_OBIP8

        @type typ: string
        @param: AUTOMATED
        @rtype: Boolean
        @return: True|False

        '''
        layer = str(layer)
        assert(layer in ["OTU2_OBIP8", "OTU4_OBIP8", "ODU2_OBIP8", "ODU4_OBIP8", "OTU2E_OBIP8", "ODU2E_OBIP8"]), "inject sonet Ber,please choose OTU2_OBIP8|OTU4_OBIP8|ODU2_OBIP8|ODU4_OBIP8|OTU2E_OBIP8|ODU2E_OBIP8 for the first parameter"

        typ = str(typ)
        assert(typ in ["AUTOMATED"]), "stop inject sonet Ber,please choose AUTOMATED only or don't set the second parameter,only automated continuous need to stop injection errors,for MANUAL, it's a one time command"



        # if "B3" == layer:
            # errorLayer = "HOP:PATH"
        # elif "B2" == layer:
            # errorLayer = "LINE"
        # else:
            # errorLayer = "SECT"
        errorLayer = layer.split("_")[0]
        if "OTU2E" == errorLayer:
            errorLayer == "OTU2:E"
        elif "ODU2E" == errorLayer:
            errorLayer == "ODU2:E"
        layer = layer.split("_")[1]
        
        # command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:" + errorLayer+":AUTomated:CONTinuous?"
        # self._session.send(command)
        # output = self._session.output.strip()
        # if "1" == output:
            # print("Automated is running now,you can stop now: "+ str(self.shelf) + " " + str(self._slot))
            # command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:"+errorLayer + ":AUTOmated:CONTinuous OFF"
            # self._session.send(command)
            # output = self._session.output.strip()
            # matchobj = re.search(r'.*ommand executed successfully', output)
            # if matchobj:
                # print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))

            # else:
                # print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                # return False
        # else:
            # print("it's not automated continuous error injection currently, don't need to stop it: " + str(self.shelf) + " " + str(self._slot) + output + ", you may need to check your testing logic")



        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:" + errorLayer+":AUTomated?"
        self._session.send(command)
        output = self._session.output.strip()
        if "1" == output:
            print("Automated is running now,you can stop now: "+ str(self.shelf) + " " + str(self._slot))
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:ERRor:"+errorLayer + ":AUTOmated OFF"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
                
            else:
                print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                return False
        else:
            print("it's not automated continuous error injection currently, don't need to stop it: " + str(self.shelf) + " " + str(self._slot) + output + ", you may need to check your testing logic")

        return True



    def injectSonetB3Ber(self, num):
        ''' to trigger B3 errors by MANUAL,we can use injectSonetBer method instead

        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50

        @rtype: Boolean
        @return: True|False

        '''
        print("this is depreciated method,try to use startInjectBer method")
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:HOP:PATH:MANual:TYPE BERRor"
        self._session.send(command)
        output = self._session.output
        result = True
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set error type as BERRor successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:HOP:PATH:MANual:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()
        if "BERROR" == output:
            print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:HOP:PATH:AMOunt " + str(num)
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:HOP:PATH:AMOunt?"
        self._session.send(command)
        output = self._session.output.strip()
        if str(num) == output:
            print("retrieved  error amount=" + str(num) + " successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False


        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:HOP:PATH:INJect"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("Inject error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("Inject error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        return result


    def injectSonetB2Ber(self, num):
        ''' to trigger B2 errors by MANUAL,we can use injectSonetBer method instead

        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50

        @rtype: Boolean
        @return: True|False

        '''
        print("this is depreciated method,try to use startInjectBer method")
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:LINE:MANual:TYPE BERRor"
        self._session.send(command)
        output = self._session.output
        result = True
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set error type as BERRor successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:LINE:MANual:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()
        if "BERROR" == output:
            print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:LINE:AMOunt " + str(num)
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:LINE:AMOunt?"
        self._session.send(command)
        output = self._session.output.strip()
        if str(num) == output:
            print("retrieved  error amount=" + str(num) + " successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False


        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:LINE:INJect"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("Inject error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("Inject error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        return result

    def injectSonetB1Ber(self, num):
        '''' to trigger B3 errors by MANUAL,we can use injectSonetBer method instead

        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50

        @rtype: Boolean
        @return: True|False

        '''
        print("this is depreciated method,try to use startInjectBer method")
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:SECT:MANual:TYPE BERRor"
        self._session.send(command)
        output = self._session.output
        result = True
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set error type as BERRor successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:SECT:MANual:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()
        if "BERROR" == output:
            print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:SECT:AMOunt " + str(num)
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:SECT:AMOunt?"
        self._session.send(command)
        output = self._session.output.strip()
        if str(num) == output:
            print("retrieved  error amount=" + str(num) + " successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False


        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:SONet:ERRor:SECT:INJect"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("Inject error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("Inject error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        return result

    def getSonetBer(self,layer,typ="COUNT"):
        ''' to get B3|B2|B1 errors showed in  test set rx side

        @type layer: string
        @param layer: B3|B2|B1
        @type typ: string
        @param typ: COUNT|RATE|SECONDS
        @rtype: string
        @return: numbers or 4.0E-07 like string

        '''
        layer = str(layer)
        assert(layer in ["B3","B2","B1"]), "get sonet Ber,please choose B3|B2|B1 for the first parameter"
        typ = str(typ)
        assert (typ in ["COUNT","RATE","SECONDS"]),"The type should be COUNT|RATE|SECONDS only"

        if "B3" == layer:
            errorLayer = "HOP:PATH"
        elif "B2" == layer:
            errorLayer = "LINE"
        else:
            errorLayer = "SECT"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":FETC:DATA:TELecom:SONet:ERRor:" + errorLayer +":" + typ +"? BERR"
        #need to wait several seconds ,otherwise , it will return 0.000000
        time.sleep(5)
        self._session.send(command)
        output = self._session.output.strip()
        print("Retrieved Ber error layer "+ errorLayer + " " + typ + " on module: " + str(self.shelf) + " " + str(self._slot) + " " + output)
        return str(output)




    def setProtocolAlarm(self,protocol,alarmLocation,alarmName):
        ''' to set which alarm to be triggered on SONET|SDH|LINE|RES|SECTION|HOP...

        @type protocol: string
        @param protocol: SONET|SDH
        @type alarmLocation: string
        @param alarmLocation: RES|SECTION|LINE|HOP|OTU2|ODU2|OTU4|ODU4|OTU2E|ODU2E
        @type alarmName: string
        @param alarmName:if alarmLocation is SECTION,this should be LOF1|SEF1|TIMS. if alarmLocation is LINE,this should be AIS|RDI.if alarmLocation is HOP,this should be AIS|RDI|LOP|LOM|TIM|PLM|UNEQP1|PDI|EPSD1|EPCD1|EPPD1
        @rtype: Boolean
        @return: True|False

        '''
        protocol = str(protocol)
        alarmLocation = str(alarmLocation)
        alarmName = str(alarmName)
        assert (protocol in ["SONET","SDH", "SDHSONET", "OTN"]),"The protocol parameter should be SONET|SDH|SDHSONET|OTN only"
        if "OTN" == protocol:
            assert (alarmLocation in ["OTU2", "ODU2", "OTU4", "ODU4", "OTU2E", "ODU2E"]),"The alarmLocation parameter should be OTU2|ODU2|OTU4|ODU4 only"
            if alarmLocation in ["OTU2", "OTU4", "OTU2E"]:
                assert (alarmName in ["OAIS", "OBDI", "LOM", "LOF", "OOF", "OOM", "OBIAE", "OIAE", "OTIM"]),"The alarm should be OAIS | OBDI | LOF | OOF | LOM | OOM | OBIAE | OIAE | OTIM"
            elif alarmLocation in ["ODU2", "ODU4", "ODU2E"]:
                assert (alarmName in ["OAIS", "OBDI", "OLCK", "OOCI", "OFSF", "OBSF", "OFSD", "OBSD", "LOFLom"]),"The alarm should be OAIS | OBDI | OLCK | OOCI | OFSF | OBSF | OFSD | OBSD | LOFLom"
        else:
            assert (alarmLocation in ["RES","SECTION","LINE","HOP"]),"The alarmLocation parameter should be RES|SECTION|LINE|HOP only"
            if alarmLocation in ["LINE"]:
                assert (alarmName in ["AIS", "RDI"]),"The alarm should be AIS | RDI"
            elif alarmLocation in ["SECTION"]:
                assert (alarmName in ["LOF1", "SEF1"]),"The alarm should be LOF1 | SEF1"
            elif alarmLocation in ["HOP"]:
                assert (alarmName in ["AIS", "RDI", "EPSD1", "EPCD1", "EPPD1", "LOP", "PDI", "UNEQP1"]),"The alarm should be AIS | RDI | EPSD1 | EPCD1 | EPPD1 | LOP | PDI | UNEQP1"
            elif alarmLocation in ["RES"]:
                # not found in the EXFO help document
                assert (alarmName in ["LOF1","SEF1","TIMS","AIS","RDI","LOP","TIM","UNEQP1","LOM","PDI","EPPD1","EPCD1","EPSD1", "OOCI", "OLCK", "OAIS", "OBDI", "LOM", "LOF"]),"The alarm should be LOF|SEF if alarmLocation=SECTION,AIS|RDI if alarmLocation=LINE and AIS|LOP|RDI|LOM|UNEQP1|PDI|EPPD1|EPCD1|EPSD1 if alarmLocation=HOP"

        if "HOP" == alarmLocation:
            tail = "HOP:PATH:TYPE"
        elif "OTU2E" == alarmLocation:
            tail = "OTU2:E:TYPE"
        elif "ODU2E" == alarmLocation:
            tail = "ODU2:E:TYPE"
        else:
            tail = alarmLocation + ":TYPE"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ALARM:" +  tail + "?"
        self._session.send(command)
        output = self._session.output.strip()
        if (output == alarmName):
            print("alarm =" + alarmName + " has already been set up on module: " + str(self.shelf) + " " + str(self._slot) + " " + alarmLocation + " " + protocol)
            return True

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ALARM:" +  tail + " " + alarmName
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set alarm =" + alarmName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + alarmLocation + " " + protocol)
            return True
        else:
            print("set alarm =" + alarmName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + alarmLocation + " " + protocol + output)
            return False



    def setPortAlarm(self,alarmName):
        ''' to set which alarm to be triggered on port


        @type alarmName: string
        @param alarmName: LOS|FRE only
        @rtype: Boolean
        @return: True|False

        '''
        alarmName = str(alarmName)
        assert (alarmName in ["LOS","FRE"]),"The alarm should be LOS"
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OPT:ALARM:PORT:TYPE?"
        self._session.send(command)
        output = self._session.output.strip()
        if (output == alarmName):
            print("The alarm: " + alarmName + " has been set already")
            return True

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OPT:ALARM:PORT"+ " " + alarmName
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set alarm =" + alarmName + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return True
        else:
            print("set alarm =" + alarmName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + output)
            return False



    def enableProtocolAlarm(self,protocol,alarmLocation,enabled="ON"):
        ''' to enabled the alarm which has beend set by setProtocolAlarm method
        @type protocol: string
        @param protocol: SONET|SDH|SDHSONET|OTN
        @type alarmLocation: string
        @param alarmLocation: RES|SECTION|LINE|HOP|OTU2|ODU2|OTU4|ODU4|OTU2E|ODU2E
        @type enable: string
        @param enable:ON|OFF
        @rtype: Boolean
        @return: True|False
        '''
        enabled = str(enabled)
        protocol = str(protocol)
        alarmLocation = str(alarmLocation)
        assert (enabled in ["ON", "OFF"]),"parameter should be ON|OFF"
        assert (protocol in ["SONET","SDH", "SDHSONET", "OTN"]),"The protocol parameter should be SONET|SDH|SDHSONET|OTN only"
        if "OTN" == protocol:
            assert (alarmLocation in ["OTU2", "ODU2", "OTU4", "ODU4", "OTU2E", "ODU2E"]),"The alarmLocation parameter should be OTU2|ODU2|OTU4|ODU4|OTU2E|ODU2E only"
        elif protocol in ["SONET","SDH", "SDHSONET"]:
            assert (alarmLocation in ["RES","SECTION","LINE","HOP"]),"The alarmLocation parameter should be RES|SECTION|LINE|HOP only"

        if "HOP"== alarmLocation:
            tail = "HOP:PATH"
        elif "OTU2E" == alarmLocation:
            tail = "OTU2:E"
        elif "ODU2E" == alarmLocation:
            tail = "ODU2:E"
        else:
            tail = alarmLocation
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ALARM:" +  tail + " " + enabled
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("enable alarm successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + alarmLocation + " " + protocol + " " + enabled)
            return True
        else:
            print("enable alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + alarmLocation + " " + protocol + " " + enabled + " " + output)
            return False



    def enablePortAlarm(self,enabled="ON"):
        ''' to enabled the alarm which has beend set by setPortAlarm method

        @type enable: string
        @param enable:ON|OFF
        @rtype: Boolean
        @return: True|False
        '''
        enabled = str(enabled)
        assert (enabled in ["ON", "OFF"]),"parameter should be ON|OFF"
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OPT:ALARM:PORT " + enabled
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("enable alarm successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + enabled)
            return True
        else:
            print("enable alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + enabled + " " + output)
            return False



    def getProtocolAlarm(self,protocol,alarmLocation,alarmName,interval="CURRENT"):
        ''' to retrieve if the test set rx side has the protocol alarm provided currently or historically


        @type protocol: string
        @param protocol: SONET|SDH
        @type alarmLocation: string
        @param alarmLocation: RES|SECTION|LINE|HOP
        @type interval: string
        @param interval:CURRENT|HIST
        @rtype: string
        @return: ABSENT|PRESENT|INACTIVE|MASKED
        '''

        protocol = str(protocol)
        alarmLocation = str(alarmLocation)
        alarmName = str(alarmName)
        inteval = str(interval)

        assert (protocol in ["SONET","SDH", "SDHSONET"]),"The protocol parameter should be SONET|SDH|SDHSONET only"
        assert (alarmLocation in ["RES","SECTION","LINE","HOP"]),"The alarmLocation parameter should be RES|SECTION|LINE|HOP only"
        assert (alarmName in ["LOF1","SEF1","TIMS","AIS","RDI","LOP","UNEQP1","LOM","PDI","EPPD1","EPCD1","EPSD1"]),"The alarm should be LOF1|SEF1|TIMS if alarmLocation = SECTION,AIS|RDI if alarmLocation = LINE and AIS|LOP|RDI|UNEQP1|PDI|LOM|EPPD1|EPCD1|EPSD1 if alarmLocation = HOP"
        assert (interval in ["CURRENT","HIST"]), "The interval parameter should be CURRENT|HIST only"
        if "HOP"== alarmLocation:
            tail = "HOP:PATH:"
        else:
            tail = alarmLocation + ":"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":FETC:DATA:TEL:"+protocol +":ALAR:" +  tail + interval + "?" + " " + alarmName
        self._session.send(command)
        output = self._session.output.strip()

        if (output in ["ABSENT","PRESENT","INACTIVE","MASKED"]):
            print("get alarm =" + alarmName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + alarmLocation + " " + protocol + " " + interval)
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + alarmLocation + " " + protocol + " " + inteval + " " + output)




    def getPortAlarm(self,alarmName,interval="CURRENT"):
        ''' to retrieve if the test set rx side has the port level alarm provided currently or historically

        @type alarmName: string
        @param alarName: LOS|FRE only
        @type interval: string
        @param interval:CURRENT|HIST
        @rtype: string
        @return: ABSENT|PRESENT|INACTIVE|MASKED
        '''
        alarmName = str(alarmName)
        interval = str(interval)
        assert (interval in ["CURRENT", "HIST"]), "The interval parameter should be CURRENT|HIST only"
        assert (alarmName in ["LOS","FRE"]),"The alarm should be LOS|FRE"
        command = "LINS" + str(self.shelf) + str(self._slot) + ":FETC:DATA:TEL:OPT:ALARM:PORT:"+ interval + "?" + " "+ alarmName
        self._session.send(command)
        output = self._session.output.strip()

        if (output in ["ABSENT","PRESENT","INACTIVE","MASKED"]):
            print("get alarm =" + alarmName + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + output)


    def getAlarmStatus(self,interval="CURRENT"):
        ''' to Retrieves the global alarm status on the receiving end of Exfo test gear
        @type interval: string
        @param interval:CURRENT|HIST
        @rtype: string
        @return: ABSENT|PRESENT|INACTIVE|MASKED
        '''
        assert (interval in ["CURRENT", "HIST"]), "The interval parameter should be CURRENT|HIST only"
        command = "LINS" + str(self.shelf) + str(self._slot) + ":FETC:DATA:TELecom:TEST:GLOBal:"+ interval + "?"
        self._session.send(command)
        output = self._session.output.strip()

        if (output in ["ABSENT","PRESENT","INACTIVE","MASKED"]):
            print("get alarm =" + alarmName + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + output)


    def getCurrentOTU4Alarm(self,alarmName ="LOF"):
        '''
        this function fro check test set otu4 alarm
        '''
        command = "LINS" + str(self._slot) + ":FETC:DATA:TELecom:OTN:ALARm:OTU4:CURRent" + "?" + " " + alarmName
        self._session.send(command)
        output = self._session.output.strip()
        if output == "PRESENT":
            print("get alarm =" + alarmName + " successfully on module: " + " " + str(self._slot))
            return output
        elif output in ["ABSENT", "MASKED"]:
            print("alarm =" + alarmName + " does not exists on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + " " + str(self._slot) + " " + output)


    def getCurrentODU4Alarm(self,alarmName ="OAIS"):
        '''
        this function fro check test set odu4 alarm
        '''
        command = "LINS" + str(self._slot) + ":FETC:DATA:TELecom:OTN:ALARm:ODU4:CURRent" + "?" + " " + alarmName
        self._session.send(command)
        output = self._session.output.strip()
        if output == "PRESENT":
            print("get alarm =" + alarmName + " successfully on module: " + " " + str(self._slot))
            return output
        elif output in ["ABSENT", "MASKED"]:
            print("alarm =" + alarmName + " does not exists on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + " " + str(self._slot) + " " + output)
            

    def getCurrentODU4Alarmloopback(self,alarmName ="OBDi"):
        '''
        this function for check test set odu4 alarm
        '''
        command = "LINS" + str(self._slot) + ":FETC:DATA:TEL:OTN:ALAR:ODU4:CURRent" + "?" + " " + alarmName
        self._session.send(command)
        output = self._session.output.strip()
        if output == "PRESENT":
            print("get alarm =" + alarmName + " successfully on module: " + " " + str(self._slot))
            return output
        elif output in ["ABSENT", "MASKED"]:
            print("alarm =" + alarmName + " does not exists on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + " " + str(self._slot) + " " + output)

    def getCurrentODU2Alarm(self,alarmName ="ODU2_OBDI"):
        '''
        this function for check test set otu2 alarm
        '''
        command = "LINS" + str(self._slot) + ":FETC:DATA:TELecom:OTN:ALARm:ODU2:CURRent" + "?" + " " + alarmName.split("_")[1]
        self._session.send(command)
        output = self._session.output.strip()
        if output == "PRESENT":
            print("get alarm =" + alarmName + " successfully on module: " + " " + str(self._slot))
            return output
        elif output in ["ABSENT", "MASKED"]:
            print("alarm =" + alarmName + " does not exists on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + " " + str(self._slot) + " " + output)


    def getCurrentODU2eAlarm(self,alarmName ="ODU2E_OBDI"):
        '''
        this function for check test set otu2e alarm
        '''
        command = "LINS" + str(self._slot) + ":FETC:DATA:TELecom:OTN:ALARm:ODU2:E:CURRent" + "?" + " " + alarmName.split("_")[1]
        self._session.send(command)
        output = self._session.output.strip()
        if output == "PRESENT":
            print("get alarm =" + alarmName + " successfully on module: " + " " + str(self._slot))
            return output
        elif output in ["ABSENT", "MASKED"]:
            print("alarm =" + alarmName + " does not exists on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + " " + str(self._slot) + " " + output)


    def getCurrentSONETAlarm(self,alarmName ="LINE_RDI"):
        '''
        this function for check test set SONET/SDH RDI alarm
        '''
        command = "LINS" + str(self._slot) + ":FETC:DATA:TEL:SDHS:ALAR:LINE:CURRent" + "?" + " " + alarmName.split("_")[1]
        self._session.send(command)
        output = self._session.output.strip()
        if output == "PRESENT":
            print("get alarm =" + alarmName + " successfully on module: " + " " + str(self._slot))
            return output
        elif output in ["ABSENT", "MASKED"]:
            print("alarm =" + alarmName + " does not exists on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + " " + str(self._slot) + " " + output)
            
    def getCurrentEthernetAlarm(self,alarmName):
        '''
        this function for check test set ethernet alarm
        '''
        if alarmName == "LFAULT":
            alarmName = "LFAR"
        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:ETHernet:ALARm:PHYSical:GLOBal:CURRent" + "?" + " " + alarmName
        self._session.send(command)
        output = self._session.output.strip()
        if output == "PRESENT":
            print("get alarm =" + alarmName + " successfully on module: " + " " + str(self._slot))
            return output
        elif output in ["ABSENT", "MASKED"]:
            print("alarm =" + alarmName + " does not exists on module: " + " " + str(self._slot))
            return output
        else:
            raise Exception("get alarm =" + alarmName + " not successfully on module: " + " " + str(self._slot) + " " + output)


    def open(self):
        self._session.open()

    def close(self):
        self._session.close()

    def setVOAAttenuation(self, fValue):
        result = True
        command = "LINS%d%d:INPut:ATTenuation %E"%(shelf, self._slot, fValue)
        self._session.send(command)

        command = "LINS%d%d:INPut:ATTenuation?"%(shelf, self._slot)
        self._session.send(command)

        output = self._session.output.strip()
        strTemp = '%E'%fValue
        strTemp = strTemp[:-2] + "0" + strTemp[-2:]
        #matchobj = re.search(strTemp, output.strip())
        if output.strip() == strTemp:
            print("set VOA attenuation successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set VOA attenuation not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            result = False

        return result

    def getVOAAttenuation(self):
        result = True

        command = "LINS%d%d:INPut:ATTenuation?"%(shelf, self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if re.search("\d.\d{6}E[+-]\d{3}", output):
            print("get VOA attenuation successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("get VOA attenuation not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually result is--" + output)
            result = False

        return float(output)

    def adjustVOAAttenuation(self, fValue):
        result = True

        curVOAValue = self.getVOAAttenuation()

        if not curVOAValue:
            return False

        return self.setVOAAttenuation(fValue + curVOAValue)

    def setVOAWavelength(self, fValue):
        if int(fValue) == 1310 or int(fValue) == 1550:
            fValue = fValue * 0.000000001
        else:
            print("the wave length--%.1f is not supported"%fValue)
            return False
        result = True
        command = "LINS%d%d:INPut:WAVelength %E"%(shelf, self._slot, fValue)
        self._session.send(command)

        command = "LINS%d%d:INPut:WAVelength?"%(shelf, self._slot)
        self._session.send(command)

        output = self._session.output.strip()
        strTemp = '%E'%fValue
        strTemp = strTemp[:-2] + "0" + strTemp[-2:]
        #matchobj = re.search(strTemp, output.strip())
        if output.strip() == strTemp:
            print("set VOA WAVelength successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set VOA WAVelength not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            result = False

        return result

    def setVOAAPMode(self, strAPMode):
        if strAPMode.upper() != "ABSOLUTE" and strAPMode.upper() != "XB" and strAPMode.upper() != "REFERENCE":
            print("the AP mode--%s is not supported"%strAPMode)
            return False
        result = True
        command = "LINS%d%d:OUTPut:APMode %s"%(shelf, self._slot, strAPMode)
        self._session.send(command)

        command = "LINS%d%d:OUTPut:APMode?"%(shelf, self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == strAPMode.upper():
            print("set VOA AP mode successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set VOA AP mode not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            result = False

        return result

    def setVOAState(self, strMode):
        dictVOAState = {"ON": "1", "OFF": "0"}
        if strMode.upper() != "ON" and strMode.upper() != "OFF":
            print("the VOA mode--%s is not supported"%strMode)
            return False
        result = True
        command = "LINS%d%d:OUTPut:STATe %s"%(shelf, self._slot, strMode)
        self._session.send(command)

        command = "LINS%d%d:OUTPut:STATe?"%(shelf, self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == dictVOAState[strMode.upper()]:
            print("set VOA mode successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set VOA mode not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            result = False

        return result

    def setEtherIntAllLaneStatus(self, strMode):
        dictEtherIntAlarmAllLaneStatus = {"ON": "1", "OFF": "0"}
        if strMode.upper() != "ON" and strMode.upper() != "OFF":
            print("the Ethernet Interface All Lane Status--%s is not supported"%strMode)
            return False
        command = "LINS%s:SOUR:DATA:TELecom:OPTical:ALARm:PORT:ALANes %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TELecom:OPTical:ALARm:PORT:ALANes?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == dictEtherIntAlarmAllLaneStatus[strMode.upper()]:
            print("the Ethernet Interface All Lane Status successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("the Ethernet Interface All Lane Status not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True


    def setEtherIntAlarm(self, strMode):
        dictEtherIntAlarm = {"ON": "1", "OFF": "0"}
        if strMode.upper() != "ON" and strMode.upper() != "OFF":
            print("the Ethernet Interface Alarm --%s is not supported"%strMode)
            return False
        command = "LINS%s:SOUR:DATA:TEL:OPT:ALAR:PORT %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TEL:OPT:ALAR:PORT?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == dictEtherIntAlarm[strMode.upper()]:
            print("the Ethernet Interface Alarm successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("the Ethernet Interface Alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True

    def setEtherPhyAlarm(self, strMode):
        if strMode.upper() != "LDOWN" and strMode.upper() != "LFAULT" and strMode.upper() != "RFAULT":
            print("the Ethernet PHYS Alarm --%s is not supported"%strMode)
            return False

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYS:TYPE %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYS:TYPE?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == strMode:
            print("the Ethernet PHYS Alarm successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("the Ethernet PHYS Alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True

    def enableEtherPhyAlarm(self, strMode):
        dictEtherIntAlarm = {"ON": "1", "OFF": "0"}
        if strMode.upper() != "ON" and strMode.upper() != "OFF":
            print("enable Ethernet PHYS Alarm --%s is not supported"%strMode)
            return False
        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYS %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYS?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == dictEtherIntAlarm[strMode.upper()]:
            print("enable Ethernet PHYS Alarm successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("enable Ethernet PHYS Alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True

    def set10GEtherPhyAlarm(self, strMode):
        if strMode.upper() != "LDOWN" and strMode.upper() != "LFAULT" and strMode.upper() != "RFAULT" and \
            strMode.upper() != "LFAULTRECIEVED" and strMode.upper() != "LFAULTDETECTED":
            print("the 10G Ethernet LRATe Alarm --%s is not supported"%strMode)
            return False

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:LRATe:TYPE %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:LRATe:TYPE?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == strMode:
            print("the Ethernet LRATe Alarm successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("the Ethernet LRATe Alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True

    def set100GEtherPhyAlarm(self, strMode):
        if strMode.upper() != "LDOWN" and strMode.upper() != "LFAULT" and strMode.upper() != "RFAULT" and \
            strMode.upper() != "LFAULTRECIEVED" and strMode.upper() != "LFAULTDETECTED":
            print("the 10G Ethernet PHYSical Alarm --%s is not supported"%strMode)
            return False

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYSical:TYPE %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYSical:TYPE?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == strMode:
            print("the Ethernet PHYSical Alarm successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("the Ethernet PHYSical Alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True

    def enable10GEtherPhyAlarm(self, strMode):
        dictEtherIntAlarm = {"ON": "1", "OFF": "0"}
        if strMode.upper() != "ON" and strMode.upper() != "OFF":
            print("enable Ethernet LRATe Alarm --%s is not supported"%strMode)
            return False
        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:LRATe %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:LRATe?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == dictEtherIntAlarm[strMode.upper()]:
            print("enable Ethernet LRATe Alarm successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("enable Ethernet LRATe Alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True

    def enable100GEtherPhyAlarm(self, strMode):
        dictEtherIntAlarm = {"ON": "1", "OFF": "0"}
        if strMode.upper() != "ON" and strMode.upper() != "OFF":
            print("enable Ethernet PHYSical Alarm --%s is not supported"%strMode)
            return False
        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYSical %s"%(self._slot, strMode)
        self._session.send(command)

        command = "LINS%s:SOUR:DATA:TEL:ETH:ALAR:PHYSical?"%(self._slot)
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == dictEtherIntAlarm[strMode.upper()]:
            print("enable Ethernet PHYSical Alarm successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("enable Ethernet PHYSical Alarm not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True


    def setETHernetPhyType(self, strPhyType):
        ''' to set Phy Type on ethernet interface
        @type strPhyType: string
        @param strPhyType: SR4 | CLR4 | CWDM4 | OTHERS
        '''
        assert (strPhyType in ["SR4", "CLR4", "CWDM4", "OTHERS"]),"parameter should be SR4|CLR4|CWDM4|OTHERS"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:ETH:PHY:TYPE " +  strPhyType
        self._session.send(command)

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:ETH:PHY:TYPE?"
        self._session.send(command)

        output = self._session.output.strip()

        if output.strip() == strPhyType.upper():
            print("set Ethernet Phy Type successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set Ethernet Phy Type not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return True

    def getETHernetPhyType(self):
        ''' to set Phy Type on ethernet interface
        @type strPhyType: string
        @param strPhyType: SR4 | CLR4 | CWDM4 | OTHERS
        '''

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:ETH:PHY:TYPE?"
        self._session.send(command)

        output = self._session.output.strip()

        if output in ["SR4", "CLR4", "CWDM4", "OTHERS"]:
            print("set Ethernet Phy Type successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set Ethernet Phy Type not successfully on module: " + str(self.shelf) + " " + str(self._slot) + ". Actually value is--" + output)
            return False

        return output


    def startInjectFCBer(self,num,typ="AUTOMATED"):
        ''' to trigger B3/B2/B1 errors by MANUAL or AUTOMATED,when using MANUAL, it will trigger amount of errors.when using AUTOMATED,it will trigger errors continuously with a rate
        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50.when using AUTOMATED,it's a rate like 4.0E-07 or MIN|MAX|DEF
        @type typ: string
        @param: MANUAL|AUTOMATED
        @rtype: Boolean
        @return: True|False

        '''
        typ = str(typ)
        assert(typ in ["MANUAL", "AUTOMATED", "MAXRATE"]), "inject Ber,please choose MANUAL|AUTOMATED for the third parameter,MANUAL means manully injecting errors by number, AUTOMATED means contineously injecting errors by rate"

        num = str(num)
        r= re.compile('.{3}E-0.{1}')

        assert (num in ["MAX","MIN","MAXIMUM", "MINIMUM","DEF"] or r.match(num) or int(num) in range(1,51)),"Please choose the correct value for the second parameter, if MANUAL type choosed, please use a number between 1 to 50, if AUTOMATED type choosed,please set the second parameter with a rate like 4.0E-06 or MIN|MAX|DEF" + ":  " + str(num)

        result = True
        if "MANUAL" == typ:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated OFF"
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:MANual:TYPE BIT"
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error type as BIT successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error type as BIT not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:MANual:TYPE?"
            self._session.send(command)
            output = self._session.output.strip()
            if "BIT" == output:
                print("retrieved error type as BIT successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error type as BIT not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AMOunt " + str(num)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AMOunt?"
            self._session.send(command)
            output = self._session.output.strip()
            if str(num) == output:
                print("retrieved  error amount=" + str(num) + " successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:INJect"
            self._session.send(command)
            output = self._session.output.strip()

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("Inject error amount=" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("Inject error amount=" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

        elif "AUTOMATED" == typ:

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated OFF"
            self._session.send(command)


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:TYPE BIT"
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error type as BIT successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error type as BIT not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:TYPE?"
            self._session.send(command)
            output = self._session.output.strip()
            if "BIT" == output:
                print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:CONTinuous OFF"
            self._session.send(command)


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:RATE " + str(num)
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error rate =" + str(num) + " successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error rate =" + str(num) + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:CONTinuous ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set automated continuous ON successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:CONTinuous?"
            self._session.send(command)
            output = self._session.output.strip()
            if "1" == output:
                print("retrieved automated continuous successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved automated continuous not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False
        else:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated OFF"
            self._session.send(command)


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:TYPE BIT"
            self._session.send(command)
            output = self._session.output

            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set error type as BIT successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("set error type as BIT not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:TYPE?"
            self._session.send(command)
            output = self._session.output.strip()
            if "BIT" == output:
                print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated OFF"
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated:CONTinuous ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                result = False

        return result

    def stopInjectFCBer(self,typ="AUTOMATED"):
        ''' to stop bit errors triggering,normally it means AUTOMATED continuous triggering stopped,when triggering ber errors by MANUAL, we don't need this proc since it's one time operation
        @type typ: string
        @param: AUTOMATED
        @rtype: Boolean
        @return: True|False

        '''
        typ = str(typ)
        assert(typ in ["AUTOMATED", "MAXRATE"]), "stop inject sonet Ber,please choose AUTOMATED only or don't set the second parameter,only automated continuous need to stop injection errors,for MANUAL, it's a one time command"

        if "AUTOMATED" == typ:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated?"
            self._session.send(command)
            output = self._session.output.strip()
            if "1" == output:
                print("Automated is running now,you can stop now: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("it's not automated continuous error injection currently, don't need to stop it: " + str(self.shelf) + " " + str(self._slot) + output + ", you may need to check your testing logic")


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated OFF"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
                return True
            else:
                print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                return False
        else:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated?"
            self._session.send(command)
            output = self._session.output.strip()
            if "1" == output:
                print("Automated is running now,you can stop now: "+ str(self.shelf) + " " + str(self._slot))
            else:
                print("it's not automated continuous error injection currently, don't need to stop it: " + str(self.shelf) + " " + str(self._slot) + output + ", you may need to check your testing logic")


            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:PATTern:ERRor:PATTern:AUTomated OFF"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("enabled automated error successfully on module: " + str(self.shelf) + " " + str(self._slot))
                return True
            else:
                print("enabled automated error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                return False



    def startInjectInterfaceAlarm(self,strAlarmType,listLane="ALLLANE"):
        ''' interface layer support alarm -- LOS
        @type strAlarmType: string
        @param: strAlarmType should be LOS
        @type listLane: list
        @param: list element should be 0|1|2|3
        @rtype: Boolean
        @return: True|False

        '''
        assert(strAlarmType in ["LOS"]), "strAlarmType should be alarm -- LOS"
        # for laneIndex in listLane:
            # assert(laneIndex in [0,1,2,3]), "list element of listLane should be 1|2|3|4"
        strProtocol = self.getIfProtocol()
        if strProtocol in ["LANE4X10", "LANE4X25"]:
            lAllLane = range(0,4)
        elif "LANE10X10" == strProtocol:
            lAllLane = range(0,10)
        else:
            pass
        if strProtocol in ["LANE4X10", "LANE4X25", "LANE10X10"]:
            if "ALLLANE" == listLane:
                listLane = lAllLane
            else:
                for laneIndex in listLane:
                    assert(laneIndex in lAllLane), "list element of listLane should be %s"%lAllLane
        result = True

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT?"
        self._session.send(command)
        output = self._session.output.strip()
        if "0" == output:
            print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT OFF"
            self._session.send(command)
            # result = False

        if strProtocol in ["LANE4X10", "LANE4X25", "LANE10X10"]:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TELecom:OPTical:ALARm:PORT:ALANes OFF"
            self._session.send(command)

            if len(lAllLane) == len(listLane) and len(lAllLane) == len(list(set(listLane).intersection(set(lAllLane)))):
                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TELecom:OPTical:ALARm:PORT:ALANes ON"
                self._session.send(command)
                output = self._session.output

                matchobj = re.search(r'.*ommand executed successfully', output)
                if matchobj:
                    print("set error type as BIT successfully on module: " + str(self.shelf) + " " + str(self._slot))
                else:
                    print("set error type as BIT not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                    result = False
            else:
                for laneIndex in listLane:
                    command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT:LANE " + str(laneIndex) + ", ON"
                    self._session.send(command)
                    output = self._session.output

                    matchobj = re.search(r'.*ommand executed successfully', output)
                    if matchobj:
                        print("set error type as BIT successfully on module: " + str(self.shelf) + " " + str(self._slot))
                    else:
                        print("set error type as BIT not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                        result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT ON"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set error type as BIT successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("set error type as BIT not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT?"
        self._session.send(command)
        output = self._session.output.strip()
        if "1" == output:
            print("retrieved error type as BERROR successfully on module: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("retrieved error type as BERRor not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            result = False

        return result

    def stopInjectInterfaceAlarm(self,strAlarmType):
        ''' to stop bit errors triggering,normally it means AUTOMATED continuous triggering stopped,when triggering ber errors by MANUAL, we don't need this proc since it's one time operation
        @type strAlarmType: string
        @param: strAlarmType should be LOS
        @rtype: Boolean
        @return: True|False

        '''
        assert(strAlarmType in ["LOS"]), "strAlarmType should be alarm -- LOS"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT?"
        self._session.send(command)
        output = self._session.output.strip()
        if "1" == output:
            print("Automated is running now,you can stop now: "+ str(self.shelf) + " " + str(self._slot))
        else:
            print("it's not automated interface error injection currently, don't need to stop it: " + str(self.shelf) + " " + str(self._slot) + output + ", you may need to check your testing logic")


        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OPTical:ALARm:PORT OFF"
        self._session.send(command)
        output = self._session.output.strip()
        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("stop injecting interface error successfully on module: " + str(self.shelf) + " " + str(self._slot))
        else:
            print("stop injecting not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
            return False
        strProtocol = self.getIfProtocol()
        if strProtocol in ["LANE4X10", "LANE4X25", "LANE10X10"]:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TELecom:OPTical:ALARm:PORT:ALANes OFF"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("stop injecting interface error successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                print("stop injecting not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)
                return False

        return True

    def getApplication(self):
        ''' set module interface to specific protocol
        @rtype: None or str
        @return: None|Application type(str)
        '''
        #assert (application in ["OTNBERT","SONETSDHBERT","EBERT","FCBERT"]),"The interface protocol should be one of OTNBER|SONETSDHBERT|EBERT|FCBERT"
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:TEST:TYPE?"
        self._session.send(command)
        time.sleep(10)
        output = self._session.output.strip()
        if output in ["OTNBERT","SONETSDHBERT","EBERT","FCBERT"]:
            return output
        else:
            print("get Application failed: unkown Application type -- %s"%output)
            return None

    def enableEthOversizeMonitoring(self):
        ''' enable ethernet oversize Monitoring
        @rtype: Boolean
        @return: True|False
        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:MAC:OVERsize ON"
        self._session.send(command)
        # time.sleep(10)
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:ERRor:MAC:OVERsize?"
        self._session.send(command)
        output = self._session.output.strip()
        if output == 1:
            return True
        else:
            print("enable ethernet oversize monitoring failed: unkown Application type -- %s"%output)
            return False

    def setEthFrameSize(nLength):
        ''' set ethernet package length
        @rtype: Boolean
        @return: True|False
        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:STReam:FRAMe:SIZE 1, %d"%nLength
        self._session.send(command)
        # time.sleep(1)

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:STReam:FRAMe:SIZE? 1"
        self._session.send(command)
        output = self._session.output.strip()
        if int(output) == nLength:
            return True
        else:
            print("get ethernet frame size failed: unkown Application type -- %s"%output)
            return False

    def setEthTrafficDstMacAddr(strDstMacAddr):
        ''' set ethernet package length
        @rtype: Boolean
        @return: True|False
        '''
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:STReam:ADDRess:DESTination 1, %d"%strDstMacAddr
        self._session.send(command)
        # time.sleep(1)

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:STReam:ADDRess:DESTination? 1"
        self._session.send(command)
        output = self._session.output.strip()
        if int(output) == strDstMacAddr:
            return True
        else:
            print("set ethernet traffic destination mac address failed: unkown Application type -- %s"%output)
            return False

    def getEthPortTrafficDetail(self):
        '''MULTicast BROadcast UNIcast FTOtal'''
        dictTrafficDetail = dict()
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:FRAMe:COUNt:TX? FTOtal"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_PACKAGE_TOTAL"] = int(float(output))

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:FRAMe:COUNt:TX? UNIcast"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_PACKAGE_UNICAST"] = int(float(output))

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:FRAMe:COUNt:TX? BROadcast"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_PACKAGE_BROADCAST"] = int(float(output))

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:FRAMe:COUNt:TX? MULTicast"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_PACKAGE_MULTICAST"] = int(float(output))

        command = "LINS" + str(self._slot) + ":SENSe:DATA:TELecom:ETHernet:FRAMe:COUNt:RX? FTOtal"
        self._session.send(command)
        output = self._session.output.strip()
        dictTrafficDetail["RX_PACKAGE_TOTAL"] = int(float(output))

        command = "LINS" + str(self._slot) + ":SENSe:DATA:TELecom:ETHernet:FRAMe:COUNt:RX? UNIcast"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["RX_PACKAGE_UNICAST"] = int(float(output))

        command = "LINS" + str(self._slot) + ":SENSe:DATA:TELecom:ETHernet:FRAMe:COUNt:RX? BROadcast"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["RX_PACKAGE_BROADCAST"] = int(float(output))

        command = "LINS" + str(self._slot) + ":SENSe:DATA:TELecom:ETHernet:FRAMe:COUNt:RX? MULTicast"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["RX_PACKAGE_MULTICAST"] = int(float(output))

        for key in dictTrafficDetail.keys():
            print("%s port %s %s:%s"%(self._session._host, self._slot, key, dictTrafficDetail[key]))
        # print(dictTrafficDetail)
        return dictTrafficDetail


    def getFCPortTrafficDetail(self):
        '''MULTicast BROadcast UNIcast FTOtal'''
        dictTrafficDetail = dict()
        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:FRAMe:COUNt? TX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_PACKAGE_TOTAL"] = int(float(output))

        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:FRAMe:COUNt? RX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["RX_PACKAGE_TOTAL"] = int(float(output))


        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:FRAMe:RATE? TX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_PACKAGE_RATE"] = float(output)

        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:FRAMe:RATE? RX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["RX_PACKAGE_RATE"] = float(output)



        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:BYTE:COUNt? TX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_BYTE_TOTAL"] = int(float(output))

        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:BYTE:COUNt? RX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["RX_BYTE_TOTAL"] = int(float(output))


        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:LINE:UTILization? TX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["TX_LINE_UTILIZATION"] = float(output)

        command = "LINS" + str(self._slot) + ":FETCh:DATA:TELecom:FIBer:STReam:LINE:UTILization? RX"
        self._session.send(command)
        output = self._session.output.strip()

        dictTrafficDetail["RX_LINE_UTILIZATION"] = float(output)

        for key in dictTrafficDetail.keys():
            print("%s port %s %s:%s"%(self._session._host, self._slot, key, dictTrafficDetail[key]))
        # print(dictTrafficDetail)
        return dictTrafficDetail


    def setEthTrafficTx(self, strStatus):
        dictStatus = {"ON":1, "OFF":0}
        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:STReam:TX:STATus %s"%strStatus
        self._session.send(command)
        output = self._session.output.strip()

        command = "LINS" + str(self._slot) + ":SOURce:DATA:TELecom:ETHernet:STReam:TX:STATus?"
        self._session.send(command)
        output = self._session.output.strip()

        if int(output) == dictStatus[strStatus]:
            return True
        else:
            print("set ethernet Traffic Tx failed")
            return False

    def setFrameSizeType(self,flowid,type):
        '''' This command sets the frame size type.
        @type type: string
        @param type:FIXED,RANDOM,EMIX,SWEEP
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:FRAM:SIZE:TYPE " +  flowid + "," + type
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set frame size type " + type + " successfully on module:" + str(self._slot))
            return True
        else:
            print("Failed to set frame size type " + type + "on module:" + str(self._slot))
            return False

    def setFrameSize(self,size,flowid='1'):
        '''' This command sets the frame size.
        @type type:string
        @param size:
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:FRAM:SIZE " + flowid + "," + size
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set Ethernet frame size " + size + " successfully on module:" + str(self._slot))
            return True
        else:
            print("Failed to set Ethernet frame size " + size + "on module:" + str(self._slot))
            return False

    def getFrameSize(self,flowid='1'):
        '''' This command get the frame size.
        @type type:string
        @param size:
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:FRAM:SIZE? " + flowid
        self._session.send(command)
        output = self._session.output.strip()

        if output.isdigit():
            print("get Ethernet frame size successfully on module:" + str(self._slot))
            return int(output)
        else:
            print("Failed to set Ethernet frame size on module:" + str(self._slot))
            return False

    def setFrameRate(self,value):
        '''' This command sets the transmitter payload rate for the selected traffic payload type,
        this value is based on % of maxlimit .
        @type type:string
        @param size:
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:RATE " + value
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set Ethernet frame rate " + value + "% successfully on module:" + str(self._slot))
            return True
        else:
            print("Failed to set Ethernet frame rate " + value + "% on module:" + str(self._slot))
            return False


    def setEthDesMAC(self,mac,flowid="1"):
        ''''This command sets the Media Access Control (MAC) destination address.
        @mac:"XX:XX:XX:XX:XX:XX"
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:ADDR:DEST " + flowid + "," + mac
        self._session.send(command)
        output = self._session.output.strip()

        matchobj = re.search(r'.*ommand executed successfully', output)
        if matchobj:
            print("set the MAC destination address successful")
            return True
        else:
            print("Failed to set the MAC destination address")
            return False

    def getEthDesMAC(self,flowid="1"):
        ''''This command sets the Media Access Control (MAC) destination address.
        @mac:"XX:XX:XX:XX:XX:XX"
        '''
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:ETH:STR:ADDR:DEST? " + flowid
        self._session.send(command)
        output = self._session.output.strip().replace("\"", "")
        if re.match(r"^[0-9A-F]{2}(:[0-9A-F]{2}){5}$", output):
            print("get the MAC destination address successful")
            return output
        else:
            print("Failed to get the MAC destination address")
            return False


    def startInjectProtocolError(self,strErrorName, strErrorParam):
        ''' to set which alarm to be triggered on SONET|SDH|LINE|RES|SECTION|HOP...

        @type protocol: string
        @param protocol: SONET|SDH
        @type alarmLocation: string
        @param alarmLocation: RES|SECTION|LINE|HOP|OTU2|ODU2|OTU4|ODU4|OTU2E|ODU2E
        @type alarmName: string
        @param alarmName:if alarmLocation is SECTION,this should be LOF1|SEF1|TIMS. if alarmLocation is LINE,this should be AIS|RDI.if alarmLocation is HOP,this should be AIS|RDI|LOP|LOM|TIM|PLM|UNEQP1|PDI|EPSD1|EPCD1|EPPD1
        @rtype: Boolean
        @return: True|False

        '''
        if strErrorName in ["FCS"]:
            protocol = "ethernet"
            # 10GE location
            # strErrorLocation = "LRATe"
            # 40/100GE location
            strErrorLocation = "MAC"
        else:
            raise Exception("unknown Error type")
        strErrorParam = str(strErrorParam)
        if strErrorParam.isdigit():
            strInjectMode = "MANual"
        elif "MAXRATE" == strErrorParam:
            strInjectMode = "AUTomated:CONTinuous"
        else:
            strInjectMode = "AUTomated"

        if strInjectMode in ["AUTomated:CONTinuous", "AUTomated"]:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":" + "AUTomated" + ":TYPE?"
        else:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":" + "MANual" + ":TYPE?"
        self._session.send(command)
        output = self._session.output.strip()
        if (output == strErrorName):
            print("error = " + strErrorName + " has already been set up on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
        else:
            if strInjectMode in ["AUTomated:CONTinuous", "AUTomated"]:
                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":" + "AUTomated" + ":TYPE " + strErrorName
            else:
                command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":" + "MANual" + ":TYPE " + strErrorName
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("start to inject FCS successful")
            else:
                print("Failed to start to inject FCS")
                return False

        if "AUTomated:CONTinuous" == strInjectMode:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AUTomated:CONTinuous ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set alarm =" + strErrorName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
            else:
                print("set alarm =" + strErrorName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol + output)
                return False
        elif "AUTomated" == strInjectMode:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AUTomated:RATE " + strErrorParam
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set alarm =" + strErrorName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
            else:
                print("set alarm =" + strErrorName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol + output)
                return False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AUTomated ON"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set alarm =" + strErrorName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
            else:
                print("set alarm =" + strErrorName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol + output)
                return False
        else:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AMOunt " + strErrorParam
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set alarm =" + strErrorName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
            else:
                print("set alarm =" + strErrorName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol + output)
                return False

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":INJ"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set alarm =" + strErrorName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
            else:
                print("set alarm =" + strErrorName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol + output)
                return False
        return True

    def stopInjectProtocolError(self,strErrorName):
        ''' to set which alarm to be triggered on SONET|SDH|LINE|RES|SECTION|HOP...

        @type protocol: string
        @param protocol: SONET|SDH
        @type alarmLocation: string
        @param alarmLocation: RES|SECTION|LINE|HOP|OTU2|ODU2|OTU4|ODU4|OTU2E|ODU2E
        @type alarmName: string
        @param alarmName:if alarmLocation is SECTION,this should be LOF1|SEF1|TIMS. if alarmLocation is LINE,this should be AIS|RDI.if alarmLocation is HOP,this should be AIS|RDI|LOP|LOM|TIM|PLM|UNEQP1|PDI|EPSD1|EPCD1|EPPD1
        @rtype: Boolean
        @return: True|False

        '''
        if strErrorName in ["FCS"]:
            protocol = "ethernet"
            # 10GE location
            # strErrorLocation = "LRATe"
            # 40/100GE location
            strErrorLocation = "MAC"
        else:
            raise Exception("unknown Error type")

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AUTomated?"
        self._session.send(command)
        output = self._session.output.strip()

        if "1" == output:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AUTomated OFF"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set alarm =" + strErrorName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
                return True
            else:
                print("set alarm =" + strErrorName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol + output)
                return False


        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AUTomated:CONTinuous?"
        self._session.send(command)
        output = self._session.output.strip()
        if "1" == output:
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:"+protocol +":ERRor:" +  strErrorLocation + ":AUTomated:CONTinuous OFF"
            self._session.send(command)
            output = self._session.output.strip()
            matchobj = re.search(r'.*ommand executed successfully', output)
            if matchobj:
                print("set alarm =" + strErrorName + " successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol)
                return True
            else:
                print("set alarm =" + strErrorName + " not successfully on module: " + str(self.shelf) + " " + str(self._slot) + " " + strErrorLocation + " " + protocol + output)
                return False
        print("the inject status is already OFF")
        return True


    def setFCLogin(self, strStatus, strCredit=""):
        ''' setup FC login parameters
        @rtype: Boolean
        @return: True|False
        '''
        dictStatus = {"ON":"1", "OFF":"0"}
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:LOG:STAT %s"%strStatus
        self._session.send(command)
        # time.sleep(10)
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:LOG:STAT?"
        self._session.send(command)
        output = self._session.output.strip()
        if output == dictStatus[strStatus]:
            print("setup FC login status successed")
        else:
            print("setup FC login status failed: output fromw EXFO -- %s"%output)
            return False

        if "" != strCredit:
            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:ADV:BBCR %s"%strCredit
            self._session.send(command)

            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:ADV:BBCR?"
            self._session.send(command)
            output = self._session.output.strip()
            if output == strCredit:
                print("setup FC login ADVertised BBCRedit successed")
            else:
                print("setup FC login ADVertised BBCRedit failed: output fromw EXFO -- %s"%output)
                return False
        return True


    def setFCBuf2BufFlowCtrl(self, strStatus, strCredit=""):
        ''' setup FC login parameters
        @rtype: Boolean
        @return: True|False
        '''
        dictStatus = {"ON":"1", "OFF":"0"}
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:FCON:ENAB %s"%strStatus
        self._session.send(command)
        # time.sleep(10)
        command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:FCON:ENAB?"
        self._session.send(command)
        output = self._session.output.strip()
        if output == dictStatus[strStatus]:
            print("setup FC buffer to buffer flow control status successed")
        else:
            print("setup FC buffer to buffer flow control status failed: output fromw EXFO -- %s"%output)
            return False

        if "" != strCredit:
            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:AVA:BBCR %s"%strCredit
            self._session.send(command)

            command = "LINS" + str(self._slot) + ":SOUR:DATA:TEL:FIB:PORT:AVA:BBCR?"
            self._session.send(command)
            output = self._session.output.strip()
            if output == strCredit:
                print("setup FC buffer to buffer flow control AVAilable BBCRedit successed")
            else:
                print("setup FC buffer to buffer flow control AVAilable BBCRedit failed: output fromw EXFO -- %s"%output)
                return False
        return True


    def startInjectOTNError(self, protocol, layer, errorType, num):
        '''trigger OTN errors
        @type layer: string
        @param layer: OTU2|OTU2E|OTU4
        @type layer: string
        @param layer: OTU2|ODU2|OTU2E|ODU2E|OTU4|ODU4
        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50.when using AUTOMATED,it's a rate like 4.0E-07 or MIN|MAX|DEF
        @rtype: Boolean
        @return: True|False

        '''
        protocol = str(protocol)
        assert protocol in ["OTU2", "OTU2E", "OTU4"], "protocol ,please choose OTU2|OTU2E|OTU4 for the first parameter"

        layer = str(layer)
        assert layer in ["OTU2", "ODU2", "OTU2E", "ODU2E", "OTU4", "ODU4", "FEC"], "inject sonet|OTN Ber,please choose OTU2|ODU2|OTU2E|ODU2E|OTU4|ODU4 for the second parameter"

        num = str(num)
        r= re.compile('.{3}E-0.{1}')

        assert (num in ["MAX","MIN","MAXIMUM", "MINIMUM","DEF"] or r.match(num) or int(num) in range(1,51)),"Please choose the correct value for the second parameter, if MANUAL type choosed, please use a number between 1 to 50, if AUTOMATED type choosed,please set the second parameter with a rate like 4.0E-06 or MIN|MAX|DEF" + ":  " + str(num)

        # if "OBIP8" == layer:

            # errorLayer = "ODU2"
        # elif "B3" == layer:
            # errorLayer = "HOP:PATH"
        # elif "B2" == layer:
            # errorLayer = "LINE"
        # else:
            # errorLayer = "SECT"
        errorLayer = layer
        if "OTU2E" == errorLayer:
            errorLayer = "OTU2:E"
        elif "ODU2E" == errorLayer:
            errorLayer = "ODU2:E"

        # clear error
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT OFF"
        self._session.send(command)

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUTomated:CONTinuous OFF"
        self._session.send(command)

        if num.isdigit():
            # set manual error type
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":MANual:TYPE " + errorType
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":MANual:TYPE?"
            self._session.send(command)
            output = self._session.output
            if output.strip() == errorType:
                print("set error type as %s successfully on module: "%errorType + str(self.shelf) + " " + str(self._slot))
            else:
                raise Exception("set error type as %s not successfully on module: "%errorType + str(self.shelf) + " " + str(self._slot) + output)

            # set error amount
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AMOunt " + num
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AMOunt?"
            self._session.send(command)
            output = self._session.output
            if num in output.strip():
                print("set error amount as %s successfully on module: "%num + str(self.shelf) + " " + str(self._slot))
            else:
                raise Exception("set error amount as %s not successfully on module: "%num + str(self.shelf) + " " + str(self._slot) + output)

            # inject error
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":INJect"
            self._session.send(command)

        else:
            # set automated error type
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT:TYPE " + errorType
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT:TYPE?"
            self._session.send(command)
            output = self._session.output
            if output.strip() == errorType:
                print("set error type as %s successfully on module: "%errorType + str(self.shelf) + " " + str(self._slot))
            else:
                raise Exception("set error type as %s not successfully on module: "%errorType + str(self.shelf) + " " + str(self._slot) + output)

            # set error rate
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT:RATE " + num
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT:RATE?"
            self._session.send(command)
            output = self._session.output
            if "error" not in output.strip():
                print("set error rate as %s successfully on module: "%num + str(self.shelf) + " " + str(self._slot))
            else:
                raise Exception("set error rate as %s not successfully on module: "%num + str(self.shelf) + " " + str(self._slot) + output)

            # start to inject error
            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT ON"
            self._session.send(command)

            command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT?"
            self._session.send(command)
            output = self._session.output
            if output.strip() == "1":
                print("inject error successfully on module: " + str(self.shelf) + " " + str(self._slot))
            else:
                raise Exception("inject error not successfully on module: " + str(self.shelf) + " " + str(self._slot) + output)

    def stopInjectOTNError(self, protocol, layer, errorType):
        '''trigger OTN errors
        @type layer: string
        @param layer: OTU2|OTU2E|OTU4
        @type layer: string
        @param layer: OTU2|ODU2|OTU2E|ODU2E|OTU4|ODU4
        @type num: string
        @param num: when using MANUAL,it's Int range from 1 to 50.when using AUTOMATED,it's a rate like 4.0E-07 or MIN|MAX|DEF
        @rtype: Boolean
        @return: True|False

        '''
        protocol = str(protocol)
        assert protocol in ["OTU2", "OTU2E", "OTU4"], "protocol ,please choose OTU2|OTU2E|OTU4 for the first parameter"

        layer = str(layer)
        assert layer in ["OTU2", "ODU2", "OTU2E", "ODU2E", "OTU4", "ODU4", "FEC"], "inject sonet|OTN Ber,please choose OTU2|ODU2|OTU2E|ODU2E|OTU4|ODU4 for the second parameter"

        errorLayer = layer
        if "OTU2E" == errorLayer:
            errorLayer = "OTU2:E"
        elif "ODU2E" == errorLayer:
            errorLayer = "ODU2:E"

        # clear error
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUT OFF"
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOUR:DATA:TEL:OTN:ERR:"+ errorLayer + ":AUTomated:CONTinuous OFF"
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))

    def setBertDisruptionMonitoringStatus(self, strStatus):
        assert strStatus in ["ON", "OFF"], "Disruption Monitoring Status should be ON|OFF"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SENSe:DATA:TELecom:SDT "+ strStatus
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SENSe:DATA:TELecom:SDT?"
        self._session.send(command)
        output = self._session.output
        if not (("ON" == strStatus and "1" == output.strip()) or ("OFF" == strStatus and "0" == output.strip())):
            raise Exception("execute cmd %s on %s failed"%(self, command))
        return True


    def setFibrePspStatus(self, strStatus):
        assert strStatus in ["ON", "OFF"], "Disruption Monitoring Status should be ON|OFF"

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:FIBer:PSP "+ strStatus
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))

        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:FIBer:PSP?"
        self._session.send(command)
        output = self._session.output
        if not (("ON" == strStatus and "1" == output.strip()) or ("OFF" == strStatus and "0" == output.strip())):
            raise Exception("execute cmd %s on %s failed"%(self, command))
        return True


    def getOTUSMTTITracesExpected(self, strMode):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SENSe:DATA:TELecom:OTN:OTU4:TTI:%s:EXPected?"%strMode.upper()
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))
        
        return  output
        
    def setOTUSMTTITracesExpected(self, strMode, strValue):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SENSe:DATA:TELecom:OTN:OTU4:TTI:%s:EXPected %s"%(strMode.upper(), strValue)
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))
        
        return  True
        
        
    def getOTUSMTTITracesReceived(self, strMode):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:OTU4:SM:%s:B16?"%strMode.upper()
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))
        
        return  output
        
    def setOTUSMTTITracesReceived(self, strMode, strValue):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:OTU4:SM:%s:B16 %s"%(strMode.upper(), strValue)
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))
        
        return  True
        
        
    def getOTUSMTTITracesOperator(self, strMode):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:OTU4:SM:OPSPec:B32?"
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))
        
        return  output
        
    def setOTUSMTTITracesOperator(self, strValue):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SOURce:DATA:TELecom:OTN:OTU4:SM:OPSPec:B32 %s"%strValue
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))
        
        return  True

    def setOTUSMTTITracesStatus(self ,strMode, strStatus):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SENSe:DATA:TELecom:OTN:OTU4:TTI:TIM %s, %s"%(strMode, strStatus)
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))
        
        return  True

    def getOTUSMTTITracesStatus(self, strMode):
        command = "LINS" + str(self.shelf) + str(self._slot) + ":SENSe:DATA:TELecom:OTN:OTU4:TTI:TIM? %s"%strMode
        self._session.send(command)
        output = self._session.output
        if "error" in output:
            raise Exception("execute cmd %s on %s failed"%(self, command))

        if "1" == output.strip():
            return "ON"
        elif "0" == output.strip():
            return "OFF"
        else:
            raise Exception("execute cmd %s on %s failed"%(self, command))
