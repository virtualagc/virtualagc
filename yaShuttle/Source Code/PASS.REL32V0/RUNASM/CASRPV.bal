*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CASRPV.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CASRPV - CHARACTER ASSIGN,PARTITIONED INPUT,REMOTE'     00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
TARG2    DS    F                                                        00000400
TARG4    DS    F                                                        00000500
         MEND                                                           00000600
CASRPV   AMAIN                                                          00000700
*                                                                       00000800
* ASSIGN C1$(I TO J) TO C2 WHERE C1 IS A REMOTE CHARACTER STRING AND    00000900
*   C2 IS A TEMPORARY STRING AREA.                                      00001000
*                                                                       00001100
         INPUT R4,            ZCON(CHARACTER STRING) C1                X00001200
               R5,            INTEGER(I) SP                            X00001300
               R6             INTEGER(J) SP                             00001400
         OUTPUT R2            ZCON(CHARACTER STRING) C2                 00001500
         WORK  R1,R3,R7                                                 00001600
*                                                                       00001700
* ALGORITHM:                                                            00001800
*   DESCRIPTOR(C2) = 255 || 255;                                        00001900
*   GO TO CASRP                                                         00002000
*                                                                       00002100
         ST    R4,TARG4       STORE INPUT ZCON IN TARG4                 00002200
         XR    R4,R4          CLEAR R4                                  00002300
         SHW@# ARG2(R4)       SET MAXLEN OF VAC TO 255                  00002400
         B     MERG                                                     00002500
CASRP    AENTRY                                                         00002600
*                                                                       00002700
* ASSIGN C1$(I TO J) TO C2 WHERE C1 IS A REMOTE CHARACTER STRING AND    00002800
*   C2 IS A DECLARED CHARACTER STRING.                                  00002900
*                                                                       00003000
         INPUT R4,            ZCON(CHARACTER STRING) C1                X00003100
               R5,            INTEGER(I) SP                            X00003200
               R6             INTEGER(J) SP                             00003300
         OUTPUT R2            ZCON(CHARACTER STRING) C2                 00003400
         WORK  R1,R3,R7                                                 00003500
*                                                                       00003600
* ALGORITHM:                                                            00003700
*   IF I <= 0 THEN                                                      00003800
*     DO;                                                               00003900
*       I = 1;                                                          00004000
*       SEND ERROR$(4:17);                                              00004100
*     END;                                                              00004200
*   IF J > CURRENT_LENGTH(C1) THEN                                      00004300
*     DO;                                                               00004400
*       J = CURRENT_LENGTH(C1);                                         00004500
*       SEND ERROR$(4:17);                                              00004600
*     END;                                                              00004700
*   J = J - I + 1;                                                      00004800
*   IF J < 0 THEN                                                       00004900
*     DO;                                                               00005000
*       J = 0;                                                          00005100
*       IF C1 ^= '' THEN                                                00005200
*         SEND ERROR$(4:17);                                            00005300
*     END;                                                              00005400
*   IF J > MAXIMUM_LENGTH(C2) THEN                                      00005500
*     J = MAXIMUM_LENGTH(C2);                                           00005600
*   DESCRIPTOR(C2) = MAXIMUM_LENGTH(C2) || J;                           00005700
*   J = J + 1;                                                          00005800
*   IF J = 1 THEN                                                       00005900
*     RETURN;                                                           00006000
*   J = SHR(J,1); /* J = # OF HALFWORDS TO BE MOVED */                  00006100
*   IF ODD(I) THEN                                                      00006200
*     DO;                                                               00006300
*       I = SHR(I,1); /* NO ALIGNMENT PROBLEMS */                       00006400
*       DO FOR L = 1 TO J;                                              00006500
*         C2$(2 AT (2 * (L - 1)) + 1) = C1$(2 AT 2 * I + 1);            00006600
*       END;                                                            00006700
*     END;                                                              00006800
*   ELSE                                                                00006900
*     DO;                                                               00007000
*       I = SHR(I,1);                                                   00007100
*       ZCON(C1) = ZCON(C1) + I;                                        00007200
*       DO FOR L = 1 TO J;                                              00007300
*         C2$(2 AT (2 * (L - 1)) + 1) = C1$(2 AT 2 * I);                00007400
*       END;                                                            00007500
*     END;                                                              00007600
*                                                                       00007700
         ST    R4,TARG4       STORE INPUT ZCON IN TARG4                 00007800
         XR    R4,R4          CLEAR R4 (TO BE USED AS INDEX)            00007900
MERG     ST    R2,TARG2       SAVE ZCON OF OUTPUT IN TARG2              00008000
         LR    R5,R5          SET CONDITION CODE                        00008100
         BP    L1             IF > 0 THEN OK                            00008200
         LA    R5,1           ELSE FIXUP AND                            00008300
         AERROR 17            INTEGER(I) IS LESS THAN 0                 00008400
L1       LH@#  R3,TARG4(R4)   GET C1 DESCRIPTOR                         00008500
         NHI   R3,X'00FF'     MASK OFF MAXLENGTH                        00008600
         CR    R6,R3          COMPARE J WITH CURR LENGTH OF C1          00008700
         BLE   L2             IF <= THEN OK                             00008800
         LR    R6,R3          ELSE FIXUP AND                            00008900
         AERROR 17            INTEGER J IS GREATER THAN CURRLEN(C1)     00009000
L2       SR    R6,R5          J - I + 1 =                               00009100
         AHI   R6,X'0001'     # OF CHARS TO STORE                       00009200
         BP    L3             IF > 0 THEN OK                            00009300
         SR    R6,R6          ELSE FIXUP                                00009400
         LR    R3,R3          SET CONDITION CODE                        00009500
         BZ    L3             IF = 0 THEN OK                            00009600
         AERROR 17            I TO J SPECIFIES NEG LEN PARTITION        00009700
L3       LH@#  R3,TARG2(R4)   GET C2 DESCRIPTOR                         00009800
         SRL   R3,8           PUT MAXLENGTH IN LOWER BYTE               00009900
         NHI   R3,X'00FF'     ISOLATE MAXIMUM LENGTH                    00010000
         CR    R6,R3          COMPARE I WITH MAXIMUM_LENGTH(C2)         00010100
         BLE   L4             IF <= THEN OK                             00010200
         LR    R6,R3          ELSE TRUNCATE (SET J = MAX_LENGTH)        00010300
L4       SLL   R3,8           RESTORE MAXLEN OF DESTINATION             00010400
         OR    R3,R6          WITH NEW CURRLEN                          00010500
         STH@# R3,TARG2(R4)   RESET C2 DESCRIPTOR                       00010600
         AHI   R6,X'0001'     ADD 1 TO J                                00010700
         CHI   R6,X'0001'     COMPARE J WITH 1                          00010800
         BE    EXIT           IF = THEN RETURN                          00010900
         SRL   R6,1           GET # OF HALFOWRDS TO BE MOVED            00011000
         LFXI  R7,1           PUT A 1 INTO R7                           00011100
         LFXI  R3,-1          PUT A -1 INTO R3                          00011200
         TRB   R5,X'0001'     MAKE ODD TEST                             00011300
         SRL   R5,1           GET I / 2                                 00011400
         BO    L6             IF TESTED BIT WAS 1 THEN GO TO L6 LOOP    00011500
*                                                                       00011600
* THE FOLLOWING LOOP MOVES BY HALFWORDS WHICH ARE NOT ALIGNED           00011700
*                                                                       00011800
         AST   R5,TARG4       INCREMENT INPUT ZCON                      00011900
         LH@#  R5,TARG4(R4)   LOAD HALFWORD INTO R5 (INDEX = 0)         00012000
L5       IHL@# R5,TARG4(R7)   GET NEXT HALFWORD IN LOW HALF OF REG.     00012100
         SLL   R5,8           GET 2 CHARACTERS IN UPPER HALFWORD        00012200
         STH@# R5,TARG2(R7)   STORE IN C2                               00012300
         AST   R7,TARG2       BUMP OUTPUT PTR TO NEXT 2 CHARS           00012400
         AST   R7,TARG4       BUMP INPUT PTR TO NEXT 2 CHARS            00012500
         SLL   R5,8           PUT NEXT CHAR IN LOWER BYTE OF R5         00012600
         BCTB  R6,L5                                                    00012700
         B     EXIT                                                     00012800
*                                                                       00012900
* THE FOLLOWING LOOP MOVES BY HALFWORDS WHICH ARE ALIGNED               00013000
*                                                                       00013100
L6       LR    R2,R5          SET R2 TO I                               00013200
         LFXI  R1,1          R1 <- 1                                    00013300
L7       LA    R2,1(R2)       BUMP OUTPUT PTR TO NEXT 2 CHARS           00013400
         LH@#  R5,TARG4(R2)   GET 2 CHARS FROM INPUT                    00013500
         STH@# R5,TARG2(R1)   STORE 2 CHARS IN OUTPUT                   00013600
         LA    R1,1(R1)       BUMP OUTPUT PTR TO NEXT 2 CHARS           00013700
         BCTB  R6,L7                                                    00013800
EXIT     AEXIT                                                          00013900
         ACLOSE                                                         00014000
