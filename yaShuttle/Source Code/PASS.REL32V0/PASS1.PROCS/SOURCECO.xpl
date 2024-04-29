 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SOURCECO.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  SOURCE_COMPARE                                         */
 /* MEMBER NAME:     SOURCECO                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          INCL_NUM          CHARACTER;                                   */
 /*          DELTA_LEN         BIT(16)                                      */
 /*          PATCH_INCL_NUM    CHARACTER;                                   */
 /*          PATCH_SRN_COUNT   BIT(16)                                      */
 /*          REPLCNT           BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDED                                                          */
 /*          DELETED                                                        */
 /*          FALSE                                                          */
 /*          INCL_LOG_MSG                                                   */
 /*          INCLUDING                                                      */
 /*          INPUT_DEV                                                      */
 /*          PATCH_INCL_HEAD                                                */
 /*          PATCH_TEXT_LIMIT                                               */
 /*          PATCHSAVE                                                      */
 /*          PLUS                                                           */
 /*          SAVE_LINE                                                      */
 /*          SRN_COUNT                                                      */
 /*          STARS                                                          */
 /*          TEXT_LIMIT                                                     */
 /*          TRUE                                                           */
 /*          UPDATE_INPUT_DEV                                               */
 /*          X1                                                             */
 /*          X109                                                           */
 /*          X70                                                            */
 /*          X8                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          ADDING                                                         */
 /*          COMPARE_SOURCE                                                 */
 /*          CUR_CARD                                                       */
 /*          CURRENT_CARD                                                   */
 /*          CURRENT_SRN                                                    */
 /*          DELETING                                                       */
 /*          FIRST_CARD                                                     */
 /*          I                                                              */
 /*          INITIAL_INCLUDE_RECORD                                         */
 /*          MORE                                                           */
 /*          NO_MORE_PATCH                                                  */
 /*          NO_MORE_SOURCE                                                 */
 /*          PAT_CARD                                                       */
 /*          PATCH_CARD                                                     */
 /*          PATCH_COUNT                                                    */
 /*          PATCH_SRN                                                      */
 /*          PRINT_INCL_HEAD                                                */
 /*          PRINT_INCL_TAIL                                                */
 /*          REPLACING                                                      */
 /*          SAVE_PATCH                                                     */
 /*          UPDATING                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          LEFT_PAD                                                       */
 /*          SRNCMP                                                         */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SOURCE_COMPARE <==                                                  */
 /*     ==> LEFT_PAD                                                        */
 /*     ==> SRNCMP                                                          */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  REVISION HISTORY                                                       */
 /*                                                                         */
 /*  DATE      WHO  RLS       DR/CR #   DESCRIPTION                         */
 /*                                                                         */
 /*  04/26/01  DCP  31V0/     CR13335   ALLEVIATE SOME DATA SPACE PROBLEMS  */
 /*                 16V0                IN HAL/S COMPILER                   */
 /*                                                                         */
 /***************************************************************************/
SOURCE_COMPARE:                                                                 00434210
   PROCEDURE;                                                                   00434220
 /*THIS ROUTINE COMPARES THE SRNS AND THE TEXT LINES*/                          00434230
 /*OF THE ORIGINAL AND PATCHED SOURCES TO DETERMINE THE*/                       00434240
 /*UPDATE MODE(ADDING.DELETING OR REPLACING)*/                                  00434250
      DECLARE REPLCNT BIT(16) INITIAL(0);                                       00434260
      DECLARE PATCH_SRN_COUNT BIT(16);                                          00434270
      DECLARE (PATCH_INCL_NUM,INCL_NUM) CHARACTER;                              00434280
      DECLARE DELTA_LEN BIT(16);                                                00434290
      IF NO_MORE_SOURCE THEN RETURN;                                            00434300
      IF ^FIRST_CARD THEN                                                       00434310
         IF ^INITIAL_INCLUDE_RECORD THEN                                        00434320
         CURRENT_CARD=INPUT(INPUT_DEV);                                         00434330
      ELSE DO;                                                                  00434340
         IF ^COMPARE_SOURCE THEN DO;                                            00434350
            INITIAL_INCLUDE_RECORD=FALSE;                                       00434360
            RETURN;                                                             00434370
         END;                                                                   00434380
      END;                                                                      00434390
      IF ^COMPARE_SOURCE THEN RETURN;                                           00434400
      IF LENGTH(CURRENT_CARD)^=0 THEN DO;                                       00434410
         CUR_CARD=SUBSTR(CURRENT_CARD,0,TEXT_LIMIT);                            00434420
         CURRENT_SRN=SUBSTR(CURRENT_CARD,TEXT_LIMIT+1,6);                       00434430
      END;                                                                      00434440
      ELSE                                                                      00434450
         NO_MORE_SOURCE=TRUE;                                                   00434460
 /* MORE INDICATES THAT ADDITIONAL RECORDS HAVE TO READ FROM THE */             00434470
 /* PATCH INPUT IN ORDER TO SYNCHRONIZE    */                                   00434480
      MORE=TRUE;                                                                00434490
      DO WHILE MORE;                                                            00434500
 /* READ UPDATED SOURCE CODE*/                                                  00434510
         IF NO_MORE_PATCH THEN RETURN;                                          00434520
         IF ^DELETING THEN DO;                                                  00434530
            IF ^FIRST_CARD THEN                                                 00434540
               IF ^INITIAL_INCLUDE_RECORD THEN DO;                              00434550
               PATCH_CARD=INPUT(UPDATE_INPUT_DEV);                              00434560
            END;                                                                00434570
            ELSE DO;                                                            00434580
               INITIAL_INCLUDE_RECORD=FALSE;                                    00434590
               PATCH_SRN_COUNT=0;                                               00434600
            END;                                                                00434610
            FIRST_CARD=FALSE;                                                   00434620
            IF LENGTH(PATCH_CARD) = 0 THEN DO;                                  00434630
               IF ^INCLUDING THEN                                               00434640
                  COMPARE_SOURCE=FALSE;                                         00434650
               NO_MORE_PATCH=TRUE;                                              00434660
               IF REPLCNT ^= 0 THEN                                             00434670
                  DO I=0 TO REPLCNT-1;                                          00434680
                  OUTPUT(9)=PATCHSAVE(I);                                       00434690
               END;                                                             00434700
               REPLCNT=0;                                                       00434710
               RETURN;                                                          00434720
            END;                                                                00434730
            ELSE DO;                                                            00434740
               PAT_CARD=SUBSTR(PATCH_CARD,0,TEXT_LIMIT);                        00434750
               PATCH_SRN=SUBSTR(PATCH_CARD,PATCH_TEXT_LIMIT+1,6);               00434760
            END;                                                                00434770
         END;                                                                   00434780
         IF INCLUDING THEN DO;                                                  00434790
            IF (BYTE(SUBSTR(CUR_CARD,0,1))^=BYTE('D')) &                        00434800
               (BYTE(SUBSTR(CUR_CARD,0,1)) ^=BYTE('C')) THEN                    00434810
               INCL_NUM=LEFT_PAD('('||PLUS||(SRN_COUNT+1)||')',6)||             00434820
               X1;                                                              00434830
            ELSE                                                                00434840
               INCL_NUM=X8;                                                     00434850
            IF (BYTE(SUBSTR(PAT_CARD,0,1)) ^=BYTE('D')) &                       00434860
               (BYTE(SUBSTR(PAT_CARD,0,1)) ^= BYTE('C')) THEN DO;               00434870
               IF ^DELETING THEN DO;                                            00434880
                  PATCH_SRN_COUNT=PATCH_SRN_COUNT+1;                            00434890
                  PATCH_INCL_NUM=LEFT_PAD(PLUS||PATCH_SRN_COUNT,6)||            00434900
                     X1;                                                        00434910
               END;                                                             00434920
            END;                                                                00434930
            ELSE PATCH_INCL_NUM=X8;                                             00434940
         END;                                                                   00434950
         ELSE DO;                                                               00434960
            INCL_NUM='';                                                        00434970
            PATCH_INCL_NUM='';                                                  00434980
         END;                                                                   00434990
         DO CASE SRNCMP(CURRENT_SRN,PATCH_SRN);                                 00435000
 /*CASE 0, SRNS IDENTICAL, TEXTS POSSIBLY DIFFERENT*/                           00435010
            DO;                                                                 00435020
               IF PAT_CARD^=CUR_CARD THEN DO;                                   00435030
 /*TEXTS DIFFERENT*/                                                            00435040
                  IF UPDATING THEN DO;                                          00435050
                     IF ^REPLACING THEN DO;                                     00435060
                        OUTPUT(9)=X70;                                          00435070
                        ADDING,DELETING=FALSE;                                  00435080
                     END;                                                       00435090
                  END;                                                          00435100
                  UPDATING=TRUE;                                                00435110
                  REPLACING=TRUE;                                               00435120
                  IF INCLUDING & PRINT_INCL_HEAD THEN DO;                       00435130
                     OUTPUT(9)=X1||PATCH_INCL_HEAD;                 /*CR13335*/ 00435140
                     OUTPUT(9)='I'||STARS||' START '||INCL_LOG_MSG;             00435150
                     OUTPUT(9)=X1;                                              00435160
                     PRINT_INCL_HEAD=FALSE;                                     00435170
                     PRINT_INCL_TAIL=TRUE;                                      00435180
                  END;                                                          00435190
                  DELTA_LEN=LENGTH(CURRENT_CARD)+LENGTH(INCL_NUM);              00435200
                  PATCH_COUNT=PATCH_COUNT+1;                                    00435210
                  OUTPUT(9)=X1||CURRENT_SRN||X1||INCL_NUM||CUR_CARD|| /*C13335*/00435220
                     SUBSTR(X109,DELTA_LEN)||DELETED;                           00435230
                  DELTA_LEN=LENGTH(PATCH_CARD)+LENGTH(PATCH_INCL_NUM);          00435240
                  PATCHSAVE(REPLCNT)='R'||PATCH_SRN||X1||PATCH_INCL_NUM||       00435250
                     PAT_CARD||SUBSTR(X109,DELTA_LEN)||ADDED;                   00435260
                  REPLCNT=REPLCNT+1;                                            00435270
                  DO WHILE RECORD_USED(SAVE_PATCH)<=REPLCNT;                    00435280
                     NEXT_ELEMENT(SAVE_PATCH);                                  00435290
                  END;                                                          00435300
               END;                                                             00435310
               ELSE DO;                                                         00435320
                  IF UPDATING THEN DO;                                          00435330
                     IF REPLACING THEN DO;                                      00435340
                        DO I=0 TO REPLCNT-1;                                    00435350
                           OUTPUT(9)=PATCHSAVE(I);                              00435360
                        END;                                                    00435370
                        REPLCNT=0;                                              00435380
                     END;                                                       00435390
                     UPDATING=FALSE;                                            00435400
                     ADDING,DELETING,REPLACING=FALSE;                           00435410
                     OUTPUT(9)=X70;                                             00435420
                  END;                                                          00435430
               END;                                                             00435440
               IF NO_MORE_SOURCE THEN MORE=TRUE;                                00435450
               ELSE MORE=FALSE;                                                 00435460
            END;                                                                00435470
 /* CASE 1: CURRENT_SRN<PATCH_SRN*/                                             00435480
            DO;                                                                 00435490
               IF UPDATING THEN DO;                                             00435500
                  IF ^DELETING THEN DO;                                         00435510
                     IF REPLACING THEN DO;                                      00435520
                        DO I=0 TO REPLCNT-1;                                    00435530
                           OUTPUT(9)=PATCHSAVE(I);                              00435540
                        END;                                                    00435550
                        REPLCNT=0;                                              00435560
                     END;                                                       00435570
                     OUTPUT(9)=X70;                                             00435580
                  END;                                                          00435590
               END;                                                             00435600
               DELETING=TRUE;                                                   00435610
               UPDATING=TRUE;                                                   00435620
               REPLACING,ADDING=FALSE;                                          00435630
               IF INCLUDING & PRINT_INCL_HEAD THEN DO;                          00435640
                  OUTPUT(9)=X1||PATCH_INCL_HEAD;                    /*CR13335*/ 00435650
                  OUTPUT(9)='I'||STARS||' START '||INCL_LOG_MSG;                00435660
                  OUTPUT(9)=X1;                                                 00435670
                  PRINT_INCL_HEAD=FALSE;                                        00435680
                  PRINT_INCL_TAIL=TRUE;                                         00435690
               END;                                                             00435700
               DELTA_LEN=LENGTH(CURRENT_CARD)+LENGTH(INCL_NUM);                 00435710
               PATCH_COUNT=PATCH_COUNT+1;                                       00435720
               OUTPUT(9)='D'||CURRENT_SRN||X1||INCL_NUM||CUR_CARD||             00435730
                  SUBSTR(X109,DELTA_LEN)||DELETED;                              00435740
               IF NO_MORE_SOURCE THEN MORE=TRUE;                                00435750
               ELSE MORE=FALSE;                                                 00435760
            END;                                                                00435770
 /* CASE 2 :CURRENT_SRN>PATCH_SRN */                                            00435780
            DO;                                                                 00435790
               MORE=TRUE;                                                       00435800
               IF UPDATING THEN DO;                                             00435810
                  IF ^ADDING THEN DO;                                           00435820
                     IF REPLACING THEN DO;                                      00435830
                        DO I=0 TO REPLCNT-1;                                    00435840
                           OUTPUT(9)=PATCHSAVE(I);                              00435850
                        END;                                                    00435860
                        REPLCNT=0;                                              00435870
                     END;                                                       00435880
                     ADDING=TRUE;                                               00435890
                     REPLACING,DELETING=FALSE;                                  00435900
                     OUTPUT(9)=X70;                                             00435910
                  END;                                                          00435920
               END;                                                             00435930
               IF INCLUDING & PRINT_INCL_HEAD THEN DO;                          00435940
                  OUTPUT(9)=X1||PATCH_INCL_HEAD;                    /*CR13335*/ 00435950
                  OUTPUT(9)='I'||STARS||' START '|| INCL_LOG_MSG;               00435960
                  OUTPUT(9)=X1;                                                 00435970
                  PRINT_INCL_HEAD=FALSE;                                        00435980
                  PRINT_INCL_TAIL=TRUE;                                         00435990
               END;                                                             00436000
               DELTA_LEN=LENGTH(PATCH_CARD)+LENGTH(PATCH_INCL_NUM);             00436010
               PATCH_COUNT=PATCH_COUNT+1;                                       00436020
               OUTPUT(9)='A'||PATCH_SRN||X1||PATCH_INCL_NUM||PAT_CARD||         00436030
                  SUBSTR(X109,DELTA_LEN)||ADDED;                                00436040
               UPDATING,ADDING=TRUE;                                            00436050
            END;                                                                00436060
         END;                                                                   00436070
      END;                                                                      00436080
      RETURN;                                                                   00436090
   END SOURCE_COMPARE;   /*  $S  $S */                                          00436100
