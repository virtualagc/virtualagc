*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XTOC.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

     TITLE 'XTOC -- HEX AND OCTAL TO CHARACTER CONVERSION'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000200
XTOC     AMAIN INTSIC=YES                                               00000300
*                                                                       00000400
*   CONVERT BIT STRING TO                                               00000500
*   A STRING OF HEXADECIMAL CHARACTER                                   00000600
*                                                                       00000700
         INPUT R5,            BIT STRING                               X00000800
               R6             INTEGER(LENG.)                            00000900
         OUTPUT R2            CHARACTER                                 00001000
         WORK  R1,R3,R4,R7,F0                                           00001100
*                                                                       00001200
*                                                                       00001300
*                                                                       00001400
         LACR  R3,R6                                                    00001500
         AHI   R3,52          52-LENGTH                                 00001600
         NHI   R3,X'FFFC'     SHIFT COUNT=MULTIPLE OF 4                 00001700
         AHI   R6,3                                                     00001800
         SRL   R6,2           CHAR COUNT=(LENGTH+3)/4                   00001900
         LR    R1,R6          SAVE CHAR COUNT IN R1                     00002000
         LHI   R7,4           HEX SHIFT COUNT                           00002100
         B     COMMON                                                   00002200
*                                                                       00002300
OTOC     AENTRY                                                         00002400
*                                                                       00002500
*  CONVERT BIT STRING TO OCL CHARACTER STRING                           00002600
*                                                                       00002700
         INPUT R5,            BIT STRING                               X00002800
               R6             INTEGER(LENG.)                            00002900
         OUTPUT R2            CHARACTER                                 00003000
         WORK  R1,R3,R4,R7,F0                                           00003100
*                                                                       00003200
*                                                                       00003300
         AHI   R6,2                                                     00003400
         SRL   R6,2                                                     00003500
         D     R6,FX3         CHAR COUNT=(LENGTH+2)/3                   00003600
         LR    R1,R6          SAVE CHAR COUNT IN R1                     00003700
         MIH   R6,FM3                                                   00003800
         LA    R3,51(R6,3)    SHIFT COUNT=51-3*(CHAR COUNT)             00003900
         LHI   R7,3           OCTAL SHIFT COUNT                         00004000
*                                                                       00004100
*  COMMON SECTION HERE                                                  00004200
*                                                                       00004300
COMMON   LA    R6,1(R1)       CHAR COUNT+1                              00004400
         SRL   R6,1           LOOP COUNT=(CHAR COUNT+1)/2               00004500
         LFLR  F0,R4          SAVE RETURN ADDRESS                       00004600
         XR    R4,R4          CLEAR R4 TO RECEIVE STRING                00004700
         SLDL  R4,0(R3)       SHIFT TO FIRST DIGIT POSITION             00004800
*                                                                       00004900
         LH    R3,0(R2)                                                 00005000
         NHI   R3,X'FF00'                                               00005100
         AR    R3,R1                                                    00005200
         STH   R3,0(R2)       STORE CHARACTER STRING LENGTH             00005300
*                                                                       00005400
LOOP     LA    R3,0(R4,3)     DIGIT IN TOP HALF R3.                     00005500
         AHI   R3,X'0030'     IF 9 OR LESS,THEN                         00005600
         CHI   R3,X'003A'     CONVERT TO A NUMERAL.                     00005700
         BL    SECOND         OTHERWISE, CONVERT A                      00005800
         LA    R3,7(R3)       DIGIT TO A LETTER.                        00005900
*                                                                       00006000
SECOND   ZRB   R4,X'FFFF'                                               00006100
         SLDL  R4,0(R7)       SHIFT 3 FOR OCTAL, 4 FOR HEX              00006200
         AHI   R4,X'0030'                                               00006300
         CHI   R4,X'003A'                                               00006400
         BL    STORE          CONVERT TO A LETTER                       00006500
         AHI   R4,7           IF GREATER THAN 9.                        00006600
*                                                                       00006700
STORE    SLL   R3,8           SHIFT TO RECEIVE SECOND DIGIT             00006800
         AR    R3,R4                                                    00006900
         STH   R3,1(R2)       STORE DIGITS IN STRING                    00007000
         LA    R2,1(R2)       INCREMENT POINTER                         00007100
         ZRB   R4,X'FFFF'     ZERO TOP HALF R4                          00007200
         SLDL  R4,0(R7)       SHIFT 3 FOR OCTAL, 4 FOR HEX              00007300
         BCT   R6,LOOP                                                  00007400
*                                                                       00007500
EXIT     LFXR  R4,F0          RESTORE RETURN ADDRESS                    00007600
         AEXIT                AND EXIT                                  00007700
*                                                                       00007800
         DS    0F                                                       00007900
FX3      DC    X'60000000'    0.75                                      00008000
FM3      DC    H'-3'                                                    00008100
         ACLOSE                                                         00008200
