 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DTOKEN.xpl
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
 
   /* ROUTINE TO PICK OUT TOKENS FROM A DIRECTIVE CARD.            */           00000100
   /* IF D_CONTINUATION_OK IS TRUE, THEN IF NO TOKEN EXISTS ON THE */           00000200
   /*   CURRENT RECORD, D_TOKEN WILL GET THE NEXT RECORD AND       */           00000300
   /*   IF THAT RECORD IS ALSO A DIRECTIVE, RETURN THE FIRST       */           00000400
   /*   TOKEN FROM IT.                                             */           00000500
   /* D_TOKEN RETURNS THE TOKEN FOUND                              */           00000600
D_TOKEN:                                                                        00000700
   PROCEDURE CHARACTER;                                                         00000800
      DECLARE (I,J) BIT(16);                                                    00000900
      DECLARE #SPECIALS LITERALLY '3',                                          00001000
              SPECIALS CHARACTER CONSTANT(' ,:;');                              00001100
BLANKS:                                                                         00001200
      DO FOREVER;                                                               00001300
         DO WHILE (BYTE(CURRENT_CARD,D_INDEX) = BYTE(' ')) &                    00001400
            (D_INDEX <= TEXT_LIMIT);                                            00001500
            D_INDEX = D_INDEX + 1;                                              00001600
         END;                                                                   00001700
         IF D_INDEX <= TEXT_LIMIT THEN                                          00001800
            ESCAPE BLANKS;                                                      00001900
         IF D_CONTINUATION_OK THEN DO;  /* GET NEXT RECORD */                   00002000
            CALL NEXT_RECORD;                                                   00002100
            IF CARD_TYPE(BYTE(CURRENT_CARD)) ^= CARD_TYPE(BYTE('D')) THEN DO;   00002200
               LOOKED_RECORD_AHEAD = TRUE;                                      00002300
               D_CONTINUATION_OK = FALSE;                                       00002400
               RETURN '';                                                       00002500
            END;                                                                00002600
            BYTE(CURRENT_CARD) = BYTE('D');                                     00002700
            CALL PRINT_COMMENT(TRUE);                                           00002800
            D_INDEX = 1;                                                        00002900
            REPEAT BLANKS;                                                      00003000
         END;                                                                   00003100
         ELSE RETURN '';                                                        00003200
      END BLANKS;                                                               00003300
      DO I = 1 TO #SPECIALS;                                                    00003400
         IF BYTE(CURRENT_CARD, D_INDEX) = BYTE(SPECIALS, I) THEN DO;            00003500
            D_INDEX = D_INDEX + 1;                                              00003600
            RETURN SUBSTR(CURRENT_CARD, D_INDEX-1, 1);                          00003700
         END;                                                                   00003800
      END;                                                                      00003900
      I = D_INDEX;                                                              00004000
TOKEN:                                                                          00004100
      DO WHILE D_INDEX <= TEXT_LIMIT;                                           00004200
         DO J = 0 TO #SPECIALS;                                                 00004300
            IF BYTE(CURRENT_CARD, D_INDEX) = BYTE(SPECIALS, J) THEN             00004400
               ESCAPE TOKEN;                                                    00004500
         END;                                                                   00004600
         D_INDEX = D_INDEX + 1;                                                 00004700
      END TOKEN;                                                                00004800
      RETURN SUBSTR(CURRENT_CARD, I, D_INDEX - I);                              00004900
   END D_TOKEN;                                                                 00005000
