 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PASSBAC2.xpl
    Purpose:    Auxiliary functionality used by the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
/***************************************************************************/
/* PROCEDURE NAME:  PASS_BACK_VAC_REFS                                     */
/* MEMBER NAME:     PASSBAC2                                               */
/* INPUT PARAMETERS:                                                       */
/*          WHICH_START       BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          CHECK_PASS_VAC    LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          F_BLOCK_PTR                                                    */
/*          F_FLAGS                                                        */
/*          F_START                                                        */
/*          F_VAC_REF                                                      */
/*          FRAME_BLOCK_PTR                                                */
/*          FRAME_FLAGS                                                    */
/*          FRAME_START                                                    */
/*          FRAME_VAC_REF                                                  */
/*          PREV_BLOCK_FLAG                                                */
/*          STACK_PTR                                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          STACK_FRAME                                                    */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NEW_ZERO_VAC_REF_FRAME                                         */
/*          MERGE_VAC_REF_FRAMES                                           */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PASS_BACK_VAC_REFS <==                                              */
/*     ==> NEW_ZERO_VAC_REF_FRAME                                          */
/*         ==> NEW_VAC_REF_FRAME                                           */
/*             ==> ERRORS                                                  */
/*                 ==> PRINT_PHASE_HEADER                                  */
/*                     ==> PRINT_DATE_AND_TIME                             */
/*                         ==> PRINT_TIME                                  */
/*                 ==> COMMON_ERRORS                                       */
/*     ==> MERGE_VAC_REF_FRAMES                                            */
/***************************************************************************/
                                                                                02322000
                                                                                02324000
 /* ROUTINE TO PROPERLY PASS BACK VAC REFERENCE FRAMES ALONG STACK */           02326000
                                                                                02328000
PASS_BACK_VAC_REFS:PROCEDURE(WHICH_START);                                      02330000
                                                                                02332000
      DECLARE                                                                   02334000
         WHICH_START                    BIT(16);                                02336000
                                                                                02338000
      IF (FRAME_FLAGS(STACK_PTR) & PREV_BLOCK_FLAG) = 0 THEN                    02340000
 /* CURRENT FRAME STARTED IN THIS BLOCK */                                      02342000
         CALL MERGE_VAC_REF_FRAMES(FRAME_VAC_REF(STACK_PTR),                    02344000
         FRAME_VAC_REF(STACK_PTR + 1), FRAME_START(FRAME_BLOCK_PTR(STACK_PTR)), 02346000
         FRAME_START(STACK_PTR + WHICH_START) );                                02348000
      ELSE DO;   /* CURRENT FRAME STARTED IN THE LAST HALMAT BLOCK */           02350000
         IF (FRAME_FLAGS(STACK_PTR + 1) & PREV_BLOCK_FLAG) = 0 THEN DO;         02352000
 /* POPPED FRAME STARTED IN THIS BLOCK */                                       02354000
CHECK_PASS_VAC:                                                                 02356000
            IF FRAME_VAC_REF(STACK_PTR) = 0 THEN DO;                            02358000
 /* NO ALLOCATED REFERENCE FRAME */                                             02360000
               FRAME_VAC_REF(STACK_PTR) = FRAME_VAC_REF(STACK_PTR + 1);         02362000
            END;                                                                02364000
            ELSE                                                                02366000
               CALL MERGE_VAC_REF_FRAMES(FRAME_VAC_REF(STACK_PTR),              02368000
               FRAME_VAC_REF(STACK_PTR + 1),                                    02370000
               FRAME_START(FRAME_BLOCK_PTR(STACK_PTR)),                         02372000
               FRAME_START(STACK_PTR + WHICH_START) );                          02374000
         END;                                                                   02376000
         ELSE DO;   /* POPPED FRAME STARTED IN LAST BLOCK */                    02378000
            IF FRAME_VAC_REF(STACK_PTR + 1) = 0 THEN DO;                        02380000
 /* NO REFERENCES FOR POPPED FRAME */                                           02382000
               IF FRAME_VAC_REF(STACK_PTR) = 0 THEN DO;                         02384000
 /* NO REFERENCES FOR THIS FRAME */                                             02386000
                  FRAME_VAC_REF(STACK_PTR) = NEW_ZERO_VAC_REF_FRAME;            02388000
               END;                                                             02390000
            END;                                                                02392000
            ELSE                                                                02394000
               GO TO CHECK_PASS_VAC;                                            02396000
         END;                                                                   02398000
      END;                                                                      02400000
                                                                                02402000
      CLOSE PASS_BACK_VAC_REFS;                                                 02404000
