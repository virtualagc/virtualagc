 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SETDUPLF.xpl
    Purpose:    Part of the HAL/S-FC compiler.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section TBD.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
SET_DUPL_FLAG:                                                                  00000100
   PROCEDURE(DUPL_TERM);                                                        00000200
      DECLARE DUPL_TERM BIT(16);                                                00000300
      DECLARE J BIT(16);                                                        00000400
      J = DUPL_TERM;                                                            00000500
      DO WHILE SYT_TYPE(J) ^= TEMPL_NAME;                                       00000600
         J = J - 1;                                                             00000700
      END;                                                                      00000800
      SYT_FLAGS(J) = SYT_FLAGS(J) | DUPL_FLAG;                                  00000900
      IF SYT_PTR(J) > 0 THEN DO;                                                00001000
         SYT_PTR(J) = 0;                                                        00001100
         CALL ERROR(CLASS_DQ, 7, SYT_NAME(DUPL_TERM));                          00001200
      END;                                                                      00001300
      RETURN;                                                                   00001400
   END SET_DUPL_FLAG;                                                           00001500
