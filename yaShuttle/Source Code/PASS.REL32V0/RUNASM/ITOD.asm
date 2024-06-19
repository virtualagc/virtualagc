*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ITOD.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'ITOD - DOUBLE PREC INTEGER TO DOUBLE PREC SCALAR CONVERSION'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
ITOD     AMAIN INTSIC=YES,SECTOR=0                                      00000200
*                                                                       00000300
*   CONVERTS INTEGER DP TO SCALAR DP                                    00000400
*                                                                       00000500
         INPUT R5             INTEGER  DP                               00000600
         OUTPUT F0            SCALAR  DP                                00000700
         WORK  F1                                                       00000800
*                                                                       00000900
*                                                                       00001000
*                                                                       00001100
         LR    R5,R5                                                    00001200
         BM    ITODNEG                                                  00001300
         LE    F0,=X'4E80000000000000'                                  00001400
         LFLR  F1,R5                                                    00001500
         SED   F0,=X'4E80000000000000'                                  00001600
         AEXIT                                                          00001700
ITODNEG  LCR   R5,R5                                                    00001800
         LE    F0,=X'CE80000000000000'                                  00001900
         LFLR  F1,R5                                                    00002000
         SED   F0,=X'CE80000000000000'                                  00002100
         AEXIT                                                          00002200
         ACLOSE                                                         00002300
