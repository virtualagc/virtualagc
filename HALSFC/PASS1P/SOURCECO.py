#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SOURCECO.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Created a stub.
            2023-09-18 RSB  Ported.
'''

from xplBuiltins import *
import g

'''
 *************************************************************************
  PROCEDURE NAME:  SOURCE_COMPARE
  MEMBER NAME:     SOURCECO
  LOCAL DECLARATIONS:
           INCL_NUM          CHARACTER;
           DELTA_LEN         BIT(16)
           PATCH_INCL_NUM    CHARACTER;
           PATCH_SRN_COUNT   BIT(16)
           REPLCNT           BIT(16)
  EXTERNAL VARIABLES REFERENCED:
           ADDED
           DELETED
           FALSE
           INCL_LOG_MSG
           INCLUDING
           INPUT_DEV
           PATCH_INCL_HEAD
           PATCH_TEXT_LIMIT
           PATCHSAVE
           PLUS
           SAVE_LINE
           SRN_COUNT
           STARS
           TEXT_LIMIT
           TRUE
           UPDATE_INPUT_DEV
           X1
           X109
           X70
           X8
  EXTERNAL VARIABLES CHANGED:
           ADDING
           COMPARE_SOURCE
           CUR_CARD
           CURRENT_CARD
           CURRENT_SRN
           DELETING
           FIRST_CARD
           I
           INITIAL_INCLUDE_RECORD
           MORE
           NO_MORE_PATCH
           NO_MORE_SOURCE
           PAT_CARD
           PATCH_CARD
           PATCH_COUNT
           PATCH_SRN
           PRINT_INCL_HEAD
           PRINT_INCL_TAIL
           REPLACING
           SAVE_PATCH
           UPDATING
  EXTERNAL PROCEDURES CALLED:
           LEFT_PAD
           SRNCMP
  CALLED BY:
           INITIALIZATION
 *************************************************************************
'''


def SOURCE_COMPARE():
    # The local variables are as follows.  Since SOURCE_COMPARE() is called
    # precisely once, persistence is not an issue.
    REPLCNT = 0;
    PATCH_SRN_COUNT = 0;
    PATCH_INCL_NUM = ''
    INCL_NUM = '';
    DELTA_LEN = 0;
    
    # THIS ROUTINE COMPARES THE SRNS AND THE TEXT LINES
    # OF THE ORIGINAL AND PATCHED SOURCES TO DETERMINE THE
    # UPDATE MODE(ADDING.DELETING OR REPLACING)
    if g.NO_MORE_SOURCE: 
        return;
    if not g.FIRST_CARD:
        if not g.INITIAL_INCLUDE_RECORD:
            g.CURRENT_CARD = INPUT(g.INPUT_DEV)[:];
            pass
    else:
        if not g.COMPARE_SOURCE:
            g.INITIAL_INCLUDE_RECORD = g.FALSE;
            return;
    if not g.COMPARE_SOURCE: 
        return;
    if LENGTH(g.CURRENT_CARD) != 0:
        g.CUR_CARD = SUBSTR(g.CURRENT_CARD, 0, g.TEXT_LIMIT[0]);
        g.CURRENT_SRN = SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 1, 6);
    else:
        g.NO_MORE_SOURCE = g.TRUE;
    # MORE INDICATES THAT ADDITIONAL RECORDS HAVE TO READ FROM THE
    # PATCH INPUT IN ORDER TO SYNCHRONIZE
    g.MORE = g.TRUE;
    while g.MORE:
        # READ UPDATED SOURCE CODE
        if g.NO_MORE_PATCH: 
            return;
        if not g.DELETING:
            if not g.FIRST_CARD:
                if not g.INITIAL_INCLUDE_RECORD:
                    g.PATCH_CARD = INPUT(g.UPDATE_INPUT_DEV);
                else:
                    g.INITIAL_INCLUDE_RECORD = g.FALSE;
                    PATCH_SRN_COUNT = 0;
            g.FIRST_CARD = g.FALSE;
            if LENGTH(g.PATCH_CARD) == 0:
                if not g.INCLUDING:
                    g.COMPARE_SOURCE = g.FALSE;
                g.NO_MORE_PATCH = g.TRUE;
                if REPLCNT != 0:
                    for g.I in range(0, REPLCNT):
                        OUTPUT(9, g.PATCHSAVE(g.I));
                REPLCNT = 0;
                return;
            else:
                g.PAT_CARD = SUBSTR(g.PATCH_CARD, 0, g.TEXT_LIMIT[0]);
                g.PATCH_SRN = SUBSTR(g.PATCH_CARD, g.PATCH_TEXT_LIMIT[0] + 1, 6);
        if g.INCLUDING:
            if (BYTE(SUBSTR(g.CUR_CARD, 0, 1)) != BYTE('D')) and \
                    (BYTE(SUBSTR(g.CUR_CARD, 0, 1)) != BYTE('C')):
               INCL_NUM = LEFT_PAD('(' + g.PLUS + (g.SRN_COUNT[0] + 1) + ')', 6) \
                            +g.X1;
            else:
               INCL_NUM = g.X8;
            if (BYTE(SUBSTR(g.PAT_CARD, 0, 1)) != BYTE('D')) and \
                    (BYTE(SUBSTR(g.PAT_CARD, 0, 1)) != BYTE('C')): 
                if not g.DELETING: 
                    PATCH_SRN_COUNT = PATCH_SRN_COUNT + 1;
                    PATCH_INCL_NUM = LEFT_PAD(g.PLUS + PATCH_SRN_COUNT, 6) + \
                                        g.X1;
            else:
                PATCH_INCL_NUM = g.X8;
        else:
            INCL_NUM = '';
            PATCH_INCL_NUM = '';
        # DO CASE SRNCMP(CURRENT_SRN,PATCH_SRN);
        sc = SRNCMP(g.CURRENT_SRN, g.PATCH_SRN)
        if sc == 0:
            # CASE 0, SRNS IDENTICAL, TEXTS POSSIBLY DIFFERENT
            if g.PAT_CARD != g.CUR_CARD:
                # TEXTS DIFFERENT
                if g.UPDATING: 
                    if not g.REPLACING:
                        OUTPUT(9, g.X70);
                        g.ADDING = g.FALSE
                        g.DELETING = g.FALSE;
                g.UPDATING = g.TRUE;
                g.REPLACING = g.TRUE;
                if g.INCLUDING and g.PRINT_INCL_HEAD:
                    OUTPUT(9, g.X1 + PATCH_INCL_HEAD);
                    OUTPUT(9, 'I' + g.STARS + ' START ' + g.INCL_LOG_MSG);
                    OUTPUT(9, g.X1);
                    g.PRINT_INCL_HEAD = g.FALSE;
                    g.PRINT_INCL_TAIL = g.TRUE;
                DELTA_LEN = LENGTH(g.CURRENT_CARD) + LENGTH(INCL_NUM);
                g.PATCH_COUNT = g.PATCH_COUNT + 1;
                OUTPUT(9, g.X1 + g.CURRENT_SRN + g.X1 + INCL_NUM + g.CUR_CARD + \
                    SUBSTR(g.X109, DELTA_LEN) + g.DELETED);
                DELTA_LEN = LENGTH(g.PATCH_CARD) + LENGTH(PATCH_INCL_NUM);
                g.PATCHSAVE(REPLCNT, 'R' + g.PATCH_SRN + g.X1 + PATCH_INCL_NUM \
                    +g.PAT_CARD + SUBSTR(g.X109, DELTA_LEN) + g.ADDED);
                REPLCNT = REPLCNT + 1;
                while RECORD_USED(g.SAVE_PATCH) <= REPLCNT:
                    NEXT_ELEMENT(g.SAVE_PATCH);
            else:
                if g.UPDATING:
                    if g.REPLACING:
                        for g.I in range(0, REPLCNT):
                            OUTPUT(9, g.PATCHSAVE(g.I));
                        REPLCNT = 0;
                    g.UPDATING = g.FALSE;
                    g.ADDING, g.DELETING
                    g.REPLACING = g.FALSE;
                    OUTPUT(9, g.X70);
            if g.NO_MORE_SOURCE: 
                g.MORE = g.TRUE;
            else:
                g.MORE = g.FALSE;
        elif sc == 1:
            # CASE 1: g.CURRENT_SRN<PATCH_SRN
            if g.UPDATING:
                if not g.DELETING:
                    if g.REPLACING:
                        for g.I in range(0, REPLCNT):
                           OUTPUT(9, g.PATCHSAVE(g.I));
                        REPLCNT = 0;
                    OUTPUT(9, g.X70);
            g.DELETING = g.TRUE;
            g.UPDATING = g.TRUE;
            g.REPLACING = g.FALSE
            g.ADDING = g.FALSE = g.FALSE;
            if g.INCLUDING and g.PRINT_INCL_HEAD:
                OUTPUT(9, g.X1 + PATCH_INCL_HEAD);
                OUTPUT(9, 'I' + g.STARS + ' START ' + g.INCL_LOG_MSG);
                OUTPUT(9, g.X1);
                g.PRINT_INCL_HEAD = g.FALSE;
                g.PRINT_INCL_TAIL = g.TRUE;
            DELTA_LEN = LENGTH(g.CURRENT_CARD) + LENGTH(INCL_NUM);
            g.PATCH_COUNT = g.PATCH_COUNT + 1;
            OUTPUT(9, 'D' + g.CURRENT_SRN + g.X1 + INCL_NUM + g.CUR_CARD + \
                        SUBSTR(g.X109, DELTA_LEN) + g.DELETED);
            if g.NO_MORE_SOURCE: 
                g.MORE = g.TRUE;
            else:
                g.MORE = g.FALSE;
        elif sc == 2:
            # CASE 2 :CURRENT_SRN>PATCH_SRN
            g.MORE = g.TRUE;
            if g.UPDATING:
                if not g.ADDING:
                    if g.REPLACING:
                        for g.I in range(0, REPLCNT):
                            OUTPUT(9, g.PATCHSAVE(g.I));
                        REPLCNT = 0;
                    g.ADDING = g.TRUE;
                    g.REPLACING = g.FALSE
                    g.DELETING = g.FALSE;
                    OUTPUT(9, g.X70);
            if g.INCLUDING and g.PRINT_INCL_HEAD:
                OUTPUT(9, g.X1 + PATCH_INCL_HEAD);
                OUTPUT(9, 'I' + g.STARS + ' START ' + g.INCL_LOG_MSG);
                OUTPUT(9, g.X1);
                g.PRINT_INCL_HEAD = g.FALSE;
                g.PRINT_INCL_TAIL = g.TRUE;
            DELTA_LEN = LENGTH(g.PATCH_CARD) + LENGTH(PATCH_INCL_NUM);
            g.PATCH_COUNT = g.PATCH_COUNT + 1;
            OUTPUT(9, 'A' + g.PATCH_SRN + g.X1 + PATCH_INCL_NUM + g.PAT_CARD + \
                        SUBSTR(g.X109, DELTA_LEN) + g.ADDED);
            g.UPDATING = g.TRUE
            g.ADDING = g.TRUE;
    return;
    
