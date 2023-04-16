 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CS.xpl
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
/* PROCEDURE NAME:  CS                                                     */
/* MEMBER NAME:     CS                                                     */
/* FUNCTION RETURN TYPE:                                                   */
/*          FIXED                                                          */
/* INPUT PARAMETERS:                                                       */
/*          LEN               FIXED                                        */
/* CALLED BY:                                                              */
/*          EMITSTRING                                                     */
/*          GENERATE                                                       */
/*          INITIALISE                                                     */
/***************************************************************************/
                                                                                00707500
 /* ROUTINE TO GIVE CORE REQUIREMENTS FOR CHARACTER STRING */                   00708000
CS:                                                                             00708500
   PROCEDURE(LEN) FIXED;                                                        00709000
      DECLARE LEN FIXED;                                                        00709500
      RETURN SHR(LEN+1, 1);                                                     00710000
   END CS;                                                                      00710500
