#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   RECOVER.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-09-12 RSB  Began porting from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.CERRDECL as d
from SAVETOKE import SAVE_TOKEN
from CALLSCAN import CALL_SCAN
from CHECKARR import CHECK_ARRAYNESS
from CHECKTOK import CHECK_TOKEN
from STACKDUM import STACK_DUMP
from OUTPUTWR import OUTPUT_WRITER
from EMITSMRK import EMIT_SMRK

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  RECOVER                                                */
 /* MEMBER NAME:     RECOVER                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DECLARING         BIT(8)                                       */
 /*          BAD_BAD(1818)     LABEL                                        */
 /*          TOKEN_LOOP_START(1859)  LABEL                                  */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BCD                                                            */
 /*          DECLARE_TOKEN                                                  */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          EOFILE                                                         */
 /*          EVIL_FLAG                                                      */
 /*          FACTOR_LIM                                                     */
 /*          FALSE                                                          */
 /*          IC_PTR1                                                        */
 /*          IC_PTR2                                                        */
 /*          ID_TOKEN                                                       */
 /*          IMPLIED_TYPE                                                   */
 /*          LAST_WRITE                                                     */
 /*          LOOK_STACK                                                     */
 /*          REPLACE_TOKEN                                                  */
 /*          SAVE_INDENT_LEVEL                                              */
 /*          SEMI_COLON                                                     */
 /*          STATE_NAME                                                     */
 /*          STATE_STACK                                                    */
 /*          STMT_PTR                                                       */
 /*          STRUCTURE_WORD                                                 */
 /*          SUB_START_TOKEN                                                */
 /*          SYM_FLAGS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ASSIGN_ARG_LIST                                                */
 /*          BI_FUNC_FLAG                                                   */
 /*          COMPILING                                                      */
 /*          CONTEXT                                                        */
 /*          DELAY_CONTEXT_CHECK                                            */
 /*          DO_INIT                                                        */
 /*          FACTOR_FOUND                                                   */
 /*          FACTORED_TYPE                                                  */
 /*          FACTORING                                                      */
 /*          FCN_LV                                                         */
 /*          FIXING                                                         */
 /*          I                                                              */
 /*          IC_FOUND                                                       */
 /*          INDENT_LEVEL                                                   */
 /*          INIT_EMISSION                                                  */
 /*          NAME_IMPLIED                                                   */
 /*          NAME_PSEUDOS                                                   */
 /*          NAMING                                                         */
 /*          PARMS_WATCH                                                    */
 /*          PTR_TOP                                                        */
 /*          QUALIFICATION                                                  */
 /*          RECOVERING                                                     */
 /*          REF_ID_LOC                                                     */
 /*          REFER_LOC                                                      */
 /*          SP                                                             */
 /*          STATE                                                          */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYM_TAB                                                        */
 /*          TEMPORARY_IMPLIED                                              */
 /*          TOKEN                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CALL_SCAN                                                      */
 /*          CHECK_ARRAYNESS                                                */
 /*          CHECK_TOKEN                                                    */
 /*          EMIT_SMRK                                                      */
 /*          OUTPUT_WRITER                                                  */
 /*          SAVE_TOKEN                                                     */
 /*          STACK_DUMP                                                     */
 /* CALLED BY:                                                              */
 /*          COMPILATION_LOOP                                               */
 /***************************************************************************/
'''


def RECOVER():
    # The local variable (DECLARING) doesn't need persistence.
    
    ''' THIS ERROR RECOVERY SEARCHES FORWARD IN THE TEXT FOR A SEMICOLON OR
    END_OF_FILE, AS BEFORE.  THEN IT WIPES THE STATE STACK BACKWARD SEARCHING
    FOR A STATE THAT CAN READ THE NEW TOKEN.  THE STATE IN WHICH THE PARSE
    SHOULD BE RESUMED IS RETURNED     '''
    DECLARING = g.FALSE;
    g.RECOVERING = g.TRUE;
    goto_TOKEN_LOOP_START = False
    if g.TOKEN != g.SEMI_COLON and g.TOKEN != g.EOFILE:
        goto_TOKEN_LOOP_START = True;
    while goto_TOKEN_LOOP_START or (g.TOKEN != g.SEMI_COLON and g.TOKEN != g.EOFILE):
        if not goto_TOKEN_LOOP_START:
            if g.TOKEN != 0:
                SAVE_TOKEN(g.TOKEN, g.BCD, g.IMPLIED_TYPE);
            else:
                SAVE_TOKEN(g.ID_TOKEN, g.BCD, g.IMPLIED_TYPE);
        goto_TOKEN_LOOP_START = False;
        g.TOKEN = 0;
        CALL_SCAN();  # TO FIND SOMETHING SOLID IN THE TEXT
    g.CONTEXT = 0
    g.TEMPORARY_IMPLIED = 0;
    g.NAME_IMPLIED = g.FALSE
    g.DELAY_CONTEXT_CHECK = g.FALSE;
    g.ASSIGN_ARG_LIST = g.FALSE;
    g.NAME_PSEUDOS = g.FALSE;
    g.NAMING = 0
    g.FIXING = 0
    g.REFER_LOC = 0;
    g.PARMS_WATCH = g.FALSE;
    g.QUALIFICATION = 0;
    g.RECOVERING = g.FALSE
    g.DO_INIT = g.FALSE;
    g.BI_FUNC_FLAG = g.FALSE
    g.INIT_EMISSION = g.FALSE;
    if (g.IC_FOUND & 1) != 0:  #  RESET PTR_TOP IF POSSIBLE
        g.PTR_TOP = g.IC_PTR1 - 1;  #  IF SYNTAX ERROR DURING FACTORED INIT
    elif (g.IC_FOUND & 2) != 0:  #  NORMAL INITIALAZATION
        g.PTR_TOP = g.IC_PTR2 - 1;
    g.IC_FOUND = 0;  #  RESET TO SHOW NO INITIALIZATION IN PROGRESS
    if g.SUBSCRIPT_LEVEL > 0:
        g.SUBSCRIPT_LEVEL = 0;
    g.FCN_LV = 0;
    if g.REF_ID_LOC > 0:
        g.SYT_FLAGS(g.REF_ID_LOC, g.SYT_FLAGS(g.REF_ID_LOC) | g.EVIL_FLAG);
        g.REF_ID_LOC = 0;
    CHECK_ARRAYNESS();
    while g.SP > 0:
        g.STATE = CHECK_TOKEN(g.STATE_STACK[g.SP], g.LOOK_STACK[g.SP], g.TOKEN);
        if g.STATE > 0 and g.STATE_NAME[g.STATE_STACK[g.SP]] != g.SUB_START_TOKEN:
            g.SP = g.SP - 1;
            STACK_DUMP();
            if g.TOKEN != g.EOFILE:
                if g.SAVE_INDENT_LEVEL != 0:
                    g.INDENT_LEVEL = g.SAVE_INDENT_LEVEL;
                if not DECLARING:
                    return;
                SAVE_TOKEN(g.TOKEN, g.BCD, g.IMPLIED_TYPE);
                OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);
                CALL_SCAN();
                EMIT_SMRK();
                g.FACTORING = g.TRUE;
                g.FACTOR_FOUND = g.FALSE;
                # For the following lines, refer to the comments associated
                # with TYPE in the file g.py:
                g.FACTORED_TYPE = 0
                g.FACTORED_BIT_LENGTH = 0
                g.FACTORED_CHAR_LENGTH = 0
                g.FACTORED_MAT_LENGTH = 0
                g.FACTORED_VEC_LENGTH = 0
                g.FACTORED_ATTRIBUTES = 0
                g.FACTORED_ATTRIBUTES2 = 0
                g.FACTORED_ATTR_MASK = 0
                g.FACTORED_STRUC_PTR = 0
                g.FACTORED_STRUC_DIM = 0
                g.FACTORED_CLASS = 0
                g.FACTORED_NONHAL = 0
                g.FACTORED_LOCKp = 0
                g.FACTORED_IC_PTR = 0
                g.FACTORED_IC_FND = 0
                g.FACTORED_N_DIM = 0
                g.FACTORED_S_ARRAY = [0] * (g.N_DIM_LIM + 1)
            else:
                break  # GO TO BAD_BAD;
            return;
        g.I = g.STATE_NAME[g.STATE_STACK[g.SP]];
        if (g.I == g.DECLARE_TOKEN) or (g.I == g.REPLACE_TOKEN):
            DECLARING = g.TRUE;
        elif g.I == g.STRUCTURE_WORD:
            DECLARING = g.TRUE;
        g.SP = g.SP - 1;
    # BAD_BAD:
    OUTPUT_WRITER(g.LAST_WRITE, g.STMT_PTR);
    g.DOUBLE_SPACE();
    OUTPUT(0, '***** ERROR RECOVERY UNSUCCESSFUL.');
    g.COMPILING = g.FALSE;
    return;
