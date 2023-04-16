*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DMAX.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'DMAX--SCALAR MAX FUNCTION, DP'                          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
DMAX     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE MAX ELEMENT OF A LENGTH N ARRAY OF DOUBLE PRECISION       00000400
*   SCALARS.                                                            00000500
*                                                                       00000600
*   REVISION HISTORY:                                                   00000702
*                                                                       00000802
*     DATE       NAME  DR/SSCR#   DESCRIPTION                           00000902
*     --------   ----  --------   ------------------------------------  00001002
*     12/16/89   JAC   DR103762   REPLACED QCED/QCEDR MACRO WITH        00001102
*                                 CED/CEDR INSTRUCTION                  00001202
*                                                                       00001302
         INPUT R2,            ARRAY(N) SCALAR DP                       X00001400
               R5             INTEGER(N) SP                             00001500
         OUTPUT F0            SCALAR DP                                 00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   CURRMAX = ARRAY$(1);                                                00001900
*   DO FOR I = 2 TO N;                                                  00002000
*     IF ARRAY$(I) > CURRMAX THEN                                       00002100
*       CURRMAX = ARRAY$(I);                                            00002200
*   END;                                                                00002300
*                                                                       00002400
         B     START          GO TO SET CURRMAX                         00002500
*                                                                       00002601
*        DR103762 - REPLACED QCED WITH CED ON NEXT LINE                 00002701
*                                                                       00002801
DLOOP    CED   F0,4(R2)       COMPARE CURRMAX TO NEXT ELEMENT           00002900
         BNL   HIGH           IF ^< THEN SKIP OVER SETTING OF CURRMAX   00003000
START    LED   F0,4(R2)       IF CURRMAX <= ARRAY$(I) THEN SET CURRMAX  00003100
HIGH     LA    R2,4(R2)       UPDATE INPUT PTR                          00003200
         BCT   R5,DLOOP                                                 00003300
         AEXIT                                                          00003400
         ACLOSE                                                         00004000
