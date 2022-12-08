 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKINV.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  CHECK_INVAR                                            */
 /* MEMBER NAME:     CHECKINV                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          AR_INV            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FORCE_PULL        BIT(8)                                       */
 /*          BUMP_CSE(1271)    LABEL                                        */
 /*          INX               BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DSUB                                                           */
 /*          END_OF_NODE                                                    */
 /*          EXTN                                                           */
 /*          FALSE                                                          */
 /*          I_TRACE                                                        */
 /*          LEVEL                                                          */
 /*          LEVEL_STACK_VARS                                               */
 /*          LEV                                                            */
 /*          NODE                                                           */
 /*          NODE_BEGINNING                                                 */
 /*          NODE2                                                          */
 /*          NONCOMMUTATIVE                                                 */
 /*          NOT                                                            */
 /*          OR                                                             */
 /*          STACK_TRACE                                                    */
 /*          STACKED_BLOCK#                                                 */
 /*          TRUE                                                           */
 /*          XSTACKED_BLOCK#                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          CSE2                                                           */
 /*          OLD_BLOCK#                                                     */
 /*          OLD_LEVEL                                                      */
 /*          PRESENT_HALMAT                                                 */
 /*          PRESENT_NODE_PTR                                               */
 /*          PREVIOUS_HALMAT                                                */
 /*          PREVIOUS_NODE_OPERAND                                          */
 /*          PREVIOUS_NODE_PTR                                              */
 /*          PREVIOUS_NODE                                                  */
 /*          REVERSE                                                        */
 /*          TWIN_MATCH                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ARRAYED_ELT                                                    */
 /*          GET_EON                                                        */
 /*          INVAR                                                          */
 /* CALLED BY:                                                              */
 /*          PULL_INVARS                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_INVAR <==                                                     */
 /*     ==> GET_EON                                                         */
 /*     ==> ARRAYED_ELT                                                     */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*         ==> TYPE                                                        */
 /*     ==> INVAR                                                           */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*         ==> TYPE                                                        */
 /*         ==> ARRAYED_ELT                                                 */
 /*             ==> CSE_WORD_FORMAT                                         */
 /*                 ==> HEX                                                 */
 /*             ==> TYPE                                                    */
 /*         ==> ZAP_BIT                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /* 04/06/00 JAC  30V0  DR111323 BS122 FOR NAME STRUCTURE COMPARE           */
 /*               15V0                                                      */
 /***************************************************************************/
                                                                                04137000
                                                                                04137010
                                                                                04137020
 /* MAIN ROUTINES FOR PULLING INVARIANT COMPUTATIONS FROM LOOPS*/               04137030
                                                                                04137040
                                                                                04137050
 /* CHECKS NODE FOR LOOP INVAR(RELATIVE TO LEVEL 'LEV') COMPUTATION.  PUTS      04137060
      SUCH INVARS IN CSE INDEXED BY CSE_FOUND_INX.  PUTS END_OF_NODE AT END.    04137070
      CSE_FOUND_INX POINTS TO END_OF_NODE.                                      04137080
      SETS LOOPY_OPS TRUE IF                                                    04137090
      INVAR PART IS LOOPY_OP.  IN THIS CASE SETS LOOP_DIMENSION.*/              04137100
                                                                                04137110
 /* MUST BE CALLED WITH ALL OPERANDS*/                                          04137120
                                                                                04137130
CHECK_INVAR:                                                                    04137140
   PROCEDURE(AR_INV) BIT(8);                                                    04137150
      DECLARE AR_INV BIT(8);                                                    04137160
      DECLARE (INX,TEMP) BIT(16);                                               04137170
      DECLARE FORCE_PULL BIT(8);                                                04137171
                                                                                04137180
                                                                                04137190
BUMP_CSE:                                                                       04137200
      PROCEDURE;                                                                04137210
         CSE_FOUND_INX = CSE_FOUND_INX + 1;                                     04137220
         CSE(CSE_FOUND_INX) = NODE(INX);                                        04137230
         CSE2(CSE_FOUND_INX) = NODE2(INX);                                      04137240
      END BUMP_CSE;                                                             04137250
                                                                                04137260
                                                                                04137270
      IF I_TRACE THEN OUTPUT =                                                  04137280
         'CHECK_INVAR(' || AR_INV || '):  ' || NODE_BEGINNING;                  04137290
      CSE_FOUND_INX = 0;                                                        04137300
      INX = NODE_BEGINNING - 1;                                                 04137310
      FORCE_PULL = FALSE;                                                       04137311
      IF AR_INV THEN IF (NODE(NODE_BEGINNING) & "FFFF") = EXTN                  04137312
         THEN DO;                                                               04137313
         TEMP = GET_EON(INX) + 1;                                               04137314
 /* FIRST EXTN OPERAND */                                                       04137315
         FORCE_PULL = ARRAYED_ELT(NODE(TEMP),NODE2(TEMP)) = 0; /*DR111323*/     04137316
      END;                                                                      04137317
      ELSE IF NODE(NODE_BEGINNING) = DSUB   /* UNARRAYED DSUB*/                 04137318
         THEN FORCE_PULL = TRUE;                                                04137319
      DO WHILE NODE(INX) ^= END_OF_NODE;                                        04137320
         IF FORCE_PULL THEN CALL BUMP_CSE; ELSE                                 04137321
                                                                                04137322
            IF INVAR(NODE(INX),NODE2(INX),AR_INV) THEN DO;                      04137340
            CALL BUMP_CSE;                                                      04137350
         END;                                                                   04137360
         INX = INX - 1;                                                         04137370
      END;                                                                      04137380
                                                                                04137390
      IF CSE_FOUND_INX >= 2 & ^NONCOMMUTATIVE OR NONCOMMUTATIVE &               04137400
         CSE_FOUND_INX = NODE_BEGINNING - INX - 1 THEN DO;                      04137403
         CALL BUMP_CSE;    /* GET END OF NODE*/                                 04137410
         TWIN_MATCH,REVERSE = FALSE;                                            04137420
         PREVIOUS_NODE_PTR,PRESENT_NODE_PTR = INX - 1;                          04137430
         PREVIOUS_HALMAT,PRESENT_HALMAT =                                       04137440
            NODE(PRESENT_NODE_PTR) & "FFFF";                                    04137450
         PREVIOUS_NODE_OPERAND = NODE_BEGINNING - 1;                            04137460
         PREVIOUS_NODE = NODE_BEGINNING;                                        04137470
         IF AR_INV THEN OLD_LEVEL = LEVEL;                                      04137480
         ELSE OLD_LEVEL = LEV-1;                                                04137483
         OLD_BLOCK# =STACKED_BLOCK#(OLD_LEVEL);                                 04137490
                                                                                04137500
         IF I_TRACE THEN DO;                                                    04137510
            OUTPUT =                                                            04137520
               '   PREVIOUS_NODE_PTR=' || PREVIOUS_NODE_PTR                     04137530
               || ', PREVIOUS_NODE=' || PREVIOUS_NODE ;                         04137540
            OUTPUT = '   OLD_LEVEL='||OLD_LEVEL||', OLD_BLOCK#=' || OLD_BLOCK#; 04137550
         END;                                                                   04137560
         RETURN TRUE;                                                           04137570
      END;                                                                      04137580
      RETURN FALSE;                                                             04137590
   END CHECK_INVAR;                                                             04137600
