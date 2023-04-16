 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INTEGERI.xpl
    Purpose:    Part of the HAL/S-FC compiler's HALMAT intermediate-code
                generation process.
    Reference:  "HAL/S-FC & HAL/S-360 Compiler System Program Description", 
                section 6.3.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the 
                Virtual AGC Project. Inline comments beginning merely with 
                "/*" are from the original Space Shuttle development.
 */
 
 /***************************************************************************/
 /* PROCEDURE NAME:  INTEGERIZABLE                                          */
 /* MEMBER NAME:     INTEGERI                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          FLT_NEGMAX        FIXED                                        */
 /*          LIT_NEGMAX        LABEL                                        */
 /*          NEGLIT            BIT(8)                                       */
 /*          NEGMAX            FIXED                                        */
 /*          NO_INTEGER(739)   LABEL                                        */
 /*          TEMP              FIXED                                        */
 /*          TEMP1             FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          ADDR_FIXED_LIMIT                                               */
 /*          ADDR_FIXER                                                     */
 /*          ADDR_ROUNDER                                                   */
 /*          CONST_DW                                                       */
 /*          DW                                                             */
 /*          FALSE                                                          */
 /*          TRUE                                                           */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FOR_DW                                                         */
 /* CALLED BY:                                                              */
 /*          INTEGER_LIT                                                    */
 /***************************************************************************/
                                                                                00176100
 /* ROUTINE TO CONVERT SCALAR LIT TO INTEGER AND CHECK RANGE */                 00176200
INTEGERIZABLE:                                                                  00176300
   PROCEDURE;                                                                   00176400
      DECLARE LIT_NEGMAX LABEL, FLT_NEGMAX FIXED INITIAL("C8800000");           00176500
      DECLARE NEGMAX FIXED INITIAL("80000000"), NEGLIT BIT(8);                  00176600
      DECLARE (TEMP,TEMP1) FIXED;                                               00176700
                                                                                00176800
      CALL INLINE("58",1, 0, FOR_DW);                                           00176900
      CALL INLINE("68", 0, 0, 1, 0);              /* LE 0,0(0,1) */             00177000
      IF DW(0) = "FF000000" THEN DO;                                            00177100
NO_INTEGER:RETURN FALSE;                                                        00177200
      END;                                                                      00177300
      TEMP = ADDR(NO_INTEGER);                                                  00177400
      TEMP1 = ADDR(LIT_NEGMAX);                                                 00177500
      CALL INLINE("28", 2, 0);                    /* LDR 2,0     */             00177600
      CALL INLINE("20", 0, 0);                    /* LPDR 0,0    */             00177700
      CALL INLINE("2B", 4, 4);                    /* SDR 4,4     */             00177800
      CALL INLINE("78", 4, 0, FLT_NEGMAX);        /* LE 4,FLT_NEGMAX */         00177900
      CALL INLINE("58", 2, 0, TEMP1);             /* L 2,TEMP1   */             00178000
      CALL INLINE("29", 4, 2);                    /* CDR 4,2     */             00178100
      CALL INLINE("07", 8, 2);                    /* BCR 8,2     */             00178200
      CALL INLINE("58", 1, 0, ADDR_ROUNDER);      /* L 1,ADDR_ROUNDER */        00178300
      CALL INLINE("6A", 0, 0, 1, 0);              /* AD 0,0(0,1) */             00178400
      CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);  /* L 1,ADDR__LIMIT */         00178500
      CALL INLINE("58", 2, 0, TEMP);              /* L 2,TEMP    */             00178600
      CALL INLINE("69", 0, 0, 1, 0);              /* CD 0,0(0,1) */             00178700
      CALL INLINE("07", 2, 2);                    /* BCR 2,2     */             00178800
LIT_NEGMAX:                                                                     00178900
      CALL INLINE("58", 1, 0, ADDR_FIXER);        /* L 1,ADDR_FIXER */          00179000
      CALL INLINE("6E", 0, 0, 1, 0);              /* AW 0,0(0,1) */             00179100
      CALL INLINE("58", 1, 0, FOR_DW);                                          00179200
      CALL INLINE("60", 0, 0, 1, 8);              /* STD 0,8(0,1) */            00179300
      CALL INLINE("70", 2, 0, 1, 8);              /* STE 2,8(0,1) */            00179400
      NEGLIT = SHR(DW(2), 31);                                                  00179500
      IF NEGLIT THEN DO;                                                        00179600
         IF DW(3) ^= NEGMAX THEN DW(3) = -DW(3);                                00179700
      END;                                                                      00179800
      RETURN TRUE;                                                              00179900
   END INTEGERIZABLE;                                                           00180000
