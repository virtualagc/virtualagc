 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EXPANDDS.xpl
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
 /* PROCEDURE NAME:  EXPAND_DSUB                                            */
 /* MEMBER NAME:     EXPANDDS                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          NUMOP             BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ALPHA                                                          */
 /*          BETA                                                           */
 /*          CHAR_VAR                                                       */
 /*          FALSE                                                          */
 /*          LIT                                                            */
 /*          NOP                                                            */
 /*          OPR                                                            */
 /*          TSUB                                                           */
 /*          VAR_TYPE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DSUB_HOLE                                                      */
 /*          DSUB_INX                                                       */
 /*          DSUB_LOC                                                       */
 /*          PRESENT_DIMENSION                                              */
 /*          PREVIOUS_COMPUTATION                                           */
 /*          TSUB_SUB                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LAST_OP                                                        */
 /*          CHECK_COMPONENT                                                */
 /*          NO_OPERANDS                                                    */
 /*          OPOP                                                           */
 /*          SET_SAV                                                        */
 /*          SET_VAR                                                        */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EXPAND_DSUB <==                                                     */
 /*     ==> OPOP                                                            */
 /*     ==> LAST_OP                                                         */
 /*     ==> NO_OPERANDS                                                     */
 /*     ==> SET_VAR                                                         */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> LAST_OPERAND                                                */
 /*     ==> SET_SAV                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> NO_OPERANDS                                                 */
 /*         ==> LAST_OPERAND                                                */
 /*         ==> VU                                                          */
 /*             ==> HEX                                                     */
 /*         ==> PUSH_HALMAT                                                 */
 /*             ==> HEX                                                     */
 /*             ==> OPOP                                                    */
 /*             ==> VAC_OR_XPT                                              */
 /*             ==> BUMP_D_N                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> ENTER                                                   */
 /*             ==> LAST_OP                                                 */
 /*             ==> NO_OPERANDS                                             */
 /*             ==> MOVE_LIMB                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> RELOCATE                                            */
 /*                 ==> MOVECODE                                            */
 /*                     ==> ENTER                                           */
 /*     ==> CHECK_COMPONENT                                                 */
 /*         ==> XHALMAT_QUAL                                                */
 /*         ==> CONVERSION_TYPE                                             */
 /*         ==> GENERATE_DSUB_COMPUTATION                                   */
 /*             ==> INSERT_HALMAT_TRIPLE                                    */
 /*                 ==> VU                                                  */
 /*                     ==> HEX                                             */
 /*                 ==> PUSH_HALMAT                                         */
 /*                     ==> HEX                                             */
 /*                     ==> OPOP                                            */
 /*                     ==> VAC_OR_XPT                                      */
 /*                     ==> BUMP_D_N                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> ENTER                                           */
 /*                     ==> LAST_OP                                         */
 /*                     ==> NO_OPERANDS                                     */
 /*                     ==> MOVE_LIMB                                       */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> RELOCATE                                    */
 /*                         ==> MOVECODE                                    */
 /*                             ==> ENTER                                   */
 /*             ==> COMPUTE_DIM_CONSTANT                                    */
 /*                 ==> SAVE_LITERAL                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> TEMPLATE_LIT                                        */
 /*                     ==> STRUCTURE_COMPARE                               */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GENERATE_TEMPLATE_LIT                           */
 /*                         ==> SAVE_LITERAL                                */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                             ==> GET_LITERAL                             */
 /*                 ==> INT_TO_SCALAR                                       */
 /*                     ==> HEX                                             */
 /*             ==> EXTRACT_VAR                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> OPOP                                                */
 /*                 ==> XHALMAT_QUAL                                        */
 /*             ==> COMPUTE_DIMENSIONS                                      */
 /***************************************************************************/
                                                                                02370610
                                                                                02370620
 /* EXPANDS DSUB'S & TSUB'S IF NOT CHARACTER OF BIT TYPE.                       02370630
      OPR(PTR) IS DSUB OR TSUB*/                                                02370640
EXPAND_DSUB:                                                                    02370650
   PROCEDURE(PTR) BIT(16);                                                      02370660
      DECLARE(PTR,NUMOP,TEMP) BIT(16);                                          02370670
                                                                                02370680
                                                                                02370690
                                                                                02370700
      DSUB_LOC = PTR;                                                           02370710
      DSUB_HOLE = LAST_OP(PTR - 1);                                             02370720
                                                                                02370730
      IF OPOP(DSUB_HOLE) ^= NOP | DSUB_HOLE < 0 THEN DSUB_HOLE = PTR;           02370740
 /* NO SPACE LEFT BY PHASE 1*/                                                  02370750
      TEMP = PTR + 1;                                                           02370760
      IF (SHR(OPR(TEMP),4) & "F") = LIT THEN RETURN;                            02370765
      IF (OPR(TEMP+1)&"FFFF") = "0951" THEN RETURN; /* TSUB WITH LIT INDEX */   02370766
      TSUB_SUB = OPOP(DSUB_LOC) = TSUB;                                         02370767
      CALL SET_VAR(TEMP);                                                       02370770
      IF VAR_TYPE = CHAR_VAR THEN RETURN;                                       02370780
      PREVIOUS_COMPUTATION = FALSE;                                             02370790
      PRESENT_DIMENSION = 0;                                                    02370800
                                                                                02370810
      NUMOP = NO_OPERANDS(DSUB_LOC);                                            02370820
      DSUB_INX = PTR + 2;                                                       02370830
                                                                                02370840
      DO WHILE DSUB_INX <= DSUB_LOC + NUMOP;                                    02370850
                                                                                02370860
         DO CASE ALPHA;                                                         02370870
                                                                                02370880
            PRESENT_DIMENSION = PRESENT_DIMENSION + 1;  /* 0 = * */             02370890
                                                                                02370900
            CALL CHECK_COMPONENT;                       /* 1 = INDEX */         02370910
                                                                                02370920
            IF BETA THEN PRESENT_DIMENSION = PRESENT_DIMENSION + 1;             02370930
 /* TO */                                                                       02370940
                                                                                02370950
            IF ^BETA THEN CALL CHECK_COMPONENT;         /* AT   (BETA = 0)*/    02370960
                                                                                02370970
         END;   /* DO CASE*/                                                    02370980
                                                                                02370990
         DSUB_INX = DSUB_INX + 1;                                               02371000
                                                                                02371010
      END;  /* DO WHILE*/                                                       02371020
                                                                                02371030
      IF PREVIOUS_COMPUTATION THEN CALL SET_SAV;                                02371040
                                                                                02371042
      TSUB_SUB = FALSE;                                                         02371044
                                                                                02371046
   END EXPAND_DSUB;                                                             02371050
