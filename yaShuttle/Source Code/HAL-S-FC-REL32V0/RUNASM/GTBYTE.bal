*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    GTBYTE.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'GTBYTE--INTRINSIC USED FOR CHARACTER MANIPULATION'      00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
GTBYTE   AMAIN INTSIC=INTERNAL                                          00000200
*                                                                       00000300
*  FETCHES ONE CHARACTER FROM A CHARACTER STRING. USED FOR CHARACTER    00000400
* MANIPULATION BY OTHER LIBRARY ROUTINES                                00000500
*                                                                       00000600
         INPUT R2             POINTER                                   00000700
         OUTPUT R5            SINGLE CHARACTER                          00000800
         WORK R4,F0                                                     00000900
         LFLR  F0,R4                                                    00001000
         LH    R5,1(R2)                                                 00001100
         L     R4,BYTEDISP                                              00001200
         AR    R2,R4                                                    00001300
         NR    R4,R2                                                    00001400
         LFXR  R4,F0                                                    00001500
         BZ    LOWER                                                    00001600
         SRL   R5,8                                                     00001700
LOWER    NHI   R5,X'00FF'                                               00001800
         AEXIT                                                          00001900
         DS    0F                                                       00002000
BYTEDISP DC    X'00008000'                                              00002100
         ACLOSE                                                         00002200
