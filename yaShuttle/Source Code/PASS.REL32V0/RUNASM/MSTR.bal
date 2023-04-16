*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MSTR.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE   'MSTR- STRUCTURE MOVE,REMOTE'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
MSTR     AMAIN                                                          00000200
*        STRUCTURE MOVE, REMOTE                                         00000300
         INPUT R4,            ZCON PTR TO SOURCE                       X00000500
               R5             INTEGER SP NUMBER OF HALFWORDS TO MOVE    00000600
         OUTPUT R2            ZCON PTR TO DESTINATION                   00000700
         WORK  R3,R6,R7                                                 00000800
         LR    R5,R5          CHECK IF BAD COUNT                        00000900
         BNP   NOMOVE                                                   00001000
         TB    ARG4+1,X'0400'       IF SOURCE ZCON HAS IGNORE DSR BIT   00001100
         BNO   SRCZCON                                                  00001200
         IHL   R4,STACK+1           THEN GET DSR FROM PSW               00001300
*        DR103543: MASK OFF BITS 16-27 OF MVH SOURCE ADDRESS REGISTER.  00001401
         N     R4,=X'FFFF000F'      CLEAR RESRVED & IGNORED BITS 16-27  00001500
SRCZCON  TB    ARG2+1,X'0400'       IF DEST ZCON HAS IGNORE DSR BIT     00001600
         BNO   DESTZCON                                                 00001700
         IHL   R2,ARG5              R2 = A(DEST,COUNT)                  00001800
         MVH   R2,R4                DIRECT MOVE                         00001900
         B     NOMOVE                                                   00002000
DESTZCON LR    R7,R2                                                    00002100
         N     R7,=XL2'F'                                               00002200
         IHL   R2,ARG5              R2 = A(DEST,COUNT)                  00002300
         BALR  R3,0                                                     00002400
L1       LR    R6,R3                                                    00002500
         N     R6,=X'FFFFFFF0'                                          00002602
         OR    R6,R7                                                    00002700
         AHI   R6,L2-L1                                                 00002800
         BCRE  7,R6                 PUT DEST DSR IN PSW                 00002900
L2       MVH   R2,R4                                                    00003000
         AHI   R3,NOMOVE-L1                                             00003100
         BCRE  7,R3                 RESTORE PSW                         00003200
NOMOVE   AEXIT                                                          00003300
         ACLOSE                                                         00003400
