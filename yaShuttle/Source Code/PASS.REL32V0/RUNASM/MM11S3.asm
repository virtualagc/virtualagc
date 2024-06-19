*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM11S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MM11S3--MATRIX TRANSPOSE, LENGTH 3, SP'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM11S3   AMAIN  INTSIC=YES                                              00000200
*                                                                       00000300
* TAKE THE TRANSPOSE OF A 3 X 3 SINGLE PRECISION MATRIX                 00000400
*                                                                       00000500
         INPUT  R2           MATRIX(3,3) SP                             00000600
         OUTPUT R1           MATRIX(3,3) SP                             00000700
         WORK   R5,F0,F1,F2                                             00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   SEE ALGORITHM DESCRIPTION IN MM11D3                                 00001100
*                                                                       00001200
         LFXI   R5,1                                                    00001300
         IAL    R5,2                                                    00001400
*                                                                       00001500
* THE ABOVE SETS THE CONTENTS OF R5 TO INDEX || COUNT FOR THE BIX       00001600
*   INSTRUCTION.                                                        00001700
*                                                                       00001800
MM11S3L  LE     F0,2(R2)                                                00001900
         LE     F1,4(R2)                                                00002000
         LE     F2,6(R2)                                                00002100
         STE    F0,0(R5,R1)                                             00002200
         STE    F1,6(R5,R1)                                             00002300
         STE    F2,12(R5,R1)                                            00002400
         LA     R2,6(R2)                                                00002500
         BIX    R5,MM11S3L                                              00002600
         AEXIT                                                          00002700
         ACLOSE                                                         00002800
