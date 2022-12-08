*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CSHAPQ.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'CSHAPQ - ARRAYED CHARACTER TO INTEGER, SCALAR SHAPING FUNCTION' 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CSHAPQ   AMAIN ACALL=YES                                                00000200
* INTEGER AND SCALAR SHAPING FUNCTION, CONVERSION FROM CHARACTER ARRAY  00000300
         INPUT R4,            CHARACTER ARRAY(N) POINTER (TO 1ST)      X00000400
               R5,            INTEGER(N) SP                            X00000500
               R6,            TYPE (0-H,1-I,2-E,3-D) OF CONVERSION     X00000600
               R7  WIDTH IN HALFWORDS BETWEEN CHARACTER ARRAY ITEMS     00000700
         OUTPUT R2            PTR TO ARRAYED RESULT (H,I,E,OR D)        00000800
         WORK  R1,R3,F0                                                 00000900
         WORK  F1,F2,F3,F4,F5 DUE TO ACALLS                             00001000
*                                                                       00001100
         LA    R1,TABLE                                                 00001200
         USING TABLE,R1                                                 00001300
         LH    R3,TABLE(R6)   GET ADDRESS OF SUBROUTINE                 00001400
         DROP  R1                                                       00001500
         LR    R1,R2          SAVE PTR TO RESULT ARRAY                  00001600
         LR    R2,R4          COPY PTR TO CHAR ARRAY FOR CTO? INPUT     00001700
         LR    R6,R5          COPY COUNT TO SAFE REG                    00001800
         BR    R3             GO TO SUBROUTINE                          00001900
*                                                                       00002000
CTOHX    ACALL CTOH           CONVERT TO HALFWORD INTEGER               00002100
         STH   R5,0(R1)       SAVE ANSWER                               00002200
         LA    R1,1(R1)       BUMP OUTPUT PTR                           00002300
         AR    R2,R7          BUMP INPUT CHARACTER PTR                  00002400
         BCTR  R6,R3          LOOP TILL DONE                            00002500
         AEXIT                                                          00002600
*                                                                       00002700
CTOIX    ACALL CTOI           CONVERT TO FULLWORD                       00002800
         ST    R5,0(R1)       SAVE ANSWER                               00002900
         LA    R1,2(R1)       BUMP OUTPUT PTR                           00003000
         AR    R2,R7          BUMP INPUT CHARACTER ARRAY POINTER        00003100
         BCTR  R6,R3          LOOP TILL DONE                            00003200
         AEXIT                                                          00003300
*                                                                       00003400
CTOEX    ACALL CTOE           CONVERT TO FULLWORD SCALAR                00003500
         STE   F0,0(R1)       SAVE ANSWER                               00003600
         LA    R1,2(R1)       BUMP OUTPUT PTR                           00003700
         AR    R2,R7          BUMP INPUT CHARACTER ARRAY POINTER        00003800
         BCTR  R6,R3          LOOP TILL DONE                            00003900
         AEXIT                                                          00004000
*                                                                       00004100
CTODX    ACALL CTOD           CONVERT TO DOUBLE SCALAR                  00004200
         STED  F0,0(R1)       SAVE ANSWER                               00004300
         LA    R1,4(R1)       BUMP OUTPUT PTR                           00004400
         AR    R2,R7          BUMP INPUT CHARACTER ARRAY POINTER        00004500
         BCTR  R6,R3          LOOP TILL DONE                            00004600
         AEXIT                                                          00004700
*                                                                       00004800
         ADATA                                                          00004900
TABLE    DC    Y(CTOHX)                                                 00005000
         DC    Y(CTOIX)                                                 00005100
         DC    Y(CTOEX)                                                 00005200
         DC    Y(CTODX)                                                 00005300
         ACLOSE                                                         00005400
