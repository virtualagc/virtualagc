### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    R63.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 350-353
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-24 HG   Transcribed
##              2016-12-07 HG   Fix P00 -> POO (appears only in comments)
##                              revert above changes
##		2016-12-23 RSB	Proofed comment text with octopus/ProoferComments
##				and fixed all errors found.

## Page 350
# SUBROUTINE NAME:    V89CALL
# MOD NO:  0                       DATE: 9 JAN 1968
# MOD BY:  DIGITAL DEVEL GROUP     LOG SECTION: R63

# FUNCTIONAL DESCRIPTION:

# CALLED BY VERB 89 ENTER DURING P00. PRIO 10 USED.  CALCULATES AND
# DISPLAYS FINAL FDAI BALL ANGLES TO POINT LM +X OR +Z AXIS AT CSM.

# 1. KEY IN V 89 E ONLY IF IN PROG 00. IF NOT IN P00, OPERATOR ERROR AND
# EXIT R63, OTHERWISE CONTINUE.

# 2. IF IN P00, DO IMU STATUS CHECK ROUTINE (R02BOTH). IF IMU ON AND ITS
# ORIENTATION KNOWN TO LGC, CONTINUE.

# 3. FLASH DISPLAY V 04 N 06.  R2 INDICATES WHICH SPACECRAFT AXIS IS TO
# BE POINTED AT CSM.  INITIAL CHOICE IS PREFERRED (+Z) AXIS (R2=1).
# ASTRONAUT CAN CHANGE TO (+X) AXIS (R2 NOT = 1) BY V 22 E 2 E.  CONTINUE
# AFTER KEYING IN PROCEED.

# 4. BOTH VEHICLE STATE VECTORS UPDATED BY CONIC EQS.

# 5. HALF MAGNITUDE UNIT LOS VECTOR (IN STABLE MEMBER COORDINATES) AND
# HALF MAGNITUDE UNIT SPACECRAFT AXIS VECTOR (IN BODY COORDINATES)
# PREPARED FOR VECPOINT.

# 6. GIMBAL ANGLES FROM VECPOINT TRANSFORMED INTO FDAI BALL ANGLES BY
# BALLANGS. FLASH DISPLAY V 06 N 18 AND AWAIT RESPONSE.

# 7. RECYCLE - RETURN TO STEP 4.
#    TERMINATE - EXIT R63.
#    PROCEED - RESET 3AXISFLG AND CALL R60LEM FOR ATTITUDE MANEUVER.


# CALLING SEQUENCE:  V 89 E.
#
# SUBROUTINES CALLED:  CHKPOOH, R02BOTH, GOXDSPF, CSMCONIC, LEMCONIC,
#                      VECPOINT, BALLANGS, R60LEM.

# NORMAL EXIT MODES:  TC ENDEXT

# ALARMS:  1. OPERATOR ERROR IF NOT IN P00.
#          2. PROGRAM ALARM IF IMU IS OFF.
#          3. PROGRAM ALARM IF IMU ORIENTATION IS UNKNOWN.

# OUTPUT:  NONE

# ERASABLE INITIALIZATION REQUIRED:  NONE

# DEBRIS:  OPTION1, +1, TDEC1, POINTVSM, SCAXIS, CPHI, CTHETA, CPSI,

## Page 351
#          3AXISFLG.

                EBANK=          RONE
                BANK            32
                SETLOC          BAWLANGS
                BANK


                COUNT*          $$/R63
V89CALL         TC              BANKCALL                # IMU STATUS CHECK. RETURNS IF ORIENTATION
                CADR            R02BOTH                 # KNOWN. ALARMS IF NOT.
                CAF             THREE                   # ALLOW ASTRONAUT TO SELECT DESIRED
                TS              OPTIONX                 # TRACKING ATTITUDE AXIS.
                CAF             ONE
                TS              OPTIONX         +1
                CAF             VB04N12                 # V 04 N 12
                TC              BANKCALL
                CADR            GOFLASH
                TC              ENDEXT                  # TERMINATE
                TC              +2                      # PROCEED
                TC              -5                      # DATA IN. OPTION1+1 = 1 FOR Z AXIS
V89RECL         TC              INTPRET                 #                   = 2 FOR X AXIS
                RTB             DAD
                                LOADTIME                # READ PRESENT TIME
                                DP1MIN
                STORE           TSTART82                # SAVE TIME FOR LEMCONIC CALL
                STCALL          TDEC1                   # STORE TIME FOR CSMCONIC CALL
                                CSMCONIC                # CSM STATE VECTOR UPDATE
                VLOAD                                   # CSMCONIC LEFT R VECTOR IN RATT
                                RATT
                STODL           RONE                    # SAVE FOR LINE OF SIGHT (LOS) COMPUTATION
                                TSTART82
                STCALL          TDEC1                   # STORE TIME FOR LEMCONIC CALL
                                LEMCONIC                # LEM STATE VECTOR UPDATE
                VLOAD           VSU                     # CSM POSITION - LEM POSITION = LOS
                                RONE                    # LOS VECTOR LEFT IN MPAC
                                RATT
                MXV             RTB                     # (REFSMMAT X LOS). TRANSFORMS LOS FROM
                                REFSMMAT                # REFERENCE COORD TO STAB MEMB COORD.
                                NORMUNIT
                STORE           POINTVSM                # STORE LOS FOR VECPOINT CALL
                EXIT
                CS              OPTIONX         +1      # 1 FOR Z AXIS. 2 FOR X AXIS.
                AD              ONE
                EXTEND
                BZF             ALINEZ
ALINEX          TC              INTPRET                 # X AXIS ALIGNMENT
                VLOAD
                                UNITX                   # READ (.5, 0, 0)

## Page 352
V89CALL1        STCALL          SCAXIS                  # STORE SELECTED ALIGNMENT AXIS
                                VECPOINT                # PUTS DESIRED GIM ANG (OG,IG,MG) IN TMPAC
                STORE           CPHI                    # STORE GIMBAL ANGLES FOR BALLANGS CALL.
                EXIT
                TC              BANKCALL
                CADR            BALLANGS                # PUTS DESIRED BALL ANGLES IN FDAIX,Y,Z
                CAF             VB06N18                 # V 06 N 18
                TC              BANKCALL                # NOUN 18 REFERS TO FDAIX,Y,Z
                CADR            GOFLASH
                TC              ENDEXT                  # TERMINATE
                TC              +2                      # PROCEED
                TC              V89RECL                 # RECYCLE
                TC              DOWNFLAG                # RESET 3 AXIS FLAG
                ADRES           3AXISFLG                # RESET BIT6 FLAG WORD 5
                TC              BANKCALL                # PERFORMS LEM MANEUVER TO ALIGN SELECTED
                CADR            R60LEM                  # SPACECRAFT AXIS TO CSM.
                TCF             ENDEXT                  # TERMINATE R63


ALINEZ          TC              INTPRET                 # Z AXIS ALIGNMENT
                VLOAD           GOTO
                                UNITZ                   # READ (0, 0, .5)
                                V89CALL1


VB04N12         VN              412
VB06N18         VN              0618

## Page 353
DP1MIN          2DEC            6000
