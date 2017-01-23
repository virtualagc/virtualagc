### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     Q,R-AXES_REACTION_CONTROL_SYSTEM_AUTOPILOT.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Hartmuth Gutsche <hgutsche@xplornet.com>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        562-593
## Mod history:  2016-09-20 JL   Created.
##               2016-09-30 HG   Started transcribing from scan
##               2016-10-08 HG   Change TS  Q -> TC  Q (p. 584)
##               2016-10-15 HG   fix label  MAXJET -> MAXTJET
##                                          ORGTOA -> URGTOA
##                                          TQRGTTM1 -> TQRGTTMI 
##                                          NEGQERROR -> NEGQEROR 
##                               fix operand NEGSCP -> NEGCSP 
##                                           UREGNCYQ -> URGENCYQ  
##                                           .5ACCMNS -> .5ACCMNE 
##                                           25,32.QR -> 25/32.QR
##                                           Q-NORTJS -> Q-NORJTS
##                                           -RATDEB -> -RATEDB
##                                           CHECKSTIK -> CHEKSTIK
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 and fixed the errors found.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent
## reduction in image quality) are available online at
##       https://www.ibiblio.org/apollo.
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 562
                BANK            24
                EBANK=          DT
# THE FOLLOWING T5RUPT ENTRY BEGINS THE PROGRAM WHICH CONTROLS THE Q,R-AXIS ACTION OF THE LEM USING THE RCS JETS.
# THE NOMINAL TIME BETWEEN THE Q,R-AXIS RUPTS IS 100 MS (UNLESS THE TRIM GIMBAL CONTROL SYSTEM IS USED, IN WHICH
# CASE THIS PROGRAM IS IDLE).

NULLFILT        2CADR           FILDUMMY

QRAXIS          CAF             MS30QR                  # RESET TIME IMMEDIATELY: DT = 30 MS
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

## Page 563

# SECOND, TRANSFORM CPU INCREMENTS TO BODY-ANGLE INCREMENTS:
                CAE             M31                     # MATRIX*VECTOR(WITH X COMPONENT ZERO)
                EXTEND
                MP              ITEMP1                  # M31 * ITEMP1 = M31 * DELTA CDUY
                TS              ITEMP3
                CAE             M32                     # M32 * ITEMP2 = M32 * DELTA CDUZ
                EXTEND
                MP              ITEMP2                  # DELTAR = M31*(DEL CDUY) + M32*(DEL CDUZ)
                ADS             ITEMP3                  # R-BODY-ANGLE INCREMENT SCALED AT PI/2(6)

                CAE             M21                     # MATRIX*VECTOR(WITH X COMPONENT ZERO)
                EXTEND                                  # CLOBBERS ITEMP2=DEL CDUZ, FOR EFFICIENCY
                MP              ITEMP1                  # M21 * ITEMP1 = M21 * DELTA CDUY
                XCH             ITEMP2                  # M22 * ITEMP2 = M22 * DELTA CDUZ
                EXTEND
                MP              M22                     # DELTAQ = M21*(DEL CDUY) + M22*(DEL CDUZ)
                ADS             ITEMP2                  # Q-BODY-ANGLE INCREMENT SCALED AT PI/2(6)

# FINALLY, DERIVE Q AND R BODY ANGULAR RATES:

                EXTEND                                  # WFORQR IS K/(NOMINAL DT) SCALED AT 16
                MP              WFORQR                  # FORM WEIGHTED VALUE OF MEASURED DATA
                XCH             OMEGAQ                  # SAVE AND BEGIN TO WEIGHT VALUE OF OLD W
                EXTEND                                  # (1-K) IS SCALED AT 1 FOR EFFICIENT CALC
                MP              (1-K)QR                 # (K CHANGES EVERY 2 SECS IN ASCENT)
                AD              JETRATEQ                # WEIGHTED TERM DUE TO JET ACCELERATION
                AD              AOSQTERM                # TERM DUE TO ASCENT OFFSET ACCELERATION
                ADS             OMEGAQ                  # TOTAL RATE ESTIMATE SCALED AT PI/4

                CAE             ITEMP3                  # GET DELTAR
                EXTEND                                  # WFORQR IS K/(NOMINAL DT) SCALED AT 16
                MP              WFORQR                  # FORM WEIGHTED VALUE OF MEASURED DATA
                XCH             OMEGAR                  # SAVE AND BEGIN TO WEIGHT VALUE OF OLD W
                EXTEND                                  # (1-K) IS SCALED AT 1 FOR EFFICIENT CALC
                MP              (1-K)QR                 # (K CHANGES EVERY 2 SECS IN ASCENT)
                AD              JETRATER                # WEIGHTED TERM DUE TO JET ACCELERATION
                AD              AOSRTERM                # TERM DUE TO ASCENT OFFSET ACCELERATION
                ADS             OMEGAR                  # TOTAL RATE ESTIMATE SCALED AT PI/4

                TC              QJUMPADR
SKIPQRAX        CA              NORMQADR
                TS              QJUMPADR
                CA              ZERO
                TS              JETRATEQ
                TS              JETRATER
                CA              TQR
                AD              NEGCSP2
                CCS             A
                TC              QRTORQUE

## Page 564
                TCF             RESUME
                TC              QRTORQUE
                CS              JETRATEQ
                ADS             OMEGAQ
                CS              JETRATER
                ADS             OMEGAR
                TCF             RESUME
QRTORQUE        AD              ONE
                EXTEND
                MP              BIT5
                CA              L
                EXTEND
                MP              16/25QR
                TS              TQR
                EXTEND
                MP              NO.QJETS
                CAE             L
                EXTEND
                MP              1JACCQ
                TS              JETRATEQ
                ADS             SUMRATEQ
                CAE             TQR
                EXTEND
                MP              NO.RJETS
                CAE             L
                EXTEND
                MP              1JACCR
                TS              JETRATER
                ADS             SUMRATER
                CAE             WFORQR
                EXTEND
                MP              TQR
                AD             (1-K)/8
                EXTEND
                MP              BIT4
                LXCH            ITEMP1
                CAE             JETRATEQ
                EXTEND
                MP              ITEMP1
                TS              JETRATEQ
                CAE             JETRATER
                EXTEND
                MP              ITEMP1
                TS              JETRATER
                CA              ZERO
                TS              NO.QJETS
                TS              NO.RJETS
                TC              Q
NORMQADR        GENADR          NORMALQ
NORMALQ         CAF             BIT13                   # CHECKING ATTITUDE HOLD BIT

## Page 565
                EXTEND
                RAND            31                      # BITS INVERTED
                EXTEND
                BZF             CHKBIT10
                CAF             BIT14                   # ATT HOLD BIT NOT PRESENT. CHECK FOR AUTO
                EXTEND
                RAND            31
                EXTEND
                BZF             ATTSTEER                # AUTOMATIC STEERING, CHECK FOR RATE HOLD
                EXTEND                                  # IF MODE SELECT SW OFF DO DAPIDLER NEXT
                DCA             IDLEADRQ
                DXCH            T5ADR
                TCF             RESUME

IDLEADRQ        2CADR           DAPIDLER

CHKBIT10        CAF             BIT10                   # BIT10=1 FOR MIN IMP USE OF RHC
                MASK            DAPBOOLS
                EXTEND
                BZF             CHEKSTIK                # IN ATT-HOLD/RATE-COMMAND IF BIT10=0

                CAE             DELAYCTR                # SET TO 2 BY RUPT 10
                EXTEND
                BZF             XTRANS

                CA              MINTADR
                TS              TJETADR

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

## Page 566
                BZF             2JETS-R

                TCF             XTRANS

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
                CS              16/32400                # 1DEG/SEC SCALED AT PI.PI/16
                AD              ITEMP1
                EXTEND
                BZMF            RATESMAL

#          THE RATE IS NOT SMALL ENOUGH YET.

                CA              OMEGAQ
                TS              QRATEDIF
                CA              OMEGAR

## Page 567
                TS              RRATEDIF
                TCF             OBEYQRRC

RATESMAL        CS              BIT1
                MASK            DAPBOOLS                # RATE COMMAND BIT SET TO ZERO
                TS              DAPBOOLS

                CAE             CDUX
                TS              CDUXD
                CAE             CDUY
                TS              CDUYD
                CAE             CDUZ
                TS              CDUZD

RHCACTIV        CAF             BIT1
                MASK            DAPBOOLS
                EXTEND
                BZF             XTRANS                  # LET P AXIS SET THE RATE COMMAND BIT
# COMPUTE RATE ERRORS
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

# ZERO,ENABLE,AND START COUNTERS
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

## Page 568
                TCF             POSQEROR
                TCF             NOQJETS
                TCF             NEGQEROR

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

## Page 569
                TS              RATEDIF
                AD              -2JETLIM
                EXTEND
                BZMF            2JETS-Q
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

## Page 570
                TCF              TORQUEV



# TRANSLATION WITHOUT ROTATION IS ACCOMPLISHED IN XTRANS SECTION

XTRANS          CA              ZERO
                TS              ADDTLT6
                TS              ADDT6JTS
                CA              BIT6
                MASK            DAPBOOLS                # CHECKING THE ULLAGE BIT

                EXTEND
                BZF             +4
                CA              ALL+XJTS                # ULLAGE JETS
WRITEON         TC              WRITEQR
                TCF             RESUME
 +4             CAF             BIT7
                EXTEND
                RAND            31
                EXTEND
                BZF             +XTRANS

                CA              BIT8                    # -X TRANS BIT.INVERTED
                EXTEND
                RAND            31
                EXTEND
                BZF             -XTRANS
NOTORQUE        CA              ZERO
                TCF             WRITEON
+XTRANS         CAF             2,10-OUT                # CHECK FOR FAILURE OF 2 OR 10
                EXTEND
                RXOR            32
                EXTEND
                BZF             +3                      # 2 AND 10 GOOD
                CA              +X,B                    # SINCE 2 OR 10 FAILED, USE 6 AND 14 OF B
                TCF             WRITEON
 +3             CA              +X,A                    # 2 AND 10 SYSTEM A
                TCF             WRITEON
-XTRANS         CAF             1,9-OUT                 # CHECK FOR FAILURE OF 1 OR 9
                EXTEND
                RXOR            32
                EXTEND
                BZF             +3                      # 1 AND 9 GOOD
                CA              -X,A                    # SINCE 1 OR 9 FAILED, USE 5 AND 13 OF A
                TCF             WRITEON
 +3             CA              -X,B                    # 1 AND 9 SYSTEM B
                TCF             WRITEON

## Page 571
# DO NECESSARY PARTS OF Q,R-AXES TORQUE VECTOR RECONSTRUCTION HERE AND NOW.  FOR OTHER PARTS WAIT UNTIL THE NEXT
# P-AXIS RCS DAP T5RUPT.

TORQUEV         CS              TQR                     # CALCULATED Q,R JET TIME (AS IN TIME6)
                AD              +T6TJMIN
                EXTEND                                  #   CORRECT BRANCH.
                BZMF            TQRGTTMI                # BRANCH FOR TQR = OR GREATER THAN MINIMP.
                CA              ZERO
                TS              TOFJTCHG                # SINCE TQR LESS THAN A MINIMUM IMPULSE,
                TS              JETRATEQ                #   ZERO ALL OF THESE REGISTERS AND GO TO
                TS              JETRATER                #   JET LIST.
                CA              JTSATCHG
                TC              WRITEQR
                TCF             RESUME
TQRGTTMI        CA              TQR
                TS              TOFJTCHG
                AD              -1.5CSP
                EXTEND
                BZMF            DOQRSKIP
                CA              1JACCQ
                EXTEND
                MP              NO.QJETS
                CA              L
                TS              ITEMP1
                EXTEND
                MP              QR.1STOQ
## Note: in the scan the two statements above (EXTEND, MP QR.1STOQ) are boxed in (red) and a marked with a question mark
##     I.E.   ----------------------------
##            | EXTEND                   |
##            | MP              QR.1STOQ |   ?
##            ----------------------------
                TS              JETRATEQ
                CA              ITEMP1
                EXTEND
                MP              0.1AT1
                ADS             SUMRATEQ
                CA              1JACCR
                EXTEND
                MP              NO.RJETS
                CA              L
                TS              ITEMP1
                EXTEND
                MP              QR.1STOQ
## Note: in the scan the two statements above (EXTEND, MP QR.1STOQ) are boxed in (red) and a marked with a question mark
##       See above.
                TS              JETRATER
                CA              ITEMP1
                EXTEND
                MP              0.1AT1
                ADS             SUMRATER
                CA              JTSONNOW
                TCF             WRITEON
SKIPQRAD        GENADR          SKIPQRAX
0.1AT1          DEC             +0.10000
DOQRSKIP        CA              SKIPQRAD
                TS              QJUMPADR
# CHANGE JET ON AND OFF BITS TO ACCOUNT FOR THE PRESENT STATE OF THE
## Page 572
# CHANNEL. THE CHANGES ACCOUNT FOR PURE ROTATION ONLY- NOT TRANSLATION.
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
                CA              14-TQRMN
                TS              ADDTLT6
                TCF             TOJTLST
NOQRON          CA              14-TQRMN
                ADS             TOFJTCHG
                CA              ZERO
                TS              ADDTLT6
                TCF             TOJTLST
JTSAREON        CA              MCOMPTQR
                ADS             TOFJTCHG
                CA              ZERO
                TS              ADDTLT6
TOJTLST         CA              JTSONNOW
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
MCOMPTQR        OCTAL           77765                   # -10 MS COMPUTATION TIME
14-TQRMN        DEC             11

## Page 573
MINTADR         GENADR          MINTJET
-.88975         DEC             -.88975
(1-K),QR        DEC             0.50000                 # K = 1/2
(1-KQ)/8        DEC             0.06250
-90MS           DEC             -.00879
+90MS           DEC             0.00879
NEGCSP2         DEC             -.00977
16/25QR         DEC             0.64000
ALL+XJTS        OCTAL           40252
2,10-OUT        OCTAL           00201
+X,A            OCTAL           40042
+X,B            OCTAL           40210
1,9-OUT         OCTAL           00104
-X,A            OCTAL           40104
-X,B            OCTAL           40021
JTLSTADR        2CADR           JTLST

RTJETADR        GENADR          RTJETIME

## Page 574
# Q,R-AXES ATTITUDE STEERING CALCULATIONS:

# (EXECUTED WHEN LGC IS IN AUTOMATIC SCSMODE OR IF SCSMODE IS ATTITUDE HOLD AND THE ROTATIONAL HAND CONTROLLER IS
# NEITHER OUT OF DETENT NOR IS THE RATE COMMAND BIT SET IN DAPBOOLS)

# IMMEDIATELY AFTER CALCULATING THE ATTITUDE ERRORS, THE FOLLOWING TESTS ARE MADE TO DETERMINE WHETHER THE DESCENT
# ENGINE TRIM GIMBAL SHOULD BE USED TO CONTROL THE LEM ATTITUDE RATHER THAN THE RCS JETS:

#          1) IS THE TRIM GIMBAL FUNCTIONALLY OPERATIVE?
#          2) ARE THE Q,R-AXES RCS JETS OFF?
#          3) ARE BOTH TRIM GIMBAL DRIVES OFF?
#          4) IS THE LEM RATE LESS THAN .5 DEG/SEC ABOUT BOTH AXES?

GOTOGTS         CAF             INITFILT                # ERRORS NOW CONTROLLABLE BY TRIM GIMBAL
                TS              T5ADR                   # SET T5RUPT TO GO TO FILTER INITIALIZING
                TCF             RESUME                  # PROGRAM

BGIM24          OCTAL           07400
DESCADR         GENADR          TJET-LAW                # RETURN ADDRESS FOR JET SELECT LOGIC
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
# BIT 3 TO ITS PREVIOUS VALUE IF THIS IS NOT 1, BECAUSE SAVERATE SETS BIT3
# TO 1 FOR ALL PASSES AFTER THE FIRST IN ORDER NOT TO SAVE THE RATE AGAIN.

# IN ADDITION TO NON-RATE HOLD MODE AND NON-FIRST PASS RATE HOLD MODE
# EXITS TO QERRCALC, THE FIRST PASS EXITS TO RESUME, IE. OUT OF INTERRUPT
# AND BACK TO DAPIDLER TO AWAIT THE NEXT CALL TO DAP.

# RATE HOLD PRODUCES THE FOLLOWING OUTPUT IN ERASABLE --

#    CDUD - SCALED AT +/-PI, DESIRED GIMBAL ANGLE

#    DELCDU - SCALED AT +/-PI, INCREMENT TO CDUD EVERY 100 MS.

#    OMEGAPD, QD, RD - SCALED AT +/-PI/4, BODY AXIS RATES

# ALL THESE ARE USED BY AUTOMATIC STEERING MODE EQUATIONS.

## Page 575
# RATE HOLD REQUIRES OMEGAP, Q, R EVERY .25 SEC, AND ALSO REQUIRES PILOT-
# TO-GIMBAL AXIS MATRIX ELEMENTS, MR12, 22, 13, 23 TO BE LOCATED IN THAT
# ORDER.

# FINALLY, RATE HOLD LEAVES DEBRIS IN --

#    DLCDUIDX - LOOP INDEX USED IN COMPUTING DELCDUS, = 1, 0

#    ITEMP1 - STORES TEMPORARY PRODUCTS AND SUMS, LEFT WITH DELCDUY IN 1S.



ATTSTEER        CS              DAPBOOLS                # DOES BIT14 OF DAPBOOLS REQUEST RATE HOLD
                MASK            BIT14                   # (SIVB-LEM SEPARATION)
                CCS             A
                TCF             QERRCALC                # NO, GO DIRECTLY TO AUTOMATIC STEERING

# CHECK DAPBOOLS, BIT3, TO SEE IF DESIRED RATE HAS BEEN SAVED YET

                CAE             DAPBOOLS                # DOES BIT3 SHOW THAT THE DESIRED RATE HAS
                MASK            BIT3                    # BEEN SAVED(NOT FIRST PASS).  IF NOT, GO
                CCS             A                       # SAVE DESIRED RATES IN THE OMEGADS
                TCF             NEXDLCDU        -1      # YES, COMPUTE THE DELCDUS.

# SAVERATE IS ENTERED ONLY DURING THE FIRST PASS THROUGH RATE HOLD.  IT
# SAVES THE CURRENT CDUS FIRST IN CDUDS AND THEN SAVES THE BODY RATES,
# OMEGAP, Q, R IN OMEGAPD, QD, RD.  NEXT, WE SET BIT 3 OF DAPBOOLS TO 1.

SAVERATE        EXTEND                                  # COME HERE FIRST TIME INTO RATE HOLD IN
                DCA             CDUY
                DXCH            CDUYD                   # ORDER TO SET UP RATES, CDUS, AND DELCDUS
                CAE             CDUX
                TS              CDUXD                   # FIRST, CDUDS = CDUS AT SIVB SEPARATION

                EXTEND                                  # NEXT, SAVE CURRENT SIVB SEPARATION RATES
                DCA             OMEGAP
                DXCH            OMEGAPD                 # OMEGAP AND OMEGAR, IN OMEGAPD AND
                CAE             OMEGAR
                TS              OMEGARD                 # OMEGARD.  LEM HELD TO RATES FOR 13 SECS.

                CAF             BIT3                    # RESET BIT 3 = 1 SO THAT RATES NOT SAVED
                ADS             DAPBOOLS                # AGAIN IN RATE HOLD PASSES
                TCF             RESUME                  # RETURN TO IDLE AFTER SAVING RATE

100MSCAL        DEC             .025                    # 100 MS. SCALED AT 4 SEC.  RATE HOLD DELT

# TO COMPUTE TEH DELCDUS, Y AND Z, WE SET UP A LOOP AND SOLVE THE EQUATION

# C(DELCDUY+DLCDUIDX)=(OMEGAQD.C(MR12+DLCDUIDX)+OMEGARD.C(MR13+DLCDUIDX))
#                       .(100MS) SCALED AT PI IN 2S COMPLEMENT(LIKE CDUS)

## Page 576
# DURING THIS COMPUTATION, ITEMP1 IS USED TO STORE THE PARTIAL SUMS AND
# PRODUCTS.  DELCDUY IS RESCALED TO 1 AS MR12 AND MR13 ARE SCALED AT 2.
# AFTER CONVERTING TO TWOS COMPLEMENT, WE SET DELCDUX TO ZERO TO AVOID ANY
# ROLL DURING RATE HOLD MODE.  NOTE THAT DELCDUS ARE COMPUTED IN THE NEGA-
# TIVE TO ALLOW 2S COMP. MOD. SUBTRACT LATER ON (CDU-(-DELCDU))

                CAF             ONE                     # SET UP LOOP INDEX TO COMPUTE DELCDUS.
NEXDLCDU        TS              DLCDUIDX                # DLCDUIDX = C(A)

                CS              OMEGAQD                 # DLCDUIDX = 1              DLCDUIDX = 0
                EXTEND                                  # ITEMP1=-OMEGAQD.MR22
                INDEX           DLCDUIDX
                MP              MR12                    # MR22 SCALED AT 1       MR12 SCALED AT 2
                TS              ITEMP1                  #                     ITEMP1=-OMEGAQD.MR12

                CS              OMEGARD                 # C(A)=ITEMP1 -OMEGARD.MR23
                EXTEND
                INDEX           DLCDUIDX                #                C(A)=ITEMP1 -OMEGARD.MR13
                MP              MR13                    # MR23 SCALED AT 1        MR13 SCALED AT 2
                AD              ITEMP1
                EXTEND                                  # DELT = 100 MS. SCALED AT 4 SEC.
                MP              100MSCAL
                TS              ITEMP1                  # ITEMP1 = C(A) . DELT

                CCS             DLCDUIDX                # CHECK INDEX FOR RESCALING
                TCF             +3                      # DELCDUZ SCALED AT PI/4, RESCALE UNNEEDED
                CAE             ITEMP1                  # DELCDUY SCALED AT PI/2, RESCALE BY
                ADS             ITEMP1                  # ADDING TO ITSELF

                CCS             ITEMP1                  # CONVERT DELCDUS TO TWOS COMPLEMENT (SAME
                AD              ONE                     # AS CDUS).  ADD ONE TO RESTORE PRE-CCS A
                TCF             STODLCDU                # STORE DIRECT IF POSITIVE ZERO
                COM                                     # COMPLEMENT IF NEGATIVE, CCS INCREMENTS
STODLCDU        INDEX           DLCDUIDX                # IF NEGATIVE ZERO, STORE POSITIVE ZERO
                TS              DELCDUY                 # STORE FINAL DELCDUZ OR DELCDUY

                CCS             DLCDUIDX                # TEST INDEX DLCDUIDX, EITHER 1 OR 0
                TCF             NEXDLCDU                # IF 1, DO DELCDUY
                TS              DELCDUX                 # DELCDUZ,Y DONE, 0 TO DELCDUX-NO ROLL

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

## Page 577
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

                CAF             BIT2                    # TEST TO SEE IF LEM AND DAP MODES ALLOW
                MASK            DAPBOOLS                # USE OF TRIM GIMBAL CONTROL SYSTEM:
                CCS             A                       # BIT2 = 0 MEANS THAT TRIM GIMBAL CONTROL
                TCF             STILLRCS                # IS POSSIBLE, SO TEST OTHER TG CONDITIONS

# TEST (2): ARE THE Q,R-AXES RCS JETS OFF?
                EXTEND                                  # BUT, IF JETS ARE OFF AND TRIM GIMBAL MAY
                READ            5                       # POSSIBLY BE USED: BEING IN THE JET COAST
                CCS             A                       # REGION OF THE PHASE PLANE IS A NECESSARY
                TCF             STILLRCS                # BUT INSUFFICIENT REASON FOR GTS USE

# TEST (3): ARE BOTH TRIM GIMBAL DRIVES OFF?

                EXTEND                                  # BITS 9-12 OF CHANNEL 12 ARE THE SIGNALS
                READ            12                      # WHICH DRIVE THE TRIM GIMBAL ENGINE:
                MASK            BGIM24                  # IF NONE OF THESE BITS ARE ON, THEN BOTH
                CCS             A                       # WAITLIST TASKS TO TURN OFF THE DRIVES
                TCF             STILLRCS                # HAVE BEEN DONE AND GTS CONTROL CAN OCCUR

# TEST (4): IS THE LEM RATE LESS THAN .5 DEG/SEC ABOUT BOTH AXES?

                CA              BIT1
LOOPTOP         TS              QRCNTR
                DOUBLE
                INDEX           A
                CCS             OMEGAQ                  # IS ERROR RATE SMALL ENOUGH FOR GTS.
                AD              -RATLM+1                # -.5 DEG/SEC SCALED AT PI/4 + 1 BIT
                TCF             +2
                AD              -RATLM+1
                EXTEND
                BZMF            +2                      # IS RATE LESS,EQUAL .5 DEG/SEC.
                TCF             STILLRCS                # NO.      SO USE RCS.

## Page 578
                INDEX           QRCNTR                  # YES.     TRY THE ERROR MAGNITUDE.
                CCS             QDIFF                   # IS ERROR SMALL ENOUGH FOR GTS.
                AD              -XBND+1                 # -1.4 DEG SCALED AT PI    + 1 BIT
                TCF             +2
                AD              -XBND+1
                EXTEND
                BZMF            +2                      # IS ERROR LESS,EQUAL 1.4 DEG.
                TCF             STILLRCS                # NO.      USE RCS CONTROL.
                CCS             QRCNTR                  # THIS AXIS IS FINE.   ARE BOTH DONE.
                TCF             LOOPTOP                 # NOW TRY THE Q AXIS.
                TCF             GOTOGTS                 # TRANSFER TO TRIM GIMBAL CONTROL
-RATLM+1        OCT             77512                   # -.5 DEG/SEC SCALED AT PI/4  + 1 BIT
-XBND+1         OCT             77601                   # -1.4 DEG SCALED AT PI. + 1 BIT.
# "STILLRCS" IS THE ENTRY POINT TO RCS ATTITUDE STEERING WHENEVER IT IS FOUND THAT THE TRIM GIMBAL CONTROL
# SYSTEM SHOULD NOT BE USED:

STILLRCS        CAF             DESCADR                 # SET JET SELECT LOGIC RETURN ADDRESS TO
                TS              TJETADR                 # THE Q,R-AXIS TJETLAW CALCULATION

                TC              T6JOBCHK                # CHECK T6 CLOCK RUPT BEFORE SUBROUTINE

RURGENCY        CAE             1/NJTSR                 # SET-UP URGENCY SUBROUTINE
                TS              1/NJETAC
## Note: Target  (See below)
                CS              OMEGARD                 # EDOTR = OMEGAR - OMEGARD
                AD              OMEGAR
                TS              EDOTR                   # SCALED AT PI/4 RADIANS
                TC              URGROUTN                # *** SUBROUTINE CALL ***
                TS              URGENCYR                # URGENCY LEFT IN A SCALED AT 2(4) SECS

                DXCH            E                       # MOVE R-AXIS VARIABLES TO R-AXIS ERASABLE
                DXCH            ER                      # FROM Q-XIS (COMMON) ERASABLE
                TS              E
                CAE             EDOT                    # (LLOK AT REORG FOR EFFIC: JDA 7/17/66)
                TS              EDOT(R)

QURGENCY        CAE             1/NJTSQ                 # SET-UP URGENCY SUBROUTINE
                TS              1/NJETAC
                CS              OMEGAQD                 # EDOTQ = OMEGAQ - OMEGAQD
                AD              OMEGAQ
                TS              EDOTQ                   # SCALED AT PI/4 RADIANS
                TC              URGROUTN                # *** SUBROUTINE CALL ***

                TS              URGENCYQ                # URGENCY LEFT IN A SCALED AT 2(4) SECS
## Note: in the scan the statements starting with QURGENCY are marked with red side bars
##       and a red box. The box has the marker CAE EDOTQ and an arrow pointing
##       in between the two statements marked as 'Target' above.
##
##                       ...
##                 TS             1/NJETAC
##                                        <------|
##                 CS             OMEGARD        |
##                                               |
##                       ...                     |
##                                               |
##  QURGENCY     | CAE             1/NJTSQ   |   |
##               | TS              1/NJETAC  |   |
##               |---------------------------|   |
##               | CS              OMEGAQD   |   |
##  CAE          | AD              OMEGAQ    |---|
##     EDOTQ     | TS              EDOTQ     |
##               |---------------------------|
##               | TC              URGROUTN  |
##               | TS              URGENCYQ  |
##

                EXTEND
                BZF             BURGZERO                # TEST FOR BOTH URGENCIES ZERO

                EXTEND
                MP              -TAN22.5
                AD              URGENCYR
                EXTEND

## Page 579
                MP              COS22.5
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
                BZMF            NEGAPOSB

POSAPOSB        CA              A-B
                EXTEND
                BZMF            MINUSU                  # NEGATIVE U-AXIS SELECTED

2/4JET-R        EXTEND
                DCA             ER
                DXCH            E
                CAE             EDOT(R)
                TS              EDOT
                CAE             .5ACCMNR
                TS              .5ACCMNE
                CAF             URM                     # 2/4 JET URGENCY TEST -R AXIS
                AD              URGENCYR
                EXTEND
                BZMF            2JETS-R

4JETS-R         CAE             1/2JTSR                 # MOVE 1/NJETAC UNMODIFIED
                TS              1/NJETAC
                CS              SEVEN
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS-R         CCS             RMANDACC                # ASCENT 4-JET OVER-RIDE TEST
                TCF             4JETS-R

## Page 580
                CAE             1/2JTSR
                TS              1/NJETAC
                CS              SIX
                TCF             POLTYPE                 # GO FIND BEST POLICY

MINUSU          CAE             .5ACCMNU
                TS              .5ACCMNE
                CAE             URGENCYQ                # 2 JET OPT/MAND TEST: -U AXIS
                AD              URGENCYR
                CCS             A
                AD              NEGURGUM
                TCF             +2
                AD              NEGURGUM
                EXTEND
                BZMF            2JETS-U

2JETSM-U        TC              UXFORM
2-U.RATE        CS              FIVE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS-U         CCS             UMANDACC                # ASCENT 2-JET MANDATORY OVER-RIDE TEST
                TCF             2JETSM-U
                TC              UXFORM
                CS              FOUR
                TCF             POLTYPE                 # GO FIND BEST POLICY

NEGAPOSB        CAE             A+B
                EXTEND
                BZMF            PLUSV

2/4JET-Q        CAE             .5ACCMNQ
                TS              .5ACCMNE
                CAF             UQM                     # 204 JET URGENCY TEST: -Q AXIS
                AD              URGENCYQ
                EXTEND
                BZMF            2JETS-Q         +2      # (FIRST TWO INSTRUCTIONS UNNECESSARY)

4JETS-Q         CAE             1/2JTSQ                 # MOVE 1/NJETAC UNMODIFIED
                TS              1/NJETAC
                CS              THREE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS-Q         CCS             QMANDACC                # ASCENT 4-JET OVER-RIDE TEST
                TCF             4JETS-Q
                CAE             1/2JTSQ
                TS              1/NJETAC
                CS              TWO
                TCF             POLTYPE                 # GO FIND BEST POLICY

PLUSV           CAE             .5ACCMNV

## Page 581
                TS              .5ACCMNE
                CS              URGENCYQ                # 2 JET OPT/MAND TEST: +V AXIS
                AD              URGENCYR
                CCS             A
                AD              NEGURGVM
                TCF             +2
                AD              NEGURGVM
                EXTEND
                BZMF            2JETS+V

2JETSM+V        TC              VXFORM
2+V.RATE        CS              ONE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS+V         CCS             VMANDACC                # ASCENT 2-JET MANDATORY OVER-RIDE TEST
                TCF             2JETSM+V
                TC              VXFORM
                CAF             ZERO
                TCF             POLTYPE                 # GO FIND BEST POLICY

BURGZERO        CAE             URGENCYR                # TEST FOR SECOND URGENCY ALSO ZERO
                EXTEND
                BZF             XTRANS                  # NO ROTATION NEEDED NOW

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

MINUSV          CAE             .5ACCMNV
                TS              .5ACCMNE
                CS              URGENCYQ                # 2 JET OPT/MAND TEST: -V AXIS
                AD              URGENCYR
                CCS             A
                AD              NEGURGVM

## Page 582
                TCF             +2
                AD              NEGURGVM
                EXTEND
                BZMF            2JETS-V

2JETSM-V        TC              VXFORM
2-V.RATE        CAF             ONE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS-V         CCS             VMANDACC                # ASCENT 2-JET MANDATORY OVER-RIDE TEST
                TCF             2JETSM-V
                TC              VXFORM
                CAF             TWO
                TCF             POLTYPE                 # GO FIND BEST POLICY

NEGANEGB        CAE             A-B
                EXTEND
                BZMF            2/4JET+R

PLUSU           CAE             .5ACCMNU
                TS              .5ACCMNE
                CAE             URGENCYQ                # 2 JET OPT/MAND TEST: +U AXIS
                AD              URGENCYR
                CCS             A
                AD              NEGURGUM
                TCF             +2
                AD              NEGURGUM
                EXTEND
                BZMF            2JETS+U

2JETSM+U        TC              UXFORM
2+U.RATE        CAF             THREE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS+U         CCS             UMANDACC                # ASCENT 2-JET MANDATORY OVER-RIDE TEST
                TCF             2JETSM+U
                TC              UXFORM
                CAF             FOUR
                TCF             POLTYPE                 # GO FIND BEST POLICY

2/4JET+R        EXTEND
                DCA             ER
                DXCH            E
                CAE             EDOT(R)
                TS              EDOT
                CAE             .5ACCMNR
                TS              .5ACCMNE
                CAF             URM                     # 2/4 JET URGENCY TEST +R AXIS
                AD              URGENCYR
                EXTEND

## Page 583
                BZMF            2JETS+R

4JETS+R         CAE             1/2JTSR                 # MOVE 1/NJETAC UNMODIFIED
                TS              1/NJETAC
                CAF             FIVE
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS+R         CCS             RMANDACC                # ASCENT 4-JET OVER-RIDE TEST
                TCF             4JETS+R
                CAE             1/2JTSR
                TS              1/NJETAC
                CAF             SIX
                TCF             POLTYPE                 # GO FIND BEST POLICY

2/4JET+Q        CAE             .5ACCMNQ
                TS              .5ACCMNE
                CAF             UQM                     # 2/4 JET URGENCY TEST: + Q AXIS
                AD              URGENCYQ
                EXTEND
                BZMF            2JETS+Q         +2      # (FIRST TWO INSTRUCTIONS UNNECESSARY)

4JETS+Q         CAE             1/2JTSQ                 # MOVE 1/NJETAC UNMODIFIED
                TS              1/NJETAC
                CAF             SEVEN
                TCF             POLTYPE                 # GO FIND BEST POLICY

2JETS+Q         CCS             QMANDACC                # ASCENT 4-JET OVER-RIDE TEST
                TCF             4JETS+Q
                CAE             1/2JTSQ
                TS              1/NJETAC
                CAF             EIGHT

POLTYPE         TS              POLRELOC
                EXTEND
                DCA             POLADR
                DTCB
POLADR          2CADR           POLTYPEP

## Page 584
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
                BZF             +2                      # CHECK FOR VALUE BEYOND SCALING RANGE
                TCF             REDUCEQR                # SAME AS REDUCEUV
                CAE             L
                TS              EDOT                    # SAVE RATE SCALED AT PI/16
                EXTEND
                SQUARE
                TS              EDOT(2)                 # SAVE RATE SQUARED SCALED AT PI(2)/2(8)

                CAE             EQ                      # TRANSFORM ANGULAR ERROR TO U/V-AXIS
                AD              ER
                EXTEND
                MP              .707
                TS              E                       # SAVE ERROR SCALED AT PI
                TC              Q

.707            DEC             0.70711                 # SQRT(1/2)



NEGURGUM        DEC             -.18750
NEGURGVM        EQUALS          NEGURGUM
UQM             EQUALS          NEGURGUM
URM             EQUALS          NEGURGUM


## Page 585
# GENERALIZED URGENCY SUBROUTINE FOR USE ON ALL PILOT AXES (P,Q,R)...

# DEPENDING ON THE AXIS PROBLEM, EDOTP,EDOTQ,EDOTR IS EXPECTED TO ARRIVE IN A AND 1/2JTSP,1/2JTSQ,1/2JTSR IN
# 1/NJETAC.  NOTE THAT THE Q,R-AXIS PROBLEM IS EXPECTED TO DO THE R-AXIS PROBLEM FIRST (FOR EFFICIENT USE OF
# ERASABLE) AND THE Q,R-AXIS PROBLEM DOES NOT USE TPSIG.
# (THIS ROUTINE SHOULD BE IN THE FIXED BANK OF THE Q,R-AXIS PROBLEM SINCE IT IS CALLED ONLY ONCE FROM THE P-AXIS.)

URGROUTN        TS              EDOT                    # SAVE FOR REDUCEQR
                EXTEND                                  # EXPECT EDOT IN A SCALED AT PI/4 RAD/SEC
                MP              BIT3                    # TRY TO RESCALE TO PI/16 RADIANS/SECOND
                EXTEND
                BZF             +2                      # OVERFLOW CHECK ON NEW SCALING
                TCF             REDUCERA                # DISTINGUISH BETWEEN P AND Q,R
 +2             CCS             L                       # INSURE NON-ZERO EDOT (TPSIG FLAG)
                AD              TWO
                TCF             +2
                COM
 +2             AD              NEG1
                TS              TPSIG                   # (FOR P-AXIS PROBLEM ONLY)
                TS              EDOT                    # SAVE FOR T-JET LAW SCALED AT PI/16

                EXTEND
                SQUARE
                TS              EDOT(2)                 # SCALED AT PI(2)/2(8) RAD(2)/SEC(2)

                EXTEND                                  # 1/2JTSP,1/2JTSQ,1/2JTSR IN 1/NJETAC
                MP              1/NJETAC                # SCALED AT 2(8)/PI SEC(2)/RAD
                EXTEND
                SU              DB                      # DEADBAND SCALED AT PI RADIANS
                TS              FPQR                    # .5(1/ACC)EDOT(2) - DB SCALED AT PI RADS

                CAE             EDOT(2)                 # SCALED AT PI(2)/2(8) RAD(2)/SEC(2)
                EXTEND
                MP              .5ACCMNE                # .5(1/ACCMIN) AT 2(8)/PI SEC(2)/RAD
                AD              DB                      # SCALED AT PI RADIANS
                TS              FPQRMIN                 # .5(1/ACCMIN)EDOT(2) + DB AT PI RADIANS

                CCS             EDOT                    # EDOT TEST ON SIGN
                CAE             E                       # P,Q,R-AXIS ERROR SCALED AT PI RADIANS
                TCF             +2
                TCF             EDOTNEG
 +2             ADS             FPQR                    # E + .5(1/ACC)EDOT(2) - DB AT PI RADIANS

FTEST           CCS             EDOT                    # EDOT GUARANTEED NOT +0 OR -0
                CCS             FPQR                    # FPQR GUARANTEED NOT +0
                TCF             TPSIGCHG                # EDOT.G.+0, FPQR.G.+0
                CCS             FPQR                    # EDOT.L.-0
                TCF             FPMINCAL                # EDOT.L.-0,FPQR.G.+0/EDOT.G.+0,FPQR.L.-0
                TCF             FPMINCAL                # EDOT.G.+0, FPQR.E.-0 (FROM FIRST CCS)
                TCF             TPSIGCHG                # EDOT.L.-0, FPQR.L.-0

## Page 586
TPSIGCHG        CS              TPSIG                   # EDOT.L.-0, FPQR.E.-0 (FROM 2ND CCS)
                TS              TPSIG                   # (SIGN OF P-AXIS JETS IF NEEDED)
                CAE             EDOT                    # SCALED AT PI/16 RADIANS/SECOND
                EXTEND
                MP              BIT11                   # SCALE TO PI RADIANS/SECOND
                AD              FPQR                    # (IMPLICIT MULT OF FPQR BY 1/SEC)
                TCF             URGMULT                 # THIS URGENCY = (1/ACC)(FPQR+EDOT)

EDOTNEG         CS              FPQR                    # SCALED AT PI RADIANS
                AD              E
                TS              FPQR                    # E - .5(1/ACC)EDOT(2) + DB
                TCF             FTEST

FPMINCAL        CCS             FPQR                    # NECESSARY RETEST ON FPQR
                CS              FPQRMIN
                TCF             +2                      # E - .5(1/ACCMIN)EDOT(2) - DB
                CAE             FPQRMIN
                AD              E                       # E + .5(1/ACCMIN)EDOT(2) + DB
                TS              FPQRMIN                 # (SCALED AT PI RADIANS)

                CCS             EDOT                    # EDOT    GUARANTEED NOT +0 OR -0
                CCS             FPQRMIN                 # FPQRMIN GUARANTEED NOT +0 (CALL IT F)
                TCF             ZEROURG                 # EDOT.G.+0, F.G.+0
                CCS             FPQRMIN                 # EDOT.L.-0
                TCF             NORMURG                 # EDOT.L.-0, F.G.+0 / EDOT.G.+0, F.L.-0
                TCF             NORMURG                 # EDOT.G.+0, F.E.-0 (FROM FIRST CCS)
                TCF             ZEROURG                 # EDOT.L.-0, F.L.-0
ZEROURG         CAF             ZERO                    # EDOT.L.-0, F.E.-0 (FROM SECOND CCS)
                TCF             URGSTORE                # THIS URGENCY ZERO (IN COAST REGIAN)

NORMURG         CAE             FPQRMIN                 # THIS URGENCY FPQRMIN(1/ACC)
URGMULT         EXTEND
                MP              1/NJETAC
                EXTEND                                  # SCALE FROM 2(9) TO 2(4) SECONDS
                MP              BIT6                    # 1/NJETAC = 1/2JETAC, WANT 1/1JETAC
                EXTEND
                BZF             URGTOA
                CCS             A
                CA              POSMAX
                TCF             URGSTORE
                CS              POSMAX
                TCF             URGSTORE
URGTOA          CA              L
URGSTORE        TC              Q                       # *** RETURN ***

## Page 587
# GENERALIZED T-JET LAW SUBROUTINE FOR USE BY BOTH THE P-AXIS AND Q,R-AXIS PROBLEMS (ONCE EACH)...

# DEPENDING ON THE AXIS ABOUT WHICH ROTATION IS DEEMED MOST URGENT, 1/JACC FOR THAT AXIS IS EXPECTED IN 1/NJETAC
# AND THE CORRESPONDING VALUES FOR E, EDOT, AND EDOT(2) ARE ALSO EXPECTED TO BE SET UP IN ADVANCE.
# (THIS ROUTINE MAY RESIDE IN THE FIXED BANK OF EITHER THE P-AXIS OR Q,R-AXIS PROBLEM.)

# ***** IMPORTANT NOTICE *****

#     NOTE THAT TJETLOC IS THE LOCAL ENTRY POINT FOR THIS PROGRAM AND TJETLAW IS THE CROSS-BANK ENTRY.  SEE BELOW
# FOR THE TWO CALLING SEQUENCES FOR OPTIMAL USE AND BE ASSURED THAT FOR EITHER CASE ISWRETRN MUST BE USED AND
# RUPTREG3 CONTAINS THE EVENTUAL RETURN ADDRESS.

# LOCAL CALL:
#          TC     TJETLOC
#          TCF    NO ROTATION JETS
#          TS     TIME CALCULATED

# CROSS-BANK CALL:
#          CAF    TJETLAWCADR
#          TC     ISWCALL
#          TCF    NO ROTATION JETS
#          TS     TIME CALCULATED



# ***** VERY IMPORTANT NOTICE *****

# SINCE THE Q,R-AXES SWITCHED FIXED BANK BECAME VERY FULL (DUE TO THE ADDITION OF RATE-HOLD MODE AND A BETTER
# RCS-GTS INTERFACE), THE LOCAL CALL AND LOCAL ENTRY POINT FOR THE T-JET LAW HAVE BEEN DELETED AS OF REVISION  7
# OF AURORA (BY JON ADDELSTON 10/24/66).



# FOR CONVENIENCE, WE INCLUDE HERE THE CALL FROM THE Q,R-AXIS PROBLEM:

                BANK            24
QR-JETLW        CADR            TJET-LAW                # CADR OF Q,R-ENTRY TO TJETLAW SUBROUTINE

TJET-LAW        TC              T6JOBCHK                # CHECK T6 CLOCK RUPT BEFORE SUBROUTINE

                CAF             QR-JETLW                # T-JETLAW CALLING SEQUENCE (LIKE P-AXIS)
                TC              ISWCALL                 # (IN INTERBANK COMMUNICATION LOG SECTION)
                TCF             XTRANS                  # GO TO XTRANS SINCE NO ROTATION IS USED
                TS              TQR                     # SAVE CALCULATED TIME FOR THE TORQUE
                TCF             TORQUEV                 # VECTOR RECONSTRUCTION PROBLEM


## Note: the following seems to be fully assembled code injected as comment. See the VERY IMPORTANT NOTICE above .
#    24,1000   0 0006 1  TJETLOC         EXTEND                   LOCAL ENTRY FAKES CROSS-BANK IN SMALL DT

## Page 588
#    24,1001   22 076 0  QXCH            RUPTREG3                 SAVE RETURN WHERE ISWCALL DOES
#    24,1002   3 4174 1  CAF             ISWRETRN        +3       GET CADR OF RUPTREG3 FROM TC INSTRUCTION
#    24,1003   54 002 1  TS              Q                        SO TC Q GOES TO RUPTREG3 FOR RETURN

                BANK            25

TJETLAW         CS              EDOT                    # TEST EDOT SIGN
                EXTEND
                BZMF            +4
                TS              EDOT                    # SIGNS OF E AND EDOT CHANGED IF EDOT NEG
                CS              E                       # TO CONSIDER FUNCTIONS IN UPPER HALF OF
                TS              E                       # THE E,EDOT PHASE PLANE

                CAE             EDOT(2)                 # SCALED AT PI(2)/2(8) RAD(2)/SEC(2)
                EXTEND                                  # (1/NJETAC HAS BEEN SET FOR N JETS)
                MP              1/NJETAC                # SCALED AT 2(8)/PI SEC(2)/RAD
                EXTEND
                MP              BIT14                   # .5EDOT(2)/NJETACC SCALED AT PI RADIANS
                AD              E                       # SCALED AT PI RADIANS (ERROR)
                EXTEND
                SU              DB                      # SCALED AT PI RADIANS (DEADBAND)
                TS              HDAP                    # E + .5EDOT(2)/NJETACC - DB

                EXTEND
                BZMF            NEGHDAP

                CAE             EDOT                    # SCALED AT PI/16 RAD/SEC (RATE)
                EXTEND
                MP              1/NJETAC                # SCALED AT 2(8)/PI SEC(2)/RAD (ACC) (-1)
                TS              TERMA                   # SCALED AT 2(4) SEC (CNTRL SMPL PERIOD)
                AD              NEGCSP                  # EDOT/NJETACC - CSP SCALED AT 16 SECONDS

                EXTEND
                BZMF            +3

MAXTJET         CAF             BIT14                   # (1/2) IS LIKE POSMAX AT THIS SCALING
                TCF             NORMRETN                # (OVERFLOW IS THUS PREVENTED)

                CS              HDAP                    # -DBMINIMP + E + EDOT(2)/NJETACC - DB
                AD              MINIMPDB                # SCALED AT PI RADIANS
                EXTEND
                BZMF            MAINBRCH

                CAE             TERMA                   # EDOT/NJETACC - .5TJMIN SCALED AT 16 SECS
                AD              -20MS                   # - 20 MS SCALED AT 16.
                EXTEND
                BZMF            TJMIN

                AD              23.75MS                 # WE GET TERMA + 3.75 MS.
                TCF             TJETSCAL

## Page 589
TJMIN           CS              PAXCALL                 # WE KNOW WE DO P AXIS SINCE WE HAVE RUPT-
                AD              RUPTREG3                #  REG3 = T-JETLAW +3(Q-AXIS CALL NOT AT
                EXTEND                                  #  SAME LOCATION-- WE HOPE - AND INSURE.).
                BZF             WEDOP
                CAE             NO.QJETS                # NO. OF Q JETS ON
                EXTEND
                BZF             WEDOR
                CAE             NO.RJETS                # NO. OF R JETS ON
                EXTEND
                BZF             WEDOQ
DOTJMIN         CAF             +TJMINT6
NORMRETN        INCR            RUPTREG3                # *** RETURN +1 ***
                TC              Q                       # BACK TO ISWRETRN
WEDOP           TS              OMEGAP
                TCF             DOTJMIN
WEDOR           TS              OMEGAR
                TCF             DOTJMIN
WEDOQ           TS              OMEGAQ
                TCF             DOTJMIN
PAXCALL         GENADR          T-JETLAW        +3
NEGHDAP         CAE             EDOT(2)                 # SCALED AT PI(2)/2(8) RAD(2)/SEC(2)
                EXTEND
                MP              .5ACCMNE                # .5(1/ACCMIN) AT 2(8)/PI SEC(2)/RAD
                AD              E                       # SCALED AT PI RADIANS (ERROR)
                AD              DB                      # SCALED AT PI RADIANS  (DEADBAND)
                AD              DBMINIMP
                EXTEND
                BZMF            +2
                TC              Q                       # *** RETURN *** (NO JETS)

 +2             CS              MAXRATE                 # 10 DEG/SEC SCALED AT PI/16 RAD/SEC
                AD              EDOT                    # EDOT - MAXRATE
                EXTEND
                BZMF            +2
                TC              Q                       # *** RETURN *** (NO JETS)

 +2             CS              EDOT                    # SCALED AT PI/16 RAD/SEC (RATE)
                EXTEND
                MP              1/NJETAC                # SCALED AT 2(8)/PI SEC(2)/RAD (ACC)(-1)
                TS              TERMA                   # -EDOT/NJETACC SCALED AT 2(4) SECONDS

                CS              HDAP                    # - E + .5EDOT(2)/NJETACC + DB
                AD              E
                AD              E                       # TWICE ERROR NEGATES E OF HDAP(OLD)
                AD              MINIMPDB
MAINBRCH        TS              HDAP                    # -HDAP(OLD) + 2E + DBMINIMP AT PI RADS

                CAE             1/NJETAC                # SCALED AT 2(8)/PI SEC(2)/RAD
                EXTEND
                MP              BIT14                   # (1/2)(1/NJETAC)

## Page 590
                AD              .5ACCMNE
                TS              DENOM                   # .5(1/NJETACC) + .5(1/ACCMIN) AT 2(8)/PI

                EXTEND
                MP              MAXRATE2                # SCALED AT PI(2)/2(8) RAD(2)/SEC(2)
                AD              HDAP                    # DENOM.MAXRATE(2) + HDAP AT PI RADIANS
                EXTEND
                BZMF            NOROOT

                CAE             HDAP                    # SCALED AT PI RADIANS
                EXTEND
                DV              DENOM                   # SCALED AT 2(8)/PI SEC(2)/RAD(2)
                EXTEND
                MP              1/NJETAC
                EXTEND
                MP              1/NJETAC
                TS              TERMB                   # -(HDAP/DENOM)(1/NJETACC)(2) AT 2(8) SECS

                CAF             NEGCSP                  # SCALED AT 2(4) SECONDS
                AD              TERMA
                EXTEND
                SQUARE                                  # SCALED AT 2(8) SECONDS
                AD              TERMB
                EXTEND                                  # (TERMA - CSP)(2) + TERMB
                BZMF            MAXTJET
                CAF             -TJMIN16
                AD              TERMA                   # TERMA - TJMIN SCALED AT 2(4) SECONDS
                EXTEND
                BZMF            MAYNOJET

PREROOT         EXTEND                                  # MUST SAVE Q .

                QXCH            A+B
                TC              T6JOBCHK
                CS              TERMB
                TC              SPROOT                  # SQRT(-TERMB) SCALED AT 2(4) SECONDS

                EXTEND                                  # MUST RESTORE OLD Q AFTER SPROOT
                QXCH            A+B

TJSUM           AD              TERMA                   # TERMA + SQRT(-TERMB)
TJETSCAL        DOUBLE                                  # NOW SCALED AT 2(3) SECONDS
                EXTEND
                MP              25/32QR                 # SCALED T O 16/25 2(4) SECONDS.
                TCF             NORMRETN                # *** RETURN +1 ***

NOROOT          CAF             MAXRATE
                AD              .6DEG/SC                # MAXRATE + DEL SCALED AT PI/16 RAD/SEC
                EXTEND
                MP              1/NJETAC                # SCALED AT 2(8)/PI SEC(2)/RAD

## Page 591
                TCF             TJSUM                   # SCALED AT 2(4) RADIANS

MAYNOJET        CAF             -TJMIN16
                AD              TERMA                   # TERMA - TJMIN SCALED AT 2(4) SECONDS
                EXTEND
                SQUARE                                  # SCALED AT 2(8) SEC(2)
                AD              TERMB
                EXTEND
                BZMF            PREROOT                 # (TERMA - TJMIN)(2) + TERMB AT 2(8)
                TC              Q                       # *** RETURN *** (NO JETS)

NEGCSP          DEC             -.00625                 # 100 MS SCALED AT 2(4) SECONDS
+TJMINT6        DEC             +.00073
-TJMIN16        DEC             -.00047
-TJMINQR        EQUALS          -TJMIN16
23.75MS         DEC             0.00148                 # 23.75 MS SCALED AT 16 SECONDS.
-20MS           DEC             -.00125                 # - 20 MS SCALED AT 16 SECONDS.
MAXRATE         DEC             0.88889                 # 10 DEGREES/SECOND SCALED AT PI/16
MAXRATE2        DEC             0.79012                 # 100 DEG(2)/SEC(2) SCALED AT PI(2)/2(8)
.6DEG/SC        DEC             0.05333                 # 6/10 DEGREES/SECOND SCALED AT PI/16
25/32QR         DEC             0.78125

## Page 592
# THESE TWO SUBROUTINES TRANSFORM EDOTQ,EDOTR INTO THE U/V-AXIS (RESPECTIVELY) FOR THE RATE COMMAND MODE (ONLY).
# VALUE IS STORED IN EDOTGEN SCALED AT PI/4 RADIANS/SECOND.

                BANK            24

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



# THESE PROGRAMS REDUCE THE RATE ERROR TO 10.6 DEGREES/SECOND.

REDUCERA        CS              EDOT                    # TEST FOR P-AXIS PROBLEM
                AD              EDOTP                   # EXACT MATCH MEANS P-AXIS
                EXTEND
                BZF             REDUCEP                 # P-AXIS SUM IS ALWAYS MINUS ZERO

REDUCEQR        TC              REDUCESC                # GET SHRINK FACTOR
                EXTEND                                  # SHRINK Q-AXIS COMPONENT
                MP              EDOTQ
                TS              QRATEDIF

                CAE             EDOTR                   # SHRINK R-AXIS COMPONENT
                EXTEND
                MP              EDOT
                TS              RRATEDIF

                TCF             OBEYQRRC

REDUCEP         TC              REDUCESC                # GET SHRINK FACTOR
                EXTEND                                  # SHRINK P-AXIS COMPONENT
                MP              EDOTP
                TS              EDOTP
                TS              TPSIG

                EXTEND
                DCA             +2
                DTCB
                2CADR           OBEYRAPE

## Page 593
REDUCESC        CAF             10.6D/S                 # SCALED AT PI/4
                EXTEND
                DV              EDOT                    # RESULT SCALED AT 1
                TS              EDOT                    # SAVE FACTOR IN EDOT FOR R SHRINKAGE
                TC              Q                       # *** RETURN ***

10.6D/S         DEC             0.23111                 # 10.6 DEGRESS/SECOND SCALED AT PI/4



ENDDAP24        EQUALS
