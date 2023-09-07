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

from g import *

'''
   /* ROUTINE CALLED TO HANDLE PROCESSING OF INCLUDE DIRECTIVE.     */
   /* RETURNS TRUE IF TEMPLATE IS TO BE PROCESSED, FALSE OTHERWISE. */
'''

def INCLUDE_OK():
    global C, COMPARE_SOURCE, CURRENT_CARD, INCLUDE_COMPRESSED, INCLUDE_LIST, \
            INCLUDE_LIST2, INCLUDE_OFFSET, INCLUDE_OPENED, INCLUDE_STMT, \
            INCLUDING, INITIAL_INCLUDE_RECORD, MEMBER, \
            REV_CAT, TEMPLATE_FLAG, TPL_REMOTE
    # Locals:
    INCL_FLAGS = 0
    LIST_FLAG = 0
    SDF_FLAG = 0
    
    
    if INCLUDING:
        ERROR(CLASS_XI,1);
        return FALSE;
    INCL_FLAGS = 0;
    C = D_TOKEN;
    TEMPLATE_FLAG = FALSE
    SDF_FLAG = FALSE;
    if C  == 'TEMPLATE':
        SDF_FLAG = TRUE
        TEMPLATE_FLAG = TRUE;
        INCL_FLAGS = INCL_FLAGS | INCL_TEMPLATE_FLAG;
        MEMBER = D_TOKEN;
    elif C == 'SDF':
        SDF_FLAG = TRUE;
        MEMBER = D_TOKEN;
    else:
        MEMBER = C;
    if LENGTH(MEMBER) == 0:
        ERROR(CLASS_XI,2);
        return FALSE;
    C = D_TOKEN;
    LIST_FLAG = TRUE;
    while True:
        if C == 'NOLIST':
            LIST_FLAG = FALSE;
        elif (C == 'NOSDF') and TEMPLATE_FLAG:
            SDF_FLAG = FALSE;
        elif C == 'REMOTE':
           INCL_FLAGS = INCL_FLAGS | INCL_REMOTE_FLAG;
           if TEMPLATE_FLAG:
               TPL_REMOTE = TRUE;
           elif not SDF_FLAG:
               ERROR(CLASS_XI, 4);
        else:
            ESCAPE();
        C = D_TOKEN;
    if (TEMPLATE_FLAG or SDF_FLAG) and CREATING:
        ERROR(CLASS_XI, 12);
        return FALSE;
    if SDF_FLAG:
        if INCLUDE_SDF(MEMBER, INCL_FLAGS):
            return FALSE;
        if not TEMPLATE_FLAG:
            return FALSE;
    if TEMPLATE_FLAG:
        MEMBER = DESCORE(MEMBER);
    elif LENGTH(MEMBER) < 8:
        MEMBER = PAD(MEMBER, 8);
    else:
        MEMBER = SUBSTR(MEMBER, 0, 8);
    if FINDER(4, MEMBER, 0): # FIND THE MEMBER
        ERROR(CLASS_XI,3,MEMBER);
        return FALSE;
    if TEMPLATE_FLAG:
        COMPARE_SOURCE=FALSE;
        # SAVE CURRENT STMT NUMBER FOR 'INCLUDE TEMPLATE NOSDF'
        INCLUDE_STMT = STMT_NUM;
    INCL_FLAGS = INCL_FLAGS | SHL(0x1,SHR(INCLUDE_FILEp,1));
    REV_CAT = MONITOR(15);
    INCLUDE_MSG = ' OF INCLUDED MEMBER, RVL ' \
                    + STRING(0x01000000 | ADDR(REV_CAT)) + \
                    ', CATENATION NUMBER ' + (REV_CAT & 0xFFFF);
    INCLUDE_LIST = LIST_FLAG
    INCLUDE_LIST2 = LIST_FLAG;
    INCLUDE_OFFSET = CARD_COUNT + 1;
    if SIMULATING:
        MAKE_INCL_CELL(MEMBER, INCL_FLAGS, REV_CAT);
    INCLUDING = TRUE;
    INPUT_DEV = 4;
    INCLUDE_OPENED = TRUE;
    CURRENT_CARD = INPUT(INPUT_DEV);
    LRECL(1, LENGTH(CURRENT_CARD) - 1);
    if BYTE(CURRENT_CARD) == 0x00:
        # COMPRESSED SOURCE
        INCLUDE_COMPRESSED = TRUE;
        INPUT_REC(1, CURRENT_CARD);
    else:
        INITIAL_INCLUDE_RECORD = TRUE;
    return TRUE;
