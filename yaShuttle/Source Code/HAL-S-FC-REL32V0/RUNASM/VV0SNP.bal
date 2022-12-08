*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV0SNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VV0SNP---SCALAR TO COLUMN VECTOR,SINGLE PREC'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV0SNP   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*    FILLS A COL. OF SP MATRIX M(M,N)                                   00000400
*                                                                       00000500
*     WITH ZEROES                                                       00000600
*                                                                       00000700
         INPUT F0,            SCLAR      SP                            X00000800
               R7,            INTEGER(N)  SP                           X00000900
               R5             INTEGER(M)  SP                            00001000
         OUTPUT R1            VECTOR(M)   SP                            00001100
*                                                                       00001200
*    ALGORITHM:                                                         00001300
*     DO FOR I=1 TO M;                                                  00001400
*      M(I,X)=0;                                                        00001500
*     END;                                                              00001600
*                                                                       00001700
LOOP     STE   F0,2(R1)       PLACE M ELE.                              00001800
         AR    R1,R7          BUMP RESULT PTR BY # COL.                 00001900
         BCTB  R5,LOOP        I=1 TO M COUNTER                          00002000
         AEXIT                                                          00002100
         ACLOSE                                                         00002200
