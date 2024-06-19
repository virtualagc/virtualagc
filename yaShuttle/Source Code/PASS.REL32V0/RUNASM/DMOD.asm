*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    DMOD.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

*                                                                       00000401
         TITLE 'DMOD - MOD FUNCTION, DOUBLE PREC. SCALAR'               00000500
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
DMOD     AMAIN INTSIC=YES                                               00000600
*                                                                       00000700
*   COMPUTES THE MOD INSTRUCTION :                                      00000803
*                                                                       00000900
*    MOD(A,B)                                                           00001000
*                                                                       00001100
*   WHERE  A OR B OR BOTH ARE DP                                        00001200
*                                                                       00001300
* REVISION HISTORY :                                                    00001405
*                                                                       00001505
* 16 JAN 89 - ROBERT HANDLEY - DR63480                                  00001605
*   REPLACED IDEDR MACRO WITH DEDR INSTRUCTION. ALSO HAD TO ADD A CED   00001711
*   INSTRUCTION FOLLOWING THE DEDR BECAUSE THE IDEDR MACRO SET THE      00002011
*   CONDITION CODE WHICH IS TESTED FOR LATER FOR A RESULT OF ZERO.      00002211
*   SINCE THE DEDR INSTRUCTION DOES NOT SET THE CONDITION CODE A CHECK  00002311
*   FOR A ZERO RESULT WAS ADDED TO SET THE CONDITION CODE.              00002511
*   BECAUSE OF THE REMOVAL THE IDEDR MACRO THIS ROUTINE WILL NO LONGER  00002712
*   WORK ON THE AP101/B.                                                00002812
*                                                                       00002912
* 16 DEC 89 - JOYCE CRAWLEY - DR103762                                  00003016
*   REPLACED QCED MACRO WITH CED INSTRUCTION                            00003116
*                                                                       00003216
* 26 JAN 93 - ROBERT HANDLEY - DR103781,CR11163,CR11164
*   DR103781 - REVISED ALGORITHM TO REMOVE FLAWED FLOOR FUNCTION
*   CR11163  - REPLACED BROKEN CEDR INTRUCTIONS WITH IBMCEDR MACRO
*   CR11164  - REPLACED BROKEN DEDR INTRUCTIONS WITH I2DEDR MACRO
*
         INPUT F0,            SCALAR  DP                               X00003313
               F2             SCALAR  DP                                00003400
         OUTPUT F0            SCALAR  DP                                00003500
         WORK  F1,F3,F4,F5,F6,F7                                        00003600
*                                                                       00003700
         LER   F2,F2      CHECK B
         BP    MOD         IF B POSITIVE, CONTINUE
         BM    COMPB       IF B NEGATIVE, COMPLEMENT B
         LER   F0,F0      SPECIAL CASE: B=0, CHECK A
         BNM   EXIT        IF A>=0, RETURN A
         B     LOGERR      ELSE LOG ERROR, RETURN ZERO
*
COMPB    LECR  F2,F2      USE |B|
MOD      LER   F5,F1      COPY A INTO F4,F5
         LER   F4,F0
         BN    NEGA
*
* A IS POSITIVE
*
         IBMCEDR F4,F2    PREDIVIDE CHECK: A < |B|?
         BL    EXIT        IF TRUE, RETURN A
         I2DEDR F4,F2,F0,F6  A/|B|
         AED   F4,BIGNUM  FLOOR(A/|B|)
         SED   F4,BIGNUM
         MEDR  F4,F2      |B| * FLOOR(A/|B|)
         SEDR  F0,F4      A - |B| * FLOOR(A/|B|)
*
* PERFORM EXIT VALIDATION CHECKS
*
VALID8   BM    VLOW
VHI      IBMCEDR F0,F2    ANS >= 0
         BL    EXIT        IF ANS < |B|, VALID ANS, RETURN
         SEDR  F0,F2       ELSE ADJUST FOR 1 LOST |B|
         IBMCEDR F0,F2
         BL    EXIT       NOW IF ANS < |B|, VALID ANS, RETURN
         B     FIXUP       ELSE MAJOR FAULT, TAKE FIXUP RETURN
*
VLOW     AEDR  F0,F2      ANS < 0, MAY MEAN 1 LOST |B|
         BNM   EXIT       NOW IF ANS >= 0, VALID ANS, RETURN
         B     FIXUP       ELSE MAJOR FAULT, TAKE FIXUP RETURN
*
* A IS NEGATIVE
*
NEGA     LECR  F4,F4      USE |A|
         IBMCEDR F4,F2    PREDIVIDE CHECK: A < |B|?
         BHE   AGEB        IF |A| >= |B|, CONTINUE WITH ROUTINE
         AEDR  F0,F2       ELSE A + |B| IS THE ANS
         B     VALID8     VALIDATE FOR =|B| CASE
AGEB     I2DEDR F4,F2,F0,F6  CALCULATE |A|/|B|
         LECR  F0,F0      REFORM A FROM |A| (F4 -> F0 DURING IDEDR)
         AED   F4,BIGNUM  FLOOR(|A|/|B|)
         SED   F4,BIGNUM
         MEDR  F4,F2      |B| * FLOOR(|A|/|B|)
         AEDR  F0,F4      A + |B| * FLOOR(|A|/|B|)
*
* AT THIS POINT THE ANSWER SHOULD BE -|B|<= ANS <= 0.
*
         BNM   VALID8     SHOULD TAKE BRANCH FOR ZERO RESULT ONLY
         AEDR  F0,F2      IF ANS IS < 0 ADD 1 MORE |B|
         B     VALID8     VALIDATE ANSWER
*
* MAJOR ALGORITHMIC ERROR ENCOUNTERED
*
FIXUP    SEDR  F0,F0      RETURN 0
         AERROR 33        LOG GPC ERROR
         B     EXIT
*
LOGERR   SEDR  F0,F0      RETURN ZERO
         AERROR 19        LOG GPC ERROR
*
* COMMON EXIT
*
EXIT     AEXIT                                                          00007100
*
BIGNUM   DC    X'4E80000000000000'                                      00007312
         ACLOSE                                                         00008000
