#!/usr/bin/env python
'''
License:    Declared to be in the Public Domain in the U.S. by its author
            (Ron Burkey), and may be used, modified, or distributed freely for
            any purpose whatever.
Filename:   rawSdfDumper.py
Purpose:    Parses a "raw" SDF file as output by HALSFC-PASS3, closely 
            following the description of the SDF format in document USA001556, 
            "HAL/S-FC SDL Interface Control Document".
Reference:  https://www.ibiblio.org/apollo
Contact:    Ron Burkey <info@sandroid.org>
History:    2026-07-05 RSB  Began.

This file can be used either as a module or as a stand-alone program.  In 
module form, it merely parses the raw SDF file and sets a lot of variables
based on what it finds, and the calling code can access those variables.  As a 
stand-alone program, it prints out those variables in a hopefully human-friendly
way that's easy to reference back to the fuller descriptions in USA001556.

All variables use native Python datatypes, except that blobs or text read from 
the SDF is in `bytearray`'s that retain whatever encoding the SDF uses itself.
In stand-alone mode, text is translated to ASCII for display purposes.
'''

import sys
import os
from datetime import datetime, timedelta
from types import SimpleNamespace
from asciiToEbcdic import *

class sdf:
    maxPages = 250
    
    @staticmethod
    # `bytes` is a `bytearray` containing an EBCDIC string.
    def convertEbcdicToAscii(bytes):
        s = ""
        for b in bytes:
            if b == 0:
                break
            s += ebcdicToAscii[b]
        return s
        
    @staticmethod
    def dayOfYearToDate(day_of_year, year=datetime.now().year):
        date = datetime(year, 1, 1) + timedelta(days=day_of_year - 1)
        return date.month, date.day
    
    @staticmethod
    def centisecondsToHMS(cs):
        total_seconds = cs // 100
        hour = (total_seconds // 3600) % 24
        minute = (total_seconds % 3600) // 60
        second = total_seconds % 60
        return hour, minute, second
    
    def __init__(self, filename=None, verbose=False, sdfpkg=False):
        if filename == None:
            fp = sys.stdin
        else:
            fp = fopen(filename, "rb")
        
        def vprint(*args, **kwargs):
            if verbose:
                print(*args, **kwargs)
        
        self.pageSize = 1680

        # Get the complete contents of the file from stdin, as a set of pages.
        self.pages = []
        while (page := fp.buffer.read(self.pageSize)):
            self.pages.append(page)
        if len(self.pages) == 0:
            vprint("No data found")
            return
        elif (len(self.pages[-1])) != self.pageSize:
            vprint(f"Dataset size not a multiple of {self.pageSize}")
            return
        vprint(f"Pages read: {len(self.pages)}")
        vprint()
        
        # Convert an SDF pointer into a page number and offset.
        def parsePointer(sdfPtr):
            return ((sdfPtr >> 16) & 0xFFFF, sdfPtr & 0xFFFF)
        
        offsetForGet = 0
        def getByte(sdfPtr, caption=None, hex=False, indent=1):
            pageNumber, offset = parsePointer(offsetForGet + sdfPtr)
            page = self.pages[pageNumber]
            value = page[offset]
            if caption != None:
                if hex:
                    c = '0x%02X' % value
                else:
                    c = '%d' % value
                vprint(f"{'\t'*indent}{caption}: {c}")
            return value
        
        def getHalfword(sdfPtr, caption=None, hex=False, indent=1):
            pageNumber, offset = parsePointer(offsetForGet + sdfPtr)
            page = self.pages[pageNumber]
            value = (page[offset] << 8) | page[offset+1]
            if caption != None:
                if hex:
                    c = '0x%04X' % value
                else:
                    c = '%d' % value
                vprint(f"{'\t'*indent}{caption}: {c}")
            return value
        
        def get3QuarterWord(sdfPtr, caption=None, hex=False, indent=1):
            pageNumber, offset = parsePointer(offsetForGet + sdfPtr)
            page = self.pages[pageNumber]
            value = (page[offset] << 16) | (page[offset+1] << 8) | \
                    page[offset+2]
            if caption != None:
                if hex:
                    c = '0x%06X' % value
                else:
                    c = '%d' % value
                vprint(f"{'\t'*indent}{caption}: {c}")
            return value
        
        def getFullword(sdfPtr, caption=None, hex=False, indent=1):
            pageNumber, offset = parsePointer(offsetForGet + sdfPtr)
            page = self.pages[pageNumber]
            value = (page[offset] << 24) | (page[offset+1] << 16) | \
                    (page[offset+2] << 8) | page[offset+3]
            if caption != None:
                if hex:
                    c = '0x%08X' % value
                else:
                    c = '%d' % value
                vprint(f"{'\t'*indent}{caption}: {c}")
            return value
        
        # The argument `inversion` allows detection/correction of negative
        # pointers.
        pointerInverted = False
        def getPointer(sdfPtr, caption=None, indent=1, inversion=False):
            nonlocal pointerInverted
            pointerInverted = False
            ptr = getFullword(sdfPtr)
            if inversion and (ptr & 0x80000000) != 0:
                ptr = 0xFFFFFFFF & (1 + ~ptr)
                pointerInverted = True
            if caption != None:
                pageNumber, offset = parsePointer(ptr)
                vprint(f"{'\t'*indent}{caption} is at page {pageNumber} offset 0x{'%04X' % offset}" + (" (inverted)" if pointerInverted else ""))
            return ptr
        
        ascii = ""
        def getText(sdfPtr, length, caption=None, indent=1):
            nonlocal ascii
            pageNumber, offset = parsePointer(offsetForGet + sdfPtr)
            page = self.pages[pageNumber]
            ret = bytearray(page[offset : offset+length])
            if caption != None:
                msg = f"{'\t'*indent}{caption}: "
                for b in ret:
                    msg += '%02X ' % b
                msg += '"'
                ascii = self.convertEbcdicToAscii(ret)
                msg += ascii + '"'
                vprint(msg)
            return ret
        
        # 2.2.2. Master Directory Cell
        offsetForGet = 0
        vprint("Master Directory Cell (ICD PDF p.31)")
        self.phase3VersionNumber = getHalfword(0, "1\tPhase 3 version Number")
        if self.phase3VersionNumber != 35:  # From PASS3.PROCS/##DRIVER.xpl `VERSION#`
            vprint("\tWarning: Bytes 0-1 not correct version number")
        self.unused = getHalfword(2, "2\tUnused")
        if self.unused != 0:
            vprint("\tWarning: Bytes 2-3 not zero")
        self.pFirstCellOfDirectoryFreeCellChain = getPointer(4, "3\tFirst cell of directory free cell chain")
        if getFullword(self.pFirstCellOfDirectoryFreeCellChain) != 0:
            vprint("\t\tFYI: Directory free cell chain not empty")
        self.pDirectoryRootCell = getPointer(8, "4\tDirectory root cell")
        self.pFirstCellOfDataFreeCellChain = getPointer(12, "5\tFirst cell of data free cell chain")
        if getFullword(self.pFirstCellOfDataFreeCellChain) != 0:
            vprint("\t\tFYI: Data free cell chain not empty")
        
        # 2.2.2.2. Directory Root Cell
        offsetForGet = self.pDirectoryRootCell
        vprint("Directory Root Cell (ICD PDF p.34)")
        self.drc = SimpleNamespace()
        self.drc.flagField = getHalfword(0, "1\tFlag field", True)
        flags = ("SRN_FLAG", "ADDR_FLAG", "COMPOOL_FLAG", "FC_FLAG", "OVERFLOW_FLAG",
                 "NON_MONOTONIC_SRN_FLAG", "NON_UNIQUE_SRN_FLAG", "NOTRACE_FLAG",
                 "HIGHOPT", "BIT_FLAG", "HALMAT_FLAG", "FCDATA_FLAG", "SDL_FLAG",
                 "DATA_REMOTE", "REL6_FLAG", "NEW_FLAG")
        for i in range(16):
            doit = 1 & (self.drc.flagField >> (15 - i))
            if not doit:
                continue
            msg = f"\t\tBit {i}\t{flags[i]}: "
            msg += str(doit)
            vprint(msg)
        flagSRN = self.drc.flagField & 0x8000
        flagADDR = self.drc.flagField & 0x4000
        self.drc.numberOfLastPhysicalRecord = getHalfword(2, "2\tNumber of last physical record")
        self.drc.dateOfFileCreation = getFullword(4, "3\tDate of file creation (1000 * (year - 1900) + day of the year)")
        self.drc.yearOfFileCreation = self.drc.dateOfFileCreation // 1000
        self.drc.dayOfFileCreation = self.drc.dateOfFileCreation - 1000 * self.drc.yearOfFileCreation
        self.drc.year = self.drc.yearOfFileCreation + 1900
        self.drc.month, self.drc.day = self.dayOfYearToDate(self.drc.dayOfFileCreation, year=self.drc.year)
        vprint(f"\t\t{self.drc.year}-{'%02d' % self.drc.month}-{'%02d' % self.drc.day}")
        self.drc.timeOfFileCreation = getFullword(8, "4\tTime of file creation (centiseconds since midnight)")
        self.drc.hour, self.drc.minute, self.drc.second = self.centisecondsToHMS(self.drc.timeOfFileCreation)
        vprint(f"\t\t{'%02d' % self.drc.hour}:{'%02d' % self.drc.minute}:{'%02d' % self.drc.second}")
        self.drc.numberOfLastDirectoryPhysicalRecord = getHalfword(12, "5\tNumber of last directory physical record")
        self.drc.numberOfExternalBlocks = getHalfword(14, "6\tNumber of EXTERNAL blocks")
        self.drc.numberOfBlockIndices = getHalfword(16, "7\tNumber of block indices")
        self.drc.numberOfSymbols = getHalfword(18, "8\tNumber of symbols")
        self.drc.pHeadOfBlockIndexTable = getPointer(20, "9\tHead of block index table")
        self.drc.totalNumberOfEmittedAP101Instructions = getFullword(24, "10\tTotal Number of emitted AP-101 instructions generated")
        self.drc.indexInSymbolTableForNameOfCompilationUnit = getHalfword(28, "11a\tIndex in Symbol Index Table for the name of the compilation unit")
        self.drc.indexIntoSymbolTableForAllInternalSymbols = getHalfword(30, "11b\tIndex into Symbol Index Table for linked list of all internal symbols order alphabetically")
        self.drc.dOrPListHead = getHalfword(32, "12a\t#D or #P list head of compilation unit internal symbols")
        self.drc.rListHead = getHalfword(34, "12b\t#R list head of compilation unit remote data")
        self.drc.pFirstSymbolIndexTableEntry = getPointer(36, "13\tFirst SYMBOL index table entry")
        self.drc.numberOfStackWalkbackLoops = getHalfword(40, "14a\tNumber of stack walkback loops")
        self.drc.relativeAddressOfLiteralAreaInDCSECT = getHalfword(42, "14b\tRelative address of literal area in #D CSECT (65535 if does not exist)")
        self.drc.pCompilationUnitBlockDataCell = getPointer(44, "15\tCompilation unit block data cell")
        self.drc.pHeadOfTheHALSBlockTree = getPointer(48, "16\tHead of the HAL/S Block Tree")
        self.drc.valueOfTheFirstISNInFile = getHalfword(52, "17\tValue of the first ISN in file")
        vprint("\t(ICD PDF p.35)")
        self.drc.valueOfTheLastISNInFile = getHalfword(54, "18\tValue of the last ISN in file")
        self.drc.numberOfExecutableStatements = getHalfword(56, "19\tNumber of executable and DECLARE statements")
        self.drc.numberOfStatements = getHalfword(58, "20\tNumber of statements")
        self.drc.pFirstStatementIndexTableEntry = getPointer(60, "21\tFirst statement index table entry")
        self.drc.pFirstCellOfTheIncludeDataCellList = getPointer(64, "22\tFirst cell of the include data cell list")
        self.drc.pFirstCellOfTheStatementExtentCellList = getPointer(68, "23\tFirst cell of the statement extent cell list")
        self.drc.firstStatementReferenceNumberSRN = getText(72, 6, "24a\tFirst statement reference number (SRN)")
        self.drc.includeCountForFirstSRN = getHalfword(78, "24b\tInclude count for first SRN")
        self.drc.lastStatementReferenceNumberSRN = getText(80, 6, "25a\tLast statement reference number (SRN)")
        self.drc.includeCountForLastSRN = getHalfword(86, "25b\tInclude count for last SRN")
        self.drc.indexOfCompilationUnitBlockDataCell = getHalfword(88, "26\tIndex of compilation unit block data cell")
        self.drc.userDefinedCompilationUnitNumberCOMPUNIT = getHalfword(90, "27\tUser defined compilation unit (COMPUNIT)")
        self.drc.pTitleDataCell = getPointer(92, "28\tTitle data cell")
        vprint("\t29\t8 bytes reserved (user data)")
        self.drc.totalNumberOfSymbols = getFullword(104, "30\tTotal number of symbols")
        self.drc.totalNumberOfBytesOfReplaceText = getFullword(108, "31\tTotal number of bytes of REPLACE text")
        self.drc.totalNumberOfBytesInLiteralTable = getFullword(112, "32\tTotal number of bytes in literal table")
        self.drc.totalFreeCellSpace = getHalfword(116, "33\tTotal free cell space")
        self.drc.comsubParameterEnd = getHalfword(118, "34\tCOMSUB parameter end")
        vprint("\t(ICD PDF p.36)")
        self.drc.numberOfXrefTableEntries = getFullword(120, "35\tNumber of XREF table entries")
        self.drc.numberOfSymbolsSpecifiedInParmField = getFullword(124, "36\tNumber of symbols specified in PARM field")
        self.drc.noBytesSpecifiedForReplaceTextInParmField = getFullword(128, "37\tNo. bytes specified for REPLACE text in PARM field")
        self.drc.noCharactersSpecifiedForLiteralsInParmField = getFullword(132, "38\tNo. characters specified for literals in PARM field")
        self.drc.numberOfXrefEntriesSpecifiedInParmField = getFullword(136, "39\tNumber of XREF entries specified in PARM field")
        self.drc.compilerIdentification = getText(140, 12, "40\tCompiler identification")
        self.drc.pCardtypeData = getPointer(152, "41\tCARDTYPE data")
        self.drc.pInitializationTable = getPointer(156, "42\tInitialization table")
        self.drc.halfwordsInInitializationTable = getFullword(160, "43\t# halfwords in initialization table")
        vprint("\t44-47\tUnused")
        self.drc.offsetToStartOfTopLiteralAreaInD = getHalfword(168, "48\tOffset to start of top literal area in #D")
        self.drc.offsetToEndOfTopLiteralAreaInD = getHalfword(170, "49\tOffset to end of top literal area in #D")
        self.drc.pLiteralExtentTable = getPointer(172, "50\tLiteral extent table")
        self.drc.numberOfEntriesInLiteralExtentTable = getFullword(176, "51\tNumber of entries in literal extent table")
        self.drc.pFunctionIndexTable = getPointer(180, "52\tFunction Index Table")
        self.drc.numberOfEntriesInFunctionIndexTable = getHalfword(184, "53\tNumber of entries in function index table")
        vprint("\t54-62\tUnused")
        
        # 2.2.2.2.1.1. Title Data Cell
        vprint("Title Data Cell (ICD PDF p.42)")
        offsetForGet = self.drc.pTitleDataCell
        self.noOfTitleCharacters = getByte(0, "1\tNo. of characters in TITLE")
        self.titleContents = getText(1, self.noOfTitleCharacters, "2\tTitleContents")
        
        # 2.2.2.2.1.2. CARDTYPE Data Cell
        vprint("CARDTYPE Data Cell (ICD PDF p.43)")
        offsetForGet = self.drc.pCardtypeData
        self.noOfCardtypeCharacters = getByte(0, "1\tNo. of characters in CARDTYPE")
        self.cardtypeText = getText(1, self.noOfCardtypeCharacters, "2\tText of CARDTYPE")
        
        # 2.2.2.2.1.3. Initialization Table
        vprint("Initialization Table (ICD PDF p.44)")
        self.initializationTable = []
        offsetForGet = self.drc.pInitializationTable
        for i in range(self.drc.halfwordsInInitializationTable):
            self.initializationTable.append(getHalfword(i, f"1\tInitialization value {i+1}", hex=True))
        
        # 2.2.2.2.2. Include Text Data
        vprint("Include Text Data (ICD PDF p.45)")
        includeTextData = []
        offsetForGet = self.drc.pFirstCellOfTheIncludeDataCellList
        includeCellNumber = 0
        if offsetForGet == 0:
            vprint("\t(None)")
        while offsetForGet != 0:
            includeCellNumber += 1
            vprint(f"\tInclude Data Cell {includeCellNumber}")
            self.cell = {}
            self.cell["1"] = getPointer(0, "1\tNext member in the include cell chain", indent=2)
            self.cell["2"] = getText(4, 8, "2\tInclude library member name", indent=2)
            self.cell["3"] = getHalfword(12, "3\tRevision number", indent=2)
            self.cell["4"] = getHalfword(14, "4\tCatenation number", indent=2)
            self.cell["5"] = getByte(16, "5\tFlag bits", hex=True, indent=2)
            if (self.cell["5"] & 0x80) != 1:
                vprint("\t\t\tBit 0\tThe member is an SDF")
            if (self.cell["5"] & 0x40) != 1:
                vprint("\t\t\tBit 1\tThe member is located in the library specified by the OUTPUT5 DD statement")
            if (self.cell["5"] & 0x20) != 1:
                vprint("\t\t\tBit 2\tThe member is located in the library specified by the HALSDF DD statement.")
            if (self.cell["5"] & 0x10) != 1:
                vprint("\t\t\tBit 3\tThe member is located in the library specified by the OUTPUT8 DD statement.")
            if (self.cell["5"] & 0x08) != 1:
                vprint("\t\t\tBit 4\tThe member is  located in the library specified by the OUTPUT6 DD statement.")
            if (self.cell["5"] & 0x04) != 1:
                vprint("\t\t\tBit 5\tThe member is located in the library specified by the INCLUDE DD statement.")
            if (self.cell["5"] & 0x02) != 1:
                vprint("\t\t\tBit 6\tTEMPLATE flag. The directive has the form: D INCLUDE TEMPLATE.")
            if (self.cell["5"] & 0x01) != 1:
                vprint("\t\t\tBit 7\tREMOTE flag. The directive specifies the keyword REMOTE.")
            self.cell["6"] = getByte(17, "6\tNumber of SRN's", indent=2)
            self.cell["7"] = []
            vprint("\t\tSRN's:")
            for i in range(cell["6"]):
                self.cell["7"].append(getText(18+6*i, 6, f"7\tSRN {i+1}", indent=3))
            offsetForGet = self.cell["1"]
        
        # 2.2.2.2.3.1. Block Index Table
        vprint("Block Index Table (ICD PDF p.48)")
        self.blockIndexTable = []
        for blockNum in range(self.drc.numberOfBlockIndices):
            vprint(f"\tBlock {blockNum}")
            blockOffset = 12 * blockNum
            offsetForGet = self.drc.pHeadOfBlockIndexTable
            block = {}
            block["name"] = getText(blockOffset, 8, "1\tBlock CSECT name", indent=2)
            asciiName = ascii
            block["pointer"] = getPointer(blockOffset + 8, "2\tBlock data cell", indent=2)
            block["cells"] = []
            offsetForGet = block["pointer"]
            while offsetForGet != 0:
                vprint(f"\t\tData for the block (ICD PDF p.58)")
                cell = {}
                cell["pNextHigherMember"] = getPointer(0, "1\tNext higher member in HAL/S block data cell tree", indent=3)
                cell["pNextLowerMember"] = getPointer(4, "2\tNext lower member in HAL/S block data cell tree", indent=3)
                cell["pFirstNestedBlock"] = getPointer(8, "3\tFirst nested block within the scope of this block", indent=3)
                cell["pNextSiblingMember"] = getPointer(12, "4\tNext block at same level of enclosing block", indent=3)
                cell["pBlockSymbolExtentCell"] = getPointer(16, "5\tBlock symbol extent cell for block", indent=3)
                bset = []
                oldOffsetForGet = offsetForGet
                offsetForGet = cell["pBlockSymbolExtentCell"]
                while offsetForGet != 0:
                    bsec = {}
                    bsec["successor"] = getPointer(0, "1\tSuccessor", indent=4)
                    bsec["numberOfExtentEntries"] = getHalfword(4, "2\tNumber of extent entries", indent=4)
                    bsec["pageNumberOfFirstRecord"] = getHalfword(6, "3\tPage number of 1st physical record of symbol table index", indent=4)
                    offset = 8
                    extentEntries = []
                    for extentNo in range(bsec["numberOfExtentEntries"]):
                        ee = {}
                        ee[f"firstOffset"] = getHalfword(offset, f"4\tFirst offset {extentNo+1}", indent=4)
                        offset += 2
                        ee[f"lastOffset"] = getHalfword(offset, f"5\tLast offset {extentNo+1}", indent=4)
                        offset += 2
                        ee[f"startOfFirstSymbolName"] = getText(offset, 8, f"6\tFirst symbol name {extentNo+1}", indent=4)
                        offset += 8
                        ee[f"startOfLastSymbolName"] = getText(offset, 8, f"7\tLast symbol name {extentNo+1}", indent=4)
                        offset += 8
                        extentEntries.append(ee)
                    bsec["extentEntries"] = extentEntries
                    bset.append(bsec)
                    offsetForGet = bsec["successor"]
                cell["blockSymbolExtentTable"] = bset
                offsetForGet = oldOffsetForGet
                cell["symbolIndexNumberOfBlockName"] = getHalfword(20, "6a\tSymbol index number of block name", indent=3)
                cell["unused"] = getHalfword(22, "6b\tUnused", indent=3)
                cell["flagBits"] = getByte(24, "7\tFlag bits", hex=True, indent=3)
                flags = ("REENTRANT flag", "EXCLUSIVE flag", "ACCESS flag", 
                         "RIGID flag", "EXTERNAL flag",
                         "NONHAL flag", "(Unused)", "(Unused)")
                for i in range(8):
                    doit = 1 & (cell["flagBits"] >> (7 - i))
                    if not doit:
                        continue
                    msg = f"\t\t\t\tBit {i}\t{flags[i]}: "
                    msg += str(doit)
                    vprint(msg)
                cell["VersionNoOfBlockTemplate"] = getByte(25, "8\tVersion no. of block template", indent=3)
                cell["blockIndexNumberInBlockIndexTable"] = getHalfword(26, "9\tBlock index number in the block index table", indent=3)
                cell["blockID"] = getHalfword(28, "10\tBlock ID", indent=3)
                cell["blockCategory"] = getByte(30, "11\tBlock category", hex=True, indent=3)
                blockCategories = ("(Unknown)", "PROGRAM", "PROCEDURE",
                                   "FUNCTION", "COMPOOL", "TASK", "UPDATE")
                vprint("\t\t\t\t" + blockCategories[cell["blockCategory"]])
                cell["functionType"] = getByte(31, "12\tFunction type", hex=True, indent=3)
                functionTypes = ("(None)", "BIT (16 bits)", "CHARACTER",
                                 "MATRIX (SP)", "VECTOR (SP)", "SCALAR (SP)",
                                 "INTEGER (SP)",
                                 "(Not used)", "(Not used)", "BIT (32 bits)",
                                 "(Not used)", "MATRIX (DP)", "VECTOR (DP)",
                                 "SCALAR (DP)", "INTEGER (DP)", 
                                 "(Unknown)", "STRUCTURE")
                vprint("\t\t\t\t" + functionTypes[cell["functionType"]])
                cell["indexToFirstSymbol"] = getHalfword(32, "13\tIndex to first symbol of block in the symbol index table", indent=3)
                cell["indexToLastSymbol"] = getHalfword(34, "14\tIndex to last symbol of block in the symbol index table", indent=3)
                cell["firstStmtNoOfHalsBlock"] = getHalfword(36, "15\tFirst Stmt No. of HAL/S block", indent=3)
                cell["lastStmtNoOfHalsBlock"] = getHalfword(38, "16\tLast Stmt No. of HAL/S block", indent=3)
                cell["isnOfFirstExecutableStmt"] = getHalfword(40, "17a\tISN of 1st executable stmt after initial DECLAREs", indent=3)
                cell["headOfStackFrameVariables"] = getHalfword(42, "17b\tHead of stack frame variables (in address order)", indent=3)
                cell["lengthOfBlockName"] = getByte(44, "18\tLength of block name", indent=3)
                cell["blockName"] = getText(45, cell["lengthOfBlockName"], "19\tBlock name", indent=3)
                
                vprint("\t\tSymbols for the block (ICD PDF p.61)")
                symbols = []
                
                #---------------------------------------------------------------
                def processSymbol(nameBeginning, cellPtr, indent=0):
                    nonlocal offsetForGet;
                    oldOffsetForGet = offsetForGet
                    offsetForGet = cellPtr 
                    scell = {}
                    vprint(f"{'\t'*indent}Symbol data (ICD PDF p.64)")
                    indent += 1
                    scell["nextSymbolInPhase1Order"] = getHalfword(-10, "0d\tNext symbol in phase 1 declared order", indent=indent)
                    scell["pAuxiliarySymbolInformation"] = getPointer(-8, "0c\tAuxiliary symbol information", indent=indent)
                    scell["alphabeticLink"] = getHalfword(-4, "0a\tAlphabetic link", indent=indent)
                    scell["nextSymbolByAddress"] = getHalfword(-2, "0b\tNext symbol by address", indent=indent)
                    scell["blockIndexNumber"] = getHalfword(0, "1\tBlock index #", indent=indent)
                    scell["zeroOrOffsetToExtension"] = getByte(2, "2\tZero or offset to extension data", indent=indent)
                    offsetToExtension = scell["zeroOrOffsetToExtension"]
                    scell["offsetToXrefData"] = getByte(3, "3\tOffset to XREF data", indent=indent)
                    offsetToXrefData = scell["offsetToXrefData"]
                    scell["offsetToArray"] = getByte(4, "4\tOffset to array (copiness) data", indent=indent)
                    offsetToArray = scell["offsetToArray"]
                    scell["offset to struc data"] = getByte(5, "5\tOffset to struc data", indent=indent)
                    offsetToStrucData = scell["offset to struc data"]
                    scell["symbolClass"] = getByte(6, "6\tSymbol class", indent=indent)
                    symbolClass = scell["symbolClass"]
                    # We have to read the Flag Bits a little prematurely, so that
                    # we can condition the Symbol Type a little bit.  So we don't 
                    # print it now, but do it below.
                    flagBits = getFullword(8)
                    flagCOMPOOL         = flagBits & 0x80000000
                    flagInputParameter  = flagBits & 0x40000000
                    flagAssignParameter = flagBits & 0x20000000
                    flagTEMPORARY       = flagBits & 0x10000000
                    flagAUTOMATIC       = flagBits & 0x08000000
                    flagNAME            = flagBits & 0x04000000
                    flagTemplate        = flagBits & 0x02000000
                    flagUnqualified     = flagBits & 0x01000000
                    flagREENTRANT       = flagBits & 0x00800000
                    flagDENSE           = flagBits & 0x00400000
                    flagCONSTANT        = flagBits & 0x00200000
                    flagACCESS          = flagBits & 0x00100000
                    flagIndirect        = flagBits & 0x00080000
                    flagLATCHED         = flagBits & 0x00040000
                    flagLOCKED          = flagBits & 0x00020000
                    flagREMOTE          = flagBits & 0x00010000
                    flagNonZeroBias     = flagBits & 0x00008000
                    flagINITIAL         = flagBits & 0x00004000
                    flagRIGID           = flagBits & 0x00002000
                    flagLiteral         = flagBits & 0x00001000
                    flagEXTERNAL        = flagBits & 0x00000800
                    flagStackVariable   = flagBits & 0x00000400
                    flagLocalBlockData  = flagBits & 0x00000200
                    flagEQUATE          = flagBits & 0x00000100
                    flagIncludedREMOTE  = flagBits & 0x00000080
                    flagEXCLUSIVE       = flagBits & 0x00000040
                    #flagUnused1        = flagBits & 0x00000020
                    flagMiscName        = flagBits & 0x00000010
                    flagMacroArg        = flagBits & 0x00000008
                    flagASIP            = flagBits & 0x00000004
                    #flagUnused2        = flagBits & 0x00000002
                    flagMultiMaskBIT    = flagBits & 0x00000001
                    symbolClassesAndTypes = {
                        1: {
                            "class": "Variable",
                            "types": ("(None)", "BIT (16 bits)", "CHARACTER",
                                      "MATRIX (SP)", "VECTOR (SP)", "SCALAR (SP)",
                                      "INTEGER (SP)",
                                      "(Not used)", "(Not used)", "BIT (32 bits)",
                                      "(Not used)", "MATRIX (DP)", "VECTOR (DP)",
                                      "SCALAR (DP)", "INTEGER (DP)", 
                                      "(Unknown)", "STRUCTURE", "EVENT")
                            },
                        2: {
                            "class": "Label",
                            "types": ("(None)", "PROGRAM", "PROCEDURE",
                                      "FUNCTION", "COMPOOL", "TASK", "UPDATE",
                                      "Statement", "EQUATE", "REPLACE")
                            },
                        3: {
                            "class": "Function",
                            "types": ("(None)", "BIT (16 bits)", "CHARACTER",
                                      "MATRIX (SP)", "VECTOR (SP)", "SCALAR (SP)",
                                      "INTEGER (SP)",
                                      "(Not used)", "(Not used)", "BIT (32 bits)",
                                      "(Not used)", "MATRIX (DP)", "VECTOR (DP)",
                                      "SCALAR (DP)", "INTEGER (DP)", 
                                      "(Unknown)", "STRUCTURE")
                            },
                        4: {
                            "class": "Template",
                            "types": ["(None)", "BIT (16 bits)", "CHARACTER",
                                      "MATRIX (SP)", "VECTOR (SP)", "SCALAR (SP)",
                                      "INTEGER (SP)",
                                      "(Not used)", "(Not used)", "BIT (32 bits)",
                                      "(Not used)", "MATRIX (DP)", "VECTOR (DP)",
                                      "SCALAR (DP)", "INTEGER (DP)", 
                                      "(Unknown)", 
                                      "Template" if flagTemplate else "Minor structure", 
                                      "EVENT"]
                            },
                        5: {
                            "class": "Template label",
                            "types": ("(None)", "PROGRAM", "PROCEDURE",
                                      "FUNCTION", "COMPOOL", "TASK")
                            }
                    }
                    symbolClassAndType = symbolClassesAndTypes[scell["symbolClass"]]
                    vprint(f"{'\t'*(indent+1)}{symbolClassAndType['class']}")
                    scell["symbolType"] = getByte(7, "7\tSymbol type", indent=indent)
                    symbolType = scell["symbolType"]
                    symbolTypeString = symbolClassAndType['types'][symbolType]
                    vprint(f"{'\t'*(indent+1)}{symbolTypeString}")
                    scell["flagBits"] = getFullword(8, "8\tFlag bits", hex=True, indent = indent)
                    flagTypes = ("COMPOOL Flag", "Input Parameter", "Assign Parameter",
                                 "TEMPORARY", "AUTOMATIC", "NAME Variable",
                                 "Template Flag", "Unqualified Structure Flag",
                                 "REENTRANT Flag", "DENSE Flag", "CONSTANT Flag",
                                 "ACCESS Flag", "Indirect Flag", "LATCHED Flag",
                                 "LOCKED Flag", "REMOTE Flag", "Non-zero Bias Flag",
                                 "INITIAL Flag", "RIGID", "Literal", "EXTERNAL",
                                 "Stack Variable", "Local Block Data", "EQUATE",
                                 "INCLUDED REMOTE", "EXCLUSIVE", "(Unused)",
                                 "Misc. Name Flag", "Macro Arg. Flag", "ASIP Flag",
                                 "(Unused)", "BIT variable assigned from multi-instruction mask")
                    for i in range(32):
                        doit = 1 & (scell["flagBits"] >> (31 - i))
                        if not doit:
                            continue
                        msg = f"{'\t'*(indent+1)}Bit {i}\t{flagTypes[i]}: "
                        msg += str(doit)
                        vprint(msg)
                    scell["lengthOfSymbolName"] = getByte(12, "9\tLength of symbol name", indent=indent)
                    lengthOfSymbolName = scell["lengthOfSymbolName"]
                    if symbolClass == 2 and symbolType == 9: # REPLACE LABEL
                        scell["numberOfBytesOfReplaceText"] = get3QuarterWord(13, "10\tNumber of bytes of REPLACE text", indent=indent)
                    elif symbolClass in [2, 3]: 
                        scell["statementNumber"] = getHalfword(14, "10\tStatement number", indent=indent)
                    else:
                        scell["relativeMemoryAddressOfSymbol"] = get3QuarterWord(13, "10\tRelative memory address of symbol", indent=indent)
                    scell["blockID"] = getHalfword(16, "11\tBlock ID", indent=indent)
                    if flagDENSE: # Dense bit Strings.  Note: I don't actually know how to detect these.
                        scell["alignment"] = getByte(18, "12a\tAlignment (dense bit strings)", hex=True, indent=indent)
                        scell["numberOfBits"] = getByte(19, "12b\tNumber of bits (dense bit strings)", indent=indent)
                    elif symbolTypeString == "CHARACTER" or symbolTypeString.startswith("BIT"): # Bit and Char Strings.
                        scell["numberOfBitsOrCharInString"] = getHalfword(18, "12\tNumber of bits or char in string", indent=indent)
                    elif symbolTypeString == "STRUCTURE": # Major Structure
                        scell["symbolNumberOfTemplate"] = getHalfword(18, "12\tSymbol number (index) of template", indent=indent)
                    elif flagEQUATE: # Equate Labels
                        scell["symbolNumberOfExternalEquate"] = getHalfword(18, "12\tSymbol number (index) of external equate reference", indent=indent)
                    elif symbolTypeString.startswith("VECTOR") or symbolTypeString.startswith("MATRIX"):
                        scell["numberOfRows"] = getByte(18, "12a\tNumber of rows", indent=indent)
                        scell["numberOfColumns"] = getByte(19, "12b\tNumber of columns", indent=indent)
                    if flagCONSTANT:
                        scell["constantValueCell"] = getPointer(20, "13\tConstant value cell", indent=indent)
                    elif symbolTypeString == "REPLACE":
                        scell["replaceTextCellChain"] = getPointer(20, "13\tReplace text cell chain", indent=indent)
                    elif flagLocalBlockData:
                        scell["addrOfLocalBlockDataArea"] = getHalfword(20, "13\tAddr of local block data area", indent=indent)
                        scell["sizeOfLocalBlockDataArea"] = getHalfword(22, "14\tSize of local block data area", indent=indent)
                    elif flagLOCKED:
                        scell["lockGroupNumber"] = getByte(20, "13\tLock group number", indent=indent)
                        scell["numberOfBytesOfMemoryOccupied"] = get3QuarterWord(21, "14\tNumber of bytes of memory occupied", indent=indent)
                    if lengthOfSymbolName > 8:
                        extraBytes = lengthOfSymbolName - 8
                        scell["continuationOfSymbolName"] = getText(24, extraBytes, "15\tContinuation of symbol name", indent=indent)
                    else:
                        extraBytes = 0
                    if offsetToExtension != 0:
                        scell["valueOfBiasOfArray"] = getFullword(offsetToExtension, "16\tValue of Bias of Array", indent=indent)
                    if offsetToStrucData != 0:
                        if flagUnqualified:
                            scell["linkToUnqualifiedStructure"] = getHalfword(offsetToStrucData + 0, "17\tLink to unqualified structure", indent=indent)
                        scell["linkToEldestSon"] = getHalfword(offsetToStrucData + 2, "18\tLink to 'Eldest Son'", indent=indent)
                        scell["linkToBrother"] = getHalfword(offsetToStrucData + 4, "19\tLink to 'Brother'", indent=indent)
                    if offsetToArray != 0:
                        numberOfDimensions = getHalfword(offsetToArray + 0, "20\tNumber of dimensions", indent=indent)
                        scell["numberOfDimensions"] = numberOfDimensions
                        if numberOfDimensions >= 1:
                            scell["rangeOfDim1"] = getHalfword(offsetToArray + 2, "21\tRange of dim 1", indent=indent)
                            if numberOfDimensions >= 2:
                                scell["rangeOfDim2"] = getHalfword(offsetToArray + 4, "22\tRange of dim 2", indent=indent)
                                if numberOfDimensions >= 3:
                                    scell["rangeOfDim3"] = getHalfword(offsetToArray + 6, "23\tRange of dim 3", indent=indent)
                    if offsetToXrefData != 0:
                        offset = offsetToXrefData - 2
                        xrefEntries = []
                        scell["relativeSymbolNoInBlock"] = getHalfword(offset, "24a\tRelative symbol no. in block", indent=indent)
                        offset += 2
                        scell["totalNumberOfXrefEntries"] = getHalfword(offset, "24b\tTotal number of XREF entries", indent=indent)
                        offset += 2
                        xrefEntriesLeft = scell["totalNumberOfXrefEntries"]
                        while xrefEntriesLeft > 0:
                            p, o = parsePointer(offsetForGet + offset)
                            if o < 1676 and getFullword(offset) == 0xFFFFFFFF:
                                getFullword(offset, "26\t(Page break)", hex=True, indent=indent)
                                offset += 4
                            elif getHalfword(offset) == 0xFFFF:
                                getHalfword(offset, "26\t(Page break)", hex=True, indent=indent)
                                offset += 2
                            else:
                                entry = getHalfword(offset, f"25\tFlag+Statement #{1 + len(xrefEntries)}", hex=True, indent=indent)
                                offset += 2
                                flagA = entry & 0x8000
                                flagR = entry & 0x4000
                                flagS = entry & 0x2000
                                statementIndex = entry & 0x1FFF
                                flagD = not (flagA or flagR or flagS)
                                msg = f"{'\t'*(indent+1)}Statement {statementIndex}:"
                                if flagA:
                                    msg +=  " Assigned"
                                if flagR:
                                    msg += " Referenced"
                                if flagS:
                                    msg += " Subscript"
                                if flagD:
                                    msg += " Declared"
                                vprint(msg)
                                xrefEntries.append({
                                    "assigned": flagA,
                                    "referenced": flagR,
                                    "subscript": flagS,
                                    "declared": flagD,
                                    "statementIndex": statementIndex
                                    })
                                xrefEntriesLeft -= 1
                                continue
                            # If we got here, then item 27 should be next
                            # to change to a different 1680-byte page.
                            page, offset = getPointer(offset, "27\tNext XREF cell", indent=indent)
                            offsetForGet = (page << 16) | offset
                            offset = 0 
                        scell["xrefEntries"] = xrefEntries
                    
                    symbols.append(scell)
                    offsetForGet = oldOffsetForGet
                #---------------------------------------------------------------
                    
                symbolCount = 0
                if cell["pBlockSymbolExtentCell"] != 0: # There's a Block Symbol Extent Table
                    for bsec in cell["blockSymbolExtentTable"]:
                        for ee in bsec["extentEntries"]:
                            firstOffset = (ee["firstOffset"] - 1) % 140
                            lastOffset = (ee["lastOffset"] - 1) % 140
                            for offset in range(firstOffset, lastOffset + 1):
                                symbolCount += 1
                                vprint(f"\t\t\tSymbol {symbolCount} (ICD PDF p.61)")
                                symOffset = 12 * offset
                                offsetForGet = cell["pBlockSymbolExtentCell"]
                                nameBeginning = getText(symOffset, 8, "1\tFirst 8 characters of symbol name", indent=4)
                                cellPtr = getPointer(symOffset+8, "2\tSymbol data cell", indent=4)
                                processSymbol(nameBeginning, cellPtr, indent=4)
                else: # There's no Block Symbol Extent Table
                    offsetForGet = self.drc.pFirstSymbolIndexTableEntry
                    for i in range(cell["indexToFirstSymbol"]-1, cell["indexToLastSymbol"]):
                        symbolCount += 1
                        vprint(f"\t\t\tSymbol {symbolCount} (ICD PDF p.62)")
                        symOffset = 12 * i
                        nameBeginning = getText(symOffset, 8, "1\tFirst 8 characters of symbol name", indent=4)
                        cellPtr = getPointer(symOffset+8, "2\tSymbol data cell", indent=4)
                        processSymbol(nameBeginning, cellPtr, indent=4)
                cell["symbols"] = symbols
                block["cells"].append(cell)
                offsetForGet = cell["pNextHigherMember"]
            self.blockIndexTable.append(block)
        
        # 2.2.2.2.5. Statement Index Table
        if self.drc.pFirstStatementIndexTableEntry != 0:
            vprint("Statement Index Table (ICD PDF p.98)")
            self.executableStatements = []
            self.declareStatements = []
            offset = 0
            for stmtNo in range(self.drc.valueOfTheFirstISNInFile-1, self.drc.valueOfTheLastISNInFile):
                vprint(f"\tStatement {stmtNo+1} (ICD PDF p.101)")
                statement = {}
                offsetForGet = self.drc.pFirstStatementIndexTableEntry
                if flagSRN:
                    statement["srn"] = getText(offset, 6, "1\tStatement Reference Number (SRN)", indent=2)
                    offset += 6
                    statement["includeCount"] = getHalfword(offset, "2\tINCLUDE count", indent=2)
                    offset += 2
                pStatementData = getPointer(offset, "3\tStatement data", indent=2, inversion=True)
                statement["pStatementData"] = pStatementData
                offset += 4
                if not pointerInverted:
                    vprint("\t\t\tExecutable statement (ICD PDF p.103)")
                    oldOffset = offset
                    offsetForGet = statement["pStatementData"]
                    # We need to read "Statement Category" as little out of 
                    # order, because we need some of the flags in it immediately.
                    statementCategory = getByte(2)
                    flagOriginalSRN = statementCategory & 0x80
                    flagPresentLHS  = statementCategory & 0x40
                    flagPresentRHS  = statementCategory & 0x20
                    offset = -8
                    if flagPresentRHS:
                        offset -= 4
                    if flagPresentLHS:
                        offset -= 4
                        statement["lhsStatementVariables"] = getPointer(offset, "0a\tLHS statement variable list", indent=3)
                        offset += 4
                    if flagPresentRHS:
                        statement["rhsStatementVariables"] = getPointer(offset, "0b\tRHS statement variable list", indent=3)
                        offset += 4
                    statement["flagField"] = getHalfword(offset, "0c\tFlag Field", indent = 3)
                    offset += 2
                    flagMultiBitMask = statement["flagField"] & 0x0200
                    if flagMultiBitMask:
                        vprint("\t\t\t\tBit 6\tContains multi-instruction bit-masking operation")
                    # Unused halfword:
                    offset += 2
                    statement["halmatCellPointer"] = getPointer(offset, "0e\tHALMAT cell pointer", indent=3)
                    offset += 4
                    if offset != 0:
                        print("Implementation error, offset != 0", file=sys.stderr)
                        exit(1)
                    statement["halsBlockIndex"] = getHalfword(0, "1\tHAL/S block index", indent=3)
                    statement["statementCategory"] =  getByte(2, "2\tStatement category", indent=3) # Reread, to pring message.
                    if flagOriginalSRN:
                        vprint("\t\t\t\tBit 0\tOriginal SRN present")
                    if flagPresentLHS:
                        vprint("\t\t\t\tBit 1\tPointer to LHS expression variables present")
                    if flagPresentRHS:
                        vprint("\t\t\t\tBit 2\tPointer to RHS expression variables present")
                    statementSubtype = 3 & (statementCategory >> 3)
                    statementContext = statementCategory & 7
                    if statementContext == 1:
                        vprint("\t\t\t\tBit 5-7\tELSE statement")
                    if statementContext == 2:
                        vprint("\t\t\t\tBit 5-7\tTHEN statement")
                    if statementContext == 4:
                        vprint("\t\t\t\tBit 5-7\tON ERROR statement reference")
                    statementType = getByte(3, "2\tStatement type", indent=3)
                    statement["statementType"] = statementType
                    statementTypes = (
                        "Null", "?", "CALL", "?", "?", "IF Condition", "CLOSE",
                        "RETURN", "END", "SCHEDULE", "?", "WAIT", "UPDATE PRIORITY",
                        "SET, SIGNAL, RESET", "SEND ERROR", "ON ERROR", "FILE",
                        "DO", "DO WHILE, DO UNTIL", "DO FOR", "DO CASE",
                        "DECLARE", "BLOCK HEADER", "EQUATE", "TEMPORARY",
                        "(Not used)", "(Not used)", "(Not used)", "(Not used)", 
                        "(Not used)", "(Not used)", "%NAMEBIAS", "%SVC",
                        "%NAMECOPY", "%COPY", "%SVCI", "%NAMEADD"
                        )
                    s = statementTypes[statementType]
                    if statementType == 1:
                        if statementSubtype == 0:
                            s = "EXIT"
                        elif statementSubtype == 1:
                            s = "REPEAT"
                        elif statementSubtype == 2:
                            s = "GO TO"
                    elif statementType == 3:
                        if statementSubtype == 0:
                            s = "READ"
                        elif statementSubtype == 1:
                            s = "READALL"
                        elif statementSubtype == 2:
                            s = "WRITE"
                    elif statementType == 4:
                        if statementSubtype == 0:
                            s = "Assignment"
                        elif statementSubtype == 1:
                            s = "NAME Assignment"
                    elif statementType == 10:
                        if statementSubtype == 0:
                            s = "FILE Input"
                        elif statementSubtype == 1:
                            s = "FILE Output"
                    vprint(f"\t\t\t\t{s}")
                    numberOfLabelIndexes = getByte(4, "4\tNumber of label indexes", indent=3)
                    statement["numberOfLabelIndexes"] = numberOfLabelIndexes
                    numberOfLhsHalfwords = getByte(5, "5\tNumber of LHS halfwords", indent=3)
                    statement["numberOfLhsHalfwords"] = numberOfLhsHalfwords
                    offset = 6
                    if numberOfLabelIndexes > 0:
                        for i in range(numberOfLabelIndexes):
                            label = getHalfword(offset, f"6\tLabel {i+1}", indent=3)
                            offset += 2
                    if numberOfLhsHalfwords > 0:
                        for i in range(numberOfLhsHalfwords):
                            lhs = getHalfword(offset, f"7\tLHS {i+1}", indent=3)
                            offset += 2
                    if flagADDR:
                        statement["memoryAddress1"] = get3QuarterWord(offset, "8\tMemory address #1 (relative)", hex=True, indent=3)
                        offset += 3
                        statement["memoryAddress2"] = get3QuarterWord(offset, "9\tMemory address #2 (relative)", hex=True, indent=3)
                        offset += 3
                    if flagOriginalSRN:
                        statement["originalSRN"] = getText(offset, 6, "10\tOriginal SRN", indent=3)
                    offset = oldOffset
                    self.executableStatements.append(statement)
                else:
                    vprint("\t\t\tDECLARE statement")
                    oldOffset = offset
                    offsetForGet = statement["pStatementData"]
                
                
                    offset = oldOffset
                    self.declareStatements.append(statement)
        
        # Set this at the very end to indicate that the class has been fully
        # initialized, as opposed to having exited prematurely.
        self.successfullyInitialized = True
    
    def abend(self, errorNumber):
        print(f"Abend {errorNumber}", file=sys.stderr)
        os._exit(1)
    
    '''
    Perform a function of SDFPKG.ASM.  Returns a dictionary corresponding to
    `COMMTABL` with only the fields manipulated by the current call present.
    Note that virtual memory and FCBs are not used in any way by this port of
    SDFPKG.ASM, so while the related fields in `COMMTABL` are changed as
    indicated by the documentation, those changes are meaningless.  For example
    for mode 0, only the `CRETURN` field's value is actually meaningful.
    
    Most of the input arguments also represent fields of `COMMTABL`.
    '''
    def sdfpkg(self, mode, APGAREA=None, AFCBAREA=None, NPAGES=None, 
               NBYTES=None, ADDR=None, PNTR=None, BLKNO=None):
        flagAUTO = mode & 0x80000000
        flagMODF = mode & 0x40000000
        flagRELS = mode & 0x20000000
        flagRESV = mode & 0x10000000
        mode = mode & 0xFFFF
        if mode == 0:
            # No arguments are needed, and no operation is needed either.
            return {"CRETURN": 0 if self.successfullyInitialized else 4, 
                    "ADDR": 0, "APGAREA": 0, "AFCBAREA": 0,
                    "NBYTES": 0, "NPAGES": self.maxPages }
        if mode == 1:
            print(f"Implementation error:  Use `del` instead of sdfpkg(2)", file=sys.stderr)
            exit(1);
        if mode == 2:
            # Note that this does nothing other than manipulate various fields
            # as expected.
            if APGAREA == 0 and NPAGES != 0:
                abend(4013)
            if NPAGES > self.maxPages:
                NPAGES = self.maxPages
            if AFCBAREA == 0 and NBYTES != 0:
                abend(4015)
            return {"CRETURN": 0, 
                    "APGAREA": 0, "AFCBAREA": 0,
                    "NBYTES": 0, "NPAGES": self.maxPages }
        if mode == 3:
            return {"CRETURN": 0, 
                    "APGAREA": 0, "AFCBAREA": 0,
                    "NBYTES": 0, "NPAGES": self.maxPages }
        if mode == 4:
            print(f"Implementation error:  Instead of sdfpkg(4), create a new `sdf` class instance", file=sys.stderr)
            exit(1);
        if mode == 5:  # ***FIXME*** I don't understand this at all!
            return None
        if mode == 6:
            return {"CRETURN": 0} 
        if mode == 7:
            return {"CRETURN": 0, "ADDR": 0, "PNTR": self.drc}
        if mode == 8:
            for cell in self.blockIndexTable:
                pass
        if mode == 9:
            return None
        if mode == 10:
            return None
        if mode == 11:
            return None
        if mode == 12:
            return None
        if mode == 13:
            return None
        if mode == 14:
            return None
        if mode == 15:
            return None
        if mode == 16:
            return None
        if mode == 17:
            return None
        if mode == 18:
            return None
        return None

if __name__ == "__main__":
    helpMsg='''
This program reads (from stdin) an SDF as emitted by the HAL/S compiler's Phase
3, parses it, and produces a report.  This is work in progress, and as such, 
the SDF is still not completely parsed.  More may be added later on an as-needed
basis when/if it facilitates continued HAL/S compiler development.

It (sdfParser.py) can also be used as an importable Python module.

For easy reference to documentation, ICD page numbers and field numbers are
added at strategic points in the report.  These correspond to the "HAL/S-FC 
SDL Interface Control Document", USA001556.

Usage as a stand-alone program:
    sdfParser.py --help
or
    sdfParser.py [--show-dict] < FILENAME.sdf
By default, report is printed in a hopefully human-readable format.  When the
--show-dict switch is present, what's printed instead is a representation of
the Python objects created by the parsing process, which is useful to have
in hand when writing code that imports sdfParser.py as a module.

Typical usage as a module:  
    from sdfParser import sdf
    sdfInstance = sdf("FILENAME.sdf") # The constructor.
    ...
    returnValues = sdf.sdfpkg(MODE, ... mode-dependent arguments ...)
    ...

Regarding the constructor:  The filename is omitted, then stdin is used instead.
The constructor also accepts an optional `verbose` argument (default False)
which then True prints the human-readable report about the parsing to stdout.  
And an optional `sdfpkg` argument (default False) which terminates parsing 
after enough information has been ascertained to support SDFPKG.ASM functions.
In all cases, the constructor creates a Python class containing the results
of the parsing which has been performed.  In full, the constructor's API is
    sdf(filename=None, verbose=False, sdfpkg=False)
Rather than document how the parsed data is represented in the class created
by the constructor, I'd suggest exploring it with the stand-alone version of 
sdfParser.py and its --show-dict switch, in consultation with document
USA001556.

Regarding the method `sdfpkg`:  This method supports SDFPKG.ASM functions, as
described somewhat in the "SDFPKG User's Guide for PASS 29.0/BFS 14.0", document
SFPC-PASS0092, and in the memo "Simulation Data File (SDF) Access Package".
These documents relate to BAL, HAL/S, C, and PL/I interfaces to SDFPKG.ASM, and 
must be freely interpreted in order to apply them instead to Python.  Basically,
MODE consists of 4 option flags and a "mode number" from 0 to 18 that determine
the nature of the function to be performed, which are almost entirely related
to searching the SDF in various manners.  The nature of the arguments and of the
return values varies by mode number.

One significant difference between the human-readable report and the underlying
Python objects provided by the class is that the human-readable report has 
several convenience features that may need to be explicitly provided when using 
the Python objects directly, if you're interested in the corresponding data:

* Translation of textual data from EBCDIC encoding to ASCII.  There is no 
  universal standard as to EBCDIC glyphs or their encoding, and the version used
  here is that required by the original Intermetrics HAL/S compiler.
* Conversion of datestamps from (year-1900)*1000+dayOfYear to mm/dd/yyyy format.
* Conversion of timestamps centisecondsSinceMidnight to hh:mm:ss format.

The class contains methods to perform these conversions, namely:

* sdf.convertEbcdicToAscii(BYTES) converts a Python `bytearray` containing
  EBCDIC bytes, returning a string containing ASCII characters.  The conversion
  terminates either when all bytes are converted, or else when the first 0x00
  is encountered.
* sdf.dayOfYearToDate(DAY_OF_YEAR, YEAR) parses the day of the year, returning
  a pair of two numbers (month,day).  Note that the first day of the year is
  day 1 (rather than day 0).  If YEAR is omitted it defaults to the current
  year, but that can result in an incorrect conversion, since in practice this
  date information relates to the date on which the SDF was generated rather 
  than to the current date.
* sdf.centisecondsToHMS(CENTISECONDS) converts the time since midnight, in
  centiseconds, to the trio of numbers (hours,minutes,seconds).

Note additionally that where SDF data is sorted alphabetically, the collation
is EBCDIC rather than ASCII.
'''
    if "--help" in sys.argv:
        print(helpMsg)
        exit(0)
    if "--show-dict" in sys.argv:
        mysdf = sdf(sdfpkg=("--sdfpkg" in sys.argv))
        import pprint
        pprint.pprint(mysdf.__dict__, sort_dicts=False, compact=True)
        exit(0)
    sdf(verbose=True)
