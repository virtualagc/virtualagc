 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ICQARRAY.xpl
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
 
ICQ_ARRAY#:                                                                     00000100
   PROCEDURE (LOC) FIXED;                                                       00000200
      DECLARE LOC BIT(16), I FIXED;                                             00000300
      IF NAME_IMPLIED THEN RETURN 1;                                            00000400
      I=1;                                                                      00000500
      IF SYT_ARRAY(LOC)^=0 THEN DO LOC=SYT_ARRAY(LOC)+1 TO                      00000600
                          SYT_ARRAY(LOC)+EXT_ARRAY(SYT_ARRAY(LOC));             00000700
         I=EXT_ARRAY(LOC)*I;                                                    00000800
      END;                                                                      00000900
      RETURN I;                                                                 00001000
   END ICQ_ARRAY#;                                                              00001100
