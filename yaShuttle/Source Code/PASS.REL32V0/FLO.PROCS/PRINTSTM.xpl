 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSTM.xpl
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
 /* PROCEDURE NAME:  PRINT_STMT_VARS                                        */
 /* MEMBER NAME:     PRINTSTM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          STMT_PTR          FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          COMM                                                           */
 /*          STMT_DATA_HEAD                                                 */
 /*          VMEM_F                                                         */
 /*          VMEM_H                                                         */
 /*          VMEM_LOC_ADDR                                                  */
 /*          X1                                                             */
 /*          X10                                                            */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          EXP_VARS                                                       */
 /*          EXP_PTRS                                                       */
 /*          PTR_INX                                                        */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          FORMAT_CELL_TREE                                               */
 /*          LOCATE                                                         */
 /* CALLED BY:                                                              */
 /*          DUMP_ALL                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINT_STMT_VARS <==                                                 */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /*     ==> FORMAT_CELL_TREE                                                */
 /*         ==> FORMAT_VAR_REF_CELL                                         */
 /*             ==> LOCATE                                                  */
 /*             ==> HEX                                                     */
 /*             ==> FLUSH                                                   */
 /*             ==> STACK_PTR                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*         ==> FORMAT_EXP_VARS_CELL                                        */
 /*             ==> LOCATE                                                  */
 /*             ==> HEX                                                     */
 /*             ==> FLUSH                                                   */
 /*             ==> STACK_PTR                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /*         ==> FORMAT_PF_INV_CELL                                          */
 /*             ==> LOCATE                                                  */
 /*             ==> HEX                                                     */
 /*             ==> FLUSH                                                   */
 /*             ==> STACK_PTR                                               */
 /*                 ==> ERRORS                                              */
 /*                     ==> COMMON_ERRORS                                   */
 /***************************************************************************/
                                                                                00303500
 /* FORMATS THE STMT VARIBLES DATA ASSOCIATED WITH THE STMT DATA CELLS */       00303600
PRINT_STMT_VARS:                                                                00303700
   PROCEDURE;                                                                   00303800
      DECLARE STMT_PTR FIXED;                                                   00303900
                                                                                00304000
      OUTPUT = X1;                                                              00304100
      OUTPUT = 'STMT VARIABLES:';                                               00304200
      OUTPUT = X1;                                                              00304300
      STMT_PTR = STMT_DATA_HEAD;                                                00304400
      DO WHILE STMT_PTR ^= -1;                                                  00304500
         CALL LOCATE(STMT_PTR,ADDR(VMEM_F),0);                                  00304600
         COREWORD(ADDR(VMEM_H)) = VMEM_LOC_ADDR;                                00304700
         STMT_PTR = VMEM_F(0);                                                  00304800
         IF VMEM_F(4) = VMEM_F(5) THEN REPEAT;                                  00304801
         OUTPUT = X10||'STMT#'||VMEM_H(14)||'-- LHS: '||HEX(VMEM_F(4),8)        00304900
            ||'  RHS: '||HEX(VMEM_F(5),8);                                      00305000
         PTR_INX = 2;                                                           00305100
         EXP_PTRS(1) = VMEM_F(5) | "80000000";                                  00305200
         EXP_PTRS(2) = VMEM_F(4) | "80000000";                                  00305300
         EXP_VARS(1),EXP_VARS(2) = 1;                                           00305400
         CALL FORMAT_CELL_TREE;                                                 00305500
      END;                                                                      00305600
   END PRINT_STMT_VARS;                                                         00305700
