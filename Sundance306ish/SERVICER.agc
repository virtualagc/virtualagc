### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SERVICER.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.
##              2020-07-29 MAS  Added code to do an AUXFLAG-like cycle delay
##                              in DVMON.
##              2021-05-30 ABS  Aligned IAW to field boundary.


                BANK            33
                SETLOC          SERVICES
                BANK

                EBANK=          DVCNTR
# *************************************   PREREAD   **************************************************************


                COUNT*          $$/SERV

PREREAD         CAF             SEVEN                   # 5.7 SPOT TO SKIP LASTBIAS AFTER
                TC              NEWPHASE                # RESTART.
                OCT             5
                CAF             PRIO21
                TC              NOVAC
                EBANK=          NBDX
                2CADR           LASTBIAS                # DO LAST GYRO COMPENSATION IN FREE FALL

BIBIBIAS        TC              PIPASR          +3      # CLEAR + READ PIPS LAST TIME IN FRE5+F133
                                                        # DO NOT DESTROY VALUE OF PIPTIME1

                TC              UPFLAG
                ADRES           V37FLAG                 # SET V37FLAG AND AVEGFLAG (BITS 5 AND 6
                TC              UPFLAG                  #    OF FLAGWRD7)
                ADRES           AVEGFLAG

                TC              DOWNFLAG                # RESET DRIFTFLAG
                ADRES           DRIFTFLG

                CAF             FOUR                    # INITIALIZE DV MONITOR
                TS              DVCNTR
                TS              PIPAGE
                TS              STOPDVC 

                CAF             LRBYBIT
                TS              LRSTAT

                CAF             ENDJBCAD                # POINT OUTROUTE TO END-OF-JOB.
                TS              OUTROUTE

                CAF             PRIO22
                TC              FINDVAC                 # TO FIRST ENTRY TO AVERAGE G.
                EBANK=          DVCNTR
                2CADR           NORMLIZE

                CAF             2SECS                   # WAIT TWO SECONDS FOR READACCS
                TC              WAITLIST
                EBANK=          DVCNTR
                2CADR           READACCS

                CS              TWO                     # 5.2SPOT FOR REREADAC AND NORMLIZE
                TC              NEWPHASE
                OCT             5

                TCF             TASKOVER

# *************************************   READACCS   *************************************************************
READACCS        CS              FLAGWRD6
                MASK            MUNFLBIT
                CCS             A
                TCF             PIPSDONE        -1

                CS              FLAGWRD7
                MASK            SWANDBIT
                CCS             A
                TCF             SWANDOFF

                CAF             TWELVE
                TC              WAITLIST
                EBANK=          UNIT/R/
                2CADR           LANDISP

                TCF             PIPSDONE        -1

SWANDOFF        TC              IBNKCALL
                CADR            DISPRSET

                TC              PIPASR                  # READ THE PIPAS.

PIPSDONE        CA              FIVE
                TC              NEWPHASE
                OCT             5
REDO5.5         CAF             ONE
                TS              PIPAGE

                CAF             SEVEN                   # SET PIPCTR FOR 4X/SEC RATE.
                TS              PIPCTR

                CS              FLAGWRD7
                MASK            AVEGFBIT
                CCS             A
                TC              AVEGOUT                 # AVEGFLAG DOWN - SET UP FINAL EXIT

MAKEACCS        CAF             2SECS
                TC              TWIDDLE
                ADRES           READACCS

                CS              LRSTAT
                MASK            LRBYBIT
                EXTEND
                BZF             STRTSERV

                CAF             1.95SECS
                TC              TWIDDLE
                ADRES           LRHTASK

STRTSERV        CA              PRIO20
                TC              FINDVAC
                EBANK=          DVCNTR
                2CADR           SERVICER                # SET UP SERVICER JOB

                TC              PHASCHNG
                OCT             40045

                CA              BIT9
                EXTEND
                WOR             DSALMOUT                # TURN ON TEST CONNECTOR OUTBIT

                TCF             TASKOVER

AVEGOUT         EXTEND
                DCA             AVOUTCAD                # SET UP FINAL SERVICER EXIT
                DXCH            AVGEXIT

                TCF             STRTSERV                # END TASK WITHOUT CALLING READACCS


                EBANK=          DVCNTR
AVOUTCAD        2CADR           AVGEND

# *************************************   SERVICER   *************************************************************

SERVICER        TC              PHASCHNG                # RESTART REREADAC + SERVICER
                OCT             16035
                OCT             20000
                EBANK=          DVCNTR
                2CADR           GETABVAL

                CAF             PRIO31                  # INITIALIZE 1/PIPADT IN CASE RESTART HAS
                TS              1/PIPADT                # CAUSED LASTBIAS TO BE SKIPPED.


                TC              BANKCALL                # PIPA COMPENSATION CALL
                CADR            1/PIPA

GETABVAL        TC              INTPRET
                VLOAD           ABVAL
                                DELV
                STORE           ABDELV                  # ABDELV = CM/SEC*2(-14).
                DMP
                                KPIP
                STORE           ABDVCONV                # ABDVCONV = M/CS * 2(-5).
MASSMON         BON             AXT,1                   # ARE WE ON THE SURFACE?
                                SURFFLAG
                                MOONSPOT                # YES:  BYPASS MASS MESS
                                0
                DDV             BON                     # NO:   WHICH VEX SHOULD BE USED?
                                1SEC(7)
                                APSFLAG
                                +3
                AXT,1
                                2
                STODL           /AF/                    # /AF/ = MAGNITUDE DV/DT
                                ABDVCONV
                VSR4            DDV*
                                APSVEX1,1
                DMP             DAD
                                MASS
                                MASS
                STORE           MASS1

MOONSPOT        DLOAD           VSR6
                                ABDVCONV
                DAD
                                DVTOTAL
                STORE           DVTOTAL                 # UPDATE DVTOTAL FOR DISPLAY

                RTB             CALL
                                TMPTOSPT
                                CD*TR*G
                AXC,1           CALL
                                XNBPIP
                                XNBNDX

AVERAGEG        BON             CALL
                                MUNFLAG
                                MUNRVG
                                CALCRVG
                EXIT

GOSERV          TC              PHASCHNG
                OCT             10035

COPYCYCL        TC              COPYCYC

                TC              DOWNFLAG                # CLEAR STEERSW PRIOR TO DVMON.
                ADRES           STEERSW

                CAF             IDLEFBIT                # IS THE IDLE FLAG SET?
                MASK            FLAGWRD7
                CCS             A
                TCF             USEJETS                 # IDLEFLAG = 1, HENCE SET AUXFLAG TO 0.

## The following three instructions have been added to approximate the AUXFLAG logic in Luminary,
## using only three instructions as observed from module B6 of Sundance 306. They are, however,
## a modern recreation, and may or may not match what actually went into 306.
                XCH             AUXFLAG
                CCS             A
                TCF             USEJETS

DVMON           INHINT
                CS              DVTHRUSH
                AD              ABDELV
                EXTEND
                BZMF            LOTHRUST

                TC              IBNKCALL
                CADR            NOULLAGE

                CS              FLAGWRD2                # SET STEERSW.
                MASK            STEERBIT
                ADS             FLAGWRD2

DVCNTSET        CA              STOPDVC                 # UPDATE MAXIMUM NOW THAT
                TS              DVCNTR                  # THRUXT HAS BEEN DETECTED.

                CA              FLAGWRD1
                MASK            GIMBFBIT
                EXTEND
                BZF             USEJETS

                CA              FLAGWRD1                # BRANCH IF APSFLAG IS SET.
                MASK            APSFLBIT
                CCS             A
                TCF             USEJETS

                CA              BIT9                    # CHECK GIMBAL FAIL BIT
                EXTEND
                RAND            CHAN32
                EXTEND
                BZF             USEJETS

USEGTS          CS              USEQRJTS
                MASK            DAPBOOLS
                TS              DAPBOOLS
                TCF             SERVOUT

LOTHRUST        CCS             DVCNTR
                TCF             DECCNTR

                TC              PHASCHNG
                OCT             10035

                TC              POSTJUMP
                CADR            COMFAIL

DECCNTR         TS              DVCNTR

USEJETS         INHINT
                CS              DAPBOOLS
                MASK            USEQRJTS
                ADS             DAPBOOLS
SERVOUT         RELINT
                TC              BANKCALL
                CADR            1/ACCS

                CA              PRIORITY
                MASK            LOW9
                TS              PUSHLOC
                ZL
                DXCH            FIXLOC                  # FIXLOC AND OVFIND

                TC              PHASCHNG
                OCT             10035
                EXTEND                                  # EXIT TO SELECTED ROUTINE WHETHER THERE
                DCA             AVGEXIT                 # IS THRUST OR NOT.  THE STATE OF STEERSW
                DXCH            Z                       # WILL CONVEY THIS INFORMATION.

AVGEND          CA              PIPTIME         +1      # FINAL AVERAGE G EXIT
                TS              1/PIPADT                # SET UP FREE FALL GYRO COMPENSATION.

                TC              UPFLAG                  # SET DRIFT FLAG.
                ADRES           DRIFTFLG

                TC              BANKCALL
                CADR            PIPFREE

                CS              BIT9
                EXTEND
                WAND            DSALMOUT

                TC              2PHSCHNG

                OCT             5                       # GROUP 5 OFF
                OCT             05022                   # GROUP 2 ON
                OCT             20000

                TC              INTPRET
                CALL
                                AVETOMID
                BON             BOFF
                                RNDVZFLG
                                AVG2.7
                                P25FLAG
                                GRP2OFF 
                EXIT

                TC              PHASCHNG
                OCT             40112

AVERTRN         CA              OUTROUTE                # RETURN TO DESIRED POINT.
                TC              BANKJUMP

GRP2OFF         EXIT
                TC              PHASCHNG
                OCT             00002
                TCF             AVERTRN

AVG2.7          EXIT
                TC              PHASCHNG
                OCT             40072
                TCF             AVERTRN

OUTGOAVE        =               AVERTRN

DVCNTR1         =               MASS1

SERVEXIT        TC              PHASCHNG
                OCT             00035

   +2           TCF             ENDOFJOB

ENDJBCAD        CADR            SERVEXIT        +2

# NORMLIZE AND COPYCYCL

NORMLIZE        TC              INTPRET
                DLOAD
                                MASS
                STOVL           MASS1
                                UNITX
                STORE           UASTEER
                BOFF            VLOAD
                                MUNFLAG
                                NORMLIZ1
                                VN1
                MXV             VSL1
                                REFSMMAT
                STOVL           V
                                RN1
                MXV             VSL6
                                REFSMMAT
                STCALL          R
                                MUNGRAV
                BON             VLOAD
                                FLP70
                                ASCSPOT
                                V
                VXV             UNIT
                                R
                STORE           UHYP
ASCSPOT         EXIT
                TCF             NORMLIZ2

NORMLIZ1        VLOAD           CALL
                                RN1
                                CALCGRAV
                EXIT

NORMLIZ2        TC              COPYCYC
                TC              ENDOFJOB


COPYCYC         EXTEND
                QXCH            COPEXIT
                CAF             OCT25
                TC              GENTRAN
                ADRES           RN1
                ADRES           RN
                TC              COPEXIT

COPEXIT         =               MPAC            +3

# ******************* PIPA READER ********************

#                 MOD NO. 00  BY D. LICKLY  DEC.9 1966


# FUNCTIONAL DESCRIPTION

#    SUBROUTINE TO READ PIPA COUNTERS, TRYING TO BE VERY CAREFUL SO THAT IT WILL BE RESTARTABLE.
#    PIPA READINGS ARE STORED IN THE VECTOR DELV. THE HIGH ORDER PART OF EACH COMPONENT CONTAINS THE PIPA READING,
#    RESTARTS BEGIN AT REREADAC.


#    AT THE END OF THE PIPA READER THE CDUS ARE READ AND STORED AS A
# VECTOR IN CDUTEMP.  THE HIGH ORDER PART OF EACH COMPONENT CONTAINS
# THE CDU READING IN 2S COMP IN THE ORDER CDUX,Y,Z.  THE THRUST
# VECTOR ESTIMATOR IN FINDCDUD REQUIRES THE CDUS BE READ AT PIPTIME.

# CALLING SEQUENCE AND EXIT

#    CALL VIA TC, ISWCALL, ETC.

#    EXIT IS VIA Q.


#

# INPUT

#    INPUT IS THROUGH THE COUNTERS PIPAX, PIPAY, PIPAZ, AND TIME2.


# OUTPUT

#    HIGH ORDER COMPONENTS OF THE VECTOR DELV CONTAIN THE PIPA READINGS.
#    PIPTIME CONTAINS TIME OF PIPA READING.


# DEBRIS (ERASABLE LOCATIONS DESTROYED BY PROGRAM)

#          TEMX   TEMY   TEMZ   PIPAGE

PIPASR          EXTEND

                DCA             TIME2
                DXCH            PIPTIME1                # CURRENT TIME POSITIVE VALUE
       +3       CS              ZERO                    # INITIALIZE THESE AT NEG. ZERO.
                TS              TEMX
                TS              TEMY
                TS              TEMZ

                CA              ZERO
                TS              DELVZ                   # OTHER DELVS OK INCLUDING LOW ORDER
                TS              DELVY
                TS              PIPAGE                  # SHOW PIPA READING IN PROGRESS

REPIP1          EXTEND
                DCS             PIPAX                   # X AND Y PIPS READ
                DXCH            TEMX
                DXCH            PIPAX                   # PIPAS SET TO NEG ZERO AS READ.
                TS              DELVX
                LXCH            DELVY

REPIP3          CS              PIPAZ                   # REPEAT PROCESS FOR Z PIP
                XCH             TEMZ
                XCH             PIPAZ
DODELVZ         TS              DELVZ

REPIP4          CA              CDUX                    # READ CDUS INTO HIGH ORDER CDUTEMPS
                TS              CDUTEMPX
                CA              CDUY
                TS              CDUTEMPY
                CA              CDUZ
                TS              CDUTEMPZ
                CA              DELVX
                TS              PIPATMPX
                CA              DELVY
                TS              PIPATMPY
                CA              DELVZ
                TS              PIPATMPZ

                TC              Q


REREADAC        CCS             PHASE5
                TCF             +2
                TCF             TASKOVER

                CCS             PIPAGE
                TCF             READACCS                # PIP READING NOT STARTED. GO TO BEGINNING


                CAF             DONEADR                 # SET UP RETURN FROM PIPASR
                TS              Q

                CCS             DELVZ
                TCF             REPIP4                  # Z DONE, GO DO CDUS
                TCF             +3                      # Z NOT DONE, CHECK Y.
                TCF             REPIP4
                TCF             REPIP4

                ZL
                CCS             DELVY
                TCF             +3
                TCF             CHKTEMX                 # Y NOT DONE, CHECK X.
                TCF             +1
                LXCH            PIPAZ                   # Y DONE, ZERO Z PIP.

                CCS             TEMZ
                CS              TEMZ                    # TEMZ NOT = -0, CONTAINS -PIPAZ VALUE.
                TCF             DODELVZ
                TCF             -2
                LXCH            DELVZ                   # TEMZ = -0, L HAS ZPIP VALUE.
                TCF             REPIP4

CHKTEMX         CCS             TEMX                    # HAS THIS CHANGED
                CS              TEMX                    # YES
                TCF             +3                      # YES
                TCF             -2                      # YES
                TCF             REPIP1                  # NO
                TS              DELVX

                CS              TEMY
                TS              DELVY

                CS              ZERO                    # ZERO X AND Y PIPS
                DXCH            PIPAX                   # L STILL ZERO FROM ABOVE

                TCF             REPIP3

DONEADR         GENADR          PIPSDONE

TMPTOSPT        CA              CDUTEMPY                # THIS SUBROUTINE, CALLED BY AN RTB FROM
                TS              CDUSPOTY                # INTERPRETIVE, LOADS THE CDUS CORRESPON-
                CA              CDUTEMPZ                # DING TO PIPTIME INTO THE CDUSPOT VECTOR.
                TS              CDUSPOTZ
                CA              CDUTEMPX
                TS              CDUSPOTX
                TCF             DANZIG

# LRHTASK IS A WAITLIST TASK SET BY READACCS DURING THE DESCENT BRAKING
# PHASE WHEN THE ALT TO THE LUNAR SURFACE IS LESS THAN 25,000 FT.  THIS
# TASK CLEARS THE ALTITUDE MEASUREMENT MADE DISCRETE AND INITIATES THE
# LANDING RADAR MEASUREMENT JOB (LRHJOB) TO TAKE A ALTITUDE MEASUREMENT
# 50 MS PRIOR TO THE NEXT READACCS TASK.

LRHTASK         CA              READLBIT
                MASK            LRSTAT                  # IS READLR FLAG SET?
                EXTEND
                BZF             TASKOVER                # NO.  BYPASS LR READ.

                CS              LRSTAT
                MASK            NOLRRBIT                # IS LR READ INHIBITED?
                EXTEND
                BZF             TASKOVER                # YES.  BYPASS LR READ.

                CA              PRIO32                  # LR READ OK   SET JOB TO DO IT
                TC              NOVAC                   # ABOUT 50 MS PRIOR TO PIPA READ
                EBANK=          HMEAS
                2CADR           LRHJOB

                TC              TASKOVER


# HIGATASK IS ENTERED APPROXIMATELY 6 SECS PRIOR TO HIGATE DURING THE
# DESCENT PHASE.  HIGATASK SETS THE HIGATE FLAG (BIT11) AND THE LR INHIBIT
# FLAG (BIT10) IN LRSTAT.  THE HIGATJOB IS SET UP TO REPOSITION THE LR
# ANTENNA FROM POSITION 1 TO POSITION 2.  IF THE REPOSITIONING IS
# SUCCESSFUL THE ALT BEAM AND VELOCITY BEAMS ARE TRANSFORMED TO THE NEW
# ORIENTATION IN NB COORDINATES AND STORED IN ERASABLE.

HIGATASK        INHINT
                CS              PRIO3                   # SET HIGATE AND LR INHIBIT FLAGS
                MASK            LRSTAT   
                AD              PRIO3
                TS              LRSTAT   
                CAF             PRIO32
                TC              FINDVAC                 # SET LR POSITIONING JOB (POS2)
                EBANK=          HMEAS
                2CADR           HIGATJOB
                RELINT
                TCF             CONTSERV                # CONTINUE SERVICER

#   MUNRETRN IS THE RETURN LOC FROM SPECIAL AVE G ROUTINE (MUNRVG)

MUNRETRN        EXIT

                CAF             XORFLBIT                # WERE WE BELOW 30000 FT LAST PASS?
                MASK            LRSTAT
                EXTEND
                BZF             XORCHK                  # NO - TEST THIS PASS

                CS              LRSTAT
                MASK            LRBYBIT
                EXTEND
                BZF             COPYCYC1                # BYPASS LR LOGIC IF BIT15 IS SET.

                CA              READLBIT                # SEE IF ALT < 35000 FT LAST CYCLE
                MASK            LRSTAT
                EXTEND
                BZF             25KCHK                  # ALT WAS > 35000 FT LAST CYCLE   CHK NOW

HITEST          CAF             PSTHIBIT                # CHECK FOR HIGATE
                MASK            LRSTAT   
                EXTEND
                BZF             HIGATCHK                # NOT AT HIGATE LAST CYCLE-CHK THIS CYCLE

POS2CHK         CAF             BIT7                    # VERIFY LR IN POS2
                EXTEND
                RAND            CHAN33
                EXTEND
                BZF             UPDATCHK                # IT IS-CHECK FOR LR UPDATE
                CAF             BIT13                   # NOT IN POS2-MAYBE REPOSITIONING
                EXTEND
                RAND            CHAN12
                EXTEND
                BZF             LRPOSALM                # LR NOT IN POS2 OR REPOSITIONING-BAD
                TCF             CONTSERV                # LR BEING REPOSITIONED-CONTINUE SERV

HIGATCHK        CS              TTF/8                   # IS TTF > CRITERION?
                AD              RPCRTIME

                EXTEND
                BZMF            HIGATASK                # IF UXBXP > QSW, THEN REPOSITION

POS1CHK         CAF             BIT6                    # HIGATE NOT IN SIGHT-DO POS1 CHK
                EXTEND
                RAND            33
                EXTEND
                BZF             UPDATCHK                # LR IN POS1-CHECK FOR LR UPDATE

LRPOSALM        TC              ALARM                   # LR NOT IN PROPER POS-ALARM-BYPASS UPDATE
                OCT             511                     # AND CONTINUE SERVICER
CONTSERV        INHINT
                CS              BITS4-7
                MASK            LRSTAT                  # CLEAR LR MEASUREMENT MADE DISCRETES.
                TS              LRSTAT

COPYCYC1        TC              PHASCHNG
                OCT             10035

                TC              INTPRET                 # INTPRET DOES A RELINT.
                VLOAD           VXM
                                V1S
                                REFSMMAT
                VSL1
                STORE           VN1                     # TEMP. REF. VELOCITY VECTOR*2(7)M/CS.
                ABVAL
                STOVL           ABVEL
                                R1S
                VXM             VSR4
                                REFSMMAT
                STORE           RN1                     # TEMP. REF. POSITION VECTOR*2(29)M.
                UNIT
                STORE           UNITR
                BOFF            RTB
                                FLP70
                                +2
                                COPYCYC3
                VLOAD           UNIT
                                R1S
                VXV             VSL1
                                UHYP
                STOVL           UHZP                    # DOWNRANGE HALF-UNIT VECTOR FOR R10.
                                WM
                VXV             VSL2
                                R1S
                STODL           DELVS
                                36D
                DSU
                                /LAND/
                STORE           HCALC                   # NEW HCALC*2(24)M.
                DMP
                                ALTCONV
                STOVL           ALTBITS                 # ALTITUDE FOR R10 IN BIT UNITS.
                                V1S
                VSQ             DDV
                                36D
                DMP             SIGN
                                ARCONV1
                                HDOTDISP
COPYCYC2        EXIT                                    # LEAVE ALTITUDE RATE COMPENSATION IN MPAC
                CAF             FIVE
                TC              GENTRAN
                ADRES           UNIT/R/
                ADRES           RUNIT

                CA              MPAC
                TS              DALTRATE

COPYCYC3        CAF             ELEVEN
                TC              GENTRAN
                ADRES           R1S
                ADRES           R

                TS              PIPATMPX
                TS              PIPATMPY
                TS              PIPATMPZ

                TCF             COPYCYCL                # COMPLETE THE COYPCYCL.

#     ALTCHK COMPARES CURRENT ALTITUDE (IN HCALC) WITH A SPECIFIED ALTITUDE FROM A TABLE BEGINNING AT ALTCRIT.
# ITS CALLING SEQUENCE IS AS FOLLOWS:-

#        L        CAF    N
#        L+1      TC     BANKCALL
#        L+2      CADR   ALTCHK
#        L+3      RETURN HERE IF HCALC STILL > SPECIFIED CRITERION.   C(L) = +0.
#        L+4      RETURN HERE IF HCALC < OR = SPECIFIED CRITERION.   C(A) = C(L) = +0

# ALTCHK MUST BE BANKCALLED EVEN FROM ITS OWN BANK.   N IS THE LOCATION, RELATIVE TO THE TAG ALTCRIT,
# OF THE BEGINNING OF THE DP CONSTANT TO BE USED AS A CRITERION.

ALTCHK          EXTEND
                INDEX           A
                DCA             ALTCRIT
                DXCH            MPAC            +1
                EXTEND
                DCS             HCALC
                DAS             MPAC            +1
                TC              BRANCH          +4
                CAF             ZERO                    # BETTER THAN A NOOP, PERHAPS
                INCR            BUF2
                TCF             SWRETURN

ALTCRIT         =               25KFT

25KFT           2DEC            7620            B-24    # (0)
15KFT           2DEC            4572            B-24    # (2)
50FT            2DEC            15.24           B-24    # (4)
30KFT           2DEC            9144            B-24    # (6)


XORCHK          CAF             SIX                     # ARE WE BELOW 30000 FT?
                TC              BANKCALL
                CADR            ALTCHK
                TCF             CONTSERV                # CONTINUE LR UPDATE
                TC              UPFLAG                  # YES: INHIBIT X-AXIS OVERRIDE
                CADR            XOVINFLG
                TC              UPFLAG
                CADR            XORFLG
                TCF             CONTSERV                # CONTINUE LR UPDATE


25KCHK          CAF             ZERO                    # ARE WE BELOW 25000 FT?

                TC              BANKCALL
                CADR            ALTCHK
                TCF             CONTSERV
                CAF             READLBIT                # SET READLR FLAG TO ENABLE LR READING.
SETLRSTT        ADS             LRSTAT
                TCF             CONTSERV

15KCHK          CAF             TWO                     # ARE WE BELOW 15000 FT?

                TC              BANKCALL
                CADR            ALTCHK
                TCF             CONTSERV
                LXCH            VSELECT
                CAF             READVBIT
                TCF             SETLRSTT

# *********************************************************************************************************
#

CALCGRAV        UNIT            PDVL                    # SAVE UNIT/R/ IN PUSHLIST            (18)
                                ZEROVECS
                STOVL           UNITGOBL
                AXC,1           PUSH
                                2
                STORE           UNITR
                BON             AXC,1
                                LMOONFLG
                                CALCGRV1
                                0
                DOT             PUSH
                                UNITW
                DSQ             BDSU
                                DP1/20
                PDDL            DDV
                                RESQ
                                34D                     # (RN)SQ
                STORE           32D                     # TEMP FOR (RE/RN)SQ
                DMP             DMP
                                20J
                VXSC            PDDL
                                UNITR
                DMP             DMP
                                2J
                                32D
                VXSC            VAD
                                UNITW
                STADR
                STORE           UNITGOBL
                VAD             PUSH                    # MPAC = UNIT GRAVITY VECTOR.         (18)
CALCGRV1        DLOAD           NORM                    # PERFORM A NORMALIZATION ON RMAGSQ IN
                                34D                     # ORDER TO BE ABLE TO SCALE THE MU FOR
                                X2                      # MAXIMUM PRECISION.
                BDDV*           SLR*
                                -MUDT,1
                                0       -21D,2
                VXSC            STADR
                STORE           GDT1/2                  # SCALED AT 2(+7) M/CS
                RVQ

CALCRVG         VLOAD           VXM
                                DELV
                                REFSMMAT
                VXSC            VSL1
                                KPIP1
                STORE           DELVREF
                VSR1            PUSH
                VAD             PUSH                    # (DV-OLDGDT)/2 TO PD SCALED AT 2(+7)M/CS

                                GDT/2
                VAD             PDDL                    #                                     (18)
                                VN
                                PIPTIME1
                DSU             SL
                                PIPTIME
                                6D
                VXSC
                VAD             STQ
                                RN
                                31D
                STCALL          RN1                     # TEMP STORAGE OF RN SCALED 2(+29)M
                                CALCGRAV

                VAD             VAD
                VAD
                                VN
                STCALL          VN1                     # TEMP STORAGE OF VN SCALED 2(+7)M/CS
                                31D

KPIP1           2DEC            .0128                   # SCALES DELV TO UNITS OF 2(7) M/CS.
KPIP            2DEC            .1024                   # SCALES DELV TO UNITS OF 2(4) M/CS.

# *** THE ORDER OF THE FOLLOWING TWO CONSTANTS MUST BE PRESERVED *********

-MUDT           2DEC*           -7.9720645      E+12 B-44*
-MUDT1          2DEC*           -9.8055560      E+10 B-44*

UNUSEDF3        2DEC            12800

DP1/20          2DEC            0.05
RESQ            2DEC*           40.6809913      E12 B-58*
20J             2DEC            3.24692010      E-2
2J              2DEC            3.24692010      E-3
ALTCONV         2DEC            1.40206802      B-4     # CONVERTS M*2(-24) TO BIT UNITS *2(-28).
ARCONV1         2DEC            656.167979      B-10    # CONV. ALTRATE COMP. TO BIT UNITS<
1SEC(7)         2DEC            100             B-7
DPSVEX1         2DEC            -3004.75757     E-2 B-6
APSVEX1         2DEC            -3030.0259      E-2 B-6
200B17          =               2SEC(17)

#****************************************************************************************************************

# MUNRVG IS A SPECIAL AVERAGE G INTEGRATION ROUTINE USED BY THRUSTING
# PROGRAMS WHICH FUNCTION IN THE VICINITY OF AN ASSUMED SPHERICAL MOON.
# THE INPUT AND OUTPUT QUANTITIES ARE REFERENCED TO THE STABLE MEMBER
# COORDINATE SYSTEM.

MUNRVG          VLOAD           VXSC
                                DELV
                                KPIP2
                PUSH            VAD                     # 1ST PUSH: DELV IN UNITS OF 2(8) M/CS
                                GDT/2
                PUSH            VAD                     # 2ND PUSH: (DELV + GDT)/2, UNITS OF 2(7)
                                V                       #                                     (12)
                VXSC            VAD
                                200B17
                                R
                STCALL          R1S                     # STORE R SCALED AT 2(+24)M.
                                MUNGRAV

                VAD             VAD
                VAD                                     #                                     (0)
                                V
                STORE           V1S                     # STORE V SCALED AT 2(+7)M/CS.
                ABVAL
                STOVL           ABVELINT                # STORE SPEED FOR LR AND DISPLAYS.
                                UNIT/R/
                DOT             SL1
                                V1S
                STODL           HDOTDISP                # HDOT = V. UNIT(R)*2(7)M/CS.
                                36D
                DSU
                                /LAND/
                STCALL          HCALC                   # FOR NOW, DISPLAY WHETHER POS OR NEG
                                MUNRETRN
MUNGRAV         UNIT                                    # AT 36D HAVE ABVAL(R), AT 34D R.R
                STODL           UNIT/R/
                                34D
                NORM            BDDV
                                X2
                                -MUDT1
                SLR*            VXSC
                                0 -11D,2
                                UNIT/R/
                STORE           GDT1/2                  # 1/2GDT SCALED AT 2(7) M/CS.
                RVQ

KPIP2           2DEC            .0064                   # SCALES DELV TO UNITS OF 2(8) M/CS.
1.95SECS        DEC             195
RPCRTIME        DEC             -6              E2 B-17
0.175           2DEC            0.175
0.155           2DEC            0.155
LRWH            2DEC            0.4545454545    B1
VSCAL3          2DEC            -4.72441006     B-7     # 15.5 FT/SEC AT 2(7) M/CS
6.25            2DEC            .01905          B-6     # 6.25 FT/SEC AT 2(6) M/CS
LRHMAX          2DEC            170688              
2SEC(18)        2DEC            200             B-18
2SEC(28)        2OCT            00000   00310           # 2SEC AT 2(28)

HSCAL           2DEC            -.3288792               # SCALES 1.079 FT/BIT TO 2(22)M.

# ***** THE SEQUENCE OF THE FOLLOWING CONSTANTS MUST BE PRESERVED ********
VZSCAL          2DEC            +.5410829105            # SCALES .8668 FT/SEC/BIT TO 2(18) M/CS.
VYSCAL          2DEC            +.7565672446            # SCALES 1.212 FT/SEC/BIT TO 2(18) M/CS.
VXSCAL          2DEC            -.4020043770            # SCALES -.644 FT/SEC/BIT TO 2(18) M/CS.

LRWVZ           2DEC            0.7
LRWVY           2DEC            0.7
LRWVX           2DEC            0.4

BITS4-7         OCT             110

# LRSTAT BIT DEFINITIONS
LRBYBIT         =               BIT15                   # LR UPDATE BYPASS FLAG
PSTHIBIT        =               BIT11                   # PAST HIGATE FLAG
NOLRRBIT        =               BIT10                   # LANDING RADAR REPOSITIONING FLAG
XORFLBIT        =               BIT9                    # X-AXIS OVERRIDE LIMIT FLAG
VELDABIT        =               BIT7                    # LR VELOCITY MEASUREMENT MADE FLAG
READLBIT        =               BIT6                    # OK TO READ LR RANGE DATA FLAG
READVBIT        =               BIT5                    # OK TO READ LR VELOCITY DATA FLAG
RNGEDBIT        =               BIT4                    # LR ALTITUDE MEASUREMENT MADE FLAG

# THE FOLLOWING DEFINITIONS ALLOW LRSTAT AND 
XOVINFLG        =               11872D                  # X-AXIS OVERRIDE FLAG
LRBYPASS        =               13561D                  # LANDING RADAR BYPASS FLAG
XORFLG          =               13567D                  # X-AXIS OVERRIDE LIMIT FLAG

UPDATCHK        CAF             NOLRRBIT                # SEE IF LR UPDATE INHIBITED.
                MASK            LRSTAT   
                CCS             A
                TCF             CONTSERV                # IT IS-NO LR UPDATE
                CAF             RNGEDBIT                # NO INHIBIT - SEE ALT MEAS. THIS CYCLE.
                MASK            LRSTAT   
                EXTEND
                BZF             VMEASCHK                # NO ALT MEAS THIS CYCLE-CHECK FOR VEL

POSUPDAT        TC              INTPRET
                VLOAD           VXM
                                HBEAMNB                 # RANGE VECTOR IN NB COORDINATES AT 2(22)M
                                XNBPIP                  # CONVERT TO SM COORDINATES AT 2(23)M
                VSL1            SETPD
                                0
                DOT             DMP
                                UNIT/R/                 # ALTITUDE AT 2(24)M
                                HMEAS
                SL              DMP
                                6D
                                HSCAL
                DSU             PUSH
                                HCALC
                STODL           DELTAH
                                HCALC
                DMP             DAD
                                0.175
                                50FT
                PDDL            ABS
                                DELTAH
                BOVB            DDV
                                TCDANZIG
                EXIT

                INCR            LRLCTR
                CCS             OVFIND
                TCF             HFAIL                   # DELTA H TOO LARGE

                CA              FLAGWRD1
                MASK            HINHFBIT
                CCS             A
                TCF             VMEASCHK                # UPDATE INHIBITED - TEST VELOCITY ANYWAY

                TC              INTPRET                 # DO POSITION UPDATE

                DLOAD           DDV
                                HCALC                   # RESCALE H TO 2(28)M
                                LRHMAX
                BOVB            BDSU
                                VMEASCHK
                                NEARONE
                DMP             DDV
                                DELTAH
                                LRWH
                VXSC            VAD
                                UNIT/R/
                                R1S
                STORE           GNUR
                EXIT

                TC              PHASCHNG
                OCT             10035

                CA              FIVE
                TC              GENTRAN
                ADRES           GNUR
                ADRES           R1S
                RELINT

                TC              INTPRET
                VLOAD           CALL
                                R1S
                                MUNGRAV
                EXIT

VMEASCHK        TC              PHASCHNG                # RESTART AT NEXT LOCATION
                OCT             10035
                CAF             VELDABIT                # IS V READING AVAILABLE?
                MASK            LRSTAT
                EXTEND
                BZF             VALTCHK                 # NO   SEE IF V READING TO BE TAKEN

VELUPDAT        CS              VSELECT                 # PROCESS VELOCITY DATA
                DOUBLE
                TS              L                       # -2 VSELECT IN L
                AD              L
                AD              L                       # -6 VSELECT IN A
                INDEX           FIXLOC
                DXCH            X1                      # X1 = -6 VSELECT, X2 = -2 VSELECT


                CA              EBANK4
                TS              EBANK
                EBANK=          LRXCDU

                CA              PIPTEM                  # STORE DELV IN MPAC
                ZL
                DXCH            MPAC

                CA              PIPTEM          +1
                ZL
                DXCH            MPAC            +3

                CA              PIPTEM          +2
                ZL
                DXCH            MPAC            +5

                CA              LRYCDU                  # STORE LRCDUS IN CDUSPOTS
                TS              CDUSPOT
                CA              LRZCDU
                TS              CDUSPOT         +2
                CA              LRXCDU
                TS              CDUSPOT         +4

                CS              ONE
                TS              MODE                    # CHANGE STORE MODE TO VECTOR

                CA              EBANK7
                TS              EBANK                   # RESTORE EBANK 7
                EBANK=          DVCNTR

                CA              FIXLOC
                TS              PUSHLOC                 # SET PD TO ZERO

                TC              INTPRET
                PDVL*           CALL
                                VZBEAMNB,1              # CONVERT VBEAM FROM NB TO SM
                                TRG*NBSM
                PDVL
                VXSC            PDDL
                                KPIP1                   # SCALE DELV TO 2(7) M/CS AND PUSH
                                LRVTIME                 # TIME OF DELV AT 2(28)CS
                DSU             DDV
                                PIPTIME                 # TU - T(N-1)
                                2SEC(28)
                VXSC            VSL1                    # G(N-1)(TU - T(N-1))
                                GDT/2                   # SCALED AT 2(7) M/CS
                VAD             VAD                     # PUSH UP FOR DELV
                                DELVREF
                PDVL            VXV
                                R
                                WM
                VAD
                DOT             PDDL
                                0
                                VMEAS
                SL              DMP*
                                10D
                                VZSCAL,2
                DSU             PDDL
                                6
                ABS             DMP
                                0.155
                DAD             PDDL
                                6.25
                                6
                ABS             BDSU
                EXIT

                INCR            LRMCTR
                TC              BRANCH
                TCF             VUPDAT
                TCF             VFAIL                   # DELTA V TOO LARGE     ALARM

VFAIL           CS              LRSCTR                  #   DELTA Q LARGE
                EXTEND                                  # IF S = 0, DO NOT TURN ON TRACKER FAIL
                BZF             NOLITE
                AD              LRMCTR                  # M-S
                MASK            NEG3                    # TEST FOR M-S > 3
                EXTEND                                  # IF M-S > 3, THEN TWO OR MORE OF THE
                BZF             +1                      #   LAST FOUR V READINGS WERE BAD,
#               TCF             NOLITE                  #   SO TURN ON VELOCITY FAIL LIGHT

#               TC              UPFLAG                  # AND SET BIT TO TURN ON TRACKER FAIL LITE
#               ADRES           VFLSHFLG

NOLITE          CA              LRMCTR                  # SET S = M
                TS              LRSCTR

                CS              FLAGWRD0
                MASK            VORIDBIT
                EXTEND
                BZF             VUPDAT1

                CCS             VSELECT                 # TEST FOR Z COMPONENT
                TCF             VALTCHK                 # NOT Z, DO NOT SET VX INHIBIT

                CAF             TWO
                TS              VSELECT
                TCF             VALTCHK

VUPDAT          CA              FLAGWRD0
                MASK            VINHFBIT
                CCS             A
                TCF             VALTCHK                 # UPDATE INHIBITED

VUPDAT1         TC              INTPRET
                DLOAD           DDV
                                ABVELINT
                                VSCAL3
                BOVB            DAD
                                VALTCHK
                                NEARONE
                DMP*            DMP
                                LRWVZ,2
                VXSC
                VAD
                                V1S                     # ADD WEIGHTED DELTA V TO VELOCITY
                STORE           GNUV
                EXIT

                TC              PHASCHNG                # DO NOT RE-UPDATE
                OCT             10035

                CA              FIVE
                TC              GENTRAN                 # STORE NEW VELOCITY VECTOR
                ADRES           GNUV
                ADRES           V1S

ENDVDAT         =               VALTCHK

VALTCHK         TC              PHASCHNG                # DO NOT REPEAT ABOVE
                OCT             10035

                CAF             READVBIT                # TEST READVEL TO SEE IF VELOCITY READING
                MASK            LRSTAT                  # IS DESIRED.
                EXTEND
                BZF             15KCHK                  # TES - READ VELOCITY

READV           INHINT    
                CAF             PRIO32                  # SET UP JOB TO READ VELOCITY BEAMS.
                TC              NOVAC
                EBANK=          HMEAS
                2CADR           LRVJOB

                TCF             CONTSERV                # CONTINUE WITH SERVICER

HFAIL           CS              LRRCTR
                EXTEND
                BZF             NORLITE                 # IF R = 0, DO NOT TURN ON TRK FAIL
                AD              LRLCTR
                MASK            NEG3
                EXTEND                                  # IF L-R LT 4, DO NOT TURN ON TRK FAIL
                BZF             +1
#                TCF             NORLITE

#                TC              UPFLAG                  # AND SET BIT TO TURN ON TRACKER FAIL LITE
#                ADRES           HFLSHFLG

NORLITE         CA              LRLCTR
                TS              LRRCTR                  # SET R = L
                TS              LRMCTR

                TCF             VMEASCHK


# ********************************************************************************************************
#    LRVJOB IS SET WHEN THE LEM IS BELOW 15000 FT DURING THE LANDING PHASE
#    THIS JOB INITIALIZES THE LANDING RADAR READ ROUTINE FOR 5 VELOCITY
#    SAMPLES AND GOES TO SLEEP WHILE THE SAMPLING IS DONE-ABOUT 500 MS.
#    WITH A GOODEND RETURN THE DATA IS STORED IN VMEAS AND BIT7 OF LRSTAT
#    IS SET.  THE GIMBAL ANGLES ARE READ ABOUT MIDWAY IN THE SAMPLING .


LRVJOB          INHINT
                CA              24MS                    # SET TASK TO READ CDUS + PIPAS
                TC              WAITLIST
                EBANK=          LRVTIME
                2CADR           RDGIMS

                CCS             VSELECT                 # SEQUENCE LR VEL BEAM SELECTOR
                TCF             +2
                CAF             TWO                     # IF ZERO-RESET TO TWO
                TS              VSELECT
                DOUBLE                                  # 2XVSELECT USED FOR VBEAM INDEX IN LRVEL
                TC              BANKCALL                # GO INITIALIZE LR VEL READ ROUTINE
                CADR            LRVEL
                TC              BANKCALL                # PUT LRVJOB TO SLEEP ABOUT 500 MS
                CADR            RADSTALL
                TC              ENDOFJOB

                EXTEND                                  # GOOD RETURN-STOW AWAY VMEAS
                DCA             SAMPLSUM
                DXCH            VMEAS

                CS              LRSTAT                  # SET BIT TO INDICATE VELOCITY
                MASK            VELDABIT                # MEASUREMENT MADE.
                ADS             LRSTAT

                TC              ENDOFJOB

# LRHJOB IS SET BY LRHTASK WHEN LEM IS BELOW 25000 FT.  THIS JOB
# INITIALIZES THE LR READ ROUTINE FOR AN ALT MEASUREMENT AND GOES TO
# SLEEP WHILE THE SAMPLING IS DONE-ABOUT 95 MS.  WITH A GOODEND RETURN
# THE ALT DATA IS STORED IN HMEAS AND BIT7 OF LRSTAT IS SET.

LRHJOB          TC              BANKCALL                # INITIATE LR ALT MEASUREMENT
                CADR            LRALT
                TC              BANKCALL                # LRHJOB TO SLEEP ABOUT 95MS
                CADR            RADSTALL
                TC              ENDOFJOB

                EXTEND
                DCA             SAMPLSUM                # GOOD RETURN-STORE AWAY LRH DATA
                DXCH            HMEAS                   # LRH DATA 1.079 FT/BIT

                CS              LRSTAT                  # SET BIT TO INDICATE RANGE
                MASK            RNGEDBIT                # MEASUREMENT MADE.
                ADS             LRSTAT
                TC              ENDOFJOB                # TERMINATE LRHJOB

#     RDGIMS  IS A TASK SET UP BY LRVJOB TO PICK UP THE IMU CDUS AND TIME
#     AT ABOUT THE MIDPOINT OF THE LR VEL READ ROUTINE WHEN 5 VEL SAMPLES
#     ARE SPECIFIED.

                EBANK=          LRVTIME
RDGIMS          EXTEND
                DCA             TIME2                   # PICK UP TIME2,TIME1
                DXCH            LRVTIME                 #    AND SAVE IN LRVTIME

                EXTEND
                DCA             CDUX                    # PICK UP CDUX AND CDUY
                DXCH            LRXCDU                  #    AND SAVE IN LRXCDU AND LRYCDU

                CA              CDUZ
                TS              LRZCDU                  # SAVE CDUZ IN LRZCDU

                CA              PIPAX
                TS              PIPTEM                  # SAVE PIPAX IN PIPTEM

                EXTEND
                DCA             PIPAY                   # PICK UP PIPAY AND PIPAZ
                DXCH            PIPTEM          +1      #    AND SAVE IN PIPTEM +1 AND PIPTEM +2
                TC              TASKOVER

#    HIGATJOB IS SET APPROXIMATELY 6 SECONDS PRIOR TO HIGH GATE DURING
#    THE DESCENT BURN PHASE OF LUNAR LANDING.  THIS JOB INITIATES THE
#    LANDING RADAR REPOSITIONING ROUTINE AND GOES TO SLEEP UNTIL THE
#    LR ANTENNA MOVES FROM POSITION 1 TO POSITION 2.  IF THE LR ANTENNA
#    ACHIEVES POSITION 2 WITHIN 22 SECONDS THE ALTITUDE AND VELOCITY
#    BEAM VECTORS  ARE RECOMPUTED TO REFLECT THE NEW ORIENTATION WITH
#    RESPECT TO THE NB.  BIT10 OF LRSTAT IS CLEARED TO ALLOW LR
#    MEASUREMENTS AND THE JOB TERMINATES.

HIGATJOB        TC              BANKCALL                # START LRPOS2 JOB
                CADR            LRPOS2
                TC              BANKCALL                # PUT HIGATJOB TO SLEEP UNTIL JOB IS DONE
                CADR            RADSTALL
                TC              ENDOFJOB                # BAD END

                TC              SETPOS2                 # LR IN POS2 - SET UP TRANSFORMATIONS

                CS              NOLRRBIT                # RESET NOLRREAD FLAG TO ENABLE LR READING
                MASK            LRSTAT
                TS              LRSTAT
                TC              ENDOFJOB

SETPOS1         TC              MAKECADR                # MUST BE CALLED BY BANKCALL
                TS              LRADRET1                # SAVE RETURN CADR, SINCE BUF2 CLOBBERED

                CA              ZERO                    # INDEX FOR LRALPHA,LRBETA IN POS 1.

#                TS              LRLCTR                  # SET L,M,R, ANS S TO ZERO
#                TS              LRMCTR
#                TS              LRRCTR
#                TS              LRSCTR
                TC              SETPOS                  # CONTINUE WITH COMPUTATIONS

                CA              LRADRET1
                TC              BANKJUMP                # RETURN TO CALLER


SETPOS2         CA              TWO                     # INDEX FOR POS2
SETPOS          EXTEND
                INDEX           A
                DCA             LRALPHA                 # LRALPHA IN A, LRBETA IN L
                TS              CDUSPOT         +4      # ROTATION ABOUT X
                LXCH            CDUSPOT                 # ROTATION ABOUT Y
                CA              ZERO
                TS              CDUSPOT         +2      # ZERO ROTATION ABOUT Z.

                EXTEND
                QXCH            LRADRET                 # SAVE RETURN

                TC              INTPRET
                VLOAD           CALL
                                UNITY                   # CONVERT UNITY(ANTENNA) TO NB
                                TRG*SMNB
                STOVL           VYBEAMNB
                                UNITX                   # CONVERT UNITX(ANTENNA) TO NB
                CALL
                                *SMNB*
                STORE           VXBEAMNB
                VXV             VSL1
                                VYBEAMNB
                STODL           VZBEAMNB                # Z = X * Y
                                HANGLE
                RTB             PUSH
                                CDULOGIC
                SIN             PDDL
                COS             PDDL
                                ZEROVECS
                PDDL            VDEF
                VCOMP           CALL
                                *SMNB*                  # CONVERT TO NB
                STORE           HBEAMNB
                EXIT
                TC              LRADRET

24MS            DEC             24
