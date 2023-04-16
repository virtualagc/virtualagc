 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TYPEBITS.xpl
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
 /* PROCEDURE NAME:  TYPE_BITS                                              */
 /* MEMBER NAME:     TYPEBITS                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          CTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          ADD_SMRK_NODE                                                  */
 /*          GET_NAME_INITIALS                                              */
 /*          GET_P_F_INV_CELL                                               */
 /*          GET_STMT_VARS                                                  */
 /*          GET_VAR_REF_CELL                                               */
 /*          PROCESS_EXTN                                                   */
 /*          PROCESS_HALMAT                                                 */
 /*          SCAN_INITIAL_LIST                                              */
 /*          SEARCH_EXPRESSION                                              */
 /*          TRAVERSE_INIT_LIST                                             */
 /***************************************************************************/
                                                                                00134200
TYPE_BITS:                                                                      00134300
   PROCEDURE (CTR) BIT(8);                                                      00134400
      DECLARE CTR BIT(16);                                                      00134500
                                                                                00134600
      RETURN SHR(OPR(CTR),4) & "F";                                             00134700
   END TYPE_BITS;                                                               00134800
