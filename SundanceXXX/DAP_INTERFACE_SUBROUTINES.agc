### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    DAP_INTERFACE_SUBROUTINES.agc
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

                BANK    20
                SETLOC  DAPS3
                BANK

                EBANK=  CDUXD
                COUNT*  $$/DAPIF

# MOD 0         DATE    11/15/66        BY GEORGE W. CHERRY
# MOD 1                  1/23/67        MODIFICATION BY PETER ADLER
#
# FUNCTIONAL DESCRIPTION
#       HEREIN ARE A COLLECTION OF SUBROUTINES WHICH ALLOW MISSION CONTROL PROGRAMS TO CONTROL THE MODE
#       AND INTERFACE WITH THE DAP.
#
# CALLING SEQUENCES
#       IN INTERRUPT OR WITH INTERRUPT INHIBITED
#               TC      IBNKCALL
#               FCADR   ROUTINE
#       IN A JOB WITHOUT INTERRUPT INHIBITED
#               INHINT
#               TC      IBNKCALL
#               FCADR   ROUTINE
#               RELINT
#
# OUTPUT
#       SEE INDIVIDUAL ROUTINES BELOW
#
# DEBRIS
#       A, L, AND SOMETIMES MDUETEMP                    ODE     NOT IN PULSES MODE

# SUBROUTINE NAMES:
#       SETMAXDB, SETMINDB, RESTORDB, PFLITEDB
# MODIFIED:     30 JANUARY 1968 BY P S WEISSMAN TO CREATE RESTORDB.
# MODIFIED:     1 MARCH 1968 BY P S WEISSMAN TO SAVE EBANK AND CREATE PFLITEDB
#
# FUNCTIONAL DESCRIPTION:
#       SETMAXDB - SET DEADBAND TO 5.0 DEGREES
#       SETMINDB - SET DEADBAND TO 0.3 DEGREE
#       RESTORDB - SET DEADBAND TO MAX OR MIN ACCORDING TO SETTING OF DBSELECT BIT OF DAPBOOLS
#       PFLITEDB - SET DEADBAND TO 1.0 DEGREE AND ZERO THE COMMANDED ATTITUDE CHANGE AND COMMANDED RATE
#
#       ALL ENTRIES SET UP A NOVAC JOB TO DO 1/ACCS SO THAT THE TJETLAW SWITCH CURVES ARE POSITIONED TO
#       REFLECT THE NEW DEADBAND.  IT SHOULD BE NOTED THAT THE DEADBAND REFERS TO THE ATTITUDE IN THE P-, U-, AND V-AXES.
#
# SUBROUTINE CALLED:    NOVAC
#
# CALLING SEQUENCE:     SAME AS ABOVE
#                       OR      TC RESTORDB +1    FROM ALLCOAST
#
# DEBRIS:               A, L, Q, RUPTREG1, (ITEMPS IN NOVAC)
#
# DAPBOOLS BITS AND NAMES

AUTRATE1        EQUALS  BIT1            # THESE FLAGS ARE USED TOGETHER TO INIDCAT
AUTRATE2        EQUALS  BIT2            # ASTRONAUT-CHOSEN KALCMANU MANEUVER RATES
                                        # (0,0)=(BIT2,BIT1)= 0.2 DEG/SEC
                                        # (0,1)=  0.5 DEG/SEC
ACCSOKAY        EQUALS  BIT3            # VALUES FROM 1/ACCS USABLE FLAG
DBSELECT        EQUALS  BIT4            # DAP DEADBAND SELECT FLAG
AORBSYST        EQUALS  BIT5            # P-AXIS ROTATION JET SYSTEM (A OR B) FLAG
ULLAGER         EQUALS  BIT6            # INTERNAL ULLAGE REQUEST FLAG
RHCSCALE        EQUALS  BIT7            # RHC SCALE SELECT FLAG
DRIFTBIT        EQUALS  BIT8            # USE OFFSET ACCELERATION FLAG
XOVINHIB        EQUALS  BIT9            # X-AXIS OVERRIDE PERMITTED FLAG
AORBTRAN        EQUALS  BIT10           # X-TRANSLATION JET SYSTEM (A OR B) FLAG
ACC4OR2X        EQUALS  BIT11           # 2 OR 4 JET Z-TRANSLATION MODE FLAG
OURRCBIT        EQUALS  BIT12           # INTERNAL DAP RATE COMMAND ACTIVITY FLAG
CSMDOCKD        EQUALS  BIT13           # CSM DOCKED TO LM FLAG
USEQRJTS        EQUALS  BIT14           # TRIM GIMBAL FLAG
PULSES          EQUALS  BIT15           # MINIMUM IMPULSE RHC MODE FLAG


RESTORDB        CAE     DAPBOOLS        # DETERMINE CREW-SELECTED DEADBAND.
                MASK    DBSELECT
                EXTEND
                BZF     SETMINDB

SETMAXDB        CAF     WIDEDB          # SET 5 DEGREE DEADBAND.
 +1             TS      DB

                EXTEND                  # SET UP JOB TO RE-POSITION SWITCH CURVES.
                QXCH    RUPTREG1
CALLACCS        CAF     PRIO27
                TC      NOVAC
                EBANK=  AOSQ
                2CADR   1/ACCJOB

                TC      RUPTREG1        # RETURN TO CALLER.

SETMINDB        CAF     NARROWDB        # SET 0.3 DEGREE DEADBAND.
                TCF     SETMAXDB +1

PFLITEDB        EXTEND                  # THE RETURN FROM CALLACCS IS TO RUPTREG1.
                QXCH    RUPTREG1
                TC      ZATTEROR        # ZERO THE ERRORS AND COMMANDED RATES.
                CAF     POWERDB         # SET DB TO 1.0 DEG.
                TS      DB
                TCF     CALLACCS        # SET UP 1/ACCS AND RETURN TO CALLER.

POWERDB         DEC     .02222          # 1.0 DEGREE SCALED AT 45.

ZATTEROR        CAF     EBANK6
                XCH     EBANK
                TS      L               # SAVE CALLERS EBANK IN L.
                CAE     CDUX
                TS      CDUXD
                CAE     CDUY
                TS      CDUYD
                CAE     CDUZ
                TS      CDUZD
                TCF     STOPRATE +3

STOPRATE        CAF     EBANK6
                XCH     EBANK
                TS      L               # SAVE CALLERS EBANK IN L.
 +3             CAF     ZERO
                TS      OMEGAPD
                TS      OMEGAQD
                TS      OMEGARD
                TS      DELCDUX
                TS      DELCDUY
                TS      DELCDUZ
                TS      DELPEROR
                TS      DELQEROR
                TS      DELREROR
                LXCH    EBANK           # RESTORE CALLERS EBANK.
                TC      Q

# SUBROUTINE NAME:      ALLCOAST
# WILL BE CALLED BY FRESH STARTS AND ENGINE OFF ROUTINES.               .
#
# CALLING SEQUENCE:     (SAME AS ABOVE)
#
# EXIT:                 RETURN TO Q.
#
# SUBROUTINES CALLED:   STOPRATE, RESTORDB, NOVAC
#
# ZERO:                 (FOR ALL AXES) AOS, ALPHA, AOSTERM, OMEGAD, DELCDU, DELEROR
#
# OUTPUT:               DRIFTBIT/DAPBOOLS, DB, JOB TO DO 1/ACCS
#
# DEBRIS:               A, L, Q, RUPTREG1, RUPTREG2, (ITEMPS IN NOVAC)

ALLCOAST        CAF     EBANK6
                XCH     EBANK
                TS      ITEMP6
                CS      ZERO
                TS      AOSQ
                TS      AOSQ +1
                TS      AOSR
                TS      AOSR +1
                TS      ALPHAQ          # FOR DOWNLIST.
                TS      ALPHAR
                TS      AOSQTERM
                TS      AOSRTERM
                CA      ITEMP6
                TS      EBANK           # RESTORE EBANK (EBANK6 NO LONGER NEEDED)

                CS      DAPBOOLS        # SET UP DRIFTBIT
                MASK    DRIFTBIT
                ADS     DAPBOOLS
                TCF     RESTORDB +1     # RESTORE DEADBANK TO CREW-SELECTED VALUE.

