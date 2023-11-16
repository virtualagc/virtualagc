 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ##DRIVER.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    Note:       Inline comments beginning with "/*/" were created by the
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
 /* 01/21/91 JAC  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /*                                                                         */
 /* 02/19/91 RSJ  23V2  CR11109  REMOVED UNUSED VARIABLES AND REFORMAT      */
 /*                                                                         */
 /* 05/24/93 RAH  25V0  DR105709 ADDED STRINGS 'REPLACE' AND 'STRUCTURE'    */
 /*                9V0           TO CHARACTER ARRAY STMT_TYPES              */
 /*                                                                         */
 /* 03/02/01 DAS  31V0  CR13353 ADD SIZE OF BUILTIN FUNCTIONS XREF TABLE    */
 /*               16V0          INTO SDF                                    */
 /*                                                                         */
 /* 09/11/02 JAC  32V0  CR13570 CREATE NEW %MACRO TO PERFORM ZEROTH         */
 /*               17V0          ELEMENT CALCULATIONS                        */
 /*                                                                         */
 /***************************************************************************/
 /* EDIT #001     18 AUGUST 1977     VERSION 1.0  */                            00100000
                                                                                00100100
 /*  $Z MAKES THE CODE GO ON ERRORS  */                                         00100200
 /* $HH A L / S   S Y S T E M   --   S D F L I S T   --   I N T E R M E T R I   00100300
C S ,   I N C .   */                                                            00100400
                                                                                00100500
                                                                                00100900
 /*   LIMITING SDFLIST SIZES AND LENGTHS   */                                   00101000
                                                                                00101100
DECLARE  PAGE_SIZE LITERALLY '1680';       /* PHYSICAL BLOCK SIZE OF SDF PAGES*/00101200
                                                                                00101300
   DECLARE  MISC_VAL     LITERALLY '9';                                         00101400
                                                                                00101500
   DECLARE  TRUE LITERALLY '1',                                                 00101600
      FALSE LITERALLY '0';                                                      00101700
                                                                                00101800
   DECLARE  TMP FIXED;                                                          00101900
                                                                                00102000
 /* USEFUL CHARACTER LITERALS */                                                00102100
                                                                                00102200
   DECLARE  COLON          CHARACTER INITIAL (':'),                             00102300
      DOUBLE         CHARACTER INITIAL ('0'),                                   00102400
      HEXCODES       CHARACTER INITIAL ('0123456789ABCDEF'),                    00102500
      ASTS           CHARACTER INITIAL ('******************  '),                00102600
      SDFLIST_ERR    CHARACTER INITIAL ('*** SDFLIST INTERNAL ERROR: '),        00102700
      X1             CHARACTER INITIAL (' '),                                   00102800
      X2             CHARACTER INITIAL ('  '),                                  00102900
      X3             CHARACTER INITIAL ('   '),                                 00103000
      X4             CHARACTER INITIAL ('    '),                                00103100
      X5             CHARACTER INITIAL ('     '),                               00103200
      X6             CHARACTER INITIAL ('      '),                              00103300
      X7             CHARACTER INITIAL ('       '),                             00103400
      X10            CHARACTER INITIAL ('          '),                          00103500
      X15            CHARACTER INITIAL ('               '),                     00103600
      X20            CHARACTER INITIAL ('                    '),                00103700
      X28            CHARACTER INITIAL ('                            '),        00103800
      X30            CHARACTER INITIAL                                          00103900
      ('                              '),                                       00104000
      X52            CHARACTER INITIAL                                          00104100
      ('                                                    '),                 00104200
      X60            CHARACTER INITIAL                                          00104210
      ('                                                            '),         00104220
      X72            CHARACTER INITIAL                                          00104300
   ('                                                                        ');00104400
                                                                                00104500
 /* DECLARES FOR SPECIAL TABLST LOGIC */                                        00104600
                                                                                00104700
   DECLARE STMT_TYPES(36) CHARACTER INITIAL(                                    00104800
      'NULL', 'EXIT/REPEAT/GOTO', 'CALL', 'READ/READALL/WRITE',                 00104900
      'ASSIGN', 'IF', 'CLOSE', 'RETURN', 'END', 'SCHEDULE',                     00105000
      'CANCEL/TERMINATE', 'WAIT', 'UPDATE PRIORITY',                            00105100
      'SET/SIGNAL/RESET', 'SEND ERROR', 'ON ERROR', 'FILE',                     00105200
      'DO', 'DO WHILE/DO UNTIL', 'DO FOR', 'DO CASE',                           00105300
/*********** DR105709, RAH, 4/23/92 ***********************************/
      'DECLARE','BLOCK','EQUATE EXTRN','TEMPORARY',                             00105400
      'REPLACE','STRUCTURE','','','','','%NAMEBIAS',         /*CR13570*/
/*********** END DR105709 *********************************************/
      '%SVC','%NAMECOPY','%COPY','%SVCI','%NAMEADD');                           00105500
                                                                                00105600
   DECLARE STMT_FLAGS(4) CHARACTER INITIAL('', 'ELSE ', 'THEN ', '',            00105700
      'ON_ERROR_OBJ: ');                                                        00105800
                                                                                00105900
   DECLARE SYMBOL_CLASSES(6) CHARACTER INITIAL(                                 00106000
      '', '  VARIABLE    ', '  LABEL       ',                                   00106100
      '  FUNCTION    ', '  TEMPLATE    ',                                       00106200
      '  TPL LBL     ', '  TPL FUNC LBL');                                      00106300
                                                                                00106400
   DECLARE SYMBOL_TYPES(17) CHARACTER INITIAL(                                  00106500
      '', '  BIT STRING', '  CHARACTER ',                                       00106600
      '  SP MATRIX ', '  SP VECTOR ', '  SP SCALAR ',                           00106700
      '  SP INTEGER', '', '', '  BIT STRING',                                   00106800
      '  BIT STRING', '  DP MATRIX ', '  DP VECTOR ',                           00106900
      '  DP SCALAR ', '  DP INTEGER', '',                                       00107000
      '  STRUCTURE ', '  EVENT     ');                                          00107100
                                                                                00107200
   DECLARE PROC_TYPES(9) CHARACTER INITIAL(                                     00107300
      '', '  PROGRAM   ', '  PROCEDURE ',                                       00107400
      '  FUNCTION  ', '  COMPOOL   ', '  TASK      ',                           00107500
      '  UPDATE    ', '  STATEMENT ', '  EQUATE    ', '  REPLACE   ');          00107600
                                                                                00107700
 /* COMMON DEFINITTONS FOR USE WHEN PART OF THE HAL/S COMPILER */               00107800
                                                                                00107900
   /%INCLUDE COMMON %/                                                          00108000
                                                                                00110400
      DECLARE  OPTIONS_CODE LITERALLY 'COMM(7)',                                00110500
      SDF_NAM1 LITERALLY 'COMM(40)';                                            00110600
                                                                                00110701
 /* SDF GLOBAL PARAMETERS */                                                    00110900
                                                                                00111000
 DECLARE  LAST_PAGE BIT(16),                /* # OF LAST SDF PAGE             */00111100
      LOC_PTR FIXED,                    /* POINTER LAST LOCATED           */    00111200
      LOC_ADDR FIXED,                   /* CORE ADDRESS LAST LOCATED      */    00111300
      FIRST_STMT BIT(16),               /* NUMBER OF FIRST EXECUTABLE STMT*/    00111400
      LAST_STMT BIT(16),                /* NUMBER OF LAST STATEMENT       */    00111500
      STMT_NODES BIT(16),               /* # OF STATEMENT NODES PER PAGE  */    00111600
      STMT_NODE_SIZE BIT(16),           /* STMT NODE SIZE (4 OR 12 BYTES) */    00111900
      SYMB_NODE_SIZE LITERALLY '12',    /* SYMBOL NODE SIZE (12 BYTES)    */    00112000
      BLOCK_NODE_SIZE LITERALLY '12',   /* BLOCK NODE SIZE (12 BYTES)     */    00112100
      BASE_SYMB_PAGE BIT(16),           /* FIRST_SYMB_PTR (HI-ORDER HALF) */    00112200
      BASE_SYMB_OFFSET BIT(16),         /* FIRST_SYMB_PTR (LO-ORDER HALF) */    00112300
      BASE_STMT_PAGE BIT(16),           /* FIRST_STMT_PTR (HI-ORDER HALF) */    00112400
      BASE_STMT_OFFSET BIT(16),         /* FIRST_STMT_PTR (LO-ORDER HALF) */    00112500
      BASE_BLOCK_PAGE BIT(16),          /* FIRST_BLOCK_PTR (HI-ORDER HALF)*/    00112600
      BASE_BLOCK_OFFSET BIT(16),        /* FIRST_BLOCK_PTR (LO-ORDER HALF)*/    00112700
      #SYMBOLS BIT(16),                 /* TOTAL NUMBER OF SYMBOL NODES   */    00112800
      #STMTS BIT(16),                   /* TOTAL NUMBER OF STMT NODES     */    00112900
      #EXECS BIT(16),                   /* TOTAL NUMBER OF EXECUTABLE STMTS*/   00113000
      #EXTERNALS BIT(16),               /* NUMBER OF INCLUDED COMPOOLS    */    00113100
      #PROCS BIT(16),                   /* NUMBER OF HAL BLOCKS           */    00113200
      #BIFUNCS BIT(16),         /* CR13353-NUMBER OF BUILTIN FUNCTIONS    */
      BASE_BI_PTR BIT(32),      /* CR13353-FUNC INDEX TABLE POINTER       */
      KEY_BLOCK BIT(16),                                                        00113300
      KEY_SYMB BIT(16),                                                         00113400
      COMPUNIT BIT(16),                                                         00113500
      EMITTED_CNT FIXED,                                                        00113600
      SDFPKG_LOCATES FIXED,                                                     00113700
      SDFPKG_READS FIXED,                                                       00113800
      SDFPKG_SLECTCNT FIXED,                                                    00113900
      SDFPKG_FCBAREA FIXED,                                                     00114000
      SDFPKG_PGAREA BIT(16),                                                    00114100
      SDFPKG_NUMGETM BIT(16),                                                   00114200
      #LABELS BIT(16),                  /* NUMBER OF LABELS              */     00114300
      #LHS BIT(16);                     /* NUMBER OF LEFT-HAND SIDES     */     00114400
                                                                                00114500
                                                                                00115100
 /* MODE INDICATION FLAGS */                                                    00115200
                                                                                00115300
DECLARE  SRN_FLAG BIT(1) INITIAL(0),       /* 1 --> SDF HAS SRNS (SDL CONFIG) */00115400
      ADDR_FLAG BIT(1) INITIAL(0),      /* 1 --> SDF HAS STMT ADDRESSES    */   00115500
      SDL_FLAG BIT(1) INITIAL(0),       /* 1 --> SDL OPERATION             */   00115600
      NEW_FLAG BIT(1) INITIAL(0),       /* 1 --> VERS 12 OR LATER SDF      */   00115700
      COMPOOL_FLAG BIT(1) INITIAL(0),   /* 1 --> SDF IS FOR A COMPOOL UNIT */   00115800
      HMAT_OPT BIT(1) INITIAL(0),   /* --> HALMAT IN SDF */                     00115810
      OVERFLOW_FLAG BIT(1) INITIAL(0),  /* 1 --> DIRECTORY OVERFLOW        */   00115900
      SRN_FLAG1 BIT(1) INITIAL(0),      /* 1 --> NON-MONOTONIC SRN(S)      */   00116000
      SRN_FLAG2 BIT(1) INITIAL(0),      /* 1 --> NON-UNIQUE SRN(S)         */   00116100
      NOTRACE_FLAG BIT(1) INITIAL(0),   /* 1 --> 360 HAL COMP HAS NO HOOKS */   00116200
      FC_FLAG BIT(1) INITIAL(0),        /* 1 --> FC SDF                    */   00116300
      FCDATA_FLAG BIT(1) INITIAL(0),                                            00116400
      STAND_ALONE BIT(1) INITIAL(0),    /* 1 --> SDFLIST IS BY ITSELF */        00116500
      TABDMP        BIT(1) INITIAL(0),  /* 1 --> HEX DUMP REQUESTED        */   00116600
      TABLST      BIT(1) INITIAL(0),    /* 1 --> SDF SUMMARY REQUESTED     */   00116700
      BRIEF BIT(1) INITIAL(0),          /* 1 --> SHORT SDF SUMMARY     */       00116800
      ALL BIT(1) INITIAL(0);            /* 1 --> PROCESS ALL SDFS   */          00116900
                                                                                00117000
 /* DECLARES FOR SDFPKG COMMUNICATION AREA */                                   00117100
                                                                                00117200
   DECLARE  COMM_TAB(29) FIXED;                                                 00117300
                                                                                00117400
   BASED    COMMTABL_BYTE BIT(8),                                               00117500
      COMMTABL_HALFWORD BIT(16),                                                00117600
      COMMTABL_FULLWORD FIXED;                                                  00117700
                                                                                00117800
   DECLARE  COMMTABL_ADDR FIXED;                                                00117900
                                                                                00118000
   DECLARE  APGAREA  LITERALLY 'COMMTABL_FULLWORD(0)',                          00118100
      AFCBAREA LITERALLY 'COMMTABL_FULLWORD(1)',                                00118200
      NPAGES   LITERALLY 'COMMTABL_HALFWORD(4)',                                00118300
      NBYTES   LITERALLY 'COMMTABL_HALFWORD(5)',                                00118400
      MISC     LITERALLY 'COMMTABL_HALFWORD(6)',                                00118500
      CRETURN  LITERALLY 'COMMTABL_HALFWORD(7)',                                00118600
      BLKNO    LITERALLY 'COMMTABL_HALFWORD(8)',                                00118700
      SYMBNO   LITERALLY 'COMMTABL_HALFWORD(9)',                                00118800
      STMTNO   LITERALLY 'COMMTABL_HALFWORD(10)',                               00118900
      BLKNLEN  LITERALLY 'COMMTABL_BYTE(22)',                                   00119000
      SYMBNLEN LITERALLY 'COMMTABL_BYTE(23)',                                   00119100
      PNTR     LITERALLY 'COMMTABL_FULLWORD(6)',                                00119200
      ADDRESS  LITERALLY 'COMMTABL_FULLWORD(7)',                                00119300
      SDFNAM   LITERALLY 'COMMTABL_ADDR+32',                                    00119400
      SREFNO   LITERALLY 'COMMTABL_ADDR+48',                                    00119600
      INCLCNT  LITERALLY 'COMMTABL_HALFWORD(27)',                               00119700
      BLKNAM   LITERALLY 'COMMTABL_ADDR+56',                                    00119800
      SYMBNAM  LITERALLY 'COMMTABL_ADDR+88';                                    00119900
                                                                                00120000
 /* DECLARES FOR SDFPKG INTERNAL DATA BUFFER (DATABUF) */                       00120100
                                                                                00120200
   BASED     DATABUF_BYTE BIT(8),                                               00120300
      DATABUF_HALFWORD BIT(16),                                                 00120400
      DATABUF_FULLWORD FIXED;                                                   00120500
                                                                                00120600
   DECLARE   LOCCNT    LITERALLY 'DATABUF_FULLWORD(0)',                         00120700
      NUMGETM   LITERALLY 'DATABUF_HALFWORD(18)',                               00121700
      NUMOFPGS  LITERALLY 'DATABUF_HALFWORD(19)',                               00121800
      TOTFCBLN  LITERALLY 'DATABUF_FULLWORD(13)',                               00122700
      READS     LITERALLY 'DATABUF_FULLWORD(15)',                               00122900
      SLECTCNT  LITERALLY 'DATABUF_FULLWORD(17)',                               00123100
      VERSION   LITERALLY 'DATABUF_HALFWORD(47)';                               00123300
                                                                                00123400
   DECLARE UNMOVEABLE LITERALLY '0';                                            00123401
   DECLARE DW(1) LITERALLY 'FOR_DW(%1%).CONST_DW';                              00123423
 /* MISCELLANEOUS GLOBAL DECLARES */                                            00123500
                                                                                00123600
   DECLARE  TITLE CHARACTER;     /* TITLE (TYPE II OPTION) */                   00123700
   DECLARE  SDF_NAME CHARACTER; /* NAME OF LAST SELECTED SDF */                 00123800
                                                                                00123900
 /* MISCELLANEOUS DECLARATIONS */                                               00124000
   DECLARE FOREVER LITERALLY 'WHILE 1',                                         00124100
      SPACE_1 LITERALLY 'OUTPUT = X1',                                          00124200
      DSPACE LITERALLY 'OUTPUT(1) = DOUBLE',                                    00124300
      PRINTLINE CHARACTER,                                                      00124400
      (BAIL_OUT,NO_CORE) LABEL,                                                 00124500
      CLOCK(2) FIXED;                                                           00124600
                                                                                00124610
 /* DECLARES FOR FORMATTING SDF CELL TREES */                                   00124620
   BASED  VMEM_B BIT(8), VMEM_H BIT(16), VMEM_F FIXED;                          00124630
   DECLARE (VN_INX,PTR_INX) BIT(16),                                            00124640
      ASIP_FLAG BIT(8),                                                         00124650
      LINELENGTH LITERALLY '131',                                               00124660
      MAXLINES LITERALLY '40',                                                  00124665
      S(MAXLINES) CHARACTER;                                                    00124680
   BASED VARNAME_REC RECORD DYNAMIC:   /* FOR SPACE MANAGEMENT */               00124682
         VAR CHARACTER,                                                         00124684
      END;                                                                      00124686
   BASED CELL_PTR_REC RECORD DYNAMIC:  /* FOR SPACE MANAGEMENT */               00124688
         C_PTR FIXED,                                                           00124690
      END;                                                                      00124692
   DECLARE VARNAME(1) LITERALLY 'VARNAME_REC.VAR(%1%)',                         00124694
      CELL_PTRS(1) LITERALLY 'CELL_PTR_REC.C_PTR(%1%)';                         00124696
                                                                                00124700
/*CR13353- BUILTIN FUNCTION NAME TABLE FOR PRINTOUT IN DUMPSDF */
   DECLARE BI# LITERALLY '63';
   DECLARE BI_NAME(BI#) CHARACTER INITIAL('', 'ABS', 'COS', 'DET', 'DIV', 'EXP',
      'LOG', 'MAX', 'MIN', 'MOD', 'ODD', 'SHL', 'SHR', 'SIN', 'SUM', 'TAN',
      'XOR', 'COSH', 'DATE', 'PRIO', 'PROD', 'SIGN', 'SINH', 'SIZE', 'SQRT',
      'TANH', 'TRIM', 'UNIT', 'ABVAL', 'FLOOR', 'INDEX', 'LJUST', 'RJUST',
      'ROUND', 'TRACE', 'ARCCOS', 'ARCSIN', 'ARCTAN', 'ERRGRP', 'ERRNUM',
      'LENGTH', 'MIDVAL', 'RANDOM', 'SIGNUM', 'ARCCOSH', 'ARCSINH',
      'ARCTANH', 'ARCTAN2', 'CEILING', 'INVERSE', 'NEXTIME', 'RANDOMG',
      'RUNTIME', 'TRUNCATE', 'CLOCKTIME', 'REMAINDER', 'TRANSPOSE',
      'BIT', 'SUBBIT', 'INTEGER', 'SCALAR', 'VECTOR', 'MATRIX', 'CHARACTER');

                                                                                00124710
 /* INCLUDE COMMON REL19 DECS $%COMDEC19 */                                     00124720
 /* INCLUDE VMEM DECLARES:  $%VMEM1  */                                         00124730
 /* AND:  $%VMEM2  */                                                           00124740
                                                                                00124750
 /**MERGE EMITOUTP     EMIT_OUTPUT                     */
 /**MERGE PAD          PAD                             */
 /**MERGE LEFTPAD      LEFT_PAD                        */
 /**MERGE FORMAT       FORMAT                          */
 /**MERGE HEX          HEX                             */
 /**MERGE HEX8         HEX8                            */
 /**MERGE HEX6         HEX6                            */
 /**MERGE CHARTIME     CHARTIME                        */
 /**MERGE CHARDATE     CHARDATE                        */
 /**MERGE PRINTTIM     PRINT_TIME                      */
 /**MERGE PRINTDAT     PRINT_DATE_AND_TIME             */
 /**MERGE MOVE         MOVE                            */
 /**MERGE ZERO256      ZERO_256                        */
 /**MERGE ZEROCORE     ZERO_CORE                       */
 /**MERGE STMTTOPT     STMT_TO_PTR                     */
 /**MERGE SYMBTOPT     SYMB_TO_PTR                     */
 /**MERGE BLOCKTOP     BLOCK_TO_PTR                    */
 /**MERGE SDFSELEC     SDF_SELECT                      */
 /**MERGE SDFPTRLO     SDF_PTR_LOCATE                  */
 /**MERGE SDFLOCAT     SDF_LOCATE                      */
 /**MERGE PAGEDUMP     PAGE_DUMP                       */
 /**MERGE BLOCKNAM     BLOCK_NAME                      */
 /**MERGE SYMBOLNA     SYMBOL_NAME                     */
 /**MERGE PTRTOBLO     PTR_TO_BLOCK                    */
 /**MERGE PRINTREP     PRINT_REPLACE_TEXT              */
 /**MERGE DUMPSDF      DUMP_SDF                        */
 /**MERGE INITIALI     INITIALIZE                      */
 /**MERGE SDFPROCE     SDF_PROCESSING                  */
 /**MERGE PRINTSUM     PRINTSUMMARY                    */
                                                                                00270000
 /*  START OF THE MAIN PROGRAM  */                                              00270100
MAIN_PROGRAM:                                                                   00270200
                                                                                00270300
   CLOCK = MONITOR(18);                                                         00270400
   CALL INITIALIZE;                                                             00270500
   CLOCK(1) = MONITOR(18);                                                      00270600
   CALL SDF_PROCESSING;                                                         00270700
   CLOCK(2) = MONITOR(18);                                                      00270800
   IF STAND_ALONE THEN CALL PRINTSUMMARY;                                       00270900
   RETURN COMMON_RETURN_CODE;                                                   00271000
NO_CORE:                                                                        00271100
   OUTPUT = X1;                                                                 00271200
   OUTPUT = '*** INSUFFICIENT CORE MEMORY -- INCREASE REGION SIZE ***';         00271300
BAIL_OUT:                                                                       00271400
   OUTPUT = X1;                                                                 00271500
   OUTPUT = 'S D F L I S T   P R O C E S S I N G   A B A N D O N E D';          00271600
   OUTPUT = X1;                                                                 00271700
   RETURN 16;                                                                   00271800
   EOF EOF EOF EOF EOF EOF EOF EOF EOF                                          00271900
