#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and mals -dsflkdsjfy be used or modified in any way desired.
Filename:   HAL_S_FC.py ... formerly known as ##DRIVER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-24 RSB  Began porting from ##DRIVER.xpl, segregating global
                            into the separate module g.py.
            2023-11-10 RSB  Renamed ##DRIVER.py -> HAL-S-FC.py to avoid
                            certain cross-platform difficulties.  And
                            besides, it was just the right thing to do!
            2023-11-11 RSB  Renamed again, to HAL_S_FC.py, since it 
                            turns out that "HAL-S-FC" is not a valid
                            name for a Python module (and all Python
                            scripts are Python modules).

 /***************************************************************************/
 /* PROCEDURE NAME:  MAIN PROGRAM                                           */
 /* MEMBER NAME:     ##DRIVER                                               */
 /* PURPOSE:         THE DRIVER PROGRAM FOR A PHASE OF THE COMPILER.        */
 /*                  THIS MEMBER IS THE MAIN PROGRAM, THE OTHER MEMBERS     */
 /*                  SHOULD BE CHECKED FOR HEADER INFORMATION.              */
 /* LOCAL DECLARATIONS:                                                     */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /* CALLED BY:                                                              */
 /***************************************************************************/
'''

#####################################################################
# Every port from ##DRIVER.xpl needs the following, in order for all
# of them to use the same xplBuiltins.py and HALINCL/ without conflict.
import os
import pathlib
import shutil
scriptFolder = os.path.dirname(__file__)
scriptParentFolder = str(pathlib.Path(scriptFolder).parent.absolute())
shutil.copyfile(scriptParentFolder + "/xplBuiltins.py", \
                scriptFolder + "/xplBuiltins.py")
shutil.rmtree(scriptFolder + "/HALINCL", ignore_errors=True)
shutil.copytree(scriptParentFolder + "/HALINCL", \
                scriptFolder + "/HALINCL")
#####################################################################

from xplBuiltins import *
import g
from INITIALI import INITIALIZATION
from COMPILAT import COMPILATION_LOOP
from ALMOST_DISASTER import ALMOST_DISASTER

#####################################################################
# This stuff handles for us what DD cards in JCL did originally.
# I.e., it opens the files we need.  We don't have to do it if just
# printing the --help message.  Note that we don't need to handle the
# random-access files FILE1 through FILE6, nor the system printer
# OUTPUT, since xplBuiltins.py hard-codes those.
import sys

if "--help" not in sys.argv:

    # Parse the command-line arguments to see if there's anything that
    # modifies how we're supposed to open the files.
    sourceFile = None  # Use stdin by default for HAL/S source-code file.
    listing2 = False
    templib = False
    for parm in sys.argv[1:]:
        if parm.startswith("--hal="):
            sourceFile = parm[6:]
            if not sourceFile.endswith(".hal"):
                sourceFile = sourceFile + ".hal"
        elif parm == "LISTING2":
            listing2 = True
        elif parm == "--templib":
            templib = True

    # Open the files that we need for INPUT() and OUTPUT(), other than 
    # output files 0 and 1 (whose behavior is hard-coded separately), 
    # and buffer their contents where appropriate.  Does not include
    # random-access files handled by the FILE() function.
    
    # Start with INPUT(0), which is much more complex than the other 
    # files in order to take care of possible use of stdin, filtering 
    # out UTF-8 characters, path convenience substitutions, and so on.
    if sourceFile == None:  # HAL/S source code.
        f = sys.stdin
        sourceFile = "stdin"
    else:
        # Get the source-file name from the compiler's --hal switch.
        # If the file turns out to not be in the current folder, try several others.
        # This is just a convenience for me in debugging, based on the notion that
        # the compiler is being run from the yaShuttle/ported/ folder in the source 
        # tree.  The other folders don't need to be checked in a production version
        # of the compiler, since they most likely don't even exist.
        folders = (
            "",
            scriptParentFolder + "/../Source Code/Programming in HAL-S/",
            scriptParentFolder + "/../Source Code/HAL-S-360 Users Manual/"
            )
        f = None
        i = 0
        while f == None and i < len(folders):
            try:
                s = folders[i] + sourceFile
                f = open(s, "r")
                sourceFile = s
                break
            except:
                f = None
                i += 1
        if f == None:
            print("Couldn't find the source file (%s)" % sourceFile, \
                  file=sys.stderr)
            sys.exit(1)
    dummy = []
    for line in f:
        # Regarding the "\xef\xbb\xbf" replacement ... *apparently*,
        # in Windows, if you make the mistake of editing a HAL/S source
        # file containing a UTF-8 character ("¬", "¢"), Windows will
        # thoughtfully stick the UTF-8 character encoded as 
        # "\xef\xbb\xbf" at the beginning of the file when you save it.
        # Of course, for us, that's pure garbage, so we remove it if
        # it's there ... or anywhere!
        line = line.rstrip('\n\r').replace("¬", "~").replace("^", "~")\
                   .replace("¢", "`").replace("\xef\xbb\xbf", "")\
                   .expandtabs(8).ljust(80)
        dummy.append(line)
    inputDevices[0] = {
        "file": f,
        "open": True,
        "ptr":-1,
        "buf": dummy
        }
    
    # The rest of the files can be handled a bit more systematically.
    if listing2:
        # Secondary output listing.
        outputDevices[2] = openGenericOutputDevice("LISTING2.hal")
    # Template library.
    inputDevices[4] = openGenericInputDevice("TEMPLIB.json", True, templib)
    # Error-message library.
    inputDevices[5] = openGenericInputDevice("ERRORLIB.json", True)
    # File of module access rights.
    inputDevices[6] = openGenericInputDevice("ACCESS.json", True)
    # Where to stow output templates.
    if templib: # In permanent template library.
        outputDevices[6] = inputDevices[4]
    else:       # In temporary template library.
        outputDevices[6] = openGenericOutputDevice("&&TEMPLIB.json", True)
    # Temporary includes.
    outputDevices[8] = openGenericOutputDevice("&&TEMPINC.json", True)
    # Source-comparision output.
    outputDevices[9] = openGenericOutputDevice("SOURCECO.txt")
####################################################################

'''
In XPL, 5 parts comprised this driver module, one of which (THE_BEGINNING)
always executed, but the other 4 were only run selectively via GO TO statements
at this level or lower levels in the module hierarchy.  Since Python has no
GO TO, we have to do things differently.  Fortunately, those GO TO targets, if 
reached, each result directly or indirectly in termination of the program, so 
what we do is just to provide each of those 4 GO TO blocks of code as separate
subroutines, callable from any level of the code without having to come back
here after the subroutines complete.

For example, if there are no errors, COMPILATION_LOOP() below does not return,
and terminates the program by means that don't concern us at the moment,
*without* falling through to ALMOST_DISASTER().  Whereas in case of error,
COMPILATION_LOOP() does return and falls through.  ALMOST_DISASTER() is itself
an error exit.  The other error exits (not shown below) are SCAN_DISASTER(), 
OUTPUT_WRITER_DISASTER(), and ENDITNOW().
'''

# Initialization
g.CLOCK[0] = MONITOR(18)
INITIALIZATION()

# import HALINCL.COMMON as h
# from watchpoints import watch
# watch(g.FCN_LV)

# THE_BEGINNING:
g.CLOCK[1] = MONITOR(18)
COMPILATION_LOOP()
ALMOST_DISASTER()  # GO TO ALMOST_DISASTER
