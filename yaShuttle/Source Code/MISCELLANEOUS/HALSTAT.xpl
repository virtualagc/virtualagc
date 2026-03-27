   /* EDIT 193     1 DECEMBER 1978     VERSION 8.1   */                         00100000
                                                                                00100100
   /*  $Z MAKES THE CODE GO ON ERRORS  */                                       00100200
   /* $HH A L / S   S Y S T E M   --   H A L S T A T   --   I N T E R M E T R I 00100300
C S ,   I N C .   */                                                            00100400
                                                                                00100500
   /* AREA FOR ZAPS */                                                          00100600
                                                                                00100700
ARRAY ZAP_AREA(25) FIXED;                                                       00100800
                                                                                00100900
DECLARE STAT_TITLE CHARACTER INITIAL('HALSTAT V8.1');                           00101000
                                                                                00101100
                                                                                00101200
                                                                                00101300
                                                                                00101400
DECLARE RESERVED_LIMIT LITERALLY '14';                                          00101500
                                                                                00101600
         /*   THE FOLLOWING IS THE INPUT GRAMMAR   */                           00101700
                                                                                00101800
                                                                                00101900
                                                                                00102000
                                                                                00102100
         /*      1   <COMPILATION> ::= <COMMAND LIST> _|_                     */00102200
                                                                                00102300
         /*      2   <COMMAND LIST> ::=                                       */00102400
         /*      3                    | <COMMAND LIST> <COMMAND>              */00102500
                                                                                00102600
         /*      4   <COMMAND> ::= <DEFINE CLAUSE> ;                          */00102700
         /*      5               | <COMMAND CLAUSE> ;                         */00102800
                                                                                00102900
         /*      6   <DEFINE CLAUSE> ::= DEFINE FUNCTION <LABEL> AS           */00103000
         /*      6                       <UNIT SPEC>                          */00103100
         /*      7                     | DEFINE CONFIGURATION <LABEL> AS      */00103200
         /*      7                       <PHASE SPEC>                         */00103300
         /*      8                     | DEFINE <CSECT SPEC> AS <TYPE SPEC>   */00103400
         /*      8                       <STATUS SPEC>                        */00103500
                                                                                00103600
         /*      9   <UNIT SPEC> ::= UNIT <UNIT LIST>                         */00103700
         /*     10                 | UNITS <UNIT LIST>                        */00103800
                                                                                00103900
         /*     11   <UNIT LIST> ::= <LABEL>                                  */00104000
         /*     12                 | <UNIT LIST> , <LABEL>                    */00104100
                                                                                00104200
         /*     13   <PHASE SPEC> ::= PHASE <PHASE LIST>                      */00104300
         /*     14                  | PHASES <PHASE LIST>                     */00104400
                                                                                00104500
         /*     15   <PHASE LIST> ::= <NUMBER>                                */00104600
         /*     16                  | <PHASE LIST> , <NUMBER>                 */00104700
                                                                                00104800
         /*     17   <COMMAND CLAUSE> ::= <MAP CLAUSE>                        */00104900
         /*     18                      | <ANALYZE CLAUSE>                    */00105000
         /*     19                      | <PROCESS CLAUSE>                    */00105100
         /*     20                      | <SUPPRESS CLAUSE>                   */00105200
                                                                                00105300
         /*     21   <MAP CLAUSE> ::= MAP <MAP SPEC> <RANGE SPEC>             */00105400
         /*     21                    <LEVEL SPEC>                            */00105500
                                                                                00105600
         /*     22   <MAP SPEC> ::= ALL CONFIGURATIONS                        */00105700
         /*     23                | ALL PHASES                                */00105800
         /*     24                | CONFIGURATION <CONFIG NAME LIST>          */00105900
         /*     25                | CONFIGURATIONS <CONFIG NAME LIST>         */00106000
         /*     26                | <PHASE SPEC>                              */00106100
                                                                                00106200
         /*     27   <RANGE SPEC> ::=                                         */00106300
         /*     28                  | <FROM SPEC>                             */00106400
         /*     29                  | <TO SPEC>                               */00106500
         /*     30                  | <FROM SPEC> <TO SPEC>                   */00106600
         /*     31                  | <SECTOR SPEC>                           */00106700
                                                                                00106800
         /*     32   <FROM SPEC> ::= FROM <HEX>                               */00106900
                                                                                00107000
         /*     33   <TO SPEC> ::= TO <HEX>                                   */00107100
                                                                                00107200
         /*     34   <SECTOR SPEC> ::= SECTOR <NUMBER>                        */00107300
                                                                                00107400
         /*     35   <LEVEL SPEC> ::=                                         */00107500
         /*     36                  | AT LEVEL <NUMBER> <SUBLEVEL SPEC>       */00107600
                                                                                00107700
         /*     37   <SUBLEVEL SPEC> ::=                                      */00107800
         /*     38                     | FORMAT <NUMBER>                      */00107900
                                                                                00108000
         /*     39   <CONFIG NAME LIST> ::= <LABEL>                           */00108100
         /*     40                        | <CONFIG NAME LIST> , <LABEL>      */00108200
                                                                                00108300
         /*     41   <ANALYZE CLAUSE> ::= ANALYZE <ANALYZE SPEC>              */00108400
                                                                                00108500
         /*     42   <ANALYZE SPEC> ::= CONFIGURATION <CONFIG NAME LIST>      */00108600
         /*     43                    | CONFIGURATIONS <CONFIG NAME LIST>     */00108700
                                                                                00108800
         /*     44   <TYPE SPEC> ::=                                          */00108900
         /*     45                 | TYPE <LABEL>                             */00109000
                                                                                00109100
         /*     46   <STATUS SPEC> ::=                                        */00109200
         /*     47                   | STATUS <LABEL>                         */00109300
                                                                                00109400
         /*     48   <PROCESS CLAUSE> ::= PROCESS <UNIT SPEC>                 */00109500
         /*     49                      | PROCESS <FUNC SPEC>                 */00109600
                                                                                00109700
         /*     50   <FUNC SPEC> ::= FUNCTION <FUNC NAME LIST>                */00109800
         /*     51                 | FUNCTIONS <FUNC NAME LIST>               */00109900
                                                                                00110000
         /*     52   <FUNC NAME LIST> ::= <LABEL>                             */00110100
         /*     53                      | <FUNC NAME LIST> , <LABEL>          */00110200
                                                                                00110300
         /*     54   <SUPPRESS CLAUSE> ::= SUPPRESS PRINT FOR <UNIT SPEC>     */00110400
         /*     55                       | SUPPRESS PRINT FOR <FUNC SPEC>     */00110500
         /*     56                       | SUPPRESS ERRORS IN <UNIT SPEC>     */00110600
         /*     57                       | SUPPRESS PRINT FOR <CSECT SPEC>    */00110700
                                                                                00110800
         /*     58   <CSECT SPEC> ::= CSECT <CSECT LIST>                      */00110900
         /*     59                  | CSECTS <CSECT LIST>                     */00111000
                                                                                00111100
         /*     60   <CSECT LIST> ::= <LABEL>                                 */00111200
         /*     61                  | <CSECT LIST> , <LABEL>                  */00111300
                                                                                00111400
                                                                                00111500
                                                                                00111600
                                                                                00111700
         /*   THESE ARE LALR PARSING TABLES   */                                00111800
                                                                                00111900
         DECLARE MAXR# LITERALLY '64'; /* MAX READ # */                         00112000
                                                                                00112100
         DECLARE MAXL# LITERALLY '83'; /* MAX LOOK # */                         00112200
                                                                                00112300
         DECLARE MAXP# LITERALLY '89'; /* MAX PUSH # */                         00112400
                                                                                00112500
         DECLARE MAXS# LITERALLY '150'; /* MAX STATE # */                       00112600
                                                                                00112700
         DECLARE START_STATE LITERALLY '65';                                    00112800
                                                                                00112900
         DECLARE TERMINAL# LITERALLY '36'; /* # OF TERMINALS */                 00113000
                                                                                00113100
         DECLARE VOCAB# LITERALLY '64';                                         00113200
                                                                                00113300
         DECLARE VOCAB(VOCAB#) CHARACTER INITIAL ('',';',',','AS','AT','IN','TO'00113400
         ,'_|_','ALL','FOR','MAP','FROM','TYPE','UNIT','<HEX>','CSECT','LEVEL'  00113500
         ,'PHASE','PRINT','UNITS','CSECTS','DEFINE','ERRORS','FORMAT','PHASES'  00113600
         ,'SECTOR','STATUS','<EMPTY>','<LABEL>','ANALYZE','PROCESS','<NUMBER>'  00113700
         ,'FUNCTION','SUPPRESS','FUNCTIONS','CONFIGURATION','CONFIGURATIONS'    00113800
         ,'<COMMAND>','<TO SPEC>','<MAP SPEC>','<FROM SPEC>','<FUNC SPEC>'      00113900
         ,'<TYPE SPEC>','<UNIT LIST>','<UNIT SPEC>','<CSECT LIST>'              00114000
         ,'<CSECT SPEC>','<LEVEL SPEC>','<MAP CLAUSE>','<PHASE LIST>'           00114100
         ,'<PHASE SPEC>','<RANGE SPEC>','<COMPILATION>','<SECTOR SPEC>'         00114200
         ,'<STATUS SPEC>','<ANALYZE SPEC>','<COMMAND LIST>','<DEFINE CLAUSE>'   00114300
         ,'<SUBLEVEL SPEC>','<ANALYZE CLAUSE>','<COMMAND CLAUSE>'               00114400
         ,'<FUNC NAME LIST>','<PROCESS CLAUSE>','<SUPPRESS CLAUSE>'             00114500
         ,'<CONFIG NAME LIST>');                                                00114600
                                                                                00114700
         DECLARE P# LITERALLY '61'; /* # OF PRODUCTIONS */                      00114800
                                                                                00114900
         DECLARE STATE_NAME(MAXR#) BIT(8) INITIAL (0,0,2,2,2,2,2,3,3,3,4,5,6,8,900115000
         ,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,28,28,29,30,31,32,32  00115100
         ,33,34,35,35,35,36,36,39,40,42,43,43,45,45,46,49,49,51,56,57,60,61,61  00115200
         ,64,64,64,64);                                                         00115300
                                                                                00115400
         DECLARE #STATE_NAME(P#) BIT(8) INITIAL (0,7,27,37,1,1,44,50,54,43,43,2800115500
         ,28,49,49,31,31,48,59,62,63,47,36,24,64,64,50,27,40,38,38,53,14,14,31  00115600
         ,27,58,27,31,28,28,55,64,64,27,28,27,28,44,41,61,61,28,28,44,41,44,46  00115700
         ,45,45,28,28);                                                         00115800
                                                                                00115900
         DECLARE #PRODUCE_NAME(P#) BIT(8) INITIAL (0,52,56,56,37,37,57,57,57,44 00116000
         ,44,43,43,50,50,49,49,60,60,60,60,48,39,39,39,39,39,51,51,51,51,51,40  00116100
         ,38,53,47,47,58,58,64,64,59,55,55,42,42,54,54,62,62,41,41,61,61,63,63  00116200
         ,63,63,46,46,45,45);                                                   00116300
                                                                                00116400
         DECLARE RSIZE LITERALLY '73'; /*  READ STATES INFO  */                 00116500
                                                                                00116600
         DECLARE LSIZE LITERALLY '38'; /* LOOK AHEAD STATES INFO */             00116700
                                                                                00116800
         DECLARE ASIZE LITERALLY '42'; /* APPLY PRODUCTION STATES INFO */       00116900
                                                                                00117000
         DECLARE READ1(RSIZE) BIT(8) INITIAL (0,0,31,28,28,28,28,12,17,24,16,14 00117100
         ,24,36,13,15,19,20,32,34,8,17,24,35,36,14,28,28,28,31,31,9,15,20,32,35 00117200
         ,5,31,31,28,3,3,35,36,13,19,32,34,23,28,28,18,22,28,28,6,11,25,26,2,2,300117300
         ,2,4,7,10,21,29,30,33,1,1,2,2);                                        00117400
                                                                                00117500
         DECLARE LOOK1(LSIZE) BIT(8) INITIAL (0,0,12,0,23,0,1,4,0,6,0,26,0,2,0,200117600
         ,0,2,0,2,0,2,0,2,0,4,0,2,0,2,0,2,0,2,0,2,0,2,0);                       00117700
                                                                                00117800
         /*  PUSH STATES ARE BUILT-IN TO THE INDEX TABLES  */                   00117900
                                                                                00118000
         DECLARE APPLY1(ASIZE) BIT(8) INITIAL (0,0,0,0,0,8,11,14,0,23,0,9,0,28,000118100
         ,0,0,0,0,0,46,0,0,0,0,42,43,44,0,0,0,0,0,0,14,0,39,0,0,14,0,24,0);     00118200
                                                                                00118300
         DECLARE READ2(RSIZE) BIT(8) INITIAL (0,0,105,129,150,101,142,17,21,28  00118400
         ,20,122,112,111,18,19,23,24,37,39,13,21,28,40,43,121,134,100,149,67,10400118500
         ,14,19,24,36,41,11,127,123,136,8,9,42,44,18,23,37,39,27,31,141,22,26   00118600
         ,128,32,12,16,29,30,5,4,66,2,10,90,15,25,33,34,38,93,94,6,3);          00118700
                                                                                00118800
         DECLARE LOOK2(LSIZE) BIT(8) INITIAL (0,84,7,85,35,86,87,87,45,46,117,4700118900
         ,88,48,98,49,99,50,147,51,148,53,102,54,103,55,89,59,139,60,140,61,113 00119000
         ,62,114,63,131,64,132);                                                00119100
                                                                                00119200
         DECLARE APPLY2(ASIZE) BIT(8) INITIAL (0,0,56,92,57,95,145,143,137,72,7100119300
         ,96,115,76,75,58,106,68,77,69,119,118,120,110,125,82,81,83,80,107,130  00119400
         ,70,97,108,144,138,79,78,109,146,52,74,73);                            00119500
                                                                                00119600
         DECLARE INDEX1(MAXS#) BIT(8) INITIAL (0,1,2,3,4,5,6,7,44,8,10,44,11,12 00119700
         ,14,20,25,26,27,28,29,30,31,27,28,32,36,37,30,38,39,40,41,42,44,48,49  00119800
         ,50,51,50,53,54,53,53,53,55,55,58,59,59,60,60,61,62,62,63,64,70,71,72  00119900
         ,72,73,73,73,73,1,2,4,6,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,91 00120000
         ,133,126,116,135,124,1,2,2,3,3,4,4,4,5,5,9,9,11,11,13,13,15,15,15,15,1600120100
         ,17,17,17,17,17,18,18,18,18,18,19,20,22,23,23,24,24,25,25,29,30,30,31  00120200
         ,31,32,32,33,33,34,34,36,36,38,38,38,38,39,39,41,41);                  00120300
                                                                                00120400
         DECLARE INDEX2(MAXS#) BIT(8) INITIAL (0,1,1,1,1,1,1,1,2,2,1,2,1,2,6,5,100120500
         ,1,1,1,1,1,1,1,1,4,1,1,1,1,1,1,1,2,4,1,1,1,2,1,1,1,1,1,1,3,1,1,1,1,1,1 00120600
         ,1,1,1,1,6,1,1,1,1,1,1,1,1,1,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,7,3500120700
         ,45,47,55,1,0,1,1,1,4,4,4,1,1,0,2,1,1,0,2,0,0,0,0,3,1,1,1,1,0,0,0,0,1,000120800
         ,1,1,1,0,3,0,1,0,2,1,1,1,0,1,0,1,1,1,1,1,0,2,3,3,3,3,1,1,0,2);         00120900
                                                                                00121000
DECLARE ENDFILE BIT(16) INITIAL(7),                                             00121100
        SEMICOLON BIT(16) INITIAL(1),                                           00121200
        CHARACTER_STRING BIT(16) INITIAL(0),                                    00121300
        LABELNAME BIT(16) INITIAL(28),                                          00121400
        NUMBER BIT(16) INITIAL(31),                                             00121500
        SCALAR BIT(16) INITIAL(0),                                              00121600
        HEXADECIMAL BIT(16) INITIAL(14),                                        00121700
        SEQUENCE BIT(16) INITIAL(0);                                            00121800
                                                                                00121900
   /*  STACK DECLARATIONS  */                                                   00122000
                                                                                00122100
DECLARE STAKSIZE LITERALLY '30',                                                00122200
        (MP,SP,MPP1,MAXSP) BIT(16),                                             00122300
        STATE BIT(16),                                                          00122400
        LOOK BIT(16),                                                           00122500
        TOKEN BIT(16),                                                          00122600
        VALUE(STAKSIZE) FIXED,                                                  00122700
        BCD(STAKSIZE) CHARACTER,                                                00122800
        LOOK_STAK(STAKSIZE) BIT(16),                                            00122900
        STATE_STAK(STAKSIZE) BIT(16);                                           00123000
                                                                                00123100
                                                                                00123200
     /*  SOME SCANNER TABLES  */                                                00123300
                                                                                00123400
DECLARE CONTEXT(TERMINAL#) BIT(8) INITIAL(0,0,1,0,0,0,4,0,0,0,0,4,5,1,0,1,      00123500
                                     0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0);00123600
DECLARE NULL BIT(8) INITIAL(0),                                                 00123700
        RESERVED BIT(8) INITIAL(1),                                             00123800
        TIMING BIT(8) INITIAL(2),                                               00123900
        SRN BIT(8) INITIAL(3),                                                  00124000
        HEXNUM BIT(8) INITIAL(4),                                               00124100
        GENCHAR BIT(8) INITIAL(5);                                              00124200
                                                                                00124300
DECLARE CHARTYPE(255) BIT(8) INITIAL(                                           00124400
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,              00124500
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,              00124600
      0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,              00124700
      0,3,5,0,5,0,0,3,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,              00124800
      0,0,5,3,3,2,0,0,0,3,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,3,3,3,3,3,              00124900
      3,3,3,3,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,              00125000
      0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,3,              00125100
      3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,3,3,3,3,3,3,3,3,0,0,0,0,0,0,              00125200
      4,4,4,4,4,4,4,4,4,4,0,0,0,0,0,6);                                         00125300
DECLARE NOT_LETTER_OR_DIGIT(255) BIT(8) INITIAL(                                00125400
      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,              00125500
      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,              00125600
      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,              00125700
      1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,              00125800
      1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,              00125900
      0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,              00126000
      1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,              00126100
      0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,              00126200
      0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1);                                         00126300
                                                                                00126400
DECLARE (COMPILING,LOOK_AHEAD) BIT(1);                                          00126500
DECLARE (DWORG,CARD#) FIXED, DWAREA(4) FIXED,                                   00126600
        (CP,TEXT_LIMIT) BIT(16),                                                00126700
        TEXT CHARACTER;                                                         00126800
                                                                                00126900
BASED DW FIXED;                                                                 00127000
                                                                                00127100
DECLARE TOGGLE(9) BIT(1), SUCCESS BIT(1) INITIAL(1);                            00127200
                                                                                00127300
                                                                                00127400
                                                                                00127500
   /*   LIMITING HALSTAT SIZES AND LENGTHS   */                                 00127600
                                                                                00127700
DECLARE  PAGE_SIZE LITERALLY '1680',       /* PHYSICAL BLOCK SIZE OF SDF PAGES*/00127800
         MAX_CSECT_TYPES LITERALLY '19',   /* MAX NUMBER OF CSECT TYPES       */00127900
         ALT_PAD_SIZE LITERALLY '16000';   /* ALLOW UP TO 1000 PAGES          */00128000
                                                                                00128100
DECLARE  MISC_VAL     LITERALLY '49';                                           00128200
                                                                                00128300
DECLARE  (DW_AD,ADDR_VALUE,ADDR_FIXER,ADDR_FIXED_LIMIT,ADDR_ROUNDER,TMP) FIXED, 00128400
         (TMP1) FIXED;                                                          00128500
                                                                                00128600
   /* USEFUL CHARACTER LITERALS */                                              00128700
                                                                                00128800
DECLARE  ACHAR          CHARACTER INITIAL ('A'),                                00128900
         BCHAR          CHARACTER INITIAL ('B'),                                00129000
         BLCHAR         CHARACTER INITIAL ('BL'),                               00129100
         CLCHAR         CHARACTER INITIAL ('CL'),                               00129200
         DCHAR          CHARACTER INITIAL ('D'),                                00129300
         ECHAR          CHARACTER INITIAL ('E'),                                00129400
         FCHAR          CHARACTER INITIAL ('F'),                                00129500
         HCHAR          CHARACTER INITIAL ('H'),                                00129600
         MCHAR          CHARACTER INITIAL ('M'),                                00129700
         UCHAR          CHARACTER INITIAL ('U'),                                00129800
         VCHAR          CHARACTER INITIAL ('V'),                                00129900
         XCHAR          CHARACTER INITIAL ('X'),                                00130000
         XLCHAR         CHARACTER INITIAL ('XL'),                               00130100
         YCHAR          CHARACTER INITIAL ('Y'),                                00130200
         ZCHAR          CHARACTER INITIAL ('Z');                                00130300
                                                                                00130400
DECLARE  COLON          CHARACTER INITIAL (':'),                                00130500
         BLK_COLON_BLK  CHARACTER INITIAL (' : '),                              00130505
         SEMI_COLON     CHARACTER INITIAL (';'),                                00130600
         SEMICOLON_BLK  CHARACTER INITIAL ('; '),                               00130700
         BLK_EQUALS_BLK CHARACTER INITIAL (' = '),                              00130705
         COMMA          CHARACTER INITIAL (','),                                00130800
         PERIOD         CHARACTER INITIAL ('.'),                                00130900
         PERIOD3        CHARACTER INITIAL ('               ...'),               00130905
         AT_SIGN        CHARACTER INITIAL ('@'),                                00131000
         DOLLAR_SIGN    CHARACTER INITIAL ('$'),                                00131100
         SHARP_SIGN     CHARACTER INITIAL ('#'),                                00131200
         ASTERISK_SIGN  CHARACTER INITIAL ('*'),                                00131300
         DBL_SHARP_SIGN CHARACTER INITIAL ('##'),                               00131400
         DBL_DOLLAR_SIGN CHARACTER INITIAL ('$$'),                              00131500
         PCENT_SIGN     CHARACTER INITIAL ('%'),                                00131600
         PLUS           CHARACTER INITIAL ('+'),                                00131700
         MINUS          CHARACTER INITIAL ('-'),                                00131800
         BLK_MINUS_BLK  CHARACTER INITIAL (' - '),                              00131805
         QUOTE          CHARACTER INITIAL (''''),                               00131900
         DBL_QUOTE      CHARACTER INITIAL ('"'),                                00132000
         LPAREN         CHARACTER INITIAL ('('),                                00132100
         RPAREN         CHARACTER INITIAL (')'),                                00132200
         RPAR_BLK       CHARACTER INITIAL (') '),                               00132300
         AST_RPAR_BLK   CHARACTER INITIAL ('*) '),                              00132400
         LPAR_AST_RPAR_BLK CHARACTER INITIAL ('(*) '),                          00132500
         SLASH          CHARACTER INITIAL ('/'),                                00132600
         DOUBLE         CHARACTER INITIAL ('0'),                                00132700
         ZEROCHAR       CHARACTER INITIAL ('0'),                                00132800
         ZERO6          CHARACTER INITIAL ('000000'),                           00132805
         ONE            CHARACTER INITIAL ('1'),                                00132900
         TWO            CHARACTER INITIAL ('2'),                                00133000
         ASTS           CHARACTER INITIAL (' ***'),                             00133100
         HEXCODES       CHARACTER INITIAL ('0123456789ABCDEF'),                 00133200
         HALSTAT_ERR    CHARACTER INITIAL ('*** HALSTAT INTERNAL ERROR: '),     00133300
         NUM_STRING CHARACTER INITIAL('0123456789'),                            00133400
         KEY_STRING CHARACTER INITIAL('  C  DPFTZREXQL'),                       00133500
         X1             CHARACTER INITIAL (' '),                                00133600
         X2             CHARACTER INITIAL ('  '),                               00133700
         X3             CHARACTER INITIAL ('   '),                              00133800
         X4             CHARACTER INITIAL ('    '),                             00133900
         X5             CHARACTER INITIAL ('     '),                            00134000
         X6             CHARACTER INITIAL ('      '),                           00134100
         X7             CHARACTER INITIAL ('       '),                          00134200
         X8             CHARACTER INITIAL ('        '),                         00134300
         X10            CHARACTER INITIAL ('          '),                       00134400
         X11            CHARACTER INITIAL ('           '),                      00134500
         X12            CHARACTER INITIAL ('            '),                     00134600
         X14            CHARACTER INITIAL ('              '),                   00134700
         X15            CHARACTER INITIAL ('               '),                  00134800
         X20            CHARACTER INITIAL ('                    '),             00134900
         X24            CHARACTER INITIAL ('                        '),         00135000
         X33            CHARACTER INITIAL                                       00135100
 ('                                 '),                                         00135200
         X38            CHARACTER INITIAL                                       00135300
 ('                                      '),                                    00135400
         X52            CHARACTER INITIAL                                       00135500
 ('                                                    '),                      00135600
         X71            CHARACTER INITIAL                                       00135700
 ('                                                                       '),   00135800
         X72            CHARACTER INITIAL                                       00135900
 ('                                                                        '),  00136000
         PRINTLINE      CHARACTER INITIAL                                       00136100
('                                                                              00136200
                                                                      ');       00136300
                                                                                00136400
   /* CSECT PREFIX CHARACTER STRINGS */                                         00136500
                                                                                00136600
DECLARE  DATA_CSECT     CHARACTER INITIAL ('#D'),                               00136700
         PDE_CSECT      CHARACTER INITIAL ('#E'),                               00136800
         FSIM_CSECT     CHARACTER INITIAL ('#F'),                               00136900
         COMPOOL_CSECT  CHARACTER INITIAL ('#P'),                               00137000
         REMOTE_CSECT   CHARACTER INITIAL ('#R'),                               00137100
         TIME_CSECT     CHARACTER INITIAL ('#T'),                               00137200
         EXCLUSIVE_CSECT CHARACTER INITIAL ('#X'),                              00137300
         ZCON_CSECT     CHARACTER INITIAL ('#Z');                               00137400
                                                                                00137500
   /* DECLARES FOR MISCELLANEOUS HAL/S ATTRIBUTES, DATA TYPES, ETC. */          00137600
                                                                                00137700
DECLARE  ATTR_AUTOMATIC CHARACTER INITIAL ('AUTOMATIC '),                       00137800
         ATTR_DENSE     CHARACTER INITIAL ('DENSE '),                           00137900
         ATTR_RIGID     CHARACTER INITIAL ('RIGID '),                           00138000
         ATTR_INITIAL   CHARACTER INITIAL ('INITIAL() '),                       00138100
         ATTR_CONSTANT  CHARACTER INITIAL ('CONSTANT() '),                      00138200
         ATTR_ACCESS    CHARACTER INITIAL ('ACCESS '),                          00138300
         ATTR_REENTRANT CHARACTER INITIAL ('REENTRANT '),                       00138400
         ATTR_EXCLUSIVE CHARACTER INITIAL ('EXCLUSIVE '),                       00138500
         ATTR_LOCK      CHARACTER INITIAL ('LOCK('),                            00138600
         ATTR_NAME      CHARACTER INITIAL ('NAME '),                            00138700
         ATTR_LATCHED   CHARACTER INITIAL ('LATCHED '),                         00138800
         ATTR_ARRAY     CHARACTER INITIAL ('ARRAY('),                           00138900
         ATTR_TEMPORARY CHARACTER INITIAL ('TEMPORARY '),                       00139000
         ATTR_REMOTE    CHARACTER INITIAL ('REMOTE '),                          00139100
         ATTR_INPUT     CHARACTER INITIAL ('''INPUT'','),                       00139200
         ATTR_ASSIGN    CHARACTER INITIAL ('''ASSIGN'','),                      00139300
         ATTR_STACK     CHARACTER INITIAL ('''STACK'','),                       00139400
         ATTR_LITERAL   CHARACTER INITIAL ('''LITERAL'','),                     00139500
         ATTR_EQUATED   CHARACTER INITIAL ('''EQUATED'','),                     00139600
         ATTR_UNQUALIFIED CHARACTER INITIAL ('''UNQUALIFIED'','),               00139700
         ATTR_INDIRECT   CHARACTER INITIAL ('''INDIRECT'','),                   00139800
         ATTR_NAMED      CHARACTER INITIAL ('''NAMED'','),                      00139805
         ATTR_PARAMETERIZED CHARACTER INITIAL ('''PARAMETERIZED'','),           00139810
         ATTR_COMPOOL    CHARACTER INITIAL ('COMPOOL '),                        00139900
         ATTR_FUNCTION   CHARACTER INITIAL ('FUNCTION '),                       00140000
         ATTR_PROGRAM    CHARACTER INITIAL ('PROGRAM '),                        00140100
         ATTR_TASK       CHARACTER INITIAL ('TASK '),                           00140200
         ATTR_PROCEDURE  CHARACTER INITIAL ('PROCEDURE '),                      00140300
         ATTR_UPDATE     CHARACTER INITIAL ('UPDATE '),                         00140400
         ATTR_REPLACE    CHARACTER INITIAL ('REPLACE '),                        00140500
         ATTR_MINOR_STRUC CHARACTER INITIAL ('MINOR STRUCTURE '),               00140600
         ATTR_STRUCTURE  CHARACTER INITIAL ('STRUCTURE'),                       00140700
         ATTR_TERMINAL   CHARACTER INITIAL ('TERMINAL '),                       00140800
         ATTR_STRUC_TERM CHARACTER INITIAL ('STRUCTURE TERMINAL '),             00140900
         ATTR_LABEL      CHARACTER INITIAL ('LABEL '),                          00141000
         ATTR_DOUBLE     CHARACTER INITIAL ('DOUBLE '),                         00141100
         ATTR_EVENT      CHARACTER INITIAL ('EVENT '),                          00141200
         ATTR_BIT        CHARACTER INITIAL ('BIT('),                            00141300
         ATTR_VECTOR     CHARACTER INITIAL ('VECTOR('),                         00141400
         ATTR_MATRIX     CHARACTER INITIAL ('MATRIX('),                         00141500
         ATTR_CHARACTER  CHARACTER INITIAL ('CHARACTER('),                      00141600
         ATTR_INTEGER    CHARACTER INITIAL ('INTEGER '),                        00141700
         ATTR_SCALAR     CHARACTER INITIAL ('SCALAR '),                         00141800
         ATTR_PHASE      CHARACTER INITIAL ('PHASE ');                          00141805
                                                                                00141900
   /* DECLARES FOR SPECIAL TABLST LOGIC */                                      00142000
                                                                                00142100
DECLARE STMT_TYPES(36) CHARACTER INITIAL(                                       00142200
         'NULL', 'EXIT/REPEAT/GOTO', 'CALL', 'READ/READALL/WRITE',              00142300
        'ASSIGN', 'IF', 'CLOSE', 'RETURN', 'END', 'SCHEDULE',                   00142400
        'CANCEL/TERMINATE', 'WAIT', 'UPDATE PRIORITY',                          00142500
        'SET/SIGNAL/RESET', 'SEND ERROR', 'ON ERROR', 'FILE',                   00142600
        'DO', 'DO WHILE/DO UNTIL', 'DO FOR', 'DO CASE',                         00142700
        '', 'BLOCK', '', '', '', '', '', '', '', '', '',                        00142800
         '%SVC', '%NAMECOPY', '%COPY', '%SVCI', '%NAMEADD');                    00142900
                                                                                00143000
DECLARE STMT_FLAGS(4) CHARACTER INITIAL('', 'ELSE ', 'THEN ', '',               00143100
        'ON_ERROR_OBJ: ');                                                      00143200
                                                                                00143300
DECLARE SYMBOL_CLASSES(6) CHARACTER INITIAL(                                    00143400
        '', '  VARIABLE    ', '  LABEL       ',                                 00143500
        '  FUNCTION    ', '  TEMPLATE    ',                                     00143600
        '  TPL LBL     ', '  TPL FUNC LBL');                                    00143700
                                                                                00143800
DECLARE SYMBOL_TYPES(17) CHARACTER INITIAL(                                     00143900
        '', '  BIT STRING', '  CHARACTER ',                                     00144000
        '  SP MATRIX ', '  SP VECTOR ', '  SP SCALAR ',                         00144100
        '  SP INTEGER', '', '', '  BIT STRING',                                 00144200
        '  BIT STRING', '  DP MATRIX ', '  DP VECTOR ',                         00144300
        '  DP SCALAR ', '  DP INTEGER', '',                                     00144400
         '  STRUCTURE ', '  EVENT     ');                                       00144500
                                                                                00144600
DECLARE PROC_TYPES(9) CHARACTER INITIAL(                                        00144700
        '', '  PROGRAM   ', '  PROCEDURE ',                                     00144800
        '  FUNCTION  ', '  COMPOOL   ', '  TASK      ',                         00144900
        '  UPDATE    ', '  STATEMENT ', '  EQUATE    ', '  REPLACE   ');        00145000
                                                                                00145100
   /* DECLARATIONS FOR CSECT CLASSIFICATION AND ACCOUNTING */                   00145200
                                                                                00145300
DECLARE CSECT_COUNT(MAX_CSECT_TYPES) BIT(16);                                   00145400
DECLARE CSECT_TOTAL_SIZE(MAX_CSECT_TYPES) FIXED;                                00145500
DECLARE CSECT_DESCRIPT(MAX_CSECT_TYPES) CHARACTER INITIAL(                      00145600
        'NON-HAL','$0(PROGRAM)','$N(TASK)','#C(COMSUB)','INTERNAL BLOCK',       00145700
        'STACK','#D(DATA)','#P(DATA)','#F(FSIM)','#T(COST/USE)','#Z(ZCON)',     00145800
        '#R(REMOTE)','#E(PDE)','#X(EXCLUSIVE)','#Q(QCON)','#L(LIB DATA)',       00145900
         'LIBRARY RTN','BCE','MSC','PATCH');                                    00146000
                                                                                00146100
   /* DECLARATIONS FOR STATEMENT CLASSIFICATION AND ACCOUNTING */               00146200
                                                                                00146300
DECLARE STMT_CNT(36) FIXED;                                                     00146400
DECLARE GLOBAL_STMT_CNT(36) FIXED;                                              00146500
                                                                                00146600
   /* DECLARES FOR CSECT PHASE CLASSIFICATION */                                00146700
                                                                                00146800
DECLARE NUM_PHASES BIT(16);                                                     00146900
DECLARE PHASE_TAB(256) BIT(8);                                                  00147000
                                                                                00147100
   /* DECLARES FOR SYNTHESIZE & HALSTAT COMMAND TABLES */                       00147200
                                                                                00147300
DECLARE MAX_XUNITS LITERALLY '1500',                                            00147400
        MAX_XPHASES LITERALLY '1500',                                           00147500
        MAX_CONFIGS LITERALLY '25',                                             00147600
        MAX_FUNCS LITERALLY '25',                                               00147700
        MAX_TPHASES LITERALLY '500',                                            00147800
        MAX_MAP_CMDS LITERALLY '25';                                            00147900
                                                                                00148000
DECLARE (#XUNITS,#XPHASES,#CONFIGS,#FUNCS,#TPHASES,#MAP_CMDS) BIT(16),          00148100
        (XFROM,XTO) FIXED,                                                      00148200
        (CSECT_BOOL,CSECT_CAT) BIT(8),                                          00148300
        (XFORMAT,XLEVEL,MAP_CMD) BIT(16);                                       00148400
                                                                                00148500
                                                                                00148600
BASED  XUNITS BIT(16),                                                          00148700
       XPHASES BIT(16);                                                         00148800
                                                                                00148900
DECLARE CONFIG_NAME(MAX_CONFIGS) CHARACTER,                                     00149000
        CONFIG_PHASE_PTR(MAX_CONFIGS) BIT(16);                                  00149100
                                                                                00149200
DECLARE FUNC_NAME(MAX_FUNCS) CHARACTER,                                         00149300
        FUNC_UNIT_PTR(MAX_FUNCS) BIT(16);                                       00149400
                                                                                00149500
DECLARE MAP_CMD_TYPE(MAX_MAP_CMDS) BIT(8),                                      00149600
        MAP_CMD_LEVEL(MAX_MAP_CMDS) BIT(8),                                     00149700
        MAP_CMD_FMT(MAX_MAP_CMDS) BIT(8),                                       00149800
        MAP_CMD_ADDR1(MAX_MAP_CMDS) FIXED,                                      00149900
        MAP_CMD_ADDR2(MAX_MAP_CMDS) FIXED,                                      00150000
        MAP_CMD_UTIL(MAX_MAP_CMDS) BIT(16);                                     00150100
                                                                                00150200
DECLARE TPHASES(MAX_TPHASES) BIT(16);                                           00150300
                                                                                00150400
   /* DECLARES FOR GAP DETECTION LOGIC */                                       00150500
                                                                                00150600
DECLARE MAX_#GAPS LITERALLY '450';                                              00150700
DECLARE (GLOBAL_GAP_CNT,#GLOBAL_GAPS) BIT(16);                                  00150800
DECLARE (SAVE_GAP_FLAG,GLOBAL_GAP_FLAG) BIT(1);                                 00150900
                                                                                00151000
BASED  (GAP_ADDR1,GAP_ADDR2,GLOBAL_GAP_ADDR1,GLOBAL_GAP_ADDR2) FIXED;           00151100
                                                                                00151200
   /* VIRTUAL MEMORY PAGING SYSTEM PARAMETERS AND DATA */                       00151300
                                                                                00151400
DECLARE VMEM_LIM_PAGES LITERALLY '399',                                         00151500
         VMEM_PAGE_LIMIT LITERALLY '1999';                                      00151600
                                                                                00151700
   /*          $%VMEM1X          */                                             00151800
   /*          $%STND            */                                             00151900
   /*          $%CONV            */                                             00152000
   /*          $%TRACE           */                                             00152100
   /*          $%EXPAND          */                                             00152200
   /*          SCDLWJSX        */                                               00152210
                                                                                00152300
   /* DECLARES FOR MONITOR 28 CALL */                                           00152400
                                                                                00152500
DECLARE  NAMERTN(1) FIXED,                                                      00152600
         MINCORE FIXED INITIAL(100000),                                         00152700
         MAXCORE FIXED INITIAL(5000000),                                        00152800
         CORE_ADDR FIXED,                                                       00152900
         CORE_LEN FIXED;                                                        00153000
                                                                                00153100
   /* SDF GLOBAL PARAMETERS */                                                  00153200
                                                                                00153300
DECLARE  FIRST_STMT BIT(16),               /* NUMBER OF FIRST EXECUTABLE STMT*/ 00153400
         LAST_STMT BIT(16),                /* NUMBER OF LAST STATEMENT       */ 00153500
         #SYMBOLS BIT(16),                 /* TOTAL NUMBER OF SYMBOL NODES   */ 00153600
         #STMTS BIT(16),                   /* TOTAL NUMBER OF STMT NODES     */ 00153700
         #EXTERNALS BIT(16),               /* NUMBER OF INCLUDED COMPOOLS    */ 00153800
         #PROCS BIT(16),                   /* NUMBER OF HAL BLOCKS           */ 00153900
         REF_STAT BIT(16),                                                      00154000
         KEY_BLOCK BIT(16),                                                     00154100
         KEY_SYMB BIT(16),                                                      00154200
         #GAPS BIT(16),                                                         00154300
         #PSEUDO_GAPS BIT(16),                                                  00154400
         MIN_GAP BIT(16),                                                       00154500
         #OVERLAPS BIT(16),                                                     00154600
         #REFS1 BIT(16),                                                        00154700
         #REFS2 BIT(16),                                                        00154800
         SAVE_BASE BIT(16),                                                     00154900
         SAVE_NDX FIXED,                                                        00155000
         SELECTED_UNIT BIT(16),                                                 00155100
         LAST_MAP_ADDR FIXED,                                                   00155200
         LAST_GAP_ADDR FIXED,                                                   00155300
         LAST_OVERLAP_ADDR FIXED,                                               00155400
         GAP_SIZE FIXED,                                                        00155500
         TOTAL_ERRORS FIXED,                                                    00155600
         TOTAL_STACK_WALKS FIXED,                                               00155700
         SEVERE_ERRORS FIXED,                                                   00155800
         SAVE_SEVERE_ERRORS BIT(16),                                            00155900
         UNUSED_CNT FIXED,                                                      00156000
         TOTAL_EXTRAN_CNT BIT(16),                                              00156100
         TOTAL_EXTRAN_SIZE FIXED,                                               00156200
         UNASSIGN_CNT BIT(16),                                                  00156300
         LAST_ERROR FIXED,                                                      00156400
         #LIBS BIT(16),                                                         00156500
         NONHAL BIT(16),                                                        00156600
         LIBRARY BIT(16),                                                       00156700
         QCON BIT(16),                                                          00156800
         LIBRARY_DATA BIT(16),                                                  00156900
         MAX_PHASE BIT(16),                                                     00157000
         MAP_LEVEL BIT(16) INITIAL(0),                                          00157100
         MAX_MAP_LEVEL BIT(16) INITIAL(0),                                      00157200
         FILE_LEVEL BIT(16),                                                    00157300
         #U_CMDS BIT(16),                                                       00157400
         CARD_NO FIXED,                                                         00157500
         GSD_LEVEL BIT(16) INITIAL(2),                                          00157600
         MSG_LEVEL BIT(16) INITIAL(1),                                          00157700
         GFORMAT BIT(16) INITIAL(0),                                            00157800
         MFORMAT BIT(16) INITIAL(0),                                            00157900
         TOTAL_SYM_REC FIXED,                                                   00158000
         TOTAL_SYM_REC_INSERT FIXED,                                            00158100
         TOTAL_RLD_REC FIXED,                                                   00158200
         SDFPKG_LOCATES FIXED,                                                  00158300
         SDFPKG_READS FIXED,                                                    00158400
         SDFPKG_SLECTCNT FIXED,                                                 00158500
         SDFPKG_FCBAREA FIXED,                                                  00158600
         SDFPKG_PGAREA BIT(16),                                                 00158700
         SDFPKG_NUMGETM BIT(16),                                                00158800
         FREE_STRING_SIZE FIXED,                                                00158900
         MIN_STRING_SIZE FIXED,                                                 00159000
         #LABELS BIT(16),                  /* NUMBER OF LABELS              */  00159100
         #LHS BIT(16);                     /* NUMBER OF LEFT-HAND SIDES     */  00159200
                                                                                00159300
   /* BUFFERS FOR VMEM TRACKING OF FILE 1 AND 2 */                              00159400
                                                                                00159500
DECLARE (VMEM_BUFF_ADDR1,VMEM_BUFF_ADDR2) FIXED;                                00159600
                                                                                00159700
   /* VARIABLES FOR REPLACE TEXT PROCESSING */                                  00159800
                                                                                00159900
DECLARE (REPL_TEXT_PTR1,REPL_TEXT_ADDR1,REPL_TEXT_PTR2,REPL_TEXT_ADDR2) FIXED,  00160000
         (REPL_LEN1,REPL_LEN2) BIT(16);                                         00160100
                                                                                00160200
   /* MODE INDICATION FLAGS */                                                  00160300
                                                                                00160400
DECLARE  SRN_FLAG BIT(1) INITIAL(0),       /* 1 --> SDF HAS SRNS (SDL CONFIG) */00160500
         ADDR_FLAG BIT(1) INITIAL(0),      /* 1 --> SDF HAS STMT ADDRESSES    */00160600
         FCDATA_FLAG BIT(1) INITIAL(0),    /* 1 --> FCDATA MODE (360)         */00160700
         COMPOOL_FLAG BIT(1) INITIAL(0),   /* 1 --> SDF IS FOR A COMPOOL UNIT */00160800
         FC_FLAG BIT(1) INITIAL(0),        /* 1 --> FC LOAD MODULE            */00160900
         ADL_FLAG BIT(1) INITIAL(0),       /* 1 --> TAPE PRODUCED FOR ADL     */00161000
         STAT_FLAG     BIT(1) INITIAL(0),  /* 1 --> COMP. UNIT STATISTICS     */00161100
         EOFLAG BIT(1) INITIAL(0),        /* 1 --> END OF FILE ON SYSIN       */00161200
         EJECT_FLAG BIT(1) INITIAL(0);    /* 1 --> PAGE EJECTS IN COMP. STATS.*/00161300
                                                                                00161400
   /* DECLARES FOR SDFPKG COMMUNICATION AREA */                                 00161500
                                                                                00161600
DECLARE  COMM_TAB(29) FIXED;                                                    00161700
                                                                                00161800
BASED    COMMTABL_BYTE BIT(8),                                                  00161900
         COMMTABL_HALFWORD BIT(16),                                             00162000
         COMMTABL_FULLWORD FIXED;                                               00162100
                                                                                00162200
DECLARE  COMMTABL_ADDR FIXED;                                                   00162300
                                                                                00162400
DECLARE  APGAREA  LITERALLY 'COMMTABL_FULLWORD(0)',                             00162500
         AFCBAREA LITERALLY 'COMMTABL_FULLWORD(1)',                             00162600
         NPAGES   LITERALLY 'COMMTABL_HALFWORD(4)',                             00162700
         NBYTES   LITERALLY 'COMMTABL_HALFWORD(5)',                             00162800
         MISC     LITERALLY 'COMMTABL_HALFWORD(6)',                             00162900
         CRETURN  LITERALLY 'COMMTABL_HALFWORD(7)',                             00163000
         BLKNO    LITERALLY 'COMMTABL_HALFWORD(8)',                             00163100
         SYMBNO   LITERALLY 'COMMTABL_HALFWORD(9)',                             00163200
         STMTNO   LITERALLY 'COMMTABL_HALFWORD(10)',                            00163300
         BLKNLEN  LITERALLY 'COMMTABL_BYTE(22)',                                00163400
         SYMBNLEN LITERALLY 'COMMTABL_BYTE(23)',                                00163500
         PNTR     LITERALLY 'COMMTABL_FULLWORD(6)',                             00163600
         ADDRESS  LITERALLY 'COMMTABL_FULLWORD(7)',                             00163700
         SDFNAM   LITERALLY 'COMMTABL_ADDR+32',                                 00163800
         CSECTNAM LITERALLY 'COMMTABL_ADDR+40',                                 00163900
         SREFNO   LITERALLY 'COMMTABL_ADDR+48',                                 00164000
         INCLCNT  LITERALLY 'COMMTABL_HALFWORD(27)',                            00164100
         BLKNAM   LITERALLY 'COMMTABL_ADDR+56',                                 00164200
         SYMBNAM  LITERALLY 'COMMTABL_ADDR+88';                                 00164300
                                                                                00164400
   /* DECLARES FOR SDFPKG INTERNAL DATA BUFFER (DATABUF) */                     00164500
                                                                                00164600
BASED     DATABUF_BYTE BIT(8),                                                  00164700
          DATABUF_HALFWORD BIT(16),                                             00164800
          DATABUF_FULLWORD FIXED;                                               00164900
                                                                                00165000
DECLARE   LOCCNT    LITERALLY 'DATABUF_FULLWORD(0)',                            00165100
          AVULN     LITERALLY 'DATABUF_FULLWORD(1)',                            00165200
          CURFCB    LITERALLY 'DATABUF_FULLWORD(2)',                            00165300
          PADADDR   LITERALLY 'DATABUF_FULLWORD(3)',                            00165400
          ACOMMTAB  LITERALLY 'DATABUF_FULLWORD(4)',                            00165500
          ACURNTRY  LITERALLY 'DATABUF_FULLWORD(5)',                            00165600
          ROOT      LITERALLY 'DATABUF_FULLWORD(6)',                            00165700
          SAVEXTPT  LITERALLY 'DATABUF_FULLWORD(7)',                            00165800
          SAVFSYMB  LITERALLY 'DATABUF_HALFWORD(16)',                           00165900
          SAVLSYMB  LITERALLY 'DATABUF_HALFWORD(17)',                           00166000
          NUMGETM   LITERALLY 'DATABUF_HALFWORD(18)',                           00166100
          NUMOFPGS  LITERALLY 'DATABUF_HALFWORD(19)',                           00166200
          BASNPGS   LITERALLY 'DATABUF_HALFWORD(20)',                           00166300
          FCBSTKLN  LITERALLY 'DATABUF_HALFWORD(21)',                           00166400
          IOFLAG    LITERALLY 'DATABUF_BYTE(44)',                               00166500
          GETMFLAG  LITERALLY 'DATABUF_BYTE(45)',                               00166600
          GOFLAG    LITERALLY 'DATABUF_BYTE(46)',                               00166700
          MODFLAG   LITERALLY 'DATABUF_BYTE(47)',                               00166800
          ONEFCB    LITERALLY 'DATABUF_BYTE(48)',                               00166900
          FIRST     LITERALLY 'DATABUF_BYTE(49)',                               00167000
          TOTFCBLN  LITERALLY 'DATABUF_FULLWORD(13)',                           00167100
          RESERVES  LITERALLY 'DATABUF_FULLWORD(14)',                           00167200
          READS     LITERALLY 'DATABUF_FULLWORD(15)',                           00167300
          WRITES    LITERALLY 'DATABUF_FULLWORD(16)',                           00167400
          SLECTCNT  LITERALLY 'DATABUF_FULLWORD(17)',                           00167500
          FCBCNT    LITERALLY 'DATABUF_FULLWORD(18)',                           00167600
          VERSION   LITERALLY 'DATABUF_HALFWORD(47)';                           00167700
                                                                                00167800
   /* DECLARES FOR ADL TAPE GENERATION LOGIC */                                 00167900
                                                                                00168000
DECLARE ADLBUFF(19) FIXED;                                                      00168100
                                                                                00168200
BASED   ADLBUFF_BYTE BIT(8),                                                    00168300
        ADLBUFF_HW BIT(16),                                                     00168400
        ADLBUFF_FW FIXED;                                                       00168500
                                                                                00168600
DECLARE ADLBUFF_ADDR FIXED;                                                     00168700
DECLARE RECORD_BUFFER CHARACTER;                                                00168800
                                                                                00168900
DECLARE RECORD_TYPE     LITERALLY 'ADLBUFF_BYTE(0)',                            00169000
        RECORD_REC#     LITERALLY 'ADLBUFF_FW(0)',                              00169100
        RECORD_RECID    LITERALLY 'ADLBUFF_FW(1)',                              00169200
        RECORD_NAME     LITERALLY 'ADLBUFF_ADDR+8',                             00169300
        RECORD_DATE     LITERALLY 'ADLBUFF_FW(10)',                             00169400
        RECORD_TIME     LITERALLY 'ADLBUFF_FW(11)',                             00169500
        RECORD_UNITID   LITERALLY 'ADLBUFF_HW(20)',                             00169600
        RECORD_BLKID    LITERALLY 'ADLBUFF_HW(21)',                             00169700
        RECORD_VCLASS   LITERALLY 'ADLBUFF_BYTE(44)',                           00169800
        RECORD_VTYPE    LITERALLY 'ADLBUFF_BYTE(45)',                           00169900
        RECORD_STACKID  LITERALLY 'ADLBUFF_HW(23)',                             00170000
        RECORD_FLAGS    LITERALLY 'ADLBUFF_FW(12)',                             00170100
        RECORD_PHASE    LITERALLY 'ADLBUFF_BYTE(52)',                           00170200
        RECORD_ADDR1    LITERALLY 'ADLBUFF_FW(13)',                             00170300
        RECORD_SIZE     LITERALLY 'ADLBUFF_FW(14)',                             00170400
        RECORD_ADDR2    LITERALLY 'ADLBUFF_FW(14)',                             00170500
        RECORD_BIAS     LITERALLY 'ADLBUFF_FW(15)',                             00170600
        RECORD_MISC     LITERALLY 'ADLBUFF_HW(32)',                             00170700
        RECORD_#COPIES  LITERALLY 'ADLBUFF_HW(33)',                             00170800
        RECORD_#DIMS    LITERALLY 'ADLBUFF_BYTE(68)',                           00170900
        RECORD_CPYSIZE  LITERALLY 'ADLBUFF_FW(17)',                             00171000
        RECORD_DIM1     LITERALLY 'ADLBUFF_HW(36)',                             00171100
        RECORD_DIM2     LITERALLY 'ADLBUFF_HW(37)',                             00171200
        RECORD_DIM3     LITERALLY 'ADLBUFF_HW(38)',                             00171300
        RECORD_SPARE2   LITERALLY 'ADLBUFF_HW(39)';                             00171400
                                                                                00171500
   /* DECLARES FOR SYM RECORD PROCESSING */                                     00171600
                                                                                00171700
DECLARE SYM_STRUC_PTR FIXED;                                                    00171800
DECLARE SYM_DESCRIPT(6) BIT(16) INITIAL(6,8,6,2,-2,1,8);                        00171900
                                                                                00172000
   /* MISCELLANEOUS GLOBAL DECLARES */                                          00172100
                                                                                00172200
DECLARE  LMOD CHARACTER;    /* LOAD MODULE NAME */                              00172300
DECLARE  TITLE CHARACTER;     /* TITLE (TYPE II OPTION) */                      00172400
DECLARE  SDF_NAME CHARACTER; /* NAME OF LAST SELECTED SDF */                    00172500
DECLARE  (GOT_BLK,GOT_VAR,GOT_COPIES,GOT_UNIT,GOT_LINK) BIT(16);                00172600
DECLARE  (GOT_ID) BIT(16);                                                      00172700
DECLARE  (GOT_PHASE) BIT(8);                                                    00172800
DECLARE  (RECORD#) FIXED;                                                       00172900
DECLARE  (GOT_RECORD,GOT_COPY_SIZE,GOT_ADDR,GOT_ADDR1,GOT_CELL_ADDR) FIXED;     00173000
DECLARE  GOT_NAME CHARACTER;                                                    00173100
DECLARE  MEM_TYPE CHARACTER;                                                    00173200
                                                                                00173300
COMMON OPTIONS_CODE FIXED; /* HALSTAT OPTIONS */                                00173400
COMMON (MAX_SEVERITY,#UNITS,#CSECTS) BIT(16);                                   00173500
                                                                                00173600
   /* DECLARES FOR MAIN HALSTAT DATA BASES */                                   00173700
                                                                                00173800
DECLARE (MAX_UNITS,MAX_CSECTS) FIXED;                                           00173900
DECLARE #COM_SYTSIZE LITERALLY '18';                                            00174000
                                                                                00174100
COMMON BASED   UNIT_NAMES     CHARACTER,                                        00174200
               SDF_NAMES      CHARACTER,                                        00174300
               SYMBOL_NAMES   CHARACTER;                                        00174400
                                                                                00174500
COMMON BASED   UNIT_SORT      BIT(16),                                          00174600
               UNIT_TYPE      BIT(8),                                           00174700
               #C$0           BIT(16),                                          00174800
               #D#P           BIT(16),                                          00174900
               #F#R           BIT(16),                                          00175000
               #T#Z           BIT(16),                                          00175100
               #E             BIT(16),                                          00175200
               #X             BIT(16),                                          00175300
               ALPHA_LINK     BIT(16),                                          00175400
               NEXT_LINK      BIT(16),                                          00175500
               MAP_BASE       FIXED,                                            00175600
               VAR_BASE       FIXED,                                            00175700
               TEXT_BASE      FIXED,                                            00175800
               TASK_TAB       BIT(16),                                          00175900
               STACK_TAB      BIT(16),                                          00176000
               PROC_TAB       BIT(16),                                          00176100
               UNIT_FLAGS     BIT(8),                                           00176200
               UNIT_REF_CNT1  BIT(16),                                          00176300
               UNIT_REF_CNT2  BIT(16);                                          00176400
                                                                                00176500
COMMON BASED   SELECTOR       BIT(16);                                          00176600
                                                                                00176700
DECLARE  COMMON_SYTSIZES(#COM_SYTSIZE) BIT(8)                                   00176800
               INITIAL(1,     /* UNIT_SORT  */                                  00176900
                       0,     /* UNIT_TYPE  */                                  00177000
                       1,     /* #C$0       */                                  00177100
                       1,     /* #D#P       */                                  00177200
                       1,     /* #F#R       */                                  00177300
                       1,     /* #T#Z       */                                  00177400
                       1,     /* #E         */                                  00177500
                       1,     /* #X         */                                  00177600
                       1,     /* ALPHA_LINK */                                  00177700
                       1,     /* NEXT_LINK  */                                  00177800
                       2,     /* MAP_BASE   */                                  00177900
                       2,     /* VAR_BASE   */                                  00178000
                       2,     /* TEXT_BASE  */                                  00178100
                       1,     /* TASK_TAB   */                                  00178200
                       1,     /* STACK_TAB  */                                  00178300
                       1,     /* PROC_TAB   */                                  00178400
                       0,     /* UNIT_FLAGS */                                  00178500
                       1,     /* UNIT_REF_CNT1 */                               00178600
                       1);    /* UNIT_REF_CNT2 */                               00178700
                                                                                00178800
BASED          CSECT_ADDR     FIXED,                                            00178900
               CSECT_LENGTH   FIXED,                                            00179000
               CSECT_ID       BIT(16),                                          00179100
               CSECT_ESDID    BIT(16),                                          00179200
               CSECT_SORT     BIT(16),                                          00179300
               CSECT_SORTX    BIT(16),                                          00179400
               CSECT_SORTY    BIT(16),                                          00179500
               CSECT_SORTZ    BIT(16),                                          00179600
               CSECT_STACK_REQ BIT(16),                                         00179700
               CSECT_CHAR     FIXED,                                            00179800
               CSECT_APTR1    FIXED,                                            00179900
               CSECT_APTR2    FIXED,                                            00180000
               CSECT_TEXT_PTR FIXED,                                            00180100
               CSECT_FLAGS BIT(8),                                              00180200
               CSECT_LINK     BIT(16);                                          00180300
                                                                                00180400
DECLARE #NON_COM_SYTSIZE LITERALLY '14';                                        00180500
                                                                                00180600
DECLARE NON_COMMON_SYTSIZES(#NON_COM_SYTSIZE) BIT(8)                            00180700
            INITIAL(2,       /* CSECT_ADDR */                                   00180800
                  2,       /* CSECT_LENGTH */                                   00180900
                  1,       /* CSECT_ID */                                       00181000
                  1,       /* CSECT_ESDID */                                    00181100
                  1,       /* CSECT_SORT */                                     00181200
                  1,       /* CSECT_SORTX */                                    00181300
                  1,       /* CSECT_SORTY */                                    00181400
                  1,       /* CSECT_SORTZ */                                    00181500
                  1,       /* CSECT_STACK_REQ */                                00181600
                  3,       /* CSECT_CHAR */                                     00181700
                  2,       /* CSECT_APTR1 */                                    00181800
                  2,       /* CSECT_APTR2 */                                    00181900
                  2,       /* CSECT_TEXT_PTR */                                 00182000
                  0,       /* CSECT_FLAGS */                                    00182100
                  1);      /* CSECT_LINK */                                     00182200
                                                                                00182300
   /* MISCELLANEOUS DECLARATIONS */                                             00182400
                                                                                00182500
DECLARE SPACE_1 LITERALLY 'CALL DO_SPACE',                                      00182600
        DSPACE LITERALLY 'OUTPUT(1) = DOUBLE',                                  00182700
        MAP_SPACE LITERALLY 'IF MAP_LEVEL = 4 THEN OUTPUT = X1',                00182800
        (BAIL_OUT,NO_CORE) LABEL,                                               00182900
        CLOCK(8) FIXED;                                                         00183000
                                                                                00183100
   /* DECLARATIONS FOR ASSORTED BUFFERS */                                      00183200
                                                                                00183300
BASED FILE1_BUFF FIXED;                                                         00183400
DECLARE (FILE1_BUFF_ADDR,AUX_BUFF_ADDR) FIXED;                                  00183500
DECLARE GSD_ALPH_PTR FIXED;                                                     00183600
                                                                                00183700
DECLARE RESERVE LITERALLY 'SAVE_NDX=VMEM_NDX;VMEM_PAD_DISP(SAVE_NDX)=VMEM_PAD_DI00183800
SP(SAVE_NDX)+1;';                                                               00183900
DECLARE RELEASE LITERALLY 'VMEM_PAD_DISP(SAVE_NDX)=VMEM_PAD_DISP(SAVE_NDX)-1;'  00184000
;                                                                               00184100
                                                                                00184200
   /*          $%VMEM2X          */                                             00184300
   /*          $%VMEM3X          */                                             00184400
   /*          $%VMEM4X          */                                             00184500
                                                                                00184600
                                                                                00184700
DO_SPACE:                                                                       00184800
   PROCEDURE;                                                                   00184900
      OUTPUT = X1;                                                              00185000
   END DO_SPACE;                                                                00185100
                                                                                00185200
   /*  SUBROUTINE TO FIND OCCURANCE OF ONE CHAR STRING IN ANOTHER.   */         00185300
CHAR_INDEX:                                                                     00185400
   PROCEDURE (STRING1,STRING2) BIT(16) ;                                        00185500
      DECLARE (STRING1,STRING2) CHARACTER, (L1,L2,I) FIXED;                     00185600
      L1 = LENGTH(STRING1);                                                     00185700
      L2 = LENGTH(STRING2);                                                     00185800
      IF L2>L1 THEN RETURN -1;                                                  00185900
      DO I = 0 TO L1-L2;                                                        00186000
         IF SUBSTR(STRING1,I,L2) = STRING2 THEN RETURN I;                       00186100
      END;                                                                      00186200
      RETURN -1;                                                                00186300
   END CHAR_INDEX;                                                              00186400
                                                                                00186500
   /* SUBROUTINE FOR PRINTING A LINE THAT MAY EXCEED THE PRINTER LINE WIDTH */  00186600
EMIT_OUTPUT:                                                                    00186700
   PROCEDURE (STRINGX) CHARACTER;                                               00186800
      DECLARE STRINGX CHARACTER;                                                00186900
      IF LENGTH(STRINGX) < 133 THEN OUTPUT = STRINGX;                           00187000
      ELSE DO;                                                                  00187100
         OUTPUT = SUBSTR(STRINGX,0,132);                                        00187200
         OUTPUT = SUBSTR(STRINGX,132);                                          00187300
      END;                                                                      00187400
   END EMIT_OUTPUT;                                                             00187500
                                                                                00187600
   /* SUBROUTINE FOR FORCING A CHARACTER STRING TO A SPECIFIED LENGTH */        00187700
PAD:                                                                            00187800
   PROCEDURE (STRINGX,MAX) CHARACTER;                                           00187900
      DECLARE (STRINGX) CHARACTER, (MAX,L) BIT(16);                             00188000
                                                                                00188100
      L = LENGTH(STRINGX);                                                      00188200
      IF L < MAX THEN STRINGX = STRINGX||SUBSTR(X72,0,MAX-L);                   00188300
      ELSE IF L > MAX THEN STRINGX = SUBSTR(STRINGX,0,MAX);                     00188400
      RETURN STRINGX;                                                           00188500
   END PAD;                                                                     00188600
                                                                                00188700
   /* SUBROUTINE TO PAD A CHARACTER STRING ON THE LEFT WITH BLANKS */           00188800
LEFT_PAD:                                                                       00188900
   PROCEDURE (STRINGX,WIDTH) CHARACTER;                                         00189000
      DECLARE STRINGX CHARACTER, (WIDTH,L) FIXED;                               00189100
      L = LENGTH(STRINGX);                                                      00189200
      IF L >= WIDTH THEN RETURN STRINGX;                                        00189300
      ELSE RETURN SUBSTR(X72,0,WIDTH-L)||STRINGX;                               00189400
   END LEFT_PAD;                                                                00189500
                                                                                00189600
KEEP:                                                                           00189700
   PROCEDURE (STRINGX) CHARACTER;                                               00189800
      DECLARE (STRINGX) CHARACTER;                                              00189900
                                                                                00190000
      STRINGX = X1 || STRINGX;                                                  00190100
      RETURN SUBSTR(STRINGX,1);                                                 00190200
   END KEEP;                                                                    00190300
                                                                                00190400
RTRIM:                                                                          00190500
   PROCEDURE (STR) CHARACTER;                                                   00190600
      DECLARE STR CHARACTER, I BIT(16);                                         00190700
      I = CHAR_INDEX(STR,X1);                                                   00190800
      IF I ~= -1 THEN RETURN SUBSTR(STR,0,I);                                   00190900
      ELSE RETURN STR;                                                          00191000
   END RTRIM;                                                                   00191100
                                                                                00191200
FRACTIONAL:                                                                     00191300
   PROCEDURE (NUM1,NUM2) CHARACTER;                                             00191400
      DECLARE (NUM1,NUM2) FIXED, (STRING1,STRING2) CHARACTER;                   00191500
      IF NUM2 = 0 THEN RETURN '  0.000';                                        00191600
      STRING1 = LPAD(((NUM1*1000)/NUM2),6);                                     00191700
      STRING2 = SUBSTR(STRING1,0,3)||PERIOD||SUBSTR(STRING1,3);                 00191800
      RETURN STRING2;                                                           00191900
   END FRACTIONAL;                                                              00192000
                                                                                00192100
PERCENT:                                                                        00192200
   PROCEDURE (NUM1,NUM2) CHARACTER;                                             00192300
      DECLARE (NUM,NUM1,NUM2,NUM3) FIXED, (STRING1,STRING2) CHARACTER;          00192400
      IF NUM2 = 0 THEN RETURN '  0.00%';                                        00192500
      NUM3 = (100*NUM1)/NUM2;                                                   00192600
      NUM = 100*NUM1 - NUM2*NUM3;                                               00192700
      NUM = (100*NUM)/NUM2;                                                     00192800
      NUM = NUM + 100*NUM3;                                                     00192900
      IF NUM < 100 THEN DO;                                                     00193000
         STRING1 = LPAD(NUM+100,3);                                             00193100
         STRING2 = '  0.'||SUBSTR(STRING1,1,2)||PCENT_SIGN;                     00193200
      END;                                                                      00193300
      ELSE DO;                                                                  00193400
         STRING1 = LPAD(NUM,5);                                                 00193500
         STRING2 = SUBSTR(STRING1,0,3)||PERIOD||SUBSTR(STRING1,3)||PCENT_SIGN;  00193600
      END;                                                                      00193700
      RETURN STRING2;                                                           00193800
   END PERCENT;                                                                 00193900
                                                                                00194000
   /* ROUTINE TO CONVERT SCALAR LIT TO INTEGER AND CHECK RANGE */               00194100
INTEGERIZABLE:                                                                  00194200
   PROCEDURE;                                                                   00194300
      DECLARE LIT_NEGMAX LABEL, FLT_NEGMAX FIXED INITIAL("C8800000");           00194400
      DECLARE NEGMAX FIXED INITIAL("80000000"), NEGLIT BIT(8);                  00194500
      DECLARE (TEMP,TEMP1) FIXED;                                               00194600
                                                                                00194700
      CALL INLINE("58", 1, 0, DW);                /* L  1,DW     */             00194800
      CALL INLINE("68", 0, 0, 1, 0);              /* LE 0,0(0,1) */             00194900
      IF DW = "FF000000" THEN DO;                                               00195000
NO_INTEGER: RETURN FALSE;                                                       00195100
      END;                                                                      00195200
      TEMP = ADDR(NO_INTEGER);                                                  00195300
      TEMP1 = ADDR(LIT_NEGMAX);                                                 00195400
      CALL INLINE("28", 2, 0);                    /* LDR 2,0     */             00195500
      CALL INLINE("20", 0, 0);                    /* LPDR 0,0    */             00195600
      CALL INLINE("2B", 4, 4);                    /* SDR 4,4     */             00195700
      CALL INLINE("78", 4, 0, FLT_NEGMAX);        /* LE 4,FLT_NEGMAX */         00195800
      CALL INLINE("58", 2, 0, TEMP1);             /* L 2,TEMP1   */             00195900
      CALL INLINE("29", 4, 2);                    /* CDR 4,2     */             00196000
      CALL INLINE("07", 8, 2);                    /* BCR 8,2     */             00196100
      CALL INLINE("58", 1, 0, ADDR_ROUNDER);      /* L 1,ADDR_ROUNDER */        00196200
      CALL INLINE("6A", 0, 0, 1, 0);              /* AD 0,0(0,1) */             00196300
      CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);  /* L 1,ADDR__LIMIT */         00196400
      CALL INLINE("58", 2, 0, TEMP);              /* L 2,TEMP    */             00196500
      CALL INLINE("69", 0, 0, 1, 0);              /* CD 0,0(0,1) */             00196600
      CALL INLINE("07", 2, 2);                    /* BCR 2,2     */             00196700
   LIT_NEGMAX:                                                                  00196800
      CALL INLINE("58", 1, 0, ADDR_FIXER);        /* L 1,ADDR_FIXER */          00196900
      CALL INLINE("6E", 0, 0, 1, 0);              /* AW 0,0(0,1) */             00197000
      CALL INLINE("58", 1, 0, DW);                /* L 1,DW      */             00197100
      CALL INLINE("60", 0, 0, 1, 8);              /* STD 0,8(0,1) */            00197200
      CALL INLINE("70", 2, 0, 1, 8);              /* STE 2,8(0,1) */            00197300
      NEGLIT = SHR(DW(2), 31);                                                  00197400
      IF NEGLIT THEN DO;                                                        00197500
         IF DW(3) ~= NEGMAX THEN DW(3) = -DW(3);                                00197600
      END;                                                                      00197700
      RETURN TRUE;                                                              00197800
   END INTEGERIZABLE;                                                           00197900
                                                                                00198000
KOREWORD:                                                                       00198100
   PROCEDURE (MEM_ADDR) FIXED;                                                  00198200
      DECLARE (MEM_ADDR,TMP) FIXED;                                             00198300
      BASED NODE_B BIT(8);                                                      00198400
      COREWORD(ADDR(NODE_B)) = ADDR(TMP);                                       00198500
      NODE_B(0) = COREBYTE(MEM_ADDR);                                           00198600
      NODE_B(1) = COREBYTE(MEM_ADDR+1);                                         00198700
      NODE_B(2) = COREBYTE(MEM_ADDR+2);                                         00198800
      NODE_B(3) = COREBYTE(MEM_ADDR+3);                                         00198900
      RETURN TMP;                                                               00199000
   END KOREWORD;                                                                00199100
                                                                                00199200
KOREHALF:                                                                       00199300
   PROCEDURE (MEM_ADDR) BIT(16);                                                00199400
      DECLARE (MEM_ADDR) FIXED, TMP_16 BIT(16);                                 00199500
      BASED NODE_B BIT(8);                                                      00199600
      COREWORD(ADDR(NODE_B)) = ADDR(TMP_16);                                    00199700
      NODE_B(0) = COREBYTE(MEM_ADDR);                                           00199800
      NODE_B(1) = COREBYTE(MEM_ADDR+1);                                         00199900
      RETURN TMP_16;                                                            00200000
   END KOREHALF;                                                                00200100
                                                                                00200200
CHARTIME:                                                                       00200300
   PROCEDURE (T) CHARACTER;                                                     00200400
      DECLARE C CHARACTER, T FIXED;                                             00200500
      C=T/360000||COLON||T MOD 360000/6000||COLON||                             00200600
         T MOD 6000/100||PERIOD;                                                00200700
      T=T MOD 100;                                                              00200800
      IF T < 10 THEN C=C||ZEROCHAR;                                             00200900
      RETURN C||T;                                                              00201000
   END CHARTIME;                                                                00201100
                                                                                00201200
PRINTTIME:                                                                      00201300
   PROCEDURE (MESSAGE,T);                                                       00201400
      DECLARE (MESSAGE,C) CHARACTER, T FIXED;                                   00201500
      C = CHARTIME(T);                                                          00201600
      OUTPUT = MESSAGE||C;                                                      00201700
   END PRINTTIME;                                                               00201800
                                                                                00201900
PRINT_TIME:                                                                     00202000
   PROCEDURE (MESSAGE,T);                                                       00202100
      DECLARE (MESSAGE,C) CHARACTER, T FIXED;                                   00202200
      C = CHAR_TIME(T);                                                         00202300
      OUTPUT = MESSAGE || C;                                                    00202400
   END PRINT_TIME;                                                              00202500
                                                                                00202600
PRINT_DATE_AND_TIME:                                                            00202700
   PROCEDURE (MESSAGE,D,T);                                                     00202800
      DECLARE (MESSAGE,C) CHARACTER, (D,T) FIXED;                               00202900
      C = CHAR_DATE(D);                                                         00203000
      CALL PRINT_TIME(MESSAGE||C||'. CLOCK TIME = ',T);                         00203100
   END PRINT_DATE_AND_TIME;                                                     00203200
                                                                                00203300
ERROR:                                                                          00203400
   PROCEDURE (STRING1,NUM);                                                     00203500
      DECLARE STRING1 CHARACTER, NUM BIT(16);                                   00203600
      TOTAL_ERRORS = TOTAL_ERRORS + 1;                                          00203700
      IF NUM > 0 THEN SEVERE_ERRORS = SEVERE_ERRORS + 1;                        00203800
      SPACE_1;                                                                  00203900
      CALL EMIT_OUTPUT('*** ERROR #'||TOTAL_ERRORS||' SEVERITY '||NUM||         00204000
         BLK_MINUS_BLK||STRING1||ASTS);                                         00204100
      IF LAST_ERROR ~= 0 THEN                                                   00204200
         OUTPUT = '*** LAST ERROR WAS AT SYMBOL '||LAST_ERROR||ASTS;            00204300
      LAST_ERROR = GOT_RECORD;                                                  00204400
      IF MAX_SEVERITY < NUM THEN MAX_SEVERITY = NUM;                            00204500
   END ERROR;                                                                   00204600
                                                                                00204700
   /* ROUTINE TO 'SELECT' AN SDF FOR PROCESSING */                              00204800
                                                                                00204900
SDF_SELECT:                                                                     00205000
   PROCEDURE (UNIT);                                                            00205100
      DECLARE (UNIT,TEMP) BIT(16);                                              00205200
      BASED   NODE_H BIT(16), NODE_F FIXED;                                     00205300
                                                                                00205400
      SELECTED_UNIT = UNIT;                                                     00205500
      SDF_NAME = SDF_NAMES(UNIT);                                               00205600
      CALL MOVE(8,SDF_NAME,SDFNAM);                                             00205700
      CALL MONITOR(22,"80000007");                                              00205800
      COREWORD(ADDR(NODE_H)) = ADDRESS;                                         00205900
      #EXTERNALS = NODE_H(7);                                                   00206000
      #PROCS = NODE_H(8);                                                       00206100
      #SYMBOLS = NODE_H(9);                                                     00206200
      FIRST_STMT = NODE_H(26);                                                  00206300
      LAST_STMT = NODE_H(27);                                                   00206400
      KEY_BLOCK = NODE_H(44);                                                   00206500
      KEY_SYMB = NODE_H(14);                                                    00206600
      TEMP = NODE_H(0);                                                         00206700
      SRN_FLAG,ADDR_FLAG,COMPOOL_FLAG,FCDATA_FLAG = FALSE;                      00206800
      IF (TEMP & "8000") ~= 0 THEN SRN_FLAG = TRUE;                             00206900
      IF (TEMP & "4000") ~= 0 THEN ADDR_FLAG = TRUE;                            00207000
      IF (TEMP & "2000") ~= 0 THEN COMPOOL_FLAG = TRUE;                         00207100
      IF (TEMP & "0004") ~= 0 THEN                                              00207200
         FCDATA_FLAG = TRUE;                                                    00207300
   END SDF_SELECT;                                                              00207400
                                                                                00207500
   /* ROUTINE TO 'LOCATE' EXTERNAL SDF DATA BY POINTER */                       00207600
                                                                                00207700
SDF_PTR_LOCATE:                                                                 00207800
   PROCEDURE (PTR,FLAGS);                                                       00207900
      DECLARE (PTR,ARG) FIXED,                                                  00208000
              FLAGS BIT(8);                                                     00208100
      PNTR = PTR;                                                               00208200
      ARG = SHL(FLAGS,28) + 5;                                                  00208300
      CALL MONITOR(22,ARG);                                                     00208400
   END SDF_PTR_LOCATE;                                                          00208500
                                                                                00208600
   /* ROUTINE TO EXTRACT A BLOCK NAME FROM A BLOCK DATA CELL */                 00208700
                                                                                00208800
BLOCK_NAME:                                                                     00208900
   PROCEDURE (BLK#) CHARACTER;                                                  00209000
      DECLARE BLK# BIT(16);                                                     00209100
      BLKNO = BLK#;                                                             00209200
      CALL MONITOR(22,8);                                                       00209300
      RETURN STRING(BLKNAM + SHL(BLKNLEN-1,24));                                00209400
   END BLOCK_NAME;                                                              00209500
                                                                                00209600
   /* ROUTINE TO EXTRACT A SYMBOL NAME FROM A SYMBOL NODE AND DATA CELL */      00209700
                                                                                00209800
SYMBOL_NAME:                                                                    00209900
   PROCEDURE (SYMB#) CHARACTER;                                                 00210000
      DECLARE SYMB# BIT(16);                                                    00210100
                                                                                00210200
      SYMBNO = SYMB#;                                                           00210300
      CALL MONITOR(22,9);                                                       00210400
      RETURN STRING(SYMBNAM + SHL(SYMBNLEN-1,24));                              00210500
   END SYMBOL_NAME;                                                             00210600
                                                                                00210700
GET_UNIT_NDX_BY_NAME:                                                           00210800
   PROCEDURE (NAME) FIXED;                                                      00210900
      DECLARE (LO_LIM,HI_LIM,MID) FIXED, (NAME,NAMEX) CHARACTER;                00211000
      LO_LIM = 1;                                                               00211100
      HI_LIM = #UNITS;                                                          00211200
      DO WHILE LO_LIM <= HI_LIM;                                                00211300
         MID = SHR(HI_LIM+LO_LIM,1);                                            00211400
         NAMEX = UNIT_NAMES(UNIT_SORT(MID));                                    00211500
         IF NAME = NAMEX THEN GO TO DONE;                                       00211600
         ELSE IF STRING_GT(NAMEX,NAME) THEN HI_LIM = MID - 1;                   00211700
         ELSE LO_LIM = MID + 1;                                                 00211800
      END;                                                                      00211900
      RETURN 0;                                                                 00212000
DONE:                                                                           00212100
      RETURN UNIT_SORT(MID);                                                    00212200
   END GET_UNIT_NDX_BY_NAME;                                                    00212300
                                                                                00212400
GET_SRN:                                                                        00212500
   PROCEDURE (ITEM) CHARACTER;                                                  00212600
      DECLARE (STRINGX,SRN_STRING) CHARACTER, (ITEM,J) BIT(16);                 00212700
      DECLARE SFLAG BIT(8);                                                     00212800
      BASED NODE_H BIT(16), NODE_B BIT(8);                                      00212900
                                                                                00213000
      IF (GFORMAT > 0)&(SRN_FLAG = TRUE) THEN DO;                               00213100
         STMTNO = ITEM&"1FFF";                                                  00213200
         CALL MONITOR(22,17);                                                   00213300
         IF CRETURN = 0 THEN DO;                                                00213400
            PNTR = COREWORD(ADDRESS + 8);                                       00213500
            STRINGX = LPAREN||STRING(ADDRESS+"05000000");                       00213600
            COREWORD(ADDR(NODE_H)) = ADDRESS;                                   00213700
            IF NODE_H(3) ~= 0 THEN DO;                                          00213800
               STRINGX = STRINGX||PLUS||NODE_H(3);                              00213900
               IF (VERSION >= 25)&(PNTR ~= 0) THEN DO;                          00214000
                  CALL MONITOR(22,5);                                           00214100
                  COREWORD(ADDR(NODE_B)) = ADDRESS;                             00214200
                  SFLAG = NODE_B(2);                                            00214300
                  IF (SFLAG & "80") ~= 0 THEN DO;                               00214400
                     J = 6 + SHL(NODE_B(4)+NODE_B(5),1);                        00214500
                     IF ADDR_FLAG THEN J = J + 6;                               00214600
                     SRN_STRING = STRING("05000000" + ADDRESS + J);             00214700
                     IF SRN_STRING ~= ZERO6 THEN                                00214800
                        STRINGX = STRINGX||SLASH||SRN_STRING;                   00214900
                  END;                                                          00215000
               END;                                                             00215100
            END;                                                                00215200
            RETURN STRINGX||')  ';                                              00215300
         END;                                                                   00215400
      END;                                                                      00215500
      RETURN X2;                                                                00215600
   END GET_SRN;                                                                 00215700
                                                                                00215800
GET_CARD: PROCEDURE;                                                            00215900
   DECLARE I BIT(16),                                                           00216000
           TPAD CHARACTER INITIAL('   ''  ');                                   00216100
   CP = 0;                                                                      00216200
   DO WHILE TRUE;                                                               00216300
      IF EOFLAG THEN DO;                                                        00216400
         TEXT = TPAD;                                                           00216500
         BYTE(TEXT,1) = "FF";                                                   00216600
         BYTE(TEXT,5) = "FF";                                                   00216700
         TEXT_LIMIT = LENGTH(TPAD) - 1;                                         00216800
         RETURN;                                                                00216900
      END;                                                                      00217000
      TEXT = INPUT;                                                             00217100
      IF LENGTH(TEXT)>0 THEN DO;                                                00217200
         CARD# = CARD# + 1;                                                     00217300
         TEXT_LIMIT = LENGTH(TEXT) - 9;                                         00217400
         OUTPUT = LPAD(CARD#,8)||' | '||SUBSTR(TEXT,0,TEXT_LIMIT+1)||'| '||     00217500
                                 SUBSTR(TEXT,TEXT_LIMIT+1);                     00217600
         OUTPUT = X1;                                                           00217700
         TEXT = SUBSTR(TEXT,0,TEXT_LIMIT+1);                                    00217800
         RETURN;                                                                00217900
      END;                                                                      00218000
      EOFLAG = TRUE;                                                            00218100
   END;                                                                         00218200
 END GET_CARD;                                                                  00218300
                                                                                00218400
CHAR:                                                                           00218500
   PROCEDURE;                                                                   00218600
      /* USED FOR STRINGS TO AVOID CARD BOUNDARY PROBLEMS */                    00218700
      CP = CP + 1;                                                              00218800
      IF CP <= TEXT_LIMIT THEN RETURN;                                          00218900
      CALL GET_CARD;                                                            00219000
   END CHAR;                                                                    00219100
SCAN:                                                                           00219200
   PROCEDURE;                                                                   00219300
      DECLARE (S1, S2, S3) FIXED;                                               00219400
      DECLARE I BIT(16);                                                        00219500
      DECLARE LSTRNGM CHARACTER INITIAL('STRING TOO LONG');                     00219600
      DECLARE NEGBIT FIXED;                                                     00219700
      IF LOOK_AHEAD THEN RETURN;                                                00219800
      LOOK_AHEAD = TRUE;                                                        00219900
      BCD = '';   VALUE = 0;                                                    00220000
   SCAN1:                                                                       00220100
      DO WHILE TRUE;                                                            00220200
         IF CP > TEXT_LIMIT THEN CALL GET_CARD;                                 00220300
         ELSE                                                                   00220400
            DO; /* DISCARD LAST SCANNED VALUE */                                00220500
               TEXT_LIMIT = TEXT_LIMIT - CP;                                    00220600
               TEXT = SUBSTR(TEXT, CP);                                         00220700
               CP = 0;                                                          00220800
            END;                                                                00220900
         /*  BRANCH ON NEXT CHARACTER IN TEXT                  */               00221000
         DO CASE CHARTYPE(BYTE(TEXT));                                          00221100
                                                                                00221200
            /*  CASE 0  */                                                      00221300
                                                                                00221400
            /* ILLEGAL CHARACTERS FALL HERE  */                                 00221500
            DO;                                                                 00221600
               IF BYTE(TEXT) = BYTE(MINUS) THEN IF CONTEXT = TIMING THEN DO;    00221700
                  CP = 1;                                                       00221800
                  NEGBIT = "80000000";                                          00221900
                  GO TO NUM_ENTRY;                                              00222000
               END;                                                             00222100
               CALL ERROR ('ILLEGAL CHARACTER: ' || SUBSTR(TEXT, 0, 1),0);      00222200
            END;                                                                00222300
                                                                                00222400
            /*  CASE 1  */                                                      00222500
                                                                                00222600
            /*  BLANK  */                                                       00222700
            DO;                                                                 00222800
               CP = 1;                                                          00222900
               DO WHILE BYTE(TEXT, CP) = BYTE(X1) & CP <=  TEXT_LIMIT;          00223000
                  CP = CP + 1;                                                  00223100
               END;                                                             00223200
               CP = CP - 1;                                                     00223300
            END;                                                                00223400
                                                                                00223500
            /*  CASE 2  */                                                      00223600
                                                                                00223700
            /*  STRING QUOTE ('):  CHARACTER STRING  */                         00223800
            DO WHILE TRUE;                                                      00223900
               TOKEN = CHARACTER_STRING;                                        00224000
               CALL CHAR;                                                       00224100
               S1 = CP;                                                         00224200
               DO WHILE BYTE(TEXT, CP) ~=  BYTE(QUOTE);                         00224300
                  CP = CP + 1;                                                  00224400
                  IF CP > TEXT_LIMIT THEN                                       00224500
                     DO; /* STRING BROKEN ACROSS CARD BOUNDARY */               00224600
                        IF LENGTH(BCD) + CP > 257 THEN                          00224700
                           DO;                                                  00224800
                              CALL ERROR(LSTRNGM  ,1);                          00224900
                              GO TO SET_CONTEXT;                                00225000
                           END;                                                 00225100
                        BCD = BCD || SUBSTR(TEXT, S1, CP-S1);                   00225200
                        CALL GET_CARD;                                          00225300
                        S1 = 0;                                                 00225400
                     END;                                                       00225500
               END;                                                             00225600
               IF LENGTH(BCD) + CP > 257 THEN                                   00225700
                  DO;                                                           00225800
                     CALL ERROR(LSTRNGM,1);                                     00225900
                     GO TO SET_CONTEXT;                                         00226000
                  END;                                                          00226100
               IF CP > S1 THEN                                                  00226200
                  BCD = BCD || SUBSTR(TEXT,S1,CP-S1);                           00226300
               CALL CHAR;                                                       00226400
               IF BYTE(TEXT, CP) ~ =  BYTE(QUOTE) THEN                          00226500
                  GO TO SET_CONTEXT;                                            00226600
               IF LENGTH(BCD) > 255 THEN                                        00226700
                  DO;                                                           00226800
                     CALL ERROR(LSTRNGM,1);                                     00226900
                     GO TO SET_CONTEXT;                                         00227000
                  END;                                                          00227100
               BCD = BCD || QUOTE;                                              00227200
               TEXT_LIMIT = TEXT_LIMIT - CP;                                    00227300
               TEXT = SUBSTR(TEXT,CP);                                          00227400
               CP = 0;   /* PREPARE TO RESUME SCANNING STRING */                00227500
            END;                                                                00227600
                                                                                00227700
            /*  CASE 3  */                                                      00227800
                                                                                00227900
            DO WHILE TRUE;  /* A LETTER:  IDENTIFIERS AND RESERVED WORDS */     00228000
               IF CONTEXT = SRN THEN GO TO SEQ_TOKEN;                           00228100
               IF CONTEXT = HEXNUM THEN GO TO NUM_ENTRY;                        00228200
GEN_CHAR_STRING:                                                                00228300
               DO CP = CP + 1 TO TEXT_LIMIT;                                    00228400
                  IF NOT_LETTER_OR_DIGIT(BYTE(TEXT, CP)) THEN                   00228500
                     DO;  /* END OF IDENTIFIER  */                              00228600
                        IF CP > 0 THEN BCD = BCD || SUBSTR(TEXT, 0, CP);        00228700
                        S1 = LENGTH(BCD);                                       00228800
                        IF CONTEXT = NULL THEN                                  00228900
                        IF S1 > 1 THEN IF S1 <=  RESERVED_LIMIT THEN            00229000
                           /* CHECK FOR RESERVED WORDS */                       00229100
                           DO I = 1 TO TERMINAL#;                               00229200
                              IF BCD = VOCAB(I) THEN                            00229300
                                 DO;                                            00229400
                                    TOKEN = I;                                  00229500
                                    GO TO SET_CONTEXT;                          00229600
                                 END;                                           00229700
                           END;                                                 00229800
                        /*  RESERVED WORDS GONE - MUST BE A LABEL */            00229900
                         IF LENGTH(BCD) > 32 THEN                               00230000
                            DO;                                                 00230100
                               CALL ERROR('NAME TOO LONG: ' || BCD, 1);         00230200
                               BCD = SUBSTR(BCD, 0, 32);                        00230300
                            END;                                                00230400
                        TOKEN = LABELNAME;                                      00230500
                        GO TO SET_CONTEXT;                                      00230600
                     END;                                                       00230700
               END;                                                             00230800
               /*  END OF CARD  */                                              00230900
               BCD = BCD || TEXT;                                               00231000
               CALL GET_CARD;                                                   00231100
               CP = -1;                                                         00231200
            END;                                                                00231300
                                                                                00231400
            /*  CASE 4  */                                                      00231500
                                                                                00231600
            DO;      /*  DIGIT:  A NUMBER  */                                   00231700
               IF CONTEXT = SRN THEN GO TO SEQ_TOKEN;                           00231800
               IF CONTEXT = GENCHAR THEN GO TO GEN_CHAR_STRING;                 00231900
   NUM_ENTRY:   S2,S3 = 0;                                                      00232000
                IF CONTEXT = TIMING THEN DO;                                    00232100
                   TOKEN = SCALAR;                                              00232200
                   DO WHILE TRUE;                                               00232300
                      DO CP = CP TO TEXT_LIMIT;                                 00232400
                         S1 = BYTE(TEXT,CP);                                    00232500
                         IF S1 = BYTE(PERIOD) THEN S2 = S2 + 1;                 00232600
                         ELSE IF S1 = BYTE(ECHAR) THEN DO;                      00232700
                            IF S2 < 2 THEN S2 = 1;                              00232800
                            IF S3 = 0 THEN S3 = 1;                              00232900
                            ELSE S2 = 2;                                        00233000
                         END;                                                   00233100
                         ELSE IF S1 = BYTE(PLUS) | S1 = BYTE(MINUS) THEN DO;    00233200
                            IF S3 = 1 THEN S3 = 3;                              00233300
                            ELSE S2 = 2;                                        00233400
                         END;                                                   00233500
                         ELSE IF (S1 < "F0")|(S1 > "F9") THEN DO;               00233600
                            IF S2 > 1 THEN S3 = 1;                              00233700
                            IF CP > 0 THEN BCD = BCD || SUBSTR(TEXT,0,CP);      00233800
                            IF ~S3 THEN S3 = MONITOR(10,                        00233900
                                  SUBSTR(BCD,SHR(NEGBIT,31)));                  00234000
                            DW = DW | NEGBIT;                                   00234100
                            NEGBIT = 0;                                         00234200
                            GO TO NUM_DONE;                                     00234300
                         END;                                                   00234400
                         ELSE IF S3 THEN S3 = S3 - 1;                           00234500
                      END;                                                      00234600
                      BCD = BCD || TEXT;                                        00234700
                      CALL GET_CARD;                                            00234800
                   END;                                                         00234900
                END;                                                            00235000
                ELSE IF CONTEXT ~= HEXNUM THEN DO;                              00235100
                   TOKEN = NUMBER;                                              00235200
                   DO WHILE TRUE;                                               00235300
                      DO CP = CP TO TEXT_LIMIT;                                 00235400
                         S1 = BYTE(TEXT,CP);                                    00235500
                         IF (S1 < "F0")|(S1>"F9") THEN DO;                      00235600
                            S3 = S2 > 9;                                        00235700
                            IF CP > 0 THEN BCD = BCD || SUBSTR(TEXT,0,CP);      00235800
              NUM_DONE:     IF S3 THEN CALL ERROR('ILLEGAL NUMBER: '||BCD,1);   00235900
                            GO TO SET_CONTEXT;                                  00236000
                         END;                                                   00236100
                         S2 = S2 + 1;                                           00236200
                         IF S2 < 10 THEN VALUE = 10*VALUE+S1-"F0";              00236300
                      END;                                                      00236400
                      BCD = BCD || TEXT;                                        00236500
                      CALL GET_CARD;                                            00236600
                   END;                                                         00236700
                END;                                                            00236800
               ELSE DO;   /* HEXADECIMAL (OR OCTAL) NUMBER */                   00236900
                  TOKEN = HEXADECIMAL;                                          00237000
                  DO WHILE TRUE;                                                00237100
                     DO CP = CP TO TEXT_LIMIT;                                  00237200
                        S1 = BYTE(TEXT,CP);                                     00237300
                        IF FALSE THEN DO;                                       00237400
                           IF (S1>="F0")&(S1<="F7") THEN DO;                    00237500
                              S2 = S2 + 1;                                      00237600
                              IF S2 < 9 THEN VALUE = 8*VALUE+S1-"F0";           00237700
                              ELSE GO TO BAD_HEX;                               00237800
                           END;                                                 00237900
                           ELSE GO TO BAD_HEX;                                  00238000
                        END;                                                    00238100
                        ELSE DO;                                                00238200
                           IF (S1 >= "F0")&(S1 <= "F9") THEN DO;                00238300
                              S2 = S2 + 1;                                      00238400
                              IF S2 < 9 THEN VALUE = 16*VALUE+S1-"F0";          00238500
                              ELSE GO TO BAD_HEX;                               00238600
                           END;                                                 00238700
                           ELSE IF (S1 >= "C1")&(S1 <= "C6") THEN DO;           00238800
                              S2 = S2 + 1;                                      00238900
                              IF S2 < 9 THEN VALUE = 16*VALUE+10+S1-"C1";       00239000
                              ELSE GO TO BAD_HEX;                               00239100
                           END;                                                 00239200
                           ELSE DO;                                             00239300
BAD_HEX:                      S3 = S2 > 8;                                      00239400
                              IF CP > 0 THEN BCD = BCD || SUBSTR(TEXT,0,CP);    00239500
                              GO TO NUM_DONE;                                   00239600
                           END;                                                 00239700
                        END;                                                    00239800
                     END;                                                       00239900
                     BCD = BCD || TEXT;                                         00240000
                     CALL GET_CARD;                                             00240100
                  END;                                                          00240200
               END;                                                             00240300
            END;                                                                00240400
                                                                                00240500
            /*  CASE 5  */                                                      00240600
            DO;      /*  SPECIAL CHARACTERS  */                                 00240700
               TOKEN = 0;                                                       00240800
               CP = 1;                                                          00240900
               BCD = SUBSTR(TEXT,0,1);                                          00241000
               DO WHILE TRUE;                                                   00241100
                  TOKEN = TOKEN + 1;                                            00241200
                  IF BYTE(VOCAB(TOKEN)) = BYTE(BCD) THEN GO TO SET_CONTEXT;     00241300
               END;                                                             00241400
            END;                                                                00241500
                                                                                00241600
            /*  CASE 6  */                                                      00241700
            DO;  /* END OF FILE MARK */                                         00241800
               TOKEN = ENDFILE;                                                 00241900
               CP = 1;                                                          00242000
               BCD = '/*';                                                      00242100
               GO TO SET_CONTEXT;                                               00242200
            END;                                                                00242300
                                                                                00242400
            /*  IMAGINARY CASE 7 - FOR SEQUENCE NUMBER */                       00242500
        SEQ_TOKEN:                                                              00242600
            DO WHILE TRUE;                                                      00242700
               DO CP = CP TO TEXT_LIMIT;                                        00242800
                IF NOT_LETTER_OR_DIGIT(BYTE(TEXT,CP)) THEN DO;                  00242900
                  /* END OF TOKEN  */                                           00243000
                  IF CP > 0 THEN BCD = BCD || SUBSTR(TEXT,0,CP);                00243100
                  S1 = LENGTH(BCD);                                             00243200
                  IF S1 ~= 6 THEN DO;                                           00243300
                     CALL ERROR('SRN IS NOT 6 CHARACTERS LONG',0);              00243400
                     IF S1 > 6 THEN BCD = SUBSTR(BCD,0,6);                      00243500
                     ELSE BCD = SUBSTR(ZERO6,S1) || BCD;                        00243600
                  END;                                                          00243700
                  TOKEN = SEQUENCE;                                             00243800
                  GO TO SET_CONTEXT;                                            00243900
                END;                                                            00244000
               END;                                                             00244100
               BCD = BCD || TEXT;                                               00244200
               CALL GET_CARD;                                                   00244300
               CP = 0;                                                          00244400
            END;                                                                00244500
                                                                                00244600
         END;     /* OF CASE ON CHARTYPE  */                                    00244700
         CP = CP + 1;  /* ADVANCE SCANNER AND RESUME SEARCH FOR TOKEN  */       00244800
      END;                                                                      00244900
   SET_CONTEXT:  CONTEXT = CONTEXT(TOKEN);                                      00245000
   IF TOGGLE(2) THEN OUTPUT = '****** SCANNER RETURNS '||BCD||                  00245100
        BLK_EQUALS_BLK||TOKEN||' IN CONTEXT '||CONTEXT;                         00245200
   END SCAN;                                                                    00245300
                                                                                00245400
RESET:                                                                          00245500
   PROCEDURE;                                                                   00245600
      #XUNITS,#XPHASES = 0;                                                     00245700
      XFROM = 0;                                                                00245800
      XTO = "003FFFFF";                                                         00245900
      MAP_CMD = 0;                                                              00246000
      CSECT_BOOL,CSECT_CAT = 0;                                                 00246100
      XLEVEL,XFORMAT = -1;                                                      00246200
   END RESET;                                                                   00246300
                                                                                00246400
SYNTHESIZE: PROCEDURE(PROD#);                                                   00246500
   DECLARE T1 FIXED;                                                            00246600
   DECLARE (C1,S1,CSECT_NAME) CHARACTER;                                        00246700
   DECLARE FIRST_PROCESS BIT(1) INITIAL(1);                                     00246800
   DECLARE SIGNAL BIT(1);                                                       00246900
   DECLARE PROD# BIT(16);                                                       00247000
   DECLARE (LEN,J,K,L,FUNC#) BIT(16);                                           00247100
   DECLARE OUT_OF_RANGE CHARACTER INITIAL(' OUT OF RANGE -- REQUEST IGNORED'),  00247200
           ITEM_NOT_FOUND CHARACTER INITIAL(' NOT FOUND -- REQUEST IGNORED');   00247205
   IF TOGGLE(1) THEN OUTPUT='******* ENTERING PRODUCTION '||PROD#||             00247300
             ' : MP = '||MP;                                                    00247400
   DO CASE PROD#;                                                               00247500
   ;                                                                            00247600
         /*      1   <COMPILATION> ::= <COMMAND LIST> _|_                     */00247700
      ;                                                                         00247800
                                                                                00247900
         /*      2   <COMMAND LIST> ::=                                       */00248000
      ;                                                                         00248100
         /*      3                    | <COMMAND LIST> <COMMAND>              */00248200
      DO;                                                                       00248300
         CALL RESET;                                                            00248400
         SUCCESS = TRUE;                                                        00248500
      END;                                                                      00248600
                                                                                00248700
         /*      4   <COMMAND> ::= <DEFINE CLAUSE> ;                          */00248800
      ;                                                                         00248900
         /*      5               | <COMMAND CLAUSE> ;                         */00249000
      ;                                                                         00249100
                                                                                00249200
         /*      6   <DEFINE CLAUSE> ::= DEFINE FUNCTION <LABEL> AS           */00249300
         /*      6                       <UNIT SPEC>                          */00249400
      IF SUCCESS THEN DO;                                                       00249500
         IF #FUNCS < MAX_FUNCS THEN DO;                                         00249600
            IF #XUNITS + 1 + #TPHASES < MAX_TPHASES THEN DO;                    00249700
               TPHASES(#TPHASES + 1) = #XUNITS;                                 00249800
               DO J = 1 TO #XUNITS;                                             00249900
                  TPHASES(#TPHASES + J + 1) = XUNITS(J);                        00250000
               END;                                                             00250100
               #FUNCS = #FUNCS + 1;                                             00250200
               FUNC_NAME(#FUNCS) = BCD(MP + 2);                                 00250300
               FUNC_UNIT_PTR(#FUNCS) = #TPHASES + 1;                            00250400
               #TPHASES = #TPHASES + #XUNITS + 1;                               00250500
               #XUNITS = 0;                                                     00250600
            END;                                                                00250700
         END;                                                                   00250800
      END;                                                                      00250900
         /*      7                     | DEFINE CONFIGURATION <LABEL> AS      */00251000
         /*      7                       <PHASE SPEC>                         */00251100
      IF SUCCESS THEN DO;                                                       00251200
         IF #CONFIGS < MAX_CONFIGS THEN DO;                                     00251300
            IF #XPHASES + 1 + #TPHASES < MAX_TPHASES THEN DO;                   00251400
               TPHASES(#TPHASES+1) = #XPHASES;                                  00251500
               DO J = 1 TO #XPHASES;                                            00251600
                  TPHASES(#TPHASES + J + 1) = XPHASES(J);                       00251700
               END;                                                             00251800
               #CONFIGS = #CONFIGS + 1;                                         00251900
               CONFIG_NAME(#CONFIGS) = BCD(MP + 2);                             00252000
               CONFIG_PHASE_PTR(#CONFIGS) = #TPHASES + 1;                       00252100
               #TPHASES = #TPHASES + #XPHASES + 1;                              00252200
               #XPHASES = 0;                                                    00252300
            END;                                                                00252400
         END;                                                                   00252500
      END;                                                                      00252600
                                                                                00252700
         /*      8                     | DEFINE <CSECT SPEC> AS <TYPE SPEC>   */00252800
         /*      8                       <STATUS SPEC>                        */00252900
      IF SUCCESS THEN DO;                                                       00253000
         DO J = 1 TO #XUNITS;                                                   00253100
            CSECT_FLAGS(XUNITS(J)) = CSECT_FLAGS(XUNITS(J))|CSECT_BOOL;         00253200
            IF CSECT_CAT > 0 THEN COREBYTE(ADDR(CSECT_ADDR(XUNITS(J)))) =       00253300
               CSECT_CAT + 16;                                                  00253400
         END;                                                                   00253500
         #XUNITS = 0;                                                           00253600
      END;                                                                      00253700
         /*      9   <UNIT SPEC> ::= UNIT <UNIT LIST>                         */00253800
      ;                                                                         00253900
         /*     10                 | UNITS <UNIT LIST>                        */00254000
      ;                                                                         00254100
                                                                                00254200
         /*     11   <UNIT LIST> ::= <LABEL>                                  */00254300
COMMON_UNITS:                                                                   00254400
      DO;                                                                       00254500
         C1 = BCD(SP);                                                          00254600
         LEN = LENGTH(C1);                                                      00254700
         IF (BYTE(C1)=BYTE(SLASH))&(BYTE(C1,LEN-1)=BYTE(SLASH)) THEN DO;        00254800
            C1 = SUBSTR(C1,1,LEN-2);                                            00254900
            DO J = 1 TO #UNITS;                                                 00255000
               IF C1 = SUBSTR(UNIT_NAMES(J),0,LEN-2) THEN DO;                   00255100
                  #XUNITS = #XUNITS + 1;                                        00255200
                  IF #XUNITS <= MAX_UNITS THEN XUNITS(#XUNITS) = J;             00255300
               END;                                                             00255400
            END;                                                                00255500
         END;                                                                   00255600
         ELSE DO;                                                               00255700
            J = GET_UNIT_NDX_BY_NAME(C1);                                       00255800
            IF J = 0 THEN DO;                                                   00255900
               C1 = 'UNIT '||C1||ITEM_NOT_FOUND;                                00256000
               CALL ERROR(C1,0);                                                00256100
            END;                                                                00256200
            ELSE DO;                                                            00256300
               #XUNITS = #XUNITS + 1;                                           00256400
               IF #XUNITS <= MAX_XUNITS THEN XUNITS(#XUNITS) = J;               00256500
            END;                                                                00256600
         END;                                                                   00256700
      END;                                                                      00256800
         /*     12                 | <UNIT LIST> , <LABEL>                    */00256900
      GO TO COMMON_UNITS;                                                       00257000
                                                                                00257100
         /*     13   <PHASE SPEC> ::= PHASE <PHASE LIST>                      */00257200
      ;                                                                         00257300
         /*     14                  | PHASES <PHASE LIST>                     */00257400
      ;                                                                         00257500
                                                                                00257600
         /*     15   <PHASE LIST> ::= <NUMBER>                                */00257700
COMMON_PHASES:                                                                  00257800
      DO;                                                                       00257900
         J = VALUE(SP);   /* PHASE NUMBER */                                    00258000
         IF (J < 0) | (J > 255) THEN DO;                                        00258100
            C1 = ATTR_PHASE||VALUE(SP)||OUT_OF_RANGE;                           00258200
            CALL ERROR(C1,0);                                                   00258300
            SUCCESS = FALSE;                                                    00258400
         END;                                                                   00258500
         ELSE DO;                                                               00258600
            #XPHASES = #XPHASES + 1;                                            00258700
            IF #XPHASES <= MAX_XPHASES THEN XPHASES(#XPHASES) = J;              00258800
         END;                                                                   00258900
      END;                                                                      00259000
         /*     16                  | <PHASE LIST> , <NUMBER>                 */00259100
      GO TO COMMON_PHASES;                                                      00259200
                                                                                00259300
         /*     17   <COMMAND CLAUSE> ::= <MAP CLAUSE>                        */00259400
      ;                                                                         00259500
         /*     18                      | <ANALYZE CLAUSE>                    */00259600
      ;                                                                         00259700
         /*     19                      | <PROCESS CLAUSE>                    */00259800
      ;                                                                         00259900
         /*     20                      | <SUPPRESS CLAUSE>                   */00260000
      ;                                                                         00260100
                                                                                00260200
         /*     21   <MAP CLAUSE> ::= MAP <MAP SPEC> <RANGE SPEC>             */00260300
         /*     21                    <LEVEL SPEC>                            */00260400
      IF SUCCESS THEN DO;                                                       00260500
         IF #MAP_CMDS < MAX_MAP_CMDS THEN DO;                                   00260600
            IF XLEVEL = -1 THEN XLEVEL = MAP_LEVEL;                             00260700
            IF XFORMAT = -1 THEN XFORMAT = MFORMAT;                             00260800
            #MAP_CMDS = #MAP_CMDS + 1;                                          00260900
            MAP_CMD_TYPE(#MAP_CMDS) = MAP_CMD;                                  00261000
            MAP_CMD_LEVEL(#MAP_CMDS) = XLEVEL;                                  00261100
            MAP_CMD_FMT(#MAP_CMDS) = XFORMAT;                                   00261200
            MAP_CMD_ADDR1(#MAP_CMDS) = XFROM;                                   00261300
            MAP_CMD_ADDR2(#MAP_CMDS) = XTO;                                     00261400
            IF MAP_CMD < 3 THEN MAP_CMD_UTIL(#MAP_CMDS) = 0;                    00261500
            ELSE IF MAP_CMD = 3 THEN DO;                                        00261600
               IF #XUNITS + 1 + #TPHASES < MAX_TPHASES THEN DO;                 00261700
                  TPHASES(#TPHASES + 1) = #XUNITS;                              00261800
                  DO J = 1 TO #XUNITS;                                          00261900
                     TPHASES(#TPHASES + J + 1) = XUNITS(J);                     00262000
                  END;                                                          00262100
                  MAP_CMD_UTIL(#MAP_CMDS) = #TPHASES + 1;                       00262200
                  #TPHASES = #TPHASES + #XUNITS + 1;                            00262300
                  #XUNITS = 0;                                                  00262400
               END;                                                             00262500
            END;                                                                00262600
            ELSE DO;                                                            00262700
               IF #XPHASES + 1 + #TPHASES < MAX_TPHASES THEN DO;                00262800
                  TPHASES(#TPHASES + 1) = #XPHASES;                             00262900
                  DO J = 1 TO #XPHASES;                                         00263000
                     TPHASES(#TPHASES + J + 1) = XPHASES(J);                    00263100
                  END;                                                          00263200
                  MAP_CMD_UTIL(#MAP_CMDS) = #TPHASES + 1;                       00263300
                  #TPHASES = #TPHASES + #XPHASES + 1;                           00263400
                  #XPHASES = 0;                                                 00263500
               END;                                                             00263600
            END;                                                                00263700
         END;                                                                   00263800
      END;                                                                      00263900
         /*     22   <MAP SPEC> ::= ALL CONFIGURATIONS                        */00264000
      IF SUCCESS THEN MAP_CMD = 1;                                              00264100
         /*     23                | ALL PHASES                                */00264200
      IF SUCCESS THEN MAP_CMD = 2;                                              00264300
         /*     24                | CONFIGURATION <CONFIG NAME LIST>          */00264400
      IF SUCCESS THEN MAP_CMD = 3;                                              00264500
         /*     25                | CONFIGURATIONS <CONFIG NAME LIST>         */00264600
      IF SUCCESS THEN MAP_CMD = 3;                                              00264700
         /*     26                | <PHASE SPEC>                              */00264800
      IF SUCCESS THEN MAP_CMD = 4;                                              00264900
                                                                                00265000
         /*     27   <RANGE SPEC> ::=                                         */00265100
      ;                                                                         00265200
         /*     28                  | <FROM SPEC>                             */00265300
      ;                                                                         00265400
         /*     29                  | <TO SPEC>                               */00265500
      ;                                                                         00265600
         /*     30                  | <FROM SPEC> <TO SPEC>                   */00265700
      ;                                                                         00265800
         /*     31                  | <SECTOR SPEC>                           */00265900
      ;                                                                         00266000
                                                                                00266100
         /*     32   <FROM SPEC> ::= FROM <HEX>                               */00266200
      XFROM = VALUE(MPP1);                                                      00266300
                                                                                00266400
         /*     33   <TO SPEC> ::= TO <HEX>                                   */00266500
      XTO = VALUE(MPP1);                                                        00266600
                                                                                00266700
         /*     34   <SECTOR SPEC> ::= SECTOR <NUMBER>                        */00266800
      DO;                                                                       00266900
         IF FC_FLAG THEN DO;                                                    00267000
            J = VALUE(MPP1);                                                    00267100
            IF (J < 0) | (J > 3) THEN DO;                                       00267200
               C1 ='SECTOR '||J||OUT_OF_RANGE;                                  00267300
               CALL ERROR(C1,0);                                                00267400
               SUCCESS = FALSE;                                                 00267500
            END;                                                                00267600
            ELSE DO;                                                            00267700
               XFROM = 32768 * J;                                               00267800
               XTO = XFROM + 32767;                                             00267900
            END;                                                                00268000
         END;                                                                   00268100
         ELSE DO;                                                               00268200
            C1='SECTOR SPECIFICATION ILLEGAL FOR 360 RUNS -- REQUEST IGNORED';  00268300
            CALL ERROR(C1,0);                                                   00268400
            SUCCESS = FALSE;                                                    00268500
         END;                                                                   00268600
      END;                                                                      00268700
                                                                                00268800
         /*     35   <LEVEL SPEC> ::=                                         */00268900
      ;                                                                         00269000
         /*     36                  | AT LEVEL <NUMBER> <SUBLEVEL SPEC>       */00269100
      DO;                                                                       00269200
         J = VALUE(MP + 2);                                                     00269300
         IF (J < 0) | (J > 3) THEN DO;                                          00269400
            C1 = 'LEVEL '||J||OUT_OF_RANGE;                                     00269500
            CALL ERROR(C1,0);                                                   00269600
            SUCCESS = FALSE;                                                    00269700
         END;                                                                   00269800
         ELSE XLEVEL = J;                                                       00269900
      END;                                                                      00270000
                                                                                00270100
         /*     37   <SUBLEVEL SPEC> ::=                                      */00270200
      ;                                                                         00270300
         /*     38                     | FORMAT <NUMBER>                      */00270400
      DO;                                                                       00270500
         J = VALUE(MPP1);                                                       00270600
         IF (J < 0) | (J > 2) THEN DO;                                          00270700
            C1 = 'FORMAT '||J||OUT_OF_RANGE;                                    00270800
            CALL ERROR(C1,0);                                                   00270900
            SUCCESS = FALSE;                                                    00271000
         END;                                                                   00271100
         ELSE XFORMAT = J;                                                      00271200
      END;                                                                      00271300
                                                                                00271400
         /*     39   <CONFIG NAME LIST> ::= <LABEL>                           */00271500
COMMON_CONFIGS:                                                                 00271600
      DO;                                                                       00271700
         DO J = 1 TO #CONFIGS;                                                  00271800
            IF CONFIG_NAME(J) = BCD(SP) THEN GO TO FOUND_CONFIG;                00271900
         END;                                                                   00272000
         C1 = 'CONFIGURATION '||BCD(SP)||ITEM_NOT_FOUND;                        00272100
         CALL ERROR(C1,0);                                                      00272200
         SUCCESS = FALSE;                                                       00272300
         GO TO END_CASE;                                                        00272400
FOUND_CONFIG:                                                                   00272500
         #XUNITS = #XUNITS + 1;                                                 00272600
         IF #XUNITS <= MAX_XUNITS THEN XUNITS(#XUNITS) = J;                     00272700
      END;                                                                      00272800
         /*     40                        | <CONFIG NAME LIST> , <LABEL>      */00272900
      GO TO COMMON_CONFIGS;                                                     00273000
                                                                                00273100
         /*     41   <ANALYZE CLAUSE> ::= ANALYZE <ANALYZE SPEC>              */00273200
      ;                                                                         00273300
                                                                                00273400
         /*     42   <ANALYZE SPEC> ::= CONFIGURATION <CONFIG NAME LIST>      */00273500
      ;                                                                         00273600
         /*     43                | CONFIGURATIONS <CONFIG NAME LIST>         */00273700
      ;                                                                         00273800
                                                                                00273900
         /*     44   <TYPE SPEC> ::=                                          */00274000
      CSECT_CAT = 0;                                                            00274100
         /*     45                    | TYPE <LABEL>                          */00274200
      DO;                                                                       00274300
         S1 = BCD(MPP1);                                                        00274400
         IF S1 = 'CPU' THEN CSECT_CAT = 0;                                      00274500
         ELSE IF S1 = 'BCE' THEN CSECT_CAT = 1;                                 00274600
         ELSE IF S1 = 'MSC' THEN CSECT_CAT = 2;                                 00274700
         ELSE IF S1 = 'PATCH' THEN CSECT_CAT = 3;                               00274800
         ELSE DO;                                                               00274900
            C1 = 'CSECT CLASSIFICATION '||S1||ITEM_NOT_FOUND;                   00275000
            CALL ERROR(C1,0);                                                   00275200
            SPACE_1;                                                            00275300
            SUCCESS = FALSE;                                                    00275400
            GO TO END_CASE;                                                     00275500
         END;                                                                   00275600
      END;                                                                      00275700
                                                                                00275800
         /*     46   <STATUS SPEC> ::=                                        */00275900
      CSECT_BOOL = 0;                                                           00276000
         /*     47                         | STATUS <LABEL>                   */00276100
      DO;                                                                       00276200
         S1 = BCD(MPP1);                                                        00276300
         CSECT_BOOL = 0;                                                        00276400
         IF S1 = 'INVARIANT' THEN CSECT_BOOL = CSECT_BOOL|"10";                 00276500
         ELSE IF S1 = 'VARIANT' THEN CSECT_BOOL = CSECT_BOOL|"08";              00276600
         ELSE IF S1 = 'INDEFINITE' THEN CSECT_BOOL = CSECT_BOOL|"04";           00276700
         ELSE DO;                                                               00276800
            C1 = 'CSECT STATUS '||S1||ITEM_NOT_FOUND;                           00276900
            CALL ERROR(C1,0);                                                   00277000
            SUCCESS = FALSE;                                                    00277100
            GO TO END_CASE;                                                     00277200
         END;                                                                   00277300
      END;                                                                      00277400
                                                                                00277500
         /*     48   <PROCESS CLAUSE> ::= PROCESS <UNIT SPEC>                 */00277600
      IF SUCCESS THEN DO;                                                       00277700
         IF FIRST_PROCESS THEN DO;                                              00277800
            FIRST_PROCESS = FALSE;                                              00277900
            DO J = 1 TO #UNITS;                                                 00278000
               UNIT_FLAGS(J) = UNIT_FLAGS(J) | "0010";                          00278100
            END;                                                                00278200
         END;                                                                   00278300
         DO J = 1 TO #XUNITS;                                                   00278400
            UNIT_FLAGS(XUNITS(J)) = UNIT_FLAGS(XUNITS(J)) & "FFEF";             00278500
         END;                                                                   00278600
         #XUNITS = 0;                                                           00278700
      END;                                                                      00278800
         /*     49                      | PROCESS <FUNC SPEC>                 */00278900
      IF SUCCESS THEN DO;                                                       00279000
         IF FIRST_PROCESS THEN DO;                                              00279100
            FIRST_PROCESS = FALSE;                                              00279200
            DO J = 1 TO #UNITS;                                                 00279300
               UNIT_FLAGS(J) = UNIT_FLAGS(J) | "0010";                          00279400
            END;                                                                00279500
         END;                                                                   00279600
         DO J = 1 TO #XUNITS;                                                   00279700
            FUNC# = XUNITS(J);                                                  00279800
            DO K = 1 TO TPHASES(FUNC_UNIT_PTR(FUNC#));                          00279900
               L = TPHASES(FUNC_UNIT_PTR(FUNC#) + K);                           00280000
               UNIT_FLAGS(L) = UNIT_FLAGS(L) & "FFEF";                          00280100
            END;                                                                00280200
         END;                                                                   00280300
      END;                                                                      00280400
                                                                                00280500
         /*     50   <FUNC SPEC> ::= FUNCTION <FUNC NAME LIST>                */00280600
      ;                                                                         00280700
         /*     51                 | FUNCTIONS <FUNC NAME LIST>               */00280800
      ;                                                                         00280900
                                                                                00281000
         /*     52   <FUNC NAME LIST> ::= <LABEL>                             */00281100
COMMON_FUNCS:                                                                   00281200
      DO;                                                                       00281300
         DO J = 1 TO #FUNCS;                                                    00281400
            IF FUNC_NAME(J) = BCD(SP) THEN GO TO FOUND_FUNC;                    00281500
         END;                                                                   00281600
         C1 = ATTR_FUNCTION||BCD(SP)||ITEM_NOT_FOUND;                           00281700
         CALL ERROR(C1,0);                                                      00281800
         SUCCESS = FALSE;                                                       00281900
         GO TO END_CASE;                                                        00282000
FOUND_FUNC:                                                                     00282100
         #XUNITS = #XUNITS + 1;                                                 00282200
         IF #XUNITS <= MAX_XUNITS THEN XUNITS(#XUNITS) = J;                     00282300
      END;                                                                      00282400
         /*     53                      | <FUNC NAME LIST> , <LABEL>          */00282500
      GO TO COMMON_FUNCS;                                                       00282600
                                                                                00282700
         /*     54   <SUPPRESS CLAUSE> ::= SUPPRESS PRINT FOR <UNIT SPEC>     */00282800
      IF SUCCESS THEN DO;                                                       00282900
         DO J = 1 TO #XUNITS;                                                   00283000
            UNIT_FLAGS(XUNITS(J)) = UNIT_FLAGS(XUNITS(J))|"0010";               00283100
         END;                                                                   00283200
         #XUNITS = 0;                                                           00283300
      END;                                                                      00283400
         /*     55                       | SUPPRESS PRINT FOR <FUNC SPEC>     */00283500
      IF SUCCESS THEN DO;                                                       00283600
         DO J = 1 TO #XUNITS;                                                   00283700
            FUNC# = XUNITS(J);                                                  00283800
            DO K = 1 TO TPHASES(FUNC_UNIT_PTR(FUNC#));                          00283900
               L = TPHASES(FUNC_UNIT_PTR(FUNC#) + K);                           00284000
               UNIT_FLAGS(L) = UNIT_FLAGS(L) | "0010";                          00284100
            END;                                                                00284200
         END;                                                                   00284300
      END;                                                                      00284400
         /*     56                       | SUPPRESS ERRORS IN <UNIT SPEC>     */00284500
      IF SUCCESS THEN DO;                                                       00284600
         DO J = 1 TO #XUNITS;                                                   00284700
            UNIT_FLAGS(XUNITS(J)) = UNIT_FLAGS(XUNITS(J))|"0020";               00284800
         END;                                                                   00284900
         #XUNITS = 0;                                                           00285000
      END;                                                                      00285100
         /*     57                       | SUPPRESS PRINT FOR <CSECT SPEC>    */00285200
      DO;                                                                       00285300
         DO J = 1 TO #XUNITS;                                                   00285400
            CSECT_FLAGS(XUNITS(J)) = CSECT_FLAGS(XUNITS(J))|"20";               00285500
         END;                                                                   00285600
         #XUNITS = 0;                                                           00285700
      END;                                                                      00285800
                                                                                00285900
         /*     58   <CSECT SPEC> ::= CSECT <CSECT LIST>                      */00286000
      ;                                                                         00286100
         /*     59                  | CSECTS <CSECT LIST>                     */00286200
      ;                                                                         00286300
                                                                                00286400
         /*     60   <CSECT LIST> ::= <LABEL>                                 */00286500
      DO;                                                                       00286600
COMMON_CSECTS:                                                                  00286700
         CSECT_NAME = BCD(SP);                                                  00286800
         LEN = LENGTH(CSECT_NAME);                                              00286900
         IF LEN > 8 THEN CSECT_NAME = SUBSTR(CSECT_NAME,0,8);                   00287000
         ELSE IF LEN < 8 THEN CSECT_NAME = PAD(CSECT_NAME,8);                   00287100
         SIGNAL = FALSE;                                                        00287200
         DO J = 1 TO #CSECTS;                                                   00287300
            S1 = STRING("07000000" + ADDR(CSECT_CHAR(SHL(J,1))));               00287400
            IF S1 = CSECT_NAME THEN DO;                                         00287500
               SIGNAL = TRUE;                                                   00287600
               #XUNITS = #XUNITS + 1;                                           00287700
               IF #XUNITS <= MAX_XUNITS THEN XUNITS(#XUNITS) = J;               00287800
            END;                                                                00287900
         END;                                                                   00288000
         IF ~SIGNAL THEN DO;                                                    00288100
            C1 = 'CSECT '||CSECT_NAME||ITEM_NOT_FOUND;                          00288200
            CALL ERROR(C1,0);                                                   00288300
         END;                                                                   00288400
      END;                                                                      00288500
         /*     61                  | <CSECT LIST> , <LABEL>                  */00288600
      GO TO COMMON_CSECTS;                                                      00288700
                                                                                00288800
END_CASE:                                                                       00288900
   END;  /* OF DO CASE  */                                                      00289000
 END SYNTHESIZE;                                                                00289100
                                                                                00289200
FIX_TOKEN: PROCEDURE(NST,NLK,NTK);                                              00289300
   DECLARE (NST,NLK,NTK) BIT(16);                                               00289400
   DECLARE (I,J,K) BIT(16);                                                     00289500
   K = SP - 1;                                                                  00289600
   DO WHILE NST > 0;                                                            00289700
      IF NST <= MAXR# THEN DO;                                                  00289800
         I = INDEX1(NST);                                                       00289900
         DO I = I TO I + INDEX2(NST) - 1;                                       00290000
            IF READ1(I) = NTK THEN DO;                                          00290100
               IF NLK >= 0 THEN RETURN NST;                                     00290200
               ELSE RETURN -NLK;                                                00290300
            END;                                                                00290400
         END;                                                                   00290500
         IF NLK <= 0 THEN RETURN 0;                                             00290600
         NST = NLK;                                                             00290700
         NLK = -NST;                                                            00290800
      END;                                                                      00290900
      ELSE IF NST > MAXP# THEN DO;                                              00291000
         I = INDEX1(NST);                                                       00291100
         J = STATE_STAK(K);                                                     00291200
         DO WHILE J ~= APPLY1(I);                                               00291300
            IF APPLY1(I) = 0 THEN J = 0;                                        00291400
            ELSE I = I + 1;                                                     00291500
         END;                                                                   00291600
         K = K - INDEX2(NST);                                                   00291700
         NST = APPLY2(I);                                                       00291800
      END;                                                                      00291900
      ELSE IF NST <= MAXL# THEN DO;                                             00292000
         I = INDEX1(NST);                                                       00292100
         J = NTK;                                                               00292200
         DO WHILE LOOK1(I) ~= J;                                                00292300
            IF LOOK1(I) = 0 THEN J = 0;                                         00292400
            ELSE I = I + 1;                                                     00292500
         END;                                                                   00292600
         NST = LOOK2(I);                                                        00292700
      END;                                                                      00292800
      ELSE NST = 0;                                                             00292900
   END;                                                                         00293000
   RETURN 0;                                                                    00293100
 END FIX_TOKEN;                                                                 00293200
                                                                                00293300
RECOVER: PROCEDURE;                                                             00293400
   SUCCESS = TRUE;                                                              00293500
   DO WHILE (TOKEN ~= SEMICOLON)&(TOKEN ~= ENDFILE);                            00293600
      LOOK_AHEAD = FALSE;                                                       00293700
      CALL SCAN;                                                                00293800
      CONTEXT = 0;                                                              00293900
   END;                                                                         00294000
   IF TOKEN = SEMICOLON THEN DO;                                                00294100
      LOOK_AHEAD = FALSE;                                                       00294200
      CALL SCAN;                                                                00294300
   END;                                                                         00294400
   DO WHILE SP > 0;                                                             00294500
      STATE = FIX_TOKEN(STATE_STAK(SP),LOOK_STAK(SP),TOKEN);                    00294600
      IF STATE > 0 THEN DO;                                                     00294700
         SP = SP - 1;                                                           00294800
         IF TOKEN = ENDFILE THEN GO TO VERY_BAD;                                00294900
         RETURN;                                                                00295000
      END;                                                                      00295100
      SP = SP - 1;                                                              00295200
   END;                                                                         00295300
VERY_BAD:                                                                       00295400
   OUTPUT(1) = ' ****** ERROR RECOVERY UNSUCCESSFUL';                           00295500
   COMPILING = FALSE;                                                           00295600
   END RECOVER;                                                                 00295700
                                                                                00295800
COMPILATION_LOOP: PROCEDURE;                                                    00295900
   DECLARE (I,J) BIT(16);                                                       00296000
                                                                                00296100
   /*  HERE WE PARSE THE INPUT STREAM, HOPPING FROM STATE TO STATE */           00296200
   /*  ACCORDING TO THE TOKENS RETURNED BY SCAN, AND PERFORMING    */           00296300
   /*  REDUCTIONS USING SYNTHESIZE.                                */           00296400
                                                                                00296500
                                                                                00296600
   ADD_TO_STAK: PROCEDURE;                                                      00296700
      SP = SP + 1;                                                              00296800
      IF SP > MAXSP THEN DO;                                                    00296900
         MAXSP = SP;                                                            00297000
         IF SP > STAKSIZE THEN DO;                                              00297100
            CALL ERROR('PARSE STACK SIZE EXCEEDED',3);                          00297200
            RETURN;                                                             00297300
         END;                                                                   00297400
      END;                                                                      00297500
   END ADD_TO_STAK;                                                             00297600
                                                                                00297700
  COMP_LOOP:                                                                    00297800
   DO WHILE COMPILING;                                                          00297900
      IF TOGGLE THEN OUTPUT = '******* CURRENT STATE '||STATE;                  00298000
      IF STATE <= MAXR# THEN DO;     /*  READ STATE  */                         00298100
         CALL SCAN;                                                             00298200
         CALL ADD_TO_STAK;                                                      00298300
         STATE_STAK(SP) = STATE;                                                00298400
         LOOK_STAK(SP) = LOOK;                                                  00298500
         LOOK = 0;                                                              00298600
         I = INDEX1(STATE);                                                     00298700
         DO I = I TO I + INDEX2(STATE) - 1;                                     00298800
            IF READ1(I) = TOKEN THEN DO;                                        00298900
               VALUE(SP) = VALUE;                                               00299000
               BCD(SP) = BCD;                                                   00299100
               STATE = READ2(I);                                                00299200
               LOOK_AHEAD = FALSE;                                              00299300
               GO TO COMP_LOOP;                                                 00299400
            END;                                                                00299500
         END;                                                                   00299600
         /*  ILLEGAL SYMBOL */                                                  00299700
         CALL ERROR('GRAMMATICALLY ILLEGAL TOKEN: '||BCD,2);                    00299800
         CALL RECOVER;                                                          00299900
      END;                                                                      00300000
      ELSE IF STATE > MAXP# THEN DO;   /* APPLY PRODUCTION STATE */             00300100
         MP = SP - INDEX2(STATE);                                               00300200
         MPP1 = MP + 1;                                                         00300300
         CALL SYNTHESIZE(STATE-MAXP#);                                          00300400
         SP = MP;                                                               00300500
         I = INDEX1(STATE);                                                     00300600
         J = STATE_STAK(SP);                                                    00300700
         DO WHILE APPLY1(I) ~= 0;                                               00300800
            IF J = APPLY1(I) THEN GO TO MATCH_FOUND;                            00300900
            I = I + 1;                                                          00301000
         END;                                                                   00301100
      MATCH_FOUND:                                                              00301200
         IF APPLY2(I) = 0 THEN RETURN;   /* GOAL REACHED  */                    00301300
         STATE = APPLY2(I);                                                     00301400
         LOOK = 0;                                                              00301500
      END;                                                                      00301600
      ELSE IF STATE <= MAXL# THEN DO;          /* LOOK AHEAD STATE  */          00301700
         I = INDEX1(STATE);                                                     00301800
         LOOK = STATE;                                                          00301900
         CALL SCAN;                                                             00302000
         DO WHILE LOOK1(I) ~= 0;                                                00302100
            IF LOOK1(I) = TOKEN THEN GO TO LOOK_MATCH;                          00302200
            I = I + 1;                                                          00302300
         END;                                                                   00302400
   LOOK_MATCH:                                                                  00302500
         STATE = LOOK2(I);                                                      00302600
      END;                                                                      00302700
      ELSE DO;         /*  PUSH STATE  */                                       00302800
         CALL ADD_TO_STAK;                                                      00302900
         STATE_STAK(SP) = INDEX2(STATE);                                        00303000
         STATE = INDEX1(STATE);                                                 00303100
         LOOK_STAK(SP),LOOK = 0;                                                00303200
      END;                                                                      00303300
   END;                                                                         00303400
                                                                                00303500
   END COMPILATION_LOOP;                                                        00303600
                                                                                00303700
PRINT_CROSS_REF:                                                                00303800
   PROCEDURE (LINK);                                                            00303900
      DECLARE (K,LINK,KLIM1,KLIM2) FIXED,                                       00304000
              (ITEM) BIT(16),                                                   00304100
              (S1,S2) CHARACTER;                                                00304200
      BASED NODE_H BIT(16);                                                     00304300
                                                                                00304400
PRINT_IT:                                                                       00304500
   PROCEDURE;                                                                   00304600
      S1 = S1 || (SHR(ITEM,13)&7)||X1||SUBSTR(10000+(ITEM&"1FFF"),1,4)||        00304700
         GET_SRN(ITEM);                                                         00304800
      IF LENGTH(S1) + SHL(GFORMAT,3) > 108 THEN DO;                             00304900
         OUTPUT = S1;                                                           00305000
         S1 = X52;                                                              00305100
      END;                                                                      00305200
   END PRINT_IT;                                                                00305300
                                                                                00305400
      IF LINK ~= 0 THEN DO;                                                     00305500
         DO WHILE LINK ~= 0;                                                    00305600
            CALL VMEM_LOCATE_PTR(1,LINK,0);                                     00305700
            COREWORD(ADDR(NODE_H)) = VMEM_LOC_ADDR;                             00305800
            S2 = UNIT_NAMES(NODE_H(2));                                         00305900
            S2 = PAD(S2,32);                                                    00306000
            S1 = PERIOD3||S2||X2;                                               00306100
            KLIM1 = 4;                                                          00306200
            KLIM2 = KLIM1 + NODE_H(3) - 1;                                      00306300
            #REFS2 = #REFS2 + 1;                                                00306400
            IF GFORMAT > 0 THEN DO;                                             00306500
               IF NODE_H(2) ~= SELECTED_UNIT THEN DO;                           00306600
                  SELECTED_UNIT = NODE_H(2);                                    00306700
                  CALL MOVE(8,SDF_NAMES(SELECTED_UNIT),SDFNAM);                 00306800
                  CALL MONITOR(22,"80000007");                                  00306900
                  IF (COREWORD(ADDRESS)&"80000000") ~= 0 THEN SRN_FLAG = TRUE;  00307000
                  ELSE SRN_FLAG = FALSE;                                        00307100
               END;                                                             00307200
            END;                                                                00307300
            DO K = KLIM1 TO KLIM2;                                              00307400
               ITEM = NODE_H(K);                                                00307500
               IF (ITEM&"E000") ~= 0 THEN #REFS1 = #REFS1 + 1;                  00307600
               REF_STAT = REF_STAT | (ITEM&"E000");                             00307700
               CALL PRINT_IT;                                                   00307800
            END;                                                                00307900
            LINK = SHL(NODE_H(0),16) + NODE_H(1);                               00308000
            IF LENGTH(S1) > 52 THEN OUTPUT = S1;                                00308100
         END;                                                                   00308200
         REF_STAT = SHR(REF_STAT,13)&7;                                         00308300
         IF GFORMAT > 0 THEN DO;                                                00308400
            IF GOT_UNIT ~= SELECTED_UNIT THEN DO;                               00308500
               SELECTED_UNIT = GOT_UNIT;                                        00308600
               CALL MOVE(8,SDF_NAME,SDFNAM);                                    00308700
               CALL MONITOR(22,"80000007");                                     00308800
               IF (COREWORD(ADDRESS)&"80000000") ~= 0 THEN SRN_FLAG = TRUE;     00308900
               ELSE SRN_FLAG = FALSE;                                           00309000
            END;                                                                00309100
         END;                                                                   00309200
      END;                                                                      00309300
      ELSE REF_STAT = -1;                                                       00309400
   END PRINT_CROSS_REF;                                                         00309500
                                                                                00309600
FICHE_TITLE:                                                                    00309700
   PROCEDURE (USER_TITLE);                                                      00309800
      DECLARE (USER_TITLE,PARM_TEXT) CHARACTER,                                 00309900
         (I) BIT(16), (ALL_SET,SIGNAL) BIT(1);                                  00310000
      DECLARE NAMERTN(1) FIXED,                                                 00310100
            COMTFLAG BIT(8) INITIAL("80"),                                      00310200
            COMTFORM BIT(8),                                                    00310300
            COMTILINE BIT(16),                                                  00310400
            COMTIDISP BIT(16),                                                  00310500
            COMTILEN BIT(16),                                                   00310600
            COMTDCB FIXED,   /* FILLED IN BY DOFICHE ROUTINE */                 00310700
            COMTLEN BIT(16),                                                    00310800
            COMTITLE(63) BIT(8);                                                00310900
      IF ~ALL_SET THEN DO;                                                      00311000
         IF SIGNAL THEN RETURN;                                                 00311100
         SIGNAL = TRUE;                                                         00311200
         PARM_TEXT = PARM_FIELD;                                                00311300
         I = CHAR_INDEX(PARM_TEXT,'CLASS=');                                    00311400
         IF I < 0 THEN DO;                                                      00311500
            I = CHAR_INDEX(PARM_TEXT,'CL=');                                    00311600
            IF I < 0 THEN RETURN;                                               00311700
            I = I - 3;                                                          00311800
         END;                                                                   00311900
         IF BYTE(PARM_TEXT,I+6) ~= BYTE(MCHAR) THEN RETURN;                     00312000
         CALL MOVE(8,'DOFICHE ',ADDR(NAMERTN));                                 00312100
         ALL_SET = TRUE;                                                        00312200
      END;                                                                      00312300
      I = LENGTH(USER_TITLE);                                                   00312400
      IF I = 0 THEN DO;                                                         00312500
         IF LENGTH(TITLE) > 0 THEN USER_TITLE = STAT_TITLE||' --- '||TITLE;     00312600
         ELSE USER_TITLE = STAT_TITLE;                                          00312700
      END;                                                                      00312800
      I = LENGTH(USER_TITLE);                                                   00312900
      IF I > 64 THEN I = 64;                                                    00313000
      COMTLEN = I;                                                              00313100
      CALL MOVE(I,USER_TITLE,ADDR(COMTITLE));                                   00313200
      CALL MONITOR(28,4,ADDR(NAMERTN));                                         00313300
   END FICHE_TITLE;                                                             00313400
                                                                                00313500
INITIALIZE:                                                                     00313600
   PROCEDURE;                                                                   00313700
      DECLARE (MAX_AVAIL,I,J,K,TEMP1) FIXED,                                    00313800
             (RECORD_ADDR,#ENTRIES) FIXED,                                      00313900
             (CSECT_TYPE) BIT(16),                                              00314000
             (NAMEX,BASE_NAME,FIRST_CHAR,SECOND_CHAR) CHARACTER,                00314100
             OPT_PROC_NAME CHARACTER INITIAL ('STATOPT '),                      00314105
             (CESD_FLAG) BIT(1),                                                00314200
              (C,S,PARM_TEXT) CHARACTER;                                        00314400
      BASED NODE_F FIXED;                                                       00314500
      BASED   (PRO,CON,TYPE2,VALS,MONVALS) FIXED;                               00314600
      DECLARE TYPE2_TYPE(9) BIT(8) INITIAL(                                     00314700
         0,  /* TITLE */                                                        00314800
         2,  /* LINECT */                                                       00314900
         2,  /* PAGES */                                                        00315000
         1,  /* MAP */                                                          00315100
         1,  /* GSD */                                                          00315200
         0,  /* LMOD */                                                         00315300
         1,  /* MSGLEVEL */                                                     00315400
         1,  /* GFORMAT */                                                      00315500
         1,  /* MFORMAT */                                                      00315600
         1);  /* FILE */                                                        00315700
                                                                                00315800
STORAGE_MGT:                                                                    00315900
   PROCEDURE (VAR_LOC,SIZE,HIARCHY,NOABORT) BIT(1);                             00316000
      DECLARE (VAR_LOC,SIZE,I,J) FIXED, (HIARCHY,NOABORT) BIT(1);               00316100
                                                                                00316200
ALLOCATE_LCS:                                                                   00316300
   PROCEDURE BIT(1);                                                            00316400
      SIZE = (SIZE + 7)&"00FFFFF8";                                             00316500
      IF SIZE > CORE_LEN THEN RETURN 1;                                         00316600
      J = CORE_ADDR;                                                            00316700
      CORE_ADDR = CORE_ADDR + SIZE;                                             00316800
      CORE_LEN = CORE_LEN - SIZE;                                               00316900
      RETURN 0;                                                                 00317000
   END ALLOCATE_LCS;                                                            00317100
                                                                                00317200
      IF HIARCHY THEN DO;                                                       00317300
         IF ~ALLOCATE_LCS THEN GO TO GOT_CORE;                                  00317400
      END;                                                                      00317500
      I = FREELIMIT + 512;                                                      00317600
      J = (I - SIZE)&"00FFFFF8";                                                00317700
      IF (J - 512) <= (FREEPOINT + MIN_STRING_SIZE) THEN DO;                    00317800
         IF HIARCHY THEN GO TO CORE_FAIL;                                       00317900
         IF ALLOCATE_LCS THEN GO TO CORE_FAIL;                                  00318000
      END;                                                                      00318100
      ELSE FREELIMIT = J - 512;                                                 00318200
GOT_CORE:                                                                       00318300
      COREWORD(VAR_LOC) = J;                                                    00318400
      CALL ZERO_CORE(J,SIZE);                                                   00318500
      RETURN 0;                                                                 00318600
CORE_FAIL:                                                                      00318700
      IF NOABORT THEN RETURN 1;                                                 00318800
      ELSE GO TO NO_CORE;                                                       00318900
   END STORAGE_MGT;                                                             00319000
                                                                                00319100
   /* PROCESS PARM FIELD INFORMATION */                                         00319200
                                                                                00319300
      TMP = MONITOR(13, OPT_PROC_NAME);                                         00319400
      OPTIONS_CODE = COREWORD(TMP);                                             00319500
      COREWORD(ADDR(CON)) = COREWORD(TMP + 4);                                  00319600
      COREWORD(ADDR(PRO)) = COREWORD(TMP + 8);                                  00319700
      COREWORD(ADDR(TYPE2)) = COREWORD(TMP + 12);                               00319800
      COREWORD(ADDR(VALS)) = COREWORD(TMP+16);                                  00319900
      COREWORD(ADDR(MONVALS)) = COREWORD(TMP+20);  /* NOT USED RIGHT NOW */     00320000
      TITLE = KEEP(STRING(VALS(0)));                                            00320100
      CALL FICHE_TITLE('');                                                     00320200
      IF LENGTH(TITLE) = 0 THEN                                                 00320300
         TITLE = 'I N T E R M E T R I C S ,   I N C .';                         00320400
      J = LENGTH(TITLE);                                                        00320500
      J = ((61 - J)/2) + J;                                                     00320600
      C = LEFT_PAD(TITLE,J);                                                    00320700
      C = PAD(C,61);                                                            00320800
      S = CHAR_TIME(TIME);                                                      00320900
      S = CHAR_DATE(DATE) || X3 || S;                                           00321000
      OUTPUT(1) = 'HH A L S T A T   '||STRING(MONITOR(23))||C||X3||S;           00321100
      CALL PRINT_DATE_AND_TIME('HALSTAT -- VERSION OF ',                        00321200
         DATE_OF_GENERATION, TIME_OF_GENERATION);                               00321300
      DSPACE;                                                                   00321400
      CALL PRINT_DATE_AND_TIME('TODAY IS ', DATE, TIME);                        00321500
      SPACE_1;                                                                  00321600
      PARM_TEXT = PARM_FIELD;                                                   00321700
      IF LENGTH(PARM_TEXT) > 0 THEN DO;                                         00321800
         DO I = 0 TO LENGTH(PARM_TEXT) - 2;                                     00321900
            IF BYTE(PARM_TEXT,I) = BYTE(DOLLAR_SIGN) THEN DO;                   00322000
               SP = BYTE(PARM_TEXT,I + 1) - BYTE(ZEROCHAR);                     00322100
               IF SP >= 0 & SP <= 9 THEN TOGGLE(SP) = TRUE;                     00322200
            END;                                                                00322300
         END;                                                                   00322400
         CALL EMIT_OUTPUT('PARM FIELD: '||PARM_TEXT);                           00322500
      END;                                                                      00322600
      DSPACE;                                                                   00322700
      OUTPUT = ' COMPLETE LIST OF HALSTAT OPTIONS IN EFFECT';                   00322800
      DSPACE;                                                                   00322900
      OUTPUT = '       *** TYPE 1 OPTIONS ***';                                 00323000
      SPACE_1;                                                                  00323100
      I = 0;                                                                    00323200
      DO WHILE PRO(I) ~= 0;                                                     00323300
         S = STRING(PRO(I));                                                    00323400
         C = LEFT_PAD(STRING(CON(I)), 12);                                      00323500
         OUTPUT = C || ' INSTEAD OF ' || S;                                     00323600
         I = I + 1;                                                             00323700
      END;                                                                      00323800
      OUTPUT(1) = DOUBLE;                                                       00323900
      OUTPUT = '       *** TYPE 2 OPTIONS ***';                                 00324000
      SPACE_1;                                                                  00324100
      I = 0;                                                                    00324200
      DO WHILE TYPE2(I) ~= 0;                                                   00324300
         C = LEFT_PAD(STRING(TYPE2(I)), 15);                                    00324400
         IF TYPE2_TYPE(I) ~= 2 THEN DO;                                         00324500
            IF TYPE2_TYPE(I) THEN                                               00324600
               S = VALS(I);  /* DECIMAL VALUE */                                00324700
            ELSE                                                                00324800
               S = STRING(VALS(I));  /* DESCRIPTOR */                           00324900
            OUTPUT = C || BLK_EQUALS_BLK || S;                                  00325000
         END;                                                                   00325100
         I = I + 1;                                                             00325200
      END;                                                                      00325300
      DSPACE;                                                                   00325400
                                                                                00325500
      MAP_LEVEL = VALS(3);     /* MAP=    */                                    00325600
      GSD_LEVEL = VALS(4);     /* GSD=   */                                     00325700
      MSG_LEVEL = VALS(6);     /* MSGLEVEL=   */                                00325800
      GFORMAT = VALS(7);       /* GFORMAT=   */                                 00325900
      MFORMAT = VALS(8);      /* MFORMAT=   */                                  00326000
      FILE_LEVEL = VALS(9);     /* FILE=  */                                    00326100
                                                                                00326200
   /* SCAN THE CESD TO DETERMINE GOOD NUMBERS FOR MAX_CSECTS AND MAX_UNITS */   00326300
                                                                                00326400
      LMOD = KEEP(STRING(VALS(5)));                                             00326500
      I = LENGTH(LMOD);                                                         00326600
      IF I = 0 THEN LMOD = 'GO      ';                                          00326700
      ELSE LMOD = PAD(LMOD,8);                                                  00326800
      IF MONITOR(2,8,LMOD) THEN DO;                                             00326900
         SPACE_1;                                                               00327000
         OUTPUT = '*** LOAD MODULE '||LMOD||' NOT FOUND ***';                   00327100
         GO TO BAIL_OUT;                                                        00327200
      END;                                                                      00327300
                                                                                00327400
      MIN_STRING_SIZE = 50000;   /* AN INTERIM VALUE */                         00327500
      CALL MOVE(8,OPT_PROC_NAME,ADDR(NAMERTN));                                 00327600
      CALL MONITOR(28,8,ADDR(NAMERTN));   /* DELETE OPTION PROCESSOR */         00327700
      CALL MOVE(8,'GETLCS  ',ADDR(NAMERTN));                                    00327800
      CALL MONITOR(28,4,ADDR(NAMERTN));   /* GET LCS IF THERE IS ANY */         00327900
      CALL STORAGE_MGT(ADDR(FILE1_BUFF),14400,1,0);                             00328000
      FILE1_BUFF_ADDR = COREWORD(ADDR(FILE1_BUFF));                             00328100
      AUX_BUFF_ADDR = FILE1_BUFF_ADDR + VMEM_PAGE_SIZE;                         00328200
                                                                                00328300
   /* IF AN FC LOAD MODULE, USE A POINT TO BYPASS THE SYM RECORDS */            00328400
                                                                                00328500
      IF (OPTIONS_CODE&"20000000") ~= 0 THEN CALL MONITOR(24,0);                00328600
                                                                                00328700
      DO WHILE MONITOR(24,FILE1_BUFF_ADDR);                                     00328800
         RECORD_ADDR = FILE1_BUFF_ADDR;                                         00328900
         IF COREBYTE(RECORD_ADDR) = "20" THEN DO;                               00329000
            CESD_FLAG = TRUE;                                                   00329100
            #ENTRIES = SHR(COREWORD(RECORD_ADDR+4)&"FFFF",4);                   00329200
            RECORD_ADDR = RECORD_ADDR - 8;                                      00329300
            DO I = 1 TO #ENTRIES;                                               00329400
               RECORD_ADDR = RECORD_ADDR + 16;                                  00329500
               IF (COREBYTE(RECORD_ADDR+8)&"F") = 0 THEN DO;                    00329600
                  MAX_CSECTS = MAX_CSECTS + 1;                                  00329700
                  FIRST_CHAR = STRING(RECORD_ADDR);                             00329800
                  SECOND_CHAR = STRING(RECORD_ADDR + 1);                        00329900
                  CSECT_TYPE = 0;                                               00330000
                  IF FIRST_CHAR = DOLLAR_SIGN THEN DO;                          00330100
                     IF SECOND_CHAR = ZEROCHAR THEN CSECT_TYPE = 1;             00330200
                     ELSE CSECT_TYPE = 2;                                       00330300
                     GO TO CONTINUE;                                            00330400
                  END;                                                          00330500
                  IF FIRST_CHAR = AT_SIGN THEN DO;                              00330600
                     CSECT_TYPE = 5;                                            00330700
                     GO TO CONTINUE;                                            00330800
                  END;                                                          00330900
                  IF FIRST_CHAR = SHARP_SIGN THEN DO;                           00331000
                     CSECT_TYPE = CHAR_INDEX(KEY_STRING,SECOND_CHAR) + 1;       00331100
                     GO TO CONTINUE;                                            00331200
                  END;                                                          00331300
                  J = CHAR_INDEX(NUM_STRING,SECOND_CHAR);                       00331400
                  IF J > -1 THEN CSECT_TYPE = 4;                                00331500
CONTINUE:                                                                       00331600
                  IF (CSECT_TYPE>0)&(CSECT_TYPE<14) THEN DO;                    00331700
                     BASE_NAME = STRING("05000002" + RECORD_ADDR);              00331800
                     BASE_NAME = DBL_SHARP_SIGN||BASE_NAME;                     00331900
                     DO J = 1 TO MAX_UNITS;                                     00332000
                        K = MAX_UNITS - J + 1;                                  00332100
                        NAMEX = STRING("07000100"+SHL(K,3)+FILE1_BUFF_ADDR);    00332200
                        IF NAMEX = BASE_NAME THEN GO TO MATCH;                  00332300
                     END;                                                       00332400
                     MAX_UNITS = MAX_UNITS + 1;                                 00332500
                     TMP = FILE1_BUFF_ADDR + 256 + SHL(MAX_UNITS,3);            00332600
                     CALL MOVE(8,BASE_NAME,TMP);                                00332700
MATCH:                                                                          00332800
                  END;                                                          00332900
               END;                                                             00333000
            END;                                                                00333100
            IF #ENTRIES < 15 THEN GO TO END_READ;                               00333200
         END;                                                                   00333300
         ELSE IF CESD_FLAG THEN GO TO END_READ;                                 00333400
      END;                                                                      00333500
END_READ:                                                                       00333600
      CALL MONITOR(3,8);                                                        00333700
      CALL MONITOR(2,8,LMOD);                                                   00333800
                                                                                00333900
   /* SET UP THE BASED STORAGE DEPENDENT UPON CSECTS AND UNITS */               00334000
                                                                                00334100
      MIN_STRING_SIZE = SHL(MAX_UNITS,9);  /* 512 BYTES PER UNIT */             00334200
      IF MIN_STRING_SIZE < 50000 THEN MIN_STRING_SIZE = 50000;                  00334300
      IF MIN_STRING_SIZE > 250000 THEN MIN_STRING_SIZE = 250000;                00334400
      J = (FREELIMIT + 512) & "00FFF800";  /* 2K BNDRY NEAR TOP OF CORE */      00334500
      TEMP1 = SHL(SHL(3*(MAX_UNITS+1),1) + DX_SIZE,2);                          00334600
      IF TEMP1 <= 2048 THEN  TEMP1 = (J - TEMP1) & "00FFF800";                  00334700
      ELSE DO;                                                                  00334800
         TEMP1 = (J - SHL(3*(MAX_UNITS+1),2))&"00FFF800";                       00334900
         TEMP1 = (TEMP1 - SHL(DX_SIZE + 3*(MAX_UNITS+1),2))&"FFF800";           00335000
      END;                                                                      00335100
      IF TEMP1 - 512 <= FREEPOINT THEN CALL COMPACTIFY;                         00335200
      CALL MONITOR(7,ADDR(TEMP1),J - TEMP1);                                    00335300
      FREELIMIT = TEMP1 - 512;                                                  00335400
      IF DESCRIPTOR_MONITOR(6,ADDR(UNIT_NAMES),SHL(MAX_UNITS+1,2))              00335500
         THEN GO TO NO_CORE;                                                    00335600
      IF DESCRIPTOR_MONITOR(6,ADDR(SDF_NAMES),SHL(MAX_UNITS+1,2))               00335700
         THEN GO TO NO_CORE;                                                    00335800
      IF DESCRIPTOR_MONITOR(6,ADDR(SYMBOL_NAMES),SHL(MAX_UNITS+1,2))            00335900
         THEN GO TO NO_CORE;                                                    00336000
                                                                                00336100
      DO I = 0 TO #COM_SYTSIZE;                                                 00336200
         CALL STORAGE_MGT(ADDR(UNIT_SORT) + SHL(I,2),                           00336300
            SHL(MAX_UNITS+1,COMMON_SYTSIZES(I)),0,0);                           00336400
      END;                                                                      00336500
      CALL STORAGE_MGT(ADDR(SELECTOR),SHL(MAX_UNITS+1,3),1,0);                  00336600
      DO I = 0 TO #NON_COM_SYTSIZE;                                             00336700
         CALL STORAGE_MGT(ADDR(CSECT_ADDR) + SHL(I,2),                          00336800
            SHL(MAX_CSECTS+1,NON_COMMON_SYTSIZES(I)),0,0);                      00336900
      END;                                                                      00337000
                                                                                00337100
   /* SET UP SCALAR PROCESSING ARRAY */                                         00337200
                                                                                00337300
      CALL STORAGE_MGT(ADDR(DW),56,0,0);                                        00337400
      CALL INLINE("58",1,0,DW);          /*L   1,DW   */                        00337500
      CALL INLINE("50",1,0,DW_AD);       /*  ST 1,DW_AD */                      00337600
      CALL MONITOR(5,DW_AD);                                                    00337700
      ADDR_VALUE = DW_AD + 24;                                                  00337800
      ADDR_FIXER = ADDR_VALUE + 8;                                              00337900
      DW(8) = "4E000000";                                                       00338000
      DW(9) = 0;                                                                00338100
      ADDR_FIXED_LIMIT = ADDR_FIXER + 8;                                        00338200
      DW(10) = "487FFFFF";                                                      00338300
      DW(11) = "FFFFFFFF";                                                      00338400
      ADDR_ROUNDER = ADDR_FIXED_LIMIT + 8;                                      00338500
      DW(12) = "407FFFFF";                                                      00338600
      DW(13) = "FFFFFFFF";                                                      00338700
                                                                                00338800
   /* SET INTERNAL FLAGS BASED ON THE PARM FIELD */                             00338900
                                                                                00339000
      IF (OPTIONS_CODE & "40000000") ~= 0 THEN ADL_FLAG = TRUE;                 00339100
      IF (OPTIONS_CODE & "20000000") ~= 0 THEN FC_FLAG = TRUE;                  00339200
      IF (OPTIONS_CODE & "10000000") ~= 0 THEN STAT_FLAG = TRUE;                00339300
      IF (OPTIONS_CODE & "800") ~= 0 THEN EJECT_FLAG = TRUE;                    00339400
                                                                                00339500
   /* SET UP THE SDFPKG COMMUNICATION AREA */                                   00339600
                                                                                00339700
      COREWORD(ADDR(COMMTABL_BYTE)) = ADDR(COMM_TAB);                           00339800
      COREWORD(ADDR(COMMTABL_HALFWORD)) = ADDR(COMM_TAB);                       00339900
      COREWORD(ADDR(COMMTABL_FULLWORD)) = ADDR(COMM_TAB);                       00340000
      COMMTABL_ADDR = ADDR(COMM_TAB);                                           00340100
                                                                                00340200
   /* ALLOCATE SDFPKG FILE CONTROL BLOCK AREA */                                00340300
   /* USE G. CETRONE'S ROUTINE TO ALLOCATE SUFFICIENT FCB SPACE */              00340400
   /* TMP = GET_FCB_SIZE('HALSDF',1);  */                                       00340500
      TMP = 2000;                                                               00340510
      IF TMP <= 0 THEN DO;                                                      00340600
        GO TO BAIL_OUT;                                                         00340610
      END;                                                                      00340620
      NBYTES = - TMP;                                                           00340700
      CALL STORAGE_MGT(ADDR(PRO),SHL(TMP,7),1,0);                               00340800
      AFCBAREA = COREWORD(ADDR(PRO));                                           00340900
                                                                                00341000
   /* ALLOCATE AN AUXILIARY SDFPKG PAGING AREA DIRECTORY */                     00341100
                                                                                00341200
      CALL STORAGE_MGT(ADDR(PRO),ALT_PAD_SIZE,1,0);                             00341300
      ADDRESS = COREWORD(ADDR(PRO));                                            00341400
      PNTR = ALT_PAD_SIZE;                                                      00341500
                                                                                00341600
   /* INITIALIZE SDFPKG WITH A SMALL PAGING AREA */                             00341700
                                                                                00341800
      NPAGES = 2;                                                               00341900
      TMP = NPAGES * 1680;                                                      00342000
      CALL STORAGE_MGT(ADDR(PRO),TMP,1,0);                                      00342100
      APGAREA = COREWORD(ADDR(PRO));                                            00342200
      MISC = MISC_VAL;                                                          00342300
      CALL MONITOR(22,0,COMMTABL_ADDR);   /* INITIALIZE SDFPKG */               00342400
      IF CRETURN ~= 0 THEN DO;                                                  00342500
         SPACE_1;                                                               00342600
         OUTPUT = '*** OPEN ERROR DETECTED FOR SDF PDS -- CORRECT JCL AND RESUBM00342700
IT ***';                                                                        00342800
         GO TO BAIL_OUT;                                                        00342900
      END;                                                                      00343000
      COREWORD(ADDR(DATABUF_BYTE)) = ADDRESS;                                   00343100
      COREWORD(ADDR(DATABUF_HALFWORD)) = ADDRESS;                               00343200
      COREWORD(ADDR(DATABUF_FULLWORD)) = ADDRESS;                               00343300
                                                                                00343400
   /* NOW ALLOCATE VMEM PAGING AREA AND AUGMENT THE SDFPKG PAGING AREA */       00343500
                                                                                00343600
PAGING_ALLOCATE:                                                                00343700
   PROCEDURE BIT(1);                                                            00343800
      J = 0;                                                                    00343900
      DO FOREVER;                                                               00344000
         I = 0;                                                                 00344100
         IF (J = 0)|(NPAGES = 0) THEN DO;                                       00344200
            J = 3;                                                              00344300
            IF VMEM_MAX_PAD < VMEM_LIM_PAGES THEN DO;                           00344400
               IF ~STORAGE_MGT(ADDR(PRO),VMEM_PAGE_SIZE,1,1) THEN DO;           00344500
                  I = 1;                                                        00344600
                  VMEM_MAX_PAD = VMEM_MAX_PAD + 1;                              00344700
                  VMEM_PAD_ADDR(VMEM_MAX_PAD) = COREWORD(ADDR(PRO));            00344800
               END;                                                             00344900
               ELSE DO;                                                         00345000
                  IF VMEM_MAX_PAD < 2 THEN RETURN 1;                            00345100
               END;                                                             00345200
            END;                                                                00345300
         END;                                                                   00345400
         J = J - 1;                                                             00345500
         IF NPAGES > 0 THEN DO;                                                 00345600
            IF ~STORAGE_MGT(ADDR(PRO),1680,1,1) THEN DO;                        00345700
               I = 1;                                                           00345800
               NPAGES = 1;                                                      00345900
               APGAREA = COREWORD(ADDR(PRO));                                   00346000
               CALL MONITOR(22,2);   /* AUGMENT THE SDFPKG PAGING AREA */       00346100
            END;                                                                00346200
            ELSE DO;                                                            00346300
               IF NUMOFPGS < 3 THEN RETURN 1;                                   00346400
               ELSE RETURN 0;                                                   00346500
            END;                                                                00346600
         END;                                                                   00346700
         IF I = 0 THEN RETURN 0;                                                00346800
      END;                                                                      00346900
   END PAGING_ALLOCATE;                                                         00347000
                                                                                00347100
      CALL STORAGE_MGT(ADDR(VMEM_BUFF_ADDR1),SHL(VMEM_PAGE_LIMIT+1,1),0,0);     00347200
      IF GSD_LEVEL > 2 THEN CALL STORAGE_MGT(ADDR(VMEM_BUFF_ADDR2),             00347300
         SHL(VMEM_PAGE_LIMIT+1,1),0,0);                                         00347400
      CALL STORAGE_MGT(ADDR(VMEM_PAD_PAGEID),SHL(VMEM_LIM_PAGES+1,2),0,0);      00347500
      CALL STORAGE_MGT(ADDR(VMEM_PAD_ADDR),SHL(VMEM_LIM_PAGES+1,2),0,0);        00347600
      CALL STORAGE_MGT(ADDR(VMEM_PAD_CNT),SHL(VMEM_LIM_PAGES+1,2),0,0);         00347700
      CALL STORAGE_MGT(ADDR(VMEM_PAD_DISP),SHL(VMEM_LIM_PAGES+1,1),0,0);        00347800
      VMEM_NDX = - 1;                                                           00347900
      DO I = 1 TO VMEM_MAX_FILES;                                               00348000
         VMEM_FILE_LAST_PAGE(I) = - 1;                                          00348100
      END;                                                                      00348200
      VMEM_MAX_CELLSIZE1 = SHR(VMEM_PAGE_SIZE,2)&"FFFFFFFC";                    00348300
      VMEM_MAX_CELLSIZE2 = VMEM_PAGE_SIZE - 8;                                  00348400
      VMEM_MAX_PTR_CNT = SHR(VMEM_MAX_CELLSIZE2 - 8,2);                         00348500
      VMEM_MAX_PAD = -1;   /* FOR PAGING_ALLOCATE */                            00348600
      IF PAGING_ALLOCATE THEN DO;                                               00348700
         MIN_STRING_SIZE = 7500;                                                00348800
         IF PAGING_ALLOCATE THEN GO TO NO_CORE;                                 00348900
      END;                                                                      00349000
                                                                                00349100
      CALL VMEM_OPEN_FILE(1,VMEM_PAGE_LIMIT,VMEM_BUFF_ADDR1,VMEM_NEW);          00349200
      IF GSD_LEVEL > 2 THEN CALL VMEM_OPEN_FILE(2,VMEM_PAGE_LIMIT,              00349300
         VMEM_BUFF_ADDR2,VMEM_NEW);                                             00349400
                                                                                00349500
   /* ALL THAT IS LEFT IS FREE STRING AREA */                                   00349600
                                                                                00349700
      FREE_STRING_SIZE = FREELIMIT - FREEPOINT;                                 00349800
                                                                                00349900
   /* MISCELLANEOUS INITIALIZATIONS */                                          00350000
                                                                                00350100
      COREWORD(ADDR(XUNITS)) = ADDR(FILE1_BUFF(0));                             00350200
      COREWORD(ADDR(XPHASES)) = ADDR(FILE1_BUFF(900));                          00350300
      COREWORD(ADDR(GAP_ADDR1)) = ADDR(FILE1_BUFF(0));                          00350400
      COREWORD(ADDR(GAP_ADDR2)) = ADDR(FILE1_BUFF(450));                        00350500
      COREWORD(ADDR(GLOBAL_GAP_ADDR1)) = ADDR(FILE1_BUFF(900));                 00350600
      COREWORD(ADDR(GLOBAL_GAP_ADDR2)) = ADDR(FILE1_BUFF(1350));                00350700
                                                                                00350800
      IF FC_FLAG THEN DO;                                                       00350900
         MEM_TYPE = ' HALFWORDS';                                               00351000
         MIN_GAP = 2;                                                           00351100
      END;                                                                      00351200
      ELSE DO;                                                                  00351300
         MEM_TYPE = ' BYTES';                                                   00351400
         MIN_GAP = 8;                                                           00351500
      END;                                                                      00351600
      STATE = START_STATE;                                                      00351700
      COMPILING = TRUE;                                                         00351800
      SP = 1;                                                                   00351900
      CP = 0;                                                                   00352000
      TEXT_LIMIT = -1;                                                          00352100
      TEXT = '';                                                                00352200
                                                                                00352300
      CALL INLINE("41",1,0,DWAREA);                                             00352400
      CALL INLINE("88",1,0,0,3);                                                00352500
      CALL INLINE("89",1,0,0,3);                                                00352600
      CALL INLINE("50",1,0,DW);                                                 00352700
      CALL INLINE("50",1,0,DWORG);                                              00352800
      CALL MONITOR(5,DWORG);                                                    00352900
                                                                                00353000
   END INITIALIZE   /* $S */ ; /* $S */                                         00353100
                                                                                00353200
   /* LOGIC TO READ, FILTER, AND STASH AWAY THE CESD INFORMATION */             00353300
                                                                                00353400
CESD_PROCESSING:                                                                00353500
   PROCEDURE;                                                                   00353600
      DECLARE  (THIS_PHASE,CSECT_TYPE,LOC,DEX,I,J,#ENTRIES) BIT(16),            00353700
               (CESD_ESDID,OFFSET,MAX_OFFSET) BIT(16),                          00353800
               (THIS_STRING,FIRST_CHAR,SECOND_CHAR,BUFFER,FFSTRING) CHARACTER,  00353900
               (CSECT_NAME,TS,BASE_NAME) CHARACTER,                             00354000
               (MID,LO_LIM,HI_LIM,RECORD_ADDR) FIXED,                           00354100
               ALIGNED_BUFFER(63) FIXED,                                        00354200
               (CESD_FLAG) BIT(1);                                              00354300
      DECLARE  FFBUFF(1) FIXED INITIAL("FFFFFFFF","FFFFFFFF");                  00354400
      BASED    NODE_H BIT(16);                                                  00354500
                                                                                00354600
INSERT:                                                                         00354700
   PROCEDURE (LINK) BIT(16);                                                    00354800
      DECLARE (SAVE_LINK,LINK,PREV_LINK) BIT(16),                               00354900
              (LESSER) BIT(1),                                                  00355000
              (CHAR_STRING) CHARACTER;                                          00355100
      IF LINK = 0 THEN RETURN #CSECTS;                                          00355200
      SAVE_LINK = LINK;                                                         00355300
      PREV_LINK = 0;                                                            00355400
      DO WHILE LINK ~= 0;                                                       00355500
         TMP = SHR(CSECT_LENGTH(LINK),24);                                      00355600
         CHAR_STRING = STRING("01000000"+ADDR(CSECT_CHAR(SHL(LINK,1))));        00355700
         LESSER = (THIS_STRING<CHAR_STRING);                                    00355800
         IF THIS_PHASE > TMP THEN GO TO NEXT_ENTRY;                             00355900
         IF (THIS_PHASE < TMP) | (LESSER = TRUE) THEN DO;                       00356000
            CSECT_LINK(#CSECTS) = LINK;                                         00356100
            IF PREV_LINK = 0 THEN RETURN #CSECTS;                               00356200
            ELSE GO TO DONE;                                                    00356300
         END;                                                                   00356400
NEXT_ENTRY:                                                                     00356500
         PREV_LINK = LINK;                                                      00356600
         LINK = CSECT_LINK(LINK);                                               00356700
      END;                                                                      00356800
DONE:                                                                           00356900
      CSECT_LINK(PREV_LINK) = #CSECTS;                                          00357000
      RETURN SAVE_LINK;                                                         00357100
   END INSERT;                                                                  00357200
                                                                                00357300
      FFSTRING = STRING("07000000" + ADDR(FFBUFF));                             00357400
      DO FOREVER;                                                               00357500
         BUFFER = INPUT(3);                                                     00357600
         IF BUFFER = '' THEN GO TO END_PDS;                                     00357700
         RECORD_ADDR = ADDR(ALIGNED_BUFFER);                                    00357800
         CALL MOVE(LENGTH(BUFFER),BUFFER,RECORD_ADDR);                          00357900
         OFFSET = 2;                                                            00358000
         MAX_OFFSET = SHR(COREWORD(RECORD_ADDR),16)&"FFFF";                     00358100
         DO WHILE OFFSET < MAX_OFFSET;                                          00358200
            BASE_NAME = STRING("07000000" + RECORD_ADDR + OFFSET);              00358300
            IF BASE_NAME = FFSTRING THEN GO TO END_PDS;                         00358400
            #LIBS = #LIBS + 1;                                                  00358500
            TMP = SHL(#LIBS,3) + AUX_BUFF_ADDR;                                 00358600
            CALL MOVE(8,RECORD_ADDR+OFFSET,TMP);                                00358700
            TMP = COREBYTE(RECORD_ADDR+OFFSET+11);                              00358800
            OFFSET = OFFSET + 12 + 2*(TMP&"1F");                                00358900
         END;                                                                   00359000
      END;                                                                      00359100
END_PDS:                                                                        00359200
                                                                                00359300
   /* IF AN FC LOAD MODULE, USE A POINT TO BYPASS THE SYM CARDS */              00359400
                                                                                00359500
      IF FC_FLAG THEN CALL MONITOR(24,0);                                       00359600
                                                                                00359700
      DO WHILE MONITOR(24,FILE1_BUFF_ADDR);                                     00359800
         RECORD_ADDR = FILE1_BUFF_ADDR;                                         00359900
         IF COREBYTE(RECORD_ADDR) = "20" THEN DO;                               00360000
            CESD_FLAG = TRUE;                                                   00360100
            #ENTRIES = SHR(COREWORD(RECORD_ADDR+4)&"FFFF",4);                   00360200
            CESD_ESDID = (SHR(COREWORD(RECORD_ADDR+4),16)&"FFFF")-1;            00360300
            RECORD_ADDR = RECORD_ADDR - 8;                                      00360400
            DO I = 1 TO #ENTRIES;                                               00360500
               CESD_ESDID = CESD_ESDID + 1;                                     00360600
               RECORD_ADDR = RECORD_ADDR + 16;                                  00360700
               IF (COREBYTE(RECORD_ADDR + 8)&"F") = 0 THEN DO;                  00360800
                  CSECT_TYPE,LOC = 0;                                           00360900
                  CSECT_NAME = STRING("07000000" + RECORD_ADDR);                00361000
                  FIRST_CHAR = STRING(RECORD_ADDR);                             00361100
                  SECOND_CHAR = STRING(RECORD_ADDR + 1);                        00361200
                  IF FIRST_CHAR = DOLLAR_SIGN THEN DO;                          00361300
                     IF SECOND_CHAR = ZEROCHAR THEN CSECT_TYPE = 1;             00361400
                     ELSE CSECT_TYPE = 2;                                       00361500
                     GO TO CONTINUE;                                            00361600
                  END;                                                          00361700
                  IF FIRST_CHAR = AT_SIGN THEN DO;                              00361800
                     CSECT_TYPE = 5;                                            00361900
                     GO TO CONTINUE;                                            00362000
                  END;                                                          00362100
                  IF FIRST_CHAR = SHARP_SIGN THEN DO;                           00362200
                     CSECT_TYPE = CHAR_INDEX(KEY_STRING,SECOND_CHAR) + 1;       00362300
                     IF CSECT_TYPE = 0 THEN GO TO LIB_PROC;                     00362400
                     ELSE GO TO CONTINUE;                                       00362500
                  END;                                                          00362600
                  DEX = CHAR_INDEX(NUM_STRING,SECOND_CHAR);                     00362700
                  IF DEX > -1 THEN CSECT_TYPE = 4;                              00362800
                  ELSE DO;                                                      00362900
LIB_PROC:                                                                       00363000
                     LO_LIM = 1;                                                00363100
                     HI_LIM = #LIBS;                                            00363200
                     DO WHILE LO_LIM <= HI_LIM;                                 00363300
                        MID = SHR(LO_LIM + HI_LIM,1);                           00363400
                        TS = STRING("07000000" + SHL(MID,3) + AUX_BUFF_ADDR);   00363500
                        IF CSECT_NAME = TS THEN GO TO FINISHED;                 00363600
                        ELSE IF CSECT_NAME < TS THEN HI_LIM = MID - 1;          00363700
                        ELSE LO_LIM = MID + 1;                                  00363800
                     END;                                                       00363900
                     GO TO CONTINUE;                                            00364000
FINISHED:                                                                       00364100
                     CSECT_TYPE = 16;                                           00364200
                     GO TO ADD_CSECT;                                           00364300
                  END;                                                          00364400
CONTINUE:                                                                       00364500
                  IF (CSECT_TYPE > 0)&(CSECT_TYPE < 14) THEN DO;                00364600
                     BASE_NAME = STRING("05000002" + RECORD_ADDR);              00364700
                     BASE_NAME = DBL_SHARP_SIGN||BASE_NAME;                     00364800
                     DO J = 1 TO #UNITS;                                        00364900
                        LOC = #UNITS-J+1;                                       00365000
                        IF SDF_NAMES(LOC) = BASE_NAME THEN                      00365100
                           GO TO MATCH;                                         00365200
                     END;                                                       00365300
                     CALL MOVE(8,BASE_NAME,SDFNAM);                             00365400
                     CALL MONITOR(22,"80000007");                               00365500
                     SELECTED_UNIT = 0;                                         00365600
                     IF CRETURN ~= 0 THEN DO;                                   00365700
                        CSECT_TYPE = 0;                                         00365800
                        OUTPUT = '*** SDF '||BASE_NAME||' WAS NOT FOUND -- CSECT00365900
 '||CSECT_NAME||' WILL BE ASSUMED NONHAL';                                      00366000
                        GO TO ADD_CSECT;                                        00366100
                     END;                                                       00366200
                     ELSE DO;                                                   00366300
                        #UNITS = #UNITS + 1;                                    00366400
                        LOC = #UNITS;                                           00366500
                        SDF_NAMES(LOC) = BASE_NAME;                             00366600
                        OUTPUT = '*** SDF '||BASE_NAME||' WAS FOUND!!!';        00366610
                        COREWORD(ADDR(NODE_H)) = ADDRESS;                       00366700
                        IF (NODE_H(0)&"1000") ~= 0 THEN DO;                     00366800
                           IF FC_FLAG = FALSE THEN DO;                          00366900
                              UNIT_FLAGS(LOC) = UNIT_FLAGS(LOC) | "0001";       00367000
                              TS = 'LOAD MODULE IS DECLARED 360 BUT SDF '||     00367100
                                 BASE_NAME||' IS FC';                           00367200
                              CALL ERROR(TS,4);                                 00367300
                           END;                                                 00367400
                        END;                                                    00367500
                        ELSE DO;                                                00367600
                           IF FC_FLAG THEN DO;                                  00367700
                              UNIT_FLAGS(LOC) = UNIT_FLAGS(LOC) | "0001";       00367800
                              TS = 'LOAD MODULE IS DECLARED FC BUT SDF '||      00367900
                                 BASE_NAME||' IS 360';                          00368000
                              CALL ERROR(TS,4);                                 00368100
                           END;                                                 00368200
                        END;                                                    00368300
                        IF (NODE_H(0)&"0002") = 0 THEN                          00368400
                           UNIT_FLAGS(LOC) = UNIT_FLAGS(LOC)|"0002";            00368500
                     END;                                                       00368600
MATCH:                                                                          00368700
                     CSECT_ID(#CSECTS + 1) = LOC;                               00368800
                  END;                                                          00368900
ADD_CSECT:                                                                      00369000
                  #CSECTS = #CSECTS + 1;                                        00369100
                  CSECT_ADDR(#CSECTS) = ((COREWORD(RECORD_ADDR                  00369200
                     + 8)) & "FFFFFF") | (SHL(CSECT_TYPE,24));                  00369300
                  CSECT_LENGTH(#CSECTS) = (COREWORD(RECORD_ADDR + 12));         00369400
                  THIS_PHASE = SHR(CSECT_LENGTH(#CSECTS),24);                   00369500
                  IF THIS_PHASE > MAX_PHASE THEN MAX_PHASE = THIS_PHASE;        00369600
                  CSECT_CHAR(SHL(#CSECTS,1)) = COREWORD(RECORD_ADDR);           00369700
                  CSECT_CHAR(SHL(#CSECTS,1)+1) = COREWORD(RECORD_ADDR + 4);     00369800
                  THIS_STRING = STRING("01000000" + RECORD_ADDR);               00369900
                  CSECT_SORT(#CSECTS) = #CSECTS;                                00370000
                  CSECT_SORTX(#CSECTS) = #CSECTS;                               00370100
                  CSECT_SORTZ(#CSECTS) = #CSECTS;                               00370200
                  CSECT_ESDID(#CSECTS) = CESD_ESDID;                            00370300
                  DO CASE CSECT_TYPE;                                           00370400
                     DO;    /* NONHAL CSECT   */                                00370500
                        NONHAL = INSERT(NONHAL);                                00370600
                        CSECT_ID(#CSECTS) = 0;                                  00370700
                     END;                                                       00370800
                     DO;    /* $0  PROGRAM     */                               00370900
                        #C$0(LOC) = INSERT(#C$0(LOC));                          00371000
                     END;                                                       00371100
                     DO;    /*    TASK         */                               00371200
                        TASK_TAB(LOC) = INSERT(TASK_TAB(LOC));                  00371300
                     END;                                                       00371400
                     DO;    /* #C  COMSUB    */                                 00371500
                        #C$0(LOC) = INSERT(#C$0(LOC));                          00371600
                     END;                                                       00371700
                     DO;    /* INTERNAL PROC */                                 00371800
                        PROC_TAB(LOC) = INSERT(PROC_TAB(LOC));                  00371900
                     END;                                                       00372000
                     DO;    /* @   STACK    */                                  00372100
                        STACK_TAB(LOC) = INSERT(STACK_TAB(LOC));                00372200
                     END;                                                       00372300
                     DO;    /* #D  DECL DATA */                                 00372400
                        #D#P(LOC) = INSERT(#D#P(LOC));                          00372500
                     END;                                                       00372600
                     DO;    /* #P  COMPOOL    */                                00372700
                        #D#P(LOC) = INSERT(#D#P(LOC));                          00372800
                     END;                                                       00372900
                     DO;    /* #F  FSIM    */                                   00373000
                        #F#R(LOC) = INSERT(#F#R(LOC));                          00373100
                     END;                                                       00373200
                     DO;    /* #T  COST/USE  */                                 00373300
                        #T#Z(LOC) = INSERT(#T#Z(LOC));                          00373400
                     END;                                                       00373500
                     DO;    /* #Z   ZCONS   */                                  00373600
                        #T#Z(LOC) = INSERT(#T#Z(LOC));                          00373700
                     END;                                                       00373800
                     DO;    /* #R   REMOTE  */                                  00373900
                        #F#R(LOC) = INSERT(#F#R(LOC));                          00374000
                     END;                                                       00374100
                     DO;    /*  PDE     */                                      00374200
                        #E(LOC) = INSERT(#E(LOC));                              00374300
                     END;                                                       00374400
                     DO;    /* EXCLUSIVE */                                     00374500
                        #X(LOC) = INSERT(#X(LOC));                              00374600
                     END;                                                       00374700
                     DO;    /* #Q (QCON)  */                                    00374800
                        QCON = INSERT(QCON);                                    00374900
                        CSECT_ID(#CSECTS) = 0;                                  00375000
                     END;                                                       00375100
                     DO;    /* #L (LIB DATA) */                                 00375200
                        LIBRARY_DATA = INSERT(LIBRARY_DATA);                    00375300
                        CSECT_ID(#CSECTS) = 0;                                  00375400
                     END;                                                       00375500
                     DO;    /* LIBRARY CODE */                                  00375600
                        LIBRARY = INSERT(LIBRARY);                              00375700
                        CSECT_ID(#CSECTS) = 0;                                  00375800
                     END;                                                       00375900
                  END;                                                          00376000
               END;                                                             00376100
            END;                                                                00376200
            IF #ENTRIES < 15 THEN GO TO END_READ;                               00376300
         END;                                                                   00376400
         ELSE IF CESD_FLAG THEN GO TO END_READ;                                 00376500
      END;                                                                      00376600
END_READ:                                                                       00376700
      BUFFER = '';                                                              00376800
                                                                                00376900
   /* CLOSE THE LOAD MODULE PDS  */                                             00377000
                                                                                00377100
      CALL MONITOR(3,8);                                                        00377200
                                                                                00377300
   END CESD_PROCESSING    /*  $S  */ ; /*  $S  */                               00377400
                                                                                00377500
BUILD_TAPE:                                                                     00377600
   PROCEDURE (MODE);                                                            00377700
      DECLARE (ACTION,MODE) BIT(16),                                            00377800
              (SAVE_#COPIES,SAVE_CPYSIZE,FLAG) FIXED;                           00377900
                                                                                00378000
      BASED   NODE_F FIXED,                                                     00378100
              NODE_H BIT(16),                                                   00378200
              NODE_B BIT(8);                                                    00378300
                                                                                00378400
      CALL ZERO_256(ADLBUFF_ADDR,80);   /* ZERO RECORD BUFFER */                00378500
      RECORD# = RECORD# + 1;                                                    00378600
      RECORD_REC# = SHL(MODE,24) + RECORD#;                                     00378700
      ACTION = MODE;                                                            00378800
      IF ACTION > 4 THEN ACTION = 5;                                            00378900
      DO CASE ACTION;                                                           00379000
         DO;     /* INITIAL CALL */                                             00379100
            CALL MOVE(32,X72,RECORD_NAME);                                      00379200
            TMP = LENGTH(TITLE);                                                00379300
            IF TITLE ~= '' THEN CALL MOVE(TMP,TITLE,RECORD_NAME);               00379400
            RECORD_DATE = DATE;                                                 00379500
            RECORD_TIME = TIME;                                                 00379600
         END;                                                                   00379700
         DO;     /* UNIT CALL */                                                00379800
            RECORD_RECID = GOT_ID;                                              00379900
            CALL MOVE(32,GOT_NAME,RECORD_NAME);                                 00380000
         END;                                                                   00380100
         DO;     /* BLOCK CALL */                                               00380200
            RECORD_RECID = GOT_ID;                                              00380300
            CALL MOVE(32,GOT_NAME,RECORD_NAME);                                 00380400
         END;                                                                   00380500
         DO;     /* END OF DIRECTORY */                                         00380600
         END;                                                                   00380700
         DO;     /* FINAL CALL */                                               00380800
         END;                                                                   00380900
         DO;     /* DATA CALL */                                                00381000
            COREWORD(ADDR(NODE_F)) = GOT_CELL_ADDR;                             00381100
            COREWORD(ADDR(NODE_H)) = GOT_CELL_ADDR;                             00381200
            COREWORD(ADDR(NODE_B)) = GOT_CELL_ADDR;                             00381300
            FLAG = NODE_F(2);                                                   00381400
            RECORD_RECID = GOT_RECORD;                                          00381500
            CALL MOVE(32,GOT_NAME,RECORD_NAME);                                 00381600
            RECORD_UNITID = GOT_UNIT;                                           00381700
            RECORD_BLKID = NODE_H(0);                                           00381800
            RECORD_VCLASS = NODE_B(6);                                          00381900
            RECORD_VTYPE = NODE_B(7);                                           00382000
            IF MODE=10 THEN RECORD_STACKID = SHL(0,9) | (NODE_H(8)&"7F");       00382100
            RECORD_FLAGS = FLAG;                                                00382200
            RECORD_ADDR1 = SHL(GOT_PHASE,24) + GOT_ADDR;                        00382300
            IF MODE = 5 THEN RECORD_ADDR2 = GOT_ADDR1;                          00382400
            ELSE RECORD_SIZE = NODE_F(5) & "FFFFFF";                            00382500
            IF NODE_B(2) ~= 0 THEN RECORD_BIAS = NODE_F(SHR(NODE_B(2),2));      00382600
            RECORD_MISC = NODE_H(9);                                            00382700
            IF MODE = 9 THEN DO;                                                00382800
               RECORD_#COPIES = GOT_COPIES;                                     00382900
               RECORD_CPYSIZE = GOT_COPY_SIZE;                                  00383000
            END;                                                                00383100
            ELSE IF MODE = 7 THEN DO;                                           00383200
               SAVE_#COPIES,TMP = NODE_H(SHR(NODE_B(4),1)+1);                   00383300
               SAVE_CPYSIZE = (NODE_F(5)&"FFFFFF")/TMP;                         00383400
               RECORD_#COPIES = SAVE_#COPIES;                                   00383500
               RECORD_CPYSIZE = SAVE_CPYSIZE;                                   00383600
            END;                                                                00383700
            ELSE IF MODE = 8 THEN DO;                                           00383800
               RECORD_#COPIES = SAVE_#COPIES;                                   00383900
               RECORD_CPYSIZE = SAVE_CPYSIZE;                                   00384000
            END;                                                                00384100
            IF (NODE_B(4)~=0)&(MODE~=7) THEN DO;                                00384200
               TMP = SHR(NODE_B(4),1);                                          00384300
               RECORD_#DIMS = NODE_H(TMP) & "FF";                               00384400
               RECORD_DIM1 = NODE_H(TMP + 1);                                   00384500
               IF RECORD_#DIMS > 1 THEN RECORD_DIM2 = NODE_H(TMP + 2);          00384600
               IF RECORD_#DIMS > 2 THEN RECORD_DIM3 = NODE_H(TMP + 3);          00384700
            END;                                                                00384800
         END;                                                                   00384900
      END;                                                                      00385000
      OUTPUT(4) = RECORD_BUFFER;                                                00385100
   END BUILD_TAPE;                                                              00385200
                                                                                00385300
SDF_PROCESSING:                                                                 00385400
   PROCEDURE;                                                                   00385500
      DECLARE (REMOTE_TEMP,NUM_LINES,BLK#,I,J,K,KK) BIT(16),                    00385600
              (TPHASE_PTR,NEXT1,NEW_LINK,SAVE_LINK,STACK_INX,L,M) BIT(16),      00385700
             (MAP_DEX,MAP_TYPE,PH#,Q,QQ,QQQ,BASE_SYMB,UNIT_NO) BIT(16),         00385800
             (LEN,STRUC0,STRUC1,STRUC2,LEVEL,SYMB1,SYMB2,KLIM1,KLIM2) BIT(16),  00385900
             (SAVE_STMT,ITEM,L1,L2,M1,M2,ARRAY0,ARRAY1,ARRAY2,ARRAY3) BIT(16),  00386000
             (NEST_LEVEL,#CONFIG_CSECTS) BIT(16),                               00386100
             (CSECT_TYPE,KEY_CHARS,SBLK,SLIM1,SLIM2,COUNT) BIT(16),             00386200
             (DIS_TEMP,SAVE_STMTX,ADDR_LINK) BIT(16),                           00386300
             (BIT_SHIFT,NUM_BITS,NUM_PER_LINE,#ENTRIES,CUR_CSECT_NDX) BIT(16),  00386400
             (SYM_CSECT_ID,TEMPLATE_LINK,SLINK,BASE_BLOCK,SYM_DATA_DEX) BIT(16),00386500
             (SYM_ORG,SYM_NAME_LEN,NDATA_TYPE,SYM_DATA_TYPE,SYM_SP) BIT(16),    00386600
             (QTYPE,CCW_ADDR_AUG,LMOD_REC_TYPE,CNTL_CNT,RLD_CNT) BIT(16),       00386700
             (NAME_INX,LIT_VERSION) BIT(16),                                    00386800
             (SFLAG,SCLASS,STYPE,OLD_STYPE,BLK_CLASS,CLASS,TYPE) BIT(8),        00386900
             (ERROR_KEY_FLAG,TEXT_FLAG,EXCLUSIVE,RLABEL,SIGNAL) BIT(1),         00387000
             (NOTRACE_FLAG,NEW_CSECT,VALID_FLAG) BIT(1),                        00387100
             (SYM_STACK_FLAG,INITIAL_SYMBOL,TEMPLATING) BIT(1),                 00387200
             (SYM_DSECT_FLAG,SYM_CSECT_FLAG,SYM_MULT_FLAG,SYM_SCAL_FLAG) BIT(1),00387300
             INIT BIT(1) INITIAL(1),                                            00387400
             (SRN_STRING,INCL_STRING,UNIT_STRING,SYMBOL_STRING) CHARACTER,      00387500
             (MAP_HDR_STRING) CHARACTER,                                        00387600
             (MAP_HDR,S1,S2,S3,S4,S5,ALT_SDF,SAVE_NAME,FLAG_STRING) CHARACTER,  00387700
             (WORK_STRING,CSECT_NAME,CONTROL_CARD,SDF_TITLE) CHARACTER,         00387800
             (HEX_SIZE,SIZE_STRING,BASIC_NAME,PREV_CHAR,THIS_CHAR) CHARACTER,   00387900
            (LIT_STRING1,LIT_STRING2,SYM_NAME,REAL_NAME,PATTERN_CHAR) CHARACTER,00388000
             ZERO_CHAR CHARACTER INITIAL ('00000000000000000000000000000000'),  00388100
             X_CHAR CHARACTER INITIAL ('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),     00388200
             TS(10) CHARACTER,                                                  00388300
             (OLD_SYM_ADDR,BUFF_ADDR,SDF_DATE,SDF_TIME) FIXED,                  00388400
             (PTR,ADDR1,ADDR2,TEMP1,TEMP2,TEMP3,SAVE_PNTR,SADDR,SEXTENT) FIXED, 00388500
             (LIT_PTR,LIT_ADDR,SYMB_PTR,SAVE_ADDR1,SAVE_ADDR2) FIXED,           00388600
             (HOLD_ADDR,TEMP_ADDR) FIXED,                                       00388700
             (PH_TEMP,PTR1,CODE_SIZE,STACK_SIZE,DATA_SIZE,ADDR_CHAIN) FIXED,    00388800
             (CUR_ADDR,ADDR_BUMP,G_TEMP,MAP_ADDR1,MAP_ADDR2) FIXED,             00388900
            (HOLD_PTR,RECORD_ADDR,ADDR_LIM,SYM_ADDR,SYM_MULT,SYM_SCAL) FIXED,   00389000
             (TEXT_CELL_PTR,RESV_LINK,BIT_VALUE,BIT_MASK,SYM_DATA_LEN) FIXED,   00389100
             WORK(9) FIXED,                                                     00389200
             (RLD_ADDR,CCW_ADDR,EXTENSION_PTR,TEXT_SIZE,FLAG,FLAG1) FIXED,      00389300
             (TEXT_ADDRESS,CSECT_CNT,OLD_ADDR,BASE_ADDR) FIXED,                 00389400
             (LINK,SAVE_CELL_ADDR,CURRENT_BASE,SAVE_ADDR,ADDR_INC) FIXED;       00389500
                                                                                00389600
DECLARE SYM_NAME_BUFF(1) FIXED INITIAL("40404040","40404040");                  00389700
DECLARE CNTL_BUFF1(59) BIT(16);                                                 00389800
DECLARE CNTL_BUFF2(59) BIT(16);                                                 00389900
                                                                                00390000
DECLARE NEST_STMT(20) BIT(16);                                                  00390100
DECLARE NEST_STYPE(20) BIT(8);                                                  00390200
                                                                                00390300
DECLARE ADDR_AUG101(19) BIT(16) INITIAL(0,1,0,2,2,2,1,0,0,2,1,4,4,4,2,          00390400
      0,0,1,1,2);                                                               00390500
DECLARE ADDR_AUG360(19) BIT(16) INITIAL(0,2,0,4,4,4,2,0,0,4,1,8,8,8,4,          00390600
      0,0,1,2,4);                                                               00390700
DECLARE DATA_TYPES(19) BIT(16) INITIAL(0,1,2,5,5,5,3,0,0,1,1,6,6,6,             00390800
      4,0,0,1,0,0);                                                             00390900
DECLARE PER_LINE(19) BIT(16) INITIAL(0,16,0,5,5,5,12,0,0,8,24,3,3,3,            00391000
      8,0,0,16,1,1);                                                            00391100
DECLARE DATA_OK(19) BIT(8) INITIAL(0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,0,0,1,1,1);    00391200
                                                                                00391300
DECLARE      STRUC_NEST LITERALLY '12';                                         00391400
ARRAY        TPL_STACK1(STRUC_NEST) BIT(16),                                    00391500
             TPL_STACK2(STRUC_NEST) FIXED;                                      00391600
DECLARE NAME_ARRAY(STRUC_NEST) CHARACTER;                                       00391700
                                                                                00391800
BASED        (NODE_H,NODE_H1,NODE_H2) BIT(16),                                  00391900
             (NODE_B,NODE_B1,NODE_B2) BIT(8),                                   00392000
             (NODE_F,NODE_F1,NODE_F2) FIXED;                                    00392100
                                                                                00392200
EXTRACT_REPLACE_TEXT:                                                           00392300
   PROCEDURE (PTR,BUFF_ADDR) BIT(16);                                           00392400
      DECLARE (PTR,BUFF_ADDR) FIXED, (#BYTES,I,J,K,CNT) BIT(16);                00392500
      BASED NODE_H BIT(16), NODE_B BIT(8);                                      00392600
      DECLARE INCR_BUFF LITERALLY 'IF #BYTES<6216 THEN DO; #BYTES=#BYTES + 1;   00392700
         BUFF_ADDR = BUFF_ADDR + 1; END';                                       00392800
                                                                                00392900
      #BYTES = 0;                                                               00393000
      DO WHILE PTR ~= 0;                                                        00393100
         PNTR = PTR;                                                            00393200
         CALL MONITOR(22,5);                                                    00393300
         PTR = COREWORD(ADDRESS);                                               00393400
         COREWORD(ADDR(NODE_H)) = ADDRESS;                                      00393500
         COREWORD(ADDR(NODE_B)) = ADDRESS + 6;                                  00393600
         CNT = NODE_H(2);                                                       00393700
         DO I = 0 TO CNT - 1;                                                   00393800
            J = NODE_B(I);                                                      00393900
            IF J = "EE" THEN DO;                                                00394000
               I = I + 1;                                                       00394100
               J = NODE_B(I);                                                   00394200
               IF J = 0 THEN RETURN 0;                                          00394300
               DO K = 1 TO J + 1;                                               00394400
                  COREBYTE(BUFF_ADDR) = "40";                                   00394500
                  INCR_BUFF;                                                    00394600
               END;                                                             00394700
            END;                                                                00394800
            ELSE DO;                                                            00394900
               IF J = BYTE(DBL_QUOTE) THEN DO;                                  00395000
                  COREBYTE(BUFF_ADDR) = J;                                      00395100
                  INCR_BUFF;                                                    00395200
               END;                                                             00395300
               COREBYTE(BUFF_ADDR) = J;                                         00395400
               INCR_BUFF;                                                       00395500
            END;                                                                00395600
         END;                                                                   00395700
       END;                                                                     00395800
      RETURN #BYTES;                                                            00395900
   END EXTRACT_REPLACE_TEXT;                                                    00396000
                                                                                00396100
PRINT_REPLACE_TEXT:                                                             00396200
   PROCEDURE (STR,MAX_COL,BUFF_ADDR,LEN);                                       00396300
      DECLARE (BUFF_ADDR) FIXED, (MAX_COL,LEN,LEN_AVAIL) BIT(16),               00396400
            (STR,LEFT_FILL,TS) CHARACTER;                                       00396500
                                                                                00396600
      LEFT_FILL = SUBSTR(X72,0,LENGTH(STR));                                    00396700
      TS = STR||DBL_QUOTE;                                                      00396800
      DO WHILE LEN > 0;                                                         00396900
         LEN_AVAIL = MAX_COL - LENGTH(TS);                                      00397000
         IF (LEN + 1) <= LEN_AVAIL THEN DO;                                     00397100
            OUTPUT = TS||STRING(SHL(LEN-1,24)+BUFF_ADDR)||DBL_QUOTE;            00397200
            RETURN;                                                             00397300
         END;                                                                   00397400
         ELSE DO;                                                               00397500
            OUTPUT = TS||STRING(SHL(LEN_AVAIL-1,24) + BUFF_ADDR);               00397600
            BUFF_ADDR = BUFF_ADDR + LEN_AVAIL;                                  00397700
            LEN = LEN - LEN_AVAIL;                                              00397800
            TS = LEFT_FILL;                                                     00397900
         END;                                                                   00398000
      END;                                                                      00398100
   END PRINT_REPLACE_TEXT;                                                      00398200
                                                                                00398300
GET_CSECT_NDX_BY_ADDR:                                                          00398400
   PROCEDURE (MEM_ADDR) FIXED;                                                  00398500
   DECLARE (LO_LIM,HI_LIM,MID,MEM_ADDR,ADDR1,ADDR2) FIXED;                      00398600
      IF (MEM_ADDR>=BASE_ADDR)&(MEM_ADDR<=OLD_ADDR) THEN                        00398700
         RETURN CUR_CSECT_NDX;                                                  00398800
      LO_LIM = 1;                                                               00398900
      HI_LIM = #CONFIG_CSECTS;                                                  00399000
      DO WHILE LO_LIM <= HI_LIM;                                                00399100
         MID = SHR(HI_LIM+LO_LIM,1);                                            00399200
         ADDR1 = CSECT_ADDR(CSECT_SORTY(MID))&"FFFFFF";                         00399300
         IF MEM_ADDR = ADDR1 THEN GO TO FINISHED;                               00399400
         ELSE IF MEM_ADDR < ADDR1 THEN HI_LIM = MID - 1;                        00399500
         ELSE DO;                                                               00399600
            ADDR2 = ADDR1 - 1 + (CSECT_LENGTH(CSECT_SORTY(MID))&"FFFFFF");      00399700
            IF MEM_ADDR <= ADDR2 THEN GO TO FINISHED;                           00399800
            ELSE LO_LIM = MID + 1;                                              00399900
         END;                                                                   00400000
      END;                                                                      00400100
      RETURN 0;                                                                 00400200
FINISHED:                                                                       00400300
      RETURN CSECT_SORTY(MID);                                                  00400400
   END GET_CSECT_NDX_BY_ADDR;                                                   00400500
                                                                                00400600
GET_CSECT_NDX_BY_ESDID:                                                         00400700
   PROCEDURE (ESDID) FIXED;                                                     00400800
   DECLARE (LO_LIM,HI_LIM,MID,ESDID,ESDIDX) FIXED;                              00400900
      LO_LIM = 1;                                                               00401000
      HI_LIM = #CSECTS;                                                         00401100
      DO WHILE LO_LIM <= HI_LIM;                                                00401200
         MID = SHR(HI_LIM+LO_LIM,1);                                            00401300
         ESDIDX = CSECT_ESDID(CSECT_SORTZ(MID));                                00401400
         IF ESDID = ESDIDX THEN GO TO FINI;                                     00401500
         ELSE IF ESDID < ESDIDX THEN HI_LIM = MID - 1;                          00401600
         ELSE LO_LIM = MID + 1;                                                 00401700
      END;                                                                      00401800
      RETURN 0;                                                                 00401900
FINI:                                                                           00402000
      RETURN CSECT_SORTZ(MID);                                                  00402100
   END GET_CSECT_NDX_BY_ESDID;                                                  00402200
                                                                                00402300
GET_CSECT_NDX_BY_NAME:                                                          00402400
   PROCEDURE (NAME) FIXED;                                                      00402500
      DECLARE (LO_LIM,HI_LIM,MID) FIXED,                                        00402600
               (NAME,NAMEX) CHARACTER;                                          00402700
      LO_LIM = 1;                                                               00402800
      HI_LIM = #CSECTS;                                                         00402900
      DO WHILE LO_LIM <= HI_LIM;                                                00403000
         MID = SHR(HI_LIM+LO_LIM,1);                                            00403100
         TMP = SHL(CSECT_SORTX(MID),1);                                         00403200
         NAMEX = STRING("07000000" + ADDR(CSECT_CHAR(TMP)));                    00403300
         IF NAME = NAMEX THEN GO TO BEENDET;                                    00403400
         ELSE IF NAME < NAMEX THEN HI_LIM = MID-1;                              00403500
         ELSE LO_LIM = MID+1;                                                   00403600
      END;                                                                      00403700
      RETURN 0;                                                                 00403800
BEENDET:                                                                        00403900
      RETURN CSECT_SORTX(MID);                                                  00404000
   END GET_CSECT_NDX_BY_NAME;                                                   00404100
                                                                                00404200
EMIT_HDG:                                                                       00404300
   PROCEDURE (HEADING);                                                         00404400
      DECLARE (HEADING,TS) CHARACTER, J BIT(16);                                00404500
      J = LENGTH(HEADING);                                                      00404600
      TS = SUBSTR(X72,0,63-SHR(J,1))||HEADING;                                  00404700
      OUTPUT(1) = TWO||TS;                                                      00404800
      OUTPUT(1) = ONE;                                                          00404900
   END EMIT_HDG;                                                                00405000
                                                                                00405100
GSD_HDG:                                                                        00405200
   PROCEDURE (EXT);                                                             00405300
      DECLARE (EXT,TS) CHARACTER;                                               00405400
      TS = 'G L O B A L   S Y M B O L   D I R E C T O R Y'||EXT;                00405500
      CALL EMIT_HDG(TS);                                                        00405600
      OUTPUT = '     (CROSS REFERENCE KEY:  4 = ASSIGNMENT, 2 = REFERENCE, 1 = S00405700
UBSCRIPT USE, 0 = DEFINITION)';                                                 00405800
      SPACE_1;                                                                  00405900
   END GSD_HDG;                                                                 00406000
                                                                                00406100
TPL_ERR:                                                                        00406200
   PROCEDURE (ERRTYPE);                                                         00406300
      DECLARE ERRTYPE BIT(16), (T1,T2,T3) CHARACTER;                            00406400
      DECLARE MSG_ARRAY(9) CHARACTER INITIAL('CLASS MISMATCH:   ',              00406500
         'TYPE MISMATCH:    ', 'FLAG MISMATCH:    ', 'ADDRESS MISMATCH: ',      00406600
         'MISC MISMATCH:    ', 'LOCK GRP MISMATCH:', 'SIZE MISMATCH:    ',      00406700
         'ARRAYNESS/COPINESS MISMATCH:','REPLACE TEXT MISMATCH:',               00406800
         'LITERAL VALUE MISMATCH:');                                            00406900
                                                                                00407000
DECLARE INCLUDE_CHARSTRING CHARACTER INITIAL ('    INCLUDE SYMBOL:  '),         00407100
        COMPOOL_CHARSTRING CHARACTER INITIAL ('    COMPOOL SYMBOL:  ');         00407200
                                                                                00407300
      IF ERROR_KEY_FLAG = FALSE THEN DO;                                        00407400
         ERROR_KEY_FLAG = TRUE;                                                 00407500
         OUTPUT(1) = ONE;                                                       00407600
         SPACE_1;                                                               00407700
         OUTPUT = 'FLAG MISMATCH KEY:';                                         00407800
         SPACE_1;                                                               00407900
         OUTPUT = '80000000   COMPOOL VARIABLE';                                00408000
         OUTPUT = '40000000   INPUT PARAMETER';                                 00408100
         OUTPUT = '20000000   ASSIGN PARAMETER';                                00408200
         OUTPUT = '10000000   TEMPORARY VARIABLE';                              00408300
         OUTPUT = '08000000   AUTOMATIC';                                       00408400
         OUTPUT = '04000000   NAME VARIABLE';                                   00408500
         OUTPUT = '02000000   STRUCTURE TEMPLATE NAME';                         00408600
         OUTPUT = '01000000   UNQUALIFIED STRUCTURE';                           00408700
         OUTPUT = '00800000   REENTRANT';                                       00408800
         OUTPUT = '00400000   DENSE';                                           00408900
         OUTPUT = '00200000   CONSTANT';                                        00409000
         OUTPUT = '00100000   ACCESS CONTROLLED';                               00409100
         OUTPUT = '00080000   INDIRECT';                                        00409200
         OUTPUT = '00040000   LATCHED';                                         00409300
         OUTPUT = '00020000   LOCKED';                                          00409400
         OUTPUT = '00010000   REMOTE';                                          00409500
         OUTPUT = '00008000   OFFSET SUPPLIED';                                 00409600
         OUTPUT = '00004000   INITIAL';                                         00409700
         OUTPUT = '00002000   RIGID';                                           00409800
         OUTPUT = '00001000   LITERAL';                                         00409900
         OUTPUT = '00000800   EXTERNAL';                                        00410000
         OUTPUT = '00000400   STACK VARIABLE';                                  00410100
         OUTPUT = '00000200   LOCAL BLOCK DATA';                                00410200
         OUTPUT = '00000100   VARIABLE IS EQUATED TO';                          00410300
         OUTPUT = '00000080   NONHAL BLOCK LABEL';                              00410400
         OUTPUT = '00000040   EXCLUSIVE';                                       00410500
         OUTPUT = '00000020   FCDATA';                                          00410600
         OUTPUT = '00000010   MISC_NAME_FLAG';                                  00410700
         OUTPUT = '00000008   MACRO_ARG_FLAG';                                  00410800
         DSPACE;                                                                00410900
      END;                                                                      00411000
      IF SIGNAL = FALSE THEN DO;                                                00411100
         IF (ERRTYPE = 0)&((UNIT_FLAGS(I)&"0020")~=0) THEN RETURN;              00411200
         SIGNAL = TRUE;                                                         00411300
         CALL ERROR('COMPOOL TEMPLATE MISMATCH',2);                             00411400
         T2 = SYMBOL_STRING;                                                    00411500
         IF CLASS = 1 THEN T1 = 'VARIABLE ';                                    00411600
         ELSE IF CLASS = 2 THEN T1 = PROC_TYPES(TYPE)||ATTR_LABEL;              00411700
         ELSE IF CLASS = 3 THEN TS = '  FUNCTION LABEL ';                       00411800
         ELSE DO;                                                               00411900
            IF SUBSTR(T2,0,1) = X1 THEN TS = 'STRUCTURE TEMPLATE';              00412000
            ELSE T1 = 'TERMINAL/MINOR NODE ';                                   00412100
         END;                                                                   00412200
         OUTPUT = T1||T2||' INCLUDED IN UNIT '||                                00412300
         UNIT_NAMES(I)||' DOES NOT MATCH SYMBOL IN COMPOOL '||UNIT_STRING;      00412400
         IF ERRTYPE ~= 0 THEN DO;                                               00412500
            IF ERRTYPE < 8 THEN                                                 00412600
            OUTPUT = '                            INCLUDED SYMBOL         COMPOO00412700
L SYMBOL';                                                                      00412800
            SPACE_1;                                                            00412900
         END;                                                                   00413000
         ELSE DO;                                                               00413100
            OUTPUT = '     SYMBOL COULD NOT BE FOUND IN CURRENT COMPOOL';       00413200
            UNIT_FLAGS(I) = UNIT_FLAGS(I) | "0004";                             00413300
            RETURN;                                                             00413400
         END;                                                                   00413500
         UNIT_FLAGS(I) = UNIT_FLAGS(I)|"0004";                                  00413600
      END;                                                                      00413700
      DO CASE (ERRTYPE - 1);                                                    00413800
         DO;     /* CLASS MISMATCH */                                           00413900
            T2 = SYMBOL_CLASSES(CLASS);                                         00414000
            T3 = SYMBOL_CLASSES(NODE_B2(6));                                    00414100
            T2 = SUBSTR(T2,2);                                                  00414200
            T3 = SUBSTR(T3,2);                                                  00414300
         END;                                                                   00414400
         DO;     /* TYPE MISMATCH */                                            00414500
            IF CLASS = 2 THEN T2 = PROC_TYPES(TYPE);                            00414600
            ELSE T2 = SYMBOL_TYPES(TYPE);                                       00414700
            IF NODE_B2(6) = 2 THEN T3 = PROC_TYPES(NODE_B2(7));                 00414800
            ELSE T3 = SYMBOL_TYPES(NODE_B2(7));                                 00414900
            T2 = SUBSTR(T2,2);                                                  00415000
            T3 = SUBSTR(T3,2);                                                  00415100
         END;                                                                   00415200
         DO;     /* FLAG MISMATCH */                                            00415300
            T2 = HEX8(FLAG&"FEDE36E7");                                         00415400
            T3 = HEX8(NODE_F2(2)&"FEDE36E7");                                   00415500
         END;                                                                   00415600
         DO;     /* ADDRESS MISMATCH */                                         00415700
            T2 = HEX8(NODE_F(3)&"FFFFFF");                                      00415800
            T3 = HEX8(NODE_F2(3)&"FFFFFF");                                     00415900
         END;                                                                   00416000
         DO;     /* MISC MISMATCH */                                            00416100
            T2 = HEX4(NODE_H(9));                                               00416200
            T2 = X4||T2;                                                        00416300
            T3 = HEX4(NODE_H2(9));                                              00416400
            T3 = X4||T3;                                                        00416500
         END;                                                                   00416600
         DO;     /* LOCK GROUP MISMATCH */                                      00416700
            T2 = LPAD(NODE_B(20),8);                                            00416800
            T3 = LPAD(NODE_B2(20),8);                                           00416900
         END;                                                                   00417000
         DO;     /* SIZE MISMATCH */                                            00417100
            T2 = LPAD(NODE_F(5)&"FFFFFF",8);                                    00417200
            T3 = LPAD(NODE_F2(5)&"FFFFFF",8);                                   00417300
         END;                                                                   00417400
         DO;     /* ARRAY ATTRIBUTE MISMATCH */                                 00417500
            GO TO SET_T2_T3;                                                    00417600
         END;                                                                   00417700
         DO;     /* REPLACE TEXT MISMATCH */                                    00417800
            GO TO SET_T2_T3;                                                    00417900
         END;                                                                   00418000
         DO;     /* LITERAL VALUE MISMATCH */                                   00418100
SET_T2_T3:                                                                      00418200
            T2 = X12;                                                           00418300
            T3 = X12;                                                           00418400
         END;                                                                   00418500
      END;                                                                      00418600
      T2 = PAD(T2,12);                                                          00418700
      T3 = PAD(T3,12);                                                          00418800
      T1 = MSG_ARRAY(ERRTYPE - 1);                                              00418900
      OUTPUT = X2||T1||X8||T2||X12||T3;                                         00419000
      IF ERRTYPE = 9 THEN DO;                                                   00419100
         CALL PRINT_REPLACE_TEXT(INCLUDE_CHARSTRING,126,REPL_TEXT_ADDR1,        00419200
            REPL_LEN1);                                                         00419300
         CALL PRINT_REPLACE_TEXT(COMPOOL_CHARSTRING,126,REPL_TEXT_ADDR2,        00419400
            REPL_LEN2);                                                         00419500
      END;                                                                      00419600
      ELSE IF ERRTYPE = 10 THEN DO;                                             00419700
         OUTPUT = INCLUDE_CHARSTRING||LIT_STRING1;                              00419800
         OUTPUT = COMPOOL_CHARSTRING||LIT_STRING2;                              00419900
      END;                                                                      00420000
   END TPL_ERR;                                                                 00420100
                                                                                00420200
ENTER_REF:                                                                      00420300
   PROCEDURE(XU,YU,YS);                                                         00420400
      DECLARE (PTR,PTR1,XU,YU,YS,M,N) FIXED,                                    00420500
               (KK) BIT(16);                                                    00420600
      BASED NODE_F1 FIXED, NODE_H1 BIT(16);                                     00420700
                                                                                00420800
      IF VAR_BASE(YU) = 0 THEN RETURN;                                          00420900
      COREWORD(ADDR(NODE_B)) = ADDRESS;                                         00421000
      IF NODE_B(3) = 0 THEN RETURN;                                             00421100
      COREWORD(ADDR(NODE_H)) = ADDRESS + NODE_B(3);                             00421200
      COUNT = NODE_H(0);                                                        00421300
      IF COUNT = 0 THEN RETURN;                                                 00421400
      PTR = VMEM_ALLOC_CELL(1,SHL(COUNT,1)+8,0);                                00421500
      COREWORD(ADDR(NODE_H1)) = VMEM_LOC_ADDR;                                  00421600
      COREWORD(ADDR(NODE_F1)) = VMEM_LOC_ADDR;                                  00421700
      RESERVE;                                                                  00421800
      CALL VMEM_LOCATE_COPY(1,VAR_BASE(YU),YS,MODF);                            00421900
      RELEASE;                                                                  00422000
      PTR1 = VMEM_F(0);                                                         00422100
      VMEM_F(0) = PTR;                                                          00422200
      NODE_F1(0) = PTR1;                                                        00422300
      NODE_H1(2) = XU;                                                          00422400
      NODE_H1(3) = COUNT;                                                       00422500
      N = 4;                                                                    00422600
      M = 1;                                                                    00422700
      DO WHILE COUNT > 0;                                                       00422800
         TMP = NODE_H(M);                                                       00422900
         IF TMP ~= -1 THEN DO;                                                  00423000
            NODE_H1(N) = TMP;                                                   00423600
            COUNT = COUNT - 1;                                                  00423700
            M = M + 1;                                                          00423800
            N = N + 1;                                                          00423900
         END;                                                                   00424000
         ELSE DO;                                                               00424100
            TMP = NODE_H(M + 1);                                                00424300
            IF TMP = -1 THEN M = M + 1;                                         00424400
            PNTR = SHL(NODE_H(M + 1),16) + NODE_H(M + 2);                       00424500
            CALL MONITOR(22,"80000005");                                        00424600
            SELECTED_UNIT = 0;                                                  00424700
            M = 0;                                                              00424800
            COREWORD(ADDR(NODE_H)) = ADDRESS;                                   00424900
         END;                                                                   00425000
      END;                                                                      00425100
   END ENTER_REF;                                                               00425200
                                                                                00425300
CSECT_PROC:                                                                     00425400
   PROCEDURE (LINK,MODE) FIXED;                                                 00425500
      DECLARE (LINK,MODE,SUM) FIXED;                                            00425600
      SUM = 0;                                                                  00425700
      DO WHILE LINK ~= 0;                                                       00425800
         IF TEMP1 = (CSECT_LENGTH(LINK)&"FF000000") THEN DO;                    00425900
            IF SIGNAL THEN DO;                                                  00426000
               SIGNAL = FALSE;                                                  00426100
               IF MAX_PHASE > 1 THEN DO;                                        00426200
                  TS(1) = LPAD(PH#,2);                                          00426300
                  TS = ATTR_PHASE||TS(1)||': ';                                 00426400
               END;                                                             00426500
               ELSE TS = X10;                                                   00426600
            END;                                                                00426700
            S1 = STRING("01000000" + ADDR(CSECT_CHAR(SHL(LINK,1))));            00426800
            IF (MODE=1)&((CSECT_FLAGS(LINK)&"40")=0) THEN                       00426900
               S1 = ASTERISK_SIGN||S1;                                          00427000
            ELSE S1 = X1||S1;                                                   00427100
            S2 = HEX6(CSECT_ADDR(LINK)&"FFFFFF");                               00427200
            TMP = CSECT_LENGTH(LINK)&"FFFFFF";                                  00427300
            SUM = SUM + TMP;                                                    00427400
            S3 = LPAD(TMP,6);                                                   00427500
            TS(2) = X1||S1||X2||S2||X1||S3||X2;                                 00427600
            IF LENGTH(TS) + LENGTH(TS(2)) > 132 THEN DO;                        00427700
               OUTPUT = TS;                                                     00427800
               TS = X10||TS(2);                                                 00427900
            END;                                                                00428000
            ELSE TS = TS||TS(2);                                                00428100
         END;                                                                   00428200
         LINK = CSECT_LINK(LINK);                                               00428300
      END;                                                                      00428400
      RETURN SUM;                                                               00428500
   END CSECT_PROC;                                                              00428600
                                                                                00428700
CHECK_EXTRAN:                                                                   00428800
   PROCEDURE (LINK);                                                            00428900
      DECLARE (LINK,SIZE,CORE_ADDRESS) FIXED,                                   00429000
               (ADDR_STRING) CHARACTER;                                         00429100
      DO WHILE LINK ~= 0;                                                       00429200
         IF (CSECT_FLAGS(LINK)&"40")=0 THEN DO;                                 00429300
            SIZE = CSECT_LENGTH(LINK)&"FFFFFF";                                 00429400
            PH# = SHR(CSECT_LENGTH(LINK),24)&"FF";                              00429500
            IF FC_FLAG THEN SIZE = SHR(SIZE,1);                                 00429600
            TOTAL_EXTRAN_SIZE = TOTAL_EXTRAN_SIZE + SIZE;                       00429700
            CORE_ADDRESS = CSECT_ADDR(LINK)&"FFFFFF";                           00429800
            IF FC_FLAG THEN CORE_ADDRESS = SHR(CORE_ADDRESS,1);                 00429900
            ADDR_STRING = HEX6(CORE_ADDRESS);                                   00430000
            TS(1) = STRING("01000000" + ADDR(CSECT_CHAR(SHL(LINK,1))));         00430100
            TS(1) = TS(1)||SUBSTR(SDF_NAMES(I),2);                              00430200
            TS(3) = 'EXTRANEOUS CSECT OF LENGTH '||SIZE||MEM_TYPE||' IN PHASE ' 00430300
               ||PH#||' AT ADDR '||ADDR_STRING||BLK_COLON_BLK||TS(1)||          00430400
               ' OF UNIT '||UNIT_NAMES(I);                                      00430500
            CALL ERROR(TS(3),0);                                                00430600
            TOTAL_EXTRAN_CNT = TOTAL_EXTRAN_CNT + 1;                            00430700
         END;                                                                   00430800
         LINK = CSECT_LINK(LINK);                                               00430900
      END;                                                                      00431000
   END CHECK_EXTRAN;                                                            00431100
                                                                                00431200
CHECK_MISSING:                                                                  00431300
   PROCEDURE;                                                                   00431400
      SIGNAL = TRUE;                                                            00431500
      DO WHILE SLINK ~= 0;                                                      00431600
         TS(1) = STRING("01000000" + ADDR(CSECT_CHAR(SHL(SLINK,1))));           00431700
         TS(1) = TS(1)||BASIC_NAME;                                             00431800
         IF (TS(1) = TS(2))&(PH_TEMP=(CSECT_LENGTH(SLINK)&"FF000000"))          00431900
            THEN DO;                                                            00432000
            CSECT_FLAGS(SLINK) = CSECT_FLAGS(SLINK)|"40";                       00432100
            SIGNAL = FALSE;                                                     00432200
         END;                                                                   00432300
         SLINK = CSECT_LINK(SLINK);                                             00432400
      END;                                                                      00432500
      IF SIGNAL THEN DO;                                                        00432600
         IF TS ~= '' THEN TS = LPAREN||TS||RPAR_BLK;                            00432700
         TS(3) = 'MISSING CSECT IN PHASE '||PH#||BLK_COLON_BLK||TS(2)||X1||     00432800
            TS||'OF UNIT '||UNIT_NAMES(I);                                      00432900
         CALL ERROR(TS(3),2);                                                   00433000
         UNIT_FLAGS(I) = UNIT_FLAGS(I)|"0008";                                  00433100
      END;                                                                      00433200
      TS = '';                                                                  00433300
   END CHECK_MISSING;                                                           00433400
                                                                                00433500
PHASE_DET:                                                                      00433600
   PROCEDURE;                                                                   00433700
                                                                                00433800
GET_PH#:                                                                        00433900
   PROCEDURE (LINK);                                                            00434000
      DECLARE (LINK,OUR_PH#,TEMP) BIT(16);                                      00434100
      DECLARE (KEY) BIT(8);                                                     00434200
      DO WHILE LINK ~= 0;                                                       00434300
         OUR_PH# = SHR(CSECT_LENGTH(LINK),24);                                  00434400
         TEMP = SHR(CSECT_ADDR(LINK),24);                                       00434500
         IF TEMP = 10 THEN KEY = "01";                                          00434600
         ELSE KEY = "02";                                                       00434700
         IF PHASE_TAB(OUR_PH#) < 2 THEN DO;                                     00434800
            PHASE_TAB(OUR_PH#) = KEY;                                           00434900
            IF OUR_PH# > NUM_PHASES THEN NUM_PHASES = OUR_PH#;                  00435000
         END;                                                                   00435100
         LINK = CSECT_LINK(LINK);                                               00435200
      END;                                                                      00435300
   END GET_PH#;                                                                 00435400
                                                                                00435500
      CALL ZERO_256(ADDR(PHASE_TAB),256);                                       00435600
      NUM_PHASES = 0;                                                           00435700
      CALL GET_PH#(#C$0(I));                                                    00435800
      CALL GET_PH#(#D#P(I));                                                    00435900
      CALL GET_PH#(#F#R(I));                                                    00436000
      CALL GET_PH#(#T#Z(I));                                                    00436100
      CALL GET_PH#(#E(I));                                                      00436200
      CALL GET_PH#(#X(I));                                                      00436300
      CALL GET_PH#(TASK_TAB(I));                                                00436400
      CALL GET_PH#(PROC_TAB(I));                                                00436500
      CALL GET_PH#(STACK_TAB(I));                                               00436600
   END PHASE_DET;                                                               00436700
                                                                                00436800
PUSH_STACK:                                                                     00436900
   PROCEDURE;                                                                   00437000
      STACK_INX = STACK_INX + 1;                                                00437100
      IF STACK_INX > STRUC_NEST THEN DO;                                        00437200
         SPACE_1;                                                               00437300
         OUTPUT = HALSTAT_ERR||'STRUCTURE TRAVERSAL STACK LIMIT EXCEEDED ***';  00437400
         SPACE_1;                                                               00437500
         DO I = 0 TO STRUC_NEST;                                                00437600
            TS = HEX8(TPL_STACK2(I));                                           00437700
            OUTPUT = I||X3||TPL_STACK1(I)||X3||TS;                              00437800
         END;                                                                   00437900
         GO TO BAIL_OUT;                                                        00438000
      END;                                                                      00438100
   END PUSH_STACK;                                                              00438200
                                                                                00438300
NEXT_SYMBOL:                                                                    00438400
   PROCEDURE BIT(1);                                                            00438500
      DECLARE (I,J,K,S,BASE,SPAN,TMP1,TMP2) BIT(16);                            00438600
      BASED NODE_H BIT(16);                                                     00438700
                                                                                00438800
      IF INIT THEN DO;                                                          00438900
         INIT = FALSE;                                                          00439000
         GSD_ALPH_PTR = VMEM_ALLOC_STRUC(1,0,2,-2,'GSD ALPHABETIZATION STRUCTURE00439100
',0,FAST);                                                                      00439200
         CALL VMEM_SEQ_OPEN(1,GSD_ALPH_PTR,SYSTEM,0,0);                         00439300
         GOT_LINK = 0;                                                          00439400
         DO I = 1 TO #UNITS;                                                    00439500
            CALL SDF_SELECT(UNIT_SORT(I));                                      00439600
            IF (UNIT_FLAGS(UNIT_SORT(I))&"0010") = 0 THEN DO;                   00439700
               SELECTOR(I) = I;                                                 00439800
               COREWORD(ADDR(NODE_H)) = ADDRESS;                                00439900
               ALPHA_LINK(I) = NODE_H(15);                                      00440000
               SYMBOL_NAMES(I) = KEEP(SYMBOL_NAME(ALPHA_LINK(I)));              00440100
               COREWORD(ADDR(NODE_H)) = ADDRESS;                                00440200
               NEXT_LINK(I) = NODE_H(-2);                                       00440300
            END;                                                                00440400
         END;                                                                   00440500
         BASE = 1;                                                              00440600
         SPAN = #UNITS;                                                         00440700
         DO WHILE SPAN > 1;                                                     00440800
            SPAN = SHL(SHR(SPAN+1,1),1);                                        00440900
            K = BASE + SPAN;                                                    00441000
            DO J = BASE TO (K-2) BY 2;                                          00441100
               TMP1 = SELECTOR(J);                                              00441200
               TMP2 = SELECTOR(J+1);                                            00441300
               IF TMP1 = 0 THEN SELECTOR(K) = TMP2;                             00441400
               ELSE IF TMP2 = 0 THEN SELECTOR(K) = TMP1;                        00441500
               ELSE DO;                                                         00441600
                  IF STRING_GT(SYMBOL_NAMES(TMP1),SYMBOL_NAMES(TMP2))           00441700
                     THEN SELECTOR(K) = TMP2;                                   00441800
                  ELSE SELECTOR(K) = TMP1;                                      00441900
               END;                                                             00442000
               K = K + 1;                                                       00442100
            END;                                                                00442200
            BASE = BASE + SPAN;                                                 00442300
            SPAN = SHR(SPAN,1);                                                 00442400
         END;                                                                   00442500
         SAVE_BASE = BASE;                                                      00442600
         S = SELECTOR(BASE);                                                    00442700
      END;                                                                      00442800
      ELSE DO;                                                                  00442900
         IF (ADL_FLAG=TRUE)&(GOT_LINK ~= 0) THEN DO;                            00443000
            SYMBNO = GOT_LINK;                                                  00443100
            CALL MONITOR(22,"20000009");                                        00443200
         END;                                                                   00443300
         IF NEXT_LINK(S) = 0 THEN DO;                                           00443400
            SELECTOR(S) = 0;                                                    00443500
            ALPHA_LINK(S) = 0;                                                  00443600
         END;                                                                   00443700
         ELSE DO;                                                               00443800
            ALPHA_LINK(S) = NEXT_LINK(S);                                       00443900
            IF GOT_UNIT ~= SELECTED_UNIT THEN CALL SDF_SELECT(GOT_UNIT);        00444000
            SYMBOL_NAMES(S) = KEEP(SYMBOL_NAME(ALPHA_LINK(S)));                 00444100
            COREWORD(ADDR(NODE_H)) = ADDRESS;                                   00444200
            NEXT_LINK(S) = NODE_H(-2);                                          00444300
         END;                                                                   00444400
         IF #UNITS = 1 THEN GO TO EXEUNT;                                       00444500
         BASE = 1;                                                              00444600
         SPAN = #UNITS;                                                         00444700
         J = SHL(SHR(S-1,1),1) + 1;                                             00444800
         K = 0;                                                                 00444900
         DO FOREVER;                                                            00445000
            SPAN = SHL(SHR(SPAN+1,1),1);                                        00445100
            K = BASE + SPAN + SHR(J-BASE,1);                                    00445200
            TMP1 = SELECTOR(J);                                                 00445300
            TMP2 = SELECTOR(J+1);                                               00445400
            IF TMP1 = 0 THEN SELECTOR(K) = TMP2;                                00445500
            ELSE IF TMP2 = 0 THEN SELECTOR(K) = TMP1;                           00445600
            ELSE DO;                                                            00445700
               IF STRING_GT(SYMBOL_NAMES(TMP1),SYMBOL_NAMES(TMP2))              00445800
                  THEN SELECTOR(K) = TMP2;                                      00445900
               ELSE SELECTOR(K) = TMP1;                                         00446000
            END;                                                                00446100
            IF K = SAVE_BASE THEN GO TO EXEUNT;                                 00446200
            J = SHL(SHR(K-1,1),1) + 1;                                          00446300
            BASE = BASE + SPAN;                                                 00446400
            SPAN = SHR(SPAN,1);                                                 00446500
         END;                                                                   00446600
EXEUNT:                                                                         00446700
         S = SELECTOR(SAVE_BASE);                                               00446800
      END;                                                                      00446900
      IF S = 0 THEN RETURN FALSE;                                               00447000
      GOT_UNIT = UNIT_SORT(S);                                                  00447100
      GOT_LINK = ALPHA_LINK(S);                                                 00447200
      CALL VMEM_NEXT_COPY(SYSTEM,MODF);                                         00447300
      SEQ_H(0) = GOT_UNIT;                                                      00447400
      SEQ_H(1) = GOT_LINK;                                                      00447500
      IF ADL_FLAG THEN DO;                                                      00447600
         REAL_NAME = SYMBOL_NAMES(S);                                           00447700
         GOT_NAME = PAD(REAL_NAME,32);                                          00447800
         IF GOT_UNIT ~= SELECTED_UNIT THEN CALL SDF_SELECT(GOT_UNIT);           00447900
         SYMBNO = GOT_LINK;                                                     00448000
         CALL MONITOR(22,"10000009");                                           00448100
         GOT_CELL_ADDR = ADDRESS;                                               00448200
      END;                                                                      00448300
      RETURN TRUE;                                                              00448400
   END NEXT_SYMBOL;                                                             00448500
                                                                                00448600
FAST_NEXT_SYMBOL:                                                               00448700
   PROCEDURE BIT(1);                                                            00448800
      IF INIT THEN DO;                                                          00448900
         GOT_LINK = 0;                                                          00449000
         CALL VMEM_SEQ_OPEN(1,GSD_ALPH_PTR,SYSTEM,1,0);                         00449100
         INIT = FALSE;                                                          00449200
      END;                                                                      00449300
      IF GOT_LINK ~= 0 THEN DO;                                                 00449400
         SYMBNO = GOT_LINK;                                                     00449500
         CALL MONITOR(22,"20000009");  /* RELEASE PREVIOUS SYMBOL */            00449600
      END;                                                                      00449700
      IF ~VMEM_NEXT_COPY(SYSTEM,0) THEN RETURN FALSE;                           00449800
      GOT_UNIT = SEQ_H(0);                                                      00449900
      GOT_LINK = SEQ_H(1);                                                      00450000
      IF GOT_UNIT ~= SELECTED_UNIT THEN CALL SDF_SELECT(GOT_UNIT);              00450100
      REAL_NAME = KEEP(SYMBOL_NAME(GOT_LINK));                                  00450200
      GOT_NAME = PAD(REAL_NAME,32);                                             00450300
      CALL MONITOR(22,"10000006");                                              00450400
      GOT_CELL_ADDR = ADDRESS;                                                  00450500
      RETURN TRUE;                                                              00450600
   END FAST_NEXT_SYMBOL;                                                        00450700
                                                                                00450800
CHECK_MATCH:                                                                    00450900
   PROCEDURE BIT(1);                                                            00451000
      DECLARE (CLASS2) BIT(8),                                                  00451100
              (NEXT1,NEXT2) BIT(16),                                            00451200
              (FLAG1,FLAG2) FIXED,                                              00451300
              (NAME1,NAME2) CHARACTER;                                          00451400
                                                                                00451500
      COREWORD(ADDR(NODE_F2)) = ADDRESS;                                        00451600
      COREWORD(ADDR(NODE_B2)) = ADDRESS;                                        00451700
      CLASS2 = NODE_B2(6);                                                      00451800
      FLAG2 = NODE_F2(2);                                                       00451900
      IF CLASS2 < 4 THEN RETURN FALSE;                                          00452000
      COREWORD(ADDR(NODE_F1)) = SAVE_ADDR;                                      00452100
      COREWORD(ADDR(NODE_H1)) = SAVE_ADDR;                                      00452200
      COREWORD(ADDR(NODE_B1)) = SAVE_ADDR;                                      00452300
      FLAG1 = NODE_F1(2);                                                       00452400
      NEXT1 = NODE_H1(SHR(NODE_B1(5),1) + 2);                                   00452500
      DO FOREVER;                                                               00452600
         COREWORD(ADDR(NODE_H2)) = ADDRESS;                                     00452700
         NEXT2 = NODE_H2(SHR(NODE_B2(5),1) + 2);                                00452800
         IF (FLAG1&"02000000")~=0 THEN DO;                                      00452900
            IF (FLAG2&"02000000") ~=0 THEN RETURN TRUE;                         00453000
            ELSE RETURN FALSE;                                                  00453100
         END;                                                                   00453200
         ELSE IF (FLAG2&"02000000")~=0 THEN RETURN FALSE;                       00453300
         IF (NEXT1 < 0)&(NEXT2 > 0) THEN RETURN FALSE;                          00453400
         IF (NEXT1 > 0)&(NEXT2 < 0) THEN RETURN FALSE;                          00453500
         IF NEXT1 < 0 THEN DO;                                                  00453600
            NEXT1 = - NEXT1;                                                    00453700
            NEXT2 = - NEXT2;                                                    00453800
         END;                                                                   00453900
         CALL MOVE(8,SDF_NAME,SDFNAM);                                          00454000
         CALL MONITOR(22,4);                                                    00454100
         SELECTED_UNIT = 0;                                                     00454200
         NAME1 = KEEP(SYMBOL_NAME(NEXT1));                                      00454300
         COREWORD(ADDR(NODE_F1)) = ADDRESS;                                     00454400
         COREWORD(ADDR(NODE_H1)) = ADDRESS;                                     00454500
         COREWORD(ADDR(NODE_B1)) = ADDRESS;                                     00454600
         FLAG1 = NODE_F1(2);                                                    00454700
         NEXT1 = NODE_H1(SHR(NODE_B1(5),1) + 2);                                00454800
         CALL MOVE(8,ALT_SDF,SDFNAM);                                           00454900
         CALL MONITOR(22,4);                                                    00455000
         SELECTED_UNIT = 0;                                                     00455100
         NAME2 = SYMBOL_NAME(NEXT2);                                            00455200
         IF NAME1 ~= NAME2 THEN RETURN FALSE;                                   00455300
         COREWORD(ADDR(NODE_F2)) = ADDRESS;                                     00455400
         COREWORD(ADDR(NODE_B2)) = ADDRESS;                                     00455500
         FLAG2 = NODE_F2(2);                                                    00455600
      END;                                                                      00455700
   END CHECK_MATCH;                                                             00455800
                                                                                00455900
GLOBAL_SYMB:                                                                    00456000
   PROCEDURE (LOCAL) FIXED;                                                     00456100
      DECLARE (SGLOBAL,LOCAL) FIXED,                                            00456200
              (NEG) BIT(1);                                                     00456300
      IF GSD_LEVEL = 0 THEN RETURN 0;                                           00456400
      IF MAP_BASE(GOT_UNIT) = 0 THEN RETURN 0;                                  00456500
      IF LOCAL = 0 THEN RETURN 0;                                               00456600
      IF LOCAL < 0 THEN DO;                                                     00456700
         NEG = TRUE;                                                            00456800
         LOCAL = - LOCAL;                                                       00456900
      END;                                                                      00457000
      ELSE NEG = FALSE;                                                         00457100
      RESERVE                                                                   00457200
      CALL VMEM_LOCATE_COPY(1,MAP_BASE(GOT_UNIT),LOCAL,0);                      00457300
      SGLOBAL = VMEM_F(0);                                                      00457400
      IF (SGLOBAL&"40000000") ~= 0 THEN DO;                                     00457500
         CALL VMEM_LOCATE_PTR(1,SGLOBAL&"3FFFFFFF",0);                          00457600
         SGLOBAL = VMEM_F(0);                                                   00457700
      END;                                                                      00457800
      RELEASE                                                                   00457900
      IF NEG THEN SGLOBAL = - SGLOBAL;                                          00458000
      RETURN SGLOBAL;                                                           00458100
   END GLOBAL_SYMB;                                                             00458200
                                                                                00458300
SET_STRINGS:                                                                    00458400
   PROCEDURE;                                                                   00458500
      S1 = HEX6(ADDR1);                                                         00458600
      IF (ADDR2 = ADDR1)|(ADDR2 = 0) THEN S2 = X7;                              00458700
      ELSE DO;                                                                  00458800
         S2 = HEX6(ADDR2);                                                      00458900
         S2 = MINUS||S2;                                                        00459000
      END;                                                                      00459100
   END SET_STRINGS;                                                             00459200
                                                                                00459300
SUB1:                                                                           00459400
   PROCEDURE;                                                                   00459500
      DECLARE GLOBAL_TMP FIXED;                                                 00459600
      SYMBOL_STRING = SYMBOL_NAME(LINK);                                        00459700
      GLOBAL_TMP = GLOBAL_SYMB(LINK);                                           00459800
      IF GLOBAL_TMP = 0 THEN TS(2) = X5;                                        00459900
      ELSE TS(2) = LPAD(GLOBAL_TMP,5);                                          00460000
      COREWORD(ADDR(NODE_F)) = ADDRESS;                                         00460100
      COREWORD(ADDR(NODE_H)) = ADDRESS;                                         00460200
      COREWORD(ADDR(NODE_B)) = ADDRESS;                                         00460300
      FLAG = NODE_F(2);                                                         00460400
      CLASS = NODE_B(6);                                                        00460500
      TYPE = NODE_B(7);                                                         00460600
   END SUB1;                                                                    00460700
                                                                                00460800
SUB1A:                                                                          00460900
   PROCEDURE;                                                                   00461000
      ADDR1 = NODE_F(3)&"FFFFFF";                                               00461100
      IF (FLAG&"04000000") ~= 0 THEN DO;                                        00461200
         IF FC_FLAG THEN ADDR2 = ADDR1;                                         00461300
         ELSE ADDR2 = ADDR1 + 3;                                                00461400
      END;                                                                      00461500
      ELSE ADDR2 = ADDR1 + (NODE_F(5)&"FFFFFF") - 1;                            00461600
      IF (CLASS=4)&((FLAG&"04400000")="00400000") THEN DO;                      00461700
         IF (TYPE=1)|(TYPE=9)|(TYPE=10) THEN DO;                                00461800
            IF FC_FLAG THEN DO;                                                 00461900
               TMP = 1;                                                         00462000
               IF TYPE = 9 THEN TMP = 2;                                        00462100
               ADDR2 = ADDR1 + TMP - 1;                                         00462200
            END;                                                                00462300
         END;                                                                   00462400
      END;                                                                      00462500
      ADDR1 = ADDR1 + CURRENT_BASE;                                             00462600
      ADDR2 = ADDR2 + CURRENT_BASE;                                             00462700
   END SUB1A;                                                                   00462800
                                                                                00462900
SUB2:                                                                           00463000
   PROCEDURE;                                                                   00463100
      DECLARE WORK_STRING CHARACTER;                                            00463200
      TS(1) = PAD(SYMBOL_STRING,48);                                            00463300
      IF (FLAG&"04000000") ~= 0 THEN TS(1) = TS(1)||'  NAME';                   00463400
      ELSE TS(1) = TS(1)||X6;                                                   00463500
      IF (TYPE~=16)&(NODE_B(4)~=0) THEN TS(1) = TS(1)||'  ARRAY';               00463600
      ELSE TS(1) = TS(1)||X7;                                                   00463700
      IF (FLAG&"00200000") ~= 0 THEN WORK_STRING = '  CONSTANT    ';            00463800
      ELSE IF CLASS > 3 THEN WORK_STRING = '  TERMINAL    ';                    00463900
      ELSE WORK_STRING = SYMBOL_CLASSES(CLASS);                                 00464000
      IF (CLASS=1)&(TYPE=16) THEN DO;                                           00464100
         G_TEMP = GLOBAL_SYMB(NODE_H(9));                                       00464200
         IF G_TEMP ~= 0 THEN WORK_STRING = WORK_STRING||                        00464300
            'TPL# '||G_TEMP;                                                    00464400
      END;                                                                      00464500
      TS(1) = TS(1)||SYMBOL_TYPES(TYPE)||WORK_STRING;                           00464600
      CALL SUB1A;                                                               00464700
   END SUB2;                                                                    00464800
                                                                                00464900
SUB3:                                                                           00465000
   PROCEDURE;                                                                   00465100
      CALL SET_STRINGS;                                                         00465200
      OUTPUT = S1||S2||X2||CSECT_NAME||PLUS||HEX4(ADDR1-BASE_ADDR)||X1||        00465300
         TS(2)||X2||TS(1);                                                      00465400
   END SUB3;                                                                    00465500
                                                                                00465600
EXTRACT:                                                                        00465700
   PROCEDURE (STRINGX) CHARACTER;                                               00465800
      DECLARE STRINGX CHARACTER,                                                00465900
             J BIT(16);                                                         00466000
      STRINGX = SUBSTR(STRINGX,1,71);                                           00466100
      DO WHILE SUBSTR(STRINGX,0,1) = X1;                                        00466200
         STRINGX = SUBSTR(STRINGX,1);                                           00466300
      END;                                                                      00466400
      IF STRINGX = '' THEN RETURN STRINGX;                                      00466500
      J = CHAR_INDEX(STRINGX,X1);                                               00466600
      IF J > 0 THEN STRINGX = SUBSTR(STRINGX,0,J);                              00466700
      IF LENGTH(STRINGX) > 32 THEN STRINGX = SUBSTR(STRINGX,0,32);              00466800
      RETURN STRINGX;                                                           00466900
   END EXTRACT;                                                                 00467000
                                                                                00467100
DO_ALLOCATE:                                                                    00467200
   PROCEDURE;                                                                   00467300
      DECLARE (PTR,BASE) FIXED, J BIT(16);                                      00467400
      IF EXTENSION_PTR = 0 THEN DO;                                             00467500
         CALL VMEM_LOCATE_COPY(1,TEXT_BASE(GOT_UNIT),GOT_VAR+1,0);              00467600
         COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;                                00467700
         BASE = NODE_F(0);                                                      00467800
         IF BASE = 0 THEN DO;                                                   00467900
            RESERVE                                                             00468000
            VMEM_PAD_DISP(SAVE_NDX) = VMEM_PAD_DISP(SAVE_NDX) |                 00468100
               "4000";                                                          00468200
            EXTENSION_PTR = VMEM_ALLOC_CELL(1,TEXT_SIZE+8,0);                   00468300
            COREWORD(ADDR(NODE_H)) = VMEM_LOC_ADDR;                             00468400
            NODE_H(3) = NUM_LINES;                                              00468500
            CALL MOVE(TEXT_SIZE,FILE1_BUFF_ADDR,VMEM_LOC_ADDR+8);               00468600
            NODE_F(0) = EXTENSION_PTR;                                          00468700
            RELEASE                                                             00468800
         END;                                                                   00468900
      END;                                                                      00469000
      ELSE DO;                                                                  00469100
         PTR = VMEM_ALLOC_CELL(1,TEXT_SIZE+8,0);                                00469200
         COREWORD(ADDR(NODE_H)) = VMEM_LOC_ADDR;                                00469300
         NODE_H(3) = NUM_LINES;                                                 00469400
         CALL MOVE(TEXT_SIZE,FILE1_BUFF_ADDR,VMEM_LOC_ADDR+8);                  00469500
         CALL VMEM_LOCATE_PTR(1,EXTENSION_PTR,MODF);                            00469600
         VMEM_F(0) = PTR;                                                       00469700
         EXTENSION_PTR = PTR;                                                   00469800
      END;                                                                      00469900
      TEXT_FLAG = FALSE;                                                        00470000
   END DO_ALLOCATE;                                                             00470100
                                                                                00470200
TEXT_ERROR:                                                                     00470300
   PROCEDURE (STRINGX,ERR);                                                     00470400
      DECLARE STRINGX CHARACTER, ERR BIT(16);                                   00470500
      IF SIGNAL THEN DO;                                                        00470600
         SIGNAL = FALSE;                                                        00470700
         OUTPUT(2) = X1;                                                        00470800
         OUTPUT(2) = ' *** THE FOLLOWING ERRORS WERE DETECTED IN PROCESSING USER00470900
 SUPPLIED TEXT INPUT ***';                                                      00471000
         OUTPUT(2) = X1;                                                        00471100
      END;                                                                      00471200
      OUTPUT(2) = X1||CONTROL_CARD;                                             00471300
      OUTPUT(2) = ' *** '||STRINGX;                                             00471400
      OUTPUT(2) = X1;                                                           00471500
   END TEXT_ERROR;                                                              00471600
                                                                                00471700
EMIT_TEXT:                                                                      00471800
   PROCEDURE (VAR,MODE);                                                        00471900
      DECLARE (PTR,RTEXT_BIAS) FIXED, (VAR,MODE,I,NUM_LINES) BIT(16),           00472000
         (CHAR,LMARGIN,LTEXT,RTEXT,RMARGIN) CHARACTER;                          00472100
      BASED NODE_F FIXED;                                                       00472200
                                                                                00472300
PRINT_LINE:                                                                     00472400
   PROCEDURE;                                                                   00472500
      OUTPUT = LMARGIN||LTEXT||RTEXT||RMARGIN;                                  00472600
      IF MODE = 1 THEN DO;                                                      00472700
         RTEXT = X33;                                                           00472800
         LMARGIN = X20;                                                         00472900
      END;                                                                      00473000
      ELSE RTEXT = X38;                                                         00473100
      LTEXT = X71;                                                              00473200
   END PRINT_LINE;                                                              00473300
                                                                                00473400
      IF TEXT_BASE(GOT_UNIT) ~= 0 THEN DO;                                      00473500
         CALL VMEM_LOCATE_COPY(1,TEXT_BASE(GOT_UNIT),VAR,0);                    00473600
         PTR = VMEM_F(0);                                                       00473700
         IF PTR ~= 0 THEN DO;                                                   00473800
            SPACE_1;                                                            00473900
            SIGNAL = FALSE;                                                     00474000
            LTEXT = X71;                                                        00474100
            IF MODE = 1 THEN DO;                                                00474200
               RTEXT = X33;                                                     00474300
               RTEXT_BIAS = "20000001";                                         00474400
               LMARGIN = 'DESCRIPTION:        ';                                00474500
            END;                                                                00474600
            ELSE DO;                                                            00474700
               RTEXT = X38;                                                     00474800
               RTEXT_BIAS = "25000001";                                         00474900
               LMARGIN = 'C              ';                                     00475000
            END;                                                                00475100
            DO WHILE PTR ~= 0;                                                  00475200
               CALL VMEM_LOCATE_PTR(1,PTR,0);                                   00475300
               COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;                          00475400
               PTR = NODE_F(0);                                                 00475500
               NUM_LINES = NODE_F(1)&"FFFF";                                    00475600
               BUFF_ADDR = VMEM_LOC_ADDR + 8;                                   00475700
               DO I = 1 TO NUM_LINES;                                           00475800
                  CHAR = STRING(BUFF_ADDR);                                     00475900
                  IF CHAR = XCHAR THEN DO;                                      00476000
                     RMARGIN = STRING("07000028" + BUFF_ADDR);                  00476100
                     RTEXT = STRING(RTEXT_BIAS + BUFF_ADDR);                    00476200
                     CALL PRINT_LINE;                                           00476300
                     SIGNAL = FALSE;                                            00476400
                     BUFF_ADDR = BUFF_ADDR + 48;                                00476500
                  END;                                                          00476600
                  ELSE DO;                                                      00476700
                     IF SIGNAL THEN CALL PRINT_LINE;                            00476800
                     RMARGIN = STRING("07000048" + BUFF_ADDR);                  00476900
                     LTEXT = STRING("46000001" + BUFF_ADDR);                    00477000
                     SIGNAL = TRUE;                                             00477100
                     BUFF_ADDR = BUFF_ADDR + 80;                                00477200
                  END;                                                          00477300
               END;                                                             00477400
            END;                                                                00477500
            IF SIGNAL THEN CALL PRINT_LINE;                                     00477600
            SPACE_1;                                                            00477700
         END;                                                                   00477800
      END;                                                                      00477900
   END EMIT_TEXT;                                                               00478000
                                                                                00478100
LOCATE_TEXT:                                                                    00478200
   PROCEDURE (D_TEXT_ADDR,D_TEXT_LEN);                                          00478300
      DECLARE (D_TEXT_ADDR,TEXT_ADDR1,TEXT_ADDR2,TEXT_LIM_ADDR) FIXED,          00478400
              (TEXT_CELL_ADDR) FIXED,                                           00478500
              (DES_CSECT_NDX,D_TEXT_LEN,TEXT_CSECT_NDX) BIT(16);                00478600
      DECLARE TEXT_BUFFER(64) FIXED;                                            00478700
                                                                                00478800
NO_TEXT:                                                                        00478900
   PROCEDURE;                                                                   00479000
      DECLARE I BIT(16);                                                        00479100
      TEXT_ADDRESS = ADDR(TEXT_BUFFER);                                         00479200
      DO I = 0 TO 64;                                                           00479300
         TEXT_BUFFER(I) = "DEADFACE";                                           00479400
      END;                                                                      00479500
   END NO_TEXT;                                                                 00479600
                                                                                00479700
NEXT_CELL:                                                                      00479800
   PROCEDURE;                                                                   00479900
      CALL VMEM_LOCATE_PTR(1,TEXT_CELL_PTR,0);                                  00480000
      TEXT_CELL_ADDR = VMEM_LOC_ADDR;                                           00480100
      TEXT_ADDR1 = COREWORD(TEXT_CELL_ADDR+4);                                  00480200
      TEXT_ADDR2 = COREWORD(TEXT_CELL_ADDR+8);                                  00480300
   END NEXT_CELL;                                                               00480400
                                                                                00480500
EXTRACT_TEXT:                                                                   00480600
   PROCEDURE;                                                                   00480700
      DECLARE (LEN,CUR_TEXT_ADDR,SOURCE_ADDR,TARGET_ADDR) FIXED;                00480800
                                                                                00480900
      CALL NO_TEXT;                                                             00481000
      CUR_TEXT_ADDR = D_TEXT_ADDR;                                              00481100
      TMP = CUR_TEXT_ADDR - TEXT_ADDR1;                                         00481200
      IF FC_FLAG THEN TMP = SHL(TMP,1);                                         00481300
      SOURCE_ADDR = TEXT_CELL_ADDR + 12 + TMP;                                  00481400
      TARGET_ADDR = ADDR(TEXT_BUFFER);                                          00481500
      DO WHILE CUR_TEXT_ADDR <= TEXT_LIM_ADDR;                                  00481600
         IF TEXT_LIM_ADDR <= TEXT_ADDR2 THEN DO;                                00481700
            LEN = TEXT_LIM_ADDR - CUR_TEXT_ADDR + 1;                            00481800
            IF FC_FLAG THEN LEN = SHL(LEN,1);                                   00481900
            CALL MOVE(LEN,SOURCE_ADDR,TARGET_ADDR);                             00482000
            CALL VMEM_DISP(RESV);                                               00482100
            RETURN;                                                             00482200
         END;                                                                   00482300
         LEN = TEXT_ADDR2 - CUR_TEXT_ADDR + 1;                                  00482400
         IF FC_FLAG THEN LEN = SHL(LEN,1);                                      00482500
         CALL MOVE(LEN,SOURCE_ADDR,TARGET_ADDR);                                00482600
         IF COREWORD(TEXT_CELL_ADDR) ~= 0 THEN DO;                              00482700
            TEXT_CELL_PTR = COREWORD(TEXT_CELL_ADDR);                           00482800
            CALL NEXT_CELL;                                                     00482900
            CUR_TEXT_ADDR = TEXT_ADDR1;                                         00483000
            IF CUR_TEXT_ADDR > TEXT_LIM_ADDR THEN DO;                           00483100
               CALL VMEM_DISP(RESV);                                            00483200
               RETURN;                                                          00483300
            END;                                                                00483400
            SOURCE_ADDR = TEXT_CELL_ADDR + 12;                                  00483500
            LEN = CUR_TEXT_ADDR - D_TEXT_ADDR;                                  00483600
            IF FC_FLAG THEN LEN = SHL(LEN,1);                                   00483700
            TARGET_ADDR = ADDR(TEXT_BUFFER) + LEN;                              00483800
         END;                                                                   00483900
         ELSE DO;                                                               00484000
            CALL VMEM_DISP(RESV);                                               00484100
            RETURN;                                                             00484200
         END;                                                                   00484300
      END;                                                                      00484400
   END EXTRACT_TEXT;                                                            00484500
                                                                                00484600
GET_TEXT:                                                                       00484700
   PROCEDURE;                                                                   00484800
      DO FOREVER;                                                               00484900
         CALL NEXT_CELL;                                                        00485000
         IF (D_TEXT_ADDR >= TEXT_ADDR1)&(D_TEXT_ADDR <= TEXT_ADDR2) THEN DO;    00485100
            IF TEXT_LIM_ADDR <= TEXT_ADDR2 THEN DO;                             00485200
               TMP = D_TEXT_ADDR - TEXT_ADDR1;                                  00485300
               IF FC_FLAG THEN TMP = SHL(TMP,1);                                00485400
               TEXT_ADDRESS = TEXT_CELL_ADDR + 12 + TMP;                        00485500
               CALL VMEM_DISP(RESV);                                            00485600
               RETURN;                                                          00485700
            END;                                                                00485800
            ELSE DO;                                                            00485900
               CALL EXTRACT_TEXT;                                               00486000
               RETURN;                                                          00486100
            END;                                                                00486200
         END;                                                                   00486300
         TEXT_CELL_PTR = COREWORD(TEXT_CELL_ADDR);                              00486400
         IF TEXT_CELL_PTR = 0 THEN DO;                                          00486500
            CALL NO_TEXT;                                                       00486600
            TEXT_CSECT_NDX = 0;                                                 00486700
            RETURN;                                                             00486800
         END;                                                                   00486900
      END;                                                                      00487000
   END GET_TEXT;                                                                00487100
                                                                                00487200
      DES_CSECT_NDX = GET_CSECT_NDX_BY_ADDR(D_TEXT_ADDR);                       00487300
      TEXT_LIM_ADDR = D_TEXT_ADDR + D_TEXT_LEN - 1;                             00487400
      IF (DES_CSECT_NDX=TEXT_CSECT_NDX)&(D_TEXT_ADDR>=TEXT_ADDR1) THEN DO;      00487500
         IF D_TEXT_ADDR <= TEXT_ADDR2 THEN DO;                                  00487600
            IF TEXT_LIM_ADDR <= TEXT_ADDR2 THEN DO;                             00487700
               TMP = D_TEXT_ADDR - TEXT_ADDR1;                                  00487800
               IF FC_FLAG THEN TMP = SHL(TMP,1);                                00487900
               TEXT_ADDRESS = TEXT_CELL_ADDR + 12 + TMP;                        00488000
            END;                                                                00488100
            ELSE DO;                                                            00488200
               CALL VMEM_LOCATE_PTR(1,TEXT_CELL_PTR,RELS);                      00488300
               CALL EXTRACT_TEXT;                                               00488400
            END;                                                                00488500
         END;                                                                   00488600
         ELSE DO;                                                               00488700
            CALL VMEM_LOCATE_PTR(1,TEXT_CELL_PTR,RELS);                         00488800
            TEXT_CELL_PTR = COREWORD(TEXT_CELL_ADDR);                           00488900
            CALL GET_TEXT;                                                      00489000
         END;                                                                   00489100
      END;                                                                      00489200
      ELSE DO;                                                                  00489300
         IF TEXT_CELL_PTR ~= 0 THEN CALL VMEM_LOCATE_PTR(1,TEXT_CELL_PTR,RELS); 00489400
         TEXT_CELL_PTR = CSECT_TEXT_PTR(DES_CSECT_NDX);                         00489500
         IF TEXT_CELL_PTR = 0 THEN DO;                                          00489600
            TEXT_CSECT_NDX = 0;                                                 00489700
            CALL NO_TEXT;                                                       00489800
         END;                                                                   00489900
         ELSE DO;                                                               00490000
            TEXT_CSECT_NDX = DES_CSECT_NDX;                                     00490100
            CALL GET_TEXT;                                                      00490200
         END;                                                                   00490300
      END;                                                                      00490400
   END LOCATE_TEXT;                                                             00490500
                                                                                00490600
GET_H:                                                                          00490700
   PROCEDURE (MEM_ADDR) BIT(16);                                                00490800
      DECLARE MEM_ADDR FIXED;                                                   00490900
      IF FC_FLAG THEN CALL LOCATE_TEXT(MEM_ADDR,1);                             00491000
      ELSE CALL LOCATE_TEXT(MEM_ADDR,2);                                        00491100
      RETURN KOREHALF(TEXT_ADDRESS);                                            00491200
   END GET_H;                                                                   00491300
                                                                                00491400
GET_F:                                                                          00491500
   PROCEDURE (MEM_ADDR) FIXED;                                                  00491600
      DECLARE MEM_ADDR FIXED;                                                   00491700
      IF FC_FLAG THEN CALL LOCATE_TEXT(MEM_ADDR,2);                             00491800
      ELSE CALL LOCATE_TEXT(MEM_ADDR,4);                                        00491900
      RETURN KOREWORD(TEXT_ADDRESS);                                            00492000
   END GET_F;                                                                   00492100
                                                                                00492200
GET_E:                                                                          00492300
   PROCEDURE (MEM_ADDR);                                                        00492400
      DECLARE MEM_ADDR FIXED;                                                   00492500
      IF FC_FLAG THEN CALL LOCATE_TEXT(MEM_ADDR,2);                             00492600
      ELSE CALL LOCATE_TEXT(MEM_ADDR,4);                                        00492700
      DW(0) = KOREWORD(TEXT_ADDRESS);                                           00492800
      DW(1) = 0;                                                                00492900
   END GET_E;                                                                   00493000
                                                                                00493100
GET_D:                                                                          00493200
   PROCEDURE (MEM_ADDR);                                                        00493300
      DECLARE MEM_ADDR FIXED;                                                   00493400
      IF FC_FLAG THEN CALL LOCATE_TEXT(MEM_ADDR,4);                             00493500
      ELSE CALL LOCATE_TEXT(MEM_ADDR,8);                                        00493600
      DW(0) = KOREWORD(TEXT_ADDRESS);                                           00493700
      DW(1) = KOREWORD(TEXT_ADDRESS+4);                                         00493800
   END GET_D;                                                                   00493900
                                                                                00494000
SCALAR_TO_CHAR:                                                                 00494100
   PROCEDURE (MEM_ADDR,DTYPE) CHARACTER;                                        00494200
      DECLARE (MEM_ADDR,DTYPE) FIXED, STR CHARACTER;                            00494300
      IF DTYPE = 0 THEN DO;                                                     00494400
         CALL GET_E(MEM_ADDR);                                                  00494500
         IF DW(0) = "DEADFACE" THEN RETURN 'UNINITIALIZED  ';                   00494600
      END;                                                                      00494700
      ELSE DO;                                                                  00494800
         CALL GET_D(MEM_ADDR);                                                  00494900
         IF DW(0) = "DEADFACE" THEN RETURN 'UNINITIALIZED           ';          00495000
      END;                                                                      00495100
      STR = STRING(MONITOR(12,DTYPE));                                          00495200
      RETURN STR;                                                               00495300
   END SCALAR_TO_CHAR;                                                          00495400
                                                                                00495500
BIT_TO_CHAR:                                                                    00495600
   PROCEDURE (IVAL) CHARACTER;                                                  00495700
      DECLARE IVAL FIXED, (I) BIT(16), STR CHARACTER;                           00495800
      IF NUM_BITS = 1 THEN DO;                                                  00495900
         IF IVAL = 0 THEN RETURN 'FALSE ';                                      00496000
         ELSE RETURN 'TRUE  ';                                                  00496100
      END;                                                                      00496200
      STR = 'BIN'''||SUBSTR(ZERO_CHAR,0,NUM_BITS)||QUOTE;                       00496300
      DO I = 1 TO NUM_BITS;                                                     00496400
         IF (IVAL&1) ~= 0 THEN BYTE(STR,NUM_BITS+4-I) = "F1";                   00496500
         IVAL = SHR(IVAL,1);                                                    00496600
      END;                                                                      00496700
      RETURN STR;                                                               00496800
   END BIT_TO_CHAR;                                                             00496900
                                                                                00497000
PRINT_HEX:                                                                      00497100
   PROCEDURE (MEM_ADDR,LEN,NOSKIP);                                             00497200
      DECLARE (MEM_ADDR,MEM_ADDR1,MEM_ADDR2,HEX_CNT,LEN) FIXED;                 00497300
      DECLARE HEX_STRING CHARACTER;                                             00497400
      DECLARE NOSKIP BIT(1);                                                    00497500
                                                                                00497600
TEXT_STRINGS:                                                                   00497700
   PROCEDURE;                                                                   00497800
      S1 = HEX6(MEM_ADDR1);                                                     00497900
      IF MEM_ADDR2 = MEM_ADDR1 THEN S2 = X7;                                    00498000
      ELSE DO;                                                                  00498100
         S2 = HEX6(MEM_ADDR2);                                                  00498200
         S2 = MINUS||S2;                                                        00498300
      END;                                                                      00498400
   END TEXT_STRINGS;                                                            00498500
                                                                                00498600
      IF LEN <= 0 THEN RETURN;                                                  00498700
      MEM_ADDR1,MEM_ADDR2 = MEM_ADDR;                                           00498800
      HEX_STRING = '';                                                          00498900
      IF FC_FLAG THEN DO;                                                       00499000
         HEX_CNT = 16;                                                          00499100
         DO WHILE LEN > 0;                                                      00499200
            HEX_STRING = HEX_STRING||HEX4(GET_H(MEM_ADDR2))||X2;                00499300
            HEX_CNT = HEX_CNT - 1;                                              00499400
            IF HEX_CNT = 0 THEN DO;                                             00499500
               CALL TEXT_STRINGS;                                               00499600
               OUTPUT = S1||S2||X2||CSECT_NAME||PLUS||HEX4(MEM_ADDR1-           00499700
                  BASE_ADDR)||X7||HEX_STRING;                                   00499800
               HEX_STRING = '';                                                 00499900
               HEX_CNT = 16;                                                    00500000
               MEM_ADDR1 = MEM_ADDR2 + 1;                                       00500100
            END;                                                                00500200
            MEM_ADDR2 = MEM_ADDR2 + 1;                                          00500300
            LEN = LEN - 1;                                                      00500400
         END;                                                                   00500500
         IF LENGTH(HEX_STRING) > 0 THEN DO;                                     00500600
            MEM_ADDR2 = MEM_ADDR2 - 1;                                          00500700
            CALL TEXT_STRINGS;                                                  00500800
            TS = S1||S2||X2||CSECT_NAME||PLUS||HEX4(MEM_ADDR1-BASE_ADDR)||      00500900
               X7||HEX_STRING;                                                  00501000
            IF NOSKIP THEN TS = PAD(TS,80);                                     00501100
            ELSE OUTPUT = TS;                                                   00501200
         END;                                                                   00501300
      END;                                                                      00501400
      ELSE DO;                                                                  00501500
      END;                                                                      00501600
   END PRINT_HEX;                                                               00501700
                                                                                00501800
PRINT_ITEM:                                                                     00501900
   PROCEDURE;                                                                   00502000
      DECLARE (ITEM_CNT,K,L) BIT(16);                                           00502100
      DECLARE TS_INIT CHARACTER INITIAL('                                   '); 00502200
      IF DATA_OK(QTYPE) THEN DO;                                                00502300
         CUR_ADDR = ADDR1;                                                      00502400
         IF FC_FLAG THEN ADDR_BUMP = ADDR_AUG101(QTYPE);                        00502500
         ELSE ADDR_BUMP = ADDR_AUG360(QTYPE);                                   00502600
         IF QTYPE = 18 THEN DO;                                                 00502700
            CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,0);                              00502800
            RETURN;                                                             00502900
         END;                                                                   00503000
         ELSE IF QTYPE = 19 THEN DO;                                            00503100
            CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,0);                              00503200
            RETURN;                                                             00503300
         END;                                                                   00503400
         ELSE IF QTYPE = 2 THEN DO;                                             00503500
            CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,0);                              00503600
            RETURN;                                                             00503700
         END;                                                                   00503800
         ELSE IF QTYPE = 7 THEN DO;                                             00503900
            CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,0);                              00504000
            RETURN;                                                             00504100
         END;                                                                   00504200
         IF SYM_MULT = 1 THEN CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,1);            00504300
         ELSE DO;                                                               00504400
            CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,0);                              00504500
            TS = TS_INIT;                                                       00504600
         END;                                                                   00504700
         ITEM_CNT = NUM_PER_LINE;                                               00504800
         DO K = 1 TO SYM_MULT;                                                  00504900
            DO CASE DATA_TYPES(QTYPE);                                          00505000
               ;                                                                00505100
               DO;     /* BIT STRINGS */                                        00505200
                  IF (TYPE=9) THEN BIT_VALUE = GET_F(CUR_ADDR);                 00505300
                  ELSE BIT_VALUE = GET_H(CUR_ADDR);                             00505400
                  IF BIT_SHIFT ~= 0 THEN BIT_VALUE = SHR(BIT_VALUE,BIT_SHIFT);  00505500
                  IF BIT_MASK ~= 0 THEN BIT_VALUE = BIT_VALUE&BIT_MASK;         00505600
                  TS = TS||BIT_TO_CHAR(BIT_VALUE)||X2;                          00505700
               END;                                                             00505800
               DO;     /* CHARACTER STRINGS */                                  00505900
               END;                                                             00506000
               DO;     /* SP INT */                                             00506100
                  IF SYM_MULT > 1 THEN                                          00506200
                     TS = TS||LPAD(GET_H(CUR_ADDR),6)||X2;                      00506300
                  ELSE TS = TS||GET_H(CUR_ADDR);                                00506400
               END;                                                             00506500
               DO;     /* DP INT */                                             00506600
                  IF SYM_MULT > 1 THEN                                          00506700
                     TS = TS||LPAD(GET_F(CUR_ADDR),9)||X2;                      00506800
                  ELSE TS = TS||GET_F(CUR_ADDR);                                00506900
               END;                                                             00507000
               DO;     /* SP SCALAR */                                          00507100
                  TS = TS||SCALAR_TO_CHAR(CUR_ADDR,0)||X2;                      00507200
               END;                                                             00507300
               DO;     /* DP SCALAR */                                          00507400
                  TS = TS||SCALAR_TO_CHAR(CUR_ADDR,8)||X2;                      00507500
               END;                                                             00507600
            END;                                                                00507700
            CUR_ADDR = CUR_ADDR + ADDR_BUMP;                                    00507800
            ITEM_CNT = ITEM_CNT - 1;                                            00507900
            IF ITEM_CNT = 0 THEN DO;                                            00508000
               OUTPUT = TS;                                                     00508100
               TS = TS_INIT;                                                    00508200
               ITEM_CNT = NUM_PER_LINE;                                         00508300
            END;                                                                00508400
         END;                                                                   00508500
         IF LENGTH(TS) > 35 THEN OUTPUT = TS;                                   00508600
      END;                                                                      00508700
   END PRINT_ITEM;                                                              00508800
                                                                                00508900
PRINT_NONHAL_ITEM:                                                              00509000
   PROCEDURE;                                                                   00509100
      IF TYPE = 0 THEN DO;                                                      00509200
         CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,0);                                 00509300
         RETURN;                                                                00509400
      END;                                                                      00509500
      QTYPE = TYPE;                                                             00509600
      NUM_PER_LINE = PER_LINE(QTYPE);                                           00509700
      CALL PRINT_ITEM;                                                          00509800
   END PRINT_NONHAL_ITEM;                                                       00509900
                                                                                00510000
PRINT_HAL_ITEM:                                                                 00510100
   PROCEDURE;                                                                   00510200
      DECLARE (K,L) FIXED;                                                      00510300
      IF (FLAG&"200")~=0 THEN DO;                                               00510400
         CALL PRINT_HEX(ADDR1,ADDR2-ADDR1+1,0);                                 00510500
         RETURN;                                                                00510600
      END;                                                                      00510700
      IF (FLAG&"04000000") ~= 0 THEN DO;                                        00510800
         NUM_PER_LINE = 1;                                                      00510900
         SYM_MULT = 1;                                                          00511000
         QTYPE = 18;                                                            00511100
      END;                                                                      00511200
      ELSE DO;                                                                  00511300
         QTYPE = TYPE;                                                          00511400
         NUM_PER_LINE = PER_LINE(QTYPE);                                        00511500
         IF TYPE = 17 THEN DO;                                                  00511600
            NUM_BITS = 1;                                                       00511700
            NUM_PER_LINE = 12;                                                  00511800
            BIT_SHIFT = 0;                                                      00511900
            BIT_MASK = 1;                                                       00512000
         END;                                                                   00512100
         ELSE IF (TYPE=1)|(TYPE=9)|(TYPE=10) THEN DO;                           00512200
            NUM_BITS = NODE_B(19);                                              00512300
            NUM_PER_LINE = 97/(NUM_BITS + 7);                                   00512400
            BIT_SHIFT = 0;                                                      00512500
            BIT_MASK = 0;                                                       00512600
            IF (FLAG&"00400000")~=0 THEN DO;                                    00512700
               IF NODE_B(18) ~= "FF" THEN BIT_SHIFT = NODE_B(18);               00512800
               IF NUM_BITS = 32 THEN BIT_MASK = -1;                             00512900
               ELSE DO;                                                         00513000
                  BIT_MASK = "7FFFFFFF";                                        00513100
                  IF NUM_BITS < 31 THEN BIT_MASK = SHR(BIT_MASK,32-NUM_BITS-1); 00513200
               END;                                                             00513300
            END;                                                                00513400
         END;                                                                   00513500
         SYM_MULT = 1;                                                          00513600
         IF (TYPE=4)|(TYPE=12) THEN DO;                                         00513700
            SYM_MULT = NODE_B(19);                                              00513800
            IF NODE_B(19) < NUM_PER_LINE THEN NUM_PER_LINE = NODE_B(19);        00513900
         END;                                                                   00514000
         ELSE IF (TYPE=3)|(TYPE=11) THEN DO;                                    00514100
            SYM_MULT = NODE_B(18) * NODE_B(19);                                 00514200
            IF NODE_B(19) < NUM_PER_LINE THEN NUM_PER_LINE = NODE_B(19);        00514300
         END;                                                                   00514400
         IF NODE_B(4) > 0 THEN DO;                                              00514500
            K = SHR(NODE_B(4),1);                                               00514600
            DO L = 1 TO NODE_H(K);                                              00514700
               SYM_MULT = SYM_MULT * NODE_H(K+L);                               00514800
            END;                                                                00514900
         END;                                                                   00515000
      END;                                                                      00515100
      CALL PRINT_ITEM;                                                          00515200
   END PRINT_HAL_ITEM;                                                          00515300
                                                                                00515400
                                                                                00515500
      CALL CESD_PROCESSING;   /* READ AND ORGANIZE CESD DATA */                 00515600
      CLOCK(2) = MONITOR(18);                                                   00515700
                                                                                00515800
   /* BUILD UP A LIST OF COMPLETE UNIT NAMES AND ESTABLISH MAPPING TABLES */    00515900
                                                                                00516000
      DO I = 1 TO #UNITS;                                                       00516100
         UNIT_SORT(I) = I;                                                      00516200
         BASIC_NAME = SUBSTR(SDF_NAMES(I),2);                                   00516300
         CALL SDF_SELECT(I);                                                    00516400
         COREWORD(ADDR(NODE_H)) = ADDRESS;                                      00516500
         REMOTE_TEMP = NODE_H(17);                                              00516600
         IF (NODE_H(0) & "0100") ~= 0 THEN NOTRACE_FLAG = TRUE;                 00516700
         ELSE NOTRACE_FLAG = FALSE;                                             00516800
         UNIT_NAMES(I) = KEEP(BLOCK_NAME(KEY_BLOCK));                           00516900
         COREWORD(ADDR(NODE_B)) = ADDRESS;                                      00517000
         UNIT_TYPE(I) = NODE_B(30);                                             00517100
         CALL PHASE_DET;                                                        00517200
         TS = '';                                                               00517300
         DO PH# = 1 TO NUM_PHASES;                                              00517400
            IF PHASE_TAB(PH#) > 1 THEN DO;                                      00517500
               PH_TEMP = SHL(PH#,24);                                           00517600
               IF FC_FLAG THEN DO;                                              00517700
                  IF REMOTE_TEMP ~= 0 THEN DO;                                  00517800
                     TS(2) = REMOTE_CSECT||BASIC_NAME;                          00517900
                     SLINK = #F#R(I);                                           00518000
                     CALL CHECK_MISSING;                                        00518100
                  END;                                                          00518200
               END;                                                             00518300
               EXCLUSIVE = FALSE;                                               00518400
               IF UNIT_TYPE(I) ~= 4 THEN DO;                                    00518500
                  DO J = 1 TO #PROCS;                                           00518600
                     TS = BLOCK_NAME(J);                                        00518700
                     COREWORD(ADDR(NODE_B)) = ADDRESS;                          00518800
                     IF (NODE_B(24)&"08")=0 THEN DO;                            00518900
                        IF (FC_FLAG = TRUE)&((NODE_B(24)&"40")~=0) THEN         00519000
                           EXCLUSIVE = TRUE;                                    00519100
                        SLINK = 0;                                              00519200
                        DO CASE NODE_B(30);                                     00519300
                           ;                                                    00519400
                           DO;   /* PROGRAM */                                  00519500
                              SLINK = #C$0(I);                                  00519600
                           END;                                                 00519700
                           DO;   /* PROCEDURE */                                00519800
                              IF J = KEY_BLOCK THEN SLINK = #C$0(I);            00519900
                              ELSE SLINK = PROC_TAB(I);                         00520000
                           END;                                                 00520100
                           DO;   /* FUNCTION */                                 00520200
                              IF J = KEY_BLOCK THEN SLINK = #C$0(I);            00520300
                              ELSE SLINK = PROC_TAB(I);                         00520400
                           END;                                                 00520500
                           ;                                                    00520600
                           DO;   /* TASK */                                     00520700
                              SLINK = TASK_TAB(I);                              00520800
                           END;                                                 00520900
                           DO;   /* UPDATE */                                   00521000
                              SLINK = PROC_TAB(I);                              00521100
                           END;                                                 00521200
                        END;                                                    00521300
                        TS(2) = STRING("07000000" + CSECTNAM);                  00521400
                        CALL CHECK_MISSING;                                     00521500
                     END;                                                       00521600
                  END;                                                          00521700
                  TS(2) = DATA_CSECT||BASIC_NAME;                               00521800
                  SLINK = #D#P(I);                                              00521900
                  CALL CHECK_MISSING;                                           00522000
                  IF EXCLUSIVE THEN DO;                                         00522100
                     TS(2) = EXCLUSIVE_CSECT||BASIC_NAME;                       00522200
                     SLINK = #X(I);                                             00522300
                     CALL CHECK_MISSING;                                        00522400
                  END;                                                          00522500
                  IF FC_FLAG THEN DO;                                           00522600
                     IF UNIT_TYPE(I) = 1 THEN DO;                               00522700
                        TS(2) = PDE_CSECT||BASIC_NAME;                          00522800
                        SLINK = #E(I);                                          00522900
                        CALL CHECK_MISSING;                                     00523000
                     END;                                                       00523100
                     ELSE DO;                                                   00523200
                        TS(2) = ZCON_CSECT||BASIC_NAME;                         00523300
                        SLINK = #T#Z(I);                                        00523400
                        CALL CHECK_MISSING;                                     00523500
                     END;                                                       00523600
                  END;                                                          00523700
                  ELSE DO;                                                      00523800
                     TS(2) = FSIM_CSECT||BASIC_NAME;                            00523900
                     SLINK = #F#R(I);                                           00524000
                     CALL CHECK_MISSING;                                        00524100
                     IF NOTRACE_FLAG = FALSE THEN DO;                           00524200
                        TS(2) = TIME_CSECT||BASIC_NAME;                         00524300
                        SLINK = #T#Z(I);                                        00524400
                        CALL CHECK_MISSING;                                     00524500
                     END;                                                       00524600
                  END;                                                          00524700
               END;                                                             00524800
               ELSE DO;                                                         00524900
                  TS(2) = COMPOOL_CSECT||BASIC_NAME;                            00525000
                  SLINK = #D#P(I);                                              00525100
                  CALL CHECK_MISSING;                                           00525200
               END;                                                             00525300
            END;                                                                00525400
         END;                                                                   00525500
         CALL CHECK_EXTRAN(#C$0(I));                                            00525600
         CALL CHECK_EXTRAN(#D#P(I));                                            00525700
         CALL CHECK_EXTRAN(#F#R(I));                                            00525800
         IF ~FC_FLAG THEN CALL CHECK_EXTRAN(#T#Z(I));                           00525900
         CALL CHECK_EXTRAN(#E(I));                                              00526000
         CALL CHECK_EXTRAN(#X(I));                                              00526100
         CALL CHECK_EXTRAN(TASK_TAB(I));                                        00526200
         CALL CHECK_EXTRAN(PROC_TAB(I));                                        00526300
      END;                                                                      00526400
                                                                                00526500
   /* ALPHABETIZE THE COMPILATION UNITS ACCORDING TO THEIR FULL NAMES */        00526600
                                                                                00526700
      M = SHR(#UNITS,1);                                                        00526800
      DO WHILE M > 0;                                                           00526900
         DO J = 1 TO #UNITS - M;                                                00527000
            I = J;                                                              00527100
            DO WHILE STRING_GT(UNIT_NAMES(UNIT_SORT(I)),                        00527200
               UNIT_NAMES(UNIT_SORT(I+M)));                                     00527300
               L = UNIT_SORT(I);                                                00527400
               UNIT_SORT(I) = UNIT_SORT(I+M);                                   00527500
               UNIT_SORT(I+M) = L;                                              00527600
               I = I - M;                                                       00527700
               IF I < 1 THEN GO TO LMY;                                         00527800
            END;                                                                00527900
LMY:                                                                            00528000
         END;                                                                   00528100
         M = SHR(M,1);                                                          00528200
      END;                                                                      00528300
                                                                                00528400
      CLOCK(3) = MONITOR(18);                                                   00528500
                                                                                00528600
   /* PROCESS USER SUPPLIED TEXT INPUT (IF ANY) */                              00528700
                                                                                00528800
      FIRST = "01";                                                             00528900
      GOT_UNIT,GOT_BLK,GOT_VAR = 0;                                             00529000
      TEXT_FLAG = FALSE;                                                        00529100
      PREV_CHAR = AT_SIGN;                                                      00529200
      SIGNAL = TRUE;                                                            00529300
      DO FOREVER;                                                               00529400
         CONTROL_CARD = INPUT(2);                                               00529500
         IF CONTROL_CARD = '' THEN DO;                                          00529600
            IF TEXT_FLAG THEN CALL DO_ALLOCATE;                                 00529700
            GO TO NO_TEXT_INPUT;                                                00529800
         END;                                                                   00529900
         THIS_CHAR = SUBSTR(CONTROL_CARD,0,1);                                  00530000
         IF (THIS_CHAR ~= X1)&(THIS_CHAR ~= XCHAR) THEN DO;                     00530100
            IF TEXT_FLAG THEN CALL DO_ALLOCATE;                                 00530200
            WORK_STRING = EXTRACT(CONTROL_CARD);                                00530300
            IF THIS_CHAR = UCHAR THEN DO;                                       00530400
               GOT_BLK,GOT_VAR = 0;                                             00530500
               GOT_UNIT,I = GET_UNIT_NDX_BY_NAME(WORK_STRING);                  00530600
               IF GOT_UNIT = 0 THEN DO;                                         00530700
                  TS = 'UNIT NOT FOUND: '||WORK_STRING;                         00530800
                  CALL TEXT_ERROR(TS,0);                                        00530900
                  GO TO READ_NEXT_CARD;                                         00531000
               END;                                                             00531100
               IF FILE_LEVEL > 0 THEN DO;                                       00531200
                  #U_CMDS = #U_CMDS + 1;                                        00531300
                  UNIT_FLAGS(I) = UNIT_FLAGS(I) | "80";                         00531400
               END;                                                             00531500
               CALL SDF_SELECT(I);                                              00531600
               GOT_BLK,BLKNO = KEY_BLOCK;                                       00531700
               CALL MONITOR(22,8);                                              00531800
               IF TEXT_BASE(I) = 0 THEN DO;                                     00531900
                  TEXT_BASE(I) = VMEM_ALLOC_STRUC(1,#SYMBOLS+1,1,8,'',0,0);     00532000
               END;                                                             00532100
            END;                                                                00532200
            ELSE IF GOT_UNIT ~= 0 THEN DO;                                      00532300
               IF THIS_CHAR = BCHAR THEN DO;                                    00532400
                  GOT_BLK,GOT_VAR = 0;                                          00532500
                  TMP = LENGTH(WORK_STRING);                                    00532600
                  BLKNLEN = TMP;                                                00532700
                  CALL MOVE(TMP,WORK_STRING,BLKNAM);                            00532800
                  CALL MONITOR(22,11);                                          00532900
                  IF CRETURN = 0 THEN GOT_BLK = BLKNO;                          00533000
                  ELSE DO;                                                      00533100
                     TS = 'BLOCK NOT FOUND: '||WORK_STRING;                     00533200
                     CALL TEXT_ERROR(TS,0);                                     00533300
                  END;                                                          00533400
               END;                                                             00533500
               ELSE IF (GOT_BLK~=0)&(THIS_CHAR=VCHAR) THEN DO;                  00533600
                  GOT_VAR = 0;                                                  00533700
                  IF BYTE(WORK_STRING) = BYTE(AT_SIGN) THEN                     00533800
                     BYTE(WORK_STRING) = BYTE(X1);                              00533900
                  TMP = LENGTH(WORK_STRING);                                    00534000
                  SYMBNLEN = TMP;                                               00534100
                  CALL MOVE(TMP,WORK_STRING,SYMBNAM);                           00534200
                  CALL MONITOR(22,13);                                          00534300
                  IF CRETURN = 0 THEN GOT_VAR = SYMBNO;                         00534400
                  ELSE DO;                                                      00534500
                     TS = 'SYMBOL NOT FOUND: '||WORK_STRING;                    00534600
                     CALL TEXT_ERROR(TS,0);                                     00534700
                  END;                                                          00534800
               END;                                                             00534900
            END;                                                                00535000
         END;                                                                   00535100
         ELSE IF GOT_UNIT ~= 0 THEN DO;                                         00535200
            IF TEXT_FLAG = FALSE THEN DO;                                       00535300
               IF (PREV_CHAR=UCHAR)|((PREV_CHAR=VCHAR)&(GOT_VAR~=0)) THEN DO;   00535400
                  BUFF_ADDR = FILE1_BUFF_ADDR;                                  00535500
                  TEXT_FLAG = TRUE;                                             00535600
                  TEXT_SIZE = 0;                                                00535700
                  EXTENSION_PTR = 0;                                            00535800
                  NUM_LINES = 0;                                                00535900
               END;                                                             00536000
            END;                                                                00536100
            IF TEXT_FLAG THEN DO;                                               00536200
               IF TEXT_SIZE > 960 THEN DO;                                      00536300
                  CALL DO_ALLOCATE;                                             00536400
                  TEXT_FLAG = TRUE;                                             00536500
                  TEXT_SIZE = 0;                                                00536600
                  NUM_LINES = 0;                                                00536700
                  BUFF_ADDR = FILE1_BUFF_ADDR;                                  00536800
               END;                                                             00536900
               NUM_LINES = NUM_LINES + 1;                                       00537000
               IF THIS_CHAR = XCHAR THEN DO;                                    00537100
                  CALL MOVE(40,CONTROL_CARD,BUFF_ADDR);                         00537200
                  TMP = COREWORD(ADDR(CONTROL_CARD)) + 72;                      00537300
                  CALL MOVE(8,TMP,BUFF_ADDR + 40);                              00537400
                  BUFF_ADDR = BUFF_ADDR + 48;                                   00537500
                  TEXT_SIZE = TEXT_SIZE + 48;                                   00537600
               END;                                                             00537700
               ELSE DO;                                                         00537800
                  CALL MOVE(80,CONTROL_CARD,BUFF_ADDR);                         00537900
                  BUFF_ADDR = BUFF_ADDR + 80;                                   00538000
                  TEXT_SIZE = TEXT_SIZE + 80;                                   00538100
               END;                                                             00538200
            END;                                                                00538300
         END;                                                                   00538400
READ_NEXT_CARD:                                                                 00538500
         PREV_CHAR = THIS_CHAR;                                                 00538600
      END;                                                                      00538700
NO_TEXT_INPUT:                                                                  00538800
                                                                                00538900
   /* PROCESS HALSTAT CONTROL CARDS */                                          00539000
                                                                                00539100
      CALL RESET;                                                               00539200
      OUTPUT(1) = ONE;                                                          00539300
      CALL SCAN;                                                                00539400
      SAVE_SEVERE_ERRORS = SEVERE_ERRORS;                                       00539500
      CALL COMPILATION_LOOP;                                                    00539600
      IF SAVE_SEVERE_ERRORS ~= SEVERE_ERRORS THEN DO;                           00539700
         SPACE_1;                                                               00539800
         OUTPUT = '*** SEVERE ERRORS ENCOUNTERED IN SYSIN INPUT ***';           00539900
         GO TO BAIL_OUT;                                                        00540000
      END;                                                                      00540100
                                                                                00540200
   /* IF NO MAP COMMANDS HAVE BEEN INPUTTED, SEE IF ONE MUST BE GENERATED */    00540300
                                                                                00540400
      IF (#MAP_CMDS = 0) & (MAP_LEVEL > 0) THEN DO;                             00540500
         #MAP_CMDS = 1;                                                         00540600
         IF #CONFIGS > 0 THEN MAP_CMD_TYPE(1) = 1;                              00540700
         ELSE MAP_CMD_TYPE(1) = 2;                                              00540800
         MAP_CMD_LEVEL(1) = MAP_LEVEL;                                          00540900
         MAP_CMD_FMT(1) = MFORMAT;                                              00541000
         MAP_CMD_ADDR1(1) = 0;                                                  00541100
         MAP_CMD_ADDR2(1) = "003FFFFF";                                         00541200
         MAP_CMD_UTIL(1) = 0;                                                   00541300
      END;                                                                      00541400
      MAX_MAP_LEVEL = 0;                                                        00541500
      DO I = 1 TO #MAP_CMDS;                                                    00541600
         IF MAP_CMD_LEVEL(I) > MAX_MAP_LEVEL THEN                               00541700
            MAX_MAP_LEVEL = MAP_CMD_LEVEL(I);                                   00541800
      END;                                                                      00541900
                                                                                00542000
   /* PROCESS REMAINING LOAD MODULE DATA */                                     00542100
                                                                                00542200
SYM_LINKER:                                                                     00542300
   PROCEDURE;                                                                   00542400
      IF GSD_LEVEL > 2 THEN DO;                                                 00542500
         IF SYM_NAME ~= X8 THEN DO;                                             00542600
            IF SUBSTR(SYM_NAME,0,4) ~= '#@LB' THEN DO;                          00542700
               IF SUBSTR(SYM_NAME,0,4) ~= '$RET' THEN DO;                       00542800
                  CALL VMEM_NEXT_COPY(SYSTEM,MODF);                             00542900
                  SEQ_F(0) = SYM_NAME_BUFF(0);                                  00543000
                  SEQ_F(1) = SYM_NAME_BUFF(1);                                  00543100
                  SEQ_H(4) = SYM_CSECT_ID;                                      00543200
                  SEQ_F(3) = PTR;                                               00543300
               END;                                                             00543400
            END;                                                                00543500
         END;                                                                   00543600
      END;                                                                      00543700
      NODE_F(2) = SYM_NAME_BUFF(0);                                             00543800
      NODE_F(3) = SYM_NAME_BUFF(1);                                             00543900
      NODE_F(4) = SHL(SYM_ORG,24)|SYM_ADDR;                                     00544000
      IF CSECT_APTR1(SYM_CSECT_ID) = 0 THEN DO;                                 00544100
         CSECT_APTR1(SYM_CSECT_ID) = PTR;                                       00544200
         CSECT_APTR2(SYM_CSECT_ID) = PTR;                                       00544300
      END;                                                                      00544400
      ELSE DO;                                                                  00544500
         CALL VMEM_LOCATE_PTR(1,CSECT_APTR2(SYM_CSECT_ID),0);                   00544600
         COREWORD(ADDR(NODE_F1)) = VMEM_LOC_ADDR;                               00544700
         IF (NODE_F1(4)&"FFFFFF") <= SYM_ADDR THEN DO;                          00544800
            NODE_F1(1) = PTR;                                                   00544900
            CALL VMEM_DISP(MODF);                                               00545000
            CSECT_APTR2(SYM_CSECT_ID) = PTR;                                    00545100
         END;                                                                   00545200
         ELSE IF FALSE THEN DO;                                                 00545300
            SAVE_PNTR = 0;                                                      00545400
            TOTAL_SYM_REC_INSERT = TOTAL_SYM_REC_INSERT + 1;                    00545500
            PTR1 = CSECT_APTR1(SYM_CSECT_ID);                                   00545600
            DO WHILE PTR1 ~= 0;                                                 00545700
               CALL VMEM_LOCATE_PTR(1,PTR1,0);                                  00545800
               COREWORD(ADDR(NODE_F1)) = VMEM_LOC_ADDR;                         00545900
               IF (NODE_F1(4)&"FFFFFF") > SYM_ADDR THEN DO;                     00546000
                  NODE_F(1) = PTR1;                                             00546100
                  IF SAVE_PNTR = 0 THEN CSECT_APTR1(SYM_CSECT_ID)=PTR;          00546200
                  ELSE DO;                                                      00546300
                     CALL VMEM_LOCATE_PTR(1,SAVE_PNTR,MODF);                    00546400
                     VMEM_F(1) = PTR;                                           00546500
                  END;                                                          00546600
                  GO TO INSERT_DONE;                                            00546700
               END;                                                             00546800
               SAVE_PNTR = PTR1;                                                00546900
               PTR1 = NODE_F1(1);                                               00547000
            END;                                                                00547100
         END;                                                                   00547200
      END;                                                                      00547300
INSERT_DONE:                                                                    00547400
      CALL VMEM_LOCATE_PTR(1,PTR,RELS);                                         00547500
   END SYM_LINKER;                                                              00547600
                                                                                00547700
      IF MAX_MAP_LEVEL > 0 THEN DO;                                             00547800
         M = SHR(#CSECTS,1);                                                    00547900
         DO WHILE M > 0;                                                        00548000
            DO J = 1 TO #CSECTS - M;                                            00548100
               I = J;                                                           00548200
               DO WHILE (CSECT_ADDR(CSECT_SORT(I))&"FFFFFF") >                  00548300
                  (CSECT_ADDR(CSECT_SORT(I+M))&"FFFFFF");                       00548400
                  L = CSECT_SORT(I);                                            00548500
                  CSECT_SORT(I) = CSECT_SORT(I + M);                            00548600
                  CSECT_SORT(I + M) = L;                                        00548700
                  I = I - M;                                                    00548800
                  IF I < 1 THEN GO TO LMU;                                      00548900
               END;                                                             00549000
LMU:                                                                            00549100
            END;                                                                00549200
            M = SHR(M,1);                                                       00549300
         END;                                                                   00549400
         IF MAX_MAP_LEVEL > 3 THEN DO;                                          00549500
            M = SHR(#CSECTS,1);                                                 00549600
            DO WHILE M > 0;                                                     00549700
               DO J = 1 TO #CSECTS - M;                                         00549800
                  I = J;                                                        00549900
                  DO WHILE (CSECT_ESDID(CSECT_SORTZ(I))) >                      00550000
                     (CSECT_ESDID(CSECT_SORTZ(I+M)));                           00550100
                     L = CSECT_SORTZ(I);                                        00550200
                     CSECT_SORTZ(I) = CSECT_SORTZ(I + M);                       00550300
                     CSECT_SORTZ(I + M) = L;                                    00550400
                     I = I - M;                                                 00550500
                     IF I < 1 THEN GO TO LMV;                                   00550600
                  END;                                                          00550700
LMV:                                                                            00550800
               END;                                                             00550900
               M = SHR(M,1);                                                    00551000
            END;                                                                00551100
         END;                                                                   00551200
      END;                                                                      00551300
      M = SHR(#CSECTS,1);                                                       00551400
      DO WHILE M > 0;                                                           00551500
         DO J = 1 TO (#CSECTS - M);                                             00551600
            I = J;                                                              00551700
            DO FOREVER;                                                         00551800
               TMP = SHL(CSECT_SORTX(I),1);                                     00551900
               S1 = STRING("07000000" + ADDR(CSECT_CHAR(TMP)));                 00552000
               TMP = SHL(CSECT_SORTX(I+M),1);                                   00552100
               S2 = STRING("07000000" + ADDR(CSECT_CHAR(TMP)));                 00552200
               IF S1 <= S2 THEN GO TO LMW;                                      00552300
               L = CSECT_SORTX(I);                                              00552400
               CSECT_SORTX(I) = CSECT_SORTX(I + M);                             00552500
               CSECT_SORTX(I + M) = L;                                          00552600
               I = I - M;                                                       00552700
               IF I < 1 THEN GO TO LMW;                                         00552800
            END;                                                                00552900
LMW:                                                                            00553000
         END;                                                                   00553100
         M = SHR(M,1);                                                          00553200
      END;                                                                      00553300
                                                                                00553400
   /* IF GSD_LEVEL > 2 THEN ALLOCATE THE SYM STRUCTURE */                       00553500
                                                                                00553600
      IF GSD_LEVEL > 2 THEN DO;                                                 00553700
         SYM_STRUC_PTR = VMEM_ALLOC_STRUC(2,0,0,0,'SYM STRUCTURE',              00553800
            ADDR(SYM_DESCRIPT),FAST);                                           00553900
         CALL VMEM_SEQ_OPEN(2,SYM_STRUC_PTR,SYSTEM,0,0);                        00554000
      END;                                                                      00554100
      SYM_NAME = STRING("07000000" + ADDR(SYM_NAME_BUFF));                      00554200
      SYM_CSECT_FLAG = FALSE;                                                   00554300
      SYM_DSECT_FLAG = FALSE;                                                   00554400
      SYM_STACK_FLAG = FALSE;                                                   00554500
      CALL MONITOR(2,8,LMOD);                                                   00554600
      DO WHILE MONITOR(24,FILE1_BUFF_ADDR);                                     00554700
         RECORD_ADDR = FILE1_BUFF_ADDR;                                         00554800
         LMOD_REC_TYPE = COREBYTE(RECORD_ADDR);                                 00554900
         DO CASE SHR(LMOD_REC_TYPE,4)&"F";                                      00555000
            DO;     /* CONTROL/RLD */                                           00555100
               TMP = COREWORD(RECORD_ADDR+4);                                   00555200
               CNTL_CNT = SHR(TMP,16)&"FFFF";                                   00555300
               RLD_CNT = TMP & "FFFF";                                          00555400
               CCW_ADDR = COREWORD(RECORD_ADDR+8)&"FFFFFF";                     00555500
               IF FC_FLAG THEN CCW_ADDR = SHR(CCW_ADDR,1);                      00555600
               RECORD_ADDR = RECORD_ADDR + 16;                                  00555700
               IF RLD_CNT > 0 THEN DO;                                          00555800
                  SAVE_ADDR,RLD_ADDR = RECORD_ADDR;                             00555900
                  RECORD_ADDR = RECORD_ADDR + RLD_CNT;                          00556000
               END;                                                             00556100
               IF CNTL_CNT > 0 THEN DO;                                         00556200
                  #ENTRIES = SHR(CNTL_CNT,2);                                   00556300
                  DO I = 1 TO #ENTRIES;                                         00556400
                     TMP = KOREWORD(RECORD_ADDR);                               00556500
                     CNTL_BUFF1(I) = SHR(TMP,16)&"FFFF";                        00556600
                     CNTL_BUFF2(I) = TMP&"FFFF";                                00556700
                     RECORD_ADDR = RECORD_ADDR + 4;                             00556800
                  END;                                                          00556900
                  CALL MONITOR(24,FILE1_BUFF_ADDR);                             00557000
                  IF MAX_MAP_LEVEL > 3 THEN DO;                                 00557100
                     RECORD_ADDR = FILE1_BUFF_ADDR;                             00557200
                     DO I = 1 TO #ENTRIES;                                      00557300
                        TMP = CNTL_BUFF1(I);                                    00557400
                        CCW_ADDR_AUG = CNTL_BUFF2(I);                           00557500
                        IF FC_FLAG THEN CCW_ADDR_AUG =                          00557600
                           SHR(CCW_ADDR_AUG,1);                                 00557700
                        J = GET_CSECT_NDX_BY_ESDID(TMP);                        00557800
                        IF J = 0 THEN GO TO NEXT_TEXT;                          00557900
                        BASE_ADDR = CCW_ADDR;                                   00558000
                        TEMP_ADDR = RECORD_ADDR;                                00558100
                        TEMP1 = CNTL_BUFF2(I);                                  00558200
                        DO WHILE TEMP1 ~= 0;                                    00558300
                           IF TEMP1 > 1024 THEN TEMP2 = 1024;                   00558400
                           ELSE TEMP2 = TEMP1;                                  00558500
                           TEMP3 = TEMP2;                                       00558600
                           IF FC_FLAG THEN TEMP3 = SHR(TEMP3,1);                00558700
                           PTR = VMEM_ALLOC_CELL(1,TEMP2+12,0);                 00558800
                           COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;              00558900
                           NODE_F(1) = BASE_ADDR;                               00559000
                           NODE_F(2) = BASE_ADDR + TEMP3 - 1;                   00559100
                           CALL MOVE(TEMP2,TEMP_ADDR,VMEM_LOC_ADDR+12);         00559200
                           LINK = CSECT_TEXT_PTR(J);                            00559300
                           IF LINK = 0 THEN                                     00559400
                              CSECT_TEXT_PTR(J) = PTR;                          00559500
                           ELSE DO;                                             00559600
                              DO WHILE LINK ~= 0;                               00559700
                                 CALL VMEM_LOCATE_PTR(1,LINK,0);                00559800
                                 COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;        00559900
                                 LINK = NODE_F(0);                              00560000
                              END;                                              00560100
                              NODE_F(0) = PTR;                                  00560200
                              CALL VMEM_DISP(MODF);                             00560300
                           END;                                                 00560400
                           TEMP1 = TEMP1 - TEMP2;                               00560500
                           BASE_ADDR = BASE_ADDR + TEMP3;                       00560600
                           TEMP_ADDR = TEMP_ADDR + TEMP2;                       00560700
                        END;                                                    00560800
NEXT_TEXT:                                                                      00560900
                        CCW_ADDR = CCW_ADDR + CCW_ADDR_AUG;                     00561000
                        RECORD_ADDR = RECORD_ADDR + CNTL_BUFF2(I);              00561100
                     END;                                                       00561200
                  END;                                                          00561300
               END;                                                             00561400
               IF (LMOD_REC_TYPE&"08") ~= 0 THEN                                00561500
                  GO TO END_LOAD_MODULE;                                        00561600
            END;                                                                00561700
            DO;     /* PHASE RECORD */                                          00561800
            END;                                                                00561900
            DO;     /* CESD RECORD */                                           00562000
               IF MAX_MAP_LEVEL < 4 THEN GO TO END_LOAD_MODULE;                 00562100
            END;                                                                00562200
            DO;     /* UNUSED */                                                00562300
            END;                                                                00562400
            DO;     /* SYM RECORD */                                            00562500
               ADDR_LIM = RECORD_ADDR + 4 +                                     00562600
                  (COREWORD(RECORD_ADDR)&"FFFF");                               00562700
               RECORD_ADDR = RECORD_ADDR + 4;                                   00562800
               DO WHILE RECORD_ADDR < ADDR_LIM;                                 00562900
                  TOTAL_SYM_REC = TOTAL_SYM_REC + 1;                            00563000
                  SYM_ORG = COREBYTE(RECORD_ADDR);                              00563100
                  SYM_ADDR = 0;                                                 00563200
                  DO I = 1 TO 3;                                                00563300
                     SYM_ADDR = SHL(SYM_ADDR,8) +                               00563400
                        COREBYTE(RECORD_ADDR + I);                              00563500
                  END;                                                          00563600
                  IF FC_FLAG THEN SYM_ADDR = SHR(SYM_ADDR,1);                   00563700
                  RECORD_ADDR = RECORD_ADDR + 4;                                00563800
                  SYM_NAME_BUFF(0),SYM_NAME_BUFF(1) = "40404040";               00563900
                  IF (SYM_ORG & "08") = 0 THEN DO;                              00564000
                     SYM_NAME_LEN = SYM_ORG & "07";                             00564100
                     CALL MOVE(SYM_NAME_LEN+1,RECORD_ADDR,                      00564200
                        ADDR(SYM_NAME_BUFF(0)));                                00564300
                     RECORD_ADDR = RECORD_ADDR + SYM_NAME_LEN + 1;              00564400
                  END;                                                          00564500
                  IF (SYM_ORG & "80") = 0 THEN DO;                              00564600
                     NDATA_TYPE = SHR(SYM_ORG & "70",4);                        00564700
                     DO CASE NDATA_TYPE;                                        00564800
                        DO;     /* SPACE */                                     00564900
                           RECORD_ADDR = RECORD_ADDR + 1;                       00565000
                        END;                                                    00565100
                        DO;     /* CSECT */                                     00565200
                           SYM_CSECT_FLAG = FALSE;                              00565300
                           SYM_DSECT_FLAG = FALSE;                              00565400
                           SYM_CSECT_ID = GET_CSECT_NDX_BY_NAME(SYM_NAME);      00565500
                           IF SYM_CSECT_ID ~= 0 THEN SYM_CSECT_FLAG = TRUE;     00565600
                        END;                                                    00565700
                        DO;     /* DSECT */                                     00565800
                           SYM_CSECT_FLAG = FALSE;                              00565900
                           SYM_DSECT_FLAG = TRUE;                               00566000
                           IF SYM_NAME = 'STACK   ' THEN SYM_STACK_FLAG = TRUE; 00566100
                           ELSE SYM_STACK_FLAG = FALSE;                         00566200
                        END;                                                    00566300
                        DO;     /* COMMON */                                    00566400
                           SYM_CSECT_FLAG = FALSE;                              00566500
                           SYM_DSECT_FLAG = FALSE;                              00566600
                        END;                                                    00566700
                        DO;     /* INSTRUCTION */                               00566800
                        END;                                                    00566900
                        DO;     /* CCW */                                       00567000
                        END;                                                    00567100
                        ;;                                                      00567200
                     END;                                                       00567300
                     IF (SYM_CSECT_ID~=0)&(SYM_CSECT_FLAG=TRUE) THEN DO;        00567400
                        IF NDATA_TYPE > 3 THEN DO;                              00567500
                           TMP = SHR(CSECT_ADDR(SYM_CSECT_ID),24)&"FF";         00567600
                           IF (TMP=0)|(TMP>14) THEN DO;                         00567700
                              IF (MAX_MAP_LEVEL > 2)|(GSD_LEVEL > 2) THEN DO;   00567800
                                 PTR = VMEM_ALLOC_CELL(1,20,RESV);              00567900
                                 COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;        00568000
                                 CALL SYM_LINKER;                               00568100
                              END;                                              00568200
                           END;                                                 00568300
                        END;                                                    00568400
                     END;                                                       00568500
                  END;                                                          00568600
                  ELSE IF SYM_CSECT_ID ~= 0 THEN DO;                            00568700
                     IF (SYM_DSECT_FLAG=TRUE)&(SYM_STACK_FLAG=TRUE) THEN DO;    00568800
                        IF SYM_NAME = 'STACKEND' THEN                           00568900
                           CSECT_STACK_REQ(SYM_CSECT_ID) = SYM_ADDR;            00569000
                     END;                                                       00569100
                     IF (SYM_ORG & "40") ~= 0 THEN SYM_MULT_FLAG = TRUE;        00569200
                     ELSE SYM_MULT_FLAG = FALSE;                                00569300
                     IF (SYM_ORG & "10") ~= 0 THEN SYM_SCAL_FLAG = TRUE;        00569400
                     ELSE SYM_SCAL_FLAG = FALSE;                                00569500
                     SYM_DATA_TYPE = COREBYTE(RECORD_ADDR);                     00569600
                     RECORD_ADDR = RECORD_ADDR + 1;                             00569700
                     SYM_SP = 0;                                                00569800
                     IF SYM_DATA_TYPE = "80" THEN DO;                           00569900
                        SYM_SP = 1;                                             00570000
                     END;                                                       00570100
                     ELSE IF SYM_DATA_TYPE = "84" THEN DO;                      00570200
                        SYM_SP = 2;                                             00570300
                     END;                                                       00570400
                     IF SYM_SP = 0 THEN DO;                                     00570500
                        SYM_DATA_DEX = SHR(SYM_DATA_TYPE,2);                    00570600
                        IF SYM_DATA_DEX < 3 THEN DO;                            00570700
                           SYM_DATA_LEN = COREBYTE(RECORD_ADDR);                00570800
                           SYM_DATA_LEN = SHL(SYM_DATA_LEN,8) +                 00570900
                              COREBYTE(RECORD_ADDR + 1) + 1;                    00571000
                           RECORD_ADDR = RECORD_ADDR + 2;                       00571100
                        END;                                                    00571200
                        ELSE DO;                                                00571300
                           SYM_DATA_LEN = COREBYTE(RECORD_ADDR) + 1;            00571400
                           RECORD_ADDR = RECORD_ADDR + 1;                       00571500
                        END;                                                    00571600
                        IF FC_FLAG THEN SYM_DATA_LEN = SHR(SYM_DATA_LEN,1);     00571700
                     END;                                                       00571800
                     SYM_MULT = 0;                                              00571900
                     IF SYM_MULT_FLAG THEN DO;                                  00572000
                        DO I = 0 TO 2;                                          00572100
                           SYM_MULT = SHL(SYM_MULT,8) +                         00572200
                              COREBYTE(RECORD_ADDR + I);                        00572300
                        END;                                                    00572400
                        RECORD_ADDR = RECORD_ADDR + 3;                          00572500
                     END;                                                       00572600
                     ELSE SYM_MULT = 1;                                         00572700
                     SYM_SCAL = 0;                                              00572800
                     IF SYM_SCAL_FLAG THEN DO;                                  00572900
                        DO I = 0 TO 1;                                          00573000
                           SYM_SCAL = SHL(SYM_SCAL,8) +                         00573100
                              COREBYTE(RECORD_ADDR + I);                        00573200
                        END;                                                    00573300
                        RECORD_ADDR = RECORD_ADDR + 2;                          00573400
                     END;                                                       00573500
                     IF (SYM_CSECT_FLAG=TRUE)&(SYM_SP=0) THEN DO;               00573600
                        TMP = SHR(CSECT_ADDR(SYM_CSECT_ID),24)&"FF";            00573700
                        IF (TMP=0)|(TMP>14) THEN DO;                            00573800
                           IF (SYM_MULT>0)|(SYM_NAME~=X8) THEN DO;              00573900
                              IF SYM_DATA_LEN = 0 THEN DO;  /* FIX ANDY */      00574000
                                 SYM_DATA_LEN = 1;                              00574100
                                 SYM_DATA_DEX = 9;                              00574200
                              END;                                              00574300
                              IF (MAX_MAP_LEVEL > 2)|(GSD_LEVEL > 2) THEN DO;   00574400
                                 PTR = VMEM_ALLOC_CELL(1,28,RESV);              00574500
                                 COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;        00574600
                                 COREWORD(ADDR(NODE_H)) = VMEM_LOC_ADDR;        00574700
                                 NODE_F(5) = SHL(SYM_DATA_DEX,24)|SYM_MULT;     00574800
                                 NODE_H(12) = SYM_DATA_LEN;                     00574900
                                 NODE_H(13) = SYM_SCAL;                         00575000
                                 CALL SYM_LINKER;                               00575100
                              END;                                              00575200
                           END;                                                 00575300
                        END;                                                    00575400
                     END;                                                       00575500
                  END;                                                          00575600
               END;                                                             00575700
            END;                                                                00575800
            DO;     /* UNUSED */                                                00575900
            END;                                                                00576000
            DO;     /* UNUSED */                                                00576100
            END;                                                                00576200
            DO;     /* UNUSED */                                                00576300
            END;                                                                00576400
            DO;     /* IDR RECORD */                                            00576500
            END;                                                                00576600
            ;;;;;;;                                                             00576700
         END;                                                                   00576800
      END;                                                                      00576900
END_LOAD_MODULE:                                                                00577000
      CALL MONITOR(3,8);                                                        00577100
                                                                                00577200
   /* ENSURE THAT IF A CSECT HAS SYM CARD ENTRIES, THAT ALL APPEARANCES OF  */  00577300
   /* THAT CSECT POINTS TO THE SAME SYM CARD ENTRIES (I.E., OTHER PHASES)   */  00577400
                                                                                00577500
      IF MAX_PHASE > 1 THEN DO;                                                 00577600
         DO I = 1 TO #CSECTS;                                                   00577700
            J = CSECT_SORTX(I);                                                 00577800
            IF CSECT_APTR1(J) ~= 0 THEN DO;                                     00577900
               TMP = CSECT_APTR1(J);                                            00578000
               S1 = STRING("07000000" + ADDR(CSECT_CHAR(SHL(J,1))));            00578100
               K = I - 1;                                                       00578200
               DO WHILE K > 0;                                                  00578300
                  L = CSECT_SORTX(K);                                           00578400
                  S2 = STRING("07000000" + ADDR(CSECT_CHAR(SHL(L,1))));         00578500
                  IF S1 ~= S2 THEN GO TO EXIT1;                                 00578600
                  CSECT_APTR1(L) = TMP;                                         00578700
                  K = K - 1;                                                    00578800
               END;                                                             00578900
EXIT1:                                                                          00579000
               K = I + 1;                                                       00579100
               DO WHILE K <= #CSECTS;                                           00579200
                  L = CSECT_SORTX(K);                                           00579300
                  S2 = STRING("07000000" + ADDR(CSECT_CHAR(SHL(L,1))));         00579400
                  IF S1 ~= S2 THEN GO TO EXIT2;                                 00579500
                  CSECT_APTR1(L) = TMP;                                         00579600
                  K = K + 1;                                                    00579700
               END;                                                             00579800
EXIT2:                                                                          00579900
               I = K - 1;                                                       00580000
            END;                                                                00580100
         END;                                                                   00580200
      END;                                                                      00580300
                                                                                00580400
   /* FINISH OFF SYM RECORD PROCESSING */                                       00580500
                                                                                00580600
      IF GSD_LEVEL > 2 THEN DO;                                                 00580700
         CALL VMEM_SEQ_CLOSE(SYSTEM);                                           00580800
         CALL VMEM_FIX_STRUC(2,SYM_STRUC_PTR);                                  00580900
         CALL VMEM_SORT_STRUC(2,SYM_STRUC_PTR,0,6,8,INPLACE);                   00581000
      END;                                                                      00581100
                                                                                00581200
   /* LIBERATE THE AUX BUFFER FOR VIR. MEM. PAGING */                           00581300
                                                                                00581400
      IF VMEM_MAX_PAD < VMEM_LIM_PAGES THEN DO;                                 00581500
         VMEM_MAX_PAD = VMEM_MAX_PAD + 1;                                       00581600
        VMEM_PAD_ADDR(VMEM_MAX_PAD) = AUX_BUFF_ADDR;                            00581700
      END;                                                                      00581800
                                                                                00581900
   /* SET UP MISC ALLOCATIONS FOR ALL NON-SUPPRESSED COMPILATION UNITS */       00582000
                                                                                00582100
      IF (GSD_LEVEL + FILE_LEVEL) > 0 THEN DO;                                  00582200
         DO I = 1 TO #UNITS;                                                    00582300
            CALL SDF_SELECT(I);                                                 00582400
            IF (UNIT_FLAGS(I)&"0010") = 0 THEN DO;                              00582500
               COREWORD(ADDR(NODE_H)) = ADDRESS;                                00582600
               ADDR_LINK = NODE_H(16);                                          00582700
               IF (GSD_LEVEL + FILE_LEVEL) > 0 THEN DO;                         00582800
                  MAP_BASE(I) = VMEM_ALLOC_STRUC(1,#SYMBOLS,1,8,'',0,0);        00582900
                  IF UNIT_TYPE(I) = 4 THEN                                      00583000
                     VAR_BASE(I) = VMEM_ALLOC_STRUC(1,#SYMBOLS,1,8,'',0,0);     00583100
                  ELSE VAR_BASE(I) = VMEM_ALLOC_STRUC(1,1,1,8,'',0,0);          00583200
               END;                                                             00583300
            END;                                                                00583400
         END;                                                                   00583500
      END;                                                                      00583600
                                                                                00583700
   /* ALLOCATE BUFFERS FOR PROCESSING OF REPLACE TEXT */                        00583800
                                                                                00583900
      REPL_TEXT_PTR1 = VMEM_ALLOC_STRUC(1,1,6216,6,'',0,0);                     00584000
      CALL VMEM_LOCATE_PTR(1,REPL_TEXT_PTR1,RESV|MODF);                         00584100
      REPL_TEXT_ADDR1 = VMEM_LOC_ADDR;                                          00584200
                                                                                00584300
      REPL_TEXT_PTR2 = VMEM_ALLOC_STRUC(1,1,6216,6,'',0,0);                     00584400
      CALL VMEM_LOCATE_PTR(1,REPL_TEXT_PTR2,RESV|MODF);                         00584500
      REPL_TEXT_ADDR2 = VMEM_LOC_ADDR;                                          00584600
                                                                                00584700
   /* PASS THROUGH ALL SDFS IN ALPHABETICAL ORDER AND GATHER CROSS-REF INFO */  00584800
                                                                                00584900
      DO UNIT_NO = 1 TO #UNITS;                                                 00585000
         I = UNIT_SORT(#UNITS-UNIT_NO+1);                                       00585100
         CALL SDF_SELECT(I);                                                    00585200
         DO BLK# = 1 TO #PROCS;                                                 00585300
            BLKNO = BLK#;                                                       00585400
            CALL MONITOR(22,8);                                                 00585500
            COREWORD(ADDR(NODE_B)) = ADDRESS;                                   00585600
            COREWORD(ADDR(NODE_H)) = ADDRESS;                                   00585700
            IF NODE_B(30) = 4 THEN DO;                                          00585800
               SLIM1 = NODE_H(16);                                              00585900
               SLIM2 = NODE_H(17);                                              00586000
               IF BLKNO = KEY_BLOCK THEN DO;                                    00586100
                  IF ((GSD_LEVEL+FILE_LEVEL)>0)&((UNIT_FLAGS(I)&"0010")=0)      00586200
                  THEN DO;                                                      00586300
                     DO J = SLIM1 TO SLIM2;                                     00586400
                        SYMBNO = J;                                             00586500
                        CALL MONITOR(22,9);                                     00586600
                        CALL ENTER_REF(I,I,SYMBNO);                             00586700
                     END;                                                       00586800
                  END;                                                          00586900
               END;                                                             00587000
               ELSE DO;                                                         00587100
                  TMP = SHL((NODE_B(44)-1),24);                                 00587200
                  UNIT_STRING = STRING(ADDRESS + 45 + TMP);                     00587300
                  UNIT_STRING = KEEP(UNIT_STRING);                              00587400
                  K = GET_UNIT_NDX_BY_NAME(UNIT_STRING);                        00587500
                  IF K = 0 THEN GO TO NO_SDF;                                   00587600
                  DO J = SLIM1 TO SLIM2;                                        00587700
                     SIGNAL = FALSE;                                            00587800
                     SYMBNO = J;                                                00587900
                     CALL MONITOR(22,"10000009");                               00588000
                     SYMBOL_STRING = KEEP(STRING(SYMBNAM+                       00588100
                        SHL(SYMBNLEN-1,24)));                                   00588200
                     COREWORD(ADDR(NODE_F)) = ADDRESS;                          00588300
                     COREWORD(ADDR(NODE_H)) = ADDRESS;                          00588400
                     COREWORD(ADDR(NODE_B)) = ADDRESS;                          00588500
                     CLASS = NODE_B(6);                                         00588600
                     TYPE = NODE_B(7);                                          00588700
                     FLAG = NODE_F(2);                                          00588800
                     SYMB_PTR = PNTR;                                           00588900
                     SAVE_ADDR = ADDRESS;                                       00589000
                     REPL_LEN1 = 0;                                             00589100
                     IF (CLASS=2)&(TYPE=9)&(NODE_B(3)~=0) THEN DO;              00589200
                        IF (VERSION>=25)&(NODE_F(5)~=0) THEN DO;                00589300
                           REPL_LEN1 = EXTRACT_REPLACE_TEXT(NODE_F(5),          00589400
                              REPL_TEXT_ADDR1);                                 00589500
                        END;                                                    00589600
                     END;                                                       00589700
                     LIT_PTR = 0;                                               00589800
                     IF ((FLAG&"00001000")~=0)&(NODE_B(3)~=0) THEN DO;          00589900
                        IF (VERSION >=25)&((NODE_F(5)&"FFFFFF")~=0) THEN DO;    00590000
                           LIT_PTR = NODE_F(5);                                 00590100
                           PNTR = LIT_PTR;                                      00590200
                           CALL MONITOR(22,"10000005");                         00590300
                           LIT_ADDR = ADDRESS;                                  00590400
                           LIT_VERSION = VERSION;                               00590410
                        END;                                                    00590500
                        ELSE LIT_PTR = 0;                                       00590502
                     END;                                                       00590600
                     TMP = LENGTH(UNIT_STRING);                                 00590700
                     BLKNLEN = TMP;                                             00590800
                     CALL MOVE(TMP,UNIT_STRING,BLKNAM);                         00590900
                     TMP = LENGTH(SYMBOL_STRING);                               00591000
                     SYMBNLEN = TMP;                                            00591100
                     CALL MOVE(TMP,SYMBOL_STRING,SYMBNAM);                      00591200
                     ALT_SDF = SDF_NAMES(K);                                    00591300
                     CALL MOVE(8,ALT_SDF,SDFNAM);                               00591400
                     FIRST = "00";                                              00591500
                     IF (CLASS>3)&((FLAG&"01000000")=0) THEN FIRST = "01";      00591600
                     CALL MONITOR(22,"8000000C");                               00591700
                     SELECTED_UNIT = 0;                                         00591800
                     IF CRETURN = 0 THEN DO;                                    00591900
                        IF FIRST = "01" THEN DO;                                00592000
                           Q,BASE_SYMB = SYMBNO;                                00592100
                           SYMB1 = SAVFSYMB;                                    00592200
                           SYMB2 = SAVLSYMB;                                    00592300
                           IF CHECK_MATCH THEN GO TO FOUND_VAR;                 00592400
                           ELSE DO FOREVER;                                     00592500
                              Q = Q - 1;                                        00592600
                              IF Q < SYMB1 THEN GO TO REVERSE;                  00592700
                              TS = SYMBOL_NAME(Q);                              00592800
                              IF TS = SYMBOL_STRING THEN DO;                    00592900
                                 IF CHECK_MATCH THEN GO TO FOUND_VAR;           00593000
                              END;                                              00593100
                              ELSE GO TO REVERSE;                               00593200
                           END;                                                 00593300
REVERSE:                                                                        00593400
                           Q = BASE_SYMB;                                       00593500
                           DO FOREVER;                                          00593600
                              Q = Q + 1;                                        00593700
                              IF Q > SYMB2 THEN GO TO NO_VAR;                   00593800
                              TS = SYMBOL_NAME(Q);                              00593900
                              IF TS = SYMBOL_STRING THEN DO;                    00594000
                                 IF CHECK_MATCH THEN GO TO FOUND_VAR;           00594100
                              END;                                              00594200
                              ELSE GO TO NO_VAR;                                00594300
                           END;                                                 00594400
FOUND_VAR:                                                                      00594500
                           SYMBNO = Q;                                          00594600
                           CALL MONITOR(22,9);                                  00594700
                        END;                                                    00594800
                        HOLD_ADDR = ADDRESS;                                    00594900
                        IF (GSD_LEVEL>0)&(MAP_BASE(I)~=0)&(MAP_BASE(K)~=0) THEN 00595000
                           DO;                                                  00595100
                           RESERVE                                              00595200
                           CALL VMEM_LOCATE_COPY(1,MAP_BASE(K),SYMBNO,0);       00595300
                           TMP = VMEM_LOC_PTR | "40000000";                     00595400
                           CALL VMEM_LOCATE_COPY(1,MAP_BASE(I),J,MODF);         00595500
                           VMEM_F(0) = TMP;                                     00595600
                           RELEASE                                              00595700
                        END;                                                    00595800
                        IF NODE_B(3) ~= 0 THEN DO;                              00595900
                           COREWORD(ADDR(NODE_F2)) = HOLD_ADDR;                 00596000
                           COREWORD(ADDR(NODE_H2)) = HOLD_ADDR;                 00596100
                           COREWORD(ADDR(NODE_B2)) = HOLD_ADDR;                 00596200
                           IF TYPE ~= NODE_B2(7) THEN CALL TPL_ERR(2);          00596300
                           IF CLASS ~= NODE_B2(6) THEN CALL TPL_ERR(1);         00596400
                           IF (FLAG&"FEDE36E7")~=(NODE_F2(2)&"FEDE36E7") THEN   00596500
                              CALL TPL_ERR(3);                                  00596600
                           IF ~((CLASS=2)&(TYPE=9)) THEN DO;                    00596700
                              IF NODE_F(3) ~= NODE_F2(3) THEN CALL TPL_ERR(4);  00596800
                           END;                                                 00596900
                           IF ~((TYPE=16)|((CLASS=2)&(TYPE=8))) THEN DO;        00597000
                              IF NODE_H(9) ~= NODE_H2(9) THEN CALL TPL_ERR(5);  00597100
                           END;                                                 00597200
                           IF (FLAG & "00020000") ~= 0 THEN DO;                 00597300
                              IF NODE_B(20) ~= NODE_B2(20) THEN CALL TPL_ERR(6);00597400
                           END;                                                 00597500
                           IF ~(((CLASS=2)&(TYPE=9))|((FLAG&"00001000")~=0))    00597600
                           THEN DO;                                             00597700
                              IF (NODE_F(5)&"FFFFFF")~=(NODE_F2(5)&"FFFFFF")    00597800
                                 THEN CALL TPL_ERR(7);                          00597900
                           END;                                                 00598000
                           IF NODE_B(4) ~= 0 THEN DO;                           00598100
                              IF NODE_B2(4) = 0 THEN CALL TPL_ERR(8);           00598200
                              ELSE DO;                                          00598300
                                 KK = SHR(NODE_B(4),1);                         00598400
                                 L = SHR(NODE_B2(4),1);                         00598500
                                 IF NODE_H(KK) ~= NODE_H2(L) THEN               00598600
                                    CALL TPL_ERR(8);                            00598700
                                 KLIM1 = KK + 1;                                00598800
                                 KLIM2 = KLIM1 + NODE_H(KK) - 1;                00598900
                                 DO KK = KLIM1 TO KLIM2;                        00599000
                                    L = L + 1;                                  00599100
                                    IF NODE_H(KK) ~= NODE_H2(L) THEN DO;        00599200
                                       CALL TPL_ERR(8);                         00599300
                                       GO TO END_CHECK;                         00599400
                                    END;                                        00599500
                                 END;                                           00599600
                              END;                                              00599700
                           END;                                                 00599800
                           ELSE IF NODE_B2(4) ~= 0 THEN CALL TPL_ERR(8);        00599900
                           IF (NODE_B2(6)=2)&(NODE_B2(7)=9) THEN DO;            00600000
                              IF (VERSION>=25)&(NODE_F2(5)~=0) THEN DO;         00600100
                                 IF REPL_LEN1 > 0 THEN DO;                      00600200
                                    REPL_LEN2 = EXTRACT_REPLACE_TEXT(NODE_F2(5),00600300
                                       REPL_TEXT_ADDR2);                        00600400
                                    IF REPL_LEN1 ~= REPL_LEN2 THEN              00600500
                                       CALL TPL_ERR(9);                         00600600
                                    ELSE DO;                                    00600700
COMPARE_LOOP:                                                                   00600800
                                       DO KK = 0 TO REPL_LEN1 - 1;              00600900
                                          IF COREBYTE(REPL_TEXT_ADDR1+KK) ~=    00601000
                                             COREBYTE(REPL_TEXT_ADDR2+KK) THEN  00601100
                                             DO;                                00601200
                                             CALL TPL_ERR(9);                   00601300
                                             ESCAPE COMPARE_LOOP;               00601400
                                          END;                                  00601500
                                       END;                                     00601600
                                    END;                                        00601700
                                 END;                                           00601800
                              END;                                              00601900
                           END;                                                 00602000
                           ELSE IF (VERSION>=25)&((NODE_F2(2)&"1000")~=0) THEN  00602200
                           DO;                                                  00602300
                              IF (CLASS=NODE_B2(6))&(TYPE=NODE_B2(7)) THEN DO;  00602500
                                 PNTR = NODE_F2(5);                             00602700
                                 IF LIT_PTR ~= 0 THEN DO;                       00602701
                                    IF PNTR ~= 0 THEN DO;                       00602702
                                       CALL MONITOR(22,5);                      00602800
                                       IF TYPE = 2 THEN DO;                     00602900
                                          LIT_STRING1=STRING(SHL(COREBYTE(      00603000
                                             LIT_ADDR),24)+LIT_ADDR+1);         00603100
                                          LIT_STRING2=STRING(SHL(COREBYTE(      00603200
                                             ADDRESS),24)+ADDRESS+1);           00603300
                                          IF LIT_STRING1~=LIT_STRING2 THEN      00603400
                                             CALL TPL_ERR(10);                  00603500
                                       END;                                     00603600
                                       ELSE DO;                                 00603700
                                          IF (COREWORD(LIT_ADDR) ~=             00603800
                                             COREWORD(ADDRESS))|(COREWORD(      00603900
                                             LIT_ADDR+4)~=COREWORD(ADDRESS+4))  00604000
                                             THEN DO;                           00604100
                                                DW(0)=COREWORD(LIT_ADDR);       00604200
                                                DW(1)=COREWORD(LIT_ADDR+4);     00604300
                                                LIT_STRING1 = KEEP(STRING(      00604400
                                                   MONITOR(12,8)));             00604500
                                                DW(0)=COREWORD(ADDRESS);        00604600
                                                DW(1)=COREWORD(ADDRESS+4);      00604700
                                                LIT_STRING2 = STRING(           00604800
                                                   MONITOR(12,8));              00604900
                                                CALL TPL_ERR(10);               00605000
                                          END;                                  00605100
                                       END;                                     00605200
                                    END;                                        00605300
                                    ELSE IF LIT_VERSION>=27 |                   00605310
                                       (LIT_VERSION<27 & COREWORD(LIT_ADDR)~=0) 00605320
                                       THEN DO;                                 00605325
                                       LIT_STRING1=STRING(SHL(COREBYTE(LIT_ADDR)00605330
                                          ,24) + LIT_ADDR+1);                   00605340
                                       LIT_STRING2 = '';                        00605350
                                       CALL TPL_ERR(10);                        00605360
                                    END;                                        00605370
                                 END;                                           00605400
                                 ELSE IF LIT_VERSION>=27 & (PNTR~=0) THEN DO;   00605401
                                    CALL MONITOR(22,5);                         00605402
                                    IF VERSION>=27 | (COREWORD(ADDRESS)~=0 &    00605403
                                    VERSION<27) THEN DO;                        00605404
                                       LIT_STRING1 = '';                        00605405
                                       LIT_STRING2=STRING(SHL(COREBYTE(ADDRESS),00605406
                                          24) + ADDRESS+1);                     00605407
                                       CALL TPL_ERR(10);                        00605408
                                    END;                                        00605409
                                 END;                                           00605410
                              END;                                              00605500
                           END;                                                 00605600
                        END;                                                    00605700
END_CHECK:                                                                      00605800
                        ADDRESS = SAVE_ADDR;                                    00605900
                        CALL MOVE(8,SDF_NAME,SDFNAM);                           00606000
                        IF (NODE_B(3)~=0)&((GSD_LEVEL+FILE_LEVEL)>0) THEN       00606100
                           CALL ENTER_REF(I,K,SYMBNO);                          00606200
                     END;                                                       00606300
                     ELSE DO;                                                   00606400
NO_VAR:                                                                         00606500
                        IF NODE_B(3) ~= 0 THEN CALL TPL_ERR(0);                 00606600
                     END;                                                       00606700
                     IF SIGNAL THEN DO;                                         00606800
                        SPACE_1;                                                00606900
                        SIGNAL = FALSE;                                         00607000
                     END;                                                       00607100
                     CALL MOVE(8,SDF_NAME,SDFNAM);                              00607200
                     PNTR = SYMB_PTR;                                           00607300
                     CALL MONITOR(22,"A0000005");                               00607400
                     IF LIT_PTR ~= 0 THEN DO;                                   00607500
                        PNTR = LIT_PTR;                                         00607600
                        CALL MONITOR(22,"A0000005");                            00607700
                        LIT_PTR = 0;                                            00607800
                     END;                                                       00607900
                     SELECTED_UNIT = 0;                                         00608000
                  END;                                                          00608100
               END;                                                             00608200
            END;                                                                00608300
            ELSE IF (GSD_LEVEL + FILE_LEVEL) > 0 THEN DO;                       00608400
               TMP = SHL((NODE_B(44)-1),24);                                    00608500
               UNIT_STRING = STRING(ADDRESS + 45 + TMP);                        00608600
               UNIT_STRING = KEEP(UNIT_STRING);                                 00608700
               IF ((NODE_H(12)&"0800")~=0) THEN DO;                             00608800
                  K = GET_UNIT_NDX_BY_NAME(UNIT_STRING);                        00608900
                  IF K = 0 THEN GO TO NO_SDF;                                   00609000
                  SYMBNO = NODE_H(16);                                          00609100
                  CALL MONITOR(22,9);                                           00609200
                  CALL ENTER_REF(I,K,1);                                        00609300
               END;                                                             00609400
               ELSE IF BLK# = KEY_BLOCK THEN DO;                                00609500
                  TMP = LENGTH(UNIT_STRING);                                    00609600
                  BLKNLEN = TMP;                                                00609700
                  CALL MOVE(TMP,UNIT_STRING,BLKNAM);                            00609800
                  SYMBNLEN = TMP;                                               00609900
                  CALL MOVE(TMP,UNIT_STRING,SYMBNAM);                           00610000
                  FIRST = "00";                                                 00610100
                  CALL MONITOR(22,12);                                          00610200
                  COREWORD(ADDR(NODE_B)) = ADDRESS;                             00610205
                  COREWORD(ADDR(NODE_F)) = ADDRESS;                             00610210
                  FLAG = NODE_F(2);                                             00610215
                  IF (FLAG & "04000000") = 0 THEN DO;                           00610220
                     CLASS = NODE_B(6);                                         00610225
                     TYPE = NODE_B(7);                                          00610230
                     IF (CLASS = 3)|((CLASS=2)&(TYPE<3)) THEN                   00610235
                        CALL ENTER_REF(I,I,1);                                  00610240
                  END;                                                          00610245
               END;                                                             00610400
            END;                                                                00610500
NO_SDF:                                                                         00610600
         END;                                                                   00610700
      END;                                                                      00610800
                                                                                00610900
   /* FREE SECONDARY REPLACE TEXT BUFFER */                                     00611000
                                                                                00611100
      CALL VMEM_LOCATE_PTR(1,REPL_TEXT_PTR2,RELS);                              00611200
                                                                                00611300
   /* ISSUE RECOMPILATION RECOMMENDATIONS */                                    00611400
                                                                                00611500
      SIGNAL = TRUE;                                                            00611600
      DO UNIT_NO = 1 TO #UNITS;                                                 00611700
         I = UNIT_SORT(UNIT_NO);                                                00611800
         IF (UNIT_FLAGS(I)&"000F") ~= 0 THEN DO;                                00611900
            IF SIGNAL THEN DO;                                                  00612000
               SIGNAL = FALSE;                                                  00612100
               OUTPUT(1) = ONE;                                                 00612200
               SPACE_1;                                                         00612300
               OUTPUT = '*** THE FOLLOWING COMPILATION UNITS SHOULD BE RECOMPILE00612400
D FOR THE REASONS GIVEN ***';                                                   00612500
               OUTPUT = '    (KEY:  1 - SDF HAS WRONG TYPE   2 - SDF IS OLD   4 00612600
- COMPOOL TEMPLATE MISMATCH   8 - CSECT MISMATCH)';                             00612700
               SPACE_1;                                                         00612800
               OUTPUT = '        COMPILATION UNIT            REASON';           00612900
               SPACE_1;                                                         00613000
            END;                                                                00613100
            TS = LPAD((UNIT_FLAGS(I)&"000F"),2);                                00613200
            TS(1) = PAD(UNIT_NAMES(I),32);                                      00613300
            OUTPUT = TS(1)||X5||TS;                                             00613400
         END;                                                                   00613500
      END;                                                                      00613600
                                                                                00613700
   /* IF THIS IS AN FC LOAD MODULE, ADJUST CSECT DATA TO HALFWORD ADDRESSING */ 00613800
                                                                                00613900
      IF FC_FLAG THEN DO I = 1 TO #CSECTS;                                      00614000
         CSECT_ADDR(I) = (CSECT_ADDR(I)&"FF000000")|SHR(CSECT_ADDR(I)&          00614100
            "FFFFFF",1);                                                        00614200
         CSECT_LENGTH(I) = (CSECT_LENGTH(I)&"FF000000")|SHR(CSECT_LENGTH(I)&    00614300
            "FFFFFF",1);                                                        00614400
      END;                                                                      00614500
                                                                                00614600
      CLOCK(4) = MONITOR(18);                                                   00614700
                                                                                00614800
   /* GENERATE A SEQUENTIAL FILE OF ALL SYMBOLS IN ALPHABETICAL ORDER */        00614900
                                                                                00615000
      IF ADL_FLAG THEN DO;                                                      00615100
         RECORD_BUFFER = STRING(SHL(79,24) + ADDR(ADLBUFF));                    00615200
         COREWORD(ADDR(ADLBUFF_BYTE)) = ADDR(ADLBUFF);                          00615300
         COREWORD(ADDR(ADLBUFF_HW)) = ADDR(ADLBUFF);                            00615400
         COREWORD(ADDR(ADLBUFF_FW)) = ADDR(ADLBUFF);                            00615500
         ADLBUFF_ADDR = ADDR(ADLBUFF);                                          00615600
         CALL BUILD_TAPE(0);   /* INITIALIZE CALL */                            00615700
         DO UNIT_NO = 1 TO #UNITS;                                              00615800
            GOT_ID = UNIT_SORT(UNIT_NO);                                        00615900
            GOT_NAME = UNIT_NAMES(GOT_ID);                                      00616000
            GOT_NAME = PAD(GOT_NAME,32);                                        00616100
            CALL BUILD_TAPE(1);   /* UNIT RECORD */                             00616200
            CALL SDF_SELECT(GOT_ID);                                            00616300
            DO GOT_ID = 1 TO #PROCS;                                            00616400
               GOT_NAME = BLOCK_NAME(GOT_ID);                                   00616500
               COREWORD(ADDR(NODE_H)) = ADDRESS;                                00616600
               IF ((NODE_H(12)&"0800")=0) THEN DO;                              00616700
                  GOT_NAME = PAD(GOT_NAME,32);                                  00616800
                  CALL BUILD_TAPE(2);   /* BLOCK RECORD */                      00616900
               END;                                                             00617000
            END;                                                                00617100
         END;                                                                   00617200
         CALL BUILD_TAPE(3);   /* END OF DIRECTORY */                           00617300
      END;                                                                      00617400
      IF (ADL_FLAG=FALSE)&(GSD_LEVEL=0) THEN GO TO BYPASS_MERGE;                00617500
      DO WHILE NEXT_SYMBOL;                                                     00617600
         GOT_RECORD = GOT_RECORD + 1;                                           00617700
         IF (GSD_LEVEL>0)&(MAP_BASE(GOT_UNIT)~=0) THEN DO;                      00617800
            CALL VMEM_LOCATE_COPY(1,MAP_BASE(GOT_UNIT),GOT_LINK,MODF);          00617900
            VMEM_F(0) = GOT_RECORD;                                             00618000
         END;                                                                   00618100
         IF ADL_FLAG THEN DO;                                                   00618200
            ADDR_INC = 0;                                                       00618300
            GOT_ADDR1 = 0;                                                      00618400
            COREWORD(ADDR(NODE_F)) = GOT_CELL_ADDR;                             00618500
            COREWORD(ADDR(NODE_H)) = GOT_CELL_ADDR;                             00618600
            COREWORD(ADDR(NODE_B)) = GOT_CELL_ADDR;                             00618700
            FLAG = NODE_F(2);                                                   00618800
            SCLASS = NODE_B(6);                                                 00618900
            STYPE = NODE_B(7);                                                  00619000
            GOT_PHASE = 0;                                                      00619100
            IF ((SCLASS = 2)|(SCLASS = 3))&((FLAG & "04000000")=0) THEN DO;     00619200
               IF ADDR_FLAG = FALSE THEN GO TO SKIP_IT;                         00619300
               IF (SCLASS=2)&((STYPE=4)|(STYPE>7)) THEN GO TO SKIP_IT;          00619400
               IF NODE_H(7) = 0 THEN GO TO SKIP_IT;                             00619500
               STMTNO = NODE_H(7);                                              00619600
               CALL MONITOR(22,10);                                             00619700
               COREWORD(ADDR(NODE_H1)) = ADDRESS;                               00619800
               COREWORD(ADDR(NODE_B1)) = ADDRESS;                               00619900
               SBLK = NODE_H1(0);                                               00620000
               #LABELS = NODE_B1(4);                                            00620100
               #LHS = NODE_B1(5);                                               00620200
               J = 6 + SHL(#LABELS + #LHS,1);                                   00620300
               GOT_ADDR = NODE_B1(J);                                           00620400
               GOT_ADDR = SHL(GOT_ADDR,8) + NODE_B1(J + 1);                     00620500
               GOT_ADDR = SHL(GOT_ADDR,8) + NODE_B1(J + 2);                     00620600
               BLKNO = 0;                                                       00620700
               IF SBLK = KEY_BLOCK THEN DO;                                     00620800
                  ADDR_INC = CSECT_ADDR(#C$0(GOT_UNIT))&"FFFFFF";               00620900
                  GOT_PHASE = SHR(CSECT_LENGTH(#C$0(GOT_UNIT)),24);             00621000
               END;                                                             00621100
               ELSE DO;                                                         00621200
                  BLKNO = SBLK;                                                 00621300
                  CALL MONITOR(22,8);                                           00621400
                  KEY_CHARS = SHR(COREWORD(CSECTNAM),16);                       00621500
                  COREWORD(ADDR(NODE_B1)) = ADDRESS;                            00621600
                  BLK_CLASS = NODE_B1(30);                                      00621700
                  IF BLK_CLASS = 5 THEN DO;                                     00621800
                     J = TASK_TAB(GOT_UNIT);                                    00621900
                     DO WHILE (KEY_CHARS~=SHR(CSECT_CHAR(SHL(J,1)),16))&(J~=0); 00622000
                        J = CSECT_LINK(J);                                      00622100
                     END;                                                       00622200
                     ADDR_INC = CSECT_ADDR(J)&"FFFFFF";                         00622300
                  END;                                                          00622400
                  ELSE DO;                                                      00622500
                     J = PROC_TAB(GOT_UNIT);                                    00622600
                     DO WHILE (KEY_CHARS~=SHR(CSECT_CHAR(SHL(J,1)),16))&(J~=0); 00622700
                        J = CSECT_LINK(J);                                      00622800
                     END;                                                       00622900
                     ADDR_INC = CSECT_ADDR(J)&"FFFFFF";                         00623000
                  END;                                                          00623100
                  GOT_PHASE = SHR(CSECT_LENGTH(J),24);                          00623200
               END;                                                             00623300
               IF ~((SCLASS=2)&(STYPE=7)) THEN DO;                              00623400
                  IF BLKNO = 0 THEN DO;                                         00623500
                     BLKNO = SBLK;                                              00623600
                     CALL MONITOR(22,8);                                        00623700
                  END;                                                          00623800
                  COREWORD(ADDR(NODE_H1)) = ADDRESS;                            00623900
                  STMTNO = NODE_H1(19);                                         00624000
                  CALL MONITOR(22,10);                                          00624100
                  COREWORD(ADDR(NODE_H1)) = ADDRESS;                            00624200
                  COREWORD(ADDR(NODE_B1)) = ADDRESS;                            00624300
                  #LABELS = NODE_B1(4);                                         00624400
                  #LHS = NODE_B1(5);                                            00624500
                  J = 6 + SHL(#LABELS + #LHS,1);                                00624600
                  GOT_ADDR1 = NODE_B1(J + 3);                                   00624700
                  GOT_ADDR1 = SHL(GOT_ADDR1,8) + NODE_B1(J + 4);                00624800
                  GOT_ADDR1 = SHL(GOT_ADDR1,8) + NODE_B1(J + 5);                00624900
                  GOT_ADDR1 = GOT_ADDR1 + ADDR_INC;                             00625000
               END;                                                             00625100
            END;                                                                00625200
            ELSE DO;                                                            00625300
               GOT_ADDR = NODE_F(3) & "FFFFFF";                                 00625400
               GOT_PHASE = SHR(CSECT_LENGTH(#D#P(GOT_UNIT)),24);                00625500
               IF (FLAG & "00000400") ~= 0 THEN DO;                             00625600
               END;                                                             00625700
               ELSE IF (SCLASS < 4)&((FLAG & "00001000")=0) THEN DO;            00625800
                  IF ((FLAG&"00010000")~=0)&(FC_FLAG=TRUE) THEN                 00625900
                     ADDR_INC = CSECT_ADDR(#F#R(GOT_UNIT))&"FFFFFF";            00626000
                  ELSE ADDR_INC = CSECT_ADDR(#D#P(GOT_UNIT))&"FFFFFF";          00626100
               END;                                                             00626200
            END;                                                                00626300
            GOT_ADDR = GOT_ADDR + ADDR_INC;                                     00626400
            IF (FLAG & "00001000") = 0 THEN DO;                                 00626500
               IF SCLASS < 4 THEN DO;                                           00626600
                  IF (SCLASS = 1)&(STYPE = 16) THEN DO;                         00626700
                     CALL BUILD_TAPE(7);                                        00626800
                     SAVE_LINK = GOT_LINK;                                      00626900
                     SAVE_ADDR = GOT_ADDR;                                      00627000
                     SAVE_CELL_ADDR = GOT_CELL_ADDR;                            00627100
                     SAVE_NAME = GOT_NAME;                                      00627200
                     STACK_INX = 0;                                             00627300
                     CURRENT_BASE = GOT_ADDR;                                   00627400
                     COREWORD(ADDR(NODE_H1)) = ADDRESS;                         00627500
                     LINK = NODE_H1(9);                                         00627600
                     DO FOREVER;                                                00627700
                        GOT_NAME = SYMBOL_NAME(LINK);                           00627800
                        GOT_NAME = PAD(GOT_NAME,32);                            00627900
                        COREWORD(ADDR(NODE_F1)) = ADDRESS;                      00628000
                        COREWORD(ADDR(NODE_H1)) = ADDRESS;                      00628100
                        COREWORD(ADDR(NODE_B1)) = ADDRESS;                      00628200
                        NEW_LINK = NODE_H1(-1);                                 00628300
                        IF (NODE_B1(7)=16)&((NODE_F1(2)&"04000000")=0) THEN DO; 00628400
                           IF (NODE_H1(SHR(NODE_B1(5),1)+1)=0) THEN DO;         00628500
                              TPL_STACK1(STACK_INX) = NEW_LINK;                 00628600
                              TPL_STACK2(STACK_INX) = CURRENT_BASE;             00628700
                              CALL PUSH_STACK;                                  00628800
                              CURRENT_BASE = CURRENT_BASE+(NODE_F1(3)&"FFFFFF");00628900
                              NEW_LINK = NODE_H1(9);                            00629000
                           END;                                                 00629100
                        END;                                                    00629200
                        ELSE DO;                                                00629300
                           GOT_LINK = LINK;                                     00629400
                           GOT_ADDR = CURRENT_BASE + (NODE_F1(3)&"FFFFFF");     00629500
                           GOT_CELL_ADDR = ADDRESS;                             00629600
                           CALL BUILD_TAPE(8);                                  00629700
                        END;                                                    00629800
                        DO WHILE NEW_LINK = 0;                                  00629900
                           IF STACK_INX = 0 THEN GO TO FINISH;                  00630000
                           STACK_INX = STACK_INX - 1;                           00630100
                           CURRENT_BASE = TPL_STACK2(STACK_INX);                00630200
                           NEW_LINK = TPL_STACK1(STACK_INX);                    00630300
                        END;                                                    00630400
                        LINK = NEW_LINK;                                        00630500
                     END;                                                       00630600
FINISH:                                                                         00630700
                     GOT_LINK = SAVE_LINK;                                      00630800
                     GOT_ADDR = SAVE_ADDR;                                      00630900
                     GOT_CELL_ADDR = SAVE_CELL_ADDR;                            00631000
                     GOT_NAME = SAVE_NAME;                                      00631100
                  END;                                                          00631200
                  ELSE DO;                                                      00631300
                     IF SCLASS = 1 THEN DO;                                     00631400
                        IF (FLAG & "400")~=0 THEN CALL BUILD_TAPE(10);          00631500
                        ELSE CALL BUILD_TAPE(6);                                00631600
                     END;                                                       00631700
                     ELSE CALL BUILD_TAPE(5);                                   00631800
                  END;                                                          00631900
               END;                                                             00632000
               ELSE IF (STYPE ~= 16)&((FLAG & "01000000")~=0) THEN DO;          00632100
                  SYMBNO = NODE_H(SHR(NODE_B(5),1));                            00632200
                  CALL MONITOR(22,9);                                           00632300
                  COREWORD(ADDR(NODE_F1)) = ADDRESS;                            00632400
                  COREWORD(ADDR(NODE_H1)) = ADDRESS;                            00632500
                  COREWORD(ADDR(NODE_B1)) = ADDRESS;                            00632600
                  GOT_COPIES = NODE_H1(SHR(NODE_B1(4),1)+1);                    00632700
                  GOT_COPY_SIZE = (NODE_F1(5)&"FFFFFF")/GOT_COPIES;             00632800
                  SAVE_ADDR = GOT_ADDR;                                         00632900
                  GOT_ADDR = GOT_ADDR + (NODE_F1(3) & "FFFFFF");                00633000
                  IF (NODE_F1(2)&"00010000") ~= 0 THEN DO;                      00633100
                     IF FC_FLAG THEN GOT_ADDR = GOT_ADDR +                      00633200
                        CSECT_ADDR(#F#R(GOT_UNIT))&"FFFFFF";                    00633300
                     ELSE GOT_ADDR = GOT_ADDR + CSECT_ADDR(#D#P(GOT_UNIT))&     00633400
                        "FFFFFF";                                               00633500
                  END;                                                          00633600
                  ELSE GOT_ADDR = GOT_ADDR + CSECT_ADDR(#D#P(GOT_UNIT))&        00633700
                     "FFFFFF";                                                  00633800
                  CALL BUILD_TAPE(9);   /* UNQUALIFIED STRUC VAR */             00633900
                  GOT_ADDR = SAVE_ADDR;                                         00634000
               END;                                                             00634100
            END;                                                                00634200
         END;                                                                   00634300
SKIP_IT:                                                                        00634400
      END;                                                                      00634500
      CALL VMEM_SEQ_CLOSE(SYSTEM);                                              00634600
      IF ADL_FLAG THEN CALL BUILD_TAPE(4);                                      00634700
BYPASS_MERGE:                                                                   00634800
                                                                                00634900
      CLOCK(5) = MONITOR(18);                                                   00635000
                                                                                00635100
   /* PRODUCE LISTING OF COMPILATION UNIT STATISTICS */                         00635200
                                                                                00635300
      IF STAT_FLAG THEN DO;                                                     00635400
         DO UNIT_NO = 1 TO #UNITS;                                              00635500
            I = UNIT_SORT(UNIT_NO);                                             00635600
            IF (UNIT_FLAGS(I)&"0010") ~= 0 THEN GO TO SKIP_STATS;               00635700
            TS = '                              S T A T I S T I C S   F O R   U 00635800
N I T   '||UNIT_NAMES(I);                                                       00635900
            OUTPUT(1) = TWO||TS;                                                00636000
            IF EJECT_FLAG THEN OUTPUT(1) = ONE;                                 00636100
            ELSE DO;                                                            00636200
               DSPACE;                                                          00636300
               OUTPUT = TS;                                                     00636400
               SPACE_1;                                                         00636500
            END;                                                                00636600
            CALL SDF_SELECT(I);                                                 00636700
            GOT_UNIT = I;                                                       00636800
            FLAG_STRING = '';                                                   00636900
            IF SRN_FLAG THEN FLAG_STRING = FLAG_STRING || 'SRN,';               00637000
            IF ADDR_FLAG THEN FLAG_STRING = FLAG_STRING || 'ADDRS,';            00637100
            K = LENGTH(FLAG_STRING);                                            00637200
            IF K ~= 0 THEN                                                      00637300
               FLAG_STRING = SUBSTR(FLAG_STRING,0,K-1);                         00637400
            COREWORD(ADDR(NODE_H)) = ADDRESS;                                   00637500
            COREWORD(ADDR(NODE_F)) = ADDRESS;                                   00637600
            SDF_DATE = NODE_F(1);                                               00637700
            SDF_TIME = NODE_F(2);                                               00637800
            PTR1 = NODE_F(23);                                                  00637900
            IF PTR1 ~= 0 THEN DO;                                               00638000
               CALL SDF_PTR_LOCATE(PTR1,0);                                     00638100
               K = COREBYTE(ADDRESS);                                           00638200
               SDF_TITLE = STRING(SHL(K-1,24) + ADDRESS + 1);                   00638300
            END;                                                                00638400
            IF PTR1 ~= 0 THEN DO;                                               00638500
               OUTPUT = 'TITLE:              '|| SDF_TITLE;                     00638600
               SPACE_1;                                                         00638700
            END;                                                                00638800
            CALL EMIT_TEXT(1,1);                                                00638900
            OUTPUT = 'UNIT #:             '|| UNIT_NO;                          00639000
            OUTPUT = 'UNIT NAME:          '|| UNIT_NAMES(I);                    00639100
            OUTPUT = 'UNIT TYPE:        '|| PROC_TYPES(UNIT_TYPE(I));           00639200
            IF (NODE_H(0)&"0004")~=0 THEN DO;                                   00639300
               TS = STRING("09000000" + COREWORD(ADDR(NODE_H))+140);            00639400
               DO WHILE BYTE(TS) = BYTE(X1);                                    00639500
                  TS = SUBSTR(TS,1);                                            00639600
               END;                                                             00639700
               OUTPUT = 'COMPILER:           ' || TS;                           00639800
            END;                                                                00639900
            OUTPUT = 'COMPILATION DATE:   '||CHAR_DATE(SDF_DATE);               00640000
            OUTPUT = 'COMPILATION TIME:   '||CHAR_TIME(SDF_TIME);               00640100
            IF FLAG_STRING ~= '' THEN                                           00640200
               OUTPUT = 'FLAGS:              '|| FLAG_STRING;                   00640300
            IF UNIT_TYPE(I) ~= 4 THEN DO;                                       00640400
               OUTPUT = 'EXECUTABLE STMTS:   '|| NODE_H(28);                    00640500
               OUTPUT = 'EMITTED INSTRS:     '|| NODE_F(6);                     00640600
               IF NODE_H(20) ~= 0 THEN                                          00640700
                  OUTPUT = 'STACK WALKS:        '|| NODE_H(20);                 00640800
               TOTAL_STACK_WALKS = TOTAL_STACK_WALKS + NODE_H(20);              00640900
            END;                                                                00641000
            SPACE_1;                                                            00641100
            IF MSG_LEVEL > 0 THEN DO;                                           00641200
               OUTPUT = 'COMPILATION PARAMETERS:';                              00641300
               OUTPUT = '     SYMBOLS        '||NODE_F(26)||SLASH||NODE_F(31);  00641400
               OUTPUT = '     MACROSIZE      '||NODE_F(27)||SLASH||NODE_F(32);  00641500
               OUTPUT = '     LITSTRINGS     '||NODE_F(28)||SLASH||NODE_F(33);  00641600
               OUTPUT = '     XREFSIZE       '||NODE_F(30)||SLASH||NODE_F(34);  00641700
               SPACE_1;                                                         00641800
            END;                                                                00641900
            SAVE_PNTR = NODE_F(11);                                             00642000
            OUTPUT='            **** C O M P I L A T I O N   L A Y O U T ****'; 00642100
            SPACE_1;                                                            00642200
            K = 1;                                                              00642300
            DO WHILE ((#EXTERNALS > 0)&(K~>#PROCS));                            00642400
               TS = BLOCK_NAME(K);                                              00642500
               TS(1) = X6;                                                      00642600
               L = GET_UNIT_NDX_BY_NAME(TS);                                    00642700
               IF L = 0 THEN TS(1) = 'NONHAL';                                  00642800
               COREWORD(ADDR(NODE_H)) = ADDRESS;                                00642900
               COREWORD(ADDR(NODE_B)) = ADDRESS;                                00643000
               IF (NODE_H(12)&"0800") ~= 0 THEN DO;                             00643100
                  #EXTERNALS = #EXTERNALS - 1;                                  00643200
                  TS = TS(1)||X6||TS||': EXTERNAL'||PROC_TYPES(NODE_B(30));     00643300
                  OUTPUT = TS;                                                  00643400
                  IF NODE_B(30) = 4 THEN DO;                                    00643500
                     SLIM1 = NODE_H(16);                                        00643600
                     SLIM2 = NODE_H(17);                                        00643700
                     KK = 1;                                                    00643800
                     TS = X14;                                                  00643900
                     DO J = SLIM1 TO SLIM2;                                     00644000
                        SYMBOL_STRING = PAD(SYMBOL_NAME(J),32);                 00644100
                        TMP = GLOBAL_SYMB(J);                                   00644200
                        IF TMP = 0 THEN TS(1) = X6;                             00644300
                        ELSE TS(1) = LPAD(TMP,6);                               00644400
                        SYMBOL_STRING = TS(1)||X1||SYMBOL_STRING;               00644500
                        COREWORD(ADDR(NODE_B)) = ADDRESS;                       00644600
                        CLASS = NODE_B(6);                                      00644700
                        TYPE = NODE_B(7);                                       00644800
                        IF ~((CLASS=2)&(TYPE=4)) THEN DO;                       00644900
                           IF KK < 4 THEN KK = KK + 1;                          00645000
                           ELSE DO;                                             00645100
                              KK = 2;                                           00645200
                              OUTPUT = TS;                                      00645300
                              TS = X14;                                         00645400
                           END;                                                 00645500
                           TS = TS||SYMBOL_STRING;                              00645600
                        END;                                                    00645700
                     END;                                                       00645800
                     IF KK > 1 THEN OUTPUT = TS;                                00645900
                  END;                                                          00646000
               END;                                                             00646100
               K = K + 1;                                                       00646200
            END;                                                                00646300
            SPACE_1;                                                            00646400
            LEVEL = 0;                                                          00646500
            PNTR = SAVE_PNTR;                                                   00646600
            DO WHILE PNTR ~= 0;                                                 00646700
               CALL MONITOR(22,5);                                              00646800
               COREWORD(ADDR(NODE_H)) = ADDRESS;                                00646900
               K = NODE_H(13);                                                  00647000
               SYMBOL_STRING = BLOCK_NAME(K);                                   00647100
               CSECT_NAME = STRING("07000000" + CSECTNAM);                      00647200
               CSECT_NAME = LPAREN||CSECT_NAME||RPAREN;                         00647300
               COREWORD(ADDR(NODE_B)) = ADDRESS;                                00647400
               COREWORD(ADDR(NODE_H)) = ADDRESS;                                00647500
               COREWORD(ADDR(NODE_F)) = ADDRESS;                                00647600
               TS = SYMBOL_STRING||COLON||PROC_TYPES(NODE_B(30));               00647700
               IF LEVEL = 0 THEN TS(1) = '';                                    00647800
               ELSE TS(1) = SUBSTR(PRINTLINE,0,3*LEVEL);                        00647900
               IF NODE_B(30) ~= 4 THEN DO;                                      00648000
                  TS(2) = LPAD(NODE_H(18),4);                                   00648100
                  TS(3) = LPAD(NODE_H(19),4);                                   00648200
                  TS(2) = TS(2) || BLK_MINUS_BLK ||TS(3);                       00648300
               END;                                                             00648400
               ELSE TS(2) = X11;                                                00648500
               TS = CSECT_NAME||X1||TS(2)||X2||TS(1)||TS;                       00648600
               CALL EMIT_OUTPUT(TS);                                            00648700
               IF NODE_F(2) ~= 0 THEN DO;                                       00648800
                  LEVEL = LEVEL + 1;                                            00648900
                  PNTR = NODE_F(2);                                             00649000
               END;                                                             00649100
               ELSE DO;                                                         00649200
                  PNTR = NODE_F(3);                                             00649300
                  DO WHILE PNTR < 0;                                            00649400
                     LEVEL = LEVEL - 1;                                         00649500
                     PNTR = - PNTR;                                             00649600
                     CALL MONITOR(22,5);                                        00649700
                     COREWORD(ADDR(NODE_F)) = ADDRESS;                          00649800
                     PNTR = NODE_F(3);                                          00649900
                  END;                                                          00650000
               END;                                                             00650100
            END;                                                                00650200
            SPACE_1;                                                            00650300
            OUTPUT = '            **** C S E C T   I N F O R M A T I O N ****'; 00650400
            SPACE_1;                                                            00650500
            OUTPUT='                 ADDR    SIZE         ADDR    SIZE         A00650600
DDR    SIZE         ADDR    SIZE         ADDR    SIZE';                         00650700
            SPACE_1;                                                            00650800
            CALL PHASE_DET;                                                     00650900
            DO PH# = 1 TO NUM_PHASES;                                           00651000
               IF PHASE_TAB(PH#) ~= 0 THEN DO;                                  00651100
                  SIGNAL = TRUE;                                                00651200
                  TEMP1 = SHL(PH#,24);                                          00651300
                  DATA_SIZE = CSECT_PROC(#E(GOT_UNIT),0);                       00651400
                  DATA_SIZE = DATA_SIZE + CSECT_PROC(#X(GOT_UNIT),0);           00651500
                  DATA_SIZE = DATA_SIZE + CSECT_PROC(#T#Z(GOT_UNIT),0);         00651600
                  DATA_SIZE = DATA_SIZE + CSECT_PROC(#D#P(GOT_UNIT),0);         00651700
                  DATA_SIZE = DATA_SIZE + CSECT_PROC(#F#R(GOT_UNIT),0);         00651800
                  CODE_SIZE = CSECT_PROC(#C$0(GOT_UNIT),1);                     00651900
                  CODE_SIZE = CODE_SIZE + CSECT_PROC(TASK_TAB(GOT_UNIT),1);     00652000
                  STACK_SIZE = CSECT_PROC(STACK_TAB(GOT_UNIT),0);               00652100
                  CODE_SIZE = CODE_SIZE + CSECT_PROC(PROC_TAB(GOT_UNIT),1);     00652200
                  IF LENGTH(TS) > 0 THEN OUTPUT = TS;                           00652300
                  SPACE_1;                                                      00652400
                  S1 = LPAD(CODE_SIZE,6);                                       00652500
                  S2 = LPAD(DATA_SIZE,6);                                       00652600
                  S3 = LPAD(STACK_SIZE,6);                                      00652700
                  OUTPUT = '            CODE: '||S1||MEM_TYPE||'    DATA: '||   00652800
                     S2||MEM_TYPE||'    STACK: '||S3||MEM_TYPE;                 00652900
               END;                                                             00653000
            END;                                                                00653100
            IF FIRST_STMT ~= 0 THEN DO;                                         00653200
               SPACE_1;                                                         00653300
               OUTPUT='            **** S T M T   F R E Q U E N C I E S ****';  00653400
               SPACE_1;                                                         00653500
               DO K = FIRST_STMT TO LAST_STMT;                                  00653600
                  STMTNO = K;                                                   00653700
                  CALL MONITOR(22,10);                                          00653800
                  IF CRETURN = 0 THEN DO;                                       00653900
                     COREWORD(ADDR(NODE_B)) = ADDRESS;                          00654000
                     STYPE = NODE_B(3);                                         00654100
                     STMT_CNT(STYPE) = STMT_CNT(STYPE) + 1;                     00654200
                     GLOBAL_STMT_CNT(STYPE) = GLOBAL_STMT_CNT(STYPE) + 1;       00654300
                  END;                                                          00654400
               END;                                                             00654500
               TS = '';                                                         00654600
               DO K = 0 TO 36;                                                  00654700
                  IF STMT_CNT(K) ~= 0 THEN DO;                                  00654800
                     IF LENGTH(TS) > 0 THEN TS = TS||COMMA;                     00654900
                     TS = TS||STMT_TYPES(K)||MINUS||STMT_CNT(K);                00655000
                     IF LENGTH(TS) > 110 THEN DO;                               00655100
                        OUTPUT = TS;                                            00655200
                        TS = '';                                                00655300
                     END;                                                       00655400
                     STMT_CNT(K) = 0;                                           00655500
                  END;                                                          00655600
               END;                                                             00655700
               IF LENGTH(TS) > 0 THEN OUTPUT = TS;                              00655800
            END;                                                                00655900
SKIP_STATS:                                                                     00656000
         END;                                                                   00656100
      END;                                                                      00656200
                                                                                00656300
      CLOCK(6) = MONITOR(18);                                                   00656400
                                                                                00656500
   /* FINALLY WE ARE READY TO DEVELOP THE GLOBAL SYMBOL DIRECTORY */            00656600
                                                                                00656700
      IF GSD_LEVEL > 0 THEN DO;                                                 00656800
         GOT_RECORD = 0;                                                        00656900
         INIT = TRUE;                                                           00657000
         INITIAL_SYMBOL = TRUE;                                                 00657100
         DO WHILE FAST_NEXT_SYMBOL;                                             00657200
            GOT_RECORD = GOT_RECORD + 1;                                        00657300
            COREWORD(ADDR(NODE_F)) = GOT_CELL_ADDR;                             00657400
            IF (GSD_LEVEL = 1)&((NODE_F(2)&"80000000")=0) THEN GO TO SKIP3;     00657500
            COREWORD(ADDR(NODE_H)) = GOT_CELL_ADDR;                             00657600
            COREWORD(ADDR(NODE_B)) = GOT_CELL_ADDR;                             00657700
            CLASS = NODE_B(6);                                                  00657800
            TYPE = NODE_B(7);                                                   00657900
            FLAG = NODE_F(2);                                                   00658000
            IF (FLAG & "02000000") ~= 0 THEN TEMPLATE_LINK = NODE_H(-1);        00658100
            IF (FLAG & "800") ~= 0 THEN GO TO SKIP3;                            00658200
            IF (CLASS=2)&(TYPE=9)&((FLAG&"80000000")=0) THEN DO;                00658300
               IF NODE_B(3) = 0 THEN GO TO SKIP3;                               00658400
               ELSE IF NODE_H(SHR(NODE_B(3),1)) = 1 THEN GO TO SKIP3;           00658500
            END;                                                                00658600
            IF INITIAL_SYMBOL THEN DO;                                          00658700
               INITIAL_SYMBOL = FALSE;                                          00658800
               IF BYTE(GOT_NAME) = BYTE(X1) THEN DO;                            00658900
                  TEMPLATING = TRUE;                                            00659000
                  CALL GSD_HDG('   (S T R U C T U R E   T E M P L A T E S)');   00659100
               END;                                                             00659200
               ELSE CALL GSD_HDG('');                                           00659300
            END;                                                                00659400
            ELSE IF TEMPLATING THEN DO;                                         00659500
               IF BYTE(GOT_NAME) ~= BYTE(X1) THEN DO;                           00659600
                  TEMPLATING = FALSE;                                           00659700
                  CALL GSD_HDG('');                                             00659800
               END;                                                             00659900
            END;                                                                00660000
            TS = LPAD(GOT_RECORD,5);                                            00660100
            TS(1) = X2||GOT_NAME;                                               00660200
            IF (FLAG&"00200000") ~= 0 THEN TS(3) = '  CONSTANT    ';            00660300
            ELSE IF CLASS = 4 THEN DO;                                          00660400
               TS(3) = '  TERMINAL    ';                                        00660500
               IF (TYPE = 16)&(NODE_H(SHR(NODE_B(5),1)+1)~=0) THEN              00660600
                  TS(3) = '  TEMPLATE    ';                                     00660700
            END;                                                                00660800
            ELSE TS(3) = SYMBOL_CLASSES(CLASS);                                 00660900
            IF (CLASS=2)|(CLASS=5) THEN TS(2) = PROC_TYPES(TYPE);               00661000
            ELSE TS(2) = SYMBOL_TYPES(TYPE);                                    00661100
            TS(5) = UNIT_NAMES(GOT_UNIT);                                       00661200
            EXCLUSIVE = FALSE;                                                  00661300
            IF (FLAG & "80000000") ~= 0 THEN DO;                                00661400
               TS(4) = '  C O M P O O L   ';                                    00661500
            END;                                                                00661600
            ELSE DO;                                                            00661700
               TS(4) = '  UNIT(BLOCK): ';                                       00661800
               TS(6) = BLOCK_NAME(NODE_H);                                      00661900
               COREWORD(ADDR(NODE_H1)) = ADDRESS;                               00662000
               IF (NODE_H1(12)&"4000") ~= 0 THEN EXCLUSIVE = TRUE;              00662100
               IF NODE_H(0) ~= KEY_BLOCK THEN DO;                               00662200
                  TS(5) = TS(5)||LPAREN||TS(6)||RPAREN;                         00662300
               END;                                                             00662400
            END;                                                                00662500
            TS = TS||TS(1)||TS(2)||TS(3)||TS(4)||TS(5);                         00662600
            CALL EMIT_OUTPUT(TS);                                               00662700
            TS = X15;                                                           00662800
            RLABEL = FALSE;                                                     00662900
            IF ((CLASS = 2)|(CLASS = 3))&((FLAG&"04000000")=0) THEN             00663000
               RLABEL = TRUE;                                                   00663100
            IF (FLAG&"10000000") ~= 0 THEN TS = TS||ATTR_TEMPORARY;             00663200
            ELSE IF (FLAG&"04000000") ~= 0 THEN DO;                             00663300
               TS = TS||ATTR_NAME;                                              00663400
               IF CLASS = 2 THEN DO;                                            00663500
                  IF TYPE = 1 THEN TS = TS||ATTR_PROGRAM;                       00663600
                  ELSE IF TYPE = 5 THEN TS = TS||ATTR_TASK;                     00663700
               END;                                                             00663800
            END;                                                                00663900
            IF NODE_B(5) > 0 THEN DO;                                           00664000
               K = SHR(NODE_B(5),1);                                            00664100
               STRUC0 = NODE_H(K);                                              00664200
               STRUC1 = NODE_H(K + 1);                                          00664300
               STRUC2 = NODE_H(K + 2);                                          00664400
            END;                                                                00664500
            ELSE STRUC0,STRUC1,STRUC2 = 0;                                      00664600
                                                                                00664700
DO_ARRAY:                                                                       00664800
   PROCEDURE;                                                                   00664900
                                                                                00665000
            IF NODE_B(4) > 0 THEN DO;                                           00665100
               K = SHR(NODE_B(4),1);                                            00665200
               ARRAY0 = NODE_H(K);                                              00665300
               ARRAY1 = NODE_H(K + 1);                                          00665400
               ARRAY2 = NODE_H(K + 2);                                          00665500
               ARRAY3 = NODE_H(K + 3);                                          00665600
               IF (TYPE ~= 16) THEN DO;                                         00665700
                  TS = TS||ATTR_ARRAY;                                          00665800
                  IF ARRAY0 = 1 THEN DO;                                        00665900
                     IF ARRAY1 < 0 THEN TS = TS||AST_RPAR_BLK;                  00666000
                     ELSE TS = TS||ARRAY1||RPAR_BLK;                            00666100
                  END;                                                          00666200
                  ELSE DO;                                                      00666300
                     TS = TS||ARRAY1||COMMA||ARRAY2;                            00666400
                     IF ARRAY0 = 3 THEN TS = TS||COMMA||ARRAY3;                 00666500
                     TS = TS||RPAR_BLK;                                         00666600
                  END;                                                          00666700
               END;                                                             00666800
            END;                                                                00666900
            ELSE ARRAY0,ARRAY1,ARRAY2,ARRAY3 = 0;                               00667000
   END DO_ARRAY;                                                                00667100
                                                                                00667200
            CALL DO_ARRAY;                                                      00667300
            IF TYPE = 16 THEN DO;                                               00667400
               IF ((FLAG&"02000000") = 0) THEN DO;                              00667500
                  IF STRUC1 ~= 0 THEN TS = TS||ATTR_MINOR_STRUC;                00667600
                  ELSE DO;                                                      00667700
                     TS = TS||SUBSTR(SYMBOL_NAME(NODE_H(9)),1)||'-STRUCTURE';   00667800
                     IF ARRAY1 < 0 THEN TS = TS||LPAR_AST_RPAR_BLK;             00667900
                     ELSE IF ARRAY1 > 1 THEN TS = TS||LPAREN||ARRAY1||RPAR_BLK; 00668000
                     ELSE TS = TS||X1;                                          00668100
                     IF CLASS = 3 THEN TS = TS||ATTR_FUNCTION;                  00668200
                  END;                                                          00668300
               END;                                                             00668400
            END;                                                                00668500
            IF ~((CLASS = 2) | (CLASS = 5)) THEN DO;                            00668600
                                                                                00668700
DO_TYPES:                                                                       00668800
   PROCEDURE;                                                                   00668900
                                                                                00669000
               IF (TYPE = 1)|(TYPE = 9)|(TYPE = 10)|(TYPE = 17) THEN DO;        00669100
                  TEMP1 = NODE_B(19);                                           00669200
                  IF TYPE = 17 THEN TS = TS||ATTR_EVENT;                        00669300
                  ELSE TS = TS||ATTR_BIT||TEMP1||RPAR_BLK;                      00669400
               END;                                                             00669500
               ELSE IF (TYPE=4)|(TYPE=12) THEN DO;                              00669600
                  TEMP1 = NODE_B(19);                                           00669700
                  TS = TS||ATTR_VECTOR||TEMP1||RPAR_BLK;                        00669800
                  IF TYPE = 12 THEN TS = TS||ATTR_DOUBLE;                       00669900
               END;                                                             00670000
               ELSE IF (TYPE=3)|(TYPE=11) THEN DO;                              00670100
                  TEMP1 = NODE_B(18);                                           00670200
                  TEMP2 = NODE_B(19);                                           00670300
                  TS = TS||ATTR_MATRIX||TEMP1||COMMA||TEMP2||RPAR_BLK;          00670400
                  IF TYPE = 11 THEN TS = TS||ATTR_DOUBLE;                       00670500
               END;                                                             00670600
               ELSE IF TYPE = 2 THEN DO;                                        00670700
                  TEMP1 = NODE_H(9);                                            00670800
                  IF TEMP1 < 0 THEN TS = TS||ATTR_CHARACTER||AST_RPAR_BLK;      00670900
                  ELSE TS = TS||ATTR_CHARACTER||TEMP1||RPAR_BLK;                00671000
               END;                                                             00671100
               ELSE IF (TYPE=6)|(TYPE=14) THEN DO;                              00671200
                  TS = TS||ATTR_INTEGER;                                        00671300
                  IF TYPE = 14 THEN TS = TS||ATTR_DOUBLE;                       00671400
               END;                                                             00671500
               ELSE IF (TYPE=5)|(TYPE=13) THEN DO;                              00671600
                  TS = TS||ATTR_SCALAR;                                         00671700
                  IF TYPE = 13 THEN TS = TS||ATTR_DOUBLE;                       00671800
               END;                                                             00671900
   END DO_TYPES;                                                                00672000
               CALL DO_TYPES;                                                   00672100
            END;                                                                00672200
            IF (CLASS=3)&(TYPE~=16) THEN TS = TS||ATTR_FUNCTION;                00672300
            IF ((FLAG&"00020000")~=0) THEN DO;                                  00672400
               TEMP1 = NODE_B(20);                                              00672500
               IF TEMP1 = "FF" THEN TS = TS||ATTR_LOCK||AST_RPAR_BLK;           00672600
               ELSE TS = TS||ATTR_LOCK||TEMP1||RPAR_BLK;                        00672700
            END;                                                                00672800
            TS(1) = '';                                                         00672900
            IF RLABEL = FALSE THEN                                              00673000
               IF (FLAG&"00040000") ~= 0 THEN TS = TS||ATTR_LATCHED;            00673100
            IF (FLAG&"00010000") ~= 0 THEN TS = TS||ATTR_REMOTE;                00673200
            IF (FLAG&"00400000") ~= 0 THEN TS = TS||ATTR_DENSE;                 00673300
            IF (FLAG&"08000000") ~= 0 THEN TS = TS||ATTR_AUTOMATIC;             00673400
            IF (FLAG&"00002000") ~= 0 THEN TS = TS||ATTR_RIGID;                 00673500
            IF (FLAG&"00004000") ~= 0 THEN TS = TS||ATTR_INITIAL;               00673600
            IF (FLAG&"00200000") ~= 0 THEN TS = TS||ATTR_CONSTANT;              00673700
            IF (FLAG&"00100000") ~= 0 THEN TS = TS||ATTR_ACCESS;                00673800
            IF (RLABEL=TRUE)&((CLASS=3)|((CLASS=2)&(TYPE=2))) THEN DO;          00673900
               IF (FLAG&"00800000")~=0 THEN TS = TS||ATTR_REENTRANT;            00674000
               ELSE IF EXCLUSIVE THEN TS = TS||ATTR_EXCLUSIVE;                  00674100
            END;                                                                00674200
            IF (CLASS=2)&(TYPE=8) THEN                                          00674300
               TS = TS||'(SEE SYMBOL # '||GLOBAL_SYMB(NODE_H(9))||RPAR_BLK;     00674400
            IF (TYPE=16)&((FLAG&"02000000")=0)&(STRUC1=0) THEN                  00674500
               TS = TS||'(SEE TEMPLATE # '||GLOBAL_SYMB(NODE_H(9))||RPAR_BLK;   00674600
            IF CLASS > 3 THEN DO;                                               00674700
               TEMP1 = GLOBAL_SYMB(STRUC0);                                     00674800
               IF (FLAG & "02000000") = 0 THEN DO;                              00674900
                  COREWORD(ADDR(NODE_B1)) = COREWORD(ADDR(NODE_B));             00675000
                  COREWORD(ADDR(NODE_H1)) = COREWORD(ADDR(NODE_H));             00675100
                  COREWORD(ADDR(NODE_F1)) = COREWORD(ADDR(NODE_F));             00675200
                  FLAG1 = FLAG;                                                 00675300
                  DO WHILE (FLAG1&"02000000") = 0;                              00675400
                     NEXT1 = NODE_H1(SHR(NODE_B1(5),1)+2);                      00675500
                     IF NEXT1 < 0 THEN NEXT1 = - NEXT1;                         00675600
                     SYMBNO = NEXT1;                                            00675700
                     CALL MONITOR(22,9);                                        00675800
                     COREWORD(ADDR(NODE_B1)) = ADDRESS;                         00675900
                     COREWORD(ADDR(NODE_H1)) = ADDRESS;                         00676000
                     COREWORD(ADDR(NODE_F1)) = ADDRESS;                         00676100
                     FLAG1 = NODE_F1(2);                                        00676200
                  END;                                                          00676300
                  TS = TS||'(BELONGS TO TEMPLATE # '||GLOBAL_SYMB(NEXT1)||      00676400
                     RPAR_BLK;                                                  00676500
               END;                                                             00676600
            END;                                                                00676700
            IF (FLAG&"00000100") ~= 0 THEN TS(1) = TS(1)||ATTR_EQUATED;         00676800
            IF (FLAG&"00000400") ~= 0 THEN TS(1) = TS(1)||ATTR_STACK;           00676900
            IF (FLAG&"40000000") ~= 0 THEN TS(1) = TS(1)||ATTR_INPUT;           00677000
            IF (FLAG&"20000000") ~= 0 THEN TS(1) = TS(1)||ATTR_ASSIGN;          00677100
            IF (FLAG&"00000010") ~= 0 THEN TS(1) = TS(1)||ATTR_NAMED;           00677105
            IF (FLAG&"00000008") ~= 0 THEN TS(1) = TS(1)||ATTR_PARAMETERIZED;   00677110
            IF (FLAG&"00001000") ~= 0 THEN TS(1) = TS(1)||ATTR_LITERAL;         00677200
            IF (FLAG&"01000000") ~= 0 THEN DO;                                  00677300
               IF CLASS < 4 THEN TS(1) = TS(1)||ATTR_UNQUALIFIED;               00677400
               ELSE IF TEMP1 ~= 0 THEN TS(1) = TS(1)||                          00677500
                  'UNQUALIFIED - SEE STRUC # '||TEMP1||COMMA;                   00677600
            END;                                                                00677700
            IF RLABEL = FALSE THEN                                              00677800
               IF (FLAG&"00080000") ~= 0 THEN TS(1) = TS(1)||ATTR_INDIRECT;     00677900
            K = LENGTH(TS(1));                                                  00678000
            IF K > 0 THEN DO;                                                   00678100
               IF LENGTH(TS) > 15 THEN TS = TS||X5;                             00678200
               TS = TS||LPAREN||SUBSTR(TS(1),0,K-1)||RPAR_BLK;                  00678300
            END;                                                                00678400
            IF LENGTH(TS) > 15 THEN CALL EMIT_OUTPUT(TS);                       00678500
            IF (RLABEL=FALSE)|((CLASS=2)&(TYPE=8)) THEN DO;                     00678600
               TS = X15;                                                        00678700
               SADDR = NODE_F(3)&"FFFFFF";                                      00678800
               ADDR_CHAIN = 0;                                                  00678900
               SEXTENT = NODE_F(5)&"FFFFFF";                                    00679000
               IF CLASS > 3 THEN DO;                                            00679100
                  TS(1) = HEX6(SADDR);                                          00679200
                  TS = TS||'TEMPLATE OFFSET: '||TS(1)||X1;                      00679300
               END;                                                             00679400
               ELSE IF (FLAG&"00000400") ~= 0 THEN DO;                          00679500
                  IF FC_FLAG THEN DO;                                           00679600
                     TEMP1 = SHL(0,9) | (NODE_H(8)&"7F");                       00679700
                     TS(1) = HEX4(TEMP1);                                       00679800
                     TS = TS||'STACK FRAME: '||TS(1)||X1;                       00679900
                  END;                                                          00680000
                  TS(1) = HEX6(SADDR);                                          00680100
                  TS = TS||'STACK OFFSET: '||TS(1)||X1;                         00680200
               END;                                                             00680300
               ELSE IF (FLAG&"00001000") = 0 THEN DO;  /* SKIP LITERALS */      00680400
                  IF ((FLAG&"00010000")~=0)&(FC_FLAG=TRUE) THEN DO;             00680500
                     ADDR_CHAIN = #F#R(GOT_UNIT);                               00680600
                     S1 = REMOTE_CSECT;                                         00680700
                  END;                                                          00680800
                  ELSE DO;                                                      00680900
                     ADDR_CHAIN = #D#P(GOT_UNIT);                               00681000
                     IF (FLAG&"80000000") ~= 0 THEN                             00681100
                        S1 = COMPOOL_CSECT;                                     00681200
                     ELSE S1 = DATA_CSECT;                                      00681300
                  END;                                                          00681400
                  S1 = S1||SUBSTR(SDF_NAMES(GOT_UNIT),2)||X1;                   00681500
                  TS(1) = HEX6(SADDR);                                          00681600
                  TS = TS||'(CSECT: '||S1||                                     00681700
                     'OFFSET: '||TS(1)||RPAR_BLK;                               00681800
               END;                                                             00681900
               IF (RLABEL=FALSE)&((FLAG&"00001000")=0) THEN DO;                 00682000
                  TS(1) = HEX6(SEXTENT);                                        00682100
                  TS = TS||'SIZE: '||TS(1)||LPAREN||SEXTENT||RPAR_BLK;          00682200
                  IF (FLAG&"00008000") ~= 0 THEN DO;                            00682300
                     TEMP1 = NODE_F(SHR(NODE_B(2),2));                          00682400
                     TS(1) = HEX6(TEMP1);                                       00682500
                     TS = TS||'BIAS: '||TS(1)||LPAREN||TEMP1||RPAR_BLK;         00682600
                  END;                                                          00682700
               END;                                                             00682800
                                                                                00682900
DO_PATTERN:                                                                     00683000
   PROCEDURE;                                                                   00683100
                                                                                00683200
               IF (CLASS=4)&((TYPE=1)|(TYPE=9)|(TYPE=10)|(TYPE=17)) THEN DO;    00683300
                  IF ((FLAG&"00400000")~=0)&((FLAG&"04000000")=0) THEN DO;      00683400
                     TEMP1 = NODE_B(18);                                        00683500
                     IF TEMP1 = "FF" THEN TEMP1 = 0;                            00683600
                     TEMP2 = NODE_B(19);                                        00683700
                     TEMP3 = 32 - (TEMP1 + TEMP2);                              00683800
                     PATTERN_CHAR = SUBSTR(X_CHAR,0,TEMP2);                     00683900
                     IF TEMP3 > 0 THEN PATTERN_CHAR =                           00684000
                        SUBSTR(ZERO_CHAR,0,TEMP3)||PATTERN_CHAR;                00684100
                     IF TEMP1 > 0 THEN PATTERN_CHAR = PATTERN_CHAR||            00684200
                        SUBSTR(ZERO_CHAR,0,TEMP1);                              00684300
                     IF TYPE = 1 THEN TEMP2 = 16;                               00684400
                     ELSE IF TYPE = 9 THEN TEMP2 = 32;                          00684500
                     ELSE TEMP2 = 8;                                            00684600
                     PATTERN_CHAR = SUBSTR(PATTERN_CHAR,32-TEMP2,TEMP2);        00684700
                     TS = TS||SUBSTR(PATTERN_CHAR,0,4)||                        00684800
                        X1||SUBSTR(PATTERN_CHAR,4,4)||X1;                       00684900
                     IF TEMP2 > 8 THEN TS = TS||SUBSTR(PATTERN_CHAR,8,4)||      00685000
                        X1||SUBSTR(PATTERN_CHAR,12,4)||X1;                      00685100
                     IF TEMP2 > 16 THEN TS = TS||SUBSTR(PATTERN_CHAR,16,4)||    00685200
                        X1||SUBSTR(PATTERN_CHAR,20,4)||X1||                     00685300
                        SUBSTR(PATTERN_CHAR,24,4)||X1||                         00685400
                        SUBSTR(PATTERN_CHAR,28,4)||X1;                          00685500
                  END;                                                          00685600
               END;                                                             00685700
   END DO_PATTERN;                                                              00685800
                                                                                00685900
               DO WHILE ADDR_CHAIN ~= 0;                                        00686000
                  GOT_PHASE = SHR(CSECT_LENGTH(ADDR_CHAIN),24);                 00686100
                  ADDR_INC = CSECT_ADDR(ADDR_CHAIN)&"FFFFFF";                   00686200
                  TS(1) = HEX6(SADDR + ADDR_INC);                               00686300
                  IF MAX_PHASE > 1 THEN TS(2) = ATTR_PHASE||GOT_PHASE||X1;      00686400
                  ELSE TS(2) = '';                                              00686500
                  TS(2) = TS(2)||'ADDR: '||TS(1)||X2;                           00686600
                  IF LENGTH(TS) + LENGTH(TS(2)) > 132 THEN DO;                  00686700
                     OUTPUT = TS;                                               00686800
                     TS = X15||TS(2);                                           00686900
                  END;                                                          00687000
                  ELSE TS = TS||TS(2);                                          00687100
                  ADDR_CHAIN = CSECT_LINK(ADDR_CHAIN);                          00687200
               END;                                                             00687300
               IF LENGTH(TS) > 15 THEN OUTPUT = TS;                             00687400
            END;                                                                00687500
                                                                                00687600
   /* EMIT REPLACE TEXT VALUE (IF ANY) */                                       00687700
                                                                                00687800
            IF (CLASS=2)&(TYPE=9) THEN DO;                                      00687900
               IF VERSION >= 25 THEN DO;                                        00688000
                  IF NODE_F(5) ~= 0 THEN DO;                                    00688100
                     LEN = EXTRACT_REPLACE_TEXT(NODE_F(5),REPL_TEXT_ADDR1);     00688200
                     CALL PRINT_REPLACE_TEXT(X15,126,REPL_TEXT_ADDR1,LEN);      00688300
                  END;                                                          00688400
               END;                                                             00688500
            END;                                                                00688600
                                                                                00688700
   /* PROCESS CROSS-REFERENCE INFORMATION */                                    00688800
                                                                                00688900
            #REFS1,#REFS2,REF_STAT = 0;                                         00689000
            IF COMPOOL_FLAG THEN DO;                                            00689100
               CALL VMEM_LOCATE_COPY(1,VAR_BASE(GOT_UNIT),GOT_LINK,0);          00689200
               CALL PRINT_CROSS_REF(VMEM_F(0));                                 00689300
            END;                                                                00689400
            ELSE IF GOT_LINK = KEY_SYMB THEN DO;                                00689500
               CALL VMEM_LOCATE_COPY(1,VAR_BASE(GOT_UNIT),1,0);                 00689600
               CALL PRINT_CROSS_REF(VMEM_F(0));                                 00689700
            END;                                                                00689800
            ELSE IF NODE_B(3) > 0 THEN DO;                                      00689900
               HOLD_PTR = 0;                                                    00690000
               COREWORD(ADDR(NODE_F1)) = GOT_CELL_ADDR;                         00690100
               COREWORD(ADDR(NODE_H1)) = GOT_CELL_ADDR;                         00690200
               K = SHR(NODE_B(3),1);                                            00690300
               S2 = PAD(UNIT_NAMES(GOT_UNIT),32);                               00690400
               S1 = PERIOD3||S2||X2;                                            00690500
               L = NODE_H1(K);                                                  00690600
               K = K + 1;                                                       00690700
               DO J = 1 TO L;                                                   00690800
                  M = NODE_H1(K);                                               00690900
                  IF M ~= -1 THEN DO;                                           00691000
                     KK = M&"E000";                                             00691100
                     REF_STAT = REF_STAT | KK;                                  00691600
                     S1 = S1||(SHR(M,13)&7)||X1||SUBSTR(10000+(M&"1FFF"),1,4)|| 00691700
                        GET_SRN(M);                                             00691800
                     IF LENGTH(S1) + SHL(GFORMAT,3) > 108 THEN DO;              00691900
                        OUTPUT = S1;                                            00692000
                        S1 = X52;                                               00692100
                     END;                                                       00692200
                  END;                                                          00692300
                  ELSE DO;                                                      00692400
                     J = J - 1;                                                 00692600
                     K = SHR(K + 2,1);                                          00692700
                     IF GFORMAT > 0 THEN DO;                                    00692800
                        IF HOLD_PTR ~= 0 THEN DO;                               00692900
                           PNTR = HOLD_PTR;                                     00693000
                           CALL MONITOR(22,"20000005");                         00693100
                        END;                                                    00693200
                        HOLD_PTR,PNTR =  NODE_F1(K);                            00693300
                        CALL MONITOR(22,"10000005");                            00693400
                     END;                                                       00693500
                     ELSE DO;                                                   00693600
                        PNTR = NODE_F1(K);                                      00693700
                        CALL MONITOR(22,5);                                     00693800
                     END;                                                       00693900
                     COREWORD(ADDR(NODE_F1)) = ADDRESS;                         00694000
                     COREWORD(ADDR(NODE_H1)) = ADDRESS;                         00694100
                     K = -1;                                                    00694200
                  END;                                                          00694300
                  K = K + 1;                                                    00694400
               END;                                                             00694500
               IF LENGTH(S1) > 52 THEN OUTPUT = S1;                             00694600
               REF_STAT = SHR(REF_STAT,13)&7;                                   00694700
               IF HOLD_PTR ~= 0 THEN DO;                                        00694800
                  PNTR = HOLD_PTR;                                              00694900
                  CALL MONITOR(22,"20000005");                                  00695000
                  HOLD_PTR = 0;                                                 00695100
               END;                                                             00695200
            END;                                                                00695300
            ELSE REF_STAT = -1;                                                 00695400
            IF REF_STAT ~= -1 THEN DO;                                          00695500
               IF REF_STAT THEN REF_STAT = REF_STAT|2;                          00695600
               REF_STAT = SHR(REF_STAT,1);                                      00695700
               DO CASE REF_STAT;                                                00695800
                  DO;     /* DECLARED ONLY */                                   00695900
NOT_USED:                                                                       00696000
                     IF (FLAG&"20000000") ~= 0 THEN GO TO SET_ERROR;            00696100
                     IF (FLAG&"00000100") ~= 0 THEN GO TO END_CASE;             00696200
                     IF (CLASS>3)&((FLAG&"02000000")=0) THEN GO TO END_CASE;    00696300
                     IF (FLAG&"04000000")=0 THEN DO;                            00696400
                        IF (CLASS = 2)&(TYPE ~= 9) THEN DO;                     00696500
                           IF (TYPE=4)|(TYPE=6)|(TYPE=7)|(TYPE=8) THEN          00696600
                              GO TO END_CASE;                                   00696700
                           ELSE IF NODE_H(0) = KEY_BLOCK THEN                   00696800
                              GO TO END_CASE;                                   00696900
                        END;                                                    00697000
                     END;                                                       00697100
                     IF MSG_LEVEL > 0 THEN                                      00697200
                        OUTPUT = X52||'*** SYMBOL POSSIBLY NOT USED ***';       00697300
                     UNUSED_CNT = UNUSED_CNT + 1;                               00697400
                  END;                                                          00697500
                  DO;     /* REFERENCED ONLY */                                 00697600
                     IF (FLAG&"40204000") ~= 0 THEN GO TO END_CASE;             00697700
                     IF (CLASS=3)|((CLASS=2)&((FLAG&"04000000")=0)) THEN        00697800
                        GO TO END_CASE;                                         00697900
                     IF CLASS > 3 THEN GO TO END_CASE;  /* WEED OUT TEMPLATES */00698000
                     IF (FLAG&"00000100") ~= 0 THEN GO TO END_CASE;             00698100
SET_ERROR:                                                                      00698200
                     S1 = 'SYMBOL REFERENCED BUT NOT ASSIGNED';                 00698300
                     CALL ERROR(S1,1);                                          00698400
                     SPACE_1;                                                   00698500
                     UNASSIGN_CNT = UNASSIGN_CNT + 1;                           00698600
                  END;                                                          00698700
                  DO;      /* ASSIGNED ONLY */                                  00698800
                     IF CLASS > 3 THEN GO TO END_CASE;                          00698900
                     IF (FLAG&"20000000") ~= 0 THEN GO TO END_CASE;             00699000
                     GO TO NOT_USED;                                            00699100
                  END;                                                          00699200
                  DO;     /* REFERENCED + ASSIGNED */                           00699300
                  END;                                                          00699400
END_CASE:                                                                       00699500
               END;                                                             00699600
            END;                                                                00699700
            IF (FLAG & "02000000") ~= 0 THEN DO;                                00699800
               SPACE_1;                                                         00699900
               TS = '                      STRUCTURE'||REAL_NAME;               00700000
               IF (FLAG & "00400000") ~= 0 THEN TS = TS||' DENSE';              00700100
               IF (FLAG & "00002000") ~= 0 THEN TS = TS||' RIGID';              00700200
               OUTPUT = TS||COLON;                                              00700300
               TS = '';                                                         00700400
               LINK = STRUC1;                                                   00700500
               TPL_STACK1(0) = 0;                                               00700600
               STACK_INX = 1;                                                   00700700
               DO WHILE LINK > 0;                                               00700800
                  IF LENGTH(TS) > 0 THEN OUTPUT = TS||COMMA;                    00700900
                  SPACE_1;                                                      00701000
                  GOT_NAME = SYMBOL_NAME(LINK);                                 00701100
                  COREWORD(ADDR(NODE_F)) = ADDRESS;                             00701200
                  COREWORD(ADDR(NODE_H)) = ADDRESS;                             00701300
                  COREWORD(ADDR(NODE_B)) = ADDRESS;                             00701400
                  CLASS = NODE_B(6);                                            00701500
                  TYPE = NODE_B(7);                                             00701600
                  FLAG = NODE_F(2);                                             00701700
                  TS = X15||LPAD(GLOBAL_SYMB(LINK),5)||X2||                     00701800
                     SUBSTR(X72,0,3*STACK_INX)||STACK_INX||                     00701900
                     X1||GOT_NAME||X1;                                          00702000
DO_ENTRY:                                                                       00702100
   PROCEDURE;                                                                   00702200
                                                                                00702300
                  K = SHR(NODE_B(5),1);                                         00702400
                  STRUC1 = NODE_H(K + 1);                                       00702500
                  STRUC2 = NODE_H(K + 2);                                       00702600
                  IF (FLAG & "04000000") ~= 0 THEN TS = TS||ATTR_NAME;          00702700
                  IF CLASS > 4 THEN DO;                                         00702800
                     IF TYPE = 1 THEN TS = TS||ATTR_PROGRAM;                    00702900
                     ELSE IF TYPE = 5 THEN TS = TS||ATTR_TASK;                  00703000
                  END;                                                          00703100
                  ELSE DO;                                                      00703200
                     CALL DO_ARRAY;                                             00703300
                     IF TYPE = 16 THEN DO;                                      00703400
                        IF STRUC1 = 0 THEN DO;                                  00703500
                           CALL MONITOR(22,"10000006");                         00703600
                           TS = TS||SUBSTR(SYMBOL_NAME(NODE_H(9)),1)||          00703700
                              '-STRUCTURE';                                     00703800
                           IF ARRAY1 < 0 THEN TS = TS||'(*)';                   00703900
                           ELSE IF ARRAY1 > 1 THEN                              00704000
                              TS = TS||LPAREN||ARRAY1||RPAR_BLK;                00704100
                           ELSE TS = TS||X1;                                    00704200
                           TS = TS||'(SEE TEMPLATE # '||                        00704300
                              GLOBAL_SYMB(NODE_H(9))||RPAR_BLK;                 00704400
                           SYMBNO = LINK;                                       00704500
                           CALL MONITOR(22,"20000009");                         00704600
                        END;                                                    00704700
                     END;                                                       00704800
                     ELSE CALL DO_TYPES;                                        00704900
                  END;                                                          00705000
                  IF ((FLAG&"00040000")~=0)&(CLASS=4) THEN                      00705100
                     TS = TS||ATTR_LATCHED;                                     00705200
                  IF (FLAG & "00400000") ~= 0 THEN                              00705300
                     TS = TS||ATTR_DENSE;                                       00705400
                  IF (FLAG & "00002000") ~= 0 THEN                              00705500
                     TS = TS||ATTR_RIGID;                                       00705600
                  TMP = LENGTH(TS);                                             00705700
                  TS = SUBSTR(TS,0,TMP-1);                                      00705800
   END DO_ENTRY;                                                                00705900
                                                                                00706000
                  CALL DO_ENTRY;                                                00706100
                  IF STRUC1 ~= 0 THEN DO;                                       00706200
                     TPL_STACK1(STACK_INX) = STRUC2;                            00706300
                     STACK_INX = STACK_INX + 1;                                 00706400
                     LINK = STRUC1;                                             00706500
                  END;                                                          00706600
                  ELSE IF STRUC2 > 0 THEN LINK = STRUC2;                        00706700
                  ELSE DO;                                                      00706800
                     LINK = -1;                                                 00706900
                     DO WHILE LINK < 0;                                         00707000
                        STACK_INX = STACK_INX - 1;                              00707100
                        LINK = TPL_STACK1(STACK_INX);                           00707200
                     END;                                                       00707300
                  END;                                                          00707400
               END;                                                             00707500
               OUTPUT = TS||SEMI_COLON;                                         00707600
               SPACE_1;                                                         00707700
               OUTPUT = '                      MEMORY ALLOCATION';              00707800
               CURRENT_BASE = 0;                                                00707900
               STACK_INX = 0;                                                   00708000
               OLD_ADDR = -1;                                                   00708100
               LINK = TEMPLATE_LINK;                                            00708200
               DO FOREVER;                                                      00708300
                  CALL SUB1;                                                    00708400
                  NEW_LINK = NODE_H(-1);                                        00708500
                  IF (TYPE=16)&((FLAG&"04000000")=0) THEN DO;                   00708600
                     IF (NODE_H(SHR(NODE_B(5),1)+1)=0) THEN DO;                 00708700
                        TPL_STACK1(STACK_INX) = NEW_LINK;                       00708800
                        TPL_STACK2(STACK_INX) = CURRENT_BASE;                   00708900
                        CALL PUSH_STACK;                                        00709000
                        CURRENT_BASE = CURRENT_BASE + (NODE_F(3)&"FFFFFF");     00709100
                        NEW_LINK = NODE_H(9);                                   00709200
                     END;                                                       00709300
                  END;                                                          00709400
                  ELSE DO;                                                      00709500
                     CALL SUB1A;                                                00709600
                     IF OLD_ADDR ~= ADDR1 THEN SPACE_1;                         00709700
                     OLD_ADDR = ADDR1;                                          00709800
                     CALL SET_STRINGS;                                          00709900
                     TS = X15||TS(2)||X2||S1||S2||X2||SYMBOL_STRING||X1;        00710000
                     CALL DO_ENTRY;                                             00710100
                     TS = PAD(TS,92);                                           00710200
                     CALL DO_PATTERN;                                           00710300
                     OUTPUT = TS;                                               00710400
                  END;                                                          00710500
                  DO WHILE NEW_LINK = 0;                                        00710600
                     IF STACK_INX = 0 THEN GO TO END_TPL;                       00710700
                     STACK_INX = STACK_INX - 1;                                 00710800
                     CURRENT_BASE = TPL_STACK2(STACK_INX);                      00710900
                     NEW_LINK = TPL_STACK1(STACK_INX);                          00711000
                  END;                                                          00711100
                  LINK = NEW_LINK;                                              00711200
               END;                                                             00711300
END_TPL:                                                                        00711400
               SPACE_1;                                                         00711500
            END;                                                                00711600
            CALL EMIT_TEXT(GOT_LINK+1,2);                                       00711700
            IF GOT_LINK = KEY_SYMB THEN DO;                                     00711800
               UNIT_REF_CNT1(GOT_UNIT) = #REFS1;                                00711900
               UNIT_REF_CNT2(GOT_UNIT) = #REFS2-1;                              00712000
            END;                                                                00712100
SKIP3:                                                                          00712200
         END;                                                                   00712300
         OUTPUT(1) = TWO;                                                       00712400
         CALL VMEM_SEQ_CLOSE(SYSTEM);                                           00712500
      END;                                                                      00712600
                                                                                00712700
    /* EMIT THE NONHAL SEGMENT OF THE GSD LISTING IF REQUESTED */               00712800
                                                                                00712900
      IF GSD_LEVEL > 2 THEN DO;                                                 00713000
         IF VMEM_GET_STRUC_COPIES(2,SYM_STRUC_PTR) > 0 THEN DO;                 00713100
            OUTPUT(1) = '2  #        NAME      CSECT/REL. ADDR       ATTRIBUTES 00713200
       LENGTH    SCALE        PHASE/ABS. ADDRESS';                              00713300
            OUTPUT(1) = ONE;                                                    00713400
            CALL VMEM_SEQ_OPEN(2,SYM_STRUC_PTR,SYSTEM,1,0);                     00713500
            DO WHILE VMEM_NEXT_COPY(SYSTEM,0);                                  00713600
               OUTPUT = X1;                                                     00713700
               TS = LPAD(VMEM_SEQ_LOC_COPY,5)||X4;                              00713800
               TS(1) = STRING("07000000" + VMEM_SEQ_LOC_ADDR)||X4;              00713900
               J = SEQ_H(4);    /* SYM_CSECT_ID */                              00714000
               CALL VMEM_LOCATE_PTR(1,SEQ_F(3),0);                              00714100
               SYM_ADDR = VMEM_F(4)&"FFFFFF";                                   00714200
               SYM_ORG = SHR(VMEM_F(4),24)&"FF";                                00714300
               CSECT_NAME = STRING("07000000" + ADDR(CSECT_CHAR(SHL(J,1))));    00714400
               TS(2) = LPAREN||CSECT_NAME||PLUS||HEX4(SYM_ADDR)||')    ';       00714500
               TS(3) = '';                                                      00714600
               IF (SYM_ORG & "80") = 0 THEN DO;                                 00714700
                  TS(4),TS(5) = X10;                                            00714800
                  NDATA_TYPE = SHR(SYM_ORG&"70",4);                             00714900
                  DO CASE NDATA_TYPE;                                           00715000
                     ;                                                          00715100
                     TS(3) = 'CSECT';                                           00715200
                     ;;                                                         00715300
                     TS(3) = 'EQU    *';                                        00715400
                     TS(3) = 'CCW';                                             00715500
                     ;;                                                         00715600
                  END;                                                          00715700
               END;                                                             00715800
               ELSE DO;                                                         00715900
                  SYM_MULT = VMEM_F(5)&"FFFFFF";                                00716000
                  SYM_DATA_DEX = SHR(VMEM_F(5),24)&"FF";                        00716100
                  SYM_DATA_LEN = VMEM_H(12);                                    00716200
                  SYM_SCAL = VMEM_H(13);                                        00716300
                  IF SYM_MULT = 0 THEN TS(3) = 'DS     ';                       00716400
                  ELSE TS(3) = 'DC     ';                                       00716500
                  IF SYM_MULT = 0 THEN TS(3) = TS(3)||ZEROCHAR;                 00716600
                  ELSE IF SYM_MULT > 1 THEN TS(3) = TS(3)||SYM_MULT;            00716700
                  TS(4) = LPAD(SYM_MULT*SYM_DATA_LEN,6)||X4;                    00716800
                  IF SYM_SCAL ~= 0 THEN TS(5) = LPAD(SYM_SCAL,6)||X4;           00716900
                  ELSE TS(5) = X10;                                             00717000
                  DO CASE SYM_DATA_DEX;                                         00717100
                     TS(3) = TS(3)||CLCHAR||SYM_DATA_LEN;                       00717200
                     TS(3) = TS(3)||XLCHAR||SYM_DATA_LEN;                       00717300
                     TS(3) = TS(3)||BLCHAR||SYM_DATA_LEN;                       00717400
                     ;                                                          00717500
                     TS(3) = TS(3)||FCHAR;                                      00717600
                     TS(3) = TS(3)||HCHAR;                                      00717700
                     TS(3) = TS(3)||ECHAR;                                      00717800
                     TS(3) = TS(3)||DCHAR;                                      00717900
                     DO;                                                        00718000
                        IF FC_FLAG THEN TS(3) = TS(3)||ZCHAR;                   00718100
                        ELSE TS(3) = TS(3)||ACHAR;                              00718200
                     END;                                                       00718300
                     TS(3) = TS(3)||YCHAR;                                      00718400
                  END;                                                          00718500
               END;                                                             00718600
               TS(3) = PAD(TS(3),21);                                           00718700
               TS = TS||TS(1)||TS(2)||TS(3)||TS(4)||TS(5);                      00718800
               ADDR_CHAIN = J;                                                  00718900
               DO WHILE ADDR_CHAIN ~= 0;                                        00719000
                  GOT_PHASE = SHR(CSECT_LENGTH(ADDR_CHAIN),24)&"FF";            00719100
                  ADDR_INC = CSECT_ADDR(ADDR_CHAIN)&"FFFFFF";                   00719200
                  TS(6) = HEX6(SYM_ADDR + ADDR_INC);                            00719300
                  IF MAX_PHASE > 1 THEN TS(7) = ATTR_PHASE||GOT_PHASE||X1;      00719400
                  ELSE TS(7) = '';                                              00719500
                  TS(7) = TS(7)||'ADDR: '||TS(6)||X2;                           00719600
                  IF LENGTH(TS) + LENGTH(TS(7)) > 132 THEN DO;                  00719700
                     OUTPUT = TS;                                               00719800
                     TS = SUBSTR(PRINTLINE,0,81)||TS(7);                        00719900
                  END;                                                          00720000
                  ELSE TS = TS||TS(7);                                          00720100
                  ADDR_CHAIN = 0;   /* TEMPORARY */                             00720200
               END;                                                             00720300
               OUTPUT = TS;                                                     00720400
            END;                                                                00720500
            CALL VMEM_SEQ_CLOSE(SYSTEM);                                        00720600
            OUTPUT(1) = TWO;                                                    00720700
         END;                                                                   00720800
      END;                                                                      00720900
                                                                                00721000
   /* PRINT A LIST OF COMPILATION UNIT REFERENCE COUNTS */                      00721100
                                                                                00721200
      IF (GSD_LEVEL > 1)&(#UNITS > 1) THEN DO;                                  00721300
         TS='2                              C O M P I L A T I O N   U N I T   R 00721400
E F E R E N C E   C O U N T S';                                                 00721500
         OUTPUT(1) = TS;                                                        00721600
         OUTPUT(1) = ONE;                                                       00721700
         SPACE_1;                                                               00721800
         OUTPUT = ' CNT1 = TOTAL NUMBER OF CALLS (PROCEDURES/FUNCTIONS), = TOTAL00721900
 NUMBER OF NAME REFERENCES (PROGRAMS)';                                         00722000
         OUTPUT = ' CNT2 = TOTAL NUMBER OF REFERENCING COMPILATION UNITS';      00722100
         SPACE_1;                                                               00722200
         OUTPUT='  #    COMPILATION UNIT NAME                 UNIT TYPE       CN00722300
T1     CNT2';                                                                   00722400
         DSPACE;                                                                00722500
         DO UNIT_NO = 1 TO #UNITS;                                              00722600
            I = UNIT_SORT(UNIT_NO);                                             00722700
            S1 = LPAD(UNIT_NO,3);                                               00722800
            S2 = PAD(UNIT_NAMES(I),32);                                         00722900
            S3 = PROC_TYPES(UNIT_TYPE(I));                                      00723000
            S4 = LPAD(UNIT_REF_CNT1(I),5);                                      00723100
            S5 = LPAD(UNIT_REF_CNT2(I),5);                                      00723200
            OUTPUT = S1||X4||S2||X4||S3||X4||S4||X4||S5;                        00723300
         END;                                                                   00723400
      END;                                                                      00723500
                                                                                00723600
      CLOCK(7) = MONITOR(18);                                                   00723700
                                                                                00723800
   /* MAP GENERATION LOGIC -- DRIVEN BY CONTROL LOGIC THAT FOLLOWS */           00723900
                                                                                00724000
MAP_GENERATION:                                                                 00724100
   PROCEDURE;                                                                   00724200
                                                                                00724300
CSECT_OK:                                                                       00724400
   PROCEDURE (J) BIT(1);                                                        00724500
      DECLARE (J,ADDRESS_TEMP) FIXED;                                           00724600
      IF (CSECT_FLAGS(J)&"80") = 0 THEN RETURN FALSE;                           00724700
      ADDRESS_TEMP = CSECT_ADDR(J)&"FFFFFF";                                    00724800
      IF (ADDRESS_TEMP>=MAP_ADDR1)&(ADDRESS_TEMP<=MAP_ADDR2) THEN               00724900
         RETURN TRUE;                                                           00725000
      ELSE RETURN FALSE;                                                        00725100
   END CSECT_OK;                                                                00725200
                                                                                00725300
      #OVERLAPS,#GAPS,#PSEUDO_GAPS = 0;                                         00725400
      OLD_ADDR = -1;                                                            00725500
      LAST_MAP_ADDR = 0;                                                        00725600
      GAP_SIZE = 0;                                                             00725700
      CSECT_CNT = 0;                                                            00725800
      CALL EMIT_HDG(MAP_HDR_STRING);                                            00725900
      TS = '';                                                                  00726000
      DO I = 1 TO #CSECTS;                                                      00726100
         J = CSECT_SORTX(I);                                                    00726200
         IF CSECT_OK(J) THEN DO;                                                00726300
            CSECT_NAME = STRING("07000000" + ADDR(CSECT_CHAR(SHL(J,1))));       00726400
            ADDR1 = CSECT_ADDR(J)&"FFFFFF";                                     00726500
            TS = TS||CSECT_NAME||X1||HEX6(ADDR1)||X3;                           00726600
            IF LENGTH(TS) > 115 THEN DO;                                        00726700
               OUTPUT = TS;                                                     00726800
               TS = '';                                                         00726900
            END;                                                                00727000
         END;                                                                   00727100
      END;                                                                      00727200
      IF TS ~= '' THEN OUTPUT = TS;                                             00727300
      OUTPUT(1) = ONE;                                                          00727400
      DO I = 1 TO #CSECTS;                                                      00727500
         J = CSECT_SORT(I);                                                     00727600
         IF CSECT_OK(J) THEN DO;                                                00727700
            CUR_CSECT_NDX = J;                                                  00727800
            NEW_CSECT = TRUE;                                                   00727900
            CSECT_CNT = CSECT_CNT + 1;                                          00728000
            TEMP2 = CSECT_LENGTH(J)&"FFFFFF";                                   00728100
            IF TEMP2 = 0 THEN GO TO NEXT_ONE;                                   00728200
            HEX_SIZE = HEX6(TEMP2);                                             00728300
            SIZE_STRING = ' ****   '||HEX_SIZE||LPAREN||LPAD(TEMP2,5)||RPAREN   00728400
               ||X2;                                                            00728500
            SIZE_STRING = PAD(SIZE_STRING,23);                                  00728600
            BASE_ADDR = CSECT_ADDR(J)&"FFFFFF";                                 00728700
            IF OLD_ADDR > 0 THEN DO;                                            00728800
               IF (BASE_ADDR - OLD_ADDR) > MIN_GAP THEN DO;                     00728900
                  #GAPS = #GAPS + 1;                                            00729000
                  ADDR1 = OLD_ADDR + 1;                                         00729100
                  ADDR2 = BASE_ADDR - 1;                                        00729200
                  #PSEUDO_GAPS = #PSEUDO_GAPS + 1;                              00729300
                  IF #PSEUDO_GAPS <= MAX_#GAPS THEN DO;                         00729400
                     GAP_ADDR1(#PSEUDO_GAPS) = ADDR1;                           00729500
                     GAP_ADDR2(#PSEUDO_GAPS) = ADDR2;                           00729600
                  END;                                                          00729700
                  GAP_SIZE = GAP_SIZE + ADDR2 - ADDR1 + 1;                      00729800
                  TS = '';                                                      00729900
                  IF #GAPS > 1 THEN DO;                                         00730000
                     TS(1) = HEX6(LAST_GAP_ADDR);                               00730100
                     TS = 'LAST GAP IS AT ADDR '||TS(1);                        00730200
                  END;                                                          00730300
                  LAST_GAP_ADDR = ADDR1;                                        00730400
                  CALL SET_STRINGS;                                             00730500
                  OUTPUT = S1||S2||'             INTER_CSECT GAP # '||          00730600
                     #GAPS||'  ('||(ADDR2 - ADDR1 + 1)||' HW)  '||TS;           00730700
               END;                                                             00730800
               ELSE IF (BASE_ADDR <= OLD_ADDR)&(TEMP2>0) THEN DO;               00730900
                  #OVERLAPS = #OVERLAPS + 1;                                    00731000
                  TS = '';                                                      00731100
                  IF #OVERLAPS > 1 THEN DO;                                     00731200
                     TS(1) = HEX6(LAST_OVERLAP_ADDR);                           00731300
                     TS = ' -- LAST OVERLAP IS AT ADDR '||TS(1);                00731400
                  END;                                                          00731500
                  LAST_OVERLAP_ADDR = BASE_ADDR;                                00731600
                  OUTPUT = '*** CSECT OVERLAP # '||#OVERLAPS||TS;               00731700
               END;                                                             00731800
            END;                                                                00731900
            ELSE IF OLD_ADDR = -1 THEN DO;                                      00732000
               IF (BASE_ADDR - 1) >= MIN_GAP THEN DO;                           00732100
                  #PSEUDO_GAPS = #PSEUDO_GAPS + 1;                              00732200
                  GAP_ADDR1(#PSEUDO_GAPS) = 0;                                  00732300
                  GAP_ADDR2(#PSEUDO_GAPS) = BASE_ADDR - 1;                      00732400
               END;                                                             00732500
            END;                                                                00732600
            ADDR1 = BASE_ADDR;                                                  00732700
            ADDR2,OLD_ADDR = ADDR1 + TEMP2 - 1;                                 00732800
            CSECT_TYPE = SHR(CSECT_ADDR(J),24)&"FF";                            00732900
            CSECT_NAME = STRING("07000000" + ADDR(CSECT_CHAR(SHL(J,1))));       00733000
            CSECT_COUNT(CSECT_TYPE) = CSECT_COUNT(CSECT_TYPE) + 1;              00733100
            CSECT_TOTAL_SIZE(CSECT_TYPE) =                                      00733200
               CSECT_TOTAL_SIZE(CSECT_TYPE) + TEMP2;                            00733300
            CALL SET_STRINGS;                                                   00733400
            IF (CSECT_TYPE=0)|(CSECT_TYPE>13) THEN DO;                          00733500
               TYPE = 0;                                                        00733600
               DIS_TEMP = 0;                                                    00733700
               IF (CSECT_TYPE > 13)&(CSECT_TYPE < 17) THEN DO;                  00733800
                  DIS_TEMP = 1;                                                 00733900
                  DO CASE (CSECT_TYPE - 14);                                    00734000
                     DO;   /* #Q */                                             00734100
                        TS = '   Z C O N';                                      00734200
                        TYPE = 19;                                              00734300
                        SYM_MULT = 1;                                           00734400
                     END;                                                       00734500
                     DO;    /* #L */                                            00734600
                        TS = '   D A T A';                                      00734700
                     END;                                                       00734800
                     DO;    /* CODE */                                          00734900
                        TS = '   C O D E';                                      00735000
                     END;                                                       00735100
                  END;                                                          00735200
                  TS = 'H A L   L I B R A R Y'||TS;                             00735300
               END;                                                             00735400
               ELSE IF CSECT_TYPE = 0 THEN TS = 'N O N H A L';                  00735500
               ELSE DO CASE (CSECT_TYPE - 17);                                  00735600
                  DO;     /* BCE CSECT */                                       00735700
                     TS = '   B C E';                                           00735800
                  END;                                                          00735900
                  DO;     /* MSC CSECT */                                       00736000
                     TS = '   M S C';                                           00736100
                  END;                                                          00736200
                  DO;     /* PATCH CSECT */                                     00736300
                     TS = '   P A T C H';                                       00736400
                  END;                                                          00736500
               END;                                                             00736600
               MAP_SPACE;                                                       00736700
               OUTPUT = S1||S2||X2||CSECT_NAME||SIZE_STRING||TS;                00736800
               MAP_SPACE;                                                       00736900
               IF (CSECT_FLAGS(J)&"20")~=0 THEN GO TO NEXT_ONE;                 00737000
               IF ~FC_FLAG THEN DO;                                             00737100
                  GO TO NEXT_ONE;                                               00737200
               END;                                                             00737300
               IF TYPE ~= 0 THEN DO;                                            00737400
               END;                                                             00737500
               ELSE IF MAP_LEVEL > 2 THEN DO;                                   00737600
                  OLD_SYM_ADDR = BASE_ADDR;                                     00737700
                  IF CSECT_APTR1(J) ~= 0 THEN DO;                               00737800
                     LINK = CSECT_APTR1(J);                                     00737900
                     DO WHILE LINK ~= 0;                                        00738000
                        RESV_LINK = LINK;                                       00738100
                        CALL VMEM_LOCATE_PTR(1,LINK,0);                         00738200
                        COREWORD(ADDR(NODE_F)) = VMEM_LOC_ADDR;                 00738300
                        LINK = NODE_F(1);                                       00738400
                        COREWORD(ADDR(NODE_H)) = VMEM_LOC_ADDR;                 00738500
                        SYM_ADDR = NODE_F(4)&"FFFFFF";                          00738600
                        SYM_ORG = SHR(NODE_F(4),24)&"FF";                       00738700
                        ADDR1,ADDR2 = BASE_ADDR + SYM_ADDR;                     00738800
                        OLD_SYM_ADDR = ADDR1;                                   00738900
                        TS(1) = STRING("07000000" + ADDR(NODE_F(2)));           00739000
                        TS(1) = TS(1)||X1;                                      00739100
                        TS(2) = X24;                                            00739200
                        TYPE = 0;                                               00739300
                        IF (SYM_ORG & "80") = 0 THEN DO;                        00739400
                           NDATA_TYPE = SHR(SYM_ORG & "70",4);                  00739500
                           DO CASE NDATA_TYPE;                                  00739600
                              DO;     /* SPACE */                               00739700
                              END;                                              00739800
                              DO;     /* CSECT */                               00739900
                              END;                                              00740000
                              DO;     /* DSECT */                               00740100
                              END;                                              00740200
                              DO;     /* COMMON */                              00740300
                              END;                                              00740400
                              DO;     /* INSTRUCTION */                         00740500
                                 TS(1) = TS(1)||'EQU    *';                     00740600
                              END;                                              00740700
                              DO;     /* CCW */                                 00740800
                                 TS(1) = TS(1)||'CCW';                          00740900
                              END;                                              00741000
                              ;;                                                00741100
                           END;                                                 00741200
                        END;                                                    00741300
                        ELSE DO;                                                00741400
                           SYM_MULT = NODE_F(5)&"FFFFFF";                       00741500
                           SYM_DATA_DEX = SHR(NODE_F(5),24)&"FF";               00741600
                           SYM_DATA_LEN = NODE_H(12);                           00741700
                           SYM_SCAL = NODE_H(13);                               00741800
                           IF SYM_MULT = 0 THEN TS(1)=TS(1)||'DS     ';         00741900
                           ELSE TS(1) = TS(1)||'DC     ';                       00742000
                           IF SYM_MULT = 0 THEN TS(1) = TS(1)||ZEROCHAR;        00742100
                           ELSE IF SYM_MULT > 1 THEN TS(1) = TS(1)||SYM_MULT;   00742200
                           IF SYM_MULT > 0 THEN DO;                             00742300
                              ADDR2 = ADDR1 + SYM_MULT*SYM_DATA_LEN - 1;        00742400
                              OLD_SYM_ADDR = ADDR2 + 1;                         00742500
                           END;                                                 00742600
                           DO CASE SYM_DATA_DEX;                                00742700
                              DO;     /* CHARACTER */                           00742800
                                 TS(1) = TS(1)||CLCHAR||SYM_DATA_LEN;           00742900
                                 TYPE = 7;                                      00743000
                              END;                                              00743100
                              DO;     /* HEXADECIMAL */                         00743200
                                 TS(1) = TS(1)||XLCHAR||SYM_DATA_LEN;           00743300
                              END;                                              00743400
                              DO;     /* BINARY */                              00743500
                                 TS(1) = TS(1)||BLCHAR||SYM_DATA_LEN;           00743600
                              END;                                              00743700
                              DO;     /* UNUSED */                              00743800
                              END;                                              00743900
                              DO;     /* FULLWORD */                            00744000
                                 TS(1) = TS(1)||FCHAR;                          00744100
                                 TYPE = 14;                                     00744200
                              END;                                              00744300
                              DO;     /* HALFWORD */                            00744400
                                 TS(1) = TS(1)||HCHAR;                          00744500
                                 TYPE = 6;                                      00744600
                              END;                                              00744700
                              DO;     /* SHORT FLOAT */                         00744800
                                 TS(1) = TS(1)||ECHAR;                          00744900
                                 TYPE = 5;                                      00745000
                              END;                                              00745100
                              DO;     /* LONG FLOAT */                          00745200
                                 TS(1) = TS(1)||DCHAR;                          00745300
                                 TYPE = 13;                                     00745400
                              END;                                              00745500
                              DO;     /* LONG ADCON */                          00745600
                                 IF FC_FLAG THEN TS(1) = TS(1)||ZCHAR;          00745700
                                 ELSE TS(1) = TS(1)||ACHAR;                     00745800
                                 TYPE = 19;                                     00745900
                              END;                                              00746000
                              DO;     /* SHORT ADCON */                         00746100
                                 TS(1) = TS(1)||YCHAR;                          00746200
                                 TYPE = 18;                                     00746300
                              END;                                              00746400
                           END;                                                 00746500
                           IF SYM_SCAL ~= 0 THEN DO;                            00746600
                              TS(1) = PAD(TS(1),20);                            00746700
                              TS(1) = TS(1)||'SCALE FACTOR = '||SYM_SCAL;       00746800
                           END;                                                 00746900
                        END;                                                    00747000
                        CALL SUB3;                                              00747100
                     END;                                                       00747200
                  END;                                                          00747300
               END;                                                             00747400
            END;                                                                00747500
            ELSE DO;                                                            00747600
               GOT_UNIT = CSECT_ID(J);                                          00747700
               IF (CSECT_TYPE=6)|(CSECT_TYPE=7)|(CSECT_TYPE=11) THEN DO;        00747800
                  CALL SDF_SELECT(GOT_UNIT);                                    00747900
                  TS = 'DATA                                            UNIT: ';00748000
                  MAP_SPACE;                                                    00748100
                  OUTPUT = S1||S2||X2||CSECT_NAME||SIZE_STRING||TS||            00748200
                     UNIT_NAMES(GOT_UNIT);                                      00748300
                  MAP_SPACE;                                                    00748400
                  IF (CSECT_FLAGS(J)&"20")~=0 THEN GO TO NEXT_ONE;              00748500
                  IF (UNIT_FLAGS(GOT_UNIT)&"0010")~=0 THEN GO TO NEXT_ONE;      00748600
                  IF MAP_LEVEL > 1 THEN DO;                                     00748700
                     COREWORD(ADDR(NODE_H)) = ADDRESS;                          00748800
                     IF CSECT_TYPE = 11 THEN LINK = NODE_H(17);                 00748900
                     ELSE LINK = NODE_H(16);                                    00749000
                     DO WHILE LINK ~= 0;                                        00749100
                        VALID_FLAG = TRUE;                                      00749200
                        CURRENT_BASE = BASE_ADDR;                               00749300
                        CALL SUB1;                                              00749400
                        LINK = NODE_H(-1);                                      00749500
                        IF (FLAG&"00000200") ~= 0 THEN DO;                      00749600
                           ADDR1 = NODE_H(10) + CURRENT_BASE;                   00749700
                           ADDR2 = ADDR1 + NODE_H(11) - 1;                      00749800
                           TS(1) = '--- LOCAL BLOCK DATA (BLOCK '||             00749900
                              SYMBOL_STRING||') ---';                           00750000
                        END;                                                    00750100
                        ELSE IF (CLASS=2)&(TYPE=8) THEN DO;                     00750200
                           VALID_FLAG = FALSE;                                  00750300
                           ADDR1,ADDR2 = (NODE_F(3)&"FFFFFF") +                 00750400
                              CURRENT_BASE;                                     00750500
                           G_TEMP = GLOBAL_SYMB(NODE_H(9));                     00750600
                           TS(1) = '### EQUATE LABEL '||                        00750700
                              SYMBOL_STRING;                                    00750800
                           IF G_TEMP ~= 0 THEN TS(1) = TS(1)||' (SEE SYMB: '||  00750900
                              G_TEMP||') ###';                                  00751000
                        END;                                                    00751100
                        ELSE CALL SUB2;                                         00751200
                        CALL SUB3;                                              00751300
                        IF (CLASS=1)&(TYPE=16)&                                 00751400
                           ((FLAG&"04000000")=0) THEN DO;                       00751500
                           CURRENT_BASE=BASE_ADDR + (NODE_F(3)&"FFFFFF");       00751600
                           SAVE_LINK = LINK;                                    00751700
                           GOT_COPIES = NODE_H(SHR(NODE_B(4),1)+1);             00751800
                           GOT_COPY_SIZE=(NODE_F(5)&"FFFFFF")/GOT_COPIES;       00751900
                           TEMP2 = NODE_H(9);                                   00752000
                           DO K = 1 TO GOT_COPIES;                              00752100
                              ADDR1 = CURRENT_BASE;                             00752200
                              ADDR2 = ADDR1 + GOT_COPY_SIZE - 1;                00752300
                              CALL SET_STRINGS;                                 00752400
                              IF GOT_COPIES > 1 THEN                            00752500
                                 OUTPUT = S1||S2||'     +++ COPY '              00752600
                                 ||K||' OF '||GOT_COPIES||' +++';               00752700
                              LINK = TEMP2;                                     00752800
                              STACK_INX = 0;                                    00752900
                              IF MFORMAT > 0 THEN DO FOREVER;                   00753000
                                 CALL SUB1;                                     00753100
                                 NEW_LINK = NODE_H(-1);                         00753200
                                 IF (TYPE=16)&((FLAG&"04000000")=0) THEN DO;    00753300
                                    IF (NODE_H(SHR(NODE_B(5),1)+1)=0)           00753400
                                       THEN DO;                                 00753500
                                       TPL_STACK1(STACK_INX) = NEW_LINK;        00753600
                                       TPL_STACK2(STACK_INX) =                  00753700
                                          CURRENT_BASE;                         00753800
                                       CALL PUSH_STACK;                         00753900
                                       CURRENT_BASE = CURRENT_BASE +            00754000
                                          (NODE_F(3)&"FFFFFF");                 00754100
                                       NEW_LINK = NODE_H(9);                    00754200
                                    END;                                        00754300
                                 END;                                           00754400
                                 ELSE DO;                                       00754500
                                    CALL SUB2;                                  00754600
                                    CALL SUB3;                                  00754700
                                 END;                                           00754800
                                 DO WHILE NEW_LINK = 0;                         00754900
                                    IF STACK_INX = 0 THEN GO TO COMPLETED;      00755000
                                    STACK_INX = STACK_INX - 1;                  00755100
                                    CURRENT_BASE = TPL_STACK2(STACK_INX);       00755200
                                    NEW_LINK = TPL_STACK1(STACK_INX);           00755300
                                 END;                                           00755400
                                 LINK = NEW_LINK;                               00755500
                              END;                                              00755600
COMPLETED:                                                                      00755700
                              CURRENT_BASE = CURRENT_BASE + GOT_COPY_SIZE;      00755800
                           END;                                                 00755900
                           IF MFORMAT > 0 THEN                                  00756000
                            OUTPUT='                  +++ END OF STRUCTURE +++';00756100
                           LINK = SAVE_LINK;                                    00756200
                        END;                                                    00756300
                     END;                                                       00756400
                     IF (CSECT_TYPE=6)&(FC_FLAG=TRUE) THEN DO;                  00756500
                        ADDR1 = ADDR2 + 1;                                      00756600
                        IF OLD_ADDR > ADDR1 THEN DO;                            00756700
                           ADDR2 = OLD_ADDR;                                    00756800
                           CALL SET_STRINGS;                                    00756900
                           OUTPUT =S1||S2||X2||CSECT_NAME||PLUS||HEX4(ADDR1     00757000
                              - BASE_ADDR)||'   ??? ADCONS,LITERALS,ETC. ???';  00757100
                        END;                                                    00757200
                     END;                                                       00757300
                  END;                                                          00757400
               END;                                                             00757500
               ELSE IF CSECT_TYPE < 5 THEN DO;                                  00757600
                  IF SELECTED_UNIT ~= GOT_UNIT THEN                             00757700
                     CALL SDF_SELECT(GOT_UNIT);                                 00757800
                  DO K = 1 TO #PROCS;                                           00757900
                     BLKNO = K;                                                 00758000
                     CALL MONITOR(22,15);                                       00758100
                     SYMBOL_STRING = STRING("07000000" + ADDRESS);              00758200
                     IF CSECT_NAME = SYMBOL_STRING THEN GO TO BLOCK_FOUND;      00758300
                  END;                                                          00758400
                  GO TO NEXT_ONE;                                               00758500
BLOCK_FOUND:                                                                    00758600
                  SYMBOL_STRING = PAD(BLOCK_NAME(K),32);                        00758700
                  COREWORD(ADDR(NODE_H)) = ADDRESS;                             00758800
                  COREWORD(ADDR(NODE_B)) = ADDRESS;                             00758900
                  CLASS = NODE_B(30);                                           00759000
                  TS = SUBSTR(PROC_TYPES(CLASS),2)||SYMBOL_STRING||             00759100
                     '      UNIT: '||UNIT_NAMES(GOT_UNIT);                      00759200
                  MAP_SPACE;                                                    00759300
                  OUTPUT = S1||S2||X2||CSECT_NAME||SIZE_STRING||TS;             00759400
                  MAP_SPACE;                                                    00759500
                  IF (CSECT_FLAGS(J)&"20")~=0 THEN GO TO NEXT_ONE;              00759600
                  IF (UNIT_FLAGS(GOT_UNIT)&"0010")~=0 THEN GO TO NEXT_ONE;      00759700
                  IF (MAP_LEVEL > 2)&(ADDR_FLAG = TRUE) THEN DO;                00759800
                     KLIM1 = NODE_H(18);                                        00759900
                     KLIM2 = NODE_H(19);                                        00760000
                     NEST_LEVEL = 0;                                            00760100
                     BASE_BLOCK = BLKNO;                                        00760200
                     DO K = KLIM1 TO KLIM2;                                     00760300
                        STMTNO,SAVE_STMTX,SAVE_STMT = K;                        00760400
                        CALL MONITOR(22,17);                                    00760500
                        COREWORD(ADDR(NODE_H)) = ADDRESS;                       00760600
                        COREWORD(ADDR(NODE_F)) = ADDRESS;                       00760700
                        IF SRN_FLAG THEN DO;                                    00760800
                           SRN_STRING = STRING("05000000" + ADDRESS);           00760900
                           INCL_STRING = LPAD(NODE_H(3),5);                     00761000
                           TS(1) = X2||SRN_STRING||X1||INCL_STRING;             00761100
                           PTR = NODE_F(2);                                     00761200
                        END;                                                    00761300
                        ELSE DO;                                                00761400
                           TS(1) = X14;                                         00761500
                           PTR = NODE_F(0);                                     00761600
                        END;                                                    00761700
                        IF PTR ~= 0 THEN DO;                                    00761800
                           CALL SDF_PTR_LOCATE(PTR,RESV);                       00761900
                           COREWORD(ADDR(NODE_B)) = ADDRESS;                    00762000
                           COREWORD(ADDR(NODE_H)) = ADDRESS;                    00762100
                           SBLK = NODE_H(0);                                    00762200
                           IF SBLK ~= BASE_BLOCK THEN DO;                       00762300
                              BLKNO = SBLK;                                     00762400
                              CALL MONITOR(22,8);                               00762500
                              COREWORD(ADDR(NODE_H)) = ADDRESS;                 00762600
                              K = NODE_H(19);                                   00762700
                              GO TO NEXT_STMT;                                  00762800
                           END;                                                 00762900
                           SFLAG = NODE_B(2);                                   00763000
                           STYPE = NODE_B(3);                                   00763100
                           IF (STYPE>16)&(STYPE<21) THEN DO;                    00763200
                              NEST_LEVEL = NEST_LEVEL + 1;                      00763300
                              NEST_STMT(NEST_LEVEL) = K;                        00763400
                              NEST_STYPE(NEST_LEVEL) = STYPE;                   00763500
                           END;                                                 00763600
                           ELSE IF STYPE=8 THEN DO;                             00763700
                              SAVE_STMT = NEST_STMT(NEST_LEVEL);                00763800
                              OLD_STYPE = NEST_STYPE(NEST_LEVEL);               00763900
                              NEST_LEVEL = NEST_LEVEL - 1;                      00764000
                           END;                                                 00764100
                           #LABELS = NODE_B(4);                                 00764200
                           #LHS = NODE_B(5);                                    00764300
                           L = 6 + SHL(#LABELS + #LHS,1);                       00764400
                           ADDR1 = NODE_B(L);                                   00764500
                           ADDR1 = SHL(ADDR1,8) + NODE_B(L + 1);                00764600
                           ADDR1 = SHL(ADDR1,8) + NODE_B(L + 2) +               00764700
                              BASE_ADDR;                                        00764800
                           ADDR2 = NODE_B(L + 3);                               00764900
                           ADDR2 = SHL(ADDR2,8) + NODE_B(L + 4);                00765000
                           ADDR2 = SHL(ADDR2,8) + NODE_B(L + 5) +               00765100
                              BASE_ADDR;                                        00765200
                           SAVE_ADDR1 = ADDR1;                                  00765300
                           SAVE_ADDR2 = ADDR2;                                  00765400
                           CALL SET_STRINGS;                                    00765500
                           TS(3) = X2||STMT_FLAGS(SFLAG&3)||                    00765600
                              STMT_TYPES(STYPE);                                00765700
                           TS(3) = PAD(TS(3),32);                               00765800
                           TS(2) = LPAD(K,5);                                   00765900
                           TS = S1||S2||X2||CSECT_NAME||PLUS||HEX4(ADDR1-       00766000
                              BASE_ADDR)||X1||TS(2)||TS(3)||X2||TS(1);          00766100
                           LEN = LENGTH(TS);                                    00766200
                           IF #LABELS > 0 THEN DO;                              00766300
                              TS = TS||'    LABEL(S):  ';                       00766400
                              L1 = 3;                                           00766500
                              L2 = L1 + #LABELS - 1;                            00766600
                              DO L = L1 TO L2;                                  00766700
                                 ITEM = NODE_H(L);                              00766800
                                 G_TEMP = GLOBAL_SYMB(ITEM);                    00766900
                                 IF G_TEMP ~= 0 THEN                            00767000
                                    TS(1) = LPAD(G_TEMP,5);                     00767100
                                 ELSE TS(1) = '';                               00767200
                                 TS(2) = SYMBOL_NAME(ITEM);                     00767300
                                 OUTPUT = TS||TS(1)||X2||TS(2);                 00767400
                                 TS = SUBSTR(PRINTLINE,0,LEN+15);               00767500
                              END;                                              00767600
                              TS = SUBSTR(PRINTLINE,0,LEN);                     00767700
                           END;                                                 00767800
                           IF #LHS > 0 THEN DO;                                 00767900
                              TS = TS||'    TARGET(S): ';                       00768000
                              L1 = 3 + #LABELS;                                 00768100
                              L2 = L1 + #LHS - 1;                               00768200
                              DO L = L1 TO L2;                                  00768300
                                 ITEM = NODE_H(L);                              00768400
                                 IF ITEM > 0 THEN DO;                           00768500
                                    IF ITEM <= #SYMBOLS THEN DO;                00768600
                                       G_TEMP = GLOBAL_SYMB(ITEM);              00768700
                                       IF G_TEMP ~= 0 THEN                      00768800
                                          TS(1) = LPAD(G_TEMP,5);               00768900
                                       ELSE TS(1) = '';                         00769000
                                       TS(2) = SYMBOL_NAME(ITEM);               00769100
                                    END;                                        00769200
                                    ELSE DO;                                    00769300
                                       TS(1) = X5;                              00769400
                                       TS(2) = '';                              00769500
                                    END;                                        00769600
                                    OUTPUT = TS||TS(1)||X2||TS(2);              00769700
                                 END;                                           00769800
                                 ELSE DO;                                       00769900
                                    TS(3) = '';                                 00770000
                                    IF GSD_LEVEL > 0 THEN                       00770100
                                       TS(4) = LPAREN;                          00770200
                                    ELSE TS(4) = '';                            00770300
                                    M1 = L + 1;                                 00770400
                                    M2 = L - ITEM;                              00770500
                                    L = M2;                                     00770600
                                    DO M = M1 TO M2;                            00770700
                                       ITEM = NODE_H(M);                        00770800
                                       IF (ITEM > 0)&(ITEM <= #SYMBOLS)         00770900
                                       THEN DO;                                 00771000
                                          IF GSD_LEVEL > 0 THEN                 00771100
                                             TS(4) = TS(4)||GLOBAL_SYMB(ITEM);  00771200
                                          TS(2) = SYMBOL_NAME(ITEM);            00771300
                                       END;                                     00771400
                                       ELSE TS(2) = '';                         00771500
                                       TS(3) = TS(3)||TS(2);                    00771600
                                       IF M < M2 THEN DO;                       00771700
                                          IF GSD_LEVEL > 0 THEN                 00771800
                                             TS(4) = TS(4)||COMMA;              00771900
                                          TS(3) = TS(3)||PERIOD;                00772000
                                       END;                                     00772100
                                       ELSE IF GSD_LEVEL > 0 THEN               00772200
                                          TS(4) = TS(4)||RPAREN;                00772300
                                    END;                                        00772400
                                    TS = TS||TS(4)||X2||TS(3);                  00772500
                                    CALL EMIT_OUTPUT(TS);                       00772600
                                 END;                                           00772700
                                 TS = SUBSTR(PRINTLINE,0,LEN+15);               00772800
                              END;                                              00772900
                           END;                                                 00773000
                           IF (#LABELS+#LHS) = 0 THEN OUTPUT = TS;              00773100
NEXT_STMT:                                                                      00773200
                           CALL SDF_PTR_LOCATE(PTR,RELS);                       00773300
                        END;                                                    00773400
                     END;                                                       00773500
                  END;                                                          00773600
               END;                                                             00773700
               ELSE DO;                                                         00773800
                  TYPE = 0;                                                     00773900
                  DO CASE CSECT_TYPE;                                           00774000
                     ;;;;;                                                      00774100
                     DO;    /* STACK    */                                      00774200
                        TS = 'STACK';                                           00774300
                     END;                                                       00774400
                     ;;                                                         00774500
                     DO;    /* #F(FSIM) */                                      00774600
                        TS = 'FSIM';                                            00774700
                     END;                                                       00774800
                     DO;    /* #T(COST) */                                      00774900
                        TS = 'COST/USE';                                        00775000
                     END;                                                       00775100
                     DO;    /* #Z(ZCON) */                                      00775200
                        TS = 'ZCON';                                            00775300
                        TYPE = 19;                                              00775400
                        SYM_MULT = 1;                                           00775500
                     END;                                                       00775600
                     ;                                                          00775700
                     DO;    /* #E       */                                      00775800
                        TS = 'PDE';                                             00775900
                     END;                                                       00776000
                     DO;    /* #X       */                                      00776100
                        TS = 'EXCLUSIVE';                                       00776200
                     END;                                                       00776300
                     ;;;                                                        00776400
                  END;                                                          00776500
                  TS = PAD(TS,44);                                              00776600
                  MAP_SPACE;                                                    00776700
                  OUTPUT = S1||S2||X2||CSECT_NAME||SIZE_STRING||TS              00776800
                     ||'    UNIT: '||UNIT_NAMES(GOT_UNIT);                      00776900
                  MAP_SPACE;                                                    00777000
                  IF (CSECT_FLAGS(J)&"20")~=0 THEN GO TO NEXT_ONE;              00777100
               END;                                                             00777200
            END;                                                                00777300
         END;                                                                   00777400
NEXT_ONE:                                                                       00777500
      END;                                                                      00777600
      IF TEXT_CELL_PTR ~= 0 THEN DO;                                            00777700
         CALL VMEM_LOCATE_PTR(1,TEXT_CELL_PTR,RELS);                            00777800
         TEXT_CELL_PTR = 0;                                                     00777900
      END;                                                                      00778000
      IF (MAP_ADDR1 = 0)&(MAP_ADDR2="3FFFFF")&(CSECT_CNT>0) THEN DO;            00778100
         OUTPUT(1) = ONE;                                                       00778200
         SPACE_1;                                                               00778300
         OUTPUT = '          M A P   S U M M A R Y';                            00778400
         SPACE_1;                                                               00778500
         OUTPUT = '    CSECT CATEGORY      #      TOTAL SIZE';                  00778600
         SPACE_1;                                                               00778700
         DO K = 0 TO MAX_CSECT_TYPES;                                           00778800
            IF CSECT_COUNT(K) > 0 THEN DO;                                      00778900
               S1 = PAD(CSECT_DESCRIPT(K),17);                                  00779000
               S2 = LPAD(CSECT_COUNT(K),4);                                     00779100
               S3 = LPAD(CSECT_TOTAL_SIZE(K),6);                                00779200
               OUTPUT = X4||S1||S2||X5||S3||MEM_TYPE;                           00779300
            END;                                                                00779400
         END;                                                                   00779500
         DSPACE;                                                                00779600
         WORK(0) = CSECT_TOTAL_SIZE(1) + CSECT_TOTAL_SIZE(2) +                  00779700
            CSECT_TOTAL_SIZE(3) + CSECT_TOTAL_SIZE(4);                          00779800
         WORK(1) = CSECT_TOTAL_SIZE(6) + CSECT_TOTAL_SIZE(7) +                  00779900
            CSECT_TOTAL_SIZE(8) + CSECT_TOTAL_SIZE(9) +                         00780000
            CSECT_TOTAL_SIZE(10) + CSECT_TOTAL_SIZE(11) +                       00780100
            CSECT_TOTAL_SIZE(12) + CSECT_TOTAL_SIZE(13);                        00780200
         WORK(2) = CSECT_TOTAL_SIZE(16);                                        00780300
         WORK(3) = CSECT_TOTAL_SIZE(14) + CSECT_TOTAL_SIZE(15);                 00780400
         WORK(4) = CSECT_TOTAL_SIZE(5);                                         00780500
         WORK(5) = WORK(0) + WORK(1) + WORK(2) + WORK(3) + WORK(4);             00780600
         WORK(6) = CSECT_TOTAL_SIZE(0) + CSECT_TOTAL_SIZE(17) +                 00780700
            CSECT_TOTAL_SIZE(18) + CSECT_TOTAL_SIZE(19);                        00780800
         WORK(7) = WORK(5) + WORK(6);                                           00780900
         IF FC_FLAG THEN DO;                                                    00781000
            TS(1) = ' (INCLUDING #Z,#E,#X)';                                    00781100
            TS(2) = ' (INCLUDING #Q)';                                          00781200
            TS(3) = ' (INCLUDING BCE,MSC & PATCH AREAS)';                       00781300
         END;                                                                   00781400
         ELSE DO;                                                               00781500
            TS(1) = '';                                                         00781600
            TS(2) = '';                                                         00781700
            TS(3) = '';                                                         00781800
         END;                                                                   00781900
         S1 = LPAD(WORK(0),6);                                                  00782000
         S2 = PERCENT(WORK(0),WORK(7));                                         00782100
         OUTPUT = '    TOTAL HAL CODE            '||S1||MEM_TYPE||X4||          00782200
            S2;                                                                 00782300
         S1 = LPAD(WORK(1),6);                                                  00782400
         S2 = PERCENT(WORK(1),WORK(7));                                         00782500
         OUTPUT = '    TOTAL HAL DATA            '||S1||MEM_TYPE||X4||          00782600
            S2||X2||TS(1);                                                      00782700
         S1 = LPAD(WORK(2),6);                                                  00782800
         S2 = PERCENT(WORK(2),WORK(7));                                         00782900
         OUTPUT = '    TOTAL LIBRARY CODE        '||S1||MEM_TYPE||X4||          00783000
            S2;                                                                 00783100
         S1 = LPAD(WORK(3),6);                                                  00783200
         S2 = PERCENT(WORK(3),WORK(7));                                         00783300
         OUTPUT = '    TOTAL LIBRARY DATA        '||S1||MEM_TYPE||X4||          00783400
            S2||X2||TS(2);                                                      00783500
         S1 = LPAD(WORK(4),6);                                                  00783600
         S2 = PERCENT(WORK(4),WORK(7));                                         00783700
         OUTPUT = '    TOTAL STACK SPACE         '||S1||MEM_TYPE||X4||          00783800
            S2;                                                                 00783900
         S1 = LPAD(WORK(5),6);                                                  00784000
         S2 = PERCENT(WORK(5),WORK(7));                                         00784100
         OUTPUT = '          TOTAL HAL           '||S1||MEM_TYPE||X4||          00784200
            S2;                                                                 00784300
         S1 = LPAD(WORK(6),6);                                                  00784400
         S2 = PERCENT(WORK(6),WORK(7));                                         00784500
         OUTPUT = '    TOTAL NON-HAL CODE/DATA   '||S1||MEM_TYPE||X4||          00784600
            S2||X2||TS(3);                                                      00784700
         S1 = LPAD(WORK(7),6);                                                  00784800
         OUTPUT = '          GRAND TOTAL         '||S1||MEM_TYPE;               00784900
         IF LAST_MAP_ADDR ~= 0 THEN DO;                                         00785000
            SPACE_1;                                                            00785100
            TS = HEX6(LAST_MAP_ADDR);                                           00785200
            OUTPUT='ONE OR MORE MAP ERRORS WERE DETECTED -- LAST WAS AT ADDR '||00785300
               TS;                                                              00785400
         END;                                                                   00785500
         IF #GAPS > 0 THEN DO;                                                  00785600
            SPACE_1;                                                            00785700
            OUTPUT = #GAPS||' INTER-CSECT GAPS FOR A TOTAL SIZE OF '||          00785800
            GAP_SIZE||MEM_TYPE;                                                 00785900
            TS = HEX6(LAST_GAP_ADDR);                                           00786000
            OUTPUT = 'LAST GAP OCCURRED AT ADDRESS '||TS;                       00786100
         END;                                                                   00786200
         IF #OVERLAPS > 0 THEN DO;                                              00786300
            SPACE_1;                                                            00786400
            OUTPUT = #OVERLAPS||' CSECT OVERLAPS';                              00786500
            TS = HEX6(LAST_OVERLAP_ADDR);                                       00786600
            OUTPUT = 'LAST OVERLAP OCCURRED AT ADDRESS '||TS;                   00786700
         END;                                                                   00786800
         DO K = 0 TO MAX_CSECT_TYPES;                                           00786900
            CSECT_COUNT(K) = 0;                                                 00787000
            CSECT_TOTAL_SIZE(K) = 0;                                            00787100
         END;                                                                   00787200
      END;                                                                      00787300
      IF GLOBAL_GAP_FLAG THEN DO;                                               00787400
         #PSEUDO_GAPS = #PSEUDO_GAPS + 1;                                       00787500
         GAP_ADDR1(#PSEUDO_GAPS) = OLD_ADDR + 1;                                00787600
         GAP_ADDR2(#PSEUDO_GAPS) = "1FFFF";                                     00787700
         IF #GLOBAL_GAPS = 0 THEN DO;                                           00787800
            #GLOBAL_GAPS,GLOBAL_GAP_CNT = #PSEUDO_GAPS;                         00787900
            DO I = 1 TO #PSEUDO_GAPS;                                           00788000
               GLOBAL_GAP_ADDR1(I) = GAP_ADDR1(I);                              00788100
               GLOBAL_GAP_ADDR2(I) = GAP_ADDR2(I);                              00788200
            END;                                                                00788300
         END;                                                                   00788400
         ELSE DO;                                                               00788500
            I = 1;                                                              00788600
            DO WHILE I <= #GLOBAL_GAPS;                                         00788700
               IF GLOBAL_GAP_ADDR2(I) ~= 0 THEN DO;                             00788800
                  SAVE_GAP_FLAG = FALSE;                                        00788900
                  DO J = 1 TO #PSEUDO_GAPS;                                     00789000
                     IF (GAP_ADDR1(J)>=GLOBAL_GAP_ADDR1(I))&                    00789100
                        (GAP_ADDR1(J)<GLOBAL_GAP_ADDR2(I)) THEN DO;             00789200
                        GLOBAL_GAP_ADDR1(I) = GAP_ADDR1(J);                     00789300
                        SAVE_GAP_FLAG = TRUE;                                   00789400
                     END;                                                       00789500
                     IF (GAP_ADDR2(J)>GLOBAL_GAP_ADDR1(I))&                     00789600
                        (GAP_ADDR2(J)<=GLOBAL_GAP_ADDR2(I)) THEN DO;            00789700
                        GLOBAL_GAP_ADDR2(I) = GAP_ADDR2(J);                     00789800
                        SAVE_GAP_FLAG = TRUE;                                   00789900
                     END;                                                       00790000
                     IF (GAP_ADDR1(J)<GLOBAL_GAP_ADDR1(I))&                     00790100
                        (GAP_ADDR2(J)>GLOBAL_GAP_ADDR2(I)) THEN                 00790200
                        SAVE_GAP_FLAG = TRUE;                                   00790300
                  END;                                                          00790400
                  IF (SAVE_GAP_FLAG=FALSE)|((GLOBAL_GAP_ADDR2(I) -              00790500
                     GLOBAL_GAP_ADDR1(I) + 1) < MIN_GAP) THEN DO;               00790600
                     GLOBAL_GAP_CNT = GLOBAL_GAP_CNT - 1;                       00790700
                     GLOBAL_GAP_ADDR1(I) = 0;                                   00790800
                     GLOBAL_GAP_ADDR2(I) = 0;                                   00790900
                  END;                                                          00791000
               END;                                                             00791100
               I = I + 1;                                                       00791200
            END;                                                                00791300
         END;                                                                   00791400
      END;                                                                      00791500
   END MAP_GENERATION;                                                          00791600
                                                                                00791700
SET_CONFIG:                                                                     00791800
   PROCEDURE (P_PTR,P_NO);                                                      00791900
      DECLARE (P_PTR,P_NO,P_TEMP,I,J,K,L,P_ADDR1,P_ADDR2) FIXED,                00792000
               (Q_ADDR1,Q_ADDR2,DEX) FIXED, FIRST BIT(1);                       00792100
                                                                                00792200
SET_PHASE:                                                                      00792300
   PROCEDURE (P_NO);                                                            00792400
      DECLARE (P_NO,I,P_TEMP) FIXED;                                            00792500
      DO I = 1 TO #CSECTS;                                                      00792600
         P_TEMP = SHR(CSECT_LENGTH(I),24)&"FF";                                 00792700
         IF P_TEMP = P_NO THEN DO;                                              00792800
            CSECT_FLAGS(I) = CSECT_FLAGS(I) | "80";                             00792900
         END;                                                                   00793000
      END;                                                                      00793100
   END SET_PHASE;                                                               00793200
                                                                                00793300
      #CONFIG_CSECTS = 0;                                                       00793400
      DO I = 1 TO #CSECTS;                                                      00793500
         CSECT_FLAGS(I) = CSECT_FLAGS(I)&"7F";                                  00793600
      END;                                                                      00793700
      IF P_PTR = 0 THEN CALL SET_PHASE(P_NO);                                   00793800
      ELSE DO;                                                                  00793900
         FIRST = TRUE;                                                          00794000
         CALL ZERO_256(ADDR(PHASE_TAB),256);                                    00794100
         DO I = 1 TO TPHASES(P_PTR);                                            00794200
            PHASE_TAB(TPHASES(P_PTR+I)) = 1;                                    00794300
         END;                                                                   00794400
         DO I = (256-MAX_PHASE) TO 255;                                         00794500
            P_TEMP = 256 - I;                                                   00794600
            IF PHASE_TAB(P_TEMP) ~= 0 THEN DO;                                  00794700
               IF FIRST THEN DO;                                                00794800
                  FIRST = FALSE;                                                00794900
                  CALL SET_PHASE(P_TEMP);                                       00795000
               END;                                                             00795100
               ELSE DO;                                                         00795200
                  DEX = 1;                                                      00795300
                  DO J = 1 TO #CSECTS;                                          00795400
                     K = CSECT_SORT(J);                                         00795500
                     IF (SHR(CSECT_LENGTH(K),24)&"FF") = P_TEMP THEN DO;        00795600
                        P_ADDR1 = CSECT_ADDR(K)&"FFFFFF";                       00795700
                        P_ADDR2 = P_ADDR1 - 1 + (CSECT_LENGTH(K)&"FFFFFF");     00795800
                        DO WHILE DEX <= #CSECTS;                                00795900
                           L = CSECT_SORT(DEX);                                 00796000
                           Q_ADDR1 = CSECT_ADDR(L)&"FFFFFF";                    00796100
                           IF Q_ADDR1 > P_ADDR2 THEN GO TO SET_IT;              00796200
                           Q_ADDR2 = Q_ADDR1 - 1 + (CSECT_LENGTH(L)&"FFFFFF");  00796300
                           IF Q_ADDR2 >= P_ADDR1 THEN                           00796400
                              IF (CSECT_FLAGS(L)&"80")~=0 THEN                  00796500
                                 GO TO NO_GOOD;                                 00796600
                           DEX = DEX + 1;                                       00796700
                        END;                                                    00796800
SET_IT:                                                                         00796900
                        CSECT_FLAGS(K) = CSECT_FLAGS(K)|"80";                   00797000
NO_GOOD:                                                                        00797100
                     END;                                                       00797200
                  END;                                                          00797300
               END;                                                             00797400
            END;                                                                00797500
         END;                                                                   00797600
      END;                                                                      00797700
   END SET_CONFIG;                                                              00797800
                                                                                00797900
   /* GENERATE AS MANY MAPS AS REQUESTED */                                     00798000
                                                                                00798100
      MAP_HDR = 'M E M O R Y   M A P  ---  ';                                   00798200
      DO MAP_DEX = 1 TO #MAP_CMDS;                                              00798300
         MAP_TYPE = MAP_CMD_TYPE(MAP_DEX);                                      00798400
         MAP_LEVEL = MAP_CMD_LEVEL(MAP_DEX);                                    00798500
         MFORMAT = MAP_CMD_FMT(MAP_DEX);                                        00798600
         MAP_ADDR1 = MAP_CMD_ADDR1(MAP_DEX);                                    00798700
         MAP_ADDR2 = MAP_CMD_ADDR2(MAP_DEX);                                    00798800
         DO CASE MAP_TYPE;                                                      00798900
            ;                                                                   00799000
            DO;     /* ALL CONFIGURATIONS */                                    00799100
               #GLOBAL_GAPS = 0;                                                00799200
               GLOBAL_GAP_CNT = 0;                                              00799300
               IF (MAP_ADDR1=0)&(MAP_ADDR2="3FFFFF")&(#CONFIGS>1)&              00799400
                  (FC_FLAG=TRUE) THEN GLOBAL_GAP_FLAG = TRUE;                   00799500
               DO QQ = 1 TO #CONFIGS;                                           00799600
                  MAP_HDR_STRING = MAP_HDR||CONFIG_NAME(QQ);                    00799700
                  TPHASE_PTR = CONFIG_PHASE_PTR(QQ);                            00799800
                  CALL SET_CONFIG(TPHASE_PTR,0);                                00799900
                  CALL MAP_GENERATION;                                          00800000
               END;                                                             00800100
               IF GLOBAL_GAP_FLAG THEN DO;                                      00800200
                  IF GLOBAL_GAP_ADDR2(#GLOBAL_GAPS) -                           00800300
                     GLOBAL_GAP_ADDR1(#GLOBAL_GAPS) < MIN_GAP THEN DO;          00800400
                     #GLOBAL_GAPS = #GLOBAL_GAPS - 1;                           00800500
                     GLOBAL_GAP_CNT = GLOBAL_GAP_CNT - 1;                       00800600
                  END;                                                          00800700
                  IF GLOBAL_GAP_CNT > 0 THEN DO;                                00800800
                     TS = 'G L O B A L   I N T E R - C S E C T   G A P   S U M M00800900
A R Y';                                                                         00801000
                     CALL EMIT_HDG(TS);                                         00801100
                     SPACE_1;                                                   00801200
                     J = 0;                                                     00801300
                     DO I = 1 TO #GLOBAL_GAPS;                                  00801400
                        IF GLOBAL_GAP_ADDR2(I) > 0 THEN DO;                     00801500
                           J = J + 1;                                           00801600
                           ADDR1 = GLOBAL_GAP_ADDR1(I);                         00801700
                           ADDR2 = GLOBAL_GAP_ADDR2(I);                         00801800
                           CALL SET_STRINGS;                                    00801900
                           CSECT_NAME = PAD('GAP '||J,8);                       00802000
                           TEMP2 = ADDR2 - ADDR1 + 1;                           00802100
                           HEX_SIZE = HEX6(TEMP2);                              00802200
                           SIZE_STRING = '   ***  '||HEX_SIZE||LPAREN||         00802300
                              LPAD(TEMP2,5)  ||RPAREN;                          00802400
                           OUTPUT = S1||S2||X2||CSECT_NAME||SIZE_STRING;        00802500
                        END;                                                    00802600
                     END;                                                       00802700
                  END;                                                          00802800
               END;                                                             00802900
            END;                                                                00803000
            DO;     /* ALL PHASES */                                            00803100
               IF MAX_PHASE = 1 THEN DO;                                        00803200
                  MAP_HDR_STRING = 'M E M O R Y   M A P';                       00803300
                  PH# = 1;                                                      00803400
                  CALL SET_CONFIG(0,PH#);                                       00803500
                  CALL MAP_GENERATION;                                          00803600
               END;                                                             00803700
               ELSE DO PH# = 1 TO MAX_PHASE;                                    00803800
                  MAP_HDR_STRING = MAP_HDR||'P H A S E   '||PH#;                00803900
                  CALL SET_CONFIG(0,PH#);                                       00804000
                  CALL MAP_GENERATION;                                          00804100
               END;                                                             00804200
            END;                                                                00804300
            DO;     /* SPECIFIC CONFIGURATION(S) */                             00804400
               DO QQQ = 1 TO TPHASES(MAP_CMD_UTIL(MAP_DEX));                    00804500
                  QQ = TPHASES(QQQ + MAP_CMD_UTIL(MAP_DEX));                    00804600
                  MAP_HDR_STRING = MAP_HDR||CONFIG_NAME(QQ);                    00804700
                  TPHASE_PTR = CONFIG_PHASE_PTR(QQ);                            00804800
                  CALL SET_CONFIG(TPHASE_PTR,0);                                00804900
                  CALL MAP_GENERATION;                                          00805000
               END;                                                             00805100
            END;                                                                00805200
            DO;     /* SPECIFIC PHASE(S) */                                     00805300
               MAP_HDR_STRING = MAP_HDR||'M I X E D   P H A S E S';             00805400
               TPHASE_PTR = MAP_CMD_UTIL(MAP_DEX);                              00805500
               CALL SET_CONFIG(TPHASE_PTR,0);                                   00805600
               CALL MAP_GENERATION;                                             00805700
            END;                                                                00805800
         END;                                                                   00805900
      END;                                                                      00806000
      OUTPUT(1) = TWO;                                                          00806100
                                                                                00806200
   /* GENERATE HALSTAT OUTPUT FILES IF REQUESTED */                             00806300
                                                                                00806400
OUT_CARD:                                                                       00806500
   PROCEDURE (C_TYPE,RPL);                                                      00806600
      DECLARE (C_TYPE,C_BODY,C_SEQ) CHARACTER, C_LEN BIT(16);                   00806700
      DECLARE RPL BIT(1);                                                       00806800
                                                                                00806900
      C_SEQ = CARD_NO;                                                          00807000
      C_LEN = LENGTH(C_SEQ);                                                    00807100
      IF C_LEN < 8 THEN C_SEQ = SUBSTR(ZERO_CHAR,0,8-C_LEN)||C_SEQ;             00807200
      IF RPL THEN C_BODY = PAD(C_TYPE||WORK_STRING,72);                         00807300
      ELSE C_BODY = PAD(C_TYPE||X1||WORK_STRING,72);                            00807400
      IF TOGGLE(7) THEN OUTPUT = C_BODY||C_SEQ;                                 00807500
      ELSE OUTPUT(6) = C_BODY||C_SEQ;                                           00807600
      CARD_NO = CARD_NO + 100;                                                  00807700
   END OUT_CARD;                                                                00807800
                                                                                00807900
ADD_ATTR:                                                                       00808000
   PROCEDURE (STR,MODE);                                                        00808100
      DECLARE STR CHARACTER, (LEN,MODE) BIT(16),                                00808200
         (ATTR_IN_PROGRESS,COMMA_NEEDED) BIT(1);                                00808300
                                                                                00808400
      LEN = LENGTH(STR);                                                        00808500
      IF MODE = - 1 THEN DO;                                                    00808600
         MODE = 1;                                                              00808700
         STR = SUBSTR(STR,0,LEN-1);                                             00808800
      END;                                                                      00808900
      DO CASE MODE;                                                             00809000
         DO;     /* BEGIN NEW ATTR LIST */                                      00809100
            IF ATTR_IN_PROGRESS THEN DO;                                        00809200
               WORK_STRING = WORK_STRING||SEMICOLON_BLK;                        00809300
               IF LENGTH(WORK_STRING) + LEN > 69 THEN DO;                       00809400
                  CALL OUT_CARD(DCHAR,0);                                       00809500
                  WORK_STRING = X6;                                             00809600
               END;                                                             00809700
            END;                                                                00809800
            WORK_STRING = WORK_STRING||STR;                                     00809900
            ATTR_IN_PROGRESS = TRUE;                                            00810000
            COMMA_NEEDED = FALSE;                                               00810100
         END;                                                                   00810200
         DO;     /* ADD A MINOR ATTRIBUTE */                                    00810300
            IF COMMA_NEEDED THEN WORK_STRING = WORK_STRING||COMMA;              00810400
            IF LENGTH(WORK_STRING) + LEN > 69 THEN DO;                          00810500
               CALL OUT_CARD(DCHAR,0);                                          00810600
               WORK_STRING = X6;                                                00810700
            END;                                                                00810800
            WORK_STRING = WORK_STRING||STR;                                     00810900
            COMMA_NEEDED = TRUE;                                                00811000
         END;                                                                   00811100
         DO;     /* END ALL ATTR LISTS */                                       00811200
            IF ATTR_IN_PROGRESS THEN DO;                                        00811300
               WORK_STRING = WORK_STRING||SEMICOLON_BLK;                        00811400
               CALL OUT_CARD(DCHAR,0);                                          00811500
               ATTR_IN_PROGRESS = FALSE;                                        00811600
            END;                                                                00811700
         END;                                                                   00811800
      END;                                                                      00811900
   END ADD_ATTR;                                                                00812000
                                                                                00812100
EMIT_VD:                                                                        00812200
   PROCEDURE (SYMB#);                                                           00812300
      DECLARE (SYMB#,KLIM1,KLIM2,J,K,L,M,REF_STAT,REF_CODE) BIT(16),            00812400
         (LEN,LEN_AVAIL) BIT(16),                                               00812500
         (PTR,SAVE_PTR,BUFF_ADDR) FIXED, STR CHARACTER;                         00812600
                                                                                00812700
      SAVE_PTR = NODE_F(5);                                                     00812800
      CALL OUT_CARD(VCHAR,0);                                                   00812900
      WORK_STRING = X6;                                                         00813000
      CALL ADD_ATTR('TYPE=',0);                                                 00813100
      RLABEL = FALSE;                                                           00813200
      IF ((CLASS=2)|(CLASS=3))&((FLAG&"04000000")=0) THEN RLABEL=TRUE;          00813300
      IF (FLAG & "04000000") ~= 0 THEN STR = ATTR_NAME;                         00813400
      ELSE STR = '';                                                            00813500
      IF NODE_B(4) ~= 0 THEN DO;                                                00813600
         K = SHR(NODE_B(4),1);                                                  00813700
         ARRAY0 = NODE_H(K);                                                    00813800
         ARRAY1 = NODE_H(K + 1);                                                00813900
         ARRAY2 = NODE_H(K + 2);                                                00814000
         ARRAY3 = NODE_H(K + 3);                                                00814100
         IF TYPE ~= 16 THEN DO;                                                 00814200
            STR = STR||ATTR_ARRAY;                                              00814300
            IF ARRAY0 = 1 THEN DO;                                              00814400
               IF ARRAY1 < 0 THEN STR = STR||AST_RPAR_BLK;                      00814500
               ELSE STR = STR||ARRAY1||RPAR_BLK;                                00814600
            END;                                                                00814700
            ELSE DO;                                                            00814800
               STR = STR||ARRAY1||COMMA||ARRAY2;                                00814900
               IF ARRAY0 = 3 THEN STR = STR||COMMA||ARRAY3;                     00815000
               STR = STR||RPAR_BLK;                                             00815100
            END;                                                                00815200
         END;                                                                   00815300
      END;                                                                      00815400
      ELSE ARRAY0,ARRAY1,ARRAY2,ARRAY3 = 0;                                     00815500
      IF TYPE = 16 THEN DO;                                                     00815600
         IF (FLAG & "02000000") = 0 THEN DO;                                    00815700
            IF STRUC1 ~= 0 THEN STR = STR||ATTR_MINOR_STRUC;                    00815800
            ELSE DO;                                                            00815900
               STR = STR||ATTR_STRUCTURE;                                       00816000
               IF ARRAY1 < 0 THEN STR = STR||LPAR_AST_RPAR_BLK;                 00816100
               ELSE IF ARRAY1 > 1 THEN STR = STR||LPAREN||ARRAY1||RPAR_BLK;     00816200
               ELSE STR = STR||X1;                                              00816300
            END;                                                                00816400
         END;                                                                   00816500
     END;                                                                       00816600
      ELSE IF CLASS = 3 THEN STR = STR||ATTR_FUNCTION||ATTR_LABEL;              00816700
      ELSE IF (CLASS=2)|(CLASS=5) THEN DO;                                      00816800
         DO CASE TYPE;                                                          00816900
            ;                                                                   00817000
            STR = STR||ATTR_PROGRAM;                                            00817100
            STR = STR||ATTR_PROCEDURE;                                          00817200
            ;                                                                   00817300
            STR = STR||ATTR_COMPOOL;                                            00817400
            STR = STR||ATTR_TASK;                                               00817500
            STR = STR||ATTR_UPDATE;                                             00817600
            ;                                                                   00817700
            ;                                                                   00817800
            STR = STR||ATTR_REPLACE;                                            00817900
         END;                                                                   00818000
         IF CLASS = 5 THEN STR = STR||ATTR_TERMINAL;                            00818100
         ELSE STR = STR||ATTR_LABEL;                                            00818200
      END;                                                                      00818300
      ELSE DO;                                                                  00818400
         DO CASE TYPE;                                                          00818500
            ;                                                                   00818600
            DO;                                                                 00818700
DO_BITS:                                                                        00818800
               TEMP1 = NODE_B(19);                                              00818900
               IF TYPE = 17 THEN STR = STR||ATTR_EVENT;                         00819000
               ELSE STR = STR||ATTR_BIT||TEMP1||RPAR_BLK;                       00819100
            END;                                                                00819200
            DO;                                                                 00819300
               TEMP1 = NODE_H(9);                                               00819400
               STR = STR||ATTR_CHARACTER;                                       00819500
               IF TEMP1 < 0 THEN STR = STR||AST_RPAR_BLK;                       00819600
               ELSE STR = STR||TEMP1||RPAR_BLK;                                 00819700
            END;                                                                00819800
            DO;                                                                 00819900
DO_MATRIX:                                                                      00820000
               TEMP1 = NODE_B(18);                                              00820100
               TEMP2 = NODE_B(19);                                              00820200
               STR = STR||ATTR_MATRIX||TEMP1||COMMA||TEMP2||RPAR_BLK;           00820300
               IF TYPE = 11 THEN STR = STR||ATTR_DOUBLE;                        00820400
            END;                                                                00820500
            DO;                                                                 00820600
DO_VECTOR:                                                                      00820700
               TEMP1 = NODE_B(19);                                              00820800
               STR = STR||ATTR_VECTOR||TEMP1||RPAR_BLK;                         00820900
               IF TYPE = 12 THEN STR = STR||ATTR_DOUBLE;                        00821000
            END;                                                                00821100
            DO;                                                                 00821200
DO_SCALAR:                                                                      00821300
               STR = STR||ATTR_SCALAR;                                          00821400
               IF TYPE = 13 THEN STR = STR||ATTR_DOUBLE;                        00821500
            END;                                                                00821600
            DO;                                                                 00821700
DO_INTEGER:                                                                     00821800
               STR = STR||ATTR_INTEGER;                                         00821900
               IF TYPE = 14 THEN STR = STR||ATTR_DOUBLE;                        00822000
            END;                                                                00822100
            ;;                                                                  00822200
            GO TO DO_BITS;                                                      00822300
            GO TO DO_BITS;                                                      00822400
            GO TO DO_MATRIX;                                                    00822500
            GO TO DO_VECTOR;                                                    00822600
            GO TO DO_SCALAR;                                                    00822700
            GO TO DO_INTEGER;                                                   00822800
            ;;                                                                  00822900
            GO TO DO_BITS;                                                      00823000
         END;                                                                   00823100
         IF CLASS >= 4 THEN STR = STR||ATTR_TERMINAL;                           00823200
      END;                                                                      00823300
      CALL ADD_ATTR(STR,-1);                                                    00823400
      CALL ADD_ATTR('ATTR=',0);                                                 00823500
      IF ((FLAG & "00020000") ~= 0) THEN DO;                                    00823600
         STR = ATTR_LOCK;                                                       00823700
         TEMP1 = NODE_B(20);                                                    00823800
         IF TEMP1 = "FF" THEN STR = STR||AST_RPAR_BLK;                          00823900
         ELSE STR = STR||TEMP1||RPAR_BLK;                                       00824000
         CALL ADD_ATTR(STR,-1);                                                 00824100
      END;                                                                      00824200
      IF (FLAG & "10000000") ~= 0 THEN CALL ADD_ATTR(ATTR_TEMPORARY,-1);        00824300
      IF RLABEL = FALSE THEN                                                    00824400
         IF (FLAG & "00040000") ~= 0 THEN CALL ADD_ATTR(ATTR_LATCHED,-1);       00824500
      IF (FLAG & "00010000") ~= 0 THEN CALL ADD_ATTR(ATTR_REMOTE,-1);           00824600
      IF (FLAG & "08000000") ~= 0 THEN CALL ADD_ATTR(ATTR_AUTOMATIC,-1);        00824700
      IF (FLAG & "00400000") ~= 0 THEN CALL ADD_ATTR(ATTR_DENSE,-1);            00824800
      IF (FLAG & "00002000") ~= 0 THEN CALL ADD_ATTR(ATTR_RIGID,-1);            00824900
      IF (FLAG & "00100000") ~= 0 THEN CALL ADD_ATTR(ATTR_ACCESS,-1);           00825000
      IF (FLAG & "00004000") ~= 0 THEN CALL ADD_ATTR(ATTR_INITIAL,-1);          00825100
      IF (FLAG & "00200000") ~= 0 THEN CALL ADD_ATTR(ATTR_CONSTANT,-1);         00825200
      IF (RLABEL=TRUE)&((CLASS=3)|((CLASS=2)&(TYPE=2))) THEN DO;                00825300
         IF (FLAG & "00800000") ~= 0 THEN CALL ADD_ATTR(ATTR_REENTRANT,-1);     00825400
         ELSE IF (FLAG & "00000040") ~= 0 THEN CALL ADD_ATTR(ATTR_EXCLUSIVE,-1);00825500
      END;                                                                      00825600
      IF (FLAG & "00000100") ~= 0 THEN CALL ADD_ATTR(ATTR_EQUATED,-1);          00825700
      IF (FLAG & "00000400") ~= 0 THEN CALL ADD_ATTR(ATTR_STACK,-1);            00825800
      IF (FLAG & "40000000") ~= 0 THEN CALL ADD_ATTR(ATTR_INPUT,-1);            00825900
      IF (FLAG & "20000000") ~= 0 THEN CALL ADD_ATTR(ATTR_ASSIGN,-1);           00826000
      IF (FLAG & "00001000") ~= 0 THEN CALL ADD_ATTR(ATTR_LITERAL,-1);          00826100
      IF (FLAG & "01000000") ~= 0 THEN CALL ADD_ATTR(ATTR_UNQUALIFIED,-1);      00826200
      IF (RLABEL = FALSE) THEN                                                  00826300
         IF (FLAG & "00080000") ~= 0 THEN CALL ADD_ATTR(ATTR_INDIRECT,-1);      00826400
      IF (COMPOOL_FLAG=TRUE)|(SYMB#=KEY_SYMB) THEN DO;                          00826500
         IF COMPOOL_FLAG THEN                                                   00826600
            CALL VMEM_LOCATE_COPY(1,VAR_BASE(I),SYMB#,0);                       00826700
         ELSE IF SYMB# = KEY_SYMB THEN                                          00826800
            CALL VMEM_LOCATE_COPY(1,VAR_BASE(I),1,0);                           00826900
         PTR = VMEM_F(0);                                                       00827000
         IF PTR ~= 0 THEN DO;                                                   00827100
            CALL ADD_ATTR('XREF=',0);                                           00827200
            DO WHILE PTR ~= 0;                                                  00827300
               REF_STAT = 0;                                                    00827400
               CALL VMEM_LOCATE_PTR(1,PTR,0);                                   00827500
               PTR = COREWORD(VMEM_LOC_ADDR);                                   00827600
               COREWORD(ADDR(NODE_H1)) = VMEM_LOC_ADDR;                         00827700
               STR = RTRIM(SUBSTR(SDF_NAMES(NODE_H1(2)),2));                    00827800
               KLIM1 = 4;                                                       00827900
               KLIM2 = KLIM1 + NODE_H1(3) - 1;                                  00828000
               DO K = KLIM1 TO KLIM2;                                           00828100
                  REF_CODE = SHR(NODE_H1(K),13)&7;                              00828200
                  IF REF_CODE = 0 THEN REF_CODE = 8;                            00828300
                  REF_STAT = REF_STAT | REF_CODE;                               00828400
               END;                                                             00828500
               CALL ADD_ATTR(STR||SLASH||REF_STAT,1);                           00828600
            END;                                                                00828700
         END;                                                                   00828800
      END;                                                                      00828900
      ELSE IF NODE_B(3) ~= 0 THEN DO;                                           00829000
         REF_STAT = 0;                                                          00829100
         CALL ADD_ATTR('XREF=',0);                                              00829200
         COREWORD(ADDR(NODE_F1)) = ADDRESS;                                     00829300
         COREWORD(ADDR(NODE_H1)) = ADDRESS;                                     00829400
         K = SHR(NODE_B(3),1);                                                  00829500
         STR = RTRIM(SUBSTR(SDF_NAMES(I),2));                                   00829600
         L = NODE_H1(K);                                                        00829700
         K = K + 1;                                                             00829800
         DO J = 1 TO L;                                                         00829900
            M = NODE_H1(K);                                                     00830000
            IF M ~= -1 THEN DO;                                                 00830100
               REF_CODE = SHR(M,13)&7;                                          00830200
               IF (REF_CODE=0)&(J>60) THEN DO;                                  00830300
                  K = K - 2;                                                    00830400
                  GO TO FIX_XREF;                                               00830500
               END;                                                             00830600
               IF REF_CODE = 0 THEN REF_CODE = 8;                               00830700
               REF_STAT = REF_STAT | REF_CODE;                                  00830800
            END;                                                                00830900
            ELSE DO;                                                            00831000
FIX_XREF:                                                                       00831100
               J = J - 1;                                                       00831200
               K = SHR(K+2,1);                                                  00831300
               PNTR = NODE_F1(K);                                               00831400
               CALL MONITOR(22,5);                                              00831500
               COREWORD(ADDR(NODE_F1)) = ADDRESS;                               00831600
               COREWORD(ADDR(NODE_H1)) = ADDRESS;                               00831700
               K = -1;                                                          00831800
            END;                                                                00831900
            K = K + 1;                                                          00832000
         END;                                                                   00832100
         CALL ADD_ATTR(STR||SLASH||REF_STAT,1);                                 00832200
      END;                                                                      00832300
      CALL ADD_ATTR('',2);                                                      00832400
      IF (CLASS=2)&(TYPE=9) THEN DO;                                            00832500
         IF (VERSION>=25)&(SAVE_PTR~=0) THEN DO;                                00832600
            LEN = EXTRACT_REPLACE_TEXT(SAVE_PTR,REPL_TEXT_ADDR1);               00832700
            BUFF_ADDR = REPL_TEXT_ADDR1;                                        00832800
            WORK_STRING = '       REPL="';                                      00832900
            DO WHILE LEN > 0;                                                   00833000
               LEN_AVAIL = 71 - LENGTH(WORK_STRING);                            00833100
               IF (LEN+2) <= LEN_AVAIL THEN DO;                                 00833200
                  WORK_STRING = WORK_STRING||STRING(SHL(LEN-1,24)+              00833300
                     BUFF_ADDR)||'";';                                          00833400
                  CALL OUT_CARD(DCHAR,1);                                       00833500
                  RETURN;                                                       00833600
               END;                                                             00833700
               ELSE DO;                                                         00833800
                  WORK_STRING = WORK_STRING||STRING(SHL(LEN_AVAIL-1,24)+        00833900
                     BUFF_ADDR);                                                00834000
                  CALL OUT_CARD(DCHAR,1);                                       00834100
                  BUFF_ADDR = BUFF_ADDR + LEN_AVAIL;                            00834200
                  LEN = LEN - LEN_AVAIL;                                        00834300
                  WORK_STRING = '';                                             00834400
               END;                                                             00834500
            END;                                                                00834600
         END;                                                                   00834700
      END;                                                                      00834800
   END EMIT_VD;                                                                 00834900
                                                                                00835000
      IF FILE_LEVEL > 2 THEN FILE_LEVEL = 2;                                    00835100
      DO CASE FILE_LEVEL;                                                       00835200
         DO;     /* 0 --> NO FILE */                                            00835300
         END;                                                                   00835400
         DO;     /* 1 --> SKELETAL PSF (OR VB RECORDS) */                       00835500
COMMON_FILE:                                                                    00835600
            DO UNIT_NO = 1 TO #UNITS;                                           00835700
               I = UNIT_SORT(UNIT_NO);                                          00835800
               IF ((UNIT_FLAGS(I)&"80")~=0)|((#U_CMDS=0)&(UNIT_TYPE(I)=4))      00835900
               THEN DO;                                                         00836000
                  CARD_NO = 100;                                                00836100
                  WORK_STRING = UNIT_NAMES(I);                                  00836200
                  IF TOGGLE(7) THEN DO;                                         00836300
                     CALL EMIT_HDG('PSF MEMBER $$'||                            00836400
                        SUBSTR(SDF_NAMES(I),2,6));                              00836500
                     SPACE_1;                                                   00836600
                  END;                                                          00836700
                  CALL SDF_SELECT(I);                                           00836800
                  IF FILE_LEVEL = 1 THEN CALL OUT_CARD(UCHAR,0);                00836900
                  DO BLK# = 1 TO #PROCS;                                        00837000
                     WORK_STRING = BLOCK_NAME(BLK#);                            00837100
                     COREWORD(ADDR(NODE_B)) = ADDRESS;                          00837200
                     COREWORD(ADDR(NODE_H)) = ADDRESS;                          00837300
                     IF (NODE_B(24)&"08") = 0 THEN DO;   /* INTERNAL */         00837400
                        IF FILE_LEVEL = 1 THEN CALL OUT_CARD(BCHAR,0);          00837500
                        SLIM1 = NODE_H(16);                                     00837600
                        SLIM2 = NODE_H(17);                                     00837700
                        DO J = SLIM1 TO SLIM2;                                  00837800
                           WORK_STRING = SYMBOL_NAME(J);                        00837900
                           COREWORD(ADDR(NODE_B)) = ADDRESS;                    00838000
                           COREWORD(ADDR(NODE_H)) = ADDRESS;                    00838100
                           COREWORD(ADDR(NODE_F)) = ADDRESS;                    00838200
                           IF NODE_B(5) = 0 THEN STRUC1,STRUC2 = 0;             00838300
                           CLASS = NODE_B(6);                                   00838400
                           TYPE = NODE_B(7);                                    00838500
                           FLAG = NODE_F(2);                                    00838600
                           IF CLASS >= 4 THEN DO;                               00838700
                              IF (TYPE ~= 16)&((FLAG & "01000000")~=0) THEN DO; 00838800
                                 IF FILE_LEVEL = 1 THEN CALL EMIT_VD(J);        00838900
                              END;                                              00839000
                           END;                                                 00839100
                           ELSE IF (CLASS=2)&(TYPE>6) THEN DO;                  00839200
                              IF TYPE = 9 THEN DO;   /* REPLACE */              00839300
                                 IF (FLAG&"80000000") = 0 THEN DO;              00839400
                                    IF NODE_B(3) = 0 THEN GO TO BYPASS_REPL;    00839500
                                    ELSE IF NODE_H(SHR(NODE_B(3),1))=1 THEN     00839600
                                       GO TO BYPASS_REPL;                       00839700
                                 END;                                           00839800
                                 IF FILE_LEVEL = 1 THEN DO;                     00839900
                                    CALL EMIT_VD(J);                            00840000
                                 END;                                           00840100
BYPASS_REPL:                                                                    00840200
                              END;                                              00840300
                           END;                                                 00840400
                           ELSE DO;                                             00840500
                              NAME_ARRAY(0) = KEEP(WORK_STRING);                00840600
                              IF FILE_LEVEL = 1 THEN CALL EMIT_VD(J);           00840700
                              IF (CLASS=1)&(TYPE=16)&((FLAG&"05000000")=0)      00840800
                              THEN DO;                                          00840900
                                 NAME_INX,STACK_INX = 0;                        00841000
                                 LINK = NODE_H(9);                              00841100
STRUC_LOOP:                                                                     00841200
                                 DO FOREVER;                                    00841300
                                    WORK_STRING = KEEP(SYMBOL_NAME(LINK));      00841400
                                    COREWORD(ADDR(NODE_B)) = ADDRESS;           00841500
                                    COREWORD(ADDR(NODE_H)) = ADDRESS;           00841600
                                    COREWORD(ADDR(NODE_F)) = ADDRESS;           00841700
                                    CLASS = NODE_B(6);                          00841800
                                    TYPE = NODE_B(7);                           00841900
                                    FLAG = NODE_F(2);                           00842000
                                    K = SHR(NODE_B(5),1);                       00842100
                                    STRUC1 = NODE_H(K + 1);                     00842200
                                    STRUC2 = NODE_H(K + 2);                     00842300
                                    IF (FLAG & "02000000") = 0 THEN DO;         00842400
                                       NAME_INX = NAME_INX + 1;                 00842500
                                       NAME_ARRAY(NAME_INX) = WORK_STRING;      00842600
                                       WORK_STRING = NAME_ARRAY(0);             00842700
                                       DO K = 1 TO NAME_INX;                    00842800
                                          WORK_STRING=WORK_STRING||PERIOD;      00842900
                                          IF (LENGTH(WORK_STRING) +             00843000
                                          LENGTH(NAME_ARRAY(K))) > 69 THEN DO;  00843100
                                             CALL OUT_CARD(VCHAR,0);            00843200
                                             WORK_STRING=X3||NAME_ARRAY(K);     00843300
                                          END;                                  00843400
                                          ELSE WORK_STRING=WORK_STRING||        00843500
                                             NAME_ARRAY(K);                     00843600
                                       END;                                     00843700
                                       CALL EMIT_VD(LINK);                      00843800
                                    END;                                        00843900
                                    IF STRUC1 ~= 0 THEN LINK = STRUC1;          00844000
                                    ELSE IF (TYPE=16)&((FLAG&"04000000")=0)     00844100
                                    THEN DO;                                    00844200
                                       LINK = NODE_H(9);                        00844300
                                       CALL PUSH_STACK;                         00844400
                                       TPL_STACK1(STACK_INX) = STRUC2;          00844500
                                    END;                                        00844600
                                    ELSE DO;                                    00844700
                                       NAME_INX = NAME_INX - 1;                 00844800
                                       LINK = STRUC2;                           00844900
                                    END;                                        00845000
                                    DO WHILE LINK <= 0;                         00845100
                                       IF LINK < 0 THEN DO;                     00845200
                                          NAME_INX = NAME_INX - 1;              00845300
                                          SYMBNO = - LINK;                      00845400
                                          CALL MONITOR(22,9);                   00845500
                                          COREWORD(ADDR(NODE_B)) = ADDRESS;     00845600
                                          COREWORD(ADDR(NODE_H)) = ADDRESS;     00845700
                                          LINK = NODE_H(SHR(NODE_B(5),1)+2);    00845800
                                       END;                                     00845900
                                       ELSE DO;                                 00846000
                                          IF STACK_INX = 0 THEN                 00846100
                                             ESCAPE STRUC_LOOP;                 00846200
                                          LINK = TPL_STACK1(STACK_INX);         00846300
                                          STACK_INX = STACK_INX - 1;            00846400
                                       END;                                     00846500
                                    END;                                        00846600
                                 END;                                           00846700
                              END;                                              00846800
                           END;                                                 00846900
                        END;                                                    00847000
                     END;                                                       00847100
                  END;                                                          00847200
                  IF ~TOGGLE(7) THEN                                            00847300
                    CALL MONITOR(1,6,DBL_DOLLAR_SIGN||SUBSTR(SDF_NAMES(I),2,6));00847400
               END;                                                             00847500
            END;                                                                00847600
         END;                                                                   00847700
         DO;     /* 2 --> HALSTAT FILE GENERATION */                            00847800
         END;                                                                   00847900
      END;                                                                      00848000
                                                                                00848100
   /* FREE PRIMARY REPLACE TEXT BUFFER */                                       00848200
                                                                                00848300
      CALL VMEM_LOCATE_PTR(1,REPL_TEXT_PTR1,RELS);                              00848400
                                                                                00848500
   /* SAVE KEY SDFPKG PARAMETERS FOR USE BY PRINTSUMMARY */                     00848600
                                                                                00848700
      SDFPKG_LOCATES = LOCCNT;                                                  00848800
      SDFPKG_READS = READS;                                                     00848900
      SDFPKG_SLECTCNT = SLECTCNT;                                               00849000
      SDFPKG_FCBAREA = TOTFCBLN;                                                00849100
      SDFPKG_PGAREA = NUMOFPGS;                                                 00849200
      SDFPKG_NUMGETM = NUMGETM;                                                 00849300
                                                                                00849400
   /* ALLOW SDFPKG TO TERMINATE ITSELF.  THEN IT WILL BE DELETED */             00849500
                                                                                00849600
      CALL MONITOR(22,1);                                                       00849700
                                                                                00849800
   END SDF_PROCESSING    /*  $S  */ ; /*  $S  */                                00849900
                                                                                00850000
PRINTSUMMARY:                                                                   00850100
   PROCEDURE;                                                                   00850200
      DECLARE T FIXED,                                                          00850300
              (S1,S2,S3) CHARACTER,                                             00850400
              I BIT(16);                                                        00850500
                                                                                00850600
      OUTPUT(1) = ONE;                                                          00850700
      IF STAT_FLAG THEN DO;                                                     00850800
         SPACE_1;                                                               00850900
         OUTPUT = 'H A L   S T A T E M E N T    F R E Q U E N C I E S';         00851000
         SPACE_1;                                                               00851100
         OUTPUT = '  STATEMENT TYPE          #       %';                        00851200
         SPACE_1;                                                               00851300
         T = 0;                                                                 00851400
         DO I = 0 TO 36;                                                        00851500
            T = T + GLOBAL_STMT_CNT(I);                                         00851600
         END;                                                                   00851700
         DO I = 0 TO 36;                                                        00851800
            IF GLOBAL_STMT_CNT(I) ~= 0 THEN DO;                                 00851900
               S1 = PAD(STMT_TYPES(I),20);                                      00852000
               S2 = LPAD(GLOBAL_STMT_CNT(I),5);                                 00852100
               S3 = PERCENT(GLOBAL_STMT_CNT(I),T);                              00852200
               OUTPUT = S1||X2||S2||X4||S3;                                     00852300
            END;                                                                00852400
         END;                                                                   00852500
         SPACE_1;                                                               00852600
      END;                                                                      00852700
      T = TIME;                                                                 00852800
      CALL PRINT_DATE_AND_TIME('END OF HALSTAT ',DATE,T);                       00852900
      SPACE_1;                                                                  00853000
      OUTPUT=TOTAL_ERRORS||' ERRORS ('||SEVERE_ERRORS||' SEVERE) WERE DETECTED';00853100
      OUTPUT = 'HIGHEST SEVERITY CODE WAS '||MAX_SEVERITY;                      00853200
      OUTPUT = 'LAST ERROR WAS AT SYMBOL '||LAST_ERROR;                         00853300
      SPACE_1;                                                                  00853400
      IF GSD_LEVEL > 0 THEN DO;                                                 00853500
         OUTPUT = UNUSED_CNT||' SYMBOLS NOT USED';                              00853600
         OUTPUT = UNASSIGN_CNT||' SYMBOLS REFERENCED BUT NOT ASSIGNED';         00853700
      END;                                                                      00853800
      IF TOTAL_STACK_WALKS > 0 THEN                                             00853900
         OUTPUT = TOTAL_STACK_WALKS||' STACK WALK-BACK LOOPS';                  00854000
      IF TOTAL_EXTRAN_CNT > 0 THEN                                              00854100
         OUTPUT = TOTAL_EXTRAN_CNT||' EXTRANEOUS CSECTS -- TOTAL OF '||         00854200
            TOTAL_EXTRAN_SIZE||MEM_TYPE;                                        00854300
      SPACE_1;                                                                  00854400
      OUTPUT = 'NUMBER OF COMPILATION UNITS       = '|| #UNITS;                 00854500
      OUTPUT = 'NUMBER OF CSECTS                  = '|| #CSECTS;                00854600
      SPACE_1;                                                                  00854700
      IF ADL_FLAG THEN                                                          00854800
         OUTPUT = 'NUMBER OF ADL RECORDS EMITTED     = '||RECORD#;              00854900
      OUTPUT = 'NUMBER OF SDFPKG LOCATES          = '|| SDFPKG_LOCATES;         00855000
      OUTPUT = 'NUMBER OF SDFPKG READS            = '|| SDFPKG_READS;           00855100
      OUTPUT = 'NUMBER OF SDFPKG SELECTS          = '|| SDFPKG_SLECTCNT;        00855200
      OUTPUT = 'NUMBER OF SDFPKG GETMAINS         = '|| SDFPKG_NUMGETM;         00855300
      OUTPUT = 'SDFPKG FCB AREA SIZE (BYTES)      = '|| SDFPKG_FCBAREA;         00855400
      OUTPUT = 'SDFPKG PAGING AREA SIZE (PAGES)   = '|| SDFPKG_PGAREA;          00855500
      SPACE_1;                                                                  00855600
      OUTPUT = 'VMEM PAGING AREA SIZE (PAGES)     = '|| VMEM_MAX_PAD + 1;       00855602
      OUTPUT = 'NUMBER OF FILE 1 PAGES            = '||VMEM_FILE_LAST_PAGE(1)+1;00855605
      OUTPUT = 'NUMBER OF FILE 1 LOCATES          = '|| VMEM_FILE_LOCATE_CNT(1);00855610
      OUTPUT = 'NUMBER OF FILE 1 READS            = '||VMEM_FILE_READ_CNT(1);   00855615
      OUTPUT = 'NUMBER OF FILE 1 WRITES           = '|| VMEM_FILE_WRITE_CNT(1); 00855620
      OUTPUT = 'NUMBER OF FILE 2 PAGES            = '||VMEM_FILE_LAST_PAGE(2)+1;00855630
      OUTPUT = 'NUMBER OF FILE 2 LOCATES          = '|| VMEM_FILE_LOCATE_CNT(2);00855635
      OUTPUT = 'NUMBER OF FILE 2 READS            = '|| VMEM_FILE_READ_CNT(2);  00855640
      OUTPUT = 'NUMBER OF FILE 2 WRITES           = '|| VMEM_FILE_WRITE_CNT(2); 00855645
      SPACE_1;                                                                  00855647
                                                                                00855700
      CALL VMEM_CLOSE_FILE(1,DELETE);                                           00855800
      IF FILE_LEVEL = 2 THEN CALL VMEM_CLOSE_FILE(2,VMEM_SAVE);                 00855900
      ELSE CALL VMEM_CLOSE_FILE(2,DELETE);                                      00855905
                                                                                00856000
                                                                                00856100
      OUTPUT = 'FREE STRING AREA SIZE (BYTES)     = '|| FREE_STRING_SIZE;       00856200
      OUTPUT = 'NUMBER OF MINOR COMPACTIFIES      = '|| COMPACTIFIES;           00856300
      OUTPUT = 'NUMBER OF MAJOR COMPACTIFIES      = '|| COMPACTIFIES(1);        00856400
      SPACE_1;                                                                  00856500
      DO I = 1 TO 8;                                                            00856600
         IF CLOCK(I) < CLOCK(I - 1) THEN CLOCK(I) = CLOCK(I) + 8640000;         00856700
      END;                                                                      00856800
      CALL PRINTTIME('TOTAL CPU TIME IN HALSTAT              ',                 00856900
                CLOCK(8) - CLOCK);                                              00857000
      SPACE_1;                                                                  00857100
      CALL PRINTTIME('CPU TIME FOR INITIALIZATION            ',                 00857200
                CLOCK(1) - CLOCK);                                              00857300
      CALL PRINTTIME('CPU TIME FOR CESD PROCESSING           ',                 00857400
                CLOCK(2) - CLOCK(1));                                           00857500
      CALL PRINTTIME('CPU TIME FOR COMPILATION UNIT SETUP    ',                 00857600
                CLOCK(3) - CLOCK(2));                                           00857700
      CALL PRINTTIME('CPU TIME FOR SYMBOL CORRELATION        ',                 00857800
                CLOCK(4) - CLOCK(3));                                           00857900
      CALL PRINTTIME('CPU TIME FOR SYMBOL ALPHABETIZATION    ',                 00858000
                CLOCK(5) - CLOCK(4));                                           00858100
      CALL PRINTTIME('CPU TIME FOR STATISTICS GENERATION     ',                 00858200
               CLOCK(6) - CLOCK(5));                                            00858300
      CALL PRINTTIME('CPU TIME FOR GSD GENERATION            ',                 00858400
               CLOCK(7) - CLOCK(6));                                            00858500
      CALL PRINTTIME('CPU TIME FOR MAP GENERATION            ',                 00858600
               CLOCK(8) - CLOCK(7));                                            00858700
   END PRINTSUMMARY;                                                            00858800
                                                                                00858900
   /*  START OF THE MAIN PROGRAM  */                                            00859000
MAIN_PROGRAM:                                                                   00859100
                                                                                00859200
   CLOCK = MONITOR(18);                                                         00859300
   CALL INITIALIZE;                                                             00859400
   CLOCK(1) = MONITOR(18);                                                      00859500
   CALL SDF_PROCESSING;                                                         00859600
   CLOCK(8) = MONITOR(18);                                                      00859700
   CALL PRINTSUMMARY;                                                           00859800
   RETURN SHL(MAX_SEVERITY,2);                                                  00859900
NO_CORE:                                                                        00860000
   SPACE_1;                                                                     00860100
   OUTPUT = '*** INSUFFICIENT CORE MEMORY -- INCREASE REGION SIZE ***';         00860200
BAIL_OUT:                                                                       00860300
   SPACE_1;                                                                     00860400
   OUTPUT = 'H A L S T A T   P R O C E S S I N G   A B A N D O N E D';          00860500
   SPACE_1;                                                                     00860600
   RETURN 16;                                                                   00860700
EOF EOF EOF EOF EOF EOF EOF EOF EOF                                             00860800
