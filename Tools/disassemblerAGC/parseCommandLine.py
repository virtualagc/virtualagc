#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       parseCommandLine.py
Purpose:        Parses command line for disassemblerAGC.py
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
                2022-10-07 RSB  Added --skip.
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
dbank = 0o02
dstart = 0o0000
dend = 0o0050
specialOnly = False
pattern = False
symbol = "SYMBOL"
specsFilename = ""
findFilename = ""
descent = False
flexFilename = ""
skips = {}
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
            --basic=A   Add basic address (NNNN or NN,NNNN octal)    
                        to list of entry points.  Multiple --basic    
                        switches can be used.  The interrupt lead-ins    
                        are always present by default, as well as an    
                        'special subroutines' that are known.    
            --interp=A  Add interpretive address (NNNN or NN,NNNN octal)    
                        to list of entry points.  Multiple --interp    
                        switched can be used.    
            --bin       CORE is a .bin file as output by yaYUL.    
            --hardware  CORE is a 'hardware' style .bin file.  If --bin    
                        is present, --hardware overrides it.    
            --debug     Turn on some debugging messages.    
            --dump      Dump the octals w/o disassembly.    
            --dtest     By default, the first instruction is basic, and    
                        and the test range is bank 02, from address 4000    
                        to 4050, but these can be changed with the extra    
                        switches --dint --dbank=N, --dstart=N, --dend==N,    
                        where the parameter is an octal number.    
                        Note that for --dstart and --dend.    
            --special   Only print deduced special subroutines.    
            --pattern=S This is similar to --dtest, and takes the same    
                        optional extra command-line switches, but instead    
                        of providing a disassembly, instead provides a    
                        draft sample pattern (which typically requires    
                        manual tweaking) for use in searchSpecial.py.    
                        Note that --pattern overrides --dtest.  S is the    
                        symbol for the subroutine for the pattern.
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
            --descent   Disassemble with recursive descent, to try and reach
                        all of the reachable code.  This is not presently
                        functional.
            --skip=S    In using the --find option, it just so happens that 
                        there may be several matchs for some symbol S defined
                        in the specification file.  One options for dealing
                        that situation is to instruct the disassembler to skip
                        the first match it finds for that symbol.  Using this
                        switch twice tells the disassmbler to skip the first 
                        2 matches of the symbol.  And so on.
               
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
    elif param == "--special":
        specialOnly = True
    elif param[:8] == "--specs=":
        specsFilename = param[8:]
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
    elif param == "--descent":
        descent = True
    else:
        print("Unrecognized option", param)
        sys.exit(1)
if hardwareFile:
    binFile = False


