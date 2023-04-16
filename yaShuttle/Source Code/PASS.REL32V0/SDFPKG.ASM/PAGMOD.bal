*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    PAGMOD.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

         TITLE 'PAGMOD  -  PAGING AREA AND FCB AREA DATA MANAGER'       00000100
         GBLA  &PAG1                                                    00000200
         GBLA  &PAG2                                                    00000300
         GBLA  &FCBPRIM                                                 00000400
&PAG1    SETA  2                                                        00000500
&PAG2    SETA  250                                                      00000600
&FCBPRIM SETA  1024           SIZE OF FCB PRIMARY ALLOCATION            00000700
PAGMOD   CSECT                                                          00000800
*                                                                       00000900
*     UPON ENTRY, REGISTER 1 CONTAINS A SERVICE CODE.                   00001000
*                                                                       00001100
         USING *,15                                                     00001105
         B     *+12                                                     00001110
         DC    CL8'PAGMOD  '                                            00001115
         BALR  15,0                                                     00001117
         DROP  15                                                       00001120
         OSSAVE                                                         00001200
         USING COMMTABL,R10                                             00001300
         USING DATABUF,R11                                              00001400
         B     SERVICES(R1)                                             00001500
SERVICES B     INIT           INITIALIZE                                00001600
         B     TERM           TERMINATE                                 00001700
         B     AUGMENT        AUGMENT PAGING AREA OR FCB AREA           00001800
         B     RESCIND        RESCIND AUGMENTED PAGING AREA             00001900
*                                                                       00002000
INIT     EQU   *                                                        00002100
         TM    MISC+1,X'04'   ALTERNATE DDNAME SPECIFIED?               00002200
         BNO   NOALTDD                                                  00002300
         LA    R1,PDSFILE     POINT AT THE DCB                          00002400
         USING IHADCB,R1                                                00002500
         MVC   DCBDDNAM(8),SDFDDNAM                                     00002600
         DROP  R1                                                       00002700
NOALTDD  TM    MISC+1,X'02'   IS UPDAT MODE SPECIFIED?                  00002800
         BO    UPDATM                                                   00002900
         OPEN  (PDSFILE,(INPUT))                                        00003000
         B     CHKOPEN                                                  00003100
UPDATM   OPEN  (PDSFILE,(UPDAT))                                        00003200
         MVI   MODFLAG,1      INDICATE UPDAT MODE ACTIVE                00003300
CHKOPEN  LA    R12,PDSFILE                                              00003400
         USING IHADCB,R12                                               00003500
         TM    DCBOFLGS,X'10'                                           00003600
         DROP  R12                                                      00003700
         BO    OPENOK                                                   00003800
         MVI   RETCODE+3,4                                              00003900
         B     EXIT                                                     00004000
*                                                                       00004100
*        ALLOCATE AND INITIALIZE PAGING AREA                            00004200
*                                                                       00004300
OPENOK   TM    MISC+1,X'20'   TEST FOR ALTERNATE PAD                    00004400
         BNO   OPENOK1                                                  00004500
         LH    R0,LPAD        NUMBER OF 16-BYTE PAD SLOTS               00004600
         SLL   R0,4           CONVERT TO BYTES                          00004700
         L     R1,APAD        GET ADDRESS OF ORIGINAL PAD               00004800
         L     R6,FCBSTK1     ADDRESS OF ADDRESS STACK                  00004900
         L     R7,FCBSTK2     ADDRESS OF LENGTH STACK                   00005000
         ST    R1,0(R6)                                                 00005100
         ST    R0,0(R7)                                                 00005200
         LA    R5,1                                                     00005300
         STH   R5,FCBSTKLN                                              00005400
         L     R1,ADDR        GET ADDRESS OF USER-SUPPLIED PAD          00005500
         ST    R1,APAD                                                  00005600
         L     R1,PNTR        GET # OF BYTES IN USER-SUPPLIED PAD       00005700
         SRL   R1,4           CONVERT TO A 16-BYTE COUNT                00005800
         STH   R1,LPAD                                                  00005900
         SR    R0,R0                                                    00005905
         ST    R0,ADDR                                                  00005910
         ST    R0,PNTR                                                  00005915
OPENOK1  LH    R0,NPAGES                                                00006000
         LH    R8,LPAD                                                  00006100
         CR    R0,R8                                                    00006200
         BH    ABEND2         NPAGES MUST BE <= &PAG2                   00006300
         LTR   R0,R0                                                    00006400
         BM    ABEND2         NPAGES MUST BE >= 0                       00006500
         BNZ   USEHIS1                                                  00006600
         L     R1,APGAREA                                               00006700
         LTR   R1,R1                                                    00006800
         BNZ   ABEND2                                                   00006900
         LA    R0,&PAG1       ALLOCATE A MINIMAL AMOUNT                 00007000
USEHIS1  STH   R0,BASNPGS     SAVE BASE NUMBER OF PAGES                 00007100
         L     R1,APGAREA                                               00007200
         ST    R1,AREATEMP    PAGING AREA ADDRESS (IF SUPPLED)          00007300
         LTR   R1,R1                                                    00007400
         BM    ABEND2                                                   00007500
         BNZ   EXTRNPGS                                                 00007600
         L     R2,GETMSTK1    ADDRESS OF GETMAIN ADDRESS STACK          00007700
         L     R3,GETMSTK2    ADDRESS OF GETMAIN LENGTH STACK           00007800
         MH    R0,=H'1680'    CONVERT # OF PAGES TO BYTES               00007900
         ST    R0,BYTETEMP                                              00008000
         GETMAIN R,LV=(0)                                               00008100
         LTR   R15,R15                                                  00008200
         BNZ   ABEND4                                                   00008300
         ST    R1,AREATEMP    SAVE ADDRESS OF GETMAIN'D AREA            00008400
         ST    R1,0(R2)       INSERT INTO GETMAIN ADDRESS STACK         00008500
         L     R0,BYTETEMP                                              00008600
         ST    R0,0(R3)       INSERT INTO GETMAIN LENGTH STACK          00008700
         LA    R0,1                                                     00008800
         STH   R0,NUMGETM     INDICATE ONE GETMAIN TO DATE              00008900
EXTRNPGS LH    R0,BASNPGS                                               00009000
         STH   R0,NUMOFPGS    SIZE OF CURRENT PAGING AREA               00009100
         LH    R1,LPAD        R1 = MAX PAGES THAT WE CAN HANDLE         00009200
         SR    R1,R0                                                    00009300
         STH   R1,NPAGES      TELL THE USER HOW MUCH IS LEFT            00009400
*                                                                       00009500
*        INITIALIZE THE PAGING AREA DIRECTORY                           00009600
*                                                                       00009700
         USING PDENTRY,R8                                               00009800
         L     R8,APAD        R8 = START OF PAGING AREA DIRECTORY       00009900
         SR    R7,R7                                                    00010000
         LH    R6,BASNPGS                                               00010100
         L     R5,AREATEMP                                              00010200
INITLOOP ST    R5,PAGEADDR(R7)                                          00010300
         LA    R5,1680(R5)                                              00010400
         LA    R7,PDENTLEN(R7)                                          00010500
         BCT   R6,INITLOOP                                              00010600
         DROP  R8                                                       00010700
*                                                                       00010800
*        ALLOCATE AND INITIALIZE THE FCB AREA                           00010900
*                                                                       00011000
         LH    R0,NBYTES                                                00011100
         LTR   R0,R0                                                    00011200
         BM    SHIFT7         IF NEG, SHIFT COMPLEMENT BY 7             00011300
         BNZ   USEHIS2                                                  00011400
         L     R1,AFCBAREA                                              00011500
         LTR   R1,R1                                                    00011600
         BNZ   ABEND3                                                   00011700
         LA    R0,&FCBPRIM    ALLOCATE A SUITABLE AMOUNT                00011800
USEHIS2  ST    R0,BYTETEMP    SAVE # OF BYTES ALLOCATED                 00011900
         L     R1,AFCBAREA                                              00012000
         ST    R1,AREATEMP    FCB AREA ADDRESS (IF SUPPLIED)            00012100
         LTR   R1,R1                                                    00012200
         BM    ABEND3                                                   00012300
         BZ    INTRNFCB                                                 00012400
         TM    MISC+1,X'01'   IS THE AUTO-GETMAIN OPTION SET?           00012500
         BNO   EXTRNFCB                                                 00012600
         MVI   GETMFLAG,1                                               00012700
         B     EXTRNFCB                                                 00012800
INTRNFCB MVI   GETMFLAG,1     INDICATE AUTO GETMAINS ALLOWED (FOR FCBS) 00012900
         L     R2,GETMSTK1    ADDRESS OF GETMAIN ADDRESS STACK          00013000
         L     R3,GETMSTK2    ADDRESS OF GETMAIN LENGTH STACK           00013100
         LH    R4,NUMGETM                                               00013200
         SLL   R4,2                                                     00013300
         GETMAIN R,LV=(0)                                               00013400
         LTR   R15,R15                                                  00013500
         BNZ   ABEND4                                                   00013600
         ST    R1,AREATEMP    SAVE ADDRESS OF GETMAIN'D AREA            00013700
         ST    R1,0(R4,R2)    INSERT INTO GETMAIN ADDRESS STACK         00013800
         L     R0,BYTETEMP                                              00013900
         ST    R0,0(R4,R3)    INSERT INTO GETMAIN LENGTH STACK          00014000
         LH    R4,NUMGETM                                               00014100
         LA    R4,1(R4)       INCREMENT COUNT OF GETMAINS               00014200
         STH   R4,NUMGETM                                               00014300
EXTRNFCB L     R2,FCBSTK1     ADDRESS OF FCB AREA ADDRESS STACK         00014400
         L     R3,FCBSTK2     ADDRESS OF FCB AREA LENGTH STACK          00014500
         LH    R5,FCBSTKLN                                              00014600
         SLL   R5,2                                                     00014700
         L     R0,AREATEMP    GET FCB BASE ADDRESS                      00014800
         ST    R0,0(R5,R2)                                              00014900
         L     R0,BYTETEMP                                              00015000
         ST    R0,0(R5,R3)                                              00015100
         LH    R5,FCBSTKLN                                              00015200
         LA    R5,1(R5)                                                 00015300
         STH   R5,FCBSTKLN                                              00015400
         ST    R10,ACOMMTAB                                             00015500
         ST    R12,DCBADDR                                              00015600
         L     R0,APAD                                                  00015700
         ST    R0,PADADDR                                               00015800
         ST    R0,AVULN                                                 00015900
         ST    R0,ACURNTRY                                              00016000
         MVI   GOFLAG,1       INDICATE INITIALIZATION SUCCESSFUL        00016100
COMEXT   SR    R0,R0                                                    00016200
         ST    R0,APGAREA                                               00016300
         ST    R0,AFCBAREA                                              00016400
         STH   R0,NBYTES                                                00016500
         B     EXIT                                                     00016600
*                                                                       00016700
SHIFT7   LCR   R0,R0          CONVERT TO A POS VALUE                    00016800
         SLL   R0,7           MULTIPLY BY 128                           00016900
         B     USEHIS2                                                  00017000
*                                                                       00017100
TERM     EQU   *                                                        00017200
*                                                                       00017300
*        WRITE OUT ALL MODIFIED PAGES                                   00017400
*                                                                       00017500
         L     R4,ADECB       R4 = ADDRESS OF THE DECB                  00017600
         CLI   IOFLAG,0       IS THERE A WRITE IN PROGRESS?             00017700
         BE    NOCHECK                                                  00017800
         CHECK (R4)           WAIT FOR IT TO COMPLETE                   00017900
         USING PDENTRY,R6                                               00018000
NOCHECK  L     R6,PADADDR                                               00018100
         LH    R5,NUMOFPGS                                              00018200
         USING FCBCELL,R12                                              00018300
TERMLOOP L     R12,FCBADDR                                              00018400
         LTR   R12,R12       IS THIS PAGE IN USE?                       00018500
         BZ    NOWRITE                                                  00018600
         CLI   MODFIND,0      IS IT MODIFIED?                           00018700
         BE    NOWRITE                                                  00018800
         MVC   BUFLOC,APGEBUFF  SET UP DECB FOR READ                    00018900
         LH    R1,PAGENO      R1 = PAGE # * 8                           00019000
         L     R2,FCBTTRZ(R1)                                           00019100
         DROP  R12                                                      00019200
         ST    R2,TTRWORD                                               00019300
         POINT PDSFILE,TTRWORD                                          00019400
         READ  (R4),SF,MF=E                                             00019500
         CHECK (R4)                                                     00019600
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR WRITE                   00019700
         WRITE (R4),SF,MF=E                                             00019800
         CHECK (R4)                                                     00019900
NOWRITE  XC    PAGEADDR(16),PAGEADDR                                    00020000
         LA    R6,PDENTLEN(R6)                                          00020100
         BCT   R5,TERMLOOP                                              00020200
         DROP  R6                                                       00020300
*                                                                       00020400
*        FREE ALL GETMAIN'D AREAS                                       00020500
*                                                                       00020600
         LH    R5,NUMGETM                                               00020700
         LTR   R5,R5          HAVE WE DONE ANY GETMAINS?                00020800
         BZ    SKIPFREE                                                 00020900
         L     R2,GETMSTK1                                              00021000
         L     R3,GETMSTK2                                              00021100
         SR    R4,R4                                                    00021200
FREELOOP L     R0,0(R4,R3)    R0 = LENGTH                               00021300
         L     R1,0(R4,R2)    R1 = ADDRESS                              00021400
         FREEMAIN R,LV=(0),A=(1)                                        00021500
         LA    R4,4(R4)                                                 00021600
         BCT   R5,FREELOOP                                              00021700
*                                                                       00021800
*        RESET ALL OTHER GLOBAL PARAMETERS                              00021900
*                                                                       00022000
SKIPFREE XC    LOCCNT(76),LOCCNT                                        00022100
*                                                                       00022200
*        CLOSE THE HALSDF DCB                                           00022300
*                                                                       00022400
         CLOSE (PDSFILE)                                                00022500
*                                                                       00022600
*        FINISH RESET OF THE PAD                                        00022700
*                                                                       00022800
         LA    R6,PADBASE                                               00022900
         C     R6,APAD                                                  00023000
         BE    DOCLOSE                                                  00023100
         LA    R5,&PAG2                                                 00023200
         STH   R5,LPAD                                                  00023300
         ST    R6,APAD                                                  00023400
         USING PDENTRY,R6                                               00023405
CLSLOOP  XC    PAGEADDR(16),PAGEADDR                                    00023500
         LA    R6,PDENTLEN(R6)                                          00023600
         BCT   R5,CLSLOOP                                               00023700
         DROP  R6                                                       00023800
DOCLOSE  LH    R1,LPAD                                                  00023900
         STH   R1,NPAGES                                                00024000
         B     COMEXT                                                   00024100
*                                                                       00024200
AUGMENT  LH    R0,NPAGES      GET # OF PAGES TO AUGMENT                 00024300
         LTR   R0,R0                                                    00024400
         BM    ABEND2                                                   00024500
         BZ    CHKFCB                                                   00024600
         LH    R8,LPAD        R8 = MAX # OF PAGES ALLOWED               00024700
         LH    R7,NUMOFPGS    R7 = CURRENT # OF PAGES                   00024800
         AR    R7,R0          R7 = PROPOSED # OF PAGES                  00024900
         CR    R7,R8                                                    00025000
         BH    ABEND2         ENSURE THAT WE DONT EXCEED MAX            00025100
         SR    R8,R7                                                    00025200
         STH   R8,NPAGES      NUMBER OF PAGES STILL POSSIBLE            00025300
         LR    R6,R0          R6 = COUNTER                              00025400
         L     R1,APGAREA                                               00025500
         ST    R1,AREATEMP                                              00025600
         LTR   R1,R1                                                    00025700
         BNP   ABEND2                                                   00025800
*                                                                       00025900
*        INITIALIZE THE PAGING AREA DIRECTORY EXTENSION                 00026000
*                                                                       00026100
         USING PDENTRY,R8                                               00026200
         L     R8,APAD                                                  00026300
         LH    R5,NUMOFPGS    R5 = OLD # OF PAGES                       00026400
         STH   R7,NUMOFPGS    UPDATE NUMOFPGS                           00026500
         MH    R5,=AL2(PDENTLEN)                                        00026600
         AR    R8,R5          R8 POINTS TO FIRST UNUSED PDENTRY         00026700
         L     R5,AREATEMP                                              00026800
AUGLOOP  ST    R5,PAGEADDR                                              00026900
         LA    R5,1680(R5)                                              00027000
         LA    R8,PDENTLEN(R8)                                          00027100
         BCT   R6,AUGLOOP                                               00027200
         DROP  R8                                                       00027300
*                                                                       00027400
*        SEE IF FCB AREA IS TO BE AUGMENTED                             00027500
*                                                                       00027600
CHKFCB   LH    R0,NBYTES                                                00027700
         LTR   R0,R0                                                    00027800
         BM    ABEND3         NBYTES MUST BE >= 0                       00027900
         BZ    COMEXT                                                   00028000
         L     R1,AFCBAREA                                              00028100
         LTR   R1,R1                                                    00028200
         BNP   ABEND3         MUST BE > 0                               00028300
         LH    R5,FCBSTKLN    R5 = # OF FCB AREAS TO DATE               00028400
         CH    R5,MAXSTACK    SEE IF WE STILL HAVE STACK SPACE          00028500
         BE    ABEND7                                                   00028600
         SLL   R5,2                                                     00028700
         L     R6,FCBSTK1     ADDRESS OF FCB ADDRESS STACK              00028800
         L     R7,FCBSTK2     ADDRESS OF FCB LENGTH STACK               00028900
         ST    R1,0(R5,R6)                                              00029000
         ST    R0,0(R5,R7)                                              00029100
         LH    R5,FCBSTKLN                                              00029200
         LA    R5,1(R5)                                                 00029300
         STH   R5,FCBSTKLN                                              00029400
         B     COMEXT                                                   00029500
*                                                                       00029600
RESCIND  L     R4,ADECB       R4 = ADDRESS OF THE DECB                  00029700
         CLI   IOFLAG,0       IS THERE A WRITE IN PROGRESS?             00029800
         BNE   NOCHECK1                                                 00029900
         CHECK (R4)                                                     00030000
         MVI   IOFLAG,0                                                 00030100
NOCHECK1 LH    R6,NUMOFPGS                                              00030200
         SH    R6,BASNPGS                                               00030300
         BNP   ABEND5                                                   00030400
         USING PDENTRY,R8                                               00030500
         L     R8,APAD                                                  00030600
         LH    R5,BASNPGS                                               00030700
         STH   R5,NUMOFPGS                                              00030800
         MH    R5,=AL2(PDENTLEN)                                        00030900
         AR    R8,R5                                                    00031000
         USING FCBCELL,R12                                              00031100
RESCLOOP L     R12,FCBADDR                                              00031200
         LTR   R12,R12        IS THIS PAGE IN USE?                      00031300
         BZ    NOWRITE1                                                 00031400
         LH    R1,RESVCNT     IS IT RESERVED?                           00031500
         LTR   R1,R1                                                    00031600
         BP    ABEND6                                                   00031700
         LH    R1,PAGENO                                                00031800
         SR    R0,R0                                                    00031900
         ST    R0,FCBPDADR(R1)                                          00032000
         CLI   MODFIND,0      IS THE PAGE MODIFIED?                     00032100
         BE    NOWRITE1                                                 00032200
         MVC   BUFLOC,APGEBUFF  SET UP DECB FOR READ                    00032300
         L     R2,FCBTTRZ(R1)                                           00032400
         ST    R2,TTRWORD                                               00032500
         POINT PDSFILE,TTRWORD                                          00032600
         READ  (R4),SF,MF=E                                             00032700
         CHECK (R4)                                                     00032800
         MVC   BUFLOC,PAGEADDR  SET UP DECB FOR WRITE                   00032900
         WRITE (R4),SF,MF=E                                             00033000
         CHECK (R8)                                                     00033100
NOWRITE1 XC    PAGEADDR(16),PAGEADDR                                    00033200
         LA    R8,PDENTLEN(R8)                                          00033300
         BCT   R6,RESCLOOP                                              00033400
         LH    R1,LPAD        R1 = MAX # OF PAGES                       00033500
         SH    R1,BASNPGS                                               00033600
         STH   R1,NPAGES      TELL THE USER HOW MUCH IS LEFT            00033700
         B     COMEXT                                                   00033800
         DROP  R8,R12                                                   00033900
*                                                                       00034000
EXIT     EQU   *                                                        00034100
         OSRETURN                                                       00034200
*                                                                       00034300
*        ABENDS                                                         00034400
*                                                                       00034500
         USING *,R15                                                    00034600
ABEND1   LA    R1,4002        SYNAD ERROR                               00034700
         B     DOABEND                                                  00034800
         DROP  R15                                                      00034900
ABEND2   LA    R1,4013        BAD PAGING AREA SPECIFICATION             00035000
         B     DOABEND                                                  00035100
ABEND3   LA    R1,4015        BAD FCB AREA SPECIFICATION                00035200
         B     DOABEND                                                  00035300
ABEND4   LA    R1,4019        GETMAIN FAILURE IN INIT                   00035400
         B     DOABEND                                                  00035500
ABEND5   LA    R1,4012        RESCIND (NO EXTERNAL AREA ALLOCATED)      00035600
         B     DOABEND                                                  00035700
ABEND6   LA    R1,4011        RESCIND (1 OR MORE PAGES RESERVED)        00035800
         B     DOABEND                                                  00035900
ABEND7   LA    R1,4021        EXHAUSTION OF INTERNAL STACKS             00036000
         B     DOABEND                                                  00036100
*                                                                       00036200
DOABEND  ABEND (R1),DUMP                                                00036300
*                                                                       00036400
*        DCB OPEN EXIT LOGIC                                            00036500
*                                                                       00036600
         DS    0F                                                       00036700
EXITLST  DC    X'85',AL3(OUTEXIT)                                       00036800
*                                                                       00036900
         USING IHADCB,R1                                                00037000
OUTEXIT  NC    DCBBLKSI,DCBBLKSI  CHECK BLKSIZE                         00037100
         BNZ   OUTEXIT1           ALREADY SET                           00037200
         MVC   DCBBLKSI(2),DFLTBLKS                                     00037300
*                                 PROVIDE DEFAULT BLOCK SIZE            00037400
OUTEXIT1 NC    DCBLRECL,DCBLRECL  CHECK LRECL                           00037500
         BNZ   OUTEXIT2           ALREADY SET                           00037600
         MVC   DCBLRECL(2),DFLTLREC                                     00037700
*                                 PROVIDE DEFAULT LRECL                 00037800
OUTEXIT2 TM    DCBRECFM,B'11111110' CHECK RECFM                         00037900
         BCR   B'0111',14         ALREADY SET SO RETURN                 00038000
         OC    DCBRECFM(1),DFLTRECF                                     00038100
*                                 PROVIDE DEFAULT RECFM                 00038200
         BR     R14               RETURN                                00038300
         DROP   R1                                                      00038400
*                                                                       00038500
         DS     0H                                                      00038600
DFLTBLKS DC    H'1680'        BLKSIZE = 1680 BYTES                      00038700
DFLTLREC DC    H'1680'        LRECL = 1680 BYTES                        00038800
DFLTRECF DC    B'10000000'    RECFM = F                                 00038900
*                                                                       00039000
*        DATA  AREA                                                     00039100
*                                                                       00039200
         DS    0F                                                       00039300
AREATEMP DS    F                                                        00039400
BYTETEMP DS    F                                                        00039500
TTRWORD  DS    F                                                        00039600
*                                                                       00039700
*        LITERAL POOL                                                   00039800
*                                                                       00039900
         LTORG                                                          00040000
*                                                                       00040100
*        DCB FOR SDF I/O                                                00040200
*                                                                       00040300
PDSFILE  DCB   DSORG=PO,                                               X00040400
               DEVD=DA,                                                X00040500
               EXLST=EXITLST,                                          X00040600
               MACRF=(R,W),                                            X00040700
               DDNAME=HALSDF,                                          X00040800
               SYNAD=ABEND1                                             00040900
*                                                                       00041000
*        PAGING AREA DIRECTORY                                          00041100
*                                                                       00041200
         DS    0D                                                       00041300
APAD     DC    A(PADBASE)                                               00041400
LPAD     DC    H'&PAG2'                                                 00041500
         DC    H'0'                                                     00041600
PADBASE  DC    (4*&PAG2)F'0'                                            00041700
*                                                                       00041800
*        DSECTS                                                         00041900
*                                                                       00042000
         DATABUF                                                        00042100
         COMMTABL                                                       00042200
         PDENTRY                                                        00042300
         FCBCELL                                                        00042400
         PRINT NOGEN                                                    00042405
         DCBD  DSORG=(PO)                                               00042500
         END                                                            00042600
