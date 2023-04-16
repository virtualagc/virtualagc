 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   TWINHALM.xpl
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
 /* PROCEDURE NAME:  TWIN_HALMATTED                                         */
 /* MEMBER NAME:     TWINHALM                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          OP                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          AND                                                            */
 /*          FALSE                                                          */
 /*          OPR                                                            */
 /*          SINCOS                                                         */
 /*          TWIN#                                                          */
 /*          XBFNC                                                          */
 /* CALLED BY:                                                              */
 /*          RELOCATE_HALMAT                                                */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
                                                                                01197000
                                                                                01198000
 /* CHECKS PTR TO SEE IF ARTIFICIAL TWIN_HALMAT OPERATOR*/                      01199000
TWIN_HALMATTED:                                                                 01200000
   PROCEDURE(PTR) BIT(8);                                                       01201000
      DECLARE PTR BIT(16);                                                      01202000
      DECLARE OP FIXED;                                                         01203000
      OP = OPR(PTR);                                                            01204000
      IF (OP & "FFF1") ^= XBFNC THEN RETURN FALSE;                              01205000
      RETURN OP >= SINCOS AND OP < SINCOS + TWIN#;                              01206000
   END TWIN_HALMATTED;                                                          01207000
