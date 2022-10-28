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
                2022-10-14 RSB  Removed --descent, --basic, and --interp.
                                Completely restructured and partially
                                cleaned up the --help option for (hopefully)
                                much-more-effective usage.
                2022-10-18 RSB  Added --intpret.
                2022-10-19 RSB  Added --dsymbols, --dloop
                2022-10-20 RSB  Added --know.
                2022-10-26 RSB  Added --module.
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
debugLevel = 0
dump = False
dumpModule = 0
dumpSort = False
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
flexFilename = ""
minFlex = 0o10
checkFilename = ""
skips = {}
disjoint = True
hintAfter = {}
ignore = []
avoid = []
parity = False
block1 = False
blk2 = False
intpret = -1
symbolFilename = ""
dloopFilename = ""
know = {}

entryCount = 0
pBanks = ""
oBanks = ""
for param in sys.argv[1:]:
    if param == "--help":
        print('''
            This program can be used as an AGC disassembler or viewer for
            .bin files.  Primarily, however, it is part of the workflow
            for reconstructing AGC source code for an AGC program given
            as just a dump of physical rope-memory modules.  Specifically,
            it tries to deduce a list of memory addresses of program labels
            and variables names.  Companion programs are pieceworkAGC.py
            and specifyAGC.py.
        
            Usage:    
                 disassemblerAGC.py [OPTIONS] <ROPE >DISASSEMBLY    
                 
            Options related to the input file:
                Default:    The input ROPE is a .binsource file.
                --bin       ROPE is instead a .bin file as output by yaYUL.    
                --hardware  ROPE is a 'hardware' style .bin file, presumably
                            created by dumping physical rope-memory modules.
                --parity    By default, the parity bit is ignored in input 
                            --bin files and --hardware files.  The --parity 
                            switch enables it.  Note that without parity, we 
                            cannot necessarily distinguish between memory 
                            locations that are unused vs those that are merely 
                            00000; but not all .bin files contain parity bits,
                            and this may not be a problem anyway.  Processing
                            of binsource files is unaffected by --parity.

            Options related to AGC architecture:
                Default:    LGC or Block II, normal variant.
                --blk2      LGC or Block II, BLK2 variant.
                --block1    Block I.
            
            Miscellaneous options:          
                --help      Display the descriptive information you're now
                            reading.       
                --dump      Output an octal dump of the ROPE. Don't forget
                            to add any appropriate AGC-architecture options
                            (see above), since those affect the selection of
                            banks and the order in which they're output.
                --module=B  In the case "--dump --hardware", one is generally
                            dealing with data dumped from a single rope-memory
                            module rather than a complete executable.  This
                            option can be used to specify which module (B1,
                            B2, B29, etc.) is being dumped.  This affects only
                            the BANK labels appearing in the dump.  Partial
                            rope files such as this should be avoided for
                            any operations other than --dump.  Instead, a 
                            full ROPE file should be prepared using tools 
                            such as pieceworkAGC.py. 
                --sort      Dumps for --hardware files are output using the 
                            bank order specific to the target.  For --block1
                            in particular, this may not be a very convenient
                            order.  The --sort switch orders the banks in 
                            increasing order in the --dump.
                --intpret=A Force the address of INTPRET to be at fixed-fixed
                            address A (a 4-digit octal).  This would be used
                            if (say) you don't have a dump of the 
                            fixed-fixed banks that have INTPRET in them.    
                --debug     Turn on some debugging messages. 
                --debug-level=N  Set the "debugging level", default 0.  The
                            only other defined setting is N=1, which means 
                            that with the --find option, only code patterns
                            are matched, without any attempt to indirectly
                            identify symbols through references to them.
                  
            Options related to --dtest:
                --dtest     This outputs a disassembly of a range of
                            addresses confined to a single fixed-memory bank.
                            For Block II the default address range corresponds
                            to the interrupt vector table:  i.e., 02,2000
                            to 02,2050 for Block II, and 01,6000 to 01,6034
                            for Block I.  But these assumptions can be changed
                            with the options listed below.
                --dint      The disassembly range can be mixed basic 
                            instructions and interpreter instructions, but 
                            by default the very first instruction in the
                            range is basic. The --dint switch instead specifies
                            that the first instruction is interpretive.
                --dbank=N   Bank number is N (octal).
                --dstart=N  Starting offset is N (octal).
                --dend=N    Disassembly stops when reaching this address 
                            (octal) without disassembling it. 
                --dloop=B   Starts an interactive loop in which you can perform
                            successive disassemblies (equivalent to 
                                --dtest [--dint] --dbank --dstart --dend
                            by entering the parameters for them from the
                            keyboard rather than as command-line parameters.
                            To use this feature, the bin or binsource file
                            must be specified (B) rather than using < on the
                            command line, since the stdin is needed for 
                            inputting your interactive commands.
                --dsymbols=F  Allows optional selection of a symbol-table
                            file.  Then --dtest performs a disassembly,
                            it then uses this symbol table to provide
                            program labels for the code and symbolic names
                            for operands. When disassemblyAGC.py is run
                            with the --find automation option (see below),
                            it automatically produces a symbol table file
                            called disassemblerAGC.symbols which is suitable
                            for use as F.  Such a file can also be customized
                            by manual editing (and presumably being renamed
                            in the process so that --find doesn't overwrite
                            it later).   
                            
            Automation:  Creation of match-patterns:                                   
                --specs=F   Reads a baseline file (F) of pattern 
                            specifications, typically created by the separate
                            program specifyAGC.py. Outputs patterns in a form
                            useful for the disassemblerAGC.py's --find option,
                            for subsequent patterns matching within a 
                            different (or the same) ROPE. 
                            
            Automation:  Analysis of a ROPE using BASELINE match-patterns:
                --find=F    Uses a baseline match-pattern file as created by
                            --specs (see above), and tries to find all of the
                            patterns specified therein.
                --hint=S1@S2 This is a hint that subroutine S1 must be at a 
                            higher memory address than subroutine S2.  As many
                            --hint switches can be used as desired.  A typical
                            usage would be to work around two (or more) 
                            match-patterns being either identical, or being 
                            contained within one another.  Used in similar 
                            circumstances as --skip (see below), for similar
                            reasons, but generally the superior choice for
                            problematic tables of TC instructions.
                --skip=S    In using the --find option, it just so happens 
                            that there may be several matches for some symbol S
                            defined in the match-patterns file.  One option for
                            dealing with that situation is to instruct the 
                            disassembler to skip the first match it finds for
                            that symbol.  Using this switch twice tells the 
                            disassembler to skip the first 2 matches of the 
                            symbol.  And so on.  Used in similar circumstances
                            as --hint (see above), for similar reasons, but 
                            sometimes the superior choice for small 
                            match-patterns.
                --ignore=S  Simply ignore subroutine S altogether when matching
                            patterns.  This is a last-resort measure when
                            --hint and --skip (see above) are inadequate for
                            dealing with a problematic subroutine S.
                --avoid=BB,NNNN-MMMM Specify a fixed address range which 
                            should be avoided by the matching process.  You
                            can use as many of these switches as necessary.
                            This is a last-resort measure when a long section
                            of data happens to disassemble compatibly to 
                            code.  An example (the only one known, actually)
                            is a table of CADR pseudo-ops that disassembles
                            as a table of TC instructions.
                --know=S@BB,AAAA[,C]  (Not yet implemented.) Similar to 
                            --intpret.  Use this to indicate that you know
                            (irrespective of any pattern-matching) that 
                            symbol S is at fixed address BB,AAAA in the 
                            ROPE. The optional C (in octal) is the number
                            of words you think should be allocated for it;
                            no other matches can be made in the memory
                            range BB,AAAA through BB,AAAA+C-1.  If C is 
                            omitted, then no memory range is reserved,
                            You can use as many of these options as
                            you like.  Nevertheless, you should use them
                            sparingly, *only* when you're sure that the
                            pattern defined by the BASELINE is wrong for the
                            ROPE (as opposed to merely being inconvenient).
                            That's because once a symbol is given a known
                            address in this way, it cannot be used for 
                            matching any references it makes.
                --check=F   Specifies an assembly-listing file that can be 
                            used for comparison vs the matches found. If 
                            this switch is not present, no comparison is 
                            performed.
                --overlap   (Rare.) By default, overlapping of the program 
                            chunks defined in the match-patterns file (and the 
                            specifications file from which it was derived)
                            is rigidly avoided by the pattern-matching.  But
                            if they can overlap by intention (which can happen
                            only if the match-patterns or the specifications
                            they're derived from have been created manually
                            rather than by automation), use this switch.
                --prio=B,... (Rare.) A list of banks (octal) which are searched 
                            first with the --find switch.  Without --prio, the 
                            banks are searched in the order 00, 01, 02, ..., 
                            43.
                --only=B,... (Rare.) A list of banks (octal) for --find.  If
                            present, only the listed banks are searched.
                        
            Options related to "special subroutines":                            
                --special   Just print the "special subroutines" found, 
                            without any additional processing.  
                --flex=F    Add user-created "special subroutines" to the
                            list of special subroutines already hardcoded,
                            which include INTPRET etc.  F is a file containing
                            such patterns.  Patterns can be created either
                            manually, or with the --pattern option (see
                            below).  
                --min-flex=N  Ignore any patterns in a --flex file that are
                            less than N (octal) words long.  The default is
                            10 (octal, 8 decimal).
                --pattern=S Outputs a sample pattern (which typically 
                            requiring manual tweaking) for program label S, 
                            suitable for pasting into searchSpecial.py or for
                            use with the --flex option (see above). Note that
                            search flexibility for interpretive code is 
                            somewhat reduced vs basic code.
                --dbank=N   (For --pattern.) Bank number is N (octal).
                --dstart=N  (For --pattern.) Starting offset is N (octal.
                --dend=N    (For --pattern.) First address not included. 
                --dint      (For --pattern.) Starting offset is interpretive
                            vs the default (basic). 
        ''')
        sys.exit(0)
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
    elif param[:14] == "--debug-level=":
        debugLevel = int(param[14:])
    elif param == "--dump":
        dump = True
    elif param == "--sort":
        dumpSort = True
    elif param[:9] == "--module=":
        dumpModule = param[9:]
        if dumpModule[:1].upper() == "B":
            dumpModule = dumpModule[1:]
        if not dumpModule.isdigit():
            print("Error: Parameter %s out of range." % param, file=sys.stderr)
            sys.exit(1)
        dumpModule = int(dumpModule)
    elif param[:10] == "--pattern=":
        pattern = True
        symbol = param[10:]
    elif param[:10] == "--intpret=":
        intpret = int(param[10:], 8)
    elif param[:8] == "--dloop=":
        dloopFilename = param[8:]
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
    elif param[:11] == "--dsymbols=":
        symbolFilename = param[11:]
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
    elif param[:11] == "--min-flex=":
        minFlex = int(param[11:], 8)
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
    elif param[:7] == "--know=":
        fields = param[7:].split("@")
        symbol = fields[0]
        fields = fields[1].split(",")
        bank = int(fields[0], 8)
        address = int(fields[1], 8)
        if len(fields) == 2:
            know[symbol] = (bank, address)
        elif len(fields) >= 3:
            know[symbol] = (bank, address, int(fields[2],8))
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

