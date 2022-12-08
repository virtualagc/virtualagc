*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV5S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV5S3--VECTOR DIVIDED BY SCALAR, LENGTH 3, SP'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV5S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* DIVIDE V1 BY A SINGLE PRECISION SCALAR WHERE V1 IS A SINGLE PRECISION 00000400
*   3 VECTOR.                                                           00000500
*                                                                       00000600
         INPUT R2,            VECTOR(3) SP                             X00000700
               F0             SCALAR                                    00000800
         OUTPUT R1            VECTOR(3) SP                              00000900
         WORK  F2                                                       00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN VV5D3                                  00001300
*                                                                       00001400
         LER   F0,F0          SET CONDITION CODE                        00001500
         BZ    VV5SDZ         IF ZERO THEN SEND AN ERROR                00001600
DIV      LE    F2,2(R2)       GET FIRST ELEMENT                         00001700
         DER   F2,F0          DIVIDE BY THE SCALAR                      00001800
         STE   F2,2(R1)       STORE FIRST ELEMENT                       00001900
         LE    F2,4(R2)       GET SECOND ELEMENT                        00002000
         DER   F2,F0          DIVIDE BY THE SCALAR                      00002100
         STE   F2,4(R1)       STORE THE SECOND ELEMENT                  00002200
         LE    F2,6(R2)       GET THIRD ELEMENT                         00002300
         DER   F2,F0          DIVIDE BY THE SCALAR                      00002400
         STE   F2,6(R1)       STORE THIRD ELEMENT                       00002500
         AEXIT                                                          00002600
VV5SDZ   AERROR 25            ATTEMPT TO DIVIDE BY 0                    00002700
         LFLI  F0,1                                                     00002800
         B     DIV                                                      00002900
         ACLOSE                                                         00003000
