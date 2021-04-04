### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CONTROLLED_CONSTANTS.agc
## Purpose:     A section of Luminary revision 173.
##              It is part of the reconstructed source code for the second
##              (unflown) release of the flight software for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 14.
##              The code has been recreated from a reconstructed copy of
##              Luminary 178, as well as Luminary memo 167 (revision 1).
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 173 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 38-54
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-09-18 MAS  Created from Luminary 178. Gave THROTLAG
##                              its original value of 0.2s. Changed K1VAL
##                              back to 124.55 B-23.
##              2019-09-21 MAS  Restored the original landing analog displays
##                              constants from Luminary 131.
##              2021-05-30 ABS  DEC -> DEC* for extended address fields.

## Page 38
# DPS AND APS ENGINE PARAMETERS

                SETLOC          P40S
                BANK
                COUNT*          $$/P40

# *** THE ORDER OF THE FOLLOWING SIX CONSTANTS MUST NOT BE CHANGED ***

FDPS            2DEC            4.3670          B-7     # 9817.5 LBS FORCE IN NEWTONS

MDOTDPS         2DEC            0.1480          B-3     # 32.62 LBS/SEC IN KGS/CS.

DTDECAY         2DEC            -38                     # 40 PERCENT FTP-DPS TAILOFF FOR P40

FAPS            2DEC            1.5569          B-7     # 3500 LBS FORCE IN NEWTONS

MDOTAPS         2DEC            0.05135         B-3     # 11.32 LBS/SEC IN KGS/CS

ATDECAY         2DEC            -18                     # 618 LB-SEC  TAILOFF FOR APS

# ************************************************************************

100PCTTO        2DEC            24              B-17    # 100 PERCENT FTP-DPS TAILOFF FOR P70

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

                SETLOC          ASENT1
## Page 39
                BANK
                COUNT*          $$/P70

(1/DV)A         2DEC            15.20           B-7     # 2 SECONDS WORTH OF INITIAL ASCENT

                                                        # STAGE ACCELERATION -- INVERTED (M/CS)
                                                        # 1) PREDICATED ON A LIFTOFF MASS OF
                                                        #    4869.9 KG (SNA-8-D-027 7/11/68)
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

APSVEX          DEC             -3030           E-2 B-5   # 9942 FT/SEC IN M/CS.
DPSVEX          DEC*            -2.95588868     E+1 B-05* #         VE (DPS) +2.95588868E+ 3
# ************************************************************************

                SETLOC          F2DPS*31
                BANK
                COUNT*          $$/F2DPS

TRIMACCL        2DEC*           +3.50132708     E-5 B+08* #         A (T)    +3.50132708E- 1

## Page 40
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

FMAXODD         DEC             +3841                     # FSAT          +4.81454413 E+ 4

FMAXPOS         DEC             +3467                     # FMAX          +4.34546769 E+ 4

THROTLAG        DEC             +20                       # TAU (TH)      +1.99999999 E-1
SCALEFAC        2DEC*           +7.97959872     E+2 B-16* # BITPERF       +7.97959872E- 2

                SETLOC          F2DPS*32
                BANK
                COUNT*          $$/F2DPS

DPSTHRSH        DEC             36                        # (THRESH1 + THRESH3 FOR P63)

## Page 41
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

                SETLOC          SERVICES
                BANK
                COUNT*          $$/SERV

HBEAMNB         2DEC            -0.7147168647           # POS 1 ALT BEAM IN NAV BASE COORDINATES

                2DEC            -0.0731086602

                2DEC            -0.6955824372


VZBEAMNB        2DEC            -0.4067366430           # POS 1 VZ  BEAM

                2DEC            +0.0954915028

                2DEC            +0.9085409600


VYBEAMNB        2DEC            +0.0                    # POS 1 VY  BEAM

                2DEC            +0.9945218954

                2DEC            -0.1045284632


VXBEAMNB        2DEC            +0.9135454576           # POS 1 VX  BEAM

                2DEC            +0.0425155563

                2DEC            +0.4045084971


## Page 42
                2DEC            -0.9374036070           # POS 2 ALT BEAM

                2DEC            -0.0364014993

                2DEC            -0.3463371311


                2DEC            +0.0                    # POS 2 VZ  BEAM

                2DEC            +0.1045284632

                2DEC            +0.9945218954


                2DEC            +0.0                    # POS 2 VY  BEAM

                2DEC            +0.9945218954

                2DEC            -0.1045284632


                2DEC            +0.9999999999           # POS 2 VX  BEAM

                2DEC            +0.0

                2DEC            +0.0


HSCAL           2DEC            -.3288792               # SCALES 1.079 FT/BIT TO 2(22)M.

# ***** THE SEQUENCE OF THE FOLLOWING CONSTANTS MUST BE PRESERVED ********

VZSCAL          2DEC            +.5410829105            # SCALES .8668 FT/SEC/BIT TO 2(18) M/CS.

VYSCAL          2DEC            +.7565672446            # SCALES 1.212 FT/SEC/BIT TO 2(18) M/CS.

VXSCAL          2DEC            -.4020043770            # SCALES -.644 FT/SEC/BIT TO 2(18) M/CS.


# ************************************************************************

KPIP            DEC             .0512                   # SCALES DELV TO UNITS OF 2(5) M/CS.
KPIP1           2DEC            .0128                   # SCALES DELV TO UNITS OF 2(7) M/CS.

## Page 43
KPIP2           2DEC            .0064                   # SCALES DELV TO UNITS OF 2(8) M/CS.

ALTCONV         2DEC            1.399078846 B-4         # CONVERTS M*2(-24) TO BIT UNITS *2(-28).
ARCONV1         2DEC            656.167979 B-10         # CONV. ALTRATE COMP. TO BIT UNITS<

                SETLOC          R10
                BANK
                COUNT*          $$/R10

ARCONV          OCT             24402                   # 656.1679798B-10 CONV ALTRATE TO BIT UNIT

ARTOA           DEC             .1066098 B-1            # .25/2.345 B-1 4X/SEC CYCLE RATE.

ARTOA2          DEC             .0021322 B8             # (.5)/(2.345)(100)

VELCONV         OCT             22316                   # 588.914 B-10 CONV VEL. TO BIT UNITS.

KPIP1(5)        DEC             .0512                   # SCALES DELV TO M/CS*2(-5).

MAXVBITS        OCT             00547                   # MAX. DISPLAYED VELOCITY 199.9989 FT/SEC.


                SETLOC          DAPS3
                BANK
                COUNT*          $$/DAPAO

TORKJET1        DEC             .03757                  # 550 / .2 SCALED AT (+16) 64 / 180

## Page 44
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

HIDESCNT        DEC             16700           B-16    # MAX DESCENT LEM MASS -- 2(16) KG.
LODESCNT        DEC             1750            B-16    # MIN DESCENT STAGE (ALONE) -- 2(16) KG

## Page 45
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

EARTHMU         2DEC*           -3.986032       E10 B-36*       # M(3)/CS(2)

                SETLOC          ASENT1
                BANK
                COUNT*          $$/P12

MUM(-37)        2DEC*           4.9027780       E8 B-37*

MOONRATE        2DEC*           .26616994890062991 E-7 B+19*    # RAD/CS.

                SETLOC          SERVICES
                BANK
                COUNT*          $$/SERV

# *** THE ORDER OF THE FOLLOWING TWO CONSTANTS MUST BE PRESERVED *********

-MUDT           2DEC*           -7.9720645      E+12 B-44*
-MUDT1          2DEC*           -9.8055560      E+10 B-44*
# ************************************************************************

## Page 46
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

                2DEC*           2.21422176      E4 B-15*        # SQRT(MUM)

                2DEC*           .45162595       E-4 B+14*       # 1/SQRT(MUM)

# ************************************************************************
## Page 47
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

REMDIST         2DEC            384402000       B-29    # MEAN DISTANCE BETWEEN EARTH AND MOON.

## Page 48
# PHYSICAL CONSTANTS (TIME - VARIANT)

                SETLOC          STARTAB
                BANK
                COUNT*          $$/STARS

                2DEC            +.8343989109    B-1     # STAR 37       X

                2DEC            -.2390600205    B-1     # STAR 37       Y

                2DEC            -.4966173214    B-1     # STAR 37       Z

                2DEC            +.8140910890    B-1     # STAR 36       X

                2DEC            -.5555422636    B-1     # STAR 36       Y

                2DEC            +.1691995627    B-1     # STAR 36       Z

                2DEC            +.4541602263    B-1     # STAR 35       X

                2DEC            -.5391353124    B-1     # STAR 35       Y

                2DEC            +.7092754074    B-1     # STAR 35       Z

                2DEC            +.3203620343    B-1     # STAR 34       X

                2DEC            -.4435303001    B-1     # STAR 34       Y

                2DEC            -.8370478121    B-1     # STAR 34       Z

                2DEC            +.5522208574    B-1     # STAR 33       X

                2DEC            -.7931952248    B-1     # STAR 33       Y

                2DEC            -.2566972144    B-1     # STAR 33       Z

                2DEC            +.4539032479    B-1     # STAR 32       X

                2DEC            -.8778479991    B-1     # STAR 32       Y

                2DEC            +.1528225504    B-1     # STAR 32       Z

                2DEC            +.2071906196    B-1     # STAR 31       X

                2DEC            -.8719421540    B-1     # STAR 31       Y

                2DEC            -.4436089799    B-1     # STAR 31       Z

                2DEC            +.1218415406    B-1     # STAR 30       X

                2DEC            -.7702450672    B-1     # STAR 30       Y

## Page 49
                2DEC            +.6260009387    B-1     # STAR 30       Z

                2DEC            -.1122343912    B-1     # STAR 29       X

                2DEC            -.9695188377    B-1     # STAR 29       Y

                2DEC            +.2177995974    B-1     # STAR 29       Z

                2DEC            -.1144569328    B-1     # STAR 28       X

                2DEC            -.3399947346    B-1     # STAR 28       Y

                2DEC            -.9334362275    B-1     # STAR 28       Z

                2DEC            -.3514226152    B-1     # STAR 27       X

                2DEC            -.8241537737    B-1     # STAR 27       Y

                2DEC            -.4441539178    B-1     # STAR 27       Z

                2DEC            -.5325711148    B-1     # STAR 26       X

                2DEC            -.7161840263    B-1     # STAR 26       Y

                2DEC            +.4510526000    B-1     # STAR 26       Z

                2DEC            -.7860975319    B-1     # STAR 25       X

                2DEC            -.5219727016    B-1     # STAR 25       Y

                2DEC            +.3310516106    B-1     # STAR 25       Z

                2DEC            -.6896884364    B-1     # STAR 24       X

                2DEC            -.4183842954    B-1     # STAR 24       Y

                2DEC            -.5910029120    B-1     # STAR 24       Z

                2DEC            -.5812126603    B-1     # STAR 23       X

                2DEC            -.2910465457    B-1     # STAR 23       Y

                2DEC            +.7599235169    B-1     # STAR 23       Z

                2DEC            -.9169129501    B-1     # STAR 22       X

                2DEC            -.3504194263    B-1     # STAR 22       Y

                2DEC            -.1909891817    B-1     # STAR 22       Z

## Page 50
                2DEC            -.4522463508    B-1     # STAR 21       X

                2DEC            -.0494719393    B-1     # STAR 21       Y

                2DEC            -.8905199410    B-1     # STAR 21       Z

                2DEC            -.9524789319    B-1     # STAR 20       X

                2DEC            -.0595555999    B-1     # STAR 20       Y

                2DEC            -.2987256513    B-1     # STAR 20       Z

                2DEC            -.9656970164    B-1     # STAR 19       X

                2DEC            +.0523798707    B-1     # STAR 19       Y

                2DEC            +.2543336816    B-1     # STAR 19       Z

                2DEC            -.8609439465    B-1     # STAR 18       X

                2DEC            +.4634300302    B-1     # STAR 18       Y

                2DEC            +.2097811430    B-1     # STAR 18       Z

                2DEC            -.7743822014    B-1     # STAR 17       X

                2DEC            +.6150774086    B-1     # STAR 17       Y

                2DEC            -.1483643740    B-1     # STAR 17       Z

                2DEC            -.4659729684    B-1     # STAR 16       X

                2DEC            +.4773764969    B-1     # STAR 16       Y

                2DEC            +.7449703838    B-1     # STAR 16       Z

                2DEC            -.3613079259    B-1     # STAR 15       X

                2DEC            +.5746463708    B-1     # STAR 15       Y

                2DEC            -.7343283537    B-1     # STAR 15       Z

                2DEC            -.4120676148    B-1     # STAR 14       X

                2DEC            +.9064582964    B-1     # STAR 14       Y

                2DEC            +.0923776901    B-1     # STAR 14       Z

                2DEC            -.1822546265    B-1     # STAR 13       X

## Page 51
                2DEC            +.9404481198    B-1     # STAR 13       Y

                2DEC            -.2869504922    B-1     # STAR 13       Z

                2DEC            -.0615513667    B-1     # STAR 12       X

                2DEC            +.6031426337    B-1     # STAR 12       Y

                2DEC            -.7952549230    B-1     # STAR 12       Z

                2DEC            +.1369502971    B-1     # STAR 11       X

                2DEC            +.6814042795    B-1     # STAR 11       Y

                2DEC            +.7189804058    B-1     # STAR 11       Z

                2DEC            +.2009372589    B-1     # STAR 10       X

                2DEC            +.9690787331    B-1     # STAR 10       Y

                2DEC            -.1432153163    B-1     # STAR 10       Z

                2DEC            +.3505042402    B-1     # STAR 9        X

                2DEC            +.8927120666    B-1     # STAR 9        Y

                2DEC            +.2832171316    B-1     # STAR 9        Z

                2DEC            +.4103778920    B-1     # STAR 8        X

                2DEC            +.4989028983    B-1     # STAR 8        Y

                2DEC            +.7633386428    B-1     # STAR 8        Z

                2DEC            +.7030586868    B-1     # STAR 7        X

                2DEC            +.7077417542    B-1     # STAR 7        Y

                2DEC            +.0693548283    B-1     # STAR 7        Z

                2DEC            +.5449551668    B-1     # STAR 6        X

                2DEC            +.5316172328    B-1     # STAR 6        Y

                2DEC            -.6483879887    B-1     # STAR 6        Z

                2DEC            +.0129982160    B-1     # STAR 5        X

                2DEC            +.0078080287    B-1     # STAR 5        Y

## Page 52
                2DEC            +.9998850339    B-1     # STAR 5        Z

                2DEC            +.4918000631    B-1     # STAR 4        X

                2DEC            +.2205989850    B-1     # STAR 4        Y

                2DEC            -.8422997006    B-1     # STAR 4        Z

                2DEC            +.4774532337    B-1     # STAR 3        X

                2DEC            +.1167072881    B-1     # STAR 3        Y

                2DEC            +.8708718726    B-1     # STAR 3        Z

                2DEC            +.9342553544    B-1     # STAR 2        X

                2DEC            +.1737172460    B-1     # STAR 2        Y

                2DEC            -.3114309732    B-1     # STAR 2        Z

                2DEC            +.8748133997    B-1     # STAR 1        X

                2DEC            +.0262841262    B-1     # STAR 1        Y

                2DEC            +.4837464836    B-1     # STAR 1        Z

CATLOG          DEC             7071
# ************************************************************************


                SETLOC          EPHEM1
                BANK
                COUNT*          $$/EPHEM

KONMAT          2DEC            1.0             B-1     #        *************

                2DEC            0                       #                    *

                2DEC            0                       #                    *

                2DEC            0                       #                    *

                2DEC*           .91746          B-1*    # K1 COS (OBL)

                2DEC*           -.035711        B-1*    # K2 SIN (OBL) SIN (IM)

                2DEC            0                       #                    *

                2DEC*           .39784          B-1*    # K3 SIN (OBL)

## Page 53
                2DEC*           .082354         B-1*    # K4 COS (OBL) SIN (IM)

CSTODAY         2DEC            8640000         B-33    #                    * NOTE           *

RCB-13          OCT             00002                   #                    * TABLES CONTAIN *
                OCT             00000                   #                    * CONSTANTS FOR  *
RATESP          2DEC*           .03660099       B+4*    # LOMR

                2DEC*           .00273780       B+4*    # LOSR

                2DEC*           -.00014720      B+4*    # LONR

                2DEC            .174685017              # LOMO

                2DEC            .274011893              # LOSO

                2DEC            .932520213              # LONO

VAL67           2DEC*           .017531111      B+1*    # AMOD

                2DEC            -.224249436             # AARG

                2DEC*           .036291713      B+1*    # 1/27

                2DEC*           .003484442      B+1*    # BMOD

                2DEC            .058226609              # BARG

                2DEC            .031250000              # 1/32

                2DEC*           .005329930      B+1*    # CMOD

                2DEC            -.010500980             # CARG

                2DEC*           .002737925      B+1*    # 1/365

# ************************************************************************


                SETLOC          PLANTIN2
                BANK
                COUNT*          $$/LUROT

COSI            2DEC*           9.996417320     E-1 B-1*        # COS (5521.5 SEC.)

SINI            2DEC*           2.676579050     E-2 B-1*        # SIN (5521.5 SEC.)

NODDOT          2DEC*           -1.703706159    E-11 B28*       # REV/CSEC

FDOT            2DEC*           4.253263471     E-9 B27*        # REV/CSEC

## Page 54
BDOT            2DEC*           -1.145530402    E-16 B28*       # REV/CSEC

NODIO           2DEC*           9.325201471     E-1  B 0*       # REV

FSUBO           2DEC*           2.421820916     E-1  B 0*       # REV

BSUBO           2DEC*           6.511977813     E-2  B 0*       # REV

WEARTH          2DEC*           1.160576171     E-7  B23*       # REV/CSEC

AZO             2DEC*           7.739945637     E-1  B 0*       # REVS

