#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SETDUPLF.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Ported
'''

import g
import HALINCL.CERRDECL as d
from ERROR import ERROR


def SET_DUPL_FLAG(DUPL_TERM):
    # J is local.
    J = DUPL_TERM;
    while g.SYT_TYPE(J) != g.TEMPL_NAME:
        J = J - 1;
    g.SYT_FLAGS(J, g.SYT_FLAGS(J) | g.DUPL_FLAG);
    if g.SYT_PTR(J) > 0:
        g.SYT_PTR(J, 0);
        ERROR(d.CLASS_DQ, 7, g.SYT_NAME(g.DUPL_TERM));
    return;
