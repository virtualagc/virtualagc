 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   HEX.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  HEX                                                    */
 /* MEMBER NAME:     HEX                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          HVAL              FIXED                                        */
 /*          N                 FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          HEXCODES          CHARACTER;                                   */
 /*          H_LOOP            LABEL                                        */
 /*          STRING            CHARACTER;                                   */
 /*          ZEROS             CHARACTER;                                   */
 /* CALLED BY:                                                              */
 /*          DUMP_STMT_HALMAT                                               */
 /*          DUMP_ALL                                                       */
 /*          FORMAT_EXP_VARS_CELL                                           */
 /*          FORMAT_FORM_PARM_CELL                                          */
 /*          FORMAT_NAME_TERM_CELLS                                         */
 /*          FORMAT_PF_INV_CELL                                             */
 /*          FORMAT_VAR_REF_CELL                                            */
 /*          GET_STMT_VARS                                                  */
 /*          PAGE_DUMP                                                      */
 /*          PRINT_STMT_VARS                                                */
 /*          SCAN_INITIAL_LIST                                              */
 /***************************************************************************/
                                                                                00131238
                                                                                00131248
 /* SUBROUTINE TO CONVERT INTEGER TO EXTERNAL HEX NOTATION  */                  00131258
HEX:                                                                            00131268
   PROCEDURE(HVAL, N) CHARACTER;                                                00131278
      DECLARE STRING CHARACTER, (HVAL, N) FIXED;                                00131288
      DECLARE ZEROS CHARACTER INITIAL('00000000');                              00131298
      DECLARE HEXCODES CHARACTER INITIAL('0123456789ABCDEF');                   00131308
      STRING = '';                                                              00131318
H_LOOP:STRING = SUBSTR(HEXCODES, HVAL&"F", 1)|| STRING;                         00131328
      HVAL = SHR(HVAL, 4);                                                      00131338
      IF HVAL ^= 0 THEN GO TO H_LOOP;                                           00131348
      IF LENGTH(STRING) >= N THEN RETURN STRING;                                00131358
      RETURN SUBSTR(ZEROS, 0, N-LENGTH(STRING)) || STRING;                      00131368
   END HEX;                                                                     00131378
