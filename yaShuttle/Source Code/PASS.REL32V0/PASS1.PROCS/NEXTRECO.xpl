 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   NEXTRECO.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

 /***************************************************************************/
 /* PROCEDURE NAME:  NEXT_RECORD                                            */
 /* MEMBER NAME:     NEXTRECO                                               */
 /* FUNCTION RETURN TYPE:                                                   */
 /*          CHARACTER                                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          INCLUDE_COMPRESSED                                             */
 /*          INCLUDING                                                      */
 /*          INPUT_DEV                                                      */
 /*          SYSIN_COMPRESSED                                               */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CURRENT_CARD                                                   */
 /*          INITIAL_INCLUDE_RECORD                                         */
 /*          LOOKED_RECORD_AHEAD                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DECOMPRESS                                                     */
 /* CALLED BY:                                                              */
 /*          STREAM                                                         */
 /*          INITIALIZATION                                                 */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> NEXT_RECORD <==                                                     */
 /*     ==> DECOMPRESS                                                      */
 /*         ==> BLANK                                                       */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /***************************************************************************/
                                                                                00436110
                                                                                00436120
NEXT_RECORD:                                                                    00436130
   PROCEDURE CHARACTER;                                                         00436140
      IF LOOKED_RECORD_AHEAD THEN DO;                                           00436150
         LOOKED_RECORD_AHEAD = FALSE;                                           00436160
         RETURN;                                                                00436170
      END;                                                                      00436180
      IF INCLUDING THEN DO;                                                     00436220
         IF INCLUDE_COMPRESSED THEN                                             00436230
            CURRENT_CARD = DECOMPRESS(1);                                       00436240
         ELSE DO;                                                               00436250
            IF INITIAL_INCLUDE_RECORD THEN INITIAL_INCLUDE_RECORD = FALSE;      00436260
            ELSE CURRENT_CARD = INPUT(INPUT_DEV);                               00436270
         END;                                                                   00436280
      END;                                                                      00436290
      ELSE DO;  /* NOT INCLUDE */                                               00436300
         IF SYSIN_COMPRESSED THEN CURRENT_CARD = DECOMPRESS(0);                 00436310
         ELSE CURRENT_CARD = INPUT(INPUT_DEV);                                  00436320
      END;                                                                      00436330
   END NEXT_RECORD;                                                             00436350
