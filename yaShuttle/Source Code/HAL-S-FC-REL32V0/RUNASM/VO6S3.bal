*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VO6S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VO6S3--VECTOR OUTER PRODUCT, LENGTH 3, SP'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VO6S3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE VECTOR OUTER PRODUCT OF TWO SINGLE PRECISION 3-VECTORS.     00000400
*                                                                       00000500
         INPUT R2,            VECTOR(3)                                X00000600
               R3             VECTOR(3)                                 00000700
         OUTPUT R1            MATRIX(3,3) SP                            00000800
         WORK  R5,R6,F0                                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   SEE ALGORITHM DESCRIPTION IN VO6D3                                  00001200
*                                                                       00001300
         LA    R5,3           SET R5 COUNTER                            00001400
         XR    R2,R3          SWITCH R2 AND R3 PTRS                     00001500
         XR    R3,R2                                                    00001600
         XR    R2,R3                                                    00001700
LOOP2    LA    R6,3           RESET R6 COUNTER                          00001800
LOOP1    LE    F0,2(R3)                                                 00001900
         ME    F0,0(R6,R2)                                              00002000
         STE   F0,0(R6,R1)                                              00002100
         BCTB  R6,LOOP1                                                 00002200
         LA    R3,2(R3)       SET V1 PTR TO NEXT ELEMENT                00002300
         LA    R1,6(R1)       SET OUTPUT PTR TO NEXT ROW                00002400
         BCTB  R5,LOOP2                                                 00002500
         AEXIT                                                          00002600
         ACLOSE                                                         00002700
