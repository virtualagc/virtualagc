*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR0DNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR0DNP--SCALAR TO REMOTE COLUMN VECTOR MOVE, DP'        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR0DNP   AMAIN                                                          00000200
*                                                                       00000300
* FILLS A COLUMN VECTOR OF LENGTH N OF A DOUBLE PRECISION MATRIX WITH   00000400
*   A PARTICULAR DOUBLE PRECISION SCALAR.                               00000500
*                                                                       00000600
         INPUT R5,            INTEGER(N) SP                            X00000700
               R7,            INTEGER(OUTDEL) SP                       X00000800
               F0             SCALAR DP                                 00000900
         OUTPUT R2            ZCON(VECTOR(N)) DP                        00001000
         WORK  R4                                                       00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   DO FOR I = 1 TO N;                                                  00001400
*     V$(I) = F0;                                                       00001500
*   END;                                                                00001600
*                                                                       00001700
         LFXI  R4,1           PLACE INDEX INTO R4                       00001800
         SRL   R7,2           ADJUST HALFWORDS TO INDEX                 00001900
VR0DNPX  STED@# F0,ARG2(R4)                                             00002000
         AR    R4,R7          BUMP INDEX                                00002100
         BCTB  R5,VR0DNPX                                               00002200
         AEXIT                                                          00002300
         ACLOSE                                                         00002400
