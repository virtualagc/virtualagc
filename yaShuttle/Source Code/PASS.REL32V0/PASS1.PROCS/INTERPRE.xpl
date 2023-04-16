 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INTERPRE.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  INTERPRET_ACCESS_FILE                                  */
 /* MEMBER NAME:     INTERPRE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          A_TOKEN           CHARACTER;                                   */
 /*          ACCESS_ERROR(1483)  LABEL                                      */
 /*          ACCESS_OFF        FIXED                                        */
 /*          ADVANCE_CP        LABEL                                        */
 /*          BLOCK_END         BIT(16)                                      */
 /*          BLOCK_NAME        CHARACTER;                                   */
 /*          BLOCK_START       BIT(16)                                      */
 /*          CP                BIT(16)                                      */
 /*          END_FILE_EXIT     LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          LOOKUP            LABEL                                        */
 /*          NEXT_TOKEN        LABEL                                        */
 /*          RECOVER_WITHOUT_MSG(1516)  LABEL                               */
 /*          RECOVERY_POINT(3) LABEL                                        */
 /*          RESET_ACCESS_FLAG LABEL                                        */
 /*          RESTART           LABEL                                        */
 /*          S                 CHARACTER;                                   */
 /*          SYNTAX_ERROR      LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ACCESS_FLAG                                                    */
 /*          ACCESS_FOUND                                                   */
 /*          CLASS_PA                                                       */
 /*          COMPOOL_LABEL                                                  */
 /*          ENDSCOPE_FLAG                                                  */
 /*          FALSE                                                          */
 /*          FOREVER                                                        */
 /*          FUNC_CLASS                                                     */
 /*          LINK_SORT                                                      */
 /*          PROC_LABEL                                                     */
 /*          PROG_LABEL                                                     */
 /*          PROGRAM_ID                                                     */
 /*          READ_ACCESS_FLAG                                               */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_HASHLINK                                                   */
 /*          SYM_NAME                                                       */
 /*          SYM_TYPE                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_HASHLINK                                                   */
 /*          SYT_HASHSIZE                                                   */
 /*          SYT_HASHSTART                                                  */
 /*          SYT_NAME                                                       */
 /*          SYT_TYPE                                                       */
 /*          TEXT_LIMIT                                                     */
 /*          TRUE                                                           */
 /*          X70                                                            */
 /*          X8                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          J                                                              */
 /*          LETTER_OR_DIGIT                                                */
 /*          NAME_HASH                                                      */
 /*          SYM_TAB                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HASH                                                           */
 /*          OUTPUT_WRITER                                                  */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INTERPRET_ACCESS_FILE <==                                           */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> HASH                                                            */
 /*     ==> OUTPUT_WRITER                                                   */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> MIN                                                         */
 /*         ==> MAX                                                         */
 /*         ==> BLANK                                                       */
 /*         ==> LEFT_PAD                                                    */
 /*         ==> I_FORMAT                                                    */
 /*         ==> CHECK_DOWN                                                  */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 04/26/01 DCP  31V0  CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS         */
 /*               16V0           IN HAL/S COMPILER                          */
 /***************************************************************************/
                                                                                00407400
INTERPRET_ACCESS_FILE:                                                          00407500
   PROCEDURE;                                                                   00407600
      DECLARE END_FILE_EXIT LABEL;                                              00407700
      DECLARE (CP, I, BLOCK_START, BLOCK_END) BIT(16);                          00407800
      DECLARE (BLOCK_NAME, A_TOKEN) CHARACTER;                                  00407900
      DECLARE ACCESS_OFF FIXED;                                                 00408000
      DECLARE S CHARACTER;                                                      00408100
                                                                                00408200
ACCESS_ERROR:                                                                   00408300
      PROCEDURE(MSG_NUM, NAME);                                                 00408400
         DECLARE NAME CHARACTER;                                                00408500
         DECLARE MSG_NUM BIT(16);                                               00408600
         DECLARE MSG_ISSUED BIT(1);                                             00408700
         DECLARE ACCESS_MSG(6) CHARACTER INITIAL(                               00408800
            '**SYNTAX ERROR ON THE FOLLOWING PROGRAM ACCESS FILE RECORD:',      00408900
         ' APPEARS ON THE PROGRAM ACCESS FILE BUT IS NOT DEFINED IN THIS COMPILA00409000
TION',                                                                          00409100
         ' IS IN A "$BLOCK" LIST BUT IS NOT A COMPOOL, PROGRAM, PROCEDURE, OR FU00409200
NCTION',                                                                        00409300
         ' APPEARS ON THE PROGRAM ACCESS FILE BUT IS NOT CURRENTLY ACCESS PROTEC00409400
TED',                                                                           00409500
         ' IS NOT DEFINED WITHIN THE COMPOOL SPECIFIED ON THE PROGRAM ACCESS FIL00409600
E',                                                                             00409700
         ' IS USED AS A COMPOOL BLOCK NAME ON THE PROGRAM ACCESS FILE BUT IS NOT00409800
 A COMPOOL LABEL',                                                              00409900
         ' IS A COMPOOL BLOCK NAME WHICH MUST APPEAR IN A $BLOCK LIST BEFORE ITS00410000
 CONTENTS CAN BE USED');                                                        00410100
         IF ^MSG_ISSUED THEN DO;                                                00410200
            MSG_ISSUED = TRUE;                                                  00410300
            CALL ERROR(CLASS_PA, 2, PROGRAM_ID);                                00410400
            CALL OUTPUT_WRITER;  /* PUT THE MSG OUT */                          00410500
         END;                                                                   00410600
         IF MSG_NUM = 0 THEN DO;  /* SPECIAL SYNTAX ERROR MSG */                00410700
            OUTPUT = X8 || ACCESS_MSG;                                          00410800
            OUTPUT = S;                                                         00410900
         END;                                                                   00411000
         ELSE OUTPUT = X8 || NAME || ACCESS_MSG(MSG_NUM);                       00411100
      END ACCESS_ERROR;                                                         00411200
                                                                                00411300
RESET_ACCESS_FLAG:                                                              00411400
      PROCEDURE;                                                                00411500
         DECLARE J FIXED;                                                       00411600
         J = SYT_FLAGS(I);                                                      00411700
         IF (J & ACCESS_FLAG) ^= 0 THEN                                         00411800
            SYT_FLAGS(I) = J & ACCESS_OFF;                                      00411900
         ELSE CALL ACCESS_ERROR(3, A_TOKEN);                                    00412000
      END RESET_ACCESS_FLAG;                                                    00412100
                                                                                00412200
LOOKUP:                                                                         00412300
      PROCEDURE(NAME);                                                          00412400
         DECLARE NAME CHARACTER;                                                00412500
         DECLARE I FIXED;                                                       00412600
         NAME_HASH = HASH(NAME, SYT_HASHSIZE);                                  00412800
         I = SYT_HASHSTART(NAME_HASH);                                          00412900
         DO WHILE I > 0;                                                        00413000
            IF NAME = SYT_NAME(I) THEN                                          00413100
               RETURN I;                                                        00413200
            I = SYT_HASHLINK(I);                                                00413300
         END;                                                                   00413400
         RETURN -1;                                                             00413500
      END LOOKUP;                                                               00413600
                                                                                00413700
ADVANCE_CP:                                                                     00413800
      PROCEDURE;                                                                00413900
         DECLARE EOF_FLAG BIT(1);                                               00414000
         CP = CP + 1;                                                           00414100
         IF CP > TEXT_LIMIT THEN DO;                                            00414200
            IF EOF_FLAG THEN GO TO END_FILE_EXIT;                               00414300
READIT:                                                                         00414400
            S = INPUT(6);                                                       00414500
            IF LENGTH(S) = 0 THEN DO;                                           00414600
               S = X70 || X70;  /* SHOULD BE >= 80 */                           00414700
               EOF_FLAG = TRUE;                                                 00414800
            END;                                                                00414900
            IF BYTE(S) = BYTE('C') THEN GO TO READIT;                           00415000
            CP = 1;                                                             00415100
         END;                                                                   00415200
      END ADVANCE_CP;                                                           00415300
                                                                                00415400
NEXT_TOKEN:                                                                     00415500
      PROCEDURE;                                                                00415600
         DECLARE I BIT(16);                                                     00415700
         DECLARE NUM_DELIMETERS LITERALLY '3';                                  00415800
      DECLARE DELIMETERS(NUM_DELIMETERS) BIT(8) INITIAL("00", "4D", "5D", "6B");00415900
         DO WHILE BYTE(S, CP) = BYTE(X1);                           /*CR13335*/ 00416000
            CALL ADVANCE_CP;                                                    00416100
         END;                                                                   00416200
         A_TOKEN = '';                                                          00416300
         DO WHILE LETTER_OR_DIGIT(BYTE(S, CP));                                 00416400
            A_TOKEN=A_TOKEN||SUBSTR(S,CP,1);                                    00416500
            CALL ADVANCE_CP;                                                    00416600
         END;                                                                   00416700
         IF LENGTH(A_TOKEN) ^= 0 THEN RETURN 0;                                 00416800
         DO I = 1 TO NUM_DELIMETERS;                                            00416900
            IF BYTE(S,CP)=DELIMETERS(I) THEN DO;                                00417000
               CALL ADVANCE_CP;                                                 00417100
               RETURN I;                                                        00417200
            END;                                                                00417300
         END;                                                                   00417400
         CALL ADVANCE_CP;                                                       00417500
         RETURN NUM_DELIMETERS + 1;  /* UNKNOWN DELIMETER */                    00417600
      END NEXT_TOKEN;                                                           00417700
                                                                                00417800
      IF ^ACCESS_FOUND THEN RETURN;  /* NO ACCESS FLAGS PRESENT */              00417900
      IF MONITOR(2, 6, PROGRAM_ID) THEN DO;                                     00418000
         CALL ERROR(CLASS_PA, 1, PROGRAM_ID);                                   00418100
         RETURN;                                                                00418200
      END;                                                                      00418300
      ACCESS_OFF = ^ACCESS_FLAG;                                                00418400
      LETTER_OR_DIGIT(BYTE('$')) = TRUE;  /* FOR THIS PROC ONLY */              00418500
      CP = TEXT_LIMIT;                                                          00418600
      CALL ADVANCE_CP;  /* GET IT ALL STARTED */                                00418700
RESTART:                                                                        00418800
      I = NEXT_TOKEN;                                                           00418900
      IF I ^= 0 THEN GO TO SYNTAX_ERROR;                                        00419000
      BLOCK_NAME = A_TOKEN;                                                     00419100
      IF NEXT_TOKEN ^= 1 THEN GO TO SYNTAX_ERROR;                               00419200
RECOVERY_POINT:                                                                 00419300
      IF BLOCK_NAME = '$BLOCK' THEN                                             00419400
         DO FOREVER;                                                            00419500
         IF NEXT_TOKEN ^= 0 THEN GO TO SYNTAX_ERROR;                            00419600
         I = LOOKUP(A_TOKEN);                                                   00419700
         IF I < 0 THEN CALL ACCESS_ERROR(1, A_TOKEN);                           00419800
         ELSE DO;                                                               00419900
            IF (SYT_TYPE(I) = PROC_LABEL)                                       00420000
               | (SYT_TYPE(I) = PROG_LABEL)                                     00420100
               | (SYT_CLASS(I) = FUNC_CLASS) THEN                               00420200
               CALL RESET_ACCESS_FLAG;                                          00420300
            ELSE IF SYT_TYPE(I) = COMPOOL_LABEL THEN DO;                        00420400
               J = ^READ_ACCESS_FLAG;                                           00420500
               CALL RESET_ACCESS_FLAG;                                          00420600
               DO WHILE (SYT_FLAGS(I) & ENDSCOPE_FLAG) = 0;                     00420700
                  I = I + 1;                                                    00420800
                  SYT_FLAGS(I) = SYT_FLAGS(I) & J;                              00420900
               END;                                                             00421000
            END;                                                                00421100
            ELSE CALL ACCESS_ERROR(2, A_TOKEN);                                 00421200
         END;                                                                   00421300
         I = NEXT_TOKEN;                                                        00421400
         IF I = 2 THEN GO TO RESTART;  /* CLOSE PAREN */                        00421500
         IF I ^= 3 THEN GO TO SYNTAX_ERROR;                                     00421600
      END;                                                                      00421700
      ELSE DO;  /* A COMPOOL NAME */                                            00421800
         BLOCK_START = LOOKUP(BLOCK_NAME);                                      00421900
         IF BLOCK_START < 0 THEN DO;                                            00422000
            CALL ACCESS_ERROR(1, BLOCK_NAME);                                   00422100
            GO TO RECOVER_WITHOUT_MSG;                                          00422200
         END;                                                                   00422300
         IF SYT_TYPE(BLOCK_START) ^= COMPOOL_LABEL THEN DO;                     00422400
            CALL ACCESS_ERROR(5, BLOCK_NAME);                                   00422500
            GO TO RECOVER_WITHOUT_MSG;                                          00422600
         END;                                                                   00422700
         IF (SYT_FLAGS(BLOCK_START) & ACCESS_FLAG) ^= 0 THEN DO;                00422800
            CALL ACCESS_ERROR(6, BLOCK_NAME);                                   00422900
            GO TO RECOVER_WITHOUT_MSG;                                          00423000
         END;                                                                   00423100
         BLOCK_END = BLOCK_START;                                               00423200
         DO WHILE (SYT_FLAGS(BLOCK_END) & ENDSCOPE_FLAG) = 0;                   00423300
            BLOCK_END = BLOCK_END + 1;                                          00423400
         END;                                                                   00423500
         DO FOREVER;                                                            00423600
            IF NEXT_TOKEN ^= 0 THEN GO TO SYNTAX_ERROR;                         00423700
            IF A_TOKEN = '$ALL' THEN DO;                                        00423800
               DO I = BLOCK_START TO BLOCK_END;                                 00423900
                  SYT_FLAGS(I) = SYT_FLAGS(I) & ACCESS_OFF;                     00424000
               END;                                                             00424100
               IF NEXT_TOKEN ^= 2 THEN GO TO SYNTAX_ERROR;                      00424200
               GO TO RESTART;                                                   00424300
            END;                                                                00424400
            I = LOOKUP(A_TOKEN);                                                00424500
            IF I < 0 THEN CALL ACCESS_ERROR(1, A_TOKEN);                        00424600
            ELSE DO;                                                            00424700
               IF (I > BLOCK_END) | (I < BLOCK_START) THEN                      00424800
                  CALL ACCESS_ERROR(4, A_TOKEN);                                00424900
               ELSE CALL RESET_ACCESS_FLAG;                                     00425000
            END;                                                                00425100
            I = NEXT_TOKEN;                                                     00425200
            IF I = 2 THEN GO TO RESTART;                                        00425300
            IF I ^= 3 THEN GO TO SYNTAX_ERROR;                                  00425400
         END;                                                                   00425500
      END;                                                                      00425600
SYNTAX_ERROR:                                                                   00425700
      CALL ACCESS_ERROR(0);                                                     00425800
      I = NEXT_TOKEN;                                                           00425900
      BLOCK_NAME = A_TOKEN;                                                     00426000
RECOVER_WITHOUT_MSG:                                                            00426100
      DO WHILE NEXT_TOKEN ^= 1;                                                 00426200
         BLOCK_NAME = A_TOKEN;                                                  00426300
      END;                                                                      00426400
      GO TO RECOVERY_POINT;                                                     00426500
END_FILE_EXIT:                                                                  00426600
      LETTER_OR_DIGIT(BYTE('$')) = FALSE;  /* RESTORE */                        00426700
      RETURN;                                                                   00426800
   END INTERPRET_ACCESS_FILE;                                                   00426900
