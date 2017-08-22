### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    GIMBAL_LOCK_AVOIDANCE.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   p. 376
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-24 HG   Transcribed
##		2016-12-23 RSB	Proofed comment text with octopus/ProoferComments
##				but no errors found.
##		2017-08-22 RSB	Fixed comment-text typo identified in ZERLINA 56.

## Page 376
                BANK            15

                SETLOC          KALCMON1
                BANK


# DETECTING GIMBAL LOCK
LOCSKIRT        EQUALS          NOGIMLOC

NOGIMLOC        SET
                                CALCMAN3
WCALC           LXC,1           DLOAD*
                                RATEINDX                # CHOOSE THE DESIRED MANEUVER RATE
                                ARATE,1                 # FROM A LIST OF FOUR
                SR4             CALL                    # COMPUTE THE INCREMENTAL ROTATION MATRIX
                                DELCOMP                 # DEL CORRESPONDING TO A 1 SEC ROTATION
                                                        # ABOUT COF
                DLOAD*          VXSC
                                ARATE,1
                                COF
                STODL           BRATE                   # COMPONENT MANEUVER RATES 45 DEG/SEC
                                AM
                DMP             DDV*
                                ANGLTIME
                                ARATE,1
                SR
                                5
                STORE           TM                      # MANEUVER EXECUTION TIME SCALED AS T2
                SETGO
                                CALCMAN2                # 0(OFF) = CONTINUE MANEUVER
                                NEWANGL         +1      # 1(ON) = START MANEUVER
#          THE FOUR SELECTABLE FREE FALL MANEUVER RATES SELECTED BY
#          LOADING RATEINDX WITH 0,2,4,6, RESPECTIVELY


ARATE           2DEC            .0088888888             # = 0.2 DEG/SEC       $ 22.5 DEG/SEC
                2DEC            .0222222222             # = 0.5 DEG/SEC       $ 22.5 DEG/SEC
                2DEC            .0888888888             # = 2.0 DEG/SEC       $ 22.5 DEG/SEC
                2DEC            .4444444444             # = 10.0 DEG/SEC      $ 22.5 DEG/SEC

ANGLTIME        2DEC            .0001907349             # = 100B-19     FUDGE FACTOR TO CONVERT
                                                        # MANEUVER ANGLE TO MANEUVER TIME
