#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ICQTERM#.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-25 RSB  Ported
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h


def ICQ_TERMp(LOC):
    # Local I
    if g.NAME_IMPLIED: 
        return 1;
    if g.SYT_TYPE(LOC) == g.VEC_TYPE: 
        return g.VAR_LENGTH(LOC);
    if g.SYT_TYPE(LOC) == g.MAT_TYPE: 
        I = g.VAR_LENGTH(LOC) & 0xFF;
        LOC = SHR(g.VAR_LENGTH(LOC), 8);
        return LOC * I;
    if g.SYT_TYPE(LOC) == g.MAJ_STRUC: 
        LOC = g.SYT_ADDR(g.VAR_LENGTH(LOC));
        if LOC > 0: 
            return LOC;
    return 1;
