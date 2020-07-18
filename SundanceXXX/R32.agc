### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    R32.agc
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

## Sundance 302

# 1)    ROUTINE NAME - TARGET DELTA V PROGRAM (R32).
# 2)    FUNCTIONAL DESCRIPTION - UPON ENTRY BY ASTRONAUT ACTION, R32 FLASHES DSKY REQUESTS TO THE ASTRONAUT
#       TO PROVIDE VIA DSKY (1) THE DELTA V TO BE APPLIED TO THE OTHER VEHICLE STATE VECTOR AND (2) THE
#       TIME (TIG) AT WHICH THE OTHER VEHICLE VELOCITY WAS CHANGED BY  EXECUTION OF A THRUSTING MANEUVER. THE
#       OTHER VEHICLE STATE VECTOR IS INTEGRATED TO TIG AND UPDATED BY THE ADDITION OF DELTA V (DELTA V HAVING
#       BEEN TRANSFORMED FROM LV TO REF COSYS).  USING INTEGRVS, THE   PROGRAM THEN INTEGRATES THE OTHER
# VEHICLE STATE VECTOR TO THE STATE VECTOR OF THIS VEHICLE, THUS INSURING THAT THE W-MATRIX AND BOTH VEHICLE
# STATES CORRESPOND TO THE SAME TIME.
# 3)    ERASABLE INITIALIZATION REQUIRED - NONE.
# 4)    CALLING SEQUENCES AND EXIT MODES - CALLED BY ASTRONAUT REQUEST THRU DSKY V 84 E.
#       EXITS BY TCF ENDOFJOB.
# 5)    OUTPUT - OTHER VEHICLE STATE VECTOR INTEGRATED TO TIG AND INCREMENTED BY DELTA V IN REF COSYS.
#       THE PUSHLIST CONTAINS THE MATRIX BY WHICH THE INPUT DELTA V MUST BE POST-MULTIPLIED TO CONVERT FROM LV
#       TO REF COSYS.
# 6)    DEBRIS - OTHER VEHICLE STATE VECTOR.
# 7)    SUBROUTINES CALLED - BANKCALL, GOXDSPF, CSMPREC (OR LEMPREC), ATOPCSM (OR ATOPLEM), INTSTALL, INTWAKE, PHASCHNG
#       INTPRET, INTEGRVS, AND MINIRECT.
# 8)    FLAG USE - MOONFLAG, CMOONFLAG, INTYPFLG, RASFLAG, AND MARKCTR.

                BANK    30
                SETLOC  R32LOC
                BANK

                COUNT*  $$/R32

                EBANK=  TIG

JOBR32          TC      UNK7766
                TC      INTPRET
                SET     EXIT
                        R32FLAG

                CAF     V06N84          # FLASH LAST DELTA V,
                TC      BANKCALL        # AND WAIT FOR KEYBOARD ACTION.
                CADR    GOMARKF
                TC      ENDR32
                TC      +2              # PROCEED
                TC      -5              # STORE DATA AND REPEAT FLASHING
                CAF     V06N84 +1       # FLASH VERB 06 NOUN 33, DISPLAY LAST TIG,
                TC      BANKCALL        # AND WAIT FOR KEYBOARD ACTION.
                CADR    GOMARKF
                TC      ENDR32
                TC      +2
                TC      -5
                TC      INTPRET         # RETURN TO INTERPRETIVE CODE
                DLOAD                   # SET D(MPAC)=TIG IN CSEC B28
                        TIG
                STCALL  TDEC1           # SET TDEC1=TIG FOR ORBITAL INTEGRATION
                        OTHPREC
COMPMAT         VLOAD   UNIT
                        RATT
                VCOMP                   # U(-R)
                STORE   24D             # U(-R) TO 24D
                VXV     UNIT            # U(-R) X V = U(V X R)
                        VATT
                STORE   18D
                VXV     UNIT            # U(V X R) X U(-R) = U((R X V) X R)
                        24D
                STOVL   12D
                        DELVOV
                VXM     VSL1            # V(MPAC)=DELTA V IN REFCOSYS
                        12D
                VAD
                        VATT
                STORE   6               # V(PD6)=VATT + DELTA V
                CALL                    # PREVENT WOULD-BE USER OF ORBITAL
                        INTSTALL        # INTEG FROM INTERFERING WITH UPDATING
                CALL
                        R32SUB1
                VLOAD   VSR*
                        6
                        0,2
                STOVL   VCV
                        RATT
                VSR*
                        0,2
                STODL   RCV
                        TIG
                STORE   TET
                CLEAR   DLOAD
                        INTYPFLG
                        TETTHIS
INTOTHIS        STCALL  TDEC1
                        INTEGRVS
                SET     CALL
                        NOUPFLAG
                        INTSTALL
                VLOAD
                        RATT1
                STORE   RRECT
                STODL   RCV
                        TAT
                STOVL   TET
                        VATT1
                CALL
                        MINIRECT
                EXIT

                CS      RASFLAG
                MASK    BIT2
                ADS     RASFLAG

                TC      INTPRET
                CALL
                        ATOPOTH
                SSP     EXIT
                        QPRET
                        OUT
                TC      BANKCALL        # PERMIT USE OF ORBITAL INTEGRATION
                CADR    INTWAKE
OUT             EXIT
ENDR32          TC      INTPRET
                CLEAR   EXIT
                        R32FLAG
                CAF     ZERO
                TS      MARKCTR         # CLEAR RR TRACKING MARK COUNTER
                TCF     ENDEXT

V06N84          NV      0684
                NV      0633
R32SUB1         AXT,2   SET
                        2
                        MOONFLAG        # SET MEANS MOON IS SPHERE OF INFLUENCE.
                BON     AXT,2
                        CMOONFLG        # SET MEANS PERM CM STATE IN LUNAR SPHERE.
                        QPRET
                        0
                CLEAR   RVQ
                        MOONFLAG



