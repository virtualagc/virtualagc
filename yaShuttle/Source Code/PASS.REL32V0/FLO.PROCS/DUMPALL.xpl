 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DUMPALL.xpl
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
 /* PROCEDURE NAME:  DUMP_ALL                                               */
 /* MEMBER NAME:     DUMPALL                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          FORMAT            BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          MSG(1)            CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          LINELENGTH                                                     */
 /*          SYM_ADD                                                        */
 /*          SYM_NAME                                                       */
 /*          SYM_NUM                                                        */
 /*          SYM_TAB                                                        */
 /*          SYM_VPTR                                                       */
 /*          SYT_NAME                                                       */
 /*          SYT_NUM                                                        */
 /*          SYT_VPTR                                                       */
 /*          VMEM_DUMP                                                      */
 /*          VMEM_LAST_PAGE                                                 */
 /*          VPTR_INX                                                       */
 /*          X1                                                             */
 /*          X3                                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT_SYT_VPTRS                                               */
 /*          HEX                                                            */
 /*          PAGE_DUMP                                                      */
 /*          PRINT_STMT_VARS                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DUMP_ALL <==                                                        */
 /*     ==> HEX                                                             */
 /*     ==> FORMAT_SYT_VPTRS                                                */
 /*         ==> FORMAT_FORM_PARM_CELL                                       */
 /*             ==> LOCATE                                                  */
 /*             ==> HEX                                                     */
 /*             ==> FLUSH                                                   */
 /*         ==> FORMAT_VAR_REF_CELL                                         */
 /*             ==> LOCATE                                                  */
 /*             ==> HEX                                                     */
 /*             ==> FLUSH                                                   */
 /*             ==> STACK_PTR                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*         ==> FORMAT_NAME_TERM_CELLS                                      */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*             ==> LOCATE                                                  */
 /*             ==> HEX                                                     */
 /*             ==> FLUSH                                                   */
 /*             ==> FORMAT_VAR_REF_CELL                                     */
 /*                 ==> LOCATE                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> FLUSH                                               */
 /*                 ==> STACK_PTR                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*     ==> PRINT_STMT_VARS                                                 */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FORMAT_CELL_TREE                                            */
 /*             ==> FORMAT_VAR_REF_CELL                                     */
 /*                 ==> LOCATE                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> FLUSH                                               */
 /*                 ==> STACK_PTR                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*             ==> FORMAT_EXP_VARS_CELL                                    */
 /*                 ==> LOCATE                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> FLUSH                                               */
 /*                 ==> STACK_PTR                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*             ==> FORMAT_PF_INV_CELL                                      */
 /*                 ==> LOCATE                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> FLUSH                                               */
 /*                 ==> STACK_PTR                                           */
 /*                     ==> ERRORS                                          */
 /*                         ==> COMMON_ERRORS                               */
 /*     ==> PAGE_DUMP                                                       */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/11/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00305847
 /* DUMPS VMEM POINTERS,CELLS AND PAGES */                                      00305900
DUMP_ALL:                                                                       00306000
   PROCEDURE (FORMAT);                                                          00306100
      DECLARE MSG(1) CHARACTER, (I,FORMAT) BIT(16);                             00306200
                                                                                00306300
      OUTPUT(1) = '1';                                                          00306400
      OUTPUT = 'INCLUDE LIST HEAD: '|| HEX(COMM(14));                           00306500
      OUTPUT = 'STMT DATA HEAD: '|| HEX(COMM(16));                              00306600
      OUTPUT = X1;                                                              00306700
      OUTPUT = 'SYT VPTRS('||VPTR_INX||'):';                                    00306800
      OUTPUT = X1;                                                              00306801
      DO I = 1 TO VPTR_INX;                                                     00306900
         MSG(1) = SYT_NAME(SYT_NUM(I))||':'||HEX(SYT_VPTR(I),8)||X3;            00307000
         IF LENGTH(MSG) + LENGTH(MSG(1)) > LINELENGTH THEN DO;                  00307100
            OUTPUT = MSG;                                                       00307200
            MSG = MSG(1);                                                       00307300
         END;                                                                   00307400
         ELSE MSG = MSG || MSG(1);                                              00307500
      END;                                                                      00307600
      OUTPUT = MSG;                                                             00307700
      IF FORMAT THEN DO;                                                        00307900
         CALL FORMAT_SYT_VPTRS;                                                 00308000
         OUTPUT(1) = '1';                                                       00308010
         CALL PRINT_STMT_VARS;                                                  00308100
      END;                                                                      00308200
      IF VMEM_DUMP THEN DO;                                                     00308300
         OUTPUT(1) = '1';                                                       00308400
         DO I = 0 TO VMEM_LAST_PAGE;                                            00308500
            CALL PAGE_DUMP(I);                                                  00308600
         END;                                                                   00308700
      END;                                                                      00308800
   END DUMP_ALL;                                                                00308900
