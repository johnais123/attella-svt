from xml.etree import ElementTree as ET
from xml import etree
# from XML import XML
import re
import random

ROBOT_LIBRARY_SCOPE = "GLOBAL" 

# get xml file name from module name
def getXMLFileNameFromModuleName(strModuleName):
    if strModuleName in ["org-openroadm-device"]:
        return "org-openroadm-device.xml"
    elif strModuleName in ["active-alarm-list"]:
        return "org-openroadm-alarm.xml"
    elif strModuleName in ["current-pm-list"]:
        return "org-openroadm-pm.xml"

        
def getOperXml(targetEt, param_key, param_value="", namespace=""):
    xmlFileName = getXMLFileNameFromModuleName(targetEt.tag)
    try:
        xmlFile = ET.parse("../src/%s"%xmlFileName)
        targetEt.attrib = xmlFile.getroot().attrib

    except Exception as e:
        raise Exception("parse %s fail!"%xmlFileName)
        
    # if type(param_value) == type(list()):
    if isinstance(param_value, list):
        for dictParams in param_value:
            getOperXml(targetEt, param_key)
            for key, value in dictParams.items():
                getOperXml(targetEt, key, value)
    else:
        # toby transfer datetime str to datetime object, so we need to mark datetime with head \ and tail \
        # and we need to strip head \ and tail \
        if isinstance(param_value, str) and len(param_value) > 0 and "\\" == param_value[0] and "\\" == param_value[-1]:
            param_value = param_value.strip("\\")
            
        xmlOper = xmlFile.find('.//%s'%targetEt.tag)
        targetFather = xmlOper.find('.//%s/..'%param_key)
        compareEt = xmlOper.find('.//%s'%param_key)
        

        # handle root 
        if xmlOper.tag == targetFather.tag:
            temp = ET.SubElement(targetEt, param_key)
            temp.text = param_value
        
        # handle leaf
        elif targetEt.find('.//%s'%targetFather.tag) is not None:
            if "alias" in compareEt.attrib:
                param_key = compareEt.attrib["alias"]
            if "" != namespace:
                temp = ET.SubElement(targetEt.findall('.//%s'%targetFather.tag)[-1], param_key, {"xls" : namespace})
            else:
                temp = ET.SubElement(targetEt.findall('.//%s'%targetFather.tag)[-1], param_key)

            temp.text = param_value
            # temp.attrib = compareEt.attrib
        
        # handle middle-level node
        else:
            if "xls" in targetFather.attrib:
                getOperXml(targetEt, targetFather.tag, namespace=targetFather.attrib["xls"])
            else:
                getOperXml(targetEt, targetFather.tag)
            if "alias" in compareEt.attrib:
                param_key = compareEt.attrib["alias"]
            temp = ET.SubElement(targetEt.findall('.//%s'%targetFather.tag)[-1], param_key)
            temp.text = param_value
            # temp.attrib = compareEt.attrib

def getKey(listname, moduleName="org-openroadm-device"):
    '''
    Retrieve list key value from provided xml file
    listname :  list node name 
    '''
    xmlfile = getXMLFileNameFromModuleName(moduleName)
    tree = ET.parse("../src/%s"%xmlfile)
    root = tree.getroot()
    child = root.find(".//%s/*[@type='key']"%listname)
    if child is None:
        return None
    else:
        return child.tag
        
        
def getNodeAlias(nodeName, moduleName="org-openroadm-device"):
    '''
    Retrieve list key value from provided xml file
    listname :  list node name 
    '''
    xmlfile = getXMLFileNameFromModuleName(moduleName)
    tree = ET.parse("../src/%s"%xmlfile)
    root = tree.getroot()
    child = root.find(".//%s"%nodeName)
    if child is None:
        return None
    elif "alias" in child.attrib.keys():
        return child.attrib["alias"]
    else:
        return child.tag
        
def isNodeAKey(nodeName, moduleName="org-openroadm-device"):
    '''
    Retrieve list key value from provided xml file
    listname :  list node name 
    '''
    xmlfile = getXMLFileNameFromModuleName(moduleName)
    tree = ET.parse("../src/%s"%xmlfile)
    root = tree.getroot()
    child = root.find(".//%s"%nodeName)
    if child is None:
        return False
    elif "type" in child.attrib.keys():
        return child.attrib["type"] == "key"
    else:
        return False

        
def getNodeFather(nodeName, moduleName="org-openroadm-device"):
    '''
    Retrieve list key value from provided xml file
    listname :  list node name 
    '''
    if None == nodeName:
        return None
    xmlfile = getXMLFileNameFromModuleName(moduleName)
    tree = ET.parse("../src/%s"%xmlfile)
    root = tree.getroot()
    child = root.find(".//%s/.."%nodeName)
    if child is None:
        return None
    else:
        return child.tag
            
            
def verifyModuleData(root, pathPre, dictParams, keyItem = None):
    result = True
    if keyItem is None:
        pass
    else:
        pathPre += "/[" + getNodeAlias(keyItem) + "=\"" + dictParams[keyItem] + "\"]/."
    for key, value in dictParams.items():
        if isinstance(value, int) or isinstance(value, float):
            value = str(value)

        if isinstance(value, list):
            keyItem = getKey(key)
            if keyItem is None:
                pathTemp = pathPre
            else:
                pathTemp = pathPre + "//" + key
            for item in value:
                if not verifyModuleData(root, pathTemp, item, keyItem):
                    result = False
        else:
            # toby transfer datetime str to datetime object, so we need to mark datetime with head \ and tail \
            # and we need to strip head \ and tail \
            if isinstance(value, str) and len(value) > 0 and "\\" == value[0] and "\\" == value[-1]:
                value = value.strip("\\")
                
            print(key)
            print(value)

            if key == keyItem:
                pass
            else:
                if "." == pathPre[-1] and getNodeFather(key) != getNodeFather(keyItem):
                    print(pathPre + "//" + getNodeAlias(getNodeFather(key)) + "/" + getNodeAlias(key))
                    items = root.findall(pathPre + "//" + getNodeAlias(getNodeFather(key)) + "/" + getNodeAlias(key))

                else:
                    print(pathPre + "//" + getNodeAlias(key))
                    items = root.findall(pathPre + "//" + getNodeAlias(key))
                if len(items):
                    print(key)
                    print(pathPre + "//" + getNodeAlias(key))
                    if isNodeAKey(key):
                        bNodeFound = False
                        for item in items:
                            outputValue = item.text
                            if value == outputValue:
                                print('The real value is '"%s"%outputValue)
                                print('The expect value is '"%s"%value)
                                bNodeFound = True
                                break
                            elif 2 == len(outputValue.split(":")) and value == outputValue.split(":")[1]:
                                print('The real value is '"%s"%outputValue)
                                print('The expect value is '"%s"%value)
                                bNodeFound = True
                                break
                        if not bNodeFound:
                            print('Failed to set leaf '"%s"%key)
                            print('the node is found but the value doesn\'t match')
                            result = False
                    else:
                        lenMax = 9999999
                        for item in items:
                            path = getPath(root, item.tag, item.text, root.tag)

                            if lenMax > len(path):
                                itemTarget = item
                                lenMax = len(path)
                                
                        outputValue = itemTarget.text
                        if value == outputValue:
                            print('The real value is '"%s"%outputValue)
                            print('The expect value is '"%s"%value)
                        elif 2 == len(outputValue.split(":")) and value == outputValue.split(":")[1]:
                            print('The real value is '"%s"%outputValue)
                            print('The expect value is '"%s"%value)
                        else:
                            print('Failed to set leaf '"%s"%key)
                            print('The real value is '"%s"%outputValue)
                            print('The expect value is '"%s"%value)
                            result = False

                else:
                    print("find no instance")
                    result = False

                    

    return result
    
def getPath(root, node, value, strPrePath):
    strResult = None
    for item in root:
        if strResult is not None:
            return strResult

        if item.text is None:
            strResult = getPath(item, node, value, strPrePath + '/' + item.tag)
        elif item.tag == node and item.text == value:
            return strPrePath + '/' + node
        else:
            continue
    return strResult

# def verifyModuleDataOld(root, moduleName, dictParams):
#     VerFlag = True
#     dicts = Node_Dict_Path(dictParams, moduleName)
# 
# 
#     for keys,values in dicts.items():
#         rlvalue = root.find(".//%s"%keys).text
#         if rlvalue == values:
#             print ('The real value is '"%s"%rlvalue)
#             print ('The expect value is '"%s"%values)
#         else:
#             print ('Failed to set leaf '"%s"%keys)
#             print ('The real value is '"%s"%rlvalue)
#             print ('The expect value is '"%s"%values)
#             VerFlag =False
#             return VerFlag
#     for key ,value in dictParams.items():
#         print (key)
#         print (value)
#         print(0)
#         if isinstance(value,list):
# 
#             listkey= getlistkey(key)
#             for i in value:
#                 if isinstance(i,dict) and listkey in i.keys():
#                     # # # get list key-node value
#                     keyvalue = i[listkey]
#                     for keys,values in i.items():
#                         # # # Example: for user in child.findall(".//user/[name='tony']")
#                         print(key)
#                         print(listkey)
#                         print(1)
#                         for user in root.findall(".//%s/[%s='%s']"%(key,listkey,keyvalue)):
#                             print(2)
#                             print(ET.tostring(user))
#                             
#                             if values == user.find(keys).text:
#                                 print ('The real value is '"%s"%values)
#                                 print ('The expect value is '"%s"%user.find(keys).text)
#                             else:
#                                 print ('Failed to set leaf '"%s"%keys)
#                                 print ('The real value is '"%s"%values)
#                                 print ('The expect value is '"%s"%user.find(keys).text)
#                                 VerFlag =False
#                                 return VerFlag
#                 else:
#                     print ("input parameter is not a dict type")
#     return VerFlag

    
def getlistkey(listname, xmlfile="org-openroadm-device.xml"):
    '''
    Retrieve list key value from provided xml file
    listname :  list node name 
    '''
    tree = ET.parse("../src/%s"%xmlfile)
    root = tree.getroot()
    child= root.findall(".//%s//"%listname)
    # get list key name
    for i in child:
        if i.attrib:
            listkey =i.tag
            return listkey

            
def Retrieve_set_URL(dictParams):
    strRet = ""
    for keyModule, dictModule in dictParams.items():
        targetEt = ET.Element(keyModule)
        for key, value in dictModule.items():
            getOperXml(targetEt, key, str(value))
        strRet += ET.tostring(targetEt).decode()
    return strRet.replace("xls=", "xmlns=")

    
def Node_Dict_Path(dictParams, moduleName):
    '''
    Get Path for each under testing leaf , not include list leaf
    '''
    rlist = {}
    dictlist2 = {}
    targetEt = ET.Element(moduleName)
    # retrieve each leaf paths into list
    for key, value in dictParams.items():
        getOperXml(targetEt, key, value)
        targetEt.attrib = dict()

        rlist[key]=ET.tostring(targetEt)
        targetEt = ET.Element(moduleName)
    
    for key,value in dictParams.items():
        if isinstance(value,list):
            print("################")
            print(rlist.pop(key))

    
    for keys,values in rlist.items():
        values = values.decode()
        for key,value in dictParams.items():
            if not isinstance(value,list) and value in values: 
                spath = values.split(value)[0].strip("<,>").replace("><","/").replace(moduleName,'').lstrip("/")
                dictlist2[spath] = value
            else:
                pass    
    return dictlist2

def xml2Path(element):
    if element.text is not None:
        ret = "/" + element.text.replace("/", "%2F")
    else:
        ret = "/" + element.tag
    
    sonRet = ""
    for sonEle in element:
        sonRet += xml2Path(sonEle)
    return ret+sonRet

def get_instance_Path(dictParams):
    '''
    Get Path for each under testing leaf , not include list leaf
    '''
    print(Retrieve_set_URL(dictParams))
    if 1 == len(list(dictParams.keys())):
        moduleName = list(dictParams.keys())[0]
    else:
        print("dictParams is ：%s"%dictParams)
        raise Exception("can not handle the dictParams parameter")
        
    return xml2Path(ET.fromstring(re.sub(r" xmlns=\".*\"", "", Retrieve_set_URL(dictParams)))).replace("/%s/"%moduleName, "", 1)
    
    '''
    rlist = {}
    dictlist2 = {}
    targetEt = ET.Element(moduleName)
    # retrieve each leaf paths into list
    for key, value in dictParams.items():
        getOperXml(targetEt, key, value)
        targetEt.attrib = dict()

        rlist[key]=ET.tostring(targetEt)
        targetEt = ET.Element(moduleName)
    print(ET.tostring(targetEt))
    for key,value in dictParams.items():
        if isinstance(value,list):
            rlist.pop(key)
    for keys,values in rlist.items():
        values = values.decode()
        for key,value in dictParams.items():
            if not isinstance(value,list) and value in values: 
                spath = values.split(value)[0].strip("<,>").replace("><","/").replace(moduleName,'').lstrip("/")
                dictlist2[spath] = value
    for key, value in dictlist2.items():
        return ''.join(key.split("/")[:-1]) + '/' + value
    '''

def Retrieve_URL_Parent(dictParams):
    '''
    get xml file name and module name 
    '''
    # URLHead = xmlfile.split(".")[0] + ":" + moduleName
    # return URLHead
    if 1 == len(list(dictParams.keys())):
        moduleName = list(dictParams.keys())[0]
        return getXMLFileNameFromModuleName(moduleName).split(".")[0] + ":" + moduleName
    else:
        print("dictParams is ：%s"%dictParams)
        raise Exception("can not handle the dictParams parameter")


def verify_data(root, dictParams):
    for moduleName, dictModuleParams in dictParams.items():
        # if not verifyModuleData(root, moduleName, dictModuleParams):
        if not verifyModuleData(root, ".", dictModuleParams):
            return False
    return True

    
def getEthernetIntfFromClientIntf(strClientIntf):
    strClientIntf = strClientIntf.strip()
    if "ett-" == strClientIntf[:4]:
        
        return strClientIntf
    elif "odu-" == strClientIntf[:4]:
        
        return strClientIntf.replace("odu-", "ett-").split(":")[0]
    return -1
    
def getOtu4IntfFromClientIntf(strClientIntf):
    strClientIntf = strClientIntf.strip()
    if "ett-" == strClientIntf[:4]:
        return strClientIntf.replace("ett-", "odu-") + ":0:0:0"
    elif "odu-" == strClientIntf[:4]:
        return strClientIntf
    return -1
            
def getLineOduIntfNameFromClientIntf(strClientIntf):
    strClientIntf = strClientIntf.strip()
    if "ett-" == strClientIntf[:4]:
        location = strClientIntf[4:].split("/")
        # if int(location[2]) >= 4:
            # oduIndex = 1
        # else:
        oduIndex = int(location[2]) / 2
        return "odu-%s/1/%d:0:0:0"%(location[0], oduIndex)
    elif "odu-" == strClientIntf[:4]:
        location = strClientIntf.split("/")
        return "%s/1/%d%s"%(location[0], int(location[-1][0]) / 2, location[-1][1:])
    return -1
    
def getOtuIntfNameFromOduIntf(strOduIntf):
    print(strOduIntf)
    strOduIntf = strOduIntf.strip()
    return strOduIntf.replace("odu", "otu")[:-2]


def getOchIntfNameFromOtuIntf(strOtuIntf):
    strOtuIntf = strOtuIntf.strip()
    return strOtuIntf.replace("otu", "och")[:-2]
    

def getSupportPort(strIntf):
    strIntf.strip()
    
    if "ett-" == strIntf[:4]:
        return strIntf.replace("ett", "port")
        
    if "odu-" == strIntf[:4]:
        strIntf = getOtuIntfNameFromOduIntf(strIntf)
    
    if "otu-" == strIntf[:4]:
        strIntf = getOchIntfNameFromOtuIntf(strIntf)
    if "och-" == strIntf[:4]:
        return strIntf.replace("och", "port")[:-2]
    else:
        return -1

def getSupportCircuitPackName(strIntf):
    strIntf.strip()
    
    if "ett-" == strIntf[:4]:
        return strIntf.replace("ett", "xcvr")
    if "odu-" == strIntf[:4]:
        strIntf = getOtuIntfNameFromOduIntf(strIntf)
    if "otu-" == strIntf[:4]:
        strIntf = getOchIntfNameFromOtuIntf(strIntf)
    if "och-" == strIntf[:4]:
        return strIntf.replace("och", "xcvr")[:-2]
    else:
        return -1
        
def speed2ClientRate(speed):
    if "100G" == speed:
        return "100000"
    else:
        return -1
        
def speed2OduRate(speed):
    if "100G" == speed:
        return "ODU4"
    else:
        return -1
        
def speed2OtuRate(speed):
    if "100G" == speed:
        return "OTU4"
    else:
        return -1
        
def speed2OchRate(speed):
    if "100G" == speed:
        return "R100G"
    else:
        return -1
        
        
        
def randomFrequency():
    index = random.randint(0, 95)
    frequency = str(round(191.35 + index * 0.05, 2))
    if len(frequency) == 5:
        frequency += '0'
    
    return frequency
    
def getNextFrequency(strFrequency):
    strFrequency = str(strFrequency).strip("")
    
    if strFrequency == "196.10":
        return "191.35"
        
        
    strNextFrequency = str(round(float(strFrequency) + 0.05, 2))
    if len(strNextFrequency) == 5:
        strNextFrequency += '0'
    
    return strNextFrequency

def getdefaultOpenroamdfile(shellreturn):
    if shellreturn=="":
        print ("No file in openroadm directory")
        defile= []
    else:
        handleReturn= shellreturn.replace("\r\n","  ").replace("\t","  ")
        pattern = re.compile(r'([" "]+)')
        handleReturn = re.sub(pattern, '  ', handleReturn)
        defile=  handleReturn.split("  ")
    return defile