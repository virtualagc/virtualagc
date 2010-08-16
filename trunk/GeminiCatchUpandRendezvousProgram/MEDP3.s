*       COPYRIGHT       NONE.  THIS CODE IS IN THE PUBLIC DOMAIN.
*       FILENAME        GEMINICATCHUPANDRENDEZVOUSPROGRAM/MEDP3.S
*       PURPOSE         THIS IS PART OF THE ORIGINAL 1965 SIMULATION
*                       PROGRAM FOR THE GEMINI 7/6 MISSION
*                       CATCH-UP AND RENDEZVOUS FLIGHT PHASES.
*                       THIS PARTICULAR FILE CONTAINS THE IBM
*                       7090/7094 ASSEMBLY-LANGUAGE SUBROUTINE
*                       CALLED MEDP3 (MODIFIED EULER INTEGRATION
*                       SUBROUTINE), BY ECKSTROM OF IBM OWEGO.
*       WEBSITE         WWW.IBIBLIO.ORG/APOLLO
*       HISTORY         2010-08-14 RSB  BEGAN TRANSCRIBING FROM
*                                       THE SCANNED PDF REPORT.
*
*       REFER TO MAIN.F FOR MORE-DETAILED INTRODUCTORY COMMENTS.
*
*       FROM PAGE 155 OF THE REPORT 
        ENTRY   MAR
        ENTRY   DEV
        ENTRY   PRT
 MAR    STZ     COUNT
        CLA*    2,4
        STO     DT
        CLA*    1,4
        ARS     18
        STO     N
        CLA     3,4
        ADD     N
        STA     X1
        STA     X2
        STA     X3
        STA     X4
        STA X5
        STA X6
        ADD     N
        STA     XD1
        STA     XD2
        STA     XD3
        ADD     N
        STA     XP1
        STA     XP2
        ADD     N
        STA     XDP1
        STA     XDP2
        ADD N
        STA XL1
        STA XL2
        STA XL3
        SXA *+4,1
        LXA N,1
 XL3    STZ *,1
        TIX *-1,1,1
        AXT *,1
        SXA     S4,4
        CLA     D1
        STO*    6,4
        STZ     IND
        TRA     7,4
 DEV    SXA     EXIT,1
  S4    AXT     *,4
        LXA     N,1
        ZET     IND
        TRA     XDP2            =I
 X1     CLS     *,1             = O, V+N
*
*       FROM PAGE 156 OF THE REPORT 
 XP1    STO     *,1                  V+3N
 XD1    CLA     *,1                 V+2N
 XDP1   STO     *,1                 V+4N
 XD3    LDQ     *,1                 V+2N
        FMP     DT
 X2     FAD     *,1             V+N
 X3     STO     *,1             V+N
        TIX     X1,1,1
        CLA     D1
        STO     IND
        LXA     EXIT,1
        TRA     LD
 XDP2   CLA     *,1             V+4N
 XD2    FAD     *,1             V+2N
        FDP     TWO
        FMP     DT
 XP2    FAD     *,1             V+3N
 X4     STO     *,1             V+N
        STQ TEMP
        CLA TEMP
 XL1    FAD *,1
 X5     FAD *,1
 X6     STO *,1
 XL2    STQ *,1
        TIX     XDP2,1,1
        STZ     IND
 EXIT   AXT     *,1
        CLA     COUNT
        ADD     D1
        STO     COUNT
        SUB*    5,4
        TZE     *+5
        TPL     *+4
 LD     CLA     D1
        STO*    6,4
        TRA     7,4
        CLA     D2
        TRA     *-3
 PRT    STZ     COUNT
        LXA     S4,4
        CLA*    2,4
        STO     DT
        TRA     LD
 DT     PZE
 N      PZE
 D1     PZE     ,,1
 D2     PZE     ,,2
 COUNT  PZE
 TWO    DEC     2.
 TEMP   PZE
        END
