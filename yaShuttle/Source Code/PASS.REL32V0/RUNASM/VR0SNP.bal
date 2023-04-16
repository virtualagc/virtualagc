*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VR0SNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VR0SNP--SCALAR TO REMOTE COLUMN VECTOR MOVE, SP'        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
VR0SNP   AMAIN                                                          00000200
*                                                                       00000300
* FILLS A COLUMN VECTOR OF LENGTH N OF A SINGLE PRECISION MATRIX WITH   00000400
*   A PARTICULAR SINGLE PRECISION SCALAR                                00000500
*                                                                       00000600
         INPUT R5,            INTEGER(N) SP                            X00000700
               R7,            INTEGER(OUTDEL) SP                       X00000800
               F0             SCALAR SP                                 00000900
         OUTPUT R2            ZCON(VECTOR(N)) SP                        00001000
         WORK  R4                                                       00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
* SEE ALGORITHM DESCRIPTION IN VR0DNP                                   00001400
*                                                                       00001500
         LFXI  R4,1           PLACE INDEX INTO R4                       00001600
         SRL   R7,1           ADJUST HALFWORDS TO INDEX                 00001700
VR0SNPX  STE@# F0,ARG2(R4)                                              00001800
         AR    R4,R7          BUMP INDEX                                00001900
         BCTB  R5,VR0SNPX                                               00002000
         AEXIT                                                          00002100
         ACLOSE                                                         00002200
