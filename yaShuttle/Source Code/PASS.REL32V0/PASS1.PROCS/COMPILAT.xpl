 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMPILAT.xpl
    Purpose:    This is a part of "Phase 1" (syntax analysis) of the HAL/S-FC 
                compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-07 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  COMPILATION_LOOP                                       */
 /* MEMBER NAME:     COMPILAT                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          ADD_TO_STACK(1803)  LABEL                                      */
 /*          COMP(1808)        LABEL                                        */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /*          LOOK_MATCH(1857)  LABEL                                        */
 /*          TOP_MATCH(1833)   LABEL                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #PRODUCE_NAME                                                  */
 /*          APPLY1                                                         */
 /*          APPLY2                                                         */
 /*          CHARACTER_STRING                                               */
 /*          CLASS_BS                                                       */
 /*          CLASS_P                                                        */
 /*          CONTROL                                                        */
 /*          FIXING                                                         */
 /*          IMPLIED_TYPE                                                   */
 /*          INDEX1                                                         */
 /*          INDEX2                                                         */
 /*          LOOK1                                                          */
 /*          LOOK2                                                          */
 /*          MAXL#                                                          */
 /*          MAXP#                                                          */
 /*          MAXR#                                                          */
 /*          READ1                                                          */
 /*          READ2                                                          */
 /*          REPLACE_TEXT                                                   */
 /*          RESERVED_WORD                                                  */
 /*          SEMI_COLON                                                     */
 /*          SRN_FLAG                                                       */
 /*          STACKSIZE                                                      */
 /*          STMT_END_FLAG                                                  */
 /*          STMT_PTR                                                       */
 /*          SUBSCRIPT_LEVEL                                                */
 /*          SYT_INDEX                                                      */
 /*          TOKEN                                                          */
 /*          TRUE                                                           */
 /*          VALUE                                                          */
 /*          VOCAB_INDEX                                                    */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          BCD                                                            */
 /*          COMPILING                                                      */
 /*          CONTEXT                                                        */
 /*          FIXF                                                           */
 /*          FIXL                                                           */
 /*          FIXV                                                           */
 /*          GRAMMAR_FLAGS                                                  */
 /*          LOOK                                                           */
 /*          LOOK_STACK                                                     */
 /*          MAXSP                                                          */
 /*          MP                                                             */
 /*          MPP1                                                           */
 /*          NO_LOOK_AHEAD_DONE                                             */
 /*          PARSE_STACK                                                    */
 /*          REDUCTIONS                                                     */
 /*          SP                                                             */
 /*          STATE_STACK                                                    */
 /*          STATE                                                          */
 /*          STMT_END_PTR                                                   */
 /*          TEMPORARY_IMPLIED                                              */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          CALL_SCAN                                                      */
 /*          EMIT_EXTERNAL                                                  */
 /*          ERROR                                                          */
 /*          POP_MACRO_XREF                                                 */
 /*          RECOVER                                                        */
 /*          SAVE_TOKEN                                                     */
 /*          SRN_UPDATE                                                     */
 /*          STACK_DUMP                                                     */
 /*          SYNTHESIZE                                                     */
 /*          SYT_DUMP                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> COMPILATION_LOOP <==                                                */
 /*     ==> ERROR                                                           */
 /*         ==> PAD                                                         */
 /*     ==> SAVE_TOKEN                                                      */
 /*         ==> OUTPUT_WRITER                                               */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> LEFT_PAD                                                */
 /*             ==> I_FORMAT                                                */
 /*             ==> CHECK_DOWN                                              */
 /*     ==> POP_MACRO_XREF                                                  */
 /*         ==> SET_XREF                                                    */
 /*             ==> ENTER_XREF                                              */
 /*             ==> SET_OUTER_REF                                           */
 /*                 ==> COMPRESS_OUTER_REF                                  */
 /*                     ==> MAX                                             */
 /*     ==> SYT_DUMP                                                        */
 /*         ==> PAD                                                         */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_CELL                                                    */
 /*         ==> BLANK                                                       */
 /*         ==> HEX                                                         */
 /*         ==> I_FORMAT                                                    */
 /*     ==> EMIT_EXTERNAL                                                   */
 /*         ==> PAD                                                         */
 /*         ==> BLANK                                                       */
 /*         ==> DESCORE                                                     */
 /*             ==> PAD                                                     */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> FINDER                                                      */
 /*     ==> SRN_UPDATE                                                      */
 /*     ==> CALL_SCAN                                                       */
 /*         ==> HEX                                                         */
 /*         ==> SAVE_DUMP                                                   */
 /*         ==> SCAN                                                        */
 /*             ==> MIN                                                     */
 /*             ==> HEX                                                     */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> FINISH_MACRO_TEXT                                       */
 /*             ==> SAVE_TOKEN                                              */
 /*                 ==> OUTPUT_WRITER                                       */
 /*                     ==> CHAR_INDEX                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> MIN                                             */
 /*                     ==> MAX                                             */
 /*                     ==> BLANK                                           */
 /*                     ==> LEFT_PAD                                        */
 /*                     ==> I_FORMAT                                        */
 /*                     ==> CHECK_DOWN                                      */
 /*             ==> STREAM                                                  */
 /*                 ==> PAD                                                 */
 /*                 ==> CHAR_INDEX                                          */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*                 ==> MOVE                                                */
 /*                 ==> MIN                                                 */
 /*                 ==> MAX                                                 */
 /*                 ==> DESCORE                                             */
 /*                     ==> PAD                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> SAVE_INPUT                                          */
 /*                     ==> PAD                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> PRINT2                                              */
 /*                 ==> OUTPUT_GROUP                                        */
 /*                     ==> PRINT2                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HASH                                                */
 /*                 ==> ENTER_XREF                                          */
 /*                 ==> SAVE_LITERAL                                        */
 /*                 ==> ICQ_TERM#                                           */
 /*                 ==> ICQ_ARRAY#                                          */
 /*                 ==> CHECK_STRUC_CONFLICTS                               */
 /*                 ==> ENTER                                               */
 /*                 ==> ENTER_DIMS                                          */
 /*                 ==> DISCONNECT                                          */
 /*                 ==> SET_DUPL_FLAG                                       */
 /*                 ==> FINISH_MACRO_TEXT                                   */
 /*                 ==> ENTER_LAYOUT                                        */
 /*                 ==> MAKE_INCL_CELL                                      */
 /*                 ==> OUTPUT_WRITER                                       */
 /*                     ==> CHAR_INDEX                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> MIN                                             */
 /*                     ==> MAX                                             */
 /*                     ==> BLANK                                           */
 /*                     ==> LEFT_PAD                                        */
 /*                     ==> I_FORMAT                                        */
 /*                     ==> CHECK_DOWN                                      */
 /*                 ==> FINDER                                              */
 /*                 ==> INTERPRET_ACCESS_FILE                               */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HASH                                            */
 /*                     ==> OUTPUT_WRITER                                   */
 /*                         ==> CHAR_INDEX                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> MIN                                         */
 /*                         ==> MAX                                         */
 /*                         ==> BLANK                                       */
 /*                         ==> LEFT_PAD                                    */
 /*                         ==> I_FORMAT                                    */
 /*                         ==> CHECK_DOWN                                  */
 /*                 ==> NEXT_RECORD                                         */
 /*                     ==> DECOMPRESS                                      */
 /*                         ==> BLANK                                       */
 /*                 ==> ORDER_OK                                            */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*             ==> IDENTIFY                                                */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HASH                                                */
 /*                 ==> ENTER                                               */
 /*                 ==> SET_DUPL_FLAG                                       */
 /*                 ==> SET_XREF                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SET_OUTER_REF                                   */
 /*                         ==> COMPRESS_OUTER_REF                          */
 /*                             ==> MAX                                     */
 /*                 ==> BUFFER_MACRO_XREF                                   */
 /*             ==> PREP_LITERAL                                            */
 /*                 ==> SAVE_LITERAL                                        */
 /*     ==> STACK_DUMP                                                      */
 /*         ==> SAVE_DUMP                                                   */
 /*     ==> SYNTHESIZE                                                      */
 /*         ==> GET_LITERAL                                                 */
 /*         ==> DESCORE                                                     */
 /*             ==> PAD                                                     */
 /*         ==> ERROR                                                       */
 /*             ==> PAD                                                     */
 /*         ==> MAKE_FIXED_LIT                                              */
 /*             ==> GET_LITERAL                                             */
 /*         ==> HASH                                                        */
 /*         ==> SAVE_LITERAL                                                */
 /*         ==> ICQ_TERM#                                                   */
 /*         ==> ICQ_ARRAY#                                                  */
 /*         ==> CHECK_STRUC_CONFLICTS                                       */
 /*         ==> ENTER                                                       */
 /*         ==> DISCONNECT                                                  */
 /*         ==> ENTER_LAYOUT                                                */
 /*         ==> OUTPUT_WRITER                                               */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> LEFT_PAD                                                */
 /*             ==> I_FORMAT                                                */
 /*             ==> CHECK_DOWN                                              */
 /*         ==> COMPRESS_OUTER_REF                                          */
 /*             ==> MAX                                                     */
 /*         ==> BLOCK_SUMMARY                                               */
 /*             ==> COMPRESS_OUTER_REF                                      */
 /*                 ==> MAX                                                 */
 /*         ==> SET_OUTER_REF                                               */
 /*             ==> COMPRESS_OUTER_REF                                      */
 /*                 ==> MAX                                                 */
 /*         ==> SET_BI_XREF                                                 */
 /*             ==> ENTER_XREF                                              */
 /*         ==> SET_XREF                                                    */
 /*             ==> ENTER_XREF                                              */
 /*             ==> SET_OUTER_REF                                           */
 /*                 ==> COMPRESS_OUTER_REF                                  */
 /*                     ==> MAX                                             */
 /*         ==> SET_XREF_RORS                                               */
 /*             ==> SET_XREF                                                */
 /*                 ==> ENTER_XREF                                          */
 /*                 ==> SET_OUTER_REF                                       */
 /*                     ==> COMPRESS_OUTER_REF                              */
 /*                         ==> MAX                                         */
 /*         ==> TIE_XREF                                                    */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> EMIT_EXTERNAL                                               */
 /*             ==> PAD                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> DESCORE                                                 */
 /*                 ==> PAD                                                 */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> FINDER                                                  */
 /*         ==> SRN_UPDATE                                                  */
 /*         ==> STAB_VAR                                                    */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> STAB_LAB                                                    */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> STAB_HDR                                                    */
 /*             ==> PTR_LOCATE                                              */
 /*             ==> GET_CELL                                                */
 /*             ==> LOCATE                                                  */
 /*         ==> HALMAT_OUT                                                  */
 /*             ==> HALMAT_BLAB                                             */
 /*                 ==> HEX                                                 */
 /*                 ==> I_FORMAT                                            */
 /*         ==> HALMAT_BACKUP                                               */
 /*         ==> HALMAT_POP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_PIP                                                  */
 /*             ==> HALMAT                                                  */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_BLAB                                         */
 /*                     ==> HEX                                             */
 /*                     ==> I_FORMAT                                        */
 /*                 ==> HALMAT_OUT                                          */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*         ==> HALMAT_TUPLE                                                */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> HALMAT_FIX_PIP#                                             */
 /*         ==> HALMAT_FIX_POPTAG                                           */
 /*         ==> HALMAT_FIX_PIPTAGS                                          */
 /*         ==> EMIT_SMRK                                                   */
 /*             ==> STAB_HDR                                                */
 /*                 ==> PTR_LOCATE                                          */
 /*                 ==> GET_CELL                                            */
 /*                 ==> LOCATE                                              */
 /*             ==> HALMAT_RELOCATE                                         */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> EMIT_PUSH_DO                                                */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> PUSH_INDIRECT                                               */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> LABEL_MATCH                                                 */
 /*         ==> UNBRANCHABLE                                                */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> SETUP_VAC                                                   */
 /*         ==> VECTOR_COMPARE                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> MATRIX_COMPARE                                              */
 /*             ==> VECTOR_COMPARE                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*         ==> UNARRAYED_INTEGER                                           */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*         ==> UNARRAYED_SCALAR                                            */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*         ==> UNARRAYED_SIMPLE                                            */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*         ==> CHECK_EVENT_EXP                                             */
 /*             ==> HALMAT_FIX_POPTAG                                       */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*         ==> PROCESS_CHECK                                               */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*         ==> CHECK_ASSIGN_CONTEXT                                        */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> SET_XREF_RORS                                           */
 /*                 ==> SET_XREF                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SET_OUTER_REF                                   */
 /*                         ==> COMPRESS_OUTER_REF                          */
 /*                             ==> MAX                                     */
 /*             ==> STAB_VAR                                                */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> HALMAT_FIX_PIPTAGS                                      */
 /*         ==> ERROR_SUB                                                   */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> MAKE_FIXED_LIT                                          */
 /*                 ==> GET_LITERAL                                         */
 /*         ==> MATCH_SIMPLES                                               */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*         ==> READ_ALL_TYPE                                               */
 /*         ==> STRUCTURE_COMPARE                                           */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> PUSH_FCN_STACK                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> ARITH_LITERAL                                               */
 /*             ==> GET_LITERAL                                             */
 /*         ==> PREC_SCALE                                                  */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> MAKE_FIXED_LIT                                          */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> FLOATING                                                */
 /*             ==> SAVE_LITERAL                                            */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*             ==> ARITH_LITERAL                                           */
 /*                 ==> GET_LITERAL                                         */
 /*         ==> BIT_LITERAL                                                 */
 /*             ==> GET_LITERAL                                             */
 /*         ==> CHAR_LITERAL                                                */
 /*             ==> GET_LITERAL                                             */
 /*         ==> MATCH_ARITH                                                 */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> VECTOR_COMPARE                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> MATRIX_COMPARE                                          */
 /*                 ==> VECTOR_COMPARE                                      */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*             ==> MATCH_SIMPLES                                           */
 /*                 ==> HALMAT_TUPLE                                        */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                 ==> SETUP_VAC                                           */
 /*         ==> LIT_RESULT_TYPE                                             */
 /*         ==> ADD_AND_SUBTRACT                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> SAVE_LITERAL                                            */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*             ==> ARITH_LITERAL                                           */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> MATCH_ARITH                                             */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> VECTOR_COMPARE                                      */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                 ==> MATRIX_COMPARE                                      */
 /*                     ==> VECTOR_COMPARE                                  */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                 ==> MATCH_SIMPLES                                       */
 /*                     ==> HALMAT_TUPLE                                    */
 /*                         ==> HALMAT_POP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                         ==> HALMAT_PIP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                     ==> SETUP_VAC                                       */
 /*             ==> LIT_RESULT_TYPE                                         */
 /*         ==> MULTIPLY_SYNTHESIZE                                         */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> SAVE_LITERAL                                            */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*             ==> VECTOR_COMPARE                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> MATCH_SIMPLES                                           */
 /*                 ==> HALMAT_TUPLE                                        */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                 ==> SETUP_VAC                                           */
 /*             ==> ARITH_LITERAL                                           */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> LIT_RESULT_TYPE                                         */
 /*         ==> IORS                                                        */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> EMIT_ARRAYNESS                                              */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> SAVE_ARRAYNESS                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> RESET_ARRAYNESS                                             */
 /*         ==> ARITH_TO_CHAR                                               */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*         ==> NAME_COMPARE                                                */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> RESET_ARRAYNESS                                         */
 /*         ==> KILL_NAME                                                   */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*             ==> RESET_ARRAYNESS                                         */
 /*         ==> COPINESS                                                    */
 /*         ==> NAME_ARRAYNESS                                              */
 /*         ==> CHECK_NAMING                                                */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> SET_XREF_RORS                                           */
 /*                 ==> SET_XREF                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SET_OUTER_REF                                   */
 /*                         ==> COMPRESS_OUTER_REF                          */
 /*                             ==> MAX                                     */
 /*             ==> CHECK_ASSIGN_CONTEXT                                    */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> SET_XREF_RORS                                       */
 /*                     ==> SET_XREF                                        */
 /*                         ==> ENTER_XREF                                  */
 /*                         ==> SET_OUTER_REF                               */
 /*                             ==> COMPRESS_OUTER_REF                      */
 /*                                 ==> MAX                                 */
 /*                 ==> STAB_VAR                                            */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                 ==> HALMAT_FIX_PIPTAGS                                  */
 /*         ==> SETUP_NO_ARG_FCN                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> FLOATING                                                */
 /*             ==> SAVE_LITERAL                                            */
 /*             ==> SET_BI_XREF                                             */
 /*                 ==> ENTER_XREF                                          */
 /*             ==> SET_XREF_RORS                                           */
 /*                 ==> SET_XREF                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SET_OUTER_REF                                   */
 /*                         ==> COMPRESS_OUTER_REF                          */
 /*                             ==> MAX                                     */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SETUP_VAC                                               */
 /*             ==> UPDATE_BLOCK_CHECK                                      */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> PREC_SCALE                                              */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> MAKE_FIXED_LIT                                      */
 /*                     ==> GET_LITERAL                                     */
 /*                 ==> FLOATING                                            */
 /*                 ==> SAVE_LITERAL                                        */
 /*                 ==> HALMAT_TUPLE                                        */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                 ==> SETUP_VAC                                           */
 /*                 ==> ARITH_LITERAL                                       */
 /*                     ==> GET_LITERAL                                     */
 /*             ==> STRUCTURE_FCN                                           */
 /*         ==> START_NORMAL_FCN                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> SET_BI_XREF                                             */
 /*                 ==> ENTER_XREF                                          */
 /*             ==> SET_XREF_RORS                                           */
 /*                 ==> SET_XREF                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SET_OUTER_REF                                   */
 /*                         ==> COMPRESS_OUTER_REF                          */
 /*                             ==> MAX                                     */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> PUSH_INDIRECT                                           */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> PUSH_FCN_STACK                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> UPDATE_BLOCK_CHECK                                      */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> SAVE_ARRAYNESS                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> STRUCTURE_FCN                                           */
 /*         ==> SETUP_CALL_ARG                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> HALMAT_FIX_PIP#                                         */
 /*             ==> HALMAT_FIX_PIPTAGS                                      */
 /*             ==> VECTOR_COMPARE                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> MATRIX_COMPARE                                          */
 /*                 ==> VECTOR_COMPARE                                      */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*             ==> STRUCTURE_COMPARE                                       */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> EMIT_ARRAYNESS                                          */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> SAVE_ARRAYNESS                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> RESET_ARRAYNESS                                         */
 /*             ==> NAME_COMPARE                                            */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> RESET_ARRAYNESS                                     */
 /*             ==> KILL_NAME                                               */
 /*                 ==> CHECK_ARRAYNESS                                     */
 /*                 ==> RESET_ARRAYNESS                                     */
 /*             ==> NAME_ARRAYNESS                                          */
 /*             ==> GET_FCN_PARM                                            */
 /*         ==> ARITH_SHAPER_SUB                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> MAKE_FIXED_LIT                                          */
 /*                 ==> GET_LITERAL                                         */
 /*         ==> ATTACH_SUBSCRIPT                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> CHECK_ARRAYNESS                                         */
 /*             ==> RESET_ARRAYNESS                                         */
 /*             ==> GET_ARRAYNESS                                           */
 /*             ==> MATCH_ARRAYNESS                                         */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> ATTACH_SUB_COMPONENT                                    */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> REDUCE_SUBSCRIPT                                    */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> CHECK_SUBSCRIPT                                 */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> MAKE_FIXED_LIT                              */
 /*                             ==> GET_LITERAL                             */
 /*                         ==> HALMAT_POP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                         ==> HALMAT_PIP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                 ==> AST_STACKER                                         */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> PUSH_INDIRECT                                   */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                 ==> SLIP_SUBSCRIPT                                      */
 /*             ==> ATTACH_SUB_ARRAY                                        */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> REDUCE_SUBSCRIPT                                    */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> CHECK_SUBSCRIPT                                 */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> MAKE_FIXED_LIT                              */
 /*                             ==> GET_LITERAL                             */
 /*                         ==> HALMAT_POP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                         ==> HALMAT_PIP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                 ==> AST_STACKER                                         */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> PUSH_INDIRECT                                   */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                 ==> SLIP_SUBSCRIPT                                      */
 /*             ==> ATTACH_SUB_STRUCTURE                                    */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> REDUCE_SUBSCRIPT                                    */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> CHECK_SUBSCRIPT                                 */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> MAKE_FIXED_LIT                              */
 /*                             ==> GET_LITERAL                             */
 /*                         ==> HALMAT_POP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                         ==> HALMAT_PIP                                  */
 /*                             ==> HALMAT                                  */
 /*                                 ==> ERROR                               */
 /*                                     ==> PAD                             */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                                 ==> HALMAT_OUT                          */
 /*                                     ==> HALMAT_BLAB                     */
 /*                                         ==> HEX                         */
 /*                                         ==> I_FORMAT                    */
 /*                 ==> AST_STACKER                                         */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> PUSH_INDIRECT                                   */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                 ==> SLIP_SUBSCRIPT                                      */
 /*         ==> EMIT_SUBSCRIPT                                              */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> END_ANY_FCN                                                 */
 /*             ==> MAX                                                     */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> SAVE_LITERAL                                            */
 /*             ==> HALMAT_XNOP                                             */
 /*             ==> HALMAT_BACKUP                                           */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> HALMAT_FIX_PIP#                                         */
 /*             ==> SETUP_VAC                                               */
 /*             ==> MATCH_SIMPLES                                           */
 /*                 ==> HALMAT_TUPLE                                        */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                 ==> SETUP_VAC                                           */
 /*             ==> ARITH_LITERAL                                           */
 /*                 ==> GET_LITERAL                                         */
 /*             ==> RESET_ARRAYNESS                                         */
 /*             ==> GET_FCN_PARM                                            */
 /*             ==> REDUCE_SUBSCRIPT                                        */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> CHECK_SUBSCRIPT                                     */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> MAKE_FIXED_LIT                                  */
 /*                         ==> GET_LITERAL                                 */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*         ==> END_SUBBIT_FCN                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_TUPLE                                            */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*             ==> HALMAT_FIX_PIP#                                         */
 /*             ==> SETUP_VAC                                               */
 /*             ==> REDUCE_SUBSCRIPT                                        */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> CHECK_SUBSCRIPT                                     */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> MAKE_FIXED_LIT                                  */
 /*                         ==> GET_LITERAL                                 */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*         ==> GET_ICQ                                                     */
 /*         ==> HALMAT_INIT_CONST                                           */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> GET_ICQ                                                 */
 /*             ==> ICQ_ARRAYNESS_OUTPUT                                    */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_FIX_PIP#                                     */
 /*             ==> ICQ_CHECK_TYPE                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> ICQ_OUTPUT                                              */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_FIX_PIPTAGS                                  */
 /*                 ==> GET_ICQ                                             */
 /*                 ==> ICQ_CHECK_TYPE                                      */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*             ==> HOW_TO_INIT_ARGS                                        */
 /*                 ==> ICQ_TERM#                                           */
 /*                 ==> ICQ_ARRAY#                                          */
 /*         ==> CHECK_CONSISTENCY                                           */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> CHECK_CONFLICTS                                             */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> COMPARE                                                 */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*             ==> CHECK_CONSISTENCY                                       */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> CHECK_EVENT_CONFLICTS                                       */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> SET_SYT_ENTRIES                                             */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> ENTER_DIMS                                              */
 /*             ==> HALMAT_INIT_CONST                                       */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> HALMAT_POP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> HALMAT_PIP                                          */
 /*                     ==> HALMAT                                          */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*                         ==> HALMAT_OUT                                  */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                 ==> GET_ICQ                                             */
 /*                 ==> ICQ_ARRAYNESS_OUTPUT                                */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_FIX_PIP#                                 */
 /*                 ==> ICQ_CHECK_TYPE                                      */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                 ==> ICQ_OUTPUT                                          */
 /*                     ==> HALMAT_POP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_PIP                                      */
 /*                         ==> HALMAT                                      */
 /*                             ==> ERROR                                   */
 /*                                 ==> PAD                                 */
 /*                             ==> HALMAT_BLAB                             */
 /*                                 ==> HEX                                 */
 /*                                 ==> I_FORMAT                            */
 /*                             ==> HALMAT_OUT                              */
 /*                                 ==> HALMAT_BLAB                         */
 /*                                     ==> HEX                             */
 /*                                     ==> I_FORMAT                        */
 /*                     ==> HALMAT_FIX_PIPTAGS                              */
 /*                     ==> GET_ICQ                                         */
 /*                     ==> ICQ_CHECK_TYPE                                  */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                 ==> HOW_TO_INIT_ARGS                                    */
 /*                     ==> ICQ_TERM#                                       */
 /*                     ==> ICQ_ARRAY#                                      */
 /*         ==> CHECK_IMPLICIT_T                                            */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> CALL_SCAN                                                   */
 /*             ==> HEX                                                     */
 /*             ==> SAVE_DUMP                                               */
 /*             ==> SCAN                                                    */
 /*                 ==> MIN                                                 */
 /*                 ==> HEX                                                 */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> FINISH_MACRO_TEXT                                   */
 /*                 ==> SAVE_TOKEN                                          */
 /*                     ==> OUTPUT_WRITER                                   */
 /*                         ==> CHAR_INDEX                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> MIN                                         */
 /*                         ==> MAX                                         */
 /*                         ==> BLANK                                       */
 /*                         ==> LEFT_PAD                                    */
 /*                         ==> I_FORMAT                                    */
 /*                         ==> CHECK_DOWN                                  */
 /*                 ==> STREAM                                              */
 /*                     ==> PAD                                             */
 /*                     ==> CHAR_INDEX                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> MOVE                                            */
 /*                     ==> MIN                                             */
 /*                     ==> MAX                                             */
 /*                     ==> DESCORE                                         */
 /*                         ==> PAD                                         */
 /*                     ==> HEX                                             */
 /*                     ==> SAVE_INPUT                                      */
 /*                         ==> PAD                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> PRINT2                                          */
 /*                     ==> OUTPUT_GROUP                                    */
 /*                         ==> PRINT2                                      */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HASH                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SAVE_LITERAL                                    */
 /*                     ==> ICQ_TERM#                                       */
 /*                     ==> ICQ_ARRAY#                                      */
 /*                     ==> CHECK_STRUC_CONFLICTS                           */
 /*                     ==> ENTER                                           */
 /*                     ==> ENTER_DIMS                                      */
 /*                     ==> DISCONNECT                                      */
 /*                     ==> SET_DUPL_FLAG                                   */
 /*                     ==> FINISH_MACRO_TEXT                               */
 /*                     ==> ENTER_LAYOUT                                    */
 /*                     ==> MAKE_INCL_CELL                                  */
 /*                     ==> OUTPUT_WRITER                                   */
 /*                         ==> CHAR_INDEX                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> MIN                                         */
 /*                         ==> MAX                                         */
 /*                         ==> BLANK                                       */
 /*                         ==> LEFT_PAD                                    */
 /*                         ==> I_FORMAT                                    */
 /*                         ==> CHECK_DOWN                                  */
 /*                     ==> FINDER                                          */
 /*                     ==> INTERPRET_ACCESS_FILE                           */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HASH                                        */
 /*                         ==> OUTPUT_WRITER                               */
 /*                             ==> CHAR_INDEX                              */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                             ==> MIN                                     */
 /*                             ==> MAX                                     */
 /*                             ==> BLANK                                   */
 /*                             ==> LEFT_PAD                                */
 /*                             ==> I_FORMAT                                */
 /*                             ==> CHECK_DOWN                              */
 /*                     ==> NEXT_RECORD                                     */
 /*                         ==> DECOMPRESS                                  */
 /*                             ==> BLANK                                   */
 /*                     ==> ORDER_OK                                        */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                 ==> IDENTIFY                                            */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HASH                                            */
 /*                     ==> ENTER                                           */
 /*                     ==> SET_DUPL_FLAG                                   */
 /*                     ==> SET_XREF                                        */
 /*                         ==> ENTER_XREF                                  */
 /*                         ==> SET_OUTER_REF                               */
 /*                             ==> COMPRESS_OUTER_REF                      */
 /*                                 ==> MAX                                 */
 /*                     ==> BUFFER_MACRO_XREF                               */
 /*                 ==> PREP_LITERAL                                        */
 /*                     ==> SAVE_LITERAL                                    */
 /*         ==> STACK_DUMP                                                  */
 /*             ==> SAVE_DUMP                                               */
 /*         ==> SET_LABEL_TYPE                                              */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*         ==> ASSOCIATE                                                   */
 /*             ==> ERROR                                                   */
 /*                 ==> PAD                                                 */
 /*             ==> HALMAT_FIX_POPTAG                                       */
 /*             ==> SAVE_ARRAYNESS                                          */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*         ==> SET_BLOCK_SRN                                               */
 /*             ==> LOCATE                                                  */
 /*     ==> RECOVER                                                         */
 /*         ==> OUTPUT_WRITER                                               */
 /*             ==> CHAR_INDEX                                              */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> MIN                                                     */
 /*             ==> MAX                                                     */
 /*             ==> BLANK                                                   */
 /*             ==> LEFT_PAD                                                */
 /*             ==> I_FORMAT                                                */
 /*             ==> CHECK_DOWN                                              */
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
 /*         ==> EMIT_SMRK                                                   */
 /*             ==> STAB_HDR                                                */
 /*                 ==> PTR_LOCATE                                          */
 /*                 ==> GET_CELL                                            */
 /*                 ==> LOCATE                                              */
 /*             ==> HALMAT_RELOCATE                                         */
 /*             ==> HALMAT_POP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*             ==> HALMAT_PIP                                              */
 /*                 ==> HALMAT                                              */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HALMAT_BLAB                                     */
 /*                         ==> HEX                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> HALMAT_OUT                                      */
 /*                         ==> HALMAT_BLAB                                 */
 /*                             ==> HEX                                     */
 /*                             ==> I_FORMAT                                */
 /*         ==> CHECK_ARRAYNESS                                             */
 /*         ==> CALL_SCAN                                                   */
 /*             ==> HEX                                                     */
 /*             ==> SAVE_DUMP                                               */
 /*             ==> SCAN                                                    */
 /*                 ==> MIN                                                 */
 /*                 ==> HEX                                                 */
 /*                 ==> ERROR                                               */
 /*                     ==> PAD                                             */
 /*                 ==> FINISH_MACRO_TEXT                                   */
 /*                 ==> SAVE_TOKEN                                          */
 /*                     ==> OUTPUT_WRITER                                   */
 /*                         ==> CHAR_INDEX                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> MIN                                         */
 /*                         ==> MAX                                         */
 /*                         ==> BLANK                                       */
 /*                         ==> LEFT_PAD                                    */
 /*                         ==> I_FORMAT                                    */
 /*                         ==> CHECK_DOWN                                  */
 /*                 ==> STREAM                                              */
 /*                     ==> PAD                                             */
 /*                     ==> CHAR_INDEX                                      */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*                     ==> MOVE                                            */
 /*                     ==> MIN                                             */
 /*                     ==> MAX                                             */
 /*                     ==> DESCORE                                         */
 /*                         ==> PAD                                         */
 /*                     ==> HEX                                             */
 /*                     ==> SAVE_INPUT                                      */
 /*                         ==> PAD                                         */
 /*                         ==> I_FORMAT                                    */
 /*                     ==> PRINT2                                          */
 /*                     ==> OUTPUT_GROUP                                    */
 /*                         ==> PRINT2                                      */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HASH                                            */
 /*                     ==> ENTER_XREF                                      */
 /*                     ==> SAVE_LITERAL                                    */
 /*                     ==> ICQ_TERM#                                       */
 /*                     ==> ICQ_ARRAY#                                      */
 /*                     ==> CHECK_STRUC_CONFLICTS                           */
 /*                     ==> ENTER                                           */
 /*                     ==> ENTER_DIMS                                      */
 /*                     ==> DISCONNECT                                      */
 /*                     ==> SET_DUPL_FLAG                                   */
 /*                     ==> FINISH_MACRO_TEXT                               */
 /*                     ==> ENTER_LAYOUT                                    */
 /*                     ==> MAKE_INCL_CELL                                  */
 /*                     ==> OUTPUT_WRITER                                   */
 /*                         ==> CHAR_INDEX                                  */
 /*                         ==> ERRORS                                      */
 /*                             ==> COMMON_ERRORS                           */
 /*                         ==> MIN                                         */
 /*                         ==> MAX                                         */
 /*                         ==> BLANK                                       */
 /*                         ==> LEFT_PAD                                    */
 /*                         ==> I_FORMAT                                    */
 /*                         ==> CHECK_DOWN                                  */
 /*                     ==> FINDER                                          */
 /*                     ==> INTERPRET_ACCESS_FILE                           */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                         ==> HASH                                        */
 /*                         ==> OUTPUT_WRITER                               */
 /*                             ==> CHAR_INDEX                              */
 /*                             ==> ERRORS                                  */
 /*                                 ==> COMMON_ERRORS                       */
 /*                             ==> MIN                                     */
 /*                             ==> MAX                                     */
 /*                             ==> BLANK                                   */
 /*                             ==> LEFT_PAD                                */
 /*                             ==> I_FORMAT                                */
 /*                             ==> CHECK_DOWN                              */
 /*                     ==> NEXT_RECORD                                     */
 /*                         ==> DECOMPRESS                                  */
 /*                             ==> BLANK                                   */
 /*                     ==> ORDER_OK                                        */
 /*                         ==> ERROR                                       */
 /*                             ==> PAD                                     */
 /*                 ==> IDENTIFY                                            */
 /*                     ==> ERROR                                           */
 /*                         ==> PAD                                         */
 /*                     ==> HASH                                            */
 /*                     ==> ENTER                                           */
 /*                     ==> SET_DUPL_FLAG                                   */
 /*                     ==> SET_XREF                                        */
 /*                         ==> ENTER_XREF                                  */
 /*                         ==> SET_OUTER_REF                               */
 /*                             ==> COMPRESS_OUTER_REF                      */
 /*                                 ==> MAX                                 */
 /*                     ==> BUFFER_MACRO_XREF                               */
 /*                 ==> PREP_LITERAL                                        */
 /*                     ==> SAVE_LITERAL                                    */
 /*         ==> STACK_DUMP                                                  */
 /*             ==> SAVE_DUMP                                               */
 /*         ==> CHECK_TOKEN                                                 */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 07/13/95 DAS  27V0  CR12416  IMPROVE COMPILER ERROR PROCESSING          */
 /*               11V0           (MAKE SEVERITY 3&4 ERRORS CAUSE ABORT)     */
 /*                                                                         */
 /* 06/29/99 DCP  30V0  DR111322 LONG FACTOR DECLARATION APPEARS AS TWO     */
 /*               15V0           STATEMENTS IN OUTPUT LISTING               */
 /*                                                                         */
 /***************************************************************************/
                                                                                01542100
                                                                                01542200
COMPILATION_LOOP:                                                               01542300
   PROCEDURE;                                                                   01542400
                                                                                01542500
      DECLARE (I,J) FIXED;                                                      01542600
                                                                                01542700
 /*   THIS PROC PARSES THE INPUT STRING (BY CALLING THE SCANNER)   */           01542800
 /*   AND CALLS THE CODE EMISSION PROC (SYNTHESIZE) WHENEVER A     */           01542900
 /*   PRODUCTION CAN BE APPLIED                                    */           01543000
                                                                                01543100
 /*   INITIALIZE                                                   */           01543200
      COMPILING = TRUE;                                                         01543300
ADD_TO_STACK:                                                                   01543400
      PROCEDURE;                                                                01543500
         SP = SP + 1;                                                           01543600
         IF SP > MAXSP THEN                                                     01543700
            DO;                                                                 01543800
            MAXSP = SP;                                                         01543900
            IF SP > STACKSIZE THEN                                              01544000
               DO;                                                              01544100
               CALL ERROR(CLASS_BS,3); /* CR12416 */                            01544200
               RETURN;     /*  THUS ABORTING COMPILATION  */                    01544300
            END;                                                                01544400
         END;                                                                   01544500
      END ADD_TO_STACK;                                                         01544600
                                                                                01544700
COMP: DO WHILE (COMPILING);                                                     01544800
 /*   FIND WHICH OF THE FOUR KINDS OF STATES WE ARE DEALING WITH:  */           01544900
 /*   READ,APPLY PRODUCTION,LOOKAHEAD, OR PUSH STATE               */           01545000
         IF CONTROL("C") THEN                                                   01545100
            OUTPUT = ' COMP: STATE='||STATE||' I='||I||' J='||J;                01545200
         IF STATE <= MAXR#                                                      01545300
            THEN DO;   /*   READ STATE   */                                     01545400
            IF NO_LOOK_AHEAD_DONE THEN CALL CALL_SCAN;                          01545500
            IF SRN_FLAG THEN CALL SRN_UPDATE;                                   01545600
            CALL ADD_TO_STACK;                                                  01545700
            STATE_STACK(SP) = STATE;   /*   PUSH PRESENT STATE   */             01545800
            LOOK_STACK(SP)=LOOK;                                                01545900
            LOOK=0;                                                             01546000
            I = INDEX1(STATE);         /*   GET STARTING POINT   */             01546100
 /*   COMPARE TOKEN WITH EACH TRANSITION SYMBOL IN    */                        01546200
 /*   READ STATE                                      */                        01546300
            DO I = I TO I+INDEX2(STATE)-1;                                      01546400
               IF READ1(I) = TOKEN                                              01546500
                  THEN DO;   /*   FOUND IT   */                                 01546600
                  CALL SAVE_TOKEN(TOKEN, BCD, IMPLIED_TYPE);                    01546700
                  CALL POP_MACRO_XREF;                                          01546710
                  NO_LOOK_AHEAD_DONE=TRUE;                                      01546800
                  IF TOKEN = SEMI_COLON THEN DO;                                01546900
                     IF SUBSCRIPT_LEVEL = 0 THEN DO;                            01547000
                        SQUEEZING = FALSE;                       /*DR111322*/
                        CONTEXT,TEMPORARY_IMPLIED=0;                            01547100
                        GRAMMAR_FLAGS(STMT_PTR) = GRAMMAR_FLAGS(                01547200
                           STMT_PTR) | STMT_END_FLAG;                           01547300
                        STMT_END_PTR = STMT_PTR;                                01547310
                        IF CONTROL(7) THEN CALL SYT_DUMP;                       01547400
                     END;                                                       01547500
                  END;                                                          01547600
                  VAR(SP) = BCD;                                                01547700
                  FIXV(SP) = VALUE;                                             01547800
                  FIXF(SP)=FIXING;                                              01547900
                  FIXL(SP) = SYT_INDEX;                                         01548000
                  PARSE_STACK(SP) = TOKEN;                                      01548100
                  STATE = READ2(I);                                             01548200
                  CALL EMIT_EXTERNAL;                                           01548300
                  GO TO COMP;                                                   01548400
               END;                                                             01548500
            END;                                                                01548600
 /*   FOUND AN ERROR   */                                                       01548700
            CALL STACK_DUMP;                                                    01548710
            CALL SAVE_TOKEN(TOKEN, BCD, IMPLIED_TYPE);                          01548720
            IF (RESERVED_WORD | (TOKEN = CHARACTER_STRING) |                    01548800
               (TOKEN = REPLACE_TEXT)) THEN                                     01548900
               BCD = STRING(VOCAB_INDEX(TOKEN));                                01549000
            CALL ERROR(CLASS_P,8,BCD);                                          01549100
            CALL RECOVER;                                                       01549200
         END;                                                                   01549300
         ELSE                                                                   01549400
            IF STATE > MAXP#                                                    01549500
            THEN DO;   /*   APPLY PRODUCTION STATE   */                         01549600
            REDUCTIONS = REDUCTIONS + 1;                                        01549700
 /*   SP POINTS AT RIGHT END OF PRODUCTION   */                                 01549800
 /*   MP POINTS AT LEFT END OF PRODUCTION   */                                  01549900
            MP = SP-INDEX2(STATE);                                              01550000
            MPP1 = MP+1;                                                        01550100
            CALL SYNTHESIZE (STATE-MAXP#);   /*   APPLY PRODUCTION   */         01550200
            SP = MP;   /*   RESET STACK POINTER   */                            01550300
            PARSE_STACK(SP)=#PRODUCE_NAME(STATE-MAXP#)&"FFF";                   01550400
            I = INDEX1(STATE);                                                  01550500
 /*   COMPARE TOP OF STATE STACK WITH TABLES   */                               01550600
            J = STATE_STACK(SP);                                                01550700
            DO WHILE APPLY1(I) ^= 0;                                            01550800
               IF J = APPLY1(I) THEN GO TO TOP_MATCH;                           01550900
               I = I+1;                                                         01551000
            END;                                                                01551100
 /*   HAS THE PROGRAM GOAL BEEN REACHED   */                                    01551200
TOP_MATCH:  IF APPLY2(I) = 0 THEN RETURN;  /*  YES, FINISHED  */                01551300
            STATE = APPLY2(I);   /*   PICK UP THE NEXT STATE   */               01551400
            LOOK=0;                                                             01551500
         END;                                                                   01551600
         ELSE                                                                   01551700
            IF STATE <= MAXL#                                                   01551800
            THEN DO;   /*   LOOKAHEAD STATE   */                                01551900
            I = INDEX1(STATE);   /*   INDEX INTO THE TABLE   */                 01552000
            LOOK=STATE;                                                         01552100
            IF NO_LOOK_AHEAD_DONE THEN CALL CALL_SCAN;                          01552200
 /*   CHECK TOKEN AGAINST LEGAL LOOKAHEAD TRANSITION SYMBOLS*/                  01552300
            DO WHILE LOOK1(I) ^= 0;                                             01552400
               IF LOOK1(I) = TOKEN                                              01552500
                  THEN GO TO LOOK_MATCH;   /*   FOUND ONE   */                  01552600
               I = I+1;                                                         01552700
            END;                                                                01552800
LOOK_MATCH: STATE = LOOK2(I);                                                   01552900
         END;                                                                   01553000
         ELSE DO;   /*   PUSH STATE   */                                        01553100
            CALL ADD_TO_STACK;                                                  01553200
 /*   PUSH A STATE # INTO THE STATE_STACK   */                                  01553300
            STATE_STACK(SP) = INDEX2(STATE);                                    01553400
 /*   GET NEXT STATE                        */                                  01553500
            STATE = INDEX1(STATE);                                              01553600
            LOOK_STACK(SP),LOOK=0;                                              01553700
         END;                                                                   01553800
      END;   /*   OF COMPILE LOOP   */                                          01553900
                                                                                01554000
   END COMPILATION_LOOP;                                                        01554100
