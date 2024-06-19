*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV0DNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'VV0DNP---SCALAR TO COLUMN VECTOR,DOUBLE PREC'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV0DNP   AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   FILL A COL OF DP MATRIX M(M,N)                                      00000400
*                                                                       00000500
*     WITH  ZEROS                                                       00000600
*                                                                       00000700
         INPUT F0,            SCALAR      DP                           X00000800
               R7,            INTEGER(N)  SP                           X00000900
               R5             INTEGER(M)  SP                            00001000
         OUTPUT R1            VECTOR(M)   DP                            00001100
*                                                                       00001200
*  ALGORITHM :                                                          00001300
*     DO FOR I=1 TO M;                                                  00001400
*      M(,X)=0:                                                         00001500
*     END:                                                              00001600
*                                                                       00001700
LOOP     STED  F0,4(R1)       PLACE M ELE.                              00001800
         AR    R1,R7          BUMP R1 PTR BY # COL.                     00001900
         BCTB  R5,LOOP        I=1 TO M COUNTER                          00002000
         AEXIT                                                          00002100
         ACLOSE                                                         00002200
