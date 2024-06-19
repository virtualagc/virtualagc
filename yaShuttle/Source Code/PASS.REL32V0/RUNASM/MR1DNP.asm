*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MR1DNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MR1DNP--REMOTE PARTITIONED MATRIX MOVE, DP'             00000100
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
MR1DNP   AMAIN                                                          00000700
*                                                                       00000800
* MOVE AN N X M PARTITION OF M1 TO ALL OR AN N X M PARTITION OF M2 OR   00000900
*   MOVE ALL OF M1 TO AN N X M PARTITION OF M2, WHERE M1 AND M2 ARE     00001000
*   DOUBLE PRECISION MATRICES, AT LEAST ONE OF WHICH IS REMOTE          00001100
*                                                                       00001200
         INPUT R4,            MATRIX(N,M) DP                           X00001300
               R5,            INTEGER(N) SP                            X00001400
               R6,            INTEGER(M) SP                            X00001500
               R7             INTEGER(INDEL || OUTDEL) SP               00001600
         OUTPUT R2            MATRIX(N,M) DP                            00001700
         WORK  R3,F0                                                    00001800
*                                                                       00001900
* ALGORITHM:                                                            00002000
*   DO FOR I = 1 TO N;                                                  00002100
*     DO FOR J = 1 TO M;                                                00002200
*       M2$(I,J) = M1$(I,J);                                            00002300
*     END;                                                              00002400
*   END;                                                                00002500
*                                                                       00002600
         ST    R2,TARG2       STORE OUTPUT ZCON IN TARG2                00002700
         ST    R4,TARG4       STORE INPUT ZCON IN TARG4                 00002800
         SR    R3,R3          CLEAR R3                                  00002900
         XUL   R3,R7          PLACE OUTDEL INTO R3                      00003000
         LR    R4,R6          PLACE M IN R4                             00003100
         SLL   R4,2           GET # HALFWORDS / ROW OF                  00003200
*                             N X M PARTITION                           00003300
         AR    R3,R4          GET # HALFWORDS / ROW OF M2               00003400
         AR    R7,R4          GET # HALFWORDS / ROW OF M1               00003500
MR1DNPX  LED@# F0,TARG4(R6)                                             00003600
         STED@# F0,TARG2(R6)                                            00003700
         BCTB  R6,MR1DNPX                                               00003800
         LH    R6,ARG6        RESET COUNTER TO M                        00003900
         AST   R7,TARG4       POINT TO NEXT IN ROW                      00004000
         AST   R3,TARG2       POINT TO NEXT OUT ROW                     00004100
         BCTB  R5,MR1DNPX                                               00004200
         AEXIT                                                          00004300
         ACLOSE                                                         00004400
