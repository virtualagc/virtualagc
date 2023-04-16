 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   BUILDSDF.xpl
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
 /* PROCEDURE NAME:  BUILD_SDF_LITTAB                                       */
 /* MEMBER NAME:     BUILDSDF                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CHAR_ADR(1)       MACRO                                        */
 /*          CHAR_LEN(1)       MACRO                                        */
 /*          CHAR_TYPE(1)      MACRO                                        */
 /*          CHARS_LEFT        BIT(16)                                      */
 /*          DIR_NODE          FIXED                                        */
 /*          EXTN_INDEX        BIT(16)                                      */
 /*          EXTN_NODE         FIXED                                        */
 /*          I                 BIT(16)                                      */
 /*          INDEX             BIT(16)                                      */
 /*          LIT_EXTN_PTR      MACRO                                        */
 /*          LIT_EXTN_SZ       MACRO                                        */
 /*          LIT_EXTN_TAB      FIXED                                        */
 /*          LIT_TAB           FIXED                                        */
 /*          LIT_TAB_INDEX     BIT(16)                                      */
 /*          LITBLK_SZ         MACRO                                        */
 /*          LITCHR_INDEX      BIT(16)                                      */
 /*          LITCHR_SZ         MACRO                                        */
 /*          LITCHR_TAB        FIXED                                        */
 /*          NEW_ADR(1)        MACRO                                        */
 /*          NODE_B            BIT(8)                                       */
 /*          NODE_F            FIXED                                        */
 /*          SDF_CHAR_LIT      LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          LIT_CHAR_USED                                                  */
 /*          LIT_PG                                                         */
 /*          LIT_TOP                                                        */
 /*          LITERAL1                                                       */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT1                                                           */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /*          MODF                                                           */
 /*          PAGE_SIZE                                                      */
 /*          RELS                                                           */
 /*          RESV                                                           */
 /*          ROOT_PTR                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          GET_LITERAL                                                    */
 /*          GET_DATA_CELL                                                  */
 /*          MIN                                                            */
 /*          MOVE                                                           */
 /*          P3_LOCATE                                                      */
 /*          P3_PTR_LOCATE                                                  */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> BUILD_SDF_LITTAB <==                                                */
 /*     ==> GET_LITERAL                                                     */
 /*     ==> MIN                                                             */
 /*     ==> MOVE                                                            */
 /*     ==> P3_PTR_LOCATE                                                   */
 /*         ==> HEX8                                                        */
 /*         ==> ZERO_CORE                                                   */
 /*         ==> P3_DISP                                                     */
 /*         ==> PAGING_STRATEGY                                             */
 /*     ==> P3_LOCATE                                                       */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /*     ==> GET_DATA_CELL                                                   */
 /*         ==> P3_GET_CELL                                                 */
 /*             ==> P3_DISP                                                 */
 /*             ==> P3_LOCATE                                               */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /*             ==> PUTN                                                    */
 /*                 ==> MOVE                                                */
 /*                 ==> P3_PTR_LOCATE                                       */
 /*                     ==> HEX8                                            */
 /*                     ==> ZERO_CORE                                       */
 /*                     ==> P3_DISP                                         */
 /*                     ==> PAGING_STRATEGY                                 */
 /***************************************************************************/
BUILD_SDF_LITTAB:                                                               00207810
   PROCEDURE;                                                                   00207820
      BASED (NODE_F,EXTN_NODE,DIR_NODE) FIXED;                                  00207830
      BASED NODE_B BIT(8);                                                      00207840
      DECLARE (LIT_TAB,LITCHR_TAB,LIT_EXTN_TAB) FIXED,                          00207850
         LITCHR_INDEX BIT(16) INITIAL(0),                                       00207860
         EXTN_INDEX BIT(16) INITIAL(0),                                         00207870
         (I,INDEX,LIT_TAB_INDEX,CHARS_LEFT) BIT(16);                            00207880
      DECLARE LITBLK_SZ LITERALLY 'MIN((LIT_TOP-I+1)*12,PAGE_SIZE)',            00207890
         LITCHR_SZ LITERALLY 'MIN(CHARS_LEFT+1,PAGE_SIZE)',                     00207900
         LIT_EXTN_SZ LITERALLY '(((LIT_TOP+1)*3/420)+1)*4',                     00207910
         CHAR_LEN(1) LITERALLY '(SHR(LIT2(%1%),24)&"FF")',                      00207920
         CHAR_ADR(1) LITERALLY '(LIT2(%1%)&"FFFFFF")',                          00207930
         NEW_ADR(1) LITERALLY 'ADDR(NODE_B(%1%))',                              00207940
         CHAR_TYPE(1) LITERALLY '(LIT1(%1%)=0)',                                00207950
         LIT_EXTN_PTR LITERALLY '43';                                           00207960
                                                                                00207970
SDF_CHAR_LIT:                                                                   00207980
      PROCEDURE;                                                                00207990
         DECLARE (I,OFFSET) BIT(16);                                            00208000
         IF LITCHR_INDEX + CHAR_LEN(INDEX) > PAGE_SIZE                          00208010
            THEN DO;                                                            00208020
            CALL P3_PTR_LOCATE(LITCHR_TAB,RELS);                                00208030
            LITCHR_TAB = GET_DATA_CELL(LITCHR_SZ,ADDR(NODE_B),RESV|MODF);       00208040
            LITCHR_INDEX = 0;                                                   00208050
         END;                                                                   00208060
         OFFSET = LITCHR_INDEX;                                                 00208070
         CALL MOVE(CHAR_LEN(INDEX)+1,CHAR_ADR(INDEX),NEW_ADR(LITCHR_INDEX));    00208080
         LITCHR_INDEX = LITCHR_INDEX+CHAR_LEN(INDEX) + 1;                       00208090
         CHARS_LEFT = CHARS_LEFT-(CHAR_LEN(INDEX)+1);                           00208100
         NODE_F(LIT_TAB_INDEX+1) = LITCHR_TAB+OFFSET;                           00208110
         NODE_F(LIT_TAB_INDEX+2) = CHAR_LEN(INDEX);                             00208120
      END SDF_CHAR_LIT;                                                         00208130
                                                                                00208140
      CHARS_LEFT = LIT_CHAR_USED;                                               00208150
      LITCHR_TAB = GET_DATA_CELL(LITCHR_SZ,ADDR(NODE_B),RESV|MODF);             00208160
      LIT_TAB = GET_DATA_CELL(LITBLK_SZ,ADDR(NODE_F),RESV|MODF);                00208170
      LIT_EXTN_TAB = GET_DATA_CELL(LIT_EXTN_SZ,ADDR(EXTN_NODE),MODF);           00208180
      EXTN_NODE(EXTN_INDEX) = LIT_TAB;                                          00208190
      EXTN_INDEX = EXTN_INDEX + 1;                                              00208200
      CALL P3_LOCATE(ROOT_PTR,ADDR(DIR_NODE),MODF);                             00208210
      DIR_NODE(LIT_EXTN_PTR) = LIT_EXTN_TAB;                                    00208220
      DIR_NODE(LIT_EXTN_PTR+1) = (LIT_EXTN_SZ)/4;                               00208225
      NODE_F(0),NODE_F(1),NODE_F(2) = 0;  /* NULL CHARACTER CELL */             00208230
      LIT_TAB_INDEX = 3;  /* NEXT LITERAL ENTRY */                              00208240
      DO I = 1 TO LIT_TOP;                                                      00208250
         IF LIT_TAB_INDEX >= PAGE_SIZE/4                                        00208260
            THEN DO;   /* NEED ANOTHER SDF PAGE */                              00208270
            CALL P3_PTR_LOCATE(LIT_TAB,RELS);                                   00208280
            LIT_TAB = GET_DATA_CELL(LITBLK_SZ,ADDR(NODE_F),RESV|MODF);          00208290
            LIT_TAB_INDEX = 0;                                                  00208300
            CALL P3_LOCATE(LIT_EXTN_TAB,ADDR(EXTN_NODE),MODF);                  00208310
            EXTN_NODE(EXTN_INDEX) = LIT_TAB;                                    00208320
            EXTN_INDEX = EXTN_INDEX + 1;                                        00208330
         END;                                                                   00208340
         INDEX = GET_LITERAL(I);                                                00208350
         NODE_F(LIT_TAB_INDEX) = LIT1(INDEX);                                   00208360
         IF CHAR_TYPE(INDEX)                                                    00208370
            THEN CALL SDF_CHAR_LIT;                                             00208380
         ELSE DO;                                                               00208390
            NODE_F(LIT_TAB_INDEX+1) = LIT2(INDEX);                              00208400
            NODE_F(LIT_TAB_INDEX+2) = LIT3(INDEX);                              00208410
         END;                                                                   00208420
         LIT_TAB_INDEX = LIT_TAB_INDEX+3;                                       00208430
      END;  /* FOR LOOP */                                                      00208440
      CALL P3_PTR_LOCATE(LIT_TAB,RELS);                                         00208450
      CALL P3_PTR_LOCATE(LITCHR_TAB,RELS);                                      00208460
   END BUILD_SDF_LITTAB;                                                        00208470
