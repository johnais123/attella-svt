import logging
import pexpect
import string
import time
import re


class PowerModule():
    '''
    Creates a switched Rack Power Distribution Unit Session.  Use this session to talk to the
    switched Rack Power Distribution Unit test set.
    '''
    ROBOT_LIBRARY_SCOPE = "GLOBAL" 

    def __init__(self, address, username="admn", password="admn", timeout=30):
        '''
        The Power management address and username and password are used to create a ssh session

        @type address: ip address string
        @param address: ip address
        @type port: string
        @param port: default as 22
        @type username: string
        @param username: default ""
        @type timeout: string
        @param timeout: timeout seconds
        @type logfile: string
        @param logfile: log file name for this act session
        '''
        self._address = address
        self._username = username
        self._password = password
        self._port = 23
        self._timeout = str(timeout)
        self._child = None
        self.output = ""

    def _waitForPrompt(self):
        '''
        Wait for the Act prompt to be returned from the target.  Accumulate any
        text returned from the target in the output member.  Returns False if
        there was a timeout or EOF.
        '''

        rc = True
        patterns = [r'.*Switched -48 VDC:',
                    r'.*Password: ',
                    r'.*Username: ',
                    pexpect.EOF,
                    pexpect.TIMEOUT]
        i_tmo = len(patterns) - 1
        i_eof = len(patterns) - 2
        i_user = len(patterns) - 3
        i_pwd = len(patterns) - 4
        i_pmt = len(patterns) - 5
        done = False

        while not done and rc:
            i = self._child.expect(patterns, timeout=int(self._timeout))
            if i == i_pmt:      # prompt
                self.output += str(self._child.before) + str(self._child.after)
                done = True
                rc= True
            elif i == i_pwd:    # password
                self.output += str(self._child.before) + str(self._child.after)
                #self._child.send('%s\n' % self._password)
                done = True
            elif i == i_user:    # username
                self.output += str(self._child.before) + str(self._child.after)
                #self._child.send('%s\n' % self._password)
                done = True                
            elif i == i_eof:    # EOF
                self.output += str(self._child.before)
                rc = False
            elif i == i_tmo:    # TIMEOUT
                self.output += str(self._child.before)
                rc = False
            else:
                print (str(self._child.before))

        return rc

    #----------------------------------------------------------------- sendCommand
    def send(self, commands):
        '''
        Sends the Act commands to the target.  The 'command' parameter is a list
        of commands to be sent.  The combined output is stored in the output
        member, which can be searched using the search() and contains() methods.

        @type commands: list
        @param commands: list of commands to send
        @rtype: string
        @return: session output
        '''
        # try: 
            # junk = self._child.read_nonblocking(size=10000,timeout=2)
        # except pexpect.TIMEOUT, e: 
            # pass

        self.output = ""

        for c in commands:
            if len(c):
                if c[-1] != '\n': c += '\n'
                self._child.send(c)
                self._waitForPrompt()
        '''
        print 'output:   ' + self.output
        '''
        return self.output

    #---------------------------------------------------------------------- _spawn
    def _spawn(self):
        '''
        Spawns a child process to handle the interaction with the target.
        '''
        self._child = pexpect.spawn('telnet 172.27.90.188')
            # ['-o StrictHostKeyChecking=no','-o ConnectTimeout=%s'%self._timeout, '-p', str(self._port), '%s@%s' % (self._username, self._address) ])
        self._waitForPrompt()
        self.sendlogin(self._username)
        self.sendPassword(self._password)

    def sendlogin(self, usename):
        if re.search('.*Username: ', str(self.output)):
            self.send(['%s\n' % usename])
        else:
            raise Exception('username prompt not found in output')
            
    def sendPassword(self, password):
        if re.search('.*Password: ', str(self.output)):
            sRestle = self.send(['%s\n' % password])
        else:
            raise Exception('password prompt not found in output')
            
    #----------------------------------------------------------------------- open
    def open(self):
        '''
        Open a connection to the target (if not already).
        '''
        opencount = 1
        while (opencount < 20):
           
           if not self.isOpen():  
               self._spawn()
              
           if self.isOpen():             
               opencount = 50
           else:           
               opencount = opencount + 1
               time.sleep (2)

    #----------------------------------------------------------------------- close
    def close(self):
        '''
        Close the session (if not already).
        '''
        if self._child.isalive():
            self._child.close()

        return not self._child.isalive()

    #---------------------------------------------------------------------- isOpen
    def isOpen(self):
        '''
        Return true if the session is open.
        @rtype: boolean
        @return: True if the session is open, False otherwise
        '''
        #return self._child.isalive()
        return self._child != None
        
    def get_Outlets_List(self):
        strResult = self.send(["list outlets"])
        outletsList = list()
        for sLine in strResult.split("\n"):
            outletIdTemp = re.split(r" {2,}", sLine.strip())[0]
            if re.match(r"\.A\d", outletIdTemp):
                outletsList.append(outletIdTemp)
        return outletsList
        
    def get_Outlet_Ctrl_State(self, nOutletID):
        time.sleep(5)
        strResult = str(self.send(["status"]))
        for sLine in strResult.split("\\r\\n"):
            outletIdTemp = re.split(r" {2,}", sLine.strip())[0]
            if ".A%s"%str(nOutletID) == outletIdTemp:
                return re.split(r" {2,}", sLine.strip())[4]
        return False
                
    def get_Outlet_State(self, nOutletID):
        time.sleep(20)    
        strResult = str(self.send(["status"]))
        for sLine in strResult.split("\\r\\n"):
            outletIdTemp = re.split(r" {2,}", sLine.strip())[0]
            if ".A%s"%str(nOutletID) == outletIdTemp:
                return re.split(r" {2,}", sLine.strip())[2]
        return False
        
    def set_Outlet_Ctrl_State(self, nOutletID, strState):
        self.send(["%s .A%s"%(strState, str(nOutletID))]) 
        if strState.upper() == str(self.get_Outlet_Ctrl_State(nOutletID)).upper():
            print ("Configure power status to %s"%strState.upper())
            print ("Real power control status is :")
            print (str(self.get_Outlet_Ctrl_State(nOutletID)).upper())
        else:
            raise Exception("set Outlet Ctrl State failed")
        if strState.upper() == str(self.get_Outlet_State(nOutletID)).upper():
            print ("Configure power status to %s"%strState.upper())
            print ("Real power status is :")
            print (str(self.get_Outlet_State(nOutletID)).upper())
            return True
        else:
            raise Exception("Outlet State does not match the configuration")