*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM6SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'MM6SN--MATRIX(M,N) MATRIX(N,R) MULTIPLY, SP'            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM6SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPUTES THE MATRIX PRODUCT:                                          00000400
*                                                                       00000500
*          M(N,R) = M1(M,N) M2(N,R)                                     00000600
*                                                                       00000700
*   WHERE ONE OR MORE OF M, N, R IS NOT EQUAL TO 3.                     00000800
*                                                                       00000900
         INPUT R2,            MATRIX(M,N) SP                           X00001000
               R3,            MATRIX(N,R) SP                           X00001100
               R5,            INTEGER(M) SP                            X00001200
               R6,            INTEGER(N) SP                            X00001300
               R7             INTEGER(R) SP                             00001400
         OUTPUT R1            MATRIX(N,R) SP                            00001500
         WORK  R4,F0,F2,F4,F5                                           00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   SEE ALGORITHM DESCRIPTION IN MM6DN                                  00001900
*                                                                       00002000
         IAL   R3,0           CLEAR LOWER HALVES OR R3 AND R5           00002100
         IAL   R5,0                                                     00002200
         XUL   R5,R3          PLACE M IN LOWER HALF OF R3               00002300
         LR    R5,R7          PLACE R IN R5                             00002400
         SLL   R5,1           GET # HALFWORDS / ROW OF M2               00002500
         LFLR  F4,R4          SAVE RETURN ADDRESS                       00002600
         LR    R4,R6          LOAD N IN R4                              00002700
         SLL   R4,1           GET # HALFWORDS / ROW OF M1               00002800
         SRR   R3,16          PLACE M IN UPPER HALF OF R3               00002900
LOOP3    SRR   R3,16          PLACE M IN LOWER HALF OF R3               00003000
         LR    R7,R5          PUT # HALFWORDS / ROW OF M2 IN R7         00003100
         SRL   R7,1           GET BACK R                                00003200
LOOP2    LFLR  F5,R3          SAVE (ADDR(M2) || M)                      00003300
         SEDR  F0,F0          CLEAR ACC                                 00003400
LOOP1    LE    F2,2(R3)       GET ELEMENT OF M2                         00003500
         ME    F2,2(R2)       MULTIPLY BE ELEMENT OF M1                 00003600
         AEDR  F0,F2          PLACE RESULT IN ACC                       00003700
         LA    R2,2(R2)       BUMP M1 PTR TO NEXT ELEMENT IN ROW        00003800
         AR    R3,R5          BUMP M2 PTR TO NEXT ELEMENT IN COLUMN     00003900
         BCTB  R6,LOOP1                                                 00004000
         LR    R6,R4          GET # HALFWORDS / ROW OF M1               00004100
         SRL   R6,1           GET BACK N                                00004200
         STE   F0,2(R1)       STORE ACC                                 00004300
         LA    R1,2(R1)       BUMP OUTPUT PTR TO MEXT ELEMENT           00004400
         LFXR  R3,F5          GET BACK (ADDR(M2) || M)                  00004500
         AHI   R3,2           BUMP M2 PTR TO NEXT COLUMN                00004600
         SR    R2,R4          RESET M1 PTR TO BEGINNING OF ROW          00004700
         BCTB  R7,LOOP2                                                 00004800
         AR    R2,R4          BUMP M1 PTR TO NEXT ROW                   00004900
         SR    R3,R5          SET M2 PTR TO BEGINNING OF M2             00005000
         SRR   R3,16          PUT COLUMN PTR(M) IN UPPER HALF OF R3     00005100
         BCTB  R3,LOOP3                                                 00005200
         LFXR  R4,F4          GET BACK RETURN ADDRESS                   00005300
         AEXIT                                                          00005400
         ACLOSE                                                         00005500
