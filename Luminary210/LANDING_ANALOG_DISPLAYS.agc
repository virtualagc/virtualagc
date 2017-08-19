### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LANDING_ANALOG_DISPLAYS.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 895-904
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-27 HG   Transcribed
##              2016-12-12 HG   Fix operannd modifier none -> +4
##		2016-12-25 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.
##		2017-08-19 MAS	Fixed a typo found while transcribing Zerlina 56.

## Page 895
                BANK            21
                SETLOC          R10
                BANK

                EBANK=          END-E7
                COUNT*          $$/R10

# ****************************************************************************************************************
# LANADISP:  DISPLAY INERTIAL DATA ROUTINE FOR DESCENT AND ABORTS                            THIS VERSION BY EYLES
# ****************************************************************************************************************

LANADISP        LXCH            PIPCTR1                 # UPDATE TBASE2 AND PIPCTR SIMULTANEOUSLY
                CS              TIME1
                DXCH            TBASE2

                CS              FLAGWRD7                # IS LANDING ANALOG DISPLAYS FLAG SET?
                MASK            SWANDBIT
                CCS             A
                TCF             DISPRSET        +1      # NO:   GO RESET

# ************************************************************************
# COMPUTE VELOCITY VECTOR
# ************************************************************************

# DO EVERYTHING POSSIBLE BEFORE READING PIPAS.

                EXTEND
                DCS             VSURFACE
                DXCH            VVECTX
                EXTEND
                DCA             V
                DDOUBL
                DDOUBL
                DAS             VVECTX

                EXTEND
                DCS             VSURFACE        +2
                DXCH            VVECTY
                EXTEND
                DCA             V               +2
                DDOUBL
                DDOUBL
                DAS             VVECTY

                EXTEND
                DCS             VSURFACE        +4
                DXCH            VVECTZ
                EXTEND
                DCA             V               +4
                DDOUBL

## Page 896
                DDOUBL
                DAS             VVECTZ

# COMPUTE TIME SINCE PIPTIME.

                CS              PIPTIME         +1
                AD              TIME1
                AD              HALF
                AD              HALF
                XCH             DT                      # DT SINCE PIPTIME IN UNITS 0F 2(14) CS

# ADD IN PIPA PULSES.

                CA              PIPATMPX
                AD              PIPAX
                EXTEND
                MP              LANAKPIP
                DAS             VVECTX

                CA              PIPATMPY
                AD              PIPAY
                EXTEND
                MP              LANAKPIP
                DAS             VVECTY

                CA              PIPATMPZ
                AD              PIPAZ
                EXTEND
                MP              LANAKPIP
QUARDUMP        DAS             VVECTZ                  # TAG IS FOR EDITS

# FINALLY, ADD IN CONTRIBUTIONS OF GRAVITY AND PIPA BIAS.

                CA              G-VBIASX                # G-VBIASX IS IN UNITS OF 2(-9) M/CS/CS
                EXTEND
                MP              DT
                DAS             VVECTX                  # VVECTX IN UNITS OF 2(5) M/CS

                CA              G-VBIASY                # G-VBIASY IS IN UNITS OF 2(-9) M/CS/CS
                EXTEND
                MP              DT
                DAS             VVECTY                  # VVECTY IN UNITS OF 2(5) M/CS

                CA              G-VBIASZ                # G-VBIASZ IS IN UNITS OF 2(-9) M/CS/CS
                EXTEND
                MP              DT
                DAS             VVECTZ                  # VVECTZ IN UNITS OF 2(5) M/CS

# ************************************************************************
# COMPUTE ALTITUDE AND ALTITUDE-RATE

## Page 897
# ************************************************************************
ALTSTUFF        CA              RUNITX                  # COMPUTE RADIAL VELOCITY
                EXTEND
                MP              VVECTX
                DXCH            ALTRATE
                CA              RUNITX                  # COMPUTE THE MORE SENSITIVE TERM IN DP
                EXTEND
                MP              VVECTX          +1
                TS              L
                CAF             ZERO
                DAS             ALTRATE
                CA              RUNITY                  # NOTE:  WITH NORMAL DESCENT IMU ALIGNMENT
                EXTEND                                  #   THIS TERM IS ALWAYS ZERO, BUT ALTRATE
                MP              VVECTY                  #   CAN BE DISPLAYED DURING ASCENT TOO
                DAS             ALTRATE
                CA              RUNITZ
                EXTEND
                MP              VVECTZ
                DAS             ALTRATE

                CA              DALTRATE                # COMPENSATE FOR CHANGE IN DIRECTION OF R
                EXTEND
                MP              DT
                DAS             ALTRATE                 # ALTRATE IN UNITS OF 2(5) M/CS

                EXTEND
                DCA             ALTRATE
                DXCH            ALTRTEMP
                EXTEND
                DCA             HDOTLAD
                DAS             ALTRTEMP                # AVERAGE ALTRATE IN UNITS OF 2(4) M/CS

# THE FOLLOWING COMPUTATION FAILS IF DT EXCEEDS 20.47 SECONDS (UNLIKELY).

                CA              DT
                EXTEND
                MP              BIT4
                CA              L                       # FETCH DT FROM L IN UNITS OF 2(11) CS
                EXTEND
                MP              ALTRTEMP
                DXCH            ALTITUDE
                EXTEND
                DCA             HCALCLAD
                DAS             ALTITUDE                # ALTITUDE IN UNITS OF 2(15) METERS

# ************************************************************************
# SEND OUT ALTITUDE-RATE IF POSSIBLE
# ************************************************************************

## Page 898
                CS              FLAGWRD1                # IS INITIALIZATION IN ORDER?
                MASK            DIDFLBIT
                CCS             A
                TCF             DISPINIT                # YES:  THEN GO DO IT

                CAF             BIT2                    # NO:   ARE RR ERROR COUNTERS ENABLED?
                EXTEND
                RAND            CHAN12
                EXTEND
                BZF             DISPRSET                # NO:   REINITIALIZE DISPLAYS
ALTRROUT        EXTEND                                  # YES:  SIGNIFY ALTITUDE-RATE (BIT2 IN A)
                WOR             CHAN14

                EXTEND
                DCA             ALTRATE
                DDOUBL                                  # RESCALE ALTRATE TO UNITS OF 2(2) M/CS
                DDOUBL
                DDOUBL
                EXTEND
                MP              ALTRCONV                # RESCALE TO UNITS OF .5 F/S/BIT

                XCH             L                       # ROUND TO NEAREST .5 F/S
                DOUBLE
                TS              Q
                CAF             ZERO
                ADS             L

                AD              NEGMAX
                TS              L
                TCF             +3
                AD              L
                COM
 +3             XCH             ALTM

                CAF             BIT3
                EXTEND
                WOR             CHAN14

                CA              TWELVE                  # DELAY 120 MS FOR DATA OUTPUT
                                                        # NOTE - THIS DELAY MUST BE GREATER THAN
                                                        # 100 MS FOR COMPATIBILITY WITH THE LMS
                TC              VARDELAY

ALTROUT         CS              BIT2                    # SIGNIFY ALTITUDE
                EXTEND
                WAND            CHAN14

                CA              ALTITUDE        +1
                EXTEND
                MP              ALTCONV

## Page 899
                TS              L
                CAF             ZERO
                DXCH            ALTTEMP
                CA              ALTITUDE
                EXTEND
                MP              ALTCONV
                DAS             ALTTEMP                 # ALTITUDE IN UNITS OF 9.380 FEET/BIT

                DXCH            ALTTEMP
                DDOUBL
                DDOUBL                                  # RESCALE TO UNITS OF 2.345 FEET/BIT
                OVSK
                TCF             +4                      # NO OVERFLOW:  -38420 < ALTITUDE < +38420

                MASK            POSMAX                  # RESET OVERFLOW
                AD              BIT15
                TCF             +5

 +4             CCS             A                       # APPLY LOWER LIMIT OF POSITIVE ZERO
                AD              ONE
                TCF             +2
                CAF             ZERO

 +5             XCH             ALTM
                CAF             BIT3
                EXTEND
                WOR             CHAN14

# ************************************************************************
# SEND OUT FORWARD AND LATERAL VELOCITIES
# ************************************************************************

                TC              CROSCOMP                # FIRST CALL SUBROUTINE TO COMPUTE THEM

                CAF             BIT10                   # 1/32 TO ITEMP2 FOR USE AS DIVISOR BELOW
                TS              ITEMP2

                CAF             MAXVEL                  # LIMIT COMMAND TO 198.645 F/S
                LXCH            FORVTEMP
                TC              LADLIMIT
                LXCH            FORVTEMP        +1
                EXTEND                                  # RESCALE TO UNITS OF ONE M/CS
                DV              ITEMP2
                EXTEND                                  # RESCALE TO UNITS OF .5571 F/S/BIT
                MP              VELCONV
                XCH             L                       # ROUND TO NEAREST .5571 F/S
                DOUBLE
                TS              Q
                TCF             FORVOUT
                ADS             L

## Page 900
FORVOUT         CS              FORVMETR                # SUBTRACT METER INDICATOR TO GET CHANGE
                ADS             L
                CA              MAXDBITS
                TC              LADLIMIT                # LIMIT CHANGE TO ABOUT 300 F/S
                AD              NEG0
                TS              CDUSCMD
                ADS             FORVMETR                # UPDATE METER INDICATOR

                CAF             MAXVEL                  # LIMIT COMMAND TO 198.645 F/S
                LXCH            LATVEL
                TC              LADLIMIT
                LXCH            LATVEL          +1
                EXTEND                                  # RESCALE TO UNITS OF ONE M/CS
                DV              ITEMP2
                EXTEND                                  # RESCALE TO UNITS OF .5571 F/S/BIT
                MP              VELCONV
                XCH             L                       # ROUND TO NEAREST .5571 F/S
                DOUBLE
                TS              Q
                TCF             LATVOUT
                ADS             L
LATVOUT         CS              LATVMETR                # SUBTRACT METER INDICATOR TO GET CHANGE
                ADS             L
                CAF             MAXDBITS
                TC              LADLIMIT                # LIMIT CHANGE TO ABOUT 300 F/S
                AD              NEG0
                TS              CDUTCMD
                ADS             LATVMETR                # UPDATE METER INDICATOR

                CAF             BITSET                  # SET DRIVE BITS
                EXTEND
                WOR             CHAN14

LANADEND        TC              TASKOVER

# ************************************************************************
# SUBROUTINE TO COMPUTE FORWARD AND LATERAL VELOCITIES
# ************************************************************************

#     THE SCALARS VHY AND VHZ, COMPUTED NEXT, ARE THE VELOCITIES ALONG UNIT VECTORS UHYP AND UHZP. UHYP NORMAL
# TO THE PRE-PDI ORBITAL PLANE, UHZP IN TURN NORMAL TO UHYP AND THE POSITION VECTOR.  NOW SINCE FOR THE "LANDING
# ALIGNMENT" OF THE IMU THE STABLE-MEMBER Y-AXIS IS DEFINED THE SAME WAY AS UHYP, VVECTY IS PRECISELY VHY.
# FURTHERMORE, THE Y-TERM OF THE VHZ COMPUTATION DROPS OUT, AND THE FOLLOWING USEFUL EQUALITIES BECOME TRUE:
# UHZPX = - RUNITZ AND UHZPZ = RUNITX.  DRAW A PICTURE TO BE CONVINCED.

#     NOTE THAT IN THIS VERSION CROSS-POINTER DISPLAYS ARE OUTPUT DURING ASCENT AND ABORTS AS WELL AS DESCENT.

CROSCOMP        CS              FLAGWRD0                # IS R10FLAG SET TO INDICATE ASCENT?
                MASK            R10FLBIT
                EXTEND

## Page 901
                BZF             APSLAD                  # YES:  DISPLAY LATVEL IN INERTIAL AXES

                CS              RUNITZ                  # NO:   COMPUTE DOWNRANGE VELOCITY
                EXTEND
                MP              VVECTX
                DXCH            VHZ
                CA              RUNITX
                EXTEND
                MP              VVECTZ
                DAS             VHZ
                CA              RUNITX                  # COMPUTE THE MORE SENSITIVE TERM IN DP
                EXTEND
                MP              VVECTZ          +1
                TS              L
                CAF             ZERO
                DAS             VHZ                     # VHZ IN UNITS OF 2(5) M/CS

                EXTEND
                DCA             VVECTY
                DXCH            VHY                     # VHY IN UNITS OF 2(5) M/CS

                CAF             EBANK6                  # SWITCH TO DAP EBANK
                TS              EBANK
                EBANK=          M22

                CA              M32                     # COS(AOG)
                EXTEND
                MP              VHZ
                DXCH            FORVTEMP
                CS              M22                     # SIN(AOG)
                EXTEND
                MP              VHY
                DAS             FORVTEMP

                CA              M32                     # COS(AOG)
                EXTEND
                MP              VHZ             +1
                TS              ITEMP2
                CS              M22                     # SIN(AOG)
                EXTEND
                MP              VHY             +1
                AD              ITEMP2
                TS              L
                CAF             ZERO
                DAS             FORVTEMP                # FORWARD VELOCITY IN UNITS OF 2(5) M/CS

                CA              M22                     # SIN(AOG)
                EXTEND
                MP              VHZ
                DXCH            LATVEL

## Page 902
                CA              M32                     # COS(AOG)
                EXTEND
                MP              VHY
                DAS             LATVEL

                CA              M22                     # SIN(AOG)
                EXTEND
                MP              VHZ             +1
                TS              ITEMP2
                CA              M32                     # COS(AOG)
                EXTEND
                MP              VHY             +1
                AD              ITEMP2
                TS              L
                CAF             ZERO
                DAS             LATVEL                  # LATERAL VELOCITY IN UNITS OF 2(5) M/CS

                INCR            BBANK                   # RETURN TO SERVICER EBANK
                EBANK=          HDOTLAD

CROSSOUT        EXTEND                                  # MOVE FORVTEMP TO FORVEL FOR DSKY DISPLAY
                DCA             FORVTEMP
                DXCH            FORVEL

                TC              Q

APSLAD          TS              FORVTEMP                # DURING ASCENT AND ABORTS COME HERE TO
                TS              FORVTEMP        +1      #   DISPLAY LATVEL = SM Y-AXIS VELOCITY

                EXTEND
                DCA             VVECTY
                DXCH            LATVEL
                EXTEND                                  # ADD SURFACE VELOCITY BACK IN SO APS
                DCA             VSURFACE        +2      #   LATVEL DISPLAY WILL BE IN TRUE
                DAS             LATVEL                  #   STABLE-MEMBER COORDINATES

                TCF             CROSSOUT                # REJOIN THE MAINSTREAM

# ************************************************************************
# LANDING ANALOG DISPLAYS INITIALIZATION
# ************************************************************************

DISPINIT        TC              CROSCOMP               # FIRST COMPUTE BUT NOT OUTPUT VELOCITIES

                CS              FLAGWRD1                # SET DIDFLAG
                MASK            DIDFLBIT
                ADS             FLAGWRD1

                CAF             BIT8                    # SET DISPLAY INERTIAL DATA OUTBIT
                EXTEND

## Page 903
                WOR             CHAN12

                CS              ZERO                    # ZERO METER INDICATORS
                TS              LATVMETR
                TS              FORVMETR

                CAF             BIT4                    # SET UP TASK TO FINISH INITIALIZATION
                TC              TWIDDLE
                ADRES           INTLZE
                TCF             LANADEND

INTLZE          CAF             BIT2                    # ENABLE RR ERROR COUNTER
                EXTEND
                WOR             CHAN12

                CS              IMODES33                # SET INERTIAL DATA FLAG
                MASK            BIT8
                ADS             IMODES33
                TC              TASKOVER

# ************************************************************************
# LANDING ANALOG DISPLAYS RESET ROUTINE
# ************************************************************************

DISPRSET        TC              CROSCOMP                # FIRST COMPUTE BUT NOT OUTPUT VELOCITIES

 +1             CS              DIDFLBIT                # RESET DIDFLAG
                MASK            FLAGWRD1
                TS              FLAGWRD1

                CAF             BIT8                    # WAS INERTIAL DATA JUST DISPLAYED?
                MASK            IMODES33
                CCS             A
                CAF             BIT2                    # YES:  DISABLE RR ERROR COUNTER AND
                AD              BIT8                    # NO:   RESET DISPLAY INERTIAL DATA OUTBIT
                COM
                EXTEND
                WAND            CHAN12

                CS              BIT8
                MASK            IMODES33
                TS              IMODES33
                TCF             LANADEND

# ************************************************************************
# CONSTANTS FOR LANDING ANALOG DISPLAYS
# ************************************************************************

# CONSTANTS ON A-CARDS ARE FOUND IN THE CONTROLLED CONSTANTS SECTION

## Page 904
# LANAKPIP        DEC             .0512                 SCALES PIPAS TO UNITS OF 2(5) M/CS

# MAXVEL          OCT             00466                 198.645 F/S IN UNITS OF 2(5) M/CS

# MAXDBITS        OCT             01034                 ABOUT 300 F/S

# VELCONV         DEC             .03594                SCALES VEL AT ONE M/CS TO .5571 F/S/BIT

# ALTRCONV        DEC             .16020                SCALES ALTR AT 2(2) M/CS TO .5 F/S/BIT

# ALTCONV         DEC             .69954                SCALES ALTITUDE AT 2(15) M TO 9.38 F/BIT

BITSET          =               PRIO6                	# CROSS-POINTER DRIVE BITS

# ************************************************************************
# SUBROUTINES
# ************************************************************************
LADLIMIT        TS              ITEMP1
                CAF             ZERO
                EXTEND
                DV              ITEMP1
                CCS             A
                LXCH            ITEMP1
                TCF             +2
                TCF             +3
                CA              L
                TC              Q
                CS              ITEMP1
                TC              Q

# ************************************************************************
# THE END OF THE LANDING ANALOG DISPLAYS
# ************************************************************************
