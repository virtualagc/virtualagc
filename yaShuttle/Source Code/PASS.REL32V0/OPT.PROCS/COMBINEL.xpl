 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMBINEL.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  COMBINE_LOOPS                                          */
 /* MEMBER NAME:     COMBINEL                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DIMS              BIT(16)                                      */
 /*          FIX_LOOP_STACK    LABEL                                        */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AR_DIMS                                                        */
 /*          AR_SIZE                                                        */
 /*          C_TRACE                                                        */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          IN_VM                                                          */
 /*          LOOP_HEAD                                                      */
 /*          STT#                                                           */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          A_PARITY                                                       */
 /*          COMBINE#                                                       */
 /*          LOOP_END                                                       */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /*          OPR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          VU                                                             */
 /* CALLED BY:                                                              */
 /*          CHECK_VM_COMBINE                                               */
 /*          FINAL_PASS                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COMBINE_LOOPS <==                                                   */
 /*     ==> VU                                                              */
 /*         ==> HEX                                                         */
 /***************************************************************************/
                                                                                01895320
                                                                                01895330
 /* COMBINES LOOPS*/                                                            01895340
COMBINE_LOOPS:                                                                  01895350
   PROCEDURE;                                                                   01895360
      DECLARE (TEMP,DIMS) BIT(16);                                              01895370
                                                                                01895380
                                                                                01895390
 /* COMBINES LOOPSTACK ENTRIES AND REMOVES THE EXTRA ONE*/                      01895400
FIX_LOOP_STACK:                                                                 01895410
      PROCEDURE;                                                                01895420
         DECLARE (INX) BIT(16),                                                 01895430
            (END_SEARCH,TMP,TMP2) BIT(8),                                       01895440
            (TEMP,TEMP2) FIXED;                                                 01895450
         INX = N_INX;                                                           01895460
         END_SEARCH = TRUE;                                                     01895470
         TEMP2,TMP2 = 0;                                                        01895480
                                                                                01895490
         DO WHILE INX > 0;                                                      01895500
            IF END_SEARCH THEN DO;                                              01895510
               IF (NODE(INX) & "FFFF") = LOOP_END THEN DO;                      01895520
                  END_SEARCH = FALSE;                                           01895530
               END;                                                             01895540
               TEMP = NODE(INX);                                                01895550
               NODE(INX) = TEMP2;                                               01895560
               TEMP2 = TEMP;                                                    01895570
               TMP = A_PARITY(INX);                                             01895580
               A_PARITY(INX) = TMP2;                                            01895590
               TMP2 = TMP;             /* MOVE STACK DOWN*/                     01895600
            END;                                                                01895610
            ELSE DO;                                                            01895620
               IF SHR(NODE(INX),16) = LOOP_HEAD(1) THEN DO;                     01895630
                  NODE(INX) = (NODE(INX) & "FFFF 0000") | LOOP_END;             01895640
                  A_PARITY(INX) = A_PARITY(INX) & TMP2;                         01895650
                  N_INX = N_INX - 1;                                            01895660
                  RETURN;                                                       01895670
               END;                                                             01895680
            END;                                                                01895690
            INX = INX - 1;                                                      01895700
         END; /* DO WHILE*/                                                     01895710
                                                                                01895720
         IF C_TRACE THEN DO;                                                    01895730
            OUTPUT = '########ERROR DETECTED IN FIX_LOOP_STACK '||STT#;         01895740
         END;                                                                   01895750
      END FIX_LOOP_STACK;                                                       01895760
                                                                                01895770
                                                                                01895780
      IF C_TRACE THEN OUTPUT = 'COMBINE_LOOPS:';                                01895790
                                                                                01895800
      IF AR_SIZE <= 1 THEN RETURN;                                              01895810
                                                                                01895820
      IF IN_VM THEN DIMS = 1;                                                   01895830
      ELSE DIMS = AR_DIMS;                                                      01895840
                                                                                01895850
      DO FOR TEMP = 1 TO DIMS;                                                  01895860
         OPR(LOOP_HEAD(1) + TEMP) =                                             01895870
            OPR(LOOP_HEAD + TEMP) | OPR(LOOP_HEAD(1) + TEMP);                   01895880
         OPR(LOOP_HEAD + TEMP) = 0;                                             01895890
      END;                                                                      01895900
                                                                                01895910
      OPR(LOOP_HEAD(1)) = OPR(LOOP_HEAD(1)) & ("FFFF FFF7" | OPR(LOOP_HEAD));   01895920
                                                                                01895930
 /* REMOVE VDLP TAG IF MIXED COMBINE*/                                          01895940
                                                                                01895950
      OPR(LOOP_END) = OPR(LOOP_END) & ("FFFF FFF7" | OPR(LOOP_END(1)));         01895960
                                                                                01895970
                                                                                01895980
      OPR(LOOP_END(1)) = 0;                                                     01895990
      OPR(LOOP_HEAD) =                                                          01896000
         OPR(LOOP_HEAD) & "FF 0000";    /* NOP*/                                01896010
      LOOP_END(1) = LOOP_END;                                                   01896020
                                                                                01896030
      COMBINE# = COMBINE# + 1;                                                  01896040
                                                                                01896050
      CALL FIX_LOOP_STACK;                                                      01896060
                                                                                01896070
      IF C_TRACE THEN DO;                                                       01896080
         CALL VU(LOOP_HEAD,AR_DIMS);                                            01896090
      END;                                                                      01896100
   END COMBINE_LOOPS;                                                           01896110
