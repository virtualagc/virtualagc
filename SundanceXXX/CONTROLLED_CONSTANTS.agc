### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CONTROLLED_CONSTANTS.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Reference:   pp. 53-69
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

# DPS AND APS ENGINE PARAMETERS

                SETLOC          P40S
                BANK
                COUNT*          $$/P40

# *** THE ORDER OF THE FOLLOWING SIX CONSTANTS MUST NOT BE CHANGED ***

FDPS            2DEC            4.3670          B-7     # 9817.5 LBS FORCE IN NEWTONS
MDOTDPS         2DEC            0.1480          B-3     # 32.62 LBS/SEC IN KGS/CS.
DTDECAY         2DEC            -38
FAPS            2DEC            1.5569          B-7     # 3500 LBS FORCE IN NEWTONS
MDOTAPS         2DEC            0.05135         B-3     # 11.32 LBS/SEC IN KGS/CS
ATDECAY         2DEC            -10

# ************************************************************************

FRCS4           2DEC            0.17792         B-7     # 400 LBS FORCE IN NEWTONS
FRCS2           2DEC            0.08896         B-7     # 200 LBS FORCE IN NEWTONS

                SETLOC          P40S1
                BANK
                COUNT*          $$/P40

# *** APS IMPULSE DATA FOR P42 *******************************************

K1VAL           2DEC            124.55          B-23    # 2800 LB-SEC
K2VAL           2DEC            31.138          B-24    # 700  LB-SEC
K3VAL           2DEC            1.5569          B-10    # FAPS ( 3500 LBS THRUST)

# ************************************************************************

S40.136         2DEC            .4671           B-9     # .4671 M NEWTONS (DPS)
S40.136_        2DEC            .4671           B+1     # S40.136 SHIFTED LEFT 10.
                SETLOC          ABORTS
                BANK
                COUNT*          $$/P70

(1/DV)A         2DEC            15.20           B-7     # 2 SECONDS WORTH OF INITIAL ASCENT

                                                        # STAGE ACCELERATION -- INVERTED (M/CS)
                                                        # 1) PREDICATED ON A LIFTOFF MASS OF
                                                        #    4869.9 KG (SNA-8-D-027  7/11/68)
                                                        # 2) PREDICATED ON A CONTRIBUTION TO VEH-
                                                        #    ICLE ACCELERATION FROM RCS THRUSTERS
                                                        #    EQUIV. TO 1 JET ON CONTINUOUSLY.
K(1/DV)         2DEC            436.70          B-9     # DPS ENGINE THRUST IN NEWTONS / 100 CS.

(AT)A           2DEC            3.2883          E-4 B9  # INITIAL ASC. STG. ACCELERATION ** M/CS.
                                                        # ASSUMPTIONS SAME AS FOR (1/DV)A.
(TBUP)A         2DEC            91902           B-17    # ESTIMATED BURN-UP TIME OF THE ASCENT STG
                                                        # ASSUMPTIONS SAME AS FOR (1/DV)A WITH THE
                                                        # ADDITIONAL ASSUMPTION THAT NET MASS-FLOW
                                                        # RATE = 5.299 KG/SEC = 5.135 (APS) +
                                                        # .164 (1 RCS JET).
                SETLOC          ASENT
                BANK
                COUNT*          $$/ASENT
AT/RCS          2DEC            .0000785        B+10    # 4 JETS IN A DRY LEM
                SETLOC          SERVICES
                BANK
                COUNT*          $$/SERV

# *** THE ORDER OF THE FOLLOWING TWO CONSTANTS MUST NOT BE CHANGED *******

APSVEX          DEC             -3030           E-2 B-5 # 9942 FT/SEC IN M/CS.

DPSVEX          DEC*            -2952           E-2 B-5 # 9684 FT/SEC IN M/CS.

# ************************************************************************

                SETLOC          F2DPS*31
                BANK
                COUNT*          $$/F2DPS

TRIMACCL        2DEC*           +3.7055         E-5 B+8*# ACCELERATION DURING TRIM PHASE.

# THROTTLING AND THRUST DETECTION PARAMETERS

                SETLOC          P40S
                BANK
                COUNT*          $$/P40

THRESH1         DEC             24

THRESH3         DEC             12

HIRTHROT        =               BIT13

                SETLOC          FFTAG5
                BANK
                COUNT*          $$/P40

THRESH2         DEC             308

                SETLOC          FTHROT
                BANK
                COUNT*          $$/THROT

FMAXODD         DEC             +3866                   # THROTTLE SATURATION THRESHOLD

FMAXPOS         DEC             +3594                   # FMAX    43245 NEWTONS
THROTLAG        DEC             20                      # EMPIRICALLY DETERMINED THROTTLE LAG TIME

                SETLOC          F2DPS*32
                BANK
                COUNT*          $$/F2DPS

DPSTHRSH        DEC             36                      # (THRESH1 + THRESH3 FOR P63)

# LM HARDWARE-RELATED PARAMETERS


                SETLOC          RADARUPT
                BANK
                COUNT*          $$/RRUPT

LVELBIAS        DEC             -12288                  # LANDING RADAR BIAS FOR 153.6 KC.
RDOTBIAS        2DEC            17000                   # BIAS COUNT FOR RR RANGE RATE.

                SETLOC          LRS22
                BANK
                COUNT*          $$/LRS22

RDOTCONV        2DEC            -.0019135344    B7      # CONVERTS RR RDOT READING TO M/CS AT 2(7)
RANGCONV        2DEC            2.859024        B-3     # CONVERTS RR RANGE READING TO M. AT 2(-29
                SETLOC          FTHROT
                BANK
                COUNT*          $$/THROT

SCALEFAC        2DEC            51.947          B-12    # SCALES A (AT 2(-4) M/CS/CS) TIMES MASS
                                                        # (AT 2(16) KGS. ) TO PULSE UNITS.

                SETLOC          SERVICES
                BANK
                COUNT*          $$/SERV

HBEAMANT        2DEC            -.4687018041            # RANGE BEAM IN LR ANTENNA COORDINATES.
                2DEC            0
                2DEC            -.1741224271

HSCAL           2DEC            -.3288792               # SCALES 1.079 FT/BIT TO 2(22)M.
# ***** THE SEQUENCE OF THE FOLLOWING CONSTANTS MUST BE PRESERVED ********

VZSCAL          2DEC            +.5410829105            # SCALES .8668 FT/SEC/BIT TO 2(18) M/CS.
VYSCAL          2DEC            +.7565672446            # SCALES 1.212 FT/SEC/BIT TO 2(18) M/CS.
VXSCAL          2DEC            -.4020043770            # SCALES -.644 FT/SEC/BIT TO 2(18) M/CS.

# ************************************************************************

KPIP            DEC             .0512                   # SCALES DELV TO UNITS OF 2(5) M/CS.
KPIP1           2DEC            .0128                   # SCALES DELV TO UNITS OF 2(7) M/CS.
KPIP2           2DEC            .0064                   # SCALES DELV TO UNITS OF 2(8) M/CS.

ALTCONV         2DEC            1.399078846     B-4     # CONVERTS M*2(-24) TO BIT UNITS *2(-28).
ARCONV1         2DEC            656.167979      B-10    # CONV. ALTRATE COMP. TO BIT UNITS<
                SETLOC          R10
                BANK
                COUNT*          $$/R10

ARCONV          OCT             24402                   # 656.1679798B-10 CONV ALTRATE TO BIT UNIT

ARTOA           DEC             .1066098        B-1     # .25/2.345 B-1 4X/SEC CYCLE RATE.

ARTOA2          DEC             .0021322        B8      # (.5)/(2.345)(100)

VELCONV         OCT             22316                   # 588.914 B-10 CONV VEL. TO BIT UNITS.

KPIP1(5)        DEC             .0512                   # SCALES DELV TO M/CS*2(-5).

MAXVBITS        OCT             00547                   # MAX. DISPLAYED VELOCITY 199.9989 FT/SEC.

                SETLOC          DAPS3
                BANK
                COUNT*          $$/DAPAO

TORKJET1        DEC             .03757                  # 550 / .2 SCALED AT (+16) 64 / 180

# PARAMETERS RELATING TO MASS, INERTIA, AND VEHICLE DIMENSTIONS


                SETLOC          FRANDRES
                BANK
                COUNT*          $$/START

                SETLOC          DAPS3
                BANK
                COUNT*          $$/DAPAO

LOASCENT        DEC             2200            B-16    # MIN ASCENT LEM MASS -- 2(16) KG.

HIDESCNT        DEC             15300           B-16    # MAX DESCENT LEM MASS -- 2(16) KG.

LODESCNT        DEC             1750            B-16    # MIN DESCENT STAGE (ALONE) -- 2(16) KG.

# PHYSICAL CONSTANTS ( TIME - INVARIANT )


                SETLOC          IMU2
                BANK
                COUNT*          $$/P07

OMEG/MS         2DEC            .24339048
                SETLOC          R30LOC
                BANK
                COUNT*          $$/R30

# *** THE ORDER OF THE FOLLOWING TWO CONSTANTS MUST BE PRESERVED *********

1/RTMUM         2DEC*           .45162595       E-4 B14*
1/RTMUE         2DEC*           .50087529       E-5 B17*
# ************************************************************************

                SETLOC          P40S1
                BANK
                COUNT*          $$/S40.9

EARTHMU         2DEC*           -3.986032       E10 B-36*# M(3)/CS(2)
                SETLOC          F2DPS*31
                BANK
                COUNT*          $$/F2DPS

MOONG           2DEC            -1.6226         E-4 B2
                SETLOC          P12
                BANK
                COUNT*          $$/P12

MUM(-37)        2DEC*           4.9027780       E8 B-37*
MOONRATE        2DEC*           .26616994890062991 E-7 B+19*# RAD/CS.
                SETLOC          SERVICES
                BANK
                COUNT*          $$/SERV

# *** THE ORDER OF THE FOLLOWING TWO CONSTANTS MUST BE PRESERVED *********

-MUDT           2DEC*           -7.9720645      E+12 B-44*
-MUDT1          2DEC*           -9.8055560      E+10 B-44*

# ************************************************************************

-MUDTMUN        2DEC*           -9.8055560      E+10 B-38*
RESQ            2DEC*           40.6809913      E12 B-58*
20J             2DEC            3.24692010      E-2
2J              2DEC            3.24692010      E-3
                SETLOC          P50S1
                BANK
                COUNT*          $$/LOSAM

# ************************************************************************

                SETLOC          TOF-FF1
                BANK
                COUNT*          $$/TFF

1/RTMU          2DEC*           .5005750271     E-5 B17*        # MODIFIED EARTH MU

                SETLOC          SBAND
                BANK
                COUNT*          $$/R05

REMDIST         2DEC            384402000       B-29    # MEAN DISTANCE BETWEEN EARTH AND MOON.

# ************************************************************************


                SETLOC          PLANTIN
                BANK
                COUNT*          $$/LUROT

COSI            2DEC            .99964115       B-1     # COS(1 DEG 32.1 MIN) B-1
SINI            2DEC            .02678760       B-1     # SIN(1 DEG 32.1 MIN) B-1
NODDOT          2DEC            -.457335143     E-2     # REVS/CSEC B+28=-1.07047016 E-8  RAD/SEC
FDOT            2DEC            .570862491              # REVS/CSEC B+27= 2.67240019 E-6  RAD/SEC

BDOT            2DEC            -3.07500412     E-8     # REVS/CSEC B+28=-7.19756666 E-14 RAD/SEC
NODIO           2DEC            -.960101269             # REVS B-O    = -6.03249419  RAD
FSUBO           2DEC            .415998375              # REVS B-O    =  2.61379488  RAD
BSUBO           2DEC            .0651205006             # REVS B-O    =  0.409164173 RAD
WEARTH          2DEC            .973561855              # REVS/CSEC B+23=7.29211515 E-5 RAD/SEC
