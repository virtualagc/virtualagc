*       COPYRIGHT       NONE.  THIS CODE IS IN THE PUBLIC DOMAIN.
*       FILENAME        GEMINICATCHUPANDRENDEZVOUSPROGRAM/SKIPN.S
*       PURPOSE         THIS IS PART OF THE ORIGINAL 1965 SIMULATION
*                       PROGRAM FOR THE GEMINI 7/6 MISSION
*                       CATCH-UP AND RENDEZVOUS FLIGHT PHASES.
*                       THIS PARTICULAR FILE CONTAINS THE IBM
*                       7090/7094 ASSEMBLY-LANGUAGE SUBROUTINE
*                       CALLED SKPN.
*       WEBSITE         WWW.IBIBLIO.ORG/APOLLO
*       HISTORY         2010-08-14 RSB  BEGAN TRANSCRIBING FROM
*                                       THE SCANNED PDF REPORT.
*
*       REFER TO MAIN.F FOR MORE-DETAILED INTRODUCTORY COMMENTS.
*
*       FROM PAGE 176 OF THE REPORT 
        ENTRY   SKPN
 SKPN   SXA     RTN,1
        SXA     RTN+1,2
        CLA*    1,4
        PDX     0,1
        CLA*    2,4
        PDX     0,2
        CLA     CH+2,2
        ADD*    3,4
        ARS     18
        STA     A
 A      RDS     **
        XEC     CH+4,2
        XEC     CH+6,2
        XEC     CH+8,2
        TRA     A
        TIX     A,1,1
 RTN    AXT     0,1
        AXT     0,2
        TRA     4,4
 CH     OCT     2200000000
        OCT     1200000000
        RCHB    CW1
        RCHA    CW1
        TCOB    A+2
        TCOA    A+2
        TEFB    RTN-1
        TEFA    RTN-1
 CW1    IORP    0,0,0
        IOCD    0,0,0
        END
