#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ##DRIVER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-24 RSB  Began porting from ##DRIVER.xpl, segregating global
                            into the separate module g.py.

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

from xplBuiltins import MONITOR
import g
from INITIALI import INITIALIZATION
from COMPILAT import COMPILATION_LOOP
from ALMOST_DISASTER import ALMOST_DISASTER

#from watchpoints import watch
#watch(g.PSEUDO_FORM[3], g.FIXV[5])

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

# THE_BEGINNING:
g.CLOCK[1] = MONITOR(18)
COMPILATION_LOOP()
ALMOST_DISASTER()  # GO TO ALMOST_DISASTER
