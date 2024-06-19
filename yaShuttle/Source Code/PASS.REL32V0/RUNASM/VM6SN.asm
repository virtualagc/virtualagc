*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VM6SN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VM6SN--VECTOR(N) MATRIX(N,M) MUL.  SP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VM6SN    AMAIN INTSIC=YES                                               00000200
**                                                                      00000300
*      COMPUTES THE VECTOE MATRIX PRODUCT :                             00000400
*                                                                       00000500
*        V(M)=V1(N) X M(N,M)                                            00000600
*                                                                       00000700
*      WHERE M,N NOT=3  &  V,V1,M ARE SP                                00000800
*                                                                       00000900
         INPUT R3,            MATRIX(N,M)  SP                          X00001000
               R2,             VECTOR(N)   SP                          X00001100
               R5,            INTEGER(N)   SP                          X00001200
               R6             INTEGER(M)   SP                           00001300
         OUTPUT R1            VECTOR(M)    SP                           00001400
         WORK  R7,F0,F2,F4,F5                                           00001500
*                                                                       00001600
*   ALGORITHM:                                                          00001700
*    DO I=1 TO M                                                        00001800
*      ACC=0;                                                           00001900
*      DO J=1 TO N;                                                     00002000
*         ACC=ACC+V1(J) X M(J,I);                                       00002100
*       END;                                                            00002200
*    V(I)=ACC;                                                          00002300
*   END;                                                                00002400
*                                                                       00002500
         LR    R7,R6                                                    00002600
         SLL   R7,1                                                     00002700
$TIM1    LFLR  F5,R5          SAVE N                                    00002800
LOOP1    SEDR  F0,F0          F0=0                                      00002900
         LFLR  F4,R3         SAVE M ADD.                                00003000
LOOP2    LE    F2,2(R2)       GET V1 ELE.                               00003100
         ME    F2,2(R3)       MUL. BY M ELE.                            00003200
         AEDR  F0,F2          TEMP. SUM                                 00003300
         AR    R3,R7          BUMP MPTR TO NEXT ROW                     00003400
         LA    R2,2(R2)       BUMP V1 PTR TO NEXT ELE.                  00003500
$TIM2    BCTB  R5,LOOP2       J=1 TO N COUNTER                          00003600
         STE   F0,2(R1)      PLACE  V ELE.                              00003700
         LA    R1,2(R1)       BUMP V ELE. BY 2                          00003800
         LFXR  R5,F5          GET BACK N                                00003900
         SR    R2,R5          GET BACK V1 ADD.                          00004000
         SR    R2,R5                                                    00004100
         LFXR  R3,F4          GET BACK M ADD.                           00004200
         LA    R3,2(R3)       BUMP M PTR TO NEXT COL                    00004300
$TIM3    BCTB  R6,LOOP1       I=1 TO M COUNTER                          00004400
         AEXIT                                                          00004500
         ACLOSE                                                         00004600
