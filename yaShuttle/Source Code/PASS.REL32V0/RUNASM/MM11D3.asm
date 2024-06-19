*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM11D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM11D3--MATRIX TRANSPOSE, LENGTH 3, DP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM11D3   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKE THE TRANSPOSE OF A 3 X 3 DOUBLE PRECISION MATRIX                 00000400
*                                                                       00000500
         INPUT R2             MATRIX(3,3) DP                            00000600
         OUTPUT R1            MATRIX(3,3) DP                            00000700
         WORK  R5,F0,F2,F4                                              00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   THIS ROUTINE USES 1 LOOP.                                           00001100
*   EACH ITERATION THROUGH THE LOOP TAKES ROW I OF THE INPUT MATRIX     00001200
*   AND SPRAYS IT THRU COLUMN I OF THE OUTPUT MATRIX FOR 1 <= I <=3.    00001300
*                                                                       00001400
         LA    R5,1                                                     00001500
         IAL   R5,2                                                     00001600
*                                                                       00001700
* THE ABOVE SETS THE CONTENTS OF R5 TO INDEX || COUNT FOR THE BIX       00001800
*   INSTRUCTION.                                                        00001900
*                                                                       00002000
MM11D3L  LED   F0,4(R2)                                                 00002100
         LED   F2,8(R2)                                                 00002200
         LED   F4,12(R2)                                                00002300
         STED  F0,0(R5,R1)                                              00002400
         STED  F2,12(R5,R1)                                             00002500
         STED  F4,24(R5,R1)                                             00002600
         LA    R2,12(R2)                                                00002700
         BIX   R5,MM11D3L                                               00002800
         AEXIT                                                          00002900
         ACLOSE                                                         00003000
