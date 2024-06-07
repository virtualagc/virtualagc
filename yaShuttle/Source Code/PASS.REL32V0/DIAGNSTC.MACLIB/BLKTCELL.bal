*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    BLKTCELL.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         BLKTCELL
BLKTCELL DSECT                BLOCK DATA CELL
RTREEPTR DS    A              RIGHT TREE POINTER (>)
LTREEPTR DS    A              LEFT TREE POINTER (<)
FNESTPTR DS    F              FIRST NESTED BLOCK
LNESTPTR DS    F              NEXT BLOCK AT SAME LEVEL
EXTPTR   DS    A              SYMBOL EXTENT CELL POINTER
         DS    F              SPARE
BLKFLGS  DS    C              FLAGS APPLICABLE TO THE BLOCK
         DS    C              SPARE
BLKNDX   DS    H              BLOCK INDEX
BLKID    DS    H              BLOCK (STACK) ID
BLKCLASS DS    C              CLASS OF BLOCK
BLKTYPE  DS    C              TYPE OF BLOCK
FSYMB#   DS    H              FIRST SYMBOL NUMBER
LSYMB#   DS    H              LAST SYMBOL NUMBER
FSTMT#   DS    H              FIRST STATEMENT NUMBER
LSTMT#   DS    H              LAST STATEMENT NUMBER
POSTDCL  DS    H              STMT # OF FIRST POST-DECLARE STMT
STAKLIST DS    H              LIST HEAD FOR STACK VARS (BY ADDR)
BNAMELEN DS    C              LENGTH OF BLOCK NAME
BLKNAME  DS    0C             NAME OF BLOCK (1 TO 32 CHARACTERS)
BTCELLEN EQU   *-BLKTCELL
         MEND
