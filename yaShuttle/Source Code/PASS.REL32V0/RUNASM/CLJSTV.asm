*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    CLJSTV.asm
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    IBM AP-101S assembly language.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2024-06-18 RSB  Suffixed filename with ".asm".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'CLJSTV--LEFT JUSTIFY CHARACTER STRING'                  00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
CLJSTV   AMAIN ACALL=YES                                                00000200
*                                                                       00000300
* LEFT JUSTIFY CHARACTER STRING C1 TO A LENGTH OF I.                    00000400
*                                                                       00000500
         INPUT R4,            CHARACTER(C1)                            X00000600
               R5             INTEGER(I) SP                             00000700
         OUTPUT R2            CHARACTER(VAC)                            00000800
         WORK  R1,R3,R6,F0                                              00000900
*                                                                       00001000
* ALGORITHM:                                                            00001100
*   IF 255 < I THEN                                                     00001200
*     I = 255;                                                          00001300
*   IF I < 0 THEN                                                       00001400
*     DO;                                                               00001500
*       DESCRIPTOR(VAC) = 0 || 0;                                       00001600
*       SEND ERROR$(4:18);                                              00001700
*       RETURN;                                                         00001800
*     END;                                                              00001900
*   DESCRIPTOR(VAC) = I; /* NO NEED TO SET MAXLENGTH SINCE VAC */       00002000
*   TEMP1 = CURRENT_LENGTH(C1);                                         00002100
*   TEMP2 = I - CURRENT_LENGTH(C1);                                     00002200
*   IF TEMP1 ^= 0 THEN                                                  00002300
*     DO FOR L = 1 TO TEMP1;                                            00002400
*       VAC$(L) = C1$(L);                                               00002500
*     END;                                                              00002600
*   IF TEMP2 <= 0 THEN                                                  00002700
*     RETURN;                                                           00002800
*   BLANK = HEX'20'; /* HEX CODE FOR DEU BLANK */                       00002900
*   DO FOR K = 1 TO TEMP2;                                              00003000
*     VAC$(K + L) = BLANK;                                              00003100
*   END;                                                                00003200
*                                                                       00003300
         LR    R1,R2          PUT OUTPUT PTR INTO R1                    00003400
         LR    R2,R4          PUT INPUT PTR INTO R2 FOR ADDRESSABILITY  00003500
         LA    R6,255         255=MAX RESULT LENGTH                     00003600
         CR    R6,R5          COMPARE 255 WITH I                        00003700
         BNH   SETLEN         BRANCH IF 255 <= I                        00003800
         LR    R6,R5          SET R6=SUPPLIED LENGTH AND TEST FOR <0    00003900
         BM    NEGLEN         BRANCH IF I < 0                           00004000
*                                                                       00004100
*   R6 HAS # CHARS OF RESULT STRING. 0<=(R6)<=255                       00004200
*                                                                       00004300
SETLEN   STH   R6,0(R1)       SET ACTUAL LENGTH OF RESULT               00004400
*                                                                       00004500
* NOTE:  THIS SETS MAX LENGTH TO ZERO - OK SINCE ITS A TEMPORARY        00004600
*                                                                       00004700
         LH    R3,0(R2)       GET DESCRIPTOR OF C1                      00004800
         NHI   R3,X'00FF'     MASK OUT MAXIMUM LENGTH                   00004900
         BZ    BLANKTST       BRANCH IF NULL INPUT                      00005000
         SR    R6,R3          COMPUTE PAD CHAR COUNT                    00005100
         BM    TRUNCATE       BR IF SUPPLIED LEN < INPUT STR LEN        00005200
*                                                                       00005300
* THE FOLLOWING LOOP MOVES C1 TO THE VAC.                               00005400
*                                                                       00005500
MOVEIT   ABAL  GTBYTE         GET ONE CHAR                              00005600
         ABAL  STBYTE         STORE ONE CHAR                            00005700
*                                                                       00005800
* NOTE:  GTBYTE AND STBYTE INCREMENT THE BYTE PTRS                      00005900
*                                                                       00006000
         BCTB  R3,MOVEIT      LOOP (R3) TIMES                           00006100
*                                                                       00006200
*        PAD RESULT STRING WITH (R6) BLANKS                             00006300
*                                                                       00006400
BLANKTST LR    R6,R6          TEST FOR ANY PAD CHARS?                   00006500
         BNP   EXIT           BR IF NOT                                 00006600
BLANKIT  LHI   R5,X'0020'     R5=DEU BLANK                              00006700
         ABAL  STBYTE         STORE INTO RESULT STR                     00006800
         BCTB  R6,BLANKIT     LOOP (R6) TIMES                           00006900
EXIT     AEXIT                                                          00007000
*                                                                       00007100
*        SUPPLIED LENGTH WAS NEGATIVE                                   00007200
NEGLEN   ZH    0(R1)          SET RESULT TO NULL STRING                 00007300
*                                                                       00007400
* CAN ZERO ALL OF DESCRIPTOR SINCE ALWAYS ASSIGNS TO A VAC.             00007500
*                                                                       00007600
         AERROR 18            ERROR: NEGATIVE LENGTH TO LJUST           00007700
         B     EXIT                                                     00007800
*                                                                       00007900
* SUPPLIED LENGTH < INPUT LENGTH. PERFORM TRUNCATION                    00008000
*                                                                       00008100
TRUNCATE AERROR 18            ERROR: LJUST TRUNCATION                   00008200
         AR    R3,R6          REGENERATE RESULT LENGTH                  00008300
         BP    MOVEIT         FIXUP VIA TRUNCATION IF NON-NULL          00008400
         B     EXIT           BR IF NULL RESULT (SUPPLIED LEN=0)        00008500
*                                                                       00008600
         ACLOSE                                                         00008700
