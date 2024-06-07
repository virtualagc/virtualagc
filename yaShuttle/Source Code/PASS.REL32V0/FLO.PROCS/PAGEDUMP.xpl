 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAGEDUMP.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*@" were created by the 
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
 /*          LOCATE                                                         */
 /*          HEX                                                            */
 /* CALLED BY:                                                              */
 /*          DUMP_ALL                                                       */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PAGE_DUMP <==                                                       */
 /*     ==> LOCATE                                                          */
 /*     ==> HEX                                                             */
 /***************************************************************************/
                                                                                00305800
PAGE_DUMP:                                                                      00305801
   PROCEDURE(PAGE);                                                             00305802
      DECLARE (PAGE,J,JJ,II,III,K) BIT(16),                                     00305803
         PTR FIXED,                                                             00305804
         TS(12) CHARACTER,                                                      00305805
         STILL_ZERO BIT(1);                                                     00305806
      BASED WORD FIXED;                                                         00305807
      PTR = SHL(PAGE,16);                                                       00305808
      K = 69;                                                                   00305815
      CALL LOCATE(PTR,ADDR(WORD),0);                                            00305816
      OUTPUT(1) = '1';                                                          00305820
      TS = HEX(PAGE,3);                                                         00305821
      OUTPUT = 'PAGE '||TS||'     ..00     ..04     ..08'                       00305822
         ||'        ..0C     ..10     ..14        ..18     ..1C'                00305823
         ||'     ..20        ..24     ..28     ..2C';                           00305824
      OUTPUT = X1;                                                              00305825
      DO J = 0 TO K;   /* PAGE_SIZE/48 - 1 */                                   00305826
         II = J * 12;                                                           00305827
         STILL_ZERO = TRUE;                                                     00305828
         DO JJ = 0 TO 11;                                                       00305829
            IF WORD(JJ + II) ^= 0 THEN STILL_ZERO = FALSE;                      00305830
            TS(JJ + 1) = HEX(WORD(JJ + II),8);                                  00305831
         END;                                                                   00305832
         IF ^STILL_ZERO THEN DO;                                                00305833
            TS = HEX((J * 48), 4);                                              00305834
            DO II = 0 TO 3;                                                     00305835
               TS = TS||X3;                                                     00305836
               DO III = 1 TO 3;                                                 00305837
                  TS = TS||TS(3*II + III)||X1;                                  00305838
               END;                                                             00305839
            END;                                                                00305840
            OUTPUT = X4|| TS;                                                   00305841
         END;                                                                   00305842
      END;                                                                      00305843
      OUTPUT = X1;                                                              00305844
      OUTPUT = X1;                                                              00305845
   END PAGE_DUMP;                                                               00305846
