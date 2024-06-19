*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM14SN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MM14SN__INVERSE MATRIX M(N,N) . SP'                    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
ROWL     DS    1H                                                       00000400
         MEND                                                           00000500
MM14SN   AMAIN  ACALL=YES                                               00000600
*                                                                       00000700
*  GENERATES THE INVERSE MATRIX :                                       00000800
*                                                                       00000900
*   M(N,N)= INVERSE (M1(N,N) )                                          00001000
*                                                                       00001100
*   WHERE N^=3  M,M1 ARE SP                                             00001200
*                                                                       00001300
         INPUT R4,            MATRIX(N,N)  SP                          X00001400
               R5,            INTEGER(N)  SP                           X00001500
               R7             WORKAREA                                  00001600
         OUTPUT R2            MATRIX(N,N)  SP                           00001700
         WORK  R1,R3,R6,F0,F2,F3,F4                                     00001800
*                                                                       00001900
*  ALGORITHM :                                                          00002000
*                                                                       00002100
* FOR K=1,N                                                             00002200
*   FIND MAXIMAL ELEMENT IN ROWS K TO N,COL.S K TO N                    00002300
*   SAVE IT AS BIG,PIVOTAL ELEMENT                                      00002400
*     SAVE ITS ROW# AS ISW(K)                                           00002500
*     SAVE ITS COL# AS JSW(K)                                           00002600
*    SWITCH -KTH ROW AND ROW OF PIVOTAL ELEMENT                         00002700
*   SWITCH -KTH COLUMN AND COLUMN OF PIVOTAL ELEMENT                    00002800
*   DIVIDE KTH COLUMN ,EXCEPT FOR KTH ELEMENT BY -BIG                   00002900
*   REDUCE MATRIX                                                       00003000
*   DIVIDE KTH ROW,EXCEPT FOR KTH ELEMENT,BY BIG                        00003100
*   REPLACE PIVOT BY RECIPROCAL                                         00003200
*CONTINUE                                                               00003300
*DO K=K-1,1                                                             00003400
*INTERCHANGE JSW(K) ROW AND KTH                                         00003500
*INTERCHANGE ISW(K) COLUMN AND KTH                                      00003600
* IF DIM=2, THEN COMPUTES INVERSE DIRECTLY                              00003700
*END                                                                    00003800
* IF DIM=2,THEN CALCULATES INVERSE DIRECTLY                             00003900
*                                                                       00004000
         LR    R1,R4                                                    00004100
         CHI   R5,2                                                     00004200
         BNE   NLEN                                                     00004300
         LE    F0,2(R1)                                                 00004400
         LE    F2,4(R1)                                                 00004500
         ME    F0,8(R1)                                                 00004600
         ME    F2,6(R1)                                                 00004700
         SEDR  F0,F2                                                    00004800
         BZ    AOUT                                                     00004900
         LE    F4,8(R1)                                                 00005000
         DER   F4,F0                                                    00005100
         STE   F4,2(R2)                                                 00005200
         LE    F4,4(R1)                                                 00005300
         LECR  F4,F4                                                    00005400
         DER   F4,F0                                                    00005500
         STE   F4,4(R2)                                                 00005600
         LE    F4,6(R1)                                                 00005700
         LECR  F4,F4                                                    00005800
         DER   F4,F0                                                    00005900
         STE   F4,6(R2)                                                 00006000
         LE    F4,2(R1)                                                 00006100
         DER   F4,F0                                                    00006200
         STE   F4,8(R2)                                                 00006300
         AEXIT                                                          00006400
NLEN     LR    R3,R7                                                    00006500
         LR    R7,R5                                                    00006600
         MIH   R7,ARG5                                                  00006700
MVLOOP   LE    F0,0(R7,R1)   MOVE TO WORKAREA                           00006800
         STE   F0,0(R7,R2)                                              00006900
         BCTB  R7,MVLOOP                                                00007000
         SLL   R5,1                                                     00007100
         STH   R5,ROWL                                                  00007200
         LFXI  R5,1                                                     00007300
ALOOP    SER   F0,F0                                                    00007400
         LER   F2,F0                                                    00007500
         LR    R6,R5          I1=K                                      00007600
         LR    R7,R5          J1=K                                      00007700
         LR    R4,R5          I=K TO N                                  00007800
DLOOP    LR    R1,R5     J=K TO N                                       00007900
ELOOP    LE    F4,0(R1,R2)                                              00008000
         BNM   NSKIP                                                    00008100
         LECR  F4,F4                                                    00008200
NSKIP    CER   F2,F4                                                    00008300
         BNL   GLOOP                                                    00008400
CTSW     LE    F0,0(R1,R2)  NEW BIG                                     00008500
         LER   F2,F0     ABS(BIG)                                       00008600
         BNM   POS                                                      00008700
         LECR  F2,F2         ABS(BIG)                                   00008800
POS      LR    R6,R4   NEW ISW(K)                                       00008900
         LR    R7,R1   NEW JSW(K)                                       00009000
GLOOP    LA    R1,1(R1)    J=J+1                                        00009100
         CH    R1,ARG5                                                  00009200
         BLE   ELOOP                                                    00009300
         AHI   R4,1    NEXT ROW                                         00009400
         AH    R2,ROWL                                                  00009500
         CH    R4,ARG5  LAST+1ST ROW?                                   00009600
         BLE    DLOOP                                                   00009700
         LER   F0,F0                                                    00009800
         BE    AOUT                                                     00009900
         STH   R6,0(R3)       ISW(K)=I1                                 00010000
         STH   R7,1(R3)       JSW(K)=J1                                 00010100
         LH    R2,ARG2                                                  00010200
         LR    R1,R2                                                    00010300
         SH    R2,ROWL                                                  00010400
         LR    R7,R5                                                    00010500
L2       AH    R2,ROWL                                                  00010600
         BCTB  R7,L2     KTH ROW                                        00010700
         CR    R5,R6   K=ISW(K)?                                        00010800
         BE    MLOOP   SKIP IF EQUAL                                    00010900
*EXCHANGE ROWS                                                          00011000
         LH    R6,0(R3)     I1                                          00011100
         SH    R1,ROWL                                                  00011200
L1       AH    R1,ROWL                                                  00011300
         BCTB  R6,L1     I1TH ROW                                       00011400
         LH    R7,ARG5                                                  00011500
L3       LE    F2,0(R7,R1)       A(I1,J)                                00011600
         LE    F4,0(R7,R2)        A(K,J)                                00011700
         BZ    FX1            WORKAROUND FOR LECR BUG.                  00011800
         LECR  F4,F4                                                    00011900
FX1      STE   F4,0(R7,R1)                                              00012000
         STE   F2,0(R7,R2)                                              00012100
         BCTB  R7,L3                                                    00012200
*EXCHANGE COLUMNS                                                       00012300
MLOOP    LH    R4,ARG5                                                  00012400
         CH    R5,1(R3)    K=JI?                                        00012500
         BE    ROWD    SKIP IF EQUAL                                    00012600
         LH    R7,1(R3)     J1                                          00012700
         LH    R1,ARG2                                                  00012800
         SH    R1,ROWL                                                  00012900
M2LOOP   AH    R1,ROWL                                                  00013000
         LE    F2,0(R5,R1)     A(I,K)                                   00013100
         BZ    FX2            WORKAROUND FOR LECR BUG.                  00013200
         LECR  F2,F2                                                    00013300
FX2      LE    F4,0(R7,R1)     A(I,J1)                                  00013400
         STE   F2,0(R7,R1)     A(I,J1)=TEMP1                            00013500
         STE   F4,0(R5,R1)    A(I,K)=TEMP2                              00013600
         BCTB  R4,M2LOOP                                                00013700
*DIVIDE KTH COL BY -BIG                                                 00013800
ROWD     LFXI  R4,1                                                     00013900
         LH    R1,ARG2                                                  00014000
DIVLOOP  CR    R4,R5                                                    00014100
         BE    BABR                                                     00014200
         LE    F2,0(R5,R1)                                              00014300
         SER   F3,F3                                                    00014400
         LECR  F2,F2          -BIG                                      00014500
         DER   F2,F0          A(K,1)/-BIG                               00014600
         STE   F2,0(R5,R1)                                              00014700
BABR     AH    R1,ROWL                                                  00014800
         AHI   R4,1                                                     00014900
         CH    R4,ARG5                                                  00015000
         BLE   DIVLOOP                                                  00015100
*BEGINNING OF REDUCTION                                                 00015200
         LR    R7,R5   K                                                00015300
         LH    R1,ARG2                                                  00015400
RABR     LFXI  R4,1               I-COUNTER                             00015500
PLOOP    SER   F2,F2                                                    00015600
         CE    F2,0(R5,R1)   A(I,K)=0?                                  00015700
         BE    OSLOOP                                                   00015800
         CR    R4,R5                                                    00015900
         BE    OSLOOP                                                   00016000
         LFXI  R6,1    R6 IS J COUNTER                                  00016100
QLOOP    CR    R6,R5      J=K?                                          00016200
         BE    S1   IF YES,SKIP                                         00016300
         LE    F2,0(R5,R1)     A(I,K)                                   00016400
         ME    F2,0(R6,R2)     A(K,J)*A(I,K)                            00016500
         LE    F4,0(R6,R1)     A(I,J)                                   00016600
         AEDR  F4,F2   A(I,K)*A(I,K)+A(I,J)                             00016700
         STE   F4,0(R6,R1)                                              00016800
S1       AHI   R6,1    J=J+1                                            00016900
         CH    R6,ARG5    J=N?                                          00017000
         BNH     QLOOP                                                  00017100
OSLOOP   AH    R1,ROWL   ROW I=I+1                                      00017200
         AHI   R4,1   R4 IS I-COUNTER                                   00017300
         CH    R4,ARG5   I=N?                                           00017400
         BNH   PLOOP                                                    00017500
*END OF REDUCTION                                                       00017600
         LH    R7,ARG5                                                  00017700
*ULOOP DIVIDES KTH ROW,EXCEPT FOR KTH MEMBER,BY PIVOT                   00017800
ULOOP    CR    R7,R5   K?                                               00017900
         BE    USKIP                                                    00018000
         LE    F2,0(R7,R2)     A(K,J)                                   00018100
         DER   F2,F0                                                    00018200
         STE   F2,0(R7,R2)                                              00018300
KRIS     BCTB  R7,ULOOP                                                 00018400
         B     ARON                                                     00018500
USKIP    LFLI  F2,1                                                     00018600
         DER   F2,F0                                                    00018700
         STE   F2,0(R7,R2)                                              00018800
         B     KRIS                                                     00018900
ARON     LR    R7,R5                                                    00019000
* END OF ROW DIVIDE                                                     00019100
         AHI   R5,1   K=K+1                                             00019200
         LA    R3,2(R3)                                                 00019300
         AH    R2,ROWL                                                  00019400
         CH    R5,ARG5                                                  00019500
         BLE   ALOOP                                                    00019600
         SH    R2,ROWL                                                  00019700
         SH    R5,=H'2'   FOR K=N-1 TO 1                                00019800
         SH    R3,=H'2'                                                 00019900
*FINAL ROW AND COLUMN SWITCHS                                           00020000
REVERS   SH    R3,=H'2'                                                 00020100
         LH    R6,1(R3)      JSW(K)                                     00020200
         CR    R6,R5                                                    00020300
         BE    JCOMP                                                    00020400
         LH    R1,ARG2                                                  00020500
         SH    R1,ROWL                                                  00020600
         LR    R2,R1                                                    00020700
         LR    R7,R5                                                    00020800
X1LOOP   AH    R2,ROWL                                                  00020900
         BCTB  R7,X1LOOP                                                00021000
XLOOP    AH    R1,ROWL     JSW(K)TH ROW                                 00021100
         BCTB  R6,XLOOP                                                 00021200
         LH   R7,ARG5                                                   00021300
X2LOOP   LE    F0,0(R7,R2)   A(K,J)                                     00021400
         LE    F2,0(R7,R1)     A(I1,J)                                  00021500
         BZ    FX3            WORKAROUND FOR LECR BUG.                  00021600
         LECR  F2,F2                                                    00021700
FX3      STE   F2,0(R7,R2)   A(K,J)                                     00021800
         STE   F0,0(R7,R1)   A(I1,J)                                    00021900
         BCTB  R7,X2LOOP                                                00022000
JCOMP    LH    R6,0(R3)   ISW(K)                                        00022100
         CR    R6,R5                                                    00022200
         BE    INCR                                                     00022300
         LH    R2,ARG2                                                  00022400
         LH    R7,ARG5                                                  00022500
Y2LOOP   LE    F0,0(R6,R2)   A(I,J1)                                    00022600
         BZ    FX4            WORKAROUND FOR LECR BUG.                  00022700
         LECR  F0,F0                                                    00022800
FX4      LE    F2,0(R5,R2)     A(I,K)                                   00022900
         STE   F2,0(R6,R2)                                              00023000
         STE   F0,0(R5,R2)                                              00023100
         AH    R2,ROWL                                                  00023200
         BCTB  R7,Y2LOOP                                                00023300
INCR     SH    R5,=H'1'                                                 00023400
         BZ    OUT                                                      00023500
         B     REVERS                                                   00023600
OUT      AEXIT                                                          00023700
AOUT     AERROR   27         ERROR:THIS IS A SINGULAR MATRIX            00023800
         LH    R5,ARG5                                                  00023900
         LH    R1,ARG2                                                  00024000
         ABAL MM15SN                                                    00024100
         B     OUT                                                      00024200
         ACLOSE                                                         00024300
