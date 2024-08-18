#!/usr/bin/env python3
'''
License:    The author (Ronald S. Burkey) declares that this program
            is in the Public Domain (U.S. law) and may be used or 
            modified for any purpose whatever without licensing.
Filename:   parseCommandLine.py
Purpose:    Parses the XCOM-I command line and provides variables 
            containing the parsed command-line options.
Requires:   Python 3.6 or later.
Reference:  http://www.ibibio.org/apollo/Shuttle.html
Mods:       2024-03-27 RSB  Began experimenting with this concept.
'''

import sys
import os
import re

# XCOM-I version.  Each is in the range 0-99.
majorVersionXCOMI = 0
minorVersionXCOMI = 9

if False:
    import datetime
    now = datetime.datetime.now()
    def TIME(): # Equivalent to the XPL built-in.
        return  now.hour * 360000 + \
                now.minute * 6000 + \
                now.second * 100 + \
                now.microsecond // 10000
    TIME_OF_GENERATION = TIME()
else:
    import time
    epoch = time.time()
    now = time.localtime(epoch)
    TIME_OF_GENERATION = now.tm_hour * 360000 + \
                         now.tm_min * 6000 + \
                         now.tm_sec * 100
    DATE_OF_GENERATION = (now.tm_year - 1900) * 1000 + \
                         now.tm_yday

'''
# A nifty way to trap unwanted calls to `print`.
import builtins
orig_print = builtins.print
def my_print(*args, **kwargs):
    orig_print(*args, **kwargs)
    if ("file" not in kwargs):
        breakpoint()
builtins.print = my_print
'''

ifdefs = { 'W' }
inputFilenames = []
targetLanguage = "C"
outputFolder = None
indentationQuantum = "  "
debugSink = None
lines = [] # One line of source code per entry.
lineRefs = [] # One reference (filename:number) for each line of source code.
pseudoStatements = [] # One pseudo-statement per entry. See the 
psRefs = [] # One index into `lineRefs` for each `pseudoStatement`
#sourceFiles = [] # Source filename for each line.
verbose = True
includeFolder = ".." + os.sep + "HALINCL" # Folder for /%INCLUDE ... %/ directives.
baseSource = None
adhocs = {}
standardXPL = False
identifierString = None  # String returned by MONITOR(23)
merge = None
firstFile = True
noInclusionDirectives = False
showBacktrace = False
physicalTop = 1 << 24
keepUnused = False
prettyPrint = False
noLabels = False
displayInitializers = False
debugInlines = False
libraryCutoff = 0  # The line-number boundary between the library file and the
                   # main source.
amountOfReservedMemory = 0x2000
quiet = False
debuggingAid = False
reentryGuard = True # Do not change this.
#autoInline = False
guessInlines = []
traceInlines = False
winKeep = False

# The characters used internally to replace spaces and duplicated single-quotes
# within quoted strings.  The exact values aren't important, except insofar as
# they shouldn't be something that would otherwise appear in XPL strings, but
# which are characters that won't cause Python to have a
# conniption.  I've chosen DC2 and DC4 control characters because they're the
# same in ASCII & EBCDIC, but that's just arbitrary.  I originally used
# ~ and ` since they weren't in the character set originally supported by XPL,
# but I've realized belately that my own instructions that logical-not and
# U.S.-cent should be replaced by them make it likely that they could in fact
# appear in strings *now*, particularly for macro definitions.
replacementQuote = "\x12"
replacementSpace = "\x14"
# Folder where XCOM-I.py itself is.
basePath = os.path.dirname(os.path.realpath(__file__)) + os.sep
libFile = basePath + "SPACELIB.xpl"

# Raw read of a source-code file.  Recursive, if /%INCLUDE ... %/ directives
# (and similar) are encountered.
def readFileIntoLines(filename):
    global inputFilenames, lines
    # global sourceFiles
    if filename in inputFilenames:
        return
    try:
        inputFilenames.append(filename)
        f = open(filename, "r")
        lineNumber = 0
        for line in f:
            lineNumber += 1
            if "$%" in line:
                pass
            line = line.replace("'TITAN--XPL'", "'RSB-XCOM-I'") # Exactly 12 chars each.
            lines.append(line)
            lineRefs.append("%s:%d" % (filename, lineNumber))
            #sourceFiles.append(os.path.basename(filename))
            if not noInclusionDirectives:
                if "/%INCLUDE" in line:
                    fields = line.split()
                    readFileIntoLines(dirHALINCL + os.sep + fields[1] + ".xpl")
                elif None != re.search('/\\*.*\\$%.*\\*/', line):
                    # In case it isn't obvious, this was looking for 
                    # $%filename directives within a comment.
                    basename = line[:80].split('$%')[1]
                    basename = basename.split('*')[0].split()[0]
                    readFileIntoLines(dirHALINCL + os.sep + basename + ".xpl")
                elif line.lstrip().startswith('/**MERGE'):
                    fields =line.lstrip().split()
                    if baseSource != "":
                        readFileIntoLines(baseSource + os.sep + fields[1] + ".xpl")
                    else:
                        readFileIntoLines(fields[1] + ".xpl")
        f.close()
    except:
        print("Failed to read file %s" % filename, file = sys.stderr)
        if winKeep:
            input()
        sys.exit(1)

# Parse the command line, reading the lines of XPL source code in the
# process.
helpMsg = '''
Usage:
    XCOM-I.py [OPTIONS] FILE1.xpl [ FILE2.xpl [ ... ] ]

The available OPTIONS are:

--help          Print this info.
--              If this is found, it means to skip the entire remainder of the
                command line.
--xpl           Compile standard XPL rather than XPL/I.
--lib-file=F    (Default SPACELIB.xpl, or XPL.LIBRARY.xpl if the --xpl option
                is used.)  Specifies a "library file" of XPL source code to 
                include prior to any of the XPL files specified on the command 
                line.  Note that if both --xpl and --lib-file are used, then
                --xpl must *precede* --lib-file on the command line; both must
                precede the names of the first source-code file specified.
--cond=c        XPL/I source-code files can contain code which is conditionally
                included or excluded, using the syntax
                    /?c...code...?/
                Here, c is a single upper-case alphabetical character.  This
                would be similar, for example, to "#ifdef c" in the C computer
                language.  Multiple --cond switches can appear on the same
                command line. In the XPL/I source code for the HAL/S-FC program,
                the relevant choices are:
                    c=P    For the Primary Flight Software (PFS).
                    c=B    For the Backup Flight Software (PFS).
                    c=A    To produce debugging output for BASED management.
                    c=C    To produce debugging output for COMPACTIFY.
                Note that when compiling HAL/S-FC, one should use either 
                --cond=P or --cond=B but not both at the same time. 
                Additionally, the following conditionals, not specifically 
                targetting HAL/S-FC (though currently only used in HAL/S-FC) 
                are available:
                    c=V    Enable Virtual AGC modifications.
                    c=W    (Default) Disable Virtual AGC modifications.
                These are mutually exclusive, in that selecting either one
                deselects the other.  They are intended for use in compiling
                legacy code, in which it is desirable either to compile "as-is" 
                (W) or else with modern modifications by Virtual AGC.  In 
                HAL/S-FC specifically, V enables two modifications:
                    1.  In PASS1, when using the `D INCLUDE TEMPLATE`
                        compiler directives, no attempt to load SDF files is
                        made, compensating for the current non-implementation
                        of SDFPKG.
                    2.  In PASS2, all runtime library functions are treated
                        as "validated", eliminating compiler warnings for use
                        of statements such as `WRITE(6) ...`.
--identifer=S   (Default "REL32V0   ".)  Set the 10-character string returned 
                by MONITOR(23).  Will be automatically truncated or padded as
                needed.
--include=F     Folder to use for XPL/I's "/%INCLUDE ... %/" directives.
                Note that this is relative to the source-code file.
                Defaults to ../HALINCL.  If used, should precede any XPL source
                files on the command line.
--source=F      (Default is the folder containing the first XPL source-code file
                given on the command line.)  Name of the folder from which
                XPL source-code files (other than those for --include) are drawn
                by default. If used, should precede any XPL source files on the
                command line.
--output=F      (Default is the base-name of the first XPL source-code file
                given on the command line.) Name of the folder to store output 
                files.
--merge=F       (Default None.)  Write a file F containing all of the merged XPL
                source code.  Note that the resulting file is not necessarily a
                valid XPL file itself, because any file-inclusion directives the
                original separate source-code files contained are still present
                in it; thus if the merged file were compiled using normal XCOM-I
                options, double-inclusions would occur.  If the merged file will
                itself be compiled, the --no-inclusion switch (see below) should
                be used.  It may be advisable to give the merged file an 
                extension like ".merged" rather than the usual ".xpl" to avoid 
                confusion.
--no-inclusion  Disables any file-include directives found within the XPL source
                code.  This is typically used for "merged" files (see above).
--patch=P       Path to the inline-BAL patch files.  By default, this will
                be the same folder that contains the first XPL source-code
                file specified on the command line.
--adhoc=S,R     This is a way of creating global XPL macros without change
                to source-code files.  S is the name of the macro and R is
                the replacement text.  This switch can be used multiple 
                times.  In hindsight, it doesn't seem useful.
--target=L      (Default C) Set the target language for object-code.
                Only C is presently supported.
--indent=N      (Default 2) Set the indentation width for C-language source code.
                This is purely cosmetic effect to make it more pleasant to read
                the code output by XCOM-I.
--debug=D       Print extra debugging messages to device D.  D is either stdout 
                or stderr.
--debug-inlines By default, XCOM-I comments out `CALL INLINE`s that embed IBM 360
                which don't have an associated patch-file.  This option instead
                inserts a call to a dummy function called `debugInline`, which
                prints a message.  This allows detecting or trapping unpatched
                `CALL INLINEs`.  `CALL INLINE`s which embed C code are not 
                affected.  Only the first `CALL INLINE` in any adjacent sequence
                is affected.
--guess=N,M,... Produce approximate files with proposed translations of 
                `CALL INLINE` statemements for patchN.c, patchM.c, etc.  Can
                use -1 to mean all patches.  Automatically sets --debug-inlines.
                Since the files which are produced have names of the form
                guessN.c, guessNp.c, and/or guessNb.c, where N>=0 is an
                integer, it's advisable to preserve or delete conflicting files
                beforehand.
--debugging-aid Include extra functions in the runtime library that may be 
                useful for debugging XCOM-I itself.
--verbose       The --verbose switch (which is the default) embeds extra comments
--concise       in the generated C source code, useful for debugging, or just for
                improved human readability.  Whereas the --concise switch instead
                eliminates those extra comments, producing smaller C file sizes.
--quiet         Eliminates some informative messages by XCOM-I.  Note that this
                is *not* the opposite of --verbose, which affects the generated
                C code rather than XCOM-I's messages.
--backtrace     Show Python backtrace for some XCOM-I errors.
--keep-unused   By default, XPL procedures which are never called are discarded
                without any generation of C code, and reduced analysis.  With
                --keep-unused, those procedures are retained and processed
                normally.
--pp            "Pretty print" the output C files.  The files runtimeC.c, 
                memory.c, and *.h are exempted from the reformatting process.
                This option requires installation of clang-format.  Note that
                depending on its version, clang pretty-printing may reformat
                comment lines that extend past the 80-column limit.
--nl            By default, generated C code uses C preprocessor macros (i.e.,
                symbolic names) to represent the absolute memory addresses at
                which XPL variables appear in the memory model.  With --nl
                ("no labels"), the addresses appear as decimal numbers instead.
                Note that --pp and --nl are independent of each other.
--de            This duplicates the $E control toggle of the original XCOM,
                but only to the extent of displaying the raw initial values of 
                variables in the symbol table printed in main.c.
--reserved=N    (Default 4096.)  XCOM-I retains a certain amount of the 24-bit
                XPL memory space for its own internal use.  If you get an 
                out-of-reserved-memory error message from XCOM-I, you can use
                this option to enlarge the amount of reserved memory.
--winkeep       When running XCOM-I in Windows (but not from MSYS2), Python
                programs run in a newly-created window that closes immediately
                upon termination.  The side effect is that you cannot see any
                error messages.  The --winkeep option causes the window to stay
                open until there's a keypress.
'''

for parm in sys.argv[1:]:
    if parm == "--":
        break
    #elif parm == "--auto-inline":
    #    autoInline = True
    elif parm == "--trace-inlines":
        traceInlines = True
    elif parm == "--winkeep":
        winKeep = True
    elif parm.startswith("--guess="):
        fields = parm[8:].split(",")
        try:
            for field in fields:
                guessInlines.append(int(field))
        except:
            print("Non-integer in --guess option", file=sys.stderr)
            if winKeep:
                input()
            sys.exit(1)
        debugInlines = True
        traceInlines = True
    elif parm == "--debugging-aid":
        debuggingAid = True
    elif parm == "--reentry-guard":
        # This is now the default.
        reentryGuard = True
    elif parm == "--quiet":
        quiet = True
    elif parm.startswith("--reserved="):
        amountOfReservedMemory = int(parm[11:])
    elif parm == "--debug-inlines":
        debugInlines = True
    elif parm == "--pp":
        prettyPrint = True
    elif parm == "--nl":
        noLabels = True
    elif parm == "--de":
        displayInitializers = True
    elif parm == "--keep-unused":
        keepUnused = True
    elif parm.startswith("--merge="):
        merge = parm[8:]
    elif parm.startswith("--lib-file="):
        libFile = parm[11:]
    elif parm == "--no-inclusion":
        noInclusionDirectives = True
    elif parm == "--no-overrides":
        noOverrides = True
    elif parm == "--help":
        print(helpMsg, file = sys.stderr)
        if winKeep:
            input()
        sys.exit(0)
    elif parm == "--xpl":
        standardXPL = True
        libFile = basePath + "XPL.LIBRARY.xpl"
    elif parm.startswith("--cond="):
        cond = parm[7:]
        if len(cond) != 1 or not cond.isupper():
            print("Illegal conditional %s" % parm, file=sys.stderr)
            if winKeep:
                input()
            sys.exit(1)
        if cond in ["V", "W"]:
            ifdefs -= { "V", "W" }
        ifdefs.add(cond)
    elif parm.startswith("--identifier="):
        identifierString = "%-10s" % parm[13:23]
    elif parm.startswith("--include="):
        includeFolder = parm[10:]
    elif parm.startswith("--source="):
        baseSource = parm[9:]
    elif parm.startswith("--patch="):
        baseSource = parm[8:]
    elif parm.startswith("--adhoc="):
        fields = parm[8:].split(",", 1)
        if len(fields) != 2:
            print("The --adhoc switch requires 2 sub-fields", file=sys.stderr)
            if winKeep:
                input()
            sys.exit(1)
        adhocs[fields[0]] = fields[1]
    elif parm.startswith("--debug="):
        d = parm[8:]
        if d == "stdout":
            debugSink = sys.stdout
        elif d == "stderr":
            debugSink = sys.stderr
        else:
            print("Value for --debug not recognized", file = sys.stderr)
            if winKeep:
                input()
            sys.exit(1)
    elif parm == "--verbose":
        verbose = True
    elif parm == "--concise":
        verbose = False
    elif parm.startswith("--target="):
        targetLanguage = parm[9:].upper()
        if targetLanguage not in ["C"]:
            print("Target language not supported", file = sys.stderr)
            if winKeep:
                input()
            sys.exit(1)
    elif parm.startswith("--output="):
        outputFolder = parm[9:] + ".build"
    elif parm.startswith("--indent="):
        indentationQuantum = " " * int(parm[9:])
    elif parm == "--backtrace":
        showBacktrace = True
    elif parm.startswith("-"):
        print("Unknown option %s" % parm, file = sys.stderr)
        if winKeep:
            input()
        sys.exit(1)
    else:
        if firstFile:
            if baseSource == None:
                baseSource = os.path.dirname(parm)
            if baseSource != "":
                dirHALINCL = baseSource + os.sep + includeFolder
            else:
                dirHALINCL = includeFolder
            if libFile != None:
                readFileIntoLines(libFile)
                libraryCutoff = len(lines)
        firstFile = False
        readFileIntoLines(parm)
        if outputFolder == None:
            head, tail = os.path.split(parm)
            name, ext = os.path.splitext(tail)
            outputFolder = name + ".build"

if identifierString == None:
    if "P" in ifdefs:
        identifierString = 'REL32V0   '
    elif "B" in ifdefs:
        identifierString = 'BFS-17.0  '
    else:
        identifierString = "(TBD)     "

if merge != None:
    f = open(merge, "w")
    f.writelines(lines)
    f.close()


# All of the source code is now in lines[].  Massage it a bit.
for i in range(len(lines)):
    # If trailing linefeeds or carriage returns (Windows, I'm looking at you!)
    # were read in, strip them off.
    lines[i] = lines[i].rstrip("\n\r")
    # *Apparently*, in Windows, if you make the mistake of editing a source
    # file containing one of our problematic UTF-8 characters ("¬", "¢"), 
    # Windows will "thoughtfully" stick an unwanted UTF-8 character encoded as 
    # "\xef\xbb\xbf" at the beginning of the file when you save it.  I suppose
    # this must be invisible to the user, while helping Windows magically 
    # identify files as UTF-8 without examining the entire file.  But for 
    # XCOM-I, it's pure, unadulterated corruption.
    lines[i] = lines[i].replace("\xef\xbb\xbf", "")
    # Also, if somebody modern edits a file and thoughlessly put in any tab
    # characters, we need to expands those tabs into spaces.
    lines[i] = lines[i].expandtabs(8)
    # Make sure each line is at least 80 columns wide.
    lines[i] = "%-80s" % lines[i]
    # Strip off punch-card sequence numbers at the ends of lines.
    lines[i] = lines[i][:80]
    
    
