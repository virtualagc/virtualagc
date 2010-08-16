*       COPYRIGHT       NONE.  THIS CODE IS IN THE PUBLIC DOMAIN.
*       FILENAME        GEMINICATCHUPANDRENDEZVOUSPROGRAM/TCTRL.S
*       PURPOSE         THIS IS PART OF THE ORIGINAL 1965 SIMULATION
*                       PROGRAM FOR THE GEMINI 7/6 MISSION
*                       CATCH-UP AND RENDEZVOUS FLIGHT PHASES.
*                       THIS PARTICULAR FILE CONTAINS THE IBM
*                       7090/7094 ASSEMBLY-LANGUAGE SUBROUTINE
*                       CALLED TCTRL (REAL TIME INTERRUPT SIMULATION,
*                       CH B COMMAND TRAP), BY CONSTABLE.
*       WEBSITE         WWW.IBIBLIO.ORG/APOLLO
*       HISTORY         2010-08-14 RSB  BEGAN TRANSCRIBING FROM
*                                       THE SCANNED PDF REPORT.
*
*       REFER TO MAIN.F FOR MORE-DETAILED INTRODUCTORY COMMENTS.
*
*       FROM PAGE 158 OF THE REPORT 
        ENTRY   CTRL1
(TES)
GEXEC
 CTRLI  SXA     IXB4,4
        SXA     IXB2,2
        SXA     IXB4,1
        XEC*    $(TES)
        XCA                     T SCALED +35
        ANA     =077777
        ALS     18              MS DESIRED SCALED +17
        SUB     =7.3B+17
        TPL     *+3
        CLA     =01000000
        TRA     *+7
        XCA
        MPY     =10.B+4         NO. OF WORDS SCALED +21
        ALS     4               NO. OF WORDS SCALED +17
        CAS     =0077777000000
        CLA     =0077777000000
        NOP
        STD     CW1             SET UP IOCT COMMAND
        WTBB    6
        RCHB    CW1
        ENB     =02
        ZET     INIT
        TRA     *+2
        TRA     *+9
        AXT     206,1
        CLA     SAVE1,1
        STO     0,1
        TIX     *-2,1,1
        AXT     101,1
        CLA     SAVE2,1
        STO     101,1
        TIX     *-2,1,1
        CLA     LOCA
        STO     13
        ZET     DIND
        TRA     *+2
        TRA     *+3
        CLA     =077
        DVP     =01
        ZET     OFIND
*
*       FROM PAGE 159 OF THE REPORT 
        TRA     *+8
        CLA     SJ2
        LDQ     SJ3
        LLS     2
        LDQ     SJ1
        ZET     OFIND
        TRA     *+5
        TOV     *+4
        CLA     =0200000000000
        LLS     1
        TRA     *-9
 IXA4   AXT     0,4
 IXA2   AXT     0,2
 IXA1   AXT     0,1
 CENT   TTR     $GEXEC
 TENT   SXA     IXA4,4
        SXA     IXA2,2
        SXA     IXA1,1
        TRCB    *+1
        ENB     =0
        STZ     DIND
        STZ     OFIND
        STQ     SJ1
        LRS     2
        STO     SJ2
        STQ     SJ3
        TNO     *+3
        CLA     =077777
        STO     OFIND
        DCT
        TRA     *+2
        TRA     *+3
        CLA     =077777
        STO     DIND
        CLA     12
        STA     CENT
        AXT     206,1
        CLA     0,1
        STO     SAVE1,1
        TIX     *-2,1,1
        AXT     101,1
        CLA     101,1
        STO     SAVE2,1
        TIX     *-2,1,1
        CLA     =077777
        STO     INIT
 IXB4   AXT     0,4
 IXB2   AXT     0,2
 IXB1   AXT     0,1
        ETTB
        TRA     *+2
        TRA     1,4
*
*       FROM PAGE 160 OF THE REPORT 
        REWB    6
        TCOB    *
        WTBB    6
        RCHB    CW2
        TCOB    *
        TRA     1,4
 CW1    IOCT    16384,0,0
 CW2    IOCD    16384,0,10
 LOCA   TTR     TENT
 SJ1    PZE     0
 SJ2    PZE     0
 SJ3    PZE     0
 OFIND  PZE     0
 DIND   PZE     0
 INIT   PZE     0
 SAVE1  BES     206
 SAVE2  BES     101
        END
