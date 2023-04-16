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
 /* INPUT PARAMETERS:                                                       */
 /*          STRING1           CHARACTER;                                   */
 /*          STRING2           CHARACTER;                                   */
 /* LOCAL DECLARATIONS:                                                     */
 /*          L1                FIXED                                        */
 /*          I                 FIXED                                        */
 /*          L2                FIXED                                        */
 /* CALLED BY:                                                              */
 /*          OUTPUT_WRITER                                                  */
 /*          STREAM                                                         */
 /***************************************************************************/
                                                                                00261592
CHAR_INDEX:                                                                     00261593
   PROCEDURE(STRING1, STRING2);                                                 00261594
      DECLARE (STRING1, STRING2) CHARACTER, (L1, L2, I) FIXED;                  00261595
      L1 = LENGTH(STRING1);                                                     00261596
      L2 = LENGTH(STRING2);                                                     00261597
      IF L2 > L1 THEN                                                           00261598
         RETURN -1;                                                             00261599
      DO I = 0 TO L1 - L2;                                                      00261600
         IF SUBSTR(STRING1, I, L2) = STRING2 THEN                               00261601
            RETURN I;                                                           00261602
      END;                                                                      00261603
      RETURN -1;                                                                00261604
   END CHAR_INDEX;                                                              00261605
