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
for i in range(2):
    try:
        from sdf import sdf
    except ImportError as error:
        pipIt(i, _pathToVAGC, error.name)

class sdfpkg:
    c = None
    s = None
    COMMTABL= None
    commtablAddress=None
    
    def __init__(self, memoryModel, sdflibName, COMMTABL):
        self.c = cmem(memoryModel, sdflibName)
        self.s = sdf(self.c)
        self.COMMTABL = COMMTABL

    '''
    Perform a function of SDFPKG.ASM.
    '''
    def sdfpkg(self, mode, commtablAddress=None):
        mode = mode & 0x0000FFFF
        disp = mode & 0xF0000000
        
        # Hand off operations which are virtual-memory manipulations to `cmem`.
        
        if mode == 0:
            self.c.fromNative(self.COMMTABL, commtabl=commtablAddress)
            self.c.monitor22(mode, commtablAddress)
            self.COMMTABL.update(self.c.toNative())
            return
        
        if mode in { 1, 2, 3, 4, 5, 6, 18 }:
            self.c.fromNative(self.COMMTABL)
            self.c.monitor22(mode)
            self.COMMTABL.update(self.c.toNative())
            return
        
        # Otherwise, let us handle it here.
        
        if mode == 7:
            vmp = self.s.masterDirectoryCell.pDirectoryRootCell
            COMMTABL = {
                "CRETURN": 0,
                "ADDR": self.c.mode5(vmp),
                "PNTR": vmp
            }
            self.c.fromNative(COMMTABL) # Write to `COMMTABL` in `mem`.
            self.COMMTABL.update(self.c.toNative())
            self.c.monitor22(6, disp | 6) # Set disposition parameters.
            return
        
        if mode == 8:
            blkno = self.COMMTABL["BLKNO"]
            cell = self.s.blockIndexTable[blkno]
            dataCell = cell.blockDataCell
            vmp = cell.pThisCell
            COMMTABL = {
                "CRETURN": 0,
                "ADDR": self.c.mode5(vmp),
                "PNTR": vmp,
                "BLKNLEN": dataCell.lengthOfBlockName,
                "CSECTNAM": self.s.convertEbcdicToAscii(cell.blockCsectName),
                "BLKNAM": self.s.convertEbcdicToAscii(dataCell.blockName)
            }
            self.c.fromNative(COMMTABL) # Write to `COMMTABL` in `mem`.
            self.COMMTABL.update(self.c.toNative())
            self.c.monitor22(6, disp | 6) # Set disposition parameters.
            return None
        
        if mode == 9:
            symbno = self.COMMTABL["SYMBNO"] - 1
            if symbno >= 0 and symbno < len(self.s.symbolIndexTable):
                symbol = self.s.symbolIndexTable[symbno]
                symbnlen = symbol.symbolDataCell.lengthOfSymbolName
                if symbnlen <= 8:
                    symbnam = symbol.nameStart[:symbnlen]
                else:
                    symbnlen = symbol.nameStart + \
                               symbol.symbolDataCell.continuationOfSymbolName
                vmp = symbol.pDataCell
                COMMTABL = {
                    "CRETURN": 0,
                    "ADDR": self.c.mode5(vmp),
                    "PNTR": vmp,
                    "SYMBNLEN": symbnlen,
                    "SYMBNAM": symbnam,
                    "BLKNO": symbol.symbolDataCell.blockIndexNumber,
                    "MEMORY": page
                }
            else:
                COMMTABL = {
                    "CRETURN": 1,
                    "ADDR": 0,
                    "PNTR": 0
                }
            self.c.fromNative(COMMTABL) # Write to `COMMTABL` in `mem`.
            self.COMMTABL.update(self.c.toNative())
            self.c.monitor22(6, disp | 6) # Set disposition parameters.
            return
            
        if mode == 10:
            stmtno = self.COMMTABL["STMTNO"] - 1
            if stmtno >= 0 and stmtno < len(self.s.statementIndexTable):
                statement = self.s.statementIndexTable[stmtno]
                vmp = s.v.mode5(symbol.pThisCell)
                COMMTABL = {
                    "CRETURN": 0, # ***FIXME***
                    "ADDR": self.c.mode5(vmp),
                    "PNTR": vmp,
                    "SREFNO": statement.srn,
                    "INCLCNT": statement.includeCount,
                    "BLKNO": statement.halsBlockIndex
                }
            self.c.fromNative(COMMTABL) # Write to `COMMTABL` in `mem`.
            self.COMMTABL.update(self.c.toNative())
            self.c.monitor22(6, disp | 6) # Set disposition parameters.
            return
        
        if mode == 11:
            return 
        
        if mode == 12:
            return 
        
        if mode == 13:
            return 
        
        if mode == 14:
            return 
        
        if mode == 15:
            return 
        
        if mode == 16:
            symbno = self.COMMTABL["SYMBNO"] - 1
            if symbno >= 0 and symbno < len(self.s.symbolIndexTable):
                COMMTABL = {
                    "CRETURN": 0,
                    "ADDR": 0,
                    "PNTR": self.s.symbolIndexTable[symbno]
                }
            else:
                COMMTABL = {
                    "CRETURN": 1,
                    "ADDR": 0,
                    "PNTR": 0
                }
            self.c.fromNative(COMMTABL) # Write to `COMMTABL` in `mem`.
            self.COMMTABL.update(self.c.toNative())
            self.c.monitor22(6, disp | 6) # Set disposition parameters.
            return
            
        if mode == 17:
            return 
        
        cmem.abend(4016)

#------------------------------------------------------------------------------
# Stand-alone program.
if __name__ == "__main__":
    import pprint
    
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
