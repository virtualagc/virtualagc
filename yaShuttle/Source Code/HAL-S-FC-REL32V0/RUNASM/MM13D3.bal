*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM13D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM13D3--TRACE OF 3 X 3 MATRIX, DP'                      00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
MM13D3   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE TRACE OF A 3 X 3 DOUBLE PRECISION MATRIX                    00000400
*                                                                       00000500
         INPUT R2             MATRIX(3,3) DP                            00000600
         OUTPUT F0            SCALAR DP                                 00000700
*                                                                       00000800
* ALGORITHM:                                                            00000900
*   LOADS M$(1,1), ADDS M$(2,2) TO IT, ADDS M$(3,3) TO IT.              00001000
*                                                                       00001100
         LED   F0,4(R2)                                                 00001200
         AED   F0,20(R2)                                                00001300
         AED   F0,36(R2)                                                00001400
         AEXIT                                                          00001500
         ACLOSE                                                         00001600
