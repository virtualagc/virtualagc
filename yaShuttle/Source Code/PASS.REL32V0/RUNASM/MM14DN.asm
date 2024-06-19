*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM14DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MM14DN MATRIX INVERSE,N X N,DOUBLE PREC'               00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
ROWL  DS    1H                                                          00000400
         MEND                                                           00000500
MM14DN   AMAIN ACALL=YES,QDED=YES                                       00000600
*                                                                       00000700
*   GENERATES THE INVERSE MATRIX :                                      00000800
*                                                                       00000900
*     M(N,N)= INVERSE ( M1(N,N) )                                       00001000
*                                                                       00001100
*   WHERE N NOT=3 & M , M1  ARE DP                                      00001200
*                                                                       00001300
         INPUT R4,            MATRIX(N,N)  DP                          X00001400
               R5,            INTEGER(N)   DP                          X00001500
               R7             WORKAREA                                  00001600
         OUTPUT R2            MATRIX(N,N)  DP                           00001700
         WORK  R1,R3,R6,F0,F1,F2,F3,F4,F5                               00001800
*                                                                       00001900
*  ALGORITHM:                                                           00002000
*                                                                       00002100
* FOR K=1,N                                                             00002200
*   FIND MAXIMAL ELEMENT IN ROWS K TO N,COL.S K TO N                    00002300
*   SAVE IT AS BIG,PIVOTAL ELEMENT                                      00002400
*     SAVE ITS ROW# AS ISW(K)                                           00002500
*     SAVE ITS COL# AS JSW(K)                                           00002600
*    SWITCH KTH ROW AND ROW OF PIVOTAL ELEMENT                          00002700
*   SWITCH KTH COLUMN AND COLUMN OF PIVOTAL ELEMENT                     00002800
*   DIVIDE KTH COLUMN ,EXCEPT FOR KTH ELEMENT BY -BIG                   00002900
*   REDUCE MATRIX                                                       00003000
*   DIVIDE KTH ROW,EXCEPT FOR KTH ELEMENT,BY BIG                        00003100
*   REPLACE PIVOT BY RECIPROCAL                                         00003200
*CONTINUE                                                               00003300
*DO K=K-1,1                                                             00003400
*INTERCHANGE JSW(K) ROW AND KTH                                         00003500
*INTERCHANGE ISW(K) COLUMN AND KTH                                      00003600
*END                                                                    00003700
* IF DIM=2, THEN CALCULATES INVERSE DIRECTLY                            00003800
*                                                                       00003900
         LR    R1,R4          CHANGE BETWEEN R1&R4                      00004000
         CHI   R5,2                                                     00004100
         BNE   NLEN                                                     00004200
         LED   F0,4(R1)                                                 00004300
         LED   F2,8(R1)                                                 00004400
         MED   F0,16(R1)                                                00004500
         MED   F2,12(R1)                                                00004600
         SEDR  F0,F2                                                    00004700
         BZ    AOUT                                                     00004800
         SER   F5,F5                                                    00004900
         LFLI  F4,1                                                     00005000
        QDEDR  F4,F0                                                    00005100
         LED   F2,16(R1)                                                00005200
         MEDR  F2,F4                                                    00005300
         STED  F2,4(R2)                                                 00005400
         LED   F2,8(R1)                                                 00005500
         LECR  F2,F2                                                    00005600
         MEDR  F2,F4                                                    00005700
         STED  F2,8(R2)                                                 00005800
         LED   F2,12(R1)                                                00005900
         LECR  F2,F2                                                    00006000
         MEDR  F2,F4                                                    00006100
         STED  F2,12(R2)                                                00006200
         LED   F2,4(R1)                                                 00006300
         MEDR  F2,F4                                                    00006400
         STED  F2,16(R2)                                                00006500
         AEXIT                                                          00006600
NLEN     LR    R3,R7                                                    00006700
         LR    R7,R5                                                    00006800
         MIH   R7,ARG5                                                  00006900
MVLOOP   LED   F0,0(R7,R1)                                              00007000
         STED   F0,0(R7,R2)                                             00007100
         BCTB  R7,MVLOOP                                                00007200
         SLL   R5,2                                                     00007300
         STH   R5,ROWL                                                  00007400
         LFXI  R5,1                                                     00007500
ALOOP    SEDR   F2,F2                                                   00007600
         LER   F0,F2                                                    00007700
         LER   F1,F3                                                    00007800
         LR    R6,R5          I1=K                                      00007900
         LR    R7,R5          J1=K                                      00008000
         LR    R4,R5          I=K TO N                                  00008100
DLOOP    LR    R1,R5     J=K TO N                                       00008200
ELOOP    LED   F4,0(R1,R2)                                              00008300
         BNM   NSKIP                                                    00008400
         LECR  F4,F4                                                    00008500
NSKIP   QCEDR  F0,F4                                                    00008600
         BNL   GLOOP                                                    00008700
CTSW     LED    F2,0(R1,R2)   NEW BIG                                   00008800
         LER   F0,F2                                                    00008900
         BNM   POS                                                      00009000
         LECR  F0,F0                                                    00009100
POS      LR    R6,R4       I1=I                                         00009200
         LR    R7,R1       J1=J                                         00009300
GLOOP    LA    R1,1(R1)                                                 00009400
         CH    R1,ARG5                                                  00009500
         BLE    ELOOP                                                   00009600
         AHI   R4,1                                                     00009700
         AH    R2,ROWL                                                  00009800
         CH    R4,ARG5                                                  00009900
         BLE    DLOOP                                                   00010000
         LER   F2,F2                                                    00010100
         BZ    AOUT                                                     00010200
         SEDR  F0,F0                                                    00010300
         LFLI  F0,1                                                     00010400
        QDEDR  F0,F2                                                    00010500
         STH   R6,0(R3)       ISW(K)=I1                                 00010600
         STH   R7,1(R3)       JSW(K)=J1                                 00010700
         LH    R2,ARG2                                                  00010800
         LR    R1,R2                                                    00010900
         SH    R2,ROWL                                                  00011000
         LR    R7,R5                                                    00011100
L2       AH    R2,ROWL                                                  00011200
         BCTB  R7,L2       KTH ROW                                      00011300
         CR    R5,R6      K=I1?                                         00011400
         BE    MLOOP                                                    00011500
*EXCHANGE ROWS                                                          00011600
         SH    R1,ROWL                                                  00011700
L1       AH    R1,ROWL                                                  00011800
         BCTB  R6,L1     I1TH ROW                                       00011900
         LH    R7,ARG5                                                  00012000
L3       LED   F2,0(R7,R1)       A(I1,J)                                00012100
         LED   F4,0(R7,R2)        A(K,J)                                00012200
         BZ    FX1            WORKAROUND FOR LECR BUG.                  00012300
         LECR  F4,F4                                                    00012400
FX1      STED  F4,0(R7,R1)                                              00012500
         STED  F2,0(R7,R2)                                              00012600
         BCTB  R7,L3                                                    00012700
*EXCHANGE COLUMNS                                                       00012800
MLOOP    LH    R4,ARG5                                                  00012900
         CH    R5,1(R3)                                                 00013000
         BE    ROWD                                                     00013100
         LH    R7,1(R3)     J1                                          00013200
         LH    R1,ARG2                                                  00013300
         SH    R1,ROWL                                                  00013400
M2LOOP   AH    R1,ROWL                                                  00013500
         LED   F2,0(R5,R1)     A(I,K)                                   00013600
         BZ    FX2            WORKAROUND FOR LECR BUG.                  00013700
         LECR  F2,F2                                                    00013800
FX2      LED   F4,0(R7,R1)     A(I,J1)                                  00013900
         STED  F2,0(R7,R1)     A(I,J1)=TEMP1                            00014000
         STED  F4,0(R5,R1)    A(I,K)=TEMP2/-BIG                         00014100
         BCTB  R4,M2LOOP                                                00014200
*DIVIDE KTH ROW BY -BIG                                                 00014300
ROWD     LH    R1,ARG2                                                  00014400
         LFXI  R4,1                                                     00014500
DIVLOOP  CR    R4,R5                                                    00014600
         BE    BABR                                                     00014700
         LED   F2,0(R5,R1)                                              00014800
         LECR  F2,F2                                                    00014900
         MEDR  F2,F0                                                    00015000
         STED  F2,0(R5,R1)                                              00015100
BABR     AH    R1,ROWL                                                  00015200
         AHI   R4,1                                                     00015300
         CH    R4,ARG5                                                  00015400
         BLE   DIVLOOP                                                  00015500
*BEGINNING OF REDUCTION                                                 00015600
         LR    R7,R5                                                    00015700
         LH    R1,ARG2                                                  00015800
RABR     LFXI  R4,1               I-COUNTER                             00015900
PLOOP    EQU   *                                                        00016000
         LED    F2,0(R5,R1)   A(I,K)=0?                                 00016100
         BE    OSLOOP                                                   00016200
         CR    R4,R5                                                    00016300
         BE    OSLOOP                                                   00016400
         LFXI  R6,1    R6 IS J COUNTER                                  00016500
QLOOP    CR    R6,R5      J=K?                                          00016600
         BE    S1   IF YES,SKIP                                         00016700
         LED   F2,0(R5,R1)     A(I,K)                                   00016800
         MED    F2,0(R6,R2)     A(K,J)                                  00016900
         LED    F4,0(R6,R1)     A(I,J)                                  00017000
         AEDR  F4,F2                                                    00017100
         STED   F4,0(R6,R1)                                             00017200
S1       AHI   R6,1    J=J+1                                            00017300
         CH    R6,ARG5    J=N?                                          00017400
         BNH   QLOOP                                                    00017500
OSLOOP   AH    R1,ROWL   ROW I=I+1                                      00017600
         AHI   R4,1   R2 IS I-COUNTER                                   00017700
         CH    R4,ARG5   I=N?                                           00017800
         BNH   PLOOP                                                    00017900
*END OF REDUCTION                                                       00018000
         LH    R7,ARG5                                                  00018100
*ULOOP DIVIDES KTH ROW,EXCEPT FOR KTH MEMBER,BY PIVOT                   00018200
ULOOP    CR    R7,R5                                                    00018300
         BE    USKIP                                                    00018400
         LED   F2,0(R7,R2)     A(K,J)                                   00018500
         MEDR  F2,F0                                                    00018600
         STED   F2,0(R7,R2)                                             00018700
KRIS     BCTB  R7,ULOOP                                                 00018800
         B     ARON                                                     00018900
USKIP    STED   F0,0(R7,R2)                                             00019000
         B     KRIS                                                     00019100
ARON     LR    R7,R5                                                    00019200
         AHI   R5,1   K=K+1                                             00019300
         LA    R3,2(R3)                                                 00019400
         AH    R2,ROWL                                                  00019500
         CH    R5,ARG5                                                  00019600
         BLE   ALOOP                                                    00019700
         SH    R2,ROWL                                                  00019800
         SH    R5,=H'2'   FOR K=N-1 TO 1                                00019900
         SH    R3,=H'2'                                                 00020000
*FINAL ROW AND COLUMN SWITCHS                                           00020100
REVERS   SH    R3,=H'2'                                                 00020200
         LH    R6,1(R3)      J1=ISW(K)                                  00020300
         CR    R6,R5                                                    00020400
         BE    JCOMP                                                    00020500
         LH    R1,ARG2                                                  00020600
         SH    R1,ROWL                                                  00020700
         LR    R2,R1                                                    00020800
         LR    R4,R5                                                    00020900
WLOOP    AH    R2,ROWL     KTH ROW                                      00021000
         BCTB  R4,WLOOP                                                 00021100
XLOOP    AH    R1,ROWL     I1TH ROW                                     00021200
         BCTB  R6,XLOOP                                                 00021300
         LH   R7,ARG5                                                   00021400
X2LOOP   LED   F0,0(R7,R2)   A(K,J)                                     00021500
         LED   F2,0(R7,R1)     A(I1,J)                                  00021600
         BZ    FX3            WORKAROUND FOR LECR BUG.                  00021700
         LECR  F2,F2                                                    00021800
FX3      STED  F2,0(R7,R2)   A(K,J)                                     00021900
         STED  F0,0(R7,R1)   A(I1,J)                                    00022000
         BCTB   R7,X2LOOP                                               00022100
JCOMP    LH    R6,0(R3)                                                 00022200
         CR    R6,R5                                                    00022300
         BE    INCR                                                     00022400
         LH    R2,ARG2                                                  00022500
         LH    R7,ARG5                                                  00022600
Y2LOOP   LED   F0,0(R6,R2)   A(I,J1)                                    00022700
         BZ    FX4            WORKAROUND FOR LECR BUG.                  00022800
         LECR  F0,F0                                                    00022900
FX4      LED   F2,0(R5,R2)     A(I,K)                                   00023000
         STED  F2,0(R6,R2)                                              00023100
         STED  F0,0(R5,R2)                                              00023200
         AH    R2,ROWL                                                  00023300
         BCTB  R7,Y2LOOP                                                00023400
INCR     SH    R5,=H'1'                                                 00023500
         BZ    OUT                                                      00023600
         B     REVERS                                                   00023700
OUT      AEXIT                                                          00023800
AOUT     AERROR   27         ERROR:THIS IS A SINGULAR MATRIX            00023900
         LH    R5,ARG5                                                  00024000
         LH    R1,ARG2                                                  00024100
         ABAL MM15DN                                                    00024200
         B     OUT                                                      00024300
         ACLOSE                                                         00024400
