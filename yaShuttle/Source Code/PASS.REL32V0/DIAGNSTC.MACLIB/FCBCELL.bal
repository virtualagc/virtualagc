*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    FCBCELL.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         FCBCELL
FCBCELL  DSECT
TTRK     DS    F
GTTREEPT DS    A
LTTREEPT DS    A
FILENAME DS    CL8
BLKPTR   DS    F
SYMBPTR  DS    F
STMTPTR  DS    F
TREEPTR  DS    F
NODESIZE DS    H
FLAGS    DS    H
NUMBLKS  DS    H
NUMSYMBS DS    H
FSTSTMT  DS    H
LSTSTMT  DS    H
LSTPAGE  DS    H
VERSIONX DS    H
STMTEXPT DS    F    POINTER TO STATEMENT NODE EXTENT CELL
SPARE2   DS    F
FCBLEN   EQU   *-FCBCELL
FCBTTRZ  DS    F
FCBPDADR DS    A
         MEND
