*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    TEST1.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         PRINT NOGEN                                                    00000010
TEST1    CSECT                                                          00000020
         OSSAVE                                                         00000030
         LA    R0,COMMAREA                                              00000040
         SR    R1,R1                                                    00000050
         CALL  SDFPKG                                                   00000060
*                                                                       00000070
         LA    R1,4                                                     00000080
         CALL  SDFPKG                                                   00000090
*                                                                       00000100
LOOPER   EQU   *                                                        00000102
         LA    R1,14                                                    00000110
         CALL  SDFPKG                                                   00000120
         B     LOOPER                                                   00000125
*                                                                       00000130
         OSRETURN                                                       00000140
         DS    0F                                                       00000150
COMMAREA EQU   *                                                        00000160
APGAREA  DC    A(0)                                                     00000170
AFCBBLKS DC    A(0)                                                     00000180
NPAGES   DC    H'0'                                                     00000190
NBYTES   DC    H'0'                                                     00000200
MISC     DC    H'0'                                                     00000210
CRETURN  DC    H'0'                                                     00000220
BLKNO    DC    H'0'                                                     00000230
SYMBNO   DC    H'0'                                                     00000240
STMTNO   DC    H'0'                                                     00000250
BLKNLEN  DC    X'00'                                                    00000260
SYMBNLEN DC    X'00'                                                    00000270
PNTR     DC    F'0'                                                     00000280
ADDR     DC    A(0)                                                     00000290
SDFNAM   DC    C'##IMUERR'                                              00000300
CSECTNAM DC    CL8' '                                                   00000310
SREFNO   DC    CL6' '                                                   00000320
INCLCNT  DC    H'0'                                                     00000330
BLKNAM   DC    CL32' '                                                  00000340
SYMBNAM  DC    CL32' '                                                  00000350
         END                                                            00000360
