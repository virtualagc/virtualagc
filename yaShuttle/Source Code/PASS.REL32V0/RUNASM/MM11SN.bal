*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MM11SN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE  'MM11SN--MATRIX TRANSPOSE, LENGTH N, SP'                00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
MM11SN   AMAIN  INTSIC=YES                                              00000200
*                                                                       00000300
* TO CREATE THE SINGLE PRECISION TRANSPOSE OF AN N X M MATRIX WHERE     00000400
*   EITHER N AND/OR M ARE NOT EQUAL TO 3                                00000500
*                                                                       00000600
         INPUT R5,           INTEGER(M) SP                             X00000700
               R2,           MATRIX(N,M) SP                            X00000800
               R6            INTEGER(N) SP                              00000900
         OUTPUT R1           MATRIX(M,N) SP                             00001000
         WORK   R3,R7,F0,F1                                             00001100
*                                                                       00001200
* ALGORITHM:                                                            00001300
*   SEE ALGORITHM DESCRIPTION IN MM11DN                                 00001400
*                                                                       00001500
         LR     R7,R5        SAVE # OF ROWS OF RESULT                   00001600
         LFLR   F1,R6        SAVE # OF COLUMNS OF RESULT                00001700
ILOOP    LA     R2,2(R2)     BUMP INPUT PTR TO FIRST ENTRY OF COLUMN    00001800
*                            BEING PROCESSED                            00001900
         SR     R3,R3        SET INDEX REG TO 0                         00002000
JLOOP    LE     F0,0(R3,R2)                                             00002100
         LA     R1,2(R1)     BUMP OUTPUT PTR TO NEXT ELEMENT            00002200
         STE    F0,0(R1)                                                00002300
         AR     R3,R7        BUMP INDEX REG TO POINT TO NEXT COLUMN     00002400
*                            ELEMENT OF INPUT MATRIX                    00002500
         BCTB   R6,JLOOP                                                00002600
         LFXR   R6,F1        RESTORE # OF COLUMNS COUNT                 00002700
         BCTB   R5,ILOOP                                                00002800
         AEXIT                                                          00002900
         ACLOSE                                                         00003000
