*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV0SN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV0SN -- SCALAR TO VECTOR MOVE,LENGTH N,SINGLE PREC'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV0SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*     GENERATES A VECTOR(N)  SP                                         00000400
*                                                                       00000500
*    ALL OF WHOSE ELE. ARE THE SAME                                     00000600
*                                                                       00000700
         INPUT F0,            SCALAR      SP                           X00000800
               R5             INTEGER(N)  SP                            00000900
         OUTPUT R1            VECTOR(N)   SP                            00001000
*                                                                       00001100
*   ALGORITHM:                                                          00001200
*     DO FOR I=N TO 1;                                                  00001300
*      V(I)=S;                                                          00001400
*     END;                                                              00001500
*                                                                       00001600
LOOP     STE   F0,0(R5,R1)    PLACE V ELE.                              00001700
         BCTB  R5,LOOP        I=N TO 1 COUNTER                          00001800
         AEXIT                                                          00001900
         ACLOSE                                                         00002000
