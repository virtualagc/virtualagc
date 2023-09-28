#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SCAN_DISASTER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-24 RSB  Split off from ##DRIVER.py.

See the comments in ##DRIVER.py.
'''


def SCAN_DISASTER():
    
    '''
    Importing OUTPUTWR here rather than at the top of the file causes it to
    be imported at a later time, which avoids a partially-initialized 
    circular-import error , namely
            SCAN_DISASTER -> OUTPUTWR -> ERROR -> SCAN_DISASTER
    '''
    from OUTPUTWR import OUTPUT_WRITER
    from OUTPUT_WRITER_DISASTER import OUTPUT_WRITER_DISASTER
    
    OUTPUT_WRITER()
    OUTPUT_WRITER_DISASTER()  # GO TO OUTPUT_WRITER_DISASTER
