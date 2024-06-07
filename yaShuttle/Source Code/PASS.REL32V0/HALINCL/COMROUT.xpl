 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   COMROUT.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
   /* ROUTINE TO PAD STRINGS WITH BLANKS TO A FIXED LENGTH */
PAD:
   PROCEDURE(STRING,WIDTH) CHARACTER;
      DECLARE STRING CHARACTER, (WIDTH,L) FIXED;
      DECLARE X72 CHARACTER INITIAL
 ('                                                                        ');
      L = LENGTH(STRING);
      IF L >= WIDTH THEN RETURN STRING;
      ELSE RETURN STRING || SUBSTR(X72, 72 + L - WIDTH);
   END PAD;
CHAR_INDEX:
   PROCEDURE(STRING1, STRING2);
      DECLARE (STRING1, STRING2) CHARACTER, (L1, L2, I) FIXED;
      L1 = LENGTH(STRING1);
      L2 = LENGTH(STRING2);
      IF L2 > L1 THEN
         RETURN -1;
      DO I = 0 TO L1 - L2;
         IF SUBSTR(STRING1, I, L2) = STRING2 THEN
            RETURN I;
      END;
      RETURN -1;
   END CHAR_INDEX;
