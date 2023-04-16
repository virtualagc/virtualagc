 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENERAT2.xpl
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
 /* PROCEDURE NAME:  GENERATE_DSUB_COMPUTATION                              */
 /* MEMBER NAME:     GENERAT2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TMP               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          ARRAY_DIMENSIONS                                               */
 /*          BIT_VAR                                                        */
 /*          IADD                                                           */
 /*          IIPR                                                           */
 /*          PRESENT_DIMENSION                                              */
 /*          TRUE                                                           */
 /*          TSUB_SUB                                                       */
 /*          VAR_TYPE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          DIMENSIONS                                                     */
 /*          LAST_DSUB_HALMAT                                               */
 /*          PREVIOUS_COMPUTATION                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          COMPUTE_DIM_CONSTANT                                           */
 /*          COMPUTE_DIMENSIONS                                             */
 /*          EXTRACT_VAR                                                    */
 /*          INSERT_HALMAT_TRIPLE                                           */
 /* CALLED BY:                                                              */
 /*          CHECK_COMPONENT                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GENERATE_DSUB_COMPUTATION <==                                       */
 /*     ==> INSERT_HALMAT_TRIPLE                                            */
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
 /*     ==> COMPUTE_DIM_CONSTANT                                            */
 /*         ==> SAVE_LITERAL                                                */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GET_LITERAL                                             */
 /*         ==> TEMPLATE_LIT                                                */
 /*             ==> STRUCTURE_COMPARE                                       */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> GENERATE_TEMPLATE_LIT                                   */
 /*                 ==> SAVE_LITERAL                                        */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> GET_LITERAL                                     */
 /*         ==> INT_TO_SCALAR                                               */
 /*             ==> HEX                                                     */
 /*     ==> EXTRACT_VAR                                                     */
 /*         ==> HEX                                                         */
 /*         ==> OPOP                                                        */
 /*         ==> XHALMAT_QUAL                                                */
 /*     ==> COMPUTE_DIMENSIONS                                              */
 /***************************************************************************/
                                                                                02370160
                                                                                02370170
                                                                                02370180
 /* COMPUTES DIMENSIONS IF NECESSARY, THEN GENERATES MULTIPLICATIONS            02370190
      AND ADDITIONS FOR SUBSCRIPT COMPUTATIONS.  PTR POINTS TO DSUB OPERAND*/   02370200
GENERATE_DSUB_COMPUTATION:                                                      02370210
   PROCEDURE;                                                                   02370220
      DECLARE TMP FIXED;                                                        02370230
      IF ^PREVIOUS_COMPUTATION THEN DO;                                         02370240
         IF TSUB_SUB THEN DO;                                                   02370241
            DIMENSIONS = 2;                                                     02370242
         END;                                                                   02370243
         ELSE CALL COMPUTE_DIMENSIONS;                                          02370244
      END;                                                                      02370245
      IF VAR_TYPE = BIT_VAR AND PRESENT_DIMENSION >ARRAY_DIMENSIONS THEN RETURN;02370250
 /* NO TERMINAL BIT SUBSCRIPTS*/                                                02370260
                                                                                02370270
      IF PRESENT_DIMENSION ^= DIMENSIONS THEN DO;                               02370280
         TMP = INSERT_HALMAT_TRIPLE(IIPR,EXTRACT_VAR,COMPUTE_DIM_CONSTANT,1);   02370290
                                                                                02370300
 /* GENERATED SUBSCRIPT IIPR'S HAVE A TAG OF 1 */                               02370310
                                                                                02370320
         IF PREVIOUS_COMPUTATION THEN                                           02370330
            LAST_DSUB_HALMAT = INSERT_HALMAT_TRIPLE(IADD,TMP,LAST_DSUB_HALMAT); 02370340
         ELSE LAST_DSUB_HALMAT = TMP;                                           02370350
      END;                                                                      02370360
      ELSE DO;     /* LAST DIMENSION*/                                          02370370
         IF PREVIOUS_COMPUTATION THEN DO;                                       02370380
            LAST_DSUB_HALMAT = INSERT_HALMAT_TRIPLE(IADD,LAST_DSUB_HALMAT,      02370390
               EXTRACT_VAR);                                                    02370400
         END;                                                                   02370410
         ELSE LAST_DSUB_HALMAT = EXTRACT_VAR;  /* PREVENTS A$(J+1) SCE'S */     02370420
      END;                                                                      02370430
                                                                                02370440
      PREVIOUS_COMPUTATION = TRUE;                                              02370450
   END GENERATE_DSUB_COMPUTATION;                                               02370460
