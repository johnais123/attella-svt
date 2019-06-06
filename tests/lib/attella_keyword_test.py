import unittest
from lxml import etree, objectify
import os
import attella_keyword


class attella_keyword_test(unittest.TestCase):
    
    # ${administrative_state_for_fpc}           evaluate    random.choice(["inService", "outOfService", "maintenance"])    random
    # &{fpckey}         create dictionary       circuit-pack-name-self=${tv['uv-attella_def_slot0_provisioned_circuit_pack']}                                circuit-pack-type=FPC        shelf=shelf-0     slot=slot-0     subSlot=slot-0
    # ...               administrative-state-cp=${administrative_state_for_fpc}                        equipment-state-cp=reserved-for-facility-available    circuit-pack-mode=NORMAL
    # ...                          due-date-cp=${tv['uv-valid_due_date']}     circuit-pack-product-code=${tv['uv-attella_def_circuit_pack_fpc_pic_fan_product_code']}
    # @{fpc_info}       create list             ${fpckey}
    # &{dev_info}       create dictionary       circuit-packs=${fpc_info}
    # &{payload}        createdictionary        org-openroadm-device=${dev_info}

    def testVerifyDataBasicDeviceInfo(self):
        root = _getXmlRoot("test.xml")

        testData = {"softwareVersion":"19.2F16-EVO", "max-srgs":"0", "max-degrees":"0"}
        testData2 = {"org-openroadm-device":testData}
        result = attella_keyword.verify_data(root, testData2)

        print ("result is " + str(result))
        self.assertEqual(True, result)

    def testVerifyDataCircuitPacks(self):
        root = _getXmlRoot("test.xml")
        # uv-ATTELLA_DEF_SLOT0_PROVISIONED_CIRCUIT_PACK = "fpc-0"

        fpcKey1 = { "circuit-pack-name-self":"fpc-0",
                     "circuit-pack-type":"FPC",
                      "shelf":"shelf-0",
                      "slot":"slot-0",
                      "subSlot":"slot-0",
                      "administrative-state-cp":"inService",
                      "equipment-state-cp":"reserved-for-facility-available",
                      "circuit-pack-mode":"NORMAL",
                      "due-date-cp":"2019-02-18T00:00:00Z",
                      "product-code":"virtual circuit pack",
                      "type-cp-category":"circuitPack",
        }


        fpcInfo = [fpcKey1]
        devInfo = {'circuit-packs':fpcInfo}
        payLoad = {'org-openroadm-device':devInfo}

        result = attella_keyword.verify_data(root, payLoad)
        self.assertEqual(True, result)


    def testVerifyDataCircuitPacksFans(self):
        root = _getXmlRoot("test.xml")
        # uv-ATTELLA_DEF_SLOT0_PROVISIONED_CIRCUIT_PACK = "fpc-0"

        fan = { "circuit-pack-name-self":"fan-0",
                "circuit-pack-type":"ACX6160-T-Fan-Tray",
                "shelf":"shelf-0",
                "slot":"slot-3",
                "subSlot":"slot-0",
                "administrative-state-cp":"inService",
                "equipment-state-cp":"reserved-for-facility-available",
                "circuit-pack-mode":"NORMAL",
                "due-date-cp":"2019-02-18T00:00:00Z",
                "product-code":"760-09778",
                "type-cp-category":"fan"
        }

        test = {"fan-0":"slot-3", 
                  "fan-1":"slot-4",
                  "fan-2":"slot-5",
                  "fan-3":"slot-6",
                  "fan-4":"slot-7",}

        for entry1, entry2 in test.iteritems():
            fan["circuit-pack-name-self"] = entry1
            fan["slot"] = entry2

            fanInfo = [fan]
            devInfo = {'circuit-packs':fanInfo}
            payLoad = {'org-openroadm-device':devInfo}

            result = attella_keyword.verify_data(root, payLoad)
            if result is not True:
                print "Failed for :" + entry1 + entry2
            self.assertEqual(True, result)
            


    def testVerifyDataBasicDeviceInfoYangPatch(self):
        root = _getOpenRoadmDevRoot("yangPatchTest.xml")
    

        fpcKey1 = { "circuit-pack-name-self":"fpc-0",
                    "circuit-pack-type":"FPC",
                    "shelf":"shelf-0",
                    "slot":"slot-0",
                    "subSlot":"slot-0",
                    "administrative-state-cp":"inService",
                    "equipment-state-cp":"reserved-for-facility-available",
                    "circuit-pack-mode":"NORMAL",
                    "due-date-cp":"2019-02-18T00:00:00Z",
        }

        fpcInfo = [fpcKey1]
        devInfo = {'circuit-packs':fpcInfo}
        payLoad = {'org-openroadm-device':devInfo}
        result = attella_keyword.verify_data(root, payLoad)
        print ("result is " + str(result))
        self.assertEqual(True, result)


    def testGetKey(self):
        self.assertEqual("circuit-pack-name-self", attella_keyword.getKey("circuit-packs"))


    def testGetFather(self):
        self.assertEqual("circuit-packs", attella_keyword.getNodeFather("product-code-cp"))
        self.assertEqual("circuit-packs", attella_keyword.getNodeFather("product-code"))
        self.assertEqual("circuit-packs", attella_keyword.getNodeFather("shelf"))

    


def _getXmlRoot(fileName):
    dir_path = os.path.dirname(os.path.realpath(__file__))
    tree = etree.parse(dir_path + '/../resources/' + fileName)
    return _removeNamespace(tree.getroot())

def _getOpenRoadmDevRoot(fileName):
    dir_path = os.path.dirname(os.path.realpath(__file__))
    tree = etree.parse(dir_path + '/../resources/' + fileName)
    root = _removeNamespace(tree.getroot())
    return root.find("edit/value/org-openroadm-device")


def _removeNamespace(root):
    for elem in root.getiterator():
        if not hasattr(elem.tag, 'find'): continue  # (1)
        i = elem.tag.find('}')
        if i >= 0:
            elem.tag = elem.tag[i+1:]
    objectify.deannotate(root, cleanup_namespaces=True)
    return root


