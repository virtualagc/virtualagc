*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DASINH.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE    'DASINH-- ARCSINCH,DOUBLE PRECISION'                  00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*                                                                       00000200
*     ARCSINCH(X)=LN(X+SQRT(X**2+1))                                    00000300
*                                                                       00000400
* THE FUNCTION IS MADE ODD BY COMPUTING IT FOR A POSITIVE ARGUMENT,     00000500
* THEN CHANGING THE SIGN OF THE RESULT IF THE ARGUMENT IS NEGATIVE.     00000600
* IF ABS(X) IS SO SMALL THAT THE NEXT TERM IN THE TAYLOR SERIES FOR     00000700
* ARCSINH(X) WILL NOT CHANGE THE RESULT, X IS RETURNED. FOR LARGER      00000800
* ABS(X) THE TAYLOR SERIES IS CALCULATED UNTIL THE EXPONENT OF THE      00000900
* ARGUMENT BECOMES LARGE ENOUGH TO MAKE THE STRAIGHTFORWARD USE OF      00001000
*        THE LOG AND SQRT SUBROUTINES GIVE ACCURATE RESULTS. FOR ABS(X) 00001100
* SO LARGE THAT SQRT(X**2+1) IS INDISTINQUISHABLE FROM X TO DOUBLE      00001200
* PRECISION, LN(X)+LN(2) IS CALCULATED                                  00001300
*                                                                       00001400
         MACRO                                                          00001500
         WORKAREA                                                       00001600
BUFF     DS    D                                                        00001700
         MEND                                                           00001800
DASINH   AMAIN ACALL=YES                                                00001900
* COMPUTES HYPERBOLIC ARC-SINE IN DOUBLE PRECISION                      00002000
         INPUT F0             SCALAR DP                                 00002100
         OUTPUT F0            SCALAR DP                                 00002200
         WORK  R7,F1,F2,F3,F4,F5                                        00002300
         LFXR  R7,F0                                                    00002400
         LER   F0,F0                                                    00002500
         BNM   POS                                                      00002600
         LECR  F0,F0                                                    00002700
POS      CE    F0,TINY                                                  00002800
         BNH   SIGN                                                     00002900
         CE    F0,BIG                                                   00003000
         BL    REGULAR                                                  00003100
         ACALL DLOG                                                     00003200
         AED   F0,LN2                                                   00003300
         B     SIGN                                                     00003400
REGULAR  CE    F0,SMALL                                                 00003500
         BH    NORMAL                                                   00003600
         LER   F2,F0                                                    00003700
         LER   F3,F1          TAYLOR SERIES:                            00003800
         MEDR  F2,F2          X-(1/2)*X**3/3+(1*3/2*4)*X**5/5           00003900
         LER   F4,F2          -(1*3*5/2*4*6)*X**7/7                     00004000
         LER   F5,F3          +(1*3*5*7/2*4*6*8)*X**9/9                 00004100
         MED   F4,A11         -(1*3*5*7*9/2*4*6*8*10)*X*11/11           00004200
         AED   F4,A9                                                    00004300
         MEDR  F4,F2                                                    00004400
         AED   F4,A7                                                    00004500
         MEDR  F4,F2                                                    00004600
         AED   F4,A5                                                    00004700
         MEDR  F4,F2                                                    00004800
         AED   F4,A3                                                    00004900
         MEDR  F4,F2                                                    00005000
         AED   F4,ONE                                                   00005100
         MEDR  F0,F4                                                    00005200
         B     SIGN                                                     00005300
NORMAL   STED  F0,BUFF                                                  00005400
         MEDR  F0,F0                                                    00005500
         AED   F0,ONE                                                   00005600
         ACALL DSQRT                                                    00005700
         AED   F0,BUFF                                                  00005800
         ACALL DLOG                                                     00005900
SIGN     LR    R7,R7                                                    00006000
         BNM   FIN                                                      00006100
         LER   F0,F0          WORKAROUND FOR BUG                        00006200
         BZ    FIN            IN LECR INSTRUCTION.                      00006300
         LECR  F0,F0                                                    00006400
FIN      AEXIT                                                          00006500
ONE      DC    D'1'                                                     00006600
LN2      DC    X'40B17217F7D1CF7B'                                      00006700
A3       DC    X'C02AAAAAAAAAAAAB'                                      00006800
A5       DC    X'4013333333333333'                                      00006900
A7       DC    X'BFB6DB6DB6DB6DB7'                                      00007000
A9       DC    X'3F7C71C71C71C71C'                                      00007100
A11      DC    X'BF5BA2E8BA2E8BA3'                                      00007200
TINY     DC    X'3A3A25DA'                                              00007300
SMALL    DC    X'40100000'                                              00007400
BIG      DC    X'47400000'                                              00007500
         ACLOSE                                                         00007600
