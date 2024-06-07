*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    XXDSIN.bal
*/ Purpose:     This is a part of the "Monitor" of the HAL/S-FC 
*/              compiler program.
*/ Reference:   "HAL/S Compiler Functional Specification", 
*/              section 2.1.1.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-07 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ are from the Virtual AGC Project.
*/              Comments beginning merely with * are from the original 
*/              Space Shuttle development.

DCOS     TITLE 'COMPILER''S DSIN / DCOS ROUTINE'                        00000100
       SPACE                                                            00000200
XXDCOS   CSECT                                                          00000300
         USING *,15                                                     00000400
         LA    R0,2                                                     00000500
         BAL   15,MERGE                                                 00000600
         REGEQU                                                         00000700
         USING *,15                                                     00000800
         ENTRY XXDSIN                                                   00000900
XXDSIN   DC    0H'0'                                                    00001000
CRANK    EQU   *                                                        00001100
       SR      R0,R0           FOR SINE, OCTANT CRANK IS 0 IF +ARG      00001200
         LTDR F0,F0                                                     00001300
         BC    2,*+8                                                    00001400
       LA      R0,4                                                     00001500
       SPACE                                                            00001600
MERGE  LPER    F0,F0         FORCE SIGN OF ARG TO +                     00001700
       CE      F0,MAX                                                   00001800
       BC      10,ERROR        ERROR IF /X/ GRT THAN OR = PI*2**50      00001900
       SPACE                                                            00002000
       DD      F0,PIOV4       DIVIDE BY PI/4 AND SEPARATE INTEGER       00002100
       LDR     F2,F0           PART AND FRACTION PART OF QUOTIENT       00002200
       AW      F2,SCALER      FORCE CHARACTERISTIC X'4E'                00002300
       STD     F2,BUFF        INTEGER PART UNNORMALIZED = OCTANT        00002400
       AD      F2,SCALER      INTEGER PART NORMALIZED                   00002500
       SDR     F0,F2         FRACTION PART TO F0                        00002600
       AL      R0,BUFF+4      ADJUST OCTANT NUMBER WITH CRANK           00002700
       ST      R0,BUFF         AND SAVE IT                              00002800
       SPACE                                                            00002900
       TM      OCTNT+3,X'01'   IF ODD OCTANT, TAKE COMPLEMENT           00003000
       BC      8,EVEN            OF FRACTION TO OBTAIN MODIFIED ARG     00003100
       SD      F0,C0                                                    00003200
       SPACE                                                            00003300
EVEN   LPDR    F4,F0                                                    00003400
       SR      R1,R1         R1 = 0 FOR COSINE POLYNOMIAL               00003500
       TM      OCTNT+3,X'03'     THIS IS FOR OCTANT 2, 3, 6, OR 7       00003600
       BC      4,*+8           R1 = 8 FOR SINE POLYNOMIAL               00003700
       LA      R1,8             THIS IS FOR OCTANT 1, 4, 5, OR 8        00003800
       SPACE                                                            00003900
       CE      F4,UNFLO       IF X IS LESS THAN 16**-7, SET X TO 0      00004000
       BC      2,*+6             THIS PREVENTS UNDERFLOW                00004100
       SDR     F0,F0                                                    00004200
       SPACE                                                            00004300
       MDR     F0,F0         COMPUTE SINE OR COSINE OF MODIFIED         00004400
       LDR     F2,F0           ARG USING PROPER CHEBYSHEV               00004500
       MD      F0,C7(R1)         INTERPOLATION POLYNOMIAL               00004600
       AD      F0,C6(R1)                                                00004700
       MDR     F0,F2         SIN(X)/X POLYNOMIAL OF DEG 6 IN X**2       00004800
       AD      F0,C5(R1)     COS(X) POLYNOMIAL OF DEG 7 IN X**2         00004900
       MDR     F0,F2                                                    00005000
       AD      F0,C4(R1)                                                00005100
       MDR     F0,F2                                                    00005200
       AD      F0,C3(R1)                                                00005300
       MDR     F0,F2                                                    00005400
       AD      F0,C2(R1)                                                00005500
       MDR     F0,F2                                                    00005600
       AD      F0,C1(R1)                                                00005700
       SPACE                                                            00005800
       LTR     R1,R1                                                    00005900
       BC      8,COSF                                                   00006000
       MDR     F0,F4         COMPLETE SINE POLYNOMIAL BY                00006100
       BC      15,SIGN           MULTIPLYING BY X                       00006200
       SPACE                                                            00006300
COSF   MDR     F0,F2         COMPLETE COSINE POLYNOMIAL                 00006400
       AD      F0,C0            (ONE MORE DEGREE)                       00006500
       SPACE                                                            00006600
SIGN   TM      OCTNT+3,X'04'   IF MODIFIED OCTANT IS IN                 00006700
       BC      8,*+6             LOWER PLANE, SIGN IS NEGATIVE          00006800
       LNER    F0,F0                                                    00006900
EXIT   BR      14                                                       00007000
*ERROR - ARG GE PI*2**5 IN ABS                                          00007100
ERROR  DS 0H                                                            00007200
         LA    15,1                                                     00007300
         BR    14                                                       00007400
       SPACE                                                            00007500
       DS       0D                                                      00007600
BUFF     DS    D                                                        00007700
OCTNT    EQU   BUFF                                                     00007800
C7     DC      X'B66C992E84B6AA37'     COS C7                           00007900
       DC      X'3778FCE0E5AD1685'     SIN C6                           00008000
C6     DC      X'387E731045017594'     COS C6                           00008100
       DC      X'B978C01C6BEF8CB3'     SIN C5                           00008200
C5     DC      X'BA69B47B1E41AEF6'     COS C5                           00008300
       DC      X'3B541E0BF684B527'     SIN C4                           00008400
C4     DC      X'3C3C3EA0D06ABC29'     COS C4                           00008500
       DC      X'BD265A599C5CB632'     SIN C3                           00008600
C3     DC      X'BE155D3C7E3C90F8'     COS C3                           00008700
       DC      X'3EA335E33BAC3FBD'     SIN C2                           00008800
C2     DC      X'3F40F07C206D6AB1'     COS C2                           00008900
       DC      X'C014ABBCE625BE41'     SIN C1                           00009000
C1     DC      X'C04EF4F326F91777'     COS C1 -2F                       00009100
PIOV4  DC      X'40C90FDAA22168C2'     SIN C0                           00009200
C0     DC      X'4110000000000000'     COS C0                           00009300
SCALER DC      X'4E00000000000000'                                      00009400
ONOVSQT2 DC    X'40B504F333F9DE70'                                      00009500
UNFLO  DC      X'3A100000'                                              00009600
MAX    DC      X'4DC90FDA'                                              00009700
         END                                                            00009800
