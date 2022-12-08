*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1T3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1T3--VECTOR MOVE, LENGTH 3, DP TO SP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1T3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 IS A DOUBLE PRECISION 3 VECTOR AND V2 IS       00000400
*   A SINGLE PRECISION 3 VECTOR.                                        00000500
*                                                                       00000600
         INPUT R2             VECTOR(3) DP                              00000700
         OUTPUT R1            VECTOR(3) SP                              00000800
         WORK  F0,F2,F4                                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   SEE ALGORITHM DESCRIPTION IN VV1D3                                  00001200
*                                                                       00001300
         LED   F0,4(R2)                                                 00001400
         LED   F2,8(R2)                                                 00001500
         LED   F4,12(R2)                                                00001600
         STE   F0,2(R1)                                                 00001700
         STE   F2,4(R1)                                                 00001800
         STE   F4,6(R1)                                                 00001900
         AEXIT                                                          00002000
         ACLOSE                                                         00002100
