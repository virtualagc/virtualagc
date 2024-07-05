#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   FINISHMA.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-22 RSB  Ported
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.VMEM2 as v2
from HALINCL.VMEM3 import GET_CELL, MOVE
from HALINCL.SPACELIB import NEXT_ELEMENT


# I doubt if any of the local variables in FINISH_MACRO_TEXT *need* to be 
# persistent, but it's tricky to tell at a glance.  So I'll just make them
# all persistent, which is the safest thing to do in XPL
class cFINISH_MACRO_TEXT:

    def __init__(self):
        self.NODE_F0 = 0
        self.NODE_F1 = 0
        self.ARG_FLAG = 0
        self.NEXT_CELL_PTR = 0
        self.TEXT_PTR = 0
        self.BLANK_BYTES = 0
        self.CELLSIZE = 0
        self.TEXT_SIZE = 0
        self.II = 0
        
lFINISH_MACRO_TEXT = cFINISH_MACRO_TEXT()


def FINISH_MACRO_TEXT():
    l = lFINISH_MACRO_TEXT  # All local variables
    
    # ROUTINE TO PUT TERMINATION CHARACTERS ONTO END OF REPLACE
    # MACRO TEXT, AND (IF SIMULATING) MOVE THE MACRO TEXT TO
    # VIRTUAL MEMORY
    if g.FIRST_FREE() != 0:
        l.II = g.MACRO_TEXT(g.FIRST_FREE() - 1);
        if (g.MACRO_TEXT(g.FIRST_FREE() - 2) == BYTE(')') and l.II == BYTE('`')) \
                or l.II == BYTE(')') or g.MACRO_ARG_COUNT > 0:
            NEXT_ELEMENT(g.MACRO_TEXTS);
            NEXT_ELEMENT(g.MACRO_TEXTS);
            g.MACRO_TEXT(g.FIRST_FREE(), 0xEE);
            g.MACRO_TEXT(g.FIRST_FREE() + 1, 0);
            g.FIRST_FREE(g.FIRST_FREE() + 2);
    g.MACRO_TEXT(g.FIRST_FREE(), 0xEF);
    if g.SIMULATING > 0:
        if g.MACRO_TEXT(g.FIRST_FREE() - 2) == 0xEE and \
                g.MACRO_TEXT(g.FIRST_FREE() - 1) == 0:
            l.TEXT_SIZE = (g.FIRST_FREE() - 2) - g.START_POINT;
            l.TEXT_PTR = (g.FIRST_FREE() - 2) - g.MACRO_CELL_LIM;
            if g.MACRO_ARG_COUNT > 0: 
                l.ARG_FLAG = 0x80000000;
            else:
                l.ARG_FLAG = 0;
        else:
            l.TEXT_SIZE = g.FIRST_FREE() - g.START_POINT;
            l.TEXT_PTR = g.FIRST_FREE() - g.MACRO_CELL_LIM;
            l.ARG_FLAG = 0;
        if l.TEXT_SIZE < 0: 
            l.TEXT_SIZE = 0;
        l.NEXT_CELL_PTR = -1;
        while l.TEXT_SIZE >= g.MACRO_CELL_LIM:
            l.CELLSIZE = g.MACRO_CELL_LIM;
            if g.MACRO_TEXT(l.TEXT_PTR - 1) == 0xEE:
                l.TEXT_PTR = l.TEXT_PTR + 1;
                l.CELLSIZE = l.CELLSIZE - 1;
            g.REPLACE_TEXT_PTR, l.NODE_F0 = GET_CELL(l.CELLSIZE + 6, v2.MODF);
            l.NODE_F0 = l.NEXT_CELL_PTR;
            l.NODE_F1 = SHL(l.CELLSIZE, 16);
            g.MACRO_BYTES(g.MACRO_BYTES() + g.MACRO_CELL_LIM);
            MOVE(l.CELLSIZE, (g.MACRO_TEXT(l.TEXT_PTR), 0), \
                 v2.VMEM_LOC_ADDR + 6);
            l.NEXT_CELL_PTR = g.REPLACE_TEXT_PTR;
            l.TEXT_PTR = l.TEXT_PTR - g.MACRO_CELL_LIM;
            l.TEXT_SIZE = l.TEXT_SIZE - l.CELLSIZE;
        if l.TEXT_SIZE > 0:
            g.REPLACE_TEXT_PTR, l.NODE_F0 = GET_CELL(l.TEXT_SIZE + 6, v2.MODF);
            l.NODE_F0 = l.NEXT_CELL_PTR;
            l.NODE_F1 = SHL(l.TEXT_SIZE, 16);
            l.NEXT_CELL_PTR = g.REPLACE_TEXT_PTR;
            g.MACRO_BYTES(g.MACRO_BYTES() + ((l.TEXT_SIZE + 3) & 0xFFFC));
            MOVE(l.TEXT_SIZE, (g.MACRO_TEXT(g.START_POINT), 0), \
                 v2.VMEM_LOC_ADDR + 6);
        g.REPLACE_TEXT_PTR, l.NODE_F0 = GET_CELL(8, v2.MODF);
        l.NODE_F0 = l.NEXT_CELL_PTR;
        l.NODE_F1 = 0xFFFF0000 + l.BLANK_BYTES;
        g.REPLACE_TEXT_PTR = g.REPLACE_TEXT_PTR | l.ARG_FLAG;
    g.FIRST_FREE(g.FIRST_FREE() + 1);
    NEXT_ELEMENT(g.MACRO_TEXTS);
    return;
