*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    ATANH.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'ATANH--ARCTANH,SINGLE PRECISION'                        00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*   ARCTANCH(X)=|X|  FOR  4.1138977E-05 < |X|                           00000200
*   ARCTANCH(X)=1/2*LN((1+X)/(1-X))  FOR  4.1138977E-05 <= |X| <= .1875 00000300
*   ARCTANCH(X)=X+(1/3)X**3+(1/5)X**5  FOR |X| > .1875                  00000400
*                                                                       00000500
* IF ABS(X) IS VERY SMALL, ARCTANH(X) NEARLY EQUALS X. IF IT IS         00000600
* LARGER, THE TAYLOR SERIES FOR ARCTANH(X) IS CALCULATED. FOR           00000700
* STILL LARGER X, THE LOG SUBROUTINE IS USED AS INDICATED. IN THAT      00000800
* CASE, THE FUNCTION IS MADE ODD BY CALCULATING THE FUNCTION FOR        00000900
* POSITIVE X, AND REVERSING THE SIGN OF THE RESULT IF X IS NEGATIVE.    00001000
* IF ABS(X) IS NOT LESS THAN ONE, AN ERROR IS SIGNALED.                 00001100
*                                                                       00001200
* REVISION HISTORY                                                      00001301
* ----------------                                                      00001401
* DATE     NAME  REL   DR NUMBER AND TITLE                              00001501
*                                                                       00001601
* 03/15/91  RAH  23V2  CR11055 RUNTIME LIBRARY CODE COMMENT CHANGES     00001701
*                                                                       00001801
ATANH    AMAIN ACALL=YES                                                00001900
* COMPUTES HYPERBOLIC ARC-TANGENT IN SINGLE PRECISION                   00002000
         INPUT F0             SCALAR SP                                 00002100
         OUTPUT F0            SCALAR SP                                 00002200
         WORK  R5,R6,R7,F1,F2,F3,F4                                     00002300
         LER   F2,F0                                                    00002400
         BNM   POS                                                      00002500
         LECR  F2,F2                                                    00002600
POS      CE    F2,ONE                                                   00002700
         BNL   ERROR                                                    00002800
         CE    F2,TINY   IF SMALLER THAN THIS, THE NEXT TERM IN THE     00002900
         BL    EXIT      TAYLOR SERIES WOULDN'T CHANGE THE RESULT.      00003000
         CE    F2,SMALL  IF NOT SMALLER THAN THIS,POLYNOMIAL ERRORS     00003100
         BH    NORMAL    BECOME LARGER THAN OTHER AVERAGE ERRORS.       00003200
         MER   F2,F2     TAYLOR SERIES IS X+(1/3)X**3+(1/5)X**5.        00003300
         LER   F4,F2                                                    00003400
         MER   F4,F4                                                    00003500
         MER   F2,F0                                                    00003600
         MER   F4,F0                                                    00003700
         ME    F2,THIRD                                                 00003800
         ME    F4,FIFTH                                                 00003900
         AER   F2,F4                                                    00004000
         AER   F0,F2                                                    00004100
         AEXIT                                                          00004200
NORMAL   LFXR  R7,F0                                                    00004300
         LE    F0,ONE                                                   00004400
         LER   F4,F0                                                    00004500
         AER   F0,F2                                                    00004600
         SER   F4,F2                                                    00004700
         DER   F0,F4                                                    00004800
         ACALL LOG                                                      00004900
         DE    F0,TWO                                                   00005000
         LR    R7,R7                                                    00005100
         BNM   EXIT                                                     00005200
         LECR  F0,F0                                                    00005300
EXIT     AEXIT                                                          00005400
ERROR    AERROR 60            1<=|ARG|                                  00005500
         SER   F0,F0                                                    00005600
         AEXIT                                                          00005700
ONE      DC    E'1'                                                     00005800
TWO      DC    E'2'                                                     00005900
SMALL    DC    X'40300000'    .1875                                     00006000
TINY     DC    X'3D2B2329'    4.1138977E-05                             00006100
THIRD    DC    X'40555555'                                              00006200
FIFTH    DC    X'40333333'                                              00006300
         ACLOSE                                                         00007000
