*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM13SN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM13SN--TRACE OF N X N MATRIX, SP'                      00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
MM13SN   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE TRACE OF AN N X N SINGLE PRECISION MATRIX WHERE N           00000400
*   IS NOT EQUAL TO 3.                                                  00000500
*                                                                       00000600
         INPUT R2,            MATRIX(N,N) SP                           X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR SP                                 00000900
         WORK  R6                                                       00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN MM13DN                                 00001300
*                                                                       00001400
         LA    R6,1(R5,3)     PUT N + 1 IN R6                           00001500
         SLL   R6,1           MULTIPLY R6 BY 2                          00001600
         SER   F0,F0                                                    00001700
ADDLOOP  AE    F0,2(R2)                                                 00001800
         AR    R2,R6          BUMP INDEX PTR BY N + 1                   00001900
         BCTB  R5,ADDLOOP                                               00002000
         AEXIT                                                          00002100
         ACLOSE                                                         00002200
