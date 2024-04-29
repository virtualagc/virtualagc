 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   DUMPSDF.xpl
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
 /* PROCEDURE NAME:  DUMP_SDF                                               */
 /* MEMBER NAME:     DUMPSDF                                                */
 /* LOCAL DECLARATIONS:                                                     */
 /*       #BITS             BIT(8)             L                 BIT(16)    */
 /*       #CHARS            BIT(16)            LAST_BLOCK        BIT(16)    */
 /*       #XREF             BIT(16)            LIT_FLAG          BIT(8)     */
 /*       ADDR1             FIXED              LIT_TYPE          BIT(8)     */
 /*       ADDR1_DEC         CHARACTER          NAME              CHARACTER  */
 /*       ADDR1_HEX         CHARACTER          NAME_FLAG         BIT(8)     */
 /*       ADDR2             FIXED              NODE_B            BIT(8)     */
 /*       ADDR2_DEC         CHARACTER          NODE_B1           BIT(8)     */
 /*       ADDR2_HEX         CHARACTER          NODE_F            FIXED      */
 /*       ADDR3_DEC         CHARACTER          NODE_F1           FIXED      */
 /*       ADDR3_HEX         CHARACTER          NODE_H            BIT(16)    */
 /*       CHAR_STRING       CHARACTER          PRINT_ADDRS       LABEL      */
 /*       CONST_FLAG        BIT(8)             PTR               FIXED      */
 /*       DOUBLE_FLAG       BIT(8)             PTR1              FIXED      */
 /*       DUMP_HALMAT       LABEL              SADDR             FIXED      */
 /*       FLAG              FIXED              SBLK              BIT(16)    */
 /*       FLUSH             LABEL              SCALAR_CHAR       LABEL      */
 /*       FORMAT_CELL_TREE  LABEL              SCLASS            BIT(8)     */
 /*       FORMAT_EXP_VARS_CELL  LABEL          SDF_TITLE         CHARACTER  */
 /*       FORMAT_FORM_PARM_CELL  LABEL         SEXTENT           FIXED      */
 /*       FORMAT_NAME_TERM_CELLS  LABEL        SFLAG             BIT(8)     */
 /*       FORMAT_PF_INV_CELL  LABEL            SHIFT             BIT(8)     */
 /*       FORMAT_VAR_REF_CELL  CHARACTER       SOFFSET           FIXED      */
 /*       HMAT_PTR          FIXED              SRN_STRING        CHARACTER  */
 /*       I                 BIT(16)            SRNS              BIT(8)     */
 /*       INCL_FILES(5)     CHARACTER          STACK_PTR         LABEL      */
 /*       INCL_STRING       CHARACTER          STACK_STRING      LABEL      */
 /*       INCLUDE_PTR       FIXED              STYPE             BIT(8)     */
 /*       INTEGERIZABLE     LABEL              SUB_STMT_TYPES(10)  CHARACTER*/
 /*       ITEM              BIT(16)            SUBTYPE           BIT(8)     */
 /*       J                 BIT(16)            T(37)             BIT(8)     */
 /*       J1                BIT(16)            TEMP              FIXED      */
 /*       J2                BIT(16)            TEMP1             BIT(16)    */
 /*       K                 BIT(16)            TEMP2             BIT(16)    */
 /*       KLIM              BIT(16)            TEMP3             BIT(16)    */
 /*       K1                BIT(16)            TEMP4             BIT(16)    */
 /*       K2                BIT(16)            TS(10)            CHARACTER  */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       #EXECS                               PNTR                         */
 /*       #EXTERNALS                           POINTER_PREFIX               */
 /*       #PROCS                               PROC_TYPES                   */
 /*       #STMTS                               RELS                         */
 /*       #SYMBOLS                             RESV                         */
 /*       ADDR_FIXED_LIMIT                     SDF_NAME                     */
 /*       ADDR_FIXER                           SREFNO                       */
 /*       ADDR_FLAG                            SRN_FLAG                     */
 /*       ADDR_ROUNDER                         STMT_FLAGS                   */
 /*       ADDRESS                              STMT_TYPES                   */
 /*       ASTS                                 STMTNO                       */
 /*       BLKNO                                SYMBOL_CLASSES               */
 /*       BRIEF                                SYMBOL_TYPES                 */
 /*       C_PTR                                TABDMP                       */
 /*       CELL_PTRS                            TABLST                       */
 /*       COMMTABL_ADDR                        TRUE                         */
 /*       COMMTABL_FULLWORD                    VAR                          */
 /*       COMPUNIT                             VARNAME                      */
 /*       CONST_DW                             VERSION                      */
 /*       DATABUF_HALFWORD                     VMEM_B                       */
 /*       DW                                   VMEM_F                       */
 /*       EMITTED_CNT                          VMEM_H                       */
 /*       FALSE                                X1                           */
 /*       FC_FLAG                              X10                          */
 /*       FIRST_STMT                           X15                          */
 /*       FOREVER                              X2                           */
 /*       HMAT_OPT                             X20                          */
 /*       INCLCNT                              X28                          */
 /*       KEY_BLOCK                            X3                           */
 /*       KEY_SYMB                             X30                          */
 /*       LAST_PAGE                            X4                           */
 /*       LAST_STMT                            X5                           */
 /*       LINELENGTH                           X52                          */
 /*       MAXLINES                             X6                           */
 /*       NEW_FLAG                             X7                           */
 /*       NILL                                 X72                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       #LABELS                              LOC_PTR                      */
 /*       #LHS                                 PTR_INX                      */
 /*       ASIP_FLAG                            S                            */
 /*       CELL_PTR_REC                         TMP                          */
 /*       COMMTABL_HALFWORD                    VARNAME_REC                  */
 /*       FOR_DW                               VN_INX                       */
 /*       LOC_ADDR                                                          */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       BLOCK_NAME                           PRINT_REPLACE_TEXT           */
 /*       BLOCK_TO_PTR                         PTR_TO_BLOCK                 */
 /*       FORMAT                               SDF_LOCATE                   */
 /*       HEX                                  SDF_PTR_LOCATE               */
 /*       HEX6                                 SDF_SELECT                   */
 /*       HEX8                                 STMT_TO_PTR                  */
 /*       PAGE_DUMP                            SYMB_TO_PTR                  */
 /*       PRINT_DATE_AND_TIME                  SYMBOL_NAME                  */
 /* CALLED BY:                                                              */
 /*       SDF_PROCESSING                                                    */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> DUMP_SDF <==                                                        */
 /*     ==> FORMAT                                                          */
 /*     ==> HEX                                                             */
 /*     ==> HEX8                                                            */
 /*     ==> HEX6                                                            */
 /*     ==> PRINT_DATE_AND_TIME                                             */
 /*         ==> CHARDATE                                                    */
 /*         ==> PRINT_TIME                                                  */
 /*             ==> CHARTIME                                                */
 /*     ==> STMT_TO_PTR                                                     */
 /*     ==> SYMB_TO_PTR                                                     */
 /*     ==> BLOCK_TO_PTR                                                    */
 /*     ==> SDF_SELECT                                                      */
 /*     ==> SDF_PTR_LOCATE                                                  */
 /*     ==> SDF_LOCATE                                                      */
 /*         ==> SDF_PTR_LOCATE                                              */
 /*     ==> PAGE_DUMP                                                       */
 /*         ==> HEX                                                         */
 /*         ==> HEX8                                                        */
 /*     ==> BLOCK_NAME                                                      */
 /*     ==> SYMBOL_NAME                                                     */
 /*     ==> PTR_TO_BLOCK                                                    */
 /*         ==> SDF_LOCATE ****                                             */
 /*     ==> PRINT_REPLACE_TEXT                                              */
 /*         ==> SDF_LOCATE ****                                             */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 JAC  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 04/09/91 RSJ  24V0  CR11096  CHANGE PATCH_FLAG FIELD TO                 */
 /*                              DATA_REMOTE                                */
 /*                                                                         */
 /* 12/23/92 PMA  8V0   *        MERGED 7V0 AND 24V0 COMPILERS.             */
 /*                              * REFERENCE 24V0 CR/DRS                    */
 /*                                                                         */
 /* 05/24/93 RAH  25V0  DR105709 FIX PRINTOUT ALIGNMENT IN STATEMENT        */
 /*                9V0           DATA TABLE                                 */
 /*                                                                         */
 /* 09/09/93 LJK  25V1  DR109001 INCORRECT STATEMENT DATA GENERATED BY      */
 /*                9V1           SDFLIST                                    */
 /*                                                                         */
 /* 04/05/94 JAC  26V0  DR108643 INCORRECTLY PRINTS 'NONHAL' INSTEAD OF     */
 /*               10V0           'INCREM'                                   */
 /*                                                                         */
 /* 03/15/95 DAS  27V0  DR103787 WRONG VALUE LOADED FROM REGISTER FOR A     */  01520000
 /*               11V0           STRUCTURE NODE REFERENCE                   */  01530000
 /*                                                                         */  01540000
 /* 11/29/95 SMR  27V1  DR108627 SDFLIST PROCESSES END OF CURRENT CROSS     */  01520000
 /*               11V1           REFERENCE MARKERS INCORRECTLY              */  01530000
 /*                                                                         */  01540000
 /* 05/26/99 SMR  30V0  CR13079  ADD HAL/S INITIALIZATION DATA TO SDF       */  01520000
 /*               15V0                                                      */  01530000
 /*                                                                         */  01540000
 /* 01/12/99 TKN  30V0/ DR111304 EXTRA COMMA IN SDFLIST                     */
 /*               15V0                                                      */
 /*                                                                         */
 /* 03/02/01 DAS  31V0 CR13353 ADD SIZE OF BUILTIN FUNCTIONS XREF TABLE     */
 /*               16V0         INTO SDF                                     */
 /*                                                                         */
 /* 03/02/01 DCP  31V0/  DR111367 ABEND OCCURS FOR A                        */
 /*               16V0            MULTI-DIMENSIONAL ARRAY                   */
 /*                                                                         */
 /* 11/03/00 TKN  31V0/ DR111354 ABEND 4005 IN SDFLIST                      */
 /*               16V0                                                      */
 /*                                                                         */
 /***************************************************************************/
                                                                                00170285
 /* ROUTINE TO DUMP AN SDF VIA SDFPKG */                                        00170300
                                                                                00170400
DUMP_SDF:                                                                       00170500
   PROCEDURE;                                                                   00170600
      DECLARE (FLAG,SADDR,SEXTENT,PTR,PTR1,ADDR1,ADDR2,TEMP) FIXED,             00170700
         (HMAT_PTR,SOFFSET,INCLUDE_PTR) FIXED,                                  00170800
         (I,J,J1,J2,K,K1,K2,L,KLIM,ITEM,LAST_BLOCK,SBLK) BIT(16),               00170900
         (#CHARS,#XREF,TEMP1,TEMP2,TEMP3,TEMP4) BIT(16),                        00171000
         (SCLASS,#BITS,SHIFT,SFLAG,STYPE,NAME_FLAG) BIT(8),                     00171100
         (SRNS,CONST_FLAG,DOUBLE_FLAG,LIT_FLAG,LIT_TYPE) BIT(8),                00171110
         T("25") BIT(8) INITIAL(0,1,0,4,7,0,0,0,0,0,0,0,0,0,0,0,9,              00171120
         0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),                              00171125
         SUBTYPE BIT(8),                                                        00171130
         SUB_STMT_TYPES(10) CHARACTER INITIAL('','EXIT','REPEAT','GO TO',       00171140
         'READ','READALL','WRITE','ASSIGN','NAME ASSIGN','FILE INPUT',          00171150
         'FILE OUTPUT'),                                                        00171160
         TS(10) CHARACTER,                                                      00171200
         (SRN_STRING,INCL_STRING,ADDR1_HEX,ADDR2_HEX,ADDR3_HEX) CHARACTER,      00171300
         (SDF_TITLE) CHARACTER,                                                 00171400
         INCL_FILES(5) CHARACTER INITIAL('INCLUDE','OUTPUT6',                   00171410
         'OUTPUT8','HALSDF','OUTPUT5','??'),                                    00171420
         (NAME,ADDR1_DEC,ADDR2_DEC,ADDR3_DEC,CHAR_STRING) CHARACTER;            00171500
      BASED (NODE_F,NODE_F1) FIXED,                                             00171600
         (NODE_B,NODE_B1) BIT(8),                                               00171700
         NODE_H BIT(16);                                                        00171800
      BASED SYM_SORT RECORD DYNAMIC:         /*CR13079*/
         SYM# BIT(16),                       /*CR13079*/
         OFFSET FIXED,                       /*CR13079*/
      END;                                   /*CR13079*/
      DECLARE SYM#_ARRAY(1) LITERALLY 'SYM_SORT(%1%).SYM#';     /*CR13079*/
      DECLARE OFFSET_ARRAY(1) LITERALLY 'SYM_SORT(%1%).OFFSET'; /*CR13079*/
      DECLARE MAX_ARRAY BIT(16) INITIAL(-1);                    /*CR13079*/

/*CR13079 - INSERT THE OFFSET AND SYMBOL NUMBERS INTO ARRAYS SORTED*/
/* BY OFFSET.                                                      */
INSERT_SORT:
      PROCEDURE(SIZE,OFF,SYM);
         DECLARE OFF FIXED;
         DECLARE (SIZE,SYM) BIT(16);
         DECLARE I BIT(16);
         I = SIZE;
         DO WHILE (I > 0) & (OFFSET_ARRAY(I-1) > OFF);
            OFFSET_ARRAY(I) = OFFSET_ARRAY(I-1);
            SYM#_ARRAY(I) = SYM#_ARRAY(I-1);
            I = I - 1;
         END;
         OFFSET_ARRAY(I) = OFF;
         SYM#_ARRAY(I) = SYM;
END INSERT_SORT;

/*CR13079 - PRINT THE #D/#P INFORMATION AT THE END OF THE LISTING*/
PRINT_#D_INFO:
      PROCEDURE(INFO_FLAG);
      DECLARE INFO_FLAG BIT(1);  /*TRUE IF EXTRA INFORMATION IS TO BE PRINTED*/
      DECLARE (CLASS,TYPE) BIT(16), IJ FIXED;      /*DR111367*/
      DECLARE TMPC CHARACTER;
      DECLARE (SIZE,FLAGS) BIT(32);
      DECLARE OLD_OFFSET FIXED;
      OLD_OFFSET = 0;
      IF ^INFO_FLAG THEN OUTPUT = '#DLIST';
      DO I = 0 TO MAX_ARRAY;
         SYMBNO = SYM#_ARRAY(I);
         CALL MONITOR(22,9);
         NAME = SYMBOL_NAME(SYM#_ARRAY(I));
         CLASS = COREBYTE(ADDRESS+6);
         TYPE =  COREBYTE(ADDRESS+7);
         FLAGS = COREWORD(ADDRESS+8);
         IF INFO_FLAG THEN
           OUTPUT = 'SYM # '||SYM#_ARRAY(I)||'; NAME = '||NAME||
           '; BLOCK # = '||BLKNO;
         IF CRETURN = 0 THEN DO;
            IF (FLAGS & "04000000") ^= 0 THEN DO; /*NAME VARIABLE*/
              IF (FLAGS & "00010000") ^= 0 THEN SIZE=2; /*REMOTE NAME*/
              ELSE SIZE=1;
            END;
            ELSE SIZE   = COREWORD(ADDRESS+20) & "FFFFFF";
            IF INFO_FLAG THEN DO;
              OUTPUT = '  LOCATED '||NAME||'; SYMBNO = '||SYMBNO||
              '; OFFSET = '||(COREWORD(ADDRESS+12) & "FFFFFF");
              OUTPUT = '  SIZE = '||SIZE||'; CLASS = '||CLASS||
              '; TYPE = '||COREBYTE(ADDRESS+7);
              IF (FLAGS & "04000000") ^= 0 THEN OUTPUT = '  NAME VARIABLE';
            END;
            CALL MONITOR(22,18); /* LOCATE INITIAL DATA */
            IF (I > 0) & (^INFO_FLAG) THEN DO;  /* PRINT ANY GAPS */
              DO IJ=1 TO (OFFSET_ARRAY(I)-OLD_OFFSET);
                OUTPUT = '0000';
              END;
            END;
            IJ,J = 0;
            DO WHILE (IJ <= (SIZE-1)*2);
              IF ((((OFFSET_ARRAY(I)+(IJ/2))*2) MOD PAGE_SIZE) = 0) &
              (IJ ^= 0)  THEN DO;
                PNTR = PNTR & "FFFF 0000";
                PNTR = PNTR + "1 0000";
                CALL MONITOR(22,5);
                J = 0;
              END;
              TMPC = HEX(COREHALFWORD(ADDRESS+J),4);
              IF INFO_FLAG THEN
                OUTPUT= '     '||HEX(OFFSET_ARRAY(I)+(IJ/2),4)||': '
                ||SUBSTR(TMPC,LENGTH(TMPC)-4,4);
              ELSE DO;
                IF (FLAGS & "04000000") ^= 0 THEN /*NAME VARIABLE*/
                   OUTPUT = SUBSTR(TMPC,LENGTH(TMPC)-4,4)||'NAME';
                ELSE OUTPUT = SUBSTR(TMPC,LENGTH(TMPC)-4,4);
              END;
              IJ = IJ + 2;
              J = J + 2;;
            END;
            OLD_OFFSET = OFFSET_ARRAY(I) + (IJ/2);
         END;
         ELSE IF CRETURN = 20 THEN
            OUTPUT = '  '||NAME||' NOT FOUND';
      END;
   END PRINT_#D_INFO;

PRINT_ADDRS:                                                                    00172000
      PROCEDURE;                                                                00172100
         ADDR1_HEX = HEX8(SADDR);                                               00172200
         ADDR2_HEX = HEX8(SEXTENT);                                             00172300
         ADDR1_DEC = FORMAT(SADDR,6);                                           00172400
         ADDR2_DEC = FORMAT(SEXTENT,6);                                         00172500
         IF SOFFSET > 0 THEN DO;                                                00172600
            ADDR3_HEX = HEX8(SOFFSET);                                          00172700
            ADDR3_DEC = FORMAT(SOFFSET,6);                                      00172800
            TS(2) = X2 || 'BIAS = ' ||                                          00172900
               ADDR3_HEX || '(' || ADDR3_DEC || ')';                            00173000
         END;                                                                   00173100
         ELSE TS(2) = '';                                                       00173200
         TS = X10 || 'ADDRESS = ';                                              00173300
         TS(1) = X2 || 'SIZE = ';                                               00173400
         OUTPUT = TS || ADDR1_HEX || '(' ||                                     00173500
            ADDR1_DEC || ')' || TS(1) ||                                        00173600
            ADDR2_HEX || '(' || ADDR2_DEC || ')' || TS(2);                      00173700
      END;                                                                      00173800
                                                                                00173900
 /* ROUTINE TO CONVERT SCALAR LIT TO INTEGER AND CHECK RANGE */                 00173901
INTEGERIZABLE:                                                                  00173902
      PROCEDURE;                                                                00173903
         DECLARE LIT_NEGMAX LABEL, FLT_NEGMAX FIXED INITIAL("C8800000");        00173904
         DECLARE NEGMAX FIXED INITIAL("80000000"), NEGLIT BIT(8);               00173905
         DECLARE (TEMP,TEMP1) FIXED;                                            00173906
                                                                                00173907
         CALL INLINE("58",1,0,FOR_DW);                                          00173908
         CALL INLINE("68", 0, 0, 1, 0);              /* LE 0,0(0,1) */          00173909
         IF DW(0) = "FF000000" THEN DO;                                         00173910
NO_INTEGER: RETURN FALSE;                                                       00173911
         END;                                                                   00173912
         TEMP = ADDR(NO_INTEGER);                                               00173913
         TEMP1 = ADDR(LIT_NEGMAX);                                              00173914
         CALL INLINE("28", 2, 0);                    /* LDR 2,0     */          00173915
         CALL INLINE("20", 0, 0);                    /* LPDR 0,0    */          00173916
         CALL INLINE("2B", 4, 4);                    /* SDR 4,4     */          00173917
         CALL INLINE("78", 4, 0, FLT_NEGMAX);        /* LE 4,FLT_NEGMAX */      00173918
         CALL INLINE("58", 2, 0, TEMP1);             /* L 2,TEMP1   */          00173919
         CALL INLINE("29", 4, 2);                    /* CDR 4,2     */          00173920
         CALL INLINE("07", 8, 2);                    /* BCR 8,2     */          00173921
         CALL INLINE("58", 1, 0, ADDR_ROUNDER);      /* L 1,ADDR_ROUNDER */     00173922
         CALL INLINE("6A", 0, 0, 1, 0);              /* AD 0,0(0,1) */          00173923
         CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);  /* L 1,ADDR__LIMIT */      00173924
         CALL INLINE("58", 2, 0, TEMP);              /* L 2,TEMP    */          00173925
         CALL INLINE("69", 0, 0, 1, 0);              /* CD 0,0(0,1) */          00173926
         CALL INLINE("07", 2, 2);                    /* BCR 2,2     */          00173927
LIT_NEGMAX:                                                                     00173928
         CALL INLINE("58", 1, 0, ADDR_FIXER);        /* L 1,ADDR_FIXER */       00173929
         CALL INLINE("6E", 0, 0, 1, 0);              /* AW 0,0(0,1) */          00173930
         CALL INLINE("58",1,0,FOR_DW);                                          00173931
         CALL INLINE("60", 0, 0, 1, 8);              /* STD 0,8(0,1) */         00173932
         CALL INLINE("70", 2, 0, 1, 8);              /* STE 2,8(0,1) */         00173933
         NEGLIT = SHR(DW(2), 31);                                               00173934
         IF NEGLIT THEN DO;                                                     00173935
            IF DW(3) ^= NEGMAX THEN DW(3) = -DW(3);                             00173936
         END;                                                                   00173937
         RETURN TRUE;                                                           00173938
      END INTEGERIZABLE;                                                        00173939
                                                                                00173940
      CALL SDF_SELECT;                                                          00174000
      IF TABDMP THEN DO;                                                        00174100
         CHAR_STRING = ' DEC   HEX  -HEX    PTR      BLOCK NAME '               00174200
            || '                     PTR    BLK#    SYMBOL NAME';               00174300
         CHAR_STRING = CHAR_STRING || X20 ||                                    00174500
            'PTR      SRN   COUNT';                                             00174600
         OUTPUT(1) = '1';                                                       00174700
         OUTPUT(1) = '2'||CHAR_STRING;                                          00174800
         OUTPUT = CHAR_STRING;                                                  00174900
         OUTPUT = X1;                                                           00175000
         KLIM = LAST_STMT;                                                      00175100
         IF KLIM < #SYMBOLS THEN KLIM = #SYMBOLS;                               00175200
         DO K = 1 TO KLIM;                                                      00175300
            TS = FORMAT(K,4)||X2;                                               00175400
            TS(1) = HEX(K,4)||X2;                                               00175500
            TEMP = (-K) & "FFFF";                                               00175600
            TS(10) = HEX(TEMP,4) || X2;                                         00175700
            IF #PROCS >= K THEN DO;                                             00175800
               PTR = BLOCK_TO_PTR(K);                                           00175900
               TS(2) = HEX8(PTR)||X2;                                           00176000
               TS(3) = BLOCK_NAME(K);                                           00176100
               TMP = LENGTH(TS(3));                                             00176200
               IF TMP > 28 THEN TS(3) = SUBSTR(TS(3),0,28);                     00176300
               ELSE IF TMP < 28 THEN DO;                                        00176400
                  NAME = TS(3) || SUBSTR(X72,0,28-TMP);                         00176500
                  TS(3) = NAME;                                                 00176600
               END;                                                             00176700
               TS(3) = TS(3)||X2;                                               00176800
            END;                                                                00176900
            ELSE DO;                                                            00177000
               TS(2) = X10;                                                     00177100
 /* PRINTS OUT THE CONCATENATED S ARRAY */                                      00177101
FLUSH:                                                                          00177102
               PROCEDURE (LAST,STMT_VARS);                                      00177103
                  DECLARE (LAST,I,J,K,STMT_VARS) BIT(16), STRING CHARACTER;     00177104
                  DECLARE X13 CHARACTER INITIAL('             ');               00177105
                                                                                00177106
                  IF STMT_VARS & LENGTH(S)>0 THEN DO;                           00177107
                     I = LENGTH(S);                                             00177108
                     DO K = 1 TO LAST;                                          00177109
                        I = I + LENGTH(S(K));                                   00177110
                     END;                                                       00177111
                     IF I < LINELENGTH THEN DO;                                 00177112
                        STRING = '';                                            00177113
                        GO TO IT_FITS;                                          00177114
                     END;                                                       00177115
                     OUTPUT = S;                                                00177116
                     S = '';                                                    00177117
                     J = 1;                                                     00177118
                  END;                                                          00177119
                  STRING = X10;                                                 00177120
IT_FITS:                                                                        00177121
                  DO WHILE J <= LAST;                                           00177122
                     IF LENGTH(STRING) + LENGTH(S(J)) < LINELENGTH THEN DO;     00177123
                        STRING = STRING || S(J);                                00177124
                        S(J) = '';                                              00177125
                        J = J + 1;                                              00177126
                     END;                                                       00177127
                     ELSE DO;                                                   00177128
                        I,K = LINELENGTH - LENGTH(STRING) - 1;                  00177129
               DO WHILE BYTE(S(J),I)^=BYTE(' ') & BYTE(S(J),I)^=BYTE(',') & I>0;00177130
                           I = I - 1;                                           00177131
                        END;                                                    00177132
                        IF I=0 THEN DO;                                         00177133
                           I = K;                                               00177134
                           DO WHILE BYTE(S(J),I)^=BYTE('.') & I>0;  /*DR111304*/00177135
                              I = I - 1;                                        00177136
                           END;                                                 00177137
                           IF I = 0 THEN I = K;                                 00177138
                        END;                                                    00177139
                        OUTPUT = STRING || SUBSTR(S(J),0,I+1);                  00177140
                        S(J) = SUBSTR(S(J),I+1);                                00177141
                        STRING = X13;                                           00177142
                     END;                                                       00177143
                  END;                                                          00177144
                  J,L,STMT_VARS = 0;                                            00177145
                  OUTPUT = STRING;                                              00177146
               END FLUSH;                                                       00177147
                                                                                00177148
 /* ADDS VMEM CELL PTR TO STACK */                                              00177149
STACK_PTR:                                                                      00177150
               PROCEDURE (PTR);                                                 00177151
                  DECLARE PTR FIXED;                                            00177152
                                                                                00177153
                  PTR_INX = PTR_INX + 1;                                        00177154
          IF PTR_INX > RECORD_TOP(CELL_PTR_REC) THEN NEXT_ELEMENT(CELL_PTR_REC);00177155
                  CELL_PTRS(PTR_INX) = PTR;                                     00177159
               END STACK_PTR;                                                   00177160
                                                                                00177161
STACK_STRING:                                                                   00177162
               PROCEDURE (STRING);                                              00177163
                  DECLARE STRING CHARACTER;                                     00177164
                                                                                00177165
                  VN_INX = VN_INX + 1;                                          00177166
             IF VN_INX > RECORD_TOP(VARNAME_REC) THEN NEXT_ELEMENT(VARNAME_REC);00177167
                  VARNAME(VN_INX) = STRING;                                     00177171
                  CALL STACK_PTR("C0000000" | VN_INX);                          00177172
               END STACK_STRING;                                                00177173
                                                                                00177174
FORMAT_FORM_PARM_CELL:                                                          00177175
               PROCEDURE (SYMB#,PTR) ;                                          00177176
                  DECLARE (J,K,SYMB#) BIT(16), PTR FIXED;                       00177177
                                                                                00177178
                  S = S || SYMBOL_NAME(SYMB#);                                  00177179
                  CALL SDF_LOCATE(PTR,ADDR(VMEM_H),RESV);                       00177180
                  COREWORD(ADDR(VMEM_B)) = LOC_ADDR;                            00177181
                  K = 0;                                                        00177182
                  S = S || '(';                                                 00177183
                  IF VMEM_B(3) > 0 THEN DO;                                     00177184
                     DO J = 2 TO VMEM_B(3) + 1;                                 00177185
                        IF LENGTH(S(K)) > LINELENGTH THEN K = K + 1;            00177186
                        S(K) = S(K) || SYMBOL_NAME(VMEM_H(J)) || ',';           00177187
                     END;                                                       00177188
                     BYTE(S(K),LENGTH(S(K))-1) = BYTE(')');                     00177189
                  END;                                                          00177190
                  ELSE S = S || ')';                                            00177191
                  IF VMEM_B(2) > VMEM_B(3) THEN DO;                             00177192
                     S(K) = S(K) || ' ASSIGN(';                                 00177193
                     DO J = VMEM_B(3)+2 TO VMEM_B(2)+1;                         00177194
                        IF LENGTH(S(K)) > LINELENGTH THEN K = K + 1;            00177195
                        S(K) = S(K) || SYMBOL_NAME(VMEM_H(J)) || ',';           00177196
                     END;                                                       00177197
                     BYTE(S(K),LENGTH(S(K))-1) = BYTE(')');                     00177198
                  END;                                                          00177199
                  CALL SDF_PTR_LOCATE(PTR,RELS);                                00177200
                  CALL FLUSH(K);                                                00177201
               END FORMAT_FORM_PARM_CELL;                                       00177202
                                                                                00177203
FORMAT_VAR_REF_CELL:                                                            00177204
               PROCEDURE (PTR,NO_PRINT) CHARACTER;                              00177205
                  DECLARE (#SYTS,J,LAST_SUB_TYPE) BIT(16), PTR FIXED,           00177206
                     (NO_PRINT,SUBSCRIPTS,ALPHA,SUB_TYPE,BETA,EXP_TYPE) BIT(8), 00177207
                     SUB_STRINGS(2) CHARACTER INITIAL('',':',';'),              00177208
                     EXP_STRINGS(4) CHARACTER INITIAL('','#+','#-','','#'),     00177209
                     MSG(4) CHARACTER;                                          00177210
                                                                                00177211
                  CALL SDF_LOCATE(PTR,ADDR(VMEM_H),RESV);                       00177212
                  COREWORD(ADDR(VMEM_F)) = LOC_ADDR;                            00177213
                  IF VMEM_H(1) < 0 THEN DO;                                     00177214
                     SUBSCRIPTS = TRUE;                                         00177215
                     #SYTS = VMEM_H(1) & "7FFF";                                00177216
                  END;                                                          00177217
                  ELSE DO;                                                      00177218
                     SUBSCRIPTS = FALSE;                                        00177219
                     #SYTS = VMEM_H(1);                                         00177220
                  END;                                                          00177221
                  IF #SYTS = 1 THEN MSG(2) = ' ' || VMEM_H(4);                  00177222
                  ELSE MSG(2) = ' ('||VMEM_H(4);                                00177223
                  MSG = SYMBOL_NAME(VMEM_H(4));                                 00177224
                  DO J = 5 TO #SYTS+3;                                          00177225
                     MSG(2) = MSG(2) || ',' || VMEM_H(J);                       00177226
                     MSG = MSG || '.' || SYMBOL_NAME(VMEM_H(J));                00177227
                  END;                                                          00177228
                  IF #SYTS = 1 THEN MSG = MSG(2) || '=' || MSG;                 00177229
                  ELSE MSG = MSG(2) || ')=' || MSG;                             00177230
                  IF ^SUBSCRIPTS THEN DO;                                       00177231
                     CALL SDF_PTR_LOCATE(PTR,RELS);                             00177232
                     IF NO_PRINT THEN DO;                                       00177233
                        IF LENGTH(S(L)) > LINELENGTH THEN L = L + 1;            00177234
                        S(L) = S(L) || MSG;                                     00177235
                        NO_PRINT = FALSE;                                       00177236
                     END;                                                       00177237
                     RETURN MSG;                                                00177238
                  END;                                                          00177239
                  J = #SYTS + 4;                                                00177240
                  MSG(1) = '$(';                                                00177241
                  MSG(2), MSG(3) = '';                                          00177242
                  LAST_SUB_TYPE = -1;                                           00177243
                  DO WHILE J <= SHR(VMEM_H(0),1) - 1;                           00177244
                     ALPHA = SHR(VMEM_H(J),8) & 3;                              00177245
                     SUB_TYPE = SHR(VMEM_H(J),10) & 3;                          00177246
                     BETA = VMEM_H(J) & "F";                                    00177247
                     EXP_TYPE = SHR(VMEM_H(J),4) & "F";                         00177248
                     MSG(3) = MSG(3) || EXP_STRINGS(SHR(EXP_TYPE,1));           00177249
                     IF EXP_TYPE THEN DO;                                       00177250
                        J = J + 1;                                              00177251
                        MSG(3) = MSG(3) || VMEM_H(J);                           00177252
                     END;                                                       00177253
                     ELSE MSG(3) = MSG(3) || '?';                               00177254
                     DO CASE ALPHA;                                             00177255
                        MSG(3) = '*';                                           00177256
                        ;                                                       00177257
                        IF BETA THEN MSG(3) = MSG(3) || ' TO ';                 00177258
                        IF BETA THEN MSG(3) = MSG(3) || ' AT ';                 00177259
                     END;                                                       00177260
                     IF BETA = 0 THEN DO;                                       00177261
                        IF LAST_SUB_TYPE >= 0 THEN                              00177262
              IF SUB_TYPE^=LAST_SUB_TYPE THEN MSG(2)=SUB_STRINGS(LAST_SUB_TYPE);00177263
                        ELSE MSG(2) = ',';                                      00177264
                        LAST_SUB_TYPE = SUB_TYPE;                               00177265
                        MSG(1) = MSG(1) || MSG(2) || MSG(3);                    00177266
                        MSG(3) = '';                                            00177267
                     END;                                                       00177268
                     J = J + 1;                                                 00177269
                  END;                                                          00177270
           IF SUB_TYPE=1 | SUB_TYPE=2 THEN MSG(1)=MSG(1)||SUB_STRINGS(SUB_TYPE);00177271
                  MSG(2), MSG(3) = '';                                          00177272
                  IF VMEM_F(1) ^= 0 THEN DO;                                    00177273
                     MSG(1) = MSG(1) || '):';                                   00177274
                     CALL STACK_STRING(',');                                    00177275
                     CALL STACK_PTR(VMEM_F(1) | "80000000");                    00177276
                  END;                                                          00177277
                  ELSE IF NO_PRINT THEN MSG(1) = MSG(1) || '),';                00177278
                  ELSE MSG(1) = MSG(1) || ')';                                  00177279
                  CALL SDF_PTR_LOCATE(PTR,RELS);                                00177280
                  IF NO_PRINT THEN DO;                                          00177281
                     DO J = 0 TO 1;                                             00177282
                        IF LENGTH(S(L)) > LINELENGTH THEN L = L + 1;            00177283
                        S(L) = S(L) || MSG(J);                                  00177284
                     END;                                                       00177285
                     NO_PRINT = FALSE;                                          00177286
                     RETURN;                                                    00177287
                  END;                                                          00177288
                  ELSE RETURN MSG || MSG(1);                                    00177289
               END FORMAT_VAR_REF_CELL;                                         00177290
                                                                                00177291
FORMAT_EXP_VARS_CELL:                                                           00177292
               PROCEDURE (PTR,OUTER);                                           00177293
                  DECLARE (I,J,K,M,#SYTS,OUTER) BIT(16), PTR FIXED;             00177294
                  DECLARE STRING CHARACTER;                                     00177295
                                                                                00177296
                  CALL SDF_LOCATE(PTR,ADDR(VMEM_H),RESV);                       00177297
                  COREWORD(ADDR(VMEM_F)) = LOC_ADDR;                            00177298
                  #SYTS = VMEM_H(1);                                            00177299
                  IF ^OUTER THEN DO;                                            00177300
                     S(L) = S(L) || '(';                                        00177301
                     CALL STACK_PTR("C0000000");                                00177302
                  END;                                                          00177303
                  IF #SYTS > 0 THEN DO;                                         00177304
                     J = 2;                                                     00177305
                     DO WHILE J<=#SYTS+1;                                       00177306
                        IF LENGTH(S(L)) > LINELENGTH THEN L = L + 1;            00177307
                 IF VMEM_H(J) >= 0 THEN S(L) = S(L)|| ' ' || VMEM_H(J) || '=' ||00177308
                           SYMBOL_NAME(VMEM_H(J)) || ',';                       00177309
                        ELSE DO;                                                00177310
                           J = J + 1;                                           00177311
                           S(L) = S(L) || ' (' || VMEM_H(J);                    00177312
                           STRING = SYMBOL_NAME(VMEM_H(J));                     00177313
                           DO K = 2 TO -VMEM_H(J-1);                            00177314
                              J = J + 1;                                        00177315
                              S(L) = S(L) || ',' || VMEM_H(J);                  00177316
                              STRING = STRING||'.'||SYMBOL_NAME(VMEM_H(J));     00177317
                           END;                                                 00177318
                           S(L) = S(L) || ')=' || STRING || ',';                00177319
                        END;                                                    00177320
                        J = J + 1;                                              00177321
                     END;                                                       00177322
                  END;                                                          00177323
                  I = SHR(#SYTS+3,1);                                           00177324
                  K = SHR(VMEM_H(0),2)-1;                                       00177325
                  DO J = I TO K;                                                00177326
                     M = I + K - J;                                             00177327
                     IF LENGTH(S(L)) > LINELENGTH THEN L = L + 1;               00177328
                     IF (VMEM_F(M) & "C0000000") = "C0000000" THEN DO;          00177329
               /******  DR109001  LJK 9/9/93           ***********/
               /*       CHANGE VMEM_F(J) REFERENCE TO VMEM_F(M)  */
                        STRING = VMEM_F(M) & "3FFFFFFF";
               /******  END DR109001                   ***********/
                        CALL STACK_STRING(' '||STRING);                         00177331
                     END;                                                       00177332
                     ELSE DO;                                                   00177333
                        CALL STACK_PTR(VMEM_F(M));                              00177334
                     END;                                                       00177335
                  END;                                                          00177336
                  CALL SDF_PTR_LOCATE(PTR,RELS);                                00177337
               END FORMAT_EXP_VARS_CELL;                                        00177338
DUMP_HALMAT:                                                                    00177348
               PROCEDURE(PTR);                                                  00177358
                  DECLARE (PTR,HPTR,TEMP) FIXED,                                00177368
                     (I,#WORDS,HCELL) BIT(16);                                  00177378
                  BASED NODE_F FIXED;                                           00177388
                                                                                00177398
FORMAT_HMAT:                                                                    00177408
                  PROCEDURE(ATOM);                                              00177418
                     DECLARE ATOM FIXED;                                        00177428
                     DECLARE PROD BIT(16);                                      00177438
                     DECLARE C CHARACTER,                                       00177448
                        BLAB1 CHARACTER INITIAL('0ND   X'),                     00177458
                        BLAB2 CHARACTER                                         00177468
  INITIAL('  0 SYT INL VAC XPT LIT IMD AST CSZ ASZ OFF                       ');00177478
                     DECLARE (ICNT,J) BIT(16);                                  00177488
                     DECLARE OPERAND(1) LITERALLY '%1%';                        00177498
                                                                                00177508
                     IF OPERAND(ATOM)                                           00177518
                        THEN DO;                                                00177528
                        C = HEX(SHR(ATOM,1)&"7",1);                             00177538
                        C = HEX(SHR(ATOM,8)&"FF",1) || ',' || C;                00177548
                        C = SUBSTR(BLAB2,SHR(ATOM,2)&"3C",3) || ')' || C;       00177558
                        J = SHR(ATOM,16);                                       00177568
                        C = FORMAT(J,7) || '(' || C;                            00177578
                        C = '  :' || C;                                         00177588
                        IF ICNT = 4                                             00177598
                           THEN DO;                                             00177608
                           ICNT = 1;                                            00177618
                           C = SUBSTR(X72,0,36) || C;                           00177628
                        END;                                                    00177638
                        ELSE DO;                                                00177648
                           PROD = ICNT*17+36;                                   00177658
                           C = '+' || SUBSTR(X72,0,PROD) || C;                  00177678
                           ICNT = ICNT+1;                                       00177688
                        END;                                                    00177698
                     END;                                                       00177708
                     ELSE DO;                                                   00177718
                        C = HEX(SHR(ATOM,24),1);                                00177728
                        C = ')' || SUBSTR(BLAB1,SHR(ATOM,1)&"7",1) || ',' || C; 00177738
                        C = FORMAT(SHR(ATOM,16)&"FF",3) || C;                   00177748
                        C = '      ' || HEX(SHR(ATOM,4)&"FFF",3) || '(' || C;   00177758
                        ICNT = 0;                                               00177768
                     END;                                                       00177778
                     OUTPUT(1) = C;                                             00177788
                  END FORMAT_HMAT;                                              00177798
                                                                                00177808
                  IF PTR = NILL                                                 00177818
                     THEN DO;                                                   00177828
                     OUTPUT = '    NO HALMAT';                                  00177838
                     RETURN;                                                    00177848
                  END;                                                          00177858
                  ELSE OUTPUT = '    HALMAT:';                                  00177868
                  HPTR = PTR;                                                   00177878
                  CALL SDF_LOCATE(HPTR,ADDR(NODE_F),RESV);                      00177888
                  HCELL = 1;                                                    00177898
                  #WORDS = SHR(NODE_F(0),16);  /* # OF HALMAT WORDS IN STMT */  00177908
                  DO I = 1 TO #WORDS;                                           00177918
                     IF NODE_F(HCELL) = POINTER_PREFIX                          00177928
                        THEN DO;                                                00177938
                        TEMP = NODE_F(HCELL+1);                                 00177948
                        CALL SDF_PTR_LOCATE(HPTR,RELS);                         00177958
                        CALL SDF_LOCATE(TEMP,ADDR(NODE_F),RESV);                00177968
                        HPTR = TEMP;                                            00177978
                        HCELL = 0;                                              00177988
                     END;                                                       00177998
                     CALL  FORMAT_HMAT(NODE_F(HCELL));                          00178008
                     HCELL = HCELL+1;                                           00178018
                  END;                                                          00178028
 /* OUTPUT = X1; */                                                             00178038
                  CALL SDF_PTR_LOCATE(HPTR,RELS);                               00178048
               END DUMP_HALMAT;                                                 00178058
                                                                                00178068
FORMAT_PF_INV_CELL:                                                             00178078
               PROCEDURE (PTR);                                                 00178088
                  DECLARE (#ASSIGN,J,K,SYMB) BIT(16), PTR FIXED;                00178098
                                                                                00178108
                  CALL SDF_LOCATE(PTR,ADDR(VMEM_H),RESV);                       00178118
                  COREWORD(ADDR(VMEM_F)) = LOC_ADDR;                            00178128
            S(L) = S(L)||' '||VMEM_H(3) || '=' || SYMBOL_NAME(VMEM_H(3)) || '(';00178138
                  #ASSIGN = VMEM_H(1) - VMEM_H(2);                              00178148
                  CALL STACK_STRING(',');                                       00178158
                  CALL STACK_PTR("C0000000");                                   00178168
                  IF #ASSIGN>0 THEN DO;                                         00178178
                     DO J = 1 TO #ASSIGN;                                       00178188
                        K = VMEM_H(1) + 2 - J;                                  00178198
                        IF VMEM_F(K) = 0 THEN CALL STACK_STRING(' -,');         00178208
                        ELSE IF (VMEM_F(K) & "C0000000") = "C0000000" THEN DO;  00178218
                           SYMB = VMEM_F(K) & "3FFFFFFF";                       00178228
                      CALL STACK_STRING(' '||SYMB||'='||SYMBOL_NAME(SYMB)||',');00178238
                        END;                                                    00178248
                        ELSE DO;                                                00178258
                           IF (VMEM_F(K)&"C0000000")="80000000" THEN DO;        00178268
                              CALL STACK_STRING(',');                           00178278
                              CALL STACK_PTR(VMEM_F(K));                        00178288
                              CALL STACK_STRING(' ');                           00178298
                           END;                                                 00178308
                           ELSE CALL STACK_PTR(VMEM_F(K));                      00178318
                        END;                                                    00178328
                     END;                                                       00178338
                     CALL STACK_STRING('  ASSIGN(');                            00178348
                     CALL STACK_PTR("C0000000");                                00178358
                  END;                                                          00178368
                  IF VMEM_H(2) > 0 THEN DO;                                     00178378
                     DO J = 1 TO VMEM_H(2);                                     00178388
                        K = VMEM_H(2) + 2 - J;                                  00178398
                        IF VMEM_F(K) = 0 THEN CALL STACK_STRING(' -,');         00178408
                        ELSE IF(VMEM_F(K) & "C0000000") = "C0000000" THEN DO;   00178418
                           SYMB = VMEM_F(K) & "3FFFFFFF";                       00178428
                      CALL STACK_STRING(' '||SYMB||'='||SYMBOL_NAME(SYMB)||',');00178438
                        END;                                                    00178448
                        ELSE DO;                                                00178458
                           IF (VMEM_F(K) & "C0000000") = "80000000" THEN DO;    00178468
                              CALL STACK_STRING(',');                           00178478
                              CALL STACK_PTR(VMEM_F(K));                        00178488
                              CALL STACK_STRING(' ');                           00178498
                           END;                                                 00178508
                           ELSE CALL STACK_PTR(VMEM_F(K));                      00178518
                        END;                                                    00178528
                     END;                                                       00178538
                  END;                                                          00178548
                  CALL SDF_PTR_LOCATE(PTR,RELS);                                00178558
               END FORMAT_PF_INV_CELL;                                          00178568
                                                                                00178578
 /* ROUTINE TO FORMAT AND PRINT A LINKED TREE OF VMEM CELLS */                  00178588
FORMAT_CELL_TREE:                                                               00178598
               PROCEDURE (PTR,STMT_VARS);                                       00178608
                  DECLARE (PTR_TYPE,OUTER,STMT_VARS) BIT(8), PTR FIXED;         00178618
                                                                                00178628
                  OUTER = TRUE;                                                 00178638
                  PTR_INX = 1;                                                  00178648
                  CELL_PTRS(PTR_INX) = PTR;                                     00178658
                  DO WHILE PTR_INX > 0;                                         00178668
                     PTR = CELL_PTRS(PTR_INX);                                  00178678
                     PTR_INX = PTR_INX - 1;                                     00178688
                     PTR_TYPE = SHR(PTR,30) & 3;                                00178698
                     PTR = PTR & "3FFFFFFF";                                    00178708
                     DO CASE PTR_TYPE;                                          00178718
                        CALL FORMAT_VAR_REF_CELL(PTR,1);                        00178728
                        CALL FORMAT_PF_INV_CELL(PTR);                           00178738
                        DO;                                                     00178748
                           CALL FORMAT_EXP_VARS_CELL(PTR,OUTER);                00178758
                           OUTER = FALSE;                                       00178768
                        END;                                                    00178778
                        DO;                                                     00178788
                           IF PTR = 0 THEN DO;                                  00178798
                              IF BYTE(S(L),LENGTH(S(L))-1) = BYTE(',') THEN     00178808
                                 S(L) = SUBSTR(S(L),0,LENGTH(S(L))-1);          00178818
                              S(L) = S(L) || ' )';                              00178828
                           END;                                                 00178838
                           ELSE DO;                                             00178848
                              IF LENGTH(S(L)) > LINELENGTH THEN L = L + 1;      00178858
                              S(L) = S(L) || VARNAME(PTR);                      00178868
                              VN_INX = PTR - 1;                                 00178878
                           END;                                                 00178888
                        END;                                                    00178898
                     END;                                                       00178908
                  END;                                                          00178918
                  IF BYTE(S(L),LENGTH(S(L))-1) = BYTE(',') THEN                 00178928
                     S(L) = SUBSTR(S(L),0,LENGTH(S(L))-1);                      00178938
                  CALL FLUSH(L,STMT_VARS);                                      00178948
               END FORMAT_CELL_TREE;                                            00178958
                                                                                00178968
 /* FORMATS AND PRINTS A CHAIN OF NAME TERMINAL INITIALIZATION CELLS */         00178978
FORMAT_NAME_TERM_CELLS:                                                         00178988
               PROCEDURE (SYMB#,PTR);                                           00178998
                  DECLARE (#SYTS,SYMB#,J,K,WORDTYPE,FIRSTWORD) BIT(16);         00179008
                  DECLARE (NEXT_CELL,PTR,PTR_TEMP) FIXED;                       00179018
                  DECLARE TEMPNAME CHARACTER;                                   00179028
                  BASED VMEM_F FIXED, VMEM_H BIT(16);                           00179038
                                                                                00179048
                  OUTPUT = X10 ||                                               00179058
         'INITIAL VALUES FOR NAME TERMINALS IN STRUCTURE: '||SYMBOL_NAME(SYMB#);00179068
                  DO WHILE PTR ^= 0;                                            00179078
                     CALL SDF_LOCATE(PTR,ADDR(VMEM_F),RESV);                    00179088
                     NEXT_CELL = VMEM_F(1);                                     00179098
                     COREWORD(ADDR(VMEM_H)) = LOC_ADDR;                         00179108
                     K = 0;                                                     00179118
                     #SYTS = VMEM_H(1);                                         00179128
                     FIRSTWORD = (#SYTS+5) & "FFFE";                            00179138
                     S = SYMBOL_NAME(VMEM_H(4));                                00179148
                     DO J = 5 TO #SYTS+3;                                       00179158
                        S = S || '.' || SYMBOL_NAME(VMEM_H(J));                 00179168
                     END;                                                       00179178
                     S = S || ' --> ';                                          00179188
                     J = FIRSTWORD;                                             00179198
                     IF VMEM_H(J) = 3 THEN DO;                                  00179208
                        S = S || 'ALL COPIES NULL.';                            00179218
                        CALL FLUSH(0);                                          00179228
                        GO TO DONETOO;                                          00179238
                     END;                                                       00179248
                     DO FOREVER;                                                00179258
                        WORDTYPE = VMEM_H(J);                                   00179268
                        IF WORDTYPE<0 | WORDTYPE>3 THEN GO TO DONE;             00179278
                        IF LENGTH(S(K)) > LINELENGTH THEN                       00179288
                           IF K >= MAXLINES THEN DO;                            00179289
                           CALL FLUSH(K);                                       00179290
                           K = 0;                                               00179291
                        END;                                                    00179292
                        ELSE K = K + 1;                                         00179293
                        DO CASE WORDTYPE;                                       00179298
                           DO;  /* 0 = INITIAL POINTER VALUE */                 00179308
                              PTR_TEMP = VMEM_F(SHR(J+2,1));                    00179318
                              IF PTR_TEMP>0 THEN DO;                            00179328
 /*  GET NAME OF VARIABLE USED IN NAME VAR.                                     00179338
                   KILLED OPTIMIZATION THAT HAD BEEN HERE.  SIMILAR             00179348
                   PROCEDURE IN FLOGEN. */                                      00179358
                        TEMPNAME = SUBSTR(' '||FORMAT_VAR_REF_CELL(PTR_TEMP),1);00179368
                                 S(K) = S(K)||VMEM_H(J+1)||':'||TEMPNAME||',';  00179378
                              END;                                              00179458
                           ELSE S(K) = S(K)||VMEM_H(J+1)||': '||VMEM_H(J+3)||'='00179468
                                 ||SYMBOL_NAME(VMEM_H(J+3))||',';               00179478
                              J = J + 4;                                        00179488
                           END;                                                 00179498
                           DO;  /* 1 = REPETITION FACTOR */                     00179508
                        S(K) = S(K)||'('||VMEM_H(J+2)||'#,+'||VMEM_H(J+3)||')(';00179518
                              J = J + 4;                                        00179528
                           END;                                                 00179538
                           DO;  /* 2 = LOOP END (FOR REPETITION FACTORS */      00179548
                              IF LENGTH(S(K)) = 0 THEN K = K-1;    /*DR111304*/
                              IF BYTE(S(K),LENGTH(S(K))-1) = BYTE(',') THEN     00179558
                                 S(K) = SUBSTR(S(K),0,LENGTH(S(K))-1);          00179568
                              S(K) = S(K) || '),';                              00179578
                              J = J + 2;                                        00179588
                           END;                                                 00179598
 /* 3 = END NAME INITIALIZATION FOR THIS TERMINAL */                            00179603
                           IF VMEM_H(J+1)=0 THEN GO TO DONE;                    00179608
                           ELSE DO;                                             00179618
                              CALL SDF_PTR_LOCATE(PTR,RELS);                    00179628
                              PTR = VMEM_F(SHR(J+2,1));                         00179638
                              CALL SDF_LOCATE(PTR,ADDR(VMEM_F),RESV);           00179648
                              COREWORD(ADDR(VMEM_H)) = LOC_ADDR;                00179658
                              J = 2;                                            00179668
                           END;                                                 00179678
                        END;                                                    00179688
                     END;                                                       00179698
DONE:                                                                           00179708
                     IF LENGTH(S(K)) = 0 THEN K = K-1;   /*DR111304*/
                     IF BYTE(S(K),LENGTH(S(K))-1) = BYTE(',') THEN              00179718
                        S(K) = SUBSTR(S(K),0,LENGTH(S(K))-1);                   00179728
                     CALL FLUSH(K);                                             00179738
DONETOO:                                                                        00179748
                     CALL SDF_PTR_LOCATE(PTR,RELS);                             00179758
                     PTR = NEXT_CELL;                                           00179768
                  END;                                                          00179778
               END FORMAT_NAME_TERM_CELLS;                                      00179788
                                                                                00179798
/*CR13353- PRINT XREF DATA FOR SYMBOL OR BUILTIN FUNCTION */
PRINT_XREF_DATA:
      PROCEDURE(K);
      /* K IS BYTE OFFSET TO BEGINNING OF XREF DATA WITHIN CURRENT PAGE */
      DECLARE K BIT(16);
               TS = X10 || 'CROSS REFERENCE:  ';
               #XREF = NODE_H(K);
               K = K + 1;
               DO J = 1 TO #XREF;
                  ITEM = NODE_H(K);
                  IF ITEM ^= -1 THEN DO;                       /*DR108627*/
                     TS = TS || (SHR(ITEM,13)&7)||
                        X1||SUBSTR(10000+(ITEM&"1FFF"),1,4)||X2;
                     IF LENGTH(TS) + 6 > 132 THEN DO;
                        OUTPUT = TS;
                        TS = X28;
                     END;
                  END;
                  ELSE DO;
                     J = J - 1;
                     K = SHR(K + 2,1);
                     PTR1 = NODE_F(K);
                     CALL SDF_LOCATE(PTR1,ADDR(NODE_F),0);
                     COREWORD(ADDR(NODE_H)) = LOC_ADDR;
                     K = -1;
                  END;
                  K = K + 1;
               END;
               IF LENGTH(TS) > 28 THEN OUTPUT = TS;
   END PRINT_XREF_DATA;

               TS(3) = X30;                                                     00179808
            END;                                                                00179818
            IF #SYMBOLS >= K THEN DO;                                           00179828
               PTR = SYMB_TO_PTR(K);                                            00179838
               TS(4) = HEX8(PTR)||X2;                                           00179848
               TS(5) = SYMBOL_NAME(K);                                          00179858
               TMP = LENGTH(TS(5));                                             00179868
               IF TMP > 28 THEN TS(5) = SUBSTR(TS(5),0,28);                     00179878
               ELSE IF TMP < 28 THEN DO;                                        00179888
                  NAME = TS(5) || SUBSTR(X72,0,28-TMP);                         00179898
                  TS(5) = NAME;                                                 00179908
               END;                                                             00179918
               TS(5) = TS(5)||X2;                                               00179928
               TS(9) = HEX(BLKNO,4)||X2;                                        00179938
            END;                                                                00179948
            ELSE DO;                                                            00179958
               TS(4) = X10;                                                     00179968
               TS(9) = X6;                                                      00179978
               TS(5) = X30;                                                     00179988
            END;                                                                00179998
            IF (K >= FIRST_STMT) & (K <= LAST_STMT) THEN DO;                    00180008
               PTR = STMT_TO_PTR(K);                                            00180018
               TS(6) = HEX8(PTR)||X2;                                           00180028
               IF SRN_FLAG THEN DO;                                             00180038
                  STMTNO = K;                                                   00180048
                  CALL MONITOR(22,17);                                          00180058
                  COREWORD(ADDR(TS(7))) = SREFNO + "05000000";                  00180068
                  TS(7) = TS(7)||X1;                                            00180078
                  TS(8) = FORMAT(INCLCNT,5);                                    00180088
               END;                                                             00180100
               ELSE DO;                                                         00180200
                  TS(7) = X7;                                                   00180300
                  TS(8) = X5;                                                   00180400
               END;                                                             00180500
            END;                                                                00180600
            ELSE DO;                                                            00180700
               TS(6) = X10;                                                     00180800
               TS(7) = X7;                                                      00180900
               TS(8) = X5;                                                      00181000
            END;                                                                00181100
            OUTPUT = TS||TS(1)||TS(10)||TS(2)||TS(3)||TS(4)||TS(9)||            00181200
               TS(5)||TS(6)||TS(7)||TS(8);                                      00181300
         END;                                                                   00181400
         OUTPUT(1) = '2' || X52 || 'HEX DUMP OF SDF ' || SDF_NAME;              00181500
         DO I = 0 TO LAST_PAGE;                                                 00181600
            CALL SDF_PTR_LOCATE(SHL(I,16),0);                                   00181700
            CALL PAGE_DUMP(I);                                                  00181800
         END;                                                                   00181900
         OUTPUT(1) = '2' || X1;                                                 00181910
      END;                                                                      00182000
                                                                                00182100
      IF TABLST THEN DO;                                                        00182200
         IF ^BRIEF THEN DO;                                                     00182300
            OUTPUT(1) = '1';                                                    00182400
            OUTPUT =  X52 || 'FORMATTED DUMP OF SDF ' || SDF_NAME;              00182500
            OUTPUT = X1;                                                        00182600
            OUTPUT = X30 || 'D I R E C T O R Y   D A T A';                      00182700
            OUTPUT = X1;                                                        00182800
            OUTPUT = X1;                                                        00182900
         END;                                                                   00183000
         ELSE DO;                                                               00183100
            OUTPUT = SDF_NAME;                                                  00183200
         END;                                                                   00183300
         CALL SDF_LOCATE(0,ADDR(NODE_F),0);                                     00183400
         PTR = NODE_F(2);                                                       00183500
         CALL SDF_LOCATE(PTR,ADDR(NODE_F),RESV);                                00183600
         COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                     00183700
         PTR1 = NODE_F(23);                                                     00183800
         SDF_TITLE = '';                                                        00183900
         ALLOCATE_SPACE(SYM_SORT,10);  /*CR13079*/
         IF PTR1 ^= 0 THEN DO;                                                  00184000
            CALL SDF_LOCATE(PTR1,ADDR(NODE_B),0);                               00184100
            K = NODE_B(0);                                                      00184200
            COREWORD(ADDR(SDF_TITLE)) = SHL(K-1,24) + LOC_ADDR + 1;             00184300
         END;                                                                   00184400
         TS = '';                                                               00184500
         FLAG = NODE_F(0);                                                      00184600
         IF (FLAG & "80000000") ^= 0 THEN                                       00184700
            DO;                                                                 00184710
            SRNS = TRUE;                                                        00184720
            TS = TS || 'SRN,';                                                  00184800
         END;                                                                   00184810
         IF (FLAG & "40000000") ^= 0 THEN                                       00184900
            TS = TS || 'ADDRS,';                                                00185000
         IF (FLAG & "20000000") ^= 0 THEN                                       00185100
            TS = TS || 'COMPOOL,';                                              00185200
         IF (FLAG & "10000000") ^= 0 THEN                                       00185300
            TS = TS || 'FC,';                                                   00185400
         IF (FLAG & "08000000") ^= 0 THEN                                       00185500
            TS = TS || 'DIRECTORY_OVERFLOW,';                                   00185600
         IF (FLAG & "04000000") ^= 0 THEN                                       00185700
            TS = TS || 'NON_MONOTONIC_SRNS,';                                   00185800
         IF (FLAG & "02000000") ^= 0 THEN                                       00185900
            TS = TS || 'NON_UNIQUE_SRNS,';                                      00186000
         IF (FLAG & "01000000") ^= 0 THEN                                       00186100
            TS = TS || 'NOTRACE,';                                              00186200
 /*-RSJ----CR11096-----#DFLAG-----------------------------*/
 /*TEST FLAG FIELD FOR DATA_REMOTE OPTION.  THIS FIELD    */
 /*WAS PREVIOUS PATCH FLAG.                               */
         IF (FLAG & "00040000") ^= 0 THEN
            TS = TS || 'DATA_REMOTE,';
 /*-------------------------------------------------------*/
         IF (FLAG & "00800000") ^= 0 THEN  /* DR103787 */                       08540000
            TS = TS || 'HIGHOPT,';         /* DR103787 */                       08550000
         IF (FLAG & "00200000") ^= 0 THEN                                       00186250
            TS = TS || 'HALMAT,';                                               00186260
         IF (FLAG & "00100000") ^= 0 THEN                                       00186300
            TS = TS || 'FCDATA,';                                               00186400
         IF (FLAG & "00080000") ^= 0 THEN                                       00186500
            TS = TS || 'SDL,';                                                  00186600
         IF (FLAG & "00400000") ^= 0                                            00186610
            THEN TS = TS || 'BITMASK,';                                         00186620
         K = LENGTH(TS);                                                        00186700
         TS = SUBSTR(TS,0,K-1);                                                 00186800
         IF PTR1 ^= 0 THEN                                                      00186900
            OUTPUT = X10 || 'TITLE:                        ' || SDF_TITLE;      00187000
         OUTPUT = X10 || 'FLAGS:                        ' || TS;                00187100
         IF ^BRIEF THEN DO;                                                     00187200
            OUTPUT = X10 || 'COMPUNIT:                     ' || COMPUNIT;       00187300
            OUTPUT = X10 || '# OF LAST PAGE:               ' || LAST_PAGE;      00187400
         END;                                                                   00187500
         CALL PRINT_DATE_AND_TIME('          DATE/TIME:                    ',   00187600
            NODE_F(1),NODE_F(2));                                               00187700
         OUTPUT = X10 || 'SDF VERSION #:                ' || VERSION;           00188500
         IF ^BRIEF THEN DO;                                                     00188600
            OUTPUT = X10 || '# OF LAST DIRECTORY PAGE:     ' || NODE_H(6);      00188700
            OUTPUT = X10 || '# OF EXTERNAL BLOCKS:         ' || #EXTERNALS;     00188800
            OUTPUT = X10 || '# OF BLOCKS:                  ' || #PROCS;         00188900
            OUTPUT = X10 || '# OF SYMBOLS:                 ' || #SYMBOLS;       00189000
            OUTPUT = X10 || '# OF EMITTED INSTRUCTIONS:    ' || EMITTED_CNT;    00189100
            IF NEW_FLAG = FALSE THEN DO;                                        00189200
               OUTPUT = X10 || 'FREE SPACE (BYTES):           ' || NODE_H(15);  00189300
            END;                                                                00189400
            ELSE DO;                                                            00189500
               OUTPUT = X10 || 'FREE SPACE (BYTES):           ' || NODE_H(58);  00189600
               OUTPUT = X10 || 'LIST HEAD PTR (ALPHABETIC):   ' || NODE_H(15);  00189700
               IF NODE_H(21) ^= 0  THEN                                         00189800
                  OUTPUT=X10 || 'LITERAL ADDRESS (#D):         ' ||             00189900
                  NODE_H(21);                                                   00190000
               IF NODE_H(16) ^= 0 THEN                                          00190100
                  OUTPUT = X10 || 'LIST HEAD PTR (#D#P DATA):    ' ||           00190200
                  NODE_H(16);                                                   00190300
               IF NODE_H(17) ^= 0 THEN                                          00190400
                  OUTPUT = X10 || 'LIST HEAD PTR (#R DATA):      ' ||           00190500
                  NODE_H(17);                                                   00190600
               OUTPUT= X10 || 'START OF INITIAL LITERAL AREA (#D) :     '       00190660
                  || NODE_H(84);                                                00190662
               OUTPUT=X10 || 'END OF INITIAL LITERAL AREA (#D) :        '       00190664
                  || NODE_H(85);                                                00190666
               IF NODE_F(44) ^= 0 THEN                                          00190667
                  OUTPUT = X10 || 'SIZE OF LITERAL EXTENT TABLE (WORDS):  '     00190668
                  ||    NODE_F(44);                                             00190669
            END;                                                                00190700
            K = PTR_TO_BLOCK(NODE_F(11));                                       00190800
            TS = BLOCK_NAME(K);                                                 00190900
            OUTPUT = X10 || 'ROOT OF HIERARCHY TREE:       ' ||                 00191000
               K || X2 || TS;                                                   00191100
            K = PTR_TO_BLOCK(NODE_F(12));                                       00191200
            TS = BLOCK_NAME(K);                                                 00191300
            OUTPUT = X10 || 'ROOT OF ALPHABETICAL TREE:    ' ||                 00191400
               K || X2 || TS;                                                   00191500
            OUTPUT = X10 || 'FIRST STMT #:                 ' || FIRST_STMT;     00191600
            OUTPUT = X10 || 'LAST STMT #:                  ' || LAST_STMT;      00191700
            OUTPUT = X10 || '# OF EXECUTABLE STMTS:        ' || #EXECS;         00191800
            OUTPUT = X10 || 'TOTAL # OF STMTS:             ' || NODE_H(29);     00191900
            OUTPUT = X10 || 'BLOCK # OF COMP. UNIT:        ' || KEY_BLOCK;      00192000
            OUTPUT = X10 || 'SYMBOL # OF COMP. UNIT:       ' || KEY_SYMB;       00192100
            IF NODE_H(59) ^= 0 THEN                                             00192110
               OUTPUT = X10 || 'SYMBOL # OF LAST COMSUB PARM: ' || NODE_H(59);  00192150
            OUTPUT = X10 || 'NUMBER OF STACK WALKS:        ' || NODE_H(20);     00192200
            IF SRN_FLAG THEN DO;                                                00192300
               COREWORD(ADDR(SRN_STRING)) = COREWORD(ADDR(NODE_F)) + "05000048";00192400
               INCL_STRING = FORMAT(NODE_H(39),5);                              00192500
               OUTPUT = X10 || 'FIRST SRN & INCLUDE COUNT:    ' ||              00192600
                  SRN_STRING || X2 || INCL_STRING;                              00192700
               COREWORD(ADDR(SRN_STRING)) = COREWORD(ADDR(NODE_F)) + "05000050";00192800
               INCL_STRING = FORMAT(NODE_H(43),5);                              00192900
               OUTPUT = X10 || 'LAST SRN & INCLUDE COUNT:     ' ||              00193000
                  SRN_STRING || X2 || INCL_STRING;                              00193100
            END;                                                                00193200
            OUTPUT = X1;                                                        00193300
         END;                                                                   00193400
         OUTPUT = X10 || 'SYMBOLS     '||NODE_F(26)||'/'||NODE_F(31);           00193500
         OUTPUT = X10 || 'MACROSIZE   '||NODE_F(27)||'/'||NODE_F(32);           00193600
         OUTPUT = X10 || 'LITSTRINGS  '||NODE_F(28)||'/'||NODE_F(33);           00193700
         OUTPUT = X10 || 'XREFSIZE    '||NODE_F(30)||'/'||NODE_F(34);           00193800
         IF VERSION >= 24 THEN DO;                                              00193900
            PTR1 = NODE_F(38);                                                  00194000
            IF PTR1 ^= 0 THEN DO;                                               00194100
               CALL SDF_LOCATE(PTR1,ADDR(NODE_B),0);                            00194200
               K = NODE_B(0);                                                   00194300
               COREWORD(ADDR(TS)) = SHL(K-1,24) + LOC_ADDR + 1;                 00194400
               OUTPUT = X10 || 'CARDTYPE:   ' || TS;                            00194500
            END;                                                                00194600
         END;                                                                   00194700
         IF VERSION >= 25 THEN INCLUDE_PTR = NODE_F(16);                        00194710
         ELSE INCLUDE_PTR = 0;                                                  00194720
         CALL SDF_PTR_LOCATE(PTR,RELS);                                         00194800
         IF BRIEF THEN RETURN;                                                  00194900
         TS = '2' || '  BLOCK#' || '  NAME ' ||                                 00195000
            X20 || X7 || '  TYPE' || X6 || '  CLASS' ||                         00195100
            X5 || '  FLAGS';                                                    00195200
         OUTPUT(1) = TS;                                                        00195300
         OUTPUT(1) = '1';                                                       00195400
         OUTPUT = X30 || 'B L O C K   D A T A';                                 00195500
         OUTPUT = X1;                                                           00195600
         DO I = 1 TO #PROCS;                                                    00195700
            BLKNO = I;                                                          00195800
            CALL MONITOR(22,15);                                                00195900
            PTR,LOC_PTR = PNTR;                                                 00196000
            LOC_ADDR = ADDRESS;                                                 00196100
            COREWORD(ADDR(SRN_STRING)) = LOC_ADDR + "07000000";                 00196200
            TS(1) = BLOCK_NAME(I);                                              00196300
            CALL MONITOR(22,"10000006");                                        00196400
            K = LENGTH(TS(1));                                                  00196500
            CHAR_STRING = X2 || TS(1);                                          00196600
            CHAR_STRING = CHAR_STRING || SUBSTR(X72,0,32-K);                    00196700
            TS(1) = CHAR_STRING;                                                00196800
            COREWORD(ADDR(NODE_F)) = LOC_ADDR;                                  00196900
            COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                  00197000
            COREWORD(ADDR(NODE_B)) = LOC_ADDR;                                  00197100
            PTR = LOC_PTR;                                                      00197200
            TS = FORMAT(NODE_H(13),5);                                          00197300
            TS = X3 || TS;                                                      00197400
            SCLASS = NODE_B(30);                                                00197500
            STYPE = NODE_B(31);                                                 00197600
            FLAG = NODE_F(6);                                                   00197700
            IF SCLASS = 3 THEN DO;                                              00197800
               TS(2) = SYMBOL_TYPES(STYPE);                                     00197900
               TS(3) = '  FUNCTION  ';                                          00198000
            END;                                                                00198100
            ELSE DO;                                                            00198200
               TS(2) = X10 || X2;                                               00198300
               TS(3) = PROC_TYPES(SCLASS);                                      00198400
            END;                                                                00198500
            TS(4) = X2;                                                         00198600
            IF (FLAG & "80000000") ^= 0 THEN                                    00198700
               TS(4) = TS(4) || 'REENTRANT,';                                   00198800
            IF (FLAG & "40000000") ^= 0 THEN                                    00198900
               TS(4) = TS(4) || 'EXCLUSIVE,';                                   00199000
            IF (FLAG & "20000000") ^= 0 THEN                                    00199100
               TS(4) = TS(4) || 'ACCESS,';                                      00199200
            IF (FLAG & "10000000") ^= 0 THEN                                    00199300
               TS(4) = TS(4) || 'RIGID,';                                       00199400
            IF (FLAG & "08000000") ^= 0 THEN                                    00199500
               TS(4) = TS(4) || 'EXTERNAL,';                                    00199600
            IF (FLAG & "04000000") ^= 0 THEN                                    00199700
               TS(4) = TS(4) || 'NONHAL,';                                      00199800
            IF (FLAG & "02000000") ^= 0                                         00199810
               THEN TS(4) = TS(4) || 'CODE_OVERFLOW,';                          00199820
            K = LENGTH(TS(4));                                                  00199900
            IF K > 2 THEN TS(4) = SUBSTR(TS(4),0,K-1);                          00200000
            OUTPUT = TS || TS(1) || TS(2) || TS(3) || TS(4);                    00200100
            IF NODE_H(10) ^= 0 THEN TS='  SYM# OF BLOCK NAME = '||NODE_H(10);   00200200
            ELSE TS = '';                                                       00200210
            OUTPUT = X10 || 'CSECT NAME = ' || SRN_STRING || TS;                00200250
            IF NODE_B(25) ^= 0 THEN OUTPUT = X10 || 'TEMPLATE VERSION = ' ||    00200260
               NODE_B(25);                                                      00200270
            IF NODE_H(21) ^= 0 THEN                                             00200300
               OUTPUT = X10 || 'LIST HEAD PTR (STACK DATA) = ' || NODE_H(21);   00200400
            IF (SCLASS ^= 4)&((FLAG & "04000000")=0) THEN DO;                   00200500
               TEMP1 = NODE_H(14);                                              00200600
               OUTPUT = X10 || 'STACK ID = ' || TEMP1;                          00200700
            END;                                                                00200800
            TEMP1 = NODE_H(16);                                                 00200900
            TEMP2 = NODE_H(17);                                                 00201000
            TEMP3 = NODE_H(18);                                                 00201100
            TEMP4 = NODE_H(19);                                                 00201200
            IF (SCLASS = 4) | ((FLAG & "04000000")^=0) THEN TS = '';            00201300
            ELSE TS = X4 || 'STMTS = ' || TEMP3                                 00201400
               || ' TO ' || TEMP4;                                              00201500
            OUTPUT = X10 || 'SYMBOLS = ' || TEMP1 || ' TO ' ||                  00201600
               TEMP2 || TS;                                                     00201700
            IF (SCLASS ^= 4)&((FLAG & "04000000")=0) THEN                       00201800
               OUTPUT = X10 || 'FIRST POST-DECLARE STMT = ' || NODE_H(20);      00201900
            TEMP1 = PTR_TO_BLOCK(NODE_F(0));                                    00202000
            TEMP2 = PTR_TO_BLOCK(NODE_F(1));                                    00202100
            TEMP3 = PTR_TO_BLOCK(NODE_F(2));                                    00202200
            IF TEMP1 > 0 THEN DO;                                               00202300
               TS = BLOCK_NAME(TEMP1);                                          00202400
               TS(1) = FORMAT(TEMP1,3);                                         00202500
               OUTPUT = X10 || 'ALPHABETIC > LINK POINTS TO:      ' ||          00202600
                  TS(1) || X2 || TS;                                            00202700
            END;                                                                00202800
            IF TEMP2 > 0 THEN DO;                                               00202900
               TS = BLOCK_NAME(TEMP2);                                          00203000
               TS(1) = FORMAT(TEMP2,3);                                         00203100
               OUTPUT = X10 || 'ALPHABETIC < LINK POINTS TO:      ' ||          00203200
                  TS(1) || X2 || TS;                                            00203300
            END;                                                                00203400
            IF TEMP3 > 0 THEN DO;                                               00203500
               TS = BLOCK_NAME(TEMP3);                                          00203600
               TS(1) = FORMAT(TEMP3,3);                                         00203700
               OUTPUT = X10 || 'NESTED BLOCK LINK POINTS TO:      ' ||          00203800
                  TS(1) || X2 || TS;                                            00203900
            END;                                                                00204000
            IF NODE_F(3) > 0 THEN DO;                                           00204100
               TEMP4 = PTR_TO_BLOCK(NODE_F(3));                                 00204200
               TS = BLOCK_NAME(TEMP4);                                          00204300
               TS(1) = FORMAT(TEMP4,3);                                         00204400
               OUTPUT = X10 || 'NEXT BLOCK LINK POINTS TO:        ' ||          00204500
                  TS(1) || X2 || TS;                                            00204600
            END;                                                                00204700
            IF NODE_F(3) < 0 THEN DO;                                           00204800
               TEMP4 = PTR_TO_BLOCK(-NODE_F(3));                                00204900
               TS = BLOCK_NAME(TEMP4);                                          00205000
               TS(1) = FORMAT(TEMP4,3);                                         00205100
               OUTPUT = X10 || 'NEXT BLOCK LINK THREADS BACK TO:  ' ||          00205200
                  TS(1) || X2 || TS;                                            00205300
            END;                                                                00205400
            OUTPUT = X1;                                                        00205500
            CALL SDF_PTR_LOCATE(PTR,RELS);                                      00205600
         END;                                                                   00205700
         IF INCLUDE_PTR > 0 THEN DO;                                            00205702
            TS = '2' || '   INCL#' || '  MEMBER NAME ' || X20 || '  TYPE';      00205704
            OUTPUT(1) = TS;                                                     00205706
            OUTPUT(1) = '1';                                                    00205708
            OUTPUT = X30 || 'I N C L U D E   D A T A';                          00205710
            OUTPUT = X1;                                                        00205712
            J = 1;                                                              00205714
            DO WHILE INCLUDE_PTR > 0;                                           00205716
               CALL SDF_LOCATE(INCLUDE_PTR,ADDR(NODE_B),0);                     00205718
               COREWORD(ADDR(NODE_H)) = LOC_ADDR;                               00205720
               COREWORD(ADDR(NODE_F)) = LOC_ADDR;                               00205722
               TS = X5 || FORMAT(J,3);                                          00205724
               J = J + 1;                                                       00205726
               COREWORD(ADDR(TS(1))) = "07000000" + LOC_ADDR + 4;               00205728
               TS(1) = X2 || TS(1) || X2 || X20;                                00205730
               SFLAG = NODE_B(16);                                              00205732
               IF (SFLAG & "02") ^= 0 THEN TS(2) = 'TEMPLATE,';                 00205734
               ELSE TS(2) = '';                                                 00205736
               IF (SFLAG & "01") ^= 0 THEN TS(2)=TS(2)||'REMOTE,';              00205738
               IF LENGTH(TS(2))>0 THEN TS(2) = SUBSTR(TS(2),0,LENGTH(TS(2))-1); 00205740
               OUTPUT = TS || TS(1) || TS(2);                                   00205742
               TS = '  CATENATION NUMBER: ' || NODE_H(7);                       00205744
               COREWORD(ADDR(TS(1))) = "01000000" + LOC_ADDR + 12;              00205746
               OUTPUT = X10 || 'RVL: ' || TS(1) || TS;                          00205748
               IF SRNS THEN DO;                                                 00205750
                  IF NODE_B(17) > 1 THEN TS = X10||'INCLUDED AT SRNS: ';        00205752
                  ELSE TS = X10 || 'INCLUDED AT SRN: ';                         00205754
                  SADDR = "05000000" + LOC_ADDR + 18;                           00205756
                  DO I = 1 TO NODE_B(17);                                       00205758
                     COREWORD(ADDR(TS(1))) = SADDR;                             00205760
                     TS = TS || TS(1) || ',';                                   00205762
                     SADDR = SADDR + 6;                                         00205764
                  END;                                                          00205766
                  OUTPUT = SUBSTR(TS,0,LENGTH(TS)-1);                           00205768
               END;                                                             00205770
               I = 0;                                                           00205772
               DO WHILE ^SHR(SFLAG,2+I) & (I<5);                                00205773
                  I = I + 1;                                                    00205774
               END;                                                             00205775
               OUTPUT = X10 || 'FROM FILE SPECIFIED IN THE ' || INCL_FILES(I)   00205776
                  || ' DD CARD';                                                00205777
               INCLUDE_PTR = NODE_F(0);                                         00205778
               OUTPUT = X1;                                                     00205780
            END;                                                                00205782
         END;                                                                   00205784
         TS = '2'||'   SYMB#'||'  NAME '||X20||X7||                             00205800
            '  TYPE'||X6||'  CLASS'||X7||'  FLAGS';                             00205900
         OUTPUT(1) = TS;                                                        00206000
         OUTPUT(1) = '1';                                                       00206100
         OUTPUT = X30||'S Y M B O L   D A T A';                                 00206200
         OUTPUT = X1;                                                           00206300
         LAST_BLOCK = -1;                                                       00206400
         DO I = 1 TO #SYMBOLS;                                                  00206500
            TS = FORMAT(I,5);                                                   00206600
            TS = X3 || TS;                                                      00206700
            TS(1) = SYMBOL_NAME(I);                                             00206800
            K = LENGTH(TS(1));                                                  00206900
            CHAR_STRING = X2 || TS(1);                                          00207000
            CHAR_STRING = CHAR_STRING || SUBSTR(X72,0,32-K);                    00207100
            TS(1) = CHAR_STRING;                                                00207200
            CALL MONITOR(22,"10000006");                                        00207300
            COREWORD(ADDR(NODE_F)) = LOC_ADDR;                                  00207400
            COREWORD(ADDR(NODE_H)) = LOC_ADDR;                                  00207500
            COREWORD(ADDR(NODE_B)) = LOC_ADDR;                                  00207600
            PTR = LOC_PTR;                                                      00207700
            SBLK = NODE_H(0);                                                   00207800
            IF SBLK ^= LAST_BLOCK THEN DO;                                      00207900
               LAST_BLOCK = SBLK;                                               00208000
               TS(6) = BLOCK_NAME(SBLK);                                        00208100
               TS(7) = FORMAT(SBLK,3);                                          00208200
               TS(7) = ASTS || 'BLOCK:  ' || TS(7) ||                           00208300
                  X2 || TS(6);                                                  00208400
               OUTPUT = X1;                                                     00208500
               OUTPUT = TS(7);                                                  00208600
               OUTPUT = X1;                                                     00208700
            END;                                                                00208800
            SCLASS = NODE_B(6);                                                 00208900
            STYPE = NODE_B(7);                                                  00209000
            TS(3) = SYMBOL_CLASSES(SCLASS);                                     00209100
            IF (SCLASS = 2) | (SCLASS = 5) THEN TS(2) =                         00209200
               PROC_TYPES(STYPE);                                               00209300
            ELSE TS(2) = SYMBOL_TYPES(STYPE);                                   00209400
            FLAG = NODE_F(2);                                                   00209500
            TS(5) = X2;                                                         00209600
            IF (FLAG & "80000000") ^= 0 THEN                                    00209700
               TS(5) = TS(5) || 'COMPOOL,';                                     00209800
            IF (FLAG & "40000000") ^= 0 THEN                                    00209900
               TS(5) = TS(5) || 'INPUT,';                                       00210000
            IF (FLAG & "20000000") ^= 0 THEN                                    00210100
               TS(5) = TS(5) || 'ASSIGN,';                                      00210200
            IF (FLAG & "10000000") ^= 0 THEN                                    00210300
               TS(5) = TS(5) || 'TEMPORARY,';                                   00210400
            IF (FLAG & "08000000") ^= 0 THEN                                    00210500
               TS(5) = TS(5) || 'AUTOMATIC,';                                   00210600
            IF (FLAG & "04000000") ^= 0 THEN DO;                                00210700
               NAME_FLAG = TRUE;                                                00210710
               TS(5) = TS(5) || 'NAME,';                                        00210800
            END;                                                                00210810
            ELSE NAME_FLAG = FALSE;                                             00210820
            IF (FLAG & "02000000") ^= 0 THEN                                    00210900
               TS(5) = TS(5) || 'TPL_HDR,';                                     00211000
            IF (FLAG & "01000000") ^= 0 THEN                                    00211100
               TS(5) = TS(5) || 'UNQUALIFIED,';                                 00211200
            IF (FLAG & "00800000") ^= 0 THEN                                    00211300
               TS(5) = TS(5) || 'REENTRANT,';                                   00211400
            IF (FLAG & "00400000") ^= 0 THEN                                    00211500
               TS(5) = TS(5) || 'DENSE,';                                       00211600
            IF (FLAG & "00200000") ^= 0 THEN                                    00211700
               DO;                                                              00211710
               CONST_FLAG = TRUE;                                               00211720
               TS(5) = TS(5) || 'CONSTANT,';                                    00211800
            END;                                                                00211810
            ELSE CONST_FLAG = FALSE;                                            00211820
            IF (FLAG & "00100000") ^= 0 THEN                                    00211900
               TS(5) = TS(5) || 'ACCESS,';                                      00212000
            IF (FLAG & "00080000") ^= 0 THEN                                    00212100
               TS(5) = TS(5) || 'INDIRECT,';                                    00212200
            IF (FLAG & "00040000") ^= 0 THEN                                    00212300
               TS(5) = TS(5) || 'LATCHED,';                                     00212400
            IF (FLAG & "00020000") ^= 0 THEN                                    00212500
               TS(5) = TS(5) || 'LOCKED,';                                      00212600
            IF (FLAG & "00010000") ^= 0 THEN                                    00212700
               TS(5) = TS(5) || 'REMOTE,';                                      00212800
            IF (FLAG & "00008000") ^= 0 THEN DO;                                00212900
               TS(5) = TS(5) || 'BIAS,';                                        00213000
               TEMP = SHR(NODE_B(2),2);                                         00213100
               SOFFSET = NODE_F(TEMP) & "FFFFFF";                               00213200
            END;                                                                00213300
            ELSE SOFFSET = 0;                                                   00213400
            IF (FLAG & "00004000") ^= 0 THEN                                    00213500
               TS(5) = TS(5) || 'INITIAL,';                                     00213600
            IF (FLAG & "00002000") ^= 0 THEN                                    00213700
               TS(5) = TS(5) || 'RIGID,';                                       00213800
            IF (FLAG & "00001000") ^= 0 THEN                                    00213900
               DO;                                                              00213910
               IF CONST_FLAG THEN LIT_FLAG = TRUE;                              00213920
               TS(5) = TS(5) || 'LITERAL,';                                     00214000
            END;                                                                00214010
            ELSE LIT_FLAG = FALSE;                                              00214020
            IF (FLAG & "00000800") ^= 0 THEN                                    00214100
               TS(5) = TS(5) || 'EXTERNAL,';                                    00214200
            IF (FLAG & "00000400") ^= 0 THEN                                    00214300
               TS(5) = TS(5) || 'STACK,';                                       00214400
            IF (FLAG & "00000200") ^= 0 THEN                                    00214500
               TS(5) = TS(5) || 'BLOCK_DATA,';                                  00214600
            IF (FLAG & "00000100") ^= 0 THEN                                    00214700
               TS(5) = TS(5) || 'EQUATE,';                                      00214800
            IF (FLAG & "00000080") ^= 0 THEN                                    00214900
               TS(5) = TS(5) || 'INCREM,';      /* DR108643 */                  00215000
            IF (FLAG & "00000040") ^= 0 THEN                                    00215100
               TS(5) = TS(5) || 'EXCLUSIVE,';                                   00215200
            IF (FLAG & "00000020") ^= 0 THEN                                    00215300
               TS(5) = TS(5) || 'FCDATA,';                                      00215400
            IF (FLAG & "00000010") ^= 0 THEN                                    00215410
               TS(5) = TS(5) || 'MISC_NAME,';                                   00215420
            IF (FLAG & "00000008") ^= 0 THEN                                    00215430
               TS(5) = TS(5) || 'REPL_MACRO_ARGS,';                             00215440
            IF (FLAG & "00000001") ^= 0                                         00215450
               THEN TS(5) = TS(5) || 'BITMASK,';                                00215460
            IF ((FLAG & "00000004") ^= 0) THEN ASIP_FLAG = TRUE;                00215470
            ELSE ASIP_FLAG = FALSE;                                             00215480
            IF (FLAG & "00000002") ^=0 THEN                                     00215490
               TS(5) = TS(5) || 'OVERFLOW_DATA,';                               00215500
            K = LENGTH(TS(5));                                                  00215510
            IF K > 2 THEN                                                       00215600
               TS(5) = SUBSTR(TS(5),0,K-1);                                     00215700
            OUTPUT = TS || TS(1) || TS(2) || TS(3) || TS(5);                    00215800
            TS = X10;                                                           00215810
            IF NEW_FLAG THEN DO;                                                00215900
               IF NODE_F(-1) ^= 0 THEN                                          00216000
                  TS = TS || 'ALPHABETIC LINK = ' ||                            00216100
                  NODE_H(-2) || X4 || 'ADDRESS LINK = ' ||                      00216200
                  NODE_H(-1);                                                   00216300
            END;                                                                00216400
            IF (FLAG & "800") = 0 THEN TS=TS||X4||'PHASE1 LINK = '||NODE_H(-5); 00216410
            IF LENGTH(TS) > 10 THEN OUTPUT = TS;                                00216420
            IF LIT_FLAG & VERSION >= 25 THEN DO;                                00216430
               DOUBLE_FLAG = STYPE > 12;                                        00216440
               LIT_TYPE = STYPE & "7";                                          00216450
               IF NODE_F(5) ^= 0 THEN                                           00216460
                  CALL SDF_LOCATE(NODE_F(5),ADDR(NODE_B1),0);                   00216465
               IF STYPE = 2 THEN DO;                                            00216470
                  IF NODE_F(5) = 0 THEN TS = '';                                00216480
                  ELSE COREWORD(ADDR(TS)) = SHL(NODE_B1(0),24) + LOC_ADDR + 1;  00216490
                  TS(8) = ' CONSTANT(''';                                       00216500
               END;                                                             00216510
               ELSE DO;                                                         00216520
                  COREWORD(ADDR(NODE_F1)) = ADDR(NODE_B1(0));                   00216530
                  DW(0) = NODE_F1(0);                                           00216540
                  DW(1) = NODE_F1(1);                                           00216550
                  IF LIT_TYPE = 6 THEN DO;                                      00216560
                     IF ^INTEGERIZABLE THEN GO TO SCALAR_CHAR;                  00216570
                     TS = DW(3);                                                00216580
                     IF DOUBLE_FLAG THEN                                        00216590
                        OUTPUT = X10||'DP INTEGER CONSTANT('||TS||')';          00216600
                     ELSE OUTPUT=X10||'SP INTEGER CONSTANT('||TS||')';          00216610
                  END;                                                          00216620
                  ELSE IF LIT_TYPE = 5 THEN DO;                                 00216630
SCALAR_CHAR:         COREWORD(ADDR(TS)) = MONITOR(12, DOUBLE_FLAG);             00216640
                     IF DOUBLE_FLAG THEN                                        00216650
                        OUTPUT = X10||'DP SCALAR CONSTANT('||TS||')';           00216660
                     ELSE OUTPUT=X10||'SP SCALAR CONSTANT('||TS||')';           00216670
                  END;                                                          00216680
               END;                                                             00216690
            END;                                                                00216700
            ELSE TS = '';                                                       00216710
            IF (SCLASS=2)&(STYPE=8) THEN DO;                                    00216720
               IF ASIP_FLAG THEN OUTPUT = X10||'POINTS TO '||                   00216730
                  FORMAT_VAR_REF_CELL(NODE_F(-2));                              00216740
               SADDR = NODE_F(3)&"FFFFFF";                                      00216750
               SEXTENT = NODE_F(5)&"FFFFFF";                                    00216760
               CALL PRINT_ADDRS;                                                00216800
            END;                                                                00216900
            ELSE IF (SCLASS=2)&(STYPE=9) THEN DO;                               00217000
               IF VERSION >= 25 THEN                                            00217010
                  CALL PRINT_REPLACE_TEXT(NODE_F(5),NODE_F(3)&"FFFFFF");        00217020
            END;                                                                00217100
            ELSE IF ((SCLASS=2)|(SCLASS=3))&((FLAG&"04000000")=0) THEN DO;      00217200
               TEMP1 = NODE_H(7);                                               00217300
               IF TEMP1 ^= 0 THEN DO;                                           00217400
                  S = 'LABEL DEFINED ON STMT '||TEMP1;                          00217410
                  IF ASIP_FLAG THEN DO;                                         00217420
                     S = S || '  :  ';                                          00217430
                     CALL FORMAT_FORM_PARM_CELL(I,NODE_F(-2));                  00217440
                  END;                                                          00217450
                  ELSE CALL FLUSH(0);                                           00217460
               END;                                                             00217470
               IF FC_FLAG THEN DO;                                              00217600
                  IF (SCLASS = 3) | ((SCLASS = 2) & (STYPE ^= 4) &              00217700
                     (STYPE ^= 7)) THEN DO;                                     00217800
                     SADDR = NODE_H(10);                                        00217900
                     SEXTENT = NODE_H(11);                                      00218000
                     CALL PRINT_ADDRS;                                          00218100
                  END;                                                          00218200
               END;                                                             00218300
            END;                                                                00218400
            ELSE DO;                                                            00218500
               SADDR = NODE_F(3) & "00FFFFFF";                                  00218600
               IF (FLAG & "00000400") ^= 0 THEN DO;                             00218700
                  TEMP1 = NODE_H(8);                                            00218800
                  OUTPUT = X10 || 'STACK ID = ' || TEMP1;                       00218900
               END;                                                             00219000
               IF ((FLAG&"00020000")^=0) THEN DO;                               00219100
                  TEMP1 = NODE_B(20);                                           00219200
                  IF TEMP1 = "FF" THEN OUTPUT = X10 || 'LOCK(*)';               00219300
                  ELSE OUTPUT = X10 || 'LOCK(' || TEMP1 || ')';                 00219400
               END;                                                             00219500
               IF (FLAG & "00001000") = 0 THEN DO;                              00219600
                  SEXTENT = NODE_F(5) & "00FFFFFF";                             00219700
                  CALL PRINT_ADDRS;                                             00219800
               END;                                                             00219900
            END;                                                                00220000
            IF SCLASS ^= 2 THEN DO;                                             00220100
               IF SCLASS ^= 5 THEN DO;                                          00220200
                  IF (STYPE = 1) | (STYPE = 9) | (STYPE = 10) |                 00220300
                     (STYPE = 17) THEN DO;                                      00220400
                     #BITS = NODE_B(19);                                        00220500
                     SHIFT = NODE_B(18);                                        00220600
                     TS = X10 || 'BIT(' || #BITS || ')';                        00220700
                     IF (FLAG & "00400000") ^= 0 THEN DO;                       00220800
                        IF SHIFT = "FF" THEN DO;                                00220900
                           SHIFT = 0;                                           00221000
                           TS(2) = '  MASK';                                    00221100
                        END;                                                    00221200
                        ELSE IF SHIFT = 0 THEN                                  00221300
                           TS(2) = '  NO MASK';                                 00221400
                        ELSE TS(2) = '  MASK';                                  00221500
                        TS(3) = FORMAT(SHIFT,2);                                00221600
                        TS(1) = X2 || 'RIGHT SHIFT FACTOR = ' || TS(3);         00221700
                     END;                                                       00221800
                     ELSE TS(1),TS(2) = '';                                     00221900
                     OUTPUT = TS || TS(1) || TS(2);                             00222000
                  END;                                                          00222100
                  IF (STYPE = 4) | (STYPE = 12) THEN DO;                        00222200
                     TEMP1 = NODE_B(19);                                        00222300
                     OUTPUT = X10 || 'VECTOR(' ||                               00222400
                        TEMP1 || ')';                                           00222500
                  END;                                                          00222600
                  IF (STYPE = 3) | (STYPE = 11) THEN DO;                        00222700
                     TEMP1 = NODE_B(18);                                        00222800
                     TEMP2 = NODE_B(19);                                        00222900
                     OUTPUT = X10 || 'MATRIX(' ||                               00223000
                        TEMP1 || ',' ||                                         00223100
                        TEMP2 || ')';                                           00223200
                  END;                                                          00223300
                  IF STYPE = 2 THEN DO;                                         00223400
                     #CHARS = NODE_H(9);                                        00223500
                     IF #CHARS < 0 THEN                                         00223600
                        OUTPUT = X10 || 'CHARACTER(*)';                         00223700
                     ELSE DO;                                                   00223800
                        IF VERSION<25 | ^LIT_FLAG THEN                          00223900
                           OUTPUT = X10||'CHARACTER('||#CHARS||')';             00223905
                        ELSE DO;                                                00223910
                           TS(9) = X10||'CHARACTER('||#CHARS||')' || TS(8);     00223915
                           J = LENGTH(TS(9));                                   00223920
                           IF LENGTH(TS) <= 129-J THEN OUTPUT = TS(9)||TS       00223925
                              ||''')';                                          00223930
                           ELSE DO;                                             00223935
                              IF LENGTH(TS)>=254 THEN DO;                       00223940
                                 TS(9) = TS(9)||SUBSTR(TS,0,2);                 00223945
                                 J = J + 2;                                     00223950
                                 TS = SUBSTR(TS,2) || ''')';                    00223955
                              END;                                              00223960
                              ELSE TS = TS || ''')';                            00223965
                              OUTPUT = TS(9) || SUBSTR(TS,0,131-J);             00223970
                              IF LENGTH(SUBSTR(TS,131-J)) <= 121 THEN           00223975
                                 OUTPUT = X10||SUBSTR(TS,131-J);                00223980
                              ELSE DO;                                          00223985
                                 OUTPUT = X10||SUBSTR(TS,131-J,121);            00223990
                                 OUTPUT = X10||SUBSTR(TS,252-J);                00223995
                              END;                                              00224000
                           END;                                                 00224005
                        END;                                                    00224010
                     END;                                                       00224100
                     TS(8) = '';                                                00224110
                  END;                                                          00224200
                  IF (STYPE = 16) & ((SCLASS=1)|(SCLASS=3)) THEN DO;            00224300
                     TS(1) = SYMBOL_NAME(NODE_H(9));                            00224400
                     TS = FORMAT(NODE_H(9),4);                                  00224500
                     OUTPUT = X10 || 'POINTS TO TEMPLATE:  ' ||                 00224600
                        TS || X2 || TS(1);                                      00224700
                  END;                                                          00224800
               END;                                                             00224900
               IF NODE_B(4) > 0 THEN DO;                                        00225000
                  K = SHR(NODE_B(4),1);                                         00225100
                  TEMP1 = NODE_H(K);                                            00225200
                  TEMP2 = NODE_H(K + 1);                                        00225300
                  TEMP3 = NODE_H(K + 2);                                        00225400
                  TEMP4 = NODE_H(K + 3);                                        00225500
                  IF (STYPE=16)&((SCLASS=1)|(SCLASS=3)) THEN DO;                00225600
                     IF TEMP2 < 0 THEN                                          00225700
                        OUTPUT = X10 || 'STRUCTURE(*)';                         00225800
                     ELSE OUTPUT = X10 || 'STRUCTURE(' || TEMP2 || ')';         00225900
                  END;                                                          00226000
                  ELSE DO;                                                      00226100
                     IF TEMP1 = 1 THEN DO;                                      00226200
                        IF TEMP2 < 0 THEN                                       00226300
                           OUTPUT = X10 || 'ARRAY(*)';                          00226400
                        ELSE DO;                                                00226500
                           OUTPUT = X10 || 'ARRAY(' ||                          00226600
                              TEMP2 || ')';                                     00226700
                        END;                                                    00226800
                     END;                                                       00226900
                     ELSE DO;                                                   00227000
                        TS = X10 || 'ARRAY(' ||                                 00227100
                           TEMP2 || ',' ||                                      00227200
                           TEMP3;                                               00227300
                        IF TEMP1 = 3 THEN                                       00227400
                           TS = TS || ',' ||                                    00227500
                           TEMP4 || ')';                                        00227600
                        ELSE TS = TS || ')';                                    00227700
                        OUTPUT = TS;                                            00227800
                     END;                                                       00227900
                  END;                                                          00228000
               END;                                                             00228100
               IF NODE_B(5) > 0 THEN DO;                                        00228200
                  K = SHR(NODE_B(5),1);                                         00228300
                  TEMP1 = NODE_H(K);                                            00228400
                  TEMP2 = NODE_H(K + 1);                                        00228500
                  TEMP3 = NODE_H(K + 2);                                        00228600
                  IF (SCLASS = 4) & (STYPE = 16) &                              00228700
                     ((FLAG & "02000000") = 0) & (TEMP2 = 0) THEN DO;           00228800
                     TS(1) = SYMBOL_NAME(NODE_H(9));                            00228900
                     TS = FORMAT(NODE_H(9),4);                                  00229000
                     OUTPUT = X10 || 'POINTS TO TEMPLATE:      ' ||             00229100
                        TS || X2 || TS(1);                                      00229200
                  END;                                                          00229300
                  IF TEMP1 ^= 0 THEN DO;                                        00229400
                     TS(1) = SYMBOL_NAME(TEMP1);                                00229500
                     TS = FORMAT(TEMP1,4);                                      00229600
                     OUTPUT = X15 || 'POINTS TO' ||                             00229700
                        ' STRUCTURE:     ' || TS || X2                          00229800
                        || TS(1);                                               00229900
                  END;                                                          00230000
                  IF TEMP2 ^= 0 THEN DO;                                        00230100
                     TS(1) = SYMBOL_NAME(TEMP2);                                00230200
                     TS = FORMAT(TEMP2,4);                                      00230300
                     OUTPUT = X15 || 'POINTS TO ELDEST SON:    ' ||             00230400
                        TS || X2 || TS(1);                                      00230500
                  END;                                                          00230600
                  IF TEMP3 ^= 0 THEN DO;                                        00230700
                     IF TEMP3 > 0 THEN DO;                                      00230800
                        TS(1) = SYMBOL_NAME(TEMP3);                             00230900
                        TS = FORMAT(TEMP3,4);                                   00231000
                        OUTPUT = X15 || 'POINTS TO BROTHER:       ' ||          00231100
                           TS || X2 || TS(1);                                   00231200
                     END;                                                       00231300
                     ELSE DO;                                                   00231400
                        TEMP3 = - TEMP3;                                        00231500
                        TS(1) = SYMBOL_NAME(TEMP3);                             00231600
                        TS = FORMAT(TEMP3,4);                                   00231700
                        OUTPUT = X15 || 'THREADS BACK TO FATHER:  '             00231800
                           || TS || X2 || TS(1);                                00231900
                     END;                                                       00232000
                  END;                                                          00232100
               END;                                                             00232200
            END;                                                                00232300
            IF NODE_B(3) > 0 THEN DO;                                           00232400
 /* DR111354 */
 /* IN CASE OF SYMBOL XREF EXTENSION CELL, SAVE ADDR OF SYM DATA CELL */
               DECLARE SYM_DATA_CELL_ADDR FIXED;            /*DR111354*/
               SYM_DATA_CELL_ADDR= COREWORD(ADDR(NODE_F));  /*DR111354*/
               CALL PRINT_XREF_DATA(SHR(NODE_B(3),1)); /*CR13353*/
            END;                                                                00235000
            IF ASIP_FLAG & (SCLASS=1 | SCLASS=2 & NAME_FLAG) THEN DO;           00235010
 /* DR111354 */
 /* RESTORE NODE_F TO SYM_DATA_CELL_ADDR BEFORE GETTING AUXILIARY INFO. */
               COREWORD(ADDR(NODE_F))  = SYM_DATA_CELL_ADDR; /*DR111354*/
               IF STYPE=16 & ^NAME_FLAG THEN                                    00235020
                  CALL FORMAT_NAME_TERM_CELLS(I,NODE_F(-2));                    00235030
               ELSE OUTPUT = X10||'INITIAL(NAME('||                             00235040
                  FORMAT_VAR_REF_CELL(NODE_F(-2)) || '))';                      00235050
            END;                                                                00235060
            /*PUT ALL SYMBOLS STORED IN THE #D OR #P INTO THE ARRAYS USED FOR*/
            /*PRINTING THE #D/#P INITIALIZATION VALUES IN ORDER BY OFFSET*/
 /*CR13079*/IF SCLASS=1 THEN
 /*CR13079*/  IF ^LIT_FLAG THEN /*NOT IN LITERAL TABLE*/
 /*CR13079*/  IF ((FLAG & "7000 0000")=0) THEN/*NOT INPUT,ASSIGN OR TEMPORARY*/
 /*CR13079*/  IF ^( ((FLAG & "00000040") = 0) & ((FLAG & "04000000") = 0)
 /*CR13079*/  & ((FLAG & "00010000") ^= 0) ) THEN /*NOT IN #R*/
 /*CR13079*/  IF ((FLAG & "00000800") = 0)   THEN /*NOT EXTERNAL*/
 /*CR13079*/  DO;
 /*CR13079*/    MAX_ARRAY = MAX_ARRAY + 1;
 /*CR13079*/    NEXT_ELEMENT(SYM_SORT);
 /*CR13079*/    CALL INSERT_SORT(MAX_ARRAY,SADDR,I);
 /*CR13079*/  END;
            CALL SDF_PTR_LOCATE(PTR,RELS);                                      00235100
            OUTPUT = X1;                                                        00235200
         END;                                                                   00235300
         IF #STMTS > 0 THEN DO;                                                 00235400
            TS = '2'||'STMT#  TYPE'||X20;                                       00235500
            IF SRN_FLAG THEN                                                    00235600
               TS = TS||'   SRN   INCL  ORIG SRN';                              00235700
            IF ADDR_FLAG THEN                                                   00235800
               TS = TS||'  ADDR1         '||'  ADDR2';                          00235900
            OUTPUT(1) = TS;                                                     00236100
            OUTPUT(1) = '1';                                                    00236200
            OUTPUT = X30||'S T A T E M E N T   D A T A';                        00236300
            OUTPUT = X1;                                                        00236400
            LAST_BLOCK = -1;                                                    00236500
            DO I = FIRST_STMT TO LAST_STMT;                                     00236600
               TS = FORMAT(I,5);                                                00236700
               STMTNO = I;                                                      00236900
               CALL MONITOR(22,17);                                             00237000
               LOC_PTR = PNTR;                                                  00237100
               LOC_ADDR = ADDRESS;                                              00237200
               COREWORD(ADDR(NODE_H)) = LOC_ADDR;                               00237300
               COREWORD(ADDR(NODE_F)) = LOC_ADDR;                               00237400
               IF SRN_FLAG THEN DO;                                             00237500
                  COREWORD(ADDR(SRN_STRING)) = LOC_ADDR + "05000000";           00237600
                  INCL_STRING = FORMAT(NODE_H(3),5);                            00237700
                  TS(2) = X2 || SRN_STRING || X1 || INCL_STRING;                00237800
                  PTR = NODE_F(2);                                              00237900
               END;                                                             00238000
               ELSE DO;                                                         00238100
                  TS(2) = '';                                                   00238200
                  PTR = NODE_F(0);                                              00238300
               END;                                                             00238400
               IF PTR ^= 0 THEN DO;                                             00238500
                  CALL SDF_LOCATE(ABS(PTR),ADDR(NODE_H),RESV);                  00238600
                  COREWORD(ADDR(NODE_B)) = LOC_ADDR;                            00238700
                  COREWORD(ADDR(NODE_F)) = LOC_ADDR;                            00238710
                  SBLK = NODE_H(0);                                             00238800
                  SFLAG = NODE_B(2);                                            00238900
                  IF PTR > 0 THEN DO;                                           00238910
                     IF HMAT_OPT                                                00238920
                        THEN HMAT_PTR = NODE_F(-1);                             00238930
                     STYPE = NODE_B(3);                                         00239000
                     #LABELS = NODE_B(4);                                       00239100
                     #LHS = NODE_B(5);                                          00239200
                     J = 6 + 2*(#LABELS + #LHS);                                00239210
                     IF ADDR_FLAG THEN DO;                                      00239300
                        ADDR1 = NODE_B(J);                                      00239500
                        ADDR1 = SHL(ADDR1,8) + NODE_B(J+1);                     00239600
                        ADDR1 = SHL(ADDR1,8) + NODE_B(J+2);                     00239700
                        ADDR2 = NODE_B(J+3);                                    00239800
                        ADDR2 = SHL(ADDR2,8) + NODE_B(J+4);                     00239900
                        ADDR2 = SHL(ADDR2,8) + NODE_B(J+5);                     00240000
                        J = J + 6;                                              00240010
                     END;                                                       00240100
                     IF (SFLAG & "80") ^= 0 THEN DO;                            00240110
                        COREWORD(ADDR(SRN_STRING))="05000000"+LOC_ADDR+J;       00240120
                        IF SRN_STRING = '000000' THEN SRN_STRING = '      ';    00240130
                        TS(2) = TS(2) || X2 || SRN_STRING;                      00240140
                     END;                                                       00240150
                     ELSE TS(2) = TS(2) || '        ';                          00240160
                     TS(1) = STMT_FLAGS(SFLAG & 7);                             00240200
                     SUBTYPE = T(STYPE) + (SHR(SFLAG,3) & 3);                   00240210
                     IF VERSION>=26 & SUBTYPE^=0 THEN                           00240220
                        TS(1) = X2||TS(1)||SUB_STMT_TYPES(SUBTYPE);             00240230
                     ELSE TS(1) = X2 || TS(1) || STMT_TYPES(STYPE);             00240240
                     K = LENGTH(TS(1));                                         00240400
                     IF K >= 26 THEN TS(1) = SUBSTR(TS(1),0,26);                00240500
                     ELSE DO;                                                   00240600
                        CHAR_STRING = TS(1) || SUBSTR(X72,0,26-K);              00240700
                        TS(1) = CHAR_STRING;                                    00240800
                     END;                                                       00240900
                  END;                                                          00240910
/* DECLARE, EQUATE EXTRN, TEMPORARY, REPLACE, OR STRUCTURE STMTS */
                  ELSE DO;                                                      00240920
                     IF HMAT_OPT                                                00240930
                        THEN HMAT_PTR = NODE_F(2);                              00240940
                     IF (SFLAG & "20") ^= 0 THEN DO;                            00240950
                        COREWORD(ADDR(SRN_STRING)) = "05000000" + LOC_ADDR +12; 00240960
                        IF SRN_STRING = '000000' THEN SRN_STRING = '      ';    00240970
                        TS(2) = TS(2) || X2 || SRN_STRING;                      00240980
                     END;                                                       00240990
                     ELSE TS(2) = TS(2) || '        ';                          00241000
                     STYPE = NODE_B(3);                                         00241010
                     TS(1) = X2||STMT_TYPES(STYPE)||SUBSTR(X20,0,17);           00241020
/************ DR105709, 5/28/92, RAH **********************************/
                     TS(1) = SUBSTR(TS(1),0,26);
/************ END DR105709 ********************************************/
                  END;                                                          00241030
                  IF SBLK ^= LAST_BLOCK THEN DO;                                00241040
                     LAST_BLOCK = SBLK;                                         00241100
                     TS(5) = BLOCK_NAME(SBLK);                                  00241200
                     TS(4) = FORMAT(SBLK,3);                                    00241300
                     TS(4) = ASTS || 'BLOCK:  ' || TS(4) ||                     00241400
                        X2 || TS(5);                                            00241500
                     OUTPUT = X1;                                               00241600
                     OUTPUT = TS(4);                                            00241700
                     OUTPUT = X1;                                               00241800
                  END;                                                          00241900
                  TS(4) = '';                                                   00241910
                  IF (ADDR_FLAG & (PTR > 0)) THEN DO;                           00242000
                     ADDR1_HEX = HEX6(ADDR1);                                   00242100
                     ADDR1_DEC = FORMAT(ADDR1,6);                               00242200
                     ADDR2_HEX = HEX6(ADDR2);                                   00242300
                     ADDR2_DEC = FORMAT(ADDR2,6);                               00242400
                     TS(3) = X2 || ADDR1_HEX || '(' ||                          00242500
                        ADDR1_DEC || ')' || X2 || ADDR2_HEX ||                  00242600
                        '(' || ADDR2_DEC || ')';                                00242700
                  END;                                                          00242800
                  ELSE TS(3) = '';                                              00242900
                  S = TS || TS(1) || TS(2) || TS(3) || TS(4);                   00243000
                  IF PTR > 0 THEN                                               00243001
                     IF (NODE_H(-4) & "0200") ^= 0                              00243010
                     THEN S = S || ' BITMASK ';                                 00243020
                  IF PTR > 0 THEN DO;                                           00243030
                     IF #LABELS > 0 THEN DO;                                    00243200
                        S(1) = '  LABEL(S):  ';                                 00243300
                        J1 = 3;                                                 00243400
                        J2 = J1 + #LABELS - 1;                                  00243500
                        DO J = J1 TO J2;                                        00243600
                           TS(1) = NODE_H(J);                                   00243700
                           TS(2) = SYMBOL_NAME(NODE_H(J));                      00243710
                           S(1) = S(1) || TS(1) || '=' || TS(2) || ', ';        00243720
                        END;                                                    00243730
                        S(1) = SUBSTR(S(1),0,LENGTH(S(1))-2);                   00243740
                        CALL FLUSH(1,1);                                        00243750
                     END;                                                       00244500
                     IF VERSION>=26 & (SFLAG & "40")^= 0 THEN #LHS = 0;         00244510
                     IF #LHS > 0 THEN DO;                                       00244600
                        S(1) = '  TARGET(S): ';                                 00244700
                        L = 1;                                                  00244710
                        J1 = 3 + #LABELS;                                       00244800
                        J2 = J1 + #LHS - 1;                                     00244900
                        DO J = J1 TO J2;                                        00245000
                           ITEM = NODE_H(J);                                    00245100
                           IF ITEM > 0 THEN DO;                                 00245200
                              TS(1) = ITEM;                                     00245300
                              TS(2) = SYMBOL_NAME(ITEM);                        00245400
                              IF LENGTH(S(L))>LINELENGTH THEN L=L+1;            00245500
                              S(L) = S(L) || TS(1) || '=' || TS(2) || ', ';     00245510
                           END;                                                 00245700
                           ELSE DO;                                             00245800
                              TS(3) = '';                                       00245900
                              TS(4) = '(';                                      00246000
                              K1 = J + 1;                                       00246100
                              K2 = J - ITEM;                                    00246200
                              J = K2;                                           00246300
                              DO K = K1 TO K2;                                  00246400
                                 ITEM = NODE_H(K);                              00246500
                                 TS(4) = TS(4) ||                               00246600
                                    ITEM;                                       00246700
                                 TS(2) = SYMBOL_NAME(ITEM);                     00246800
                                 TS(3) = TS(3) || TS(2);                        00246900
                                 IF K < K2 THEN DO;                             00247000
                                    TS(4) = TS(4) || ',';                       00247100
                                    TS(3) = TS(3) || '.';                       00247200
                                 END;                                           00247300
                                 ELSE TS(4) = TS(4) || ')';                     00247400
                              END;                                              00247500
                              IF LENGTH(S(L))>LINELENGTH THEN L = L+1;          00247600
                              S(L) = S(L) || TS(4) || '=' || TS(3) || ', ';     00247610
                           END;                                                 00247620
                        END;                                                    00247630
                        S(L) = SUBSTR(S(L),0,LENGTH(S(L))-2);                   00247640
                        CALL FLUSH(L,1);                                        00247650
                     END;                                                       00248400
                     IF VERSION>=26 THEN DO;                                    00248500
                        L = 1;                                                  00248510
                        IF (SFLAG & "40") ^= 0 THEN DO;                         00248520
                           IF STYPE>=9 & STYPE<=12 THEN S(1) = '  PROCESSES:';  00248530
                           ELSE S(1) = '  TARGET(S):';                          00248540
                           IF VERSION>=28 THEN CALL FORMAT_CELL_TREE(NODE_F(-4)|00248550
                              "8000 0000",1);                                   00248560
                           ELSE CALL FORMAT_CELL_TREE(NODE_F(-2)|"80000000",1); 00248570
                        END;                                                    00248580
                        L = 1;                                                  00248590
                        IF (SFLAG & "20") ^= 0 THEN DO;                         00248600
                           S(1) = '  RHS VARS: ';                               00248610
                           IF VERSION>=28 THEN CALL FORMAT_CELL_TREE(NODE_F(-3)|00248620
                              "8000 0000",1);                                   00248630
                           ELSE CALL FORMAT_CELL_TREE(NODE_F(-1)|"80000000",1); 00248640
                        END;                                                    00248650
                     END;                                                       00248660
                  END;                                                          00248670
                  IF LENGTH(S) > 0 THEN OUTPUT = S;                             00248680
                  IF HMAT_OPT                                                   00248690
                     THEN CALL DUMP_HALMAT(HMAT_PTR);                           00248700
                  CALL SDF_PTR_LOCATE(ABS(PTR),RELS);                           00248710
               END;                                                             00248720
            END;                                                                00248800
         END;                                                                   00248900
/*CR13353 - BEGIN PRINTOUT OF BUILTIN FUNCTION XREF DATA */
         IF #BIFUNCS > 0 THEN DO;
            OUTPUT(1) = '2';
            OUTPUT(1) = '1';
            OUTPUT = X30||'B U I L T - I N   F U N C T I O N   '||
                     'C R O S S   R E F E R E N C E';
            OUTPUT = X1;
            /* LOCATE FUNCTION INDEX TABLE */
            CALL SDF_LOCATE(BASE_BI_PTR,ADDR(NODE_F1),RESV);
            DO I = 0 TO #BIFUNCS-1;
               TS = FORMAT(I+1,5);
               TS = X3 || TS;
               TS(1) = BI_NAME(NODE_F1(I*2)); /* EACH ENTRY IS 2 FULLWORDS */
               K = LENGTH(TS(1));
               CHAR_STRING = X2 || TS(1);
               CHAR_STRING = CHAR_STRING || SUBSTR(X72,0,32-K);
               TS(1) = CHAR_STRING;
               OUTPUT = TS || TS(1);
               PTR = NODE_F1(I*2+1); /* PTR TO XREF DATA - EACH ENTRY IS 2 FW */
               CALL SDF_LOCATE(PTR,ADDR(NODE_F),0);
               COREWORD(ADDR(NODE_H)) = LOC_ADDR;
               CALL PRINT_XREF_DATA(0);
            END;
            CALL SDF_PTR_LOCATE(BASE_BI_PTR,RELS);
         END;
/*CR13353 - END*/
      END;                                                                      00249000
      OUTPUT(1) = '2';                                                          00249100
      IF INITIAL_ON(0) THEN          /*CR13079*/
         CALL PRINT_#D_INFO(TRUE);   /*CR13079*/
      IF INITIAL_ON(1) THEN          /*CR13079*/
         CALL PRINT_#D_INFO(FALSE);  /*CR13079*/
   END DUMP_SDF   /* $S */ ; /* $S */                                           00249200
