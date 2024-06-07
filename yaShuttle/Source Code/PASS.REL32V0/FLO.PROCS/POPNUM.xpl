 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPNUM.xpl
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
 /* PROCEDURE NAME:  POPNUM                                                 */
 /* MEMBER NAME:     POPNUM                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          GET_VAR_REF_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          PROCESS_EXTN                                                   */
 /***************************************************************************/
                                                                                00131388
 /* ROUTINES FOR DECODING HALMAT WORDS */                                       00131398
                                                                                00131408
POPNUM:                                                                         00131500
   PROCEDURE (CTR) BIT(8);                                                      00131600
      DECLARE CTR BIT(16);                                                      00131700
                                                                                00131800
      RETURN SHR(OPR(CTR),16) & "FF";                                           00131900
   END POPNUM;                                                                  00132000
