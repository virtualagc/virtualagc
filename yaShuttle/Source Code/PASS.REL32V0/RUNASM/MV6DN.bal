*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MV6DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MV6DN--MATRIX*VECTOR,LENGTH N,DBLE PREC'               00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MV6DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTE THE MATRIX VECTOR PRODUCT                                   00000400
*                                                                       00000500
*        V(M)=M(M,N) V1(N)                                              00000600
*                                                                       00000700
*       WHERE N,M NOT= 3                                                00000800
*                                                                       00000900
         INPUT R2,            MATRIX(M,N) DP                           X00001000
               R3,            VECTOR(N)   DP                           X00001100
               R5,            INTEGER(M)  SP                           X00001200
               R6             INTEGER(N)  SP                            00001300
         OUTPUT R1            VECTOR(M)   DP                            00001400
         WORK  R7,F0,F2,F4,F5                                           00001500
*                                                                       00001600
*   ALGORITHM:                                                          00001700
*     DO FOR I=1 TOM;                                                   00001800
*           ACC=0;                                                      00001900
*      DO FOR J=1 TO N;                                                 00002000
*        ACC=ACC+M$(I,J)*V1$(J);                                        00002100
*      END;                                                             00002200
*       V$(I)=ACC;                                                      00002300
*     END;                                                              00002400
*                                                                       00002500
* REVISION HISTORY                                                      00002600
* ----------------                                                      00002700
* DATE     NAME  REL   DR NUMBER AND TITLE                              00002800
*                                                                       00002900
* 03/15/91  RAH  23V2  CR11055 RUNTIME LIBRARY CODE COMMENT CHANGES     00003000
*                                                                       00003200
MV6DX    LFLR  F4,R3          SAVE VECTOR ADD.                          00003300
         LR    R7,R1          SAVE RESULT ADD.                          00003400
         LR    R3,R6                                                    00003500
         LFLR  F5,R6          SAVE N                                    00003600
$TIM1    SLL   R3,2                                                     00003700
LOOP1    LFXR  R1,F4          GET BACK VECTOR ADD.                      00003800
         SEDR  F2,F2                                                    00003900
LOOP2    LED   F0,0(R6,R2)    GET M ELE.                                00004000
         MED   F0,0(R6,R1)                                              00004100
         AEDR  F2,F0          TEMP SUM                                  00004200
$TIM2    BCTB  R6,LOOP2       I=N TO 1 COUNTER                          00004300
         LR    R1,R7          GET BACK RESULT ADD.                      00004400
         STED  F2,4(R1)                                                 00004500
         AHI   R7,4           BUMP V PTR BY 4                           00004600
         LFXR  R6,F5          GET BACK N                                00004700
         AR    R2,R3          BUMP M PTR TO NEXT ROW                    00004800
$TIM3    BCTB  R5,LOOP1       I=1 TO M COUNTER                          00004900
         AEXIT                                                          00005000
         ACLOSE                                                         00006000
