#!/usr/bin/env python3
'''
License:    The author, Ron Burkey, declares this program to be in the Public
            Domain, and may be used or modified in any way desired.
Filename:   ERROR.py
Purpose:    This is part of the port of the original XPL source code for 
            HAL/S-FC into Python. 
Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
History:    2023-08-31 RSB  Ported from XPL
'''

from xplBuiltins import *
import g
import HALINCL.COMMON as h
import HALINCL.CERRDECL as d
from SCAN_DISASTER import SCAN_DISASTER
from PAD import PAD

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  ERROR                                                  */
 /* MEMBER NAME:     ERROR                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          CLASS             BIT(16)                                      */
 /*          NUM               BIT(8)                                       */
 /*          TEXT              CHARACTER;                                   */
 /*          SEVERE            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          SET_DEFAULTS      LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ALMOST_DISASTER                                                */
 /*          COMM                                                           */
 /*          ERROR_CLASSES                                                  */
 /*          FALSE                                                          */
 /*          SAVE_ERROR_LIM                                                 */
 /*          STMT_NUM                                                       */
 /*          g.STMT_PTR                                                       */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMPILING                                                      */
 /*          C                                                              */
 /*          g.ERROR_PTR                                                      */
 /*          LAST                                                           */
 /*          SAVE_ERROR_MESSAGE                                             */
 /*          TOO_MANY_ERRORS                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          PAD                                                            */
 /* CALLED BY:                                                              */
 /*          ADD_AND_SUBTRACT                                               */
 /*          ARITH_SHAPER_SUB                                               */
 /*          ARITH_TO_CHAR                                                  */
 /*          ASSOCIATE                                                      */
 /*          AST_STACKER                                                    */
 /*          ATTACH_SUB_ARRAY                                               */
 /*          ATTACH_SUB_COMPONENT                                           */
 /*          ATTACH_SUB_STRUCTURE                                           */
 /*          ATTACH_SUBSCRIPT                                               */
 /*          CHECK_ASSIGN_CONTEXT                                           */
 /*          CHECK_CONFLICTS                                                */
 /*          CHECK_CONSISTENCY                                              */
 /*          CHECK_EVENT_CONFLICTS                                          */
 /*          CHECK_IMPLICIT_T                                               */
 /*          CHECK_NAMING                                                   */
 /*          CHECK_SUBSCRIPT                                                */
 /*          COMPARE                                                        */
 /*          COMPILATION_LOOP                                               */
 /*          EMIT_EXTERNAL                                                  */
 /*          EMIT_PUSH_DO                                                   */
 /*          END_ANY_FCN                                                    */
 /*          END_SUBBIT_FCN                                                 */
 /*          ERROR_SUB                                                      */
 /*          HALMAT                                                         */
 /*          HALMAT_INIT_CONST                                              */
 /*          ICQ_CHECK_TYPE                                                 */
 /*          IDENTIFY                                                       */
 /*          INITIALIZATION                                                 */
 /*          INTERPRET_ACCESS_FILE                                          */
 /*          IORS                                                           */
 /*          MATCH_ARITH                                                    */
 /*          MATCH_ARRAYNESS                                                */
 /*          MULTIPLY_SYNTHESIZE                                            */
 /*          NAME_COMPARE                                                   */
 /*          ORDER_OK                                                       */
 /*          PREC_SCALE                                                     */
 /*          PROCESS_CHECK                                                  */
 /*          PUSH_FCN_STACK                                                 */
 /*          PUSH_INDIRECT                                                  */
 /*          REDUCE_SUBSCRIPT                                               */
 /*          SAVE_ARRAYNESS                                                 */
 /*          SCAN                                                           */
 /*          SET_LABEL_TYPE                                                 */
 /*          SET_SYT_ENTRIES                                                */
 /*          SET_T_LIMIT                                                    */
 /*          SETUP_CALL_ARG                                                 */
 /*          SETUP_NO_ARG_FCN                                               */
 /*          STAB_LAB                                                       */
 /*          STAB_VAR                                                       */
 /*          START_NORMAL_FCN                                               */
 /*          STREAM                                                         */
 /*          STRUCTURE_COMPARE                                              */
 /*          SYNTHESIZE                                                     */
 /*          TIE_XREF                                                       */
 /*          UNBRANCHABLE                                                   */
 /*          UPDATE_BLOCK_CHECK                                             */
 /*          VECTOR_COMPARE                                                 */
 /***************************************************************************/
'''

def ERROR(CLASS, NUM, TEXT=""):
    # ERRORFILE and SEVERITY are locals, but don't need persistence.
    ERRORFILE = 5;

    if CLASS <= d.CLASS_ZS:
        g.LAST = g.LAST + 1;
        if g.LAST > g.SAVE_ERROR_LIM:
            # BUFFER FULL
            g.TOO_MANY_ERRORS = g.TRUE;
            g.LAST = g.LAST - 1;
        else:
            g.C[0] = SUBSTR(d.ERROR_CLASSES, SHL(CLASS - 1, 1), 2);
            if BYTE(g.C[0], 1) == BYTE(g.X1):
                g.C[0] = SUBSTR(g.C[0], 0, 1);
            g.SAVE_ERROR_MESSAGE[g.LAST] = PAD(g.C[0] + str(NUM), 8) + TEXT;
            # IF THE ERROR IS GENERATED IN A STRUCTURE TEMPLATE
            # AND THE TOKEN IS EQUAL TO THE LEVEL NUMBER THEN
            # ATTACH THE ERROR TO THE PREVIOUS TOKEN SO THE
            # ERROR WILL BE PRINTED WITH THE CORRECT LINE.
            if g.TOKEN == g.LEVEL:
                g.ERROR_PTR[g.STMT_PTR-1] = g.LAST;
            else:
                g.ERROR_PTR[g.STMT_PTR] = g.LAST; # ATTACH ERROR TO TOKEN
            # REMOVE "SEVERE" PARAMETER (HANDLE SEVERITY 3&4 
            # ABORT IN OUTPUT_WRITER
            # GET ERROR SEVERITY FROM ERRORLIB FILE AND
            # ABORT IMMEDIATELY FOR SEVERITY 3&4 ERRORS
            goto_AGAIN = True
            while goto_AGAIN:
                goto_AGAIN = False
                g.C[0]=PAD(g.C[0]+str(NUM),8);
                if MONITOR(2,5,g.C[0]):
                    CLASS=d.CLASS_BX;
                    NUM=113;
                    TEXT = g.C[0];
                    g.C[0]=SUBSTR(d.ERROR_CLASSES,SHL(CLASS-1,1),2);
                    if BYTE(g.C[0],1)==BYTE(g.X1):
                        g.C[0]=SUBSTR(g.C[0],0,1);
                    goto_AGAIN = True
                    continue
            g.S = INPUT(ERRORFILE);
            SEVERITY = BYTE(g.S) - BYTE('0');
            if SEVERITY > 2:
                g.MAX_SEVERITY = SEVERITY;
                g.COMPILING = g.FALSE;
                SCAN_DISASTER()
        TEXT = '';
    else:
        '''
        NEXT_ELEMENT(h.ADVISE);
        ADV_STMTp(RECORD_USED(h.ADVISE)-1, g.STMT_NUM);
        ADV_ERRORp(RECORD_USED(h.ADVISE)-1, \
                       SUBSTR(d.ERROR_CLASSES,SHL(CLASS-1,1),2)+str(NUM));
        '''
        h.ADVISE.append(h.advise())
        h.ADVISE[-1].ADV_STMTp = g.STMT_NUM()
        h.ADVISE[-1].ADV_ERRORp = SUBSTR(d.ERROR_CLASSES,SHL(CLASS-1,1),2)+str(NUM)
        
