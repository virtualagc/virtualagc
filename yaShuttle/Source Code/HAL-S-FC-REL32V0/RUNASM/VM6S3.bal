*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VM6S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VM6S3 -- VECTOR MATRIX MULTIPLY,LENGTH 3,SINGLEPREC'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VM6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*     COMPUTES THE VECTOR MATRIX PRODUCT:                               00000400
*                                                                       00000500
*       V(3)=V1(3) X M(3,3)                                             00000600
*                                                                       00000700
*       WHERE  V,V1,M ARE SP                                            00000800
*                                                                       00000900
         INPUT R3,            MATRIX(3,3)  SP                          X00001000
               R2             VECTOR(3)    SP                           00001100
         OUTPUT R1            VECTOR(3)    SP                           00001200
         WORK  R5,F0,F2                                                 00001300
*                                                                       00001400
*   ALGORITHM:                                                          00001500
*    DO FOR I=1 TO 3 ;                                                  00001600
*     V(I)=V1(1)M(1,I)+V1(2)M(2,I)+V1(3)M(3,I);                         00001700
*     END;                                                              00001800
*                                                                       00001900
         LFXI  R5,3           R5=3                                      00002000
LOOP     LE    F0,2(R2)       GET 1 ST' V1 ELE.                         00002100
         LE    F2,4(R2)       GET 2 ND' V1 ELE.                         00002200
         ME    F0,2(R3)       MUL BY M(1,I)                             00002300
         ME    F2,8(R3)       MUL BY M(2,I)                             00002400
         AEDR  F0,F2          TEMP SUM                                  00002500
         LE    F2,6(R2)       GET 3 RD' ELE.                            00002600
         ME    F2,14(R3)      MUL BY M(3,I)                             00002700
         AEDR  F0,F2          GET V(I) ELE.                             00002800
         STE   F0,2(R1)       PLACE V ELE.                              00002900
         LA    R1,2(R1)       BUMP V PTR BY 2                           00003000
         LA    R3,2(R3)       BUMP M PTR TO NEXT COL                    00003100
         BCTB  R5,LOOP        I=1 TO 3 COUNTER                          00003200
         AEXIT                                                          00003300
         ACLOSE                                                         00003400
