*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    EMIN.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'EMIN--SCALAR MIN FUNCTION, SP'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
EMIN     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE MINIMAL ELEMENT OF A LENGTH N ARRAY OF SINGLE PRECISION   00000400
*   SCALARS.                                                            00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) SCALAR SP                       X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR SP                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   SEE ALGORITHM DESCRIPTION IN DMIN                                   00001200
*                                                                       00001300
         B     START          GO TO SET CURRMIN                         00001400
ELOOP    CE    F0,2(R2)       COMPARE CURRMIN TO NEXT ELEMENT           00001500
         BNH   LOW            IF ^> THEN SKIP OVER ASSIGNMENT           00001600
START    LE    F0,2(R2)       RESET CURRMIN                             00001700
LOW      LA    R2,2(R2)       UPDATE PTR                                00001800
         BCT   R5,ELOOP                                                 00001900
         AEXIT                                                          00002000
         ACLOSE                                                         00002100
