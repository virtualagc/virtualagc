 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMPUTED.xpl
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
 /* PROCEDURE NAME:  COMPUTE_DIM_CONSTANT                                   */
 /* MEMBER NAME:     COMPUTED                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          FLAG              BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          TEMP              BIT(16)                                      */
 /*          I                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMPONENT_SIZE                                                 */
 /*          DIMENSIONS                                                     */
 /*          FOR                                                            */
 /*          PRESENT_DIMENSION                                              */
 /*          TSUB_SUB                                                       */
 /*          XLIT                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_LITERAL                                                   */
 /*          INT_TO_SCALAR                                                  */
 /*          TEMPLATE_LIT                                                   */
 /* CALLED BY:                                                              */
 /*          GENERATE_DSUB_COMPUTATION                                      */
 /*          GET_LOOP_DIMENSION                                             */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COMPUTE_DIM_CONSTANT <==                                            */
 /*     ==> SAVE_LITERAL                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> TEMPLATE_LIT                                                    */
 /*         ==> STRUCTURE_COMPARE                                           */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GENERATE_TEMPLATE_LIT                                       */
 /*             ==> SAVE_LITERAL                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*     ==> INT_TO_SCALAR                                                   */
 /*         ==> HEX                                                         */
 /***************************************************************************/
                                                                                02369190
                                                                                02369200
 /*COMPUTES DIMENSION CONSTANT, GENERATES LITERAL, & RETURNS LITERAL POINTER*/  02369210
COMPUTE_DIM_CONSTANT:                                                           02369220
   PROCEDURE(FLAG);                                                             02369230
      DECLARE FLAG BIT(8);                                                      02369240
      DECLARE (TEMP,I) BIT(16);                                                 02369250
      IF TSUB_SUB THEN DO;                                                      02369253
         FLAG = 0;                                                              02369254
         RETURN SHL(TEMPLATE_LIT,16) | XLIT;                                    02369255
      END;                                                                      02369256
      TEMP = 1;                                                                 02369260
      DO FOR I = PRESENT_DIMENSION + 1 TO DIMENSIONS;                           02369270
         TEMP = TEMP * COMPONENT_SIZE(I);                                       02369280
      END;                                                                      02369290
      IF FLAG THEN DO;                                                          02369300
         FLAG = 0;                                                              02369310
         IF TEMP > 1 THEN RETURN TEMP;                                          02369320
         ELSE RETURN 0;                                                         02369330
      END;                                                                      02369340
      CALL INT_TO_SCALAR(TEMP);                                                 02369350
      RETURN SHL(SAVE_LITERAL(0,1,0,1,1),16) | XLIT;                            02369360
   END COMPUTE_DIM_CONSTANT;                                                    02369370
