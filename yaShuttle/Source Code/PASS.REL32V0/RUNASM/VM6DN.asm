*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VM6DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VM6DN--VECTOR*MATRIX,LENGTH N,DBLE PREC'               00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VM6DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE VECTOR MATRIX PRODUCT:                                 00000400
*                                                                       00000500
*      V(M)=V1(N) X M(N,M)                                              00000600
*                                                                       00000700
*   WHER N NOT= 3  &  V,V1,M : DP                                       00000800
*                                                                       00000900
         INPUT R3,            MATRIX(N,M)  DP                          X00001000
               R2,            VECTOR(N)    DP                          X00001100
               R5,            TNTEGER(N)   SP                          X00001200
               R6             INTEGER(M)   SP                           00001300
         OUTPUT R1            VECTOR(M)     SP                          00001400
         WORK  R7,F0,F2,F3,F4,F5                                        00001500
*                                                                       00001600
*    ALGORITHM:                                                         00001700
*     DO I=1 T0 M;                                                      00001800
*        ACC=0;                                                         00001900
*        DO J=1 T0 O N ;                                                00002000
*        ACC=ACC+V1(J) X M(J,I)                                         00002100
*        END;                                                           00002200
*        V(I) =  ACC ;                                                  00002300
*     END;                                                              00002400
*                                                                       00002500
         LFLR  F5,R5          SAVE N IN F5                              00002600
         LR    R7,R6          PUT M IN R7                               00002700
$TIM1    SLL   R7,2           GET # OF M                                00002800
LOOP1    LFLR  F4,R3          SAVE R3                                   00002900
$TIM2    SEDR  F0,F0          F0=0                                      00003000
LOOP2    LE    F2,4(R3)       GET LEFT HALF OF V1 ELE.                  00003100
         LE    F3,6(R3)       GET RIGHT HALF OF V1 ELE.                 00003200
         MED   F2,4(R2)       MUL.BY M ELE.                             00003300
         AEDR  F0,F2          TEMP SUM                                  00003400
         AR    R3,R7          BUMP M PTR TO NEXT ROW                    00003500
         LA    R2,4(R2)       BUMP V1PTR TO NEXT ELE.                   00003600
$TIM3    BCTB  R5,LOOP2       J=1 TO N COUNTER                          00003700
         STED  F0,4(R1)       PLACE V ELE.                              00003800
         LA    R1,4(R1)       BUMP V PTR BY 4                           00003900
         LFXR  F5,R5          GET BACK R5                               00004000
         SLL   R5,2           GET # COL OF V1                           00004100
         SR    R2,R5          GETBACK R2                                00004200
         SRL   R5,2           GET BACK R5                               00004300
         LFXR  R3,F4          GET BACK R3                               00004400
         LA    R3,4(R3)       GET BACK M COL                            00004500
$TIM4    BCTB  R6,LOOP1       I=1 TO M                                  00004600
         AEXIT                                                          00004700
         ACLOSE                                                         00004800
