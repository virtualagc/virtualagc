*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM12SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM12SN--DETERMINANT OF AN N X N MATRIX, SP'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
DETSAV   DS    1F                                                       00000400
         MEND                                                           00000500
MM12SN   AMAIN                                                          00000600
*                                                                       00000700
* TAKES THE DETERMINANT OF AN N X N DOUBLE PRECISION MATRIX WHERE N     00000800
*   IS NOT EQUAL TO 3.                                                  00000900
*                                                                       00001000
         INPUT R2,            MATRIX(N,N) SP                           X00001100
               R4,            MATRIX(N,N) SP TEMPORARY WORKAREA        X00001200
               R5             INTEGER(N) SP                             00001300
         OUTPUT F0            SCALAR SP                                 00001400
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
         LE    F0,2(R2)                                                 00005600
         ME    F0,8(R2)                                                 00005700
         LE    F2,4(R2)                                                 00005800
         ME    F2,6(R2)                                                 00005900
         SEDR  F0,F2                                                    00006000
         B     OUT                                                      00006100
NLEN     LR    R7,R5                                                    00006200
         MR    R7,R5                                                    00006300
         SLL   R7,15                                                    00006400
         LR    R1,R4                                                    00006500
         LR    R4,R5                                                    00006600
         SLL   R4,1                                                     00006700
MVLOOP   LE    F0,0(R7,R2)                                              00006800
         STE   F0,0(R7,R1)                                              00006900
         BCTB  R7,MVLOOP                                                00007000
         LFLI  F4,1                                                     00007100
         LFXI  R5,1                                                     00007200
ALOOP    SER   F0,F0                                                    00007300
         LR    R7,R5                                                    00007400
         LH    R1,ARG4                                                  00007500
         SR    R1,R4                                                    00007600
SLOOP    AR    R1,R4                                                    00007700
         BCTB  R7,SLOOP                                                 00007800
         LR    R6,R5          I1=K                                      00007900
         LR    R7,R5          J1=K                                      00008000
         LR    R3,R5          I=K TO N                                  00008100
DLOOP    LR    R2,R5          J = K TO N                                00008200
ELOOP    LE    F2,0(R2,R1)                                              00008300
         BNL   COMP                                                     00008400
C1       LECR  F2,F2                                                    00008500
COMP     CER  F0,F2                                                     00008600
         BNL   GLOOP                                                    00008700
         LER   F0,F2                                                    00008800
         LR    R6,R3                                                    00008900
         LR    R7,R2                                                    00009000
GLOOP    LA    R2,1(R2)       J COUNTER                                 00009100
         CH    R2,ARG5                                                  00009200
         BLE   ELOOP                                                    00009300
         LA    R3,1(R3)                                                 00009400
         AR    R1,R4          ROW I = I + 1                             00009500
         CH    R3,ARG5                                                  00009600
         BLE   DLOOP                                                    00009700
         LH    R1,ARG4                                                  00009800
         LR    R3,R5                                                    00009900
         SR    R1,R4                                                    00010000
         LR    R2,R1                                                    00010100
K2       AR    R1,R4                                                    00010200
         BCTB  R3,K2                                                    00010300
         CR    R6,R5                                                    00010400
         BE    L                                                        00010500
J        LECR  F4,F4                                                    00010600
         LR    R3,R6                                                    00010700
K1       AR    R2,R4                                                    00010800
         BCTB  R3,K1                                                    00010900
         LR    R3,R5                                                    00011000
KLOOP    LE    F0,0(R3,R1)    A(K,J)                                    00011100
         LE    F2,0(R3,R2)    A(I1,J)                                   00011200
         STE   F2,0(R3,R1)    A(K,J)                                    00011300
         STE   F0,0(R3,R2)    A(I1,J)                                   00011400
         LA    R3,1(R3)                                                 00011500
         CH    R3,ARG5                                                  00011600
         BNH   KLOOP                                                    00011700
L        LR    R2,R1                                                    00011800
         CR    R7,R5                                                    00011900
         BE    Q                                                        00012000
N        LECR  F4,F4                                                    00012100
         LR    R3,R5          I = K TO N                                00012200
OLOOP    LE    F0,0(R7,R1)    A(I,J1)                                   00012300
         LE    F2,0(R5,R1)    A(I,K)                                    00012400
         STE   F2,0(R7,R1)    A(I,J1)                                   00012500
         STE   F0,0(R5,R1)    A(I,K)                                    00012600
         AR    R1,R4                                                    00012700
         LA    R3,1(R3)                                                 00012800
         CH    R3,ARG5                                                  00012900
         BNH   OLOOP                                                    00013000
Q        LE    F0,0(R5,R2)    A(K,K)                                    00013100
         MER   F4,F0          DET * A(K,K)                              00013200
         LH    R1,ARG4                                                  00013300
         STE   F4,DETSAV                                                00013400
         LER   F4,F0                                                    00013500
R        LR    R1,R2                                                    00013600
         AR    R2,R4                                                    00013700
         LR    R3,R5                                                    00013800
         LA    R3,1(R3)                                                 00013900
         LFLI  F0,1                                                     00014000
         DER   F0,F4                                                    00014100
RLOOP    LR    R7,R5                                                    00014200
         AHI   R7,1           K + 1                                     00014300
         LE    F2,0(R5,R2)    A(I,K)                                    00014400
         LECR  F2,F2          -A(I,K)                                   00014500
T        MER   F2,F0          TEMP1                                     00014600
ULOOP    LE    F4,0(R7,R1)    A(K,J)                                    00014700
         MER   F4,F2          A(K,J) * TEMP1                            00014800
V        AE    F4,0(R7,R2)    A(I,J)                                    00014900
         STE   F4,0(R7,R2)                                              00015000
         AHI   R7,1           J = J + 1                                 00015100
         CH    R7,ARG5                                                  00015200
         BNH   ULOOP                                                    00015300
         AR    R2,R4                                                    00015400
         LA    R3,1(R3)                                                 00015500
         CH    R3,ARG5                                                  00015600
         BNH   RLOOP                                                    00015700
         AHI   R5,1                                                     00015800
         LE    F4,DETSAV                                                00015900
         CH    R5,ARG5                                                  00016000
         BL    ALOOP                                                    00016100
         SR    R2,R4                                                    00016200
         LH    R5,ARG5                                                  00016300
         ME    F4,0(R5,R2)                                              00016400
         LER   F0,F4                                                    00016500
OUT      AEXIT                                                          00016600
         ACLOSE                                                         00016700
