*                                                                       00010003
* TEST1:  VERS 2.0      CRAIG W. SCHULENBERG     10/30/92               00020005
*                         -- BASELINED                                  00030003
*                                                                       00040003
         PRINT NOGEN                                                    00050002
TEST1    CSECT                                                          00060002
         OSSAVE                                                         00070002
         LA    R0,COMMAREA                                              00080002
         SR    R1,R1                                                    00090002
         CALL  SDFPKG                                                   00100002
*                                                                       00110002
         LA    R1,4                                                     00120002
         CALL  SDFPKG                                                   00130002
         SR    R1,R1                                                    00131007
         ST    R1,PNTR                                                  00132007
*                                                                       00140000
LOOPER   EQU   *                                                        00150002
         LA    R1,5                                                     00160007
         CALL  SDFPKG                                                   00170002
         LH    R1,PNTR                                                  00171007
         LA    R1,1(R1)                                                 00172007
         STH   R1,PNTR                                                  00173007
         B     LOOPER                                                   00180002
*                                                                       00190002
         OSRETURN                                                       00200002
         DS    0F                                                       00210002
COMMAREA EQU   *                                                        00220002
APGAREA  DC    A(0)                                                     00230002
AFCBBLKS DC    A(0)                                                     00240002
NPAGES   DC    H'0'                                                     00250002
NBYTES   DC    H'0'                                                     00260000
MISC     DC    H'0'                                                     00270002
CRETURN  DC    H'0'                                                     00280002
BLKNO    DC    H'0'                                                     00290002
SYMBNO   DC    H'0'                                                     00300002
STMTNO   DC    H'0'                                                     00310002
BLKNLEN  DC    X'00'                                                    00320002
SYMBNLEN DC    X'00'                                                    00330002
PNTR     DC    F'0'                                                     00340002
ADDR     DC    A(0)                                                     00350002
SDFNAM   DC    C'##VAASEQ'                                              00360008
CSECTNAM DC    CL8' '                                                   00370002
SREFNO   DC    CL6' '                                                   00380002
INCLCNT  DC    H'0'                                                     00390002
BLKNAM   DC    CL32' '                                                  00400002
SYMBNAM  DC    CL32' '                                                  00410002
         END                                                            00420002
