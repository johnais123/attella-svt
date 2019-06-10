from ncclient import manager

from ncclient.operations.subscribe import *
from ncclient.operations import RaiseMode

from ncclient.xml_ import *

import time
import xml.etree.ElementTree as ET

import re

TARGET_DB_RUNNING = "running"
TARGET_DB_CANDIDATE = "candidate"
TARGET_DB_STARTUP = "startup"



class openRoadmDevice():
    def __init__(self, strHost, strUsername, strPassword, nPort = 830, nTimeout = 30):
        self.HOST = strHost
        self.PORT = nPort
        self.NETCONFUSER = strUsername
        self.NETCONFPWD = strPassword
        self.TIMEOUT = nTimeout
        self.session = None
    
    def __requireSessionOpen(func):
        def new(*args):
            print("start to run func %s"%func.__name__)
            if args[0].session == None:
                print("the session has not been open yet")
                raise Exception("the session has not been open yet")
            elif not args[0].session.connected:
                print("the session is opened before but not connected now")
                raise Exception("the session is opened before but not connected now") 
            return func(*args)
        return new
    def __judgeRpcReply(func):
        def new(*args):
            ret = func(*args)
            if ret.ok:
                return ret
            else:
                print("error in rpc reply. error message is %s"%str(ret.errors))
                raise("error in rpc reply. error message is %s"%str(ret.errors))
        return new
        
    
    def open_session(self):
        if self.session == None:
            try:
                self.session = manager.connect(host=self.HOST,
                                         port=self.PORT,
                                         username=self.NETCONFUSER,
                                         password=self.NETCONFPWD,
                                         timeout=self.TIMEOUT,
                                        hostkey_verify=False)
            except Exception as ex:
                print(ex)
                raise ex
                
        elif not self.session.connected:
            print("the session is opened before but not connected now")
        else:
            print("the session is already connected")
            raise Exception("can't open the session for the session is already connected")

    def close_session(self):
        if self.session == None:
            print("the session has not been open yet")
        elif not self.session.connected:
            print("the session is opened before but not connected now")
        else:
            self.session.close_session()
            self.session = None
    @__requireSessionOpen
    def getServerCapabilities(self):
        return self.session.server_capabilities
    @__requireSessionOpen
    def getClientCapabilities(self):
        return self.session.client_capabilities
        
    # <get-config> Retrieve all or part of a specified configuration.
    # <get> Retrieve running configuration and device state information.
    @__judgeRpcReply
    @__requireSessionOpen
    def getConfig(self, strTargetDB=TARGET_DB_RUNNING, strFilter=None):
        return self.session.get_config(strTargetDB, strFilter)
    @__judgeRpcReply
    @__requireSessionOpen
    def copyConfig(self, strSrcTargetDB, strDstURL):
        self.session.copy_config(strSrcTargetDB, strDstURL)
    @__judgeRpcReply
    @__requireSessionOpen
    def editConfig(self, strTargetDB, strConfig):
        self.session.edit_config(strTargetDB, strConfig)
        
    # delete_config(target)
    # Delete a configuration datastore.
    # target specifies the name or URL of configuration datastore to delete
    @__judgeRpcReply
    @__requireSessionOpen
    def deleteConfig(self, strTargetDB):
        self.session.deleteConfig(strTargetDB)
    @__judgeRpcReply
    @__requireSessionOpen
    def sendRpcCmd(self, strRpcCmd, strSrc=None, strFilter=None):
        return self.session.dispatch(strRpcCmd, strSrc, strFilter)
    @__judgeRpcReply
    @__requireSessionOpen
    def lockDB(self, strTargetDB):
        return self.session.lock(strTargetDB)
        
    @__judgeRpcReply
    @__requireSessionOpen
    def unlockDB(self, strTargetDB):
        return self.session.unlock(strTargetDB)
        
    # Commit the candidate configuration as the device's new current configuration.
    # Depends on the :candidate capability.
    # commit(confirmed=False, timeout=None, persist=None)
    @__judgeRpcReply
    @__requireSessionOpen
    def commitProvision(self):
        return self.session.commit()
        
    @__judgeRpcReply
    @__requireSessionOpen 
    def discardChanges(self):
        return self.session.discard_changes()
        
    # validate(source)
    # Validate the contents of the specified configuration.

    # source is the name of the configuration datastore being validated or config element containing the configuration subtree to be validated
    @__judgeRpcReply
    @__requireSessionOpen
    def validateDB(self, strTargetDB):
        return self.session.validate(strTargetDB)
    
    # @__judgeRpcReply
    # @__requireSessionOpen
    def createSubscription(self):
        subscription = CreateSubscription(
            self.session._session,
            self.session._device_handler)
        return subscription.request(stream_name="NETCONF")
    
    def takeNotification(self, iTimeout):
        return self.session.take_notification(timeout=iTimeout)

# def getNetconfClientHandle(strHost, strUsername="root", strPassword="Embe1mpls"):
    # return openRoadmDevice(strHost, strUsername, strPassword)

    
def ncHandleInit(strHost, strUsername, strPassword):
    ncHandle = openRoadmDevice(strHost, strUsername, strPassword)
    ncHandle.open_session()
    ncHandle.createSubscription()
    return ncHandle
    
def ncHandleDestory(ncHandle):
    ncHandle.close_session()
    
def wait4ExpectedNotifications(ncHandle, listNotifications, timeout=60):
    ret = False
    # ncHandle = getNetconfClientHandle(strHost)
    # ncHandle.open_session()
    # ncHandle.createSubscription()
    t0 = time.time()
    lReceivedNotifications = []
    lNotifications = []
    while time.time() - t0 < float(timeout):
        notification = ncHandle.takeNotification(10)
        if notification:
            lNotifications.append(notification)
    print("JMC Number of notificaions %s"%len(lNotifications))
    for notification in lNotifications:
        print("JMC notifications %s"%notification.notification_xml)
        for listNotify in listNotifications:
            if "alarm-notification" == listNotify[0]:
                print("JMC Alarm notification found %s %s"%(listNotify[1], listNotify[2]))
                print("JMC Number of expected notifcations %s"%len(listNotifications))
                print("JMC Number of expected params %s"%len(listNotify))
                if 3 == len(listNotify):
                    #if re.match("%s"%ALARM_NOTIFICATION(listNotify[1], listNotify[2]), re.sub(r"\n *", "", notification.notification_xml)):
                    if listNotify[1] in notification.notification_xml and listNotify[2] in notification.notification_xml:
                        print("the expected notification received!")
                        lReceivedNotifications.append(listNotify)
                        break
                elif 4 == len(listNotify):
                    #if re.match("%s"%ALARM_NOTIFICATION(listNotify[1], listNotify[2], listNotify[3]), re.sub(r"\n *", "", notification.notification_xml)):
                    if listNotify[1] in notification.notification_xml and listNotify[2] in notification.notification_xml and listNotify[3] in notification.notification_xml:
                        print("the expected notification received!")
                        lReceivedNotifications.append(listNotify)
                        break
            elif "db-backup-notification" == listNotify[0]:
                pass
            elif "transfer-notification" == listNotify[0]:
                if re.match("%s"%TRANSFER_NOTIFICATION(listNotify[1], listNotify[2]), re.sub(r"\n *", "", notification.notification_xml)):
                    print("the expected notification received!")
                    lReceivedNotifications.append(listNotify)
                    break
            elif "db-restore-notification" == listNotify[0]:
                pass
            elif "sw-stage-notification" == listNotify[0]:
                if re.match("%s"%SW_STAGE_NOTIFICATION(listNotify[1], listNotify[2]), re.sub(r"\n *", "", notification.notification_xml)):
                    print("the expected notification received!")
                    lReceivedNotifications.append(listNotify)
                    break
            elif "sw-activate-notification" == listNotify[0]:
                if re.match("%s"%SW_ACTIVATE_NOTIFICATION(listNotify[1], listNotify[2]), re.sub(r"\n *", "", notification.notification_xml)):
                    print("the expected notification received!")
                    lReceivedNotifications.append(listNotify)
                    break
            elif "historical-pm-collect-result" == listNotify[0]:
                if re.match("%s"%HISTORICAL_PM_COLLECT_RESULT(listNotify[1]), re.sub(r"\n *", "", notification.notification_xml)):
                    print("the expected notification received!")
                    lReceivedNotifications.append(listNotify)
                    break
            elif "create-tech-info-notification" == listNotify[0]:
                if re.match("%s"%CREATE_TECH_INFO_NOTIFICATION(listNotify[1], listNotify[2]), re.sub(r"\n *", "", notification.notification_xml)):
                    print("the expected notification received!")
                    lReceivedNotifications.append(listNotify)
                    break
            else:
                print("unknown notification type -- %s"%listNotify[0])
        if len(lReceivedNotifications) == len(listNotifications):
            ret = True
            break
    
    print("expected notification list is %s; the received list is %s"%(listNotifications, lReceivedNotifications))
    if ret:
        print("All expected notification received")
    else:
        print("Not All expected notification received")
    return ret
    

class DB_BACKUP_NOTIFICATION():
    def __init__(self, strStatus, strfilename):
        self.status = strStatus
        self.filename = strfilename
        
    def __str__(self):
        a = ET.Element('notification', xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0")
        b = ET.SubElement(a, 'db-backup-notification', xmlns="http://org/openroadm/database")
        status = ET.SubElement(b, 'status')
        status.text = self.status
        statusMsg = ET.SubElement(b, 'status-message')
        statusMsg.text = "Database backed up successfully in file %s"%self.filename
        eventTime = ET.SubElement(a, 'eventTime')
        eventTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}\+\d{2}:\d{2}"
        return str(ET.tostring(a), encoding='utf-8')
        
class HISTORICAL_PM_COLLECT_RESULT():
    def __init__(self, strStatus):
        self.status = strStatus
        
    def __str__(self):
        a = ET.Element('notification', xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0")
        b = ET.SubElement(a, 'historical-pm-collect-result', xmlns="http://org/openroadm/pm")
        pmFilename = ET.SubElement(b, 'pm-filename')
        pmFilename.text = "pm-history-\d{8}-\d{6}-\d{3}\.gz"
        status = ET.SubElement(b, 'status')
        status.text = self.status
        statusMsg = ET.SubElement(b, 'status-message')
        if "Successful" == self.status:
            statusMsg.text = "Collected PM history file"
        else:
            statusMsg.text = ".*"

        eventTime = ET.SubElement(a, 'eventTime')
        eventTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}\+\d{2}:\d{2}"
        return str(ET.tostring(a), encoding='utf-8')

class CREATE_TECH_INFO_NOTIFICATION():
    def __init__(self, strShelf, strStatus):
        self.shelf = strShelf
        self.status = strStatus
        
    def __str__(self):
        a = ET.Element('notification', xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0")
        b = ET.SubElement(a, 'create-tech-info-notification', xmlns="http://org/openroadm/pm")
        shelfId = ET.SubElement(b, 'shelf-id')
        shelfId.text = self.shelf
        logFilename = ET.SubElement(b, 'log-file-name')
        logFilename.text = "debug_collector_\d{4}(-\d{2}){2}(_\d{2}){3}\.tar\.gz"
        status = ET.SubElement(b, 'status')
        status.text = self.status
        statusMsg = ET.SubElement(b, 'status-message')
        if "Successful" == self.status:
            statusMsg.text = "Create Tech Info successful"
        else:
            statusMsg.text = ".*"

        eventTime = ET.SubElement(a, 'eventTime')
        eventTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}\+\d{2}:\d{2}"
        return str(ET.tostring(a), encoding='utf-8')
        

        
class TRANSFER_NOTIFICATION():
    def __init__(self, strPath, strStatus):
        self.path = strPath
        self.status = strStatus
        
    def __str__(self):
        a = ET.Element('notification', xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0")
        b = ET.SubElement(a, 'transfer-notification', xmlns="http://org/openroadm/file-transfer")
        path = ET.SubElement(b, 'local-file-path')
        path.text = self.path
        status = ET.SubElement(b, 'status')
        status.text = self.status
        statusMsg = ET.SubElement(b, 'status-message')
        if "Successful" == self.status:
            statusMsg.text = "File transfer successful"
        else:
            statusMsg.text = ".*"
        eventTime = ET.SubElement(a, 'eventTime')
        eventTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}\+\d{2}:\d{2}"
        return str(ET.tostring(a), encoding='utf-8')
        
        
class SW_ACTIVATE_NOTIFICATION():
    def __init__(self, strType, strStatus):
        self.type = strType
        self.status = strStatus
        
    def __str__(self):
        a = ET.Element('notification', xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0")
        b = ET.SubElement(a, 'sw-activate-notification', xmlns="http://org/openroadm/de/swdl")
        type = ET.SubElement(b, 'sw-active-notification-type')
        type.text = self.type
        status = ET.SubElement(b, 'status')
        status.text = self.status
        statusMsg = ET.SubElement(b, 'status-message')
        if "Successful" == self.status:
            statusMsg.text = "Database activation event: %s"%self.type
        else:
            statusMsg.text = ".*"
        eventTime = ET.SubElement(a, 'eventTime')
        eventTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}\+\d{2}:\d{2}"
        return str(ET.tostring(a), encoding='utf-8')
        
class SW_STAGE_NOTIFICATION():
    def __init__(self, strPath, strStatus):
        self.path = strPath
        self.status = strStatus
        
    def __str__(self):
        a = ET.Element('notification', xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0")

        b = ET.SubElement(a, 'sw-stage-notification', xmlns="http://org/openroadm/de/swdl")

        status = ET.SubElement(b, 'status')
        status.text = self.status
        statusMsg = ET.SubElement(b, 'status-message')
        if "Successful" == self.status:
            statusMsg.text = "Software staged successfully with file %s"%self.path
        else:
            statusMsg.text = ".*"
        eventTime = ET.SubElement(a, 'eventTime')
        eventTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}\+\d{2}:\d{2}"
        return str(ET.tostring(a), encoding='utf-8')
        
        
class ALARM_NOTIFICATION():
    def __init__(self, strRes, strAlarm, strAction="raise"):
        self.res = strRes
        self.alarm = strAlarm
        self.action = strAction

    def __str__(self):
        a = ET.Element('notification', xmlns="urn:ietf:params:xml:ns:netconf:notification:1.0")
        b = ET.SubElement(a, 'alarm-notification', xmlns="http://org/openroadm/alarm")
        id = ET.SubElement(b, 'id')
        id.text = "0x[0-9a-fA-F]{10}"
        resource = ET.SubElement(b, 'resource')
        res = ET.SubElement(resource, 'resource')
        res_name = ET.SubElement(res, 'interface-name')
        res_name.text = self.res
        res_type = ET.SubElement(resource, 'resourceType')
        type = ET.SubElement(res_type, 'type')
        type.text = "interface"
        
        probableCause = ET.SubElement(b, 'probableCause')
        cause = ET.SubElement(probableCause, 'cause')
        cause.text = "[\w ]*"
        direction = ET.SubElement(probableCause, 'direction')
        direction.text = "[\w ]*"
        location = ET.SubElement(probableCause, 'location')
        location.text = "[\w ]*"
        
        raiseTime = ET.SubElement(b, 'raiseTime')
        raiseTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}Z"

        severity = ET.SubElement(b, 'severity')
        if "clear" == self.action:
            severity.text = "clear"
        elif self.alarm in ["ODU Alarm Indication Signal", "Backward Defect Indication", "Degraded defect", "ODU Open Connection Indication"]:
            severity.text = "major"
        elif self.alarm in ["Incoming Alignment Error", "Backward Incoming Alignment Error"]:
            severity.text = "warning"
        else:
            severity.text = "critical"
        circuit_id = ET.SubElement(b, 'circuit-id')
        circuit_id.text = "[\w ]*"
        additional_detail = ET.SubElement(b, 'additional-detail')
        additional_detail.text = self.alarm
        
        eventTime = ET.SubElement(a, 'eventTime')
        eventTime.text = "\d{4}(-\d{2}){2}T(\d{2}:){2}\d{2}\+\d{2}:\d{2}"
        print(str(ET.tostring(a), encoding='utf-8'))
        return str(ET.tostring(a), encoding='utf-8')


