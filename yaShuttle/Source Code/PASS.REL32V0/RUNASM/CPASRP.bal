*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CPASRP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

 TITLE 'CPASRP--CHARACTER ASSIGN,PARTITION TO PARTITION,REMOTE'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
VAC      DS    128H                                                     00000400
         MEND                                                           00000500
CPASRP   AMAIN ACALL=YES                                                00000600
*                                                                       00000700
* ASSIGN C1$(I TO J) TO C2$(K TO L) WHERE C1 AND C2 ARE CHARACTER       00000800
*   STRINGS AT LEAST ONE OF WHICH IS REMOTE.                            00000900
*                                                                       00001000
         INPUT R4,            CHARACTER(C1)                            X00001100
               R5,            INTEGER(I) SP                            X00001200
               R6,            INTEGER(J) SP                            X00001300
               R7             INTEGER(K || L) SP                        00001400
         OUTPUT R2            CHARACTER(C2)                             00001500
         WORK  F0,F1                                                    00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   VAC = CASRPV(C1$(I TO J));                                          00001900
*   C2$(K TO L) = CPASR(VAC);                                           00002000
*                                                                       00002100
         LA    R2,VAC                                                   00002200
         ACALL CASRPV         PUT INPUT PARTITION INTO A VAC            00002300
         LH    R5,ARG7        LOAD K IN R5                              00002400
         LH    R6,ARG7+1      LOAD L IN R6                              00002500
         BNZ   *+2            CHECK FOR ZERO                            00002600
         LR    R6,R5          SPECIAL CASE, ASSUME L=K                  00002700
         L     R2,ARG2                                                  00002800
         LA    R4,VAC         READ FROM VAC INTO                        00002900
         ACALL CPASR          PARTITION                                 00003000
         AEXIT                                                          00003100
         ACLOSE                                                         00003200
