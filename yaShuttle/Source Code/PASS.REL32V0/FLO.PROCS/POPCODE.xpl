 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPCODE.xpl
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
 /* PROCEDURE NAME:  POPCODE                                                */
 /* MEMBER NAME:     POPCODE                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          ADD_SMRK_NODE                                                  */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          PROCESS_HALMAT                                                 */
 /*          SCAN_INITIAL_LIST                                              */
 /*          SEARCH_EXPRESSION                                              */
 /*          TRAVERSE_INIT_LIST                                             */
 /***************************************************************************/
                                                                                00132100
POPCODE:                                                                        00132200
   PROCEDURE (CTR) BIT(16);                                                     00132300
      DECLARE CTR BIT(16);                                                      00132400
                                                                                00132500
      RETURN SHR(OPR(CTR),4) & "FFF";                                           00132600
   END POPCODE;                                                                 00132700
