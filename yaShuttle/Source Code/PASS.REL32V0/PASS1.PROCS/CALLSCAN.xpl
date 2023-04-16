 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CALLSCAN.xpl
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
 /* PROCEDURE NAME:  CALL_SCAN                                              */
 /* MEMBER NAME:     CALLSCAN                                               */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BCD                                                            */
 /*          CONST_DW                                                       */
 /*          CONTROL                                                        */
 /*          DW                                                             */
 /*          FALSE                                                          */
 /*          FOR_DW                                                         */
 /*          NEXT_CHAR                                                      */
 /*          PARTIAL_PARSE                                                  */
 /*          RECOVERING                                                     */
 /*          TOKEN                                                          */
 /*          VALUE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          S                                                              */
 /*          NO_LOOK_AHEAD_DONE                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          SAVE_DUMP                                                      */
 /*          SCAN                                                           */
 /* CALLED BY:                                                              */
 /*          RECOVER                                                        */
 /*          COMPILATION_LOOP                                               */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> CALL_SCAN <==                                                       */
 /*     ==> HEX                                                             */
 /*     ==> SAVE_DUMP                                                       */
 /*     ==> SCAN                                                            */
 /*         ==> MIN                                                         */
 /*         ==> HEX                                                         */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> FINISH_MACRO_TEXT                                           */
 /*         ==> SAVE_TOKEN                                                  */
 /*             ==> OUTPUT_WRITER                                           */
 /*                 ==> CHAR_INDEX                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> MIN                                                 */
 /*                 ==> MAX                                                 */
 /*                 ==> BLANK                                               */
 /*                 ==> LEFT_PAD                                            */
 /*                 ==> I_FORMAT                                            */
 /*                 ==> CHECK_DOWN                                          */
 /*         ==> STREAM                                                      */
 /*             ==> PAD                                                     */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MOVE                                                    */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> DESCORE                                                 */
 /*                 ==> PAD                                                 */
 /*             ==> HEX                                                     */
 /*             ==> SAVE_INPUT                                              */
 /*                 ==> PAD                                                 */
 /*                 ==> I_FORMAT                                            */
 /*             ==> PRINT2                                                  */
 /*             ==> OUTPUT_GROUP                                            */
 /*                 ==> PRINT2                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HASH                                                    */
 /*             ==> ENTER_XREF                                              */
 /*             ==> SAVE_LITERAL                                            */
 /*             ==> ICQ_TERM#                                               */
 /*             ==> ICQ_ARRAY#                                              */
 /*             ==> CHECK_STRUC_CONFLICTS                                   */
 /*             ==> ENTER                                                   */
 /*             ==> ENTER_DIMS                                              */
 /*             ==> DISCONNECT                                              */
 /*             ==> SET_DUPL_FLAG                                           */
 /*             ==> FINISH_MACRO_TEXT                                       */
 /*             ==> ENTER_LAYOUT                                            */
 /*             ==> MAKE_INCL_CELL                                          */
 /*             ==> OUTPUT_WRITER                                           */
 /*                 ==> CHAR_INDEX                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> MIN                                                 */
 /*                 ==> MAX                                                 */
 /*                 ==> BLANK                                               */
 /*                 ==> LEFT_PAD                                            */
 /*                 ==> I_FORMAT                                            */
 /*                 ==> CHECK_DOWN                                          */
 /*             ==> FINDER                                                  */
 /*             ==> INTERPRET_ACCESS_FILE                                   */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HASH                                                */
 /*                 ==> OUTPUT_WRITER                                       */
 /*                     ==> CHAR_INDEX                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> MIN                                             */
 /*                     ==> MAX                                             */
 /*                     ==> BLANK                                           */
 /*                     ==> LEFT_PAD                                        */
 /*                     ==> I_FORMAT                                        */
 /*                     ==> CHECK_DOWN                                      */
 /*             ==> NEXT_RECORD                                             */
 /*                 ==> DECOMPRESS                                          */
 /*                     ==> BLANK                                           */
 /*             ==> ORDER_OK                                                */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> IDENTIFY                                                    */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HASH                                                    */
 /*             ==> ENTER                                                   */
 /*             ==> SET_DUPL_FLAG                                           */
 /*             ==> SET_XREF                                                */
 /*                 ==> ENTER_XREF                                          */
 /*                 ==> SET_OUTER_REF                                       */
 /*                     ==> COMPRESS_OUTER_REF                              */
 /*                         ==> MAX                                         */
 /*             ==> BUFFER_MACRO_XREF                                       */
 /*         ==> PREP_LITERAL                                                */
 /*             ==> SAVE_LITERAL                                            */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
                                                                                01081200
CALL_SCAN:                                                                      01081300
   PROCEDURE;                                                                   01081400
      NO_LOOK_AHEAD_DONE = FALSE;                                               01081500
      CALL SCAN;                                                                01081600
      IF CONTROL(4) | (PARTIAL_PARSE & RECOVERING) THEN DO;                     01081700
         S = HEX(DW(7), 0);                                                     01081800
         S = HEX(DW(6), 0) || S;                                                01081900
         S = 'SCANNER: ' || TOKEN || ', NUMBER_VALUE: ' || S ||                 01082000
            ', VALUE: ' || VALUE;                                               01082100
         IF BCD ^= '' THEN S = S || ', CURRENT BCD: ' || BCD;                   01082200
         IF RECOVERING THEN S = S || ', SKIPPED OVER BY RECOVERY';              01082300
         S = S || ', NEXT_CHAR: ' || NEXT_CHAR;                                 01082400
         IF RECOVERING THEN CALL SAVE_DUMP(S);                                  01082500
         ELSE OUTPUT = S;                                                       01082600
      END;                                                                      01082700
   END CALL_SCAN;                                                               01082800
