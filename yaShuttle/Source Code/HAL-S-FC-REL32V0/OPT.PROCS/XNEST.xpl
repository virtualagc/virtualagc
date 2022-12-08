 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   XNEST.xpl
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
 /* PROCEDURE NAME:  XNEST                                                  */
 /* MEMBER NAME:     XNEST                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          XNEST_MASK                                                     */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          PUT_SHAPING_ARGS                                               */
 /***************************************************************************/
                                                                                00568070
 /* RETURNS NEST UNSHIFTED*/                                                    00568080
XNEST:                                                                          00568090
   PROCEDURE(PTR);                                                              00568100
      DECLARE PTR BIT(16);                                                      00568110
      RETURN OPR(PTR) & XNEST_MASK;                                             00568120
   END XNEST;                                                                   00568130
