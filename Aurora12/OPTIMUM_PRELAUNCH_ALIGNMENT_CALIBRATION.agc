### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        514-534
## Mod history:  2016-09-20 JL   Created.
##               2016-09-27 MAS  Started.
##               2016-10-15 HG   Fix operand INPRET -> INTPRET
##                                           PHASECHNG -> PHASCHNG 
##                               Fix operator TC -> CA
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 and fixed errors found.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of 
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent 
## reduction in image quality) are available online at 
##       https://www.ibiblio.org/apollo.  
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 514
# THIS PROGRAM USES A VERTICAL,SOUTH,EAST COORDINATE SYSTEM FOR PIPAS
                BANK            21
                EBANK=          XSM

# G SCHMIDT SIMPLIFIED ESTIMATION PROGRAM FOR ALIGNMENT CALIBRATION. THE
# PROGRAM IS COMPLETELY RESTART PROFED. DATA STORED IN BANK4.
ESTIMS          TC              PHASCHNG
                OCT             00101
RSTGTS1         INHINT                                          #  COMES HERE PHASE1 RESTART
                CA              TIME1
                TS              GTSWTLST
                CAF             ZERO                            # ZERO THE PIPAS
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

                TC              NEWMODEX
                OCT             05
                TC              BANKCALL
                CADR            GCOMPZER                        #   ZERO COMPENSATION PROGRAM REGISTERS
                TC              ANNNNNN

## Page 515
ALLOOP          INHINT                                          #  TASK EVERY .5 OR 1 SEC (COMPASS-DRIFT)
                CA              TIME1
                TS              GTSWTLST                        # STORE TIME TO SET UP NEXT WAITLIST
ALLOOP3         CA              ALTIM
                TS              GEOSAVED
                TC              PHASCHNG
                OCT             00201
                TC              +2

ALLOOP1         INHINT                                          # RESTARTS COME IN HERE
                CA              GEOSAVED
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
                CAF             ZERO                            
                TS              PIPAX                           
                TS              PIPAY                           
                TS              PIPAZ                           
                TC              PHASCHNG
                OCT             00701
                RELINT
SPECSTS         CAF             PRIO20                          
                TC              FINDVAC                         
                2CADR           ALFLT                           # START THE JOB

                TC              TASKOVER                        

## Page 516
ALFLT           TC              STOREDTA                        #  STORE DATA IN CASE OF RESTART IN JOB
                TC              PHASCHNG                        # THIS IS THE JOB DONE EVERY ITERATION
                OCT             00601
                CCS             GEOCOMPS                        
                TC              +2                              
                TC              NORMLOP                         
                TC              BANKCALL                        # COMPENSATION IF IN COMPASS
                CADR            1/PIPA                          
                TC              NORMLOP


ALFLT1          TC              LOADSTDT                        # COMES HERE ON RESTART

NORMLOP         TC              INTPRET                         
                DLOAD                                           
                                INTVAL                                          
                STORE           S1                              # STEP REGISTERS MAY HAVE BEEN WIPED OUT
                SLOAD           BZE
                                GEOCOMPS
                                ALCGKK
                GOTO
                                ALFLT2
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
                                ALX1S                                           

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
## Page 517
                SLOAD           BZE
                                GEOCOMPS
                                DELMLP
                GOTO
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
                STODL*          DELM            +10D,1          
                                VLAUN           +8D,1
                STODL           VLAUNS          +8D,1
                                INTVAL          -2
                STORE           INTY            +8D,1
                TIX,1           AXT,2                           
                                DELMLP                                          
                                4                                               
ALILP           DLOAD*          DMPR*                           
                                ALK             +4,2                            
                                ALDK            +4,2                            
                STORE           ALK             +4,2            
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
                STODL*          INTY            +8D,2           
                                ALK             +12D,2
                DAD*
                                ALDK            +12D,2
                STORE           ALK             +12D,2          
                DMPR*           DAD*                            
                                DELM            +8D,2                           
## Page 518
                                INTY            +16D,2                          
                STODL*          INTY            +16D,2          
                                ALSK            +1,1
                DMP*            SL1R
                                DELM            +8D,2
                DAD*
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
                STODL           POSNV           +8D,1           
                                MPAC            +3
                STODL           VLAUN           +8D,1           
                                MPAC            +5
                STORE           ACCWD           +8D,1           
                TIX,1                                           
                                LOOSE                                           


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
                STODL           16D,2                           
                COS                                             
                STORE           22D,2                           # COSINES
                TIX,2           DLOAD                                          
                                BOOP                                            
## Page 519
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
## Page 520
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
## Page 521
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
## Page 522
                PDDL            DMP
                                INTVEC          +4
                                GEOCONS4
                BDSU            STADR
                STORE           THETAN          +2
ADDINDRF        VLOAD           MXV
                                THETAN
                                GEOMTRX
                VSL1            VAD
                                THETAX
                STORE           THETAX
                EXIT

ENDGTSAL        CCS             LENGTHOT                        # IS 5 SEC OVER-THE TIME TO TORQ PLATFORM
                TC              SLEEPIE                         # NO-SET UP NEXT WAITLIST CALL FOR .5 SEC
                CCS             LGYRO                           # YES BUT ARE GYROS BUSY
                TCF             ANNNNNN         +2              # BUSY-GET THEM .5 SECONDS FROM NOW

                TC              PHASCHNG
                OCT             00401
                TC              INTPRET                         # ADD COMPASS COMMANDS INTO ERATE
                VLOAD           VAD
                                THETAX
                                ERCOMP
                STORE           ERCOMP
                EXIT
                TC              BANKCALL
                CADR            EARTHR                          # TORQUE IT ALL IN

RESTEST1        INHINT                                          # CHECK ON ORIENTATION CHANGE
                CA              PREMTRXC
                EXTEND
                BZMF            NOCHORLD                        # +1 -CHANGE, 0 OR -1 NO LOAD OR LOADING
                TC              LOADXSM                         # IF THERE WAS A CHANGE LOAD IT INTO XSM
                TC              PHASCHNG
                OCT             01001
RESTEST3        CA              ZERO                            # RESET CHANGE INDEX TO ZERO
                TS              PREMTRXC
                RELINT
## Page 523
                TC              INTPRET                         # HERE TO CHANGE ORIENTATOON
                AXT,1                                           # DESIRED IN XSM,PRESENT IN GEOMTRX
                                18D
                SSP
                                S1
                                6
LOADM           VLOAD*          DOT
                                XSM             +18D,1
                                GEOMTRX         +12D
                PDVL*           DOT
                                XSM             +18D,1
                                GEOMTRX         +6D
                PDVL*           DOT
                                XSM             +18D,1
                                GEOMTRX
                VDEF            UNIT
                STORE           XDC             +18D,1
                TIX,1           CALL
                                LOADM
                                CALCGTA
                EXIT
                TC              TORQINCH                        # NECESSARY TORQUE NOW IN OGC


SETUPER1        TC              INTPRET                         
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
                OCT             00501
                CA              AINGYRO
                TC              BANKCALL
                CADR            IMUPULSE
                TC              BANKCALL
                CADR            IMUSTALL
                TC              SOMERR2                         # BAD GYRO TORQUE-END OF TEST

## Page 524
GEOSTRT4        CCS             TORQNDX                         #  ONLY POSITIVE IF IN VERTICAL DRIFT TEST
                TC              GEOBAVR                         # VERT DRIFT TEST OVER
                TC              SETUPER                         #  SET UP ERATE FOR PIPTEST OR COMPASS
                CCS             GEOCOMPS
                TC              TQORESTM
                TC              BANKCALL                        # GO TO IMU2 FOR A PIPA TEST AND DISPLAY
                CADR            TORQUE

GEOBAVR         TC              BANKCALL
                CADR            VALMIS                          #  DISPLAY VERTICAL DRIFT


## Page 525
# SET UP WAITLIST SECTION

SLEEPIE         TS              LENGTHOT                        # TEST NOT OVER-DECREMENT LENGTHOT
                TC              PHASCHNG                        #  CHANGE PHASE
                OCT             00301
                CCS             TORQNDX                         # ARE WE DOING VERTDRIFT
                TC              EARTTPRQ                        # YES,DO HOR ERATE TORQ THEN SLEEP
                TC              WTLISTNT                        # GO TO SET UP NEXT WAITLIST
EARTTPRQ        TC              BANKCALL                        # IN VERTDRIFT,ADD HOR ERATE AND SLEEP
                CADR            EARTHR
WTLISTNT        INHINT
                CS              TIME1
                AD              GTSWTLST
                EXTEND
                BZMF            +2
                AD              NEGMAX
                AD              1SECXT                          # 1 SEC FOR CALIBRATION,.5 SEC IN COMPASS
                EXTEND
                BZMF            RIGHTGTS
WTGTSMPL        TC              WAITLIST
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

## Page 526
TQORESTM        TC              BANKCALL
                CADR            LOADGTSM                        # LOAD NEW XSM MATRIX INTO GEOMTRX

NOCHORLD        RELINT                                          # AFTER CHANGEIN ORIEN OR NO CHANGE
                TC              INTPRET
                VLOAD
                                SCHZEROS
                STORE           THETAX
                STORE           THETAN
                EXIT
                CCS             ERECTIME
                TS              ERECTIME                        #        COUNTS DOWN FOR ERECTION

ANNNNNN         CAF             NINE
                TS              LENGTHOT
                CCS             ERECTIME
                TC              SLEEPIE         +1
                TC              CHECKMM                         # IN COMPASS CHECK FOR VERIFICATION
                OCT             03
                TC              +2                              # NOT VERIFYING
                TC              SLEEPIE         +1              # YES
                TC              NEWMODEX
                OCT             02
                TC              SLEEPIE         +1              # COMPASS IS 02  -ERECTION 05
SETUPER         EXTEND                                          # SUBROUTINE CALLED IN 3 PLACES
                QXCH            QPLACES
                TC              INTPRET
                CALL
                                ERTHRVSE
                EXIT
                TC              BANKCALL
                CADR            OGCZERO
                TC              QPLACES

## Page 527
OPTMSTRT        INDEX           PHASE1
                TC              +0
                TC              GTSGTS1
                TC              GTSGTS2
                TC              GTSGTS3
                TC              GTSGTS4
                TC              GTSGTS5
                TC              GTSGTS6
                TC              GTSGTS7
                TC              GTSGTS10


GTSGTS1         CAF             PRIO20
                TC              FINDVAC
                2CADR           RSTGTS1

                TC              SWRETURN
GTSGTS2         CAF             ONE
                TC              WAITLIST
                2CADR           ALLOOP1

                TC              SWRETURN
GTSGTS3         CAF             PRIO20
                TC              FINDVAC
                2CADR           WTLISTNT

                TC              SWRETURN
GTSGTS4         CAF             PRIO20
                TC              FINDVAC
                2CADR           RESTEST1

                TC              SWRETURN
GTSGTS5         CAF             PRIO20
                TC              FINDVAC
                2CADR           GEOSTRT4

                TC              SWRETURN
GTSGTS6         CAF             PRIO20
                TC              FINDVAC
                2CADR           ALFLT1

                TC              SWRETURN

GTSGTS7         CAF             ONE
                TC              WAITLIST
                2CADR           SPECSTS

GTSGTS10        CAF             PRIO20
                TC              FINDVAC
## Page 528
                2CADR           RESTEST3

                TC              SWRETURN

## Page 529
GEOBND          OCT             02000                           #  BANK 4  -THIS IS THE STORE DTA SECTION
GEOBND1         OCT             02400                           # BANK NUMBER 5


STOREDTA        CAF             GEOBND
                TS              L
                CAF             77DECML
                TS              MPAC
                INDEX           MPAC
                CA              ALX1S
                LXCH            EBANK
                EBANK=          JETSTEP
                INDEX           MPAC
                TS              JETSTEP
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
                EBANK=          JETSTEP
                INDEX           MPAC
                CA              JETSTEP
                LXCH            EBANK
                EBANK=          XSM
                INDEX           MPAC
                TS              ALX1S
                CCS             MPAC
                TCF             +2
                TC              Q
                TS              MPAC
                TCF             LOADSTDT        +2

## Page 530
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

## Page 531
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

## Page 532
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
## Page 533
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

## Page 534
                2DEC            -.00835370                      # SSWAY ACCEL GAIN X 980.402/4096


GEORGEJ         2DEC            .63661977                       

GEORGEK         2DEC            .59737013                       

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
                CA              ZERO
                TS              PREMTRXC
                CAF             1/2SECX
                TS              1SECXT
                TC              BANKCALL
                CADR            GEOIMUTT                        # TO IMU PERF TESTS 2


ENDPREL1        EQUALS
