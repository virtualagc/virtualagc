*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV10S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV10S3--UNIT VECTOR, LENGTH 3 OR N, SP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG5    DS    F                                                        00000400
R6SAVE   DS    F                                                        00000500
R1SAVE   DS    F                                                        00000600
         MEND                                                           00000700
VV10S3   AMAIN                                                          00000800
*                                                                       00000900
* FINDS THE UNIT VECTOR OF V1 WHERE V1 IS A DOUBLE PRECISION            00001000
*   3 VECTOR.                                                           00001100
*                                                                       00001200
         INPUT R4             VECTOR(3) SP                              00001300
         OUTPUT R2            VECTOR(3) SP                              00001400
         WORK  R1,R5,R6,F0,F2,F4                                        00001500
*                                                                       00001600
* ALGORITHM:                                                            00001700
*   SEE ALGORITHM DESCRIPTION IN VV10D3                                 00001800
*                                                                       00001900
         LA    R5,3                                                     00002000
         B     UNIT                                                     00002100
VV10SN   AENTRY                                                         00002200
*                                                                       00002300
* FINDS THE UNIT VECTOR OF V1 WHERE V1 IS A DOUBLE PRECISION            00002400
*   VECTOR OF LENGTH N WHERE N IS NOT EQUAL TO 3.                       00002500
*                                                                       00002600
         INPUT R4,            VECTOR(N) SP                             X00002700
               R5             INTEGER(N) SP                             00002800
         OUTPUT R2            VECTOR(N) SP                              00002900
         WORK  R1,R6,F0,F2,F4                                           00003000
*                                                                       00003100
* ALGORITHM:                                                            00003200
*   SEE ALGORITHM DESCRIPTION IN VV10DN                                 00003300
*                                                                       00003400
UNIT     LR    R1,R2          MOVE OUTPUT BASE TO R4 FOR                00003500
*                             ADDRESSABILITY PURPOSES                   00003600
         LR    R2,R4                 "          "                       00003700
         ST    R5,TARG5       SAVE FOR AFTER SQRT                       00003800
         BAL   R6,MAG         FIND MAGNITUDE OF V1                      00003900
         L     R5,TARG5       RESET COUNT                               00004000
         LER   F0,F0          SET CONDITION CODE                        00004100
         BZ    AOUT           IF MAGNITUDE = 0 THEN SEND ERROR AND      00004200
*                             PERFORM FIXUP                             00004300
         LH    R2,ARG4        RESET INPUT BASE                          00004400
ULOOP    LE    F2,0(R5,R2)    GET ELEMENT FROM INPUT                    00004500
         DER   F2,F0          DIVIDE ELEMENT BY MAGNITUDE               00004600
         STE   F2,0(R5,R1)    STORE INTO RESULTS                        00004700
         BCTB  R5,ULOOP                                                 00004800
         B     OUT                                                      00004900
VV9SN    AENTRY                                                         00005000
*                                                                       00005100
* RETURNS THE MAGNITUDE OF V1 WHERE V1 IS A SINGLE PRECISION            00005200
*   VECTOR OF LENGTH N WHERE N IS NOT EQUAL TO 3.                       00005300
*                                                                       00005400
         INPUT R2,            VECTOR(N) SP                             X00005500
               R5             INTEGER(N) SP                             00005600
         OUTPUT F0            SCALAR SP                                 00005700
         WORK  R6,F0,F2,F4                                              00005800
*                                                                       00005900
* ALGORITHM:                                                            00006000
*   SEE ALGORITHM DESCRIPTION IN VV9DN                                  00006100
*                                                                       00006200
RMAG     LA    R6,OUT         IF ABVAL CALLED FROM HIGHER LEVEL         00006300
*                             THEN LOAD ADDRESS OF RETURN SEQUENCE      00006400
MAG      SEDR  F0,F0          CLEAR F0                                  00006500
LOOP     LE    F2,0(R5,R2)    GET ELEMENT FROM VECTOR                   00006600
         MER   F2,F2          SQUARE IT                                 00006700
         AEDR  F0,F2          ADD INTO ACCUMULATOR                      00006800
         BCTB  R5,LOOP                                                  00006900
         ST    R6,R6SAVE      SAVE R6 FOR AFTER SQRT                    00007000
         ST    R1,R1SAVE      SAVE R1 FOR AFTER SQRT                    00007100
         ABAL  SQRT           GET SQRT OF ACCUMULATOR                   00007200
         L     R6,R6SAVE      GET RETURN ADDRESS BACK                   00007300
         L     R1,R1SAVE      GET POSSIBLE R1 VECTOR BACK               00007400
         BR    R6             BRANCH TO EITHER RETURN SEQUENCE          00007500
*                             OR BACK TO UNIT                           00007600
AOUT     AERROR    28         VECTOR/MATRIX DIVIDE BY 0                 00007700
         SER   F0,F0          CLEAR F0                                  00007800
         ABAL  VV0SN          SET RESULT TO 0 VECTOR                    00007900
OUT      AEXIT                                                          00008000
         ACLOSE                                                         00008100
