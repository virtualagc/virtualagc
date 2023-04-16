*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM14S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'MM14S3--MATRIX INVERSE,3 X 3,SINGLE PREC'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM14S3   AMAIN   ACALL=YES                                              00000200
*                                                                       00000300
*  GENERATES THE INVERSE MATRIX:                                        00000400
*                                                                       00000500
*     M(3,3)= INVERSE( M1(3,3) )                                        00000600
*                                                                       00000700
*  WHERE  M,M1  ARE  SP                                                 00000800
*                                                                       00000900
         INPUT R4             MATRIX(3,3)  SP                           00001000
         OUTPUT R2            MATRIX(3,3)  SP                           00001100
         WORK  R1,R5,F0,F2,F4                                           00001200
*                                                                       00001300
*   ALGORITHM :                                                         00001400
*                                                                       00001500
*    INVERSE (M) =  ADJ(M) /DET(M)                                      00001600
*                                                                       00001700
         LR    R1,R2                                                    00001800
         LR    R2,R4                                                    00001900
         ACALL MM12S3                                                   00002000
         LER   F0,F0                                                    00002100
         BZ    AOUT                                                     00002200
         LE    F2,10(R2)                                                00002300
         LE    F4,16(R2)                                                00002400
         ME    F2,18(R2)                                                00002500
         ME    F4,12(R2)                                                00002600
         SEDR  F2,F4                                                    00002700
         DER   F2,F0                                                    00002800
         STE   F2,2(R1)       I(1,1)                                    00002900
         LE    F2,4(R2)                                                 00003000
         LE    F4,16(R2)                                                00003100
         ME    F2,18(R2)                                                00003200
         ME    F4,6(R2)                                                 00003300
         SEDR  F4,F2                                                    00003400
         DER   F4,F0                                                    00003500
         STE   F4,4(R1)       I(1,2)                                    00003600
         LE    F2,4(R2)                                                 00003700
         LE    F4,10(R2)                                                00003800
         ME    F2,12(R2)                                                00003900
         ME    F4,6(R2)                                                 00004000
         SEDR  F2,F4                                                    00004100
         DER   F2,F0                                                    00004200
         STE   F2,6(R1)       I(1,3)                                    00004300
         LE    F2,8(R2)                                                 00004400
         LE    F4,14(R2)                                                00004500
         ME    F2,18(R2)                                                00004600
         ME    F4,12(R2)                                                00004700
         SEDR  F4,F2                                                    00004800
         DER   F4,F0                                                    00004900
         STE   F4,8(R1)       I(2,1)                                    00005000
         LE    F2,2(R2)                                                 00005100
         LE    F4,14(R2)                                                00005200
         ME    F2,18(R2)                                                00005300
         ME    F4,6(R2)                                                 00005400
         SEDR  F2,F4                                                    00005500
         DER   F2,F0                                                    00005600
         STE   F2,10(R1)      I(2,2)                                    00005700
         LE    F2,2(R2)                                                 00005800
         LE    F4,8(R2)                                                 00005900
         ME    F2,12(R2)                                                00006000
         ME    F4,6(R2)                                                 00006100
         SEDR  F4,F2                                                    00006200
         DER   F4,F0                                                    00006300
         STE   F4,12(R1)      I(2,3)                                    00006400
         LE    F2,8(R2)                                                 00006500
         LE    F4,14(R2)                                                00006600
         ME    F2,16(R2)                                                00006700
         ME    F4,10(R2)                                                00006800
         SEDR  F2,F4                                                    00006900
         DER   F2,F0                                                    00007000
         STE   F2,14(R1)      I(3,1)                                    00007100
         LE    F2,2(R2)                                                 00007200
         LE    F4,14(R2)                                                00007300
         ME    F2,16(R2)                                                00007400
         ME    F4,4(R2)                                                 00007500
         SEDR  F4,F2                                                    00007600
         DER   F4,F0                                                    00007700
         STE   F4,16(R1)      I(3,2)                                    00007800
         LE    F2,2(R2)                                                 00007900
         LE    F4,8(R2)                                                 00008000
         ME    F2,10(R2)                                                00008100
         ME    F4,4(R2)                                                 00008200
         SEDR  F2,F4                                                    00008300
         DER   F2,F0                                                    00008400
         STE   F2,18(R1)      I(3,3)                                    00008500
OUT      AEXIT                                                          00008600
AOUT     AERROR   27         ERROR:THIS IS A SINGULAR MATRIX            00008700
         LA    R5,3                                                     00008800
         ABAL MM15SN                                                    00008900
         B     OUT                                                      00009000
         ACLOSE                                                         00009100
