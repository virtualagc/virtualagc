*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    BTOC.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

     TITLE 'BTOC -- BIT STRING TO CHARACTER CONVERSION'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000200
BTOC     AMAIN INTSIC=YES                                               00000300
*                                                                       00000400
*  CONVERTS BIT DATA TO CHARACTER DATA                                  00000500
*                                                                       00000600
         INPUT R5,            BIT STRING                               X00000700
               R6             INTEGER(LENG.)                            00000800
         OUTPUT R2            CHARACTER                                 00000900
         WORK  R3,R7,R1,R4                                              00001000
*                                                                       00001100
*                                                                       00001200
*                                                                       00001300
         LR    R1,R4          SAVE RETURN REGISTER                      00001400
*                                                                       00001500
*  STORE BYTE COUNT IN STRING                                           00001600
*                                                                       00001700
         LH    R3,0(R2)                                                 00001800
         NHI   R3,X'FF00'                                               00001900
         AR    R3,R6                                                    00002000
         STH   R3,0(R2)                                                 00002100
*                                                                       00002200
*  SET UP REGISTERS                                                     00002300
*                                                                       00002400
         LACR  R7,R6                                                    00002500
         AHI   R7,32          SHIFT COUNT = 32 - LENGTH                 00002600
         SLL   R5,63          SHIFT OFF UNWANTED BITS                   00002700
         AHI   R6,1                                                     00002800
         SRL   R6,1           HALFWORD COUNT                            00002900
*                                                                       00003000
*  LOOP FOR CONVERSION                                                  00003100
*                                                                       00003200
LOOP     XR    R4,R4                                                    00003300
         LA    R2,1(R2)                                                 00003400
         SLDL  R4,1                                                     00003500
         SLL   R4,7                                                     00003600
         SLDL  R4,1                                                     00003700
         SLL   R4,16                                                    00003800
         AHI   R4,X'3030'                                               00003900
         STH   R4,0(R2)                                                 00004000
         BCT   R6,LOOP                                                  00004100
*                                                                       00004200
EXIT     LR    R4,R1          RECOVER RETURN ADDRESS                    00004300
         AEXIT                                                          00004400
         ACLOSE                                                         00004500
