 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PASSBACK.xpl
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
/* PROCEDURE NAME:  PASS_BACK_SYT_REFS                                     */
/* MEMBER NAME:     PASSBACK                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          CHECK_PASS_SYT    LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          F_FLAGS                                                        */
/*          F_SYT_REF                                                      */
/*          FRAME_FLAGS                                                    */
/*          FRAME_SYT_REF                                                  */
/*          PREV_BLOCK_FLAG                                                */
/*          STACK_PTR                                                      */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          STACK_FRAME                                                    */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          NEW_ZERO_SYT_REF_FRAME                                         */
/*          MERGE_SYT_REF_FRAMES                                           */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PASS_BACK_SYT_REFS <==                                              */
/*     ==> NEW_ZERO_SYT_REF_FRAME                                          */
/*         ==> NEW_SYT_REF_FRAME                                           */
/*             ==> ERRORS                                                  */
/*                 ==> PRINT_PHASE_HEADER                                  */
/*                     ==> PRINT_DATE_AND_TIME                             */
/*                         ==> PRINT_TIME                                  */
/*                 ==> COMMON_ERRORS                                       */
/*     ==> MERGE_SYT_REF_FRAMES                                            */
/***************************************************************************/
                                                                                02248000
                                                                                02250000
 /* ROUTINE TO PROPERLY PASS BACK SYT REFERENCE FRAMES ALONG                    02252000
            THE STACK */                                                        02254000
                                                                                02256000
PASS_BACK_SYT_REFS:PROCEDURE;                                                   02258000
                                                                                02260000
      IF (FRAME_FLAGS(STACK_PTR) & PREV_BLOCK_FLAG) = 0 THEN                    02262000
 /* CURRENT FRAME STARTED IN THIS HALMAT BLOCK */                               02264000
         CALL MERGE_SYT_REF_FRAMES(FRAME_SYT_REF(STACK_PTR),                    02266000
         FRAME_SYT_REF(STACK_PTR + 1) );                                        02268000
      ELSE DO;   /* CURRENT FRAME STARTED IN THE LAST HALMAT BLOCK */           02270000
         IF (FRAME_FLAGS(STACK_PTR + 1) & PREV_BLOCK_FLAG) = 0 THEN DO;         02272000
 /* POPPED FRAME STARTED IN THIS BLOCK */                                       02274000
CHECK_PASS_SYT:                                                                 02276000
            IF FRAME_SYT_REF(STACK_PTR) = 0 THEN DO;                            02278000
 /* NO CURRENTLY ALLOCATED REFERENCE MAP */                                     02280000
               FRAME_SYT_REF(STACK_PTR) = FRAME_SYT_REF(STACK_PTR + 1);         02282000
            END;                                                                02284000
            ELSE                                                                02286000
               CALL MERGE_SYT_REF_FRAMES(FRAME_SYT_REF(STACK_PTR),              02288000
               FRAME_SYT_REF(STACK_PTR + 1));                                   02290000
         END;                                                                   02292000
         ELSE DO;   /* POPPED FRAME STARTED IN LAST BLOCK */                    02294000
            IF FRAME_SYT_REF(STACK_PTR + 1) = 0 THEN DO;                        02296000
 /* NO REFERENCES FOR POPPED FRAME */                                           02298000
               IF FRAME_SYT_REF(STACK_PTR) = 0 THEN DO;                         02300000
 /* NO REFERENCES FOR THIS FRAME */                                             02302000
                  FRAME_SYT_REF(STACK_PTR) = NEW_ZERO_SYT_REF_FRAME;            02304000
               END;                                                             02306000
            END;                                                                02308000
            ELSE                                                                02310000
               GO TO CHECK_PASS_SYT;                                            02312000
         END;                                                                   02314000
      END;                                                                      02316000
                                                                                02318000
      CLOSE PASS_BACK_SYT_REFS;                                                 02320000
