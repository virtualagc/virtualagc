 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   XBITS.xpl
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
 /* PROCEDURE NAME:  X_BITS                                                 */
 /* MEMBER NAME:     XBITS                                                  */
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
                                                                                00134900
X_BITS:                                                                         00135000
   PROCEDURE (CTR) BIT(8);                                                      00135100
      DECLARE CTR BIT(16);                                                      00135200
                                                                                00135300
      RETURN SHR(OPR(CTR),1) & "0007";                                          00135400
   END X_BITS;                                                                  00135500
