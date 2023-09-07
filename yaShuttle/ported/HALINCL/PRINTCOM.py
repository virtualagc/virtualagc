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

from g import *

def PRINT_COMMENT(PRINT,CURRENT_DIR):
    global SQUEEZING, I, STMT_NUM, SAVE_SRN2, SRN, SAVE_SRN_COUNT2, \
            SRN_COUNT, INDENT_LEVEL, S, INCLUDE_CHAR, LINE_MAX, NEXT_CC, \
            PREV_ELINE
    # Locals:
    FORMAT_CHAR = ''
    C = ''
    T = ''
    R = ''
    
    FORMAT_CHAR='|';
    if not INCLUDE_LIST2:
        return;
    I = 1;
    if COMMENTING:
        C = X1;
    else:
        SQUEEZING = FALSE;
        I = 2;
        C = DOUBLE;
        if IF_FLAG:
            STMT_NUM = STMT_NUM - 1;
            SAVE_SRN2 = SRN[2];
            SRN[2] = SAVE_SRN1;
            SAVE_SRN_COUNT2 = SRN_COUNT[2];
            SRN_COUNT[2] = SAVE_SRN_COUNT1;
            IF_FLAG = FALSE;
            OUTPUT_WRITER(SAVE1,SAVE2);
            INDENT_LEVEL=INDENT_LEVEL+INDENT_INCR;
            if STMT_PTR > -1:
                LAST_WRITE = SAVE2+1;
            STMT_NUM = STMT_NUM + 1;
            SRN[2] = SAVE_SRN2;
            SRN_COUNT[2] = SAVE_SRN_COUNT2;
        else:
            ELSE_FLAG = FALSE;
            OUTPUT_WRITER(LAST_WRITE, STMT_PTR);
    S = CARD_COUNT + 1 - INCLUDE_OFFSET;
    S = PAD(S, 4);
    # PRINT THE STATEMENT NUMBER FOR D INCLUDE, PRINT BLANKS
    # FOR OTHER DIRECTIVES AND COMMENTS.
    if (CARD_TYPE(BYTE(CURRENT_CARD)) == CARD_TYPE(BYTE('D'))) \
            and (CURRENT_DIR == 'INCLUDE'):
        R = I_FORMAT(STMT_NUM,4);
    else:
        R = X4;
    if INCLUDING:
        INCLUDE_CHAR = PLUS;
        T = PAD1;
        if SRN_PRESENT:
            R = PAD1;
    else:
        INCLUDE_CHAR = X1;
        if SRN_PRESENT:
            # PRINT THE STATEMENT NUMBER FOR D INCLUDE.
            # IF PRINTING SRNS, ADD THE STATEMENT NUMBER TO THE SRN IN R.
            R = PAD(SUBSTR(CURRENT_CARD, TEXT_LIMIT + 1, 6), 7)+R;
        if SDL_OPTION:
            T = SUBSTR(CURRENT_CARD, TEXT_LIMIT + 7, 2);
            if LENGTH(CURRENT_CARD) >= TEXT_LIMIT + 17:
                T = T + X1 + SUBSTR(CURRENT_CARD, TEXT_LIMIT + 9, 8);
            else:
                T = T + SUBSTR(X70, 0, 9);
    if LISTING2:
        PRINT2(C + SUBSTR(X8, 1) + INCLUDE_CHAR + \
            SUBSTR(CURRENT_CARD, 0, 1) + VBAR + \
            SUBSTR(CURRENT_CARD, 1) + VBAR + S + X1 + CURRENT_SCOPE, I);
    if PRINT:
        if LINE_MAX == 0:
            LINE_MAX = LINE_LIM;
            C = PAGE;
        I=100-TEXT_LIMIT;
        # MOVE THE REVISION LEVEL TO THE FIRST 2 COLUMNS OF
        # THE CURRENT SCOPE FIELD WHEN SDL_OPTION IS TRUE.
        if SDL_OPTION:
            S=FORMAT_CHAR+SUBSTR(T,0,2)+FORMAT_CHAR+SAVE_SCOPE;
        else:
            S=FORMAT_CHAR+SAVE_SCOPE;
        S=SUBSTR(CURRENT_CARD,1,TEXT_LIMIT)+SUBSTR(X70,0,I)+S;
        OUTPUT(1, C+R+INCLUDE_CHAR+SUBSTR(CURRENT_CARD,0,1)+VBAR+S);
    NEXT_CC = ' ';
    CURRENT_DIR = '';
    PREV_ELINE = FALSE;
