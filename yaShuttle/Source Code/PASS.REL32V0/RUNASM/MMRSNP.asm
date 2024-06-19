*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MMRSNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

MMRSNP  TITLE 'SINGLE PRECISION VECTOR/MATRIX INPUT INTERFACE'          00000100
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
MMRSNP  AMAIN ACALL=YES                                                 00000700
* READS AN M*N SINGLE PRECION VECTOR/MATRIX                             00000710
         INPUT R5,            NO. OF ROWS(M)                           X00000720
               R6,            NO. OF COLLUMNS(N)                       X00000730
               R7             DELTA DIMENSION                           00000740
         OUTPUT R2            DESCRIPTOR FOR VECTOR/MATRIX              00000750
         WORK  R1                                                       00000760
         LHI   R1,2                                                     00000800
         LR    R7,R7                                                    00000900
         BZ    OK                                                       00001000
         CHI   R5,1                                                     00001100
         BNE   OK                                                       00001200
         LR    R1,R7                                                    00001300
OK       STH   R1,HOLD1                                                 00001400
         STH   R7,HOLD7                                                 00001500
         LR    R7,R5                                                    00001600
         LA    R2,2(R2)                                                 00001650
OLOOP    EQU   *                                                        00001700
         LR    R5,R6                                                    00002000
LOOP     EQU   *                                                        00002100
         ACALL EIN                                                      00002200
         AH    R2,HOLD1                                                 00002300
         BCT   R5,LOOP                                                  00002400
         AH    R2,HOLD7                                                 00002500
         BCT   R7,OLOOP                                                 00002600
         AEXIT                                                          00002700
         ACLOSE                                                         00002800
