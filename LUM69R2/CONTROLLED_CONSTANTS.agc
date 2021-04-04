### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CONTROLLED_CONSTANTS.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 75 and 78. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 53-69
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.
##              2019-07-27 MAS  Updated J4REQ/J3 to match LUM69 rev 2.
##		2020-12-14 RSB	Tweaked the annotation relevant to the
##				change mentioned above to conform to the
##				style and extent of similar justifying
##				annotations previously added to 
##				Comanche 44 and 51.
##              2021-05-30 ABS  2DEC* -> DEC for non extended address fields.

## Page 53
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

## Page 54
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

DPSVEX          DEC             -2952           E-2 B-5 # 9684 FT/SEC IN M/CS.

# ************************************************************************

                SETLOC          F2DPS*31
                BANK
                COUNT*          $$/F2DPS

TRIMACCL        2DEC*           +3.7055         E-5 B+8*# ACCELERATION DURING TRIM PHASE.

## Page 55
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

## Page 56
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

## Page 57
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

## Page 58
# PARAMETERS RELATING TO MASS, INERTIA, AND VEHICLE DIMENSTIONS


                SETLOC          FRANDRES
                BANK
                COUNT*          $$/START

FULLAPS         DEC             5050            B-16    # NOMINAL FULL ASCENT MASS -- 2(16) KG.

                SETLOC          LOADDAP1
                BANK
                COUNT*          $$/R03

MINLMD          DEC             -2850           B-16    # MIN. DESCENT STAGE MASS -- 2(16) KG.

MINMINLM        DEC             -2200           B-16    # MIN ASCENT STAGE MASS -- 2(16) KG.

MINCSM          =               BIT11                   # MIN CSM MASS (OK FOR 1/ACCS) = 9050 LBS

                SETLOC          DAPS3
                BANK
                COUNT*          $$/DAPAO

LOASCENT        DEC             2200            B-16    # MIN ASCENT LEM MASS -- 2(16) KG.

HIDESCNT        DEC             15300           B-16    # MAX DESCENT LEM MASS -- 2(16) KG.

LODESCNT        DEC             1750            B-16    # MIN DESCENT STAGE (ALONE) -- 2(16) KG.

## Page 59
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

## Page 60
# ************************************************************************

-MUDTMUN        2DEC*           -9.8055560      E+10 B-38*
RESQ            2DEC*           40.6809913      E12 B-58*
20J             2DEC            3.24692010      E-2
2J              2DEC            3.24692010      E-3
                SETLOC          P50S1
                BANK
                COUNT*          $$/LOSAM

RSUBEM          2DEC            384402000       B-29
RSUBM           2DEC            1738090         B-29
RSUBE           2DEC            6378166         B-29
ROE             2DEC            .00257125
                SETLOC          CONICS1
                BANK
                COUNT*          $$/LT-LG

ERAD            2DEC            6373338         B-29    # PAD RADIUS
504RM           2DEC            1738090         B-29    # METERS B-29 (EQUATORIAL MOON RADIUS)
                SETLOC          CONICS1
                BANK
                COUNT*          $$/CONIC

# *** THE ORDER OF THE FOLLOWING CONSTANTS MUST BE PRESERVED *************

MUTABLE         2DEC*           3.986032        E10 B-36*       # MUE
                2DEC*           .25087606       E-10 B+34*      # 1/MUE
                2DEC*           1.99650495      E5 B-18*        # SQRT(MUE)
                2DEC*           .50087529       E-5 B+17*       # 1/SQRT(MUE)


                2DEC*           4.902778        E8 B-30*        # MUM
                2DEC*           .203966         E-8 B+28*       # 1/MUM

## Page 61
                2DEC*           2.21422176      E4 B-15*        # SQRT(MUM)
                2DEC*           .45162595       E-4 B+14*       # 1/SQRT(MUM)
# ************************************************************************

                SETLOC          INTINIT
                BANK
                COUNT*          $$/INTIN

OMEGMOON        2DEC*           2.66169947      E-8 B+23*

                SETLOC          ORBITAL2
                BANK
                COUNT*          $$/ORBIT

# *** THE ORDER OF THE FOLLOWING CONSTANTS MUST NOT BE CHANGED ***********

                2DEC*           1.32715445      E16 B-54*       # S
MUM             2DEC*           4.9027780       E8 B-30*        # M
MUEARTH         2DEC*           3.986032        E10 B-36*
                2DEC            0
J4REQ/J3        2DEC*           .4991607391     E7 B-26*
## <b>Reconstruction:</b> In Luminary 69, the following line reads "2DEC 0".
## It has been changed in Luminary 69/2 due to incorporation of the R-2
## Lunar Potential Model &mdash; see
## <a href="http://www.ibiblio.org/apollo/Documents/LUM75_text.pdf">LUMINARY Memo #75</a>.
## The Luminary 69/2 version of the line has been taken from Luminary 99/1, which 
## also incorporates the R-2 model. As for the question of how it was <i>known</i> 
## during the reconstruction process to target this specific value, the bulk of R-2 
## model code changes are confined to the <a href="ORBITAL_INTEGRATION.agc.html">ORBITAL 
## INTEGRATION log section</a>, and indeed J4REQ/J3 is used <i>only</i> there.  Thus,
## after ORBITAL INTEGRATION modifications were made, it would only be natural to check 
## that the constants which the ORBITAL INTEGRATION code referenced had the expected 
## values relative to Luminary 99/1.
                2DEC            -176236.02      B-25
2J3RE/J2        2DEC*           -.1355426363    E5 B-27*
                2DEC*           .3067493316     E18 B-60*
J2REQSQ         2DEC*           1.75501139      E21 B-72*
3J22R2MU        2DEC*           9.20479048      E16 B-58*
# ************************************************************************

                SETLOC          TOF-FF1
                BANK
                COUNT*          $$/TFF

1/RTMU          2DEC*           .5005750271     E-5 B17*        # MODIFIED EARTH MU

                SETLOC          SBAND
                BANK
                COUNT*          $$/R05

## Page 62
REMDIST         2DEC            384402000       B-29    # MEAN DISTANCE BETWEEN EARTH AND MOON.

## Page 63
# PHYSICAL CONSTANTS (TIME - VARIANT)
                SETLOC  STARTAB
                BANK
                COUNT*  $$/STARS

                2DEC            +.8341953207    B-1     # STAR 37       X
                2DEC            -.2394362567    B-1     # STAR 37       Y
                2DEC            -.4967780649    B-1     # STAR 37       Z

                2DEC            +.8138753897    B-1     # STAR 36       X
                2DEC            -.5559063490    B-1     # STAR 36       Y
                2DEC            +.1690413589    B-1     # STAR 36       Z

                2DEC            +.4540570017    B-1     # STAR 35       X
                2DEC            -.5393383149    B-1     # STAR 35       Y
                2DEC            +.7091871552    B-1     # STAR 35       Z

                2DEC            +.3200014224    B-1     # STAR 34       X
                2DEC            -.4436740480    B-1     # STAR 34       Y
                2DEC            -.8371095679    B-1     # STAR 34       Z

                2DEC            +.5518160037    B-1     # STAR 33       X
                2DEC            -.7934422090    B-1     # STAR 33       Y
                2DEC            -.2568045150    B-1     # STAR 33       Z

                2DEC            +.4535361097    B-1     # STAR 32       X
                2DEC            -.8780537171    B-1     # STAR 32       Y
                2DEC            +.1527307006    B-1     # STAR 32       Z

                2DEC            +.2067145272    B-1     # STAR 31       X
                2DEC            -.8720349419    B-1     # STAR 31       Y
                2DEC            -.4436486945    B-1     # STAR 31       Z

                2DEC            +.1216171923    B-1     # STAR 30       X
                2DEC            -.7703014754    B-1     # STAR 30       Y

## Page 64
                2DEC            +.6259751556    B-1     # STAR 30       Z

                2DEC            -.1126265542    B-1     # STAR 29       X
                2DEC            -.9694679589    B-1     # STAR 29       Y
                2DEC            +.2178236347    B-1     # STAR 29       Z

                2DEC            -.1147906312    B-1     # STAR 28       X
                2DEC            -.3399437395    B-1     # STAR 28       Y
                2DEC            -.9334138229    B-1     # STAR 28       Z

                2DEC            -.3518772846    B-1     # STAR 27       X
                2DEC            -.8239967165    B-1     # STAR 27       Y
                2DEC            -.4440853383    B-1     # STAR 27       Z

                2DEC            -.5328042377    B-1     # STAR 26       X
                2DEC            -.7159448596    B-1     # STAR 26       Y
                2DEC            +.4511569595    B-1     # STAR 26       Z

                2DEC            -.7862552143    B-1     # STAR 25       X
                2DEC            -.5216265404    B-1     # STAR 25       Y
                2DEC            +.3312227199    B-1     # STAR 25       Z

                2DEC            -.6899901699    B-1     # STAR 24       X
                2DEC            -.4180817959    B-1     # STAR 24       Y
                2DEC            -.5908647707    B-1     # STAR 24       Z

                2DEC            -.5811943804    B-1     # STAR 23       X
                2DEC            -.2907877154    B-1     # STAR 23       Y
                2DEC            +.7600365758    B-1     # STAR 23       Z

                2DEC            -.9171065276    B-1     # STAR 22       X
                2DEC            -.3500098785    B-1     # STAR 22       Y
                2DEC            -.1908106439    B-1     # STAR 22       Z

## Page 65
                2DEC            -.4524416631    B-1     # STAR 21       X
                2DEC            -.0492700670    B-1     # STAR 21       Y
                2DEC            -.8904319187    B-1     # STAR 21       Z

                2DEC            -.9525633510    B-1     # STAR 20       X
                2DEC            -.0591313500    B-1     # STAR 20       Y
                2DEC            -.2985406935    B-1     # STAR 20       Z

                2DEC            -.9656240240    B-1     # STAR 19       X
                2DEC            +.0528067543    B-1     # STAR 19       Y
                2DEC            +.2545224762    B-1     # STAR 19       Z

                2DEC            -.8606970465    B-1     # STAR 18       X
                2DEC            +.4638127405    B-1     # STAR 18       Y
                2DEC            +.2099484122    B-1     # STAR 18       Z

                2DEC            -.7741360248    B-1     # STAR 17       X
                2DEC            +.6154234025    B-1     # STAR 17       Y
                2DEC            -.1482142053    B-1     # STAR 17       Z

                2DEC            -.4656165921    B-1     # STAR 16       X
                2DEC            +.4775804724    B-1     # STAR 16       Y
                2DEC            +.7450624681    B-1     # STAR 16       Z

                2DEC            -.3611937602    B-1     # STAR 15       X
                2DEC            +.5748077840    B-1     # STAR 15       Y
                2DEC            -.7342581827    B-1     # STAR 15       Z

                2DEC            -.4116502629    B-1     # STAR 14       X
                2DEC            +.9066387314    B-1     # STAR 14       Y
                2DEC            +.0924676785    B-1     # STAR 14       Z

                2DEC            -.1818957154    B-1     # STAR 13       X

## Page 66
                2DEC            +.9405318128    B-1     # STAR 13       Y
                2DEC            -.2869039173    B-1     # STAR 13       Z

                2DEC            -.0614360769    B-1     # STAR 12       X
                2DEC            +.6031700106    B-1     # STAR 12       Y
                2DEC            -.7952430739    B-1     # STAR 12       Z

                2DEC            +.1373948084    B-1     # STAR 11       X
                2DEC            +.6813398852    B-1     # STAR 11       Y
                2DEC            +.7189566241    B-1     # STAR 11       Z

                2DEC            +.2013426456    B-1     # STAR 10       X
                2DEC            +.9689888101    B-1     # STAR 10       Y
                2DEC            -.1432544058    B-1     # STAR 10       Z

                2DEC            +.3509587451    B-1     # STAR 9        X
                2DEC            +.8925545449    B-1     # STAR 9        Y
                2DEC            +.2831507435    B-1     # STAR 9        Z

                2DEC            +.4107492871    B-1     # STAR 8        X
                2DEC            +.4987190610    B-1     # STAR 8        Y
                2DEC            +.7632590132    B-1     # STAR 8        Z

                2DEC            +.7033883645    B-1     # STAR 7        X
                2DEC            +.7074274193    B-1     # STAR 7        Y
                2DEC            +.0692188921    B-1     # STAR 7        Z

                2DEC            +.5450662811    B-1     # STAR 6        X
                2DEC            +.5313738486    B-1     # STAR 6        Y
                2DEC            -.6484940879    B-1     # STAR 6        Z

                2DEC            +.0131955837    B-1     # STAR 5        X
                2DEC            +.0078043793    B-1     # STAR 5        Y

## Page 67
                2DEC            +.9998824772    B-1     # STAR 5        Z

                2DEC            +.4917355618    B-1     # STAR 4        X
                2DEC            +.2203784481    B-1     # STAR 4        Y
                2DEC            -.8423950835    B-1     # STAR 4        Z

                2DEC            +.4776746280    B-1     # STAR 3        X
                2DEC            +.1164935557    B-1     # STAR 3        Y
                2DEC            +.8707790771    B-1     # STAR 3        Z

                2DEC            +.9342726691    B-1     # STAR 2        X
                2DEC            +.1732973829    B-1     # STAR 2        Y
                2DEC            -.3116128956    B-1     # STAR 2        Z

                2DEC            +.8749183324    B-1     # STAR 1        X
                2DEC            +.0258916990    B-1     # STAR 1        Y
                2DEC            +.4835778442    B-1     # STAR 1        Z

CATLOG          DEC             6869

# ************************************************************************


                SETLOC          EPHEM1
                BANK
                COUNT*          $$/EPHEM

KONMAT          2DEC            1.0             B-1     #         *************
                2DEC            0                       #                     *
                2DEC            0                       #                     *
                2DEC            0                       #                     *
                2DEC            .91745          B-1     # K1 COS(OBL)         *
                2DEC            -.03571         B-1     # K2 SIN(OBL)SIN(IM)  *
                2DEC            0                       #                     *
                2DEC            .39784          B-1     # K3 SIN(OBL)         *

## Page 68
                2DEC            .082354         B-1     # K4 COS(OBL)SIN(IM)  *
CSTODAY         2DEC            8640000         B-33    #                     * NOTE           *
RCB-13          OCT             00002                   #                     * TABLES CONTAIN *
                OCT             00000                   #                     * CONSTANTS FOR  *
RATESP          2DEC            .03660098       B+4     #                     * 1968 - 1969    *
                2DEC            .00273779       B+4     # LOSR                *
                2DEC            -.00014719      B+4     # LONR                *
                2DEC            .455880394              # LOMO                *
                2DEC            .275337971              # LOSO                *
                2DEC            .0398987882             # LONO                *
VAL67           2DEC            .017361944      B+1     # AMOD                *
                2DEC            .286523072              # AARG                *
                2DEC            .036291712      B+1     # 1/27                *
                2DEC            .003534722      B+1     # BMOD                *
                2DEC            .113165625              # BARG                *
                2DEC            .03125          B+1     # 1/32                *
                2DEC            .005330555      B+1     # CMOD                *
                2DEC            -.010415660             # CARG       VALUE COMPUTED USING 1/364.24
                2DEC            .002737925      B+1     # 1/365   *************
# ************************************************************************

                SETLOC          PLANTIN
                BANK
                COUNT*          $$/LUROT

COSI            2DEC            .99964115       B-1     # COS(1 DEG 32.1 MIN) B-1
SINI            2DEC            .02678760       B-1     # SIN(1 DEG 32.1 MIN) B-1
NODDOT          2DEC            -.457335143     E-2     # REVS/CSEC B+28=-1.07047016 E-8  RAD/SEC
FDOT            2DEC            .570862491              # REVS/CSEC B+27= 2.67240019 E-6  RAD/SEC

## Page 69
BDOT            2DEC            -3.07500412     E-8     # REVS/CSEC B+28=-7.19756666 E-14 RAD/SEC
NODIO           2DEC            -.960101269             # REVS B-O    = -6.03249419  RAD
FSUBO           2DEC            .415998375              # REVS B-O    =  2.61379488  RAD
BSUBO           2DEC            .0651205006             # REVS B-O    =  0.409164173 RAD
WEARTH          2DEC            .973561855              # REVS/CSEC B+23=7.29211515 E-5 RAD/SEC
