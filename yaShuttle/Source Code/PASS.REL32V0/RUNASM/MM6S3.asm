*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM6S3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM6S3--MATRIX(3,3) MATRIX(3,3) MULTIPLY, SP'            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPUTES THE MATRIX PRODUCT:                                          00000400
*                                                                       00000500
*          M(3,3) = M1(3,3) M2(3,3)                                     00000600
*                                                                       00000700
         INPUT R2,            MATRIX(3,3) SP ( THIS IS M1 )            X00000800
               R3             MATRIX(3,3) SP ( THIS IS M2 )             00000900
         OUTPUT R1            MATRIX(3,3) SP                            00001000
         WORK  R5,R6,R7,F0,F2,F4                                        00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   SEE ALGORITHM DESCRIPTION IN MM6D3                                  00001400
*                                                                       00001500
         LA    R7,3           PLACE A 3 IN R7                           00001600
         LA    R6,6           PLACE A 6 IN R6                           00001700
*                             (# OF HALFWORDS / ROW)                    00001800
LOOP3    LA    R5,3           PLACE A 3 IN R5                           00001900
LOOP2    LE    F0,2(R2)       GET M1$(I,1)                              00002000
         ME    F0,2(R3)       MULTIPLY BY M2$(1,J)                      00002100
         LE    F2,4(R2)       GET M1$(I,2)                              00002200
         ME    F2,8(R3)       MULTIPLY BY M2$(2,J)                      00002300
         LE    F4,6(R2)       GET M1$(I,3)                              00002400
         ME    F4,14(R3)      MULTIPLY BY M2$(3,J)                      00002500
         AEDR  F0,F2          ACCUMULATE INTERMEDIATE PRODUCTS          00002600
         AEDR  F0,F4                                                    00002700
         STE   F0,2(R1)       STORE AWAY IN M                           00002800
         LA    R1,2(R1)       BUMP OUTPUT PTR TO NEXT ELEMENT           00002900
         LA    R3,2(R3)       BUMP M2 PTR TO NEXT COLUMN                00003000
         BCTB  R5,LOOP2                                                 00003100
         LA    R2,6(R2)       BUMP M1 PTR TO NEXT ROW                   00003200
         SR    R3,R6          RESET M2 PTR TO BEGINNING OF MATRIX       00003300
         BCTB  R7,LOOP3                                                 00003400
         AEXIT                                                          00003500
         ACLOSE                                                         00003600
