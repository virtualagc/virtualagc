*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    KTOC.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

   TITLE 'KTOC -- BIT STRING TO CHARACTER CONVERSION(DECIMAL RADIX)'    00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
KTOC     AMAIN INTSIC=YES                                               00000200
*                                                                       00000300
*  PERFORM BIT STRING TO CHARACTER                                      00000400
*   CONVERSION WITH DECIMAL RADIX                                       00000500
*                                                                       00000600
         INPUT R5,            BIT STRING                               X00000700
               R6             INTEGER(LENG.)                            00000800
         OUTPUT R2            CHARACTER                                 00000900
         WORK  R1,R3,R4,F0,F1                                           00001000
         WORK  R7             BECAUSE OF SRDL R6,4                      00001100
*                                                                       00001200
*                                                                       00001300
*                                                                       00001400
         LFLR  F1,R4          SAVE RETURN ADDRESS                       00001500
*                                                                       00001600
*  SET UP CHARACTER AND HALFWORD COUNTS                                 00001700
*                                                                       00001800
         MH    R6,LOG2                                                  00001900
         SRL   R6,1                                                     00002000
         AHI   R6,1                                                     00002100
         LFLR  F0,R6          STORE CHARACTER COUNT                     00002200
         AHI   R6,1                                                     00002300
         SRL   R6,1           HALFWORD COUNT                            00002400
         LR    R1,R6                                                    00002500
*                                                                       00002600
*  FURTHER SETUP FOR CALCULATION                                        00002700
*                                                                       00002800
         LR    R6,R5          GET STRING IN EVEN REGISTER               00002900
*                                                                       00003000
*  CONVERT TO DECIMAL HERE. GET THE LOW-ORDER DIGIT OF X                00003100
*   AS X-10*(X/10) (INTEGER DIVISION). SAVE X/10 FOR                    00003200
*   USE AS THE NEW X.  GENERATE TWO DIGITS AT A TIME,                   00003300
*   AND STORE BY HALFWORDS FROM RIGHT TO LEFT.  NOTICE                  00003400
*   THAT THIS YIELDS A STRING WITH VARIABLE LENGTH AND                  00003500
*   ALIGNMENT, WHICH MUST BE CORRECTED WHEN THE STRING                  00003600
*   IS LEFT-JUSTIFIED IN THE OUTPUT AREA.                               00003700
*                                                                       00003800
POSINT   SRDL  R6,4                                                     00003900
         D     R6,TEN                                                   00004000
         LR    R3,R6          X/10 IN R3                                00004100
         M     R6,TEN                                                   00004200
         SLDL  R6,4           10*(X/10)                                 00004300
         SR    R5,R6          GET DIGIT AS X-10*(X/10)                  00004400
         SLL   R5,16          SHIFT TO TOP HALFWORD, LOW BYTE           00004500
         LR    R4,R5          LOW DIGIT IN R4                           00004600
*  END OF FIRST CYCLE                                                   00004700
         LR    R6,R3          NEW X = OLD X/10                          00004800
         LR    R5,R3          SAVE IN R5 AS WELL                        00004900
         SRDL  R6,4                                                     00005000
         D     R6,TEN                                                   00005100
         LR    R3,R6          X/10 IN R3                                00005200
         M     R6,TEN                                                   00005300
         SLDL  R6,4           10*(X/10)                                 00005400
         SR    R5,R6          GET DIGIT AS X-10*(X/10)                  00005500
         SLL   R5,24          SHIFT TO TOP BYTE                         00005600
         AR    R4,R5          TWO DIGITS IN R4                          00005700
         AHI   R4,X'3030'     CONVERT TO CHARACTERS                     00005800
         LR    R6,R3          NEW X = OLD X/10                          00005900
         STH   R4,0(R1,R2)                                              00006000
         LR    R5,R3                                                    00006100
         BCT   R1,POSINT                                                00006200
*                                                                       00006300
*  PUT IN LENGTH AND ALIGN CHARACTER STRING                             00006400
*                                                                       00006500
         LH    R4,0(R2)                                                 00006600
         NHI   R4,X'FF00'                                               00006700
         LFXR  R3,F0          RECOVER COUNT                             00006800
         AR    R4,R3                                                    00006900
         STH   R4,0(R2)                                                 00007000
*                                                                       00007100
         TRB   R3,X'0001'     IF COUNT IS EVEN, THE STRING              00007200
         BZ    EXIT           IS ALREADY CORRECTLY ALIGNED              00007300
*                                                                       00007400
* IF THE COUNT IS ODD, THEN THE STRING IS OFFSET BY ONE BYTE,           00007500
* SO IT MUST BE SHIFTED ONE BYTE TO THE LEFT. THE MOVE IS               00007600
* ACCOMPLISHED HERE.                                                    00007700
*                                                                       00007800
*                                                                       00007900
         LA    R3,1(R3)                                                 00008000
         SRL   R3,1           REMAINING HALFWORD COUNT                  00008100
         LH    R4,1(R2)       FIRST BYTE IN BITS 8-15                   00008200
         LA    R1,1(R2)       ADDRESS OF FIRST CHARACTER                00008300
PLOOP2   IHL   R4,1(R1)                                                 00008400
         SLL   R4,8           TWO CORRECT BYTES TOGETHER                00008500
         STH   R4,0(R1)                                                 00008600
         SLL   R4,8                                                     00008700
         LA    R1,1(R1)                                                 00008800
         BCT   R3,PLOOP2                                                00008900
*                                                                       00009000
EXIT     LFXR  R4,F1          RESTORE RETURN ADDRESS                    00009100
         AEXIT                AND EXIT                                  00009200
*                                                                       00009300
TEN      DC    F'0.625'                                                 00009400
LOG2     DC    H'19728'                                                 00009500
         ACLOSE                                                         00009600
