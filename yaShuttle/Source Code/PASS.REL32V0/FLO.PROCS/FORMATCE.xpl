 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   FORMATCE.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  FORMAT_CELL_TREE                                       */
 /* MEMBER NAME:     FORMATCE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          PTR_TYPE          BIT(8)                                       */
 /*          PTR               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXP_VARS                                                       */
 /*          EXP_PTRS                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          PTR_INX                                                        */
 /*          LEVEL                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          FORMAT_EXP_VARS_CELL                                           */
 /*          FORMAT_PF_INV_CELL                                             */
 /*          FORMAT_VAR_REF_CELL                                            */
 /* CALLED BY:                                                              */
 /*          PRINT_STMT_VARS                                                */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> FORMAT_CELL_TREE <==                                                */
 /*     ==> FORMAT_VAR_REF_CELL                                             */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FLUSH                                                       */
 /*         ==> STACK_PTR                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*     ==> FORMAT_EXP_VARS_CELL                                            */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FLUSH                                                       */
 /*         ==> STACK_PTR                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /*     ==> FORMAT_PF_INV_CELL                                              */
 /*         ==> LOCATE                                                      */
 /*         ==> HEX                                                         */
 /*         ==> FLUSH                                                       */
 /*         ==> STACK_PTR                                                   */
 /*             ==> ERRORS                                                  */
 /*                 ==> COMMON_ERRORS                                       */
 /***************************************************************************/
                                                                                00293100
 /* ROUTINE TO FORMAT AND PRINT A LINKED TREE OF VMEM CELLS */                  00293200
FORMAT_CELL_TREE:                                                               00293300
   PROCEDURE;                                                                   00293400
      DECLARE PTR_TYPE BIT(8), PTR FIXED;                                       00293500
                                                                                00293600
      DO WHILE PTR_INX > 0;                                                     00293700
         PTR = EXP_PTRS(PTR_INX);                                               00293800
         LEVEL = EXP_VARS(PTR_INX);                                             00293900
         PTR_INX = PTR_INX - 1;                                                 00294000
         PTR_TYPE = SHR(PTR,30) & 3;                                            00294100
         PTR = PTR & "3FFFFFFF";                                                00294200
         IF PTR ^= 0 THEN DO CASE PTR_TYPE;                                     00294300
            CALL FORMAT_VAR_REF_CELL(PTR);                                      00294400
            CALL FORMAT_PF_INV_CELL(PTR);                                       00294500
            CALL FORMAT_EXP_VARS_CELL(PTR);                                     00294600
            ;                                                                   00294700
         END;                                                                   00294800
      END;                                                                      00294900
   END FORMAT_CELL_TREE;                                                        00295000
