 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LUMPTERM.xpl
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
 /* PROCEDURE NAME:  LUMP_TERMINALSIZE                                      */
 /* MEMBER NAME:     LUMPTERM                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          OP                BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MATRIX                                                         */
 /*          SYM_LENGTH                                                     */
 /*          SYM_TAB                                                        */
 /*          SYM_TYPE                                                       */
 /*          SYT_DIMS                                                       */
 /*          SYT_TYPE                                                       */
 /*          VECTOR                                                         */
 /* CALLED BY:                                                              */
 /*          STRUCTURE_WALK                                                 */
 /***************************************************************************/
                                                                                00151700
 /* ROUTINE TO LUMP THE NUMBER OF ITEMS IN A TERMINAL SYMBOL */                 00151800
LUMP_TERMINALSIZE:                                                              00151900
   PROCEDURE(OP) FIXED;                                                         00152000
      DECLARE OP BIT(16);                                                       00152100
      IF SYT_TYPE(OP) = VECTOR THEN                                             00152200
         RETURN SYT_DIMS(OP) & "FF";                                            00152201
      IF SYT_TYPE(OP) = MATRIX THEN                                             00152202
         RETURN SHR(SYT_DIMS(OP),8) * (SYT_DIMS(OP) & "FF");                    00152300
      RETURN 1;                                                                 00152400
   END LUMP_TERMINALSIZE;                                                       00152500
