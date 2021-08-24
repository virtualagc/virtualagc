### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SECOND_DPS_GUIDANCE.agc
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
## Reference:   pp. 814-850
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-13 HG   Transcribed
##              2017-06-15 HG   Fix interpretive operand /AFC/ -> /ACF/
##              2017-06-17 MAS  Added a workaround for yaYUL calculating a
##                              fractional number off by one.
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.
##              2021-05-30 ABS  2DEC* -> DEC for non extended address fields.

## Page 814

# PROGRAM NAME - SECOND DPS GUIDANCE

# MOD NO. - 0

# MODIFICATION BY - KLUMPP AND EYLES

# FUNCTIONAL DESCRIPTION -

#      THERE ARE TWO MODES OF OPERATION OF THE SECOND DPS GUIDANCE PROGRAM (2DPS).  PRIOR TO THE IGNITION
# SEQUENCE 2DPS IS OPERATED IN THE PRE-IGNITION MODE FOR THE PURPOSE OF PROVIDING, FOR THE IGNITION
# SEQUENCE, THE TIME OF INITIATION AND THE DIRECTION OF THRUST.  IMMEDIATELY AFTER THE IGNITION SEQUENCE
# IS COMPLETED, INCLUDING THE COMMAND OF MAXIMUM THRUST, 2DPS IS ENGAGED IN THE THRUSTING MODE FOR THE

# PURPOSE OF PROVIDING THRUST ACCELERATION MAGNITUDE AND DIRECTION COMMANDS NECESSARY TO CONDUCT THE
# SIMULATED POWERED LANDING MANEUVER.

#      PRIOR TO LAUNCH, ERASABLE MEMORY MUST BE LOADED WITH THE SEMI-UNIT NORMAL TO THE PLANE OF THE
# REQUIRED ORBIT CPT6/2, AND DATA WHICH INDIRECTLY SPECIFICIES THE NOMINAL IGNITION TIME TIGNOM.  THESE
# DATA MAY BE ADJUSTED, AS A GROUP, VIA THE UPLINK, UNTIL 200 SECONDS PRIOR TO THE TIGNOM IMPLIED BY THE
# PRE-LAUNCH LOAD OR IMPLIED BY THE UPLINK DATA, WHICHEVER IS EARLIER.  A DESCRIPTION OF THE METHOD OF
# UPDATING TIGNOM IS IN THE PROVINCE OF THE MISSION CONTROL PROGRAM (MCP) MISSION PHASE 11 -
# DPS2/FITH/APS1.  THE TARGETING IS CONTROLLED BY THE SEMI-UNIT VECTOR CPT6/2 AS DESCRIBED IN THE 206 GSOP.


#      AT APPROXIMATELY 180 SECONDS PRIOR TO TIGNOM, THE MCP ENGAGES 2DPS IN THE PRE-IGNITION MODE BY
# PROVIDING AN EXTRAPOLATED TIME AND STATE IN THE REGISTERS TET, RIGNTION, VIGNTION, AND TRANSFERRING
# CONTROL TO LOCATION PREBURN IN 2DPS.  THIS TIME AND STATE ARE AT APPROXIMATELY 50 SECONDS PRIOR TO
# TIGNOM.  (THE NAMES RIGNTION, VIGNTION, CHOSEN TO INDICATE USAGE WITH OTHER GUIDANCE PROGRAMS, ARE
# MISLEADING WITH 2DPS IN THAT THE EXTRAPOLATED STATE PROVIDED IN THESE REGISTERS IS NOT THAT EXPECTED AT
# IGNITION BUT RATHER AT 50 SECONDS PRIOR TO IGNITION.)  2DPS TRANSFERS THE CONTENTS OF TET TO PIPTIME
# AND CALLS SUBROUTINE VPATCHER WHICH TRANSFERS THE STATE TO RN, VN AND INITIALIZES FOR CALCRVG.
# USING CALCRVG AS A SUBROUTINE, AND INTERNAL SUBROUTINES IGNITN1 AND IGNITN2, 2DPS MOVES THE TIME AND
# STATE FORWARD TO A TIME GREATER THAN OR EQUAL TO TULLG-6 SECONDS AND LESS THAN OR EQUAL TO TULLG-3.8 SECONDS,
# LEAVING THIS CONSISTENT SET IN PIPTIME, RN, VN, WHERE TULLG IS THE PRECISE TIME FOR ULLAGE TO BE INITIATED
# AND IS LEFT IN THE REGISTER OF THAT NAME.  2DPS LEAVES A SEMI-UNIT VECTOR IN THE DIRECTION IN WHICH
# THRUST IS TO BE COMMANDED DURING THE IGNITION SEQUENCE IN THE REGISTER POINTVSM AND BRANCHES TO

# LOCATION RETPREB IN THE MISSION CONTROL PROGRAM.

#      USING THE DATA LEFT BY THE PRE-IGNITION MODE OF 2DPS, THE MCP ENGAGES KALCMANU TO PROPERLY
# ORIENT THE SPACECRAFT FOR THE IGNITION SEQUENCE, AND ISSUES THE WAITLIST CALLS WHICH CAUSE THE
# READACCS, SERVICER, PGNCSMON LOOP TO BE ESTABLISHED (WITH 2DPS NOT IN THE LOOP) AND PRODUCE ULLAGE,
# ENGINE IGNITION, AND FINALLY MAXIMUM THRUST.  IMMEDIATELY AFTER MAXIMUM THRUST IS COMMANDED, THE MCP
# PLACES THE 2BCADR OF BURN (EBANK= E2DPS) IN THE AVGEXIT WHICH CAUSES 2DPS TO BE ADDED TO THE READACCS,
# SERVICER, PGNCSMON LOOP IMMEDIATELY FOLLOWING CALCRVG.

#      WHEN CONTROL IS GIVEN TO 2DPS WITH THE 2BCADR OF BURN IN AVGEXIT, 2DPS OPERATES IN THE THRUSTING

# MODE.  IT GENERATES THE SEQUENCING REQUIRED TO CONDUCT THE SIMULATED POWERED LANDING MANEUVER AND ISSUES
# THE THRUST ACCELERATION MAGNITUDE AND DIRECTION COMMANDS.

#      2DPS GENERATES THE SEQUENCING BY INCREMENTING THE HIGH ORDER PART OF AVGEXIT, BY AN APPROPRIATE
# INTEGER, TO ACCOMPLISH EACH CHANGE OF 2DPS PHASE.  THE INCREMENTING OF AVGEXIT CAUSES, ON THE SUBSEQUENT

## Page 815
# PASS THROUGH 2DPS, CONTROL TO BEGIN AT A NEW POINT IN THE SECOND DPS FLITE SEQUENCE TABLE, AND
# CONSEQUENTLY THE CORRESPONDING 2DPS MODING TO BE ESTABLISHED.

#      2DPS GENERATES THE THRUST ACCELERATION MAGNITUDE AND DIRECTION COMMANDS ON THE BASIS OF THE
# CONTENTS OF PIPTIME, RN, VN, AT THE BEGINNING OF THE PASS.  TO ISSUE THE THRUST ACCELERATION DIRECTION
# COMMAND, 2DPS PLACES A SEMI-UNIT VECTOR IN THE REQUIRED DIRECTION IN THE REGISTER AXISD AND CALLS

# FINDCDUD AS A SUBROUTINE.  TO ISSUE THE MAGNITUDE COMMAND, 2DPS PLACES THE REQUIRED MAGNITUDE IN THE
# REGISTER /ACF/ AND CALLS THROTCON AS A SUBROUTINE.

#      BEFORE BUT NOT INCLUDING THE LAST PASS, 2DPS TERMINATES THE JOB PERIODICALLY STARTED BY READACCS
# BY BRANCHING TO ENDOFJOB.

#      ON THE LAST PASS 2DPS PLACES THE SEMI-UNIT VECTOR ALONG THE NORMAL TO THE DESIRED ORBITAL PLANE,
# CPT6/2, IN THE REGISTER AXISD, CALLS FINDCDUD, AND BRANCHES TO LOCATION RETBURN IN THE MCP.  THE MCP
# REMOVES 2DPS FROM THE READACCS, SERVICER, PGNCSMON LOOP AND ISSUES THE WAITLIST CALLS WHICH PRODUCE THE
# RANDOM THROTTLING.  THE MCP DOES NOT CHANGE THE CONTENTS OF AXISD SUPPLIED BY 2DPS.  CONSEQUENTLY THE
# THRUST ACCELERATION DURING RANDOM THROTTLING IS NORMAL TO THE ORBITAL PLANE.

## Page 816
# INTERFACE SPECIFICATIONS -

# SPECIFICATION           PRE-IGNITION MODE          THRUSTING MODE

# CALLING SEQUENCE -      DTCB TO PREBURN            DTCB TO BURN
#                         (EBANK= E2DPS)             (EBANK= E2DPS)

# NORMAL EXITS -          DTCB TO LOCATION           PRIOR TO LAST PASS -
#                         RETPREB (EBANK=            TC TO ENDOFJOB
#                         EMP11JOB) IN MISSION
#                         CONTROL PROGRAM.           LAST PASS -
#                                                    DTCB TO LOCATION

#                                                    RETBURN (EBANK=
#                                                    EMP11JOB) IN MISSION
#                                                    CONTROL PROGRAM

# ALARM OR ABORT EXITS -  NONE                       NONE

# ERASABLE                
#    INITIALIZATION -     CPT6/2 (IMU COORDS)        2BCADR OF BURN
#			  OTHER INITIALIZATION       (EBANK= E2DPS) MUST
#                         DONE INTERNALLY            BE IN AVGEXIT.  OTHER
#                                                    INITIALIZATION DONE IN
#                                                                         N PRE-

#                                                    IGNITION MODE.

# INPUTS -                TET                        PIPTIME
#                         RIGNTION                   RN
#                         VIGNTION                   VN

# OUTPUTS -               PIPTIME                    AXISD
#                         RN                         /ACF/
#                         VN
#                         TULLG

#                         POINTVSM

# ERASABLES -             AMEMORY THROUGH            SAME
#                         AMEMORY +217 OCT
#                         PLUS 6 FOR CPT6/2 (NOT
#                         YET ASSIGNED)

# SUBROUTINES CALLED -    ROOTPSRS                   ROOTPSRS
#                         VPATCHER                   FINDCDUD
#                         CALCRVG                    THROTCON

## Page 817
                BANK            22
                EBANK=          E2DPS
# ************************************************************************
# INITIALIZATION OF SECOND DPS GUIDANCE - PREBURN
# ************************************************************************

PREBURN         =               INIT2DPS
INIT2DPS        TC              PRETINIT                # INITIALIZES INTERPRETER


# CLEAR ORBITAL INTEGRATION VARIABLES FROM REGISTERS IN COMMON WITH 2DPS

                TC              INTPRET
                DLOAD
                                TET                     # EXTRAPOLATED TIME FROM ORBITAL INTEGRATN
                STCALL          PIPTIME                 # TIME REGISTER OF PIPASR
                                VPATCHER                # TRANSFERS RIGNTION, VIGNTION TO RN, VN,
                EXIT                                    # AND DUPLICATES FUNCTIONS OF NORMLIZE
                TC              PHASCHNG                # PREVENTS REREADING ORBITAL INTEGRATION

 +402           OCT             04022                   # VARIABLES AFTER WRITING OVER THEM

# COMMON REGISTERS ARE CLEARED

                TC              INTPRET
                DLOAD
                                IGNALGL
                STOVL           AVGEXIT                 # SET UP RETURN ADDRESS IN AVGEXIT
                                ZEROPOS
                STORE           GDOTM1                  # DERIVATIVE OF G FOR USE BY IGNITN1
                STODL           UNAFC/2
                                ZEROPOS

                STORE           TTF/4TMP                # ZERO AS IF COMING FROM PREVIOUS PHASE
                EXIT
                CA              ZEROPOS
                TS              FLPASS0                 # SHOWS THIS IS INITIAL PASS THIS PHASE
                TC              XTRTPIP                 # SETS TPIP EXTRAPOLATED
                CA              POSMAX
                TS              /AFC/                   # FORCES INITIALIZATION OF COUNTFC
                TS              /AFC/           +1      # ONLY REASON: TO ASSURE GOOD PARITY
                TS              COUNTFCT                # ONLY REASON: TO ASSURE GOOD PARITY
                TC              AVGEXIT                 # RETURNS TO APPROPRIATE LOCATION IN 2DPS

## Page 818
# ************************************************************************
# SECOND DPS FLITE SEQUENCE TABLE
# ************************************************************************

# INDIRECT ADDRESSES

BURN            =               QUAD0X
BRTTFNU         =               1
PARL            =               2
TBRL            =               3
TTF/4CR         =               4
BRXEND          =               5

IGNALG          TCF             TTFINCR
                TCF             ADTTFNU                 # AS IF COMING FROM PREVIOUS PHASE
                OCT             00000
                ADRES           TBRIGAL
                DEC             -1.5            E2 B-15 # -1.5 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXIGEND

QUAD0X          TCF             TTFINCR
                TCF             RETTTFNU                # AS IF CONTINUING PREBURN PHASE
                OCT             00000

                ADRES           TBRQUAD
                DEC             -045            E2 B-15 # -045 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXQDLIN

QUAD0F          TCF             TTFINCR
                TCF             ADTTFNU
                OCT             00027
                ADRES           TBRQUAD
                DEC             -3.0            E2 B-15 # -3.0 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXQDLIN

LING0F          TCF             LSETEVN

                TCF             RETTTFNU
                OCT             00027
                ADRES           TBRLING
                DEC             -.50            E2 B-15 # -.50 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXQDLIN

LING1F          TCF             LSETODD
                TCF             ADTTFNU
                OCT             00056
                ADRES           TBRLING

                DEC             -.50            E2 B-15 # -.50 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXQDLIN

QUAD2F          TCF             TTFINCR
                TCF             ADTTFNU

## Page 819
                OCT             00065
                ADRES           TBRQUAD
                DEC             -3.0            E2 B-15 # -3.0 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXQDLIN

LING2F          TCF             LSETEVN

                TCF             RETTTFNU
                OCT             00065
                ADRES           TBRLING
                DEC             -.50            E2 B-15 # -.50 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXQDLIN

LING3F          TCF             LSETODD
                TCF             ADTTFNU
                OCT             00114
                ADRES           TBRLING
## The following line is supposed to read "DEC -.25 E2 B-15", which is supposed to
## assemble to the octal 77763 ... but actually assembles to 77762.  For the present,
## it is being hard-coded as "OCT 77763" as a workaround.
                OCT             77763                   # -.25 SECONDS, TTF UNITS, COMPARES TTF/4
                TCF             EXFINAL




# ************************************************************************
# SECOND DPS ROAD MAPS (BRANCH TABLES)
# ************************************************************************

# INDIRECT ADDRESSES

BRIGN1          =               0

BRLING          =               1
BRIGN2          =               2
BRXMID          =               3

TBRIGAL         TCF             IGNITN1
                TCF             TTF/4CL
                TCF             IGNITN2
                TCF             EXIGMID

TBRQUAD         TCF             RETIGN1
                TCF             TTF/4CL
                TCF             RETIGN2

                TCF             EXQDLIN

TBRLING         TCF             RETIGN1
                TCF             LINGUID
                TCF             RETIGN2
                TCF             EXQDLIN

## Page 820
# ************************************************************************
# INITIALIZATION FOR EACH PASS
# ************************************************************************

# NTLZPASS SETS INDICES, FILLS TPIPOLD, TPIP, R, V EVERY PASS; BRANCHES TO IGNITN1, ADTTFNU WHEN APPROPRIATE.

NTLZPASS        EXTEND
                QXCH            RETNTLZ

                TC              PRETINIT                # INITIALIZES INTERPRETER
# SET INDICES

                EXTEND
                INDEX           AVGEXIT
                DCA             PARL                    # LOADS ADRESES OF PARMTR AND BRANCH TABLS
                DXCH            NDX2DPS
                EXTEND
                DCS             NDX2DPS
                INDEX           FIXLOC
                DXCH            X1                      # LOADS BOTH INTRP NDX REGS, NEEDED OR NOT

# FILL TPIPOLD AND TPIP

                EXTEND
                DCA             TPIP

                DXCH            TPIPOLD
                TC              PHASCHNG                # PROTECT TPIPOLD AND
 +402           OCT             04022                   # PREVENT RETURNING TO PREVIOUS PROGRAM
                EXTEND
                DCA             PIPTIME
                DXCH            TPIP

# FILL R AND V

                TC              INTPRET

                VLOAD
                                RN
                STOVL           R                       # RN TO R WITHOUT RESCALING
                                VN
                VSR2
                STORE           V                       # VN TO V WITH SCALING ADJUSTMENT
                EXIT

# IGNITN1 AND ADTTFNU BRANCH DECISIONS

                INDEX           NDXBR
                TCF             BRIGN1                  # TO IGNITN1 WHEN APPROPRIATE

RETIGN1         TC              PHASCHNG                # RETURN HERE WHETHER OR NOT DO IGNITN1.
 +402           OCT             04022                   # PROTECT TTF/4TMP AS USED BY IGNITN1 FROM

## Page 821
                                                        # WIPEOUT BY ADTTFNU AND TTFINCR. ALSO
                                                        # PROTECT RTEMP, VTEMP FROM RS, VS (SHARE)

                CCS             FLPASS0
                TCF             TTFINCR         +1      # ON OTHER THAN FIRST PASS IN ANY PHASE.
                INDEX           AVGEXIT
                TCF             BRTTFNU                 # TO ADTTFNU WHEN APPROPRIATE


# ADD TTF/4NU TO TTF/4 FROM LAST PASS

ADTTFNU         EXTEND
                DCA             TTF/4
                DXCH            TTF/4TMP
                INDEX           NDX2DPS
                CA              TTF/4NU
                ADS             TTF/4TMP
                TC              PHASCHNG                # PROTECT TTF/4
 +402           OCT             04022

                EXTEND
                DCA             TTF/4TMP
                DXCH            TTF/4                   # RENEWED TTF/4

                TC              PHASCHNG                # PROTECT TTF/4TMP FROM WIPEOUT BY TTFINCR
 +402           OCT             04022
RETTTFNU        TC              RETNTLZ



# ************************************************************************
# INCREMENT TTF/4

# ************************************************************************

TTFINCR         TC              NTLZPASS
 +1             EXTEND
                DCS             TPIPOLD
                DXCH            MPAC
                EXTEND
                DCA             TPIP
                DAS             MPAC
                CA              TSCALE

                TC              DMPNSUB                 # (TPIP-TPIPOLD)/4 TO MPAC, TTF UNITS

                EXTEND
                DCA             TTF/4
                DAS             MPAC                    # YIELDS INCREMENTED TTF/4 IN MPAC
                DXCH            MPAC
                DXCH            TTF/4TMP
                TC              PHASCHNG                # PROTECT TTF/4
 +402           OCT             04022
                EXTEND

## Page 822
                DCA             TTF/4TMP

                DXCH            TTF/4                   # INCREMENTED TTF/4



# ************************************************************************
# SET UP STATE IN LOCAL, PLANE, SPHERICAL COORDINATES
# ************************************************************************

STUP2DPS        TC              INTPRET
                VLOAD           UNIT
                                R
                STOVL           CLT/2                   # DEFINITION OF MATRIX CLT/2

                                CPT6/2
                VXV             UNIT
                                CLT/2
                STOVL           CLT/2           +6
                                CLT/2
                VXV             VSL1
                                CLT/2           +6
                STOVL           CLT/2           +14
                                V
                MXV             VSL1

                                CLT/2                   # -      *     -
                STOVL           VL                      # VL = 2 CLT/2 V
                                R
                DOT             SL1
                                CPT6/2                  #         - -
                STOVL           RP2                     # RP2 = 2 R.CPT6/2
                                R
                VXV             DOT
                                V
                                CPT6/2
                SL1                                     #          - - -
                STOVL           MAP2                    # MAP2 = 2 R*V.CPT6/2

                                R
                ABVAL                                   #                 -
                STODL           RLENGTH                 # RLENGTH = ABVAL(R)
                                RP2
                DSQ             PDDL
                                RLENGTH
                DSQ             DSU
                SQRT                                    #                  2    2
                STODL           RC                      # RC = SQRT(RLENGTH -RP2 )
                                RLENGTH                 #               -

                STODL           RS                      # DEFINITION OF RS, FIRST COMPONENT
                                RC
                DDV
                                RLENGTH
                STODL           CRS2                    # COSINE (RS2) = RC/RLENGTH

## Page 823
                                RP2
                DDV
                                RLENGTH
                STODL           SRS2                    # SINE (RS2) = RP2/RLENGTH
                                RP2
                DDV

                                RC
                STODL           TRS2                    # TANGENT (RS2) = RP2/RC
                                SRS2
                SR1             ARCSIN
                DMP             SL3
                                PI/4                    #               -
                STODL           RS              +4      # DEFINITION OF RS, THIRD COMPONENT
                                VL              +4
                DDV             PDDL                    # THIS PUSH DOWN IS FOR 3RD COMP OF VS.
                                RLENGTH
                                VL              +2
                DDV             PDDL                    # THIS PUSH DOWN IS FOR 2ND COMP OF VS.

                                RC
                                VL
                VDEF                                    # DEFINITION OF SPHERICAL VELOCITY VECTOR
                STODL           VS
                                VS              +2
                DSQ
                DMP             DMP
                                SRS2
                                CRS2
                PDDL            DMP

                                VS              +4
                                VS
                DDV             SL1
                                RLENGTH
                DAD             DCOMP
                PDDL            DMP                     # THIS PUSH DOWN IS FOR 3RD COMP OF ASPRT.
                                VS              +2
                                VS
                DDV
                                RLENGTH
                PDDL            DMP
                                TRS2

                                VS              +4
                DMP
                                VS              +2
                DSU             SL1
                PDDL            DSQ                     # THIS PUSH DOWN IS FOR 2ND COMP OF ASPRT.
                                RLENGTH
                BDDV
                                MUEARTH
                PDDL            DSQ
                                VS              +4

## Page 824
                DMP                                     #                    -
                                RLENGTH                 #       THIS MONSTER ASPRT REPRESENTS

                PDDL            DSQ                     #       INCIDENTAL ACCELERATIONS; DUE
                                CRS2                    #       TO GRAVITY, CORIOLIS FORCES,
                PDDL            DSQ                     #       AND SO FORTH.
                                VS              +2
                DMP             DMP
                                RLENGTH
                DAD             DSU
                VDEF                                    # DEFINITION OF ASPRT
                STORE           ASPRT
                EXIT

                CA              ZERO                    #       SECOND COMPONENTS
                TS              RS              +2      #       OF RS AND VS ARE
                TS              RS              +3      #       ZEROED HERE TO PREVENT
                TS              VS              +2      #       OVERFLOW TROUBLE IN
                TS              VS              +3      #       THE ACS EQUATION.
                TC              PHASCHNG                # TIME ONLY?
 +402           OCT             04022
                INDEX           NDXBR
                TCF             BRLING                  # POSSIBLE BRANCH TO LINEAR GUIDANCE

## Page 825
# ************************************************************************
# TTF/4 COMPUTATION
# ************************************************************************

TTF/4CL         EXTEND
                INDEX           NDX2DPS
                DCA             JDS2
                DXCH            TABLTTF         +6      # A(3) = JDS2 TO TABLTTF

                EXTEND
                INDEX           NDX2DPS
                DCA             ADS             +4
                DDOUBL
                DXCH            MPAC
                CA              SP3/4
                TC              SHORTMP                 # LEAVING  A(2) IN MPAC
                DXCH            MPAC
                DXCH            TABLTTF         +4      # A(2) = (6 ADS2)/4 TO TABLTTF
                CA              BIT8

                TS              TABLTTF         +10     # FRACTIONAL PRECISION FOR TTF TO TABLE
                EXTEND
                DCA             VS              +4
                DXCH            MPAC
                CA              SP3/8
                TC              SHORTMP                 # YIELDS 6/16 VS2 IN MPAC
                EXTEND
                INDEX           NDX2DPS
                DCA             VDS             +4
                DDOUBL
                DXCH            MPAC
                DXCH            TABLTTF         +2      # STORE 6/16 VS2 IN TABLTTF

                CA              SP9/16
                TC              SHORTMP                 # YIELDS 18/16 VDS2 IN MPAC
                EXTEND
                DCS             RS              +4
                DXCH            MPAC                    # -RS2 TO MPAC, FETCHING 18/16 VDS2
                DAS             TABLTTF         +2      # A(1) = (6 VS2+18 VDS2)/16

                EXTEND
                INDEX           NDX2DPS
                DCA             RDS             +4

                DAS             MPAC                    # YIELDS -RS2+RDS2 IN MPAC
                CA              SP3/8
                TC              SHORTMP
                EXTEND
                DCA             MPAC
                DXCH            TABLTTF                 # A(0)  =-24(RS2-RDS2)/64

                INHINT                                  # SET INHIBITED LOOP TO STORE FOR DWNLINK
                CAF             ELEVEN                  # INITIALIZE INDEX TO DEC 11
RVSTOR          TS              RUPTREG1

## Page 826
                INDEX           RUPTREG1

                CA              RN1
                INDEX           RUPTREG1
                TS              RN                      # STORE UPDATED RN, VN
                CCS             RUPTREG1
                TCF             RVSTOR
                EXTEND
                DCA             PIPTIMET
                DXCH            PIPTIME                 # UPDATED PIPTIME
                EXTEND
                DCA             PIPTIME
                DXCH            STATIME                 # STATE TIME FOR DWNLINK
                RELINT

                TC              PHASCHNG                # TIME ONLY?
 +402           OCT             04022



# ************************************************************************
# QUADRATIC GUIDANCE - SPHERICAL ACCELERATION AS QUADRATIC TIME FUNCTION
# ************************************************************************

                                                        #  -
                                                        #  ACS EQUATION IS PROGRAMMED LIKE THIS:
                                                        #                        -  -
                                                        #          -  -      1/2(RS-RDS)
                                                        #         (VS+VDS) - -----------
                                                        #   -                   TTF/4      -
                                                        #   ACS = ---------------------- + ADS
                                                        #               2/3(TTF/4)

                TC              INTPRET
                DLOAD           DMP
                                TTF/4
                                2DPS2/3

                PDVL            VSU*
                                RS
                                RDS,1
                VSR1            V/SC
                                TTF/4
                PDVL            VAD*
                                VS
                                VDS,1
                VSU             V/SC
                VAD*
                                ADS,1
                STORE           ACS                     # BEHOLD, UNWORTHY MORTAL
                VSU
                                ASPRT                   # -      -     -
                STODL           AFCS                    # AFCS = ACS - ASPRT

## Page 827
                                RC
                DSQ             DMP
                                TTF/4
                PDDL            DSU
                                MAP2
                                MADP2

                SR2
                DDV             STADR                   #                           2
                STODL           AFCS            +2      # AFCS  = 1/4(MAP -MADP )/RC (TTF/4)
                                AFCS            +4      #     1          2     2



# ************************************************************************
# THRUST ACCEL POINTING AND MAGNITUDE COMMANDS - DUE TO QUAD OR LINR GUID
# ************************************************************************

AFCCALC         DMP             PDDL                    # COMES HERE FROM LINGUID.

                                RLENGTH
                                AFCS            +2
                DMP             PDDL
                                RC
                                AFCS
                VDEF            VXM
                                CLT/2
                VSL1                                    # -                                     *
                STORE           AFC                     # AFC = 2(AFCS , RC AFCS ,RLENGTH AFCS )CLT/2
                UNIT                                    #             0         1             2

                STODL           UNAFC/2
                                36D                     # MAGNITUDE OF AFC, /AFC/
                STORE           /AFC/                   # FOR IGNITION ALGORITHM
                SR1R                                    # CONVERTS /AFC/ TO THROTCON UNITS, /ACF/
                STORE           /ACF/                   # FOR THROTTLE CONTROL SUBR THROTCON
                EXIT
                INDEX           NDXBR
                TCF             BRIGN2

 -3             TS              OVFIND                  # RETURN FROM TTF/4 OVERFLOW
 -2             CA              FIVE                    # RETURN RESETTING COUNTFC
 -1             TS              COUNTFCT                # RETURN DECREMENTING COUNTFC

RETIGN2         TC              PHASCHNG                # RETURN (NORMAL) FROM IGNITN2
 +402           OCT             04022                   # PREVENT GOING FAR BACK IN 2DPS AFTR EXIT



# ************************************************************************
# PREPARE TO EXIT
# ************************************************************************

                INCR            FLPASS0                 # INCR FIRST PASS FLAG. REPEATS ARE OK.

## Page 828
                INDEX           AVGEXIT
                CS              TTF/4CR

                AD              TTF/4
                EXTEND
                INDEX           NDXBR
                BZMF            BRXMID                  # CONTINUE PRESENT PHASE

                CA              AVGEXIT                 # PREPARE FOR NEW PHASE
                TS              AVGXTEMP                # TEMPORARY PROTECTION FOR AVGEXIT
                TC              PHASCHNG                # PROTECT AVGEXIT
 +402           OCT             04022
                CA              AVGXTEMP

                AD              SIX
                TS              AVGEXIT
                CA              ZERO
                TS              FLPASS0                 # RESET FLAG INDICATING PASS ZERO (FIRST)
                INDEX           AVGXTEMP
                TCF             BRXEND

## Page 829
# ************************************************************************
# ROUTINES FOR EXITING FROM SECOND DPS GUIDANCE. THESE ARE:
# ************************************************************************

# 1.       EXIGMID CALLS CALCRVG AS AN INTERPRETIVE SUBROUTINE UP UNTIL BUT NOT INCLUDING THE LAST PASS DURING
#          THE PREBURN PHASE. UPON RETURN EXIGMID RESTARTS 2DPS.

# 2.       EXIGEND IS USED ON THE LAST PASS DURING PREBURN. IT SETS UP FOR KALCMANU, FOR THE SUBSEQUENT 2DPS

#          BURN, AND EXITS TO THE MISSION CONTROL PROGRAM.

# 3.       EXQDLIN IS USED TO TERMINATE EACH PASS UP UNTIL BUT NOT INCLUDING THE LAST PASS ON ALL 2DPS BURN
#          PHASES. EXQDLIN OBTAINS ATTITUDE AND THROTTLE CONTROL AND TERMINATES THE JOB.

# 4.       EXFINAL IS THE FINAL 2DPS EXIT. IT SETS UP THE ATTITUDE COMMAND FOR RANDOM THROTTLING, OBTAINS
#          ATTITUDE AND THROTTLE CONTROL, AND EXITS TO THE MISSION CONTROL PROGRAM.



# EXIGMID SETS UP FOR CALCRVG TO MOVE STATE FORWARD A SPECIFIED TIME, INITIALIZES THE INTERPRETER, CALLS CALCRVG
# AS AN INTERPRETIVE SUBROUTINE, AND UPON RETURN SETS UP FOR IGNALG AND BRANCHES INDIRECTLY THERETO.

EXIGMID         TC              PRETINIT                # INITIALIZES INTERPRETER FOR CALCRVG
                                                        # SUCCEEDING CODING MUST NOT UNDO

                TC              INTPRET
                DLOAD           DAD
                                PIGNALG
                                PIPTIME
                STOVL           PIPTIMET                # UPDATED PIPTIME TEMPORARY STORAGE
                                ZEROPOS
                STCALL          DELV                    # DELV = 0

                                CALCRVG                 # STEPS FORWARD IN TIME LEAVING RN1, VN1
                EXIT

                CA              E2DPSL                  # ASSURE CORRECT EBANK BEFORE
                TS              EBANK                   # DOING PHASCHNG
                TC              PHASCHNG                # PROTECT PIPTIME. PREVENT REDOING CALCRVG
 +402           OCT             04022
                TC              INTPRET
                DLOAD
                                PIPTIMET

                STOVL           PIPTIME                 # UPDATED PIPTIME
                                RN1
                STOVL           RN                      # UPDATED POSITION
                                VN1
                STORE           VN                      # UPDATED VELOCITY
                EXIT
                TC              AVGEXIT                 # RETURNS TO APPROPRIATE LOCATION IN 2DPS.

## Page 830

# EXIGEND EXTRAPOLATES UNAFC/2 TO TTF/4 = 0, SETS UP FOR MISSION CONTROL PROGRAM, SETS UP FOR THE SUCCEEDING

# BRAKING PHASE, AND EXITS TO THE MISSION CONTROL PROGRAM.

# EXTRAPOLATE UNAFC/2

# UNAFC/2 = UNAFC/2+(UNAFC/2-UNAFC/2O)(TTF)/(TPIPOLD-TPIP)

EXIGEND         EXTEND
                DCA             TPIPOLD
                DXCH            MPAC
                EXTEND
                DCS             TPIP
                DAS             MPAC

                CA              TSCALE
                EXTEND
                MP              BIT3                    # MULTIPLIES BY N = 4 LEAVING RESULT IN L
                CA              L                       # ASSUMES N(TPIPOLD-TPIP)/4>TTF/4 IN MAGN.
                TC              DMPNSUB                 # N(TPIPOLD-TPIP)/4 TO MPAC, TTF UNITS
                EXTEND
                DCA             TTF/4
                DXCH            MPAC                    # DIVIDEND TO MPAC
                DXCH            BUF                     # DIVISOR TO BUF
                TC              USPRCADR

                CADR            DDV/BDDV                # (TTF/4)/(N(TPIPOLD-TPIP)/4) TO MPAC

                CA              ZERO
                TS              MODE                    # TO INDICATE DP IN MPAC

                TC              INTPRET
                PDVL            VSU
                                UNAFC/2
                                UNAFC/20
                VSL2            VXSC                    # VSL2 UNDOES MP BIT3 PRECEDING
                                UNAFC/2
                VAD

                                UNAFC/2                 # YIELDS EXTRAPOLATED UNAFC/2

# SET UP FOR MISSION CONTROL PROGRAM

                STODL           POINTVSM                # STORE FOR KALCMANU
                                TTF/4
                DCOMP           DMP
                                TSCALINV
                DAD
                                PIPTIME

                STORE           TULLG                   # TIME AT WHICH ULLAGE IS TO START

# SET UP FOR BRAKING PHASE

                EXIT

## Page 831
                TC              PHASCHNG                # PROTECT TTF/4 AND PREVENT REREADING REG-
 +402           OCT             04022                   # ISTERS REWRITTEN BY MISN CONT PROGRAM
                EXTEND
                DCA             TTF/4TMP
                DXCH            TTF/4

# RETURN TO MISSION CONTROL PROGRAM

                TC              PRETINIT                # INITIALIZES INTERPRETER
                EXTEND
                DCA             RETPREBL
                DTCB

## Page 832
# EXQDLIN STORES THE SEMI-UNIT VECTOR DEFINING THE DIRECTION OF COMMANDED THRUST ACCELERATION (UNAFC/2) IN THE
# APPROPRIATE REGISTERS OF FINDCDUD (AXISD) AND CALLS FINDCDUD AS A SUBROUTINE.

# THEN EXQDLIN TRANSFERS THE COMMANDED THRUST ACCELERATION MAGNITUDE (/AFC/) TO THE APPROPRIATE REGISTERS OF
# THROTCON, (/ACF/), CHANGING SCALING, AND CALLS THROTCON AS A SUBROUTINE.
# FINALLY EXQDLIN TERMINATES THE JOB.

EXQDLIN         TC              INTPRET
                VLOAD
                                UNAFC/2
                STCALL          AXISD
                                FINDCDUD                # ATTITUDE CONTROL
                EXIT


                EXTEND
                DCA             THROTCOL
                DTCB                                    # THROTTLE CONTROL
                TC              ENDOFJOB                # TERMINATES THE JOB PERIODICALLY STARTED
                                                        # BY A WAITLIST CALL FROM READACCS



# EXFINAL IS THE FINAL EXIT FROM 2DPS. FIRST EXFINAL PLACES THE SEMI-UNIT NORMAL TO THE ORBITAL PLANE (CPT6/2)
# IN AXISD AND CALLS FINDCDUD AS A SUBROUTINE. THIS CAUSES FURTHER THRUSTING TO BE NORMAL TO THE ORBITAL PLANE.
# THEN EXFINAL TRANSFERS THE COMMANDED THRUST ACCELERATION MAGNITUDE (/AFC/) TO THE APPROPRIATE REGISTERS OF

# THROTCON, (/ACF/), CHANGING SCALING, AND CALLS THROTCON AS A SUBROUTINE.
# FINALLY EXFINAL RETURNS TO THE MISSION CONTROL PROGRAM WHICH EXECUTES THE RANDOM THROTTLING.

EXFINAL         TC              INTPRET
                VLOAD
                                CPT6/2
                STCALL          AXISD
                                FINDCDUD                # ATTITUDE CONTROL
                EXIT

                EXTEND
                DCA             THROTCOL
                DTCB                                    # THROTTLE CONTROL
                TC              PRETINIT                # INITIALIZES INTERPRETER
                EXTEND
                DCA             RETBURNL
                DTCB

## Page 833
# ************************************************************************
# SPECIAL PURPOSE SUBROUTINES OF SECOND DPS GUIDANCE
# ************************************************************************

# ************************************************************************
# IGNITION ALGORITHM
# ************************************************************************


# IGNITN1 EXTRAPOLATES THE GIVEN STATE FORWARD THROUGH THE TIME INTERVAL REQUIRED TO ACCOMPLISH ULLAGE AND TO
# LITE AT LOW THRUST AND TRIM THE ENGINE. THE EXTRAPOLATION ENDS AT THE TIME MAXIMUM THRUST WOULD BE COMMANDED
# IF THE LITEUP PROCEDURE WERE INITIATED AT THE CURRENT GIVEN TIME. (THE GIVEN TIME IS NOT TRUE. ALL GIVEN
# CONDITIONS INCLUDE A FREE-FALL EXTRAPOLATION OF THE ACTUAL ORBIT.) THE EXTRAPOLATION PERFORMED BY IGNITN1
# INCLUDES ALL EFFECTS OF ENGINE THRUST DURING THE LITEUP PROCEDURE, AND IT USES THE
# THRUST POINTING DIRECTION WHICH WILL BE COMMANDED AT THE INITIATION OF MAXIMUM THRUST.
# THIS EXTRAPOLATED STATE IS THEN FED TO THE GUIDANCE EQUATIONS, WHICH COMPUTE THE THRUST POINTING
# DIRECTION (UNAFC/2) AND THE THRUST ACCELERATION MAGNITUDE COMMAND (/AFC/).

# IGNITN2 THEN RECEIVES THIS OUTPUT DATA FROM THE GUIDANCE EQUATIONS AND DETERMINES WHETHER THE THRUST

# ACCELERATION MAGNITUDE COMMAND IS MONOTONICALLY INCREASING. WHEN IT IS, IGNITN2 USES THE PRESENT AND PREVIOUS
# VALUES TO COMPUTE ONE QUARTER OF THE PRESENT TIME (TTF/4) RELATIVE TO THE TIME AT WHICH THE THRUST
# ACCELERATION MAGNITUDE COMMAND WILL REACH THE CRITERION VALUE (/AFC/CR) WHICH CORRESPONDS TO MAXIMUM THROTTLE.
# WHEN TTF/4 SO COMPUTED REACHES THE TIME CRITERION FOR TERMINATING THE PREBURN PHASE (TTF/4CR),
# EXIGEND IS PROCESSED, TERMINATING THE PHASE AND RETURNING CONTROL TO THE MISSION CONTROL PROGRAM.
# THE MISSION CONTROL PROGRAM EXECUTES THE COMPUTED IGNITION SEQUENCE. IGNITN2 MUST ALSO, ON EACH PASS,
# REESTABLISH CERTAIN DATA REQUIRED FOR THE SUBSEQUENT PASS.

# IGNITION ALGORITHM PART 1
# ************************************************************************

# DO TEMPORARY STORAGE

IGNITN1         TC              INTPRET
                DLOAD
                                /AFC/
                STOVL           /AFC/OLD                # OLD VALUE OF /AFC/ FOR USE BY IGNITN2

                                UNAFC/2
                STOVL           UNAFC/20                # OLD VALUE OF UNAFC/2

# EXTRAPOLATE STATE


                                R
                STOVL           RDUM
                                V
                STOVL           VDUM
                                GDOTM1
                STODL           JDUM
                                PFCULLG                 # ULLAGE PERIOD
                STODL           PDUM                    # DUMMY PERIOD
                                AFULLG                  # LEAVE AFULLG IN MPAC

## Page 834
                CALL                                    # EXTRAPOLATES DUMMY STATE AND

                                XTRIGN1                 # LEAVES INITIAL GRAVITY IN GDUM

                VLOAD
                                GDUM
                STODL           GDUMPRES                # SAVE INITL GRAVITY FOR COMPUTING GDOTM1

                                PFCLITE                 # LITEUP PERIOD
                STODL           PDUM
                                AFLITE                  # LEAVE AFLITE IN MPAC
                CALL
                                XTRIGN1                 # EXTRAPOLATE


                DLOAD
                                PFCTRIM                 # TRIM PERIOD
                STODL           PDUM
                                AFTRIM                  # LEAVE AFTRIM IN MPAC
                CALL
                                XTRIGN1                 # YIELDS FINAL EXTRAPOLATED STATE

                VLOAD
                                RDUM
                STOVL           RTEMP                   # RESTART PROTECTION FOR EXTRAPOLATED R

                                VDUM
                STCALL          VTEMP                   # RESTART PROTECTION FOR EXTRAPOLATED V

# COMPUTE DERIVATIVE OF GRAVITY

                                GDUMCL                  # YIELDS FINAL GRAVITY IN MPAC AND GDUM
                VSU             V/SC
                                GDUMPRES
                                PPHM1                   # COMPLETES COMPUTATION OF DERIV OF G
                STORE           GDOTM1                  # FOR USE NEXT PASS. PROTECTION NOT RQD.
                EXIT


# GENERATION OF EXTRAPOLATED DATA COMPLETE. PROTECT AND TRANSFER TO STORAGE.

                TC              PHASCHNG                # PROTECT R, V
 +402           OCT             04022
                TC              INTPRET
                DLOAD
                                TTF/4TMP
                STOVL           TTF/4                   # RESTORES TTF/4 TO LAST VALUE BY GUIDANCE
                                RTEMP
                STOVL           R                       # EXTRAPOLATED R

                                VTEMP
                STORE           V                       # EXTRAPOLATED V
                EXIT
                CA              COUNTFCT
                TS              COUNTFC                 # FOR IGNITN2

## Page 835
                TC              XTRTPIP                 # YIELDS TPIP EXTRAPOLATED
                TCF             RETIGN1



# IGNITION ALGORITHM PART 2

# ************************************************************************

IGNITN2         EXTEND
                DCA             TTF/4
                DXCH            TTF/4TMP                # SAVE TTF/4 FOR NEXT PASS
                TC              PHASCHNG                # PROTECT TTF/4
 +402           OCT             04022
                CS              POSMAX
                TS              TTF/4                   # PREVENT PREMATURE TERMINATION OF PREBURN

# TEST WHETHER /AFC/ > /AFC/OLD, IF SO TEST WHETHER COUNTFC = 0.

                EXTEND
                DCA             /AFC/
                DXCH            MPAC
                EXTEND
                DCS             /AFC/OLD
                DAS             MPAC                    # /AFC/-/AFC/OLD IN MPAC

                CCS             MPAC                    # TEST HI ORDER
                TCF             TCOUNTFC
                TCF             TSTLOAFC

                TCF             RETIGN2         -2      # RESET COUNTFC
TSTLOAFC        CA              MPAC            +1      # TEST LO ORDER
                EXTEND
                BZMF            RETIGN2         -2      # RESET COUNTFC
TCOUNTFC        CCS             COUNTFC
                TCF             RETIGN2         -1      # DECREMENT COUNTFC

# RESET TTF/4 BY EXTRAPOLATING /AFC/

# TTF/4 = (1/4)(TPIPOLD-TPIP)(/AFC/-/AFC/CR)/(/AFC/OLD-/AFC/)

                EXTEND

                DCA             TPIPOLD
                DXCH            MPAC
                EXTEND
                DCS             TPIP
                DAS             MPAC
                CA              TSCALE
                TC              DMPNSUB                 # (1/4)(TPIPOLD-TPIP) TO MPAC, TTF UNITS

                EXTEND
                DCA             /AFC/

## Page 836
                DXCH            MPAC            +3
                EXTEND

                DCS             /AFC/CR
                DAS             MPAC            +3
                TC              DMP
                GENADR          MPAC            +3

                EXTEND
                DCA             /AFC/OLD
                DXCH            BUF
                EXTEND
                DCS             /AFC/

                DAS             BUF
                TC              USPRCADR
                CADR            DDV/BDDV                # YIELDS TTF/4 IN MPAC

                CCS             OVFIND
                TCF             RETIGN2         -3      # IF TTF/4 OVFL. RESETS OVFIND, COUNTFC.

                DXCH            MPAC
                DXCH            TTF/4
                TCF             RETIGN2



# ************************************************************************
# SPECIAL PURPOSE STATE EXTRAPOLATION SUBROUTINE FOR IGNITN1
# ************************************************************************

# XTRIGN1 RECEIVES THE EXTRAPOLATION PERIOD IN PDUM; THE INITIAL STATE IN RDUM, VDUM; THE THRUST ACCELERATION
# MAGNITUDE IN MPAC, DIRECTION IN UNAFC/2; AND JERK IN JDUM.

# IT LEAVES GRAVITY IN GDUM, THE TOTAL INITIAL ACCELERATION IN ADUM, AND THE EXTRAPOLATED STATE IN RDUM, VDUM.

# PRESENTLY THE DUM REGISTERS OCCUPY LOCATIONS FIXLOC +6 THRU FIXLOC +45 OCTAL.

XTRIGN1         STQ
                                RETXIGN1                # SAVE QPRET
                SL1             VXSC
                                UNAFC/2
                PUSH            CALL                    # PUSHES AF UNAFC
                                GDUMCL                  # YIELDS GRAVITY IN MPAC AND GDUM
                VAD             STADR
                STORE           ADUM                    # ADUM = AF UNAFC+G
                CALL
                                XTRDUMST                # EXTRAPOLATES RDUM, VDUM
                GOTO
                                RETXIGN1

## Page 837
# ************************************************************************
# LINEAR GUIDANCE - SPHERICAL ACCELERATION AS LINEAR TIME FUNCTION
# ************************************************************************

# SET LINEAR GUIDANCE COEFFICIENTS IN EVEN NUMBERED PHASES
# ************************************************************************

LSETEVN         TC              NTLZPASS

                TC              INTPRET
                VLOAD*
                                ADS,1                   # -       -
                STODL           ALINS                   # ALINS = ADS
                                AFCS            +2
                DAD
                                ASPRT           +2
                STORE           ACS             +2
                STOVL           ALINS           +2      # ALINS  = ACS  = AFCS  + ASPRT
                                ALINS                   #      2      2       2        2
                GOTO
                                LINSET

# SET LINEAR GUIDANCE COEFFICIENTS IN ODD NUMBERED PHASES
# ************************************************************************

LSETODD         TC              NTLZPASS
                TC              INTPRET
                VLOAD*
                                ADS,1                   # -       -
                STORE           ALINS                   # ADINS = ADS


# COMMON PARTS OF LSETEVN AND LSETODD
# ************************************************************************

LINSET          BVSU
                                ACS
                VSR2            V/SC
                                TTF/4                   # -            -     -
                STORE           JLINS                   # JLINS = 1/4 (ACS - ALINS)/(TTF/4)
                EXIT
                TCF             TTFINCR         +1

# LINEAR GUIDANCE EQUATIONS
# ************************************************************************

LINGUID         TC              INTPRET
                VLOAD           VXSC
                                JLINS
                                TTF/4
                VSL2
                VAD             VSU

## Page 838
                                ALINS

                                ASPRT                   # -        -               -       -
                STODL           AFCS                    # AFCS = 4 JLINS/(TTF/4) + ALINS - ASPRT
                                AFCS            +4
                GOTO
                                AFCCALC



# ************************************************************************
# SUBROUTINE TO SET TPIP EXTRAPOLATED
# ************************************************************************

XTRTPIP         EXTEND
                DCA             PIPTIME
                DXCH            TPIP
                EXTEND
                DCA             PPHM1CS
                DAS             TPIP
                TC              Q

## Page 839
# ************************************************************************
# GENERAL PURPOSE SUBROUTINES CONTRIBUTED BY SECOND DPS GUIDANCE
# ************************************************************************

# ************************************************************************
# DOUBLE PRECISION ROOT FINDER SUBROUTINE
# ************************************************************************

#                                                         N        N-1
#          ROOTPSRS FINDS ONE ROOT OF THE POWER SERIES A X  + A   X    + ... + A X + A
#                                                       N      N-1              1     0

# USING NEWTON'S METHOD STARTING WITH AN INITIAL GUESS FOR THE ROOT. THE ENTERING DATA MUST BE AS FOLLOWS:

#                                         A        SP     LOC-3           ADRES FOR REFERENCING PWR COF TABL
#                                         L        SP     N-1             N IS THE DEGREE OF THE POWER SERIES
#                                         MPAC     DP     X               INITIAL GUESS FOR ROOT

#                                         LOC-2N   DP     A(0)
#                                                  ...
#                                         LOC      DP     A(N)
#                                         LOC+2    SP     PRECROOT        PREC RQD OF ROOT (AS FRACT OF 1ST GUESS)

# THE DP RESULT IS LEFT IN MPAC UPON EXIT, AND A SP COUNT OF THE ITERATIONS TO CONVERGENCE IS LEFT IN MPAC+2.
# RETURN IS TO LOC(TC POWRSERS)+1.

#          PRECAUTION: ROOTPSRS MAKES NO CHECKS FOR OVERFLOW OR FOR IMPROPER USAGE. IMPROPER USAGE COULD
# PRECLUDE CONVERGENCE OR REQUIRE EXCESSIVE ITERATIONS. AS A SPECIFIC EXAMPLE, ROOTPSRS FORMS A DERIVATIVE

# COEFFICIENT TABLE BY MULTIPLYING EACH A(I) BY I, WHERE I RANGES FROM 1 TO N. IF AN ELEMENT OF THE DERIVATIVE
# COEFFICIENT TABLE = 1 OR > 1 IN MAGNITUDE, ONLY THE EXCESS IS RETAINED. ROOTPSRS MAY CONVERGE ON THE CORRECT
# ROOT NONETHELESS, BUT IT MAY TAKE AN EXCESSIVE NUMBER OF ITERATIONS. THEREFORE THE USER SHOULD RECOGNIZE:

# 1. USER'S RESPONSIBILITY TO ASSURE THAT I X A(I) < 1 IN MAGNITUDE FOR ALL I.

# 2. USER'S RESPONSIBILITY TO ASSURE OVERFLOW WILL NOT OCCUR IN EVALUATING EITHER THE RESIDUAL OR THE DERIVATIVE
#    POWER SERIES. THIS OVERFLOW WOULD BE PRODUCED BY SUBROUTINE POWRSERS, CALLED BY ROOTPSRS, AND MIGHT NOT
#    PRECLUDE EVENTUAL CONVERGENCE.

# 3. AT PRESENT, ERASABLE LOCATIONS ARE RESERVED ONLY FOR N UP TO 5. AN N IN EXCESS OF 5 WILL PRODUCE CHAOS.
#    ALL ERASABLES USED BY ROOTPSRS ARE UNSWITCHED LOCATED IN THE REGION FROM MPAC-33 OCT TO MPAC+7.

# 4. THE ITERATION COUNT RETURNED IN MPAC+2 MAY BE USED TO DETECT ABNORMAL PERFORMANCE.

                                                        # STORE ENTERING DATA, INITLIZE ERASABLES

ROOTPSRS        EXTEND
                QXCH            RETROOT                 # RETURN ADRES
                TS              PWRPTR                  # PWR TABL POINTER
                DXCH            MPAC            +3      # PWR TABL ADRES, N-1
                CA              DERTABLL

## Page 840
                TS              DERPTR                  # DER TABL POINTER
                TS              MPAC            +5      # DER TABL ADRES

                CCS             MPAC            +4      # NO POWER SERIES OF DEGREE 1 OR LESS
                TS              MPAC            +6      # N-2
                CA              ZERO                    # MODE USED AS ITERATION COUNTER. MODE
                TS              MODE                    # MUST BE POS SO ABS WON'T COMP MPAC+3 ETC

                                                        # COMPUTE CRITERION TO STOP ITERATING

                EXTEND
                DCA             MPAC                    # FETCH ROOT GUESS, KEEPING IT IN MPAC
                DXCH            ROOTPS                  # AND IN ROOTPS

                INDEX           MPAC            +3      # PWR TABL ADRES
                CA              5                       # PRECROOT TO A
                TC              SHORTMP                 # YIELDS DP PRODUCT IN MPAC
                TC              USPRCADR
                CADR            ABS                     # YIELDS ABVAL OF CRITERION ON DX IN MPAC
                DXCH            MPAC
                DXCH            DXCRIT                  # CRITERION

                                                        # SET UP DER COF TABL

                EXTEND
                INDEX           PWRPTR

                DCA             3
                DXCH            MPAC                    # A(N) TO MPAC

                CA              MPAC            +4      # N-1 TO A

DERCLOOP        TS              PWRCNT                  # LOOP COUNTER
                AD              ONE
                TC              DMPNSUB                 # YIELDS DERCOF = I X A(I) IN MPAC
                EXTEND
                INDEX           PWRPTR

                DCA             1
                DXCH            MPAC                    # A(I-1) TO MPAC, FETCHING DERCOF
                INDEX           DERPTR
                DXCH            3                       # DERCOF TO DER TABL
                CS              TWO
                ADS             PWRPTR                  # DECREMENT PWR POINTER
                CS              TWO
                ADS             DERPTR                  # DECREMENT DER POINTER
                CCS             PWRCNT
                TCF             DERCLOOP

                                                        # CONVERGE ON ROOT


ROOTLOOP        EXTEND
                DCA             ROOTPS                  # FETCH CURRENT ROOT
                DXCH            MPAC                    # LEAVE IN MPAC

## Page 841
                EXTEND
                DCA             MPAC            +5      # LOAD A, L WITH DER TABL ADRES, N-2
                TC              POWRSERS                # YIELDS DERIVATIVE IN MPAC

                EXTEND
                DCA             ROOTPS
                DXCH            MPAC                    # CURRENT ROOT TO MPAC, FETCHING DERIVTIVE
                DXCH            BUF                     # LEAVE DERIVATIVE IN BUF AS DIVISOR

                EXTEND
                DCA             MPAC            +3      # LOAD A, L WITH PWR TABL ADRES, N-1
                TC              POWRSERS                # YIELDS RESIDUAL IN MPAC

                TC              USPRCADR
                CADR            DDV/BDDV                # YIELDS -DX IN MPAC

                EXTEND
                DCS             MPAC                    # FETCH DX, LEAVING -DX IN MPAC
                DAS             ROOTPS                  # CORRECTED ROOT NOW IN ROOTPS


                TC              USPRCADR
                CADR            ABS                     # YIELDS ABS(DX) IN MPAC
                EXTEND
                DCS             DXCRIT
                DAS             MPAC                    # ABS(DX)-ABS(DXCRIT) IN MPAC

                INCR            MODE                    # INCREMENT ITERATION COUNTER

                CCS             MPAC                    # TEST HI ORDER DX
                TCF             ROOTLOOP
                TCF             TESTLODX

                TCF             ROOTSTOR
TESTLODX        CCS             MPAC            +1      # TEST LO ORDER DX
                TCF             ROOTLOOP
                TCF             ROOTSTOR
                TCF             ROOTSTOR
ROOTSTOR        DXCH            ROOTPS
                DXCH            MPAC                    # STORE DP ROOT IN MPAC, MPAC+1
                CA              MODE
                TS              MPAC            +2      # STORE SP ITERATION COUNT IN MPAC+2
                TC              RETROOT

DERTABLL        ADRES           DERCOFN         -3

## Page 842
# ************************************************************************
# GENERAL PURPOSE SUBROUTINE FOR EXTRAPOLATING DUMMY STATE RDUM, VDUM
# ************************************************************************

# XTRDUMST REQUIRES THE EXTRAPOLATION PERIOD, INITIAL POSITION, INITIAL VELOCITY, INITIAL ACCELERATION, JERK
# TO ARRIVE IN PDUM, RDUM, VDUM, ADUM, JDUM.

# IT LEAVES THE EXTRAPOLATED STATE IN RDUM, VDUM.

# PRESENTLY THE DUM REGISTERS ARE LOCATIONS FIXLOC +6 THRU FIXLOC +31 OCTAL, AND FIXLOC +40 OCTAL THRU
# FIXLOC +45 OCTAL.

#                                             2            3
# THE EQNS ARE RDUM = RDUM+VDUM PDUM+ADUM PDUM /2+JDUM PDUM /6,

#                                             2
#              VDUM = VDUM+ADUM PDUM+JDUM PDUM /2.

# THEY ARE PROGRAMMED AS RDUM = ((JDUM PDUM/3+ADUM)PDUM/2+VDUM)PDUM+RDUM

#                        VDUM = (JDUM PDUM/2+ADUM)PDUM+VDUM

XTRDUMST        DLOAD
                                PDUM
                DMP             VXSC

                                1/3DP
                                JDUM
                VAD             VXSC
                                ADUM
                                PDUM
                VSR1            VAD
                                VDUM
                VXSC            VAD
                                PDUM
                                RDUM
                STODL           RDUM                    # EXTRAPOLATED RDUM. NO RESTART PROTECTION


                                PDUM
                SR1R            VXSC
                                JDUM
                VAD             VXSC
                                ADUM
                                PDUM
                VAD
                                VDUM
                STORE           VDUM                    # EXTRAPOLATED VDUM. NO RESTART PROTECTION
                RVQ

## Page 843
# ************************************************************************
# DUMMY GRAVITY SUBROUTINE
# ************************************************************************

# GDUMCL COMPUTES GRAVITY GIVEN POSITION IN RDUM, LEAVING RESULT IN MPAC AND GDUM.

#                                         2
# GDUM =-MUEARTH UNIT(RDUM)/((ABVAL(RDUM)) )

GDUMCL          VLOAD           VCOMP
                                RDUM
                UNIT            VXSC
                                MUEARTH
                V/SC            VSL1                    # SHIFT COMPENSATES FOR SEMI-UNIT
                                42
                STORE           GDUM
                RVQ



# ************************************************************************
# INTERPRETER INITIALIZATION SUBROUTINE
# ************************************************************************

PRETINIT        CA              FIXLOC
                TS              PUSHLOC
                CA              ZERO
                TS              OVFIND
                TC              Q

## Page 844
# ************************************************************************
# SECOND DPS TARGET PARAMETERS

# ************************************************************************

# PARAMETER TABLE INDIRECT ADDRESSES

TTF/4NU         =               TTF/4N0X
ADS             =               A0XS
RDS             =               R0XS
VDS             =               V0XS
JDS2            =               J0XS2
MADP2           =               MA0XP2

#
# A CONSISTENT SET OF UNITS IS USED THRUOUT THE SECOND DPS GUIDANCE. THESE UNITS ARE:
# TIME 2(  15)CS; LENGTH 2(  24)M; ANGLE 2(   0)RAD.

# IGNITION ALGORITHM - PREBURN PARAMETERS
# ************************************************************************

PPHM1           2DEC*           +3.350000000    E+3  B-15*

PPHM1CS         2DEC*           +3.350000000    E+3  B-28*

/AFC/CR         2DEC*           +2.965861098    E-4  B+6*


PFCULLG         2DEC*           +7.500000000    E+2  B-15*

AFULLG          2DEC*           +6.074952094    E-6  B+6*

PFCLITE         2DEC*           +3.000000000    E+2  B-15*

AFLITE          2DEC*           +3.198162867    E-5  B+6*

PFCTRIM         2DEC*           +2.300000000    E+3  B-15*


AFTRIM          2DEC*           +3.202931538    E-5  B+6*

## Page 845
# PARAMETER TABLE FOR BURN PHASES
# ************************************************************************

TTF/4N0X        DEC*            -1.125000000    E+4  B-15*

A0XS            2DEC*           -8.572092116    E-5  B+6*

                2DEC            0


                2DEC*           +7.269884947    E-11 B+30*

R0XS            2DEC*           +6.713370537    E+6  B-24*

                2DEC            0

                2DEC*           +1.056080555    E-2  B-0*

V0XS            2DEC*           -1.071382748    E+0  B-9*


                2DEC            0

                2DEC*           -9.160545259    E-7  B+15*

J0XS2           2DEC*           +1.194804087    E-15 B+45*

MA0XP2          2DEC*           +5.156859816    E+8  B-33*

## Page 846
TTF/4N0F        DEC*            -2.500000000    E+3  B-15*


A0FS            2DEC*           -5.038447857    E-5  B+6*

                2DEC            0

                2DEC*           +4.273045103    E-11 B+30*

R0FS            2DEC*           +6.700335070    E+6  B-24*

                2DEC            0

                2DEC*           +3.369214099    E-3  B-0*


V0FS            2DEC*           -1.545589897    E+0  B-9*

                2DEC            0

                2DEC*           -5.138853270    E-7  B+15*

J0FS2           2DEC*           +5.027062289    E-16 B+45*

MA0FP2          2DEC*           +5.156859816    E+8  B-33*



TTF/4NU1        DEC*            -1.000000000    E+2  B-15*

A1FS            2DEC*           +5.044035031    E-5  B+6*

                2DEC            0

                2DEC*           +4.277783493    E-11 B+30*

## Page 847
## Workaround: the following line has been changed to OCT because yaYUL produces
##             slightly different numerical results. The original was as follows:
## TTF/4NU2        DEC*            -3.375000000    E+3  B-15*
TTF/4NU2        OCT             74550

A2FS            2DEC*           +1.331951587    E-4  B+6*

                2DEC            0


                2DEC*           +1.991810043    E-11 B+30*

R2FS            2DEC*           +6.687217073    E+6  B-24*

                2DEC            0

                2DEC*           +1.144811884    E-5  B-0*

V2FS            2DEC*           -1.198407174    E-1  B-9*

                2DEC            0

                2DEC*           -2.215170344    E-8  B+15*

J2FS2           2DEC*           -3.386627333    E-15 B+45*

MA2FP2          2DEC*           +5.156859816    E+8  B-33*



TTF/4NU3        DEC*            -2.500000000    E+2  B-15*

A3FS            2DEC*           +1.536879692    E-13 B+6*

                2DEC            0

                2DEC*           +2.438530673    E-11 B+30*

## Page 848
# ************************************************************************
# SECOND DPS CONSTANTS

# ************************************************************************

# ADDRESS CONSTANTS

E2DPSL          ECADR           E2DPS                   # FOR ACCESSING EBANK OF 2DPS
                EBANK=          E2DPS
IGNALGL         2BCADR          IGNALG


                                                        # THE NEXT TWO CONSTANTS MUST BE KEPT
                                                        # IN ORDER AND ADJACENT
TABLTTFL        ADRES           TABLTTF         +3      # ADRES TO REF TTF TABL
DEGTTF-1        OCT             2                       # DEGREE-1 OF TTF POWER SERIES

                EBANK=          EMP11JOB
RETPREBL        2BCADR          RETPREB

                EBANK=          EMP11JOB
RETBURNL        2BCADR          RETBURN

                EBANK=          ETHROT
THROTCOL        2BCADR          THROTCON


# ARITHMETIC FRACTIONS AND INTEGERS

TSCALE          =               BIT12

TSCALINV        OCT             00010
ZEROPOS         OCT             00000                   # LO ORDER PART OF TSCALINV, AND
                OCT             00000                   # FIRST COMPONENT OF ZERO VECTOR
ZERONEG         OCT             77777

                OCT             77777
                OCT             00000                   # LAST COMPONENT OF ZERO VECTOR, AND
PIGNALG         OCT             00000                   # HI ORDER PART OF PIGNALG, TPIP UNITS
                DEC             +2              E+2B-14 # LO ORDER PART OF PIGNALG, TPIP UNITS

1/3DP           2DEC            .3333333333

## The following line is "SP3/8 OCT .3 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
SP3/8           DEC             .375            B14
## The following line is "SP9/16 OCT .44 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
SP9/16          DEC             .5625           B14
2/3DP           2DEC            .6666666667

2DPS2/3         =               2/3DP
## The following line is "SP3/4 OCT .6 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
SP3/4           DEC             .75             B14
PI/4            2DEC            +3.14159265     B-2


## Page 849

# ************************************************************************
# VARIOUS TEMPORARY TEST ROUTINES FOR SUBROUTINES CONTRIBUTED BY 2DPS
# ************************************************************************

# TEST ROOTPSRS ON 5TH DEGREE POWER SERIES

RUTTEST         EXTEND
                DCA             RUTINIT

                DXCH            MPAC

                EXTEND
                DCA             RUTTABLL
                TC              ROOTPSRS

# TEST POLY ON SIN 30 DEGREES

POLYTEST        TC              INTPRET
                DLOAD           SIN

                                QTSTPOLY

# TEST USEPRET ON V/SC

                STOVL           RC
                                A2FS
                STORE           RS
                EXIT
                CA              OCT1/2L
                TS              ADDRWD
                TC              USEPRET
                TC              V/SC

                TC              INTPRET
                STORE           VS
                EXIT
END2DPST        CA              ONE

# TEMP CONSTANTS FOR TESTS
## The following line is "RTUNIT OCT .6 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
RUTINIT         DEC             .75              B14
                OCT             0

                OCT             0
                OCT             0

## The following line is "OCT +.001 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
                DEC             1.953125        E-3 B14
                OCT             0

                OCT             0
                OCT             0

## The following line is "OCT -.024 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
                DEC             -3.90625        E-2 B14

## Page 850
                OCT             0

                OCT             0
                OCT             0

## The following line is "RUTTABL OCT +.100 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
RUTTABL         DEC             +.125           B14
                OCT             0

RUTPREC         OCT             1

RUTTABLL        ADRES           RUTTABL         -3
                OCT             4

QTSTPOLY        2DEC            .083333333

## The following line is "OCT1/2 OCT .4 B14" in the original program listing, but the yaYUL
## assembler does not syntactically support this syntax for OCT, so it has been replaced
## by a numerical equivalent that the assembler does support.
OCT1/2          DEC             .5              B14
                OCT             0
OCT1/2L         ADRES           OCT1/2
