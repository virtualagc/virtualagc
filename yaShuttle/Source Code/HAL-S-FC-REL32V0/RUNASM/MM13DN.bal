*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM13DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM13DN--TRACE OF N X N MATRIX, DP'                      00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
MM13DN   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE TRACE OF AN N X N DOUBLE PRECISION MATRIX WHERE N IS        00000400
*   NOT EQUAL TO 3.                                                     00000500
*                                                                       00000600
         INPUT R2,            MATRIX(N,N) DP                           X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR DP                                 00000900
         WORK  R6                                                       00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   OBTAIN M$(1,1) AND INCREMENT THRU MATRIX BY N+1 ELEMENTS,           00001300
*     THEREBY CATCHING ALL THE DIAGONAL ELEMENTS OF THE MATRIX.         00001400
*                                                                       00001500
         LA    R6,1(R5,3)     PUT N + 1 IN R6                           00001600
         SLL   R6,2           MULTIPLY N + 1 BY 4                       00001700
         SEDR  F0,F0          CLEAR F0                                  00001800
ADDLOOP  AED   F0,4(R2)                                                 00001900
         AR    R2,R6          BUMP INDEX INTO MATRIX BY N + 1           00002000
         BCTB  R5,ADDLOOP                                               00002100
         AEXIT                                                          00002200
         ACLOSE                                                         00002300
