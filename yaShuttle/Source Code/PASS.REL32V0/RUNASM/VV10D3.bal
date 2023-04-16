*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV10D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV10D3--UNIT VECTOR, LENGTH 3 OR N, DP'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG5    DS    F                                                        00000400
         MEND                                                           00000500
VV10D3   AMAIN ACALL=YES,QDED=YES                                       00000600
*                                                                       00000700
* FINDS THE UNIT VECTOR OF V1 WHERE V1 IS A DOUBLE PRECISION            00000800
*   3 VECTOR.                                                           00000900
*                                                                       00001000
         INPUT R4             VECTOR(3) DP                              00001100
         OUTPUT R2            VECTOR(3) DP                              00001200
         WORK  R1,R5,R6,F0,F2,F3,F4                                     00001300
*                                                                       00001400
* ALGORITHM:                                                            00001500
*   F0 = ABVAL(V1);                                                     00001600
*   IF F0 = 0 THEN                                                      00001700
*     DO;                                                               00001800
*       SEND ERROR;                                                     00001900
*       RETURN 0_VECTOR;                                                00002000
*     END;                                                              00002100
*   ELSE                                                                00002200
*     DO;                                                               00002300
*       F2 = 1 / F0;                                                    00002400
*       DO FOR I = 3 TO 1 BY -1;                                        00002500
*         RESULTS$(I) = V1$(I) F2;                                      00002600
*       END;                                                            00002700
*     END;                                                              00002800
*                                                                       00002900
         LFXI  R5,3           SET COUNT TO 3                            00003000
         B     UNIT                                                     00003100
VV10DN   AENTRY                                                         00003200
*                                                                       00003300
* FINDS THE UNIT VECTOR OF V1 WHERE V1 IS A DOUBLE PRECISION            00003400
*   VECTOR OF LENGTH N WHERE N IS NOT EQUAL TO 3.                       00003500
*                                                                       00003600
         INPUT R4,            VECTOR(N) DP                             X00003700
               R5             INTEGER(N) SP                             00003800
         OUTPUT R2            VECTOR(N) DP                              00003900
         WORK  R1,R6,F0,F2,F3,F4                                        00004000
*                                                                       00004100
* ALGORITHM:                                                            00004200
*   F0 = ABVAL(V1);                                                     00004300
*   IF F0 = 0 THEN                                                      00004400
*     DO;                                                               00004500
*       SEND ERROR;                                                     00004600
*       RETURN 0_VECTOR;                                                00004700
*     END;                                                              00004800
*   ELSE                                                                00004900
*     DO;                                                               00005000
*       F2 = 1 / F0;                                                    00005100
*       DO FOR I = N TO 1 BY -1;                                        00005200
*         RESULTS$(I) = V1$(I) F2;                                      00005300
*       END;                                                            00005400
*     END;                                                              00005500
*                                                                       00005600
UNIT     LR    R1,R2          PUT BASE OF OUTPUT IN R1 FOR              00005700
*                             ADDRESSING PURPOSES                       00005800
         LR    R2,R4               "        "                           00005900
         ST    R5,TARG5       STORE COUNT IN STACK                      00006000
         BAL   R6,MAG         FIND THE MAGNITUDE OF V1                  00006100
         L     R5,TARG5       RELOAD NUMBER OF ELEMENTS                 00006200
         SER   F3,F3          CLEAR RIGHT HALF OF F2                    00006300
         LER   F0,F0          SET CONDITION CODE                        00006400
         BZ    AOUT           IF ZERO THEN SEND ERROR AND PERFORM FIX   00006500
         LH    R2,ARG4        RELOAD INPUT BASE                         00006600
         LFLI  F2,1           SET F2 TO 1                               00006700
        QDEDR  F2,F0          TAKE 1 / MAGNITUDE                        00006800
ULOOP    LED   F0,0(R5,R2)    GET ELEMENT FROM INPUT                    00006900
         MEDR  F0,F2          MULTIPLY BY 1 / MAGNITUDE                 00007000
         STED  F0,0(R5,R1)    STORE IN RESULT VECTOR                    00007100
         BCTB  R5,ULOOP                                                 00007200
         B     OUT                                                      00007300
VV9D3    AENTRY                                                         00007400
*                                                                       00007500
* RETURNS THE MAGNITUDE OF V1 WHERE V1 IS A DOUBLE PRECISION            00007600
*   3 VECTOR.                                                           00007700
*                                                                       00007800
         INPUT R2             VECTOR(3) DP                              00007900
         OUTPUT F0            SCALAR DP                                 00008000
         WORK  R5,R6,F2,F4                                              00008100
*                                                                       00008200
* ALGORITHM:                                                            00008300
*   F0 = 0;                                                             00008400
*   DO FOR I = 3 TO 1 BY -1;                                            00008500
*     F0 = F0 + V1$(I) ** 2;                                            00008600
*   END;                                                                00008700
*   F0 = SQRT(F0);                                                      00008800
*                                                                       00008900
         LFXI  R5,3           SET COUNTER TO 3                          00009000
         B RMAG                                                         00009100
VV9DN    AENTRY                                                         00009200
*                                                                       00009300
* RETURNS THE MAGNITUDE OF V1 WHERE V1 IS A DOUBLE PRECISION            00009400
*   VECTOR OF LENGTH N WHERE N IS NOT EQUAL TO 3.                       00009500
*                                                                       00009600
         INPUT R2,            VECTOR(N) DP                             X00009700
               R5             INTEGER(N) SP                             00009800
         OUTPUT F0            SCALAR DP                                 00009900
         WORK  R6,F2,F4                                                 00010000
*                                                                       00010100
* ALGORITHM:                                                            00010200
*   F0 = 0;                                                             00010300
*   DO FOR I = N TO 1 BY -1;                                            00010400
*     F0 = F0 + V1$(I) ** 2;                                            00010500
*   END;                                                                00010600
*   F0 = SQRT(F0);                                                      00010700
*                                                                       00010800
RMAG     LA    R6,OUT         IF ABVAL THEN LOAD INTO R6                00010900
*                             ADDRESS OF RETURN SEQUENCE.               00011000
MAG      SEDR  F0,F0          CLEAR F0                                  00011100
LOOP     LED   F2,0(R5,R2)    GET ELEMENT FROM INPUT                    00011200
         MEDR  F2,F2          SQUARE THE ELEMENT                        00011300
         AEDR  F0,F2          ADD TO ACCUMULATOR                        00011400
         BCTB  R5,LOOP                                                  00011500
         ACALL DSQRT          TAKE SQRT OF F0                           00011600
         BR    R6             EITHER RETURN TO CALLER OR TO             00011700
*                             UNIT VECTOR ROUTINE                       00011800
AOUT     AERROR 28            VECTOR/MATRIX DIVIDE BY 0                 00011900
         SEDR  F0,F0          CLEAR F0                                  00012000
         ABAL  VV0DN          MAKE THE RESULT THE 0 VECTOR              00012100
OUT      AEXIT                                                          00012200
         ACLOSE                                                         00012300
