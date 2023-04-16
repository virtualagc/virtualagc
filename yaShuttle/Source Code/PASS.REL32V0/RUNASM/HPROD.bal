*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    HPROD.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'HPROD--INTEGER PROD FUNCTION, SP'                       00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
HPROD    AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* RETURNS THE PRODUCT OF ALL THE ELEMENTS OF A LENGTH N ARRAY OF        00000400
*   SINGLE PRECISION INTEGERS.                                          00000500
*                                                                       00000600
         INPUT R2,            ARRAY(N) INTEGER SP                      X00000700
               R5             INTEGER(N) SP                             00000800
         OUTPUT R5            INTEGER SP                                00000900
         WORK  R6                                                       00001000
*                                                                       00001100
* ALGORITHM:                                                            00001200
*   SEE ALGORITHM DESCRIPTION IN DPROD                                  00001300
*                                                                       00001400
         LH    R6,=H'1'       SET ACCUMULATOR TO 1                      00001500
LOOPH    MIH   R6,1(R2)       MULT BY NEXT ELT.                         00001600
         LR    R6,R6          SET CONDITION CODE                        00001700
         BZ    SHIFT          PROD=0 SO RETURN                          00001800
         LA    R2,1(R2)       BUMP INPUT PTR TO NEXT ELEMENT            00001900
         BCT   R5,LOOPH                                                 00002000
SHIFT    LR    R5,R6          ANSWER EXPECTED IN R5                     00002100
         AEXIT                                                          00002200
         ACLOSE                                                         00002300
