### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    VERB_AND_NOUN_INFORMATION.agc
## Purpose:     Part of the source code for AGC program Retread 50. 
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/Restoration.html
## Mod history: 2019-06-12 MAS  Recreated from Computer History Museum's
##				physical core-rope modules.
##              2019-10-01 MAS  Added Retread 50's new extended verbs.

## Page 1

## Page 2
# VERB DEFINITIONS



#  REGULAR VERBS
# 01  DISPLAY OCTAL COMP 1 (R1)
# 02  DISPLAY OCTAL COMP 2 (R1)
# 03  DISPLAY OCTAL COMP 3 (R1)
# 04  DISPLAY OCTAL COMP 1,2 (R1,R2)
# 05  DISPLAY OCTAL COMP 1,2,3 (R1,R2,R3)
# 06  DECIMAL DISPLAY
# 07  DP DECIMAL DISPLAY (R1,R2)
# 10  SPARE
# 11  MONITOR OCT COMP 1 (R1)
# 12  MONITOR OCT COMP 2 (R1)
# 13  MONITOR OCT COMP 3 (R1)
# 14  MONITOR OCT COMP 1,2 (R1)
# 15  MONITOR OCT COMP 1,2,3 (R1,R2,R3)
# 16  MONITOR DECIMAL
# 17  MONITOR DP DECIMAL (R1,R2)
# 20  SPARE
# 21  LOAD COMP 1 (R1)
# 22  LOAD COMP 2 (R2)
# 23  LOAD COMP 3 (R3)
# 24  LOAD COMP 1,2 (R1,R2)
# 25  LOAD COMP 1,2,3 (R1,R2,R3)
# 26  SPARE
# 27  FIXED MEMORY DISPLAY 
# 30  REQUEST EXECUTIVE
# 31  REQUEST WAITLIST
# 32  C(R2) INTO R3, C(R1) INTO R2
# 33  PROCEED WITHOUT DATA
# 34  TERMINATE CURRENT TEST OR LOAD REQUEST
# 35  TEST LIGHTS
# 36  FRESH START
# 37  CHANGE MAJOR MODE
# END OF REGULAR VERBS

## !! START CHANGE FOR RETREAD 50 !!

# EXTENDED VERBS
# 40  ZERO ISS CDU
# 41  COARSE ALIGN IMU
# 42  FINE ALIGN IMU
# 43  PULSE TORQUE GYROS
# 44  ISS TURN-ON

## !! END CHANGE FOR RETREAD 50 !!

## Page 3
# NORMAL NOUNS                                       SCALE AND DECIMAL POINT
# 00  NOT IN USE
# 01  SPECIFY MACHINE ADDRESS (FRACTIONAL)           (.XXXXX)
# 02  SPECIFY MACHINE ADDRESS (WHOLE)                (XXXXX.)
# 03  SPECIFY MACHINE ADDRESS (DEGREES)              (XXX.XXDEGREES)
# 04  SPECIFY MACHINE ADDRESS (HOURS)                (XXX.XXHOURS)
# 05  SPECIFY MACHINE ADDRESS (SECONDS)              (XXX.XXSECONDS)
# 06  SPECIFY MACHINE ADDRESS (GYRO DEGREES)         (XX.XXXDEGREES)
# 07  SPECIFY MACHINE ADDRESS (Y OPT DEGREES)        (XX.XXXDEGREES)
# 10  CHANNEL TO BE SPECIFIED
# 11  SPARE
# 12  SPARE
# 13  SPARE
# 14  SPARE
# 15  INCREMENT MACHINE ADDRESS                      (OCTAL ONLY)
# 16  TIME SECONDS                                   (XXX.XXSECONDS)
# 17  TIME HOURS                                     (XXX.XXHOURS)
# 20  ICDU                                           (XXX.XXDEGREES)
# 21  PIPAS                                          (XXXXX.PULSES)
# 22  NEW ANGLES I                                   (XXX.XXDEGREES)
# 23  DELTA ANGLES I                                 (XXX.XXDEGREES)
# 24  DELTA TIME (SECONDS)                           (XXX.XXSECONDS)
# 25  CHECKLIST                                      (XXXXX.)
# 26  PRIO/DELAY, ADRES, BBCON                       (OCTAL ONLY)
# 27  SELF TEST ON/OFF SWITCH                        (XXXXX.)
# 30  STAR NUMBERS                                   (XXXXX.)
# 31  FAILREG                                        (OCTAL ONLY)
# 32  DECISION TIME (MIDCOURSE)                      (XXX.XXHOURS (INTERNAL UNITS = WEEKS))
# 33  EPHEMERIS TIME (MIDCOURSE)                     (XXX.XXHOURS (INTERNAL UNITS = WEEKS))
# 34  MEASURED QUANTITY (MIDCOURSE)                  (XXXX.XKILOMETERS)
# 35  ROLL, PITCH, YAW                               (XXX.XXDEGREES)
# 36  LANDMARK DATA 1                                (OCTAL ONLY)
# 37  LANDMARK DATA 2                                (OCTAL ONLY)
# 40  SPARE
# 41  SPARE
# 42  SPARE
# 43  SPARE
# 44  SPARE
# 45  SPARE
# 46  SPARE
# 47  SPARE
# 50  SPARE
# 51  SPARE
# 52  GYRO BIAS DRIFT                                (.BBXXXXXMILLIRAD/SEC)
# 53  GYRO INPUT AXIS ACCELERATION DRIFT             (.BBXXXXX(MILLIRAD/SEC)/(CM/SEC SEC))
# 54  GYRO SPIN AXIS ACCELERATION DRIFT              (.BBXXXXX(MILLIRAD/SEC)/(CM/SEC SEC))
# END OF NORMAL NOUNS

## Page 4
# MIXED NOUNS                                        SCALE AND DECIMAL POINT
# 55  OCDU                                           (XXX.XXDEG, XX.XXXDEG)
# 56  UNCALLED MARK DATA (OCDU & TIME(SECONDS))      (XXX.XXDEG, XX.XXXDEG, XXX.XXSEC)
# 57  NEW ANGLES OCDU                                (XXX.XXDEG, XX.XXXDEG)
# 60  IMU MODE STATUS (IN3, WASKSET, OLDERR)         (OCTAL ONLY)
# 61  TARGET AZIMUTH AND ELEVATION                   (XXX.XXDEG, XX.XXXDEG)
# 62  ICDUZ AND TIME                                 (XXX.XXDEG, XXX.XXSEC)
# 63  OCDUX AND TIME                                 (XXX.XXDEG, XXX.XXSEC)
# 64  OCDUY AND TIME                                 (XX.XXXDEG, XXX.XXSEC)
# 65  SAMPLED TIME (HOURS AND SECONDS)               (XXX.XXHOURS, XXX.XXSEC)
#         (FETCHED IN INTERRUPT)
# 66  SYSTEM TEST RESULTS                            (XXXXX., .XXXXX, XXXXX.)
# 67  DELTA GYRO ANGLES                              (XX.XXXDEG  FOR EACH)
# 70  PIPA BIAS                                      (X.XXXXCM/SEC SEC  FOR EACH)
# 71  PIPA SCALE FACTOR ERROR                        (XXXXX.PARTS/MILLION  FOR EACH)
# 72  DELTA POSITION                                 (XXXX.XKILOMETERS  FOR EACH)
# 73  DELTA VELOCITY                                 (XXXX.XMETERS/SEC  FOR EACH)
# 74  MEASUREMENT DATA (MIDCOURSE)                   (XXX.XXHOURS (INTERNAL UNITS=WEEKS), XXXX.XKILOMETERS, XXXXX.
# 75  MEASUREMENT DEVIATIONS (MIDCOURSE)             (XXXX.XKILOMETERS, XXXX.XMETERS/SEC, XXXX.XKILOMETERS)
# 76  POSITION VECTOR                                (XXXX.XKILOMETERS  FOR EACH)
# 77  VELOCITY VECTOR                                (XXXX.XMETERS/SEC  FOR EACH)
