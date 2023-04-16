*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MMWDNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

MMWDNP  TITLE 'DOUBLE PRECISION VECTOR/MATRIX OUTPUT INTERFACE'         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
HOLD1    DS    H                                                        00000400
HOLD7    DS    H                                                        00000500
         MEND                                                           00000600
MMWDNP   AMAIN ACALL=YES                                                00000700
* OUTPUT AN M*N DOUBLE PRECISION VECTOR/MATRIX                          00000800
         INPUT R2,            POINTER TO 0'TH ELT. OF VECTOR/MATRIX    X00000900
               R5,            NO. OF ROWS(M)                           X00001000
               R6,            NO. OF COLOMNS(N)                        X00001100
               R7             DELTA DIMENSION                           00001200
         OUTPUT NONE                                                    00001300
         WORK  R1,F0                                                    00001400
         LHI   R1,4                                                     00001500
         LR    R7,R7                                                    00001600
         BZ    OK                                                       00001700
         CHI   R5,1                                                     00001800
         BNE   OK                                                       00001900
         LR    R1,R7                                                    00002000
OK       STH   R1,HOLD1                                                 00002100
         STH   R7,HOLD7                                                 00002200
         LR    R7,R5                                                    00002300
OLOOP    LHI   R5,1                                                     00002400
         ACALL SKIP                                                     00002500
         ACALL COLUMN                                                   00002600
         LR    R5,R6                                                    00002700
LOOP     LED   F0,4(R2)                                                 00002800
         ACALL DOUT                                                     00002900
         AH    R2,HOLD1                                                 00003000
         BCT   R5,LOOP                                                  00003100
         AH    R2,HOLD7                                                 00003200
         BCT   R7,OLOOP                                                 00003300
         AEXIT                                                          00003400
         ACLOSE                                                         00003500
