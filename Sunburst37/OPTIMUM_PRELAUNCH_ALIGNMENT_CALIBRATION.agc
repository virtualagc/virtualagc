### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##		2016-10-18 RSB	Transcribed by correcting Aurora 12 version of 
##				this file.
##		2016-10-31 RSB	Typos.
##		2016-11-01 RSB	More typos.
##		2016-12-05 RSB	Comment-proofing with octopus/ProoferComments
##				completed, changes made.

## Page 450
# PROGRAM NAME-OPTIMUM PRELAUNCH ALIGNMENT CALIBRATION
# DATE- NOVEMBER 2  1966
# BY- GEORGE SCHMIDT IL 7-146 EXT. 126
# MOD NO 2
# FUNCTIONAL DESCRIPTION

# THIS LOG SECTION CONSISTS OF PRELAUNCH ALIGNMENT AND GYRO DRIFT TESTS
# INTEGRATED TOGETHER TO SAVE WORDS. IT IS COMPLETELY RESTART PROOFED.
# THE PRELAUNCH ALIGNMENT TECHNIQUE IS BASICALLY THE SAME AS IN BLOCK 1
# EXCEPT THAT IT HAS BEEN SIMPLIFIED IN THE SENSE THAT SMALL ANGLE APPROX.
# HAVE BEEN USED. THE DRIFT TESTS USE A UNIQUE IMPLEMENTATION OF THE
# OPTIMUM STATISTICAL FILTER. FOR A DESCRIPTION SEE E-1973.BOTH OF THESE
# ROUTINES USE STANDARD SYSTEM TEST LEADIN PROCEDURES. THE INITIALIZATION
# PROCEDURE FOR THE DRIFT TESTS IS IN THE JDC S. THE INITIALIZATION METHOD
# FOR GYROCOMPASS IS IN A STG MEMO FOR EACH ASSEMBLY.
# THIS LOG SECTION ALWAYS STARTS BY A CADR IN IMU PERF. TESTS 2 AND BEGINS
# AT ESTIMS. THE PIPS ARE READ EVERY .5 SEC IN COMPASS AND 1 SEC IN DRIFT
# TESTS. THEN IN BOTH CASES RELEVANT COMPUTATION IS DONE. THE KEY ERASABLE
# IS GEOCOMPS- 0 WE ARE IN A DRIFT TEST -NONZERO WE ARE IN COMPASS.
# THE GYROCOMPASS HAS THE CAPABILITY TO ALIGN TO ANY ORIENTATION,HAS THE
# CAPABILITY TO BE COMPENSATED FOR
# COMPONENT ERRORS,IS CAPABLE OF OPTICAL VERIFICATION( CSM ONLY).

# SUBROUTINES CALLED

# EARTHR, CALGTA,  OGC ZERO,ERTHRVSE,GCOMPZERO AND
# IMU COMPENSATION
# DURING OPTICAL VERIFICATION (CSM ONLY) ESSENTIALLY ALL OF INFLIGHT ALIGN
# IS CALLED IN ONE WAY OR ANOTHER. SEE THE LISTING.

# NORMAL EXIT

# DRIFT TESTS- LENGTHOT GOES TO ZERO-RETURN TO IMU PERF TEST2 CONTROL
# GYROCOMPASS-GRR RECEIVED OR G LEVEL EXCEEDS GLIFTOFF-START UP MP 2
#                                                      206 IMPLEMENTATION

# ALARMS

# 1600     OVERFLOW IN DRIFT TEST
# 1601     BAD IMU TORQUE ABORT
# 1602     BAD OPTICS DURING VERIFICATION-RETURN TO COMPASS      CSM ONLY

# OUTPUT

# DRIFT TESTS- FLASHING DISPLAYS OF RESULTS-CONTROLLED IN IMU PERF TESTS 2
# COMPASS-PROGRAM MODE LIGHTS TELL YOU WHAT PHASE OF PROGRAM YOU ARE IN
#    01    INITIALIZING THE PLATFORM POSITION AND ERASABLE
#    02    GYROCOMPASSING
#    03    DOING OPTICAL VERIFICATION (CSM)
#    04    GRR SIGNAL RECEIVED FINISH UP TORQUE AND TC MP2JOB
## Page 451
#                                                      206 IMPLEMENTATION

# DEBRIS

# ALL CENTRALS,ALL OF EBANK XSM,AND 78 DEC LOCATIONS  (SEE STOREDTA..

## Page 452
                BANK            35
                EBANK=          XSM

# G SCHMIDT SIMPLIFIED ESTIMATION PROGRAM FOR ALIGNMENT CALIBRATION. THE
# PROGRAM IS COMPLETELY RESTART PROFED. DATA STORED IN BANK4.
ESTIMS          TC              PHASCHNG
                OCT             00075
                CAF		BIT1
                TC		SETRSTRT			# SET RESTART FLAG
                
RSTGTS1         INHINT                                          #  COMES HERE PHASE1 RESTART
                CA              TIME1
                TS              GTSWTLST
                CS             	ZERO 
                TS              PIPAX                           
                TS              PIPAY                           
                TS              PIPAZ                           
                TS              DELVX           +1
                TS              DELVY           +1
                TS              DELVZ           +1
                RELINT                                          
                TC              SETUPER
                CA              77DECML                         
                TS              ZERONDX                         
                CA              ALXXXZ                          
                TC              BANKCALL
                CADR            ZEROING                         
                TC              INTPRET                         
                VLOAD                                           
                                INTVAL          +2
                STORE           ALX1S
                EXIT

                CCS             GEOCOMPS                        # GEOCOMPS IN NON ZERO IF COMPASS
                TC              +2
                TC              SLEEPIE         +1              
                CA              LENGTHOT                        #   TIMES FIVE IS THE NUM OF SEC ERECTING
                TS              ERECTIME
                
                CA		ONE
                TS		PHASENUM
                TC              NEWMODEX
                OCT             02
                TC              BANKCALL
                CADR            GCOMPZER                        #   ZERO COMPENSATION PROGRAM REGISTERS
                TC              ANNNNNN

## Page 453
ALLOOP          CA              TIME1
                XCH             GTSWTLST                        # STORE TIME TO SET UP NEXT WAITLIST.
                TS		OLDGT				# SAVE LAST READ TIME.
                
ALLOOP3         CA              ALTIM
                TS              GEOSAVED
                TC              PHASCHNG
                OCT             00115
ALLOOP1         CA              GEOSAVED
                TS              ALTIM
                CCS             A
                CA              A                               # SHOULD NEVER HIT THIS LOCATION
                TS              ALTIMS                          
                CS              A                               
                TS              ALTIM                           
                CA              PIPAX
                TS              DELVX
                CA              PIPAY
                TS              DELVY
                CA              PIPAZ
                TS              DELVZ
                CA		SCHOCT23
                TC		NEWPHASE
                OCT		00005         
SPECSTS         CS              ZERO                            
                TS              PIPAX                           
                TS              PIPAY                           
                TS              PIPAZ   
                CAF		PRIO20
                TC		FINDVAC
                EBANK=		XSM
                2CADR           ALFLT                           # START THE JOB

                TC              TASKOVER                        

## Page 454
ALFLT           TC              STOREDTA                        #  STORE DATA IN CASE OF RESTART IN JOB
                TC              PHASCHNG                        # THIS IS THE JOB DONE EVERY ITERATION
                OCT             00215
                TCF		+2
ALFLT1          TC              LOADSTDT                        # COMES HERE ON RESTART
		CCS		GEOCOMPS
		TC		+2
		TC		NORMLOP
		TC		CHKCOMED			#      SEE IF PRELAUNCH OVER
		TC		BANKCALL			#  COMPENSATION IF IN COMPASS
		CADR		1/PIPA
		CS		GTSWTLST			# SEE IF MEASURED DELV LOOKS LIKE LIFTOFF
		AD		OLDGT				# HAS OCCURRED.
		EXTEND
		BZMF		+3
		AD		NEG1/2				# (IF TIME1 OVERFLOWED)
		AD		NEG1/2
		TS		MPAC		+3		# DT STORED NEGATIVELY
		
		TC		INTPRET
		
		SLOAD		SL4				# SCALE DT AT 2(+10) CS.
				MPAC		+3
		PDVL		ABVAL
				DELV
		DDV						# GET ACC (NEG) IN M/SEC SQ SCALED 2(4)
		DAD		BMN				# (DV OVFLO GIVES DP POSMAX)
				GLIFTOFF			# WHEN GLIFTOFF = DP POSMAX, THIS KIND OF
				GRRNOW				# LIFTOFF DETECTION IS INHIBITED.
		EXIT						# CONTINUE GYROCOMPASS IF NO LIFTOFF.

NORMLOP         EXTEND
		DCA		INTVAL
		INDEX		FIXLOC
		DXCH		S1
		CCS		GEOCOMPS
		TC		PALFLT				# COMPASS
		TC		INTPRET				# NO COMPZSS
ALCGKK          SLOAD           BMN                             
                                ALTIMS                                          
                                ALFLT2                                          
ALKCG           AXT,2           LXA,1                           # LOADS SLOPES AND TIME CONSTANTS AT RQST
                                12D                                             
                                ALX1S                                           
ALKCG2          DLOAD*          INCR,1                          
                                ALFDK           +144D,1                         
                DEC             -2                              
                STORE           ALDK            +10D,2          
                TIX,2           SXA,1                           
                                ALKCG2 
## Page 455                                                                         
                                ALX1S                                           

		EXIT
PALFLT		TC		INTPRET
ALFLT2          VLOAD           VXM
                                DELVX
                                GEOMTRX
                VSL1
                DLOAD           DCOMP
                                MPAC            +3
                STODL           DPIPAY
                                MPAC            +5
                STORE           DPIPAZ

                SETPD           AXT,1                           # MEASUREMENT INCORPORATION ROUTINES.
                                0
                                8D                                              
                SLOAD           DCOMP
                                GEOCOMPS
                BMN
                                ALWAYSG                         # DO A QUICK COMPASS
DELMLP          DLOAD*          DMP                             
                                DPIPAY          +8D,1                           
                                PIPASC                                          
                SLR             DAD*                           
                                9D                                              
                                DELM            +8D,1                           
                DSU*            PDDL*
                                INTY            +8D,1
                                VLAUN           +8D,1
                DSU*            DMP
                                VLAUNS          +8D,1
                                VELSC
                SL2R                                            
                DAD             STADR                           
                STORE           DELM            +8D,1           
                STORE           DELM            +10D,1   
                DLOAD*       
                                VLAUN           +8D,1
                STORE           VLAUNS          +8D,1
                DLOAD
                                INTVAL          -2
                STORE           INTY            +8D,1
                TIX,1           AXT,2                           
                                DELMLP                                          
                                4                                               
ALILP           DLOAD*          DMPR*                           
                                ALK             +4,2                            
                                ALDK            +4,2                            
                STORE           ALK             +4,2  
## Page 456          
                TIX,2           AXT,2                           
                                ALILP                                           
                                8D                                              
ALKLP           LXC,1           SXA,1                           
                                CMPX1                                           
                                CMPX1                                           
                DLOAD*          DMPR*                           
                                ALK             +1,1                            
                                DELM            +8D,2                           
                DAD*                                            
                                INTY            +8D,2                           
                STORE           INTY            +8D,2   
                DLOAD*		DAD*        
                                ALK             +12D,2
                                ALDK            +12D,2
                STORE           ALK             +12D,2          
                DMPR*           DAD*                            
                                DELM            +8D,2                           
                                INTY            +16D,2                          
                STORE           INTY            +16D,2 
                DLOAD*		DMP*         
                                ALSK            +1,1
                                DELM		+8D,2
                SL1R		DAD*
                                VLAUN           +8D,2
                STORE           VLAUN           +8D,2
                TIX,2           AXT,1                           
                                ALKLP                                           
                                8D                                              


LOOSE           DLOAD*          PDDL*                           
                                ACCWD           +8D,1                           
                                VLAUN           +8D,1                           
                PDDL*           VDEF                            
                                POSNV           +8D,1                           
                MXV             VSL1                            
                                TRANSM1                                         
                DLOAD                                           
                                MPAC                                            
                STORE           POSNV           +8D,1
                DLOAD           
                                MPAC            +3
                STORE           VLAUN           +8D,1  
                DLOAD         
                                MPAC            +5
                STORE           ACCWD           +8D,1           
                TIX,1                                           
                                LOOSE                                           
## Page 457

                AXT,2           AXT,1                           # EVALUATE SINES AND COSINES
                                6                                               
                                2                                               
BOOP            DLOAD*          DMPR                            
                                ANGX            +2,1                            
                                GEORGEJ                                         
                SR2R                                            
                PUSH            SIN                             
                SL1R            XAD,1                           
                                X1                                              
                STORE          16D,2
                DLOAD                           
                COS                                             
                STORE           22D,2                           # COSINES
                TIX,2           DLOAD                                          
                                BOOP                                            


                                14D
                SL2             DAD
                                INTY
                STODL           INTY
                                12D
                DMP             SL3R
                                20D
                DAD
                                INTZ
                STODL           INTZ
                                16D
                DMPR            DMPR
                                18D
                                14D
                SL2
                PDDL            DMPR
                                10D
                                12D
                DAD
                DMPR
                                WANGI
                PDDL            DMPR
                                18D
                                20D
                DMP             SL2R
                                WANGO
                BDSU
                                DRIFTO
                DSU             STADR
                STODL           WPLATO
                                16D
## Page 458
                DMPR            DMP
                                20D
                                WANGI
                SL2R
                PDDL            DMPR
                                WANGO
                                14D
                DAD
                                DRIFTI
                DSU
                PDDL            DMPR
                                WANGT
                                WANGI
                DAD             STADR
                STODL           WPLATI
                                18D
                DMP             SL1R
                                10D
                PDDL            DMPR
                                12D
                                16D
                DMP             SL1R
                                14D
                BDSU
                DMPR
                                WANGI
                PDDL            DMPR
                                12D
                                20D
                DMP             SL1R
                                WANGO
                BDSU
                                DRIFTT
                DAD                                             #  WPLATT NOW IN MPAC
                PUSH                                            # PUSH IT DOWN-X IT BY SANG +2
                DMPR            SR1R
                                12D
                PDDL            DMPR
                                WPLATO
                                18D
                DAD
                DDV
                                20D
                PUSH            DMPR
                                GEORGEK
                SRR             DAD
                                13D
                                ANGX
                STODL           ANGX
                DMPR            DAD
## Page 459                
                                14D
                                WPLATI
                DMPR            SRR
                                GEORGEK
                                13D
                DAD
                                ANGY
                STODL           ANGY
                                18D
                DMP             SL1R                            # MULTIPLY X WPLATT -SL1- PUSH AND RELOAD
                PDDL            DMPR
                                12D
                                WPLATO
                BDSU
                DMPR            SRR
                                GEORGEK
                                13D
                DAD
                                ANGZ
                STORE           ANGZ
                BOVB            EXIT
                                SOMEERRR
                CCS             LENGTHOT
                TC              SLEEPIE
                TC              SETUPER1

                
ALWAYSG         DLOAD*          DSU*                            # COMPASS AND ERECT
                                DPIPAY          +8D,1
                                FILDELV         +8D,1
                DMPR            DAD*
                                GEOCONS1
                                FILDELV         +8D,1
                STORE           FILDELV         +8D,1
                DAD*
                                INTVEC          +8D,1
                STORE           INTVEC          +8D,1
                DMPR            DAD*
                                GEOCONS2
                                FILDELV         +8D,1
                DMPR            PUSH
                                GEOCONS1
                TIX,1           SLOAD
                                ALWAYSG
                                ERECTIME
                BZE             DLOAD
                                COMPGS                          # COMPASS
                                THETAN          +2
                DSU             STADR
## Page 460                
                STODL           THETAN          +2
                BDSU
                                THETAN          +4
                STORE           THETAN          +4
                GOTO
                                ADDINDRF
COMPGS          DLOAD           DAD                             # COMPASS
                                THETAN
                                FILDELV
                STODL           THETAN
                                FILDELV
                DMPR            BDSU
                                GEOCONS3
                                THETAN          +4
                STODL           THETAN          +4
                                FILDELV         +4
                DMPR            BDSU
                                GEOCONS3
                                THETAN          +2
                PDDL            DMP
                                INTVEC          +4
                                GEOCONS4
                BDSU            STADR
                STORE           THETAN          +2
ADDINDRF        VLOAD
                                THETAN
                STORE		COMPTORK			# IN E7 FOR DOWNLINK.
                EXIT

ENDGTSAL        CCS             LENGTHOT                        #  IS 5 SEC OVER-THE TIME TO TORQ PLATFORM
                TC              SLEEPIE                         #  NO-SET UP NEXT WAITLIST CALL FOR .5 SEC
                CCS             LGYRO                           #  YES BUT ARE GYROS BUSY
                TCF             ANNNNNN         +2              #  BUSY-GET THEM .5 SECONDS FROM NOW


		TC		CHKCOMED			# SEE IF LAST TIME FOR COMPASS
		
LASTGTS		TC		INTPRET
		VLOAD
				ERCOMP
		STODL		THETAX
				TMARK
		STORE		ALK
		EXIT						# PREVIOUS SECTION WAS FOR RESTARTS
		
RESTAIER	TC              PHASCHNG

                OCT             00255
                TC              INTPRET                         # ADD COMPASS COMMANDS INTO ERATE
## Page 461
		VLOAD		MXV
				THETAN
				GEOMTRX
		VSL1		VAD
				THETAX
		STODL		ERCOMP
				ALK
		STORE		TMARK
		EXIT
                TC              BANKCALL
                CADR            EARTHR                          # TORQUE IT ALL IN
                CA		ERECTIME
                TS		GEOSAVED
RESTEST1        TCF		NOCHORLD

REDO3.27	INHINT						# PRELAUNCH DONE
		TC		CHECKMM
		OCT		11				# SEE IF LIFTOFF IS DISPLAYED
		TC		+2				# NO , DISPLAY MM 7.
		TCF		ENDOFJOB			# LIFTOFF DISPLAYED - IGNORE MM 7.
		
		TC		NEWMODEX			# PRELAUNCH DONE
		OCT		7				# DISPLAY MAJOR MODE 7
		CAF		ZERO			
		TC		NEWPHASE			# TURN OFF FINAL PRELAUNCH PROTECTION.
		OCT		00003
		
		TCF 		ENDOFJOB			# TERMINATE PRELAUNCH
		
		
SETUPER1	TC		INTPRET
                DLOAD           PDDL                            # ANGLES FROM DRIFT TEST ONLY
                                ANGZ                                            
                                ANGY                                            
                PDDL            VDEF                            
                                ANGX                                            
                VCOMP           VXSC                            
                                GEORGEJ                                         
                MXV             VSR1                            
                                GEOMTRX
                STORE           OGC                             
                EXIT                                            


TORQINCH        TC              PHASCHNG
                OCT             00175
## Page 462                
                CA              AINGYRO
                TC              BANKCALL
                CADR            IMUPULSE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              SOMERR2                         # BAD GYRO TORQUE-END OF TEST
                
## Page 463             
GEOSTRT4        CCS             TORQNDX                         #  ONLY POSITIVE IF IN VERTICAL DRIFT TEST
                TC              GEOBAVR                         # VERT DRIFT TEST OVER
                TC              SETUPER                         #  SET UP ERATE FOR PIPTEST OR COMPASS
                TC              BANKCALL                        # GO TO IMU2 FOR A PIPA TEST AND DISPLAY
                CADR            TORQUE

GEOBAVR         TC              BANKCALL
                CADR            VALMIS                          #  DISPLAY VERTICAL DRIFT


## Page 464
# SET UP WAITLIST SECTION
SLEEPIE         TS              LENGTHOT                        # TEST NOT OVER-DECREMENT LENGTHOT
                TC              PHASCHNG                        #  CHANGE PHASE
                OCT             00135
                CCS             TORQNDX                         # ARE WE DOING VERTDRIFT
                TC              EARTTPRQ                        # YES,DO HOR ERATE TORQ THEN SLEEP
                TC              WTLISTNT                        # GO TO SET UP NEXT WAITLIST
EARTTPRQ        TC              BANKCALL                        # IN VERTDRIFT,ADD HOR ERATE AND SLEEP
                CADR            EARTHR
WTLISTNT        TC		CHKCOMED			# SEE IF GYROCOMPASS OVER

		INHINT
                CS              TIME1
                AD              GTSWTLST
                EXTEND
                BZMF            +2
                AD              NEGMAX
                AD              1SECXT                          # 1 SEC FOR CALIBRATION,.5 SEC IN COMPASS
                EXTEND
                BZMF            RIGHTGTS
WTGTSMPL        TC              WAITLIST
		EBANK=		XSM
                2CADR           ALLOOP

                RELINT
                TC              ENDOFJOB                        
RIGHTGTS        CAF             TWO
                TC              WTGTSMPL


SOMEERRR        TC              ALARM                           
                OCT             1600                            
                TC              +3
SOMERR2         TC              ALARM
                OCT             1601
                TC              BANKCALL
                CADR            ENDTEST

## Page 465
NOCHORLD        TC		PHASCHNG
		OCT		00155

                TC              INTPRET
                VLOAD
                                SCHZEROS
                STORE           THETAN
                EXIT
                CCS             GEOSAVED
                TS              ERECTIME                        #        COUNTS DOWN FOR ERECTION

ANNNNNN         CAF             NINE
                TS              LENGTHOT
                TC              SLEEPIE         +1
                
SETUPER         EXTEND                                          # SUBROUTINE CALLED IN 3 PLACES
                QXCH            QPLACES
                TC              INTPRET
                CALL
                                ERTHRVSE
                EXIT
                TC              BANKCALL
                CADR            OGCZERO
                TC              QPLACES

## Page 466
GEOBND          =		EBANK3
GEOBND1         =		EBANK5
STOREDTA        CAF             GEOBND
                TS              L
                CAF             77DECML
                TS              MPAC
                INDEX           MPAC
                CA              ALX1S
                LXCH            EBANK
                EBANK=          RESTRTCS
                INDEX           MPAC
                TS              RESTRTCS
                LXCH            EBANK
                EBANK=          XSM
                CCS             MPAC
                TCF             +2
                TC              Q
                TS              MPAC
                CAF             GEOBND
                TS              L
                TCF             STOREDTA        +4


LOADSTDT        CAF             77DECML
                TS              MPAC
                CA              GEOBND
                XCH             EBANK
                TS              L
                EBANK=          RESTRTCS
                INDEX           MPAC
                CA              RESTRTCS
                LXCH            EBANK
                EBANK=          XSM
                INDEX           MPAC
                TS              ALX1S
                CCS             MPAC
                TCF             +2
                TC              Q
                TS              MPAC
                TCF             LOADSTDT        +2

## Page 467
LOADXSM         EXTEND
                QXCH            QPLACES
                CAF             17DECML
                TS              MPAC
                INDEX           A
                CA              PRELMTRX
                INDEX           MPAC
                TS              XSM
                CCS             MPAC
                TCF             LOADXSM         +3
                TC              QPLACES
ALFDK           DEC             -28                             # SLOPES AND TIME CONSTANTS FOR FIRST 30SC
                DEC             -1
                2DEC            .91230833                       # TIME CONSTANTS-PIPA OUTPUTS

                2DEC            .81193187                       # TIME CONSTANT-ERECTION ANGLES

                2DEC            -.00035882                      # SLOPE-AZIMUTH ANGLE

                2DEC            -.00000029                      # SLOPE-VERTICAL DRIFT

                2DEC            .00013262                       # SLOPE-NORTH SOUTH DRIFT


                DEC             -58                             # 31-90 SEC
                DEC             -1
                2DEC            .99122133

                2DEC            .98940595

                2DEC            -.00079010

                2DEC            -.00000265

                2DEC            .00043154


                DEC             -8                              # 91-100 SEC
                DEC             -1
                2DEC            .99971021

                2DEC            .99852047

                2DEC            .00042697

                2DEC            -.00000213

                2DEC            .00011864

## Page 468
                DEC             -98                             # 101-200 SEC
                DEC             -1
                2DEC            .99550063

                2DEC            .98992124

                2DEC            .00043452

                2DEC            -.00000401

                2DEC            -.00021980


                DEC             -248                            # 201-450 SEC
                DEC             -1
                2DEC            .99673264

                2DEC            .99365467

                2DEC            .00003767

                2DEC            -.00002317

                2DEC            -.00003305


                DEC             -338                            # 451-790 SEC
                DEC             -1
                2DEC            .99924362

                2DEC            .99888274

                2DEC            .00000064

                2DEC            -.00004012

                2DEC            -.00000195


                DEC             -408                            # 791-1200 SEC
                DEC             -1
                2DEC            .99963845

                2DEC            .99913162

                2DEC            .00000090

## Page 469
                2DEC            .00002927

                2DEC            -.00000026


                DEC             -498                            # 1201-1700 SEC
                DEC             -1
                2DEC            .99934865

                2DEC            .99868793

                2DEC            .00000055

                2DEC            .00001183

                2DEC            -.00000005


                DEC             -398                            # 1701-2100 SEC
                DEC             -1
                2DEC            .99947099

                2DEC            .99894799

                2DEC            .00000018

                2DEC            .00000300

                2DEC            -.00000001


                DEC             -598                            # 2101-2700 SEC
                DEC             -1
                2DEC            .99957801

                2DEC            .99916095

                2DEC            .00000007

                2DEC            .00000096

                2DEC            .00000000


                DEC             -698                            # 2700-3400 SEC
                DEC             -1
## Page 470
                2DEC            .99966814

                2DEC            .99933952

                2DEC            .00000002

                2DEC            .00000028

                2DEC            .00000000


                DEC             -598                            # 3401-4000 SEC
                DEC             -1
                2DEC            .99972716

                2DEC            .99945654

                2DEC            .00000001

                2DEC            .00000010

                2DEC            .00000000


SCHZEROS        2DEC            .00000000                       

                2DEC            .00000000                       

                2DEC            .00000000                       

INTVAL          OCT             4                               
                OCT             2                               
                DEC             144                             
                DEC             -1                              
SOUPLY          2DEC            .93505870                       # INITIAL GAINS FOR PIP OUTPUTS

                2DEC            .26266423                       # INITIAL GAINS/4 FOR ERECTION ANGLES


77DECML         DEC             77                              
ALXXXZ          GENADR          ALX1S           -1              
AINGYRO         ECADR           OGC
PIPASC          2DEC            .13055869                       

VELSC           2DEC            -.52223476                      # 512/980.402

ALSK            2DEC            .17329931                       # SSWAY VEL GAIN X 980.402/4096

## Page 471
                2DEC            -.00835370                      # SSWAY ACCEL GAIN X 980.402/4096


GEORGEJ         2DEC            .63661977                       

GEORGEK         2DEC            .59737013  

SCHOCT23	OCT		00023                     
GEOCONS1        2DEC            .1

GEOCONS2        2DEC            .005

GEOCONS3        2DEC            .025

GEOCONS4        2DEC            .00003

1/PIPAGT        OCT             06200
17DECML         DEC             17
19DECML         DEC             19
1/2SECX         DEC             50


GTSCPSS         CA              ONE
                TS              GEOCOMPS                        # THIS IS THE LEAD IN FOR COMPASS
                TC              NEWMODEX
                OCT             01
                CA              1/PIPAGT
                TS              1/PIPADT
                CA		ELEVEN				# COMPASS IS POSITION 11
                TS		POSITON
                CA		BIT8				# 620 SECONDS ERECTING
                TS		LENGTHOT
                CAF             1/2SECX				# COMPASS IS A .5 SEC LOOP
                TS              1SECXT
                CAF		ZERO
                TS		NBPOS
                TC              BANKCALL
                CADR            GEOIMUTT 


CHKCOMED	CA		FLAGWRD1			# CHECK FOR END OF COMPASS
		MASK		BIT2				# TEST FOR GRR FLAG
		CCS		A
		TCF		PRELTERM			# YES  GRR HAS OCCURRED
		TC		Q				# NO  CONTINUE

## Page 472
PRELTERM	TC		NEWMODEX
		OCT		04				# 04 IS END OF COMPASS
		TCF		LASTGTS				# GET LAST TORQUING
		
		
GRRNOW		SET		VLOAD				# COME HERE WHEN DELV CHECK SHOWS LIFTOFF
				GRRFLAG				# TO HAVE OCCURRED.
				DELV
		STORE		DELVBUF
		SSP		EXIT
				DT-LIFT				# START LIFTOFF 100 MS AFTER MP2TASK
				10D
				
		INHINT
		CAF		1SEC+1				# DELAY TILL PRELAUNCH IF FINISHED, BUT
		TC		WAITLIST			# NOT SO LONG THAT READACCS HAPPENS FIRST.
		EBANK=		GTSWTLST
		2CADR		LIFTFIXT
		
		RELINT
		TCF		PRELTERM
		