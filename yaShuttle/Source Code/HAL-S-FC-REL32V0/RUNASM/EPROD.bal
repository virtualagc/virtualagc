*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    EPROD.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'EPROD--SCALAR PROD FUNCTION,SP'                         00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
EPROD    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE PRODUCT OF ALL THE ELEMENTS OF A LENGTH N ARRAY OF        00000400
*   SINGLE PRECISION SCALARS.                                           00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) SCALAR SP                       X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT F0            SCALAR SP                                 00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   SEE ALGORITHM DESCRIPTION IN DPROD                                  00001200
*                                                                       00001300
         LE    F0,=E'1'       INITIALIZE ACCUMULATOR                    00001400
LOOPE    ME    F0,2(R2)       MULTIPLY BY NEXT ELEMENT                  00001500
         LER   F0,F0          SET CONDITION CODE                        00001600
         BZ    EXIT           PROD=0 SO RETURN                          00001700
         LA    R2,2(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00001800
         BCT   R5,LOOPE                                                 00001900
EXIT     AEXIT                                                          00002000
         ACLOSE                                                         00002100
