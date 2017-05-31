### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    Q,R-AXES_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc
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
## Reference:   pp. 491-519
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-31 HG   Transcribed

## Page 491
                BANK            17
                EBANK=          DT
# THE FOLLOWING T5RUPT ENTRY BEGINS THE PROGRAM WHICH CONTROLS THE Q,R-AXIS ACTION OF THE LEM USING THE RCS JETS.
# THE NOMINAL TIME BETWEEN THE Q,R-AXIS RUPTS IS 100 MS (UNLESS THE TRIM GIMBAL CONTROL SYSTEM IS USED, IN WHICH
# CASE THIS PROGRAM IS IDLE).

                EBANK=          DT
NULLFILT        2CADR           FILDUMMY

QRAXIS          CAF             MS30QR                  # RESET TIMER IMMEDIATELY: DT = 30 MS
                TS              TIME5

                LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT

# SET UP A DUMMY KALMAN FILTER T5RUPT.  (THIS MAY BE RESET TO THE KALMAN FILTER INITIALIZATION PASS, IF THE TRIM
# GIMBAL CONTROL SYSTEM SHOULD BE USED.)

                EXTEND
                DCA             NULLFILT
                DXCH            T5ADR

# CALCULATE LEM BODY RATES FOR Q AND R AXES:

# THIS COMPUTATION IS VALID FOR BOTH ASCENT AND DESCENT SINCE THE OFFSET ACCELERATION TERM IS INCLUDED ALWAYS,
# BUT HAS VALUE ZERO IN DESCENT, AND SINCE THE WEIGHTING FACTORS ARE IN ERASABLE AND DISTINCT.

# FIRST, CONSTRUCT Y AND Z CDU INCREMENTS:

                CAE             CDUY                    # 2'S COMPLEMENT MEASUREMENT SCALED AT PI
                TS              L                       # (SAVE FOR UPDATING OF OLDYFORQ)
                EXTEND                                  # FORM INCREMENT IN CDUY FOR LAST 100 MS
                MSU             OLDYFORQ                # (100 MS OLD CDUY SAVED FROM LAST PASS)
                LXCH            OLDYFORQ                # UPDATE OLDYFORQ WITH NEW CDUY VALUE
                EXTEND                                  # RESCALE DELTA CDUY FROM PI RADIANS TO
                MP              BIT7                    # PI/2(6) RADIANS BY MULTIPLYING BY 64
                LXCH            ITEMP1                  # SAVE 1'S COMPLEMENT VALUE TEMPORARILY
                CAE             CDUZ                    # 2'S COMPLEMENT MEASUREMENT SCALED AT PI
                TS              L                       # (SAVE FOR UPDATING OF OLDZFORQ)
                EXTEND                                  # FORM INCREMENT IN CDUZ FOR LAST 100 MS
                MSU             OLDZFORQ                # (100 MS OLD CDUZ SAVED FROM LAST PASS)
                
                LXCH            OLDZFORQ                # UPDATE OLDZFORQ WITH NEW CDUZ VALUE
                EXTEND                                  # RESCALE DELTA CDUZ FROM PI RADIANS TO
                MP              BIT7                    # PI/2(6) RADIANS BY MULTIPLYING BY 64
                LXCH            ITEMP2                  # SAVE 1'S COMPLEMENT VALUE TEMPORARILY

## Page 492
# SECOND, TRANSFORM CPU INCREMENTS TO BODY-ANGLE INCREMENTS:

                CAE             M31                     # MATRIX*VECTOR(WITH x COMPONENT ZERO)
                EXTEND
                MP              ITEMP1                  # M31 * ITEMP1 = M31 * DELTA CDUY
                DXCH            ITEMP3
                CAE             M32                     # M32 * ITEMP2 = M32 * DELTA CDUZ
                EXTEND
                MP              ITEMP2                  # DELTAR = M31*(DEL CDUY) + M32*(DEL CDUZ)
                DAS             ITEMP3                  # R_BODY_ANGLE INCREMENT SCALED AT PI/2(6)

                CAE             M21                     # MATRIX*VECTOR(WITH X COMPONENT ZERO)
                EXTEND                                  # CLOBBERS ITEMP2=DEL CDUZ, FOR EFFICIENCY
                MP              ITEMP1                  # M21 * ITEMP1 = M21 * DELTA CDUY
                DXCH            ITEMP2                  # M22 * ITEMP2 = M22 * DELTA CDUZ
                EXTEND
                MP              M22                     # DELTAQ = M21*(DEL CDUY) + M22*(DEL CDUZ)
                ADS             ITEMP2                  # Q_BODY_ANGLE INCREMENT SCALED AT PI/2(6)
                
# FINALLY, DERIVE Q AND R BODY ANGULAR RATES:

                EXTEND                                  # WFORQR IS K/(NOMINAL DT) SCALED AT 16
                MP              WFORQR                  # FORM WEIGHTED VALUE OF MEASURED DATA
                XCH             OMEGAQ                  # SAVE AND BEGIN TO WEIGHT VALUE OF OLD W
                EXTEND                                  # (1-K) IS SCALED AT 1 FOR EFFICIENT CALC
                MP              (1-K)                   # (K CHANGES EVERY 2 SECONDS IN ASCENT.)
                
                AD              JETRATEQ                # WEIGHTED TERM DUE TO JET ACCELERATION
                AD              AOSQTERM                # TERM DUE TO ASCENT OFFSET ACCELERATION
                ADS             OMEGAQ                  # TOTAL RATE ESTIMATE SCALED AT PI/4

                CAE             ITEMP3                  # GET DELTAR
                EXTEND                                  # WFORQR IS K/(NOMINAL DT) SCALED AT 16
                MP              WFORQR                  # FORM WEIGHTED VALUE OF MEASURED DATA
                XCH             OMEGAR                  # SAVE AND BEGIN TO WEIGHT VALUE OF OLD W
                EXTEND                                  # (1-K) IS SCALED AT 1 FOR EFFICIENT CALC
                MP              (1-K)                   # (K CHANGES EVERY 2 SECONDS IN ASCENT.)
                AD              JETRATER                # WEIGHTED TERM DUE TO JET ACCELERATION
                AD              AOSRTERM                # TERM DUE TO ASCENT OFFSET ACCELERATION
                ADS             OMEGAR                  # TOTAL RATE ESTIMATE SCALED AT PI/4

                TC              QJUMPADR
SKIPQRAX        CA              NORMQADR
                TS              QJUMPADR                
                TCF             RESUME
NORMQADR        GENADR          NORMALQ
NORMALQ         CAF             BIT13                   # CHECKING ATTITUDE HOLD BIT
                EXTEND
                RAND            31                      # BITS INVERTED
                EXTEND
                
                BZF             CHKBIT10
                
## Page 493      
                CAF             BIT14                   # ATT HOLD BIT NOT PRESENT. CHECK FOR AUTO
                EXTEND  
                RAND            31
                EXTEND
                BZF             ATTSTEER                # AUTOMATIC STEERING, CHECK FOR RATE HOLD
                EXTEND                                  # IF MODE SELECT SW OFF DO DAPIDLER NEXT
                DCA             IDLEADRQ
                DXCH            T5ADR

                TCF             RESUME
                
                EBANK=          DT
IDLEADRQ        2CADR           DAPIDLER
CHKBIT10        CAF             BIT10                   # BIT10=1 FOR MIN IMP USE OF RHC
                MASK            DAPBOOLS
                EXTEND
                BZF             CHEKSTIK                # IN ATT-HOLD/RATE-COMMAND IF BIT10=0
                
                CAE             DELAYCTR                # SET TO 2 BY RUPT 10
                EXTEND
                BZF             XTRANS
                
                CA              MINTADR
                TS              TJETDAR
                
                CA              BIT1
                EXTEND
                RAND            31
                EXTEND
                BZF             2JETS+Q
                
                CA              BIT2
                EXTEND
                RAND            31
                EXTEND
                BZF             2JETS-Q
                
                CA              BIT5
                EXTEND
                RAND            31
                EXTEND
                BZF             2JETS+R
                
                CA              BIT6
                EXTEND
                RAND            31
                EXTEND
                BZF             2JETS-R
                
                TCF             XTRANS
                
## Page 494                
MINTJET         CAF             +T6TJMIN
                TS              TQR
                CA              ZERO
                TS              DELAYCTR
                TCF             TORQUEV
                
CHEKSTIK        CAF             BIT15                   # OUT-OF-DETENT BIT
                EXTEND
                RAND            31                      # BITS INVERTED
                
                EXTEND
                BZF             RHCACTIV                # BRANCH IF OUT OF DETENT
                CA              BIT1                    # OUR RATE COMMAND BIT
                MASK            DAPBOOLS
                
                EXTEND
                BZMF            ATTSTEER                # AUTOMATIC STEERING, CHECK FOR RATE HOLD
# WE WERE IN RATE COMMAND AND RATES MUST BE MADE SMALLER

#  ARE RATES SMALL ENOUGH NOW
                CA              OMEGAP
                EXTEND
                SQUARE
                DXCH            ITEMP1
                
                CA              OMEGAQ
                EXTEND
                SQUARE
                DAS             ITEMP1
                
                CA              OMEGAR
                EXTEND
                SQUARE
                DAS             ITEMP1
                
# WE NOW HAVE SQUARED MAGNITUDE OF RATE VECTOR IN ITEMP1
                CS              16/32400                # 1 DEG/SEC SCALED AT PI.PI/16
                AD              ITEMP1
                
                EXTEND
                BZMF            RATESMAL
                
#          THE RATE IS NOT SMALL ENOUGH YET.

                CA              OMEGAQ
                TS              QRATEDIF
                CA              OMEGAR
                TS              RRATEDIF
                TCF             OBEYQRRC
                
RATESMAL        CS              BIT1

## Page 495
                MASK            DAPBOOLS                # RATE COMMAND BIT SET TO ZERO        
                TS              DAPBOOLS
                
                CAE             CDUX
                TS              CDUXD
                CAE             CDUY
                TS              CDUYD
                CAE             CDUZ
                TS              CDUZD
                
RHACTIV         CAF             BIT1
                MASK            DAPBOOLS
                EXTEND
                BZF             XTRANS                  # LET P AXIS SET THE RATE COMMAND BIT
                
                CAE             Q-RHCCTR
                EXTEND
                MP              BIT9
                CA              -.88975
                
                EXTEND
                MP              L                       # -Q RATE COMMAND SCALED AT PI/4
                AD              OMEGAQ
                TS              QRATEDIF
                
                CAE             R-RHCCTR
                EXTEND
                MP              BIT9
                CA              -.88975
                EXTEND
                MP              L                       # -R RATE COMMAND SCALED AT PI/4.
                AD              OMEGAR
                TS              RRATEDIF
                
# ZERO,ENABLE,AND START COUNTERS 99
                CAF             ZERO
                TS              P-RHCCTR
                TS              Q-RHCCTR
                TS              R-RHCCTR
                CAF             BIT8,9
                EXTEND
                WOR             13
                
OBEYQRRC        CA              RTJETADR
                TS              TJETADR
                
                CCS             QRATEDIF
                TCF             POSQEROR
                TCF             NOQJETS
                TCF             NEGQEROR
                
## Page 496                
NOQJETS         CCS             RRATEDIF                # CHECK SIGN OF RATE ERROR AND GET ABVAL
                TCF             R+,CHKDB
                
                TCF             XTRANS
                TCF             R-,CHKDB
                TCF             XTRANS

NEGQEROR        AD              -RATEDB
                EXTEND
                BZMF            NOQJETS

                CCS             RRATEDIF
                TCF             R+Q-CHKR
                TCF             Q-NORJTS
                TCF             R-Q-CHKR

Q-NORJTS        CS              QRATEDIF
                TS              RATEDIF
                AD              -2JETLIM
                EXTEND
                BZMF            2JETS+Q
                TCF             4JETS+Q

R+Q-CHKR        AD              -RATEDB
                EXTEND
                BZMF            Q-NORJTS
                
                TC              EDOTVGEN
                TCF             2-V.RATE

R-Q-CHKR        AD              -RATEDB
                EXTEND
                BZMF            Q-NORJTS
                TC              EDOTUGEN
                EXTEND
                SU              RRATEDIF
                TCF             2+U.RATE

POSQEROR        AD              -RATEDB
                EXTEND
                BZMF            NOQJETS

                CCS             RRATEDIF
                TCF             R+Q+CHKR
                TCF             Q+NORJTS
                TCF             R-Q+CHKR

Q+NORJTS        CA              QRATEDIF
                TS              RATEDIF
                AD              -2JETLIM
                
                EXTEND
                BZMF            2JETS-Q
                
## Page 497                
                TCF             4JETS-Q

R+Q+CHKR        AD              -RATEDB
                EXTEND
                BZMF            Q+NORJTS
                TC              EDOTUGEN
                TCF             2-U.RATE

R-Q+CHKR        AD              -RATEDB
                EXTEND
                BZMF            Q+NORJTS
                TC              EDOTVGEN
                TCF             2+V.RATE

R+,CHKDB        AD              -RATEDB
                EXTEND
                BZMF            XTRANS
                CA              RRATEDIF
                TS              RATEDIF
                AD              -2JETLIM
                EXTEND
                BZMF            2JETS-R
                TCF             4JETS-R

R-,CHKDB        AD              -RATEDB
                EXTEND
                BZMF            XTRANS
                CS              RRATEDIF
                TS              RATEDIF
                AD              -2JETLIM
                EXTEND
                BZMF            2JETS+R
                
                TCF             4JETS+R

RTJETIME        CCS             RATEDIF                 # SCALED AT PI/4 RADIANS/SECOND
                AD              ONE
                TCF             +2
                AD              ONE                     # ABS(RATEDIF)
                EXTEND
                MP              1/NJETAC                # SCALED AT 2(8)/PI SECOND(2)/RADIANS
                EXTEND
                MP              BIT4                    # SCALED AT 2(3) SECONDS
                CAE             L
                EXTEND
                MP              25/32.QR                # TJET NOW PROPERLY SCALED IN A
                TS              TQR                     # AT 2(4)16/25 SECONDS
                TCF             TORQUEV

## Page 498
# DAPSECTION: XTRANS              MOD. NO. 1  DATE: NOVEMBER 20, 1966

# AUTHOR: JOHN S. BLISS (ADAMS ASSOCIATES)

# MODIFICATION BY: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# X-AXIS TRANSLATION LOGIC (IN THE ABSENSE OF Q,R-AXIS ROTATION) IS INITIATED IN THE "XTRANS" SECTION.

# XTRANS FIRST SETS ADDTLT6 AND ADDT6JTS TO ZERO FOR USE BY "JTLST" AND "T6JOB" WHEN THEY ARE CALLED.  IT THEN
# CHECKS FOR PLUS OR MINUS X TRANSLATION REQUESTS FROM THE ASTRONAUT'S STICK.  IF NONE IS REQUESTED IN THAT WAY,
# THE ULLAGE BIT OF DAPBOOLS IS CHECKED.  (NOTE THAT THE ORDER OF THE TESTS ALLOWS THE ASTRONAUT TO OVERRIDE THE
# INTERNAL ULLAGE REQUEST.)  IF NO TRANSLATION IS REQUESTED, ALL Q,R-AXIS JETS ARE TURNED OFF AND THE INTERRUPT
# IS TERMINATED.


# CALLING SEQUENCE: NONE.         SUBROUTINES CALLED: +/-TRANS

# NORMAL EXIT: 1. IF NO TRANSLATION: RESUME.
#              2.IF SOME TRANSLATION: +/-TRANS

# ALARM/ABORT MODE: NONE.

# INPUT:  ULLAGER/DAPBOOLS,BITS7,8/CHANNEL 31.

# OUTPUT: C(ANYTRANS) = NEGMAX FOR +X TRANSLATION.
#         C(ANYTRANS) = POSMAX FOR -X TRANSLATION.
#         C(TRANSNOW) = C(TRANSAVE) = +0.
#         C(TRANONLY) = PNZ

# DEBRIS: A,L,


XTRANS          CAF             ZERO                    # PICK UP ZERO AND INITIALIZE
                TS              ADDTLT6
                TS              ADDT6JTS
                
                TS              TQR                     # A ZERO OF JET TIME FOR THE TORQUE VEXTOR
                
                CAF             BIT7                    # IS PLUS X TRANSLATION DESIRED
                
                EXTEND
                RAND            31                      # CHANNEL 31 BITS INVERTED
                EXTEND
                BZF             +XORULGE                # YES, +X
                
                CAF             BIT8                    # NO, IS MINUS X TRANSLATION DESIRED
                EXTEND
                RAND            31                      # CHANNEL 31 BITS INVERTED
                EXTEND
                BZF             -XTRANS                 # YES, -X
                
                CAF             BIT6                    # NO, IS ULLAGE(+X TRANSLATION) DESIRED
                MASK            DAPBOOLS
                
## Page 499                
                CCS             A
                TCF             +XORULGE                # YES, ULLAGE
                
                CAF             ZERO                    # SINCE NEITHER ROTATION NOR TRANSLATION
                EXTEND                                  # ARE NEEDED, TURN OFF ALL JETS FOR THE
                WRITE           5                       # Q,R-AXES.
                
                TCF             RESUME
                
+XORULGE        CAF             NEGMAX                  # PLUS TRANSLATION OR ULLAGE DESIRED:
                TCF             +2                      # LOAD NEGMAX IN A AND SKIP NEXT OPCODE TO
                
-XTRANS         CAF             POSMAX                  # -X TRANSLATION DESIRED, A = POSMAX, AND
                TS              ANYTRANS                # LOAD ANYTRANS WITH A(NEG/POS MAX)
                
                CAF             ZERO                    # INITIALIZE TRANSNOW AND TRANSAVE WITH
                TS              TRANSNOW                # ZERO FOR USE IN THE JET POLICY SELECTION
                TS              TRANSAVE                # PROGRAM.
                
                EXTEND                                  # SET UP 2CADR FOR TRANSFER TO +/-XTRAN.
                DCA             JTPOLADR        
                TS              TRANONLY                # STORE POSITIVE, NON-ZERO S-REGISTER IN
                DTCB                                    # TRANONLY.  AFTER +/-XTRAN, GO TO JTLST.
                
                EBANK=          JTSONNOW
JTPOLADR        2CADR           +/-XTRAN                # TRANSLATION ONLY ENTRY TO JET POLICY

## Page 500
# DO NECESSAY PARTS OF Q,R-AXES TORQUE VECTOR RECONSTRUCTION HERE AND NOW.  FOR OTHER PARTS WAIT UNTIL THE NEXT
# P-AXIS RCS DAP T5RUPT

NORMRETN        TS              TQR


TORQUEV         CS              TQR                     # CALCULATED Q,R JET TIME (AS IN TIME6)
                AD              +T6TJMIN
                EXTEND                                  #   CORRECT BRANCH.
                BZMF            TQRGTTMI                # BRANCH FOR TQR = OR GREATER THAN MINIMP.
                CA              ZERO
                TS              TOFJTCHG                # SINCE TQR LESS THAN A MINIMUM IMPULSE,
                TCF             XTRANS                  # SEE IF TRANSLATION IS DESIRED .
TQRGTTMI        CAE             TQR                     
                TS              TOFJTCHG                
                AD              -1.5CSP
                EXTEND
                BZMF            DOQRSKIP
                CAE             JTSONNOW
                TC              WRITEQR                 # TURN ON QR JETS USING T6JOB SUBROUTINE.
                TCF             RESUME
                
SKIPQRAD        GENADR          SKIPQRAX
DOQRSKIP        CA              SKIPQRAD
                TS              QJUMADR
                
# CHANGE JET ON AND OFF BITS TO ACCOUNT FOR THE PRESENT STATE OF THE
#   CHANNEL. THE CHANGES ACCOUNT FOR PURE ROTATION ONLY- NOT TRANSLATION.
                CA              JTSONNOW                # = JETS WHICH ARE TO GO ON NOW.
                EXTEND
                RAND            5                       # MASK THE CHANNEL WITH THE DESIRED STATE.
                EXTEND                                  
                BZF             NOQRON                  # A IS ZERO IF NO JETS TO GO ON ARE ON.
                AD              BIT15                   # MAKE DIFFERENCE CORRESPOND TO A QR JET.
                EXTEND
                SU              JTSONNOW                # RESULT IS COMPLEMENT OF JET BITS WHICH
                TS              L                       #   ARE TO BE ON FOR 6.5MS MORE THAN CALC.
                EXTEND
                BZF             JTSAREON                # A=0,THUS ALL JETS TO GO ON ARE NOW ON.
TRSLTMN2        CAE             JTSATCHG
                MASK            POSMAX                  # REMOVE BIT15 FROM JTSATCHG.
                EXTEND
                BZF             NOTRANS                 # IF JTSATCHG = 0 THEN NO TRANSLATION NOW.
                CA              14-TQRMN
                ADS             TOFJTCHG                # INSURE T GREATER THAN 14 MS.
                TCF             TOJTLST
NOTRANS         CS              L
                AD              BIT15                   # MAKE JET BITS CORRESPOND TO QR AXIS.
                XCH             JTSATCHG                # JTSONNOW - L = JETS ON AT TOFJTCHG.
                                
                TS              ADDT6JTS                # JTS ON AT TOFJTCHG +ONDELAY.
                
## Page 501              
                CA              14-TQRMN
                TS              ADDTLT6
                TCF             TOJTLST
NOQRON          CA              14-TQRMN
                ADS             TOFJTCHG
                CA              ZERO
                TS              ADDTLT6
                TCF             TOJTLST
                
JTSAREON        CAE             JTSATCHG
                MASK            POSMAX
                EXTEND
                BZF             +3
                CAF             MCOMPTQR
                ADS             TOFJTCHG
                CA              ZERO
                TS              ADDTLT6
TOUTLST         CA              JTSONNOW        
                TC              WRITEQR         
                EXTEND
                DCA             JTLSTADR
                DTCB
-1.5CSP         DEC             -0.01465
+T6TJMIN        DEC             +.00073
25/32.QR        DEC             0.78125
MS20QR          OCTAL           37776
MS30QR          OCTAL           37775
MS50QR          OCTAL           37773
16/32400        DEC             0.00049
BIT8,9          OCTAL           00600
MCOMPTQR        DEC             -16                     # -10 MS COMPUTATION TIME
14-TQRMN        DEC             11

MINTADR         GENADR          MINTJET
-.88975         DEC             -.88975
(1-K),QR        DEC             0.50000                 # K = 1/2
(1-KQ)/8        DEC             0.06250
-90MS           DEC             -.00879
+90MS           DEC             0.00879
NEGCSP2         DEC             -.00977
ALL+XJTS        OCTAL           40252
2,10-OUT        OCTAL           00201
+X,A            OCTAL           40042
+X,B            OCTAL           40210
1,9-OUT         OCTAL           00104
-X,A            OCTAL           40104
-X,B            OCTAL           40021
                EBANK=          JTSONNOW
JTLSTADR        2CADR           JTLST
RTJETADR        GENADR          RTJETIME

## Page 502
# Q,R-AXES ATTITUDE STEERING CALCULATIONS:

# (EXECUTED WHEN LGC IS IN AUTOMATIC SCSMODE OR IF SCSMODE IS ATTITUDE HOLD AND THE ROTATIONAL HAND CONTROLLER IS
# NEITHER OUT OF DETENT NOR IS THE RATE COMMAND BIT SET IN DAPBOOLS)

# IMMEDIATELY AFTER CALCULATING THE ATTITUDE ERRORS, THE FOLLOWING TESTS ARE MADE TO DETERMINE WETHER THE DESCENT
# ENGINE TRIM GIMBAL SHOULD BE USED TO CONTROL THE LEM ATTITUDE RATHER THAN THE RCS JETS:

#          1) IS THE TRIM GIMBAL FUNCTIONALLY OPERATIVE?
#          2) ARE THE Q-R-AXES RCS JETS OFF?
#          3) ARE BOTH TRIM GIMBAL DRIVES OFF?
#          4) IS THE LEM RATE LESS THAN .5 DEG/SEC ABOUT BOTH AXES?

GOTOGTS         CAF             INITFLT                 # ERRORS NOW CONTROLLABLE BY TRIM GIMBAL

                TS              T5ADR                   # SET T5RUPT TO GO TO FILTER INITIALIZING
                TCF             RESUME                  # PROGRAM
                
BGIM24          OCTAL           07400
DESCADR         GENADR          TJETLAW
INITFILT        GENADR          FILTINIT                # ADDRESS OF FILTER INITIALIZATION RUPT

# "ATTSTEER" IS THE NOMINAL ENTRY POINT FOR REACTION CONTROL SYSTEM ATTITUDE STEERING:
# BEGIN ATTSTEER BY CHECKING IF RATE HOLD MODE(CURRENTLY USED ONLY AT SIVB
# -LEM SEPARATION-206 MISSION PHASE 6) IS REQUESTED(BIT 14 OF DAPBOOLS ON)
# IF BIT 14 IS OFF, BRANCH TO QERRCALC DIRECTLY AND BEGIN AUTOMATIC
# STEERING.  IF BIT 14 IS ON, TEST BIT 3 OF DAPBOOLS TO SEE IF THE DESIRED
# RATE HAS BEEN SAVED YET.  IF IT IS ON, THIS IS NOT THE FIRST PASS AND
# THE RATE HAS BEEN SAVED.  GO DIRECTLY TO QERRCALC FOR AUTOMATIC STEERING
# IF THE BIT IS OFF, THE RATE MUST BE SAVED.  TRANSFER TO SAVERATE(BANK25)
# AND RETURN AFTER FIRST PASS TO RESUME AND DAPIDLER.

# IN ORDER TO USE RATE HOLD, THE MISSION PROGRAMMER MUST SET BIT 14 OF
# DAPBOOLS ON AND SET BIT 3 OF DAPBOOLS TO ZERO.  UPON RETURNING FROM THE
# FIRST PASS AT LEAST THROUGH RATE HOLD, THE MISSION PROGRAMMER MUST RESET
# BIT 3 TO ITS PREVIOUS VALUE IF THIS IS NOT 1, BECASUE SAVERATE SETS BIT3
# TO 1 FOR ALL PASSES AFTER THE FIRST IN ORDER NOT TO SAVE THE RATE AGAIN.


# IN ADDITION TO NON-RATE HOLD MODE AND NON-FIRST PASS RATE HOLD MODE
# EXITS RO QERRCALC, THE FIRST PASS EXITS TO RESUME, IE. OUT OF INTERRUPT
# AND BACK TO DAPIDLER TO AWAIT THE NEXT CALL TO DAP.

# RATE HOLD PRODUCES THE FOLLOWING OUTPUT IN ERASABLE --

#    CDUD - SCALED AT +/-PI, DESIRED GIMBAL ANGLE

#    DELCDU - SCALED AT +/-PI, INCREMENT TO CDUD EVERY 100MS

#    OMEGAPD, QD, RD - SCALED AT +/-PI/4, BODY AXIS RATES

# ALL THESE ARE USED BY AUTOMATIC STEERING MODE EQUATIONS.

## Page 503
# RATE HOLD REQUIRES OMEGAP, Q, R EVERY .25 SE, AND ALSO REQUIRES PILO-
# TO-GIMBAL AXIS MATRIX ELEMENTS, MR12, 22, 13, 23 TO BE LOCATED IN THAT
# ORDER

# FINALLY, RATE HOLD LEAVES DEBRIS IN --

#    DLCDUIDX - LOOP INDEX USED IN COMPUTING DELCDUS, =1, 0

#    ITEMP1 - STORES TEMPORARY PRODUCTS AND SUMS, LEFT WITH DELCDUY IN 1S.



ATTSTEER        CS              DAPBOOLS
                MASK            BIT14
                CCS             A
                TCF             QERRCALC
                
# CHECK DAPBOOLS, BIT3, TO SEE IF DESIRED RATE HAS BEEN SAVED YET                

# TO COMPUTE THE DELCDUS, Y AND Z, WE SET UP A LOOP AND SOLVE THE EQUATION

#  C(DELCDUY+DLCDUIDX)=(OMEGAQ).C(MR12+DLCDUIDX)+OMEGARD.C(MR13+DLCDUIDX))
#                         .(100MS) SCALED AT PI IN 2S COMPLEMENT(LIKE CDUS)

# DURING THIS COMPUTATION, ITEMP1 IS USED TO STORE THE PARTIAL SUMS AND
# PRODUCTS.  DELCDUY IS RESCALED TO 1 AS MR12 AND MR13 ARE SCALED AT 2.
# AFTER CONVERTING TO TWOS COMPLEMENT, WE SET DELCDUX TO ZERO TO AVOID ANY
# ROLL DURING RATE HOLD MODE.  NOTE THAT DELCDUS ARE COMPUTED IN THE NEGA-
# TIVE TO ALLOW 2S COMP. MOD. SUBTRACT LATER ON (CDU-(-DELCDU))

                CAF             ONE                     # SET UP LOOP INDEX TO COMPUTE DELCDUS
NEXDLCDU        TS              DLCDUIDX                # DLCDUIDX = C(A)

                CS              OMEGAQD                 # DLCDUIDX = 1              DLCDUIDX = 0
                EXTEND                                  # ITEMP1=-OMEGAQD.MR22
                INDEX           DLCDUIDX
                MP              MR12                    # MR22 SCALED AT 1       MR12 SCALED AT 2
                TS              ITEMP1                  #                     ITEMP1=-OMEGAQD.MR12
                
                CS              OMEGARD                 # C(A)=ITEMP1 -OMEGARD.M23
                EXTEND
                INDEX           DLCDUIDX                #                C(A)=ITEMP1 -OMEGARD.MR13 
                MP              MR13                    # MR23 SCALED AT 1        MR13 SCALED AT 2
                
                AD              ITEMP1
                EXTEND                                  # DELT = 100 MS. SCALED AT 4 SEC.
                MP              100MSCAL
                TS              ITEMP1                  # ITEMP1 = C(A) . DELT
                
                CCS             DLCDUIDX                # CHECK INDEX FOR RESCALING
                TCF             +3                      # DELCDUZ SCALED AT PI/4, RESCALE UNNEEDED
                
## Page 504     
                CAE             ITEMP1                  # DELCDUY SCALED AT PI/2, RESCALE BY
                ADS             ITEMP1                  # ADDING TO ITSELF
                
                CCS             ITEMP1                  # CONVERT DELCDUS TO TWOS COMPLEMENT (SAME
                AD              ONE                     # AS CDUS).  ADD ONE TO RESTORE PRE-CCS A
                TCF             STODLCDU                # STORE DIRECT IF POSITIVE ZERO
                COM                                     # COMPLEMENT IF NECGATIVE, CSS INCREMENTS
STODLCDU        INDEX           DLCDUIDX                # IF NEGATIVE ZERO, STORE POSITIVE ZERO
                TS              DELCDUY                 # STORE FINAL DELCDUZ OR DELCDUY
                
                CCS             DLCDUIDX                # TEST INDEX DLCDUIDX, EITHER 1 OR 0
                TCF             NEXDLCDU                # IF 1, DO DELCDUY
                TS              DELCDUX                 # DELDUZ,Y DONE, 0 TO DELCDUX-NO ROLL
                
QERRCALC        CAE             CDUY                    # Q-ERROR CALCULATION
                EXTEND
                MSU             CDUYD                   # CDU ANGLE - ANGLE DESIRED (Y-AXIS)
                TS              ITEMP1                  # SAVE FOR RERRCALC
                EXTEND
                MP              M21                     # (CDUY-CDUYD)*M21 SCALED AT PI RADIANS
                XCH             ER                      # SAVE FIRST TERM (OF TWO) IN OPP.AXIS REG
                CAE             CDUZ                    # SECOND TERM CALCULATION:
                EXTEND
                MSU             CDUZD                   # CDU ANGLE -ANGLE DESIRED (Z-AXIS)
                TS              ITEMP2                  # SAVE FOR RERRCALC
                EXTEND
                
                MP              M22                     # (CDUZ-CDUZD)*M22 SCALED AT PI RADIANS
                ADS             ER                      # SAVE SUM OF TERMS, NO OVERFLOW EVER
                TS              QERROR                  # SAVE QERROR FOR EIGHT-BALL DISPLAY
                
RERRCALC        CAE             ITEMP1                  # R-ERROR CALCULATION:
                EXTEND                                  # CDU ANGLE -ANGLE DESIRED (Y-AXIS)
                MP              M31                     # (CDUY-CDUYD)*M31 SCALED AT PI RADIANS
                XCH             E                       # SAVE FIRST TERM (OF TWO) IN OPP.AXIS REG
                CAE             ITEMP2                  # SECOND TERM CALCULATION:
                EXTEND                                  # CDU ANGLE -ANGLE DESIRED (Z-AXIS)
                MP              M32                     # (CDUZ-CDUZD)*M32 SCALED AT PI RADIANS
                ADS             E                       # SAVE SUM OF TERMS, NO OVERFLOW EVER
                TS              RERROR                  # SAVE R-ERROR FOR EIGHT-BALL DISPLAY

# TEST (1): IS THE TRIM GIMBAL FUNCTIONALLY OPERATIVE?

                CAF             BIT2                    # ETST TO SEE IF LEM AND DAP MODES ALLOW
                MASK            DAPBOOLS                # USE OF TRIM GIMBAL CONTROL SYSTEM:
                CCS             A                       # BIT2 = 0 MEANS THAT TRIM GIMBAL CONTROL
                TCF             STILLRCS                # IS POSSIBLE, SO TEST OTHER TG CONDITIONS

# TEST (2): ARE THE Q,R-AXES RCS JETS OFF?
                EXTEND                                  # BUT, IF JETS ARE OFF AND TRIM GIMBAL MAY
                
                READ            5                       # POSSIBLY BE USED: BEING IN THE JET COAST
                
## Page 505XXXXXX                
# THIS CODING IS ENTERED FROM BURGZERO, WHEN BOTH URGENCIES ARE ZERO.  EXITS TO GTS IF POSSIBLE, XTRANS OTHERWISE

GIMBLTRY        CAF             USEQRJTS                # IS JET USAGE MANDATORY.
                MASK            DAPBOOLS
                CCS             A
                TCF             XTRANS                  # YES.  GO TO XTRANS.
                
                EXTEND                                  # ARE GIMBALS DRIVING?
                READ            12
                MASK            BGIM24                  # BITS 9,10,11,12 ARE GIMBAL DRIVE BITS.
                CCS             A
                TCF             XTRANS                  # YES.  DRIVING.  GO TO XTRANS.
                
                EXTEND                                  # NO.   CHECK JETS.
                READ            5                       # ARE ANY Q,R JETS ON NOW.
                                                        # (CAN ONLY BE ROTATION JETS.)
                EXTEND
                BZF             XTRANS                  # NO.   GO TO XTRANS.
                
## Page 534
                CAF             ZERO                    # YES.  TURN OFF JETS.
                EXTEND
                WRITE           5
                
                EXTEND                                  # NO.   GO TO GTS.
                DCA             GOGTSADR
                DXCH            Z
                
                EBANK=          DT
GOGTSADR        2CADR           GOTOGTS

# REMAINING CODING (HERE TO STILLRCS) STAYS IN TO KEEP ADDRESSES CONSTANT.

                TC              CCSHOLE                 # FILLER.
                TCF             STILLRCS                # NO.      SO USE RCS.
                INDEX           QRCNTR                  # YES.     TRY THE ERROR MAGNITUDE.
                CCS             QDIFF                   # IS ERROR SMALL ENOUGH FOR GTS.
                AD              -XBND+1                 # -1.4 DEG SCALED AT PI    + 1 BIT
                TCF             +2
                AD              -XBND+1
                EXTEND
                BZMF            +2                      # IS ERROR LESS,EQUAL 1.4 DEG.
                TCF             STILLRCS                # NO.      USE RCS CONTROL.
                CCS             QRCNTR                  # THIS AXIS IS FINE.   ARE BOTH DONE.
                TC              CCSHOLE                 # REMOVE REFERENCE TO ELIMINATED SYMBOL.
                TC              CCSHOLE                 # FILLER.
-RATLM+1        OCT             77512                   # -.5 DEG/SEC SCALED AT PI/4  + 1 BIT
-XBND+1         OCT             77601                   # -1.4 DEG SCALED AT PI, + 1 BIT.
# "STILLRCS" IS THE ENTRY POINT TO RCS ATTITUDE STERRING WHENEVER IT IS FOUND THAT THE TRIM GIMBAL CONTROL
# SYSTEM SHOULD NOT BE USED;

## Page 535
# Q,R-AXES RCS URGENCY FUNCTION LOGIC:

STILLRCS        CCS             DAPBOOLS                # BRANCH TO SPS-BACKUP RCS CONTROL LOGIC.
                TCF             SPSBAKUP                # WHEN BIT15/DAPBOOLS = 0.
                NOOP
                CAF             DESCADR                 # SET JET SELECT LOGIC RETURN ADDRESS TO
                TS              TJETADR                 # THE Q,R-AXIS TJETLAW CALCULATION
                
                TC              T6JOBCHK                # CHECK T6 CLOCK RUPT BEFORE SUBROUTINE
                
# CALCULATE THE RATE ERRORS SCALED AT PI/4 RADIANS/SECOND(2):

                CS              OMEGAQD
                AD              OMEGAQ                  # EDOTQ = OMEGAQ - OMEGAQD
                TS              EDOTQ
                
                CS              OMEGARD
                AD              OMEGAR                  # EDOTR = OMEGAR - OMEGARD
                TS              EDOTR
                
## Page 536
# Q,R-AXES URGENCY FUNCTION LOOP:

# SET UP LOOP TO DO R-AXIS, THEN Q-AXIS:

                CAF             ONE                     # 1: REFERS TO R-AXIS VARIABLES.
                TS              AXISCNTR                # 0: REFERS TO Q-AXIS VARIABLES.
                
# PICK UP EDOT AND RESCALE FROM PI/4 TO PI/16 RADIANS/SECOND:

URGLOOP         INDEX           AXISCNTR                # ERROR RATES ARE PRE-CALCULATED BY RATE
                CAE             EDOTQ                   # DERIVATION SCALED AT PI/4 RADIANS/SECOND
                EXTEND                                  # MULTIPLYING BY FOUR (BIT3) LEAVES EDOT
                MP              FOUR                    # AS C(L) IF EDOT LESS THAN 11.25 DEG/SEC.
                EXTEND
                BZF             +2                      # IF C(A) NON-ZERO, THEN EDOT GREATER THAN
                TCF             EDOTMAX                 # 11.25 DEG/SEC IN MAGNITUDE, SO LIMIT IT.
                
                CCS             L                       # INSURE NON-ZERO EDOT:
                AD              TWO                     # C(L) PNZ REMAINS UNCHANGED.
                TCF             +2                      # C(L) NNZ REMAINS UNCHANGED.
                COM                                     # C(L)  +0 BECOMES 77776.
                AD              NEG1                    # C(L)  -0 BECOMES 77776.
EDOTSTOR        TS              EDOT                    # SAVE NON-ZERO EDOT SCALED AT PI/16.

                EXTEND                                  # CALCULATE (EDOT)(EDOT):
                SQUARE
                TS              EDOT(2)                 # SCALED AT PI(2)/2(+8) RAD(2)/SEC(2).
                
                EXTEND                                  #  0.5               +8       2
                INDEX           AXISCNTR                # ------  SCALED AT 2  /PI SEC /RAD.
                MP              1/ACCQ                  # ACCQ,R
                EXTEND                                  # DEADBAND = 5.0 OR 1.0 OR 0.3 DEGREES
                SU              DB                      # SCALED AT PI RADIANS.
                TS              FPQR                    # 0.5(1/ACC)EDOT(2)-DB SCALED AT PI RADS.
                
                CAE             EDOT(2)                 # SCALED AT PI(2)/2(8) RAD(2)/SEC(2).
                EXTEND
                INDEX           AXISCNTR
                MP              1/AMINQ                 # .5(1/ACCMIN) AT 2(8)/PI SEC(2)/RAD.
                AD              DB                      # DEADBAND SCALED AT PI RADIANS.
                TS              FPQRMIN                 # .5(1/ACCMIN)EDOT(2)+DB SCALED AT PI RAD.
                
                CCS             EDOT                    # EDOT TEST ON SIGN (NON-ZERO):
                CAE             E                       # ATTITUDE ERROR FOR THIS AXIS
                TCF             +2                      # SCALED AT PI RADIANS.
                TCF             EDOTNEG
                ADS             FPQR                    # E+0.5(1/ACC)EDOT(2)-DB SCALED AT PI RAD.
                
FTEST           CCS             EDOT                    # EDOT GUARANTEED NOT +0 OR -0.
                CCS             FPQR                    # FPQR GUARANTEED NOT +0.
## Page 537
                TCF             QUICKURG                # EDOT.G.+0, FPQR.G.+0.
                CCS             FPQR                    # EDOT.L.-0.
                TCF             FMINCALC                # EDOT.L.-0,FPQR.G.+0/EDOT.G.+0,FPQR.L.-0.
                TCF             FMINCALC                # EDOT.G.+0,FPQR.E.-0 (FROM FIRST CCS).
                TCF             QUICKURG                # EDOT.L.-0,FPQR.L.-0.
                
QUICKURG        CAE             EDOT                    # EDOT.L.-0,FPQR.E.-0 (FROM 2ND CCS).
                EXTEND                                  # SCALE FROM PI/16 TO PI RADIANS/SECOND
                MP              BIT11                   # TO HAVE SAME SCALING AS FPQR AFTER THE
                AD              FPQR                    # IMPLICIT MULT. OF FPQR BY 1/SEC.
                TCF             URGMULT                 # THIS URGENCY = (1/ACC)(FPQR+EDOT).
                
EDOTMAX         CCS             A                       # GUARANTEED NOT +0 OR -0.
                CAF             POSMAX
                TCF             EDOTSTOR                # SET EDOT TO SIGNED MAXIMUM.
                CS              POSMAX
                TCF             EDOTSTOR                # SCALED AT PI/16 RADIANS/SECOND.
                
EDOTNEG         CS              FPQR                    # SCALED AT PI RADIANS
                AD              E                       # ATTITUDE ERROR FOR THIS AXIS
                TS              FPQR                    # E-0.5(1/ACC)EDOT(2)+DB SCALED AT PI RAD.
                TCF             FTEST
                
FMINCALC        CCS             FPQR                    # NECESSARY RETEST ON FPQR;
                CS              FPQRMIN
                TCF             +2                      # E-0.5(1/ACCMIN)EDOT(2)-DB
                CAE             FPQRMIN
                AD              E                       # E+0.5(1/ACCMIN)EDOT(2)+DB
                TS              FPQRMIN                 # SCALED AT PI RADIANS.
                
                CCS             EDOT                    # EDOT    GUARANTEED NOT +0 OR -0.
                CCS             FPQRMIN                 # FPQRMIN GUARANTEED NOT +0 (CALL IT F).
                TCF             ZEROURG                 # EDOT.G.+0, F.G.+0.
                CCS             FPQRMIN                 # EDOT.L.-0.
                TCF             NORMURG                 # EDOT.L.-0, F.G.+0 / EDOT.G.+0, F.L.-0.
                TCF             NORMURG                 # EDOT.G.+0, F.E.-0 (FROM FIRST CCS).
                TCF             ZEROURG                 # EDOT.L.-0, F.L.-0.
ZEROURG         EXTEND                                  # EDOT.L.-0, F.E.-0 (FROM 2ND CCS).
                DCA             DPZEROY                 # THIS URGENCY IS ZERO.
                DXCH            URGENCYQ
                TCF             MOREURG                 # TEST FOR NEXT AXIS
                
NORMURG         CAE             FPQRMIN                 # THIS URGENCY IS FPQRMIN(1/ACC).
URGMULT         EXTEND
                INDEX           AXISCNTR
                MP              1/ACCQ
                DXCH            URGENCYQ                # SAVE D.P. SCALED AT 2(+9).
                
MOREURG         CCS             AXISCNTR                # TEST FOR END OF LOOP
                TCF             +2                      # CONTINUE.
                
## Page 538
                TCF             URGSCALQ                # FINISHED.
                
                TS              AXISCNTR                # Q-AXIS
                
                EXTEND
                DCA             URGENCYQ                # SET URGENCYR
                DXCH            URGENCYR
                
                DXCH            E                       # SET ER,EDOT(2)R
                DXCH            ER
                TS              EQ                      # SET EQ
                CAE             EDOT
                TS              EDOT(R)                 # SET EDOT(R).
                
                TCF             URGLOOP                 # CONTINUE.
                
# SUFFICIENT TEST FOR URGENCY RESCALING:

URGSCALR        CCS             URGENCYR                # IF ABVAL(URGENCYR) LESS THAN SCALE BOUND
                AD              SCALEBND
                TCF             +2                      # THEN BOTH URGENCIES CAN BE RESCALED FROM
                AD              SCALEBND
                EXTEND                                  # 2(+9) TO 2(+4) SECONDS.
                BZMF            URGSCALE
                TCF             URGLIMS
                
# RESCALE BOTH URGENCIES FROM 2(+9) TO 2(+4) SECONDS:

URGSCALE        CAE             URGENCYQ                # SHIFT D.P. URGENCYQ LEFT 5-PLACES TO
                EXTEND                                  # FORM S.P. URGENCYQ NOW SCALED AT 16 SECS
                MP              BIT6
                LXCH            URGENCYQ
                CAE             URGENCYQ        +1
                EXTEND
                MP              BIT6
                ADS             URGENCYQ
                
                CAE             URGENCYR                # SHIFT D.P. URGENCYR LEFT 5-PLACES TO
                EXTEND                                  # FORM S.P. URGENCYR NOW SCALED AT 16 SECS
                MP              BIT6
                LXCH            URGENCYR
                CAE             URGENCYR        +1
                EXTEND
                MP              BIT6
                ADS             URGENCYR
                
                CAE             URGLM2                  # SET URGENCY LIMIT FOR 2(+4) SCALING.
                TCF             URGFUDGE
                
SCALEBND        OCTAL           77400                   #  -8 SECONDS SCALED AT 2(+9).
## Page 539
DPZEROY         2DEC            0

# NECESSARY TEST FOR URGENCY RESCALING:

URGSCALQ        CCS             URGENCYQ                # IF ABVAL(URGENCYQ) LESS THAN SCALE BOUND
                AD              SCALEBND
                TCF             +2                      # THEN TEST URGENCYR FOR RESCALABLE
                AD              SCALEBND
                EXTEND                                  # MAGNITUDE.
                BZMF            URGSCALR
                
URGLIMS         CAE             URGLM1                  # SET URGENCY LIMIT FOR 2(+9) SCALING.
URGFUDGE        TS              URGLIMIT

# USE URGENCY FUNCTION CORRECTION FACTOR WHEN NECESSARY:

                CCS             AOSQ                    # IF C(AOSQ) ZERO OR IF C(URGENCYQ) ZERO,
                CS              URGENCYQ                # THEN IT IS CLEARLY UNNECESSARY TO FUDGE.
                TCF             +2                      # WHILE MAKING THIS TEST, WE CALCULATE
                CAE             URGENCYQ                # -SIGN(AOSQ)(URGENCYQ) WHICH IF POSITIVE
                EXTEND                                  # INDICATES THAT WE ARE TRYING TO FIGHT
                BZMF            URGFUDG1                # THE EFFECT OF AOSQ, SO WE DO NOT FUDGE.
                
                CAE             URGRATQ                 # HERE WE KNOW THAT AOSQ WILL ACTUALLY
                EXTEND                                  # HELP THE RCS JETS MANEUVER FOR THIS AXIS
                MP              URGENCYQ                # FOR THIS CSP, MULTIPLYING BY URGRATQ
                TS              URGENCYQ                # REDUCES URGENCYQ APPROPRIATELY ENOUGH.
                
URGFUDG1        CCS             AOSR                    # HERE WE DO THE SAME LOGIC FOR THE R-AXIS
                CS              URGENCYR                # COMPUTATIONS AS WE DID FOR THE Q-AXIS AT
                TCF             +2                      # URGFUDGE.  RATHER THAN REPEAT THE ABOVE
                CAE             URGENCYR                # COMMENTS, WE PROVIDE A BIT OF FURTHER
                EXTEND                                  # EXPLANATION; FIRST, ONLY A S.P. URGENCY
                BZMF            URGPLANE                # IS SAVED IF WE DO THE FUDGE, SINCE ONLY
                
                CAE             URGRATR                 # S.P. URGENCIES ARE REFERENCED BELOW AND
                EXTEND                                  # NO D.P. ACCURACY IS NEEDED.  SECOND, BY
                MP              URGENCYR                # BY MULTIPLYING BY THE FUDGE RATIO DURING
                TS              URGENCYR                # APS BURNS, WE PREVENT SOME RCS FIRINGS
                                                        # WHICH WOULD OVER-CORRECT DUE TO THE AOS.
                                                        
URGPLANE        CAE             URGENCYQ                # BEGIN URGENCY-PLANE COMPUTATIONS:
                EXTEND
                BZF             BURGZERO                # TEST FOR BOTH URGENCIES ZERO
                
                EXTEND
                MP              -TAN22.5
                AD              URGENCYR
                EXTEND
                MP              COS22.5
## Page 540
                TS              TERMA                   # UR.COS(22.5)-UQ.SIN(22.5)
                
                CS              URGENCYR
                EXTEND
                MP              -TAN22.5
                AD              URGENCYQ
                EXTEND
                MP              COS22.5
                TS              TERMB                   # UR.SIN(22.5)+UQ.COS(22.5)
                
A+B/A-B         AD              TERMA
                TS              A+B
A-B/ONLY        CS              TERMB
                AD              TERMA
                TS              A-B
                
# AXIS AND MODE SELECTION

                CAE             TERMB                   # B URGENCY TEST
                EXTEND
                BZMF            NEGBURG
                
POSBURG         CAE             TERMA                   # A URGENCY TEST
                EXTEND
                BZMF            NETAPOSB
                
POSAPOSB        CAE             A-B
                EXTEND
                BZMF            MINUSU                  # NEGATIVE U-AXIS SELECTED
                
2/4JET-R        CAE             1/AMINR
                TS              .5ACCMNE
                EXTEND
                DCA             ER
                DXCH            E
                CAE             EDOT(R)
                TS              EDOT
                CAE             URGLIMIT
                AD              URGENCYR
                EXTEND
                BZMF            2JETS-R
                
4JETS-R         CS              ONE
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
2JETS-R         CCS             NJ-R
                TCF             4JETS-R
                CS              TWO
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
## Page 541
MINUSU          CAE             1/AMINU
                TS              .5ACCMNE
                CAE             URGENCYQ
                AD              URGENCYR
                AD              URGLIMIT
                EXTEND
                BZMF            2JETS-U
                
2JETSM-U        TC              UXFORM
2-U.RATE        CAF             THREE
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
2JETS-U         CCS             NJ-U
                TCF             2JETSM-U
                TC              UXFORM
                CAF             TWO
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
NETAPOSB        CAE             A+B
                EXTEND
                BZMF            PLUSV
                
2/4JET-Q        CAE             1/AMINQ
                TS              .5ACCMNE
                CAE             URGLIMIT
                AD              URGENCYQ
                EXTEND
                BZMF            2JETS-Q
                
4JETS-Q         CS              FIVE
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
2JETS-Q         CCS             NJ-Q
                TCF             4JETS-Q
                CS              SIX
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
PLUSV           CAE             1/AMINV
                TS              .5ACCMNE
                CS              URGENCYR
                AD              URGENCYQ
                AD              URGLIMIT
                EXTEND
                BZMF            2JETS+V
                
2JETSM+V        TC              VXFORM
2+V.RATE        CAF             FIVE
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
2JETS+V         CCS             NJ+V
## Page 542
                TCF             2JETSM+V
                TC              VXFORM
                CAF             FOUR
                TCF             POLTYPE                 # GO FIND BEST POLICY
                
BURGZERO        CAE             URGENCYR                # TEST FOR SECOND URGENCY ALSO ZERO
                EXTEND
                BZF             GIMBLTRY                # BOTH URGENCIES ZERO.  TRY THE GTS.

                EXTEND                                  # TIME SAVING A+B CALCULATION
                MP              SIN22.5
                TS              TERMB                   # US.SIN(22.5)
                CAE             URGENCYR
                EXTEND
                MP              COS22.5
                TS              TERMA                   # UR.COS(22.5)
                TCF             A-B/ONLY
                
COS22.5         DEC             0.92388                 # COSINE OF 22.5 DEGREES
SIN22.5         DEC             0.38268                 # SINE OF 22.5 DEGREES
-TAN22.5        DEC             -.41421                 # NEGATIVE OF TANGENT OF 22.5 DEGREES

NEGBURG         CAE             TERMA                   # A URGENCY TEST
                EXTEND
                BZMF            NEGANEGB

POSANEGB        CAE             A+B
                EXTEND
                BZMF            2/4JET+Q

MINUSV          CAE             1/AMINV
                TS              .5ACCMNE
                CS              URGENCYQ 
                AD              URGENCYR
                AD              URGLIMIT
                EXTEND
                BZMF            2JETS-V

2JETSM-V        TC              VXFORM
2-V.RATE        CAF             SEVEN
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS-V         CCS             NJ-V    
                TCF             2JETSM-V
                TC              VXFORM
                CAF             SIX
                TCF             POLTYPE                 # GO FIND BEST POLICY

NEGANEGB        CAE             A-B
                EXTEND
## Page 543
                BZMF            2/4JET+R

PLUSU           CAE             1/AMINU
                TS              .5ACCMNE
                CS              URGLIMIT
                AD              URGENCYQ
                AD              URGENCYR
                EXTEND
                BZMF            2JETSM+U

2JETS+U         CCS             NJ+U
                TCF             2JETSM+U
                TC              UXFORM
                CAF             ZERO
                TCF             POLTYPE                 # GO TO FIND BEST POLICY

2JETSM+U        TC              UXFORM
2+U.RATE        CAF             ONE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2/4JET+R        CAE             1/AMINR
                TS              .5ACCMNE
                EXTEND
                DCA             ER
                DXCH            E
                CAE             EDOT(R)
                TS              EDOT
                CS              URGENCYR
                AD              URGLIMIT
                EXTEND
                BZMF            2JETS+R

4JETS+R         CS              THREE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS+R         CCS             NJ+R
                TCF             4JETS+R
                CS              FOUR
                TCF             POLTYPE                 # GO FIND BEST POLICY

2/4JET+Q        CAE             1/AMINQ
                TS              .5ACCMNE
                CS              URGENCYQ
                AD              URGLIMIT
                EXTEND
                BZMF            2JETS+Q 

4JETS+Q         CS              SEVEN
                TCF             POLTYPE                 # GO FIND BEST POLICY

## Page 544
2JETS+Q         CCS             NJ+Q
                TCF             4JETS+Q
                CS              EIGHT

# GENERALIZED CALLING SEQUENCE FOR ALL Q,R-AXES ROTATIONS (FROM BANK 17):

POLTYPE         TS              NETACNDX                # SAVE INDEX INDICATING AXIS, DIRECTION,
                EXTEND                                  # AND NUMBER OF JETS REQUESTED (THIS SPEC-
                DCA             POLADR                  # IFIES THE "OPTIMAL" POLICY.  TRANSFER
                DTCB                                    # ACROSS BANKS TO POLICY SELECTION ROUTINE
                
                EBANK=          JTSONNOW
POLADR          2CADR           POLTYPEP                # 2CADR OF JET POLICY SELECT ROUINTE.


## Page 545
# SUBROUTINES UXFORM AND VXFORM CALCULATE NEEDED VALUES FOR T-JET LAW
# (THEY GO OFF TO REDUCE RATE, IF NECESSARY, AND THEN DO NOT RETURN)

VXFORM          CAE             1/2JETSV                # GET INVERSE OF V-JET ACCELERATION
                TS              1/NJETAC
                CS              EQ                      # COMPLEMENT FOR TRANSFORMATION
                TS              EQ
                CS              EDOTQ
                TCF             UVXFORM         +1
UXFORM          CAE             1/2JETSU                # SET INVERSE OF U-JET ACCELERATION
                TS              1/NJETAC

UVXFORM         CAE             EDOTQ                   # TRANSFORM ANGULAR RATE TO U/V-AXIS
                AD              EDOTR
                EXTEND
                MP              .707
                TS              EDOT                    # SAVE FOR REDUCEUV
                EXTEND
                MP              BIT3
                EXTEND
                BZF             UVEDOT                  # BRANCH IF RESCALING SUCCESSFUL.
                
                CCS             A                       # LIMIT EDOT TO +/- 11.25 DEG/SEC.
                CAF             POSMAX
                TCF             UVEDOT1
                CS              POSMAX
                TCF             UVEDOT1
                
UVEDOT          CAE             L
UVEDOT1         TS              EDOT                    # RATE ERROR SCALED AT PI/16.
                EXTEND
                SQUARE
                TS              EDOT(2)                 # SAVE RATE SQUARED SCALED AT PI(2)/2(8)
                
                CAE             EQ                      # TRANSFORM ATTITUDE ERROR TO U/V -AXIS
                AD              ER
                EXTEND
                MP              .707
                TS              E 

                TC              Q

-1.5CSPQ        DEC             -.00938
+TJMINT6        DEC             +.00073
-TJMIN16        DEC             -.00097
-TJMINQR        EQUALS          -TJMIN16
38.7MAT4        DEC             0.00242
-MS35AT4        DEC             -.00219                 # -35MS SCALED AT 4
## Page 546
MAXRATE         DEC             0.88889                 # 10 DEGREES/SECOND SCALED AT PI/16
MAXRATE2        DEC             0.79012                 # 100 DEG(2)/SEC(2) SCALED AT PI(2)/2(8)
.6DEG/SC        DEC             0.05333                 # 6/10 DEGREES/SECOND SCALED AT PI/16
25/32QR         DEC             0.78125


## Page 547
# THESE TWO SUBROUTINES TRANSFORM EDOTQ,EDOTR INTO THE U/V-AXIS (RESPECTIVELY) FOR THE RATE COMMAND MODE (ONLY).
# VALUE IS STORED IN EDOTGEN SCALED AT PI/4 RADIANS/SECOND.

                BANK            17

EDOTUGEN        CAE             1/2JETSU                # FOR U-AXIS TRANSFORMATION
                TS              1/NJETAC
                CAE             EDOTQ
                TCF             +4
EDOTVGEN        CAE             1/2JETSV                # FOR V-AXIS TRANSFORMATION
                TS              1/NJETAC
                CS              EDOTQ
                AD              EDOTR
                EXTEND
                MP              .707
                TS              RATEDIF
                TC              Q


.707            DEC             0.70711      

SPSBAKUP        EXTEND
                DCA             SPSRCSAD
                DXCH            Z
                EBANK=          DT
SPSRCSAD        2CADR           SPSRCS


## Page 548
# *********TJETLAW************************************************************************************************

TJETLAW         CS              EDOT                    # TEST ON EDOT SIGN:
                EXTEND
                BZMF            +4
                TS              EDOT                    # SIGNS OF E AND EDOT CHANGED IF EDOT NEG,
                CS              E                       # TO CONSIDER FUNCTIONS IN THE UPPER HALF
                TS              E                       # OF THE E-DOT PHASE PLANE.

                CAE             EDOT(2)                 # SCALED AT PI(2)/2(+8) RAD(2)/SEC(2)
                EXTEND                                  # 1/NETACC HAS BEEN SET FOR N-JETS WITH
                MP              1/NETACC                # IMPLICIT FACTOR OF (1/2).
                AD              E                       # ATTITUDE ERROR SCALED AT PI RADIANS.
                EXTEND                                  # DEADBAND VALUE SCALED AT PI RADIANS.
                SU              DB                      # E+.5EDOT/NETACC-DB
                TS              HDAP                    # SCALED AT PI RADIANS.

                EXTEND
                BZMF            NEGHDAP

                CAE             EDOT                    # RATE ERROR; LIMITED TO +/- 11.25 DEG/SEC
                EXTEND                                  # SCALED AT PI/16 RADIANS/SECOND.
                MP              1/NETACC                # SCALED AT 2(+8)/PI SEC(2)/RAD: (ACC) (-1)
                DDOUBL                                  # SCALED AT 2(+4) SECONDS.
                TS              TERMA 
                
                AD              -1.5CSPQ                # (EDOT/NETACC)-1.5CSP SCALED AT 16 SECS.
                EXTEND
                BZMF            +3

MAXTJET         CAF             BIT14                   # (1/2) IS LIKE POSMAX AT THIS SCALING.
                TCF             NORMRETN                # (OVERFLOW IS PREVENTED IN THIS WAY.)

                CS              HDAP                    # MINIMPDB-E-(EDOT(2)/NETACC)+DB
                AD              MINIMPDB                # SCALED AT PI RADIANS.
                EXTEND                                  # (DURING APS BURNS, MINIMPDB = -DB.)
                BZMF            MAINBRCH

                CAE             TERMA                   # EDOT/NETACC-35MS SCALED AT 16 SECONDS.
                AD              -MS35AT4
                EXTEND                                  # COMPARE TIME-TO-GET-ZERO-RATE WITH 35MS.
                BZMF            INZONE4

                AD              38.7MAT4                # TIME-TO-GET-ZERO-RATE + 1/2 MINIMP.
                TCF             TJETSCAL

INZONE4         CCS             EDOT                    # IF EDOT IS EITHER 00001, 00000, 77777,
                EXTEND                                  # OR 77776 (IN OCTAL), THEN THIS CODING
                BZF             XTRANS                  # CAUSES A BRANCH TO XTRANS, NO ROTATION
                EXTEND                                  # JETS ARE FIRED. *** NOTE: IF THE EXTEND
## Page 549
                BZF             XTRANS                  # CODE IS SKIPPED, BZF EXECUTES LIKE TCF.
                
                
                CAE             NO.QJETS                # IF NO Q-AXIS JETS THEN MUST HAVE R-AXIS.
                EXTEND
                BZF             ROTRAXIS
                
                CAE             OMEGAQD                 # WITH Q-AXIS JETS, ZERO THE RATE ERROR.
                TS              OMEGAQ
                
                CAE             NO.RJETS                # IF NO R-AXIS JETS, THEN Q-AXIS JETS WERE
                EXTEND                                  # ALREADY FOUND.
                BZF             DOTJMIN
                
ROTRAXIS        CAE             OMEGARD                 # WITH R-AXIS JETS, ZERO THE RATE ERROR.
                TS              OMEGAR

DOTJMIN         CAF             +TJMINT6                # USE MINIMUM IMPULSE DT FOR TQR.
                TCF             NORMRETN
                
NEGHDAP         CAE             EDOT(2)                 # RATE ERROR SQUARED SCALED AT PI(2)/2(8).
                EXTEND
                MP              .5ACCMNE                # .5(1/ACCMIN) AT 2(8)/PI SEC(2)/RAD.
                AD              E                       # ATTITUDE ERROR SCALED AT PI RADIANS
                AD              DB                      # DEADBANDS (2) SCALED AT PI RADIANS
                AD              DBMINIMP                # (DURING APS BURNS DBMINIMP = 0.)
                EXTEND
                BZMF            +2
                TCF             XTRANS                  # NO ROTATION JETS NEEDED.

 +2             CS              MAXRATE                 # 10 DEGREES/SECOND SCALED AT PI/16.
                AD              EDOT                    # EDOT-MAXRATE SCALED AT PI/16 RAD/SEC.
                EXTEND
                BZMF            +2
                TCF             XTRANS

 +2             CS              EDOT                    # RATE ERROR SCALED AT PI/16 RAD/SEC.
                EXTEND                                  # (LIMITED TO +/- 11.25 DEG/SEC.)
                MP              1/NETACC                # SCALED AT 2(+8)/PI SEC(2)/RAD; (ACC):-1)
                DDOUBL                                  # SCALED AT 2(+4) SECONDS.
                TS              TERMA 

                CS              HDAP                    # -E+(.5EDOT(2)/NETACC)+DB
                AD              E
                AD              E                       # TWICE ERROR NEGATES E OF HDAP(ABOVE)
                AD              MINIMPDB
MAINBRCH        TS              HDAP                    # -HDAP(ABOVE)+2E+DBMINIMP AT PI RADIANS.

                CAE             1/NETACC                # .5(1/NETACC+1/ACCMIN) SCALED AT 2(8)/PI.
## Page 550
                ADS             .5ACCMNE                # .5ACCMNE NOW HOLDS DENOM.

                EXTEND                                  # DENOM(MAXRATE(2)).HDAP AT PI RADIANS.
                MP              MAXRATE2       
                AD              HDAP        
                EXTEND
                BZMF            NOROOT
                
                CAE             1/NETACC                # SAVE (1/NETACC)(2)
                DOUBLE
                EXTEND
                SQUARE
                DXCH            INVACCSQ
                
                CAE             HDAP                    # (HDAP)/(DENOM)
                ZL
                EXTEND
                DV              .5ACCMNE
                TS              QUOTTEMP
                
                EXTEND                                  # +(HDAP/DENOM)(1/NETACC)(2) AT 2(8) SECS.
                MP              INVACCSQ        +1
                TS              INVACCSQ        +1
                CAF             ZERO
                XCH             INVACCSQ
                EXTEND
                MP              QUOTTEMP
                DAS             INVACCSQ
                
                EXTEND                                  # SAVE COPY OF ABOVE D.P. VALUE
                DCA             INVACCSQ
                DXCH            TERMB
                
                CAF             -1.5CSPQ                # (1.5CSP-EDOT/NETACC) AT 16 SECS.
                AD              TERMA
                EXTEND
                SQUARE                                  # (1.5CSP-EDOT/NETACC)(2) AT 256 SECS.
                DAS             INVACCSQ                # (1.5CSP-EDOT/NETACC)(2) - TERMB
                
                CAE             INVACCSQ                # CHECK HIGH ORDER PART, IF NON-ZERO.
                EXTEND
                BZF             ONLYTST1
                TCF             ONLYTST1        +1
                
ONLYTST1        CAE             INVACCSQ        +1      # USE LOW ORDER PART, SINCE HIGH PART 0.
                EXTEND
                BZMF            MAXTJET
                
                CAF             -TJMIN16                # -EDOT/NETACC-TJMIN SCALED AT 16.
                AD              TERMA 
## Page 551
                EXTEND
                BZMF            MAYNOJET

PREROOT         CAF             AFTRUTAD                # THIS WILL CAUSE SQUARE ROOT TO BE TAKEN
                TS              T5ADR                   # ON THE NEXT T5RUPT.
                EXTEND  
                READ            5
                TS              CH5TEMP
JETSON          CAE             JTSONNOW                # TURN ON JETS AND END RUPT
                TC              WRITEQR
                TCF             RESUME
                
AFTRUTAD        GENADR          DORUTDUM
NOROOT          CAF             MAXRATE
                AD              .6DEG/SC                # MAXRATE+DEL SCALED AT PI/16 RAD/SEC.
                EXTEND
                MP              1/NETACC                # (MAXRATE+DEL)/NETACC
                DDOUBL                                  # SCALED AT 2(+4) SECONDS
TJSUM           AD              TERMA   
TJETSCAL        DOUBLE                                  # NOW SCALED AT 2(+3) SECONDS.
                EXTEND
                MP              25/32QR                 # SCALED TO 16/25 2(+4) SECONDS AS TIME6.
                TCF             NORMRETN
                
MAYNOJET        EXTEND                                  # RE-INITIALIZE C(INVACCSQ,D.P.)
                DCA             TERMB                   # SINCE CLOBBERED ABOVE.
                DXCH            INVACCSQ
                
                CAF             -TJMIN16
                AD              TERMA                   # TERMA-TJMIN SCALED AT 2(+4) SECONDS.
                EXTEND
                SQUARE                                  # SCALED AT 2(+8) SECONDS.
                DAS             INVACCSQ                # FORM D.P. SUM.
                
                CAE             INVACCSQ                # CHECK HIGH ORDER PART IF NON-ZERO.
                EXTEND
                BZF             ONLYTST2
                TCF             ONLYTST2        +1
                
ONLYTST2        CAE             INVACCSQ        +1      # USE LOW ORDER PART, SINCE HIGH PART 0.
                EXTEND
                BZMF            PREROOT
                TCF             DOTJMIN                 # FIRE FOR MINIMUM IMPULSE.
CHKSUM17        OCT             37777


## Page 552
# SUBROUTINE NAME: DAPSQRT        MOD. NO. 0  DATE: DECEMBER 28, 1966

# AUTHOR: JONATHAN D. ADDELSTON (ADAMS ASSOCIATES)

# DAPSQRT IS A SUBROUTINE WHICH PERFORMS THE NECESSARY AND APPROPRIATE INTERFACE FUNCTIONS BETWEEN THE LM DAP AND
# THE PRESENT SPROOT SUBROUTINE IN MASTER.  DAPSQRT EXPECTS A DOUBLE PRECISION ARGUMENT IN C(A,L) AND WILL SHIFT
# THAT QUANTITY SIX OR FOUR BITS TO THE LEFT TO FORM A MORE ACCURATE SINGLE PRECISION ARGUMENT FOR SPROOT (AND
# THEN SHIFT THE SINGLE PRECISION RESULT OF SPROOT THREE OR TWO BITS TO THE RIGHT IN ORDER TO MAINTAIN SCALING
# CONSISTENCY).  DAPSQRT ALSO PERFORMS THE HERETOFORE NEGLECTED FUNCTION OF SAVING AND RESTORING THE CONTENTS OF
# THE SR (SHIFT-RIGHT) REGISTER WHICH MUST BE DONE BY ALL USERS OF SPROOT IN INTERRUPT.

# NOTE: IF ORIGINAL C(A) = 0, THEN THE SQUARE ROOT SINGLE PRECISION ARGUMENT IS C(L), AND THE RESULT FROM SPROOT
# IS SHIFTED LEFT SEVEN BITS.

# CALLING SEQUENCE:

#                                         L        TC     IBNKCALL        CALL IS ALWAYS FROM ANOTHER BANK.
#                                         L +1     CADR   DAPSQRT         ENTER ROUTINE WITH C(A,L) = D.P. ARG.
#                                         L +2     (RETURN)               C(A) = BEST VALUE OF SQUARE ROOT.

# ALARM/ABORT MODE: NONE.

# SUBROUTINES CALLED: SPROOT AND T6JOBCHK.

# NORMAL EXIT MODE: RETURN TO L +2.

# OUTPUT: C(A) AT RETURN TO CALLER IS THE BEST SINGLE PRECISION SQUARE ROOT OF THE GIVEN DOUBLE PRECISION ARGUMENT

# ERASABLE INITIALIZATION REQUIRED: DOUBLE PRECISION ARGUMENT AS C(A,L).

# DEBRIS: ITEMP4, ITEMP5, ITEMP6 AND A,L,Q.


                BANK            26
                EBANK=          FUNCTION
                
# SRTEMP        ERASE                                   SCRATCH CELLS FOR DAPSQRT
# SQRTTEMP      ERASE                                   SCRATCH CELLS FOR DAPSQRT
# SQRTTEMQ      ERASE                                   SCRATCH CELLS FOR DAPSQRT

DAPSQRT         TS              SQRTTEMP                # SAVE C(A) PART OF DOUBLE PRECISION ARG.

                EXTEND                                  # SAVE C(Q) FOR RETURN TO LM DAP CALLER.
                QXCH            SQRTTEMQ
                
                CAE             SR                      # SAVE C(SR) SINCE ALL INTERRUPT PROGRAMS
                DOUBLE                                  # USING SPROOT MUST DO SO.
                TS              SRTEMP
## Page 553
                TC              T6JOBCHK                # CHECK TIME6-RUPT BEFORE SPROOT.
                
                CAE             SQRTTEMP                # RESTORE D.P. ARG. TO C(A,L), AND THEN
                EXTEND                                  # CHECK FOR C(A) = +0.  IF SO, TAKE THE
                BZF             DAPSQRT3                # SQUARE ROOT OF C(L) AND POST-SHIFT.
                
                MASK            DAPHIGH7                # IF THIS MASK PRODUCES A WORD OF ZEROS,
                EXTEND                                  # C(D.P.ARG) WILL BE SHIFTED LEFT 6 BITS
                BZF             SQRTSL6                 # WITHOUT OVERFLOWING BEFORE USING SPROOT.
                
                MASK            DAPHIGH5                # IF THIS MASK PRODUCES A WORD OF ZEROS,
                EXTEND                                  # C(D.P.ARG) WILL BE SHIFTED LEFT 4 BITS
                BZF             SQRTSL4                 # WITHOUT OVERFLOWING BEFORE USING SPROOT.
                
                CAE             SQRTTEMP                # GET UNSHIFTED S.P. ARGUMENT FOR SPROOT.
                
                TC              SPROOT                  # CALL SUBROUTINE IN FIXED-FIXED.
                
DAPSQRT1        LXCH            SRTEMP                  # RESTORE C(SR).
                LXCH            SR
                
                TC              SQRTTEMQ                # RETURN WITH SQUARE ROOT AS C(A).
                
SQRTSL6         CAF             BIT9                    # SET UP TO SHIFT D.P. ARG. LEFT 6 BITS
                TS              Q
                CAF             BIT12                   # AND TO SHIFT SPROOT ANS. RIGHT 3 BITS.
                TCF             DAPSQRT2
                
SQRTSL4         CAF             BIT11                   # SET UP TO SHIFT D.P. ARG. LEFT 4 BITS
                TS              Q
                CAF             BIT13                   # AND TO SHIFT SPROOT ANS. RIGHT 2 BITS.
DAPSQRT2        XCH             SQRTTEMP                # (RECONSTRUCT D.P. ARGUMENT.)

                EXTEND                                  # VARIABLE LEFT SHIFT (4 OR 6 BITS).
                DV              Q                       # (MAC HAS DIFFEQ, LM DAP HAS DV Q - PUN?)
DAPROOT         TC              SPROOT                  # CALL SUBROUTINE IN FIXED-FIXED
                EXTEND                                  # VARIABLE RIGHT SHIFT (2 OR 3 BITS).
                MP              SQRTTEMP
                
                TCF             DAPSQRT1                # RETURN SEQUENCE.
                
DAPSQRT3        CAF             BIT8                    # SET UP TO SHIFT SPROOT ANS. RIGHT 7 BITS
                TS              SQRTTEMP
                CAE             L                       # USE C(L) AS SPROOT ARGUMENT.
                TCF             DAPROOT
                
DAPHIGH7        OCTAL           77400
DAPHIGH5        OCTAL           76000

