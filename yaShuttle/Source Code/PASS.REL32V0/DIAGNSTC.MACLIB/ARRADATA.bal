*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ARRADATA.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         ARRADATA
ARRADATA DSECT                ARRAYNESS DATA TEMPLATE
ARRAYNUM DS    H              NUMBER OF DIMENSIONS
RANGE1   DS    H              RANGE OF DIMENSION 1
RANGE2   DS    H              RANGE OF DIMENSION 2
RANGE3   DS    H              RANGE OF DIMENSION 3
ARRAYLEN EQU   *-ARRADATA
         MEND
