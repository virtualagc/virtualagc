*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ITOC.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

   TITLE 'ITOC -- INTERNAL INTEGER TO CHARACTER CONVERSION'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
ARG      DS    F                                                        00000400
CHARSTR  DS    8H                                                       00000500
         MEND                                                           00000600
*                                                                       00000700
ITOC     AMAIN                                                          00000800
*                                                                       00000900
*  CONVERTS INTEGER DP TO CHARACTER                                     00001000
*                                                                       00001100
         INPUT R5             INTEGER  DP                               00001200
         OUTPUT R2            CHARACTER                                 00001300
         WORK  R1,R3,R4,R6                                              00001400
*                                                                       00001500
*                                                                       00001600
*                                                                       00001700
         B     MERGE                                                    00001800
*                                                                       00001900
HTOC     AENTRY                                                         00002000
*                                                                       00002100
*  CONVERT INTEGER SP TO CHARACTER                                      00002200
*                                                                       00002300
         INPUT R5             INTEGER  SP                               00002400
         OUTPUT R2            CHARACTER                                 00002500
         WORK  R1,R3,R4,R6                                              00002600
*                                                                       00002700
*                                                                       00002800
*                                                                       00002900
         SRA   R5,16                                                    00003000
*                                                                       00003100
MERGE    ST    R5,ARG                                                   00003200
         LR    R6,R5                                                    00003300
         BNM   GETADR                                                   00003400
         LACR  R6,R6                                                    00003500
GETADR   LA    R5,CHARSTR+7                                             00003600
         LR    R1,R6                                                    00003700
POSINT   SRDL  R6,4                                                     00003800
         D     R6,TEN                                                   00003900
         LR    R3,R6          X/10 IN R3                                00004000
         M     R6,TEN                                                   00004100
         SLDL  R6,4                                                     00004200
         SR    R1,R6          GET DIGIT                                 00004300
         SLL   R1,16                                                    00004400
         LR    R4,R1          LOW DIGIT IN R4                           00004500
*  END OF FIRST CYCLE                                                   00004600
         LR    R6,R3                                                    00004700
         BZ    ENDTRAN1                                                 00004800
         LR    R1,R3                                                    00004900
         SRDL  R6,4                                                     00005000
         D     R6,TEN                                                   00005100
         LR    R3,R6                                                    00005200
         M     R6,TEN                                                   00005300
         SLDL  R6,4                                                     00005400
         SR    R1,R6                                                    00005500
         SLL   R1,24                                                    00005600
         AHI   R1,X'3030'                                               00005700
         AR    R4,R1                                                    00005800
         LR    R6,R3                                                    00005900
         BZ    ENDTRAN2                                                 00006000
         STH   R4,0(R5,3)                                               00006100
         LR    R1,R3                                                    00006200
         BCT   R5,POSINT                                                00006300
*                                                                       00006400
*  GET SIGN AND ALIGN CHARACTER STRING                                  00006500
*                                                                       00006600
ENDTRAN1 TB    ARG,X'8000'                                              00006700
         BO    MINUS1         CORRECTLY ALIGNED IF NEGATIVE             00006800
         AHI   R4,X'0030'                                               00006900
         AHI   R5,1                                                     00007000
         B     PLUS2                                                    00007100
*                                                                       00007200
MINUS1   AHI   R4,X'2D30'                                               00007300
STORE1   STH   R4,1(R2)                                                 00007400
* PUT IN LENGTH                                                         00007500
         LA    R3,CHARSTR+8                                             00007600
         SR    R3,R5                                                    00007700
         SLL   R3,1           BYTE LENGTH                               00007800
         LH    R6,0(R2)                                                 00007900
         NHI   R6,X'FF00'                                               00008000
         AR    R6,R3                                                    00008100
         STH   R6,0(R2)                                                 00008200
         SRL   R3,1           HALFWORD COUNT                            00008300
PLOOP1   BCT   R3,CONT                                                  00008400
         B     EXIT                                                     00008500
CONT     LA    R2,1(R2)                                                 00008600
         LA    R5,1(R5,3)                                               00008700
         LH    R4,0(R5,3)                                               00008800
         STH   R4,1(R2)                                                 00008900
         B     PLOOP1                                                   00009000
*                                                                       00009100
* OFFSET BY ONE BYTE                                                    00009200
*                                                                       00009300
ENDTRAN2 TB    ARG,X'8000'                                              00009400
         BZ    STORE1         CORRECTLY ALIGNED IF NOT NEGATIVE         00009500
         STH   R4,0(R5,3)                                               00009600
         LHI   R4,X'002D'                                               00009700
* PUT IN LENGTH                                                         00009800
PLUS2    LA    R3,CHARSTR+8                                             00009900
         SR    R3,R5                                                    00010000
         SLL   R3,1                                                     00010100
         LA    R3,1(R3)       LENGTH IN BYTES                           00010200
         LH    R6,0(R2)                                                 00010300
         NHI   R6,X'FF00'                                               00010400
         AR    R6,R3                                                    00010500
         STH   R6,0(R2)                                                 00010600
         LA    R3,1(R3)                                                 00010700
         SRL   R3,1           REMAINING HALFWORD COUNT                  00010800
*                                                                       00010900
PLOOP2   IHL   R4,0(R5,3)                                               00011000
         SLL   R4,8                                                     00011100
         STH   R4,1(R2)                                                 00011200
         SLL   R4,8                                                     00011300
         LA    R2,1(R2)                                                 00011400
         LA    R5,1(R5,3)                                               00011500
         BCT   R3,PLOOP2                                                00011600
*                                                                       00011700
EXIT     AEXIT                                                          00011800
*                                                                       00011900
TEN      DC    F'0.625'                                                 00012000
         ACLOSE                                                         00012100
