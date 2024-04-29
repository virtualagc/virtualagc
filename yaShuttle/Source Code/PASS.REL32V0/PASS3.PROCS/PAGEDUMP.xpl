 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAGEDUMP.xpl
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
 /* PROCEDURE NAME:  PAGE_DUMP                                              */
 /* MEMBER NAME:     PAGEDUMP                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PAGE              BIT(16)                                      */
 /*          FILE#             BIT(16)                                      */
 /* LOCAL DECLARATIONS:                                                     */
 /*          II                BIT(16)                                      */
 /*          III               BIT(16)                                      */
 /*          J                 BIT(16)                                      */
 /*          JJ                BIT(16)                                      */
 /*          K                 BIT(16)                                      */
 /*          PTR               FIXED                                        */
 /*          STILL_ZERO        BIT(8)                                       */
 /*          TS(12)            CHARACTER;                                   */
 /*          WORD              FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          FALSE                                                          */
 /*          TRUE                                                           */
 /*          X1                                                             */
 /*          X3                                                             */
 /*          X4                                                             */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX                                                            */
 /*          HEX8                                                           */
 /*          LOCATE                                                         */
 /*          P3_LOCATE                                                      */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PAGE_DUMP <==                                                       */
 /*     ==> HEX                                                             */
 /*     ==> HEX8                                                            */
 /*     ==> LOCATE                                                          */
 /*     ==> P3_LOCATE                                                       */
 /*         ==> P3_PTR_LOCATE                                               */
 /*             ==> HEX8                                                    */
 /*             ==> ZERO_CORE                                               */
 /*             ==> P3_DISP                                                 */
 /*             ==> PAGING_STRATEGY                                         */
 /***************************************************************************/
                                                                                00187300
 /* SDF PAGE DUMPING ROUTINE */                                                 00187400
                                                                                00187500
PAGE_DUMP:                                                                      00187600
   PROCEDURE(PAGE,FILE#);                                                       00187700
      DECLARE (PAGE,FILE#,J,JJ,II,III,K) BIT(16),                               00187710
         PTR FIXED,                                                             00187900
         TS(12) CHARACTER,                                                      00188000
         STILL_ZERO BIT(1);                                                     00188100
      BASED WORD FIXED;                                                         00188200
      PTR = SHL(PAGE,16);                                                       00188300
      DO CASE FILE#;                                                            00188400
         DO;   /* SDF */                                                        00188405
            K = 34;                                                             00188410
            CALL P3_LOCATE(PTR,ADDR(WORD),0);                                   00188415
         END;                                                                   00188420
         DO;   /* VMEM */                                                       00188425
            K = 69;                                                             00188430
            CALL LOCATE(PTR,ADDR(WORD),0);                                      00188435
         END;                                                                   00188440
      END;                                                                      00188445
      FILE# = 0;                                                                00188450
      OUTPUT(1) = '1';                                                          00188500
      TS = HEX(PAGE,3);                                                         00188600
      OUTPUT = 'PAGE '||TS||'     ..00     ..04     ..08'                       00188700
         ||'        ..0C     ..10     ..14        ..18     ..1C'                00188800
         ||'     ..20        ..24     ..28     ..2C';                           00188900
      OUTPUT = X1;                                                              00189000
      DO J = 0 TO K;   /* PAGE_SIZE/48 - 1 */                                   00189100
         II = J * 12;                                                           00189200
         STILL_ZERO = TRUE;                                                     00189300
         DO JJ = 0 TO 11;                                                       00189400
            IF WORD(JJ + II) ^= 0 THEN STILL_ZERO = FALSE;                      00189500
            TS(JJ + 1) = HEX8(WORD(JJ + II));                                   00189600
         END;                                                                   00189700
         IF ^STILL_ZERO THEN DO;                                                00189800
            TS = HEX((J * 48), 4);                                              00189900
            DO II = 0 TO 3;                                                     00190000
               TS = TS||X3;                                                     00190100
               DO III = 1 TO 3;                                                 00190200
                  TS = TS||TS(3*II + III)||X1;                                  00190300
               END;                                                             00190400
            END;                                                                00190500
            OUTPUT = X4|| TS;                                                   00190600
         END;                                                                   00190700
      END;                                                                      00190800
      OUTPUT = X1;                                                              00190900
      OUTPUT = X1;                                                              00191000
   END PAGE_DUMP;                                                               00191100
