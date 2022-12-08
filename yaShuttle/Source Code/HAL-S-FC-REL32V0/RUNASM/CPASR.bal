*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CPASR.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CPASR - CHARACTER ASSIGN,PARTITIONED OUTPUT,REMOTE'     00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG2    DS    F                                                        00000400
TARG4    DS    F                                                        00000500
PADBLANK DS    F                                                        00000600
         MEND                                                           00000700
CPASR    AMAIN                                                          00000800
*                                                                       00000900
* ASSIGN C2 TO C1$(I TO J) WHERE C1 AND C2 ARE CHARACTER STRINGS,       00001000
*   AT LEAST ONE OF WHICH IS REMOTE.                                    00001100
*                                                                       00001200
         INPUT R4,            ZCON(CHARACTER) (C2)                     X00001300
               R5,            INTEGER(I) SP                            X00001400
               R6             INTEGER(J) SP                             00001500
         OUTPUT R2            ZCON(CHARACTER) (C1)                      00001600
         WORK  R1,R3,R7,F0,F1                                           00001700
*                                                                       00001800
* ALGORITHM:                                                            00001900
*   IF I <= 0 THEN                                                      00002000
*     DO;                                                               00002100
*       I = 1; /* FIXUP */                                              00002200
*       SEND ERROR$(4:17);                                              00002300
*     END;                                                              00002400
*   IF MAXIMUM_LENGTH(C1) < J THEN                                      00002500
*     DO;                                                               00002600
*       J = MAXIMUM_LENGTH(C1); /* FIXUP */                             00002700
*       SEND ERROR$(4:17);                                              00002800
*     END;                                                              00002900
*   IF J > CURRENT_LENGTH(C1) THEN                                      00003000
*     DESCRIPTOR(C1) = MAXIMUM_LENGTH(C1) || J;                         00003100
*   PARTITION_LENGTH = J - I + 1;                                       00003200
*   IF PARTITION_LENGTH < 0 THEN                                        00003300
*     DO;                                                               00003400
*       SEND ERROR$(4:17);                                              00003500
*       RETURN;                                                         00003600
*     END;                                                              00003700
*   NUMBER_OF_BLANKS = I - CURRENT_LENGTH(C1) - 1;                      00003800
*   IF NUMBER_OF_BLANKS > 0 THEN                                        00003900
*     DO;                                                               00004000
*       TEMP = SHR(CURRENT_LENGTH(C1) + 3,2);                           00004100
*       DO FOR K = 1 TO NUMBER_OF_BLANKS;                               00004200
*         C1$(TEMP + K) = HEX'0020';                                    00004300
*       END;                                                            00004400
*     END;                                                              00004500
*   DO FOR L = 1 TO PARTITION_LENGTH;                                   00004600
*     C1$(TEMP + K - 1 + L) = C2$(L);                                   00004700
*   END;                                                                00004800
*                                                                       00004900
         XR    R7,R7          CLEAR R7                                  00005000
         ST    R7,PADBLANK    CLEAR OUT PADBLANK                        00005100
         ST    R4,TARG4       SAVE INPUT ZCON IN TARG4                  00005200
         ST    R2,TARG2       SAVE OUTPUT ZCON IN TARG2                 00005300
         LFLI  F0,1           SET UP WHICH BYTE PTR FOR GTBYTER         00005400
         LER   F1,F0          SET UP WHICH BYTE PTR FOR STBYTER         00005500
         LR    R5,R5          SET CONDITION CODE                        00005600
         BP    L1             IF R5 = > 0 THEN OK                       00005700
         LFXI  R5,1           ELSE FIXUP IS ONE                         00005800
         AERROR 17            I <= 0                                    00005900
L1       LH@#  R3,TARG2(R7)   GET DESCRIPTOR OF DESTINATION             00006000
         SRL   R3,8           PUT MAXIMUM_LENGTH(C1) IN LOWER PART OF   00006100
*                             HALFWORD                                  00006200
         CR    R6,R3          COMPARE J WITH MAXIMUM_LENGTH(C1)         00006300
         BLE   L5             IF <= THEN OK                             00006400
         LR    R6,R3          ELSE FIXUP IS MAXLEN                      00006500
         NHI   R6,X'00FF'     CLEARS OUT THE BOTTOM HALF OF R6          00006600
         AERROR 17            J > MAXLENGTH(C1)                         00006700
L5       SLL   R3,8           GET BACK DESCRIPTOR OF C1                 00006800
         NHI   R3,X'00FF'     MASK OFF MAXIMUM_LENGTH                   00006900
L2       CR    R6,R3          COMPARE J WITH CURRENT(LENGTH(C1)         00007000
         BLE   L3             IF <= THEN GO TO L3                       00007100
         LH@#  R4,TARG2(R7)   GET DESCRIPTOR(C1)                        00007200
         ZRB   R4,X'00FF'     ZERO OUT ORIG CURRLEN                     00007300
         AR    R4,R6          GET MAXLEN || J                           00007400
         STH@# R4,TARG2(R7)   STORE NEW C1 DESCRIPTOR                   00007500
L3       SR    R6,R5          J - I + 1 =                               00007600
         AHI   R6,1           LENGTH OF PARTITION                       00007700
         BZ    L6             IF ZERO THEN NO FURTHER PROCESSING        00007800
         BP    L4             IF  > 0 THEN OK ELSE ERROR                00007900
         AERROR    17         LENGTH OF PARTITION < 0                   00008000
         B     EXIT           AND RETURN                                00008100
*                                                                       00008200
* NOTE: THE ABOVE RETURN LEAVES C1 IN AN INDETERMINATE STATE            00008300
*                                                                       00008400
L4       LH@#  R4,TARG4(R7)   GET C2 DESCRIPTOR                         00008500
         NHI   R4,X'00FF'     GET CURRENT_LENGTH(C2)                    00008600
         LR    R1,R4          SAVE CURRENT_LENGTH(C2)                   00008700
         SR    R4,R6          COMPUTE CURRLEN(C2) - PARTITION LENGTH    00008800
         BP    L6             IF > 0 THEN BRANCH                        00008900
         LR    R6,R1          ELSE SET R6 = CURRLEN(C2)                 00009000
         LCR   R4,R4          COMPUTE # OF RIGHT PAD BLANKS             00009100
         ST    R4,PADBLANK    SAVE IT AWAY                              00009200
L6       LR    R4,R5          PLACE I IN R4                             00009300
         SR    R4,R3          I - CURRENT_LENGTH(C1) - 1 =              00009400
         AHI   R4,-1          NUMBER OF INTERVENING BLANKS              00009500
         LFXI  R7,1           SET INDEX REG FOR STBYTER AND GTBYTER     00009600
         BP    LSTORE         IF R4 > 0 THEN STORE INTERVENING BLANKS   00009700
         AHI   R5,-1          ELSE I - 1 / 2 =                          00009800
         SRL   R5,1           ADDRESS TO HALFWORD CONTAINING I          00009900
         XR    R2,R2          CLEAR OUT R2                              00010000
         XUL   R2,R5          GET POSSIBLE ODD INDICATOR IN R2          00010100
         AST   R5,TARG2       INCREMENT OUTPUT ADDRESS                  00010200
         LR    R2,R2          SET CONDITION CODE                        00010300
         BNN   L7             IF >= 0 THEN BRANCH                       00010400
         LECR  F1,F1          ELSE SET RIGHT BYTE PTR                   00010500
L7       B     CSTORE         GO TO STORE CHARACTERS                    00010600
LSTORE   SRL   R3,1           ADDRESS TO START INTERVENING BLANKS       00010700
         XR    R2,R2          CLEAR OUT R2                              00010800
         XUL   R2,R3          PLACE ODD BIT IF ANY IN R2                00010900
         AST   R3,TARG2       INCREMENT OUTPUT PTR                      00011000
         LR    R2,R2          SET CONDITION CODE                        00011100
         BNN   LST            IF >= 0 THEN BRANCH                       00011200
         LECR  F1,F1          ELSE SET RIGHT BYTE PTR                   00011300
LST      LR    R1,R4          PLACE # OF BLANKS IN R1                   00011400
LST1     LHI   R5,X'0020'     PLACE DEU BLANK IN R5                     00011500
         BAL   R4,STBYTER     BRANCH TO STORE CHAR ROUTINE              00011600
         BCTB  R1,LST1                                                  00011700
CSTORE   LR    R6,R6          SET CONDITION CODE                        00011800
         BZ    L8             IF ZERO THEN NO CHARS TO STORE            00011900
CST      BAL   R4,GTBYTER     GET A CHAR                                00012000
         BAL   R4,STBYTER     STORE A CHAR                              00012100
         BCTB  R6,CST                                                   00012200
L8       L     R6,PADBLANK    GET NUMBER OF RIGHT PAD BLANKS            00012300
         BZ    EXIT           IF ZERO THEN EXIT                         00012400
RSTORE   LHI   R5,X'0020'                                               00012500
         BAL   R4,STBYTER                                               00012600
         BCTB  R6,RSTORE                                                00012700
EXIT     AEXIT                                                          00012800
*                                                                       00012900
* THIS CODE CORRESPONDS TO STBYTE FOR REMOTE DATA                       00013000
*   F1 = WHICH BYTE INDICATOR (1 => LEFT, -1 => RIGHT)                  00013100
*   TARG2 = OUTPUT PTR                                                  00013200
*   R3 = WORK REGISTER                                                  00013300
*   R5 = CHARACTER TO BE STORED                                         00013400
*   R7 = 1                                                              00013500
*                                                                       00013600
STBYTER  LH@#  R3,TARG2(R7)                                             00013700
         LECR  F1,F1                                                    00013800
         BM    LOWERS         IF NEGATIVE THEN STORE LEFT BYTE          00013900
         NHI   R3,X'FF00'     ELSE CLEAR OUT RIGHT BYTE                 00014000
         AR    R3,R5          MERGE IN NEW CHAR                         00014100
         STH@# R3,TARG2(R7) STORE AWAY NEW COMBO                        00014200
         AST   R7,TARG2       SINCE RIGHT BYTE, INCREMENT OUTPUT        00014300
         BR    R4                                                       00014400
LOWERS   SLL   R5,8           PLACE INPUT CHAR TO LEFT BYTE             00014500
         NHI   R3,X'00FF'     REMOVE OLD LEFT BYTE                      00014600
         AR    R3,R5          MERGE TWO CHARS                           00014700
         STH@# R3,TARG2(R7)   STORE NEW COMBO                           00014800
         BR    R4             RETURN                                    00014900
*                                                                       00015000
* THIS CODE CORRESPONDS TO GTBYTE FOR REMOTE DATA                       00015100
*   F0 = WHICH BYTE INDICATOR ( 1 => LEFT, -1 => RIGHT)                 00015200
*   TARG4 = INPUT PTR                                                   00015300
*   R5 = CHARACTER TO BE RETURNED                                       00015400
*   R7 = 1                                                              00015500
*                                                                       00015600
GTBYTER  LH@#  R5,TARG4(R7)   GET HALFWORD WITH CHAR                    00015700
         LECR  F0,F0          SET CONDITION CODE                        00015800
         BM    LOWERG         IF NEGATIVE THEN GET LEFT BYTE            00015900
         NHI   R5,X'00FF'     GET RID OF LEFT BYTE                      00016000
         AST   R7,TARG4       SINCE RIGTH BYTE INCREMENT INPUT PTR      00016100
         BR    R4                                                       00016200
LOWERG   NHI   R5,X'FF00'     MASK OFF RIGHT BYTE                       00016300
         SRL   R5,8           PLACE IN RIGHTBYTE POSITION               00016400
         BR    R4             RETURN                                    00016500
         ACLOSE                                                         00016600
