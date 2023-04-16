*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CTOX.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CTOX--CHARACTER TO OCTAL AND HEX CONVERSION'            00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NOT NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS NOT USED AS
* A BASE REGISTER. (CR12620)
*
CTOX     AMAIN                                                          00000200
*                                                                       00000300
* CONVERT A CHARACTER STRING, C1, TO A BIT STRING WHERE C1 CONTAINS     00000400
*   HEXADECIMAL CHARACTERS.                                             00000500
*                                                                       00000600
         INPUT R2             CHARACTER(C1)                             00000700
         OUTPUT R5            BIT(32)                                   00000800
         WORK  R1,R3,R4,R6,R7,F0                                        00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   RADIX = 4;                                                          00001200
*   IF LENGTH(C1) = 0 THEN                                              00001300
*     DO;                                                               00001400
*       SEND ERROR$(4:32);                                              00001500
*       RETURN HEX(8)'0';                                               00001600
*     END;                                                              00001700
*   TEMP = 0;                                                           00001800
*   DO FOR I = 1 TO LENGTH(C1);                                         00001900
*     CURR_CHAR = GTBYTE;                                               00002000
*     IF CURR_CHAR > 'F' THEN                                           00002100
*       DO;                                                             00002200
*         SEND ERROR$(4:32);                                            00002300
*         RETURN HEX(8)'0';                                             00002400
*       END;                                                            00002500
*     IF CURR_CHAR < 'A' THEN                                           00002600
*       DO;                                                             00002700
*         IF CURR_CHAR > '9' THEN                                       00002800
*           DO;                                                         00002900
*             SEND ERROR$(4:32);                                        00003000
*             RETURN HEX(8)'0';                                         00003100
*           END;                                                        00003200
*         IF CURR_CHAR < '0' THEN                                       00003300
*           DO;                                                         00003400
*             SEND ERROR$(4:32);                                        00003500
*             RETURN HEX(8)'0';                                         00003600
*           END;                                                        00003700
*         INTEGER(SUBBIT(CURR_CHAR)) = INTEGER(SUBBIT(CURR_CHAR)) +     00003800
*           INTEGER(SUBBIT(HEX'FFD0'));                                 00003900
*         TEMP = SLL(TEMP,RADIX) + SRL(CURR_CHAR,16);                   00004000
*       END;                                                            00004100
*     ELSE                                                              00004200
*       DO;                                                             00004300
*         INTEGER(SUBBIT(CURR_CHAR)) = INTEGER(SUBBIT(CURR_CHAR)) +     00004400
*           INTEGER(SUBBIT(HEX'FFC9');                                  00004500
*         TEMP = SLL(TEMP,RADIX) + SRL(CURR_CHAR,16);                   00004600
*       END;                                                            00004700
*   END;                                                                00004800
*   RETURN TEMP;                                                        00004900
*                                                                       00005000
         EXTRN GTBYTE                                                   00005100
         LHI   R6,4           SHIFT COUNT FOR HEX                       00005200
         BAL   R1,COMMON      DO SOME COMMON STUFF                      00005300
*                                                                       00005400
*  TESTS SPECIFIC TO HEXADECIMAL                                        00005500
*                                                                       00005600
         CHI   R5,X'46'       ERROR IF CHARACTER FOLLOWS                00005700
         BH    ERROR          'F' IN COLLATING SEQUENCE.                00005800
         CHI   R5,X'41'       CHECK FOR DIGIT IF CHARACTER              00005900
         BL    NUM            PRECEDES 'A' IN COLLATING SEQUENCE.       00006000
         AHI   R5,X'FFC9'     CONVERT LETTER TO NUMBER                  00006100
         B     SHIFT                                                    00006200
*                                                                       00006300
NUM      CHI   R5,X'39'       IF <C'A' AND >C'9',                       00006400
         BH    ERROR          INVALID CHARACTER IN HEXADECIMAL          00006500
*                                                                       00006600
*  TEST AND CONVERSION COMMON TO BOTH HEX AND OCTAL DIGITS              00006700
*                                                                       00006800
COMMON1  CHI   R5,X'30'       IF < C'0',                                00006900
         BL    ERROR          INVALID CHARACTER IN EITHER ENTRY         00007000
         AHI   R5,X'FFD0'     CONVERT DIGIT TO NUMBER                   00007100
*                                                                       00007200
*  THIS SECTION IS USED FOR ALL VALID INPUTS, HEX AND OCTAL             00007300
*                                                                       00007400
SHIFT    SLL   R7,0(R6)       SHIFT 3 FOR OCT, 4 FOR HEX                00007500
         SRL   R5,16          NEXT DIGIT IN R5 LOW                      00007600
         AR    R7,R5          ACCUMULATE BIT STRING                     00007700
         ABAL  GTBYTE                                                   00007800
         BCTR  R3,R1                                                    00007900
*                                                                       00008000
EXIT     ST    7,ARG5                                                   00008100
         AEXIT                                                          00008200
*                                                                       00008300
*  OCTAL CONVERSION ENTRY                                               00008400
*                                                                       00008500
CTOO     AENTRY                                                         00008600
*                                                                       00008700
* CONVERT A CHARACTER STRING, C1, TO A BIT STRING WHERE C1 CONTAINS     00008800
*   OCTAL CHARACTERS.                                                   00008900
*                                                                       00009000
         INPUT R2             CHARACTER(C1)                             00009100
         OUTPUT R5            BIT(32)                                   00009200
         WORK  R3,R4,R6,R7,F0                                           00009300
*                                                                       00009400
* ALGORITHM:                                                            00009500
*   RADIX = 3;                                                          00009600
*   IF LENGTH(C1) = 0 THEN                                              00009700
*     DO;                                                               00009800
*       SEND ERROR$(4:31);                                              00009900
*       RETURN HEX(8)'0';                                               00010000
*     END;                                                              00010100
*   TEMP = 0;                                                           00010200
*   DO FOR I = 1 TO LENGTH(C1);                                         00010300
*     CURR_CHAR = GTBYTE;                                               00010400
*     IF CURR_CHAR > '7' THEN                                           00010500
*       DO;                                                             00010600
*         SEND ERROR$(4:31);                                            00010700
*         RETURN HEX(8)'0';                                             00010800
*       END;                                                            00010900
*     IF CURR_CHAR < '0' THEN                                           00011000
*       DO;                                                             00011100
*         SEND ERROR$(4:31);                                            00011200
*         RETURN 0;                                                     00011300
*       END;                                                            00011400
*     INTEGER(SUBBIT(CURR_CHAR)) = INTEGER(SUBBIT(CURR_CHAR)) +         00011500
*       INTEGER(SUBBIT(HEX'FFD0'));                                     00011600
*     TEMP = SLL(TEMP,RADIX) + SRL(CURR_CHAR,16);                       00011700
*   END;                                                                00011800
*   RETURN TEMP;                                                        00011900
*                                                                       00012000
         LFXI  R6,3           SHIFT COUNT FOR OCTAL                     00012100
         BAL   R1,COMMON      DO COMMON STUFF AND RETURN HERE           00012200
*                                                                       00012300
*  TEST SPECIFIC TO OCTAL                                               00012400
*                                                                       00012500
         CHI   R5,X'37'       IF > C'7',                                00012600
         BH    ERROR          INVALID CHARACTER IN OCTAL                00012700
         B     COMMON1                                                  00012800
*                                                                       00012900
*  COMMON SECTION: DOES SETUP AND GETS THE FIRST CHARACTER              00013000
*                                                                       00013100
COMMON   LH    R3,0(R2)                                                 00013200
         NHI   R3,X'00FF'     GET LENGTH IN R3,                         00013300
         BZ    ERROR          AND GIVE ERROR IF LENGTH=0.               00013400
         LA    R2,0(R2)       ZERO OUT FLAG IN BYTE POINTER             00013500
         XR    R7,R7          CLEAR R7 TO RECEIVE STRING                00013600
         ABAL  GTBYTE                                                   00013700
         BCR   7,R1                                                     00013800
*                                                                       00013900
ERROR    TRB   R6,4                                                     00014000
         BNZ   HEXERR                                                   00014100
         AERROR 31            BIT@OCT CONVERSION-INVALID CHARACTER      00014200
         XR    R7,R7          FIXUP RETURNS 0                           00014300
         B     EXIT                                                     00014400
*                                                                       00014500
HEXERR   AERROR 32            BIT@HEX CONVERSION-INVALID CHARACTER      00014600
         XR    R7,R7          STANDARD FIXUP RETURNS 0                  00014700
         B     EXIT                                                     00014800
*                                                                       00014900
         ACLOSE                                                         00015000
