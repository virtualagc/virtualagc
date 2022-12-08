*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MR1SNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MR1SNP--REMOTE PARTITIONED MATRIX MOVE, DP'             00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG2    DS    F                                                        00000400
TARG4    DS    F                                                        00000500
         MEND                                                           00000600
MR1SNP   AMAIN                                                          00000700
*                                                                       00000800
* MOVE AN N X M PARTITION OF M1 TO ALL OR AN N X M PARTITION OF M2 OR   00000900
*   MOVE ALL OF M1 TO AN N X M PARTITION OF M2, WHERE M1 AND M2 ARE     00001000
*   SINGLE PRECISION MATRICES, AT LEAST ONE OF WHICH IS REMOTE          00001100
*                                                                       00001200
         INPUT R4,            MATRIX(N,M) SP                           X00001300
               R5,            INTEGER(N) SP                            X00001400
               R6,            INTEGER(M) SP                            X00001500
               R7             INTEGER(INDEL || OUTDEL) SP               00001600
         OUTPUT R2            MATRIX(N,M) DP                            00001700
         WORK R3,F0                                                     00001800
*                                                                       00001900
* ALGORITHM:                                                            00002000
*   SEE ALGORITHM DESCRIPTION IN MR1DNP                                 00002100
*                                                                       00002200
         ST    R2,TARG2       STORE OUTPUT ZCON IN TARG2                00002300
         ST    R4,TARG4       STORE INPUT ZCON IN TARG4                 00002400
         SR    R3,R3          CLEAR R3                                  00002500
         XUL   R3,R7          PLACE OUTDEL IN R3                        00002600
         LR    R4,R6          PLACE M IN R4                             00002700
         SLL   R4,1           GET # HALFWORDS / ROW OF                  00002800
*                             N X M PARTITION                           00002900
         AR    R3,R4          GET # HALFWORDS / ROW OF M2               00003000
         AR    R7,R4          GET # HALFWORDS / ROW OF M1               00003100
MR1SNPX  LE@#  F0,TARG4(R6)                                             00003200
         STE@# F0,TARG2(R6)                                             00003300
         BCTB  R6,MR1SNPX                                               00003400
         LH    R6,ARG6        RESET COUNTER TO M                        00003500
         AST   R7,TARG4       POINT TO NEXT 'IN' ROW                    00003600
         AST   R3,TARG2       POINT TO NEXT 'OUT' ROW                   00003700
         BCTB  R5,MR1SNPX                                               00003800
         AEXIT                                                          00003900
         ACLOSE                                                         00004000
