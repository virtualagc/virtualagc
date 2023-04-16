*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    MONITOR.bal
*/ Purpose:     This is a part of the "Monitor" of the HAL/S-FC 
*/              compiler program.
*/ Reference:   "HAL/S Compiler Functional Specification", 
*/              section 2.1.1.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-07 RSB  Removed a garbage character (0x00)
*/                              that was present when I received the
*/                              file.  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ are from the Virtual AGC Project.
*/              Comments beginning merely with * are from the original 
*/              Space Shuttle development.

**********************************************************************
*                                                                    *
* REVISION HISTORY                                                   *
*                                                                    *
* DATE     WHO   RLS     DR/CR#         DESCRIPTION                  *
* ----     ---   ---     -------        -----------                  *
*                                                                    *
* 05/27/92 PMA   7V0  DR101925   ADDED HEADER. CHANGED OUTPUT3 DCB   *
*                                TO REFLECT PDS VERSUS SEQUENTIAL    *
*                                FOR BFS ONLY!                       *
*                                                                    *
**********************************************************************
         MACRO                                                          00000100
         DCBLIST                                                        00000200
         GBLA  &INPUTS,&OUTPUTS                                         00000210
         GBLB  &XPL                                                     00000220
         LCLA  &I,&K                                                    00000300
         LCLC  &C,&CSECT1,&CSECT2                                       00000400
&C       SETC  '&SYSECT'                                                00000500
&CSECT1  SETC  'INWORK'                                                 00000600
&CSECT2  SETC  'OUTWORK'                                                00000700
         AIF   ('&SYSLIST(1)' EQ 'INPUT').INOK                          00000800
         MNOTE 1,'FIRST ARGUMENT MUST INDICATE INPUT DCBS'              00000900
         MEXIT                                                          00001000
.INOK    ANOP                                                           00001100
GETDCBS  DS    0F                                                       00001200
&I       SETA  2                                                        00001300
&K       SETA  0                                                        00001310
.LOOP1   ANOP                                                           00001400
         AIF   ('&SYSLIST(&I,2)' EQ '').GENOUT                          00001500
         AIF   (&K GT &INPUTS).INCR1                                    00001510
         DC    A(&SYSLIST(&I,1))  INPUT DCB ADDR                        00001600
&CSECT1  CSECT                                                          00001700
         AIF   ('&SYSLIST(&I,2)' EQ 'PO').INPO                          00001800
         DC    A(0)           NO WORK AREA FOR PS                       00001900
         AGO   .INCR1                                                   00002000
.INPO    ANOP                                                           00002100
         DC    A(IWORK&I)     INPUT PDS WORK AREA ADDR                  00002200
.INCR1   ANOP                                                           00002300
&C       CSECT                                                          00002400
&I       SETA  &I+1                                                     00002500
&K       SETA  &K+1                                                     00002510
         AGO   .LOOP1                                                   00002600
.GENOUT  ANOP                                                           00002700
         AIF   ('&SYSLIST(&I)' EQ 'OUTPUT').OUTOK                       00002800
         MNOTE 1,'OUTPUT DCB INDICATOR MISSING'                         00002900
         MEXIT                                                          00003000
.OUTOK   ANOP                                                           00003100
PUTDCBS  DS    0F                                                       00003200
&K       SETA  0                                                        00003210
.LOOP2   ANOP                                                           00003300
&I       SETA  &I+1                                                     00003400
         AIF   (&I GT N'&SYSLIST).GENTBLS                               00003500
         AIF   (&K GT &OUTPUTS).INCR2                                   00003510
         DC    A(&SYSLIST(&I,1)) OUTPUT DCB ADDR                        00003600
&CSECT2  CSECT                                                          00003700
         AIF   ('&SYSLIST(&I,2)' EQ 'PO').OUTPO                         00003800
         DC    A(0)           NO WORK AREA FOR PS                       00003900
         AGO   .INCR2                                                   00004000
.OUTPO   ANOP                                                           00004100
         DC    A(OWORK&I)  OUTPUT PDS WORK AREA ADDR                    00004200
.INCR2   ANOP                                                           00004300
&K       SETA  &K+1                                                     00004310
&C       CSECT                                                          00004400
         AGO   .LOOP2                                                   00004500
.GENTBLS ANOP                                                           00004600
&I       SETA  1                                                        00004700
&K       SETA  0                                                        00004710
&CSECT1  CSECT                                                          00004800
.LOOP3   ANOP                                                           00004900
&I       SETA  &I+1                                                     00005000
         AIF   ('&SYSLIST(&I,2)' EQ '').GENWORK                         00005100
         AIF   ('&SYSLIST(&I,2)' NE 'PO').INCR3                         00005200
         AIF   (&K GT &INPUTS).INCR3                                    00005210
IWORK&I  DC    3F'0'         INPUT PDS WORK AREA                        00005300
         AIF   (&XPL).INCR3                                             00005310
         DC    2CL8' '        ORIGINAL/CURRENT DDNAMES                  00005320
.INCR3   ANOP                                                           00005330
&K       SETA  &K+1                                                     00005340
         AGO   .LOOP3                                                   00005400
.GENWORK ANOP                                                           00005500
&CSECT2  CSECT                                                          00005600
&K       SETA  0                                                        00005610
.LOOP4   ANOP                                                           00005700
&I       SETA  &I+1                                                     00005800
         AIF   (&I GT N'&SYSLIST).ENDIT                                 00005900
         AIF   ('&SYSLIST(&I,2)' NE 'PO').INCR4                         00006000
         AIF   (&K GT &OUTPUTS).INCR4                                   00006010
OWORK&I  DC    2F'0'         OUTPUT PDS WORK AREA                       00006100
         AIF   (&XPL).INCR4                                             00006110
         DC    CL8' '         ASSOCIATED DDNAME                         00006120
.INCR4   ANOP                                                           00006130
&K       SETA  &K+1                                                     00006140
         AGO   .LOOP4                                                   00006200
.ENDIT   ANOP                                                           00006300
&C       CSECT                                                          00006400
         MEND                                                           00006500
         SPACE 3                                                        00006505
         MACRO                                                          00006510
         SPARM                                                          00006515
         GBLB  &COMP,&XPL,&XPLE,&PA,&BF                                 00006520
&COMP    SETB  ('&SYSPARM' NE 'DASS')                                   00006525
&XPL     SETB  ('&SYSPARM' EQ 'XPL')                                    00006527
&PA      SETB  ('&SYSPARM' EQ 'PASS') ** DR101925 - P. ANSLEY, 5/22/92  00006527
&BF      SETB  ('&SYSPARM' EQ 'BFS') ** DR101925 - P. ANSLEY, 5/22/92
         AIF   ('&SYSPARM' NE 'XPLE').SP1                               00006530
&XPL     SETB  1                                                        00006540
&XPLE    SETB  1                                                        00006550
.SP1     ANOP                                                           00006560
         MEND                                                           00006570
XMON     TITLE 'XPL LINKING SUBMONITOR FOR THE HAL/S COMPILER'          00006600
         SPACE 2                                                        00006700
*********************************************************************** 00006800
*                                                                     * 00006900
*                                                                     * 00007000
*                                                                     * 00007100
*        XPLSM    SUBMONITOR FOR THE XPL COMPILER GENERATOR SYSTEM    * 00007200
*                                                                     * 00007300
*                                                                     * 00007400
*                                  DAVID B. WORTMAN                   * 00007500
*                                  STANFORD UNIVERSITY                * 00007600
*                                  MARCH  1969                        * 00007700
*                                                                     * 00007800
*        MODIFIED BY INTERMETRICS, INC. DURING DEVELOPMENT OF THE     * 00007900
*        HAL PROGRAMMING SYSTEM                                       * 00008000
*                                                                     * 00008100
*********************************************************************** 00008200
         EJECT                                                          00008300
         SPACE 1                                                        00008400
*********************************************************************** 00008500
*                                                                     * 00008600
*                                                                     * 00008700
*                                                                     * 00008800
*        DEFINE PARAMETRIC CONSTANTS FOR XPLSM                        * 00008900
*                                                                     * 00009000
*                                                                     * 00009100
*********************************************************************** 00009200
         SPACE 1                                                        00009300
         GBLA  &INPUTS             NUMBER OF INPUT FILES                00009400
         GBLA  &OUTPUTS            NUMBER OF OUTPUT FILES               00009500
         GBLA  &FILES              NUMBER OF DIRECT ACCESS FILES        00009600
         GBLA  &MONREQS            NUMBER OF 'MONITOR' REQUESTS         00009700
         GBLB  &COMP               1--> MONITOR FOR COMPILER;0 FOR DASS 00009710
         GBLB  &XPL           1--> MONITOR FOR XPL COMPILER; 0 FOR HAL  00009720
         GBLB  &XPLE                1--> MONITOR FOR XPLE COMPILER      00009730
         LCLA  &I                  VARIABLE FOR ITERATION LOOPS         00009800
         SPACE 5                                                        00010100
IOPACK   CSECT                                                          00010200
         SPARM                                                          00010205
         SPACE 2                                                        00010300
         AIF   (NOT &XPL).XX1                                           00010310
&INPUTS  SETA  4                   INPUT(I),   I = 0,1,2,3...           00010320
         SPACE 1                                                        00010330
         AIF   (&XPLE).XE1                                              00010340
&OUTPUTS SETA  8                   OUTPUT(I),  I = 0,1,2,3...           00010350
         AGO   .XE2                                                     00010360
.XE1     ANOP                                                           00010370
&OUTPUTS SETA  14                  OUTPUT(I),  I = 0,1,2,3...           00010380
.XE2     ANOP                                                           00010390
         SPACE 1                                                        00010400
&FILES   SETA  4                   FILE(I,*),  I = 1,2,3,4              00010410
         AGO   .QQ2                                                     00010420
.XX1     AIF   (&COMP).QQ1                                              00010430
&INPUTS  SETA  9                   INPUT(I),   I = 0,1,2,3...           00010440
         SPACE 1                                                        00010500
&OUTPUTS SETA  9                   OUTPUT(I),  I = 0,1,2,3...           00010600
         SPACE 1                                                        00010700
&FILES   SETA  3                  FILE(I,*),  I = 1,2,3                 00010710
         AGO   .QQ2                                                     00010715
.QQ1     ANOP                                                           00010720
&INPUTS  SETA  11                 INPUT(I),   I = 0,1,2,3...            00010730
         SPACE 1                                                        00010740
&OUTPUTS SETA  9                   OUTPPUT(I), I = 0,1,2,3...           00010750
         SPACE 1                                                        00010760
&FILES   SETA  9                  FILE(I,*),  I=1,2,3,4,5,6,7,8,9       00010800
.QQ2     ANOP                                                           00010810
         SPACE                                                          00010900
&MONREQS SETA  34                 NUM REQUESTS ACCEPTED BY 'MONITOR'    00011000
*                                  FUNCTION OF XPL                      00011100
         SPACE 1                                                        00011200
*********************************************************************** 00011300
*                                                                     * 00011400
*                                                                     * 00011500
*        FILEBYTS DETERMINES THE BLOCKSIZE FOR DIRECT ACCESS FILE     * 00011600
*        I/O.  IT SHOULD BE EQUAL TO THE VALUE OF THE LITERAL         * 00011700
*        CONSTANT 'DISKBYTES' IN THE XCOM COMPILER FOR COMPILATION    * 00011800
*        TO WORK SUCCESSFULLY.  THE VALUE OF FILEBYTS WHICH IS        * 00011900
*        ASSEMBLED IN MAY BE OVERIDDEN BY THE 'FILE=NNNN' PARAMETER   * 00012000
*        ON THE OS/360 EXEC CARD.                                     * 00012100
*                                                                     * 00012200
*                                                                     * 00012300
*                                                                     * 00012400
*        DEVICE       ALLOWABLE RANGE         SUGGESTED VALUE         * 00012500
*                                                                     * 00012600
*        2311      80 <= FILEBYTS <= 3624        3600                 * 00012700
*                                                                     * 00012800
*        2314      80 <= FILEBYTS <= 7294        7200                 * 00012900
*                                                                     * 00013000
*        2321      80 <= FILEBYTS <= 2000        2000                 * 00013100
*                                                                     * 00013200
*                                                                     * 00013300
*        LARGER VALUES MAY BE USED FOR FILEBYTS IF THE SUBMONITOR     * 00013400
*        IS REASSEMBLED WITH  RECFM=FT  SPECIFIED IN THE DCBS FOR     * 00013500
*        THE DIRECT ACCESS FILES.                                     * 00013600
*                                                                     * 00013700
*                                                                     * 00013800
*********************************************************************** 00013900
         SPACE 2                                                        00014000
FILEBYTS EQU   7200                2314 DISKS                           00014100
         SPACE 2                                                        00014200
*********************************************************************** 00014300
*                                                                     * 00014400
*                                                                     * 00014500
*        BLKSIZE DEFAULT FOR SOME INPUT AND OUTPUT FILES.  SEE THE    * 00014600
*        EXIT LIST HANDLING ROUTINE GENXT.  SHOULD BE THE LARGEST     * 00014700
*        MULTIPLE OF 80 THAT IS LESS THAN OR EQUAL TO FILEBYTS        * 00014800
*                                                                     * 00014900
*********************************************************************** 00015000
         SPACE 2                                                        00015100
IOFBYTS  EQU   80*(FILEBYTS/80)                                         00015200
         SPACE 2                                                        00015300
*********************************************************************** 00015400
*                                                                     * 00015500
*                                                                     * 00015600
*        DEFINE THE REGISTERS USED TO PASS PARAMETERS TO THE          * 00015700
*        SUBMONITOR FROM THE XPL PROGRAM                              * 00015800
*                                                                     * 00015900
*                                                                     * 00016000
*********************************************************************** 00016100
         SPACE 2                                                        00016200
SVCODE   EQU   1                   CODE INDICATING SERVICE REQUESTED    00016300
         SPACE 1                                                        00016400
PARM1    EQU   0                   FIRST PARAMETER                      00016500
         SPACE 1                                                        00016600
PARM2    EQU   2                   SECOND PARAMETER                     00016700
         SPACE 1                                                        00016800
PARM3    EQU   3                   THIRD PARAMETER                      00016900
         SPACE 2                                                        00017000
*********************************************************************** 00017100
*                                                                     * 00017200
*                                                                     * 00017300
*        DEFINE THE SERVICE CODES USED BY THE XPL PROGRAM TO          * 00017400
*        INDICATE SERVICE REQUESTS TO THE SUBMONITOR                  * 00017500
*                                                                     * 00017600
*                                                                     * 00017700
*********************************************************************** 00017800
         SPACE 3                                                        00017900
GETC     EQU   4                   SEQUENTIAL INPUT                     00018000
         SPACE 1                                                        00018100
PUTC     EQU   8                   SEQUENTIAL OUTPUT                    00018200
         SPACE 1                                                        00018300
LINENUM  EQU   12                  LINE NUMBER REQUEST                  00018400
         SPACE 1                                                        00018500
SETLNLIM EQU   16                  SET PAGE LINE LIMIT                  00018600
         SPACE 1                                                        00018700
EXDMP    EQU   20                  FORCE A CORE DUMP                    00018800
         SPACE 1                                                        00018900
GTIME    EQU   24                  RETURN TIME AND DATE                 00019000
         SPACE 1                                                        00019100
RSVD1    EQU   28                  (UNUSED)                             00019200
         SPACE 1                                                        00019300
RSVD2    EQU   32                  LINK                                 00019400
         SPACE 1                                                        00019500
RSVD3    EQU   36                  INTERRUPT_TRAP    (NOP IN XPLSM)     00019600
         SPACE 1                                                        00019700
RSVD4    EQU   40                  MONITOR                              00019800
         SPACE 1                                                        00019900
RSVD5    EQU   44                  (UNUSED)                             00020000
         SPACE 1                                                        00020100
RSVD6    EQU   48                  (UNUSED)                             00020200
         SPACE 1                                                        00020300
         SPACE 2                                                        00020400
*********************************************************************** 00020500
*                                                                     * 00020600
*        GENERATE THE SERVICE CODES FOR DIRECT ACCESS FILE I/O        * 00020700
*        BASED ON THE NUMBER OF FILES AVAILABLE  (&FILES)             * 00020800
*                                                                     * 00020900
*********************************************************************** 00021000
         SPACE 2                                                        00021100
FILEORG  EQU   RSVD6+4             ORIGIN FOR THE FILE SERVICE CODES    00021200
         SPACE 1                                                        00021300
&I       SETA  1                                                        00021400
.SC1     AIF   (&I GT &FILES).SC2                                       00021500
RD&I     EQU   FILEORG+8*(&I-1)    CODE FOR READING FILE&I              00021600
WRT&I    EQU   FILEORG+8*(&I-1)+4  CODE FOR WRITING FILE&I              00021700
&I       SETA  &I+1                                                     00021800
         AGO   .SC1                                                     00021900
.SC2     ANOP                                                           00022000
         SPACE 2                                                        00022100
ENDSERV  EQU   FILEORG+8*(&I-1)    1ST UNUSED SERVICE CODE              00022200
         SPACE 2                                                        00022300
*********************************************************************** 00022400
*                                                                     * 00022500
*                                                                     * 00022600
*        DEFINE REGISTER USAGE                                        * 00022700
*                                                                     * 00022800
*********************************************************************** 00022900
         SPACE 2                                                        00023000
RTN      EQU   3                   REGISTER CONTAINING COMPLETION       00023100
*                                  CODE RETURNED BY THE PROGRAM         00023200
         SPACE 1                                                        00023300
EBR      EQU   10                  BASE REGISTER USED DURING            00023400
*                                  INITIALIZATION                       00023500
         SPACE 1                                                        00023600
CBR      EQU   12                  LINKAGE REGISTER USED FOR CALLS      00023700
*                                  TO THE SUBMONITOR                    00023800
         SPACE 1                                                        00023900
SELF     EQU   15                  REGISTER THAT ALWAYS CONTAINS        00024000
*                                  THE ADDRESS OF THE SUBMONITOR        00024100
*                                  ENTRY POINT                          00024200
         SPACE 1                                                        00024300
*********************************************************************** 00024400
*                                                                     * 00024500
*        BIT CONSTANTS NEEDED FOR CONVERSING WITH OS/360              * 00024600
*                                                                     * 00024700
*********************************************************************** 00024800
         SPACE 2                                                        00024900
OPENBIT  EQU   B'00010000'         DCBOFLGS BIT INDICATING OPEN         00025000
*                                  SUCCESSFULLY COMPLETED               00025100
         SPACE 1                                                        00025200
TAPEBITS EQU   B'10000001'         BITS INDICATING A MAGNETIC TAPE      00025300
DASDBITS EQU   B'00100000'    BITS INDICATING A DASD DEVICE             00025350
         SPACE 1                                                        00025400
KEYLBIT  EQU   B'00000001'         BIT IN RECFM THAT INDICATES          00025500
*                                  KEYLEN WAS SET EXPLICITELY ZERO      00025600
         SPACE 1                                                        00025700
POBITS   EQU   B'00000010'    PARTITIONED ORGANIZATION BITS IN DCBDSORG 00025800
         SPACE 1                                                        00025900
SUBPOOL  EQU   22             SUBPOOL USED FOR ALL EXPLICIT GETMAINS    00026000
         SPACE 2                                                        00026100
*********************************************************************** 00026200
*                                                                     * 00026300
*        FLAG BITS USED TO CONTROL SUBMONITOR OPERATION               * 00026400
*                                                                     * 00026500
*********************************************************************** 00026600
         SPACE 2                                                        00026700
ALLBITS  EQU   B'11111111'         MASK                                 00026800
         SPACE 1                                                        00026900
L2REQST  EQU   B'10000000'    LISTING2 REQUESTED                        00027000
         SPACE 1                                                        00027100
SFILLBIT EQU   B'01000000'         1 CHARACTER OF FILL NEEDED BY        00027200
*                                  THE PUT ROUTINE                      00027300
         SPACE 1                                                        00027400
LFILLBIT EQU   B'00100000'         LONGER FILL NEEDED BY PUT ROUTINE    00027500
         SPACE 1                                                        00027600
OUTZBIT  EQU   B'00010000'         ON DURING OUTPUT(0) PROCESSING       00027700
         SPACE                                                          00027800
DUMPBIT  EQU   B'00001000'         GIVE A CORE DUMP FOR I/O ERRORS      00027900
         SPACE                                                          00028000
LINKBIT  EQU   B'00000100'         INDICATES THAT SUBSEQUENT XPL        00028100
*                                  PROGRAMS ARE TO BE LOADED IN THE     00028200
*                                  LINKING MODE                         00028300
         SPACE                                                          00028400
NOCBIT   EQU   B'00000010'         INDICATES NO COMMON STRINGS          00028500
         SPACE                                                          00028600
H2ACTIVE EQU   B'00000001'         SUBHEADING FLAG                      00028700
         SPACE 2                                                        00028800
*********************************************************************** 00028900
*                                                                     * 00029000
*                                                                     * 00029100
*              DEFINE ABEND CODES ISSUED BY THE SUBMONITOR            * 00029200
*                                                                     * 00029300
*********************************************************************** 00029400
         SPACE 2                                                        00029500
OPENABE  EQU   100                 UNABLE TO OPEN ONE OF THE FILES:     00029600
*                                  PROGRAM OR SYSPRINT                  00029700
         SPACE 1                                                        00029800
PGMEOD   EQU   200                 UNEXPECTED END OF FILE WHILE         00029900
*                                  READING IN THE XPL PROGRAM           00030000
         SPACE 1                                                        00030100
PGMERR   EQU   300                 SYNAD ERROR WHILE READING IN         00030200
*                                  THE XPL PROGRAM                      00030300
         SPACE 1                                                        00030400
COREABE  EQU   400                 XPL PROGRAM WON'T FIT IN             00030500
*                                  THE AMOUNT OF MEMORY AVAILABLE       00030600
         SPACE 1                                                        00030700
CODEABE  EQU   500                 INVALID SERVICE CODE FROM THE        00030800
*                                  XPL PROGRAM                          00030900
         SPACE                                                          00031000
PAGEABE  EQU   600                 PRINTED-PAGE LIMIT EXCEEDED          00031100
         SPACE                                                          00031200
COMABE   EQU   700                 LINKED PROGRAMS SPECIFIED DIFFERENT  00031300
*                                  SIZE COMMON AREAS                    00031400
         SPACE 1                                                        00031500
OUTSYND  EQU   800                 SYNAD ERROR ON OUTPUT FILE           00031600
         SPACE 1                                                        00031700
PFABE    EQU   900                 INVALID OUTPUT FILE SPECIFIED        00031800
         SPACE 1                                                        00031900
INSYND   EQU   1000                SYNAD ERROR ON INPUT FILE            00032000
         SPACE 1                                                        00032100
OVLAYABE EQU   1100                LINKING PROCESS OVERLAYED COMMON     00032200
*                                  STRING AREA                          00032300
         SPACE                                                          00032400
INEODAB  EQU   1200                END OF FILE ERROR ON INPUT FILE      00032500
         SPACE 1                                                        00032600
MOVEABE  EQU   1300                IMPOSSIBLE TO MOVE THE COMMON        00032700
*                                  STRINGS UP DURING LINKING            00032800
         SPACE                                                          00032900
GFABE    EQU   1400                INVALID INPUT FILE SPECIFIED         00033000
         SPACE 1                                                        00033100
MONBADRQ EQU   1500                UNKNOWN REQUEST BY 'MONITOR' FUNC    00033200
         SPACE                                                          00033300
MONBADF  EQU   1600                UNKNOWN DD IN 'MONITOR' REQUEST      00033400
         SPACE                                                          00033500
DIRABE   EQU   1700                DIRECTORY ERROR ON PDS               00033600
         SPACE                                                          00033700
OPDSSYND EQU   1800                SYNAD ERROR ON OUTPUT PDS FILE       00033800
         SPACE                                                          00033900
STOWABE  EQU   1900                INVALID MEMBER NAME SPECIFIED        00034000
         SPACE                                                          00034100
         SPACE                                                          00034200
FLSYND   EQU   2000                SYNAD ERROR ON DIRECT ACCESS FILE    00034300
         SPACE                                                          00034400
IPDSOERR EQU   2100                ATTEMPT TO READ FROM AN INPUT        00034500
*                                  PDS WITHOUT ISSUING THE "FIND"       00034600
*                                  MONITOR REQUEST FIRST                00034700
         SPACE 1                                                        00034800
FLEOD    EQU   2200                END OF FILE ERROR ON DIRECT          00034900
*                                  ACCESS FILE                          00035000
         SPACE                                                          00035100
FINDABE  EQU   2300                INVALID MEMBER TO BE FOUND           00035200
         SPACE                                                          00035300
IPDSSYND EQU   2400                SYNAD ERROR ON PDS INPUT FILE        00035400
         SPACE 1                                                        00035500
SETFABE  EQU   2500           FILE BLOCKING SPECIFICATION ERR           00035600
         SPACE 1                                                        00035610
OPTABE   EQU   2600           BAD NAME FOR OPTION PROCESSOR             00035620
         SPACE 1                                                        00035700
HALCOMPF EQU   3000 MON#9/10 ERROR OR MISALIGNED # 5                    00035800
         SPACE                                                          00035900
USERABE  EQU   4000                XPL PROGRAM CALLED EXIT TO FORCE     00036000
*                                  AN ABEND (AND A POSSIBLE CORE DUMP)  00036100
*                                                                       00036200
*        THE FOLLOWING OFFSETS ARE DEFINED FOR USE IN OBTAINING THE     00036300
*        VALUES OF TYPE2 OPTIONS NEEDED BY THIS MONITOR FROM THE        00036400
*        VALUES ARRAY GENERATED BY THE MONITOR OPTION PROCESSOR         00036500
LINCTLOC EQU   0                                                        00036600
PAGCTLOC EQU   4                                                        00036700
MINLOC   EQU   8                                                        00036800
MAXLOC   EQU   12                                                       00036810
FREELOC  EQU   16                                                       00036820
         EJECT                                                          00036900
         SPACE 5                                                        00037000
*********************************************************************** 00037100
*                                                                     * 00037200
*                                                                     * 00037300
*                                                                     * 00037400
*        SUBMONITOR  INITIALIZATION                                   * 00037500
*                                                                     * 00037600
*                                                                     * 00037700
*********************************************************************** 00037800
         SPACE 3                                                        00037900
         ENTRY XPLSM               WHERE OS ENTERS THE SUBMONITOR       00038000
         ENTRY  SAVE,SAVREG,PGMPARMS                                    00038100
         SPACE 2                                                        00038200
         DS    0F                                                       00038300
         USING *,15                                                     00038400
         SPACE 1                                                        00038500
XPLSM    SAVE  (14,12),T,*         SAVE ALL REGISTERS                   00038600
         ST    13,SAVE+4           SAVE RETURN POINTER                  00038700
         LA    15,SAVE             ADDRESS OF SUBMONITOR'S OS SAVE AREA 00038800
         ST    15,8(0,13)                                               00038900
         LR    13,15                                                    00039000
         USING SAVE,13                                                  00039100
         BALR  EBR,0               BASE ADDRESS FOR INITIALIZATION      00039200
         USING *,EBR                                                    00039300
BASE1    DS    0H                                                       00039400
         DROP  15                                                       00039500
         AIF   (&XPL).XX2     NO ALTERNATE DDNAMES                      00039510
*CHANGE THE DDNAMES OF THE DCBS IF DYNAMICALLY INVOKED                  00039600
         TM    0(1),X'80' NO DDLIST                                     00039700
         BO    NONAME                                                   00039800
         L     2,4(0,1) ADDRESS OF DDLIST PTR                           00039900
         LH    3,0(0,2)                                                 00040000
         LTR   3,3 LEN = 0                                              00040100
         BNH   NODDLIST                                                 00040200
         LA    8,8                                                      00040300
         LA    7,ALTDDLST     ADDRESS OF LIST OF DCBS                   00040400
         LA    6,(ALTEND-ALTDDLST)/4                                    00040500
DDLIST1  OC    2(8,2),2(2) ANY OVERRIDE                                 00040600
         BZ    DDLIST2                                                  00040700
         L     5,0(0,7)                                                 00040800
         USING IHADCB,5                                                 00040900
         MVC   DCBDDNAM,2(2) OVERRIDE DDNAME                            00040910
         DROP  5                                                        00040920
DDLIST2  SR    3,8                                                      00041000
         BNH   NODDLIST                                                 00041100
         AR    2,8                                                      00041200
         LA    7,4(0,7)                                                 00041300
         BCT   6,DDLIST1                                                00041400
         SPACE                                                          00041500
NODDLIST TM    4(1),X'80'     THIRD PARM FIELD?                         00043800
         BO    NONAME         NO                                        00043900
         L     2,8(0,1)       ADDR OF NAME FIELD PTR                    00044000
         ST    2,NAMEFLD      SAVE FOR LATER MONITOR CALL               00044600
NONAME   DC    0H'0'                                                    00044700
.XX2     ANOP                                                           00044710
         L     1,0(,1)             ADDRESS OF A POINTER TO THE PARM     00044800
*                                  FIELD OF THE OS EXEC CARD            00044900
         ST    1,CONTROL           SAVE ADDRESS FOR THE TRACE ROUTINE   00045000
         MVI   FLAGS,B'00000000'   RESET ALL FLAGS                      00045100
         LOAD  EPLOC=OPTNAME  LOAD MONITOR OPTION PROCESSOR             00045110
         L     1,CONTROL                                                00045115
         LR    15,0           ADDRESS OF PROCESSOR                      00045120
         BALR  14,15          CALL IT                                   00045130
         ST    1,VCONOPT      SAVE ADDR OF OPTIONS                      00045140
         LR    3,1                                                      00045150
         LR    4,3            REMEMBER FOR LATER                        00045500
         TM    3(3),X'01'     IS DUMP SET                               00045600
         BNO   OVER1          NO, SKIP LOCAL BIT                        00045700
         OI    FLAGS,DUMPBIT                                            00045800
OVER1    TM    3(3),X'02'      IS LISTING2 SET?                         00045900
         BNO   OVER2                                                    00046000
         OI    FLAGS,L2REQST                                            00046100
OVER2    L     3,16(0,3)      ADDR OF PRINTABLE VALUE OPTIONS           00046200
         L     11,LINCTLOC(0,3)      VALUE OF "LINECT="                 00046300
         ST    11,LINELIM                                               00046400
         LA    11,1(0,11)                                               00046500
         ST    11,LINECT      FORCE PAGE ON FIRST OUTPUT                00046600
         L     11,PAGCTLOC(0,3)      VALUE OF "PAGES="                  00046700
         ST    11,PAGECT                                                00046800
         L     11,MINLOC(0,3)  VALUE OF "MIN="                          00047000
         ST    11,COREMIN                                               00047100
         L     11,MAXLOC(0,3)  VALUE OF "MAX="                          00047200
         ST    11,COREMAX                                               00047300
         L     11,FREELOC(0,3) VALUE OF "FREE="                         00047400
         TM    3(4),X'04'     IS ALTER SET?                             00047410
         BNO   *+6            BR IF NO                                  00047420
         AR    11,11          IF YES, DOUBLE FREE                       00047430
         ST    11,FREEUP                                                00047500
         AIF   (&XPL).XX3     NO DYNAMIC DDNAMES                        00047510
         SR    2,2            ZERO INDEX                                00047550
         LA    6,&INPUTS+1    CYCLE THROUGH ALL INPUT FILES             00047600
         L     5,IWRKADDR     TO PDS WORK AREA CSECT                    00047650
PDSALT0  L     3,GETDCBS(2)   LOOK AT CORRESPONDING DCB                 00047700
         USING IHADCB,3                                                 00047750
         TM    DCBDSORG,POBITS IS THIS A PDS                            00047800
         BNO   PDSALT1        NO, TO NEXT ENTRY                         00047850
         L     4,0(2,5)       GET WORK AREA ADDRESS                     00047900
         USING IPDSDATA,4                                               00047950
         MVC   INDDNAM1,DCBDDNAM RECORD FOR FUTURE REFERENCE            00048000
         MVC   INDDNAM2,DCBDDNAM BY MONITOR(8)                          00048010
         DROP  3,4                                                      00048050
PDSALT1  LA    PARM2,4(,PARM2) TO NEXT DCB ENTRY                        00048100
         BCT   6,PDSALT0      THROUGH ENTIRE INPUT LIST                 00048150
         SR    2,2            ZERO INDEX                                00048160
         LA    6,&OUTPUTS+1    CYCLE THROUGH ALL OUTPUT FILES           00048170
         L     5,OWRKADDR     TO PDS WORK AREA CSECT                    00048180
PDSALT2  L     3,PUTDCBS(2)   LOOK AT CORRESPONDING DCB                 00048190
         USING IHADCB,3                                                 00048200
         TM    DCBDSORG,POBITS IS THIS A PDS                            00048210
         BNO   PDSALT3        NO, TO NEXT ENTRY                         00048220
         L     4,0(2,5)       GET WORK AREA ADDRESS                     00048230
         USING OPDSDATA,4                                               00048240
         MVC   DDNAME,DCBDDNAM RECORD FOR FUTURE REFERENCE              00048250
         DROP  3,4                                                      00048270
PDSALT3  LA    PARM2,4(,PARM2) TO NEXT DCB ENTRY                        00048280
         BCT   6,PDSALT2      THROUGH ENTIRE OUTPUT LIST                00048290
         SPIE  SPIEADDR,(12,13) TRAP FLT.PT UNDER/OVER FLOWS            00048600
         ST    1,OLDSPIE SAVE FOR FUTURE USE                            00049100
.XX3     ANOP                                                           00049200
         STIMER TASK,BINTVL=ONEHOUR START A TASK TIMER                  00049300
         SPACE 2                                                        00049400
*********************************************************************** 00049500
*                                                                     * 00049600
*                                                                     * 00049700
*        OPEN THE FILES  PROGRAM, SYSIN, AND SYSPRINT                 * 00049800
*                                                                     * 00049900
*********************************************************************** 00050000
         SPACE 2                                                        00050100
         OPEN  (INPUT0,(INPUT),OUTPUT0,(OUTPUT),PROGRAM,(INPUT))        00050200
         AIF   (&XPL).QQO                                               00050210
         AIF   (NOT &COMP).QQO                                          00050220
         OPEN  (INPUT5,(INPUT))                                         00050230
.QQO     ANOP                                                           00050240
         SPACE 1                                                        00050300
         TM    FLAGS,L2REQST  LISTING2 REQUESTED?                       00050400
         BZ    NOL2           BRANCH IF NOT                             00050500
         OPEN  (OUTPUT2,(OUTPUT))                                       00050600
         L     3,PUTDCBS+2*4  DCB ADDRESS                               00050700
         USING IHADCB,3                                                 00050800
         TM    DCBOFLGS,OPENBIT                                         00050900
         BZ    BADOPEN                                                  00051000
NOL2     EQU   *                                                        00051100
         L     3,PUTDCBS           ADDRESS OF DCB FOR OUTPUT0           00051500
         TM    DCBOFLGS,OPENBIT    CHECK FOR SUCCESSFUL OPENING         00051600
         BZ    BADOPEN             OUTPUT0 NOT OPENED SUCCESSFULLY      00051700
         L     3,PGMDCB            ADDRESS OF DCB FOR PROGRAM           00051800
         TM    DCBOFLGS,OPENBIT    TEST FOR SUCCESSFUL OPENING          00051900
         BNZ   OPENOK                                                   00052030
         DROP  3                                                        00052100
         SPACE 2                                                        00052200
BADOPEN  LA    1,OPENABE           ABEND BECAUSE FILES DIDN'T OPEN      00052300
*                                  PROPERLY                             00052400
         B     ABEND               GO TO ABEND ROUTINE                  00052500
         SPACE 2                                                        00052600
OPENOK   DS    0H                                                       00052700
         SPACE 2                                                        00052800
*********************************************************************** 00052900
*                                                                     * 00053000
*                                                                     * 00053100
*        NOW OBTAIN SPACE IN MEMORY FOR THE XPL PROGRAM AND ITS       * 00053200
*        FREE STRING AREA.  A GETMAIN IS ISSUED TO OBTAIN AS MUCH     * 00053300
*        MEMORY AS POSSIBLE WITHIN THE PARTITION.  THEN A FREEMAIN    * 00053400
*        IS ISSUED TO RETURN THE AMOUNT OF MEMORY SPECIFIED BY        * 00053500
*        THE VARIABLE 'FREEUP' TO OS/360 FOR USE AS WORK SPACE.       * 00053600
*        OS/360 NEEDS SPACE FOR FOR DYNAMICALLY CREATING BUFFERS      * 00053700
*        FOR THE SEQUENTIAL INPUT AND OUTPUT FILES AND FOR            * 00053800
*        OVERLAYING I/O ROUTINES.                                     * 00053900
*                                                                     * 00054000
*           THE AMOUNT OF CORE REQUESTED FROM OS/360 CAN BE ALTERED   * 00054100
*        WITH THE 'MAX=NNNN' AND 'MIN=MMMM' PARAMETERS TO THE         * 00054200
*        SUBMONITOR.  THE AMOUNT OF CORE RETURNED TO OS/360 CAN BE    * 00054300
*        ALTERED WITH THE 'FREE=NNNN' OR THE 'ALTER' PARAMETER        * 00054400
*                                                                     * 00054500
*                                                                     * 00054600
*        MEMORY REQUEST IS DEFINED BY THE CONTROL BLOCK STARTING AT   * 00054700
*        'COREREQ'.  THE DESCRIPTION OF THE MEMORY SPACE OBTAINED     * 00054800
*        IS PUT INTO THE CONTROL BLOCK STARTING AT 'ACORE'.           * 00054900
*                                                                     * 00055000
*                                                                     * 00055100
*********************************************************************** 00055200
         SPACE 2                                                        00055300
         GETMAIN VU,LA=COREREQ,A=ACORE,SP=SUBPOOL                       00055400
         SPACE 1                                                        00055500
         LM    1,2,ACORE           ADDRESS OF CORE OBTAINED TO R1       00055600
*                                  LENGTH OF CORE AREA TO R2            00055700
         AR    1,2                 ADDRESS OF TOP OF CORE AREA          00055800
         S     1,FREEUP            LESS AMOUNT TO BE RETURNED           00055900
         ST    1,CORETOP           ADDRESS OF TOP OF USABLE CORE        00056000
*                                  (BECOMES 'FREELIMIT')                00056100
         S     2,FREEUP            SUBTRACT AMOUNT RETURNED             00056200
         ST    2,CORESIZE          SIZE OF AVAILABLE SPACE              00056300
         L     3,FREEUP            AMOUNT TO GIVE BACK                  00056400
         SPACE 1                                                        00056500
         FREEMAIN R,LV=(3),A=(1),SP=SUBPOOL                             00056600
         SPACE 2                                                        00056700
*********************************************************************** 00056800
*                                                                     * 00056900
*                                                                     * 00057000
*        READ IN THE BINARY XPL PROGRAM AS SPECIFIED BY THE           * 00057100
*                                                                     * 00057200
*        //PROGRAM  DD  .....                                         * 00057300
*                                                                     * 00057400
*        CARD.  IT IS ASSUMED THAT THE BINARY PROGRAM IS IN STANDARD  * 00057500
*        XPL SYSTEM LINKING FORMAT.                                   * 00057600
*                                                                     * 00057700
*                                                                     * 00057800
*        THE FIRST RECORD OF THE BINARY PROGRAM SHOULD BE A BLOCK     * 00057900
*        OF INFORMATION DESCRIBING THE CONTENTS OF THE FILE.          * 00058000
*        THE FORMAT OF THIS BLOCK IS SHOWN IN THE SUBMONITOR DATA     * 00058100
*        AREA UNDER 'FILECTRL'.                                       * 00058200
*                                                                     * 00058300
*                                                                     * 00058400
*********************************************************************** 00058500
         SPACE 2                                                        00058600
         L     2,ACORE             ADDRESS OF START OF CORE AREA        00058700
         BAL   CBR,READPGM         READ IN 1ST RECORD                   00058800
         MVC   FILECTRL(52),0(2)   MOVE THE FCB                         00058900
         LR    7,2            GET FCB ADDR                              00058910
         AH    7,FLAGOFF      ADDRESSABILITY FOR FLAG                   00058915
         A     7,BYTSBLK FIX FOR DIFFERENT SIZE BLOCKS                  00058917
         TM    1(7),X'FF'     IS LENGTH SUPPLIED?                       00058920
         BO    NEWID          IF SO, USE IT                             00058925
         LR    7,2            FCB ADDR                                  00058930
         AH    7,IDOFFSET     DEFAULT PGMID LOC                         00058935
         A     7,BYTSBLK FIX FOR DIFFERENT SIZE BLOCKS                  00058937
         MVC   PGMID(10),0(7) IDDESC DEFAULTS TO LENGTH 10              00058940
         B     NODLINK        SKIP LENGTH PROCESSING                    00058945
IDMOVE   MVC   PGMID(*-*),0(7) MOVE CHARS TO RESERVED LOC               00058946
NEWID    SR    3,3            READY TO LOAD LENGTH                      00058950
         IC    3,2(0,7)       LENGTH FIELD FOLLOWS FLAG BYTE            00058955
         STC   3,IDDESC       SAVE IN PSEUDO DESCRIPTOR                 00058960
         NI    IDDESC,X'1F'   TRUNCATE TO 32 OR LESS                    00058965
         IC    3,IDDESC       GET TRUNCATED LENGTH-1 BACK               00058970
         SR    7,3            WHERE STRING BEGINS                       00058975
         EX    3,IDMOVE       MOVE THE CHARACTERS                       00058980
NODLINK  SR    7,7                 # COMMON STRINGS (ZERO FIRST LINK)   00059500
LINKING  L     3,BYTSCDAT          BYTES OF COMMON DATA                 00059600
         TM    FLAGS,LINKBIT       ARE WE LINKING?                      00059800
         BNO   FIRSTFCB                                                 00059900
         AR    2,3                 WHERE TO PUT THE FCB                 00060000
         BAL   CBR,READPGM         READ IN THE FCB                      00060100
         CLC   BYTSCDAT,0(2)       IS COMMON DATA THE SAME SIZE?        00060200
         BNE   INCOMPAT            ABEND 700 IF NOT                     00060300
         CLC   BYTSCDSC,4(2)       HOW ABOUT COMMON DESCRIPTORS?        00060400
         BNE   INCOMPAT            ABEND 700 IF NOT                     00060500
         CLC   COMARRD,48(2)  FINALLY, COMMON ARRAYS?                   00060600
         BNE   INCOMPAT       ABEND 700 IF NOT                          00060700
         MVC   FILECTRL(52),0(2)   MOVE THE FCB                         00060800
FIRSTFCB LR    4,3                 SAVE TOTAL SIZE OF COMMON            00060900
         A     3,BYTSDESC          PLUS BYTES NON-COMMON DESCRIPTORS    00061000
         S     3,BYTSBLK           MINUS ONE BLOCK                      00061100
         A     3,DESCFULL          PLUS AMOUNT IN LAST BLOCK            00061200
         A     3,BYTSCODE          PLUS BYTES OF PROGRAM                00061300
         S     3,BYTSBLK           MINUS ONE BLOCK                      00061400
         A     3,CODEFULL          PLUS AMOUNT IN LAST CODE BLOCK       00061500
         A     3,BYTSDATA          PLUS BYTES OF NON-COMMON DATA        00061600
         C     3,CORESIZE          COMPARE WITH SPACE AVAILABLE         00061700
         BNH   *+12                                                     00061800
         LA    1,COREABE           ABEND CODE FOR NO ROOM IN CORE       00061900
         B     ABEND                                                    00062000
         TM    FLAGS,LINKBIT       ARE WE LINKING?                      00062100
         BNO   ZERODATA            ZERO COMMON AREA IF NOT              00062200
         TM    FLAGS,NOCBIT        ANY COMMON STRINGS?                  00062300
         BO    NOCOMMON                                                 00062400
         A     3,ACORE             HOW FAR WILL WE OVERLAY?             00062500
         CR    8,3                 WILL IT OVERLAY THE COMMON STRINGS?  00062600
         BH    NOCOMMON            JUMP OVER ZEROING ROUTINE            00062700
         LA    1,OVLAYABE                                               00062800
         B     ABEND               ABEND 1100                           00062900
ZERODATA LTR   4,4                 IS THERE ANY COMMON?                 00063000
         BZ    NOCOMMON            NOTHING TO ZERO                      00063100
         LR    5,4            GET SIZE OF COMMON                        00063200
         AR    5,2            COMPUTE END                               00063300
         N     5,WORDALGN     ALIGN TO WORD BOUNDARY                    00063400
         L     6,COMARRD      GET NUMBER OF COMMON ARRAY DESCRIPTORS    00063500
         SLA   6,3            * 8                                       00063600
         BZ    NOCOMARD       NONE THERE                                00063700
         BCTR  6,0            -1 FOR EXECUTE OF MVC                     00063800
         EX    6,COMARMOV     GET OUT OF THE WAY BEFORE ZERO            00063900
NOCOMARD LR    5,4                 SAVE COMMON SIZE                     00064000
         SRL   5,8                 # OF 256 BYTE BLOCKS TO BE ZEROED    00064100
         LA    5,1(0,5)            PLUS ONE FOR GOOD MEASURE            00064200
         MVI   0(2),X'00'          GET IT STARTED                       00064300
MOVEZERO MVC   1(256,2),0(2)       ZERO A BLOCK                         00064400
         LA    2,256(0,2)          POINT TO NEXT BLOCK                  00064500
         BCT   5,MOVEZERO          DO UNTIL ALL HAVE BEEN ZEROED        00064600
         L     2,ACORE             START OF LOAD AREA                   00064700
         LR    5,2            REMEMBER COMMON START                     00064800
         LTR   6,6            ANY COMMON ARRAYS TO SET UP               00064900
         BZ    NOCOMMON-2     NO, BYPASS                                00065000
         L     6,COMARRD      GET COUNT AGAIN                           00065100
         AR    5,4            GET END OF AREA AGAIN                     00065200
         N     5,WORDALGN     ALIGN TO WORD BOUNDARY                    00065300
SETCOMAR LM    7,8,512(5)     GET ENTRIES                               00065400
         ST    8,0(7,2)       SET POINTER AT CORRECT LOCATION IN COMMON 00065500
         LA    5,8(,5)        BUMP TABLE POINTER                        00065600
         BCT   6,SETCOMAR     REPEAT TILL DONE                          00065700
         SR    7,7                                                      00065800
         AR    2,4            PLUS SIZE OF COMMON                       00065900
NOCOMMON L     5,BLKSDESC     BLOCKS OF NON-COMMON DESCRIPTORS          00066000
         L     3,BYTSBLK           BYTES PER BLOCK                      00066100
RDESC    BAL   CBR,READPGM         READ A BLOCK OF DESCRIPTORS          00066200
         AR    2,3                 INCREMENT READ LOCATION              00066300
         BCT   5,RDESC             GET ALL THE BLOCKS                   00066400
         SR    2,3                 LESS ONE BLOCK                       00066500
         A     2,DESCFULL          WHERE TO READ IN THE CODE            00066600
         ST    2,CODEADR           SAVE CODE LOCATION FOR XPL PROGRAM   00066700
         L     5,BLKSCODE          BLOCKS OF CODE                       00066800
RCODE    BAL   CBR,READPGM         READ A BLOCK OF CODE                 00066900
         AR    2,3                 INCREMENT READ LOCATION              00067000
         BCT   5,RCODE             READ THEM ALL                        00067100
         SR    2,3                 LESS ONE BLOCK                       00067200
         A     2,CODEFULL          WHERE TO READ IN THE DATA            00067300
         ST    2,DATADR            SAVE DATA LOCATION FOR XPL PROGRAM   00067400
         L     5,BLKSDATA          BLOCKS OF DATA AND COMPILED STRINGS  00067500
RDATA    BAL   CBR,READPGM         READ IN THE XPL PROGRAM'S DATA AREA  00067600
         AR    2,3                 ADDRESS TO PUT NEXT RECORD           00067700
         BCT   5,RDATA             LOOP BACK FOR NEXT RECORD            00067800
         SR    2,3                                                      00067900
         A     2,DATAFULL          FREEPOINT                            00068000
         TM    FLAGS,LINKBIT       ARE WE LINKING?                      00068100
         BNO   CALLXPL             NO COMMON STRINGS YET, IF NOT        00068200
         TM    FLAGS,NOCBIT                                             00068300
         BO    CALLXPL                                                  00068400
         LR    5,7                 SAVE SIZE OF COMMON STRINGS          00068500
         SRL   5,8                 # 256 BYTE BLOCKS                    00068600
         SR    11,2                                                     00068700
         LTR   5,5                 ANY WHOLE BLOCKS?                    00068800
         BZ    SMALLMV                                                  00068900
MOVEDOWN MVC   0(256,2),0(8)       MOVE A BLOCK DOWN                    00069000
         LA    2,256(0,2)          GET NEXT BLOCK                       00069100
         LA    8,256(0,8)                                               00069200
         BCT   5,MOVEDOWN          LOOP TIL DONE                        00069300
SMALLMV  L     4,CORETOP           END OF COMMON STRINGS                00069400
         SR    4,8                 NUMBER OF CHARACTERS LEFT TO MOVE    00069500
         BZ    EXACT               NONE LEFT                            00069600
         BCTR  4,0                 ONE LESS FOR EXECUTE                 00069700
         EX    4,MOVEDOWN          MOVE THE LAST CHARACTERS             00069800
EXACT    L     6,DESCDESC     POINT TO DESCRIPTOR LIST                  00069900
         LA    9,4            CHECK 4 ENTRIES (MUST AGREE WITH          00070000
*                             A NUMBER GENERATED BY THE XPL COMPILER    00070100
RELOCDSC L     8,4(,6)        LENGTH OF THIS BLOCK OF DESCRIPTORS       00070200
         LTR   8,8                                                      00070300
         BZ    NEXTBLK        THIS BLOCK EMPTY, GET NEXT                00070400
         L     5,0(,6)        START OF THIS BLOCK OF DESCRIPTORS        00070500
         AR    8,5            NOW END OF THIS BLOCK OF DESCRIPTORS      00070600
         BAL   CBR,RELOCATE       RELOCATE BLOCK OF DESCRIPTORS         00070610
NEXTBLK  LA    6,8(,6)            TO NEXT DESCRIPTOR BLOCK              00070620
         BCT   9,RELOCDSC         UNTIL ALL ARE CHECKED                 00070630
*                                                                       00070640
         L     6,FIRSTREC         FIRST RECORD                          00070650
NEXTRECT LTR   6,6                IS THERE ONE                          00070660
         BZ    CALLXPL                                                  00070670
         USING BASEDREC,6                                               00070680
         L     3,BRECPTR          POINTER TO RECORD FIELD               00070690
         L     9,BRECUSED         # OF ALLOCATED RECORDS                00070700
         LH    2,BRECNDSC         # OF DESCRIPTORS/RECORD               00070710
         SLA   2,2                *4 (# OF WORDS)                       00070720
         BZ    LINKREC            NONE, ON TO NEXT RECORD               00070730
RELRECS  LR    5,3                FIRST DESCRIPTOR IN RECORD            00070740
         LR    8,2                # OF BYTES OF DESCRIPTOR AREA         00070750
         AR    8,5                END OF DESCRIPTOR AREA                00070760
         BAL   CBR,RELOCATE       RELOCATE DESCRIPTORS                  00070770
         AH    3,BRECWDTH         INCREMENT BY FULL RECORD WIDTH        00070780
         BCT   9,RELRECS          THROUGH ALL ALLOCATED RECORD COPIES   00070790
LINKREC  L     6,BRECNEXT         TO NEXT RECORD BLOCK                  00070800
         DROP  6                                                        00070810
         B     NEXTRECT           SEE IF THERE ARE ANY MORE             00070820
RELOCATE L     4,0(0,5)            LOAD DESCRIPTOR                      00070830
         LTR   4,4                 IS IT NULL                           00070840
         BZ    NULLDESC            DON'T RELOCATE                       00070900
         SR    4,11                PUT IN OFFSET                        00071000
         ST    4,0(0,5)            STORE DESCRIPTOR                     00071100
NULLDESC LA    5,4(0,5)            POINT TO NEXT DESCRIPTOR             00071200
         CR    5,8                 ANY MORE?                            00071300
         BL    RELOCATE                                                 00071400
         BR    CBR                RETURN                                00071500
         SPACE 2                                                        00071700
*********************************************************************** 00071800
*                                                                     * 00071900
*                                                                     * 00072000
*        CODE TO BRANCH TO THE XPL PROGRAM                            * 00072100
*                                                                     * 00072200
*                                                                     * 00072300
*********************************************************************** 00072400
         SPACE 2                                                        00072500
CALLXPL  LA    SELF,ENTRY          ADDRESS OF ENTRY POINT TO XPLSM      00072600
         LM    0,3,PGMPARMS        PARAMETERS FOR THE XPL PROGRAM       00072700
         DROP  EBR,13                                                   00072800
         USING ENTRY,SELF                                               00072900
         SPACE 2                                                        00073000
         LR    13,7                PASS COMMON STRING SIZE TO XPL       00073100
         ENTRY STARTXPL                                                 00073110
STARTXPL BAL   CBR,0(0,2)          BRANCH TO THE XPL PROGRAM            00073800
         SPACE 1                                                        00073900
*********************************************************************** 00074000
*                                                                     * 00074100
*                                                                     * 00074200
*        THE XPL PROGRAM RETURNS HERE AT THE END OF EXECUTION         * 00074300
*                                                                     * 00074400
*                                                                     * 00074500
*********************************************************************** 00074600
         SPACE 2                                                        00074700
         L     EBR,ABASE1          REGISTER FOR ADDRESSABILITY          00074800
         USING BASE1,EBR                                                00074900
         ST    RTN,RTNSV           SAVE COMPLETION CODE RETURNED BY     00075000
*                             THE XPL PROGRAM FOR PASSING TO OS         00075100
         IC    RTN,RETFLAGS   GET HIGH BYTE FLAGS                       00075200
         STC   RTN,RTNSV      PUT INTO RETURN CODE                      00075300
         L     13,ASAVE            ADDRESS OF OS/360 SAVE AREA          00075400
         USING SAVE,13                                                  00075500
         DROP  SELF                                                     00075600
         LR    12,13                                                    00075605
         A     12,F4096                                                 00075610
         USING SAVE+4096,12                                             00075615
         SPACE 2                                                        00075900
*********************************************************************** 00076000
*                                                                     * 00076100
*        RELEASE THE MEMORY OCCUPPIED BY THE XPL PROGRAM              * 00076200
*                                                                     * 00076300
*********************************************************************** 00076400
         SPACE 2                                                        00076500
SMRET    EQU   *                                                        00076502
         SPACE                                                          00076554
         LA    0,SUBPOOL                                                00076556
         SLL   0,24           MOVE TO HIGH BYTE                         00076600
         FREEMAIN R,SP=(0) GIVE IT ALL BACK                             00076650
         SPACE 1                                                        00076700
         DELETE EPLOC=OPTNAME DELETE CURRENT OPTION PROCESSOR           00076710
         SPACE 1                                                        00076720
         LA    3,GETDCBS      ADDR OF DCB ADDR LIST                     00077810
CLOSEALL L     4,0(0,3)       DCB ADDR                                  00077820
         LA    4,0(0,4)       CLEAR POSSIBLR HO BIT                     00077830
         LTR   4,4            WATCH FOR ZERO DCB ADDR                   00077840
         BZ    NEXTDCB        SKIP IF NON-EXISTANT                      00077850
         USING IHADCB,4       USE DCBD SYMBOLS                          00077860
         TM    DCBOFLGS,OPENBIT IS IT OPEN?                             00077870
         DROP  4                                                        00077875
         BNO   TRYFREEP       NO, BUT TRY FREEPOOL                      00077880
         CLOSE ((4))                                                    00077890
TRYFREEP TM    23(4),1        BUFCB ADDR EXISTS?                        00077900
         BO    NEXTDCB        NO, LOOK AT NEXT DCB                      00077910
         FREEPOOL (4)                                                   00077920
NEXTDCB  TM    0(3),X'80'     WAS THIS THE LAST DCB?                    00077930
         BO    RESPIE         YES, EXIT LOOP                            00077940
         LA    3,4(0,3)       POINT AT NEXT DCB ADDR                    00077950
         B     CLOSEALL       LOOP AGAIN                                00077960
         SPACE 1                                                        00079200
RESPIE   EQU   *                                                        00079300
         AIF   (&XPL).XX0                                               00079310
         L     1,OLDSPIE                                                00079320
         SPIE  MF=(E,(1)) RESTORE ORIGINAL SPIE                         00079400
.XX0     ANOP                                                           00079450
         L     15,RTNSV            LOAD RETURN CODE                     00079500
         L     13,SAVE+4                                                00079600
         DROP  13,12                                                    00079700
         RETURN (14,12),RC=(15)    RETURN TO OS/360                     00079800
         SPACE 1                                                        00079900
         DROP  EBR                                                      00080000
         USING SAVE,13                                                  00080100
         SPACE 5                                                        00080200
*********************************************************************** 00080300
*                                                                     * 00080400
*        ROUTINE TO ABEND IF THE LINKED PROGRAMS' COMMON AREAS        * 00080500
*        ARE INCOMPATIBLE                                             * 00080600
*                                                                     * 00080700
*********************************************************************** 00080800
         SPACE 2                                                        00080900
INCOMPAT LA    1,COMABE                                                 00081000
         B     ABEND                                                    00081100
         EJECT                                                          00081200
*********************************************************************** 00081300
*                                                                     * 00081400
*                                                                     * 00081500
*                                                                     * 00081600
*        CONSTANTS USED DURING INITIALIZATION                         * 00081700
*                                                                     * 00081800
*                                                                     * 00081900
*********************************************************************** 00082000
         SPACE 2                                                        00082100
OLDSPIE  DS    A                                                        00082200
SAVE     DS    18F                 SAVE AREA FOR OS/360                 00082300
ONEHOUR  DC    F'360000'      ONE HOUR IN .01 SECS                      00082400
ACORE    DS    A                   ADDRESS OF CORE                      00082500
CORESIZE DS    F                   SIZE OF CORE IN BYTES                00082600
CONTROL  DS    A                   ADDRESS OF PARAMETER STRING PASSED   00082700
*                                  TO THE SUBMONITOR BY OS/360          00082800
COREREQ  DS    0F                  CORE REQUEST CONTROL BLOCK           00082900
COREMIN  DC    F'50000'            MINIMUM AMOUNT OF CORE REQUESTED     00083000
COREMAX  DC    F'5000000'          MAXIMUM AMOUNT OF CORE REQUESTED     00083100
FREEUP   DC    A(0)             AMOUNT OF CORE TO RETURN TO OS          00083200
WORDALGN DC    X'00FFFFFC'      MASK FOR WORD BOUNDARY ALIGNMENT        00083400
COMARMOV MVC   512(0,5),52(2) MOVE INFO FROM FCB BEYOND ZEROED AREA     00083500
IDOFFSET DS    0H                                                       00083510
         DC    H'-10' 10 BYTES BEFORE END OF FCB                        00083515
FLAGOFF  DC    H'-3' ONE BYTE BEFORE POTENTIAL FLAG BYTE                00083518
PGMID    DS    CL32           32 (MAX) CHARACTER ID FOR PROGRAM         00083520
         DS    0F                                                       00083530
IDDESC   DC    AL1(9),AL3(PGMID)  DESCRIPTOR FOR PROGRAM ID (LEN=10)    00083540
JFCBDESC DC    AL1(L'JFCB-1),AL3(JFCB) DESCRIPTOR FOR JOB FILE CNTL BLK 00083550
         SPACE 1                                                        00083600
*********************************************************************** 00083700
*                                                                     * 00083800
*        BLOCK OF PARAMETERS PASSED TO THE XPL PROGRAM                * 00083900
*                                                                     * 00084000
*********************************************************************** 00084100
         SPACE 1                                                        00084200
PGMPARMS DS    F                   R0  UNUSED                           00084300
CORETOP  DC    A(0)                R1  ADDRESS OF TOP OF CORE           00084400
         ENTRY CODEADR                                                  00084450
CODEADR  DC    F'0'                R2  ADDRESS OF START OF 1ST RECORD   00084500
*                                  OF THE XPL PROGRAM                   00084600
DATADR   DC    F'0'                R3  ADDRESS OF THE START OF THE XPL  00084700
*                                      PROGRAM'S DATA AREA              00084800
VCONOPT  DC    A(0)           ADDRESS OF OPTIONS PARAMETERS             00084900
OPTNAME  DC    CL8'MONOPT  '  DEFAULTS TO MONITOR OPTION PROCESSOR      00084910
         EJECT                                                          00085200
*********************************************************************** 00085300
*                                                                     * 00085400
*                                                                     * 00085500
*                                                                     * 00085600
*        DATA AREA FOR THE SUBMONITOR                                 * 00085700
*                                                                     * 00085800
*                                                                     * 00085900
*********************************************************************** 00086000
         SPACE 2                                                        00086100
         DS    0F                                                       00086200
MAXCODE  DC    A(ENDSERV-4)        LARGEST VALID SERVICE CODE           00086300
RTNSV    DC    F'0'                SAVE COMPLETION CODE RETURNED        00086400
*                                  BY THE XPL PROGRAM                   00086500
DESCDESC DC    F'0'                                                     00086600
FIRSTREC DC    F'0'                                                     00086610
ABESAVE  DS    F                   SAVE ABEND CODE DURING CLOSE         00086700
ABEREGS  DS    3F                  SAVE PROGRAMS REGS 0-2 BEFORE ABEND  00086800
TTR      DC    F'0'                TTRZ ADDRESS FOR READ AND WRITE      00086900
FLAGS    DC    X'00'               SUBMONITOR CONTROL FLAGS             00087100
RETFLAGS DC    X'00'                                                    00087200
NAMEFLD  DC    A(0) ADDR OF CHARACTERISTIC NAME FIELD                   00087300
         DS    0D                                                       00087400
DTSV     DC    PL8'0'              WORK AREA FOR CONVERTING DATE        00087500
BLKSAV   DC    H'0'                                                     00087501
FILECTRL DS    0F                  FILE CONTROL BLOCK STRUCTURE         00087600
         SPACE                                                          00087700
BYTSCDAT DS    1F                  BYTES OF COMMON DATA                 00087800
         SPACE                                                          00087900
BYTSCDSC DS    1F                  BYTES OF COMMON DESCRIPTORS          00088000
         SPACE                                                          00088100
BYTSDESC DS    1F                  BYTES OF NON-COMMON DESCRIPTORS      00088200
         SPACE                                                          00088300
BYTSCODE DS    1F                  BYTES OF COMPILED CODE               00088400
         SPACE                                                          00088500
BYTSDATA DS    1F                  BYTES OF NON-COMMON DATA             00088600
         SPACE                                                          00088700
BLKSDESC DS    1F                  BLOCKS OF NON-COMMON DESCRIPTORS     00088800
         SPACE                                                          00088900
BLKSCODE DS    1F                  BLOCKS OF CODE                       00089000
         SPACE                                                          00089100
BLKSDATA DS    1F                  BLOCKS OF NON-COMMON DATA            00089200
         SPACE                                                          00089300
BYTSBLK  DS    1F                  # BYTES PER BLOCK                    00089400
         SPACE                                                          00089500
DESCFULL DS    1F                  # BYTES ACTUALLY USED IN LAST BLOCK  00089600
         SPACE                                                          00089700
CODEFULL DS    1F                  # BYTES USED IN LAST CODE BLOCK      00089800
         SPACE                                                          00089900
DATAFULL DS    1F                  # BYTES USED IN LAST DATA BLOCK      00090000
         SPACE 1                                                        00090100
COMARRD  DS    1F             # COMMON ARRAY DESCRIPTORS                00090200
         EJECT                                                          00090300
         AIF   (&XPL).QQ12                                              00090310
*        ALTERNATE DD LIST                                              00090400
*                                                                       00090500
ALTDDLST DC    A(INPUT1)      SYSIN                                     00090600
         DC    A(INPUT4)      INCLUDE                                   00090700
         DC    A(INPUT5)      ERROR                                     00090800
         DC    A(INPUT6)      INCLUDE                                   00090900
         DC    A(OUTPUT1)     SYSPRINT                                  00091000
         DC    A(OUTPUT2)     LISTING2                                  00091100
         DC    A(OUTPUT3)     OUTPUT3 (OBJECT)                          00091200
         DC    A(OUTPUT4)     OUTPUT4 (DECK)                            00091300
         DC    A(OUTPUT5)     OUTPUT5 (SDF)                             00091400
         DC    A(OUTPUT6)     OUTPUT6 (TEMPLATES)                       00091500
         DC    A(OUTPUT7)     OUTPUT7 (FC CODE LIST)                    00091600
ALTFILES DC    A(FILE1)                                                 00091700
         DC    A(FILE2)                                                 00091800
         DC    A(FILE3)                                                 00091900
         DC    A(FILE4)                                                 00092000
         DC    A(FILE5)                                                 00092100
         DC    A(FILE6)                                                 00092200
AFILEND  EQU   *                                                        00092900
         DC    A(PROGRAM)                                               00093000
         DC    A(OUTPUT8)                                               00093100
         DC    A(HALSDF)                                                00093105
         DC    A(OUTPUT9)                                               00093115
         DC    A(INPUT8)                                                00093120
         DC    A(FILE7)                                                 00093125
         DC    A(INPUT9)                                                00093135
          DC    A(INPUT11)                                              00093140
ALTEND   EQU   *                                                        00093200
         AIF   (&COMP).QQ0                                              00093205
&I       SETA  &FILES+1                                                 00093207
.FL1     AIF   (&I GT 6).QQ12                                           00093209
FILE&I   EQU   *                                                        00093210
&I       SETA  &I+1                                                     00093220
         AGO   .FL1                                                     00093225
.QQ0     ANOP                                                           00093250
&I       SETA  &INPUTS+1                                                00093252
.IL1     AIF   (&I GT 9).QQ13                                           00093254
INPUT&I  EQU   *                                                        00093256
&I       SETA  &I+1                                                     00093258
         AGO   .IL1                                                     00093260
.QQ13    ANOP                                                           00093262
&I       SETA  &OUTPUTS+1                                               00093264
.OL1     AIF   (&I GT 9).QQ12                                           00093266
OUTPUT&I EQU   *                                                        00093268
&I       SETA  &I+1                                                     00093270
         AGO   .OL1                                                     00093272
.QQ12    ANOP                                                           00093274
         SPACE 3                                                        00093300
*********************************************************************** 00093400
*                                                                     * 00093500
*                                                                     * 00093600
*        DCB ADDRESS TABLE FOR ALL I/O ROUTINES                       * 00093700
*                                                                     * 00093800
*                                                                     * 00093900
*        THE FOUR SETS OF DCB ADDRESSES HEADED BY  'GETDCBS',         * 00094000
*        'PUTDCBS', 'ARWDCBS', AND 'PGMDCB' MUST BE CONTIGUOUS        * 00094100
*        AND END WITH 'PGMDCB'.  THESE LISTS ARE USED AT JOB END      * 00094200
*        TO CLOSE ALL FILES BEFORE RETURNING TO OS                    * 00094300
*                                                                     * 00094400
*                                                                     * 00094500
*        DCB ADDRESSES FOR INPUT FILES:                               * 00094600
*                                                                     * 00094700
*                                                                     * 00094800
*********************************************************************** 00094900
         SPACE 2                                                        00095000
OWRKADDR DC    V(OUTWORK)                                               00095100
IWRKADDR DC    V(INWORK)                                                00095200
FWRKADDR DC    A(FILEWORK-FILEORG)                                      00095250
         SPACE 1                                                        00095300
         GBLB &PA,&BF   ** DR101925 - P. ANSLEY, 5/22/92 **
         AIF (&BF).B1   ** DR101925 - P. ANSLEY, 5/20/92 **
         DCBLIST INPUT,                                                X00095400
               (INPUT0,PS),                                            X00095500
               (INPUT1,PS),                                            X00095600
               (INPUT2,PS),                                            X00095700
               (INPUT3,PS),                                            X00095800
               (INPUT4,PO),                                            X00095900
               (INPUT5,PO),                                            X00096000
               (INPUT6,PO),                                            X00096100
               (INPUT7,PO),                                            X00096200
               (INPUT8,PO),                                            X00096210
               (INPUT9,PO),                                            X00096215
               (INPUT10,PS),                                           X00096216
               (INPUT11,PO),                                           X00096217
               OUTPUT,                                                 X00096300
               (OUTPUT0,PS),                                           X00096400
               (OUTPUT1,PS),                                           X00096500
               (OUTPUT2,PS),                                           X00096600
               (OUTPUT3,PS),                                           X
               (OUTPUT4,PS),                                           X00096800
               (OUTPUT5,PO),                                           X00096900
               (OUTPUT6,PO),                                           X00097000
               (OUTPUT7,PS),                                           X00097100
               (OUTPUT8,PO),                                           X00097200
               (OUTPUT9,PO),                                           X00097205
               (OUTPUT10,PS),                                          X00097210
               (OUTPUT11,PS),                                          X00097215
               (OUTPUT12,PS),                                          X00097220
               (OUTPUT13,PS),                                          X00097225
               (OUTPUT14,PS)                                            00097230
         SPACE 1                                                        00097300
         AGO .C1
.B1      ANOP                  ** DR101925 - P. ANSLEY, 5/22/92 **
         DCBLIST INPUT,                                                X00095400
               (INPUT0,PS),                                            X00095500
               (INPUT1,PS),                                            X00095600
               (INPUT2,PS),                                            X00095700
               (INPUT3,PS),                                            X00095800
               (INPUT4,PO),                                            X00095900
               (INPUT5,PO),                                            X00096000
               (INPUT6,PO),                                            X00096100
               (INPUT7,PO),                                            X00096200
               (INPUT8,PO),                                            X00096210
               (INPUT9,PO),                                            X00096215
               (INPUT10,PS),                                           X00096216
               (INPUT11,PO),                                           X00096217
               OUTPUT,                                                 X00096300
               (OUTPUT0,PS),                                           X00096400
               (OUTPUT1,PS),                                           X00096500
               (OUTPUT2,PS),                                           X00096600
               (OUTPUT3,PO),                                           X
               (OUTPUT4,PS),                                           X00096800
               (OUTPUT5,PO),                                           X00096900
               (OUTPUT6,PO),                                           X00097000
               (OUTPUT7,PS),                                           X00097100
               (OUTPUT8,PO),                                           X00097200
               (OUTPUT9,PO),                                           X00097205
               (OUTPUT10,PS),                                          X00097210
               (OUTPUT11,PS),                                          X00097215
               (OUTPUT12,PS),                                          X00097220
               (OUTPUT13,PS),                                          X00097225
               (OUTPUT14,PS)                                            00097230
         SPACE 1                                                        00097300
.C1      ANOP                     **** END DR101925 ****
*********************************************************************** 00097400
*                                                                     * 00097500
*        DCB ADDRESS FOR DIRECT ACCESS FILES                          * 00097600
*                                                                     * 00097700
*********************************************************************** 00097800
         SPACE 1                                                        00097900
ARWDCBS  DS    0F                                                       00098000
         SPACE 1                                                        00098100
&I       SETA  1                                                        00098200
.DA1     AIF   (&I GT &FILES).DA2                                       00098300
         ORG   ARWDCBS+RD&I-FILEORG                                     00098400
         DC    A(FILE&I)                                                00098500
         ORG   ARWDCBS+WRT&I-FILEORG                                    00098600
         DC    A(FILE&I)                                                00098700
FILEWORK CSECT                                                          00098720
         DC    2A(FWORK&I)                                              00098740
IOPACK   CSECT                                                          00098760
&I       SETA  &I+1                                                     00098800
         AGO   .DA1                                                     00098900
.DA2     ANOP                                                           00099000
         ORG   ARWDCBS+ENDSERV-FILEORG                                  00099100
FILEWORK CSECT                                                          00099110
&I       SETA  1                                                        00099120
.DA3     AIF   (&I GT &FILES).DA4                                       00099130
FWORK&I  DC    2F'0'                                                    00099140
&I       SETA  &I+1                                                     00099150
         AGO   .DA3                                                     00099160
.DA4     ANOP                                                           00099170
IOPACK   CSECT                                                          00099180
         DS    0F                                                       00099200
         SPACE 2                                                        00099300
PGMDCB   DC    X'80'               FLAG END OF PARAMETER LIST           00099400
         DC    AL3(PROGRAM)        ADDRESS OF PROGRAM DCB               00099500
         SPACE 2                                                        00099600
OCDCB    DS    F                   DCB ADDRESSES FOR OPEN AND CLOSE     00099700
MOVEADR  DS    1F                  DESCRIPTOR STORAGE FOR PUT ROUTINE   00099800
FILLENG  DC    F'0'                LENGTH OF PADDING NEEDED IN OUTPUT   00099900
F1       DC    F'1'                THE CONSTANT ONE                     00100000
F2       DC    F'2'                THE CONSTANT TWO                     00100100
F4       DC    F'4'           THE CONSTANT FOUR                         00100200
LINECT   DC    F'60'               LINE COUNT ACCUMULATOR FOR SYSPRINT  00100300
LINELIM  DC    F'59'               UPPER LIMIT FOR LINECT               00100400
PAGECT   DC    F'250'              ABORT AFTER THIS MANY PAGES          00100500
MOVEHDG  MVC   HEADING+1(*-*),0(2)                                      00100600
MOVEHDG2 MVC   HEADING2+1(*-*),0(2)                                     00100700
GETMOVE  MVC   0(0,2),0(1)         MVC COMMAND FOR THE GET ROUTINE      00100800
MVCNULL  MVC   1(0,1),0(1)         MVC COMMAND FOR THE PUT ROUTINE      00100900
MVCBLANK MVC   2(0,1),1(1)             "                                00101000
MVCSTRNG MVC   0(0,1),0(2)             "                                00101100
ONE      DC    PL1'1'                                                   00101200
PAGENO   DC    PL3'0'                                                   00101300
PAT      DC    XL6'402020202120'                                        00101400
HEADING  DC    CL125'1X P L   S Y S T E M   --   I N T E R M E T R I C &00101500
               S',C'PAGE   1'                                           00101600
HEADING2 DC    CL133'0'            THE SUBHEADING                       00101700
PABM     DC    C'-* * *  PAGE LIMIT EXCEEDED  ---  ABEND 600  * * *'    00101800
         DS    0F                 FULLWORD ALIGN                        00101810
ACSMETH  DC    AL1(0),AL3(0)      HIGH BYTE FILLED IN                   00101820
WTPM     DC    AL2(78+4)                                                00101830
         DC    X'8000'            MCS FLAGS                             00101840
SYNADMSG DC    CL78' '                                                  00101850
         DC    X'0000'            DESCRIPTOR CODES                      00101860
         DC    X'0020'            ROUTING CODES (ROUTCDE=11)            00101870
         DS    0D                  STOWNAME MUST BE ON A DOUBLEWORD     00101900
STOWNAME DC    C'        ',X'00000001',X'F0F0' INITIAL RVL              00102000
         DS    0H             BLDLIST MUST BE ON A HALFWORD BOUNDRY     00102100
BLDLIST  DC    H'1',H'76'  FF AND LL FIELDS                             00102200
FINDNAME DC    CL8' '                                                   00102300
FINDTTRK DS    4X                                                       00102400
FINDZC   DS    2X                                                       00102500
FINDUSER DS    62X                                                      00102600
F384     DC    F'384'         TIMER UNITS TO .01 SEC CONVERSION FACTOR  00102700
PDSFLAGS DS    X               FLAGS FOR USE WHEN DOING FIND OPERATIONS 00103400
ASDFPKG  DC    A(0)           ADDRESS OF SDFPKG                         00103605
SDFDDNAM DC    CL8'HALSDF'                                              00103606
F4096    DC    F'4096'                                                  00103607
CORETEST DC    F'8'           MIN OF 8 BYTES                            00103610
         DC    F'5000000'     MAX OF 5 MEG                              00103620
COREGOT  DS    A              ADDR OF CORE OBTAINED                     00103630
         DS    F              SIZE GOTTEN                               00103640
         WRITE PDSDECB,SF,MF=L     MAKE DECB FOR PDS WRITES             00103700
*                                                                       00103720
DSCBFILE CAMLST SEARCH,0,0,DSCBWORK  TO READ FMT1 DSCB                  00103740
MBBCCHHR DS    CL8                                                      00103760
         XDAP  XDAPECB,WI,0,0,0,,MF=L                                   00103770
         EJECT                                                          00103800
         SPACE 5                                                        00103900
*********************************************************************** 00104000
*                                                                     * 00104100
*                                                                     * 00104200
*        ROUTINE TO READ IN THE BINARY IMAGE OF THE XPL PROGRAM       * 00104300
*                                                                     * 00104400
*                                                                     * 00104500
*********************************************************************** 00104600
         SPACE 2                                                        00104700
READPGM  DS    0H                                                       00104800
*                                  SHARE DECB WITH FILE READ ROUTINE    00104900
         SPACE 1                                                        00105000
         L     14,PGMDCB    LOAD DCB ADDRESS                            00105100
         READ  RDECB,SF,(14),(2),MF=E                                   00105200
         CHECK RDECB               WAIT FOR READ TO COMPLETE            00105300
         SPACE 1                                                        00105400
         BR    CBR            RETURN TO CALLER                          00105500
         EJECT                                                          00105600
         SPACE 5                                                        00105700
*********************************************************************** 00105800
*                                                                     * 00105900
*                                                                     * 00106000
*        ROUTINES TO PROVIDE DEFAULT DATASET INFORMATION IF NONE      * 00106100
*        IS PROVIDED BY JCL OR VOLUME LABELS.  IN PARTICULAR,         * 00106200
*        BLKSIZE, LRECL, BUFNO, AND RECFM INFORMATION.                * 00106300
*                                                                     * 00106400
*                                                                     * 00106500
*        EXIT LISTS FOR DCBS                                          * 00106600
*                                                                     * 00106700
*********************************************************************** 00106800
         SPACE 2                                                        00106900
         DC    0F'0'                                                    00107000
*        FIRST SET UP THE GENERIC CLASSES OF DCB EXIT ROUTINES          00107100
*                                                                       00107110
*        ALL USE JFCB EXIT TO ALLOW RDJFCB ON ANY DCB                   00107120
*                                                                       00107200
TYPE1    DC    X'07',AL3(JFCB),X'85',AL3(GROUP1)                        00107300
TYPE2    DC    X'07',AL3(JFCB),X'85',AL3(GROUP2)                        00107400
TYPE3    DC    X'07',AL3(JFCB),X'85',AL3(GROUP3)                        00107500
TYPE4    DC    X'07',AL3(JFCB),X'85',AL3(GROUP4)                        00107600
TYPE5    DC    X'07',AL3(JFCB),X'85',AL3(GROUP5)                        00107700
TYPE6    DC    X'07',AL3(JFCB),X'85',AL3(GROUP6)                        00107705
TYPE7    DC    X'07',AL3(JFCB),X'85',AL3(GROUP7)                        00107710
*                                                                       00107800
*        NOW DEFINE THE SPECIFIC EXITS BY REFERENCE TO THE CLASSES      00107900
*                                                                       00108000
INEXIT1  EQU   TYPE1                                                    00108100
INEXIT2  EQU   TYPE1                                                    00108200
INEXIT3  EQU   TYPE1                                                    00108300
INEXIT4  EQU   TYPE1                                                    00108400
INEXIT5  EQU   TYPE1                                                    00108500
INEXIT6  EQU   TYPE1                                                    00108600
INEXIT7  EQU   TYPE1                                                    00108700
         AIF   (&COMP).TI2                                              00108701
INEXIT8  EQU   TYPE6                                                    00108705
INEXIT9  EQU   TYPE4                                                    00108710
         AGO   .TI1                                                     00108720
.TI2     ANOP                                                           00108730
INEXIT8  EQU   TYPE1                                                    00108740
INEXIT9  EQU   TYPE1                                                    00108750
INEXIT10 EQU   TYPE2                                                    00108760
INEXIT11 EQU   TYPE6                                                    00108761
.TI1     ANOP                                                           00108770
*                                                                       00108800
OUTEXIT1 EQU   TYPE2                                                    00108900
OUTEXIT2 EQU   TYPE2                                                    00109000
OUTEXIT3 EQU   TYPE3                                                    00109100
OUTEXIT4 EQU   TYPE3                                                    00109200
OUTEXIT5 EQU   TYPE4                                                    00109300
OUTEXIT6 EQU   TYPE1                                                    00109400
OUTEXIT7 EQU   TYPE5                                                    00109500
OUTEXIT8 EQU   TYPE1                                                    00109600
OUTEXIT9 EQU   TYPE2                                                    00109605
OUTEXITA EQU   TYPE3                                                    00109610
OUTEXITB EQU   TYPE3                                                    00109615
OUTEXITC EQU   TYPE3                                                    00109620
OUTEXITD EQU   TYPE3                                                    00109625
OUTEXITE EQU   TYPE3                                                    00109630
*                                                                       00109700
FILEEXIT EQU   TYPE7                                                    00109705
*                                                                       00109710
*                                                                       00109800
*********************************************************************** 00109900
*                                                                     * 00110000
*        DCB EXIT ROUTINE ENTRY POINTS                                * 00110100
*                                                                     * 00110200
*********************************************************************** 00110300
*                                                                       00110400
GROUP1   MVC   DEFAULTS(6),DEFAULT1                                     00110500
         B     GENXT                                                    00110600
*                                                                       00110700
GROUP2   MVC   DEFAULTS(6),DEFAULT2                                     00110800
         B     GENXT                                                    00110900
*                                                                       00111000
GROUP3   MVC   DEFAULTS(6),DEFAULT3                                     00111100
         B     GENXT                                                    00111200
*                                                                       00111300
GROUP4   MVC   DEFAULTS(6),DEFAULT4                                     00111400
         B     GENXT                                                    00111500
*                                                                       00111600
GROUP5   MVC   DEFAULTS(6),DEFAULT5                                     00111700
         B     GENXT                                                    00111705
*                                                                       00111710
GROUP6   MVC   DEFAULTS(6),DEFAULT6                                     00111715
         B     GENXT                                                    00111720
*                                                                       00111725
GROUP7   MVC   DEFAULTS(6),DEFAULT7                                     00111730
         SPACE 1                                                        00111800
*********************************************************************** 00111900
*                                                                     * 00112000
*                                                                     * 00112100
*        DCB EXIT LIST PROCESSING ROUTINE FOR OPEN EXITS              * 00112200
*                                                                     * 00112300
*********************************************************************** 00112400
         SPACE 2                                                        00112500
GENXT    DS    0H                                                       00112600
         USING IHADCB,1            REGISTER 1 POINTS AT THE DCB         00112700
         NC    DCBBLKSI,DCBBLKSI   CHECK BLKSIZE                        00112800
         BNZ   GXT1                ALREADY SET                          00112900
         MVC   DCBBLKSI(2),DFLTBLKS                                     00113000
*                                  PROVIDE DEFAULT BLOCKSIZE            00113100
         SPACE 1                                                        00113200
GXT1     NC    DCBLRECL,DCBLRECL   CHECK LRECL                          00113300
         BNZ   GXT2                ALREADY SET                          00113400
         MVC   DCBLRECL(2),DFLTLREC                                     00113500
*                                  PROVIDE DEFAULT LRECL                00113600
         SPACE 1                                                        00113700
GXT2     CLI   DCBBUFNO,0          CHECK BUFNO                          00113800
         BNE   GXT3                ALREADY SPECIFIED                    00113900
         MVC   DCBBUFNO(1),DFLTBUFN                                     00114000
*                                  PROVIDE DEFAULT BUFNO                00114100
         SPACE 1                                                        00114200
GXT3     TM    DCBRECFM,ALLBITS-KEYLBIT                                 00114300
*                                  CHECK RECFM                          00114400
         BCR   B'0111',14          ALREADY SET SO RETURN                00114500
         OC    DCBRECFM(1),DFLTRECF                                     00114600
*                                  PROVIDE DEFAULT RECFM                00114700
         BR    14                  RETURN                               00114800
         DROP  1                                                        00114900
         SPACE 2                                                        00115000
*********************************************************************** 00115100
*                                                                     * 00115200
*        ARRAY OF DEFAULT ATTRIBUTES USED BY GENXT                    * 00115300
*                                                                     * 00115400
*********************************************************************** 00115500
         SPACE 1                                                        00115600
DEFAULTS DS    0H                                                       00115700
DFLTBLKS DS    1H                  DEFAULT BLKSIZE                      00115800
DFLTLREC DS    1H                  DEFAULT LRECL                        00115900
DFLTBUFN DS    AL1                 DEFAULT BUFNO                        00116000
DFLTRECF DS    1BL1                DEFAULT RECFM                        00116100
*                                                                       00116200
*        DEFINE THE DEFAULT ATTRIBUTES BY TYPE                          00116300
*                                                                       00116400
DEFAULT1 DS    0H                                                       00116500
         DC    H'1680'         BLKSIZE=1680                             00116600
         DC    H'80'           LRECL=80                                 00116700
         DC    AL1(1)          BUFNO=1                                  00116800
         DC    B'10010000'     RECFM=FB                                 00116900
*                                                                       00117000
*                                                                       00117100
DEFAULT2 DS    0H                                                       00117200
         DC    H'3458'         BLKSIZE=3458                             00117300
         DC    H'133'          LRECL=133                                00117400
         DC    AL1(2)          BUFNO=2                                  00117500
         DC    B'10010100'     RECFM=FBA                                00117600
*                                                                       00117700
*                                                                       00117800
DEFAULT3 DS    0H                                                       00117900
         DC    H'400'          BLKSIZE=400                              00118000
         DC    H'80'           LRECL=80                                 00118100
         DC    AL1(1)          BUFNO=1                                  00118200
         DC    B'10010000'     RECFM=FB                                 00118300
*                                                                       00118400
*                                                                       00118500
DEFAULT4 DS    0H                                                       00118600
         DC    H'1680'         BLKSIZE=1680                             00118700
         DC    H'1680'         LRECL=1680                               00118800
         DC    AL1(0)          BUFNO=0                                  00118900
         DC    B'10000000'     RECFM=F                                  00119000
*                                                                       00119100
*                                                                       00119200
DEFAULT5 DS    0H                                                       00119300
         DC    H'3458'        BLKSIZE=3458                              00119400
         DC    H'133'         LRECL=133                                 00119500
         DC    AL1(1)         BUFNO=1                                   00119600
         DC    B'10010010'    RECFM=FBM                                 00119700
*                                                                       00119800
*                                                                       00119900
DEFAULT6 DS    0H                                                       00119905
         DC    H'13030'        BLKSIZE=13030                            00119910
         DC    H'13030'        LRECL=13030                              00119915
         DC    AL1(0)          BUFNO=0                                  00119920
         DC    B'11000000'     RECFM=U                                  00119925
*                                                                       00119930
*                                                                       00119935
DEFAULT7 DS    0H                                                       00119940
         DC    AL2(FILEBYTS)      BLKSIZE=FILEBYTS                      00119945
         DC    AL2(FILEBYTS)      LRECL=FILEBYTS                        00119950
         DC    AL1(0)             BUFNO=0                               00119955
         DC    B'10000000'        RECFM=F                               00119960
*                                                                       00119965
*                                                                       00119970
         EJECT                                                          00120000
         SPACE 5                                                        00120100
*********************************************************************** 00120200
*                                                                     * 00120300
*                                                                     * 00120400
*        INPUT - OUTPUT  ERROR ROUTINES                               * 00120500
*                                                                     * 00120600
*                                                                     * 00120700
*                                                                     * 00120800
*        SYNAD AND EOD ERROR ROUTINES FOR INITIAL LOADING OF THE      * 00120900
*        XPL PROGRAM                                                  * 00121000
*                                                                     * 00121100
*                                                                     * 00121200
*********************************************************************** 00121300
         SPACE 2                                                        00121400
EODPGM   STM   0,2,ABEREGS         SAVE REGISTERS                       00121500
         LA    1,PGMEOD            UNEXPECTED EOD WHILE READING IN      00121600
*                                  THE XPL PROGRAM                      00121700
         B     ABEND               GO TO ABEND ROUTINE                  00121800
         SPACE 2                                                        00121900
ERRPGM   STM   0,2,ABEREGS         SAVE REGISTERS                       00122000
         MVI   ACSMETH,2          BSAM                                  00122010
         BAL   10,PSYNADAF                                              00122020
         LA    1,PGMERR            SYNAD ERROR WHILE READING IN THE     00122100
*                                  XPL PROGRAM                          00122200
         B     ABEND               GO TO ABEND ROUTINE                  00122300
         SPACE 2                                                        00122400
*********************************************************************** 00122500
*                                                                     * 00122600
*                                                                     * 00122700
*        SYNAD AND EOD ROUTINES FOR INPUT(I),  I = 0,1, ...  ,&INPUTS * 00122800
*                                                                     * 00122900
*********************************************************************** 00123000
         SPACE 3                                                        00123100
         USING SAVE+4096,12                                             00123200
PDSEOD   SR    0,0                                                      00123300
         USING IPDSDATA,PARM2                                           00123400
         ST    0,INBUFSIZ          RESET # BYTES READ TO FORCE READ     00123500
         DROP  PARM2                                                    00123600
         B     RETNEOF             RETURN A NULL STRING                 00123700
         SPACE 2                                                        00123800
IPDSYNAD STM   0,2,ABEREGS                                              00123900
         MVI   ACSMETH,1          BPAM                                  00123910
         BAL   10,PSYNADAF                                              00123920
IPDSBAD  EQU   *                                                        00123930
         LA    1,IPDSSYND          ABEND CODE                           00124000
         B     ABEND                                                    00124100
         SPACE 2                                                        00124200
INEOD    L     2,SAVREG+PARM2*4    PICK UP SUBCODE SPECIFYING WHICH     00124300
*                                  INPUT FILE                           00124400
         SLL   2,2                 SUBCODE*4                            00124500
         L     2,GETDCBS(2)        FETCH DCB ADDRESS                    00124600
         USING IHADCB,2                                                 00124700
         ST    2,OCDCB             STORE IT FOR THE CLOSE SVC           00124800
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST           00124900
         CLOSE ,MF=(E,OCDCB)       CLOSE THE OFFENDING FILE             00125000
         B     RETNEOF        RETURN EOF INDICATION                     00125010
         SPACE 1                                                        00125100
PCLOSE   DS    0H                                                       00125200
         XC    DCBDDNAM,DCBDDNAM   MARK THE FILE PERMANENTLY UNUSABLE   00125300
         DROP  2                                                        00125400
         B     RETNEOF             GO RETURN AN END OF FILE INDICATION  00125500
         SPACE 2                                                        00125600
INSYNAD  STM   0,2,ABEREGS         SAVE REGISTERS                       00125700
         MVI   ACSMETH,3          QSAM                                  00125710
         BAL   10,PSYNADAF                                              00125720
         LA    1,INSYND            SYNAD ERROR ON AN INPUT FILE         00125800
         B     INERR               BRANCH TO ERROR ROUTINE              00125900
         SPACE 1                                                        00126000
INEOD2   LA    1,INEODAB           EOD ON AN INPUT FILE                 00126100
*                                  ATTEMPT TO READ AFTER AN EOD SIGNAL  00126200
INERR    A     1,SAVREG+PARM2*4    SUBCODE INDICATING WHICH INPUT FILE  00126300
         B     ABEND               BRANCH TO ABEND ROUTINE              00126400
         SPACE 2                                                        00126500
*********************************************************************** 00126600
*                                                                     * 00126700
*                                                                     * 00126800
*        SYNAD ERROR ROUTINES FOR OUTPUT FILES                        * 00126900
*                                                                     * 00127000
*                                                                     * 00127100
*********************************************************************** 00127200
         SPACE 2                                                        00127300
OUTSYNAD STM   0,2,ABEREGS         SAVE REGISTERS                       00127400
         MVI   ACSMETH,3          QSAM                                  00127410
         BAL   10,PSYNADAF                                              00127420
OUTBAD   EQU   *                                                        00127430
         LA    1,OUTSYND           SYNAD ERROR ON OUTPUT FILE           00127500
         B     INERR                                                    00127600
         SPACE 2                                                        00127700
OPDSYNAD STM   0,2,ABEREGS         SAVE REGISTERS                       00127800
         MVI   ACSMETH,1          BPAM                                  00127810
         BAL   10,PSYNADAF                                              00127820
OPDSBAD  EQU   *                                                        00127830
         LA    1,OPDSSYND          SYNAD ERROR ON PDS FILE              00127900
         B     ABEND               GO TO ERROR ROUTINE                  00128000
         SPACE 2                                                        00128100
*********************************************************************** 00128200
*                                                                     * 00128300
*        SYNAD AND EOD ROUTINES FOR DIRECT ACCESS FILE I/O            * 00128400
*                                                                     * 00128500
*********************************************************************** 00128600
         SPACE 2                                                        00128700
FILESYND STM   0,2,ABEREGS         SAVE REGISTERS                       00128800
         MVI   ACSMETH,2          BSAM                                  00128810
         BAL   10,PSYNADAF                                              00128820
FILEBAD  EQU   *                                                        00128830
         LA    1,FLSYND            SYNAD ERROR ON DIRECT ACCESS FILE    00128900
         B     FILERR              GO TO ERROR ROUTINE                  00129000
         SPACE 1                                                        00129100
FILEEOD  STM   0,2,ABEREGS         SAVE REGISTERS                       00129200
         LA    1,FLEOD             EOD ERROR ON DIRECT ACCESS FILE      00129300
         SPACE 1                                                        00129400
FILERR   L     2,SAVREG+SVCODE*4   SERVICE CODE                         00129500
         LA    0,RD1-8             COMPUTE WHICH DIRECT ACCESS FILE     00129600
         SR    2,0                 SERVICE_CODE - 1ST SERVICE CODE      00129700
         SRL   2,3                 DIVIDE BY 8                          00129800
         AR    1,2                                                      00129900
*                                  FALL THROUGH TO ABEND ROUTINE        00130000
         SPACE 2                                                        00130100
*********************************************************************** 00130200
*                                                                     * 00130300
*                                                                     * 00130400
*        ABEND ROUTINE FOR ALL I/O ERRORS                             * 00130500
*                                                                     * 00130600
*                                                                     * 00130700
*********************************************************************** 00130800
         SPACE 2                                                        00130900
ABEND    DS    0H                                                       00131000
         ST    1,ABESAVE                                                00131010
         CLOSE (OUTPUT0)                                                00131020
         L     1,ABESAVE                                                00131030
         TM    FLAGS,DUMPBIT       IS A CORE DUMP DESIRED ?             00131100
         BZ    NODUMP              NO, ABEND QUIETLY                    00131200
         SPACE 1                                                        00131300
         ABEND (1),DUMP            ABEND WITH A DUMP                    00131400
         SPACE 1                                                        00131500
NODUMP   DS    0H                                                       00131600
         ABEND (1)                 ABEND WITHOUT A DUMP                 00131700
         SPACE 2                                                        00131800
*********************************************************************** 00131900
*                                                                     * 00132000
*                                                                     * 00132100
*        ROUTINE TO FORCE AN ABEND DUMP WHEN REQUESTED BY THE         * 00132200
*        XPL PROGRAM BY MEANS OF THE STATEMENT:                       * 00132300
*                                                                     * 00132400
*        CALL  EXIT  ;                                                * 00132500
*                                                                     * 00132600
*                                                                     * 00132700
*********************************************************************** 00132800
         SPACE 2                                                        00132900
USEREXIT DS    0H                                                       00133000
         STM   0,2,ABEREGS         SAVE REGISTERS                       00133100
         LTR  0,0             CHECK USER SUPPLIED ABEND CODE            00133200
         BM   BADEXIT         IT MUST BE POSITIVE                       00133210
         LA   1,999           BUT LESS THAN 999                         00133220
         CR   0,1                                                       00133230
         BNH  SETEXIT                                                   00133240
BADEXIT  LA   0,999           SET BAD ABEND CODE TO 999                 00133250
SETEXIT  LA   1,USERABE       GET BASE USER ABEND CODE                  00133260
         AR   1,0             ADD IN USER SUPPLIED CODE                 00133270
         B    ABEND           DO ABEND                                  00133280
         DROP  12                                                       00133400
         SPACE 2                                                        00133405
*                                                                       00133410
* ROUTINE TO PRINT OUT SYNADAF INFO FOR I/O ERRORS                      00133415
*                                                                       00133420
         SPACE 2                                                        00133425
PSYNADAF LA    15,0(,15)          ZERO H/O BYTE                         00133430
         O     15,ACSMETH         PUT IN ACCESS METHOD CODE             00133435
         SVC   68                 ISSUE SVC                             00133440
         DROP  13                                                       00133445
         L     2,4(,13)                                                 00133450
         USING SAVE,2                                                   00133455
         MVC   SYNADMSG,50(1)     SAVE MESSAGE                          00133460
         SYNADRLS                                                       00133465
         DROP  2                                                        00133470
         USING SAVE,13                                                  00133475
         LA    1,WTPM                                                   00133480
         SVC   35                 'WTO' TO PROGRAMMER                   00133485
         BR    10                 RETURN TO CALLER                      00133490
         EJECT                                                          00133500
         SPACE 5                                                        00133600
*********************************************************************** 00133700
*                                                                     * 00133800
*                                                                     * 00133900
*        DISPATCHER FOR ALL SERVICE REQUESTS FROM THE XPL PROGRAM     * 00134000
*                                                                     * 00134100
*                                                                     * 00134200
*********************************************************************** 00134300
         SPACE 2                                                        00134400
         DROP  13                                                       00134500
         USING ENTRY,SELF                                               00134600
ENTRY    DS    0H                  XPL PROGRAMS ENTER HERE              00134700
         STM   0,15,SAVREG         SAVE REGISTERS                       00134800
         L     13,ASAVE            ADDRESS OF OS SAVE AREA              00134900
         DROP  SELF                                                     00135000
         USING SAVE,13                                                  00135100
         LR    12,13          SET UP SECONDARY BASE                     00135105
         A     12,F4096                                                 00135110
         USING SAVE+4096,12                                             00135115
         LR    11,12          SET UP TERTIARY BASE                      00135120
         A     11,F4096                                                 00135125
         USING SAVE+8192,11                                             00135130
         SPACE 1                                                        00135400
         LTR   SVCODE,SVCODE       CHECK THE SERVICE CODE FOR VALIDITY  00135500
         BNP   BADCODE             SERVICE CODE MUST BE > 0             00135600
         C     SVCODE,MAXCODE      AND < ENDSERV                        00135700
         BH    BADCODE             GO ABEND                             00135800
         SPACE 1                                                        00135900
TABLE    B     TABLE(SVCODE)       GO DO THE SERVICE                    00136000
         SPACE 1                                                        00136100
         ORG   TABLE+GETC                                               00136200
         B     GET                 READ INPUT FILE                      00136300
         SPACE 1                                                        00136400
         ORG   TABLE+PUTC                                               00136500
         B     PUT                 WRITE OUTPUT FILE                    00136600
         SPACE 1                                                        00136700
         ORG   TABLE+LINENUM                                            00136800
         B     GETCNT              GET LINE NUMBER                      00136900
         SPACE 1                                                        00137000
         ORG   TABLE+SETLNLIM                                           00137100
         B     SETCNT              SET LINE COUNT LIMIT                 00137200
         SPACE 1                                                        00137300
         ORG   TABLE+EXDMP                                              00137400
         B     USEREXIT            TERMINATE VIA ABEND (OPTIONAL DUMP)  00137500
         SPACE 1                                                        00137600
         ORG   TABLE+GTIME                                              00137700
         B     GETIME              RETURN TIME AND DATE                 00137800
         SPACE 1                                                        00137900
         ORG   TABLE+RSVD1                                              00138000
         B     EXIT                (UNUSED)                             00138100
         SPACE 1                                                        00138200
         ORG   TABLE+RSVD2                                              00138300
         B     LINKPGMS            LINK                                 00138400
         SPACE 1                                                        00138500
         ORG   TABLE+RSVD3                                              00138600
         B     GETPARM             PARM_FIELD                           00138700
         SPACE 1                                                        00138800
         ORG   TABLE+RSVD4                                              00138900
         B     MONITOR             MONITOR                              00139000
         SPACE 1                                                        00139100
         ORG   TABLE+RSVD5                                              00139200
         B     EXIT                (UNUSED)                             00139300
         SPACE 1                                                        00139400
         ORG   TABLE+RSVD6                                              00139500
         B     EXIT                (UNUSED)                             00139600
         SPACE 2                                                        00139700
*********************************************************************** 00139800
*                                                                     * 00139900
*                                                                     * 00140000
*        DYNAMICALLY GENERATE THE DISPATCHING TABLE ENTRIES FOR       * 00140100
*        FILE I/O SERVICES.                                           * 00140200
*                                                                     * 00140300
*                                                                     * 00140400
*********************************************************************** 00140500
         SPACE 2                                                        00140600
&I       SETA  1                   LOOP INDEX                           00140700
.DBR1    AIF   (&I GT &FILES).DBR2                                      00140800
*                                  FINISHED ?                           00140900
         ORG   TABLE+RD&I                                               00141000
         B     READ                BRANCH TO FILE READ ROUTINE          00141100
         ORG   TABLE+WRT&I                                              00141200
         B     WRITE               BRANCH TO FILE WRITE ROUTINE         00141300
&I       SETA  &I+1                INCREMENT COUNTER                    00141400
         AGO   .DBR1               LOOP BACK                            00141500
.DBR2    ANOP                                                           00141600
         SPACE 2                                                        00141700
         ORG   TABLE+ENDSERV       RESET PROGRAM COUNTER                00141800
         SPACE 2                                                        00141900
*********************************************************************** 00142000
*                                                                     * 00142100
*                                                                     * 00142200
*        COMMON EXIT ROUTINE FOR RETURN TO THE XPL PROGRAM            * 00142300
*                                                                     * 00142400
*                                                                     * 00142500
*********************************************************************** 00142600
         SPACE 2                                                        00142700
EXIT     DS    0H                                                       00142800
         LM    0,15,SAVREG         RESTORE REGISTERS                    00142900
         DROP  13                                                       00143000
         USING ENTRY,SELF                                               00143100
         SPACE 1                                                        00143200
         BR    14                  RETURN TO THE XPL PROGRAM            00143300
         SPACE 1                                                        00143400
         DROP  SELF                                                     00143500
         USING SAVE,13                                                  00143600
         SPACE 2                                                        00143700
*********************************************************************** 00143800
*                                                                     * 00143900
*        ROUTINE TO ABEND IN CASE OF BAD SERVICE CODES                * 00144000
*                                                                     * 00144100
*********************************************************************** 00144200
         SPACE 2                                                        00144300
BADCODE  STM   0,2,ABEREGS         SAVE REGISTERS                       00144400
         LA    1,CODEABE           BAD SERVICE CODE ABEND               00144500
         B     ABEND               GO ABEND                             00144600
         SPACE 2                                                        00144700
*********************************************************************** 00144800
*                                                                     * 00144900
*           ROUTINE TO ABORT IN CASE OF EXCESSIVE PRINTING            * 00145000
*                                                                     * 00145100
*********************************************************************** 00145200
         SPACE 2                                                        00145300
PAGEAB   MVC   0(L'PABM,1),PABM    MOVE PAGE-ABORT MSG TO OUTPUT        00145400
         MVI   L'PABM(1),C' '         AND FILL WITH BLANKS              00145500
         MVC   L'PABM+1(133-L'PABM-1,1),L'PABM(1)                       00145600
         LA    1,PAGEABE           ABEND CODE FOR TOO MUCH PRINT        00145700
         B     ABEND                                                    00145800
         SPACE 3                                                        00145805
*********************************************************************** 00145808
*                                                                       00145810
*        SMALL DATA AREA TO LET MONITOR GET ADDRESSABLE UPON RETURN     00145815
*        FROM XPL                                                       00145820
*                                                                       00145825
*********************************************************************** 00145828
         SPACE 2                                                        00145830
         DS    0F                                                       00145835
ASAVE    DC    A(SAVE)        ADDRESS OF OS SAVE AREA                   00145840
ABASE1   DC    A(BASE1)       BASE ADDRESS FOR INITIALIZATION           00145845
SAVREG   DC    16F'0'         SAVE AREA FOR THE SUBMONITOR              00145850
SAVE813  DC    6F'0'          SAVE AREA FOR CALLING LOW CORE ROUTINE    00145870
         EJECT                                                          00145900
         SPACE 5                                                        00146000
*********************************************************************** 00146100
*                                                                     * 00146200
*                                                                     * 00146300
*        INPUT ROUTINE FOR READING SEQUENTIAL INPUT FILES             * 00146400
*                                                                     * 00146500
*                                                                     * 00146600
*        INPUT TO THIS ROUTINE IS:                                    * 00146700
*                                                                     * 00146800
*      PARM1   ADDRESS OF THE NEXT AVAILABLE SPACE IN THE PROGRAMS    * 00146900
*              DYNAMIC STRING AREA  (FREEPOINT)                       * 00147000
*                                                                     * 00147100
*      SVCODE  THE SERVICE CODE FOR INPUT                             * 00147200
*                                                                     * 00147300
*      PARM2   A SUBCODE DENOTING WHICH INPUT FILE,                   * 00147400
*              INPUT(I),     I = 0,1, ... ,&INPUTS                    * 00147500
*                                                                     * 00147600
*        THE ROUTINE RETURNS:                                         * 00147700
*                                                                     * 00147800
*      PARM1   A STANDARD XPL STRING DESCRIPTOR POINTING AT THE INPUT * 00147900
*              RECORD WHICH IS NOW AT THE TOP OF THE STRING AREA      * 00148000
*                                                                     * 00148100
*      SVCODE  THE NEW VALUE FOR FREEPOINT, UPDATED BY THE LENGTH OF  * 00148200
*              THE RECORD JUST READ IN                                * 00148300
*                                                                     * 00148400
*                                                                     * 00148500
*        A STANDARD XPL STRING DESCRIPTOR HAS:                        * 00148600
*                                                                     * 00148700
*        BITS  0-7                 (LENGTH - 1) OF THE STRING         * 00148800
*        BITS  8-31                ABSOLUTE ADDRESS OF THE STRING     * 00148900
*                                                                     * 00149000
*                                                                     * 00149100
*                                                                     * 00149200
*********************************************************************** 00149300
         SPACE 2                                                        00149400
GET      DS    0H                                                       00149500
         LA    SVCODE,&INPUTS      CHECK THAT THE SUBCODE IS VALID      00149600
         LTR   PARM2,PARM2         SUBCODE MUST BE >= 0                 00149700
         BM    BADGET                                                   00149800
         CR    PARM2,SVCODE        AND <= &INPUTS                       00149900
         BH    BADGET              NOT A REAL FILE                      00150000
         SLL   PARM2,2             SUBCODE*4                            00150100
         L     3,GETDCBS(PARM2)    ADDRESS OF DCB FOR THE FILE          00150200
         USING IHADCB,3                                                 00150300
         TM    DCBDSORG,POBITS                                          00150400
         BO    PDSREAD        READ A PDS ATASET                         00150500
         NC    DCBDDNAM,DCBDDNAM   HAS THE FILE BEEN PERMANENTLY        00150600
*                                  CLOSED ?                             00150700
         BZ    INEOD2              YES, SO TERMINATE THE JOB            00150800
         SPACE 1                                                        00150900
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   00151000
         BO    GETOPEN             YES                                  00151100
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC       00151200
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST           00151300
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        00151400
         LR    2,3                 COPY DCB ADDRESS                     00151500
         TM    DCBOFLGS,OPENBIT    WAS THE FILE OPENED SUCCESSFULLY ?   00151600
         BZ    PCLOSE              NO, MARK FILE PERMANENTLY CLOSED AND 00151700
*                                  RETURN EOD INDICATION TO THE PROGRAM 00151800
         SPACE 2                                                        00151900
GETOPEN  DS    0H                                                       00152000
         GET   (3)                 LOCATE MODE GET                      00152100
         SPACE 1                                                        00152200
*********************************************************************** 00152300
*                                                                     * 00152400
*        USING LOCATE MODE, THE ADDRESS OF THE NEXT INPUT BUFFER      * 00152500
*        IS RETURNED IN R1                                            * 00152600
*                                                                     * 00152700
*********************************************************************** 00152800
         SPACE 1                                                        00152900
         L     2,SAVREG+PARM1*4    FETCH THE STRING DESCRIPTOR          00153000
         LA    2,0(,2)             ADDRESS PART ONLY                    00153100
         LH    3,DCBLRECL          RECORD LENGTH                        00153200
         DROP  3                                                        00153300
         BCTR  3,0                 LENGTH - 1                           00153400
         EX    3,GETMOVE           MOVE THE CHARACTERS                  00153500
         ST    2,SAVREG+PARM1*4    BUILD UP A STRING DESCRIPTOR         00153600
         STC   3,SAVREG+PARM1*4    LENGTH FIELD                         00153700
         LA    2,1(2,3)            NEW FREE POINTER                     00153800
         ST    2,SAVREG+SVCODE*4                                        00153900
         B     EXIT                RETURN TO THE XPL PROGRAM            00154000
         SPACE 2                                                        00154100
*********************************************************************** 00154200
*                                                                     * 00154300
*        RETURN A NULL STRING DESCRIPTOR AS AN END OF FILE            * 00154400
*        INDICATION THE FIRST TIME AN INPUT REQUEST FIND THE          * 00154500
*        END OF DATA CONDITION                                        * 00154600
*                                                                     * 00154700
*********************************************************************** 00154800
         SPACE 2                                                        00154900
RETNEOF  DS    0H                                                       00155000
         MVC   SAVREG+SVCODE*4(4),SAVREG+PARM1*4                        00155100
*                                  RETURN FREEPOINT UNTOUCHED           00155200
         XC    SAVREG+PARM1*4(4),SAVREG+PARM1*4                         00155300
*                                  RETURN A NULL STRING DESCRIPTOR      00155400
         B     EXIT                RETURN TO THE XPL PROGRAM            00155500
         SPACE 3                                                        00155600
*********************************************************************** 00155700
*                                                                     * 00155800
*        ROUTINE TO ABEND IN CASE OF AN INVALID SUBCODE               * 00155900
*                                                                     * 00156000
*********************************************************************** 00156100
         SPACE 2                                                        00156200
BADGET   STM   0,2,ABEREGS         SAVE REGISTERS                       00156300
         LA    1,GFABE             INVALID GET SUBCODE                  00156400
         B     INERR               GO ABEND                             00156500
         EJECT                                                          00156600
PDSREAD  L     4,IWRKADDR                                               00156700
         L     PARM2,0(PARM2,4)                                         00156800
         USING IPDSDATA,PARM2                                           00156900
         USING IHADCB,3                                                 00157000
         TM    DCBOFLGS,OPENBIT    IS IT OPEN?                          00157100
         BNO   INPDSERR            SHOULD HAVE BEEN OPENED              00157200
         L     4,INBLKDAT          NEXT LRECL LOC                       00157300
         L     5,INAREA            BUFFER ADDRESS                       00157400
         C     4,INBUFSIZ          STILL SOMETHING IN BUFFER?           00157500
         BL    NEXTREC             YES - GO READ IT                     00157600
         READ  PDSDECB,SF,(3),(5),'S',MF=E                              00157700
         LH    7,DCBBLKSI          BLKSIZE                              00157800
         SR    4,4                 RESET OFFSET                         00157900
         CHECK PDSDECB             WAIT FOR READ TO COMPLETE            00158000
         L     6,PDSDECB+16        IOB ADDRESS                          00158100
         SH    7,14(0,6)           BLKSIZE-RESIDUAL_COUNT=BYTES READ    00158200
         ST    7,INBUFSIZ          SAVE COUNT                           00158300
NEXTREC  LR    6,2                                                      00158400
         L     2,SAVREG+PARM1*4    WHERE TO PUT STRING                  00158500
         LA    2,0(,2)             ADDRESS ONLY                         00158600
         LH    3,DCBLRECL          RECORD LENGTH                        00158700
         DROP  3                                                        00158800
         BCTR  3,0                 LENGTH - 1                           00158900
         LA    1,0(4,5)            RECORD LOCATION                      00159000
         EX    3,GETMOVE           MOVE THE STRING                      00159100
         ST    2,SAVREG+PARM1*4    BUILD THE DESCRIPTOR                 00159200
         STC   3,SAVREG+PARM1*4    LENGTH FIELD                         00159300
         LA    2,1(2,3)            NEW FREEPOINT                        00159400
         ST    2,SAVREG+SVCODE*4   SAVE FOR RETURN                      00159500
         LA    4,1(3,4)            NEW RELATIVE BUFFER POINTER          00159600
         LR    2,6                                                      00159700
         ST    4,INBLKDAT          SAVE FOR NEXT TIME                   00159800
         B     EXIT                RETURN TO XPL                        00159900
         DROP  PARM2                                                    00160000
         SPACE 3                                                        00160100
INPDSERR STM   0,2,ABEREGS         SAVE REGS                            00160200
         LA    1,IPDSOERR          ABEND CODE                           00160300
         B     INERR                                                    00160400
         EJECT                                                          00160500
*********************************************************************** 00160600
*                                                                     * 00160700
*                                                                     * 00160800
*                                                                     * 00160900
*        ROUTINE FOR WRITING SEQUENTIAL OUTPUT FILES                  * 00161000
*                                                                     * 00161100
*                                                                     * 00161200
*        INPUT TO THIS ROUTINE:                                       * 00161300
*                                                                     * 00161400
*      PARM1   XPL STRING DESCRIPTOR OF THE STRING TO BE OUTPUT       * 00161500
*                                                                     * 00161600
*      PARM2   SUBCODE INDICATING  OUTPUT(I),  I = 0,1, ... ,&OUTPUTS * 00161700
*                                                                     * 00161800
*      SVCODE  THE SERVICE CODE FOR OUTPUT                            * 00161900
*                                                                     * 00162000
*                                                                     * 00162100
*        THE STRING NAMED BY THE DESCRIPTOR IS PLACED IN THE NEXT     * 00162200
*        OUTPUT BUFFER OF THE SELECTED FILE.  IF THE STRING IS        * 00162300
*        SHORTER THAN THE RECORD LENGTH OF THE FILE THEN THE          * 00162400
*        REMAINDER OF THE RECORD IS PADDED WITH BLANKS.  IF THE       * 00162500
*        STRING IS LONGER THAN THE RECORD LENGTH OF THE FILE          * 00162600
*        THEN IT IS TRUNCATED ON THE RIGHT TO FIT.  IF THE SUBCODE    * 00162700
*        SPECIFIES OUTPUT(0) THEN A SINGLE BLANK IS CONCATENATED      * 00162800
*        ON TO THE FRONT OF THE STRING TO SERVE AS CARRIAGE CONTROL.  * 00162900
*                                                                     * 00163000
*                                                                     * 00163100
*********************************************************************** 00163200
         SPACE 2                                                        00163300
PUT      DS    0H                                                       00163400
         ST    PARM1,MOVEADR       SAVE THE STRING DESCRIPTOR           00163500
         LTR   PARM2,PARM2         CHECK SUBCODE FOR VALIDITY           00163600
         BM    BADPUT              SUBCODE MUST BE >= 0                 00163700
         LA    SVCODE,&OUTPUTS                                          00163800
         CR    PARM2,SVCODE        AND <= &OUTPUTS                      00163900
         BH    BADPUT                                                   00164000
         SLL   PARM2,2                                                  00164100
         L     3,PUTDCBS(2)        GET THE DCB ADDRESS                  00164200
         USING IHADCB,3                                                 00164300
         TM    DCBDSORG,POBITS IS IT PO?                                00164400
         BO    PDSWRITE                                                 00164500
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   00164600
         BO    PUTOPEN             YES, GO DO THE OUTPUT                00164700
         ST    3,OCDCB             STORE DCB ADDRESS FOR THE OPEN SVC   00164800
         MVI   OCDCB,X'8F'         FLAG END OF PARAMETER LIST AND SET   00164900
*                                  FLAG INDICATING OPENING FOR OUTPUT   00165000
         SPACE 1                                                        00165100
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        00165200
         SPACE 1                                                        00165300
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFULL ?           00165400
         BZ    OUTBAD             NO, OUTPUT SYNAD ERROR                00165500
         SPACE 1                                                        00165600
PUTOPEN  DS    0H                                                       00165700
         PUT   (3)                 LOCATE MODE PUT                      00165800
         SPACE 1                                                        00165900
*********************************************************************** 00166000
*                                                                     * 00166100
*        USING LOCATE MODE, THE ADDRESS OF THE NEXT OUTPUT BUFFER     * 00166200
*        IS RETURNED IN  R1.                                          * 00166300
*                                                                     * 00166400
*********************************************************************** 00166500
         SPACE 1                                                        00166600
         OI    FLAGS,OUTZBIT       INITIALLY ASSUME OUTPUT(0)           00166700
         MVI   CCB,C' '            INITIALIZE CARRIAGE CONTROL BYTE     00166800
         SR    15,15               CLEAR REGISTER 15                    00166900
         C     15,MOVEADR          IS THE STRING NULL (DESCRIPTOR = 0)  00167000
         BE    NULLPUT             YES, SO PUT OUT A BLANK RECORD       00167100
         IC    15,MOVEADR          LENGTH-1 OF THE STRING               00167200
         LA    14,1(15)            REAL LENGTH OF THE STRING            00167300
         C     PARM2,F4            CHECK I IN OUTPUT(I):                00167400
         BL    PUT0                   OUTPUT(0)                         00167500
         BH    PUTGT1                 OUTPUT(>1)                        00167600
         L     2,MOVEADR              OUTPUT(1)                         00167700
         MVC   CCB(1),0(2)         FETCH CC BYTE                        00167800
         LA    2,1(,2)             INCR ADDRESS PAST CC BYTE            00167900
         ST    2,MOVEADR                                                00168000
         BCTR  15,0                ALLOW FOR REMOVED CCB                00168100
         L     2,LINECT            FETCH LINE COUNTER                   00168200
         CLI   CCB,C'1'            PAGE EJECT?                          00168300
         BE    MAYEJECT                                                 00168400
         CLI   CCB,C'0'            SPACE 2?                             00168500
         BE    SP2                                                      00168600
         CLI   CCB,C'-'            SPACE 3?                             00168700
         BE    SP3                                                      00168800
         CLI   CCB,C'+'            SPACE 0?                             00168900
         BE    SP0                                                      00169000
         CLI   CCB,C' '            SPACE 1?                             00169100
         BE    SP1A                                                     00169200
         CLI   CCB,C'2'            NEW SUBHEADING?                      00169300
         BE    HDG2                                                     00169400
         CLI   CCB,C'H'            SPECIAL HEADING CODE?                00169500
         BNE   TESTZL             NO.  OUTPUT WITH NO OTHER EFFECTS.    00169600
         MVI   HEADING+1,C' '                                           00169700
         MVC   HEADING+2(119),HEADING+1                                 00169800
         S     14,F2               NEED LENGTH - 1 - CCB                00169900
         BM    EJECT                                                    00170000
         L     2,MOVEADR                                                00170100
         EX    14,MOVEHDG          MOVE NEW HEADING INTO PLACE          00170200
         LA    14,1                SET UP BLANK LINE TO FOLLOW          00170300
         B     EJECT                                                    00170400
         SPACE                                                          00170500
HDG2     S     14,F2               LENGTH - 1 - CCB                     00170600
         BM    NOHDG               INDICATES NO SUBHEADING TO BE USED   00170700
         L     2,MOVEADR           FTECH ADDRESS OF STRING              00170800
         MVI   HEADING2+1,C' '                                          00170900
         MVC   HEADING2+2(131),HEADING2+1                               00171000
         EX    14,MOVEHDG2         MOVE NEW HEADING IN                  00171100
         OI    FLAGS,H2ACTIVE      INDICATE SUBHEADING IN USE           00171200
         MVI   EJLNO+1,X'04'       LINE NUMBER AFTER EJECT W/SUBHEADING 00171300
         MVI   NULCCB,C' '         CCB FOR NULL LINE AFTER 2 HEADINGS   00171400
         MVI   NOTNLCCB,C'0'       CCB FOR NON-NULL LINE AFTER HEADINGS 00171500
         MVI   FIRSTNUM,X'05'      LINE NUM OF FIRST LINE ON PAGE       00171600
         B     HDG                                                      00171700
NOHDG    NI    FLAGS,ALLBITS-H2ACTIVE                                   00171800
         MVI   EJLNO+1,X'03'       LINE NUMBER AFTER EJECT W/NO SUBHDG  00171900
         MVI   NULCCB,C'0'         CCB FOR NULL LINE AFTER ONE HEADING  00172000
         MVI   NOTNLCCB,C'-'       CCB FOR NON-NULL LINE AFTER ONE HDG  00172100
         MVI   FIRSTNUM,X'04'                                           00172200
HDG      LA    14,1                FAKE A NULL LINE                     00172300
         MVI   CCB,C'+'            CHANGE CCB TO NO SPACE               00172400
         L     2,LINELIM           PROHIBIT NEW PAGE                    00172500
SP0      CH    2,EJLNO             AVOID BEING TOO CLOSE TO HDG         00172600
         BH    TESTZL              FAR ENOUGH AWAY ALREADY              00172700
FORCESP1 MVI   CCB,C' '            NOT FAR ENOUGH. CHANGE TO SP1        00172800
         B     SP1A                                                     00172900
         SPACE                                                          00173000
SP3      CH    2,EJLNO             NO UPSPACE IF ONLY HEADING IS THERE  00173100
         BNH   FORCESP1                                                 00173200
         LA    2,3(,2)             INCR LINE COUNT BY 3                 00173300
         B     FULLCK                                                   00173400
         SPACE                                                          00173500
SP2      CH    2,EJLNO             NO UPSPACE IF ONLY HEADING IS THERE  00173600
         BNH   FORCESP1                                                 00173700
         LA    2,2(,2)             INCR LINE COUNT BY 2                 00173800
         B     FULLCK                                                   00173900
         SPACE                                                          00174000
MAYEJECT C     14,F1               IS THIS A SOLO CCB?                  00174100
         BH    EJECT               PROCEED IF NOT                       00174200
         CH    2,EJLNO             IF SO, ARE WE AT THE TOP OF THE PAGE 00174300
         BH    EJECT                                                    00174400
         MVI   0(1),C'+'           AT PAGE TOP, MAKE EJECT INTO SP 0    00174500
         B     TESTZL1                                                  00174600
         SPACE                                                          00174700
EJECT    AP    PAGENO,ONE          INCR PAGE NUMBER                     00174800
         MVC   ABEREGS(L'PAT),PAT                                       00174900
         ED    ABEREGS(L'PAT),PAGENO                                    00175000
         MVC   HEADING+129(4),ABEREGS+2                                 00175100
         MVC   0(133,1),HEADING    MOVE HEADING TO OUTPUT               00175200
         STM   14,15,ABEREGS                                            00175300
         PUT   (3)                 GET POINTER FOR NEXT LINE            00175400
         L     14,PAGECT           DECREMENT COUNT OF PAGES TO GO       00175500
         S     14,F1                  BEFORE PRINT-ABORT                00175600
         BM    PAGEAB              ABORT IF LIMIT EXCEEDED              00175700
         ST    14,PAGECT           STORE COUNT IF NOT                   00175800
         TM    FLAGS,H2ACTIVE      IS THERE A SUBHEADING?               00175900
         BNO   NOH2                                                     00176000
         MVC   0(133,1),HEADING2   MOVE SUBHEADING TO OUTPUT BUFFER     00176100
         PUT   (3)                                                      00176200
NOH2     EQU   *                                                        00176300
         LM    14,15,ABEREGS                                            00176400
         C     14,F1               SEE IF NEXT LINE IS NULL             00176500
         BH    EJNOTNUL            BRANCH IF NOT NULL                   00176600
         MVI   CCB,C'0'            LEAVE TWO SPACES AFTER HEADING       00176700
NULCCB   EQU   *-3                                                      00176800
         LA    2,3                                                      00176900
EJLNO    EQU   *-2                 LINE COUNT AFTER HEADING             00177000
         B     STCOUNT                                                  00177100
         SPACE                                                          00177200
EJNOTNUL MVI   CCB,C'-'            PRINT LINE, PRECEDED BY 3 SPACES     00177300
NOTNLCCB EQU   *-3                                                      00177400
         LA    2,4                 INITIAL LINE NUM OF FIRST LINE       00177500
FIRSTNUM EQU   *-1                 WHERE TO RESET FIRST LINE NUM        00177600
         B     STCOUNT                                                  00177700
         SPACE                                                          00177800
PUT0     LA    14,1(,14)           INCREASE REAL LENGTH BY 1 FOR CC     00177900
SP1      L     2,LINECT                                                 00178000
SP1A     LA    2,1(,2)                                                  00178100
FULLCK   C     2,LINELIM           PAGE TOO FULL?                       00178200
         BH    EJECT               YES.  EJECT & PRINT HEADING          00178300
STCOUNT  ST    2,LINECT            NO.   PRINT                          00178400
TESTZL   C     14,F1               TEST FOR NULL                        00178500
         BH    PUT2                BRANCH IF NOT                        00178600
         MVC   0(1,1),CCB          MOVE CCB TO OUTPUT,                  00178700
TESTZL1  MVI   1(1),C' '              FOLLOWED BY 1                     00178800
         MVC   2(131,1),1(1)          AND THEN 131 MORE BLANKS          00178900
         B     EXIT                                                     00179000
         SPACE                                                          00179100
PUTGT1   NI    FLAGS,ALLBITS-OUTZBIT     TURN OFF OUTZBIT               00179200
PUT2     LH    0,DCBLRECL          RECORD LENGTH OF THE FILE            00179300
         SR    0,14                RECORD LENGTH - REAL LENGTH          00179400
         BM    TOOLONG             RECORD LENGTH < REAL LENGTH          00179500
         BZ    MATCH               RECORD LENGTH = REAL LENGTH          00179600
*                                  RECORD LENGTH > REAL LENGTH          00179700
         OI    FLAGS,SFILLBIT+LFILLBIT                                  00179800
*                                  INDICATE PADDING REQUIRED            00179900
         S     0,F1                RECORD LENGTH - REAL LENGTH - 1      00180000
         BP    LONGMOVE            RECORD LENGTH - REAL LENGTH > 1      00180100
         NI    FLAGS,ALLBITS-LFILLBIT                                   00180200
*                                  RECORD LENGTH - REAL LENGTH = 1      00180300
*                                  IS A SPECIAL CASE                    00180400
LONGMOVE ST    0,FILLENG           SAVE LENGTH FOR PADDING OPERATION    00180500
         B     MOVEIT              GO MOVE THE STRING                   00180600
         SPACE 1                                                        00180700
TOOLONG  LH    15,DCBLRECL         REPLACE THE STRING LENGTH            00180800
*                                  WITH THE RECORD LENGTH               00180900
         BCTR  15,0                RECORD LENGTH - 1 FOR THE MOVE       00181000
MATCH    NI    FLAGS,ALLBITS-SFILLBIT-LFILLBIT                          00181100
*                                  INDICATE NO PADDING REQUIRED         00181200
         SPACE 1                                                        00181300
MOVEIT   TM    FLAGS,OUTZBIT       CHECK FOR OUTPUT(0)                  00181400
         BZ    MOVEIT2             OUTPUT(0) IS A SPECIAL CASE          00181500
         MVI   0(1),C' '           PROVIDE CARRIAGE CONTROL             00181600
CCB      EQU   *-3                                                      00181700
         LA    1,1(,1)             INCREMENT BUFFER POINTER             00181800
MOVEIT2  L     2,MOVEADR           STRING DESCRIPTOR                    00181900
         LA    2,0(,2)             ADDRESS PART ONLY                    00182000
         EX    15,MVCSTRNG         EXECUTE A MVC INSTRUCTION            00182100
         TM    FLAGS,SFILLBIT      IS PADDING REQUIRED ?                00182200
         BZ    EXIT                NO, RETURN TO THE XPL PROGRAM        00182300
         SPACE 1                                                        00182400
         AR    1,15                ADDRESS TO START PADDING - 1         00182500
         MVI   1(1),C' '           START THE PAD                        00182600
         TM    FLAGS,LFILLBIT      IS MORE PADDING REQUIRED ?           00182700
         BZ    EXIT                NO, RETURN TO XPL PROGRAM            00182800
         L     15,FILLENG          LENGTH OF PADDING NEEDED             00182900
         BCTR  15,0                LESS ONE FOR THE MOVE                00183000
         EX    15,MVCBLANK         EXECUTE MVC TO FILL IN BLANKS        00183100
         B     EXIT                RETURN TO THE XPL PROGRAM            00183200
         SPACE 1                                                        00183300
*********************************************************************** 00183400
*                                                                     * 00183500
*        FOR A NULL STRING OUTPUT A BLANK RECORD                      * 00183600
*                                                                     * 00183700
*********************************************************************** 00183800
         SPACE 1                                                        00183900
NULLPUT  C     PARM2,F4            SEE IF SYSPRINT                      00184000
         BH    NP1                 BRANCH IF NOT                        00184100
         LA    14,1                INDICATE ZERO LENGTH                 00184200
         B     SP1                 GO DO PAGINATION                     00184300
NP1      LH    15,DCBLRECL         RECORD LENGTH                        00184400
         S     15,F2               LESS TWO FOR THE MOVES               00184500
         MVI   0(1),C' '           INITIAL BLANK                        00184600
         EX    15,MVCNULL          EXECUTE MVC TO FILL IN THE BLANKS    00184700
         B     EXIT                RETURN TO THE XPL PROGRAM            00184800
         SPACE 1                                                        00184900
         DROP  3                                                        00185000
         SPACE 1                                                        00185100
*********************************************************************** 00185200
*                                                                     * 00185300
*        ROUTINE TO ABEND IN CASE OF AN INVALID SERVICE CODE          * 00185400
*                                                                     * 00185500
*********************************************************************** 00185600
         SPACE 2                                                        00185700
BADPUT   STM   0,2,ABEREGS         SAVE REGISTERS                       00185800
         LA    1,PFABE             INVALID PUT SUBCODE                  00185900
         B     INERR               GO ABEND                             00186000
         EJECT                                                          00186100
PDSWRITE L     4,OWRKADDR                                               00186200
         L     PARM2,0(PARM2,4)                                         00186300
         USING OPDSDATA,PARM2                                           00186400
         USING IHADCB,3                                                 00186500
         TM    DCBOFLGS,OPENBIT    IS IT OPEN?                          00186600
         BO    PDSOPEN             YES                                  00186700
         ST    3,OCDCB             STORE DCB ADDRESS                    00186800
         MVI   OCDCB,X'8F'    FLAG ARG LIST END AND INDICATE OUTPUT     00186900
         OPEN  ,MF=(E,OCDCB)       OPEN FILE                            00187000
         TM    DCBOFLGS,OPENBIT    WAS OPEN SUCESSFUL?                  00187100
         BZ    OPDSBAD            NO- SYNAD ERROR                       00187200
         GETBUF  (3),(4)       GET THE BUFFER                           00187300
         ST    4,AREADATA          SAVE CORE ADDRESS                    00187400
PDSOPEN  L     4,BLKDATA           GET LOC OF NEXT LRECL                00187500
         CH    4,DCBBLKSI          IS BUFFER FULL?                      00187600
         BL    FILLBUFF            NO - GO FILL SOME OF IT              00187700
         L     4,AREADATA          GET AREA ADDRESS                     00187800
         LH    5,DCBBLKSI          GET BLKSIZE                          00187900
         WRITE PDSDECB,SF,(3),(4),(5),MF=E                              00188000
         SR    4,4                 RESET NEXT LRECL                     00188100
         CHECK PDSDECB             WAIT FOR WRITE TO COMPLETE           00188200
FILLBUFF L     1,AREADATA          AREA ADDRESS                         00188300
         AR    1,4                 OFFSET INTO BUFFER                   00188400
         SR    15,15                                                    00188500
         C     15,MOVEADR          IS DESCRIPTOR NULL?                  00188600
         BE    NULLWRT             YES - OUTPUT A BLANK LINE            00188700
         IC    15,MOVEADR          LENGTH-1                             00188800
         LA    14,1(,15)           REAL LENGTH                          00188900
         LH    0,DCBLRECL          RECORD LENGTH                        00189000
         SR    0,14                RECORD LENGTH - REAL LENGTH          00189100
         BM    WTOOLONG            RECORD LENGTH < REAL LENGTH          00189200
         BZ    WMATCH              RECORD LENGTH = REAL LENGTH          00189300
         OI    FLAGS,SFILLBIT+LFILLBIT PADDING REQUIRED                 00189400
         S     0,F1                RECORD LENGTH - REAL LENGTH - 1      00189500
         BP    WLNGMOVE            RECORD LENGTH - REAL LENGTH > 1      00189600
         NI    FLAGS,ALLBITS-LFILLBIT RECORD LENGTH - REAL LENGTH = 1   00189700
WLNGMOVE ST    0,FILLENG           SAVE LENGTH                          00189800
         B     MOVEREC                                                  00189900
WTOOLONG LH    15,DCBLRECL         REPLACE STRING LENGTH WITH REC LNTH  00190000
         BCTR  15,0                                                     00190100
WMATCH   NI    FLAGS,ALLBITS-SFILLBIT-LFILLBIT NO PADDING               00190200
MOVEREC  LR    6,2                 SAVE REG 2                           00190300
         L     2,MOVEADR           STRING DESCRIPTOR                    00190400
         LA    2,0(,2)             ADDRESS ONLY                         00190500
         EX    15,MVCSTRNG         MOVE THE STRING                      00190600
         LR    2,6                 RESTORE REG 2                        00190700
         TM    FLAGS,SFILLBIT      SINGLE PAD REQUIRED?                 00190800
         BZ    INCRAREA            NO - DON'T PAD                       00190900
         AR    1,15                ADDRESS TO START PADDING             00191000
         MVI   1(1),C' '           START PAD                            00191100
         TM    FLAGS,LFILLBIT      MORE PADDING?                        00191200
         BZ    INCRAREA            NO - SKIP IT                         00191300
         L     15,FILLENG          LENGTH OF PAD                        00191400
         BCTR  15,0                LESS ONE FOR EXECUTE                 00191500
         EX    15,MVCBLANK         PAD IT                               00191600
         B     INCRAREA                                                 00191700
NULLWRT  LH    15,DCBLRECL         RECORD LENGTH                        00191800
         S     15,F2                                                    00191900
         MVI   0(1),C' '           ONE BLANK                            00192000
         EX    15,MVCNULL          AND ALL THE REST                     00192100
INCRAREA AH    4,DCBLRECL          INCREMENT BUFFER POINTER             00192200
         ST    4,BLKDATA           SAVE FOR NEXT WRITE                  00192300
         B     EXIT                                                     00192400
         DROP  3                                                        00192500
         DROP  PARM2                                                    00192600
         EJECT                                                          00192700
         SPACE 5                                                        00192800
*********************************************************************** 00192900
*                                                                     * 00193000
*                                                                     * 00193100
*                                                                     * 00193200
*        READ ROUTINE FOR DIRECT ACCESS FILE I/O                      * 00193300
*                                                                     * 00193400
*                                                                     * 00193500
*        INPUT TO THIS ROUTINE IS:                                    * 00193600
*                                                                     * 00193700
*      PARM1   CORE ADDRESS TO READ THE RECORD INTO                   * 00193800
*                                                                     * 00193900
*      SVCODE  SERVICE CODE INDICATING WHICH FILE TO USE              * 00194000
*                                                                     * 00194100
*      PARM2   RELATIVE RECORD NUMBER   0,1,2,3,...                   * 00194200
*                                                                     * 00194300
*                                                                     * 00194400
*                                                                     * 00194500
*********************************************************************** 00194600
         SPACE 2                                                        00194700
READ     DS    0H                                                       00194800
         ST    PARM1,RDECB+12      STORE ADDRESS                        00194900
         ST    PARM1,XDAPECB+60                                         00194910
         L     3,ARWDCBS-FILEORG(SVCODE)                                00195000
*                                  ADDRESS OF THE DCB FOR THIS FILE     00195100
         USING IHADCB,3                                                 00195200
         L     4,FWRKADDR                                               00195220
         L     4,0(4,SVCODE)  GET FILEDATA INFO ADDRESS                 00195240
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   00195300
         BO    READOPEN            YES, GO READ                         00195400
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC       00195500
         MVI   OCDCB,X'83'         FLAG END OF PARAMETER LIST           00195600
*                                  AND INDICATE OPEN FOR INOUT          00195700
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        00195800
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFUL ?            00195900
         BZ    FILEBAD            NO, SYNAD ERROR                       00196000
         BAL   10,DASDSETF    IF DASD DEVICE, SETUP FILEDATA            00196050
         SPACE 1                                                        00196100
READOPEN DS    0H                                                       00196200
         NI    DCBIFLGS,X'F3'     NORMAL PROCESSING                     00196205
         TM    DCBRECFM,X'C0' IS RECFM=U?                               00196210
         BO    READU          BR IF YES                                 00196220
         TM    DCBDEVT,TAPEBITS    IS THE FILE ON MAGNETIC TAPE         00196300
         DROP  3                                                        00196400
         BO    READTP              YES, GO FORM RECORD INDEX FOR TAPE   00196500
         BAL   14,DASDRECC    FORM TTRZ ADDRESS                         00196600
         USING FILEDATA,4                                               00196620
         C     PARM2,FILETTRN READING BEYOND END OF DATA SET?           00196640
         BH    FILEEOD            YES, ABEND                            00196660
         BAL   9,XDAPSET          SET UP XDAP PARAMETERS                00196670
         DROP  4                                                        00196680
         XDAP  XDAPECB,RI,(3),,(5),,MBBCCHHR,MF=E READ IN RECORD        00196690
         WAIT  ECB=XDAPECB        WAIT TO FINISH                        00196700
         CLI   XDAPECB,X'7F'      SUCCESSFUL COMPLETION?                00196710
         BE    EXIT               YES, RETURN TO XPL PROGRAM            00196720
         B     XDAPERR            ISSUE MESSAGE AND ABEND               00196730
READTP   ST    PARM2,TTR           SAVE RECORD POINTER                  00196740
         SPACE 1                                                        00196800
         POINT (3),TTR             POINT AT THE RECORD TO BE READ       00196900
DOREAD   READ  RDECB,SF,(3),0      READ THE RECORD INTO CORE            00197000
         CHECK RDECB               WAIT FOR THE READ TO COMPLETE        00197100
         B     EXIT           RETURN TO THE XPL PROGRAM                 00197250
         SPACE                                                          00197260
READU    STH   PARM2,RDECB+6  SAVE LENGTH IN DECB                       00197310
         B     DOREAD                                                   00197320
         SPACE 3                                                        00197400
         EJECT                                                          00197490
*                                                                       00197500
*        THIS ROUTINE INITIALIZES FILEDATA FOR DASD DEVICES             00197502
*                                                                       00197504
         USING IHADCB,3                                                 00197506
DASDSETF TM    DCBDEVT,DASDBITS IS THIS DIRECT ACCESS DEVICE            00197508
         BCR   14,10          NO, RETURN                                00197510
         RDJFCB ((3))         GET JFCB DATA                             00197512
         LTR   15,15          DID WE GET IT?                            00197514
         BNZ   FILEEOD        FOR LACK OF ANYTHING BETTER TO DO         00197516
         L     5,JFCBDESC     GET DESCRIPTOR FOR JFCB                   00197518
         USING JFCBD,5                                                  00197520
         LA    1,JFCBDSNM     DATASET NAME                              00197522
         ST    1,DSCBFILE+4                                             00197524
         LA    1,JFCBVOLS     ASSUME 1 VOLUME DATASETS                  00197526
         ST    1,DSCBFILE+8                                             00197528
         DROP  5                                                        00197530
         OBTAIN DSCBFILE      READ FMT1 DSCB FOR DATASET                00197532
         USING FILEDATA,4                                               00197534
         L     5,DSCBFILE+12                                            00197536
         USING DS1CB,5                                                  00197538
         XC    FILETTRN,FILETTRN  INITIAL LAST RECORD                   00197540
         CLC   DCBBLKSI,DS1BLKL SAME BLKSIZE?                           00197542
         BNE   NEWFILE        NO, TREAT AS NEW FILE                     00197544
         CLI   OCDCB,X'87'    OPEN FOR OUTPUT?                          00197546
         BE    NEWFILE        YES, ASSUME OLD DATA NOT NEEDED           00197548
         MVC   FILETTRN(3),DS1LSTAR OTHERWISE, USE LAST TRACK INFO      00197550
         MVC   DCBTRBAL,DS1TRBAL    ''                                  00197552
         DROP  5                                                        00197554
         ST    PARM2,TTR          SAVE PARM2                            00197556
         L     PARM2,FILETTRN     WHERE WE ARE HEADING                  00197558
         BAL   9,XDAPSET          CONVERT TO ABSOLUTE                   00197560
         MVC   DCBFDAD,MBBCCHHR                                         00197562
         OI    DCBOFLGS,X'80'     SET LAST OP WRITE                     00197564
         L     PARM2,TTR          RESTORE PARM2                         00197566
NEWFILE  L     5,DCBDVTBL     GET DEVICE INFO                           00197568
         USING DEVT,5                                                   00197570
         CLI   DCBKEYLE,0                                               00197572
         BNE   FILEBAD            KEYS NOT SUPPORTED                    00197574
*        CALCULATE THE NUMBER OF BLOCKS PER TRCK FOR                    00197576
*        THE DASD ON WHICH THE FILE IS ALLOCATED.                       00197581
*        THIS IS NECESSARY BECAUSE BSAM WILL NOT CORRECTLY              00197586
*        PERFORM WRITES TO THE END OF A FILE AFTER A POINT              00197591
*        SO ONE MUST KEEP TRACK OF WHERE IN THE FILE ONE IS BY HAND.    00197596
         LR    6,10             SAVE 10 TRKCALC DESTROYS IT             00197601
         TRKCALC FUNCTN=TRKCAP,DEVTAB=(5),R=1,K=0,DD=DCBBLKSI           00197606
         LR    10,6             RESTORE REGISTER 10                     00197611
         LTR   15,15            TEST FOR VALID NO OF RECORDS            00197616
         BNZ   FILEBAD                                                  00197621
         ST    0,FILEREC#       STORE NO. OF RECORDS/TRK                00197626
         DROP  3,5                                                      00197628
         BR    10                                                       00197630
         SPACE                                                          00197632
*                                                                       00197634
*        ROUTINE TO COMPUTE TTR FROM RELATIVE BLOCK #                   00197636
*                                                                       00197638
DASDRECC LTR   6,PARM2                                                  00197640
         SRDA  6,32                                                     00197642
         D     6,FILEREC#                                               00197644
         A     6,F1           ADD 1 TO REMAINDER                        00197646
*                             (MAKES RANGE 1 TO N INSTEAD OF 0 TO N-1)  00197648
         SLL   7,16           TT00                                      00197650
         SLL   6,8            R0                                        00197652
         OR    6,7            COMBINE TT WITH RN                        00197654
         LR    PARM2,6                                                  00197656
         BR    14                                                       00197658
         DROP  4                                                        00197660
         EJECT                                                          00197800
         SPACE 5                                                        00197900
*********************************************************************** 00198000
*                                                                     * 00198100
*                                                                     * 00198200
*                                                                     * 00198300
*        WRITE ROUTINE FOR DIRECT ACCESS FILE I/O                     * 00198400
*                                                                     * 00198500
*                                                                     * 00198600
*        INPUT TO THIS ROUTINE IS:                                    * 00198700
*                                                                     * 00198800
*      PARM1   CORE ADDRESS TO READ THE RECORD FROM                   * 00198900
*                                                                     * 00199000
*      SVCODE  SERVICE CODE INDICATING WHICH FILE TO USE              * 00199100
*                                                                     * 00199200
*      PARM2   RELATIVE RECORD NUMBER   0,1,2, ...                    * 00199300
*                                                                     * 00199400
*                                                                     * 00199500
*                                                                     * 00199600
*********************************************************************** 00199700
         SPACE 2                                                        00199800
WRITE    DS    0H                                                       00199900
         ST    PARM1,WDECB+12      SAVE CORE ADDRESS                    00200000
         ST    PARM1,XDAPECB+60                                         00200010
         L     3,ARWDCBS-FILEORG(SVCODE)                                00200100
*                                  GET THE DCB ADDRESS                  00200200
         USING IHADCB,3                                                 00200300
         L     4,FWRKADDR                                               00200320
         L     4,0(4,SVCODE)  GET FILEDATA INFO ADDRESS                 00200340
         TM    DCBOFLGS,OPENBIT    IS THE FILE OPEN ?                   00200400
         BO    WRTOPEN             YES, GO WRITE                        00200500
         ST    3,OCDCB             STORE DCB ADDRESS FOR OPEN SVC       00200600
         MVI   OCDCB,X'87'         FLAG END OF ARGUMENT LIST AND        00200700
*                                  INDICATE OPENING FOR OUTIN           00200800
         SPACE 1                                                        00200900
         OPEN  ,MF=(E,OCDCB)       OPEN THE FILE                        00201000
         SPACE 1                                                        00201100
         TM    DCBOFLGS,OPENBIT    WAS THE OPEN SUCCESSFUL ?            00201200
         BZ    FILEBAD            NO, SYNAD ERROR                       00201300
         BAL   10,DASDSETF    IF DASD DEVICE, SETUP FILEDATA            00201350
         SPACE 1                                                        00201400
WRTOPEN  DS    0H                                                       00201500
         NI    DCBIFLGS,X'F3'     NORMAL PROCESSING                     00201505
         TM    DCBRECFM,X'C0' IS RECFM=U?                               00201510
         BO    WRITEU         BR IF YES                                 00201520
         TM    DCBDEVT,TAPEBITS    IS THE FILE ON MAGNETIC TAPE         00201600
         DROP  3                                                        00201700
         BO    WRITP               YES, GO FORM RECORD INDEX FOR TAPE   00201800
         BAL   14,DASDRECC    FORM TTRZ ADDRESS FOR DIRECT ACCESS       00201900
         USING FILEDATA,4                                               00201905
WRTCHEKT C     PARM2,FILETTRN IS THIS NEXT RECORD                       00201910
         BNH   WRTXDAP            REWRITE, USE XDAP                     00201915
         ST    PARM2,TTR          SAVE RECORD POINTER                   00201920
         B     DOWRITE                                                  00201925
         SPACE                                                          00201975
WRITP    ST    PARM2,TTR           SAVE RECORD POINTER                  00202000
         SPACE 1                                                        00202100
         POINT (3),TTR             POINT AT THE DESIRED RECORD          00202200
DOWRITE  WRITE WDECB,SF,(3),0      WRITE THE RECORD OUT                 00202300
         CHECK WDECB               WAIT FOR THE WRITE TO FINISH         00202400
         USING IHADCB,3                                                 00202500
         TM    DCBDEVT,DASDBITS DIRECT ACCESS DEVICE?                   00202505
         BNO   EXIT           NO, EXIT                                  00202510
         TM    DCBRECFM,X'C0'     IS RECFM=U?                           00202515
         BO    EXIT               YES, NOT PSEUDO-RANDOM ACCESS         00202520
         NOTE  (3)            WHICH RECORD JUST WRITTEN                 00202525
         ST    1,FILETTRN                                               00202530
         C     1,TTR              AT DESIRED RECORD YET?                00202535
         BL    DOWRITE            NO, KEEP WRITING                      00202540
         DROP  3,4                                                      00202545
         B     EXIT                RETURN TO THE XPL PROGRAM            00202550
         SPACE 1                                                        00202555
WRITEU   STH   PARM2,WDECB+6  SAVE LENGTH IN DECB                       00202560
         B     DOWRITE                                                  00202565
         SPACE                                                          00202570
         USING IHADCB,3                                                 00202575
XDAPSET  LR    0,PARM2            PICK UP TTRZ                          00202580
         L     1,DCBDEBAD     DEB ADDRESS                               00202620
         LA    2,MBBCCHHR     AREA TO RECEIVE MBBCCHHR                  00202625
         STM   8,13,SAVE813 BECAUSE LOW CORE ROUTINE                    00202630
         LA    8,SAVE813      CHOOSES TO CLOBBER THESE REGS             00202635
         L     15,16(0,0)     CVT                                       00202640
         USING CVT,15                                                   00202645
         L     15,CVTPCNVT    CONVERT TTR TO MBBCCHHR                   00202650
         DROP  15                                                       00202655
         BALR  14,15                                                    00202660
         LM    8,13,0(8)      REGS BACK                                 00202665
         LH    5,DCBBLKSI     BLOCK COUNT                               00202675
*    TO TURN OFF ERROR RECOVERY, CHANGE '00' TO '0C'                 *  00202677
*        OI    DCBIFLGS,X'0C'     TURN OFF BSAM RECOVERY             *  00202677
         OI    DCBIFLGS,X'00'     TURN ON BSAM RECOVERY, DR48227        00202677
         DROP  3                                                        00202680
         BR    9                                                        00202685
         SPACE                                                          00202690
WRTXDAP  BAL   9,XDAPSET          SET UP XDAP INFO                      00202695
         XDAP  XDAPECB,WI,(3),,(5),,MBBCCHHR,MF=E WRITE OUT RECORD      00202700
         WAIT  ECB=XDAPECB    WAIT TO FINISH                            00202705
         CLI   XDAPECB,X'7F'      SUCCESSFUL COMPLETION                 00202710
         BE    EXIT               YES, RETURN TO XPL PROGRAM            00202715
XDAPERR  MVI   ACSMETH,0          EXCP                                  00202720
         LA    1,XDAPECB+4        IOB ADDRESS                           00202725
         BAL   10,PSYNADAF         ISSUE DIAGNOSTIC                     00202730
         B     FILEBAD            AND ABEND                             00202735
         SPACE 5                                                        00202740
*********************************************************************** 00202800
*                                                                     * 00202900
*                                                                     * 00203000
*                                                                     * 00203100
*        TIME AND DATE FUNCTIONS                                      * 00203200
*                                                                     * 00203300
*                                                                     * 00203400
*        RETURNS TIME OF DAY IN HUNDREDTHS OF A SECOND IN REGISTER    * 00203500
*        PARM1  AND THE DATE IN THE FORM  YYDDD IN REGISTER SVCODE    * 00203600
*                                                                     * 00203700
*                                                                     * 00203800
*********************************************************************** 00203900
         SPACE 2                                                        00204000
GETIME   TIME  BIN                 REQUEST THE TIME                     00204100
         ST    0,SAVREG+PARM1*4    RETURN IN REGISTER PARM1             00204200
         ST    1,DTSV+4            STORE THE DATE IN PACKED DECIMAL     00204300
         CVB   1,DTSV              CONVERT IT TO BINARY                 00204400
         ST    1,SAVREG+SVCODE*4   RETURN DATE IN REGISTER SVCODE       00204500
         B     EXIT                RETURN TO THE XPL PROGRAM            00204600
         EJECT                                                          00204700
*********************************************************************** 00204800
*                                                                     * 00204900
*                                                                     * 00205000
*                                                                     * 00205100
*        LINKING ROUTINE                                              * 00205200
*                                                                     * 00205300
*        MOVES THEN COMMON STRINGS (IF ANY) TO THE TOP OF THE         * 00205400
*        CORE AREA.                                                   * 00205500
*                                                                     * 00205600
*        INPUT TO THIS ROUTINE:                                       * 00205700
*                                                                     * 00205800
*        REG 0 THE ADDR OF THE START OF THE COMPACTED COMMON STRINGS  * 00205900
*                                                                     * 00205910
*        REG 2 ADDR OF DESCRIPTOR DESCRIPTORS                         * 00205920
*                                                                     * 00206000
*        REG 3 FREEPOINT FROM COMPACTIFY                              * 00206100
*                                                                     * 00206110
*        REG 4 CURRENT VALUE OF "CORETOP"                             * 00206120
*                                                                     * 00206200
*                                                                     * 00206300
*                                                                     * 00206400
*                                                                     * 00206500
*********************************************************************** 00206600
         DROP  11                                                       00206610
LINKPGMS L     EBR,ABASE1          REGISTER FOR ADRESSIBILITY           00206700
         USING BASE1,EBR                                                00206800
         OI    FLAGS,LINKBIT       TURN ON LINKING FLAG                 00206900
         ST    2,DESCDESC     SAVE POINTER TO DESCRIPTOR LIST           00207000
         ST    4,CORETOP      NEW CORETOP FROM XPL                      00207010
         S     4,ACORE        SIZE OF REMAINING ORIGINAL AREA           00207020
         ST    4,CORESIZE     SAVE IT                                   00207030
         TM    SAVREG+5*4,X'80'   IS THERE A BASED RECORD CHAIN         00207040
         BO    *+6                YES, REMEMBER IT                      00207050
         SR    5,5                OTHERWISE, NULL CHAIN ADDRESS         00207060
         ST    5,FIRSTREC         REMEMBER FIRST RECORD POINTER         00207070
         LA    7,4            TO SEARCH 4 TIMES                         00207100
LINKCHKS L     8,4(,2)        LENGTH OF DESCRIPTOR BLOCK                00207200
         LTR   8,8            ANY THERE                                 00207300
         BNZ   LINKDOMV       YES, GO MOVE THE DATA                     00207400
         LA    2,8(,2)        TO NEXT DESCRIPTOR BLOCK                  00207500
         BCT   7,LINKCHKS     TO SEE IF THERE WERE ANY ANYWHERE         00207600
LINKRECS LTR   5,5                ANY RECORDS IN CHAIN                  00207610
         BZ    NOLINKMV           NO, SET NO COMMON STRING              00207620
         USING BASEDREC,5                                               00207630
         NC    BRECNDSC,BRECNDSC  ANY DESCRIPTORS IN RECORD             00207640
         BNZ   LINKDOMV           YES, PROTECT 'EM                      00207650
         L     5,BRECNEXT         LINK TO NEXT RECORD IN CHAIN          00207660
         DROP  5                                                        00207670
         B     LINKRECS           IF THERE ARE ANY                      00207680
NOLINKMV EQU   *                                                        00207690
         OI    FLAGS,NOCBIT   NO CARRYOVER, SO INDICATE                 00207700
         L     2,ACORE                                                  00207800
         B     NODLINK        SKIP MOVING COMMON STRINGS                00207900
LINKDOMV LR    11,0           START OF STRINGS                          00207910
         LR    7,3                 FREEPOINT                            00208100
         SR    7,11                LENGTH OF STRING BLOCK               00208200
         L     8,CORETOP                                                00208300
         LR    6,8                                                      00208400
         SR    8,7                 WHERE TO START STRINGS               00208500
         LR    2,11                FIRST CHARACTER OF STRINGS           00208600
         LA    2,256(0,2)          OFFSET FOR OVERLAY CHECK             00208700
         CR    8,2                 WILL THEY OVERLAY                    00208800
         BH    MOVEOK                                                   00208900
         LA    1,MOVEABE           ABEND 1300                           00209000
         B     ABEND                                                    00209100
MOVEOK   LR    5,7                                                      00209200
         SRL   5,8                 # 256 BYTE BLOCKS TO BE MOVED        00209300
         LR    9,3                 FREEPOINT                            00209400
         LA    5,2(0,5)                                                 00209500
         LA    2,256                                                    00209600
         B     REDUCE                                                   00209700
MOVEUP   MVC   0(256,6),0(9)       MOVE A BLOCK                         00209800
REDUCE   SR    9,2                 POINT TO NEXT BLOCK                  00209900
         SR    6,2                                                      00210000
         BCT   5,MOVEUP                                                 00210100
         L     2,ACORE             FOR LINKING PROCESS                  00210200
         B     LINKING                                                  00210300
         DROP  EBR                                                      00210400
         USING SAVE+8192,11                                             00210410
         SPACE 5                                                        00210500
*********************************************************************** 00210600
*                                                                     * 00210700
*        LINE_COUNT FUNCTION                                          * 00210800
*                                                                     * 00210900
*        RETURNS CURRENT VALUE OF LINECT                              * 00211000
*                                                                     * 00211100
*********************************************************************** 00211200
         SPACE 5                                                        00211300
GETCNT   L     0,LINECT            FETCH LINE COUNT                     00211400
         ST    0,SAVREG+PARM1*4    RETURN IN REG PARM1                  00211500
         B     EXIT                SEND BACK TO XPL PROGRAM             00211600
         SPACE 5                                                        00211700
*********************************************************************** 00211800
*                                                                     * 00211900
*        SET_LINELIM COMMAND                                          * 00212000
*                                                                     * 00212100
*        SETS LINELIM TO THE VALUE PASSED IN REG 0 BY THE XPL CALL:   * 00212200
*        CALL SET_LINELIM(X);                                         * 00212300
*        WHERE X IS THE NEW LINE LIMIT TO BE SET.                     * 00212400
*                                                                     * 00212500
*********************************************************************** 00212600
         SPACE 5                                                        00212700
SETCNT   ST    0,LINELIM           STORE NEW MAX LINE COUNT VALUE       00212800
         B     EXIT                RETURN TO XPL PROGRAM                00212900
         EJECT                                                          00213000
         SPACE 5                                                        00213100
*********************************************************************** 00213200
*                                                                     * 00213300
*        ROUTINE TO GET THE PARM FIELD FROM THE EXEC CARD             * 00213400
*                                                                     * 00213500
*                                                                     * 00213600
*        INPUT TO THIS ROUTINE IS:                                    * 00213700
*                                                                     * 00213800
*        PARM1   ADDRESS OF THE NEXT AVAILABLE SPACE IN THE PROGRAM'S * 00213900
*        DYNAMIC STRING AREA  (FREEPOINT)                             * 00214000
*                                                                     * 00214100
*        SVCODE  THE SERVICE CODE FOR PARM_FIELD                      * 00214200
*                                                                     * 00214300
*        THE ROUTINE RETURNS:                                         * 00214400
*                                                                     * 00214500
*        PARM1   A STANDARD XPL STRING DESCRIPTOR POINTING TO THE     * 00214600
*                PARM FIELD WHICH IS NOW AT THE TOP OF THE STRING AREA* 00214700
*                                                                     * 00214800
*        SVCODE  THE NEW VALUE FOR FREEPOINT                          * 00214900
*                                                                     * 00215000
*********************************************************************** 00215100
         SPACE 5                                                        00215200
GETPARM  L     2,SAVREG+PARM1*4    FREEPOINT                            00215300
         LA    2,0(,2)             ADDRESS ONLY                         00215400
         L     1,CONTROL           POINTER TO PARM FIELD                00215500
         LH    3,0(,1)             LENGTH OF PARM FIELD                 00215600
         LTR   3,3                 IS THERE A PARM FIELD?               00215700
         BZ    NOPARM              NO, RETURN NULL STRING               00215800
         BCTR  3,0                 LENGTH - 1                           00215900
         LA    1,2(,1)             ADDRESS OF PARM FIELD                00216000
         EX    3,GETMOVE           MOVE TO STRING AREA                  00216100
         ST    2,SAVREG+PARM1*4    BUILD DESCRIPTOR                     00216200
         STC   3,SAVREG+PARM1*4                                         00216300
         LA    2,1(2,3)            NEW FREEPOINT                        00216400
         ST    2,SAVREG+SVCODE*4                                        00216500
         B     EXIT                                                     00216600
NOPARM   MVC   SAVREG+SVCODE*4(4),SAVREG+PARM1*4                        00216700
         ST    3,SAVREG+PARM1*4                                         00216800
         B     EXIT                                                     00216900
         EJECT                                                          00217000
*********************************************************************** 00217100
*                                                                     * 00217200
*        ROUTINE TO HANDLE REQUESTS MADE BY THE XPL PROGRAM           * 00217300
*        BY NEANS OF THE XPL STATEMENT:                               * 00217400
*           CALL MONITOR(A, B);                                       * 00217500
*        WHERE A IS THE CODE FOR THE REQUEST TO BE PERFORMED,         * 00217600
*        AND B IS ADDITIONAL INFORMATION NEEDED, IF ANY,              * 00217700
*        BY THE FUNCTION REQUESTED BY A.                              * 00217800
*                                                                     * 00217900
*********************************************************************** 00218000
         SPACE 5                                                        00218100
MONITOR  LH    SVCODE,SAVREG+2+PARM1*4  GET REQUEST CODE                00218200
         LTR   SVCODE,SVCODE       REQUEST MUST BE >= 0                 00218300
         BM    BADREQ                                                   00218400
         LA    PARM1,&MONREQS-1    MAX VALID CODE                       00218500
         CR    SVCODE,PARM1        AND <= MAX REQUEST                   00218600
         BH    BADREQ                                                   00218700
         SLL   SVCODE,2            REQUEST CODE * 4                     00218800
         B     REQUEST(SVCODE)     FIND THE REQUEST                     00218900
REQUEST  B     CLOSEO         0: CLOSE AN OUTPUT FILE                   00219000
         B     STOW           1: STOW FUNCTION                          00219100
         B     FIND           2: FIND-PREPARE FOR PDS INPUT             00219200
         B     CLOSEI         3: CLOSE AN INPUT FILE                    00219300
         B     SETFILE        4: CHANGE FILE BLOCKING                   00219400
         B     MON#5          5: SET UP FOR FLOATING POINT PACKAGE      00219500
         B     XPLGETM        6: GETMAIN FOR POINTER VARIABLE           00219600
         B     XPLFREEM       7: FREEMAIN POINTER VARIABLE STORAGE      00219700
         B     SETDDNAM       8: SET PDS DDNAME                         00219800
ZONKHERE B     AB3000         9: COMPILE-TIME EVAL OF FLT.PT            00219900
         B     AB3000         10: CHAR TO FLT.PT CONVERSION             00220000
         B     EXIT           11: NOT SUPPORTED                         00220300
         B     MON#12         12: FLT.PT TO CHAR CONVERSION             00220400
         B     MON13          13: FOR OPTIONS PASSING                   00221400
         B     MON14          14: FOR SDF HANDLING                      00221500
         B     RVL            15: PDS MEMBER REVISION LEVEL IND&CAT NUM 00221600
         B     RETCODE        16: INCORPORATE FLAGS INTO RETURN CODE    00221700
         B     COMPNAME       17: SET COMPILATION CHARACTERISTIC NAME   00221800
         B     TTIME          18: GET CURRENT TASK ELAPSED TIME         00221900
         B     XPLVGETM       19: GETMAIN A LIST OF AREAS               00222000
         B     XPLVFREE       20: FREEMAIN A LIST OF AREAS              00222100
         B     CORELEFT       21: DETERMINE HOW MUCH CORE IS LEFT       00222110
         B     CALLSDF        22: CALLS TO THE SDF ACCESS PACKAGE       00222115
         B     GETPGMID       23: RETURN PROGRAM IDENTIFICATION         00222125
         B     LMODREAD       24: READ A BLOCK OF A LOAD MODULE         00222130
         B     MMREAD         25: READ A MASS MEMORY LOAD BLOCK         00222135
         B     MAFREAD        26: READ A MAF(MEMORY ANALYSIS FILE)BLOCK 00222140
         B     MAFWRITE       27: WRITE A MAF BLOCK                     00222145
         B     MON28          28: LINK TO DUMP ANALYSIS SERVICE ROUTINE 00222150
         B     GETPAGE        29: RETURN CURRENT PAGE NUMBER            00222155
         B     GETJFCB        30: RETURN JFCB AS STRING                 00222160
         B     VMEMSRV        31: VIRTUAL MEMORY LOOKAHEAD SERVICE      00222162
         B     COREINCR           32: FIND OUT SUBPOOL MONIMUM SIZE     00222170
         B     FILESTAT           33: FIND OUT FILE MAX REC# AND BLKSIZ 00222180
ZONKED   B     MON#9                                                    00222200
         B     MON#10                                                   00222300
AB3000   LA    1,HALCOMPF                                               00222400
         B     ABEND                                                    00222500
  EJECT                                                                 00222600
CLOSEO   LA    SVCODE,&OUTPUTS     CHECK THAT SUBCODE IS VALID          00222700
         LTR   PARM2,PARM2         MUST BE >= 0                         00222800
         BM    BADFILE                                                  00222900
         CR    PARM2,SVCODE        AND <= NUMBER OF POSSIBLE FILES      00223000
         BH    BADFILE        NOT A LEGAL ONE                           00223050
         SLL   PARM2,2             SUBCODE * 4                          00223100
         L     3,PUTDCBS(PARM2)    GET THE DCB ADDRESS                  00223200
         USING IHADCB,3                                                 00223300
         TM    DCBDSORG,POBITS                                          00223400
         BO    CLOSOPDS                                                 00223500
         TM    DCBOFLGS,OPENBIT    IS IT OPEN?                          00223600
         BNO   EXIT                ALREADY CLOSED; NOTHING TO DO        00223700
         ST    3,OCDCB             STORE DCB ADDR FOR CLOSE SVC         00223800
         MVI   OCDCB,X'80'         FLAG END OF PARAMETER LIST           00223900
         CLOSE ,MF=(E,OCDCB)       CLOSE THE FILE                       00224000
FREEPOOL EQU   *                                                        00224005
         CLI   DCBBUFNO,0     ARE THERE BUFFERS TO FREE?                00224010
         BE    EXIT                                                     00224015
         FREEPOOL (3)              FREE BUFFER AREA                     00224100
         DROP  3                                                        00224200
         B     EXIT            RETURN TO XPL                            00224300
*        CLOSE AN OUTPUT PDS IF NECESSARY (STOW DOES A CLOSE)           00224400
CLOSOPDS L     4,OWRKADDR                                               00224500
         L     PARM2,0(PARM2,4)                                         00224600
         USING OPDSDATA,PARM2                                           00224700
         SR    4,4                                                      00224800
         ST    4,BLKDATA                                                00224900
         USING IHADCB,3                                                 00225000
         TM    DCBOFLGS,OPENBIT IS IT OPEN?                             00225100
         BNO   EXIT            NO, NOTHING TO DO                        00225200
         ST    3,OCDCB                                                  00225300
         MVI   OCDCB,X'80'                                              00225400
         CLOSE MF=(E,OCDCB)                                             00225500
         DROP  3                                                        00225600
         DROP  PARM2                                                    00225700
         B     FREEPOOL        GIVE BACK BUFFER AND RETURN TO XPL       00225800
         SPACE 5                                                        00225900
*        STOW MEMBER FOR OUTPUT PDS; USED FOR ALL PDS OUTPUT EXCEPT     00226000
*        OUTPUT5 WHICH IS HANDLED SEPERATELY                            00226100
STOW     LA    SVCODE,&OUTPUTS                                          00226200
         L     PARM2,SAVREG+PARM2*4 FILE #                              00226300
         CR    PARM2,SVCODE        MUST BE <= MAX FILE                  00226400
         BH    BADFILE                                                  00226500
         LTR   PARM2,PARM2                                              00226600
         BM    BADFILE                                                  00226700
         SLL   PARM2,2             WORD ADDRESSING                      00226800
         L     3,PUTDCBS(PARM2)   DCB ADDRESS                           00226900
         USING IHADCB,3                                                 00227000
         TM    DCBDSORG,POBITS                                          00227100
         BNO   BADFILE                                                  00227200
         TM    DCBOFLGS,OPENBIT IS IT OPEN                              00227300
         BNO   EXIT                                                     00227400
         CLI   DCBBUFNO,0     IS THE MONITOR DOING THE BUFFERING?       00227405
         BE    DOSTOW                                                   00227410
         L     4,OWRKADDR                                               00227500
         L     PARM2,0(PARM2,4)                                         00227600
         USING OPDSDATA,PARM2                                           00227700
         L     4,BLKDATA           BUFFER POINTER                       00227800
         LTR   4,4                 ANY WRITE NECESSARY?                 00227900
         BZ    FREEBUFF            NO                                   00228000
         L     5,AREADATA          BUFFER ADDRESS                       00228100
         LH    6,DCBBLKSI          SAVE BLKSIZE                         00228200
         STH   4,DCBBLKSI          SET TO BUFFER RESIDUAL               00228300
         WRITE PDSDECB,SF,(3),(5),(4),MF=E                              00228400
         CHECK PDSDECB             WAIT FOR WRITE TO COMPLETE           00228500
         STH   6,DCBBLKSI          RESTORE BLKSIZE                      00228600
FREEBUFF SR    4,4                                                      00228700
         ST    4,BLKDATA           RESET BUFFER POINTER                 00228800
DOSTOW   EQU   *                                                        00228805
         L     PARM2,SAVREG+PARM3*4 DESCRIPTOR                          00228900
         CLI   SAVREG+PARM3*4,7 LENGTH=7 --> ACTUAL=8                   00229000
         BNE   STOWERR             ABEND IF NOT                         00229100
         MVC   STOWNAME(8),0(PARM2) MOVE THE MEMBER NAME                00229200
         STOW  (3),STOWNAME,R      REPLACE TYPE STOW                    00229300
         B     STOWCODE(15)        TAKE ACTION ON RETURN CODE           00229400
STOWCODE B     RET1                MEMBER REPLACED - RETURN 1           00229500
         B     STOWOK              NOT APPLICABLE                       00229600
         B     STOWOK              NAME NOT FOUND - ADDED (RETURN 0)    00229700
         B     DIRABEND            DIRECTORY FULL - ABEND               00229800
         B     OPDSBAD            I/O ERROR                             00229900
STOWOK   SR    15,15               SET RETURN TO ZERO                   00230000
         B     RESAVE                                                   00230100
RET1     LA    15,1                SET RETURN TO ONE                    00230200
RESAVE   ST    15,SAVREG+PARM1*4   SETUP RETURN CODE                    00230300
         ST    3,OCDCB             SAVE DCB ADDRESS                     00230400
         MVI   OCDCB,X'80'         MARK END OF LIST                     00230500
         CLOSE ,MF=(E,OCDCB)       CLOSE FILE                           00230600
         DROP  3                                                        00230700
         DROP  PARM2                                                    00230800
         B     FREEPOOL                                                 00230900
         SPACE 5                                                        00231000
FIND     LA    SVCODE,&INPUTS                                           00231100
         L     PARM2,SAVREG+PARM2*4 FILE #                              00231200
         CR    PARM2,SVCODE        MUST BE <= MAX FILE NUM              00231300
         BH    BADFILE             ABEND                                00231400
         LTR   PARM2,PARM2                                              00231500
         BM    BADFILE                                                  00231600
         SLL   PARM2,2                                                  00231700
         L     3,GETDCBS(PARM2) DCB ADDR                                00231800
         USING IHADCB,3                                                 00231900
         TM    DCBDSORG,POBITS                                          00232000
         BNO   BADFILE                                                  00232100
         L     4,IWRKADDR                                               00232200
         L     PARM2,0(PARM2,4)                                         00232300
         USING IPDSDATA,PARM2                                           00232400
         MVI   PDSFLAGS,0      PRESUME NON-SPECIAL PDS                  00232500
         TM    DCBOFLGS,OPENBIT IS IT OPEN?                             00233300
         BO    INOPEN         YES, PROCEED WITH FIND                    00233400
         ST    3,OCDCB                                                  00234600
         MVI   OCDCB,X'80'     OPEN FOR INPUT                           00234700
         OPEN  ,MF=(E,OCDCB)                                            00234800
         TM    DCBOFLGS,OPENBIT                                         00234900
         BO    INOPEN                                                   00235000
         OI    PDSFLAGS,X'02' SET DD MISSING FLAG                       00235300
         B     RETURN1        RETURN NOT FOUND, NO DDNAME               00235400
INOPEN   L     4,SAVREG+PARM3*4                                         00235700
         CLI   SAVREG+PARM3*4,7 NAME MUST BE 8 CHARS                    00235800
         BNE   FINDERR         BAD NEWS IF NOT                          00235900
         MVC   FINDNAME(8),0(4) MOVE MEMBERNAME TO FIND LIST            00236000
         BLDL  (3),BLDLIST LOCATE THE MEMBER                            00236100
         B     BLDLCODE(15)    CHECK RETURN CODE                        00236200
BLDLCODE B     BLDLOK          MEMBER FOUND                             00236300
         B     RETURN1        MEMBER NOT FOUND                          00236400
         B     IPDSBAD            I/O ERROR IN DIRECTORY                00236500
BLDLOK   SR    15,15                                                    00236600
         ST    15,SAVREG+PARM1*4 SET RETURN CODE                        00236700
         ST    15,INBUFSIZ    FORCE NEXT INPUT(.) TO DO A NEW READ      00236701
         FIND  (3),FINDTTRK,C                                           00236800
         CLI   DCBBUFNO,0     DO WE NEED BUFFERS?                       00236805
         BE    RETURN0                                                  00236810
         L     4,INAREA                                                 00236900
         LTR   4,4             IS BUFFER ALREADY GOTTEN?                00237000
         BNZ   RETURN0         YES, RETURN                              00237100
         GETBUF  (3),(4)                                                00237200
         ST    4,INAREA        SAVE BUFFER ADDRESS                      00237300
         B     RETURN0                                                  00237400
RETURN1  LA    15,1                                                     00238600
         ST    15,SAVREG+PARM1*4                                        00238700
         DROP  3                                                        00238800
         DROP PARM2                                                     00238900
RETURN0  OC    SAVREG+PARM1*4+3(1),PDSFLAGS SET OPTIONAL NOT OPEN FLAG  00239000
         B     EXIT                                                     00239700
         SPACE 5                                                        00239800
CLOSEI   LA    SVCODE,&INPUTS                                           00239900
         LTR   PARM2,PARM2         MUST BE >= 0                         00240000
         BM    BADFILE                                                  00240100
         CR    PARM2,SVCODE                                             00240200
         BH    BADFILE        ILLEGAL FILE                              00240300
         SLL   PARM2,2                                                  00240400
         L     3,GETDCBS(PARM2)    DCB ADDRESS                          00240500
         USING IHADCB,3                                                 00240600
         TM    DCBDSORG,POBITS                                          00240700
         BO    CLOSEPDS                                                 00240800
         TM    DCBOFLGS,OPENBIT    IS IT OPEN                           00240900
         DROP  3                                                        00241000
         BNO   EXIT                IF NOT EXIT - NOTHING TO DO          00241100
         ST    3,OCDCB             SAVE DCB ADDRESS                     00241200
         MVI   OCDCB,X'80'         FLAG END OF LIST                     00241300
         CLOSE MF=(E,OCDCB)        CLOSE IT                             00241400
         B     FREEPOOL            NOW FREE THE SUBPOOL                 00241500
CLOSEPDS L     4,IWRKADDR                                               00241600
         L     PARM2,0(PARM2,4)                                         00241700
         USING IPDSDATA,PARM2                                           00241800
         USING IHADCB,3                                                 00241900
         TM    DCBOFLGS,OPENBIT    IS IT OPEN?                          00242000
         BNO   EXIT                NO - NOTHING TO DO                   00242100
         ST    3,OCDCB             SAVE ADDRESS                         00242200
         MVI   OCDCB,X'80' FLAG END OF LIST                             00242300
         CLOSE MF=(E,OCDCB)        CLOSE THE FILE                       00242400
         SR    4,4                                                      00242500
         ST    4,INBUFSIZ          RESET IN CASE OF FURTHER READS       00242600
         ST    4,INAREA        INDICATE NO AREA GOTTEN                  00242700
         DROP  3                                                        00242800
         DROP  PARM2                                                    00242900
         B     FREEPOOL                                                 00243000
         SPACE 3                                                        00243100
SETFILE  LA    PARM1,&FILES   HIGHEST NUMBERED FILE                     00243200
         L     4,SAVREG+PARM2*4 GET REQUESTED FILE NUMBER               00243300
         LTR   4,4            CHECK WITHIN RANGE                        00243400
         BNP   BADFILE        MUST BE > 0                               00243500
         CR    4,PARM1        CHECK UPPER LIMIT                         00243600
         BH    BADFILE        OUT OF RANGE                              00243700
         SLL   4,3            FILE NO. * 8 FOR PROPER INDEX             00243800
         LA    4,FILEORG-8(,4) ADJUST FOR TABLE INDEX                   00244000
         L     3,ARWDCBS-FILEORG(4) GET DCB POINTER                     00244020
         L     5,FWRKADDR                                               00244040
         L     4,0(5,4)       PICK UP FILEDATA ADDRESS                  00244060
         L     PARM2,SAVREG+PARM3*4 PICK UP NEW BLKSIZE                 00244150
         USING IHADCB,3       ADDRESSABILITY                            00244200
         TM    DCBOFLGS,OPENBIT IS IT OPEN?                             00244210
         BNO   CLOSED         NO, NO NEED TO CLOSE FIRST                00244220
         ST    3,OCDCB                                                  00244230
         MVI   OCDCB,X'80'                                              00244240
         CLOSE MF=(E,OCDCB)   CLOSE BEFORE CHANGING                     00244250
CLOSED   LTR   PARM2,PARM2    CHECK FOR POSITIVE LENGTH                 00244260
         BP    SETIT          BR IF FILE                                00244270
         LPR   PARM2,PARM2    ABS(PARM2) FOR LRECL/ BLKSIZE             00244275
         OI    DCBRECFM,X'C0' SET RECFM=U                               00244280
SETIT    STH   PARM2,DCBBLKSI REVISE BLOCKSIZE                          00244300
         STH   PARM2,DCBLRECL AND LRECL (RECFM=F)                       00244400
         DROP  3                                                        00244500
         USING FILEDATA,4                                               00244600
         XC    FILETTRN,FILETTRN  RESET LAST RECORD                     00244650
         DROP  4                                                        00244700
         B     EXIT           NOTE THIS MUST BE DONE BEFORE FIRST USE   00244800
         SPACE 4                                                        00244900
XPLGETM  L     PARM3,SAVREG+PARM3*4 SIZE TO BE GOTTEN                   00245000
         L     PARM2,SAVREG+PARM2*4 ADDR OF POINTER                     00245100
         SR    1,1                                                      00245200
         ST    1,0(0,PARM2)        DEFAULT TO ZERO                      00245300
         GETMAIN EC,LV=(PARM3),A=(PARM2),SP=SUBPOOL                     00245400
         SRA   15,2                                                     00245500
         ST    15,SAVREG+PARM1*4   INDICATE SUCCESS TO XPL PROGRAM      00245600
         BNZ   EXIT           GETMAIN FAILED                            00245700
         L     PARM2,0(0,PARM2) ADDR OF STORAGE OBTAINED                00245800
         BAL   7,ZEROMEM      GO ZERO IT                                00245900
         B     EXIT                                                     00246000
         SPACE 5                                                        00246100
XPLFREEM L     PARM3,SAVREG+PARM3*4 SIZE                                00246200
         L     PARM2,SAVREG+PARM2*4    ADDR OF POINTER                  00246300
         L     PARM2,0(0,PARM2) ADDR OF AREA TO BE FREED                00246400
         FREEMAIN R,LV=(PARM3),A=(PARM2),SP=SUBPOOL                     00246500
         B     EXIT                                                     00246600
         SPACE 5                                                        00246605
*                                                                       00246700
*        GETMAIN FOR A LIST OF AREAS                                    00246800
*                                                                       00246900
XPLVGETM L     9,SAVREG+PARM2*4 ADDR LIST                               00247000
         L     10,SAVREG+PARM3*4 SIZE LIST                              00247100
         SR    8,8            COUNTER                                   00247200
NEXTGETM LA    PARM2,0(8,9)   ADDR                                      00247300
         L     6,0(8,10)      SIZE                                      00247400
         LA    PARM3,0(0,6)   ZERO HIGH BYTE                            00247410
         GETMAIN EC,LV=(PARM3),A=(PARM2),SP=SUBPOOL                     00247500
         SRA   15,2           RETURN CODE                               00247600
         ST    15,SAVREG+PARM1*4 INDICATE SUCCESS                       00247700
         BNZ   EXIT           GIVE UP                                   00247800
         L     PARM2,0(0,PARM2)                                         00247810
         BAL   7,ZEROMEM                                                00247900
         LA    8,4(0,8)       NEXT ENTRY                                00248000
         LTR   6,6            IS THIS THE LAST                          00248300
         BNM   NEXTGETM                                                 00248400
         B     EXIT                                                     00248500
         SPACE 5                                                        00248510
*                                                                       00248600
*        FREEMAIN FOR A LIST OF AREAS                                   00248700
*                                                                       00248800
XPLVFREE L     9,SAVREG+PARM2*4 ADDR LIST                               00248900
         L     10,SAVREG+PARM3*4 SIZE LIST                              00249000
         SR    4,4            COUNTER                                   00249010
NEXTFREE L     PARM2,0(4,9)   ADDR OF POINTER                           00249020
         L     6,0(4,10)      SIZE                                      00249040
         LA    PARM3,0(0,6)                                             00249045
         FREEMAIN R,LV=(PARM3),A=(PARM2),SP=SUBPOOL                     00249050
         LA    4,4(0,4)       NEXT ENTRY                                00249060
         LTR   6,6                                                      00249070
         BNM   NEXTFREE                                                 00249080
         B     EXIT                                                     00249200
         SPACE 5                                                        00249210
*                                                                       00249300
*        ROUTINE TO ZERO A BLOCK OF GETMAINED MEMORY                    00249400
*                                                                       00249500
*        CALLED VIA           BAL  7,ZEROMEM                            00249600
*        PARM2=ADDR OF STORAGE                                          00249700
*        PARM3=SIZE OF STORAGE BLOCK                                    00249800
*                                                                       00249900
ZEROMEM  DS    0H                                                       00250000
         LA    4,7(0,PARM3)   CLEAR H.O. BYTE AND ROUND UP              00250100
         SRA   4,3            # DOUBLEWORDS                             00250200
         BCR   13,7           PROTECT AGAINST MIS-CALL                  00250300
         LR    5,PARM2        START ADDRESS                             00250400
         SDR   0,0            ZERO                                      00250500
ZERO8    STD   0,0(0,5)       ZERO DBLWORD                              00250600
         LA    5,8(0,5)       NEXT DBLWORD                              00250700
         BCT   4,ZERO8        LOOP TILL DONE                            00250800
         BR    7              RETURN                                    00250900
         SPACE 5                                                        00250910
SETDDNAM EQU   *                                                        00250920
         AIF   (&XPL).XX4                                               00250923
         LA    SVCODE,&INPUTS                                           00250926
         CR    PARM2,SVCODE   IS THIS LEGAL INPUT FILE #                00250930
         BH    BADFILE        NO, ERROR                                 00250940
         SLA   PARM2,2        *4                                        00250950
         BM    BADFILE        IF NEGATIVE, ALSO ERROR                   00250960
         L     6,GETDCBS(PARM2) GET DCB ADDRESS                         00250970
         USING IHADCB,6                                                 00250980
         TM    DCBDSORG,POBITS IS THIS A PDS                            00250990
         BNO   BADFILE        NO, ERROR                                 00251000
         DROP  6                                                        00251010
         LTR   PARM3,PARM3    SET FOR INPUT OR OUTPUT FILE              00251020
         SLL   PARM3,2        *4 ANYWAY                                 00251030
         BM    SETDDOUT       SET OUTPUT FILE DDNAME                    00251040
SETDDIN  LA    SVCODE,&INPUTS*4                                         00251050
         L     4,GETDCBS(PARM3)                                         00251060
         L     5,IWRKADDR                                               00251070
         L     5,0(PARM3,5)   TO INPUT PDS WORK AREA                    00251075
         USING IPDSDATA,5                                               00251080
         LA    5,INDDNAM1     REAL DDNAME ASSOCIATED WITH THIS INPUT    00251090
         DROP  5                                                        00251100
         MVI   PDSFLAGS,0     EQUATING TO INPUT FILE                    00251105
         B     SETDD                                                    00251110
SETDDOUT LA    SVCODE,&OUTPUTS*4                                        00251120
         L     4,PUTDCBS(PARM3)                                         00251130
         L     5,OWRKADDR                                               00251133
         L     10,0(5,PARM3)  TO OUTPUT PDS WORK AREA                   00251136
         USING OPDSDATA,10                                              00251140
         LA    5,DDNAME                                                 00251144
         DROP  10                                                       00251148
         MVI   PDSFLAGS,1     EQUATING TO OUTPUT FILE                   00251152
SETDD    CR    PARM3,SVCODE   LEGAL FILE?                               00251170
         BH    BADFILE        NO, ABORT                                 00251180
         LTR   PARM3,PARM3    NEGATIVE                                  00251190
         BM    BADFILE        ALSO NO GOOD                              00251200
         USING IHADCB,4                                                 00251210
         TM    DCBDSORG,POBITS IS THIS A PDS                            00251220
         BNO   BADFILE        NO, ERROR                                 00251230
         L     7,IWRKADDR                                               00251240
         L     7,0(7,PARM2)   GET WORK AREA ADDRESS                     00251242
         USING IPDSDATA,7                                               00251244
         CLC   INDDNAM2,0(5)  IS NAME THE SAME                          00251246
         BNE   ALTOPENT       NO, IF OPEN, CLOSE IT                     00251248
         TM    PDSFLAGS,1     EQUATING TO OUTPUT FILE?                  00251250
         BZ    EXIT           NO, LEAVE ALONE                           00251252
         TM    DCBOFLGS,OPENBIT IS OUTPUT FILE OPEN                     00251254
         BO    SETDDO         YES, EXTENT INFO EXISTS                   00251256
         USING OPDSDATA,10                                              00251258
         NC    AREADATA,AREADATA HAS A STOW BEEN DONE?                  00251260
         BZ    EXIT           NO, CAN LEAVE OPEN AS IS                  00251262
         XC    AREADATA,AREADATA FLAG CLOSE DONE                        00251264
         DROP  10                                                       00251266
         B     ALTOPENT       AND DO IT                                 00251268
SETDDO   L     8,DCBDEBAD     PICK UP DEB ADDRESS                       00251270
         DROP  4                                                        00251272
         USING IHADCB,6                                                 00251274
         TM    DCBOFLGS,OPENBIT IS WORKING PDS OPEN?                    00251276
         BZ    EXIT           NO, LET FIND DO THE DIRTY WORK            00251278
         L     9,DCBDEBAD     DEB FOR INPUT FILE                        00251280
         CLC   16(1,8),16(9)  # EXTENTS THE SAME?                       00251282
         BE    EXIT           YES, CAN ALSO LEAVE ALONE                 00251284
ALTOPENT TM    DCBOFLGS,OPENBIT IS PDS OPEN?                            00251286
         BZ    SETDDN         NO, JUST INSERT DDNAME                    00251300
ALTCLOSE ST    6,OCDCB         SET UP TO CLOSE INCLUDE AND              00251301
         MVI   OCDCB,X'80'     TRY AGAIN WITH OUTPUT6                   00251302
         CLOSE MF=(E,OCDCB)                                             00251303
         FREEPOOL (6)          GIVE BACK THE BUFFER                     00251304
         XC    INAREA,INAREA SHOW NO BUFFER GOTTEN                      00251310
*                                                                       00251320
SETDDN   MVC   DCBDDNAM,0(5) SET DDNAME IN DCB FOR OPEN                 00251330
         MVC   INDDNAM2,0(5)  RECORD CURRENT NAME IN USE                00251340
         DROP  6,7                                                      00251350
.XX4     ANOP                                                           00251353
         B     EXIT           ALL DONE                                  00251360
         SPACE 5                                                        00251370
*                                                                       00251710
*        MONITOR CALL 21 - GET AS MUCH MEMORY AS POSSIBLE AND RETURN    00251720
*        SIZE TO XPL.  MEMORY IS FREED BEFORE GOING BACK                00251730
*                                                                       00251740
CORELEFT GETMAIN VC,LA=CORETEST,A=COREGOT,SP=SUBPOOL                    00251750
         LM    1,2,COREGOT    ADDR TO R1, LENGTH TO R2                  00251760
         ST    2,SAVREG+PARM1*4 RETURN SIZE GOTTEN                      00251770
         FREEMAIN R,LV=(2),A=(1),SP=SUBPOOL                             00251780
         B     EXIT           GO BACK                                   00251790
*                                                                       00251795
*        MONITOR CALL 22 - PASS CONTROL TO THE SDF ACCESS               00251800
*        PACKAGE.  LOAD IT FROM STEPLIB IF IT IS THE FIRST CALL.        00251805
*                                                                       00251810
CALLSDF  EQU   *                                                        00251811
         AIF   (&XPL).QQ3                                               00251812
         CLI   SAVREG+3+PARM2*4,0  INITIALIZE CALL?                     00251815
         BNE   LOADED                                                   00251825
         LOAD  EP=SDFPKG                                                00251830
         ST    0,ASDFPKG                                                00251835
         L     0,SAVREG+PARM3*4 GET ADDR OF COMM AREA                   00251837
         LR    4,0                                                      00251838
         LA    5,OUTPUT5          DCB WITH ALTERNATE DDNAME             00251839
         TM    13(4),X'4' IS ALTERNATE DDNAME TO BE USED                00251841
         BO    SETSDFNM           YES, USE IT                           00251843
         LA    5,HALSDF           OTHERWISE USE DEFAULT                 00251845
         OI    13(4),X'4'                                               00251850
         USING IHADCB,5                                                 00251851
SETSDFNM MVC   32(8,4),DCBDDNAM  MOVE DDNAME INTO COMM AREA             00251852
         DROP  5                                                        00251853
LOADED   L     15,ASDFPKG                                               00251855
         L     1,SAVREG+PARM2*4  LOAD THE SDFPKG MODE AND FLAGS         00251857
         BALR  14,15          CALL SDFPKG                               00251859
         ST    15,SAVREG+PARM1*4 PASS BACK THE RETURN CODE              00251861
         CLI   SAVREG+3+PARM2*4,1  CLOSE CALL?                          00251863
         BE    DELSDF                                                   00251865
         CLI   SAVREG+3+PARM2*4,0  INIT CALL?                           00251866
         BNE   EXIT                NO                                   00251867
         LTR   15,15               SUCCESSFUL INIT?                     00251868
         BZ    EXIT                YES, RETAIN                          00251869
DELSDF   DELETE EP=SDFPKG                                               00251870
.QQ3     ANOP                                                           00251871
         B     EXIT                                                     00251872
         SPACE 2                                                        00251873
MON13    LTR   PARM2,PARM2    MODULE NAME SPECIFIED??                   00251875
         BNZ   NEWOPT         YES, GET NEW PROCESSOR                    00251885
         L     3,VCONOPT      LOAD EXISTING OPTION PARMS                00251895
         ST    3,SAVREG+PARM1*4 SAVE FOR RETURN TO XPL                  00251905
         B     EXIT                                                     00251915
NEWOPT   CLI   SAVREG+PARM2*4,7 DESCRIPTOR MUST HAVE LENGTH 8           00251925
         BNE   OPTERR                                                   00251935
         DELETE EPLOC=OPTNAME                                           00251945
         MVC   OPTNAME(8),0(PARM2)  MOVE IN NEW MODULE NAME             00251955
         LOAD  EPLOC=OPTNAME                                            00251965
         LR    15,0           ENTRY POINT ADDR                          00251975
         L     1,CONTROL      PARM FIELD ADDR                           00251985
         BALR  14,15          CALL IT                                   00251995
         ST    1,VCONOPT      SAVE NEW OPTIONS PARM                     00252005
         ST    1,SAVREG+PARM1*4 SAVE FOR RETURN TO XPL                  00252015
         B     EXIT                                                     00252025
         SPACE 3                                                        00252200
MON14    EQU   *                                                        00252300
         AIF   (&XPL).XX5                                               00252303
         L     SVCODE,SAVREG+PARM2*4                                    00252400
         L     PARM2,SAVREG+PARM3*4 SET UP FOR SDF ROUTINE              00252500
         ENTRY OUTPUT5                                                  00252550
         L     10,VSDFOUT                                               00252600
         DROP  11                                                       00252605
         BALR  11,10                                                    00252700
         SPACE 1                                                        00252800
         B     EXIT                                                     00252900
         B     ABEND                                                    00253000
         B     DIRABEND                                                 00253100
         B     OPDSBAD                                                  00253200
         LA    1,OPENABE                                                00253300
         B     ABEND                                                    00253400
         ST    15,SAVREG+PARM1*4                                        00253500
         B     EXIT                                                     00253600
VSDFOUT  DC    V(SDFOUT)                                                00253601
         AGO   .XX6                                                     00253602
.XX5     B     EXIT                                                     00253603
.XX6     ANOP                                                           00253604
         USING SAVE+8192,11                                             00253605
*                                                                       00253612
*        MONITOR CALL 24 - ALLOWS LOAD MODULES TO BE READ BY XPL        00253615
*                                                                       00253620
LMODREAD EQU   *                                                        00253622
         L     0,SAVREG+PARM2*4  FETCH THE INPUT BUFFER ADDRESS         00253625
         LTR   0,0            ARE WE TO DO A POINT?                     00253626
         BNZ   LM1            NO                                        00253627
         MVC   TTRCESD(4),FINDUSER   GET THE TTR OF THE USER            00253628
         POINT INPUT11,TTRCESD                                          00253629
         B     DASSRET0                                                 00253630
LM1      ST    0,LMODBUFF     STORE THE ADDRESS IN THE DECB             00253631
         READ  LMODDCB,SF,MF=E                                          00253635
         CHECK LMODDCB        WAIT FOR THE READ TO COMPLETE             00253640
DASSRET1 EQU   *                                                        00253641
         LA    15,1           SIGNAL NOT AT END OF FILE                 00253645
         B     LMODEXIT                                                 00253650
DASSRET0 EQU   *                                                        00253652
LMODEOD  SR    15,15          SIGNAL END OF FILE                        00253655
LMODEXIT ST    15,SAVREG+PARM1*4  RETURN THE EOF CODE TO THE CALLER     00253660
         B     EXIT                                                     00253665
TTRCESD  DC    F'0'           TTR OF THE LOAD MODULE CESD               00253666
         READ  LMODDCB,SF,INPUT11,0,13030,MF=L                          00253675
LMODBUFF EQU   LMODDCB+12                                               00253680
*                                                                       00253685
*        MONITOR CALL - 25 ALLOWS AP-101 MASS MEMORY TO BE READ BY XPL  00253690
*                                                                       00253695
MMREAD   EQU   *                                                        00253696
         AIF   (&COMP).QQ6                                              00253697
         CLI   FIRSTMM,0      FIRST CALL?                               00253700
         BNE   MM1                                                      00253705
         MVI   FIRSTMM,1      SET FLAG                                  00253710
         L     0,SAVREG+PARM2*4  GET THE BUFFER ADDRESS                 00253715
         ST    0,MMBUFADR                                               00253720
         OPEN  (MMDCB,(INPUT))                                          00253725
         B     EXIT                                                     00253730
MM1      L     6,SAVREG+PARM3*4  FETCH THE BLOCK COUNT                  00253735
         BNZ   MM2            LAST CALL?                                00253740
         CLOSE MMDCB                                                    00253745
         B     EXIT                                                     00253750
MM2      L     5,MMBUFADR     INITIALIZE TARGET ADDRESS                 00253755
         L     4,SAVREG+PARM2*4  FETCH STARTING FTSBB                   00253760
MM3      LR    3,4            GET CURRENT FTSBB                         00253765
         SR    2,2                                                      00253770
         D     2,=F'6'                                                  00253775
         SLL   3,16                                                     00253780
         LA    2,1(2)                                                   00253785
         SLL   2,8                                                      00253790
         AR    2,3                                                      00253795
         ST    2,MMTTR                                                  00253800
         POINT MMDCB,MMTTR                                              00253805
         READ  MMDECB,SF,,(5),,,,,MF=E                                  00253810
         CHECK MMDECB                                                   00253815
         LA    4,1(4)         BUMP FTSBB                                00253820
         LA    5,1024(5)      BUMP TARGET ADDRESS                       00253825
         BCT   6,MM3          MORE BLOCKS TO READ?                      00253830
         B     EXIT                                                     00253835
FIRSTMM  DC    X'0'                                                     00253840
         DS    0F                                                       00253845
MMTTR    DS    F                                                        00253850
MMBUFADR DS    F                                                        00253855
         READ  MMDECB,SF,MMDCB,,'S',,,,MF=L                             00253860
MMDCB    DCB   BFALN=F,BLKSIZE=1024,DSORG=PSU,MACRF=(RP),              X00253865
               RECFM=F,NCP=1,DDNAME=MASSMEM1                            00253870
         AGO   .QQ7                                                     00253871
.QQ6     ANOP                                                           00253872
         B     EXIT                                                     00253873
.QQ7     ANOP                                                           00253874
         SPACE 3                                                        00253875
*                                                                       00253876
*        MONITOR CALL 26 -- ALLOWS XPL TO READ MAFS                     00253879
*                                                                       00253882
MAFREAD  EQU   *                                                        00253883
         AIF   (&COMP).QQ8                                              00253884
         L     4,SAVREG+PARM2*4  FETCH THE INPUT BUFFER ADDRESS         00253885
         LTR   4,4                                                      00253886
         BNZ   MAFRD1                                                   00253887
         LA    3,INPUT9                                                 00253888
         USING IHADCB,3                                                 00253889
         OPEN  (INPUT9,(INPUT))                                         00253890
         TM    DCBOFLGS,OPENBIT                                         00253891
         BO    DASSRET0                                                 00253892
         B     DASSRET1                                                 00253893
MAFRD1   ST    4,MAFINBUF                                               00253894
         READ  MAFINDCB,SF,MF=E                                         00253895
         CHECK MAFINDCB                                                 00253896
         B     DASSRET0                                                 00253897
         READ  MAFINDCB,SF,INPUT9,0,1680,MF=L                           00253900
MAFINBUF EQU   MAFINDCB+12                                              00253903
         AGO   .QQ9                                                     00253904
.QQ8     ANOP                                                           00253905
         B     EXIT                                                     00253906
.QQ9     ANOP                                                           00253907
         SPACE 3                                                        00253908
*                                                                       00253909
*        MONITOR CALL 27 -- ALLOWS XPL TO GENERATE MAFS                 00253912
*                                                                       00253915
MAFWRITE EQU   *                                                        00253916
         AIF   (&COMP).QQ10                                             00253917
         L     4,SAVREG+PARM2*4  FETCH THE OUTPUT BUFFER                00253918
         LTR   4,4                                                      00253919
         BNZ   MAFWR1                                                   00253920
         LA    3,OUTPUT9                                                00253921
         USING IHADCB,3                                                 00253922
         OPEN  (OUTPUT9,(OUTPUT))                                       00253923
         TM    DCBOFLGS,OPENBIT                                         00253924
         BO    DASSRET0                                                 00253925
         B     DASSRET1                                                 00253926
MAFWR1   ST    4,MFOUTBUF                                               00253927
         WRITE MFOUTDCB,SF,MF=E                                         00253928
         CHECK MFOUTDCB                                                 00253929
         B     DASSRET0                                                 00253930
         WRITE MFOUTDCB,SF,OUTPUT9,0,1680,MF=L                          00253933
MFOUTBUF EQU   MFOUTDCB+12                                              00253936
         AGO   .QQ11                                                    00253937
.QQ10    ANOP                                                           00253938
         B     EXIT                                                     00253939
.QQ11    ANOP                                                           00253940
         SPACE 3                                                        00253941
*        RVL - MONITOR #15 - RETURNS REVISION LEVEL AND CATENATION      00253942
*        NUMBER OF THE LAST PDS MEMBER FOUND.  RVL IS RETURNED AS       00253945
*        THE LEFT HALF WORD AND THE CAT NUMBER AS THE RIGHT.            00254000
RVL      NI    FINDZC+1,X'7F' IGNORE THE ALIAS FLAG                     00254100
         SR    2,2                                                      00254200
         SR    3,3                                                      00254300
         ST    3,SAVREG+PARM1*4                                         00254400
         IC    2,FINDZC+1     LOAD C BYTE                               00254500
         SRDL  2,5            #TTRNS                                    00254600
         SRL   3,26           LENGTH OF USER DATA (TIMES 2 FOR HW)      00254700
         C     3,=F'20'        COMPARE LENGTH WITH NEW FORMAT           00254710
         BNE   RVL001          BRANCH FOR OLD FORMAT                    00254720
         LH    1,FINDUSER+14   LOAD RVL VALUE                           00254730
         B     SAVERVL                                                  00254740
RVL001   EQU   *                                                        00254750
         SLL   2,2            BYTES OF TTRN                             00254800
         SR    1,1                                                      00254900
         SR    3,2            BYTES OF NON TTRN USER DATA               00255000
         BNP   SAVERVL        NO RVL IF NO NON-TTRN USER DATA           00255100
         LH    1,FINDUSER(2)  GET RVL                                   00255200
SAVERVL  STH   1,SAVREG+PARM1*4 SAVE IN FIRST HW OF ANSWER              00255300
         SR    5,5                                                      00255400
         IC    5,FINDTTRK+3       GET BLDL CATENATION NUMBER            00255500
         LA    5,1(0,5)       GET INTO OUR BASE (FIRST=1)               00255600
         STH   5,SAVREG+2+PARM1*4 SECOND HW                             00255700
         B     EXIT                                                     00255800
         SPACE 5                                                        00255805
*                                                                       00255810
*        MONITOR CALL 28 -- ALLOWS DASS TO LINK OFF TO SPECIALIZED      00255815
*        MEMORY DUMP ACCESS AND REFORMATTING MODULES                    00255820
*                                                                       00255825
MON28    EQU   *                                                        00255830
         AIF   (&COMP).QQ14                                             00255835
         L     4,SAVREG+PARM3*4  GET ADDRESS OF COMM. AREA              00255837
         L     3,SAVREG+PARM2*4  FETCH THE MODE NUMBER                  00255840
         B     MON28REQ(3)                                              00255845
MON28REQ B     MON28LD          0     LOAD                              00255850
         B     MON28LNK         4     LINK                              00255855
MON28DEL DELETE EPLOC=(4)       8     DELETE                            00255860
         B     DASSRET0                                                 00255865
MON28LD  LOAD  EPLOC=(4)                                                00255885
         B     DASSRET0                                                 00255895
MON28LNK LR    1,4                                                      00255905
         L     0,PUTDCBS                                                00255907
         LINK  EPLOC=(4)                                                00255910
         ST    15,SAVREG+PARM1*4                                        00255915
         B     EXIT                                                     00255920
.QQ14    ANOP                                                           00255945
         B     EXIT                                                     00255950
         SPACE 5                                                        00255955
*        SET RETURN FLAGS - PARM2 OR'ED IN UNLESS HO BIT SET,           00256000
*        IN WHICH CASE THE ENTIRE RETFLAGS ARE SET TO PARM2             00256100
RETCODE  LTR   PARM2,PARM2                                              00256200
         BM    SETFLAGS                                                 00256300
         IC    1,RETFLAGS                                               00256400
         OR    PARM2,1                                                  00256500
SETFLAGS STC   PARM2,RETFLAGS                                           00256600
         B     EXIT                                                     00256700
         SPACE 5                                                        00256800
*        COMPNAME - PUT CHARACTERISTIC NAME OF THIS COMPILATION         00256900
*        (PASSED IN PARM2) IN THE THIRD PARM FIELD PASSED TO MONITOR    00257000
COMPNAME L     1,NAMEFLD      PICK UP NAME FIELD ADDR                   00257100
         LTR   1,1            WAS ONE SPECIFIED?                        00257200
         BZ    EXIT           NOT SUPPLIED                              00257300
         CLI   SAVREG+PARM2*4,7                                         00257400
         BNE   EXIT           MUST BE LENGTH 8                          00257500
         MVC   0(8,1),0(PARM2) MOVE THE NAME                            00257600
         B     EXIT                                                     00257700
         SPACE 5                                                        00257800
*        TTIME - MONITOR REQUEST TO EXAMINE THE ELAPSED TASK            00257900
*        TIME OF THIS JOB STEP                                          00258000
TTIME    TTIMER                                                         00258100
         LTR   0,0            IS THERE ANY                              00258200
         BZ    GETIME         IF NOT, DO NORMAL XPL TIME REQUEST        00258300
         SRDL  0,32                                                     00258400
         D     0,F384                                                   00258500
         L     3,ONEHOUR                                                00258600
         SR    3,1                                                      00258700
         ST    3,SAVREG+PARM1*4 SAVE TIME IN .01 SEC                    00258800
         B     EXIT                                                     00258900
         SPACE 3                                                        00258910
GETPGMID L     3,IDDESC       LOAD DESCRIPTOR                           00258920
         ST    3,SAVREG+PARM1*4 SAVE FOR RETURN                         00258930
         B     EXIT           RETURN                                    00258940
         SPACE 3                                                        00258950
OPTERR   STM   0,2,ABEREGS       SAVE REGS                              00258960
         LA    1,OPTABE       ABEND CODE                                00258970
         B     ABEND                                                    00258980
         SPACE 3                                                        00258990
BADREQ   STM   0,2,ABEREGS                                              00259000
         LA    1,MONBADRQ          LOAD ABEND CODE                      00259100
         B     ABEND               GO DO ABEND                          00259200
         SPACE 3                                                        00259300
BADFILE  STM   0,2,ABEREGS                                              00259400
         LA    1,MONBADF           LOAD ABEND CODE                      00259500
         B     ABEND               GO DO ABEND                          00259600
         SPACE 3                                                        00259700
DIRABEND STM   0,2,ABEREGS         SAVE REGISTERS                       00259800
         LA    1,DIRABE            LOAD ABEND CODE                      00259900
         AH    1,SAVREG+PARM1*4                                         00260000
         B     ABEND                                                    00260100
         SPACE 3                                                        00260200
STOWERR  STM   0,2,ABEREGS         SAVE REGS                            00260300
         LA    1,STOWABE           LOAD ABEND CODE                      00260400
         AH    1,SAVREG+PARM1*4    ADD IN FILE NUM                      00260500
         B     ABEND                                                    00260600
         SPACE 3                                                        00260700
FINDERR  STM   0,2,ABEREGS         SAVE REGS                            00260800
         LA    1,FINDABE           ABEND CODE                           00260900
         AH    1,SAVREG+PARM1*4    ADD IN FILE NUM                      00261000
         B     ABEND                                                    00261100
         SPACE 3                                                        00261200
SETFERR  STM   0,2,ABEREGS    SAVE REGS                                 00261300
         LA    1,SETFABE      ABEND CODE                                00261400
         AH    1,SAVREG+PARM1*4 ADD IN FILE NUM                         00261500
         B     ABEND                                                    00261600
         SPACE 3                                                        00261605
GETPAGE  ZAP   DOUBLE,PAGENO                                            00261610
         CVB   0,DOUBLE       CONVERT CURRENT DECIMAL PAGE# TO BINARY   00261615
         ST    0,SAVREG+4*PARM1 SET FUNCTION RETURN                     00261620
         B     EXIT                                                     00261625
*                                                                       00261630
DOUBLE   DS    D                                                        00261635
         SPACE 3                                                        00261638
GETJFCB  EQU   *                                                        00261640
         SR    4,4            SET "NO TIOT MOD"                         00261642
         LTR   PARM2,PARM2    IS FILE# >= 0?                            00261645
         BM    BADFILE        ABEND IF NOT                              00261650
         LTR   PARM3,PARM3    TEST FOR INPUT, OUTPUT, OR FILE           00261655
         BZ    FILEJFCB       BR IF FILE(=0)                            00261660
         BM    INJFCB         BR IF INPUT (<0)                          00261665
OUTJFCB  LA    SVCODE,&OUTPUTS                                          00261675
         CR    PARM2,SVCODE  IF REQUESTED OUTPUT EXCEEDS DEFINED OUTPUT 00261680
         BH    BADFILE        THEN ABEND                                00261685
         SLL   PARM2,2        *4                                        00261690
         L     3,PUTDCBS(PARM2) GET DCB ADDR                            00261695
         B     JFCBCOM                                                  00261700
INJFCB   LA    SVCODE,&INPUTS                                           00261705
         CR    PARM2,SVCODE                                             00261706
         BH    BADFILE        EXCEEDED INPUT MAX                        00261707
         SLL   PARM2,2                                                  00261708
         L     3,GETDCBS(PARM2) GET DCB ADDR                            00261709
         USING IHADCB,3                                                 00261710
         TM    DCBOFLGS,OPENBIT IS DCB OPEN?                            00261711
         BNO   JFCBCOM        CONTINUE IF NOT                           00261712
         TM    DCBDSORG,POBITS IS IT A PDS?                             00261713
         BNO   JFCBCOM        BR IF NOT                                 00261714
         CLI   DCBRELAD+3,0   CONCATENATED?                             00261715
         BE    JFCBCOM        BR IF NOT                                 00261716
         EXTRACT DOUBLE,FIELDS=(TIOT)                                   00261717
         L     14,DOUBLE      GET TIOT ADR                              00261718
         SR    5,5                                                      00261719
         IC    5,DCBRELAD+3   GET CONCAT #                              00261720
         LH    4,DCBTIOT      GET OLD TIOT VAL                          00261721
         LR    1,4                                                      00261722
         SR    0,0                                                      00261723
TIOLOOP  IC    0,0(1,14)      GET TIOT ENTRY LENGTH                     00261724
         AR    1,0            OFFSET TO NEXT ENTRY                      00261725
         BCT   5,TIOLOOP                                                00261726
         STH   1,DCBTIOT      SET NEW TIOT VALUE                        00261727
         B     JFCBCOM                                                  00261730
FILEJFCB LTR   PARM2,PARM2    ZERO?                                     00261735
         BNP   BADFILE        YES, ALSO ILLEGAL                         00261740
         LA    SVCODE,&FILES                                            00261742
         CR    PARM2,SVCODE                                             00261745
         BH    BADFILE        THROW OUT IF TOO BIG                      00261750
         SLL   PARM2,3        *8                                        00261755
         L     3,ARWDCBS-8(PARM2) PICK UP DCB                           00261760
*                                                                       00261765
JFCBCOM  RDJFCB ((3))                                                   00261770
         LTR   15,15          TEST RETURN CODE                          00261775
         BZ    *+10           IS OK                                     00261780
         XC    JFCB,JFCB      OTHERWISE, RETURN ALL ZEROS               00261785
         L     0,JFCBDESC     GET DESCRIPTOR                            00261790
         ST    0,SAVREG+4*PARM1 AND RETURN TO USER                      00261795
         LTR   4,4            ANY TIOT MOD?                             00261796
         BZ    EXIT           BR IF NO                                  00261797
         STH   4,DCBTIOT      RESTORE OLD VALUE                         00261798
         B     EXIT                                                     00261800
*                                                                       00261805
*        MONITOR CALL 31 --- VIRTUAL MEMORY LOOKAHEAD SERVICES          00261810
*                                                                       00261815
VMEMSRV  EQU   *                                                        00261820
         AIF   (&XPL).ZZ1                                               00261822
         L     2,SAVREG+PARM3*4  FETCH RECORD #                         00261824
         LTR   2,2                                                      00261826
         BNM   VMEMSRV1                                                 00261828
         L     4,SAVREG+PARM2*4  GET THE SECOND OPERAND                 00261830
         LTR   4,4                                                      00261832
         BZ    VMEMSRV3       PERFORM A CHECK                           00261834
         STH   4,VMEMFIL      SAVE THE FILE NUMBER                      00261836
         B     EXIT                                                     00261838
VMEMFIL  DC    H'2'           DEFAULT IS FILE 2                         00261840
VMEMSRV1 EQU   *                                                        00261842
         LH    5,VMEMFIL      GET THE FILE NUMBER                       00261844
         SLL   5,3                                                      00261846
         LA    5,FILEORG-8(5)                                           00261848
         L     3,ARWDCBS-FILEORG(5)  DCB ADDRESS                        00261850
         L     4,FWRKADDR                                               00261852
         L     4,0(4,5)                                                 00261854
         BAL   14,DASDRECC                                              00261856
         ST    2,TTR                                                    00261858
         BAL   9,XDAPSET          SET UP XDAP INFO                      00261859
         L     4,SAVREG+PARM2*4  GET BUFFER ADDRESS                     00261860
         LTR   4,4                                                      00261862
         BP    VMEMSRV2                                                 00261864
         WAIT  ECB=VMEMECB                                              00261866
VMEMSRV2 EQU   *                                                        00261868
         LA    4,0(,4)        KNOCK DOWN H/O BYTE                       00261870
         XDAP  VMEMECB,RI,(3),(4),(5),,MBBCCHHR READ IN RECORD          00261872
         B     EXIT                                                     00261878
VMEMSRV3 EQU   *                                                        00261880
         WAIT  ECB=VMEMECB                                              00261882
.ZZ1     ANOP                                                           00261884
         B     EXIT                                                     00261886
         SPACE 3                                                        00261888
*                                                                       00261890
*        MONITOR 32            FIND OUT WHETHER SUBPOOLS ARE 2K OR 4K   00261892
*                                                                       00261894
COREINCR L     2,16(0,0)          CVT                                   00261896
         LA    0,2048             NORMAL FOR MFT/MVT/VS1                00261898
         TM    116(2),X'12'       CVTDCB                                00261900
         BNO   *+8                NOT VS2                               00261902
         L     0,F4096            FOR VS2, USE 4096                     00261904
         ST    0,SAVREG+PARM1*4   RETURN IN REG PARM1                   00261906
         B     EXIT                                                     00261908
         SPACE 5                                                        00261910
*                                                                       00261912
*        MONITOR 33               FIND OUT ATTRIBUTES OF DIRECT ACCESS  00261914
*                                 FILE                                  00261916
*                                                                       00261918
*        RETURNS AL2(MAX REC#),AL2(DCBBLKSI)                            00261920
*              WHERE MAXREC# IS -1 IF FILE IS NEW                       00261922
*                                                                       00261924
FILESTAT LA    PARM1,&FILES       MAX FILE#                             00261926
         L     4,SAVREG+PARM2*4   GET REQUESTED FILE#                   00261928
         LTR   4,4                                                      00261930
         BNP   BADFILE            NOT LEGAL FILE NUMBER                 00261932
         CR    4,PARM1                                                  00261934
         BH    BADFILE            DITTO                                 00261936
         SLL   4,3                *8 FOR INDEX INTO DCB TABLE           00261938
         LA    4,FILEORG-8(,4)    CORRECT FOR DISPATCH TABLE            00261940
         L     3,ARWDCBS-FILEORG(4) PICK UP DCB ADDRESS                 00261942
         L     5,FWRKADDR         BEGINNING OF FILE WORK AREAS          00261944
         L     4,0(5,4)           PICK UP ADDRESS OF FILE DESCRIPTOR    00261946
         USING IHADCB,3                                                 00261948
         MVC   BLKSAV,DCBBLKSI   REMEMBER DEFINED BLKSIZ                00261950
         TM    DCBOFLGS,OPENBIT   IS FILE OPEN?                         00261952
         BO    FILEOPEN           YES, RETURN EXISTING ATTRIBUTES       00261954
         CLC   DCBBLKSI,DEFAULT7  HAS SETFILE BEEN DONE?                00261956
         BNE   FILESET            YES, LEAVE INTACT                     00261958
         XC    DCBBLKSI,DCBBLKSI  ZERO OUT BLKSIZE                      00261960
         XC    DCBLRECL,DCBLRECL  AND LRECL TO CATCH NON-DEFAULT STATUS 00261962
FILESET  ST    3,OCDCB            SET UP DCB PARAMETER LIST             00261964
         MVI   OCDCB,X'83'        AND SET STATUS TO INOUT               00261966
         OPEN  MF=(E,OCDCB)       OPEN THE FILE (SAME AS FOR INPUT)     00261968
         TM    DCBOFLGS,OPENBIT   DID IT OPEN PROPERLY                  00261970
         BZ    BADFILE            NO, EXIT STAGE LEFT                   00261972
         BAL   10,DASDSETF        NOW SET UP FILE ATTRIBUTES            00261974
         USING FILEDATA,4                                               00261976
         LH    5,DCBBLKSI         REMEMBER ESTABLISHED BLOCKSIZE        00261978
         NC    FILETTRN,FILETTRN  IS THIS AN EMPTY DATASET              00261980
         BNZ   FILEOPEN-4         NO, MIGHT AS WELL LEAVE IT OPEN       00261982
         MVI   OCDCB,X'80'        SET UP TO CLOSE                       00261984
         CLOSE MF=(E,OCDCB)       CLOSE THE FILE (TO MAKE SUBSEQUENT    00261986
*                                 WRITES WORK O.K.)                     00261988
         MVC   DCBBLKSI,BLKSAV      RESTORE TO STATUS BEFORE OPEN       00261990
         MVC   DCBLRECL,BLKSAV      ..                                  00261992
         STH   5,BLKSAV             RETURN OPEN STATUS TO USER          00261994
FILEOPEN LH    1,FILETTRN         PICK UP TT FIELD                      00261996
         M     0,FILEREC#         * #RECS/TRACK                         00261998
         SR    0,0                                                      00262000
         IC    0,FILETTRN+2       PICK UP R FIELD                       00262002
         AR    1,0                ACTUAL FIRST RECORD                   00262004
         BCTR  1,0                (-1 FOR PROPER FILE RANGE)            00262006
         STH   1,SAVREG+PARM1*4   RETURN MAX REC# TO USER               00262008
         MVC   SAVREG+PARM1*4+2(2),BLKSAV RETURN BLKSIZ TO USER         00262010
         DROP  3,4                                                      00262012
         B     EXIT               RETURN TO USER                        00262014
         EJECT                                                          00262800
         SPACE 5                                                        00262900
         PRINT NOGEN                                                    00263000
*********************************************************************** 00263100
*                                                                     * 00263200
*                                                                     * 00263300
*                                                                     * 00263400
*        DEVICE  CONTROL  BLOCKS  FOR  THE  SUBMONITOR                * 00263500
*                                                                     * 00263600
*                                                                     * 00263700
*********************************************************************** 00263800
*                                                                       00263900
*                                                                       00264000
PROGRAM  DCB   DSORG=PS,                                               X00264100
               MACRF=R,                                                X00264200
               DDNAME=PROGRAM,                                         X00264300
               DEVD=DA,                                                X00264400
               KEYLEN=0,                                               X00264500
               EODAD=EODPGM,                                           X00264600
               BUFNO=0,                                                X00264650
               SYNAD=ERRPGM                                             00264700
*                                                                       00264800
*                                                                       00264900
INPUT0   DCB   DSORG=PS,                                               X00265000
               DDNAME=SYSIN,                                           X00265100
               DEVD=DA,                                                X00265200
               MACRF=GL,                                               X00265300
               EODAD=INEOD,                                            X00265400
               SYNAD=INSYNAD,                                          X00265500
               EXLST=INEXIT1,                                          X00265600
               EROPT=ACC                                                00265700
*                                                                       00265800
*********************************************************************** 00265900
*                                                                     * 00266000
INPUT1   EQU   INPUT0              INPUT(0) & INPUT(1) ARE BOTH SYSIN * 00266100
*                                                                     * 00266200
*********************************************************************** 00266300
*                                                                       00266400
INPUT2   DCB   DSORG=PS,                                               X00266410
               DDNAME=INPUT2,                                          X00266420
               DEVD=DA,                                                X00266430
               MACRF=GL,                                               X00266440
               EODAD=INEOD,                                            X00266450
               SYNAD=INSYNAD,                                          X00266460
               EXLST=INEXIT2,                                          X00266470
               EROPT=ACC                                                00266480
*                                                                       00266500
*                                                                       00266600
         AIF   (&XPL).XX7                                               00266700
INPUT3   DCB   DSORG=PS,      PDS DIRECTORY ATTRIBUTES                 X00266710
               DDNAME=RUNLIB,                                          X00266720
               DEVD=DA,                                                X00266730
               MACRF=GL,                                               X00266740
               EODAD=INEOD,                                            X00266750
               SYNAD=INSYNAD,                                          X00266760
               EXLST=INEXIT3,                                          X00266765
               EROPT=ACC,                                              X00266770
               LRECL=256,                                              X00266780
               BLKSIZE=256,                                            X00266790
               RECFM=F                                                  00266800
         AGO   .XX8                                                     00266810
.XX7     ANOP                                                           00266815
INPUT3   DCB   DSORG=PS,      PDS DIRECTORY ATTRIBUTES                 X00266830
               DDNAME=INPUT3,                                          X00266835
               DEVD=DA,                                                X00266840
               MACRF=GL,                                               X00266845
               EODAD=INEOD,                                            X00266850
               SYNAD=INSYNAD,                                          X00266855
               EXLST=INEXIT3,                                          X00266860
               EROPT=ACC                                                00266865
.XX8     ANOP                                                           00266870
*                                                                       00266900
*                                                                       00267000
INPUT4   DCB   DSORG=PO,                                               X00267100
               DDNAME=INCLUDE,                                         X00267200
               DEVD=DA,                                                X00267300
               MACRF=R,                                                X00267400
               SYNAD=IPDSYNAD,                                         X00267500
               EODAD=PDSEOD,                                           X00267600
               EXLST=INEXIT4,                                          X00267700
               BUFNO=1,                                                X00267800
               RECFM=FB                                                 00267900
         AIF   (&XPL).QI1                                               00267910
*                                                                       00268000
*                                                                       00268100
INPUT5   DCB   DSORG=PO,                                               X00268200
               DDNAME=ERROR,                                           X00268300
               DEVD=DA,                                                X00268400
               MACRF=R,                                                X00268500
               SYNAD=IPDSYNAD,                                         X00268600
               EODAD=PDSEOD,                                           X00268700
               EXLST=INEXIT5,                                          X00268800
               BUFNO=1,                                                X00268900
               RECFM=FB                                                 00269000
*                                                                       00269100
*                                                                       00269200
INPUT6   DCB   DSORG=PO,                                               X00269300
               DDNAME=ACCESS,                                          X00269400
               DEVD=DA,                                                X00269500
               MACRF=R,                                                X00269600
               SYNAD=IPDSYNAD,                                         X00269700
               EODAD=PDSEOD,                                           X00269800
               EXLST=INEXIT6,                                          X00269900
               BUFNO=1,                                                X00270000
               RECFM=FB                                                 00270100
*                                                                       00270200
*                                                                       00270300
INPUT7   DCB   DSORG=PO,                                               X00270400
               DDNAME=INCLUDE,                                         X00270500
               DEVD=DA,                                                X00270600
               MACRF=R,                                                X00270700
               SYNAD=IPDSYNAD,                                         X00270800
               EODAD=PDSEOD,                                           X00270900
               EXLST=INEXIT7,                                          X00271000
               BUFNO=1,                                                X00271100
               RECFM=FB                                                 00271200
         AIF   (&COMP).QI1                                              00271202
*                                                                       00271205
*                                                                       00271210
INPUT8   DCB   DSORG=PO,                                               X00271215
               DDNAME=HALLIB,                                          X00271220
               DEVD=DA,                                                X00271225
               MACRF=R,                                                X00271230
               SYNAD=IPDSYNAD,                                         X00271235
               EODAD=LMODEOD,                                          X00271240
               EXLST=INEXIT8,                                          X00271245
               BUFNO=0,                                                X00271250
               RECFM=U                                                  00271255
*                                                                       00271260
*                                                                       00271265
INPUT9   DCB   DSORG=PO,                                               X00271270
               DDNAME=MAFIN,                                           X00271275
               DEVD=DA,                                                X00271280
               MACRF=R,                                                X00271285
               SYNAD=IPDSYNAD,                                         X00271287
               EODAD=DASSRET1,                                         X00271288
               EXLST=INEXIT9,                                          X00271289
               BUFNO=0,                                                X00271296
               RECFM=F                                                  00271297
         AGO   .QI2                                                     00271299
.QI1     ANOP                                                           00271304
*                                                                       00271309
*                                                                       00271314
INPUT8   DCB   DSORG=PS,                                               X00271319
               DDNAME=BASESRC,                                         X00271324
               DEVD=DA,                                                X00271329
               MACRF=GL,                                               X00271334
               EODAD=INEOD,                                            X00271339
               SYNAD=INSYNAD,                                          X00271344
               EXLST=INEXIT8,                                          X00271349
               EROPT=ACC                                                00271354
*                                                                       00271359
*                                                                       00271364
INPUT9   DCB   DSORG=PO,                                               X00271369
               DDNAME=BASEINCL,                                        X00271374
               DEVD=DA,                                                X00271379
               MACRF=R,                                                X00271384
               SYNAD=IPDSYNAD,                                         X00271389
               EODAD=PDSEOD,                                           X00271394
               EXLST=INEXIT9,                                          X00271399
               BUFNO=1,                                                X00271404
               RECFM=FB                                                 00271409
*                                                                       00271414
*                                                                       00271419
INPUT10  DCB   DSORG=PS,                                               X00271424
               DDNAME=PATCHLOG,                                        X00271429
               DEVD=DA,                                                X00271434
               MACRF=GL,                                               X00271439
               EODAD=INEOD,                                            X00271444
               SYNAD=INSYNAD,                                          X00271449
               EXLST=INEXIT10,                                         X00271454
               EROPT=ACC                                                00271459
.QI2     ANOP                                                           00271464
*                                                                       00271469
*                                                                       00271474
INPUT11  DCB   DSORG=PO,                                               X00271479
               DDNAME=BASECU,                                          X00271484
               DEVD=DA,                                                X00271489
               MACRF=R,                                                X00271494
               SYNAD=IPDSYNAD,                                         X00271499
               EODAD=LMODEOD,                                          X00271504
               EXLST=INEXIT11,                                         X00271509
               BUFNO=0,                                                X00271514
               RECFM=U                                                  00271519
OUTPUT0  DCB   DSORG=PS,                                               X00271524
               LRECL=133,     MONITOR ASSUMES 133, ERROR IF NOT        X00271529
               RECFM=FBA,                                              X00271534
               DDNAME=SYSPRINT,                                        X00271600
               DEVD=DA,                                                X00271700
               MACRF=PL,                                               X00271800
               SYNAD=OUTSYNAD,                                         X00271900
               EXLST=OUTEXIT1,                                         X00272000
               EROPT=ACC                                                00272100
*                                                                       00272200
*                                                                       00272300
*********************************************************************** 00272400
*                                                                     * 00272500
OUTPUT1  EQU   OUTPUT0             OUTPUT(0), OUTPUT(1) BOTH SYSPRINT * 00272600
*                                                                     * 00272700
*********************************************************************** 00272800
*                                                                       00272900
*                                                                       00273000
OUTPUT2  DCB   DSORG=PS,                                               X00273100
               DDNAME=LISTING2,                                        X00273200
               DEVD=DA,                                                X00273300
               MACRF=PL,                                               X00273400
               SYNAD=OUTSYNAD,                                         X00273500
               EXLST=OUTEXIT2,                                         X00273600
               EROPT=ACC                                                00273700
*                                                                       00273800
*                                                                       00273900
         AIF (&BF).B2          **** DR101925 - P. ANSLEY, 5/22/92 **
OUTPUT3  DCB   DSORG=PS,                                               X
               DDNAME=OUTPUT3,                                         X
               DEVD=DA,                                                X
               MACRF=PL,                                               X
               SYNAD=OUTSYNAD,                                         X
               EXLST=OUTEXIT3,                                         X
               EROPT=ACC
         AGO .C2               ***** DR101925 - P. ANSLEY, 5/22/92 **
.B2      ANOP
OUTPUT3  DCB   DSORG=PO,                                               X00274000
               DDNAME=OUTPUT3,                                         X00274100
               DEVD=DA,                                                X00274200
               MACRF=(W),                                              X00274300
               SYNAD=OPDSYNAD,                                         X00274400
               EXLST=OUTEXIT3,                                         X00274500
               BUFNO=1                                                  00274600
.C2      ANOP                  ***** END DR101925  *****
*                                                                       00274700
*                                                                       00274800
OUTPUT4  DCB   DSORG=PS,                                               X00274900
               DDNAME=OUTPUT4,                                         X00275000
               DEVD=DA,                                                X00275100
               MACRF=PL,                                               X00275200
               SYNAD=OUTSYNAD,                                         X00275300
               EXLST=OUTEXIT4,                                         X00275400
               EROPT=ACC                                                00275500
*                                                                       00275600
*                                                                       00275700
OUTPUT5  DCB   DSORG=PO,  BUFNO FOR OUTPUT5 SHOULD BE LEFT AT ZERO     X00275800
               DDNAME=OUTPUT5,                                         X00275900
               DEVD=DA,                                                X00276000
               EXLST=OUTEXIT5,                                         X00276100
               MACRF=(R,W),                                            X00276200
               BUFNO=0,                                                X00276300
               SYNAD=OPDSYNAD                                           00276400
*                                                                       00276500
*                                                                       00276600
OUTPUT6  DCB   DSORG=PO,                                               X00276700
               DDNAME=OUTPUT6,                                         X00276800
               DEVD=DA,                                                X00276900
               EXLST=OUTEXIT6,                                         X00277000
               MACRF=W,                                                X00277100
               RECFM=FB,                                               X00277200
               BUFNO=1,                                                X00277300
               SYNAD=OPDSYNAD                                           00277400
*                                                                       00277500
*                                                                       00277600
OUTPUT7  DCB   DSORG=PS,                                               X00277700
               DDNAME=OUTPUT7,                                         X00277800
               DEVD=DA,                                                X00277900
               MACRF=PL,                                               X00278000
               SYNAD=OUTSYNAD,                                         X00278100
               EXLST=OUTEXIT7,                                         X00278200
               EROPT=ACC                                                00278300
*                                                                       00278400
*                                                                       00278500
OUTPUT8  DCB   DSORG=PO,                                               X00278600
               DDNAME=OUTPUT8,                                         X00278700
               DEVD=DA,                                                X00278800
               EXLST=OUTEXIT8,                                         X00278900
               MACRF=W,                                                X00279000
               RECFM=FB,                                               X00279100
               BUFNO=1,                                                X00279200
               SYNAD=OPDSYNAD                                           00279300
*                                                                       00279301
*                                                                       00279302
OUTPUT9  DCB   DSORG=PS,                                               X00279303
               DDNAME=PATCHLOG,                                        X00279304
               DEVD=DA,                                                X00279305
               MACRF=PL,                                               X00279306
               SYNAD=OUTSYNAD,                                         X00279307
               EXLST=OUTEXIT9,                                         X00279308
               EROPT=ACC                                                00279309
         AIF   (&XPLE).XE3                                              00279310
         AIF   (&COMP).QO1                                              00279311
.XE3     ANOP                                                           00279312
*                                                                       00279313
*                                                                       00279314
OUTPUT9  DCB   DSORG=PO,                                               X00279315
               DDNAME=MAFOUT,                                          X00279320
               DEVD=DA,                                                X00279325
               MACRF=W,                                                X00279330
               SYNAD=OPDSYNAD,                                         X00279335
               EXLST=OUTEXIT9,                                         X00279340
               BUFNO=0,                                                X00279345
               RECFM=F                                                  00279350
.QO1     ANOP                                                           00279360
         AIF   (NOT &XPLE).SKP7                                         00279400
*                                                                       00279403
*                                                                       00279406
OUTPUT10 DCB   DSORG=PS,                                               X00279409
               DDNAME=OUTPUT10,                                        X00279412
               DEVD=DA,                                                X00279415
               MACRF=PL,                                               X00279418
               SYNAD=OUTSYNAD,                                         X00279421
               EXLST=OUTEXITA,                                         X00279424
               EROPT=ACC                                                00279427
*                                                                       00279430
*                                                                       00279433
OUTPUT11 DCB   DSORG=PS,                                               X00279436
               DDNAME=OUTPUT11,                                        X00279439
               DEVD=DA,                                                X00279442
               MACRF=PL,                                               X00279445
               SYNAD=OUTSYNAD,                                         X00279448
               EXLST=OUTEXITB,                                         X00279451
               EROPT=ACC                                                00279454
*                                                                       00279457
*                                                                       00279460
OUTPUT12 DCB   DSORG=PS,                                               X00279463
               DDNAME=OUTPUT12,                                        X00279466
               DEVD=DA,                                                X00279469
               MACRF=PL,                                               X00279472
               SYNAD=OUTSYNAD,                                         X00279475
               EXLST=OUTEXITC,                                         X00279478
               EROPT=ACC                                                00279481
*                                                                       00279484
*                                                                       00279487
OUTPUT13 DCB   DSORG=PS,                                               X00279490
               DDNAME=OUTPUT13,                                        X00279493
               DEVD=DA,                                                X00279496
               MACRF=PL,                                               X00279499
               SYNAD=OUTSYNAD,                                         X00279502
               EXLST=OUTEXITD,                                         X00279505
               EROPT=ACC                                                00279508
*                                                                       00279511
*                                                                       00279514
OUTPUT14 DCB   DSORG=PS,                                               X00279517
               DDNAME=OUTPUT14,                                        X00279520
               DEVD=DA,                                                X00279523
               MACRF=PL,                                               X00279526
               SYNAD=OUTSYNAD,                                         X00279529
               EXLST=OUTEXITE,                                         X00279532
               EROPT=ACC                                                00279535
.SKP7     ANOP                                                          00279538
*                                                                       00279541
*                                                                       00279544
*********************************************************************** 00279600
*                                                                     * 00279700
*                                                                     * 00279800
*        DCBS FOR THE DIRECT ACCESS FILES                             * 00279900
*                                                                     * 00280000
*                                                                     * 00280100
*        BECAUSE OF THE MANNER IN WHICH THE FILES ARE USED,  IT IS    * 00280200
*        NECESSARY TO HAVE TWO DCB'S FOR EACH FILE.  ONE DCB FOR      * 00280300
*        READING AND ONE FOR WRITING.                                 * 00280400
*                                                                     * 00280500
*                                                                     * 00280600
*********************************************************************** 00280700
         SPACE 2                                                        00280800
&I       SETA  1                                                        00280900
.DD1     AIF   (&I GT &FILES).DD2                                       00281000
         SPACE 1                                                        00281100
FILE&I    DCB  DSORG=PS,                                               X00281200
               MACRF=(RP,WP),                                          X00281300
               DDNAME=FILE&I,                                          X00281400
               DEVD=DA,                                                X00281500
               RECFM=F,                                                X00281600
               LRECL=FILEBYTS,                                         X00281700
               BLKSIZE=FILEBYTS,                                       X00281800
               KEYLEN=0,                                               X00281900
               EXLST=FILEEXIT,                                         X00281910
               EODAD=FILEEOD,                                          X00282000
               SYNAD=FILESYND                                           00282100
         SPACE 1                                                        00283200
&I       SETA  &I+1                                                     00283300
         AGO   .DD1                                                     00283400
.DD2     ANOP                                                           00283500
         EJECT                                                          00283600
*********************************************************************** 00283700
*                                                                     * 00283800
*                                                                     * 00283900
*        DUMMY  DCB  FOR  DEFINING  DCB  FIELDS                       * 00284000
*                                                                     * 00284100
*                                                                     * 00284200
*********************************************************************** 00284300
         SPACE 2                                                        00284400
         DCBD  DSORG=(PS,PO),DEVD=DA                                    00284500
HALSDF   EQU   SDFDDNAM+IHADCB-DCBDDNAM  PHONY DCB ADDRESS              00284510
IPDSDATA DSECT                                                          00284600
INBUFSIZ DS    1F                                                       00284700
INAREA   DS    1F                                                       00284800
INBLKDAT DS    1F                                                       00284900
INDDNAM1 DS    CL8            DDNAME ASSIGNED TO THIS FILE              00284950
INDDNAM2 DS    CL8            DDNAME THIS FILE IS OPEN WITH             00284960
*                                                                       00285000
OPDSDATA DSECT                                                          00285100
BLKDATA  DS    1F                                                       00285200
AREADATA DS    1F                                                       00285300
DDNAME   DS    CL8            ASSOCIATED DDNAME                         00285310
*                                                                       00285400
FILEDATA DSECT                                                          00285402
FILETTRN DS    F              ADDRESS OF HIGHEST RECORD WRITTEN         00285404
FILEREC# DS    F              # OF RECORDS/TRACK FOR CURRENT BLKSIZE    00285406
*                                                                       00285410
JFCBD    DSECT                                                          00285412
JFCBDSNM DS    CL44           DATASET NAME                              00285414
         DS    74C                                                      00285416
JFCBVOLS DS    5CL6           VOLUME NAME(S)                            00285418
*                                                                       00285420
DS1CB    DSECT                                                          00285422
         DS    (86-44)C                                                 00285424
DS1BLKL  DS    H              BLOCKSIZE AT CLOSE                        00285426
         DS    10C                                                      00285428
DS1LSTAR DS    CL3            TTR OF LAST BLOCK                         00285430
DS1TRBAL DS    CL2                BALANCE FROM LAST BLOCK               00285431
*                                                                       00285432
CVT      DSECT                                                          00285434
         DS    7F                                                       00285436
CVTPCNVT DS    F              ADDRESS OF TTR TO MBBCCHHR ROUTINE        00285438
*                                                                       00285440
DEVT     DSECT                                                          00285442
DEVT#CYL DS    H                                                        00285444
DEVT#TRK DS    H                                                        00285446
DEVTTCAP DS    H              TRACK CAPACITY                            00285448
DEVTOVH1 DS    C              BLOCK OVERHEAD FOR ALL BUT LAST REC       00285450
DEVTOVHN DS    C              BLOCK OVERHEAD FOR LAST REC               00285452
DEVTNKEY DS    C              FACTOR FOR NO KEYS                        00285454
DEVTFLAG DS    C              WHAT ELSE                                 00285456
DEVTTOLF DS    H              TOLERANCE FACTOR (IF FLAG INDICATES)      00285458
*                                                                       00285460
BASEDREC DSECT                    FORMAT OF BASED RECORD DOPE VECTOR    00285462
BRECPTR  DS    A                  ADDRESS OF ALLOCATED DATA             00285464
BRECWDTH DS    H                  ACTUAL WIDTH OF RECORD TEMPLATE       00285466
BRECNDSC DS    H                  NUMBER OF DESCRIPTORS IN RECORD       00285468
BRECALOC DS    F                  NUMBER OF RECORDS ALLOCATED           00285470
BRECUSED DS    F                  NUMBER OF RECORDS IN ACTUAL USE       00285472
BRECNEXT DS    F                  POINTER TO NEXT ALLOCATED RECORD      00285474
BRECASOC DS    F                  ASSOCIATED RECORD                     00285476
BRECGLOB DS    H                  GLOBAL FACTOR                         00285478
BRECGRUP DS    H                  GROUP FACTOR                          00285480
         EJECT                                                          00285482
IOPACK   CSECT                                                          00285500
         AIF   (NOT &XPL).XX9                                           00285510
MON#5    EQU   TTIME                                                    00285520
MON#9    B     EXIT                                                     00285530
MON#10   B     EXIT                                                     00285540
MON#12   B     EXIT                                                     00285550
         AGO   .XX10                                                    00285560
.XX9     ANOP                                                           00285570
MON#5    ST    PARM2,ADDRWORK                                           00285600
         TM    ADDRWORK+3,7                                             00285700
         BNZ   AB3000                                                   00285800
         MVC   ZONKHERE(8),ZONKED CHANGE TO APPROP. BC 15'S             00285900
         B     EXIT                                                     00286000
         EJECT                                                          00286100
MON#9    LTR   PARM2,PARM2                                              00286200
         BNH   RETURN01                                                 00286300
         SH    PARM2,MAX#9REQ                                           00286400
         SLL   PARM2,2                                                  00286500
         L     4,ADDRWORK                                               00286600
         LD    0,0(0,4)                                                 00286700
         ST    13,SREG13                                                00286800
         L     13,ADSAVEA JUST SO IF INTERRUPT OCCURS,                  00286900
         STM   14,12,12(13) WE CAN DO LM IN SPIE ROUTINE                00287000
         BH    MON#9CAL                                                 00287100
         EX    0,BRTABEND(PARM2)                                        00287200
RETURN00 STD   0,0(0,4) SAVE ANSWER                                     00287300
         SR    PARM1,PARM1                                              00287400
         L     13,SREG13                                                00287500
         ST    PARM1,SAVREG+4*PARM1 RETURN CODE = 0                     00287600
         B     EXIT                                                     00287700
RETURN01 LA    PARM1,1                                                  00287800
         L     13,SREG13                                                00287900
         ST    PARM1,SAVREG+4*PARM1 RC=1                                00288000
         B     EXIT                                                     00288100
         SPACE 5                                                        00288200
BRANCHTB AD    0,8(0,4)                                                 00288300
         SD    0,8(0,4)                                                 00288400
         MD    0,8(0,4)                                                 00288500
         B     FDIVIDE                                                  00288600
BRTABEND B     EXPON                                                    00288700
         SPACE 5                                                        00288800
FDIVIDE  OC    9(7,4),9(4)                                              00288900
         BZ    RETURN01                                                 00289000
         DD    0,8(0,4)                                                 00289100
         B     RETURN00                                                 00289200
         SPACE 5                                                        00289300
EXPON    LD    2,8(0,4) EXPONENT (BASE IN F0)                           00289400
         AW    2,X4E00ETC     UNNORMALIZE                               00289500
         LDR   4,2                                                      00289600
         ADR   2,2 NORMALIZE                                            00289700
         HDR   2,2                                                      00289800
         CD    2,8(0,4) SAME AS BEFORE --> INTEGER EXPONENT             00289900
         BNE   CALLEXP                                                  00290000
         STD   4,8(0,4)                                                 00290100
         OC    9(4,4),9(4) NICE SMALL NUMBER???                         00290200
         BNZ   CALLEXP NO,SEE IF WE CAN DO IT VIA EXP(LOG)              00290300
         L     6,12(0,4) INTEGER PORTION                                00290400
         LTDR  2,2 POS OR NEG                                           00290500
         MVI   EXPMD+1,0                                                00290600
         LD    2,D#ONE                                                  00290700
         BH    EXPLTR                                                   00290800
         LTDR  0,0 BETTER NOT BE 0**NON POS                             00290900
         BZ    RETURN01                                                 00291000
         MVI   EXPMD+1,240                                              00291100
         SPACE                                                          00291200
EXPLTR   LTR   6,6                                                      00291300
         BZ    EXPEND                                                   00291400
         SPACE                                                          00291500
EXPSHIFT SRDL  6,1                                                      00291600
         LTR   7,7                                                      00291700
         BNL   EXPTEST                                                  00291800
EXPMD    NOP   EXPDIV                                                   00291900
         MDR   2,0                                                      00292000
         B     EXPTEST                                                  00292100
EXPDIV   DDR   2,0                                                      00292200
EXPTEST  DC    0H'0'                                                    00292300
         LTR   6,6                                                      00292400
         BZ    EXPEND                                                   00292500
         MDR   0,0                                                      00292600
         B     EXPSHIFT                                                 00292700
         SPACE                                                          00292800
EXPEND   LDR   0,2                                                      00292900
         B     RETURN00                                                 00293000
         SPACE 5                                                        00293100
CALLEXP  DC    0H'0'                                                    00293200
         MVI   TANGENT+1,X'F0'                                          00293300
         MVC   TANGENT+2(2),STOSCON1                                    00293400
         L     15,VCONTAB+4*4    LOG                                    00293500
STOSTEST LTR   15,15                                                    00293600
         BH    DOCALLS                                                  00293700
STOS01   MVI   TANGENT+1,0                                              00293800
         B     RETURN01                                                 00293900
STOSCON1 DC    S(STOS1)                                                 00294000
STOSCON2 DC    S(STOS2)                                                 00294100
STOS1    BCT   15,*+8                                                   00294200
         B     STOS01                                                   00294300
         MD    0,8(0,4)                                                 00294400
         L     15,VCONTAB+3*4   EXP                                     00294500
         MVC   TANGENT+2(2),STOSCON2                                    00294600
         B     STOSTEST                                                 00294700
STOS2    MVI   TANGENT+1,0                                              00294800
         BCT   15,RETURN00                                              00294900
         B     RETURN01                                                 00295000
         EJECT                                                          00295100
MON#10   SR    1,1                                                      00295200
         IC    1,SAVREG+PARM2*4 LENGTH                                  00295300
         LA    1,1(0,1) TRUE LENGTH                                     00295400
         L     15,V#XTOD                                                00295500
         L     4,ADDRWORK BUFFER ADDRESS                                00295600
         B     DOCALLS                                                  00295700
         SPACE 5                                                        00295800
MON#9CAL CH    PARM2,MAX#9CAL                                           00295900
         BH    RETURN01                                                 00296000
         L     15,VCONTAB-4(PARM2)                                      00296100
DOCALLS  LTR   15,15                                                    00296200
         BNH   RETURN01                                                 00296300
         ST    13,SREG13                                                00296400
         L     13,ADSAVEA                                               00296500
         STM   14,12,12(13)                                             00296600
         BALR  14,15                                                    00296700
         USING *,14                                                     00296800
         L     1,ADSAVEA                                                00296900
         DROP  14                                                       00297000
         LM    0,12,12+8(1) DON'T RESTORE R 15                          00297100
         L     13,SREG13   RESTORE REG 13                               00297200
TANGENT  NOP   *                                                        00297300
         BCT   15,RETURN00                                              00297400
         B     RETURN01                                                 00297500
         SPACE 5                                                        00297600
MON#12   L     15,V#DTOC                                                00297700
         LTR   15,15 LINKED IN?                                         00297800
         BNH   MON#12A NO, RETURN NULL STRING                           00297900
         L     0,SAVREG+PARM2*4 GET LENGTH CODE (E=0,D=8)               00298000
         L     4,ADDRWORK BUFFER ADDRESS                                00298100
         LD    0,0(0,4) VALUE INTO F0                                   00298200
         ST    13,SREG13                                                00298300
         L     13,ADSAVEA                                               00298400
         STM   14,12,12(13)                                             00298500
         BALR  14,15                                                    00298600
         L     13,(ADSAVEA-*)(0,14) ADDRESS OF SAVE AREA                00298700
         LM    0,12,12+8(13) R15 CONTAINS PTR TO STRING                 00298800
         L     13,SREG13 RESTORE R 13                                   00298900
MON#12A  ST    15,SAVREG+PARM1*4 PASS BACK DESCRIPTOR                   00299000
         B     EXIT                                                     00299100
         SPACE 5                                                        00299200
V#DTOC   DC    V(XXDTOC)                                                00299300
V#XTOD   DC    V(XXXTOD)                                                00299400
VCONTAB  DC    V(XXDSIN)                                                00299500
         DC    V(XXDCOS)                                                00299600
         DC    A(XXDTAN)                                                00299700
         DC    V(XXDEXP)                                                00299800
         DC    V(XXDLOG)                                                00299900
         DC    V(XXDSQRT)                                               00300000
         SPACE 5                                                        00300100
XXDTAN   MVI   TANGENT+1,240                                            00300200
         MVC   TANGENT+2(2),XXSCON1                                     00300300
         L     15,VCONTAB+4 COSINE                                      00300400
XXTEST   LTR   15,15                                                    00300500
         BH    DOCALLS                                                  00300600
XXTAN01  MVI   TANGENT+1,0                                              00300700
         B     RETURN01                                                 00300800
XXSCON1  DC    S(XXTAN1)                                                00300900
XXSCON2  DC    S(XXTAN2)                                                00301000
XXTAN1   BCT   15,*+8                                                   00301100
         B     XXTAN01                                                  00301200
         STD   0,8(0,4)  SAVE RESULT                                    00301300
         LD    0,0(0,4) ORIGINAL ARG                                    00301400
         L     15,VCONTAB SINE                                          00301500
         MVC   TANGENT+2(2),XXSCON2                                     00301600
         B     XXTEST                                                   00301700
XXTAN2   MVI   TANGENT+1,0                                              00301800
         BCT   15,FDIVIDE                                               00301900
         B     RETURN01                                                 00302000
         EJECT                                                          00302100
SPIEADDR MVC   (SPIETYPE-SPIEADDR)(1,15),7(1) TYPE SAVED                00302500
         MVC   9(3,1),(SPIETYPE+1-SPIEADDR)(15)                         00304400
         BR    14                                                       00304500
         SPACE 5                                                        00304600
SPIEEXIT BALR  9,0                                                      00304700
         L     13,(ADSAVEA-SPIEEXIT-2)(0,9) NO UINGS                    00304800
         LM    14,12,12(13) RESTORE AS BEFORE                           00304900
         MVI   TANGENT+1,0                                              00305000
         CLI   SPIETYPE,12                                              00305100
         BNE   *+14                                                     00305200
         MVC   0(8,4),X7FETC                                            00305300
         B     RETURN01                                                 00305400
         XC    0(8,4),0(4)                                              00305500
         B     RETURN01                                                 00305600
         EJECT                                                          00305700
D#ONE    DC    D'1'                                                     00305800
X4E00ETC   DC    X'4E00000000000000'                                    00305900
ADSAVEA  DC    A(SAVE)                                                  00306100
SREG13   DC    A(0) SAVE REGISTER 13 HERE                               00306200
SPIETYPE DC    A(SPIEEXIT)                                              00306300
ADDRWORK DC    A(0)                                                     00306400
MAX#9REQ DC    H'5' # OF NON CALL MON#9'S                               00306500
MAX#9CAL DC    AL2(6*4) MAX # OF CALL TYPES LEFT SHIFTED 2              00306600
X7FETC   DC    X'7FFFFFFFFFFFFFFF'                                      00306700
.XX10    ANOP                                                           00306710
*                                                                       00306720
JFCB     DC    XL176'00'                                                00306750
         DS    0D                                                       00306850
DSCBWORK DC    XL148'0'                                                 00306950
XPLSMEND EQU   *                                                        00307500
         END                                                            00307600
