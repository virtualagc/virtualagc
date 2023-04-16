*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MR1TNP.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MR1TNP--REMOTE PARTITIONED MATRIX MOVE, DP TO SP'       00000100
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
MR1TNP   AMAIN                                                          00000700
*                                                                       00000800
* MOVE AN N X M PARTITION OF M1 TO ALL OR AN N X M PARTITION OF M2 OR   00000900
*   MOVE ALL OF M1 TO AN N X M PARTITION OF M2, WHERE M1 IS A DOUBLE    00001000
*   PRECISION MATRIX AND M2 IS A SINGLE PRECISION MATRIX, ONE OF WHICH  00001100
*   IS REMOTE.                                                          00001200
*                                                                       00001300
         INPUT R4,            ZCON(MATRIX(N,M)) DP                     X00001400
               R5,            INTEGER(N) SP                            X00001500
               R6,            INTEGER(M) SP                            X00001600
               R7             INTEGER(INDEL || OUTDEL) SP               00001700
         OUTPUT R2            ZCON(MATRIX(N,M)) SP                      00001800
         WORK  R3,F0                                                    00001900
*                                                                       00002000
* ALGORITHM:                                                            00002100
*   SEE ALGORITHM DESCRIPTION IN MR1DNP                                 00002200
*                                                                       00002300
         ST    R2,TARG2       STORE OUTPUT ZCON IN TARG2                00002400
         ST    R4,TARG4       STORE INPUT ZCON IN TARG4                 00002500
         SR    R3,R3          CLEAR R3                                  00002600
         XUL   R3,R7          PLACE OUTDEL IN R3                        00002700
         LR    R4,R6          PLACE M IN R4                             00002800
         SLL   R4,1           GET # OF HALFWORDS / ROW OF               00002900
*                             SP N X M PARTITION                        00003000
         AR    R3,R4          ADD SP ROWLENGTH TO OUTDEL                00003100
*                             (ACTUAL ROW LENGTH OF RECEIVER)           00003200
         SLL   R4,1           GET # OF HALFWORDS / ROW OF               00003300
*                             DP N X M PARTITION                        00003400
         AR    R7,R4          ADD DP ROWLENGTH TO INDEL                 00003500
*                             (ACTUAL ROW LENGTH OF SOURCE)             00003600
         LR    R4,R6          SAVE M IN R4                              00003700
MR1TNPX  LED@# F0,TARG4(R6)                                             00003800
         STE@# F0,TARG2(R6)                                             00003900
         BCTB  R6,MR1TNPX                                               00004000
         LR    R6,R4          RESET R6 TO M                             00004100
         AST   R7,TARG4       BUMP INPUT PTR TO NEXT ROW                00004200
         AST   R3,TARG2       BUMP OUTPUT PTR TO NEXT ROW               00004300
         BCTB  R5,MR1TNPX                                               00004400
         AEXIT                                                          00004500
         ACLOSE                                                         00004600
