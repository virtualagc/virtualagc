 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   CHARINDE.xpl
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
 /***************************************************************************/
                                                                                00628000
                                                                                00637010
 /*  SUBROUTINE TO FIND OCCURANCE OF ONE CHAR STRING IN ANOTHER.   */           00637020
CHAR_INDEX:                                                                     00637030
   PROCEDURE (STRING1,STRING2) BIT(16) ;                                        00637040
      DECLARE (STRING1,STRING2) CHARACTER, (L1,L2,I) FIXED;                     00637050
      L1 = LENGTH(STRING1);                                                     00637060
      L2 = LENGTH(STRING2);                                                     00637070
      IF L2>L1 THEN RETURN -1;                                                  00637080
      DO I = 0 TO L1-L2;                                                        00637090
         IF SUBSTR(STRING1,I,L2) = STRING2 THEN RETURN I;                       00637100
      END;                                                                      00637110
      RETURN -1;                                                                00637120
   END CHAR_INDEX;                                                              00637130
