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

import sys
from xplBuiltins import *

import g
import HALINCL.COMMON as h
from INITIALI import INITIALIZATION
from COMPILAT import COMPILATION_LOOP
from PRINTSUM import PRINT_SUMMARY
from OUTPUTWR import OUTPUT_WRITER
from ERRORSUM import ERROR_SUMMARY
from HALINCL.DOWNSUM import DOWNGRADE_SUMMARY
from HALINCL.SPACELIB import RECORD_LINK

'''
The global variable g.monitorLabel is used for subroutines upon error to 
indicate the severity of error, and hence which label to "GO TO" here at this
top level of the program.  Python has no "GO TO", so we have to accomplish this
in a more-clunky indirect fashion.
'''

# Initialization
g.monitorLabel = None
g.CLOCK[0] = MONITOR(18)
INITIALIZATION()
if g.monitorLabel != None:
    routing = g.monitorLabel
else:
    routing = "THE BEGINNING"

if routing == "THE BEGINNING":
    g.monitorLabel = None
    g.CLOCK[1] = MONITOR(18)
    COMPILATION_LOOP()
    if g.monitorLabel != None:
        routing = g.monitorLabel
    else:
        routing = "ALMOST_DISASTER" # Fall through
    
if routing == "ALMOST_DISASTER":
    g.monitorLabel = None
    OUTPUT(1, g.SUBHEADING)
    g.CLOCK[2] = MONITOR(18)
    if g.MAX_SEVERITY == 0 and h.SEVERITY_ONE:
        g.MAX_SEVERITY = 1
    PRINT_SUMMARY()
    if g.monitorLabel != None:
        routing = g.monitorLabel
    else:
        if (g.COMPILING & 0x80) != 0: # HALMAT COMPLETE FLAG
            if g.MAX_SEVERITY < 2:
                if g.CONTROL[1] == g.FALSE:
                    g.TOGGLE =  (g.CONTROL[2] & 0x80) | \
                                (g.CONTROL[5] & 0x40) | \
                                (g.CONTROL[9] & 0x10) | \
                                (g.CONTROL[6] & 0x20)
                    if g.MAX_SEVERITY > 0:
                        g.TOGGLE = g.TOGGLE | 0x08
                    RECORD_LINK()
        if g.monitorLabel != None:
            routing = g.monitorLabel
        else:
            g.MAX_SEVERITY = 4
            routing = "ENDITNOW"
        
if routing == "SCAN_DISASTER":
    g.monitorLabel = None
    OUTPUT_WRITER()
    if g.monitorLabel != None:
        routing = g.monitorLabel
    else:
        routine = "OUTPUT_WRITER_DISASTER"
    
if routing == "OUTPUT_WRITER_DISASTER":
    g.monitorLabel = None
    OUTPUT(1, g.SUBHEADING)
    ERROR_SUMMARY()
    if g.monitorLabel != None:
        routing = g.monitorLabel
    else:
        routing = "ENDITNOW"
    
if routing == "ENDITNOW":
    g.monitorLabel = None
    OUTPUT(1, g.DOUBLE)
    if g.MAX_SEVERITY > 2:
        DOWNGRADE_SUMMARY()
    OUTPUT(0, g.X32 + \
             '*****  C O M P I L A T I O N   A B A N D O N E D  *****')
    print()
    exit(g.MAX_SEVERITY << 2)

print("Implementation error: Unknown routing", file=sys.stderr)
exit(1)
