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
 /***********************************************************/                  00006000
 /*                                                         */                  00007000
 /*  REVISION HISTORY                                       */                  00008000
 /*                                                         */                  00009000
 /*  DATE     WHO  RLS   DR/CR #  DESCRIPTION               */                  00009100
 /*                                                         */                  00009200
 /*  11/30/90 RAH  23V1  CR11088  INCREASE DOWNGRADE LIMIT  */                  00009300
 /*  01/17/91 TKK  23V2  CR11098  DELETE SPILL CODE FROM    */
 /*                               COMPILER                  */
 /*  02/22/91 TKK  23V2  CR11109  CLEAN UP OF COMPILER      */
 /*                               SOURCE CODE               */
 /*  06/27/91 TEV   7V0  CR11114  MERGE BFS/PASS COMPILERS  */
 /*                               WITH CR/DR FIXES          */
 /*  10/29/93 TEV  26V0/ DR108630 0C4 ABEND OCCURS ON       */
 /*                10V0           ILLEGAL DOWNGRADE         */
 /*  04/05/94 JAC  26V0  DR108643 INCORRECTLY PRINTS 'NONHAL' */
 /*                10V0           INSTEAD OF 'INCREM' IN    */
 /*                               SDFLIST                   */
 /*  07/11/95 DAS  27V0  CR12416  IMPROVE COMPILER ERROR    */
 /*                11V0           PROCESSING                */
 /*  03/03/95 BAF  27V0  DR108629 STATEMENT NUMBER IN ERROR */
 /*                11V0            MESSAGE INCORRECT -      */
 /*                                DELETED PREVIOUS_ERROR.  */
 /*  11/21/95 BAF/ 27V1  DR107302  INCORRECT ERROR MESSAGE  */
 /*           RCK  11V1             FOR NAME INITIALIZATION */
 /*  12/07/95 BAF/ 27V1  DR109024 INVALID NONHAL DECLARATION*/
 /*           RCK  11V1            DOES NOT GET ERROR MSG   */
 /*                                                         */
 /*  01/25/96 DAS  27V1  DR109036 BAD SEVERITY 3 ERROR      */
 /*                11V1  HANDLING IN PASS1                  */
 /*                                                         */
 /*  12/20/97 SMR  28V0  CR12713  ENHANCE COMPILER LISTING  */
 /*                12V0                                     */
 /*                                                         */
 /*  08/19/96 SMR  28V0  DR108603 ZS1 NOT DOWNGRADED FOR    */
 /*                12V0  CARD TYPE WCZMTCBCPC               */
 /*                                                         */
 /*  08/06/96 SMR  28V0  DR109044 DI17 ERROR EMITTED FOR    */
 /*                12V0  NAME CHARACTER(*) PARAMETERS       */
 /*                                                         */
 /*  02/18/98 SMR  29V0  CR12940  ENHANCE COMPILER LISTING  */
 /*                14V0                                     */
 /*                                                         */
 /*  12/02/97 JAC  29V0  DR109074 DOWNGRADE OF DI21 FAILS   */
 /*                14V0  WHEN INCLUDING A REMOTELY          */
 /*                                                         */
 /*  01/28/98 DCP  29V0/ DR109052 ARITHMETIC EXPRESSION IN  */
 /*                14V0  CONSTANT/INITIAL VALUE GETS ERROR  */
 /*                                                         */
 /*  01/15/98 DCP  29V0  DR109083 CONSTANT DOUBLE SCALAR    */
 /*                14V0  CONVERTED TO CHAR AS SINGLE        */
 /*                                                         */
 /*  03/03/98 LJK  29V0  REPLACE MACRO SPLIT ON TWO LINES   */
 /*                14V0                                     */
 /*                                                         */
 /*  04/03/00 DCP  30V0  CR13273 PRODUCE SDF MEMBER WHEN    */
 /*                15V0          OBJECT MODULE CREATED      */
 /*                                                         */
 /*                                                         */
 /*  12/23/99 JAC  30V0  DR111348 NO ERROR EMITTED FOR      */
 /*                15V0  REMOTE STRUCTURE TEMPLATE MISMATCH */
 /*                                                         */
 /*  01/30/00 DCP  30V0  CR13211 GENERATE ADVISORY MESSAGE  */
 /*                15V0  WHEN BIT STRING ASSIGNED TO        */
 /*                      SHORTER STRING                     */
 /*                                                         */
 /*  11/22/99 JAC  30V0  DR111326 STATEMENTS PRINTED        */
 /*                15V0  INCORRECTLY AFTER REPLACE MACRO    */
 /*                                                         */
 /*  09/09/99 JAC  30V0  DR111341 DO CASE STATEMENT PRINTED */
 /*                15V0  INCORRECTLY (PRINT_FLUSH DELETED)  */
 /*                                                         */
 /*  05/04/99 JAC  30V0  DR111320 INCORRECTLY PRINTED       */
 /*                15V0  EXPONENT IN OUTPUT LISTING         */
 /*                                                         */
 /*  03/24/99 JAC  30V0  DR111314 INCLUDE FAILS WITH SRN    */
 /*                15V0  OPTION                             */
 /*                                                         */
 /*  04/26/01 DCP  31V0  CR13335  ALLEVIATE SOME DATA SPACE */
 /*                16V0           PROBLEMS IN HAL/S COMPILER*/
 /*                                                         */
 /*  01/23/01 DCP  31V0  CR13336  DON'T ALLOW ARITHMETIC    */
 /*                16V0           EXPRESSIONS IN CHARACTER  */
 /*                               INITIAL CLAUSES           */
 /*                                                         */
 /*  02/01/01 DCP  31V0  DR111367 ABEND OCCURS FOR A        */
 /*                16V0           MULTI-DIMENSIONAL ARRAY   */
 /*                                                         */
 /*  12/20/00 TKN  31V0  DR111356 XREF INCORRECT FOR        */
 /*                16V0  STRUCTURE TEMPLATE DECLARATION     */
 /*                                                         */
 /*  04/20/04 DCP  32V0  CR13832  REMOVE UNPRINTED TYPE 1   */
 /*                17V0           HAL/S COMPILER OPTIONS    */
 /*                                                         */
 /*  09/20/03 DCP  32V0  DR120227 INCLUDE COUNT INCORRECT   */
 /*                17V0           IN COMPILATION LISTING    */
 /*                                                         */
 /*  09/09/02 JAC  32V0  CR13570  CREATE NEW %MACRO TO      */
 /*                17V0  PERFORM ZEROTH ELEMENT CALCULATIONS*/
 /*                                                         */
 /***********************************************************/                  00009500
 /* TURN ON $ZEE RUN */                                                         00000100
 /* $HH A L   C O M P I L E R   --   P H A S E   1   --   I N T E R M E T R I C 00000200
 S ,   I N C . */                                                               00000300
                                                                                00000400
                                                                                00000450
 /*   THE FOLLOWING IS THE INPUT GRAMMAR   */                                   00000500
                                                                                00000550
                                                                                00000600
                                                                                00000650
                                                                                00000700
 /*      1   <COMPILATION> ::= <COMPILE LIST> _|_                     */        00000750
                                                                                00000800
 /*      2   <COMPILE LIST> ::= <BLOCK DEFINITION>                    */        00000850
 /*      3                    | <COMPILE LIST> <BLOCK DEFINITION>     */        00000900
                                                                                00000950
 /*      4   <ARITH EXP> ::= <TERM>                                   */        00001000
 /*      5                 | + <TERM>                                 */        00001050
 /*      6                 | - <TERM>                                 */        00001100
 /*      7                 | <ARITH EXP> + <TERM>                     */        00001150
 /*      8                 | <ARITH EXP> - <TERM>                     */        00001200
                                                                                00001250
 /*      9   <TERM> ::= <PRODUCT>                                     */        00001300
 /*     10            | <PRODUCT> / <TERM>                            */        00001350
                                                                                00001400
 /*     11   <PRODUCT> ::= <FACTOR>                                   */        00001450
 /*     12               | <FACTOR> * <PRODUCT>                       */        00001500
 /*     13               | <FACTOR> . <PRODUCT>                       */        00001550
 /*     14               | <FACTOR> <PRODUCT>                         */        00001600
                                                                                00001650
 /*     15   <FACTOR> ::= <PRIMARY>                                   */        00001700
 /*     16              | <PRIMARY> <**> <FACTOR>                     */        00001750
                                                                                00001800
 /*     17   <**> ::= **                                              */        00001850
                                                                                00001900
 /*     18   <PRE PRIMARY> ::= ( <ARITH EXP> )                        */        00001950
 /*     19                   | <NUMBER>                               */        00002000
 /*     20                   | <COMPOUND NUMBER>                      */        00002050
                                                                                00002100
 /*     21   <ARITH FUNC HEAD> ::= <ARITH FUNC>                       */        00002150
 /*     22                       | <ARITH CONV> <SUBSCRIPT>           */        00002200
                                                                                00002250
 /*     23   <ARITH CONV> ::= INTEGER                                 */        00002300
 /*     24                  | SCALAR                                  */        00002350
 /*     25                  | VECTOR                                  */        00002400
 /*     26                  | MATRIX                                  */        00002450
                                                                                00002500
 /*     27   <PRIMARY> ::= <ARITH VAR>                                */        00002550
                                                                                00002600
 /*     28   <PRE PRIMARY> ::= <ARITH FUNC HEAD> ( <CALL LIST> )      */        00002650
                                                                                00002700
 /*     29   <PRIMARY> ::= <MODIFIED ARITH FUNC>                      */        00002750
 /*     30               | <ARITH INLINE DEF> <BLOCK BODY>            */        00002800
 /*     30                 <CLOSING> ;                                */        00002850
 /*     31               | <PRE PRIMARY>                              */        00002900
 /*     32               | <PRE PRIMARY> <QUALIFIER>                  */        00002950
                                                                                00003000
 /*     33   <OTHER STATEMENT> ::= <ON PHRASE> <STATEMENT>            */        00003050
 /*     34                       | <IF STATEMENT>                     */        00003100
 /*     35                       | <LABEL DEFINITION>                 */        00003150
 /*     35                         <OTHER STATEMENT>                  */        00003200
                                                                                00003250
 /*     36   <STATEMENT> ::= <BASIC STATEMENT>                        */        00003300
 /*     37                 | <OTHER STATEMENT>                        */        00003350
                                                                                00003400
 /*     38   <ANY STATEMENT> ::= <STATEMENT>                          */        00003450
 /*     39                     | <BLOCK DEFINITION>                   */        00003500
                                                                                00003550
 /*     40   <BASIC STATEMENT> ::= <LABEL DEFINITION>                 */        00003600
 /*     40                         <BASIC STATEMENT>                  */        00003650
 /*     41                       | <ASSIGNMENT> ;                     */        00003700
 /*     42                       | EXIT ;                             */        00003750
 /*     43                       | EXIT <LABEL> ;                     */        00003800
 /*     44                       | REPEAT ;                           */        00003850
 /*     45                       | REPEAT <LABEL> ;                   */        00003900
 /*     46                       | GO TO <LABEL> ;                    */        00003950
 /*     47                       | ;                                  */        00004000
 /*     48                       | <CALL KEY> ;                       */        00004050
 /*     49                       | <CALL KEY> ( <CALL LIST> ) ;       */        00004100
 /*     50                       | <CALL KEY> <ASSIGN> (              */        00004150
 /*     50                         <CALL ASSIGN LIST> ) ;             */        00004200
 /*     51                       | <CALL KEY> ( <CALL LIST> )         */        00004250
 /*     51                         <ASSIGN> ( <CALL ASSIGN LIST> )    */        00004300
 /*     51                         ;                                  */        00004350
 /*     52                       | RETURN ;                           */        00004400
 /*     53                       | RETURN <EXPRESSION> ;              */        00004450
 /*     54                       | <DO GROUP HEAD> <ENDING> ;         */        00004500
 /*     55                       | <READ KEY> ;                       */        00004550
 /*     56                       | <READ PHRASE> ;                    */        00004600
 /*     57                       | <WRITE KEY> ;                      */        00004650
 /*     58                       | <WRITE PHRASE> ;                   */        00004700
 /*     59                       | <FILE EXP> = <EXPRESSION> ;        */        00004750
 /*     60                       | <VARIABLE> = <FILE EXP> ;          */        00004800
 /*     61                       | <WAIT KEY> FOR DEPENDENT ;         */        00004850
 /*     62                       | <WAIT KEY> <ARITH EXP> ;           */        00004900
 /*     63                       | <WAIT KEY> UNTIL <ARITH EXP> ;     */        00004950
 /*     64                       | <WAIT KEY> FOR <BIT EXP> ;         */        00005000
 /*     65                       | <TERMINATOR> ;                     */        00005050
 /*     66                       | <TERMINATOR> <TERMINATE LIST> ;    */        00005100
 /*     67                       | UPDATE PRIORITY TO <ARITH EXP> ;   */        00005150
 /*     68                       | UPDATE PRIORITY <LABEL VAR> TO     */        00005200
 /*     68                         <ARITH EXP> ;                      */        00005250
 /*     69                       | <SCHEDULE PHRASE> ;                */        00005300
 /*     70                       | <SCHEDULE PHRASE>                  */        00005350
 /*     70                         <SCHEDULE CONTROL> ;               */        00005400
 /*     71                       | <SIGNAL CLAUSE> ;                  */        00005450
 /*     72                       | SEND ERROR <SUBSCRIPT> ;           */        00005500
 /*     73                       | <ON CLAUSE> ;                      */        00005550
 /*     74                       | <ON CLAUSE> AND <SIGNAL CLAUSE>    */        00005600
 /*     74                         ;                                  */        00005650
 /*     75                       | OFF ERROR <SUBSCRIPT> ;            */        00005700
 /*     76                       | <% MACRO NAME> ;                   */        00005750
 /*     77                       | <% MACRO HEAD> <% MACRO ARG> ) ;   */        00005800
                                                                                00005850
 /*     78   <% MACRO HEAD> ::= <% MACRO NAME> (                      */        00005900
 /*     79                    | <% MACRO HEAD> <% MACRO ARG> ,        */        00005950
                                                                                00006000
 /*     80   <% MACRO ARG> ::= <NAME VAR>                             */        00006050
 /*     81                   | <CONSTANT>                             */        00006100
                                                                                00006150
 /*     82   <BIT PRIM> ::= <BIT VAR>                                 */        00006200
 /*     83                | <LABEL VAR>                               */        00006250
 /*     84                | <EVENT VAR>                               */        00006300
 /*     85                | <BIT CONST>                               */        00006350
 /*     86                | ( <BIT EXP> )                             */        00006400
 /*     87                | <MODIFIED BIT FUNC>                       */        00006450
 /*     88                | <BIT INLINE DEF> <BLOCK BODY> <CLOSING>   */        00006500
 /*     88                  ;                                         */        00006550
 /*     89                | <SUBBIT HEAD> <EXPRESSION> )              */        00006600
 /*     90                | <BIT FUNC HEAD> ( <CALL LIST> )           */        00006650
                                                                                00006700
 /*     91   <BIT FUNC HEAD> ::= <BIT FUNC>                           */        00006750
 /*     92                     | BIT <SUB OR QUALIFIER>               */        00006800
                                                                                00006850
 /*     93   <BIT CAT> ::= <BIT PRIM>                                 */        00006900
 /*     94               | <BIT CAT> <CAT> <BIT PRIM>                 */        00006950
 /*     95               | <NOT> <BIT PRIM>                           */        00007000
 /*     96               | <BIT CAT> <CAT> <NOT> <BIT PRIM>           */        00007050
                                                                                00007100
 /*     97   <BIT FACTOR> ::= <BIT CAT>                               */        00007150
 /*     98                  | <BIT FACTOR> <AND> <BIT CAT>            */        00007200
                                                                                00007250
 /*     99   <BIT EXP> ::= <BIT FACTOR>                               */        00007300
 /*    100               | <BIT EXP> <OR> <BIT FACTOR>                */        00007350
                                                                                00007400
 /*    101   <RELATIONAL OP> ::= =                                    */        00007450
 /*    102                     | <NOT> =                              */        00007500
 /*    103                     | <                                    */        00007550
 /*    104                     | >                                    */        00007600
 /*    105                     | < =                                  */        00007650
 /*    106                     | > =                                  */        00007700
 /*    107                     | <NOT> <                              */        00007750
 /*    108                     | <NOT> >                              */        00007800
                                                                                00007850
 /*    109   <COMPARISON> ::= <ARITH EXP> <RELATIONAL OP>             */        00007900
 /*    109                    <ARITH EXP>                             */        00007950
 /*    110                  | <CHAR EXP> <RELATIONAL OP> <CHAR EXP>   */        00008000
 /*    111                  | <BIT CAT> <RELATIONAL OP> <BIT CAT>     */        00008050
 /*    112                  | <STRUCTURE EXP> <RELATIONAL OP>         */        00008100
 /*    112                    <STRUCTURE EXP>                         */        00008150
 /*    113                  | <NAME EXP> <RELATIONAL OP> <NAME EXP>   */        00008200
                                                                                00008250
 /*    114   <RELATIONAL FACTOR> ::= <REL PRIM>                       */        00008300
 /*    115                         | <RELATIONAL FACTOR> <AND>        */        00008350
 /*    115                           <REL PRIM>                       */        00008400
                                                                                00008450
 /*    116   <RELATIONAL EXP> ::= <RELATIONAL FACTOR>                 */        00008500
 /*    117                      | <RELATIONAL EXP> <OR>               */        00008550
 /*    117                        <RELATIONAL FACTOR>                 */        00008600
                                                                                00008650
 /*    118   <REL PRIM> ::= ( <RELATIONAL EXP> )                      */        00008700
 /*    119                | <NOT> ( <RELATIONAL EXP> )                */        00008750
 /*    120                | <COMPARISON>                              */        00008800
                                                                                00008850
 /*    121   <CHAR PRIM> ::= <CHAR VAR>                               */        00008900
 /*    122                 | <CHAR CONST>                             */        00008950
 /*    123                 | <MODIFIED CHAR FUNC>                     */        00009000
 /*    124                 | <CHAR INLINE DEF> <BLOCK BODY>           */        00009050
 /*    124                   <CLOSING> ;                              */        00009100
 /*    125                 | <CHAR FUNC HEAD> ( <CALL LIST> )         */        00009150
 /*    126                 | ( <CHAR EXP> )                           */        00009200
                                                                                00009250
 /*    127   <CHAR FUNC HEAD> ::= <CHAR FUNC>                         */        00009300
 /*    128                      | CHARACTER <SUB OR QUALIFIER>        */        00009350
                                                                                00009400
 /*    129   <SUB OR QUALIFIER> ::= <SUBSCRIPT>                       */        00009450
 /*    130                        | <BIT QUALIFIER>                   */        00009500
                                                                                00009550
 /*    131   <CHAR EXP> ::= <CHAR PRIM>                               */        00009600
 /*    132                | <CHAR EXP> <CAT> <CHAR PRIM>              */        00009650
 /*    133                | <CHAR EXP> <CAT> <ARITH EXP>              */        00009700
 /*    134                | <ARITH EXP> <CAT> <ARITH EXP>             */        00009750
 /*    135                | <ARITH EXP> <CAT> <CHAR PRIM>             */        00009800
                                                                                00009850
 /*    136   <ASSIGNMENT> ::= <VARIABLE> <=1> <EXPRESSION>            */        00009900
 /*    137                  | <VARIABLE> , <ASSIGNMENT>               */        00009950
                                                                                00010000
 /*    138   <IF STATEMENT> ::= <IF CLAUSE> <STATEMENT>               */        00010050
 /*    139                    | <TRUE PART> <STATEMENT>               */        00010100
                                                                                00010150
 /*    140   <TRUE PART> ::= <IF CLAUSE> <BASIC STATEMENT> ELSE       */        00010200
                                                                                00010250
 /*    141   <IF CLAUSE> ::= <IF> <RELATIONAL EXP> THEN               */        00010300
 /*    142                 | <IF> <BIT EXP> THEN                      */        00010350
                                                                                00010400
 /*    143   <IF> ::= IF                                              */        00010450
                                                                                00010500
 /*    144   <DO GROUP HEAD> ::= DO ;                                 */        00010550
 /*    145                     | DO <FOR LIST> ;                      */        00010600
 /*    146                     | DO <FOR LIST> <WHILE CLAUSE> ;       */        00010650
 /*    147                     | DO <WHILE CLAUSE> ;                  */        00010700
 /*    148                     | DO CASE <ARITH EXP> ;                */        00010750
 /*    149                     | <CASE ELSE> <STATEMENT>              */        00010800
 /*    150                     | <DO GROUP HEAD> <ANY STATEMENT>      */        00010850
 /*    151                     | <DO GROUP HEAD> <TEMPORARY STMT>     */        00010900
                                                                                00010950
 /*    152   <CASE ELSE> ::= DO CASE <ARITH EXP> ; ELSE               */        00011000
                                                                                00011050
 /*    153   <WHILE KEY> ::= WHILE                                    */        00011100
 /*    154                 | UNTIL                                    */        00011150
                                                                                00011200
 /*    155   <WHILE CLAUSE> ::= <WHILE KEY> <BIT EXP>                 */        00011250
 /*    156                    | <WHILE KEY> <RELATIONAL EXP>          */        00011300
                                                                                00011350
 /*    157   <FOR LIST> ::= <FOR KEY> <ARITH EXP>                     */        00011400
 /*    157                  <ITERATION CONTROL>                       */        00011450
 /*    158                | <FOR KEY> <ITERATION BODY>                */        00011500
                                                                                00011550
 /*    159   <ITERATION BODY> ::= <ARITH EXP>                         */        00011600
 /*    160                      | <ITERATION BODY> , <ARITH EXP>      */        00011650
                                                                                00011700
 /*    161   <ITERATION CONTROL> ::= TO <ARITH EXP>                   */        00011750
 /*    162                         | TO <ARITH EXP> BY <ARITH EXP>    */        00011800
                                                                                00011850
 /*    163   <FOR KEY> ::= FOR <ARITH VAR> =                          */        00011900
 /*    164               | FOR TEMPORARY <IDENTIFIER> =               */        00011950
                                                                                00012000
 /*    165   <ENDING> ::= END                                         */        00012050
 /*    166              | END <LABEL>                                 */        00012100
 /*    167              | <LABEL DEFINITION> <ENDING>                 */        00012150
                                                                                00012200
 /*    168   <ON PHRASE> ::= ON ERROR <SUBSCRIPT>                     */        00012250
                                                                                00012300
 /*    169   <ON CLAUSE> ::= ON ERROR <SUBSCRIPT> SYSTEM              */        00012350
 /*    170                 | ON ERROR <SUBSCRIPT> IGNORE              */        00012400
                                                                                00012450
 /*    171   <SIGNAL CLAUSE> ::= SET <EVENT VAR>                      */        00012500
 /*    172                     | RESET <EVENT VAR>                    */        00012550
 /*    173                     | SIGNAL <EVENT VAR>                   */        00012600
                                                                                00012650
 /*    174   <FILE EXP> ::= <FILE HEAD> , <ARITH EXP> )               */        00012700
                                                                                00012750
 /*    175   <FILE HEAD> ::= FILE ( <NUMBER>                          */        00012800
                                                                                00012850
 /*    176   <CALL KEY> ::= CALL <LABEL VAR>                          */        00012900
                                                                                00012950
 /*    177   <CALL LIST> ::= <LIST EXP>                               */        00013000
 /*    178                 | <CALL LIST> , <LIST EXP>                 */        00013050
                                                                                00013100
 /*    179   <CALL ASSIGN LIST> ::= <VARIABLE>                        */        00013150
 /*    180                        | <CALL ASSIGN LIST> , <VARIABLE>   */        00013200
                                                                                00013250
 /*    181   <EXPRESSION> ::= <ARITH EXP>                             */        00013300
 /*    182                  | <BIT EXP>                               */        00013350
 /*    183                  | <CHAR EXP>                              */        00013400
 /*    184                  | <STRUCTURE EXP>                         */        00013450
 /*    185                  | <NAME EXP>                              */        00013500
                                                                                00013550
 /*    186   <STRUCTURE EXP> ::= <STRUCTURE VAR>                      */        00013600
 /*    187                     | <MODIFIED STRUCT FUNC>               */        00013650
 /*    188                     | <STRUC INLINE DEF> <BLOCK BODY>      */        00013700
 /*    188                       <CLOSING> ;                          */        00013750
 /*    189                     | <STRUCT FUNC HEAD> ( <CALL LIST> )   */        00013800
                                                                                00013850
 /*    190   <STRUCT FUNC HEAD> ::= <STRUCT FUNC>                     */        00013900
                                                                                00013950
 /*    191   <LIST EXP> ::= <EXPRESSION>                              */        00014000
 /*    192                | <ARITH EXP> # <EXPRESSION>                */        00014050
                                                                                00014100
 /*    193   <VARIABLE> ::= <ARITH VAR>                               */        00014150
 /*    194                | <STRUCTURE VAR>                           */        00014200
 /*    195                | <BIT VAR>                                 */        00014250
 /*    196                | <EVENT VAR>                               */        00014300
 /*    197                | <SUBBIT HEAD> <VARIABLE> )                */        00014350
 /*    198                | <CHAR VAR>                                */        00014400
 /*    199                | <NAME KEY> ( <NAME VAR> )                 */        00014450
                                                                                00014500
 /*    200   <NAME VAR> ::= <VARIABLE>                                */        00014550
 /*    201                | <LABEL VAR>                               */        00014600
 /*    202                | <MODIFIED ARITH FUNC>                     */        00014650
 /*    203                | <MODIFIED BIT FUNC>                       */        00014700
 /*    204                | <MODIFIED CHAR FUNC>                      */        00014750
 /*    205                | <MODIFIED STRUCT FUNC>                    */        00014800
                                                                                00014850
 /*    206   <NAME EXP> ::= <NAME KEY> ( <NAME VAR> )                 */        00014900
 /*    207                | NULL                                      */        00014950
 /*    208                | <NAME KEY> ( NULL )                       */        00015000
                                                                                00015050
 /*    209   <NAME KEY> ::= NAME                                      */        00015100
                                                                                00015150
 /*    210   <LABEL VAR> ::= <PREFIX> <LABEL> <SUBSCRIPT>             */        00015200
                                                                                00015250
 /*    211   <MODIFIED ARITH FUNC> ::= <PREFIX> <NO ARG ARITH FUNC>   */        00015300
 /*    211                             <SUBSCRIPT>                    */        00015350
                                                                                00015400
 /*    212   <MODIFIED BIT FUNC> ::= <PREFIX> <NO ARG BIT FUNC>       */        00015450
 /*    212                           <SUBSCRIPT>                      */        00015500
                                                                                00015550
 /*    213   <MODIFIED CHAR FUNC> ::= <PREFIX> <NO ARG CHAR FUNC>     */        00015600
 /*    213                            <SUBSCRIPT>                     */        00015650
                                                                                00015700
 /*    214   <MODIFIED STRUCT FUNC> ::= <PREFIX>                      */        00015750
 /*    214                              <NO ARG STRUCT FUNC>          */        00015800
 /*    214                              <SUBSCRIPT>                   */        00015850
                                                                                00015900
 /*    215   <STRUCTURE VAR> ::= <QUAL STRUCT> <SUBSCRIPT>            */        00015950
                                                                                00016000
 /*    216   <ARITH VAR> ::= <PREFIX> <ARITH ID> <SUBSCRIPT>          */        00016050
                                                                                00016100
 /*    217   <CHAR VAR> ::= <PREFIX> <CHAR ID> <SUBSCRIPT>            */        00016150
                                                                                00016200
 /*    218   <BIT VAR> ::= <PREFIX> <BIT ID> <SUBSCRIPT>              */        00016250
                                                                                00016300
 /*    219   <EVENT VAR> ::= <PREFIX> <EVENT ID> <SUBSCRIPT>          */        00016350
                                                                                00016400
 /*    220   <QUAL STRUCT> ::= <STRUCTURE ID>                         */        00016450
 /*    221                   | <QUAL STRUCT> . <STRUCTURE ID>         */        00016500
                                                                                00016550
 /*    222   <PREFIX> ::=                                             */        00016600
 /*    223              | <QUAL STRUCT> .                             */        00016650
                                                                                00016700
 /*    224   <SUBBIT HEAD> ::= <SUBBIT KEY> <SUBSCRIPT> (             */        00016750
                                                                                00016800
 /*    225   <SUBBIT KEY> ::= SUBBIT                                  */        00016850
                                                                                00016900
 /*    226   <SUBSCRIPT> ::= <SUB HEAD> )                             */        00016950
 /*    227                 | <QUALIFIER>                              */        00017000
 /*    228                 | <$> <NUMBER>                             */        00017050
 /*    229                 | <$> <ARITH VAR>                          */        00017100
 /*    230                 |                                          */        00017150
                                                                                00017200
 /*    231   <SUB START> ::= <$> (                                    */        00017250
 /*    232                 | <$> ( @ <PREC SPEC> ,                    */        00017300
 /*    233                 | <SUB HEAD> ;                             */        00017350
 /*    234                 | <SUB HEAD> :                             */        00017400
 /*    235                 | <SUB HEAD> ,                             */        00017450
                                                                                00017500
 /*    236   <SUB HEAD> ::= <SUB START>                               */        00017550
 /*    237                | <SUB START> <SUB>                         */        00017600
                                                                                00017650
 /*    238   <SUB> ::= <SUB EXP>                                      */        00017700
 /*    239           | *                                              */        00017750
 /*    240           | <SUB RUN HEAD> <SUB EXP>                       */        00017800
 /*    241           | <ARITH EXP> AT <SUB EXP>                       */        00017850
                                                                                00017900
 /*    242   <SUB RUN HEAD> ::= <SUB EXP> TO                          */        00017950
                                                                                00018000
 /*    243   <SUB EXP> ::= <ARITH EXP>                                */        00018050
 /*    244               | <# EXPRESSION>                             */        00018100
                                                                                00018150
 /*    245   <# EXPRESSION> ::= #                                     */        00018200
 /*    246                    | <# EXPRESSION> + <TERM>               */        00018250
 /*    247                    | <# EXPRESSION> - <TERM>               */        00018300
                                                                                00018350
 /*    248   <=1> ::= =                                               */        00018400
                                                                                00018450
 /*    249   <$> ::= $                                                */        00018500
                                                                                00018550
 /*    250   <AND> ::= &                                              */        00018600
 /*    251           | AND                                            */        00018650
                                                                                00018700
 /*    252   <OR> ::= |                                               */        00018750
 /*    253          | OR                                              */        00018800
                                                                                00018850
 /*    254   <NOT> ::= ^                                              */        00018900
 /*    255           | NOT                                            */        00018950
                                                                                00019000
 /*    256   <CAT> ::= ||                                             */        00019050
 /*    257           | CAT                                            */        00019100
                                                                                00019150
 /*    258   <QUALIFIER> ::= <$> ( @ <PREC SPEC> )                    */        00019200
 /*    259                 | <$> ( <SCALE HEAD> <ARITH EXP> )         */        00019250
 /*    260                 | <$> ( @ <PREC SPEC> , <SCALE HEAD>       */        00019300
 /*    260                   <ARITH EXP> )                            */        00019350
                                                                                00019400
 /*    261   <SCALE HEAD> ::= @                                       */        00019450
 /*    262                  | @ @                                     */        00019500
                                                                                00019550
 /*    263   <BIT QUALIFIER> ::= <$> ( @ <RADIX> )                    */        00019600
                                                                                00019650
 /*    264   <RADIX> ::= HEX                                          */        00019700
 /*    265             | OCT                                          */        00019750
 /*    266             | BIN                                          */        00019800
 /*    267             | DEC                                          */        00019850
                                                                                00019900
 /*    268   <BIT CONST HEAD> ::= <RADIX>                             */        00019950
 /*    269                      | <RADIX> ( <NUMBER> )                */        00020000
                                                                                00020050
 /*    270   <BIT CONST> ::= <BIT CONST HEAD> <CHAR STRING>           */        00020100
 /*    271                 | TRUE                                     */        00020150
 /*    272                 | FALSE                                    */        00020200
 /*    273                 | ON                                       */        00020250
 /*    274                 | OFF                                      */        00020300
                                                                                00020350
 /*    275   <CHAR CONST> ::= <CHAR STRING>                           */        00020400
 /*    276                  | CHAR ( <NUMBER> ) <CHAR STRING>         */        00020450
                                                                                00020500
 /*    277   <IO CONTROL> ::= SKIP ( <ARITH EXP> )                    */        00020550
 /*    278                  | TAB ( <ARITH EXP> )                     */        00020600
 /*    279                  | COLUMN ( <ARITH EXP> )                  */        00020650
 /*    280                  | LINE ( <ARITH EXP> )                    */        00020700
 /*    281                  | PAGE ( <ARITH EXP> )                    */        00020750
                                                                                00020800
 /*    282   <READ PHRASE> ::= <READ KEY> <READ ARG>                  */        00020850
 /*    283                   | <READ PHRASE> , <READ ARG>             */        00020900
                                                                                00020950
 /*    284   <WRITE PHRASE> ::= <WRITE KEY> <WRITE ARG>               */        00021000
 /*    285                    | <WRITE PHRASE> , <WRITE ARG>          */        00021050
                                                                                00021100
 /*    286   <READ ARG> ::= <VARIABLE>                                */        00021150
 /*    287                | <IO CONTROL>                              */        00021200
                                                                                00021250
 /*    288   <WRITE ARG> ::= <EXPRESSION>                             */        00021300
 /*    289                 | <IO CONTROL>                             */        00021350
                                                                                00021400
 /*    290   <READ KEY> ::= READ ( <NUMBER> )                         */        00021450
 /*    291                | READALL ( <NUMBER> )                      */        00021500
                                                                                00021550
 /*    292   <WRITE KEY> ::= WRITE ( <NUMBER> )                       */        00021600
                                                                                00021650
 /*    293   <BLOCK DEFINITION> ::= <BLOCK STMT> <BLOCK BODY>         */        00021700
 /*    293                          <CLOSING> ;                       */        00021750
                                                                                00021800
 /*    294   <BLOCK BODY> ::=                                         */        00021850
 /*    295                  | <DECLARE GROUP>                         */        00021900
 /*    296                  | <BLOCK BODY> <ANY STATEMENT>            */        00021950
                                                                                00022000
 /*    297   <ARITH INLINE DEF> ::= FUNCTION <ARITH SPEC> ;           */        00022050
 /*    298                        | FUNCTION ;                        */        00022100
                                                                                00022150
 /*    299   <BIT INLINE DEF> ::= FUNCTION <BIT SPEC> ;               */        00022200
                                                                                00022250
 /*    300   <CHAR INLINE DEF> ::= FUNCTION <CHAR SPEC> ;             */        00022300
                                                                                00022350
 /*    301   <STRUC INLINE DEF> ::= FUNCTION <STRUCT SPEC> ;          */        00022400
                                                                                00022450
 /*    302   <BLOCK STMT> ::= <BLOCK STMT TOP> ;                      */        00022500
                                                                                00022550
 /*    303   <BLOCK STMT TOP> ::= <BLOCK STMT TOP> ACCESS             */        00022600
 /*    304                      | <BLOCK STMT TOP> RIGID              */        00022650
 /*    305                      | <BLOCK STMT HEAD>                   */        00022700
 /*    306                      | <BLOCK STMT HEAD> EXCLUSIVE         */        00022750
 /*    307                      | <BLOCK STMT HEAD> REENTRANT         */        00022800
                                                                                00022850
 /*    308   <LABEL DEFINITION> ::= <LABEL> :                         */        00022900
                                                                                00022950
 /*    309   <LABEL EXTERNAL> ::= <LABEL DEFINITION>                  */        00023000
 /*    310                      | <LABEL DEFINITION> EXTERNAL         */        00023050
                                                                                00023100
 /*    311   <BLOCK STMT HEAD> ::= <LABEL EXTERNAL> PROGRAM           */        00023150
 /*    312                       | <LABEL EXTERNAL> COMPOOL           */        00023200
 /*    313                       | <LABEL DEFINITION> TASK            */        00023250
 /*    314                       | <LABEL DEFINITION> UPDATE          */        00023300
 /*    315                       | UPDATE                             */        00023350
 /*    316                       | <FUNCTION NAME>                    */        00023400
 /*    317                       | <FUNCTION NAME> <FUNC STMT BODY>   */        00023450
 /*    318                       | <PROCEDURE NAME>                   */        00023500
 /*    319                       | <PROCEDURE NAME>                   */        00023550
 /*    319                         <PROC STMT BODY>                   */        00023600
                                                                                00023650
 /*    320   <FUNCTION NAME> ::= <LABEL EXTERNAL> FUNCTION            */        00023700
                                                                                00023750
 /*    321   <PROCEDURE NAME> ::= <LABEL EXTERNAL> PROCEDURE          */        00023800
                                                                                00023850
 /*    322   <FUNC STMT BODY> ::= <PARAMETER LIST>                    */        00023900
 /*    323                      | <TYPE SPEC>                         */        00023950
 /*    324                      | <PARAMETER LIST> <TYPE SPEC>        */        00024000
                                                                                00024050
 /*    325   <PROC STMT BODY> ::= <PARAMETER LIST>                    */        00024100
 /*    326                      | <ASSIGN LIST>                       */        00024150
 /*    327                      | <PARAMETER LIST> <ASSIGN LIST>      */        00024200
                                                                                00024250
 /*    328   <PARAMETER LIST> ::= <PARAMETER HEAD> <IDENTIFIER> )     */        00024300
                                                                                00024350
 /*    329   <PARAMETER HEAD> ::= (                                   */        00024400
 /*    330                      | <PARAMETER HEAD> <IDENTIFIER> ,     */        00024450
                                                                                00024500
 /*    331   <ASSIGN LIST> ::= <ASSIGN> <PARAMETER LIST>              */        00024550
                                                                                00024600
 /*    332   <ASSIGN> ::= ASSIGN                                      */        00024650
                                                                                00024700
 /*    333   <DECLARE ELEMENT> ::= <DECLARE STATEMENT>                */        00024750
 /*    334                       | <REPLACE STMT> ;                   */        00024800
 /*    335                       | <STRUCTURE STMT>                   */        00024850
 /*    336                       | EQUATE EXTERNAL <IDENTIFIER> TO    */        00024900
 /*    336                         <VARIABLE> ;                       */        00024950
                                                                                00025000
 /*    337   <REPLACE STMT> ::= REPLACE <REPLACE HEAD> BY <TEXT>      */        00025050
                                                                                00025100
 /*    338   <REPLACE HEAD> ::= <IDENTIFIER>                          */        00025150
 /*    339                    | <IDENTIFIER> ( <ARG LIST> )           */        00025200
                                                                                00025250
 /*    340   <ARG LIST> ::= <IDENTIFIER>                              */        00025300
 /*    341                | <ARG LIST> , <IDENTIFIER>                 */        00025350
                                                                                00025400
 /*    342   <TEMPORARY STMT> ::= TEMPORARY <DECLARE BODY> ;          */        00025450
                                                                                00025500
 /*    343   <DECLARE STATEMENT> ::= DECLARE <DECLARE BODY> ;         */        00025550
                                                                                00025600
 /*    344   <DECLARE BODY> ::= <DECLARATION LIST>                    */        00025650
 /*    345                    | <ATTRIBUTES> , <DECLARATION LIST>     */        00025700
                                                                                00025750
 /*    346   <DECLARATION LIST> ::= <DECLARATION>                     */        00025800
 /*    347                        | <DCL LIST ,> <DECLARATION>        */        00025850
                                                                                00025900
 /*    348   <DCL LIST ,> ::= <DECLARATION LIST> ,                    */        00025950
                                                                                00026000
 /*    349   <DECLARE GROUP> ::= <DECLARE ELEMENT>                    */        00026050
 /*    350                     | <DECLARE GROUP> <DECLARE ELEMENT>    */        00026100
                                                                                00026150
 /*    351   <STRUCTURE STMT> ::= STRUCTURE <STRUCT STMT HEAD>        */        00026200
 /*    351                        <STRUCT STMT TAIL>                  */        00026250
                                                                                00026300
 /*    352   <STRUCT STMT HEAD> ::= <IDENTIFIER> : <LEVEL>            */        00026350
 /*    353                        | <IDENTIFIER> <MINOR ATTR LIST>    */        00026400
 /*    353                          : <LEVEL>                         */        00026450
 /*    354                        | <STRUCT STMT HEAD>                */        00026500
 /*    354                          <DECLARATION> , <LEVEL>           */        00026550
                                                                                00026600
 /*    355   <STRUCT STMT TAIL> ::= <DECLARATION> ;                   */        00026650
                                                                                00026700
 /*    356   <STRUCT SPEC> ::= <STRUCT TEMPLATE> <STRUCT SPEC BODY>   */        00026750
                                                                                00026800
 /*    357   <STRUCT SPEC BODY> ::= - STRUCTURE                       */        00026850
 /*    358                        | <STRUCT SPEC HEAD>                */        00026900
 /*    358                          <LITERAL EXP OR *> )              */        00026950
                                                                                00027000
 /*    359   <STRUCT SPEC HEAD> ::= - STRUCTURE (                     */        00027050
                                                                                00027100
 /*    360   <DECLARATION> ::= <NAME ID>                              */        00027150
 /*    361                   | <NAME ID> <ATTRIBUTES>                 */        00027200
                                                                                00027250
 /*    362   <NAME ID> ::= <IDENTIFIER>                               */        00027300
 /*    363               | <IDENTIFIER> NAME                          */        00027350
                                                                                00027400
 /*    364   <ATTRIBUTES> ::= <ARRAY SPEC> <TYPE & MINOR ATTR>        */        00027450
 /*    365                  | <ARRAY SPEC>                            */        00027500
 /*    366                  | <TYPE & MINOR ATTR>                     */        00027550
                                                                                00027600
 /*    367   <ARRAY SPEC> ::= <ARRAY HEAD> <LITERAL EXP OR *> )       */        00027650
 /*    368                  | FUNCTION                                */        00027700
 /*    369                  | PROCEDURE                               */        00027750
 /*    370                  | PROGRAM                                 */        00027800
 /*    371                  | TASK                                    */        00027850
                                                                                00027900
 /*    372   <ARRAY HEAD> ::= ARRAY (                                 */        00027950
 /*    373                  | <ARRAY HEAD> <LITERAL EXP OR *> ,       */        00028000
                                                                                00028050
 /*    374   <TYPE & MINOR ATTR> ::= <TYPE SPEC>                      */        00028100
 /*    375                         | <TYPE SPEC> <MINOR ATTR LIST>    */        00028150
 /*    376                         | <MINOR ATTR LIST>                */        00028200
                                                                                00028250
 /*    377   <TYPE SPEC> ::= <STRUCT SPEC>                            */        00028300
 /*    378                 | <BIT SPEC>                               */        00028350
 /*    379                 | <CHAR SPEC>                              */        00028400
 /*    380                 | <ARITH SPEC>                             */        00028450
 /*    381                 | EVENT                                    */        00028500
                                                                                00028550
 /*    382   <BIT SPEC> ::= BOOLEAN                                   */        00028600
 /*    383                | BIT ( <LITERAL EXP OR *> )                */        00028650
                                                                                00028700
 /*    384   <CHAR SPEC> ::= CHARACTER ( <LITERAL EXP OR *> )         */        00028750
                                                                                00028800
 /*    385   <ARITH SPEC> ::= <PREC SPEC>                             */        00028850
 /*    386                  | <SQ DQ NAME>                            */        00028900
 /*    387                  | <SQ DQ NAME> <PREC SPEC>                */        00028950
                                                                                00029000
 /*    388   <SQ DQ NAME> ::= <DOUBLY QUAL NAME HEAD>                 */        00029050
 /*    388                    <LITERAL EXP OR *> )                    */        00029100
 /*    389                  | INTEGER                                 */        00029150
 /*    390                  | SCALAR                                  */        00029200
 /*    391                  | VECTOR                                  */        00029250
 /*    392                  | MATRIX                                  */        00029300
                                                                                00029350
 /*    393   <DOUBLY QUAL NAME HEAD> ::= VECTOR (                     */        00029400
 /*    394                             | MATRIX (                     */        00029450
 /*    394                               <LITERAL EXP OR *> ,         */        00029500
                                                                                00029550
 /*    395   <LITERAL EXP OR *> ::= <ARITH EXP>                       */        00029600
 /*    396                        | *                                 */        00029650
                                                                                00029700
 /*    397   <PREC SPEC> ::= SINGLE                                   */        00029750
 /*    398                 | DOUBLE                                   */        00029800
                                                                                00029850
 /*    399   <MINOR ATTR LIST> ::= <MINOR ATTRIBUTE>                  */        00029900
 /*    400                       | <MINOR ATTR LIST>                  */        00029950
 /*    400                         <MINOR ATTRIBUTE>                  */        00030000
                                                                                00030050
 /*    401   <MINOR ATTRIBUTE> ::= STATIC                             */        00030100
 /*    402                       | AUTOMATIC                          */        00030150
 /*    403                       | DENSE                              */        00030200
 /*    404                       | ALIGNED                            */        00030250
 /*    405                       | ACCESS                             */        00030300
 /*    406                       | LOCK ( <LITERAL EXP OR *> )        */        00030350
 /*    407                       | REMOTE                             */        00030400
 /*    408                       | RIGID                              */        00030450
 /*    409                       | <INIT/CONST HEAD>                  */        00030500
 /*    409                         <REPEATED CONSTANT> )              */        00030550
 /*    410                       | <INIT/CONST HEAD> * )              */        00030600
 /*    411                       | LATCHED                            */        00030650
 /*    412                       | NONHAL ( <LEVEL> )                 */        00030700
                                                                                00030750
 /*    413   <INIT/CONST HEAD> ::= INITIAL (                          */        00030800
 /*    414                       | CONSTANT (                         */        00030850
 /*    415                       | <INIT/CONST HEAD>                  */        00030900
 /*    415                         <REPEATED CONSTANT> ,              */        00030950
                                                                                00031000
 /*    416   <REPEATED CONSTANT> ::= <EXPRESSION>                     */        00031050
 /*    417                         | <REPEAT HEAD> <VARIABLE>         */        00031100
 /*    418                         | <REPEAT HEAD> <CONSTANT>         */        00031150
 /*    419                         | <NESTED REPEAT HEAD>             */        00031200
 /*    419                           <REPEATED CONSTANT> )            */        00031250
 /*    420                         | <REPEAT HEAD>                    */        00031300
                                                                                00031350
 /*    421   <REPEAT HEAD> ::= <ARITH EXP> #                          */        00031400
                                                                                00031450
 /*    422   <NESTED REPEAT HEAD> ::= <REPEAT HEAD> (                 */        00031500
 /*    423                          | <NESTED REPEAT HEAD>            */        00031550
 /*    423                            <REPEATED CONSTANT> ,           */        00031600
                                                                                00031650
 /*    424   <CONSTANT> ::= <NUMBER>                                  */        00031700
 /*    425                | <COMPOUND NUMBER>                         */        00031750
 /*    426                | <BIT CONST>                               */        00031800
 /*    427                | <CHAR CONST>                              */        00031850
                                                                                00031900
 /*    428   <NUMBER> ::= <SIMPLE NUMBER>                             */        00031950
 /*    429              | <LEVEL>                                     */        00032000
                                                                                00032050
 /*    430   <CLOSING> ::= CLOSE                                      */        00032100
 /*    431               | CLOSE <LABEL>                              */        00032150
 /*    432               | <LABEL DEFINITION> <CLOSING>               */        00032200
                                                                                00032250
 /*    433   <TERMINATOR> ::= TERMINATE                               */        00032300
 /*    434                  | CANCEL                                  */        00032350
                                                                                00032400
 /*    435   <TERMINATE LIST> ::= <LABEL VAR>                         */        00032450
 /*    436                      | <TERMINATE LIST> , <LABEL VAR>      */        00032500
                                                                                00032550
 /*    437   <WAIT KEY> ::= WAIT                                      */        00032600
                                                                                00032650
 /*    438   <SCHEDULE HEAD> ::= SCHEDULE <LABEL VAR>                 */        00032700
 /*    439                     | <SCHEDULE HEAD> AT <ARITH EXP>       */        00032750
 /*    440                     | <SCHEDULE HEAD> IN <ARITH EXP>       */        00032800
 /*    441                     | <SCHEDULE HEAD> ON <BIT EXP>         */        00032850
                                                                                00032900
 /*    442   <SCHEDULE PHRASE> ::= <SCHEDULE HEAD>                    */        00032950
 /*    443                       | <SCHEDULE HEAD> PRIORITY (         */        00033000
 /*    443                         <ARITH EXP> )                      */        00033050
 /*    444                       | <SCHEDULE PHRASE> DEPENDENT        */        00033100
                                                                                00033150
 /*    445   <SCHEDULE CONTROL> ::= <STOPPING>                        */        00033200
 /*    446                        | <TIMING>                          */        00033250
 /*    447                        | <TIMING> <STOPPING>               */        00033300
                                                                                00033350
 /*    448   <TIMING> ::= <REPEAT> EVERY <ARITH EXP>                  */        00033400
 /*    449              | <REPEAT> AFTER <ARITH EXP>                  */        00033450
 /*    450              | <REPEAT>                                    */        00033500
                                                                                00033550
 /*    451   <REPEAT> ::= , REPEAT                                    */        00033600
                                                                                00033650
 /*    452   <STOPPING> ::= <WHILE KEY> <ARITH EXP>                   */        00033700
 /*    453                | <WHILE KEY> <BIT EXP>                     */        00033750
                                                                                00033800
                                                                                00033850
                                                                                00033900
                                                                                00033950
 /*   THESE ARE LALR PARSING TABLES   */                                        00034000
                                                                                00034050
   DECLARE MAXR# LITERALLY '441'; /* MAX READ # */                              00034100
                                                                                00034150
   DECLARE MAXL# LITERALLY '666'; /* MAX LOOK # */                              00034200
                                                                                00034250
   DECLARE MAXP# LITERALLY '810'; /* MAX PUSH # */                              00034300
                                                                                00034350
   DECLARE MAXS# LITERALLY '1263'; /* MAX STATE # */                            00034400
                                                                                00034450
   DECLARE NT LITERALLY '142';                                                  00034600
                                                                                00034650
   DECLARE NSY LITERALLY '311';                                                 00034700
                                                                                00034750
   DECLARE VOCAB(11) CHARACTER INITIAL ('.<(+|&$*);^-/,>:#@=||**ATBYDOGOIFINONOR00034800
TO END_OF_FILEANDBINBITCATDECENDFORHEXNOTOCTOFFSETTABCALLCASECHARELSEEXITFILELIN00034850
ELOCKNAMENULLPAGEREADSENDSKIPTASKTHENTRUEWAITAFTERARRAYCLOSEDENSEERROREVENTEVERY00034900
FALSERESETRIGIDUNTILWHILEWRITE<TEXT>ACCESSASSIGNCANCEL','COLUMNDOUBLEEQUATEIGNOR00034950
EMATRIXNONHALREMOTEREPEATRETURNSCALARSIGNALSINGLESTATICSUBBITSYSTEMUPDATEVECTOR<00035000
EMPTY><LABEL><LEVEL>ALIGNEDBOOLEANCOMPOOLDECLAREINITIALINTEGERLATCHEDPROGRAMREAD00035050
ALLREPLACE<BIT ID>CONSTANTEXTERNALFUNCTIONPRIORITYSCHEDULE<CHAR ID>','AUTOMATICC00035100
HARACTERDEPENDENTEXCLUSIVEPROCEDUREREENTRANTSTRUCTURETEMPORARYTERMINATE<ARITH ID00035150
><BIT FUNC><EVENT ID><CHAR FUNC><ARITH FUNC><IDENTIFIER><CHAR STRING><STRUCT FUN00035200
C><% MACRO NAME><STRUCTURE ID><SIMPLE NUMBER><COMPOUND NUMBER><NO ARG BIT FUNC>'00035250
,'<STRUCT TEMPLATE><NO ARG CHAR FUNC><NO ARG ARITH FUNC><NO ARG STRUCT FUNC><$><00035300
**><=1><IF><OR><AND><CAT><NOT><SUB><TERM><RADIX><ASSIGN><ENDING><FACTOR><NUMBER>00035350
<PREFIX><REPEAT><TIMING><BIT CAT><BIT EXP><BIT VAR><CLOSING><FOR KEY><NAME ID><P00035400
RIMARY><PRODUCT>','<SUB EXP><ARG LIST><BIT PRIM><BIT SPEC><CALL KEY><CHAR EXP><C00035450
HAR VAR><CONSTANT><FILE EXP><FOR LIST><LIST EXP><NAME EXP><NAME KEY><NAME VAR><R00035500
EAD ARG><READ KEY><REL PRIM><STOPPING><SUB HEAD><VARIABLE><WAIT KEY><ARITH EXP><00035550
ARITH VAR><BIT CONST><CALL LIST>','<CASE ELSE><CHAR PRIM><CHAR SPEC><EVENT VAR><00035600
FILE HEAD><IF CLAUSE><LABEL VAR><ON CLAUSE><ON PHRASE><PREC SPEC><QUALIFIER><STA00035650
TEMENT><SUB START><SUBSCRIPT><TRUE PART><TYPE SPEC><WHILE KEY><WRITE ARG><WRITE 00035700
KEY><ARITH CONV><ARITH SPEC><ARRAY HEAD>','<ARRAY SPEC><ASSIGNMENT><ATTRIBUTES><00035750
BIT FACTOR><BLOCK BODY><BLOCK STMT><CHAR CONST><COMPARISON><DCL LIST ,><EXPRESSI00035800
ON><IO CONTROL><SCALE HEAD><SQ DQ NAME><SUBBIT KEY><TERMINATOR><% MACRO ARG><ASS00035850
IGN LIST><COMPILATION><DECLARATION><PRE PRIMARY>','<QUAL STRUCT><READ PHRASE><RE00035900
PEAT HEAD><STRUCT SPEC><SUBBIT HEAD><% MACRO HEAD><# EXPRESSION><COMPILE LIST><D00035950
ECLARE BODY><IF STATEMENT><REPLACE HEAD><REPLACE STMT><SUB RUN HEAD><WHILE CLAUS00036000
E><WRITE PHRASE><ANY STATEMENT><BIT FUNC HEAD><BIT QUALIFIER>','<DECLARE GROUP><00036050
DO GROUP HEAD><FUNCTION NAME><RELATIONAL OP><SCHEDULE HEAD><SIGNAL CLAUSE><STRUC00036100
TURE EXP><STRUCTURE VAR><BIT CONST HEAD><BIT INLINE DEF><BLOCK STMT TOP><CHAR FU00036150
NC HEAD><FUNC STMT BODY><ITERATION BODY><LABEL EXTERNAL><PARAMETER HEAD>','<PARA00036200
METER LIST><PROC STMT BODY><PROCEDURE NAME><RELATIONAL EXP><STRUCTURE STMT><TEMP00036250
ORARY STMT><TERMINATE LIST><ARITH FUNC HEAD><BASIC STATEMENT><BLOCK STMT HEAD><C00036300
HAR INLINE DEF><DECLARE ELEMENT><INIT/CONST HEAD><MINOR ATTR LIST><MINOR ATTRIBU00036350
TE>','<OTHER STATEMENT><SCHEDULE PHRASE><ARITH INLINE DEF><BLOCK DEFINITION><CAL00036400
L ASSIGN LIST><DECLARATION LIST><LABEL DEFINITION><LITERAL EXP OR *><SCHEDULE CO00036450
NTROL><STRUC INLINE DEF><STRUCT FUNC HEAD><STRUCT SPEC BODY><STRUCT SPEC HEAD><S00036500
TRUCT STMT HEAD>','<STRUCT STMT TAIL><SUB OR QUALIFIER><DECLARE STATEMENT><ITERA00036550
TION CONTROL><MODIFIED BIT FUNC><RELATIONAL FACTOR><REPEATED CONSTANT><TYPE & MI00036600
NOR ATTR><MODIFIED CHAR FUNC><NESTED REPEAT HEAD><MODIFIED ARITH FUNC><MODIFIED 00036650
STRUCT FUNC><DOUBLY QUAL NAME HEAD>');                                          00036700
   ARRAY VOCAB_INDEX(NSY) FIXED INITIAL ( 0, 16777216, 16777472, 16777728,      00036750
      16777984, 16778240, 16778496, 16778752, 16779008, 16779264, 16779520,     00036800
      16779776, 16780032, 16780288, 16780544, 16780800, 16781056, 16781312,     00036850
      16781568, 16781824, 33559296, 33559808, 33560320, 33560832, 33561344,     00036900
      33561856, 33562368, 33562880, 33563392, 33563904, 33564416, 201337088,    00036950
      50345216, 50345984, 50346752, 50347520, 50348288, 50349056, 50349824,     00037000
      50350592, 50351360, 50352128, 50352896, 50353664, 50354432, 67132416,     00037050
      67133440, 67134464, 67135488, 67136512, 67137536, 67138560, 67139584,     00037100
      67140608, 67141632, 67142656, 67143680, 67144704, 67145728, 67146752,     00037150
      67147776, 67148800, 67149824, 83928064, 83929344, 83930624, 83931904,     00037200
      83933184, 83934464, 83935744, 83937024, 83938304, 83939584, 83940864,     00037250
      83942144, 83943424, 100721920, 100723456, 100724992, 100726528, 100663297,00037300
      100664833, 100666369, 100667905, 100669441, 100670977, 100672513,         00037350
      100674049, 100675585, 100677121, 100678657, 100680193, 100681729,         00037400
      100683265, 100684801, 100686337, 100687873, 117466625, 117468417,         00037450
      117470209, 117472001, 117473793, 117475585, 117477377, 117479169,         00037500
      117480961, 117482753, 117484545, 117486337, 117488129, 134267137,         00037550
      134269185, 134271233, 134273281, 134275329, 134277377, 151056641,         00037600
      150994946, 150997250, 150999554, 151001858, 151004162, 151006466,         00037650
      151008770, 151011074, 151013378, 167792898, 167795458, 167798018,         00037700
      184577794, 201357826, 201360898, 218141186, 218144514, 234925058,         00037750
      234928642, 251709442, 285267714, 285272066, 285212675, 301994243,         00037800
      318776067, 335558147, 50350595, 67128579, 67129603, 67130627, 67131651,   00037850
      83909891, 83911171, 83912451, 83913731, 100692227, 117470979, 134249987,  00037900
      134252035, 134254083, 134256131, 134258179, 134260227, 134262275,         00037950
      151041539, 151043843, 151046147, 151048451, 151050755, 151053059,         00038000
      151055363, 151057667, 150994948, 167774468, 167777028, 167779588,         00038050
      167782148, 167784708, 167787268, 167789828, 167792388, 167794948,         00038100
      167797508, 167800068, 167802628, 167805188, 167807748, 167810308,         00038150
      167812868, 167815428, 167817988, 167820548, 167823108, 184602884,         00038200
      184605700, 184608516, 184611332, 184549381, 184552197, 184555013,         00038250
      184557829, 184560645, 184563461, 184566277, 184569093, 184571909,         00038300
      184574725, 184577541, 184580357, 184583173, 184585989, 184588805,         00038350
      184591621, 184594437, 184597253, 184600069, 201380101, 201383173,         00038400
      201386245, 201326598, 201329670, 201332742, 201335814, 201338886,         00038450
      201341958, 201345030, 201348102, 201351174, 201354246, 201357318,         00038500
      201360390, 201363462, 201366534, 201369606, 218149894, 218153222,         00038550
      218156550, 218159878, 218163206, 218103815, 218107143, 218110471,         00038600
      218113799, 218117127, 234897671, 234901255, 234904839, 234908423,         00038650
      234912007, 234915591, 234919175, 234922759, 234926343, 234929927,         00038700
      251710727, 251714567, 251718407, 251658248, 251662088, 251665928,         00038750
      251669768, 251673608, 251677448, 251681288, 251685128, 268466184,         00038800
      268470280, 268474376, 268478472, 268482568, 268486664, 268490760,         00038850
      268494856, 268435465, 268439561, 268443657, 268447753, 268451849,         00038900
      268455945, 268460041, 285241353, 285245705, 285250057, 285254409,         00038950
      285258761, 285263113, 285267465, 285271817, 285212682, 285217034,         00039000
      301998602, 302003210, 302007818, 302012426, 302017034, 302021642,         00039050
      302026250, 302030858, 302035466, 302040074, 302044682, 302049290,         00039100
      301989899, 301994507, 318776331, 318781195, 318786059, 318790923,         00039150
      318795787, 318800651, 335582731, 335587851, 352370187, 369152779,         00039200
      385935627);                                                               00039250
   ARRAY V_INDEX(20) BIT(16) INITIAL (1, 20, 31, 45, 63, 76, 97, 110,/*CR13335*/00039300
      116, 126, 129, 130, 132, 134, 136, 137, 137, 140, 141, 142, 143);/*13335*/00039350
                                                                                00039400
   DECLARE P# LITERALLY '453'; /* # OF PRODUCTIONS */                           00039450
                                                                                00039500
   ARRAY   STATE_NAME(MAXR#) BIT(16) INITIAL (0,0,1,1,2,3,3,3,3,3,3,3,3,3       00039550
      ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,8,8,9,9    00039600
      ,9,9,9,10,12,12,12,12,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,15     00039650
      ,16,16,17,18,18,18,18,19,19,22,22,23,23,24,25,27,28,28,30,30,30,30,30     00039700
      ,32,34,34,37,38,38,42,43,44,45,46,47,49,50,51,52,54,55,56,57,58,63,64     00039750
      ,65,67,67,67,69,71,73,75,80,82,84,85,87,88,90,95,95,95,96,98,98,98,98     00039800
      ,98,99,103,104,108,109,110,111,112,113,113,113,113,113,113,113,114,114    00039850
      ,115,116,118,118,119,123,123,124,124,126,128,131,131,131,131,131,131      00039900
      ,134,138,139,140,141,142,143,143,143,144,145,146,147,147,148,148,149      00039950
      ,149,149,150,150,150,150,153,153,154,154,154,155,156,157,157,157,157      00040000
      ,157,158,158,158,158,158,158,158,158,158,158,158,159,160,161,161,161      00040050
      ,161,161,162,162,162,162,162,162,162,164,164,164,164,164,165,166,167      00040100
      ,168,169,170,172,173,174,174,174,174,174,177,177,178,180,181,181,182      00040150
      ,182,184,187,188,188,188,188,189,190,190,190,190,190,190,190,190,190      00040200
      ,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190      00040250
      ,190,190,190,190,190,190,190,190,190,190,190,191,193,193,193,193,193      00040300
      ,194,196,198,199,200,201,202,203,203,206,207,207,207,207,208,209,210      00040350
      ,210,212,213,214,215,216,217,218,219,219,220,220,220,220,220,221,224      00040400
      ,225,225,225,227,227,228,229,230,231,234,235,236,236,237,238,239,240      00040450
      ,240,241,242,243,244,244,246,247,248,249,249,250,252,254,255,256,257      00040500
      ,257,257,257,257,258,259,259,260,262,263,264,265,267,268,269,270,270      00040550
      ,272,273,273,273,273,276,277,278,279,280,282,283,283,283,286,287,289      00040600
      ,289,290,290,291,291,291,291,291,291,292,292,292,292,292,292,292,293      00040650
      ,294,295,297,298,304,304,305,305,308,311);                                00040700
                                                                                00040750
                                                                                00040800
   ARRAY   #PRODUCE_NAME(P#) BIT(16) INITIAL (0,233,243,243,190,190,190         00040850
      ,190,190,152,152,168,168,168,168,156,156,144,235,235,235,277,277,213      00040900
      ,213,213,213,167,235,167,167,167,167,285,285,285,205,205,251,251,278      00040950
      ,278,278,278,278,278,278,278,278,278,278,278,278,278,278,278,278,278      00041000
      ,278,278,278,278,278,278,278,278,278,278,278,278,278,278,278,278,278      00041050
      ,278,278,278,241,241,231,231,171,171,171,171,171,171,171,171,171,252      00041100
      ,252,161,161,161,161,219,219,162,162,257,257,257,257,257,257,257,257      00041150
      ,223,223,223,223,223,304,304,273,273,185,185,185,195,195,195,195,195      00041200
      ,195,265,265,300,300,174,174,174,174,174,217,217,245,245,208,199,199      00041250
      ,146,255,255,255,255,255,255,255,255,194,210,210,249,249,178,178,267      00041300
      ,267,302,302,165,165,155,155,155,202,201,201,259,259,259,177,198,173      00041350
      ,193,193,289,289,225,225,225,225,225,260,260,260,260,295,179,179,188      00041400
      ,188,188,188,188,188,188,182,182,182,182,182,182,180,180,180,181,200      00041450
      ,309,303,307,310,261,191,175,163,197,236,236,158,158,240,229,207,207      00041500
      ,207,207,207,206,206,206,206,206,187,187,151,151,151,151,248,169,169      00041550
      ,242,242,242,145,143,148,148,147,147,150,150,149,149,204,204,204,227      00041600
      ,227,253,153,153,153,153,262,262,192,192,192,192,192,222,222,226,226      00041650
      ,226,226,226,237,237,250,250,183,183,211,211,184,184,212,288,220,220      00041700
      ,220,287,287,263,280,294,221,264,264,264,264,264,291,268,268,279,279      00041750
      ,279,279,279,279,279,279,279,256,272,266,266,266,271,271,271,270,269      00041800
      ,269,232,154,281,281,281,281,247,246,246,170,170,275,301,244,244,290      00041850
      ,290,224,254,254,274,298,298,298,299,239,296,296,297,234,234,166,166      00041900
      ,218,218,218,216,216,216,216,216,215,215,306,306,306,209,209,209,209      00041950
      ,209,172,172,196,214,214,214,228,228,228,228,228,311,311,292,292,203      00042000
      ,203,283,283,284,284,284,284,284,284,284,284,284,284,284,284,282,282      00042050
      ,282,305,305,305,305,305,238,308,308,176,176,176,176,157,157,164,164      00042100
      ,164,230,230,276,276,189,258,258,258,258,286,286,286,293,293,293,160      00042150
      ,160,160,159,186,186);                                                    00042200
                                                                                00042250
   DECLARE RSIZE LITERALLY '1319'; /*  READ STATES INFO  */                     00042300
                                                                                00042350
   DECLARE LSIZE LITERALLY '919'; /* LOOK AHEAD STATES INFO */                  00042400
                                                                                00042450
   DECLARE ASIZE LITERALLY '819'; /* APPLY PRODUCTION STATES INFO */            00042500
                                                                                00042550
   ARRAY   READ1(RSIZE) BIT(8) INITIAL (0,95,98,135,19,3,4,12,84,89,96,99       00042600
      ,105,113,130,135,136,137,99,3,4,11,12,28,33,34,36,39,40,41,42,47,61,70    00042650
      ,84,89,93,96,99,105,113,118,127,129,130,132,135,136,137,131,99,136,53     00042700
      ,54,93,135,18,18,18,3,84,89,96,99,105,113,130,135,136,137,9,10,10,78      00042750
      ,132,10,10,48,123,44,51,53,55,58,80,93,135,3,4,11,12,28,33,34,36,39,40    00042800
      ,41,42,44,47,51,53,54,55,58,61,70,80,84,89,93,96,99,105,113,118,127,129   00042850
      ,130,132,133,135,136,137,87,99,131,18,19,99,99,18,81,91,18,33,36,39,41    00042900
      ,81,91,50,76,10,38,46,73,74,30,67,3,11,28,33,34,36,39,40,41,42,61,70,93   00042950
      ,113,127,135,98,43,71,90,3,98,124,135,3,11,28,33,34,36,39,40,41,42,61     00043000
      ,70,93,113,119,127,135,67,135,3,3,10,98,3,3,3,9,3,3,67,3,3,98,3,3,112,3   00043050
      ,3,10,98,3,4,10,11,12,28,33,34,36,39,40,41,42,47,53,54,61,70,84,89,93     00043100
      ,96,99,105,113,118,127,129,130,132,133,135,136,137,114,3,16,10,10,10,9    00043150
      ,34,52,59,64,66,68,72,77,81,84,85,86,89,91,92,96,100,101,104,105,106      00043200
      ,107,111,113,117,118,121,131,139,3,3,131,3,131,10,34,81,84,89,91,96,101   00043250
      ,105,118,139,34,101,10,81,84,89,91,96,105,118,139,30,135,3,3,10,131,3     00043300
      ,131,53,3,16,52,66,72,77,85,86,92,100,104,106,111,117,9,14,30,19,3,10     00043350
      ,12,3,99,135,136,3,3,99,135,136,3,4,11,12,28,33,34,36,39,40,41,42,47,53   00043400
      ,54,61,70,84,89,93,96,99,105,113,118,127,129,130,132,133,135,136,137,3    00043450
      ,4,12,47,84,89,96,99,105,113,118,129,130,132,135,136,137,3,28,33,34,36    00043500
      ,39,41,42,61,70,93,113,127,135,3,28,33,34,36,39,41,42,61,70,93,113,127    00043550
      ,135,2,15,19,3,9,3,3,10,1,3,8,84,89,96,99,105,113,130,135,136,137,9,9,9   00043600
      ,9,9,110,116,126,128,126,141,98,110,116,126,128,138,140,141,142,128,98    00043650
      ,110,128,138,98,110,126,128,138,141,116,126,140,141,142,63,69,73,74,20    00043700
      ,35,2,11,15,19,20,35,40,5,29,60,5,9,29,5,10,29,10,10,10,10,10,34,52,59    00043750
      ,64,66,68,72,77,81,84,85,86,89,91,92,96,100,101,104,105,106,107,111,113   00043800
      ,117,118,121,139,21,13,30,9,14,10,3,10,78,9,20,35,2,9,11,15,19,20,35,40   00043850
      ,19,10,10,73,74,2,11,15,19,40,3,3,9,9,10,44,51,53,55,58,80,93,135,9,10    00043900
      ,14,16,14,19,9,14,19,10,3,4,12,38,73,84,89,96,99,105,113,130,135,136      00043950
      ,137,4,12,17,20,35,4,12,20,35,2,4,11,12,15,19,20,35,40,4,10,12,4,9,12     00044000
      ,20,35,4,10,12,4,12,30,2,4,9,11,12,15,19,20,35,40,4,12,17,20,35,4,10,12   00044050
      ,4,9,12,4,12,22,4,10,12,4,9,12,4,9,12,4,9,12,4,9,12,4,9,12,4,9,12,4,12    00044100
      ,23,4,10,12,4,9,12,4,9,12,19,9,14,9,14,9,14,9,14,9,14,10,24,25,26,28,42   00044150
      ,43,45,49,50,53,56,57,62,71,75,79,87,88,90,93,95,98,108,115,125,134,135   00044200
      ,10,14,30,10,32,9,14,9,14,3,4,8,12,17,84,89,96,99,105,113,130,135,136     00044250
      ,137,3,83,94,10,10,52,66,72,77,85,86,92,100,104,106,111,117,3,4,11,12     00044300
      ,28,33,34,36,39,40,41,42,61,70,84,89,93,96,99,105,113,127,130,135,136     00044350
      ,137,3,4,10,11,12,28,33,34,36,39,40,41,42,44,47,51,53,54,55,58,61,70,80   00044400
      ,84,89,93,96,99,105,113,118,127,129,130,132,133,135,136,137,10,34,52,66   00044450
      ,68,72,77,81,84,85,86,89,91,92,96,100,101,104,105,106,111,117,118,139     00044500
      ,10,14,6,32,10,24,25,26,28,42,43,45,49,50,53,56,57,62,65,71,75,79,87,88   00044550
      ,90,93,95,98,108,115,125,134,135,82,103,109,123,131,10,9,10,81,91,7,10    00044600
      ,135,9,14,10,14,1,7,10,14,3,28,33,36,39,41,42,47,53,61,70,93,99,132,135   00044650
      ,136,137,10,53,93,135,3,4,11,12,28,33,34,36,39,40,41,42,47,53,54,61,70    00044700
      ,84,89,93,96,99,105,113,118,127,129,130,132,133,135,136,137,28,33,36,39   00044750
      ,41,42,47,53,61,70,93,99,132,135,136,137,4,12,31,95,98,10,10,23,10,3,4    00044800
      ,12,17,84,89,96,99,105,113,130,135,136,137,10,10,10,14,3,10,24,25,26,28   00044850
      ,37,42,43,45,49,50,53,56,57,62,71,75,79,87,88,90,93,95,98,108,115,124     00044900
      ,125,134,135,3,34,68,81,84,89,91,96,101,105,118,139,53,54,113,133,135     00044950
      ,22,27,28,114,10,10,132,10,72,77,3,14,102,107,113,121,131,34,68,81,84     00045000
      ,89,91,96,101,105,118,139,78,3,78,5,29,60,5,9,29,5,9,29,10,14,3,48,120    00045050
      ,122,3,4,8,11,12,28,33,34,36,39,40,41,42,47,53,54,61,70,84,89,93,96,99    00045100
      ,105,113,118,127,129,130,132,133,135,136,137,16,52,66,72,77,85,86,92      00045150
      ,100,104,106,111,117,10,14,73,74,119,9,14,9,14,14,59,95,112,10,24,25,26   00045200
      ,28,42,43,45,49,50,53,56,57,59,62,65,71,75,79,87,88,90,93,95,98,108,112   00045250
      ,115,125,134,135,10,24,25,26,28,37,42,43,45,49,50,53,56,57,59,62,71,75    00045300
      ,79,87,88,90,93,95,98,108,112,115,125,134,135,10,24,25,26,28,42,43,45     00045350
      ,49,50,53,56,57,62,65,71,75,79,87,88,90,93,95,98,108,115,125,134,135,10   00045400
      ,24,25,26,28,37,42,43,45,49,50,53,56,57,62,71,75,79,87,88,90,93,95,98     00045450
      ,108,115,125,134,135,9,9,14,9,14,9,9,9,10,3,9,14,9,14,3,4,8,12,84,89,96   00045500
      ,99,105,113,130,135,136,137);                                             00045550
                                                                                00045600
   ARRAY   LOOK1(LSIZE) BIT(8) INITIAL (0,135,0,126,141,0,19,0,126,141,0        00045650
      ,126,141,0,126,141,0,126,141,0,126,141,0,98,110,116,126,128,138,140,141   00045700
      ,0,98,110,116,126,128,138,140,141,142,0,98,110,116,126,128,138,140,141    00045750
      ,142,0,53,93,135,0,98,110,116,126,128,138,140,141,142,0,98,110,128,138    00045800
      ,0,53,54,93,135,0,98,110,116,126,128,138,140,141,142,0,98,110,116,126     00045850
      ,128,138,140,141,142,0,98,110,116,126,128,138,140,141,142,0,98,110,116    00045900
      ,126,128,138,140,141,142,0,53,93,135,0,126,141,0,126,141,0,126,141,0      00045950
      ,126,141,0,126,141,0,18,0,126,141,0,98,110,126,128,138,141,0,18,0,116     00046000
      ,126,140,141,0,53,93,135,0,126,141,0,126,141,0,126,141,0,126,141,0,48,0   00046050
      ,126,141,0,126,141,0,126,141,0,126,141,0,53,93,135,0,126,141,0,110,116    00046100
      ,126,128,0,98,110,116,126,128,138,140,141,142,0,135,0,126,141,0,98,110    00046150
      ,116,126,128,138,140,141,142,0,53,93,135,0,18,0,19,0,98,110,116,126,128   00046200
      ,138,140,141,142,0,18,81,91,0,18,81,91,0,18,33,36,39,41,81,91,0,18,0,98   00046250
      ,110,116,126,128,138,140,141,142,0,50,0,126,141,0,126,141,0,126,141,0     00046300
      ,126,141,0,98,110,128,138,0,53,93,135,0,126,141,0,126,141,0,126,141,0,7   00046350
      ,0,98,0,126,0,98,110,128,138,0,135,0,135,0,126,141,0,126,141,0,98,0,7,0   00046400
      ,7,0,7,0,126,141,0,135,0,126,141,0,3,0,98,110,116,126,128,138,140,141     00046450
      ,142,0,135,0,114,0,114,0,3,0,7,0,7,0,98,0,135,0,7,0,7,0,3,0,7,0,7,0,53    00046500
      ,0,3,0,7,0,7,0,7,0,7,0,126,0,126,0,126,141,0,98,110,116,126,128,138,140   00046550
      ,141,142,0,98,110,116,126,128,138,140,141,142,0,98,110,128,138,0,98,110   00046600
      ,116,126,128,138,140,141,142,0,98,110,128,138,0,98,110,116,126,128,138    00046650
      ,140,141,142,0,98,110,128,138,0,116,126,140,141,0,116,126,140,141,0,98    00046700
      ,110,128,138,0,98,110,128,138,0,98,110,128,138,0,3,0,1,3,8,84,89,96,99    00046750
      ,105,113,126,130,135,136,137,141,0,63,69,0,10,0,20,35,0,2,11,15,19,20     00046800
      ,35,40,0,20,35,0,20,35,0,5,29,0,10,0,5,29,0,10,0,126,141,0,10,14,0,21,0   00046850
      ,13,0,30,0,20,35,0,20,35,0,110,116,126,128,0,126,141,0,4,12,0,9,14,0,9    00046900
      ,10,14,0,4,12,30,0,9,14,0,4,12,22,0,4,12,0,4,12,0,10,0,4,12,0,4,12,0,4    00046950
      ,12,0,4,12,0,4,12,0,4,12,0,4,12,23,0,4,12,0,4,12,0,110,116,126,128,0      00047000
      ,110,116,126,128,0,110,116,126,128,0,9,10,14,16,126,141,0,83,94,0,110     00047050
      ,116,126,128,0,10,14,0,98,110,116,126,128,138,140,141,142,0,98,110,126    00047100
      ,128,138,141,0,98,110,116,126,128,138,140,141,142,0,7,0,126,141,0,10,14   00047150
      ,0,6,32,0,6,32,0,110,116,126,128,0,110,116,126,128,0,110,116,126,128,0    00047200
      ,110,116,126,128,0,110,116,126,128,0,82,103,109,123,0,126,141,0,126,141   00047250
      ,0,81,91,0,7,0,98,0,7,0,1,7,0,9,14,110,116,126,128,0,53,93,135,0,98,110   00047300
      ,116,126,128,138,140,141,142,0,98,110,116,126,128,138,140,141,142,0,4     00047350
      ,12,0,126,141,0,82,103,109,123,0,110,116,126,128,0,10,72,77,120,122,0     00047400
      ,98,110,128,138,0,116,126,140,141,0,126,141,0,142,0,22,27,28,114,0,82     00047450
      ,103,109,123,0,14,0,10,72,77,120,122,0,78,0,3,78,0,10,0,48,0,120,122,0    00047500
      ,82,103,109,123,0,98,110,116,126,128,138,140,141,142,0,10,14,0,10,14,0    00047550
      ,82,103,109,123,0,14,0,14,0,59,95,112,0,102,107,110,113,116,121,126,128   00047600
      ,0,110,116,126,128,0,102,107,110,113,116,121,126,128,0,110,116,126,128    00047650
      ,0,110,116,126,128,0,82,103,109,123,0,126,141,0,6,32,0,6,32,0,98,110      00047700
      ,116,126,128,138,140,141,142,0,126,141,0);                                00047750
                                                                                00047800
 /*  PUSH STATES ARE BUILT-IN TO THE INDEX TABLES  */                           00047850
                                                                                00047900
   ARRAY   APPLY1(ASIZE) BIT(16) INITIAL (0,0,0,8,11,17,18,20,25,26,27,28       00047950
      ,30,31,32,33,34,36,37,40,60,62,67,68,75,80,82,83,85,88,93,94,95,106,117   00048000
      ,123,125,132,187,188,190,192,194,195,242,269,322,329,330,331,350,351      00048050
      ,364,372,381,383,408,440,0,42,43,44,54,55,56,57,0,3,46,206,0,186,0,0,0    00048100
      ,0,0,0,419,420,421,422,423,0,313,316,319,327,0,378,0,316,419,420,421      00048150
      ,422,423,0,0,0,193,196,197,199,0,0,17,28,188,190,191,192,329,380,0,189    00048200
      ,0,11,17,22,28,37,90,101,188,329,330,0,226,229,258,273,279,388,0,0,190    00048250
      ,0,17,28,329,0,192,0,194,195,0,0,163,0,11,17,28,40,188,190,192,329,381    00048300
      ,0,59,0,0,0,0,0,0,0,224,412,0,257,0,0,0,0,0,378,0,0,0,96,0,81,0,0,0,20    00048350
      ,25,26,27,0,41,0,62,75,80,132,187,331,364,408,440,0,17,28,188,190,192     00048400
      ,39,384,0,0,68,0,19,24,29,41,59,61,69,92,263,361,363,365,0,19,24,0,17    00048450
      ,28,188,190,192,329,382,0,17,18,20,25,26,27,28,62,68,75,80,132,187,188    00048500
      ,190,192,329,331,364,382,408,440,0,19,24,65,105,158,160,354,365,0,19,24   00048550
      ,365,0,19,24,365,0,19,24,365,0,19,24,365,0,17,18,20,25,26,27,28,62,68     00048600
      ,75,80,132,187,188,190,192,329,331,364,384,408,440,0,19,24,29,41,59,61    00048650
      ,69,92,100,183,185,263,313,316,319,327,340,341,342,343,344,361,363,365    00048700
      ,378,419,420,421,422,423,0,11,17,18,20,25,26,27,28,40,62,68,75,80,132     00048750
      ,187,188,190,192,194,195,329,331,364,381,408,440,0,19,24,29,41,59,61,69   00048800
      ,92,263,313,316,319,327,340,341,342,343,344,361,363,365,378,419,420,421   00048850
      ,422,423,0,19,24,29,41,59,61,69,92,103,124,133,263,313,316,319,327,340    00048900
      ,341,342,343,344,361,363,365,378,419,420,421,422,423,0,17,18,19,20,24     00048950
      ,25,26,27,28,29,41,59,61,62,68,69,75,80,92,132,187,188,190,192,263,313    00049000
      ,316,319,327,329,331,340,341,342,343,344,361,363,364,365,378,384,408      00049050
      ,419,420,421,422,423,440,0,11,17,18,19,20,22,24,25,26,27,28,29,37,40,41   00049100
      ,59,61,62,65,68,69,75,80,90,92,100,101,103,105,124,132,133,158,160,183    00049150
      ,185,187,188,189,190,191,192,193,194,195,196,197,199,263,313,316,319      00049200
      ,327,329,330,331,340,341,342,343,344,354,361,363,364,365,378,380,381      00049250
      ,384,408,419,420,421,422,423,440,0,19,24,29,41,59,61,69,92,263,313,316    00049300
      ,319,327,340,341,342,343,344,361,363,365,378,419,420,421,422,423,0,0      00049350
      ,120,121,122,141,148,161,169,170,178,180,181,182,332,353,358,0,0,0,0,0    00049400
      ,83,372,0,0,0,98,163,357,0,436,437,0,399,400,401,402,0,17,28,188,190      00049450
      ,192,193,226,229,251,253,258,273,279,329,388,0,225,226,227,228,229,250    00049500
      ,251,252,253,254,0,357,0,70,71,0,0,78,0,0,361,365,0,361,365,0,62,331,0    00049550
      ,0,0,61,0,62,0,0,0,1,367,0,390,407,413,432,0,0,0,0,0,0,0,1,340,341,342    00049600
      ,343,344,367,378,419,421,422,423,0,0,0,0,0,0,0,202,398,0,0,397,0,48,249   00049650
      ,0,377,0,0,0,0,0,0,167,0,58,0,0,0,0,0,0,152,157,0,0,0,346,435,0,0,243,0   00049700
      ,0,0,335,0,379,396,0,152,153,154,155,0,152,153,156,0,151,152,153,155      00049750
      ,156,0,0,0,5,6,7,9,334,434,0,76,77,78,352,0,173,328,0,409,410,411,0,0     00049800
      ,440,0,0,0,361,0,13,14,15,16,21,23,183,185,361,365,0,340,341,342,343      00049850
      ,344,0,0,0,0,0,0,0,0,0,224,0);                                            00049900
                                                                                00049950
   ARRAY   READ2(RSIZE) BIT(16) INITIAL (0,1125,138,1031,915,448,473,478        00050000
      ,836,834,835,1239,833,151,831,1030,1238,830,143,450,473,1064,478,1083     00050050
      ,1076,508,1077,1074,1065,1075,1084,107,1081,1082,836,834,1035,835,1239    00050100
      ,833,153,534,901,937,831,1085,1030,1238,830,1150,1239,1238,1019,112       00050150
      ,1035,1030,493,494,495,448,836,834,835,1239,833,151,831,1030,1238,830     00050200
      ,1220,887,859,1142,1086,860,861,962,535,104,110,1019,113,116,127,1035     00050250
      ,1030,450,473,1064,478,1083,1076,508,1077,1074,1065,1075,1084,104,107     00050300
      ,110,1019,1017,113,116,1081,1082,127,836,834,1035,835,1239,833,152,534    00050350
      ,901,937,831,1085,1000,1030,1238,830,1261,1164,1151,496,916,1162,1163     00050400
      ,1072,1208,1207,1072,1076,1077,1074,1075,1208,1207,109,1147,954,510,514   00050450
      ,964,963,91,517,455,1064,1083,1076,508,1077,1074,1065,1075,1084,1081      00050500
      ,1082,1035,154,901,1030,142,512,521,525,445,976,168,1030,455,1064,1083    00050550
      ,1076,508,1077,1074,1065,1075,1084,1081,1082,1035,154,164,901,1030,518    00050600
      ,1030,462,21,852,139,13,463,449,1018,464,14,519,465,1182,1241,15,466      00050650
      ,150,446,10,854,140,450,473,862,1064,478,1083,1076,508,1077,1074,1065     00050700
      ,1075,1084,107,1019,1017,1081,1082,836,834,1035,835,1239,833,152,534      00050750
      ,901,937,831,1085,1000,1030,1238,830,531,1203,1118,853,855,856,1222,97    00050800
      ,111,1181,118,1213,1191,1218,1215,1208,523,130,1217,1200,1207,1211,528    00050850
      ,1214,1192,145,1199,1221,1180,149,1178,1212,162,1179,538,179,1223,16      00050900
      ,539,1224,175,1108,97,1208,523,1200,1207,528,1192,1199,162,179,97,1192    00050950
      ,1108,1208,523,1200,1207,528,1199,162,179,505,1030,468,447,871,173,1169   00051000
      ,176,1173,12,73,111,1213,1218,1215,130,1217,1211,1214,145,1221,149,1212   00051050
      ,1138,1140,504,974,888,886,53,467,1239,1030,1238,38,470,1239,1030,1238    00051100
      ,451,473,1064,478,1083,1076,508,1077,1074,1065,1075,1084,107,1019,1017    00051150
      ,1081,1082,836,834,1035,835,1239,833,152,534,901,937,831,1085,1000,1030   00051200
      ,1238,830,471,473,478,107,836,834,835,1239,833,156,534,937,831,1085       00051250
      ,1030,1238,830,455,1083,1076,508,1077,1074,1075,1084,1081,1082,1035,154   00051300
      ,901,1030,460,1083,1076,508,1077,1074,1075,1084,1081,1082,1035,154,901    00051350
      ,1030,917,918,912,23,1073,461,472,864,443,448,476,836,834,835,1239,833    00051400
      ,151,831,1030,1238,830,1100,1102,1101,49,1079,530,533,536,537,536,542     00051450
      ,529,530,533,536,537,540,541,542,543,537,529,530,537,540,529,530,536      00051500
      ,537,540,542,533,536,541,542,543,515,520,964,963,1066,1067,444,1064,491   00051550
      ,911,1066,1067,1065,1062,1063,952,1062,896,1063,1062,874,1063,1103,840    00051600
      ,898,934,998,97,111,1181,118,1213,1191,1218,1215,1208,523,130,1217,1200   00051650
      ,1207,1211,528,1214,1192,145,1199,1221,1180,149,1178,1212,162,1179,179    00051700
      ,827,481,1052,1149,66,1109,452,858,1142,936,1066,1067,444,936,1064,491    00051750
      ,911,1066,1067,1065,497,870,955,964,963,444,1064,491,911,1065,453,456     00051800
      ,1009,1016,865,104,110,1019,113,116,127,1035,1030,1036,1043,1045,1044     00051850
      ,482,498,1007,482,1058,1146,448,473,478,511,522,836,834,835,1239,833      00051900
      ,151,831,1030,1238,830,474,479,1231,1066,1067,474,479,1066,1067,444,474   00051950
      ,1064,479,491,911,1066,1067,1065,474,872,479,474,828,479,1066,1067,474    00052000
      ,477,479,474,479,506,444,474,828,1064,479,491,911,1066,1067,1065,474      00052050
      ,479,492,1066,1067,474,873,479,474,984,479,474,479,500,474,877,479,474    00052100
      ,1088,479,474,1090,479,474,1091,479,474,1087,479,474,1089,479,474,1253    00052150
      ,479,474,479,501,474,878,479,474,1069,479,474,1070,479,973,48,488,838     00052200
      ,488,900,488,935,488,999,488,857,86,87,953,89,102,512,513,108,109,1019    00052250
      ,114,115,1247,521,126,1244,131,524,525,1035,135,138,146,532,1243,177      00052300
      ,1030,1110,483,507,883,96,1068,490,1068,71,448,473,1049,478,1055,836      00052350
      ,834,835,1239,833,151,831,1030,1238,830,1034,980,979,885,882,111,1213     00052400
      ,1218,1215,130,1217,1211,1214,145,1221,149,1212,469,473,1064,478,1083     00052450
      ,1076,508,1077,1074,1065,1075,1084,1081,1082,836,834,1035,835,1239,833    00052500
      ,155,901,831,1030,1238,830,450,473,867,1064,478,1083,1076,508,1077,1074   00052550
      ,1065,1075,1084,104,107,110,1019,1017,113,116,1081,1082,127,836,834       00052600
      ,1035,835,1239,833,152,534,901,937,831,1085,1000,1030,1238,830,1107,97    00052650
      ,111,1213,1191,1218,1215,1208,523,130,1217,1200,1207,1211,528,1214,1192   00052700
      ,145,1199,1221,149,1212,162,179,851,58,1060,1061,857,86,87,953,89,102     00052750
      ,512,513,108,109,1019,114,115,1247,516,521,126,1244,131,524,525,1035      00052800
      ,526,138,146,532,1243,177,1030,128,144,147,165,538,863,899,869,1208       00052850
      ,1207,1059,875,1030,47,889,1165,64,442,1059,866,484,1232,1083,1076,1077   00052900
      ,1074,1075,1084,107,1019,1081,1082,1035,1239,1085,1030,1238,1235,1111     00052950
      ,1019,1035,1030,450,473,1064,478,1083,1076,508,1077,1074,1065,1075,1084   00053000
      ,107,1019,1017,1081,1082,836,834,1035,835,1239,833,152,534,901,937,831    00053050
      ,1085,1000,1030,1238,830,1083,1076,1077,1074,1075,1084,107,1019,1081      00053100
      ,1082,1035,1239,1085,1030,1238,1235,475,480,811,1125,138,1153,1152,84     00053150
      ,1144,448,473,478,1055,836,834,835,1239,833,151,831,1030,1238,830,957     00053200
      ,956,868,485,457,857,86,87,953,89,509,102,512,513,108,109,1019,114,115    00053250
      ,1247,521,126,1244,131,524,525,1035,526,138,146,532,167,1243,177,1030     00053300
      ,1139,97,1191,1208,523,1200,1207,528,1192,1199,162,179,1019,1017,157      00053350
      ,1000,1030,499,502,503,159,881,884,1080,1112,1114,1113,458,487,1122       00053400
      ,1121,1130,1131,174,97,1191,1208,523,1200,1207,528,1192,1199,162,179      00053450
      ,1142,1139,1142,1062,1063,951,1062,928,1063,1062,929,1063,876,486,454     00053500
      ,950,1116,1117,450,473,45,1064,478,1083,1076,508,1077,1074,1065,1075      00053550
      ,1084,107,1019,1017,1081,1082,836,834,1035,835,1239,833,152,534,901,937   00053600
      ,831,1085,1000,1030,1238,830,74,111,1213,1218,1215,130,1217,1211,1214     00053650
      ,145,1221,149,1212,879,63,964,963,1254,50,489,51,489,1158,1123,1124       00053700
      ,1120,857,86,87,953,89,102,512,513,108,109,1019,114,115,1123,1247,516     00053750
      ,521,126,1244,131,524,525,1035,527,138,146,1120,532,1243,177,1030,857     00053800
      ,86,87,953,89,509,102,512,513,108,109,1019,114,115,1123,1247,521,126      00053850
      ,1244,131,524,525,1035,527,138,146,1120,532,1243,177,1030,857,86,87,953   00053900
      ,89,102,512,513,108,109,1019,114,115,1247,516,521,126,1244,131,524,525    00053950
      ,1035,135,138,146,532,1243,177,1030,857,86,87,953,89,509,102,512,513      00054000
      ,108,109,1019,114,115,1247,521,126,1244,131,524,525,1035,135,138,146      00054050
      ,532,1243,177,1030,1198,1177,1183,1193,1204,1194,1168,1216,880,459,1219   00054100
      ,1225,1229,1233,448,473,1206,478,836,834,835,1239,833,151,831,1030,1238   00054150
      ,830);                                                                    00054200
                                                                                00054250
   ARRAY   LOOK2(LSIZE) BIT(16) INITIAL (0,2,1033,667,667,3,4,913,668,668       00054300
      ,5,669,669,6,670,670,7,671,671,8,672,672,9,673,673,673,673,673,673,673    00054350
      ,673,11,674,674,674,674,674,674,674,674,674,17,675,675,675,675,675,675    00054400
      ,675,675,675,18,19,19,19,676,677,677,677,677,677,677,677,677,677,20,678   00054450
      ,678,678,678,22,24,24,24,24,679,680,680,680,680,680,680,680,680,680,25    00054500
      ,681,681,681,681,681,681,681,681,681,26,682,682,682,682,682,682,682,682   00054550
      ,682,27,683,683,683,683,683,683,683,683,683,28,29,29,29,684,685,685,30    00054600
      ,686,686,31,687,687,32,688,688,33,689,689,34,35,1041,690,690,36,691,691   00054650
      ,691,691,691,691,37,39,1041,692,692,692,692,40,41,41,41,693,694,694,42    00054700
      ,695,695,43,696,696,44,697,697,46,52,958,698,698,54,699,699,55,700,700    00054750
      ,56,701,701,57,59,59,59,702,703,703,60,704,704,704,704,61,705,705,705     00054800
      ,705,705,705,705,705,705,62,65,706,707,707,67,708,708,708,708,708,708     00054850
      ,708,708,708,68,69,69,69,709,70,1042,72,914,710,710,710,710,710,710,710   00054900
      ,710,710,75,76,76,76,1071,77,77,77,1071,78,78,78,78,78,78,78,1071,79      00054950
      ,1071,711,711,711,711,711,711,711,711,711,80,81,1058,712,712,82,713,713   00055000
      ,83,714,714,85,715,715,88,716,716,716,716,90,92,92,92,717,718,718,93      00055050
      ,719,719,94,720,720,95,98,721,99,975,722,100,723,723,723,723,101,103      00055100
      ,724,105,725,726,726,106,727,727,117,119,1240,120,728,121,729,122,730     00055150
      ,731,731,123,124,732,733,733,125,129,1202,734,734,734,734,734,734,734     00055200
      ,734,734,132,133,735,134,1125,136,1124,137,1201,141,736,148,737,738,158   00055250
      ,160,739,161,740,163,741,166,1167,169,742,170,743,171,1172,172,1148,178   00055300
      ,744,180,745,181,746,182,747,748,183,749,185,750,750,186,751,751,751      00055350
      ,751,751,751,751,751,751,187,752,752,752,752,752,752,752,752,752,188      00055400
      ,753,753,753,753,189,754,754,754,754,754,754,754,754,754,190,755,755      00055450
      ,755,755,191,756,756,756,756,756,756,756,756,756,192,757,757,757,757      00055500
      ,193,758,758,758,758,194,759,759,759,759,195,760,760,760,760,196,761      00055550
      ,761,761,761,197,762,762,762,762,199,200,1078,206,206,206,206,206,206     00055600
      ,206,206,206,763,206,206,206,206,763,821,223,223,1260,1256,224,225,225    00055650
      ,907,226,226,226,226,226,226,226,907,227,227,908,228,228,921,230,230      00055700
      ,992,965,233,235,235,1251,1263,236,764,764,242,1170,1170,243,244,825      00055750
      ,245,819,246,1048,250,250,993,254,254,920,765,765,765,765,263,766,766     00055800
      ,269,270,270,1205,991,991,271,991,991,991,272,278,278,278,969,991,991     00055850
      ,280,283,283,283,1053,284,284,1249,285,285,1250,1262,286,287,287,943      00055900
      ,288,288,944,291,291,919,297,297,1053,299,299,1259,300,300,1258,301,301   00055950
      ,301,971,302,302,970,305,305,972,767,767,767,767,313,768,768,768,768      00056000
      ,316,769,769,769,769,319,1046,1046,1046,1046,770,770,322,324,324,978      00056050
      ,771,771,771,771,327,1184,1184,328,772,772,772,772,772,772,772,772,772    00056100
      ,329,773,773,773,773,773,773,330,774,774,774,774,774,774,774,774,774      00056150
      ,331,332,775,776,776,334,1175,1175,335,338,338,909,339,339,910,777,777    00056200
      ,777,777,340,778,778,778,778,341,779,779,779,779,342,780,780,780,780      00056250
      ,343,781,781,781,781,344,345,345,345,345,782,783,783,350,784,784,351      00056300
      ,352,352,1196,353,785,786,354,357,841,358,358,787,1230,1230,788,788,788   00056350
      ,788,361,363,363,363,789,790,790,790,790,790,790,790,790,790,364,791      00056400
      ,791,791,791,791,791,791,791,791,365,366,366,1054,792,792,372,377,377     00056450
      ,377,377,1105,793,793,793,793,378,1126,1126,1126,1126,1126,379,794,794    00056500
      ,794,794,380,795,795,795,795,381,796,796,383,797,384,385,385,385,385      00056550
      ,1252,390,390,390,390,798,393,968,1132,1132,1132,1132,1132,396,397,1135   00056600
      ,398,398,1128,966,400,405,846,406,406,1115,407,407,407,407,799,800,800    00056650
      ,800,800,800,800,800,800,800,408,1186,1186,409,1185,1185,410,413,413      00056700
      ,413,413,801,416,1154,417,1155,418,418,418,1119,1119,1119,802,1119,802    00056750
      ,1119,802,802,419,803,803,803,803,420,1119,1119,804,1119,804,1119,804     00056800
      ,804,421,805,805,805,805,422,806,806,806,806,423,432,432,432,432,807      00056850
      ,808,808,434,436,436,926,437,437,927,809,809,809,809,809,809,809,809      00056900
      ,809,440,810,810,441);                                                    00056950
                                                                                00057000
   ARRAY   APPLY2(ASIZE) BIT(16) INITIAL (0,0,367,275,276,279,584,584,584       00057050
      ,584,584,273,292,293,294,295,296,298,275,276,282,582,596,584,582,582      00057100
      ,586,592,597,587,289,595,303,277,593,594,281,582,582,273,273,273,589      00057150
      ,590,583,274,585,273,588,582,304,306,582,592,290,591,581,581,580,815      00057200
      ,817,1056,816,818,1057,820,814,823,822,824,574,826,560,546,624,404,608    00057250
      ,573,845,845,845,845,845,847,959,948,843,949,848,960,1106,646,850,850     00057300
      ,850,850,850,846,629,355,904,905,905,906,903,376,564,564,564,229,565      00057350
      ,229,564,566,563,612,611,232,232,232,232,232,569,234,231,568,570,567      00057400
      ,635,635,382,637,637,638,636,930,664,663,401,402,645,399,925,924,942      00057450
      ,945,941,392,938,902,252,253,251,252,251,251,251,251,577,576,947,336      00057500
      ,844,603,599,548,633,598,606,606,605,374,373,257,641,967,571,205,977      00057550
      ,600,318,387,386,256,255,315,249,309,310,311,312,308,415,414,1098,1002    00057600
      ,349,347,946,1098,348,1226,1226,1001,388,388,388,388,388,388,922,994      00057650
      ,433,988,987,1010,1010,989,989,267,1096,990,268,1096,1227,266,1010,265    00057700
      ,261,262,890,258,258,258,258,258,258,923,995,260,260,260,260,260,260      00057750
      ,260,260,260,260,260,260,260,260,260,260,260,260,260,260,260,260,259      00057800
      ,1011,1011,1246,986,317,1248,1245,1011,893,1012,1012,1012,839,1013,1013   00057850
      ,1013,897,1014,1014,1014,933,1015,1015,1015,997,996,996,996,996,996,996   00057900
      ,996,996,996,996,996,996,996,996,996,996,996,996,996,996,996,996,1004     00057950
      ,1003,1003,1003,1003,1003,1003,1003,1003,307,1039,1039,1003,1003,1003     00058000
      ,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003    00058050
      ,1003,1003,837,931,931,931,931,931,931,931,931,931,931,931,931,931,931    00058100
      ,931,931,931,931,931,931,931,931,931,931,931,931,1008,1005,1005,1005      00058150
      ,1005,1005,1005,1005,1005,1005,1005,1005,1005,1005,1005,1005,1005,1005    00058200
      ,1005,1005,1005,1005,1005,1005,1005,1005,1005,1005,892,1006,1006,1006     00058250
      ,1006,1006,1006,1006,1006,981,982,983,1006,1006,1006,1006,1006,1006       00058300
      ,1006,1006,1006,1006,1006,1006,1006,1006,1006,1006,1006,1006,1006,894     00058350
      ,625,625,625,625,625,625,625,625,625,625,625,625,625,625,625,625,625      00058400
      ,625,625,625,625,625,625,625,625,625,625,625,625,625,625,625,625,625      00058450
      ,625,625,625,625,625,625,625,625,625,625,625,625,625,625,625,359,217      00058500
      ,214,214,214,214,218,214,214,214,214,214,212,220,221,212,212,212,214      00058550
      ,216,214,212,214,214,218,212,219,218,215,216,215,214,215,216,216,219      00058600
      ,219,214,214,218,214,218,214,218,221,221,218,218,218,212,212,212,212      00058650
      ,212,214,220,214,212,212,212,212,212,216,212,212,214,214,212,218,221      00058700
      ,222,214,212,212,212,212,212,214,213,627,627,627,627,627,627,627,627      00058750
      ,627,627,627,627,627,627,627,627,627,627,627,627,627,627,627,627,627      00058800
      ,627,627,628,622,602,325,326,1020,1028,1027,1026,1029,1022,1023,1021      00058850
      ,1024,832,323,1025,939,601,264,1047,631,1051,1050,575,630,547,545,545     00058900
      ,184,544,552,552,551,550,550,550,550,549,557,557,557,557,557,558,198      00058950
      ,198,198,198,198,198,198,557,198,556,553,553,553,553,553,554,554,554      00059000
      ,554,554,555,842,1037,620,620,619,940,201,559,389,1236,1236,895,1237      00059050
      ,1237,932,1099,1099,1097,360,375,1093,1092,1095,1094,578,607,812,813      00059100
      ,849,615,616,614,617,613,652,640,648,661,618,391,655,656,656,656,656      00059150
      ,656,655,658,659,660,659,660,657,394,647,634,644,1127,1129,1141,643,642   00059200
      ,395,1137,1136,204,203,202,1160,1159,371,370,247,961,1143,369,368,654     00059250
      ,653,346,632,1145,435,1161,362,362,1187,1166,662,1157,356,1156,572,1171   00059300
      ,337,610,609,1174,1176,1133,1134,604,248,248,248,248,1188,314,314,314     00059350
      ,1189,333,333,333,333,333,1190,621,666,426,427,428,430,425,429,424,320    00059400
      ,321,320,1197,1195,411,651,650,1210,1210,1210,1209,649,439,438,626,665    00059450
      ,1228,891,985,207,208,209,210,211,1038,1038,1234,1234,829,237,238,239     00059500
      ,240,241,1242,623,403,579,639,412,431,562,561,1257,1255);                 00059550
                                                                                00059600
   ARRAY   INDEX1(MAXS#) BIT(16) INITIAL (0,1,3,59,4,1306,1306,1306,5,1306      00059650
      ,18,19,49,50,50,50,50,351,942,939,942,50,151,50,52,942,942,942,351,939    00059700
      ,5,5,5,5,5,56,5,778,57,58,384,939,59,59,59,70,59,71,72,74,75,76,77,78     00059750
      ,59,59,59,59,904,939,5,79,87,125,126,193,127,5,942,939,128,128,129,130    00059800
      ,131,942,132,132,135,132,942,142,5,1000,143,5,144,149,5,150,151,167,939   00059850
      ,5,5,5,168,171,910,172,173,175,192,193,194,193,5,195,196,198,199,200      00059900
      ,201,202,203,204,205,5,206,207,910,910,910,5,193,5,208,209,210,211,212    00059950
      ,213,215,193,249,249,249,250,251,252,253,910,254,255,256,285,286,287      00060000
      ,910,288,289,303,290,290,301,290,303,311,312,314,193,910,315,910,316      00060050
      ,317,318,256,319,910,910,320,321,322,335,337,338,339,910,341,910,910      00060100
      ,910,342,346,347,59,942,351,151,351,151,351,151,384,384,401,415,429,401   00060150
      ,432,433,1049,434,435,436,437,450,451,452,453,454,455,459,461,470,461     00060200
      ,461,471,459,475,481,485,486,488,490,492,490,490,492,499,499,502,499      00060250
      ,505,499,499,508,509,510,511,512,5,513,541,542,543,544,546,547,490,492    00060300
      ,550,553,490,561,562,563,566,571,572,573,574,575,584,588,590,591,593      00060350
      ,594,609,609,614,618,627,630,630,635,638,641,651,656,659,662,609,609      00060400
      ,609,609,609,665,614,609,668,671,674,677,680,609,683,609,609,686,609      00060450
      ,689,692,609,695,698,699,701,703,705,707,709,737,738,709,739,740,709      00060500
      ,742,744,746,761,762,764,765,709,766,351,778,804,910,843,1306,844,867     00060550
      ,868,869,869,871,871,871,871,871,900,904,905,906,907,5,5,908,910,911      00060600
      ,913,915,910,917,917,919,921,938,939,942,975,991,993,996,997,998,999      00060650
      ,1000,1014,1015,1016,1018,900,1019,1049,151,384,1061,5,1063,1066,1070     00060700
      ,1071,566,1072,900,1073,1076,1077,1078,1082,1083,1094,1095,1097,499       00060750
      ,1100,1103,1106,1108,1109,1110,900,1112,766,766,1146,1159,900,1164,1166   00060800
      ,1168,1168,1169,1172,709,1203,1234,1263,1292,1293,1295,1296,1297,1298     00060850
      ,1299,1300,900,1301,1306,904,869,869,1302,1304,942,1306,1,3,6,8,11,14     00060900
      ,17,20,23,32,42,52,56,66,71,76,86,96,106,116,120,123,126,129,132,135      00060950
      ,137,140,147,149,154,158,161,164,167,170,172,175,178,181,184,188,191      00061000
      ,196,206,208,211,221,225,227,229,239,243,247,255,257,267,269,272,275      00061050
      ,278,281,286,290,293,296,299,301,303,305,310,312,314,317,320,322,324      00061100
      ,326,328,331,333,336,338,348,350,352,354,356,358,360,362,364,366,368      00061150
      ,370,372,374,376,378,380,382,384,386,388,390,393,403,413,418,428,433      00061200
      ,443,448,453,458,463,468,473,475,491,494,496,499,507,510,513,516,518      00061250
      ,521,523,526,529,531,533,535,538,541,546,549,552,555,559,563,566,570      00061300
      ,573,576,578,581,584,587,590,593,596,600,603,606,611,616,621,628,631      00061350
      ,636,639,649,656,666,668,671,674,677,680,685,690,695,700,705,710,713      00061400
      ,716,719,721,723,725,728,735,739,749,759,762,765,770,775,781,786,791      00061450
      ,794,796,801,806,808,814,816,819,821,823,826,831,841,844,847,852,854      00061500
      ,856,860,869,874,883,888,893,898,901,904,907,917,1032,1032,1032,1032      00061550
      ,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032    00061600
      ,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032    00061650
      ,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032    00061700
      ,1032,1032,1032,1032,1032,1032,1032,1032,1040,1032,1032,1032,1032,1032    00061750
      ,1032,1040,1040,1040,1032,1032,1032,1032,1032,1040,1040,1032,1032,1040    00061800
      ,1040,1040,1040,1040,1040,1040,1040,1032,1032,1032,1032,1032,1032,1032    00061850
      ,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032,1032    00061900
      ,1032,1032,1032,1032,1032,1032,1040,1032,1032,1032,1032,1032,1032,1104    00061950
      ,1032,1032,1040,1032,1040,1032,1032,1032,1032,1032,1032,1032,1032,1032    00062000
      ,1032,1104,1104,1032,1104,1032,1032,1032,1032,1032,1104,1032,1032,1032    00062050
      ,1,2,2,3,3,3,3,3,59,59,67,67,67,67,71,71,73,74,74,74,75,75,76,76,76,76    00062100
      ,77,74,77,77,77,77,78,78,78,84,84,89,89,91,91,91,91,91,91,91,91,91,91     00062150
      ,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91,91     00062200
      ,91,91,91,91,91,98,98,99,99,100,100,100,100,100,100,100,100,100,105,105   00062250
      ,106,106,106,106,115,115,117,117,128,128,128,128,128,128,128,128,135      00062300
      ,135,135,135,135,136,136,138,138,142,142,142,144,144,144,144,144,144      00062350
      ,147,147,148,148,150,150,150,150,150,160,160,162,162,163,164,164,165      00062400
      ,166,166,166,166,166,166,166,166,167,168,168,171,171,173,173,174,174      00062450
      ,175,175,176,176,177,177,177,179,180,180,181,181,181,183,185,186,187      00062500
      ,187,192,192,194,194,194,194,194,204,204,204,204,212,213,213,215,215      00062550
      ,215,215,215,215,215,228,228,228,228,228,228,231,231,231,239,262,271      00062600
      ,275,279,283,287,310,341,368,396,427,427,477,477,555,583,584,584,584      00062650
      ,584,584,600,600,600,600,600,601,601,602,602,602,602,603,604,604,607      00062700
      ,607,607,608,609,613,613,616,616,621,621,637,637,648,648,648,650,650      00062750
      ,653,654,654,654,654,656,656,657,657,657,657,657,660,660,663,663,663      00062800
      ,663,663,666,666,667,667,668,668,670,670,672,672,673,674,677,677,677      00062850
      ,682,682,683,684,685,686,687,687,687,687,687,688,701,701,702,702,702      00062900
      ,702,702,702,702,702,702,703,704,705,705,705,706,706,706,707,710,710      00062950
      ,711,713,716,716,716,716,718,719,719,720,720,721,722,723,723,725,725      00063000
      ,727,728,728,729,730,730,730,731,732,735,735,736,737,737,740,740,741      00063050
      ,741,741,743,743,743,743,743,744,744,745,745,745,747,747,747,747,747      00063100
      ,750,750,755,759,759,759,765,765,765,765,765,766,766,767,767,774,774      00063150
      ,779,779,782,782,782,782,782,782,782,782,782,782,782,782,786,786,786      00063200
      ,787,787,787,787,787,789,790,790,791,791,791,791,793,793,804,804,804      00063250
      ,810,810,811,811,812,813,813,813,813,814,814,814,815,815,815,816,816      00063300
      ,816,817,818,818);                                                        00063350
                                                                                00063400
   ARRAY   INDEX2(MAXS#) BIT(16) INITIAL (0,2,1,11,1,14,14,14,13,14,1,30,1      00063450
      ,2,2,2,2,33,33,3,33,2,16,2,4,33,33,33,33,3,13,13,13,13,13,1,13,26,1,1     00063500
      ,17,3,11,11,11,1,11,1,2,1,1,1,1,1,11,11,11,11,1,3,13,8,38,1,1,1,1,13,33   00063550
      ,3,1,1,1,1,1,33,3,3,7,1,33,1,13,14,1,13,5,1,13,1,16,1,3,13,13,13,3,1,1    00063600
      ,1,2,17,1,1,1,1,13,1,2,1,1,1,1,1,1,1,1,13,1,1,1,1,1,13,1,13,1,1,1,1,1,2   00063650
      ,34,1,1,1,1,1,1,1,1,1,1,1,29,1,1,1,1,1,1,7,11,10,2,9,8,1,2,1,1,1,1,1,1    00063700
      ,1,1,29,1,1,1,1,1,13,2,1,1,2,1,1,1,1,1,4,1,4,11,33,33,16,33,16,33,16,17   00063750
      ,17,14,14,3,14,1,1,1,1,1,1,13,1,1,1,1,1,4,2,9,1,1,8,4,1,6,4,1,2,2,2,7,2   00063800
      ,2,7,2,3,3,2,3,2,2,1,1,1,1,1,13,28,1,1,1,2,1,3,2,7,3,8,2,1,1,3,5,1,1,1    00063850
      ,1,9,4,2,1,2,1,15,2,5,4,9,3,3,5,3,3,10,5,3,3,3,2,2,2,2,2,3,4,2,3,3,3,3    00063900
      ,3,2,3,2,2,3,2,3,3,2,3,1,2,2,2,2,2,28,1,1,28,1,2,28,2,2,15,1,2,1,1,28     00063950
      ,12,33,26,39,1,1,14,23,1,1,2,2,29,29,29,29,29,4,1,1,1,1,13,13,2,1,2,2,2   00064000
      ,1,2,1,2,17,1,3,33,16,2,3,1,1,1,1,14,1,1,2,1,4,30,12,16,17,2,13,3,4,1,1   00064050
      ,5,1,4,3,1,1,4,1,11,1,2,3,2,3,3,2,1,1,2,4,34,12,12,13,5,4,2,2,1,1,3,31    00064100
      ,28,31,29,29,1,2,1,1,1,1,1,1,4,1,14,1,2,2,2,2,33,14,2,3,2,3,3,3,3,3,9     00064150
      ,10,10,4,10,5,5,10,10,10,10,4,3,3,3,3,3,2,3,7,2,5,4,3,3,3,3,2,3,3,3,3,4   00064200
      ,3,5,10,2,3,10,4,2,2,10,4,4,8,2,10,2,3,3,3,3,5,4,3,3,3,2,2,2,5,2,2,3,3    00064250
      ,2,2,2,2,3,2,3,2,10,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,10,10,5   00064300
      ,10,5,10,5,5,5,5,5,5,2,16,3,2,3,8,3,3,3,2,3,2,3,3,2,2,2,3,3,5,3,3,3,4,4   00064350
      ,3,4,3,3,2,3,3,3,3,3,3,4,3,3,5,5,5,7,3,5,3,10,7,10,2,3,3,3,3,5,5,5,5,5    00064400
      ,5,3,3,3,2,2,2,3,7,4,10,10,3,3,5,5,6,5,5,3,2,5,5,2,6,2,3,2,2,3,5,10,3,3   00064450
      ,5,2,2,4,9,5,9,5,5,5,3,3,3,10,3,3,5,6,7,8,9,11,17,18,19,20,22,24,25,26    00064500
      ,27,28,29,30,31,32,33,34,36,37,40,41,42,43,44,46,54,55,56,57,59,60,61     00064550
      ,62,65,67,68,69,75,80,82,83,85,88,90,92,93,94,95,98,100,101,103,105,106   00064600
      ,117,120,121,122,123,124,125,132,133,141,148,158,160,161,163,169,170      00064650
      ,178,180,181,182,183,185,186,187,188,189,190,191,192,193,194,195,196      00064700
      ,197,199,206,242,263,269,313,316,319,322,327,329,330,331,332,334,340      00064750
      ,341,342,343,344,345,350,351,353,354,358,361,363,364,365,372,378,380      00064800
      ,381,383,384,390,407,408,413,419,420,421,422,423,432,434,440,441,1,0,1    00064850
      ,0,1,1,2,2,0,2,0,2,2,1,0,2,0,2,0,0,0,1,0,0,0,0,0,3,0,3,0,1,1,0,1,0,0,0    00064900
      ,0,1,1,1,2,1,2,3,0,1,4,5,8,1,2,2,1,1,1,1,3,3,3,2,3,3,1,2,4,5,1,2,1,3,1    00064950
      ,3,3,1,3,1,2,0,0,0,0,0,0,2,0,3,2,3,0,1,0,2,1,3,0,2,0,2,0,1,0,0,1,1,1,1    00065000
      ,2,2,2,2,2,0,2,0,2,2,3,0,0,0,0,3,3,2,0,1,0,0,0,2,2,2,2,2,2,1,1,2,2,2,0    00065050
      ,1,2,3,2,3,1,1,1,4,0,0,1,1,2,1,0,2,1,3,2,3,0,1,1,2,3,3,1,1,1,3,2,1,0,2    00065100
      ,0,2,0,0,0,0,0,0,0,3,3,0,0,2,0,0,0,0,2,0,3,0,0,0,0,0,0,3,0,3,0,2,2,2,2    00065150
      ,2,1,2,2,2,2,0,2,0,1,2,0,1,0,1,1,0,1,4,1,1,1,0,1,0,0,1,2,1,0,0,0,2,2,0    00065200
      ,0,0,0,0,0,0,0,0,0,4,4,7,0,1,4,0,0,0,0,0,3,1,0,0,0,0,0,4,3,3,3,3,3,1,2    00065250
      ,1,2,0,0,0,0,3,3,3,3,0,0,1,2,1,2,2,2,1,1,1,0,1,1,1,0,1,1,1,1,1,0,0,1,0    00065300
      ,1,1,1,0,0,1,0,0,1,2,0,2,1,0,0,1,0,5,3,0,3,0,2,2,2,0,2,0,1,1,0,1,2,2,3    00065350
      ,3,1,1,1,2,2,0,1,0,1,1,0,0,2,0,0,0,0,1,2,0,1,0,0,0,0,0,0,0,3,3,0,0,1,2    00065400
      ,0,0,0,0,1,3,0,0,0,0,0,1,0,0,0,0,0,3,0,0,2,2,0,3,1,1,2,0,1,1,2,0,1,1,2    00065450
      ,0,0,0,0,0,0,0,1,1,0,0,0,2,0,1,2,2,2,0,4,1,0,0,1,2,2,0,1,1,1);            00065500
                                                                                00065550
/*CHANGED THE DECLARES FOR CHARTYPE, TX & LETTER_OR_DIGIT TO ARRAYS /*CR13335*/
   ARRAY   CHARTYPE(255) BIT(8) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00065600
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00065650
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00065700
      0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 4, 3, 3, 3, 7, 3, 0, 0, 0, 0, 0, 0,  00065750
      0, 0, 0, 0, 3, 8, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 12, 0, 3,  00065800
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 5, 3, 11, 0, 2, 2, 2, 2, 2, 2,  00065850
      2, 2, 2, 0, 10, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 10, 0, 0, 0, 00065900
      0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0,  00065950
      0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0,  00066000
      0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2,00066050
      2, 2, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 9, 0);  00066100
   ARRAY   TX(255) BIT(8) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066150
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066200
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066250
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066300
      0, 7, 8, 9, 10, 11, 12, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 15, 0, 0,00066350
      0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 17, 18, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0,  00066400
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066450
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066500
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066550
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066600
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);              00066650
   ARRAY   LETTER_OR_DIGIT(255) BIT(1) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  00066700
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066750
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066800
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00066850
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,00066900
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,00066950
      1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0,00067000
      0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00067050
      0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1,00067100
      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0,00067150
      0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0);           00067200
   ARRAY SET_CONTEXT(NT) BIT(8) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00067250
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,00067300
      0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00067350
      0, 1, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 1, 0, 0,  00067400
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 5, 1, 0, 0, 0, 0, 8, 0, 1,00067450
      0, 6, 0, 4, 0, 0, 1, 0, 0, 6, 0, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,00067500
      0, 0, 0, 0, 0, 0);                                                        00067550
   DECLARE ARITH_FUNC_TOKEN   FIXED INITIAL (130),                              00067600
      ARITH_TOKEN        FIXED INITIAL (126),                                   00067650
      BIT_FUNC_TOKEN     FIXED INITIAL (127),                                   00067700
      BIT_TOKEN          FIXED INITIAL (110),                                   00067750
      CHARACTER_STRING   FIXED INITIAL (132),                                   00067800
      CHAR_FUNC_TOKEN    FIXED INITIAL (129),                                   00067850
      CHAR_TOKEN         FIXED INITIAL (116),                                   00067900
      COMMA              FIXED INITIAL (14),                                    00067950
      CONCATENATE        FIXED INITIAL (20),                                    00068000
      CPD_NUMBER         FIXED INITIAL (137),                                   00068050
      CROSS_TOKEN        FIXED INITIAL (8),                                     00068100
      DECLARE_TOKEN      FIXED INITIAL (103),                                   00068150
      DOLLAR             FIXED INITIAL (7),                                     00068200
      DOT_TOKEN          FIXED INITIAL (1),                                     00068250
      DO_TOKEN           FIXED INITIAL (24),                                    00068300
      EOFILE             FIXED INITIAL (31),                                    00068350
      EVENT_TOKEN        FIXED INITIAL (128),                                   00068400
      EXPONENTIATE       FIXED INITIAL (21),                                    00068450
      FACTOR             FIXED INITIAL (156),                                   00068500
      ID_TOKEN           FIXED INITIAL (131),                                   00068550
      LABEL_DEFINITION   FIXED INITIAL (291),                                   00068600
      LAB_TOKEN          FIXED INITIAL (98),                                    00068650
      LEFT_PAREN         FIXED INITIAL (3),                                     00068700
      LEVEL              FIXED INITIAL (99),                                    00068750
      NO_ARG_ARITH_FUNC  FIXED INITIAL (141),                                   00068800
      NO_ARG_BIT_FUNC    FIXED INITIAL (138),                                   00068850
      NO_ARG_CHAR_FUNC   FIXED INITIAL (140),                                   00068900
      NO_ARG_STRUCT_FUNC FIXED INITIAL (142),                                   00068950
      NUMBER             FIXED INITIAL (136),                                   00069000
      REPLACE_TEXT       FIXED INITIAL (76),                                    00069050
      REPLACE_TOKEN      FIXED INITIAL (109),                                   00069100
      RT_PAREN           FIXED INITIAL (9),                                     00069150
      SEMI_COLON         FIXED INITIAL (10),                                    00069200
      STRUCTURE_WORD     FIXED INITIAL (123),                                   00069250
      STRUCT_FUNC_TOKEN  FIXED INITIAL (133),                                   00069300
      STRUCT_TEMPLATE    FIXED INITIAL (139),                                   00069350
      EXPONENT           FIXED INITIAL (144),                                   00069400
      STRUC_TOKEN        FIXED INITIAL (135),                                   00069450
      PERCENT_MACRO      FIXED INITIAL (134),                                   00069500
      TEMPORARY          FIXED INITIAL (124),                                   00069550
      EQUATE_TOKEN       FIXED INITIAL (82);                                    00069600
   DECLARE RESERVED_LIMIT FIXED INITIAL (9);                                    00069650
   DECLARE IF_TOKEN FIXED INITIAL (26);                                         00069660
   DECLARE SUB_START_TOKEN FIXED INITIAL (206);                                 00069670
                                                                                00137500
                                                                                00137600
                                                                                00137700
 /*  DECLARATIONS FOR THE SCANNER                                        */     00137800
                                                                                00137900
 /* TOKEN IS THE INDEX INTO THE VOCABULARY V() OF THE LAST SYMBOL SCANNED,      00138000
      BCD IS THE LAST SYMBOL SCANNED (LITERAL CHARACTER STRING). */             00138100
   DECLARE TOKEN FIXED, BCD CHARACTER;                                          00138200
   DECLARE CLOSE_BCD CHARACTER;                                                 00138300
                                                                                00138400
   DECLARE EXPRESSION_CONTEXT BIT(16) INITIAL(1),                               00138500
      DECLARE_CONTEXT BIT(16) INITIAL (5),                                      00138600
      PARM_CONTEXT BIT(16) INITIAL (6),                                         00138700
      ASSIGN_CONTEXT BIT(16) INITIAL (7),                                       00138800
      REPLACE_PARM_CONTEXT BIT(16) INITIAL (10),                                00138900
      EQUATE_CONTEXT BIT(16) INITIAL(11),                                       00139000
      REPL_CONTEXT BIT(16) INITIAL (8);                                         00139100
                                                                                00139200
 /* SET UP SOME CONVENIENT ABBREVIATIONS FOR PRINTER CONTROL */                 00139300
   DECLARE EJECT_PAGE LITERALLY 'OUTPUT(1) = PAGE',                             00139400
      PAGE CHARACTER INITIAL ('1'), DOUBLE CHARACTER INITIAL ('0'),             00139500
      PLUS CHARACTER INITIAL('+'),                                              00139600
      DOUBLE_SPACE LITERALLY 'OUTPUT(1) = DOUBLE',                              00139700
      X70 CHARACTER INITIAL ('                                                  00139800
                    ');                                                         00139900
   DECLARE X256 CHARACTER INITIAL(   '                                          00139910
                                                                                00139920
                                                                                00139930
                                                  ');                           00139940
                                                                                00140000
 /* CHARTYPE() IS USED TO DISTINGUISH CLASSES OF SYMBOLS IN THE SCANNER.        00140100
      TX() IS A TABLE USED FOR TRANSLATING FROM ONE CHARACTER SET TO ANOTHER.   00140200
      LETTER_OR_DIGIT IS SIMILAR TO CHARTYPE() BUT IS USED IN SCANNING          00140300
      IDENTIFIERS ONLY.                                                         00140400
   */                                                                           00140500
                                                                                00140600
   DECLARE (ERROR_COUNT, MAX_SEVERITY) FIXED;              /*DR108629*/         00140700
   DECLARE (STATEMENT_SEVERITY) FIXED;                                          00140800
   DECLARE VALUE FIXED;                                                         00140900
                                                                                00141000
                                                                                00141100
                                                                                00141200
 /* DECLARATIONS FOR MACRO PROCESSING */                                        00141300
   DECLARE MACRO_EXPAN_LIMIT LITERALLY '8', MAX_PARAMETER LITERALLY '12';       00141400
   DECLARE PARM_EXPAN_LIMIT LITERALLY '8';                                      00141500
   DECLARE  (MACRO_EXPAN_LEVEL,OLD_PR_PTR) BIT(16),                             00141600
      MACRO_CELL_LIM BIT(16) INITIAL(1000),                                     00141610
      M_TOKENS(MACRO_EXPAN_LIMIT) FIXED INITIAL(2),                             00141700
      (OLD_MEL,NEW_MEL,TEMP_INDEX,PARM_COUNT,OLD_PEL) BIT(16),                  00141800
      (MACRO_NAME, TEMP_STRING) CHARACTER,                                      00141900
      (MACRO_EXPAN_STACK,BASE_PARM_LEVEL,NUM_OF_PARM,                           00142000
      M_BLANK_COUNT) (MACRO_EXPAN_LIMIT) BIT(16),                               00142100
      M_CENT(MACRO_EXPAN_LIMIT) BIT(8),                                         00142200
      P_CENT(PARM_EXPAN_LIMIT)  BIT(8),                                         00142300
      (MAC_NUM, MACRO_ARG_COUNT) BIT(16),                                       00142400
      FIRST_TIME(MACRO_EXPAN_LIMIT) BIT(1) INITIAL(1,1,1,1,1,1,1,1,1),          00142500
      FOUND_CENT BIT(1),                                                        00142600
      (MACRO_POINT, OLD_MP) FIXED, M_P(MACRO_EXPAN_LIMIT) FIXED,                00142700
      MACRO_CALL_PARM_TABLE(MACRO_EXPAN_LIMIT*MAX_PARAMETER) CHARACTER,         00142800
      (PARM_STACK_PTR,PARM_REPLACE_PTR) (PARM_EXPAN_LIMIT) BIT(16),             00142900
      (TOP_OF_PARM_STACK, PARM_EXPAN_LEVEL) BIT(16),                            00143000
      (ONE_BYTE, SOME_BCD) CHARACTER,                                           00143100
      (PASS,RESTORE) BIT(16),                                                   00143200
      M_PRINT(MACRO_EXPAN_LIMIT) BIT(16),                                       00143300
      (T_INDEX, START_POINT) FIXED,                                             00143400
      FIRST_TIME_PARM(PARM_EXPAN_LIMIT) BIT(1) INITIAL(1,1,1,1,1,1,1,1,1),      00143600
      DONT_SET_WAIT BIT(1),                                                     00143700
      MAC_XREF(MACRO_EXPAN_LIMIT) BIT(16),                                      00143710
      MAC_CTR BIT(16) INITIAL(-1),                                              00143720
      SAVE_PE BIT(16),                                                          00143800
      OLD_TOPS BIT(16),                                                         00143900
      SUPPRESS_THIS_TOKEN_ONLY BIT(1),                                          00144000
      MACRO_FOUND BIT(1);                                                       00144100
   DECLARE (MACRO_ADDR,MACRO_TEXT_LIM,REPLACE_TEXT_PTR) FIXED;                  00144200
   BASED MACRO_TEXTS RECORD DYNAMIC:                                            00144300
         MAC_TXT      BIT(8),                                                   00144310
      END;                                                                      00144320
                                                                                00144400
   DECLARE (COMPILING, RECOVERING) BIT(1);                                      00144500
                                                                                00144600
   DECLARE S CHARACTER;  /* A TEMPORARY USED VARIOUS PLACES */                  00144700
   DECLARE C(2) CHARACTER;  /* TEMPORARIES USED VARIOUS PLACES */               00144800
   DECLARE CURRENT_SCOPE CHARACTER;                                             00144900
                                                                                00145000
                                                                                00145100
   DECLARE (CONTEXT, PROCMARK, REGULAR_PROCMARK) FIXED;                         00145200
   DECLARE MAIN_SCOPE BIT(16);                                                  00145300
   DECLARE DO_INIT BIT(1) INITIAL(0);                                           00145400
   DECLARE IMPLIED_TYPE BIT(16);                                                00145500
                                                                                00145600
                                                                                00145700
   DECLARE SYTSIZE FIXED,                                                       00145800
      XREF_LIM FIXED;                                                           00146000
   /%INCLUDE COMMON %/                                                          00146200
      BASED LINK_SORT RECORD DYNAMIC:                                           00148300
         SYM_HASHLINK            BIT(16),                                       00148400
         SYM_SORT                BIT(16),                                       00148500
      END;                                                                      00148600
   DECLARE PHASE1_FREESIZE FIXED;
                                                                                00150300
   DECLARE BIT_TYPE       LITERALLY '1',                                        00150900
      CHAR_TYPE      LITERALLY '2',                                             00151000
      MAT_TYPE       LITERALLY '3',                                             00151100
      VEC_TYPE       LITERALLY '4',                                             00151200
      SCALAR_TYPE    LITERALLY '5',                                             00151300
      INT_TYPE       LITERALLY '6',                                             00151400
      IORS_TYPE      LITERALLY '8',                                             00151600
      EVENT_TYPE     LITERALLY '9',                                             00151700
      MAJ_STRUC      LITERALLY '10',                                            00151800
      ANY_TYPE       LITERALLY '11',                                            00151900
                                                                                00152000
      TEMPL_NAME     LITERALLY '"3E"',                                          00152100
      STMT_LABEL     LITERALLY '"42"',                                          00152400
      UNSPEC_LABEL   LITERALLY '"43"',                                          00152500
      IND_CALL_LAB   LITERALLY '"45"',                                          00152700
      CALLED_LABEL   LITERALLY '"46"',                                          00152800
      PROC_LABEL     LITERALLY '"47"',                                          00152900
      TASK_LABEL     LITERALLY '"48"',                                          00153000
      PROG_LABEL     LITERALLY '"49"',                                          00153100
      COMPOOL_LABEL  LITERALLY '"4A"',                                          00153200
      EQUATE_LABEL   LITERALLY '"4B"';                                          00153300
   BASED INIT_APGAREA  RECORD:                                                  00153400
         AREAPG (1260) FIXED,                                                   00153410
      END;                                                                      00153420
   BASED INIT_AFCBAREA RECORD:                                                  00153430
         AREAFCB (128) FIXED,                                                   00153440
      END;                                                                      00153450
   BASED SAVE_PATCH RECORD DYNAMIC:                                             00153740
         SAVE_LINE CHARACTER,                                                   00153760
      END;                                                                      00153780
   DECLARE PATCHSAVE(1) LITERALLY 'SAVE_PATCH(%1%).SAVE_LINE';                  00153800
 /* COMM EQUAIVALENCES */                                                       00154400
   DECLARE LIT_CHAR_AD   LITERALLY 'COMM(0)',
      LIT_CHAR_USED LITERALLY 'COMM(1)',                                        00154600
      LIT_TOP       LITERALLY 'COMM(2)',                                        00154700
      STMT_NUM      LITERALLY 'COMM(3)',                                        00154800
      FL_NO         LITERALLY 'COMM(4)',                                        00154900
      MAX_SCOPE#    LITERALLY 'COMM(5)',                                        00155000
      TOGGLE        LITERALLY 'COMM(6)',                                        00155100
      OPTIONS_CODE  LITERALLY 'COMM(7)',                                        00155200
      XREF_INDEX    LITERALLY 'COMM(8)',                                        00155300
      FIRST_FREE    LITERALLY 'COMM(9)',                                        00155400
      NDECSY        LITERALLY 'COMM(10)',                                       00155410
      FIRST_STMT    LITERALLY 'COMM(11)',                                       00155420
      TIME_OF_COMPILATION LITERALLY 'COMM(12)',                                 00155430
      DATE_OF_COMPILATION LITERALLY 'COMM(13)';                                 00155440
   DECLARE INCLUDE_LIST_HEAD LITERALLY 'COMM(14)';                              00155445
   DECLARE MACRO_BYTES   LITERALLY 'COMM(15)';                                  00155450
   DECLARE STMT_DATA_HEAD LITERALLY 'COMM(16)';                                 00155460
   DECLARE BLOCK_SRN_DATA LITERALLY 'COMM(18)';                                 00155470
   BASED SRN_BLOCK_RECORD FIXED;                                                00155480
   DECLARE COMSUB_END LITERALLY 'COMM(17)';                                     00155490
   DECLARE VAR_CLASS   BIT(8) INITIAL (1),                                      00155500
      LABEL_CLASS BIT(8) INITIAL (2),                                           00155600
      FUNC_CLASS  BIT(8) INITIAL (3),                                           00155700
      REPL_ARG_CLASS BIT(8) INITIAL (5),                                        00155800
      REPL_CLASS BIT(8) INITIAL(6),                                             00155900
      TEMPLATE_CLASS BIT(8) INITIAL(7),  /*  DONT REORDER ANY CLASSES */        00156000
      TPL_LAB_CLASS BIT(8) INITIAL(8),   /*  BECAUSE OF SNEAKY        */        00156100
      TPL_FUNC_CLASS BIT(8) INITIAL(9);  /*  INDEXING                 */        00156200
                                                                                00156300
   DECLARE SCOPE# BIT(16);                                                      00156400
   DECLARE (KIN,QUALIFICATION) BIT(16);                                         00156500
   DECLARE SYT_INDEX FIXED;                                                     00156600
                                                                                00156700
   DECLARE X32 CHARACTER INITIAL ('                                ');          00156800
                                                                                00156900
   DECLARE SYT_HASHSIZE LITERALLY '997';                                        00157000
   ARRAY   SYT_HASHSTART(SYT_HASHSIZE) BIT(16);                                 00157100
                                                                                00157200
   DECLARE NEST_LIM LITERALLY '16', NEST FIXED;                                 00157300
                                                                                00157400
   DECLARE DEFAULT_TYPE BIT(16) INITIAL (5),          /*  SCALAR  */            00157500
      DEF_BIT_LENGTH BIT(16) INITIAL (1),        /*  BOOLEAN  */                00157600
      DEF_CHAR_LENGTH BIT(16) INITIAL (8),                                      00157700
      DEF_MAT_LENGTH BIT(16) INITIAL ("0303"),                                  00157800
      DEF_VEC_LENGTH BIT(16) INITIAL (3),                                       00157900
      DEFAULT_ATTR FIXED INITIAL ("00800208");                                  00158000
                                                                                00158100
   DECLARE BLOCK_MODE(NEST_LIM) BIT(8),                                         00158200
      BLOCK_SYTREF(NEST_LIM) BIT(16),                                           00158300
      EXTERNAL_MODE BIT(8),                                                     00158400
      PROC_MODE BIT(8) INITIAL (1),                                             00158500
      FUNC_MODE BIT(8) INITIAL (2),                                             00158600
      CMPL_MODE BIT(8) INITIAL (3),                                             00158700
      PROG_MODE BIT(8) INITIAL (4),                                             00158800
      TASK_MODE BIT(8) INITIAL (5),                                             00158900
      UPDATE_MODE BIT(8) INITIAL(6),                                            00159000
      INLINE_MODE BIT(8) INITIAL(7);                                            00159100
                                                                                00159200
   DECLARE HOST_BIT_LENGTH_LIM LITERALLY '32',  /* FOR 360/370 */               00159300
      BIT_LENGTH_LIM  BIT(16) INITIAL(HOST_BIT_LENGTH_LIM),                     00159310
      CHAR_LENGTH_LIM BIT(16) INITIAL (255),                                    00159400
      VEC_LENGTH_LIM  BIT(16) INITIAL(64),                                      00159500
      MAT_DIM_LIM     BIT(16) INITIAL (64),                                     00159600
      ARRAY_DIM_LIM   BIT(16) INITIAL (32767),                                  00159700
      N_DIM_LIM       LITERALLY '3',                                            00159800
      N_DIM_LIM_PLUS_1 LITERALLY '4';                                           00159900
                                                                                00160000
                                                                                00160100
   DECLARE PROCMARK_STACK(NEST_LIM) BIT(16);                                    00160200
                                                                                00160300
   DECLARE SCOPE#_STACK(NEST_LIM) BIT(16);                                      00160400
                                                                                00160500
   DECLARE INDENT_STACK(NEST_LIM) BIT(16);                                      00160600
   DECLARE NEST_LEVEL BIT(16), NEST_STACK(NEST_LIM) BIT(16);                    00160610
   DECLARE FACTORING BIT(16) INITIAL (1), EXP_OVERFLOW BIT(1);                  00160700
   DECLARE FACTOR_LIM LITERALLY '19';    /*DR109024*/                           00160800
        /* DR109024 - FACTOR_LIM IS USED IN A LOOP IN SYNTHESIS
           AND IN RECOVER TO SET THE NEXT TWO DECLARES.  SO,
           THOSE DECLARES MUST PARALLEL EACH OTHER (I.E. THERE MUST
           BE A 'FACTORED_XXX' FOR EVERY 'XXX'), AND FACTOR_LIM
           MUST BE THE TOTAL NUMBER OF FIXED VARIABLES IN EACH
           DECLARE.

           ALSO, IF FACTORED_ATTRIBUTES2 IS TO BE USED FOR
           ANYTHING, YOU SHOULD CHECK MODULE CHECKCO2
           TO SEE IF A CHECK FOR CONFLICT NEEDS TO BE ADDED
           TO THAT MODULE.  IT WAS NOT NECESSARY FOR DR109024
         */
                                                                                00160900
   DECLARE (TYPE,                                                               00161000
      BIT_LENGTH,                                                               00161100
      CHAR_LENGTH,                                                              00161200
      MAT_LENGTH,                                                               00161300
      VEC_LENGTH,                                                               00161400
      ATTRIBUTES,                                                               00161500
      ATTRIBUTES2,                        /*DR109024*/                          00161500
      ATTR_MASK,                                                                00161600
      STRUC_PTR,                                                                00161700
      STRUC_DIM,                                                                00161800
      CLASS,                                                                    00161900
      NONHAL,                                                                   00162000
      LOCK#,                                                                    00162100
      IC_PTR,                                                                   00162200
      IC_FND,                                                                   00162300
      N_DIM) FIXED,                                                             00162400
      S_ARRAY(N_DIM_LIM) FIXED;                                                 00162500
                                                                                00162600
   DECLARE (FACTORED_TYPE,                                                      00162700
      FACTORED_BIT_LENGTH,                                                      00162800
      FACTORED_CHAR_LENGTH,                                                     00162900
      FACTORED_MAT_LENGTH,                                                      00163000
      FACTORED_VEC_LENGTH,                                                      00163100
      FACTORED_ATTRIBUTES,                                                      00163200
      FACTORED_ATTRIBUTES2,                        /*DR109024*/                 00161500
      FACTORED_ATTR_MASK,                                                       00163300
      FACTORED_STRUC_PTR,                                                       00163400
      FACTORED_STRUC_DIM,                                                       00163500
      FACTORED_CLASS,                                                           00163600
      FACTORED_NONHAL,                                                          00163700
      FACTORED_LOCK#,                                                           00163800
      FACTORED_IC_PTR,                                                          00163900
      FACTORED_IC_FND,                                                          00164000
      FACTORED_N_DIM) FIXED,                                                    00164100
      FACTORED_S_ARRAY(N_DIM_LIM) FIXED;                                        00164200
                                                                                00164300
   DECLARE LOCK_LIM BIT(8) INITIAL(15),                                         00164400
      ASSIGN_ARG_LIST BIT(1);                                                   00164500
   DECLARE EXT_ARRAY_PTR FIXED INITIAL(1);                                      00164600
   DECLARE STRUC_SIZE FIXED;                                                    00164700
   DECLARE STARRED_DIMS BIT(16);                                                00164800
                                                                                00164900
 /*  THE FOLLOWING ARE USED IN PARSING PRODUCTS   */                            00165000
   DECLARE (TERMP,PP,PPTEMP,BEGINP,SCALARP,VECTORP,MATRIXP,                     00165100
      MATRIX_PASSED,CROSS_COUNT,DOT_COUNT,SCALAR_COUNT,VECTOR_COUNT,            00165200
      MATRIX_COUNT) FIXED;                                                      00165300
   DECLARE CROSS FIXED INITIAL (10), DOT FIXED INITIAL (11);                    00165400
   DECLARE CONTROL(16) BIT(1);  /* INPUT CONTROLABLE SWITCHES */                00165500
   DECLARE XREF_FULL BIT(1),                                                    00165600
      XREF_MASK FIXED INITIAL ("1FFF"),                                         00165700
      XREF_ASSIGN FIXED INITIAL ("8000"),                                       00165800
      XREF_REF    FIXED INITIAL ("4000"),                                       00165900
      XREF_SUBSCR FIXED INITIAL ("2000");                                       00166000
   DECLARE OUTER_REF_LIM BIT(16),                                               00166100
      OUTER_REF_MAX BIT(16),                                                    00166110
      OUTER_REF_INDEX BIT(16);                                                  00166200
   DECLARE PAGE_THROWN BIT(1) INITIAL(1); /* PREVENT NEW PAGE ON PROG DEF */    00166400
   BASED OUTER_REF_TABLE RECORD DYNAMIC:                                        00166500
         OUT_REF                   BIT(16),                                     00166520
         OUT_REF_FLAGS             BIT(8),                                      00166540
      END;                                                                      00166560
   DECLARE OUTER_REF_PTR(NEST_LIM) BIT(16);                                     00166600
   DECLARE PROGRAM_LAYOUT_LIM LITERALLY '255',                                  00166700
      PROGRAM_LAYOUT_INDEX BIT(16);                                             00166800
   ARRAY   PROGRAM_LAYOUT(PROGRAM_LAYOUT_LIM) BIT(16);                          00166900
   DECLARE CASE_LEVEL_LIM LITERALLY '10';                                       00167000
   DECLARE CASE_STACK(CASE_LEVEL_LIM) BIT(16);                                  00167100
   DECLARE CASE_LEVEL BIT(16); /* INITIALIZED TO -1 IN INITIALIZATION */        00167200
                                                                                00167300
   DECLARE (ID_LOC,REF_ID_LOC) FIXED;                                           00167400
                                                                                00167500
   DECLARE (MAXSP, REDUCTIONS, SCAN_COUNT, MAXNEST, IDENT_COUNT) FIXED;         00167600
                                                                                00167800
 /* RECORD THE TIMES OF IMPORTANT POINTS DURING CHECKING */                     00167900
   DECLARE CLOCK(5) FIXED;                                                      00168000
                                                                                00168100
                                                                                00168200
 /* COMMONLY USED STRINGS */                                                    00168300
   DECLARE X1 CHARACTER INITIAL(' '), X4 CHARACTER INITIAL('    ');             00168400
   DECLARE X2 CHARACTER INITIAL('  ');                                          00168500
  DECLARE X109 CHARACTER INITIAL('                                              00168510
                                                                     ');        00168520
   DECLARE PERIOD CHARACTER INITIAL ('.');                                      00168600
   DECLARE SQUOTE CHARACTER INITIAL('''');                          /*CR13335*/
                                                                                00168700
 /* TEMPORARIES USED THROUGHOUT THE COMPILER */                                 00168800
   DECLARE (I, J, K, L) FIXED;                                                  00168900
                                                                                00169000
   DECLARE TRUE LITERALLY '1', FALSE LITERALLY '0', FOREVER LITERALLY 'WHILE 1';00169100
                                                                                00169200
   DECLARE NO_LOOK_AHEAD_DONE BIT(1);                                           00169300
 /*  THE STACKS DECLARED BELOW ARE USED TO DRIVE THE SYNTACTIC                  00169600
      ANALYSIS ALGORITHM AND STORE INFORMATION RELEVANT TO THE INTERPRETATION   00169700
      OF THE TEXT.  THE STACKS ARE ALL POINTED TO BY THE STACK POINTER SP.  */  00169800
                                                                                00169900
   DECLARE STACKSIZE LITERALLY '75';  /* SIZE OF STACK  */                      00170000
   DECLARE PARSE_STACK (STACKSIZE) BIT(9);   /*  TOKENS OF THE PARTIALLY PARSED 00170100
                                              TEXT */                           00170200
   DECLARE LOOK BIT(16);                                            /*CR13335*/ 00170300
   ARRAY LOOK_STACK(STACKSIZE) BIT(16);                             /*CR13335*/ 00170400
   ARRAY STATE_STACK(STACKSIZE) FIXED;                                          00170500
   DECLARE STATE FIXED;                                                         00170600
   DECLARE VAR(STACKSIZE) CHARACTER,                                            00170700
      FIXV(STACKSIZE) FIXED,                                                    00170800
      FIXL(STACKSIZE) FIXED,                                                    00170900
      FIXF(STACKSIZE) BIT(16),                                                  00171000
      PTR(STACKSIZE) BIT(16);                                                   00171100
                                                                                00171200
 /* SP POINTS TO THE RIGHT END OF THE REDUCIBLE STRING IN THE PARSE STACK,      00171300
      MP POINTS TO THE LEFT END, AND                                            00171400
      MPP1 = MP+1.                                                              00171500
   */                                                                           00171600
   DECLARE (SP, MP, MPP1) FIXED;                                                00171700
                                                                                00171800
   DECLARE NT_PLUS_1 BIT(16);                                                   00171900
                                                                                00172000
  DECLARE (SAVE_OVER_PUNCH,SAVE_NEXT_CHAR) BIT(8),(OLD_LEVEL,NEW_LEVEL) BIT(16),00172100
      (NEXT_CHAR, OVER_PUNCH) BIT(8),                                           00172200
      (TEMP1, TEMP2, TEMP3) FIXED,                                              00172300
      (EXP_TYPE, BLANK_COUNT, SAVE_BLANK_COUNT) BIT(16),                        00172400
      (STRING_OVERFLOW, LABEL_IMPLIED, TEMPLATE_IMPLIED, EQUATE_IMPLIED) BIT(1);00172500
   DECLARE (IMPLIED_UPDATE_LABEL, NAME_HASH) FIXED;                             00172600
   DECLARE (INLINE_LEVEL,INLINE_LABEL) BIT(16);                                 00172700
   DECLARE MAX_STRUC_LEVEL LITERALLY '5',                                       00172900
      OVER_PUNCH_SIZE LITERALLY '4',                                            00173000
      ID_LIMIT LITERALLY '32',                                                  00173600
      MAX_STRING_SIZE LITERALLY '256';                                          00173700
   ARRAY OVER_PUNCH_TYPE(10) FIXED INITIAL(                         /*CR13335*/ 00173100
         "40","4B","6B","5C","60","40","40","40","40","40","4E");   /*CR13335*/ 00173200
   DECLARE CARD_COUNT FIXED;                                                    00173800
   DECLARE ALMOST_DISASTER LABEL;                                               00174000
                                                                                00174100
 /* THE INDIRECT STACKS AND POINTER ARE DEFINED BELOW                   */      00174200
   DECLARE PTR_MAX LITERALLY 'STACKSIZE';   /* SAME AS STACKSIZE FOR NOW */     00174300
   DECLARE INX(PTR_MAX) BIT(16),                                                00174400
      LOC_P(PTR_MAX) BIT(16),                                                   00174500
      VAL_P(PTR_MAX) BIT(16),                                                   00174600
      EXT_P(PTR_MAX) BIT(16),                                                   00174700
      PSEUDO_TYPE(PTR_MAX) BIT(8),                                              00174800
      PSEUDO_FORM(PTR_MAX) BIT(8),                                              00174900
      PSEUDO_LENGTH(PTR_MAX) BIT(16);                                           00175000
   DECLARE PTR_TOP BIT(16) INITIAL(1);/*1ST ENTRY DUMMY,CONTAINS LAST PTR USED*/00175100
   DECLARE MAX_PTR_TOP FIXED;                                                   00175200
   DECLARE BI_LIMIT LITERALLY '9';                                              00175300
   DECLARE BI# LITERALLY '63',                                                  00175400
      BI_XREF_CELL LITERALLY 'COMM(29)',                                        00175405
                                                                                00175410
 /* LITERALS FOR SHAPING FUNCTION INDEXES INTO BI_XREF AND BI_XREF# */          00175415
      BIT_NDX  LITERALLY '57',                                                  00175420
      SBIT_NDX LITERALLY '58',                                                  00175425
      INT_NDX  LITERALLY '59',                                                  00175430
      SCLR_NDX LITERALLY '60',                                                  00175435
      VEC_NDX  LITERALLY '61',                                                  00175440
      MTX_NDX  LITERALLY '62',                                                  00175445
      CHAR_NDX LITERALLY '63';                                                  00175450
                                                                                00175455
   DECLARE SYT_MAX BIT(16) INITIAL(32765-BI#);                                  00175465
 /* THE SYMBOL TABLE IS INDEXED INTO BY A BIT(16), AND THE UPPER POSSI          00175475
      SYMBOL TABLE INDEXES ARE USED TO DISTINGUISH BUILT-IN FUNCTIONS */        00175485
   DECLARE NEXTIME_LOC BIT(16) INITIAL(50);                                     00175500
   DECLARE BI_FUNC_FLAG BIT(8);                                                 00175600
   DECLARE BI_INDEX(BI_LIMIT) BIT(16) INITIAL(0,1,1,17,28,35,44,53,54,57);      00175700
   ARRAY BI_INFO(BI#) BIT(32) INITIAL(                                          00175800
      "00000000", /* UNUSED */                                                  00175900
      "08010001", /* ABS */                                                     00176000
      "05012709", /* COS */                                                     00176100
      "0501000C", /* DET */                                                     00176200
      "06020007", /* DIV */                                                     00176300
      "05010909", /* EXP */                                                     00176400
      "05014A09", /* LOG */                                                     00176500
      "08010001", /* MAX */                                                     00176600
      "08010001", /* MIN */                                                     00176700
      "08020001", /* MOD */                                                     00176800
      "01010007", /* ODD */                                                     00176900
      "06020007", /* SHL */                                                     00177000
      "06020007", /* SHR */                                                     00177100
      "05012609", /* SIN */                                                     00177200
      "08010001", /* SUM */                                                     00177300
      "05012809", /* TAN */                                                     00177400
      "01020003", /* XOR */                                                     00177500
      "05010009", /* COSH */                                                    00177600
      "06000100", /* DATE */                                                    00177700
      "06000000", /* PRIO */                                                    00177800
      "08010001", /* PROD */                                                    00177900
      "08010001", /* SIGN */                                                    00178000
      "05010009", /* SINH */                                                    00178100
      "0601000D", /* SIZE */                                                    00178200
      "05010B09", /* SQRT */                                                    00178300
      "05010009", /* TANH */                                                    00178400
      "02010005", /* TRIM */                                                    00178500
      "0401000E", /* UNIT */                                                    00178600
      "0501000E", /* ABVAL */                                                   00178700
      "06010001", /* FLOOR */                                                   00178800
      "06020005", /* INDEX */                                                   00178900
      "02020006", /* LJUST */                                                   00179000
      "02020006", /* RJUST */                                                   00179100
      "06010001", /* ROUND */                                                   00179200
      "0501000C", /* TRACE */                                                   00179300
      "05010009", /* ARCCOS */                                                  00179400
      "05010009", /* ARCSIN */                                                  00179500
      "05010009", /* ARCTAN */                                                  00179600
      "06000000", /* ERRGRP */                                                  00179700
      "06000000", /* ERRNUM */                                                  00179800
      "06010005", /* LENGTH */                                                  00179900
      "05030009", /* MIDVAL */                                                  00180000
      "05000000", /* RANDOM */                                                  00180100
      "08010001", /* SIGNUM */                                                  00180200
      "05010009", /* ARCCOSH */                                                 00180300
      "05010009", /* ARCSINH */                                                 00180400
      "05010009", /* ARCTANH */                                                 00180500
      "05020009", /* ARCTAN2 */                                                 00180600
      "06010001", /* CEILING */                                                 00180700
      "0301000C", /* INVERSE */                                                 00180800
      "05010003", /* NEXTIME */                                                 00180900
      "05000000", /* RANDOMG */                                                 00181000
      "05000000", /* RUNTIME */                                                 00181100
      "06010001", /* TRUNCATE */                                                00181200
      "05000200", /* CLOCKTIME */                                               00181300
      "06020007", /* REMAINDER */                                               00181400
      "0301000C");/* TRANSPOSE */                                               00181500
   ARRAY BI_ARG_TYPE(14) BIT(8) INITIAL(                                        00181600
      0,    /* (0) UNUSED */                                                    00181700
      8,    /* (1) IORS */                                                      00181800
      8,    /* (2) IORS */                                                      00181900
      1,    /* (3) BIT */                                                       00182000
      1,    /* (4) BIT */                                                       00182100
      2,    /* (5) CHARACTER */                                                 00182200
      2,    /* (6) CHARACTER */                                                 00182300
      6,    /* (7) INTEGER */                                                   00182400
      6,    /* (8) INTEGER */                                                   00182500
      5,    /* (9) SCALAR */                                                    00182600
      5,    /* (A) SCALAR */                                                    00182700
      5,    /* (B) SCALAR */                                                    00182800
      3,    /* (C) MATRIX */                                                    00182900
      "B",  /* (D) ANY */                                                       00183000
      4);   /* (E) VECTOR */                                                    00183100
   ARRAY BI_FLAGS(BI#) BIT(8) INITIAL(                                          00183200
      "00", "00", "00", "40", "00", "00", "00", "20", "20", "00", /*  0- 9 */   00183300
      "00", "00", "00", "00", "20", "00", "00", "00", "10", "00", /* 10-19 */   00183400
      "20", "00", "00", "30", "00", "00", "00", "00", "00", "00", /* 20-29 */   00183500
      "00", "00", "00", "00", "40", "00", "00", "00", "00", "00", /* 30-39 */   00183600
      "00", "00", "00", "00", "00", "00", "00", "00", "00", "40", /* 40-49 */   00183700
      "00", "00", "00", "00", "10", "00", "80");                  /* 50-56 */   00183800
   ARRAY BI_XREF(BI#) BIT(16);                                                  00183900
   ARRAY BI_XREF#(BI#) BIT(16);                                                 00183910
/* BI_LOC & BI_INDX WERE CREATED TO LOCATE THE BUILT-IN FUNCTION    /*CR13335*/
/* NAME IN BI_NAME. BI_NAME WAS CHANGED FROM A 63 STRING ARRAY TO   /*CR13335*/
/* A 3 STRING ARRAY BECAUSE PASS1 WAS CLOSE TO REACHING THE         /*CR13335*/
/* MAXIMUM NUMBER OF ALLOWABLE STRINGS.                             /*CR13335*/
   ARRAY BI_LOC(BI#) BIT(8) INITIAL(0, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90,
   100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 0, 10, 20, 30, 40, 50, 60,
   70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 0, 10, 20, 30,
   40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 0,
   10, 20);
   ARRAY BI_INDX(BI#) BIT(4) INITIAL(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
   1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3);
   DECLARE BI_NAME(3) CHARACTER                                                 00184000
    INITIAL('ABS       COS       DET       DIV       EXP       LOG       MAX
   MIN       MOD       ODD       SHL       SHR       SIN       SUM       TAN    00184100
   XOR       COSH      DATE      PRIO      PROD      ',                         00184200
  'SIGN      SINH      SIZE      SQRT      TANH      TRIM      UNIT      ABVAL  00184300
   FLOOR     INDEX     LJUST     RJUST     ROUND     TRACE     ARCCOS    ARCSIN 00184400
   ARCTAN    ERRGRP    ERRNUM    LENGTH    ',                                   00184500
  'MIDVAL    RANDOM    SIGNUM    ARCCOSH   ARCSINH   ARCTANH   ARCTAN2   CEILING00184600
   INVERSE   NEXTIME   RANDOMG   RUNTIME   TRUNCATE  CLOCKTIME REMAINDER TRANSPO00184700
SE BIT       SUBBIT    INTEGER   SCALAR    ',                                   00184710
  'VECTOR    MATRIX    CHARACTER ');
                                                                                00184800
 /*   CURRENT ARRAYNESS DECLARATIONS  */                                        00184900
   DECLARE CURRENT_ARRAYNESS(N_DIM_LIM_PLUS_1) BIT(16),                         00185000
      ARRAYNESS_FLAG BIT(8),                                                    00185100
      AS_PTR_MAX LITERALLY '20',                                                00185200
      AS_PTR BIT(16),                                                           00185300
      VAR_ARRAYNESS(N_DIM_LIM_PLUS_1) BIT(16),                                  00185400
      SAVE_ARRAYNESS_FLAG BIT(8),                                               00185500
      ARRAYNESS_STACK(AS_PTR_MAX) BIT(16);                                      00185600
                                                                                00185800
   DECLARE SUBSCRIPT_LEVEL BIT(16) ;                                            00185900
   DECLARE EXPONENT_LEVEL BIT(16);                                              00186000
   DECLARE NEXT_SUB BIT(16) ;                                                   00186100
   DECLARE DEVICE_LIMIT LITERALLY '9',                                          00186300
      ON_ERROR_PTR BIT(16) INITIAL(EXT_SIZE);                                   00186400
   DECLARE TEMP FIXED ;    /*  TEMPORARY FULL WORD   */                         00186500
   DECLARE TEMP_SYN FIXED ;        /* TEMPORARY USED ONLY ON SYTH DO CASE       00186600
                                     LEVEL, NOT IN CALLED ROUTINES         */   00186700
   DECLARE REL_OP BIT(16) ;                                                     00186800
   DECLARE NUM_ELEMENTS FIXED;    /*DR111367-COUNTS DISPLACEMENT FOR I/C LIST */00186900
   DECLARE NUM_FL_NO BIT (16);    /* COUNTS NO OF FL_NO NEEDED BY I/C LIST  */  00187000
   DECLARE NUM_STACKS BIT(16);    /* COUNTS NO INDIRECT STACKS I/C LIST NEEDS */00187100
   DECLARE IC_FOUND BIT(16);      /* 1 -> FACTORED,2 -> NORMAL I/C LIST. (1|2)*/00187200
   DECLARE IC_PTR1 BIT(16);       /* CONTAINS FACTORED I/C LIST PTR(...) VALUE*/00187300
   DECLARE IC_PTR2 BIT(16);       /* CONTAINS NORMAL I/C LIST PTR(...) VALUE  */00187400
   DECLARE INIT_EMISSION BIT(8);                                                00187600
                                                                                00187700
 /*  DO GROUP FLOW STACKS  */                                                   00187800
   DECLARE DO_LEVEL_LIM LITERALLY '25', /*CR12940*/                             00187900
      DO_LEVEL BIT(16) INITIAL(1),                                              00188000
      DO_LOC(DO_LEVEL_LIM) BIT(16),                                             00188100
      DO_PARSE(DO_LEVEL_LIM) BIT(16),                                           00188200
      DO_CHAIN(DO_LEVEL_LIM) BIT(16),                                           00188300
      DO_STMT#(DO_LEVEL_LIM) BIT(16),                                           00188310
      DO_INX(DO_LEVEL_LIM) BIT(8);                                              00188400
                                                                                00188500
   DECLARE FCN_LV_MAX LITERALLY '10',                                           00188600
      FCN_LV BIT(16),                                                           00188700
      FCN_MODE(FCN_LV_MAX) BIT(8),                                              00188800
      FCN_LOC(FCN_LV_MAX) BIT(16),                                              00188900
      FCN_ARG(FCN_LV_MAX) BIT(16);                                              00189000
   DECLARE UPDATE_BLOCK_LEVEL BIT(16);                                          00189100
   DECLARE (IND_LINK,FIX_DIM) BIT(16);                                          00189200
   DECLARE LIST_EXP_LIM LITERALLY '32767';                                      00189300
   DECLARE REFER_LOC BIT(16);                                                   00189400
   DECLARE SUB_SEEN FIXED ;                                                     00189500
   DECLARE SUB_COUNT LITERALLY  'INX(PTR(MP))' ;                                00189600
   DECLARE STRUCTURE_SUB_COUNT LITERALLY 'PSEUDO_LENGTH(PTR(MP))' ;             00189700
   DECLARE ARRAY_SUB_COUNT LITERALLY 'VAL_P(PTR(MP))';                          00189800
 /* THE FOLLOWING ARE USED FOR PSEUDO_FORM AND IN HALMAT OUTPUT */              00189900
   DECLARE XSYT BIT(8) INITIAL (1),                                             00190000
      XINL BIT(8) INITIAL (2),                                                  00190100
      XVAC BIT(8) INITIAL (3),                                                  00190200
      XXPT BIT(8) INITIAL (4),                                                  00190300
      XLIT BIT(8) INITIAL (5),                                                  00190400
      XIMD BIT(8) INITIAL (6),                                                  00190500
      XAST BIT(8) INITIAL (7),                                                  00190600
      XCSZ BIT(8) INITIAL (8),                                                  00190700
      XASZ BIT(8) INITIAL (9),                                                  00190800
      XOFF BIT(8) INITIAL (10);                                                 00190900
 /* FOLLOWING ARE THE HALMAT OUTPUT OPERATOR CODES */                           00191000
   DECLARE XEXTN BIT(16) INITIAL ("001"),                                       00191200
      XXREC BIT(16) INITIAL ("002"),                                            00191300
      XSMRK BIT(16) INITIAL ("004"),                                            00191400
      XIFHD BIT(16) INITIAL ("007"),                                            00191500
      XLBL  BIT(16) INITIAL ("008"),                                            00191600
      XBRA  BIT(16) INITIAL ("009"),                                            00191700
      XFBRA BIT(16) INITIAL ("00A"),                                            00191800
      XDCAS BIT(16) INITIAL ("00B"),                                            00191900
      XECAS BIT(16) INITIAL ("00C"),                                            00192000
      XCLBL BIT(16) INITIAL ("00D"),                                            00192100
      XDTST BIT(16) INITIAL ("00E"),                                            00192200
      XETST BIT(16) INITIAL ("00F"),                                            00192300
      XDFOR BIT(16) INITIAL ("010"),                                            00192400
      XEFOR BIT(16) INITIAL ("011"),                                            00192500
      XCFOR BIT(16) INITIAL ("012"),                                            00192600
      XDSMP BIT(16) INITIAL ("013"),                                            00192700
      XESMP BIT(16) INITIAL ("014"),                                            00192800
      XAFOR BIT(16) INITIAL ("015"),                                            00192900
      XCTST BIT(16) INITIAL ("016"),                                            00193000
      XADLP BIT(16) INITIAL ("017"),                                            00193100
      XDLPE BIT(16) INITIAL ("018"),                                            00193200
      XDSUB BIT(16) INITIAL ("019"),                                            00193300
      XIDLP BIT(16) INITIAL ("01A"),                                            00193400
      XTSUB BIT(16) INITIAL ("01B"),                                            00193500
      XPCAL BIT(16) INITIAL ("01D"),                                            00193600
      XFCAL BIT(16) INITIAL ("01E");                                            00193700
   DECLARE XREAD(2) BIT(16) INITIAL ("01F",    /*  INDEXED OFF OF               00193800
        XRDAL         */          "020",    /*                                  00193900
        XWRIT         */          "021");                                       00194000
   DECLARE XFILE BIT(16) INITIAL ("022"),                                       00194100
      XXXST BIT(16) INITIAL ("025"),                                            00194200
      XXXND BIT(16) INITIAL ("026"),                                            00194300
      XXXAR BIT(16) INITIAL ("027"),                                            00194400
      XTDEF BIT(16) INITIAL ("02A"),                                            00194500
      XMDEF BIT(16) INITIAL ("02B"),                                            00194600
      XFDEF BIT(16) INITIAL ("02C"),                                            00194700
      XPDEF BIT(16) INITIAL ("02D"),                                            00194800
      XUDEF BIT(16) INITIAL ("02E"),                                            00194900
      XCDEF BIT(16) INITIAL ("02F"),                                            00195000
      XCLOS BIT(16) INITIAL ("030"),                                            00195100
      XEDCL BIT(16) INITIAL ("031"),                                            00195200
      XRTRN BIT(16) INITIAL ("032");                                            00195300
   DECLARE XTDCL BIT(16) INITIAL ("033");                                       00195400
   DECLARE XWAIT BIT(16) INITIAL ("034"),                                       00195500
      XSGNL BIT(16) INITIAL ("035"),                                            00195600
      XCANC BIT(16) INITIAL ("036"),                                            00195700
      XTERM BIT(16) INITIAL ("037"),                                            00195800
      XPRIO BIT(16) INITIAL ("038"),                                            00195900
      XSCHD BIT(16) INITIAL ("039"),                                            00196000
      XERON BIT(16) INITIAL ("03C"),                                            00196100
      XERSE BIT(16) INITIAL ("03D");                                            00196200
   DECLARE XMSHP(3) BIT(16) INITIAL ("040",  /*  INDEXED OFF OF                 00196300
        XVSHP   */                "041",  /*                                    00196400
        XSSHP    */               "042",  /*                                    00196500
        XISHP   */                "043");                                       00196600
   DECLARE XSFST BIT(16) INITIAL ("045"),                                       00196700
      XSFND BIT(16) INITIAL ("046"),                                            00196800
      XSFAR BIT(16) INITIAL ("047"),                                            00196900
      XBFNC BIT(16) INITIAL ("04A"),                                            00197000
      XLFNC BIT(16) INITIAL ("04B"),                                            00197100
      XIMRK BIT(16) INITIAL ("003"),                                            00197200
      XIDEF BIT(16) INITIAL ("051"),                                            00197300
      XICLS BIT(16) INITIAL ("052");                                            00197400
   DECLARE XNEQU(1) BIT(16) INITIAL ("056",   /*                                00197500
        XNNEQ      */             "055"),                                       00197600
      XNASN BIT(16) INITIAL ("057");                                            00197700
   DECLARE XPMHD BIT(16) INITIAL("059"),                                        00197800
      XPMAR BIT(16) INITIAL("05A"),                                             00197900
      XPMIN BIT(16) INITIAL("05B");                                             00198000
   DECLARE XXASN(10) BIT(16) INITIAL ( 0 ,  /*  MAKE INDEX WORK                 00198100
           XBASN    */              "0101",  /*                                 00198200
           XCASN    */              "0201",  /*                                 00198300
           XMASN    */              "0301",  /*                                 00198400
           XVASN    */              "0401",  /*                                 00198500
           XSASN   */                  "0501",   /*                             00198600
           XIASN   */                  "0601",   /*                             00198700
           UNUSED  */                  0,0,0,    /*                             00198800
           XTASN   */                  "04F");                                  00198900
 /* FOLLOWING ARE NOT LITERALS TO SAVE ON 100 POSSIBLE USAGE ONLY  */           00199000
   DECLARE XMEQU(1) BIT(16) INITIAL ("0766",  /* INDEXED OFF OF                 00199300
           XMNEQ     */              "0765");                                   00199400
   DECLARE XVEQU(1) BIT(16) INITIAL ("0786",  /* INDEXED OFF OF                 00199500
           XVNEQ     */              "0785");                                   00199600
   DECLARE XSEQU(5) BIT(16) INITIAL("07A6",  /* INDEXED OFF OF                  00199700
           XSNEQ    */              "07A5",  /*                                 00199800
           XSLT     */              "07AA",  /*                                 00199900
           XSGT     */              "07A8",  /*                                 00200000
           XSNGT    */              "07A7",  /*                                 00200100
           XSNLT    */              "07A9");                                    00200200
   DECLARE XIEQU(5) BIT(16) INITIAL("07C6",  /* INDEXED OFF OF                  00200300
           XINEQ    */              "07C5",  /*                                 00200400
           XILT     */              "07CA",  /*                                 00200500
           XIGT     */              "07C8",  /*                                 00200600
           XINGT    */              "07C7",  /*                                 00200700
           XINLT    */              "07C9");                                    00200800
   DECLARE XBEQU(1) BIT(16) INITIAL ("0726",  /* INDEXED OFF OF                 00200900
           XBNEQ     */              "0725");                                   00201000
   DECLARE XCEQU(5) BIT(16) INITIAL("0746",  /* INDEXED OFF OF                  00201100
          XCNEQ   */              "0745",   /*                                  00201200
          XCLT    */              "074A",   /*                                  00201300
          XCGT    */              "0748",   /*                                  00201400
          XCNGT   */              "0747",   /*                                  00201500
          XCNLT   */              "0749");                                      00201600
   DECLARE XTEQU(1) BIT(16) INITIAL (  "04E",  /*  INDEXED OFF OF               00201700
           XTNEQ   */                  "04D");                                  00201800
   DECLARE XMNEG(3) BIT(16) INITIAL("0344",  /* INDEXED OFF OF                  00201900
           XVNEG    */              "0444",  /*                                 00202000
           XSNEG    */              "05B0",  /*                                 00202100
           XINEG    */              "06D0");                                    00202200
   DECLARE XMADD(1) BIT(16) INITIAL("0362",  /* INDEXED OFF OF                  00202300
           XVADD    */              "0482"),                                    00202400
      XSADD(1) BIT(16) INITIAL("05AB",  /*
           XIADD    */              "06CB");
   DECLARE XMSUB(1) BIT(16) INITIAL("0363",  /* INDEXED OFF OF                  00202700
           XVSUB    */              "0483"),                                    00202800
      XSSUB(1) BIT(16) INITIAL("05AC",  /*
           XISUB    */              "06CC");
   DECLARE XMSDV(2) BIT(16) INITIAL("03A6",  /* INDEXED OFF OF                  00203100
           XVSDV    */              "04A6",  /*                                 00203200
           XSSDV    */              "05AE");                                    00203300
   DECLARE XSSPR(1) BIT(16) INITIAL("05AD",  /* INDEXED OFF OF                  00203400
           XIIPR    */              "06CD");                                    00203500
 /* FOLLOWING ARE NOT LITERALS TO SAVE ON THE 100 POSSIBLE USAGE ONLY  */       00203600
   DECLARE XVSPR BIT(16) INITIAL("04A5"),                                       00203700
      XMSPR BIT(16) INITIAL("03A5"),                                            00203800
      XVDOT BIT(16) INITIAL("058E"),                                            00203900
      XVVPR BIT(16) INITIAL("0387"),                                            00204000
      XVMPR BIT(16) INITIAL("046D"),                                            00204100
      XMVPR BIT(16) INITIAL("046C"),                                            00204200
      XMMPR BIT(16) INITIAL("0368"),                                            00204300
      XVCRS BIT(16) INITIAL("048B");                                            00204400
   DECLARE XMTRA BIT(16) INITIAL("0329"),                                       00204500
      XMINV BIT(16) INITIAL("03CA"),                                            00204600
      XSEXP BIT(16) INITIAL("05AF"),                                            00204700
      XSIEX BIT(16) INITIAL("0571"),                                            00204800
      XSPEX(1) BIT(16) INITIAL("0572",  /* INDEXED OFF OF                       00204900
           XIPEX */                 "06D2");                                    00205000
 /* FOLLOWING AND NOT LITERALS ONLY TO SAVE ON THE 100 POSSIBLE USAGE  */       00205100
   DECLARE XCAND BIT(16) INITIAL("07E2"),                                       00205200
      XCOR  BIT(16) INITIAL("07E3"),                                            00205300
      XCNOT BIT(16) INITIAL("07E4");                                            00205400
   DECLARE XSTOI BIT(16) INITIAL ("06A1"),                                      00205500
      XITOS BIT(16) INITIAL("05C1");                                            00205600
   DECLARE XBTOI(5) BIT(16) INITIAL ("0621",  /*  INDEXED OFF OF                00205700
           XCTOI    */               "0641",  /*                                00205800
           UNUSED    */              0,       /*                                00205900
           UNUSED    */              0,       /*                                00206000
           XSTOI     */              "06A1",  /*                                00206100
           XITOI     */              "06C1");                                   00206200
   DECLARE XBTOS(5) BIT(16) INITIAL ("0521",  /*  INDEXED OFF OF                00206300
           XCTOS     */              "0541",  /*                                00206400
           UNUSED    */              0,       /*                                00206500
           UNUSED    */              0,       /*                                00206600
           XSTOS     */              "05A1",  /*                                00206700
           XITOS     */              "05C1");                                   00206800
   DECLARE XCCAT BIT(16) INITIAL("0202");                                       00206900
   DECLARE XBCAT BIT(16) INITIAL("0105");                                       00207000
   DECLARE XBAND BIT(16) INITIAL("0102"),                                       00207100
      XBOR  BIT(16) INITIAL("0103"),                                            00207200
      XBNOT BIT(16) INITIAL("0104");                                            00207300
   DECLARE XSTRI BIT(16) INITIAL("0801"),                                       00207400
      XSLRI BIT(16) INITIAL("0802"),                                            00207500
      XETRI BIT(16) INITIAL("0804"),                                            00207600
      XELRI BIT(16) INITIAL("0803");                                            00207700
   DECLARE XBINT(5) BIT(16) INITIAL("0821",   /* INDEXED OFF OF                 00207800
           XCINT    */              "0841",  /*                                 00207900
           XMINT    */              "0861",  /*                                 00208000
           XVINT    */              "0881",   /*                                00208100
           XSINT    */              "08A1",   /*                                00208200
           XIINT    */              "08C1");                                    00208300
   DECLARE XTINT BIT(16) INITIAL ("8E2"),                                       00208400
      XEINT BIT(16) INITIAL("8E3"),                                             00208500
      XNINT BIT(16) INITIAL ("8E1");                                            00208600
   DECLARE XMTOM(3) BIT(16) INITIAL ("341",   /* INDEXED OFF OF                 00208700
           XVTOV    */               "441",   /*                                00208800
           XSTOS      */             "5A1",   /*                                00208900
           XITOI      */             "6C1");                                    00209000
   DECLARE XBTRU BIT(16) INITIAL ("720");                                       00209100
   DECLARE XBTOC(5) BIT(16) INITIAL ("0221",  /*  INDEXED OFF OF                00209200
           XCTOC    */               "0241",  /*                                00209300
           UNUSED   */               0,       /*                                00209400
           UNUSED   */               0,       /*                                00209500
           XSTOC    */               "02A1",  /*                                00209600
           XITOC    */               "02C1");                                   00209700
   DECLARE XBTOB(5) BIT(16) INITIAL ("0121",  /*  INDEXED OFF OF                00209800
           XCTOB    */               "0141",  /*                                00209900
           UNUSED   */               0,       /*                                00210000
           UNUSED   */               0,       /*                                00210100
           XSTOB    */               "01A1",  /*                                00210200
           XITOB    */               "01C1");                                   00210300
   DECLARE XBTOQ(5) BIT(16) INITIAL ("0122",  /*  INDEXED OFF OF                00210400
           XCTOQ    */               "0142",  /*                                00210500
           UNUSED   */               0,0,     /*                                00210600
           XSTOQ    */               "01A2",  /*                                00210700
           XITOQ    */               "01C2");                                   00210800
 /* FOLLOWING ARE THE 'CODE OPTIMIZER' BIT VALUES */                            00210900
   DECLARE XCO_N BIT(8) INITIAL ("01"),                                         00211000
      XCO_D BIT(8) INITIAL ("02");                                              00211100
 /* ASSIGNMENT TYPE-- MATCH VALIDITY CHECK TABLE */                             00211200
   DECLARE ASSIGN_TYPE(15) BIT(16) INITIAL(                                     00211300
      "(1) 0000 0000 0000 0000", /* NULL      */                                00211400
      "(1) 0000 0000 0000 0010", /* BIT       */                                00211500
      "(1) 0000 0000 0110 0101", /* CHAR      */                                00211600
      "(1) 0000 0000 0000 1001", /* MAT       */                                00211700
      "(1) 0000 0000 0001 0001", /* VEC       */                                00211800
      "(1) 0000 0000 0110 0001", /* SCA       */                                00211900
      "(1) 0000 0000 0110 0001", /* INT       */                                00212000
      "(1) 0000 0000 0000 0000", /* BORC      */                                00212100
      "(1) 0000 0000 0110 0000", /*  IORS   */                                  00212200
      "(1) 0000 0000 0000 0000", /* EVENT     */                                00212300
      "(1) 0000 0100 0000 0000",  /* STRUCTURE  */                              00212400
      "(1) 0000 0111 1111 1110");  /* ANY TYPE  */                              00212500
   DECLARE STRING_MASK BIT(16) INITIAL("(1) 1100110");                          00212600
                                                                                00212700
   DECLARE IC_SIZE LITERALLY '200', IC_SIZ LITERALLY '199';                     00212800
   ARRAY IC_VAL(IC_SIZ) BIT(16),                                                00212900
      IC_LOC(IC_SIZ) BIT(16),                                                   00213000
      IC_LEN(IC_SIZ) BIT(16),                                                   00213100
      IC_FORM(IC_SIZ) BIT(8),                                                   00213200
      IC_TYPE(IC_SIZ) BIT(8);                                                   00213300
   DECLARE IC_FILE LITERALLY '3',                                               00213400
      ICQ FIXED,                                                                00213500
      NUM_EL_MAX LITERALLY '32767',                                             00213600
      (IC_ORG, IC_LIM, IC_MAX, CUR_IC_BLK, IC_LINE) FIXED;                      00213700
   DECLARE LIT_TOP_MAX LITERALLY '32767',                                       00213800
      LIT_CHAR_SIZE FIXED,                                                      00213900
      LIT_BUF_SIZE LITERALLY '130',                                             00214000
      LITFILE LITERALLY '2';                                                    00214100
   DECLARE (LIT_PTR, LITORG, LITMAX, CURLBLK) FIXED;                            00214200
   DECLARE LITLIM FIXED INITIAL(LIT_BUF_SIZE);                                  00214300
   DECLARE DW_AD FIXED;                                                         00214400
   DECLARE LOCK_FLAG    LITERALLY '"0001"',                                     00214500
      REENTRANT_FLAG  LITERALLY '"0002"',                                       00214600
      DENSE_FLAG    LITERALLY '"0004"',                                         00214700
      ALIGNED_FLAG  LITERALLY '"0008"',                                         00214800
      IMP_DECL      LITERALLY '"0010"',                                         00214900
      ASSIGN_PARM   LITERALLY '"0020"',                                         00215000
      DEFINED_LABEL LITERALLY '"0040"',                                         00215100
      REMOTE_FLAG    LITERALLY '"00000080"',                                    00215200
      AUTO_FLAG     LITERALLY '"0100"',                                         00215300
      STATIC_FLAG   LITERALLY '"0200"',                                         00215400
      INPUT_PARM    LITERALLY '"0400"',                                         00215500
      INIT_FLAG     LITERALLY '"0800"',                                         00215600
      CONSTANT_FLAG LITERALLY '"1000"',                                         00215700
      ARRAY_FLAG     LITERALLY '"2000"',                                        00215800
      ENDSCOPE_FLAG LITERALLY '"4000"',                                         00215900
      INACTIVE_FLAG   LITERALLY '"00008000"',                                   00216000
      ACCESS_FLAG     LITERALLY '"00010000"',                                   00216100
      LATCHED_FLAG    LITERALLY '"00020000"',                                   00216200
      IMPL_T_FLAG       LITERALLY '"00040000"',                                 00216300
      EXCLUSIVE_FLAG  LITERALLY '"00080000"',                                   00216400
      EXTERNAL_FLAG   LITERALLY '"00100000"',                                   00216500
      EVIL_FLAG       LITERALLY '"00200000"',                                   00216600
      DOUBLE_FLAG     LITERALLY '"00400000"',                                   00216700
      SINGLE_FLAG     LITERALLY '"00800000"',                                   00216800
      DUMMY_FLAG      LITERALLY '"01000000"',                                   00216900
      INCLUDED_REMOTE LITERALLY '"02000000"',  /* DR102949, DR108643 */         00217010
      DUPL_FLAG  LITERALLY '"04000000"',                                        00217100
      TEMPORARY_FLAG   LITERALLY '"08000000"',                                  00217200
      NAME_FLAG      LITERALLY '"10000000"',                                    00217300
      READ_ACCESS_FLAG  LITERALLY '"20000000"',                                 00217400
      MISC_NAME_FLAG LITERALLY '"40000000"',                                    00217500
      RIGID_FLAG LITERALLY '"80000000"',                                        00217600
      NONHAL_FLAG   LITERALLY '"01"',  /* DR108643 - SYT_FLAGS2 ARRAY */        00217000
                                                                                00217700
      PARM_FLAGS      LITERALLY '"00000420"',                                   00217800
      SDF_INCL_FLAG   LITERALLY 'INIT_FLAG',                                    00217900
      SDF_INCL_LIST   LITERALLY 'CONSTANT_FLAG',                                00218000
      SDF_INCL_OFF    LITERALLY '"FFFFE7FF"',                                   00218100
      ALDENSE_FLAGS LITERALLY '"000C"',                                         00218200
      AUTSTAT_FLAGS LITERALLY '"0300"',                                         00218300
      INIT_CONST    LITERALLY '"1800"',                                         00218400
      SD_FLAGS        LITERALLY '"00C00000"',                                   00218500
      SM_FLAGS        LITERALLY '"90C2008C"',  /*DR111348*/                     00218600
      INP_OR_CONST  LITERALLY '"1400"';                                         00218700
   DECLARE   MOVEABLE LITERALLY '1',                                            00218701
      UNMOVEABLE LITERALLY '0';                                                 00218702
 /*LITERALS TO CHANGE REFERENCES TO VARIABLES TO RECORD FORMAT*/                00218703
   DECLARE MACRO_TEXT(1) LITERALLY 'MACRO_TEXTS(%1%).MAC_TXT';                  00218704
   DECLARE SYT_NAME(1) LITERALLY 'SYM_TAB(%1%).SYM_NAME',                       00218705
      SYT_ADDR(1) LITERALLY 'SYM_TAB(%1%).SYM_ADDR',                            00218706
      SYT_XREF(1) LITERALLY 'SYM_TAB(%1%).SYM_XREF',                            00218707
      SYT_NEST(1) LITERALLY 'SYM_TAB(%1%).SYM_NEST',                            00218708
      SYT_SCOPE(1) LITERALLY 'SYM_TAB(%1%).SYM_SCOPE',                          00218709
      VAR_LENGTH(1) LITERALLY 'SYM_TAB(%1%).SYM_LENGTH',                        00218710
      SYT_ARRAY(1) LITERALLY 'SYM_TAB(%1%).SYM_ARRAY',                          00218711
      SYT_PTR(1) LITERALLY 'SYM_TAB(%1%).SYM_PTR',                              00218712
      SYT_LINK1(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK1',                          00218713
      SYT_LINK2(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK2',                          00218714
      SYT_CLASS(1) LITERALLY 'SYM_TAB(%1%).SYM_CLASS',                          00218715
      SYT_FLAGS(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS',                          00218716
      SYT_FLAGS2(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS2',  /* DR108643 */        00218716
      SYT_LOCK#(1) LITERALLY 'SYM_TAB(%1%).SYM_LOCK#',                          00218717
      SYT_TYPE(1) LITERALLY 'SYM_TAB(%1%).SYM_TYPE',                            00218718
      EXTENT(1) LITERALLY 'SYM_TAB(%1%).XTNT';                                  00218719
   DECLARE SYT_HASHLINK(1) LITERALLY 'LINK_SORT(%1%).SYM_HASHLINK',             00218720
      SYT_SORT(1) LITERALLY 'LINK_SORT(%1%).SYM_SORT';                          00218721
   DECLARE OUTER_REF(1) LITERALLY 'OUTER_REF_TABLE(%1%).OUT_REF',               00218722
      OUTER_REF_FLAGS(1) LITERALLY 'OUTER_REF_TABLE(%1%).OUT_REF_FLAGS';        00218723
   DECLARE LIT_CHAR(1) LITERALLY 'LIT_NDX(%1%).CHAR_LIT';
   DECLARE LIT1(1) LITERALLY 'LIT_PG.LITERAL1(%1%)',                            00218725
      LIT2(1) LITERALLY 'LIT_PG.LITERAL2(%1%)',                                 00218726
      LIT3(1) LITERALLY 'LIT_PG.LITERAL3(%1%)';                                 00218727
   DECLARE XREF(1) LITERALLY 'CROSS_REF(%1%).CR_REF';                           00218728
   DECLARE ATOMS(1) LITERALLY 'FOR_ATOMS(%1%).CONST_ATOMS';                     00218729
   DECLARE DW(1) LITERALLY 'FOR_DW(%1%).CONST_DW';                              00218730
                                                                                00218800
   DECLARE ILL_ATTR(10) FIXED INITIAL(                                          00218900
      0,                                                                        00219000
      "00C20000",   /*  BIT  */                                                 00219100
      "00C20000",   /*  CHARACTER  */                                           00219200
      "00020000",   /*  MATRIX  */                                              00219300
      "00020000",   /*  VECTOR  */                                              00219400
      "00020000",   /*  SCALAR  */                                              00219500
      "00020000",   /*  INTEGER  */                                             00219600
      0,                                                                        00219700
      0,                                                                        00219800
      "00C01181",  /*  EVENT  */                                                00219900
      "00C20000");  /*  STRUCTURE  */                                           00220000
   DECLARE ILL_LATCHED_ATTR FIXED INITIAL ("02C01000"),                         00220100
      ILL_CLASS_ATTR(2) FIXED INITIAL ("00000000",                              00220200
      "80C3208D",                                                               00220300
      "8003208D"),                                                              00220400
      ILL_TEMPL_ATTR FIXED INITIAL("02033B81"),                                 00220500
      ILL_MINOR_STRUC FIXED INITIAL("02C31B81"),                                00220600
      ILL_TERM_ATTR(1) FIXED INITIAL("02011B81","02011B01"),                    00220700
      ILL_NAME_ATTR FIXED INITIAL ("02010000"),                                 00220800
      ILL_INIT_ATTR FIXED INITIAL ("00001B00"),                                 00220900
      ILL_EQUATE_ATTR FIXED INITIAL("0A180462"),                                00221000
      ILL_TEMPORARY_ATTR FIXED INITIAL ("82051B8D");                            00221100
   DECLARE NAME_IMPLIED BIT(1);                                                 00221200
   DECLARE BUILDING_TEMPLATE BIT(1);                                            00221300
   DECLARE LOOKUP_ONLY BIT(1);                                                  00221400
   DECLARE NAMING BIT(1), FIXING BIT(16);                                       00221500
   DECLARE DELAY_CONTEXT_CHECK BIT(1);                                          00221600
   DECLARE NAME_PSEUDOS BIT(1);                                                 00221700
   DECLARE NAME_BIT BIT(8);                                                     00221800
   DECLARE FACTOR_FOUND BIT(1);                                                 00221900
   DECLARE ERRLIM LITERALLY '102',                                              00222000
      IND_ERR_# FIXED;                                                          00222100
   ARRAY SAVE_SEVERITY(ERRLIM) BIT(8),                                          00222200
      SAVE_LINE_#(ERRLIM) BIT(16);                                              00222300
   DECLARE INCLUDING BIT(1);                                                    00222400
   DECLARE INCLUDE_LIST BIT(1) INITIAL(TRUE),INCLUDE_LIST2 BIT(1) INITIAL(TRUE),00222500
      INCLUDE_END BIT(1), INCLUDE_OPENED BIT(1);                                00222600
   DECLARE INPUT_DEV BIT(16);                                                   00222700
   DECLARE INCLUDE_CHAR CHARACTER ;                                             00222800
   DECLARE (INCLUDE_OFFSET,INCLUDE_COUNT,INCLUDE_FILE#) BIT(16);                00222900
   DECLARE SAVE# LITERALLY '19', LINE_LIM BIT(16) INITIAL(59),                  00223000
      LINE_MAX BIT(16);                                                         00223100
   DECLARE LISTING2_COUNT BIT(16); /* INITIALIZED TO LINE_LIM */                00223200
   DECLARE SAVE_GROUP(SAVE#) CHARACTER;                                         00223300
   DECLARE SAVE_ERROR_LIM LITERALLY '19';                                       00223400
   DECLARE SAVE_ERROR_MESSAGE(SAVE_ERROR_LIM) CHARACTER;                        00223500
   DECLARE (TOO_MANY_LINES, TOO_MANY_ERRORS) BIT(1);                            00223600
   DECLARE CURRENT_CARD CHARACTER;                                              00223700
   DECLARE END_GROUP BIT(1);                                                    00223800
   DECLARE NONBLANK_FOUND BIT(1),                                               00223900
      GROUP_NEEDED BIT(1) INITIAL(TRUE);                                        00224000
   DECLARE LRECL(1) BIT(16);                                                    00224100
   DECLARE INPUT_REC(1) CHARACTER;                                              00224200
   DECLARE MEMORY_FAILURE BIT(1);                                               00224300
   DECLARE (SYSIN_COMPRESSED, INCLUDE_COMPRESSED,                               00224400
      LOOKED_RECORD_AHEAD, INITIAL_INCLUDE_RECORD) BIT(1);                      00224500
   DECLARE NOT_ASSIGNED_FLAG BIT(1);                                            00224600
   DECLARE INFORMATION CHARACTER;                                               00224700
   DECLARE X8 CHARACTER INITIAL('        '), VBAR CHARACTER INITIAL('| ');      00224800
   DECLARE STARS CHARACTER INITIAL('*****');                                    00224900
   DECLARE SUBHEADING CHARACTER INITIAL('2');                                   00225000
   DECLARE (NEXT, LAST) BIT(16);                                                00225100
   DECLARE SAVE_CARD CHARACTER;                                                 00225200
   DECLARE COMMENTING BIT(1);                                                   00225300
   DECLARE SQUEEZING BIT(1);                                                    00225400
   DECLARE LISTING2 BIT(1);                                                     00225500
   DECLARE TEXT_LIMIT(1) BIT(16);                                               00225600
   DECLARE PATCH_TEXT_LIMIT(1) BIT(16);                                         00225610
   DECLARE ACCESS_FOUND BIT(1);                                                 00225700
   DECLARE SDF_OPEN BIT(1);                                                     00225750
   DECLARE PROGRAM_ID CHARACTER;                                                00225800
   DECLARE INCLUDE_MSG CHARACTER;                                               00225900
   ARRAY CARD_TYPE  (255)  BIT(16);                                             00226000
   DECLARE STACK_PTR(STACKSIZE) BIT(16);                                        00226100
   DECLARE ELSEIF_PTR BIT(16);                                                  00226150
   DECLARE OUTPUT_STACK_MAX LITERALLY '1799';  /*DR111326*/                     00226200
   DECLARE SAVE_BCD_MAX LITERALLY '256';       /*DR111326*/                     00226300
   ARRAY STMT_STACK(OUTPUT_STACK_MAX)  BIT(16);                                 00226400
   ARRAY  ERROR_PTR(OUTPUT_STACK_MAX)  BIT(16);                                 00226410
 /* THE FOLLOWING DECLARATION MUST OCCUR IN THIS EXACT ORDER.                   00226500
          THE UNFLO ENTRY IS USED TO ABSORB THE RESULTS OF                      00226600
          A PRODUCTION TRYING TO FORCE NO SPACING OF A TOKEN                    00226700
          IN THE OUTPUT WRITER LISTING WHEN THAT TOKEN IS                       00226800
          THE RESULT OF A REPLACE EXPANSION. THE CORRESPONDING                  00226900
          ENTRY IN STACK_PTR WILL CONTAIN A -1 THUS SELECTING                   00227000
          THE UNFLO ELEMENT.  */                                                00227100
   ARRAY TOKEN_FLAGS_UNFLO BIT(1),                /*DR111320  CR13335*/
         TOKEN_FLAGS(OUTPUT_STACK_MAX) BIT(16),   /*DR111320  CR13335*/         00227200
         GRAMMAR_FLAGS_UNFLO BIT(1),              /*DR111320  CR13335*/         00227300
         GRAMMAR_FLAGS(OUTPUT_STACK_MAX) BIT(16); /*DR111320  CR13335*/         00227300
   DECLARE ATTR_LOC BIT(16);                                                    00227400
   DECLARE ATTR_INDENT BIT(16);                                                 00227500
   DECLARE ATTR_FOUND BIT(1);                                                   00227600
   DECLARE END_OF_INPUT BIT(1);                                                 00227700
   DECLARE SAVE_BCD(SAVE_BCD_MAX) CHARACTER;                                    00227800
   DECLARE (STMT_PTR, BCD_PTR, STMT_END_PTR, SUB_END_PTR) BIT(16);              00227900
   DECLARE SAVE_SCOPE CHARACTER;                                                00228000
   DECLARE NOSPACE LITERALLY 'TOKEN_FLAGS(STACK_PTR(MP)) = TOKEN_FLAGS(STACK_PTR00228100
(MP)) | "20"';                                                                  00228200
   DECLARE LABEL_FLAG BIT(16) INITIAL("0001");                                  00228300
   DECLARE ATTR_BEGIN_FLAG BIT(16) INITIAL("0002");                             00228400
   DECLARE STMT_END_FLAG BIT(16) INITIAL("0004");                               00228500
   DECLARE INLINE_FLAG BIT(16) INITIAL("0200");                                 00228600
   DECLARE FUNC_FLAG BIT(16) INITIAL("0008");                                   00228700
   DECLARE LEFT_BRACKET_FLAG BIT(16) INITIAL("0010");                           00228800
   DECLARE RIGHT_BRACKET_FLAG BIT(16) INITIAL("0020");                          00228900
   DECLARE LEFT_BRACE_FLAG BIT(16) INITIAL("0040");                             00229000
   DECLARE RIGHT_BRACE_FLAG BIT(16) INITIAL("0080");                            00229100
   DECLARE MACRO_ARG_FLAG BIT(16) INITIAL("0100");                              00229200
   DECLARE PRINT_FLAG BIT(16) INITIAL("0400");                                  00229300
   DECLARE PRINT_FLAG_OFF BIT(16) INITIAL("FBFF");                              00229400
   DECLARE PRINTING_ENABLED BIT(16) INITIAL("0400");                            00229500
   DECLARE COMMENT_COUNT BIT(16);                                               00229600
   DECLARE SAVE_COMMENT CHARACTER INITIAL('                                     00229700
                                                                                00229800
                                                                                00229900
                                                           ');                  00230000
   DECLARE LAST_SPACE BIT(16);                                                  00230100
   DECLARE LAST_WRITE BIT(16);                                                  00230200
   ARRAY SPACE_FLAGS(284) BIT(8) INITIAL(  /* DIMENSION IS TWICE NT  */         00230300
      "00", "00", "00", "12", "00", "00", "00", "00", "00", "20",   /*  0-  9*/ 00230400
      "20", "02", "00", "00", "20", "00", "20", "22", "00", "00",   /* 10- 19*/ 00230500
      "00", "00", "00", "00", "00", "00", "00", "00", "00", "00",   /* 20- 29*/ 00230600
      "00", "00", "00", "02", "00", "00", "02", "00", "00", "02",   /* 30- 39*/ 00230700
      "00", "02", "00", "00", "02", "00", "00", "02", "00", "00",   /* 40- 49*/ 00230800
      "02", "02", "02", "01", "00", "02", "02", "00", "02", "00",   /* 50- 59*/ 00230900
      "00", "00", "00", "00", "02", "00", "00", "00", "00", "00",   /* 60- 69*/ 00231000
   "00", "00", "00", "00", "00", "02", "00", "00", "02", "00", "02", /* 70- 80*/00231100
   "00", "00", "50", "00", "02", "00", "00", "00", "00", "00", "00", /* 81- 91*/00231200
   "00", "02", "50", "00", "00", "00", "01", "00", "00", "00", "00", /* 92-102*/00231300
      "00", "02", "00", "00", "00", "02", "00", "00", "02", "00",   /*103-112*/ 00231400
      "01", "01", "00", "00", "00", "00", "00", "00", "01", "00",   /*113-122*/ 00231500
      "00", "00", "00", "00", "01", "00", "01", "01", "00", "00",   /*123-132*/ 00231600
     "01", "01", "00", "00", "00", "00", "00", "00", "00", "00",     /*133-142*/00231700
 /*  END OF FIRST PART OF SPACE TABLE USED FOR M-LINE SPACING  */               00231800
      "22", "22", "12", "22", "22", "22", "22", "22", "20",   /*  0-  9*/       00231900
      "22", "22", "22", "22", "22", "22", "22", "22", "22", "22",   /* 10- 19*/ 00232000
      "00", "22", "55", "00", "00", "00", "00", "00", "00", "00",   /* 20- 29*/ 00232100
      "55", "00", "00", "02", "00", "00", "02", "00", "00", "02",   /* 30- 39*/ 00232200
      "00", "02", "00", "00", "02", "00", "00", "02", "00", "00",   /* 40- 49*/ 00232300
      "02", "02", "02", "01", "00", "02", "02", "00", "02", "00",   /* 50- 59*/ 00232400
      "00", "00", "00", "00", "02", "00", "00", "00", "00", "00",   /* 60- 69*/ 00232500
   "00", "00", "00", "00", "00", "02", "00", "00", "02", "00", "02", /* 70- 80*/00232600
    "00", "00", "50", "00", "02", "00", "00", "00", "00", "00", "00", /* 81-91*/00232700
   "00", "02", "50", "00", "00", "00", "01", "00", "00", "00", "00", /* 92-102*/00232800
      "00", "02", "00", "00", "00", "02", "00", "00", "02", "00",   /*103-112*/ 00232900
      "01", "01", "00", "00", "00", "00", "00", "00", "01", "00",   /*113-122*/ 00233000
      "00", "00", "00", "00", "01", "00", "01", "01", "00", "00",   /*123-132*/ 00233100
      "01", "01", "00", "00", "00", "00", "00", "00", "00", "00"); /*133-142*/  00233200
                                                                                00233300
                                                                                00233400
 /* THE ARRAY TRANS_IN IS USED TO DETERMINE THE RESULT OF APPLYING THE          00233500
    "ESCAPE" CHARACTER TO ONE OF THE STANDARD HAL/S CHARACTER CODES.            00233600
    THE ARRAY IS INDEXED BY THE BINARY VALUE OF AN INPUT CHARACTER.             00233700
    THE VALUE AT A PARTICULAR INDEX HAS THE LEVEL 1 ESCAPE TRANSLATION          00233800
    CHARACTER IN THE RIGHT BYTE AND THE LEVEL 2 CHARACTER IN THE LEFT BYTE.     00233900
    A ZERO VALUE IN A PARTICULAR BYTE INDICATES THAT THE REQUESTED              00234000
    ESCAPE TRANSLATION HAS NOT BEEN DEFINED. (THE ZERO VALUE HAS THIS MEANING   00234100
    IN ALL CASES EXCEPT THE ONE IN WHICH THE ESCAPED VALUE IS TO BE "00".       00234200
    THIS SPECIAL CASE IS DETECTED IN THE SCANNER LOGIC BY USING THE             00234300
    VALUES OF "VALID_00_OP" AND "VALID_00_CHAR" */                              00234400
                                                                                00234500
   ARRAY TRANS_IN(255) BIT(16) INITIAL(                                         00234600
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /*  0- 7 */00234700
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /*  8- F */00234800
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 10-17 */00234900
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 18-1F */00235000
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 20-27 */00235100
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 28-2F */00235200
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 30-37 */00235300
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 38-3F */00235400
     "FF4A", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 40-47 */00235500
     "0000", "0000", "0000", "DCAF", "EA21", "0000", "D044", "DE0D", /* 48-4F */00235600
     "E048", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 50-57 */00235700
     "0000", "0000", "0000", "EE53", "DB46", "0000", "FA55", "DF47", /* 58-5F */00235800
     "DA45", "DD0E", "0000", "0000", "0000", "0000", "0000", "0000", /* 60-67 */00235900
     "0000", "0000", "0000", "EF54", "FD00", "FC16", "EB20", "0000", /* 68-6F */00236000
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 70-77 */00236100
     "0000", "0000", "FB56", "EC51", "ED52", "0000", "E149", "FE00", /* 78-7F */00236200
     "0000", "8E29", "8F2A", "902B", "9A2C", "9C2D", "9D2E", "9E2F", /* 80-87 */00236300
     "9F30", "A031", "0000", "0000", "0000", "0000", "0000", "0000", /* 88-8F */00236400
     "0000", "A132", "AA33", "AB34", "AC35", "AE36", "B037", "B138", /* 90-97 */00236500
     "B239", "B33A", "0000", "0000", "0000", "0000", "0000", "0000", /* 98-9F */00236600
     "0000", "0000", "B43B", "B53C", "B63D", "B73E", "B83F", "B941", /* A0-A7 */00236700
     "BA42", "BB43", "0000", "0000", "0000", "0000", "0000", "0000", /* A8-AF */00236800
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* B0-B7 */00236900
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* B8-BF */00237000
     "0000", "5710", "5811", "5919", "6213", "6314", "641A", "6512", /* C0-C7 */00237100
     "660B", "670C", "0000", "0000", "0000", "0000", "0000", "0000", /* C8-CF */00237200
     "0000", "680F", "6922", "6A1F", "7023", "7124", "721C", "7317", /* D0-D7 */00237300
     "7425", "751E", "0000", "0000", "0000", "0000", "0000", "0000", /* D8-DF */00237400
     "0000", "0000", "7618", "7715", "7826", "790A", "801D", "8A27", /* E0-E7 */00237500
     "8C1B", "8D28", "0000", "0000", "0000", "0000", "0000", "0000", /* E8-EF */00237600
     "BC00", "BE01", "BF02", "C003", "CA04", "CB05", "CC06", "CD07", /* F0-F7 */00237700
     "CE08", "CF09", "0000", "0000", "0000", "0000", "0000", "0000");/* F8-FF */00237800
                                                                                00237900
                                                                                00238000
 /* THE TRANS_OUT ARRAY IS USED BY THE OUTPUT WRITER TO OBTAIN THE PROPER       00238100
    OVER PUNCH (IF ANY) FOR A GIVEN INTERNAL CHARACTER REPRESENTATION. THE      00238200
    ARRAY IS INDEXED BY THE BINARY VALUE OF AN INTERNAL CHARACTER AS            00238300
    GENERATED BY SCAN USING THE TRANS_IN ARRAY. THE RIGHT HAND BYTE OF          00238400
    EACH ENTRY CONTAINS THE CHARACTER IN THE STANDARD HAL/S CHARACTER           00238500
    SET WHICH IS "ESCAPED" TO PRODUCE THE CHARACTER WHOSE BINARY VALUE          00238600
    IS THE INDEX OF THAT ENTRY. A ZERO VALUE INDICATES THAT THE CHARACTER       00238700
    IS NOT GENERATED VIA AN ESCAPE. THE LEFT HAND BYTE (IF THE RH BYTE IS       00238800
    NON-ZERO) CONTAINS THE ESCAPE LEVEL WHICH MUST BE APPLIED TO THE            00238900
    RH CHARACTER TO ACHIEVE THE INDEXING CHARACTER VALUE. AN ESCAPE LEVEL       00239000
    OF 1 IS INDECATED BY "00", A LEVEL OF 2 BY "01", ETC. */                    00239100
                                                                                00239200
                                                                                00239300
   ARRAY TRANS_OUT(255) BIT(16) INITIAL(                                        00239400
     "00F0", "00F1", "00F2", "00F3", "00F4", "00F5", "00F6", "00F7", /*  0- 7 */00239500
     "00F8", "00F9", "00E5", "00C8", "00C9", "004F", "0061", "00D1", /*  8- F */00239600
     "00C1", "00C2", "00C7", "00C4", "00C5", "00E3", "006D", "00D7", /* 10-17 */00239700
     "00E2", "00C3", "00C6", "00E8", "00D6", "00E6", "00D9", "00D3", /* 18-1F */00239800
     "006E", "004C", "00D2", "00D4", "00D5", "00D8", "00E4", "00E7", /* 20-27 */00239900
     "00E9", "0081", "0082", "0083", "0084", "0085", "0086", "0087", /* 27-2F */00240000
     "0088", "0089", "0091", "0092", "0093", "0094", "0095", "0096", /* 30-37 */00240100
     "0097", "0098", "0099", "00A2", "00A3", "00A4", "00A5", "00A6", /* 38-3F */00240200
     "0000", "00A7", "00A8", "00A9", "004E", "0060", "005C", "005F", /* 40-47 */00240300
     "0050", "007E", "0040", "0000", "0000", "0000", "0000", "0000", /* 48-4F */00240400
     "0000", "007B", "007C", "005B", "006B", "005E", "007A", "01C1", /* 50-57 */00240500
     "01C2", "01C3", "0000", "0000", "0000", "0000", "0000", "0000", /* 58-5F */00240600
     "0000", "0000", "01C4", "01C5", "01C6", "01C7", "01C8", "01C9", /* 60-67 */00240700
     "01D1", "01D2", "01D3", "0000", "0000", "0000", "0000", "0000", /* 68-6F */00240800
     "01D4", "01D5", "01D6", "01D7", "01D8", "01D9", "01E2", "01E3", /* 70-77 */00240900
     "01E4", "01E5", "0000", "0000", "0000", "0000", "0000", "0000", /* 78-7F */00241000
     "01E6", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 80-87 */00241100
     "0000", "0000", "01E7", "0000", "01E8", "01E9", "0181", "0182", /* 88-8F */00241200
     "0183", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* 90-97 */00241300
     "0000", "0000", "0184", "0000", "0185", "0186", "0187", "0188", /* 98-9F */00241400
     "0189", "0191", "0000", "0000", "0000", "0000", "0000", "0000", /* A0-A7 */00241500
     "0000", "0000", "0192", "0193", "0194", "0000", "0195", "004B", /* A8-AF */00241600
     "0196", "0197", "0198", "0199", "01A2", "01A3", "01A4", "01A5", /* B0-B7 */00241700
     "01A6", "01A7", "01A8", "01A9", "01F0", "0000", "01F1", "01F2", /* B8-BF */00241800
     "01F3", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* C0-C7 */00241900
     "0000", "0000", "01F4", "01F5", "01F6", "01F7", "01F8", "01F9", /* C8-CF */00242000
     "014E", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* D0-D7 */00242100
     "0000", "0000", "0160", "015C", "014B", "0161", "014F", "015F", /* D8-DF */00242200
     "0150", "017E", "0000", "0000", "0000", "0000", "0000", "0000", /* E0-E7 */00242300
     "0000", "0000", "014C", "016E", "017B", "017C", "015B", "016B", /* E8-EF */00242400
     "0000", "0000", "0000", "0000", "0000", "0000", "0000", "0000", /* F0-F7 */00242500
     "0000", "0000", "015E", "017A", "016D", "016C", "017F", "0140");/* F8-FF */00242600
                                                                                00242700
                                                                                00242800
   DECLARE ESCP BIT(8) INITIAL("4A");  /* THE ESCAPE CHARACTER */               00242900
   DECLARE CHAR_OP(1) BIT(8) INITIAL("6D", "7E");  /* OVER PUNCH ESCAPES */     00243000
  DECLARE VALID_00_OP BIT(8) INITIAL("6D"); /* THE OVERPUNCH VALID IN GENERATING00243100
                                             THE X'00' CHARACTER */             00243200
   DECLARE VALID_00_CHAR BIT(8) INITIAL("F0");  /* THE CHARACTER WHICH, WHEN    00243300
                                                "ESCAPED" BY THE PROPER OP CHAR 00243400
                                                GENERATES X'00' INTERNALLY */   00243500
   DECLARE STACK_DUMPED BIT(1);                                                 00243600
 /***** CR11088 1/90 RAH **********************************************/
 /* CHANGED INITIAL VALUE OF DOWN_COUNT FROM 1 TO 0 BECAUSE IT IS NOW */
 /* PRE-INCREMENTED INSTEAD OF POST-INCREMENTED.                      */
   DECLARE DOWN_COUNT BIT(16) INITIAL(0);                                       00243610
 /***** END CR11088 ***************************************************/
   DECLARE SEVERITY BIT(16);                                                    00243620
   DECLARE PARTIAL_PARSE BIT(1);                                                00253600
   DECLARE TEMPORARY_IMPLIED BIT(1);                                            00253700
   DECLARE RESERVED_WORD BIT(1);                                                00253800
   DECLARE IMPLICIT_T BIT(1);                                                   00254000
   DECLARE WAIT BIT(1);                                                         00254100
   DECLARE OUT_PREV_ERROR BIT(16);                                              00254200
   DECLARE (INDENT_LEVEL, LABEL_COUNT, INDENT_INCR) BIT(16);                    00254300
   DECLARE INLINE_INDENT BIT(16),                                               00254400
      INLINE_STMT_RESET BIT(16),                                                00254500
      INLINE_INDENT_RESET BIT(16) INITIAL(-1);                                  00254600
   DECLARE STACK_DUMP_MAX LITERALLY '10';                                       00254700
   DECLARE SAVE_STACK_DUMP(STACK_DUMP_MAX) CHARACTER;                           00254800
   DECLARE STACK_DUMP_PTR BIT(16);                                              00254900
   DECLARE SAVE_INDENT_LEVEL BIT(16);                                           00255000
   DECLARE OUTPUT_WRITER_DISASTER LABEL;                                        00255100
   DECLARE (PAD1, PAD2) CHARACTER;                                              00255200
   DECLARE SMRK_FLAG BIT(8);                                                    00255500
   DECLARE SCAN_DISASTER LABEL; /* DR109036 */                                  00255100
                                                                                00255600
 /* TEMPLATE EMISSION DECLARATIONS */                                           00255700
   DECLARE (EXTERNALIZE,TPL_VERSION) BIT(16),                                   00255800
      TPL_FLAG BIT(16) INITIAL(3),                                              00255900
      TPL_NAME CHARACTER,                                                       00256000
      PARMS_PRESENT BIT(16),                                                    00256100
      PARMS_WATCH BIT(1),                                                       00256200
      TPL_REMOTE BIT(1),                                                        00256220
      TPL_LRECL BIT(16) INITIAL(80);        /*DR111314*/                        00256300
                                                                                00256400
 /* HALMAT DECLARATIONS */                                                      00256500
   DECLARE (NEXT_ATOM#,ATOM#_FAULT,LAST_POP#,CURRENT_ATOM) FIXED,               00256600
      ATOM#_LIM LITERALLY '1799',  /* SIZE OF BLOCK IN WORDS -1  */             00256700
      HALMAT_BLOCK BIT(16),                                                     00256800
      (HALMAT_OK,HALMAT_CRAP) BIT(1),                                           00256900
      HALMAT_FILE LITERALLY '1',                                                00257000
      HALMAT_RELOCATE_FLAG BIT(1);                                              00257100
                                                                                00257200
                                                                                00257300
 /*  DECLARATIONS FOR STATEMENT FILE  */                                        00257400
   DECLARE STAB_STACKLIM LITERALLY '128';                                       00257900
   ARRAY STAB_STACK(STAB_STACKLIM) BIT(16),                                     00257910
      STAB2_STACK(STAB_STACKLIM) BIT(16);                                       00257920
   DECLARE (STAB_STACKTOP,STAB_MARK) BIT(16),                                   00257930
      (STAB2_STACKTOP,STAB2_MARK) BIT(16),                                      00258120
      LAST_STAB_CELL_PTR FIXED INITIAL(-1),                                     00258130
      STMT_TYPE BIT(16),                                                        00258200
      SIMULATING BIT(8),                                                        00258300
      XSET LITERALLY 'STMT_TYPE=STMT_TYPE|';                                    00258400
   DECLARE SRN(2) CHARACTER, INCL_SRN(2) CHARACTER,                             00258600
      (SRN_PRESENT, ADDR_PRESENT, SDL_OPTION) BIT(1),                           00258700
      SREF_OPTION BIT(1),                                                       00258710
      SRN_FLAG BIT(1),                                                          00258800
      (SRN_MARK,INCL_SRN_MARK) CHARACTER,                                       00258900
      SRN_COUNT_MARK BIT(16),                                                   00259000
      SRN_COUNT(2) BIT(16),                                                     00259100
      SAVE_SRN_COUNT1 BIT(16),                         /*DR120227*/
      SAVE_SRN_COUNT2 BIT(16);                         /*DR120227*/
 /*  %MACRO DECLARATIONS  */                                                    00259200
 /*CR13570 - CHANGE STARTING POINT OF MACROS FOR STMT_TYPES IN SDF*/
   DECLARE PC_STMT_TYPE_BASE LITERALLY '"1E"';  /* FIRST IS "1F" */             00259300

   /***********************************************/
   /* THE PASS SYSTEM SUPPORTS THE NAMEADD MACRO, */
   /* WHILE THE BFS SYSTEM DOES NOT.              */
   /***********************************************/
 /?P /* CR11114 -- BFS/PASS INTERFACE; %NAMEADD */
   DECLARE PCNAME CHARACTER INITIAL(                                            00259400
   '                %NAMEBIAS       %SVC            %NAMECOPY       %COPY       00259500
    %SVCI           %NAMEADD        '),   /*CR13570*/                           00259502
 ?/
 /?B /* CR11114 -- BFS/PASS INTERFACE; %NAMEADD */
   DECLARE PCNAME CHARACTER INITIAL(                                            00259400
   '                                %SVC            %NAMECOPY       %COPY       00259500
    %SVCI           '),                  /*CR13570*/
 ?/
      PCCOPY_INDEX LITERALLY '3',                                               00259510
      PC_LIMIT BIT(16) INITIAL(9),  /* LONGEST NAME */                          00259600

 /?P  /* CR11114 -- BFS/PASS INTERFACE; %NAMEADD */
      PC_INDEX LITERALLY '6',  /* NUMBER OF NAMES */             /*CR13570*/    00259700
      ALT_PCARG#(PC_INDEX) BIT(16) INITIAL(0, 2, 1, 2, 2, 1, 3), /*CR13570*/    00259800
      PCARG#(PC_INDEX) BIT(16) INITIAL(0, 2, 1, 2, 3, 1, 3),     /*CR13570*/    00259900
      PCARGOFF(PC_INDEX) BIT(16) INITIAL(0, 1, 3, 5, 7, 10, 11), /*CR13570*/    00260000
      PCARG_MAX LITERALLY '13',  /* TOTAL NUMBER OF ARGS */      /*CR13570*/    00260100
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE; %NAMEADD */
      PC_INDEX LITERALLY '5',  /* NUMBER OF NAMES */             /*CR13570*/
      ALT_PCARG#(PC_INDEX) BIT(16) INITIAL(0, 0, 1, 2, 2, 1),    /*CR13570*/
      PCARG#(PC_INDEX) BIT(16) INITIAL(0, 0, 1, 2, 3, 1),        /*CR13570*/
      PCARGOFF(PC_INDEX) BIT(16) INITIAL(0, 0, 1, 3, 5, 8),      /*CR13570*/
      PCARG_MAX LITERALLY '8',  /* TOTAL NUMBER OF ARGS */
 ?/
      PCARGTYPE(PCARG_MAX) FIXED INITIAL(0,                                     00260200
 /?P  "(1)00001000000",    /*CR13570*/
      "(1)11001111110",    /*CR13570*/
 ?/                        /*CR13570*/
      "(1)11001111110",                                                         00260200
      0, /* SPACE FOR SECOND %SVC ARG */                                        00260210
      "(1)10000000000",                                                         00260300
      "(1)10000000000",                                                         00260400
      "(1)11001111110",                                                         00260500
      "(1)11001111110",                                                         00260600
      "(1)100000000000000000001000000",                                         00260700

 /?P  /* CR11114 -- BFS/PASS INTERFACE; SVC */
      0, /* %SVCI UNIMPLEMENTED */                                              00260710
      "(1)11001111110",                                                         00260720
      "(1)11001111110",                                                         00260730
 ?/
      "(1)100000000000000000001000000"),                                        00260740
      PCARGBITS(PCARG_MAX) BIT(16) INITIAL(0,                                   00260800
 /?P  "(1)101110101",    /*CR13570*/
      "(1)000000101",    /*CR13570*/
 ?/                      /*CR13570*/
      "(1)100001101",                                                           00260800
      0,  /* SECOND %SVC ARG */                                                 00260810
      "(1)11010001",                                                            00260900
      "(1)11000001",                                                            00261000
      "(1)00010101",                                                            00261100
      "(1)00000101",                                                            00261200
      "(1)101101101",                                                           00261300

 /?P  /* CR11114 -- BFS/PASS INTERFACE; SVC */
      0, /* %SVCI UNIMPLEMENTED */                                              00261310
      "(1)11010001",                                                            00261320
      "(1)11000001",                                                            00261330
 ?/
      "(1)101101101");                                                          00261340
   DECLARE (MORE,UPDATING,REPLACING,ADDING,DELETING)                            00261350
      BIT(1);                                                                   00261360
   DECLARE LIST_INCLUDE BIT(1) INITIAL(0);                                      00261370
   DECLARE PATCH_COUNT FIXED INITIAL(0);                                        00261380
   DECLARE (REV_CAT) FIXED;                                                     00261390
   DECLARE MEMBER CHARACTER;                                                    00261400
   DECLARE (CURRENT_SRN,PATCH_SRN,PATCH_CARD) CHARACTER;                        00261410
   DECLARE (PAT_CARD,CUR_CARD) CHARACTER;                                       00261430
   DECLARE COMPARE_SOURCE BIT(1) INITIAL(1);                                    00261440
   DECLARE UPDATE_INPUT_DEV BIT(16);                                            00261450
   DECLARE ADDED CHARACTER INITIAL('+++ ADDED');                                00261460
   DECLARE DELETED CHARACTER INITIAL('--- DELETED');                            00261470
   DECLARE PRINT_INCL_HEAD BIT(1);                                              00261480
   DECLARE PRINT_INCL_TAIL BIT(1);                                              00261490
   DECLARE (INCL_LOG_MSG,PATCH_INCL_HEAD) CHARACTER;                            00261500
   DECLARE NO_MORE_SOURCE BIT(1) INITIAL(0);                                    00261530
   DECLARE NO_MORE_PATCH BIT(1) INITIAL(0);                                     00261550
   DECLARE FIRST_CARD BIT(1);                                                   00261560
   DECLARE HMAT_OPT BIT(1);                                                     00261565
   DECLARE INCREMENT_DOWN_STMT BIT(1);       /*DR108603*/
   DECLARE PREV_STMT_NUM FIXED INITIAL(-1);  /*DR108603*/
   DECLARE INCLUDE_STMT FIXED INITIAL(-1);   /*DR109074*/
 /* INCLUDE COMMON DECLS FOR REL19:  $%COMDEC19 */                              00261575
   DECLARE DWN_STMT(1) LITERALLY 'DOWN_INFO(%1%).DOWN_STMT';                    00261576
   DECLARE DWN_ERR(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_ERR';                     00261577
   DECLARE DWN_CLS(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_CLS';                     00261578
/********************* DR108630 - TEV - 10/29/93 *********************/
   DECLARE DWN_UNKN(1) LITERALLY 'DOWN_INFO(%1%).DOWN_UNKN';
/********************* END DR108630 **********************************/
   DECLARE DWN_VER(1)  LITERALLY 'DOWN_INFO(%1%).DOWN_VER';                     00261579
   DECLARE PREV_ELINE BIT(1) INITIAL(FALSE);            /*CR12713*/
   DECLARE NEXT_CC CHARACTER INITIAL('0');              /*CR12713*/
   DECLARE SAVE_DO_LEVEL BIT(16) INITIAL(-1);           /*CR12713*/
   DECLARE IFDO_FLAG(DO_LEVEL_LIM) BIT(1);              /*CR12713*/
   DECLARE   IF_FLAG BIT(1) INITIAL(FALSE);             /*CR12713*/
   DECLARE ELSE_FLAG BIT(1) INITIAL(FALSE);             /*CR12713*/
   DECLARE  END_FLAG BIT(1) INITIAL(FALSE);             /*CR12713*/
   DECLARE  MOVE_ELSE BIT(1) INITIAL(TRUE);             /*CR12713*/
   DECLARE (SAVE1,SAVE2) FIXED;                         /*CR12713*/
   DECLARE (SAVE_SRN1,SAVE_SRN2) CHARACTER;             /*CR12713*/
   DECLARE RVL(1) CHARACTER;                            /*CR12940*/
   DECLARE NEXT_CHAR_RVL CHARACTER;                     /*CR12940*/
   ARRAY RVL_STACK1(OUTPUT_STACK_MAX) BIT(8);           /*CR12940*/
   ARRAY RVL_STACK2(OUTPUT_STACK_MAX) BIT(8);           /*CR12940*/
   DECLARE DOUBLELIT BIT(1);                            /*DR109083*/
   DECLARE NO_NEW_XREF BIT(1) INITIAL(FALSE);           /*DR111356*/
   DECLARE ADV_STMT#(1) LITERALLY 'ADVISE(%1%).STMT#',  /*CR13211*/
           ADV_ERROR#(1) LITERALLY 'ADVISE(%1%).ERROR#';/*CR13211*/
 /* INCLUDE TABLE FOR DOWNGRADES:    $%DWNTABLE */                              00261580
 /* INCLUDE ERROR DECLARATIONS:      $%CERRDECL */                              00261581
 /* INCLUDE DOWNGRADE SUMMARY:       $%DOWNSUM  */                              00261582
 /**MERGE PAD          PAD                             */
 /**MERGE CHARINDE     CHAR_INDEX                      */
 /**MERGE ERRORS       ERRORS                          */
 /**MERGE MIN          MIN                             */
 /**MERGE MAX          MAX                             */
 /**MERGE GETLITER     GET_LITERAL                     */
 /**MERGE UNSPEC       UNSPEC                          */
 /**MERGE BLANK        BLANK                           */
 /**MERGE LEFTPAD      LEFT_PAD                        */
 /**MERGE DESCORE      DESCORE                         */
 /**MERGE HEX          HEX                             */
 /**MERGE IFORMAT      I_FORMAT                        */
 /**MERGE SAVEINPU     SAVE_INPUT                      */
 /**MERGE PRINT2       PRINT2                          */
 /**MERGE OUTPUTGR     OUTPUT_GROUP                    */
 /**MERGE SAVEDUMP     SAVE_DUMP                       */
 /**MERGE ERROR        ERROR                           */
 /**MERGE MAKEFIXE     MAKE_FIXED_LIT                  */
 /**MERGE FLOATING     FLOATING                        */
 /**MERGE HASH         HASH                            */
 /**MERGE SETTLIMI     SET_T_LIMIT                     */
 /**MERGE SRNCMP       SRNCMP                          */
 /**MERGE OUTPUTWR     OUTPUT_WRITER                   */
 /**MERGE FINDER       FINDER                          */
 /**MERGE SAVETOKE     SAVE_TOKEN                      */
 /**MERGE INTERPRE     INTERPRET_ACCESS_FILE           */
 /**MERGE DECOMPRE     DECOMPRESS                      */
 /**MERGE SOURCECO     SOURCE_COMPARE                  */
 /**MERGE NEXTRECO     NEXT_RECORD                     */
 /**MERGE ORDEROK      ORDER_OK                        */
 /**MERGE STREAM       STREAM                          */
 /**MERGE COMPRESS     COMPRESS_OUTER_REF              */
 /**MERGE BLOCKSUM     BLOCK_SUMMARY                   */
 /**MERGE SETOUTER     SET_OUTER_REF                   */
 /**MERGE SETBIXRE     SET_BI_XREF                     */
 /**MERGE SETXREF      SET_XREF                        */
 /**MERGE SETXREFR     SET_XREF_RORS                   */
 /**MERGE BUFFERMA     BUFFER_MACRO_XREF               */
 /**MERGE POPMACRO     POP_MACRO_XREF                  */
 /**MERGE IDENTIFY     IDENTIFY                        */
 /**MERGE SYTDUMP      SYT_DUMP                        */
 /**MERGE TIEXREF      TIE_XREF                        */
 /**MERGE LITDUMP      LIT_DUMP                        */
 /**MERGE PREPLITE     PREP_LITERAL                    */
 /**MERGE SCAN         SCAN                            */
 /**MERGE EMITEXTE     EMIT_EXTERNAL                   */
 /**MERGE SRNUPDAT     SRN_UPDATE                      */
 /**MERGE CHARTIME     CHARTIME                        */
 /**MERGE CHARDATE     CHARDATE                        */
 /**MERGE PRINTTIM     PRINT_TIME                      */
 /**MERGE PRINTDAT     PRINT_DATE_AND_TIME             */
 /**MERGE STABVAR      STAB_VAR                        */
 /**MERGE STABLAB      STAB_LAB                        */
 /**MERGE STABHDR      STAB_HDR                        */
 /**MERGE HALMATBL     HALMAT_BLAB                     */
 /**MERGE HALMATRE     HALMAT_RELOCATE                 */
 /**MERGE HALMATOU     HALMAT_OUT                      */
 /**MERGE HALMAT       HALMAT                          */
 /**MERGE HALMATXN     HALMAT_XNOP                     */
 /**MERGE HALMATBA     HALMAT_BACKUP                   */
 /**MERGE HALMATPO     HALMAT_POP                      */
 /**MERGE HALMATPI     HALMAT_PIP                      */
 /**MERGE HALMATTU     HALMAT_TUPLE                    */
 /**MERGE HALMATFI     HALMAT_FIX_PIP#                 */
 /**MERGE HALMATF2     HALMAT_FIX_POPTAG               */
 /**MERGE HALMATF3     HALMAT_FIX_PIPTAGS              */
 /**MERGE EMITSMRK     EMIT_SMRK                       */
 /**MERGE EMITPUSH     EMIT_PUSH_DO                    */
 /**MERGE PUSHINDI     PUSH_INDIRECT                   */
 /**MERGE LABELMAT     LABEL_MATCH                     */
 /**MERGE UNBRANCH     UNBRANCHABLE                    */
 /**MERGE SETUPVAC     SETUP_VAC                       */
 /**MERGE VECTORCO     VECTOR_COMPARE                  */
 /**MERGE MATRIXCO     MATRIX_COMPARE                  */
 /**MERGE CHECKARR     CHECK_ARRAYNESS                 */
 /**MERGE UNARRAYE     UNARRAYED_INTEGER               */
 /**MERGE UNARRAY2     UNARRAYED_SCALAR                */
 /**MERGE UNARRAY3     UNARRAYED_SIMPLE                */
 /**MERGE CHECKEVE     CHECK_EVENT_EXP                 */
 /**MERGE PROCESS2     PROCESS_CHECK                   */
 /**MERGE CHECKASS     CHECK_ASSIGN_CONTEXT            */
 /**MERGE ERRORSUB     ERROR_SUB                       */
 /**MERGE MATCHSIM     MATCH_SIMPLES                   */
 /**MERGE READALLT     READ_ALL_TYPE                   */
 /**MERGE STRUCTUR     STRUCTURE_COMPARE               */
 /**MERGE PUSHFCNS     PUSH_FCN_STACK                  */
 /**MERGE UPDATEBL     UPDATE_BLOCK_CHECK              */
 /**MERGE ARITHLIT     ARITH_LITERAL                   */
 /**MERGE PRECSCAL     PREC_SCALE                      */
 /**MERGE BITLITER     BIT_LITERAL                     */
 /**MERGE CHARLITE     CHAR_LITERAL                    */
 /**MERGE MATCHARI     MATCH_ARITH                     */
 /**MERGE LITRESUL     LIT_RESULT_TYPE                 */
 /**MERGE ADDANDSU     ADD_AND_SUBTRACT                */
 /**MERGE MULTIPLY     MULTIPLY_SYNTHESIZE             */
 /**MERGE IORS         IORS                            */
 /**MERGE EMITARRA     EMIT_ARRAYNESS                  */
 /**MERGE SAVEARRA     SAVE_ARRAYNESS                  */
 /**MERGE RESETARR     RESET_ARRAYNESS                 */
 /**MERGE ARITHTOC     ARITH_TO_CHAR                   */
 /**MERGE GETARRAY     GET_ARRAYNESS                   */
 /**MERGE NAMECOMP     NAME_COMPARE                    */
 /**MERGE KILLNAME     KILL_NAME                       */
 /**MERGE COPINESS     COPINESS                        */
 /**MERGE NAMEARRA     NAME_ARRAYNESS                  */
 /**MERGE CHECKNAM     CHECK_NAMING                    */
 /**MERGE MATCHARR     MATCH_ARRAYNESS                 */
 /**MERGE STRUCTU2     STRUCTURE_FCN                   */
 /**MERGE SETUPNOA     SETUP_NO_ARG_FCN                */
 /**MERGE STARTNOR     START_NORMAL_FCN                */
 /**MERGE GETFCNPA     GET_FCN_PARM                    */
 /**MERGE SETUPCAL     SETUP_CALL_ARG                  */
 /**MERGE ARITHSHA     ARITH_SHAPER_SUB                */
 /**MERGE CHECKSUB     CHECK_SUBSCRIPT                 */
 /**MERGE REDUCESU     REDUCE_SUBSCRIPT                */
 /**MERGE ASTSTACK     AST_STACKER                     */
 /**MERGE SLIPSUBS     SLIP_SUBSCRIPT                  */
 /**MERGE ATTACHSU     ATTACH_SUB_COMPONENT            */
 /**MERGE ATTACHS2     ATTACH_SUB_ARRAY                */
 /**MERGE ATTACHS3     ATTACH_SUB_STRUCTURE            */
 /**MERGE ATTACHS4     ATTACH_SUBSCRIPT                */
 /**MERGE EMITSUBS     EMIT_SUBSCRIPT                  */
 /**MERGE ENDANYFC     END_ANY_FCN                     */
 /**MERGE ENDSUBBI     END_SUBBIT_FCN                  */
 /**MERGE GETICQ       GET_ICQ                         */
 /**MERGE ICQARRA2     ICQ_ARRAYNESS_OUTPUT            */
 /**MERGE ICQCHECK     ICQ_CHECK_TYPE                  */
 /**MERGE ICQOUTPU     ICQ_OUTPUT                      */
 /**MERGE HOWTOINI     HOW_TO_INIT_ARGS                */
 /**MERGE HALMATIN     HALMAT_INIT_CONST               */
 /**MERGE COMPARE      COMPARE                         */
 /**MERGE CHECKCON     CHECK_CONSISTENCY               */
 /**MERGE CHECKCO2     CHECK_CONFLICTS                 */
 /**MERGE CHECKEV2     CHECK_EVENT_CONFLICTS           */
 /**MERGE SETSYTEN     SET_SYT_ENTRIES                 */
 /**MERGE GETSUBSE     GET_SUBSET                      */
 /**MERGE INITIALI     INITIALIZATION                  */
 /**MERGE CHECKIMP     CHECK_IMPLICIT_T                */
 /**MERGE CALLSCAN     CALL_SCAN                       */
 /**MERGE DUMPIT       DUMPIT                          */
 /**MERGE STACKDUM     STACK_DUMP                      */
 /**MERGE SETLABEL     SET_LABEL_TYPE                  */
 /**MERGE ASSOCIAT     ASSOCIATE                       */
 /**MERGE SETBLOCK     SET_BLOCK_SRN                   */
 /**MERGE SYNTHESI     SYNTHESIZE                      */
 /**MERGE CHECKTOK     CHECK_TOKEN                     */
 /**MERGE RECOVER      RECOVER                         */
 /**MERGE COMPILAT     COMPILATION_LOOP                */
 /**MERGE ERRORSUM     ERROR_SUMMARY                   */
 /**MERGE PRINTSUM     PRINT_SUMMARY                   */
                                                                                01562600
THE_BEGINNING:
   CLOCK(0)=MONITOR(18);                                                        01562800
   CALL INITIALIZATION;                                                         01562900
                                                                                01563000
   CLOCK(1)=MONITOR(18);                                                        01563100
   CALL COMPILATION_LOOP;                                                       01563300
                                                                                01563400
ALMOST_DISASTER:/* END COMPILATION AFTER INDIRECT STACK OVERFLOW  */            01563500
 /*  COMPILING = FALSE WHEN YOU BRANCH TO HERE  */                              01563600
   OUTPUT(1) = SUBHEADING;                                                      01563700
                                                                                01563800
   CLOCK(2)=MONITOR(18);                                                        01563900
   /* CR12416: SEVERITY 1 ERRORS TREATED AS WARNING UNTIL NOW */                07959000
   IF (MAX_SEVERITY = 0) & SEVERITY_ONE              /* CR12416 */              07959000
      THEN MAX_SEVERITY = 1;                         /* CR12416 */              07959000
                                                                                01564000
 /* CLOCK(3) GETS SET IN PRINT_SUMMARY */                                       01564100
   CALL PRINT_SUMMARY;                                                          01564200
                                                                                01564340
   IF (COMPILING&"80")^=0 THEN             /*  HALMAT COMPLETE FLAG  */         01564400
      IF MAX_SEVERITY<2 THEN                                                    01564500
      IF CONTROL(1)=FALSE THEN DO;                                              01564600
 TOGGLE=(CONTROL(2)&"80")|(CONTROL(5)&"40")|(CONTROL(9)&"10")|(CONTROL(6)&"20");01564700
      IF MAX_SEVERITY>0 THEN TOGGLE=TOGGLE|"08";                                01564800
      CALL RECORD_LINK;                                                         01565000
   END;                                                                         01565100
   MAX_SEVERITY=4;                                                              01565200
   GOTO ENDITNOW;                                                               01565300
/* DR109036: AFTER SEVERITY 3/4 ERROR IN SCAN, PRINT THE ERROR */               01565400
SCAN_DISASTER:         /* DR109036 */                                           01565400
   CALL OUTPUT_WRITER; /* DR109036 */                                           01565400
OUTPUT_WRITER_DISASTER:                                                         01565400
   OUTPUT(1) = SUBHEADING;                                                      01565500
   CALL ERROR_SUMMARY;                                                          01565600
ENDITNOW:                                                                       01565700
   DOUBLE_SPACE;                                                                01565800
   IF MAX_SEVERITY > 2 THEN DO;                                                 01565810
      CALL DOWNGRADE_SUMMARY;                 /* CR13273 */                     01565820
   END;                                                                         01565860
   OUTPUT=X32||'*****  C O M P I L A T I O N   A B A N D O N E D  *****';       01565900
   RETURN SHL(MAX_SEVERITY, 2);                                                 01566000
                                                                                01566100
   EOF EOF EOF                                                                  01566200
