*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ETOH.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'ETOH - SNGL PREC SCALAR TO SNGL PREC INTEGER CONVERSION'        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
ETOH     AMAIN INTSIC=YES,SECTOR=0                                      00000200
*                                                                       00000300
*  CONVERTS SCALAR SP TO INTEGER SP                                     00000400
*                                                                       00000500
         INPUT F0             SCALAR  SP                                00000600
         OUTPUT R5            INTEGER  SP                               00000700
*                                                                       00000800
*                                                                       00000900
*                                                                       00001000
DTOH     AENTRY                                                         00001100
*                                                                       00001200
*                                                                       00001300
*  CONVERTS SCALAR DP TO INTEGER SP                                     00001400
*                                                                       00001500
         INPUT F0             SCALAR  DP                                00001600
         OUTPUT R5            INTEGER  SP                               00001700
*                                                                       00001800
*                                                                       00001900
*                                                                       00002000
CONVERT  CVFX  R5,F0                                                    00002100
         A     R5,=X'00007FFF'                                          00002200
         BC    5,POS                                                    00002300
         A     R5,=X'00000001'                                          00002400
POS      EQU   *                                                        00002500
         NHI   R5,X'FFFF'                                               00002600
         AEXIT                                                          00002700
         ACLOSE                                                         00002800
