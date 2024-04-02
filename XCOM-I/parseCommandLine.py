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

pfs = True
inputFilenames = []
targetLanguage = "C"
outputFolder = "C_Output"
indent = "  "
debugSink = None
lines = [] # One line of source code per entry.
verbose = False

# Parse the command line, reading the lines of XPL source code in the
# process.
helpMsg = '''
Usage:
    XCOM-I.py [OPTIONS] FILE1.xpl [ FILE2.xpl [ ... ] ] >OUTPUT.c

The available OPTIONS are:

--help        Print this info.
--pfs         (Default) Port for Primary Flight System.
--bfs         (Don't use with --pfs.) Port for Backup Flight System. 
--target=L    (Default C) Set the target language for object-code.
              Only C is presently supported.
--output=F    (Default C_Output) Name of the folder to store output files.
--indent=N    (Default 2) Set the indentation width for (C) source code.
--debug=D     Print extra debugging messages.  D is stdout or stderr.
--verbose     Embed extra comments in C source code.
'''
for parm in sys.argv[1:]:
    if parm == "--help":
        print(helpMsg, file = sys.stderr)
        sys.exit(0)
    elif parm == "--pfs":
        pfs = True
    elif parm == "--bfs":
        pfs = False
    elif parm.startswith("--debug="):
        d = parm[8:]
        if d == "stdout":
            debugSink = sys.stdout
        elif d == "stderr":
            debugSink = sys.stderr
        else:
            print("Value for --debug not recognized", file = sys.stderr)
            sys.exit(1)
    elif parm == "--verbose":
        verbose = True
    elif parm.startswith("--target="):
        targetLanguage = parm[9:].upper()
        if targetLanguage not in ["C"]:
            print("Target language not supported", file = sys.stderr)
            sys.exit(1)
    elif parm.startswith("--output="):
        outputFolder = parm[9:]
    elif parm.startswith("--indent="):
        indent = " " * int(parm[9:])
    elif parm.startswith("-"):
        print("Unknown option %s" % parm, file = sys.stderr)
        sys.exit(1)
    else:
        try:
            inputFilenames.append(parm)
            f = open(parm, "r")
            lines.extend(f.readlines())
            f.close()
        except:
            print("Failed to read file %s" % parm, file = sys.stderr)
            sys.exit(1)

# All of the source code is now in lines[].  Massage it a bit.
for i in range(len(lines)):
    # If trailing linefeeds were read in, strip them off.
    lines[i] = lines[i].rstrip("\n")
    # Make sure each line is at least 80 columns wide.
    lines[i] = "%-80s" % lines[i]
    # Strip off punch-card sequence numbers the ends of lines.
    lines[i] = lines[i][:80]

