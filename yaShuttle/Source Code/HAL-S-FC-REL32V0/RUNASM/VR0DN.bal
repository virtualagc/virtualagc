*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR0DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR0DN--SCALAR TO REMOTE VECTOR MOVE, DP'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR0DN    AMAIN                                                          00000200
*                                                                       00000300
* FILLS A V OF LENGTH N, A SUCCESSIVELY STORED PARTITION OF M OF LENGTH 00000400
*   N = R S, OR ALL OF M OF LENGTH N = R S, WITH A PARTICULAR           00000500
*   DOUBLE PRECISION SCALAR, WHERE                                      00000600
*     V IS A REMOTE DOUBLE PRECISION VECTOR,                            00000700
*     M IS A REMOTE DOUBLE PRECISION MATRIX,                            00000800
*     R AND S ARE THE DIMENSIONS OF M OR ITS PARTITION.                 00000900
*                                                                       00001000
         INPUT R5,            INTEGER(N) SP                            X00001100
               F0             SCALAR DP                                 00001200
         OUTPUT R2            ZCON(VECTOR(N)) DP                        00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   DO FOR I = N TO 1 BY -1;                                            00001600
*     V$(I) = F0;                                                       00001700
*   END;                                                                00001800
*                                                                       00001900
VR0DNX   STED@# F0,ARG2(R5)                                             00002000
         BCTB  R5,VR0DNX                                                00002100
         AEXIT                                                          00002200
         ACLOSE                                                         00002300
