*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV8S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV8S3--VECTOR COMPARISION, LENGTH 3 AND N, SP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV8S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPARISON OF V1 AND V2 WHERE V1 AND V2 ARE SINGLE PRECISION 3        00000400
*   VECTORS.                                                            00000500
*                                                                       00000600
         INPUT R2,            VECTOR(3) SP                             X00000700
               R3             VECTOR(3) SP                              00000800
         OUTPUT CC                                                      00000900
         WORK  R1,R5,F0                                                 00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN VV8D3                                  00001300
*                                                                       00001400
         LFXI  R5,3                                                     00001500
VV8SN    AENTRY                                                         00001600
*                                                                       00001700
* COMPARISON OF V1 AND V2 WHERE V1 AND V2 ARE SINGLE PRECISION VECTORS  00001800
*   OF LENGTH N WHERE N IS NOT EQUAL TO 3                               00001900
*                                                                       00002000
         INPUT R2,            VECTOR(3) SP                             X00002100
               R3,            VECTOR(3) SP                             X00002200
               R5             INTEGER(N) SP                             00002300
         OUTPUT CC                                                      00002400
         WORK  R1,F0                                                    00002500
*                                                                       00002600
* ALGORITHM:                                                            00002700
*   SEE ALGORITHM DESCRIPTION IN VV8DN                                  00002800
*                                                                       00002900
         LR    R1,R3          MORE CONVENIENT FOR ADDRESING             00003000
VV8SNL   LE    F0,0(R5,R2)    GET ELEMENT FROM INPUT                    00003100
         CE    F0,0(R5,R1)    COMPARE WITH CORRESPONDING ELEMENT        00003200
         BNE   VV8SNEQ        IF NOT EQUAL THEN EXIT LOOP               00003300
         BCTB  R5,VV8SNL                                                00003400
VV8SNEQ  AEXIT CC=(R5)                                                  00003500
         ACLOSE                                                         00003600
