 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ##DRIVER.xpl
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
 /* PROCEDURE NAME:  MAIN PROGRAM                                           */
 /* MEMBER NAME:     ##DRIVER                                               */
 /* PURPOSE:         THE DRIVER PROGRAM FOR A PHASE OF THE COMPILER.        */
 /*                  THIS MEMBER IS THE MAIN PROGRAM, THE OTHER MEMBERS     */
 /*                  SHOULD BE CHECKED FOR HEADER INFORMATION.              */
 /* LOCAL DECLARATIONS:                                                     */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /* CALLED BY:                                                              */
 /***************************************************************************/
 /*                                                                         */
 /* REVISION HISTORY:                                                       */
 /*                                                                         */
 /* DATE     WHO  RLS   DR/CR #  DESCRIPTION                                */
 /*                                                                         */
 /* 01/21/91 DKB  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 03/07/91 DKB  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /*                                                                         */
 /* 04/03/91 JAC  23V2  CR11098  INCREASED VERSION NUMBER FOR SDF           */
 /*                                                                         */
 /* 04/09/91 RSJ  24V0  CR11096F INCREASED VERSION NUMBER FOR SDF           */
 /*                                                                         */
 /* 12/23/92 PMA   8V0  *        MERGED 7V0 AND 24V0 COMPILERS.             */
 /*                              * REFERENCE 24V0 CR/DRS                    */
 /*                                                                         */
 /*  5/17/93 RSJ   25V0 CR11097  INCREASED VERSION NUMBER FOR SDF           */
 /*                 9V0                                                     */
 /*                                                                         */
 /*  4/06/94 JAC   26V0 DR108643 INCORRECTLY LISTS 'NONHAL' INSTEAD OF      */
 /*                10V0          'INCREM' IN SDFLIST                        */
 /*                                                                         */  01540000
 /* 03/15/95 DAS  27V0  DR103787 WRONG VALUE LOADED FROM REGISTER FOR A     */  01520000
 /*               11V0           STRUCTURE NODE REFERENCE                   */  01530000
 /*                              (INCREASED VERSION NUMBER FOR SDF)         */
 /*                                                                         */
 /* 04/03/00 DCP  30V0  CR13273  PRODUCE SDF MEMBER WHEN OBJECT MODULE      */
 /*               15V0           CREATED                                    */
 /*                                                                         */
 /* 01/31/00 DCP  30V0  CR13211  GENERATE ADVISORY MESSAGE WHEN BIT STRING  */
 /*               15V0           ASSIGNED TO SHORTER STRING                 */
 /*                                                                         */
 /* 07/14/99 DCP  30V0  CR12214  USE THE SAFEST %MACRO THAT WORKS           */
 /*               15V0                                                      */
 /*                                                                         */
 /*  4/08/99 SMR   30V0 CR13079  ADD HAL/S INITIALIZATION DATA TO SDF       */
 /*                15V0                                                     */
 /*                                                                         */  01540000
 /* 03/02/01 DAS   31V0 CR13353 ADD SIZE OF BUILTIN FUNCTIONS XREF TABLE    */
 /*                16V0         INTO SDF                                    */
 /*                                                                         */
 /* 03/02/04 DCP   32V0 CR13811 ELIMINATE STACK WALKBACK CAPABILITY         */
 /*                17V0                                                     */
 /*                                                                         */
 /***************************************************************************/
 /* EDIT #146     17 AUGUST 1977     VERSION 25     */                          00100000
                                                                                00100100
 /*  $Z MAKES THE CODE GO ON ERRORS  */                                         00100200
 /* $HH A L / S   C O M P I L E R   --   P H A S E   3   --   I N T E R M E T   00100300
R I C S ,   I N C .   */                                                        00100400
                                                                                00100410
 /* PHASE 3 VERSION NUMBER */                                                   00100420
                                                                                00100430
   DECLARE VERSION# LITERALLY '35';     /*CR13079*/ /*CR13353*/
                                                                                00100450
 /*   LIMITING PHASE 3 SIZES AND LENGTHS   */                                   00100500
                                                                                00100600
DECLARE  SDF_SIZE LITERALLY '599',         /* MAXIMUM NUMBER OF SDF PAGES     */00100700
      PAGE_SIZE LITERALLY '1680',       /* PHYSICAL BLOCK SIZE OF SDF PAGES*/   00100800
      MAX_CELL LITERALLY '210',         /* MAXIMUM ALLOWABLE CELL SIZE     */   00100900
      LHS_SIZE LITERALLY '255',         /* MAX OF 256 LHS INDICES PER STMT */   00101100
      LABEL_SIZE LITERALLY '255',       /* MAX OF 256 LABELS PER STMT      */   00101200
      LIM_PAGE LITERALLY '399',         /* MAX # OF IN-CORE PAGES (-1)     */   00101300
      PROC_MAX LITERALLY '255',         /* MAX # OF HAL BLOCKS ALLOWED     */   00101400
      TPL_MAX LITERALLY '1023',         /* MAX # OF TEMPLATES              */   00101500
      STRUC_NEST LITERALLY '100',       /* MAX DEPTH OF NESTED TEMPLATES  */    00101600
      XREF_MAX LITERALLY '3000',        /* MAX # OF XREFS */                    00101700
      ROOT_DIR_SZ LITERALLY '204',   /* SIZE OF DIRECTORY CELL *//*CR13353*/
      DIR_ALOC_SZ LITERALLY 'ROOT_DIR_SZ+16', /* SIZE USED TO ALLOC CELL */     00101720
      DIR_MARGIN LITERALLY '30';        /* DIRECTORY SIZING MARGIN FACTOR  */   00101800
                                                                                00101900
   DECLARE TRUE LITERALLY '1',                                                  00102000
      FALSE LITERALLY '0',                                                      00102100
      FC LITERALLY 'OBJECT_MACHINE = 1';                                        00102200
                                                                                00102300
   DECLARE (IX1,IX2,SELFNAMELOC) BIT(16);                                       00102400
   DECLARE (TMP,WORK1,WORK2) FIXED;                                             00102500
                                                                                00102600
   DECLARE       (OP1,OP2,OP3,OP4) BIT(16),                                     00102700
 /*   OPERAND TYPES AFTER INITIALIZE TIME ...  FLAG OF                          00102800
                   "8" INDICATES DOUBLE PRECISION                   */          00102900
      BITS      BIT(16) INITIAL (1),                                            00103000
      CHAR      BIT(16) INITIAL (2),                                            00103100
      MATRIX    BIT(16) INITIAL (3),                                            00103200
      VECTOR    BIT(16) INITIAL (4),                                            00103300
      SCALAR    BIT(16) INITIAL (5),                                            00103400
      INTEGER   BIT(16) INITIAL (6),                                            00103500
      FULLBIT   BIT(16) INITIAL (9),                                            00103600
      BOOLEAN   BIT(16) INITIAL (10),                                           00103700
      DMATRIX   BIT(16) INITIAL (11),                                           00103800
      DVECTOR   BIT(16) INITIAL (12),                                           00103900
      DSCALAR   BIT(16) INITIAL (13),                                           00104000
      DINTEGER  BIT(16) INITIAL (14),                                           00104100
      STRUCTURE BIT(16) INITIAL (16),                                           00104200
      EVENT     BIT(16) INITIAL (17);                                           00104300
                                                                                00104400
 /* USEFUL CHARACTER LITERALS */                                                00104500
   DECLARE  COLON          CHARACTER INITIAL (':'),                             00104600
      X1          CHARACTER INITIAL (' '),                                      00104700
      HEXCODES       CHARACTER INITIAL ('0123456789ABCDEF'),                    00104800
      P3ERR          CHARACTER INITIAL ('*** PHASE 3 INTERNAL ERROR: '),        00105000
      X2             CHARACTER INITIAL ('  '),                                  00105100
      X3             CHARACTER INITIAL ('   '),                                 00105200
      X4             CHARACTER INITIAL ('    '),                                00105300
      X5             CHARACTER INITIAL ('     '),                               00105400
      X6             CHARACTER INITIAL ('      '),                              00105500
      X7             CHARACTER INITIAL ('       '),                             00105600
      X10            CHARACTER INITIAL ('          '),                          00105700
      X20            CHARACTER INITIAL ('                    '),                00105900
      X30            CHARACTER INITIAL                                          00106200
      ('                              '),                                       00106300
      X52            CHARACTER INITIAL                                          00106400
      ('                                                    '),                 00106500
      X72            CHARACTER INITIAL                                          00106600
   ('                                                                        ');00106700
                                                                                00106800
 /*  SYMBOL TABLE DEPENDENT DECLARATIONS  */                                    00110000
                                                                                00110100
   DECLARE  SYT_SIZE BIT(16);                                                   00110200
   /%INCLUDE COMMON %/                                                          00110210
                                                                                00110400
      BASED SORTING  RECORD:                                                    00112800
         SYM_SORT1   BIT(16),                                                   00112900
         SYM_SORT2   BIT(16),                                                   00113000
         SYM_SORT3   BIT(16),                                                   00113100
         SYM_SORT4   BIT(16),                                                   00113200
         TAB_DEL     BIT(16),                                                   00113300
         SYM_SORT5   BIT(16),                                                   00113400
      END;                                                                      00113500
   BASED VALS FIXED;                                                            00113700
                                                                                00113800
   ARRAY                                                                        00113900
      XREF_TAB(XREF_MAX) BIT(16),                                               00114000
      PROC_TAB1(PROC_MAX) BIT(16),                                              00114100
      PROC_TAB2(PROC_MAX) BIT(16),                                              00114200
      PROC_TAB3(PROC_MAX) BIT(16),                                              00114300
      PROC_TAB4(PROC_MAX) FIXED,                                                00114400
      PROC_TAB5(PROC_MAX) BIT(16),                                              00114500
      PROC_TAB6(PROC_MAX) BIT(16),                                              00114600
      PROC_TAB7(PROC_MAX) BIT(16),                                              00114700
      PROC_TAB8(PROC_MAX) BIT(16),                                              00114800
      PROC_TAB9(PROC_MAX) BIT(16),                                              00114900
      TPL_TAB1(TPL_MAX) BIT(16),                                                00115000
      TPL_TAB2(TPL_MAX) BIT(16),                                                00115100
      TPL_STACK(STRUC_NEST) BIT(16),                                            00115200
      PROC_FLAGS(PROC_MAX) BIT(8);                                              00115400
                                                                                00115500
   DECLARE        LIT_CHAR_USED  LITERALLY 'COMM(1)',                           00116100
      LIT_TOP        LITERALLY 'COMM(2)',                                       00116300
      STMT_NUM       LITERALLY 'COMM(3)',                                       00116400
      MAX_SCOPE#     LITERALLY 'COMM(5)',                                       00116600
      OPTIONS_CODE   LITERALLY 'COMM(7)',                                       00116800
      XREF_USED      LITERALLY 'COMM(8)',                                       00116900
      MACRO_USED     LITERALLY 'COMM(9)',                                       00117000
      ACTUAL_SYMBOLS LITERALLY 'COMM(10)',                                      00117100
      FIRST_STMT     LITERALLY 'COMM(11)',                                      00117105
      PHASE1_TIME    LITERALLY 'COMM(12)',                                      00117110
      PHASE1_DATE    LITERALLY 'COMM(13)',                                      00117115
      INCLUDE_LIST_HEAD LITERALLY 'COMM(14)',                                   00117120
      MACRO_BYTES    LITERALLY 'COMM(15)',                                      00117130
      STMT_DATA_HEAD LITERALLY 'COMM(16)',                                      00117140
      COMSUB_END     LITERALLY 'COMM(17)',                                      00117150
      BLOCK_SRN_DATA   LITERALLY 'COMM(18)',                                    00117160
      OBJECT_MACHINE LITERALLY 'COMM(20)',                                      00117200
      EMITTED_CNT    LITERALLY 'COMM(21)',                                      00117300
      CODEHWM_HEAD LITERALLY 'COMM(30)',                                        00117410
      TOTAL_HMAT_BYTES LITERALLY 'COMM(31)',                                    00117420
      SDF_NAM1       LITERALLY 'COMM(40)',                                      00117430
      SDF_NAM2       LITERALLY 'COMM(41)';                                      00117440
   BASED SRN_BLOCK_RECORD FIXED;                                                00117445
   DECLARE UNMOVEABLE LITERALLY '0';                                            00117460
   DECLARE  SYT_NAME(1) LITERALLY 'SYM_TAB(%1%).SYM_NAME',                      00117470
      SYT_ADDR(1) LITERALLY 'SYM_TAB(%1%).SYM_ADDR',                            00117480
      SYT_XREF(1) LITERALLY 'SYM_TAB(%1%).SYM_XREF',                            00117490
      SYT_NEST(1) LITERALLY 'SYM_TAB(%1%).SYM_NEST',                            00117500
      SYT_SCOPE(1) LITERALLY 'SYM_TAB(%1%).SYM_SCOPE',                          00117510
      SYT_DIMS(1) LITERALLY 'SYM_TAB(%1%).SYM_LENGTH',                          00117520
      SYT_ARRAY(1) LITERALLY 'SYM_TAB(%1%).SYM_ARRAY',                          00117530
      SYT_PTR(1) LITERALLY 'SYM_TAB(%1%).SYM_PTR',                              00117540
      SYT_LINK1(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK1',                          00117550
      SYT_LINK2(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK2',                          00117560
      SYT_CLASS(1) LITERALLY 'SYM_TAB(%1%).SYM_CLASS',                          00117570
      SYT_FLAGS(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS',                          00117580
      SYT_FLAGS2(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS2', /* DR108643 */         00117580
      SYT_LOCK#(1) LITERALLY 'SYM_TAB(%1%).SYM_LOCK#',                          00117590
      SYT_TYPE(1) LITERALLY 'SYM_TAB(%1%).SYM_TYPE',                            00117600
      VAR_EXTENT(1) LITERALLY 'SYM_TAB(%1%).XTNT',                              00117610
      XREF(1) LITERALLY 'CROSS_REF(%1%).CR_REF',                                00117620
      LIT1(1) LITERALLY 'LIT_PG.LITERAL1(%1%)',                                 00117640
      LIT2(1) LITERALLY 'LIT_PG.LITERAL2(%1%)',                                 00117650
      LIT3(1) LITERALLY 'LIT_PG.LITERAL3(%1%)';                                 00117660
   DECLARE  SYT_SORT1(1) LITERALLY 'SORTING(%1%).SYM_SORT1',                    00117690
      SYT_SORT2(1) LITERALLY 'SORTING(%1%).SYM_SORT2',                          00117700
      SYT_SORT3(1) LITERALLY 'SORTING(%1%).SYM_SORT3',                          00117710
      SYT_SORT4(1) LITERALLY 'SORTING(%1%).SYM_SORT4',                          00117720
      DEL_TAB(1) LITERALLY 'SORTING(%1%).TAB_DEL',                              00117730
      SYT_SORT5(1) LITERALLY 'SORTING(%1%).SYM_SORT5';                          00117740
   DECLARE   SYT_NUM(1) LITERALLY 'SYM_ADD(%1%).SYM_NUM',                       00117750
      SYT_VPTR(1) LITERALLY 'SYM_ADD(%1%).SYM_VPTR';                            00117760
                                                                                00117770
   DECLARE       VAR_CLASS     BIT(16)  INITIAL (1),                            00117780
      LABEL_CLASS   BIT(16)  INITIAL (2),                                       00117790
      FUNC_CLASS    BIT(16)  INITIAL (3),                                       00117800
      REPL_ARG_CLASS BIT(16) INITIAL (5),                                       00117900
      REPL_CLASS    BIT(16)  INITIAL (6),                                       00118000
      TEMPLATE_CLASS BIT(16) INITIAL (7),                                       00118100
      TPL_LAB_CLASS BIT(16)  INITIAL (8),                                       00118200
      TPL_FUNC_CLASS BIT(16) INITIAL (9),                                       00118300
      LOCK_FLAG     FIXED  INITIAL ("00000001"),                                00118400
      REENTRANT_FLAG FIXED INITIAL ("00000002"),                                00118500
      DENSE_FLAG    FIXED  INITIAL ("00000004"),                                00118600
      EQUATE_FLAG   FIXED  INITIAL ("00000008"),   /* PH 3 USE ONLY */          00118700
      LINK_FLAG     FIXED  INITIAL ("00000010"),   /* PH 3 USE ONLY */          00118800
      ASSIGN_FLAG   FIXED  INITIAL ("00000020"),                                00118900
      REMOTE_FLAG   FIXED  INITIAL ("00000080"),                                00119000
      AUTO_FLAG     FIXED  INITIAL ("00000100"),                                00119100
      INPUT_PARM    FIXED  INITIAL ("00000400"),                                00119200
      INIT_FLAG     FIXED  INITIAL ("00000800"),                                00119300
      CONST_FLAG    FIXED  INITIAL ("00001000"),                                00119400
      SYT_VPTR_FLAG  FIXED  INITIAL ("00004000"),   /* PH 3 USE ONLY */         00119600
      BITMASK_FLAG FIXED INITIAL("00008000"),                                   00119610
      ACCESS_FLAG   FIXED  INITIAL ("00010000"),                                00119700
      LATCH_FLAG    FIXED  INITIAL ("00020000"),                                00119800
      IMPL_T_FLAG   FIXED  INITIAL ("00040000"),                                00119900
      EXCLUSIVE_FLAG FIXED INITIAL ("00080000"),                                00120000
      EXTERNAL_FLAG FIXED  INITIAL ("00100000"),                                00120100
      DOUBLE_FLAG   FIXED  INITIAL ("00400000"),                                00120300
      IGNORE_FLAG   FIXED  INITIAL ("01000000"),                                00120400
      INCLUDED_REMOTE FIXED INITIAL ("02000000"),   /* DR108643 */
      RIGID_FLAG    FIXED  INITIAL ("04000000"),                                00120600
      TEMPORARY_FLAG FIXED INITIAL ("08000000"),                                00120700
      NAME_FLAG     FIXED  INITIAL ("10000000"),                                00120800
      MISC_NAME_FLAG FIXED INITIAL ("40000000"),                                00120810
      INDIRECT_FLAG FIXED  INITIAL ("80000000"),                                00120900
      PROC_LABEL    BIT(16)  INITIAL ("47"),                                    00121400
      TASK_LABEL    BIT(16)  INITIAL ("48"),                                    00121500
      PROG_LABEL    BIT(16)  INITIAL ("49"),                                    00121600
      COMPOOL_LABEL BIT(16)  INITIAL ("4A"),                                    00121700
      EQUATE_LABEL  BIT(16)  INITIAL ("4B"),                                    00121800
      NONHAL_FLAG   BIT(8) INITIAL ("01");   /* DR108643 */                     00120500
                                                                                00121900
 /* VIRTUAL MEMORY MANAGEMENT DECLARATIONS */                                   00122000
                                                                                00122100
DECLARE  PGAREA_START FIXED,               /* ADDR OF FIRST LOC OF PAGING AREA*/00122200
      PGAREA_LIMIT FIXED,               /* ADDR OF LAST LOC OF PAGING AREA */   00122300
      MAX_PAGE BIT(16),                 /* # OF LAST IN-CORE PAGE (-1)     */   00122400
      MAX_PAGE_PRED BIT(16);            /* GUESSTIMATE OF MAX_PAGE         */   00122500
                                                                                00122600
 /* PAGING AREA DIRECTORY */                                                    00122700
   BASED PGAREA RECORD:                                                         00122800
         PGNDX  (420)  FIXED,                                                   00122810
      END;                                                                      00122820
                                                                                00122830
DECLARE  PAD_PAGE(LIM_PAGE) BIT(16),       /* SDF PAGE NUMBER                 */00122900
      PAD_ADDR(LIM_PAGE) FIXED,         /* CORE ADDRESS OF SDF PAGE        */   00123000
      PAD_DISP(LIM_PAGE) BIT(16),       /* MODIFY BIT & RESERVE COUNT      */   00123100
      PAD_CNT(LIM_PAGE) BIT(16);        /* USAGE COUNTER                   */   00123200
                                                                                00123300
 /* MAPPING TABLE 1 -- PAGE # TO FILE 5 PHYSICAL BLOCK NUMBERS */               00123400
                                                                                00123500
DECLARE  PAGE_TO_LREC(SDF_SIZE) BIT(16);   /* FILE 5 BLK NUMBERS OF SDF PAGES */00123600
                                                                                00123700
 /* MAPPING TABLE 2 -- PAGE # TO PAD INDICES */                                 00123800
                                                                                00123900
DECLARE  PAGE_TO_NDX(SDF_SIZE) BIT(16);    /* PAD INDEX VALUES FOR SDF PAGES  */00124000
                                                                                00124100
 /* SDF GLOBAL PARAMETERS */                                                    00124200
                                                                                00124300
 DECLARE FIRST#D_PAGE BIT(16) INITIAL(-1);  /*CR13079*/
 DECLARE  LAST_PAGE BIT(16) INITIAL (-1),   /* # OF LAST SDF PAGE             */00124400
      LOC_PTR FIXED,                    /* POINTER LAST LOCATED */              00124500
      LOC_ADDR FIXED,                   /* CORE ADDRESS LAST LOCATED */         00124600
      READ_CNT FIXED,                   /* NUMBER OF READS FROM FILE 5    */    00124700
      WRITE_CNT FIXED,                  /* NUMBER OF WRITES TO FILE 5     */    00124800
      LOC_CNT FIXED,                    /* NUMBER OF SDF LOCATES */             00124900
      RESV_CNT FIXED,                   /* ACCUMULATED RESERVE COUNT      */    00125000
      LAST_LREC BIT(16) INITIAL (-1),   /* RECORD # OF LAST FILE 5 PAGE   */    00125100
      LAST_DIR_PTR FIXED,               /* POINTER TO END OF DIRECTORY    */    00125200
      FIRST_DATA_PTR FIXED,             /* POINTER TO FIRST PAGE OF DATA  */    00125300
      FIRST_BLOCK_PTR FIXED,            /* POINTER TO FIRST BLOCK NODE    */    00125400
      LAST_BLOCK_PTR FIXED,             /* POINTER TO LAST BLOCK NODE     */    00125500
      FIRST_SYMB_PTR FIXED,             /* POINTER TO FIRST SYMBOL NODE   */    00125600
      LAST_SYMB_PTR FIXED,              /* POINTER TO LAST SYMBOL NODE    */    00125700
      LIT_ADDR FIXED,                  /* ADDRESS OF START OF LITERAL AREA */   00125705
      REF_STMT BIT(16),                 /* STMT # OF FIRST INTERNAL STMT  */    00125800
      LAST_STMT BIT(16),                /* NUMBER OF LAST STATEMENT       */    00126000
      FIRST_STMT_PTR FIXED,             /* POINTER TO FIRST STMT NODE     */    00126100
      LAST_STMT_PTR FIXED,              /* POINTER TO LAST STMT NODE      */    00126200
      HALMAT_CELL FIXED,    /* POINTER TO STMT HALMAT */                        00126210
      FIRST_FREE_PTR FIXED,             /* POINTER TO FIRST USABLE AREA   */    00126300
      ROOT_PTR FIXED,                   /* POINTER TO DIRECTORY ROOT NODE */    00126400
      BIAS BIT(16),                     /* FULLWORD OFFSET TO STMT PTR    */    00126500
      STRING_MARGIN FIXED,              /* # OF BYTES FOR THE STRING AREA */    00126600
      DIR_FREE_SPACE BIT(16),           /* SIZE OF DIRECTORY FREE AREA    */    00126700
      DATA_FREE_SPACE BIT(16),          /* SIZE OF DATA FREE AREA         */    00126800
      #_SYMB_BYTES FIXED,               /* # OF BYTES FOR SYMBOL NODES    */    00126900
      #_STMT_BYTES FIXED,               /* # OF BYTES FOR STMT NODES      */    00127000
      #_BLOCK_BYTES FIXED,              /* # OF BYTES FOR BLOCK NODES     */    00127100
      BASE_SYMB_PAGE BIT(16),           /* FIRST_SYMB_PTR (HI-ORDER HALF) */    00127200
      BASE_SYMB_OFFSET BIT(16),         /* FIRST_SYMB_PTR (LO-ORDER HALF) */    00127300
      BASE_STMT_PAGE BIT(16),           /* FIRST_STMT_PTR (HI-ORDER HALF) */    00127400
      BASE_STMT_OFFSET BIT(16),         /* FIRST_STMT_PTR (LO-ORDER HALF) */    00127500
      BASE_BLOCK_PAGE BIT(16),          /* FIRST_BLOCK_PTR (HI-ORDER HALF)*/    00127600
      BASE_BLOCK_OFFSET BIT(16),        /* FIRST_BLOCK_PTR (LO-ORDER HALF)*/    00127700
      LAST_DIR_PAGE BIT(16),            /* LAST PAGE OF THE SDF DIRECTORY */    00127800
      FIRST_DATA_PAGE BIT(16),          /* FIRST PAGE OF FIXED-LENGTH DATA*/    00127900
      FIRST_FREE_PAGE BIT(16),          /* FIRST PAGE FOR VAR LENGTH DATA */    00128000
      STMT_NODES_PER_PAGE BIT(16),      /* # OF STATEMENT NODES PER PAGE  */    00128100
      SYMB_NODES_PER_PAGE BIT(16),      /* # OF SYMBOL NODES PER PAGE     */    00128200
      BLOCK_NODES_PER_PAGE BIT(16),     /* # OF BLOCK NODES PER PAGE      */    00128300
      STMT_NODE_SIZE BIT(16),           /* STMT NODE SIZE (4 OR 12 BYTES) */    00128400
      SYMB_NODE_SIZE LITERALLY '12',    /* SYMBOL NODE SIZE (12 BYTES)    */    00128500
      BLOCK_NODE_SIZE LITERALLY '12',   /* BLOCK NODE SIZE (12 BYTES)     */    00128600
      #DEL_SYMBOLS BIT(16),             /* NUMBER OF DELETED SYMBOLS      */    00128700
      #DEL_TPLS BIT(16),                /* NUMBER OF DELETED TEMPLATES    */    00128800
      #SYMBOLS BIT(16),                 /* TOTAL NUMBER OF SYMBOL NODES   */    00128900
      SAVE_NDECSY BIT(16),              /* TOTAL NUMBER OF SYMBOL ENTRIES */    00129000
      #STMTS BIT(16),                   /* TOTAL NUMBER OF STMT NODES     */    00129100
      #EXECS BIT(16),                   /* TOTAL NUMBER OF EXECUTABLE STMTS*/   00129200
      #COMPOOLS BIT(16),                /* NUMBER OF INCLUDED COMPOOLS    */    00129300
      #EXTERNALS BIT(16),               /* NUMBER OF INCLUDED EXTERNALS   */    00129400
      #UNQUAL BIT(16),                  /* NUMBER OF UNQUALIFIED STRUCS.  */    00129500
      #TPLS1 BIT(16),                   /* NUMBER OF DELETABLE TEMPLATES  */    00129600
      #TPLS2 BIT(16),                   /* NUMBER OF TEMPLATES  TO SAVE   */    00129700
      K#PROCS BIT(16),                  /* INITIAL BLOCK COUNT            */    00129800
      #PROCS BIT(16),                   /* NUMBER OF HAL BLOCKS           */    00129900
      UNIT_ID BIT(16),                  /* COMPILATION UNIT ID CODE       */    00130000
      XREF_MASK BIT(16) INITIAL ("E000"),/* CROSS REF TABLE MASK          */    00130100
      NEW_NDX BIT(16),                  /* PAD INDEX OF NEXT VULNERABLE PG*/    00130200
      OLD_NDX BIT(16) INITIAL (-1);     /* PAD INDEX OF LAST 'LOCATED' PG */    00130300
                                                                                00130400
 /*          $%VMEM1          */                                                00130500
 /* $%COMDEC19 */                                                               00130510
 /*          $%VMEM2          */                                                00130520
                                                                                00131000
 /* POINTER TO THE LISTHEAD OF THE SDF DATA FREE CELL CHAIN */                  00131100
                                                                                00131200
   DECLARE  FREE_CHAIN FIXED;                                                   00131300
                                                                                00131400
 /* MODE INDICATION FLAGS */                                                    00131500
                                                                                00131600
DECLARE  SRN_FLAG BIT(1) INITIAL(0),       /* 1 --> SDF HAS SRNS (SDL CONFIG) */00131700
      ADDR_FLAG BIT(1) INITIAL(0),      /* 1 --> SDF HAS STMT ADDRESSES    */   00131800
      SDL_FLAG BIT(1) INITIAL(0),       /* 1 --> SDL OPERATION             */   00131900
      COMPOOL_FLAG BIT(1) INITIAL(0),   /* 1 --> SDF IS FOR A COMPOOL UNIT */   00132000
      OVERFLOW_FLAG BIT(1) INITIAL(0),  /* 1 --> DIRECTORY OVERFLOW        */   00132100
      NOTRACE_FLAG BIT(1) INITIAL(0),   /* 1 --> 360 COMPILATION W/O HOOKS */   00132200
      SRN_FLAG1 BIT(1) INITIAL(0),      /* 1 --> NON-MONOTONIC SRN(S)      */   00132300
      SRN_FLAG2 BIT(1) INITIAL(0),      /* 1 --> NON-UNIQUE SRN(S)         */   00132400
      RIGID_CPL_FLAG BIT(1) INITIAL(0), /* 1 --> UNIT IS A RIGID COMPOOL   */   00132500
      BOMB_FLAG BIT(1) INITIAL(0),      /* 1 --> SEVERE ERROR DETECTED     */   00132600
      PSEUDO_TPL_FLAG BIT(1) INITIAL(0), /* 1 --> TEMPLATE W/ NO STRUC     */   00132602
      HEX_DUMP_FLAG BIT(1) INITIAL(0),  /* 1 --> HEX DUMP REQUESTED        */   00132700
      DLIST BIT(1) INITIAL(0),          /* 1 --> LIST DELETED SYMBOLS      */   00132800
      DEBUG BIT(1) INITIAL(0),          /* 1 --> PRINT ALL AVAILABLE INFO  */   00132900
      FCDATA_FLAG BIT(1) INITIAL(0),    /* 1 --> 360 RUN WITH FCDATA       */   00132910
      HMAT_OPT BIT(10) INITIAL(0), /* 1 -> HALMAT IN SDF */                     00132920
      OVERFLOW BIT(1) INITIAL(0),  /*  1 -> OVERFLOW CODE PRESENT */            00132950
      HIGHOPT  BIT(1) INITIAL(0),  /* 1 -> HIGHOPT OPTION ON - DR103787 */      00132950
 /*  FOR CURRENT STATMENT       */                                              00132960
      SDF_SUMMARY BIT(1) INITIAL(0);    /* 1 --> SDF SUMMARY REQUESTED     */   00133000
                                                                                00133100
 /* DECLARATIONS FOR FILE 6 (PHASE 1/2 STATEMENT DATA) VARIABLES */             00133200
                                                                                00133300
   DECLARE  LABEL_TAB(LABEL_SIZE) BIT(16),                                      00133400
      LHS_TAB(LHS_SIZE) BIT(16),                                                00133500
      (DATA_CELL_PTR,RHS_PTR,LHS_PTR,DECL_EXP_PTR) FIXED,                       00133510
      STMT_DATA(20) BIT(16),                                                    00133600
      SDC_FLAGS BIT(16),                                                        00133610
      (#LABELS,#LHS,STAB_FIXED_LEN,LHSSAVE,TZCOUNT) BIT(16);                    00133800
   DECLARE OLD_INT_BLOCK# FIXED;                                                00133810
                                                                                00133900
   BASED HWMCELL RECORD:                                                        00133910
         NEXT_CELL_PTR FIXED,                                                   00133920
         LENGTH BIT(16),                                                        00133930
         NAME(7) BIT(8),                                                        00133940
      END;                                                                      00133950

   BASED RVL_SRN RECORD:                                 /*CR12214*/
         SRN CHARACTER,                                  /*CR12214*/
         RVL BIT(16),                                    /*CR12214*/
      END;                                               /*CR12214*/

   DECLARE SRN#(1) LITERALLY 'RVL_SRN(%1%).SRN',         /*CR12214*/
           RVL#(1) LITERALLY 'RVL_SRN(%1%).RVL';         /*CR12214*/

   DECLARE INIT_VAL(1) LITERALLY 'INIT_TAB(%1%).VALUE'; /*CR13079*/
   DECLARE #D_FREE_SPACE BIT(16);                       /*CR13079*/
 /* MISCELLANEOUS DECLARATIONS */                                               00134000
   DECLARE FOREVER LITERALLY 'WHILE 1',                                         00134100
      PRINTLINE CHARACTER,                                                      00134200
      (PHASE3_ERROR,NO_CORE,NO_PAGES,COMMON_ERROR) LABEL,                       00134300
      CLOCK(3) FIXED;                                                           00134400

   DECLARE ADV_STMT#(1) LITERALLY 'ADVISE(%1%).STMT#',   /*CR12214*/
           ADV_ERROR#(1) LITERALLY 'ADVISE(%1%).ERROR#'; /*CR12214*/
                                                                                00134405
 /**MERGE KOREWORD     KOREWORD                        */
 /**MERGE CHARINDE     CHAR_INDEX                      */
 /**MERGE FORMAT       FORMAT                          */
 /**MERGE GETLITER     GET_LITERAL                     */
 /**MERGE HEX          HEX                             */
 /**MERGE HEX8         HEX8                            */
 /**MERGE MIN          MIN                             */
 /**MERGE SYTNAME1     SYT_NAME1                       */
 /**MERGE PRINTTIM     PRINT_TIME                      */
 /**MERGE PRINTDAT     PRINT_DATE_AND_TIME             */
 /**MERGE GETARRAY     GETARRAYDIM                     */
 /**MERGE GETARRA2     GETARRAY#                       */
 /**MERGE SDFNAME      SDF_NAME                        */
 /**MERGE CSECTNAM     CSECT_NAME                      */
 /**MERGE PAD          PAD                             */
 /**MERGE PTRFIX       PTR_FIX                         */
 /**MERGE STMTTOPT     STMT_TO_PTR                     */
 /**MERGE SYMBTOPT     SYMB_TO_PTR                     */
 /**MERGE BLOCKTOP     BLOCK_TO_PTR                    */
 /**MERGE P3DISP       P3_DISP                         */
 /**MERGE PAGINGS2     PAGING_STRATEGY                 */
 /**MERGE P3PTRLOC     P3_PTR_LOCATE                   */
 /**MERGE P3LOCATE     P3_LOCATE                       */
 /**MERGE EXTRACT4     EXTRACT4                        */
 /**MERGE PUTN         PUTN                            */
 /**MERGE ZERON        ZERON                           */
 /**MERGE TRAN         TRAN                            */
 /**MERGE PAGEDUMP     PAGE_DUMP                       */
 /**MERGE P3GETCEL     P3_GET_CELL                     */
 /**MERGE GETDIRCE     GET_DIR_CELL                    */
 /**MERGE GETDATAC     GET_DATA_CELL                   */
 /**MERGE CHECKCOM     CHECK_COMPOUND                  */
 /**MERGE LHSCHECK     LHS_CHECK                       */
 /**MERGE BUILDSDF     BUILD_SDF_LITTAB                */
 /**MERGE BUILDINI     BUILD_INITTAB      */ /*CR13079*/
 /**MERGE REFORMAT     REFORMAT_HALMAT                 */
 /**MERGE GETSTMTD     GET_STMT_DATA                   */
 /**MERGE EMITKEYS     EMIT_KEY_SDF_INFO               */
 /**MERGE OUTPUTSD     OUTPUT_SDF                      */
 /**MERGE INITIALI     INITIALIZE                      */
 /**MERGE BUILDSD2     BUILD_SDF                       */
 /**MERGE PRINTSUM     PRINTSUMMARY                    */
                                                                                00520900
 /*  START OF THE MAIN PROGRAM  */                                              00521000
MAIN_PROGRAM:                                                                   00521100
   DECLARE T FIXED,                                                             00521200
      TS(12) CHARACTER,                                                         00521300
      I BIT(16);                                                                00521400
                                                                                00521500
   CLOCK = MONITOR(18);                                                         00521600
   T = TIME;                                                                    00521700
   OUTPUT(1) = '1';                                                             00521800
   CALL PRINT_DATE_AND_TIME('   HAL/S COMPILER PHASE 3   --   VERSION OF ',     00521900
      DATE_OF_GENERATION,TIME_OF_GENERATION);                                   00522000
   OUTPUT = X1;                                                                 00522100
   CALL PRINT_DATE_AND_TIME('HAL/S PHASE 3 ENTERED ',DATE,T);                   00522200
   OUTPUT = X1;                                                                 00522300
   CALL INITIALIZE;                                                             00522400
   RECORD_CONSTANT(RVL_SRN,RECORD_ALLOC(ADVISE)-1,1);        /*CR13211*/
   CALL BUILD_SDF;                                                              00522500
   CLOCK(2) = MONITOR(18);                                                      00522600
   CALL OUTPUT_SDF;                                                             00522700
   CLOCK(3) = MONITOR(18);                                                      00522800
   CALL PRINTSUMMARY;                                                           00522900
   RECORD_FREE(SORTING);                                                        00523000
   RECORD_FREE(PGAREA);                                                         00523002
   IF NOT_DOWNGRADED THEN RETURN "8";                    /* CR13273 */
   RECORD_FREE(RVL_SRN);                               /*CR13211*/
   IF HEX_DUMP_FLAG|SDF_SUMMARY THEN CALL RECORD_LINK;                          00523004
   ELSE RETURN COMMON_RETURN_CODE;                                              00523025
NO_CORE:                                                                        00523100
   OUTPUT = '*** NOT ENOUGH CORE AVAILABLE TO GENERATE SDF ***';                00523200
   RETURN 20;                                                                   00523300
NO_PAGES:                                                                       00523400
   IF BOMB_FLAG THEN CALL EXIT;                                                 00523500
   OUTPUT = '*** SDF GENERATION ABANDONED -- PAGING AREA DEPLETED ***';         00523600
   RETURN 20;                                                                   00523700
PHASE3_ERROR:                                                                   00523800
   IF BOMB_FLAG THEN CALL EXIT;                                                 00523900
   BOMB_FLAG = TRUE;                                                            00524000
   OUTPUT = X1;                                                                 00524100
   DO I = 0 TO LAST_PAGE;                                                       00524200
      CALL PAGE_DUMP(I);                                                        00524300
   END;                                                                         00524400
   OUTPUT(1) = '1';                                                             00524500
   DO I = 0 TO ACTUAL_SYMBOLS + 1;                                              00524600
      TS = FORMAT(SYT_SORT1(I),4);                                              00524700
      TS(1) = FORMAT(SYT_SORT2(I),4);                                           00524800
      TS(2) = FORMAT(SYT_SORT3(I),4);                                           00524900
      TS(3) = FORMAT(SYT_SORT4(I),4);                                           00525000
      TS(4) = FORMAT(DEL_TAB(I),4);                                             00525100
      TS(5) = FORMAT(I,4);                                                      00525200
      TS(6) = FORMAT(SYT_SORT5(I),4);                                           00525300
      OUTPUT = TS(5)||X4||TS||X4||TS(1)||X4||TS(2)||X4||TS(3)||X4||TS(6)||      00525400
         X4||TS(4);                                                             00525500
   END;                                                                         00525600
   OUTPUT(1) = '1';                                                             00525700
   DO I = 0 TO K#PROCS + 1;                                                     00525800
      TS = FORMAT(I,4);                                                         00525900
      TS(1) = FORMAT(PROC_TAB1(I),4);                                           00526000
      TS(2) = FORMAT(PROC_TAB2(I),4);                                           00526100
      TS(3) = FORMAT(PROC_TAB3(I),4);                                           00526200
      TS(4) = HEX8(PROC_TAB4(I));                                               00526300
      TS(5) = FORMAT(PROC_TAB5(I),4);                                           00526400
      TS(6) = FORMAT(PROC_TAB6(I),4);                                           00526500
      TS(7) = FORMAT(PROC_TAB7(I),4);                                           00526600
      TS(8) = FORMAT(PROC_TAB8(I),4);                                           00526700
      TS(9) = FORMAT(PROC_TAB9(I),4);                                           00526800
      OUTPUT = TS||X2||TS(1)||X2||TS(2)||X2||TS(3)||X2||TS(4)||                 00526900
         X2||TS(5)||X2||TS(6)||X2||TS(7)||X2||TS(8)||X4||TS(9);                 00527000
   END;                                                                         00527100
   OUTPUT(1) = '1';                                                             00527200
   DO I = 0 TO LAST_PAGE;                                                       00527300
      TS = FORMAT(I,4);                                                         00527400
      TS(1) = FORMAT(PAD_PAGE(I),4);                                            00527500
      TS(2) = HEX8(PAD_ADDR(I));                                                00527600
      TS(3) = HEX(PAD_DISP(I),4);                                               00527700
      TS(4) = FORMAT(PAD_CNT(I),4);                                             00527800
      OUTPUT = TS||X4||TS(1)||X4||TS(2)||X4||TS(3)||X4||TS(4);                  00527900
   END;                                                                         00528000
   OUTPUT(1) = '1';                                                             00528100
   OUTPUT = LAST_PAGE;                                                          00528200
   OUTPUT = MAX_PAGE;                                                           00528300
   OUTPUT = HEX8(LOC_PTR);                                                      00528400
   OUTPUT = HEX8(LOC_ADDR);                                                     00528500
   OUTPUT = READ_CNT;                                                           00528600
   OUTPUT = WRITE_CNT;                                                          00528700
   OUTPUT = LOC_CNT;                                                            00528800
   OUTPUT = RESV_CNT;                                                           00528900
   OUTPUT = LAST_LREC;                                                          00529000
   OUTPUT = #SYMBOLS;                                                           00529100
   OUTPUT = ACTUAL_SYMBOLS;                                                     00529200
   OUTPUT = #DEL_SYMBOLS;                                                       00529300
   OUTPUT = #DEL_TPLS;                                                          00529400
   OUTPUT = #STMTS;                                                             00529500
   OUTPUT = #EXTERNALS;                                                         00529600
   OUTPUT = K#PROCS;                                                            00529700
   OUTPUT = #PROCS;                                                             00529800
   OUTPUT = NEW_NDX;                                                            00529900
   OUTPUT = OLD_NDX;                                                            00530000
   CALL EMIT_KEY_SDF_INFO;                                                      00530100
   CALL PRINTSUMMARY;                                                           00530400
   IF DEBUG THEN CALL EXIT;                                                     00530500
COMMON_ERROR:                                                                   00530600
   OUTPUT = X1;                                                                 00530700
   OUTPUT = '*** SDF GENERATION ABANDONED -- PHASE 3 INTERNAL ERROR ***';       00530800
   IF OPTIONS_CODE THEN CALL EXIT;                                              00530900
   ELSE RETURN 20;                                                              00530910
   EOF EOF EOF EOF EOF EOF EOF EOF EOF                                          00531000
