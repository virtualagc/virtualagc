*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ITOE.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'ITOE - DOUBLE PREC INTEGER TO SINGLE PREC SCALAR CONVERSION'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000200
ITOE     AMAIN INTSIC=YES,SECTOR=0                                      00000300
*                                                                       00000400
*  CONVERT INTEGER DP TO SCALAR SP                                      00000500
*                                                                       00000600
         INPUT R5             INTEGER  DP                               00000700
         OUTPUT F0            SCALAR  SP                                00000800
*                                                                       00000900
*                                                                       00001000
*                                                                       00001100
         CVFL  F0,R5                                                    00001200
         ME    F0,=X'45100000'                                          00001300
         AEXIT                                                          00001400
         ACLOSE                                                         00001500
