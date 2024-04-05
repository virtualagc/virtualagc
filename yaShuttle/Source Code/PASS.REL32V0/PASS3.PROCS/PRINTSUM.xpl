 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PRINTSUM.xpl
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
 /* PROCEDURE NAME:  PRINTSUMMARY                                           */
 /* MEMBER NAME:     PRINTSUM                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*          DENSITY           FIXED                                        */
 /*          I                 BIT(16)                                      */
 /*          T                 FIXED                                        */
 /*          T1                FIXED                                        */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          #DEL_SYMBOLS                                                   */
 /*          #DEL_TPLS                                                      */
 /*          #PROCS                                                         */
 /*          #STMTS                                                         */
 /*          #SYMBOLS                                                       */
 /*          DATA_FREE_SPACE                                                */
 /*          DIR_FREE_SPACE                                                 */
 /*          K#PROCS                                                        */
 /*          LAST_LREC                                                      */
 /*          LAST_PAGE                                                      */
 /*          LOC_CNT                                                        */
 /*          MAX_PAGE                                                       */
 /*          MAX_PAGE_PRED                                                  */
 /*          PAGE_SIZE                                                      */
 /*          READ_CNT                                                       */
 /*          RESV_CNT                                                       */
 /*          SRN_FLAG1                                                      */
 /*          VMEM_LOC_CNT                                                   */
 /*          VMEM_READ_CNT                                                  */
 /*          VMEM_RESV_CNT                                                  */
 /*          VMEM_WRITE_CNT                                                 */
 /*          WRITE_CNT                                                      */
 /*          X1                                                             */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          CLOCK                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          DUMP_VMEM_STATUS                                               */
 /*          PRINT_DATE_AND_TIME                                            */
 /*          PRINT_TIME                                                     */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> PRINTSUMMARY <==                                                    */
 /*     ==> DUMP_VMEM_STATUS                                                */
 /*     ==> PRINT_TIME                                                      */
 /*     ==> PRINT_DATE_AND_TIME                                             */
 /*         ==> PRINT_TIME                                                  */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   CR/DR #  DESCRIPTION                                */
 /*                                                                         */
 /* 07/14/99 DCP  30V0  CR12214  USE THE SAFEST %MACRO THAT WORKS           */
 /*               15V0                                                      */
 /*                                                                         */
 /***************************************************************************/
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE     NAME  REL   DR NUMBER AND TITLE                               */
 /*                                                                         */
 /*  05/26/99 SMR   30V0  CR13079  ADD HAL/S INITIALIZATION DATA TO SDF     */
 /*                 15V0                                                    */
 /*                                                                         */
 /***************************************************************************/
                                                                                00515200
 /* SUBROUTINE FOR PRINTING AN ACTIVITY SUMMARY */                              00515300
PRINTSUMMARY:                                                                   00515400
   PROCEDURE;                                                                   00515500
      DECLARE (T,T1,DENSITY) FIXED,                                             00515600
         (I) BIT(16);                                                           00515700
                                                                                00515800
/*CR12214 - ROUTINE TO SORT & OUTPUT ADVISORY MESSAGES*/
ADVISORY_MSG:
   PROCEDURE;
     DECLARE (I,J,TMP) BIT(16), CTMP CHARACTER;

OUTPUT_MSG:
   PROCEDURE(ERROR,TEXT);
     DECLARE (TEXT,ERROR,S) CHARACTER;
     DECLARE ERRORFILE LITERALLY '5';

     IF MONITOR(2,5,ERROR) THEN DO;
       OUTPUT = 'ERROR MESSAGE ' || ERROR || ' NOT FOUND';
       RETURN;
     END;
     S = INPUT(ERRORFILE);
     S = TEXT||S;
     OUTPUT = S;
CLOSE OUTPUT_MSG;


/* PRINT TITLE & HEADER */
      OUTPUT(1) = '1ADVISORY MESSAGES';
      OUTPUT = X1;
      IF SDL_FLAG THEN
        OUTPUT = 'RVL SRN     ST# ';
      ELSE
        OUTPUT = 'SRN     ST#';

      IF SDL_FLAG THEN DO;         /*SORT RVLS, MOST RECENT FIRST*/
        DO I = 0 TO RECORD_ALLOC(ADVISE)-2;
          DO J = I+1 TO RECORD_ALLOC(ADVISE)-1;
            IF STRING_GT(STRING(ADDR(RVL#(J))+"1000000"),
                         STRING(ADDR(RVL#(I))+"1000000")) THEN DO;
              TMP = RVL#(I);
              RVL#(I) = RVL#(J);
              RVL#(J) = TMP;

              CTMP = SRN#(I);
              SRN#(I) = SRN#(J);
              SRN#(J) = CTMP;

              TMP = ADV_STMT#(I);
              ADV_STMT#(I) = ADV_STMT#(J);
              ADV_STMT#(J) = TMP;

              CTMP = ADV_ERROR#(I);
              ADV_ERROR#(I) = ADV_ERROR#(J);
              ADV_ERROR#(J) = CTMP;
            END;
          END;
        END;
        DO I = 0 TO RECORD_ALLOC(ADVISE)-2;     /*SORT SRNS*/
          DO J = I+1 TO RECORD_ALLOC(ADVISE)-1;
            IF RVL#(J) = RVL#(I) THEN
              IF STRING_GT(SRN#(I),SRN#(J)) THEN DO;
                CTMP = SRN#(I);
                SRN#(I) = SRN#(J);
                SRN#(J) = CTMP;

                TMP = ADV_STMT#(I);
                ADV_STMT#(I) = ADV_STMT#(J);
                ADV_STMT#(J) = TMP;

                CTMP = ADV_ERROR#(I);
                ADV_ERROR#(I) = ADV_ERROR#(J);
                ADV_ERROR#(J) = CTMP;
              END;
          END;
        END;
      END;
/* PRINT ERROR MESSAGES */
      DO I = 0 TO RECORD_ALLOC(ADVISE)-1;
       IF SDL_FLAG THEN DO;
         CTMP = STRING(ADDR(RVL#(I))+"1000000");
         CTMP   = CTMP||X2||SRN#(I)||X2||ADV_STMT#(I);
         CALL OUTPUT_MSG(PAD(ADV_ERROR#(I),8),PAD(CTMP,18));
       END;
       ELSE DO;
         CTMP   = SRN#(I)||X2||ADV_STMT#(I);
         CALL OUTPUT_MSG(PAD(ADV_ERROR#(I),8),PAD(CTMP,13));
       END;
      END;
END ADVISORY_MSG;

      OUTPUT = X1;                                                              00515900
      IF SRN_FLAG1 THEN                                                         00516000
         OUTPUT = '*** STATEMENT REFERENCE NUMBERS ARE NOT MONOTONIC ***';      00516100
      IF RESV_CNT ^= 0 THEN                                                     00516200
         OUTPUT='*** PHASE 3 ERROR -- SDF RESERVE COUNT = '||RESV_CNT||' ***';  00516300
      IF VMEM_RESV_CNT ^= 0                                                     00516310
         THEN DO;                                                               00516320
         OUTPUT = '*** PHASE 3 ERROR -- VMEM RESERVE COUNT = '||VMEM_RESV_CNT   00516330
            || ' ***';                                                          00516340
         CALL DUMP_VMEM_STATUS;                                                 00516350
      END;                                                                      00516360
                                                                                00516400
      OUTPUT = X1;                                                              00516410
      IF VMEM_LOC_CNT > 0 THEN DO;                                              00516420
         OUTPUT = 'NUMBER OF FILE 6 LOCATES          = '||VMEM_LOC_CNT;         00516430
         OUTPUT = 'NUMBER OF FILE 6 READS            = '||VMEM_READ_CNT;        00516440
         OUTPUT = 'NUMBER OF FILE 6 WRITES           = '||VMEM_WRITE_CNT;       00516450
      END;                                                                      00516460
      OUTPUT = X1;                                                              00516500
      OUTPUT = 'PAGING AREA SIZE (PAGES)          = '|| MAX_PAGE + 1;           00516600
      OUTPUT = 'NUMBER OF LOCATES                 = '|| LOC_CNT;                00516700
      IF (READ_CNT > 0) | (WRITE_CNT > 0) THEN DO;                              00516800
         OUTPUT = 'NUMBER OF FILE 5 READS            = '|| READ_CNT;            00516900
         OUTPUT = 'NUMBER OF FILE 5 WRITES           = '|| WRITE_CNT;           00517000
         OUTPUT = 'NUMBER OF FILE 5 RECORDS          = '|| LAST_LREC + 1;       00517100
      END;                                                                      00517200
      OUTPUT = X1;                                                              00517300
      OUTPUT = 'PREDICTED SDF SIZE (PAGES)        = '|| MAX_PAGE_PRED + 1;      00517400
      OUTPUT = 'ACTUAL SDF SIZE (PAGES)           = '|| LAST_PAGE + 1;          00517500
      T = (LAST_PAGE + 1)*PAGE_SIZE;                                            00517600
      OUTPUT = X1;                                                              00517700
      OUTPUT = 'DIRECTORY FREE SPACE (BYTES)      = '|| DIR_FREE_SPACE;         00517800
      OUTPUT = 'DATA FREE SPACE (BYTES)           = '|| DATA_FREE_SPACE;        00517900
      T1 = DIR_FREE_SPACE + DATA_FREE_SPACE + #D_FREE_SPACE;  /*CR13079*/       00518000
      DENSITY = (100*(T - T1))/T;                                               00518100
      OUTPUT = 'SDF SIZE (BYTES)                  = '|| T - T1;                 00518200
      OUTPUT = 'SDF DENSITY (%)                   = '|| DENSITY;                00518300
      OUTPUT = 'NUMBER OF BLOCK NODES             = '|| #PROCS;                 00518400
      OUTPUT = 'NUMBER OF SYMBOL NODES            = '|| #SYMBOLS;               00518500
      OUTPUT = 'NUMBER OF STATEMENT NODES         = '|| #STMTS;                 00518600
      OUTPUT = X1;                                                              00518700
      OUTPUT = 'NUMBER OF BLOCKS DELETED          = '|| K#PROCS - #PROCS;       00518800
      OUTPUT = 'NUMBER OF SYMBOLS DELETED         = '|| #DEL_SYMBOLS;           00518900
      OUTPUT = 'NUMBER OF TEMPLATES DELETED       = '|| #DEL_TPLS;              00519000
      OUTPUT = 'NUMBER OF MINOR COMPACTIFIES      = '|| COMPACTIFIES;           00519100
      OUTPUT = 'NUMBER OF MAJOR COMPACTIFIES      = '|| COMPACTIFIES(1);        00519200
      OUTPUT = 'NUMBER OF REALLOCATIONS           = '|| REALLOCATIONS;          00519250
      OUTPUT = X1;                                                              00519300
      T = TIME;                                                                 00519400
      DO I = 1 TO 3;                                                            00519500
         IF CLOCK(I) < CLOCK(I - 1) THEN                                        00519600
            CLOCK(I) = CLOCK(I) + 8640000;                                      00519700
      END;                                                                      00519800
      CALL PRINT_DATE_AND_TIME('END OF HAL/S PHASE 3 ',DATE,T);                 00519900
      CALL PRINT_TIME('TOTAL CPU TIME IN PHASE 3              ',                00520000
         CLOCK(3) - CLOCK);                                                     00520100
      CALL PRINT_TIME('CPU TIME FOR PHASE 3 INITIALIZATION    ',                00520200
         CLOCK(1) - CLOCK);                                                     00520300
      CALL PRINT_TIME('CPU TIME FOR PHASE 3 FILE GENERATION   ',                00520400
         CLOCK(2) - CLOCK(1));                                                  00520500
      CALL PRINT_TIME('CPU TIME FOR PHASE 3 FILE EMISSION     ',                00520600
         CLOCK(3) - CLOCK(2));                                                  00520700
     IF RECORD_ALLOC(ADVISE) ^= 0 & SRN_FLAG THEN /*CR12214*/
      CALL ADVISORY_MSG;                          /*CR12214*/
   END PRINTSUMMARY;                                                            00520800
