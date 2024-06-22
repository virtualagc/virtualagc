 /*@
    Access:     Public Domain, no restrictions believed to exist.
    Filename:   PASS2/##DRIVER.xpl
    Purpose:    This is a part of the HAL/S-FC compiler program.
    Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
    Language:   XPL.
    Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
    History:    2023-04-16 RSB  Suffixed the filename with ".xpl".
    		2024-06-21 RSB	Added a modification to the source code to 
    				work around the problem of "unverified"
    				runtime-library routines.  Reluctantly.
    				More explanation is below.
    Note:       Inline comments beginning with "/*@" were created by the
                Virtual AGC Project. Inline comments beginning merely with
                "/*" are from the original Space Shuttle development.
    
    Certification of Runtime-Library Routines
    -----------------------------------------
    
    AP-101S runtime-library routines as developed by Intermetrics provided a 
    lot of functionality, some of which was not needed for the flight software,
    but which nevertheless might be useful for non-flight software.  To be used
    for flight software, a runtime-library routine needed to undergo a 
    "certification" process, and (I am told) because the certification process
    would have had to be paid for, successors to Intermetrics (Loral, 
    Lockheed Martin, USA) did not certify those routines not needed for flight
    software.
    
    PASS2 contains not only a list of the runtime-library routines, but knows
    which routines were certified -- PASS2 refers to them as "verified" -- and
    which were not certified ("unverified").  If you write a HAL/S program that
    indirectly results in an uncertified runtime-library routine being called,
    PASS2 issues an XS3 error, "ATTEMPT TO INVOKE UNVERIFIED RUNTIME LIBRARY 
    ROUTINE", of severity level 1. 
    
    Where I ran afoul of this was in HAL/S test code I wrote that contained
    statements like "WRITE(6) '...message...';", which use the uncertified
    functions IOINIT and COUT.  WRITE, after all, is perfectly legitimate
    HAL/S, found for example throughout Ryer's book "Programming in HAL/S", and 
    should *not* be generating fatal compile-time errors!
    
    There are several workarounds, such as downgrading XS3 errors to severity
    0 with the compiler directive "D DOWNGRADE XS3", or editing the XS3 error
    in the ERRLIB library to have severity 0.  However, even though downgraded
    to severity 0, these will still be *errors* that show up in compiler reports
    and possibly in other ways.
    
    In PASS2, the certification status of runtime-library routines is maintained
    by the integer arrays LIB_START and LIB_LINK.  These arrays contain both
    positive and negative numbers.  The positive numbers relate to the certified
    functions, and the negative numbers relate to the uncertified functions.
    Therefore, it is *possible* to mark all of the functions as certified by
    making all of the numbers in these arrays positive.
    
    What I have done (search for "2024-06-21 RSB" below) is to introduce new 
    compilation-conditionals,
    
    	/?V ... ?/
    	/?W ... ?/
    	
    W is the default, and the original LIB_START/LIB_LINK declarations now are
    enclosed by it.  V instead contains LIB_START/LIB_LINK declarations with 
    all positive numbers.
    
    By default, when PASS2 is compiled with XCOM-I, then W is applied, and the 
    original PASS2 source code is compiled as-is.  But if PASS2 is compiled
    with XCOM-I's command-line switch --cond=V, then the all-positive tables
    are used instead, thus all runtime-library functions become "certified",
    and all XS3 errors are eliminated.
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
 /*  REVISION HISTORY :                                                     */
 /*  ------------------                                                     */
 /*  DATE   NAME  REL   DR NUMBER AND TITLE                                 */
 /*                                                                         */
 /*07/26/90 RPC   23V1  102954 NAME REMOTE COMPARISON INCORRECT OBJ CODE    */
 /*                                                                         */
 /*08/03/90 RPC   23V1  102971 %COPY OF A REMOTE NAME                       */
 /*                                                                         */
 /*10/12/90 RAH   23V1  102965 %NAMECOPY FAILS TO GENERATE FT111 ERROR MSG  */
 /*                                                                         */
 /*10/19/90 DAS   23V1  11053  (CR) RESTRICT RUNTIME LIBRARY USE            */
 /*                                                                         */
 /*11/16/90 DAS   23V1  103753 PART2: FIX INCORRECT INDEX VALUES            */
 /*                                                                         */
 /*12/21/90 DAS   23V1  103754 EXTRA CODE "SER" GENERATED BY COMPILER       */
 /*                                                                         */
 /*01/25/91 DKB   23V2  CR11098 DELETE SPILL CODE FROM COMPILER             */
 /*                                                                         */
 /*02/15/91 LWW   23V2  CR11095 SPLIT THE COMPILER SDL OPTION               */
 /*                                                                         */
 /*03/04/91 RAH   23V2  CR11109 CLEANUP OF COMPILER SOURCE CODE             */
 /*                                                                         */
 /*07/08/91 RSJ   24V0  CR11096 #DFLAG - ADD NEW ERROR CLASS AND GLOBAL     */
 /*                             VARIABLES FOR CSECT_TYPE;                   */
 /*                                                                         */
 /*07/09/91 RSJ   24V0  CR11096 #DMVH - ADDED GLOBAL VARIABLES TO BE        */
 /*                             USED FOR  THE NEW #DMVH SETUP               */
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DDSE - ADDED LDM INSTRUCTION AND           */
 /*                             ESD VARIABLES FOR DSE CONSTANTS             */
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DNAME - UNCOMMENTED OHI FOR DR103750       */
 /*                             AND MOVE SINGLE_VALUED USING MERGE          */
 /*                                                                         */
 /*07/15/91 DAS   24V0  CR11096 #DREG - ADDED GLOBAL VARIABLES TO BE        */
 /*                             USED FOR #D REGISTER ALLOCATION             */
 /*                                                                         */
 /*05/07/92 JAC    7V0  CR11114 MERGE BFS/PASS COMPILERS                    */
 /*                                                                         */
 /*09/09/92 JAC    7V0  CR11114 BACKOUT DR103753 - MAKE PASS SPECIFIC       */
 /*                                                                         */
 /*12/23/92 PMA    8V0  *       MERGED 7V0 AND 24V0 COMPILERS.              */
 /*                             * REFERENCE 24V0 CR/DRS                     */
 /*                                                                         */
 /*05/24/93 PMA   25V0  103753  REMOVED "PASS SPECIFIC" CONSTRAINT IN       */
 /*                9V0          CONCURRENCE WITH DR108535 FIX               */
 /*                                                                         */
 /*6/8/93   TEV   25V0/ 108535  INVALID USE OF SRS TYPE INSTRUCTION         */
 /*                9V0                                                      */
 /*                                                                         */
 /*11/02/93 DKB   25V1, 106968  INCORRECT RLD EMITTED (APPLIED CHANGE       */
 /*                9V1          FROM 24V2 USING CCC, CHANGE NOT IN          */
 /*                             25V0/9V0)                                   */
 /*                                                                         */
 /*02/11/94 PMA   26V0, CR12305 MODIFY VERIFIED HAL/S RTL LIST              */
 /*               10V0                                                      */
 /*                                                                         */
 /*02/01/94 PMA   26V0, CR11133 VERIFY HAL/S FC RTL'S                       */
 /*               10V0                                                      */
 /*                                                                         */
 /*04/05/94 JAC   26V0, 108643  INCORRECTLY LISTS 'NONHAL' INSTEAD OF       */
 /*               10V0          'INCREM' IN SDFLISTS                        */
 /*                                                                         */
 /*06/22/95 DAS   27V0, CR12416 IMPROVE COMPILER ERROR PROCESSING           */
 /*               11V0                                                      */
 /*                                                                         */
 /*05/04/95 RSJ   27V0/ 109016 WRONG BASE REGISTER USED WITH DATA_REMOTE    */
 /*               11V0                                                      */
 /*                                                                         */
 /*02/10/95 DAS   27V0, 103787  WRONG VALUE LOADED FROM REGISTER FOR        */
 /*               11V0          A STRUCTURE NODE DEREFERENCE                */
 /*                                                                         */
 /*03/06/95  RSJ  27V0, 109019  COMPILER INCORRECTLY ADJUSTS FOR            */
 /*               11V0          AUTOMATIC INDEX ALIGNMENT                   */
 /*                                                                         */
 /*12/06/95  SMR  27V1, 108618  DI107 ERROR INCORRECTLY EMITTED             */
 /*               11V1          FOR NAME PROGRAM & NAME TASK                */
 /*                                                                         */
 /*04/08/97  DAS  28V0, CR12432 ALLOW DEREFERENCING OF NAME REMOTE          */
 /*               12V0                                                      */
 /*                                                                         */
 /* 1/15/97  SMR  28V0, CR12713 ENHANCE COMPILER LISTING                    */
 /*               12V0                                                      */
 /*                                                                         */
 /*03/14/97  TEV  28V0, 109055  MATRIX STRUCTURE NODE USE INCORRECTLY CALLS */
 /*               12V0          VR1SN                                       */
 /*                                                                         */
 /*08/06/96  SMR  28V0, 109044  DI17 ERROR EMITTED FOR NAME                 */
 /*               12V0          CHARACTER(*) PARAMETERS                     */
 /*                                                                         */
 /*05/06/98  SMR  29V0  109095  BIT STORE VIA DATA REMOTE NAME              */
 /*               14V0          REMOTE DEREFERENCE FAILS                    */
 /*                                                                         */
 /*03/24/98  BJW  29V0,  109071 STRUCTURE IN ASSIGN PARAMETER GETS ERROR    */
 /*               14V0                                                      */
 /*                                                                         */
 /*01/05/98  DCP  29V0, CR12940 ENCHANCE COMPILER LISTING                   */
 /*               14V0                                                      */
 /*                                                                         */
 /*02/18/98  SMR  29V0, 12940   ENHANCE COMPILER LISTING                    */
 /*               14V0                                                      */
 /*                                                                         */
 /*10/06/97  SMR  29V0, 109067  INDIRECT STACK ENTRY NOT RETURNED FOR       */
 /*               14V0          STRUCTURE INITIALIZATION                    */
 /*                                                                         */
 /*12/19/97  SMR  29V0, 109084  STRUCTURE INITIALIZATION MAY CAUSE          */
 /*               14V0          INCORRECT HALMAT                            */
 /*                                                                         */
 /*12/13/99  TKN  30V0  13211   GENERATE ADVISORY MSG WHEN BIT STRING       */
 /*               15V0          ASSIGNED TO SHORTER STRING                  */
 /*                                                                         */
 /*11/17/99  DAS  30V0, CR13222 REMOVE ERROR-PRONE DESIGN OF COMPILER       */
 /*               15V0          LIBRARY DESCRIPTION TABLE                   */
 /*                                                                         */
 /*04/05/99  LJK  30V0, CR12620 SELECTIVE CLEARING OF DSES AROUND RTL CALLS */
 /*               15V0                                                      */
 /*                                                                         */
 /*02/24/99  TKN  30V0, 111307  COMPILER ABEND DURING BIX LOOP GENERATION   */
 /*               15V0                                                      */
 /*                                                                         */
 /*07/14/99  DCP  30V0, 12214   USE THE SAFEST %MACRO THAT WORKS            */
 /*               15V0                                                      */
 /*                                                                         */
 /*04/08/99  SMR  30V0 CR13079  ADD HAL/S INITIALIZATION DATA TO SDF        */
 /*               15V0                                                      */
 /*                                                                         */
 /*06/18/99  SMR  30V0, 111327  SEVERITY 1 ERROR NOT REPORTED               */
 /*               15V0                                                      */
 /*                                                                         */
 /*05/03/01  JAC  31V0, 111362  UNNECESSARY STACK WALKBACK                  */
 /*               16V0                                                      */
 /*                                                                         */
 /*04/26/01  DCP  31V0,CR13335  ALLEVIATE SOME DATA SPACE PROBLEMS          */
 /*               16V0          IN HAL/S COMPILER                           */
 /*                                                                         */
 /*03/05/01  DCP  31V0, 111367  ABEND OCCURS FOR A MULTI-DIMENSIONAL ARRAY  */
 /*               16V0                                                      */
 /*                                                                         */
 /*12/15/00  JAC  31V0, 111358  BI511 ERROR FOR BIT ASSIGNMENT IN LOOP      */
 /*               16V0                                                      */
 /*                                                                         */
 /*03/02/04  DCP  32V0 CR13811  ELIMINATE STACK WALKBACK CAPABILITY         */
 /*               17V0                                                      */
 /*                                                                         */
 /*09/04/02  DCP  32V0 CR13616  IMPROVE READABILITY AND ADD COMMENTS FOR    */
 /*               17V0          NAME DEREFERENCES                           */
 /*                                                                         */
 /*05/29/02  DCP  32V0, 111382  BASE NOT LOADED FOR NAME REMOTE COMPARISON  */
 /*               17V0                                                      */
 /*                                                                         */
 /*11/13/01  TKN  32V0, 111388  REMOTE CHARACTER PARAMETER FAILS            */
 /*               17V0                                                      */
 /*                                                                         */
 /***************************************************************************/
 /*  $Z MAKES THE CODE GO ON ERRORS  */                                         00001000
 /* $HH A L / S   C O M P I L E R   --   P H A S E   2   --   I N T E R M E T   00001500
R I C S ,   I N C .   */                                                        00002000
 /*   LIMITING PHASE 2 SIZES AND LENGTHS   */                                   00002500
   DECLARE LABELSIZE BIT(16),                                                   00003000
      STACK_SIZE LITERALLY '100',        /* NUMBER OF INDIRECT STACK ENTRIES*/  00003500
      PROC#     LITERALLY '255',        /* NUMBER OF PROCS/FUNCS/TASKS/ETC. */  00004000
      CALL_LEVEL# LITERALLY '20',        /* MAX FUNC NESTING DEPTH          */  00004500
      ARG_STACK# LITERALLY '100',        /* MAX ARGUMENT NESTING DEPTH      */  00005000
      HASHSIZE LITERALLY '49',           /* SIZE FOR HASHING EXTERNAL NAMES */  00005500
      BIGNUMBER LITERALLY  '200000',     /* MAX BYTES OF COMMON STORAGE     */  00006000
      LASTEMP   LITERALLY '100',         /* MAX # OF ACTIVE TEMPORARIES     */  00006500
      STATNOLIMIT BIT(16);               /* MAX # OF STATEMENT NUMBERS      */  00007000
                                                                                00007500
                                                                                00008000
   DECLARE TRUE LITERALLY '1',                                                  00008500
      FALSE LITERALLY '0',                                                      00009000
      FOR   LITERALLY '';                                                       00009500
                                                                                00010000
   DECLARE BY_NAME_TRUE   LITERALLY '1',              /*CR13616*/
           BY_NAME_FALSE  LITERALLY '0',              /*CR13616*/
           FOR_NAME_TRUE  LITERALLY '1',              /*CR13616*/
           FOR_NAME_FALSE LITERALLY '0';              /*CR13616*/
                                                                                00010500
 /* PRIMARY CODE TABLES AND POINTERS */                                         00011000
   DECLARE       (OP1,OP2) BIT(16),                                             00012000
      (SUBCODE,OPCODE,CLASS,NUMOP,TAG1,TAG) BIT(16),                            00012500
      (TAG2,TAG3)(2) BIT(16),                                                   00013000
      (LEFTOP, RIGHTOP, RESULT, LASTRESULT) BIT(16),                            00013500
      TAGS BIT(16),                                                             00014000
      READCTR BIT(16),                                                          00014500
      SMRK_CTR BIT(16),                                                         00015000
      (CTR,RESET) BIT(16),                                                      00015500
      STACK_MAX BIT(16);                                                        00016000
   ARRAY         STACK_PTR(STACK_SIZE) BIT(16),                                 00016500
      COPT(STACK_SIZE) BIT(8);                                                  00017000
   DECLARE                                                                      00017500
      (STRUCT_START, STRUCT_LINK) BIT(16),                                      00018000
                                                                                00018500
 /*   OPERAND TYPES AFTER INITIALISE TIME ...  FLAG OF                          00019000
                   "8" INDICATES DOUBLE PRECISION                   */          00019500
      VECMAT    BIT(8) INITIAL (0),                                             00020000
      INTSCA    BIT(8) INITIAL (3),                                             00020500
      BITS      BIT(8) INITIAL (1),                                             00021000
      CHAR      BIT(8) INITIAL (2),                                             00021500
      MATRIX    BIT(8) INITIAL (3),                                             00022000
      VECTOR    BIT(8) INITIAL (4),                                             00022500
      SCALAR    BIT(8) INITIAL (5),                                             00023000
      DSCALAR   BIT(8) INITIAL(13),                                             00023500
      INTEGER   BIT(8) INITIAL (6),                                             00024000
      DINTEGER  BIT(8) INITIAL(14),                                             00024500
      APOINTER  BIT(8) INITIAL (7),                                                25000
      RPOINTER  BIT(8) INITIAL(19),                                                25100
      FULLBIT   BIT(8) INITIAL (9),                                             00025500
      BOOLEAN   BIT(8) INITIAL (1),                                             00026000
      EXTRABIT  BIT(8) INITIAL(15),                                             00026500
      CHARSUBBIT BIT(8) INITIAL(18),                                            00027000
      STRUCTURE BIT(8) INITIAL (16),                                            00027500
      EVENT     BIT(8) INITIAL (17),                                            00028000
      LOGICAL   BIT(8) INITIAL (20),                                            00028500
      RELATIONAL BIT(8) INITIAL (21),                                           00029000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SET UP INITIAL ENTRY TYPE */
      INITIAL_ENTRY BIT(16) INITIAL(22),
 ?/
      FULLWORD  LITERALLY 'DINTEGER',                                           00029500
 /*     HALFWORD  LITERALLY 'BITS', */                                          00030000
 /*     ONEBYTE LITERALLY 'CHAR', */                                            00030500
      WORDSIZE BIT(8) INITIAL(32),                                              00031000
      HALFWORDSIZE BIT(8) INITIAL(16),                                          00031500
      BITESIZE BIT(8) INITIAL(16),                                              00032000
      NAMETYPE BIT(8) INITIAL(6),                                               00033000
      NAMESTORE BIT(8) INITIAL ("40"),                                          00034000
                                                                                00034500
 /*  OPERAND FIELD QUALIFIERS   */                                              00035000
      SYM       BIT(8) INITIAL (1),                                             00035500
      INL       BIT(8) INITIAL (2),                                             00036000
      VAC       BIT(8) INITIAL (3),                                             00036500
      XPT       BIT(8) INITIAL (4),                                             00037000
      LIT       BIT(8) INITIAL (5),                                             00037500
      IMD       BIT(8) INITIAL (6),                                             00038000
      AIDX      BIT(8) INITIAL (28),   /* DR111307 */                           00038500
      CSIZ      BIT(8) INITIAL (8),                                             00039000
      ASIZ      BIT(8) INITIAL (9),                                             00039500
      OFFSET    BIT(8) INITIAL(10),                                             00040000
      WORK      BIT(8) INITIAL(31),                                             00040500
      AIDX2     BIT(8) INITIAL(30),                                             00041000
      SYM2      BIT(8) INITIAL(29),                                             00041500
      CLBL      BIT(8) INITIAL(15),                                             00042000
 /* FIXLIT    BIT(8) INITIAL(10), */                                            00042500
      CHARLIT   BIT(8) INITIAL (8),                                             00043000
      CSYM      BIT(8) INITIAL (7),                                             00044000
      ADCON     BIT(8) INITIAL(16),                                             00044500
      LOCREL    BIT(8) INITIAL(17),                                             00045000
      LBL       BIT(8) INITIAL(18),                                             00045500
      FLNO      BIT(8) INITIAL(19),                                             00046000
      STNO      BIT(8) INITIAL(20),                                             00046500
 /* SYSINT    BIT(8) INITIAL(21), */                                            00047000
      EXTSYM    BIT(8) INITIAL(22),                                             00047500
      SHCOUNT   BIT(8) INITIAL(23),                                             00048000
                                                                                00049000
 /*  OPERATION FIELD OR SUBFIELD CODES  */                                      00049500
      XMVPR     BIT(8) INITIAL   ("0C"),           /*  5-BIT OPCODES */         00050000
      XMTRA     BIT(8) INITIAL   ("09"),                                        00051000
      XMINV     BIT(8) INITIAL   ("0A"),                                        00051500
      XMDET     BIT(8) INITIAL   ("11"),                                        00052000
      XMEXP     BIT(8) INITIAL   ("19"),                                        00052500
      XMASN     BIT(8) INITIAL   ("15"),                                        00053000
      XPASN     BIT(8) INITIAL   ("18"),                                        00053500
      XSASN     BIT(8) INITIAL   ("14"),                                        00054000
      XVMIO     BIT(8) INITIAL   ("16"),                                        00054500
      XMIDN     BIT(8) INITIAL   ("13"),                                        00055000
      XCSIO     BIT(8) INITIAL   ("07"),                                        00055500
      XCSLD     BIT(8) INITIAL   ("09"),                                        00056000
      XCSST     BIT(8) INITIAL   ("0A"),                                        00056500
      XNOT      BIT(8) INITIAL   ("04"),                                        00057000
      XOR       BIT(8) INITIAL   ("03"),                                        00057500
      XXASN     BIT(8) INITIAL   ("01"),                                        00058000
      XADD      BIT(8) INITIAL   ("0B"),                                        00058500
      XDIV      BIT(8) INITIAL   ("0E"),                                        00059000
      XEXP      BIT(8) INITIAL   ("0F"),                                        00059500
      XPEX      BIT(8) INITIAL   ("12"),                                        00060000
      XEQU      BIT(8) INITIAL   ("06"),                                        00060500
      XTASN     BIT(8) INITIAL   ("4F"),                                           60600
      XSMRK     BIT(16) INITIAL ("0040"),      /* 16-BIT  OPERATORS */          00061000
      XEXTN     BIT(16) INITIAL ("0010"),                                       00061500
      XXREC     BIT(16) INITIAL ("0020"),                                       00062000
 /* XFBRA     BIT(16) INITIAL ("00A0"), */                                      00062500
      XBTRU     BIT(16) INITIAL ("7200"),                                       00063000
 /* XCFOR     BIT(16) INITIAL ("0120"), */                                      00063500
 /* XCTST     BIT(16) INITIAL ("0160"), */                                      00064000
 /* XBNEQ     BIT(16) INITIAL ("7250"), */                                      00064500
 /* XILT      BIT(16) INITIAL ("7CA0"), */                                      00065000
      XDLPE     BIT(16) INITIAL ("0180"),                                       00065500
 /* XSFST     BIT(16) INITIAL ("0450"), */                                      00066000
 /* XSFND     BIT(16) INITIAL ("0460"), */                                      00066500
      XSFAR     BIT(16) INITIAL ("0470"),                                       00067000
 /* XXXST     BIT(16) INITIAL ("0250"), */                                      00067500
 /* XXXND     BIT(16) INITIAL ("0260"), */                                      00068000
      XXXAR     BIT(16) INITIAL ("0270"),                                       00068500
      XREAD     BIT(16) INITIAL ("01F0"),                                       00069000
 /* XRDAL     BIT(16) INITIAL ("0200"), */                                      00069500
      XWRIT     BIT(16) INITIAL ("0210"),                                       00070000
      XFILE     BIT(16) INITIAL ("0220"),                                       00070500
      XIDEF     BIT(16) INITIAL ("0510"),                                       00071000
 /* XICLS     BIT(16) INITIAL ("0520"), */                                      00071500
      XIMRK     BIT(16) INITIAL ("0030"),                                       00072000
      XADLP     BIT(16) INITIAL ("0170"),                                          72100
      XVDLP     BIT(16) INITIAL ("0178"),                                          72200
      XVDLE     BIT(16) INITIAL ("0188");                                          72300
                                                                                00072500
 /* CODE OPTIMIZER BITS  */                                                     00073000
 /* XD        BIT(8)  INITIAL      (2), */                                      00073500
 /* XN        BIT(8)  INITIAL      (1); */                                      00074000
                                                                                00074500
 /* DECLARATIONS USED BY THE CODE GENERATORS  */                                00075000
   DECLARE                                                                      00075500
                                                                                00076000
      RRTYPE BIT(8) INITIAL (32),                                               00076500
      RXTYPE BIT(8) INITIAL (33),                                               00077000
      SSTYPE BIT(8) INITIAL (34),                                               00077500
      DELTA  BIT(8) INITIAL (35),                                               00078000
      ULBL   BIT(8) INITIAL (36),                                               00078500
 /* ILBL   BIT(8) INITIAL (37), */                                              00079000
      PLBL   BIT(8) INITIAL (48),                                               00079500
      CSECT  BIT(8) INITIAL (38),                                               00080000
      DATABLK BIT(8) INITIAL(39),                                               00080500
      DADDR  BIT(8) INITIAL (40),                                               00081000
      PADDR  BIT(8) INITIAL (41),                                               00081500
      RLD    BIT(8) INITIAL (43),                                               00082000
      STMTNO BIT(8) INITIAL (44),                                               00082500
      PDELTA BIT(8) INITIAL (45),                                               00083000
      CSTRING BIT(8) INITIAL(46),                                               00083500
      CODE_END BIT(8) INITIAL(47),                                              00084000
      DATA_LIST BIT(8) INITIAL(49),                                             00084500
      SRSTYPE BIT(8) INITIAL(50),                                               00085000
      CNOP   BIT(8) INITIAL (51),                                               00085500
      NOP    BIT(8) INITIAL (52),                                               00086000
      HADDR  BIT(8) INITIAL (53),                                               00086500
      PROLOG BIT(8) INITIAL (54),                                               00087000
      ZADDR  BIT(8) INITIAL (55),                                               00087500
      SMADDR BIT(8) INITIAL (56),                                               00088000
      STADDR BIT(8) INITIAL (57),                                                  88100
      BR_ARND BIT(8) INITIAL(58);                                               00088200
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ADD NEW INTERMEDIATE OPCODES */
   DECLARE
      SPSET  BIT(16) INITIAL(63),                                               00088020
      LPUSH  BIT(16) INITIAL(64),                                               00088040
      LPOP   BIT(16) INITIAL(65);                                               00088060
 ?/
 /* LADDR  BIT(8) INITIAL (42); */                                              00088500
                                                                                00089000
   DECLARE NRTEMP LITERALLY 'WORK'; /* FORM USED FOR RNR ON STACK -CR12432 */

   DECLARE                                                                      00089500
      A    BIT(8) INITIAL ("5A"),                                               00090000
 /*AD   BIT(8) INITIAL ("6A")*/                                                 00090500
 /*ADR  BIT(8) INITIAL ("2A")*/                                                 00091000
 /*AE   BIT(8) INITIAL ("7A")*/                                                 00091500
 /*AER  BIT(8) INITIAL ("3A")*/                                                 00092000
      AH   BIT(8) INITIAL ("4A"),                                               00092500
      AHI  BIT(8) INITIAL ("AA"),                                               00093000
      AR   BIT(8) INITIAL ("1A"),                                               00093500
 /*AST  BIT(8) INITIAL ("CA")*/                                                 00094000
      BAL  BIT(8) INITIAL ("45"),                                               00094500
      BALR BIT(8) INITIAL ("05"),                                               00095000
      BC   BIT(8) INITIAL ("47"),                                               00095500
      BCF  BIT(8) INITIAL ("87"),                                               00096000
      BCR  BIT(8) INITIAL ("07"),                                               00096500
      BCRE BIT(8) INITIAL ("0F"),                                               00097000
      BCT  BIT(8) INITIAL ("46"),                                               00097500
      BCTB BIT(8) INITIAL ("86"),                                               00098000
 /*BCTR BIT(8) INITIAL ("06")*/                                                 00098500
      BIX  BIT(8) INITIAL ("44"),                                               00099000
 /?B  /* CR11114 -- BFS/PASS INTERFACE */
      BVC  BIT(16) INITIAL ("42"),                                              00091500
 ?/
 /*C    BIT(8) INITIAL ("59")*/                                                 00099500
 /*CD   BIT(8) INITIAL ("69")*/                                                 00100000
 /*CDR  BIT(8) INITIAL ("29")*/                                                 00100500
 /*CE   BIT(8) INITIAL ("79")*/                                                 00101000
 /*CER  BIT(8) INITIAL ("39")*/                                                 00101500
      CH   BIT(8) INITIAL ("49"),                                               00102000
      CHI  BIT(8) INITIAL ("A9"),                                               00102500
 /*CIST BIT(8) INITIAL ("B9")*/                                                 00103000
 /*CR   BIT(8) INITIAL ("19")*/                                                 00103500
      CVFL BIT(8) INITIAL ("3F"),                                               00104000
      CVFX BIT(8) INITIAL ("1F"),                                               00104500
 /*D    BIT(8) INITIAL ("5D")*/                                                 00105000
 /*DD   BIT(8) INITIAL ("6D")*/                                                 00105500
 /*DDR  BIT(8) INITIAL ("2D")*/                                                 00106000
 /*DE   BIT(8) INITIAL ("7D")*/                                                 00106500
 /*DER  BIT(8) INITIAL ("3D")*/                                                 00107000
 /*DR   BIT(8) INITIAL ("1D")*/                                                 00107500
      IAL  BIT(8) INITIAL ("4F"),                                               00108000
      IHL  BIT(8) INITIAL ("43"),                                               00108500
      L    BIT(8) INITIAL ("58"),                                               00109000
      LA   BIT(8) INITIAL ("41"),                                               00109500
      LCR  BIT(8) INITIAL ("13"),                                               00110000
 /*LD   BIT(8) INITIAL ("68")*/                                                 00110500
 /*LE   BIT(8) INITIAL ("78")*/                                                 00111000
 /*LECR BIT(8) INITIAL ("33")*/                                                 00111500
      LER  BIT(8) INITIAL ("38"),                                               00112000
      LFLI BIT(8) INITIAL ("03"),                                               00112500
      LFXI BIT(8) INITIAL ("02"),                                               00113000
      LH   BIT(8) INITIAL ("48"),                                               00113500
      LHI  BIT(8) INITIAL ("A8"),                                               00114000
      LM   BIT(8) INITIAL ("98"),                                               00114500
      LR   BIT(8) INITIAL ("18"),                                               00115000
 /*M    BIT(8) INITIAL ("5C")*/                                                 00115500
 /*MD   BIT(8) INITIAL ("6C")*/                                                 00116000
 /*MDR  BIT(8) INITIAL ("2C")*/                                                 00116500
 /*ME   BIT(8) INITIAL ("7C")*/                                                 00117000
 /*MER  BIT(8) INITIAL ("3C")*/                                                 00117500
      MH   BIT(8) INITIAL ("4C"),                                               00118000
      MHI  BIT(8) INITIAL ("AC"),                                               00118500
      MIH  BIT(8) INITIAL ("4E"),                                               00119000
      MR   BIT(8) INITIAL ("1C"),                                               00119500
      MSTH BIT(8) INITIAL ("BA"),                                               00120000
      MVH  BIT(8) INITIAL ("0E"),                                               00120500
 /*MVS  BIT(8) INITIAL ("7E")*/                                                 00121000
 /*N    BIT(8) INITIAL ("54")*/                                                 00121500
      NHI  BIT(8) INITIAL ("A4"),                                               00122000
      NIST BIT(8) INITIAL ("B4"),                                               00122500
   NR   BIT(8) INITIAL ("14"),  /* CR12432 - USED IN NAME COMPARE */
 /*NST  BIT(8) INITIAL ("C4")*/                                                 00123500
 /*O    BIT(8) INITIAL ("56")*/                                                 00124000
   OHI  BIT(8) INITIAL ("A6"),  /*#DNAME - THIS NOW USED FOR DR103750 */        00124500
 /*OR   BIT(8) INITIAL ("16")*/                                                 00125000
 /*OST  BIT(8) INITIAL ("C6")*/                                                 00125500
 /*S    BIT(8) INITIAL ("5B")*/                                                 00126000
      SB   BIT(8) INITIAL ("B6"),                                               00126500
      SCAL BIT(8) INITIAL ("4D"),                                               00127000
 /*SD   BIT(8) INITIAL ("6B")*/                                                 00127500
      SDR  BIT(8) INITIAL ("2B"),                                               00128000
 /*SE   BIT(8) INITIAL ("7B")*/                                                 00128500
      SER  BIT(8) INITIAL ("3B"),                                               00129000
 /*SH   BIT(8) INITIAL ("4B")*/                                                 00129500
      SHW  BIT(8) INITIAL ("96"),                                               00130000
      SLDL BIT(8) INITIAL ("8D"),                                               00130500
      SLL  BIT(8) INITIAL ("89"),                                               00131000
      SPM  BIT(8) INITIAL ("04"),                                               00131500
 /*SR   BIT(8) INITIAL ("1B")*/                                                 00132000
      SRA  BIT(8) INITIAL ("8A"),                                               00132500
      SRDA BIT(8) INITIAL ("8E"),                                               00133000
 /*SRDL BIT(8) INITIAL ("8C")*/                                                 00133500
      SRET BIT(8) INITIAL ("0D"),                                               00134000
      SRL  BIT(8) INITIAL ("88"),                                               00134500
 /*---------------- DR106968 -----------------------------*/
 /* NEW INSTRUCTION USED IN YCON_TO_ZCON: SRR.            */
      SRR  BIT(8) INITIAL ("CD"),
 /* ADDED 1 TO OPMAX CONSTANT FOR THE NEW SRR INSTRUCTION */
 /* ADDED AN ENTRY ON THE END OF EACH OF THESE ARRAYS:    */
 /*    OPERATOR   :  0                                    */
 /*    OPCC       :  0                                    */
 /*    OPER       :  28                                   */
 /*    OPNAMES    :  SRR                                  */
 /*    AP101INST  :  "F003"                               */
 /*-------------------------------------------------------*/
 /*SST  BIT(8) INITIAL ("CB")*/                                                 00135000
      ST   BIT(8) INITIAL ("50"),                                               00135500
      STD  BIT(8) INITIAL ("60"),  /*DR111382*/                                 00136000
      STE  BIT(8) INITIAL ("70"),  /*DR111382*/                                 00136500
      STH  BIT(8) INITIAL ("40"),                                               00137000
      STM  BIT(8) INITIAL ("90"),                                               00137500
      SVC  BIT(8) INITIAL ("9A"),                                               00138000
      TB   BIT(8) INITIAL ("B1"),                                               00138500
      TD   BIT(8) INITIAL ("9B"),                                               00139000
      TH   BIT(8) INITIAL ("91"),                                               00139500
      TRB  BIT(8) INITIAL ("A1"),                                               00140000
      TS   BIT(8) INITIAL ("93"),                                               00140500
 /*TSB  BIT(8) INITIAL ("B3")*/                                                 00141000
 /*X    BIT(8) INITIAL ("57")*/                                                 00141500
 /*XDR  BIT(8) INITIAL ("27")*/                                                 00142000
 /*XER  BIT(8) INITIAL ("37")*/                                                 00142500
 /*XHI  BIT(8) INITIAL ("A7")*/                                                 00143000
 /*XIST BIT(8) INITIAL ("B7")*/                                                 00143500
      XR   BIT(8) INITIAL ("17"),                                               00144000
 /*XST  BIT(8) INITIAL ("C7")*/                                                 00144500
 /*ZB   BIT(8) INITIAL ("BE")*/                                                 00145000
      ZH   BIT(8) INITIAL ("9E"),                                               00145500
/*---------------------- #DDSE -----------------------*/                        03410000
/* NEW DSE MANIPULATING INSTRUCTION LDM.              */                        03420000
      LDM  BIT(8) INITIAL ("CC"),                                               03430000
/* ADDED 1 TO OPMAX CONSTANT FOR THE NEW LDM INSTRUCTION.     */                03440000
/* ADDED AN ENTRY ON THE END OF EACH OF THESE ARRAYS:         */                03450000
/*    OPERATOR   :  0      */                                                   03460000
/*    OPCC       :  0      */                                                   03470000
/*    OPER       :  24     */                                                   03480000
/*    OPNAMES    :  LDM    */                                                   03490000
/*    AP101INST  :  "68F8" */                                                   03500000
/*----------------------------------------------------*/                        03510000
      ZRB  BIT(8) INITIAL ("AE"); /* #DMVH: THIS NOW USED */                    00146000
   ARRAY OPMAX LITERALLY '205', /*#DDSE + DR106968*/                            00146500
      OPERATOR(OPMAX) BIT(1) INITIAL( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 00147000
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   00147500
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   00148000
      0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0,   00148500
      1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,   00149000
      0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,   00149500
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   00150000
      0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,   00150500
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0),  00151000
      OPCC(OPMAX) BIT(2) INITIAL( 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2,  00151500
      0, 0, 0, 0, 1, 3, 0, 3, 3, 1, 2, 1, 1, 2, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0,   00152000
      1, 0, 2, 1, 1, 2, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 2, 1, 1, 2, 2, 0,   00152500
      1, 0, 2, 0, 2, 2, 2, 2, 0, 1, 2, 1, 1, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3,   00153000
      3, 1, 2, 1, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 1, 2, 2, 0,   00153500
      0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 1, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 2,   00154000
      0, 2, 2, 2, 0, 2, 2, 2, 0, 0, 1, 0, 1, 0, 0, 0, 0, 2, 0, 2, 2, 0, 0, 0,   00154500
      0, 0, 3, 0, 0, 3, 0, 3, 3, 2, 2, 1, 0, 2, 0, 3, 0, 0, 1, 0, 1, 1, 0, 1,   00155000
      1, 0, 2, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 2, 2, 0, 0, 2, 2, 0, 0),     00155500
      OPER(OPMAX) BIT(8) INITIAL( 0, 0, 80, 76, 120, 16, 28, 20, 0, 0, 0, 0, 0, 00156000
      128, 100, 24, 0, 0, 0, 64, 104, 0, 108, 140, 84, 40, 12, 124, 96, 60, 0,  00156500
      48, 0, 0, 0, 0, 0, 0, 0, 132, 0, 32, 4, 112, 88, 52, 0, 0, 0, 0, 0, 68,   00157000
 /?P  /* CR11114 -- BFS/PASS INTERFACE */
      0, 0, 0, 136, 72, 36, 8, 116, 92, 56, 0, 44, 156, 76, 0, 68, 32, 20, 28,  00157500
      24, 88, 48, 16, 140, 104, 128, 108, 64, 144, 0, 0, 0, 116, 0, 120, 160,   00158000
      72, 36, 4, 124, 92, 52, 0, 0, 148, 0, 0, 0, 0, 0, 0, 0, 80, 40, 8, 132,   00158500
      96, 56, 0, 0, 152, 0, 0, 0, 0, 0, 0, 0, 84, 44, 12, 136, 100, 60, 112,    00159000
      0, 0, 0, 0, 0, 0, 0, 12, 8, 80, 64, 68, 0, 76, 60, 72, 0, 84, 100, 0,     00159500
      108, 0, 0, 56, 0, 28, 0, 88, 96, 0, 0, 128, 0, 0, 104, 0, 0, 40, 0, 48,   00160000
      116, 24, 16, 4, 0, 32, 0, 132, 0, 0, 92, 0, 112, 44, 0, 52, 120, 0, 20,   00160500
      36, 0, 0, 0, 124, 0, 0, 0, 0, 0, 8, 0, 12, 20, 0, 0, 4, 16, 24, 28),      00161000
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE */
      0, 0, 0, 136, 72, 36, 8, 116, 92, 56, 0, 44, 160, 80, 36, 72, 32  , 20,
      28, 24, 92, 52, 16, 144, 108, 132, 112, 68, 148, 0, 0, 0, 120, 0  , 124,
      164, 76, 40, 4, 128, 96, 56, 0, 0, 152, 0, 0, 0, 0, 0, 0, 0, 84,   44, 8,
      136, 100, 60, 0, 0, 156, 0, 0, 0, 0, 0, 0, 0, 88, 48, 12, 140, 104, 64,
      116, 0, 0, 0, 16, 0, 0, 0, 12, 8, 84, 68, 72, 0, 80, 64, 76, 0,   88, 104,
      0, 112, 0, 0, 60, 0, 32, 0, 92, 100, 0, 0, 132, 0, 0, 108, 0, 0,   44, 0,
      52, 120, 28, 20, 4, 0, 36, 0, 136, 0, 0, 96, 0, 116, 48, 0, 56,   124, 0,
      24, 40, 0, 0, 0, 128, 0, 0, 0, 0, 0, 8, 0, 12, 20, 0, 0, 4,16,24, 28),
 ?/
      BCB_COUNT BIT(16),               /*CR12940*/
      OPCOUNT(OPMAX) BIT(16);                                                   00161500
   DECLARE OPNAMES(3) CHARACTER INITIAL(                                        00162000
'*   AEDRAER AR  BALRBCR BCREBCTRCEDRCER CR  CVFLCVFXDEDRDER DR  LACRLECRLER LFL00162500
ILFXILR  MEDRMER MR  MVH NR  OR  SEDRSER SPM SR  SRETSEDRSER XR  ',             00163000

 /?P /* CR11114 -- BFS/PASS INTERFACE; BVC DIFFERENCE IN BFS */
'*   A   AED AE  AH  BAL BC  BCT BIX C   CED CE  CH  D   DED DE  IAL IHL L   LA 00163500
 LED LE  LH  M   MED ME  MH  MIH MVS N   O   S   SCALSED SE  SH  ST  STEDSTE STH00164000
 X   ',                                                                         00164500
  /* CR12940 - IN THE FOLLOWING LINE CHANGE BC TO BCF */
'*   AHI BCF BCTBCHI CISTLHI LM  MHI MSTHNHI NISTOHI SB  SHW SLDLSLL SRA SRDASRD00165000
LSRL STM SVC TB  TD  TH  TRB TS  TSB XHI XISTZB  ZH  ZRB ',                     00165500
 ?/

 /?B /* CR11114 -- BFS/PASS INTERFACE; BVC DIFFERENCE IN BFS */
'*   A   AED AE  AH  BAL BC  BCT BIX BVC C   CED CE  CH  D   DED DE  IAL IHL L
 LA  LED LE  LH  M   MED ME  MH  MIH MVS N   O   S   SCALSED SE  SH  ST  STEDSTE
 STH X   ',
  /* CR12940 - IN THE FOLLOWING LINE CHANGE BC TO BCF AND BVC TO BVCF */
'*   AHI BCF BCTBBVCFCHI CISTLHI LM  MHI MSTHNHI NISTOHI SB  SHW SLDLSLL SRA SRD
ASRDLSRL STM SVC TB  TD  TH  TRB TS  TSB XHI XISTZB  ZH  ZRB ',
 ?/
      '*   AST NST OST SST XST LDM SRR ');                                      00166000
                                                                                00166500
   ARRAY AP101INST(OPMAX) BIT(16) INITIAL (      0,      0, "B8E0", "88E0",     00167000
      "C8E8", "E0E0", "D0E0", "C0E0",      0,      0,      0,      0,      0,   00167500
      "90E8", "68E8", "C0E8",      0,      0,      0, "E8E8", "20E0",      0,   00168000
      "28E0", "70E0", "18E0", "10E0", "00E0", "08E0", "40E0", "48E0",      0,   00168500
      "38E0",      0,      0,      0,      0,      0,      0,      0, "58E8",   00169000
      0, "48E8", "50E8", "58E8", "30E8", "10E8",      0,      0,      0,          169500
      0,      0, "78E8",      0,      0,      0, "58E0", "78E0", "48E8",        00170000
 /?P  /* CR11114 -- BFS/PASS INTERFACE */
      "50E0", "58E0", "60E0", "68E0",      0, "38E8", "B800", "E800",      0,   00170500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE */
      "50E0", "58E0", "60E0", "68E0",      0, "38E8", "B800", "E800",   "C8F0",
 ?/
      "80F8", "D8F0", "E0F0", "D0F0", "C0F0", "9800", "9000", "8000", "8800",   00171000
      "A800", "D0F8", "98F8", "E0FB", "3000",      0,      0,      0, "2000",   00171500
      0, "2800", "7000", "1800", "1000",      0, "0800", "4000", "4800",        00172000
      0,      0, "38F8",      0,      0,      0,      0,      0,      0,        00172500
      0, "78F8", "48F8", "50F8", "58F8", "30F8", "10F8",      0,      0,          173000
      "3800",      0,      0,      0,      0,      0,      0,      0, "7800",   00173500
      "48F8", "5000", "5800", "6000", "6800", "60F8",      0,      0,      0,   00174000
 /?P  /* CR11114 -- BFS/PASS INTERFACE */
      0,      0,      0,      0, "D803", "D802", "F002", "F000", "F001",        00174500
 ?/
 /?B  /* CR11114 -- BFS/PASS INTERFACE */
      "D803",      0,      0,      0, "D803", "D802", "F002", "F000",   "F001",
 ?/
      0, "F802", "F800", "F801",      0, "C8F8", "A300",      0, "B8F8",        00175000
      0,      0, "A200",      0, "CCF8",      0, "C9F8", "A000",      0,        00175500
      0, "A100",      0,      0, "B3E0",      0,      0, "B6E0",      0,        00176000
      "B2E0", "B4E0", "E8F3", "B5E0", "B0E0",      0, "B7E0",      0, "B1E0",   00176500
      0,      0, "B300",      0, "B700", "B600",      0, "B200", "B400",        00177000
      0, "B500", "B000",      0,      0,      0, "B100",      0,      0,        00177500
      0,      0,      0, "20F8",      0, "28F8", "70F8",      0,      0,        00178000
      "00F8", "08F8", "68F8", "F003");                                          00178500
   DECLARE INDIRECTION(3) CHARACTER INITIAL (' ', '@', '#', '@#');              00179500
   DECLARE CCREG BIT(16);                                                       00180000
                                                                                00180500
 /* DECLARATIONS TO DESCRIBE REGISTER CONTENTS  */                              00181000
   DECLARE REG_NUM LITERALLY '15',                                              00181500
      REG_NUM_2 LITERALLY '63', ENV_NUM LITERALLY '2',                            181600
      ENV_PTR BIT(16) INITIAL(ENV_NUM),                                           181700
      ENV_BASE(ENV_NUM) BIT(16) INITIAL(REG_NUM+1, 2*(REG_NUM+1),               00181800
      3*(REG_NUM+1)),                                                           00181810
      ENV_LBL(ENV_NUM) BIT(16),                                                   181900
      BASE_NUM LITERALLY '79',                                                  00182000
      USAGE(REG_NUM_2) BIT(16);                                                 00182100
   ARRAY                                                                        00182200
/?B   /* SSCR 8348 -- BASE REG ALLOCATION (ADCON) */

      R_BASE(BASE_NUM)      FIXED,
      R_SECTION(BASE_NUM)   BIT(8),
      R_BASE_USED(BASE_NUM) BIT(1),
?/
      USAGE_LINE(REG_NUM) BIT(16),                                              00183500
      R_VAR(REG_NUM_2) BIT(16),                                                   184000
      R_INX(REG_NUM_2) BIT(16),                                                   184500
      R_INX_SHIFT(REG_NUM_2) BIT(8),                                              185000
      R_INX_CON(REG_NUM_2) FIXED,                                                 185500
      (R_CON, R_XCON)(REG_NUM_2) FIXED,                                           186000
      R_CONTENTS(REG_NUM_2) BIT(8),                                               186500
      R_TYPE(REG_NUM_2) BIT(8),                                                   187000
      DOUBLE_TYPE(REG_NUM_2) BIT(8),  /*-------- DR103754 --------*/              187000
      (R_VAR2, R_MULT)(REG_NUM_2) BIT(16),                                        188000
      R_PARM(REG_NUM) BIT(16);                                                  00188500

/?P   /* SSCR 8348 -- BASE REG ALLOCATION (ADCON) */

 /* IN THE RECORD BASE_REGS, FIELD 'ADDR' IS SET IN                             00188508
     'GENERATE_CONSTANTS' AND USED IN 'OBJECT_GENERATOR'.  FIELDS               00188512
     'BASE', 'BASE_USED', AND 'SECTION' ARE SET IN 'INITIALIZE' AND             00188516
     'GENERATE' AND USED IN 'GENERATE_CONSTANTS' */                             00188520
   BASED BASE_REGS RECORD DYNAMIC:                                              00188524
         OFFSET     FIXED,   /* OFFSET IN CSECT TO WHICH BASE REG POINTS */     00188528
         BASE_USED  BIT(16), /* NUMBER OF TIMES THE BASE REG IS LOADED */       00188532
         ADDR       BIT(16), /* ADDRESS WHERE ADCON IS EMITTED */               00188536
         SECTION    BIT(8),  /* CSECT THAT BASE REG POINTS TO */                00188544
         SORT       BIT(16), /* USED FOR SORTING REGS BY NUMBER OF LOADS */     00188548
      END;                                                                      00188552
   DECLARE R_BASE(1)      LITERALLY    'BASE_REGS(%1%).OFFSET',                 00188556
      R_SECTION(1)   LITERALLY    'BASE_REGS(%1%).SECTION',                     00188560
      R_BASE_USED(1) LITERALLY    'BASE_REGS(%1%).BASE_USED',                   00188564
      R_ADDR(1)      LITERALLY    'BASE_REGS(%1%).ADDR',                        00188568
      R_SORT(1)      LITERALLY    'BASE_REGS(%1%).SORT';                        00188576
?/                                                                              00188580
   ARRAY                                                            /*CR13335*/ 00188600
      INDEXING(REG_NUM) BIT(1) INITIAL (                                        00189000
      0,1,1,1,1,1,1,1),                                                         00189500
                                                                                00190000
      RCLASS_START(6) BIT(16) INITIAL(0,4,12),                                  00190500
      REGISTERS(63) BIT(16) INITIAL (                                           00191000
      8, 10, 12, 14, 8, 10, 12, 14, 11, 13, 15, 9),                             00191500
      RM      FIXED   INITIAL ("7"),                                            00192000
      LINKREG BIT(8) INITIAL (4),                                               00192500
      PROGBASE BIT(8) INITIAL (1),                                              00193000
      PRELBASE BIT(8) INITIAL(9),                                               00193100
      TEMPBASE BIT(8) INITIAL (0),                                              00193500
      PROCBASE BIT(8) INITIAL (3),                                              00194000
      REMOTE_BASE BIT(8) INITIAL (9),                                           00194500
      NEXTDECLREG BIT(16),                                                      00195000
      TARGET_REGISTER BIT(16) INITIAL (-1),                                     00196000
      NOT_THIS_REGISTER BIT(16) INITIAL(-1),                                      196100
      NOT_THIS_REGISTER2 BIT(16) INITIAL(-1),  /*DR111358*/                       196100
      TARGET_R BIT(16) INITIAL(-1),                                             00196500
      SYSARG0(3) BIT(8) INITIAL (2, 1, 2, 1),                                   00197000
      SYSARG1(3) BIT(8) INITIAL (2, 2, 4, 2),                                   00197500
      SYSARG2(3) BIT(8) INITIAL (4, 3, 7, 3),                                   00198000
      FR0     BIT(8) INITIAL (8),                                               00198500
 /* FR1     BIT(8) INITIAL (9),*/                                               00199000
      FR2     BIT(8) INITIAL(10),                                               00199500
      FR4     BIT(8) INITIAL(12),                                               00200000
 /* FR6     BIT(8) INITIAL(14),*/                                               00200500
      FR7     BIT(8) INITIAL(15),                                               00201000
      R0      BIT(8) INITIAL (0),                                               00201500
      R1      BIT(8) INITIAL (1),                                               00202000
      R3      BIT(8) INITIAL (3),                                               00202100
      FIXARG1 BIT(8) INITIAL (5),                                               00202500
      FIXARG2 BIT(8) INITIAL (6),                                               00203000
      FIXARG3 BIT(8) INITIAL (7),                                               00203500
      PTRARG1 BIT(8) INITIAL (2),                                               00204000
                                                                                00204500
      ALWAYS  BIT(8) INITIAL (7),                                               00205000
      EQ      BIT(8) INITIAL (4),                                               00205500
      NEQ     BIT(8) INITIAL (3),                                               00206000
      GT      BIT(8) INITIAL (1),                                               00206500
 /* LT      BIT(8) INITIAL (2),*/                                               00207000
      GQ      BIT(8) INITIAL (5),                                               00207500
      LQ      BIT(8) INITIAL (6),                                               00208000
      EZ      BIT(8) INITIAL (4),                                               00208500
                                                                                00209000
 /* ERROR_POINT           BIT(8) INITIAL (1),*/                                 00209500
      REGISTER_SAVE_AREA(1) BIT(8) INITIAL (2, 0),                              00210000
      STACK_LINK(1) BIT(8) INITIAL (2, 0), /* 2 * TEMPBASE + R_S_A */           00210500
      STACK_FREEPOINT(1)    BIT(8) INITIAL (18, 16),                            00211000
      NEW_STACK_LOC(1)      BIT(8) INITIAL (0, 3),                              00211500
      NEW_LOCAL_BASE(1)     BIT(8) INITIAL (9, 1),                              00212000
      NEW_GLOBAL_BASE(1)    BIT(8) INITIAL (5, 2),                              00212500
                                                                                00213000
      FLOATING_ACC LITERALLY '1',                                               00213500
      DOUBLE_FACC  LITERALLY '0',                                               00214000
      FIXED_ACC    LITERALLY '3',                                               00214500
      DOUBLE_ACC   LITERALLY '2',                                               00215000
      INDEX_REG    LITERALLY '4',                                               00215500
      ODD_REG      LITERALLY '5';                                               00216000
                                                                                00239500
 /* CODE RETRIEVAL DECLARATIONS */                                              00240000
   DECLARE CODEFILE BIT(8) INITIAL (4),                                           240500
      CURCBLK BIT(8);                                                           00241000
                                                                                00241500
 /* CHARACTER AND LABEL BUFFERS AND POINTERS */                                 00242000
   DECLARE                                                                      00242500
      INSMOD FIXED,                                                             00243000
      AREASAVE FIXED,                                                           00243500
      (CHARSTRING,MESSAGE,INFO) CHARACTER,                                      00244000
      (FIRSTLABEL,SECONDLABEL) BIT(16),                                         00244500
      LHSPTR BIT(16);                                                           00245000
   BASED LAB_LOC RECORD DYNAMIC:                                                00245500
         LOCAT       FIXED,                                                     00245600
         LOCAT_ST#            BIT(16),                             /*CR12713*/  00245700
         LINK_LOCATION        BIT(16),                                          00245700
      END;                                                                      00245800
   BASED STMTNUM RECORD DYNAMIC:                                                00245900
         ARRAY_LABEL        BIT(16),                                            00246000
      END;                                                                      00246100
                                                                                00248000
 /* CONSTANT VALUES OR DESCRIPTORS FOR CODE GENERATION  */                      00248500
   DECLARE  CONST_LIM LITERALLY '2000',                                         00249000
      CONSTANT_CTR BIT(16),                                                     00249500
      CONSTANT_REFS(7) BIT(16), (MAX_SRS_DISP, SRS_REFS)(1) BIT(16),            00249600
      CONSTANT_HEAD(7) BIT(16);                                                   251000
   ARRAY    CONSTANTS(CONST_LIM) FIXED,                                         00252000
      CONSTANT_PTR(CONST_LIM) BIT(16);                                          00252500
                                                                                00253000
   DECLARE CURRENT_ESDID FIXED;                                                 00253010
   DECLARE NO_SRS BIT(1) INITIAL(0);                                            00253030
   DECLARE   DOCOPY(5) BIT(16),                                                 00253500
      STACK# BIT(16),                                                           00254000
      (VDLP_DETECTED, VDLP_ACTIVE, VDLP_IN_EFFECT) BIT(1),                      00254100
      STRI_ACTIVE BIT(1),                                                       00254500
      ARRAY_FLAG BIT(1);                                                        00255000
                                                                                00255500
 /* DO LOOP DESCRIPTOR DECLARATIONS  */                                         00256000
   DECLARE DOSIZE LITERALLY '25', DOLEVEL BIT(16), /*CR12940*/                  00256500
      DOTYPE(DOSIZE) BIT(8);                                                    00257000
                                                                                00257500
   DECLARE                                                                      00258000
      (CODE_LISTING_REQUESTED, DECK_REQUESTED, TRACING, NO_VM_OPT) BIT(1),      00258500
      (MARKER_ISSUED, HALMAT_REQUESTED, ASSEMBLER_CODE, BINARY_CODE,            00259000
      DIAGNOSTICS, REGISTER_TRACE, SUBSCRIPT_TRACE) BIT(1),                     00259500
      HIGHOPT BIT(1),          /*DR103787*/                                     00260000
      SELFNAMELOC BIT(16);                                                      00260000
                                                                                00260500
 /*  ERROR CLASSES DECLARATION */                                               00261000
                                                                                00261010
   DECLARE  CLASS_B  BIT(8) INITIAL(4),                                         00261020
      CLASS_BI BIT(8) INITIAL(6),                                               00261030
      CLASS_BS BIT(8) INITIAL(8),                                               00261040
      CLASS_BX BIT(8) INITIAL(10),                                              00261050
      CLASS_D  BIT(8) INITIAL(12),                                              00261060
      CLASS_DI BIT(8) INITIAL(17),                                              00261070
      CLASS_DQ BIT(8) INITIAL(20),                                              00261080
 /*CLASS_DS BIT(8) INITIAL(21),*/                                               00261090
      CLASS_DU BIT(8) INITIAL(23),                                              00261100
      CLASS_E  BIT(8) INITIAL(24),                                              00261110
      CLASS_EA BIT(8) INITIAL(25),                                              00261120
      CLASS_F  BIT(8) INITIAL(34),                                              00261130
      CLASS_FD BIT(8) INITIAL(35),                                              00261140
      CLASS_FN BIT(8) INITIAL(36),                                              00261150
      CLASS_FT BIT(8) INITIAL(38),                                              00261160
 /*CLASS_GC BIT(8) INITIAL(41),*/                                               00261170
      CLASS_PE BIT(8) INITIAL(63),                                              00261180
      CLASS_PF BIT(8) INITIAL(64),                                              00261190
      CLASS_PR BIT(8) INITIAL(68),
      CLASS_QD BIT(8) INITIAL(74),                                              00261200
 /*CLASS_RT BIT(8) INITIAL(79),*/                                               00261210
      CLASS_SR BIT(8) INITIAL(86),                                              00261220
      CLASS_XQ BIT(8) INITIAL(107),                                             00261230
      CLASS_XR BIT(8) INITIAL(108), /*#DFLAG - ADD CLASS, RENUM REST */
      CLASS_XS BIT(8) INITIAL(109), /*CR11053*/                                 00261230
 /*CLASS_Z  BIT(8) INITIAL(112),*/                                              00261240
      CLASS_ZB BIT(8) INITIAL(113),                                             00261250
      CLASS_ZC BIT(8) INITIAL(114),                                             00261260
 /*CLASS_ZI BIT(8) INITIAL(115),*/                                              00261270
 /*CLASS_ZN BIT(8) INITIAL(116),*/                                              00261280
      CLASS_ZO BIT(8) INITIAL(117),                                             00261290
      CLASS_ZP BIT(8) INITIAL(118),                                             00261300
 /*CLASS_ZR BIT(8) INITIAL(119),*/                                              00261310
      CLASS_ZS BIT(8) INITIAL(120),                                             00261320
      CLASS_YA BIT(8) INITIAL(121), /*CR13211*/
      CLASS_YC BIT(8) INITIAL(122), /*CR13211*/
      CLASS_YE BIT(8) INITIAL(123), /*CR13211*/
      CLASS_YF BIT(8) INITIAL(124); /*CR12214, CR13211*/                        00261320
   DECLARE ERROR_CLASSES CHARACTER INITIAL('A AAAVB BBBIBNBSBTBXC D DADCDDDFDIDL00261330
DNDQDSDTDUE EAEBECEDELEMENEOEVF FDFNFSFTG GBGCGEGLGVI ILIRISL LBLCLFLSM MCMEMOMS00261340
P PAPCPDPEPFPLPMPPPRPSPTPUQ QAQDQSQXR RERTRUS SASCSPSQSRSSSTSVT TCTDU UIUPUTV VA00261350
VCVEVFX XAXDXIXMXQXRXSXUXVZ ZBZCZIZNZOZPZRZSYAYCYEYF');/*CR12214, CR13211*/     00261360

 /*   SUBPROGRAM CONTROL DECLARATIONS  */                                       00271500
   ARRAY                                                                        00272000
      CALL#(PROC#) BIT(8),                                                      00272500
      NARGS(PROC#) BIT(16),                                                     00273000
      PROC_LEVEL(PROC#) BIT(16),                                                00273500
      PROC_LINK(PROC#) BIT(16),                                                 00274000
      LASTLABEL(PROC#) BIT(16),                                                 00274500
      MAXTEMP(PROC#) FIXED,                                                     00275000
      ORIGIN(PROC#) FIXED,                                                      00275500
 /?P  /* CR11114 -- BFS/PASS INTERFACE */
      LOCCTR(PROC#) FIXED,                                                      00276000
      STACKSPACE(PROC#) FIXED,                                                  00277000
      MAXERR(PROC#) BIT(16),                                                    00278000
 ?/
      CSECT_BOUND(PROC#) FIXED,                                                 00276010
      LASTBASE(PROC#) BIT(16),                                                  00276500
 /?B  /* CR11114 -- BFS/PASS INTERFACE */
        LOCCTR(PROC#) FIXED,                /*DR111367*/
        STACKSPACE(PROC#) BIT(16),
        MAXERR(PROC#)  BIT(1),
 ?/
      (WORKSEG, ERRSEG)(PROC#) FIXED,                                           00277500
      NOT_LEAF(PROC#) BIT(1),                                                   00278500
      OVERFLOW_LEVEL(PROC#) BIT(8),                                             00278600
      REMOTE_LEVEL(PROC#) BIT(8),                                               00279000
      ERRALLGRP(PROC#) BIT(16),                                                 00279500
      INDEXNEST(PROC#) BIT(16);                                                 00280000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; SVC */
   ARRAY
        FIRST_TIME(PROC#) BIT(1),
        LAST_SVCI(PROC#) BIT(16),
        LAST_LOGICAL_STMT(PROC#) BIT(16),
        PUSHED_LOCCTR(PROC#) FIXED;
 ?/
   DECLARE (CALL_LEVEL,ARG_STACK_PTR) BIT(16),                                  00280500
      ARG# BIT(16),                                                             00282500
      SF_RANGE_PTR BIT(16),                                                     00283000
      SF_DISP BIT(16),                                                          00283500
      PROCPOINT BIT(16),                                                        00284000
      PROCLIMIT BIT(16),                                                        00284500
      PROGPOINT BIT(16),                                                        00285000
      TASK# BIT(16),                                                            00285500
      TASKPOINT BIT(16),                                                        00286000
      ENTRYPOINT BIT(16),                                                       00287000
      XPROGLINK BIT(16),                                                        00287500
      STACKPOINT BIT(16),                                                       00286500
      PROGCODE FIXED,                                                           00288000
      PROGDATA(1) FIXED,                                                        00288500
      FSIMBASE BIT(16),                                                         00289000
      DATALIMIT BIT(16),                                                        00290000
      (FIRSTREMOTE,LASTREMOTE) BIT(16),                                         00290500
      PCEBASE BIT(16),                                                          00291500
      EXCLBASE BIT(16),                                                         00292000
      EXCLUSIVE# BIT(16),
      SYMBREAK BIT(16),                                                         00292500
      NARGINDEX BIT(16),                                                        00293500
      SDELTA BIT(16),                                                           00293510
      (ARGPOINT, ARGTYPE, ARGNO) BIT(16),                                       00294000
      R_PARM# BIT(16) INITIAL(-1),                                              00294500
      INLINE_RESULT BIT(16),                                                    00295000
      CMPUNIT_ID BIT(16),                                                       00295500
      STACK_DUMP BIT(1), LAST_STACK_HEADER BIT(16),                             00295600
      DSR BIT(16),                                                              00296000
      DUMMY     CHARACTER,                                                      00296500
      (PMINDEX, UPDATING) BIT(16),                                              00297000
      LIB_POINTER BIT(16),                                                      00297500
      TEMPLATE_CLASS BIT(16) INITIAL(7),                                        00297510
      UPDATE_FLAGS LITERALLY 'SYT_CONST(UPDATING)',                             00298000
      DOUBLEFLAG BIT(1);                                                        00299000
                                                                                00299500
 /* USEFUL CHARACTER LITERALS */                                                00300000
   DECLARE  COLON          CHARACTER INITIAL (':'),                             00300500
      COMMA          CHARACTER INITIAL (','),                                   00301000
      BLANK          CHARACTER INITIAL (' '),                                   00301500
      LEFTBRACKET    CHARACTER INITIAL ('('),                                   00302000
      RIGHTBRACKET   CHARACTER INITIAL (')'),                                   00302500
      PLUS           CHARACTER INITIAL ('+'),                                   00303000
      QUOTE          CHARACTER INITIAL (''''),                                  00303500
      HEXCODES       CHARACTER INITIAL ('0123456789ABCDEF'),                    00304000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; #Z OBJECT MODULE */
      POUND_Z        CHARACTER INITIAL ('#Z'),
 ?/
      X2             CHARACTER INITIAL ('  '),                                  00304500
      X3             CHARACTER INITIAL ('   '),                                 00305000
      X4             CHARACTER INITIAL ('    '),                                00305500
      X72            CHARACTER INITIAL                                          00306000
   ('                                                                        ');00306500
                                                                                00307000
 /*  SYMBOL TABLE DEPENDENT DECLARATIONS  */                                    00307500
   DECLARE SYT_SIZE BIT(16),                                                    00308000
      ERRLIM LITERALLY '100',                                                   00309000
      LITSIZ LITERALLY '130',                                                   00309500
      LITFILE LITERALLY '2';                                                    00310000
                                                                                00310500
   /%INCLUDE COMMON %/                                                          00311500
                                                                                00313200
      BASED P2SYMS RECORD DYNAMIC:                                              00313300
         SYM_CONST              FIXED,                                          00313400
         SYM_BASE               BIT(16),                                        00313500
         SYM_DISP               BIT(16),                                        00313600
         SYM_PARM               BIT(16),                                        00313700
         SYM_LEVEL              BIT(16),                                        00313800
      END;                                                                      00313900
   DECLARE SYT_LABEL LITERALLY 'SYT_LINK2';                                     00314000
   BASED DOSORT RECORD DYNAMIC:                                                 00314100
         SYM_SORT     FIXED,                                                    00314200
      END;                                                                      00314300
                                                                                00329000
   BASED VALS FIXED;                                                            00329500
   DECLARE LIT_CHAR_SIZE LITERALLY 'VALS(5)';                                   00329600
   DECLARE NDECSY BIT(16);                                                      00330000
   BASED PAGE_FIX RECORD DYNAMIC:                                               00330100
         TAB_OFF_PAGE       FIXED,                                              00330101
         LINE_OFF_PAGE      BIT(16),                                            00330102
      END;                                                                      00330103
DECLARE OFF_PAGE_MAX LITERALLY 'COMM(19)',(OFF_PAGE_NEXT,OFF_PAGE_LAST) BIT(16),  330200
      DATABASE(PROC#) BIT(16),                                                  00330250
      (OFF_PAGE_BASE, OFF_PAGE_CTR)(1) BIT(16);                                   330300
   BASED    DNS RECORD DYNAMIC:                                                 00330400
         DNSADDR         FIXED,                                                 00330410
         DNSVAL          FIXED,                                                 00330420
      END;                                                                      00330430
                                                                                00330500
   DECLARE                                                                      00331000
      LIT_CHAR_ADDR LITERALLY 'COMM(0)',                                        00336000
      LIT_CHAR_USED LITERALLY 'COMM(1)',                                        00336500
      LIT_TOP       LITERALLY 'COMM(2)',                                        00337000
 /* STMT_NUM      LITERALLY 'COMM(3)', */                                       00337500
      FL_NO_MAX     LITERALLY 'COMM(4)',                                        00338000
      MAX_SCOPE#    LITERALLY 'COMM(5)',                                        00338500
      TOGGLE        LITERALLY 'COMM(6)',                                        00339000
      OPTION_BITS   LITERALLY 'COMM(7)',                                        00339500
      SYT_MAX       LITERALLY 'COMM(10)',                                       00340000
      FIRSTSTMT#    LITERALLY 'COMM(11)',                                         340100
 /* BLOCK_SRN_DATA LITERALLY 'COMM(18)', */                                     00340150
      CODEHWM_HEAD  LITERALLY 'COMM(30)',                                       00340155
 /* LASTSTMT#     LITERALLY 'COMM(3)',   */                                       340200
      DATA_HWM      LITERALLY 'COMM(23)',                                       00340205
      REMOTE_HWM    LITERALLY 'COMM(24)',                                       00340210
      PRIMARY_LIT_START   LITERALLY 'COMM(27)',                                 00340225
      PRIMARY_LIT_END     LITERALLY 'COMM(28)',                                 00340230
      TIME_OF_COMPILATION LITERALLY 'COMM(12)',                                   340300
      DATE_OF_COMPILATION LITERALLY 'COMM(13)',                                   340400
      STMT_DATA_HEAD      LITERALLY 'COMM(16)',                                 00340410
      OBJECT_MACHINE      LITERALLY 'COMM(20)',                                 00340500
      OBJECT_INSTRUCTIONS LITERALLY 'COMM(21)';                     /*CR13811*/ 00341000
   DECLARE (LITORG, LITLIM, CURLBLK, COUNT#GETL) FIXED;                         00342500
                                                                                00343000
   DECLARE (CODE_BASE, CODE_LIM, CODE_BLK, CODE_MAX, CODE_LINE) FIXED,          00343500
      MAX_CODE_LINE FIXED,                                                      00343510
      SPLIT_DELTA BIT(16),                                                      00343530
      CODE_FILE LITERALLY '3',                                                  00344000
      CODE_SIZE LITERALLY '400', CODE_SIZ LITERALLY '399';                      00344500
   ARRAY CODE(CODE_SIZ) FIXED;                                                  00345000
   ARRAY NOT_MODIFIER(64) BIT(8);                                               00345500
                                                                                00346000
   DECLARE (AUX_BASE, AUX_LIM, AUX_BLK, AUX_CTR) FIXED,                           346010
      AUX_FILE BIT(8) INITIAL(1),                                                 346020
      AUXMAT_REQUESTED LITERALLY 'HALMAT_REQUESTED',                              346030
      AUX_SIZ LITERALLY '1799', AUX_SIZE LITERALLY '(AUX_SIZ+1)';                 346040
   ARRAY AUX(AUX_SIZ) FIXED;                                                      346050
                                                                                00346500
   DECLARE (LHS,RHS) (3) BIT(16),TEMP2 FIXED;                                   00346560
   DECLARE PASS1_ADCONS BIT(16);
   DECLARE ERROR# BIT(16);                                                      00347000
   DECLARE SDINDEX BIT(16),                                                     00347010
      LITTRACE BIT(1) INITIAL(0),                                               00347050
      LITTRACE2 BIT(1) INITIAL(0),                                              00347060
      SDBASE BIT(16) INITIAL(2);                                                00347070
                                                                                00347500
 /*************************************************************/                00347556
 /* DR101335 -  ADD REMOTE INFORMATION ITEMS TO THE IND_STACK */                00347557
 /*             I_PNTREMT ::= POINTS_REMOTE                   */                00347558
 /*             I_LIVREMT ::= LIVES_REMOTE                    */                00347559
 /*************************************************************/                00347560
 /* DR102965 -  ADD NAME INFORMATION ITEM TO THE IND_STACK    */
 /*             I_NAMEVAR ::= NAME_VAR                        */
 /*************************************************************/
 /* DR109016 -  ADD INFORMATION ABOUT STRUCTURE WALKS         */
 /*             I_STRUCT_WALK := STRUCT_WALK                  */
 /*************************************************************/
 /* DR109019 -  ADD AIA  INFORMATION ITEM TO THE IND_STACK    */
 /*             I_AIADONE ::= AIA_ADJUSTED                    */
 /*************************************************************/
 /* DR111388 -  WHEN A NEW INDIRECT STACK ENTRY IS CREATED,   */
 /*             MAKE SURE THIS ENTRY IS UPDATED IN PROCEDURE  */
 /*             COPY_STACK_ENTRY                              */
 /*************************************************************/
   DECLARE IND_STACK(STACK_SIZE) RECORD:                                        00347561
         I_CONST        FIXED,                                                  00347562
         I_INX_CON      FIXED,                                                  00347563
         I_STRUCT_CON   FIXED,                                                  00347570
         I_VAL          FIXED,                                                  00347575
         I_XVAL         FIXED,                                                  00347580
         I_BACKUP_REG   BIT(16),                                                00347585
         I_BASE         BIT(16),                                                00347590
         I_COLUMN       BIT(16),                                                00347595
         I_COPY         BIT(16),                                                00347600
         I_DEL          BIT(16),                                                00347605
         I_DISP         BIT(16),                                                00347610
         I_FORM         BIT(16),                                                00347615
         I_INX          BIT(16),                                                00347620
         I_INX_MUL      BIT(16),                                                00347625
         I_INX_NEXT_USE BIT(16),                                                00347630
         I_LOC          BIT(16),                                                00347635
         I_LOC2         BIT(16),                                                00347640
         I_NEXT_USE     BIT(16),                                                00347645
         I_REG          BIT(16),                                                00347650
         I_ROW          BIT(16),                                                00347655
         I_TYPE         BIT(16),                                                00347660
         I_CSE_USE      BIT(16),                                                00347661
         I_DSUBBED      BIT(16),                                                00347662
      /* NEW VARIABLES FOR NAME REMOTE DEREFERENCING:        CR12432 */
      /* NRSTACK SAVES LOC WHEN A REMOTE NR IS PUT ON STACK  CR12432 */
      /* NRDELTA SAVES INDEX TO BE ADDED TO NR'S DISP        CR12432 */
      /* NRDEREF INDICATES A NR DEREFERENCE IS TAKING PLACE  CR12432 */
         I_NRSTACK      BIT(16),                          /* CR12432 */
         I_NRDELTA      BIT(16),                          /* CR12432 */
         I_NRDEREF      BIT(8),                           /* CR12432 */
         I_NRDEREFTMP   BIT(1),                           /*DR109095*/
         I_NRBASE       BIT(16),                          /*DR109095*/
         I_INX_SHIFT    BIT(8),                                                 00347665
         I_STRUCT       BIT(8),                                                 00347670
         I_STRUCT_INX   BIT(8),                                                 00347675
         I_VMCOPY       BIT(8),                                                 00347680
         I_PNTREMT      BIT(8),                                                 00347682
         I_LIVREMT      BIT(8),                                                 00347684
         I_NAMEVAR      BIT(8),                                                 00347684
         I_STRUCT_WALK  BIT(8),
         I_AIADONE      BIT(8),                                                 00347684
      END;                                                                      00347685
   DECLARE    /* VAR_CLASS     BIT(8)  INITIAL (1),        */                   00348000
 /* LABEL_CLASS   BIT(8)  INITIAL (2),        */                                00348500
 /* FUNC_CLASS    BIT(8)  INITIAL (3),        */                                00349000
      MAJ_STRUC     BIT(8)  INITIAL ("0A"),                                     00349500
      TEMPL_NAME    BIT(8)  INITIAL ("3E"),                                     00350000
 /* IND_PTR       BIT(8)  INITIAL ("3F"),     */                                00350500
      LOCK_BITS     FIXED  INITIAL ("00000001"),                                00351000
      REENTRANT_FLAG FIXED INITIAL ("00000002"),                                00351500
      DENSE_FLAG    FIXED  INITIAL ("00000004"),                                00352000
      PARM_FLAGS    FIXED  INITIAL ("00000420"),                                00352500
      ASSIGN_FLAG   FIXED  INITIAL ("00000020"),                                00353000
      DEFINED_LABEL FIXED  INITIAL ("00000040"),                                00353500
      REMOTE_FLAG   FIXED  INITIAL ("00000080"),                                00354000
      AUTO_FLAG     FIXED  INITIAL ("00000100"),                                00354500
      CONSTANT_FLAG FIXED  INITIAL ("00001000"),                                00355000
      NOTLEAF_FLAG  FIXED  INITIAL ("00002000"),                                00355500
      ENDSCOPE_FLAG FIXED  INITIAL ("00004000"),                                00356000
      BITMASK_FLAG FIXED INITIAL("00008000"),                                   00356050
      LATCH_FLAG    FIXED  INITIAL ("00020000"),                                00356500
 /* IMPL_T_FLAG   FIXED  INITIAL ("00040000"), */                               00357000
      EXCLUSIVE_FLAG FIXED INITIAL ("00080000"),                                00357500
      EXTERNAL_FLAG FIXED  INITIAL ("00100000"),                                00358000
      EVIL_FLAGS    FIXED  INITIAL ("00200000"),                                00358500
      DOUBLE_FLAG   FIXED  INITIAL ("00400000"),                                00359000
      IGNORE_FLAG   FIXED  INITIAL ("01040000"),                                  359500
      SM_FLAGS      FIXED  INITIAL ("14C2008C"),                                  360000
      PM_FLAGS      FIXED  INITIAL ("00C20080"),   /*DR109044, 109071 */          360500
      NPM_FLAGS     FIXED  INITIAL ("00C20080"),   /*DR109044, 109071 */          360500
      NI_FLAGS      FIXED  INITIAL ("00C20000"),   /*DR109044, 109071 */          360500
      INCLUDED_REMOTE FIXED INITIAL ("02000000"), /* DR100579, 108643 */        00361010
      RIGID_FLAG    FIXED  INITIAL ("04000000"),                                00361500
      TEMPORARY_FLAG FIXED INITIAL ("08000000"),                                00362000
      NAME_FLAG      FIXED  INITIAL ("10000000"),                               00362500
      ASSIGN_OR_NAME FIXED  INITIAL ("10000020"),                               00363000
      NAME_OR_REMOTE FIXED  INITIAL ("10000080"),                                 363100
      DEFINED_BLOCK  FIXED  INITIAL ("10100000"),                               00363500
      POINTER_FLAG   FIXED  INITIAL ("80000000"),                               00364000
      POINTER_OR_NAME FIXED INITIAL ("90000000"),                               00364500
      SDF_INCL_FLAG FIXED  INITIAL ("00000800"),                                00364600
      SDF_INCL_LIST FIXED  INITIAL ("00001000"),                                00364700
      NONHAL_FLAG   BIT(8) INITIAL ("01"),                                      00361000
      ANY_LABEL     BIT(8)  INITIAL ("40"),                                     00365000
 /* IND_STMT_LAB  BIT(8)  INITIAL ("41"), */                                    00365500
      STMT_LABEL    BIT(8)  INITIAL ("42"),                                     00366000
      IND_CALL_LAB  BIT(8)  INITIAL ("45"),                                     00366500
 /* PROC_LABEL    BIT(8)  INITIAL ("47"), */                                    00367000
      TASK_LABEL    BIT(8)  INITIAL ("48"),                                     00367500
      PROG_LABEL    BIT(8)  INITIAL ("49"),                                     00368000
      COMPOOL_LABEL BIT(8)  INITIAL ("4A");                                     00368500

 /?P  /* SSCR 8348 -- BRANCH CONDENSING  */                                     00369000

 /* TO KEEP A TABLE OF ALL THE BRANCH INSTRUCTIONS, FOR POSSIBLE                00369040
     CONDENSING.  USED IN PROCEDURE OBJECT_CONDENSER */                         00369060
   BASED BRANCH_TBL RECORD DYNAMIC:                                             00369080
         INT_CODELINE   FIXED,            /* LINE IN INTERMEDIATE CODE FILE */  00369100
         B_ADDR         FIXED,            /* AP101 ADDRESS OF BRANCH */         00369120
         TARGET         BIT(16),          /* POINTER TO LABEL TABLE 'LAB_LOC' */00369140
         B_FLINK         BIT(16),         /* POINTER TO NEXT BRANCH */          00369160
         B_BLINK         BIT(16),         /* POINTER TO PREVIOUS BRANCH */      00369180
      END;                                                                      00369200
   ARRAY  LASTBRANCH(PROC#)  BIT(16),                                           00369220
      FIRSTBRANCH(PROC#) BIT(16);                                               00369240
 ?/
                                                                                00369280
 /*   VARIABLE TABLES AND POINTERS  */                                          00369500
   ARRAY   TYP_SIZE LITERALLY '20',                                             00370000
      FULLTEMP BIT(16),                                                         00370500
      (SAVEPOINT, ARRAYPOINT)(LASTEMP) BIT(16),                                 00371000
      UPPER(LASTEMP) FIXED INITIAL(-1, -1),                                     00371500
      LOWER(LASTEMP) FIXED INITIAL(BIGNUMBER),                                  00372000
      SAVED_LINE(LASTEMP) FIXED,                                                00372100
      POINT(LASTEMP) BIT(16),                                                   00372500
      WORK_USAGE(LASTEMP) BIT(16),                                              00373000
      WORK_BLK(LASTEMP) BIT(16),                                                  373100
      WORK_CTR(LASTEMP) BIT(16);                                                00373500
   DECLARE                                                                      00374000
      TEMPSPACE FIXED,                                                          00374500
      SAVEPTR BIT(16),                                                          00375000
      (IX1, IX2, KIN) BIT(16),                                                  00375500
      OPTYPE BIT(16),                                                           00376000
      (AREA, ARRCONST) FIXED,                                                   00376500
      (INDEX,STATNO) BIT(16),                                                   00377000
      TMP FIXED,LITTYPE BIT(16),                                                00377500
      (WORK1, WORK2) FIXED,                                                     00378000
      PACKFORM(31) BIT(8),                                                      00379000
      SYMFORM(31) BIT(1),                                                       00379500
      BLOCK_CLASS(11) BIT(1) INITIAL (0,0,1,1,0,0,0,0,0,0,0,0),                 00380000
      PACKFUNC_CLASS(11) BIT(1) INITIAL (0,0,0,1,0,0,0,0,0,1,0,0);  /*CR13335*/ 00380500
   ARRAY                                                            /*CR13335*/
      PACKTYPE(TYP_SIZE) BIT(8) INITIAL(                                        00381000
      1,1,2,0,0,3,3,3,0,1,1,0,0,3,3,1,4,1,1,3),                                   381500
      SELECTYPE(TYP_SIZE) BIT(8) INITIAL(                                       00382000
      5,0,4,5,5,2,0,0,5,1,4,5,5,3,1,5,0,0,5,0),                                   383500
      CHARTYPE(TYP_SIZE) BIT(8) INITIAL(                                        00384000
      5,4,4,5,5,2,0,0,5,4,4,5,5,3,1,4,0,4,4,0),                                   384500
      DATATYPE(TYP_SIZE) BIT(8) INITIAL(                                        00385000
      0,1,2,3,4,5,6,7,0,1,1,3,4,5,6,1,0,1,1,7),                                   385500
      CVTTYPE(TYP_SIZE) BIT(8) INITIAL(                                         00386000
      0,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,0,1,1,1),                                   386500
      BIGHTS(TYP_SIZE) BIT(8) INITIAL(                                          00387000
 /*==================== DR103753 PART2 ==== D. STRAUSS =====*/                    387500
 /*DANNY  CHANGE APOINTER TO 1 BIGHT INSTEAD OF 2.          */                    387500
 /*DANNY  APOINTER IS A 16-BIT NAME VARIABLE, = 1 HALFWORD. */                    387500
        /****** DR108535 - TEV - 6/8/93 *************************/
        /* CHANGED APOINTER VALUE BACK TO 2.                    */
 /*DANNY */       2,1,1,2,2,2,1,2,4,2,1,4,4,4,2,2,1,1,1,2),                       387500
        /****** END DR108535 ************************************/
 /*=========================================================*/                    387500
      OPMODE(TYP_SIZE) BIT(8) INITIAL(                                          00388000
      3,1,0,3,3,3,1,1,4,2,0,4,4,4,2,2,5,1,0,2),                                   388500
      RCLASS(TYP_SIZE) BIT(8) INITIAL(                                          00389000
      2,3,3,1,1,1,3,3,0,3,3,0,0,0,3,3,0,3,3,3),                                   389500
      SHIFT(TYP_SIZE) BIT(8) INITIAL (                                          00390000
      1,0,0,1,1,1,0,0,2,1,0,2,2,2,1,1,0,0,0,1);                                   390500
                                                                                00391000
 /*  LIBRARY CALL DECLARATIONS  */                                              00391500
   DECLARE IOMODE BIT(8);                                                         392000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT MODULE */

DECLARE OBJECT_MODULE_STATUS BIT(1),
        OBJECT_MODULE_NAME CHARACTER;

 ?/
   DECLARE ESD_LIMIT LITERALLY '400', ESD_CHAR_LIMIT LITERALLY '12',            00393500
      ESD_MAX BIT(16) INITIAL(1), ESD_NAME(ESD_CHAR_LIMIT) CHARACTER;           00394000
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT MODULE */
DECLARE
      LEC                            LITERALLY '3',
      ZCON_CSECT_TYPE                LITERALLY '"60"',
      LIBRARY_CSECT_TYPE             LITERALLY '"A0"',
      CODE_CSECT_TYPE                LITERALLY '"80"',
      DATA_CSECT_TYPE                LITERALLY '"40"';
 ?/
   ARRAY   ESD_TYPE(ESD_LIMIT) BIT(8),                                          00394500
      ESD_NAME_LENGTH(ESD_LIMIT) BIT(8),                                        00395000
      ESD_LINK(ESD_LIMIT) BIT(16),                                              00395500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; OBJECT MODULE */
      ESD_CSECT_TYPE(ESD_LIMIT) BIT(8),
 ?/
      ESD_START(HASHSIZE) BIT(16);                                              00396000
   DECLARE LIB_NUM LITERALLY '282',                                             00396500
      LIB_NAMES(5) CHARACTER INITIAL(                                           00396510
'ACOSACOSHASINASINHATANATANHBINBOUTBTOCCASCASPCASPVCASRCASRPCASRPVCASRVCASVCATCA00396520
TVCEILCINCINDEXCINPCLJSTVCOLUMNCOSCOSHCOUTCOUTPCPASCPASPCPASRCPASRPCPRCPRACPRCCP00396530
SLDCPSLDPCPSSTCPSSTPCRJSTVCSHAPQCSLDCSLDPCSSTCSSTPCSTRCSTRUCCTOBCTODCTOECTOHCTOI00396540
CTOKCTOOCTOX',                                                                  00396550
'CTRIMVDACOSDACOSHDASINDASINHDATANDATANHDATAN2DCEILDCOSDCOSHDEXPDFLOORDINDLOGDMA00396560
XDMDVALDMINDMODDOUTDPRODDPWRDDPWRHDPWRIDROUNDDSINDSINHDSLDDSNCSDSQRTDSSTDSUMDTAN00396570
DTANHDTOCDTOHDTOIDTRUNCEATAN2EINEMAXEMINEMODEOUTEPRODEPWREEPWRHEPWRIESUMETOCETOH00396580
ETOIEXPFLOOR',                                                                  00396590
'GTBYTEHINHMAXHMINHMODHOUTHPRODHPWRHHREMHSUMHTOCIINIMAXIMINIMODIOINITIOUTIPRODIP00396600
WRHIPWRIIREMISUMITOCITODITOEKTOCLINELOGMMRDNPMMRSNPMMWDNPMMWSNPMM0DNPMM0SNPMM1DN00396610
PMM1SNPMM1TNPMM1WNPMM11DNMM11D3MM11SNMM11S3MM12DNMM12D3MM12SNMM12S3MM13DNMM13D3M00396620
M13SNMM13S3',                                                                   00396630
'MM14DNMM14D3MM14SNMM14S3MM15DNMM15SNMM17DNMM17D3MM17SNMM17S3MM6DNMM6D3MM6SNMM6S00396640
3MR0DNPMR0SNPMR1DNPMR1SNPMR1TNPMR1WNPMSTRMSTRUCMV6DNMV6D3MV6SNMV6S3OTOCOUTER1PAG00396650
EQSHAPQRANDGRANDOMROUNDSINSINHSKIPSNCSSQRTSTBYTETABTANTANHTRUNCVM6DNVM6D3VM6SNVM00396660
6S3VO6DNVO6D3',                                                                 00396670
'VO6SNVO6S3VR0DNVR0DNPVR0SNVR0SNPVR1DNVR1DNPVR1SNVR1SNPVR1TNVR1TNPVR1WNVR1WNPVV000396680
DNVV0DNPVV0SNVV0SNPVV1DNVV1DNPVV1D3VV1D3PVV1SNVV1SNPVV1S3VV1S3PVV1TNVV1TNPVV1T3V00396690
V1T3PVV1WNVV1WNPVV1W3VV1W3PVV10DNVV10D3VV10SNVV10S3VV2DNVV2D3VV2SNVV2S3VV3DNVV3D00396700
3VV3SNVV3S3',                                                                   00396710
'VV4DNVV4D3VV4SNVV4S3VV5DNVV5D3VV5SNVV5S3VV6DNVV6D3VV6SNVV6S3VV7DNVV7D3VV7SNVV7S00396720
3VV8DNVV8D3VV8SNVV8S3VV9DNVV9D3VV9SNVV9S3VX6D3VX6S3XTOC');                      00396730
   ARRAY LIB_NAME_INDEX(LIB_NUM) FIXED INITIAL( 0, 67108864, 83887104, 67111168,00396740
      83889408, 67113472, 83891712, 50338560, 67116544, 67117568, 50341376,     00396750
      67119360, 83897600, 67121664, 83899904, 100678400, 83902720, 67126784,    00396760
      50350592, 67128576, 67129600, 50353408, 100685824, 67132928, 100688384,   00396770
      100689920, 50359808, 67137792, 67138816, 83917056, 67141120, 83919360,    00396780
      83920640, 100699136, 50369024, 67147008, 67148032, 83926272, 100704768,   00396790
      83929088, 100707584, 100709120, 100710656, 67157760, 83936000, 67160064,  00396800
      83938304, 67162368, 100717824, 67164928, 67165952, 67166976, 67168000,    00396810
      67169024, 67170048, 67171072, 67172096, 100663297, 83887617, 100666113,   00396820
      83890433, 100668929, 83893249, 100671745, 100673281, 83897601, 67121665,  00396830
      83899905, 67123969, 100679425, 50349313, 67127297, 67128321, 100683777,   00396840
      67130881, 67131905, 67132929, 83911169, 83912449, 83913729, 83915009,     00396850
      100693505, 67140609, 83918849, 67142913, 83921153, 83922433, 67146497,    00396860
      67147521, 67148545, 83926785, 67150849, 67151873, 67152897, 100708353,    00396870
      100709889, 50379777, 67157761, 67158785, 67159809, 67160833, 83939073,    00396880
      83940353, 83941633, 83942913, 67166977, 67168001, 67169025, 67170049,     00396890
      50393857, 83949057, 100663298, 50333186, 67111170, 67112194, 67113218,    00396900
      67114242, 83892482, 83893762, 67117826, 67118850, 67119874, 50343682,     00396910
      67121666, 67122690, 67123714, 100679170, 67126274, 83904514, 83905794,    00396920
      83907074, 67131138, 67132162, 67133186, 67134210, 67135234, 67136258,     00396930
      67137282, 50361090, 100693506, 100695042, 100696578, 100698114,           00396940
      100699650, 100701186, 100702722, 100704258, 100705794, 100707330,         00396950
      100708866, 100710402, 100711938, 100713474, 100715010, 100716546,         00396960
      100718082, 100719618, 100721154, 100722690, 100724226, 100725762,         00396970
      100663299, 100664835, 100666371, 100667907, 100669443, 100670979,         00396980
      100672515, 100674051, 100675587, 100677123, 83901443, 83902723,           00396990
      83904003, 83905283, 100683779, 100685315, 100686851, 100688387,           00397000
      100689923, 100691459, 67138563, 100694019, 83918339, 83919619, 83920899,  00397010
      83922179, 67146243, 100701699, 67148803, 100704259, 83928579, 100707075,  00397020
      83931395, 50378243, 67156227, 67157251, 67158275, 67159299, 100714755,    00397030
      50384643, 50385411, 67163395, 83941635, 83942915, 83944195, 83945475,     00397040
      83946755, 83948035, 83949315, 83886084, 83887364, 83888644, 100667140,    00397050
      83891460, 100669956, 83894276, 100672772, 83897092, 100675588, 83899908,  00397060
      100678404, 83902724, 100681220, 83905540, 100684036, 83908356,            00397070
      100686852, 83911172, 100689668, 83913988, 100692484, 83916804,            00397080
      100695300, 83919620, 100698116, 83922436, 100700932, 83925252,            00397090
      100703748, 83928068, 100706564, 83930884, 100709380, 100710916,           00397100
      100712452, 100713988, 100715524, 83939844, 83941124, 83942404, 83943684,  00397110
      83944964, 83946244, 83947524, 83948804, 83886085, 83887365, 83888645,     00397120
      83889925, 83891205, 83892485, 83893765, 83895045, 83896325, 83897605,     00397130
      83898885, 83900165, 83901445, 83902725, 83904005, 83905285, 83906565,     00397140
      83907845, 83909125, 83910405, 83911685, 83912965, 83914245, 83915525,     00397150
      83916805, 83918085, 67142149),                                            00397160
/?W /*@ The source code exactly as it was.  See V conditional below. */
 /* DANNY STRAUSS ----------- CR11053 -------------------------------*/         00857500
 /* THE LIB_POINTERS (AS STORED IN LIB_START AND LIB_LINK) FOR EACH  */         00857500
 /* UNVERIFIED RTL ROUTINE ARE NOW NEGATIVE -- CHECKED IN EMIT_CALL. */         00857500
 /*-- PMA --------------------CR11133--------------------------------*/
 /* SET LIB_START AND LIB_LINK VALUES TO VERIFIED (+) FOR VV9SN,TRUNC*/
 /* DFLOOR, ETOI, DTOH, AND DCEIL.                                   */
 /*                                                                  */
      LIB_START(HASHSIZE) BIT(16) INITIAL ( 194, 234, 257, 278,-195, 251, 261,  00397170
 /*                                                                  */
 /* PMA --------------------- CR12305 -------------------------------*/
 /* SET LIB_START AND LIB_LINK VALUES TO VERIFIED (+) FOR MM12D3,    */
 /* MM14D3, MM15DN.  SET VALUE TO UNVERIFIED (-) FOR DMAX.           */
 /*                                                                  */
      -212,-104, 255, 265, 245,-105, 259, 269,-182, 226, 263,-273,-144, 232,    00397180
      267, 277,-130,-250, 271, 280,-146,-254, 275,-244,-196,-258, 279, 115,     00397190
      -123,-262, 281, 58, 230, 266,-276, 197, 249,-270,-9, 143,-282,-274, 0),   00397200
      LIB_LINK(LIB_NUM) BIT(16) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   00397210
      -8, 0, 0, 0, 0, 0,-15, 0,-18, 0, 3, 0, 0, 0, 5,-6, 13,-14,-29, 0, 0,-24,  00397220
      0,-32, 0, 0, 0, 12, 0, 0, 0, 0,-35, 31, 0, 0,-11,-38,-4, 34,-44, 48,-7,   00397230
      -21, 0,-2, 1,-57,-22,-50, 26,-27,-55, 20, 62,-63,-43,-42,-40, 0, 68,-61,  00397240
      0, 0, 10,-70, 69,-56,-37, 73, 0,-39,-49,-74, 71, 0,-83,-33, 0,-28, 0, 0,  00397250
      -80,-51,-59,-84, 86,-53, 0, 30,-88,-45,-16,-91,-76, 60, 19,-72, 78,-47,   00397260
      -101,-77, 107, 0, 97, 85, 95,-110, 119, 109, 0,-41,-46,-117,-52,-36,-126, 00397270
      0, 64, 121, 131,-116, 102, 81, 108,-100, 98,-128,-96,-87, 89, 0,-54,      00397280
      135, 113,-140,-112, 75, 0, 66,-148,-118, 120, 92,-122, 99, 79, 65, 149,   00397290
      -25,-132, 114,-153, 93,-90,-136, 103,-142, 165,-151, 152, 17, 145,-137,   00397300
      138, 154,-139, 171,-163,-169,-141, 160, 150,-179, 172,-178,-164, 82,      00397310
      -129,-158,-175, 174,-189, 134,-147, 125,-176,-67,-170, 181,-166, 94,-191, 00397320
      -159, 183, 184,-168, 201,-200, 111, 208,-124,-210,-188,-127, 203,-190,    00397330
      -161,-173,-214, 199,-222, 193,-202,-23,-206,-187, 209, 0, 211,-106,-157,  00397340
      198, 205, 218,-219,-133,-180,-192,-167, 228, 229,-223,-216,-217, 236,     00397350
      -185, 186,-220, 224,-155,-156, 240, 242, 235,-227, 207,-248, 239,-215,    00397360
      -177, 252, 225,-233, 204, 256,-213,-237, 162,-260,-243,-221, 231, 264,    00397370
      -246, 247, 238,-268,-241,-272, 253),                                      00397380
?/
/?V /*@ 2024-06-21 RSB:  Source code modified by Virtual AGC Project */
      LIB_START(HASHSIZE) BIT(16) INITIAL ( 194, 234, 257, 278, 195, 251, 261,  00397170
      212, 104, 255, 265, 245, 105, 259, 269, 182, 226, 263, 273,144, 232,      00397180
      267, 277, 130, 250, 271, 280, 146, 254, 275, 244, 196, 258, 279, 115,     00397190
      123, 262, 281, 58, 230, 266, 276, 197, 249, 270, 9, 143, 282, 274, 0),    00397200
      LIB_LINK(LIB_NUM) BIT(16) INITIAL ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   00397210
       8, 0, 0, 0, 0, 0, 15, 0, 18, 0, 3, 0, 0, 0, 5, 6, 13, 14, 29, 0, 0, 24,  00397220
      0, 32, 0, 0, 0, 12, 0, 0, 0, 0, 35, 31, 0, 0, 11, 38, 4, 34, 44, 48, 7,   00397230
       21, 0, 2, 1, 57, 22, 50, 26, 27, 55, 20, 62, 63, 43, 42, 40, 0, 68, 61,  00397240
      0, 0, 10, 70, 69, 56, 37, 73, 0, 39, 49, 74, 71, 0, 83, 33, 0, 28, 0, 0,  00397250
       80, 51, 59, 84, 86, 53, 0, 30, 88, 45, 16, 91, 76, 60, 19, 72, 78, 47,   00397260
       101, 77, 107, 0, 97, 85, 95, 110, 119, 109, 0, 41, 46, 117, 52, 36, 126, 00397270
      0, 64, 121, 131, 116, 102, 81, 108, 100, 98, 128, 96, 87, 89, 0, 54,      00397280
      135, 113, 140, 112, 75, 0, 66, 148, 118, 120, 92, 122, 99, 79, 65, 149,   00397290
       25, 132, 114, 153, 93, 90, 136, 103, 142, 165, 151, 152, 17, 145, 137,   00397300
      138, 154, 139, 171, 163, 169, 141, 160, 150, 179, 172, 178, 164, 82,      00397310
       129, 158, 175, 174, 189, 134, 147, 125, 176, 67, 170, 181, 166, 94, 191, 00397320
       159, 183, 184, 168, 201, 200, 111, 208, 124, 210, 188, 127, 203, 190,    00397330
       161, 173, 214, 199, 222, 193, 202, 23, 206, 187, 209, 0, 211, 106, 157,  00397340
      198, 205, 218, 219, 133, 180, 192, 167, 228, 229, 223, 216, 217, 236,     00397350
       185, 186, 220, 224, 155, 156, 240, 242, 235, 227, 207, 248, 239, 215,    00397360
       177, 252, 225, 233, 204, 256, 213, 237, 162, 260, 243, 221, 231, 264,    00397370
       246, 247, 238, 268, 241, 272, 253),                                      00397380
?/
 /* DANNY STRAUSS ---------------------------------------------------*/         00857500
/*  CR13222- REPLACED LIB_INDEX & LIB_TABLE WITH LIB_REGS & LIB_CALLTYPE */
      LIB_REGS(LIB_NUM) BIT(16) INITIAL(0,
/*  1*/ "3F00","3F00","3F00","3F00","3F00","3F00","0300","0300","00FE","003E",
/* 11*/ "007E","007E","0000","0000","0000","0000","003E","03FE","03FE","0330",
/* 21*/ "0000","3F20","0300","0300","0300","3F1C","3F00","0000","0000","0300",
/* 31*/ "0300","0300","0300","007C","0000","007C","0320","0320","0320","0320",
/* 41*/ "0300","3F00","0320","0320","0320","0320","0000","007C","0320","3F00",
/* 51*/ "3F00","0320","0320","0320","0320","0320","0300","3F00","3F00","3F00",
/* 61*/ "3F00","3F00","3F00","3F00","0330","3F00","3F00","0F00","0330","0300",
/* 71*/ "3F00","0334","3F00","0334","FF10","0300","0334","3F00","0F00","0F00",
/* 81*/ "0330","3F00","3F00","0020","3F00","3F00","0000","0334","3F00","3F00",
/* 91*/ "3F00","0330","0330","0330","3F00","0300","0334","0334","3F10","0300",
/*101*/ "0334","3F00","0F00","0F00","0334","3F00","0330","0330","0F00","0330",
/*111*/ "0334","0300","0074","0074","00F4","0300","0074","0020","00F4","0074",
/*121*/ "0000","0300","0074","0074","00F4","0300","0300","00F4","0020","0020",
/*131*/ "00F4","0074","0000","0330","0330","03FE","0300","3F00","0000","0000",
/*141*/ "0300","0300","03FA","03FA","0FFE","03FE","0FFE","0FFE","0FFE","3F36",
/*151*/ "03FE","0F36","3F00","3F00","3F00","3F00","0374","0314","0374","0314",
/*161*/ "3F00","3F00","3F00","3F00","0FF2","0FF2","3F00","3F00","3F00","3F00",
/*171*/ "3FFE","3FFE","3FFE","3FFE","0300","0300","0300","0300","0300","0300",
/*181*/ "0000","0076","3FFE","0F5E","3FFE","0F1E","03FE","0300","0300","0300",
/*191*/ "0F00","0F00","0330","3F1C","3F00","0300","3F1C","0FF2","0332","0300",
/*201*/ "3F00","3F00","0330","3FFE","3F3E","3FFE","0F3E","33FE","037E","33FE",
/*211*/ "037E","0300","0300","0300","0300","0300","0300","0300","0300","0300",
/*221*/ "0300","0300","0300","0332","03B2","0332","03B2","0336","03F6","3F16",
/*231*/ "03F6","0336","03F6","3F16","03F6","0336","03F6","3F16","03F6","0336",
/*241*/ "03F6","0316","03F6","3F00","3F00","3F00","3F00","033E","3F1E","033E",
/*251*/ "3F1E","033E","031E","033E","3F1E","0F36","0F16","0F36","0F16","FF36",
/*261*/ "FF16","0F36","0F16","0F3E","0F1C","0F3E","0F1C","0336","3F16","0336",
/*271*/ "3F16","033E","033E","033E","033E","3F00","3F00","3F00","0F00","3F1E",
/*281*/ "0F1E","03FE"),
      LIB_CALLTYPE(LIB_NUM) BIT(8) INITIAL(0,
/*  1*/ 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,3,0,0,0,0,0,1,0,0,0,0,0,0,0,1,
/* 35*/ 0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,
/* 69*/ 3,0,0,1,0,1,1,0,1,0,0,0,3,0,0,0,0,0,0,1,0,0,0,3,3,3,0,0,1,1,1,0,1,0,
/*103*/ 0,0,1,0,3,3,0,3,1,0,1,1,1,0,1,0,1,1,0,0,1,1,1,0,0,1,0,0,1,1,0,3,3,1,
/*137*/ 0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,0,0,0,0,
/*171*/ 1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,3,1,0,0,1,1,1,0,0,0,3,1,
/*205*/ 1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
/*239*/ 1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
/*273*/ 1,1,1,0,0,0,0,1,1,1);

      DECLARE  POW_OF_2(1)  LITERALLY 'SHL(1,%1%)'; /* CR13222 */
   /* -------------- ARRAY ELEMENTS CONTAIN A 1 FOR RTLS -------- CR12620 */
   /*         NEEDING LDMS AND 0 FOR RTLS NOT NEEDING LDMS                */
   ARRAY EMIT_LDM_TABLE(LIB_NUM) BIT(8) INITIAL(1,1,1,1,1,0,0,0,0,0, /*CR13335*/  397560
      /*10*/  1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0,0,1,1,1,1,0,                      470000
      /*33*/  1,1,1,1,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,                      470000
      /*56*/  0,1,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,                      470000
      /*79*/  0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,                        470000
      /*101*/ 0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,                      470000
      /*124*/ 0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,                            470000
      /*144*/ 1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,0,1,1,1,1,1,1,                      470000
      /*167*/ 1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,                    470000
      /*191*/ 0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,                      470000
      /*214*/ 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,                      470000
      /*237*/ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,                      470000
      /*260*/ 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);                     470000
   /* ------------------------ END CR12620 -------------------------------*/
   DECLARE EMIT_LDM BIT(1) INITIAL(TRUE);                    /* CR12620 */      00470500
   DECLARE NEGMAX FIXED INITIAL("80000000"), POSMAX FIXED INITIAL("7FFFFFFF"),  00470500
      NULL_ADDR FIXED INITIAL (0),                                              00471000
      HALFMAX FIXED INITIAL("7FFF"), HALFMIN FIXED INITIAL("FFFF8000");           471500
 /?B  /* CR11114 -- BFS/PASS INTERFACE */
   DECLARE NUMSEQ CHARACTER INITIAL('0123456789');
 ?/
                                                                                00472000
   DECLARE MOVEABLE LITERALLY'1';                                               00472500
   DECLARE  SYT_NAME(1) LITERALLY 'SYM_TAB(%1%).SYM_NAME',                      00473500
      SYT_ADDR(1) LITERALLY 'SYM_TAB(%1%).SYM_ADDR',                            00474000
      SYT_XREF(1) LITERALLY 'SYM_TAB(%1%).SYM_XREF',                            00474500
      SYT_NEST(1) LITERALLY 'SYM_TAB(%1%).SYM_NEST',                            00475000
      SYT_SCOPE(1) LITERALLY 'SYM_TAB(%1%).SYM_SCOPE',                          00475500
      SYT_DIMS(1) LITERALLY 'SYM_TAB(%1%).SYM_LENGTH',                          00476000
      SYT_ARRAY(1) LITERALLY 'SYM_TAB(%1%).SYM_ARRAY',                          00476500
      SYT_PTR(1) LITERALLY 'SYM_TAB(%1%).SYM_PTR',                              00477000
      SYT_LINK1(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK1',                          00477500
      SYT_LINK2(1) LITERALLY 'SYM_TAB(%1%).SYM_LINK2',                          00478000
      SYT_CLASS(1) LITERALLY 'SYM_TAB(%1%).SYM_CLASS',                          00478500
      SYT_FLAGS(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS',                          00479000
      SYT_FLAGS2(1) LITERALLY 'SYM_TAB(%1%).SYM_FLAGS2',  /* DR108643 */        00479000
      SYT_LOCK#(1) LITERALLY 'SYM_TAB(%1%).SYM_LOCK#',                          00479500
      SYT_TYPE(1) LITERALLY 'SYM_TAB(%1%).SYM_TYPE',                            00480000
      EXTENT(1) LITERALLY 'SYM_TAB(%1%).XTNT',                                  00480500
      XREF(1) LITERALLY 'CROSS_REF(%1%).CR_REF',                                00481000
      LIT1(1) LITERALLY 'LIT_PG.LITERAL1(%1%)',                                 00482000
      LIT2(1) LITERALLY 'LIT_PG.LITERAL2(%1%)',                                 00482500
      LIT3(1) LITERALLY 'LIT_PG.LITERAL3(%1%)',                                 00483000
      LABEL_ARRAY(1) LITERALLY 'STMTNUM(%1%).ARRAY_LABEL',                      00483500
      LOCATION(1) LITERALLY 'LAB_LOC(%1%).LOCAT',                               00484000
      LOCATION_ST#(1) LITERALLY 'LAB_LOC(%1%).LOCAT_ST#',          /*CR12713*/  00484000
      LOCATION_LINK(1) LITERALLY 'LAB_LOC(%1%).LINK_LOCATION',                  00484500
      SYT_BASE(1) LITERALLY 'P2SYMS(%1%).SYM_BASE',                             00485000
      SYT_DISP(1) LITERALLY 'P2SYMS(%1%).SYM_DISP',                             00485500
      SYT_PARM(1) LITERALLY 'P2SYMS(%1%).SYM_PARM',                             00486000
      SYT_CONST(1) LITERALLY 'P2SYMS(%1%).SYM_CONST',                           00486500
      SYT_LEVEL(1) LITERALLY 'P2SYMS(%1%).SYM_LEVEL',                           00487000
      SYT_SORT(1) LITERALLY 'DOSORT(%1%).SYM_SORT',                             00487500
      OFF_PAGE_TAB(1) LITERALLY 'PAGE_FIX(%1%).TAB_OFF_PAGE',                   00488000
      OFF_PAGE_LINE(1) LITERALLY 'PAGE_FIX(%1%).LINE_OFF_PAGE',                 00488500
      DENSEADDR(1) LITERALLY 'DNS(%1%).DNSADDR',                                00489000
      DENSEVAL(1) LITERALLY 'DNS(%1%).DNSVAL',                                  00489500
      DW(1) LITERALLY 'FOR_DW(%1%).CONST_DW',                                   00490000
      OPR(1) LITERALLY 'FOR_ATOMS(%1%).CONST_ATOMS';                            00490500
                                                                                00540000
                                                                                00543100
 /* INCLUDE VMEM DECLARES:  $%VMEM1  */                                         00543200
 /* AND:  $%VMEM2  */                                                           00543300
                                                                                00543400
 /* MISCELLANEOUS DECLARATIONS */                                               00543500
   DECLARE FOREVER LITERALLY 'WHILE 1',                                         00544000
      LINE# FIXED,                                                              00546000
      CLOCK(2) FIXED,                                                           00546500
      (SAVE_LOCCTR, SAVE_CODE_LINE) FIXED,                                      00546600
      MAX_SEVERITY BIT(16),                                                     00547000
      (NEXTCTR, ASNCTR) BIT(16),                                                00547500
      (LAST_FLOW_BLK, LAST_FLOW_CTR) BIT(16),                                   00547600
      BOOL_COUNT BIT(16), LAST_TAG BIT(1),                                      00548000
      STOPPERFLAG BIT(1),                                                       00548500
      DECLMODE BIT(1),                                                          00549000
      EXTRA_LISTING BIT(1),                                                     00549500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; MAKE 'AB' AND 'L' INDEPENDENT */
      CODE_LISTING  BIT(1),
 ?/
      SELF_ALIGNING BIT(1),                                                     00550000
      COMPACT_CODE BIT(1),                                                      00550500
      SDL BIT(1),                                                               00551000
      REGOPT BIT(1), /* ---------- CR11095 ----------*/
      SREF BIT(1),                                                                551100
      (FIRST_INST, ADDRS_ISSUED) BIT(1),                                        00551500
      Z_LINKAGE BIT(1),                                                         00552000
      OLD_LINKAGE BIT(1),                                                       00552500
      NEW_INSTRUCTIONS BIT(1),                                                  00553000
      GENERATING BIT(1),                                                        00553500
      REMOTE_ADDRS BIT(1),                                                      00554000
      BNOT_FLAG BIT(1),                                                         00555500
 /?B  /* CR11114 -- BFS/PASS INTERFACE; ADD CONSTANT PROTECTION */
      CURR_STORE_PROTECT BIT(1) INITIAL(FALSE),
      GENED_LIT_START FIXED,
 ?/
      THISPROGRAM LITERALLY 'ESD_TABLE(PROGPOINT)',                             00556000
      PP FIXED;                                                                 00556500
                                                                                00557000
 /* LABELS */                                                                   00557500
   DECLARE (SUBMONITOR,RESTART,SRCERR) LABEL;                                   00558000
   DECLARE UNIMPLEMENTED LABEL;                                                 00558500
   DECLARE DESC LITERALLY 'STRING';                                             00559000
   DECLARE HALMAT_OPCODE     BIT(16);                                           00559020
  /*------------- #D ------------------------------------------------*/
   DECLARE    /* VALUES RETURNED BY CSECT_TYPE ROUTINE */
       STACKVAL  LITERALLY '0', /* VALUE ON THE STACK */
       STACKADDR LITERALLY '1', /* ADDRESS ON THE STACK */
       INCREM#P  LITERALLY '2', /* COMPOOL INCLUDED REMOTE */
       COMPOOL#R LITERALLY '3', /* COMPOOL DECLARED REMOTE */
       COMPOOL#P LITERALLY '4', /* COMPOOL DECLARED */
       REMOTE#R  LITERALLY '5', /* PROGRAM/PROC DECLARED REMOTE */
       LOCAL#D   LITERALLY '6', /* PROGRAM/PROC DECLARED */
       PDENTRY#E LITERALLY '7', /* PROCESS DIRECTORY ENTRY */ /*DR108618*/
       STRUCT_NAME32 LITERALLY '8', /*STRUCTURE WALK THRU 32BIT NAME--DR109055*/
       STRUCT_NAME16 LITERALLY '9'; /*STRUCTURE WALK THRU 16BIT NAME--DR109055*/
  /*------------- #DREG ---------------------------------------------*/         11311036
   DECLARE   /* VALUES USED IN REG_STAT ROUTINE IN RESTRICTION LOGIC */         11312035
       LOADBASE  LITERALLY '0', /* VIRTUAL BASE VALUE LOAD */                   11313035
       LOADNAME  LITERALLY '1', /* NAME VARIABLE LOAD */                        11314035
       LOADPARM  LITERALLY '2', /* FORMAL PASS-BY-REF PARAMETER LOAD */         11315035
       LOADADDR  LITERALLY '3', /* ADDRESS LOAD (LA) */                         11316035
       LOADLABEL LITERALLY '4'; /* DO-CASE LABEL LOAD */                        11317035
  /*------------- #DDSE ---------------------------------------------*/         11251013
   DECLARE DSESET  BIT(8) INITIAL(0), /* ESDS OF THE LDM      */                11270019
           DSECLR  BIT(8) INITIAL(0), /* CONSTANTS STORED HERE.*/               11280020
  /*------------- #DREG ---------------------------------------------*/         11350008
     D_RTL_SETUP   BIT(8) INITIAL(0), /* TRUE WHEN LOADING REGISTERS*/          11360031
    /*BOOLEAN*/                       /* IN PREPERATION FOR RTL CALL*/          11370019
     D_R1_CHANGE   BIT(8) INITIAL(0), /* TRUE WHEN R1 LOADED WITH   */          11380031
    /*BOOLEAN*/                       /* SOME NEW BASE VALUE.       */          11390019
     D_R3_CHANGE   BIT(8) INITIAL(0), /* TRUE WHEN R3 LOADED WITH   */          11380031
    /*BOOLEAN*/                       /* SOME NEW BASE VALUE.       */          11390019
    /*THE PREVIOUS VALUE OF D_RX_CHANGE IS KEPT IN NEXT-TO-LAST BIT */          11390019
    /*SO THAT IF A RESTORE OF RX IS TAKING PLACE BEFORE INSTRUCTION */          11390019
    /*THAT ALSO CHANGES RX, THAT INFORMATION WILL NOT BE LOST.      */          11390019
  /*------------- #DMVH ---------------------------------------------*/         11340008
     D_MVH_SOURCE  BIT(8) INITIAL(0); /*TRUE WHEN SETTING UP SOURCE*/           11350020
    /*BOOLEAN*/                       /*REG FOR MVH--NO REGISTER   */           11360019
                                      /*RESTRICTION NEEDED FOR THIS*/           11370019
     DECLARE ATOM#_LIM LITERALLY '1799';      /*DR109084*/
     ARRAY VAC_VAL(ATOM#_LIM) BIT(1);         /*DR109084*/
     ARRAY OPR_VAL(ATOM#_LIM) FIXED;          /*DR109084*/
     ARRAY SAVE_STACK(STACK_SIZE) BIT(1);     /*DR109067*/
     DECLARE ADV_STMT#(1) LITERALLY 'ADVISE(%1%).STMT#',   /*CR12214*/
             ADV_ERROR#(1) LITERALLY 'ADVISE(%1%).ERROR#'; /*CR12214*/
     DECLARE INIT_VAL(1) LITERALLY 'INIT_TAB(%1%).VALUE'; /*CR13079*/
 /* INCLUDE VMEM ROUTINES: $%VMEM3F */                                          00559600
 /* INCLUDE VMEM ROUTINES: $%VMEM5A */                                          00559600
 /**MERGE CSECTTYP     CSECT_TYPE                      */  /* #D */
 /**MERGE SINGLEVA     SINGLE_VALUED                   */  /*#DNAME*/           11490029
 /**MERGE MAX          MAX                             */
 /**MERGE MIN          MIN                             */
 /**MERGE CHARINDE     CHAR_INDEX                      */
 /**MERGE FORMAT       FORMAT                          */
 /**MERGE HEX          HEX                             */
 /**MERGE PAD          PAD                             */
 /**MERGE HASH         HASH                            */
 /**MERGE INSTRUCT     INSTRUCTION                     */
 /**MERGE ESDTABLE     ESD_TABLE                       */
 /**MERGE ENTERESD     ENTER_ESD                       */
 /?P  /* CR11114 -- HAS TO DO WITH SPILL               */
 /**MERGE PRIMTOOV     PRIM_TO_OVFL                    */
 ?/
 /**MERGE HEXLOCCT     HEX_LOCCTR                      */
 /**MERGE POPCODE      POPCODE                         */
 /**MERGE POPNUM       POPNUM                          */
 /**MERGE POPTAG       POPTAG                          */
 /**MERGE DECODEPO     DECODEPOP                       */
 /**MERGE GETAUX       GET_AUX                         */
 /**MERGE AUXLINE      AUX_LINE                        */
 /**MERGE NEWHALMA     NEW_HALMAT_BLOCK                */
 /**MERGE AUXOP        AUX_OP                          */
 /**MERGE AUXSYNC      AUX_SYNC                        */
 /**MERGE NEXTCODE     NEXTCODE                        */
 /**MERGE GETLITER     GET_LITERAL                     */
 /**MERGE GETCODE      GET_CODE                        */
 /**MERGE SETUPSTA     SETUP_STACK                     */
 /**MERGE SETLINKR     SET_LINKREG                     */
 /**MERGE CLEARREG     CLEAR_REGS                      */
 /**MERGE CHECKSRS     CHECK_SRS                       */
 /**MERGE ADJUST       ADJUST                          */
 /**MERGE CS           CS                              */
 /**MERGE EMITC        EMITC                           */
 /**MERGE EMITW        EMITW                           */
 /**MERGE EMITSTRI     EMITSTRING                      */
 /**MERGE BOUNDARY     BOUNDARY_ALIGN                  */
 /**MERGE SETLOCCT     SET_LOCCTR                      */
 /**MERGE EMITADDR     EMITADDR                        */
 /**MERGE EMITNOP      EMIT_NOP                        */
 /**MERGE SAVEBRAN     SAVE_BRANCH_AROUND              */
 /**MERGE EMITBRAN     EMIT_BRANCH_AROUND              */
 /**MERGE NOBRANCH     NO_BRANCH_AROUND                */
 /**MERGE NEEDSTAC     NEED_STACK                      */
 /**MERGE RELEASET     RELEASETEMP                     */
 /**MERGE ERRORS       ERRORS                          */
 /**MERGE CHECKSIZ     CHECKSIZE                       */
 /**MERGE PRINTTIM     PRINT_TIME                      */
 /?B /* CR11114 -- BFS/PASS INTERFACE                  */
 /**MERGE DECODEYE     DECODE_YEAR_DAY_AND_MONTH       */
 ?/
 /**MERGE PRINTDAT     PRINT_DATE_AND_TIME             */
 /**MERGE LIBLOOK      LIB_LOOK                        */
 /**MERGE INTRINSI     INTRINSIC                       */
 /**MERGE GETSTATN     GETSTATNO                       */
 /**MERGE GETARRAY     GETARRAYDIM                     */
 /**MERGE GETARRA2     GETARRAY#                       */
 /**MERGE NAMESIZE     NAMESIZE                        */
 /?B /* CR11114 -- BFS/PASS INTERFACE                  */
 /**MERGE REMUNDIE     REM_UNDIES                      */
 ?/
 /**MERGE PROGNAME     PROGNAME                        */
 /**MERGE SETMASKI     SET_MASKING_BIT                 */
 /**MERGE EMITADD2     EMIT_ADDRS                      */
 /**MERGE UNSPEC       UNSPEC                          */
 /**MERGE INITIALI     INITIALISE                      */
 /**MERGE OPTIMISE     OPTIMISE                        */
 /**MERGE GENERATE     GENERATE                        */
 /**MERGE GENERAT2     GENERATE_CONSTANTS              */
 /**MERGE PRINTSUM     PRINTSUMMARY                    */
 /**MERGE NEXTREC      NEXT_REC                        */
 /**MERGE SKIP         SKIP                            */
 /**MERGE SKIPADDR     SKIP_ADDR                       */
 /**MERGE REALLABE     REAL_LABEL                      */
 /**MERGE GETINSTR     GET_INST_R_X                    */
 /**MERGE OBJECTCO     OBJECT_CONDENSER                */
 /**MERGE OBJECTGE     OBJECT_GENERATOR                */
 /**MERGE TERMINAT     TERMINATE                       */
                                                                                07948500
 /*  START OF THE MAIN PROGRAM  */                                              07949000
MAIN_PROGRAM:                                                                   07949500
   CLOCK = MONITOR(18);                                                         07950000
   OUTPUT(1) = '1';                                                             07950500
   CALL PRINT_DATE_AND_TIME('   HAL/S COMPILER PHASE 2  --  VERSION OF ',       07951000
      DATE_OF_GENERATION, TIME_OF_GENERATION);                                  07951500
   OUTPUT='';                                                                   07952000
   CALL PRINT_DATE_AND_TIME('HAL/S PHASE 2 ENTERED ',DATE,TIME);                07952500
   OUTPUT='';                                                                   07953000
   CALL INITIALISE;                                                             07953500
   CLOCK(1) = MONITOR(18);                                                      07954000
   GENERATING = TRUE;                                                           07954100
   DO WHILE GENERATING;                                                         07954500
      CALL NEW_HALMAT_BLOCK;                                                    07955000
      CALL OPTIMISE(1);                                                         07955500
      CALL DECODEPOP(CTR);                                                      07956000
RESTART:                                                                        07956500
      CALL GENERATE;                                                            07957000
   END;                                                                         07957500
   CLOCK(2) = MONITOR(18);                                                      07958000
   /* CR12416: SEVERITY 1 ERRORS TREATED AS WARNING UNTIL NOW */                07959000
   IF (MAX_SEVERITY = 0) & SEVERITY_ONE              /* CR12416 */              07959000
      THEN MAX_SEVERITY = 1;                         /* CR12416 */              07959000
   CALL TERMINATE;                                                              07959000
SUBMONITOR:                                                                     07959500
   CALL PRINTSUMMARY;                                                           07960000
   RECORD_FREE(LAB_LOC);                                                        07960500
   RECORD_FREE(STMTNUM);                                                        07960550
   RECORD_FREE(PAGE_FIX);                                                       07960600
   RECORD_FREE(P2SYMS);                                                         07960650

 /?P  /* SSCR 8348 -- BRANCH CONDENSING           */
   RECORD_FREE(BRANCH_TBL);                                                     07960660
      /* SSCR 8348 -- BASE REG ALLOCATION (ADCON) */
   RECORD_FREE(BASE_REGS);                                                      07960670
 ?/
   IF RECORD_ALLOC(DNS) > 0 THEN                                                07960700
      RECORD_FREE(DNS);                                                         07960750
   /*MAKE SURE MAX_SEVERITY IS SET CORRECTLY IN CASE A SEVERITY 1*/             07959000
   /*ERROR WAS ISSUED IN TERMINATE OR PRINTSUMMARY.              */             07959000
   IF (MAX_SEVERITY = 0) & SEVERITY_ONE              /*DR111327*/               07959000
      THEN MAX_SEVERITY = 1;                         /*DR111327*/               07959000
   IF MAX_SEVERITY = 0 THEN DO;                                                 07960800
      IF (OPTION_BITS & "800") ^= 0 THEN DO;                                    07960810
         CALL RECORD_LINK;                                                      07960820
      END;                                                                      07960840
   END;                                                                         07960850
   RETURN SHL(MAX_SEVERITY,2) | COMMON_RETURN_CODE;                             07961000
SRCERR:                                                                         07961500
   CLASS = 9;  /* TO FORCE SEND ERROR CODE */                                   07962000
   GO TO RESTART;                                                               07962500
UNIMPLEMENTED:                                                                  07963000
   CALL ERRORS(CLASS_B,102);                                                    07963500
   EOF EOF EOF EOF EOF EOF EOF EOF EOF                                          07964000
