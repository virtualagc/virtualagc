*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MV6SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MV6SN -- MATRIX VECTOR MULTIPLY,LENGTH N,SINGLE PREC'   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MV6SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*       COMPUTES THE MATRIX VECTOR PRODUCT:                             00000400
*                                                                       00000500
*         V(M)=M(M,N) X V1(N)                                           00000600
*                                                                       00000700
*        WHERE  M,N NOT= 3,    M,V,V1 : SP                              00000800
*                                                                       00000900
         INPUT R2,            MATRIX(M,N)  SP                          X00001000
               R3,            VECTOR(N)    SP                          X00001100
               R5,            INTEGER(M)   SP                          X00001200
               R6             INTEGER(N)   SP                           00001300
         OUTPUT R1            VECTOR(M)    SP                           00001400
         WORK  R7,F0,F2,F4                                              00001500
*                                                                       00001600
*   ALGORITHM:                                                          00001700
*        DO FOR I=1 TO M ;                                              00001800
*            ACC=0;                                                     00001900
*            DO FOR J=1 TO N ;                                          00002000
*             ACC=ACC+M(I,J) X V1(J);                                   00002100
*            END;                                                       00002200
*            V(I)=ACC;                                                  00002300
*        END;                                                           00002400
*                                                                       00002500
MV6SNX   LFLR  F4,R6          SAVE N IN F4                              00002600
$TIM1    LR    R7,R3          SAVE VECTOR ADD.                          00002700
LOOP1    SER   F0,F0          F0=0                                      00002800
$TIM2    LFXR  R6,F4          GET BACK N                                00002900
LOOP2    LE    F2,2(R3)       GET V1 ELE.                               00003000
         ME    F2,2(R2)       MUL. BY M ELE.                            00003100
         AEDR  F0,F2          TEMP SUM                                  00003200
         LA    R3,2(R3)                                                 00003300
         LA    R2,2(R2)                                                 00003400
$TIM3    BCTB  R6,LOOP2       J=1 TO N COUNTER                          00003500
         STE   F0,2(R1)       PLACE V ELE.                              00003600
         LA    R1,2(R1)       BUMP V PTR BY 2                           00003700
         LR    R3,R7          GET BACK VECTOR ADD.                      00003800
$TIM4    BCTB  R5,LOOP1       I=1 TO M COUNTER                          00003900
         AEXIT                                                          00004000
         ACLOSE                                                         00004100
