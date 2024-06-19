*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1S3--VECTOR MOVE, LENGTH 3, SP'                       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 AND V2 ARE SINGLE PRECISION 3 VECTORS.         00000400
*                                                                       00000500
         INPUT R2             VECTOR(3) SP                              00000600
         OUTPUT R1            VECTOR(3) SP                              00000700
         WORK  F0,F2,F4                                                 00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   SEE ALGORITHM DESCRIPTION IN VV1D3                                  00001100
*                                                                       00001200
         LE    F0,2(R2)                                                 00001300
         LE    F2,4(R2)                                                 00001400
         LE    F4,6(R2)                                                 00001500
         STE   F0,2(R1)                                                 00001600
         STE   F2,4(R1)                                                 00001700
         STE   F4,6(R1)                                                 00001800
         AEXIT                                                          00001900
         ACLOSE                                                         00002000
