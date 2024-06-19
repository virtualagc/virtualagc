*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV9S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV9S3 -- UNIT VECTOR,LENGTH 3, SINGLE PREC'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV9S3    AMAIN                                                          00000200
* RETURNS THE MAGNITUDE OF V1, WHERE V1 IS A SINGLE PREC. 3 VECTOR      00000300
         INPUT R2            VECTOR(3)  SP                              00000400
         OUTPUT F0           SCALAR  SP                                 00000500
         WORK  R1,R6,F2                                                 00000600
* ALGORITHIM                                                            00000700
*  SEE VV9D3                                                            00000800
         LE    F0,2(R2)                                                 00000900
         MER   F0,F0                                                    00001000
         LE    F2,4(R2)                                                 00001100
         MER   F2,F2                                                    00001200
         AER   F0,F2                                                    00001300
         LE    F2,6(R2)                                                 00001400
         MER   F2,F2                                                    00001500
         AER   F0,F2                                                    00001600
         ABAL  SQRT                                                     00001700
         AEXIT                                                          00001800
         ACLOSE                                                         00001900
