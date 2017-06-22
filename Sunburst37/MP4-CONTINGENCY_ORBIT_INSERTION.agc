### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MP4-CONTINGENCY_ORBIT_INSERTION.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 654-665
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-14 RSB	Transcribed.
##              2017-06-14 HG   Fix operand WACHTHTD -> WACTTHTD
##                                          TDECTEMP -> TDEC
##                                          RUPREG3  -> RUPTREG3
##                                          RUPREG1  -> RUPTREG1
##                              Remove constant 004CEK
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 654
                BANK            33

                EBANK=          TDEC
# PROGRAM NAME-                   DATE-
#          MISSION PHASE 4                 2 DECEMBER 1966
# MOD NO- 20                      LOG SECTION-
# MOD BY- SCHULENBERG                      MP4-CONTINGENCY ORBIT INSERTION

# FUNCTIONAL DESCRIPTION-
#          CONTINGENCY ORBIT INSERTION IS CALLED BY GROUND IN EVENT OF PREMATURE SIVB SHUTDOWN AND ATTEMPTS TO
# EFFECT AN ORBITAL INSERTION USING THE DPS ENGINE AND THE GUIDANCE EQUATIONS USED FOR THE APS BURNS. THE
# PROGRAM LEAVES MISSION PHASE TIMERS INHIBITED AND LEAVES FURTHER CONTROLTO THE GROUND VIA UPLINK.
# CALLING SEQUENCE-               SUBROUTINES CALLED-
#          START MP4 WHEN ABORT            FLAG1UP          FLAG1DWN

# COMMAND MONITOR DETECTS MP4              FIXDELAY         WAITLIST
# COMMAND VIA LGC UPLINK.                  VPATCHER         KALCMANU
#                                          ASCENT           UL4JETON
# NORMAL EXIT MODES-                       LMP              UL4JETOF
#          TASKOVER (AWAITS                EXECUTIVE        ENGINEON
# FURTHER COMMANDS FROM GROUND)            MIDTOAVE         ENGINOFF
# ALARM EXIT MODES-                        BANKCALL         ENGINOF1
#          NONE                            IBNKCALL         LASTBIAS

# ERASABLE INITIALIZATION REQUIRED-
#          NONE

# OUTPUT- SAME AS FOR KALCMANU
# DEBRIS- SAME AS FOR KALCMANU

MP4JOB          EXTEND
		DCA		WACTTHTD			# TO ENABLE A RESTART
		DXCH		FLUSHREG

                TC              NEWMODEX                        # START CONTINGENCY ORBIT INSERTION
                OCT             72

                CAF             FOUR                            # SIGNAL START OF MISSION PHASE 4
                TS              PHASENUM

                TC              FLAG1DWN                        # TERMINATE AVEG AND DO AUTO AVETOMID
                OCT             1

                INHINT
                CAF             BIT1
                TC              WAITLIST                        # SHORT WAITLIST TO INITIALIZE LMP COMMAND
                EBANK=          TDEC
                2CADR           ABORTPRR

                TCF             ENDOFJOB                        # END MP4JOB
## Page 655

# RCS ABORT PRESSURIZATION ROUTINE

ABORTPRR        CAF             ZERO                            # INSURE RCS JETS OFF
                EXTEND
                WRITE           5

                TC              FIXDELAY
                DEC             100                             # DELAY ONE SECOND

                TC              2LMP+DT
                DEC             188                             # RCS MAIN S/O VALVES, SYS A-OPEN**
                DEC             190                             # RCS MAIN S/O VALVES, SYS B-OPEN**
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             4                               # ED BATTERY ACTIVATION-ON
                DEC             100                             # DELAY ONE SECOND

                TC              2LMP+DT
                DEC             189                             # RCS MAIN S/O VALVES, SYS A-OPEN RESET
                DEC             191                             # RCS MAIN S/O VALVES, SYS B-OPEN RESET
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             6                               # RCS PRESSURE-FIRE**
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION-SAFE
                DEC             100                             # DELAY ONE SECOND

                TC              1LMP+DT
                DEC             7                               # RCS PRESSURE - FIRE RESET
                DEC             400                             # DELAY FOUR SECONDS

# END RCS ABORT PRESSURIZATION ROUTINE

TUMBLCHK        CA              FLAGWRD1
                MASK            BIT13
                EXTEND
                BZF             NOTUMBL

                TC              FIXDELAY
                DEC             50                              # DELAY .5 SECS AND CHECK AGAIN
                TCF             TUMBLCHK

NOTUMBL         TC              FLAG1DWN                        # IF NO TUMBLING-TERMINATE MONITOR
                OCT             20000                           # TERMINATE TUMBLE MONITOR

		TC		FLAG2DWN			# TERMINATE ABORT COMMAND MONITOR
## Page 656

		OCT		00400

TIG4-51         EXTEND
                DCA             TIME2                           # GET CURRENT TIME
                DXCH            TDEC

                CAF             021CEK                          # UPDATE STATE TO TIG4-30
                TS              L
                CAF             ZERO
                DAS             TDEC

# BEGIN ABORT LEM/S4B SEPARATION PROCEDURE

MP4SEP          CAF		MASSADR				# DECLARE EBANK= 5
		TS		EBANK
		EBANK=		MASSES
		
		EXTEND
		DCA		LEMMASS1			# INITIALIZE MASS MONITOR
		DXCH		MASS
		
		CAF		ZERO				# INITIALIZE DELAREA FOR MASS MONITOR
		TS		DELAREA
		TS		DELAREA		+1
		
		CAF		TDECADR				# DECLARE EBANK= 4
		TS		EBANK
		EBANK=		TDEC
                
                CAF             XTRANSON                        # +X TRANSLATION- ON (PRE-DAP)
                EXTEND
                WRITE           5

                TC              IBNKCALL                        # +X TRANSLATION-ON (4JET)
                CADR            ULLAGE
                
                TC              1LMP+DT
                DEC             58                              # LEM/SIVB SEPARATE - ARM ON
                DEC             50                              # DELAY 500 MS.
                
                CS              DAPBOOLS
                MASK            GODAPGO                         # TURN ON THE DAP
                ADS             DAPBOOLS

                TC              IBNKCALL
                CADR            SETMAXDB

                TC              FIXDELAY                        # WAIT FOR 300 MS.
                DEC             50                              # DELAY 500 MS.
## Page 657

                TC              IBNKCALL			# HOLD VEHICLE ATTITUDE RATE
                CADR            HOLDRATE

                TC              1LMP+DT
                DEC             90                              # LEM/SIVB SEPARATE- COMMAND
                DEC             10                              # DELAY 100 MS.

                TC              IBNKCALL
                CADR            SETMINDB

                TC              FIXDELAY
                DEC             90                              # DELAY 900 MS.

TIG4-49         TC              1LMP+DT
                DEC             59                              # LEM/S4B SEPARATE-ARM-OFF
                DEC             100                             # DELAY ONE SECOND

TIG4-48         TC              1LMP
                DEC             91                              # LEM/S4B SEPARATE-COMMAND RESET

# END LEM/S4B SEPARATION ROUTINE

                CAF             007CEK
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           TIG4-41

                CAF             PRIO27                          # START NEW JOB FOR CALCULATIONS
                TC              FINDVAC
                EBANK=          TDEC
                2CADR           LONGJOB

                TCF             TASKOVER                        # END TIG4-48 TASK

LONGJOB         EXTEND
                DCA             ORBINTAD                        # DO ORBITAL INTEGRATION
                DXCH            Z

PRECOI          CAF             KALC4AD
                TS              ASCRET
                TC              INTPRET
                CALL
                                VPATCHER                        # RESCALE AND LOAD IGN STATES IN RN AND VN
                DLOAD
                		RCRIT				# RCRIT=INJECTION ALTITUDE*2(-25)
                STOVL		RCO
                                VN                              # VN FROM VPATCHER=VIGNTION*2(-7) M/CS
                VXV             UNIT
                                RN                              # RN FROM VPATCHER=RIGNTION*2(N-29) M
                STOVL           QAXIS                           # UNIT HORIZONTAL VECTOR NORMAL TO ORBIT
## Page 658
                                UNITR                           # UNITR FROM AVEG=UNIT(RIGNTION)*2(-1) M
                STORE           PAXIS1
                VXV             VSL1
                                QAXIS
                STOVL           SAXIS                           # UNIT HORIZONTAL VECTOR PARALLEL TO ORBIT
                                ABLOCK
                STOVL           AT
                                BBLOCK
                STOVL           ATMEAS
                                CBLOCK
                STODL           RDOTD                        
                                KR1EST
                STODL           KR1                             # LOAD ATTITUDE LIMITING PARAMETER
                                TGOEST
                STORE           TGO
                CLEAR		CLEAR
                		DIRECT
                		PASS
                VLOAD           DOT
                                SAXIS
                                VN                              # ZDOT*2(-8)
                SL1                                             #  *2(-7)
                STOVL           ZDOT
                                PAXIS1
                DOT             SL1                             # RDOT*2(-8)
                                VN                              #  *2(-7)
                STODL           RDOT
                                DP0
                STORE		GEFF				# GEFF=0
                STORE           YDOT                            # YDOT=0
                SET             GOTO
                                56D				# SET FOR RETURN
                                GAIN	+1			# GO TO USE ASCENT TGO SECTION
TKNOWN          DLOAD           DAD
                                RDOTD
                                RDOT                            # (RDOT+RDOTD)*2(-7)
                SR1             DMP                             #  .5RDOTAVE*2(-7)
                                TGO                             # RGO*2(-24),SINCE TGO IS *2(-17)
                DAD             SR1                             # RFREE IS RCO FOR NO R-CONTROL,*2(-24)
                                RMAG                            #  *2(-25)
                DSU             BPL
                                RCO
                                FREE-R
                CLEAR           GOTO                            # IF RFREE SMTHAN RCO, CONSTRAIN RCO
                                HC
                                ASCENT
FREE-R          SET             GOTO
                                HC                              # IF RFREE GRTHAN RCO, FREE RCO
                                ASCENT
PREKALC4        VLOAD           
## Page 659
                                UT				# GET UT FROM ASCENT OUTPUT REGISTER
                STOVL           POINTVSM                        # KALCMANU INPUT REGISTER
                                BODYVECT                        # LOAD BODY AXES VECTOR IN SM COORDS
                STORE           SCAXIS                          # KALCMANU INPUT VECTOR
                SET             SSP
                                33D

                                RATEINDX
                                6                               # 10 DEG/SEC.
                EXIT

                TCF             ENDOFJOB                        # END LONGJOB

TIG4-41         CAF             AVGENADR                        # GENADR OF AVERAGEG
                TS              DVSELECT

                EXTEND
                DCA             EXITADR                         # SET AVEG TO EXIT TO END OF JOB UNTIL
                DXCH            AVGEXIT                         # IT IS RESET TO ATMAG

                EXTEND
                DCA             MP4TM1AD                        # SET MONITOR EXIT
                DXCH            DVMNEXIT

                TC              1LMP+DT
                DEC             4                               # ED BATTERY ACTIVATION-ON
                DEC             400                             # DELAY 4 SECONDS

TIG4-37         TC              IBNKCALL                        # +X TRANSLATION- OFF
                CADR            NOULLAGE

                TC              IBNKCALL
                CADR            STOPRATE                        # HOLD VEHICLE ATTITUDE

                TC              FIXDELAY
                DEC             100                             # DELAY ONE SECOND

TIG4-36         TC              1LMP
                DEC             8                               # LANDING GEAR DEPLOY-FIRE

                CAF             002CEK
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           TIG4-34

                CAF             PRIO30                          # CALL KALCMANU
                TC              FINDVAC
                EBANK=          MIS
                2CADR           VECPOINT

## Page 660
                TCF             TASKOVER                        # END TIG4-36 TASK

TIG4-34		CS		030CEK				# SET PREREAD CALL (AUTO LASTBIAS)
		TC		TASKSETR
                TC              WAITLIST
                EBANK=          DVTOTAL
                2CADR           PREREAD

                TC              1LMP+DT
                DEC             9                               # LANDING GEAR DEPLOY- FIRE RESET
                DEC             402                             # DELAY 4 SECONDS

TIG4-30         TC              ENGINOF1			# REMOVE EXTRANEOUS ENGINE DISCRETES

                TC              2LMP+DT
                DEC             150                             # ENGINE SELECT- DESC ARM
                DEC             86                              # MANUAL THROTTLE- ON 10 PERCENT
                DEC             1398                            # DELAY 14 SECONDS

TIG4-16         TC              2LMP+DT
                DEC             228                             # DPS PQGS ARM NO 1 - ENABLE
                DEC             196                             # DPS PQGS ARM NO 2- ENABLE
                DEC             100

TIG4-15         TC              2LMP+DT
                DEC             244                             # DPS PQGS NO 1- ON
                DEC             212                             # DPS PQGS NO 2- ON
                DEC             750                             # DELAY 7.5 SECONDS

TIG4-7.5        TC              IBNKCALL                        # +X TRANSLATION- ON
                CADR            ULLAGE

                TC              FIXDELAY
                DEC             750                             # DELAY 7.5 SECONDS

                CAF             PRIO31				# SET UP JOB FOR ATTSTAL
                TC              NOVAC
                EBANK=          TDEC
                2CADR           IGNTEST

                TCF             TASKOVER

IGNTEST         TC              BANKCALL                        # WE WAIT UNTIL KALCMANU IS HAPPY
                CADR            ATTSTALL
                TC              CURTAINS

MP4IGN          TC		ENGINEON			# IGNITE DPS ENGINE

		CAF		THRSTADR			# DECLARE EBANK= 6
		TS		EBANK
## Page 661
		EBANK=		THRSTCMD
		
		CAF		10PERTHR			# REPORT EXPECTED THRUST TO DAP
		TS		THRSTCMD
		
		INHINT
                CAF             003CEK
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP4IGN+3

                TCF             ENDOFJOB

MP4IGN+3        TC              IBNKCALL                        # +X TRANSLATION- OFF
                CADR            NOULLAGE

                TC              1LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION- SAFE
                DEC             2300                            # DELAY 23 SECONDS

MAXTHRST        CAF             POSMAX                          # CALL FOR 92.5 PERCENT THRUST
                TS              PCNTF
                EXTEND
                DCA             PCNTFMAD
                DTCB
                
                CAF		92PERTHR			# REPORT EXPECTED THRUST TO DAP
                TS		THRSTCMD
                
                CAF		TDECADR				# DECLARE EBANK= 4
                TS		EBANK
                EBANK=		TDEC

                TC              FIXDELAY
                DEC             100                             # DELAY ONE SECOND

GUIDANCE        EXTEND                                          # TUNE IN ASCENT GUIDANCE
                DCA             ATMAG4
                DXCH            AVGEXIT

                CAF             CDUJOBAD
                TS              ASCRET

                TCF             TASKOVER

MP4TERM1	EXTEND
		DCA		EXITADR				# RESET AVERAGE G EXIT
		DXCH		AVGEXIT
		
		TC		BANKCALL
## Page 662

		CADR		STOPRATE			# HOLD VEHICLE ATTITUDE
		
	        INHINT
                CAF             005CEK
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           TCO+5

                TCF		ENDOFJOB

TCO+5           TC              2LMP+DT
                DEC             151                             # ENGINE SELECT-DESC ARM-OFF
                DEC             87                              # MANUAL THROTTLE-RESET (30 PERCENT)
                DEC             100                             # DELAY ONE SECOND

                TC              IBNKCALL                        # SET MAXIMUM DEADBAND
                CADR            SETMAXDB

                TC              FIXDELAY
                DEC             900                             # DELAY NINE SECONDS

TCO+15          TC              2LMP+DT
                DEC             245                             # DPS PQGS NO 1- OFF
                DEC             213                             # DPS PQGS NO 2- OFF
                DEC             100

                TC              2LMP+DT
                DEC             229                             # DPS PQGS ARM NO 1- DISABLE
                DEC             197                             # DPS PQGS ARM NO 2- DISABLE
                DEC             1400                            # DELAY 14 SECONDS

                TC              FLAG1DWN                        # TERMINATE AVEG AND DO AUTO AVETOMID
                OCT             1

                CS		FOUR				# ALLOW AVEG TO POOH IF IT WANTS TO.
                TS		PHASENUM

                TCF             TASKOVER

# ************************************************************************
# TIME INCREMENTS FOR WAITLISTS IN MP4 - XXXXXCEK = DEC XXXXX00 CS
# ************************************************************************
002CEK          DEC             200

003CEK          DEC             300

005CEK          DEC             500

007CEK          DEC             700
## Page 663

021CEK          DEC             2100

030CEK          DEC             3000

XTRANSON        OCT             00252                           # CHANNEL 5 CODE FOR 4-JET TRANSLATION

10PERTHR	DEC		1050

92PERTHR	DEC		9710

# ************************************************************************
# CONSTANTS FOR PRECOI CALCULATIONS AND FOR INITIALIZATION OF ASCENT EO.
# ************************************************************************
ABLOCK          2DEC            2.8420		E-4 B9		# MAXACC92

                2DEC            3.3788 		E-2 B4		# 1/EXVEL

                2DEC            1.0413		E5 B-17		# TBUP4

BBLOCK          2DEC            0				# ACCSTEP

                2DEC            0				# ACCSTEP +2

KREST           2DEC            0.95

KR1EST          2DEC            0.31

TGOEST          2DEC            50000           B-17

BODYVECT        2DEC            .5

CBLOCK          2DEC            0                               # RDOTD

                2DEC            0                               # YDOTD
                
                2DEC		7.8397245 E1 B-7
                
RCRIT		2DEC*		6.5355846 E6 B-24*

# ************************************************************************
# GENADRS, ECADRS, AND 2CADRS USED IN MP4
# ************************************************************************

AVGENADR        GENADR          AVERAGEG

TDECADR		ECADR		TDEC				# FOR EBANK= 4

MASSADR		ECADR		MASSES				# FOR EBANK= 5

## Page 664
THRSTADR	ECADR		THRSTCMD			# FOR EBANK= 6

                EBANK=          TDEC
MP4TM1AD        2CADR           MP4TERM1

                EBANK=          TDEC
EXITADR         2CADR           SERVEXIT

                EBANK=          AMEMORY
ORBINTAD        2CADR           MIDTOAVE

                EBANK=          ETHROT
PCNTFMAD        2CADR           PCNTFMAX

                EBANK=          TDEC
ATMAG4          2CADR           ATMAG

		EBANK=		TDEC
WACTTHTD	2CADR		ENDOFJOB

KALC4AD         FCADR           PREKALC4

CDUJOBAD        FCADR           FINDCDUD

# ************************************************************************
# TASKSETR SUBROUTINE - NOT YET AVAILABLE TO OTHER FIXED BANKS

# ************************************************************************

TASKSETR        INHINT
		EXTEND
                QXCH            TEMX
                TS              L
                CAF             ZERO
                DXCH            MPAC
                DXCH            RUPTREG1
                CAF             ZERO
                XCH             MPAC            +2
                TS              RUPTREG3
                EXTEND
                DCS             TIME2
                DAS             MPAC
                CA		EBANK
                TS		TEMY
                CAF		TDECADR
                TS		EBANK
                EXTEND
                DCA             TDEC
                DAS             MPAC
                TC              TPAGREE
                CA              RUPTREG3
## Page 665                
                TS              MPAC            +2
                DXCH            RUPTREG1
                DXCH            MPAC
                EXTEND
                BZF             +3
                TC              ABORT
                OCT             00404
                XCH             L
                EXTEND
                BZMF            -4
                LXCH            TEMY
                LXCH            EBANK
                RELINT
                TC              TEMX
# ************************************************************************
