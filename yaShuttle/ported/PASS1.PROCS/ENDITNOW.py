#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ENDITNOW.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Split off from ##DRIVER.py.

See the comments in ##DRIVER.py.
'''

import sys
from xplBuiltins import OUTPUT
import g
from HALINCL.DOWNSUM import DOWNGRADE_SUMMARY

def ENDITNOW():
    OUTPUT(1, g.DOUBLE)
    if g.MAX_SEVERITY > 2:
        DOWNGRADE_SUMMARY()
    OUTPUT(0, g.X32 + \
             '*****  C O M P I L A T I O N   A B A N D O N E D  *****')
    print()
    exit(g.MAX_SEVERITY << 2)
    
