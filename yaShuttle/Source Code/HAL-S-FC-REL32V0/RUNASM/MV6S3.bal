*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MV6S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MV6S3 -- MATRIX VECTOR MULTIPLY.LENGTH 3,SINGLE PREC'   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MV6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE MATRIX VECTOR PRODUCT:                                 00000400
*                                                                       00000500
*        V(3)=M(3,3) X V1(3)                                            00000600
*                                                                       00000700
*        WHERE  V,M,V1 : SP                                             00000800
*                                                                       00000900
         INPUT R2,            MATRIX(3,3)  SP                          X00001000
               R3             VECTOR(3)    SP                           00001100
         OUTPUT R1            VECTO(3)    SP                            00001200
         WORK  F0,F2                                                    00001300
*                                                                       00001400
*    ALGORITHM:                                                         00001500
*       DO FOR I=3 TO 1 ;                                               00001600
*         V(I)=M(I,1)V1(1)+M(I,2)V1(2)+M(I,3)V1(3);                     00001700
*       END;                                                            00001800
*    DO LOOP IS UNWOUND TO SAVE REGS AND TIME                           00001900
*                                                                       00002000
MV6S3X   LE    F0,2(R2)      GET M(1,1)                                 00002100
         ME    F0,2(R3)      MULT BY V(1)                               00002200
         LE    F2,4(R2)      GET M(1,2)                                 00002300
         ME    F2,4(R3)      MULT BYV(2)                                00002400
         AER   F0,F2         TEMP SUM                                   00002500
         LE    F2,6(R2)      GET M(1,3)                                 00002600
         ME    F2,6(R3)      MULT BY V(3)                               00002700
         AER   F0,F2         TEMT SUM                                   00002800
         STE   F0,2(R1)      STORE                                      00002900
         LE    F0,8(R2)      REPEAT FOR  M(2,1)  ETC.                   00003000
         ME    F0,2(R3)                                                 00003100
         LE    F2,10(R2)                                                00003200
         ME    F2,4(R3)                                                 00003300
         AER   F0,F2                                                    00003400
         LE    F2,12(R2)                                                00003500
         ME    F2,6(R3)                                                 00003600
         AER   F0,F2                                                    00003700
         STE   F0,4(R1)                                                 00003800
         LE    F0,14(R2)     REPEAT FOR  M(3,1)  ETC.                   00003900
         ME    F0,2(R3)                                                 00004000
         LE    F2,16(R2)                                                00004100
         ME    F2,4(R3)                                                 00004200
         AER   F0,F2                                                    00004300
         LE    F2,18(R2)                                                00004400
         ME    F2,6(R3)                                                 00004500
         AER   F0,F2                                                    00004600
         STE   F0,6(R1)                                                 00004700
         AEXIT                                                          00004800
         ACLOSE                                                         00004900
