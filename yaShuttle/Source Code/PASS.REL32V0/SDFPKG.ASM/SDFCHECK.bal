*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    SDFCHECK.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

SDFCHECK CSECT                                                          00000100
         PRINT NOGEN                                                    00000200
         OSSAVE                                                         00000300
         OPEN  (DCB1,(INPUT))                                           00000400
         LA    R12,DCB1                                                 00000500
         USING IHADCB,R12                                               00000600
         TM    DCBOFLGS,X'10'                                           00000700
         BO    OPENOK1                                                  00000800
         MVI   RETCODE+3,1                                              00000900
         B     DONE                                                     00001000
OPENOK1  OPEN  (DCB2,(INPUT))                                           00001100
         LA    R12,DCB2                                                 00001200
         TM    DCBOFLGS,X'10'                                           00001300
         BO    OPENOK2                                                  00001400
         MVI   RETCODE+3,2                                              00001500
         B     DONE                                                     00001600
OPENOK2  OPEN  (DCB3,(OUTPUT))                                          00001700
         LA    R12,DCB3                                                 00001800
         TM    DCBOFLGS,X'10'                                           00001900
         BO    LOOP1                                                    00002000
         MVI   RETCODE+3,3                                              00002100
         B     DONE                                                     00002200
         DROP  R12                                                      00002300
LOOP1    L     R2,=A(BUF1)                                              00002400
         READ  DECB1,SF,DCB1,BUF1,'S'                                   00002500
         CHECK DECB1                                                    00002600
         LH    R3,0(R2)                                                 00002700
         AR    R3,R2                                                    00002800
         LA    R2,2(R2)                                                 00002900
LOOP2    CR    R2,R3                                                    00003000
         BNL   LOOP1                                                    00003100
         MVC   SDFNAM(8),0(R2)                                          00003200
         MVC   NAME(8),0(R2)                                            00003300
         MVC   MSG2(14),GOOD                                            00003400
         CLC   SDFNAM(8),=X'FFFFFFFFFFFFFFFF'                           00003500
         BE    DONE                                                     00003600
         L     R4,=A(DCB2)                                              00003700
         BLDL  (R4),BLDLAREA                                            00003800
         MVC   TTRWORD(3),TTRN1                                         00003900
         POINT (R4),TTRWORD                                             00004000
         READ  DECB2,SF,DCB2,BUF2,'S'                                   00004100
         CHECK DECB2                                                    00004200
         L     R6,=A(BUF2)                                              00004300
         SR    R7,R7                                                    00004400
         IC    R7,TTRN1+3                                               00004500
LOOP3    MVC   TTRWORD(3),0(R6)                                         00004600
         POINT (R4),TTRWORD                                             00004700
         READ  DECB3,SF,DCB2,BUF3,'S'                                   00004800
         CHECK DECB3                                                    00004900
         LA    R6,4(R6)                                                 00005000
         BCT   R7,LOOP3                                                 00005100
CONT     SR    R1,R1                                                    00005200
         IC    R1,11(R2)                                                00005300
         N     R1,=X'0000001F'                                          00005400
         AR    R1,R1                                                    00005500
         LA    R1,12(R1)                                                00005600
         AR    R2,R1                                                    00005700
         PUT   DCB3,MESSAGE                                             00005800
         B     LOOP2                                                    00005900
DONE     CLOSE (DCB1)                                                   00006000
         CLOSE (DCB2)                                                   00006100
         CLOSE (DCB3)                                                   00006200
         OSRETURN                                                       00006300
SYNAD1   LA    R1,4001                                                  00006400
         B     DOABEND                                                  00006500
SYNAD2   MVC   MSG2(14),BAD                                             00006600
         BR    R14                                                      00006605
EODAD2   MVC   MSG2(14),BAD                                             00006610
         B     CONT                                                     00006615
SYNAD3   LA    R1,4003                                                  00006800
DOABEND  ABEND (R1),DUMP                                                00006900
*                                                                       00007000
*        DATA AREA                                                      00007100
*                                                                       00007200
         DS    0F                                                       00007300
TTRWORD  DC    F'0'                                                     00007400
MESSAGE  DC    CL4'SDF '                                                00007500
NAME     DC    CL8' '                                                   00007600
MSG1     DC    CL4' IS '                                                00007700
MSG2     DC    CL24' '                                                  00007800
*                                                                       00007900
GOOD     DC    CL14'GOOD          '                                     00008000
BAD      DC    CL14'BAD BAD BAD !!'                                     00008100
*                                                                       00008200
*        BLDL AREA                                                      00008300
*                                                                       00008400
         DS    0H                                                       00008500
BLDLAREA EQU   *                                                        00008600
FF       DC    H'1'                                                     00008700
LL       DC    H'28'                                                    00008800
SDFNAM   DS    CL8                                                      00008900
TTR      DS    CL3                                                      00009000
K        DS    CL1                                                      00009100
Z        DS    CL1                                                      00009200
C        DS    CL1                                                      00009300
TTRN1    DS    2H                                                       00009400
TTRN2    DS    2H                                                       00009500
TTRN3    DS    2H                                                       00009600
PGELAST  DS    H                                                        00009700
*                                                                       00009800
*        LITERAL AREA                                                   00009900
*                                                                       00010000
         LTORG                                                          00010100
*                                                                       00010200
*        DCBS                                                           00010300
*                                                                       00010400
DCB1     DCB   DSORG=PS,DDNAME=SDF1,DEVD=DA,MACRF=R,SYNAD=SYNAD1,      X00010500
               EODAD=DONE,RECFM=U                                       00010600
DCB2     DCB   DSORG=PO,DDNAME=SDF2,DEVD=DA,MACRF=R,SYNAD=SYNAD2,      X00010700
               RECFM=F,LRECL=1680,BLKSIZE=1680,EODAD=EODAD2             00010800
DCB3     DCB   DSORG=PS,DDNAME=SYSPRINT,DEVD=DA,MACRF=PM,SYNAD=SYNAD3, X00010900
               RECFM=F,LRECL=40,BLKSIZE=40                              00011000
*                                                                       00011100
*        BUFFERS                                                        00011200
*                                                                       00011300
         DS    0F                                                       00011400
BUF1     DS    64F                                                      00011500
BUF2     DS    420F                                                     00011600
BUF3     DS    420F                                                     00011700
         DCBD  DSORG=(PO)                                               00011800
         END                                                            00011900
