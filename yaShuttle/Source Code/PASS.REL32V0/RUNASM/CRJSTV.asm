*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CRJSTV.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CRJSTV--RIGHT JUSTIFY CHARACTER STRING'                 00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CRJSTV   AMAIN                                                          00000200
*                                                                       00000300
* RIGHT JUSTIFY C1 TO A LENGTH OF I.                                    00000400
*                                                                       00000500
         INPUT R4,            CHARACTER(C1)                            X00000600
               R5             INTEGER(I) SP                             00000700
         OUTPUT R2            CHARACTER(VAC)                            00000800
         WORK  R1,R3,R6,F0                                              00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   IF 255 <= I THEN                                                    00001200
*     DESCRIPTOR(VAC) = 0 || 255; /* VAC => NO MAXIMUM LENGTH NEEDED */ 00001300
*   ELSE                                                                00001400
*     IF I < 0 THEN                                                     00001500
*       DO;                                                             00001600
*         SEND ERROR$(4:18);                                            00001700
*         RETURN;                                                       00001800
*       END;                                                            00001900
*     ELSE                                                              00002000
*       DESCRIPTOR(VAC) = 0 || I;                                       00002100
*   NUMBER_OF_BLANKS = I - CURRENT_LENGTH(C1);                          00002200
*   IF NUMBER_OF_BLANKS < 0 THEN                                        00002300
*     DO;                                                               00002400
*       SEND ERROR$(4:18);                                              00002500
*       NAME(C1) = NAME(C1$(# - I - 1));                                00002600
*     END;                                                              00002700
*   ELSE                                                                00002800
*     IF NUMBER_OF_BLANKS ^= 0 THEN                                     00002900
*       DO FOR K = 1 TO NUMBER_OF_BLANKS;                               00003000
*         VAC$(K) = HEX'0020';                                          00003100
*       END;                                                            00003200
*   IF CURRENT_LENGTH(C1) = 0 THEN                                      00003300
*     RETURN;                                                           00003400
*   DO FOR L = 1 TO CURRENT_LENGTH(C1);                                 00003500
*     VAC$(K + L - 1) = C1$(L);                                         00003600
*   END;                                                                00003700
*                                                                       00003800
         LR    R1,R2          PUT VAC PTR INTO R1                       00003900
         LR    R2,R4          PUT C1 PTR INTO R2 FOR ADDRESSABILITY     00004000
         LA    R3,255         MAX LENGTH OF RESULT                      00004100
         CR    R3,R5          COMPARE 255 WITH I                        00004200
         BNH   SETLEN         BR IF SUPPLIED >=255                      00004300
         LR    R3,R5          SET R3=SUPPLIED LEN AND TEST FOR <0       00004400
         BM    NEGLEN         BR IF <0 TO GIVE NULL RESULT              00004500
*                                                                       00004600
*        R3 HAS RESULT LENGTH: 0<=(R3)<=255                             00004700
*                                                                       00004800
SETLEN   STH   R3,0(R1)       SET ACTUAL LEN OF TEMPORARY RESULT        00004900
*                                                                       00005000
* NOTE:  THIS SETS MAX LEN=0 - OK SINCE ITS TEMP                        00005100
*                                                                       00005200
         LH    R6,0(R2)       GET C1 DESCRIPTOR                         00005300
         NHI   R6,X'00FF'     MASK OUT MAX LEN                          00005400
         SR    R3,R6          COMPUTE # PAD CHARS                       00005500
         BZ    NOBLANKS       IF = 0 THEN PADDING NOT NECESSARY         00005600
         BM    TRUNCATE       IF < 0 THEN TRUNCATION ERROR              00005700
*                                                                       00005800
*        BLANK (R3) CHARS OF RESULT                                     00005900
*                                                                       00006000
BLANKIT  LHI   R5,X'0020'     R5=DEU BLANK                              00006100
         ABAL  STBYTE         STORE ONE BLANK                           00006200
         BCTB  R3,BLANKIT     LOOP (R3) TIMES                           00006300
*                                                                       00006400
*        MOVE (R6) CHARS FROM INPUT STR TO RESULT                       00006500
*                                                                       00006600
NOBLANKS LR    R6,R6          TEST # OF INPUT CHARS TO MOVE             00006700
         BNP   EXIT           BR IF NONE TO MOVE                        00006800
MOVEIT   ABAL  GTBYTE         GET ONE CHAR                              00006900
         ABAL  STBYTE         STORE ONE CHAR                            00007000
         BCTB  R6,MOVEIT      LOOP (R6) TIMES                           00007100
*                                                                       00007200
EXIT     AEXIT                                                          00007300
*                                                                       00007400
*        NEGATIVE SUPPLIED LENGTH                                       00007500
*                                                                       00007600
NEGLEN   ZH    0(R1)          SET RESULT TO NULL STRING                 00007700
         AERROR 18            ERROR: NEGATIVE LENGTH TO RJUST           00007800
         B     EXIT                                                     00007900
*                                                                       00008000
*        SUPPLIED LENGTH LESS THAN INPUT STR LENGTH                     00008100
*                                                                       00008200
TRUNCATE AERROR 18            ERROR: RJUST TRUNCATION                   00008300
         AR    R6,R3          REGENERATE RESULT LENGTH                  00008400
         LACR  R5,R3          R5=# CHARS TO SKIP OVER IN INPUT STR      00008500
         SRA   R5,1           R5=# HALFWORDS "                          00008600
         AR    R2,R5          INCREMENT INPUT STR PTR                   00008700
         TRB   R3,X'0001'     IS SKIP CHAR COUNT ODD?                   00008800
         BZ    NOBLANKS       BR IF NOT TO COPY CHARS                   00008900
         IAL   R2,X'8000'     SET ODD CHAR FLAG IN BYTE PTR FOR GTBYTE  00009000
         B     NOBLANKS       GO TRANSFER CHARS                         00009100
         ACLOSE                                                         00009200
