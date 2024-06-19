*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CPAS.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CPAS--CHARACTER ASSIGN,PARTITIONED OUTPUT'              00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
         MACRO                                                          00000200
         WORKAREA                                                       00000300
PADBLANK DS    H                                                        00000400
         MEND                                                           00000500
CPAS     AMAIN                                                          00000600
*                                                                       00000700
* ASSIGNS C1 TO A PARTITION OF C2$(I TO J).                             00000800
*                                                                       00000900
         INPUT R4,            CHARACTER(C1)                            X00001000
               R5,            INTEGER(I) SP                            X00001100
               R6             INTEGER(J) SP                             00001200
         OUTPUT R2            CHARACTER(C2)                             00001300
         WORK  R1,R3,R7,F0                                              00001400
*                                                                       00001500
* ALGORITHM:                                                            00001600
*   IF I <= 0 THEN                                                      00001700
*     DO;                                                               00001800
*       I = 1;                                                          00001900
*       SEND ERROR$(4:17);                                              00002000
*     END;                                                              00002100
*   IF J > MAXIMUM_LENGTH(C2) THEN                                      00002200
*     DO;                                                               00002300
*       J = MAX_LENGTH(C2);                                             00002400
*       SEND ERROR$(4:17);                                              00002500
*     END;                                                              00002600
*   IF J > CURRENT_LENGTH((C2) THEN                                     00002700
*     DESCRIPTOR(C2) = MAX_LENGTH(C2) || J;                             00002800
*   LENGTH_OF_PARTITION = J - I + 1;                                    00002900
*   IF LENGTH_OF_PARTITION < 0 THEN                                     00003000
*     DO;                                                               00003100
*       SEND ERROR$(4:17);                                              00003200
*       RETURN;                                                         00003300
*     END;                                                              00003400
*   ELSE                                                                00003500
*     IF LENGTH_OF_PARTITION = 0 THEN                                   00003600
*       RETURN;  /* IF PARTITION LENGTH IS 0 THEN NOOP */               00003700
*   NUMBER_OF_BLANKS = I - CURRENT_LENGTH(C2) - 1;                      00003800
*   IF NUMBER_OF_BLANKS <= 0 THEN                                       00003900
*     DO;                                                               00004000
*       I = SHR(I + 1,1);                                               00004100
*       NAME(C1) = NAME(C1 + I);                                        00004200
*     END;                                                              00004300
*   ELSE                                                                00004400
*     DO;                                                               00004500
*       NAME(C2) = NAME(C2) + SHR(CURRENT_LENGTH(C2) + 2,1);            00004600
*       DO FOR K = 1 TO NUMBER_OF_BLANKS;                               00004700
*         C2$(K) = HEX'0020';                                           00004800
*       END;                                                            00004900
*     END;                                                              00005000
*   LENGTH_OF_PARTITION = LENGTH_OF_PARTITION + 1;                      00005100
*   DO FOR L = 1 TO LENGTH_OF_PARTITION;                                00005200
*     C2$(K + L) = C1$(L);                                              00005300
*   END;                                                                00005400
*                                                                       00005500
         XR    R7,R7          CLEAR R7                                  00005600
         STH   R7,PADBLANK    SET PADBLANK = 0                          00005700
         LR    R1,R2          PUT ADDR(C2) INTO R1                      00005800
         LR    R2,R4          PUT ADDR(C1) INTO R2 FOR ADDRESSABILITY   00005900
         LR    R5,R5          SET CONDITION CODE                        00006000
         BP    L1             FIRST CHAR CAN'T HAVE NEG POSITION        00006100
         LFXI  R5,1           FIXUP: SET I = 1                          00006200
         AERROR 17            I <= 0                                    00006300
L1       LH    R3,0(R1)       GET DESCRIPTOR OF DESTINATION             00006400
         NHI   R3,X'FF00'     GET MAX LENGTH OF C2                      00006500
         SRL   R3,8           (SRL SUPPLIES LEADING ZEROES)             00006600
         CR    R6,R3          COMPARE J WITH MAXIMUM LENGTH OF C2       00006700
         BLE   L5             ELSE FIXUP: J = MAXIMUM LENGTH            00006800
         LR    R6,R3          FIXUP IS MAXLEN                           00006900
         AERROR 17            J > MAXLENGTH(C2)                         00007000
L5       LH    R3,0(R1)       GET C2 DESCRIPTOR                         00007100
         NHI   R3,X'00FF'     MASK OFF MAXIMUM LENGTH                   00007200
L2       CR    R6,R3          COMPARE J WITH CURRENT LENGTH OF C2       00007300
         BLE   L3             IF <= THEN GO TO L3                       00007400
         ZB    0(R1),X'00FF'  ELSE ZERO CURRENT LENGTH OF C2            00007500
         AH    R6,0(R1)       GET MAXIMUM LENGTH OF C2 || J             00007600
         STH   R6,0(R1)       RESET C2 DESCRIPTOR                       00007700
         NHI   R6,X'00FF'     GET BACK J                                00007800
L3       SR    R6,R5          J-I+1=                                    00007900
         AHI   R6,1           LENGTH OF PARTITION                       00008000
         BZ    L6             IF LENGTH OF PARTITION = 0 THEN NO ASSIGN 00008100
         BP    L4             IF >= 0 THEN GO TO L4                     00008200
         AERROR 17            LENGTH OF PARTITION < 0                   00008300
         B     EXIT                                                     00008400
L4       LH    R7,0(R2)       GET DESCRIPTOR OF C1                      00008500
         NHI   R7,X'00FF'     GET CURRENT LENGTH OF C1                  00008600
         LR    R4,R7          SAVE CURRENT LENGTH OF C1 IN R4           00008700
*                             (IT MIGHT BE NEEDED)                      00008800
         SR    R7,R6          GET CURRENT LENGTH(C1) - PARTITION LENGTH 00008900
         BNM   L6             IF >=0 THEN GO TO L6                      00009000
         LR    R6,R4          ELSE # OF CHARS TO STORE = LENGTH OF C1   00009100
         LCR   R7,R7          COMPUTE # OF RIGHT PAD BLANKS             00009200
         STH   R7,PADBLANK    SAVE THIS NUMBER ON STACK                 00009300
L6       LR    R7,R5          R7 <- I                                   00009400
         SR    R7,R3          I - CURRENT_LENGTH(C2) - 1 =              00009500
         AHI   R7,-1          # OF BLANKS                               00009600
         BP    B2             IF > 0 THEN GO TO B2                      00009700
         AHI   R5,-1          I - 1 / 2 =                               00009800
         SRL   R5,1           # HALFWRDS TO I                           00009900
         AR    R1,R5          RESET STBYTE PTR                          00010000
         B     CSTC           START STORING CHARACTERS                  00010100
B2       SRL   R3,1           # HALFWRDS TO ORIG CURRLEN                00010200
         AR    R1,R3          RESET STBYTE PTR                          00010300
*                                                                       00010400
* THE FOLLOWING LOOP PADS WITH PRECEDING BLANKS                         00010500
*                                                                       00010600
BST      LHI   R5,X'0020'     ' ' TO BE STORED                          00010700
         ABAL  STBYTE                                                   00010800
         BCTB  R7,BST                                                   00010900
*                                                                       00011000
* THE FOLLWOING LOOP STORES THE CHARS OF C1 INTO C2                     00011100
*                                                                       00011200
CSTC     LR    R6,R6          SET CONDITION CODE                        00011300
         BZ    STRPAD                                                   00011400
CST      ABAL  GTBYTE                                                   00011500
         ABAL  STBYTE                                                   00011600
         BCTB  R6,CST                                                   00011700
STRPAD   LH    R7,PADBLANK    GET # RIGHT PAD CHARS                     00011800
         BZ    EXIT           IF ZERO THEN RETURN                       00011900
*                                                                       00012000
* THE FOLLOWING LOOP STORES RIGHT PADDING BLANKS                        00012100
*                                                                       00012200
PADRIGHT LHI   R5,X'0020'     ELSE LOAD UP DEU BLANK                    00012300
         ABAL  STBYTE                                                   00012400
         BCTB  R7,PADRIGHT                                              00012500
EXIT     AEXIT                                                          00012600
         ACLOSE                                                         00012700
