*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM6D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM6D3--MATRIX(3,3) MATRIX(3,3) MULTIPLY, DP'            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM6D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPUTES THE MATRIX PRODUCT:                                          00000400
*                                                                       00000500
*          M(3,3) = M1(3,3) M2(3,3)                                     00000600
*                                                                       00000700
         INPUT R2,            MATRIX(3,3) DP ( THIS IS M1 )            X00000800
               R3             MATRIX(3,3) DP ( THIS IS M2 )             00000900
         OUTPUT R1            MATRIX(3,3) DP                            00001000
         WORK  R5,R6,R7,F0,F1,F2,F3,F4,F5                               00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   DO FOR I = 1 TO 3;                                                  00001400
*     DO FOR J = 1 TO 3;                                                00001500
*       F0 = M2$(1,J);                                                  00001600
*       F0 = F0 M1$(I,1);                                               00001700
*       F2 = M2$(2,J);                                                  00001800
*       F2 = F2 M1$(I,2);                                               00001900
*       F4 = M2$(3,J);                                                  00002000
*       F4 = F4 M1$(I,3);                                               00002100
*       F0 = F0 + F2 + F4;                                              00002200
*       M$(I,J) = F0;                                                   00002300
*     END;                                                              00002400
*   END;                                                                00002500
*                                                                       00002600
         LA    R5,3           PLACE A 3 IN R5                           00002700
         LA    R6,12          PLACE A 12 IN R6                          00002800
*                             (# OF HALFWORDS / ROW)                    00002900
LOOP3    LA    R7,3           SET R7 TO 3                               00003000
LOOP2    LE    F0,4(R3)       GET LEFT HALF OF M2$(1,J)                 00003100
         LE    F1,6(R3)       GET RIGHT HALF OF M2$(1,J)                00003200
         MED   F0,4(R2)       MULTIPLY BY M1$(I,1)                      00003300
         LE    F2,16(R3)      GET LEFT HALF OF M2$(2,J)                 00003400
         LE    F3,18(R3)      GET RIGHT HALF OF M2$(2,J)                00003500
         MED   F2,8(R2)       MULTIPLY BY M1$(I,2)                      00003600
         LE    F4,28(R3)      GET LEFT HALF OF M2$(3,J)                 00003700
         LE    F5,30(R3)      GET RIGHT HALF OF M2$(3,J)                00003800
         MED   F4,12(R2)      MULTIPLY BY M1$(I,3);                     00003900
         AEDR  F0,F2          FORM SUM                                  00004000
         AEDR  F0,F4                                                    00004100
         STED  F0,4(R1)       SAVE IN RESULT MATRIX                     00004200
         LA    R1,4(R1)       BUMP OUTPUT PTR TO NEXT ELEMENT           00004300
         LA    R3,4(R3)       BUMP M2 PTR TO NEXT COLUMN                00004400
         BCTB  R7,LOOP2       (J = 1 TO 3 COUNTER)                      00004500
         LA    R2,12(R2)      BUMP M1 PTR TO NEXT ROW                   00004600
         SR    R3,R6          RESET R3 TO BEGINNING OF M2               00004700
         BCTB  R5,LOOP3       (I = 1 TO 3 COUNTER)                      00004800
         AEXIT                                                          00004900
         ACLOSE                                                         00005000
