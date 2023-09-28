#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ENTERLAY.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-16 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR


def ENTER_LAYOUT(NDX):
    g.PROGRAM_LAYOUT_INDEX = g.PROGRAM_LAYOUT_INDEX + 1;
    if g.PROGRAM_LAYOUT_INDEX > g.PROGRAM_LAYOUT_LIM:
        g.PROGRAM_LAYOUT_INDEX = g.PROGRAM_LAYOUT_LIM;
        ERROR(d.CLASS_P, 6);
    else:
        g.PROGRAM_LAYOUT[g.PROGRAM_LAYOUT_INDEX] = NDX;
    return;
