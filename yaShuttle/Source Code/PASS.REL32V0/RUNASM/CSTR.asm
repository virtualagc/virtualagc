*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CSTR.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CSTR--STRUCTURE COMPARE, REMOTE'                        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
CSTR     AMAIN                                                          00000200
*                                                                       00000300
* COMPARE S1 WITH S2 WHERE S1 AND S2 ARE STRUCTURES OF LENGTH N         00000400
*   HALFWORDS, AT LEAST ONE OF WHICH IS REMOTE.                         00000500
*                                                                       00000600
         INPUT R2,            ZCON(STRUCTURE(S1))                      X00000700
               R4,            ZCON(STRUCTURE(S2))                      X00000800
               R5             INTEGER(N) SP                             00000900
         OUTPUT CC                                                      00001000
         WORK  R3,R6,R7                                                 00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   DO FOR I = 1 TO N;                                                  00001400
*     IF S1 ^= S2 THEN                                                  00001500
*       RETURN CC;                                                      00001600
*     NAME(S1) = NAME(S1) + 1;                                          00001700
*     NAME(X2) = NAME(S2) + 1;                                          00001800
*   END;                                                                00001900
*                                                                       00002000
         LFXI  R7,1           SET R7 TO A 1 (FOR INDEXING PURPOSES)     00002100
         XR    R3,R3          CLEAR R3 (FOR INDEXING PURPOSES)          00002200
L1       LH@#  R6,ARG2(R3)    JUST LOAD AND COMPARE 1/2WORDS TIL DONE   00002300
         CH@#  R6,ARG4(R3)    CONDITION CODE SET HERE                   00002400
         BNE   CPRNEQ         IF NOT EQUAL TO RETURN NE                 00002500
         AR    R3,R7                                                    00002600
         BCTB  R5,L1                                                    00002700
         AEXIT CC=EQ          IF GET HERE THEN EQUAL                    00002800
CPRNEQ   AEXIT CC=NE                                                    00002900
         ACLOSE                                                         00003000
