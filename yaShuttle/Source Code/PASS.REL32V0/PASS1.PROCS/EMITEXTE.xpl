 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   EMITEXTE.xpl
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
 /* PROCEDURE NAME:  EMIT_EXTERNAL                                          */
 /* MEMBER NAME:     EMITEXTE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_CHAR(1538)    LABEL                                        */
 /*          BINX              BIT(16)                                      */
 /*          CHAR              CHARACTER;                                   */
 /*          EX_WRITE(1528)    LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          INCR_PTR(1533)    LABEL                                        */
 /*          J                 BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          NEWBUFF           CHARACTER;                                   */
 /*          OLDBUFF           CHARACTER;                                   */
 /*          VERSION           CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BCD                                                            */
 /*          BLOCK_SYTREF                                                   */
 /*          CHARACTER_STRING                                               */
 /*          CLASS_XV                                                       */
 /*          ESCP                                                           */
 /*          MAC_TXT                                                        */
 /*          MACRO_TEXTS                                                    */
 /*          MACRO_TEXT                                                     */
 /*          MP                                                             */
 /*          PARSE_STACK                                                    */
 /*          REPLACE_TEXT                                                   */
 /*          RESERVED_WORD                                                  */
 /*          SDL_OPTION                                                     */
 /*          SP                                                             */
 /*          START_POINT                                                    */
 /*          SYM_LOCK#                                                      */
 /*          SYT_LOCK#                                                      */
 /*          TOKEN                                                          */
 /*          TPL_LRECL                                                      */
 /*          TRANS_OUT                                                      */
 /*          VAR                                                            */
 /*          VOCAB_INDEX                                                    */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXTERNALIZE                                                    */
 /*          SYM_TAB                                                        */
 /*          TPL_FLAG                                                       */
 /*          TPL_NAME                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          BLANK                                                          */
 /*          DESCORE                                                        */
 /*          ERROR                                                          */
 /*          FINDER                                                         */
 /*          PAD                                                            */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /*          COMPILATION_LOOP                                               */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> EMIT_EXTERNAL <==                                                   */
 /*     ==> PAD                                                             */
 /*     ==> BLANK                                                           */
 /*     ==> DESCORE                                                         */
 /*         ==> PAD                                                         */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> FINDER                                                          */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 06/20/91 TEV  7V0   CR11114  MERGE BFS/PASS COMPILERS WITH DR FIXES     */
 /*                                                                         */
 /* 04/26/01 DCP  31V0  CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS IN      */
 /*               16V0           HAL/S COMPILER                             */
 /***************************************************************************/
                                                                                00764500
EMIT_EXTERNAL:                                                                  00764600
   PROCEDURE;                                                                   00764700
      DECLARE (NEWBUFF,OLDBUFF,CHAR) CHARACTER,                                 00764800
         VERSION CHARACTER INITIAL('D VERSION  '),                              00764900
         (BINX, I, J, K) BIT(16);                                               00765000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; FIX COMPOOL RIGID BUG */
      DECLARE BLANK_NEEDED BIT(8) INITIAL(TRUE);
 ?/
EX_WRITE:                                                                       00765300
      PROCEDURE;                                                                00765400
         OUTPUT(6)=NEWBUFF;                                                     00765500
         DO CASE TPL_FLAG;                                                      00765600
            ;                                                                   00765700
            DO;                                                                 00765800
               IF NEWBUFF^=SUBSTR(OLDBUFF,0,TPL_LRECL) THEN TPL_FLAG=2;         00765900
               ELSE OLDBUFF=INPUT(7);                                           00766000
            END;                                                                00766100
            ;;                                                                  00766200
            END;                                                                00766300
      END EX_WRITE;                                                             00766400
                                                                                00766405
ADD_CHAR:                                                                       00766410
      PROCEDURE(VAL);                                                           00766415
         DECLARE VAL BIT(16);                                                   00766420
         BYTE(NEWBUFF, BINX) = VAL;                                             00766425
         BINX = BINX + 1;                                                       00766430
         IF BINX = TPL_LRECL THEN DO;                                           00766435
            CALL EX_WRITE;                                                      00766440
            CALL BLANK(NEWBUFF, 0, TPL_LRECL);                                  00766445
            BINX = 1;                                                           00766450
         END;                                                                   00766455
      END ADD_CHAR;                                                             00766460
                                                                                00766500
      DO CASE EXTERNALIZE;                                                      00766600
         ;   /*  NOT OPERATING  */                                              00766700
         DO;  /* RUNNING */                                                     00766800
            IF TOKEN = REPLACE_TEXT THEN DO;                                    00766810
               CALL ADD_CHAR(BYTE('"'));                                        00766820
               I = START_POINT;                                                 00766830
               J = MACRO_TEXT(I);                                               00766840
               DO WHILE J ^= "EF";                                              00766850
                  IF J = BYTE('"') THEN DO;                                     00766860
                     CALL ADD_CHAR(BYTE('"'));                                  00766870
                     CALL ADD_CHAR(BYTE('"'));                                  00766880
                  END;                                                          00766890
                  ELSE IF J = "EE" THEN DO;                                     00766900
                     DO J = 1 TO MACRO_TEXT(I+1) + (MACRO_TEXT(I+1)^=0);        00766910
                        CALL ADD_CHAR(BYTE(X1));                    /*CR13335*/ 00766920
                     END;                                                       00766930
                     I = I + 1;                                                 00766940
                  END;                                                          00766950
                  ELSE CALL ADD_CHAR(J);  /* NORMAL TEXT */                     00766960
                  I = I + 1;                                                    00766970
                  J = MACRO_TEXT(I);                                            00766980
               END;  /* OF WHILE NOT "EF" */                                    00766990
               CALL ADD_CHAR(BYTE('"'));                                        00767000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN    */
      /*            TEMPLATE                                      */
               BLANK_NEEDED = TRUE;
 ?/
            END;  /* OF TOKEN = REPLACE_TEXT */                                 00767010
            ELSE IF RESERVED_WORD THEN DO;                                      00767020
               CHAR = STRING(VOCAB_INDEX(TOKEN));                               00767030
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN    */
      /*            TEMPLATE                                      */
               IF LENGTH(CHAR) = 1 THEN BLANK_NEEDED = FALSE;
               ELSE DO;
                  IF BLANK_NEEDED THEN CALL ADD_CHAR(BYTE(X1));     /*CR13335*/
                  BLANK_NEEDED = TRUE;
               END;
 ?/
               DO I = 0 TO LENGTH(CHAR) - 1;                                    00767040
                  CALL ADD_CHAR(BYTE(CHAR, I));                                 00767050
               END;                                                             00767060
            END;                                                                00767070
            ELSE IF TOKEN = CHARACTER_STRING THEN DO;                           00767080
               CALL ADD_CHAR(BYTE(SQUOTE));                         /*CR13335*/ 00767090
               I = 0;                                                           00767100
               J = BYTE(BCD, I);                                                00767110
               DO WHILE (J ^= BYTE(SQUOTE)) & (I < LENGTH(BCD));    /*CR13335*/ 00767120
                  IF (TRANS_OUT(J) & "FF") ^= 0 THEN DO;                        00767130
                     DO K = 0 TO SHR(TRANS_OUT(J), 8) & "FF";                   00767140
                        CALL ADD_CHAR(ESCP);                                    00767150
                     END;                                                       00767160
                     CALL ADD_CHAR(TRANS_OUT(J) & "FF");                        00767170
                  END;                                                          00767180
                  ELSE CALL ADD_CHAR(J);                                        00767190
INCR_PTR:                                                                       00767200
                  I = I + 1;                                                    00767210
                  J = BYTE(BCD, I);                                             00767220
               END;  /* OF DO WHILE */                                          00767230
               CALL ADD_CHAR(BYTE(SQUOTE));                         /*CR13335*/ 00767240
               IF I ^= LENGTH(BCD) THEN DO;                                     00767250
                  CALL ADD_CHAR(BYTE(SQUOTE));                      /*CR13335*/ 00767260
                  GO TO INCR_PTR;                                               00767270
               END;                                                             00767280
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN  */
      /*            TEMPLATE                                    */
               BLANK_NEEDED = FALSE;
 ?/
            END;  /* OF TOKEN = CHARACTER_STRING */                             00767290
            ELSE DO;  /* TOKEN = ANYTHING ELSE */                               00767300
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN  */
      /*            TEMPLATE                                    */
               IF BLANK_NEEDED THEN CALL ADD_CHAR(BYTE(X1));        /*CR13335*/
 ?/
               DO I = 0 TO LENGTH(BCD) - 1;                                     00767310
                  CALL ADD_CHAR(BYTE(BCD, I));                                  00767320
               END;                                                             00767330
 /?B  /* CR11114 -- BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN  */
      /*            TEMPLATE                                    */
               BLANK_NEEDED = TRUE;
 ?/
            END;  /* OF TOKEN = ANYTHING ELSE */                                00767340
 /?P  /* CR11114 -- BFS/PASS INTERFACE; DELETE EXTRA BLANKS IN  */
      /*            TEMPLATE FOR BFS                            */
            CALL ADD_CHAR(BYTE(X1));    /* SPACE BETWEEN TOKENS */  /*CR13335*/ 00767350
 ?/
         END;  /* OF RUNNING */                                                 00767360
         DO;   /*  STOPPING  */                                                 00772900
            IF BINX>1 THEN CALL EX_WRITE;                                       00773000
            NEWBUFF=PAD(' CLOSE ;   ',TPL_LRECL);                               00773100
            CALL EX_WRITE;                                                      00773200
            EXTERNALIZE=0;                                                      00773300
            IF TPL_FLAG=3 THEN RETURN;                                          00773400
            IF TPL_FLAG=0 THEN J,BYTE(VERSION,10)="01";                         00773500
            ELSE DO;                                                            00773600
               DO WHILE LENGTH(OLDBUFF)>0;                                      00773700
                  NEWBUFF=OLDBUFF;                                              00773800
                  OLDBUFF=INPUT(7);                                             00773900
               END;                                                             00774000
               CALL MONITOR(3, 7);  /* CLOSE THE TEMPLATE FILE */               00774010
               IF SUBSTR(NEWBUFF,0,10)^=SUBSTR(VERSION,0,10) THEN DO;           00774100
                  I,J="01";                                                     00774200
                  IF ^SDL_OPTION THEN                                           00774300
                     CALL ERROR(CLASS_XV, 1, TPL_NAME);                         00774310
               END;                                                             00774400
               ELSE DO;                                                         00774500
                  J=BYTE(NEWBUFF,10);                                           00774600
                  IF J="FF" THEN I="01";                                        00774700
                  ELSE I=J+1;                                                   00774800
                  IF TPL_FLAG=2 THEN J=I;                                       00774900
               END;                                                             00775000
               BYTE(VERSION,10)=I;                                              00775100
            END;                                                                00775200
            SYT_LOCK#(BLOCK_SYTREF(1))=J;                                       00775300
            OUTPUT(6) = VERSION || BYTE(VERSION, 10);                           00775400
         END;                                                                   00775500
         DO;  /*  STARTING  */                                                  00775600
            NEWBUFF=': EXTERNAL '||STRING(VOCAB_INDEX(PARSE_STACK(SP)))||X1;    00775700
            NEWBUFF=X1||VAR(MP)||NEWBUFF;                                       00775800
            BINX=LENGTH(NEWBUFF);                                               00775900
            NEWBUFF=PAD(NEWBUFF,TPL_LRECL);                                     00776000
            EXTERNALIZE=1;                                                      00776100
            TPL_NAME=DESCORE(VAR(MP));                                          00776200
            TPL_FLAG = FINDER(7, TPL_NAME, 1) = 0;  /* IGNORE INLINE BLOCKS */  00776300
            IF TPL_FLAG THEN OLDBUFF=INPUT(7);                                  00776400
         END;                                                                   00776500
         ;  /*  QUIESCENT  */                                                   00776600
      END;                                                                      00776700
   END EMIT_EXTERNAL;                                                           00776800
