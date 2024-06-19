*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1D3--VECTOR MOVE, LENGTH 3, DP'                       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 AND V2 ARE DOUBLE PRECISION 3-VECTORS.         00000400
*                                                                       00000500
         INPUT R2             VECTOR(3) DP                              00000600
         OUTPUT R1            VECTOR(3) DP                              00000700
         WORK  F0,F2,F4                                                 00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   V2$(1) = V1$(1);                                                    00001100
*   V2$(2) = V1$(2);                                                    00001200
*   V2$(3) = V1$(2);                                                    00001300
*                                                                       00001400
         LED   F0,4(R2)                                                 00001500
         LED   F2,8(R2)                                                 00001600
         LED   F4,12(R2)                                                00001700
         STED  F0,4(R1)                                                 00001800
         STED  F2,8(R1)                                                 00001900
         STED  F4,12(R1)                                                00002000
         AEXIT                                                          00002100
         ACLOSE                                                         00002200
