 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TAGCONDI.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  TAG_CONDITIONALS                                       */
 /* MEMBER NAME:     TAGCONDI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FLAGS             BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /*          LAST_TAG          BIT(16)                                      */
 /*          NODES             BIT(16)                                      */
 /*          OPTYPE            BIT(16)                                      */
 /*          SET_TAG           LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CAND                                                           */
 /*          FOR                                                            */
 /*          REGISTER_TAG                                                   */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_INX                                                          */
 /*          ADD                                                            */
 /*          D_N_INX                                                        */
 /*          DIFF_NODE                                                      */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ANDOR_TYPE                                                     */
 /*          BUMP_ADD                                                       */
 /*          BUMP_D_N                                                       */
 /*          CLASSIFY                                                       */
 /*          COMPARE_TYPE                                                   */
 /*          NO_OPERANDS                                                    */
 /*          NOT_TYPE                                                       */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TAG_CONDITIONALS <==                                                */
 /*     ==> BUMP_D_N                                                        */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> BUMP_ADD                                                        */
 /*     ==> CLASSIFY                                                        */
 /*         ==> PRINT_SENTENCE                                              */
 /*             ==> FORMAT                                                  */
 /*             ==> HEX                                                     */
 /*     ==> NOT_TYPE                                                        */
 /*     ==> ANDOR_TYPE                                                      */
 /*     ==> COMPARE_TYPE                                                    */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                02303000
 /*TAGS COMPARISONS IN CONDITIONAL STATEMENTS WHICH ALLOW PRESERVATION          02304000
      OF REGISTERS TO NEXT COMPARISON*/                                         02305000
TAG_CONDITIONALS:                                                               02306000
   PROCEDURE(PTR);                                                              02307000
      DECLARE (NODES,PTR,I,FLAGS,OPTYPE,LAST_TAG) BIT(16);                      02308000
                                                                                02309000
                                                                                02310000
SET_TAG:                                                                        02311000
      PROCEDURE(PTR);                                                           02312000
         DECLARE PTR BIT(16);                                                   02313000
         FLAGS = FLAGS + 1;                                                     02314000
         OPR(PTR) = OPR(PTR) | REGISTER_TAG;                                    02315000
         IF WATCH THEN OUTPUT = 'CONDITIONAL TAG:  '||PTR;                      02316000
         IF PTR > LAST_TAG THEN LAST_TAG = PTR;                                 02317000
      END SET_TAG;                                                              02318000
                                                                                02319000
                                                                                02320000
                                                                                02321000
      NODES,A_INX = 0;                                                          02322000
      D_N_INX = 1;                                                              02323000
      DIFF_NODE(1) = PTR;                                                       02324000
                                                                                02325000
      DO WHILE D_N_INX > 0;                                                     02326000
                                                                                02327000
         DIFF_NODE = DIFF_NODE(D_N_INX);                                        02328000
         D_N_INX = D_N_INX - 1;                                                 02329000
         IF NOT_TYPE(DIFF_NODE) THEN DO;                                        02330000
            NODES = NODES + 1;  /* PREVENT NOT PROBLEM */                       02330100
            CALL BUMP_D_N(SHR(OPR(DIFF_NODE + 1),16));                          02330200
         END;                                                                   02330300
         ELSE IF ANDOR_TYPE(DIFF_NODE) THEN DO;                                 02331000
            CALL BUMP_ADD(DIFF_NODE);                                           02332000
            FLAGS,LAST_TAG = 0;                                                 02333000
            OPTYPE = CLASSIFY(DIFF_NODE);                                       02334000
            NODES = NODES + 1;                                                  02335000
                                                                                02336000
            DO WHILE A_INX > 0;                                                 02337000
               ADD = ADD(A_INX);                                                02338000
               A_INX = A_INX -1;                                                02339000
               IF ANDOR_TYPE(ADD) THEN DO;                                      02340000
                  IF OPTYPE ^= CLASSIFY(ADD) THEN DO;                           02341000
                     CALL BUMP_D_N(ADD);                                        02342000
                     IF ADD > LAST_TAG THEN LAST_TAG = ADD;                     02343000
                  END;                                                          02344000
                  ELSE DO FOR I = ADD + 1 TO ADD + NO_OPERANDS(ADD);            02345000
                     PTR = SHR(OPR(I),16);                                      02346000
                     IF COMPARE_TYPE(PTR) THEN DO;                              02347000
                        CALL SET_TAG(PTR);                                      02348000
                     END;                                                       02349000
                     ELSE CALL BUMP_ADD(PTR);                                   02350000
                  END;                                                          02351000
               END;                                                             02352000
               ELSE IF NOT_TYPE(ADD) THEN CALL BUMP_D_N(SHR(OPR(ADD + 1),16));  02353000
               ELSE IF COMPARE_TYPE(ADD) THEN CALL SET_TAG(ADD);                02354000
                                                                                02355000
            END;   /* DO WHILE A_INX*/                                          02356000
                                                                                02357000
            IF FLAGS ^= 0 THEN IF (NODES ^= 1 | OPTYPE ^= CAND) THEN            02358000
               IF COMPARE_TYPE(LAST_TAG) THEN DO;                               02359000
                                                                                02360000
 /* IF THE TOP NODE IS CAND THEN RETAIN TAG*/                                   02361000
                                                                                02362000
               OPR(LAST_TAG) = OPR(LAST_TAG) - REGISTER_TAG;                    02363000
               IF WATCH THEN OUTPUT = 'CONDITIONAL DETAG:  '||LAST_TAG;         02364000
            END;                                                                02365000
         END;  /* ANDOR_TYPE(DIFF_NODE)*/                                       02366000
                                                                                02367000
      END;   /* D_N_INX*/                                                       02368000
                                                                                02369000
   END TAG_CONDITIONALS;                                                        02369010
