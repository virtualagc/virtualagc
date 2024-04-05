 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ERROR.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

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
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> ERROR <==                                                           */
 /*     ==> PAD                                                             */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 03/03/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /* 03/03/95 BAF  27V0  DR108629 STATEMENT NUMBER IN ERROR MESSAGE...       */
 /*               11V0   REMOVED PROCESSING OF VARIABLE PREVIOUS_ERROR      */
 /*                                                                         */
 /*                                                                         */
 /* 07/13/95 DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING          */
 /*               11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)     */
 /*                                                                         */
 /* 01/25/96 DAS  27V1  DR109036 BAD SEVERITY 3 ERROR HANDLING IN PASS1     */
 /*               11V1                                                      */
 /*                                                                         */
 /* 01/30/00 DCP  30V0  CR13211  GENERATE ADVISORY MESSAGE WHEN BIT STRING  */
 /*               15V0           ASSIGNED TO SHORTER STRING                 */
 /*                                                                         */
 /* 04/26/01 DCP  31V0  CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS IN      */
 /*               16V0           HAL/S COMPILER                             */
 /*                                                                         */
 /* 02/06/01 DCP  31V0  DR111369 ERROR ATTACHED TO WRONG STRUCTURE NODE     */
 /*               16V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00281700
ERROR:                                                                          00281800
   PROCEDURE(CLASS, NUM, TEXT);                                                 00281900
    DECLARE CLASS BIT(16), NUM BIT(8), TEXT CHARACTER;                          00282000
    DECLARE SEVERITY BIT(16);        /* DR109036 */                             00282000
    DECLARE ERRORFILE LITERALLY '5'; /* DR109036 */                             00030000

    IF CLASS <= CLASS_ZS THEN DO;    /* CR13211 */
      LAST = LAST + 1;                                                          00282100
      IF LAST > SAVE_ERROR_LIM THEN                                             00282200
         DO;  /* BUFFER FULL */                                                 00282300
         TOO_MANY_ERRORS = TRUE;                                                00282400
         LAST = LAST - 1;                                                       00282500
         GO TO SET_DEFAULTS;                                                    00282600
      END;                                                                      00282700
      C = SUBSTR(ERROR_CLASSES, SHL(CLASS - 1, 1), 2);                          00282800
      IF BYTE(C, 1) = BYTE(X1) THEN                                 /*CR13335*/ 00282900
         C = SUBSTR(C, 0, 1);                                                   00283000
      SAVE_ERROR_MESSAGE(LAST) = PAD(C || NUM, 8) || TEXT;                      00283100
     /* IF THE ERROR IS GENERATED IN A STRUCTURE TEMPLATE /*DR111369*/
     /* AND THE TOKEN IS EQUAL TO THE LEVEL NUMBER THEN   /*DR111369*/
     /* ATTACH THE ERROR TO THE PREVIOUS TOKEN SO THE     /*DR111369*/
     /* ERROR WILL BE PRINTED WITH THE CORRECT LINE.      /*DR111369*/
      IF TOKEN = LEVEL THEN                               /*DR111369*/
         ERROR_PTR(STMT_PTR-1) = LAST;                    /*DR111369*/
      ELSE                                                /*DR111369*/
         ERROR_PTR(STMT_PTR) = LAST; /* ATTACH ERROR TO TOKEN */                00283110
      /* CR12416 -- REMOVE "SEVERE" PARAMETER (HANDLE SEVERITY 3&4 */           00283700
      /* ABORT IN OUTPUT_WRITER */                                              00283700
      /* DR109036 - GET ERROR SEVERITY FROM ERRORLIB FILE AND */                00283700
      /* ABORT IMMEDIATELY FOR SEVERITY 3&4 ERRORS */                           00283700
      AGAIN:C=PAD(C||NUM,8);                                                    00130000
      IF MONITOR(2,5,C) THEN DO;                                                00140000
         CLASS=CLASS_BX;                                                        00150000
         NUM=113;                                                               00160000
         TEXT = C;                                                              00170000
         C=SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2);                              00110000
         IF BYTE(C,1)=BYTE(X1) THEN C=SUBSTR(C,0,1);                /*CR13335*/ 00120000
         GO TO AGAIN;                                                           00180000
      END;                                                                      00190000
      S = INPUT(ERRORFILE);                                                     00200000
      SEVERITY = BYTE(S) - BYTE('0');                                           00210000
      IF SEVERITY > 2 THEN DO;                                                  00261624
         MAX_SEVERITY = SEVERITY;                                               00261625
         COMPILING = FALSE;                                                     00261625
         GO TO SCAN_DISASTER;                                                   00261626
      END;                                                                      00261627
      /* END DR109036 */                                                        00261627
SET_DEFAULTS:                                                                   00283800
      TEXT = '';                                                                00284000
    END;                                                            /*CR13211*/
    ELSE DO;                                                        /*CR13211*/
      NEXT_ELEMENT(ADVISE);                                         /*CR13211*/
      ADV_STMT#(RECORD_USED(ADVISE)-1) = STMT_NUM;                  /*CR13211*/
      ADV_ERROR#(RECORD_USED(ADVISE)-1) =                           /*CR13211*/
                       SUBSTR(ERROR_CLASSES,SHL(CLASS-1,1),2)||NUM; /*CR13211*/
    END;                                                            /*CR13211*/
   END ERROR;                                                                   00284100
