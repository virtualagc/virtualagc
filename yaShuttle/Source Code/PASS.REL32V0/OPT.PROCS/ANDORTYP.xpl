 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ANDORTYP.xpl
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
 /* PROCEDURE NAME:  ANDOR_TYPE                                             */
 /* MEMBER NAME:     ANDORTYP                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          BIT(8)                                                         */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          OR                                                             */
 /*          OPR                                                            */
 /*          XCAND                                                          */
 /*          XCOR                                                           */
 /* CALLED BY:                                                              */
 /*          TAG_CONDITIONALS                                               */
 /***************************************************************************/
                                                                                02271000
                                                                                02279000
 /* CHECKS IF CAND OR COR OPERATOR*/                                            02280000
ANDOR_TYPE:                                                                     02281000
   PROCEDURE(PTR) BIT(8);                                                       02282000
      DECLARE PTR BIT(16);                                                      02283000
      PTR = OPR(PTR) & "FFF1";                                                  02284000
      RETURN PTR = XCAND   OR    PTR = XCOR;                                    02285000
   END ANDOR_TYPE;                                                              02286000
