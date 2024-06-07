 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LIST.xpl
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
/* PROCEDURE NAME:  LIST                                                   */
/* MEMBER NAME:     LIST                                                   */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          LIST1             BIT(16)                                      */
/*          LIST2             BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          TEMP_PTR          BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CELL_CDR                                                       */
/*          CDR_CELL                                                       */
/*          CLOSE                                                          */
/*          TRUE                                                           */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          LIST_STRUX                                                     */
/* CALLED BY:                                                              */
/*          PASS1                                                          */
/***************************************************************************/
                                                                                02454000
                                                                                02456000
 /* ROUTINE TO MERGE TWO LISTS INTO ONE */                                      02458000
                                                                                02460000
LIST:FUNCTION(LIST1, LIST2) BIT(16);                                            02462000
                                                                                02464000
   DECLARE                                                                      02466000
      LIST1                          BIT(16),                                   02468000
      LIST2                          BIT(16),                                   02470000
      TEMP_PTR                       BIT(16);                                   02472000
                                                                                02474000
   IF LIST1 = 0 THEN                                                            02476000
      RETURN LIST2;                                                             02478000
                                                                                02480000
   IF LIST2 = 0 THEN                                                            02482000
      RETURN LIST1;                                                             02484000
                                                                                02486000
   TEMP_PTR = LIST1;   /* GO DOWN LIST1 TO ITS LAST PTR AND CHANGE IT           02488000
                          TO POINT TO LIST2 */                                  02490000
   DO WHILE TRUE;                                                               02492000
      IF CDR_CELL(TEMP_PTR) = 0 THEN DO;                                        02494000
         CDR_CELL(TEMP_PTR) = LIST2;                                            02496000
         RETURN LIST1;                                                          02498000
      END;                                                                      02500000
      TEMP_PTR = CDR_CELL(TEMP_PTR);                                            02502000
   END;                                                                         02504000
                                                                                02506000
   CLOSE LIST;                                                                  02508000
