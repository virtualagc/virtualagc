### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RTB_OP_CODES.agc
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
## Reference:   pp. 342-347
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-06 HG   Transcribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 342
                BANK            15
#          LOAD TIME2, TIME1 INTO MPAC:

LOADTIME        EXTEND
                DCA             TIME2
                TCF             SLOAD2

#          CONVERT THE SINGLE PRECISION 2'S COMPLEMENT NUMBER ARRIVING IN MPAC (SCALED IN HALF-REVOLUTIONS) TO A
# DP 1'S COMPLEMENT NUMBER SCALED IN REVOLUTIONS.

CDULOGIC        CCS             MPAC
                CAF             ZERO
                TCF             +3
                NOOP
                CS              HALF

                TS              MPAC            +1
                CAF             ZERO
                XCH             MPAC
                EXTEND
                MP              HALF
                DAS             MPAC
                TCF             SLOAD2          +2      # C(A) = +0.

#          READ IMU CDUS INTO MPAC AS A VECTOR. ESPECIALLY USEFUL IN CONNECTION WITH SMNB, ETC.

READCDUS        INHINT
                CA              CDUY                    # IN ORDER Y Z X
                TS              MPAC
                CA              CDUZ
                TS              MPAC            +3
                CA              CDUX
                TCF             READPIPS        +6      # COMMON CODING.

#          READ THE PIPS INTO MPAC WITHOUT CHANGING THEM:

READPIPS        INHINT

                CA              PIPAX
                TS              MPAC
                CA              PIPAY
                TS              MPAC            +3
                CA              PIPAZ
                RELINT
                TS              MPAC            +5

                CAF             ZERO
                TS              MPAC            +1
                TS              MPAC            +4
                TS              MPAC            +6

## Page 343
VECMODE         CS              ONE
                TCF             NEWMODE

#          FORCE TP SIGN AGREEMENT IN MPAC:

SGNAGREE        TC              TPAGREE
                TCF             DANZIG

#          CONVERT THE DP 1'S COMPLEMENT ANGLE SCALED IN REVOLUTIONS TO A SINGLE PRECISION 2'S COMPLEMENT ANGLE
# SCALED IN HALF-REVOLUTIONS.

1STO2S          TC              1TO2SUB
                CAF             ZERO
                TS              MPAC            +1
                TCF             NEWMODE

#          DO 1STO2S ON A VECTOR OF ANGLES:

V1STO2S         TC              1TO2SUB                 # ANSWER ARRIVES IN A AND MPAC.

                DXCH            MPAC            +5
                DXCH            MPAC
                TC              1TO2SUB
                TS              MPAC            +2

                DXCH            MPAC            +3
                DXCH            MPAC
                TC              1TO2SUB
                TS              MPAC            +1

                CA              MPAC            +5
                TS              MPAC

TPMODE          CAF             ONE                     # MODE IS TP.
                TCF             NEWMODE

#          V1STO2S FOR 2 COMPONENT VECTOR, USED BY RR.

2V1STO2S        TC              1TO2SUB
                DXCH            MPAC            +3
                DXCH            MPAC
                TC              1TO2SUB
                TS              L

                CA              MPAC            +3
                TCF             SLOAD2

#          SUBROUTINE TO DO DOUBLING AND 1'S TO 2'S COMVERSION:

1TO2SUB         DXCH            MPAC                    # FINAL MPAC +1 UNSPECIFIED.
                DDOUBL

## Page 344
                CCS             A
                AD              ONE

                TCF             +2
                COM                                     # THIS WAS REVERSE OF MSU.

                TS              MPAC                    # AND SKIP ON OVERFLOW.
                TC              Q

                INDEX           A                       # OVERFLOW UNCORRECT AND IN MSU.
                CAF             LIMITS
                ADS             MPAC
                TC              Q

## Page 345
#          SUBROUTINE TO INCREMENT CDUS
INCRCDUS        CAF             LOCTHETA
                TS              BUF                     # PLACE ADRES(THETA) IN BUF.
                CAE             MPAC                    # INCREMENT IN 1S COMPL.
                TC              CDUINC

                INCR            BUF
                CAE             MPAC            +3

                TC              CDUINC

                INCR            BUF
                CAE             MPAC            +5
                TC              CDUINC

                TCF             VECMODE

LOCTHETA        ADRES           THETAD

#          THE FOLLOWING ROUTINE INCREMENTS IN 2S COMPLEMENT THE REGISTER WHOSE ADDRESS IS IN BUF BY THE 1S COMPL.
# QUANTITY FOUND IN TEM2. THIS MAY BE USED TO INCREMENT DESIRED IMU AND OPTICS CDU ANGLES OR ANY OTHER 2S COMPL.
# (+0 UNEQUAL TO -0) QUANTITY. MAY BE CALLED BY BANKCALL/SWCALL.

CDUINC          TS              TEM2                    # 1S COMPL.QUANT. ARRIVES IN ACC. STORE IT
                INDEX           BUF
                CCS             0                       # CHANGE 2S COMPL. ANGLE(IN BUF)INTO 1S
                AD              ONE
                TCF             +4
                AD              ONE
                AD              ONE                     # OVERFLOW HERE IF 2S COMPL. IS 180 DEG.
                COM

                AD              TEM2                    # ADD IN INCREMENT. WILL OVERFLOW IF RE-
                                                        # SULT MOVES FROM 2ND TO 3D QUAD.(OR BACK)
                CCS             A                       # BACK TO 2S COMPL.
                AD              ONE
                TCF             +2
                COM
                TS              TEM2                    # STORE 14BIT QUANTITY WITH PRESENT SIGN
                TCF             +4
                INDEX           A                       # OVERFLOW MEANS CORRECT 14BIT VALUE,WRONG
                                                        #  SIGN.
                CAF             LIMITS                  # FIX IT,BY ADDING IN 37777 OR 40000
                AD              TEM2

                INDEX           BUF
                TS              0                       # STORE NEW ANGLE IN 2S COMPLEMENT.
                TC              Q

## Page 346
#          RTB TO TORQUE GYROS, EXCEPT FOR THE CALL TO IMUSTALL. ECADR OF COMMANDS ARRIVES IN X1.

PULSEIMU        INDEX           FIXLOC                  # ADDRESS OF GYRO COMMANDS SHOULD BE IN X1
                CA              X1
                TC              BANKCALL
                CADR            IMUPULSE
                TCF             DANZIG

## Page 347
#          THE FOLLOWING ROUTINE IS USED ONLY IN BENCH TESTING THE RR.

RRSIM           TC              FIXDELAY
                DEC             50

RRSIM2          CAF             BIT2                    # SEE IF RR ECTR ENABLED.
                EXTEND
                RAND            12
                EXTEND
                BZF             RRSIM

                CA              TEM2                    # SAVE EXEC TEMPS SINCE IN RUPT.
                TS              RUPTREG1
                CAF             LOPTY
                XCH             BUF
                TS              RUPTREG2
                CA              LASTYCMD                # ECTR.
                DOUBLE
                EXTEND

                MP              RRSIMG
                TC              CDUINC
                INCR            BUF
                CA              OPTY                    # SHAFT CMD IS DIVIDED BY THE ABS VALUE OF
                EXTEND                                  # THE COS OF THE TRUNNION ANGLE.
                MSU             7                       # TO 1S COMPLEMENT.
                TC              SPCOS                   #                                 *
                EXTEND                                  # SPCOS NOW GIVES COS SCALED AT 1 *
                MP              BIT14                   #     (A DAP GROUP FIX)           *
                CCS             A
                TCF             +3
                TCF             +2
                TCF             +1
                AD              ONE
                TS              ITEMP1

                CA              LASTXCMD                # SHAFT RATE DEPENDS ON TRUNNION.
                EXTEND
                MP              RRSIMG
                EXTEND
                DV              ITEMP1
                TC              CDUINC
                CA              RUPTREG1

                TS              TEM2
                CA              RUPTREG2
                TS              BUF
                TCF             RRSIM

LOPTY           ADRES           OPTY
RRSIMG          DEC             .59259
