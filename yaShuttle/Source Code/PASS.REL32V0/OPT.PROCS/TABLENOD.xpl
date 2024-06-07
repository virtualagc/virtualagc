 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TABLENOD.xpl
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
 /* PROCEDURE NAME:  TABLE_NODE                                             */
 /* MEMBER NAME:     TABLENOD                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CAT_PTR           BIT(16)                                      */
 /*          ENTER             LABEL                                        */
 /*          SEARCH_INX        BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          BLOCK#                                                         */
 /*          CATALOG_ENTRY_SIZE                                             */
 /*          CSE_INX                                                        */
 /*          END_OF_NODE                                                    */
 /*          FALSE                                                          */
 /*          FOR                                                            */
 /*          LEVEL                                                          */
 /*          NODE_BEGINNING                                                 */
 /*          NODE_ENTRY_SIZE                                                */
 /*          NODE2                                                          */
 /*          NONCOMMUTATIVE                                                 */
 /*          OLD_BLOCK#                                                     */
 /*          OLD_LEVEL                                                      */
 /*          TOTAL_MATCH_PRES                                               */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE_TAB                                                        */
 /*          INVARIANT_PULLED                                               */
 /*          NODE                                                           */
 /*          NODE_SIZE                                                      */
 /*          SEARCH                                                         */
 /*          SEARCH2                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_SRCH                                                   */
 /*          CATALOG_ENTRY                                                  */
 /*          GET_FREE_SPACE                                                 */
 /*          TYPE                                                           */
 /* CALLED BY:                                                              */
 /*          GET_NODE                                                       */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> TABLE_NODE <==                                                      */
 /*     ==> GET_FREE_SPACE                                                  */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*     ==> TYPE                                                            */
 /*     ==> CATALOG_SRCH                                                    */
 /*     ==> CATALOG_ENTRY                                                   */
 /*         ==> GET_EON                                                     */
 /*         ==> GET_FREE_SPACE                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /*                                                                         */
 /* DATE     WHO  RLS        DESCRIPTION                                    */
 /* 11/21/95 JMP  27V1/11V1  DR109029 FIX CSE TABLE CORRUPTION CAUSED BY    */
 /*                          STRUCTURE-COPY IN IF CONDITION                 */
 /*                                                                         */
 /* 01/29/05 TKN  32V0/      DR120263  INFINITE LOOP FOR ARRAYED CONDITIONAL*/
 /*               17V0                                                      */
 /***************************************************************************/
                                                                                02227280
                                                                                02227290
 /* PUTS NODES INTO CSE_TAB */                                                  02229000
TABLE_NODE:                                                                     02230000
   PROCEDURE;                                                                   02231000
      DECLARE (CAT_PTR,TEMP) BIT(16);                                           02232000
      DECLARE SEARCH_INX BIT(16);                                               02233000
      IF TRACE THEN OUTPUT = 'TABLE_NODE';                                      02234000
                                                                                02234010
      IF ARRAYED_CONDITIONAL THEN RETURN;   /*DR120263*/
      IF TOTAL_MATCH_PRES AND INVARIANT_PULLED THEN DO; /*DR120263,DR109029 */
         NODE_SIZE = 0;                                                         02234030
         TEMP = 1;                                                              02234040
         NODE = NODE(NODE_BEGINNING - TEMP);                                    02234050
         DO WHILE NODE ^= END_OF_NODE;                                          02234060
            IF TYPE(NODE) > 5 THEN DO;                                          02234070
               NODE_SIZE = NODE_SIZE + 1;                                       02234080
               SEARCH(NODE_SIZE) = NODE;                                        02234090
               SEARCH2(NODE_SIZE) = NODE2(NODE_BEGINNING - TEMP);               02234100
            END;                                                                02234110
            TEMP = TEMP + 1;                                                    02234120
            NODE = NODE(NODE_BEGINNING - TEMP);                                 02234130
         END;                                                                   02234140
      END;                                                                      02234150
                                                                                02234160
 /* THIS IS TO ALLOW MORE CSE'S WITH INVARIANTS PULLED FROM LOOPS*/             02234170
                                                                                02234180
      DO FOR SEARCH_INX = 1 TO NODE_SIZE;                                       02235000
         SEARCH = SEARCH(SEARCH_INX);                                           02236000
         IF SEARCH ^= 0 THEN DO CASE TYPE(SEARCH);                              02237000
            ;;;;;                                                               02237010
               ;                                                                02238000
            ;        /*6 = IMMEDIATE */                                         02239000
            ;;;;DO;  /*B = VALUE_NO*/                                           02240000
                  CAT_PTR = CATALOG_SRCH(SEARCH);                               02241000
                  IF CAT_PTR ^= 0 THEN DO;                       /* DR109029 */
ENTER:              IF CSE_TAB(CSE_INX) ^= NODE_BEGINNING THEN DO;              02242000
                      /* PREVENT DOUBLE TABLING*/                               02243000
                      CSE_TAB(CAT_PTR),TEMP = GET_FREE_SPACE(NODE_ENTRY_SIZE);  02244000
                      CSE_TAB(TEMP) = NODE_BEGINNING;                           02245000
                      CSE_TAB(TEMP+1) = CSE_INX;                                02246000
                      IF TOTAL_MATCH_PRES AND INVARIANT_PULLED THEN             02247000
                         CSE_TAB(TEMP + 2) = SHL(OLD_LEVEL,11) | OLD_BLOCK#;    02247010
                      ELSE CSE_TAB(TEMP + 2) = SHL(LEVEL,11) | BLOCK#;          02247020
                      END;                                                      02247030
                    ELSE DO;                                                    02247040
                      IF TRACE THEN OUTPUT = '   CSE_INX=' || CSE_INX ||        02247050
                         ', TMP=' || TOTAL_MATCH_PRES|| ', IP=' ||              02247060
                         INVARIANT_PULLED || ', OB#=' || OLD_BLOCK#;            02247070
                         IF TOTAL_MATCH_PRES AND INVARIANT_PULLED THEN          02247080
                         CSE_TAB(CSE_INX + 2) = SHL(OLD_LEVEL,11) | OLD_BLOCK#; 02247090
                    END;                                                        02247100
                  END;                                           /* DR109029 */
               IF NONCOMMUTATIVE THEN RETURN;                                   02248000
            END;     /*VALUE_NO*/                                               02249000
            DO;      /*OUTER_TERMINAL_VAC*/                                     02250000
               CAT_PTR = CATALOG_SRCH(SEARCH2(SEARCH_INX));                     02251000
               IF CAT_PTR = 0 THEN DO;    /* NEW OP*/                           02252000
                  TEMP = GET_FREE_SPACE(CATALOG_ENTRY_SIZE);                    02253000
                  CSE_TAB(CSE_INX + 2) = TEMP;                                  02254000
                  CALL CATALOG_ENTRY(TEMP,NODE_BEGINNING);                      02255000
                  CSE_INX = CSE_TAB(TEMP);                       /* DR109029 */
               END;                                                             02256000
               GO TO ENTER;                                                     02257000
            END;     /* OUTER_TERMINAL_VAC*/                                    02258000
                                                                                02259000
            ;   /* DON'T TABLE LITERALS */ ;;                                   02260000
            END; /*DO CASE*/                                                    02261000
      END;                                                                      02262000
      INVARIANT_PULLED = FALSE;                                                 02262010
   END TABLE_NODE;                                                              02263000
