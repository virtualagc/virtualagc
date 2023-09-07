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

from sys import exit
from g import monitorLabel, CLOCK, MONITOR, OUTPUT, SUBHEADING, MAX_SEVERITY, \
                COMPILING, CONTROL, FALSE, TOGGLE, DOUBLE, X32
from INITIALI import INITIALIZATION
from COMPILAT import COMPILATION_LOOP
from PRINTSUM import PRINT_SUMMARY
from OUTPUTWR import OUTPUT_WRITER
from ERRORSUM import ERROR_SUMMARY
from HALINCL.COMMON import SEVERITY_ONE
from HALINCL.DOWNSUM import DOWNGRADE_SUMMARY
from HALINCL.SPACELIB import RECORD_LINK

monitorLabel = "THE_BEGINNING"
while True:
    routing = monitorLabel
    monitorLabel = None
    if routing == "THE_BEGINNING":
        CLOCK[0] = MONITOR(18)
        INITIALIZATION()
        if monitorLabel != None:
            continue
        CLOCK[1] = MONITOR(18)
        COMPILATION_LOOP()
        if monitorLabel != None:
            continue
        monitorLabel = "ALMOST_DISASTER" # Fall through
    elif routing == "ALMOST_DISASTER":
        OUTPUT(1, SUBHEADING)
        CLOCK[2] = MONITOR(18)
        if MAX_SEVERITY == 0 and SEVERITY_ONE:
            MAX_SEVERITY = 1
        PRINT_SUMMARY()
        if monitorLabel != None:
            continue
        if (COMPILING & 0x80) != 0: # HALMAT COMPLETE FLAG
            if MAX_SEVERITY < 2:
                if CONTROL[1] == FALSE:
                    TOGGLE =  (CONTROL[2] & 0x80) | \
                                (CONTROL[5] & 0x40) | \
                                (CONTROL[9] & 0x10) | \
                                (CONTROL[6] & 0x20)
                    if MAX_SEVERITY > 0:
                        TOGGLE = TOGGLE | 0x08
                    RECORD_LINK()
                    if monitorLabel != None:
                        continue
        MAX_SEVERITY = 4
        monitorLabel = "ENDITNOW"
    elif routing == "SCAN_DISASTER":
        OUTPUT_WRITER()
        if monitorLabel != None:
            continue
        monitorLabel = "OUTPUT_WRITER_DISASTER"
    elif routing == "OUTPUT_WRITER_DISASTER":
        OUTPUT(1, SUBHEADING)
        ERROR_SUMMARY()
        if monitorLabel != None:
            continue
        monitorLabel = "ENDITNOW"
    elif routing == "ENDITNOW":
        OUTPUT(1, DOUBLE)
        if MAX_SEVERITY > 2:
            DOWNGRADE_SUMMARY()
            if monitorLabel != None:
                continue
        OUTPUT(0, X32 + \
                 '*****  C O M P I L A T I O N   A B A N D O N E D  *****')
        print()
        exit(MAX_SEVERITY << 2)
    else:
        print("Implementation error: Unknown routing", file=sys.stderr)
        exit(1)
