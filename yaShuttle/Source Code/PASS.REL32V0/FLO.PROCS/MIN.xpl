 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MIN.xpl
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
 /* PROCEDURE NAME:  MIN                                                    */
 /* MEMBER NAME:     MIN                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          A                 BIT(16)                                      */
 /*          B                 BIT(16)                                      */
 /* CALLED BY:                                                              */
 /*          ADD_SMRK_NODE                                                  */
 /***************************************************************************/
                                                                                00131158
 /* FUNCTION TO RETURN THE LESSER OF TWO EVILS */                               00131168
MIN:                                                                            00131178
   PROCEDURE(A,B) BIT(16);                                                      00131188
      DECLARE (A,B) BIT(16);                                                    00131198
      IF A<B THEN RETURN A;                                                     00131208
      ELSE RETURN B;                                                            00131218
   END MIN;                                                                     00131228
