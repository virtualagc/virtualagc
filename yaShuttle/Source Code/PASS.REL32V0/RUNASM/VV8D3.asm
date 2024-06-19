*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV8D3.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'VV8D3--VECTOR COMPARISON, LENGTH 3 AND N, SP'           00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV8D3    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPARES V1 AND V2 WHERE V1 AND V2 ARE DOUBLE PRECISION 3 VECTORS     00000400
*                                                                       00000500
         INPUT R2,            VECTOR(3) DP                             X00000600
               R3             VECTOR(3)                                 00000700
         OUTPUT CC                                                      00000800
         WORK  R1,R5,F0                                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   DO FOR I = N TO 1 BY -1;                                            00001200
*     IF V1$(I) ^= V2$(I) THEN                                          00001300
*       EXIT;                                                           00001400
*   END;                                                                00001500
*   IF I = 0 THEN                                                       00001600
*     RETURN TRUE;                                                      00001700
*   ELSE                                                                00001800
*     RETURN FALSE;                                                     00001900
*                                                                       00002000
         LFXI  R5,3                                                     00002100
VV8DN    AENTRY                                                         00002200
*                                                                       00002300
* COMPARES V1 AND V2 WHERE V1 AND V2 ARE DOUBLE PRECISION VECTORS OF    00002400
*   LENGTH N WHERE N IS NOT EQUAL TO 3.                                 00002500
*                                                                       00002600
         INPUT R2,            VECTOR(N) DP                             X00002700
               R3,            VECTOR(N) DP                             X00002800
               R5             INTEGER(N) SP                             00002900
         OUTPUT CC                                                      00003000
         WORK  R1,F0                                                    00003100
*                                                                       00003200
* ALGORITHM:                                                            00003300
*   DO FOR I = N TO 1 BY -1;                                            00003400
*     IF V1$(I) ^= V2$(I) THEN                                          00003500
*       EXIT;                                                           00003600
*   END;                                                                00003700
*   IF I = 0 THEN                                                       00003800
*     RETURN TRUE;                                                      00003900
*   ELSE                                                                00004000
*     RETURN FALSE;                                                     00004100
*                                                                       00004200
         LR    R1,R3          MORE CONVENIENT FOR ADDRESING             00004300
VV8DNL   LED   F0,0(R5,R2)    GET ELEMENT FROM INPUT                    00004400
         SED   F0,0(R5,R1)    COMPARE WITH CORREPONDING ELEMENT         00004500
         BNE   VV8DNEQ        EXIT IF NOT EQUAL                         00004600
         BCTB  R5,VV8DNL                                                00004700
VV8DNEQ  AEXIT CC=(R5)                                                  00004800
         ACLOSE                                                         00004900
