### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PADLOADS.agc
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
## Reference:   pp. 37-52
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 37
#        ******  FORMAT  ******

# NAMETAG  LENGTH TYPE ?? (GSOP NAME)        PROGRAMS                     SAMPLE VALUE / UNITS
#                                                                         DESCRIPTION
#                                                                         MORE DESCRIPTION
#          INCRE   PRESENT ESTIMATED LGC   SCALING      SOURCE OF VALUE 
#           -MENT   LENGTH AND VALUE


#         ????? POSSIBLE TYPES ?????

#    HOW INITIATED:     P  = PADLOADED
#                       U  = UPLINKED
#                       D  = DSKY (ASTRONAUT)
#    IF MODIFIED, HOW: (I) = INVARIANT
#                     (PGM)= PROGRAM GENERATED
#                      (F) = FRESH  START REINITIALIZED
#                      (U) = UPLINKED
#                      (D) = DSKY (ASTRONAUT)
#


#        ******  EXAMPLE  ******

# FREAKOUT (2D)   P(I)     (F-OMEGA)         P88'S-RENDESVOUS AVOIDANCE    (2 MICROGRAMS)
#                                                                         RESULTANT QUANTITY AFTER LONG EXPOSURE
#                                                                           TO A 'STATUS QUO' PHILOSOPHY
#          +0     1OCT     00534   E3  B-12             (SUN)LITE DAWNS
#          +1     1OCT     07381   E-4 B-12
#

#             *************
#

# FLGWRD10 (1D)   P(PGM)                     MANY PROGRAMS, DAP-R03        (00000 FOR DESCENT, 10000 FOR ASCENT )
#                                                                         MUST BE SET TO ONE VALUE OR OTHER DEPEND
#                                                                          ING ON MISSION PHASE BECAUSE APSFLAG IS
#                                                                          NOT INITIALIZED IN FRESH START AS ARE
#                                                                          OTHER FLAGBITS. MUST USE DSKY OR R03
#                 OCT      00000
#

# FLAGWRD3 (1D)   P(PGM)                       MANY PROGRAMS              (10000 FOR REFSMMAT GOOD; 00000 FOR NO
#                                                                         GOOD) REFSMFLG IS NOT INITIALIZED BY
#                                                                         FRESH START AS OTHER BITS ARE.
#                 OCT      00000
#              OR OCT      10000
#
## Page 38
# FLAGWRD8 (1D)   P(PGM)                       MANY PROGRAMS              (THERE ARE 8 POSSIBLE CONFIGURATIONS)
#                                                                         CMOON, LMOON, & SURFFLAG ARE NOT INITIAL
#                 						          IZED BY FRESH START AS OTHER BITS ARE.
#                 OCT; BITS 8,11,12 NEED TO BE SET AS YOU DESIRE
#

# HIASCENT (1D)   P(F)    (HIASCENT)         DIGITAL AUTOPILOT            (5000 KG.; 11,100 LBS.)
#                                                                         INITIAL STAGED MASS
#                 1DEC     5050  B-16                   SUNLITER # 147
#

# DKTRAP   (1D)   P(F)    (-THETA-MAX-C)     DAP STATE ESTIMATOR PARAM.   (.14 DEG SCALED AT 4.5 DEG OR -510 DEC)
#                                                                         LEM-CSM DOCKED, THRESHOLD FOR MEASURE-
#                                                                         MENT INCORPORATION
#                 1OCT     77001              R557 GSOP SEC 3.3.2.3 JUNE68
#

# DKOMEGAN (1D)   P(F)    (N-OMEGA-C)        DAP STATE ESTIMATOR PARAM.   ( 10 DEC )
#                                                                         LEM-CSM DOCKED, RATE GAIN CONSTANT
#                 1OCT     00012              R557 GSOP SEC 3.3.2.3 JUNE68
#

# DKKAOSNN (1D)   P(F)    (N-ALPHA-C)        DAP STATE ESTIMATOR PARAM.   ( 60 DEC )
#                                                                         LEM-CSM DOCKED, ACCELERATION GAIN
#                                                                                                     CONSTANT
#                 1OCT     00074              R557 GSOP SEC 3.3.2.3 JUNE68
#

# LMTRAP   (1D)   P(F)    (-THETA-MAX-L)     DAP STATE ESTIMATOR PARAM.   (.14 DEG SCALED AT 4.5 DEG )
#                                                                         LEM-ALONE, THRESHOLD FOR MEASUREMENT
#                                                                                                    INCORPORATION
#                 1OCT     77001              R557 GSOP SEC 3.3.2.3 JUNE68
#

# LMOMEGAN (1D)   P(F)    (N-OMEGA-L)        DAP STATE ESTIMATOR PARAM.   ( 0 DEC )
#                                                                         LEM-ALONE, RATE GAIN CONSTANT
#                 1OCT     00000              R557 GSOP SEC 3.3.2.3 JUNE68
#

# LMKAOSN  (1D)   P(F)    (N-ALPHA-L)        DAP STATE ESTIMATOR PARAM.   ( 60 DEC )
#                                                                         LEM-ALONE, ACCELERATION GAIN CONSTANT
#                 1OCT     00074              R557 GSOP SEC 3.3.2.3 JUNE68
#

# DKDB     (1D)   P(F)                       DAP                          ( 1.4 DEGREES EXPRESSED IN RADIANS )
#                                                                         WIDTH OF DEADBAND FOR DOCKED RCS AUTO-
#                                                                           PILOT   (PI/DKDB RADIANS = DEADBAND)
#                 1OCT     00200                        LUMINARY ERASABLES
#
## Page 39
# ROLLTIME (1D)   P(D)    (R-TRIM)           D.A.P. AND R03               ( 3000 CENTISECONDS  OR  30 SECS. )
#                                                                         TIME TO TRIM DESCENT Z GIMBAL (ROLL)
#                 1DEC     3000                      SUNDANCE PADLOAD MEMO
#

# PITTIME  (1D)   P(D)    (P-TRIM)           D.A.P. AND R03               ( 3000 CENTISECONDS  OR  30 SECS. )
#                                                                         TIME TO TRIM DESCENT Z GIMBAL (ROLL)
#                 1DEC     3000                      SUNDANCE PADLOAD MEMO
#

# POSTORKP (1D)   P(PGM)  (POSTORKP)         DAP                          ACCUMULATED JET TORQUE ABOUT +P AXIS
#                                                                         SCALED AT 32 JET-SEC, OR ABOUT 2.0 JET-
#                 1OCT    00000               PCR 616                     MSEC PER BIT.  PERMITTED TO OVERFLOW.
#

# NEGTORKP (1D)   P(PGM)  (NEGTORKP)         DAP                          ACCUMULATED JET TORQUE ABOUT -P AXIS
#                                                                         SCALED AS POSTORKP.
#                 1OCT    00000               PCR 616
#

# POSTORKU (1D)   P(PGM)  (POSTORKU)         DAP                          ACCUMULATED JET TORQUE ABOUT +U AXIS
#                                                                         SCALED AS POSTORKP.
#                 1OCT    00000               PCR 616
#

# NEGTORKU (1D)   P(PGM)  (NEGTORKU)         DAP                          ACCUMULATED JET TORQUE ABOUT -U AXIS
#                                                                         SCALED AS POSTORKP.
#                 1OCT    00000               PCR 616
#

# POSTORKV (1D)   P(PCM)  (POSTORKV)         DAP                          ACCUMULATED JET TORQUE ABOUT +V AXIS
#                                                                         SCALED AS POSTORKP
#                 1OCT    00000               PCR 616
#

# ZOOMTIME (1D)   P(2)    (TAU-T)            P40'S , LUNAR LANDING        ( 26 SEC )
#                                                                         TIME BETWEEN ENGINE ON AND THROTTLE UP
#                                                                          COMMAND IN ANY DPS BURN
#                 1DEC     2600 CSEC.                SUNDANCE PADLOAD MEMO
#

# MASS     (2D)   P(U)    (M)                ALL P40'S, SERVICER          (FULL LOADED VALUE APPROX. 15,043.8 KG.)
#                                                                         VALUE FOR DESCENT STAGE WITH VARYING
#                                                                            FUEL LOADS
#                 2DEC     B-16
#

# PIPASCFX (1D)   P(I)     (SFE1)            IMU COMPENSATION PARAMETERS  (  PARTS PER MILLION)
#                                                                         SCALE FACTOR ERROR CORRECTION FACTOR
#                 1OCT     75155    B-9              SUNDANCE PADLOAD MEMO
## Page 40
#

# PIPASCFY (1D)   P(I)     (SFE2)            IMU COMPENSATION PARAMETERS  (  PARTS PER MILLION)
#                                                                         SCALE FACTOR ERROR CORRECTION FACTOR
#                 1OCT     77403    B-9              SUNDANCE PADLOAD MEMO
#

# PIPASCFZ (1D)   P(I)     (SFE3)            IMU COMPENSATION PARAMETERS  (  PARTS PER MILLION)
#                                                                         SCALE FACTOR ERROR CORRECTION FACTOR
#                 1OCT     65532    B-9              SUNDANCE PADLOAD MEMO
#

# PBIASX   (1D)   P(I)     (BIAS1)           IMU COMPENSATION PARAMETERS  (PIPA PULSES PER CSEC OR CM PER SEC**2 )
#                                                                         PIPA BIASES
#                 1OCT     04554    B-5              SUNDANCE PADLOAD MEMO
#

# PBIASY   (1D)   P(I)     (BIAS2)           IMU COMPENSATION PARAMETERS  (PIPA PULSES PER CSEC OR CM PER SEC**2 )
#                                                                         PIPA BIASES
#                 1OCT     06433    B-5              SUNDANCE PADLOAD MEMO
#

# PBIASZ   (1D)   P(I)     (BIAS3)           IMU COMPENSATION PARAMETERS  (PIPA PULSES PER CSEC OR CM PER SEC**2 )
#                                                                         PIPA BIASES
#                 1OCT     77220    B-5              SUNDANCE PADLOAD MEMO
#

# ADIAX    (1D)   P(I)     (ADIAX)           IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER PIPA PULSE)
#                                                                         (MILLI-EARTH-RATE UNIT (MERU) / GRAVITY)
#                                                                         GYRO DRIFTS DUE TO ACCELERATION ALONG
#                                                                            INPUT AXIS
#                 1OCT     00436    B-6              SUNDANCE PADLOAD MEMO
#

# ADIAY    (1D)   P(I)     (ADIAY)           IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER PIPA PULSE)
#                                                                         (MILLI-EARTH-RATE UNIT (MERU) / GRAVITY)
#                                                                         GYRO DRIFTS DUE TO ACCELERATION ALONG
#                                                                            INPUT AXIS
#                 1OCT     76277    B-6              SUNDANCE PADLOAD MEMO
#

# ADIAZ    (1D)   P(I)     (ADIAZ)           IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER PIPA PULSE)
#                                                                         (MILLI-EARTH-RATE UNIT (MERU) / GRAVITY)
#                                                                         GYRO DRIFTS DUE TO ACCELERATION ALONG
#                                                                            INPUT AXIS
#                 1OCT     00064    B-6              SUNDANCE PADLOAD MEMO
#

# ADSRAX   (1D)   P(I)     (ADSRAX)          IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER PIPA PULSE)
#                                                                         (MILLI-EARTH-RATE UNIT (MERU) / GRAVITY)
## Page 41
#                                                                         GYRO DRIFTS DUE TO ACCELERATION ALONG
#                                                                            SPIN REFERENCE AXIS
#                 1OCT     00064    B-6              SUNDANCE PADLOAD MEMO
#

# ADSRAY   (1D)   P(I)     (ADSRAY)          IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER PIPA PULSE)
#                                                                         (MILLI-EARTH-RATE UNIT (MERU) / GRAVITY)
#                                                                         GYRO DRIFTS DUE TO ACCELERATION ALONG
#                                                                            SPIN REFERENCE AXIS
#                 1OCT     00116    B-6              SUNDANCE PADLOAD MEMO
#

# ADSRAZ   (1D)   P(I)     (ADSRAZ)          IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER PIPA PULSE)
#                                                                         (MILLI-EARTH-RATE UNIT (MERU) / GRAVITY)
#                                                                         GYRO DRIFTS DUE TO ACCELERATION ALONG
#                                                                            SPIN REFERENCE AXIS
#                 1OCT     00064    B-6              SUNDANCE PADLOAD MEMO
#

# NBDX     (1D)   P(I)     (NBDX)            IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER CSEC.)
#                                                                         OR (MILLI-EARTH-RATE UNIT CALLED 'MERU')
#                                                                         GYRO BIAS DRIFTS
#                 1OCT     77332    B-5              SUNDANCE PADLOAD MEMO
#

# NBDY     (1D)   P(I)     (NBDY)            IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER CSEC.)
#                                                                         OR (MILLI-EARTH-RATE UNIT CALLED 'MERU')
#                                                                         GYRO BIAS DRIFTS
#                 1OCT     77415    B-5              SUNDANCE PADLOAD MEMO
#

# NBDZ     (1D)   P(I)     (NBDZ)            IMU COMPENSATION PARAMETERS  (  GYRO PULSES PER CSEC.)
#                                                                         OR (MILLI-EARTH-RATE UNIT CALLED 'MERU')
#                                                                         GYRO BIAS DRIFTS
#                 1OCT     00000    B-5              SUNDANCE PADLOAD MEMO
#

# WRENDPOS (1D)   P(D-V67)   (W-RR)          P20 - RENDEZVOUS NAVIGATION  (2440 METERS)
#                                                                         W-MATRIX INERTIAL DIAGONAL ELEMENT
#                                                                         PRESELECTED ERROR TRANSITION
#                 VALUE UNCERTAIN
#

# WRENDVEL (1D)   P(D-V67)   (W-RV)          P20 - RENDEZVOUS NAVIGATION  ( .0244 METERS PER CSEC.)
#                                                                         W-MATRIX INERTIAL DIAGONAL ELEMENT
#                                                                         PRESELECTED ERROR TRANSITION
#                 VALUE UNCERTAIN
#

# WSHAFT   (1D)   P(I)     (W-THETA)         P20-RENDESVOUS NAVIGATION    ( 10 MILLIRADIANS)
## Page 42
#                                                                         W-MATRIX INERTIAL DIAGONAL ELEMENT
#                                                                         SHAFT PRESELECTED ERROR TRANSITION
#                 VALUE UNCERTAIN
#

# WTRUN    (1D)   P(I)     (W-BETA)          P20-RENDESVOUS NAVIGATION    ( 10 MILLIRADIANS  -MR- )
#                                                                         W-MATRIX INERTIAL DIAGONAL ELEMENT
#                                                                         TRUNNIUN PRESELECTED ERROR TRANSITION
#                 VALUE UNCERTAIN
#

# RMAX     (1D)   P(I)     (DELTA-RMAX)      P20-RENDESVOUS NAVIGATION    ( 9.26 TIMES 10 TO 4TH POWER)
#                                                                         THRESHOLD LIMIT FOR POSITION CORRECTION
#                 VALUE UNCERTAIN
#

# VMAX     (1D)   P(I)     (DELTA-VMAX)      P20-RENDESVOUS NAVIGATION    (9.144 TIMES 10 METERS PER SECOND)
#                                                                         THRESHOLD LIMIT FOR VELOCITY CORRECTION
#                 VALUE UNCERTAIN
#

# SHAFTVAR (1D)   P(U)     (VAR-BETA)        P22-RENDESVOUS RADAR         ( 10 TO 6TH POWER SQUARE RADIANS)
#                                                                         RR SHAFT ANGLE ERROR VARIANCE
#                 VALUE UNCERTAIN
#

# TRUNVAR  (1D)   P(U)     (VAR-THETA)       P22-RENDESVOUS RADAR         ( 10 TO 6TH POWER SQUARE RADIANS)
#                                                                         RR TRUNNION ANGLE ERROR VARIANCE
#                 VALUE UNCERTAIN
#

# WSURFPOS (1D)   P(D-V67)   (W-LR)          P20'S-LUNAR SURFACE NAVIGAT
#
#                                                                         W-MATRIX INERTIAL DIAGONAL ELEMENT
#                                                                         LUNAR ANALOG OF WRENPOS
#

# WSURFVEL (1D)   P(D-V67)   (W-LV)          P20'S-LUNAR SURFACE NAVIGAT
#
#                                                                         W-MATRIX INERTIAL DIAGONAL ELEMENT
#                                                                         LUNAR ANALOG OF WRENVEL
#

# RANGEVAR (2D)   P(I)     (VAR-R))          P20 NAVIGATION'S STATE VECTOR INCORPORATION ROUTINE
#                                                                         (1/3 % QUANTITY SQUARED OR .11111111 E-4
#                                                                         RANGE ERROR VARIANCE CORRESPONDING TO
#                                                                              A PERCENTAGE ERROR
#                 2DEC*    .111111111 E-4 B12*                GSOP
#

## Page 43
# RATEVAR  (2D)   P(I)     (VAR-V))          P20 NAVIGATION'S STATE VECTOR INCORPORATION ROUTINE
#                                                                         (1.3/3 % QUANTITY SQUARED OR  1.8777 E-5
#                                                                         VELOCITY ERROR VARIANCE CORRESPONDING TO
#                                                                              A PERCENTAGE ERROR
#                 2DEC     1.87777 E-5 B12                    GSOP
#

# RVARMIN  (1D)   P(I)     (VAR-RMIN)        P20 NAVIGATION'S STATE VECTOR INCORPORATION ROUTINE
#                                                                         (80/3 FT QUANTITY SQUARED)
#                                                                         MIN. RENDESVOUS RADAR POSITION VARIANCE
#                 1DEC     66.0  B-12   METERS**2             GSOP
#

# VVARMIN  (1D)   P(I)     (VAR-VMIN)        P20 NAVIGATION'S STATE VECTOR INCORPORATION ROUTINE (METERS/CSEC)**2
#                                                                         (1.3 /3  FT PER SEC QUANTITY SQUARED)
#                                                                         MINIMUM VELOCITY VARIANCE
#                 DEC     .17445 E-5 B12                      GSOP
#

# X789     (6D)   P(PGM)   (DELTA-BETA,DELTA-THETA,ZERO)   P20S, MEAS.INCORP2   (MILLIRADIANS)
#                                                                         7,8,9TH COMPONENT NAVIGATION STATEVECTOR
#                                                                         ALSO SHAFT + TRUNNION BIAS ESTIMATES
#          +0     2DEC     0  INITIALLY
#          +2     2DEC     0  INITIALLY                LUMINARY LISTING
#          +4     2DEC     0 ALWAYS
#

# ATIGINC  (2D)   P(I)     (DELTA-TAU-3)     P35                          ( 7 MINUTES )
#                                                                         ACTIVE VEHICLE TIME REQUIRED TO PREPARE
#                                                                          FOR A TPM MANEUVER
#                 2DEC     42000  B-28  (CSEC)       SUNDANCE PADLOAD MEMO
#

# PTIGINC  (2D)   P(I)     (DELTA-TAU-7)     P75                          (12 MINUTES )
#                                                                         PASSIVE VEHICLE TIME REQUIRED TO PREPARE
#                                                                          FOR A TPM MANEUVER
#                 2DEC     72000  B-28  (CSEC)       SUNDANCE PADLOAD MEMO
#

# AOTAZ    (3D)   P(I)     (AZ1,AZ2,AZ3)      AOTMARK (ALIGNMENT OPTICAL  TELESCOPE)    (-60 DEG, 0, +60 DEG)
#                                                                         ANGLES BETWEEN THE LM NAVIGATION BASE Z
#                                                                         AXIS AND AOT LINE OF SIGHT FOR DETENT1,
#                                                                         2,3. (AZIMUTH, 3 FORWARD VIEWING POSIT.)
#          +0     OCT      65252
#          +1     OCT      0                         SUNDANCE PADLOAD MEMO
#          +2     OCT      12525
#

# AOTEL    (3D)   P(I)     (EL1,EL2,EL3)      AOTMARK (ALIGNMENT OPTICAL  TELESCOPE)    (EACH IS 45 DEGREES)
#                                                                         ANGLES BETWEEN THE LM NAVIGATION BASE
## Page 44
#                                                                         Y-Z PLANE & AOT LINE OF SIGHT FOR
#                                                                         DETENT1,2,3. (ELEVATION, 3 FORWARD POS.)
#          +0     OCT      10000
#          +1     OCT      10000                     SUNDANCE PADLOAD MEMO
#          +2     OCT      10000
#

# DUMPCNT  (1D)   P(I)                     DOWNLINK TELEMETRY             HOLDS THE NUMBER 'N' INDICATING THAT A
#                                                                         DOWNLINK ERASABLE DUMP WILL SEND ALL OF
#                                                                         ERASABLE STORAGE N TIMES (N=1 TO 4)
#                 OCT   20000   IF 4 ERASABLE DUMPS DESIRED
#                 OCT   10000   IF 2 COMPLETE DUMPS DESIRED       LUMINARY
#                 OCT   04000   IF 1 COMPLETE ERASABLE DUMP        LISTING
#

# AGSK     (2D)   P(U)                        V47(R47) AGS INITIALIZATION (  MINS ?)
#                                                                         GROUND ELAPSED TIME OF LATEST AGS CLOCK
#                                                                         ZERO
#

# RBRFG    (6D)   P(I)     (R-OFG)         LUNAR LANDING TARGET PARAMETERS (  METERS )
#                                                                         RANGE VECTOR,  BRAKING PHASE, HIGHGATE
#          +0     2DEC*   +2.92362643 E+ 3 B-24 *
#          +2     2DEC*   +0.00000000 E+ 0 B-24 *    23A LUMAR LANDING PGM
#          +4     2DEC*   -1.00839629 E+ 4 B-24 *
#

# VBRFG    (6D)   P(I)     (V-OFG)         LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC )
#                                                                         VELOCITY VECTOR, BRAKING PHASE, HIGHGATE
#          +0     2DEC*   -4.83907728 E- 1 B-10 *
#          +2     2DEC*   +0.00000000 E+ 0 B-10 *    23A LUNAR LANDING PGM
#          +4     2DEC*   +1.71785605 E+ 0 B-10 *
#

# ABRFG    (6D)   P(I)     (A-OFG)         LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC SQUARED )   HIGHGATE
#                                                                         ACCELERATION VECTOR, BRAKING PHASE
#          +0     2DEC*   -5.22722473 E- 5 B+04 *
#          +2     2DEC*   +0.00000000 E+ 0 B+04 *    23A LUNAR LANDING PGM
#          +4     2DEC*   -2.86621213 E- 4 B+04 *
#

# VBRFG*   (2D)   P(I)                     LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC )
#                                                                         VELOCITY SCALAR, BRAKING PHASE, HIGHGATE
#                 2DEC*   +3.86517612 E+ 0 B-10 *    23A LUNAR LANDING PGM
#

# ABRFG*   (2D)   P(I)                     LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC SQUARED )  HIGH GATE
#                                                                         ACCELERATION SCALAR, BRAKING PHASE
#                 2DEC*   -1.71972727 E- 3 B+04 *    23A LUNAR LANDING PGM
#

## Page 45
# JBRFG*   (2D)   P(I)     (J-OFZG)        LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC CUBED )
#                                                                         JERK SCALAR, BRAKING PHASE, HIGHGATE
#                 2DEC*   -2.90216724 E- 8 B+18 *    23A LUNAR LANDING PGM
#

# RAPFG    (6D)   P(I)     (R-1FG)         LUNAR LANDING TARGET PARAMETERS (  METERS )
#                                                                         RANGE VECTOR, APPROACH PHASE, LOWGATE
#          +0     2DEC*   +2.35092239 E+ 1 B-24 *
#          +2     2DEC*   +0.00000000 E+ 0 B-24 *    23A LUNAR LANDING PGM
#          +4     2DEC*   -5.28319999 E- 1 B-24 *
#

# VAPFG    (6D)   P(I)     (V-1FG)         LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC )
#                                                                         VELOCITY VECTOR, APPROACH PHASE, LOWGATE
#          +0     2DEC*   -9.44879999 E- 3 B-10 *
#          +2     2DEC*   +0.00000000 E+ 0 B-10 *    23A LUNAR LANDNNG PGM
#          +4     2DEC*   +3.96239999 E- 3 B-10 *
#

# AAPFG    (6D)   P(I)     (A-1FG)         LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC SQUARED )  LOW GATE
#                                                                         ACCELERATION VECTOR, APPROACH PHASE
#          +0     2DEC*   +1.52399999 E- 6 B+04 *
#          +2     2DEC*   +0.00000000 E+ 0 B+04 *    23A LUNAR LANDING PGM
#          +4     2DEC*   -1.98119999 E- 5 B+04 *
#

# VAPFG*   (2D)   P(I)                     LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC )
#                                                                         VELOCITY SCALAR, APPROACH PHASE, LOWGATE
#                 2DEC*   +8.91539999 E- 3 B-10 *    23A LUNAR LANDING PGM
#

# AAPFG*   (2D)   P(I)                     LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC SQUARED )  LOW GATE
#                                                                         ACCELERATION SCALAR, APPROACH PHASE
#                 2DEC*   -1.18871999 E- 4 B+04 *    23A LUNAR LANDING PGM
#

# JAPFG*   (2D)   P(I)     (J-1FZG)        LUNAR LANDING TARGET PARAMETERS (  METERS PER CSEC CUBED )
#                                                                         JERK SCALAR, APPROACH PHASE, LOWGATE
#                 2DEC*   +8.37249023 E- 8 B+18 *    23A LUNAR LANDING PGM
#

# VIGN     (2D)   P(I)     (V-IGG)         LUNAR LANDING TARGET PARAMETERS (16.99  METERS PER SECOND )
#                                                                         DESIRED SPEED FOR IGNITION
#                 2DEC*   +1.69952182 E+ 1 B-10 *    23A LUNAR LANDING PGM
#

# RIGNX    (2D)   P(I)     (R-IGXG)        LUNAR LANDING TARGET PARAMETERS ( 40127 METERS )
#                                                                         DESIRED X-COMPONENT IN GUIDANCE COORDIN-
#                                                                          ATES FOR IGNITION  ("ALTITUDE")
#                 2DEC*   -4.09432231 E+ 4 B-24 *    23A LUNAR LANDING PGM
## Page 46
#

# RIGNZ    (2D)   P(I)     (R-IGZG)        LUNAR LANDING TARGET PARAMETERS ( 437347 METERS )
#                                                                         DESIRED Z-COMPONENT IN GUIDANCE COORDIN-
#                                                                          ATES FOR IGNITION  ("GROUND RANGE")
#                 2DEC*   -4.40014934 E+ 5 B-24 *    23A LUNAR LANDING PGM
#

# KIGNX/B4 (2D)   P(I)     (K-X)           LUNAR LANDING TARGET PARAMETERS
#                                                                         IGNITION ALGORITHM SENSITIVITY COEF.
#                 2DEC    -.022499999                23A LUNAR LANDING PGM
#

# KIGNY/B8 (2D)   P(I)     (K-Y)           LUNAR LANDING TARGET PARAMETERS
#                                                                         IGNITION ALGORITHM SENSITIVITY COEF.
#                 2DEC    -.174716605                23A LUNAR LANDING PGM
#

# KIGNV/B4 (2D)   P(I)     (K-V)           LUNAR LANDING TARGET PARAMETERS
#                                                                         IGNITION ALGORITHM SENSITIVITY COEF.
#                 2DEC    -.165939331                23A LUNAR LANDING PGM
#

# LOWCRIT  (1D)   P(I)                     LUNAR LANDING TARGET PARAMETERS (2.7 LBS/BIT) (57% NOMINAL MAX THRUST )
#                                                                         LOWER LIMIT BEYOND WHICH THROTTLE SET TO
#                                                                          EITHER MAXIMUM OR TRUE VALUE
#                 1OCT    04251
#

# HIGHCRIT (1D)   P(I)                     LUNAR LANDING TARGET PARAMETERS (  LBS / BIT : 63% NOMINAL MAX THRUST)
#                                                                         UPPER LIMIT BEYOND WHICH THROTTLE SET TO
#                                                                          EITHER MAXIMUM OR TRUE VALUE ?
#                 1OCT    04622
#

# TENDAPPR (1D)   P(I)                     LUNAR LANDING TARGET PARAMETERS ( 10 SECONDS )
#                                                                         TIME CRITERION FOR SWITCHING OUT OF
#                                                                          APPROACH PHASE QUADRATIC GUIDANCE
#                 DEC     +10  E2 B-17   (BOTH ONEAND TWO-PHASE)
#                                                                                                   LUM MEMO # 45

# TENDBRAK (1D)   P(I)                      LUNAR LANDING TARGET PARAMETER  ( 200 SECONDS )
#                                                                         TIME CRITERION FOR SWITCH TO APPROACH
#                                                                         PHASE  (P64 )
#                 DEC     +20  E2 B-17  (TWO-PHASE LANDING MODE)  LUM MEMO
#                 DEC     +200 E2 B-17  (ONE-PHASE LANDING MODE)     #45
#

# RPCRTIME (1D)   P(I)                     LUNAR LANDING TARGET PARAMETERS (300 SECONDS )
#                                                                         TIME CRITERION FOR REPOSITIONING LR
## Page 47
#                                                                          ANTENNA
#                 DEC     +5   E2 B-17  (TWO-PHASE LANDING MODE)  LUM MEMO
#                 DEC     +300 E2 B-17  (ONE-PHASE LANDING MODE)     #45
#

# RPCRTQSW (1D)   P(2)                     LUNAR LANDING TARGET PARAMETERS  ( COS 45 DEGREES SCALED AT B+1 )
#                                                                         X COMPONENT OF X-AXIS OF VEHICLE IN
#                                                                         STABLE MEMBER COORDINATES: CRITERION FOR
#                                                                         REPOSITIONING LR ANTENNA
#                 DEC     00000   (TWO-PHASE LANDING MODE)   SUNLITER
#                 DEC     .35356  (ONE-PHASE LANDING MODE)     # 260
#

# LRALPHA  (1D)   P(I)     (ALPHA-1)         LANDING RADAR  P63-67        ( 6 DEGREES)
#                                                                         POSITION 1, X ROTATION
#                 1OCT     01042                           SUNLITER # 168
#

# LRBETA1  (1D)   P(I)     (BETA-1)          LANDING RADAR  P63-67        ( 24 DEGREES)
#                                                                         POSITION 1, Y ROTATION
#                 1OCT     04210
#

# LRALPHA2 (1D)   P(I)     (ALPHA-2)          LANDING RADAR  P63-67       ( 6 DEGREES)
#                                                                         POSITION 2, X ROTATION
#                 1OCT     01042                           SUNLITER # 168
#

# LRBETA2  (1D)   P(I)     (BETA-2)          LANDING RADAR  P63-67        ( 0 DEGREES)
#                                                                         POSITION 2, Y ROTATION
#                 1OCT     00000                           SUNLITER # 168
#

# LRHMAX   (1D)   P(I)     (H-M)             LANDING RADAR  P63-67        (50,000 FEET)
#                                                                         ALTITUDE WEIGHTING FUNCTION PARAMETER
#                 1DEC     15240                     PCR # 253
#

# LRVMAX   (1D)   P(I)     (V-M)             LANDING RADAR  P63-67        (2000 FT PER SECOND)
#                                                                         VELOCITY WEIGHTING FUNCTION PARAMETER
#                 1DEC     .047625                         SUNLITER # 168
#

# LRWH     (1D)   P(I)     (K-H)             LANDING RADAR  P63-67        (.35  DEC)
#                                                                         ALTITUDE WEIGHTING FUNCTION PARAMETER
#                 1DEC     .35                       PCR # 253
#

# LRWVZ    (1D)   P(I)     (K-VZ)            LANDING RADAR  P63-67         ( .7 DEC )
#                                                                         Z VELOCITY WEIGHTING FUNCTION PARAMETER
## Page 48
#                 1DEC     .7                            SUNLITER # 168
#

# LRWVY    (1D)   P(I)     (K-VY)            LANDING RADAR  P63-67         ( .7 DEC )
#                                                                         Y VELOCITY WEIGHTING FUNCTION PARAMETER
#                 1DEC     .7                            SUNLITER # 168
#

# LRWVX    (1D)   P(I)     (K-VX)            LANDING RADAR  P63-67         ( .4 DEC )
#                                                                         X VELOCITY WEIGHTING FUNCTION PARAMETER
#                 1DEC     .4                            SUNLITER # 168
#

# DELQFIX  (2D)   P(I)            DELQFIX             R12                 50 FEET
#                                                                         LR ALT DATA REASONABLENESS TEST PARM.
#                 2DEC    15.24 B-24                  PCRS 639 &248
#

# TBRKPNT  (1D)   P(I)                               P70-71 ASCENT        (540 SEC OR 54000 CSEC )
#                                                                         TFI BRANCH TIME;  ABORT TARGET
#                 1DEC    54000 B-17                 PCR # 133
#

# ABTVINJ1 (2D)   P(I)                               P70-71 ASCENT        (5551 FEET / SEC)
#                                                                         DESIRED INJECTION VELOCITY FOR TFI
#                                                                         BRANCH TIME LESS THAN TBRKPNT; VELOCITY
#                                                                         REQUIRED TO GAIN 60 NM APOLUNE ORBIT
#                 2DEC    16.91945 B-7               PCR # 133
#

# ABTVINJ2 (2D)   P(I)                               P70-71 ASCENT        (5510 FEET / SEC)
#                                                                         DESIRED INJECTION VELOCITY FOR TFI
#                                                                         BRANCH TIME GREATER THAN TBRKPNT; VEL
#                                                                         REQUIRED TO GAIN 30 NM APOLUNE ORBIT
#                 2DEC    16.79448 B-7               PCR # 133
#

# TLAND    (2D)   P(U)                     LUNAR LANDING TARGET PARAMETERS (  2DEC 34573411  <CSEC>)
#                                                                         BRAKING PHASE TIME OF LANDING ON MOON
#                 LAUNCH DATE DEPENDENT
#

# RLS      (6D)   P(U)     (R-LS)          P20-22 LUNAR SURFACE NAVIGATION  (1.7 TIMES 10**6 METERS; 0 M; 0 METER)
#                                                                         SAMPLE VALUE AT 0DEG LATITUDE & LONGITUD
#                                                                         LANDING SITE VECTOR, MOON REFERENCE
#                 LAUNCH DATE DEPENDENT
#

# 504LM    (6D)   P(I)     (L-M)           PLANETARY INERTIAL ORIENTATION   ( RADIANS) 8.5 X 10**-5
#                                                                                      73.9 X 10**-5
## Page 49
#                                                                                       6.6 X 10**-5
#                                                                         MOON LIBRATION VECTOR EXPRESSED AT MID-
#                                                                          POINT OF MISSION IN MOON FIXED COORDIN.
#                 LAUNCH DATE DEPENDENT
#

# TEPHEM   (3D)   P(U)     (T-0)           LUNAR + SOLAR EPHEMERIDES,P50S  (2.23452 X 10**9 CSEC )
#                                                                         LAUNCH TIME - ELAPSED TIME BETWEEN MID-
#                                                                          NITE JULY 1 UNIVERSAL TIME PRECEEDING
#                                                                          LAUNCH AND THE TIME THAT THE COMPUTER
#                                                                          CLOCK WAS ZEROED AT TIME OF LAUNCH
#          +0     DEC      LAUNCH DATE DEPENDENT
#          +1     2DEC
#

# AXO      (2D)   P(I)     (A-X-TLO)       PLANETARY INERTIAL ORIENTATION ( 4.65 X 10**-5 RADIANS)
#                                                                         EARTH ANALOGS OF 504LM
#                                                                         FUNCTION OF LAUNCH TIME USED BY NAVIGA-
#                                                                          TION PROGRAMS
#                                                                         SMALL ANGLE ABOUT THE X-AXIS OF BASIC
#                                                                          REFERENCE COORDINATE SYSTEM.....
#                 LAUNCH DATE DEPENDENT
#

# -AYO     (2D)   P(I)     (A-Y-TLO)       PLANETARY INERTIAL ORIENTATION ( 2.147 X 10**-5  RADIANS)
#                                                                         SEE AXO COMMENTS
#                                                                         SMALL ANGLE ABOUT THE Y AXIS OF BASIC
#                                                                          REFERENCE COORDINATE SYSTEM THAT DES-
#                                                                          CRIBES THE PRECESSION AND NUTATION OF
#                                                                          THE EARTH'S POLAR AXIS
#                 LAUNCH DATE DEPENDENT
#

# AZO      (2D)   P(I)     (A-Z-O)         PLANETARY INERITAL ORIENTATION ( .7753 REVOLUTIONS)
#                                                                         ANGLE BETWEEN THE X AXIS OF BASIC REF
#                                                                          COORDINATE SYSTEM AND THE X AXIS OF THE
#                                                                          EARTH-FIXED COORDINATE SYSTEM AT
#                                                                          --,196- UNIVERSAL TIME
#                 LAUNCH DATE DEPENDENT
#

# REFSMMAT (18D)  PGM                      P50'S COMPUTE; MOST MAJOR PGMS.   ( ORTHOGONAL UNIT VECTORS ) SEE BELOW
#                                                                         TRANSFORMATION MATRIX BETWEEN
#                                                                           STABLE MEMBER COORDINATE SYSTEM AND
#                                                                           INERTIAL COORDINATE SYSTEM
#    A S V +0     2DEC    +.155540134
#      A A +2     2DEC    -.441118568
#      M L +4     2DEC    -.176696562
#      P U +6     2DEC    -.001190874
#      L E +10    2DEC    -.186282563                23A LUNAR LANDING PGM
## Page 50
#      E . +12    2DEC    +.464001495
#      . . +14    2DEC    -.475190328
#      . . +16    2DEC    -.143920862
#      . . +20    2DEC    -.058999463
#

# RRECTCSM (6D)   U(PGM)   (R-C0)            INTEGRATION INITIALIZATION     (METERS,B-29 OR B-27 IF EARTH OR MOON
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         RECTIFICATION POSITION VECTOR FOR CSM
#

# RRECTLEM (6D)   U(PGM)   (R-L-0)           INTEGRATION INITIALIZATION     (METERS,B-29 OR B-27 IF EARTH OR MOON
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         RECTIFICATION POSITION VECTOR FOR LEM
#

# VRECTCSM (6D)   U(PGM)   (V-C-0)           INTEGRATION INITIALIZATION    (M/CSEC, B-7 OR B-5 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         RECTIFICATION VELOCITY VECTOR FOR CSM
#

# VRECTLEM (6D)   U(PGM)   (V-L-0)           INTEGRATION INITIALIZATION    (M/CSEC, B-7 OR B-5 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         RECTIFICATION VELOCITY VECTOR FOR LEM
#

# RCVCSM   (6D)   U(PGM)   (R-C-CON)         INTEGRATION INITIALIZATION     (METERS,B-29 OR B-27 IF EARTH OR MOON
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         CONIC POSITION VECTOR FOR CSM
#                                                                         EQUALS RRECTCSM IF TCCSM =0
#

# RCVLEM   (6D)   U(PGM)   (R-L-CON)         INTEGRATION INITIALIZATION     (METERS,B-29 OR B-27 IF EARTH OR MOON
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         CONIC POSITION VECTOR FOR LEM
#                                                                         EQUALS RRECTLEM IF TCLEM =0
#

# VCVCSM   (6D)   U(PGM)   (V-C-CON)         INTEGRATION INITIALIZATION    (M/CSEC, B-7 OR B-5 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         CONIC VELOCITY VECTOR FOR CSM
#                                                                         EQUALS VRECTCSM IF TCCSM =0
#

# VCVLEM   (6D)   U(PGM)   (V-L-CON)         INTEGRATION INITIALIZATION    (M/CSEC, B-7 OR B-5 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         CONIC VELOCITY VECTOR FOR LEM
#                                                                         EQUALS VRECTLEM IF TCLEM =0
#

## Page 51
# DELTACSM (6D)   P(U)     (DELTA-C)         INTEGRATION INITIALIZATION    (METERS, B-22 OR B-18 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         POSITION DEVIATION VECTOR FOR CSM
#                                                                         = 0  IF TCCSM =0
#                 6DEC     0                     LUMINARY LIST, INT. INIT.
#

# DELTALEM (6D)   P(U)     (DELTA-L)         INTEGRATION INITIALIZATION    (METERS, B-22 OR B-18 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         POSITION DEVIATION VECTOR FOR LEM
#                                                                         = 0  IF TCLEM =0
#                 6DEC     0                     LUMINARY LIST, INT. INIT.
#

# NUVCSM   (6D)   P(U)     (UPSILON-C)       INTEGRATION INITIALIZATION    (M/CSEC, B-3 OR B-(-1) IF EARTH OR MOON
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         VELOCITY DEVIATION VECTOR FOR CSM
#                                                                         = 0  IF TCCSM =0
#                 6DEC     0                     LUMINARY LIST, INT. INIT.
#

# NUVLEM   (6D)   P(U)     (UPSILON-L)       INTEGRATION INITIALIZATION    (M/CSEC, B-3 OR B-(-1) IF EARTH OR MOON
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         VELOCITY DEVIATION VECTOR FOR LEM
#                                                                         = 0  IF TCLEM =0
#                 6DEC     0                     LUMINARY LIST, INT. INIT.
#

# TCCSM    (2D)   P(U)     (TAU-C)           INTEGRATION INITIALIZATION     ( 0 CSEC, B-28 )
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         TIME SINCE RECTIFICATION FOR CSM
#                                                                         TIME ASSOCIATED WITH CSM CONIC POSITION,
#                                                                          CONIC VELOCITY, POSITION DEVIATION AND
#                                                                           VELOCITY DEVIATION VECTORS
#                 2DEC     0                     LUMINARY LIST, INT. INIT.
#

# TCLEM    (2D)   P(U)     (TAU-L)           INTEGRATION INITIALIZATION     ( 0 CSEC, B-28 )
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         TIME SINCE RECTIFICATION FOR LEM
#                                                                         TIME ASSOCIATED WITH LEM CONICS AS ABOVE
#                 2DEC     0                     LUMINARY LIST, INT. INIT.
#

# TETCSM   (2D)   U(PGM)   (T-C)             INTEGRATION INITIALIZATION     (   CSEC, B-28 )
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         THE TIME THAT STATE VECTOR IS VALID;
#                                                                          LUNAR ORBIT DEPENDENCE ON REAL TIME
#

## Page 52
# TETLEM   (2D)   U(PGM)   (T-L)             INTEGRATION INITIALIZATION     (   CSEC, B-28 )
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         THE TIME THAT STATE VECTOR IS VALID;
#                                                                          LUNAR ORBIT DEPENDENCE ON REAL TIME
#

# XKEPCSM  (2D)   P(U)     (X-C)             INTEGRATION INITIALIZATION    (M**1/2, B-17 OR B-16 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         ROOT OF KEPLER'S EQUATION FOR CSM
#                                                                         = 0  IF TCCSM =0
#                 2DEC     0                     LUMINARY LIST, INT. INIT.
#

# XKEPLEM  (2D)   P(U)     (X-L)             INTEGRATION INITIALIZATION    (M**1/2, B-17 OR B-16 IF EARTH OR MOON)
#                                                                         PERMANENT STATE VECTORS AND TIMES
#                                                                         ROOT OF KEPLER'S EQUATION FOR LEM
#                                                                         = 0  IF TCLEM =0
#                 2DEC     0                     LUMINARY LIST, INT. INIT.
#
