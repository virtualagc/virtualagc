 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   MAX.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  MAX                                                    */
/* MEMBER NAME:     MAX                                                    */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          VAL1              FIXED                                        */
/*          VAL2              FIXED                                        */
/* CALLED BY:                                                              */
/*          GET_LITERAL                                                    */
/*          GENERATE                                                       */
/*          INITIALISE                                                     */
/***************************************************************************/
 /* MAX FUNCTION  */                                                            00560000
MAX:                                                                            00560500
   PROCEDURE(VAL1, VAL2) FIXED;                                                 00561000
      DECLARE (VAL1, VAL2) FIXED;                                               00561500
      IF VAL1 > VAL2 THEN RETURN VAL1;                                          00562000
      RETURN VAL2;                                                              00562500
   END MAX;                                                                     00563000
