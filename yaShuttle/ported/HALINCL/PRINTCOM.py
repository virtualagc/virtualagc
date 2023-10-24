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
from IFORMAT  import I_FORMAT
from OUTPUTWR import OUTPUT_WRITER
from PAD      import PAD
from PRINT2   import PRINT2

'''
It's unclear what's going on with the CURRENT_DIR parameters.  Most CALLs
to PRINT_COMMENT don't have it, but *some* do.  Defaulting it to an empty
string is just my guess.
'''


def PRINT_COMMENT(PRINT, CURRENT_DIR=''):
    # FORMAT_CHAR, C, T, and R are locals, but don't appear to need persistence.
    
    FORMAT_CHAR = '|';
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
            g.STMT_NUM(g.STMT_NUM() - 1);
            g.SAVE_SRN2 = g.SRN[2][:];
            g.SRN[2] = g.SAVE_SRN1[:];
            g.SAVE_SRN_COUNT2 = g.SRN_COUNT[2];
            g.SRN_COUNT[2] = g.SAVE_SRN_COUNT1;
            g.IF_FLAG = g.FALSE;
            OUTPUT_WRITER(g.SAVE1, g.SAVE2);
            g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
            if g.STMT_PTR > -1:
                g.LAST_WRITE = g.SAVE2 + 1;
            g.STMT_NUM(g.STMT_NUM() + 1);
            g.SRN[2] = g.SAVE_SRN2[:];
            g.SRN_COUNT[2] = g.SAVE_SRN_COUNT2;
        else:
            g.ELSE_FLAG = g.FALSE;
            OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);
    g.S = str(g.CARD_COUNT + 1 - g.INCLUDE_OFFSET);
    g.S = PAD(g.S, 4);
    # PRINT THE STATEMENT NUMBER FOR D INCLUDE, PRINT BLANKS
    # FOR OTHER DIRECTIVES AND COMMENTS.
    if (g.CARD_TYPE[BYTE(g.CURRENT_CARD)] == g.CARD_TYPE[BYTE('D')]) \
            and (CURRENT_DIR == 'INCLUDE'):
        R = I_FORMAT(g.STMT_NUM(), 4);
    else:
        R = g.X4;
    if g.INCLUDING:
        g.INCLUDE_CHAR = g.PLUS;
        T = g.PAD1[:];
        if g.SRN_PRESENT:
            R = g.PAD1[:];
    else:
        g.INCLUDE_CHAR = g.X1;
        if g.SRN_PRESENT:
            # PRINT THE STATEMENT NUMBER FOR D INCLUDE.
            # IF PRINTING SRNS, ADD THE STATEMENT NUMBER TO THE SRN IN R.
            R = PAD(SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 1, 6), 7) + R;
        if g.SDL_OPTION:
            T = SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 7, 2);
            if LENGTH(g.CURRENT_CARD) >= g.TEXT_LIMIT[0] + 17:
                T = T + g.X1 + SUBSTR(g.CURRENT_CARD, g.TEXT_LIMIT[0] + 9, 8);
            else:
                T = T + SUBSTR(g.X70, 0, 9);
    if g.LISTING2:
        PRINT2(C + SUBSTR(g.X8, 1) + g.INCLUDE_CHAR + \
            SUBSTR(g.CURRENT_CARD, 0, 1) + g.VBAR + \
            SUBSTR(g.CURRENT_CARD, 1) + g.VBAR + g.S + g.X1 + g.CURRENT_SCOPE, g.I);
    if PRINT:
        if g.LINE_MAX == 0:
            g.LINE_MAX = g.LINE_LIM;
            C = g.PAGE;
        g.I = 100 - g.TEXT_LIMIT[0];
        # MOVE THE REVISION LEVEL TO THE FIRST 2 COLUMNS OF
        # THE CURRENT SCOPE FIELD WHEN SDL_OPTION IS TRUE.
        if g.SDL_OPTION:
            g.S = FORMAT_CHAR + SUBSTR(T, 0, 2) + FORMAT_CHAR + g.SAVE_SCOPE;
        else:
            g.S = FORMAT_CHAR + g.SAVE_SCOPE;
        g.S = SUBSTR(g.CURRENT_CARD, 1, g.TEXT_LIMIT[0]) + SUBSTR(g.X70, 0, g.I) + g.S;
        OUTPUT(1, C + R + g.INCLUDE_CHAR + SUBSTR(g.CURRENT_CARD, 0, 1) + g.VBAR + g.S);
    g.NEXT_CC = ' ';
    '''
    Since CURRENT_DIR is a parameter of the procedure, the commented-out line 
    below appears to be pointless if the XPL compiler is implemented according 
    to the documentation (McKeeman et al section 6.14) ... namely, that changes
    within procedures to procedure parameters have no effect in the calling
    code.  But I *suspect* that the 
    XPL compiler was implemented in a non-compliant manner, in which string 
    parameters were passed by reference rather than by value, and hence the 
    commented-out line (depending on the implementation details) could 
    conceivably empty the string corresponding to CURRENT_DIR in the calling
    code. If that's true, then there is a boundary case (in the STREAM module,
    for a HAL/S source line that's a Data Directive), in which that could have
    a visible effect.  Given that all of this is based on inference, I'll not
    attempt to implement anything based on those inferences at present, but 
    it's possible that this will have to be revisited in the future.
    If we had the text of CR12713, it could potentially clear up some of the 
    mystery.
    '''
    # CURRENT_DIR = '';
    g.PREV_ELINE = g.FALSE;
