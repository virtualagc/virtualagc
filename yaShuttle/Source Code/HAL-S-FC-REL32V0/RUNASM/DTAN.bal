*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DTAN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'DTAN  DOUBLE PRECISION TANGENT'                         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000201
* REVISION HISTORY:                                                     00000301
*                                                                       00000401
*   DATE       NAME  DR/SSCR#   DESCRIPTION                             00000501
*   --------   ----  --------   -------------------------------------   00000601
*   12/16/89   JAC   DR103762   REPLACED QCED/QCEDR MACRO WITH          00000701
*                               CED/CEDR INSTRUCTION                    00000801
*   02/22/93   RSJ   DR108670   REPLACED QDEDR F0,PIOV4 WITH
*                               MED F0,FOUROVPI
*                                                                       00000901
         MACRO                                                          00001000
         WORKAREA                                                       00001100
OCTANT   DS    D                                                        00001200
TEMP     DS    D                                                        00001300
TEST     DS    D                                                        00001400
         MEND                                                           00001500
*                                                                       00001600
DTAN     AMAIN QDED=YES                                                 00001700
* PERFORMS TANGENT(X) IN DOUBLE PRECISION                               00001800
         INPUT F0             SCALAR DP RADIANS                         00001900
         OUTPUT F0            SCALAR DP                                 00002000
         WORK  R5,R6,F1,F2,F3,F4,F5                                     00002100
         SR    R6,R6                                                    00002200
         LED   F4,ONE                                                   00002300
         LED   F2,INIT                                                  00002400
         STED  F2,TEST                                                  00002500
         LER   F0,F0                                                    00002600
         BNM   POS                                                      00002700
         LECR  F0,F0                                                    00002800
         LH    R6,INFINITY+1                                            00002900
*                                                                       00003000
POS      CE    F0,MAX                                                   00003100
         BNL   ERROR1                                                   00003200
         MED   F0,FOUROVPI                                              00003300
         STE   F0,OCTANT                                                00003400
         LFXR  R5,F0                                                    00003500
         NHI   R5,X'FF00'                                               00003600
         STH   R5,TEST                                                  00003700
         CER   F0,F4                                                    00003800
         BNL   NORMAL                                                   00003900
         ZB    OCTANT+3,X'00FF'                                         00004000
         B     JOIN                                                     00004100
*                                                                       00004200
NORMAL   LER   F2,F0                                                    00004300
         LER   F3,F1                                                    00004400
         AED   F2,CH4E                                                  00004500
         STED  F2,OCTANT                                                00004600
         SED   F2,CH4E                                                  00004700
         SEDR  F0,F2          FRACTION IN F0                            00004800
*                                                                       00004900
         TB    OCTANT+3,X'0001'                                         00005000
         BZ    JOIN                                                     00005100
         SEDR  F0,F4          IFF ODD OCTANT, W=1-FRACTION              00005200
*                                                                       00005300
JOIN     LER   F4,F0                                                    00005400
         BNM   WPOS                                                     00005500
         LECR  F4,F4                                                    00005600
WPOS     LER   F5,F1                                                    00005700
         STED  F4,TEMP                                                  00005800
         LED   F2,B3                                                    00005900
         CE    F4,UNFLO                                                 00006000
         BNL   POLY                                                     00006100
         LED   F4,ONE                                                   00006200
         B     SKIP                                                     00006300
POLY     MEDR  F0,F0                                                    00006400
         LER   F4,F0                                                    00006500
         LER   F5,F1                                                    00006600
         AED   F4,A2                                                    00006700
         MEDR  F4,F0                                                    00006800
         AED   F4,A1                                                    00006900
         MEDR  F2,F0                                                    00007000
         AED   F2,B2                                                    00007100
         MEDR  F2,F0                                                    00007200
         AED   F2,B1                                                    00007300
SKIP     MEDR  F2,F0                                                    00007400
         AED   F2,B0                                                    00007500
         MEDR  F0,F4                                                    00007600
         AED   F0,A0                                                    00007700
         LED   F4,TEMP                                                  00007800
         MEDR  F0,F4                                                    00007900
         TB    OCTANT+3,X'0003'                                         00008000
         BM    COTN                                                     00008100
        QDEDR  F0,F2          IF OCTANT IS 0 OR 3(MOD 4),               00008200
         B     SIGN           THE ANSWER IS TAN(W*PI/4)=P(W)/Q(W).      00008300
*                                             /* DR103762 NEXT LINE */  00008401
COTN     CED   F4,TEST        IF OCTANT IS 1 OR 2(MOD 4),               00008501
         BNH   ERROR2         AND IF W IS TOO SMALL, SINGULARITY        00008601
        QDEDR  F2,F0          TROUBLE.  OTHERWISE, THE ANSWER IS        00008701
         LER   F0,F2          COTAN(W*PI/4)=Q(W)/P(W).                  00008800
         LER   F1,F3                                                    00008900
*                                                                       00009000
SIGN     TB    OCTANT+3,X'0002'                                         00009100
         BZ    NXTEST                                                   00009200
         LER   F0,F0          WORKAROUND FOR BUG                        00009300
         BZ    NXTEST         IN LECR INSTRUCTION.                      00009400
         LECR  F0,F0                                                    00009500
*                                                                       00009600
NXTEST   LR    R6,R6                                                    00009700
         BZ    EXIT                                                     00009800
         LER   F0,F0          WORKAROUND FOR BUG                        00009900
         BZ    EXIT           IN LECR INSTRUCTION.                      00010000
         LECR  F0,F0                                                    00010100
*                                                                       00010200
EXIT     AEXIT                                                          00010300
*                                                                       00010400
ERROR1   AERROR 11            |ARG| >= PI*2**50                         00010500
         LED   F0,ONE         STANDARD FIXUP RETURNS 1                  00010600
         B     EXIT                                                     00010700
*                                                                       00010800
ERROR2   AERROR 12            TOO CLOSE TO SINGULARITY                  00010900
         LED   F0,INFINITY                                              00011000
         B     EXIT                                                     00011100
*                                                                       00011200
         DS    0D                                                       00011300
INFINITY DC    X'7FFFFFFFFFFFFFFF' LARGEST NUMBER FOR FIX               00011400
ONE      DC    X'4110000000000000' 1.0                                  00011500
CH4E     DC    X'4E10000000000000'                                      00011600
FOUROVPI DC    X'41145F306DC9C882' 4/PI                                 00011700
A2       DC    X'C325FD4A87357CAF'    -607.8306953515                   00011800
A1       DC    X'44AFFA6393159226'   45050.3889630777                   00011900
A0       DC    X'C58AFDD0A41992D4' -569309.0400634512  +3F IN ABS       00012000
B3       DC    X'422376F171F72282'      35.4646216610                   00012100
B2       DC    X'C41926DBBB1F469B'   -6438.8583240077                   00012200
B1       DC    X'4532644B1E45A133' +206404.6948906228                   00012300
B0       DC    X'C5B0F82C871A3B68' -724866.7829840012                   00012400
INIT     DC    X'0000000000000008' COMPARAND WITHOUT CHARACTERISTIC     00012500
MAX      DC    X'4DC90FDA'          PI*2**50                            00012600
MIN      DC    X'02145F31'          (4/PI)*2**(-252)                    00012700
UNFLO    DC    X'35400000'          2**(-46)                            00012800
         ACLOSE                                                         00013000
