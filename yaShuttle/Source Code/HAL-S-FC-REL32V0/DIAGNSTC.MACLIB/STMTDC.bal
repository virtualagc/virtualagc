*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    STMTDC.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         STMTDC
STMTDC   DSECT STATEMENT DATA CELL
BNUM     DS    H              BLOCK NUMBER
STMTTYPE DS    H              STATEMENT TYPE
NUMLABLS DS    CL1            NUMBER OF LABELS
NUMLHS   DS    CL1            NUMBER OF LEFT-HAND SIDES
         MEND
