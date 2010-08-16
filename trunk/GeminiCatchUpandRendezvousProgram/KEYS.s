*       COPYRIGHT       NONE.  THIS CODE IS IN THE PUBLIC DOMAIN.
*       FILENAME        GEMINICATCHUPANDRENDEZVOUSPROGRAM/KEYS.S.
*       PURPOSE         THIS IS PART OF THE ORIGINAL 1965 SIMULATION
*                       PROGRAM FOR THE GEMINI 7/6 MISSION
*                       CATCH-UP AND RENDEZVOUS FLIGHT PHASES.
*                       THIS PARTICULAR FILE CONTAINS THE IBM
*                       7090/7094 ASSEMBLY-LANGUAGE SUBROUTINE
*                       CALLED KEYS.
*       WEBSITE         WWW.IBIBLIO.ORG/APOLLO
*       HISTORY         2010-08-14 RSB  BEGAN TRANSCRIBING FROM
*                                       THE SCANNED PDF REPORT.
*
*       REFER TO MAIN.F FOR MORE-DETAILED INTRODUCTORY COMMENTS.
*
*       FROM PAGE 119 OF THE REPORT 
        ENTRY   KEYS
 KEYS   CLA     =043000000
        SUB*    1,4
        ARS     18
        STA     LOC1
        ENK     **
        XCL     **
 LOC1   ARS     **
        ANA     =01
        ALS     18
        STO*    2,4
        TRA     3,4
        END
