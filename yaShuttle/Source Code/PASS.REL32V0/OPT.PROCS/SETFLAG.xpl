 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETFLAG.xpl
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
 /* PROCEDURE NAME:  SET_FLAG                                               */
 /* MEMBER NAME:     SETFLAG                                                */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /*          BIT#              BIT(8)                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FLAG                                                           */
 /* CALLED BY:                                                              */
 /*          FLAG_V_N                                                       */
 /*          FLAG_NODE                                                      */
 /*          FLAG_VAC_OR_LIT                                                */
 /***************************************************************************/
                                                                                02624000
 /* SETS FLAGS */                                                               02625000
SET_FLAG:                                                                       02626000
   PROCEDURE(PTR,BIT#);                                                         02627000
      DECLARE PTR BIT(16),BIT# BIT(8);                                          02628000
      FLAG(PTR) = FLAG(PTR) | SHL(1,BIT#);                                      02629000
      BIT# = 0;                                                                 02630000
   END SET_FLAG;                                                                02631000
