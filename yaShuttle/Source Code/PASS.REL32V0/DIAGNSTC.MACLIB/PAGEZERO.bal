*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    PAGEZERO.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         PAGEZERO
PAGEZERO DSECT
VERSION  DS    H              SDF VERSION NUMBER
         DS    H
DIRFCPTR DS    A              POINTER TO DIRECTORY FREE CELL CHAIN
DROOTPTR DS    A              POINTER TO DIRECTORY ROOT CELL
DATFCPTR DS    A              POINTER TO DATA FREE CELL CHAIN
         MEND
