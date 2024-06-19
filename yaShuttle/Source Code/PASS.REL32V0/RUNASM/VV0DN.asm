*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV0DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV0DN -- SCALAR TO VECTOR MOVE,LENGTH N,DOUBLE PREC'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV0DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*     GENERATES A VECTOR(N)  DP                                         00000400
*   ALL OF WHOSE ELE. ARE THE SAME                                      00000500
*                                                                       00000600
         INPUT F0,            SCALAR      DP                           X00000700
               R5             INTEGER(N)  SP                            00000800
         OUTPUT R1            VECTOR(N)   DP                            00000900
*                                                                       00001000
*   ALGORITHM :                                                         00001100
*   DO FOR I=N TO 1                                                     00001200
*     V(I)=S;                                                           00001300
*   END;                                                                00001400
*                                                                       00001500
LOOP     STED  F0,0(R5,R1)    PLACE V ELE.                              00001600
         BCTB  R5,LOOP        I=N TO 1 COUNTER                          00001700
         AEXIT                                                          00001800
         ACLOSE                                                         00001900
