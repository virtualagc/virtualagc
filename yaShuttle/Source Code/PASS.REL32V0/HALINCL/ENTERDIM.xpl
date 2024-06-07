 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ENTERDIM.xpl
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
 
ENTER_DIMS:                                                                     00000100
   PROCEDURE;                                                                   00000200
      DECLARE (I, J, K) FIXED, LAST_EXT_PTR FIXED INITIAL(1);                   00000300
      IF EXT_ARRAY(LAST_EXT_PTR) = N_DIM THEN DO;                               00000400
         J = LAST_EXT_PTR + 1;                                                  00000500
         DO I = 0 TO N_DIM - 1;                                                 00000600
            IF EXT_ARRAY(J + I) ^= S_ARRAY(I) THEN                              00000700
               GO TO NO_MATCH;                                                  00000800
         END;                                                                   00000900
         SYT_ARRAY(ID_LOC) = LAST_EXT_PTR;  /* MATCH */                         00001000
         RETURN;                                                                00001100
      END;                                                                      00001200
      ELSE DO;  /* NOT THE SAME AS THE LAST ENTRY */                            00001300
   NO_MATCH:                                                                    00001400
         I = 1;                                                                 00001500
         DO WHILE I < LAST_EXT_PTR;                                             00001600
            J = EXT_ARRAY(I);  /* N_DIM OF THIS ENTRY */                        00001700
            K = I + 1;                                                          00001800
            IF J = N_DIM THEN DO;                                               00001900
               DO TEMP = 0 TO N_DIM - 1;                                        00002000
                  IF EXT_ARRAY(K + TEMP) ^= S_ARRAY(TEMP) THEN                  00002100
                     GO TO INCR_PTR;                                            00002200
               END;                                                             00002300
               SYT_ARRAY(ID_LOC) = I;  /* FOUND A MATCH */                      00002400
               RETURN;                                                          00002500
            END;                                                                00002600
            ELSE                                                                00002700
         INCR_PTR:                                                              00002800
               I = K + J;                                                       00002900
         END;  /* OF DO WHILE */                                                00003000
      END;                                                                      00003100
 /* IF WE GET HERE WE MUST TAKE UP NEW EXT_ARRAY SPACE */                       00003200
      EXT_ARRAY(EXT_ARRAY_PTR) = N_DIM;                                         00003300
      LAST_EXT_PTR, SYT_ARRAY(ID_LOC) = EXT_ARRAY_PTR;                          00003400
      EXT_ARRAY_PTR = EXT_ARRAY_PTR + 1;                                        00003500
      DO I = 0 TO N_DIM - 1;                                                    00003600
         EXT_ARRAY(EXT_ARRAY_PTR + I) = S_ARRAY(I);                             00003700
      END;                                                                      00003800
      EXT_ARRAY_PTR = EXT_ARRAY_PTR + N_DIM;                                    00003900
   END ENTER_DIMS;                                                              00004000
