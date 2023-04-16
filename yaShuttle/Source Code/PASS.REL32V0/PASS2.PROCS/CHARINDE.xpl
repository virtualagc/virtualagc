 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARINDE.xpl
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
/* PROCEDURE NAME:  CHAR_INDEX                                             */
/* MEMBER NAME:     CHARINDE                                               */
/* FUNCTION RETURN TYPE:                                                   */
/*          BIT(16)                                                        */
/* INPUT PARAMETERS:                                                       */
/*          STRING1           CHARACTER;                                   */
/*          STRING2           CHARACTER;                                   */
/* LOCAL DECLARATIONS:                                                     */
/*          L1                FIXED                                        */
/*          I                 FIXED                                        */
/*          L2                FIXED                                        */
/* CALLED BY:                                                              */
/*          INITIALISE                                                     */
/*          GENERATE                                                       */
/*          INSTRUCTION                                                    */
/*          PROGNAME                                                       */
/***************************************************************************/
                                                                                00567500
 /*  SUBROUTINE TO FIND OCCURANCE OF ONE CHAR STRING IN ANOTHER.   */           00568000
CHAR_INDEX:                                                                     00568500
   PROCEDURE (STRING1,STRING2) BIT(16) ;                                        00569000
      DECLARE (STRING1,STRING2) CHARACTER, (L1,L2,I) FIXED;                     00569500
      L1 = LENGTH(STRING1);                                                     00570000
      L2 = LENGTH(STRING2);                                                     00570500
      IF L2>L1 THEN RETURN -1;                                                  00571000
      DO I = 0 TO L1-L2;                                                        00571500
         IF SUBSTR(STRING1,I,L2) = STRING2 THEN RETURN I;                       00572000
      END;                                                                      00572500
      RETURN -1;                                                                00573000
   END CHAR_INDEX;                                                              00573500
