### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    BURN,_BABY,_BURN_--_MASTER_IGNITION_ROUTINE.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## Sundance 306

                BANK            36
                SETLOC          P40S
                BANK
                EBANK=          WHICH
                COUNT*          $$/P40
#     THE MASTER IGNITION ROUTINE IS DESIGNED FOR USE BY THE FOLLOWING LEM PROGRAMS:  P12, P40, P42, P61, P63.
# IT PERFORMS ALL FUNCTIONS IMMEDIATELY ASSOCIATED WITH APS OR DPS IGNITION:  IN PARTICULAR, EVERYTHING LYING
# BETWEEN THE PRE-IGNITION TIME CHECK -- ARE WE WITHIN 45 SECONDS OF TIG? -- AND TIG + 26 SECONDS, WHEN DPS
# PROGRAMS THROTTLE UP.

#     VARIATIONS AMONG PROGRAMS ARE ACCOMODATED BY MEANS OF TABLES CONTAINING CONSTANTS (FOR AVEGEXIT, FOR
# WAITLIST, FOR PINBALL) AND TCF INSTRUCTIONS.   USERS PLACE THE ADRES OF THE HEAD OF THE APPROPRIATE TABLE
# (OF P61TABLE FOR P61LM, FOR EXAMPLE) IN ERASABLE REGISTER 'WHICH' (E4).   THE IGNITION ROUTINE THEN INDEXES BY
# WHICH TO OBTAIN OR EXECUTE THE PROPER TABLE ENTRY.   THE IGNITION ROUTINE IS INITIATED BY A TCF BURNBABY,
# THROUGH BANKJUMP IF NECESSARY.   THERE IS NO RETURN.

#     THE MASTER IGNITION ROUTINE WAS CONCEIVED AND EXECUTED, AND (NOTA BENE) IS MAINTAINED BY ADLER AND EYLES.


#                                        HONI SOIT QUI MAL Y PENSE


#                                 ****************************************
#                                 TABLES FOR THE IGNITION ROUTINE
#                                 ****************************************

#                                             NOLI SE TANGERE

P12TABLE        VN              0674                    # (0)
                VN              0674                    # (1)
                TCF             IGNITE                  # (2)
                TCF             GOTOPOOH                # (3)
                TCF             TOOLATE                 # (4)
                TCF             P12SPOT                 # (5)
                DEC             0                       # (6)       NO ULLAGE
                EBANK=          DVCNTR
                2CADR           ATMAG                   # (7)
                TCF             DISPCHNG                # (11)
                TCF             WAITABIT                # (12)
                TCF             P12IGN                  # (13)
                TCF             TASKOVER                # (14)
                TCF             COMFAIL2                # (15)



P40TABLE        VN              0640                    # (0)
                VN              0640                    # (1)
                TCF             IGNITE                  # (2)
                TCF             GOPOST                  # (3)
                TCF             TOOLATE                 # (4)
                TCF             P40SPOT                 # (5)
                DEC             2240                    # (6)
                EBANK=          OMEGAQ
                2CADR           STEERING                # (7)
                TCF             P40SJUNK                # (11)
                TCF             WAITABIT                # (12)
                TCF             P40IGN                  # (13)
                TCF             P40ZOOM                 # (14)
                TCF             COMFAIL2                # (15)
                TCF             PUSHTIG                 # (16)



P41TABLE        TCF             P41SPOT                 # (5)
                DEC             -1                      # (6)
                EBANK=          OMEGAQ
                2CADR           CALCN85                 # (7)

                TCF             TASKOVER                # (11)
                TCF             TIGTASK                 # (12)



P42TABLE        VN              0640                    # (0)
                VN              0640                    # (1)
                TCF             IGNITE                  # (2)
                TCF             GOPOST                  # (3)
                TCF             TOOLATE                 # (4)
                TCF             P42SPOT                 # (5)
                DEC             2640                    # (6)
                EBANK=          OMEGAQ
                2CADR           STEERING                # (7)
                TCF             P40SJUNK                # (11)
                TCF             WAITABIT                # (12)
                TCF             P42IGN                  # (13)
                TCF             TASKOVER                # (14)
                TCF             COMFAIL2                # (15)



P63TABLE        VN              0662                    # (0)
                VN              0661                    # (1)
                TCF             IGNITE                  # (2)
                TCF             V99RECYC                # (3)
                TCF             TOOLATE                 # (4)
                TCF             P63SPOT                 # (5)
                DEC             2240                    # (6)
                EBANK=          WHICH
                2CADR           SERVEXIT                # (7)
                TCF             DISPCHNG                # (11)
                TCF             WAITABIT                # (12)
                TCF             P63IGN                  # (13)
                TCF             P63ZOOM                 # (14)
                TCF             COMFAIL2                # (15)


P70TABLE        VN              0675                    # (0)
                VN              0675                    # (1)
                TCF             IGNITE                  # (2)
                TCF             GOTOPOOH                # (3)
                TCF             TOOLATE                 # (4)
                TCF             P70SPOT                 # (5)
                DEC             2240                    # (6)
                EBANK=          DVCNTR
                2CADR           ATMAG                   # (7)
                TCF             DISPCHNG                # (11)
                TCF             WAITABIT                # (12)
                TCF             P70IGN                  # (13)
                TCF             P70ZOOM                 # (14)
                TCF             COMFAIL2                # (15)


P71TABLE        VN              0675                    # (0)
                VN              0675                    # (1)
                TCF             IGNITE                  # (2)
                TCF             GOTOPOOH                # (3)
                TCF             TOOLATE                 # (4)
                TCF             P71SPOT                 # (5)
                DEC             2640                    # (6)
                EBANK=          DVCNTR
                2CADR           ATMAG                   # (7)
                TCF             DISPCHNG                # (11)
                TCF             WAITABIT                # (12)
                TCF             P71IGN                  # (13)
                TCF             TASKOVER                # (14)
                TCF             COMFAIL2                # (15)



#               ****************************************
#               GENERAL PURPOSE IGNITION ROUTINES
#               ****************************************

BURNBABY        TC              PHASCHNG                # GROUP 4 RESTARTS HERE
                OCT             04024

                CAF             ZERO                    # EXTIRPATE JUNK LEFT IN DVTOTAL
                TS              DVTOTAL
                TS              DVTOTAL         +1

                TC              BANKCALL                # P40AUTO MUST BE BANKCALLED EVEN FROM ITS
                CADR            P40AUTO                 #   OWN BANK TO SET UP RETURN PROPERLY

B*RNB*B*        TC              DOWNFLAG
                ADRES           GIMBFLG

                EXTEND
                DCA             TIG                     # STORE NOMINAL TIG FOR OBLATENESS COMP.
                DXCH            GOBLTIME                # AND FOR P70 OR P71.

                TC              INTPRET
                RTB             BDSU
                                LOADTIME
                                TIG
                DSU             BPL
                                SEC45DP
                                ONTIME
                EXIT

                INDEX           WHICH
                TCF             4

TOOLATE         TC              ALARM
                OCT             1703

                CAF             V05N09
                TC              BANKCALL
                CADR            GOFLASH
                TC              GOTOPOOH
                TC              PUSHTIG
                TCF             -5

PUSHTIG         TC              INTPRET
                RTB             DAD
                                LOADTIME
                                SEC45DP
                STORE           TIG

ONTIME          DLOAD           DSU
                                TIG
                                D29.9SEC
                STORE           TDEC1
                STORE           SAVET-30
                EXIT

                INHINT
                TC              IBNKCALL
                CADR            ENGINOF3
                RELINT

                INDEX           WHICH
                TCF             5

P12SPOT         =               P40SPOT                 # (5)
P42SPOT         =               P40SPOT                 # (5)
P63SPOT         =               P41SPOT                 # (5)      IN P63 CLOKTASK ALREADY GOING
P70SPOT         =               P40SPOT                 # (5)
P71SPOT         =               P40SPOT                 # (5)
P40SPOT         CS              OCT20                   # (5)
                TC              BANKCALL                # MUST BE BANKCALLED FOR GENERALIZED
                CADR            STCLOK2                 #       RETURN
P41SPOT         TC              INTPRET                 # (5)
                CALL
                                TIGINT
                CALL
                                INITCDUW
                RTB             BDSU
                                LOADTIME
                                SAVET-30
                BMN             DSU
                                INTLATE
                                5SECDP
                BMN
                                MISSED35
                STORE           SAVET-30
                EXIT

                TC              CHECKMM
                DEC             63
                TCF             +3                      # NOT P63
                CS              CNTDNDEX                # P63 CAN START DISPLAYING NOW.
                TS              DISPDEX

CALLT-35        DXCH            MPAC
                TC              LONGCALL
                EBANK=          TTOGO
                2CADR           TIG-35
                TC              PHASCHNG
                OCT             20254                   # 4.25SPOT FOR TIG-35 RESTART.

                TCF             ENDOFJOB

MISSED35        DAD             EXIT
                                5SECDP

                DXCH            MPAC
                TC              ALSIGNAG
                XCH             L
                TS              SAVET-30
                INHINT
                TC              TWIDDLE
                ADRES           TIG-30
                TC              PHASCHNG
                OCT             47014
                -GENADR         SAVET-30
                EBANK=          TGO
                2CADR           TIG-30

                CS              BLANKDEX
                TS              DISPDEX
                TCF             ENDOFJOB

INTLATE         EXIT
                TC              ALARM
                OCT             1711
                TCF             P40ALM +2


#               ****************************************

TIG-35          CAF             5SEC
                TC              TWIDDLE
                ADRES           TIG-30

                TC              PHASCHNG
                OCT             40154                   # 4.15SPOT FOR TIG-30 RESTART

                CS              BLANKDEX                # BLANK DSKY FOR 5 SECONDS
                TS              DISPDEX

                INDEX           WHICH
                CS              6                       # CHECK ULLAGE TIME.
                EXTEND
                BZMF            TASKOVER
                CAF             4.9SEC                  # SET UP TASK TO RESTORE DISPLAY AT TIG-30
                TC              TWIDDLE
                ADRES           TIG-30.1

                CAF             PRIO17                  # A NEGATIVE ULLAGE TIME INDICATES P41, IN
                TC              NOVAC                   # WHICH CASE WE HAVE TO SET UP A JOB TO
                EBANK=          TTOGO                   # BLANK THE DSKY FOR FIVE SECONDS, SINCE
                2CADR           P41BLANK                # CLOKJOB IS NOT RUNNING DURING P41.

                TCF             TASKOVER

P41BLANK        TC              BANKCALL                # BLANK DSKY.
                CADR            CLEANDSP
                TCF             ENDOFJOB

TIG-30.1        CAF             PRIO17                  # SET UP JOB TO RESTORE DISPLAY AT TIG-30
                TC              NOVAC
                EBANK=          TTOGO
                2CADR           TIG-30A
                TCF             TASKOVER

TIG-30A         CAF             V16N85B
                TC              BANKCALL                # RESTORE DISPLAY.
                CADR            REGODSP                 # REGODSP DOES A TCF ENDOFJOB


#               *****************************************


TIG-30          CAF             S24.9SEC
                TC              TWIDDLE
                ADRES           TIG-5

                CS              CNTDNDEX                # START UP CLOKTASK AGAIN
                TS              DISPDEX

                INDEX           WHICH                   # PICK UP APPROPRIATE ULLAGE-ON TIME
                CAF             6
                EXTEND
                BZMF            ULLGNOT                 # DON'T SET UP ULLAGE IF DT IS NEG OR ZERO
                TS              SAVET-30                # SAVE DELTA-T FOR RESTART
                TC              TWIDDLE
                ADRES           ULLGTASK

                CA              THREE                   # RESTART PROTECT ULLGTASK (1.3SPOT)
                TS              L
                CS              THREE
                DXCH            -PHASE1
                CS              TIME1
                TS              TBASE1

ULLGNOT         EXTEND
                INDEX           WHICH
                DCA             7                       # LOAD AVEGEXIT WITH APPROPRIATE 2CADR
                DXCH            AVEGEXIT

                CAF             TWO                     # 4.2SPOT RESTARTS IMMEDIATELY AT REDO4.2
                TS              L
                CS              TWO                     # AND ALSO AT TIG-5 AT THE CORRECT TIME.
                DXCH            -PHASE4

                CS              TIME1
                TS              TBASE4                  # SET TBASE4 FOR TIG-5 RESTART

REDO2.17        EXTEND
                DCA             NEG0                    # CLEAR OUT GROUP 2 SO LAMBERT CAN START
                DXCH            -PHASE2                 #       IF NEEDED.

REDO4.2         CCS             PHASE5                  # IS SERVICER GOING?
                TCF             TASKOVER                # YES, DON'T START IT UP AGAIN.

                TC              POSTJUMP
                CADR            PREREAD                 # PREREAD ENDS THIS TASK


#               ****************************************


ULLGTASK        TC              ONULLAGE                # THIS COMES AT TIG-7.5 OR TIG-3.5
                TC              PHASCHNG
                OCT             1
                TCF             TASKOVER


#               ****************************************

TIG-5           CAF             5SEC
                TC              TWIDDLE
                ADRES           TIG-0

                TC              DOWNFLAG                # RESET IGNFLAG AND ASTNFLAG
                ADRES           IGNFLAG                 #   FOR LIGHT-UP LOGIC
                TC              DOWNFLAG
                ADRES           ASTNFLAG

                TC              2PHSCHNG
                OCT             40074                   # RESTART TIG-0 (4.7SPOT)
                OCT             05013                   # RESTART HERE (FOR S40.13 IF NEEDED)
                OCT             77777

                INDEX           WHICH
                TCF             11

P40SJUNK        CAF             PRIO20                  # (11)     P40 AND P42 COME HERE
                TC              FINDVAC
                EBANK=          TTOGO
                2CADR           S40.13


DISPCHNG        CS              VB99DEX                 # (11)
                TS              DISPDEX
                TCF             TASKOVER


#               ****************************************

TIG-0           CS              FLAGWRD7                # SET IGNFLAG SINCE TIG HAS ARRIVED
                MASK            IGNFLBIT
                ADS             FLAGWRD7

                TC              CHECKMM                 # IN P63 CASE, THROTTLE-UP IS ZOOMTIME
                DEC             63                      #   AFTER NOMINAL IGNITION, NOT ACTUAL
                TCF             IGNYET?
                CA              ZOOMTIME
                TC              TWIDDLE
                ADRES           ZOOM

                TC              PHASCHNG
                OCT             40033

IGNYET?         CAF             ASTNBIT                 # CHECK ASTNFLAG:  HAS ASTRONAUT RESPONDED
                MASK            FLAGWRD7                #   TO OUR ENGINE ENABLE REQUEST?
                EXTEND
                INDEX           WHICH
                BZF             12                      # BRANCH IF HE HAS NOT RESPONDED YET

IGNITION        CS              PRIO30                  # TURN ON THE ENGINE.
                EXTEND
                RAND            DSALMOUT
                AD              BIT13
                EXTEND
                WRITE           DSALMOUT
                EXTEND                                  # SET TEVENT FOR DOWNLINK
                DCA             TIME2
                DXCH            TEVENT

                EXTEND                                  # UPDATE TIG USING TGO FROM S40.13
                DCA             TGO
                DXCH            TIG
                EXTEND
                DCA             TIME2
                DAS             TIG

                INDEX           WHICH
                TCF             13

P63IGN          EXTEND                                  # (13)     INITIATE BURN DISPLAYS
                DCA             DSP2CADR
                TS              DISPDEX                 # ASSASSINATE CLOKTASK
                DXCH            AVGEXIT

                EXTEND                                  # INITIALIZE TIG FOR P70 AND P71.
                DCA             TIME2
                DXCH            TIG

                CS              FLAGWRD9                # SET FLAG FOR P70-P71
                MASK            LETABBIT
                ADS             FLAGWRD9

                CA              BRAKQADR                # INITIALIZE WCHPHASE AND FLPASSO
                TS              WCHPHASE
                CA              TWO
                TS              FLPASS0

                TCF             SETGIMBL

P70IGN          =               P40IGN                  # (13)
P40IGN          CS              FLAGWRD5                # (13)
                MASK            NOTHRBIT
                EXTEND
                BZF             SETGIMBL
                CA              ZOOMTIME                # WAITLIST FOR ZOOM (FLATOUT. ETC.)
                TC              TWIDDLE
                ADRES           ZOOM

P63IGN1         TC              2PHSCHNG
                OCT             40033                   # 3.3SPOT FOR ZOOM RESTART.
                OCT             05014                   # TYPE C   RESTARTS HERE IMMEDIATELY
                OCT             77777

SETGIMBL        CS              FLAGWRD1
                MASK            GIMBFBIT
                ADS             FLAGWRD1
                TCF             P42IGN

P12IGN          CA              ONE                     # (13)     KILL CLOKTASK
                TS              DISPDEX

P71IGN          =               P42IGN                  # (13)
P42IGN          TC              UPFLAG                  # INSURE ENGONFLG IS SET.
                ADRES           ENGONFLG
                CS              DRIFTBIT                # ENSURE THAT POWERED-FLIGHT SWITCHING
                MASK            DAPBOOLS                #   CURVES ARE USED.
                TS              DAPBOOLS
                CAF             IMPULBIT                # EXAMINE IMPULSE SWITCH
                MASK            FLAGWRD2
                CCS             A
                TCF             IMPLBURN

DVMONCON        TC              DOWNFLAG
                ADRES           IGNFLAG                 # CONNECT DVMON
                TC              DOWNFLAG
                ADRES           ASTNFLAG
                TC              DOWNFLAG
                ADRES           IDLEFLAG

                TC              PHASCHNG
                OCT             40054

                TC              FIXDELAY                # TURN ULLAGE OFF HALF A SECOND AFTER
                DEC             50                      # LIGHT UP.

ULLAGOFF        TC              NOULLAGE

WAITABIT        EXTEND                                  # KILL GROUP 4
                DCA             NEG0
                DXCH            -PHASE4

                TCF             TASKOVER


#               ****************************************

TIGTASK         CAF             PRIO16                  # TIGNOW MUST BE A JOB.
                TC              NOVAC
                EBANK=          TRKMKCNT
                2CADR           TIGNOW
                TC              PHASCHNG
                OCT             6                       # KILL GROUP 6.

                TCF             TASKOVER


#               ****************************************

ZOOM            INDEX           WHICH
                TCF             14

P63ZOOM         EXTEND                                  # (4)   SET UP GUIDANCE.
                DCA             LUNLANAD
                DXCH            AVEGEXIT

                TC              DOWNFLAG
                ADRES           KILLROSE

                CAF             THIRTEEN
                TC              WAITLIST
                EBANK=          WHICH
                2CADR           ROSEN

P70ZOOM         =               P40ZOOM                 # (4)
P40ZOOM         TC              IBNKCALL                # (4) THROTTLE THE DPS TO MAXIMUM THRUST.
                CADR            FLATOUT

                TC              PHASCHNG
                OCT             3
                TCF             TASKOVER


#               ****************************************

COMFAIL         INDEX           WHICH
                TCF             15

COMFAIL2        TC              PHASCHNG                # KILL ZOOM RESTART PROTECTION
                OCT             00003

                INHINT
                TC              KILLTASK                # KILL ZOOM, IN CASE IT'S STILL TO COME
                CADR            ZOOM
                TC              IBNKCALL                # COMMAND ENGINE OFF
                CADR            ENGINOF1
                TC              ONULLAGE
                CAF             FOUR                    # RESET DVMON
                TS              DVCNTR
                CS              OCT24
                TS              TIG
                CAF             BIT1
                TC              TWIDDLE
                ADRES           TIG-5

                TC              2PHSCHNG
                OCT             00174
                OCT             10035

                EXTEND
                DCA             AVEGEXIT
                DTCB


#               ****************************************
#               SUBROUTINES OF THE IGNITION ROUTINE
#               ****************************************

INVFLAG         CA              Q
                TC              DEBIT
                COM
                EXTEND
                RXOR            LCHAN
                TCF             COMFLAG


#               ****************************************

NOULLAGE        CS              ULLAGER                 # MUST BE CALLED IN A TASK OR UNDER INHINT
                MASK            DAPBOOLS
                TS              DAPBOOLS
                TC              Q


#               ****************************************

ONULLAGE        CS              DAPBOOLS                # TURN ON ULLAGE.  MUST BE CALLED IN
                MASK            ULLAGER                 # A TASK OR WHILE INHINTED.
                ADS             DAPBOOLS
                TC              Q


#               ****************************************


STCLOK1         CA              ZERO                    # THIS ROUTINE STARTS THE COUNT-DOWN
STCLOK2         TS              DISPDEX                 #   (CLOKTASK AND CLOKJOB).   SETTING
STCLOK3         TC              MAKECADR                # SETTING DISPDEX POSITIVE KILLS IT.
                TS              TBASE4                  # RETURN SAVE (NOT FOR RESTARTS)
                EXTEND
                DCA             TIG
                DXCH            MPAC
                EXTEND
                DCS             TIME2
                DAS             MPAC                    # HAVE TIG - TIME2, UNDOUBTEDLY A + NUMBER
                TC              TPAGREE                 # POSITIVE, SINCE WE PASSED THE
                CAF             1SEC                    #   45 SECOND CHECK
                TS              Q
                DXCH            MPAC
                MASK            LOW5                    # RESTRICT MAGNITUDE OF NUMBER IN A
                EXTEND
                DV              Q
                CA              L                       # GET REMAINDER
                AD              TWO
                INHINT
                TC              TWIDDLE
                ADRES           CLOKTASK
                TC              2PHSCHNG
                OCT             40036                   # 6.3SPOT FOR CLOKTASK
                OCT             05024
                OCT             13000

                CA              TBASE4
                TC              BANKJUMP


CLOKTASK        CS              TIME1                   # SET TBASE6 FOR GROUP 6 RESTART
                TS              TBASE6

                CCS             DISPDEX
                TCF             KILLCLOK
                NOOP
                CAF             PRIO27
                TC              NOVAC
                EBANK=          TTOGO
                2CADR           CLOKJOB


                TC              FIXDELAY                # WAIT A SECOND BEFORE STARTING OVER
                DEC             100
                TCF             CLOKTASK

KILLCLOK        EXTEND                                  # KILL RESTART

                DCA             NEG0
                DXCH            -PHASE6
                TCF             TASKOVER


CLOKJOB         EXTEND
                DCS             TIG
                DXCH            TTOGO
                EXTEND
                DCA             TIME2
                DAS             TTOGO
                INHINT
                CCS             DISPDEX                 # IF DISPDEX HAS BEEN SET POSITIVE BY A
                TCF             ENDOFJOB                # TASK OR A HIGHER PRIORITY JOB SINCE THE
                TCF             ENDOFJOB                # LAST CLOKTASK, AVOID USING IT AS AN
                COM                                     # INDEX.
                RELINT                                  # *****  DISPDEX MUST NEVER BE -0  *****
                INDEX           A
                TCF             DISPNOT         -1      # (-1 DUE TO EFFECT OF CCS)

                                                        # THIS DISPLAY IS CALLED VIA ASTNCLOK.
 -27            INDEX           WHICH                   # IT IS PRIMARILY USED BY THE ASTRONAUT
                CAF             1                       # TO RESET HIS EVENT TIMER TO AGREE WITH
                TC              BANKCALL                # TIG.
                CADR            REFLASH
                TCF             GOTOPOOH
                TCF             ASTNRETN
                TCF             -6

CNTDNDEX        =               OCT20                   # NEGATIVE OF THIS IS PROPER FOR DISPDEX

 -20            INDEX           WHICH                   # THIS DISPLAY COMES UP AT ONE SECOND
                CAF             0                       # INTERVALS.  IT IS NORMALLY OPERATED
                TC              BANKCALL                # BETWEEN TIG-30 SECONDS AND TIG-5 SECONDS
                CADR            REGODSP                 # REGODSP DOES ITS OWN TCF ENDOFJOB

VB99DEX         =               OCT14                   # NEGATIVE OF THIS IS PROPER FOR DISPDEX


V99RECYC        EQUALS

 -14            INDEX           WHICH                   # THIS IS THE "PLEASE ENABLE ENGINE"
                CAF             0                       # DISPLAY; IT IS INITIATED AT TIG-5 SEC.
                TC              BANKCALL                # THE DISPLAY IS A V99NXX, WHERE XX IS THE
                CADR            GOFLASHR                # NOUN THAT HAD PREVIOUSLY BEEN DISPLAYED
                TCF             STOPCLOK                # TERMINATE  GOTOPOOH TURNS OFF ULLAGE.
                TCF             *PROCEED
                TCF             *ENTER
                CAF             VB99CON
                TC              LINUS
                TCF             ENDOFJOB

BLANKDEX        =               TWO                     # NEGATIVE OF THIS IS PROPER FOR DISPDEX

 -2             TC              BANKCALL                # BLANK DSKY.  THE DSKY IS BLANKED FOR
                CADR            CLEANDSP                # 5 SECONDS AT TIG-35 TO INDICATE THAT
DISPNOT         TCF             ENDOFJOB                # AVERAGE G IS STARTING.


STOPCLOK        TC              NULLCLOK                # STOP CLOKTASK & TURN OFF ULLAGE ON THE
                TCF             GOTOPOOH                #     WAY TO P00  (GOTOPOOH RELINTS)

ASTNRETN        CAF             PRIO13
                INHINT
                TC              FINDVAC
                EBANK=          TTOGO
                2CADR           GOBACK
                TCF             ENDOFJOB


*PROCEED        TC              UPFLAG
                ADRES           ASTNFLAG
                INDEX           WHICH
                TCF             2


*ENTER          INDEX           WHICH
                TCF             3


GOPOST          CAF             PRIO12                  # (3)  MUST BE LOWER PRIORITY THAN CLOKJOB
                TC              FINDVAC
                EBANK=          TTOGO
                2CADR           POSTBURN
                TC              NULLCLOK
                TC              PHASCHNG                # 4.13 RESTART FOR POSTBURN
                OCT             00134

                TCF             ENDOFJOB


IGNITE          CS              FLAGWRD7                # (2)
                MASK            IGNFLBIT
                CCS             A
                TCF             IGNITE1
                CAF             BIT1
                INHINT

                TC              TWIDDLE
                ADRES           IGNITION

                TC              PHASCHNG                # IMMEDIATE RESTART AT IGNITION.
                OCT             00234

IGNITE1         CS              CNTDNDEX                # RESTORE OLD DISPLAY.
                TS              DISPDEX

                TCF             ENDOFJOB

NULLCLOK        INHINT
                EXTEND
                QXCH            P40/RET
                TC              NOULLAGE                # TURN OFF ULLAGE ...
                TC              KILLTASK                #    DON'T LET IT COME ON, EITHER ...
                CADR            ULLGTASK
                TC              PHASCHNG                #          NOT EVEN IF THERE'S A RESTART.
                OCT             1
                CA              Z                       # KILL CLOKTASK
                TS              DISPDEX
                TC              P40/RET

GOASTCLK        TC              MAKECADR
                TS              TEMPR60
                CAF             ZERO
                TS              DVTOTAL
                TS              DVTOTAL +1
ASTNCLOK        CS              ASTNDEX
                TC              BANKCALL
                CADR            STCLOK2
                TCF             ENDOFJOB                # RETURN IN NEW JOB AND IN EBANK FIVE


#               ****************************************

P40AUTO         TC              MAKECADR                # HELLO THERE.
                TS              TEMPR60                 # FOR GENERALIZED RETURN TO OTHER BANKS.
P40A/P          TC              BANKCALL                # SUBROUTINE TO CHECK PGNCS CONTROL
                CADR            G+N,AUTO                # AND AUTO STABILIZATION MODES
                CCS             A                       # +0  INDICATES IN PGNCS, IN AUTO
                TCF             TURNITON                # + INDICATES NOT IN PGNCS AND/OR AUTO
                CAF             APSFLBIT                # ARE WE ON THE DESCENT STAGE?
                MASK            FLAGWRD1
                CCS             A
                TCF             GOBACK                  # RETURN
                CAF             BIT5                    # YES, CHECK FOR AUTOTHROTTLE MODE
                EXTEND
                RAND            CHAN30
                EXTEND
                BZF             GOBACK                  # IN AUTOTHROTTLE MODE -- RETURN
TURNITON        CAF             P40A/PMD                # DISPLAY V50N25 R1=203 PLEASE PERFORM
                TC              BANKCALL                # CHECKLIST 203 TURN ON PGNCS ETC.
                CADR            GOPERF1
                TCF             GOTOPOOH                # V34E  TERMINATE
                TCF             P40A/P                  # RECYCLE
GOBACK          CAF             ZERO
                TS              DISPDEX
                CA              TEMPR60
                TC              BANKJUMP                # GOODBYE.  COME AGAIN SOON.


                BANK            36
                SETLOC          P40S

                BANK

                COUNT*          $$/P40

#               ****************************************
#               CONSTANTS FOR THE IGNITION ROUTINE
#               ****************************************

SERVCADR        =               P63TABLE        +7

P40ADRES        ADRES           P40TABLE

P41ADRES        ADRES           P41TABLE        -5

P42ADRES        ADRES           P42TABLE

                EBANK=          WCHPHASE
DSP2CADR        2CADR           DISPEXIT


                EBANK=          WCHPHASE
LUNLANAD        2CADR           LUNLAND

?               =               GOTOPOOH

BRAKQADR        REMADR          BRAKQUAD

D29.9SEC        2DEC            2990


S24.9SEC        DEC             2490

4.9SEC          DEC             490

ASTNDEX         OCT             00027                   # INDEX FOR CLOKTASK

OCT20           =               BIT5

VB99CON         OCT             24020                   # BITS 5, 12, AND 14

OCT1505         OCT             1505

## Sundance 292

#          KILLTASK
# MOD NO: NEW PROGRAM
# MOD BY: COVELLI


# FUNCTIONAL DESCRIPTION:

#    KILLTASK IS USED TO REMOVE A TASK FROM THE WAITLIST BY SUBSTITUTING ANULL TASK CALLED 'NULLTASK' (OF COURSE),
# WHICH MERELY DOES A TC TASKOVER. IF THE SAME TASK IS SCHEDULED MORE THAN ONCE, ONLY THE ONE WHICH WILL OCCUR
# FIRST IS REMOVED. IF THE TASK IS NOT SCHEDULED, KILLTASK TAKES NO ACTION AND RETURNS WITH NO ALARM. KILLTASK
# MUST BE CALLED IN INTERRUPT OR WITH INTERRUPT INHIBITED.

# CALLING SEQUENCE:
#                                         L-1     (INHINT)
#                                         L        TC     KILLTASK       IN FIXED-FIXED
#                                         L+1      CADR   ????????       CADR (NOT 2CADR) OF TASK TO BE REMOVED.
#                                         L+2      (RELINT)              RETURN

# EXIT MODE:  AT L+2 OF CALLING SEQUENCE.

# ERASABLE INITIALIZATION=  NONE.

# OUTPUT:  2CADR OF NULLTASK IN LST2

# DEBRIS:  ITEMP1 - ITEMP4, A,L,Q.

                EBANK=          LST2
                BLOCK           3                       # KILLTASK MUST BE IN FIXED-FIXED.
                SETLOC          FFTAG6
                BANK
                COUNT*          $$/KILL
KILLTASK        CA              KILLBB
                LXCH            A
                INDEX           Q
                CA              0                       # GET CADR.
                LXCH            BBANK
                TCF             KILLTSK2                # CONTINUE IN SWITCHED FIXED

                EBANK=          LST2
KILLBB          BBCON           KILLTSK2

## Sundance 302


                BANK            27

                SETLOC          P40S1
                BANK
                COUNT*          $$/KILL

KILLTSK2        LXCH            ITEMP2                  # SAVE CALLER'S BBANK

                INCR            Q
                EXTEND
                QXCH            ITEMP1                  # RETURN 2CADR IN ITEMP1,ITEMP2

                TS              ITEMP3                  # CADR IS IN A
                MASK            LOW10
                AD              BIT11
                TS              ITEMP4                  # GENADR OF TASK

                CS              LOW10
                MASK            ITEMP3
                TS              ITEMP3                  # FBANK OF TASK

                ZL
ADRSCAN         INDEX           L
                CS              LST2
                AD              ITEMP4                  # COMPARE GENADRS
                EXTEND
                BZF             TSTFBANK                # IF THEY MATCH, COMPARE FBANKS
LETITLIV        CS              LSTLIM
                AD              L
                EXTEND                                  # ARE WE DONE?
                BZF             DEAD                    # YES - DONE, SO RETURN
                INCR            L
                INCR            L
                TCF             ADRSCAN                 # CONTINUE LOOP.

DEAD            DXCH            ITEMP1
                DTCB

TSTFBANK        CS              LOW10
                INDEX           L
                MASK            LST2            +1      # COMPARE FBANKS ONLY.
                EXTEND
                SU              ITEMP3
                EXTEND
                BZF             KILLDEAD                # MATCH - KILL IT.
                TCF             LETITLIV                # NO MATCH - CONTINUE.

KILLDEAD        CA              TCTSKOVR
                INDEX           L
                TS              LST2                    # REMOVE TASK BY INSERTING TASKOVER
                TCF             DEAD

LSTLIM          EQUALS          BIT5                    # DEC 16
