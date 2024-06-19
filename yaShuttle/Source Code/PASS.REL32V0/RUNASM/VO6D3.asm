*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VO6D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VO6D3--VECTOR OUTER PRODUCT, LENGTH 3, DP'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VO6D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* TAKES THE OUTER PRODUCT OF TWO DOUBLE PRECISION 3-VECTORS.            00000400
*                                                                       00000500
         INPUT R2,            VECTOR(3) DP                             X00000600
               R3             VECTOR(3) DP                              00000700
         OUTPUT R1            MATRIX(3,3) DP                            00000800
         WORK  R5,R6,F0,F1                                              00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   DO FOR I = 1 TO 3;                                                  00001200
*      DO FOR J = 3 TO 1 BY -1;                                         00001300
*        M$(I,J) = V1$(I) V2$(J);                                       00001400
*      END;                                                             00001500
*    END;                                                               00001600
*                                                                       00001700
         LA    R5,3           INSERT COUNT IN R5                        00001800
         XR    R2,R3          SWITCH R2 AND R3                          00001900
         XR    R3,R2                                                    00002000
         XR    R2,R3                                                    00002100
         NOPR  R1             NOP TO ALIGN MED AND STED ON EVEN         00002200
*                             BOUNDARIES                                00002300
LOOP2    LA    R6,3           RESET R6                                  00002400
LOOP1    LE    F0,4(R3)       GET V1 ELEMENT                            00002500
         LE    F1,6(R3)       GET OTHER HALF OF V1 ELEMENT              00002600
         MED   F0,0(R6,R2)                                              00002700
         STED  F0,0(R6,R1)                                              00002800
         BCTB  R6,LOOP1                                                 00002900
         LA    R3,4(R3)       BUMP V1 PTR TO NEXT ELEMENT               00003000
         LA    R1,12(R1)      BUMP OUTPUT PTR TO NEXT ROW               00003100
         BCTB  R5,LOOP2                                                 00003200
         AEXIT                                                          00003300
         ACLOSE                                                         00003400
