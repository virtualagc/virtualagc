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

'''
   /* ROUTINE CALLED TO HANDLE PROCESSING OF INCLUDE DIRECTIVE.     */
   /* RETURNS TRUE IF TEMPLATE IS TO BE PROCESSED, FALSE OTHERWISE. */
'''

def INCLUDE_OK():
    # Locals:
    INCL_FLAGS = 0
    LIST_FLAG = 0
    SDF_FLAG = 0
    
    
    if g.INCLUDING:
        ERROR(CLASS_XI,1);
        return FALSE;
    INCL_FLAGS = 0;
    g.C[0] = D_TOKEN;
    g.TEMPLATE_FLAG = FALSE
    SDF_FLAG = FALSE;
    if g.C[0]  == 'TEMPLATE':
        SDF_FLAG = TRUE
        g.TEMPLATE_FLAG = TRUE;
        INCL_FLAGS = INCL_FLAGS | INCL_TEMPLATE_FLAG;
        g.MEMBER = D_TOKEN;
    elif g.C[0] == 'SDF':
        SDF_FLAG = TRUE;
        g.MEMBER = D_TOKEN;
    else:
        g.MEMBER = g.C[0];
    if LENGTH(g.MEMBER) == 0:
        ERROR(CLASS_XI,2);
        return FALSE;
    g.C[0] = D_TOKEN;
    LIST_FLAG = TRUE;
    while True:
        if g.C[0] == 'NOLIST':
            LIST_FLAG = FALSE;
        elif (g.C[0] == 'NOSDF') and g.TEMPLATE_FLAG:
            SDF_FLAG = FALSE;
        elif g.C[0] == 'REMOTE':
           INCL_FLAGS = INCL_FLAGS | INCL_REMOTE_FLAG;
           if g.TEMPLATE_FLAG:
               g.TPL_REMOTE = TRUE;
           elif not SDF_FLAG:
               ERROR(CLASS_XI, 4);
        else:
            ESCAPE();
        g.C[0] = D_TOKEN;
    if (g.TEMPLATE_FLAG or SDF_FLAG) and CREATING:
        ERROR(CLASS_XI, 12);
        return FALSE;
    if SDF_FLAG:
        if INCLUDE_SDF(g.MEMBER, INCL_FLAGS):
            return FALSE;
        if not g.TEMPLATE_FLAG:
            return FALSE;
    if g.TEMPLATE_FLAG:
        g.MEMBER = DESCORE(g.MEMBER);
    elif LENGTH(g.MEMBER) < 8:
        g.MEMBER = PAD(g.MEMBER, 8);
    else:
        g.MEMBER = SUBSTR(g.MEMBER, 0, 8);
    if FINDER(4, g.MEMBER, 0): # FIND THE MEMBER
        ERROR(CLASS_XI,3,g.MEMBER);
        return FALSE;
    if g.TEMPLATE_FLAG:
        g.COMPARE_SOURCE=FALSE;
        # SAVE CURRENT STMT NUMBER FOR 'INCLUDE TEMPLATE NOSDF'
        g.INCLUDE_STMT = STMT_NUM;
    INCL_FLAGS = INCL_FLAGS | SHL(0x1,SHR(INCLUDE_FILEp,1));
    g.REV_CAT = MONITOR(15);
    INCLUDE_MSG = ' OF INCLUDED MEMBER, RVL ' \
                    + STRING(0x01000000 | ADDR(g.REV_CAT)) + \
                    ', CATENATION NUMBER ' + (g.REV_CAT & 0xFFFF);
    g.INCLUDE_LIST = LIST_FLAG
    g.INCLUDE_LIST2 = LIST_FLAG;
    g.INCLUDE_OFFSET = CARD_COUNT + 1;
    if SIMULATING:
        MAKE_INCL_CELL(g.MEMBER, INCL_FLAGS, g.REV_CAT);
    g.INCLUDING = TRUE;
    INPUT_DEV = 4;
    g.INCLUDE_OPENED = TRUE;
    g.CURRENT_CARD = INPUT(INPUT_DEV);
    LRECL(1, LENGTH(g.CURRENT_CARD) - 1);
    if BYTE(g.CURRENT_CARD) == 0x00:
        # COMPRESSED SOURCE
        g.INCLUDE_COMPRESSED = TRUE;
        INPUT_REC(1, g.CURRENT_CARD);
    else:
        g.INITIAL_INCLUDE_RECORD = TRUE;
    return TRUE;
