*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    IREM.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'IREM - REMAINDER FUNCTION,DBL PREC INTEGER'             00000102
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
IREM     AMAIN INTSIC=YES                                               00000202
*                                                                       00000302
*   CALCULATES THE REMAINDER :                                          00000402
*                                                                       00000502
*     REMAINDER( A,B)                                                   00000602
*                                                                       00000702
* WHERE A&B ARE INTEGERS AND AT LEAST ONE OF THEM IS DP                 00000802
*                                                                       00000902
         INPUT R5,            INTEGER  DP (A)                          X00001002
               R6             INTEGER  DP (B)                           00001102
         OUTPUT R5            INTEGER  DP                               00001202
         WORK  R2,R7                                                    00001302
*                                                                       00001402
*                                                                       00001502
*                                                                       00001602
*                                                                       00001702
HREM     AENTRY                                                         00001802
*   CALCULATES THE REMAINDER :                                          00001902
*                                                                       00002002
*     REMAINDER( A,B)                                                   00002102
*                                                                       00002202
* WHERE A&B ARE INTEGER SP                                              00002302
*                                                                       00002402
         INPUT R5,            INTEGER  SP                              X00002502
               R6             INTEGER  SP                               00002602
         OUTPUT R5            INTEGER  SP                               00002702
         WORK  R2,R7                                                    00002802
*                                                                       00002902
*                                                                       00003002
*                                                                       00003102
         SR    R7,R7          CLEAR R7             /* DR103760 */       00003202
         LR    R2,R5                                                    00003302
         LR    R5,R6                                                    00003402
         BZ     ERROR         IF DENOMINATOR=0, THEN ERROR              00003502
         LR    R6,R2                                                    00003602
         SRDA  R6,31          31 BECAUSE OF FRACTIONAL DIVIDE           00003702
         DR    R6,R5          DIVIDE N/D                                00003802
         MR    R6,R5          MULTIPLY AGAIN                            00003902
         SRDA  R6,1           CHANGE FRACTION TO FULLWORD INTEGER       00004002
         SR    R2,R7          N-(N/D)*D                                 00004102
EXIT     LR    R5,R2          RESULT IN R5                              00004202
         AEXIT                                                          00004302
ERROR    AERROR  16     ERROR:SECONDE ARGUMENT=0                        00004402
         B     EXIT                                                     00004502
         ACLOSE                                                         00004602
