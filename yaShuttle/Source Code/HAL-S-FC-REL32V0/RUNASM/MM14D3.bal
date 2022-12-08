*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM14D3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'MM14D3--MATRIX INVERSE,3 X 3,SINGLE PREC'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM14D3   AMAIN   ACALL=YES,QDED=YES                                     00000200
*                                                                       00000300
*  GENERATES THE INVERSE MATRIX :                                       00000400
*                                                                       00000500
*   M(3,3)= INVERSE (M1(3,3) )                                          00000600
*                                                                       00000700
*   WHERE  M,M1 ARE DP                                                  00000800
*                                                                       00000900
         INPUT R4             MATRIX(3,3)  DP                           00001000
         OUTPUT R2            MATRIX(3,3)  DP                           00001100
         WORK  R1,R5,F0,F2,F4,F3                                        00001200
*                                                                       00001300
* ALGORITHM:                                                            00001400
*                                                                       00001500
*   INVERSE (M) = DET( M$(I^=3,J^=3) )/ DET(M)                          00001600
*                                                                       00001700
         LR    R1,R2                                                    00001800
         LR    R2,R4                                                    00001900
         ACALL MM12D3                                                   00002000
         LER   F0,F0                                                    00002100
         BZ    AOUT                                                     00002200
         SER   F3,F3                                                    00002300
         LFLI  F2,1                                                     00002400
        QDEDR  F2,F0                                                    00002500
         LED   F0,20(R2)                                                00002600
         LED   F4,32(R2)                                                00002700
         MED   F0,36(R2)                                                00002800
         MED   F4,24(R2)                                                00002900
         SEDR  F0,F4                                                    00003000
         MEDR  F0,F2                                                    00003100
         STED  F0,4(R1)       I(1,1)                                    00003200
         LED   F0,8(R2)                                                 00003300
         LED   F4,32(R2)                                                00003400
         MED   F0,36(R2)                                                00003500
         MED   F4,12(R2)                                                00003600
         SEDR  F4,F0                                                    00003700
         MEDR  F4,F2                                                    00003800
         STED  F4,8(R1)       I(1,2)                                    00003900
         LED   F0,8(R2)                                                 00004000
         LED   F4,20(R2)                                                00004100
         MED   F0,24(R2)                                                00004200
         MED   F4,12(R2)                                                00004300
         SEDR  F0,F4                                                    00004400
         MEDR  F0,F2                                                    00004500
         STED  F0,12(R1)       I(1,3)                                   00004600
         LED   F0,16(R2)                                                00004700
         LED   F4,28(R2)                                                00004800
         MED   F0,36(R2)                                                00004900
         MED   F4,24(R2)                                                00005000
         SEDR  F4,F0                                                    00005100
         MEDR  F4,F2                                                    00005200
         STED  F4,16(R1)       I(2,1)                                   00005300
         LED   F0,4(R2)                                                 00005400
         LED   F4,28(R2)                                                00005500
         MED   F0,36(R2)                                                00005600
         MED   F4,12(R2)                                                00005700
         SEDR  F0,F4                                                    00005800
         MEDR  F0,F2                                                    00005900
         STED  F0,20(R1)      I(2,2)                                    00006000
         LED   F0,4(R2)                                                 00006100
         LED   F4,16(R2)                                                00006200
         MED   F0,24(R2)                                                00006300
         MED   F4,12(R2)                                                00006400
         SEDR  F4,F0                                                    00006500
         MEDR  F4,F2                                                    00006600
         STED  F4,24(R1)      I(2,3)                                    00006700
         LED   F0,16(R2)                                                00006800
         LED   F4,28(R2)                                                00006900
         MED   F0,32(R2)                                                00007000
         MED   F4,20(R2)                                                00007100
         SEDR  F0,F4                                                    00007200
         MEDR  F0,F2                                                    00007300
         STED  F0,28(R1)      I(3,1)                                    00007400
         LED   F0,4(R2)                                                 00007500
         LED   F4,28(R2)                                                00007600
         MED   F0,32(R2)                                                00007700
         MED   F4,8(R2)                                                 00007800
         SEDR  F4,F0                                                    00007900
         MEDR  F4,F2                                                    00008000
         STED  F4,32(R1)      I(3,2)                                    00008100
         LED   F0,4(R2)                                                 00008200
         LED   F4,16(R2)                                                00008300
         MED   F0,20(R2)                                                00008400
         MED   F4,8(R2)                                                 00008500
         SEDR  F0,F4                                                    00008600
         MEDR  F0,F2                                                    00008700
         STED  F0,36(R1)      I(3,3)                                    00008800
OUT      AEXIT                                                          00008900
AOUT     AERROR   27         ERROR:THIS IS A SINGULAR MATRIX            00009000
         LA    R5,3                                                     00009100
         ABAL MM15DN                                                    00009200
         B     OUT                                                      00009300
         ACLOSE                                                         00009400
