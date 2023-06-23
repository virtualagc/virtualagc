### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INFLIGHT_ALIGNMENT_ROUTINES.agc
## Purpose:     A section of Sundial E.
##              It is part of the reconstructed source code for the final
##              release of the Block II Command Module system test software. No
##              original listings of this program are available; instead, this
##              file was created via disassembly of dumps of Sundial core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-22 MAS  Created from Aurora 12.
##              2023-06-30 MAS  Updated for Sundial E.



                BANK    7
                EBANK=  XSM



# CALCGTA COMPUTES THE GYRO TORQUE ANGLES REQUIRED TO BRING THE STABLE MEMBER INTO THE DESIRED ORIENTATION.

# THE INPUT IS THE DESIRED STABLE MEMBER COORDINATES REFERRED TO PRESENT STABLE MEMBER COORDINATES. THE THREE
# HALF-UNIT VECTORS ARE STORED AT XDC, YDC, AND ZDC.

# THE OUTPUTS ARE THE THREE GYRO TORQUING ANGLES TO BE APPLIED TO THE Y, Z, AND X GYROS AND ARE STORED DP AT IGC,
# MGC, AND OGC RESPECTIVELY. ANGLES ARE SCALED PROPERLY FOR IMUPULSE.



CALCGTA         ITA     DLOAD           # PUSHDOWN 00,02,16D,18D,22D-26D,32D-36D
                        S2              # XDC = (XD1 XD2 XD3)
                        XDC             # YDC = (YD1 YD2 YD3)
                PDDL    PDDL            # ZDC = (ZD1 ZD2 ZD3)
                        ZERODP
                        XDC +4
                DCOMP   VDEF
                UNIT
                STODL   ZPRIME          # ZP = UNIT(-XD3 O XD1) = (ZP1 ZP2 ZP3)
                        ZPRIME

                SR1
                STODL   SINTH           # SIN(IGC) = ZP1
                        ZPRIME +4
                SR1
                STCALL  COSTH           # COS(IGC) = ZP3
                        ARCTRIG

                STODL   IGC             # Y GYRO TORQUING ANGLE  FRACTION OF REV.
                        XDC +2
                SR1
                STODL   SINTH           # SIN(MGC) = XD2
                        ZPRIME

                DMP     PDDL
                        XDC +4          # PD00 = (ZP1)(XD3)
                        ZPRIME +4

                DMP     DSU
                        XDC             # MPAC = (ZP3)(XD1)
                STADR
                STCALL  COSTH           # COS(MGC) = MPAC - PD00
                        ARCTRIG

                STOVL   MGC             # Z GYRO TORQUING ANGLE  FRACTION OF REV.
                        ZPRIME
                DOT
                        ZDC
                STOVL   COSTH           # COS(OGC) = ZP . ZDC
                        ZPRIME
                DOT
                        YDC
                STCALL  SINTH           # SIN(OGC) = ZP . YDC
                        ARCTRIG

                STCALL  OGC             # X GYRO TORQUING ANGLE  FRACTION OF REV.
                        S2

# ARCTRIG COMPUTES AN ANGLE GIVEN THE SINE AND COSINE OF THIS ANGLE.

# THE INPUTS ARE SIN/4 AND COS/4 STORED DP AT SINTH AND COSTH.

# THE OUTPUT IS THE CALCULATED ANGLE BETWEEN +.5 AND -.5 REVOLUTIONS AND STORED AT THETA. THE OUTPUT IS ALSO
# AVAILABLE AT MPAC.



ARCTRIG         DLOAD   ABS             # PUSHDOWN 16D,18D,20D,22D-26D
                        SINTH
                DSU     BMN
                        QTSN45          # ABS(SIN/4) - SIN(45)/4
                        TRIG1           # IF (-45,45) OR (135,-135)



                DLOAD   SL1             # (45,135) OR (-135,-45)
                        COSTH
                ACOS    SIGN
                        SINTH
                STORE   THETA           # X = ARCCOS(COS) WITH SIGN(SIN)
                RVQ



TRIG1           DLOAD   SL1             # (-45,45) OR (135,-135)
                        SINTH
                ASIN
                STODL   THETA           # X = ARCSIN(SIN) WITH SIGN(SIN)
                        COSTH
                BMN
                        TRIG2           # IF (135,-135)

                DLOAD   RVQ
                        THETA           # X = ARCSIN(SIN)   (-45,45)



TRIG2           DLOAD   SIGN            # (135,-135)
                        HALFDP
                        SINTH
                DSU
                        THETA
                STORE   THETA           # X = .5 WITH SIGN(SIN) - ARCSIN(SIN)
                RVQ                     #                  (+) - (+) OR (-) - (-)

# SMNB TRANSFORMS A STAR DIRECTION FROM STABLE MEMBER TO NAVIGATION BASE COORDINATES.

# THE INPUTS ARE 1) THE STAR VECTOR REFERRED TO PRESENT STABLE MEMBER COORDINATES STORED AT LOCATION 32D OF THE
# VAC AREA. 2) THE GIMBAL ANGLES (CDUY,CDUZ,CDUX) STORED AT ALTERNATING LOCATIONS RESPECTIVELY. THE ANGLES ARE
# USUALLY STORED AT LOCATIONS 2,4, AND 6 OF THE MARK VAC AREA. THEY CAN BE STORED AT LOCATIONS 20,22, AND 24 OF
# YOUR JOB VAC AREA. 3) THE BASE ADDRESS OF THE GIMBAL ANGLES STORED SP AT LOCATION S1 OF yOUR JOB VAC AREA.

# THE OUTPUT IS THE STAR VECTOR REFERRED TO NAVIGATION BASE COORDINATES STORED AT 32D OF THE VAC AREA. THE OUTPUT
# IS ALSO AVAILABLE AT MPAC.



SMNB            ITA     CLEAR           # PUSHDOWN 00,02,04-10D,30D,32D-36D
                        S2
                        NBSMBIT         # SET NBSMBIT = 0

SMNB1           AXT,1   AXT,2           # ROTATE X,Z, ABOUT Y
                        4
                        0
                CALL
                        AXISROT

                AXT,1   AXT,2           # ROTATE Y,X ABOUT Z
                        2
                        4
                CALL
                        AXISROT

                AXT,1   AXT,2           # ROTATE Z,Y ABOUT X
                        0
                        2
                CALL
                        AXISROT

                GOTO
                        S2

# NBSM TRANSFORMS A STAR DIRECTION FROM NAVIGATION BASE TO STABLE MEMBER COORDINATES.

# THE INPUTS ARE  1) THE STAR VECTOR REFERRED TO NAVIGATION BASE COORDINATES STORED AT LOCATION 32D OF THE VAC
# AREA.  2) THE GIMBAL ANGLES (CDUY,CDUZ,CDUX) STORED AT ALTERNATING LOCATIONS RESPECTIVELY. THE ANGLES ARE
# USUALLY STORED AT LOCATIONS 2,4, AND 6 OF THE MARK VAC AREA. THEY CAN BE STORED AT LOCATIONS 20,22, AND 24 OF
# YOUR JOB VAC AREA.  3) THE BASE ADDRESS OF THE GIMBAL ANGLES STORED SP AT LOCATION S1 OF YOUR JOB VAC AREA.

# THE OUTPUT IS THE STAR VECTOR REFERRED TO PRESENT STABLE MEMBER COORDINATES STORED AT LOCATION 32D OF THE VAC
# AREA. THE OUTPUT IS ALSO AVAILABLE AT MPAC.



NBSM            ITA     SET             # PUSHDOWN 00,02,04-10D,30D,32D-36D
                        S2
                        NBSMBIT         # SET NBSMBIT = 1

NBSM2           AXT,1   AXT,2           # ROTATE Z,Y ABOUT X
                        0
                        2
                CALL
                        AXISROT

                AXT,1   AXT,2           # ROTATE Y,X ABOUT Z
                        2
                        4
                CALL
                        AXISROT

                AXT,1   AXT,2           # ROTATE X,Z, ABOUT Y
                        4
                        0
                CALL
                        AXISROT

                GOTO
                        S2

# AXISROT IS UTILIZED BY THE SMNB AND NBSM ROUTINES. SEE REMARKS ON THESE ROUTINES FOR INPUTS AND OUTPUTS.



AXISROT         XSU,1   SLOAD*
                        S1              #      SMNB         .       NBSM
                        4,1             # IG    MG    OG    .  OG    MG    IG
                RTB     XAD,1
                        CDULOGIC
                        S1
                STORE   30D

ACCUROT         COS
                STODL   8D,1            #              COS(ANGLE)
                        30D
                SIN
                STORE   10D,1           #              SIN(ANGLE)

                DMP*    SL1
                        32D +4,2
                PDDL*   DMP*            #                  PD0
                        8D,1            # S3SIN S1SIN S2SIN . S2SIN S1SIN S3SIN
                        32D +4,2

                SL1     PDDL*           #                  PD2
                        10D,1           # S3COS S1COS S2COS . S2COS S1COS S3COS

                DMP*    SL1             #                 MPAC
                        32D +4,1        # S1SIN S2SIN S3SIN . S3SIN S2SIN S1SIN

                BOFF
                        NBSMBIT
                        AXISROT1

                BDSU    STADR           #                   .   PD2 - MPAC
                STODL*  32D +4,2        #                   . S2    S1    S3
                        8D,1

                DMP*    SL1             #                   .      MPAC
                        32D +4,1        #                   . S3COS S2COS S1COS

                DAD     STADR           #                   .   PD0 + MPAC
                STOVL   32D +4,1        #                   . S3    S2    S1
                        32D
                RVQ

AXISROT1        DAD     STADR           #   MPAC + PD2      .
                STODL*  32D +4,2        # S3    S1    S2    .
                        8D,1
                DMP*    SL1             #      MPAC         .
                        32D +4,1        # S1COS S2COS S3COS .

                DSU     STADR           #   MPAC - PD0      .
                STOVL   32D +4,1        # S1    S2    S3    .
                        32D
                RVQ

# CALCGA COMPUTES THE CDU DRIVING ANGLES REQUIRED TO BRING THE STABLE MEMBER INTO THE DESIRED ORIENTATION.

# THE INPUTS ARE  1) THE NAVIGATION BASE COORDINATES REFERRED TO ANY COORDINATE SYSTEM.  THE THREE HALF-UNIT
# VECTORS ARE STORED AT XNB, YNB, AND ZNB.  2) THE DESIRED STABLE MEMBER COORDINATES REFERRED TO THE SAME
# COORDINATE SYSTEM ARE STORED AT XSM, YSM, AND ZSM.

# THE OUTPUTS ARE THE THREE CDU DRIVING ANGLES AND ARE STORED SP AT THETAD, THETAD +1, AND THETAD +2.

CALCGA          VLOAD   VXV             # PUSHDOWN 00-04,16D,18D
                        XNB             # XNB = OGA (OUTER GIMBAL AXIS)
                        YSM             # YSM = IGA (INNER GIMBAL AXIS)
                UNIT    PUSH            # PD0 = UNIT(OGA X IGA) = MGA

                DOT     ITA
                        ZNB
                        S2
                STOVL   COSTH           # COS(OG) = MGA . ZNB
                        0
                DOT
                        YNB
                STCALL  SINTH           # SIN(OG) = MGA . YNB
                        ARCTRIG
                STOVL   OGC
                        0

                VXV     DOT             # PROVISION FOR MG ANGLE OF 90 DEGREES
                        XNB
                        YSM
                SL1
                STOVL   COSTH           # COS(MG) = IGA . (MGA X OGA)
                        YSM
                DOT
                        XNB
                STCALL  SINTH           # SIN(MG) = IGA . OGA
                        ARCTRIG
                STORE   MGC

                ABS     DSU
                        .166...
                BPL
                        GIMLOCK1        # IF ANGLE GREATER THAN 60 DEGREES

CALCGA1         VLOAD   DOT
                        ZSM
                        0
                STOVL   COSTH           # COS(IG) = ZSM . MGA
                        XSM
                DOT     STADR
                STCALL  SINTH           # SIN(IG) = XSM . MGA
                        ARCTRIG

                STOVL   IGC
                        OGC
                RTB
                        V1STO2S
                STCALL  THETAD
                        S2

GIMLOCK1        EXIT
                TC      ALARM
                OCT     00401
                TC      INTPRET
                GOTO
                        CALCGA1


# THIS ROUTINE TAKES THE SHAFT AND TRUNNION ANGLES AS READ BY THE CM OPTICAL SYSTEM AND CONVERTS THEM INTO A  UNIT
# VECTOR REFERENCED TO THE NAVIGATION BASE COORDINATE SYSTEM AND COINCIDENT WITH THE SEXTANT LINE OF SIGHT.
#
# THE INPUTS ARE  1) THE SEXTANT SHAFT AND TRUNNION ANGLES ARE STORED SP IN LOCATIONS 3 AND 5 RESPECTIVELY OF THE
# MARK VAC AREA.  2) THE COMPLEMENT OF THE BASE ADDRESS OF THE MARK VAC AREA IS STORED SP AT LOCATION X1 OF YOUR
# JOB VAC AREA.
#
# THE OUTPUT IS A HALF-UNIT VECTOR IN NAVIGATION BASE COORDINATES AND STORED AT LOCATION 32D OF THE VAC AREA. THE
# OUTPUT IS ALSO AVAILABLE AT MPAC.


SXTNB           SLOAD*  RTB             # PUSHDOWN  00,02,04,(17D-19D),32D-36D
                        5,1             # TRUNNION = TA
                        CDULOGIC
                RTB     PUSH
                        SXTLOGIC
                SIN     SL1
                PUSH    SLOAD*          # PD2 = SIN(TA)
                        3,1             # SHAFT = SA
                RTB     PUSH            # PD4 = SA
                        CDULOGIC

                COS     DMP
                        2
                STODL   STARM           # COS(SA)SIN(TA)

                SIN     DMP
                STADR
                STODL   STARM +2        # SIN(SA)SIN(TA)

                COS
                STOVL   STARM +4
                        STARM           # STARM = 32D
                MXV     VSL1
                        NB1NB2
                STORE   32D
                RVQ


SXTLOGIC        CAF     10DEGS-         # CORRECT FOR 19.775 DEGREE OFFSET
                ADS     MPAC
                CAF     QUARTER
                TC      SHORTMP
                TC      DANZIG

# AXISGEN COMPUTES THE COORDINATES OF ONE COORDINATE SYSTEM REFERRED TO ANOTHER COORDINATE SYSTEM.

# THE INPUTS ARE  1) THE STAR1 VECTOR REFERRED TO COORDINATE SYSTEM A STORED AT STARAD.  2) THE STAR2 VECTOR
# REFERRED TO COORDINATE SYSTEM A STORED AT STARAD +6.  3) THE STAR1 VECTOR REFERRED TO COORDINATE SYSTEM B STORED
# AT LOCATION 6 OF THE VAC AREA.  4) THE STAR2 VECTOR REFERRED TO COORDINATE SYSTEM B STORED AT LOCATION 12D OF
# THE VAC AREA.

# THE OUTPUT DEFINES COORDINATE SYSTEM A REFERRED TO COORDINATE SYSTEM B.  THE THREE HALF-UNIT VECTORS ARE STORED
# AT LOCATIONS XDC, XDC +6, XDC +12D, AND STARAD, STARAD +6, STARAD +12D.

AXISGEN         AXT,1   SSP             # PUSHDOWN 00-22D,24D-28D,30D
                        STARAD +6
                        S1
                        STARAD -6

AXISGEN1        VLOAD*  VXV*            # 06D   UA = S1
                        STARAD +12D,1   #       STARAD +00D     UB = S1
                        STARAD +18D,1
                UNIT                    # 12D   VA = UNIT(S1 X S2)
                STOVL*  STARAD +18D,1   #       STARAD +06D     VB = UNIT(S1 X S2)
                        STARAD +12D,1

                VXV*    VSL1
                        STARAD +18D,1   # 18D   WA = UA X VA
                STORE   STARAD +24D,1   #       STARAD +12D     WB = UB X VB

                TIX,1
                        AXISGEN1

                AXC,1   SXA,1
                        6
                        30D

                AXT,1   SSP
                        18D
                        S1
                        6

                AXT,2   SSP
                        6
                        S2
                        2

AXISGEN2        XCHX,1  VLOAD*
                        30D             # X1=-6 X2=+6   X1=-6 X2=+4     X1=-6 X2=+2
                        0,1
                VXSC*   PDVL*           # J=(UA)(UB1)   J=(UA)(UB2)     J=(UA)(UB3)
                        STARAD +6,2
                        6,1
                VXSC*
                        STARAD +12D,2
                STOVL*  24D             # K=(VA)(VB1)   J=(VA)(VB2)     J=(VA)(VB3)
                        12D,1

                VXSC*   VAD
                        STARAD +18D,2   # L=(WA)(WB1)   J=(WA)(WB2)     J=(WA)(WB3)
                VAD     VSL1
                        24D
                XCHX,1
                        30D
                STORE   XDC +18D,1      # XDC = L+J+K   YDC = L+J+K     ZDC = L+J+K

                TIX,1
                        AXISGEN3

AXISGEN3        TIX,2
                        AXISGEN2

                VLOAD
                        XDC
                STOVL   STARAD
                        YDC
                STOVL   STARAD +6
                        ZDC
                STORE   STARAD +12D

                RVQ


# CALCSXA COMPUTES THE SEXTANT SHAFT AND TRUNNION ANGLES REQUIRED TO POSITION THE OPTICS SUCH THAT A STAR LINE-
# OF-SIGHT LIES ALONG THE STAR VECTOR. THE ROUTINE TAKES THE GIVEN STAR VECTOR AND EXPRESSES IT AS A VECTOR REF-
# ERENCED TO THE OPTICS COORDINATE SYSTEM. IN ADDITION IT SETS UP THREE UNIT VECTORS DEFINING THE X, Y, AND Z AXES
# REFERENCED TO THE OPTICS COORDINATE SYSTEM.
#
# THE INPUTS ARE  1) THE STAR VECTOR REFERRED TO PRESENT STABLE MEMBER COORDINATES STORED AT STAR.   2) SAME ANGLE
# INPUT AS *SMNB*, I.E. SINES AND COSINES OF THE CDU ANGLES, IN THE ORDER Y Z X, AT SINCDU AND COSCDU.   A CALL
# TO CDUTRIG WILL PROVIDE THIS INPUT.
#
# THE OUTPUTS ARE THE SEXTANT SHAFT AND TRUNNION ANGLES STORED DP AT SAC AND PAC RESPECTIVELY.  (LOW ORDER PART
# EQUAL TO ZERO).


CALCSXA         ITA     VLOAD           # PUSHDOWN  00-26D,28D,30D,32D-36D
                        28D
                        STAR
                STCALL  32D
                        SMNB
                MXV     VSL1
                        NB2NB1
                STODL   6               # STORE (STARM0,STARM1,STARM2)
                        ZERODP
                STORE   MPAC +5         # SET MPAC TO (STARM0,STARM1,0)
                RTB
                        VECMODE
                UNIT    BOV
                        ZNB=S1
                STODL   0               # STORE  COS/4 =S0/4 , SIN/4 = S1/4 ,0
                        0
                STODL   COSTH
                        2
                STCALL  SINTH
                        ARCTRIG         # USES THE COS/SIN STORED ABOVE
                RTB
                        1STO2S
                STOVL   SAC
                        0
                DOT     SL1
                        6
                ASIN    BMN
                        CALCSXA1        # TRUNNION ANGLE NEGATIVE
                SL2     BOV
                        CALCSXA1        # TRUNNION ANGLE GREATER THAN 90 DEGREES
                DSU     RTB
                        20DEG-
                        1STO2S
                STCALL  PAC
                        28D

CALCSXA1        EXIT                    # PROGRAM ERROR,STAR OUT OF FIELD OF VIEW
                TC      ALARM
                OCT     00402
                TC      ENDOFJOB


# SXTANG COMPUTES THE SEXTANT SHAFT AND TRUNNION ANGLES REQUIRED TO POSITION THE OPTICS SUCH THAT A STAR LINE-OF-
# SIGHT LIES ALONG THE STAR VECTOR.
#
# THE INPUTS ARE  1) THE STAR VECTOR REFERRED TO ANY COORDINATE SYSTEM STORED AT STAR.  2) THE NAVIGATION BASE
# COORDINATES REFERRED TO THE SAME COORDINATE SYSTEM. THESE THREE HALF-UNIT VECTORS ARE STORED AT XNB, YNB, AND
# ZNB.
#
# THE OUTPUTS ARE THE SEXTANT SHAFT AND TRUNNION ANGLES STORED DP AT SAC AND PAC RESPECTIVELY.  (LOW ORDER PART
# EQUAL TO ZERO).


SXTANG          ITA     RTB             # PUSHDOWN 16D,18D,22D-26D,28D
                        28D
                        TRANSP1         # EREF WRT NB2
                VLOAD   MXV
                        XNB
                        NB2NB1
                VSL1
                STOVL   XNB1
                        YNB
                MXV     VSL1
                        NB2NB1
                STOVL   YNB1
                        ZNB
                MXV     VSL1
                        NB2NB1
                STORE   ZNB1

                RTB     RTB
                        TRANSP1
                        TRANSP2

SXTANG1         VLOAD   VXV
                        ZNB1
                        STAR
                UNIT    BOV
                        ZNB=S1
                STORE   PDA             # PDA = UNIT(ZNB X S)

                DOT     DCOMP
                        XNB1
                STOVL   SINTH           # SIN(SA) = PDA . -XNB
                        PDA

                DOT
                        YNB1
                STCALL  COSTH           # COS(SA) = PDA . YNB
                        ARCTRIG
                RTB
                        1STO2S
                STOVL   SAC
                        22D
                VXV     DOT
                        ZNB1
                        STAR
                SL2     ASIN
                BMN     SL2
                        SXTALARM        # TRUNNION ANGLE NEGATIVE
                BOV     DSU
                        SXTALARM        # TRUNNION ANGLE GREATER THAN 90 DEGREES
                        20DEG-
                RTB
                        1STO2S
                STCALL  PAC
                        28D
SXTALARM        EXIT                    # PROGRAM ERROR,STAR OUT OF FIELD OF VIEW
                TC      ALARM
                OCT     00403
                TC      ENDOFJOB
ZNB=S1          DLOAD
                        270DEG
                STODL   SAC
                        20DEGS-
                STCALL  PAC
                        28D



# SMD/EREF TRANSFORMS STABLE MEMBER DESIRED COORDINATES FROM STABLE MEMBER DESIRED (DESIRED = PRESENT HERE) TO
# EARTH REFERENCE COORDINATES TO ALIGN THE STABLE MEMBER TO SPECIFIED GIMBAL ANGLES.

# THE INPUTS ARE 1) THE MATRIX DEFINING THE EARTH REFERENCE COORDINATE FRAME WITH RESPECT TO THE NAVIGATION BASE
# COORDINATE FRAME. 2) SAME AS 2) AND 3) OF SMNB.

# THE OUTPUT IS THE DESIRED STABLE MEMBER COORDINATES WITH RESPECT TO THE EARTH REFERENCE COORDINATE FRAME. THE
# THREE UNIT VECTORS ARE STORED AT XSM, YSM, AND ZSM.

SMD/EREF        ITA     VLOAD           # PUSHDOWN 00,02,04-10D,30D,32D-36D
                        12D
                        XUNIT
                STCALL  32D
                        SMNB            # STABLE MEMBER TO NAVIGATION BASE
                MXV     VSL1
                        STARAD          # THEN TO EARTH REFERENCE
                STOVL   XSM
                        YUNIT

                STCALL  32D
                        SMNB            # STABLE MEMBER TO NAVIGATION BASE
                MXV     VSL1
                        STARAD          # THEN TO EARTH REFERENCE
                STOVL   YSM
                        ZUNIT

                STCALL  32D
                        SMNB            # STABLE MEMBER TO NAVIGATION BASE
                MXV     VSL1
                        STARAD          # THEN TO EARTH REFERENCE
                STCALL  ZSM
                        12D

NB2NB1          2DEC    +.8431750 B-1
                2DEC    0
                2DEC    -.5376396 B-1
ZERINFLT        2DEC    0
HALFNFLT        2DEC    .5
                2DEC    0
                2DEC    +.5376396 B-1
                2DEC    0
                2DEC    +.8431750 B-1


NB1NB2          2DEC    +.8431750 B-1
                2DEC    0
                2DEC    +.5376396 B-1
                2DEC    0
                2DEC    .5
                2DEC    0

                2DEC    -.5376396 B-1
                2DEC    0
                2DEC    +.8431750 B-1

10DEGS-         DEC     3600

270DEG          DEC     -08191
                DEC     00000

20DEGS-         DEC     -07199
                DEC     00000

20DEG-          DEC     03600
                DEC     00000

QTSN45          2DEC    .1768

HALFDP          2DEC    .5

ZUNIT           2DEC    0

YUNIT           2DEC    0

XUNIT           2DEC    0.5

ZERODP          2DEC    0

                2DEC    0

                2DEC    0

.166...         2DEC    .1666666667

ENDINFSS        EQUALS
