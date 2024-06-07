 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NAMEORPA.xpl
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
 /* PROCEDURE NAME:  NAME_OR_PARM                                           */
 /* MEMBER NAME:     NAMEORPA                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          NAME_OR_PARM_FLAG                                              */
 /*          OPR                                                            */
 /*          SYM_FLAGS                                                      */
 /*          SYM_TAB                                                        */
 /*          SYT_FLAGS                                                      */
 /* CALLED BY:                                                              */
 /*          EXTN_CHECK                                                     */
 /*          FINAL_PASS                                                     */
 /*          FORM_TERM                                                      */
 /*          PUT_VM_INLINE                                                  */
 /***************************************************************************/
                                                                                01386000
 /* TRUE IF OPR(PTR) POINTS TO NAME OR INPUT/ASSIGN PARM*/                      01386010
NAME_OR_PARM:                                                                   01386020
   PROCEDURE(PTR) BIT(8);                                                       01386030
      DECLARE PTR BIT(16);                                                      01386040
      RETURN (SYT_FLAGS(SHR(OPR(PTR),16)) & NAME_OR_PARM_FLAG) ^= 0;            01386050
   END NAME_OR_PARM;                                                            01386060
