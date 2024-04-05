 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   SDFPROCE.xpl
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
/* PROCEDURE NAME:  SDF_PROCESSING                                         */
/* MEMBER NAME:     SDFPROCE                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          ALIGNED_BUFFER(63)  FIXED                                      */
/*          BUFFER            CHARACTER;                                   */
/*          FFBUFF(1)         FIXED                                        */
/*          FFSTRING          CHARACTER;                                   */
/*          MAX_OFFSET        BIT(16)                                      */
/*          OFFSET            BIT(16)                                      */
/*          RECORD_ADDR       FIXED                                        */
/*          STATISTICS(494)   LABEL                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          ADDRESS                                                        */
/*          ALL                                                            */
/*          BAIL_OUT                                                       */
/*          COMM                                                           */
/*          COMMTABL_ADDR                                                  */
/*          COMMTABL_FULLWORD                                              */
/*          CRETURN                                                        */
/*          DATABUF_BYTE                                                   */
/*          DATABUF_FULLWORD                                               */
/*          DATABUF_HALFWORD                                               */
/*          FOREVER                                                        */
/*          LOCCNT                                                         */
/*          MISC_VAL                                                       */
/*          MISC                                                           */
/*          NUMGETM                                                        */
/*          NUMOFPGS                                                       */
/*          READS                                                          */
/*          SDF_NAM1                                                       */
/*          SDFNAM                                                         */
/*          SLECTCNT                                                       */
/*          STAND_ALONE                                                    */
/*          TABDMP                                                         */
/*          TOTFCBLN                                                       */
/*          TRUE                                                           */
/*          X1                                                             */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          COMMTABL_HALFWORD                                              */
/*          SDF_NAME                                                       */
/*          SDFPKG_FCBAREA                                                 */
/*          SDFPKG_LOCATES                                                 */
/*          SDFPKG_NUMGETM                                                 */
/*          SDFPKG_PGAREA                                                  */
/*          SDFPKG_READS                                                   */
/*          SDFPKG_SLECTCNT                                                */
/*          TABLST                                                         */
/*          TMP                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          MOVE                                                           */
/*          DUMP_SDF                                                       */
/*          PAD                                                            */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> SDF_PROCESSING <==                                                  */
/*     ==> PAD                                                             */
/*     ==> MOVE                                                            */
/*     ==> DUMP_SDF                                                        */
/*         ==> FORMAT                                                      */
/*         ==> HEX                                                         */
/*         ==> HEX8                                                        */
/*         ==> HEX6                                                        */
/*         ==> PRINT_DATE_AND_TIME                                         */
/*             ==> CHARDATE                                                */
/*             ==> PRINT_TIME                                              */
/*                 ==> CHARTIME                                            */
/*         ==> STMT_TO_PTR                                                 */
/*         ==> SYMB_TO_PTR                                                 */
/*         ==> BLOCK_TO_PTR                                                */
/*         ==> SDF_SELECT                                                  */
/*         ==> SDF_PTR_LOCATE                                              */
/*         ==> SDF_LOCATE                                                  */
/*             ==> SDF_PTR_LOCATE                                          */
/*         ==> PAGE_DUMP                                                   */
/*             ==> HEX                                                     */
/*             ==> HEX8                                                    */
/*         ==> BLOCK_NAME                                                  */
/*         ==> SYMBOL_NAME                                                 */
/*         ==> PTR_TO_BLOCK                                                */
/*             ==> SDF_LOCATE                                              */
/*                 ==> SDF_PTR_LOCATE                                      */
/*         ==> PRINT_REPLACE_TEXT                                          */
/*             ==> SDF_LOCATE                                              */
/*                 ==> SDF_PTR_LOCATE                                      */
/***************************************************************************/
                                                                                00258600
SDF_PROCESSING:                                                                 00258700
   PROCEDURE;                                                                   00258800
      DECLARE (FFSTRING,BUFFER) CHARACTER, (RECORD_ADDR) FIXED,                 00258900
         (OFFSET,MAX_OFFSET) BIT(16), ALIGNED_BUFFER(63) FIXED,                 00259000
         FFBUFF(1) FIXED INITIAL("FFFFFFFF","FFFFFFFF");                        00259100
                                                                                00259200
 /* INITIALIZE SDFPKG */                                                        00259300
                                                                                00259400
      IF STAND_ALONE THEN DO;                                                   00259500
         MISC=MISC_VAL;                                                         00259510
         CALL MOVE(8, 'HALSDF  ', SDFNAM);                                      00259520
      END;                                                                      00259530
      ELSE MISC = MISC_VAL | 4;   /* USE ALTERNATE DD NAME LIST */              00259600
      CALL MONITOR(22,0,COMMTABL_ADDR);                                         00259700
      IF CRETURN ^= 0 THEN DO;                                                  00259800
         OUTPUT = X1;                                                           00259900
         OUTPUT = '**** OPEN ERROR DETECTED FOR SDF PDS -- CORRECT JCL AND RESUB00260000
MIT ****';                                                                      00260100
         GO TO BAIL_OUT;                                                        00260200
      END;                                                                      00260300
      COREWORD(ADDR(DATABUF_BYTE)) = ADDRESS;                                   00260400
      COREWORD(ADDR(DATABUF_HALFWORD)) = ADDRESS;                               00260500
      COREWORD(ADDR(DATABUF_FULLWORD)) = ADDRESS;                               00260600
                                                                                00260700
      IF ALL THEN DO;                                                           00260800
         FFSTRING = STRING("07000000" + ADDR(FFBUFF));                          00260900
         IF ((TABLST|TABDMP) = 0) THEN TABLST = TRUE;  /* DO SOMETHING */       00261000
         DO FOREVER;                                                            00261100
            BUFFER = INPUT(3);                                                  00261200
            IF BUFFER = '' THEN GO TO STATISTICS;                               00261300
            RECORD_ADDR = ADDR(ALIGNED_BUFFER);                                 00261400
            CALL MOVE(LENGTH(BUFFER),BUFFER,RECORD_ADDR);                       00261500
            OFFSET = 2;                                                         00261600
            MAX_OFFSET = SHR(COREWORD(RECORD_ADDR),16)&"FFFF";                  00261700
            DO WHILE OFFSET < MAX_OFFSET;                                       00261800
               SDF_NAME = STRING("07000000" + RECORD_ADDR + OFFSET);            00261900
               IF SDF_NAME = FFSTRING THEN GO TO STATISTICS;                    00262000
               CALL MOVE(8,SDF_NAME,SDFNAM);                                    00262100
               CALL DUMP_SDF;                                                   00262200
               TMP = COREBYTE(RECORD_ADDR+OFFSET+11);                           00262300
               OFFSET = OFFSET + 12 + SHL(TMP&"1F",1);                          00262400
            END;                                                                00262500
         END;                                                                   00262600
      END;                                                                      00262700
      ELSE IF STAND_ALONE THEN DO;                                              00262800
         IF ((TABLST|TABDMP) = 0) THEN TABLST = TRUE;  /* DO SOMETHING */       00262900
         DO FOREVER;                                                            00263000
            SDF_NAME = INPUT;                                                   00263100
            DO WHILE SUBSTR(SDF_NAME,0,1) = X1;                                 00263200
               SDF_NAME = SUBSTR(SDF_NAME,1);                                   00263300
            END;                                                                00263400
            IF SDF_NAME = '' THEN GO TO STATISTICS;                             00263500
            SDF_NAME = PAD(SDF_NAME,8);                                         00263600
            CALL MOVE(8,SDF_NAME,SDFNAM);                                       00263700
            CALL MONITOR(22,"80000007");                                        00263800
            IF CRETURN = 0 THEN CALL DUMP_SDF;                                  00263900
            ELSE DO;                                                            00264000
               OUTPUT='*** SDF '||SDF_NAME||' NOT FOUND -- REQUEST IGNORED ***';00264100
               OUTPUT = X1;                                                     00264200
            END;                                                                00264300
         END;                                                                   00264400
      END;                                                                      00264500
      ELSE DO;                                                                  00264600
         CALL MOVE(8,ADDR(SDF_NAM1),SDFNAM);                                    00264700
         COREWORD(ADDR(SDF_NAME)) = "07000000" + ADDR(SDF_NAM1);                00264800
         CALL MONITOR(22,"80000007");                                           00264900
         IF CRETURN = 0 THEN CALL DUMP_SDF;                                     00265000
         ELSE DO;                                                               00265100
            OUTPUT = '*** SDF '||SDF_NAME||' NOT FOUND -- PROCESSING ABANDONED *00265200
**';                                                                            00265300
         END;                                                                   00265400
      END;                                                                      00265500
                                                                                00265600
 /* SAVE KEY SDFPKG STATISTICS FOR USE BY PRINTSUMMARY */                       00265700
                                                                                00265800
STATISTICS:                                                                     00265900
      SDFPKG_LOCATES = LOCCNT;                                                  00266000
      SDFPKG_READS = READS;                                                     00266100
      SDFPKG_SLECTCNT = SLECTCNT;                                               00266200
      SDFPKG_FCBAREA = TOTFCBLN;                                                00266300
      SDFPKG_PGAREA = NUMOFPGS;                                                 00266400
      SDFPKG_NUMGETM = NUMGETM;                                                 00266500
                                                                                00266600
 /* ALLOW SDFPKG TO TERMINATE ITSELF.  THEN IT WILL BE DELETED */               00266700
                                                                                00266800
      CALL MONITOR(22,1);                                                       00266900
                                                                                00267000
   END SDF_PROCESSING    /*  $S  */ ; /*  $S  */                                00267100
