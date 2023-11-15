#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PATCHINC.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-06 RSB  Ported
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR   import ERROR
from DESCORE import DESCORE
from FINDER  import FINDER
from PAD     import PAD
from HALINCL.DTOKEN import D_TOKEN
from HALINCL.INCSDF   import INCLUDE_SDF
from HALINCL.MAKEINCL import MAKE_INCL_CELL

'''
   /* ROUTINE CALLED TO HANDLE PROCESSING OF INCLUDE DIRECTIVE.     */
   /* RETURNS TRUE IF TEMPLATE IS TO BE PROCESSED, FALSE OTHERWISE. */
'''


class cINCLUDE_OK:

    def __init__(self):
        self.INCL_FLAGS = 0
        self.LIST_FLAG = 0
        self.SDF_FLAG = 0


lINCLUDE_OK = cINCLUDE_OK()


def INCLUDE_OK():
    l = lINCLUDE_OK
    
    if g.INCLUDING:
        ERROR(d.CLASS_XI, 1);
        return g.FALSE;
    l.INCL_FLAGS = 0;
    g.C[0] = D_TOKEN();
    g.TEMPLATE_FLAG = g.FALSE
    l.SDF_FLAG = g.FALSE;
    if g.C[0] == 'TEMPLATE':
        l.SDF_FLAG = g.TRUE
        g.TEMPLATE_FLAG = g.TRUE;
        l.INCL_FLAGS = l.INCL_FLAGS | g.INCL_TEMPLATE_FLAG;
        g.MEMBER = D_TOKEN();
    elif g.C[0] == 'SDF':
        l.SDF_FLAG = g.TRUE;
        g.MEMBER = D_TOKEN();
    else:
        g.MEMBER = g.C[0];
    if LENGTH(g.MEMBER) == 0:
        ERROR(d.CLASS_XI, 2);
        return g.FALSE;
    g.C[0] = D_TOKEN();
    l.LIST_FLAG = g.TRUE;
    while True:
        if g.C[0] == 'NOLIST':
            l.LIST_FLAG = g.FALSE;
        elif (g.C[0] == 'NOSDF') and g.TEMPLATE_FLAG:
            l.SDF_FLAG = g.FALSE;
        elif g.C[0] == 'REMOTE':
           l.INCL_FLAGS = l.INCL_FLAGS | g.INCL_REMOTE_FLAG;
           if g.TEMPLATE_FLAG:
               g.TPL_REMOTE = g.TRUE;
           elif not l.SDF_FLAG:
               ERROR(d.CLASS_XI, 4);
        else:
            # Originally, ESCAPE.  That doesn't appear to be a keyword in
            # XPL, nor is it a parameterless PROCEDURE defined in the original
            # XPL code.  Looking through the source code, it appears to be
            # equivalent to the HAL/S EXIT ... i.e., it breaks out of a loop,
            # optionally to a label.
            break
        g.C[0] = D_TOKEN();
    if (g.TEMPLATE_FLAG or l.SDF_FLAG) and g.CREATING:
        ERROR(d.CLASS_XI, 12);
        return g.FALSE;
    if l.SDF_FLAG:
        if INCLUDE_SDF(g.MEMBER, l.INCL_FLAGS):
            return g.FALSE;
        if not g.TEMPLATE_FLAG:
            return g.FALSE;
    if g.TEMPLATE_FLAG:
        g.MEMBER = DESCORE(g.MEMBER);
    elif LENGTH(g.MEMBER) < 8:
        g.MEMBER = PAD(g.MEMBER, 8);
    else:
        g.MEMBER = SUBSTR(g.MEMBER, 0, 8);
    if FINDER(4, g.MEMBER, 0):  # FIND THE MEMBER
        ERROR(d.CLASS_XI, 3, g.MEMBER);
        return g.FALSE;
    if g.TEMPLATE_FLAG:
        g.COMPARE_SOURCE = g.FALSE;
        # SAVE CURRENT STMT NUMBER FOR 'INCLUDE TEMPLATE NOSDF'
        g.INCLUDE_STMT = g.STMT_NUM();
    l.INCL_FLAGS = l.INCL_FLAGS | SHL(0x1, SHR(g.INCLUDE_FILEp, 1));
    g.REV_CAT = MONITOR(15);
    sREV_CAT = BYTE(BYTE('', 0, (g.REV_CAT >> 24) & 0xFF) , \
                    1, (g.REV_CAT >> 16) & 0xFF)
    g.INCLUDE_MSG = ' OF INCLUDED MEMBER, RVL ' + sREV_CAT + \
                    ', CATENATION NUMBER ' + str(g.REV_CAT & 0xFFFF);
    g.INCLUDE_LIST = l.LIST_FLAG
    g.INCLUDE_LIST2 = l.LIST_FLAG;
    g.INCLUDE_OFFSET = g.CARD_COUNT + 1;
    if g.SIMULATING:
        MAKE_INCL_CELL(g.MEMBER, l.INCL_FLAGS, g.REV_CAT);
    g.INCLUDING = g.TRUE;
    g.INPUT_DEV = 4;
    g.INCLUDE_OPENED = g.TRUE;
    g.CURRENT_CARD = INPUT(g.INPUT_DEV);
    g.LRECL[1] = LENGTH(g.CURRENT_CARD) - 1;
    if BYTE(g.CURRENT_CARD) == 0x00:
        # COMPRESSED SOURCE
        g.INCLUDE_COMPRESSED = g.TRUE;
        g.INPUT_REC[1] = g.CURRENT_CARD[:];
    else:
        g.INITIAL_INCLUDE_RECORD = g.TRUE;
    return g.TRUE;
