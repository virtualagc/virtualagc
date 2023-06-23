### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RTB_OP_CODES.agc
## Purpose:     A section of Sundial E.
##              It is part of the reconstructed source code for the final
##              release of the Block II Command Module system test software. No
##              original listings of this program are available; instead, this
##              file was created via disassembly of dumps of Sundial core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-22 MAS  Created from Aurora 12.
##              2023-06-30 MAS  Updated for Sundial E.

                SETLOC  ENDPINS1

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
                TCF     SLOAD2 +2       # C(A) = +0.

#          READ IMU CDUS INTO MPAC AS A VECTOR. ESPECIALLY USEFUL IN CONNECTION WITH SMNB, ETC.

READCDUS        INHINT
                CA      CDUY            # IN ORDER Y Z X
                TS      MPAC
                CA      CDUZ
                TS      MPAC +3
                CA      CDUX
                TCF     READPIPS +6     # COMMON CODING.

#          READ THE PIPS INTO MPAC WITHOUT CHANGING THEM:

READPIPS        INHINT
                CA      PIPAX
                TS      MPAC
                CA      PIPAY
                TS      MPAC +3
                CA      PIPAZ
                RELINT
                TS      MPAC +5

                CAF     ZERO
                TS      MPAC +1
                TS      MPAC +4
                TS      MPAC +6

VECMODE         CS      ONE
                TCF     NEWMODE

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
                TS      MPAC +2

                DXCH    MPAC +3
                DXCH    MPAC
                TC      1TO2SUB
                TS      MPAC +1

                CA      MPAC +5
                TS      MPAC

                CAF     ONE             # MODE IS TP.
                TCF     NEWMODE

#          V1STO2S FOR 2 COMPONENT VECTOR, USED BY RR.

2V1STO2S        TC      1TO2SUB
                DXCH    MPAC +3
                DXCH    MPAC
                TC      1TO2SUB
                TS      L
                CA      MPAC +3
                TCF     SLOAD2

#          SUBROUTINE TO DO DOUBLING AND 1'S TO 2'S COMVERSION:

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

#          SUBROUTINE TO INCREMENT CDUS
INCRCDUS        CAF     LOCTHETA
                TS      BUF             # PLACE ADRES(THETA) IN BUF.
                CAE     MPAC            # INCREMENT IN 1S COMPL.
                TC      CDUINC

                INCR    BUF
                CAE     MPAC +3
                TC      CDUINC

                INCR    BUF
                CAE     MPAC +5
                TC      CDUINC

                TCF     VECMODE

LOCTHETA        ADRES   THETAD

#          THE FOLLOWING ROUTINE INCREMENTS IN 2S COMPLEMENT THE REGISTER WHOSE ADDRESS IS IN BUF BY THE 1S COMPL.
# QUANTITY FOUND IN TEM2. THIS MAY BE USED TO INCREMENT DESIRED IMU AND OPTICS CDU ANGLES OR ANY OTHER 2S COMPL.
# (+0 UNEQUAL TO -0) QUANTITY. MAY BE CALLED BY BANKCALL/SWCALL.

CDUINC          TS      TEM2            # 1S COMPL.QUANT. ARRIVES IN ACC. STORE IT
                INDEX   BUF
                CCS     0               # CHANGE 2S COMPL. ANGLE(IN BUF)INTO 1S
                AD      ONE
                TCF     +4
                AD      ONE
                AD      ONE             # OVERFLOW HERE IF 2S COMPL. IS 180 DEG.
                COM

                AD      TEM2            # ADD IN INCREMENT. WILL OVERFLOW IF RE-
                                        # SULT MOVES FROM 2ND TO 3D QUAD.(OR BACK)
                CCS     A               # BACK TO 2S COMPL.
                AD      ONE
                TCF     +2
                COM
                TS      TEM2            # STORE 14BIT QUANTITY WITH PRESENT SIGN
                TCF     +4
                INDEX   A               # OVERFLOW MEANS CORRECT 14BIT VALUE,WRONG
                                        #  SIGN.
                CAF     LIMITS          # FIX IT,BY ADDING IN 37777 OR 40000
                AD      TEM2

                INDEX   BUF
                TS      0               # STORE NEW ANGLE IN 2S COMPLEMENT.
                TC      Q

#          RTB TO TORQUE GYROS, EXCEPT FOR THE CALL TO IMUSTALL. ECADR OF COMMANDS ARRIVES IN X1.

PULSEIMU        INDEX   FIXLOC          # ADDRESS OF GYRO COMMANDS SHOULD BE IN X1
                CA      X1
                TC      BANKCALL
                CADR    IMUPULSE
                TCF     DANZIG

PIPREAD         INHINT
                CAF     ZERO
                XCH     PIPAX
                TS      MPAC
                CAF     ZERO
                XCH     PIPAY
                TS      MPAC +3
                CAF     ZERO
                XCH     PIPAZ
                RELINT
                TS      MPAC +5

                CAF     ZERO
                TS      MPAC +1
                TS      MPAC +4
                TS      MPAC +6

                TCF     VECMODE

# TRANSPSE COMPUTES THE TRANSPOSE OF A MATRIX (TRANSPOSE = INVERSE OF ORTHOGONAL TRANSFORMATION).

# THE INPUT IS A MATRIX DEFINING COORDINATE SYSTEM A WITH RESPECT TO COORDINATE SYSTEM B STORED IN STARAD THRU
# STARAD +17D.

# THE OUTPUT IS A MATRIX DEFINING COORDINATE SYSTEM B WITH RESPECT TO COORDINATE SYSTEM A STORED IN STARAD THRU
# STARAD +17D.

TRANSPSE        DXCH    STARAD +2       # PUSHDOWN NONE
                DXCH    STARAD +6
                DXCH    STARAD +2

                DXCH    STARAD +4
                DXCH    STARAD +12D
                DXCH    STARAD +4

                DXCH    STARAD +10D
                DXCH    STARAD +14D
                DXCH    STARAD +10D
                TCF     DANZIG

# EACH ROUTINE TAKES A 3X3 MATRIX STORED IN DOUBLE PRECISION IN A FIXED AREA OF ERASABLE MEMORY AND REPLACES IT
# WITH THE TRANSPOSE MATRIX. TRANSP1 USES LOCATIONS XNB+0,+1 THROUGH XNB+16D, 17D AND TRANSP2 USES LOCATIONS
# XNB1+0,+1 THROUGH XNB1+16D, 17D. EACH MATRIX IS STORED BY ROWS.

                EBANK=  XNB

TRANSP1         DXCH    XNB +2
                DXCH    XNB +6
                DXCH    XNB +2

                DXCH    XNB +4
                DXCH    XNB +12D
                DXCH    XNB +4

                DXCH    XNB +10D
                DXCH    XNB +14D
                DXCH    XNB +10D
                TCF     DANZIG


                EBANK=  XNB1

TRANSP2         DXCH    XNB1 +2
                DXCH    XNB1 +6
                DXCH    XNB1 +2

                DXCH    XNB1 +4
                DXCH    XNB1 +12D
                DXCH    XNB1 +4

                DXCH    XNB1 +10D
                DXCH    XNB1 +14D
                DXCH    XNB1 +10D
                TCF     DANZIG

ENDRTBSS        EQUALS
