 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MIN.xpl
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
/* PROCEDURE NAME:  MIN                                                    */
/* MEMBER NAME:     MIN                                                    */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          VAL1              FIXED                                        */
/*          VAL2              FIXED                                        */
/* CALLED BY:                                                              */
/*          GENERATE                                                       */
/*          OBJECT_GENERATOR                                               */
/***************************************************************************/
                                                                                00563500
 /* MIN FUNCTION  */                                                            00564000
MIN:                                                                            00564500
   PROCEDURE(VAL1, VAL2) FIXED;                                                 00565000
      DECLARE (VAL1, VAL2) FIXED;                                               00565500
      IF VAL1 < VAL2 THEN RETURN VAL1;                                          00566000
      RETURN VAL2;                                                              00566500
   END MIN;                                                                     00567000
