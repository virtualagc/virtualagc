 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NOTTYPE.xpl
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
 /* PROCEDURE NAME:  NOT_TYPE                                               */
 /* MEMBER NAME:     NOTTYPE                                                */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          XCNOT                                                          */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          TAG_CONDITIONALS                                               */
 /***************************************************************************/
                                                                                02264000
 /* CHECKS IF CNOT OPERATOR*/                                                   02265000
NOT_TYPE:                                                                       02266000
   PROCEDURE(PTR) BIT(8);                                                       02267000
      DECLARE PTR BIT(16);                                                      02268000
      RETURN (OPR(PTR) & "FFF1") = XCNOT;                                       02269000
   END NOT_TYPE;                                                                02270000
