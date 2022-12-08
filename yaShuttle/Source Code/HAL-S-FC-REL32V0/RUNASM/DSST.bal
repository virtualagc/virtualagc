*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DSST.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

    TITLE 'DSST -- DOUBLE SCALAR SUBBIT STORE'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
DSST     AMAIN                                                          00000200
*                                                                       00000300
*                                                                       00000400
*  STORES A BIT STRING INTO                                             00000500
*   SELECTED BITS OF DOUBLE SCALAR                                      00000600
*                                                                       00000700
*                                                                       00000800
         INPUT R5,            INTEGER  SP                              X00000900
               R6,            INTEGER  SP                              X00001000
               R7             BIT STRING                                00001100
         OUTPUT R2            SCALAR  DP                                00001200
         WORK  R1,R3,R4                                                 00001300
*                                                                       00001400
*                                                                       00001500
         LR    R5,R5                                                    00001600
         BP    CONT                                                     00001700
         AERROR 30           ERROR:FIRST BIT<0                          00001800
         LA    R5,1                                                     00001900
*                                                                       00002000
CONT     LR    R1,R6                                                    00002100
         SR    R6,R5                                                    00002200
         AHI   R6,1                                                     00002300
         XR    R4,R4                                                    00002400
         LR    R3,R5                                                    00002500
         L     R5,ONE                                                   00002600
         SLL   R5,0(R6)                                                 00002700
         S     R5,ONE                                                   00002800
         AHI   R1,X'FFC0'                                               00002900
         BNP   S1                                                       00003000
         AERROR 30           ERROR LAST BIT>64                          00003100
         SRDL  R4,0(R1)                                                 00003200
         B     C1                                                       00003300
*                                                                       00003400
S1       LACR  R6,R1                                                    00003500
         SLDL  R4,0(R6)       SHIFT LEFT 64-LAST BIT                    00003600
*                                                                       00003700
C1       X     R4,ALLF                                                  00003800
         X     R5,ALLF        MASK READY                                00003900
         LR    R3,R7          BIT STRING IN R3                          00004000
         L     R6,0(R2)                                                 00004100
         L     R7,2(R2)                                                 00004200
         NR    R6,R4          MASK OUT BITS TO                          00004300
         NR    R7,R5          BE STORED INTO                            00004400
*                                                                       00004500
*  SHIFT STRING TO PROPER BIT                                           00004600
*                                                                       00004700
         XR    R2,R2                                                    00004800
         LR    R1,R1                                                    00004900
         BNP   S2                                                       00005000
         SRDL  R2,0(R1)                                                 00005100
         B     C2                                                       00005200
*                                                                       00005300
S2       LACR  R1,R1                                                    00005400
         SLDL  R2,0(R1)                                                 00005500
*                                                                       00005600
*  INSERT BIT STRING                                                    00005700
*                                                                       00005800
C2       OR    R6,R2                                                    00005900
         OR    R7,R3                                                    00006000
         L     R2,ARG2                                                  00006100
         ST    R6,0(R2)                                                 00006200
         ST    R7,2(R2)                                                 00006300
EXIT     AEXIT                                                          00006400
*                                                                       00006500
ONE      DC    F'1'                                                     00006600
ALLF     DC    X'FFFFFFFF'                                              00006700
         ACLOSE                                                         00006800
