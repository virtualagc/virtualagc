*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    HIN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'HIN,IIN,EIN,DIN,BIN-INPUT ROUTINES'                    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
HIN      AMAIN                                                          00000200
*        INTEGER INPUT,SINGLE PRECISION (HALFWORD)                      00000300
         INPUT R2             POINTER TO HALFWORD                       00000400
         OUTPUT NONE                                                    00000500
         WORK  R5,R6                                                    00000600
         LHI   R6,10                                                    00000700
         STH   R6,IOCODE                                                00000800
         ABAL  INTRAP                                                   00000900
         LH    R5,IOBUF                                                 00001000
         STH   R5,0(R2)                                                 00001100
         AEXIT                                                          00001200
         EXTRN IOBUF,IOCODE                                             00001300
IIN      AENTRY                                                         00001400
*        INTEGER INPUT,DOUBLE PRECISION (FULLWORD)                      00001500
         INPUT R2             POINTER TO FULLWORD INTEGER               00001600
         OUTPUT NONE                                                    00001700
         LHI   R6,9                                                     00001800
         STH   R6,IOCODE                                                00001900
         ABAL  INTRAP                                                   00002000
         L    R5,IOBUF                                                  00002100
         ST    R5,0(R2)                                                 00002200
         AEXIT                                                          00002300
EIN      AENTRY                                                         00002400
*        SCALAR INPUT, SINGLE PRECISON (FULLWORD)                       00002500
         INPUT R2             POINTER TO SCALAR FULLWORD                00002600
         OUTPUT NONE                                                    00002700
         WORK  F0                                                       00002800
         LHI   R6,11                                                    00002900
         STH   R6,IOCODE                                                00003000
         ABAL  INTRAP                                                   00003100
         LE    F0,IOBUF                                                 00003200
         STE   F0,0(R2)                                                 00003300
         AEXIT                                                          00003400
DIN      AENTRY                                                         00003500
*        SCALAR INPUT, DOUBLE PRECISION (DOUBLEWORD)                    00003600
         INPUT R2             POINTER TO SCALAR DOUBLE                  00003700
         OUTPUT NONE                                                    00003800
         LHI   R6,12                                                    00003900
         STH   R6,IOCODE                                                00004000
         ABAL  INTRAP                                                   00004100
         LED   F0,IOBUF                                                 00004200
         STED  F0,0(R2)                                                 00004300
         AEXIT                                                          00004400
BIN      AENTRY                                                         00004500
*        BIT STRING INPUT                                               00004600
         INPUT R6             BIT STRING LENGTH                         00004700
         OUTPUT R6,           BIT STRING                               X00004800
               CC             CONDITION CODE (ALWAYS NE)                00004900
         STH   R6,IOBUF                                                 00005000
         LHI   R6,8                                                     00005100
         STH   R6,IOCODE                                                00005200
         ABAL  INTRAP                                                   00005300
         L     R6,IOBUF                                                 00005400
         CIST  ARG6,16                                                  00005500
         BL    BINSTORE       WANT FULLWORD RETURNED                    00005600
         SLL   R6,16          POISITION TO LEFTMOST POSITION            00005700
BINSTORE ST    R6,ARG6        SAVE FOR PROCESSING BY CALLER             00005800
         AEXIT CC=NE                                                    00005900
         ACLOSE                                                         00006000
