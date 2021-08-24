### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    Q,R-AXES_RCS_AUTOPILOT.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.



                BANK    17
                SETLOC  DAPS2
                BANK

                EBANK=  CDUXD

                COUNT*  $$/DAPQR

CALLQERR        TC      QERRCALC

Q,RORGTS        CCS     COTROLER        # CHOOSE CONTROL SYSTEM FOR THIS DAP PASS:
                TCF     GOTOGTS         #   GTS (ALTERNATES WITH RCS WHEN DOCKED)
                TCF     TRYGTS          #   GTS IF ALLOWED, OTHERWISE RCS
RCS             CAF     ZERO            #   RCS (TRYGTS MAY BRANCH TO HERE)
                TS      COTROLER

                DXCH    EDOTQ
                TC      ROT45DEG
                DXCH    OMEGAU

# X - TRANSLATION:
#
# INPUT:        BITS 7,8 OF CH31 (TRANSLATION CONTROLLER)
#               ULLAGER
#               APSFLAG, DRIFTBIT
#               ACC40R2X, ACRBTRAN
#
# OUTPUT:       NEXTU, NEXTV    CODES OF TRANSLATION FOR AFTER ROTATION
#               SENSETYP        TELL ROTATION DIRECTION AND DESIRE
#
# X-TRANS POLICIES ARE EITHER 4 JETS OR A DIAGONAL PAIR.  IN 2-JET TRANSLATION THE SYSTEM IS SPECIFIED.  A FAILURE
# WILL OVERRIDE THIS SPECIFICATION.  AN ALARM RESULTS WHEN NO POLICY IS AVAILABLE BECAUSE OF FAILURES.

SENSEGET        CA      BIT7            # INPUT BITS OVERRIDE THE INTERNAL BITS
                EXTEND                  # SENSETYP WILL NOT OPPOSE ANYTRANS
                RAND    CHAN31
                EXTEND
                BZF     +XORULGE
                CA      BIT8
                EXTEND
                RAND    CHAN31
                EXTEND
                BZF     -XTRANS

                CA      ULLAGER
                MASK    DAPBOOLS
                CCS     A
                TCF     +XORULGE

                CAF     ZERO
                TS      ANYTRANS
                TS      SENSETYP

                CA      BIT2            # DPS (INCLUDING DOCKED) OR APS?
                EXTEND
                RAND    CHAN30
                EXTEND
                BZF     TSENSE +1

                CAF     DRIFTBIT        # BURNING OR DRIFTING?
                MASK    DAPBOOLS
                CCS     A
                TCF     TSENSE +1

                AD      TWO             # FAVOR +X JETS DURING AN APS BURN.
TSENSE          TS      SENSETYP
                CCS     ANYTRANS
                TCF     +3
                TS      POLYTEMP
                TCF     TSNEXTS
                TS      ROTINDEX

                CA      DAPBOOLS
                MASK    ACC4OR2X
                CCS     A
                TCF     TRANS4

                CA      DAPBOOLS
                MASK    AORBTRAN
                CCS     A
                CA      ONE             # THREE FOR B
                AD      TWO             # TWO FOR A SYSTEM 2 JET X TRANS
TSNUMBRT        TS      NUMBERT

                TC      SELCTSUB

                CCS     POLYTEMP
                TCF     +3
                TC      ALARM
                OCT     02002
                CA      00314OCT
                MASK    POLYTEMP
TSNEXTS         TS      NEXTU
                CS      00314OCT
                MASK    POLYTEMP
                TS      NEXTV

# Q,R-AXES RCS CONTROL MODE SELECTION
#       SWITCHES        INDICATION WHEN SET
#       BIT13/CHAN31    AUTO, GO TO ATTSTEER
#       PULSES          MINIMUM IMPULSE MODE
#       (OTHERWISE)     RATE COMMAND/ATTITUDE HOLD MODE

QRCONTRL        CA      BIT13           # CHECK MODE SELECT SWITCH.
                EXTEND
                RAND    CHAN31          # BITS INVERTED
                CCS     A
                TCF     ATTSTEER
NORMALQ         CAF     PULSES          # PULSES = 1 FOR MIN IMP USE OF RHC
                MASK    DAPBOOLS
                EXTEND
                BZF     CHEKSTIK        # IN ATT-HOLD/RATE-COMMAND IF BIT10=0

# MINIMUM IMPULSE MODE

                INHINT
                TC      IBNKCALL
                CADR    ZATTEROR
                CA      ZERO
                TS      QERROR
                TS      RERROR          # FOR DISPLAYS
                RELINT

                EXTEND
                READ    CHAN31
                TS      TEMP31          # IS EQUAL TO DAPTEMP1
                CCS     OLDQRMIN
                TCF     CHECKIN

FIREQR          CA      TEMP31
                MASK    BIT1
                EXTEND
                BZF     +QMIN

                CA      TEMP31
                MASK    BIT2
                EXTEND
                BZF     -QMIN

                CA      TEMP31
                MASK    BIT5
                EXTEND
                BZF     +RMIN

                CA      TEMP31
                MASK    BIT6
                EXTEND
                BZF     -RMIN

                TCF     XTRANS

CHECKIN         CS      TEMP31
                MASK    OCT63
                TS      OLDQRMIN
                TCF     XTRANS

+QMIN           CA      14MS
                TS      TJU
                CS      14MS
                TCF     MINQR
-QMIN           CS      14MS
                TS      TJU
                CA      14MS
                TCF     MINQR
+RMIN           CA      14MS
                TCF     +2
-RMIN           CS      14MS
                TS      TJU
MINQR           TS      TJV
                CA      MINADR
                TS      RETJADR
                CA      ONE
                TS      OLDQRMIN
MINRTN          TS      AXISCTR
                CA      DAPBOOLS
                MASK    AORBTRAN
                CCS     A
                CA      ONE
                AD      TWO
                TS      NUMBERT
                TCF     AFTERTJ

MINADR          GENADR  MINRTN
OCT63           OCT     63
14MS            =       +TJMINT6

+XORULGE        CAF     ONE
-XTRANS         AD      FIVE
                TS      ANYTRANS
                AD      NEG4
                TCF     TSENSE

TRANS4          CA      FOUR
                TCF     TSNUMBRT

# RATE COMMAND MODE:
# DESCRIPTION (SAME AS P-AXIS)

CHEKSTIK        TS      INGTS           # NOT IN GTS WHEN IN ATT HOLD
                CS      ONE             # 1/ACCS WILL DO THE NULLING DRIVES
                TS      COTROLER        # COME BACK TO RCS NEXT TIME
                CA      BIT15
                EXTEND
                RAND    CHAN31
                EXTEND
                BZF     RHCACTIV        # BRANCH IF OUT OF DETENT.
                CA      OURRCBIT        # ***********
                MASK    DAPBOOLS        # *IN DETENT*   CHECK FOR MANUAL CONTROL
                EXTEND                  # ***********   LAST TIME.
                BZMF    ATTSTEER

DBCHECK-        CA      OMEGAP          # STAY IN RATE DAMPING UNTIL P-AXIS
                TC      CHKRTDB         # AUTOPILOT HAS TAKEN CARE OF P-RATE

                CA      OMEGAU          # DAMP U AND V AXES
                TC      CHKRTDB
                CA      OMEGAV
                TC      CHKRTDB
                TCF     WITHINDB

CHKRTDB         CCS     A
                TCF     +2
RTDBGOOD        TC      Q

                AD      -RATEDB
                EXTEND
                BZMF    RTDBGOOD

                CS      OMEGAU
                TS      URATEDIF
                CS      OMEGAV
                TS      VRATEDIF
                TCF     ENTERUV

WITHINDB        CS      OURRCBIT        # ALL RATES ARE GOOD SO EXIT RATE CMD
                INHINT                  # MODE
                MASK    DAPBOOLS
                TS      DAPBOOLS
                TC      IBNKCALL
                CADR    ZATTEROR
                RELINT
                TCF     ATTSTEER

RHCACTIV        CA      OURRCBIT
                MASK    DAPBOOLS
                EXTEND
                BZF     XTRANS

                CA      RHCSCALE        # LINEAR CONTROLLER SCALING
                MASK    DAPBOOLS
                CCS     A
                CAF     143DEC          # SCALE FOR 20D/S MAX (177D)
                AD      34DEC           # SCALE FOR 4D/S MAX (34D)
                TS      RRATEDIF
                EXTEND
                MP      SAVEHAND
                CS      OMEGAQ
                AD      L
                TS      QRATEDIF
                CA      RRATEDIF
                EXTEND
                MP      SAVEHAND +1
                CS      OMEGAR
                AD      L
                TS      RRATEDIF
                DXCH    QRATEDIF
                TC      ROT45DEG
                DXCH    URATEDIF
                
ENTERUV         CA      HANDADR
                TS      RETJADR

                CA      ZERO
                TS      QERROR
                TS      RERROR

                INHINT                  # DIRECT RATE CONTROL.
                TC      IBNKCALL
                FCADR   ZATTEROR
                RELINT

                CA      ONE
BACKHAND        TS      AXISCTR

                CA      FOUR
                TS      NUMBERT

                INDEX   AXISCTR
                INDEX   SKIPU
                TCF     +1
                CA      FOUR
                INDEX   AXISCTR
                TS      SKIPU
                TCF     LOOPER
                INDEX   AXISCTR
                CCS     URATEDIF        #       INDEX   AXIS    QUANITY
                TCF     +2              #       0       -U      1/JETACC-AOSU
                TCF     SETTIME         #       1       +U      1/JETACC+AOSU
                AD      -RATEDB         #       16      -V      1/JETACC-AOSV
                EXTEND                  #       17      +V      1/JETACC+AOSV
                BZMF    ZEROTJ          # JETACC = 2 JET ACCELERATION (1 FOR FAIL)

                INDEX   AXISCTR
                CCS     URATEDIF
                CAF     ONE
                TCF     +2
                CAF     ZERO
                INDEX   AXISCTR
                AD      AXISDIFF
                INDEX   A
                CA      1/ANET2 +1
                EXTEND
                INDEX   AXISCTR         # URATEDIF IS SCALED AT PI/4 RAD/SEC
                MP      URATEDIF        #  JET TIME IN A      SCALED 32 SEC
                TS      Q
                DAS     A
                AD      Q
                TS      A               #  OVERFLOW SKIP
                TCF     +2
                CA      Q               # RIGHT SIGN AND BIGGER THAN 150MS
SETTIME         INDEX   AXISCTR
                TS      TJU             # SCALED AT 10.67 WHICH IS CLOSE TO 10.24
                TCF     AFTERTJ

ZEROTJ          CA      ZERO
                TCF     SETTIME

HANDADR         GENADR  BACKHAND

# GTS WILL BE TRIED IF
#       1. USEQRJTS= 0,
#       2. ALLOWGTS POS,
#       3. JETS ARE OFF (Q,R-AXES)

TRYGTS          CAF     USEQRJTS        # IS JET USE MANDATORY.         (AS LONG AS
                MASK    DAPBOOLS        # USEQRJTS BIT IS NOT BIT 15, CCS IS SAFE)
                CCS     A
                TCF     RCS
                CCS     ALLOWGTS        # NO.  DOES AOSTASK OK CONTROL FOR GTS?
                TCF     +2
                TCF     RCS
                EXTEND
                READ    CHAN5
                CCS     A
                TCF     CHKINGTS
GOTOGTS         EXTEND
                DCA     GTSCADR
                DTCB

CHKINGTS        CCS     INGTS           # WAS THE TRIM GIMBAL CONTROLLING
                TCF     +2              #       YES.  SET UP A DAMPED NULLING DRIVE.
                TCF     RCS             #       NO.  NULLING WAS SET UP BEFORE.  DO RCS
                INHINT
                TC      IBNKCALL
                CADR    TIMEGMBL
                RELINT
                CAF     ZERO
                TS      INGTS
                TCF     RCS

                EBANK=  CDUXD
GTSCADR         2CADR   GTS

# SUBROUTINE TO COMPUTE Q,R-AXES ATTITUDE ERRORS FOR USE IN THE RCS AND GTS CONTROL LAWS AND THE DISPLAYS.

QERRCALC        CAE     CDUY            # Q-ERROR CALCULATION
                EXTEND
                MSU     CDUYD           # CDU ANGLE - ANGLE DESIRED (Y-AXIS)
                TS      DAPTEMP1        # SAVE FOR RERRCALC
                EXTEND
                MP      M21             # (CDUY-CDUYD)*M21 SCALED AT PI RADIANS
                TS      E
                CAE     CDUZ            # SECOND TERM CALCULATION:
                EXTEND
                MSU     CDUZD           # CDU ANGLE -ANGLE DESIRED (Z-AXIS)
                TS      DAPTEMP2        # SAVE FOR RERRCALC
                EXTEND
                MP      M22             # (CDUZ-CDUZD)*M22 SCALED AT PI RADIANS
                AD      DELQEROR        # KALCMANU INERFACE ERROR
                AD      E
                XCH     QERROR          # SAVE Q-ERROR FOR EIGHT-BALL DISPLAY.

RERRCALC        CAE     DAPTEMP1        # R-ERROR CALCULATION:
                EXTEND                  # CDU ANGLE -ANGLE DESIRED (Y-AXIS)
                MP      M31             # (CDUY-CDUYD)*M31 SCALED AT PI RADIANS
                TS      E
                CAE     DAPTEMP2        # SECOND TERM CALCULATION:
                EXTEND                  # CDU ANGLE -ANGLE DESIRED (Z-AXIS)
                MP      M32             # (CDUZ-CDUZD)*M32 SCALED AT PI RADIANS
                AD      DELREROR        # KALCMANU INERFACE ERROR
                AD      E
                XCH     RERROR          # SAVE R-ERROR FOR EIGHT-BALL DISPLAY.
                TC      Q

# "ATTSTEER" IS THE ENTRY POINT FOR Q,R-AXES (U,V-AXES) ATTITUDE CONTROL USING THE REACTION CONTROL SYSTEM

ATTSTEER        EQUALS  STILLRCS        # "STILLRCS" IS THE RCS EXIT FROM TRYGTS.

STILLRCS        EXTEND
                DCA     QERROR
                TC      ROT45DEG
                DXCH    UERROR

# PREPARES CALL TO TJETLAW (OR SPSRCS(DOCKED))
# PREFORMS SKIP LOGIC ON U OR Y AXIS IF NEEDED.

TJLAW           CA      TJLAWADR
                TS      RETJADR
                CA      ONE
                TS      AXISCTR
                INDEX   AXISCTR
                INDEX   SKIPU
                TCF     +1
                CA      FOUR
                INDEX   AXISCTR
                TS      SKIPU
                TCF     LOOPER
                INDEX   AXISCTR
                CA      UERROR
                TS      E
                INDEX   AXISCTR
                CA      OMEGAU
                TS      EDOT
                CA      DAPBOOLS
                MASK    CSMDOCKD
                CCS     A
                TCF     +3
                TC      TJETLAW
                TCF     AFTERTJ
 +3             CS      DAPBOOLS        # DOCKED.  IF GIMBAL USABLE DO GTS CONTROL
                MASK    USEQRJTS        #  ON THE NEXT PASS.
                CCS     A               # USEQRJTS BIT MUST NOT BE BIT 15.
                TS      COTROLER        # GIMBAL USABLE.  STORE POSITIVE VALUE.
                TCF     SPSRCS          # DETERMINE RCS CONTROL.

TJLAWADR        GENADR  TJLAW   +3      # RETURN ADDRESS FOR RCS ATTITUDE CONTROL

                CAF     FOUR            # ALWAYS CALL FOR 2-JET CONTROL ABOUT U,V.
                TS      NUMBERT         # FALL THROUGH TO JET SELECTION, ETC.

# Q,R-JET-SELECTION-LOGIC
#
# INPUT:        AXISCTR         0,1 FOR U,V
#               SNUFFBIT        ZERO TJETU,V AND TRANS. ONLY IF SET IN A DPS BURN
#               TJU,TJV         JET TIME SCALED 10.24 SEC.
#               NUMBERT         INDICATES NUMBER OF JETS AND TYPE OF POLICY
#               RETJADR         WHERE TO RETURN TO
# OUTPUT:       NO.U(V)JETS     RATE DERIVATION FEEDBACK
#               CHANNEL 5
#               SKIPU,SKIRV     FOR LESS THAN 150MS FIRING
#
# NOTES:        IN CASE OF FAILURE IN DESIRED ROTATION POLICY, "ALL" UNFAILED
#               JETS OF THE DESIRED POLICY ARE SELECTED. SINCE THERE ARE ONLY
#               TWO JETS, THIS MEANS THE OTHER ONE OR NONE. THE ALARM IS SENT
#               IF NONE CAN BE FOUND.
#
#               TIMES LESS THAN 14 MSEC ARE TAKEN TO CALL FOR A SINGLE-JET
#               MINIMUM IMPULSE, WITH THE JET CHOSEN SEMI-RANDOMLY.

AFTERTJ         CAF     TWO
                TS      L
                INDEX   AXISCTR
                CCS     TJU
                TCF     +5
                TCF     NOROTAT
                TCF     +2
                TCF     NOROTAT
                ZL
                AD      ONE
                TS      ABSTJ

                CA      AXISCTR
                AD      L
                TS      ROTINDEX        # 0 1 2 3 = -U -V -+U +V

                CA      ABSTJ
                AD      -150MS
                EXTEND
                BZMF    DOSKIP

                TC      SELCTSUB

                INDEX   AXISCTR
                CA      INDEXES
                TS      L

                CA      POLYTEMP
                INHINT
                INDEX   L
                TC      WRITEP

                RELINT
                TCF     FEEDBACK

NOROTAT         INDEX   AXISCTR
                CA      INDEXES
                INHINT
                INDEX   A
                TC      WRITEP  -1

                RELINT
LOOPER          CCS     AXISCTR
                TC      RETJADR
                TCF     CLOSEOUT
DOSKIP          CS      ABSTJ
                AD      +TJMINT6        # 14MS
                EXTEND
                BZMF    NOTMIN

                ADS     ABSTJ
                INDEX   AXISCTR
                CCS     TJU
                CA      +TJMINT6
                TCF     +2
                CS      +TJMINT6
                INDEX   AXISCTR
                TS      TJU

                CCS     SENSETYP        # ENSURE MIN-IMPULSE NOT AGAINST TRANS
                TCF     NOTMIN  -1
                EXTEND
                READ    LOSCALAR
                MASK    ONE
                TS      NUMBERT

NOTMIN          TC      SELCTSUB

                INDEX   AXISCTR
                CA      INDEXES
                INHINT
                TS      T6FURTHA +1
                CA      POLYTEMP
                INDEX   T6FURTHA +1
                TC      WRITEP
                CA      ABSTJ
                TS      T6FURTHA
                TC      JTLST           # IN QR BANK BY NOW

                RELINT

                CA      ZERO
                INDEX   AXISCTR
                TS      SKIPU

FEEDBACK        CS      THREE
                AD      NUMBERT
                EXTEND
                BZMF    +3

                CA      TWO
                TCF     +2
                CA      ONE
                INDEX   AXISCTR
                TS      NO.UJETS
                TCF     LOOPER

XTRANS          CA      ZERO
                TS      TJU
                TS      TJV
                CA      FOUR
                INHINT
                XCH     SKIPU
                EXTEND
                BZF     +2
                TC      WRITEU  -1
                CA      FOUR
                XCH     SKIPV
                RELINT

                EXTEND
                BZF     CLOSEOUT
                INHINT
                TC      WRITEV  -1
                RELINT

                TCF     CLOSEOUT
INDEXES         DEC     4
                DEC     13
+TJMINT6        DEC     22
-150MS          DEC     -240
BIT8,9          OCT     00600
SCLNORM         OCT     266

# THE JET LIST:
# THIS IS A WAITLIST FOR T6RUPTS.
#
# CALLED BY:
#               CA      TJ              TIME WHEN NEXT JETS WILL BE WRITTEN
#               TS      T6FURTHA
#               CA      INDEX           AXIS TO BE WIRTTEN AT TJ (FROM NOW)
#               TS      T6FURTHA +1
#               TC      JTLST
#
# EXAMPLE - U-AXIS AUTOPILOT WILL WRITE ITS ROTATION CODE OF
# JETS INTO CHANNEL 5.  IF IT DESIRES TO TURN OFF THIS POLICY WITHIN
# 150MS AND THEN FIRE NEXTU, A CALL TO JTLST IS MADE WITH T6FURTHA
# CONTAINING THE TIME TO TURN OFF THE POLICY, T6FURTHA +1 THE INDEX
# OF THE U-AXIS(4), AND NEXTU WILL CONTAIN THE "U-TRANS" POLICY OR ZERO.
#
# THE LIST IS EXACTLY 3 LONG.  (THIS LEADS TO SKIP LOGIC AND 150MS LIMIT)
# THE INPUT IS THE LAST MEMBER OF THE LIST
#
# RETURNS BY:
#       +       TC      Q
#
# DEFINITIONS:  (OUTPUT)
#       TIME6           TIME OF NEXT RUPT
#       T6NEXT          DELTA TIME TO NEXT RUPT
#       T6FURTHA        DELTA TIME FROM 2ND TO LAST RUPT
#       NXT6ADR         AXIS INDEX       Q - P-AXIS
#       T6NEXT +1       AXIS INDEX       4 - U-AXIS
#       T6FURTHA +1     AXIS INDEX      13 - V-AXIS

JTLST           CS      T6FURTHA
                AD      TIME6
                EXTEND
                BZMF    MIDORLST        # TIME6 - T IS IN A

                LXCH    NXT6ADR
                DXCH    T6NEXT
                DXCH    T6FURTHA
                TS      TIME6
                LXCH    NXT6ADR

TURNON          CA      BIT15
                EXTEND
                WOR     CHAN13
                TC      Q

MIDORLST        AD      T6NEXT
                EXTEND
                BZMF    LASTCHG         # TIME6 + T6NEXT - T IS IN A

                LXCH    T6NEXT  +1
                DXCH    T6FURTHA
                EXTEND
                SU      TIME6
                DXCH    T6NEXT

                TC      Q

LASTCHG         CS      A
                AD      NEG0
                TS      T6FURTHA

                TC      Q

ROT45DEG        TS      ROTEMP1
                AD      L
                TS      ROTEMP2
                TCF     +6
                CCS     A
                CA      POSMAX
                TCF     +2
                CA      NEGMAX
                TS      ROTEMP2         # Q+R
                CS      ROTEMP1
                AD      L
                TS      ROTEMP1         # R-Q
                TCF     +4
                EXTEND
                MP      POSMAX
                CA      L
                EXTEND
                MP      .707
                XCH     ROTEMP2
                EXTEND
                MP      .707
                LXCH    ROTEMP2
                TC      Q

.707            DEC     .70711

SELCTSUB        INDEX   ROTINDEX
                CA      ALLJETS
                INDEX   NUMBERT
                MASK    TYPEPOLY
                TS      POLYTEMP

                MASK    CH5MASK
                CCS     A
                TCF     +2
                TC      Q

                CA      THREE
FAILOOP         TS      NUMBERT
                INDEX   ROTINDEX
                CA      ALLJETS
                INDEX   NUMBERT
                MASK    TYPEPOLY
                TS      POLYTEMP
                MASK    CH5MASK
                EXTEND
                BZF     FAILOOP -2
                CCS     NUMBERT
                TCF     FAILOOP
                INDEX   AXISCTR
                TS      TJU
                TC      ALARM
                OCT     02004
                TCF     NOROTAT
ALLJETS         OCT     00110           #       -U      6 13
                OCT     00022           #       -V      2 9
                OCT     00204           #       +U      5 14
                OCT     00041           #       +V      1 10
TYPEPOLY        OCT     00125           #       -X      1 5 9 13
                OCT     00252           #       +X      2 6 10 14
                OCT     00146           #       A       2 5 10 13
                OCT     00231           #       B       1 6 9 14
                OCT     00377           #       ALL     1 2 5 6 9 10 13 14

# THE FOLLOWING SETS THE INTERRUPT FLIP-FLOP AS SOON AS POSSIBLE, WHICH PERMITS A RETURN TO THE INTERRUPTED JOB.

CLOSEOUT        CA      ADRRUPT
                TC      MAKERUPT

ADRRUPT         ADRES   ENDJASK

ENDJASK         DXCH    DAPARUPT
                DXCH    ARUPT
                DXCH    DAPBQRPT
                XCH     BRUPT
                LXCH    Q
                CAF     NEGMAX          # NEGATIVE DAPZRUPT SIGNALS JASK IS OVER.
                DXCH    DAPZRUPT
                DXCH    ZRUPT
                TCF     NOQRSM


                BLOCK   3
                SETLOC  FFTAG6
                BANK
                COUNT*  $$/DAP

MAKERUPT        EXTEND
                EDRUPT  MAKERUPT

