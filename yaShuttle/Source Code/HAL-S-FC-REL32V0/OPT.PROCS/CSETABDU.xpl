 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CSETABDU.xpl
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
 /* PROCEDURE NAME:  CSE_TAB_DUMP                                           */
 /* MEMBER NAME:     CSETABDU                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MSG               CHARACTER;                                   */
 /*          T                 BIT(16)                                      */
 /*          TEMP              BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          CSE_TAB                                                        */
 /*          CSE_TAB_DUMP2                                                  */
 /*          END_OF_LIST                                                    */
 /*          FOR                                                            */
 /*          FREE_BLOCK_BEGIN                                               */
 /*          LAST_SPACE_BLOCK                                               */
 /*          N_INX                                                          */
 /*          NODE                                                           */
 /*          NODE_DUMP                                                      */
 /*          NODE2                                                          */
 /*          SYM_NAME                                                       */
 /*          SYM_TAB                                                        */
 /*          SYT_NAME                                                       */
 /*          SYT_USED                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CATALOG_PTR                                                    */
 /*          CSE_WORD_FORMAT                                                */
 /*          FORMAT                                                         */
 /*          HEX                                                            */
 /*          VALIDITY                                                       */
 /* CALLED BY:                                                              */
 /*          GROW_TREE                                                      */
 /*          STRIP_NODES                                                    */
 /*          ZAP_TABLES                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CSE_TAB_DUMP <==                                                    */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /*     ==> CATALOG_PTR                                                     */
 /*     ==> VALIDITY                                                        */
 /*     ==> CSE_WORD_FORMAT                                                 */
 /*         ==> HEX                                                         */
 /***************************************************************************/
                                                                                01425170
 /* PRINTS CSE TABLES, CATALOG_PTR, AND WIPEOUT# */                             01426000
CSE_TAB_DUMP:                                                                   01427000
   PROCEDURE;                                                                   01428000
      DECLARE MSG CHARACTER;                                                    01429000
      DECLARE TEMP BIT(16);                                                     01430000
      DECLARE T BIT(16);                                                        01430010
      IF NODE_DUMP THEN DO;                                                     01430020
         T=N_INX - 1;                                                           01430200
         DO WHILE NODE(T) ^= END_OF_LIST AND T ^= 0;                            01430300
            T = T - 1;                                                          01430400
         END;                                                                   01430500
         OUTPUT = '';                                                           01431000
         OUTPUT= '     NODE LIST        ADD LIST       DIFF_NODE';              01432000
         DO FOR TEMP = T TO N_INX - 1;                                          01433000
            MSG = CSE_WORD_FORMAT(NODE(TEMP))||'  '||NODE2(TEMP);               01434000
            OUTPUT = FORMAT(TEMP,3)||'. '||MSG;                                 01435000
         END;                                                                   01438000
      END;                                                                      01438010
      OUTPUT = '          LEVEL = '||SHR(NODE2(T),11)                           01438020
         || ', BLOCK# = ' || (NODE2(T) & "7FF");                                01438022
      IF ^CSE_TAB_DUMP2 THEN RETURN;                                            01438024
      OUTPUT = '';                                                              01439000
      OUTPUT = '  CSE_TAB';                                                     01440000
      DO FOR TEMP = 0 TO FREE_BLOCK_BEGIN(LAST_SPACE_BLOCK)-1;                  01441000
         T = CSE_TAB(TEMP);                                                     01442000
         MSG = FORMAT(T,8) || '   ' || HEX(T,4) ||                              01442010
            FORMAT(SHR(T,11),8)||','||(T&"7FF");                                01442020
         OUTPUT = FORMAT(TEMP,3)||'. '||MSG;                                    01443000
      END;                                                                      01444000
      OUTPUT = '';                                                              01445000
      OUTPUT = 'NUMBER CATALOG_PTR';                                            01446000
      DO FOR TEMP = 0 TO SYT_USED;                                              01447000
         IF VALIDITY(TEMP) THEN DO;                                             01448000
            OUTPUT = FORMAT(TEMP,6)  ||FORMAT(CATALOG_PTR(TEMP),12)|| '   '     01449000
               || SYT_NAME(TEMP);                                               01449010
         END;                                                                   01451000
      END;                                                                      01452000
   END CSE_TAB_DUMP;                                                            01459000
