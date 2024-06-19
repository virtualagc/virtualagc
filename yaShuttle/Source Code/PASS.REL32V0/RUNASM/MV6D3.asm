*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MV6D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MV6D3 -- MATRIX*VECTOR,LENGTH 3,DBLE PRECISION'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 00000200
* R2-MATRIX,R3-VECTOR,R1-RESULT '                                       00000300
* MODIFIED SEPT.,1975 TO UNWIND LOOP (BY IBM HOUSTON)                   00000400
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 00000500
MV6D3    AMAIN INTSIC=YES                                               00000600
*     COMPUTE THE MATRIX VECTOR PRODUCT:                                00000700
*                                                                       00000800
*        V(3)=M(3,3)*V1(3)                                              00000900
*                                                                       00001000
         INPUT R2,            MATRIX(3,3) DP                           X00001100
               R3             VECTOR(3) DP                              00001200
         OUTPUT R1            VECTOR(3) DP                              00001300
         WORK  R6,F0,F1,F2,F3                                           00001400
*                                                                       00001500
*      ALGORITHM:                                                       00001600
*                                                                       00001700
*       DO FO I=1 TO 3;                                                 00001800
*         ACC=0;                                                        00001900
*         DO FOR J=1 TO 3;                                              00002000
*          ACC=ACC+M$(I,J)*V1$(J);                                      00002100
*         END;                                                          00002200
*         V$(I)=ACC;                                                    00002300
*       END                                                             00002400
*                                                                       00002500
MV6D3X   LA    R6,3                                                     00002600
LOOP1    LE    F0,4(R3)                                                 00002700
         LE    F1,6(R3)                                                 00002800
         MED   F0,4(R2)                                                 00002900
         LE    F2,8(R3)                                                 00003000
         LE    F3,10(R3)                                                00003100
         MED   F2,8(R2)                                                 00003200
         AEDR  F0,F2                                                    00003300
         LE    F2,12(R3)                                                00003400
         LE    F3,14(R3)                                                00003500
         MED   F2,12(R2)                                                00003600
         AEDR  F0,F2                                                    00003700
         STED  F0,4(R1)                                                 00003800
         LA    R1,4(R1)                                                 00003900
         LA    R2,12(R2)                                                00004000
         BCTB  R6,LOOP1                                                 00004100
         AEXIT                                                          00004200
         ACLOSE                                                         00004300
