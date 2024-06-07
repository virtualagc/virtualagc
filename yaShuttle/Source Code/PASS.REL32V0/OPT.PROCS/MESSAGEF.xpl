 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MESSAGEF.xpl
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
 /* PROCEDURE NAME:  MESSAGE_FORMAT                                         */
 /* MEMBER NAME:     MESSAGEF                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* INPUT PARAMETERS:                                                       */
 /*          WORD              FIXED                                        */
 /* LOCAL DECLARATIONS:                                                     */
 /*          MSG               CHARACTER;                                   */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          COMBINED_LITERALS                                              */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> MESSAGE_FORMAT <==                                                  */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                00668080
                                                                                00669000
 /* FORMAT CSE WORD */                                                          00670000
MESSAGE_FORMAT:                                                                 00671000
   PROCEDURE(WORD) CHARACTER;                                                   00672000
      DECLARE WORD FIXED;                                                       00673000
      DECLARE MSG CHARACTER;                                                    00674000
      MSG=HEX(WORD,8);                                                          00675000
      RETURN '  '  || MSG;                                                      00676000
   END MESSAGE_FORMAT;                                                          00677000
