 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DETAG.xpl
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
 /* PROCEDURE NAME:  DETAG                                                  */
 /* MEMBER NAME:     DETAG                                                  */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          RELOCATE_HALMAT                                                */
 /***************************************************************************/
                                                                                01417000
 /* REMOVE HALMAT TAG*/                                                         01418000
DETAG:                                                                          01419000
   PROCEDURE(PTR);                                                              01420000
      DECLARE PTR BIT(16);                                                      01421000
      IF WATCH THEN OUTPUT = 'DETAG: '||PTR;                                    01422000
      OPR(PTR) = OPR(PTR) & "FFFFFFF7";                                         01423000
   END DETAG;                                                                   01424000
