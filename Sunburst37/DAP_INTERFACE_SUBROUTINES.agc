### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    DAP_INTERFACE_SUBROUTINES.agc
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
## Reference:   pp. 453-459
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-30 HG   Transcribed
##              2017-06-15 HG   Fix operand XCH  -> TS
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 453
                BANK            16
                EBANK=          DT
# MOD 0         DATE    11/15/66        BY GEORGE W. CHERRY

# FUNCTIONAL DESCRIPTION

#          HEREIN ARE A COLLECTION OF SUBROUTINES WHICH ALLOW MISSION CONTROL PROGRAMS TO CONTROL THE MODE
#          AND INTERFACE WITH THE DAP.

# CALLING SEQUENCES

# IN INTERRUPT OR WITH INTERRUPT INHIBITED
#          TC     IBNKCALL
#          FCADR  ROUTINE

# IN A JOB WITHOUT INTERRUPT INHIBITED
#          INHINT
#          TC     IBNKCALL
#          FCADR  ROUTINE
#          RELINT

# OUTPUT
#          SEE INDIVIDUAL ROUTINES BELOW

# DEBRIS

#          A,L, AND SOMETIMES MDUETEMP

## Page 454
# DAPBOOLS BITS AND NAMES

OURRCBIT        EQUALS          BIT1                    # INTERNAL DAP RATE COMMAND ACTIVITY FLAG
TRYGIMBL        EQUALS          BIT2                    # DESCENT TRIM GIMBAL CONTROL SYSTEM FLAG

# STILL AVAILABLE BIT3

ACC4OR2X        EQUALS          BIT4                    # 2 OR 4 JET X-TRANSLATION MODE FLAG
AORBSYST        EQUALS          BIT5                    # P-AXIS ROTATION JET SYSTEM (A OR B) FLAG
ULLAGER         EQUALS          BIT6                    # INTERNAL ULLAGE REQUEST FLAG
DBSELECT        EQUALS          BIT7                    # DAP DEADBAND SELECT FLAG
APSGOING        EQUALS          BIT8                    # ASCENT PROPULSION SYSTEM BURN FLAG
VIZPHASE        EQUALS          BIT9                    # DESCENT VISIBILITY PHASE FLAG
PULSES          EQUALS          BIT10                   # MINIMUM IMPULSE RHC MODE FLAG

GODAPGO         EQUALS          BIT11                   # DAP ENABLING FLAG

# STILL AVAILABLE BIT12

# STILL AVAILABLE BIT13

AUTORHLD        EQUALS          BIT14                   # AUTOMATIC MODE RATE HOLD FLAG
SPSBACUP        EQUALS          BIT15                   # SPS BACKUP DAP FLAG



SETMINDB        CAF             EBANK6
                TS              L
                LXCH            EBANK
                CAF             NARROWDB
                TS              DB
                CS              DBSELECT
                MASK            DAPBOOLS
                TS              DAPBOOLS
                LXCH            EBANK
                TC              Q

SETMAXDB        CAF             EBANK6

                TS              L
                LXCH            EBANK
                CAF             WIDEDB
                TS              DB
                CS              DAPBOOLS
                MASK            DBSELECT
                ADS             DAPBOOLS
                LXCH            EBANK
                TC              Q

ULLAGE          CS              DAPBOOLS
                MASK            ULLAGER
                ADS             DAPBOOLS

## Page 455
                TC              Q

NOULLAGE        CS              ULLAGER
                MASK            DAPBOOLS
                TS              DAPBOOLS
                TC              Q

HOLDRATE        CAF             EBANK6
                XCH             EBANK
                TS              MDUETEMP
                CS              DAPBOOLS
                MASK            AUTORHLD
                ADS             DAPBOOLS

                EXTEND
                DCA             OMEGAP
                DXCH            OMEGAPD
                CAE             OMEGAR
                TS              OMEGARD

COMNEXIT        EXTEND
                DCA             CDUY
                DXCH            CDUYD
                CAE             CDUX
                TS              CDUXD

                CAE             MDUETEMP
                TS              EBANK
                TC              Q

STOPRATE        CAF             EBANK6
                XCH             EBANK
                TS              MDUETEMP
                CS              AUTORHLD
                MASK            DAPBOOLS
                TS              DAPBOOLS

                CAF             ZERO
                TS              OMEGAPD
                TS              OMEGAQD
                TS              OMEGARD
                TS              DELCDUX
                TS              DELCDUY

                TS              DELCDUZ
                TCF             COMNEXIT

SETRATE         EQUALS          HOLDRATE
NARROWDB        DEC             0.00167                 # 0.3 DEGREES SCALED AT PI RADIANS
WIDEDB          DEC             0.02778                 # 5.0 DEGREES SCALED AT PI RADIANS

## Page 456
# SUBROUTINE NAME: 1. UPCOAST     MOD. NO. 1  DATE: DECEMBER 4, 1966
#                  2. ALLCOAST

#                  3. WCHANGE

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# "UPCOAST" SETS UP DAP VARIABLES TO THEIR ASCENT-COAST VALUES.

# GROUNDRULE: IT MUST BE CALLED AS SOON AS ASCENT COAST IS DETECTED.

# "ALLCOAST" SETS UP MANY DAP VARIABLES FOR "STARTDAP" IN "DAPIDLER".

# GROUNDRULE: DESCOAST IS CALLED AS SOON AS DESCENT COAST IS DETECTED.

# "WCHANGE" SETS UP THE VARIABLE FOR "WCHANGER" AS A STORAGE SAVING DEVICE.

# CALLING SEQUENCE: (SAME AS ABOVE.)

# SUBROUTINES CALLED: NONE.

# ZERO: AOSQ,AOSR,AOSU,AOSV,AOSQTERM,AOSRTERM,ALL NUS.

# SET URGRATQ AND URGRATR TO POSMAX.

# OUTPUT: WFORP   (1-K)    MINIMPDB  APSGOING/DAPBOOLS

#         WFORQR  (1-K)/8  DBMINIMP

# DEBRIS: A,L.

# ***** WARNING. *****  EBANK MUST BE SET TO 6.

                BANK            20
                EBANK=          WFORP

DESCOAST        INHINT                                  # (MISSION ENTRY)

ALLCOAST        CS              TRYGIMBL                # SINCE THE DESCENT ENGINE IS OFF, LM DAP
                MASK            DAPBOOLS                # USE OF TRIM GIMBAL CONTROL SYSTEM IS
                AD              TRYGIMBL                # CLEARLY IMPOSSIBLE.
                TS              DAPBOOLS

                CAF             0.3DEGDB                # SET BOTH MINIMUM IMPULSE DEADBANDS TO
                TCF             MINIMSTO                # 0.3 DEGREES SCALED AT PI RADIANS.

UPCOAST         INHINT                                  # STOP INTERRUPTS FROM WREAKING HAVOC.

                CS              APSGOING                # TURN OFF APS BURN BIT IN DAPBOOLS SINCE
                MASK            DAPBOOLS                # LEM IS STAGED FOR ASCENT, BUT THE ASCENT

                TS              DAPBOOLS                # ENGINE IS NOT ON.

## Page 457
                CAF             0.00444                 # IN ASCENT COAST, SET BOTH MINIMUM
MINIMSTO        TS              MINIMPDB                # IMPULSE DEADBANDS TO 0.08 DEGREES
                TS              DBMINIMP                # SCALED AT PI RADIANS.

                CAF             POSMAX                  # SET URGENCY FUNCTION CORRECTION RATIOS
                TS              URGRATQ                 # TO ALMOST 1 BEFORE BEING SET IN AOSJOB.
                TS              URGRATR                 # SCALED AT 1.

                CAF             13DEC                   # ZERO THE FOLLOWING DAP ERASABLES:
CLEARASC        TS              KCOEFCTR                # AOSQ  AOSQTERM  NJ+Q  NJ+U
                CAF             ZERO                    # AOSR  AOSRTERM  NJ-Q  NJ-U
                INDEX           KCOEFCTR                # AOSU            NJ+R  NJ+V
                TS              AOSQ                    # AOSV            NJ-R  NJ-V
                CCS             KCOEFCTR
                TCF             CLEARASC

WCHANGE         CAF             0.3125                  # K = 0.5
                TS              WFORP                   # WFORP = WFORQR = K/DT = K/.1 = 10K = 5
                TS              WFORQR                  # SCALED AT 16 PER SECOND.

                EXTEND                                  # K = 0.5 IMPLIES (1-K) = 0.5:
                DCA             (1-K)S                  # (1-K)   = 0.5    SINCE SCALED AT 1.
                DXCH            (1-K)                   # (1-K)/8 = 0.0625 SINCE SCALED AT 8.

# *** NOTE THAT STARTDAP RESETS WFORP,WFORQR,(1-K),(1-K)/8. ***

                RELINT                                  # LET INTERRUPTS LOOSE.

                TC              Q                               # RETURN



0.3DEGDB        DEC             0.00167
13DEC           DEC             13

## Page 458
ASCDAP          INHINT                                  # (MISSION ENTRY)

                CAF             APSGOING                # CHECK AOSTASK BIT OF DAPBOOLS
                MASK            DAPBOOLS                # IF 0, SET BIT AND INITIATE WAITLIST TASK
                CCS             A                       # IF 1, THEN TASK LOOP ALREADY BEGUN
                TCF             ASCDAP1                 # END OF ASCENT DAP
                CAF             APSGOING                # SET BIT TO INDICATE AOSTASK SET UP AND
                ADS             DAPBOOLS                # ASCENT LOGIC.  BIT CLEARLY NOT SET YET.

                CS              DB                      # MODIFY THE TJETLAW FOR ASCENT:
                TS              MINIMPDB                # (IN ONE EQUATION DELETE MINIMPDB AND
                CAF             ZERO                    # SHIFT THE SWITCHING CURVE TO THE ORIGIN)
                TS              DBMINIMP                # MINIMPDB = -DB, DBMINIMP = 0

                TS              SUMRATEQ                # INITIALIZES SUMS OF JET RATES.
                TS              SUMRATER
                TS              KCOEFCTR                # INITIALIZE APS BURN TIMER.

                CAE             OMEGAQ                  # CREATE OLD OMEGAQ
                TS              OLDWFORQ
                CAE             OMEGAR                  # CREATE OLD OMEGAR
                TS              OLDWFORR

# ***** EVENTUALLY, USE 2SECWLT4 FROMM FIXED-FIXED AND NEW NAME. *****

                CAF             2SECSDAP                # SET UP AOSTASK TO BEGIN IN 2 SECONDS
                TC              WAITLIST                # IT THEN SETS UP A LOOP ON WAITLIST FOR
                EBANK=          AOSQ
                2CADR           AOSTASK                 # 2 SECOND INTERVALS AND CHECKS FOR THE
# REF   1              20,2145   40006 0                                  SHUTDOWN CONDITION IN BIT8 OF DAPBOOLS     
# ****************************************************************************************************************

# REMOVE THIS AND THE TASKS WHEN THE INERTIA ESTIMATOR WORKS.

                CAF             ONE                     # *** SPECIAL DAP CHECKOUT SEQUENCE ***
                TC              WAITLIST                # THESE THREE CALLS TO WAITLIST BEGIN A
                EBANK=          IXX

                2CADR           IXXTASK                 # COMPLICATED PROCEDURE TO DECREMENT THE
                CAF             ONE                     # INERTIA MATRIX DIAGONAL ELEMENTS (EACH
                TC              WAITLIST                # SCALED AT 2(+18) SLUG FEET(2) ) BY ONE
                EBANK=          IYY
                2CADR           IYYTASK                 # BIT AS SOON AS APPROPRIATE BY A NOMINAL
                CAF             ONE                     # LINEAR APPROXIMATION TO INERTIAL CHANGE.
                TC              WAITLIST
                EBANK=          IZZ
                2CADR           IZZTASK                 # *** NOT TO BE USED IN MISSIONS ***

## Page 459
# ****************************************************************************************************************

DESDCAP         INHINT                                  # (MISSION ENTRY)

                CAF             DBAUTO                  # SINCE ENGINE IS ON:
                TS              DB                      # SET DEADBAND TO 1.0 DEGREES

ASCDAP1         RELINT                                  # LET INTERRUPTS LOOSE.

                TC              Q                       # RETURN.

DBAUTO          DEC             0.00556                 # 1 DEGREE DEADBAND SCALED AT PI RADIANS
