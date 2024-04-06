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

pfs = True
inputFilenames = []
targetLanguage = "C"
outputFolder = "C_Output"
indent = "  "
debugSink = None
lines = [] # One line of source code per entry.
sourceFiles = [] # One entry for each entry in lines[]; source filename for line.
verbose = False
includeFolder = "../HALINCL" # Folder for /%INCLUDE ... %/ directives.
nullStringMethod = 0
baseSource = ""

# Raw read of a source-code file.  Recursive, if /%INCLUDE ... %/ directives
# (and similar) are encountered.
def readFileIntoLines(filename):
    global inputFilenames, lines, sourceFiles, baseSource
    if filename in inputFilenames:
        return
    baseSource = os.path.dirname(filename)
    dir = baseSource + "/" + includeFolder
    try:
        inputFilenames.append(filename)
        f = open(filename, "r")
        for line in f:
            if "$%" in line:
                pass
            lines.append(line)
            sourceFiles.append(os.path.basename(filename))
            if "/%INCLUDE" in line:
                fields = line.split()
                readFileIntoLines(dir + "/" + fields[1] + ".xpl")
            elif None != re.search('/\\*.*\\$%.*\\*/', line):
                # In case it isn't obvious, this was looking for 
                # $%filename directives within a comment.
                basename = line[:80].split('$%')[1]
                basename = basename.split('*')[0].split()[0]
                readFileIntoLines(dir + "/" + basename + ".xpl")
            elif line.lstrip().startswith('/**MERGE'):
                fields =line.lstrip().split()
                readFileIntoLines(baseSource + "/" + fields[1] + ".xpl")
        f.close()
    except:
        print("Failed to read file %s" % filename, file = sys.stderr)
        sys.exit(1)

# Parse the command line, reading the lines of XPL source code in the
# process.
helpMsg = '''
Usage:
    XCOM-I.py [OPTIONS] FILE1.xpl [ FILE2.xpl [ ... ] ] >OUTPUT.c

The available OPTIONS are:

--help        Print this info.
--pfs         (Default) Port for Primary Flight System.
--bfs         (Don't use with --pfs.) Port for Backup Flight System. 
--include=F   Folder to use for "/%INCLUDE ... %/" directives.
              Note that this is relative to the source-code file.
              Defaults to ../HALINCL.
--null=N      (Default 0) Selects from among several alternative
              implementations for empty strings, because the surviving
              documentation on that topic is unclear and contradictory.
              At present, only implementation 0 is available.
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
    elif parm.startswith("--include="):
        includeFolder = parm[10:]
    elif parm.startswith("--null="):
        nullStringMethod = int(parm[7:])
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
        readFileIntoLines(parm)
        f = open("temp.xpl", "w") # ***DEBUG***
        f.writelines(lines)
        f.close()

# All of the source code is now in lines[].  Massage it a bit.
for i in range(len(lines)):
    # If trailing linefeeds were read in, strip them off.
    lines[i] = lines[i].rstrip("\n")
    # Make sure each line is at least 80 columns wide.
    lines[i] = "%-80s" % lines[i]
    # Strip off punch-card sequence numbers the ends of lines.
    lines[i] = lines[i][:80]

