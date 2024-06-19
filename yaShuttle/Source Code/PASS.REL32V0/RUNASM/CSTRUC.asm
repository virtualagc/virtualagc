*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CSTRUC.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'CSTRUC- STRUCTURE COMPARE'                            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CSTRUC   AMAIN  INTSIC=YES                                              00000200
*                                                                       00000300
*   COMPARES TWO STRUCTURES AND RETURNS CONDITION CODE                  00000400
*    ( = OR ^=) AS A RESULT                                             00000500
*                                                                       00000600
         INPUT R2,            STRUCTURE                                X00000700
               R3,            STRUCTURE                                X00000800
               R5             INTEGER  SP                               00000900
         OUTPUT CC            CONDITION CODE                            00001000
         WORK  R6,R4                                                    00001100
*                                                                       00001200
*  ALGORITHM:                                                           00001300
* LOAD AND COMPARE 1/2 WORD                                             00001400
*                                                                       00001500
*                                                                       00001600
*                                                                       00001700
L1       LH    R6,0(R2)   JUST LOAD AND COMPARE 1/2WORDS TIL DONE       00001800
         CH    R6,0(R3)   CONDITION CODE SET HERE                       00001900
         BNE   CPRNEQ                                                   00002000
         LA    R2,1(R2)                                                 00002100
         LA    R3,1(R3)                                                 00002200
         BCTB  R5,L1                                                    00002300
*  IF WE GET HERE, THE STRUCTURES ARE EQUAL                             00002400
*                                                                       00002500
         AEXIT CC=(R5)                                                  00002600
CPRNEQ   AEXIT CC=(R4)                                                  00002700
         ACLOSE                                                         00002800
