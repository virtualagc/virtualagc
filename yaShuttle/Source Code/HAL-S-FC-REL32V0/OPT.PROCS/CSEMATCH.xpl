 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CSEMATCH.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  CSE_MATCH_FOUND                                        */
 /* MEMBER NAME:     CSEMATCH                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          COMPARE           LABEL                                        */
 /*          LAST              FIXED                                        */
 /*          MATCH             FIXED                                        */
 /*          MATCH_INX         BIT(16)                                      */
 /*          N_INX             BIT(16)                                      */
 /*          OPCODE            BIT(16)                                      */
 /*          PRESENT_ADLP      BIT(16)                                      */
 /*          PREVIOUS_ADLP     BIT(16)                                      */
 /*          SRCH              FIXED                                        */
 /*          SRCH_INX          BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ARRAYED_TSUB                                                   */
 /*          BIT_TYPE                                                       */
 /*          CLASS_ZO                                                       */
 /*          CSE_TAB                                                        */
 /*          END_OF_NODE                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LEVEL_STACK_VARS                                               */
 /*          LITERAL                                                        */
 /*          NODE                                                           */
 /*          NODE_BEGINNING                                                 */
 /*          NODE2                                                          */
 /*          NONCOMMUTATIVE                                                 */
 /*          PARITY_MASK                                                    */
 /*          PRESENT_NODE_PTR                                               */
 /*          REVERSE_OP                                                     */
 /*          SEARCH_INX                                                     */
 /*          SEARCH_REV                                                     */
 /*          SEARCH2_REV                                                    */
 /*          STACKED_BLOCK#                                                 */
 /*          STT#                                                           */
 /*          TRACE                                                          */
 /*          TRUE                                                           */
 /*          TWIN_OP                                                        */
 /*          XSTACKED_BLOCK#                                                */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          COMPARE_CALLS                                                  */
 /*          CSE_INX                                                        */
 /*          CSE                                                            */
 /*          CSE_FOUND_INX                                                  */
 /*          CSE2                                                           */
 /*          OLD_BLOCK#                                                     */
 /*          OLD_LEVEL                                                      */
 /*          OPTYPE                                                         */
 /*          PREVIOUS_HALMAT                                                */
 /*          PREVIOUS_NODE_OPERAND                                          */
 /*          PREVIOUS_NODE_PTR                                              */
 /*          PREVIOUS_NODE                                                  */
 /*          REVERSE                                                        */
 /*          SCANS                                                          */
 /*          SEARCH                                                         */
 /*          SEARCH2                                                        */
 /*          TWIN_MATCH                                                     */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_SRCH                                                   */
 /*          COMPARE_LITERALS                                               */
 /*          CSE_WORD_FORMAT                                                */
 /*          ERRORS                                                         */
 /*          GET_ADLP                                                       */
 /*          SETUP_REVERSE_COMPARE                                          */
 /*          TYPE                                                           */
 /* CALLED BY:                                                              */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CSE_MATCH_FOUND <==                                                 */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> COMPARE_LITERALS                                                */
 /*         ==> HEX                                                         */
 /*         ==> GET_LITERAL                                                 */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /*     ==> TYPE                                                            */
 /*     ==> GET_ADLP                                                        */
 /*         ==> OPOP                                                        */
 /*         ==> LAST_OP                                                     */
 /*     ==> CATALOG_SRCH                                                    */
 /*     ==> SETUP_REVERSE_COMPARE                                           */
 /*         ==> CSE_WORD_FORMAT                                             */
 /*             ==> HEX                                                     */
 /*         ==> CONTROL                                                     */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /***************************************************************************/
                                                                                03795000
 /* CHECKS NODE FOR COMMON SUBEXPRESSION */                                     03796000
CSE_MATCH_FOUND:                                                                03797000
   PROCEDURE BIT(8);                                                            03798000
      DECLARE (N_INX, SRCH_INX) BIT (16),                                       03799000
         (MATCH,LAST,SRCH) FIXED,                                               03801000
         (PREVIOUS_ADLP,PRESENT_ADLP) BIT(16),                                  03801100
         MATCH_INX BIT(16),                                                     03802000
         (I,OPCODE) BIT(16);                                                    03804000
                                                                                03805000
COMPARE:                                                                        03806000
      PROCEDURE;                                                                03807000
         DECLARE PTR BIT(16);                                                   03808000
         LAST = 0;                                                              03809000
         COMPARE_CALLS = COMPARE_CALLS + 1;                                     03810000
         DO FOR SRCH_INX = 1 TO SEARCH_INX - 1 - (NONCOMMUTATIVE=FALSE);        03811000
            IF REVERSE THEN SRCH = SEARCH_REV(SRCH_INX);                        03812000
            ELSE SRCH = SEARCH(SRCH_INX);                                       03813000
            IF SRCH ^= LAST THEN DO CASE TYPE(SRCH) ;                           03814000
               ;;;;;                                                            03814010
                  ;                                                             03815000
               DO;          /*6 = IMMEDIATE  */                                 03816000
               END;                                                             03817000
               ;;;;DO;      /*B = VALUE_NO */                                   03818000
                     PTR = SRCH & "FFFF";                                       03819000
                                                                                03820000
                                                                                03821000
SCAN:                                                                           03822000
                  IF CATALOG_SRCH(PTR) = 0 THEN RETURN FALSE;                   03823000
DO_WHILE:                                                                       03824000
                  DO WHILE CSE_INX ^= 0;                                        03825000
                     PREVIOUS_NODE_OPERAND,N_INX = CSE_TAB(CSE_INX) - 1;        03826000
 /* POINTS TO FIRST OPERAND OF NODE*/                                           03827000
                     IF ARRAYED_TSUB THEN DO;                                   03827100
                        PREVIOUS_ADLP = GET_ADLP(N_INX,1);                      03827200
                        IF PREVIOUS_ADLP ^= PRESENT_ADLP THEN DO;               03827300
                           CSE_INX = CSE_TAB(CSE_INX + 1);                      03827400
                           REPEAT DO_WHILE;                                     03827500
                        END;                                                    03827600
                     END;                                                       03827700
                     PREVIOUS_NODE = N_INX + 1;                                 03828000
                                                                                03828010
                     OLD_BLOCK# = CSE_TAB(CSE_INX + 2);                         03828020
                     OLD_LEVEL = SHR(OLD_BLOCK#,11);                            03828030
                     OLD_BLOCK# = OLD_BLOCK# & "7FF";                           03828040
                                                                                03828050
                     IF STACKED_BLOCK#(OLD_LEVEL) = OLD_BLOCK# THEN             03828060
 /* NOT UNSTACKED*/                                                             03828070
                        IF PREVIOUS_NODE ^= NODE_BEGINNING THEN                 03829000
                        IF NODE(PREVIOUS_NODE) ^= 0 THEN DO; /* DON'T SCAN ZERO 03829002
                              OPTYPE*/                                          03829004
                                                                                03829010
                        SCANS = SCANS + 1;                                      03830000
                        IF NONCOMMUTATIVE THEN MATCH_INX = 1;                   03831000
                        ELSE MATCH_INX = SRCH_INX;                              03832000
                        MATCH = 0;                                              03833000
                        CSE_FOUND_INX = 0;                                      03834000
                        DO WHILE MATCH ^= END_OF_NODE;                          03835000
                           IF REVERSE THEN DO;                                  03836000
                              SEARCH = SEARCH_REV(MATCH_INX);                   03837000
                              SEARCH2 = SEARCH2_REV(MATCH_INX);                 03838000
                           END;                                                 03839000
                           ELSE DO;                                             03840000
                              SEARCH = SEARCH(MATCH_INX);                       03841000
                              SEARCH2 = SEARCH2(MATCH_INX);                     03842000
                           END;                                                 03843000
                           IF NODE(N_INX) < SEARCH THEN N_INX = N_INX -1;       03844000
                           ELSE IF SEARCH < NODE(N_INX)                         03845000
                              THEN MATCH_INX = MATCH_INX + 1;                   03846000
                           ELSE IF NODE(N_INX) = 0 THEN DO;                     03847000
                              MATCH_INX = MATCH_INX + 1;                        03848000
                              N_INX = N_INX -1;                                 03849000
                           END;                                                 03850000
                           ELSE DO;   /* MATCHED CSE WORD*/                     03851000
                              MATCH = NODE(N_INX);                              03852000
                                                                                03853000
                              IF (MATCH & PARITY_MASK) = LITERAL THEN DO;       03853010
                                 IF COMPARE_LITERALS(NODE2(N_INX),SEARCH2)      03853020
                                    THEN GO TO BUMP;                            03853030
                                 ELSE IF NODE2(N_INX) < SEARCH2 THEN            03853040
                                    N_INX = N_INX - 1;                          03853050
                                 ELSE MATCH_INX = MATCH_INX + 1;                03853060
                              END;                                              03853070
                              ELSE DO;                                          03853080
BUMP:                            CSE_FOUND_INX = CSE_FOUND_INX + 1;             03853090
                                 CSE(CSE_FOUND_INX) = MATCH;                    03853100
                                 CSE2(CSE_FOUND_INX) = NODE2(N_INX);            03853110
                                 N_INX = N_INX - 1;                             03853120
                                 MATCH_INX = MATCH_INX + 1;                     03853130
                              END;                                              03853140
                           END;                                                 03853150
                        END; /* DO WHILE MATCH*/                                03853160
                        IF CSE_FOUND_INX > 2 & ^NONCOMMUTATIVE                  03853170
                          | CSE_FOUND_INX = SEARCH_INX & NONCOMMUTATIVE THEN DO;03853180
                           PREVIOUS_NODE_PTR = N_INX;                           03874000
 /* POINTS TO "PTR_TO_VAC" NODE WORD OF MATCH*/                                 03875000
                           PREVIOUS_HALMAT = NODE(N_INX) & "FFFF";              03876000
 /* POINTS TO HALMAT OPERATOR OF PREVIOUS MATCH*/                               03877000
                           IF TRACE THEN DO;                                    03878000
                              OUTPUT = '';                                      03879000
                              OUTPUT = '    MATCHES';                           03880000
                              DO FOR I = 1 TO CSE_FOUND_INX;                    03881000
                                 OUTPUT = CSE_WORD_FORMAT(CSE(I)) || '   ' ||   03882000
                                    CSE2(I);                                    03883000
                              END;                                              03884000
                              IF REVERSE THEN OUTPUT = '   REVERSE';            03885000
                           END;                                                 03886000
                           RETURN TRUE;                                         03887000
                        END;                                                    03888000
                     END;    /* PREVIOUS_NODE ^= NODE_BEG*/                     03889000
                     CSE_INX = CSE_TAB(CSE_INX + 1);                            03890000
                  END;  /* DO WHILE CSE_INX */                                  03891000
               IF NONCOMMUTATIVE THEN RETURN FALSE;  /* ONLY SEARCH FIRST TABLED03892000
                           ENTRY'S NODES*/                                      03893000
               END;   /*VALUE_NO */                                             03894000
                                                                                03895000
                                                                                03896000
               DO;    /* C = OUTER_TERMINAL_VAC   */                            03897000
                  IF REVERSE THEN PTR = SEARCH2_REV(SRCH_INX);                  03898000
                  ELSE PTR = SEARCH2(SRCH_INX);                                 03899000
                  GO TO SCAN;                                                   03900000
               END;;  /* LITERAL NOT IN CSE_TAB*/ ;;                            03901000
               END; /* DO CASE*/                                                03902000
            LAST = SRCH;                                                        03903000
         END;   /* DO FOR SRCH_INX*/                                            03904000
         RETURN FALSE;                                                          03905000
      END COMPARE;                                                              03906000
                                                                                03907000
      IF ARRAYED_TSUB THEN                                                      03907100
         PRESENT_ADLP = GET_ADLP(NODE(PRESENT_NODE_PTR) & "FFFF");              03907200
      TWIN_MATCH, REVERSE = 0;                                                  03908000
      IF COMPARE THEN RETURN TRUE;                                              03909000
                                                                                03910000
      IF TWIN_OP THEN DO;                                                       03911000
         OPTYPE, OPCODE = REVERSE_OP;                                           03912000
         IF COMPARE THEN DO;                                                    03913000
            TWIN_MATCH = TRUE;                                                  03914000
            RETURN TRUE;                                                        03915000
         END;                                                                   03916000
                                                                                03916343
 /*   ***** SIN COS TRAP    */                                                  03916353
         CALL ERRORS (CLASS_ZO,1,' '||STT#);                                    03916363
                                                                                03916373
         OPTYPE = OPCODE;                                                       03917000
         RETURN FALSE;                                                          03917010
      END;                                                                      03918000
                                                                                03919000
      IF NONCOMMUTATIVE | BIT_TYPE THEN RETURN FALSE;                           03920000
      REVERSE = 1;                                                              03921000
      IF SETUP_REVERSE_COMPARE THEN                                             03922000
         IF COMPARE THEN RETURN TRUE;                                           03923000
      RETURN FALSE;                                                             03924000
   END CSE_MATCH_FOUND;                                                         03925000
