### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LANDING_ANALOG_DISPLAYS.agc
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

                BANK    21
                SETLOC  R10
                BANK

                EBANK=  UNIT/R/
                COUNT*  $$/R10

LANDISP         CAF     SWANDBIT        # IS LANDING ANALOG DISPLAYS FLAG SET?
                MASK    FLAGWRD7
                CCS     A
                TCF     +3              # YES.
GODSPRST        TC      DISPRSET        # NO.
                TCF     LANDELAY
                CA      IMODES33        # BIT 7 = 0 (DO ALTRATE), =1 (DO ALT.)
                MASK    BIT7
                CCS     A
                TCF     ALTOUT
ALTROUT         TC      DISINDAT        # CHECK MODE SELECT SWITCH AND DIDFLG.
                CS      IMODES33
                MASK    BIT7
                ADS     IMODES33        # ALTERNATE ALTITUDE RATE WITH ALTITUDE.
                CAF     BIT2            # RATE COMMAND IS EXECUTED BEFORE RANGE.
                EXTEND
                WOR     CHAN14          # ALTRATE (BIT2 = 1), ALTITUDE (BIT2 = 0).
ARCOMP          CA      RUNIT           # COMPUTE ALTRATE = RUNIT.VVECT M/CS *2(-6).
                EXTEND
                MP      VVECT           # MULTIPLY X-COMPONENTS.
                XCH     RUPTREG1        # SAVE SINGLE PRECISION RESULT M/CS*2(-6).
                CA      RUNIT +2        # MULTIPLY Y-COMPONENTS.
                EXTEND
                MP      VVECT +1
                ADS     RUPTREG1        # ACCUMULATE PARTIAL PRODUCTS.
                CA      RUNIT +4        # MULTIPLY Z-COMPONENTS.
                EXTEND
                MP      VVECT +2
                ADS     RUPTREG1        # ALTITUDE RATE IN M/CS *2(-6).
                CA      ARCONV          # CONVERT ALTRATE TO BIT UNITS (.5FPS/BIT)
                EXTEND
                MP      RUPTREG1
                DOUBLE
                DOUBLE
                XCH     RUPTREG1        # ALTITUDE RATE IN BIT UNITS*2(-14).
                CS      DALTRATE        # ALTITUDE RATE COMPENSATION FACTOR.
                EXTEND
                MP      DT
                AD      RUPTREG1
                TS      ALTRATE         # ALTITUDE RATE IN BIT UNITS*2(-14).
                CS      ALTRATE
                EXTEND                  # CHECK POLARITY OF ALTITUDE RATE.
                BZMF    +2
                TCF     DATAOUT         # NEGATIVE - SEND POS. PULSES TO ALTM REG.
                CA      ALTRATE         # POSITIVE OR ZERO - SET SIGN BIT = 1 AND
                AD      BIT15           # SEND TO ALTM REGISTER.  *DO NOT SEND +0*
DATAOUT         TS      ALTM            # ACTIVATE THE LANDING ANALOG DISPLAYS - -
                CAF     DATABITS
                EXTEND
                WOR     CHAN14          # BIT3 DRIVES THE ALT/ALTRATE METER.

LANDELAY        CCS     PIPCTR
                TCF     +2
                TCF     TASKOVER
                TS      PIPCTR
                TC      FIXDELAY
                DEC     24
                TCF     LANDISP

ALTOUT          TC      DISINDAT        # CHECK MODE SELECT SWITCH AND DIDFLG.
                CS      BIT7
                MASK    IMODES33
                TS      IMODES33        # ALTERNATE ALTITUDE RATE WITH ALTITUDE.
                CS      BIT2
                EXTEND
                WAND    CHAN14
                CCS     ALTBITS         # =-1 IF OLD ALT. DATA TO BE EXTRAPOLATED.
                TCF     +4
                TCF     +3
                TCF     OLDDATA
                TS      ALTBITS         # SET ALTBITS FROM -0 TO +0.
                CS      ONE
                DXCH    ALTBITS         # SET ALTBITS = -1 FOR SWITCH USE NEXT PASS.

ZDATA2          DXCH    ALTSAVE
                TCF     NEWDATA
OLDDATA         CA      ALTRATE         # RATE APPLIES FOR .5 SEC. (4X/SEC. CYCLE)
                EXTEND
                MP      ARTOA           # EXTRAPOLATE WITH ALTITUDE RATE.
                AD      ALTSAVE +1
                TS      ALTSAVE +1
                CAF     ZERO
                ADS     ALTSAVE
                CAF     POSMAX          # FORCE SIGN AGREEMENT ASSUMING A
                AD      ONE             # NON-NEGATIVE ALTSAVE.
                AD      ALTSAVE +1      # IF ALTSAVE IS NEGATIVE, ZERO ALTSAVE
                TS      ALTSAVE +1      # AND ALTSAVE +1 AT ZERODATA.
                CAF     ZERO
                AD      POSMAX
                AD      ALTSAVE
                TS      ALTSAVE         # POSSIBLY SKIP TO NEWDATA.
                TCF     ZERODATA
NEWDATA         CCS     ALTSAVE +1
                TCF     +4
                TCF     +3
                CAF     ZERO            # SET NEGATIVE ALTSAVE +1 TO +0.
                TS      ALTSAVE +1
                CCS     ALTSAVE         # PROVIDE A 15 BIT UNSIGNED OUTPUT.
                CAF     BIT15           # THE HI-ORDER PART IS +1 OR +0.
                AD      ALTSAVE +1
                TCF     DATAOUT         # DISPATCH UNSIGNED BITS TO ALTM REG.
DISINDAT        EXTEND
                QXCH    LADQSAVE        # SAVE RETURN TO ALTROUT +1 OR ALTOUT +1
                CAF     BIT6
                EXTEND                  # WISHETH THE ASTRONAUT THE ANALOG
                RAND    CHAN30          # DISPLAYS?  I.E.,
                CCS     A               # IS THE MODE SELECT SWITCH IN PGNCS?
                TCF     GODSPRST        # NO.  ASTRONAUT REQUESTS NO INERTIAL DATA
                CCS     DIDFLG          # YES. CHECK STATUS OF DIDFLAG.
                TCF     GODSPRST
                TCF     SPEEDRUN        # SET. PERFORM DATA DISPLAY SEQUENCE.
                CAF     BIT8
                EXTEND
                WOR     CHAN12          # SET DISPLAY INERTIAL DATA OUTBIT.
                CAF     ZERO
                TS      DIDFLG
                TS      TRAKLATV        # LATERAL VELOCITY MONITOR FLAG
                TS      TRAKFWDV        # FORWARD VELOCITY MONITOR FLAG
                TS      LATVMETR        # LATVEL MONITOR METER
                TS      FORVMETR        # FORVEL MONITOR METER
                CS      BIT7
                MASK    IMODES33
                TS      IMODES33
                CAF     BIT4
                TC      TWIDDLE
                ADRES   INTLZE
                TCF     LANDELAY
INTLZE          CAF     BIT2
                EXTEND
                WOR     CHAN12          # ENABLE RR ERROR COUNTER.
                CS      IMODES33
                MASK    BIT8
                ADS     IMODES33        # SET INERTIAL DATA FLAG.
                TCF     TASKOVER

SPEEDRUN        CS      PIPTIME +1      # UPDATE THE VELOCITY VECTOR
                AD      TIME1           # COMPUTE T - TN
                AD      HALF            # CORRECT FOR POSSIBLE OVERFLOW OF TIME1.
                AD      HALF
                XCH     DT              # SAVE FOR LATER USE
                CA      1SEC
                TS      ITEMP5          # INITIALIZE FOR DIVISION LATER
                EXTEND
                DCA     GDT/2           # COMPUTE THE X-COMPONENT OF VELOCITY.
                DDOUBL
                DDOUBL
                EXTEND
                MP      DT
                EXTEND
                DV      ITEMP5
                XCH     VVECT           # VVECT = G(T-TN) M/CS *2(-5)
                EXTEND
                DCA     V               # M/CS *2(-7)
                DDOUBL                  # RESCALE TO 2(-5)
                DDOUBL
                ADS     VVECT           # VVECT = VN + G(T-TN) M/CS *2(-5)
                CA      PIPAX           # DELV CM/SEC *2(-14)
                AD      PIPATMPX        # IN CASE PIPAX HAS BEEN ZEROED
                EXTEND
                MP      KPIP1(5)        # DELV M/CS *2(-5)
                ADS     VVECT           # VVECT = VN + DELV + GN(T-TN) M/CS *2(-5)
                EXTEND
                DCA     GDT/2 +2        # COMPUTE THE Y-COMPONENT OF VELOCITY.
                DDOUBL
                DDOUBL
                EXTEND
                MP      DT
                EXTEND
                DV      ITEMP5
                XCH     VVECT +1
                EXTEND
                DCA     V +2
                DDOUBL
                DDOUBL
                ADS     VVECT +1
                CA      PIPAY
                AD      PIPATMPY
                EXTEND
                MP      KPIP1(5)
                ADS     VVECT +1
                EXTEND
                DCA     GDT/2 +4        # COMPUTE THE Z-COMPONENT OF VELOCITY.
                DDOUBL
                DDOUBL
                EXTEND
                MP      DT
                EXTEND
                DV      ITEMP5
                XCH     VVECT +2
                EXTEND
                DCA     V +4
                DDOUBL
                DDOUBL
                ADS     VVECT +2
                CA      PIPAZ
                AD      PIPATMPZ
                EXTEND
                MP      KPIP1(5)
                ADS     VVECT +2

                CS      DELVS           # HI X OF VELOCITY CORRECTION TERM.
                AD      VVECT           # HI X OF UPDATED VELOCITY VECTOR.
                TS      ITEMP1          # = VX - DVX M/CS *2(-5).
                CS      DELVS +2        #    Y
                AD      VVECT +1        #    Y
                TS      ITEMP2          # = VY - DVY M/CS *2(-5).
                CS      DELVS +4        #    Z
                AD      VVECT +2        #    Z
                TS      ITEMP3          # = VZ - DVZ M/CS *2(-5).
                CA      ITEMP1          # COMPUTE VHY, VELOCITY DIRECTED ALONG THE
                EXTEND                  # Y-COORDINATE.
                MP      UHYP            # HI X OF CROSS-RANGE HALF-UNIT VECTOR.
                XCH     RUPTREG1
                CA      ITEMP2
                EXTEND
                MP      UHYP +2         # Y
                ADS     RUPTREG1        # ACCUMULATE PARTIAL PRODUCTS.
                CA      ITEMP3
                EXTEND
                MP      UHYP +4         # Z
                ADS     RUPTREG1
                CA      RUPTREG1
                DOUBLE
                XCH     VHY             # VHY=VMP.UHYP M/CS*2(-5).
                CA      ITEMP1          # NOW COMPUTE VHZ, VELOCITY DIRECTED ALONG
                EXTEND                  # THE Z-COORDINATE.
                MP      UHZP            # HI X OF DOWN-RANGE HALF-UNIT VECTOR.
                XCH     RUPTREG1
                CA      ITEMP2
                EXTEND
                MP      UHZP +2         # Y
                ADS     RUPTREG1        # ACCUMULATE PARTIAL PRODUCTS.
                CA      ITEMP3
                EXTEND
                MP      UHZP +4         # Z
                ADS     RUPTREG1
                CA      RUPTREG1
                DOUBLE
                XCH     VHZ             # VHZ = VMP.UHZP M/CS*2(-5).
GET22/32        CAF     EBANK6          # GET SIN(AOG),COS(AOG) FROM GPMATRIX.
                TS      EBANK
                EBANK=  M22
                CA      M22
                TS      ITEMP3
                CA      M32
                TS      ITEMP4
                CAF     EBANK7
                TS      EBANK
                EBANK=  UNIT/R/
LATFWDV         CA      ITEMP4          # COMPUTE LATERAL AND FORWARD VELOCITIES.
                EXTEND
                MP      VHY
                XCH     RUPTREG1
                CA      ITEMP3
                EXTEND
                MP      VHZ
                ADS     RUPTREG1        # = VHY(COS)AOG+VHZ(SIN)AOG M/CS *2(-5)
                CA      VELCONV         # CONVERT LATERAL VELOCITY TO BIT UNITS.
                EXTEND
                MP      RUPTREG1
                DOUBLE
                XCH     LATVEL          # LATERAL VELOCITY IN BIT UNITS *2(-14).
                CA      ITEMP4          # COMPUTE FORWARD VELOCITY.
                EXTEND
                MP      VHZ
                XCH     RUPTREG1
                CA      ITEMP3
                EXTEND
                MP      VHY
                CS      A
                ADS     RUPTREG1        # =VHZ(COS)AOG-VHY(SIN)AOG M/CS *2(-5).
                CA      VELCONV         # CONVERT FORWARD VELOCITY TO BIT UNITS.
                EXTEND
                MP      RUPTREG1
                DOUBLE
                XCH     FORVEL          # FORWARD VELOCITY IN BIT UNITS *2(-14).

                CS      MAXVBITS        # ACC.=-199.9989 FT./SEC.
                TS      ITEMP6          # -547 BIT UNITS (OCTAL) AT 0.5571 FPS/BIT

VMONITOR        CCS     LATVEL
                TCF     +4
                TCF     LVLIMITS
                TCF     +7
                TCF     LVLIMITS
                CS      LATVEL
                AD      MAXVBITS        # +199.9989 FT./SEC.
                EXTEND
                BZMF    CHKLASTY
                TCF     LVLIMITS
                CA      LATVEL
                AD      MAXVBITS
                EXTEND
                BZMF    +2
                TCF     LVLIMITS
CHKLASTY        CCS     TRAKLATV
                TCF     LASTPOSY
                TCF     +2
                TCF     LASTNEGY
                CA      LATVEL
                EXTEND
                BZMF    NEGVMAXY
                TCF     POSVMAXY
LASTPOSY        CA      LATVEL
                EXTEND
                BZMF    +2
                TCF     POSVMAXY
                CS      MAXVBITS
                TCF     ZEROLSTY
POSVMAXY        CS      LATVMETR
                AD      MAXVBITS
                XCH     RUPTREG3
                CAF     ONE
                TCF     ZEROLSTY +2
LASTNEGY        CA      LATVEL
                EXTEND
                BZMF    NEGVMAXY
                CA      MAXVBITS
                TCF     ZEROLSTY
NEGVMAXY        CA      LATVMETR
                AD      MAXVBITS
                COM
                XCH     RUPTREG3
                CS      ONE
                TCF     ZEROLSTY +2
LVLIMITS        CCS     TRAKLATV
                TCF     LATVPOS
                TCF     +2
                TCF     LATVNEG
                CS      LATVMETR
                EXTEND
                BZMF    +2
                TCF     NEGLMLV
                CS      LATVEL
                EXTEND
                BZMF    LVMINLM
                AD      ITEMP6
                AD      LATVMETR
                EXTEND
                BZMF    LVMINLM
                AD      LATVEL
                EXTEND
                SU      LATVMETR
                TCF     ZEROLSTY
LATVPOS         CS      LATVEL
                EXTEND
                BZMF    LVMINLM
                TCF     +4
LATVNEG         CA      LATVEL
                EXTEND
                BZMF    LVMINLM
                CS      LATVMETR
                TCF     ZEROLSTY
NEGLMLV         CA      LATVEL
                EXTEND
                BZMF    LVMINLM
                CA      MAXVBITS
                AD      LATVMETR
                COM
                AD      LATVEL
                EXTEND
                BZMF    LVMINLM
                EXTEND
                SU      LATVEL
                AD      LATVMETR
                COM
                TCF     ZEROLSTY
LVMINLM         CS      LATVMETR
                AD      LATVEL
ZEROLSTY        XCH     RUPTREG3
                CAF     ZERO
                TS      TRAKLATV
                CA      RUPTREG3
                AD      NEG0            # AVOIDS +0 DINC HARDWARE MALFUNCTION
                TS      CDUTCMD
                CA      RUPTREG3
                ADS     LATVMETR

                CCS     FORVEL
                TCF     +4
                TCF     FVLIMITS
                TCF     +7
                TCF     FVLIMITS
                CS      FORVEL
                AD      MAXVBITS        # +199.9989 FT./SEC.
                EXTEND
                BZMF    CHKLASTZ
                TCF     FVLIMITS
                CA      FORVEL
                AD      MAXVBITS
                EXTEND
                BZMF    +2
                TCF     FVLIMITS
CHKLASTZ        CCS     TRAKFWDV
                TCF     LASTPOSZ
                TCF     +2
                TCF     LASTNEGZ
                CA      FORVEL
                EXTEND
                BZMF    NEGVMAXZ
                TCF     POSVMAXZ
LASTPOSZ        CA      FORVEL
                EXTEND
                BZMF    +2
                TCF     POSVMAXZ
                CS      MAXVBITS
                TCF     ZEROLSTZ
POSVMAXZ        CS      FORVMETR
                AD      MAXVBITS
                XCH     RUPTREG4
                CAF     ONE
                TCF     ZEROLSTZ +2
LASTNEGZ        CA      FORVEL
                EXTEND
                BZMF    NEGVMAXZ
                CA      MAXVBITS
                TCF     ZEROLSTZ
NEGVMAXZ        CA      FORVMETR
                AD      MAXVBITS
                COM
                XCH     RUPTREG4
                CS      ONE
                TCF     ZEROLSTZ +2
FVLIMITS        CCS     TRAKFWDV
                TCF     FORVPOS
                TCF     +2
                TCF     FORVNEG
                CS      FORVMETR
                EXTEND
                BZMF    +2
                TCF     NEGLMFV
                CS      FORVEL
                EXTEND
                BZMF    FVMINLM
                AD      ITEMP6
                AD      FORVMETR
                EXTEND
                BZMF    FVMINLM
                AD      FORVEL
                EXTEND
                SU      FORVMETR
                TCF     ZEROLSTZ
FORVPOS         CS      FORVEL
                EXTEND
                BZMF    FVMINLM
                TCF     +4
FORVNEG         CA      FORVEL
                EXTEND
                BZMF    FVMINLM
                CS      FORVMETR
                TCF     ZEROLSTZ
NEGLMFV         CA      FORVEL
                EXTEND
                BZMF    FVMINLM
                CA      MAXVBITS
                AD      FORVMETR
                COM
                AD      FORVEL
                EXTEND
                BZMF    FVMINLM
                EXTEND
                SU      FORVEL
                AD      FORVMETR
                COM
                TCF     ZEROLSTZ
FVMINLM         CS      FORVMETR
                AD      FORVEL
ZEROLSTZ        XCH     RUPTREG4
                CAF     ZERO
                TS      TRAKFWDV
                CA      RUPTREG4
                AD      NEG0            # AVOIDS +0 DINC HARDWARE MALFUNCTION
                TS      CDUSCMD
                CA      RUPTREG4
                ADS     FORVMETR
                TC      LADQSAVE        # GO TO ALTROUT +1 OR TO ALTOUT +1
ZERODATA        CAF     ZERO            # ZERO ALTSAVE AND ALTSAVE +1 - - -
                TS      L               #        NO NEGATIVE ALTITUDES ALLOWED.
                TCF     ZDATA2

# ************************************************************************

DISPRSET        CAF     BIT8
                MASK    IMODES33        # CHECK IF INERTIAL DATA JUST DISPLAYED.
                CCS     A
                CAF     BIT2            # YES. DISABLE RR ERROR COUNTER
                AD      BIT8            # NO. REMOVE DISPLAY INERTIAL DATA
                COM
                EXTEND
                WAND    CHAN12
                CS      BITS8/7         # RESET INERTIAL DATA, INTERLEAVE FLAGS.
                MASK    IMODES33
                TS      IMODES33
                CS      ONE
                TS      DIDFLG
                TC      Q

# ************************************************************************

BITS8/7         OCT     00300           # INERTIAL DATA AND INTERLEAVE FLAGS.
BITSET          =       PRIO6
ARCONV          OCT     24402           # 656.1679798B-10 CONV ALTRATE TO BIT UNIT
ARTOA           DEC     .2051 B-1
DATABITS        OCT     06004
VELCONV         OCT     22316           # 588.914 B-10 CONV VEL. TO BIT UNITS.
KPIP1(5)        DEC     .05115          # SCALES DELV TO M/CS*2(-5).
OCT33427        OCT     33427
MAXVBITS        OCT     00547           # MAX. DISPLAYED VELOCITY 199.9989 FT/SEC.

# ************************************************************************


