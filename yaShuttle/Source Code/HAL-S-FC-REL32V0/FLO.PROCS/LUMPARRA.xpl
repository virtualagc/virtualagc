 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   LUMPARRA.xpl
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
 /* PROCEDURE NAME:  LUMP_ARRAYSIZE                                         */
 /* MEMBER NAME:     LUMPARRA                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          OP                BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          J                 BIT(16)                                      */
 /*          ACC               FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          EXT_ARRAY                                                      */
 /*          SYM_ARRAY                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_ARRAY                                                      */
 /* CALLED BY:                                                              */
 /*          STRUCTURE_WALK                                                 */
 /***************************************************************************/
                                                                                00150594
 /* ROUTINE FOR GETTING TOTAL ARRAY SIZE IN A BIG LUMP */                       00150604
LUMP_ARRAYSIZE:                                                                 00150614
   PROCEDURE (OP) FIXED;                                                        00150700
      DECLARE (OP,J) BIT(16), ACC FIXED;                                        00150800
                                                                                00150900
      ACC = 1;                                                                  00151000
      IF SYT_ARRAY(OP) > 0 THEN                                                 00151100
         DO J = SYT_ARRAY(OP)+1 TO EXT_ARRAY(SYT_ARRAY(OP))+SYT_ARRAY(OP);      00151200
         ACC = EXT_ARRAY(J) * ACC;                                              00151300
      END;                                                                      00151400
      RETURN ACC;                                                               00151500
   END LUMP_ARRAYSIZE;                                                          00151600
