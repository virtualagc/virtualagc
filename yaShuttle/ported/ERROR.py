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

from g import SDL_OPTION, SRN_PRESENT, LAST, SAVE_ERROR_LIM, TOO_MANY_ERRORS, \
                TRUE, SUBSTR, SHL, BYTE, X1, SAVE_ERROR_MESSAGE, PAD, TOKEN, \
                LEVEL, STMT_NUM, STMT_PTR, ERROR_PTR, MONITOR, INPUT, \
                monitorLabel
from HALINCL.CERRDECL import CLASS_BX, CLASS_ZS, ERROR_CLASSES
from HALINCL.COMMON import advise, ADVISE

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
 /*          STMT_PTR                                                       */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMPILING                                                      */
 /*          C                                                              */
 /*          ERROR_PTR                                                      */
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
    global LAST, SAVE_ERROR_MESSAGE, ERROR_PTR, CLASSNUM, S, C, \
            SEVERITY, MAX_SEVERITY, COMPILING, monitorLabel, ADVISE, \
            TOO_MANY_ERRORS
    ERRORFILE = 5;

    if CLASS <= CLASS_ZS:
        LAST = LAST + 1;
        if LAST > SAVE_ERROR_LIM:
            # BUFFER FULL
            TOO_MANY_ERRORS = TRUE;
            LAST = LAST - 1;
        else:
            C = SUBSTR(ERROR_CLASSES, SHL(CLASS - 1, 1), 2);
            if BYTE(C, 1) == BYTE(X1):
                C = SUBSTR(C, 0, 1);
            SAVE_ERROR_MESSAGE[LAST] = PAD(C + str(NUM), 8) + TEXT;
            # IF THE ERROR IS GENERATED IN A STRUCTURE TEMPLATE
            # AND THE TOKEN IS EQUAL TO THE LEVEL NUMBER THEN
            # ATTACH THE ERROR TO THE PREVIOUS TOKEN SO THE
            # ERROR WILL BE PRINTED WITH THE CORRECT LINE.
            if TOKEN == LEVEL:
                ERROR_PTR[STMT_PTR-1] = LAST;
            else:
                ERROR_PTR[STMT_PTR] = LAST; # ATTACH ERROR TO TOKEN
            # REMOVE "SEVERE" PARAMETER (HANDLE SEVERITY 3&4 
            # ABORT IN OUTPUT_WRITER
            # GET ERROR SEVERITY FROM ERRORLIB FILE AND
            # ABORT IMMEDIATELY FOR SEVERITY 3&4 ERRORS
            goto_AGAIN = True
            while goto_AGAIN:
                goto_AGAIN = False
                C=PAD(C+str(NUM),8);
                if MONITOR(2,5,C):
                    CLASS=CLASS_BX;
                    NUM=113;
                    TEXT = C;
                    C=SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2);
                    if BYTE(C,1)==BYTE(X1):
                        C=SUBSTR(C,0,1);
                    goto_AGAIN = True
                    continue
            S = INPUT(ERRORFILE);
            SEVERITY = BYTE(S) - BYTE('0');
            if SEVERITY > 2:
                MAX_SEVERITY = SEVERITY;
                COMPILING = FALSE;
                monitorLabel = "SCAN_DISASTER";
                return
        TEXT = '';
    else:
        '''
        NEXT_ELEMENT(ADVISE);
        ADV_STMTp(RECORD_USED(ADVISE)-1, STMT_NUM);
        ADV_ERRORp(RECORD_USED(ADVISE)-1, \
                       SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2)+str(NUM));
        '''
        ADVISE.append(advise())
        ADVISE[-1].ADV_STMTp = STMT_NUM
        ADVISE[-1].ADV_ERRORp = SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2)+str(NUM)
        
