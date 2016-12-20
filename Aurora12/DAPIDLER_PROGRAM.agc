### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     DAPIDLER_PROGRAM.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        557-561
## Mod history:  2016-09-20 JL   Created.
##               2016-10-15 HG   FIx operand IZZMASK -> IZZTASK
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

## Page 557
# THE DAPIDLER PROGRAM IS STARTED BY FRESH START AND RESTART.             THE DAPIDLER PROGRAM IS DONE 10 TIMES
# PER SECOND UNTIL THE ASTRONAUT DESIRES THE DAP TO WAKE UP, AND THE IMU AND CDUS ARE READY FOR USE BY THE DAP.
# THE NECESSARY INITIALIZATION OF THE DAP IS DONE BY THE DAPIDLER PROGRAM.
# ADDITIONAL WORK MUST BE DONE ON DAPIDLER IN THE FUTURE.



DAPIDLER        LXCH            BANKRUPT                # INTERRUPT LEAD IN (CONTINUED)
                EXTEND
                QXCH            QRUPT
                
                CAF             BIT6
                MASK            IMODES30
                CCS             A
                TCF             MOREIDLE
                
                CAF             BIT4
                AD              BIT5
                EXTEND
                RAND            12
                CCS             A
                TCF             MOREIDLE
                
                CAF             BIT10                   # BIT10 OF 30 IS PNGCS CONTROL OF S/C
                EXTEND
                RAND            30                      # BITS IN 30 ARE INVERTED
                CCS             A
                TCF             MOREIDLE
                
                CAF             BIT13                   # ATTITUDE HOLD BIT. INVERTED.
                EXTEND
                RAND            31
                EXTEND
                BZF             STARTDAP
                
                CA              BIT14
                EXTEND
                RAND            31
                CCS             A
                TCF             MOREIDLE
                
STARTDAP        CAF             ZERO
                TS              TIME6
                TS              TIMEOFFQ
                TS              TIMEOFFR
                TS              LASTPER
                TS              LASTQER
                TS              LASTRER
                TS              PERROR                  # INITIALIZE TEMPS FOR ATT ERROR DISPLAY
                TS              QERROR
## Page 558
                TS              RERROR
                TS              T6NEXT
                TS              T6NEXT          +1
                TS              DELAYCTR
                TS              JETRATE
                TS              JETRATEQ
                TS              JETRATER
                TS              AOSQTERM
                TS              AOSRTERM
                TS              CH5MASK
                TS              CH6MASK
                TS              DELTAP
                TS              OMEGAP
                TS              OMEGAQ
                TS              OMEGAR
                TS              OMEGAPD
                TS              OMEGAQD
                TS              OMEGARD
                TS              TQR
                TS              NO.QJETS
                TS              NO.RJETS
                                                        ## HANDWRITTEN NOTATION:
                                                        ## TS  (1-K)GR
                                                        ##     (1-K)/8
                CAF             0.62170
                TS              4JETTORK
                CAF             .68387                  # 2200 FT LBS. SCALED AT 2(10) X PI.
                TS              JETTORK4                # QR AXIS JET TORQUE FOR 4 JETS.
                CA              CDUX
                TS              OLDXFORP
                TS              CDUXD
                CA              CDUY
                TS              OLDYFORP
                TS              OLDYFORQ
                TS              CDUYD
                CA              CDUZ
                TS              OLDZFORQ
                TS              CDUZD
                CAF             BIT6                    # ENABLE CDU ERR CNTR FOR ATT ERROR DISPLA
                EXTEND
                WOR             12
                
                CA              VISFZADR
                TS              PJUMPADR
                CA              .075DEC                 # INITIALIZE 100 MS JET PULSE TORQUE TERMS
                TS              100MSPTQ                #   TO VALUES WHEN K = 1/2.
                TS              QR.1STOQ                # AOSTASK MUST VARY THESE AS K VARIES.
# ****** JON ADDELSTON TAKE NOT OF THE ABOVE COMMENT - DICK GRAN.
## Page 559
                CA              10AT16
                TS              WFORP                   ## HANDWRITTEN NOTATION:
                CA              6.6AT16                 ## <<-THIS INSTRUCTION IS CROSSED OUT, BUT THEN
                                                        ## THERE IS A NOTATION "GOOD AS IS"
                TS              WFORQR
                
                CAF             ONE
                TC              WAITLIST
                2CADR           IXXTASK
                
                CA              ONE
                TC              WAITLIST
                2CADR           IYYTASK
                                                        ## HANDWRITTEN NOTATION:
                                                        ##   CAF      IPOMS
                                                        ##   TC       WAITLIST
                                                        ##   2CADR    WCHANGER
                CA              ONE
                TC              WAITLIST
                2CADR           IZZTASK
                
# THIS SECTION COMPUTES THE RATE OF CHANGE OF ACCELERATION DUE TO THE
#   ROTATION OF THE GIMBAL ENGINE. THE EQUATION IMPLEMENTED IN BOTH THE
#   Y-X PLANE AND THE Z-X PLANE IS -- D(ALPHA)/DT = T L/I * D(DELTA)/DT
#   WHERE ----
#             T = ENGINE THRUST COMMAND
#             L = PIVOT TO CG DISTANCE OF THE GIMBAL ENGINE
#             I = INERTIA
#             DELTA = GIMBAL ENGINE ANGLE MEASURED FROM THE X AXIS.

                CAF             DELTADOT                # 0.2 DEG/SEC SCALED AT PI/64
                EXTEND
                MP              L,PVT-CG                # GIMBAL PIVOT TO C.G. DISTANCE ,SCALE=8.
                EXTEND
                MP              THRSTCMD                # COMMANDED THRUST SCALED AT 2(14) =16384.
                DXCH            ITEMP1
                EXTEND
                DCA             ITEMP1
                EXTEND
                DV              IZZ                     # AT 2(18)
                TS              ACCDOTR                 # AT PI/2(7)
                DXCH            ITEMP1
                EXTEND
                DV              IYY                     # AT 2(18)
                TS              ACCDOTQ                 # AT PI/2(7)
                
                EXTEND                                  # .3ACCDOTQ AT PI/2(8)
                MP              DGBF
                TS              KQ
                EXTEND
                SQUARE
                TS              KQ2                     # KQ(2)
                
                CAE             ACCDOTR                 # .3ACCDOTR AT PI/2(8)
## Page 560
                EXTEND
                MP              DGBF
                TS              KR
                EXTEND
                SQUARE
                TS              KR2
                
                CAF             .5ACCMIN
                TS              .5ACCMNQ                # INITIALIZE FOR DESCENT
                TS              .5ACCMNR
                TS              .5ACCMNU
                TS              .5ACCMNV
                
                TS              .5ACCMNE                # (QUIRK FIX)
                
                CAF             DBMNMP                  # SET UP DESCENT MINIMUM IMPULSE DEADBANDS
                TS              DBMINIMP                # (DUPLICATES MONITOR FUNCTION)
                TS              MINIMPDB
                
                EXTEND                                  # SET UP P-AXIS TO GO TO DUMMYFIL
                DCA             DF2CADR
                DXCH            PFILTADR
                
                EXTEND
                DCA             PAXADIDL
                DXCH            T5ADR
MOREIDLE        CAF             MS100
                TS              TIME5
                TCF             RESUME
IDLERADR        2CADR           DAPIDLER

GOIDLADR        EQUALS          IDLERADR


VISFZADR        GENADR          CHKVISFZ
WCHANGER        CA              0.31250                 # CHANGE WFORP AND WFORQR
                TS              WFORP                   # TO REFLECT 100 MS INTERVAL
                TS              WFORQR                  # WHICH CAUSES SMOOTHING IN RATE FILTER.
                TCF             TASKOVER                # BETWEEN 1ST QR AND 2ND P AFTER STARTDAP
.707P           DEC             .70711                  # SQUARE ROOT OF 1/2
PAXADIDL        2CADR           PAXIS
DF2CADR         2CADR           DUMMYFIL
MS100           OCTAL           37766
0.00167         DEC             0.00167
0.62170         DEC             0.62170
180MS           OCTAL           00022                   # 18 BITS                
.68387          DEC             0.68387
## Page 561
10AT16          DEC             0.62500
6.6AT16         DEC             0.4125                  # *** IS THIS NEEDED
0.31250         DEC             0.31250

DELTADOT        DEC             0.07111                 # 0.2 DEG/SEC SCALED AT PI/64
DGBF            DEC             0.6
OCT70000        OCT             70000
.5ACCMIN        DEC             0.30680
DBMNMP          DEC             0.00167                 # .3 DEGREES SCALED AT PI RADIANS
.075DEC         DEC             0.07500                 # = T(1-K + KT/(2CSP) ) WHEN T = .1,K=.5
ENDDAP23        EQUALS
