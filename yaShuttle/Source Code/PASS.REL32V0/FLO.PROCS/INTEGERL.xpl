 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INTEGERL.xpl
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
 /* PROCEDURE NAME:  INTEGER_LIT                                            */
 /* MEMBER NAME:     INTEGERL                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          CLASS_BI                                                       */
 /*          DW                                                             */
 /*          LIT_PG                                                         */
 /*          LITERAL2                                                       */
 /*          LITERAL3                                                       */
 /*          LIT2                                                           */
 /*          LIT3                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERRORS                                                         */
 /*          GET_LITERAL                                                    */
 /*          INTEGERIZABLE                                                  */
 /* CALLED BY:                                                              */
 /*          GET_VAR_REF_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> INTEGER_LIT <==                                                     */
 /*     ==> ERRORS                                                          */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> GET_LITERAL                                                     */
 /*     ==> INTEGERIZABLE                                                   */
 /***************************************************************************/
                                                                                00180100
 /* RETURNS SUBSCRIPT LITERAL VALUE */                                          00180200
INTEGER_LIT:                                                                    00180300
   PROCEDURE (PTR) BIT(16);                                                     00180400
      DECLARE PTR BIT(16);                                                      00180500
                                                                                00180600
      PTR = GET_LITERAL(PTR);                                                   00180700
      DW(0) = LIT2(PTR);                                                        00180800
      DW(1) = LIT3(PTR);                                                        00180900
      IF ^INTEGERIZABLE THEN DO;                                                00181000
         CALL ERRORS (CLASS_BI, 205);                                           00181100
         RETURN 0;                                                              00181200
      END;                                                                      00181300
      RETURN DW(3);                                                             00181400
   END INTEGER_LIT;                                                             00181500
