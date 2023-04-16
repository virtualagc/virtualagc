 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAGEDUMP.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
 */

/***************************************************************************/
/* PROCEDURE NAME:  PAGE_DUMP                                              */
/* MEMBER NAME:     PAGEDUMP                                               */
/* INPUT PARAMETERS:                                                       */
/*          PAGE              BIT(16)                                      */
/* LOCAL DECLARATIONS:                                                     */
/*          II                BIT(16)                                      */
/*          III               BIT(16)                                      */
/*          J                 BIT(16)                                      */
/*          JJ                BIT(16)                                      */
/*          STILL_ZERO        BIT(8)                                       */
/*          TS(12)            CHARACTER;                                   */
/*          WORD              FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          FALSE                                                          */
/*          LOC_ADDR                                                       */
/*          PAGE_SIZE                                                      */
/*          TRUE                                                           */
/*          X1                                                             */
/*          X3                                                             */
/*          X4                                                             */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          HEX                                                            */
/*          HEX8                                                           */
/* CALLED BY:                                                              */
/*          DUMP_SDF                                                       */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> PAGE_DUMP <==                                                       */
/*     ==> HEX                                                             */
/*     ==> HEX8                                                            */
/***************************************************************************/
                                                                                00162200
 /* SDF PAGE DUMPING ROUTINE */                                                 00162300
                                                                                00162400
PAGE_DUMP:                                                                      00162500
   PROCEDURE (PAGE);                                                            00162600
      DECLARE (PAGE,J,JJ,II,III) BIT(16),                                       00162700
         TS(12) CHARACTER,                                                      00162800
         STILL_ZERO BIT(1);                                                     00162900
      BASED WORD FIXED;                                                         00163000
      COREWORD(ADDR(WORD)) = LOC_ADDR;                                          00163100
      OUTPUT(1) = '1';                                                          00163200
      TS = HEX(PAGE,3);                                                         00163300
      OUTPUT = 'PAGE '||TS||'     ..00     ..04     ..08'                       00163400
         ||'        ..0C     ..10     ..14        ..18     ..1C'                00163500
         ||'     ..20        ..24     ..28     ..2C';                           00163600
      OUTPUT = X1;                                                              00163700
      DO J = 0 TO (PAGE_SIZE/48 - 1);                                           00163800
         II = J * 12;                                                           00163900
         STILL_ZERO = TRUE;                                                     00164000
         DO JJ = 0 TO 11;                                                       00164100
            IF WORD(JJ + II) ^= 0 THEN STILL_ZERO = FALSE;                      00164200
            TS(JJ + 1) = HEX8(WORD(JJ + II));                                   00164300
         END;                                                                   00164400
         IF ^STILL_ZERO THEN DO;                                                00164500
            TS = HEX((J * 48), 4);                                              00164600
            DO II = 0 TO 3;                                                     00164700
               TS = TS||X3;                                                     00164800
               DO III = 1 TO 3;                                                 00164900
                  TS = TS||TS(3*II + III)||X1;                                  00165000
               END;                                                             00165100
            END;                                                                00165200
            OUTPUT = X4|| TS;                                                   00165300
         END;                                                                   00165400
      END;                                                                      00165500
      OUTPUT = X1;                                                              00165600
      OUTPUT = X1;                                                              00165700
      RETURN;                                                                   00165800
   END PAGE_DUMP;                                                               00165900
