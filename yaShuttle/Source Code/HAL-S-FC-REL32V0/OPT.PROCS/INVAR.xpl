 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INVAR.xpl
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
 /* PROCEDURE NAME:  INVAR                                                  */
 /* MEMBER NAME:     INVAR                                                  */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          NODE_WORD         FIXED                                        */
 /*          NODE2_WORD        BIT(16)                                      */
 /*          AR_INV            BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          RET               BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DUMMY_NODE                                                     */
 /*          I_TRACE                                                        */
 /*          LEVEL_STACK_VARS                                               */
 /*          LEV                                                            */
 /*          NODE                                                           */
 /*          NODE_BEGINNING                                                 */
 /*          PULL_LOOP_HEAD                                                 */
 /*          STACK_TRACE                                                    */
 /*          TRUE                                                           */
 /*          TSUB                                                           */
 /*          XPULL_LOOP_HEAD                                                */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ARRAYED_ELT                                                    */
 /*          CSE_WORD_FORMAT                                                */
 /*          TYPE                                                           */
 /*          ZAP_BIT                                                        */
 /* CALLED BY:                                                              */
 /*          CHECK_INVAR                                                    */
 /*          GET_NODE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INVAR <==                                                           */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /*     ==> TYPE                                                            */
 /*     ==> ARRAYED_ELT                                                     */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*         ==> TYPE                                                        */
 /*     ==> ZAP_BIT                                                         */
 /***************************************************************************/
                                                                                01891920
                                                                                01891930
 /* TRUE IF INVARIANT RELATIVE TO LOOP_ZAPS ARRAY*/                             01891940
INVAR:                                                                          01891950
   PROCEDURE(NODE_WORD,NODE2_WORD,AR_INV) BIT(8);                               01891960
      DECLARE (RET,AR_INV) BIT(8);                                              01891970
      DECLARE NODE_WORD FIXED,                                                  01891980
         NODE2_WORD BIT(16);                                                    01891990
      IF (NODE_WORD & "F 0000") = DUMMY_NODE THEN RET = 0;                      01891992
      ELSE                                                                      01891994
         IF AR_INV THEN DO;                                                     01892000
         IF NODE(NODE_BEGINNING) = TSUB THEN   /* UNARRAYED TSUB */             01892010
            RET = 1;                                                            01892020
         ELSE IF NODE_WORD = 0 THEN RET = 0;                                    01892030
         ELSE RET = ARRAYED_ELT(NODE_WORD,NODE2_WORD) = 0;                      01892040
      END;                                                                      01892050
      ELSE DO;                                                                  01892060
         RET = 0;                                                               01892070
         DO CASE TYPE(NODE_WORD);                                               01892080
            ;                                                                   01892090
            ;   /* NO SYT'S GET HERE*/                                          01892100
            ;                                                                   01892110
            DO;   /* 3 = TERM VAC*/                                             01892120
               RET = (NODE(NODE_WORD & "FFFF") & "FFFF") < PULL_LOOP_HEAD(LEV); 01892130
            END;                                                                01892140
            ;                                                                   01892150
            ;                                                                   01892160
            RET = TRUE;   /* 6 = IMD*/                                          01892170
            ;;;;                                                                01892180
               DO;    /* B = VALUE NO*/                                         01892190
               RET = ^ZAP_BIT(NODE2_WORD) & "1";                                01892200
            END;                                                                01892210
            DO;     /* C = OUTER TERMINAL VAC*/                                 01892220
               RET = (NODE(NODE_WORD & "FFFF") & "FFFF") < PULL_LOOP_HEAD(LEV); 01892230
            END;                                                                01892240
            ;   /* D = DUMMY*/                                                  01892250
            RET = TRUE;    /* E = LITERAL*/                                     01892260
            ;                                                                   01892270
         END;                                                                   01892280
      END;                                                                      01892290
                                                                                01892300
      IF I_TRACE THEN OUTPUT =                                                  01892310
         'INVAR(' || CSE_WORD_FORMAT(NODE_WORD) || ',' || NODE2_WORD|| ',' ||   01892320
         AR_INV || '):  '                                                       01892330
         || RET;                                                                01892340
      AR_INV = 0;                                                               01892350
      RETURN RET;                                                               01892360
   END INVAR;                                                                   01892370
