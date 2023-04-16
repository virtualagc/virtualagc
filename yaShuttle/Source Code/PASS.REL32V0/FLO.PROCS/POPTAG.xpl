 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPTAG.xpl
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
 /* PROCEDURE NAME:  POPTAG                                                 */
 /* MEMBER NAME:     POPTAG                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          GET_STMT_VARS                                                  */
 /***************************************************************************/
                                                                                00133500
POPTAG:                                                                         00133600
   PROCEDURE (CTR) BIT(8);                                                      00133700
      DECLARE CTR BIT(16);                                                      00133800
                                                                                00133900
      RETURN SHR(OPR(CTR),24) & "FF";                                           00134000
   END POPTAG;                                                                  00134100
