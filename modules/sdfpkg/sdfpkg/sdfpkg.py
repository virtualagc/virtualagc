#!/usr/bin/env python
'''
License:    Declared to be in the Public Domain in the U.S. by its author
            (Ron Burkey), and may be used, modified, or distributed freely for
            any purpose whatever.
Filename:   sdfpkg.py
Purpose:    Mimics the action of SDFPKG as described in document 
            SFOC-PASS0092, the "SDFPKG User's Guide".
Reference:  https://www.ibiblio.org/apollo
Contact:    Ron Burkey <info@sandroid.org>
History:    2026-07-05 RSB  Began.
            2026-07-14 RSB  Replaced my simple `vmem` module by the
                            imported `cmem` module instead.
            2026-07-16 RSB  Adapted from its original stand-alone implementation
                            (local git repo git/cmem on my computer) for use
                            as a module in the Virtual AGC source tree.

This file can be used either as a module or as a stand-alone program.  It 
contains a single class, plus a main program.  The provided Python classe is
`sdfpkg`, which wraps the separate `cmem` and `sdf` clases in methods that are 
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
of those, run "sdfpkg.py --sdf='SOMESDF' --show-dict" to get a listing of
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
together will also instantiate `sdf` and `cmem` classes:

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
'''

import sys
import os
from datetime import datetime, timedelta
from types import SimpleNamespace

# Import `sdf`, `cmem`, and `asciiToEbcdic` modules in such a way that they'll
# be automatically installed via pip if they're missing.
_pathToVAGC = os.path.dirname(os.path.realpath(__file__)) + "/../../.."
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
for i in range(2):
    try:
        from sdf import sdf
    except ImportError as error:
        pipIt(i, _pathToVAGC, error.name)

# Disposition parameters, occupying the most-significant nibble of the mode
# word passed to MONITOR(22).  See section 13 of the SDFPKG User's Guide, and
# note that HALSTAT really does use them: MONITOR(22,"20000009") carries the
# comment "RELEASE PREVIOUS SYMBOL".
DISP_SELECT = 0x8
DISP_MODF = 0x4
DISP_RELS = 0x2
DISP_RESV = 0x1

# Symbol classes and types, from ##DRIVER.xpl.  Only the ones CHKMATCH cares
# about are named here.
SCLASS_LABEL = 2
SCLASS_FUNC = 3
STYPE_IORS = 8

# Bits of the first flag byte of a Symbol Data Cell, i.e. of the most
# significant byte of the fullword at offset 8.
SFLAG1_TEMPLATE = 0x02
SFLAG1_UNQUALIFIED = 0x01


class sdfpkg:
    c = None
    s = None
    COMMTABL = None
    commtablAddress = None

    def __init__(self, memoryModel, sdflibName, COMMTABL):
        self.c = cmem(memoryModel, sdflibName)
        self.s = sdf(self.c)
        self.COMMTABL = COMMTABL
        # Which SDF `self.s` currently holds a parse of, so that selecting a
        # different one re-parses rather than answering from stale tables.
        self.parsedName = None
        # The block a mode 8, 11 or 12 call last established.  Mode 13 searches
        # within it, and per the User's Guide "a Mode 13 call must have been
        # preceded at some point by a Mode 8, 11, or 12 call".
        self.searchBlock = None
        # (name, symbol number) of the last symbol mode 13 returned, so that
        # "successive mode 13 calls are legal" resumes rather than repeating.
        self.lastSymbolFound = None

    # -- helpers ---------------------------------------------------------------

    def _parse(self):
        '''Make sure `self.s` holds a parse of whichever SDF is selected.'''
        if self.c.current is None:
            cmem.abend(4010)
        if self.parsedName != self.c.current:
            self.s.parseSDF()
            self.parsedName = self.c.current
            self.searchBlock = None
            self.lastSymbolFound = None

    def _reply(self, disp, **fields):
        '''Store the outputs of a successful mode call into COMMTABL, both the
        copy in `mem` and the caller's dictionary, then apply the disposition
        parameters to the page the call just located.
        '''
        fields.setdefault("CRETURN", 0)
        self.c.fromNative(fields)
        self.COMMTABL.update(self.c.toNative())
        if disp & (DISP_MODF | DISP_RELS | DISP_RESV):
            # Mode 6 takes only MODF/RESV/RELS; SELECT has already been dealt
            # with, and passing it on would be meaningless.
            self.c.monitor22(((disp & 0x7) << 28) | 6)
            self.COMMTABL.update(self.c.toNative())

    def _fail(self, code):
        '''Store a failure return code.  ADDR and PNTR are zeroed so that a
        caller which forgets to check CRETURN gets an obviously bad pointer
        rather than whatever the previous call happened to leave behind.
        '''
        self.c.fromNative({"CRETURN": code, "ADDR": 0, "PNTR": 0})
        self.COMMTABL.update(self.c.toNative())

    @staticmethod
    def _flag1(symbolDataCell):
        return (symbolDataCell.flagBits >> 24) & 0xFF

    def _symbolName(self, i):
        '''Full ASCII name of symbol number i (1-based, as SYMBNO is).'''
        return sdf.fullSymbolASCII(self.s.symbolIndexTable[i - 1])

    def _validBlock(self, blkno):
        return 1 <= blkno <= len(self.s.blockIndexTable)

    def _blockNodeVmp(self, blkno):
        # Block numbers are 1-based, as symbol and statement numbers are:
        # a Directory Root Cell reporting indexOfCompilationUnitBlockDataCell
        # as 1 means blockIndexTable[0].
        return sdf.vmpPlusOffset(
            self.s.directoryRootCell.pHeadOfBlockIndexTable, 12 * (blkno - 1))

    def _relativeAddress(self, symbol):
        '''RELADDR of a Symbol Data Cell, read the way the assembly reads it.

        SYMBDC puts SYMBLEN (one byte, offset 12) immediately before RELADDR
        (three bytes, offset 13), which is why CR13079 loads a fullword at
        SYMBLEN and masks the top byte off:

            L  R4,SYMBLEN
            N  R4,=X'00FFFFFF'

        Those three bytes are overloaded -- for a REPLACE label they hold a
        byte count, and for other class 2 and 3 symbols a statement number --
        and the parser accordingly only records `relativeMemoryAddressOfSymbol`
        for the classes where it really is an address.  The assembly makes no
        such distinction, so neither does this: read the raw bytes.
        '''
        addr = self.c.mode5(symbol.pDataCell)
        return int.from_bytes(self.c.mem[addr + 12:addr + 16], "big") \
            & 0x00FFFFFF

    def _symbolNodeVmp(self, symbno):
        return sdf.vmpPlusOffset(
            self.s.directoryRootCell.pFirstSymbolIndexTableEntry,
            12 * (symbno - 1))

    def _chkMatch(self, symbno):
        '''SDFPKG.ASM's CHKMATCH type filter, transcribed from SDFPKG.bal:

            CHKTYPE  CLI   FIRST,1        IF IN FIRST MODE, TAKE IT AND GO
                     BE    SYMFOUND
                     CLI   CLASS,2
                     BNE   NOT2
                     CLI   TYPE,8
                     BE    SKIPIT         EQUATE EXTERNAL
            NOT2     CLI   CLASS,3        NO PROBLEMS IF CLASSES 1,2 OR 3
                     BNH   SYMFOUND
                     TM    FLAG1,X'03'    IS IT AN UNQUALIFIED STRUC TERMINAL?
                     BC    5,SYMFOUND     OR A TEMPLATE HEADER???

        `BC 5` branches on condition codes 1 and 3, i.e. on "some of the tested
        bits are set" and "all of them are", so the last test accepts whenever
        FLAG1 & 0x03 is non-zero.  Note that this is the opposite of how the
        User's Guide describes the same algorithm ("If ... unqualified
        STRUCTURE or TEMPLATE, then skip symbol"); the assembly is what
        actually ran, so it wins.
        '''
        if self.c.first:
            return True
        cell = self.s.symbolIndexTable[symbno - 1].symbolDataCell
        if cell.symbolClass == SCLASS_LABEL and cell.symbolType == STYPE_IORS:
            return False                               # EQUATE EXTERNAL
        if cell.symbolClass <= SCLASS_FUNC:
            return True
        return 0 != (self._flag1(cell) & (SFLAG1_TEMPLATE | SFLAG1_UNQUALIFIED))

    def _findSymbolInBlock(self, block, name, startAfter=0):
        '''Return the number of the first symbol of `block` called `name` that
        survives CHKMATCH, or None.  SDFPKG binary-searches the symbol index
        table and then scans two ways from the hit; since the whole table is
        already parsed here, an ordered scan of the block's symbol range gives
        the same answer with far less that can go wrong.
        '''
        first = block.blockDataCell.indexToFirstSymbol
        last = block.blockDataCell.indexToLastSymbol
        for symbno in range(max(first, startAfter + 1), last + 1):
            if symbno < 1 or symbno > len(self.s.symbolIndexTable):
                break
            if self._symbolName(symbno) == name and self._chkMatch(symbno):
                return symbno
        return None

    def _findBlockByName(self, name):
        for blkno, block in enumerate(self.s.blockIndexTable, start=1):
            cell = block.blockDataCell
            if sdf.convertEbcdicToAscii(
                    cell.blockName[:cell.lengthOfBlockName]) == name:
                return blkno, block
        return None, None

    def _locateBlock(self, blkno, disp, extra=None):
        block = self.s.blockIndexTable[blkno - 1]
        cell = block.blockDataCell
        vmp = block.pBlockDataCell
        self.searchBlock = block
        self.lastSymbolFound = None
        fields = {
            "ADDR": self.c.mode5(vmp),
            "PNTR": vmp,
            "BLKNLEN": cell.lengthOfBlockName,
            "CSECTNAM": sdf.convertEbcdicToAscii(block.blockCsectName),
            "BLKNAM": sdf.convertEbcdicToAscii(
                cell.blockName[:cell.lengthOfBlockName]),
        }
        if extra:
            fields.update(extra)
        self._reply(disp, **fields)

    def _locateSymbol(self, symbno, disp, extra=None):
        symbol = self.s.symbolIndexTable[symbno - 1]
        vmp = symbol.pDataCell
        fields = {
            "ADDR": self.c.mode5(vmp),
            "PNTR": vmp,
            "SYMBNLEN": symbol.symbolDataCell.lengthOfSymbolName,
            "SYMBNAM": self._symbolName(symbno),
            "BLKNO": symbol.symbolDataCell.blockIndexNumber,
        }
        if extra:
            fields.update(extra)
        self._reply(disp, **fields)

    def _locateStatement(self, index, disp, extra=None):
        '''`index` is 0-based into statementIndexTable.'''
        statement = self.s.statementIndexTable[index]
        if statement.pStatementData == 0:
            self._fail(24)                     # Statement is non-executable
            return
        vmp = statement.pStatementData
        fields = {
            "ADDR": self.c.mode5(vmp),
            "PNTR": vmp,
            "BLKNO": statement.halsBlockIndex,
        }
        if getattr(statement, "srn", None) is not None:
            fields["SREFNO"] = sdf.convertEbcdicToAscii(statement.srn)
            fields["INCLCNT"] = statement.includeCount
        if extra:
            fields.update(extra)
        self._reply(disp, **fields)

    def _statementIndex(self, stmtno):
        '''Statement numbers are ISNs, which do not start at 1.  Returns the
        0-based index into statementIndexTable, or None if out of range.
        '''
        table = getattr(self.s, "statementIndexTable", None)
        if not table:
            return None
        index = stmtno - self.s.directoryRootCell.valueOfTheFirstISNInFile
        if index < 0 or index >= len(table):
            return None
        return index

    def _hasSRNs(self):
        return 0 != (self.s.directoryRootCell.flagField & 0x8000)

    # -- the mode call ---------------------------------------------------------

    def sdfpkg(self, mode, commtablAddress=None):
        '''Perform a function of SDFPKG.ASM.'''
        disp = (mode >> 28) & 0xF
        modeNumber = mode & 0x0000FFFF

        # Hand off operations which are virtual-memory manipulations to `cmem`.

        if modeNumber == 0:
            self.c.fromNative(self.COMMTABL, commtabl=commtablAddress)
            self.c.monitor22(mode, commtablAddress)
            self.COMMTABL.update(self.c.toNative())
            self.parsedName = None
            return

        if modeNumber in {1, 2, 3, 4, 5, 6}:
            self.c.fromNative(self.COMMTABL)
            self.c.monitor22(mode)
            self.COMMTABL.update(self.c.toNative())
            if modeNumber == 1:
                self.parsedName = None
                self.searchBlock = None
                self.lastSymbolFound = None
            return

        # Everything from here on is a search, which is answered from the
        # parsed representation of the SDF rather than by walking the trees in
        # virtual memory as SDFPKG.ASM did.  The *results* are still virtual
        # memory pointers and the addresses cmem pages them in at, because that
        # is what the caller goes on to read the cell's raw System/360-format
        # fields out of.

        if modeNumber not in {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}:
            cmem.abend(4016)

        self.c.fromNative(self.COMMTABL)
        if disp & DISP_SELECT:
            if not self.c.autoSelect():
                self.COMMTABL.update(self.c.toNative())
                return
        self._parse()

        if modeNumber == 7:
            vmp = self.s.masterDirectoryCell.pDirectoryRootCell
            self._reply(disp, ADDR=self.c.mode5(vmp), PNTR=vmp)
            return

        if modeNumber == 8:
            blkno = self.COMMTABL["BLKNO"] or 0
            if not self._validBlock(blkno):
                self._fail(16)
                return
            self._locateBlock(blkno, disp)
            return

        if modeNumber == 9:
            symbno = self.COMMTABL["SYMBNO"] or 0
            if symbno < 1 or symbno > len(self.s.symbolIndexTable):
                self._fail(20)
                return
            self._locateSymbol(symbno, disp)
            return

        if modeNumber == 10:
            index = self._statementIndex(self.COMMTABL["STMTNO"] or 0)
            if index is None:
                self._fail(36)                 # Outside legal range
                return
            self._locateStatement(index, disp)
            return

        if modeNumber == 11:
            blkno, block = self._findBlockByName(self.COMMTABL["BLKNAM"] or "")
            if block is None:
                self._fail(16)                 # No block found with that name
                return
            self._locateBlock(blkno, disp, {"BLKNO": blkno})
            return

        if modeNumber == 12:
            blkno, block = self._findBlockByName(self.COMMTABL["BLKNAM"] or "")
            if block is None:
                self._fail(16)
                return
            self.searchBlock = block
            self.lastSymbolFound = None
            name = self.COMMTABL["SYMBNAM"] or ""
            symbno = self._findSymbolInBlock(block, name)
            if symbno is None:
                self._fail(20)                 # Block found, symbol not
                return
            self.lastSymbolFound = (name, symbno)
            self._locateSymbol(symbno, disp, {
                "BLKNO": blkno,
                "SYMBNO": symbno,
                "CSECTNAM": sdf.convertEbcdicToAscii(block.blockCsectName),
            })
            return

        if modeNumber == 13:
            if self.searchBlock is None:
                # "A Mode 13 call must have been preceded at some point by a
                # Mode 8, 11, or 12 call."  SYMBSRCH checks SAVFSYMB and takes
                # ABEND8, which is 4020, "BLOCK NOT PREVIOUSLY SPECIFIED".
                cmem.abend(4020)
            name = self.COMMTABL["SYMBNAM"] or ""
            startAfter = 0
            if self.lastSymbolFound is not None \
                    and self.lastSymbolFound[0] == name:
                startAfter = self.lastSymbolFound[1]
            symbno = self._findSymbolInBlock(self.searchBlock, name, startAfter)
            if symbno is None:
                self.lastSymbolFound = None
                self._fail(20)                 # Symbol not found
                return
            self.lastSymbolFound = (name, symbno)
            self._locateSymbol(symbno, disp, {"SYMBNO": symbno})
            return

        if modeNumber == 14:
            if not self._hasSRNs():
                self._fail(28)                 # SDF does not have SRNs
                return
            srn = self.COMMTABL["SREFNO"] or ""
            inclcnt = self.COMMTABL["INCLCNT"] or 0
            table = getattr(self.s, "statementIndexTable", [])
            for index, statement in enumerate(table):
                if sdf.convertEbcdicToAscii(statement.srn) == srn \
                        and statement.includeCount == inclcnt:
                    stmtno = index + \
                        self.s.directoryRootCell.valueOfTheFirstISNInFile
                    self._locateStatement(index, disp, {"STMTNO": stmtno})
                    return
            self._fail(20)                     # SRN not found
            return

        if modeNumber == 15:
            blkno = self.COMMTABL["BLKNO"] or 0
            if not self._validBlock(blkno):
                self._fail(16)
                return
            block = self.s.blockIndexTable[blkno - 1]
            vmp = self._blockNodeVmp(blkno)
            self.searchBlock = block
            self.lastSymbolFound = None
            self._reply(disp, ADDR=self.c.mode5(vmp), PNTR=vmp,
                        CSECTNAM=sdf.convertEbcdicToAscii(block.blockCsectName))
            return

        if modeNumber == 16:
            symbno = self.COMMTABL["SYMBNO"] or 0
            if symbno < 1 or symbno > len(self.s.symbolIndexTable):
                self._fail(20)
                return
            vmp = self._symbolNodeVmp(symbno)
            self._reply(disp, ADDR=self.c.mode5(vmp), PNTR=vmp)
            return

        if modeNumber == 17:
            index = self._statementIndex(self.COMMTABL["STMTNO"] or 0)
            if index is None:
                self._fail(36)
                return
            statement = self.s.statementIndexTable[index]
            vmp = statement.pThisCell
            fields = {"ADDR": self.c.mode5(vmp), "PNTR": vmp}
            if getattr(statement, "srn", None) is not None:
                fields["SREFNO"] = sdf.convertEbcdicToAscii(statement.srn)
                fields["INCLCNT"] = statement.includeCount
            self._reply(disp, **fields)
            return

        if modeNumber == 18:
            # Careful: mode 18 means two different things.  The SDFPKG User's
            # Guide (SFOC-PASS0092, 02/08/99) documents it as "Deselect an SDF
            # (FSWAT C version only)".  Three months later CR13079 gave the
            # *assembly* a mode 18 of its own -- "FIND INIT DATA AT GIVEN #" --
            # and it is the assembly we are reproducing, so that is what is
            # implemented here.  Deselect is still available, as deselect().
            #
            #     INITDATA B     SYMB           - GET SYMBOL RELADDR IN R4
            #     GETINIT  L     R1,INITPTR     - R1 = INITIAL DATA POINTER
            #              N     R4,=X'00FFFFFF'  - MASK TO GET RELADDR FIELD
            #              AR    R4,R4          - MULTIPLY BY 2 FOR BYTE OFFSET
            #              ... normalize on 1680 and add to R1 ...
            #              CALL  LOCATE
            #
            # It is gated in the dispatcher by "CLI SDFVERS+1,33 / BH NEWCHECK",
            # SDFVERS being the version halfword at offset 0 of page 0, so only
            # an SDF newer than version 33 has initialization data to find.
            if self.s.masterDirectoryCell.phase3VersionNumber <= 33:
                cmem.abend(4016)
            symbno = self.COMMTABL["SYMBNO"] or 0
            if symbno < 1 or symbno > len(self.s.symbolIndexTable):
                self._fail(20)
                return
            symbol = self.s.symbolIndexTable[symbno - 1]
            reladdr = self._relativeAddress(symbol)
            vmp = sdf.vmpPlusOffset(
                self.s.directoryRootCell.pInitializationTable, 2 * reladdr)
            # INITDATA runs the whole mode 9 path first, so the symbol's own
            # outputs are reported too; only ADDR refers to the init data,
            # being the result of the last LOCATE the assembly performs.
            self._reply(disp,
                        ADDR=self.c.mode5(vmp),
                        PNTR=symbol.pDataCell,
                        SYMBNO=symbno,
                        SYMBNLEN=symbol.symbolDataCell.lengthOfSymbolName,
                        SYMBNAM=self._symbolName(symbno),
                        BLKNO=symbol.symbolDataCell.blockIndexNumber)
            return

    def deselect(self, name=None):
        '''Deselect an SDF: mode 18 of the FSWAT C build of SDFPKG, which the
        assembly spends on CR13079's initialization-data lookup instead.  Kept
        as a method of its own because it is genuinely useful -- it lets the
        FCB area be reused when many members are processed in turn -- and
        because a C port of this module may want to expose it as mode 18 again.
        '''
        if name is not None:
            self.COMMTABL["SDFNAM"] = name
        self.c.fromNative(self.COMMTABL)
        self.c.monitor22(18)
        self.COMMTABL.update(self.c.toNative())
        self.parsedName = None
        self.searchBlock = None
        self.lastSymbolFound = None

#------------------------------------------------------------------------------
def runTests(sdflibName, memberNames):
    '''Self-test.  Rather than hard-coding expected values against one
    particular SDF -- which would mean checking a binary fixture into the
    source tree and would only ever prove anything about that one file -- this
    drives every mode against whatever SDFs it is given and checks the answers
    against the independently-parsed representation of the same file.

    The property that matters most to a caller such as the HAL/S compiler's
    INCLUDE_SDF is that the ADDR a locate hands back really does point at the
    located cell's raw System/360-format bytes, since that is what it reads its
    fields out of.  So wherever a mode reports both a pointer and an address,
    the test reads the bytes back out of the memory model and requires them to
    agree with the parse.
    '''
    passed = 0
    failed = 0

    def check(desc, cond):
        nonlocal passed, failed
        if cond:
            print("PASS:", desc)
            passed += 1
        else:
            print("FAIL:", desc)
            failed += 1

    APGAREA = 0x100000
    COMMTABL_ADDRESS = 0x1000
    NPAGES = 250

    for member in memberNames:
        print(f"--- {sdflibName}/{member}.sdf")
        memoryModel = bytearray(APGAREA + (NPAGES + 1) * 1680)
        COMMTABL = {name: None for name, _, _ in cmem._COMMTABL_FIELDS}
        p = sdfpkg(memoryModel, sdflibName, COMMTABL)
        COMMTABL.update({"MISC": 0, "APGAREA": APGAREA, "AFCBAREA": 0,
                         "NPAGES": NPAGES, "NBYTES": 0, "ADDR": 0, "PNTR": 0})
        p.sdfpkg(0, COMMTABL_ADDRESS)
        check("mode 0 initializes", COMMTABL["CRETURN"] == 0)

        COMMTABL["SDFNAM"] = member
        p.sdfpkg(4)
        check("mode 4 selects the member", COMMTABL["CRETURN"] == 0)
        p.s.verbose = False
        p._parse()

        def word(addr):
            return int.from_bytes(memoryModel[addr:addr + 4], "big")

        def half(addr):
            return int.from_bytes(memoryModel[addr:addr + 2], "big")

        # --- mode 7, the directory root ------------------------------------
        p.sdfpkg(7)
        check("mode 7 locates the directory root cell",
              COMMTABL["CRETURN"] == 0
              and COMMTABL["PNTR"] == p.s.masterDirectoryCell.pDirectoryRootCell)
        drc = p.s.directoryRootCell
        check("mode 7's ADDR holds the root cell's raw bytes",
              half(COMMTABL["ADDR"]) == drc.flagField)

        # --- modes 8 and 15, blocks by number ------------------------------
        for blkno, block in enumerate(p.s.blockIndexTable, start=1):
            COMMTABL["BLKNO"] = blkno
            p.sdfpkg(8)
            check(f"mode 8 locates block {blkno}",
                  COMMTABL["CRETURN"] == 0
                  and COMMTABL["PNTR"] == block.pBlockDataCell)
            name = sdf.convertEbcdicToAscii(
                block.blockDataCell.blockName[
                    :block.blockDataCell.lengthOfBlockName])
            check(f"mode 8 reports block {blkno}'s name",
                  COMMTABL["BLKNAM"] == name
                  and COMMTABL["BLKNLEN"] == block.blockDataCell.lengthOfBlockName)
            check(f"mode 8's ADDR holds block {blkno}'s raw data cell",
                  word(COMMTABL["ADDR"]) == block.blockDataCell.pNextHigherMember)

            COMMTABL["BLKNO"] = blkno
            p.sdfpkg(15)
            check(f"mode 15 locates block node {blkno}",
                  COMMTABL["CRETURN"] == 0
                  and COMMTABL["PNTR"] == p._blockNodeVmp(blkno))
            check(f"mode 15's ADDR holds block node {blkno}'s pointer field",
                  word(COMMTABL["ADDR"] + 8) == block.pBlockDataCell)

            # --- mode 11, the same block by name --------------------------
            COMMTABL["BLKNAM"] = name
            p.sdfpkg(11)
            check(f"mode 11 finds block {blkno} by name",
                  COMMTABL["CRETURN"] == 0 and COMMTABL["BLKNO"] == blkno
                  and COMMTABL["PNTR"] == block.pBlockDataCell)

        COMMTABL["BLKNO"] = len(p.s.blockIndexTable) + 1
        p.sdfpkg(8)
        check("mode 8 rejects an out-of-range block number",
              COMMTABL["CRETURN"] == 16)
        COMMTABL["BLKNAM"] = "NOSUCHBLOCK"
        p.sdfpkg(11)
        check("mode 11 reports 16 for an unknown block name",
              COMMTABL["CRETURN"] == 16)

        # --- modes 9 and 16, symbols by number ------------------------------
        for symbno in range(1, len(p.s.symbolIndexTable) + 1):
            symbol = p.s.symbolIndexTable[symbno - 1]
            COMMTABL["SYMBNO"] = symbno
            p.sdfpkg(9)
            ok = (COMMTABL["CRETURN"] == 0
                  and COMMTABL["PNTR"] == symbol.pDataCell
                  and COMMTABL["SYMBNAM"] == sdf.fullSymbolASCII(symbol)
                  and COMMTABL["BLKNO"] == symbol.symbolDataCell.blockIndexNumber)
            check(f"mode 9 locates symbol {symbno}", ok)
            check(f"mode 9's ADDR holds symbol {symbno}'s raw data cell",
                  word(COMMTABL["ADDR"] + 8) == symbol.symbolDataCell.flagBits)

            COMMTABL["SYMBNO"] = symbno
            p.sdfpkg(16)
            check(f"mode 16 locates symbol node {symbno}",
                  COMMTABL["CRETURN"] == 0
                  and COMMTABL["PNTR"] == p._symbolNodeVmp(symbno))
            check(f"mode 16's ADDR holds symbol node {symbno}'s pointer field",
                  word(COMMTABL["ADDR"] + 8) == symbol.pDataCell)

        COMMTABL["SYMBNO"] = 0
        p.sdfpkg(9)
        check("mode 9 rejects symbol number 0", COMMTABL["CRETURN"] == 20)
        COMMTABL["SYMBNO"] = len(p.s.symbolIndexTable) + 1
        p.sdfpkg(9)
        check("mode 9 rejects an out-of-range symbol number",
              COMMTABL["CRETURN"] == 20)

        # --- modes 12 and 13, symbols by name -------------------------------
        for blkno, block in enumerate(p.s.blockIndexTable, start=1):
            first = block.blockDataCell.indexToFirstSymbol
            last = block.blockDataCell.indexToLastSymbol
            blockName = sdf.convertEbcdicToAscii(
                block.blockDataCell.blockName[
                    :block.blockDataCell.lengthOfBlockName])
            for symbno in range(max(1, first), min(last, len(p.s.symbolIndexTable)) + 1):
                if not p._chkMatch(symbno):
                    continue                # CHKMATCH would skip past it
                name = p._symbolName(symbno)
                COMMTABL["BLKNAM"] = blockName
                COMMTABL["SYMBNAM"] = name
                p.sdfpkg(12)
                # An earlier symbol of the same name legitimately wins, so
                # check the name rather than the number.
                check(f"mode 12 finds {blockName}.{name}",
                      COMMTABL["CRETURN"] == 0
                      and p._symbolName(COMMTABL["SYMBNO"]) == name
                      and COMMTABL["BLKNO"] == blkno)
                check(f"mode 12's ADDR holds {name}'s raw data cell",
                      word(COMMTABL["ADDR"] + 8)
                      == p.s.symbolIndexTable[
                          COMMTABL["SYMBNO"] - 1].symbolDataCell.flagBits)

                # Mode 13 searches the block mode 12 just established.
                COMMTABL["SYMBNAM"] = name
                p.sdfpkg(13)
                check(f"mode 13 continues the search for {name}",
                      COMMTABL["CRETURN"] in (0, 20))
            COMMTABL["BLKNAM"] = blockName
            COMMTABL["SYMBNAM"] = "NOSUCHSYMBOL"
            p.sdfpkg(12)
            check(f"mode 12 reports 20 for an unknown symbol in {blockName}",
                  COMMTABL["CRETURN"] == 20)

        # --- modes 10, 14 and 17, statements --------------------------------
        table = getattr(p.s, "statementIndexTable", [])
        firstISN = drc.valueOfTheFirstISNInFile
        for index, statement in enumerate(table):
            COMMTABL["STMTNO"] = firstISN + index
            p.sdfpkg(10)
            if statement.pStatementData == 0:
                check(f"mode 10 reports 24 for non-executable statement {index}",
                      COMMTABL["CRETURN"] == 24)
            else:
                check(f"mode 10 locates statement {index}",
                      COMMTABL["CRETURN"] == 0
                      and COMMTABL["PNTR"] == statement.pStatementData
                      and COMMTABL["BLKNO"] == statement.halsBlockIndex)

            COMMTABL["STMTNO"] = firstISN + index
            p.sdfpkg(17)
            check(f"mode 17 locates statement node {index}",
                  COMMTABL["CRETURN"] == 0
                  and COMMTABL["PNTR"] == statement.pThisCell)

            if p._hasSRNs() and statement.pStatementData != 0:
                COMMTABL["SREFNO"] = sdf.convertEbcdicToAscii(statement.srn)
                COMMTABL["INCLCNT"] = statement.includeCount
                p.sdfpkg(14)
                # Duplicate SRNs are legal, so only require that whatever was
                # found carries the SRN asked for.
                found = COMMTABL["CRETURN"] == 0 and COMMTABL["STMTNO"] is not None
                check(f"mode 14 finds statement {index} by its SRN",
                      found and sdf.convertEbcdicToAscii(
                          table[COMMTABL["STMTNO"] - firstISN].srn)
                      == sdf.convertEbcdicToAscii(statement.srn))

        if table:
            COMMTABL["STMTNO"] = firstISN - 1
            p.sdfpkg(10)
            check("mode 10 rejects a statement number below the first ISN",
                  COMMTABL["CRETURN"] == 36)
            COMMTABL["STMTNO"] = firstISN + len(table)
            p.sdfpkg(17)
            check("mode 17 rejects a statement number past the last ISN",
                  COMMTABL["CRETURN"] == 36)

        # --- mode 18, CR13079's initialization data --------------------------
        if p.s.masterDirectoryCell.phase3VersionNumber > 33:
            initPtr = drc.pInitializationTable
            for symbno in range(1, len(p.s.symbolIndexTable) + 1):
                symbol = p.s.symbolIndexTable[symbno - 1]
                # Independently of sdfpkg: read RELADDR straight out of the
                # located cell, which is what the assembly does.
                cellAddr = p.c.mode5(symbol.pDataCell)
                reladdr = int.from_bytes(
                    memoryModel[cellAddr + 12:cellAddr + 16], "big") & 0x00FFFFFF
                expected = sdf.vmpPlusOffset(initPtr, 2 * reladdr)
                COMMTABL["SYMBNO"] = symbno
                p.sdfpkg(18)
                check(f"mode 18 locates the init data of symbol {symbno}",
                      COMMTABL["CRETURN"] == 0
                      and COMMTABL["ADDR"] == p.c.mode5(expected)
                      and COMMTABL["PNTR"]
                      == p.s.symbolIndexTable[symbno - 1].pDataCell)
            COMMTABL["SYMBNO"] = len(p.s.symbolIndexTable) + 1
            p.sdfpkg(18)
            check("mode 18 rejects an out-of-range symbol number",
                  COMMTABL["CRETURN"] == 20)

        # --- deselect, which is the C build's mode 18 ------------------------
        p.deselect(member)
        check("deselect releases the member",
              COMMTABL["CRETURN"] == 0 and p.c.current is None)
        COMMTABL["SDFNAM"] = member
        p.sdfpkg(4)
        check("the member can be selected again after deselect",
              COMMTABL["CRETURN"] == 0)
        p._parse()

        # --- dispositions ----------------------------------------------------
        COMMTABL["BLKNO"] = 1
        p.sdfpkg((DISP_RESV << 28) | 8)
        reserved = [e for e in p.c.padSummary()["cached"] if e["resucnt"] > 0]
        check("a RESV disposition reserves the located page", len(reserved) == 1)
        COMMTABL["BLKNO"] = 1
        p.sdfpkg((DISP_RELS << 28) | 8)
        reserved = [e for e in p.c.padSummary()["cached"] if e["resucnt"] > 0]
        check("a RELS disposition releases it again", len(reserved) == 0)

        # --- SELECT (auto-select) --------------------------------------------
        COMMTABL["SDFNAM"] = member
        p.sdfpkg((DISP_SELECT << 28) | 7)
        check("a SELECT disposition selects and then locates",
              COMMTABL["CRETURN"] == 0
              and COMMTABL["PNTR"] == p.s.masterDirectoryCell.pDirectoryRootCell)
        COMMTABL["SDFNAM"] = "NOSUCH"
        p.sdfpkg((DISP_SELECT << 28) | 7)
        check("a SELECT of a missing SDF reports 8 and does not locate",
              COMMTABL["CRETURN"] == 8)

    print()
    print(f"{passed} passed, {failed} failed")
    return failed == 0


#------------------------------------------------------------------------------
# Stand-alone program.
if __name__ == "__main__":
    import pprint

    if "--test" in sys.argv:
        sdflibName = "SDFLIB"
        members = []
        for parm in sys.argv[1:]:
            if parm.startswith("--sdflib="):
                sdflibName = parm.split("=", 1)[1]
            elif parm.startswith("--sdf="):
                members.append(parm.split("=", 1)[1])
        if not members:
            # PASS3 names every SDF it writes "##" + the first 6 characters of
            # the underscore-stripped compilation-unit name, so anything in the
            # library not spelled that way is not one of ours and is left
            # alone.  Name it explicitly with --sdf= to test it anyway.
            members = sorted(f[:-4] for f in os.listdir(sdflibName)
                             if f.endswith(".sdf") and f.startswith("##"))
        if not members:
            print(f"No SDFs found in {sdflibName}/", file=sys.stderr)
            sys.exit(1)
        sys.exit(0 if runTests(sdflibName, members) else 1)

    memoryModel = bytearray(0x100000)
    COMMTABL = {
        "APGAREA": None, 
        "AFCBAREA": None, 
        "NPAGES": None, 
        "NBYTES": None,
        "MISC": None,
        "CRETURN": None, 
        "BLKNO": None, 
        "SYMBNO": None, 
        "STMTNO": None, 
        "BLKNLEN": None,
        "SYMBNLEN": None, 
        "PNTR": None, 
        "ADDR": None, 
        "SDFNAM": None, 
        "CSECTNAM": None,
        "SREFNO": None, 
        "INCLCNT": None, 
        "BLKNAM": None, 
        "SYMBNAM": None
        }
    commtablAddress = 0x1000 # Arbitrary address in `memoryModel`.
    
    mysdfpkg = sdfpkg(memoryModel,"SDFLIB", COMMTABL)
    
    npages = 1
    for parm in sys.argv:
        if parm.startswith("--npages="):
            npages = int(parm.split("=")[1])
            break
    COMMTABL["MISC"] = 0
    COMMTABL["APGAREA"] = 0x100000 # An arbitrary address
    COMMTABL["AFCBAREA"] = 0x10000 # an arbitrary address
    COMMTABL["NPAGES"] = npages
    COMMTABL["NBYTES"] = 1024
    COMMTABL["ADDR"] = 0
    COMMTABL["PNTR"] = 0
    mysdfpkg.sdfpkg(0, commtablAddress)
    #print("After mode 0:", COMMTABL)
    
    helpMsg = '''
This program reads (from stdin) an SDF as emitted by the HAL/S compiler's Phase
3, parses it, and produces a report.  It can also be used as an importable 
Python module.

For easy reference to documentation, ICD page numbers and field numbers are
added at strategic points in the report.  These correspond to the "HAL/S-FC 
SDL Interface Control Document", USA001556.

Usage as a stand-alone program:
    sdfParser.py --help
or
    sdfParser.py --sdf=SDFNAME [OPTIONS]

By SDFNAME, I mean things like "##NAVCOM".  The SDF's are assumed by the program
to be stored in the directory SDFLIB/ and to have the filename extension ".sdf",
i.e., the files have filenames like "SDFLIB/##NAVCOM.sdf", but the directory 
name and filename extension are omitted for the --sdf option.  Also, the --sdf
option should be positioned first on the command line.

If there are no OPTIONS other than --sdf specified, a report is printed in a 
hopefully human-readable format on stdout and then the program exits.  The other
available OPTIONS are:

--show-dict     Prints out a Python dictionary that's a representation of the 
                `sdf` class and then exits.  The elements of the class contain 
                the parsed SDF contents, while at the same time showing the 
                internal architecture of the class.  This is useful to have in 
                hand when coding software that imports sdfParser.py as a module
                and wants to use the parsed data in some way.

--interactive   Provides a command loop in which you can enter SDFPKG commands
                and examine the results.

--no-ansi       In interactive mode, ANSI escape sequences are used to make
                the user interface slightly less unattractive.  The --no-ansi
                switch disables those effects. 

--npages=N      Set the number of "pages" the virtual-memory system supports.
                The default is 1.

--summary       In the default mode (i.e., without --show-dict or 
                --interactive), causes a summary of the virtual-memory usage
                at the end.

Typical usage as a module is described in the program comments. 

'''
    menuMsg = '''
 0 - Initialize SDFPKG
 1 - Terminate SDFPKG
 2 - Augment Paging Area and/or FCB Area
 3 - Rescind Paging Area Augments
 4 - Select an SDF
 5 - Locate Pointer
 6 - Set Disposition Parameters
 7 - Locate Directory Root Cell
 8 - Locate Block Data Cell given Block Number
 9 - Locate Symbol Data Cell given Symbol Number
10 - Locate Statement Data Cell given Statement Number
11 - Locate Block Data Cell given Block Name
12 - Locate Symbol Data Cell given Block Name and Symbol Name
13 - Locate Symbol Data Cell given Only Symbol Name
14 - Locate Statement Data Cell given SRN
15 - Locate Block Node given Block Number
16 - Locate Symbol Node given Symbol Number
17 - Locate Statement Node given Statement Number
18 - Deselect an SDF
 Q - Quit this program

'''
    filename = None
    colorOn = "\033[32m"
    colorOff = "\033[0m"
    summarize = False
    for parm in sys.argv[1:]:
        if parm == "--help":
            print(helpMsg)
            sys.exit(0)
        if parm == "--no-ansi":
            colorOn = ""
            colorOff = ""
        if parm == "--show-dict":
            mysdfpkg.s.parseSDF()
            pprint.pprint(mysdfpkg.s.__dict__, sort_dicts=False, compact=True)
            sys.exit(0)
        if parm == "--interactive":
            mysdfpkg.s.parseSDF()
            while True:
                mode = input(menuMsg + \
                             f"{colorOn}Mode number>{colorOff} ").strip()
                if mode in ['q', 'Q']:
                    break
                try:
                    mode = int(mode)
                        
                    print(f"\n*** Mode {mode} not yet implemented ***")
                except:
                    print("I don't understand")
            sys.exit(0)
        if parm == "--summarize":
            summarize = True
        if parm.startswith("--npages="):
            pass
        if parm.startswith("--sdf="):
            fields = parm.split("=", 1)
            basename = fields[1]
            COMMTABL["SDFNAM"] = basename
            mysdfpkg.sdfpkg(4)
            #print("After mode 4:", COMMTABL)
    mysdfpkg.s.verbose = True
    mysdfpkg.s.parseSDF()
    
    if summarize:
        pprint.pprint(mysdfpkg.c.padSummary(), sort_dicts=False, compact=True)
