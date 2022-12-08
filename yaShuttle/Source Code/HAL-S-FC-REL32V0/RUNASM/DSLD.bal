*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DSLD.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

    TITLE 'DSLD -- DOUBLE SCALAR SUBBIT LOAD'                           00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
DSLD     AMAIN                                                          00000200
*                                                                       00000300
*  LOADS SPECIFIED BITS OF A SCALAR DP                                  00000400
*                                                                       00000500
*                                                                       00000600
         INPUT R2,            SCALAR  DP                               X00000700
               R5,            INTEGER                                  X00000800
               R6             INTEGER                                   00000900
         OUTPUT R5            BIT STRING                                00001000
         WORK  R3                                                       00001100
*                                                                       00001200
*                                                                       00001300
*                                                                       00001400
*                                                                       00001500
*  GET DOUBLEWORD OPERAND IN R4-R3                                      00001600
*                                                                       00001700
         L     R3,2(R2)                                                 00001800
         L     R2,0(R2)                                                 00001900
*                                                                       00002000
         AHI   R5,X'FFFF'     SHIFT COUNT = FIRST BIT-1                 00002100
         BNM   SHIFTL         GIVE ERROR IF                             00002200
         AERROR 30            FIRST BIT<1.                              00002300
         XR    R5,R5          FIXUP: FIRST BIT=1                        00002400
*                                                                       00002500
SHIFTL   SLDL  R2,0(R5)       SHIFT OFF UNWANTED BITS                   00002600
         AHI   R6,X'FFC0'     -64                                       00002700
         LACR  R6,R6          64-LAST BIT                               00002800
         BNM   SHIFTR         GIVE ERROR IF                             00002900
         AERROR 30            LAST BIT>64.                              00003000
         XR    R6,R6          FIXUP: LAST BIT=64                        00003100
*                                                                       00003200
SHIFTR   AR    R6,R5          64-WIDTH (WIDTH=LAST-FIRST+1)             00003300
         SRDL  R2,0(R6)       RIGHT-JUSTIFY BIT STRING                  00003400
*                                                                       00003500
         ST    R3,ARG5                                                  00003600
EXIT     AEXIT                                                          00003700
         ACLOSE                                                         00003800
