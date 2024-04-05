 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PAGINGS2.xpl
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
 /* PROCEDURE NAME:  PAGING_STRATEGY                                        */
 /* MEMBER NAME:     PAGINGS2                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          I                 BIT(16)                                      */
 /*          LREC#             BIT(16)                                      */
 /*          PAGE              BIT(16)                                      */
 /*          PAGE_TEMP         BIT(8)                                       */
 /*          PREV_CNT1         BIT(16)                                      */
 /*          PREV_CNT2         BIT(16)                                      */
 /*          PREV_NDX1         BIT(16)                                      */
 /*          PREV_NDX2         BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MAX_PAGE                                                       */
 /*          NO_PAGES                                                       */
 /*          PAD_ADDR                                                       */
 /*          PAD_CNT                                                        */
 /*          PAD_PAGE                                                       */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LAST_LREC                                                      */
 /*          NEW_NDX                                                        */
 /*          PAD_DISP                                                       */
 /*          PAGE_TO_LREC                                                   */
 /*          WRITE_CNT                                                      */
 /* CALLED BY:                                                              */
 /*          P3_PTR_LOCATE                                                  */
 /***************************************************************************/
                                                                                00165700
 /* PAGING STRATEGY ALGORITHM */                                                00165800
                                                                                00165900
PAGING_STRATEGY:                                                                00166000
   PROCEDURE;                                                                   00166100
      DECLARE  (I,PAGE,LREC#,PREV_NDX1,PREV_NDX2,PREV_CNT1,PREV_CNT2) BIT(16);  00166200
      BASED    PAGE_TEMP BIT(8);                                                00166300
      PREV_NDX1,PREV_NDX2 = -1;                                                 00166400
      DO I = 0 TO MAX_PAGE;                                                     00166500
         IF (PAD_DISP(I) & "3FFF") = 0 THEN DO;                                 00166600
            PAGE = PAD_PAGE(I);                                                 00166700
            LREC# = PAGE_TO_LREC(PAGE);                                         00166800
            IF LREC# = -1 THEN DO;                                              00166900
               IF PREV_NDX1 = -1 THEN DO;                                       00167000
                  PREV_NDX1 = I;                                                00167100
                  PREV_CNT1 = PAD_CNT(I);                                       00167200
               END;                                                             00167300
               ELSE IF PAD_CNT(I) < PREV_CNT1 THEN DO;                          00167400
                  PREV_NDX1 = I;                                                00167500
                  PREV_CNT1 = PAD_CNT(I);                                       00167600
               END;                                                             00167700
            END;                                                                00167800
            ELSE DO;                                                            00167900
               IF PREV_NDX2 = -1 THEN DO;                                       00168000
                  PREV_NDX2 = I;                                                00168100
                  PREV_CNT2 = PAD_CNT(I);                                       00168200
               END;                                                             00168300
               ELSE IF PAD_CNT(I) < PREV_CNT2 THEN DO;                          00168400
                  PREV_NDX2 = I;                                                00168500
                  PREV_CNT2 = PAD_CNT(I);                                       00168600
               END;                                                             00168700
            END;                                                                00168800
         END;                                                                   00168900
      END;                                                                      00169000
      IF PREV_NDX2 >= 0 THEN NEW_NDX = PREV_NDX2;                               00169100
      ELSE NEW_NDX = PREV_NDX1;                                                 00169200
      IF NEW_NDX < 0 THEN GO TO NO_PAGES;                                       00169300
      IF (PAD_DISP(NEW_NDX) & "4000") ^= 0 THEN DO;                             00169400
         PAGE = PAD_PAGE(NEW_NDX);                                              00169500
         LREC# = PAGE_TO_LREC(PAGE);                                            00169600
         IF LREC# = -1 THEN DO;                                                 00169700
            LAST_LREC = LAST_LREC + 1;                                          00169800
            PAGE_TO_LREC(PAGE) = LAST_LREC;                                     00169900
            LREC# = LAST_LREC;                                                  00170000
         END;                                                                   00170100
         COREWORD(ADDR(PAGE_TEMP)) = PAD_ADDR(NEW_NDX);                         00170200
         FILE(5,LREC#) = PAGE_TEMP;                                             00170300
         WRITE_CNT = WRITE_CNT + 1;                                             00170400
         PAD_DISP(NEW_NDX) = 0;                                                 00170500
      END;                                                                      00170600
   END PAGING_STRATEGY;                                                         00170800
