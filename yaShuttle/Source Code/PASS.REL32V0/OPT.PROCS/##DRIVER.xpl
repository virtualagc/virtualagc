 /*/
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   ##DRIVER.xpl
    Purpose:    This is a part of optimizer of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.4.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2022-12-08 RSB  Suffixed the filename with ".xpl".
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
 /* 03/15/91 DKB  23V2  CR11109  CLEANUP COMPILER SOURCE CODE               */
 /*                                                                         */
 /* 05/24/93 LWW  25V0  DR108607 MATRIX COMPARE BETWEEN DOUBLE AND          */
 /*                9V0           SINGLE PRECISION MATRICES FAIL.            */
 /*                                                                         */
 /* 10/29/93 TEV  26V0/ DR108630 0C4 ABEND OCCURS ON ILLEGAL DOWNGRADE      */
 /*               10V0                                                      */
 /*                                                                         */
 /* 02/10/95 DAS  27V0/ DR103787 WRONG VALUE LOADED FROM REGISTER FOR       */
 /*               11V0           A STRUCTURE NODE DEREFERENCE               */
 /*                                                                         */
 /* 07/13/98 JAC  29V0/ DR111306 INDEX OUT OF RANGE FOR A_PARITY AND ADD    */
 /*               14V0                                                      */
 /*                                                                         */
 /* 07/07/98 JAC  29V0/ DR109100 INDEX OUT OF RANGE FOR DIFF_PTR            */
 /*               14V0           AND DIFF_NODE                              */
 /*                                                                         */
 /* 03/19/98 JAC  29V0/ DR109092 INDEX OUT OF RANGE FOR HALMAT OPERAND      */
 /*               14V0           ARRAY                                      */
 /*                                                                         */
 /* 04/03/00 DCP  30V0/ CR13273  PRODUCE SDF MEMBER WHEN OBJECT MODULE      */
 /*               15V0           CREATED                                    */
 /*                                                                         */
 /* 07/19/99 DAS  30V0/ DR111333 BIX LOOP COMBINING CAUSES INCORRECT        */
 /*               15V0           OBJECT CODE                                */
 /*                                                                         */
 /* 06/03/99 JAC  30V0/ DR111313 BS122 ERROR FOR MULTIDIMENSIONAL           */
 /*               15V0           ASSIGNMENTS                                */
 /*                                                                         */
 /* 02/14/01 TKN  31V0/ DR111353 DOWNGRADE SUMMARY NOT PRINTED IN LISTING   */
 /*               16V0                                                      */
 /***************************************************************************/
 /* $Z MAKES THE CODE GO ON ERRORS */                                           00001000
 /* $HH A L / S   C O M P I L E R   --   O P T I M I Z E R*/                    00002000
 /* UPDATE U8     BEGIN LONG TERM OPTIMIZATION*/                                00003000
 /*    SUBSCRIPT COMMON EXPRESSIONS        */                                   00003010
 /* VECTOR MATRIX INLINE  */                                                    00003030
                                                                                00004000
 /*   LIMITING PHASE 2 SIZES AND LENGTHS   */                                   00005000
   DECLARE                                                                      00006000
      CALL_LEVEL# LITERALLY '20',        /* MAX FUNC NESTING DEPTH          */  00009000
      DOSIZE    LITERALLY '30',          /* MAX SIMPLE DO LEVEL             */  00014000
      MAX_STACK_LEVEL LITERALLY '32',  /* YOU GUESSED IT*/                      00014010
      BLOCK_END LITERALLY '1799',                                               00015000
      BLOCK_PLUS_1 LITERALLY '1800',                                            00016000
      DOUBLEBLOCK_SIZE LITERALLY '3599',  /* 2 HALMAT BLOCKS*/                  00017000
      LOOP_STACKSIZE LITERALLY '5',      /* SIZE OF STACK FOR LOOP COMBINING*/  00017010
      TEMPLATE_STACK_SIZE LITERALLY '2000';                                     00017020
                                                                                00019000
   DECLARE SINCOS FIXED INITIAL( "39 01 04A 8"),                                00020000
      TWIN# FIXED INITIAL  (" 2 00 000 0"),   /* # OF TWIN OPS*/                00021000
      SINOP BIT(16) INITIAL ("0F0D");       /* = "0F 'SIN'" */                  00022000
                                                                                00023000
   DECLARE CLOCK(2) FIXED;                                                      00024000
                                                                                00025000
   DECLARE CSE_TAB_SIZE LITERALLY '2500',                                       00026000
      CATALOG_ENTRY_SIZE LITERALLY '3',                                         00027000
      NODE_ENTRY_SIZE LITERALLY '3',                                            00028000
      MAX_NODE_SIZE LITERALLY '2000',                                           00029000
      SPACE_TAB_SIZE LITERALLY '5';                                             00030000
                                                                                00031000
   DECLARE TRUE LITERALLY '1',                                                  00032000
      FALSE LITERALLY '0',                                                      00033000
      OR   LITERALLY '|',                                                       00034000
      AND  LITERALLY '&',                                                       00035000
      NOT  LITERALLY '^',                                                       00036000
      FOREVER LITERALLY 'WHILE TRUE',                                           00036010
      FOR   LITERALLY '';                                                       00037000
                                                                                00037010
   DECLARE                                                                      00037020
      EVIL_FLAGS FIXED           INITIAL("0020 0000"),                          00037030
      SM_FLAGS FIXED             INITIAL("14C2 008C");                          00037040
                                                                                00037050
                                                                                00038000
   DECLARE ACROSS_BLOCK_TAG FIXED INITIAL("4");                                 00039000
                                                                                00040000
                                                                                00041000
   DECLARE PRTYEXP LITERALLY 'A_PARITY + (PARITY & (I+1)) & "1"';               00042000
                                                                                00043000
 /* PRIMARY CODE TABLES AND POINTERS */                                         00044000
   DECLARE       (OP1,OP2) BIT(16),                                             00045000
      (SUBCODE,OPCODE,CLASS,NUMOP,TAG1,TAG) BIT(16),                            00046000
      SUBCODE2 BIT(16),                                                         00047000
      (TAG2,TAG3)(2) BIT(16),                                                   00048000
      READCTR BIT(16),                                                          00049000
      SMRK_CTR BIT(16),                                                         00050000
      (CTR,RESET) BIT(16),                                                      00051000
      SIZE LITERALLY 'ROW',                                                     00052000
      DO_LIST(DOSIZE) BIT(16),                                                  00054000
      DO_INX BIT(16),                                                           00055000
      XREC_PTR BIT(16),                                                         00056000
                                                                                00057000
 /* DECLARATIONS FOR GROW_TREE */                                               00058000
      (BFNC_OK,NONCOMMUTATIVE,TRANSPARENT,LITCHANGE,BIT_TYPE) BIT(8),           00059000
      INDEX2_SIZE LITERALLY '600',          /*DR111306*/
      A_PARITY(INDEX2_SIZE) BIT(8),         /*DR111306*/                        00060000
      (D_N_INX,A_INX,N_INX,EON_PTR,LAST_SMRK) BIT(16),                          00061000
      INDEX_SIZE LITERALLY '360',                 /*DR109100*/
      (DIFF_NODE,DIFF_PTR) (INDEX_SIZE) BIT(16),  /*DR109100*/                  00062000
      NODE(MAX_NODE_SIZE) FIXED;                                                00063000
   DECLARE  NODE2(MAX_NODE_SIZE) BIT(16);                                       00064000
                                                                                00064010
   ARRAY TEMPLATE_STACK(TEMPLATE_STACK_SIZE) BIT(16);                           00064020
 /* STACK TO REMEMBER TEMPLATES ALREADY ENCOUNTERED IN TSUB'S*/                 00064030
                                                                                00064040
                                                                                00065000
 /* CSE TABLE */                                                                00066000
   DECLARE  CSE_TAB(CSE_TAB_SIZE) BIT(16);                                      00067000
   DECLARE ADD(INDEX2_SIZE) BIT(16);        /*DR111306*/                        00067500
   DECLARE  FREE_SPACE(SPACE_TAB_SIZE) BIT(16) INITIAL(CSE_TAB_SIZE),           00068000
      FREE_BLOCK_BEGIN(SPACE_TAB_SIZE) BIT(16) INITIAL(1),                      00069000
      LAST_SPACE_BLOCK BIT(16),                                                 00070000
      CSE_INX BIT(16),                                                          00071000
                                                                                00072000
 /* WORD FORMATS FOR CSE TABLES AND GROW_TREE */                                00073000
                                                                                00074000
                                                                                00075000
 /*                                   CONTROL TYPE PTR     */                   00076000
      LITERAL              FIXED INITIAL("2  E  0000"),       /* LAST IN SORT   00077000
                                                                 ORDER*/        00078000
      TERMINAL_VAC         FIXED INITIAL("0  3  0000"),                         00080000
      OUTER_TERMINAL_VAC   FIXED INITIAL("0  C  0000"),  /*POINTS TO VAC_PTR    00084000
                                                                      WORD*/    00085000
      VALUE_NO             FIXED INITIAL("0  B  0000"),                         00086000
      DUMMY_NODE           FIXED INITIAL("0  D  0000"),                         00087000
      END_OF_NODE          FIXED INITIAL("F  0  0000"),                         00089000
      VAC_PTR              FIXED INITIAL("F  1  0000"),                         00090000
      END_OF_LIST          FIXED INITIAL("F  F  0000"),                         00092000
                                                                                00093000
      TYPE_MASK            FIXED INITIAL("0  F  0000"),                         00094000
                                                                                00095000
      CONTROL_MASK         FIXED INITIAL("F  0  0000"),                         00096000
                                                                                00097000
 /* FOR DSUB, CONTROL = SHL(ALPHA,1) | BETA */                                  00098000
                                                                                00099000
      PARITY_MASK          FIXED INITIAL("002 F 0000"),                         00100000
                                                                                00101000
                                                                                00102000
 /* FOR TSUB, CONTROL = SHL(ALPHA - 7,1) | BETA */                              00103000
                                                                                00104000
 /*  OPERAND FIELD QUALIFIERS   */                                              00105000
      SYM       BIT(16) INITIAL (1),                                            00106000
      VAC       BIT(16) INITIAL (3),                                            00108000
      XPT       BIT(16) INITIAL (4),                                            00109000
      LIT       BIT(16) INITIAL (5),                                            00110000
      IMD       BIT(16) INITIAL (6),                                            00111000
      FUNC_CLASS BIT(8) INITIAL(3),                                             00130000
      LABEL_CLASS BIT(8) INITIAL(2),                                            00131000
      PROC_LABEL  BIT(8) INITIAL(71),                                           00132000
                                                                                00133000
 /* BUILT-IN FUNCTION TABLE*/                                                   00134000
                                                                                00135000
                                                                                00136000
      OK(100) BIT(8) INITIAL(                                                   00137000
                                                                                00138000
 /* FORMAT IS |REVERSE_OP|BFNC_OK|                                              00139000
                                        7        1        */                    00140000
                                                                                00141000
      0,        /* 0 */                                                         00142000
                                                                                00143000
      1,   /*ABS*/                                                              00144000
      27,   /*COS*/     /* = SHL(SIN,1) | 1*/                                   00145000
      1,   /*DET*/                                                              00146000
      1,   /*DIV*/                                                              00147000
      1,   /*EXP*/                                                              00148000
      1,   /*LOG*/                                                              00149000
      0,   /*MAX*/                                                              00150000
      0,   /*MIN*/                                                              00151000
      1,   /*MOD*/                                                              00152000
                                                                                00153000
 /* 10 = ODD */                                                                 00154000
                                                                                00155000
      1,   /*ODD*/                                                              00156000
      1,   /*SHL*/                                                              00157000
      1,   /*SHR*/                                                              00158000
      5,   /*SIN*/     /* = SHL(COS,1) | 1*/                                    00159000
      0,   /*SUM*/                                                              00160000
      1,   /*TAN*/                                                              00161000
      1,   /*XOR*/                                                              00162000
      1,   /*COSH*/                                                             00163000
      0,   /*DATE*/                                                             00164000
      0,   /*PRIO*/                                                             00165000
                                                                                00166000
 /* 20 = PROD */                                                                00167000
                                                                                00168000
      0,   /*PROD*/                                                             00169000
      1,   /*SIGN*/                                                             00170000
      1,   /*SINH*/                                                             00171000
      0,   /*SIZE*/                                                             00172000
      1,   /*SQRT*/                                                             00173000
      1,   /*TANH*/                                                             00174000
      0,   /*TRIM*/                                                             00175000
      1,   /*UNIT*/                                                             00176000
      1,   /*ABVAL*/                                                            00177000
      1,   /*FLOOR*/                                                            00178000
                                                                                00179000
 /* 30 = INDEX */                                                               00180000
                                                                                00181000
      1,   /*INDEX*/                                                            00182000
      0,   /*LJUST*/                                                            00183000
      0,   /*RJUST*/                                                            00184000
      1,   /*ROUND*/                                                            00185000
      1,   /*TRACE*/                                                            00186000
      1,   /*ARCCOS*/                                                           00187000
      1,   /*ARCSIN*/                                                           00188000
      1,   /*ARCTAN*/                                                           00189000
      0,   /*ERRGRP*/                                                           00190000
      0,   /*ERRNUM*/                                                           00191000
                                                                                00192000
 /* 40 = LENGTH */                                                              00193000
                                                                                00194000
      1,   /*LENGTH*/                                                           00195000
      1,   /*MIDVAL*/                                                           00196000
      0,   /*RANDOM*/                                                           00197000
      1,   /*SIGNUM*/                                                           00198000
      1,   /*ARCCOSH*/                                                          00199000
      1,   /*ARCSINH*/                                                          00200000
      1,   /*ARCTANH*/                                                          00201000
      1,   /*ARCTAN2*/                                                          00202000
      1,   /*CEILING*/                                                          00203000
      1,   /*INVERSE*/                                                          00204000
                                                                                00205000
 /* 50 = NEXTIME */                                                             00206000
                                                                                00207000
      0,   /*NEXTIME*/                                                          00208000
      0,   /*RANDOMG*/                                                          00209000
      0,   /*RUNTIME*/                                                          00210000
      1,   /*TRUNCATE*/                                                         00211000
      0,   /*CLOCKTIME*/                                                        00212000
      1,   /*REMAINDER*/                                                        00213000
      1    /*TRANSPOSE*/                                                        00214000
                                                                                00215000
      ),                                                                        00216000
                                                                                00217000
 /* IF LENGTH IS CHANGED, THEN CHANGE SINCOS AND SINOP VALUES*/                 00218000
                                                                                00219000
 /* CLASS 0 TABLE FOR CHICKEN_OUT AND PRESCAN.*/                                00219005
                                                                                00219010
                                                                                00219015
      CLASS0(96) BIT(16) INITIAL(                                               00219020
                                                                                00219025
      "173",/* 0 = NOP*/                                                        00219030
      "183",/* 1 = EXTN*/                                                       00219035
      "153",/* 2 = XREC*/                                                       00219040
      1,    /* 3 = IMRK*/                                                       00219045
      "163",/* 4 = SMRK*/                                                       00219050
      "A3", /* 5 = PXRC*/                                                       00219055
      0,                                                                        00219060
      3,    /* 7 = IFHD*/                                                       00219065
      "13", /* 8 = LBL */                                                       00219070
      "23", /* 9 = BRA */                                                       00219075
      "B3", /* A = FBRA*/                                                       00219080
      "F3", /* B = DCAS*/                                                       00219085
      "113",/* C = ECAS*/                                                       00219090
      "103",/* D = CLBL*/                                                       00219095
      "123",/* E = DTST*/                                                       00219100
      "133",/* F = ETST*/                                                       00219105
      "123",/* 10 = DFOR*/                                                      00219110
      "133",/* 11 = EFOR*/                                                      00219115
      "C1", /* 12 = CFOR*/                                                      00219120
      "33", /* 13 = DSMP*/                                                      00219125
      "43", /* 14 = ESMP*/                                                      00219130
      "141",/* 15 = AFOR*/                                                      00219135
      "C1", /* 16 = CTST*/                                                      00219140
      "E3", /* 17 = ADLP*/                                                      00219145
      3,    /* 18 = DLPE*/                                                      00219150
      "D3", /* 19 = DSUB*/                                                      00219155
      1,    /* 1A = IDLP*/                                                      00219160
      "D3", /* 1B = TSUB*/                                                      00219165
      0,0,0,0,                                                                  00219170
 /* IF PCAL OR FCAL IS CHANGED TO 3, MAKE STATEMENT ARRAYNESS                   00219175
                     MORE PRECISE*/                                             00219180
                                                                                00219185
      0,                                                                        00219190
      1,    /* 21 = WRIT*/                                                      00219195
      0,0,0,                                                                    00219200
      "71", /* 25 = XXST*/                                                      00219205
      1,    /* 26 = XXND*/                                                      00219210
      1,    /* 27 = XXAR  BEWARE:  TAG FIELD OF OPERANDS NOT ZEROED             00219215
                                      IN PREPARE HALMAT*/                       00219220
      0,0,                                                                      00219225
      "83", /* 2A - 2F BLOCK OPENINGS*/                                         00219230
      "83",                                                                     00219235
      "83",                                                                     00219240
      "83",                                                                     00219245
      "83",                                                                     00219250
      "83",                                                                     00219255
                                                                                00219260
      "93", /* 30 = CLOS*/                                                      00219265
      3,    /* 31 = EDCL*/                                                      00219270
      "63", /* 32 = RTRN*/                                                      00219275
      3,    /* 33 = TDCL*/                                                      00219280
      0,    /* 34 = WAIT*/                                                      00219285
      1,    /* 35 = SGNL*/                                                      00219290
      1,    /* 36 = CANC*/                                                      00219295
      1,    /* 37 = TERM*/                                                      00219300
      1,    /* 38 = PRIO*/                                                      00219305
      1,    /* 39 = SCHD*/                                                      00219310
      0,0,0,0,0,0,                                                              00219315
                                                                                00219320
      3,    /* 40 = MSHP*/                                                      00219325
      3,    /* 41 = VSHP*/                                                      00219330
      3,    /* 42 = SSHP*/                                                      00219335
      3,    /* 43 = ISHP*/                                                      00219340
      0,                                                                        00219345
      3,    /* 45 = SFST*/                                                      00219350
      3,    /* 46 = SFND*/                                                      00219355
      3,    /* 47 = SFAR*/                                                      00219360
      0,0,                                                                      00219365
      3,    /* 4A = BFNC*/                                                      00219370
      1,    /* 4B = LFNC*/                                                      00219375
      0,                                                                        00219380
      1,    /* 4D = TNEQ*/                                                      00219385
      1,    /* 4E = TEQU    SKIP STRUCTURE COMPARES SINCE TERMAINAL             00219390
                               NODE MIGHT HAVE BEEN ASSIGNED*/                  00219395
      "53", /* 4F = TASN*/                                                      00219400
                                                                                00219405
      0,                                                                        00219410
      "80", /* 51 = IDEF*/                                                      00219415
      "93", /* 52 = ICLS*/                                                      00219420
      0),                                                                       00219425
                                                                                00219430
                                                                                00220000
                                                                                00220010
                                                                                00220020
 /* DECLARATIONS FOR SUBSCRIPT COMMON EXPRESSIONS*/                             00220030
      LAST_DSUB_HALMAT  FIXED,                                                  00220040
      COMPONENT_SIZE(5) BIT(16),                                                00220050
      PRESENT_DIMENSION BIT(16),                                                00220060
      ARRAY_DIMENSIONS BIT(16),                                                 00220070
      DIMENSIONS BIT(16),                                                       00220080
      PREVIOUS_COMPUTATION BIT(8),                                              00220090
      VAR BIT(16),                                                              00220100
      VAR_TYPE BIT(16),                                                         00220110
      OPERAND_TYPE BIT(16),                                                     00220120
      DSUB_INX BIT(16),                                                         00220130
      DSUB_HOLE BIT(16),                                                        00220140
      DSUB_LOC BIT(16),                                                         00220150
      TSUB_SUB BIT(8),     /* TRUE IF TSUB*/                                    00220151
      TEMPLATE_STACK_END BIT(16) INITIAL(TEMPLATE_STACK_SIZE),                  00220152
      TEMPLATE_STACK_START BIT(16) INITIAL(TEMPLATE_STACK_SIZE + 1),            00220153
                                                                                00220160
                                                                                00220170
 /* CONSTANTS FOR SUBSCRIPT COMMON EXPRESSIONS*/                                00220180
                                                                                00220190
      SAV_BITS BIT(16) INITIAL("502"),                                          00220200
      SAV_VAC_BITS BIT(16) INITIAL("532"),                                      00220210
      SAV_XPT_BITS BIT(16) INITIAL("542"),                                      00220215
      ALPHA_BETA_QUAL_MASK FIXED INITIAL("772"),                                00220220
      IMD_0 BIT(16) INITIAL("61"),                                              00220230
      ALPHA_BETA_MASK BIT(16) INITIAL("F02"),                                   00220240
      ALPHA LITERALLY '(SHR(OPR(DSUB_INX),8) & "3")',                           00220250
      BETA  LITERALLY '(SHR(OPR(DSUB_INX),1))',                                 00220260
                                                                                00220270
                                                                                00220280
 /* VAR_TYPE CODES*/                                                            00220290
                                                                                00220300
      BIT_VAR  BIT(8) INITIAL(1),                                               00220310
      CHAR_VAR BIT(8) INITIAL(2),                                               00220320
      MAT_VAR  BIT(8) INITIAL(3),                                               00220330
      VEC_VAR  BIT(8) INITIAL(4),                                               00220340
      INT_VAR  BIT(8) INITIAL(6),                                               00220342
                                                                                00220350
                                                                                00220360
                                                                                00220370
 /* DECLARATIONS FOR VECTOR MATRIX INLINE*/                                     00220510
      LOOP_DIMENSION BIT(16),   /* NO OF ITERATIONS IN VM LOOP*/                00220520
      LOOP_START BIT(16),        /* PTR TO FIRST OPERATOR IN LOOP*/             00220530
      LOOP_LAST BIT(16),          /* PTR TO LAST OPERATOR IN LOOP*/             00220540
      DSUB_REF BIT(8),           /* TRUE IF LOOP OPERAND REFERS TO DSUB*/       00220550
      LOOPLESS_ASSIGN BIT(8),    /* TRUE IF ASSIGN INTO PARTITION*/             00220560
      ASSIGN_TOP BIT(8),         /* TRUE IF LAST OP ASSIGNMENT   */             00220570
      LOOPY_ASSIGN_ONLY BIT(8),  /* TRUE IF ASSIGN ONLY POSSIBLE LOOPY*/        00220580
      VDLP# BIT(8),              /* NUMBER OF VECTOR LOOPS GENERATED  */        00220590
      TAG_BIT FIXED INITIAL ("40 00 000 0"),                                    00220600
                                                                                00220610
                                                                                00220620
 /* DECLARATIONS FOR LOOP SMERSHING */                                          00220705
      AR_DIMS BIT(8),       /* # OF DIMENSIONS IN PRESENT ARRAY LOOP*/          00220710
      NESTED_VM BIT(8),     /* TRUE IF NESTED VM IN ARRAY NOT DISALLOWED*/      00220715
      STRUCTURE_COPIES BIT(8), /* TRUE IF STRUCTURE COPIES*/                    00220720
      IN_VM BIT(8),         /* TRUE IF IN VECT/MAT LOOP*/                       00220725
      IN_AR BIT(8),         /* TRUE IF IN ARRAY LOOP*/                          00220730
      AR_DENESTABLE BIT(8), /* TRUE IF ARRAY POSSIBLY DENESTABLE*/              00220735
      PHASE1_ERROR BIT(8),  /* TRUE IF ERROR DISCOVERED IN STATEMENT*/          00220740
      CROSS_STATEMENTS BIT(8) INITIAL(1),/* TRUE IF ALLOWED TO CROSS STMT       00220745
                                                    BOUNDARIES*/                00220750
                                                                                00220755
      STACKED_VDLPS BIT(16), /* # OF VDLPS ON STACK */                          00220760
      V_STACK_INX BIT(16),   /* # OF VDLPS ON END OF STACK(POSITIONS 4,5)*/     00220765
      (ST,ST1) BIT(16),     /* LOOP STACK PTRS*/                                00220770
      DENEST_TAG BIT(16)      INITIAL("400"),                                   00220775
      OUTSIDE_REF_TAG BIT(16) INITIAL("200"),                                   00220780
      VDLP_TAG   BIT(16)      INITIAL("100"),                                   00220785
      VM_LOOP_TAG FIXED INITIAL(4),                                             00220790
      OUT_OF_ARRAY_TAG BIT(16) INITIAL(2),                                      00220795
      AR_ALPHA_MASK FIXED INITIAL("FFFF 00 FF"),                                00220800
      LAST_ZAP BIT(16),                                                         00220805
      ASSIGN_OP BIT(8),                                                         00220810
      C_TRACE BIT(8),                                                           00220815
      (DENEST#,COMBINE#) BIT(16);                                               00220820
   ARRAY                         /* DR109100  CHANGE DIMENSION OF CONF ARRAYS*/
      CONF_ASSIGNS(INDEX_SIZE) BIT(16), /*POINTS TO NON-ARRAYED V/M RECEIVERS*/ 00220825
      CONF_REFERENCES(INDEX_SIZE) BIT(16); /*TO NON-ARRAYED VM RHS QUANTITIES*/ 00220826
   DECLARE
      (CA_INX,CR_INX) BIT(16),     /* INDICES TO ABOVE */                       00220827
      ARRAYNESS_CONFLICT BIT(8), /* TRUE IF INHIBITED COMBINING DUE TO          00220828
                                       ARRAYNESS OVERLAP CONFLICT */            00220829
 /* LOOP STACKS*/                                                               00220830
      LOOP_HEAD(LOOP_STACKSIZE) BIT(16), /* START OF LOOP*/                     00220835
      LOOP_END (LOOP_STACKSIZE) BIT(16), /*END OF LOOP*/                        00220840
      AR_SIZE(LOOP_STACKSIZE) BIT(16),        /* # OF ELTS IN LOOP*/            00220845
      ADJACENT(LOOP_STACKSIZE) BIT(8),   /* ADJ(K) TRUE IF LOOP K,K+1 ADJ*/     00220850
      REF_TO_DSUB(LOOP_STACKSIZE) BIT(8),   /* TRUE IF OPRND REFERS TO DSUB*/   00220855
      ASSIGN(LOOP_STACKSIZE) BIT(8),     /* TRUE IF ASSIGN IN LOOP*/            00220860
      /* DR111333 - SAVE TEMPLATE SYM# OF STRUCTURE NODE ASSIGNED */
      STRUC_TEMPL BIT(16), /* DR111333 */
      /* DR111333 - TRUE IF MAJOR STRUCTURE THEN REFERENCED AFTER NODE */
      REF_TO_STRUC BIT(8),  /* DR111333 */
                                                                                00220865
                                                                                00220870
 /* DECLARATIONS FOR GET_NODE  */                                               00221000
      SYT_POINT      BIT(16),                                                   00222000
      GET_INX        BIT(16),                                                   00223000
      NODE_BEGINNING BIT(16),                                                   00224000
      NODE_SIZE      BIT(16),                                                   00225000
      SEARCH_INX     BIT(16),                                                   00229000
      STT#           BIT(16),                                                   00231000
      ASSIGN_CTR     BIT(16),                                                   00232000
      ARRAYED_TSUB BIT(8),                                                      00232100
      TWIN_OP BIT(8),                                                           00233000
      PREVIOUS_TWIN BIT(8),                                                     00234000
      TWIN_MATCH BIT(8),                                                        00235000
      LAST_END_OF_LIST BIT(16);   /* PTR TO E O L */                            00235010
                                                                                00236000
 /*DR109092 - INCREASE SEARCH DIMENSION AND CHANGE DECLARATION TO ARRAY*/
   DECLARE MAX_NODE LITERALLY '351';                         /*DR109092*/
   ARRAY                                                     /*DR109092*/
      SEARCH(MAX_NODE)      FIXED,                           /*DR109092*/       00226000
      SEARCH_REV(MAX_NODE)  FIXED,                           /*DR109092*/       00227000
      SEARCH2_REV(MAX_NODE) BIT(16),                         /*DR109092*/       00228000
      SEARCH2(MAX_NODE)     BIT(16),                         /*DR109092*/       00230000
      CSE(MAX_NODE)         FIXED,                           /*DR109092*/       00238000
      CSE2(MAX_NODE)        BIT(16);                         /*DR109092*/       00239000

 /* DECLARATIONS FOR CSE_MATCH_FOUND, REARRANGE_HALMAT*/                        00237000
   DECLARE
      CSE_FOUND_INX         BIT(16),                                            00240000
      PREVIOUS_NODE_PTR BIT(16),                                                00241000
      PRESENT_NODE_PTR BIT(16),                                                 00242000
      (OP,REVERSE_OP)     BIT(16),                                              00243000
      (LAST_INX,POINT1)   BIT(16),                                              00244000
      TOPTAG         BIT(8),                                                    00245000
      (REVERSE,FORWARD)   BIT(8),                                               00246000
      INVERSE     BIT(8),                                                       00247000
      PARITY              BIT(8),                                               00248000
      NEW_NODE_PTR         BIT(16),                                             00249000
      (PREVIOUS_NODE_OPERAND,NEW_NODE_OP) BIT(16),                              00250000
      (MPARITY0#,MPARITY1#) BIT(16),                                            00251000
      (FNPARITY0#,FNPARITY1#) BIT(16),                                          00252000
      (PNPARITY0#,PNPARITY1#) BIT(16),                                          00253000
                                                                                00254000
 /***************************************************************************** 00255000
                                                                                00256000
PREVIOUS_NODE_OPERAND  POINTS TO FIRST OPERAND OF NODE IN NODE LIST             00257000
PREVIOUS_NODE_PTR      POINTS TO "PTR_TO_VAC" NODE WORD OF PREVIOUS MATCH       00258000
PREVIOUS_HALMAT        POINTS TO HALMAT OPERATOR OF PREVIOUS MATCH              00259000
MPARITY0#              # OF PARITY 0 OPERANDS IN MATCH OF PREVIOUS NODE         00260000
MPARITY1#              "  "   "    1     "     "   "                            00261000
FNPARITY0#             "  "   "    0     "     " FORWARD NODE                   00262000
FNPARITY1#             "  "   "    1     "     "   "      "                     00263000
PNPARITY0#             "  "    "   0     "     " PREVIOUS "                     00264000
PNPARITY1#             "  "    "   1     "     "    "     "                     00265000
NEW_NODE_PTR           POINTS TO NODE LIST WHERE "PTR_TO_VAC" FOR MATCHED PART  00266000
                       OF NODES WILL BE                                         00267000
NODE_BEGINNING         POINTS TO LATTER OPERATOR WORD IN NODE LIST              00268000
PREVIOUS_NODE          POINTS TO OPERATOR WORD IN NODE LIST                     00269000
PRESENT_NODE_PTR       POINTS TO "PTR_TO_VAC" NODE WORD OF PRESENT MATCH        00270000
*******************************************************************************/00271000
                                                                                00272000
                                                                                00273000
 /* DECLARATIONS FOR REARRANGE_HALMAT */                                        00274000
      HP BIT(16),                        /*DR111313*/
      CSE_TAG     BIT(16) INITIAL("8"),                                         00274010
      (PREVIOUS_NODE,PREVIOUS_HALMAT,PRESENT_HALMAT) BIT(16),                   00276000
      (HALMAT_NODE_START, HALMAT_NODE_END) BIT(16),                             00277000
      (NUMOP_FOR_REARRANGE, HALMAT_PTR,H_INX) BIT(16),                          00278000
      (MULTIPLE_MATCH,TOTAL_MATCH_PREV,TOTAL_MATCH_PRES) BIT(8);                00279000
                                                                                00280000
                                                                                00281000
 /* STATISTICS*/                                                                00282000
   DECLARE (MAXNODE,MAX_CSE_TAB) BIT(16),                                       00283000
      (CSE#,TRANSPOSE_ELIMINATIONS,DIVISION_ELIMINATIONS,SCANS,                 00284000
      STATISTICS,COMPARE_CALLS,COMPLEX_MATCHES,LITERAL_FOLDS)    BIT(16),       00285000
      COMPLEX_MATCH BIT(8),                                                     00286000
      EXTN_CSES   BIT(16),                                                      00287000
      TSUB_CSES   BIT(16),                                                      00288000
                                                                                00289000
                                                                                00290000
 /* DECLARATIONS FOR RELOCATE_HALMAT*/                                          00291000
      CSE_L_INX                BIT(16);                                         00292000
   BASED COMMONSE_LIST  RECORD DYNAMIC:                                         00293000
         LIST_CSE    BIT(16),                                                   00293010
      END;                                                                      00293020
                                                                                00294000
 /*  OPERATION FIELD OR SUBFIELD CODES  */                                      00295000
   DECLARE                                                                      00296000
      XSMRK     BIT(16) INITIAL ("0040"),      /* 16-BIT  OPERATORS */          00297000
      XPXRC     BIT(16) INITIAL ("0050"),                                       00297010
      XBFNC     BIT(16) INITIAL ("04A0"),                                       00298000
      XEXTN     BIT(16) INITIAL ("0010"),                                       00299000
      XXREC     BIT(16) INITIAL ("0020"),                                       00300000
      XFBRA     BIT(16) INITIAL ("00A0"),                                       00301000
      XCNOT     BIT(16) INITIAL ("7E40"),                                       00302000
      XCAND     BIT(16) INITIAL ("7E20"),                                       00303000
      XCOR      BIT(16) INITIAL ("7E30"),                                       00304000
      XCFOR     BIT(16) INITIAL ("0120"),                                       00305000
      XCTST     BIT(16) INITIAL ("0160"),                                       00306000
      XBNEQ     BIT(16) INITIAL ("7250"),                                       00307000
      XILT      BIT(16) INITIAL ("7CA0"),                                       00308000
      XDLPE     BIT(16) INITIAL ("0180"),                                       00309000
      XSFST     BIT(16) INITIAL ("0450"),                                       00310000
      XSFND     BIT(16) INITIAL ("0460"),                                       00311000
      XXXST     BIT(16) INITIAL ("0250"),                                       00313000
      XXXND     BIT(16) INITIAL ("0260"),                                       00314000
      XXXAR     BIT(16) INITIAL ("0270"),                                       00315000
      XREAD     BIT(16) INITIAL ("01F0"),                                       00316000
      XWRIT     BIT(16) INITIAL ("0210"),                                       00318000
      XIDEF     BIT(16) INITIAL ("0510"),                                       00320000
      XICLS     BIT(16) INITIAL ("0520"),                                       00321000
      XINL      BIT(16) INITIAL ("0021"),                                       00323010
      XXPT      BIT(16) INITIAL ("0041"),                                       00324000
      XIMD      BIT(16) INITIAL ("0061"),                                       00324010
      XAST      BIT(16) INITIAL ("0071"),                                       00324020
      XVAC      BIT(16) INITIAL ("0031"),                                       00325000
      XSYT      BIT(16) INITIAL ("0011"),                                       00325010
      XLIT      BIT(16) INITIAL ("0051"),                                       00325020
      XNOP      BIT(16) INITIAL ("0000"),                                       00325030
      NOP       BIT(16) INITIAL ("000"),                                        00325040
      SADD      BIT(16) INITIAL ("5AB"),                                        00327000
      SSUB      BIT(16) INITIAL ("5AC"),                                        00328000
      SSPR      BIT(16) INITIAL ("5AD"),                                        00329000
      SSDV      BIT(16) INITIAL ("5AE"),                                        00330000
      ISUB      BIT(16) INITIAL ("6CC"),                                        00331000
      IADD      BIT(16) INITIAL ("6CB"),                                        00332000
      IIPR      BIT(16) INITIAL ("6CD"),                                        00333000
      ISHP      BIT(16) INITIAL ("043"),                                        00333010
      MSHP      BIT(16) INITIAL ("040"),                                        00333020
      SFST      BIT(16) INITIAL ("045"),                                        00333030
      BFNC      BIT(16) INITIAL ("04A"),                                        00334000
      DFOR      BIT(16) INITIAL ("010"),                                        00334010
      MSUB      BIT(16) INITIAL ("363"),                                        00335000
      MADD      BIT(16) INITIAL ("362"),                                        00336000
      VSUB      BIT(16) INITIAL ("483"),                                        00337000
      VADD      BIT(16) INITIAL ("482"),                                        00338000
      RTRN      BIT(16) INITIAL ("032"),                                        00341000
      MTRA      BIT(16) INITIAL ("329"),                                        00343000
      MVPR      BIT(16) INITIAL ("46C"),                                        00344000
      DSUB      BIT(16) INITIAL ("019"),                                        00345000
      MTOM      BIT(16) INITIAL ("341"),                                        00346000
      VTOV      BIT(16) INITIAL ("441"),                                        00347000
      TSUB      BIT(16) INITIAL ("01B"),                                        00348000
      EXTN      BIT(16) INITIAL ("001"),                                        00349000
      TASN      BIT(16) INITIAL ("04F"),                                        00350000
      XREC      BIT(16) INITIAL ("002"),                                        00351000
      ADLP      BIT(16) INITIAL ("017"),                                        00351010
      DLPE      BIT(16) INITIAL ("018"),                                        00351020
      XXAR      BIT(16) INITIAL ("027"),                                        00351030
      SFAR      BIT(16) INITIAL ("047"),                                        00351040
      CAND      BIT(16) INITIAL ("7E2"),                                        00352000
      SMRK      BIT(16) INITIAL ("004"),                                        00352010
      IASN      BIT(16) INITIAL ("601"),                                        00352020
      VDOT      BIT(16) INITIAL ("58E"),                                        00352050
      BTOI      BIT(16) INITIAL("621"),                                         00352051
      BTOS      BIT(16) INITIAL("521"),                                         00352052
 /*  DR 108607 - LARRY WINGO            ******/
      MNEQ      BIT(16) INITIAL("765"),                                         00352052
      VEQU      BIT(16) INITIAL("786"),                                         00352052
 /*  END DR 108607                      ******/
                                                                                00352060
                                                                                00352070
                                                                                00352080
                                                                                00352090
 /* FULL OPERATORS*/                                                            00352100
                                                                                00352110
      VDLP      FIXED   INITIAL ("1 017 8"),                                    00352120
      VDLE      FIXED   INITIAL ("  018 8"),                                    00352130
      ADLP_WORD FIXED   INITIAL ("  017 0"),                                    00352134
      DLPE_WORD FIXED   INITIAL ("  018 0"),                                    00352135
                                                                                00352140
 /* CSE TAG SET IF PURE VECTOR DO LOOP START OR END*/                           00352150
                                                                                00352160
                                                                                00352170
                                                                                00352180
                                                                                00352190
                                                                                00353000
 /* CODE OPTIMIZER BITS  */                                                     00354000
      XD        BIT(16)  INITIAL      (2),                                      00355000
      XN        BIT(16)  INITIAL      (1);                                      00356000
                                                                                00357000
                                                                                00358000
                                                                                00358910
 /* CODE RETRIEVAL DECLARATIONS */                                              00359000
   DECLARE CODEFILE BIT(8) INITIAL (1),                                         00360000
      CURCBLK BIT(8),                                                           00361000
      CODE_OUTFILE BIT(8) INITIAL(4),                                           00362000
      OUTBLK BIT(16),                                                           00363000
      NOT_XREC  BIT(8),                                                         00364000
      TEST BIT(8),                                                              00365000
      TOTAL BIT(16),                                                            00365010
      POST_STATEMENT_ZAP  BIT(8),                                               00366000
      WATCH BIT(8),                                                             00367000
      HIGHOPT                BIT(8), /*DR103787*/                               00368000
      OPTIMIZER_OFF          BIT(8),                                            00368000
      TRACE                 BIT(8),                                             00369000
      SUB_TRACE       BIT(8),                                                   00369010
      HALMAT_REQUESTED BIT(8),                                                  00370000
      HALMAT_BLAB  BIT(8),                                                      00371000
      MOVE_TRACE BIT(8),                                                        00371050
      FOLLOW_REARRANGE BIT(8),                                                  00371060
      FUNC_LEVEL BIT(16),                                                       00372000
      NESTFUNC BIT(16);                                                         00373000
                                                                                00374000
 /* DECLARATIONS FOR LITERAL FOLDING*/                                          00375000
   DECLARE                                                                      00376000
      LIT_TOP_MAX LITERALLY '32767',                                            00378000
      (MSG1,MSG2) CHARACTER,                                                    00379000
      (LITORG,LITMAX,CURLBLK) FIXED,                                            00380000
      PREVIOUS_CALL BIT(8) ;                                                    00382000
                                                                                00383000
 /* USEFUL CHARACTER LITERALS */                                                00384000
   DECLARE  COLON          CHARACTER INITIAL (':'),                             00385000
      COMMA          CHARACTER INITIAL (','),                                   00386000
      BLANK          CHARACTER INITIAL (' '),                                   00387000
      LEFTBRACKET    CHARACTER INITIAL ('('),                                   00388000
      HEXCODES       CHARACTER INITIAL ('0123456789ABCDEF'),                    00389000
      X72            CHARACTER INITIAL                                          00390000
   ('                                                                        ');00391000
                                                                                00392000
                                                                                00393000
 /*  SYMBOL TABLE DEPENDENT DECLARATIONS  */                                    00394000
   DECLARE                                                                      00395000
      SYT_USED BIT(16),  /* LAST POSSIBLY VALID SYMBOL */                       00396000
      SYT_WORDS LITERALLY 'SHR(SYT_USED,5)',     /*****INDEX****OF LAST         00397000
                                                  POSSIBLY VALID WORD*/         00398000
                                                                                00399000
      LITSIZ LITERALLY '130',                                                   00403000
      LITFILE LITERALLY '2';                                                    00404000
   DECLARE LITLIM FIXED INITIAL(LITSIZ);                                        00405000
                                                                                00406000
   /%INCLUDE COMMON %/                                                          00407000
                                                                                00407001
      DECLARE MAX_SEVERITY BIT(16);                                             00407002
   DECLARE SEVERITY BIT(16);                                                    00407003
   DECLARE DWN_STMT(1) LITERALLY 'DOWN_INFO(%1%).DOWN_STMT';                    00407004
   DECLARE DWN_ERR(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_ERR';                     00407005
   DECLARE DWN_CLS(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_CLS';                     00407006
/********************* DR108630 - TEV - 10/29/93 *********************/
   DECLARE DWN_UNKN(1) LITERALLY 'DOWN_INFO(%1%).DOWN_UNKN';
/********************* END DR108630 **********************************/
   DECLARE DWN_VER(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_VER';                     00407007
   BASED SYM_SHRINK RECORD DYNAMIC:                                             00409300
         SYM_REL                BIT(16),                                        00409400
      END;                                                                      00409500
                                                                                00425010
 /*******************************************************************/          00425011
 /* THE FOLLOWING VARIABLES MUST BE INDEXED VIA REL */                          00425012
 /*******************************************************************/          00425013
   BASED PAR_SYM RECORD DYNAMIC:                                                00425020
         CAT_ARRAY              BIT(16),                                        00425120
      END;                                                                      00425220
   BASED STRUCT# RECORD DYNAMIC:                                                00425320
         TMPLT               BIT(16),                                           00425420
      END;                                                                      00425520
   BASED VAL_TABLE RECORD DYNAMIC:                                              00425620
         VAL_ARRAY              FIXED,                                          00425720
      END;                                                                      00425820
   BASED OBPS RECORD DYNAMIC:                                                   00425920
         TSAPS                    FIXED,                                        00426020
      END;                                                                      00426120
   BASED ZAPIT RECORD DYNAMIC:                                                  00426220
         TYPE_ZAP               FIXED,                                          00426320
      END;                                                                      00426420
                                                                                00431010
   DECLARE #ZAP_BY_TYPE_ARRAYS LITERALLY'6'; /* THERE ARE 6 OF THEM, NOT 7 */   00431030
                                                                                00432000
   DECLARE WIPEOUT# LITERALLY 'VALIDITY';                                       00433000
                                                                                00434000
                                                                                00434010
 /* VARIABLES FOR STACKING*/                                                    00434020
                                                                                00434030
   DECLARE                                                                      00434040
      ZAP_LEVEL  BIT(16),  /*ZAP_STACK_LEVEL */                                 00434041
      LOOP_ZAPS_LEVEL   BIT(16),                                                00434042
      LEVEL BIT(16),       /* STACK LEVEL*/                                     00434050
      BLOCK# BIT(16),      /* # ASSOCIATED WITH A BLOCK*/                       00434060
      OLD_LEVEL BIT(16),  /* LEVEL FOR CSE*/                                    00434100
      OLD_BLOCK# BIT(16),  /* BLOCK# FOR CSE*/                                  00434110
      POST_STATEMENT_PUSH BIT(8),   /* TO PUSH STACKS AT END OF STMT*/          00434120
      INL# BIT(16),        /* PRESENT INL#*/                                    00434130
      STACK_TRACE BIT(8),                                                       00434160
      NODE_DUMP BIT(8) INITIAL(1),                                              00434170
      CSE_TAB_DUMP2 BIT(8),  /* LISTS CATALOG & NODE ENTRIES IN CSE_TAB*/       00434173
      VAL_SIZE BIT(16),    /* WIDTH OF ZAP ARRAY FOR ONE LEVEL*/                00434180
      BLOCK_TOP BIT(16);   /* RUNNING BLOCK #'S IN A BLOCK*/                    00434190
                                                                                00434200
   BASED LEVEL_STACK_VARS RECORD DYNAMIC:                                       00434210
         XZAP_BASE FIXED,          /* BASE FOR ASSOCIATED ZAPS */               00434211
         XPULL_LOOP_HEAD BIT(16),                                               00434212
 /* START OF INNERMOST LOOP CONTAINING THIS LEVEL */                            00434213
         XSTACK_INL# BIT(16),      /* INL# FOR EACH BLOCK */                    00434214
         XSTACKED_BLOCK# BIT(16),  /* BLOCK# FOR EACH LEVEL */                  00434215
         XSTACK_TAGS BIT(8),       /* TAGS FOR EACH BLOCK */                    00434216
      END;                                                                      00434217
                                                                                00434220
 /* VARIABLES FOR LOOP INVARIANT COMPUTATIONS*/                                 00435000
                                                                                00435010
   ARRAY  AR_LIST(33)  BIT(16);                                                 00435020
   DECLARE                                                                      00435030
      AR_INX BIT(16),        /* INDEX FOR AR_LIST*/                             00435050
      DA_MASK FIXED INITIAL("6000 0000"),  /*DUMMY,ARRAY MASK FOR NODE LIST*/   00435060
      AR_TAG FIXED INITIAL("2000 0000"), /* NODE LIST TAG FOR ARRAYED NODES*/   00435070
      INVARIANT_COMPUTATION BIT(8),                                             00435120
 /* TRUE IF NODE HAS INVARIANT COMPUTATION*/                                    00435130
      INVARIANT_PULLED BIT(8),  /* TRUE IF ACTUALLY PULLED FROM LOOP*/          00435140
      INVAR# BIT(16),   /* # OF INVAR COMPS PULLED*/                            00435150
      AR_PTR BIT(16),   /* POINTS TO ADLP*/                                     00435160
      LOOPY_OPS BIT(8), /* TRUE IF INVAR COMP IS LOOPY*/                        00435170
      ARRAYED_OPS BIT(8),   /* TRUE IF INVAR COMP HAS ARRAYED OPS*/             00435180
      STATEMENT_ARRAYNESS BIT(8),  /* TRUE IF ARRAYED STMT*/                    00435190
      EXTNS_PRESENT BIT(8),   /* TRUE IF EXTN'S IN STATEMENT*/                  00435192
      ARRAYED_CONDITIONAL BIT(8),   /* IF CONDITIONAL IS ARRAYED */             00435194
      PUSH# BIT(16),    /* # OF CALLS TO PUSH_HALMAT*/                          00435200
      PUSH_SIZE FIXED,/* # OF WORDS PUSHED*/                                    00435210
      I_TRACE LITERALLY 'STACK_TRACE',                                          00435220
      CROSS_BLOCK_OPERATORS(1) BIT(16),   /* MAX # OF OPERATORS PASSED ACROSS   00435230
                                                A BLOCK*/                       00435240
      ROOM BIT(16),              /* SPACE FOR HALMAT PUSHING IN A STATEMENT*/   00435250
      LEV BIT(16);      /* LEVEL FOR PULLING INVAR COMPS*/                      00435260
   DECLARE FBRA_FLAG BIT(1) INITIAL(FALSE);                   /* DR103032 */    00435270
                                                                                00435290
                                                                                00435300
                                                                                00435310
   DECLARE WORK3 FIXED;                                                         00437000
                                                                                00438000
   DECLARE                                                                      00439000
      LIT_TOP       LITERALLY 'COMM(2)',                                        00451000
      TOGGLE        LITERALLY 'COMM(6)',                                        00455000
      OPTION_BITS   LITERALLY 'COMM(7)';                                        00456000
                                                                                00457000
   DECLARE SYT_SIZE BIT(16);                                                    00457010
                                                                                00457020
   DECLARE                                                                      00459000
      XNEST_MASK FIXED INITIAL("FF 00 0000"),                                   00459010
      PM_FLAGS FIXED INITIAL("00C20080"),                                       00460000
      MAJ_STRUCT  BIT(16) INITIAL(10),                                          00461000
      STUB_FLAG   FIXED  INITIAL("00002000"),                                   00462000
      REGISTER_TAG FIXED INITIAL("2 00 0000"),                                  00463000
      ELEGANT_BUGOUT      BIT(8),                                               00464000
      NAME_OR_PARM_FLAG FIXED INITIAL("1000 0020");                             00464010
                                                                                00466000
   DECLARE                                                                      00467000
      OPTYPE BIT(16),                                                           00469000
      TEMP BIT(16),                                                             00470000
      TMP FIXED;                                                                00471000
                                                                                00471001
   DECLARE    MOVEABLE LITERALLY '1';                                           00471002
   DECLARE  SYT_NAME(1) LITERALLY 'SYM_TAB(%1%).SYM_NAME',                      00471004
      SYT_XREF(1) LITERALLY 'SYM_TAB(%1%).SYM_XREF',                            00471006
      SYT_DIMS(1) LITERALLY 'SYM_TAB(%1%).SYM_LENGTH',                          00471009
      SYT_ARRAY(1) LITERALLY 'SYM_TAB(%1%).SYM_ARRAY',                          00471010
      SYT_LINK1(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK1',                          00471012
      SYT_LINK2(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK2',                          00471013
      SYT_CLASS(1) LITERALLY 'SYM_TAB(%1%).SYM_CLASS',                          00471014
      SYT_FLAGS(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS',                          00471015
      SYT_TYPE(1) LITERALLY 'SYM_TAB(%1%).SYM_TYPE';                            00471017
   DECLARE  REL(1) LITERALLY 'SYM_SHRINK(%1%).SYM_REL',                         00471019
      TEMPL#(1) LITERALLY 'STRUCT#(%1%).TMPLT',                                 00471020
      VALIDITY_ARRAY(1) LITERALLY 'VAL_TABLE(LEVEL).VAL_ARRAY(%1%)',            00471021
      CATALOG_ARRAY(1) LITERALLY 'PAR_SYM(LEVEL).CAT_ARRAY(%1%)',               00471022
      ZAP_BASE(1) LITERALLY 'LEVEL_STACK_VARS(%1%).XZAP_BASE',                  00471023
      PULL_LOOP_HEAD(1) LITERALLY 'LEVEL_STACK_VARS(%1%).XPULL_LOOP_HEAD',      00471024
      STACK_INL#(1) LITERALLY 'LEVEL_STACK_VARS(%1%).XSTACK_INL#',              00471025
      STACKED_BLOCK#(1) LITERALLY 'LEVEL_STACK_VARS(%1%).XSTACKED_BLOCK#',      00471026
      STACK_TAGS(1) LITERALLY 'LEVEL_STACK_VARS(%1%).XSTACK_TAGS',              00471027
      LOOP_ZAPS(1) LITERALLY 'OBPS(LOOP_ZAPS_LEVEL).TSAPS(%1%)',                00471028
      ZAPS(1) LITERALLY 'OBPS(ZAP_LEVEL).TSAPS(%1%)',                           00471029
      XREF(1) LITERALLY 'CROSS_REF(%1%).CR_REF',                                00471030
      DW(1) LITERALLY 'FOR_DW(%1%).CONST_DW',                                   00471033
      LIT1(1) LITERALLY 'LIT_PG.LITERAL1(%1%)',                                 00471036
      LIT2(1) LITERALLY 'LIT_PG.LITERAL2(%1%)',                                 00471037
      LIT3(1) LITERALLY 'LIT_PG.LITERAL3(%1%)',                                 00471038
      CSE_LIST(1) LITERALLY 'COMMONSE_LIST(%1%).LIST_CSE';                      00471039
                                                                                00472000
                                                                                00472100
 /* INCLUDE VMEM DECLARES:  $%VMEM1  */                                         00472200
 /* AND:  $%VMEM2  */                                                           00472300
                                                                                00472400
                                                                                00473000
 /* TAGS FOR OPERATOR WORD IN NODE LIST*/                                       00474000
                                                                                00475000
   DECLARE MATCHED_TAG FIXED INITIAL("8000 0000");                              00476000
                                                                                00477000
   DECLARE NEGMAX FIXED INITIAL("80000000"), POSMAX FIXED INITIAL("7FFFFFFF");  00478000
                                                                                00479000
 /* MISCELLANEOUS DECLARATIONS */                                               00480000
   DECLARE  OPTIMISING BIT(1) INITIAL(1),                                       00481000
      DISASTER LABEL,                                                           00482000
      PUSH_TEST BIT(8),                                                         00482010
      DEBUG BIT(8),                                                             00483000
      MESSAGE CHARACTER;                                                        00484000
   DECLARE  (STILL_NODES,SEARCHABLE) BIT(8);                                    00485000
                                                                                00487000
 /* ARRAY PARALLEL TO HALMAT*/                                                  00488000
   ARRAY   FLAG(DOUBLEBLOCK_SIZE) BIT(8);                                       00489000
   DECLARE OPR(DOUBLEBLOCK_SIZE) FIXED;      /* HALMAT */                       00490000
                                                                                00492000
 /**MERGE FORMAT       FORMAT                          */
 /**MERGE HEX          HEX                             */
 /**MERGE DECODEPI     DECODEPIP                       */
 /**MERGE DECODEPO     DECODEPOP                       */
 /**MERGE STACKDUM     STACK_DUMP                      */
 /**MERGE BUMPBLOC     BUMP_BLOCK                      */
 /**MERGE GETCLASS     GET_CLASS                       */
 /**MERGE OPOP         OPOP                            */
 /**MERGE GETEON       GET_EON                         */
 /**MERGE SHAPINGF     SHAPING_FN                      */
 /**MERGE XNEST        XNEST                           */
 /**MERGE VACORXPT     VAC_OR_XPT                      */
 /**MERGE STRUCTUR     STRUCTURE_COMPARE               */
 /**MERGE NEWHALMA     NEW_HALMAT_BLOCK                */
 /**MERGE BLABBLOC     BLAB_BLOCK                      */
 /**MERGE NEXTCODE     NEXTCODE                        */
 /**MERGE BUMPDN       BUMP_D_N                        */
 /**MERGE XBITS        X_BITS                          */
 /**MERGE CHARINDE     CHAR_INDEX                      */
 /**MERGE PAD          PAD                             */
 /**MERGE ERRORS       ERRORS                          */
 /**MERGE CATALOGP     CATALOG_PTR                     */
 /**MERGE SETCATAL     SET_CATALOG_PTR                 */
 /**MERGE VALIDITY     VALIDITY                        */
 /**MERGE SETVALID     SET_VALIDITY                    */
 /**MERGE S            S                               */
 /**MERGE MESSAGEF     MESSAGE_FORMAT                  */
 /**MERGE GETLITER     GET_LITERAL                     */
 /**MERGE COMPAREL     COMPARE_LITERALS                */
 /**MERGE FILLDW       FILL_DW                         */
 /**MERGE SAVELITE     SAVE_LITERAL                    */
 /**MERGE GETLITON     GET_LIT_ONE                     */
 /**MERGE LITARITH     LIT_ARITHMETIC                  */
 /**MERGE COMBINED     COMBINED_LITERALS               */
 /**MERGE GENERATE     GENERATE_TEMPLATE_LIT           */
 /**MERGE TEMPLATE     TEMPLATE_LIT                    */
 /**MERGE PRINTTIM     PRINT_TIME                      */
 /**MERGE PRINTDAT     PRINT_DATE_AND_TIME             */
 /**MERGE REFERENC     REFERENCED                      */
 /**MERGE SETUPZAP     SETUP_ZAP_BY_TYPE               */
 /**MERGE INITIALI     INITIALISE                      */
 /**MERGE ENTER        ENTER                           */
 /**MERGE LASTOP       LAST_OP                         */
 /**MERGE RELOCATE     RELOCATE                        */
 /**MERGE MOVECODE     MOVECODE                        */
 /**MERGE PREPAREH     PREPARE_HALMAT                  */
 /**MERGE TWINHALM     TWIN_HALMATTED                  */
 /**MERGE GETFREES     GET_FREE_SPACE                  */
 /**MERGE PRINTSEN     PRINT_SENTENCE                  */
 /**MERGE SORTER       SORTER                          */
 /**MERGE SEARCHSO     SEARCH_SORTER                   */
 /**MERGE SYTP         SYTP                            */
 /**MERGE XHALMATQ     XHALMAT_QUAL                    */
 /**MERGE NAMEORPA     NAME_OR_PARM                    */
 /**MERGE ASSIGNTY     ASSIGN_TYPE                     */
 /**MERGE NOOPERAN     NO_OPERANDS                     */
 /**MERGE LASTOPER     LAST_OPERAND                    */
 /**MERGE CSEWORDF     CSE_WORD_FORMAT                 */
 /**MERGE DETAG        DETAG                           */
 /**MERGE DUMPVALI     DUMP_VALIDS                     */
 /**MERGE CSETABDU     CSE_TAB_DUMP                    */
 /**MERGE VU           VU                              */
 /**MERGE HALMATFL     HALMAT_FLAG                     */
 /**MERGE CONTROL      CONTROL                         */
 /**MERGE REVERSEP     REVERSE_PARITY                  */
 /**MERGE CONVERSI     CONVERSION_TYPE                 */
 /**MERGE NONCONSE     NONCONSEC                       */
 /**MERGE SETVAR       SET_VAR                         */
 /**MERGE LOOPOPER     LOOP_OPERANDS                   */
 /**MERGE MOVELIMB     MOVE_LIMB                       */
 /**MERGE PUSHHALM     PUSH_HALMAT                     */
 /**MERGE INTTOSCA     INT_TO_SCALAR                   */
 /**MERGE INSERTHA     INSERT_HALMAT_TRIPLE            */
 /**MERGE QUICKREL     QUICK_RELOCATE                  */
 /**MERGE PUTHALMA     PUT_HALMAT_BLOCK                */
 /**MERGE NEXTFLAG     NEXT_FLAG                       */
 /**MERGE SWITCH       SWITCH                          */
 /**MERGE FORMOPER     FORM_OPERATOR                   */
 /**MERGE FORMVAC      FORM_VAC                        */
 /**MERGE PTRTOVAC     PTR_TO_VAC                      */
 /**MERGE FORMTERM     FORM_TERM                       */
 /**MERGE EXTNCHEC     EXTN_CHECK                      */
 /**MERGE BUMPCSE      BUMP_CSE                        */
 /**MERGE BUMPADD      BUMP_ADD                        */
 /**MERGE SETNONCO     SET_NONCOMMUTATIVE              */
 /**MERGE CLASSIFY     CLASSIFY                        */
 /**MERGE TERMINAL     TERMINAL                        */
 /**MERGE TYPE         TYPE                            */
 /**MERGE GROUPCSE     GROUP_CSE                       */
 /**MERGE BUMPARIN     BUMP_AR_INV                     */
 /**MERGE GETADLP      GET_ADLP                        */
 /**MERGE ARRAYEDE     ARRAYED_ELT                     */
 /**MERGE SETARRAY     SET_ARRAYNESS                   */
 /**MERGE ZAPBIT       ZAP_BIT                         */
 /**MERGE INVAR        INVAR                           */
 /**MERGE LOOPY        LOOPY                           */
 /**MERGE VMDETAG      VM_DETAG                        */
 /**MERGE INITARCO     INIT_ARCONFS                    */
 /**MERGE POPCOMPA     POP_COMPARE                     */
 /**MERGE BUMPREFO     BUMP_REF_OPS                    */
 /**MERGE CSTACKDU     C_STACK_DUMP                    */
 /**MERGE CHECKADJ     CHECK_ADJACENT_LOOPS            */
 /**MERGE MOVELOOP     MOVE_LOOP_STACK                 */
 /**MERGE BUMPLOOP     BUMP_LOOPSTACK                  */
 /**MERGE PUSHLOOP     PUSH_LOOP_STACKS                */
 /**MERGE POPLOOPS     POP_LOOP_STACKS                 */
 /**MERGE COMBINEL     COMBINE_LOOPS                   */
 /**MERGE MULTIPLY     MULTIPLY_DIMS                   */
 /**MERGE DENEST       DENEST                          */
 /**MERGE CHECKARR     CHECK_ARRAYNESS                 */
 /**MERGE SETLOOPE     SET_LOOP_END                    */
 /**MERGE PUSHVMST     PUSH_VM_STACK                   */
 /**MERGE CHECKVMC     CHECK_VM_COMBINE                */
 /**MERGE SETVMTAG     SET_V_M_TAGS                    */
 /**MERGE CHECKLIS     CHECK_LIST                      */
 /**MERGE EMPTYARR     EMPTY_ARRAY                     */
 /**MERGE FINALPAS     FINAL_PASS                      */
 /**MERGE REFEREN2     REFERENCE                       */
 /**MERGE RELOCAT2     RELOCATE_HALMAT                 */
 /**MERGE ZAPTABLE     ZAP_TABLES                      */
 /**MERGE ZAPVARSB     ZAP_VARS_BY_TYPE                */
 /**MERGE NAMECHEC     NAME_CHECK                      */
 /**MERGE TERMCHEC     TERM_CHECK                      */
 /**MERGE STCHECK      ST_CHECK                        */
 /**MERGE ASSIGNME     ASSIGNMENT                      */
 /**MERGE CATALOGS     CATALOG_SRCH                    */
 /**MERGE CATALOGE     CATALOG_ENTRY                   */
 /**MERGE CATALOG      CATALOG                         */
 /**MERGE CATALOGV     CATALOG_VAC                     */
 /**MERGE SETOTV       SET_O_T_V                       */
 /**MERGE MODIFYVA     MODIFY_VALIDITY                 */
 /**MERGE ERASEZAP     ERASE_ZAPS                      */
 /**MERGE PUSHZAPS     PUSH_ZAP_STACK                  */
 /**MERGE POPZAPST     POP_ZAP_STACK                   */
 /**MERGE PUSHSTAC     PUSH_STACK                      */
 /**MERGE COPYDOWN     COPY_DOWN                       */
 /**MERGE POPSTACK     POP_STACK                       */
 /**MERGE ENDMULTI     END_MULTICASE                   */
 /**MERGE PROCESSL     PROCESS_LABEL                   */
 /**MERGE EXITCHEC     EXIT_CHECK                      */
 /**MERGE PREVENTP     PREVENT_PULLS                   */
 /**MERGE PRESCAN      PRESCAN                         */
 /**MERGE TABLENOD     TABLE_NODE                      */
 /**MERGE NOTTYPE      NOT_TYPE                        */
 /**MERGE ANDORTYP     ANDOR_TYPE                      */
 /**MERGE COMPARET     COMPARE_TYPE                    */
 /**MERGE TAGCONDI     TAG_CONDITIONALS                */
 /**MERGE SETSAV       SET_SAV                         */
 /**MERGE COMPUTED     COMPUTE_DIM_CONSTANT            */
 /**MERGE EXTRACTV     EXTRACT_VAR                     */
 /**MERGE COMPUTE2     COMPUTE_DIMENSIONS              */
 /**MERGE GENERAT2     GENERATE_DSUB_COMPUTATION       */
 /**MERGE CHECKCOM     CHECK_COMPONENT                 */
 /**MERGE EXPANDDS     EXPAND_DSUB                     */
 /**MERGE PUTVDLP      PUT_VDLP                        */
 /**MERGE INSERT       INSERT                          */
 /**MERGE GETLOOPD     GET_LOOP_DIMENSION              */
 /**MERGE SEARCHDI     SEARCH_DIMENSION                */
 /**MERGE PUTVMINL     PUT_VM_INLINE                   */
 /**MERGE CHICKENO     CHICKEN_OUT                     */
 /**MERGE SETFLAG      SET_FLAG                        */
 /**MERGE SETHALMA     SET_HALMAT_FLAG                 */
 /**MERGE SETVACRE     SET_VAC_REF                     */
 /**MERGE PUTNOP       PUT_NOP                         */
 /**MERGE FLAGVACO     FLAG_VAC_OR_LIT                 */
 /**MERGE FLAGVN       FLAG_V_N                        */
 /**MERGE FLAGMATC     FLAG_MATCHES                    */
 /**MERGE FLAGNODE     FLAG_NODE                       */
 /**MERGE FORCETER     FORCE_TERMINAL                  */
 /**MERGE PUSHOPER     PUSH_OPERAND                    */
 /**MERGE FORCEMAT     FORCE_MATCH                     */
 /**MERGE SETWORDS     SET_WORDS                       */
 /**MERGE COLLECTM     COLLECT_MATCHES                 */
 /**MERGE BOTTOM       BOTTOM                          */
 /**MERGE PUTBFNCT     PUT_BFNC_TWIN                   */
 /**MERGE REARRANG     REARRANGE_HALMAT                */
 /**MERGE SETUPREV     SETUP_REVERSE_COMPARE           */
 /**MERGE ELIMINAT     ELIMINATE_DIVIDES               */
 /**MERGE COLLAPSE     COLLAPSE_LITERALS               */
 /**MERGE PUTSHAPI     PUT_SHAPING_ARGS                */
 /**MERGE GROWTREE     GROW_TREE                       */
 /**MERGE SETUPREA     SETUP_REARRANGE                 */
 /**MERGE CSEMATCH     CSE_MATCH_FOUND                 */
 /**MERGE PURGEEXT     PURGE_EXTNS                     */
 /**MERGE STRIPNOD     STRIP_NODES                     */
 /**MERGE CHECKINV     CHECK_INVAR                     */
 /**MERGE EJECTINV     EJECT_INVARS                    */
 /**MERGE PULLINVA     PULL_INVARS                     */
 /**MERGE EXTRACTI     EXTRACT_INVARS                  */
 /**MERGE GETNODE      GET_NODE                        */
 /**MERGE OPTIMISE     OPTIMISE                        */
 /**MERGE PREPASS      PREPASS                         */
 /**MERGE PRINTSUM     PRINTSUMMARY                    */
                                                                                04282000
                                                                                04283000
 /* START OF MAIN PROGRAM*/                                                     04284000
MAIN_PROGRAM:                                                                   04285000
   CLOCK = MONITOR(18);                                                         04286000
   CALL INITIALISE;                                                             04287000
   OUTPUT(1) = '1';                                                             04289000
   CALL PRINT_DATE_AND_TIME('   HAL/S OPTIMIZER  --  VERSION OF '               04290000
      ,DATE_OF_GENERATION,TIME_OF_GENERATION);                                  04291000
   OUTPUT = '';                                                                 04292000
   CALL PRINT_DATE_AND_TIME('HAL/S OPTIMIZER ENTERED ',DATE,TIME);              04293000
   OUTPUT = '';                                                                 04294000
   CLOCK(1) = MONITOR(18);                                                      04296100
   DO WHILE OPTIMISING;                                                         04297000
      CALL NEW_HALMAT_BLOCK;                                                    04298000
      CALL PREPASS;                                                             04298010
      CALL PREPARE_HALMAT(1);      /* PHASE 2 OPTIMISE */                       04299000
      CALL OPTIMISE;                                                            04300000
      CALL ZAP_TABLES(1);                                                       04301000
      CALL PUT_HALMAT_BLOCK;                                                    04302000
   END;                                                                         04303000
   CLOCK(2) = MONITOR(18);                                                      04304000
   COMM(19) = CROSS_BLOCK_OPERATORS(1);                                         04304010
   IF LITCHANGE THEN FILE(LITFILE,CURLBLK) = LIT1(0);                           04305000
   IF STATISTICS THEN CALL PRINTSUMMARY;                                        04306000
   RECORD_FREE(COMMONSE_LIST);                                                  04307000
   RECORD_FREE(SYM_SHRINK);                                                     04307010
   RECORD_FREE(PAR_SYM);                                                        04307020
   RECORD_FREE(VAL_TABLE);                                                      04307030
   RECORD_FREE(OBPS);                                                           04307040
   RECORD_FREE(ZAPIT);                                                          04307050
   RECORD_FREE(STRUCT#);                                                        04307060
   RECORD_FREE(LEVEL_STACK_VARS);                                               04307070
   OUTPUT = '';                                                                 04307213
   CALL PRINT_DATE_AND_TIME('END OF HAL/S OPTIMIZER ',DATE,TIME);               04307233
   OUTPUT = '';                                                                 04307253
   IF ^ELEGANT_BUGOUT THEN CALL RECORD_LINK;                                    04307273
                                                                                04307313
DISASTER:
   IF MAX_SEVERITY >=2 THEN CALL DOWNGRADE_SUMMARY;  /*CR13273 DR111353*/       04307073
   RETURN COMMON_RETURN_CODE;                        /*DR111353*/               04311000

   EOF EOF EOF                                                                  04312000
