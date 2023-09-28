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


def ASSOCIATE(TAG = -1):
    # Locals: I, J, K, L
    
    IF FIXV(MP)=0 THEN I=FIXL(MP);
    ELSE I=FIXV(MP);
    IF (SYT_FLAGS(I) & READ_ACCESS_FLAG) ^= 0 THEN
       CALL ERROR(CLASS_PS, 9, VAR(MP));
    IF (SYT_FLAGS(I) & LOCK_FLAG) ^= 0 THEN  /* LOCKED */
       IF ^ASSIGN_ARG_LIST THEN
       IF UPDATE_BLOCK_LEVEL <= 0 THEN
       CALL ERROR(CLASS_UI, 1, VAR(MP));
    J=PSEUDO_TYPE(PTR(MP));
    L = EXT_P(PTR(MP));  /* RHS OF TOKEN LIST */
    IF J>TEMPL_NAME THEN GO TO ARR_STRUC_CHECK;
    IF L >= 0 THEN DO;
       I = TOKEN_FLAGS(L);
       K = I & "1F";  /* IMPLIED TYPE */
       IF K = 7 THEN GO TO ARR_STRUC_CHECK;
       IF K >= 3 THEN
          IF K <= 4 THEN
          IF (J & "1F") ^= K THEN
          CALL ERROR(CLASS_SV, 2, VAR(MP));
       I = (I - K) | (J & "1F");  /* FINAL TYPE */
       TOKEN_FLAGS(L) = I;  /* MARK GOES ON RIGTHMOST TOKEN */
    END;
    ARR_STRUC_CHECK:
    K = STACK_PTR(MP);
    J=VAL_P(PTR(MP));
    IF DELAY_CONTEXT_CHECK THEN IF SUBSCRIPT_LEVEL = 0 THEN DO;
       CALL SAVE_ARRAYNESS;
       IF (J&"206")="202" THEN DO;
          AS_PTR=AS_PTR-1;
          EXT_P(PTR(MP))=ARRAYNESS_STACK(AS_PTR);
          IF TAG>=0 THEN CALL HALMAT_FIX_POPTAG(TAG,1);
          J=J&"DFFE";
          ARRAYNESS_STACK(AS_PTR)=ARRAYNESS_STACK(AS_PTR+1)-1;
       END;
       ELSE DO;
          EXT_P(PTR(MP))=0;
          J=J&"FFFC";
       END;
    END;
    IF J THEN DO;             /*  ARRAY MARKS NEEDED  */
       GRAMMAR_FLAGS(K) = GRAMMAR_FLAGS(K) | LEFT_BRACKET_FLAG;
       GRAMMAR_FLAGS(L) = GRAMMAR_FLAGS(L) | RIGHT_BRACKET_FLAG;
    END;
    IF SHR(J,1) THEN DO;     /*  STRUCTURE MARKS NEEDED  */
       GRAMMAR_FLAGS(K) = GRAMMAR_FLAGS(K) | LEFT_BRACE_FLAG;
       GRAMMAR_FLAGS(L) = GRAMMAR_FLAGS(L) | RIGHT_BRACE_FLAG;
    END;
    TAG=-1;
    IF SHR(J,13) THEN VAL_P(PTR(MP))=J|"10";
