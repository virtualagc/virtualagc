*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VM6D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VM6D3--VECTOR X MATRIX,LENGTH 3,DOUBLE PREC'           00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VM6D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE VECTOR MATRIX PRODUCT:                                 00000400
*                                                                       00000500
*       V(3)=V1(3) X M(3,3)                                             00000600
*                                                                       00000700
*       WHERE V,V1,M ARE DP                                             00000800
*                                                                       00000900
         INPUT R3,            MATRIX(3,3)  DP                          X00001000
               R2             VECTOR(3)    DP                           00001100
         OUTPUT R1            VECTOR(3)   DP                            00001200
         WORK  R5,F0,F2,F4,F1,F3,F5                                     00001300
*                                                                       00001400
*     ALGORITHM:                                                        00001500
*                                                                       00001600
*     DO I=1 TO 3;                                                      00001700
*       V(I)=V1(1)*M(1,I)+V1(2)*M(2,I)+V1(3)*M(3,I);                    00001800
*     END;                                                              00001900
*                                                                       00002000
         LFXI  R5,3           R5=3                                      00002100
LOOP     LE    F0,4(R3)       GET 1 ST. V1 ELE.                         00002200
         LE    F1,6(R3)                                                 00002300
         LE    F2,16(R3)       GET 2 ND. V1 ELE                         00002400
         LE    F3,18(R3)                                                00002500
         LE    F4,28(R3)      GET 3 RD. V1 ELE.                         00002600
         LE    F5,30(R3)                                                00002700
         MED   F0,4(R2)       MUL V1(1)*M(1,I)                          00002800
         MED   F2,8(R2)      MUL V1(2)*M(2,I)                           00002900
         AEDR  F2,F0           TEMP SUM                                 00003000
         MED   F4,12(R2)      MUL V1(3)*M(3,I)                          00003100
         AEDR  F2,F4          GET V ELE.                                00003200
         STED  F2,4(R1)       PLACE V ELE.                              00003300
         LA    R1,4(R1)      BUMP V PTR BY 4                            00003400
         LA    R3,4(R3)       BUMP M PTR TO NEXT COL                    00003500
         BCTB  R5,LOOP        I=1 TO 3 COUNTER                          00003600
         AEXIT                                                          00003700
         ACLOSE                                                         00003800
