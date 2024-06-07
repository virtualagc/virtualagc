*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SYMEXTV.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         SYMEXTV
SYMEXTV  DSECT DSECT FOR VARIABLE PART OF SYMBOL EXTENT CELL
FSTOFF   DS    H    OFFSET TO FIRST SYMBOL ON PAGE
LSTOFF   DS    H    OFFSET TO LAST SYMBOL ON PAGE
FSTSYMB  DS    CL8  NAME (8 CHARS) OF FIRST SYMBOL
LSTSYMB  DS    CL8  NAME (8 CHARS) OF LAST SYMBOL
         MEND
