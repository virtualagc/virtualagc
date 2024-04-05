 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   OBJECTGE.xpl
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
 /* PROCEDURE NAME:  OBJECT_GENERATOR                                       */
 /* MEMBER NAME:     OBJECTGE                                               */
 /* LOCAL DECLARATIONS:                                                     */
 /*       ABSLIST_COUNT     BIT(16)            FTHREE            FIXED      */
 /*       ADDRESS_MOD       FIXED              FTWO              FIXED      */
 /*       AHEAD(3)          CHARACTER          GENERATE_OPERANDS CHARACTER  */
 /*       AHEADSET(1447)    LABEL              GET_RLD(1499)     LABEL      */
 /*       APAGE             BIT(16)            HEADOUT           BIT(8)     */
 /*       APRINT(1775)      LABEL              I_SQUARED         FIXED      */
 /*       ATITLE(3)         CHARACTER          ICC(3)            BIT(8)     */
 /*       BYTES_REMAINING   BIT(16)            INST_ADDRS        LABEL      */
 /*       CARD_COUNTER      FIXED              ITEMP             BIT(16)    */
 /*       CARDIMAGE         FIXED              L                 FIXED      */
 /*       CASE0004          LABEL              LEFTHEX           CHARACTER  */
 /*       CC(3)             CHARACTER          LINE_LIM          BIT(16)    */
 /*       COLUMN(79)        BIT(8)             NEW_FIRST_INST    LABEL      */
 /*       CURRENT_SIZE      BIT(16)            PRINT_LINE        LABEL      */
 /*       DATA_LIST_OFF     BIT(8)             RLD_ADDR          MACRO      */
 /*       DO_ADCONS         LABEL              RLD_CARD          FIXED      */
 /*       DO_HADCONS        LABEL              RLD_LINK          MACRO      */
 /*       DUMMY_CHAR        CHARACTER          RLD_POS_LINK      MACRO      */
 /*       EFFAD             CHARACTER          RLD_REF           MACRO      */
 /*       EMIT_CARD         LABEL              RLD#              BIT(16)    */
 /*       EMIT_ESD_CARDS    LABEL              RX_RS             LABEL      */
 /*       EMIT_RLD(1704)    LABEL              SET_ADDR_RHS      LABEL      */
 /*       EMIT_RLD_CARDS    LABEL              SHIFTCOUNT        BIT(16)    */
 /*       EMIT_SYM_CARDS    LABEL              SS_TYPE           LABEL      */
 /*       EMIT_TEXT_CARD(50)  LABEL            SYMCARD(20)       BIT(8)     */
 /*       END_CARD          FIXED              S1                CHARACTER  */
 /*       ESD_CARD          FIXED              S2                CHARACTER  */
 /*       ESD_CHAR(4)       CHARACTER          TAG_NAME          CHARACTER  */
 /*       FFOUR             FIXED              TEMP1             BIT(16)    */
 /*       FIRST_TIME        BIT(8)             TEXT_CARD         FIXED      */
 /*       FONE              FIXED              TEXT_SIZE         BIT(16)    */
 /*       FORM_BD           LABEL              XVERSION          MACRO      */
 /*       FORM_EFFAD        LABEL                                           */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*       ADDR                                 PROCLIMIT                    */
 /*       ANY_LABEL                            PROGBASE                     */
 /*       APOINTER                             PROGDELTA                    */
 /*       AP101INST                            P2SYMS                       */
 /*       ARRAY_LABEL                          QUOTE                        */
 /*       ASSEMBLER_CODE                       R_ADDR                       */
 /*       BASE_REGS                            R_BASE                       */
 /*       BIGHTS                               REMOTE_FLAG                  */
 /*       BLANK                                REMOTE_LEVEL                 */
 /*       CALL#                                RIGHTBRACKET                 */
 /*       CLASS_BI                             RLD_POS_HEAD                 */
 /*       COMMA                                RM                           */
 /*       COMM                                 R                            */
 /*       COMPOOL_LABEL                        SDBASE                       */
 /*       CONSTANT_PTR                         SDELTA                       */
 /*       CONSTANTS                            SDINDEX                      */
 /*       CURRENT_ADDRESS                      SDL                          */
 /*       DATA_REMOTE                          SELFNAMELOC                  */
 /*       DATE_OF_COMPILATION                  SHCOUNT                      */
 /*       DECK_REQUESTED                       SRSTYPE                      */
 /*       DESC                                 STMTNUM                      */
 /*       ESD_NAME_LENGTH                      SYM_ADDR                     */
 /*       ESD_TYPE                             SYM_BASE                     */
 /*       EXTRA_LISTING                        SYM_CONST                    */
 /*       FALSE                                SYM_DISP                     */
 /*       FSIMBASE                             SYM_FLAGS                    */
 /*       HEXCODES                             SYM_LEVEL                    */
 /*       IAL                                  SYM_LINK1                    */
 /*       INST                                 SYM_LINK2                    */
 /*       INTEGER                              SYM_LOCK#                    */
 /*       LAB_LOC                              SYM_NAME                     */
 /*       LABEL_ARRAY                          SYM_SCOPE                    */
 /*       LDM                                  SYM_TYPE                     */
 /*       LEFTBRACKET                          SYMBREAK                     */
 /*       LFXI                                 SYT_ADDR                     */
 /*       LINK_LOCATION                        SYT_BASE                     */
 /*       LIT_TOP                              SYT_CONST                    */
 /*       LITERAL1                             SYT_DISP                     */
 /*       LITERAL2                             SYT_FLAGS                    */
 /*       LITERAL3                             SYT_LABEL                    */
 /*       LIT1                                 SYT_LEVEL                    */
 /*       LIT2                                 SYT_LINK1                    */
 /*       LIT3                                 SYT_LINK2                    */
 /*       LOCAT                                SYT_LOCK#                    */
 /*       LOCATION                             SYT_NAME                     */
 /*       LOCATION_LINK                        SYT_SCOPE                    */
 /*       LOCREL                               SYT_TYPE                     */
 /*       MAXTEMP                              TEMPBASE                     */
 /*       NAME_FLAG                            THISPROGRAM                  */
 /*       NEGMAX                               TIME_OF_COMPILATION          */
 /*       OFFSET                               TOGGLE                       */
 /*       OPTION_BITS                          TRUE                         */
 /*       ORIGIN                               TYP_SIZE                     */
 /*       PLUS                                 VALS                         */
 /*       POINTER_OR_NAME                      X2                           */
 /*       PROC_LEVEL                           X4                           */
 /*       PROCBASE                             X72                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*       AM                                   IA                           */
 /*       B                                    INDEXNEST                    */
 /*       CODE_LINE                            IX                           */
 /*       CODE_LISTING_REQUESTED               LASTBASE                     */
 /*       CURRENT_ESDID                        LHS                          */
 /*       DATABASE                             LIT_PG                       */
 /*       DUMMY                                LOCCTR                       */
 /*       D                                    MAX_CODE_LINE                */
 /*       EMITTING                             OP2                          */
 /*       ENTRYPOINT                           PROGPOINT                    */
 /*       ERRSEG                               RHS                          */
 /*       ESD_LINK                             STACKSPACE                   */
 /*       ESD_MAX                              SYM_TAB                      */
 /*       FIRST_INST                           TEMP                         */
 /*       F                                    TMP                          */
 /*       GENERATING                           WORKSEG                      */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*       EMIT_ADDRS                           MIN                          */
 /*       ENTER_ESD                            NEXT_REC                     */
 /*       ERRORS                               PAD                          */
 /*       ESD_TABLE                            REAL_LABEL                   */
 /*       GET_INST_R_X                         SET_MASKING_BIT              */
 /*       GET_LITERAL                          SKIP                         */
 /*       INSTRUCTION                          SKIP_ADDR                    */
 /* CALLED BY:                                                              */
 /*       TERMINATE                                                         */
 /***************************************************************************/
 /*********                          CALL TREE                      *********/
 /***************************************************************************/
 /* ==> OBJECT_GENERATOR <==                                                */
 /*     ==> MIN                                                             */
 /*     ==> PAD                                                             */
 /*     ==> INSTRUCTION                                                     */
 /*         ==> CHAR_INDEX                                                  */
 /*         ==> PAD                                                         */
 /*     ==> ESD_TABLE                                                       */
 /*     ==> ENTER_ESD                                                       */
 /*         ==> PAD                                                         */
 /*     ==> GET_LITERAL                                                     */
 /*         ==> MAX                                                         */
 /*     ==> ERRORS                                                          */
 /*         ==> NEXTCODE                                                    */
 /*             ==> DECODEPOP                                               */
 /*                 ==> FORMAT                                              */
 /*                 ==> HEX                                                 */
 /*                 ==> POPCODE                                             */
 /*                 ==> POPNUM                                              */
 /*                 ==> POPTAG                                              */
 /*             ==> AUX_SYNC                                                */
 /*                 ==> GET_AUX                                             */
 /*                 ==> AUX_LINE                                            */
 /*                     ==> GET_AUX                                         */
 /*                 ==> AUX_OP                                              */
 /*                     ==> GET_AUX                                         */
 /*         ==> RELEASETEMP                                                 */
 /*             ==> SETUP_STACK                                             */
 /*             ==> CLEAR_REGS                                              */
 /*                 ==> SET_LINKREG                                         */
 /*         ==> COMMON_ERRORS                                               */
 /*     ==> SET_MASKING_BIT                                                 */
 /*         ==> PTR_LOCATE                                                  */
 /*         ==> LOCATE                                                      */
 /*         ==> ERRORS ****                                                 */
 /*     ==> EMIT_ADDRS                                                      */
 /*         ==> DISP                                                        */
 /*         ==> LOCATE                                                      */
 /*         ==> ERRORS ****                                                 */
 /*     ==> NEXT_REC                                                        */
 /*         ==> GET_CODE                                                    */
 /*     ==> SKIP                                                            */
 /*     ==> SKIP_ADDR                                                       */
 /*         ==> GET_CODE                                                    */
 /*         ==> NEXT_REC ****                                               */
 /*         ==> SKIP                                                        */
 /*     ==> REAL_LABEL                                                      */
 /*     ==> GET_INST_R_X                                                    */
 /*                                                                         */
 /*                                                                         */
 /*  **** - BRANCH PREVIOUSLY EXPANDED                                      */
 /***************************************************************************/
 /* REVISION HISTORY                                                        */
 /* ----------------                                                        */
 /*   DATE    NAME   REL   DR NUMBER AND TITLE                              */
 /*                                                                         */
 /* 08/17/90  SMY   23V1   103768 NAME VARIBLES IN REMOTE STRUCTURES        */
 /*                                                                         */
 /* 01/21/91  DKB   23V2   CR11098 DELETE SPILL CODE FROM COMPILER          */
 /*                                                                         */
 /* 03/04/91  RAH   23V2   CR11109 CLEANUP OF COMPILER SOURCE CODE          */
 /*                                                                         */
 /* 01/07/91  PMA   23V2   CR11094 INCLUDED REMOTE COMPOOL ESD CARD MOD     */
 /*                                                                         */
 /* 07/09/91  RSJ   24V0   CR11096 #DFLAG - SET BLANK ESD FEILD FOR         */
 /*                                MODULES WITH DATA_REMOTE ON              */
 /*                                                                         */
 /* 07/15/91  DAS   24V0   CR11096 #DDSE - PRINT LDM IN ASSEMBLY LIST       */
 /*                                                                         */
 /* 09/05/91  DAS   24V0   CR11120 #DFLAG NEW REQUIRMENT - CLEAR THE        */
 /*                                REMOTE FLAG OF MODULE                    */
 /*                                                                         */
 /* 05/07/92  JAC    7V0   CR11114 MERGE BFS/PASS COMPILERS                 */
 /*                                                                         */
 /* 05/12/92  PMA    7V0   DR101925 BFS OBJECT DIRECTED TO INCORRECT        */
 /*                                 OUTPUT FILE                             */
 /*                                                                         */
 /* 12/23/92  PMA    8V0   *       MERGED 7V0 AND 24V0 COMPILERS.           */
 /*                                * REFERENCE 24V0 CR/DRS.                 */
 /*                                                                         */
 /* 10/7/93   RSJ    26V0/ DR106757 INSTRUCTION COUNT FREQUENCIES           */
 /*                  10V0           INCORRECT                               */
 /*                                                                         */
 /* 11/02/93  DKB   25V1,  DR106968 INCORRECT RLD (APPLIED CHANGE FROM      */
 /*                  9V1            24V2 USING CCC, CHANGE NOT IN           */
 /*                                 25V0/9V0)                               */
 /* 06/16/95  TMP   27V0   CR12385  ADD PERMANENT TRAPS TO THE COMPILER     */
 /*                 11V0                                                    */
 /*                                                                        */
 /* 12/05/94  DAS  27V0/ 107698 ILLEGAL DISPLACEMENT VALUE IN INDEXED      */
 /*                11V0         RS INSTUCTION (DO CASE)                    */
 /*                                                                         */
 /* 06/22/95  DAS    27V0/ CR12416  IMPROVE COMPILER ERROR PROCESSING       */
 /*                  11V0                                                   */
 /*                                                                         */
 /* 01/15/97  SMR/   28V0/ CR12713  ENHANCE COMPILER LISTINGS               */
 /*           TMP    12V0                                                   */
 /*                                                                         */
 /* 01/24/97  DCP   28V0/ CR12714   ADD INTERNAL COMPILER ERROR CHECKING    */
 /*                 12V0                                                    */
 /*                                                                         */
 /* 11/07/96  DCP  28V0  DR103798  ESD ENTRY FOR $0CSECT WRONG              */
 /*                                                                         */
 /* 10/03/96  DCP   28V0  DR105392   MISSING OPERAND FOR LDM                */
 /*                 12V0                                                    */
 /*                                                                         */
 /* 01/05/98  DCP   29V0/ CR12940    ENHANCE COMPILER LISTING               */
 /*                 14V0                                                    */
 /*                                                                         */
 /* 10/22/97  TMP   29V0/  CR12891  HAL/S-FC PASS COMPILER YEAR 2000        */
 /*                 14V0            UPDATE                                  */
 /*                                                                         */
 /* 04/08/99  SMR   30V0/ CR13079    ADD HAL/S INITIALIZATION DATA          */
 /*                 15V0             TO SDF                                 */
 /*                                                                         */
 /* 04/26/01  DCP   31V0/ CR13335    ALLEVIATE SOME DATA SPACE PROBLEMS     */
 /*                 16V0             IN HAL/S COMPILER                      */
 /*                                                                         */
 /* 09/16/98  DCP   30V0/ DR111316  RLD TABLE WRONG IN BFS FOR ASMLSTS      */
 /*                 15V0                                                    */
 /*                                                                         */
 /* 03/01/01  DCP   31V0/ DR111367  ABEND OCCURS FOR A                      */
 /*                 16V0            MULTI-DIMENSIONAL ARRAY                 */
 /*                                                                         */
 /* 03/06/02  TKN   32V0/ CR13554   USE TITAN SYSTEMS CORP INSTEAD OF       */
 /*                 17V0            INTERMETRICS                            */
 /*                                                                         */
 /***************************************************************************/
                                                                                07253550
                                                                                07253600
                                                                                07273000
OBJECT_GENERATOR:PROCEDURE;                                                     07273500
      DECLARE                                                                   07274000
         ADDRESS_MOD FIXED INITIAL (0),                                         07275000
 /?B     /* CR11114 -- BFS/PASS INTERFACE; CHANGE #Z TO SEPARATE OBJ. */
         HAL_NAME_CHARS CHARACTER,
 ?/
         FONE FIXED INITIAL ("0000000F"),                                       07276500
         FTWO FIXED INITIAL ("000000FF"),                                       07277000
         FTHREE FIXED INITIAL ("00000FFF"),                                     07277500
         FFOUR FIXED INITIAL ("0000FFFF"),                                      07278000
         TEXT_CARD FIXED INITIAL ("02E3E7E3"),                                  07278500
         RLD_CARD  FIXED INITIAL ("02D9D3C4"),                                  07279000
         END_CARD FIXED INITIAL ("02C5D5C4"),                                   07279500
         ESD_CARD FIXED INITIAL ("02C5E2C4"),                                   07280000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
         CARD_COUNTER FIXED INITIAL (10000),                                    07280500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
         CARD_COUNTER BIT(16) INITIAL(0),
 ?/
         I_SQUARED FIXED INITIAL ("C95C5CF2");                                  07281000
      DECLARE XVERSION LITERALLY                                                07281500
    'SUBSTR(XPL_COMPILER_VERSION+100,1)||SUBSTR(XPL_COMPILER_VERSION(1)+100,1)';07281510
      DECLARE ATITLE(3) CHARACTER INITIAL (                                     07282500
 '                                                                            ',07283000
 '                                              EXTERNAL SYMBOL DICTIONARY    ',07283500
 '                                                 RELOCATION DICTIONARY      ',07284000
'                                  DIAGNOSTIC CROSS REFERENCE AND SUMMARY    '),07284500
         AHEAD(3) CHARACTER INITIAL (                                           07285000
'2  LOC    CODE        EFFAD           LABEL   INSN   OPERANDS            SYMBOL07285500
IC OPERAND',  /*CR12940 - REMOVE 3 SPACES BETWEEN OPERANDS & SYMBOLIC*/         07286000
 /*CR12713 - ADD LENGTH IN DECIMAL TO OUTPUT.                                */
 /?P  /* CR11114 -- BFS/PASS INTERFACE; ASSEMBLER LISTING FORMAT */
 '2SYMBOL   TYPE  ID  ADDR  LEN(HEX)  LEN(DEC)         BLOCK NAME', /*CR12713*/ 07286500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ASSEMBLER LISTING FORMAT */
 /*CR12713*/
'2SYMBOL   TYPE  ID  ADDR  LEN(HEX)  LEN(DEC)  ENT ID  BLOCK NAME/LEC TEXT',
 ?/
          /* CR12713 - ADD CSECT NAMES TO RLD TABLE */
         '2 POS.ID    CSECT(P)    ADDRESS   FLAGS      REL.ID    CSECT(R)' ,    07287000
         '2'),                                                                  07287500
         CC(3) CHARACTER INITIAL ('1',' ','0','-'),                             07288000
         ICC(3) BIT(8) INITIAL ("8B", "09", "11", "19"),                        07288500
         APAGE BIT(16),                                                         07289000
         ABSLIST_COUNT BIT(16),                                                 07289500
         LINE_LIM BIT(16) INITIAL(59);                                          07290000
      DECLARE ESD_CHAR(4) CHARACTER INITIAL('SD','LD','ER','','PC'),            07290500
         SYMCARD(TYP_SIZE) BIT(8) INITIAL (                                     07291000
    0,"14",0,"18","18","18","14","24",0,"10",0,"1C","1C","1C","10",0,"14","14"); 7291500
      DECLARE EFFAD CHARACTER;                                                  07292000
      DECLARE                                                                   07292500
         RLD# BIT(16),                                                          07293000
         RLD_REF LITERALLY 'LIT1',                                              07293500
         RLD_ADDR LITERALLY 'LIT2',                                             07294000
         RLD_LINK LITERALLY 'LIT3',                                             07294500
         RLD_POS_LINK LITERALLY 'INDEXNEST',                                    07295500
         DATA_LIST_OFF BIT(1),                                                  07296000
         HEADOUT BIT(1);                                                        07296500
      DECLARE                                                                   07297000
         L FIXED;                                                               07297500
      DECLARE                                                                   07298000
         S1 CHARACTER,                                                          07298500
         S2 CHARACTER,                                                          07299000
         TAG_NAME CHARACTER;                                                    07300000
      DECLARE                                                                   07300500
         TEMP1 BIT(16),                                                         07300610
         ITEMP BIT(16),                                                         07301000
         SHIFTCOUNT BIT(16);                                                    07301500
      DECLARE                                                                   07303500
 /?P     /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
         TEXT_SIZE BIT(16) INITIAL(56),                                         07302500
         DUMMY_CHAR CHARACTER,                                                  07299500
         CURRENT_SIZE BIT(16),                                                  07303000
         BYTES_REMAINING BIT(16),                                               07302000
         CARDIMAGE FIXED INITIAL (0),                                           07304000
         COLUMN(79) BIT(8);                                                     07304500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
        CARD_IMAGE(254)                BIT(16),
        RECORD_ID                      LITERALLY 'CARD_IMAGE',
        #TEXT_HALFWORDS_USED           BIT(16) INITIAL(0);
 ?/
      DECLARE                                                                   07305000
         FIRST_TIME BIT(1) INITIAL ("01");                                      07305500
      DECLARE MVH_COUNT(8) BIT(16), MVH_CNT_KNOWN(8) BIT(1);         /*CR12940*/
    /**************************************************************************/
    /* THE RESULTANT CONDITION CODE FOR EACH INSTRUCTION             /*CR12940*/
    /*  =0     CC UNALTERED OR SPECIAL (MVS OR SPM)                  /*CR12940*/
    /*  =1     ARITHMETIC CC                                         /*CR12940*/
    /*  =2     LOGICAL CC                                            /*CR12940*/
    /*  =3     COMPARE CC                                            /*CR12940*/
    /*  =4     TEST BITS CC                                          /*CR12940*/
    /**************************************************************************/
      DECLARE CC_TYPE BIT(16);                                       /*CR12940*/
      ARRAY INST_CC(OPMAX) BIT(4) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 0, /*CR12940*/
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 2, 2, 1, 3, 1, 1, 0, 0, /*CR12940*/
      0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, /*CR12940*/
      1, 0, 0, 0, 1, 1, 3, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, /*CR12940*/
      1, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 2, 1, 3, 1, 1, 0, /*CR12940*/
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 1, 1, 0, 0, 0, 0, 0, 0, /*CR12940*/
      0, 0, 0, 0, 0, 0, 1, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, /*CR12940*/
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 4, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, /*CR12940*/
      0, 0, 0, 0, 0, 4, 0, 0, 2, 0, 2, 2, 0, 3, 1, 0, 0, 0, 2, 0, 0, /*CR12940*/
      4, 0, 4, 2, 0, 2, 2, 0, 3, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, /*CR12940*/
      2, 2, 0, 0, 1, 1, 0, 0);                                       /*CR12940*/
                                                                                07307500
/*CR13079 - PLACE A ZERO IN THE INIT_VAL LOCATIONS FROM FIRST TO LAST*/
ZERO_INIT_VAL:PROCEDURE(FIRST,LAST);
  DECLARE (FIRST,LAST,IDX) FIXED;      /*DR111367*/
     DO FOR IDX = FIRST TO LAST;
        NEXT_ELEMENT(INIT_TAB);
        INIT_VAL(IDX) = 0;
     END;
END ZERO_INIT_VAL;

 /* CR12940 - PROCEDURE TO FIND THE ALTERNATE CONDITIONAL BRANCH */
 /*           MNEMONIC BASED ON THE CONDITION CODE AND M1 FIELD. */
BC_ALT_MNEMONIC:PROCEDURE(TYPE, M) CHARACTER;
      DECLARE TYPE BIT(4);
      DECLARE M BIT(8);
      DECLARE STR#  BIT(16);
      DECLARE OPCODES101_EXT(5) CHARACTER INITIAL(
      'NOPR  BHR   BLR   BNER  BER   BNLR  BLER  BR    ',
      'NOPR  BPR   BMR   BNZR  BZR   BNMR  BNPR  BR    ',
      'NOPR  BOR   BMR   BNZR  BZR         BNOR  BR    ',
      'NOP   BH    BL    BNE   BE    BNL   BLE   B     ',
      'NOP   BP    BM    BNZ   BZ    BNM   BNP   B     ',
      'NOP   BO    BM    BNZ   BZ          BNO   B     ');

      IF (INST = BCR) | (INST = BCRE) THEN STR# = 0;
      ELSE STR# = 3;
      IF (TYPE=1) | (TYPE=2) THEN
        STR# = STR# + 1;
      ELSE IF (TYPE=4) THEN
        STR# = STR# + 2;
      M = M * 6;
      RETURN SUBSTR(OPCODES101_EXT(STR#),M,6);
   END;

AHEADSET:PROCEDURE(N);                                                          07308000
         DECLARE N BIT(16);                                                     07308500
         APAGE = N;                                                             07309000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; MAKE 'AB' & 'L' INDEPENDENT */
         IF CODE_LISTING THEN DO;
 ?/
            OUTPUT(1) = AHEAD(N);                                               07309500
            OUTPUT(1) = '1';                                                    07310000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; MAKE 'AB' & 'L' INDEPENDENT */
         END;
 ?/
         ABSLIST_COUNT = LINE_LIM;                                              07310500
      END AHEADSET;                                                             07311000
                                                                                07311500
APRINT:PROCEDURE(LINE);                                                         07312000
         DECLARE LINE CHARACTER, (PAGE_NUM, I) BIT(16);                         07312500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; MAKE 'AB' & 'L' INDEPENDENT */
         IF CODE_LISTING THEN
 ?/
         OUTPUT(1) = LINE;                                                      07313000
         IF EXTRA_LISTING THEN DO;                                               7313500
            ABSLIST_COUNT = ABSLIST_COUNT + 1;                                  07314000
            IF ABSLIST_COUNT > LINE_LIM THEN DO;                                07314500
               IF PAGE_NUM = 0 THEN DO;                                         07315000
                  LINE_LIM = VALS(1);                                           07315500
                  DO I = 0 TO 3;                                                07316000
                     BYTE(CC(I)) = ICC(I);                                      07316500
                  END;                                                          07317000
               END;                                                             07317500
               PAGE_NUM = PAGE_NUM + 1;                                         07318000
               OUTPUT(7) = CC;                                                  07318500
               OUTPUT(7) = CC(3) || ATITLE(APAGE) ||                            07319000
                  '                                   PAGE ' || PAGE_NUM;       07319500
               OUTPUT(7) = CC(2) || SUBSTR(AHEAD(APAGE), 1);                    07320000
               ABSLIST_COUNT = 6;                                               07320500
            END;                                                                07321000
            OUTPUT(7) = CC(1) || SUBSTR(LINE, 1);                               07321500
         END;                                                                   07322000
      END APRINT;                                                               07322500
                                                                                07323000
LEFTHEX:PROCEDURE(F,N)CHARACTER;                                                07323500
         DECLARE F FIXED,                                                       07324000
            N BIT(16),                                                          07324500
            (K, B) BIT(16), SS CHARACTER INITIAL ('        ');                  07325000
         K = 0;                                                                 07325500
         SHIFTCOUNT=28;                                                         07326000
         DO WHILE N>0;                                                          07326500
            B=BYTE(HEXCODES,SHR(F,SHIFTCOUNT)&FONE);                            07327000
            BYTE(SS,K)=B;                                                       07327500
            K=K+1;                                                              07328000
            N=N-1;                                                              07328500
            SHIFTCOUNT=SHIFTCOUNT-4;                                            07329000
         END;                                                                   07329500
         RETURN BLANK||SUBSTR(SS,0,K);                                          07330000
      END LEFTHEX;                                                              07330500
                                                                                07331000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
EMIT_CARD:PROCEDURE;                                                            07331500
         IF FIRST_TIME THEN DO;                                                 07332000
 /* TEMP CODE*/ COREWORD(ADDR(DUMMY_CHAR))=(ADDR(COLUMN) | "4F000000");         07332500
 /* THIS WILL MAKE LIKE DUMMY_CHAR HAD BEEN ALLOCATED AN 80-BYTE FIELD*/        07333000
            FIRST_TIME="00";                                                    07333500
 /*COREWORD(ADDR(DESCRIPTOR))=(ADDR(COLUMN) | "4F000000");                      07334000
         COREWORD(ADDR(DUMMY_CHAR))=ADDR(DESCRIPTOR);*/                         07334500
         END;                                                                   07335000
         ELSE DO;                                                               07335500
            IF (BYTES_REMAINING-CURRENT_SIZE)*CARDIMAGE=0 THEN RETURN;          07336000
            IF CARDIMAGE ^= END_CARD THEN                                       07336500
               CARDIMAGE(3)="40400000"+CURRENT_SIZE-BYTES_REMAINING;            07337000
            /* CR12416: INHIBIT OBJECT GENERATION IF ERRORS OCCURRED */         07337500
            IF MAX_SEVERITY = 0 THEN DO;              /* CR12416 */             07337500
               OUTPUT(3) = DUMMY_CHAR;                                          07337500
               IF DECK_REQUESTED THEN                                           07338000
                  OUTPUT(4) = DUMMY_CHAR;                                       07338500
            END;                                      /* CR12416 */             07339000
         END;                                                                   07339000
         CARDIMAGE = 0;                                                         07339500
         DO TEMP=1 TO 18;                                                       07340000
            CARDIMAGE(TEMP)="40404040";                                         07340500
         END;                                                                   07341000
         CARDIMAGE(19)=I_SQUARED;                                               07341500
         CARD_COUNTER=CARD_COUNTER+1;                                           07342000
         S1=CARD_COUNTER;                                                       07342500
         S1=SUBSTR(S1,LENGTH(S1)-4,4);                                          07343000
         CALL INLINE ("58",1,0,S1);    /*LOAD DESCRIPTOR*/                      07343500
         CALL INLINE ("41",2,0,COLUMN);    /*ADDRESS OF RECEIVING FIELD*/       07344000
         CALL INLINE ("D2",0,3,2,76,1,0); /*MVC 76(4,2);,0(1);*/                07344500
      END EMIT_CARD;                                                            07345000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */

         /* ROUTINE TO MOVE BYTES FORM ONE LOCATION TO ANOTHER */

MOVE_CHARS: PROCEDURE(FROM_ADDR, TO_ADDR, BYTE_COUNT);

DECLARE
        FROM_ADDR                      FIXED,
        TO_ADDR                        FIXED,
        BYTE_COUNT                     BIT(16),
        MVC_INSTRUCTION(1)             FIXED
           INITIAL("D2002000","10000000");

   IF BYTE_COUNT = 0 THEN
      RETURN;
   ELSE
      BYTE_COUNT = BYTE_COUNT - 1;
   CALL INLINE("58", 1, 0, FROM_ADDR);
   CALL INLINE("58", 2, 0, TO_ADDR);
   CALL INLINE("48", 3, 0, BYTE_COUNT);
   CALL INLINE("44", 3, 0, MVC_INSTRUCTION);

END MOVE_CHARS;


         /* ROUTINE TO EMIT AN OBJECT CARD */

EMIT_CARD: PROCEDURE(FLUSH_SWITCH);

DECLARE
        FLUSH_SWITCH                   BIT(1),
        DUMMY_CHAR                     CHARACTER,
        HEX_OF_TWO_BLANKS              LITERALLY '"4040"',
        #HALFWORDS_IN_CARD             BIT(16) INITIAL(0),
        #HALFWORDS_TO_BE_EMITTED       BIT(16),
        HALFWORD_TO_BE_EMITTED         BIT(16);

ARRAY
        FORTY_HALFWORD_CARD(39)        BIT(16);

      IF FIRST_TIME THEN DO;                                                    07332000
      COREWORD(ADDR(DUMMY_CHAR)) = ADDR(FORTY_HALFWORD_CARD) | "4F000000";
      FIRST_TIME = FALSE;
         END;                                                                   07335000

   #HALFWORDS_TO_BE_EMITTED = RECORD_ID & FTWO;
   IF #HALFWORDS_TO_BE_EMITTED = 0 THEN
      GO TO DO_RETURN;
   CARD_COUNTER = CARD_COUNTER + 1;
   HALFWORD_TO_BE_EMITTED = 0;

   DO WHILE HALFWORD_TO_BE_EMITTED < #HALFWORDS_TO_BE_EMITTED;

      DO WHILE #HALFWORDS_IN_CARD < 40;
         FORTY_HALFWORD_CARD(#HALFWORDS_IN_CARD) =
            CARD_IMAGE(HALFWORD_TO_BE_EMITTED);
         #HALFWORDS_IN_CARD = #HALFWORDS_IN_CARD + 1;
         HALFWORD_TO_BE_EMITTED = HALFWORD_TO_BE_EMITTED + 1;
         IF HALFWORD_TO_BE_EMITTED >= #HALFWORDS_TO_BE_EMITTED THEN DO;
            IF FLUSH_SWITCH THEN DO;
               IF #HALFWORDS_IN_CARD < 40 THEN
                  DO FOR #HALFWORDS_IN_CARD = #HALFWORDS_IN_CARD TO 39;
                     FORTY_HALFWORD_CARD(#HALFWORDS_IN_CARD) =
                        HEX_OF_TWO_BLANKS;
                  END;
               GO TO DO_OUTPUT;
            END;
            ELSE
               GO TO DO_RETURN;
         END;
      END;

   DO_OUTPUT:
      IF MAX_SEVERITY = 0 THEN DO;
         OUTPUT(3) = DUMMY_CHAR;    /* DR101925 - P. ANSLEY, 5/12/92 */
            IF DECK_REQUESTED THEN                                              07338000
               OUTPUT(4) = DUMMY_CHAR;                                          07338500
         END;                                                                   07339000
      #HALFWORDS_IN_CARD = 0;
         END;                                                                   07341000
DO_RETURN:
   FLUSH_SWITCH = 0;

      END EMIT_CARD;                                                            07345000
 ?/

/* CR12713 - RS INSTRUCTIONS WITH A BASE OF 3 USE THE DISPLACEMENT AS THE     */
/* EFFECTIVE ADDRESS.  THIS ROUTINE BUILDS A STRING FOR GENERATE_OPERANDS     */
/* THAT CONTAINS JUST PARENTHESIS FOR THIS CASE (TO INDICATE NO BASE IS       */
/* USED), OR THE REGISTER IN PARENTHESIS IF NOT THIS CASE.                    */
CHECK_NO_BASE_RS: PROCEDURE CHARACTER;
         IF LHS ^= SRSTYPE & B = 3 THEN
            RETURN( LEFTBRACKET||RIGHTBRACKET );
         ELSE
            RETURN( LEFTBRACKET||'R'||B||RIGHTBRACKET);
       END CHECK_NO_BASE_RS;

                                                                                07345500
GENERATE_OPERANDS:PROCEDURE CHARACTER;                                          07346000
         DECLARE T CHARACTER;                                                   07346500
     /* CR12940 - PROCEDURE TO FIND THE EXECUTION TIME FOR EACH */
     /*           INSTRUCTION GENERATED                         */
EXECUTION_TIMES:PROCEDURE(M);
    DECLARE M BIT(4);
    DECLARE TIMES(94) CHARACTER INITIAL('0', '0.25', '0.5', '0.75', '1.0',
       '1.2', '1.35', '1.5', '1.7', '1.75', '2.0', '2.15', '2.25', '2.4',
       '2.5', '3.0', '3.25', '3.75', '4.0', '4.25', '4.5', '4.675', '4.75',
       '4.925', '5.0', '5.23', '5.25', '5.5', '5.58', '5.75', '6.0', '6.03',
       '6.25', '6.28', '6.5', '6.75', '7.0', '7.25', '7.5', '7.55', '7.75',
       '7.98', '8.0', '8.025', '8.25', '8.5', '8.75', '8.8', '9.0', '9.5',
       '9.75', '10.0', '10.05', '10.25', '10.28', '10.5', '10.53', '11.5',
       '11.75', '11.8', '12.0', '12.5', '12.75', '13.25', '13.5', '14.25',
       '15.25', '16.25', '17.5', '18.125', '18.5', '19.0', '20.25', '22.25',
       '22.5', '22.75', '23.0', '24.0', '24.5', '25.0', '25.75', '26.75',
       '27.75', '29.75', '12.0+.875(N-1) (SEE POO)', 'BT=5.75, BNT=.50',
       'BT=3.50, BNT=4.50', 'BT=1.75, BNT=.750', 'BT=1.25, BNT=.50',
       'BT=2.5, BNT=1.5', 'BT=1.25, BNT=.250', '.650+(0.1*', '1.0+(0.25*',
       '.675+(0.1*', '1.0+(0.1*');

    ARRAY NORMAL_TIMES(OPMAX) BIT(8) INITIAL(0, 0, 3, 3, 26, 86, 87, 1, 0,
       0, 0, 0, 0, 68, 84, 85, 0, 0, 0, 2, 1, 0, 1, 1, 1, 1, 1, 1, 13, 23,
       0, 12, 0, 0, 0, 0, 0, 0, 0, 32, 0, 7, 32, 32, 70, 75, 0, 0, 0, 0, 0,
       4, 0, 0, 0, 12, 4, 7, 12, 12, 30, 37, 0, 9, 2, 1, 88, 2, 89, 17, 87,
       90, 1, 1, 1, 1, 6, 69, 8, 2, 2, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 13,
       23, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 7, 29, 34, 34, 71, 76, 0, 0, 2, 0,
       0, 0, 0, 0, 0, 0, 5, 9, 14, 14, 32, 38, 22, 0, 0, 0, 88, 0, 0, 0, 87,
       1, 91, 93, 91, 0, 94, 92, 92, 0, 37, 9, 0, 17, 0, 0, 7, 0, 45, 0, 72,
       15, 0, 0, 7, 0, 0, 4, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 6, 0, 1, 0, 0,
       10, 0, 15, 15, 0, 15, 15, 0, 7, 15, 0, 0, 0, 16, 0, 0, 0, 0, 0, 3, 0,
       3, 3, 0, 0, 3, 4, 35, 91);

    ARRAY INDIRECT_TIMES(OPMAX) BIT(8) INITIAL(0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 17, 17, 20, 27, 51, 19, 18, 19,
      19, 19, 19, 25, 78, 28, 17, 20, 0, 0, 0, 20, 0, 20, 20, 19, 19, 19,
      19, 33, 47, 0, 0, 24, 0, 0, 0, 0, 0, 0, 0, 24, 49, 53, 55, 73, 82,
      0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 22, 29, 34, 20, 53, 57, 48, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 51, 24, 0, 32, 0, 0, 19,
      0, 60, 0, 74, 27, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 29, 0, 29, 29, 0, 0, 29, 0, 51, 0);

    ARRAY INDEX_TIMES(OPMAX) BIT(8) INITIAL(0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 45, 42, 34, 37, 44, 49, 36, 32, 36,
      36, 36, 37, 41, 77, 43, 42, 48, 0, 0, 0, 34, 0, 34, 38, 37, 37, 37,
      37, 56, 59, 0, 0, 38, 0, 0, 0, 0, 0, 0, 0, 46, 61, 63, 64, 80, 83,
      0, 0, 38, 0, 0, 0, 0, 0, 0, 0, 45, 45, 48, 49, 63, 66, 58, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65, 40, 0, 48, 0, 0, 45,
      0, 67, 0, 81, 44, 0, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 53, 0, 53, 53, 0, 0, 53, 0, 53, 0);

    IF TAG_NAME ^= '' THEN TAG_NAME = '; '||TAG_NAME;

    DO CASE M;

    /* RR = 0 */
       DO;
         IF (INST=MR) & (R MOD 2 ^= 0) THEN
           TAG_NAME = TIMES(11)||TAG_NAME;
         ELSE IF (INST=29 /*DR*/) & (R MOD 2 ^= 0) THEN
           TAG_NAME = TIMES(21)||TAG_NAME;
         ELSE IF (INST=60 /*MER*/) & (R MOD 2 ^= 0) THEN
           TAG_NAME = TIMES(27)||TAG_NAME;
         ELSE IF (INST = MVH) THEN DO;
           IF MVH_CNT_KNOWN(R) THEN DO;
             IF MVH_COUNT(R) = 1 THEN
               TAG_NAME = '11.25'||TAG_NAME;
             ELSE IF MVH_COUNT(R) = 0 THEN
               TAG_NAME = '7.75'||TAG_NAME;
             ELSE IF MVH_COUNT(R) < 0 THEN
               TAG_NAME = '7.5';
             ELSE IF (MVH_COUNT(R) MOD 2) = 0 THEN
               TAG_NAME = '10.25+.875*'||MVH_COUNT(R)||TAG_NAME;
             ELSE TAG_NAME = '12.0+.875*('||MVH_COUNT(R)||'-1)'||TAG_NAME;
           END;
           ELSE TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME;
         END;
         ELSE TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME;
       END;

    /* RX = 1 */
       DO;
         IF (INST=92 /*M*/) & (R MOD 2 ^= 0) THEN DO;
           IF IX ^= 0 THEN DO;
             IF (SHL(F,1) + IA) > 0 THEN
               TAG_NAME = TIMES(31)||' (SEE POO)'||TAG_NAME;
             ELSE
               TAG_NAME = TIMES(54)||TAG_NAME;
           END;
             ELSE TAG_NAME = TIMES(21)||TAG_NAME;
         END;
         ELSE IF (INST=93 /*D*/) & (R MOD 2 ^= 0) THEN DO;
           IF IX ^= 0 THEN DO;
             IF (SHL(F,1) + IA) > 0 THEN
               TAG_NAME = TIMES(39)||' (SEE POO)'||TAG_NAME;
             ELSE
               TAG_NAME = TIMES(52)||TAG_NAME;
           END;
             ELSE TAG_NAME = TIMES(21)||TAG_NAME;
         END;
         ELSE IF (INST=124 /*ME*/) & ((R MOD 2 ^= 0) | (LHS=SRSTYPE)) THEN DO;
           IF IX ^= 0 THEN DO;
             IF (SHL(F,1) + IA) > 0 THEN
               TAG_NAME = TIMES(50)||' (SEE POO)'||TAG_NAME;
             ELSE
               TAG_NAME = TIMES(62)||TAG_NAME;
           END;
           ELSE TAG_NAME = TIMES(29)||TAG_NAME;
         END;
         ELSE IF IX ^= 0 THEN DO;
           IF (SHL(F,1) + IA) > 0 THEN
             TAG_NAME = TIMES(INDIRECT_TIMES(INST))||' (SEE POO)'||TAG_NAME;
           ELSE
             TAG_NAME = TIMES(INDEX_TIMES(INST))||TAG_NAME;
         END;
         ELSE
           TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME;
         IF INST = IAL THEN DO;
           IF LHS ^= SRSTYPE & B = 3 THEN DO;
             MVH_COUNT(R) = D;
             MVH_CNT_KNOWN(R) = TRUE;
           END;
           ELSE MVH_CNT_KNOWN(R) = FALSE;
         END;
       END;

    /* RS-SI = 2 */
       DO;
         IF (INST >= "90") & (INST <= "9F") & (IX ^= 0) THEN DO;
           IF (SHL(F,1) + IA) > 0 THEN
             TAG_NAME = TIMES(INDIRECT_TIMES(INST))||' (SEE POO)'||TAG_NAME;
           ELSE
             TAG_NAME = TIMES(INDEX_TIMES(INST))||TAG_NAME;
         END;
         ELSE IF (INST=SRL) | (INST=SRA) | (INST=SLDL) | (INST=SRDA) |
         (INST=SLL) | (INST=140 /*SRDL*/) THEN DO;
           IF B = 0 THEN
             TAG_NAME = TIMES(NORMAL_TIMES(INST))||D||')'||TAG_NAME;
           ELSE
             TAG_NAME = TIMES(NORMAL_TIMES(INST))||'R'||ABS(B)||')'||TAG_NAME;
         END;
         ELSE
           TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME;
       END;
    /* SS = 3 */
       DO;
         IF (INST=LDM) THEN DO;
           IF IX = 0 THEN
           TAG_NAME = TIMES(NORMAL_TIMES(INST))||TAG_NAME;
           ELSE DO;
             IF (SHL(F,1) + IA) > 0 THEN
               TAG_NAME = TIMES(INDIRECT_TIMES(INST))||' (SEE POO)'||TAG_NAME;
             ELSE
               TAG_NAME = TIMES(INDEX_TIMES(INST))||TAG_NAME;
           END;
         END;
         ELSE IF (INST=SRR) THEN
           TAG_NAME = TIMES(NORMAL_TIMES(INST))||D||')'||TAG_NAME;
       END;
    END; /* DO CASE M */

    TAG_NAME = 'TIME: '||TAG_NAME;

  END EXECUTION_TIMES;

CASE0001:                                                                       07347000
         DO CASE SHR(INST, 6);                                                  07347500
                                                                                07348000
 /*RR*/                                                                         07348500
          DO;                                                        /*CR12940*/
            /* PUT AN 'R' IN FRONT OF ALL FIXED POINT REGISTERS AND    CR12713*/
            /* AN 'F' IN FRONT OF ALL FLOATING POINT REGISTERS.        CR12713*/
            IF INST = LFXI THEN T = 'R'||R||COMMA||IX-2;             /*CR12713*/
            ELSE IF INST = LFLI THEN T = 'F'||R||COMMA||IX;          /*CR12713*/
            ELSE IF INST = BCR | INST = BCRE | INST = SRET           /*CR12713*/
                        | INST = SPM THEN T = R||COMMA||'R'||IX;     /*CR12713*/
            ELSE IF INST = CVFX THEN T = 'R'||R||COMMA||'F'||IX;     /*CR12713*/
            ELSE IF INST = CVFL THEN T = 'F'||R||COMMA||'R'||IX;     /*CR12713*/
            ELSE IF INST > CVFX & INST < CVFL THEN                   /*CR12713*/
                    T = 'F'||R||COMMA||'F'||IX;                      /*CR12713*/
            ELSE T = 'R'||R||COMMA||'R'||IX;                         /*CR12713*/
            CALL EXECUTION_TIMES(0);                                 /*CR12940*/
          END;                                                       /*CR12940*/
                                                                                07351000
 /*RX*/                                                                         07351500
CASE_RX:                                                                        07352000
            DO;                                                                 07352500
               /* CHECK FOR RS INSTRUCTION WITH A BASE OF 3            CR12713*/
               IF IX=0 THEN T = CHECK_NO_BASE_RS;                    /*CR12713*/
 /*CR12713*/   ELSE T = LEFTBRACKET||'R'||IX||COMMA||'R'||B||RIGHTBRACKET;
               T = R||COMMA||D||T;                                   /*CR12713*/
               /* PUT AN 'R' IN FRONT OF FIXED POINT REGISTERS AND     CR12713*/
               /* AN 'F' IN FRONT OF FLOATING POINT REGISTERS.         CR12713*/
               IF INST >= "60" & INST <= "7E" THEN T = 'F'||T;       /*CR12713*/
               ELSE IF INST ^= BC                                    /*CR12713*/
 /?B              & INST ^= BVC                                      /*CR12713*/
 ?/                                                                  /*CR12713*/
                  THEN T = 'R'||T;                                   /*CR12713*/
 /*CR12385*/   IF IX ^= 0 & D > 2047 THEN CALL ERRORS(CLASS_BI,512);
          /*CR12714- ADD TRAPS FOR INVALID DISPLACEMENT            */
          /*FOR SRS INSTRUCTIONS D IS EQUAL TO N * DISPLACEMENT    */
          /*WHERE N = 1 FOR HALFWORD OPERATIONS AND                */
          /*N = 2 FOR FULLWORD OPERATIONS; INSTRUCTIONS BETWEEN    */
          /*HEX'50' AND HEX'80' ARE FULLWORD OPERATIONS            */
 /*CR12714*/   IF IX = 0 & D > 65535 THEN CALL ERRORS(CLASS_BI,514);
 /*CR12714*/   IF LHS = SRSTYPE & D >= 56 THEN
 /*CR12714*/      IF (INST >= "50" & INST < "80" & (SHR(D,1) >= 56)) |
 /*CR12714*/        ^(INST >= "50" & INST < "80") THEN
 /*CR12714*/            CALL ERRORS(CLASS_BI,515,'SRS');
               CALL EXECUTION_TIMES(1);                              /*CR12940*/
            END;                                                                07354500
                                                                                07358500
 /*RS-SI*/                                                                      07359000
            DO;                                                                 07359500
               IF INST >= "90" & INST <= "9F" THEN DO;                          07360000
                  /* CHECK FOR AN RS INSTRUCTION WITH A BASE OF 3      CR12713*/
                  IF IX = 0 THEN T = D||CHECK_NO_BASE_RS;            /*CR12713*/
 /*CR12713*/      ELSE T = D||LEFTBRACKET||'R'||IX||COMMA||'R'||B||RIGHTBRACKET;
 /*CR12385*/      IF IX ^= 0 & D > 2047 THEN CALL ERRORS(CLASS_BI,512);
               END;                                                             07362000
               ELSE IF INST >= "B0" & INST <= "BF" THEN                         07362500
                  T=D||LEFTBRACKET||'R'||B||'),'||RHS(1);            /*CR12713*/07363000
               ELSE IF B = 0 THEN                                               07363500
                  T='R'||R||COMMA||D;                               /*CR12713*/ 07364000
               ELSE IF INST = LHI THEN                              /*CR12713*/
                  T='R'||R||COMMA||D||LEFTBRACKET||RIGHTBRACKET;    /*CR12713*/
               ELSE IF INST < "80" | INST > "87" THEN                           07364500
 /*CR12713*/      T='R'||R||COMMA||D||LEFTBRACKET||'R'||ABS(B)||RIGHTBRACKET;   07365000
               ELSE DO;                                                         07365500
                  T = R||COMMA||'*';                                            07366000
                  IF (RHS & 2) = 0 | D = 0 THEN                                 07366500
                     T = T || PLUS || D+1;                                      07367000
                  ELSE T = T || -D+1;                                           07367500
                  IF INST = BCTB THEN T = 'R'||T;                    /*CR12713*/
               END;                                                             07368000
 /*CR12714*/  IF IX = 0 & D > 65535 THEN CALL ERRORS(CLASS_BI,514);
 /*CR12714*/  IF LHS = SRSTYPE & D >= 56 THEN CALL ERRORS(CLASS_BI,515,'SRS');
 /*CR12714*/  IF LHS = SSTYPE & D >= 56 THEN CALL ERRORS(CLASS_BI,515,'SI');
              CALL EXECUTION_TIMES(2);                               /*CR12940*/
            END;                                                                07383500
                                                                                07384000
 /*SS*/                                                                         07384500
            DO;                                                                 07359500
    /*--------------------------- #DDSE -------------------------*/             00180450
    /* HANDLE NEW LDM INSTRUCTION PRINT FOR THE ASSEMBLY LISTING.*/             00180460
               IF (INST = LDM) THEN DO;                           /*DR105392*/
                  IF IX = 0 THEN                                  /*DR105392*/
                     T = D||CHECK_NO_BASE_RS;                     /*CR12713*/
                  ELSE DO;                                        /*CR12713*/
                     T = 'R'||IX||COMMA||'R'||B;                  /*CR12713*/
                     T = D||LEFTBRACKET||T||RIGHTBRACKET;         /*CR12713*/
                  END;                                            /*CR12713*/
                  IF IX ^= 0 & D > 2047 THEN                      /*CR012714*/
                     CALL ERRORS(CLASS_BI,512);                   /*CR012714*/
                  IF IX = 0 & D > 65535 THEN                      /*CR012714*/
                     CALL ERRORS(CLASS_BI,514);                   /*CR012714*/
               END;

    /*-----------------------------------------------------------*/             00180510
    /*----------------------DR106968-----------------------------*/
    /* SRR WAS ADDED AND PLACED IN THE SS CATEGORY INSTEAD OF    */
    /* THE SRS CATEGORY BECAUSE LACK OF SPACE IN THE INSTRUCTION */
    /* TABLE.  SO WE HANDLE IT HERE AS AN EXCEPTION              */
    /* PUT AN R IN FRONT OF REGISTER FOR SRR INSTRUCTION              CR12713 */
               ELSE IF (INST = SRR) THEN T='R'||R||COMMA||D;       /* CR12713 */
               ELSE GO TO CASE_RX;
               CALL EXECUTION_TIMES(3);                            /* CR12940*/
            END;
    /*-----------------------------------------------------------*/             00180510
         END CASE0001;                                                          07390000
         RETURN PAD(T, 20);                                        /* CR12940*/ 07390500
      END GENERATE_OPERANDS;                                                    07391000
                                                                                07391500
PRINT_LINE:PROCEDURE(I);                                                        07392000
         DECLARE (I, J) BIT(16);                                                07392500
         DECLARE T CHARACTER;                                                   07393000
         ARRAY   TYPES(50) BIT(8) INITIAL (                         /*CR13335*/ 07393500
            4,  0,  0,  0,  0,  0,  0,  0,  0,  0,                              07394000
            0,  0,  0,  0,  0,  0,  0,  0,  0,  0,                              07394500
            0,  0,  0,  0,  0,  0,  0,  0,  0,  0,                              07395000
            0,  0,  1,  1,  1,  5,  2,  2,  3,  6,                              07395500
            7,  0,  0,  9,  2,  5,  8,  0,  2,  0,                              07396000
            1);                                                                 07396500
         IF ^CODE_LISTING_REQUESTED THEN RETURN;                                07397000
         IF DATA_LIST_OFF THEN                                                   7397500
            IF CURRENT_ESDID >= DATABASE THEN                                    7398000
            IF ^(ASSEMBLER_CODE | EXTRA_LISTING) THEN RETURN;                    7398500
         S1=LEFTHEX(SHL(CURRENT_ADDRESS,12),5);                                 07399000
CASE0002:                                                                       07399500
         DO CASE TYPES(LHS);                                                    07400000
                                                                                07400500
 /*TYPE0=INIMPLEMENTED*/                                                        07401000
            S1=S1||'----- UNIMPLEMENTED FUNCTION;  LHS='||LHS||', I='||I;       07401500
                                                                                07402000
 /*TYPE1=INSTRUCTIONS*/                                                         07402500
            DO;                                                                 07403000
               IF I = 4 THEN                                                    07403500
                  S2 = LEFTHEX(SHL(RHS(1), 16), 4);                             07404000
               ELSE S2 = '';                                                    07404500
               S2 = LEFTHEX(SHL(RHS, 16), 4) || S2;                             07405000
               S1=S1||S2;                                                       07410000
               S1 = S1 || SUBSTR(X72, 51+LENGTH(S1)) || EFFAD;                  07410500
 /*CR12940*/   IF (INST=BC) | (INST=BCF) | (INST=BCRE) | (INST=BCR) THEN
 /*CR12940*/     TAG_NAME = BC_ALT_MNEMONIC(CC_TYPE,(SHR(RHS,8) & "7"))
 /*CR12940*/                || TAG_NAME;
               S2=GENERATE_OPERANDS || TAG_NAME;                                07411000
 /*CR12940*/   S2=INSTRUCTION(INST,SHL(F,1)+IA,TRUE) || BLANK || S2;            07411500
               S1 = S1 || SUBSTR(X72, 26+LENGTH(S1)) || S2;                     07412000
               TAG_NAME, EFFAD = '';                                            07412500
 /*CR12940*/   IF INST_CC(INST) ^= 0 THEN
 /*CR12940*/      CC_TYPE = INST_CC(INST);
            END;                                                                07414000
                                                                                07414500
 /*TYPE2=LABEL DEF*/                                                            07415000
            DO;                                                                 07415500
 /*CR12940*/   T = 'EQU    *';                                                  07416000
               S1 = ' 00' || SUBSTR(S1, 1);                                     07416500
PRINT_EQU:                                                                      07417000
               TEMP=9-LENGTH(TAG_NAME);                                         07417500
               IF TEMP > 0 THEN DO;                                             07418000
                  S1 = S1 || SUBSTR(X72, 43) ||                                 07418500
                     TAG_NAME||                                                 07419000
                     SUBSTR(X72,0,TEMP)||                                       07419500
                     T;                                                         07420000
               END;                                                             07420500
               ELSE DO;                                                         07421000
                  S1 = S1 || SUBSTR(X72, 43) || SUBSTR(TAG_NAME,0,8) || BLANK ||07421500
 /*CR12940*/         T || SUBSTR(X72,53) || TAG_NAME;                           07422000
               END;                                                             07422500
               TAG_NAME='';                                                     07423000
            END;                                                                07423500
                                                                                07424000
 /*TYPE3=CSECT*/                                                                07424500
            DO;                                                                 07425000
               S2 = LEFTHEX(SHL(CURRENT_ESDID,16),4);                           07425500
               T = 'CSECT        ESDID='||S2;                                   07426000
               S1 = S1 || X2;                                                   07426500
               GO TO PRINT_EQU;                                                 07427000
            END;                                                                07427500
                                                                                07428000
 /*TYPE4=HEX CONSTANT*/                                                         07428500
HEX_CONSTANT:DO;                                                                07429000
               T=LEFTHEX(SHL(RHS,16),4);                                        07429500
               S1=S1||                                                          07430000
                  T||                                                           07430500
                  SUBSTR(X72, 37) ||                                            07431000
 /*CR12940*/      'DC     X'''||                                                07431500
                  SUBSTR(T,1)||                                                 07432000
 /*CR12940*/      QUOTE || '             ' || TAG_NAME;                         07432500
               TAG_NAME = '';                                                   07433000
            END HEX_CONSTANT;                                                   07433500
                                                                                07434000
 /*TYPE5=IGNORE*/ RETURN;                                                       07434500
                                                                                07435000
 /*TYPE6=4 BYTE HEX CONSTANT*/                                                  07435500
HEX_4_CONSTANT:DO;                                                              07436000
 /*CR12940*/   S2 = 'DC     X''';                                               07436500
FOUR_BYTE_CONSTANT:                                                             07437000
               T=LEFTHEX((SHL(RHS,16) | (RHS(1) & FFOUR)), 8);                  07437500
               S1 = S1 || T || SUBSTR(X72, 41) || S2 || SUBSTR(T, 1) ||         07438000
 /*CR12940*/      QUOTE || '         ' || TAG_NAME;                             07438500
               TAG_NAME = '';                                                   07439000
            END HEX_4_CONSTANT;                                                 07439500
                                                                                07440000
 /*TYPE7=4 BYTE ADDRESS CONSTANT*/                                              07440500
            DO;                                                                 07441000
 /*CR12940*/   S2 = 'DC     A''';                                               07441500
               GO TO FOUR_BYTE_CONSTANT;                                        07442000
            END;                                                                07442500
                                                                                07443000
 /* TYPE8=N BYTE HEX OR CHARACTER CONSTANT */                                   07443500
            DO;                                                                 07444000
               J = SHL(I, 1);                                                   07444500
               T = LEFTHEX((SHL(RHS,16)|RHS(1)&FFOUR), J);                      07445000
 /*CR12940*/   S1 = S1 || T || SUBSTR(X72, 33+J) || 'DC     X''' ||             07445500
                  SUBSTR(T, 1) || QUOTE;                                        07446000
            END;                                                                07446500
                                                                                07447000
 /* TYPE9=ORIGIN  */                                                            07447500
            DO;                                                                 07448000
               S2 = LEFTHEX(SHL(L,12),5);                                       07448500
               S1 = S2 || ' 0' || SUBSTR(S1, 1);                                07449000
               L = CURRENT_ADDRESS - L;                                         07449500
               IF L > 0 THEN S2 = PLUS; ELSE S2 = '';                           07450000
 /*CR12940*/   S1 = S1 || SUBSTR(X72, 39) || 'ORG    *' || S2 || L;             07450500
            END;                                                                07451000
                                                                                07451500
         END CASE0002;                                                          07452000
         IF ^HEADOUT THEN DO;                                                   07452500
            HEADOUT=TRUE;                                                       07453000
            CALL AHEADSET(0);                                                   07453500
         END;                                                                   07454500
                                                                                07455000
         CALL APRINT(S1);                                                       07455500
      END PRINT_LINE;                                                           07456000
                                                                                07456500
FORM_EFFAD:                                                                     07457000
      PROCEDURE(I);                                                             07457500
         DECLARE I FIXED;                                                       07458000
         IF ^CODE_LISTING_REQUESTED THEN RETURN;                                07458500
         EFFAD = LEFTHEX(SHL(I,16),4);                                          07459000
      END FORM_EFFAD;                                                           07459500
                                                                                07460000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
EMIT_TEXT_CARD:PROCEDURE(I);                                                    07460500
         DECLARE I BIT(16);                                                     07461000
         IF BYTES_REMAINING < I | CARDIMAGE ^= TEXT_CARD THEN                   07461500
            DO;                                                                 07462000
            CALL EMIT_CARD;                                                     07462500
            CARDIMAGE,CARDIMAGE(1)=TEXT_CARD;                                   07463000
            CARDIMAGE(2)="40000000"+SHL(CURRENT_ADDRESS,1);                     07463500
            CARDIMAGE(4)="40400000" + CURRENT_ESDID;                            07464000
            CURRENT_SIZE, BYTES_REMAINING=TEXT_SIZE;                            07464500
         END;                                                                   07465000
         TEMP=72-BYTES_REMAINING;                                               07465500
         DO L=1 TO I;                                                           07466000
            IF L THEN COLUMN(TEMP)=SHR(RHS(SHR(L,1)),8);                        07466500
            ELSE COLUMN(TEMP)=RHS(SHR(L-1,1));                                  07467000
            TEMP=TEMP+1;                                                        07467500
         END;                                                                   07468000
         BYTES_REMAINING=BYTES_REMAINING-I;                                     07468500
         CALL PRINT_LINE(I);                                                    07469000
         CURRENT_ADDRESS=CURRENT_ADDRESS+SHR(I+1,1);                            07469500
      END EMIT_TEXT_CARD;                                                       07470000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */

         /* ROUTINE TO ADD A SPECIFIED NUMBER OF BYTES OF TEXT TO A TEXT CARD */

EMIT_TEXT_CARD: PROCEDURE(#TEXT_BYTES);

DECLARE
        #TEXT_BYTES                    BIT(16),
        #TEXT_HALFWORDS                LITERALLY '#TEXT_BYTES',
        DISPLACEMENT                   LITERALLY 'CARD_IMAGE(1)',
        CSECT_ID                       LITERALLY 'CARD_IMAGE(2)',
        TEXT_BASE                      LITERALLY '2',
        PTX_ID                         LITERALLY '"0600"',
        UTX_ID                         LITERALLY '"0700"',
        I                              BIT(16);


         /*--- ROUTINE TO CHECK THE CURR_STORE_PROTECT STATUS ---*/
CHECK_STORE_PROTECT:
   PROCEDURE;

      IF CURR_STORE_PROTECT THEN RECORD_ID = PTX_ID;
      ELSE RECORD_ID = UTX_ID;

   END CHECK_STORE_PROTECT;


   IF (#TEXT_BYTES & 1) ^= 0 THEN DO;
      #TEXT_HALFWORDS = SHR(#TEXT_BYTES + 1, 1);
      RHS(#TEXT_HALFWORDS - 1) = RHS(#TEXT_HALFWORDS - 1) & "FF00";
      END;                                                                      07465000
   ELSE
      #TEXT_HALFWORDS = SHR(#TEXT_BYTES, 1);

   IF RECORD_ID = 0 THEN DO;
      IF CURRENT_ESDID <= SYMBREAK THEN RECORD_ID = PTX_ID;
      ELSE IF ESD_CSECT_TYPE(CURRENT_ESDID) = ZCON_CSECT_TYPE THEN
         RECORD_ID = PTX_ID;
      ELSE IF CURRENT_ESDID = DATABASE THEN DO;
         IF CURRENT_ADDRESS >= GENED_LIT_START THEN RECORD_ID = PTX_ID;
         ELSE IF CURRENT_ADDRESS < SYT_ADDR(PROC_LEVEL(PROGPOINT))
         THEN RECORD_ID = PTX_ID;
         ELSE CALL CHECK_STORE_PROTECT;
      END;                                                                      07468000
      ELSE IF CURRENT_ESDID = REMOTE_LEVEL THEN CALL CHECK_STORE_PROTECT;
      ELSE RECORD_ID = UTX_ID;
      DISPLACEMENT = CURRENT_ADDRESS;
      CSECT_ID = CURRENT_ESDID;
   END;

   IF (#TEXT_HALFWORDS + #TEXT_HALFWORDS_USED + 3) > 255 THEN DO;
      RECORD_ID = RECORD_ID | (#TEXT_HALFWORDS_USED + 3);
      CALL EMIT_CARD;
      #TEXT_HALFWORDS_USED = 0;
      RECORD_ID = RECORD_ID & "FF00";
      DISPLACEMENT = CURRENT_ADDRESS;
   END;

   DO FOR I = 1 TO #TEXT_HALFWORDS;
      CARD_IMAGE(TEXT_BASE + #TEXT_HALFWORDS_USED + I) = RHS(I - 1);
   END;

   #TEXT_HALFWORDS_USED = #TEXT_HALFWORDS_USED + #TEXT_HALFWORDS;
   CALL PRINT_LINE(SHL(#TEXT_HALFWORDS, 1));
   CURRENT_ADDRESS = CURRENT_ADDRESS + #TEXT_HALFWORDS;

      END EMIT_TEXT_CARD;                                                       07470000

         /* ROUTINE TO FLUSH A TEXT CARD */

FLUSH_TEXT_CARD: PROCEDURE;

   IF #TEXT_HALFWORDS_USED ^= 0 THEN DO;
      RECORD_ID = RECORD_ID | (#TEXT_HALFWORDS_USED + 3);
      CALL EMIT_CARD;
      #TEXT_HALFWORDS_USED = 0;
   END;

   RECORD_ID = 0;

END FLUSH_TEXT_CARD;
 ?/
                                                                                 7470020
GET_RLD:                                                                         7470040
      PROCEDURE(PTR, FLAG);                                                      7470060
         DECLARE PTR FIXED, FLAG BIT(8);                                         7470080
         RETURN GET_LITERAL(PTR + LIT_TOP, FLAG);                                7470100
      END GET_RLD;                                                               7470120
                                                                                07470500
EMIT_RLD:PROCEDURE(REL, ADR) BIT(16);                                           07471000
         DECLARE (REL, TMP) BIT(16), ADR FIXED;                                 07471500
         RLD# = RLD# + 1;                                                       07472000
         TMP = GET_RLD(RLD#, 1);                                                07472500
         RLD_ADDR(TMP) = ADR;                                                   07473000
         IF REL = FSIMBASE THEN DO;                                             07473500
            REL = DATABASE;                                                     07474500
         END;                                                                   07475000
         RLD_REF(TMP) = SHL(REL & "F000",16) | REL & FTHREE;                    07475500
         RLD_LINK(TMP) = 0;                                                     07476000
         IF RLD_POS_HEAD(CURRENT_ESDID) = 0 THEN                                07476500
            RLD_POS_HEAD(CURRENT_ESDID) = RLD#;                                 07477000
         ELSE RLD_LINK(GET_RLD(RLD_POS_LINK(CURRENT_ESDID),1)) = RLD#;          07477500
         RLD_POS_LINK(CURRENT_ESDID) = RLD#;                                    07478000
         RETURN REL & FTHREE;                                                   07478500
      END EMIT_RLD;                                                             07479000
                                                                                07479500
FORM_BD:PROCEDURE(I);                                                           07480000
         DECLARE I BIT(16);                                                     07480500
         DECLARE P BIT(16),                                                     07481000
            J FIXED;                                                            07481500
         DECLARE TEMP2 CHARACTER;                                               07482000
         DECLARE LITBASE BIT(1);                                                07482100
                                                                                07483000
CHECK_Z_LINKAGE:                                                                07483500
         PROCEDURE(PTR);                                                        07484000
            DECLARE PTR BIT(16);                                                07484500
            IF (ESD_NAME_LENGTH(PTR)&"80") ^= 0 THEN DO;                        07485000
               IX, IA, F = 1;                                                   07485500
            END;                                                                07486000
         END CHECK_Z_LINKAGE;                                                   07486500
                                                                                07487000
 /* INTERNAL ROUTINE TO SET UP BRANCH DISPLACEMENTS */                          07487500
FORM_BADDR:                                                                     07488000
         PROCEDURE(PTR) FIXED;                                                  07488500
            DECLARE PTR BIT(16), DEST FIXED;                                    07489000
            DECLARE PCRELMAX BIT(16) INITIAL(0);                                07489500
            PTR = REAL_LABEL(PTR);                                              07490000
            DEST = LOCATION(PTR) + ADDRESS_MOD + ORIGIN(CURRENT_ESDID);         07490010
            ADDRESS_MOD = 0;                                                    07490500
            CALL FORM_EFFAD(DEST);                                              07491000
            IF LHS = SRSTYPE THEN DO;                                           07491500
               B = -1;                                                          07492000
               D = DEST - CURRENT_ADDRESS - 1;                                  07492500
               IF D < 0 THEN D = -D;                                            07493000
               ELSE RHS = RHS - 2;                                              07493500
            END;                                                                07494000
            ELSE DO;                                                            07494500
               B = 3;                                                           07495000
               AM = 1;                                                          07495500
               IF DEST >= CURRENT_ADDRESS+2 THEN                                07496000
                  D = DEST - CURRENT_ADDRESS-2;                                 07496500
               ELSE DO;                                                         07497000
                  D = CURRENT_ADDRESS+2 - DEST;                                 07497500
                  F = 1;                                                        07498000
               END;                                                             07498500
               IF D >= PCRELMAX THEN DO;                                        07499000
                  D = DEST;                                                     07499500
                  AM, F = 0;                                                    07500000
                  IF CURRENT_ESDID<= PROCLIMIT THEN DO;                         07500500
                     IF LOCATION_LINK(PTR) < 0 THEN                             07500510
                        CALL EMIT_RLD(CURRENT_ESDID+SDELTA, CURRENT_ADDRESS+1); 07500520
                     ELSE CALL EMIT_RLD(CURRENT_ESDID, CURRENT_ADDRESS+1);      07500530
                  END;                                                          07500540
                  ELSE DO;                                                      07500550
                     IF LOCATION_LINK(PTR)<0 THEN                               07500560
                        CALL EMIT_RLD(CURRENT_ESDID,CURRENT_ADDRESS+1);         07500570
                     ELSE CALL EMIT_RLD(CURRENT_ESDID-SDELTA,CURRENT_ADDRESS+1);07500580
                  END;                                                          07500590
               END;                                                             07501000
            END;                                                                07501500
         END FORM_BADDR;                                                        07502500
                                                                                07503000
         P=RHS(I);                                                              07503500
         IF P<0 & (LHS(I)^=0)& (LHS(I) ^= LOCREL) THEN DO;                      07503510
            P = -P;                                                             07503520
            LITBASE = 1;                                                        07503530
         END;                                                                   07503540
         ELSE LITBASE = 0;                                                      07503550
CASE0003:                                                                       07504000
         DO CASE LHS(I);                                                        07504500
                                                                                07505000
 /*0 HEX CONSTANT*/                                                             07505500
            DO;                                                                 07506000
               IF RHS = AP101INST(IAL) THEN B = 3;                              07506500
               ELSE B = 0;                                                      07506600
               D = P;                                                           07507000
            END;                                                                07507500
                                                                                07508000
 /*1*/                                                                          07508500
            DO;                                                                 07509000
               IF SYT_BASE(P) >= 0 THEN                                         07509500
                  DO;                                                           07510000
                  B = SYT_BASE(P) & RM;                                         07510500
                  D = SYT_DISP(P);                                              07511000
                  J = 0;                                                        07511500
FORM_SYM:                                                                       07512000
                  IF (SYT_FLAGS(P) & POINTER_OR_NAME) ^= 0 THEN                  7512500
                     L = 0;                                                      7512600
                  ELSE L = SYT_CONST(P);                                         7512700
                  CALL FORM_EFFAD(SYT_ADDR(P) + L + ADDRESS_MOD);                7512800
                  TAG_NAME=SYT_NAME(P);                                         07513000
                  IF ADDRESS_MOD ^= 0 THEN DO;                                  07513500
                     IF ADDRESS_MOD > 0 THEN                                    07514000
                        TAG_NAME=TAG_NAME||PLUS;                                07514500
                     TAG_NAME=TAG_NAME||ADDRESS_MOD;                            07515000
                  END;                                                          07515500
                  D = D + ADDRESS_MOD;                                          07516000
                  ADDRESS_MOD = 0;                                              07516500
                  IF J > 0 THEN DO;                                             07517000
                     J = GET_RLD(RLD#, 1);                                      07517500
                     IF SYT_SCOPE(P) >= PROGPOINT THEN DO;
                        RLD_REF(J) = 0;                                         07518500
                        B = PROGBASE;                                           07519000
                     END;                                                       07519010
                     ELSE IF D < 0 THEN DO;                                     07520000
                        D = -D;                                                 07520500
                        RLD_REF(J) = RLD_REF(J) | "80000000";                   07521000
                     END;                                                       07521500
                  END;                                                          07522000
               END;                                                             07522500
            END;                                                                07523000
                                                                                07523500
 /* 2 RLD RELOCATED SYMBOL ENTRY */                                             07524000
            DO;                                                                 07524500
               J = SYT_SCOPE(P);                                                07525000
               IF J >= PROGPOINT THEN DO;                                       07525500
                  J = 0;                                                        07526000
                  B = PROGBASE;                                                 07526500
               END;                                                             07527000
               ELSE DO;                                                         07527500
 /* USE_ABS */                                                                  07527530
                  J = EMIT_RLD(J, CURRENT_ADDRESS + 1);                         07528000
                  B = 3;                                                        07528500
               END;                                                             07529000
               D = SYT_DISP(P) + R_BASE(-SYT_BASE(P));                          07529500
               GO TO FORM_SYM;                                                  07530000
            END;                                                                07530500
                                                                                07531000
 /* 3 */                                                                        07531500
            ;                                                                   07532000
                                                                                07532500
 /*4*/                                                                          07533500
            DO;                                                                 07534000
               B = PROGBASE;                                                    07534700
 /?P  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */
               D = R_ADDR(P);                                                   07534750
 ?/
 /?B  /* SSCR 8348 -- BASE REG ALLOCATION (ADCON)  */
               D = R_INX(P);                                                    07534750
 ?/
               CALL FORM_EFFAD(D);                                              07535500
               TAG_NAME = 'BASE_REG#'||P;                                       07536000
            END;                                                                07536500
 /* 5 */                                                                        07537000
            ;                                                                   07537500
                                                                                07538000
 /* 6 LOCAL ADDRESSING CONTEXT ONLY */                                          07538500
            DO;                                                                 07539000
               B = PROCBASE;                                                    07539500
               D = SYT_LINK2(P);                                                07540000
               J = 0;                                                           07540500
               GO TO FORM_SYM;                                                  07541000
            END;                                                                07541500
                                                                                07542500
 /*7 FORMED BASE DISPLACEMENT */                                                07543000
            DO;                                                                 07543500
               B = P & RM;                                                      07544000
               CALL NEXT_REC(I);                                                07544500
               D = RHS(I) & FFOUR;                                              07545000
               CALL FORM_EFFAD(D+ADDRESS_MOD);                                  07545500
            END;                                                                07546000
                                                                                07546500
 /*8 CHARACTER CONSTANT*/                                                       07547000
            DO;                                                                 07547500
               TAG_NAME='C'''||DESC(CONSTANTS(P))||QUOTE;                       07548000
SET_J_UP:                                                                       07548500
               B = PROGBASE;                                                    07549400
               D = CONSTANT_PTR(P);                                             07550500
               CALL FORM_EFFAD(D+ADDRESS_MOD);                                  07551000
               IF ADDRESS_MOD > 0 THEN TAG_NAME = TAG_NAME||PLUS||ADDRESS_MOD;  07551500
               ELSE IF ADDRESS_MOD < 0 THEN TAG_NAME = TAG_NAME || ADDRESS_MOD; 07552000
            END;                                                                07552500
                                                                                07553000
 /*9 HALFWORD CONSTANT*/                                                        07553500
            DO;                                                                 07554000
               TAG_NAME='H''';                                                  07554500
               S2 = HEX(CONSTANTS(P),4);                           /*CR12940*/
SET_TAG_UP:                                                                     07555000
               TAG_NAME=TAG_NAME || CONSTANTS(P) || QUOTE;                      07555500
               TAG_NAME=TAG_NAME || ', ' || 'X''' || S2 || QUOTE;  /*CR12940*/
               GO TO SET_J_UP;                                                  07556000
            END;                                                                07556500
                                                                                07557000
 /*10 FULLWORD CONSTANT*/                                                       07557500
            DO;                                                                 07558000
               TAG_NAME='F''';                                                  07558500
               S2 = HEX(CONSTANTS(P),8);                           /*CR12940*/
               GO TO SET_TAG_UP;                                                07559000
            END;                                                                07559500
                                                                                07560000
 /*11 SCALAR LENGTH 4 BYTES*/                                                   07560500
            DO;                                                                 07561000
               S2 = LEFTHEX(CONSTANTS(P), 8);                                   07561500
               TAG_NAME='X''' || SUBSTR(S2,1) || QUOTE;            /*CR12940*/  07562000
               DW(0) = CONSTANTS(P);                               /*CR12940*/
               DW(1) = 0;                                          /*CR12940*/
               S2 = STRING(MONITOR(12,0));                         /*CR12940*/
               TAG_NAME = TAG_NAME || ', S''' || S2 || QUOTE;      /*CR12940*/
               GO TO SET_J_UP;                                                  07562500
            END;                                                                07563000
                                                                                07563500
 /*12 SCALAR LENGTH 8 BYTES*/                                                   07564000
            DO;                                                                 07564500
               S2 = LEFTHEX(CONSTANTS(P+1), 8);                                 07565000
               TAG_NAME=LEFTHEX(CONSTANTS(P),8) ||S2;                           07565500
               TAG_NAME='X''' ||                                   /*CR12940*/  07566000
                  SUBSTR(TAG_NAME,1) ||                                         07566500
                  QUOTE;                                                        07567000
               DW(0) = CONSTANTS(P);                               /*CR12940*/
               DW(1) = CONSTANTS(P+1);                             /*CR12940*/
               S2 = STRING(MONITOR(12,8));                         /*CR12940*/
               TAG_NAME = TAG_NAME || ', D''' || S2 || QUOTE;      /*CR12940*/
               GO TO SET_J_UP;                                                  07567500
            END;                                                                07568000
                                                                                07568500
 /*13 ADDRESS CONSTANT  */                                                      07569000
            DO;                                                                 07569500
               B = PROGBASE;                                                    07569910
               D = CONSTANT_PTR(P);                                             07570500
               CALL FORM_EFFAD(D);                                              07571000
            END;                                                                07571500
                                                                                07572000
 /* 14  */                                                                      07572500
            ;                                                                   07577500
 /* 15 = CASE POINTER  */                                                       07579500
            DO;                                                                 07580000
               IF LITBASE THEN DO;                                              07580500
                  B = SDBASE;                                                   07580550
                  D=LABEL_ARRAY(P)-R_BASE(SDINDEX);                             07580600
               END;                                                             07580650
               ELSE DO;                                                         07580700
                  B = PROGBASE;                                                 07580750
                  /* D107698: AHI USES IMMEDIATE VALUE (NO BASE) */             07580750
                  IF INST = AHI THEN B = 0; /*D107698*/                         07580750
                  D = LABEL_ARRAY(P) + PROGDELTA;                               07580800
               END;                                                             07580850
               CALL FORM_EFFAD(D);                                              07581500
            END;                                                                07582000
                                                                                07582500
 /*16*/                                                                         07583000
            DO;                                                                 07583500
            END;                                                                07593000
                                                                                07593500
 /*17*/                                                                         07594000
            DO;                                                                 07594500
               IF P < 0 THEN TEMP2 = P;                                         07595000
               ELSE TEMP2 = PLUS || P;                                          07595500
               TAG_NAME='*'||TEMP2;                                             07596000
               B=-1;                                                            07596500
               D=P-1;                                                           07597000
               IF D<=0 THEN D = -D;                                             07597500
               ELSE RHS=RHS-2;                                                  07598000
               CALL FORM_EFFAD(CURRENT_ADDRESS+P);                              07598500
            END;                                                                07599500
                                                                                07600000
 /*18 USER LABEL*/                                                              07600500
            DO;                                                                 07601000
               CALL FORM_BADDR(SYT_LABEL(P));                                   07601500
               TAG_NAME = SYT_NAME(P);                                          07602000
            END;                                                                07603500
                                                                                07604000
 /*19 FLOW NUMBER LABEL*/                                                       07604500
            DO;                                                                 07605000
               CALL FORM_BADDR(LABEL_ARRAY(P));                                 07605500
               /*CR12713 - PUT THE STATEMENT NUMBER IN THE ASSEMBLY LISTING */
               /*WHEN BRANCHING TO A LABEL.                                 */
               TAG_NAME= 'LBL#' || REAL_LABEL(LABEL_ARRAY(P)) ||   /*CR12713*/  07606000
                 ' (WITHIN ST#' ||                                 /*CR12940*/
                 LOCATION_ST#(REAL_LABEL(LABEL_ARRAY(P))) || ')';  /*CR12940*/  07606000
            END;                                                                07607500
                                                                                07608000
 /*20 GENERATED LABEL */                                                        07608500
            DO;                                                                 07609000
               CALL FORM_BADDR(P);                                              07609500
               /*CR12713 - PUT THE STATEMENT NUMBER IN THE ASSEMBLY LISTING */
               /*WHEN BRANCHING TO A LABEL.                                 */
               TAG_NAME = 'LBL#' || REAL_LABEL(P) ||               /*CR12713*/  07610000
                 ' (WITHIN ST#'||LOCATION_ST#(REAL_LABEL(P))||')'; /*CR12940*/  07606000
            END;                                                                07611500
                                                                                07612000
 /*21 SYSTEM INTRINSIC  */                                                      07612500
            DO;                                                                 07613000
            END;                                                                07614500
                                                                                07618500
 /* 22 = EXTERNAL SYMBOL  */                                                    07619000
            DO;                                                                 07619500
               P = EMIT_RLD(P, CURRENT_ADDRESS + 1);                            07620000
               TAG_NAME = ESD_TABLE(P);                                         07620500
               B = 3;                                                           07621000
               D = 0;                                                           07621500
               CALL CHECK_Z_LINKAGE(P);                                         07622000
            END;                                                                07622500
                                                                                07623000
 /* 23 = SHIFT COUNT  */                                                        07623500
            DO;                                                                 07624000
               B = -IX;                                                         07624500
               D = P;                                                           07625000
            END;                                                                07625500
                                                                                07626000
 /* CASE 24 WAS NOT DELETED FOR CR-11098 BECAUSE THE CODE WAS NOT
         OBVIOUSLY SPILL CODE. ONLY THE COMMENT INDICATED THAT IT WAS
         SPILL (01/15/91 DKB) */
 /*24=LABEL AT SPILL CSECT START */                                             07625520
            DO;                                                                 07625540
               D=LOCATION(P);                                                   07625560
               IF D^=0 THEN CALL ERRORS(CLASS_BI,507,' '||CURRENT_ADDRESS+1);   07625580
               CALL FORM_EFFAD(D);                                              07625600
               B=3;                                                             07625620
               AM,F=0;                                                          07625640
               CALL EMIT_RLD(CURRENT_ESDID+SDELTA,CURRENT_ADDRESS+1);           07625660
               TAG_NAME='LBL#'||P;                                              07625680
               RETURN;                                                          07625690
            END;                                                                07625700

 /* 24,25,...,31 */                                                             07626500
            ;;;;;;;;;;;                                                         07627000
            END CASE0003;                                                       07627500
                                                                                07628000
         D = D + ADDRESS_MOD;                                                   07628500
         ADDRESS_MOD=0;                                                         07629000
      END FORM_BD;                                                              07629500
                                                                                07630000
 /?P /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
EMIT_SYM_CARDS:PROCEDURE;                                                       07630500
         DECLARE (TEMP, TEMPL) FIXED,                                           07631000
            (I, J, B, P, T) BIT(16);                                            07631500

EMIT_SYM_CARD:PROCEDURE;                                                        07632500
            CALL EMIT_CARD;                                                     07633000
            BYTES_REMAINING, CURRENT_SIZE = TEXT_SIZE;                          07633500
            CARDIMAGE, CARDIMAGE(1) = "02E2E8D4";                               07634000
            J = 72 - BYTES_REMAINING;                                           07634500
         END EMIT_SYM_CARD;                                                     07635000
         CALL EMIT_SYM_CARD;                                                    07636000
EMIT_SYM:PROCEDURE(NAME, VAL, FLAG);                                            07636500
            DECLARE NAME CHARACTER, VAL FIXED, Q BIT(16), FLAG BIT(8);          07637000
            GO TO EMIT_SYM_START;                                               07637500
MVCSYM:     CALL INLINE("D2", 0, 0, 1, 0, 2, 0);                                07638000
EMIT_SYM_START:                                                                 07638500
            IF LENGTH(NAME) > 8 THEN NAME = SUBSTR(NAME,0,8);                   07639000
            Q = 4 + LENGTH(NAME);                                               07639500
            IF BYTES_REMAINING < Q+2 THEN CALL EMIT_SYM_CARD;                   07640000
            COLUMN(J) = FLAG + LENGTH(NAME) - 1;                                07640500
            COLUMN(J+1) = SHR(VAL, 15);                                         07641000
            COLUMN(J+2) = SHR(VAL, 7);                                          07641500
            COLUMN(J+3) = SHL(VAL, 1);                                          07642000
            TEMP = ADDR(COLUMN(J+4));                                           07643500
            TEMPL = ADDR(MVCSYM);                                               07644000
            CALL INLINE("58", 1, 0, TEMP);                                      07644500
            CALL INLINE("58", 2, 0, NAME);                                      07645000
            CALL INLINE("1B", 3, 3);                                            07645500
            CALL INLINE("43", 3, 0, NAME);                                      07646000
            CALL INLINE("18", 0, 4);                                            07646500
            CALL INLINE("58", 4, 0, TEMPL);                                     07647000
            CALL INLINE("44", 3, 0, 4, 0);                                      07647500
            CALL INLINE("18", 4, 0);                                            07648000
            BYTES_REMAINING = BYTES_REMAINING - Q;                              07648500
            J = J + Q;                                                          07649000
         END EMIT_SYM;                                                          07649500
EMIT_SYM_DATA:PROCEDURE(TYP, SIZ);                                              07650000
            DECLARE (TYP, SIZ, TMP) BIT(16);                                    07650500
            COLUMN(J) = TYP;                                                    07651000
            IF TYP = 0 THEN DO;                                                 07651500
               COLUMN(J+1) = SHR(SIZ-1, 8);                                     07652000
               COLUMN(J+2) = SIZ-1;                                             07652500
               TMP = 3;                                                         07653000
            END;                                                                07653500
            ELSE DO;                                                            07654000
               COLUMN(J+1) = SHL(SIZ,1) - 1;                                    07654500
               TMP = 2;                                                         07655000
            END;                                                                07655500
            BYTES_REMAINING = BYTES_REMAINING - TMP;                            07656000
            J = J + TMP;                                                        07656500
         END EMIT_SYM_DATA;                                                     07657000

         DO I = 1 TO ESD_MAX;                                                   07658000
            IF ESD_TYPE(I) < 1 | ESD_TYPE(I) > 2 THEN DO;                       07658500
               CALL EMIT_SYM(ESD_TABLE(I), 0, "10");                            07659000
               IF I = 1 THEN IF ESD_TABLE(I) = 'START' THEN RETURN;             07659500
               IF I <= SYMBREAK THEN DO;                                        07660000
                  CALL EMIT_SYM('STACK', 0, "20");                              07660500
                  CALL EMIT_SYM('STACKEND', MAXTEMP(I), "80");                  07661000
                  CALL EMIT_SYM_DATA("14", 1);                                  07661500
               END;                                                             07662000
               IF I = PROGPOINT THEN DO;                                        07662500
                  CALL EMIT_SYM('HALS/FC', SYT_LOCK#(SELFNAMELOC), "20");       07663000
                  DO B = 1 TO PROGPOINT - 1;                                    07663500
                     IF SYT_LOCK#(PROC_LEVEL(B)) ^= 0 THEN                      07664000
                        CALL EMIT_SYM(ESD_TABLE(B), SYT_LOCK#(PROC_LEVEL(B)));  07664500
                  END;                                                          07665000
                  CALL EMIT_SYM('HALS/END', 0);                                 07665500
                  CALL EMIT_SYM(ESD_TABLE(I), 0, "10");                          7665600
              CALL EMIT_SYM('D'||SUBSTR(100000+DATE_OF_COMPILATION,1), 1, "40"); 7665700
            CALL EMIT_SYM('T'||SUBSTR(10000000+TIME_OF_COMPILATION,1), 1, "40"); 7665800
               END;                                                             07666000
               IF I > SYMBREAK THEN DO;                                         07666500
                  IF BYTES_REMAINING < 5 THEN CALL EMIT_SYM_CARD;               07667500
                  COLUMN(J) = "88";                                             07668000
                  COLUMN(J+1), COLUMN(J+2), COLUMN(J+3) = 0;                    07668500
                  COLUMN(J+4) = "84";                                           07669000
                  BYTES_REMAINING = BYTES_REMAINING - 5;                        07669500
                  J = J + 5;                                                    07670000
                  IF (OPTION_BITS & "40") ^= 0 THEN                             07670010
                     IF I = DATABASE THEN DO B = PROGPOINT TO PROCLIMIT;        07670500
                     P = PROC_LEVEL(B);                                         07671000
                     DO WHILE P > 0;                                            07671500
                        IF SYT_BASE(P) ^= TEMPBASE THEN DO;                     07672000
                           CALL EMIT_SYM(SYT_NAME(P), SYT_ADDR(P), "80");       07672500
                           T = SYT_TYPE(P);                                     07673000
                           IF (SYT_FLAGS(P) & NAME_FLAG) ^= 0 THEN T = APOINTER; 7673500
                           ELSE IF T >= ANY_LABEL THEN T = INTEGER;              7673600
                           CALL EMIT_SYM_DATA(SYMCARD(T), BIGHTS(T));           07674000
                        END;                                                    07674500
                        P = SYT_LEVEL(P);                                       07675000
                     END;                                                       07675500
                  END;                                                          07676000
               END;                                                             07676500
            END;  /* ESD_TYPE ^= 2  */                                          07677000
         END;  /* DO I  */                                                      07677500
      END EMIT_SYM_CARDS;                                                       07681000
 ?/
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
EMIT_ESD_CARDS:PROCEDURE;                                                       07682000
         DECLARE                                                                07682500
            TEMP FIXED,                                                         07683000
            EMITTING_ESDS BIT(1), J BIT(16),                                     7683500
            ESD# BIT (16);                                                      07684000
         CALL EMIT_SYM_CARDS;                                                   07684500
         ESD# = 1;                                                              07685000
         EMITTING_ESDS = TRUE;                                                   7685500
DO_EMITTING_ESDS:                                                                7685600
         DO WHILE EMITTING_ESDS;                                                 7685700
            CALL EMIT_CARD;                                                     07686500
            BYTES_REMAINING, CURRENT_SIZE = 48;                                 07687000
            CARDIMAGE, CARDIMAGE(1) = ESD_CARD;                                 07687500
            CARDIMAGE(4) = "40400000" + ESD#;                                   07688000
DO_J:                                                                           07688500
            DO J = 5 TO 13 BY 4;                                                07689000
               IF ESD# <= ESD_MAX THEN                                          07689500
DO_ESD#:                                                                        07690000
               DO;                                                              07690500
                  BYTES_REMAINING=BYTES_REMAINING-16;                           07691000
                  S1=PAD(ESD_TABLE(ESD#),10);                                   07691500
                  TEMP=ADDR(CARDIMAGE(J));                                      07692000
                  CALL INLINE ("58",2,0,S1);                                    07692500
                  CALL INLINE ("58",1,0,TEMP);                                  07693000
                  CALL INLINE ("D2",0,7,1,0,2,0);                               07693500
                  IF ESD_TYPE(ESD#) = 2 THEN DO;                                07694000
                     CARDIMAGE(J+2)="02000000";                                 07694500
 /*--------------------------------------------------------------------------*/
 /* DAS CR11094: PUT A "1" IN THE BLANK FIELD AFTER THE ADDRESS FIELD        */
 /* PMA          IN THE ESD DATA ITEM PORTION OF THE ESD CARD OF A REMOTELY  */
 /*              INCLUDED COMPOOL SO THAT THE PRELINKER WILL KNOW TO PUT     */
 /*              IT IN A REMOTE BANK.                                        */
 /* (#DFLAG)     SAME IS TRUE FOR EXTERNAL COMSUB WITH DATA_REMOTE.          */
                     IF ((SYT_FLAGS(PROC_LEVEL(ESD#)) & REMOTE_FLAG)^=0)
                        & (ESD_TABLE(ESD#) ^= THISPROGRAM)         /*DR103798*/
                     THEN DO;                                                   11152008
                        CARDIMAGE(J+3)="01404040";                              11153008
   /* CR11120 --- UNSET THE REMOTE FLAG OF EXTERNAL COMSUB ---*/                11151008
                        IF SYT_TYPE(PROC_LEVEL(ESD#)) ^= COMPOOL_LABEL          11153109
                        THEN SYT_FLAGS(PROC_LEVEL(ESD#)) =                      11154009
                           SYT_FLAGS(PROC_LEVEL(ESD#)) & ^REMOTE_FLAG;          11155008
                     END;                                                       11156008
                     ELSE
                        CARDIMAGE(J+3)="40404040";                              07695000
 /*--------------------------------------------------------------------------*/
                  END;                                                          07695500
                  ELSE IF ESD_TYPE(ESD#) = 1 THEN DO;                           07696000
                  CARDIMAGE(J+2) = "01000000" + SHL(SYT_ADDR(ESD_LINK(ESD#)),1);07696500
                     CARDIMAGE(J+3) = "40000000" + SYT_BASE(ESD_LINK(ESD#));     7697000
                  END;                                                          07697500
                  ELSE DO;                                                      07698000
                    CARDIMAGE(J+2)=SHL(ESD_TYPE(ESD#),24) + SHL(ORIGIN(ESD#),1);07698500
                     CARDIMAGE(J+3)="40000000" + SHL(LOCCTR(ESD#),1);           07699000

/*-RSJ---CR11096F--------- PRELINK - #DFLAG ----------------------*/
/* DANNY>>> PUT A "1" IN THE BLANK FIELD AFTER THE ADDRESS FIELD  */
/*          IN THE ESD CARD OF THE CODE CSECT IF DATA_REMOTE IS   */
/*          IN EFFECT SO PRELINKER WILL PUT ITS #D CSECT REMOTE.  */
                     IF DATA_REMOTE & (ESD# = PROGPOINT) THEN
                        CARDIMAGE(J+3)="01000000" + SHL(LOCCTR(ESD#),1);
/*----------------------------------------------------------------*/
                  END;                                                          07700000
                                                                                07700500
                  IF CODE_LISTING_REQUESTED THEN DO;                            07701000
                     IF ESD# = 1 THEN DO;                                       07701500
                        CALL AHEADSET(1);                                       07702000
                     END;                                                       07703000
                     S2 = LEFTHEX(SHL(ESD#,16),4);                              07703500
                     S1 = BLANK || S1 || ESD_CHAR(ESD_TYPE(ESD#));              07704000
                     IF ESD_TYPE(ESD#) < 1 | ESD_TYPE(ESD#) > 2 THEN DO;        07704500
                        S1 = S1 || S2;                                          07705000
                        S2 = LEFTHEX(SHL(ORIGIN(ESD#),8),6);                    07707000
                        S1 = S1 || S2;                                          07707500
                        S2=LEFTHEX(SHL(LOCCTR(ESD#),8),6);                      07708000
                        /*CR12713 - PRINT LENGTH IN DECIMAL.                */
                        S2=S2||'  '||FORMAT(LOCCTR(ESD#),10);      /*CR12713*/
                        S1=S1 || S2;                                            07708500
                     END;                                                       07709000
                     ELSE IF ESD_TYPE(ESD#) = 1 THEN DO;                        07712500
                        S2 = LEFTHEX(SHL(SYT_ADDR(ESD_LINK(ESD#)),8),6);        07713000
                        S1 = S1 || SUBSTR(X72, 67) || S2;                       07713500
                        S2 = LEFTHEX(SHL(SYT_BASE(ESD_LINK(ESD#)),16),4);        7714000
                        S1 = S1 || SUBSTR(X72, 53) || S2;          /*CR12713*/  07714500
                     END;                                                       07715000
                     ELSE S1 = S1 || S2 || SUBSTR(X72, 46);        /*CR12713*/  07715500
                     IF ESD# <= PROCLIMIT THEN                                  07716000
                       S1 = S1 || SUBSTR(X72, 63) || SYT_NAME(PROC_LEVEL(ESD#));07716500
                     CALL APRINT(S1);                                           07717000
                  END;                                                          07717500
                                                                                07718000
                  ESD# = ESD# + 1;                                              07718500
               END DO_ESD#;                                                     07719000
               ELSE IF ENTRYPOINT > 0 THEN DO;                                   7719050
                  ESD# = ESD# - 1;                                               7719100
                  CALL ENTER_ESD(SYT_NAME(ENTRYPOINT), ESD#, 1);                 7719150
                  ESD_LINK(ESD#) = ENTRYPOINT;                                   7719200
                  ENTRYPOINT = SYT_LINK1(ENTRYPOINT);                            7719250
                  GO TO DO_ESD#;                                                 7719300
               END;                                                              7719350
               ELSE EMITTING_ESDS = FALSE;                                       7719400
            END DO_J;                                                           07719500
         END DO_EMITTING_ESDS;                                                   7720000
      END EMIT_ESD_CARDS;                                                       07720500
                                                                                07721000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT  */
         /* ROUTINE TO EMIT THE START CARD OF THE OBJECT MODULE */

EMIT_START_CARD: PROCEDURE;

DECLARE
        START_CARD_ID                  LITERALLY '"0102"';

   RECORD_ID = START_CARD_ID;
   CARD_IMAGE(1) = SYT_LOCK#(SELFNAMELOC);
   CALL EMIT_CARD;                                                              07633000
END EMIT_START_CARD;

         /* ROUTINE TO EMIT DEFINITION CARDS AT START OF OBJECT MODULE */
                                                                                07681500
EMIT_ESD_CARDS:PROCEDURE;                                                       07682000

DECLARE
        WORK_CHARS                     CHARACTER,
        HAL_NAME_CHARS                 CHARACTER,
        HAL_NAME_LENGTH                BIT(16),
        LAST_INDEX                     BIT(16),
        ENT_ID                         LITERALLY '"0307"',
        ENTRY_NAME                     LITERALLY 'WORK_CHARS',
        ENTRY_NAME_LOC                 LITERALLY 'ADDR(CARD_IMAGE(1))',
        ENTRY_ADDR                     LITERALLY 'CARD_IMAGE(5)',
        CSD_INDEX                      LITERALLY 'CARD_IMAGE(6)',
        ESD#                           BIT (16);                                07684000

            /* ROUTINE TO PAD NAME WITH BLANK IF ODD NUMBER OF BYTES */

   CHECK_PAD: PROCEDURE(START);

   DECLARE
           START                          BIT(16),
           PAD_CHAR                       LITERALLY '"0040"';

      IF (HAL_NAME_LENGTH & 1) ^= 0 THEN DO;
         HAL_NAME_LENGTH = HAL_NAME_LENGTH + 1;
         LAST_INDEX = SHR(HAL_NAME_LENGTH, 1) + START;
         CARD_IMAGE(LAST_INDEX) = (CARD_IMAGE(LAST_INDEX) & "FF00") | PAD_CHAR;
      END;                                                                      07695500

   END CHECK_PAD;


            /* ROUTINE TO EMIT CSECT DEFINITION CARD */

   EMIT_CSD_CARD: PROCEDURE;

   DECLARE
           CSD_ID                         LITERALLY '"0200"',
           TEMP_TYPE                      LITERALLY 'LAST_INDEX',
           CSECT_NAME                     LITERALLY 'WORK_CHARS',
           CSECT_NAME_LOC                 LITERALLY 'ADDR(CARD_IMAGE(1))',
           CSECT_LENGTH                   LITERALLY 'CARD_IMAGE(5)',
           CSD_STACK_SIZE                 LITERALLY 'CARD_IMAGE(6)',
           FLAG_LENGTH_FIELD              LITERALLY 'CARD_IMAGE(7)',
           HAL_NAME_LOC                   LITERALLY 'ADDR(CARD_IMAGE(8))';

      CSECT_NAME = PAD(ESD_TABLE(ESD#), 9);
      CALL MOVE_CHARS(CSECT_NAME, CSECT_NAME_LOC, 8);
      CSECT_LENGTH = LOCCTR(ESD#);
      TEMP_TYPE = ESD_CSECT_TYPE(ESD#);

      IF ESD# <= PROCLIMIT THEN DO;

         IF (TEMP_TYPE & "C0") = CODE_CSECT_TYPE THEN
            CSD_STACK_SIZE = MAXTEMP(ESD#);
         ELSE
            CSD_STACK_SIZE = 0;

         HAL_NAME_CHARS = SYT_NAME(PROC_LEVEL(ESD#));
      END;
      ELSE
         IF TEMP_TYPE = ZCON_CSECT_TYPE THEN DO;
            HAL_NAME_CHARS = SYT_NAME(ESD_LINK(ESD#));
            CSD_STACK_SIZE = 1;
         END;                                                                   07697500
         ELSE DO;                                                               07698000
            HAL_NAME_CHARS = '';
            CSD_STACK_SIZE = 0;
         END;

      HAL_NAME_LENGTH = LENGTH(HAL_NAME_CHARS);
      FLAG_LENGTH_FIELD = SHL(TEMP_TYPE & "C0", 8) | HAL_NAME_LENGTH;
      CALL MOVE_CHARS(HAL_NAME_CHARS, HAL_NAME_LOC, HAL_NAME_LENGTH);
      CALL CHECK_PAD(7);
      RECORD_ID = CSD_ID | (SHR(HAL_NAME_LENGTH, 1) + 8);
      CALL EMIT_CARD;

   END EMIT_CSD_CARD;


            /* ROUTINE TO EMIT EXTERNAL REFERENCE DEFINITION CARD */

   EMIT_EXR_CARD: PROCEDURE;

   DECLARE
           LIBRARY_VERSION                LITERALLY '3',
           EXR_ID                         LITERALLY '"0400"',
           EXR_NAME                       LITERALLY 'WORK_CHARS',
           EXR_NAME_LOC                   LITERALLY 'ADDR(CARD_IMAGE(1))',
           EXR_VERSION                    LITERALLY 'CARD_IMAGE(5)',
           FLAG_LENGTH_FIELD              LITERALLY 'CARD_IMAGE(6)',
           TEMP_SYT                       LITERALLY 'LAST_INDEX',
           HAL_NAME_LOC                   LITERALLY 'ADDR(CARD_IMAGE(7))';

      EXR_NAME = PAD(ESD_TABLE(ESD#), 9);
      CALL MOVE_CHARS(EXR_NAME, EXR_NAME_LOC, 8);

      IF ESD# <= PROCLIMIT THEN DO;
         TEMP_SYT = PROC_LEVEL(ESD#);
         EXR_VERSION = SYT_LOCK#(TEMP_SYT);
         HAL_NAME_CHARS = SYT_NAME(TEMP_SYT);
         HAL_NAME_LENGTH = LENGTH(HAL_NAME_CHARS);
      END;
      ELSE DO;

         IF ESD_CSECT_TYPE(ESD#) = LIBRARY_CSECT_TYPE THEN
            EXR_VERSION = LIBRARY_VERSION;
         ELSE
            EXR_VERSION = 0;

         HAL_NAME_CHARS = '';
         HAL_NAME_LENGTH = 0;
      END;

      FLAG_LENGTH_FIELD = SHL(ESD_CSECT_TYPE(ESD#) & "C0", 8) | HAL_NAME_LENGTH;
      CALL MOVE_CHARS(HAL_NAME_CHARS, HAL_NAME_LOC, HAL_NAME_LENGTH);
      CALL CHECK_PAD(6);
      RECORD_ID = EXR_ID | (SHR(HAL_NAME_LENGTH, 1) + 7);
      CALL EMIT_CARD;

   END EMIT_EXR_CARD;


            /* ROUTINE TO EMIT LINK EDIT CONTROL CARD */

   EMIT_LEC_CARD: PROCEDURE;

   DECLARE
           LEC_ID                         LITERALLY '"0500"',
           LIT_TEXT                       LITERALLY 'HAL_NAME_CHARS',
           LIT_TEXT_LENGTH                LITERALLY 'HAL_NAME_LENGTH',
           LEC_TEXT_LOC                   LITERALLY 'ADDR(CARD_IMAGE(1))';

      LIT_TEXT = STRING(LIT2(GET_LITERAL(ESD_LINK(ESD#))));
      LIT_TEXT_LENGTH = LENGTH(LIT_TEXT);
      CALL MOVE_CHARS(LIT_TEXT, LEC_TEXT_LOC, LIT_TEXT_LENGTH);
      CALL CHECK_PAD(0);
      LIT_TEXT_LENGTH = SHR(LIT_TEXT_LENGTH, 1) + 1;
      RECORD_ID = LEC_ID | LIT_TEXT_LENGTH;
      CALL EMIT_CARD;
   END EMIT_LEC_CARD;

   IF CODE_LISTING_REQUESTED THEN
      CALL AHEADSET(1);

DO_ESD#:
/*- PMA --------------------#DFLAG-----------------------------------*/
/*                                                                   */
/* WARNING - BFS 8V0 (WHICH ADDED "DATA_REMOTE" CAPABILITIES) DID    */
/*           NOT IMPLEMENT CR11096F AND CR11120 IN THIS BFS SECTION  */
/*           OF THE COMPILER.  THESE CR CHANGES RELIED ON A          */
/*           PREVIOUS CR11094 IMPLEMENTED IN PASS 23V2 WHICH WAS     */
/*           NOT MERGED INTO BFS 7V0, THUS NOT EXISTING IN 8V0.      */
/*           IN ADDITION,THESE CHANGES INVOLVE USE OF A PRELINKER    */
/*           WHICH IS NOT UTILIZED BY BFS AS OF THIS RELEASE.        */
/*           IF AND WHEN BFS BEGINS USING "DATA_REMOTE", THE         */
/*           AFOREMENTIONED CRS WILL HAVE TO BE ENGINEERED INTO      */
/*           THIS BFS SPECIFIC SECTION, "DO_ESD#".                   */
/*           THE CHANGES CAN BE REFERENCED IN THE PASS SPECIFIC      */
/*           "DO_ESD#" PROCEDURE ABOVE THIS SECTION.                 */
/*-------------------------------------------------------------------*/
   DO FOR ESD# = 1 TO ESD_MAX;

      DO CASE ESD_TYPE(ESD#);

         CALL EMIT_CSD_CARD;

         ;   /* ENTRIES DONE IN DO_ENTS LOOP */

         CALL EMIT_EXR_CARD;

         CALL EMIT_LEC_CARD;

      END;                                                                      07700000
                                                                                07700500
      IF CODE_LISTING_REQUESTED THEN DO;                                        07701000

         S2 = LEFTHEX(SHL(ESD#, 16), 4)|| SUBSTR(X72, 70);
         S1 = BLANK || WORK_CHARS;
            /* WORK_CHARS IS SET BY EMIT_XXX_CARD ROUTINES */

         DO CASE ESD_TYPE(ESD#);

            S1 = S1 || 'CSD' || S2 || LEFTHEX(SHL(ORIGIN(ESD#), 16), 4) ||
               SUBSTR(X72, 70) || LEFTHEX(SHL(LOCCTR(ESD#), 16), 4) /*CR12713*/
               || SUBSTR(X72, 70) || FORMAT(LOCCTR(ESD#),10);       /*CR12713*/
            ;   /* ENTRIES DONE IN DO_ENTS LOOP */

            S1=S1||'EXR'||LEFTHEX(SHL(ESD#, 16), 4)||SUBSTR(X72,46);/*CR12713*/

            S1 = SUBSTR(X72, 62) || 'LEC' || SUBSTR(X72, 41);       /*CR12713*/

         END;                                                                   07703000

         IF (ESD# <= PROCLIMIT) | (ESD_TYPE(ESD#) = LEC) THEN
            S1 = S1 || SUBSTR(X72, 63) || HAL_NAME_CHARS;
         CALL APRINT(S1);

      END;                                                                      07709000

   END DO_ESD#;

DO_ENTS:
   DO WHILE ENTRYPOINT >  0;

      CALL ENTER_ESD(SYT_NAME(ENTRYPOINT), 0, 1, 0);
         /* USE 0TH ENTRY OF ESD TABLE */

      RECORD_ID = ENT_ID;
      ENTRY_NAME = PAD(ESD_TABLE(0), 9);
      CALL MOVE_CHARS(ENTRY_NAME, ENTRY_NAME_LOC, 8);
      ENTRY_ADDR = SYT_ADDR(ENTRYPOINT);
      CSD_INDEX = DATABASE(SYT_BASE(ENTRYPOINT));
      CALL EMIT_CARD;

      IF CODE_LISTING_REQUESTED THEN DO;
         S1 = BLANK || WORK_CHARS || 'ENT' || SUBSTR(X72, 65) ||
            LEFTHEX(SHL(ENTRY_ADDR, 16), 4) || SUBSTR(X72, 53) ||   /*CR12713*/
            LEFTHEX(SHL(CSD_INDEX, 16), 4);
                     CALL APRINT(S1);                                           07717000
      END;                                                                      07717500
      ENTRYPOINT = SYT_LINK1(ENTRYPOINT);                                       07718000

   END DO_ENTS;

END EMIT_ESD_CARDS;                                                             07720500
 ?/
                                                                                07721500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT  */

/*CR12713 - THIS NEW PROCEDURE WILL SET UP THE RLD COLUMN TITLES AS THE      */
/*          SUBHEADER, AND PRINT A LEGEND PRIOR TO THE COLUMN TITLES.        */
/*          THIS ROUTINE WILL NOW BE CALLED INSTEAD OF AHEADSET FOR THE RLD  */
/*          SECTION OF THE LISTING.                                          */
PRINT_RLD_LEGEND: PROCEDURE;
      ABSLIST_COUNT = LINE_LIM;
      OUTPUT(1) = AHEAD(3);
      OUTPUT(1) = '1';
      OUTPUT(1) = AHEAD(2);
      OUTPUT(1) = ' RLD INFORMATION';
      OUTPUT(1) = '';
      S1 = ' POS.ID (P) IS THE ESDID OF SD FOR THE CONTROL ';
      S1 = S1||'SECTION THAT CONTAINS THE ADDRESS CONSTANT';
      OUTPUT(1) = S1;
      S1 = ' REL.ID (R) IS THE ESDID OF ESD ENTRY FOR THE ';
      S1 = S1||'SYMBOL BEING REFERRED TO';
      OUTPUT(1) = S1;
      OUTPUT(1) = '';
      S1 = '  FLAG        TYPE';
      S2 = 'ACTION PERFORMED';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||SUBSTR(X72,0,32)||S2;
      OUTPUT(1) = '';
      S1 = 'V00000ST      YCON      RELOCATION FACTOR IS ADDED TO ADDRESS ';
      S2 = 'CONSTANT.  IF ADDRESS IS GREATER THAN 15 BITS, SET BIT "0" ON.';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||S2;
      S1 = '000001ST      ACON      RELOCATION FACTOR IS ADDED TO ADDRESS ';
      S2 = 'CONSTANT.';
      OUTPUT(1) =  SUBSTR(X72,0,8)||S1||S2;
      S1 = 'V00100ST      ZCON      ADD RELOCATION FACTOR TO FIRST HALFWORD.';
      S2 = '  IF GREATER THAN 15 BITS, UPDATE BSR FIELD.';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||S2;
      OUTPUT(1) = SUBSTR(X72,0,32)||'(BRANCH RELOCATION FOR 32-BIT BRANCH)';
      S1 = 'V10000ST      ZCON      UPDATE DSR FIELD WITH HIGH ORDER 4 BITS ';
      S2 = 'OF THE 19-BIT RELOCATION FACTOR.';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||S2;
      OUTPUT(1) = SUBSTR(X72,0,32)||'(DATA RELOCATION FOR 32-BIT BRANCH)';
      S1 = 'V01000ST      ZCON      UPDATE BSR FIELD WITH HIGH ORDER 4 BITS ';
      S2 = 'OF THE 19-BIT RELOCATION FACTOR.';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||S2;
      OUTPUT(1) = SUBSTR(X72,0,32)||'(BRANCH RELOCATION FOR 32-BIT DATA)';
      S1 = 'V10100ST      ZCON      ADD RELOCATION FACTOR TO FIRST HALFWORD.';
      S2 = '  IF GREATER THAN 15-BITS, UPDATE DSR FIELD.';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||S2;
      OUTPUT(1) = SUBSTR(X72,0,32)||'(DATA RELOCATION FOR 32-BIT DATA)';
      OUTPUT(1) = '';
      OUTPUT(1) = SUBSTR(X72,0,8)||'V = SIGN OF THE YCON IN THE TEXT RECORD';
      OUTPUT(1) = SUBSTR(X72,0,13)||'0 = THE YCON IS POSITIVE';
      S1 = '1 = THE YCON IS THE ABSOLUTE VALUE OF A NEGATIVE NUMBER';
      OUTPUT(1) = SUBSTR(X72,0,13)||S1;
      OUTPUT(1) = SUBSTR(X72,0,8)||'S = DIRECTION OF RELOCATION';
      OUTPUT(1) = SUBSTR(X72,0,13)||'0 = POSITIVE';
      OUTPUT(1) = SUBSTR(X72,0,13)||'1 = NEGATIVE';
      OUTPUT(1) = SUBSTR(X72,0,8)||'T = TYPE OF NEXT RLD ITEM';
      S1 = '0 = NEXT RLD ITEM HAS DIFFERENT R OR P POINTERS; THEY ARE ';
      S2 = 'IN THE NEXT ITEM';
      OUTPUT(1) = SUBSTR(X72,0,13)||S1||S2;
      S1 = '1 = NEXT RLD ITEM HAS SAME R AND P POINTERS; HENCE THEY ARE ';
      S2 = 'OMITTED';
      OUTPUT(1) = SUBSTR(X72,0,13)||S1||S2;
      OUTPUT(1) = '';
      OUTPUT(1) = X2||SUBSTR(AHEAD(2),2);
      OUTPUT(1) = '';
   END PRINT_RLD_LEGEND;

EMIT_RLD_CARDS:PROCEDURE;                                                       07722000
         DECLARE (I,J,TEMP) BIT(16), FLAG BIT(1);                               07722500
         IF RLD# = 0 THEN RETURN;                                               07723000
         FLAG=0;                                                                07723500
EMIT_RLD_CARD:                                                                  07724000
         PROCEDURE;                                                             07724500
            CALL EMIT_CARD;                                                     07725000
            BYTES_REMAINING, CURRENT_SIZE = 48;                                 07725500
            CARDIMAGE,CARDIMAGE(1) = RLD_CARD;                                  07726000
            J = 5;                                                              07726500
         END;                                                                   07727000
RLD_LOOP:                                                                       07727500
         PROCEDURE;                                                             07727510
            DO WHILE RLD_POS_HEAD(I) > 0;                                       07729000
               TEMP = GET_RLD(RLD_POS_HEAD(I));                                 07729500
               IF RLD_REF(TEMP) ^= 0 THEN DO;                                   07730000
                  CARDIMAGE(J)=SHL(RLD_REF(TEMP), 16) + I;                      07730500
                CARDIMAGE(J+1)=SHL(RLD_ADDR(TEMP),1)|(RLD_REF(TEMP)&"FF000000");07731000
                  IF CODE_LISTING_REQUESTED THEN DO;                            07731500
                     IF FLAG = 0 THEN DO;                           /*CR12713*/ 07732000
                        FLAG = 1;                                   /*CR12713*/
                        HEADOUT = FALSE;                            /*CR12713*/
                        CALL PRINT_RLD_LEGEND;                      /*CR12713*/
                     END;                                           /*CR12713*/
                     S1=LEFTHEX(SHL(RLD_REF(TEMP),16),4);           /*CR12713*/
                     S2=LEFTHEX(SHL(RLD_ADDR(TEMP),8),6);                       07734000
                     DUMMY=LEFTHEX(CARDIMAGE(J+1),2);                           07734500
                     S1=S1||X4||' '||PAD(ESD_TABLE(RLD_REF(TEMP)),8); /*12713*/
                     S2=' '||PAD(ESD_TABLE(I),8)||X3||S2;           /*CR12713*/
 /*CR12713*/         S1=LEFTHEX(SHL(I,16),4)||X4||S2||X4||DUMMY||X4||X4||S1;    07735000
                     CALL APRINT(X2 || S1);                                     07735500
                  END;                                                          07737000
                  BYTES_REMAINING = BYTES_REMAINING - 8;                        07737500
                  J = J + 2;                                                    07738000
                  IF J > 17 THEN CALL EMIT_RLD_CARD;                            07738500
               END;                                                             07739000
               RLD_POS_HEAD(I) = RLD_LINK(TEMP);                                07740500
            END;                                                                07741000
         END RLD_LOOP;                                                          07741500
         CALL EMIT_RLD_CARD;                                                    07741520
         IF REMOTE_LEVEL > 0 THEN DO;                                           07741530
            I = REMOTE_LEVEL;                                                   07741530
            CALL RLD_LOOP;                                                      07741530
         END;                                                                   07741530
         DO I = PROGPOINT TO DATABASE;                                          07741530
            CALL RLD_LOOP;                                                      07741540
         END;                                                                   07741550
         RLD# = 0;                                                              07741630
      END EMIT_RLD_CARDS;                                                       07742500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT  */

/*CR12713 - THIS NEW PROCEDURE WILL SET UP THE RLD COLUMN TITLES AS THE      */
/*          SUBHEADER, AND PRINT A LEGEND PRIOR TO THE COLUMN TITLES.        */
/*          THIS ROUTINE WILL NOW BE CALLED INSTEAD OF AHEADSET FOR THE RLD  */
/*          SECTION OF THE LISTING.                                          */
PRINT_RLD_LEGEND: PROCEDURE;
      ABSLIST_COUNT = LINE_LIM;
      OUTPUT(1) = AHEAD(3);
      OUTPUT(1) = '1';
      OUTPUT(1) = AHEAD(2);
      OUTPUT(1) = ' RLD INFORMATION';
      OUTPUT(1) = '';
      S1 = ' POS.ID (P) IS THE ESDID OF SD FOR THE CONTROL ';
      S1 = S1||'SECTION THAT CONTAINS THE ADDRESS CONSTANT';
      OUTPUT(1) = S1;
      S1 = ' REL.ID (R) IS THE ESDID OF ESD ENTRY FOR THE ';
      S1 = S1||'SYMBOL BEING REFERRED TO';
      OUTPUT(1) = S1;
      OUTPUT(1) = ' FLAGS IS OF THE FOLLOWING FORM:';
      OUTPUT(1) = '';
      S1 = 'V0101100 - CODE WITH ZCON SECTOR';
      S2 = 'V IS THE SIGN OF THE HALFWORD ADDRESS CONSTANT AS FOLLOWS:';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||SUBSTR(X72,0,17)||S2;
      S1 = 'V0101000 - CODE WITH ZCON SECTOR AND ADDRESS';
      S2 = '0 = POSITIVE';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||SUBSTR(X72,0,10)||S2;
      S1 = 'V0001100 - DATA WITH ZCON SECTOR';
      S2 = '1 = THE HALFWORD IS THE ABSOLUTE VALUE OF A NEGATIVE NUMBER';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||SUBSTR(X72,0,22)||S2;
      S1 = 'V0001000 - DATA WITH ZCON SECTOR AND ADDRESS';
      S2 = 'XX CONTAINS ESD_CSECT_TYPE(R) AS FOLLOWS:';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||SUBSTR(X72,0,5)||S2;
      S1 = 'V0XX0000 - 2 BYTE STANDARD ADDRESS TYPE';
      S2 = '01 = ZCON_CSECT_TYPE';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||SUBSTR(X72,0,15)||S2;
      S1 = 'V0XX0100 - 4 BYTE STANDARD ADDRESS TYPE';
      S2 = '10 = LIBRARY_CSECT_TYPE';
      OUTPUT(1) = SUBSTR(X72,0,8)||S1||SUBSTR(X72,0,15)||S2;
      OUTPUT(1) = '';
      OUTPUT(1) = X2||SUBSTR(AHEAD(2),2);
      OUTPUT(1) = '';
   END PRINT_RLD_LEGEND;

         /* ROUTINE TO EMIT RELOCATION DICTIONARY CARDS AFTER TEXT CARDS */

EMIT_RLD_CARDS:PROCEDURE;                                                       07722000

DECLARE
        FLAG                           BIT(1),
        #RLD_HALFWORDS                 BIT(16),
        RLD_ID                         LITERALLY '"0800"',
        R_POINTER                      BIT(16),
        ASSEMBLED_FLAGS                BIT(16),
        P_POINTER                      BIT(16),
        THIS_RLD                       BIT(16),
        THIS_RLD_REF                   FIXED,
        THIS_RLD_ADDR                  FIXED;


            /* ROUTINE TO FLUSH AN RLD CARD */

   FLUSH_RLD_CARD: PROCEDURE;

      IF #RLD_HALFWORDS = 0 THEN
         RETURN;
      RECORD_ID = RECORD_ID | (#RLD_HALFWORDS + 1);
      CALL EMIT_CARD;                                                           07725000
      RECORD_ID = RLD_ID;
      #RLD_HALFWORDS = 0;

   END FLUSH_RLD_CARD;


            /* ROUTINE TO ADD AN RLD TO A CARD */

   ADD_RLD: PROCEDURE(R_POINTER, P_POINTER, FLAGS, ADDRESS);

   DECLARE
        R_POINTER                      BIT(16),
        P_POINTER                      BIT(16),
        FLAGS                          BIT(16),
        ADDRESS                        BIT(16),
        WHICH_ACD                      BIT(1),
        LAST_R_POINTER                 BIT(16),
        LAST_P_POINTER                 BIT(16),
        FULL_ACD                       LITERALLY '1',
        GROUPED_ACD                    LITERALLY '0',
        LAST_RLD_FLAG                  LITERALLY 'CARD_IMAGE(#RLD_HALFWORDS-1)',
        R_POINTER_HALFWORD             LITERALLY 'CARD_IMAGE(#RLD_HALFWORDS+1)',
        P_POINTER_HALFWORD             LITERALLY 'CARD_IMAGE(#RLD_HALFWORDS+2)',
        FLAGS_HALFWORD                 LITERALLY 'CARD_IMAGE(#RLD_HALFWORDS+1)',
        ADDRESS_HALFWORD               LITERALLY 'CARD_IMAGE(#RLD_HALFWORDS+2)';

      WHICH_ACD = FULL_ACD;

      IF (R_POINTER = LAST_R_POINTER) & (P_POINTER = LAST_P_POINTER) &
         (#RLD_HALFWORDS ^= 0) THEN DO;
         IF #RLD_HALFWORDS + 3 > 255 THEN
            CALL FLUSH_RLD_CARD;
         ELSE DO;
            WHICH_ACD = GROUPED_ACD;
            LAST_RLD_FLAG = LAST_RLD_FLAG | 1;
         END;                                                                   07727000
      END;
      ELSE
         IF #RLD_HALFWORDS + 5 > 255 THEN
            CALL FLUSH_RLD_CARD;

      DO CASE WHICH_ACD;

         ;   /* DO ONLY STUFF AFTER THE CASE */

         DO;   /* FULL ACD, INCLUDE R AND P POINTERS */
            R_POINTER_HALFWORD = R_POINTER;
            P_POINTER_HALFWORD = P_POINTER;
            #RLD_HALFWORDS = #RLD_HALFWORDS + 2;
         END;

      END;

      FLAGS_HALFWORD = FLAGS;
      ADDRESS_HALFWORD = ADDRESS;
      #RLD_HALFWORDS = #RLD_HALFWORDS + 2;
      LAST_P_POINTER = P_POINTER;
      LAST_R_POINTER = R_POINTER;

   END ADD_RLD;


            /* ROUTINE TO ASSEMBLE APPROPRIATE RLD FLAG INFORMATION */

   ASSEMBLE_RLD_FLAGS: PROCEDURE(OLD_FLAGS, R_POINTER) BIT(16);

   DECLARE
           OLD_FLAGS                      BIT(16),
           R_POINTER                      BIT(16),
           RET                            BIT(16);

      RET = OLD_FLAGS & "0080";   /* RETAIN C FLAG */
      IF (OLD_FLAGS & "0004") ^= 0 THEN
         RET = RET | "0004";   /* OR IN TT FLAG FOR A TYPE */

      DO CASE SHR(OLD_FLAGS, 4) & "7";
         RET = RET | SHR(ESD_CSECT_TYPE(R_POINTER) & "C0", 2);/* TAKE DEFAULT */
         RET = RET | "002C";   /* 001 -> CODE WITH ZCON SECTOR AND ADDRESS */
         RET = RET | "0028";   /* 010 -> CODE WITH ZCON SECTOR AND ADDRESS */
         ;                     /* 011 */
         RET = RET | "0018";   /* 100 -> DATA WITH ZCON SECTOR */
         RET = RET | "001C";   /* 101 -> DATA WITH ZCON SECTOR AND ADDRESS */
         ;                     /* 110 */
         ;                     /* 111 */
      END;

      RETURN RET;

   END ASSEMBLE_RLD_FLAGS;

BFS_RLD_LOOP:PROCEDURE;
   DO WHILE RLD_POS_HEAD(P_POINTER) > 0;

         THIS_RLD = GET_RLD(RLD_POS_HEAD(P_POINTER));
         THIS_RLD_REF = RLD_REF(THIS_RLD);
         THIS_RLD_ADDR = RLD_ADDR(THIS_RLD);

         IF THIS_RLD_REF ^= 0 THEN DO;

            R_POINTER = THIS_RLD_REF & FFOUR;
            ASSEMBLED_FLAGS = ASSEMBLE_RLD_FLAGS(SHR(THIS_RLD_REF, 24) & FTWO,
               R_POINTER);
            CALL ADD_RLD(R_POINTER, P_POINTER, ASSEMBLED_FLAGS, THIS_RLD_ADDR);

            IF CODE_LISTING_REQUESTED THEN DO;                                  07731500

               IF FLAG = 0 THEN DO;
                  FLAG = 1;                                         /*CR12713*/
                  HEADOUT = FALSE;
                  CALL PRINT_RLD_LEGEND;                            /*CR12713*/
                  APAGE = 2;                                     /* DR111316 */
               END;

               S1 = LEFTHEX(SHL(THIS_RLD_REF, 16), 4);
               S2 = LEFTHEX(SHL(THIS_RLD_ADDR, 16), 4);
               DUMMY = LEFTHEX(SHL(ASSEMBLED_FLAGS, 24), 2);
               S1 = S1 || '     ' || PAD(ESD_TABLE(THIS_RLD_REF),8);/*CR12713*/
               S2 = ' ' || PAD(ESD_TABLE(P_POINTER),8) || X4 || S2; /*CR12713*/
               S1 = LEFTHEX(SHL(P_POINTER, 16), 4) || X4 || S2 ||   /*CR12713*/
                    '     ' || DUMMY || SUBSTR(X72, 0, 8) || S1;    /*CR12713*/
               CALL APRINT(X2 || S1);                                           07735500
            END;                                                                07737000
         END;                                                                   07739000

         RLD_POS_HEAD(P_POINTER) = RLD_LINK(THIS_RLD);

   END;                                                                         07741000

   END BFS_RLD_LOOP;

   IF RLD# = 0 THEN
      RETURN;

   FLAG = 0;
   #RLD_HALFWORDS = 0;
   RECORD_ID = RLD_ID;

   IF REMOTE_LEVEL > 0 THEN DO;
      P_POINTER = REMOTE_LEVEL;
      CALL BFS_RLD_LOOP;
   END;
   DO FOR P_POINTER = PROGPOINT TO DATABASE;
      CALL BFS_RLD_LOOP;
   END;
   CALL FLUSH_RLD_CARD;
   RLD# = 0;                                                                    07741630
END EMIT_RLD_CARDS;                                                             07742500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
         /* ROUTINE TO EMIT THE END OF OBJECT MODULE CARD */

EMIT_END_CARD: PROCEDURE;

DECLARE
        END_CARD_ID                    LITERALLY '"0914"',
        COMPILER_ID                    CHARACTER,
        HAL_VERSION_NAME               LITERALLY 'ADDR(CARD_IMAGE(2))',
        HAL_VERSION_ID                 LITERALLY 'CARD_IMAGE(7)',
        TIME_OF_TRANSLATION            LITERALLY '8',
        XPL_VERSION_NAME               LITERALLY 'ADDR(CARD_IMAGE(11))',
        XPL_VERSION_ID                 LITERALLY 'CARD_IMAGE(16)',
        COMPILER_CREATION_TIME         LITERALLY '17',
        CARD_COUNT                     LITERALLY 'CARD_IMAGE(1)';


         /* FUNCTION TO FORMAT DATE AND TIME INTO THE TRANSLATION ID */

   FORMAT_DATE_AND_TIME: PROCEDURE(DATE_VALUE,TIME_VALUE, CARD_IMAGE_LOCATION);

   DECLARE
           DATE_VALUE                     FIXED,
           TIME_VALUE                     FIXED,
           CARD_IMAGE_LOCATION            BIT(16),
           DECODED_DATE                   FIXED;

      DECODED_DATE = DECODE_YEAR_DAY_AND_MONTH(DATE_VALUE);
      CARD_IMAGE(CARD_IMAGE_LOCATION) = (SHR(DECODED_DATE, 8) & "0000FF00") |
         (DECODED_DATE & FTWO);
      CARD_IMAGE(CARD_IMAGE_LOCATION + 1) = (DECODED_DATE & "0000FF00") |
         (TIME_VALUE / 360000);
      CARD_IMAGE(CARD_IMAGE_LOCATION + 2) =
         SHL((TIME_VALUE MOD 360000 / 6000), 8) |
         (TIME_VALUE MOD 6000 / 100);

   END FORMAT_DATE_AND_TIME;


            /* ROUTINE TO CONVERT FROM A CHARACTER STRING TO BIT(16) */

   CTOI: PROCEDURE(CHARS) BIT(16);

   DECLARE
           CHARS                          CHARACTER,
           I                              BIT(16),
           NUM_INDEX                      BIT(16),
           NUMBERS(9)                     BIT(16)
              INITIAL(0, 1, 2, 3, 4, 5, 6, 7, 8, 9),
           RESULT                         BIT(16);

      RESULT = 0;
   ACCUM_LOOP:
      DO FOR I = 0 TO LENGTH(CHARS) - 1;

         NUM_INDEX = CHAR_INDEX(NUMSEQ, SUBSTR(CHARS, I, 1));
         IF NUM_INDEX < 0 THEN DO;
            IF BYTE(CHARS, I) = BYTE('.') THEN REPEAT ACCUM_LOOP;
            ELSE NUM_INDEX = 0;
         END;
         RESULT = (RESULT * 10) + NUMBERS(NUM_INDEX);
      END;
      RETURN RESULT;
   END CTOI;


   RECORD_ID = END_CARD_ID;
   CARD_COUNT = CARD_COUNTER;
   COMPILER_ID = DESC(MONITOR(23));
   CALL MOVE_CHARS('HAL/S BFC-', HAL_VERSION_NAME, 10);
   HAL_VERSION_ID = CTOI(SUBSTR(COMPILER_ID, LENGTH(COMPILER_ID) - 5));
   CALL FORMAT_DATE_AND_TIME(DATE, TIME, TIME_OF_TRANSLATION);
   CALL MOVE_CHARS('TITAN--XPL', XPL_VERSION_NAME, 10); /*CR13554*/
   /* THE FOLLOWING LINE HAD TO BE SPLIT INTO TWO STATEMENTS BECAUSE */
   /*  IT WAS GENERATING AN XPL COMPILER MESSAGE - MULTIPLY FAILED - */
   /*  FOR BFS COMPILATION ON 12V0. THIS ANOMALY HAS BEEN DOCUMENTED */
   /*  PREVIOUSLY AND ATTRIBUTED TO A LACK OF AVAILABLE REGISTERS.   */
   XPL_VERSION_ID = (XPL_COMPILER_VERSION(0) * 100);
   XPL_VERSION_ID = XPL_VERSION_ID + (XPL_COMPILER_VERSION(1) * 10);
   CALL EMIT_CARD(1);

END EMIT_END_CARD;


      /* ROUTINE TO EMIT #Z MEMBER IF REQUIRED */

EMIT_ZCON_MEMBER:
   PROCEDURE;

      DECLARE (TEMP_SYT, X_CHAR, HAL_NAME_LENGTH) BIT(16);

      CARD_COUNTER = 0;
      CALL EMIT_START_CARD;
         /* EMIT EXR CARD */
      CALL MOVE_CHARS(OBJECT_MODULE_NAME, ADDR(CARD_IMAGE(1)), 8);
      TEMP_SYT = PROC_LEVEL(PROGPOINT);
      CARD_IMAGE(5) = SYT_LOCK#(TEMP_SYT);
      HAL_NAME_CHARS = SYT_NAME(TEMP_SYT);
      HAL_NAME_LENGTH = LENGTH(HAL_NAME_CHARS);
      IF (HAL_NAME_LENGTH & 1) ^= 0 THEN DO;
         HAL_NAME_CHARS = PAD(HAL_NAME_CHARS, HAL_NAME_LENGTH + 1);
         X_CHAR = 1;
      END;
      ELSE
         X_CHAR = 0;
      CARD_IMAGE(6) = "8000" | HAL_NAME_LENGTH;
      CALL MOVE_CHARS(HAL_NAME_CHARS, ADDR(CARD_IMAGE(7)), HAL_NAME_LENGTH +
         X_CHAR);
      RECORD_ID = "0400" | (SHR(HAL_NAME_LENGTH + X_CHAR, 1) + 7);
      CALL EMIT_CARD;
         /* EMIT CSD CARD */
      CALL MOVE_CHARS(POUND_Z || SUBSTR(OBJECT_MODULE_NAME, 2),
         ADDR(CARD_IMAGE(1)), 8);
      CARD_IMAGE(5) = 2;
      CARD_IMAGE(6) = 1;
      CARD_IMAGE(7) = "4000" | HAL_NAME_LENGTH;
      CALL MOVE_CHARS(HAL_NAME_CHARS, ADDR(CARD_IMAGE(8)), HAL_NAME_LENGTH +
         X_CHAR);
      RECORD_ID = "0200" | (SHR(HAL_NAME_LENGTH + X_CHAR, 1) + 8);
      CALL EMIT_CARD;
         /* EMIT PTX CARD */
      RECORD_ID = "0605";
      CARD_IMAGE(1) = 0;
      CARD_IMAGE(2) = 2;
      CARD_IMAGE(3) = 0;
      CARD_IMAGE(4) = "0E00";
      CALL EMIT_CARD;
         /* EMIT RLD CARD */
      RECORD_ID = "0805";
      CARD_IMAGE(1) = 1;
      CARD_IMAGE(2) = 2;
      CARD_IMAGE(3) = "002C";
      CARD_IMAGE(4) = 0;
      CALL EMIT_CARD;
      CALL EMIT_END_CARD;
/************************* DR101925 - P. ANSLEY, 5/12/92 ************/
      X_CHAR = MONITOR(1, 3, POUND_Z || SUBSTR(OBJECT_MODULE_NAME, 2));
/************************* END DR101925 *****************************/
      OBJECT_MODULE_STATUS = OBJECT_MODULE_STATUS | SHL(X_CHAR, 1);

END EMIT_ZCON_MEMBER;

 ?/
                                                                                07743000
INST_ADDRS:                                                                     07743500
      PROCEDURE;                                                                07744000
         IF FIRST_INST THEN DO;                                                 07744500
            ERRSEG(CURRENT_ESDID) = CURRENT_ADDRESS;                            07745000
            FIRST_INST = FALSE;                                                 07745500
         END;                                                                   07746000
         STACKSPACE(CURRENT_ESDID) = CURRENT_ADDRESS;                           07746500
      END INST_ADDRS;                                                           07747000
                                                                                07747500
SET_ADDR_RHS:                                                                   07748000
      PROCEDURE;                                                                07748500
         TEMP = TEMP + ADDRESS_MOD;                                             07749000
         IF TEMP < 0 THEN DO;                                                   07749500
            RHS = -TEMP;                                                        07750000
            ITEMP = GET_RLD(RLD#, 1);                                           07750500
            IF SHR(RLD_REF(ITEMP),31) THEN                                      07751000
               RLD_REF(ITEMP) = RLD_REF(ITEMP) & "7FFFFFFF";                    07751010
            ELSE RLD_REF(ITEMP) = RLD_REF(ITEMP) | "80000000";                  07751020
         END;                                                                   07751500
         ELSE RHS = TEMP;                                                       07752000
      END SET_ADDR_RHS;                                                         07752500
                                                                                07753000
                                                                                07753500
      IF (TOGGLE&"80")^=0 THEN RETURN;                                          07754000
      GENERATING, EMITTING = TRUE;                                              07754500
      CALL SET_MASKING_BIT(0);   /* TERMINATION CALL */                         07754510
      CALL EMIT_ADDRS(0);        /* INITIALIZATION CALL */                      07754520
 /?B  /* CR11114 -- BFS/PASS INTERFACE; CONSTANT PROTECTION */
      CURR_STORE_PROTECT = FALSE;
 ?/
      CODE_LINE = 0;                                                            07755000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT  */
      CALL EMIT_START_CARD;
 ?/
      CALL EMIT_ESD_CARDS;                                                      07756000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT  */
      RECORD_ID = 0;
 ?/
      /*ALLOCATE SOME SPACE FOR THE INIT_TAB RECORD*/
      ALLOCATE_SPACE(INIT_TAB,10);   /*CR13079*/
      NEXT_ELEMENT(INIT_TAB);        /*CR13079*/

      DO WHILE GENERATING;                                                      07756500
                                                                                07757000
         CALL NEXT_REC(0);                                                      07757500
         IF LHS >= 32 THEN DO;                                                  07758000
                                                                                07758500
CASE0004:                                                                       07759000
            DO CASE (LHS-32);                                                   07759500
                                                                                07760000
 /*RR*/                                                                         07760500
               IF EMITTING THEN                                                 07761000
 /* RR_TYPE: */                                                                 07761500
                  DO;                                                           07761500
                  CALL INST_ADDRS;                                              07762000
                  RHS = GET_INST_R_X;                                           07762500
                  OPCOUNT(INST) = OPCOUNT(INST) + 1; /*DR106757*/
                  IF INST < "04" THEN DO;                                       07763000
                     IX = SHL(IA,3) | IX;                                       07763500
                     IA = 0;                                                    07764000
                  END;                                                          07764500
                  RHS = RHS | SHL(R, 8) | IX;                                   07765000
                  CALL EMIT_TEXT_CARD(2);                                       07765500
               END;                                                             07766000
                                                                                07766500
 /*33=RX/RS/RI*/                                                                07767000
               IF EMITTING THEN                                                 07767500
RX_RS:                                                                          07768000
               DO;                                                              07768500
                  CALL INST_ADDRS;                                              07769000
                  RHS = GET_INST_R_X;                                           07769500
                  OPCOUNT(INST) = OPCOUNT(INST) + 1; /*DR106757*/
                  CALL NEXT_REC(1);                                             07770000
                  CALL FORM_BD(1);                                              07770500
                  IF (RHS & "F0") = "E0" THEN RHS = RHS | R;                    07771000
              ELSE RHS = RHS | SHL(R,8) | B | SHL(IA | AM | F | IX^=0,2) | "F0";07771500
                  RHS(1) = SHL(IX,13) | SHL(IA,12) | SHL(F,11) | D;             07772000
                  CALL EMIT_TEXT_CARD(4);                                       07772500
               END RX_RS;                                                       07783000
               ELSE CALL SKIP_ADDR;                                             07783500
                                                                                07784000
 /*34=SS*/                                                                      07784500
               IF EMITTING THEN                                                 07785000
SS_TYPE:                                                                        07785500
               DO;                                                              07786000
                  CALL INST_ADDRS;                                              07786500
                  RHS = GET_INST_R_X;                                           07787000
                  OPCOUNT(INST) = OPCOUNT(INST) + 1; /*DR106757*/
                  CALL NEXT_REC(1);                                             07787500
                  CALL FORM_BD(1);                                              07788000
                  IF B >= 0 THEN RHS = RHS | B;                                 07788500
                  RHS = RHS | SHL(D, 2);                                        07789000
                  CALL NEXT_REC(1);                                             07789500
                  CALL EMIT_TEXT_CARD(4);                                       07790000
               END SS_TYPE;                                                     07793000
               ELSE DO;                                                         07793500
                  CALL SKIP_ADDR;                                               07794000
                  CALL SKIP(1);                                                 07794500
               END;                                                             07795000
                                                                                07795500
 /*35=DELTA*/                                                                   07796000
               ADDRESS_MOD=RHS + ADDRESS_MOD;                                   07796500
                                                                                07797000
 /*36=ULBL*/                                                                    07797500
               DO;                                                              07798000
                  TAG_NAME=SYT_NAME(RHS);                                       07798500
                  CALL PRINT_LINE;                                              07799000
               END;                                                             07799500
                                                                                07800000
 /*37=ILBL*/                                                                    07800500
               DO;                                                              07801000
                  TAG_NAME='LBL#' || LABEL_ARRAY(RHS);                          07801500
                  CALL PRINT_LINE;                                              07802000
               END;                                                             07802500
                                                                                07803000
 /*38=CSECT*/                                                                   07803500
               DO;                                                              07804000
 /?P     /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
                  CALL EMIT_CARD;                                               07804500
 ?/
 /?B     /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
                  CALL FLUSH_TEXT_CARD;
 ?/
                  IF RHS = FSIMBASE THEN                                        07804510
                     RHS = DATABASE;                                            07804520
                  ITEMP = CURRENT_ESDID^=RHS;                                   07805000
                  CURRENT_ESDID=RHS;                                            07805500
                  L = CURRENT_ADDRESS;                                          07806000
                  IF ITEMP THEN DO;                                             07808500
                     TAG_NAME = ESD_TABLE(CURRENT_ESDID);                       07809000
                     CALL PRINT_LINE;                                           07809500
                  END;                                                          07810000
                  CALL NEXT_REC;                                                07810500
                  IF SHR(LHS, 15) THEN DO;                                      07811000
                     CURRENT_ADDRESS = (SHL(LHS & FTWO, 16) |                   07811500
                        (RHS & FFOUR)) + ORIGIN(CURRENT_ESDID);                 07812000
             IF TEMP=NEGMAX & CURRENT_ESDID <= PROCLIMIT THEN FIRST_INST = TRUE;07812500
                     LHS = 43;                                                  07813000
                     IF L ^= CURRENT_ADDRESS THEN CALL PRINT_LINE;              07813500
                  END;                                                          07814000
               END;                                                             07814500
                                                                                07815000
 /*39=BLOCK DATA*/                                                              07815500
               DO;     DO ITEMP=1 TO RHS;                                       07816000
                     CALL NEXT_REC(1);                                          07816500
                  RHS=LHS(1);                                                   07817000
                  /*IF PROCESSING A #D/#P VALUE, STORE THE FULLWORD */
                  /*DATA AT THE CURRENT ADDRESS IN INIT_VAL.        */
                  IF (CURRENT_ESDID=DATABASE) &                 /*CR13079*/
                     (CURRENT_ADDRESS < PROGDATA) THEN DO;      /*CR13079*/
                     CALL ZERO_INIT_VAL                         /*CR13079*/
                     (RECORD_TOP(INIT_TAB)+1,CURRENT_ADDRESS+1);/*CR13079*/
                     INIT_VAL(CURRENT_ADDRESS) = RHS;           /*CR13079*/
                     INIT_VAL(CURRENT_ADDRESS + 1) = RHS(1);    /*CR13079*/
                  END;                                          /*CR13079*/
                  CALL EMIT_TEXT_CARD(4);                                       07817500
               END;                                                             07818000
            END;                                                                07818500
                                                                                07819000
            DO;            /*40=RELOCATABLE ADCON*/                             07819500
               CALL NEXT_REC(1);                                                07820000
               TEMP = LHS(1);                                                   07820500
               IF ESD_TYPE(RHS) ^= 2 THEN                                       07821000
                  TEMP = TEMP + ORIGIN(RHS);                                    07821500
DO_ADCONS:                                                                      07822000
               CALL SET_ADDR_RHS;                                               07822500
              /*IF PROCESSING A #D/#P VALUE, STORE THE FULLWORD */
               /*DATA AT THE CURRENT ADDRESS IN INIT_VAL.        */
               IF (CURRENT_ESDID=DATABASE) &                 /*CR13079*/
                  (CURRENT_ADDRESS < PROGDATA) THEN DO;      /*CR13079*/
                  CALL ZERO_INIT_VAL                         /*CR13079*/
                  (RECORD_TOP(INIT_TAB)+1,CURRENT_ADDRESS+1);/*CR13079*/
                  INIT_VAL(CURRENT_ADDRESS) = RHS;           /*CR13079*/
                  INIT_VAL(CURRENT_ADDRESS + 1) = RHS(1);    /*CR13079*/
               END;                                          /*CR13079*/
               LHS = 40;                                                        07823500
               CALL EMIT_TEXT_CARD(4);                                          07824000
               ADDRESS_MOD = 0;                                                 07824500
            END;                                                                07825000
                                                                                07825500
            DO;             /*41=PROGRAM ADCON*/                                07826000
               CALL NEXT_REC(1);                                                07826500
               TEMP = LOCATION(RHS(1)) + ORIGIN(RHS);                           07827000
               GO TO DO_HADCONS;                                                07827500
            END;                                                                07828000
                                                                                07828500
 /* 42 = LITERAL ADCON  */                                                      07829000
            DO;                                                                 07829500
               CALL NEXT_REC(1);                                                07830000
               TEMP = (CONSTANT_PTR(RHS(1)) & FFOUR) + ORIGIN(RHS);             07830500
               GO TO DO_HADCONS;                                                07831000
            END;                                                                07831500
                                                                                07832000
 /* 43 = RLD*/                                                                  07832500
            DO;                                                                 07833000
               TEMP = CURRENT_ADDRESS;                                          07833500
 /* DO_RLDS: */                                                                 07834000
               RHS = EMIT_RLD(RHS, TEMP);                                       07834500
               IF RHS <= PROCLIMIT THEN TAG_NAME = SYT_NAME(PROC_LEVEL(RHS));   07839000
               ELSE TAG_NAME = ESD_TABLE(RHS);                                  07839500
            END;                                                                07840000
                                                                                07840500
 /* 44 = STMT NUMBER  */                                                        07841000
            DO;                                                                 07841500
               DO TEMP = 0 TO 8;                    /*CR12940*/
                  MVH_COUNT(TEMP)=0;                /*CR12940*/
                  MVH_CNT_KNOWN(TEMP)=FALSE;        /*CR12940*/
               END;                                 /*CR12940*/
               TAG_NAME = 'ST#'||RHS;                                           07842000
               CALL PRINT_LINE;                                                 07842500
            END;                                                                07843000
                                                                                07843500
 /* 45 = TEMP DELTA  */                                                         07844000
            ADDRESS_MOD = MAXTEMP(RHS);                                         07844500
                                                                                07845000
 /* 46 = CHAR STRING  */                                                        07845500
            DO;                                                                 07846000
               ITEMP = RHS;                                                     07846500
               DO WHILE ITEMP > 0;                                              07847000
                  CALL NEXT_REC(1);                                             07847500
                  RHS = LHS(1);                                                 07848000
                 /*IF PROCESSING A #D/#P VALUE, STORE THE CHARACTER */
                  /*STRING AT THE CURRENT ADDRESS IN INIT_VAL.       */
                  IF (CURRENT_ESDID=DATABASE) &                   /*CR13079*/
                     (CURRENT_ADDRESS < PROGDATA) THEN DO;        /*CR13079*/
                     IF ITEMP>2 THEN                              /*CR13079*/
                       CALL ZERO_INIT_VAL                         /*CR13079*/
                       (RECORD_TOP(INIT_TAB)+1,CURRENT_ADDRESS+1);/*CR13079*/
                     ELSE                                         /*CR13079*/
                       CALL ZERO_INIT_VAL                         /*CR13079*/
                       (RECORD_TOP(INIT_TAB)+1,CURRENT_ADDRESS);  /*CR13079*/
                     INIT_VAL(CURRENT_ADDRESS) = RHS;             /*CR13079*/
                     IF ITEMP>2 THEN                              /*CR13079*/
                        INIT_VAL(CURRENT_ADDRESS + 1) = RHS(1);   /*CR13079*/
                  END;                                            /*CR13079*/
                  CALL EMIT_TEXT_CARD(MIN(4, ITEMP));                           07848500
                  ITEMP = ITEMP - 4;                                            07849000
               END;                                                             07849500
            END;                                                                07850000
                                                                                07850500
 /* 47 = CODE END  */                                                           07851000
            GENERATING = FALSE;                                                 07851500
                                                                                07852000
 /* 48 = PROGRAM POINT LABEL  */                                                07852500
            DO;                                                                 07853000
               TAG_NAME = 'LBL#' || RHS;                                        07853500
               CALL PRINT_LINE;                                                 07854000
            END;                                                                07854500
                                                                                07855000
 /* 49 = LOCAL CODE LIST CONTROL  */                                            07855500
            DATA_LIST_OFF = RHS;                                                07856000
                                                                                07856500
 /* 50 = SRS INSTRUCTIONS  */                                                   07857000
            IF EMITTING THEN                                                    07857500
               DO;                                                              07858000
               CALL INST_ADDRS;                                                 07858500
               RHS = GET_INST_R_X;                                              07859000
               OPCOUNT(INST) = OPCOUNT(INST) + 1; /*DR106757*/
               CALL NEXT_REC(1);                                                07859500
               CALL FORM_BD(1);                                                 07860000
               IF B >= 0 THEN RHS = RHS | B;                                    07860500
               ELSE IF LHS(1) = SHCOUNT THEN RHS = RHS | SHL(56-B, 2);          07861000
               IF INST >= "50" & INST < "80" THEN ITEMP = 1; ELSE ITEMP = 2;    07861500
                  RHS = RHS | SHL(R, 8) | SHL(D, ITEMP);                        07862000
               CALL EMIT_TEXT_CARD(2);                                          07862500
            END;                                                                07863000
            ELSE CALL SKIP_ADDR;                                                07863500
                                                                                07864000
 /* 51 = CNOP  */                                                               07865500
            DO;                                                                 07866000
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
               CALL EMIT_CARD;                                                  07866500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT (OBJECT MODULE */
      /*            ALIGNMENT PROBLEM)                               */
               CALL FLUSH_TEXT_CARD;
 ?/
               CURRENT_ADDRESS = CURRENT_ADDRESS + RHS & (^RHS);                07867000
            END;                                                                07867500
                                                                                07868000
 /* 52 = NOP  */                                                                07868500
            CALL SKIP_ADDR;                                                     07869000
                                                                                07869500
 /* 53 = HALFWORD ADCON  */                                                     07870000
            DO;                                                                 07870500
               CALL NEXT_REC(1);                                                07871000
               IF ESD_TYPE(RHS) ^= 2 THEN                                       07871500
                  TEMP = TEMP + ORIGIN(RHS);                                    07872000
DO_HADCONS:                                                                     07872500
               CALL SET_ADDR_RHS;                                               07873000
               /*IF PROCESSING A #D/#P VALUE, STORE THE HALFWORD */
               /*AT THE CURRENT ADDRESS IN INIT_VAL.       */
               IF (CURRENT_ESDID=DATABASE) &                      /*CR13079*/
                  (CURRENT_ADDRESS < PROGDATA) THEN DO;           /*CR13079*/
                     CALL ZERO_INIT_VAL                           /*CR13079*/
                     (RECORD_TOP(INIT_TAB)+1,CURRENT_ADDRESS);    /*CR13079*/
                   INIT_VAL(CURRENT_ADDRESS) = RHS;               /*CR13079*/
               END;                                               /*CR13079*/
               LHS = 0;                                                         07873500
               CALL EMIT_TEXT_CARD(2);                                          07874000
               ADDRESS_MOD = 0;                                                 07874500
            END;                                                                07875000
                                                                                07875500
 /* 54 = PROC/FUNC PROLOG */                                                    07876000
            DO;                                                                 07876500
            END;                                                                07878000
                                                                                07878500
 /* 55 = Z-TYPE ADCON */                                                        07879000
            DO;                                                                 07879500
               CALL NEXT_REC(1);                                                07880000
               TEMP = LHS(1);                                                   07880500
               IF ESD_TYPE(RHS) ^= 2 THEN                                       07881000
                  TEMP = TEMP + ORIGIN(RHS);                                    07881500
               GO TO DO_ADCONS;                                                 07882000
            END;                                                                07882500
                                                                                07883000
 /* 56 = ADDRESS CHECK */                                                       07883500
            DO;                                                                 07884000
         CALL EMIT_ADDRS(RHS, ERRSEG(CURRENT_ESDID), STACKSPACE(CURRENT_ESDID));07884500
NEW_FIRST_INST:                                                                  7884550
               ERRSEG(CURRENT_ESDID) = CURRENT_ADDRESS;                          7884600
               STACKSPACE(CURRENT_ESDID) = 0;                                    7884700
               FIRST_INST = TRUE;                                               07885000
            END;                                                                07885500
                                                                                 7885510
 /* 57 = ADDRESS START  */                                                       7885520
            GO TO NEW_FIRST_INST;                                                7885530
                                                                                07885540
 /* 58 = BRANCH AROUND */                                                       07885550
            DO;                                                                 07885560
               CALL NEXT_REC;                                                   07885570
               CODE_LINE = TEMP;                                                07885580
            END;                                                                07885590
 /* 59 REDIRECT TO AUXILLIARY INSTRUCTION STREAM */                             07885600
            DO;                                                                 07885610
               TEMP1=CODE_LINE;                                                 07885620
               CODE_LINE=MAX_CODE_LINE;                                         07885630
            END;                                                                07885640
 /* 60 REDIRECT TO MAIN INSTRUCTION STREAM */                                   07885650
            DO;                                                                 07885660
               MAX_CODE_LINE=CODE_LINE;                                         07885670
               CODE_LINE=TEMP1+RHS-1;                                           07885680
            END;                                                                07885690
 /* 61 INTEGRAL INSTRUCTION SEQUENCE */                                         07885700
            ;                                                                   07885710
                                                                                07886000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ALTERNATE ENTRY */
   /*--- 62 = CSECT HEADER FOR INIT. DATA AREAS ---*/
            ;

   /*--- 63 = SET STORE PROTECT (SPSET) ---*/
            DO;
               CALL FLUSH_TEXT_CARD;
               CURR_STORE_PROTECT = RHS;
            END;

   /*--- 64 = PUSH LOCATION COUNTER (LPUSH) ---*/
            DO;
               CALL FLUSH_TEXT_CARD;
               PUSHED_LOCCTR(CURRENT_ESDID) = CURRENT_ADDRESS;
               L = CURRENT_ADDRESS;
               CALL NEXT_REC;
               CURRENT_ADDRESS =(TEMP & "FFFFFF") + ORIGIN(CURRENT_ESDID);
               LHS = 43;
               CALL PRINT_LINE;
            END;

   /*--- 65 = POP LOCATION COUNTER (LPOP) ---*/
            DO;
               CALL FLUSH_TEXT_CARD;
               L = CURRENT_ADDRESS;
               CURRENT_ADDRESS = PUSHED_LOCCTR(CURRENT_ESDID);
               LHS = 43;
               CALL PRINT_LINE;
            END;
 ?/
         END CASE0004;                                                          07886500
      END; /* OF IF LHS >= 32 THEN DO;*/                                        07887000
      ELSE IF LHS=0 THEN DO;                                                    07887500
         RHS = RHS + ADDRESS_MOD;                                               07888000
         /*IF PROCESSING A #D/#P VALUE, STORE THE HALFWORD */
         /*AT THE CURRENT ADDRESS IN INIT_VAL.       */
         IF (CURRENT_ESDID=DATABASE) &                           /*CR13079*/
            (CURRENT_ADDRESS < PROGDATA) THEN DO;                /*CR13079*/
               CALL ZERO_INIT_VAL                                /*CR13079*/
               (RECORD_TOP(INIT_TAB)+1,CURRENT_ADDRESS);         /*CR13079*/
             INIT_VAL(CURRENT_ADDRESS) = RHS;                    /*CR13079*/
         END;                                                    /*CR13079*/
         ADDRESS_MOD = 0;                                                       07888500
         CALL EMIT_TEXT_CARD(2);                                                07889000
      END;                                                                      07889500
   END;  /* OF DO WHILE  */                                                     07890000
   IF CODE_LISTING_REQUESTED THEN                                               07890500
      CALL APRINT(SUBSTR(X72, 26) || 'END');                                    07891000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMATE */
   CALL FLUSH_TEXT_CARD;
 ?/
   CALL EMIT_RLD_CARDS;                                                         07891500
 /?P  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMATE */
   CALL EMIT_CARD;  /* TO PURGE OUT LAST CARD  */                               07892000
   CARDIMAGE, CARDIMAGE(1) = END_CARD;                                          07892500
   DUMMY = DESC(MONITOR(23));                                                   07893000
   DUMMY = SUBSTR(DUMMY, LENGTH(DUMMY)-10, 10);                                  7893100
   DUMMY = SUBSTR(DUMMY,0,4)||BLANK||SUBSTR(DUMMY,5,2)||SUBSTR(DUMMY,8,2);      07893500
   /* MODIFY DATE FIELD SO THAT ONLY THE LAST 2 DIGITS OF            CR12891*/
   /*  THE YEAR FIELD ARE PRINTED.  ADD 100000 BEFORE USING          CR12891*/
   /*  THE SUBSTR FUNCTION SO THAT 2 DIGIT YEAR FIELDS WILL          CR12891*/
   /*  NOT LOSE THE FIRST DIGIT                                      CR12891*/
   DUMMY = '2HAL/S'||DUMMY||SUBSTR(100000+DATE,1)||'TITAN--XPL'/*12891,13554*/
           ||XVERSION||SUBSTR(100000 + DATE_OF_GENERATION, 1);     /*CR12891*/
   CALL INLINE ("58",2,0,DUMMY);                                                07894500
   CALL INLINE ("41",1,0,COLUMN);                                               07895000
   CALL INLINE("D2",2,6,1,32,2,0);                                              07895500
   BYTES_REMAINING = 0;                                                         07896000
   CALL EMIT_CARD;                                                              07896500
   CALL MONITOR(17, PAD(THISPROGRAM, 8));                                       07897000
   IF ^SDL THEN                                                                 07897500
      IF CALL#(PROGPOINT) THEN DO;                                              07898000
      TMP = SELFNAMELOC;                                                        07898500
      DO WHILE TMP > 0;                                                         07899000
         S1 = ' STACK ' || ESD_TABLE(SYT_SCOPE(TMP));                           07899500
         /* CR12416: INHIBIT OBJECT GENERATION IF ERRORS OCCURRED */            07337500
         IF MAX_SEVERITY = 0 THEN DO;              /* CR12416 */                07337500
            OUTPUT(3) = S1;                                                     07900000
            IF DECK_REQUESTED THEN                                              07900500
               OUTPUT(4) = S1;                                                  07901000
         END;                                      /* CR12416 */                07337500
         TMP = SYT_LINK1(TMP);                                                  07901500
      END;                                                                      07902000
      ITEMP = CODE_LISTING_REQUESTED;                                           07902500
      TMP = DATABASE;                                                           07903000
      OP2 = PROGPOINT;                                                          07903500
      CODE_LISTING_REQUESTED = FALSE;                                           07904000
      CALL ENTER_ESD(THISPROGRAM, 2, 2);                                        07904500
      CALL ENTER_ESD('START', 1, 0);                                            07905000
      LOCCTR(1) = 2;                                                            07906000
      ESD_MAX = 2;                                                              07906500
      DATABASE = 3;                                                             07907000
      CALL EMIT_ESD_CARDS;                                                      07908000
      LHS = 39;                                                                 07908500
      CURRENT_ESDID = 1;                                                        07909000
      RHS(1), CURRENT_ADDRESS = 0;                                              07909500
      RHS = "E4F3";  /* BAL$  4,...   SKELETON  */                              07910000
      CALL EMIT_TEXT_CARD(4);                                                   07910500
      RLD#, RLD_POS_HEAD(1) = 1;                                                07911000
      TEMP = GET_RLD(1);                                                         7911500
      RLD_ADDR(TEMP) = 1;                                                        7912000
      RLD_LINK(TEMP) = 0;                                                        7912500
      RLD_REF(TEMP) = 2;                                                         7913000
      PROGPOINT, DATABASE = 1;                                                  07913500
      CALL EMIT_RLD_CARDS;                                                      07914000
      CALL EMIT_CARD;                                                           07914500
      CARDIMAGE, CARDIMAGE(1) = END_CARD;                                       07915000
      CARDIMAGE(2) = "40000000";                                                07915500
      CARDIMAGE(4) = "40400001";                                                07916000
      CALL INLINE("58",2,0,DUMMY);                                              07916500
      CALL INLINE("41",1,0,COLUMN);                                             07917000
      CALL INLINE("D2",2,6,1,32,2,0);                                           07917500
      BYTES_REMAINING = 0;                                                      07918000
      CALL EMIT_CARD;                                                           07918500
      CODE_LISTING_REQUESTED = ITEMP;                                           07919000
      DATABASE = TMP;                                                           07919500
      PROGPOINT = OP2;                                                          07920000
   END;                                                                         07920500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
   CALL EMIT_END_CARD;

   OBJECT_MODULE_NAME = PAD(THISPROGRAM, 8);
   CALL MONITOR(17, OBJECT_MODULE_NAME);

 ?/
   IF CODE_LISTING_REQUESTED THEN DO;                                           07921000
      CALL AHEADSET(3);                                                         07921500
      CALL APRINT(BLANK);                                                       07922000
      CALL MONITOR(0, 7);                                                       07922500
   END;                                                                         07923000
   /*IF ANY REMAINING SPACE IS LEFT IN THE #D/#P, PUT ZEROS THERE.*/
   CALL ZERO_INIT_VAL(RECORD_TOP(INIT_TAB)+1,PROGDATA-1); /*CR13079*/
   RECORD_SEAL(INIT_TAB);                                 /*CR13079*/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT FORMAT */
   IF MAX_SEVERITY = 0 THEN DO;     /* CLOSE OBJECT OUTPUT IF OK */
 /************************ DR101925 - P. ANSLEY, 5/12/92 *********/
      OBJECT_MODULE_STATUS = MONITOR(1, 3, OBJECT_MODULE_NAME);
 /************************ END DR101925 **************************/
      IF PCEBASE THEN
         CALL EMIT_ZCON_MEMBER;
   END;
 ?/
END OBJECT_GENERATOR /* $S */ ; /* $S */                                        07924000
