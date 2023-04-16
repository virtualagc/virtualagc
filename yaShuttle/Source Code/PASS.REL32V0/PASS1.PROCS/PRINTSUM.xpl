 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSUM.xpl
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
 /* PROCEDURE NAME:  PRINT_SUMMARY                                          */
 /* MEMBER NAME:     PRINTSUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 FIXED                                        */
 /*          NO_DUMPS(1808)    LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK_SYTREF                                                   */
 /*          CARD_COUNT                                                     */
 /*          COMPILING                                                      */
 /*          CONTROL                                                        */
 /*          CROSS_REF                                                      */
 /*          CSECT_LENGTHS                                                  */
 /*          DOUBLE                                                         */
 /*          DOUBLE_SPACE                                                   */
 /*          DOWN_INFO                                                      */
 /*          EJECT_PAGE                                                     */
 /*          ERROR_COUNT                                                    */
 /*          INCLUDE_OPENED                                                 */
 /*          INIT_AFCBAREA                                                  */
 /*          INIT_APGAREA                                                   */
 /*          LINK_SORT                                                      */
 /*          LISTING2                                                       */
 /*          MACRO_TEXTS                                                    */
 /*          MAX_SEVERITY                                                   */
 /*          MEMORY_FAILURE                                                 */
 /*          OUTER_REF_TABLE                                                */
 /*          PAGE                                                           */
 /*          SDF_OPEN                                                       */
 /*          SDL_OPTION                                                     */
 /*          SYM_ADD                                                        */
 /*          SYM_LOCK#                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_LOCK#                                                      */
 /*          TPL_NAME                                                       */
 /*          VMEM_LOC_CNT                                                   */
 /*          VMEM_READ_CNT                                                  */
 /*          VMEM_WRITE_CNT                                                 */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CLOCK                                                          */
 /*          S                                                              */
 /*          STMT_PTR                                                       */
 /*          TPL_FLAG                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DUMPIT                                                         */
 /*          ERROR_SUMMARY                                                  */
 /*          LIT_DUMP                                                       */
 /*          OUTPUT_GROUP                                                   */
 /*          OUTPUT_WRITER                                                  */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          PRINT_TIME                                                     */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINT_SUMMARY <==                                                   */
 /*     ==> OUTPUT_GROUP                                                    */
 /*         ==> PRINT2                                                      */
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
 /*     ==> SYT_DUMP                                                        */
 /*         ==> PAD                                                         */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_CELL                                                    */
 /*         ==> BLANK                                                       */
 /*         ==> HEX                                                         */
 /*         ==> I_FORMAT                                                    */
 /*     ==> LIT_DUMP                                                        */
 /*         ==> GET_LITERAL                                                 */
 /*         ==> HEX                                                         */
 /*         ==> I_FORMAT                                                    */
 /*     ==> PRINT_TIME                                                      */
 /*         ==> CHARTIME                                                    */
 /*     ==> PRINT_DATE_AND_TIME                                             */
 /*         ==> CHARDATE                                                    */
 /*         ==> PRINT_TIME                                                  */
 /*             ==> CHARTIME                                                */
 /*     ==> DUMPIT                                                          */
 /*         ==> I_FORMAT                                                    */
 /*     ==> ERROR_SUMMARY                                                   */
 /***************************************************************************/
 /***********************************************************/                  00006000
 /*                                                         */                  00007000
 /*  REVISION HISTORY                                       */                  00008000
 /*                                                         */                  00009000
 /*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                  00009100
 /*                                                         */                  00009200
 /*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                  00009300
 /*  12/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM    */
 /*                               COMPILER                  */
 /*                                                         */                  00009400
 /***********************************************************/                  00009500
                                                                                01555800
PRINT_SUMMARY:                                                                  01555900
   PROCEDURE;                                                                   01556000
      DECLARE I FIXED;                                                          01556100
                                                                                01556200
      CALL OUTPUT_WRITER;                                                       01556210
      STMT_PTR = -1;  /* FORCE OUT ERRORS IN CASE OF TERMINATION IN MACRO */    01556220
      CALL OUTPUT_WRITER;                                                       01556300
      CALL OUTPUT_GROUP;                                                        01556400
      IF LISTING2 THEN                                                          01556500
         CALL MONITOR(0, 2); /* CLOSE LISTING2 */                               01556600
      IF INCLUDE_OPENED THEN                                                    01556700
         CALL MONITOR(3, 4);  /* CLOSE INCLUDE FILE */                          01556800
      IF SDF_OPEN THEN CALL MONITOR(22, 1);                                     01556850
      IF MEMORY_FAILURE THEN GO TO NO_DUMPS;                                    01556900
      EJECT_PAGE;                                                               01557000
      CALL SYT_DUMP;                                                            01557100
      IF RECORD_ALLOC(INIT_APGAREA) >0 THEN DO;                                 01557110
         RECORD_FREE(INIT_AFCBAREA);                                            01557120
         RECORD_FREE(INIT_APGAREA);                                             01557130
      END;                                                                      01557140
      RECORD_FREE(MACRO_TEXTS);                                                 01557170
      RECORD_FREE(LINK_SORT);                                                   01557180
      RECORD_FREE(OUTER_REF_TABLE);                                             01557190
      NEXT_ELEMENT(SYM_TAB);                                                    01557200
      RECORD_SEAL(SYM_TAB);                                                     01557210
 /* CR11088 11/90 RAH - DELETED TWO NEXT_ELEMENT(DOWN_INFO) MACROS */
      RECORD_SEAL(DOWN_INFO);                                                   01557213
      RECORD_SEAL(CROSS_REF);                                                   01557220
      RECORD_SEAL(SYM_ADD);                                                     01557230
      RECORD_SEAL(CSECT_LENGTHS);                                               01557240
      IF CONTROL(14) THEN CALL LIT_DUMP;                                        01557300
NO_DUMPS:                                                                       01557500
      EJECT_PAGE;                                                               01557600
      CALL DUMPIT;                                                              01557700
      CALL PRINT_DATE_AND_TIME('END OF HAL/S PHASE 1, ', DATE, TIME);           01557800
      OUTPUT = '';                                                              01557900
      OUTPUT = CARD_COUNT || ' CARDS WERE PROCESSED.';                          01558000
      IF ERROR_COUNT = 0 THEN                                                   01558100
         OUTPUT = 'NO ERRORS WERE DETECTED DURING PHASE 1 .';                   01558200
      ELSE DO;                                                                  01558300
         IF ERROR_COUNT=1 THEN S='ONE ERROR WAS';                               01558400
         ELSE S=ERROR_COUNT||' ERRORS WERE';                                    01558500
         OUTPUT=S||' DETECTED IN PHASE 1.';                                     01558600
         CALL ERROR_SUMMARY;                                                    01558700
      END;                                                                      01558800
      IF VMEM_LOC_CNT ^= 0 THEN DO;                                             01558810
         DOUBLE_SPACE;                                                          01558820
         OUTPUT = 'NUMBER OF FILE 6 LOCATES          = '||VMEM_LOC_CNT;         01558830
         OUTPUT = 'NUMBER OF FILE 6 READS            = '||VMEM_READ_CNT;        01558840
         OUTPUT = 'NUMBER OF FILE 6 WRITES           = '||VMEM_WRITE_CNT;       01558850
      END;                                                                      01558860
      DOUBLE_SPACE;                                                             01558900
      CLOCK(3)=MONITOR(18);                                                     01559000
      DO I = 1 TO 3;   /* WATCH OUT FOR MIDNIGHT */                             01559100
         IF CLOCK(I) < CLOCK(I-1) THEN CLOCK(I) = CLOCK(I) +  8640000;          01559200
      END;                                                                      01559300
      CALL PRINT_TIME('TOTAL CPU TIME FOR PHASE 1      ',CLOCK(3)-CLOCK(0));    01559400
      CALL PRINT_TIME('CPU TIME FOR PHASE 1 SET UP     ',CLOCK(1)-CLOCK(0));    01559500
      CALL PRINT_TIME('CPU TIME FOR PHASE 1 PROCESSING ',CLOCK(2)-CLOCK(1));    01559600
      CALL PRINT_TIME('CPU TIME FOR PHASE 1 CLEAN UP   ',CLOCK(3)-CLOCK(2));    01559700
      IF CLOCK(2) > CLOCK(1) THEN   /* WATCH OUT FOR CLOCK BEING OFF */         01559800
         OUTPUT = 'PROCESSING RATE: ' || 6000*CARD_COUNT/(CLOCK(2)-CLOCK(1))    01559900
         || ' CARDS PER MINUTE.';                                               01560000
      DOUBLE_SPACE;                                                             01560100
      IF TPL_FLAG<3 THEN IF (COMPILING&"80")=0|MAX_SEVERITY>0 THEN DO;          01560200
         TPL_FLAG=3;                                                            01560300
         OUTPUT='*******  COMPILATION ERRORS INHIBITED TEMPLATE GENERATION';    01560400
      END;                                                                      01560500
      IF TPL_FLAG = 3 THEN DO;                                                  01560600
         CALL MONITOR(0, 6);  /* CLOSE THE TEMPLATE FILE */                     01560610
         RETURN;  /* NO MORE TEMPLATE PROCESSING */                             01560620
      END;                                                                      01560630
      CALL MONITOR(16,"80");                                                    01560700
      IF ^TPL_FLAG THEN DO;                                                     01560800
         CALL MONITOR(1,6,TPL_NAME);                                            01560900
         CALL MONITOR(16,"40");                                                 01561000
      END;                                                                      01561100
      ELSE CALL MONITOR(0, 6);  /* CLOSE THE FILE ANYWAY */                     01561200
      DO CASE TPL_FLAG;                                                         01561300
         DO;                                                                    01561400
            S=' NOT FOUND - ADDED ';                                            01561500
         END;                                                                   01561600
         S=' FOUND - CHANGE NOT REQUIRED ';                                     01561700
         DO;                                                                    01561800
            S=' FOUND AND CHANGED ';                                            01561900
         END;                                                                   01562000
      END;                                                                      01562100
      IF ^SDL_OPTION THEN                                                       01562200
         S = S || ', VERSION=' || SYT_LOCK#(BLOCK_SYTREF(1));                   01562300
      OUTPUT='******* TEMPLATE LIBRARY MEMBER '||TPL_NAME||S;                   01562400
   END PRINT_SUMMARY;                                                           01562500
