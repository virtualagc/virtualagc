 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EJECTINV.xpl
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
 /* PROCEDURE NAME:  EJECT_INVARS                                           */
 /* MEMBER NAME:     EJECTINV                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          AR_INV            BIT(8)                                       */
 /*          NOT_TSUB          BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          HIGH              BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          NEW_NODE_BEGINNING  BIT(16)                                    */
 /*          OP#               BIT(16)                                      */
 /*          PUT_ADLP          BIT(8)                                       */
 /*          TEMP              BIT(16)                                      */
 /*          TEMP2             BIT(16)                                      */
 /*          TMP               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          AR_TAG                                                         */
 /*          DLPE_WORD                                                      */
 /*          FOR                                                            */
 /*          HALMAT_NODE_START                                              */
 /*          IMD_0                                                          */
 /*          LOOP_DIMENSION                                                 */
 /*          LOOPY_OPS                                                      */
 /*          NEW_NODE_PTR                                                   */
 /*          NODE                                                           */
 /*          NODE2                                                          */
 /*          OR                                                             */
 /*          OUT_OF_ARRAY_TAG                                               */
 /*          OUTSIDE_REF_TAG                                                */
 /*          PULL_LOOP_HEAD                                                 */
 /*          STATEMENT_ARRAYNESS                                            */
 /*          TAG_BIT                                                        */
 /*          VDLE                                                           */
 /*          VDLP_TAG                                                       */
 /*          VDLP                                                           */
 /*          WATCH                                                          */
 /*          XPULL_LOOP_HEAD                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          AR_PTR                                                         */
 /*          ARRAYED_OPS                                                    */
 /*          LEVEL_STACK_VARS                                               */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BOTTOM                                                         */
 /*          GROUP_CSE                                                      */
 /*          GET_ADLP                                                       */
 /*          LAST_OPERAND                                                   */
 /*          MOVE_LIMB                                                      */
 /*          NO_OPERANDS                                                    */
 /*          PRINT_SENTENCE                                                 */
 /*          PUSH_HALMAT                                                    */
 /* CALLED BY:                                                              */
 /*          PULL_INVARS                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EJECT_INVARS <==                                                    */
 /*     ==> PRINT_SENTENCE                                                  */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> LAST_OPERAND                                                    */
 /*     ==> MOVE_LIMB                                                       */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> RELOCATE                                                    */
 /*         ==> MOVECODE                                                    */
 /*             ==> ENTER                                                   */
 /*     ==> PUSH_HALMAT                                                     */
 /*         ==> HEX                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> VAC_OR_XPT                                                  */
 /*         ==> BUMP_D_N                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> ENTER                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*     ==> GROUP_CSE                                                       */
 /*         ==> LAST_OP                                                     */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> MOVE_LIMB                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> RELOCATE                                                */
 /*             ==> MOVECODE                                                */
 /*                 ==> ENTER                                               */
 /*         ==> BUMP_ADD                                                    */
 /*         ==> TERMINAL                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> HALMAT_FLAG                                             */
 /*                 ==> VAC_OR_XPT                                          */
 /*             ==> CLASSIFY                                                */
 /*                 ==> PRINT_SENTENCE                                      */
 /*                     ==> FORMAT                                          */
 /*                     ==> HEX                                             */
 /*     ==> GET_ADLP                                                        */
 /*         ==> OPOP                                                        */
 /*         ==> LAST_OP                                                     */
 /***************************************************************************/
 /* DATE     WHO  RLS        DR/CR #  DESCRIPTION                           */
 /* 06/03/99 JAC  30V0/15V0  DR111313 BS122 ERROR FOR MULTIDIMENSIONAL      */
 /*                                   ASSIGNMENTS                           */
 /***************************************************************************/
                                                                                04137610
                                                                                04137620
 /* PULLS OUT LOOP INVARIANT HALMAT */                                          04137630
EJECT_INVARS:                                                                   04137640
   PROCEDURE (AR_INV,NOT_TSUB);                                                 04137650
      DECLARE HIGH BIT(16);                             /*DR111313*/
      DECLARE (TEMP,TEMP2,K,OP#) BIT(16);                                       04137660
      DECLARE (AR_INV,PUT_ADLP,NOT_TSUB) BIT(8);                                04137665
      DECLARE TMP FIXED;                                                        04137670
      DECLARE NEW_NODE_BEGINNING BIT(16); /* OP OF NEW NODE IN NODE LIST*/      04137680
      TMP=0;                                                                    04137685
      NEW_NODE_BEGINNING = NODE2(NEW_NODE_PTR + 1);                             04137690
      ARRAYED_OPS = (NODE(NEW_NODE_BEGINNING) & AR_TAG) ^= 0;                   04137700
      PUT_ADLP = ARRAYED_OPS OR ^AR_INV AND STATEMENT_ARRAYNESS;                04137705
      IF PUT_ADLP THEN AR_PTR = GET_ADLP(NODE(NEW_NODE_PTR) & "FFFF");          04137710
      IF AR_PTR < 0 THEN PUT_ADLP = 0;                                          04137715
      IF (PUT_ADLP OR LOOPY_OPS) AND NOT_TSUB THEN DO;                          04137720
         IF PUT_ADLP THEN TEMP,OP# = NO_OPERANDS(AR_PTR) + 2;                   04137730
         ELSE TEMP = 0;                                                         04137740
         IF LOOPY_OPS THEN TEMP = TEMP + 3;                                     04137750
         CALL PUSH_HALMAT(PULL_LOOP_HEAD(0),TEMP);                              04137760
         TEMP,TEMP2,PULL_LOOP_HEAD(0) = PULL_LOOP_HEAD(0)-PUT_ADLP-LOOPY_OPS;   04137770
         IF LOOPY_OPS THEN DO;                                                  04137780
            TMP = TAG_BIT;                                                      04137790
            TEMP = TEMP - 2;                                                    04137800
            OPR(TEMP) = VDLP;                                                   04137810
            OPR(TEMP + 1) = IMD_0 | SHL(LOOP_DIMENSION,16) | VDLP_TAG |         04137820
               OUTSIDE_REF_TAG;                                                 04137830
            OPR(TEMP2) = VDLE;                                                  04137840
            TEMP2 = TEMP2 + 1;                                                  04137850
         END;                                                                   04137860
         ELSE TMP = 0;                                                          04137870
         IF PUT_ADLP THEN DO;                                                   04137880
            TMP = TMP | OUT_OF_ARRAY_TAG;                                       04137890
            TEMP = TEMP - OP# + 1;                                              04137900
            DO FOR K = 0 TO OP# - 2;                                            04137910
               OPR(TEMP + K) = OPR(AR_PTR + K);                                 04137920
            END;                                                                04137930
            OPR(TEMP + OP# - 2) = OPR(TEMP + OP# - 2) |                         04137940
               OUTSIDE_REF_TAG;                                                 04137950
            OPR(TEMP) = OPR(TEMP) & "FFFFFF";                                   04137955
            OPR(TEMP2) = DLPE_WORD;                                             04137960
         END;                                                                   04137970
      END;                                                                      04137980
      TEMP = LAST_OPERAND(GROUP_CSE(NEW_NODE_PTR));                             04137990
      TEMP2 = NODE(NEW_NODE_PTR) & "FFFF";                                      04138000
      OPR(TEMP2) = OPR(TEMP2) | TMP;                                            04138010
      TEMP2 = PULL_LOOP_HEAD(0);                                                04138020
      HIGH = BOTTOM(HALMAT_NODE_START,PULL_LOOP_HEAD(0));   /*DR111313*/
      CALL MOVE_LIMB(PULL_LOOP_HEAD(0),HIGH,                /*DR111313*/
         TEMP - HIGH + 1);                                  /*DR111313*/
      IF WATCH THEN CALL PRINT_SENTENCE(TEMP2);                                 04138050
      RETURN NEW_NODE_BEGINNING;                                                04138060
   END EJECT_INVARS;                                                            04138070
