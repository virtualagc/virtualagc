### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    GIMBAL_LOCK_AVOIDANCE.agc
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
## Reference:   p.  369
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##		2017-08-22 RSB	Transcribed.

## Page 369
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
