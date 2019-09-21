### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RTB_OP_CODES.agc
## Purpose:     A section of Luminary revision 163.
##              It is part of the reconstructed source code for the first
##              (unflown) release of the flight software for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 14.
##              The code has been recreated from a reconstructed copy of
##              Luminary 173, as well as Luminary memos 157 amd 158.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 163 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 1385-1390
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Warning:     THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
##              AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
##              LUMINARY 163.
## Mod history: 2019-08-21 MAS  Created from Luminary 173.

## Page 1385
                BANK    22
                SETLOC  RTBCODES
                BANK

                EBANK=  XNB
                COUNT*  $$/RTB

#          LOAD TIME2, TIME1 INTO MPAC:

LOADTIME        EXTEND
                DCA     TIME2
                TCF     SLOAD2

#          CONVERT THE SINGLE PRECISION 2'S COMPLEMENT NUMBER ARRIVING IN MPAC (SCALED IN HALF-REVOLUTIONS) TO A
# DP 1'S COMPLEMENT NUMBER SCALED IN REVOLUTIONS.

CDULOGIC        CCS     MPAC
                CAF     ZERO
                TCF     +3
                NOOP
                CS      HALF

                TS      MPAC +1
                CAF     ZERO
                XCH     MPAC
                EXTEND
                MP      HALF
                DAS     MPAC
                TCF     DANZIG          # MODE IS ALREADY AT DOUBLE-PRECISION

#          FORCE TP SIGN AGREEMENT IN MPAC:

SGNAGREE        TC      TPAGREE
                TCF     DANZIG

#          CONVERT THE DP 1'S COMPLEMENT ANGLE SCALED IN REVOLUTIONS TO A SINGLE PRECISION 2'S COMPLEMENT ANGLE
# SCALED IN HALF-REVOLUTIONS.

1STO2S          TC      1TO2SUB
                CAF     ZERO
                TS      MPAC +1
                TCF     NEWMODE

#          DO 1STO2S ON A VECTOR OF ANGLES:

V1STO2S         TC      1TO2SUB         # ANSWER ARRIVES IN A AND MPAC.

                DXCH    MPAC +5
                DXCH    MPAC
                TC      1TO2SUB
## Page 1386
                TS      MPAC +2

                DXCH    MPAC +3
                DXCH    MPAC
                TC      1TO2SUB
                TS      MPAC +1

                CA      MPAC +5
                TS      MPAC

TPMODE          CAF     ONE             # MODE IS TP.
                TCF     NEWMODE

#          V1STO2S FOR 2 COMPONENT VECTOR. USED BY RR.

2V1STO2S        TC      1TO2SUB
                DXCH    MPAC +3
                DXCH    MPAC
                TC      1TO2SUB
                TS      L
                CA      MPAC +3
                TCF     SLOAD2

#          SUBROUTINE TO DO DOUBLING AND 1'S TO 2'S CONVERSION:

1TO2SUB         DXCH    MPAC            # FINAL MPAC +1 UNSPECIFIED.
                DDOUBL
                CCS     A
                AD      ONE
                TCF     +2
                COM                     # THIS WAS REVERSE OF MSU.

                TS      MPAC            # AND SKIP ON OVERFLOW.
                TC      Q

                INDEX   A               # OVERFLOW UNCORRECT AND IN MSU.
                CAF     LIMITS
                ADS     MPAC
                TC      Q

#          THE FOLLOWING ROUTINE INCREMENTS IN 2S COMPLEMENT THE REGISTER WHOSE ADDRESS IS IN BUF BY THE 1S COMPL.
# QUANTITY FOUND IN TEM2. THIS MAY BE USED TO INCREMENT DESIRED IMU AND OPTICS CDU ANGLES OR ANY OTHER 2S COMPL.
# (+0 UNEQUAL TO -0) QUANTITY. MAY BE CALLED BY BANKCALL/SWCALL.

CDUINC          TS      TEM2            # 1S COMPL.QUANT. ARRIVES IN ACC. STORE IT
                INDEX   BUF
                CCS     0               # CHANGE 2S COMPL. ANGLE(IN BUF)INTO 1S
                AD      ONE
                TCF     +4
                AD      ONE
## Page 1387
                AD      ONE             # OVERFLOW HERE IF 2S COMPL. IS 180 DEG.
                COM

                AD      TEM2            # SULT MOVES FROM 2ND TO 3D QUAD.(OR BACK)
                CCS     A               # BACK TO 2S COMPL.
                AD      ONE
                TCF     +2
                COM
                TS      TEM2            # STORE 14BIT QUANTITY WITH PRESENT SIGN
                TCF     +4
                INDEX   A               #  SIGN.
                CAF     LIMITS          # FIX IT,BY ADDING IN 37777 OR 40000
                AD      TEM2

                INDEX   BUF
                TS      0               # STORE NEW ANGLE IN 2S COMPLEMENT.
                TC      Q

## Page 1388
#          RTB TO TORQUE GYROS, EXCEPT FOR THE CALL TO IMUSTALL. ECADR OF COMMANDS ARRIVES IN X1.

PULSEIMU        INDEX   FIXLOC          # ADDRESS OF GYRO COMMANDS SHOULD BE IN X1
                CA      X1
                TC      BANKCALL
                CADR    IMUPULSE
                TCF     DANZIG

## Page 1389
#          THE SUBROUTINE  SIGNMPAC  SETS C(MPAC, MPAC +1) TO SIGN(MPAC).
# FOR THIS, ONLY THE CONTENTS OF MPAC ARE EXAMINED.    ALSO +0 YIELDS POSMAX AND -0 YIELDS NEGMAX.

# ENTRY MAY BE BY EITHER OF THE FOLLOWING:

# 1.       LIMIT THE SIZE OF MPAC ON INTERPRETIVE OVERFLOW:
# ENTRY:          BOVB
#                        SIGNMPAC

# 2.       GENERATE IN MPAC THE SIGNUM FUNCTION OF MPAC:
# ENTRY:          RTB
#                        SIGNMPAC

# IN EITHER CASE, RETURN IS TO  THE NEXT INTERPRETIVE INSTRUCTION IN THE CALLING SEQUENCE.

SIGNMPAC        EXTEND
                DCA     DPOSMAX
                DXCH    MPAC
                CCS     A
DPMODE          CAF     ZERO            # SETS MPAC +2 TO ZERO IN THE PROCESS
                TCF     SLOAD2 +2
                TCF     +1
                EXTEND
                DCS     DPOSMAX
                TCF     SLOAD2
                
#     RTB OP CODE NORMUNIT IS LIKE INTERPRETIVE INSTRUCTION UNIT, EXCEPT THAT IT CAN BE DEPENDED ON NOT TO BLOW
# UP WHEN THE VECTOR BEING UNITIZED IS VERY SMALL -- IT WILL BLOW UP WHEN ALL COMPONENTS ARE ZERO.   IF NORMUNIT
# IS USED AND THE UPPER ORDER HALVES OF ALL COMPONENTS ARE ZERO, THE MAGNITUDE RETURNED IN 36D WILL BE TOO LARGE
# BY A FACTOR OF 2(13) AND THE SQUARED MAGNITUDE RETURNED AT 34D WILL BE TOO BIG BY A FACTOR OF 2(26).

NORMUNX1        CAF     ONE
                TCF     NORMUNIT  +1
NORMUNIT        CAF     ZERO
                AD      FIXLOC
                TS      MPAC  +2
                TC      BANKCALL        # GET SIGN AGREEMENT IN ALL COMPONENTS
                CADR    VECAGREE
                CCS     MPAC
                TCF     NOSHIFT
                TCF     +2
                TCF     NOSHIFT
                CCS     MPAC  +3
                TCF     NOSHIFT
                TCF     +2
                TCF     NOSHIFT
                CCS     MPAC  +5
                TCF     NOSHIFT
                TCF     +2
                TCF     NOSHIFT
## Page 1390
                CA      MPAC  +1        # SHIFT ALL COMPONENTS LEFT 13
                EXTEND
                MP      BIT14
                DAS     MPAC            # DAS GAINS A LITTLE ACCURACY
                CA      MPAC  +4
                EXTEND
                MP      BIT14
                DAS     MPAC  +3
                CA      MPAC  +6
                EXTEND
                MP      BIT14
                DAS     MPAC  +5
                CAF     THIRTEEN
                INDEX   MPAC  +2
                TS      37D
OFFTUNIT        TC      POSTJUMP
                CADR    UNIT  +1        # SKIP THE "TC VECAGREE" DONE AT UNIT


NOSHIFT         CAF     ZERO
                TCF     OFFTUNIT -2


#  RTB  VECSGNAG   ...FORCES SIGN AGREEMENT OF VECTOR IN MPAC.

VECSGNAG        TC      BANKCALL
                CADR    VECAGREE
                TC      DANZIG
