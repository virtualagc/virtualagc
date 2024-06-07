 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LINKCELL.xpl
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
/* PROCEDURE NAME:  LINK_CELL_AREA                                         */
/* MEMBER NAME:     LINKCELL                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          LINK_UP_TIME(1)   FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CELL_CDR                                                       */
/*          CDR_CELL                                                       */
/*          CLOSE                                                          */
/*          FOR                                                            */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          #GCS                                                           */
/*          FREE_CELL_PTR                                                  */
/*          LIST_STRUX                                                     */
/*          TOTAL_GC_TIME                                                  */
/*          WORK1                                                          */
/* CALLED BY:                                                              */
/*          REINITIALIZE                                                   */
/*          INITIALIZE                                                     */
/***************************************************************************/
                                                                                02510000
                                                                                02512000
 /* ROUTINE TO LINK CELLS TO FREE_CELL_PTR */                                   02514000
                                                                                02516000
LINK_CELL_AREA:PROCEDURE;                                                       02518000
                                                                                02520000
      DECLARE                                                                   02522000
         LINK_UP_TIME(1)                FIXED;                                  02524000
                                                                                02526000
      LINK_UP_TIME = MONITOR(18);                                               02528000
                                                                                02530000
      DO FOR WORK1=1 TO RECORD_TOP(LIST_STRUX);                                 02532000
         CDR_CELL(WORK1) = WORK1 + 1;                                           02532010
      END;                                                                      02536000
                                                                                02538000
      FREE_CELL_PTR = 1;                                                        02540000
                                                                                02542000
      LINK_UP_TIME(1) = MONITOR(18);                                            02544000
      #GCS = #GCS + 1;                                                          02546000
      TOTAL_GC_TIME = TOTAL_GC_TIME + (LINK_UP_TIME(1) - LINK_UP_TIME);         02548000
                                                                                02550000
      CLOSE LINK_CELL_AREA;                                                     02552000
