 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MAX.xpl
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
 /* PROCEDURE NAME:  MAX                                                    */
 /* MEMBER NAME:     MAX                                                    */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          FIXED                                                          */
 /* INPUT PARAMETERS:                                                       */
 /*          I                 FIXED                                        */
 /*          J                 FIXED                                        */
 /* CALLED BY:                                                              */
 /*          COMPRESS_OUTER_REF                                             */
 /*          END_ANY_FCN                                                    */
 /*          OUTPUT_WRITER                                                  */
 /*          STREAM                                                         */
 /***************************************************************************/
                                                                                00262200
MAX:PROCEDURE(I,J) FIXED;                                                       00262300
      DECLARE (I,J) FIXED;                                                      00262400
      IF I>J THEN RETURN I;                                                     00262500
      RETURN J;                                                                 00262600
   END MAX;                                                                     00262700
