### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CONTROLLED_CONSTANTS.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 39-55
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-17 HG   Transcribed
##              2016-12-08 HG   Fix label  HBEAMANB  -> HBEAMNB
##              2016-12-11 HG   fix value for STAR 22 Z
##                                            BSUBO
##              2016-12-12 HG   fix value for HBEAMNB
##              2016-12-12 MAS  Split up some Exx Bxx scalers.
##		2016-12-15 RSB	Proofed comment text with octopus/ProoferComments,
##				and corrected the errors found.
##		2017-03-15 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.
##              2017-08-12 MAS  Fixed a comment text error found while transcribing
##                              Zerlina 56.

## Page 39
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
ATDECAY         2DEC            -18                     # 618 LB-SEC TAILOFF FOR APS

# ************************************************************************

100PCTTO        2DEC            24              B-17    # 100 PERCENT FTP-DPS TAILOFF FOR P70

# ************************************************************************

FRCS4           2DEC            0.17792         B-7     # 400 LBS FORCE IN NEWTONS
FRCS2           2DEC            0.08896         B-7     # 200 LBS FORCE IN NEWTONS
                SETLOC          P40S1
                BANK
                COUNT*          $$/P40

# *** APS IMPULSE DATA FOR P42 *******************************************

K1VAL           2DEC            140.12          B-23    # 3150 LB.SEC APS IMPULSE (WET)
K2VAL           2DEC            31.138          B-24    # 700  LB-SEC
K3VAL           2DEC            1.5569          B-10    # FAPS ( 3500 LBS THRUST)
# ************************************************************************

S40.136         2DEC            .4671           B-9     # .4671 M NEWTONS (DPS)
S40.136_        2DEC            .4671           B+1     # S40.136 SHIFTED LEFT 10.

                SETLOC          ASENT1
## Page 40
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

## Page 41
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
THROTLAG        DEC             +8                        # TAU (TH)       +0.08 SECONDS
SCALEFAC        2DEC*           +7.97959872     E+2 B-16* # BITPERF       +7.97959872 E- 2

                SETLOC          F2DPS*32
                BANK
                COUNT*          $$/F2DPS

DPSTHRSH        DEC             36                        # (THRESH1 + THRESH3 FOR P63)

## Page 42
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

## Page 43
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
KPIP2           2DEC            .0064                   # SCALES DELV TO UNITS OF 2(8) M/CS.
                SETLOC          R10

## Page 44
                BANK
                COUNT*          $$/R10

LANAKPIP        DEC             .0512                   # SCALES PIPAS TO UNITS OF 2(5) M/CS
MAXVEL          OCT             00466                   # 198.645 F/S IN UNITS OF 2(5) M/CS
MAXDBITS        OCT             01034                   # ABOUT 300 F/S
VELCONV         DEC             .03594                  # SCALES VFL AT ONE M/CS TO .5571 F/S/BIT
ALTRCONV        DEC             .16020                  # SCALES ALTR AT 2(2) M/CS TO .5 F/S/BIT
ALTCONV         DEC             .69954                  # SCALES ALTITUDE AT 2(15) M TO 9.38 F/BIT

                SETLOC          DAPS3
                BANK
                COUNT*          $$/DAPAO

TORKJET1        DEC             .03757                  # 550 / .2 SCALED AT (+16) 64 / 180

## Page 45
# PARAMETERS RELATING TO MASS, INERTIA, AND VEHICLE DIMENSTIONS

                SETLOC          FRANDRES
                BANK
                COUNT*          $$/START

FULLAPS         DEC             5050            B-16    # NOMINAL FULL ASCENT MASS -- 2(16) KG.

                SETLOC          LOADDAP1
                BANK
                COUNT*          $$/R03

MINLMD          DEC             -4360           B-16    # MIN. UNSTAGED MASS (6560 KG) - MINMINLM
							#   2(16) KG.
MINMINLM        DEC             -2200           B-16    # MIN ASCENT STAGE MASS -- 2(16) KG.
MINCSM          =               BIT11                   # MIN CSM MASS (OK FOR 1/ACCS) = 9050 LBS

                SETLOC          DAPS3
                BANK
                COUNT*          $$/DAPAO

LOASCENT        DEC             2200            B-16    # MIN ASCENT LEM MASS -- 2(16) KG.
HIDESCNT        DEC             16700           B-16    # MAX DESCENT LEM MASS -- 2(16) KG.
LODESCNT        DEC             2542            B-16    # MIN DESCENT STAGE (ALONE) -- 2(16) KG

## Page 46
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

-MUDTMUN        2DEC*           -9.8055560      E+10 B-38*
RESQ            2DEC*           40.6809913      E12 B-58*

## Page 47
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
## Page 48
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

## Page 49
# PHYSICAL CONSTANTS (TIME - VARIANT)

                SETLOC          STARTAB
                BANK
                COUNT*          $$/STARS

                2DEC            +.8345006310    B-1     # STAR 37       X
                2DEC            -.2388718657    B-1     # STAR 37       Y
                2DEC            -.4965369357    B-1     # STAR 37       Z

                2DEC            +.8141988673    B-1     # STAR 36       X
                2DEC            -.5553601830    B-1     # STAR 36       Y
                2DEC            +.1692786800    B-1     # STAR 36       Z

                2DEC            +.4542117996    B-1     # STAR 35       X
                2DEC            -.5390337930    B-1     # STAR 35       Y
                2DEC            +.7093195408    B-1     # STAR 35       Z

                2DEC            +.3205423120    B-1     # STAR 34       X
                2DEC            -.4434583652    B-1     # STAR 34       Y
                2DEC            -.8370169081    B-1     # STAR 34       Z

                2DEC            +.5524232365    B-1     # STAR 33       X
                2DEC            -.7930716636    B-1     # STAR 33       Y
                2DEC            -.2566435348    B-1     # STAR 33       Z

                2DEC            +.4540867784    B-1     # STAR 32       X
                2DEC            -.8777450759    B-1     # STAR 32       Y
                2DEC            +.1528685033    B-1     # STAR 32       Z

                2DEC            +.2074286490    B-1     # STAR 31       X
                2DEC            -.8718956797    B-1     # STAR 31       Y
                2DEC            -.4435890882    B-1     # STAR 31       Z

                2DEC            +.1219537054    B-1     # STAR 30       X
                2DEC            -.7702168243    B-1     # STAR 30       Y

## Page 50
                2DEC            +.6260138474    B-1     # STAR 30       Z

                2DEC            -.1120382967    B-1     # STAR 29       X
                2DEC            -.9695442116    B-1     # STAR 29       Y
                2DEC            +.2177876068    B-1     # STAR 29       Z

                2DEC            -.1142900725    B-1     # STAR 28       X
                2DEC            -.3400201762    B-1     # STAR 28       Y
                2DEC            -.9334474056    B-1     # STAR 28       Z

                2DEC            -.3511952476    B-1     # STAR 27       X
                2DEC            -.8242322268    B-1     # STAR 27       Y
                2DEC            -.4441881743    B-1     # STAR 27       Z

                2DEC            -.5324545035    B-1     # STAR 26       X
                2DEC            -.7163035719    B-1     # STAR 26       Y
                2DEC            +.4510004372    B-1     # STAR 26       Z

                2DEC            -.7860186221    B-1     # STAR 25       X
                2DEC            -.5221457573    B-1     # STAR 25       Y
                2DEC            +.3309660611    B-1     # STAR 25       Z

                2DEC            -.6895375091    B-1     # STAR 24       X
                2DEC            -.4185354938    B-1     # STAR 24       Y
                2DEC            -.5910719617    B-1     # STAR 24       Z

                2DEC            -.5812217481    B-1     # STAR 23       X
                2DEC            -.2911759648    B-1     # STAR 23       Y
                2DEC            +.7598669864    B-1     # STAR 23       Z

                2DEC            -.9168160791    B-1     # STAR 22       X
                2DEC            -.3506241694    B-1     # STAR 22       Y
                2DEC            -.1910784362    B-1     # STAR 22       Z

## Page 51
                2DEC            -.4521486548    B-1     # STAR 21       X
                2DEC            -.0495728431    B-1     # STAR 21       Y
                2DEC            -.8905639377    B-1     # STAR 21       Z

                2DEC            -.9524366380    B-1     # STAR 20       X
                2DEC            -.0597677121    B-1     # STAR 20       Y
                2DEC            -.2988181236    B-1     # STAR 20       Z

                2DEC            -.9657334280    B-1     # STAR 19       X
                2DEC            +.0521664164    B-1     # STAR 19       Y
                2DEC            +.2542392790    B-1     # STAR 19       Z

                2DEC            -.8610673209    B-1     # STAR 18       X
                2DEC            +.4632386329    B-1     # STAR 18       Y
                2DEC            +.2096974909    B-1     # STAR 18       Z

                2DEC            -.7745052221    B-1     # STAR 17       X
                2DEC            +.6149043688    B-1     # STAR 17       Y
                2DEC            -.1484394758    B-1     # STAR 17       Z

                2DEC            -.4661511162    B-1     # STAR 16       X
                2DEC            +.4772744503    B-1     # STAR 16       Y
                2DEC            +.7449243154    B-1     # STAR 16       Z

                2DEC            -.3613649782    B-1     # STAR 15       X
                2DEC            +.5745656444    B-1     # STAR 15       Y
                2DEC            -.7343634472    B-1     # STAR 15       Z

                2DEC            -.4122762536    B-1     # STAR 14       X
                2DEC            +.9063680102    B-1     # STAR 14       Y
                2DEC            +.0923326629    B-1     # STAR 14       Z

                2DEC            -.1824340636    B-1     # STAR 13       X

## Page 52
                2DEC            +.9404062129    B-1     # STAR 13       Y
                2DEC            -.2869738089    B-1     # STAR 13       Z

                2DEC            -.0616090080    B-1     # STAR 12       X
                2DEC            +.6031289258    B-1     # STAR 12       Y
                2DEC            -.7952608559    B-1     # STAR 12       Z

                2DEC            +.1367280274    B-1     # STAR 11       X
                2DEC            +.6814364033    B-1     # STAR 11       Y
                2DEC            +.7189922632    B-1     # STAR 11       Z

                2DEC            +.2007345455    B-1     # STAR 10       X
                2DEC            +.9691236271    B-1     # STAR 10       Y
                2DEC            -.1431958012    B-1     # STAR 10       Z

                2DEC            +.3502769546    B-1     # STAR 9        X
                2DEC            +.8927907521    B-1     # STAR 9        Y
                2DEC            +.2832502918    B-1     # STAR 9        Z

                2DEC            +.4101921571    B-1     # STAR 8        X
                2DEC            +.4989947555    B-1     # STAR 8        Y
                2DEC            +.7633784305    B-1     # STAR 8        Z

                2DEC            +.7028937840    B-1     # STAR 7        X
                2DEC            +.7078988678    B-1     # STAR 7        Y
                2DEC            +.0694227718    B-1     # STAR 7        Z

                2DEC            +.5448995598    B-1     # STAR 6        X
                2DEC            +.5317389073    B-1     # STAR 6        Y
                2DEC            -.6483349473    B-1     # STAR 6        Z

                2DEC            +.0128995818    B-1     # STAR 5        X
                2DEC            +.0078096205    B-1     # STAR 5        Y

## Page 53
                2DEC            +.9998862988    B-1     # STAR 5        Z

                2DEC            +.4918322686    B-1     # STAR 4        X
                2DEC            +.2207092653    B-1     # STAR 4        Y
                2DEC            -.8422520048    B-1     # STAR 4        Z

                2DEC            +.4773424940    B-1     # STAR 3        X
                2DEC            +.1168141178    B-1     # STAR 3        Y
                2DEC            +.8709182540    B-1     # STAR 3        Z

                2DEC            +.9342466124    B-1     # STAR 2        X
                2DEC            +.1739271769    B-1     # STAR 2        Y
                2DEC            -.3113400137    B-1     # STAR 2        Z

                2DEC            +.8747608555    B-1     # STAR 1        X
                2DEC            +.0264803244    B-1     # STAR 1        Y
                2DEC            +.4838307948    B-1     # STAR 1        Z

CATLOG          DEC             7172
# ************************************************************************

                SETLOC          EPHEM1
                BANK
                COUNT*          $$/EPHEM

KONMAT          2DEC            1.0             B-1     #       *************
                2DEC            0                       #                   *
                2DEC            0                       #                   *
                2DEC            0                       #                   *
                2DEC            .917456380      B-1*    # K1 = COS(OBL)
                2DEC            -.035679339     B-1*    # K2 = SIN (OBL) SIN (IM) (-1)
                2DEC            0                       #                   *
                2DEC            .397836387      B-1*    # K3 = SIN (OBL)

## Page 54
                2DEC*           .082280652      B-1*    # K4 = COS (OBL) SIN (IM)
                SETLOC          EPHEM
                BANK
CSTODAY         2DEC            8640000         B-32    #               * NOTE           *
RCB-13          OCT             00002                   #               * TABLES CONTAIN *
                OCT             00000                   #               * CONSTANTS FOR  *
                SETLOC          EPHEM2
                BANK
RATESP          2DEC*           .036600997      B+4*    # LOMR
                2DEC*           .002737803      B+4*    # LOSR
                2DEC*           -.00014720      B+4*    # LONR
                2DEC            .534104635              # LOMO
                2DEC            .273331484              # LOSO
                2DEC            .878830860              # LONO
                SETLOC          EPHEM1
                BANK
VAL67           2DEC*           .017519236      B+1*    # AMOD
                2DEC            .024523430              # AARG
                2DEC*           .036291713      B+1*    # 1/27
                2DEC*           .003473642      B+1*    # BMOD
                2DEC            .540564756              # BARG
                2DEC*           .031250000      B+1*    # 1/32
                2DEC*           .005320572      B+1*    # CMOD
                2DEC            -.011706923             # CARG
                2DEC*           .002737925      B+1*    # 1/365
# ************************************************************************


                SETLOC          PLANTIN2
                BANK
                COUNT*          $$/LUROT

COSI            2DEC*           9.996417320     E-1 B-1*        # COS (5521.5 SEC.)

## Page 55
SINI            2DEC*           2.676579050     E-2 B-1*        # SIN (5521.5 SEC.)
NODDOT          2DEC*           -1.703706128    E-11 B28*       # REV/CSEC
FDOT            2DEC*           4.253263471     E-9 B27*        #    REV/CSEC
BDOT            2DEC*           -1.145529390    E-16 B28*       # REV/CSEC
NODIO           2DEC*           8.788308600     E-1  B 0*       #  REV
FSUBO           2DEC*           6.552737750     E-1  B 0*       #  REV
BSUBO           2DEC*           6.511941688     E-2  B 0*       #  REV
WEARTH          2DEC*           1.160576171     E-7  B23*       #    REV/CSEC
AZO             2DEC*           7.733314844     E-1  B 0*       # REVS

