### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MISSION_PHASE_2_GUIDANCE_REFERENCE_RELEASE_PLUS_BOOST_MONITOR.agc
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
## Reference:   pp. 632-643
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-13 RSB	Transcribed.
##              2017-06-13 HG   Fix operator DXCH ->QXCH
##                              Fix operator REFSSMAT -> REFSMMAT
##                              Fix comment (missing #) near label SHOW12
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 632
# PROGRAM NAME - MISSION PHASE 2 GUIDANCE REFERENCE RELEASE + BOOST MONITOR.

# MODIFICATION NUMBER - 1         DATE - NOVEMBER 22, 1966                MODIFICATION BY - COVELLI



# FUNCTIONAL DESCRIPTION -

#    THE FUNCTION OF MISSION PHASE 2 IS TO CONTROL THE SEQUENCE OF EVENTS IN THE 206 FLIGHT FROM GUIDANCE
# REFERENCE RELEASE THROUGH LIFTOFF TO THE SIVB BOOSTER SHUTDOWN.

#    AT GUIDANCE REFERENCE RELEASE, THE GRR FLAG IS SET,  PREREAD IS CALLED TO BEGIN COMPUTATION OF POSITION AND
# VELOCITY, AND CALLS ARE MADE FOR DFI T/M CALIBRATION AND LIFTOFF

#    WHEN PRELAUNCH DETECTS THAT THE GRR FLAG IS SET, IT TERMINATES GYROCOMPASSING AND CALLS MP2JOB. MP2JOB
# DISPLAYS 7 IN THE MAJOR MODE AND GOES TO MATRXJOB TO COMPUTE REFSMMAT.

#    AT LIFTOFF, THE LGC CLOCK IS ZEROED, CALLS ARE MADE FOR THE COLD FIRE PURGE AND POST LET JETTISON PROGRAMS.
# THE MAJOR MODE IS CHANGED TO 11.

#    AT POST LET JETTISON, THE DV MONITOR IS ENABLED TO DETECT BOOSTER SHUTDOWN, THE ABORT COMMAND MONITOR AND THE
# TUMBLE MONITOR ARE ENABLED, AND THE MAJOR MODE IS CHANGED TO 12.

#    THE VARIOUS LMP COMMANDS REQUIRED FOR MP2 ARE SCHEDULED BY WAITLIST CALLS.

#    AT DETECTION OF SIVB SHUTDOWN, AN EXECUTIVE CALL IS MADE TO MISSION PHASE 6.



# CALLING SEQUENCE :

#    MISSION PHASE 2 IS BEGUN UPON RECEIPT OF THE GUIDANCE REFERENCE RELEASE SIGNAL (VERB 65 ENTER) VIA UPLINK.



# SUBROUTINES CALLED :

#          PREREAD                1LMP
#          TUMTASK                2LMP
#          NEWMODEX               PHASCHNG
#          FINDVAC                NEWPHASE
#          NOVAC                  DFITMCAL
#          SPVAC                  IBNKCALL
#          WAITLIST
#          LONGCALL



# NORMAL EXIT MODES :
## Page 633
#    EXIT TO MISSION PHASE 6 AT SIVB SHUTDOWN.



# ABORT EXIT MODES :

#    TO MISSION PHASE 3 IF SUBORBITAL ABORT COMMAND RECEIVED VIA UPLINK.
#    TO MISSION PHASE 4 IF CONTINGENCY ORBIT INSERTION COMMAND RECEIVED VIA UPLINK.

#    TO CHARALRM IF EITHER OF THE ABOVE ABORT COMMANDS RECEIVED WHILE ABORT COMMAND MONITOR NOT ENABLED.



# OUTPUT :

#          TGRR          TIME OF GUIDANCE REFERENCE RELEASE
#          TPRELTER      TIME OF GYROCOMPASSING TERMINATION
#          TLIFTOFF      TIME OF LIFTOFF AND LGC CLOCK ZEROING
#          GRR FLAG      BIT2 FLAGWRD1 SET TO INDICATE GRR SIGNAL RECEIVED
#          SERVICER IS GOING AT END OF MISSION PHASE 2
## In the printout, the next two lines, "R000052" and "R000053" are overprinted and not 
## entirely legible.  The text of the following line has thus been taken from the 
## corresponding line in SUNBURST 120. &mdash; RSB
#          MAJOR MODE DISPLAYS
# ERASABLE INITIALIZATION :

#	   DT-DFITM	 DELTA TIME FROM GRR TO DFI T/M CALIBRATION, SINGLE PRECISION SCALED AT 2(+14) CS.
#          DT-LIFT       DELTA TIME FROM GRR TO LIFTOFF, DOUBLE PRECISION SCALED AT 2(+28) CS.
#          DT-LETJT      DELTA TIME FROM LIFTOFF TO POST LET JETTISON, DOUBLE PRECISION SCALED AT 2(+28) CS.
#          RAVEGON       POSITION AT GRR IN SM CO-ORDINATES, VECTOR SCALED AT 2(+24) M.
#          VAVEGON       VELOCITY AT GRR IN SM CO-ORDINATES, VECTOR SCALED AT 2(+7) M/CS.

# ********  ALL OF THE ERASABLE INITIALIZATION MUST BE DONE DURING THE PRE-LAUNCH ERASABLE LOAD  *****************



# DEBRIS :

#    CENTRALS AND EXECUTIVE WORK AREA.



                BANK            27
                EBANK=          TGRR



GRRPLACE        CAF		THREE			# COME HERE ON VERB 65 - GRR
		TC		NEWPHASE
		OCT		00002
## Page 634
		INHINT
		CA		MP2BBSET		# SET BBCON FOR MP2
		TS		BBANK
		
		EXTEND
		DCA		TIME2
		DXCH		TGRR			# SAVE TIME OF GUIDANCE REFERENCE RELEASE
		
		CS		FLAGWRD1
		MASK		BIT2
		ADS		FLAGWRD1		# GET GRR FLAG  BIT2  FLAGWRD1
		
		CA		DT-DFITM
		TC		WAITLIST		# SET UP DFI T/M CALIBRATION ROUTINE
		EBANK=		TGRR
		2CADR		PREDFITM
		
		EXTEND
		DCA		DT-LIFT
		TC		LONGCALL		# SET UP CALL TO LIFTOFF PROGRAM
		EBANK=		TGRR
MP2BBS-1	2CADR		LIFTOFF

		CA		AVEGADRS
		TS		DVSELECT
		
		EXTEND
		DCA		SVEXADRS
		DXCH		AVGEXIT
		
		EXTEND
		DCA		SVEXADRS
		DXCH		DVMNEXIT
		
		CA		ONE
		TC		WAITLIST
		EBANK=		DVTOTAL
		2CADR		BIBIBIAS		# START SERVICER WITH NO LAST BIAS
		
		CAF		ZERO
		TC		NEWPHASE
		OCT		00002
		CAF		EBANK4
		TS		Q			# E4 IN Q
		EXTEND
		DCA		TGRR			# IN A,L
		EXTEND
		QXCH		EBANK			# SWITCH EBANK, SAVE OLD IN Q
		EBANK=		TEVENT
		DXCH		TEVENT			# SET TGRR IN TEVENT
## Page 635		
		EBANK=		TGRR
		EXTEND
		QXCH		EBANK			# RESTORE EBANK
		
		TCF		ENDOFJOB
		
MP2BBSET	EQUALS		MP2BBS-1	+1	# BBCON FOR MP2


MP2JOB		TC		PHASCHNG
		OCT		01022			# PICK UP HERE ON RESTART
		
		CAF		TWO			# SET 2 IN MISSION PHASE REGISTER
		TS		PHASENUM
		
		EXTEND
		DCA		TEMTPREL		# SAVE TIME OF PRELAUNCH TERMINATION
		DXCH		TPRELTER
		
SHOW7		TC		NEWMODEX		# DISPLAY 7 IN MAJOR MODE
		OCT		00007
		
# GO TO MATRXJOB TO COMPUTE REFSMMAT				

## Page 636
# PROGRAM DESCRIPTION- MATRXJOB                                           DATE- 18 NOV 1966
# MOD NO- 1                                                               LOG SECTION- MP 2 GRR + BOOST MONITOR
# MOD BY- LICKLY, KERNAN                                              	  ASSEMBLY- SUNBURST REVISION 8

# FUNCTIONAL DESCRIPTION

#          THIS PROGRAM CONSTRUCTS THE MATRIX WHICH RELATES THE STABLE MEMBER INERTIAL FRAME TO THE REFERENCE
# FRAME (Z NORTH, X ALONG THE VERNAL EQUINOX.)

#          TWO INTERMEDIATE COORDINATE SYSTEMS ARE USED: A LOCAL, EARTH FIXED, VERTICAL, SOUTH, EAST SYSTEM AND AN
# EARTH REFERENCE X, Y, Z SYSTEM.  IN THIS LATTER SYSTEM, THE Z AXIS IS THE EARTH'S ROTATION AXIS, THE X AXIS IS
# NORMAL TO Z IN THE PLANE OF Z AND THE LOCAL VERTICAL, POSITIVE IN THE DIRECTION OF V.  Y IS Z CROSS X.

#          THE FIRST COMPUTATION IS OF AZGR, THE ANGLE BETWEEN THE REFERENCE INERTIAL AND EARTH REFERENCE X-Z
# PLANES (THE Z AXES ARE COINCIDENT).  AZGR IS COMPUTED BY CONVERTING THE TIME FROM THE BEGINNING OF THE EPHEMERIS
# YEAR TO RELEASE (TEPHEM + TPRELTER) TO REVOLUTIONS (DAYS).  THE WHOLE REVS ARE DISCARDED AND THE INITIAL ANGLE
# (AZ0) BETWEEN THE GREENWICH MERIDIAN AND THE REFERENCE X-Z PLANES IS ADDED.  ADDING THE LONGITUDE YIELDS AZGR.

#          THE FOLLOWING COMPUTATIONS ARE THEN PERFORMED.

# LOCAL VERTICAL(ER) = COS(LATITUDE), 0, SIN(LATITUDE)  IN EARTH REFERENCE

# LOCAL VERTICAL(IR) = COS(LAT)COS(AZGR), COS(LAT)SIN(AZGR), SIN(LAT)  IN INERTIAL REFERENCE

# LOCAL EAST(IR) = NXV = -COS(LAT)SIN(AZGR), COS(LAT)COS(AZGR), 0  IN INERTIAL REFERENCE

# LOCAL SOUTH(IR) = E(IR) X V(IR)

#          THE RELATIONSHIP OF THE STABLE MEMBER AXES TO THE V, S, E AXES IS GIVEN BY ZSMAZ, THE ANGLE FROM NORTH
# TO ZSM, AND TILT, THE ANGLE ABOUT ZSM FROM VERTICAL TO XSM.

# ZSM(IR) = EAST(IR)COS(ZSMAZ - 90) + SOUTH(IR)SIN(ZSMAZ - 90)

# YSM(IR) = (ZSM(IR) X V(IR))COS(TILT) - V(IR)SIN(TILT)

# XSM(IR) = YSM(IR) X ZSM(IR)

#          THESE THREE HALF-UNIT VECTORS, XSM(IR), YSM(IR), AND ZSM(IR) ARE THE SM AXES EXPRESSED IN INERTIAL
# REFERENCE COORDINATES AND THEY FORM REFSMMAT, THE REFERENCE TO STABLE MEMBER MATRIX.

# THE INPUT (PRELAUNCH ERASABLE LOAD) REQUIREMENTS ARE:

# 1) TEPHEM       THE TRIPLE PRECISION TIME IN CENTISECONDS FROM MIDNIGHT JULY 1, OF THE EPHEMERIS YEAR TO
# MIDNIGHT OF THE LAUNCH DAY (SIDEREAL CONVERTED TO MEAN SOLAR.)

#    IT IS ASSUMED THAT DURING THE LAUNCH COUNTDOWN THE LGC CLOCK (TIME2, TIME1) WILL BE ALIGNED TO REFLECT A
# ZERO VALUE AT MIDNIGHT OF THE LAUNCH DAY.  IF NOT, THE DIFFERENCE MUST BE ADDED TO TEPHEM.

# 2) TILT         THE ROTATION OF XSM ABOUT ZSM (RIGHT HAND RULE) FROM VERTICAL IN REVOLUTIONS.

## Page 637
# 3) ZSMAZ        THE ANGLE FROM NORTH TO ZSM IN REVOLUTIONS.

# THE OUTPUTS OF THIS PROGRAM ARE:

# 1) REFSMMAT     THE HALF-UNIT MATRIX WHICH TRANSFORMS FROM REFERENCE INERTIAL TO SM INERTIAL.

# 2) AZGR         THE ANGLE BETWEEN PAD 37 B VERTICAL AND THE REFERENCE X-Z PLANE IN REVOLUTIONS.

# CALLING SEQUENCE : CONTINUATION OF MP2JOB
# NORMAL EXIT MODE-   TC  ENDOFJOB

# ALARM OR ABORT EXITS-  NONE

# DEBRIS-  SPECIALS, CENTRALS AND EXECUTIVE WORK AREA.

MATRXJOB        TC		INTPRET
		DLOAD           SR
                                TPRELTER                        # MAKE ALIGN STOP TIME TP.
                                14D
                TAD             RTB
                                TEPHEM                          # TP CS FROM JULY 1 TO LAUNCH DAY.
                                TPMODE                          # SET STORE MODE TO TRIPLE.
                STORE           20D                             # TP CS FROM JULY 1 TO RELEASE.
                SLOAD           NORM
                                20D
                                X1                              # -9 OR -10.
                DMP             RTB
                                WEARTH                          # REVS PER 2(28)CS.
                                SGNAGREE
                SR*             PDDL
                                0               -19D,1          # GETS RID OF WHOLE REVS.
                                21D
                DMP             RTB
                                WEARTH
                                SGNAGREE
                SLR             DAD
                                5                               # DP FRACTION OF A REV.
                DAD             DAD
                                AZ0                             # MERIDIAN ANGLE AT JULY 1.
                                P37BLONG                        # PAD ANGLE TO MERIDIAN.
                STORE           AZGR                            # VERT. AZ. AT RELEASE WRT X-Z INERTIAL.

                SIN
                PDDL		COS
                		AZGR
                PDDL		SIN
                		P37BLAT				# LOCAL VERTICAL Z IN EARTH REF. SIN(L).
                STODL           REFSMMAT        +4              # ALSO LOCAL VERT Z IN REF. INERTIAL.
                                P37BLAT
                COS             SL1                             # SAVES 2 SL'S LATER.
## Page 638
                STORE           20D                             # LOCAL VER. X IN EARTH REF.  COS(L).
                DMP		STADR
                STORE		REFSMMAT			# LOCAL VERT X IN INERTIAL = COS(L)COS(AZ)
                STODL		MPAC            +3		# ALSO Y OF EAST IN INERTIAL.
                		DPZRO
                STODL           MPAC		+5		# Z OF EAST IN INERTIAL = 0.
                DMP
                                20D
                STORE           REFSMMAT        +2              # LOCAL VERT Y IN INERTIAL=COS(L)SIN(AZ).
                DCOMP           RTB                             # ALSO -X OF EAST IN INERTIAL.
                                VECMODE                         # SET STORE MODE TO VECTOR.
                PUSH            VXV                             # EAST INTO PD.
                                REFSMMAT
                UNIT                                            
                STODL           REFSMMAT        +12D            # UNIT SOUTH IN INERTIAL INTO REF +12TEMP
                                ZSMAZ                           # ZSM WRT NORTH.
                DSU		PUSH				# AZ - 90 = ANG INTO PD.
                		90DEG
                SIN             VXSC
                                REFSMMAT        +12D            # (STH)SIN(ANG) INTO R +12D (TEMP).
                STODL		REFSMMAT	+12D		# ANG FROM PD.
                COS		VXSC				# EAST FROM PD.
                VAD		UNIT
                		REFSMMAT	+12D
                STORE		REFSMMAT	+12D		# ZREFSM = (E)COS(ANG) + (STH)SIN(ANG).
                                
                VXV             UNIT
                                REFSMMAT                        # YREFSM(UNTILTED)= Z CROSS VERT = Y1.
                PDDL            COS                             # INTO PD.
                                TILT                            # TILT IS POS ABOUT ZSM FROM UNTILTED YSM.
                VXSC
                PDDL            SIN                             # (Y1)COS(T) INTO PD.
                                TILT
                VXSC            BVSU
                                REFSMMAT
                UNIT
                STORE           REFSMMAT        +6              # YREFSM = (Y1)COS(T) - (VERT)SIN(T).

                VXV             UNIT
                                REFSMMAT        +12D
                STORE           REFSMMAT                        # XREFSM = Y CROSS Z.
                EXIT

                TC              PHASCHNG
                OCT             00072                           # RESTART PREDFITM
                TC              ENDOFJOB

PREDFITM	TC		PHASCHNG
		OCT		40042				# PROTECT WAITLIST CALL TO PROG11

## Page 639
DFITMTSK	TC		IBNKCALL
		CADR		DFITMCAL
		
		TCF		TASKOVER

DFITMCAL        TC              1LMP                            # MUST BE CALLED BY IBNKCALL (OR ISWCALL)
                DEC             236                             #   IN INTERRUPT OR INHIBITED
                CA              12SEC
                TC              WAITLIST                        # CALL DFITMCL1 IN 12 SECONDS
                EBANK=          TGRR
                2CADR           DFITMCL1

                TCF             ISWRETRN

DFITMCL1        TC              2LMP
                DEC             237                             # DFI T/M CALIBRATE OFF
                DEC             198                             # MASTER C+W ALARM RESET - COMMAND
                TC              PHASCHNG
                OCT		40113                           # PROTECT DFITMCL2

		CA		200CS
		TC		WAITLIST			# CALL DFITMCL2 IN 2 SECONDS
		EBANK=		TGRR
		2CADR		DFITMCL2
		
		TCF		TASKOVER

DFITMCL2        TC              1LMP
                DEC             199                             # MASTER C+W ALARM RESET - COMMAND RESET
                CA		ZERO
                TC		NEWPHASE
                OCT		00003				# GROUP 3 INACTIVE
                TCF             TASKOVER

LIFTOFF		EXTEND
		DCA		TIME2
		DXCH		TLIFTOFF			# SAVE TIME OF LIFTOFF
		
		TC		PHASCHNG
		OCT		01013				# PICK UP HERE ON RESTART
		
		CA		ZERO
		TS		L
		DXCH		TIME2				# ZERO TIME2, TIME1
		
		TC		PHASCHNG
		OCT		40062				# PROTECT RCSPURGE AND SHOW11
		
		CA		105SEC

## Page 640
		TC		WAITLIST			# CALL RCSPURGE IN 105 SECONDS
		EBANK=		TGRR
		
		2CADR		RCSPURGE
		
		EXTEND
		DCA		DT-LETJT
		TC		LONGCALL
		EBANK=		TGRR
		2CADR		POSTLET
		
		CA		PRIO20
		TC		NOVAC
		EBANK=		TGRR
		2CADR		SHOW11
		
		CAF		EBANK4
		TS		Q				# E4 IN Q
		EXTEND
		DCA		TLIFTOFF			# IN A,L
		EXTEND
		QXCH		EBANK				# SWITCH EBANK, SAVE OLD IN Q
		EBANK=		TEVENT
		DXCH		TEVENT				# SET TLIFTOFF IN TEVENT
		EBANK=		TGRR
		EXTEND
		QXCH		EBANK				# RESTORE EBANK
		
		TCF		TASKOVER
		
SHOW11		TC		NEWMODEX
		OCT		00011				# DISPLAY 11 IN MAJOR MODE
		
		TC		PHASCHNG
		OCT		00132				# PROTECT RCSPURGE
		TCF		ENDOFJOB

RCSPURGE        CA              +XJETSON
                EXTEND
                WRITE           5                               # TURN ON +X TRANSLATION

		CA		75SEC
		TC		WAITLIST			# CALL +X TRANSLATION OFF IN 75 SECONDS
		EBANK=		TGRR
		2CADR		PURGEOFF

                TCF             TASKOVER


POSTLET         CA		BOOSTADR			# MONITOR DELV FOR BOOSTER SHUTDOWN
		TS		DVSELECT	
## Page 641		

		CS              FLAGWRD2                        # ENABLE ABORT COMMAND MONITOR
                MASK            BIT9                            # BIT 9  FLAGWORD 2
                ADS             FLAGWRD2

                CA              BIT1
                TC              WAITLIST                        # ENABLE TUMBLE MONITOR
                EBANK=          OMEGA
                2CADR           TUMTASK

		
		CA		PRIO20
		TC		NOVAC
		EBANK=		TGRR
		2CADR		SHOW12
		
		TCF		TASKOVER
		
SHOW12		TC		NEWMODEX
		OCT		00012				# DISPLAY 12 IN MAJOR MODE
		TCF		ENDOFJOB		

PURGEOFF        CA              ZERO
                EXTEND
                WRITE           5                               # TURN OFF RCS JETS

                TC              1LMP
                DEC             186                             # ECS PRIMARY WATER VALVE OPEN

		TC		PHASCHNG
		OCT		40172				# PROTECT WATEROFF
		
		CA		200CS
		TC		WAITLIST			# CALL WATEROFF IN 2 SECONDS
		EBANK=		TGRR
		2CADR		WATEROFF
		
		TCF		TASKOVER

WATEROFF        TC              1LMP
                DEC             187                             # ECS PRIMARY WATER VALVE - OPEN RESET
                TC              PHASCHNG
                OCT             00002                           # GROUP 2 INACTIVE

                TCF             TASKOVER                        # END OF MISSION PHASE 2

                
                                                                # DELTA T S AND OTHER CONSTANTS FOR MP2
AVEGADRS        GENADR          AVERAGEG
BOOSTADR        GENADR          BOOSTMON
## Page 642
SVEXADRS        EQUALS          SVEXITAD
200CS		DEC		200
12SEC           DEC             1200
75SEC		DEC		7500
105SEC		DEC		10500
WEARTH          2DEC            31.1539787      B-5             # REVOLUTIONS PER 2(28) CENTISECONDS.

AZ0		2DEC		0				# TEMP

P37BLONG	2DEC		.77620852			# 80 DEG 33 MIN 53.76306 SEC WEST

P37BLAT		2DEC		.079252160			# 28 DEG 31 MIN 50.79945 SEC NORTH

90DEG		2DEC		.25

+XJETSON        OCT             00252                           # BITS FOR +X TRANSLATION JETS


                                                                # ABORT COMMAND MONITOR - DETECTS
                                                                # SUBORBITAL ABORT AND CONTINGENCY
                                                                # ORBIT INSERTION

SUBABORT        INHINT                                          # SUBORBITAL ABORT - ZERO ABORTNDX TO
                CAF             ZERO                            # SET UP MISSION PHASE 3
                TCF             CONORBIT        +2

CONORBIT        INHINT                                          # CONTINGENCY ORBIT INSERTION - ABORTNDX
                CAF             TWO                             # SET TO 2 TO SET UP MISSION PHASE 4
                TS              L                               # SAVE IN L
                CAF		BIT9				# CHECK WHETHER ABORT COMMAND MONITOR IS
                MASK		FLAGWRD2			# ENABLED
                EXTEND
                BZF		BADCHAR				# IF NOT, GO TO BADCHAR
                CAF		EBANK3				# SET EBANK
                TS		EBANK
                LXCH		ABORTNDX			# STORE ABORTNDX
                CAF		AVEGADRS
                
                TS		DVSELECT			# TURN OFF BOOSTMON
                EXTEND
                DCA		ABORTRET			# SET UP TO RETURN TO ABORTRTN
                DXCH		FLUSHREG
                TC		POSTJUMP
                CADR		ENEMA				# WIPE EVERYTHING OUT
                
                
ABORTRTN	INHINT
		EXTEND
		DCA		ENDJOBC2			# CLEAR FLUSHREG
## Page 643		
    		DXCH		FLUSHREG
    		
    		CAF		BIT1
    		TC		WAITLIST			# RE-ESTABLISH TUMBLE MONITOR
    		EBANK=		OMEGA
    		2CADR		TUMTASK
    		
    		CAF		PRIO27
    		TS		NEWPRIO				# SET UP MP3 OR MP4 VIA SPVAC
                
                EXTEND
                INDEX           ABORTNDX                        # GET RIGHT 2CADR
                DCA             MP3-4ADR
                TC              SPVAC                           # SET UP JOB
                TCF             ENDOFJOB


                EBANK=          TDEC
MP3-4ADR        2CADR           MP03JOB                         # DO NOT CHANGE THE ORDER OF THESE 2 CARDS

                EBANK=          TDEC
                2CADR           MP4JOB                          # THEY ARE IN AN INDEXED TABLE

BADCHAR		RELINT
		TC		POSTJUMP			# ILLEGAL CHARACTER    BACK TO PINBALL
		CADR		CHARALRM

                EBANK=          TDEC                            # LEFT-OVERS FROM DELETED MISSION PHASE 18
MIDAVEAD        2CADR           MIDTOAVE

                EBANK=          TDEC
SVEXITAD        2CADR           SERVEXIT


		EBANK=		ABORTNDX
ABORTRET	2CADR		ABORTRTN

		EBANK=		ABORTNDX
ENDJOBC2	2CADR		ENDOFJOB
