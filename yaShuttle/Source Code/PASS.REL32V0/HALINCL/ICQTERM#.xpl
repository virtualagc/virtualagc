 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ICQTERM#.xpl
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
 
ICQ_TERM#:                                                                      00000100
   PROCEDURE (LOC) FIXED;                                                       00000200
      DECLARE (LOC,I) FIXED;                                                    00000300
      IF NAME_IMPLIED THEN RETURN 1;                                            00000400
      IF SYT_TYPE(LOC)=VEC_TYPE THEN RETURN VAR_LENGTH(LOC);                    00000500
      IF SYT_TYPE(LOC)=MAT_TYPE THEN DO;                                        00000600
         I=VAR_LENGTH(LOC)&"FF";                                                00000700
         LOC=SHR(VAR_LENGTH(LOC),8);                                            00000800
         RETURN LOC*I;                                                          00000900
      END;                                                                      00001000
      IF SYT_TYPE(LOC)=MAJ_STRUC THEN DO;                                       00001100
         LOC=SYT_ADDR(VAR_LENGTH(LOC));                                         00001200
         IF LOC>0 THEN RETURN LOC;                                              00001300
      END;                                                                      00001400
      RETURN 1;                                                                 00001500
   END ICQ_TERM#;                                                               00001600
