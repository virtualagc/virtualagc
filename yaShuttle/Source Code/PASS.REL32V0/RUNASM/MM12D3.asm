*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM12D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM12D3--DETERMINANT OF A 3 X 3 MATRIX, DP'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
MM12D3   AMAIN                                                          00000200
*                                                                       00000300
* TAKES THE DETERMINANT OF A 3 X 3 DOUBLE PRECISION MATRIX              00000400
*                                                                       00000500
         INPUT R2             MATRIX(3,3) DP                            00000600
         OUTPUT F0            SCALAR DP                                 00000700
         WORK  F2,F4                                                    00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   SEE ALGORITHM DESCRIPTION IN MM12S3                                 00001100
*                                                                       00001200
         LED   F0,4(R2)                                                 00001300
         MED   F0,20(R2)                                                00001400
         MED   F0,36(R2)      M$(1,1) * M$(2,2) * M$(3,3)               00001500
         LED   F2,8(R2)                                                 00001600
         MED   F2,24(R2)                                                00001700
         MED   F2,28(R2)      M$(1,2) * M$(2,3) * M$(3,1)               00001800
         LED   F4,12(R2)                                                00001900
         MED   F4,16(R2)                                                00002000
         MED   F4,32(R2)      M$(1,3) * M$(2,1) * M$(3,2)               00002100
         AEDR  F0,F2                                                    00002200
         AEDR  F0,F4                                                    00002300
         LED   F2,28(R2)                                                00002400
         MED   F2,20(R2)                                                00002500
         MED   F2,12(R2)      M$(3,1) * M$(2,2) * M$(3,1)               00002600
         LED   F4,32(R2)                                                00002700
         MED   F4,24(R2)                                                00002800
         MED   F4,4(R2)       M$(3,2) * M$(2,3) * M$(1,1)               00002900
         SEDR  F0,F2                                                    00003000
         SEDR  F0,F4                                                    00003100
         LED   F2,36(R2)                                                00003200
         MED   F2,16(R2)                                                00003300
         MED   F2,8(R2)       M$(3,3) * M$(2,1) * M$(2,1)               00003400
         SEDR  F0,F2                                                    00003500
         AEXIT                                                          00003600
         ACLOSE                                                         00003700
