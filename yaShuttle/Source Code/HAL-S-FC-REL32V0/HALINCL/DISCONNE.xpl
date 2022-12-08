 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DISCONNE.xpl
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
 
DISCONNECT:                                                                     00000100
   PROCEDURE(LOC);                                                              00000200
      /* REMOVES ENTRY AT LOC FROM SYMBOL TABLE HASH STRUCTURE                  00000300
         ASSUMES CLOSE_BCD CONTAINS THE VARIABLE NAME */                        00000400
      DECLARE (I, J) FIXED;                                                     00000500
      DECLARE LOC BIT(16);                                                      00000600
      IF BLOCK_MODE(NEST) = CMPL_MODE THEN SYT_NEST(LOC) = 0;                   00000700
      ELSE DO;                                                                  00000800
         I = HASH(CLOSE_BCD, SYT_HASHSIZE);                                     00000900
         IF SYT_HASHSTART(I) = LOC THEN                                         00001000
            SYT_HASHSTART(I) = SYT_HASHLINK(LOC);                               00001100
         ELSE DO;                                                               00001200
            I = SYT_HASHSTART(I);                                               00001300
            DO WHILE I ^= LOC;                                                  00001400
               J = I;                                                           00001500
               I = SYT_HASHLINK(I);                                             00001600
            END;                                                                00001700
            SYT_HASHLINK(J) = SYT_HASHLINK(LOC);                                00001800
         END;                                                                   00001900
         SYT_FLAGS(LOC) = SYT_FLAGS(LOC) | INACTIVE_FLAG;                       00002000
      END;                                                                      00002100
   END DISCONNECT;                                                              00002200
