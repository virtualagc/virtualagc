### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    IMU_COMPENSATION_PACKAGE.agc
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
## Reference:   pp. 802-811
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-14 HG   Transcribed
##              2017-06-15 HG   Fix operand CA  -> CS
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 802
                BANK            12
                EBANK=          NBDX

# PROGRAM DESCRIPTION- IMU COMPENSATION (LEM)                             DATE- 30 AUG 66
# MOD NO- 0                                                               LOG SECTION- IMU COMPENSATION PACKAGE
# MOD BY- GILBERT                                                         ASSEMBLY- SUNBURST REVISION 13

# FUNCTIONAL DESCRIPTION
#       THE IMU COMPENSATION PACKAGE IS DESIGNED TO COMPENSATE FOR PIPA BIAS AND SCALE FACTOR ERROR AND AT THE
# SAME TIME ACCUMULATE GYRO TORQUING COMMANDS NECESSARY TO COMPENSATE FOR THE ASSOCIATED BIAS AND ACCELERATION-
# CAUSED GYRO DRIFTS. 1/PIPA MUST BE CALLED AT LEAST EVERY 2.55 SECONDS DUE TO SCALING CONSIDERATIONS.
# SPECIFICALLY, THE CORRECTION IS

#       PIPA  = (1 + SCALE FACTOR ERROR)PIPA  - (BIAS)(DELTAT)

#           C                               I

# WHERE PIPA  IS THE COMPENSATED DATA OBTAINED FROM THE SAMPLED DATA PIPA
#           C                                                            I

# THE COMPENSATED DATA IS THEN USED TO COMPUTE THE IRIG TORQUING NECESSARY TO CANCEL THE NBD, ADIA, AND ADSRA
# GYRO COEFFICIENTS.
# SPECIFICALLY, THE COMPUTATIONS ARE

#       XIRIG     -(ADIAX)(PIPAX ) + (ADSRAX)(PIPAY ) - (NBDX)(DELTAT)

#                               C                  C
#       YIRIG     -(ADIAY)(PIPAY ) + (ADSRAY)(PIPAZ ) - (NBDY)(DELTAT)
#                               C                  C
#       ZIRIG     -(ADIAZ)(PIPAZ ) - (ADSRAZ)(PIPAY ) + (NBDZ)(DELTAT)
#                               C                  C

# THIS COMPENSATION IS SUMMED INTO THE GCOMP REGISTERS AND WHEN THE MAGNITUDE OF ANY IRIG COMMAND EXCEEDS 2
# PULSES, THE COMMANDS ARE SENT TO THE GYROS.

# DURING FREE-FALL PHASES OF A FLIGHT NBDX, NBDY, AND NBDZ ARE THE ONLY RELEVANT COEFFICIENTS. THESE BIAS TERMS
# WILL BE INTEGRATED BY ROUTINE NBDONLY APPROXIMATELY EVERY 81.93 SECONDS FOLLOWING AN EXECUTIVE CALL BY THE DUMMY
# TASK OF THE WAITLIST PROGRAM. NBDONLY IS ENABLED WHEN BIT 15 OF FLAGWRD2 IS SET TO INDICATE FREE-FALL. DURING

# THIS TIME 1/PIPA IS NOT CALLED.

# LASTBIAS IS CALLED VIA EXECUTIVE WHEN MAKING THE TRANSITION FROM FREE-FALL TO A PIPA READING MODE. THE NBD TERMS
# ARE COMPENSATED FOR FROM THE LAST NBDONLY CALL UP TO PIPA ZEROING. PREREAD WILL THEN ENABLE 1/PIPA AT ITS
# REGULAR INTERVAL. THE DRIFT FLAG MUST BE DOWN JUST PRIOR TO LASTBIAS. GYROCOMPASS NEVER CALLS LASTBIAS.

# SCALING CONSIDERATIONS
#                            UNITS              MAX. VALUE     INTERNAL UNITS AND SCALING

#        PIPA BIAS           (CM)/(SEC)(SEC)    3.125          (PIPA PULSES)/(CS) X 2(-5)

#        PIPA SCALE FACTOR   P.P.M.             1953.125       (PPM) X 2(-9)
#        NBD                 MERU               128.74604      (GYRO PULSES)/(CS) X 2(-5)
#        ADIA                (MERU)/(G)         630.36633      (GYRO PULSES)/(PIPA PULSE) X 2(-6)
#        ADSRA               (MERU)/(G)         630.36633      (GYRO PULSES)/(PIPA PULSE) X 2(-6)

## Page 803
# CONVERSION TABLE
#       1 PIPA PULSE = 1.00 (CM)/(SEC)               1 ERU = 7.29209817 X 10(-5) (RAD)/(SEC)
#       1 ERU = 15.04104488 (ARCSEC)/(SEC)           1 (CM)/(SEC)(SEC) = .01 (PIPA PULSES)/(CS)
#       1 GYRO PULSE = .61798096 ARCSEC              1 MERU = .00024272592 (GYRO PULSES)/(CS)
#       1 G = 979.24 (CM)/(SEC)(SEC)  (AMR)          1 (MERU)/(G) = .000024787174 (GYRO PULSES)/(PIPA PULSE)

# REFERENCES
#       AGC PROGRAMMING MEMO NO. 12, I.S.S. MEMO NO. 247, I.S.S. MEMO NO. 328, I.S.S. MEMO NO. 339

# CALLING SEQUENCE
#       L      TC     BANKCALL
#       L+1    CADR   1/PIPA
#       L+2                       RETURNS HERE

# NORMAL EXIT MODES
#       AT L+2 OF CALLING SEQUENCE

# ALARM OR ABORT MODES
#       ENDOFJOB


# ERASABLE INITIALIZATION REQUIRED (CONSECUTIVE LOCATIONS)
#       PBIASX    PIPAX BIAS
#       PIPASCFX  PIPAX SCALE FACTOR ERROR
#       PBIASY    PIPAY BIAS
#       PIPASCFY  PIPAY SCALE FACTOR ERROR
#       PBIASZ    PIPAZ BIAS
#       PIPASCFZ  PIPAZ SCALE FACTOR ERROR
#       NBDX      X IRIG BIAS DRIFT
#       NBDY      Y IRIG BIAS DRIFT

#       NBDZ      Z IRIG BIAS DRIFT
#       ADIAX     IRIG ACCELERATION SENSITIVE DRIFT ALONG THE X INPUT AXIS
#       ADIAY     IRIG ACCELERATION SENSITIVE DRIFT ALONG THE Y INPUT AXIS
#       ADIAZ     IRIG ACCELERATION SENSITIVE DRIFT ALONG THE Z INPUT AXIS
#       ADSRAX    IRIG ACCELERATION SENSITIVE DRIFT ALONG THE X SPIN REFERENCE AXIS
#       ADSRAY    IRIG ACCELERATION SENSITIVE DRIFT ALONG THE Y SPIN REFERENCE AXIS
#       ADSRAZ    IRIG ACCELERATION SENSITIVE DRIFT ALONG THE Z SPIN REFERENCE AXIS
#       GCOMP     GYRO COMPENSATION PULSES (SET = ZERO FOR 1ST PASS)

# INPUT
#       1/PIPADT - DELTA TIME SCALED AT (CS) X 2(+8)
#       DELVX, DELVY, DELVZ - PIPA READINGS IN THE MAJOR PARTS - MINOR PARTS IRRELEVANT


# OUTPUT
#       DELVX, DELVY, DELVZ - PIPA COUNTS SCALED 2(+14) COMPENSATED FOR PIPA BIAS AND SCALE FACTOR ERROR
#       GCOMP - 3 DP LOCATIONS CONTAINING GYRO PULSES TO COMPENSATE FOR NBD, ADIA, AND ADSRA COEFFICIENTS

# DEBRIS
#       CENTRALS - A,L,Q
#       OTHER - BUF - BUF +2, VBUF - VBUF +2, GCOMPSW

## Page 804
1/PIPA          CAF             LGCOMP                  # SAVE EBANK OF CALLING PROGRAM
                XCH             EBANK

                TS              MODE

                CCS             GCOMPSW                 # BYPASS IF GCOMPSW NEGATIVE
                TCF             +3
                TCF             +2
                TCF             IRIG1                   # RETURN

1/PIPA1         CAF             FOUR                    # PIPAZ, PIPAY, PIPAX
                TS              BUF             +2

                INDEX           A
                CA              DELVX                   # CONTAINS PREVIOUS PIPA READING
                TS              VBUF                    # TEMPORARY - MINOR PARTS IRRELEVANT

                INDEX           BUF             +2
                CS              PIPABIAS                # (PIPA PULSES)/(CS) X 2(-5)             *
                EXTEND
                MP              1/PIPADT                # (CS) X 2(+8)  NOW (PIPA PULSES) X 2(+3)*
                EXTEND                                  #                                        *
                MP              BIT4                    # SCALE 2(-3)      SHIFT LEFT 3          *
                LXCH            VBUF            +1      #(PIPA PULSES) X 2(0)    FRACTIONAL PULSE*

                INDEX           BUF +2

                CA              PIPASCF                 # (P.P.M.) X 2(-9)
                EXTEND
                MP              VBUF                    # (PIPA PULSES) X 2(+14)
                LXCH            VBUF            +2      # SAVE FOR FRACTIONAL COMPUTATION
                EXTEND
                MP              BIT6                    # SCALE 2(+9)    NOW PIPA PULSES X 2(+14)
                DAS             VBUF                    # (PIPAI) - (NBD)(DELTAT) + HI(PIPAI)(SFE)

                CA              VBUF            +2      # NOW MINOR PART
                EXTEND

                MP              BIT6                    # SCALE 2(+9)    SHIFT RIGHT 9
                TS              L
                CAF             ZERO
                DAS             VBUF                    # (PIPAI) - (NBD)(DELTAT) + (PIPAI)(SFE)

                EXTEND
                DCA             VBUF                    # RESTORE COMPENSATED PIPA READING
                INDEX           BUF             +2
                DXCH            DELVX

                CCS             BUF             +2      # PIPAZ, PIPAY, PIPAX
                AD              NEG1

                TCF             1/PIPA1 +1
                NOOP                                    # LESS THAN ZERO IMPOSSIBLE

## Page 805
IRIGCOMP        TS              GCOMPSW                 # INDICATE COMMANDS 2 PULSES OR LESS
                TS              BUF                     # INDEX COUNTER - IRIGX, IRIGY, IRIGZ

IRIGX           EXTEND
                DCS             DELVX                   # (PIPA PULSES) X 2(+14)
                DXCH            MPAC
                CA              ADIAX                   # (GYRO PULSES)/(PIPA PULSE) X 2(-6)     *
                TC              GCOMPSUB                # -(ADIAX)(PIPAX)   (GYRO PULSES) X 2(+14)


                EXTEND
                DCS             DELVY                   # (PIPA PULSES) X 2(+14)
                DXCH            MPAC
                CS              ADSRAX                  # (GYRO PULSES)/(PIPA PULSE) X 2(-6)     *
                TC              GCOMPSUB                # +(ADSRAX)(PIPAY)  (GYRO PULSES) X 2(+14)

                CS              NBDX                    # (GYRO PULSES)/(CS) X 2(-5)
                TC              DRIFSTUB                # -(NBDX)(DELTAT)   (GYRO PULSES) X 2(+14)

IRIGY           EXTEND
                DCS             DELVY                   # (PIPA PULSES) X 2(+14)
                DXCH            MPAC
                CA              ADIAY                   # (GYRO PULSES)/(PIPA PULSE) X 2(-6)     *
                TC              GCOMPSUB                # -(ADIAY)(PIPAY)   (GYRO PULSES) X 2(+14)

                EXTEND
                DCS             DELVZ                   # (PIPA PULSES) X 2(+14)
                DXCH            MPAC
                CS              ADSRAY                  # (GYRO PULSES)/(PIPA PULSE) X 2(-6)     *
                TC              GCOMPSUB                # +(ADSRAY)(PIPAZ)  (GYRO PULSES) X 2(+14)

                CS              NBDY                    # (GYRO PULSES)/(CS) X 2(-5)

                TC              DRIFSTUB                # -(NBDY)(DELTAT)   (GYRO PULSES) X 2(+14)

IRIGZ           EXTEND
                DCS             DELVY                   # (PIPA PULSES) X 2(+14)
                DXCH            MPAC
                CA              ADSRAZ                  # (GYRO PULSES)/(PIPA PULSE) X 2(-6)     *
                TC              GCOMPSUB                # -(ADSRAZ)(PIPAY)  (GYRO PULSES) X 2(+14)

                EXTEND
                DCS             DELVZ                   # (PIPA PULSES) X 2(+14)

                DXCH            MPAC
                CA              ADIAZ                   # (GYRO PULSES)/(PIPA PULSE) X 2(-6)     *
                TC              GCOMPSUB                # -(ADIAZ)(PIPAZ)   (GYRO PULSES) X 2(+14)

                CA              NBDZ                    # (GYRO PULSES)/(CS) X 2(-5)
                TC              DRIFSTUB                # +(NBDZ)(DELTAT)   (GYRO PULSES) X 2(+14)

## Page 806
                CCS             GCOMPSW                 # ARE GYRO COMMANDS GREATER THAN 2 PULSES

                TCF             +2                      # YES
                TCF             IRIG1                   # NO

                INHINT
                CAF             PRIO35                  # SEND OUT GYRO TORQUING COMMANDS
                TC              NOVAC
                EBANK=          NBDX
                2CADR           1/GYRO

                RELINT
IRIG1           CA              MODE                    # SET EBANK FOR RETURN
                TS              EBANK

                TCF             SWRETURN





GCOMPSUB        XCH             MPAC                    # ADIA OR ADSRA COEFFICIENT ARRIVES IN A
                EXTEND                                  # C(MPAC) = (PIPA PULSES) X 2(+14)
                MP              MPAC                    # (GYRO PULSES)/(PIPA PULSE) X 2(-6)     *

                DXCH            VBUF                    # NOW = (GYRO PULSES) X 2(+8)            *

                CA              MPAC            +1      # MINOR PART PIPA PULSES
                EXTEND
                MP              MPAC                    # ADIA OR ADSRA
                TS              L
                CAF             ZERO
                DAS             VBUF                    # NOW = (GYRO PULSES) X 2(+8)            *

                CA              VBUF                    # PARTIAL RESULT - MAJOR
                EXTEND
                MP              BIT9                    # SCALE 2(+6)      SHIFT RIGHT 6         *

                INDEX           BUF                     # RESULT = (GYRO PULSES) X 2(+14)
                DAS             GCOMP                   # HI(ADIA)(PIPAI)  OR  HI(ADSRA)(PIPAI)

                CA              VBUF            +1      # PARTIAL RESULT - MINOR
                EXTEND
                MP              BIT9                    # SCALE 2(+6)      SHIFT RIGHT 6         *
                TS              L
                CAF             ZERO
                INDEX           BUF                     # RESULT = (GYRO PULSES) X 2(+14)
                DAS             GCOMP                   # (ADIA)(PIPAI)  OR  (ADSRA)(PIPAI)

                TC              Q

## Page 807
DRIFSTUB        EXTEND
                QXCH            BUF             +1

                EXTEND                                  # C(A) = NBD    (GYRO PULSES)/(CS) X 2(-5)
                MP              1/PIPADT                # (CS) X 2(+8)   NOW (GYRO PULSES) X 2(+3)
                LXCH            MPAC            +1      # SAVE FOR FRACTIONAL COMPENSATION

                EXTEND
                MP              BIT4                    # SCALE 2(+11)     SHIFT RIGHT 11
                INDEX           BUF
                DAS             GCOMP                   # HI(NBD)(DELTAT)   (GYRO PULSES) X 2(+14)

                CA              MPAC            +1      # NOW MINOR PART
                EXTEND
                MP              BIT4                    # SCALE 2(+11)     SHIFT RIGHT 11
                TS              L
                CAF             ZERO
                INDEX           BUF                     # ADD IN FRACTIONAL COMPENSATION
                DAS             GCOMP                   # (NBD)(DELTAT)     (GYRO PULSES) X 2(+14)


DRFTSUB2        CAF             TWO                     # PIPAX, PIPAY, PIPAZ
                AD              BUF
                XCH             BUF
                INDEX           A
                CCS             GCOMP                   # ARE GYRO COMMANDS 1 PULSE OR GREATER
                TCF             +2                      # YES
                TC              BUF             +1      # NO

                MASK            COMPCHK                 # DEC -1

                CCS             A                       # ARE GYRO COMMANDS GREATER THAN 2 PULSES
                TS              GCOMPSW                 # YES - SET GCOMPSW POSITIVE
                TC              BUF             +1      # NO

## Page 808
1/GYRO          CAF             FOUR                    # PIPAZ, PIPAY, PIPAX
                TS              BUF

                INDEX           BUF                     # SCALE GYRO COMMANDS FOR IMUPULSE
                CA              GCOMP           +1      # FRACTIONAL PULSES
                EXTEND
                MP              BIT8                    # SHIFT RIGHT 7
                INDEX           BUF
                TS              GCOMP           +1      # FRACTIONAL PULSES SCALED

                CAF             ZERO                    # SET GCOMP = 0 FOR DAS INSTRUCTION
                INDEX           BUF

                XCH             GCOMP                   # GYRO PULSES
                EXTEND
                MP              BIT8                    # SHIFT RIGHT 7
                INDEX           BUF
                DAS             GCOMP                   # ADD THESE TO FRACTIONAL PULSES ABOVE

                CCS             BUF                     # PIPAZ, PIPAY, PIPAX
                AD              NEG1
                TCF             1/GYRO          +1
LGCOMP          ECADR           GCOMP                   # LESS THAN ZERO IMPOSSIBLE

                CAF             LGCOMP

                TC              BANKCALL
                CADR            IMUPULSE                # CALL GYRO TORQUING ROUTINE
                TC              BANKCALL
                CADR            IMUSTALL                # WAIT FOR PULSES TO GET OUT
                TCF             ENDOFJOB                # TEMPORARY

GCOMP1          CAF             FOUR                    # PIPAZ, PIPAY, PIPAX
                TS              BUF

                INDEX           BUF                     # RESCALE

                CA              GCOMP           +1
                EXTEND
                MP              BIT8                    # SHIFT MINOR PART LEFT 7 - MAJOR PART = 0
                INDEX           BUF
                LXCH            GCOMP           +1      # BITS 8-14 OF MINOR PART WERE = 0

                CCS             BUF                     # PIPAZ, PIPAY, PIPAX
                AD              NEG1
                TCF             GCOMP1          +1
COMPCHK         DEC             -1                      # LESS THAN ZERO IMPOSSIBLE
                TCF             ENDOFJOB

## Page 809
NBDONLY         CCS             GCOMPSW                 # BYPASS IF GCOMPSW NEGATIVE
                TCF             +3
                TCF             +2
                TCF             ENDOFJOB

                CA              TIME1                   # (CS) X 2(+14)
                XCH             1/PIPADT                # PREVIOUS TIME
                COM

                AD              1/PIPADT
NBD2            CCS             A                       # CALCULATE ELAPSED TIME
                AD              ONE                     # NO TIME1 OVERFLOW
                TCF             NBD3                    # RESTORE TIME DIFFERENCE AND JUMP
                TCF             +2                      # TIME1 OVERFLOW
                TCF             ENDOFJOB                # IF ELAPSED TIME = 0  (DIFFERENCE = -0)

                COM                                     # CALCULATE ABSOLUTE DIFFERENCE
                AD              POSMAX

NBD3            EXTEND                                  # C(A) = DELTAT    (CS) X 2(+14)
                MP              BIT10                   # SHIFT RIGHT 5
                DXCH            VBUF
                EXTEND
                DCA             VBUF
                DXCH            MPAC                    # DELTAT NOW SCALED (CS) X 2(+19)

                CAF             ZERO
                TS              GCOMPSW                 # INDICATE COMMANDS 2 PULSES OR LESS
                TS              BUF                     # PIPAX, PIPAY, PIPAZ

                CS              NBDX                    # (GYRO PULSES)/(CS) X 2(-5)
                TC              FBIASSUB                # -(NBDX)(DELTAT)    (GYRO PULSES) X 2(+14)


                EXTEND
                DCS             VBUF
                DXCH            MPAC                    # DELTAT SCALED (CS) X 2(+19)
                CA              NBDY                    # (GYRO PULSES)/(CS) X 2(-5)
                TC              FBIASSUB                # -(NBDY)(DELTAT)    (GYRO PULSES) X 2(+14)

                EXTEND
                DCS             VBUF
                DXCH            MPAC                    # DELTAT SCALED (CS) X 2(+19)

                CS              NBDZ                    # (GYRO PULSES)/(CS) X 2(-5)
                TC              FBIASSUB                # +(NBDZ)(DELTAT)    (GYRO PULSES) X 2 (+14)

                CCS             GCOMPSW                 # ARE GYRO COMMANDS GREATER THAN 2 PULSES
                TCF             1/GYRO                  # YES
                TCF             ENDOFJOB                # NO

## Page 810
FBIASSUB        XCH             Q

                TS              BUF             +1

                CA              Q                       # NBD SCALED (GYRO PULSES)/(CS) X 2(-5)
                EXTEND
                MP              MPAC                    # DELTAT SCALED (CS) X 2(+19)
                INDEX           BUF
                DAS             GCOMP                   # HI(NBD)(DELTAT)    (GYRO PULSES) X 2(+14)

                CA              Q                       # NOW FRACTIONAL PART
                EXTEND
                MP              MPAC            +1
                TS              L

                CAF             ZERO
                INDEX           BUF
                DAS             GCOMP                   # (NBD)(DELTAT)     (GYRO PULSES) X 2(+14)

                TCF             DRFTSUB2                # CHECK MAGNITUDE OF COMPENSATION





LASTBIAS        CCS             GCOMPSW                 # BYPASS IF GCOMPSW NEGATIVE
                TCF             +3
                TCF             +2
                TCF             ENDOFJOB

                CAF             PRIO31                  # 2 SECONDS SCALED (CS) X 2(+14)
                XCH             1/PIPADT
                COM
                AD              PIPTIME         +1      # TIME AT PIPAI = 0
                TCF             NBD2




GCOMPZER        CAF             LGCOMP                  # ROUTINE TO ZERO GCOMP BEFORE FIRST
                XCH             EBANK                   # CALL TO 1/PIPA
                TS              MODE

                CAF             ZERO
                TS              GCOMPSW
                TS              GCOMP
                TS              GCOMP   +1
                TS              GCOMP   +2

                TS              GCOMP   +3
                TS              GCOMP   +4
                TS              GCOMP   +5

## Page 811
                CA              MODE
                TS              EBANK
                TCF             SWRETURN                # RETURN TO CALLER
