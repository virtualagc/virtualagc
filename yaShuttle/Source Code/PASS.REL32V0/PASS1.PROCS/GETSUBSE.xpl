 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GETSUBSE.xpl
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
 /* PROCEDURE NAME:  GET_SUBSET                                             */
 /* MEMBER NAME:     GETSUBSE                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          SUBSET            CHARACTER;                                   */
 /*          FLAGS             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          A_TOKEN           CHARACTER;                                   */
 /*          CASE_B2           LABEL                                        */
 /*          CASE_P2           LABEL                                        */
 /*          CP                BIT(16)                                      */
 /*          GET_TOKEN         LABEL                                        */
 /*          I                 BIT(16)                                      */
 /*          L                 BIT(16)                                      */
 /*          LIMIT             BIT(16)                                      */
 /*          S                 CHARACTER;                                   */
 /*          SUBSET_ERROR      LABEL                                        */
 /*          SUBSET_MSG        CHARACTER;                                   */
 /*          VALUE             LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BI#                                                            */
 /*          BI_NAME                                                        */
 /*          FOREVER                                                        */
 /*          P#                                                             */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          #PRODUCE_NAME                                                  */
 /*          BI_FLAGS                                                       */
 /*          BIT_LENGTH_LIM                                                 */
 /* CALLED BY:                                                              */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
 /***************************************************************************/
 /*                                                                         */
 /*  REVISION HISTORY                                                       */
 /*                                                                         */
 /*  DATE      WHO  RLS      DR/CR #  DESCRIPTION                           */
 /*                                                                         */
 /*  04/26/01  DCP  31V0/    CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS IN */
 /*                 16V0              HAL/S COMPILER                        */
 /*                                                                         */
 /***************************************************************************/
                                                                                01054500
GET_SUBSET:                                                                     01054502
   PROCEDURE (SUBSET,FLAGS);                                                    01054504
      DECLARE (A_TOKEN,S,SUBSET) CHARACTER, (I,L,LIMIT,CP) BIT(16),             01054506
         FLAGS BIT(8);                                                          01054508
      DECLARE SUBSET_MSG CHARACTER INITIAL(                                     01054510
         '0 *** LANGUAGE SUBSET IN EFFECT: ');                                  01054512
                                                                                01054514
VALUE:                                                                          01054516
      PROCEDURE;                                                                01054518
         DECLARE (J,M) BIT(16);                                                 01054520
         L=0;                                                                   01054522
         DO J=1 TO LENGTH(A_TOKEN);                                             01054524
            M=BYTE(A_TOKEN,J-1)-BYTE('0');                                      01054526
            IF (M<0)|(M>9) THEN RETURN -1;                                      01054528
            L=L*10+M;                                                           01054530
         END;                                                                   01054532
         RETURN L;                                                              01054534
      END VALUE;                                                                01054536
                                                                                01054538
GET_TOKEN:                                                                      01054540
      PROCEDURE;                                                                01054542
         DECLARE T# LITERALLY '3';                                              01054544
         DECLARE TERM(T#) BIT(8) INITIAL (0,"4D","5D","6B");                    01054546
         A_TOKEN='';                                                            01054548
         DO FOREVER;                                                            01054550
            CP=CP+1;                                                            01054552
            IF CP>LIMIT THEN DO;                                                01054554
NEXLINE:                                                                        01054556
               S=INPUT(6);                                                      01054558
               I=0;                                                             01054560
               IF LENGTH(S)=0 THEN RETURN 0;                                    01054562
               IF BYTE(S)=BYTE('C') THEN GO TO NEXLINE;                         01054564
               CP=0;                                                            01054566
            END;                                                                01054568
            IF BYTE(S,CP)^=BYTE(X1) THEN DO;                        /*CR13335*/ 01054570
               DO I=1 TO T#;                                                    01054572
                  IF BYTE(S,CP)=TERM(I) THEN RETURN I;                          01054574
               END;                                                             01054576
               A_TOKEN=A_TOKEN||SUBSTR(S,CP,1);                                 01054578
            END;                                                                01054580
         END;                                                                   01054582
      END GET_TOKEN;                                                            01054584
                                                                                01054586
SUBSET_ERROR:                                                                   01054588
      PROCEDURE (NUM);                                                          01054590
         DECLARE NUM BIT(16), T CHARACTER;                                      01054592
         DECLARE S_PREFIX CHARACTER INITIAL(                                    01054594
            '  *** SUBSET ACQUISITION ERROR - ');                               01054596
         DECLARE S_MSG(4) CHARACTER INITIAL('PREMATURE EOF',                    01054598
            'BAD SYNTAX: ','UNKNOWN FUNCTION: ',                                01054600
            'UNKNOWN PRODUCTION: ', 'ILLEGAL BIT LENGTH: ');                    01054602
         DO CASE NUM;                                                           01054604
            T='';                                                               01054606
            DO;                                                                 01054608
               T=S;                                                             01054610
               DO WHILE GET_TOKEN;                                              01054612
               END;                                                             01054614
            END;                                                                01054616
            T=A_TOKEN;                                                          01054618
            T=A_TOKEN;                                                          01054620
            T=A_TOKEN;                                                          01054621
         END;                                                                   01054622
         OUTPUT=S_PREFIX||S_MSG(NUM)||T;                                        01054624
      END SUBSET_ERROR;                                                         01054626
                                                                                01054628
      IF MONITOR(2,6,SUBSET) THEN RETURN 1;                                     01054630
      S=INPUT(6);                                                               01054632
      IF LENGTH(S)=0 THEN RETURN 1;                                             01054634
      LIMIT=LENGTH(S)-1;                                                        01054636
      OUTPUT(1)=SUBSET_MSG||S;                                                  01054638
      OUTPUT=X1;                                                                01054640
      CP=LIMIT;                                                                 01054642
      I=1;                                                                      01054644
      DO WHILE I^=0;                                                            01054646
         DO CASE GET_TOKEN;                                                     01054648
            IF LENGTH(A_TOKEN)>0 THEN CALL SUBSET_ERROR(0);                     01054650
            DO;                                                                 01054652
               IF A_TOKEN='$BUILTINS' THEN DO WHILE I;                          01054654
                  DO CASE GET_TOKEN;                                            01054656
                     CALL SUBSET_ERROR(0);                                      01054658
                     CALL SUBSET_ERROR(1);                                      01054660
CASE_B2:                                                                        01054662
                     DO;                                                        01054664
                        L=BI#;                                                  01054666
                        DO WHILE L>0;                                           01054668
                           IF SUBSTR(BI_NAME(BI_INDX(L)),BI_LOC(L),10)/*C13335*/01054670
                              = PAD(A_TOKEN,10)                      /*CR13335*/
                           THEN DO;                                  /*CR13335*/
                              BI_FLAGS(L)=BI_FLAGS(L)|FLAGS;                    01054672
                              L=-1;                                             01054674
                           END;                                                 01054676
                           ELSE L=L-1;                                          01054678
                        END;                                                    01054680
                        IF L=0 THEN CALL SUBSET_ERROR(2);                       01054682
                     END;                                                       01054684
                     GO TO CASE_B2;                                             01054686
                  END;                                                          01054688
               END;                                                             01054690
               ELSE IF A_TOKEN='$PRODUCTIONS' THEN DO WHILE I;                  01054692
                  DO CASE GET_TOKEN;                                            01054694
                     CALL SUBSET_ERROR(0);                                      01054696
                     CALL SUBSET_ERROR(1);                                      01054698
CASE_P2:                                                                        01054700
                     DO;                                                        01054702
                        L=VALUE;                                                01054704
                        IF (L>0)&(L<=P#) THEN #PRODUCE_NAME(L)=                 01054706
                           #PRODUCE_NAME(L)|SHL(FLAGS,12);                      01054708
                        ELSE CALL SUBSET_ERROR(3);                              01054710
                     END;                                                       01054712
                     GO TO CASE_P2;                                             01054714
                  END;                                                          01054716
               END;                                                             01054718
               ELSE IF A_TOKEN = '$BITLENGTH' THEN DO WHILE I;                  01054720
                  DO CASE GET_TOKEN;                                            01054722
                     CALL SUBSET_ERROR(0);                                      01054724
                     CALL SUBSET_ERROR(1);                                      01054726
                     DO;                                                        01054728
                        L = VALUE;                                              01054730
                        IF L < 1 | L > BIT_LENGTH_LIM THEN                      01054732
                           CALL SUBSET_ERROR(4);                                01054734
                        ELSE BIT_LENGTH_LIM = L;                                01054736
                     END;                                                       01054738
                     CALL SUBSET_ERROR(1);                                      01054740
                  END;                                                          01054742
               END;                                                             01054744
               ELSE CALL SUBSET_ERROR(1);                                       01054746
            END;                                                                01054748
            CALL SUBSET_ERROR(1);                                               01054750
            CALL SUBSET_ERROR(1);                                               01054752
         END;                                                                   01054754
      END;                                                                      01054756
      OUTPUT=X1;                                                                01054758
      RETURN 0;                                                                 01054760
   END GET_SUBSET;                                                              01054762
