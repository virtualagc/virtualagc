*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    COMMTABL.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler program.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         MACRO
         COMMTABL
COMMTABL DSECT       SDFPKG COMMUNICATION AREA
APGAREA  DS    A     ADDRESS OF EXTERNAL PAGING AREA
AFCBAREA DS    A     ADDRESS OF EXTERNAL FCB AREA
NPAGES   DS    H     # OF PAGES IN PAGING AREA OR AUGMENT
NBYTES   DS    H     # OF BYTES IN FCB AREA OR AUGMENT
MISC     DS    H     MISCELLANEOUS PURPOSES
CRETURN  DS    H     SDFPKG RETURN CODE
BLKNO    DS    H     BLOCK NUMBER (BLOCK NODE INDEX)
SYMBNO   DS    H     SYMBOL NUMBER (SYMBOL NODE INDEX)
STMTNO   DS    H     STATEMENT NUMBER (STATEMENT NODE INDEX)
BLKNLEN  DS    CL1   NUMBER OF CHARACTERS IN BLOCK NAME (BLKNAM)
SYMBNLEN DS    CL1   NUMBER OF CHARACTERS IN SYMBOL NAME (SYMBNAM)
PNTR     DS    F     VIRTUAL MEMORY POINTER LAST LOCATED
ADDR     DS    A     CORE ADDRESS CORRESPONDING TO PNTR
SDFDDNAM EQU   *     NAME OF ALTERNATE DD FOR SDF DATA SET
SDFNAM   DS    CL8   NAME OF SDF TO BE SELECTED
CSECTNAM DS    CL8   NAME OF CODE CSECT FOR BLOCK
SREFNO   DS    CL6   STATEMENT REFERENCE NUMBER
INCLCNT  DS    H     INCLUDE COUNT (FOR SRN)
BLKNAM   DS    CL32  BLOCK NAME
SYMBNAM  DS    CL32  SYMBOL NAME
         MEND
