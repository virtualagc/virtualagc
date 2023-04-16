*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM12DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM12DN--DETERMINANT OF AN N X N MATRIX, DP'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
DETSAV   DS    1D                                                       00000400
         MEND                                                           00000500
MM12DN   AMAIN QDED=YES                                                 00000600
*                                                                       00000700
* TAKES THE DETERMINANT OF AN N X N DOUBLE PRECISION MATRIX WHERE N     00000800
*   IS NOT EQUAL TO 3.                                                  00000900
*                                                                       00001000
         INPUT R2,            MATRIX(N,N) DP                           X00001100
               R4,            MATRIX(N,N) DP TEMPORARY WORKAREA        X00001200
               R5             INTEGER(N) SP                             00001300
         OUTPUT F0            SCALAR DP                                 00001400
         WORK  R1,R3,R6,R7,F1,F2,F3,F4,F5                               00001500
*                                                                       00001600
* ALGORITHM:                                                            00001700
* IF N = 2 THEN                                                         00001800
*    RETURN (A(1,1) * A(2,2) - (A(2,1) * A(1,2)))                       00001900
* ELSE                                                                  00002000
* DET=1.0                                                               00002100
*FOR K=1 TO N-1 DO                                                      00002200
*    BEGIN                                                              00002300
*    BIG=0.0                                                            00002400
*    I1=J1=K                                                            00002500
*    FOR I=K TO N DO                                                    00002600
*    FOR J=K TO N DO                                                    00002700
*       IF ABS(A(I,J))>BIG THEN                                         00002800
*       BEGIN                                                           00002900
*       BIG=ABS(A(I,J)                                                  00003000
*       I1=I                                                            00003100
*       J1=J                                                            00003200
*       END                                                             00003300
*    IF I1^=K THEN                                                      00003400
*       BEGIN                                                           00003500
*       DET=-DET                                                        00003600
*       FOR J=K TO N DO SWITCH(A(I1,J),A(K,J));                         00003700
*       END;                                                            00003800
*    IF J1^=K THEN                                                      00003900
*       BEGIN                                                           00004000
*       DET=-DET                                                        00004100
*       FOR I=K TO N DO SWITCH(A(I,J1),A(I,K))                          00004200
*       END                                                             00004300
*    DET=DET*A(K,K)                                                     00004400
*    FOR I=K+1 TO N DO                                                  00004500
*       BEGIN                                                           00004600
*       TEMP1=-A(I,K)/A(K,K)                                            00004700
*       FOR J=K+1 TO N DO                                               00004800
*          A(I,J)=A(I,J)+A(K,J)*TEMP1                                   00004900
*       END                                                             00005000
*    END                                                                00005100
* DET=DET*A(N,N)                                                        00005200
*                                                                       00005300
         CHI   R5,2                                                     00005400
         BNE   NLEN                                                     00005500
         LED   F0,4(R2)                                                 00005600
         MED   F0,16(R2)                                                00005700
         LED   F2,8(R2)                                                 00005800
         MED   F2,12(R2)                                                00005900
         SEDR  F0,F2                                                    00006000
         B     OUT                                                      00006100
NLEN     LR    R7,R5                                                    00006200
         MR    R7,R5                                                    00006300
         SLL   R7,15                                                    00006400
         LR    R1,R4                                                    00006500
         LR    R4,R5                                                    00006600
         SLL   R4,2                                                     00006700
MVLOOP   LED   F0,0(R7,R2)                                              00006800
         STED  F0,0(R7,R1)                                              00006900
         BCTB  R7,MVLOOP                                                00007000
         SER   F5,F5                                                    00007100
         LFLI  F4,1                                                     00007200
         LFXI  R5,1                                                     00007300
ALOOP    SEDR  F0,F0                                                    00007400
         LR    R7,R5                                                    00007500
         LH    R1,ARG4                                                  00007600
         SR    R1,R4                                                    00007700
SLOOP    AR    R1,R4                                                    00007800
         BCTB  R7,SLOOP                                                 00007900
         LR    R6,R5          I1=K                                      00008000
         LR    R7,R5          J1=K                                      00008100
         LR    R3,R5          I=K TO N                                  00008200
DLOOP    LR    R2,R5          J = K TO N                                00008300
ELOOP    LED   F2,0(R2,R1)                                              00008400
         BNL   COMP                                                     00008500
C1       LECR  F2,F2                                                    00008600
COMP    QCEDR  F0,F2                                                    00008700
         BNL   GLOOP                                                    00008800
         LER   F0,F2                                                    00008900
         LER   F1,F3                                                    00009000
         LR    R6,R3                                                    00009100
         LR    R7,R2                                                    00009200
GLOOP    LA    R2,1(R2)       J COUNTER                                 00009300
         CH    R2,ARG5                                                  00009400
         BLE   ELOOP                                                    00009500
         LA    R3,1(R3)                                                 00009600
         AR    R1,R4          ROW I = I + 1                             00009700
         CH    R3,ARG5                                                  00009800
         BLE   DLOOP                                                    00009900
         LH    R1,ARG4                                                  00010000
         LR    R3,R5                                                    00010100
         SR    R1,R4                                                    00010200
         LR    R2,R1                                                    00010300
K2       AR    R1,R4                                                    00010400
         BCTB  R3,K2                                                    00010500
         CR    R6,R5                                                    00010600
         BE    L                                                        00010700
J        LECR  F4,F4                                                    00010800
         LR    R3,R6                                                    00010900
K1       AR    R2,R4                                                    00011000
         BCTB  R3,K1                                                    00011100
         LR    R3,R5                                                    00011200
KLOOP    LED   F0,0(R3,R1)    A(K,J)                                    00011300
         LED   F2,0(R3,R2)    A(I1,J)                                   00011400
         STED  F2,0(R3,R1)    A(K,J)                                    00011500
         STED  F0,0(R3,R2)    A(I1,J)                                   00011600
         LA    R3,1(R3)                                                 00011700
         CH    R3,ARG5                                                  00011800
         BNH   KLOOP                                                    00011900
L        LR    R2,R1                                                    00012000
         CR    R7,R5                                                    00012100
         BE    Q                                                        00012200
N        LECR  F4,F4                                                    00012300
         LR    R3,R5          I = K TO N                                00012400
OLOOP    LED   F0,0(R7,R1)    A(I,J1)                                   00012500
         LED   F2,0(R5,R1)    A(I,K)                                    00012600
         STED  F2,0(R7,R1)    A(I,J1)                                   00012700
         STED  F0,0(R5,R1)    A(I,K)                                    00012800
         AR    R1,R4                                                    00012900
         LA    R3,1(R3)                                                 00013000
         CH    R3,ARG5                                                  00013100
         BNH   OLOOP                                                    00013200
Q        LED   F0,0(R5,R2)    A(K,K)                                    00013300
         MEDR  F4,F0          DET * A(K,K)                              00013400
         LH    R1,ARG4                                                  00013500
         STED  F4,DETSAV                                                00013600
         LER   F4,F0                                                    00013700
         LER   F5,F1                                                    00013800
R        LR    R1,R2                                                    00013900
         AR    R2,R4                                                    00014000
         LR    R3,R5                                                    00014100
         LA    R3,1(R3)                                                 00014200
         SER   F1,F1                                                    00014300
         LFLI  F0,1                                                     00014400
        QDEDR  F0,F4                                                    00014500
RLOOP    LR    R7,R5                                                    00014600
         AHI   R7,1           K + 1                                     00014700
         LED   F2,0(R5,R2)    A(I,K)                                    00014800
         LECR  F2,F2          -A(I,K)                                   00014900
T        MEDR  F2,F0          TEMP1                                     00015000
ULOOP    LED   F4,0(R7,R1)    A(K,J)                                    00015100
         MEDR  F4,F2          A(K,J) * TEMP1                            00015200
V        AED   F4,0(R7,R2)    A(I,J)                                    00015300
         STED  F4,0(R7,R2)                                              00015400
         AHI   R7,1           J = J + 1                                 00015500
         CH    R7,ARG5                                                  00015600
         BNH   ULOOP                                                    00015700
         AR    R2,R4                                                    00015800
         LA    R3,1(R3)                                                 00015900
         CH    R3,ARG5                                                  00016000
         BNH   RLOOP                                                    00016100
         AHI   R5,1                                                     00016200
         LED   F4,DETSAV                                                00016300
         CH    R5,ARG5                                                  00016400
         BL    ALOOP                                                    00016500
         SR    R2,R4                                                    00016600
         LH    R5,ARG5                                                  00016700
         MED   F4,0(R5,R2)                                              00016800
         LER   F0,F4                                                    00016900
         LER   F1,F5                                                    00017000
OUT      AEXIT                                                          00017100
         ACLOSE                                                         00017200
