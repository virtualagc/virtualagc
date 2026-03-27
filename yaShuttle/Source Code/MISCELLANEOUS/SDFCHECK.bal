*                                                                       00010007
* SDFCHECK: VERS 2.0    CRAIG W. SCHULENBERG     10/30/92               00020008
*                         -- ADDED LOGIC TO PERFORM "ONE FCB" SDF       00030007
*                              SELECTS FOR EACH MEMBER IDENTIFIED       00040007
*                              IN THE SDF1 DCB                          00050007
*                                                                       00060007
SDFCHECK CSECT                                                          00070000
         PRINT NOGEN                                                    00080000
         OSSAVE                                                         00090000
*                                                                       00100005
* ALLOW SDFPKG TO PERFORM ITS INITIALIZATION                            00110005
*                                                                       00120005
         MVI   MISC+1,X'08'     SET ONE FCB MODE                        00130005
         LA    R0,COMMAREA                                              00140005
         SR    R1,R1                                                    00150005
         CALL  SDFPKG                                                   00160005
         OPEN  (DCB1,(INPUT))                                           00170000
         LA    R12,DCB1                                                 00180000
         USING IHADCB,R12                                               00190000
         TM    DCBOFLGS,X'10'                                           00200000
         BO    OPENOK1                                                  00210000
         MVI   RETCODE+3,1                                              00220000
         B     DONE                                                     00230000
OPENOK1  OPEN  (DCB2,(INPUT))                                           00240000
         LA    R12,DCB2                                                 00250000
         TM    DCBOFLGS,X'10'                                           00260000
         BO    OPENOK2                                                  00270000
         MVI   RETCODE+3,2                                              00280000
         B     DONE                                                     00290000
OPENOK2  OPEN  (DCB3,(OUTPUT))                                          00300000
         LA    R12,DCB3                                                 00310000
         TM    DCBOFLGS,X'10'                                           00320000
         BO    LOOP1                                                    00330000
         MVI   RETCODE+3,3                                              00340000
         B     DONE                                                     00350000
         DROP  R12                                                      00360000
LOOP1    L     R2,=A(BUF1)                                              00370000
         READ  DECB1,SF,DCB1,BUF1,'S'                                   00380000
         CHECK DECB1                                                    00390000
         LH    R3,0(R2)                                                 00400000
         AR    R3,R2                                                    00410000
         LA    R2,2(R2)                                                 00420000
LOOP2    CR    R2,R3                                                    00430000
         BNL   LOOP1                                                    00440000
         MVC   SDFNAMX(8),0(R2)                                         00450000
         MVC   SDFNAM(8),0(R2)                                          00460005
         MVC   NAME(8),0(R2)                                            00470000
         MVC   MSG2(14),GOOD                                            00480000
         CLC   SDFNAMX(8),=X'FFFFFFFFFFFFFFFF'                          00490000
         BE    DONE                                                     00500000
*                                                                       00510005
         L     R4,=A(DCB2)                                              00520000
         BLDL  (R4),BLDLAREA                                            00530000
         LH    R6,PGELAST                                               00531009
         CH    R6,=H'255'                                               00532009
         BNH   SMALLSDF                                                 00533010
         LTR   R6,R6          CREATE A TRAP LOCATION TO FIND LARGE SDFS 00534009
SMALLSDF EQU   *                                                        00535009
         MVC   TTRWORD(3),TTRN1                                         00540000
         POINT (R4),TTRWORD                                             00550000
         READ  DECB2,SF,DCB2,BUF2,'S'                                   00560000
         CHECK DECB2                                                    00570000
         L     R6,=A(BUF2)                                              00580000
         SR    R7,R7                                                    00590000
         IC    R7,TTRN1+3                                               00600000
LOOP3    MVC   TTRWORD(3),0(R6)                                         00610000
         POINT (R4),TTRWORD                                             00620000
         READ  DECB3,SF,DCB2,BUF3,'S'                                   00630000
         CHECK DECB3                                                    00640000
         LA    R6,4(R6)                                                 00650000
         BCT   R7,LOOP3                                                 00660000
*                                                                       00670005
* SELECT THE SDF IN QUESTION                                            00680005
*                                                                       00690005
CONT     LA    R1,4                                                     00700005
         CALL  SDFPKG                                                   00710005
         LH    R1,CRETURN                                               00720005
         CH    R1,=H'32'                                                00730005
         BNH   CONT1                                                    00740005
         MVC   MSG2(14),CRAPPY                                          00750005
CONT1    SR    R1,R1                                                    00760000
         IC    R1,11(R2)                                                00770000
         N     R1,=X'0000001F'                                          00780000
         AR    R1,R1                                                    00790000
         LA    R1,12(R1)                                                00800000
         AR    R2,R1                                                    00810000
         PUT   DCB3,MESSAGE                                             00820000
         B     LOOP2                                                    00830000
DONE     CLOSE (DCB1)                                                   00840000
         CLOSE (DCB2)                                                   00850000
         CLOSE (DCB3)                                                   00860000
         OSRETURN                                                       00870000
SYNAD1   LA    R1,4001                                                  00880000
         B     DOABEND                                                  00890000
SYNAD2   MVC   MSG2(14),BAD                                             00900000
         BR    R14                                                      00910005
EODAD2   MVC   MSG2(14),BAD                                             00920005
         B     CONT                                                     00930005
SYNAD3   LA    R1,4003                                                  00940000
DOABEND  ABEND (R1),DUMP                                                00950000
*                                                                       00960000
*        DATA AREA                                                      00970000
*                                                                       00980000
         DS    0F                                                       00990000
TTRWORD  DC    F'0'                                                     01000000
MESSAGE  DC    CL4'SDF '                                                01010000
NAME     DC    CL8' '                                                   01020000
MSG1     DC    CL4' IS '                                                01030000
MSG2     DC    CL24' '                                                  01040000
*                                                                       01050000
GOOD     DC    CL14'GOOD          '                                     01060000
BAD      DC    CL14'BAD BAD BAD !!'                                     01070000
CRAPPY   DC    CL14'BAD (TTRS) !!!'                                     01080007
*                                                                       01090000
*        BLDL AREA                                                      01100000
*                                                                       01110000
         DS    0H                                                       01120000
BLDLAREA EQU   *                                                        01130000
FF       DC    H'1'                                                     01140000
LL       DC    H'28'                                                    01150000
SDFNAMX  DS    CL8                                                      01160000
TTR      DS    CL3                                                      01170000
K        DS    CL1                                                      01180000
Z        DS    CL1                                                      01190000
C        DS    CL1                                                      01200000
TTRN1    DS    2H                                                       01210000
TTRN2    DS    2H                                                       01220000
TTRN3    DS    2H                                                       01230000
PGELAST  DS    H                                                        01240000
*                                                                       01250000
*        LITERAL AREA                                                   01260000
*                                                                       01270000
         LTORG                                                          01280000
*                                                                       01290000
*        DCBS                                                           01300000
*                                                                       01310000
DCB1     DCB   DSORG=PS,DDNAME=SDF1,DEVD=DA,MACRF=R,SYNAD=SYNAD1,      X01320000
               EODAD=DONE,RECFM=U                                       01330000
DCB2     DCB   DSORG=PO,DDNAME=SDF2,DEVD=DA,MACRF=R,SYNAD=SYNAD2,      X01340000
               RECFM=F,LRECL=1680,BLKSIZE=1680,EODAD=EODAD2             01350000
DCB3     DCB   DSORG=PS,DDNAME=SYSPRINT,DEVD=DA,MACRF=PM,SYNAD=SYNAD3, X01360000
               RECFM=F,LRECL=40,BLKSIZE=40                              01370000
*                                                                       01380005
         DS    0F                                                       01390005
COMMAREA EQU   *                                                        01400005
APGAREA  DC    A(0)                                                     01410005
AFCBBLKS DC    A(0)                                                     01420005
NPAGES   DC    H'0'                                                     01430005
NBYTES   DC    H'0'                                                     01440000
MISC     DC    H'0'                                                     01450005
CRETURN  DC    H'0'                                                     01460005
BLKNO    DC    H'0'                                                     01470005
SYMBNO   DC    H'0'                                                     01480005
STMTNO   DC    H'0'                                                     01490005
BLKNLEN  DC    X'00'                                                    01500005
SYMBNLEN DC    X'00'                                                    01510005
PNTR     DC    F'0'                                                     01520005
ADDR     DC    A(0)                                                     01530005
SDFNAM   DC    C'##AIBGPC'                                              01540000
CSECTNAM DC    CL8' '                                                   01550005
SREFNO   DC    CL6' '                                                   01560005
INCLCNT  DC    H'0'                                                     01570005
BLKNAM   DC    CL32' '                                                  01580005
SYMBNAM  DC    CL32' '                                                  01590005
*                                                                       01600000
*        BUFFERS                                                        01610000
*                                                                       01620000
         DS    0F                                                       01630000
BUF1     DS    64F                                                      01640000
BUF2     DS    420F                                                     01650000
BUF3     DS    420F                                                     01660000
         DCBD  DSORG=(PO)                                               01670000
         END                                                            01680000
