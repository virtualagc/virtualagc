 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATSY.xpl
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
 /* PROCEDURE NAME:  FORMAT_SYT_VPTRS                                       */
 /* MEMBER NAME:     FORMATSY                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EQUATE_LABEL                                                   */
 /*          FUNC_CLASS                                                     */
 /*          NAME_FLAG                                                      */
 /*          PROC_LABEL                                                     */
 /*          STRUCTURE                                                      */
 /*          SYM_ADD                                                        */
 /*          SYM_CLASS                                                      */
 /*          SYM_FLAGS                                                      */
 /*          SYM_NUM                                                        */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYM_VPTR                                                       */
 /*          SYT_CLASS                                                      */
 /*          SYT_FLAGS                                                      */
 /*          SYT_NUM                                                        */
 /*          SYT_TYPE                                                       */
 /*          SYT_VPTR                                                       */
 /*          VPTR_INX                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LEVEL                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT_FORM_PARM_CELL                                          */
 /*          FORMAT_NAME_TERM_CELLS                                         */
 /*          FORMAT_VAR_REF_CELL                                            */
 /* CALLED BY:                                                              */
 /*          DUMP_ALL                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORMAT_SYT_VPTRS <==                                                */
 /*     ==> FORMAT_FORM_PARM_CELL                                           */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FLUSH                                                       */
 /*     ==> FORMAT_VAR_REF_CELL                                             */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FLUSH                                                       */
 /*         ==> STACK_PTR                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*     ==> FORMAT_NAME_TERM_CELLS                                          */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FLUSH                                                       */
 /*         ==> FORMAT_VAR_REF_CELL                                         */
 /*             ==> LOCATE                                                  */
 /*             ==> HEX                                                     */
 /*             ==> FLUSH                                                   */
 /*             ==> STACK_PTR                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /***************************************************************************/
                                                                                00302000
 /* FORMATS THE CELLS POINTED TO BY THE POINTERS IN THE SYT_VPTR ARRAY */       00302100
FORMAT_SYT_VPTRS:                                                               00302200
   PROCEDURE;                                                                   00302300
      DECLARE J BIT(16);                                                        00302400
                                                                                00302500
      DO J = 1 TO VPTR_INX;                                                     00302700
         LEVEL = 0;                                                             00302710
         IF SYT_CLASS(SYT_NUM(J))=FUNC_CLASS|SYT_TYPE(SYT_NUM(J))=PROC_LABEL    00302800
            THEN CALL FORMAT_FORM_PARM_CELL(SYT_NUM(J),SYT_VPTR(J));            00302900
         ELSE IF (SYT_FLAGS(SYT_NUM(J)) & NAME_FLAG) ^= 0 |                     00303000
            SYT_TYPE(SYT_NUM(J)) = EQUATE_LABEL THEN                            00303001
            CALL FORMAT_VAR_REF_CELL(SYT_VPTR(J));                              00303100
         ELSE IF SYT_TYPE(SYT_NUM(J)) = STRUCTURE THEN                          00303101
            CALL FORMAT_NAME_TERM_CELLS(SYT_NUM(J),SYT_VPTR(J));                00303200
      END;                                                                      00303300
   END FORMAT_SYT_VPTRS;                                                        00303400
