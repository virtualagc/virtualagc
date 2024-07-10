#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ASSOCIAT.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python.  Note that this port does not necessarily
            include all program comments that were present in the original code.
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-28 RSB  Began porting
'''

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
from ERROR import ERROR
from HALMATF2 import HALMAT_FIX_POPTAG
from SAVEARRA import SAVE_ARRAYNESS

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ASSOCIATE                                              */
 /* MEMBER NAME:     ASSOCIAT                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          TAG               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          ARR_STRUC_CHECK   LABEL                                        */
 /*          J                 FIXED                                        */
 /*          K                 FIXED                                        */
 /*          L                 FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ASSIGN_ARG_LIST                                                */
 /*          CLASS_PS                                                       */
 /*          CLASS_SV                                                       */
 /*          CLASS_UI                                                       */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          LEFT_BRACE_FLAG                                                */
 /*          LEFT_BRACKET_FLAG                                              */
 /*          LOCK_FLAG                                                      */
 /*          MP                                                             */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR                                                            */
 /*          READ_ACCESS_FLAG                                               */
 /*          RIGHT_BRACE_FLAG                                               */
 /*          RIGHT_BRACKET_FLAG                                             */
 /*          STACK_PTR                                                      */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /*          TEMPL_NAME                                                     */
 /*          UPDATE_BLOCK_LEVEL                                             */
 /*          VAR                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ARRAYNESS_STACK                                                */
 /*          AS_PTR                                                         */
 /*          EXT_P                                                          */
 /*          GRAMMAR_FLAGS                                                  */
 /*          TOKEN_FLAGS                                                    */
 /*          VAL_P                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_FIX_POPTAG                                              */
 /*          SAVE_ARRAYNESS                                                 */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def ASSOCIATE(TAG=-1):
    # Locals: I, J, K, L
    
    if g.FIXV[g.MP] == 0: 
        I = g.FIXL[g.MP];
    else: 
        I = g.FIXV[g.MP];
    if (g.SYT_FLAGS(I) & g.READ_ACCESS_FLAG) != 0:
        ERROR(d.CLASS_PS, 9, g.VAR[g.MP]);
    if (g.SYT_FLAGS(I) & g.LOCK_FLAG) != 0:  # LOCKED
        if not (g.ASSIGN_ARG_LIST & 1):
            if g.UPDATE_BLOCK_LEVEL <= 0:
                ERROR(d.CLASS_UI, 1, g.VAR[g.MP]);
    J = g.PSEUDO_TYPE[g.PTR[g.MP]];
    L = g.EXT_P[g.PTR[g.MP]];  # RHS OF TOKEN LIST
    if J > g.TEMPL_NAME: 
        pass  # GO TO ARR_STRUC_CHECK;
    elif L >= 0:
        I = g.TOKEN_FLAGS(L);
        K = I & 0x1F;  # IMPLIED TYPE
        if K == 7: 
            pass  # GO TO ARR_STRUC_CHECK;
        else:
            if K >= 3:
                if K <= 4:
                    if (J & 0x1F) != K:
                        ERROR(d.CLASS_SV, 2, g.VAR[g.MP]);
            I = (I - K) | (J & 0x1F);  # FINAL TYPE
            g.TOKEN_FLAGS(L, I);  # MARK GOES ON RIGTHMOST TOKEN
    # ARR_STRUC_CHECK:
    K = g.STACK_PTR[g.MP];
    J = g.VAL_P[g.PTR[g.MP]];
    if 0 != (1 & g.DELAY_CONTEXT_CHECK): 
        if g.SUBSCRIPT_LEVEL == 0:
            SAVE_ARRAYNESS();
            if (J & 0x206) == 0x202:
                g.AS_PTR = g.AS_PTR - 1;
                g.EXT_P[g.PTR[g.MP]] = g.ARRAYNESS_STACK[g.AS_PTR];
                if TAG >= 0: 
                    HALMAT_FIX_POPTAG(TAG, 1);
                J = J & 0xDFFE;
                g.ARRAYNESS_STACK[g.AS_PTR] = g.ARRAYNESS_STACK[g.AS_PTR + 1] - 1;
            else:
                g.EXT_P[g.PTR[g.MP]] = 0;
                J = J & 0xFFFC;
    if J & 1:  #  ARRAY MARKS NEEDED
        g.GRAMMAR_FLAGS(K, g.GRAMMAR_FLAGS(K) | g.LEFT_BRACKET_FLAG);
        g.GRAMMAR_FLAGS(L, g.GRAMMAR_FLAGS(L) | g.RIGHT_BRACKET_FLAG);
    if SHR(J, 1) & 1:  #  STRUCTURE MARKS NEEDED
        g.GRAMMAR_FLAGS(K, g.GRAMMAR_FLAGS(K) | g.LEFT_BRACE_FLAG);
        g.GRAMMAR_FLAGS(L, g.GRAMMAR_FLAGS(L) | g.RIGHT_BRACE_FLAG);
    TAG = -1;
    if SHR(J, 13) & 1: 
        g.VAL_P[g.PTR[g.MP]] = J | 0x10;
