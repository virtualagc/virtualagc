 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   INITIALI.xpl
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
/* PROCEDURE NAME:  INITIALIZE                                             */
/* MEMBER NAME:     INITIALI                                               */
/* LOCAL DECLARATIONS:                                                     */
/*          C                 CHARACTER;                                   */
/*          CON               FIXED                                        */
/*          INIT_FCB          RECORD                                       */
/*          INIT_PG           RECORD                                       */
/*          J                 FIXED                                        */
/*          MONVALS           FIXED                                        */
/*          PARM_TEXT         CHARACTER;                                   */
/*          PPRO              RECORD                                       */
/*          PRO               FIXED                                        */
/*          S                 CHARACTER;                                   */
/*          TYPE2             FIXED                                        */
/*          VALS              FIXED                                        */
/* EXTERNAL VARIABLES REFERENCED:                                          */
/*          AFCBAREA                                                       */
/*          APGAREA                                                        */
/*          CELL_PTR_REC                                                   */
/*          COMM_TAB                                                       */
/*          COMMTABL_BYTE                                                  */
/*          CONST_DW                                                       */
/*          DOUBLE                                                         */
/*          DSPACE                                                         */
/*          DW                                                             */
/*          FALSE                                                          */
/*          NBYTES                                                         */
/*          NPAGES                                                         */
/*          OPTIONS_CODE                                                   */
/*          SDF_NAM1                                                       */
/*          SPACE_1                                                        */
/*          TRUE                                                           */
/*          UNMOVEABLE                                                     */
/*          VARNAME_REC                                                    */
/*          X1                                                             */
/*          X3                                                             */
/*          X52                                                            */
/*          X72                                                            */
/* EXTERNAL VARIABLES CHANGED:                                             */
/*          ADDR_FIXED_LIMIT                                               */
/*          ADDR_FIXER                                                     */
/*          ADDR_ROUNDER                                                   */
/*          ALL                                                            */
/*          BRIEF                                                          */
/*          COMM                                                           */
/*          COMMTABL_ADDR                                                  */
/*          COMMTABL_FULLWORD                                              */
/*          COMMTABL_HALFWORD                                              */
/*          FOR_DW                                                         */
/*          HMAT_OPT                                                       */
/*          PRINTLINE                                                      */
/*          STAND_ALONE                                                    */
/*          TABDMP                                                         */
/*          TABLE_ADDR                                                     */
/*          TABLST                                                         */
/*          TITLE                                                          */
/*          TMP                                                            */
/* EXTERNAL PROCEDURES CALLED:                                             */
/*          CHARDATE                                                       */
/*          CHARTIME                                                       */
/*          EMIT_OUTPUT                                                    */
/*          LEFT_PAD                                                       */
/*          PAD                                                            */
/*          PRINT_DATE_AND_TIME                                            */
/***************************************************************************/
/*********                          CALL TREE                      *********/
/***************************************************************************/
/* ==> INITIALIZE <==                                                      */
/*     ==> EMIT_OUTPUT                                                     */
/*     ==> PAD                                                             */
/*     ==> LEFT_PAD                                                        */
/*     ==> CHARTIME                                                        */
/*     ==> CHARDATE                                                        */
/*     ==> PRINT_DATE_AND_TIME                                             */
/*         ==> CHARDATE                                                    */
/*         ==> PRINT_TIME                                                  */
/*             ==> CHARTIME                                                */
/***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 JAC  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /* 02/19/91 RSJ  23V2  CR11109  REMOVE UNUSED VARIABLES AND REFORMAT       */
 /*                                                                         */
 /* 03/06/02 TKN  32V0  CR13554  USE TITAN SYSTEMS CORP INSTEAD OF          */
 /*               17V0           INTERMETRICS                               */
 /*                                                                         */
 /***************************************************************************/
                                                                                00249300
INITIALIZE:                                                                     00249400
   PROCEDURE;                                                                   00249500
      DECLARE J FIXED,                                                          00249600
         (C,S,PARM_TEXT) CHARACTER;                                             00249800
      BASED (PRO,CON,TYPE2,VALS,MONVALS) FIXED;                                 00249900
                                                                                00250000
      BASED INIT_FCB RECORD:                                                    00250100
            AREAFCB  (512) FIXED,                                               00250110
         END;                                                                   00250120
      BASED INIT_PG RECORD:                                                     00250130
            AREAPG (2100) FIXED,                                                00250140
         END;                                                                   00250150
      BASED PPRO RECORD:                                                        00250160
            PRO FIXED,                                                          00250170
         END;                                                                   00250180
                                                                                00251400
 /* SEE IF WE ARE IN STAND-ALONE MODE OR PART OF THE COMPILER */                00251500
                                                                                00251600
      IF SDF_NAM1 = 0 THEN STAND_ALONE = TRUE;                                  00251700
      IF STAND_ALONE THEN DO;                                                   00251800
         TMP = MONITOR(13, 'LISTOPT ');                                         00251900
         OPTIONS_CODE = COREWORD(TMP);                                          00252000
         COREWORD(ADDR(CON)) = COREWORD(TMP + 4);                               00252100
         COREWORD(ADDR(PRO)) = COREWORD(TMP + 8);                               00252200
         COREWORD(ADDR(TYPE2)) = COREWORD(TMP + 12);                            00252300
         COREWORD(ADDR(VALS)) = COREWORD(TMP+16);                               00252400
         COREWORD(ADDR(MONVALS)) = COREWORD(TMP+20);  /* NOT USED RIGHT NOW */  00252500
         TITLE = STRING(VALS(0));                                               00252600
         IF LENGTH(TITLE) = 0 THEN                                              00252700
            TITLE = 'T I T A N  S Y S T E M S  C O R P .'; /*CR13554*/          00252800
         J = LENGTH(TITLE);                                                     00252900
         J = ((61 - J)/2) + J;                                                  00253000
         C = LEFT_PAD(TITLE,J);                                                 00253100
         C = PAD(C,61);                                                         00253200
         S = CHARTIME(TIME);                                                    00253300
         S = CHARDATE(DATE) || X3 || S;                                         00253400
         OUTPUT(1) = 'HS D F L I S T   '||STRING(MONITOR(23))||C||X3||S;        00253500
         CALL PRINT_DATE_AND_TIME('SDFLIST -- VERSION OF ',                     00253600
            DATE_OF_GENERATION, TIME_OF_GENERATION);                            00253700
         DSPACE;                                                                00253800
         CALL PRINT_DATE_AND_TIME('TODAY IS ', DATE, TIME);                     00253900
         SPACE_1;                                                               00254000
         PARM_TEXT = PARM_FIELD;                                                00254100
         IF LENGTH(PARM_TEXT) > 0 THEN DO;                                      00254200
            CALL EMIT_OUTPUT('PARM FIELD: '||PARM_TEXT);                        00254300
         END;                                                                   00254400
         DSPACE;                                                                00254500
      END;                                                                      00254600
      RECORD_CONSTANT(PPRO,12500,UNMOVEABLE);                                   00254700
      TMP=ADDR(PPRO(0).PRO(0));                                                 00254710
      CALL MONITOR(7,ADDR(TMP(0)),50000);                                       00254720
                                                                                00255000
 /* SET INTERNAL FLAGS BASED ON THE PARM FIELD */                               00255100
                                                                                00255200
      IF (OPTIONS_CODE & "1000") ^= 0 THEN TABDMP = TRUE;                       00255300
      IF (OPTIONS_CODE & "8000") ^= 0 THEN TABLST = TRUE;                       00255400
      IF (OPTIONS_CODE & "00040000") ^= 0 THEN HMAT_OPT = TRUE;                 00255430
      IF STAND_ALONE THEN DO;                                                   00255500
         IF (OPTIONS_CODE & "20") ^= 0 THEN ALL = TRUE;                         00255600
         IF (OPTIONS_CODE & "40") ^= 0 THEN BRIEF = TRUE;                       00255700
      END;                                                                      00255800
      IF BRIEF THEN DO;                                                         00255900
         TABDMP = FALSE;                                                        00256000
         TABLST = TRUE;                                                         00256100
      END;                                                                      00256200
                                                                                00256300
 /* SET UP THE SDFPKG COMMUNICATION AREA */                                     00256400
                                                                                00256500
      COREWORD(ADDR(COMMTABL_BYTE)) = ADDR(COMM_TAB);                           00256600
      COREWORD(ADDR(COMMTABL_HALFWORD)) = ADDR(COMM_TAB);                       00256700
      COREWORD(ADDR(COMMTABL_FULLWORD)) = ADDR(COMM_TAB);                       00256800
      COMMTABL_ADDR = ADDR(COMM_TAB);                                           00256900
                                                                                00257000
 /* ALLOCATE SDFPKG FCB AREA AND PAGING AREA */                                 00257100
                                                                                00257200
      NBYTES = 2048;                                                            00257300
      RECORD_CONSTANT(INIT_FCB,1,UNMOVEABLE);                                   00257400
      AFCBAREA = ADDR(INIT_FCB(0).AREAFCB(0));                                  00257410
                                                                                00257600
      NPAGES = 5;                                                               00257700
      RECORD_CONSTANT(INIT_PG,1,UNMOVEABLE);                                    00257800
      APGAREA = ADDR(INIT_PG(0).AREAPG(0));                                     00257810
                                                                                00257905
      IF STAND_ALONE THEN DO;                                                   00257910
         RECORD_CONSTANT(FOR_DW,14,UNMOVEABLE);                                 00257915
         CALL MONITOR(5,ADDR(DW(0)));                                           00257920
         TABLE_ADDR = ADDR(DW(0)) + 24;                                         00257925
         ADDR_FIXER = TABLE_ADDR + 8;                                           00257930
         ADDR_FIXED_LIMIT = ADDR_FIXER + 8;                                     00257935
         ADDR_ROUNDER = ADDR_FIXED_LIMIT + 8;                                   00257940
         DW(8) = "4E000000";                                                    00257945
         DW(9) = 0;                                                             00257950
         DW(10) = "487FFFFF";                                                   00257955
         DW(11) = "FFFFFFFF";                                                   00257960
         DW(12) = "407FFFFF";                                                   00257965
         DW(13) = "FFFFFFFF";                                                   00257970
      END;                                                                      00257975
                                                                                00258000
 /* MISCELLANEOUS INITIALIZATIONS */                                            00258100
                                                                                00258200
      PRINTLINE = X72||X52;                                                     00258300
      ALLOCATE_SPACE(VARNAME_REC,100);                                          00258310
      RECORD_USED(VARNAME_REC) = 1;    /* TO START INDEXING AT 1 */             00258320
      ALLOCATE_SPACE(CELL_PTR_REC,200);                                         00258330
      RECORD_USED(CELL_PTR_REC) = 2;   /* ENTRY 1 IS USED IN SPECIAL PLACE,     00258340
          DOESN'T USE STACK PROCEDURE FOR THE FIRST ENTRY */                    00258350
                                                                                00258400
   END INITIALIZE   /* $S */ ; /* $S */                                         00258500
