*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV7S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'VV7S3--VECTOR NEGATE,LENGTH3,SINGLE PREC'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV7S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  GENERATES NEGATIVE VECTOR :                                          00000400
*                                                                       00000500
*   V(3) = -V1(3)                                                       00000600
*                                                                       00000700
*   WHERE   V,V1  ARE SP                                                00000800
*                                                                       00000900
         INPUT R2             VECTOR(3)  SP                             00001000
         OUTPUT R1            VECTOR(3)  SP                             00001100
         WORK  F0,F2,F4                                                 00001200
*                                                                       00001300
*   ALGORITHM                                                           00001400
*                                                                       00001500
*   V = (-V1(1),-V1(2),-V1(3))                                          00001600
*                                                                       00001700
         LE    F0,2(R2)      GET V1(1).                                 00001800
         BZ    FX1            WORKAROUND FOR LECR BUG.                  00001900
         LECR  F0,F0          COMPLEMENT ELEMENT.                       00002000
FX1      LE    F2,4(R2)       GET V1(2).                                00002100
         BZ    FX2            WORKAROUND FOR LECR BUG.                  00002200
         LECR  F2,F2          COMPLEMENT ELEMENT.                       00002300
FX2      LE    F4,6(R2)       GET V1(3).                                00002400
         BZ    FX3            WORKAROUND FOR LECR BUG.                  00002500
         LECR  F4,F4          COMPLEMENT ELEMENT.                       00002600
FX3      STE   F0,2(R1)       STORE V2(1).                              00002700
         STE   F2,4(R1)       STORE V2(2).                              00002800
         STE   F4,6(R1)       STORE V2(3).                              00002900
         AEXIT                                                          00003000
         ACLOSE                                                         00003100
