 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETMASKI.xpl
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
/* PROCEDURE NAME:  SET_MASKING_BIT                                        */
/* MEMBER NAME:     SETMASKI                                               */
/* INPUT PARAMETERS:                                                       */
/*          STMT_NO           BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          CUR_STMT#         BIT(16)                                      */
/*          FIRST_CALL        BIT(8)                                       */
/*          GO_FLAG           BIT(8)                                       */
/*          NEXT              LABEL                                        */
/*          NODE_F            FIXED                                        */
/*          STMT_DATA_PTR     FIXED                                        */
/*          STMT#             BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLASS_BI                                                       */
/*          COMM                                                           */
/*          FALSE                                                          */
/*          MODF                                                           */
/*          OPTION_BITS                                                    */
/*          RELS                                                           */
/*          STMT_DATA_HEAD                                                 */
/*          TRUE                                                           */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          LOCATE                                                         */
/*          ERRORS                                                         */
/*          PTR_LOCATE                                                     */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          INITIALISE                                                     */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> SET_MASKING_BIT <==                                                 */
/*     ==> PTR_LOCATE                                                      */
/*     ==> LOCATE                                                          */
/*     ==> ERRORS                                                          */
/*         ==> NEXTCODE                                                    */
/*             ==> DECODEPOP                                               */
/*                 ==> FORMAT                                              */
/*                 ==> HEX                                                 */
/*                 ==> POPCODE                                             */
/*                 ==> POPNUM                                              */
/*                 ==> POPTAG                                              */
/*             ==> AUX_SYNC                                                */
/*                 ==> GET_AUX                                             */
/*                 ==> AUX_LINE                                            */
/*                     ==> GET_AUX                                         */
/*                 ==> AUX_OP                                              */
/*                     ==> GET_AUX                                         */
/*         ==> RELEASETEMP                                                 */
/*             ==> SETUP_STACK                                             */
/*             ==> CLEAR_REGS                                              */
/*                 ==> SET_LINKREG                                         */
/*         ==> COMMON_ERRORS                                               */
/***************************************************************************/
/*  REVISION HISTORY :                                                     */
/*  ------------------                                                     */
/*  DATE    NAME  REL   DR NUMBER AND TITLE                                */
/*                                                                         */
/* 1/18/94  LJK   26V0  109002 INTERFACE PROBLEM BETWEEN PHASE 2 AND       */
/*                10V0  VIRTUAL MEMORY                                     */
/***************************************************************************/
                                                                                00894500
SET_MASKING_BIT:PROCEDURE(STMT_NO);                                             00894510
      DECLARE (STMT_NO, STMT#, CUR_STMT#) BIT(16),                              00894520
         STMT_DATA_PTR FIXED,                                                   00894530
         FIRST_CALL BIT(1) INITIAL(1),                                          00894540
         GO_FLAG BIT(1);                                                        00894550
      BASED NODE_F FIXED;                                                       00894560
NEXT: PROCEDURE;                                                                00894570
         CUR_STMT# = 0;                                                         00894580
         IF STMT_DATA_PTR ^= -1 THEN DO;                                        00894590
            CALL LOCATE(STMT_DATA_PTR, ADDR(NODE_F), 0);                        00894600
            CUR_STMT# = (SHR(NODE_F(7),16) & "FFFF");                           00894610
         END;                                                                   00894620
      END NEXT;                                                                 00894630
                                                                                00894640
      STMT# = STMT_NO & "7FFF";                                                 00894650
      IF STMT# = 0 THEN DO;                                                     00894660
         IF FIRST_CALL THEN DO;                                                 00894670
            FIRST_CALL = FALSE;                                                 00894680
            IF ((OPTION_BITS & "800") ^= 0)                                     00894690
               THEN DO;                                                         00894700
               GO_FLAG = TRUE;                                                  00894710
               STMT_DATA_PTR = STMT_DATA_HEAD;                                  00894720
            END;                                                                00894730
         END;                                                                   00894740
         ELSE DO;                                                               00894750
            GO_FLAG = FALSE;                                                    00894760
         END;                                                                   00894770
      END;                                                                      00894780
      ELSE IF GO_FLAG THEN DO;                                                  00894790
         DO WHILE CUR_STMT# < STMT#;                                            00894800
            CALL NEXT;                                                          00894810
      /*****  DR109002   LJK  1/18/94  **********************/
      /* SET THE SDF POINTER TO POINT TO THE NEXT STATEMENT */
      /* ONLY WHEN THE DESIRED STATEMENT IS NOT FOUND       */
            IF CUR_STMT# ^= STMT# THEN
      /*****  END DR109002          *************************/
               STMT_DATA_PTR = NODE_F(0);                                       00894820
         END;                                                                   00894830
         IF STMT# = CUR_STMT# THEN DO;                                          00894840
            NODE_F(6) = NODE_F(6) | "02000000";                                 00894850
            CALL PTR_LOCATE(STMT_DATA_PTR,MODF);                                00894860
            IF CUR_STMT# ^= 0 THEN                                              00894870
               STMT_DATA_PTR = NODE_F(0);                                       00894880
         END;                                                                   00894890
         ELSE DO;                                                               00894900
            CALL PTR_LOCATE(STMT_DATA_PTR,RELS);                                00894910
            CALL ERRORS(CLASS_BI,500);                                          00894920
 /* OUTPUT = 'CUR_STMT# = '|| CUR_STMT#||'STMT# = '||STMT#;  */                 00894930
         END;                                                                   00894960
      END;                                                                      00894970
   END SET_MASKING_BIT;                                                         00894980
