#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ALMOST_DISASTER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Split off from ##DRIVER.py.

See the comments in ##DRIVER.py.
'''

from xplBuiltins import OUTPUT, MONITOR
import g
import HALINCL.COMMON as h
from PRINTSUM import PRINT_SUMMARY
from HALINCL.SPACELIB import RECORD_LINK
from ENDITNOW import ENDITNOW

def ALMOST_DISASTER():
    OUTPUT(1, g.SUBHEADING)
    g.CLOCK[2] = MONITOR(18)
    if g.MAX_SEVERITY == 0 and h.SEVERITY_ONE:
        g.MAX_SEVERITY = 1
    PRINT_SUMMARY()
    if (g.COMPILING & 0x80) != 0:  # HALMAT COMPLETE FLAG
        if g.MAX_SEVERITY < 2:
            if g.CONTROL[1] == g.FALSE:
                g.TOGGLE(   (g.CONTROL[2] & 0x80) | \
                            (g.CONTROL[5] & 0x40) | \
                            (g.CONTROL[9] & 0x10) | \
                            (g.CONTROL[6] & 0x20) )
                if g.MAX_SEVERITY > 0:
                    g.TOGGLE(g.TOGGLE() | 0x08)
                RECORD_LINK()
    ENDITNOW() # GO TO ENDITNOW
            
