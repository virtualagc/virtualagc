*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR1DN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR1DN--REMOTE TO REMOTE VECTOR MOVE, DP'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR1DN    AMAIN                                                          00000200
*                                                                       00000300
* MOVE A PARTITION OF OR ALL OF V1 TO A PARTITION OF OR ALL OF V2, OR   00000400
*   A SUCCESSIVELY STORED PARTITION OR ALL OF M1 TO A SUCCESSIVELY      00000500
*   STORED PARTITION OR ALL OF M2, WHERE :                              00000600
*        V1 AND V2 ARE DOUBLE PRECISION VECTORS, AT LEAST ONE OF WHICH  00000700
*          IS REMOTE,                                                   00000800
*        M1 AND M2 ARE DOUBLE PRECISION MATRICES, AT LEAST ONE OF WHICH 00000900
*          IS REMOTE,                                                   00001000
*        AND WHERE THE SOURCE AND RECEIVERS ARE BOTH OF LENGTH N        00001100
*                                                                       00001200
         INPUT R4,            ZCON(VECTOR(N)) DP                       X00001300
               R5             INTEGER(N) SP                             00001400
         OUTPUT R2            ZCON(VECTOR(N)) DP                        00001500
         WORK  F0                                                       00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   DO FOR I = N TO 1 BY -1;                                            00001900
*     V1$(I) = V2$(I);                                                  00002000
*   END;                                                                00002100
*                                                                       00002200
VR1DNX   LED@# F0,ARG4(R5)                                              00002300
         STED@# F0,ARG2(R5)                                             00002400
         BCTB  R5,VR1DNX                                                00002500
         AEXIT                                                          00002600
         ACLOSE                                                         00002700
