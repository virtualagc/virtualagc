 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   VALIDITY.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  VALIDITY                                               */
 /* MEMBER NAME:     VALIDITY                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          WD#               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          LEVEL                                                          */
 /*          REL                                                            */
 /*          SYM_REL                                                        */
 /*          SYM_SHRINK                                                     */
 /*          VAL_ARRAY                                                      */
 /*          VAL_TABLE                                                      */
 /*          VALIDITY_ARRAY                                                 */
 /* CALLED BY:                                                              */
 /*          ASSIGNMENT                                                     */
 /*          CSE_TAB_DUMP                                                   */
 /*          DUMP_VALIDS                                                    */
 /*          FLAG_V_N                                                       */
 /*          GET_NODE                                                       */
 /***************************************************************************/
                                                                                00638150
                                                                                00638160
 /* RETURNS VALIDITY_ARRAY BIT*/                                                00639000
VALIDITY:                                                                       00640000
   PROCEDURE(PTR) BIT(8);                                                       00641000
      DECLARE (PTR,WD#) BIT(16);                                                00642000
      PTR = REL(PTR);                                                           00642010
      WD# = SHR(PTR,5);                                                         00643000
      RETURN SHR(VALIDITY_ARRAY(WD#),PTR & "1F") & "1";                         00644000
   END VALIDITY;                                                                00645000
