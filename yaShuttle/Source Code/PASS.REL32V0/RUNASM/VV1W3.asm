*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV1W3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV1W3--VECTOR MOVE, LENGTH 3, SP TO DP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV1W3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* MOVE V1 TO V2 WHERE V1 IS A SINGLE PRECISION 3 VECTOR AND             00000400
*   WHERE V2 IS A DOUBLE PRECISION 3 VECTOR.                            00000500
*                                                                       00000600
         INPUT R2             VECTOR(3) SP                              00000700
         OUTPUT R1            VECTOR(3) DP                              00000800
         WORK  F0,F1                                                    00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   SEE ALGORITHM DESCRIPTION IN VV1D3                                  00001200
*                                                                       00001300
         SER   F1,F1          CLEAR RIGHT HALF OF F0                    00001400
         LE    F0,2(R2)       GET FIRST INPUT ELEMENT                   00001500
         STED  F0,4(R1)       STORE FIRST ELEMENT                       00001600
         LE    F0,4(R2)       GET SECOND ELEMENT                        00001700
         STED  F0,8(R1)       STORE SECOND ELEMENT                      00001800
         LE    F0,6(R2)       GET THIRD ELEMENT                         00001900
         STED  F0,12(R1)      STORE THIRD ELEMENT                       00002000
         AEXIT                                                          00002100
         ACLOSE                                                         00002200
