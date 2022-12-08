 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHECKCOM.xpl
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
 /* PROCEDURE NAME:  CHECK_COMPONENT                                        */
 /* MEMBER NAME:     CHECKCOM                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          DSUB_INX                                                       */
 /*          OPR                                                            */
 /*          OR                                                             */
 /*          XSYT                                                           */
 /*          XVAC                                                           */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PRESENT_DIMENSION                                              */
 /*          OPERAND_TYPE                                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CONVERSION_TYPE                                                */
 /*          GENERATE_DSUB_COMPUTATION                                      */
 /*          XHALMAT_QUAL                                                   */
 /* CALLED BY:                                                              */
 /*          EXPAND_DSUB                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CHECK_COMPONENT <==                                                 */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> CONVERSION_TYPE                                                 */
 /*     ==> GENERATE_DSUB_COMPUTATION                                       */
 /*         ==> INSERT_HALMAT_TRIPLE                                        */
 /*             ==> VU                                                      */
 /*                 ==> HEX                                                 */
 /*             ==> PUSH_HALMAT                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> OPOP                                                */
 /*                 ==> VAC_OR_XPT                                          */
 /*                 ==> BUMP_D_N                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> ENTER                                               */
 /*                 ==> LAST_OP                                             */
 /*                 ==> NO_OPERANDS                                         */
 /*                 ==> MOVE_LIMB                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> RELOCATE                                        */
 /*                     ==> MOVECODE                                        */
 /*                         ==> ENTER                                       */
 /*         ==> COMPUTE_DIM_CONSTANT                                        */
 /*             ==> SAVE_LITERAL                                            */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> TEMPLATE_LIT                                            */
 /*                 ==> STRUCTURE_COMPARE                                   */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> GENERATE_TEMPLATE_LIT                               */
 /*                     ==> SAVE_LITERAL                                    */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> GET_LITERAL                                 */
 /*             ==> INT_TO_SCALAR                                           */
 /*                 ==> HEX                                                 */
 /*         ==> EXTRACT_VAR                                                 */
 /*             ==> HEX                                                     */
 /*             ==> OPOP                                                    */
 /*             ==> XHALMAT_QUAL                                            */
 /*         ==> COMPUTE_DIMENSIONS                                          */
 /***************************************************************************/
                                                                                02370470
                                                                                02370480
CHECK_COMPONENT:                                                                02370490
   PROCEDURE;                                                                   02370500
      PRESENT_DIMENSION = PRESENT_DIMENSION + 1;                                02370510
      OPERAND_TYPE = XHALMAT_QUAL(DSUB_INX);                                    02370520
      IF OPERAND_TYPE = XSYT OR OPERAND_TYPE = XVAC OR OPERAND_TYPE = XXPT      02370530
         THEN DO;                                                               02370540
                                                                                02370550
         IF OPERAND_TYPE = XVAC THEN IF CONVERSION_TYPE(SHR(OPR(DSUB_INX),16))  02370560
            THEN RETURN;     /* NO RUN TIME COMPUTATION*/                       02370570
         CALL GENERATE_DSUB_COMPUTATION;                                        02370580
      END;                                                                      02370590
   END CHECK_COMPONENT;                                                         02370600
