### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THROTTLE_CONTROL_ROUTINES.agc
## Purpose:     A log section of Zerlina 56, the final revision of
##              Don Eyles's offline development program for the variable 
##              guidance period servicer. It also includes a new P66 with LPD 
##              (Landing Point Designator) capability, based on an idea of John 
##              Young's. Neither of these advanced features were actually flown,
##              but Zerlina was also the birthplace of other big improvements to
##              Luminary including the terrain model and new (Luminary 1E)
##              analog display programs. Zerlina was branched off of Luminary 145,
##              and revision 56 includes all changes up to and including Luminary
##              183. It is therefore quite close to the Apollo 14 program,
##              Luminary 178, where not modified with new features.
## Reference:   pp. 779-783
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##              2017-08-19 MAS  Updated for Zerlina 56.
##              2017-08-24 MAS  Corrected some instructions related to storing to PIF.

## Page 779
# T  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  E
#  H  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  Y
#   R  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  L
#    O  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  E
#     T  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  S
                
                SETLOC  FTHROT
                BANK
                COUNT*  $$/THROT
                EBANK=  PIF

#     ENTER HERE FROM P66ROD WITH PIF IN A.

P66THROT        EXTEND
                QXCH    RTNHOLD
                TS      PIF
                TCF     DOITP66

#     ENTER HERE IN P63 AND P64.  FIRST COMPUTE FP (PRESENT THRUST) AND FC (DESIRED THRUST) IN OUTPUT BIT UNITS.

THROTTLE        CA      ABDELV          # COMPUTE PRESENT ACCELERATION IN UNITS OF
                EXTEND                  #   2(-4) M/CS/CS, SAVING SERVICER TROUBLE
                MP      /AF/CNST
                EXTEND
                QXCH    RTNHOLD
AFDUMP          TC      MASSMULT
                DXCH    FP              # FP = PRESENT THRUST
                EXTEND
                DCA     FWEIGHT
                DAS     FP
                DXCH    FP
                EXTEND
                MP      2SECS
                EXTEND
                DV      PGUIDE
                TS      FP

                EXTEND
                DCA     /AFC/
                TC      MASSMULT
                INHINT                  # PREVENT A DOWNRUPT
                TS      FC              # FC = THRUST DESIRED BY GUIDANCE
                DXCH    FCODD           # FCODD = WHAT IT IS GOING TO GET


                EXTEND
                DCA     PIPTIME
                DXCH    GTCTIME         # DOWNLINK TIME AGREEMENT
                RELINT
                
## Page 780
#     THIS LOGIC DETERMINES THE THROTTLING IN THE REGION 10% - 94%.   THE MANUAL THROTTLE, NOMINALLY SET AT
# MINIMUM BY THE ASTRONAUT, PROVIDES THE LOWER BOUND.   A STOP IN THE THROTTLE HARDWARE PROVIDES THE UPPER.

WHERETO         CA      EBANK5          # INITIALIZE L*WCR*T AND H*GHCR*T FROM
                TS      EBANK           #   PAD LOADED ERASABLES IN W-MATRIX
                EBANK=  LOWCRIT
                EXTEND
                DCA     LOWCRIT
                DXCH    L*WCR*T
                CA      EBANK7
                TS      EBANK
                EBANK=  PIF
                CS      ZERO            # INITIALIZE PIFPSET
                TS      PIFPSET
                CS      H*GHCR*T
                AD      FCOLD
                EXTEND
                BZMF    LOWFCOLD        # BRANCH IF FCOLD < OR = HIGHCRIT
                CS      L*WCR*T
                AD      FCODD
                EXTEND
                BZMF    FCOMPSET        # BRANCH IF FC < OR = LOWCRIT
                CA      FP              # SEE NOTE 1
                TCF     FLATOUT1

FCOMPSET        CS      FMAXODD         # SEE NOTE 2
                AD      FP
                TCF     FLATOUT2

LOWFCOLD        CS      H*GHCR*T
                AD      FCODD
                EXTEND
                BZMF    DOPIF           # BRANCH IF FC < OR = HIGHCRIT

                CA      FMAXPOS         # NO:   THROTTLE-UP
FLATOUT1        XCH     FCODD
                CA      FEXTRA
FLATOUT2        TS      PIFPSET

#                                         NOTE 1   FC IS SET EQUAL TO FP SO PIF WILL BE ZERO.   THIS IS DESIRABLE
#                                                  AS THERE IS ACTUALLY NO THROTTLE CHANGE.

#                                         NOTE 2   HERE, SINCE WE ARE ABOUT TO RETURN TO THE THROTTLEABLE REGION
#                                                  (BELOW 55%) THE QUANTITY -(FMAXODD - FP) IS COMPUTED AND PUT
#                                                  INTO PIFPSET TO COMPENSATE FOR THE DIFFERENCE BETWEEN THE
#                                                  NUMBER OF BITS CORRESPONDING TO FULL THROTTLE (FMAXODD) AND THE
#                                                  NUMBER CORRESPONDING TO ACTUAL THRUST (FP).   THUS THE TOTAL
#                                                  THROTTLE COMMAND PIF = FC - FP -(FMAXODD - FP) = FC - FMAXODD.

DOPIF           CS      FP              # COMPUTE PIF AND LIMIT IT TO 4096 BITS
## Page 781
                AD      FCODD           #   SO FWEIGHT COMPUTATION CAN'T OVERFLOW
                TS      L
                CAF     BIT13
                TC      BANKCALL
                CADR    LIMITSUB

DOIT            TS      PIF
                AD      PIFPSET         # ADD IN PIFPSET, WITHOUT CHANGING PIF
DOITP66         XCH     PIFPSET         # STASH IT IN PIFPSET FOR A MOMENT
                CAF     BIT10           # DOES PGNCS HAVE CONTROL?
                EXTEND
                RAND    CHAN30
                CCS     A
                TCF     ZILCH           # NO:   AGS, DARN IT, ZERO AUTO-THROTTLE
                CA      PIFPSET         # YES:  RETRIEVE OUTPUT AND PRESS ON
THROTOUT        TS      PSEUDO55
                TS      THRUST
                CAF     BIT4
                EXTEND
                WOR     CHAN14

#     SINCE /AF/ IS NOT AN INSTANTANEOUS ACCELERATION, BUT RATHER AN "AVERAGE" OF THE ACCELERATION LEVELS DURING
# THE PRECEEDING PIPA INTERVAL, AND SINCE FP IS COMPUTED DIRECTLY FROM /AF/, FP IN ORDER TO CORRESPOND TO THE
# ACTUAL THRUST LEVEL AT THE END OF THE INTERVAL MUST BE WEIGHTED BY

#                                   PIF(PPROCESS + TL)     PIF /PIF/
#                         FWEIGHT = ------------------ + -------------
#                                         PGUID          2 PGUID FRATE

# WHERE PPROCESS IS THE TIME BETWEEN PIPA READING AND THE START OF THROTTLING, PGUID IS THE GUIDANCE PERIOD, AND
# FRATE IS THE THROTTLING RATE (32 UNITS PER CENTISECOND).  PGUID IS EITHER 1 OR 2 SECONDS. THE "TL" IN THE
# FIRST TERM REPRESENTS THE ENGINE'S RESPONSE LAG.   HERE FWEIGHT IS COMPUTED FOR USE NEXT PASS.

                CAF     8SECS
                TS      Q
                EXTEND
                MP      BIT5
                LXCH    BUF  +1
                CS      GTCTIME  +1     # TIME AT LAST PIPA READING.
                AD      TIME1
## "AD THROTLAG" below is surrounded by drawn-in parentheses.
                AD      THROTLAG        # COMPENSATE FOR ENGINE RESPONSE LAG
                MASK    LOW9            # MAKE SURE SMALL AND POSITIVE
                ZL
                EXTEND
                DV      Q
                EXTEND
                MP      PIF
                DDOUBL
                DDOUBL
                DXCH    FWEIGHT1
## Page 782
                CCS     PIF
                AD      ONE
                TCF     +2
                AD      ONE
                EXTEND
                MP      PIF
                EXTEND
                DV      BUF +1
                ADS     FWEIGHT1
#     COMPUTE DESIRED THRUST FOR DISPLAY AS A PERCENTAGE OF 10500 POUNDS.

                CA      FC
                EXTEND
                MP      100/3727
                TS      THRDISP         # FOR DISPLAY IN  N92

THDUMP          TC      RTNHOLD


#     FLATOUT THROTTLES UP THE DESCENT ENGINE, AND IS CALLED AS A BASIC SUBROUTINE.

FLATOUT         CAF     BIT13           # 4096 PULSES
WHATOUT         TS      PIFPSET         # USE PIFPSET SO FWEIGHT WILL BE ZERO
                CS      ZERO
                TS      FCOLD
                EXTEND
                QXCH    RTNHOLD
                TCF     DOIT


#     DO WHAT HAS TO BE DONE WHEN AGS HAS CONTROL.

ZILCH           CS      ZERO            # COME HERE WHEN IN AGS TO ZERO THE AUTO-
                TS      PIF             #   THROTTLE.  FIRST SET PIF AND FC SO THE
                TS      FC              #   FWEIGHT AND N92 DISPLAY COMPUTATIONS
                CS      FEXTRA          #   WILL COME OUT RIGHTER.  THEN GRAB A
                TCF     THROTOUT        #   BATCH OF NEG BITS AND RETURN.

#     MASSMULT SCALES ACCELERATION, ARRIVING IN A AND L IN UNITS OF 2(-4) M/CS/CS, TO FORCE IN PULSE UNITS.

MASSMULT        DXCH    MPAC
 +1             EXTEND
                QXCH    BUF
                TC      DMP
                ADRES   MASS
                TC      DMP             # LEAVES PROPERLY SCALED FORCE IM MPAC
                ADRES   SCALEFAC
                TC      TPAGREE
                CA      MPAC
                EXTEND
## Page 783
                BZF     +3
                CAF     POSMAX
                TC      BUF
                DXCH    MPAC +1
                TC      BUF


#           CONSTANTS:-

FEXTRA          =       BIT13           # FEXT        +5.13309020 E+4

/AF/CNST        DEC     .13107

100/3727        DEC     .02683

8SECS           DEC     +800

# *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
#  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
#   *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *

#   *  *  *  *  *  *  *  *  *  *  *  *  *
