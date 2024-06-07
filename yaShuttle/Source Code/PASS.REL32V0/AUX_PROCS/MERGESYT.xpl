 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MERGESYT.xpl
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
/* PROCEDURE NAME:  MERGE_SYT_REF_FRAMES                                   */
/* MEMBER NAME:     MERGESYT                                               */
/* INPUT PARAMETERS:                                                       */
/*          FRAME1            BIT(16)                                      */
/*          FRAME2            BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CLOSE                                                          */
/*          FOR                                                            */
/*          S_REF_POOL                                                     */
/*          SYT_REF_POOL_FRAME_SIZE                                        */
/*          SYT_REF_POOL                                                   */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          S_POOL                                                         */
/*          WORK1                                                          */
/* CALLED BY:                                                              */
/*          PASS_BACK_SYT_REFS                                             */
/***************************************************************************/
                                                                                02106000
                                                                                02108000
 /* ROUTINE TO MERGE TWO SYT REFERENCE FRAMES */                                02110000
                                                                                02112000
MERGE_SYT_REF_FRAMES:PROCEDURE(FRAME1, FRAME2);                                 02114000
                                                                                02116000
      DECLARE (FRAME1, FRAME2) BIT(16);                                         02118000
                                                                                02120000
      DO FOR WORK1 = 0 TO SYT_REF_POOL_FRAME_SIZE;                              02122000
         SYT_REF_POOL(FRAME1 + WORK1) = SYT_REF_POOL(FRAME1 + WORK1) |          02124000
            SYT_REF_POOL(FRAME2 + WORK1);                                       02126000
      END;                                                                      02128000
                                                                                02130000
      CLOSE MERGE_SYT_REF_FRAMES;                                               02132000
