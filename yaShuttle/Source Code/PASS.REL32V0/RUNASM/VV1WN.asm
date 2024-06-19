*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1WN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1WN--VECTOR MOVE, LENGTH N, SP TO DP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1WN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 IS A SINGLE PRECISION VECTOR OF LENGTH         00000400
*   N AND V2 IS A DOUBLE PRECISION VECTOR OF LENGTH N WHERE N           00000500
*   IS NOT EQUAL TO 3.                                                  00000600
*                                                                       00000700
         INPUT R2,            VECTOR(N) SP                             X00000800
               R5             INTEGER(N) SP                             00000900
         OUTPUT R1            VECTOR(N) DP                              00001000
         WORK  F0,F1                                                    00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   SEE ALGORITHM DESCRIPTION IN VV1DN                                  00001400
*                                                                       00001500
         SER   F1,F1          CLEAR RIGHT HALF OF F0                    00001600
         NOPR  R2             A NOP TO ALIGN THE LONG INSTRUCTIONS      00001700
*                             ON EVEN BOUNDARIES                        00001800
SDLOOP   LE    F0,0(R5,R2)    GET INPUT ELEMENT                         00001900
         STED  F0,0(R5,R1)    STORE IN OUTPUT                           00002000
         BCTB  R5,SDLOOP                                                00002100
         AEXIT                                                          00002200
         ACLOSE                                                         00002300
