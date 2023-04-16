*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    STMTEXTV.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         STMTEXTV
STMTEXTV DSECT  DSECT FOR VARIABLE PART OF STMT EXTENT CELL
FSTOFF1  DS    H    OFFSET TO FIRST SRN ON PAGE
LSTOFF1  DS    H    OFFSET TO LAST SRN ON PAGE
FSTSRN   DS    CL8  FIRST SRN ON PAGE
LSTSRN   DS    CL8  LAST SRN ON PAGE
         MEND
