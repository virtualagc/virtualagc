 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   GENERATE.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  GENERATE_TEMPLATE_LIT                                  */
 /* MEMBER NAME:     GENERATE                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          CONST_DW                                                       */
 /*          DW                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          SAVE_LITERAL                                                   */
 /* CALLED BY:                                                              */
 /*          TEMPLATE_LIT                                                   */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> GENERATE_TEMPLATE_LIT <==                                           */
 /*     ==> SAVE_LITERAL                                                    */
 /*         ==> ERRORS                                                      */
 /*             ==> COMMON_ERRORS                                           */
 /*         ==> GET_LITERAL                                                 */
 /***************************************************************************/
                                                                                00826010
 /* GENERATES TEMPLATE PTR IN LIT TABLE*/                                       00826020
GENERATE_TEMPLATE_LIT:                                                          00826030
   PROCEDURE(PTR) BIT(16);                                                      00826040
      DECLARE PTR BIT(16);                                                      00826050
      DW(0) = PTR;                                                              00826060
      DW(1) = 0;                                                                00826070
      RETURN SAVE_LITERAL(0,1,0,1,3);                                           00826080
   END GENERATE_TEMPLATE_LIT;                                                   00826090
