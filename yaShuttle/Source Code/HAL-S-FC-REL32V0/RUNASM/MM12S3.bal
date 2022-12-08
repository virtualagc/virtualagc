*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM12S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM12S3--DETERMINANT OF A 3 X 3 MATRIX, SP'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
MM12S3   AMAIN                                                          00000200
*                                                                       00000300
* TAKES THE DETERMINANT OF A 3 X 3 SINGLE PRECISION MATRIX              00000400
*                                                                       00000500
         INPUT R2             MATRIX(3,3) SP                            00000600
         OUTPUT F0            SCALAR SP                                 00000700
         WORK  F2,F4                                                    00000800
*                                                                       00000900
* ALGORITHM:                                                            00001000
*   USES THE SUM OF THE TOP TO BOTTOM DIAGONALS MINUS THE SUM OF THE    00001100
*     BOTTOM TO TOP DIAGONALS FORMULA.                                  00001200
*                                                                       00001300
         LE    F0,2(R2)                                                 00001400
         ME    F0,10(R2)                                                00001500
         ME    F0,18(R2)      M$(1,1) * M$(2,2) * M$(3,3)               00001600
         LE    F2,4(R2)                                                 00001700
         ME    F2,12(R2)                                                00001800
         ME    F2,14(R2)      M$(1,2) * M$(2,3) * M$(3,1)               00001900
         LE    F4,6(R2)                                                 00002000
         ME    F4,8(R2)                                                 00002100
         ME    F4,16(R2)      M$(1,3) * M$(2,1) * M$(3,2)               00002200
         AER   F0,F2                                                    00002300
         AER   F0,F4                                                    00002400
         LE    F2,14(R2)                                                00002500
         ME    F2,10(R2)                                                00002600
         ME    F2,6(R2)       M$(3,1) * M$(2,3) * M$(1,1)               00002700
         LE    F4,16(R2)                                                00002800
         ME    F4,12(R2)                                                00002900
         ME    F4,2(R2)       M$(3,2) * M$(2,3) * M$(1,1)               00003000
         SER   F0,F2                                                    00003100
         SER   F0,F4                                                    00003200
         LE    F2,18(R2)                                                00003300
         ME    F2,8(R2)                                                 00003400
         ME    F2,4(R2)       M$(3,3) * M$(2,1) * M$(1,2)               00003500
         SER   F0,F2                                                    00003600
         AEXIT                                                          00003700
         ACLOSE                                                         00003800
