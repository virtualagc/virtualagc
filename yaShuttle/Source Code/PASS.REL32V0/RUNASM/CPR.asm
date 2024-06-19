*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CPR.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CPR--CHARACTER COMPARE'                                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CPR      AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
* COMPARE CHARACTER STRINGS C1 AND C2 FOR EITHER = OR ^=.               00000400
*                                                                       00000500
         INPUT R2,            CHARACTER(C1)                            X00000600
               R3             CHARACTER(C2)                             00000700
         OUTPUT CC                                                      00000800
         WORK  R5,R6                                                    00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   GO TO CPRC                                                          00001200
*                                                                       00001300
CPRC     AENTRY                                                         00001400
*                                                                       00001500
* COMPARE CHARACTER STRINGS C1 AND C2 FOR COLLATING SEQUENCE.           00001600
*                                                                       00001700
         INPUT R2,            CHARACTER(C1)                            X00001800
               R3             CHARACTER(C2)                             00001900
         OUTPUT CC                                                      00002000
         WORK  R5,R6                                                    00002100
*                                                                       00002200
* ALGORITHM:                                                            00002300
*   TEMP = MIN(CURRENT_LENGTH(C1), CURRENT_LENGTH(C2));                 00002400
*   TEMP1 = SHR(TEMP + 2, 1);                                           00002500
*   DO FOR I = 1 TO TEMP1 - 1;                                          00002600
*     IF C1$(2 AT 2 * I - 1) = C2$(2 AT 2 * I - 1) THEN                 00002700
*       REPEAT;                                                         00002800
*     ELSE                                                              00002900
*       RETURN CC;                                                      00003000
*   END;                                                                00003100
*   IF ODD(TEMP) THEN                                                   00003200
*     DO;                                                               00003300
*       IF C1$(TEMP) ^= C2$(TEMP) THEN                                  00003400
*         RETURN CC;                                                    00003500
*     END;                                                              00003600
*   RETURN CC(COMPARE(LENGTH(C1), LENGTH(C2)));                         00003700
*                                                                       00003800
         IAL   R2,0(R2)       SAVE POINTER TO C1 IN BOTTOM OF R2        00003900
         IAL   R3,0(R3)       SAVE POINTER TO C2 IN BOTTOM OF R2        00004000
         LH    R6,0(R2)       GET DESCRIPTOR OF C1                      00004100
         NHI   R6,X'00FF'     MASK OFF MAXIMUM LENGTH                   00004200
         LH    R5,0(R3)       GET DESCRIPTOR OF C2                      00004300
         NHI   R5,X'00FF'     MASK OFF MAXIMUM LENGTH                   00004400
         CR    R5,R6          COMPARE LENGTH(C2) WITH LENGTH(C1)        00004500
         BNL   UPR6           IF >= THEN BRANCH                         00004600
         LR    R6,R5          ELSE PUT LENGTH(C2) IN R6                 00004700
UPR6     AHI   R6,X'0002'     GET TEMP + 2                              00004800
         SRL   R6,1           TEMP1 = HALFWORD COUNT + 1 IF TEMP EVEN,  00004900
*                             HALFWORD COUNT IF TEMP IS ODD             00005000
         B     L2                                                       00005100
L1       LH    R5,1(R2)       GET HALFWORD OF C1                        00005200
         CH    R5,1(R3)       COMPARE WITH HALFWORD OF C2               00005300
         BNE   EXIT           IF NOT EQUAL THEN EXIT WITH CC            00005400
         AHI   R2,1           BUMP C1 PTR TO NEXT HALFWORD              00005500
         AHI   R3,1           BUMP C2 PTR TO NEXT HALFWORD              00005600
L2       BCTB  R6,L1                                                    00005700
         LR    R6,R6          SET CONDITION CODE                        00005800
         BZ    LAST           IF ZERO THEN CHECK THE LENGTHS            00005900
*                                                                       00006000
* NOTE THAT THE LR WILL NOT RETURN A 0 RESULT IN THE EVENT THAT         00006100
*   THE MINIMAL COMPARE COUNT WAS ODD DUE TO THE USE OF THE             00006200
*   SRL R6,1 INSTRUCTION WHICH WOULD SHIFT A 1 INTO THE HIGHER          00006300
*   ORDER BIT OF THE LOWER HALF OF R6 WHICH REMAINS UNCHANGED           00006400
*   IN THE INTERVENING CODE.                                            00006500
*                                                                       00006600
         LH    R6,1(R2)       GET HALFWORD WITH LAST CHARACTER OF C1    00006700
         NHI   R6,X'FF00'     MASK OFF UNWANTED CHARACTER               00006800
         LH    R5,1(R3)       GET HALFWORD WITH LAST CHARACTER OF C2    00006900
         NHI   R5,X'FF00'     MASK OFF UNWANTED CHARACTER               00007000
         CR    R6,R5          COMPARE C1 CHAR WITH C2 CHAR              00007100
         BNE   EXIT           IF ^= THEN RETURN WITH CC                 00007200
LAST     SLDL  R2,16          RECOVER POINTERS                          00007300
         LH    R6,0(R2)       GET DESCRIPTOR OF C1                      00007400
         NHI   R6,X'00FF'     MASK OFF MAXIMUM LENGTH                   00007500
         LH    R5,0(R3)       GET DESCRIPTOR OF C2                      00007600
         NHI   R5,X'00FF'     MASK OFF MAXIMUM LENGTH                   00007700
         CR    R6,R5          COMPARE LENGTH(C1) WITH LENGTH(C2)        00007800
*                             TO SET CC                                 00007900
EXIT     AEXIT CC=KEEP                                                  00008000
         ACLOSE                                                         00008100
