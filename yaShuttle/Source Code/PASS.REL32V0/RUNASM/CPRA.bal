*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CPRA.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CPRA--COMPARE ARRAYS OF CHARACTER STRINGS'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG2    DS    F                                                        00000400
TARG4    DS    F                                                        00000500
         MEND                                                           00000600
CPRA     AMAIN                                                          00000700
*                                                                       00000800
* COMPARE C1 AND C2 WHERE C1 AND C2 ARE LENGTH N ARRAYS OF              00000900
*   MAXIMUM LENGTH M CHARACTER STRINGS.                                 00001000
*                                                                       00001100
         INPUT R2,            ARRAY(N) CHARACTER(M) C1                 X00001200
               R4,            ARRAY(N) CHARACTER(M) C2                 X00001300
               R6,            INTEGER(FLOOR((M+1)/2)+1) SP             X00001400
               R7             INTEGER(N)                                00001500
         OUTPUT CC                                                      00001600
         WORK  R3,R5                                                    00001700
*                                                                       00001800
* ALGORITHM:                                                            00001900
*   DO FOR I = 1 TO N;                                                  00002000
*     IF C1$(I:) = C2$(I:) THEN                                         00002100
*       ;                                                               00002200
*     ELSE                                                              00002300
*       RETURN CC;                                                      00002400
*   END;                                                                00002500
*   RETURN CC;                                                          00002600
*                                                                       00002700
         ST    R2,TARG2       SAVE R2 IN TARG2                          00002800
         ST    R4,TARG4       SAVE R4 IN TARG4                          00002900
         LR    R3,R4                                                    00003000
CPRL     ABAL  CPR            CHARACTER COMPARE CALL FOR EACH ITEM      00003100
         BNE   CPRANEQ        NOT EQUAL, EXIT                           00003200
         LH    R2,TARG2       1ST ARGUMENT                              00003300
         AH    R2,ARG6        ADVANCE TO NEXT CHARACTER STRING IN ARRAY 00003400
         STH   R2,TARG2       AND BE READY FOR NEXT                     00003500
         LH    R3,TARG4       2ND ARGUMENT                              00003600
         AH    R3,ARG6        GETS THE SAME TREATMENT                   00003700
         STH   R3,TARG4                                                 00003800
*                             ***                                       00003900
         BCT   R7,CPRL        *** WARNING.  ASSUMES R7 SAFE OVER CPR    00004000
*                             ***                                       00004100
         AEXIT CC=EQ                                                    00004200
CPRANEQ  AEXIT CC=NE                                                    00004300
         ACLOSE                                                         00004400
