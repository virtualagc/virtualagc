*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MR0SNP.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MR0SNP--SCALAR TO REMOTE PARTITIONED MATRIX MOVE, SP'   00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG2    DS    F                                                        00000400
         MEND                                                           00000500
MR0SNP   AMAIN                                                          00000600
*                                                                       00000700
* FILL AN N X M PARTITION OF A REMOTE SINGLE PRECISION MATRIX WITH      00000800
*   A SINGLE PRECISION SCALAR.                                          00000900
*                                                                       00001000
         INPUT R5,            INTEGER(N) SP                            X00001100
               R6,            INTEGER(M) SP                            X00001200
               R7,            INTEGER(OUTDEL) SP                       X00001300
               F0             SCALAR SP                                 00001400
         OUTPUT R2            ZCON(MATRIX(N,M)) SP                      00001500
*                                                                       00001600
* ALGORITHM:                                                            00001700
*   SEE ALGORITHM DESCRIPTION IN MR0DNP                                 00001800
*                                                                       00001900
         ST    R2,TARG2       SAVE ZCON IN TARG2                        00002000
         LR    R2,R6          PLACE M IN R2                             00002100
         SLL   R2,1           GET # OF HALFWORDS / ROW OF               00002200
*                             PARTITION OF MATRIX                       00002300
         AR    R7,R2          GET # OF HALFWORDS / ROW OF MATRIX        00002400
         LR    R2,R6          SAVE M IN R2                              00002500
MR0SNPX  STE@# F0,TARG2(R6)                                             00002600
         BCTB  R6,MR0SNPX                                               00002700
         LR    R6,R2          RESET R6 TO M                             00002800
         AST   R7,TARG2       BUMP OUTPUT PTR TO NEXT ROW               00002900
         BCTB  R5,MR0SNPX                                               00003000
         AEXIT                                                          00003100
         ACLOSE                                                         00003200
