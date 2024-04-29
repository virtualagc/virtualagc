 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   POPTAG.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  POPTAG                                                 */
/* MEMBER NAME:     POPTAG                                                 */
/* INPUT PARAMETERS:                                                       */
/*          CTR               BIT(16)                                      */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          CONST_ATOMS                                                    */
/*          FOR_ATOMS                                                      */
/*          OPR                                                            */
/* CALLED BY:                                                              */
/*          DECODEPOP                                                      */
/*          GENERATE                                                       */
/*          OPTIMISE                                                       */
/***************************************************************************/
                                                                                  620640
POPTAG:                                                                           620650
   PROCEDURE(CTR);                                                                620660
      DECLARE CTR BIT(16);                                                        620670
      RETURN SHR(OPR(CTR),24) & "FF";                                             620680
   END POPTAG;                                                                    620690
