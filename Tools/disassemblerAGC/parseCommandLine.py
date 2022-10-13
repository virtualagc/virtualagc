#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       parseCommandLine.py
Purpose:        Parses command line for disassemblerAGC.py
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
                2022-10-07 RSB  Added --skip and --check.
                2022-10-08 RSB  Added --overlap, --hint, --ignore
                2022-10-09 RSB  Added --avoid
                2022-10-10 RSB  Added --parity.
                2022-10-13 RSB  Added --block1 and --blk2.
"""

import sys

#=============================================================================
# Parse command line.

# Turn a command-line string like NNNN or NN,NNNN into a fixed-memory address.
def toFixed(string):
    try:
        fields = string.split(",")
        if len(fields) == 1:
            value = int(fields[0], 8)
            if value < 0o4000 or value > 0o7777:
                print("Address out of range:", string)
                sys.exit(1)
            return value // 0o2000, value % 0o2000
        if len(fields) == 2:
            bank = int(fields[0], 8)
            offset = int(fields[1], 8)
            if bank < 0 or bank > 0o43 or offset < 0o2000 or offset > 0o3777:
                print("Address out of range:", string)
                sys.exit(1)
            return bank, offset % 0o2000
        else:
            print("Mangled address:", string)
            sys.exit(1)
    except:
        print("Mangled address:", string)
        sys.exit(1)

binFile = False
hardwareFile = False
debug = False
dump = False
dtest = False
dbasic = True
dbank = -1
dstart = -1
dend = -1
specialOnly = False
pattern = False
symbol = "SYMBOL"
specsFilename = ""
findFilename = ""
descent = False
flexFilename = ""
checkFilename = ""
skips = {}
disjoint = True
hintAfter = {}
ignore = []
avoid = []
parity = False
block1 = False
blk2 = False
entryPoints = [
    { "inBasic": True, "bank": 0o2, "offset": 0o0000, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(go)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0004, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(t6rupt)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0010, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(t5rupt)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0014, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(t3rupt)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0020, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(t4rupt)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0024, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(keyrupt1)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0030, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(keyrupt2)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0034, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(uprupt)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0040, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(downrupt)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0044, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(radar rupt)" },
    { "inBasic": True, "bank": 0o2, "offset": 0o0050, 
        "eb": 0, "fb": 0, "feb": 0, "symbol": "(hand controller rupt)" }
]

entryCount = 0
pBanks = ""
oBanks = ""
for param in sys.argv[1:]:
    if param == "--help":
        print('''
          Usage:    
                 disassemblerAGC.py [OPTIONS] <CORE >DISASSEMBLY    
          The input CORE is by default a .binsource file.  The OPTIONS:    
            --bin       CORE is a .bin file as output by yaYUL.    
            --hardware  CORE is a 'hardware' style .bin file.  If --bin    
                        is present, --hardware overrides it.    
            --debug     Turn on some debugging messages.    
            --dump      Dump the octals w/o disassembly.    
            --dtest     This causes a disassembly of a range of
                        addresses confined to a single fixed-memory bank.
                        For Block II the default address range is 02,2000
                        to 02,2050 with the 1st instruction being basic.
                        For Block I, the default is 01,6000 to 01,6034.
                        But these assumptions can be changed with the extra    
                        switches:
                            --dint      First instruction is interpretive.
                            --dbank=N   Bank number is N (octal).
                            --dstart=N  Starting offset is N (octal.
                            --dend==N   First address not assembled.    
            --special   Only print deduced special subroutines.    
            --pattern=S This is similar to --dtest, and takes the same    
                        optional extra command-line switches, but instead    
                        of providing a disassembly, instead provides a    
                        draft sample pattern (which typically requires    
                        manual tweaking) for use in searchSpecial.py.    
                        Note that --pattern overrides --dtest.  S is the    
                        symbol for the subroutine for the pattern.
                        Note that only patterns consisting entirely of
                        basic instructions are currently supported.
            --flex=F    If you have a file whose contents are patterns
                        such as those produced by the --pattern switch
                        described above, and possibly manually tweaked
                        afterward, you can use the --flex=F to read in
                        that file of patterns and append them to the 
                        special-subroutines search.  (See --special above.)
                        This is a more-flexible kind of search than those
                        performed in an automated way by the --specs/--find
                        switches (see below), though limited by its 
                        inability to perform erasable matches.
            --specs=F   Reads multiple pattern specifications from a file    
                        (F), similar to those used by --dtest and
                        --pattern. Outputs patterns in a form useful for
                        subsequent free-form matching in an alternate AGC
                        version. F is an ASCII file, with lines of the
                        form:    
                               SYMBOL BANK START [END] [I]    
                        END is optional, because if it is missing for a    
                        given line, then the START from the next line of    
                        the file is used as the END of the preceding line.    
                        The optional parameter 'I' is literal, and means    
                        that the starting location is interpretive rather    
                        than basic (which is the default).    
                        This switch overrides --pattern and --dtest.
            --find=F    Uses a specifications file as created by --specs,
                        and tries to find all of the patterns therein ...
                        presumably in a different rope than the one from 
                        which the file was created.
            --prio=B,... A list of banks (octal) which are searched first
                        with the --find switch.  By default, the banks are
                        searched in the order 00, 01, 02, ..., 43.
            --only=B,... A list of banks (octal) for --find.  If present,
                        only the listed banks are searched.
            --skip=S    In using the --find option, it just so happens that 
                        there may be several matchs for some symbol S defined
                        in the specification file.  One options for dealing
                        that situation is to instruct the disassembler to skip
                        the first match it finds for that symbol.  Using this
                        switch twice tells the disassmbler to skip the first 
                        2 matches of the symbol.  And so on.
            --check=F   Specifies an assembly-listing file that can be used for
                        double-checking the matches found.
            --overlap   By default program-label specifications are assumed to
                        be disjoint.  If they can overlap, use this switch.
            --hint=S1@S2 This is a hint that subroutine S1 must be at a higher
                        memory address than subroutine S2.  As many --hint
                        switches can be used as desired.
            --ignore=S  Simply ignore subroutine S.
            --avoid=BB,NNNN-MMMM Specify a fixed address range which should be 
                        avoided by the matching process.  You can use as many
                        of these switches as necessary.
            --parity    By default, the parity bit is ignored in input --bin
                        files and --hardware files.  The --parity switch 
                        enables it.  Binsource files are not affected.
            --blk2      Enables the BLK2 variant of the disassembler.  The
                        default is the Block II disassembler, but not the 
                        BLK2 variant.
            --block1    Enables the Block I varian of the disassembler.
            --descent   Disassemble with recursive descent, to try and reach
                        all of the reachable code.  This was originally 
                        intended to be the default functionality of the program
                        but is not presently functional with any degree of 
                        usability for Block II.  And I don't intend to support 
                        it at all for BLK2 or Block I.
            --basic=A   (Used only with --descent; see the entry above.)
                        Add basic address (NNNN or NN,NNNN octal)    
                        to list of entry points.  Multiple --basic    
                        switches can be used.  The interrupt lead-ins    
                        are always present by default, as well as an    
                        'special subroutines' that are known.    
            --interp=A  (Used only with --descent; see the entry above.)
                        Add interpretive address (NNNN or NN,NNNN octal)    
                        to list of entry points.  Multiple --interp    
                        switched can be used.    
               
          Note that for --bin and --hardware, we can't necessarily    
          determine that locations are unused vs merely containing 00000.    
        ''')
        sys.exit(0)
    elif param[:8] == "--basic=":
        bank, offset = toFixed(param[8:])
        superbank = 0
        if bank >= 0o40:
            superbank = 1
        entryCount += 1
        entryPoints.append( { "inBasic": True, "bank": bank, 
                             "offset": offset, "bb": bank << 10,
                             "feb": superbank, 
                             "symbol": "user%d" %entryCount } )
    elif param[:9] == "--interp=":
        bank, offset = toFixed(param[9:])
        superbank = 0
        if bank >= 0o40:
            superbank = 1
        entryCount += 1
        entryPoints.append( { "inBasic": False, "bank": bank, 
                             "offset": offset, "eb": 0, "fb": bank << 10,
                             "feb": superbank, 
                             "symbol": "user%d" %entryCount } )
    elif param == "--bin":
        binFile = True
    elif param == "--hardware":
        hardwareFile = True
    elif param == "--block1":
        block1 = True
    elif param == "--blk2":
        blk2 = True
    elif param == "--debug":
        debug = True
    elif param == "--dump":
        dump = True
    elif param[:10] == "--pattern=":
        pattern = True
        symbol = param[10:]
    elif param == "--dtest":
        dtest = True
    elif param[:8] == "--dbank=":
        dbank = int(param[8:], 8)
    elif param[:9] == "--dstart=":
        dstart = int(param[9:], 8)
    elif param[:7] == "--dend=":
        dend = int(param[7:], 8)
    elif param == "--dint":
        dbasic = False
    elif param in ["--special", "--specials"]:
        specialOnly = True
    elif param[:8] == "--specs=":
        specsFilename = param[8:]
    elif param[:8] == "--check=":
        checkFilename = param[8:]
    elif param[:7] == "--find=":
        findFilename = param[7:]
    elif param[:7] == "--flex=":
        flexFilename = param[7:]
    elif param[:7] == "--prio=":
        pBanks = param[7:]
    elif param[:7] == "--skip=":
        skip = param[7:]
        if skip not in skips:
            skips[skip] = 1
        else:
            skips[skip] += 1
    elif param[:7] == "--only=":
        oBanks = param[7:]
    elif param[:7] == "--hint=":
        fields = param[7:].split("@")
        if fields[0] in hintAfter:
            hintAfter[fields[0]].append(fields[1])
        else:
            hintAfter[fields[0]] = [fields[1]]
    elif param == "--descent":
        descent = True
    elif param == "--overlap":
        disjoint = False
    elif param[:9] == "--ignore=":
        ignore.append(param[9:])
    elif param[:8] == "--avoid=":
        fields = param[8:].split("-")
        leftFields = fields[0].split(",")
        avoid.append((int(leftFields[0], 8), int(leftFields[1], 8), 
                        int(fields[1], 8)))
    elif param == "--parity":
        parity = True
    else:
        print("Unrecognized option", param)
        sys.exit(1)
if hardwareFile:
    binFile = False
if block1:
    if dbank == -1:
        dbank = 0o01
    if dstart == -1:
        dstart = 0o6000
    if dend == -1:
        dend = 0o6034
else: # Block II
    if dbank == -1:
        dbank = 0o02
    if dstart == -1:
        dstart = 0o2000
    if dend == -1:
        dend = 0o2050

