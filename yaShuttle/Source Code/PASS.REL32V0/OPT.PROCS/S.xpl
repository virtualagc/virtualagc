 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   S.xpl
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
 /* PROCEDURE NAME:  S                                                      */
 /* MEMBER NAME:     S                                                      */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          NO                BIT(16)                                      */
 /* CALLED BY:                                                              */
 /*          FINAL_PASS                                                     */
 /*          CHICKEN_OUT                                                    */
 /***************************************************************************/
                                                                                00668000
 /* PLEURALIZES*/                                                               00668010
S:                                                                              00668020
   PROCEDURE(NO) CHARACTER;                                                     00668030
      DECLARE NO BIT(16);                                                       00668040
      IF NO = 1 THEN RETURN '';                                                 00668050
      ELSE RETURN 'S';                                                          00668060
   END S;                                                                       00668070
