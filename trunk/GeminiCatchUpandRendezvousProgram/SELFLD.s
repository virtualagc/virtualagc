*       COPYRIGHT       NONE.  THIS CODE IS IN THE PUBLIC DOMAIN.
*       FILENAME        GEMINICATCHUPANDRENDEZVOUSPROGRAM/SELFLD.S
*       PURPOSE         THIS IS PART OF THE ORIGINAL 1965 SIMULATION
*                       PROGRAM FOR THE GEMINI 7/6 MISSION
*                       CATCH-UP AND RENDEZVOUS FLIGHT PHASES.
*                       THIS PARTICULAR FILE CONTAINS THE IBM
*                       7090/7094 ASSEMBLY-LANGUAGE SUBROUTINE
*                       CALLED SELFLD (ROUTINE TO GENERATE A
*                       SELF-LOADING TAPE ON A7).
*       WEBSITE         WWW.IBIBLIO.ORG/APOLLO
*       HISTORY         2010-08-14 RSB  BEGAN TRANSCRIBING FROM
*                                       THE SCANNED PDF REPORT.
*
*       REFER TO MAIN.F FOR MORE-DETAILED INTRODUCTORY COMMENTS.
*
*       FROM PAGE 143 OF THE REPORT 
        ENTRY   SELFLD
 SELFLD SXA     XR1,1           SAVE INDEX REGISTERS FOR RETURN TO
        SXA     XR2,2           CALLING PROGRAM
        SXA     XR4,4
        CLA     SLN1            SAVE STATUS OF SENSE LIGHT ONE
        SLT     1
        CLA     NOP
        STO     SLN1P
        CLA     SLN             SAVE STATUS OF SENSE LIGHT 1
        SLT     4
        CLA     NOP
        STO     SLNNOP
 WRITAG AXT     5,1
 WRITE  REWA    7
        SDHA    7
        WTBA    7
        RCHA    WTBIOC
        TCOA    *
        TRCA    TRCHK           WRITE TAPE REDUNDANCY CHECK ERROR ROUTINE
        WEFA    7
        RUNA    7
        TSX     CPY90,4         PRINT ON-LINE
        HTR     PROP,2,-9       TAPE HAS BEEN PROPERLY WRITTEN
        TRA     SLNNOP          RETURN TO CALLING PROGRAM
 SLNNOP NOP                     RESTORE SENSE LIGHT FOUR
 SLN1P  NOP                     RESTORE SENSE LIGHT ONE
 XR1    AXT     **,1
 XR2    AXT     **,2
 XR4    AXT     **,4
        TRA     1,4
 LOADER IOCD    3,,-3
        TCOA    1
        TCOB    2
        TRA     LOADR1
 LOADR1 SWT     3               MONITOR - OR - NON MONITOR
        TRA     *+3             NON MONITOR
        TRCB    TCHECK          MONITOR   CHANNEL B CHECK
        TRA     ON
        TRCA    TCHECK                    CHANNEL A CHECK
        TRA     ON
 ON     TSX     REWIND,4        REWIND B7 OR A1
        TRA     SLNNOP          RETURN TO CALLING PROGRAM
 TRCHK  TIX     WRITE,1,1       WRITE TAPE REDUNDANCY CHECK ERROR ROUTINE
        TSX     CPY90,4         PRINT ON-LINE
        HTR     TRCHK1,,-9      5 ATTEMPTS TO WRITE A7 HAVE FAILED
        TSX     CPY90,4
        HTR     TRCHK2,,-9      MOUNT ANOTHER TAPE - HIT START  OR
*
*       FROM PAGE 144 OF THE REPORT 
        TSX     CPY90,4
        HTR     TRCHK3,2,-9     DEPRESS MQ 6 TO OMIT AND CONTINUE
        HPR
        ENK
        XCA
        ANA     MASK6
        TNZ     SLNNOP          RETURN TO CALLING PROGRAM
        TRA     WRITAG          TRY AGAIN
 TCHECK SLT     1               TEST FIRST TRY INDICATOR
        TRA     *+2
        TRA     TPERRS
        TSX     REWIND,4
        SLN     1               TURN ON FIRST TRY INDICATOR
 RELOAD SWT     3
        TRA     TAPEA1
        RTBB    7               LOAD FROM B7  - MONITOR
        RTCHB   LTBIOC
        LCHB    LOADER
        TRA     1
 TAPEA1 RTBA    1               LOAD FROM A1  - MONITOR
        RCHA    LTBIOC
        LCHA    LOADER
        TRA     1
 TPERRS TSX     REWIND,4        REWIND B7 OR A1
        TSX     CPY90,4         PRINT ON-LINE
        HTR     ONBAD,,-9       TAPE LOADING REDUNDANCY ERROR
        SWT     3
        TRA     TPERR6
        TSX     CPY90,4
        HTR     DNBAD1,,-9      TO RETRY HIT START  - TO ACCEPT  PUT MQ 6
        TSX     CPY90,4
        HTR     ONBAD2,2,-9     DOWN - HIT START
        HPR
        ENK
        XCA
        ANA     MASK6
        TNZ     SLNNOP          RETURN TO CALLING PROGRAM
        TRA     RELOAD          TRY AGAIN
 TPERR6 TSX     CPY90,4
        HTR     ONBAD3,,-9      TO ACCEPT HIT START OR CLEAR AND LOAD TAPE
        HTR     SLNNOP          RETURN TO CALLING PROGRAM
 REWIND SWT     3               REWIND B7 OR A1 SUBROUTINE
        TRA     *+3
        REWB    7
        TRA     *+2
        REWA    1
        TRA     1,4
 SLN1   SLN     1
 SLN    SLN     4
 NOP    NOP
 WTBIOC IOCP    LOADER,,4
        IOCD    4,,-4
*
*       FROM PAGE 145 OF THE REPORT 
 LTBIOC IOCT    0,,3
 TRCHK1 BCI     9,5 ATTEMPTS TO WRITE A7 HAVE FAILED
 TRCHK2 BCI     9,MOUNT ANOTHER TAPE - HIT START OR
 TRCHK3 BCI     9,DEPRESS MQ 6 TO OMIT AND CONTINUE
 ONBAD  BCI     9,TAPE LOADING REDUNDANCY ERROR
 ONBAD1 BCI     9,TO RETRY HIT START - TO ACCEPT PUT MQ 6
 ONBAD2 BCI     9,DOWN - HIT START
*
*       FROM PAGE 146 OF THE REPORT 
 ONBAD3 BCI     9,TO ACCEPT HIT START OR CLEAR AND LOAD TAPE
 PROP   BCI     9,TAPE A7 HAS BEEN PROPERLY WRITTEN
 MASK6  OCT     004000000000
*
*       FROM PAGE 147 OF THE REPORT 
*               SUBROUTINE CPY90, TO PRINT ON LINE
*
*               TSX CPY90,4
*               HTR A,,-X            A=LOCA. 1ST WORD
*               (RETURN)             X= NO. OF WORDS
*
*TO RESTORE THE PRINTER AFTER A LINE OF PRINT PUT A 2 IN TAG OF TSX+1.
*
 CPY90  SXD     OP2A,1
        SXD     OP4A,2
        SXD     OP6C,4
        CLA     1,4
        STA     BEGIN3
        STT     DP14
        PDX     ,2
        TXH     BEGIN4,2,-13
        TXI     *+1,2,12
        SXD     OV72,2
        LAC     BEGIN5,2
 BEGIN4 SXD     BEGIN2,2
 BEGIN5 AXT     12,1
        STZ     OP50+12,1
        STZ     OP50+27,1
        TIX     *-2,1,1
        STZ     BLKTST
        AXT     36,1
        AXC     1,2
        SXD     OP3A,2
        TXI     BEGIN3,2,1
 BEGIN1 LXD     OP3A,2
 BEGIN2 TXL     OP16,2,0
        TXI     *+1,2,-1
        SXD     OP3A,2
        TXI     *+1,2,1
 BEGIN3 LDQ     0,2
        AXT     OP1B,4
 OP0    SXD     OP1B,4
        AXT     0,2
        AXT     0,4
        CAL     BT4
        ARS     36,1
        SLW     VARONE
        SXD     OP2B,1
        LXD     BLKTST,1
        PXD     ,0
        LGL     3
        CAS     SIXC
        TXI     OP3,4,-2                IN 70S
        TXI     OP1,4,-2                IN 60S
        CAS     FOURC
        TXI     OP3,4,-1                IN 50S
        TXI     OP6,4,-1                IN 40S
*
*       FROM PAGE 148 OF THE REPORT 
        CAS     TWOC
 OP2A   TXL     OP3                     IN 30S
 OP2B   TXL     OP6                     IN 20S
        TXI     *+1,4,1
        TZE     DP7                     IN1S
 OP3    PXD     ,0
        LGL     3
        PAC     ,2
        CAS     ONEC
        TRA     *+3
 OP3A   TXL     OP5                     70
        TXL     OP5                     71
        CAL     VARONE                  72,73,74
        ORS     OP50+10,1
 OP4    ORS*    OP30,1
        ORS*    OP40,1
 OP4A   TXL     OP1A
 OP5    CAL     VARONE
        TXI     OP4,2,-8
 OP6    PXD     ,0
        LGL     3
        TNZ     OP2
 OP6A   CAL     VARONE
 OP6B   ORS*    OP40,1
 OP6C   TXL     OP1A
 OP1    PXD     ,0
        LGL     3
        TNZ     OP2
 OP1A   LXD     OP2B,1
        TXI     *+1,1,-1
        LXD     OP1B,4
        TIX     OP0,4,1
        TXH     BEGIN1,1,1
        ZET     BLKTST
 OP1B   TXL     OP16
        AXC     15,1
        SXD     BLKTST,1
        TXI     BEGIN1,1,51
 OP2    PAC     ,2
        CAL     VARONE
        TXL     OP4
 OP7    PXD     ,0
        LGL     3
        TNZ     OP2
        TXI     OP6A,4,-3
 OP16   AXT     0,4
        AXT     24,2
 OP17   CLA     OP50+11,4
        STO     CPYBLK+24,2
        CLA     OP50+26,4
*
*       FROM PAGE 149 OF THE REPORT 
        STO     CPYBLK+25,2
        TNX     OP18,2,2
        TXI     OP17,4,1
 OP18   TCOA    *
        WPDA
        NZT     OV72A
        TRA     *+3
        STZ     OV72A
        SPRA    9
        RCHA    OP20
        TCOA    *
        NZT     OV72
 OP14   TRA     OP13,**
        LXD     OV72,2
        SXD     OV72A,2
        LXA     BEGIN3,1
        TXI     *+1,1,12
        SXA     BEGIN3,1
        STZ     OV72
        TRA     BEGIN4
        WPDA
        SPRA    1
 OP13   LXD     OP2A,1
        LXD     OP4A,2
        LXD     OP6C,4
        TCOA    *
        TRA     2,4
 OP20   IOCD    CPYBLK,,24
 BLKTST HTR     0
 VARONE HTR     0
 BT4    OCT     400000000000
 ONEC   DEC     1
 TWOC   DEC     2
 FOURC  DEC     4
 SIXC   DEC     6
 OV72   HTR     0
 OV72A  HTR     0
 OP30   HTR     OP50+2,2
 OP40   HTR     OP50,4
        HTR     0
 OP50   BSS     12
        HTR     OP50+17,2
        HTR     OP50+15,4
        HTR     0
        BSS     12
 CPYBLK BSS     24
        END
