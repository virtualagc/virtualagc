#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   SAVETOKE.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-11 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g
from OUTPUTWR import OUTPUT_WRITER

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  SAVE_TOKEN                                             */
 /* MEMBER NAME:     SAVETOKE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          TOKEN             BIT(16)                                      */
 /*          CHAR              CHARACTER;                                   */
 /*          TYPE              BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ACTUAL_PRINTING_ENABLED  BIT(16)                               */
 /*          BCD_PTR_CHECK(1528)  LABEL                                     */
 /*          OUTPUT_STACK_RELOCATE(1542)  LABEL                             */
 /*          STMT_PTR_CHECK    LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          INCLUDE_LIST                                                   */
 /*          OUTPUT_STACK_MAX                                               */
 /*          PRINTING_ENABLED                                               */
 /*          RESERVED_WORD                                                  */
 /*          SAVE_BCD_MAX                                                   */
 /*          SP                                                             */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ATTR_LOC                                                       */
 /*          BCD_PTR                                                        */
 /*          COMMENT_COUNT                                                  */
 /*          ELSEIF_PTR                                                     */
 /*          ERROR_PTR                                                      */
 /*          GRAMMAR_FLAGS                                                  */
 /*          I                                                              */
 /*          LAST_WRITE                                                     */
 /*          SAVE_BCD                                                       */
 /*          SQUEEZING                                                      */
 /*          STACK_PTR                                                      */
 /*          STMT_PTR                                                       */
 /*          STMT_STACK                                                     */
 /*          SUPPRESS_THIS_TOKEN_ONLY                                       */
 /*          TOKEN_FLAGS                                                    */
 /*          WAIT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          OUTPUT_WRITER                                                  */
 /* CALLED BY:                                                              */
 /*          RECOVER                                                        */
 /*          COMPILATION_LOOP                                               */
 /*          SCAN                                                           */
 /***************************************************************************/
'''


class cSAVE_TOKEN:

    def __init__(self):
        self.ACTUAL_PRINTING_ENABLED = 0


lSAVE_TOKEN = cSAVE_TOKEN()


def SAVE_TOKEN(TOKEN, CHAR, TYPE, MACRO_ARG=g.FALSE):
    l = lSAVE_TOKEN  # Locals.
    
    if not g.INCLUDE_LIST:
        g.COMMENT_COUNT = -1
        g.STACK_PTR[g.SP] = -1;
        return;
    
    def OUTPUT_STACK_RELOCATE():
        # The only local, PTR, doesn't require persistence.
        
        if g.STMT_PTR < 0:
            return;
        if g.LAST_WRITE > 0:
            PTR = g.LAST_WRITE;
            if g.IF_FLAG:
                g.SAVE1 = 0;
                g.SAVE2 = g.SAVE2 - PTR;
            g.LAST_WRITE = 0;
        elif g.IF_FLAG:
            g.SAVE_SRN2 = g.SRN[2][:];
            g.SRN[2] = g.SAVE_SRN1[:];
            g.SAVE_SRN_COUNT2 = g.SRN_COUNT[2];
            g.SRN_COUNT[2] = g.SAVE_SRN_COUNT1;
            g.STMT_NUM(g.STMT_NUM() - 1);
            g.IF_FLAG = g.FALSE;
            PTR = OUTPUT_WRITER(g.SAVE1, g.SAVE2);
            g.STMT_NUM(g.STMT_NUM() + 1);
            g.SRN[2] = g.SAVE_SRN2[:];
            g.SRN_COUNT[2] = g.SAVE_SRN_COUNT2;
            # IF SAVE2 > PTR THEN THE ENTIRE IF STATEMENT HAS NOT
            # BEEN PRINTED YET.
            if (g.SAVE2 > PTR):
                g.IF_FLAG = g.TRUE;
                g.SAVE1 = 0;
                g.SAVE2 = g.SAVE2 - PTR;
            else:
                g.INDENT_LEVEL = g.INDENT_LEVEL + g.INDENT_INCR;
        else:
            PTR = OUTPUT_WRITER();
        g.BCD_PTR = 0;
        for g.STMT_PTR in range(0, g.STMT_PTR - PTR + 1):
            g.I = g.STMT_PTR + PTR;
            g.STMT_STACK[g.STMT_PTR] = g.STMT_STACK[g.I];
            g.RVL_STACK1[g.STMT_PTR] = g.RVL_STACK1[g.I];
            g.RVL_STACK2[g.STMT_PTR] = g.RVL_STACK2[g.I];
            g.GRAMMAR_FLAGS(g.STMT_PTR, g.GRAMMAR_FLAGS(g.I));
            g.TOKEN_FLAGS(g.STMT_PTR, g.TOKEN_FLAGS(g.I));
            g.ERROR_PTR[g.STMT_PTR] = g.ERROR_PTR[g.I];
            if SHR(g.TOKEN_FLAGS(g.STMT_PTR), 6) != 0:
                g.BCD_PTR = g.BCD_PTR + 1;
                g.SAVE_BCD[g.BCD_PTR] = \
                    g.SAVE_BCD[SHR(g.TOKEN_FLAGS(g.STMT_PTR), 6)][:];
                g.TOKEN_FLAGS(g.STMT_PTR, (g.TOKEN_FLAGS(g.STMT_PTR) & 0x3F) \
                                                | SHL(g.BCD_PTR, 6));
        g.STMT_PTR += 1
        if g.FACTOR_FOUND:
            g.GRAMMAR_FLAGS(1, g.GRAMMAR_FLAGS(1) | g.ATTR_BEGIN_FLAG);
        for g.I in range(0, g.SP):
            if g.STACK_PTR[g.I] < PTR:
                if not (g.FACTORING & g.STACK_PTR[g.I] == 1):
                    g.STACK_PTR[g.I] = -1;
            else:
                g.STACK_PTR[g.I] = g.STACK_PTR[g.I] - PTR;
        if g.ELSEIF_PTR < PTR:
            g.ELSEIF_PTR = -1;
        else:
            g.ELSEIF_PTR = g.ELSEIF_PTR - PTR;
        for g.I in range(2, PTR_TOP + 1):
            if g.EXT_P[g.I] != 0:
                g.EXT_P[g.I] = g.EXT_P[g.I] - PTR;
    
    g.STMT_PTR = g.STMT_PTR + 1;
    goto_STMT_PTR_CHECK = True
    while goto_STMT_PTR_CHECK:
        goto_STMT_PTR_CHECK = False
        if g.STMT_PTR > g.OUTPUT_STACK_MAX:
            g.STMT_PTR = g.OUTPUT_STACK_MAX;
            g.SQUEEZING = g.TRUE;
            OUTPUT_STACK_RELOCATE();
            if g.ATTR_LOC > 0:
                g.ATTR_LOC = 0;
            goto_STMT_PTR_CHECK = True
            continue
    g.TOKEN_FLAGS(g.STMT_PTR, TYPE);
    if not g.RESERVED_WORD:
        if g.PRINTING_ENABLED > 0:
            # NOT IN V TABLE, SO SAVE IT
            goto_BCD_PTR_CHECK = True
            while goto_BCD_PTR_CHECK:
                goto_BCD_PTR_CHECK = False
                g.BCD_PTR = g.BCD_PTR + 1;
                if g.BCD_PTR > g.SAVE_BCD_MAX:
                    g.SQUEEZING = g.TRUE;
                    g.STMT_PTR = g.STMT_PTR - 1;
                    OUTPUT_STACK_RELOCATE();
                    if g.ATTR_LOC > 0:
                        g.ATTR_LOC = 0;
                    goto_BCD_PTR_CHECK = True
                    continue
            g.SAVE_BCD[g.BCD_PTR] = CHAR[:];
            g.TOKEN_FLAGS(g.STMT_PTR, TYPE | SHL(g.BCD_PTR, 6));
            # Well, the following line seems to have no effect whatsoever,
            # given the preceding line ... but the original XPL has it.
            g.TOKEN_FLAGS(g.STMT_PTR, g.TOKEN_FLAGS(g.STMT_PTR) | \
                                        SHL(g.BCD_PTR, 6));
    g.STMT_STACK[g.STMT_PTR] = TOKEN;
    if not g.INCLUDING:
        # SAVE EACH BYTE OF RVL INTO CORRESPONDING ARRAY.  THIS ALLOWS
        # EACH TOKEN TO HAVE AN RVL ASSOCIATED WITH IT.  THESE ARRAYS
        # ARE USED IN OUTPUT_WRITER TO PRINT THE MOST RECENT RVL.
        g.RVL_STACK1[g.STMT_PTR] = BYTE(g.RVL[0], 0);
        g.RVL_STACK2[g.STMT_PTR] = BYTE(g.RVL[0], 1);
        # ASSIGN RVL THE RVL ASSOCIATED WITH THE FIRST CHARACTER OF THE
        # NEXT LINE.
        g.RVL[0] = g.NEXT_CHAR_RVL[:];
    g.ERROR_PTR[g.STMT_PTR] = -1;
    if g.WAIT:
        g.WAIT = g.FALSE;
        l.ACTUAL_PRINTING_ENABLED = 0;
    else:
        l.ACTUAL_PRINTING_ENABLED = g.PRINTING_ENABLED;
    if g.SUPPRESS_THIS_TOKEN_ONLY:
        g.SUPPRESS_THIS_TOKEN_ONLY = 0
        g.GRAMMAR_FLAGS(g.STMT_PTR, 0);
    else:
        g.GRAMMAR_FLAGS(g.STMT_PTR, l.ACTUAL_PRINTING_ENABLED);
    if TYPE != 7:  # DON'T POINT AT REPLACES
        if not MACRO_ARG:  # DON'T POINT AT REPLACE ARG
            g.STACK_PTR[g.SP] = g.STMT_PTR;
    MACRO_ARG = g.FALSE;
