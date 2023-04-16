*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV3DN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV3DN -- VECTOR SUBTRACT,LENGTH N,DOUBLE PREC'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV3DN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  COMPUTES THE VECTOR SUBSTRACT:                                       00000400
*                                                                       00000500
*   V(N)= V1(N) - V2(N)                                                 00000600
*                                                                       00000700
*    WHERE N NOT=3  V,V1,V2 ARE DP                                      00000800
*                                                                       00000900
         INPUT R2,            VECTOR(N)   DP                           X00001000
               R3,            VECTOR(N)   DP                           X00001100
               R5             INTEGER(N)  DP                            00001200
         OUTPUT R1            VECTOR(N)   DP                            00001300
         WORK  F0,F1                                                    00001400
*                                                                       00001500
*   ALGORITHM:                                                          00001600
*    DO FOR I=1 TO N ;                                                  00001700
*      V(I)=V1(I)-V2(I);                                                00001800
*    END;                                                               00001900
*                                                                       00002000
         XR    R2,R3         CHANGE BETWEEN R2&R3                       00002100
         XR    R3,R2                                                    00002200
$TIM1    XR    R2,R3                                                    00002300
VV3DNL   LE    F0,4(R3)      GET V1 ELE.                                00002400
         LE    F1,6(R3)                                                 00002500
         SED   F0,4(R2)      GET V ELE.                                 00002600
         STED  F0,4(R1)      PLACE V ELE.                               00002700
         LA    R1,4(R1)      BUMP PTR BY 4                              00002800
         LA    R2,4(R2)                                                 00002900
         LA    R3,4(R3)                                                 00003000
$TIM2    BCTB  R5,VV3DNL     I=1 TO N COUNTER                           00003100
         AEXIT                                                          00003200
         ACLOSE                                                         00003300
