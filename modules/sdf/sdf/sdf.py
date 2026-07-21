#!/usr/bin/env python
'''
License:    Declared to be in the Public Domain in the U.S. by its author
            (Ron Burkey), and may be used, modified, or distributed freely for
            any purpose whatever.
Filename:   sdf.py
Purpose:    Parses a "raw" SDF file as output by HALSFC-PASS3, closely 
            following the description of the SDF format in document USA001556, 
            "HAL/S-FC SDL Interface Control Document".  I'll call this document
            just "the ICD" if I have occasion to refer to it below.
Reference:  https://www.ibiblio.org/apollo
Contact:    Ron Burkey <info@sandroid.org>
History:    2026-07-05 RSB  Began.
            2026-07-14 RSB  Replaced my simple `vmem` module by the
                            imported `cmem` module instead.

This file can be used either as a module or as a stand-alone program.  It 
contains 2 classes, plus a main program.  The provided Python classes are:

 * `sdf`, which parses SDF's via data in the `vmem` page cache.  The parsed
   data resides in the `sdf` class's attributes.
 * `sdfpkg`, which wraps `cmem` and `sdf` operations in methods that are 
   intended to be as similar as possible to calls to SDFPKG (usually wrapped
   in the `MONITOR(22)` function) that the HAL/S compiler, HALSTAT, MAFGEN, etc. 
   use to access SDF's.

In general, when this file is used as an importable module, calling code deals 
only with the `sdfpkg`, which instantiates and uses the `sdf` class 
transparently, although you can view the `sdf` class's attributes containing
parsed data of the currently-selected SDF by using the fact that the 
instantiated class of the currently-selected SDF is `sdfpkg.s`.  So for example,
there are attributes like `sdfpkg.s.masterDirectoryCell`, 
`sdfpkg.s.masterDirectoryCell.phase3VersionNumber`, and so on.  To make sense
of those, run "sdfParser.py --sdf='SOMESDF' --show-dict" to get a listing of
the full class hierarchy, and cross-reference to the ICD to see which 
attribute names match to which fields in the SDF.

`MONITOR(22)` calls accept a "mode number" specifying the desired function to
be performed.  There is a Python dictionary called `COMMTABL` which is used to 
pass input arguments from the calling program and to hold the output results to 
the calling.  So to use the `sdfpkg` class, the calling code must first 
establish `COMMTABL`.

Some of the input and output fields in `COMMTABL` are pointers to the page
cache, which is supposed to reside in "memory", so the calling code must also
have a memory model for the page cache to reside in and for the pointers to
point to.  In Python, that model should be a large `bytearray` object, such
as 
    memoryModel = bytearray(0x100000)

The first steps are to instantiate `sdfpkg` and to call `MONITOR(0)`, which 
together will also instantiate the other two classes:

    mysdfpkg = sdfpkg(memoryModel, "SDFLIB", COMMTABL)
    ...
    # Set the fields in `COMMTABL` that are needed for mode 0.
    # According to the "SDFPKG User's Guide", those are `MISC`, `APGAREA`,
    # `AFCBAREA`, `NPAGES`, `NBYTES`, `ADDR`, and `PNTR` ...
    ...
    mysdfpkg.sdfpkg(0, addrComtabl) # Initialize `sdf`.
    # The fields in `COMMTABL` and the page cache in the memory model are now
    # altered somewhat to reflect the results of the operation.

The same pattern applies to all modes calls (i.e., `mysdfpkg.sdfpkg(mode)`, 
except that it is no longer necessary to pass `commtablAddress` as an argument 
after the location has been established by mode 0.

All variables use native Python datatypes, except that blobs or text read from 
the SDF is in `bytearray`'s that retain whatever encoding the SDF uses itself.
In stand-alone mode, text is translated to ASCII for display purposes.

Unimplemented Features
----------------------

Some SDF features  may be unimplemented simply because I haven't gotten around
to them yet or haven't understood that they were present.  I won't bother to
list them here, since I may not know about them anyway.  Some features are 
intentionally not implemented, and I want to list those here.

"Augmenting" the Paging Area and/or FCB Area (Mode 2):  This involves the
awful complication of trying to use SPACELIB to reallocate the memory arrays.
The Python version of the HAL/S compiler (HAL_S_FC.py) doesn't even have any
analog for SPACELIB.  But at any rate, it just seems unnecessary.  Instead,
alter the XPL/I or Python code of the HAL/S compiler or HALMAT or whatever
to just use an adequate worst-case size for the Paging and FCB areas to begin
with.  Of course, this is a limitation of `cmem` more than `sdf` or `sdfParser`.

"Rescinding" the Paging Area Augments:  Same thing!

HALMAT:  If the HAL/S compiler parameter HALMAT is used, then HALMAT is included
in the SDF's.  However, the ICD (September 2005) has this comment about it (PDF 
p.132):

    NOTE: The HAL/S-FC compiler feature that results in the creation of HALMAT 
    Data Structures [in the SDF] is not used and there are no plans for using 
    it. This feature should be considered “unverified “ and should not be used 
    in a production environment. The description of HALMAT Data Structures 
    contained in the subsequent sections may not accurately reflect what the 
    HAL/S-FC compiler will produce if this feature were to be used.

And the surviving BFS reports show explicitly that their source code was 
compiled with the NOHALMAT option.  Given this stance, so near the end of the 
termination of the Shuttle program, and given that no HALMAT data appears in 
any surviving MAFGEN or HALSTAT report, I have little inclination to waste any 
of my own time parsing SDF HALMAT info in the foreseeable future.
'''

import sys
import os
from datetime import datetime, timedelta
from types import SimpleNamespace

_pathToVAGC = os.path.dirname(os.path.abspath(__file__)) + "/../../.."
with open(f"{_pathToVAGC}/modules/pipIt.py", "r") as f: exec(f.read())
for i in range(2):
    try:
        from asciiToEbcdic import *
    except ImportError as error:
        pipIt(i, _pathToVAGC, error.name)
for i in range(2):
    try:
        from cmem import cmem
    except ImportError as error:
        pipIt(i, _pathToVAGC, error.name)

class sdf:
    c = None # Instance of `cmem`.
    successfullyInitialized = False
    
    def __init__(self, cmemInstance):
        self.c = cmemInstance
        self.successfullyInitialized = True
    
    verbose = False
    maxPages = 250
    pageSize = 1680
    offsetForGet = 0
    pointerInverted = False
    ascii = ""
    
    # `bytes` is a `bytearray` containing an EBCDIC string.  A Python string
    # containing ASCII characters is returned.  The `compressed` parameter, if 
    # True, means that runs of multiple consecutive space characters in the 
    # EBCDIC have been "compressed" by the following scheme:  A byte of 0xEE is
    # followed by a second byte giving the number of blanks minus 1.  So for 
    # example, if 0xEE 0x05 is encountered (and `compressed=True`), those two 
    # bytes are replaced by 6 blanks.
    def convertEbcdicToAscii(bytes, compressed=False):
        s = ""
        escaping = False
        for b in bytes:
            if compressed:
                if escaping:
                    escaping = False
                    s += " "*(b+1)
                    continue
                if b == 0xEE:
                    escaping = True
                    continue
            if b == 0:
                break
            s += ebcdicToAscii[b]
        return s
    
    # Convert an SDF pointer into a page number and offset.
    @staticmethod
    def parsePointer(sdfPtr):
        page = (sdfPtr >> 16) & 0xFFFF
        offset = sdfPtr & 0xFFFF
        while (offset & 0x8000) != 0: # Offset negative.
            page -= 1
            offset = (offset + 1680) & 0xFFFF
        while offset >= 1680:
            page += 1
            offset -= 1680
        return page, offset
    
    @staticmethod
    def vmpPlusOffset(vmp, offset):
        page, oldOffset = sdf.parsePointer(vmp)
        offset += oldOffset
        while offset < 0:
            offset += 1680
            page -= 1
        while offset >= 1680:
            offset -= 1680
            page += 1
        return (page << 16) | offset
    
    # If `self.verbose` is True, identical to python print().  If False, then
    # don't print anything.
    def vprint(self, *args, **kwargs):
        if self.verbose:
            print(*args, **kwargs)
    
    # Given an "SDF pointer" (page number + offset), returns the byte at that 
    # location in the currently-selected SDF.  Optionally prints the value, with
    # a caption, optionally in hexadecimal, with a selected indentation 
    # consisting of some number of tabs.  The printing occurs only if the 
    # `caption` argument is present.
    def getByte(self, sdfPtr, caption=None, hex=False, indent=1):
        address = self.c.mode5(self.offsetForGet + sdfPtr)
        value = self.c.mem[address]
        if caption != None:
            if hex:
                c = '0x%02X' % value
            else:
                c = '%d' % value
            self.vprint(f"{'\t'*indent}{caption}: {c}")
        return value
    
    # Same as `getByte`, but for 16-bit integers.  The big-endian byte-order 
    # used in SDF's is accounted for.
    def getHalfword(self, sdfPtr, caption=None, hex=False, indent=1):
        address = self.c.mode5(self.offsetForGet + sdfPtr)
        value = (self.c.mem[address] << 8) | self.c.mem[address + 1]
        if caption != None:
            if hex:
                c = '0x%04X' % value
            else:
                c = '%d' % value
            self.vprint(f"{'\t'*indent}{caption}: {c}")
        return value
    
    # Same as `getByte`, but for 24-bit integers.  The big-endian byte-order 
    # used in SDF's is accounted for.
    def get3QuarterWord(self, sdfPtr, caption=None, hex=False, indent=1):
        address = self.c.mode5(self.offsetForGet + sdfPtr)
        value = (self.c.mem[address] << 16) | (self.c.mem[address + 1] << 8) | \
                self.c.mem[address + 2]
        if caption != None:
            if hex:
                c = '0x%06X' % value
            else:
                c = '%d' % value
            self.vprint(f"{'\t'*indent}{caption}: {c}")
        return value
    
    # Same as `getByte`, but for 32-bit integers.  The big-endian byte-order 
    # used in SDF's is accounted for.
    def getFullword(self, sdfPtr, caption=None, hex=False, indent=1):
        address = self.c.mode5(self.offsetForGet + sdfPtr)
        value = (self.c.mem[address] << 24) | (self.c.mem[address + 1] << 16) | \
                (self.c.mem[address + 2] << 8) | self.c.mem[address + 3]
        if caption != None:
            if hex:
                c = '0x%08X' % value
            else:
                c = '%d' % value
            self.vprint(f"{'\t'*indent}{caption}: {c}")
        return value
    
    # Same as `getFullword`, but specialized for the case in which the
    # `sdfPtr` is itself pointing to an SDF pointer.  In certain cases the
    # pointer which is found in the SDF is negative.  By default `getPointer`
    # does not attempt to detect this case, but if `inversion` is `True`,
    # it will detect negative pointers and print them in their non-negative
    # forms.  But that only affect the *printed* value (i.e., when `caption`
    # is present).  The value *returned* by the function is always
    # as-is, with no corrections, and therefore may be negative.
    def getPointer(self, sdfPtr, caption=None, indent=1, inversion=False):
        self.pointerInverted = False
        ptr = self.getFullword(sdfPtr)
        if inversion and (ptr & 0x80000000) != 0:
            ptr = 0xFFFFFFFF & (1 + ~ptr)
            self.pointerInverted = True
        if caption != None:
            pageNumber, offset = sdf.parsePointer(ptr)
            self.vprint(f"{'\t'*indent}{caption} is at page {pageNumber} " + \
                        f"offset 0x{'%04X' % offset}" + \
                        (" (inverted)" if self.pointerInverted else ""))
        return ptr
    
    # Fetch text from the SDF, given that `sdfPtr` points to it, and the 
    # `length` tells how many characters are involved.  The text is returned
    # as-is, as a `bytearray`.  If `caption` is present, there is a printed
    # message, which contains both the `bytearray` form (in EBCDIC) and an 
    # ASCII translation of it.  The ASCII translation is *not* returned by
    # the function.  The `compressed` parameter is for `convertEbcdicToAscii`.
    def getText(self, sdfPtr, length, caption=None, compressed=False, indent=1):
        address = self.c.mode5(self.offsetForGet + sdfPtr)
        ret = bytearray(self.c.mem[address: address + length])
        if caption != None:
            msg = f"{'\t'*indent}{caption}: "
            for b in ret:
                msg += '%02X ' % b
            msg += '"'
            self.ascii = sdf.convertEbcdicToAscii(ret, compressed=compressed)
            msg += self.ascii + '"'
            self.vprint(msg)
        return ret

    # Given a cell in the Symbol Table, figure out the name of the symbol
    # in ASCII
    @staticmethod
    def fullSymbolASCII(symbolCell):
        symbolLength = symbolCell.symbolDataCell.lengthOfSymbolName
        if symbolLength <= 8:
            nameEBCDIC = symbolCell.nameStart[:symbolLength]
        else:
            nameEBCDIC = symbolCell.nameStart + \
                         symbolCell.symbolDataCell.continuationOfSymbolName
        return sdf.convertEbcdicToAscii(nameEBCDIC)
        
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

    def getReplaceTextCellChain(self, cell, indent=1):
        if cell.pReplaceTextCellChain == 0:
            vprint(f"{'\t'*indent}Replacement text cell chain is empty")
            return
        oldOffsetForGet = self.offsetForGet
        self.offsetForGet = cell.pReplaceTextCellChain
        rtpc = SimpleNamespace()
        cell.replaceTextCellChain = rtpc
        i = 0
        while self.offsetForGet != 0:
            if i == 0:
                self.vprint(f"{'\t'*indent}Replace Text Parameter Cell (ICD PDF p.89)")
                rtpc.pNextReplaceTextCell = self.getPointer(
                    0, "1\tNext Replace Text Cell", indent=indent)
                rtpc.argNumIndicator = self.getHalfword(
                    4, "2\t-(#ARGS+1)", indent=indent)
                numArgs = (-rtpc.argNumIndicator - 1) & 0xFFFF
                self.vprint(f"{'\t'*(indent+1)}#ARGS = {numArgs}")
                rtpc.noOfBlankBytes = self.getHalfword(
                    6, "3\tNumber of blank bytes", indent=indent)
                if numArgs > 0:
                    self.vprint(f"{'\t'*indent}4\tXPL-style descriptors (relative) for argument text")
                    offset = 8
                    rtpc.pseudoDescriptors = []
                    for i in range(numArgs):
                        pd = self.getFullword(
                            offset, f"Pseudo-descriptor for argument {i+1}", hex=True, indent=indent+1)
                        text = self.getText(
                            pd & 0xFFFFFF, (pd >> 24) + 1, "Argument text", indent=indent+2)
                        rtpc.pseudoDescriptors.append(SimpleNamespace(
                            pseudoDescriptor=pd, text=text))
                        offset += 4
                rtpc.replaceTextMacroCells = []
                self.offsetForGet = rtpc.pNextReplaceTextCell
            else:
                self.vprint(f"{'\t'*indent}Replace Text Macro Cell {i} (ICD PDF p.90)")
                rpmc = SimpleNamespace()
                rtpc.replaceTextMacroCells.append(rpmc)
                rpmc.pNextReplaceTextCell = self.getPointer(
                    0, "1\tNext Replace Text Cell", indent=indent)
                rpmc.numberOfBytesOfText = self.getHalfword(
                    4, "2\tNumber of bytes of text", indent=indent)
                rpmc.text = self.getText(
                    6, rpmc.numberOfBytesOfText, "3\tText", compressed=True, indent=indent)
                self.offsetForGet = rpmc.pNextReplaceTextCell
            i += 1

        self.offsetForGet = oldOffsetForGet
    
    # The `parseSymbol` method is intended to be used only by the `parseSDF`
    # method rather than being called directly.  As the name implies, it 
    # parses symbol data found in the SDF.  The `nameBeginning` argument is a 
    # `bytearray` of length 8 that contains the first 8 characters of the 
    # symbol name, padded with 0x00 if the name is shorter than that.  The
    # `cellPtr` argument is an SDF pointer (page number + offset) to the 
    # Symbol Data Cell containing additional data about the symbol such as the
    # remainder of the name.  I've separated it out of `parseSDF` for clarity
    # simply because it's so very large.
    def parseSymbol(self, nameBeginning, cellPtr, indent=0):
        oldOffsetForGet = self.offsetForGet
        self.offsetForGet = cellPtr 
        scell = SimpleNamespace()
        scell.nextSymbolInPhase1Order = self.getHalfword(
            -10, "0d\tNext symbol in phase 1 declared order", indent=indent)
        scell.pAuxiliarySymbolInformation = self.getPointer(
            -8, "0c\tAuxiliary symbol information", indent=indent)
        scell.alphabeticLink = self.getHalfword(
            -4, "0a\tAlphabetic link", indent=indent)
        scell.nextSymbolByAddress = self.getHalfword(
            -2, "0b\tNext symbol by address", indent=indent)
        scell.blockIndexNumber = self.getHalfword(
            0, "1\tBlock index #", indent=indent)
        scell.zeroOrOffsetToExtension = self.getByte(
            2, "2\tZero or offset to extension data", indent=indent)
        offsetToExtension = scell.zeroOrOffsetToExtension
        scell.offsetToXrefData = self.getByte(
            3, "3\tOffset to XREF data", indent=indent)
        offsetToXrefData = scell.offsetToXrefData
        scell.offsetToArray = self.getByte(
            4, "4\tOffset to array (copiness) data", indent=indent)
        offsetToArray = scell.offsetToArray
        scell.offsetToStrucData = self.getByte(
            5, "5\tOffset to struc data", indent=indent)
        offsetToStrucData = scell.offsetToStrucData
        scell.symbolClass = self.getByte(
            6, "6\tSymbol class", indent=indent)
        symbolClass = scell.symbolClass
        # We have to read the Flag Bits a little prematurely, so that
        # we can condition the Symbol Type a little bit.  So we don't 
        # print it now, but do it below.
        flagBits = self.getFullword(8)
        flagCOMPOOL = flagBits & 0x80000000
        flagInputParameter = flagBits & 0x40000000
        flagAssignParameter = flagBits & 0x20000000
        flagTEMPORARY = flagBits & 0x10000000
        flagAUTOMATIC = flagBits & 0x08000000
        flagNAME = flagBits & 0x04000000
        flagTemplate = flagBits & 0x02000000
        flagUnqualified = flagBits & 0x01000000
        flagREENTRANT = flagBits & 0x00800000
        flagDENSE = flagBits & 0x00400000
        flagCONSTANT = flagBits & 0x00200000
        flagACCESS = flagBits & 0x00100000
        flagIndirect = flagBits & 0x00080000
        flagLATCHED = flagBits & 0x00040000
        flagLOCKED = flagBits & 0x00020000
        flagREMOTE = flagBits & 0x00010000
        flagNonZeroBias = flagBits & 0x00008000
        flagINITIAL = flagBits & 0x00004000
        flagRIGID = flagBits & 0x00002000
        flagLiteral = flagBits & 0x00001000
        flagEXTERNAL = flagBits & 0x00000800
        flagStackVariable = flagBits & 0x00000400
        flagLocalBlockData = flagBits & 0x00000200
        flagEQUATE = flagBits & 0x00000100
        flagIncludedREMOTE = flagBits & 0x00000080
        flagEXCLUSIVE = flagBits & 0x00000040
        # flagUnused1        = flagBits & 0x00000020
        flagMiscName = flagBits & 0x00000010
        flagMacroArg = flagBits & 0x00000008
        flagASIP = flagBits & 0x00000004
        # flagUnused2        = flagBits & 0x00000002
        flagMultiMaskBIT = flagBits & 0x00000001
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
        symbolClassAndType = symbolClassesAndTypes[scell.symbolClass]
        self.vprint(f"{'\t'*(indent+1)}{symbolClassAndType['class']}")
        scell.symbolType = self.getByte(
            7, "7\tSymbol type", indent=indent)
        symbolType = scell.symbolType
        symbolTypeString = symbolClassAndType['types'][symbolType]
        self.vprint(f"{'\t'*(indent+1)}{symbolTypeString}")
        scell.flagBits = self.getFullword(
            8, "8\tFlag bits", hex=True, indent=indent)
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
                     "(Unused)", 
                     "BIT variable assigned from multi-instruction mask")
        for i in range(32):
            doit = 1 & (scell.flagBits >> (31 - i))
            if not doit:
                continue
            msg = f"{'\t'*(indent+1)}Bit {i}\t{flagTypes[i]}: "
            msg += str(doit)
            self.vprint(msg)
        scell.lengthOfSymbolName = self.getByte(
            12, "9\tLength of symbol name", indent=indent)
        lengthOfSymbolName = scell.lengthOfSymbolName
        if symbolClass == 2 and symbolType == 9:  # REPLACE LABEL
            scell.numberOfBytesOfReplaceText = self.get3QuarterWord(
                13, "10\tNumber of bytes of REPLACE text", indent=indent)
        elif symbolClass in [2, 3]: 
            scell.statementNumber = self.getHalfword(
                14, "10\tStatement number", indent=indent)
        else:
            scell.relativeMemoryAddressOfSymbol = self.get3QuarterWord(
                13, "10\tRelative memory address of symbol", indent=indent)
        scell.blockID = self.getHalfword(
            16, "11\tBlock ID", indent=indent)
        if flagDENSE:  # Dense bit Strings.
            scell.alignment = self.getByte(
                18, "12a\tAlignment (dense bit strings)", hex=True, indent=indent)
            scell.numberOfBits = self.getByte(
                19, "12b\tNumber of bits (dense bit strings)", indent=indent)
        elif symbolTypeString == "CHARACTER" or \
                symbolTypeString.startswith("BIT"):  # Bit and Char Strings.
            scell.numberOfBitsOrCharInString = self.getHalfword(
                18, "12\tNumber of bits or char in string", indent=indent)
        elif symbolTypeString == "STRUCTURE":  # Major Structure
            scell.symbolNumberOfTemplate = self.getHalfword(
                18, "12\tSymbol number (index) of template", indent=indent)
        elif flagEQUATE:  # Equate Labels
            scell.symbolNumberOfExternalEquate = self.getHalfword(
                18, "12\tSymbol number (index) of external equate reference", 
                indent=indent)
        elif symbolTypeString.startswith("VECTOR") or \
                symbolTypeString.startswith("MATRIX"):
            scell.numberOfRows = self.getByte(
                18, "12a\tNumber of rows", indent=indent)
            scell.numberOfColumns = self.getByte(
                19, "12b\tNumber of columns", indent=indent)
        if flagCONSTANT:
            scell.constantValueCell = self.getPointer(
                20, "13\tConstant value cell", indent=indent)
        elif symbolTypeString == "REPLACE":
            scell.pReplaceTextCellChain = self.getPointer(
                20, "13\tReplace text cell chain", indent=indent)
            self.getReplaceTextCellChain(scell, indent=indent+1)
        elif flagLocalBlockData:
            scell.addrOfLocalBlockDataArea = self.getHalfword(
                20, "13\tAddr of local block data area", indent=indent)
            scell.sizeOfLocalBlockDataArea = self.getHalfword(
                22, "14\tSize of local block data area", indent=indent)
        elif flagLOCKED:
            scell.lockGroupNumber = self.getByte(
                20, "13\tLock group number", indent=indent)
            scell.numberOfBytesOfMemoryOccupied = self.get3QuarterWord(
                21, "14\tNumber of bytes of memory occupied", indent=indent)
        if lengthOfSymbolName > 8:
            extraBytes = lengthOfSymbolName - 8
            scell.continuationOfSymbolName = self.getText(
                24, extraBytes, "15\tContinuation of symbol name", 
                indent=indent)
        else:
            extraBytes = 0
        if offsetToExtension != 0:
            scell.valueOfBiasOfArray = self.getFullword(
                offsetToExtension, "16\tValue of Bias of Array", indent=indent)
        if offsetToStrucData != 0:
            if flagUnqualified:
                scell.linkToUnqualifiedStructure = self.getHalfword(
                    offsetToStrucData + 0, "17\tLink to unqualified structure", 
                    indent=indent)
            scell.linkToEldestSon = self.getHalfword(
                offsetToStrucData + 2, "18\tLink to 'Eldest Son'", 
                indent=indent)
            scell.linkToBrother = self.getHalfword(
                offsetToStrucData + 4, "19\tLink to 'Brother'", indent=indent)
        if offsetToArray != 0:
            numberOfDimensions = self.getHalfword(
                offsetToArray + 0, "20\tNumber of dimensions", indent=indent)
            scell.numberOfDimensions = numberOfDimensions
            if numberOfDimensions >= 1:
                scell.rangeOfDim1 = self.getHalfword(
                    offsetToArray + 2, "21\tRange of dim 1", indent=indent)
                if numberOfDimensions >= 2:
                    scell.rangeOfDim2 = self.getHalfword(
                        offsetToArray + 4, "22\tRange of dim 2", indent=indent)
                    if numberOfDimensions >= 3:
                        scell.rangeOfDim3 = self.getHalfword(
                            offsetToArray + 6, "23\tRange of dim 3", 
                            indent=indent)
        if offsetToXrefData != 0:
            offset = offsetToXrefData - 2
            xrefEntries = []
            scell.relativeSymbolNoInBlock = self.getHalfword(
                offset, "24a\tRelative symbol no. in block", indent=indent)
            offset += 2
            scell.totalNumberOfXrefEntries = self.getHalfword(
                offset, "24b\tTotal number of XREF entries", indent=indent)
            offset += 2
            xrefEntriesLeft = scell.totalNumberOfXrefEntries
            while xrefEntriesLeft > 0:
                p, o = sdf.parsePointer(self.offsetForGet + offset)
                if o < 1676 and self.getFullword(offset) == 0xFFFFFFFF:
                    self.getFullword(
                        offset, "26\t(Page break)", hex=True, indent=indent)
                    offset += 4
                elif self.getHalfword(offset) == 0xFFFF:
                    self.getHalfword(
                        offset, "26\t(Page break)", hex=True, indent=indent)
                    offset += 2
                else:
                    entry = self.getHalfword(
                        offset, f"25\tFlag+Statement #{1 + len(xrefEntries)}", 
                        hex=True, indent=indent)
                    offset += 2
                    flagA = entry & 0x8000
                    flagR = entry & 0x4000
                    flagS = entry & 0x2000
                    statementIndex = entry & 0x1FFF
                    flagD = not (flagA or flagR or flagS)
                    msg = f"{'\t'*(indent+1)}Statement {statementIndex}:"
                    if flagA:
                        msg += " Assigned"
                    if flagR:
                        msg += " Referenced"
                    if flagS:
                        msg += " Subscript"
                    if flagD:
                        msg += " Declared"
                    self.vprint(msg)
                    xrefEntries.append(SimpleNamespace(
                        assigned=flagA,
                        referenced=flagR,
                        subscript=flagS,
                        declared=flagD,
                        statementIndex=statementIndex
                        ))
                    xrefEntriesLeft -= 1
                    continue
                # If we got here, then item 27 should be next
                # to change to a different 1680-byte page.
                page, offset = self.getPointer(
                    offset, "27\tNext XREF cell", indent=indent)
                self.offsetForGet = (page << 16) | offset
                offset = 0 
            scell.xrefEntries = xrefEntries
        
        self.offsetForGet = oldOffsetForGet
        return scell
    
    # This is the workhorse method of the `sdf` class.  It parses the SDF,
    # turning it into attributes of the class.  The SDF itself, buffering
    # it into memory, switching between SDF's, and so forth, is handled 
    # transparently by the `vmem` class instance.  I.e., `parseSDF` simply
    # operates on whatever SDF has been selected and is currently being offered
    # by `vmem`.
    def parseSDF(self):
        
        # 2.2.2. Master Directory Cell
        self.offsetForGet = 0
        self.vprint("Master Directory Cell (ICD PDF p.31)")
        self.masterDirectoryCell = SimpleNamespace()
        self.masterDirectoryCell.phase3VersionNumber = \
            self.getHalfword(0, "1\tPhase 3 version Number")
        # From PASS3.PROCS/##DRIVER.xpl `VERSION#`:
        if self.masterDirectoryCell.phase3VersionNumber != 35:  
            self.vprint("\tWarning: Bytes 0-1 not correct version number")
        self.masterDirectoryCell.unused = self.getHalfword(2, "2\tUnused")
        if self.masterDirectoryCell.unused != 0:
            self.vprint("\tWarning: Bytes 2-3 not zero")
        self.masterDirectoryCell.pFirstCellOfDirectoryFreeCellChain = \
            self.getPointer(4, "3\tFirst cell of directory free cell chain")
        if self.getFullword(
            self.masterDirectoryCell.pFirstCellOfDirectoryFreeCellChain) != 0:
            self.vprint("\t\tFYI: Directory free cell chain not empty")
        self.masterDirectoryCell.pDirectoryRootCell = \
            self.getPointer(8, "4\tDirectory root cell")
        self.masterDirectoryCell.pFirstCellOfDataFreeCellChain = \
            self.getPointer(12, "5\tFirst cell of data free cell chain")
        if self.getFullword(
                self.masterDirectoryCell.pFirstCellOfDataFreeCellChain) != 0:
            self.vprint("\t\tFYI: Data free cell chain not empty")
        
        # 2.2.2.2. Directory Root Cell
        self.offsetForGet = self.masterDirectoryCell.pDirectoryRootCell
        self.vprint("Directory Root Cell (ICD PDF p.34)")
        self.directoryRootCell = SimpleNamespace()
        drc = self.directoryRootCell
        drc.flagField = self.getHalfword(
            0, "1\tFlag field", True)
        flags = ("SRN_FLAG", "ADDR_FLAG", "COMPOOL_FLAG", "FC_FLAG", 
                 "OVERFLOW_FLAG", "NON_MONOTONIC_SRN_FLAG", 
                 "NON_UNIQUE_SRN_FLAG", "NOTRACE_FLAG", "HIGHOPT", "BIT_FLAG", 
                 "HALMAT_FLAG", "FCDATA_FLAG", "SDL_FLAG", "DATA_REMOTE", 
                 "REL6_FLAG", "NEW_FLAG")
        for i in range(16):
            doit = 1 & (drc.flagField >> (15 - i))
            if not doit:
                continue
            msg = f"\t\tBit {i}\t{flags[i]}: "
            msg += str(doit)
            self.vprint(msg)
        flagSRN = drc.flagField & 0x8000
        flagADDR = drc.flagField & 0x4000
        drc.numberOfLastPhysicalRecord = self.getHalfword(
            2, "2\tNumber of last physical record")
        drc.dateOfFileCreation = self.getFullword(
            4, 
            "3\tDate of file creation (1000 * (year - 1900) + day of the year)")
        drc.yearOfFileCreation = drc.dateOfFileCreation // 1000
        drc.dayOfFileCreation = \
            drc.dateOfFileCreation - 1000 * drc.yearOfFileCreation
        drc.year = drc.yearOfFileCreation + 1900
        drc.month, drc.day = self.dayOfYearToDate(drc.dayOfFileCreation, 
                                                  year=drc.year)
        self.vprint(f"\t\t{drc.year}-{'%02d' % drc.month}-{'%02d' % drc.day}")
        drc.timeOfFileCreation = self.getFullword(
            8, "4\tTime of file creation (centiseconds since midnight)")
        drc.hour, drc.minute, drc.second = \
            self.centisecondsToHMS(drc.timeOfFileCreation)
        self.vprint(f"\t\t{'%02d' % drc.hour}:{'%02d' % drc.minute}:" + \
                    "{'%02d' % drc.second}")
        drc.numberOfLastDirectoryPhysicalRecord = self.getHalfword(
            12, "5\tNumber of last directory physical record")
        drc.numberOfExternalBlocks = self.getHalfword(
            14, "6\tNumber of EXTERNAL blocks")
        drc.numberOfBlockIndices = self.getHalfword(
            16, "7\tNumber of block indices")
        drc.numberOfSymbols = self.getHalfword(
            18, "8\tNumber of symbols")
        drc.pHeadOfBlockIndexTable = self.getPointer(
            20, "9\tHead of Block Index Table")
        drc.totalNumberOfEmittedAP101Instructions = self.getFullword(
            24, "10\tTotal Number of emitted AP-101 instructions generated")
        drc.indexInSymbolTableForNameOfCompilationUnit = self.getHalfword(
            28,
            "11a\tIndex in Symbol Index Table for compilation-unit name")
        drc.indexIntoSymbolTableForAllInternalSymbols = self.getHalfword(
            30, "11b\tIndex into Symbol Index Table for linked list of all " + \
                "internal symbols order alphabetically")
        drc.dOrPListHead = self.getHalfword(
            32, "12a\t#D or #P list head of compilation unit internal symbols")
        drc.rListHead = self.getHalfword(
            34, "12b\t#R list head of compilation unit remote data")
        drc.pFirstSymbolIndexTableEntry = self.getPointer(
            36, "13\tFirst Symbol Index Table entry")
        drc.numberOfStackWalkbackLoops = self.getHalfword(
            40, "14a\tNumber of stack walkback loops")
        drc.relativeAddressOfLiteralAreaInDCSECT = self.getHalfword(
            42, "14b\tRelative address of literal area in #D CSECT (65535 if does not exist)")
        drc.pCompilationUnitBlockDataCellHierarchical = self.getPointer(
            44, "15\tCompilation unit Block Data Cell (hierarchical tree)")
        drc.pHeadOfTheHALSBlockTreeAlphabetical = self.getPointer(
            48, "16\tHead of the HAL/S Block Tree (alphabetical)")
        drc.valueOfTheFirstISNInFile = self.getHalfword(
            52, "17\tValue of the first ISN in file")
        self.vprint("\t(ICD PDF p.35)")
        drc.valueOfTheLastISNInFile = self.getHalfword(
            54, "18\tValue of the last ISN in file")
        drc.numberOfExecutableStatements = self.getHalfword(
            56, "19\tNumber of executable and DECLARE statements")
        drc.numberOfStatements = self.getHalfword(
            58, "20\tNumber of statements")
        drc.pFirstStatementIndexTableEntry = self.getPointer(
            60, "21\tFirst Statement Index Table entry")
        drc.pFirstCellOfTheIncludeDataCellList = self.getPointer(
            64, "22\tFirst cell of the INCLUDE Data Cell list")
        drc.pFirstCellOfTheStatementExtentCellList = self.getPointer(
            68, "23\tFirst cell of the Statement Extent Cell list")
        drc.firstStatementReferenceNumberSRN = self.getText(
            72, 6, "24a\tFirst statement reference number (SRN)")
        drc.includeCountForFirstSRN = self.getHalfword(
            78, "24b\tInclude count for first SRN")
        drc.lastStatementReferenceNumberSRN = self.getText(
            80, 6, "25a\tLast statement reference number (SRN)")
        drc.includeCountForLastSRN = self.getHalfword(
            86, "25b\tInclude count for last SRN")
        drc.indexOfCompilationUnitBlockDataCell = self.getHalfword(
            88, "26\tIndex of compilation unit block data cell")
        drc.userDefinedCompilationUnitNumberCOMPUNIT = self.getHalfword(
            90, "27\tUser defined compilation unit (COMPUNIT)")
        drc.pTitleDataCell = self.getPointer(92, "28\tTitle Data Cell")
        self.vprint("\t29\t8 bytes reserved (user data)")
        drc.totalNumberOfSymbols = self.getFullword(
            104, "30\tTotal number of symbols")
        drc.totalNumberOfBytesOfReplaceText = self.getFullword(
            108, "31\tTotal number of bytes of REPLACE text")
        drc.totalNumberOfBytesInLiteralTable = self.getFullword(
            112, "32\tTotal number of bytes in literal table")
        drc.totalFreeCellSpace = self.getHalfword(
            116, "33\tTotal free cell space")
        drc.comsubParameterEnd = self.getHalfword(
            118, "34\tCOMSUB parameter end")
        self.vprint("\t(ICD PDF p.36)")
        drc.numberOfXrefTableEntries = self.getFullword(
            120, "35\tNumber of XREF table entries")
        drc.numberOfSymbolsSpecifiedInParmField = self.getFullword(
            124, "36\tNumber of symbols specified in PARM field")
        drc.noBytesSpecifiedForReplaceTextInParmField = self.getFullword(
            128, "37\tNo. bytes specified for REPLACE text in PARM field")
        drc.noCharactersSpecifiedForLiteralsInParmField = self.getFullword(
            132, "38\tNo. characters specified for literals in PARM field")
        drc.numberOfXrefEntriesSpecifiedInParmField = self.getFullword(
            136, "39\tNumber of XREF entries specified in PARM field")
        drc.compilerIdentification = self.getText(
            140, 12, "40\tCompiler identification")
        drc.pCardtypeDataCell = self.getPointer(
            152, "41\tCARDTYPE Data Cell")
        drc.pInitializationTable = self.getPointer(
            156, "42\tInitialization Table")
        drc.halfwordsInInitializationTable = self.getFullword(
            160, "43\t# halfwords in initialization table")
        self.vprint("\t44-47\tUnused")
        drc.offsetToStartOfTopLiteralAreaInD = self.getHalfword(
            168, "48\tOffset to start of top literal area in #D")
        drc.offsetToEndOfTopLiteralAreaInD = self.getHalfword(
            170, "49\tOffset to end of top literal area in #D")
        drc.pLiteralExtentTable = self.getPointer(172, "50\tLiteral extent table")
        drc.numberOfEntriesInLiteralExtentTable = self.getFullword(
            176, "51\tNumber of entries in literal extent table")
        drc.pFunctionIndexTable = self.getPointer(180, "52\tFunction Index Table")
        drc.numberOfEntriesInFunctionIndexTable = self.getHalfword(
            184, "53\tNumber of entries in function index table")
        self.vprint("\t54-62\tUnused")
        
        # 2.2.2.2.1.1. Title Data Cell
        self.vprint("Title Data Cell (ICD PDF p.42)")
        self.offsetForGet = drc.pTitleDataCell
        self.titleDataCell = SimpleNamespace()
        self.titleDataCell.noOfTitleCharacters = self.getByte(
            0, "1\tNo. of characters in TITLE")
        self.titleDataCell.titleContents = self.getText(
            1, self.titleDataCell.noOfTitleCharacters, "2\tTitleContents")
        
        # 2.2.2.2.1.2. CARDTYPE Data Cell
        self.vprint("CARDTYPE Data Cell (ICD PDF p.43)")
        self.offsetForGet = drc.pCardtypeDataCell
        self.cardtypeDataCell = SimpleNamespace()
        self.cardtypeDataCell.noOfCardtypeCharacters = self.getByte(
            0, "1\tNo. of characters in CARDTYPE")
        self.cardtypeDataCell.cardtypeText = self.getText(
            1, self.cardtypeDataCell.noOfCardtypeCharacters, "2\tText of CARDTYPE")
        
        # 2.2.2.2.1.3. Initialization Table
        self.vprint("Initialization Table (ICD PDF p.44)")
        self.initializationTable = []
        self.offsetForGet = drc.pInitializationTable
        for i in range(drc.halfwordsInInitializationTable):
            self.initializationTable.append(self.getHalfword(
                i, f"1\tInitialization value {i+1}", hex=True))
        
        # 2.2.2.2.2. Include Text Data
        self.vprint("Include Text Data (ICD PDF p.45)")
        includeTextData = []
        self.includeTextData = SimpleNamespace()
        self.offsetForGet = drc.pFirstCellOfTheIncludeDataCellList
        includeCellNumber = 0
        if self.offsetForGet == 0:
            self.vprint("\t(None)")
        while self.offsetForGet != 0:
            includeCellNumber += 1
            self.vprint(f"\tInclude Data Cell {includeCellNumber}")
            self.includeTextData.cell = {}
            self.includeTextData.cell["1"] = self.getPointer(
                0, "1\tNext member in the include cell chain", indent=2)
            self.includeTextData.cell["2"] = self.getText(
                4, 8, "2\tInclude library member name", indent=2)
            self.includeTextData.cell["3"] = self.getHalfword(
                12, "3\tRevision number", indent=2)
            self.includeTextData.cell["4"] = self.getHalfword(
                14, "4\tCatenation number", indent=2)
            self.includeTextData.cell["5"] = self.getByte(
                16, "5\tFlag bits", hex=True, indent=2)
            if (self.includeTextData.cell["5"] & 0x80) != 0:
                self.vprint("\t\t\tBit 0\tThe member is an SDF")
            if (self.includeTextData.cell["5"] & 0x40) != 0:
                self.vprint("\t\t\tBit 1\tMember located by OUTPUT5 DD")
            if (self.includeTextData.cell["5"] & 0x20) != 0:
                self.vprint("\t\t\tBit 2\tMember located by HALSDF DD")
            if (self.includeTextData.cell["5"] & 0x10) != 0:
                self.vprint("\t\t\tBit 3\tMember located by OUTPUT8 DD")
            if (self.includeTextData.cell["5"] & 0x08) != 0:
                self.vprint("\t\t\tBit 4\tMember located by OUTPUT6 DD")
            if (self.includeTextData.cell["5"] & 0x04) != 0:
                self.vprint("\t\t\tBit 5\tMember located by INCLUDE DD")
            if (self.includeTextData.cell["5"] & 0x02) != 0:
                self.vprint("\t\t\tBit 6\tTEMPLATE (D INCLUDE TEMPLATE)")
            if (self.includeTextData.cell["5"] & 0x01) != 0:
                self.vprint("\t\t\tBit 7\tREMOTE flag")
            self.includeTextData.cell["6"] = self.getByte(
                17, "6\tNumber of SRN's", indent=2)
            self.includeTextData.cell["7"] = []
            self.vprint("\t\tSRN's:")
            for i in range(self.includeTextData.cell["6"]):
                self.includeTextData.cell["7"].append(self.getText(
                    18 + 6 * i, 6, f"7\tSRN {i+1}", indent=3))
            self.offsetForGet = self.includeTextData.cell["1"]
        
        # 2.2.2.2.3.1. Block Index Table
        self.vprint("Block Index Table (ICD PDF p.48)")
        self.blockIndexTable = []
        for blockNum in range(drc.numberOfBlockIndices):
            self.vprint(f"\tBlock {blockNum}")
            blockOffset = 12 * blockNum
            self.offsetForGet = drc.pHeadOfBlockIndexTable
            block = SimpleNamespace(pThisCell=self.offsetForGet)
            block.blockCsectName = self.getText(
                blockOffset, 8, "1\tBlock CSECT name", indent=2)
            asciiName = sdf.ascii
            block.pBlockDataCell = self.getPointer(
                blockOffset + 8, "2\tBlock data cell", indent=2)
            #block.cells = []
            self.offsetForGet = block.pBlockDataCell
            if True: #while self.offsetForGet != 0:
                self.vprint(f"\t\tBlock Data Cell (ICD PDF p.58)")
                cell = SimpleNamespace(pThisCell=self.offsetForGet)
                cell.pNextHigherMember = self.getPointer(
                    0, "1\tNext higher member in HAL/S block data cell tree", 
                    indent=3)
                cell.pNextLowerMember = self.getPointer(
                    4, "2\tNext lower member in HAL/S block data cell tree", 
                    indent=3)
                cell.pFirstNestedBlock = self.getPointer(
                    8, "3\tFirst nested block within the scope of this block", 
                    indent=3)
                cell.pNextSiblingMember = self.getPointer(
                    12, "4\tNext block at same level of enclosing block", 
                    indent=3)
                cell.pBlockSymbolExtentCell = self.getPointer(
                    16, "5\tBlock symbol extent cell for block", indent=3)
                bset = []
                oldOffsetForGet = self.offsetForGet
                self.offsetForGet = cell.pBlockSymbolExtentCell
                while self.offsetForGet != 0:
                    bsec = {}
                    bsec["successor"] = self.getPointer(
                        0, "1\tSuccessor", indent=4)
                    bsec["numberOfExtentEntries"] = self.getHalfword(
                        4, "2\tNumber of extent entries", indent=4)
                    bsec["pageNumberOfFirstRecord"] = self.getHalfword(
                        6, "3\tPage number of 1st physical record of symbol table index", indent=4)
                    offset = 8
                    extentEntries = []
                    for extentNo in range(bsec["numberOfExtentEntries"]):
                        ee = {}
                        ee[f"firstOffset"] = self.getHalfword(
                            offset, f"4\tFirst offset {extentNo+1}", indent=4)
                        offset += 2
                        ee[f"lastOffset"] = self.getHalfword(
                            offset, f"5\tLast offset {extentNo+1}", indent=4)
                        offset += 2
                        ee[f"startOfFirstSymbolName"] = self.getText(
                            offset, 8, f"6\tFirst symbol name {extentNo+1}", 
                            indent=4)
                        offset += 8
                        ee[f"startOfLastSymbolName"] = self.getText(
                            offset, 8, f"7\tLast symbol name {extentNo+1}", 
                            indent=4)
                        offset += 8
                        extentEntries.append(ee)
                    bsec["extentEntries"] = extentEntries
                    bset.append(bsec)
                    self.offsetForGet = bsec["successor"]
                cell.blockSymbolExtentTable = bset
                self.offsetForGet = oldOffsetForGet
                cell.symbolIndexNumberOfBlockName = self.getHalfword(
                    20, "6a\tSymbol index number of block name", indent=3)
                cell.unused = self.getHalfword(
                    22, "6b\tUnused", indent=3)
                cell.flagBits = self.getByte(
                    24, "7\tFlag bits", hex=True, indent=3)
                flags = ("REENTRANT flag", "EXCLUSIVE flag", "ACCESS flag",
                         "RIGID flag", "EXTERNAL flag",
                         "NONHAL flag", "(Unused)", "(Unused)")
                for i in range(8):
                    doit = 1 & (cell.flagBits >> (7 - i))
                    if not doit:
                        continue
                    msg = f"\t\t\t\tBit {i}\t{flags[i]}: "
                    msg += str(doit)
                    self.vprint(msg)
                cell.VersionNoOfBlockTemplate = self.getByte(
                    25, "8\tVersion no. of block template", indent=3)
                cell.blockIndexNumberInBlockIndexTable = self.getHalfword(
                    26, "9\tBlock index number in the block index table", 
                    indent=3)
                cell.blockID = self.getHalfword(
                    28, "10\tBlock ID", indent=3)
                cell.blockCategory = self.getByte(
                    30, "11\tBlock category", hex=True, indent=3)
                blockCategories = ("(Unknown)", "PROGRAM", "PROCEDURE",
                                   "FUNCTION", "COMPOOL", "TASK", "UPDATE")
                self.vprint("\t\t\t\t" + blockCategories[cell.blockCategory])
                cell.functionType = self.getByte(
                    31, "12\tFunction type", hex=True, indent=3)
                functionTypes = ("(None)", "BIT (16 bits)", "CHARACTER",
                                 "MATRIX (SP)", "VECTOR (SP)", "SCALAR (SP)",
                                 "INTEGER (SP)",
                                 "(Not used)", "(Not used)", "BIT (32 bits)",
                                 "(Not used)", "MATRIX (DP)", "VECTOR (DP)",
                                 "SCALAR (DP)", "INTEGER (DP)",
                                 "(Unknown)", "STRUCTURE")
                self.vprint("\t\t\t\t" + functionTypes[cell.functionType])
                cell.indexToFirstSymbol = self.getHalfword(
                    32, "13\tIndex (in SIT) to first symbol of block", indent=3)
                cell.indexToLastSymbol = self.getHalfword(
                    34, "14\tIndex (in SIT) to last symbol of block", indent=3)
                cell.firstStmtNoOfHalsBlock = self.getHalfword(
                    36, "15\tFirst Stmt No. of HAL/S block", indent=3)
                cell.lastStmtNoOfHalsBlock = self.getHalfword(
                    38, "16\tLast Stmt No. of HAL/S block", indent=3)
                cell.isnOfFirstExecutableStmt = self.getHalfword(
                    40, 
                    "17a\tISN of 1st executable (non-DECLARE) statement", 
                    indent=3)
                cell.headOfStackFrameVariables = self.getHalfword(
                    42, "17b\tHead of stack frame variables (in address order)",
                    indent=3)
                cell.lengthOfBlockName = self.getByte(
                    44, "18\tLength of block name", indent=3)
                cell.blockName = self.getText(
                    45, cell.lengthOfBlockName, "19\tBlock name", indent=3)
                
                #block.cells.append(cell)
                #self.offsetForGet = cell.pNextHigherMember
            block.blockDataCell = cell
            self.blockIndexTable.append(block)
        
        # 2.2.2.2.4.1. Symbol Index Table
        if self.directoryRootCell.numberOfSymbols > 0:
            self.vprint("Symbol Index Table (ICD PDF p.61)")
            self.offsetForGet = 0
            tablePage, tableOffset = sdf.parsePointer(
                self.directoryRootCell.pFirstSymbolIndexTableEntry)
            self.symbolIndexTable = []
            for i in range(self.directoryRootCell.numberOfSymbols):
                self.vprint(f"\tSymbol {i+1}")
                offset = tableOffset + 12 * i
                page = tablePage + (offset // self.pageSize)
                offset = (page << 16) | (offset % self.pageSize)
                nameStart = self.getText(
                    offset, 8, "1\tFirst 8 characters of symbol name", 
                    indent=2)
                if nameStart[0] == 0x40:
                    self.vprint("\t\t\tNote: Structure-template names begin with a space")
                pDataCell = self.getPointer(
                    offset + 8, "2\tSymbol data cell", indent=2)
                self.vprint(f"\t\tSymbolDataCell (ICD PDF p.63)")
                symbolDataCell = self.parseSymbol(nameStart, pDataCell, 
                                                  indent=3)
                self.symbolIndexTable.append(SimpleNamespace(
                    nameStart=nameStart,
                    pDataCell=pDataCell,
                    symbolDataCell=symbolDataCell
                ))
        
        # 2.2.2.2.5. Statement Index Table
        if drc.pFirstStatementIndexTableEntry != 0:
            self.vprint("Statement Index Table (ICD PDF p.98)")
            self.statementIndexTable = []
            offset = 0
            for stmtNo in range(drc.valueOfTheFirstISNInFile - 1, 
                                drc.valueOfTheLastISNInFile):
                self.vprint(f"\tStatement {stmtNo+1} (ICD PDF p.101)")
                self.offsetForGet = drc.pFirstStatementIndexTableEntry
                statement = SimpleNamespace(pThisCell=sdf.vmpPlusOffset(self.offsetForGet, offset))
                if flagSRN:
                    statement.srn = self.getText(
                        offset, 6, "1\tStatement Reference Number (SRN)", 
                        indent=2)
                    offset += 6
                    statement.includeCount = self.getHalfword(
                        offset, "2\tINCLUDE count", indent=2)
                    offset += 2
                pStatementData = self.getPointer(
                    offset, "3\tStatement data", indent=2, inversion=True)
                statement.pStatementData = pStatementData
                offset += 4
                if pStatementData == 0:
                    self.vprint("\t\t\tImplementation error?  Pointer was 0.")
                elif not self.pointerInverted:
                    self.vprint("\t\t\tExecutable statement (ICD PDF p.103)")
                    oldOffset = offset
                    self.offsetForGet = statement.pStatementData
                    # We need to read "Statement Category" as little out of 
                    # order, because we need some of the flags in it immediately.
                    statementCategory = self.getByte(2)
                    flagOriginalSRN = statementCategory & 0x80
                    flagPresentLHS = statementCategory & 0x40
                    flagPresentRHS = statementCategory & 0x20
                    offset = -8
                    if flagPresentRHS:
                        offset -= 4
                    if flagPresentLHS:
                        offset -= 4
                        statement.lhsStatementVariables = self.getPointer(
                            offset, "0a\tLHS statement variable list", indent=3)
                        offset += 4
                    if flagPresentRHS:
                        statement.rhsStatementVariables = self.getPointer(
                            offset, "0b\tRHS statement variable list", indent=3)
                        offset += 4
                    statement.flagField = self.getHalfword(
                        offset, "0c\tFlag Field", indent=3)
                    offset += 2
                    flagMultiBitMask = statement.flagField & 0x0200
                    if flagMultiBitMask:
                        self.vprint("\t\t\t\tBit 6\tMulti-instruction bit-mask")
                    # Unused halfword:
                    offset += 2
                    statement.halmatCellPointer = self.getPointer(
                        offset, "0e\tHALMAT cell pointer", indent=3)
                    offset += 4
                    if offset != 0:
                        print("Implementation error, offset != 0", 
                              file=sys.stderr)
                        exit(1)
                    statement.halsBlockIndex = self.getHalfword(
                        0, "1\tHAL/S block index", indent=3)
                    statement.statementCategory = self.getByte(
                        2, "2\tStatement category", hex=True, indent=3)  # Reread, to print message.
                    if flagOriginalSRN:
                        self.vprint("\t\t\t\tBit 0\tOriginal SRN present")
                    if flagPresentLHS:
                        self.vprint("\t\t\t\tBit 1\tValid LHS pointer")
                    if flagPresentRHS:
                        self.vprint("\t\t\t\tBit 2\tValid RHS pointer")
                    statementSubtype = 3 & (statementCategory >> 3)
                    self.vprint(f"\t\t\t\tBit 3-4\tStatement subtype = {statementSubtype}")
                    statementContext = statementCategory & 7
                    self.vprint(f"\t\t\t\tBit 5-7\tStatement context information = {statementContext}")
                    if statementContext == 1:
                        self.vprint("\t\t\t\t\tELSE statement")
                    if statementContext == 2:
                        self.vprint("\t\t\t\t\tTHEN statement")
                    if statementContext == 4:
                        self.vprint("\t\t\t\t\tON ERROR reference")
                    statementType = self.getByte(
                        3, "3\tStatement type", indent=3)
                    statement.statementType = statementType
                    statementTypes = (
                        "Null", "?", "CALL", "?", "?", "IF Condition", "CLOSE",
                        "RETURN", "END", "SCHEDULE", "?", "WAIT",
                        "UPDATE PRIORITY", "SET, SIGNAL, RESET", "SEND ERROR", 
                        "ON ERROR", "FILE", "DO", "DO WHILE, DO UNTIL", 
                        "DO FOR", "DO CASE", "DECLARE", "BLOCK HEADER", 
                        "EQUATE", "TEMPORARY", "(Not used)", "(Not used)", 
                        "(Not used)", "(Not used)", "(Not used)", "(Not used)", 
                        "%NAMEBIAS", "%SVC", "%NAMECOPY", "%COPY", "%SVCI", 
                        "%NAMEADD"
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
                    self.vprint(f"\t\t\t\t{s}")
                    numberOfLabelIndexes = self.getByte(
                        4, "4\tNumber of label indexes", indent=3)
                    statement.numberOfLabelIndexes = numberOfLabelIndexes
                    numberOfLhsHalfwords = self.getByte(
                        5, "5\tNumber of LHS halfwords", indent=3)
                    statement.numberOfLhsHalfwords = numberOfLhsHalfwords
                    offset = 6
                    if numberOfLabelIndexes > 0:
                        for i in range(numberOfLabelIndexes):
                            label = self.getHalfword(
                                offset, f"6\tLabel {i+1}", indent=3)
                            offset += 2
                            symbolCell = self.symbolIndexTable[label - 1]
                            nameASCII = sdf.fullSymbolASCII(symbolCell)
                            self.vprint(f"\t\t\t\t{nameASCII}")
                    if numberOfLhsHalfwords > 0:
                        for i in range(numberOfLhsHalfwords):
                            lhs = self.getHalfword(
                                offset, f"7\tLHS {i+1}", indent=3)
                            offset += 2
                    if flagADDR:
                        statement.memoryAddress1 = self.get3QuarterWord(
                            offset, "8\tMemory address #1 (relative)", 
                            hex=True, indent=3)
                        offset += 3
                        statement.memoryAddress2 = self.get3QuarterWord(
                            offset, "9\tMemory address #2 (relative)", 
                            hex=True, indent=3)
                        offset += 3
                    if flagOriginalSRN:
                        statement.originalSRN = self.getText(
                            offset, 6, "10\tOriginal SRN", indent=3)
                    offset = oldOffset
                    self.statementIndexTable.append(statement)
                else:
                    self.vprint("\t\t\tDeclaration statement (ICD PDF p.109)")
                    oldOffset = offset
                    self.offsetForGet = statement.pStatementData
                    statement.halsBlockIndex = self.getHalfword(
                        0, "1\tHAL/S block index", indent=3)
                    statement.flagField = self.getByte(
                        2, "2\tFlag field", hex=True, indent=3)
                    flagA = statement.flagField & 0x80
                    flagB = statement.flagField & 0x40
                    flagC = statement.flagField & 0x20
                    if flagA:
                        self.vprint("\t\t\t\tExpression cell pointer present")
                    if flagB:
                        self.vprint("\t\t\t\tHALMAT cell pointer present")
                    if flagC:
                        self.vprint("\t\t\t\tOriginal SRN present")
                    statement.statementType = self.getByte(
                        3, "3\tStatement type", indent=3)
                    if statement.statementType == 21:
                        self.vprint("\t\t\t\tDECLARE statement")
                    elif statement.statementType == 23:
                        self.vprint("\t\t\t\tEQUATE statement")
                    elif statement.statementType == 24:
                        self.vprint("\t\t\t\tTEMPORARY variable declaration")
                    elif statement.statementType == 25:
                        self.vprint("\t\t\t\tREPLACE statement")
                    elif statement.statementType == 26:
                        self.vprint("\t\t\t\tSTRUCTURE definition")
                    else:
                        self.vprint("\t\t\t\t(Unknown type)")
                    offset = 4
                    if flagA:
                        statement.pExpressionVariablesCell = self.getPointer(
                            offset, "4\tExpression variables cell", indent=3)
                        offset += 4
                    
                    if flagB:
                        statement.pHalmatCell = self.getPointer(
                            offset, "5\tHALMAT cell", indent=3)
                        offset += 4
                    
                    if flagC:
                        statement.originalSRN = self.getText(
                            offset, 6, "6\tOriginal SRN", indent=3)
                        offset += 6
                    offset = oldOffset
                    self.statementIndexTable.append(statement)
        
