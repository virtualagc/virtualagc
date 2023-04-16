*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SYMEXTF.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         SYMEXTF
SYMEXTF  DSECT DSECT FOR FIXED PART OF SYMBOL EXTENT CELL
SUCCPTR  DS    F    POINTER TO SUCCESSOR CELL (USUALLY 0)
NEXTNTRY DS    H    NUMBER OF EXTENT ENTRIES
FSTPAGE  DS    H    PAGE # CORRESPONDING TO 1ST ENTRY
         MEND
