 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COPYVACR.xpl
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
/* PROCEDURE NAME:  COPY_VAC_REF_FRAME                                     */
/* MEMBER NAME:     COPYVACR                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          FRAME             BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP_PTR          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          F_BLOCK_PTR                                                    */
/*          F_START                                                        */
/*          FOR                                                            */
/*          FRAME_BLOCK_PTR                                                */
/*          FRAME_START                                                    */
/*          HALMAT_PTR                                                     */
/*          STACK_FRAME                                                    */
/*          STACK_PTR                                                      */
/*          V_REF_POOL                                                     */
/*          VAC_REF_POOL                                                   */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          V_POOL                                                         */
/*          WORK1                                                          */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NEW_ZERO_VAC_REF_FRAME                                         */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> COPY_VAC_REF_FRAME <==                                              */
/*     ==> NEW_ZERO_VAC_REF_FRAME                                          */
/*         ==> NEW_VAC_REF_FRAME                                           */
/*             ==> ERRORS                                                  */
/*                 ==> PRINT_PHASE_HEADER                                  */
/*                     ==> PRINT_DATE_AND_TIME                             */
/*                         ==> PRINT_TIME                                  */
/*                 ==> COMMON_ERRORS                                       */
/***************************************************************************/
                                                                                02206000
                                                                                02208000
 /* ROUTINE TO GET A NEW COPY OF A VAC REFERENCE MAP AND                        02210000
            SET IT TO A SPECIFIED MAP VALUE */                                  02212000
                                                                                02214000
COPY_VAC_REF_FRAME:FUNCTION(FRAME) BIT(16);                                     02216000
                                                                                02218000
   DECLARE                                                                      02220000
      FRAME                          BIT(16),                                   02222000
      TEMP_PTR                       BIT(16);                                   02224000
                                                                                02226000
   TEMP_PTR = NEW_ZERO_VAC_REF_FRAME;                                           02228000
                                                                                02230000
   DO FOR WORK1 = SHR(FRAME_START(FRAME_BLOCK_PTR(STACK_PTR)), 5) TO            02232000
         SHR(HALMAT_PTR, 5) + 1;                                                02234000
      VAC_REF_POOL(TEMP_PTR + WORK1) = VAC_REF_POOL(FRAME + WORK1);             02236000
   END;                                                                         02238000
                                                                                02240000
   RETURN TEMP_PTR;                                                             02242000
                                                                                02244000
   CLOSE COPY_VAC_REF_FRAME;                                                    02246000
