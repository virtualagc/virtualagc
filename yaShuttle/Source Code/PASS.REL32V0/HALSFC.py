#!/usr/bin/env python
'''
This program is declared by its author, Ronald Burkey, to be in the Public
Domain in the U.S., and may be used, modified, or distributed in any manner
whatsoever, free of charge.

This Python 3 script is intended to supersede (providing full functionality
across all platforms) the predecessor bash script HALSFC and the hopefully-
equivalent Windows batch file HALSFC.bat.  The only difference, other than
possibly increased functionality, is that command-line parameters are no longer
positional.

This Linux/Mac script compiles a HAL/S program using the HAL/S-FC program,
which is assumed to be in the PATH.  ERRORLIB is assumed to be in the same
folder as HALSFC-PASS1.
'''

import sys
import os
import platform
import shutil
from datetime import datetime
from pathlib import Path

# Detect the platform.  Our only concern is Windows vs non-Windows, since I 
# assume that all non-Windows platforms are some *nix flavor.  Note that when
# python is run in an MSYS2 environment, it does *not* detect Windows,
# which is just what we want.
isWindows = (platform.system() == "Windows")
# Just in case of working with .exe files in WINE.
if not isWindows:
    os.environ['WINEDEBUG'] = '-all'

helpMessage = '''
This script compiles a HAL/S source-code file to a HALMAT "intermediate 
language" file and to AP-101S object-code file(s), using "modern" ports of the 
original Intermetrics/USA HAL/S compiler HAL/S-FC.  It requires that all 
compiler passes (HALSFC-PASS1[.exe], etc.) be in the PATH.

     HALSFC.py [OPTIONS] SOURCE.hal

The available OPTIONS are:

    --test          In addition to compiling, perform all available validity
                    tests. Requires NOTABLES in --parms (see below).  Also
                    requires that the following be installed and be in the PATH: 
                    diff[.exe], egrep[.exe], and HAL_S_FC.py.
    --parms="..."   Comma-separated list of HAL/S-FC options.  By default: none.
                    For compatibility with Windows, it is good practice to
                    enclose this in double-quotes.
    --bfs           Use BFS version of HAL/S-FC.  The default is the PASS/PFS 
                    version of HAL/S-FC.
    --exe           Use Windows port of HAL/S-FC.  This is the default on
                    Windows, but it can be done on Linux or MacOS as well if
                    the Windows version of HAL/S-FC is installed and if the
                    WINE package is installed for running Windows executables.

'''

# Parse the command line.
halsFile = None
test = False
parmString = ""
bfs = False
ext = ""
extCOMMON = ".out"
if isWindows:
    ext = ".exe"
for parm in sys.argv[1:]:
    if parm == "--test":
        test = True
    elif parm.startswith("--parms="):
        parmString = parm[8:]
    elif parm == "--bfs":
        bfs = True
    elif parm == "--exe":
        ext = ".exe"
    elif not parm.startswith("-"):
        if halsFile != None:
            print("Multiple HAL/S files specified")
            sys.exit(1)
        halsFile = parm
        if not os.path.exists(halsFile):
            print("Specified HAL/S file (%s) does not exist" % halsFile)
            sys.exit(1)
    else:
        print(helpMessage)
        if parm == "--help":
            sys.exit(0)
        sys.exit(1)
if halsFile == None:
    print(helpMessage)
    sys.exit(1)
normFile = Path(halsFile).name
commandLine = " ".join(sys.argv)

now = datetime.now()
now = now.strftime("%Y-%m-%d %H:%M:%S")

filesPorted = ["FILE1.bin", "FILE2.bin", "FILE3.bin", "FILE4.bin", "FILE5.bin", 
               "FILE6.bin", "&&TEMPLIB.json", "&&TEMPINC.json", "SOURCECO.txt",
               "$FILES_PORTED", "LIT_CHAR.bin", "SYM_TAB.json", "$FILES_PORTED", 
               "CROSS_REF.json"]
filesLocal = ["LISTING2.txt", "vmem.bin", "COMMON1.out", "COMMON2.out",
              "COMMON1.gz", "COMMON2.gz", "COMMON3.gz", "COMMON4.gz",
              "COMMON3.out", "COMMON4.out", "auxmat.bin", "objcode.bin",
              "COMMON1.out.bin.gz", "COMMON2.out.bin.gz", "COMMON3.out.bin.gz", 
              "COMMON4.out.bin.gz", "pass1A.rpt", "pass1pA.rpt", "flo.rpt", 
              "aux.rpt", "pass3.rpt", "pass4.rpt", "monitor13.parms",
              "auxp.rpt", "deck.bin", "extra.txt", "litfile0.bin", 
              "litfile1.bin", "litfile2.bin", "litfile3.bin", "litfile4.bin"]
filesPreserve = ["litfile.bin", "cards", "COMMON0.out", "COMMON0.gz", 
                 "COMMON0.out.bin.gz", "TEMPLIB.json", "TEMPLIB", 
                 "TEMPLIBB.json", "TEMPLIBB", "pass1.rpt", "pass1p.rpt", 
                 "opt.rpt", "pass2.rpt", "cards.bin", "listing2.txt", 
                 "optmat.bin", "halmat.bin"]
for f in filesPorted+filesLocal:
    try:
        os.remove(f)
    except:
        pass

# Move all generated files to a *.results folder.
results = ""
def moveAll(message):
    global results
    results = "HALSFC %s %s.results" % (normFile, now)
    os.mkdir(results);
    f = open("%s%scomment.txt" % (results, os.sep), "w")
    print(message, file=f)
    f.close()
    for f in filesPorted+filesLocal:
        try:
            shutil.move(f, "%s%s%s" % (results, os.sep, f))
        except:
            pass
    for f in filesPreserve+[halsFile]:
        try:
            shutil.copy(f, "%s%s%s" % (results, os.sep, f))
        except:
            pass

# The arguments comprise an error message.
def errorExit(message):
    print(message)
    moveAll("%s: %s" % (message, commandLine))
    print("Results in \"%s\"" % results)
    sys.exit(1)

# Adapted this from google AI.
def findFileUsingPATH(filename):
    pathVar = os.getenv("PATH")
    if not pathVar:
        return None
    directories = pathVar.split(os.pathsep)
    for directory in directories:
        if os.path.isfile(os.path.join(directory, filename)):
            return directory
    return None

if bfs:
    PASS1 = "HALSFC-PASS1B" + ext
    FLO = "HALSFC-FLO" + ext
    OPT = "HALSFC-OPTB" + ext
    AUXP = "HALSFC-AUXP" + ext
    PASS2 = "HALSFC-PASS2B" + ext
    PASS3 = "HALSFC-PASS3B" + ext
    PASS4 = "HALSFC-PASS4" + ext
    TEMPLIB = "TEMPLIBB" + ext
    CARDS = "--pdso=3,cards,E"
    TARGET = "--bfs"
else:
    PASS1 = "HALSFC-PASS1" + ext
    FLO = "HALSFC-FLO" + ext
    OPT = "HALSFC-OPT" + ext
    AUXP = "HALSFC-AUXP" + ext
    PASS2 = "HALSFC-PASS2" + ext
    PASS3 = "HALSFC-PASS3" + ext
    PASS4 = "HALSFC-PASS4" + ext
    TEMPLIB = "TEMPLIB"
    CARDS = "--ddo=3,cards.bin,E"
    TARGET = "--pfs"

appDir = findFileUsingPATH(PASS1)
if appDir == None:
    print("Directory containing the compiler is not in the PATH")
    sys.exit(1)
ERRORLIB = appDir + os.sep + "ERRORLIB" + os.sep
parmList = parmString.split(",")

# Run PASS1.
exitCode = os.system('''
%s \\
    --parm="%s" \\
    --ddi=0,"%s" \\
    --ddo=2,listing2.txt \\
    --pdsi=4,%s,E \\
    --pdsi=5,"%s" \\
    --pdsi=6,ACCESS  \\
    --pdso=6,%s,E \\
    --commono=COMMON0%s \\
    --raf=O,7200,1,halmat.bin \\
    --raf=O,1560,2,litfile.bin \\
    --raf=B,3360,6,vmem.bin \\
    >pass1.rpt
''' % (PASS1, parmString, halsFile, TEMPLIB, ERRORLIB, TEMPLIB, extCOMMON))
if exitCode != 0:
    errorExit("Aborted after PASS1")
shutil.copy("litfile.bin", "litfile0.bin")

# Maybe run PASS1 tests. 
if test:
    print("======================================================")
    diff = "diff" + ext
    egrep = "egrep" + ext
    if None == findFileUsingPATH(diff):
        errorExit("Not available for --test:  " + diff )
    if None == findFileUsingPATH(egrep):
        errorExit("Not available for --test:  " + egrep)
    ported=findFileUsingPATH("HAL_S_FC.py")
    if ported == None:
        errorExit("Not available for --test:  HAL_S_FC.py")
    ported=Path(ported).parent
    if ported == None:
        errorExit("Not available for --test:  HAL_S_FC.py")
    command = 'HAL_S_FC.py %s %s --templib --hal="%s" >pass1p.rpt' \
                         % (TARGET, parmString.replace(",", " "), halsFile)
    #print(command)
    exitCode = os.system(command)
    if exitCode:
        errorExit("Failed PASS1 cross-comparison test")
    print("PASS1 cross-comparison test:")
    for n in filesPorted:
        try:
            shutil.copy(os.path.join(ported, n), n)
        except:
            pass
    IGNORE_LINES='(HAL/S|FREE STRING AREA|NUMBER OF FILE 6|PROCESSING RATE|CPU TIME FOR|TODAY IS|COMPOOL.*VERSION)'
    if isWindows:
        IGNORE_LINES = IGNORE_LINES.replace("|", "^|")
    os.system('egrep -v "%s" pass1.rpt >pass1A.rpt' % IGNORE_LINES)
    os.system('egrep -v "%s" pass1p.rpt >pass1pA.rpt' % IGNORE_LINES)
    os.system('diff --strip-trailing-cr -q -s pass1A.rpt pass1pA.rpt')
    os.system('diff -s FILE1.bin halmat.bin')
    if "LISTING2" in parmList:
            os.system('diff --strip-trailing-cr -q -s LISTING2.txt listing2.txt')
    print("======================================================")

# Run FLO.
exitCode = os.system('''
%s \\
    --commoni=COMMON0%s \
    --commono=COMMON1%s \
    --raf=I,7200,1,halmat.bin \
    --raf=I,1560,2,litfile.bin \
    --raf=B,3360,6,vmem.bin \
    >flo.rpt
''' % (FLO, extCOMMON, extCOMMON))
if exitCode != 0:
    errorExit("Aborted after FLO")
shutil.copy("litfile.bin", "litfile1.bin")

# Run OPT.
exitCode = os.system('''
%s \\
    --commoni=COMMON1%s \
    --commono=COMMON2%s \
    --raf=I,7200,1,halmat.bin \
    --raf=B,1560,2,litfile.bin \
    --raf=O,7200,4,optmat.bin \
    --raf=B,3360,6,vmem.bin \
    >opt.rpt
''' % (OPT, extCOMMON, extCOMMON))
if exitCode != 0:
    errorExit("Aborted after OPT")
shutil.copy("litfile.bin", "litfile2.bin")

# Run AUX.
exitCode = os.system('''
%s \\
    --commoni=COMMON2%s \
    --commono=COMMON3%s \
    --raf=O,7200,1,auxmat.bin \
    --raf=I,1560,2,litfile.bin \
    --raf=I,7200,4,optmat.bin \
    --raf=B,3360,6,vmem.bin \
    >auxp.rpt
''' % (AUXP, extCOMMON, extCOMMON))
if exitCode != 0:
    errorExit("Aborted after AUX")
shutil.copy("litfile.bin", "litfile3.bin")

# Run PASS2
exitCode = os.system('''
%s \\
    %s \
    --ddo=4,deck.bin,E \
    --pdsi=5,"%s" \
    --ddo=7,extra.txt \
    --commoni=COMMON3%s \
    --commono=COMMON4%s \
    --raf=I,7200,1,auxmat.bin \
    --raf=B,1560,2,litfile.bin \
    --raf=B,1600,3,objcode.bin \
    --raf=I,7200,4,optmat.bin \
    --raf=B,3360,6,vmem.bin \
    >pass2.rpt
''' % (PASS2, CARDS, ERRORLIB, extCOMMON, extCOMMON))
if exitCode != 0:
    errorExit("Aborted after PASS2")
shutil.copy("litfile.bin", "litfile4.bin")

# PASS3 and PASS4 aren't ready for use yet.

moveAll("Success: $COMMAND_LINE")
print("Compilation successful. Results in \"%s\"." % results)
