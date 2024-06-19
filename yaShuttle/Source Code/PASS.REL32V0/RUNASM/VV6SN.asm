*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV6SN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV6SN -- VECTOR DOT PRODUCT,LENGTH N,SINGLE PREC'       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV6SN    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*   COMPUTES THE DOT PRODUCT:                                           00000400
*                                                                       00000500
*   S = V1(N) . V2(N)                                                   00000600
*                                                                       00000700
*  WHERE N NOT=3 & S,V1,V2  ARE SP                                      00000800
*                                                                       00000900
         INPUT R2,            VECTOR(N)   SP                           X00001000
               R3,            VECTOR(N)   SP                           X00001100
               R5             INTEGER(N)  SP                            00001200
         OUTPUT F0            SCALAR      SP                            00001300
         WORK  F2,R1                                                    00001400
*                                                                       00001500
*  ALGORITHM:                                                           00001600
*   S=0;                                                                00001700
*   DO FOR I=N TO 1;                                                    00001800
*     S=S+V1(I)*V2(I);                                                  00001900
*   END;                                                                00002000
*                                                                       00002100
         SEDR  F0,F0           S=0                                      00002200
$TIM1    LR    R1,R3                                                    00002300
LOOP     LE    F2,0(R5,R1)                                              00002400
         ME    F2,0(R5,R2)                                              00002500
         AEDR  F0,F2           S+V1(I)V2(I)                             00002600
$TIM2    BCTB  R5,LOOP        I=N T0 1 COUNTER                          00002700
         AEXIT                                                          00002800
         ACLOSE                                                         00002900
