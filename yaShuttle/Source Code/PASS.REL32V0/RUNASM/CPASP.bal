*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CPASP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CPASP--CHARACTER ASSIGN,PARTITION TO PARTITION'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
VAC      DS    128H                                                     00000400
         MEND                                                           00000500
CPASP    AMAIN ACALL=YES                                                00000600
*                                                                       00000700
* ASSIGN C1$(I TO J) TO C2$(K TO L) WHERE C1 AND C2 ARE                 00000800
*   CHARACTER STRINGS.                                                  00000900
*                                                                       00001000
         INPUT R4,            CHARACTER(C1)                            X00001100
               R5,            INTEGER(I) SP                            X00001200
               R6,            INTEGER(J) SP                            X00001300
               R7             INTEGER(K || L) SP                        00001400
         OUTPUT R2            CHARACTER(C2)                             00001500
         WORK  R1,F0                                                    00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   VAC = CASPV(C1$(I TO J));                                           00001900
*   C2$(K TO L) = CPAS(VAC);                                            00002000
*                                                                       00002100
         LA    R1,VAC         PUT ADDRESS OF VAC AS OUTPUT              00002200
         LR    R2,R4          PUT INPUT ADDRESS INTO R2                 00002300
         ABAL  CASPV          PUT INPUT PARTITION INTO A VAC            00002400
         LH    R5,ARG7        SET UP K AND L FOR OUTPUT PARTITION       00002500
         LH    R6,ARG7+1      PLACE L INTO R6                           00002600
         BNZ   *+2                                                      00002700
         LR    R6,R5          SPECIAL CASE FOR 2ND ARG 0                00002800
         L     R2,ARG2                                                  00002900
         LA    R4,VAC         READ FROM VAC INTO                        00003000
         ACALL CPAS           PARTITION                                 00003100
         AEXIT                                                          00003200
         ACLOSE                                                         00003300
