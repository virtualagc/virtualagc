 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENTER.xpl
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
 /* PROCEDURE NAME:  ENTER                                                  */
 /* MEMBER NAME:     ENTER                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LIST_CSE                                                       */
 /*          CSE_LIST                                                       */
 /*          TRACE                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CSE_L_INX                                                      */
 /*          COMMONSE_LIST                                                  */
 /* CALLED BY:                                                              */
 /*          MOVECODE                                                       */
 /*          PUSH_HALMAT                                                    */
 /*          PUSH_OPERAND                                                   */
 /*          SET_VAC_REF                                                    */
 /*          SWITCH                                                         */
 /***************************************************************************/
                                                                                00900000
                                                                                00900230
 /* ENTERS POINTER INTO CSE_LIST*/                                              00901000
ENTER:                                                                          00902000
   PROCEDURE(PTR);                                                              00903000
      DECLARE PTR BIT(16);                                                      00904000
      IF TRACE THEN OUTPUT = 'ENTER: '||PTR;                                    00905000
      CSE_L_INX = CSE_L_INX + 1;                                                00906000
      DO WHILE CSE_L_INX >= RECORD_TOP(COMMONSE_LIST);                          00906010
         NEXT_ELEMENT(COMMONSE_LIST);                                           00906020
      END;                                                                      00906030
      CSE_LIST(CSE_L_INX) = PTR;                                                00907000
   END ENTER;                                                                   00908000
