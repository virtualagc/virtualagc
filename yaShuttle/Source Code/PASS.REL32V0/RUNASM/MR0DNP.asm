*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MR0DNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MR0DNP--SCALAR TO REMOTE PARTITIONED MATRIX MOVE, DP'   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG2    DS    F                                                        00000400
         MEND                                                           00000500
MR0DNP   AMAIN                                                          00000600
*                                                                       00000700
* FILL AN N X M PARTITION OF A REMOTE DOUBLE PRECISION MATRIX WITH      00000800
*   A DOUBLE PRECISION SCALAR                                           00000900
*                                                                       00001000
         INPUT R5,            INTEGER(N) SP                            X00001100
               R6,            INTEGER(M) SP                            X00001200
               R7,            INTEGER(OUTDEL) SP                       X00001300
               F0             SCALAR DP                                 00001400
         OUTPUT R2            ZCON(MATRIX(N,M)) DP                      00001500
*                                                                       00001600
* ALGORITHM:                                                            00001700
*   DO FOR I = 1 TO N;                                                  00001800
*     DO FOR J = 1 TO M;                                                00001900
*       M$(I,J) = F0;                                                   00002000
*     END;                                                              00002100
*   END;                                                                00002200
*                                                                       00002300
         ST    R2,TARG2       SAVE ZCON IN TARG2                        00002400
         LR    R2,R6          PUT M IN R2                               00002500
         SLL   R2,2           GET # OF HALFWORDS / ROW OF               00002600
*                             PARTITION OF MATRIX                       00002700
         AR    R7,R2          GET # OF HALFWORDS / ROW OF MATRIX        00002800
         LR    R2,R6          SAVE M IN R2                              00002900
MR0DNPX  STED@# F0,TARG2(R6)                                            00003000
         BCTB  R6,MR0DNPX                                               00003100
         LR    R6,R2          RESET R6 TO M                             00003200
         AST   R7,TARG2        BUMP OUTPUT PTR TO NEXT ROW              00003300
         BCTB  R5,MR0DNPX                                               00003400
         AEXIT                                                          00003500
         ACLOSE                                                         00003600
