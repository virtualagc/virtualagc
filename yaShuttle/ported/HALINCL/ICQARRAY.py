#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ICQARRAY.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-10-07 RSB  Ported
'''

import g
import HALINCL.COMMON as h

def ICQ_ARRAYp(LOC):
    # Local (I) doesn't need persistence.
    if g.NAME_IMPLIED:
        return 1;
    I = 1;
    if g.SYT_ARRAY(LOC) != 0:
        for LOC in range(g.SYT_ARRAY(LOC) + 1, \
                         g.SYT_ARRAY(LOC) + h.EXT_ARRAY[g.SYT_ARRAY(LOC)] + 1):
            I = h.EXT_ARRAY[LOC] * I;
    return I;
