*/ License:     None. Believed to be in the Public Domain in the U.S.
*/ Restriction: Export from the U.S. may (or may not) be restricted by 
*/              International Traffic in Arms Regulations (ITAR).
*/ Filename:    BILDNEW5.asm
*/ Language:    IBM AP-101S Assembly Language
*/ Purpose:     This is part of the original source code for the 
*/              Space Shuttle's flight software.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ Note 1:      Comments added by the Virtual AGC Project are distinct
*/              from the original comments in that they are full-line
*/              comments with / in column 2.
*/ Note 2:      Unless otherwise explicitly noted, the original 
*/              source-code lines have been altered only by
*/              anonymization of personal names or initials with 
*/              unique tags of the form ^X, \X, ^XX, or \XX, where X 
*/              is alphanumeric.  These are arbitrary codes, *not* the
*/              person's initials. 
*/ History:     2024-08-04 RSB  Prepared from original source module.


                                                                                
* ASM IPL BILDNEW5 SOURCE                                    R  2.   7  000100AH
GPCIPL   CSECT                                                          000300AH
*                      THIS IS VER. 9.05 OF GPCIPL                      000400AH
         EXTRN MENU                                                     000600AH
         EXTRN MENUA                                                    000700AH
         EXTRN MSGTABLE                                                 000800AH
         EXTRN FAZ2STRT                                                 000900AH
         EXTRN SSLCKSUM                                                 001000AH
         EXTRN SSLENGTH                                                 001100AH
         EXTRN SSLSTART                                                 001200AH
         EXTRN LOADTBL                                                  001300AH
         EXTRN MAPTABLE                                                 001400AH
         EXTRN FMADEU11                                                 001500AH
         EXTRN VMATFLD1                                                 001600AH
         EXTRN VMATFLD2                                                 001700AH
         EXTRN VMATFLD3                                                 001800AH
         EXTRN VMATFLM1                                                 001900AH
         EXTRN VMATFLM2                                                 002000AH
         EXTRN VMATFLM3                                                 002100AH
         EXTRN GMAIMUC1                                                 002200AH
         ENTRY IPLID                                                    002300AH
         ENTRY STPWMK                                                   002400AH
         ENTRY STMWMK                                                   002500AH
         ENTRY BSLRDWR5                                                 002600AH
         ENTRY RAWCNT2                                                  002700AH
         ENTRY RAWCNT3                                                  002800AH
         ENTRY RAWCNT4                                                  002900AH
         ENTRY RAWCNT5                                                  003000AH
         ENTRY RAWCNT6                                                  003100AH
         ENTRY BCEMFDLY                                                 003200AH
         ENTRY BCEMF1DY                                                 003300AH
         ENTRY BCEMF2DY                                                 003400AH
         ENTRY BCELMFDY                                                 003500AH
* CR/SMS LOG:                                                           003700AH
*   CR  92108A SEE SMS B26535 (IPL 9.05) 09/23/96                       003800AH
*   CR  90945  SEE SMS B26525 (IPL 9.04) 12/10/93                       003900AH
*   CR  90601  SEE SMS B26522 (IPL 9.03) 11/22/91                       004000AH
*   CR  90354A SEE SMS B26513 (IPL 9.02) 12/14/90                       004100AH
*   CR  90363A SEE SMS B26514 (IPL 9.02) 12/03/90                       004200AH
*   CR  90155B SEE SMS B26504 (IPL 9.01) 02/01/90                       004300AH
*   CR  89722  SEE SMS B26505                                           004400AH
*   CR  89368  SEE SMS B26506                                           004500AH
*   CR  89723  SEE SMS B26501                                           004600AH
*   CR  89722  SEE SMS B26500                                           004700AH
*   CR  89370A SEE SMS B06570                                           004800AH
*   CR  79857E SEE SMS B06553                                           004900AH
*   CR  79341  SEE SMS B06547                                           005000AH
*   CR  69704A SEE SMS B06539                                           005100AH
*   CR  69921  SEE SMS B06534                                           005200AH
*   CR  69928  SEE SMS B06530                                           005300AH
*   CR  59435A SEE SMS B06500                                           005400AH
*   CR  59315B SEE SMS G105,G108,B06501                                 005500AH
*   CR  50203B SEE SMS G105,G107                                        005600AH
*   CR  39582B SEE SMS G105,G110,B06500,B06512                          005700AH
*   CR  39726  SEE SMS G103                                             005800AH
*   CR  39009  SEE SMS G086                                             005900AH
*   CR  29952  SEE SMS G083                                             006000AH
*   CR  29345F SEE SMS G080                                             006100AH
*   CR  29225A SEE SMS G067                                             006200AH
*   CR  29204  SEE SMS G056                                             006300AH
*                                                                       006400AH
* CR/SMS LOG:                                                           006500AH
*   SMS B26535  MOD FSW MEMBERS TO REMOVE NONSTD CHRS                   006600AH
*   SMS B26525  GPCIPL HARDWARE RESPONSE TIME FOR MEDS                  006700AH
*   SMS B26522  MASK INTERRUPT REG. E BITS DURING IPL                   006800AH
*   SMS B26513  PRESERVE VAR ENVT FOLLOW MMU INTFC ERROR                006900AH
*   SMS B26514  GPCIPL BSL CKSM ERROR MSG FIX                           007000AH
*   SMS B26504  BFS MASS MEMORY UNIT EXPANSION                          007100AH
*   SMS B26010  PROTECT TFL 102 DATA TABLE                              007200AH
*   SMS B26009  AP101S IOP READ INTERRUPT REGS. B,D & E                 007300AH
*   SMS B26008  DMA I/O STORE PROTECT ERROR                             007400AH
*   SMS B26004  REAL TIME COUNTER'S RTC TEST                            007500AH
*   SMS B26006  DSE INSTRUCTION ERROR PROCESSING                        007600AH
*   SMS B26001  ARITHMETIC AND LOGICAL INSTRUCTIONS                     007700AH
*   SMS B26005  DETECTION OF DEU CPU FAILURE                            007800AH
*   SMS B26505  GPCIPL MIA PARITY TEST                                  007900AH
*   SMS B26506  GPCIPL ERROR RECOVERY                                   008000AH
*   SMS B26000  GPCIPL STP DIAGNOSE INSTRUCTIONS                        008100AH
*   SMS B26501  GPCIPL AP101S DSE CHANGES                               008200AH
*   SMS B26500  GPCIPL AP101B CODE DELETION                             008300AH
*   SMS B06570  ROS PARITY INTERRUPT CODE                               008400AH
*   SMS B06569  STP CYCLE COUNT                                         008500AH
*   SMS BO6568  PASS LOAD I-FAIL LIGHT                                  008600AH
*   SMS B06553  GPCIPL MOD AP101S UPGRADE                               008700AH
*   SMS B06547  GENERIC STP                                             008800AH
*   SMS B06545  TFL LOCATION MASS MEMORY CHANGES                        008900AH
*   SMS B06539  GPCIPL MACHINE INDEPENDENCE SOFTWARE                    009000AH
*   SMS B06536  STP IOP TEST ERROR                                      009100AH
*   SMS B06534  GPCIPL MENU LOAD FIX                                    009200AH
*   SMS B06533  STP SAVE ENVIRONMENT                                    009300AH
*   SMS B06531A PURGE/STP OPERATIONS                                    009400AH
*   SMS B06530  UNPROTECTED JOB TABLE                                   009500AH
*   SMS B06528  ICC POLLING (BUS 5)                                     009600AH
*   SMS B06527  136 HW DOWNLIST BUFFER                                  009700AH
*   SMS B06520  SOURCE COMMENT UPDATE                                   009800AH
*   SMS B06515A INVALID MMU TRANS TABLE CONTENT                         009900AH
*   SMS B06511A INCORRECT MMU ADDR AND BLK COUNTS                       010000AH
*   SMS B06509C INVALID CRT SELECT CHECK                                010100AH
*   SMS B06507A REQUIRED LABELS FOR PATCHING GPCIPL                     010200AH
*   SMS B06503 REMOVAL OF SINGLE/DOUBLE DENSITY CHECK                   010300AH
*   SMS B06502 MM PURGE CLEAN UP AFTER PURGE                            010400AH
*   SMS BO6500 IPL: TWICE A SECOND UPDATE                               010500AH
*   SMS G110  GPCIPL MEMORY PURGE DEMO                                  010600AH
*   SMS G105  GPC/DEU/MMU MEMORY PURGE OPTION (CR 39582B)               010700AH
*   SMS G103  GPC MIA SPURIOUS TRANSMISSION (CR 39726)                  010800AH
*   SMS G101  TEST INTERRUPTS ANNUNCIATION                              010900AH
*   SMS G099  POLL RESPONSE ERRORS DURING DEU SELF TEST                 011000AH
*   SMS G097  DISPLAY GPCIPL LOAD IDENTIFIER                            011100AH
*   SMS G096  STORE PROTECT NEW PATCH AREA                              011200AH
*   SMS G095  CORRECT MACHINE CHECK INTERRUPT MASK                      011300AH
*   SMS G094  CORRECT MESSAGE 17 TEXT                                   011400AH
*   SMS G093  INITIALIZATION OF DEU 4                                   011500AH
*   SMS G091  ERRONEOUS MEMORY POWER SWITCHING FAILURE                  011600AH
*   SMS G088  MISSING STP TESTS (IOP ROS PARITY ERR & DMA I/O STORE     011700AH
*             PROTECT)                                                  011800AH
*   SMS G087  MMU LOADBLOCK CHECKSUM                                    011900AH
*   SMS G086  STP MEM PWR SWITCH LIMITS (CR 39009)                      012000AH
*   SMS G084  DEU BITE ERROR INFORMATION                                012100AH
*   SMS G083  CORRECT SSL CHECKSUM (CR 29952)                           012200AH
*   SMS G082  HISAM CHECKSUM ERROR                                      012300AH
*   SMS G080  GROUND IMU CNTL/MONITOR DISPLAY & IMU CHECKPOINT MM       012400AH
*             AREA FORMAT (CR 29345F)                                   012500AH
*   SMS G076  MODIFY MEMORY PAGE PWR TEST MESSAGES                      012600AH
*   SMS G075  LOG SVC NUMBER FOR POWER XIENT                            012700AH
*   SMS G073  MSG TEXT ERRORS                                           012800AH
*   SMS G072  LOSS OF OLD PSW IN INTERRUPT PROCESSORS                   012900AH
*   SMS G071  ERROR IN SINGLE/DOUBLE DENSITY CHECK                      013000AH
*   SMS G070  RTN ADR ERROR IN INSTRUCTION MONITOR INTERRUPT TEST       013100AH
*   SMS G069  ERROR IN STORE PROTECT INTERRUPT TEST                     013200AH
*   SMS G068  DEU CRITICAL FMTS NOT RELOADED FOLLOWING DEU SASTP RESUME 013300AH
*   SMS G067  IPL DEFAULT LOAD ENHANCEMENT (CR 29225A)                  013400AH
*   SMS G064  LOSS OF ELAPSED TIME FOR MEMORY PAGE FAILURE              013500AH
*   SMS G063  CORRECT CLOCK RESTORE                                     013600AH
*   SMS G062  ERROR IN HI-PRIORITY MESSAGE PROCESSING                   013700AH
*   SMS G061  DELETE SCRUNCH TABLE FROM DEU CONTROL PROGRAM             013800AH
*   SMS G057  CHANGE MESSAGE TEXT                                       013900AH
*   SMS G056  INITIALIZE HIGH CORE AT STARTUP (CR29204)                 014000AH
*   SMS G054  SAVE ENVIRONMENT SUBROUTINE REGISTER SET ERROR            014100AH
*   SMS G053  UNEXPECTED ERRORS DETECTED BY STP                         014200AH
*   SMS G050A ASTERISK INCORRECT ON MENU PAGE AFTER TERMINATION OF      014300AH
*              DEU STP                                                  014400AH
*   SMS G049  FAILURE TO RECOVER FROM STP ERROR                         014500AH
*   SMS G045  GPC STP USES INVALID INSTRUCTION (CED)                    014600AH
*   SMS G044  EX0 INTERRUPT CODE CHECK                                  014700AH
*   SMS G043A ITEMS 24 & 25 DOWNLIST INTERFERENCE                       014800AH
*   SMS G040  HISAM PARITY RESTART                                      014900AH
*   SMS G039  SVC HANDLER CHANGES                                       015000AH
*   SMS G038  CHECK LOADTBL FOR BFS MMU ADRESS                          015100AH
*   SMS G037  ERROR ENVIRONMENT CHANGES                                 015200AH
*   SMS G036  D/L FORMAT 50 BCE PROGAM                                  015300AH
*   SMS G035  D/L FORMAT 49 ERRORS                                      015400AH
*   SMS G034  IOP TERMINATE A ANNUNICATION                              015500AH
*   SMS G033  'C9FB' AND 'C6C6' ERROR HANDLING                          015600AH
*   SMS G032  INCORRECT INDEX COUNT IN R/M VOTER TEST                   015700AH
*   SMS G031  INCORRECT MSC ADR IN TRISTATE DRIVER TABLE                015800AH
*   SMS G030  SELF TEST FAILURE                                         015900AH
*   SMS G029A GPCIPL HISAM DUMP 6/7/79                                  016000AH
*   SMS G028  INCORRECT USE OF MMU DIRECTORY                            016100AH
*                                                                       016200AH
*   DR/SMS LOG:                                                         016300AH
*                                                                       016400AH
* DR 109638  04/05/96 (IPL 9.05) SEE SMS B26016A                        016500AH
* DR 106266  11/22/91 (IPL 9.03) SEE SMS B26014                         016600AH
* DR 106053  12/03/90 (IPL 9.02) SEE SMS B26514                         016700AH
* DR 103281  12/05/89 (IPL 9.01) SEE SMS B26009                         016800AH
* DR 102140  01/21/90 (IPL 9.01) SEE SMS B26010                         016900AH
*                                                                       017000AH
* CHANGE LOG:                                                           017100AH
* IPL 9.05 09/23/96                                                     017200AH
*                                                                       017300AH
*  07/02/96 ^ev-SMS B26016A INCORRECT LIMITS OR CLOCK-1 HANDLER         017400AH
*  09/23/96 ^ev-SMS B26535  MOD FSW MEMBERS TO REMOVE NONSTD CHRS       017500AH
*                                                                       017600AH
* IPL 9.04 12/10/93                                                     017700AH
*                                                                       017800AH
*  12/10/93 ^ev-SMS B26525 GPCIPL HARDWARE RESPONSE TIME FOR MEDS       017900AH
*                                                                       018000AH
* IPL 9.03 11/22/91                                                     018100AH
*                                                                       018200AH
*  11/22/91 ^ew-SMS B26522 MASK INTERRUPT REG. E BITS DURING IPL        018300AH
*  11/22/91 ^ew-SMS B26014 GPCIPL MENU 2 MAJ/MIN FIELDS                 018400AH
*                                                                       018500AH
* IPL 9.02 12/14/90                                                     018600AH
*                                                                       018700AH
*  12/14/90 ^ew-SMS B26513  PRESERVE VAR ENVT FOLLOW MMU INTFC ERROR    018800AH
*  12/03/90 ^ew-SMS B26514  GPCIPL BSL CKCM ERROR MSG FIX               018900AH
*                                                                       019000AH
* IPL 9.01 02/01/90                                                     019100AH
*                                                                       019200AH
*  02/01/90 ^ew-SMS B26504  BFS MASS MEMORY UNIT EXPANSION              019300AH
*  01/29/90 ^ew-SMS B26010  PROTECT TFL 102 DATA TABLE                  019400AH
*  12/11/89 ^ew-SMS B26009  AP101S IOP READ INTERRUPT REGS. B,D & E     019500AH
*                                                                       019600AH
*  10/31/88 ^ew-SMS B26008  DMA I/O STORE PROTECT ERROR                 019700AH
*  06/25/88 ^ew-SMS B26004  REAL TIME COUNTER'S RTC TEST                019800AH
*  06/25/88 ^ew-SMS B26006  DSE INSTRUCTION ERROR PROCESSING            019900AH
*  06/25/88 ^ew-SMS B26001  ARITHMETIC AND LOGICAL INSTRUCTIONS         020000AH
*  06/25/88 ^ew-SMS B26005  DETECTION OF DEU CPU FAILURE                020100AH
*  06/25/88 ^ex-SMS B26505  GPCIPL MIA PARITY TEST                      020200AH
*  06/25/88 ^ex-SMS B26506  GPCIPL ERROR RECOVERY                       020300AH
*  01/25/88 ^ex-SMS B26000  GPCIPL STP DIAGNOSE INSTRUCTIONS            020400AH
*  01/25/88 ^ew-SMS B26501  GPCIPL AP101S DSE CHANGES                   020500AH
*  01/25/88 ^ex-SMS B26500  GPCIPL AP101B CODE DELETION                 020600AH
*  06/12/87 ^ew-SMS B06570  ROS PARITY INTERRUPT CODE                   020700AH
*  06/12/87 ^ew-SMS B06569  STP CYCLE COUNT                             020800AH
*  06/12/87 ^ex-SMS B06568  PASS LOAD I-FAIL LIGHT                      020900AH
*  06/20/86 ^ew-SMS BO6553  GPCIPL MOD AP101S UPGRADE                   021000AH
*  06/20/85 ^ey-SMS B06547  GENERIC STP                                 021100AH
*  03/22/85 ^ev-SMS B06545  TFL LOCATION MASS MEMORY CHANGES            021200AH
*  03/22/85 ^ey-SMS B06539  GPCIPL MACHINE INDEPENDENCE SOFTWARE        021300AH
*  03/22/85 ^ey-SMS B06536  STP IOP TEST ERROR                          021400AH
*  03/22/85 ^ev-SMS B06534  GPCIPL MENU LOAD FIX                        021500AH
*  03/22/85 ^ev-SMS B06533  STP SAVE ENVIRONMENT                        021600AH
*  03/22/85 ^ev-SMS B06531A PURGE/STP OPERATIONS                        021700AH
*  03/22/85 ^ev-SMS B06530  UNPROTECTED JOB TABLE                       021800AH
*  03/22/85 ^ev-SMS B06528  ICC POLLING (BUS 5)                         021900AH
*  03/22/85 ^ev-SMS B06527  136 HW DOWNLIST BUFFER                      022000AH
*  03/22/85 ^ev-SMS B06520  SOURCE COMMENT UPDATE                       022100AH
*  03/22/85 ^ev-SMS B06515A INVALID MMU TRANS TABLE CONTENT             022200AH
*  03/22/85 ^ev-SMS B06507A REQUIRED LABELS FOR PATCHING GPCIPL         022300AH
*  03/12/82 ___-SMS G105 DEU/GPC/MMU MEMORY PURGE                       022400AH
*  01/28/82 ^ez-SMS G101                                                022500AH
*  10/07/81 ^ez-SMS G103                                                022600AH
*  08/14/81 ^ez-SMS G095, G096, G097, G099                              022700AH
*  04/28/81 ^fa-SMS G094, G093, G091                                    022800AH
*  01/15/81 ^ez-SOURCE CORRECTION FOR G088                              022900AH
*  01/09/81 ^ez-SOURCE CORRECTION FOR G088                              023000AH
*  11/17/80 ^ew-SMS G084 DEU BITE ERROR INFORMATION                     023100AH
*  11/13/80 ^ew-SMS G087 MMU LOADBLOCK CHECKSUM                         023200AH
*           ^i -SMS G088 MISSING STP TESTS                              023300AH
*  11/07/80 ^ew-SMS G083 CORRECT SSL CHECKSUM                           023400AH
*           ^ew-SMS G086 CHG STP MEM PWR SWITCH LIMITS TO 19 +6/-6      023500AH
*   6/13/80 ^fa-SMS G082 HISAM CHECKSUM ERROR                           023600AH
*   5/21/80 ^fa-SMS G080 IMU CKPT INHIBIT                               023700AH
*   5/02/80 ^fa-SMS G075, G076                                          023800AH
*   3/21/80 ^fa-SMS G062, G069, G070, G072                              023900AH
*   3/20/80 ^fa-SMS G071, G073                                          024000AH
*   3/14/80 ^fa-SMS G068 DEU CRITICAL FMTS NOT RELOADED FOLLOWING DEU   024100AH
*               SASTP RESUME. DELETED SMS G050A.                        024200AH
*               SMS G067 IPL DEFAULT LOAD ENHANCEMENT                   024300AH
*   1/31/80 ^fa-ADD COMMENTS                                            024400AH
*   1/25/80 ^fa-DELETE LINES FOR G057                                   024500AH
*  12/11/79 ^fa-SMS G064 LOSS OF ELAPSED TIME FOR MEMORY PAGE FAILURE   024600AH
*               SMS G049 FAILURE TO RECOVER FROM STP ERROR              024700AH
*               ADD INTERRUPT CODE RESPONSE                             024800AH
*  11/29/79 ^fa-SMS G061 DELETE SCRUNCH TBL FROM DCP IN CM4BLD          024900AH
*           ^fa-SMS G063 CORRECT CLOCK RESTORE IN FAILEXEC              025000AH
*  11/02/79 ^fa-MINOR CHGS MADE TO COMMENTS FOR SMS G056                025100AH
*  10/31/79 ^fa-UPDATE ERROR MACRO TO OUTPUT SVCXXX LABEL ON SVC'S      025200AH
*  10/30/79 ^fa-SMS G056, AND ADD DEU HDR WD DESC.                      025300AH
*  10/29/79 ^fa-SMS G043A, G044, G045, G050A, G053, G054 & G057         025400AH
*               ADD PCM BITE DESC.                                      025500AH
*   7/18/79 ^fa-SMS G040 ADD RECOVERY IN HISAM FOR PARITY ERRORS        025600AH
*   7/17/79 ^fa-SMS G038 CMPR BFS MMU ADR IN LOADTBL TO MMD PHASE TBL   025700AH
*   7/13/79 ^fa-SMS G036 CHG PCM BCE PGM "BCEPCM5" TO OUTPUT 128 WDS    025800AH
*   7/10/79 ^fb-CORRECT GPC ID IN DOWNLIST                              025900AH
*   7/10/79 ^fa-ADD FRAME WORD TO DOWNLIST BUFFER IN "COMDATA"          026000AH
*   7/09/79 ^fb-SMS G037 MOVE ERROR ENVIRONMENT ORIGIN TO 8000          026100AH
*           ^fb-SMS G039 IMPROVED VERSION OF SVC HANDLER                026200AH
*           ^fb-SMS G033 GO-TO-WAIT ON WILD BRANCH DETECT               026300AH
*   7/06/79 ^fa-SMS G035 CHG PCM BCE PGM "BCEPCM1" TO OUTPUT 128 WDS    026400AH
*           ^fb-CORRECT CODE TO REMOVE ASSEM. ERROR MESSAGES            026500AH
*   7/05/79 ^fa-SMS G028, NO-OP MMU DIRECTORY PHASE # CHECK             026600AH
*   6/26/79 ^fa-MADE CORRECTIONS TO SMS G030                            026700AH
*   6/22/79 ^fa-SMS G030,G031,G032. RESERVE PATCH AREA IN COMDATA.      026800AH
*               ADD MSG211 'ILLEGAL IO TERM A (DIA BIT 12=1)'--SMS G034 026900AH
*   6/19/79 ^fa-SMS G029, CORRECT HISAM DUMP                            027000AH
* TO NO-OP LOADING OF THE WATCHDOG TIMER                                027200AH
*                                                                       027300AH
* LOADWDOG+1=8000                                                       027400AH
*                                                                       027500AH
* ADR OF OFT CRITICAL FORMATS IN THE DEU=0100                           027700AH
* DEU OPERATIONAL TEST PROGRAM (OTP) COMMANDS:                          027900AH
*  ITEM A EXEC (RE-INITIALIZE DCP)  ITEM D+XXXX EXEC (DISPLAY DEU MEM)  028000AH
*  ITEM B EXEC (BITE REG DISPLAY)   ITEM E EXEC (EXIT OTP)              028100AH
*  ITEM C EXEC (CLEAR BITE REGS)    ITEM F+XX EXEC (FORMAT PREVIEW)     028200AH
*                                                  (XX=01-30)           028300AH
* DEU SASTP COMMANDS:                                                   028500AH
*  ITEM 1 EXEC (DRIVES AN ASTERISK ON SASTP DISPLAY WHILE FORCING A     028600AH
*               BITE ERROR DURING FORCED BITE ERROR TEST.)              028700AH
*  ITEM 2 EXEC (RESET CRITICAL BITE STATUS REGS)                        028800AH
*  DIA     BIT 0=HALT CMD                    (FROM PANEL)               029000AH
*              1=STBY CMD                    (FROM PANEL)               029100AH
*              2=RUN  CMD                    (FROM PANEL)               029200AH
*              3=IPL                                                    029300AH
*              4=MM1 IPL                     (FROM PANEL)               029400AH
*              5=MM2 IPL                     (FROM PANEL)               029500AH
*              6=MM1 READY                   (FROM MM1)                 029600AH
*              7=MM2 READY                   (FROM MM2)                 029700AH
*              8=BFS RUN N+1                 (FROM BFS GPC)             029800AH
*              9=BFS RUN N+2                 (FROM BFS GPC)             029900AH
*             10=BFS RUN N+3                 (FROM BFS GPC)             030000AH
*             11=BFS RUN N+4                 (FROM BFS GPC)             030100AH
*             12=I/O TERM A                  (FROM HDWR=0)              030200AH
*             13=I/O TERM B                  (FROM PANEL OR CNTLR)      030300AH
*             14=SPARE                                                  030400AH
*             15=GPC MEMORY DUMP             (FROM PANEL)               030500AH
*             16=BFS SPARE N+1               (FROM BFS GPC)             030600AH
*             17=BFS SPARE N+2               (FROM BFS GPC)             030700AH
*             18=BFS SPARE N+3               (FROM BFS GPC)             030800AH
*             19=BFS SPARE N+4               (FROM BFS GPC)             030900AH
*             20=STBY N+1      FOR DECODE:     STATION ID (N=I)         031000AH
*             21=STBY N+2                                               031100AH
*             22=STBY N+3      STATION ID   N+1  N+2  N+3  N+4          031200AH
*             23=STBY N+4                                               031300AH
*             24=RUN  N+1              1     2    3    4    5           031400AH
*             25=RUN  N+2                                               031500AH
*             26=RUN  N+3              2     3    4    5    1           031600AH
*             27=RUN  N+4                                               031700AH
*             28=SYNC N+1              3     4    5    1    2           031800AH
*             29=SYNC N+2                                               031900AH
*             30=SYNC N+3              4     5    1    2    3           032000AH
*             31=SYNC N+4                                               032100AH
*                                      5     1    2    3    4           032200AH
*  DIB     BIT 0=STATION ID BIT 0  FOR DECODE: BIT 0 1 2 / STATION ID   032400AH
*              1=STATION ID BIT 1                  0 0 1           1    032500AH
*              2=STATION ID BIT 2                  0 1 0           2    032600AH
*                                                  0 1 1           3    032700AH
*                                                  1 0 0           4    032800AH
*                                                  1 0 1           5    032900AH
*              3=BFS ENGAGE A                (FROM CNTLR)               033000AH
*              4=BFS ENGAGE B                (FROM CNTLR)               033100AH
*              5=BFS ENGAGE C                (FROM CNTLR)               033200AH
*              6=BFS CRT A                   (FROM PANEL)               033300AH
*              7=BFS CRT B                   (FROM PANEL)               033400AH
*              8 THRU 17=SPARE                                          033500AH
*  DO      BIT 0 THRU  6=SPARE                                          033700AH
*              7=I/O ACTIVE TALKBACK         (TO PANEL)                 033800AH
*              8=SPARE                                                  033900AH
*              9=RUN(READY) TALKBACK         (TO PANEL)                 034000AH
*             10=SPARE                                                  034100AH
*             11=SPARE                                                  034200AH
*             12=MM1 RESET                   (TO MM1)                   034300AH
*             13=MM2 RESET                   (TO MM2)                   034400AH
*             14 THRU 19=SPARE                                          034500AH
*             20=STBY                        (PRIMARY INTER-GPC)        034600AH
*             21=SPARE                                                  034700AH
*             22=BFS RUN                     (BACKUP  INTER-GPC)        034800AH
*             23=SPARE                                                  034900AH
*             24=RUN                         (PRIMARY INTER-GPC)        035000AH
*             25=SPARE                                                  035100AH
*             26=BFS SPARE                   (BACKUP  INTER-GPC)        035200AH
*             27=SPARE                                                  035300AH
*             28=SYNC                        (PRIMARY INTER-GPC)        035400AH
*             29=SPARE                                                  035500AH
*             30=STATION ID SOURCE (HDWR)                               035600AH
*             31=IPL               (HDWR)                               035700AH
*  DRO     BIT 0=GPC FAIL INDICATOR                                     035900AH
*              1=INTERNAL GPC                                           036000AH
*              2=INTERNAL GPC                                           036100AH
*              3=GPC N+1 - GPC N FAILED VOTE (INPUT)                    036200AH
*              4=GPC N+2 - GPC N FAILED VOTE (INPUT)                    036300AH
*              5=GPC N+3 - GPC N FAILED VOTE (INPUT)                    036400AH
*              6=GPC N+4 - GPC N FAILED VOTE (INPUT)                    036500AH
*              7=GPC N - GPC N+1 FAILED VOTE                            036600AH
*              8=GPC N - GPC N+2 FAILED VOTE                            036700AH
*              9=GPC N - GPC N+3 FAILED VOTE                            036800AH
*             10=GPC N - GPC N+4 FAILED VOTE                            036900AH
*             11 THRU 31=INTERNAL GPC                                   037000AH
*        INTMCK RESPONSE (INTERRUPT = MACHINE CHECK)                    037300AH
* INTRPT CODE/IOP REG DESCRIPTION             PSW MASK (P=HELD PENDING) 037400AH
*        0002          DMA MEMORY MULTI-BIT             (IOP UNIT) 45   037600AH
*        0003          CPU MEMORY MULTI-BIT             (CPU UNIT) 45   037700AH
*        0005          CPU MICROSTORE PARITY            (CPU UNIT) 45   037800AH
*        0006          INTERRUPT PAGE FAULT             (CPU UNIT) 45   037900AH
*        0007          ENDOP TIMEOUT                    (CPU UNIT) 45   038000AH
*        0008          EA FAULT                         (CPU UNIT) 45   038100AH
*        0009          CPU CANNOT CONTINUE              (CPU UNIT) 45   038200AH
*  AL =  ADDRESSABILITY LOST (ALL CASES)                                038300AH
*------------------------------------------------------------------     038500AH
*        INTPCK RESPONSE (INTERRUPT = PROGRAM CHECK)                    038700AH
* INTRPT CODE/IOP REG DESCRIPTION             PSW MASK (P=HELD PENDING) 038800AH
*  AL    0000          CPU ILLEGAL OPERATION                            039000AH
*        0001          CPU PRIVILEGED INSTRUCTION                  47   039100AH
*        0002          INTERRUPT CODE INVALID                           039200AH
*        0003          INTERRUPT CODE INVALID                           039300AH
*        0004          CPU FIXED POINT OVERFLOW                    20   039400AH
*        0005          CPU SIGNIFICANCE                            23   039500AH
*        0006          INTERRUPT CODE INVALID                           039600AH
*  AL    0007          CPU STORE PROTECT VIOLATION                      039700AH
*        0008          NOT SUPPORTED BY HARDWARE                   22   039800AH
*        0009          CPU EXPONENT UNDERFLOW FLT PT OR CONVERT    22   039900AH
*        000A          CPU EXPONENT  OVERFLOW (CONVERT)                 040000AH
*        000B          CPU EXPONENT  OVERFLOW FLT PT                    040100AH
*        000C          CPU INVALID DIVIDE     FLT PT                    040200AH
*  AL =  ADDRESSABILITY LOST                                            040300AH
*------------------------------------------------------------------     040500AH
*        INTIMR RESPONSE (INTERRUPT = INSTRUCTION MONITOR)              040700AH
* INTRPT CODE/IOP REG DESCRIPTION             PSW MASK (P=HELD PENDING) 040800AH
*  AL    NONE          CPU INSTRUCTION PROTECT  SUPV MODE (47=0) & 34 P 041000AH
*  AL =  ADDRESSABILITY LOST (ALL CASES)                                041100AH
*------------------------------------------------------------------     041300AH
*        INTEX0 RESPONSE (INTERRUPT = EXTERNAL 0)                       041500AH
* INTRPT CODE/IOP REG DESCRIPTION             PSW MASK (P=HELD PENDING) 041600AH
*        NONE/A BIT 0  IOP WATCHDOG TIMER TIMEOUT                  35 P 041800AH
*        NONE/A BIT 1  IOP FAIL LATCH (RM VOTER)                   35 P 041900AH
*        NONE/A BIT 2  IOP C/M IDLE                                35 P 042000AH
*        NONE/A BIT 3  IOP ROS PARITY                              35 P 042100AH
*        NONE/A BIT 4  IOP FAULT (OSCILLATOR)                      35 P 042200AH
*------------------------------------------------------------------     042400AH
*        INTEX1 RESPONSE (INTERRUPT = EXTERNAL 1)                       042600AH
* INTRPT CODE/IOP REG DESCRIPTION             PSW MASK (P=HELD PENDING) 042700AH
*              B BIT                                                    042900AH
*              0 1 2                                                    043000AH
*              _ _ _                                                    043100AH
*        0000/ 0 0 0   NO ERROR                                    36 P 043200AH
*        0000/ 0 0 1   DEVICE OUT DATA                             36 P 043300AH
*        0000/ 0 1 0   LOCAL STORE R1, R2, R3 PARITY               36 P 043400AH
*        0000/ 0 1 1   FB DMA ADDR OR DATA PARITY                  36 P 043500AH
*        0000/ 1 0 0   MC QUEUE CONTROL PARITY                     36 P 043600AH
*        0000/ 1 0 1   MIA PARITY                                  36 P 043700AH
*        0000/ 1 1 0   DIAGNOSTIC PROCESSOR 25                     36 P 043800AH
*        0000/B BIT 4  IOP DMA QUEUE OVERFLOW (REQUEST > 64)       36 P 044000AH
*        0000/B BIT 5  IOP DMA TIMEOUT (IN PROCESS > 8 MICROSEC)   36 P 044100AH
*        0004          CPU DMA STORE PROTECT VIOLATION        45 & 36 P 044200AH
*        NOTE CPU INTRPT CAN HAVE 'SIMULTANEOUS' IOP INTRPT             044400AH
*        NOTE ADR 0087 SET 0 AT STARTUP & BEFORE INTEX1 UNMASK          044500AH
*------------------------------------------------------------------     044700AH
*        INTEX3 RESPONSE (INTERRUPT = EXTERNAL 3)                       044900AH
* INTRPT CODE/IOP REG DESCRIPTION             PSW MASK (P=HELD PENDING) 045000AH
*        NONE              SPARE                                   38 P 045200AH
*------------------------------------------------------------------     045400AH
*        INTEX4 RESPONSE (INTERRUPT = EXTERNAL 4)                       045600AH
* INTRPT CODE/IOP REG DESCRIPTION             PSW MASK (P=HELD PENDING) 045700AH
*        NONE              SPARE                                   39 P 045900AH
********************************************************************    046100AH
*                                                                  *    046200AH
*     DESCRIPTION OF STANDARD HEADER WORD ON DEU RESPONSES         *    046300AH
*        BIT           DESCRIPTION                                 *    046400AH
*      ______          ____________________                        *    046500AH
*         0            MESSAGE TYPE                                *    046600AH
*         1               "     "                                  *    046700AH
*         2               "     "                                  *    046800AH
*         3               "     "                                  *    046900AH
*                                                                  *    047000AH
*         4            'MSG RESET' MESSAGE                         *    047100AH
*         5            DEU ID                                      *    047200AH
*         6             "  "                                       *    047300AH
*         7             "  "                                       *    047400AH
*                                                                  *    047500AH
*         8            MAJOR FUNCTION SWITCH (00=PYLD  10=SM)      *    047600AH
*         9              "     "        "    (01=GN&C  11=NOT USED)*    047700AH
*        10            'ACK' MESSAGE                               *    047800AH
*        11            FREEZE                                      *    047900AH
*                                                                  *    048000AH
*        12            KYBD MSG PRESENT (NEW MSG)                  *    048100AH
*        13            DEU SELF-TEST IN PROGRESS                   *    048200AH
*        14            CRITICAL BITE STATUS PRESENT                *    048300AH
*        15            INITIALIZATION REQUIRED                     *    048400AH
*                                                                  *    048500AH
********************************************************************    048600AH
********************************************************************    048800AH
*                                                                  *    048900AH
*     HARDWARE BITE REGISTER 1 BIT DEFINITION                      *    049000AH
*        BIT             ERROR CONDITION                           *    049100AH
*      ______          ____________________                        *    049200AH
*         0            LOGIC 1                                     *    049300AH
*         1            IPL HAS BEEN PERFORMED                      *    049400AH
*         2            IPL ERROR                                   *    049500AH
*         3            IPL CIRCUIT CHECK ERROR                     *    049600AH
*                                                                  *    049700AH
*         4            SYMBOL GENERATOR INTENSITY PARITY ERROR     *    049800AH
*         5            SYMBOL GENERATOR SINE-COSINE PARITY ERROR   *    049900AH
*         6            SYMBOL GENERATOR ACTIVE                     *    050000AH
*         7            SYMBOL GENERATOR CHARACTER PARTIY ERROR     *    050100AH
*                                                                  *    050200AH
*         8            OSCILLATOR ERROR                            *    050300AH
*         9          * SYMBOL GENERATOR ZERO DEFLECTION TEST ERROR *    050400AH
*        10          * SYMBOL GENERATOR NON-ZERO DEFLECTION TST ERR*    050500AH
*        11          * SYMBOL GENERATOR ANALOG PULSE TEST ERROR    *    050600AH
*                                                                  *    050700AH
*        12            CIRCLE OSCILLATOR ERROR                     *    050800AH
*        13          * SYMBOL GENERATOR ANALOG TEST ERROR (OR)     *    050900AH
*        14          * SYMBOL GENERATOR DISPLAY WRAP ERROR         *    051000AH
*        15            SYMBOL GENERATOR REFRESH ERROR              *    051100AH
*                                                                  *    051200AH
*                    * VALID DURING SASTP ONLY                     *    051300AH
*                                                                  *    051400AH
********************************************************************    051500AH
********************************************************************    051700AH
*                                                                  *    051800AH
*     HARDWARE BITE REGISTERS 2 & 3 BIT DEFINITION                 *    051900AH
*        BIT             ERROR CONDITION                           *    052000AH
*       _____          ____________________                        *    052100AH
*         0            LOGIC 1                                     *    052200AH
*         1            DU DEFLECTION STATUS (BSR 3)                *    052300AH
*         2            DU VIDEO STATUS (BSR 3)                     *    052400AH
*         3            DU PHOSPHOR PROTECT STATUS (BSR 3)          *    052500AH
*                                                                  *    052600AH
*         4            SPARE                                       *    052700AH
*         5            DU FILAMENT CURRENT STATUS (BSR 3)          *    052800AH
*         6            DU TEMPERATURE STATUS (BSR 3)               *    052900AH
*         7            CPU BITE SOFTWARE FAIL (BSR 2)              *    053000AH
*                                                                  *    053100AH
*         8            KEYBOARD CHANNEL A FAIL (BSR 2)             *    053200AH
*         9            KEYBOARD CHANNEL B FAIL (BSR 2)             *    053300AH
*        10            MIA ECHO CHECK ERROR (BSR 2)                *    053400AH
*        11            MIA PARITY ERROR (BSR 2)                    *    053500AH
*                                                                  *    053600AH
*        12            MIA MANCHESTER ERROR (BSR 2)                *    053700AH
*        13            MIA BIT COUNT ERROR (BSR 2)                 *    053800AH
*        14            MIA COMMAND ERROR (BSR 2)                   *    053900AH
*        15            DU POWER SUPPLY STATUS (BSR 3)              *    054000AH
*                                                                  *    054100AH
********************************************************************    054200AH
********************************************************************    054400AH
*                                                                  *    054500AH
*     SOFTWARE STATUS REGISTER BIT DEFINITION                      *    054600AH
*        BIT             ERROR CONDITION                           *    054700AH
*       _____          _____________________                       *    054800AH
*         0            DISPLAY/FORMAT DATA FILL ERROR              *    054900AH
*         1            SPARE                                       *    055000AH
*         2            INITIALIZATION PERFORMED                    *    055100AH
*         3            INVALID FILL/DUMP WORD COUNT                *    055200AH
*                                                                  *    055300AH
*         4            MIA WRAP WORD CHECK                         *    055400AH
*         5            COMMAND OVERLOAD                            *    055500AH
*         6            SPARE                                       *    055600AH
*         7            CPU MEMORY PARITY ERROR                     *    055700AH
*                                                                  *    055800AH
*         8            SPARE                                       *    055900AH
*         9            INVALID MESSAGE RECEIVED                    *    056000AH
*        10          * RIPPLE TEST ERROR                           *    056100AH
*        11            CHECK SUM ERROR                             *    056200AH
*                                                                  *    056300AH
*        12            INVALID FILL/DUMP DATA ADDRESS              *    056400AH
*        13            RECEIVED MESSAGE INCOMPLETE                 *    056500AH
*        14            CPU SELF-TEST ERROR                         *    056600AH
*        15            INCOMPLETE DEU TRANSMISSION                 *    056700AH
*                                                                  *    056800AH
*                    * VALID DURING SASTP ONLY                     *    056900AH
*                                                                  *    057000AH
********************************************************************    057100AH
********************************************************************    057300AH
*                                                                       057400AH
* BIT  0=0=PCM PWR HAS DROPPED OUT SINCE LAST BSR RESET                 057500AH
*      1=0=PCM OPERATING ON INTERNAL CLOCK (1=4.608 MHZ MTU INPUT)      057600AH
*      2=0=FETCH PROM PARITY ERROR                                      057700AH
*      3=0=128 KBPS TLM DOWNLINK ERROR                                  057800AH
*-----------------------------------------------------------------      057900AH
*      4=0= 64 KBPS TLM DOWNLINK ERROR                                  058000AH
*      5=0=128 KBPS TLM RAM OR PROM PARITY ERROR                        058100AH
*      6=0=128 KBPS TLM COUNTER ERROR                                   058200AH
*      7=0= 64 KBPS TLM RAM PARITY OR TLM COUNTER ERROR                 058300AH
*-----------------------------------------------------------------      058400AH
*      8=0=128 KBPS RECORDER DATA OUTPUT FAILED                         058500AH
*      9=0=INPUT DATA INVALID                                           058600AH
*     10=0=OI  RAM PARITY ERROR                                         058700AH
*     11=0=PDI RAM PARITY ERROR                                         058800AH
*-----------------------------------------------------------------      058900AH
*     12=0=TOGGLE BUFFER PARITY ERROR                                   059000AH
*     13=0=NO RESPONSE DETECTED ON COMPUTER BUS                         059100AH
*     14=0=MDM OR PDI NO RESPONSE                                       059200AH
*     15=0=128 KBPS FIXED FORMAT (1=PROGRAMMABLE FORMAT)                059300AH
*                                                                       059400AH
********************************************************************    059500AH
         COPY  MACSMITH                                                         
         COPY  PSA                                                              
         COPY  HISAM                                                            
         COPY  FAILEXEC                                                         
         COPY  STM0                                                             
         COPY  STPMEM                                                           
         COPY  INTHNDLR                                                         
         COPY  STM1                                                             
         COPY  STM2                                                             
         COPY  STM3                                                             
         COPY  STPDATA                                                          
         COPY  SVCALT                                                           
         COPY  INITSTP                                                          
         COPY  REALEXEC                                                         
         COPY  GPCRTOPT                                                         
         COPY  COMDATA                                                          
*        PRINT OFF                                                      061900AH
         COPY  GENLINES                                                         
*        PRINT ON                                                       062100AH
         END                                                            062300AH
