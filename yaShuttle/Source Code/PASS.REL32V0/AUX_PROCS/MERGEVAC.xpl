 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MERGEVAC.xpl
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
/* PROCEDURE NAME:  MERGE_VAC_REF_FRAMES                                   */
/* MEMBER NAME:     MERGEVAC                                               */
/* INPUT PARAMETERS:                                                       */
/*          FRAME1            BIT(16)                                      */
/*          FRAME2            BIT(16)                                      */
/*          FIRST_MERGE       BIT(16)                                      */
/*          LAST_MERGE        BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          FOR                                                            */
/*          V_REF_POOL                                                     */
/*          VAC_REF_POOL                                                   */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          V_POOL                                                         */
/*          WORK1                                                          */
/* CALLED BY:                                                              */
/*          PASS_BACK_VAC_REFS                                             */
/***************************************************************************/
                                                                                02134000
                                                                                02136000
 /* ROUTINE TO MERGE TWO VAC REFERENCE FRAMES */                                02138000
                                                                                02140000
MERGE_VAC_REF_FRAMES:PROCEDURE(FRAME1, FRAME2, FIRST_MERGE, LAST_MERGE);        02142000
                                                                                02144000
      DECLARE                                                                   02146000
         FRAME1                         BIT(16),                                02148000
         FRAME2                         BIT(16),                                02150000
         FIRST_MERGE                    BIT(16),                                02152000
         LAST_MERGE                     BIT(16);                                02154000
                                                                                02156000
      DO FOR WORK1 = SHR(FIRST_MERGE, 5) TO SHR(LAST_MERGE, 5) + 1;             02158000
         VAC_REF_POOL(FRAME1 + WORK1) = VAC_REF_POOL(FRAME1 + WORK1) |          02160000
            VAC_REF_POOL(FRAME2 + WORK1);                                       02162000
      END;                                                                      02164000
                                                                                02166000
      CLOSE MERGE_VAC_REF_FRAMES;                                               02168000
