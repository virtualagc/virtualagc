 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETHALMA.xpl
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
 /* PROCEDURE NAME:  SET_HALMAT_FLAG                                        */
 /* MEMBER NAME:     SETHALMA                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          WATCH                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          OPR                                                            */
 /* CALLED BY:                                                              */
 /*          COLLECT_MATCHES                                                */
 /*          REARRANGE_HALMAT                                               */
 /***************************************************************************/
                                                                                02632000
                                                                                02633000
 /* FLAGS HALMAT*/                                                              02634000
SET_HALMAT_FLAG:                                                                02635000
   PROCEDURE(PTR);                                                              02636000
      DECLARE PTR BIT(16);                                                      02637000
      IF WATCH THEN OUTPUT = '   SET_HALMAT_FLAG:  ' || PTR;                    02638000
      OPR(PTR) = OPR(PTR) | "8";                                                02639000
   END SET_HALMAT_FLAG;                                                         02640000
