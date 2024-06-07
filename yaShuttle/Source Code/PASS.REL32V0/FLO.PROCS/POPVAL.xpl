 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPVAL.xpl
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
 /* PROCEDURE NAME:  POPVAL                                                 */
 /* MEMBER NAME:     POPVAL                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_STMT_VARS                                                  */
 /*          PROCESS_EXTN                                                   */
 /*          PROCESS_HALMAT                                                 */
 /*          SCAN_INITIAL_LIST                                              */
 /*          TRAVERSE_INIT_LIST                                             */
 /***************************************************************************/
                                                                                00132800
POPVAL:                                                                         00132900
   PROCEDURE (CTR) BIT(16);                                                     00133000
      DECLARE CTR BIT(16);                                                      00133100
                                                                                00133200
      RETURN SHR(OPR(CTR),16);                                                  00133300
   END POPVAL;                                                                  00133400
