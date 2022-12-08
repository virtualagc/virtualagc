 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMPARET.xpl
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
 /* PROCEDURE NAME:  COMPARE_TYPE                                           */
 /* MEMBER NAME:     COMPARET                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          OPR                                                            */
 /*          XBNEQ                                                          */
 /*          XILT                                                           */
 /* CALLED BY:                                                              */
 /*          TAG_CONDITIONALS                                               */
 /***************************************************************************/
                                                                                02295000
 /* CHECKS IF CLASS 7 OPERATOR OTHER THAN CAND,COR,CNOT*/                       02296000
COMPARE_TYPE:                                                                   02297000
   PROCEDURE(PTR) BIT(8);                                                       02298000
      DECLARE PTR BIT(16);                                                      02299000
      PTR = OPR(PTR) & "FFF1";                                                  02300000
      RETURN PTR >= XBNEQ AND PTR <= XILT;                                      02301000
   END COMPARE_TYPE;                                                            02302000
