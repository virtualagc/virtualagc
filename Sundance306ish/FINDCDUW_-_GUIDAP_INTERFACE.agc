### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    FINDCDUW_-_GUIDAP_INTERFACE.agc
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



# PROGRAM NAME:   FINDCDUW

# MOD NUMBER:     1         68 07 15

# MOD AUTHOR:     KLUMPP

# OBJECTS OF MOD: 1.        TO SUPPLY COMMANDED GIMBAL ANGLES FOR NOUN 22.
#                 2.        TO MAINTAIN CORRECT AND CURRENT THRUST
#                           DIRECTION DATA IN ALL MODES.  THIS IS DONE BY
#                           FETCHING FOR THE THRUST DIRECTION FILTER THE
#                           CDUD'S IN PNGCS-AUTO, THE CDU'S IN ALL OTHER
#                           MODES.
#                 3.        TO SUBSTITUTE A STOPRATE FOR THE NORMAL
#                           AUTOPILOT COMMANDS WHENEVER
#                           1) NOT IN PNGCS-AUTO, OR
#                           2) ENGINE IS OFF.

# FUNCTIONAL DESCRIPTION:

# FINDCDUW PROVIDES THE INTERFACES BETWEEN THE VARIOUS POWERED FLITE GUIDANCE PROGRAMS
# AND THE DIGITAL AUTOPILOT.  THE INPUTS TO FINDCDUW ARE THE THRUST COMMAND VECTOR
# AND THE WINDOW COMMAND VECTOR, AND THE OUTPUTS ARE THE GIMBAL ANGLE
# INCREMENTS, THE COMMANDED ATTITUDE ANGLE RATES, AND THE COMMANDED
# ATTITUDE LAG ANGLES (WHICH ACCOUNT FOR THE ANGLES BY WHICH THE BODY WILL
# LAG BEHIND A RAMP COMMAND IN ATTITUDE ANGLE DUE TO THE FINITE ANGULAR
# ACCELERATIONS AVAILABLE).

# FINDCDUW ALINES THE ESTIMATED THRUST VECTOR FROM THE THRUST DIRECTION
# FILTER WITH THE THRUST COMMAND VECTOR, AND, WHEN  XOVINHIB  SET,
# ALINES THE +Z HALF OF THE LM ZX PLANE WITH THE WINDOW COMMAND VECTOR.

# SPECIFICATIONS:

# INITIALIZATION: A SINGLE INTERPRETIVE CALL TO  INITCDUW  IS REQUIRED
#                 BEFORE EACH GUIDED MANEUVER USING FINDCDUW.

# CALL:           INTERPRETIVE CALL TO FINDCDUW WITH THE THRUST COMMAND
#                 VECTOR IN MPAC.  INTERPRETIVE CALL TO FINDCDUW -2 WITH
#                 THE THRUST COMMAND VECTOR IN UNFC/2 AND NOT IN MPAC.

# RETURNS:        NORMAL INTERPRETIVE IN ALL CASES

#                 1.       NORMALLY ALL AUTOPILOT CMDS ARE ISSUED.

#                 2.       IF NOT PNGCS AUTO, DO STOPRATE AND RETURN
#                          WITHOUT ISSUING AUTOPILOT CMDS.

#                 3.       IF ENGINE OFF, DO STOPRATE AND RETURN WITHOUT
#                          ISSUING AUTOPILOT CMDS.

# ALARMS:         00401 IF INPUTS DETERMINE AN ATTITUDE IN GIMBAL LOCK.
#                          FINDCDUW DRIVES CDUXD AND CDUYD TO THE RQD VALUES,
#                          BUT DRIVES CDUZD ONLY TO THE GIMBAL LOCK CONE.
#                 00402 IF UNFC/2 OR UNWC/2 PRODUCE OVERFLOW WHEN
#                          UNITIZED USING NORMUNIT.  FINDCDUW ISSUES
#                          STOPRATE AS ONLY INPUT TO AUTOPILOT.

# INPUTS:         UNFC/2   THRUST COMMAND VECTOR, NEED NOT BE SEMI-UNIT.
#                 UNWC/2   WINDOW COMMAND VECTOR, NEED NOT BE SEMI-UNIT.
#                 XOVINHIB FLAG DENOTING X AXIS OVERRIDE INHIBITED.
#                 CSMDOCKD FLAG DENOTING CSM DOCKED.
#                 STEERSW  FLAG DENOTING INSUFF THRUST FOR THRUST DIR FLTR.
#
# OUTPUTS:        DELCDUX,Y,Z
#                 OMEGAPD,+1,+2
#                 DELPEROR,+1,+2
#                 CPHI,+1,+2 FOR NOUN22
#
# DEBRIS:         FINDCDUW DESTROYS SINCDUX,Y,Z AND COSCDUX,Y,Z BY
#                 WRITING INTO THESE LOCATIONS THE SINES AND COSINES
#                 OF THE CDUD'S IN PNGCS-AUTO, OF THE CDU'S OTHERWISE.

# INITIALIZATION FOR FINDCDUW

                BANK            30
                SETLOC          FCDUW
                BANK

                EBANK=          ECDUW

                COUNT*          $$/FCDUW

INITCDUW        VLOAD
                                UNITX
                STORE           UNFV/2
                STORE           UNWC/2
                RVQ

# FINDCDUW PRELIMINARIES

                VLOAD                                   # FINDCDUW -2: ENTRY WHEN UNFC/2 PRE-STORD
                                UNFC/2                  # INPUT VECTORS NEED NOT BE SEMI-UNIT
FINDCDUW        BOV             SETPD                   # FINDCDUW: ENTRY WHEN UNFC/2 IN MPAC
                                FINDCDUW                # INTERPRETER NOW INITIALIZED
                                22                      # LOCS 0 THRU 21 FOR DIRECTION COSINE MAT
                STQ             EXIT
                                QCDUWUSR                # SAVE RETURN ADDRESS

# MORE HAUSKEEPING
                CA              ECDUWL
                XCH             EBANK                   # SET EBANK
                TS              ECDUWUSR                # SAVE USER'S EBANK

                CA              DAPBOOLS
                MASK            CSMDOCKD                # CSMDOCKD MUST NOT BE BIT15
                CCS             A
                CA              ONE                     # INDEX IF CSM DOCKED
                TS              NDXCDUW

                CA              DAPBOOLS
                MASK            XOVINHIB                # XOVINHIB MUST NOT BE BIT15
                TS              FLAGOODW                # FLAGOODW = ANY PNZ NUMBER IF XOV INHIBTD

# FETCH BASIC DATA

                INHINT                                  # RELINT AT PAUTNO (TC INTPRET)

                CA              CDUXD                   # PNGCS AUTO: FETCH CDUXD,CDUYD,CDUZD
                TS              CDUSPOTX
                CA              CDUYD
                TS              CDUSPOTY
                CA              CDUZD
                TS              CDUSPOTZ

                RELINT

# FETCH INPUTS

                TC              INTPRET                 # ENTERING THRUST CMD STILL IN MPAC
                RTB
                                NORMUNIT
                STOVL           UNX/2                   # SEMI-UNIT THRUST CMD AS INITIAL UNX/2
                                UNWC/2
                RTB
                                NORMUNIT
                STOVL           UNZ/2                   # SEMI-UNIT WINDOW CMD AS INITIAL UNZ/2
                                DELV
                BOVB            CALL
                                NOATTCNT                # AT LEAST ONE ENTERING CMD VCT ZERO
                                TRG*SMNB
                BOFF            UNIT                    # YIELDS UNIT(DELV) IN VEH COORDS FOR FLTR
                                STEERSW
                                AFTRFLTR                # IF UNIT DELV OVERFLOWS, SKIP FILTER

# THRUST DIRECTION FILTER

                EXIT

                CA              UNFVY/2                 # FOR RESTARTS, UNFV/2 ALWAYS INTACT, MPAC
                LXCH            MPAC            +3      #       RENEWED AFTER RETURN FROM CALLER,
                TC              FLTRSUB                 #       TWO FILTER UPDATES MAY BE DONE.
                TS              UNFVY/2                 # UNFV/2 NEED NOT BE EXACTLY SEMI-UNIT.

                CA              UNFVZ/2
                LXCH            MPAC            +5
                TC              FLTRSUB
                TS              UNFVZ/2

                TC              INTPRET                 # COMPLETES FILTER

# FIND A SUITABLE WINDOW POINTING VECTOR

AFTRFLTR        SLOAD           BHIZ                    # IF XOV NOT INHIBITED, GO FETCH ZNB
                                FLAGOODW
                                FETCHZNB
                VLOAD           CALL
                                UNZ/2
                                UNWCTEST

FETCHZNB        VLOAD
                                ZNBPIP
                STCALL          UNZ/2
                                UNWCTEST

                VLOAD           VCOMP                   # Z AND -X CAN'T BOTH PARALLEL UNFC/2
                                XNBPIP
                STORE           UNZ/2

# COMPUTE THE REQUIRED DIRECTION COSINE MATRIX

DCMCL           VLOAD           CALL
                                UNX/2
                                DCMCL1
                CALL
                                DCMCL2
                CALL
                                TRNSPSPD
                AXC,1           CALL
                                0
                                DCMTOCDU
                RTB             EXIT
                                V1STO2S

# LIMIT THE MIDDLE GIMBAL ANGLE & COMPUTE THE UNLIMITED GIMBAL ANGLE CHGS

                CA              MPAC            +2      # LIMIT THE MGA
                TS              L                       # CAN'T LXCH: NEED UNLIMITED MGA FOR ALARM
                CA              CDUZDLIM
                TC              LIMITSUB                # YIELDS LIMITED MGA. 1 BIT ERROR POSSIBLE
                XCH             MPAC            +2      #      BECAUSE USING 2'S COMP. WHO CARES?
                EXTEND
                SU              MPAC            +2      # THIS BETTER YIELD ZERO
                CCS             A
                TCF             ALARMMGA
                TCF             +2
                TCF             ALARMMGA

MGARET          INHINT                                  # RELINT AT TC INTPRET AFTER TCQCDUW

                CA              TWO
DELGMBLP        TS              TEM2

                INDEX           TEM2
                CA              CDUXD
                EXTEND
                INDEX           TEM2
                MSU             MPAC
                INDEX           TEM2
                TS              -DELGMB                 # -UNLIMITED GIMBAL ANGLE CHGS, 1'S, PI
                CCS             TEM2
                TCF             DELGMBLP

# LIMIT THE ATTITUDE ANGLE CHANGES
#
# THIS SECTION LIMITS THE ATTITUDE ANGLE CHANGES ABOUT A SET OF ORTHOGONAL VEHICLE AXES X,YPRIME,ZPRIME.
# THESE AXES COINCIDE WITH THE COMMANDED VEHICLE AXES IF AND ONLY IF CDUXD IS ZERO.  THE PRIME SYSTEM IS
# THE COMMANDED VEHICLE SYSTEM ROTATED ABOUT THE X AXIS TO BRING THE Z AXIS INTO ALINEMENT WITH THE MIDDLE GIMBAL
# AXIS.  ATTITUDE ANGLE CHANGES IN THE PRIME SYSTEM ARE RELATED TO SMALL GIMBAL ANGLE CHANGES BY:
#
# * -DELATTX      *   * 1  SIN(CDUZD)  0 * * -DELGMBX *
# *               *   *                  * *          *
# * -DELATTYPRIME * = * 0  COS(CDUZD)  0 * * -DELGMBY *
# *               *   *                  * *          *
# * -DELATTZPRIME *   * 0  0           1 * * -DELGMBZ *

                LXCH            -DELGMB         +2      # SAME AS -DELATTZPRIME UNLIMITED
                INDEX           NDXCDUW
                CA              DAZMAX
                TC              LIMITSUB
                TS              -DELGMB         +2      # -DELGMBZ

                CA              -DELGMB         +1
                EXTEND
                MP              COSCDUZ                 # YIELDS -DELATTYPRIME/2 UNLIMITED
                TS              L
                INDEX           NDXCDUW
                CA              DAY/2MAX
                TC              LIMITSUB
                EXTEND
                DV              COSCDUZ
                XCH             -DELGMB         +1      # -DELGMBY, FETCHING UNLIMITED VALUE

                EXTEND
                MP              SINCDUZ
                DDOUBL
                TS              TEM2                    # YIELDS +DELATTX UNLIMITD, MAG < 180 DEG,
                AD              -DELGMB                 #       BASED ON UNLIMITED DELGMBY.
                TS              L                       #       ONE BIT ERROR IF OPERANDS IN MSU
                INDEX           NDXCDUW                 #       OF MIXED SIGNS.  WHO CARES?
                CA              DAXMAX
                TC              LIMITSUB
                TS              TEM3                    # SAVE LIMITED +DELATTX
                CCS             FLAGOODW
                CA              TEM3                    # FETCH IT BACK CHGING SIGN IF WINDOW GOOD
                EXTEND
                SU              TEM2
                TS              -DELGMB

# COMPUTE COMMANDED ATTITUDE RATES

# * OMEGAPD *   * -2  -4 SINCDUZ          +0         * * -DELGMBX *
# *         *   *                                    * *          *
# * OMEGAQD * = * +0  -8 COSCDUZ COSCDUX  -4 SINCDUX * * -DELGMBY *
# *         *   *                                    * *          *
# * OMEGARD *   * +0  +8 COSCDUZ SINCDUX  -4 COSCDUX * * -DELGMBZ *

# ATTITUDE ANGLE RATES IN UNITS OF PI/4 RAD/SEC = K TRIG FCNS IN UNITS OF 2 X GIMBAL ANGLE RATES IN UNITS OF
# PI/2 RAD/SEC.  THE CONSTANTS ARE BASED ON DELGMB BEING THE GIMBAL ANGLE CHANGES IN UNITS OF PI RADIANS,
# AND 2 SECONDS BEING THE COMPUTATION PERIOD (THE PERIOD BETWEEN SUCCESSIVE PASSES THRU FINDCDUW).

                CS              -DELGMB
                TS              OMEGAPD
                CS              -DELGMB         +1
                EXTEND
                MP              SINCDUZ
                DDOUBL
                ADS             OMEGAPD
                ADS             OMEGAPD

                CS              -DELGMB         +1
                EXTEND
                MP              COSCDUX
                DDOUBL
                EXTEND
                MP              COSCDUZ
                TS              OMEGAQD
                CS              -DELGMB         +2
                EXTEND
                MP              SINCDUX
                ADS             OMEGAQD
                ADS             OMEGAQD
                ADS             OMEGAQD

                CA              -DELGMB         +1
                EXTEND
                MP              SINCDUX
                DDOUBL
                EXTEND
                MP              COSCDUZ
                TS              OMEGARD
                CS              -DELGMB         +2
                EXTEND
                MP              COSCDUX
                ADS             OMEGARD
                ADS             OMEGARD
                ADS             OMEGARD

# FINAL TRANSFER

                CA              TWO
CDUWXFR         TS              TEM2
                INDEX           TEM2
                CA              -DELGMB
                EXTEND
                MP              DT/DELT                 # RATIO OF DAP INTERVAL TO CDUW INTERVAL
                TC              ONESTO2S
                INDEX           TEM2
                TS              DELCDUX                 # ANGLE INTERFACE

                INDEX           TEM2
                CCS             OMEGAPD
                AD              ONE
                TCF             +2
                AD              ONE
                EXTEND                                  # WE NOW HAVE ABS(OMEGAPD,QD,RD)
                INDEX           TEM2
                MP              OMEGAPD
                EXTEND
                MP              BIT11                   # 1/16
                EXTEND
                INDEX           TEM2                    #                  2
                DV              1JACC                   # UNITS PI/4 RAD/SEC
                TS              L
                CA              DELERLIM
                TC              LIMITSUB
                INDEX           TEM2
                TS              DELPEROR                # LAG ANGLE = OMEGA ABS(OMEGA)/2 ACCEL
                CCS             TEM2
                TCF             CDUWXFR
                RELINT

# HAUSKEEPING AND RETURN

TCQCDUW         CA              ECDUWUSR
                TS              EBANK                   # RETURN USER'S EBANK

                TC              INTPRET
                SETPD           GOTO
                                0
                                QCDUWUSR                # NORMAL AND ABNORMAL RETURN TO USER

# THRUST VECTOR FILTER SUBROUTINE

FLTRSUB         EXTEND
                QXCH            TEM2
                TS              TEM3                    # SAVE ORIGINAL OFFSET
                COM                                     # ONE MCT, NO WDS, CAN BE SAVED IF NEG OF
                AD              L                       #      ORIG OFFSET ARRIVES IN A, BUT IT'S
                EXTEND                                  #      NOT WORTH THE INCREASED OBSCURITY.
                MP              GAINFLTR
                TS              L                       # INCR TO OFFSET, UNLIMITED
                CA              DUNFVLIM                # SAME LIMIT FOR Y AND Z
                TC              LIMITSUB                # YIELDS INCR TO OFFSET, LIMITED
                AD              TEM3                    # ORIGINAL OFFSET
                TS              L                       # TOTAL OFFSET, UNLIMITED
                CA              UNFVLIM                 # SAME LIMIT FOR Y AND Z
                TC              LIMITSUB                # YIELDS TOTAL OFFSET, LIMITED
                TC              TEM2

# SUBR TO TEST THE ANGLE BETWEEN THE PROPOSED WINDOW AND THRUST CMD VCTS

UNWCTEST        DOT             DSQ
                                UNX/2
                DSU             BMN
                                DOTSWFMX
                                DCMCL
                SSP             RVQ                     # RVQ FOR ALT CHOICE IF DOT MAGN TOO LARGE
                                FLAGOODW                #      ZEROING WINDOW GOOD FLAG
                                0

DCMCL2          DLOAD           VXSC
                                UNFVZ/2                 # MUST BE SMALL
                                UNZ/2                   # -UNZ/2 FIRST ITERATION
                PDDL            VXSC                    # EXCHANGE -UNFVZ/2 UNZ/2 FOR UNFVY/2
                                UNFVY/2                 # MUST BE SMALL
                                UNY/2
                VAD             VSL1
                BVSU            UNIT                    # YIELDS -UNFVY/2 UNY/2-UNFVZ/2 UNZ/2
                                UNX/2
                STORE           UNX/2

DCMCL1          VCOMP           VXV
                                UNZ/2
                UNIT
                STORE           UNY/2                   # UNY/2 FIRST ITERATION
                VCOMP           VXV
                                UNX/2
                VSL1
                STORE           UNZ/2
                RVQ

# LIMITSUB LIMITS THE MAGNITUDE OF THE POSITIVE OR NEGATIVE VARIABLE
# ARRIVING IN L TO THE POSITIVE LIMIT ARRIVING IN A.
# THE SIGNED LIMITED VARIABLE IS RETURNED IN A.

# VERSION COURTESY HUGH BLAIR-SMITH

LIMITSUB        TS              TEM1
                CA              ZERO
                EXTEND
                DV              TEM1
                CCS             A
                LXCH            TEM1
                TCF             +2
                TCF             +3
                CA              L
                TC              Q
                CS              TEM1
                TC              Q

# SUBROUTINE TO CONVERT 1'S COMP SP TO 2'S COMP

ONESTO2S        CCS             A
                AD              ONE
                TC              Q
                CS              A
                TC              Q

# NO ATTITUDE CONTROL

NOATTCNT        TC              ALARM
                OCT             00402                   # NO ATTITUDE CONTROL

 +2             TC              BANKCALL
                FCADR           STOPRATE
                TCF             TCQCDUW                 # RETURN TO USER SKIPPING AUTOPILOT CMDS

# MIDDLE GIMBAL ANGLE ALARM

ALARMMGA        TC              ALARM
                OCT             00401
                TCF             MGARET

#************************************************************************
# CONSTANTS
#************************************************************************

# ADDRESS CONSTANTS

ECDUWL          ECADR           ECDUW

# THRUST DIRECTION FILTER CONSTANTS

GAINFLTR        DEC             .2                      # GAIN FILTER

DUNFVLIM        DEC             .007            B-1     # 7 MR MAX CHG IN F DIR IN VEH IN 2 SECS.
                                                        # THIS DOES NOT ALLOW FOR S/C ROT RATE.

UNFVLIM         DEC             .129            B-1     # 129 MR MAX THRUST OFFSET.  105 MR TRAVEL
                                                        # +10MR DEFL+5MR MECH MOUNT+9MR ABLATION.

# CONSTANTS RELATED TO GIMBAL ANGLE COMPUTATIONS

DOTSWFMX        DEC             .93302          B-4     # LIM COLNRTY OF UNWC/2 & UNFC/2 TO 85 DEG
                                                        # LOWER PART COMES FROM NEXT CONSTANT

DAXMAX          DEC             .11111111111            # DELATTX LIM TO 20 DEG IN 2 SECS, 1'S, PI
                DEC             .0111111111             # 2 DEG WHEN CSM DOCKED

DAY/2MAX        DEC             .05555555555            # LIKEWISE FOR DELATTY
                DEC             .0055555555

DAZMAX          =               DAXMAX                  # LIKEWISE FOR DELATTZ

CDUZDLIM        DEC             .3888888888             # 70 DEG LIMIT FOR MGA, 1'S, PI

# CONSTANTS FOR DATA TRANSFER

DT/DELT         DEC             .05                     # .1 SEC/2 SEC WHICH IS THE AUTOPILOT
                                                        # CONTROL SAMPLE PERIOD/COMPUTATION PERIOD

DELERLIM        =               DAY/2MAX                # 10 DEG LIMIT FOR LAG ANGLES, 1'S, PI


