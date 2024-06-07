 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ##DRIVER.xpl
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
 /* 01/21/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM COMPILER            */
 /* 03/07/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER SOURCE CODE           */
 /* 10/29/93 TEV  26V0/ DR108630 0C4 ABEND OCCURS ON ILLEGAL DOWNGRADE      */
 /*               10V0                                                      */
 /*                                                                         */
 /* 04/03/00 DCP  30V0/ CR13273  PRODUCE SDF MEMBER WHEN OBJECT MODULE      */
 /*               15V0           CREATED                                    */
 /*                                                                         */
 /* 02/14/01 TKN  31V0/ DR111353 DOWNGRADE SUMMARY NOT PRINTED IN LISTING   */
 /*               16V0                                                      */
 /***************************************************************************/
 /***************************************************************************/
 /* EDIT #001     28 FEBRUARY 1977     VERSION 1.0  */                          00100000
                                                                                00100100
 /*  $Z MAKES THE CODE GO ON ERRORS  */                                         00100200
 /* $HH A L / S   S Y S T E M   --    P H A S E   1.3    --   I N T E R M E T   00100300
R I C S ,   I N C .   */                                                        00100400
                                                                                00100500
 /* AREA FOR ZAPS */                                                            00100600
                                                                                00100700
                                                                                00100900
 /* GLOBAL FLAGS */                                                             00100901
                                                                                00100902
   DECLARE FORMATTED_DUMP BIT(8), DONT_LINK BIT(8),                             00100903
      VMEM_DUMP BIT(8),INITIALIZING BIT(8),                                     00100904
      PROC_TRACE BIT(8), WALK_TRACE BIT(8),                                     00100905
      HALMAT_DUMP BIT(8),                                                       00100915
      HMAT_OPT BIT(1),                                                          00100925
      NAME_TERM_TRACE BIT(8);                                                   00100935
                                                                                00100945
 /* USEFUL LITERALLYS */                                                        00101000
                                                                                00101100
   DECLARE TRUE LITERALLY '1',                                                  00101200
      FALSE LITERALLY '0',                                                      00101300
      FOREVER LITERALLY 'WHILE TRUE';                                           00101600
                                                                                00101700
 /*  SYMBOL TABLE DEPENDENT DECLARATIONS  */                                    00101800
                                                                                00101900
   /%INCLUDE COMMON %/                                                          00102010
                                                                                00102200
      DECLARE        TOGGLE         LITERALLY 'COMM(6)',                        00105000
      OPTIONS_CODE   LITERALLY 'COMM(7)',                                       00105100
      ACTUAL_SYMBOLS LITERALLY 'COMM(10)',                                      00105400
      STMT_DATA_HEAD LITERALLY 'COMM(16)',                                      00106000
      TOTAL_HMAT_BYTES LITERALLY 'COMM(31)';                                    00106310
                                                                                00106600
   DECLARE       VAR_CLASS     BIT(16)  INITIAL (1),                            00106700
      FUNC_CLASS    BIT(16)  INITIAL (3),                                       00106900
      ASSIGN_FLAG   FIXED  INITIAL ("00000020"),                                00108000
      INPUT_FLAG    FIXED  INITIAL ("00000400"),                                00108300
      ENDSCOPE_FLAG FIXED  INITIAL ("00004000"),                                00108700
      EVIL_FLAGS    FIXED  INITIAL ("80200000"),                                00109300
      NAME_FLAG     FIXED  INITIAL ("10000000"),                                00109900
      MISC_NAME_FLAG FIXED INITIAL ("40000000"),                                00110000
      MATRIX        BIT(16)  INITIAL(3),                                        00110200
      VECTOR        BIT(16)  INITIAL(4),                                        00110300
      STRUCTURE     BIT(16)  INITIAL(10),                                       00110400
      TEMPL_NAME    BIT(16)  INITIAL(62),                                       00110401
      IND_CALL_LAB  BIT(16)  INITIAL ("45"),                                    00110800
      PROC_LABEL    BIT(16)  INITIAL ("47"),                                    00110900
      EQUATE_LABEL  BIT(16)  INITIAL ("4B");                                    00111300
                                                                                00111400
   DECLARE MAX_SEVERITY BIT(16) INITIAL(0);                                     00111401
   DECLARE SEVERITY BIT(16);                                                    00111402
                                                                                00111403
 /* INCLUDE NILL AND XREC_WORD $%COMDEC19 */                                    00111410
 /* REPLACE MACROS USED IN HALMAT SAVING ROUTINES */                            00111420
   DECLARE INIT_SMRK_LINK LITERALLY '(ADDR(SMRK_LIST))',                        00111430
      SMRK_NODE_SZ(2) LITERALLY '(4*(%2%-%1%+3+INITIAL_CASE))',                 00111440
      VMEM_LIM LITERALLY '((VMEM_PAGE_SIZE/4)-3-INITIAL_CASE)',                 00111450
      SAVE_OP(1) LITERALLY '(OPR(%1%)|^(POPCODE(%1%)=EDCL|POPCODE(%1%)=NOP))',  00111460
      VAC_OPERAND(1) LITERALLY '(OPR(%1%) & (TYPE_BITS(%1%)=VAC))';             00111470
                                                                                00111480
 /* GLOBAL VARS FOR HALMAT LIST */                                              00111490
   DECLARE (START_NODE,END_NODE,STMT#,OLD_STMT#) BIT(16),                       00111500
      SMRK_LINK FIXED,                                                          00111510
      #CELLS BIT(16) INITIAL(0),                                                00111520
      VAC_START BIT(16),                                                        00111530
      FINAL_OP BIT(16) INITIAL(0),                                              00111540
      INITIAL_CASE BIT(1) INITIAL(TRUE),                                        00111550
      SMRK_LIST FIXED INITIAL(NILL),                                            00111560
      OLD_SMRK_NODE FIXED INITIAL(NILL);                                        00111570
                                                                                00111580
 /* DECLARATIONS FOR HALMAT DECODING */                                         00111600
                                                                                00111700
   DECLARE (BLOCK#,CURCBLK) BIT(16), CODEFILE BIT(16) INITIAL(1);               00111701
                                                                                00111800
 /*  OPERAND TYPES */                                                           00111900
                                                                                00112000
   DECLARE  SYT     BIT(16) INITIAL(1),                                         00112100
      INL     BIT(16) INITIAL(2),                                               00112200
      VAC     BIT(16) INITIAL(3),                                               00112300
      XPT     BIT(16) INITIAL(4),                                               00112400
      LIT     BIT(16) INITIAL(5),                                               00112500
      IMD     BIT(16) INITIAL(6);                                               00112600
                                                                                00112700
 /* HALMAT OPCODES */                                                           00112800
                                                                                00112900
   DECLARE  NOP   BIT(16) INITIAL("000"),                                       00113000
      EXTN  BIT(16) INITIAL("001"),                                             00113010
      XREC    BIT(16) INITIAL("002"),                                           00113100
      IMRK    BIT(16) INITIAL("003"),                                           00113200
      SMRK    BIT(16) INITIAL("004"),                                           00113300
      PXRC    BIT(16) INITIAL("005"),                                           00113301
      LBL     BIT(16) INITIAL("008"),                                           00113326
      BRA     BIT(16) INITIAL("009"),                                           00113351
      FBRA    BIT(16) INITIAL("00A"),                                           00113400
      DCAS    BIT(16) INITIAL("00B"),                                           00113500
      CLBL    BIT(16) INITIAL("00D"),                                           00113501
      DFOR    BIT(16) INITIAL("010"),                                           00113600
      CFOR    BIT(16) INITIAL("012"),                                           00113700
      AFOR    BIT(16) INITIAL("015"),                                           00113800
      CTST    BIT(16) INITIAL("016"),                                           00113900
      ADLP    BIT(16) INITIAL("017"),                                           00114000
      DLPE    BIT(16) INITIAL("018"),                                           00114100
      DSUB    BIT(16) INITIAL("019"),                                           00114200
      IDLP    BIT(16) INITIAL("01A"),                                           00114300
      TSUB    BIT(16) INITIAL("01B"),                                           00114400
      PCAL    BIT(16) INITIAL("01D"),                                           00114500
      FCAL    BIT(16) INITIAL("01E"),                                           00114600
      READ    BIT(16) INITIAL("01F"),                                           00114700
      RDAL    BIT(16) INITIAL("020"),                                           00114800
      WRIT    BIT(16) INITIAL("021"),                                           00114900
      XFIL    BIT(16) INITIAL("022"),                                           00114910
      XXST    BIT(16) INITIAL("025"),                                           00115000
      XXND    BIT(16) INITIAL("026"),                                           00115100
      XXAR    BIT(16) INITIAL("027"),                                           00115200
      EDCL    BIT(16) INITIAL("031"),                                           00115300
      RTRN    BIT(16) INITIAL("032"),                                           00115400
      TDCL    BIT(16) INITIAL("033"),                                           00115500
      WAIT    BIT(16) INITIAL("034"),                                           00115600
      SCHD    BIT(16) INITIAL("039"),                                           00115700
      ERON    BIT(16) INITIAL("03C"),                                           00115800
      MSHP    BIT(16) INITIAL("040"),                                           00115900
      ISHP    BIT(16) INITIAL("043"),                                           00116000
      SFST    BIT(16) INITIAL("045"),                                           00116100
      SFAR    BIT(16) INITIAL("047"),                                           00116200
      LFNC    BIT(16) INITIAL("04B"),                                           00116300
      TASN    BIT(16) INITIAL("04F"),                                           00116400
      IDEF    BIT(16) INITIAL("051"),                                           00116500
      NASN    BIT(16) INITIAL("057"),                                           00116600
      PMAR    BIT(16) INITIAL("05A"),                                           00116601
      PMIN    BIT(16) INITIAL("05B"),                                           00116700
      STRI    BIT(16) INITIAL("801"),                                           00116800
      SLRI    BIT(16) INITIAL("802"),                                           00116900
      ELRI    BIT(16) INITIAL("803"),                                           00117000
      ETRI    BIT(16) INITIAL("804"),                                           00117100
      TINT    BIT(16) INITIAL("8E2"),                                           00117300
      EINT    BIT(16) INITIAL("8E3");                                           00117400
                                                                                00117500
   DECLARE (OPCODE,CLASS,SUBCODE,NUMOP,CTR) BIT(16);                            00117600
                                                                                00117700
 /* CLASS 0 TABLE FOR PROCESS_HALMAT */                                         00117800
                                                                                00117900
                                                                                00118000
   DECLARE CLASS0(96) BIT(8) INITIAL(                                           00118100
                                                                                00118200
      0,    /* 0 = NOP*/                                                        00118300
      3,    /* 1 = EXTN*/                                                       00118400
      14,   /* 2 = XREC*/                                                       00118500
      15,   /* 3 = IMRK*/                                                       00118600
      15,   /* 4 = SMRK*/                                                       00118700
      0,    /* 5 = PXRC*/                                                       00118800
      0,                                                                        00118900
      0,    /* 7 = IFHD*/                                                       00119000
      0,    /* 8 = LBL */                                                       00119100
      0,    /* 9 = BRA */                                                       00119200
      0,    /* A = FBRA*/                                                       00119300
      0,    /* B = DCAS*/                                                       00119400
      12,   /* C = ECAS*/                                                       00119500
      0,    /* D = CLBL*/                                                       00119600
      0,    /* E = DTST*/                                                       00119700
      12,   /* F = ETST*/                                                       00119800
      13,   /* 10 = DFOR*/                                                      00119900
      12,   /* 11 = EFOR*/                                                      00120000
      0,    /* 12 = CFOR*/                                                      00120100
      12,   /* 13 = DSMP*/                                                      00120200
      12,   /* 14 = ESMP*/                                                      00120300
      0,    /* 15 = AFOR*/                                                      00120400
      0,    /* 16 = CTST*/                                                      00120500
      0,    /* 17 = ADLP*/                                                      00120600
      0,    /* 18 = DLPE*/                                                      00120700
      4,    /* 19 = DSUB*/                                                      00120800
      0,    /* 1A = IDLP*/                                                      00120900
      2,    /* 1B = TSUB*/                                                      00121000
      0,                                                                        00121100
      8,    /* 1D = PCAL*/                                                      00121200
      8,    /* 1E = FCAL*/                                                      00121300
      9,    /* 1F = READ*/                                                      00121400
      9,    /* 20 = RDAL*/                                                      00121500
      9,    /* 21 = WRIT*/                                                      00121600
      0,0,0,                                                                    00121700
      7,    /* 25 = XXST*/                                                      00121800
      0,    /* 26 = XXND*/                                                      00121900
      0,    /* 27 = XXAR*/                                                      00122000
      0,0,                                                                      00122100
      1,    /* 2A - 2F BLOCK OPENINGS*/                                         00122200
      1,                                                                        00122300
      1,                                                                        00122400
      1,                                                                        00122500
      1,                                                                        00122600
      1,                                                                        00122700
      12,   /* 30 = CLOS*/                                                      00122800
      0,    /* 31 = EDCL*/                                                      00122900
      0,    /* 32 = RTRN*/                                                      00123000
      0,    /* 33 = TDCL*/                                                      00123100
      0,    /* 34 = WAIT*/                                                      00123200
      0,    /* 35 = SGNL*/                                                      00123300
      0,    /* 36 = CANC*/                                                      00123400
      0,    /* 37 = TERM*/                                                      00123500
      0,    /* 38 = PRIO*/                                                      00123600
      0,    /* 39 = SCHD*/                                                      00123700
      0,0,0,                                                                    00123800
      12,      /* 3D = ERSE*/                                                   00123900
      0,0,                                                                      00124000
      6,    /* 40 = MSHP*/                                                      00124100
      6,    /* 41 = VSHP*/                                                      00124200
      6,    /* 42 = SSHP*/                                                      00124300
      6,    /* 43 = ISHP*/                                                      00124400
      0,                                                                        00124500
      5,    /* 45 = SFST*/                                                      00124600
      0,    /* 46 = SFND*/                                                      00124700
      0,    /* 47 = SFAR*/                                                      00124800
      0,0,                                                                      00124900
      0,    /* 4A = BFNC*/                                                      00125000
      6,    /* 4B = LFNC*/                                                      00125100
      0,                                                                        00125200
      0,    /* 4D = TNEQ*/                                                      00125300
      0,    /* 4E = TEQU*/                                                      00125400
      0,    /* 4F = TASN*/                                                      00125500
      0,                                                                        00125600
      1,    /* 51 = IDEF*/                                                      00125700
      12,   /* 52 = ICLS*/                                                      00125800
      0,0,                                                                      00125900
      0,    /* 55 = NNEQ*/                                                      00126000
      0,    /* 56 = NEQU*/                                                      00126100
      0,    /* 57 = NASN*/                                                      00126200
      0,                                                                        00126300
      10,   /* 59 = PMHD*/                                                      00126400
      0,    /* 5A = PMAR*/                                                      00126500
      11);  /* 5B = PMIN*/                                                      00126600
                                                                                00126700
                                                                                00126800
 /* HALMAT ARRAYS */                                                            00126900
                                                                                00127000
   DECLARE HALMAT_BLOCK_SIZE LITERALLY '1800',                                  00127100
      (OPR,HALMAT_PTR) (HALMAT_BLOCK_SIZE) FIXED;                               00127200
                                                                                00127300
 /* DECLARES FOR TEMPLATE PROCESSNG FOR NAME TERMINALS */                       00127301
                                                                                00127302
   DECLARE (INIT_LIST_HEAD,TERM_LIST_HEAD,SAVE_ADDR) FIXED,                     00127303
      SINGLE_COPY FIXED INITIAL(1),                                             00127304
      LOOP_START_OP FIXED INITIAL("00010000"),                                  00127305
      LOOP_END_OP FIXED INITIAL("00020000"),                                    00127306
      END_OF_LIST_OP FIXED INITIAL("00030000"),                                 00127307
      (INIT_WORD_START,STRUCT_REF,STRUCT_TEMPL,STRUCT_COPY#) BIT(16),           00127308
      (TEMPL_WIDTH,TEMPL_INX,KIN,STRUCT_COPIES,MAJ_STRUCT) BIT(16),             00127309
      NAME_INITIAL BIT(8) INITIAL(7), IN_IDLP BIT(8),                           00127310
      TEMPL_LIST(20) BIT(16);                                                   00127311
                                                                                00127312
                                                                                00127313
 /* VARIOUS STACKS FOR BUILDING VMEM CELLS */                                   00127314
                                                                                00127315
   DECLARE (VAR_INX,PTR_INX,WORD_INX) BIT(16),                                  00127316
      EXP_VARS(400) BIT(16),                                                    00127317
      EXP_PTRS(400) FIXED,                                                      00127318
      WORD_STACK_SIZE LITERALLY '500',                                          00127319
      WORD_STACK(WORD_STACK_SIZE) FIXED;                                        00127350
                                                                                00127351
                                                                                00127352
   DECLARE X1 CHARACTER INITIAL(' '),                                           00127353
      X3 CHARACTER INITIAL('   '),                                              00127354
      X4 CHARACTER INITIAL('    '),                                             00127355
      X10 CHARACTER INITIAL('          '),                                      00127356
      X13 CHARACTER INITIAL('             '),                                   00127357
      X70 CHARACTER INITIAL(                                                    00127358
      '                                                                      ');00127359
                                                                                00127360
                                                                                00127361
 /*MISCELLANEOUS */                                                             00127362
DECLARE (CELLSIZE,LEVEL,NEST_LEVEL,DFOR_LOC,DSUB_LOC,EXTN_LOC,TSUB_LOC) BIT(16),00127363
      LINELENGTH LITERALLY '131',                                               00127364
      MAXLINES LITERALLY '20', S(MAXLINES) CHARACTER, MSG(5) CHARACTER,         00127365
      ERROR_COUNT BIT(16), STMT_DATA_CELL FIXED,                                00127366
      (BOMB_OUT,NO_CORE) LABEL;                                                 00127367
                                                                                00127368
                                                                                00127369
   DECLARE VPTR_INX BIT(16), SYT_VPTRS BIT(16) INITIAL(2);                      00127370
                                                                                00127400
                                                                                00127500
   DECLARE  SYT_NAME(1) LITERALLY 'SYM_TAB(%1%).SYM_NAME',                      00127501
      SYT_DIMS(1) LITERALLY 'SYM_TAB(%1%).SYM_LENGTH',                          00127506
      SYT_ARRAY(1) LITERALLY 'SYM_TAB(%1%).SYM_ARRAY',                          00127507
      SYT_PTR(1) LITERALLY 'SYM_TAB(%1%).SYM_PTR',                              00127508
      SYT_LINK1(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK1',                          00127509
      SYT_LINK2(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK2',                          00127510
      SYT_CLASS(1) LITERALLY 'SYM_TAB(%1%).SYM_CLASS',                          00127511
      SYT_FLAGS(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS',                          00127512
      SYT_LOCK#(1) LITERALLY 'SYM_TAB(%1%).SYM_LOCK#',                          00127513
      SYT_TYPE(1) LITERALLY 'SYM_TAB(%1%).SYM_TYPE',                            00127514
      LIT1(1) LITERALLY 'LIT_PG.LITERAL1(%1%)',                                 00127518
      LIT2(1) LITERALLY 'LIT_PG.LITERAL2(%1%)',                                 00127519
      LIT3(1) LITERALLY 'LIT_PG.LITERAL3(%1%)',                                 00127520
      DW(1) LITERALLY 'FOR_DW(%1%).CONST_DW';                                   00127522
   DECLARE SYT_NUM(1) LITERALLY 'SYM_ADD(%1%).SYM_NUM',                         00127523
      SYT_VPTR(1) LITERALLY 'SYM_ADD(%1%).SYM_VPTR';                            00127524
                                                                                00127600
   DECLARE MAX_NAME_INITIALS LITERALLY '400';                                   00127610
 /* SINCE THERE IS NO PROVISION FOR THE VARIABLE PART OF AN EXPRESSION          00127620
    VARIABLE NODE TO EXTEND ACROSS A PAGE, MAX_NAME_INITIALS IS THE MAXIMUM     00127630
    NUMBER OF INITIALIZED NAMES THAT MAY BE ACCOMODATED FOR A SINGLE DECLARE    00127640
    STATEMENT. */                                                               00127650
   DECLARE INIT_NAME_HOLDER BIT(16),                                            00127660
      NAME_INITIALS(MAX_NAME_INITIALS) BIT(16);                                 00127670
   DECLARE DWN_STMT(1) LITERALLY 'DOWN_INFO(%1%).DOWN_STMT';                    00127700
   DECLARE DWN_ERR(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_ERR';                     00127710
   DECLARE DWN_CLS(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_CLS';                     00127720
/********************* DR108630 - TEV - 10/29/93 *********************/
   DECLARE DWN_UNKN(1) LITERALLY 'DOWN_INFO(%1%).DOWN_UNKN';
/********************* END DR108630 **********************************/
   DECLARE DWN_VER(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_VER';                     00127730
 /*  INCLUDE COMMON ERROR DECLARATIONS:  $%CERRDECL */                          00127740
 /*  INCLUDE COMMON ROUTINES:            $%COMROUT  */                          00127750
 /**MERGE ERRORS       ERRORS                          */
 /**MERGE NEWHALMA     NEW_HALMAT_BLOCK                */
 /**MERGE FORMAT       FORMAT                          */
 /**MERGE MIN          MIN                             */
 /**MERGE HEX          HEX                             */
 /**MERGE POPNUM       POPNUM                          */
 /**MERGE POPCODE      POPCODE                         */
 /**MERGE POPVAL       POPVAL                          */
 /**MERGE POPTAG       POPTAG                          */
 /**MERGE TYPEBITS     TYPE_BITS                       */
 /**MERGE XBITS        X_BITS                          */
 /**MERGE DECODEPO     DECODEPOP                       */
 /**MERGE NEXTOP       NEXT_OP                         */
 /**MERGE LASTOP       LAST_OP                         */
 /**MERGE INDIRECT     INDIRECT                        */
 /**MERGE ADDSMRKN     ADD_SMRK_NODE                   */
 /**MERGE CREATEST     CREATE_STMT                     */
 /**MERGE KEEPPOIN     KEEP_POINTERS                   */
 /**MERGE DUMPSTMT     DUMP_STMT_HALMAT                */
 /**MERGE SETDEBUG     SET_DEBUG_TOGGLES               */
 /**MERGE PUTSYTVP     PUT_SYT_VPTR                    */
 /**MERGE GETSYTVP     GET_SYT_VPTR                    */
 /**MERGE GETLITER     GET_LITERAL                     */
 /**MERGE PROCESSD     PROCESS_DECL_SMRK               */
 /**MERGE ADDINITI     ADD_INITIALIZED_NAME_VAR        */
 /**MERGE SYMBOLTA     SYMBOL_TABLE_PREPASS            */
 /**MERGE INITIALI     INITIALIZE                      */
 /**MERGE LUMPARRA     LUMP_ARRAYSIZE                  */
 /**MERGE LUMPTERM     LUMP_TERMINALSIZE               */
 /**MERGE DESCENDE     DESCENDENT                      */
 /**MERGE SUCCESSO     SUCCESSOR                       */
 /**MERGE STRUCTUR     STRUCTURE_ADVANCE               */
 /**MERGE STRUCTU2     STRUCTURE_WALK                  */
 /**MERGE PROCESSE     PROCESS_EXTN                    */
 /**MERGE GETEXPVA     GET_EXP_VARS_CELL               */
 /**MERGE SEARCHEX     SEARCH_EXPRESSION               */
 /**MERGE INTEGERI     INTEGERIZABLE                   */
 /**MERGE INTEGERL     INTEGER_LIT                     */
 /**MERGE GETVARRE     GET_VAR_REF_CELL                */
 /**MERGE SCANINIT     SCAN_INITIAL_LIST               */
 /**MERGE GETPFINV     GET_P_F_INV_CELL                */
 /**MERGE TRAVERSE     TRAVERSE_INIT_LIST              */
 /**MERGE DOEACHTE     DO_EACH_TERMINAL                */
 /**MERGE GETNAMEI     GET_NAME_INITIALS               */
 /**MERGE GETSTMTV     GET_STMT_VARS                   */
 /**MERGE PROCESSH     PROCESS_HALMAT                  */
 /**MERGE FLUSH        FLUSH                           */
 /**MERGE STACKPTR     STACK_PTR                       */
 /**MERGE FORMATFO     FORMAT_FORM_PARM_CELL           */
 /**MERGE FORMATVA     FORMAT_VAR_REF_CELL             */
 /**MERGE FORMATEX     FORMAT_EXP_VARS_CELL            */
 /**MERGE FORMATPF     FORMAT_PF_INV_CELL              */
 /**MERGE FORMATCE     FORMAT_CELL_TREE                */
 /**MERGE FORMATNA     FORMAT_NAME_TERM_CELLS          */
 /**MERGE FORMATSY     FORMAT_SYT_VPTRS                */
 /**MERGE PRINTSTM     PRINT_STMT_VARS                 */
 /**MERGE PAGEDUMP     PAGE_DUMP                       */
 /**MERGE DUMPALL      DUMP_ALL                        */
 /**MERGE SORTVPTR     SORT_VPTRS                      */
                                                                                00309025
MAIN_PROGRAM:                                                                   00309100
   CALL INITIALIZE;                                                             00309200
   CALL PROCESS_HALMAT;                                                         00309300
   CALL SORT_VPTRS;                                                             00309301
   IF (HALMAT_DUMP & HMAT_OPT) THEN CALL DUMP_STMT_HALMAT;                      00309311
   IF VMEM_DUMP THEN CALL DUMP_ALL(FORMATTED_DUMP);                             00309400
   IF DONT_LINK THEN RETURN 0;                                                  00309500
   ELSE DO;                                                                     00309600
      RECORD_SEAL(SYM_ADD);                                                     00309602
      CALL RECORD_LINK;                                                         00309604
   END;                                                                         00309606
BOMB_OUT:                                                                       00309700
   IF MAX_SEVERITY >= 2 THEN CALL DOWNGRADE_SUMMARY; /* CR13273 DR111353*/      00309607
   OUTPUT = '***  COMPILATION ABANDONED  ***';                                  00309800
   CALL DUMP_ALL(FORMATTED_DUMP);                                               00309801
   RETURN COMMON_RETURN_CODE;                                                   00309811
NO_CORE:
   OUTPUT = '***  COMPILATION ABANDONED -- INSUFFICIENT CORE  ***';             00309902
   CALL DUMP_ALL(FORMATTED_DUMP);                                               00309903
   RETURN 20;                                                                   00309905
   EOF EOF EOF EOF EOF EOF EOF                                                  00310000
