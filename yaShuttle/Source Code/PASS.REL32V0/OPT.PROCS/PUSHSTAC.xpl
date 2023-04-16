 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PUSHSTAC.xpl
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
 /* PROCEDURE NAME:  PUSH_STACK                                             */
 /* MEMBER NAME:     PUSHSTAC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          INL#              BIT(16)                                      */
 /*          SAVE_TAGS         BIT(8)                                       */
 /*          LOOP              BIT(8)                                       */
 /*          SAVE_BLOCK#       BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          K                 BIT(16)                                      */
 /*          S1                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CAT_ARRAY                                                      */
 /*          FOR                                                            */
 /*          PULL_LOOP_HEAD                                                 */
 /*          STACK_INL#                                                     */
 /*          STACK_TAGS                                                     */
 /*          STACK_TRACE                                                    */
 /*          STACKED_BLOCK#                                                 */
 /*          STT#                                                           */
 /*          SYT_SIZE                                                       */
 /*          TRACE                                                          */
 /*          VAL_ARRAY                                                      */
 /*          VAL_SIZE                                                       */
 /*          XPULL_LOOP_HEAD                                                */
 /*          XSTACK_INL#                                                    */
 /*          XSTACK_TAGS                                                    */
 /*          XSTACKED_BLOCK#                                                */
 /*          XZAP_BASE                                                      */
 /*          ZAP_BASE                                                       */
 /*          ZAP_LEVEL                                                      */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BLOCK#                                                         */
 /*          LEVEL                                                          */
 /*          LEVEL_STACK_VARS                                               */
 /*          LOOP_ZAPS_LEVEL                                                */
 /*          PAR_SYM                                                        */
 /*          VAL_TABLE                                                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          STACK_DUMP                                                     */
 /*          BUMP_BLOCK                                                     */
 /* CALLED BY:                                                              */
 /*          CHICKEN_OUT                                                    */
 /*          EXIT_CHECK                                                     */
 /*          OPTIMISE                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PUSH_STACK <==                                                      */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> FORMAT                                                      */
 /*         ==> HEX                                                         */
 /*     ==> BUMP_BLOCK                                                      */
 /***************************************************************************/
                                                                                02206650
 /* PUSHES CONTROL STACKS*/                                                     02206660
PUSH_STACK:                                                                     02206670
   PROCEDURE(INL#,SAVE_TAGS,LOOP,SAVE_BLOCK#);                                  02206680
      DECLARE LOOP BIT(8);                                                      02206690
      DECLARE (INL#,K,S1) BIT(16),                                              02206700
         SAVE_BLOCK# BIT(8),                                                    02206710
         SAVE_TAGS BIT(8);                                                      02206720
      IF STACK_TRACE THEN OUTPUT =                                              02206730
         'PUSH_STACK(' || INL# || ',' || SAVE_TAGS || '):  ' || STT#;           02206740
      S1 = SYT_SIZE + 1;                                                        02206750
      DO WHILE LEVEL >= RECORD_TOP(PAR_SYM);                                    02206760
         NEXT_ELEMENT(PAR_SYM);                                                 02206761
         NEXT_ELEMENT(VAL_TABLE);                                               02206762
         NEXT_ELEMENT(LEVEL_STACK_VARS);                                        02206763
         PULL_LOOP_HEAD(RECORD_TOP(LEVEL_STACK_VARS)) = -1;                     02206764
      END;                                                                      02206765
      DO FOR K = 0 TO SYT_SIZE;                                                 02206766
         PAR_SYM(LEVEL+1).CAT_ARRAY(K) = PAR_SYM(LEVEL).CAT_ARRAY(K);           02206767
      END;                                                                      02206768
      DO FOR K = 0 TO VAL_SIZE - 1;                                             02206769
         VAL_TABLE(LEVEL+1).VAL_ARRAY(K) = VAL_TABLE(LEVEL).VAL_ARRAY(K);       02206770
      END;                                                                      02206771
                                                                                02206930
      IF ^SAVE_BLOCK# THEN BLOCK# = BUMP_BLOCK;                                 02206940
      LEVEL = LEVEL + 1;                                                        02206950
      STACKED_BLOCK#(LEVEL) = BLOCK#;                                           02206960
      IF SAVE_TAGS THEN SAVE_TAGS = 0;                                          02206970
      ELSE STACK_TAGS(LEVEL) = STACK_TAGS(LEVEL - 1) & "4";/* KEEP IN LOOP TAG*/02206980
      IF LOOP THEN ZAP_BASE(LEVEL),LOOP_ZAPS_LEVEL=ZAP_LEVEL;                   02206990
      ELSE ZAP_BASE(LEVEL) = ZAP_BASE(LEVEL - 1);                               02207010
      PULL_LOOP_HEAD(LEVEL) = PULL_LOOP_HEAD(LEVEL - 1);                        02207020
      STACK_INL#(LEVEL) = INL#;                                                 02207030
      LOOP,INL#,SAVE_BLOCK# = 0;                                                02207040
      IF TRACE THEN CALL STACK_DUMP;                                            02207050
   END PUSH_STACK;                                                              02207060
