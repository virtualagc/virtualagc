 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEWZEROV.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  NEW_ZERO_VAC_REF_FRAME                                 */
/* MEMBER NAME:     NEWZEROV                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP_PTR          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          F_BLOCK_PTR                                                    */
/*          F_START                                                        */
/*          FOR                                                            */
/*          FRAME_BLOCK_PTR                                                */
/*          FRAME_START                                                    */
/*          STACK_FRAME                                                    */
/*          STACK_PTR                                                      */
/*          V_REF_POOL                                                     */
/*          VAC_REF_POOL_FRAME_SIZE                                        */
/*          VAC_REF_POOL                                                   */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          V_POOL                                                         */
/*          WORK1                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NEW_VAC_REF_FRAME                                              */
/* CALLED BY:                                                              */
/*          COPY_VAC_REF_FRAME                                             */
/*          PASS_BACK_VAC_REFS                                             */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> NEW_ZERO_VAC_REF_FRAME <==                                          */
/*     ==> NEW_VAC_REF_FRAME                                               */
/*         ==> ERRORS                                                      */
/*             ==> PRINT_PHASE_HEADER                                      */
/*                 ==> PRINT_DATE_AND_TIME                                 */
/*                     ==> PRINT_TIME                                      */
/*             ==> COMMON_ERRORS                                           */
/***************************************************************************/
                                                                                02068000
                                                                                02070000
 /* ROUTINE TO RETURN A NEW ZEROED VAC REFERENCE MAP */                         02072000
                                                                                02074000
NEW_ZERO_VAC_REF_FRAME:FUNCTION BIT(16);                                        02076000
                                                                                02078000
   DECLARE                                                                      02080000
      TEMP_PTR                       BIT(16);                                   02082000
                                                                                02084000
   TEMP_PTR = NEW_VAC_REF_FRAME;                                                02086000
                                                                                02088000
   DO FOR WORK1 = SHR(FRAME_START(FRAME_BLOCK_PTR(STACK_PTR)), 5) TO            02090000
         VAC_REF_POOL_FRAME_SIZE;                                               02092000
      VAC_REF_POOL(TEMP_PTR + WORK1) = 0;                                       02094000
   END;                                                                         02096000
                                                                                02098000
   RETURN TEMP_PTR;                                                             02100000
                                                                                02102000
   CLOSE NEW_ZERO_VAC_REF_FRAME;                                                02104000
