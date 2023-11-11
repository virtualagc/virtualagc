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
shutil.rmtree(scriptFolder + "/HALINCL", ignore_errors = True)
shutil.copytree(scriptParentFolder + "/HALINCL", \
                scriptFolder + "/HALINCL")
#####################################################################

from xplBuiltins import MONITOR
import g
from INITIALI import INITIALIZATION
from COMPILAT import COMPILATION_LOOP
from ALMOST_DISASTER import ALMOST_DISASTER

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

#import HALINCL.COMMON as h
#from watchpoints import watch
#watch(g.FCN_LV)

# THE_BEGINNING:
g.CLOCK[1] = MONITOR(18)
COMPILATION_LOOP()
ALMOST_DISASTER()  # GO TO ALMOST_DISASTER
