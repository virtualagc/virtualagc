 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENTERLAY.xpl
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
 
ENTER_LAYOUT:                                                                   00000100
   PROCEDURE(NDX);                                                              00000200
      DECLARE NDX BIT(16);                                                      00000300
         PROGRAM_LAYOUT_INDEX = PROGRAM_LAYOUT_INDEX + 1;                       00000400
         IF PROGRAM_LAYOUT_INDEX > PROGRAM_LAYOUT_LIM THEN DO;                  00000500
            PROGRAM_LAYOUT_INDEX = PROGRAM_LAYOUT_LIM;                          00000600
            CALL ERROR(CLASS_P,6);                                              00000700
         END;                                                                   00000800
         ELSE PROGRAM_LAYOUT(PROGRAM_LAYOUT_INDEX) = NDX;                       00000900
      RETURN;                                                                   00001000
   END ENTER_LAYOUT;                                                            00001100
