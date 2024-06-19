*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    IOINIT.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'IOINIT AND OUTPUT PACKAGE '                             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
IOINIT   AMAIN                                                          00000200
*        INITIALIZES I/O SYSTEM FOR READ,READALL,OR WRITE STATEMENT     00000300
         INPUT R5,            MODE (0-READ,1-READALL,2-WRITE,3-PRINT)  X00000400
               R6             CHANNEL (0 - 9)                           00000500
         OUTPUT NONE                                                    00000600
         WORK  R4             FOR VARIOUS BAL'S                         00000700
         ENTRY  IOBUF,IOCODE,INTRAP                                     00000800
         STH   R6,IOBUF                                                 00000900
         STH   R5,IOCODE                                                00001000
         BAL   R4,CNTRAP                                                00001100
         AEXIT                                                          00001200
HOUT     AENTRY                                                         00001300
*        SINGLE PRECISION (HALFWORD) INTEGER OUTPUT                     00001400
         INPUT R5             INTEGER SP                                00001500
         OUTPUT NONE                                                    00001600
         STH   R5,IOBUF                                                 00001700
         LHI   R6,10                                                    00001800
OUTCOM   STH   R6,IOCODE                                                00001900
OUTRAP   BCR   0,0                                                      00002000
         AEXIT                                                          00002100
OUTER1   AENTRY                                                         00002200
*        OUTPUT ENTRY USED BY COUT                                      00002300
         INPUT NONE                                                     00002400
         OUTPUT NONE                                                    00002500
         B     OUTRAP                                                   00002600
IOUT     AENTRY                                                         00002700
*        DOUBLE PRECISION (FULLWORD) INTEGER OUTPUT                     00002800
         INPUT R5             INTEGER DP                                00002900
         OUTPUT NONE                                                    00003000
         ST    R5,IOBUF                                                 00003100
         LHI   R6,9                                                     00003200
         B     OUTCOM                                                   00003300
EOUT     AENTRY                                                         00003400
*        SINGLE PRECISION (FULLWORD) SCALAR OUTPUT                      00003500
         INPUT F0             SCALAR SP                                 00003600
         OUTPUT NONE                                                    00003700
         STE   F0,IOBUF                                                 00003800
         LHI   R6,11                                                    00003900
         B     OUTCOM                                                   00004000
DOUT     AENTRY                                                         00004100
*        DOUBLE PRECISION (DOUBLEWORD) SCALAR OUTPUT                    00004200
         INPUT F0             SCALAR DP                                 00004300
         OUTPUT NONE                                                    00004400
         STED  F0,IOBUF                                                 00004500
         LHI   R6,12                                                    00004600
         B     OUTCOM                                                   00004700
BOUT     AENTRY                                                         00004800
*        BIT STRING OUTPUT                                              00004900
         INPUT R5,            BIT STRING                               X00005000
               R6             BIT LENGTH                                00005100
         OUTPUT NONE                                                    00005200
         ST    R5,IOBUF+2                                               00005300
         STH   R6,IOBUF                                                 00005400
         LHI   R6,8                                                     00005500
         B     OUTCOM                                                   00005600
INTRAP   BR    R4                                                       00005700
SKIP     AENTRY                                                         00005800
*        PERFORMS SKIP CONTROL FUNCTION                                 00005900
         INPUT R5             INTEGER SP SKIP COUNT                     00006000
         OUTPUT NONE                                                    00006100
         LHI   R6,8                                                     00006200
CTCOM    STH   R5,IOBUF                                                 00006300
         STH   R6,IOCODE                                                00006400
         BAL   R4,CNTRAP                                                00006500
         AEXIT                                                          00006600
CNTRAP   BR    R4                                                       00006700
LINE     AENTRY                                                         00006800
*        PERFORMS LINE CONTROL FUNCTION                                 00006900
         INPUT R5             INTEGER SP LINE NUMBER                    00007000
         OUTPUT NONE                                                    00007100
         LHI   R6,4                                                     00007200
         B     CTCOM                                                    00007300
COLUMN   AENTRY                                                         00007400
*        PERFORMS COLUMN CONTROL FUNCTION                               00007500
         INPUT R5             INTEGER SP COLUMN NUMBER                  00007600
         OUTPUT NONE                                                    00007700
         LHI   R6,5                                                     00007800
         B     CTCOM                                                    00007900
TAB      AENTRY                                                         00008000
*        PERFORMS TAB CONTROL FUNCTION                                  00008100
         INPUT R5             INTEGER SP TAB COUNT                      00008200
         OUTPUT NONE                                                    00008300
         LHI   R6,6                                                     00008400
         B     CTCOM                                                    00008500
PAGE     AENTRY                                                         00008600
*        PERFORMS PAGE CONTROL FUNCTION                                 00008700
         INPUT R5             INTEGER SP PAGE COUNT                     00008800
         OUTPUT NONE                                                    00008900
         LHI   R6,7                                                     00009000
         B     CTCOM                                                    00009100
         ADATA                                                          00009200
         SPOFF                                                          00009300
IOCODE   DS    H                                                        00009400
         DS    0D                                                       00009500
IOBUF    DS    129H                                                     00009600
         ACLOSE                                                         00009700
