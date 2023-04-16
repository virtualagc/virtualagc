*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM6DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM6DN--MATRIX(M,N) MATRIX(N,R) MULTIPLY, DP'            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM6DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPUTES THE MATRIX PRODUCT:                                          00000400
*                                                                       00000500
*          M(M,R) = M1(M,N) M2(N,R)                                     00000600
*                                                                       00000700
*   WHERE ONE OR MORE OF M, N, R IS NOT EQUAL TO 3.                     00000800
*                                                                       00000900
         INPUT R2,            MATRIX(M,N) DP                           X00001000
               R3,            MATRIX(N,R) DP                           X00001100
               R5,            INTEGER(M) SP                            X00001200
               R6,            INTEGER(N) SP                            X00001300
               R7             INTEGER(R) SP                             00001400
         OUTPUT R1            MATRIX(M,R) DP                            00001500
         WORK  R4,F0,F2,F3,F4,F5                                        00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   DO FOR I = 1 TO M;                                                  00001900
*     DO FOR J = 1 TO R;                                                00002000
*       ACC = 0;                                                        00002100
*       DO FOR K = 1 TO N;                                              00002200
*         ACC = ACC + M1$(I,K) * M2$(K,J);                              00002300
*       END;                                                            00002400
*       M$(I,J) = ACC;                                                  00002500
*     END;                                                              00002600
*   END;                                                                00002700
*                                                                       00002800
         IAL   R3,0           CLEAR LOWER HALVES OF R3 AND R5           00002900
         IAL   R5,0                                                     00003000
         XUL   R5,R3          PLACE M IN LOWER HALF OF R3               00003100
         LR    R5,R7          PLACE R IN R5                             00003200
         SLL   R5,2           GET # HALFWORDS / ROW OF M2               00003300
         LFLR  F4,R4          SAVE RETURN ADDRESS IN F4                 00003400
         LR    R4,R6          PLACE N IN R4                             00003500
         SLL   R4,2           GET # HALFWORDS / ROW OF M1               00003600
         SRR   R3,16          GET M TO UPPER HALF OF R3                 00003700
LOOP3    SRR   R3,16          GET M TO LOWER HALF OF R3                 00003800
         LR    R7,R5          PLACE # HALFWORDS / ROW OF M2 IN R7       00003900
         SRL   R7,2           GET BACK R                                00004000
LOOP2    LFLR  F5,R3          SAVE (ADDR(M2) || M)                      00004100
         SEDR  F0,F0                                                    00004200
LOOP1    LE    F2,4(R3)       GET LEFT HALF OF M2 ELEMENT               00004300
         LE    F3,6(R3)       GET RIGHT HALF OF M2 ELEMENT              00004400
         MED   F2,4(R2)                                                 00004500
         AEDR  F0,F2          ACCUMULATE ROW BY ROW RESULT              00004600
         LA    R2,4(R2)       BUMP M1 PTR ALONG ROW                     00004700
         AR    R3,R5          BUMP M2 PTR ALONG COLUMN                  00004800
         BCTB  R6,LOOP1       (K = 1 TO N COUNTER)                      00004900
         LR    R6,R4          PLACE # HALFWORDS / ROW OF M1 IN R6       00005000
         SRL   R6,2           GET BACK N                                00005100
         STED  F0,4(R1)       STORE ROW RESULT                          00005200
         LA    R1,4(R1)       BUMP M PTR TO NEXT ELEMENT                00005300
         LFXR  R3,F5          GET BACK (ADDR(M2) || M)                  00005400
         AHI   R3,4           BUMP M2 PTR BY 4                          00005500
         SR    R2,R4          RESET R2 TO BEGINNING OF ROW              00005600
         BCTB  R7,LOOP2       (J = 1 TO R COUNTER)                      00005700
         AR    R2,R4          BUMP M1 PTR TO NEXT ROW OF M1             00005800
         SR    R3,R5          RESET R3 TO BEGINNING OF M2               00005900
         SRR   R3,16          PLACE COLUMN PTR(I) IN UPPER HALF OF R3   00006000
         BCTB  R3,LOOP3       (I = 1 TO M COUNTER)                      00006100
         LFXR  R4,F4          GET BACK RETURN ADDRESS                   00006200
         AEXIT                                                          00006300
         ACLOSE                                                         00006400
