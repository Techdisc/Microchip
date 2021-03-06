"""*****************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""
from xml import etree as ET
from os import path

def instantiateComponent(dfpComponent):

    from os import listdir
    import xml.etree.ElementTree as ET

    MCC_HEADERS_SUBPATH = "/include"

    dfpDevice = dfpComponent.createCommentSymbol("dfpDevice", None)
    dfpDevice.setLabel("Device: " + Variables.get("__PROCESSOR"))

    #get pack information
    dfpInformation = dfpComponent.createCommentSymbol("dfpInformation", None)

    dfpFiles = listdir(Variables.get("__DFP_PACK_DIR"))
    dfpInfoFound = False
    for dfpFile in dfpFiles:
        if dfpFile.find(".pdsc") != -1:
            dfpDescriptionFile = open(Variables.get("__DFP_PACK_DIR") + "/" + dfpFile, "r")
            dfpDescription = ET.fromstring(dfpDescriptionFile.read())
            dfpInfoFound = True
            for release in dfpDescription.iter("release"):
                dfpInformation.setLabel("Release Information: " + str(release.attrib))
                break

    if dfpInfoFound == False:
        dfpFiles = listdir(Variables.get("__DFP_PACK_DIR")+"/..")
        for dfpFile in dfpFiles:
            if dfpFile.find(".pdsc") != -1:
                dfpDescriptionFile = open(Variables.get("__DFP_PACK_DIR") + "/../" + dfpFile, "r")
                dfpDescription = ET.fromstring(dfpDescriptionFile.read())
                for release in dfpDescription.iter("release"):
                    dfpInformation.setLabel("Release Information: " + str(release.attrib))
                    break

    processorName = Variables.get("__PROCESSOR")

    processorSeries = ATDF.getNode("/avr-tools-device-file/devices/device").getAttribute("series")
    compatXmlPath = path.join(Variables.get("__CORE_DIR"), "compat", "compat.xml")
    compatFile = ""
    if path.isfile(compatXmlPath):
        compatRoot = ET.parse(compatXmlPath)
        familyNode = compatRoot.find("./family[@series=\"{0}\"]".format(processorSeries))
        if familyNode is not None:
            compatFile = familyNode.get("file")
    if compatFile:
        compatFileNameSym = dfpComponent.createStringSymbol("DFP_COMPAT_FILE", None)
        compatFileNameSym.setDefaultValue("{0}_compat.h".format(processorName.lower()))
        compatFileNameSym.setVisible(False)


    deviceHeaderFile = dfpComponent.createFileSymbol("deviceHeaderFile", None)
    deviceHeaderFile.setMarkup(True)
    deviceHeaderFile.setSourcePath("templates/device.h.ftl")
    deviceHeaderFile.setOutputName("device.h")
    deviceHeaderFile.setDestPath("../../packs/" + processorName + "_DFP/")
    deviceHeaderFile.setProjectPath("packs/" + processorName + "_DFP/")
    deviceHeaderFile.setType("HEADER")
    deviceHeaderFile.setOverwrite(True)

    if compatFile:
        deviceCompatHeaderFile = dfpComponent.createFileSymbol("deviceCompatHeaderFile", None)
        deviceCompatHeaderFile.setMarkup(True)
        deviceCompatHeaderFile.setSourcePath("compat/templates/" + compatFile)
        deviceCompatHeaderFile.setOutputName(compatFileNameSym.getValue())
        deviceCompatHeaderFile.setDestPath("../../packs/" + processorName + "_DFP/")
        deviceCompatHeaderFile.setProjectPath("packs/" + processorName + "_DFP/")
        deviceCompatHeaderFile.setType("HEADER")
        deviceCompatHeaderFile.setOverwrite(True)


    if( "PIC32M" not in processorName):
        #add pack files to a project
        headerFileNames = listdir(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/component")

        for headerFileName in headerFileNames:
            szSymbol = "PART_PERIPH_{}_DEFS".format(headerFileName[:-2].upper())
            headerFile = dfpComponent.createFileSymbol(szSymbol, None)
            headerFile.setRelative(False)
            headerFile.setSourcePath(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/component/" + headerFileName)
            headerFile.setOutputName(headerFileName)
            headerFile.setMarkup(False)
            headerFile.setOverwrite(True)
            headerFile.setDestPath("../../packs/" + processorName + "_DFP/component/")
            headerFile.setProjectPath("packs/" + processorName + "_DFP/component/")
            headerFile.setType("HEADER")

        headerFile = dfpComponent.createFileSymbol("PART_MAIN_DEFS", None)
        headerFile.setRelative(False)
        headerFile.setSourcePath(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/" + processorName.replace("ATSAM", "SAM").lower() + ".h")
        headerFile.setOutputName(processorName.lower() + ".h")
        headerFile.setMarkup(False)
        headerFile.setOverwrite(True)
        headerFile.setDestPath("../../packs/" + processorName + "_DFP/")
        headerFile.setProjectPath("packs/" + processorName + "_DFP/")
        headerFile.setType("HEADER")

        headerFile = dfpComponent.createFileSymbol("PART_IO_DEFS", None)
        headerFile.setRelative(False)
        headerFile.setSourcePath(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/pio/" + processorName.replace("ATSAM", "SAM").lower() + ".h")
        headerFile.setOutputName(processorName.replace("ATSAM", "SAM").lower() + ".h")
        headerFile.setMarkup(False)
        headerFile.setOverwrite(True)
        headerFile.setDestPath("../../packs/" + processorName + "_DFP/pio/")
        headerFile.setProjectPath("packs/" + processorName + "_DFP/pio/")
        headerFile.setType("HEADER")

    if Variables.get("__TRUSTZONE_ENABLED") != None and Variables.get("__TRUSTZONE_ENABLED") == "true":
        secDeviceHeaderFile = dfpComponent.createFileSymbol("secure_deviceHeaderFile", None)
        secDeviceHeaderFile.setMarkup(True)
        secDeviceHeaderFile.setSourcePath("templates/device.h.ftl")
        secDeviceHeaderFile.setOutputName("device.h")
        secDeviceHeaderFile.setDestPath("../../packs/" + processorName + "_DFP/")
        secDeviceHeaderFile.setProjectPath("packs/" + processorName + "_DFP/")
        secDeviceHeaderFile.setType("HEADER")
        secDeviceHeaderFile.setOverwrite(True)
        secDeviceHeaderFile.setSecurity("SECURE")
        if( "PIC32M" not in processorName):
            #add pack files to a project
            secHeaderFileNames = listdir(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/component")

            for headerFileName in secHeaderFileNames:
                szSymbol = "secure_" + "PART_PERIPH_{}_DEFS".format(headerFileName[:-2].upper())
                headerFile = dfpComponent.createFileSymbol(szSymbol, None)
                headerFile.setRelative(False)
                headerFile.setSourcePath(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/component/" + headerFileName)
                headerFile.setOutputName(headerFileName)
                headerFile.setMarkup(False)
                headerFile.setOverwrite(True)
                headerFile.setDestPath("../../packs/" + processorName + "_DFP/component/")
                headerFile.setProjectPath("packs/" + processorName + "_DFP/component/")
                headerFile.setType("HEADER")
                headerFile.setSecurity("SECURE")

            headerFile = dfpComponent.createFileSymbol("secure_PART_MAIN_DEFS", None)
            headerFile.setRelative(False)
            headerFile.setSourcePath(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/" + processorName.replace("ATSAM", "SAM").lower() + ".h")
            headerFile.setOutputName(processorName.lower() + ".h")
            headerFile.setMarkup(False)
            headerFile.setOverwrite(True)
            headerFile.setDestPath("../../packs/" + processorName + "_DFP/")
            headerFile.setProjectPath("packs/" + processorName + "_DFP/")
            headerFile.setType("HEADER")
            headerFile.setSecurity("SECURE")

            headerFile = dfpComponent.createFileSymbol("secure_PART_IO_DEFS", None)
            headerFile.setRelative(False)
            headerFile.setSourcePath(Variables.get("__DFP_PACK_DIR") + MCC_HEADERS_SUBPATH + "/pio/" + processorName.replace("ATSAM", "SAM").lower() + ".h")
            headerFile.setOutputName(processorName.replace("ATSAM", "SAM").lower() + ".h")
            headerFile.setMarkup(False)
            headerFile.setOverwrite(True)
            headerFile.setDestPath("../../packs/" + processorName + "_DFP/pio/")
            headerFile.setProjectPath("packs/" + processorName + "_DFP/pio/")
            headerFile.setType("HEADER")
            headerFile.setSecurity("SECURE")