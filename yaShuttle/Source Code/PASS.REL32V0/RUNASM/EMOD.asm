*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    EMOD.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'EMOD - MOD FUNCTION,SINGLE PREC.SCALAR'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
EMOD     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  COMPUTES THE MOD INSTRUCTION :                                       00000400
*                                                                       00000500
*    MOD (A,B)                                                          00000600
*                                                                       00000700
*   WHERE A & B ARE SP SCALARS                                          00000800
*                                                                       00000900
* CHANGE HISTORY:                                                       00001000
*                                                                       00001100
*  DATE       AUTHOR           CHANGE DESCRIPTION                       00001200
*                                                                       00001300
*  7/14/89    DAVID E. WATSON  DR103563 - USE DOUBLE PRECISION          00001400
*                              INSTRUCTION WHEN ADDING/SUBTRACTING      00001500
*                              BIGNUM TO/FROM F4 IN TWO PLACES - THIS   00001607
*                              AVOIDS USING THE GUARD BITS, WHICH ARE   00001707
*                              IMPLEMENTED DIFFERENTLY ON THE AP101/B   00001807
*                              AP101/S                                  00001907
*                                                                       00002000
* 03/16/93    TONY VARESIC     DR103901 - 'EMOD RTL INCORRECT'. REMOVED
*                              FLNUM FROM ALGORITHM. REMOVED DR103563
*                              MODIFICATIONS BECAUSE ALGORITHM CHANGE
*                              CANNOT CAUSE A GUARD BIT PROBLEM ON
*                              NEGATIVE NUMBERS. CHANGED FIXUP VALUE
*                              FROM |B| TO ZERO FOR GPC ERROR 4:19.
*                              ADDED LOGIC TO EMIT GPC ERROR 4:33 WHEN
*                              VALIDATION CANNOT BRING ANSWER INTO
*                              VALID RANGE.
*
         INPUT F0,            SCALAR  SP                               X00002100
               F2             SCALAR  SP                                00002200
         OUTPUT F0            SCALAR  SP                                00002300
         WORK  F4
*                                                                       00002500
*                                                                       00002600
*                                                                       00002600
         LER    F2,F2      CHECK B                                      00003000
         BP     MOD        IF B POSITIVE, CONTINUE
         BM     COMPB      IF B NEGATIVE, COMPLEMENT B
         LER    F0,F0      SPECIAL CASE: B=0, CHECK A                   00003300
         BNM    EXIT       IF A POSITIVE, RETURN A                      00003400
         B      LOGERR     ELSE LOG ERROR, RETURN ZERO
*
COMPB    LECR   F2,F2      MAKE |B|                                     00003700
MOD      LER    F4,F0      STORE A IN F4                                00003800
         BN     NEGA       A IS NEGATIVE
*
* A IS POSITIVE
*
         CER    F4,F2      PREDIVIDE CHECK: A < |B|
         BL     EXIT       IF TRUE, A IS ANSWER, RETURN A
         DER    F4,F2      ELSE, CALCULATE A/|B|
         AE     F4,BIGNUM  FLOOR(A/|B|)
         SE     F4,BIGNUM
         MER    F4,F2      |B|*FLOOR(A/|B|)
         SER    F0,F4      A - |B|*FLOOR(A/|B|) (A>0)
*
* PERFORM EXIT VALIDITY CHECKS
*
VALID8   BM     VLOW       IS ANSWER < 0
VHI      CER    F0,F2      IS ANSWER >= |B|
         BL     EXIT       IF ANSWER < |B|, VALID ANSWER, RETURN
         SER    F0,F2      ELSE ADJUST FOR 1 LOST |B|
         CER    F0,F2
         BL     EXIT       NOW IF ANSWER < |B|, VALID ANSWER, RETURN
         B      FIXUP      ELSE MAJOR FAULT, TAKE FIXUP RETURN
*
VLOW     AER    F0,F2      ANSWER < 0, MAY MEAN 1 LOST |B|
         BNM    EXIT       NOW IF ANSWER >= 0, VALID ANSWER, RETURN
         B      FIXUP      ELSE, MAJOR FAULT, TAKE FIXUP RETURN
*
* A IS NEGATIVE
*
NEGA     LECR   F4,F4      MAKE |A|
         CER    F4,F2      PREDIVIDE CHECK: |A| < |B|?
         BHE    AGEB       IF NOT TRUE, CONTINUE WITH ROUTINE
         AER    F0,F2      ELSE, A + |B| IS ANSWER
         B      VALID8     VALIDATE FOR = |B| CASE
AGEB     DER    F4,F2      CALCULATE |A|/|B|
         AE     F4,BIGNUM  FLOOR(|A|/|B|)
         SE     F4,BIGNUM
         MER    F4,F2      |B|*FLOOR(|A|/|B|)
         AER    F0,F4      RESULT = A + |B|*FLOOR(|A|/|B|) (A<0)
         B      VALID8     GO TO VALIDATE ANSWER
*
* ZERO RESULT IF ALGORITHM FAILED (LOST BITS IN INTERMEDIATE STEPS)
*
FIXUP    SER    F0,F0      RETURN 0
         AERROR 33         LOG ERROR (MOD FAILURE)
         B      EXIT
*
LOGERR   SER    F0,F0      RETURN 0
         AERROR 19         LOG ERROR (MOD DOMAIN FAILURE)
*
* COMMON EXIT
*
EXIT     AEXIT                                                          00005900
         DS     0F                                                      00006000
BIGNUM   DC     X'46800000'
         ACLOSE                                                         00007000
