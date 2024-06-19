*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM13S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM13S3--TRACE OF 3 X 3 MATRIX, SP'                      00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
MM13S3   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE TRACE OF A 3 X 3 SINGLE PRECISION MATRIX                    00000400
*                                                                       00000500
         INPUT R2             MATRIX(3,3) SP                            00000600
         OUTPUT F0            SCALAR SP                                 00000700
*                                                                       00000800
* ALGORITHM:                                                            00000900
*   SEE ALGORITHM DESCRIPTION IN MM13D3                                 00001000
*                                                                       00001100
         LE    F0,2(R2)       M$(1,1)                                   00001200
         AE    F0,10(R2)      M$(2,2)                                   00001300
         AE    F0,18(R2)      M$(3,3)                                   00001400
         AEXIT                                                          00001500
         ACLOSE                                                         00001600
