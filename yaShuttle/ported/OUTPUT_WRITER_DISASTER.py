#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   OUTPUT_WRITER_DISASTER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Split off from ##DRIVER.py.

See the comments in ##DRIVER.py.
'''

from xplBuiltins import OUTPUT
import g
from ERRORSUM import ERROR_SUMMARY
from ENDITNOW import ENDITNOW


def OUTPUT_WRITER_DISASTER():
    OUTPUT(1, g.SUBHEADING)
    ERROR_SUMMARY()
    ENDITNOW()  # GO TO ENDITNOW
