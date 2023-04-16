*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV7D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VV7D3--VECTOR NEGATE,LENGTH 3,DOUBLE PREC'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV7D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   GENERATES THE NEGATIVE VECTOR :                                     00000400
*                                                                       00000500
*     V(3) = -V1(3)                                                     00000600
*                                                                       00000700
*  WHERE V V1 ARE DP                                                    00000800
*                                                                       00000900
         INPUT R2             VECTOR(3)  DP                             00001000
         OUTPUT R1            VECTOR(3)  DP                             00001100
         WORK  F0,F2,F4                                                 00001200
*                                                                       00001300
* ALGORITHM :                                                           00001400
* V = (-V1(1),-V1(2),-V1(3))                                            00001500
*                                                                       00001600
         LED   F0,4(R2)      GET V1(1).                                 00001700
         BZ    FX1            WORKAROUND FOR LECR BUG.                  00001800
         LECR  F0,F0          COMPLEMENT.                               00001900
FX1      LED   F2,8(R2)       GET V1(2).                                00002000
         BZ    FX2            WORKAROUND FOR LECR BUG.                  00002100
         LECR  F2,F2          COMPLEMENT.                               00002200
FX2      LED   F4,12(R2)      GET V1(3).                                00002300
         BZ    FX3            WORKAROUND FOR LECR BUG.                  00002400
         LECR  F4,F4          COMPLEMENT.                               00002500
FX3      STED  F0,4(R1)       STORE V2(1).                              00002600
         STED  F2,8(R1)       STORE V2(2).                              00002700
         STED  F4,12(R1)      STORE V2(3).                              00002800
         AEXIT                                                          00002900
         ACLOSE                                                         00003000
