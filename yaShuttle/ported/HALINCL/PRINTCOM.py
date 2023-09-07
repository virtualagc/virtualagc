#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   PRINTCOM.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-06 RSB  Ported
'''

from xplBuiltins import *
import g
from OUTPUTWR import OUTPUT_WRITER

# It's unclear what's going on with the CURRENT_DIR parameters.  Most CALLs
# to PRINT_COMMENT don't have it, but *some* do.  Defaulting it to an empty
# string is just my guess.
def PRINT_COMMENT(PRINT,CURRENT_DIR=''):
    # Locals:
    FORMAT_CHAR = ''
    C = ''
    T = ''
    R = ''
    
    FORMAT_CHAR='|';
    if not g.INCLUDE_LIST2:
        return;
    g.I = 1;
    if g.COMMENTING:
        C = g.X1;
    else:
        g.SQUEEZING = g.FALSE;
        g.I = 2;
        C = g.DOUBLE;
        if g.IF_FLAG:
            g.STMT_NUM = g.STMT_NUM - 1;
            g.SAVE_SRN2 = g.SRN[2];
            g.SRN[2] = SAVE_SRN1;
            g.SAVE_SRN_COUNT2 = g.SRN_COUNT[2];
            g.SRN_COUNT[2] = SAVE_SRN_COUNT1;
            IF_FLAG = FALSE;
            OUTPUT_WRITER(SAVE1,SAVE2);
            g.INDENT_LEVEL=g.INDENT_LEVEL+INDENT_INCR;
            if STMT_PTR > -1:
                LAST_WRITE = SAVE2+1;
            g.STMT_NUM = g.STMT_NUM + 1;
            g.SRN[2] = g.SAVE_SRN2;
            g.SRN_COUNT[2] = g.SAVE_SRN_COUNT2;
        else:
            g.ELSE_FLAG = g.FALSE;
            OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);
    g.S = g.CARD_COUNT + 1 - g.INCLUDE_OFFSET;
    g.S = PAD(g.S, 4);
    # PRINT THE STATEMENT NUMBER FOR D INCLUDE, PRINT BLANKS
    # FOR OTHER DIRECTIVES AND COMMENTS.
    if (g.CARD_TYPE[BYTE(g.CURRENT_CARD)] == g.CARD_TYPE[BYTE('D')]) \
            and (CURRENT_DIR == 'INCLUDE'):
        R = I_FORMAT(g.STMT_NUM,4);
    else:
        R = g.X4;
    if g.INCLUDING:
        g.INCLUDE_CHAR = g.PLUS;
        T = g.PAD1;
        if g.SRN_PRESENT:
            R = g.PAD1;
    else:
        g.INCLUDE_CHAR = g.X1;
        if g.SRN_PRESENT:
            # PRINT THE STATEMENT NUMBER FOR D INCLUDE.
            # IF PRINTING SRNS, ADD THE STATEMENT NUMBER TO THE SRN IN R.
            R = PAD(SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 1, 6), 7)+R;
        if g.SDL_OPTION:
            T = SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 7, 2);
            if LENGTH(g.CURRENT_CARD) >= g.TEXT_LIMIT[0] + 17:
                T = T + g.X1 + SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 9, 8);
            else:
                T = T + SUBSTR(X70, 0, 9);
    if g.LISTING2:
        PRINT2(C + SUBSTR(g.X8, 1) + g.INCLUDE_CHAR + \
            SUBSTR(g.CURRENT_CARD, 0, 1) + g.VBAR + \
            SUBSTR(g.CURRENT_CARD, 1) + g.VBAR + g.S + g.X1 + g.CURRENT_SCOPE, g.I);
    if PRINT:
        if g.LINE_MAX == 0:
            g.LINE_MAX = g.LINE_LIM;
            C = g.PAGE;
        g.I=100-g.TEXT_LIMIT[0];
        # MOVE THE REVISION LEVEL TO THE FIRST 2 COLUMNS OF
        # THE CURRENT SCOPE FIELD WHEN SDL_OPTION IS TRUE.
        if g.SDL_OPTION:
            g.S=g.FORMAT_CHAR+SUBSTR(T,0,2)+g.FORMAT_CHAR+g.SAVE_SCOPE;
        else:
            g.S=FORMAT_CHAR+g.SAVE_SCOPE;
        g.S=SUBSTR(g.CURRENT_CARD,1,g.TEXT_LIMIT[0])+SUBSTR(g.X70,0,g.I)+g.S;
        OUTPUT(1, C+R+g.INCLUDE_CHAR+SUBSTR(g.CURRENT_CARD,0,1)+g.VBAR+g.S);
    g.NEXT_CC = ' ';
    CURRENT_DIR = '';
    g.PREV_ELINE = g.FALSE;
