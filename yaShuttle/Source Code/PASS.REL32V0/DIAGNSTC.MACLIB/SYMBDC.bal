*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SYMBDC.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         SYMBDC
SYMBDC   DSECT                SYMBOL DATA CELL
BLOCKNUM DS    H              BLOCK NUMBER
EXTDOFF  DS    C              OFFSET TO EXTENSION DATA
XREFOFF  DS    C              OFFSET TO XREF DATA
ARRAYOFF DS    C              OFFSET TO ARRAYNESS DATA
STRUCTOF DS    C              OFFSET TO STRUCTURE DATA
CLASS    DS    C              SYMBOL CLASS
TYPE     DS    C              SYMBOL TYPE
FLAG1    DS    C              FLAG BYTE ONE
FLAG2    DS    C              FLAG BYTE TWO
FLAG3    DS    C              FLAG BYTE THREE
FLAG4    DS    C              FLAG BYTE 4
SYMBLEN  DS    C              LENGTH OF SYMBOL NAME
RELADDR  DS    CL3            RELATIVE CORE ADDRESS
SBLKID   DS    H              UNIQUE BLOCK ID
TEMPL#   EQU   *   HALFWORD FOR MAJOR STRUCTURE TEMPLATE SYMBOL #
DENSEOFF EQU   *              DENSE BIT STRING OFFSET (ONE BYTE)
CHARLEN  EQU   *              HALFWORD FOR CHARACTER STRING LENGTH
ROWS     DS    C              NUMBER OF ROWS (LENGTH)
BITLEN   EQU   *              BYTE FOR BIT STRING LENGTH
COLUMNS  DS    C              NUMBER OF COLUMNS (LENGTH OF VECTOR)
LOCK#    DS    C              LOCK GROUP # OF VARIABLE (IF LOCKED)
BYTESIZE DS    CL3            TOTAL NUMBER OF BYTES USED BY SYMBOL
NAMECONT DS    0C             SYMBOL NAME CONTINUATION
SDCLEN   EQU   *-SYMBDC
         MEND
