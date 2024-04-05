 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   P3PTRLOC.xpl
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
 /* PROCEDURE NAME:  P3_PTR_LOCATE                                          */
 /* MEMBER NAME:     P3PTRLOC                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          PTR               FIXED                                        */
 /*          FLAGS             BIT(8)                                       */
 /* LOCAL DECLARATIONS:                                                     */
 /*          CUR_NDX           BIT(16)                                      */
 /*          LREC#             BIT(16)                                      */
 /*          OFFSET            BIT(16)                                      */
 /*          PAGE              BIT(16)                                      */
 /*          PAGE_TEMP         BIT(8)                                       */
 /*          PAGE_TEMP1        FIXED                                        */
 /*          TS                CHARACTER;                                   */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          MAX_PAGE                                                       */
 /*          MODF                                                           */
 /*          NEW_NDX                                                        */
 /*          PAD_ADDR                                                       */
 /*          PAGE_SIZE                                                      */
 /*          PAGE_TO_LREC                                                   */
 /*          PHASE3_ERROR                                                   */
 /*          P3ERR                                                          */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          LAST_PAGE                                                      */
 /*          LOC_ADDR                                                       */
 /*          LOC_CNT                                                        */
 /*          LOC_PTR                                                        */
 /*          OLD_NDX                                                        */
 /*          PAD_CNT                                                        */
 /*          PAD_DISP                                                       */
 /*          PAD_PAGE                                                       */
 /*          PAGE_TO_NDX                                                    */
 /*          READ_CNT                                                       */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          HEX8                                                           */
 /*          PAGING_STRATEGY                                                */
 /*          P3_DISP                                                        */
 /*          ZERO_CORE                                                      */
 /* CALLED BY:                                                              */
 /*          BUILD_SDF_LITTAB                                               */
 /*          BUILD_SDF                                                      */
 /*          EXTRACT4                                                       */
 /*          INITIALIZE                                                     */
 /*          OUTPUT_SDF                                                     */
 /*          PUTN                                                           */
 /*          P3_LOCATE                                                      */
 /*          REFORMAT_HALMAT                                                */
 /*          TRAN                                                           */
 /*          ZERON                                                          */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> P3_PTR_LOCATE <==                                                   */
 /*     ==> HEX8                                                            */
 /*     ==> ZERO_CORE                                                       */
 /*     ==> P3_DISP                                                         */
 /*     ==> PAGING_STRATEGY                                                 */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 03/07/91 DKB  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /***************************************************************************/
                                                                                00170900
 /* ROUTINE TO 'LOCATE' SDF DATA BY POINTER */                                  00171000
                                                                                00171100
P3_PTR_LOCATE:                                                                  00171200
   PROCEDURE (PTR,FLAGS);                                                       00171300
      DECLARE  PTR FIXED,                                                       00171400
         TS CHARACTER,                                                          00171500
         (PAGE,OFFSET,CUR_NDX,LREC#) BIT(16),                                   00171600
         FLAGS BIT(8);                                                          00171700
      BASED    PAGE_TEMP BIT(8),                                                00171800
         PAGE_TEMP1 FIXED;                                                      00171900
      PAGE = SHR(PTR,16) & "FFFF";                                              00172000
      OFFSET = PTR & "FFFF";                                                    00172100
      IF (PAGE < 0) | (PAGE > LAST_PAGE + 1) |                                  00172200
         (OFFSET < 0) | (OFFSET > PAGE_SIZE - 1) THEN DO;                       00172300
         TS = HEX8(PTR);                                                        00172400
         OUTPUT = X1;                                                           00172500
         OUTPUT = P3ERR || 'BAD PTR (' ||                                       00172600
            TS || ') DETECTED BY P3_PTR_LOCATE ROUTINE ***';                    00172700
         GO TO PHASE3_ERROR;                                                    00172800
      END;                                                                      00172900
      LOC_CNT = LOC_CNT + 1;                                                    00173000
      IF OLD_NDX >= 0 THEN PAD_DISP(OLD_NDX) = PAD_DISP(OLD_NDX) - 1;           00173100
      IF PAGE > LAST_PAGE THEN DO;                                              00173200
         LAST_PAGE = LAST_PAGE + 1;                                             00173300
         IF LAST_PAGE <= MAX_PAGE THEN DO;                                      00173400
            CUR_NDX = LAST_PAGE;                                                00173500
         END;                                                                   00173600
         ELSE DO;                                                               00173700
            CUR_NDX = NEW_NDX;                                                  00173800
            PAGE_TO_NDX(PAD_PAGE(CUR_NDX)) = -1;                                00173900
         END;                                                                   00174000
         PAGE_TO_NDX(PAGE) = CUR_NDX;                                           00174100
         PAD_PAGE(CUR_NDX) = LAST_PAGE;                                         00174200
         PAD_DISP(CUR_NDX) = 0;                                                 00174300
         PAD_CNT(CUR_NDX) = LOC_CNT;                                            00174400
         FLAGS = FLAGS|MODF;                                                    00174500
                                                                                00174600
 /* ZERO OUT THE NEW PAGE */                                                    00174700
                                                                                00174800
         CALL ZERO_CORE(PAD_ADDR(CUR_NDX),PAGE_SIZE);                           00174900
                                                                                00175000
 /* CONNECT THIS NEW PAGE INTO THE FREE CELL CHAIN */                           00175100
                                                                                00175200
         COREWORD(ADDR(PAGE_TEMP1)) = PAD_ADDR(CUR_NDX);                        00175300
         PAGE_TEMP1(0) = PAGE_SIZE;                                             00175400
         PAGE_TEMP1(1) = SHL(LAST_PAGE + 1,16);                                 00175500
      END;                                                                      00175600
      ELSE DO;                                                                  00175700
         CUR_NDX = PAGE_TO_NDX(PAGE);                                           00175800
         IF CUR_NDX = -1 THEN DO;                                               00175900
            CUR_NDX = NEW_NDX;                                                  00176000
            PAGE_TO_NDX(PAD_PAGE(CUR_NDX)) = -1;                                00176100
            PAGE_TO_NDX(PAGE) = CUR_NDX;                                        00176200
            LREC# = PAGE_TO_LREC(PAGE);                                         00176300
            COREWORD(ADDR(PAGE_TEMP)) = PAD_ADDR(CUR_NDX);                      00176400
            PAGE_TEMP = FILE(5,LREC#);                                          00176500
            PAD_PAGE(CUR_NDX) = PAGE;                                           00176600
            PAD_DISP(CUR_NDX) = 0;                                              00176700
            READ_CNT = READ_CNT + 1;                                            00176800
         END;                                                                   00176900
         PAD_CNT(CUR_NDX) = LOC_CNT;                                            00177000
      END;                                                                      00177100
      PAD_DISP(CUR_NDX) = PAD_DISP(CUR_NDX) + 1;                                00177200
      OLD_NDX = CUR_NDX;                                                        00177300
      LOC_PTR = PTR;                                                            00177400
      LOC_ADDR = PAD_ADDR(CUR_NDX) + OFFSET;                                    00177500
      IF FLAGS ^= 0 THEN CALL P3_DISP(FLAGS);                                   00177600
      IF LAST_PAGE >= MAX_PAGE THEN CALL PAGING_STRATEGY;                       00177700
   END P3_PTR_LOCATE;                                                           00177900
