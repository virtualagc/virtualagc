*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DMIN.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'DMIN--SCALAR MIN FUNCTION, DP'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
DMIN     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE MINIMAL ELEMENT OF A LENGTH N ARRAY OF DOUBLE PRECISION   00000400
*   SCALARS.                                                            00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) SCALAR DP                       X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR DP                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   CURRMIN = ARRAY$(1);                                                00001200
*   DO FOR I = 2 TO N;                                                  00001300
*     IF CURRMIN <  ARRAY$(I) THEN                                      00001400
*       CURRMIN = ARRAY$(I);                                            00001500
*   END;                                                                00001600
*                                                                       00001700
         B     START          GO TO SET CURRMIN                         00001800
DLOOP   QCED   F0,4(R2)       COMPARE CURRMIN TO NEXT ELEMENT           00001900
         BNH   LOW            IF ^> THEN SKIP AROUND ASSIGNMENT         00002000
START    LED   F0,4(R2)       SET CURRMIN TO NEW MINIMAL ELEMENT        00002100
LOW      LA    R2,4(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00002200
         BCT   R5,DLOOP                                                 00002300
         AEXIT                                                          00002400
         ACLOSE                                                         00002500
