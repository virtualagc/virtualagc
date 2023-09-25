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

'''
Originally, 5 parts comprised this driver module, one of which (THE_BEGINNING)
was always run, but the other 4 were selectively entered via GO TO statements
at this level or lower levels in the module hierarchy.  Since Python has no
GO TO, we have to do things differently.  It's relatively easy to work around
this just for the GO TO's at *this* level, but the ones at the lower levels
are a bit of a conundrum.  Fortunately, the blocks of code we need to reach
all result directly or indirectly in exits from the program, so what we do
instead is to provide each of the 4 problematic blocks of code as a separate
subroutine, callable from any level of the code.
'''

# Initialization
g.CLOCK[0] = MONITOR(18)
INITIALIZATION()

# THE_BEGINNING:
g.CLOCK[1] = MONITOR(18)
COMPILATION_LOOP()
ALMOST_DISASTER() # GO TO ALMOST_DISASTER
