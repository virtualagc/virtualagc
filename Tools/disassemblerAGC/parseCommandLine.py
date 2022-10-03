#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       parseCommandLine.py
Purpose:        Parses command line for disassemblerAGC.py
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
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
for param in sys.argv[1:]:
    if param == "--help":
        print("Usage:")
        print("\tdisassemblerAGC.py [OPTIONS] <CORE >DISASSEMBLY")
        print("The input CORE is by default a .binsource file.  The OPTIONS:")
        print("  --basic=A    Add basic address (NNNN or NN,NNNN octal)")
        print("               to list of entry points.  Multiple --basic")
        print("               switches can be used.  The interrupt lead-ins")
        print("               are always present by default, as well as an")
        print("               'special subroutines' that are known.")
        print("  --interp=A   Add interpretive address (NNNN or NN,NNNN octal)")
        print("               to list of entry points.  Multiple --interp")
        print("               switched can be used.")
        print("  --bin        CORE is a .bin file as output by yaYUL.")
        print("  --hardware   CORE is a 'hardware' style .bin file.  If --bin")
        print("               is present, --hardware overrides it.")
        print("  --debug      Turn on some debugging messages.")
        print("  --dump       Dump the octals w/o disassembly.")
        print("  --special    Only print deduced special subroutines.")
        print("  --dtest      By default, the first instruction is basic, and")
        print("               and the test range is bank 02, from address 4000")
        print("               to 4050, but these can be changed with the extra")
        print("               switches --dint --dbank=N, --dstart=N, --dend==N,")
        print("               where the parameter is an octal number.")
        print("               Note that for --dstart and --dend.")
        print("  --pattern=S  This is similar to --dtest, and takes the same")
        print("               optional extra command-line switches, but instead")
        print("               of providing a disassembly, instead provides a")
        print("               draft sample pattern (which typically requires")
        print("               manual tweaking) for use in searchSpecial.py.")
        print("               Note that --pattern overrides --dtest.  S is the")
        print("               symbol for the subroutine for the pattern.")
        print("  --specs=F    Reads multiple pattern specifications from a file")
        print("               (F), similar to those used by --dtest and --pattern.")
        print("               Outputs patterns in a form useful for subsequent")
        print("               free-form matching in an alternate AGC version.")
        print("               F is an ASCII file, with lines of the form:")
        print("                     SYMBOL BANK START [END] [I]")
        print("               END is optional, because if it is missing for a")
        print("               given line, then the START from the next line of")
        print("               the file is used as the END of the preceding line.")
        print("               The optional parameter 'I' is literal, and means")
        print("               that the starting location is interpretive rather")
        print("               than basic (which is the default).")
        print("               This switch overrides --pattern and --dtest.")
        print("Note that for --bin and --hardware, we can't necessarily")
        print("determine that locations are unused vs merely containing 00000.")
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
    else:
        print("Unrecognized option", param)
        sys.exit(1)
if hardwareFile:
    binFile = False


