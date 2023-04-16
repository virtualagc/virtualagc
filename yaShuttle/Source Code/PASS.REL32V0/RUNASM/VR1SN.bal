*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR1SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR1SN--REMOTE TO REMOTE VECTOR MOVE, SP'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR1SN    AMAIN                                                          00000200
*                                                                       00000300
* MOVE A PARTITION OF OR ALL OF V1 TO A PARTITION OF OR ALL OF V2, OR   00000400
*   A SUCCESIVELY STORED PARTITION OR ALL OF M1 TO A SUCCESSIVELY       00000500
*   STORED PARTITION OR ALL OF M2, WHERE :                              00000600
*        V1 AND V2 ARE SINGLE PRECISION VECTORS, AT LEAST ONE OF WHICH  00000700
*          IS REMOTE,                                                   00000800
*        M1 AND M2 ARE SINGLE PRECISION MATRICES, AT LEAST ONE OF WHICH 00000900
*          IS REMOTE,                                                   00001000
*        AND WHERE THE SOURCE AND RECEIVERS ARE BOTH OF LENGTH N        00001100
*                                                                       00001200
         INPUT R4,            ZCON(VECTOR(N)) SP                       X00001300
               R5             INTEGER(N) SP                             00001400
         OUTPUT R2            ZCON(VECTOR(N)) SP                        00001500
         WORK  F0                                                       00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   SEE ALGORITHM DESCRIPTION IN VR1DN                                  00001900
*                                                                       00002000
VR1SNX   LE@#  F0,ARG4(R5)                                              00002100
         STE@# F0,ARG2(R5)                                              00002200
         BCTB  R5,VR1SNX                                                00002300
         AEXIT                                                          00002400
         ACLOSE                                                         00002500
