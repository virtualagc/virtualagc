### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    THROTTLE_CONTROL_ROUTINES.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.

## Sundance 292

                BANK    31
                SETLOC  FTHROT
                BANK
                EBANK=  PIF
                COUNT*  $$/THROT

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# HERE FC, DESIRED THRUST, AND FP, PRESENT THRUST, UNWEIGHTED, ARE COMPUTED.

THROTTLE        CA      ABDELV          # COMPUTE PRESENT ACCELERATION IN UNITS OF
                EXTEND                  # 2(-4) M/CS/CS, SAVING SERVICER TROUBLE
                MP      /AF/CNST
 +3             EXTEND
                QXCH    RTNHOLD
AFDUMP          TC      MASSMULT
                DXCH    FP              # FP = PRESENT THRUST
                EXTEND
                DCA     /AFC/
                TC      MASSMULT
                DXCH    FCODD           # FCODD = WHAT IT IS GOING TO GET

# IF IT HAS BEEN LESS THAN 3 SECONDS SINCE THE LAST THROTTLING, AUGMENT FP USING THE FWEIGHT CALCULATED THEN.

                CS      TTHROT          # THIS CODING ASSUMES A FLATOUT WITHIN
                AD      TIME1           #   80 SECONDS BEFORE FIRST THROTTLE CALL
                MASK    POSMAX
                COM
                AD      3SECS
                EXTEND
                BZMF    WHERETO         # BRANCH IF (TIME1-TTHROT +1) > 3 SECONDS
                EXTEND
                DCA     FWEIGHT
                DAS     FP

#     THIS LOGIC DETERMINES THE THROTTLING IN THE REGION 10% - 94%.  THE MANUAL THROTTLE, NOMINALLY SET AT
# MINIMUM BY ASTRONAUT OR MISSION CONTROL PROGRAMS, PROVIDES THE LOWER BOUND.  A STOP IN THE THROTTLE HARDWARE
# PROVIDES THE UPPER.

WHERETO         CS      ZERO            # INITIALIZE PIFPSET
                TS      PIFPSET
                CS      HIGHCRIT
                AD      FCOLD
                EXTEND
                BZMF    LOWFCOLD        # BRANCH IF FCOLD < OR = HIGHCRIT
                CS      LOWCRIT
                AD      FCODD
                EXTEND
                BZMF    FCOMPSET        # BRANCH IF FC < OR = LOWCRIT
                CA      FP              # SEE NOTE 1
                TCF     FLATOUT1

FCOMPSET        CS      FMAXODD         # SEE NOTE 2
                AD      FP
                TCF     FLATOUT2

LOWFCOLD        CS      HIGHCRIT
                AD      FCODD
                EXTEND
                BZMF    DOPIF           # BRANCH IF FC < OR = HIGHCRIT

                CA      FMAXPOS         # NO:  THROTTLE-UP
FLATOUT1        DXCH    FCODD
                CA      FEXTRA
FLATOUT2        TS      PIFPSET

# NOTE 1        FC IS SET EQUAL TO FP SO PIF WILL BE ZERO.  THIS IS DESIRABLE
#               AS THERE IS ACTUALLY NO THROTTLE CHANGE.
#
# NOTE2         HERE, SINCE WE ARE ABOUT TO RETURN TO THE THROTTLEABLE REGION
#               (BELOW 55%) THE QUANTITY -(FMAXODD-FP) IS COMPUTED AND PUT
#               INTO PIFPSET TO COMPENSATE FOR THE DIFFERENCE BETWEEN THE
#               NUMBER OF BITS CORRESPONDING TO FULL THROTTLE (FMAXODD) AND THE
#               NUMBER CORRESPONDING TO ACTUAL THRUST (FP).  THUS THE TOTAL
#               THROTTLE COMMAND PIF = FC - FP - (FMAXODD - FP) = FC - FMAXODD.

DOPIF           TC      FASTCHNG	# RESTART PROTECTION
                EXTEND
                DCA     FCODD
                TS      FCOLD
                DXCH    PIF
                EXTEND
                DCS     FP
                DAS     PIF             # PIF = FC - FP, NEVER EQUALS +0

DOIT            CA      PIF
                AD      PIFPSET         # ADD IN PIFPSET, WITHOUT CHANGING PIF
                TS      PSEUDO55
                TS      THRUST
                CAF     BIT4
                EXTEND
                WOR     CHAN14
                CA      TIME1
                TS      TTHROT

# SINCE /AF/ IS NOT AN INSTANTANEOUS ACCELERATION, BUT RATHER AN "AVERAGE" OF THE ACCELERATION LEVELS DURING
# THE PRECEEDING PIPA INTERVAL, AND SINCE FP IS COMPUTED DIRECTLY FROM /AF/, FP IN ORDER TO CORRESPOND TO THE
# ACTUAL THRUST LEVEL AT THE END OF THE INTERVAL MUST BE WEIGHTED BY
#
#                 PIF(PPROCESS + TL)     PIF /PIF/
#       FWEIGHT = ------------------ + -------------
#                      PGUID           2 PGUID FRATE
#
# WHERE PPROCESS IS THE TIME BETWEEN PIPA READING AND THE START OF THROTTLING, PGUID IS THE GUIDANCE PERIOD, AND
# FRATE IS THE THROTTLING RATE (32 UNITS PER CENTISECOND).  PGUID IS ASSUMED TO BE 2 SECONDS.  THE "TL" IN THE
# FIRST TERM REPRESENTS THE ENGINE'S RESPONSE LAG.  HERE FWEIGHT IS COMPUTED FOR USE NEXT PASS.

                CA      4SECS
                TS      Q
                CS      PIPTIME +1      # TIME OF LAST PIPA READING
                AD      TIME1
                AD      THROTLAG        # COMPENSATE FOR ENGINE RESPONSE LAG
                MASK    LOW8            # MAKE SURE SMALL AND POSITIVE
                ZL
                EXTEND
                DV      Q
                EXTEND
                MP      PIF
                DOUBLE
                DXCH    FWEIGHT
                CA      2.PG.FRT
                TS      Q
                CCS     PIF
                AD      ONE
                TCF     +2
                AD      ONE
                EXTEND
                MP      PIF
                EXTEND
                DV      Q
                ZL
                DAS     FWEIGHT

THDUMP          TC      RTNHOLD

# FLATOUT THROTTLES UP THE DESCENT ENGINE, AND IS CALLED AS A BASIC SUBROUTINE.

FLATOUT         CAF     BIT13           # 4096 PULSES
WHATOUT         TS      PIFPSET         # USE PIFPSET SO FWEIGHT WILL BE ZERO
                CS      ZERO
                TS      PIF
                EXTEND
                QXCH    RTNHOLD
                TCF     DOIT

# MASSMULT SCALES ACCELERATION, ARRIVING IN A AND L IN UNITS OF 2(-4) M/CS/CS, TO FORCE IN PULSE UNITS.

MASSMULT        EXTEND
                QXCH    BUF
                EXTEND
                MP      MASS            # LEAVES ODDLY SCALED FORCE IN A AND L
                DXCH    MPAC
                TC      DMP             # LEAVES PROPERLY SCALED FORCE IM MPAC
                ADRES   SCALEFAC
                DXCH    MPAC +1
                TC      BUF

# CONSTANTS:-

FMAXMAX         DEC     +3882
FMAXODD         DEC     +3866           # THROTTLE SATURATION THRESHOLD
FMAXPOS         DEC     +3648           # FMAX    43245 NEWTONS
HIGHCRIT        DEC     2446
LOWCRIT         DEC     2135
FEXTRA          =       BIT7
DEC438          DEC     438
THROTLAG        DEC     20              # EMPIRICALLY DETERMINED THROTTLE LAG TIME
2.PG.FRT        DEC     12800
/AF/CNST        DEC     .13107
SCALEFAC        2DEC    51.947 B-12     # SCALES A (AT 2(-4) M/CS/CS) TIMES MASS
                                        # (AT 2(16) KGS. ) TO PULSE UNITS.

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
