 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETVAR.xpl
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
 /* PROCEDURE NAME:  SET_VAR                                                */
 /* MEMBER NAME:     SETVAR                                                 */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(16)                                                        */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          SYM_TAB                                                        */
 /*          OPR                                                            */
 /*          SYM_TYPE                                                       */
 /*          SYT_TYPE                                                       */
 /*          XXPT                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          VAR                                                            */
 /*          VAR_TYPE                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          XHALMAT_QUAL                                                   */
 /*          LAST_OPERAND                                                   */
 /* CALLED BY:                                                              */
 /*          CHECK_ARRAYNESS                                                */
 /*          EXPAND_DSUB                                                    */
 /*          GET_LOOP_DIMENSION                                             */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> SET_VAR <==                                                         */
 /*     ==> XHALMAT_QUAL                                                    */
 /*     ==> LAST_OPERAND                                                    */
 /***************************************************************************/
                                                                                01496200
 /* SETS VAR,VAR_TYPE */                                                        01496210
SET_VAR:                                                                        01496220
   PROCEDURE(PTR) BIT(16);                                                      01496230
      DECLARE PTR BIT(16);                                                      01496240
      IF XHALMAT_QUAL(PTR) = XXPT THEN                                          01496250
         PTR = LAST_OPERAND(SHR(OPR(PTR),16));                                  01496260
      VAR = SHR(OPR(PTR),16);                                                   01496270
      VAR_TYPE = SYT_TYPE(VAR);                                                 01496280
   END SET_VAR;                                                                 01496290
