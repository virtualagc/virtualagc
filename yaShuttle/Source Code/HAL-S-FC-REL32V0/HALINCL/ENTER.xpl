 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENTER.xpl
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
 
/***********************************************************/                   00006000
/*                                                         */                   00007000
/*  REVISION HISTORY                                       */                   00008000
/*                                                         */                   00009000
/*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                   00009100
/*                                                         */                   00009200
/*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                   00009300
/*                                                         */                   00009400
/***********************************************************/                   00009500
ENTER:                                                                          00000010
   PROCEDURE (NAME, CLASS);                                                     00000020
      DECLARE CLASS FIXED, NAME CHARACTER;                                      00000030
                                                                                00000040
      NDECSY = NDECSY + 1;     /*  DON'T OCCUPY LAST SLOT  */                   00000050
      NEXT_ELEMENT(SYM_TAB);                                                    00000060
/* CR11088 11/90 RAH - DELETED NEXT_ELEMENT(DOWN_INFO) FROM THIS SPOT */        00000060
      NEXT_ELEMENT(LINK_SORT);                                                  00000070
      SYT_NAME(NDECSY) = NAME;                                                  00000080
      SYT_CLASS(NDECSY) = CLASS;                                                00000090
      SYT_SCOPE(NDECSY) = SCOPE#;                                               00000100
      SYT_NEST(NDECSY) = NEST;                                                  00000110
      SYT_XREF(NDECSY) = ENTER_XREF(0, 0);                                      00000120
      IF CLASS=REPL_ARG_CLASS THEN RETURN NDECSY;                               00000130
      SYT_HASHLINK(NDECSY) = SYT_HASHSTART(NAME_HASH);                          00000140
      SYT_HASHSTART(NAME_HASH) = NDECSY;                                        00000150
      RETURN NDECSY;                                                            00000160
   END;                                                                         00000170
