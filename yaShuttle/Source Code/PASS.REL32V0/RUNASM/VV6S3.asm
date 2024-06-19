*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV6S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV6S3 -- VECTOR DOT PRODUCT,LENGTH 3,SINGLE PREC'       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  COMPUTES THE DOT PRODUCT:                                            00000400
*                                                                       00000500
*   S= V1(3) . V2(3)                                                    00000600
*                                                                       00000700
*   WHERE S,V1,V2 ARE SP                                                00000800
*                                                                       00000900
         INPUT R2,            VECTOR(3)  SP                            X00001000
               R3             VECTOR(3)  SP                             00001100
         OUTPUT F0            SCALAR     SP                             00001200
         WORK  F2                                                       00001300
*                                                                       00001400
*  ALGORITHM :                                                          00001500
*  S = V1(1)V2(1)+V1(2)V2(2)+V1(3)V2(3)                                 00001600
*                                                                       00001700
VV6S3X   LE    F0,2(R3)        X(1)                                     00001800
         ME    F0,2(R2)        X(1)*Y(1)                                00001900
         LE    F2,4(R3)        X(2)                                     00002000
         ME    F2,4(R2)        Y(2)*X(2)                                00002100
         AEDR   F0,F2             X(1)Y(1)+X(2)Y(2)                     00002200
         LE    F2,6(R3)       X(3)                                      00002300
         ME    F2,6(R2)       X(3)*Y(3)                                 00002400
         AEDR   F0,F2             (X(1)Y(1)+X(2)Y(2))+X(3)Y(3)          00002500
           AEXIT                                                        00002600
         ACLOSE                                                         00002700
