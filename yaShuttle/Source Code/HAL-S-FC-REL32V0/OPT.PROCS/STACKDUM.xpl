 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   STACKDUM.xpl
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
 /* PROCEDURE NAME:  STACK_DUMP                                             */
 /* MEMBER NAME:     STACKDUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          REL_LIST          BIT(8)                                       */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BLOCK#                                                         */
 /*          COMM                                                           */
 /*          FOR                                                            */
 /*          INL#                                                           */
 /*          LEVEL                                                          */
 /*          LEVEL_STACK_VARS                                               */
 /*          LOOP_ZAPS_LEVEL                                                */
 /*          LOOP_ZAPS                                                      */
 /*          OBPS                                                           */
 /*          OLD_BLOCK#                                                     */
 /*          OLD_LEVEL                                                      */
 /*          PAR_SYM                                                        */
 /*          PULL_LOOP_HEAD                                                 */
 /*          REL                                                            */
 /*          STACK_TAGS                                                     */
 /*          STACKED_BLOCK#                                                 */
 /*          SYM_NAME                                                       */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          SYT_SIZE                                                       */
 /*          SYT_USED                                                       */
 /*          SYT_WORDS                                                      */
 /*          TRUE                                                           */
 /*          TSAPS                                                          */
 /*          VAL_ARRAY                                                      */
 /*          VAL_SIZE                                                       */
 /*          VAL_TABLE                                                      */
 /*          VALIDITY_ARRAY                                                 */
 /*          XPULL_LOOP_HEAD                                                */
 /*          XSTACK_TAGS                                                    */
 /*          XSTACKED_BLOCK#                                                */
 /*          XZAP_BASE                                                      */
 /*          ZAP_BASE                                                       */
 /*          ZAP_LEVEL                                                      */
 /*          ZAPS                                                           */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT                                                         */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          END_MULTICASE                                                  */
 /*          EXIT_CHECK                                                     */
 /*          OPTIMISE                                                       */
 /*          POP_STACK                                                      */
 /*          PUSH_STACK                                                     */
 /*          ZAP_TABLES                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> STACK_DUMP <==                                                      */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                00560010
 /* DUMPS FLOW OF CONTROL STACKS*/                                              00560020
STACK_DUMP:                                                                     00560030
   PROCEDURE;                                                                   00560040
      DECLARE K BIT(16);                                                        00560050
      DECLARE REL_LIST BIT(8);                                                  00560051
      OUTPUT = '';                                                              00560052
      IF ^REL_LIST THEN DO;                                                     00560053
         REL_LIST = TRUE;                                                       00560054
         OUTPUT = ' NO REL';                                                    00560055
         DO FOR K = 2 TO COMM(10);                                              00560056
            IF REL(K) > 1 THEN                                                  00560057
               OUTPUT = FORMAT(K,3) || FORMAT(REL(K),4) ||                      00560058
               '  ' || SYT_NAME(K);                                             00560059
         END;                                                                   00560060
      END;                                                                      00560061
      OUTPUT = 'STACK_DUMP:  LEVEL=' || LEVEL||                                 00560070
         ', BLOCK#=' ||BLOCK#||                                                 00560080
         ', INL#=' ||INL#||                                                     00560090
         ', OLD_LEVEL=' ||OLD_LEVEL||                                           00560100
         ', OLD_BLOCK#=' || OLD_BLOCK# ||                                       00560110
         ', VAL_SIZE=' || VAL_SIZE;                                             00560120
      OUTPUT = '';                                                              00560130
                                                                                00560140
      OUTPUT = '   LEVEL STACKED_BLOCK# STACK_TAGS PULL_LOOP_HEAD';             00560150
      DO FOR K = 0 TO LEVEL;                                                    00560160
         OUTPUT = FORMAT(K,8)||                                                 00560170
            FORMAT(STACKED_BLOCK#(K),15) ||                                     00560180
            '   '|| HEX(STACK_TAGS(K),8)||'      '||FORMAT(PULL_LOOP_HEAD(K),4);00560190
      END;                                                                      00560200
      OUTPUT = '';                                                              00560210
                                                                                00560220
      OUTPUT =                                                                  00560230
         'RECORD_TOP(CATALOG_ARRAY)= ' ||RECORD_TOP(PAR_SYM);                   00560240
      OUTPUT= 'RECORD_TOP(VALIDITY_ARRAY)= ' ||RECORD_TOP(VAL_TABLE);           00560250
      OUTPUT= 'RECORD_TOP(ZAPS)= ' ||RECORD_TOP(OBPS);                          00560260
      OUTPUT = '   ZAP_BASE=' || ZAP_BASE(LEVEL) ||                             00560300
         ', PULL_LOOP_HEAD(LEVEL)='  || PULL_LOOP_HEAD(LEVEL);                  00560310
      OUTPUT = '   SYT_SIZE=' ||SYT_SIZE||', SYT_WORDS='||SYT_WORDS||           00560320
         ', SYT_USED='||SYT_USED;                                               00560330
      OUTPUT = '';                                                              00560340
                                                                                00560350
      OUTPUT = '   VALIDITY     ZAPS LOOP_ZAPS';                                00560360
      DO FOR K = 0 TO SYT_WORDS;                                                00560370
         OUTPUT = '   ' || HEX(VALIDITY_ARRAY(K),8) ||                          00560380
            ' ' || HEX(ZAPS(K),8) || '  ' || HEX(LOOP_ZAPS(K),8);               00560390
      END;                                                                      00560400
   END STACK_DUMP;                                                              00560410
