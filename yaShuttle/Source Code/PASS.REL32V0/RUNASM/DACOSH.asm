*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DACOSH.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

  TITLE 'INVERSE HYPER COS FUNCTION (LONG)'                             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
*      ARCCOSH(X)=LN(X+SQRT(X**2-1))                                    00000200
*                                                                       00000300
* IF SQRT(X**2-1) IS INDISTINGUISHABLE FROM X TO DOUBLE PRECISION,      00000400
* LN(X)+LN(2) IS CALCULATED.  IF X IS LESS THAN ONE, AN ERROR IS        00000500
* SIGNALED.  OTHERWISE, THE LOG AND SQRT SUBROUTINES ARE USED AS        00000600
* INDICATED.  X**2-1 IS COMPUTED AS (X+1)*(X-1) TO AVOID LOSS OF        00000700
* SIGNIFICANT DIGITS IN THE CALCULATION.                                00000800
*                                                                       00000900
* REVISION HISTORY                                                      00002703
*                                                                       00002803
*DR101156  1/26/89  R. HANDLEY                                          00003203
*     CHECK FOR AN EPSILON VALUE. IF 1-EPSILON<=ARGUMENT<=1 THEN        00003303
*     DON'T PRODUCE ERROR, BUT RETURN FIXUP VALUE.                      00003403
*     IF ARGUMENT<1-EPSILON THEN PRODUCE ERROR AND RETURN FIXUP         00003503
*     VALUE. EPSILON IS A DOUBLEWORD WITH THE LAST HALFWORD CONTAINING  00003603
*     ALL ONES.                                                         00003703
*                                                                       00003803
*DR103795  2/22/93  P. ANSLEY  -   INTERMETRICS                         00016303
*     INCREASED EPSILON VALUE TO HANDLE ARGUMENTS BETWEEN
*     -1 AND 1 ACCURATE TO DOUBLE PRECISION REQUIREMENTS.
*
          MACRO                                                         00016500
          WORKAREA                                                      00016600
BUFF      DS         D                                                  00016700
          MEND                                                          00016800
DACOSH    AMAIN      ACALL=YES                                          00016900
* COMPUTES HYPERBOLIC ARC-COSINE IN DOUBLE PRECISION                    00017000
         INPUT F0             SCALAR DP                                 00017100
         OUTPUT F0            SCALAR DP                                 00017200
         WORK  F1,F2,F3,F4,F5                                           00017300
          CE         F0,BIG                                             00017400
          BL         NORMAL                                             00017500
          ACALL      DLOG                                               00017600
          AED        F0,LN2                                             00017700
          AEXIT                                                         00017800
NORMAL    LED        F2,ONE                                             00017900
          STED       F0,BUFF                                            00018000
          SEDR       F0,F2                                              00018100
          BM         TESTE                                  DR101156    00018202
          AED        F2,BUFF                                            00018300
          MEDR       F0,F2                                              00018400
          ACALL      DSQRT                                              00018500
          AED        F0,BUFF                                            00018600
          ACALL      DLOG                                               00018700
EXIT      AEXIT                                                         00018800
TESTE     AED        F0,EPSILON                             DR101156    00018902
          BNM        NOTERR                                 DR101156    00019006
         AERROR 59            ARG<1-EPSILON                 DR101156    00019104
NOTERR    SEDR       F0,F0                                  DR101156    00019202
         B     EXIT                                                     00019300
ONE       DC         D'1'                                               00019400
LN2       DC         X'40B17217F7D1CF7B'                                00019500
BIG       DC         X'47400000'                                        00019600
EPSILON   DC         X'3AFFFFFFF0000000' /* 5.96046445E-08  DR103795    00019700
          ACLOSE                                                        00020000
