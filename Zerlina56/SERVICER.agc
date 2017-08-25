### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SERVICER.agc
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
## Reference:   pp. 850-889
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-07-28 MAS  Created from Luminary 210.
##              2017-08-17 MAS  Began updates for Zerlina 56.
##              2017-08-19 MAS  Completed updating for Zerlina 56.
##              2017-08-24 MAS  Replaced an incorrect VXM with VXV.

## Page 850
# ****************************************************************************************************************
# VARIABLE GUIDANCE PERIOD SERVICER                                                               WRITTEN BY EYLES
# ****************************************************************************************************************

                SETLOC  SERV1
                BANK
                EBANK=  DVCNTR
                COUNT*  $$/SERV

# ****************************************************************************************************************
# PREREAD
# ****************************************************************************************************************

#           THIS ROUTINE IS CALLED BY A TASK (TO WHICH IT DOES NOT RETURN) TO START SERVICER.   PREREAD ZEROES
# THE PIPAS AND PIPASOLD (PIPTIME1 IS ALREADY SET), SETS V37FLAG AND AVEGFLAG SO SHOW THAT SERVICER IS ON, CLEARS
# DRIFTFLAG TO SHOW THAT THOSE PASSIVE GUYS ARE NO LONGER IN CONTROL, INITIALIZES THE INFAMOUS DV MONITOR,
# INITIATES QUARTASK WHICH COMPRISES R10 AND R11, AND SETS UP NORMLIZE, THE JOB LEAD-IN TO THE SERVICER CYCLE.


PREREAD         TC      PHASCHNG        # SKIP LASTBIAS IF THERE IS A RESTART
                OCT     47015
                OCT     77777
                EBANK=  DVCNTR
                2CADR   BIBIBIAS


                CAF     PRIO21
                TC      NOVAC
                EBANK=  NBDX
                2CADR   LASTBIAS        # DO LAST GYRO COMPENSATION IN FREE FALL


BIBIBIAS        CS      ZERO            # ZERO PIPAS AND PIPASOLD
                TS      PIPAX
                TS      PIPAY
                TS      PIPAZ
                TS      PIPAXOLD
                TS      PIPAYOLD
                TS      PIPAZOLD

                CAF     BIT9            # SET TEST CONNECTOR OUTBIT TO TELL THE
                EXTEND                  #   HYBRID THAT AVERAGE-G IS STARTING
                WOR     DSALMOUT

                CS      FLAGWRD7
                MASK    SUPER011        # SET V37FLAG AND AVEGFLAG (BITS 5 AND 6
                ADS     FLAGWRD7        #   OF FLAGWRD7)

                TC      DOWNFLAG        # CLEAR DRIFTFLG TO STOP COASTING FLIGHT
                ADRES   DRIFTFLG        #   TYPE GYRO COMPENSATION  ????

## Page 851
                CA      FLAGWRD6        # IS MUNFLAG SET?
                MASK    MUNFLBIT
                EXTEND
                BZF     NORMSET         # NO:   DO NOT INITIATE QUARTASK

                CCS     PHASE2          # AVOID MULTIPLE QUARTASK CALL
                TCF     NORMSET

                CS      TIME1
                TS      TBASE2
                CAF     DEC17           # 2.21SPOT FOR QUARTASK
                TS      L
                COM
                DXCH    -PHASE2

                CAF     OCT31
                TC      WAITLIST
                EBANK=  END-E7
                2CADR   QUARTASK


NORMSET         CAF     PRIO20          # SET UP SERVICER LEAD-IN AT PRIORITY 20
                TC      FINDVAC
                EBANK=  DVCNTR
                2CADR   NORMLIZE


                TC      PHASCHNG        # PROTECT NORMLIZE IN GROUP 5 AT PRIO 20
                OCT     07025
                OCT     20000           # PRIORITY 20
                EBANK=  DVCNTR
                2CADR   NORMLIZE


                TCF     TASKOVER

# ****************************************************************************************************************
# NORMLIZE - SERVICER JOB LEAD-IN
# ****************************************************************************************************************
                
                SETLOC  SERVICES
                BANK
                EBANK=  DVCNTR
                COUNT*  $$/SERV

NORMLIZE        TC      INTPRET
                VLOAD   BOFF
                        RN1
                        MUNFLAG
                        NORMLIZ1
## Page 852
                VSL6    MXV
                        REFSMMAT
                STCALL  R
                        MUNGRAV
                VLOAD   VSL1
                        VN1
                MXV
                        REFSMMAT
                STORE   V
                SLOAD   PUSH            # COMPUTE PIPA BIAS VECTOR FOR USE BY
                        PBIASZ          #   P66ROD AND LANDING ANALOG DISPLAYS
                SLOAD   PUSH
                        PBIASY
                SLOAD   VDEF
                        PBIASX
                VXSC    EXIT            # RESCALE TO UNITS OF 2(-9) M/CS/CS
                        BIASFACT

                CA      MPAC
                TS      BIASACCX
                CA      MPAC     +3
                TS      BIASACCY
                CA      MPAC     +5
                TS      BIASACCZ

                TCF     NORMLIZ2

NORMLIZ1        CALL
                        CALCGRAV
                EXIT

NORMLIZ2        CAF     OCT24           # TWENTY TO YOU
                TC      COPYCYC +1      # DO NOT COPY MASS IN NORMLIZE

                RELINT

#                                            (FALL THROUGH TO PIPCYCLE)

# ****************************************************************************************************************
# START OF SERVICER CYCLE
# ****************************************************************************************************************

SERVEXIT        =       PIPCYCLE

PIPCYCLE        TC      SERVCHNG

                TC      DOWNFLAG        # CLEAR SERVOVER FLAG TO INDICATE THAT
                ADRES   SERVOVER        #   SERVICER IS STARTING A NEW PASS

                CAF     EBANK7          # INSURE PROPER EBANK
## Page 853
                TS      EBANK
                EBANK=  END-E7

                CS      TIME1           # WAS LAST READACCS LONG ENOUGH AGO?
                AD      PIPTIME  +1
                AD      NEG1/2
                AD      NEG1/2
                XCH     L               # CLEAR PROBABLE OVERFLOW
                XCH     L
                AD      PGMIN
                EXTEND
                BZMF    READACCS        # YES:  GO STRAIGHT TO READACCS

                TC      BANKCALL        # NO:   DELAY IT ACCORDINGLY
                CADR    DELAYJOB

READACCS        INHINT                  # INHINT SO DELVS, CDUTEMPS, PIPTIME1 AND
                EXTEND                  #   PGUIDE1 WILL BE A CONSISTENT SET
                DCA     TIME2
                DXCH    PIPTIME1

                CA      PIPAX
                TS      PIPATMPX
                CA      PIPAY
                TS      PIPATMPY
                CA      PIPAZ
                TS      PIPATMPZ
                CA      CDUX
                TS      CDUTEMPX
                CA      CDUY
                TS      CDUTEMPY
                CA      CDUZ
                TS      CDUTEMPZ

                CS      PIPAXOLD
                AD      PIPATMPX
                TC      PIPNORM
                DXCH    DELVX

                CS      PIPAYOLD
                AD      PIPATMPY
                TC      PIPNORM
                DXCH    DELVY

                CS      PIPAZOLD
                AD      PIPATMPZ
                TC      PIPNORM
                DXCH    DELVZ

                CS      PIPTIME  +1     # COMPUTE GUIDANCE PERIOD PGUIDE1
## Page 854
                AD      PIPTIME1 +1
                AD      HALF
                AD      HALF
                ZL
                DXCH    PGUIDE1

                RELINT
                TC      SERVCHNG        # PIPATMPS GO TO PIPASOLD AT COPYCYCL

#          THE PHILOSOPHY OF THE HANDLING OF PIPAS AND PIPASOLD IS THIS:   THAT AT ANY TIME THE QUANTITY
# PIPAS-PIPASOLD BE THE THRUST DELTA-V NEEDED TO EXTRAPOLATE LM POSITION AND VELOCITY FROM R AND V (VALID AT
# PIPTIME) TO THE PRESENT TIME.   THE COMPUTATIONS THIS PARTICULARLY ASSISTS ARE IN THE LANDING ANALOG
# DISPLAYS, LANDING RADAR DATA INCORPORATION (PART OF SERVICER), AND P66 R.O.D.

PIPSDONE        CS      PGMAX           # WAS LAST READACCS TOO LONG AGO?
                AD      PGUIDE1
                EXTEND
                BZMF    +3              # NO

                TC      ALARM           # YES:  LIGHT ALARM LIGHT
                OCT     00555

                CS      FLAGWRD7        # HAS AVEGFLAG FALLEN?
                MASK    AVEGFBIT
                EXTEND
                BZF     SERVICER        # NO:   CONTINUE AVERAGE-G

AVEGOUT         EXTEND                  # YES:  THEN THIS IS THE LAST SERVICER
                DCA     AVOUTCAD
                DXCH    AVGEXIT

SERVICER        CAF     EBANK3
                TS      EBANK
                EBANK=  PHSNAME5
                CAF     GETABADR        # SKIP 1/PIPA AFTER RESTART
                TS      PHSNAME5
                CAF     EBANK7
                TS      EBANK
                EBANK=  DVCNTR

                CA      PGUIDE1         # SET 1/PIPADT TO PGUIDE1 JUST COMPUTED
                EXTEND
                MP      BIT5            # RESCALE PGUIDE TO UNITS OF 2(10) CS
                LXCH    1/PIPADT

                TC      BANKCALL        # PIPA COMPENSATION CALL
                CADR    1/PIPA

GETABVAL        CA      FIXLOC          # ZERO PUSHDOWN POINTER
                TS      PUSHLOC

## Page 855
                CA      DELV
                EXTEND
                MP      A
                DXCH    MPAC
                CA      DELV     +2
                EXTEND
                MP      A
                DAS     MPAC
                CA      DELV     +4
                EXTEND
                MP      A
                DAS     MPAC
                TC      USPRCADR
                CADR    SQRT
                CA      MPAC
                TS      ABDELV          # |DELV| IN LM PIPA UNITS OF ONE CM/S/BIT

                EXTEND                  # MAKE A NUMBER FOR THOSE WHO ARE USED
                MP      2SECS           #   TO USING ABDELV AS AN ACCELERATION,
                EXTEND                  #   LIKE 1/ACCS AND THE DELTA-V MONITOR
                DV      PGUIDE1
                TS      ABDVACC         # SAME UNITS AS ABDELV BUT AN ACCELERATION

                EXTEND
                DCA     MASS
                DXCH    MASS1           # INITIALIZE MASS1 IN CASE WE SKIP MASSMON

MASSMON         CS      FLAGWRD8        # ARE WE ON THE SURFACE?
                MASK    SURFFBIT
                EXTEND
                BZF     MOONSPOT        # YES:  BYPASS MASS MESS

                CA      FLGWRD10        # NO:   WHICH VEX SHOULD BE USED?
                MASK    APSFLBIT
                CCS     A
                EXTEND                  # IF EXTEND IS EXECUTED, APSVEX --> A,
                DCA     APSVEX          #   OTHERWISE DPSVEX --> A
                TS      Q

                CA      ABDELV
                EXTEND
                MP      KPIP
                EXTEND
                DV      Q               # WHERE APPROPRIATE VEX RESIDES
                EXTEND
                MP      MASS
                DAS     MASS1

MOONSPOT        CA      KPIP1           # TP MPAC = ABDELV AT 2(14) CM/SEC
                TC      SHORTMP         # MULTIPLY BY KPIP1 TO GET
                        
## Page 856
## The following 5 lines are marked as having changed between ZFLY.048 and ZFLY.049
                EXTEND
                DCA     DVTOTAL
                DAS     MPAC
                DXCH    MPAC
                DXCH    DVTEMP          # PRELIMINARY DVTOTAL, UNITS OF 2(7) M/CS

                TC      TMPTOSPT

                TC      BANKCALL        # COMPUTE SINES AND COSINES FOR FLESHPOT
                CADR    QUICTRIG

                CAF     XNBPIPAD        # COMPUTE BODY-PLATFORM MATRIX
                TC      BANKCALL
                CADR    FLESHPOT

AVERAGEG        CS      FLAGWRD6        # IS MUNFLAG SET?
                MASK    MUNFLBIT
                EXTEND
                BZF     RVBOTH          # YES:  DO DESCENT-ASCENT NAVIGATION

#                                            (FALL THROUGH TO CALCRVG)    NO

# ****************************************************************************************************************
# NAVIGATION USED BY THE P40S NEAR EARTH OR MOON
# ****************************************************************************************************************


CALCRVG         TC      INTPRET
                VLOAD   VXM
                        DELV
                        REFSMMAT
                VXSC    VSL1
                        KPIP1
                STORE   DELVREF
                VSR1    PUSH
                PDDL    VXSC
                        PGUIDE1
                        G
                VAD     VAD
                        VN
                PUSH    VSR
                        8D
                VXSC    VAD
                        PGUIDE1
                        RN
                STCALL  RN1             # VECTOR RN1 IN UNITS OF 2(29) METERS
                        CALCGRAV

                VXSC    VAD
                        PGUIDE1
                VAD     STADR

## Page 857
                STORE   VN1             # VECTOR VN1 IN UNITS OF 2(7) M/CS
                EXIT

                TC      SERVCHNG
                TCF     COPYCYCL

# ****************************************************************************************************************
# NAVIGATION USED BY DESCENT AND ASCENT ONLY
# ****************************************************************************************************************

RVBOTH          TC      INTPRET
                VLOAD   VXSC
                        G(CSM)
                        PGUIDE1
                VAD     PUSH
                        V(CSM)
                VSR3    VXSC
                        PGUIDE1
                VAD
                        R(CSM)
                STCALL  R1S             # CSM POSITION IN UNITS OF 2(24) METERS
                        MUNGRAV
                VXSC
                        PGUIDE1
                VAD     STADR
                STORE   V1S             # CSM VELOCITY IN UNITS OF 2(7) M/CS
                EXIT

                TC      SERVCHNG

                TC      INTPRET
                VLOAD
                        G1
                STOVL   G(CSM)
                        R1S
                STOVL   R(CSM)
                        V1S
                STORE   V(CSM)
                EXIT

                TC      SERVCHNG

MUNRVG          TC      INTPRET
                VLOAD   VXSC
                        DELV
                        KPIP2
                PUSH    PDDL            # PUSH DOWN SCALED DELV TWICE
                        PGUIDE1
                VXSC    VAD
                        G
## Page 858
                VAD     PUSH
                        V
                VSR3    VXSC
                        PGUIDE1
                VAD
                        R
                STCALL  R1S             # VECTOR R1S IN UNITS OF 2(24) METERS
                        MUNGRAV
                VXSC    VAD
                        PGUIDE1
                VAD     STADR
                STORE   V1S             # VECTOR V1S IN UNITS OF 2(7) M/CS
                ABVAL
                STOVL   ABVEL           # ABVEL IN UNITS OF 2(7) M/CS
                        28D
                STODL   UNIT/R/         # ONLY UNIT/R/ COMPUTATION IN MUNGRAV CASE
                        36D
                DSU     RTB             # MPAC MUST BE SIGNAGREED FOR MUNRETRN
                        /LAND/
                        SGNAGREE
                STORE   HCALC           # COPYCYC1 MAY CHANGE THIS HCALC
                EXIT

                CS      FLGWRD11        # IS LRBYPASS SET?
                MASK    LRBYBIT
                EXTEND
                BZF     COPYCYC1        # YES:  BYPASS ALL LANDING RADAR LOGIC

#                                            (FALL THROUGH TO LR LOGIC)

# ****************************************************************************************************************
# LANDING RADAR DATA INCORPORATION
# ****************************************************************************************************************


# ********************************
# LR PRELIMINARIES
# ********************************

#     MUNRETRN DEPENDS ON SEEING HCALC IN MPAC WITH SIGNS AGREED.

MUNRETRN        CA      MPAC            # IS ALT < 1024 METERS?
                EXTEND
                BZF     LROFF?          # YES:  GO CHECK ALTITUDE AGAINST HLROFF

                CS      FLGWRD11        # NO:   IS ALTITUDE ALREADY < 30000 FEET?
                MASK    XORFLBIT
                EXTEND
                BZF     R12             # YES

30KCHK          EXTEND                  # NO:   IS ALT < 30000 FEET NOW?
## Page 859
                DCA     1-30KFT
                DAS     MPAC

                CCS     A
                TCF     R12             # NO:   ALTITUDE STILL > 30000 FEET
                TC      UPFLAG          # YES:   SET X-AXIS OVERRIDE INHIBIT FLAG
                ADRES   XOVINFLG
                TC      UPFLAG
                ADRES   XORFLG

LROFF?          CS      MPAC     +1     # IS ALTITUDE < HLROFF?
                AD      HLROFF
                EXTEND
                BZMF    R12             # NO:   GO TRY UPDATE

                TC      DOWNFLAG        # YES:  RESET LR PERMIT FLAG
                ADRES   LRINH

R12             CS      FLGWRD11        # IS NOLRREAD SET (BY HIGATASK)?
                MASK    NOLRRBIT
                EXTEND
                BZF     CONTSERV        # YES:  BYPASS POSITION CHECK AND UPDATE

POSTST          CA      BITS6+7         # NO:   TEST LR ANTENNA POSITION DISCRETES
                EXTEND
                RAND    CHAN33
                EXTEND
                MP      BIT10           # SHIFT BITS 6 AND 7 TO BITS 1 AND 2

                INDEX   A
                TCF     +1
                TCF     511?            # A = 0 --> BOTH DISCRETES PRESENT
                TCF     POSCHNG?        # A = 1 --> POSITION 2
                TCF     POSCHNG?        # A = 2 --> POSITION 1
511?            CCS     511CTR          # IF CONDITION PERSISTS FOR FIVE
                TCF     ST511CTR        # CONSECUTIVE PASSES,ISSUE 511 ALARM
                TC      ALARM
                OCT     511
                CS      ZERO            # SET CTR TO -0 TO BYPASS ALARM
ST511CTR        TS      511CTR
                TCF     CONTSERV
POSCHNG?        TS      L

                CA      FOUR            # SET 511CTR TO RE-ENABLE 511 ALARM
                TS      511CTR

                LXCH    LRPOS           # UPDATE LRPOS WITH NEW POSITION
                CS      LRPOS
                AD      L               # IS NEWPOS = OLDPOS?
                EXTEND
## Page 860
                BZF     EXTRAPRV        # YES
                TCF     CONTSERV        # NO

#          NOW MUST BE COMPUTED THE ALTITUDE AND VELOCITY VECTORS AT THE TIME OF THE RADAR READING.   THE
# FINAL VALUES OF R AND V FROM THE LAST SERVICER ARE EXTRAPOLATED FORWARD TO LRTIME.   THE CONTENTS OF THE PIPAS
# AT LRTIME WERE STORED IN PIPTEM.   THE RESULTS ARE STORED IN RN1, VN1 AND HLRTIME FOR POSUPDAT AND VELUPDAT.

#     ALSO EXTRAPRV COMPUTES A BODY-PLATFORM MATRIX VALID AT LRTIME AND STORES IT AT XNBRAD.   THIS IS USED BY
# POSUPDAT AND VELUPDAT TO CONVERT BEAM VECTORS TO PLATFORM COORDINATES.

EXTRAPRV        CAF     EBANK4
                EBANK=  PIPTEM
                TS      EBANK

                CA      LRYCDU
                TS      CDUSPOTY
                CA      LRZCDU
                TS      CDUSPOTZ
                CA      LRXCDU
                TS      CDUSPOTX

                TC      BANKCALL        # PREPARE SINES AND COSINES FOR FLESHPOT
                CADR    QUICTRIG

                CAF     XNBRADAD        # COMPUTE MATRIX XNBRAD VALIB AT LRTIME
                TC      BANKCALL        #   (CAN'T USE *NBSM* LATER BECAUSE P66ROD
                CADR    FLESHPOT        #   COULD CLOBBER SINES AND COSINES)

                INHINT                  # INHINT FOR PIPNORM, INTPRET WILL RELINT
                CS      PIPAXOLD
                AD      PIPTEM
                TC      PIPNORM
                DXCH    MPAC
                CS      PIPAYOLD
                AD      PIPTEM   +1
                TC      PIPNORM
                DXCH    MPAC     +3
                CS      PIPAZOLD
                AD      PIPTEM   +2
                TC      PIPNORM
                DXCH    MPAC     +5

                CS      PIPTIME  +1
                AD      LRTIME   +1
                AD      HALF
                AD      HALF
                ZL
                INDEX   FIXLOC
                DXCH    12D

## Page 861
                CA      EBANK7
                EBANK=  DVCNTR
                TS      EBANK

                CS      ONE             # SET MODE TO VECTOR
                TS      MODE

                TC      INTPRET
                VXSC    PUSH
                        KPIP2
                PDDL    VXSC
                        12D
                        G
                VAD     VAD
                        V
                PUSH    VSR3
                VXSC    VAD
                        12D
                        R
                STCALL  RN1             # IN RN1 POSITION AT TIME OF READING
                        MUNGRAV
                VXSC    VAD
                        12D
                VAD     STADR
                STODL   VN1             # IN VN1 VELOCITY AT TIME OF READING
                        36D
                DSU
                        /LAND/
                STORE   HLRTIME         # ALTITUDE AT TIME OF RADAR READ
                EXIT

# ***********************************
# ALTITUDE UPDATE (CUM TERRAIN MODEL)
# ***********************************

HMEASCHK        CA      FLGWRD11        # WAS ALT READING MADE THIS PASS?
                MASK    RNGEDBIT
                EXTEND
                BZF     VMEASCHK        # NO:   CHECK FOR VELOCITY MEASUREMENT

POSUPDAT        TC      SERVCHNG        # YES
                TC      POSINDEX        # SET X1 ACCORDING TO ANTENNA POSITION

                TC      INTPRET
                VLOAD*  VXM             # CONVERT PROPER HBEAM FROM NB TO SM
                        HBEAMNB,1
                        XNBRAD
                PDDL    SL              # STORE IN PL AND SCALE HMEAS
                        HMEAS
                        6D
## Page 862
                DMP     VXSC            # SLANT RANGE AT 2(22), PUSH UP FOR HBEAM
                        HSCAL           # SLANT RANGE VECTOR AT 2(23) M
                PUSH    DOT             # PUSH NEG OF RADAR ALTITUDE BEAM VECTOR
                        UNIT/R/         # ALTITUDE AT 2(24) METERS
                DSU     PDDL            # PUSH PARTIAL DELTA H, LOAD NEG OF BEAM Z
                        HLRTIME
                SR1     DAD
                        LAND     +4
                BDSU    SL              # SCALE RANGE TO UNITS OF 2(18) METERS
                        RN1      +4     # WHERE EXTRAPRV LEFT POSITION AT LRTIME
                        6D
                BOVB    EXIT
                        SIGNMPAC        # PICK UP NEGMAX UPON OVERFLOW

                CS      FLAGWRD1        # IS NOTERFLG SET (BY P66 OR V68)?
                MASK    NOTERBIT
                EXTEND
                BZF     TERSKIP         # Y: SKIP TERRAIN BUT TRANSFER DELTA H

                CA      EBANK5          # N: PREPARE TO ACCESS TERRAIN TABLE
                TS      EBANK
                EBANK=  END-E5

                CA      ZERO            # INITIALIZE MINUS LAST ABSCISSA FOR
                TS      TEM2            #   TERLOOP WHICH ADDS THE CONTRIBUTIONS
                CA      FOUR            #   OF FIVE TERRAIN SEGMENTS TO DELTA H
TERLOOP         TS      TEM5

                CA      MPAC            # PICK UP CURRENT RANGE (NEG BEFORE SITE)
                TS      L
                INDEX   TEM5
                CS      ABSC0           # TERRAIN ABSCISSAE UNITS: 2(18) METERS
                TC      BANKCALL        # LIMIT GIVEN LIMITSUB MUST BE POSITIVE
                FCADR   LIMITSUB        # LIMIT |RANGE| <= |CURRENT ABSCISSA|
                TS      TEM4            # SAVE TO COMPARE WITH CURRENT ABSCISSA

                AD      TEM2            # SUBTRACT LAST ABSCISSA
                EXTEND
                INDEX   TEM5
                MP      SLOPE0          # SLOPE UNITS: 2(6) RADIANS. RESOL: 3.9 MR

                INDEX   FIXLOC          # ADD CONTRIBUTION OF SEGMENT TO YIELD
                DAS     4               #   CORRECTED DELTAH IN UNITS 2(24) METERS

                CA      TEM1            # RETRIEVE MINUS CURR ABSC FROM LIMITSUB*
                TS      TEM2            # STORE AS MINUS LAST ABSC FOR NEXT SEG

# * NOTE:  IF WE HAVE FLOWN BEYOND THE LANDING SITE BY MORE THAN THE
#          LENGTH OF THE SEGMENT ADJACENT TO THE LANDING SITE, CA TEM1
#          WILL RETRIEVE - INSTEAD OF MINUS THE CURRENT ABSCISSA -
## Page 863
#          A ZERO OR POSITIVE REMAINDER OF THE DIVISION DONE BY LIMITSUB.
#          THIS RETRIEVAL WILL CAUSE AN IMMEDIATE BRANCH TO TEREND,
#          WHICH IS THE DESIRED RESULT.  HOWEVER, FLYING PAST THE LANDING
#          SITE IS IMPOSSIBLE EXCEPT IN P66 WHEN THE TERRAIN MODEL IS OFF.

                AD      TEM4            # HAS LM FLOWN PAST CURRENT ABSCISSA?
                EXTEND
                BZF     +2
                TCF     TEREND          # Y: IGNORE FURTHER ABSCISSAE
                CCS     TEM5            # N: IS CURRENT ABSCISSA THE LAST?
                TCF     TERLOOP         # N: REPEAT TERRAIN LOOP

TEREND          CA      EBANK7          # Y: RESTORE EBANK AND DEPART
                TS      EBANK
                EBANK=  END-E7

TERSKIP         INDEX   FIXLOC          # TRANSFER COMPLETED DELTA H HOME
                DXCH    4               #   TO BE ACCESSED BY DISPLAYS, TELEMETRY,
                DXCH    DELTAH          #   AND POSITION UPDATE WHICH FOLLOWS

                CA      FIXLOC          # RESTORE PUSHDOWN POINTER TO ZERO
                TS      PUSHLOC

                CA      FLGWRD11        # IS PSTHIBIT SET (BY HIGATASK)?
                MASK    PSTHIBIT
                EXTEND
                BZF     NOREASON        # NO:   DON'T DO REASONABILITY TEST YET

                TC      INTPRET         # YES:  DO REASONABILITY TEST
                DLOAD   ABS
                        DELTAH
                DSU     SL3             # ABS(DELTAH) - DQFIX
                        DELQFIX
                DSU     EXIT            # ABS(DELTAH) - (DQFIX + HLRT/8) AT 2(21)
                        HLRTIME
                INCR    LRLCTR
                TC      BRANCH
                TCF     HFAIL           # DELTA H TOO LARGE
                TCF     HFAIL           # DELTA H TOO LARGE
                TC      DOWNFLAG        # RESET HFAIL FLAG
                ADRES   HFAILFLG
                TC      DOWNFLAG        # TURN OFF ALT FAIL LAMP
                ADRES   HFLSHFLG

NOREASON        CS      FLGWRD11        # IS UPDATE INHIBITED?
                MASK    LRINHBIT
                CCS     A
                TCF     VMEASCHK        # YES:  TEST VELOCITY ANYWAY

                EXTEND                  # RESCALE HLRTIME TO UNITS OF 2(28) METERS
## Page 864
                DCA     HLRTIME
                DXCH    MPAC
                CAF     BIT11
                TC      SHORTMP

                EXTEND
                DCA     DELTAH          # STORE DELTAH IN MPAC AND
                DXCH    MPAC            # BRING HCALC INTO A,L
                TC      ALSIGNAG
                EXTEND                  # IF HIGH PART OF HCALC IS NON ZERO, THEN
                BZF     +2              # HCALC > HMAX,
                TCF     VMEASCHK        # SO UPDATE IS BYPASSED
                TS      MPAC +2         #   FOR LATER SHORTMP

                CS      L               # -H AT 2(14)M
                AD      LRHMAX          # HMAX - H
                EXTEND
                BZMF    VMEASCHK        # IF H >HMAX, BYPASS UPDATE
                EXTEND
                MP      LRWH            # WH(HMAX - H)
                EXTEND
                DV      LRHMAX          # WH(1 - H/HMAX)
                TS      MPTEMP
                TC      SHORTMP2        # DELTAH (WH)(1 - H/HMAX) IN MPAC
                TC      INTPRET         # MODE IS DP FROM ABOVE
                SL1
                VXSC    VAD
                        UNIT/R/         # DELTAR = DH(WH)(1 - H/HMAX) UNIT/R/
                        R1S
                STORE   GNUR            # CORRECTED R AT PIPTIME1 (NEW G1 WILL
                EXIT                    #   BE COMPUTED AT COPYCYC1)

                TC      SERVCHNG

                EXTEND
                DCA     GNUR
                DXCH    R1S
                EXTEND
                DCA     GNUR     +2
                DXCH    R1S      +2
                EXTEND
                DCA     GNUR     +4
RUPDATED        DXCH    R1S      +4

# ********************************
# VELOCITY UPDATE
# ********************************

VMEASCHK        TC      SERVCHNG
                CS      FLGWRD11
## Page 865
                MASK    VELDABIT        # IS V READING AVAILABLE?
                CCS     A
                TCF     VALTCHK         # NO   SEE IF V READING TO BE TAKEN

VELUPDAT        TC      SERVCHNG        # YES
                TC      POSINDEX        # SET X1 ACCORDING TO ANTENNA POSITION

                CS      VSELECT
                TS      L
                ADS     L               # -2 VSELECT IN L
                AD      L
                AD      L               # -6 VSELECT IN A
                INDEX   FIXLOC
                DAS     X1              # X1 = -6 VSELECT + POS, X2 = -2 VSELECT

                CA      FIXLOC
                TS      PUSHLOC         # SET PD TO ZERO

                TC      INTPRET
                VLOAD*  VXM             # CONVERT PROPER VBEAM FROM NB TO SM
                        VZBEAMNB,1
                        XNBRAD
                PDDL    SL              # STORE IN PD 0-5
                        VMEAS           # LOAD VELOCITY MEASUREMENT
                        12D
                DMP*    PDVL            # SCALE TO M/CS AT 2(6)
                        VZSCAL,2        # AND STORE IN PD 6-7
                        VN1             # VELOCITY AT TIME OF READING
                VSL2    VSU             # SCALE TO UNITS OF 2(5) M/CS AND
                        VSURFACE        #   SUBTRACT SURFACE VELOCITY
                PUSH    ABVAL           # STORE IN PD
                SR4     DAD             # ABS(VM)/8 + VELBIAS AT 2(6)
                        VELBIAS
                STOVL   20D             # STORE IN 20D AND PICK UP VM
                DOT     BDSU            # V(EST) AT 2(6)
                        0               # DELTAV = VMEAS - V(EST)
                PUSH    ABS
                DSU     EXIT            # ABS(DV) - (7.5 + ABS(VM)/8))
                        20D

                INCR    LRMCTR
                TC      BRANCH
                TCF     VFAIL           # DELTA V TOO LARGE     ALARM
                TCF     VFAIL           # DELTA V TOO LARGE     ALARM

                TC      DOWNFLAG        # RESET HFAIL FLAG
                ADRES   VFAILFLG
                TC      DOWNFLAG        # TURN OFF VEL FAIL LAMP
                ADRES   VFLSHFLG

## Page 866
                CA      FLGWRD11
                MASK    VXINHBIT
                EXTEND
                BZF     VUPDAT          # IF VX INHIBIT RESET, INCORPORATE DATA.

                TC      DOWNFLAG
                ADRES   VXINH           # RESET VX INHIBIT

                CA      VSELECT
                AD      NEG2            # IF VSELECT = 2 (X AXIS),
                EXTEND                  # BYPASS UPDATE
                BZF     ENDVDAT

VUPDAT          CS      FLGWRD11
                MASK    LRINHBIT
                CCS     A
                TCF     VALTCHK         # UPDATE INHIBITED

                TS      MPAC +1

                CA      ABVEL           # STORE E7 ERASABLES NEEDED IN TEMPS
                TS      ABVEL*
                CA      VSELECT
                TS      VSELECT*
                CA      EBANK5
                TS      EBANK           # CHANGE EBANKS

                EBANK=  LRVF
                CS      LRVF
                AD      ABVEL*          # IF V < VF, USE WVF
                EXTEND
                BZMF    USEVF

                CS      ABVEL*
                AD      LRVMAX          # VMAX - V
                EXTEND
                BZMF    WSTOR -1        # IF V > VMAX, W = 0

                EXTEND
                INDEX   VSELECT*
                MP      LRWVZ           # WV(VMAX - V)

                EXTEND
                DV      LRVMAX          # WV( 1 - V/VMAX )
                TCF     WSTOR

USEVF           INDEX   VSELECT*
                CA      LRWVFZ          # USE APPROPRIATE CONSTANT WEIGHT
                TCF     WSTOR

## Page 867
 -1             CA      ZERO
WSTOR           TS      MPAC
                CS      BIT7            # IS CURRENT PROGRAM P66?
                AD      MODREG
                EXTEND
                BZMF    +3              # NO

                CA      LRWVFF          # YES
                TS      MPAC

 +3             CA      EBANK7
                TS      EBANK           # CHANGE EBANKS

                EBANK=  ABVEL
                TC      INTPRET
                DMP     VXSC            # W(DELTA V)(VBEAMSM)  UP 6-7, 0-5
                VAD
                        V1S             # ADD WEIGHTED DELTA V TO VELOCITY
                STORE   GNUV            # CORRECTED V AT PIPTIME1
                EXIT

                TC      SERVCHNG

                EXTEND
                DCA     GNUV
                DXCH    V1S
                EXTEND
                DCA     GNUV     +2
                DXCH    V1S      +2
                EXTEND
                DCA     GNUV     +4
VUPDATED        DXCH    V1S      +4

ENDVDAT         =       VALTCHK

VALTCHK         TC      SERVCHNG        # DO NOT REPEAT ABOVE

HIGATCHK        CS      FLGWRD11        # IS PSTHIBIT SET?
                MASK    PSTHIBIT
                EXTEND
                BZF     CONTSERV        # YES

                CA      TTF/8           # NO
                AD      RPCRTIME
                EXTEND
                BZMF    CONTSERV

                CA      EBANK4
                XCH     EBANK
                TS      L

## Page 868
                EBANK=  XNBPIP
                CS      XNBPIP
                EBANK=  DVCNTR
                LXCH    EBANK
                AD      RPCRTQSW
                EXTEND
                BZMF    HIGATASK

CONTSERV        TC      SERVCHNG
                INHINT
                CS      BITS4-7
                MASK    FLGWRD11        # CLEAR LR MEASUREMENT MADE DISCRETES.
                TS      FLGWRD11

#          NOTE THAT R12READ (AND RDGIMS) IS NOT RESTART PROTECTED.   IF THERE SHOULD BE A RESTART, THIS
# READING SIMPLY IS NOT MADE.

                CAF     BIT1            # NOW SAFE TO MAKE A READING
                TC      WAITLIST
                EBANK=  VSELECT
                2CADR   R12READ


#                                            (FALL THROUGH TO COPYCYC1)

# ****************************************************************************************************************
# COPYCYCLE CODING
# ****************************************************************************************************************

COPYCYC1        TC      SERVCHNG

                CA      FIXLOC          # BATTEN DOWN THE HATCHES
                TS      PUSHLOC

                TC      INTPRET
                VLOAD   CALL            # RECOMPUTE G1 IN CASE LR UPDATED R1S
                        R1S
                        MUNGRAV
                DLOAD   DSU
                        36D
                        /LAND/
                STORE   HCALC           # ALTITUDE IN UNITS OF 2(24) METERS
                SL      PDVL            # STORE HCALCLAD AT PD 0
                        9D
                        UNIT/R/
                VXV     ABVAL
                        V1S
                DSQ     DDV
                        36D
                SL1     PDVL            # STORE DALTRATE AT PD 2
## Page 869
                        UNIT/R/
                DOT     SL1
                        V1S
                STORE   HDOTDISP        # HDOT IN UNITS OF 2(7) M/CS
                SL2     PDVL            # STORE HDOTLAD AT PD 4
                        WM
                VXV     VSL2
                        R1S
                STOVL   VSURFACE        # SURFACE VELOCITY IN UNITS OF 2(5) M/CS
                        R1S             #   (NO NEED TO LOAD VSURFACE UNDER INHINT
                VXM     VSR4            #   BECAUSE IT CHANGES ONLY VERY SLOWLY)
                        REFSMMAT
                STOVL   RN1             # POSITION IN REFERENCE COORDINATES
                        V1S
                VXM     VSL1
                        REFSMMAT
                STOVL   VN1             # VELOCITY IN REFERENCE COORDINATES
                        G1
                VSL3    EXIT            # GRAVACC IN MPAC UNITS OF 2(-9) M/CS/CS

                INHINT                  # INHINT TO PREVENT DOWNRUPT OR QUARTASK

                INDEX   FIXLOC          # FETCH HCALCLAD FROM PD 0
                DXCH    0
                DXCH    HCALCLAD        # ALTITUDE IN UNITS OF 2(15) METERS

                INDEX   FIXLOC          # FETCH DALTRATE FROM PD 2
                DXCH    2
                TS      DALTRATE        # DALTRATE IN UNITS OF 2(-9) M/CS/CS
    
                INDEX   FIXLOC          # FETCH HDOTLAD FROM PD 4
                DXCH    4
                DXCH    HDOTLAD         # HDOTLAD IN UNITS OF 2(5) M/CS

                CA      MPAC
                TS      GRAVACCX        # GRAVACCX IN UNITS OF 2(-9) M/CS/CS
                CA      MPAC     +3
                TS      GRAVACCY        # GRAVACCY IN UNITS OF 2(-9) M/CS/CS
                CA      MPAC     +5
                TS      GRAVACCZ        # GRAVACCZ IN UNITS OF 2(-9) M/CS/CS

                EXTEND
                DCA     UNIT/R/
                DDOUBL                  # SCALE FULL-SIZE BUT WATCH FOR OVERFLOW
                OVSK
                TCF     +2
                CAF     POSMAX
 +2             XCH     RUNITX

                EXTEND
## Page 870
                DCA     UNIT/R/  +2
                DDOUBL                  # SCALE FULL-SIZE, OVERFLOW MOST UNLIKELY
                XCH     RUNITY

                EXTEND
                DCA     UNIT/R/  +4
                DDOUBL                  # SCALE FULL-SIZE, OVERFLOW MOST UNLIKELY
                XCH     RUNITZ

                EXTEND
                DCA     R1S
                DXCH    R
                EXTEND
                DCA     R1S +2
                DXCH    R +2
                EXTEND
                DCA     R1S +4
                DXCH    R +4
                EXTEND
                DCA     V1S
                DXCH    V
                EXTEND
                DCA     V1S +2
                DXCH    V +2
                EXTEND
                DCA     V1S +4
                DXCH    V +4

                CS      FLAGWRD7        # INDICATE TO LANADISP THAT THE NUMBERS IT
                MASK    SWANDBIT        #   NEEDS FROM SERVICER HAVE BEEN PROVIDED
                ADS     FLAGWRD7

COPYCYCL        INHINT                  # ENTER HERE FROM CALCRVG

                CA      PGUIDE1
                TS      SERVDURN        # FOR DOWNLINK

                CA      PIPATMPX
                TS      PIPAXOLD
                CA      PIPATMPY
                TS      PIPAYOLD
                CA      PIPATMPZ
                TS      PIPAZOLD

                EXTEND
                DCA     DVTEMP
                DXCH    DVTOTAL

                TC      COPYCYC         # COPY RN1 - MASS1 INTO RN - MASS

## Page 871
                TC      SERVCHNG

#                                         (FALL THROUGH TO DVMON, STILL UNDER INHINT)

# ****************************************************************************************************************
# DVMON
# ****************************************************************************************************************

DVMON           CS      STEERBIT        # STEERSW IS RESET IF THRUST IS ADEQUATE
                MASK    FLAGWRD2
                TS      FLAGWRD2

                CAF     IDLEFBIT        # IS THE IDLE FLAG SET?
                MASK    FLAGWRD7
                CCS     A
                TCF     NODVMON1        # IDLEFLAG = 1, HENCE SET AUXFLAG TO 0.

                CS      FLAGWRD6
                MASK    AUXFLBIT
                CCS     A
                TCF     NODVMON2        # AUXFLAG = 0, HENCE SET AUXFLAG TO 1.

                CS      DVTHRUSH        # DOES THRUST EXCEED CRITERION DVTHRUSH?
                AD      ABDVACC
                EXTEND
                BZMF    LOTHRUST        # NO

                CS      FLAGWRD2        # YES: SET STEERSW
                MASK    STEERBIT
                ADS     FLAGWRD2

DVCNTSET        CAF     ONE             # ALLOW TWO PASSES MAXIMUM NOW THAT
                TS      DVCNTR          # THRUST HAS BEEN DETECTED.

                CA      FLGWRD10        # BRANCH IF APSFLAG IS SET.
                MASK    APSFLBIT
                CCS     A
                TCF     USEJETS

                CA      BIT9            # CHECK GIMBAL FAIL BIT
                EXTEND
                RAND    CHAN32
                EXTEND
                BZF     USEJETS

USEGTS          CS      USEQRJTS
                MASK    DAPBOOLS
                TS      DAPBOOLS
                TCF     DVMONEND

## Page 872
NODVMON1        CS      AUXFLBIT        # SET AUXFLAG TO 0.
                MASK    FLAGWRD6
                TS      FLAGWRD6
                TCF     USEJETS

NODVMON2        CS      FLAGWRD6        # SET AUXFLAG TO 1.
                MASK    AUXFLBIT
                ADS     FLAGWRD6
                TCF     USEJETS

LOTHRUST        TC      SERVCHNG
                CCS     DVCNTR
                TCF     DECCNTR

                CCS     PHASE4          # COMFAIL JOB ACTIVE?
                TCF     DVMONEND

                TC      PHASCHNG        # 4.37SPOT FOR COMFAIL.
                OCT     00374

                CAF     PRIO25
                TC      NOVAC
                EBANK=  WHICH
                2CADR   COMFAIL

                TCF     DVMONEND

DECCNTR         TS      DVCNTR1
                TC      SERVCHNG
                CA      DVCNTR1
                TS      DVCNTR
                TC      IBNKCALL        # IF THRUST IS LOW, NO STEERING IS DONE
                CADR    STOPRATE        # AND THE DESIRED RATES ARE SET TO ZERO.
USEJETS         CS      DAPBOOLS
                MASK    USEQRJTS
                ADS     DAPBOOLS
DVMONEND        RELINT

# ****************************************************************************************************************
# EXIT TO GUIDANCE EQUATIONS
# ****************************************************************************************************************

#          RULES FOR USERS OF SERVICER:

#          DO NOT GO TO ENDOFJOB.   RETURN TO THE START OF SERVICER AT PIPCYCLE.   INSURE THAT ALL BRANCHES LEAD
# EVENTUALLY TO PIPCYCLE.

#          USE GROUP 5 AS RESTART GROUP AND USE A "TC SERVCHNG" (WHICH IS IN FIXED-FIXED) WHENEVER POSSIBLE
# FOR RESTART PROTECTION.

## Page 873
#          AVOID CHANGING PRIORITY EXCEPT BEFORE CALLING DISPLAY ROUTINES WHICH WILL SET UP OFF-LINE JOBS.
# IN THIS CASE RAISE PRIORITY TO 23 AND RESTORE TO 20 AS SOON AS POSSIBLE.

                TC      BANKCALL
                CADR    1/ACCS

                CA      PRIORITY
                MASK    LOW9
                TS      PUSHLOC
                ZL
                DXCH    FIXLOC          # FIXLOC AND OVFIND

                TC      SERVCHNG

                TC      UPFLAG          # SET SERVOVER FLAG TO INDICATE THAT
                ADRES   SERVOVER        #   SERVICER IS THROUGH FOR THIS PASS

SERVOUT         EXTEND                  # EXIT TO SELECTED ROUTINE WHETHER THERE
                DCA     AVGEXIT         #   IS THRUST OR NOT.   STEERSW WILL
                DXCH    Z               #   CONVEY THIS INFORMATION.

# ****************************************************************************************************************
# COME HERE VIA AVGEXIT ON LAST SERVICER PASS
# ****************************************************************************************************************

AVGEND          CA      PIPTIME +1      # FINAL AVERAGE G EXIT
                TS      1/PIPADT        # SET UP FREE FALL GYRO COMPENSATION.

                TC      UPFLAG          # SET DRIFT FLAG.
                ADRES   DRIFTFLG

                TC      BANKCALL
                CADR    PIPFREE

                CS      BIT9
                EXTEND
                WAND    DSALMOUT

                TC      2PHSCHNG
                OCT     5               # GROUP 5 OFF
                OCT     05022           # GROUP 2 ON
                OCT     20000

                TC      INTPRET
                CLEAR
                        SWANDISP        # SHUT OFF R10 WHEN SERVICER ENDS.
                CLEAR   CALL            # RESET MUNFLAG.
                        MUNFLAG
                        AVETOMID
                CLEAR   EXIT
## Page 874
                        V37FLAG
AVERTRN         TC      POSTJUMP
                CADR    V37RET

OUTGOAVE        =       AVERTRN

# ****************************************************************************************************************
# COME HERE FROM POODOO TO CURTAIL BUT NOT HALT SERVICER
# ****************************************************************************************************************

SERVIDLE        EXTEND                  # DISCONNECT SERVICER FROM ALL GUIDANCE
                DCA     CYCLEADR
                DXCH    AVGEXIT

                CS      FLAGWRD7        # DISCONNECT THE DELTA-V MONITOR
                MASK    IDLEFBIT
                ADS     FLAGWRD7

                CAF     LRBYBIT         # TERMINATE R12 IF RUNNING.
                TS      FLGWRD11

                EXTEND
                DCA     NEG0
                DXCH    -PHASE1

                CA      FLAGWRD6        # DO NOT TURN OFF PHASE 2 IF MUNFLAG SET.
                MASK    MUNFLBIT
                CCS     A
                TCF     +4

                EXTEND
                DCA     NEG0
                DXCH    -PHASE2

 +4             EXTEND
                DCA     NEG0
                DXCH    -PHASE3

                EXTEND
                DCA     NEG0
                DXCH    -PHASE6

                CAF     OCT33           # 4.33SPOT FOR GOPOOFIX
                TS      L
                COM
                DXCH    -PHASE4

                TCF     WHIMPER         # PERFORM A SOFTWARE RESTART AND PROCEED
                                        # TO GOTOPOOH WHILE SERVICER CONTINUES TO
                                        # RUN, ALBEIT IN A GROUND STATE WHERE
## Page 875
                                        # ONLY STATE-VECTOR DEPENDENT FUNCTIONS
                                        # ARE MAINTAINED.

# ****************************************************************************************************************
# MISCELLANEOUS OFF-LINE LANDING RADAR TASKS AND JOBS
# ****************************************************************************************************************

# ********************************
# HFAIL AND VFAIL
# ********************************

#          ENTER HFAIL FROM MAIN-LINE SERVICER IF ALTITUDE REASONABLENESS TEST IS FAILED.

HFAIL           TC      UPFLAG          # SET HFAIL FLAG FOR DOWNLINK
                ADRES   HFAILFLG
                CS      LRRCTR
                EXTEND
                BZF     NORLITE         # IF R = 0, DO NOT TURN ON TRK FAIL
                AD      LRLCTR
                MASK    NEG3
                EXTEND                  # IF L-R LT 4, DO NOT TURN ON TRK FAIL
                BZF     +2
                TCF     NORLITE

                TC      UPFLAG          # AND SET BIT TO TURN ON TRACKER FAIL LITE
                ADRES   HFLSHFLG

NORLITE         CA      LRLCTR
                TS      LRRCTR          # SET R = L

                TCF     VMEASCHK


#          ENTER VFAIL FROM MAIN-LINE SERVICER IF VELOCITY REASONABLENESS TEST IS FAILED.

VFAIL           TC      UPFLAG          # SET VFAIL FLAG FOR DOWNLINK
                ADRES   VFAILFLG
                CS      LRSCTR
                EXTEND                  # IF S = 0, DO NOT TURN ON TRACKER FAIL
                BZF     NOLITE
                AD      LRMCTR          # M-S
                MASK    NEG3            # TEST FOR M-S > 3
                EXTEND                  # IF M-S > 3, THEN TWO OR MORE OF THE
                BZF     +2              #   LAST FOUR V READINGS WERE BAD,
                TCF     NOLITE          #   SO TURN ON VELOCITY FAIL LIGHT

## The following two instructions are surrounded by drawn-in parentheses.
                TC      UPFLAG          # AND SET BIT TO TURN ON TRACKER FAIL LITE
                ADRES   VFLSHFLG

NOLITE          CA      LRMCTR          # SET S = M
## Page 876
                TS      LRSCTR

                CCS     VSELECT         # TEST FOR Z COMPONENT
                TCF     ENDVDAT         # NOT Z, DO NOT SET VX INHIBIT

                TC      UPFLAG          # Z COMPONENT - SET FLAG TO SKIP X
                ADRES   VXINH           # COMPONENT,AS ERROR MAY BE DUE TO CROSS
                TCF     ENDVDAT         # LOBE LOCK UP NOT DETECTED ON X AXIS

# ********************************
# HIGATASK
# ********************************

#          HIGATASK IS ENTERED APPROXIMATELY 6 SECONDS BEFORE HIGATE IN THE DESCENT PHASE.   HIGATASK SETS THE 
# HIGATE FLAG (BIT11) AND THE NO LR READ FLAG (BIT10) OF LRSTAT ALIAS FLAGWORD 11.   THE HIGATJOB IS SET UP TO 
# REPOSITION THE LR ANTENNA FROM POSITION 1 TO POSITION 2.   IF THE REPOSITIONING IS SUCESSFUL THE ALT BEAM AND
# VELOCITY BEAMS ARE TRANSFORMED TO THE NEW ORIENTATION IN NB COORDINATES AND STORED IN ERASABLE.   THIS
# TRANSFORMATION IS PERFORMED AT SETPOS2.

HIGATASK        CS      FLGWRD11        # SET PSTHIGAT AND NOLRREAD FLAGS
                MASK    PRIO3
                ADS     FLGWRD11

                CCS     PHASE1          # AVOID MULTIPLE HIGATJOBS
                TCF     CONTSERV

                TC      PHASCHNG        # 1.5SPOT FOR HIGATJOB
                OCT     51

                CA      PRIO32
                TC      FINDVAC         # COULD IT BE NOVAC NOW THAT SETPOS2 OUT
                EBANK=  HMEAS
                2CADR   HIGATJOB


                TCF     CONTSERV

# ********************************
# POSINDEX
# ********************************

#     THIS ROUTINE SETS X1 ACCORDING TO CURRENT ANTENNA POSITION AS INDICATED BY LRPOS.   IT ALSO ZEROES X2
# AND THE PUSHDOWN POINTER.   IT IS CALLED BY POSUPDAT AND VELUPDAT.

POSINDEX        CA      FIXLOC          # ZERO PUSHDOWN POINTER
                TS      PUSHLOC
                CAF     BIT1
                MASK    LRPOS           # NOTE: LRPOS = 1 FOR POS 2 AND VICE VERSA
                CCS     A
                CS      OCT30           # POS 2: INDEX = -24D
## Page 877
                ZL                      # POS 1: INDEX = 0; X2 = 0 FOR BOTH
                INDEX   FIXLOC
                DXCH    X1              # SET X1 AND X2
                TC      Q

# ********************************
# HIGATJOB
# ********************************

#     HIGATJOB IS SET UP WHEN BOTH THE TIME AND ANGLE CRITERIA FOR ANTENNA REPOSITIONING ARE MET.   THIS JOB
# INITIATES THE LANDING RADAR ANTENNA REPOSITIONING ROUTINE.   DURING THE REPOSITIONING R12 IS INHIBITED BY THE
# NOLRREAD FLAG, WHICH IS SET BY HIGATASK OR IN CASE OF A RESTART POSSIBLY BY REREPOS.   UPON COMPLETION OF
# REPOSITIONING, WHETHER SUCESSFUL OR NOT, NOLRREAD FLAG IS CLEARED AND R1

                SETLOC  SERV2
                BANK
                EBANK=  END-E7
                COUNT*  $$/SERV

REREPOS         INHINT                  # ON RESTART, SET FLAGS AGAIN
                CS      FLGWRD11
                MASK    PRIO3
                ADS     FLGWRD11

HIGATJOB        TC      BANKCALL        # INITIATE REPOSITIONING ROUTINE
                CADR    LRPOS2
                TC      BANKCALL        # DELAY UNTIL FINISHED
                CADR    RADSTALL

                TCF     +1              # IF UNSUCCESSFUL, R12 WILL HANDLE THINGS
                CA      ONE             # INDICATE POS 2 IS EXPECTED
                TS      LRPOS

                TC      DOWNFLAG        # RE-ENABLE R12.
                ADRES   NOLRREAD

                TC      PHASCHNG        # CLEAR RESTART PROTECTION
                OCT     1
                TC      ENDOFJOB

# ********************************
# RDGIMS
# ********************************

#          RDGIMS IS SET UP TO SNATCH THE PIPAS AND CDUS AT THE MIDPOINT OF THE COMBINED ALTITUDE AND VELOCITY
# LANDING RADAR READ.

                EBANK=  LRTIME
                
RDGIMS          EXTEND
## Page 878
                DCA     TIME2
                DXCH    LRTIME

                EXTEND
                DCA     CDUX
                DXCH    LRXCDU

                CA      CDUZ
                TS      LRZCDU

                CA      PIPAX
                TS      PIPTEM

                EXTEND
                DCA     PIPAY
                DXCH    PIPTEM   +1

                TC      TASKOVER

# ****************************************************************************************************************
# GRAVITY CALCULATION SUBROUTINES
# ****************************************************************************************************************

                EBANK=  DVCNTR

# ********************************
# CALCGRAV
# ********************************

CALCGRAV        UNIT    PUSH            # SAVE UNIT/R/ IN PUSHLIST            (18)
                STORE   UNIT/R/
                LXC,1   SLOAD           # RTX2 = 0 IF EARTH ORBIT, =2 IF LUNAR.
                        RTX2
                        X1
                BMN
                        CALCGRV1
                VLOAD   DOT             #                                     (12)
                        UNITZ
                        UNIT/R/
                SL1     PUSH            #                                     (14)
                DSQ     BDSU
                        DP1/20
                PDDL    DDV
                        RESQ
                        34D             # (RN)SQ
                STORE   32D             # TEMP FOR (RE/RN)SQ
                DMP     DMP
                        20J
                VXSC    PDDL
                        UNIT/R/
## Page 879
                DMP     DMP
                        2J
                        32D
                VXSC    VSL1
                        UNITZ
                VAD     STADR
                STORE   UNITGOBL
                VAD     PUSH            # MPAC CONTAINS UNIT GRAVITY VECTOR
CALCGRV1        DLOAD   NORM            # PERFORM A NORMALIZATION ON RMAGSQ IN
                        34D             # ORDER TO BE ABLE TO SCALE THE MU FOR
                        X2              # MAXIMUM PRECISION.
                BDDV*   SLR*
                        -MUEARTH,1
                        0 -15D,2
                VXSC    STADR
                STORE   G1              # ACCELERATION IN UNITS OF 2(-6) M/CS/CS
                RVQ

# ********************************
# MUNGRAV
# ********************************

                SETLOC  SERV1
                BANK
                EBANK=  G
                COUNT*  $$/SERV

MUNGRAV         UNIT
                STODL   28D
                        34D
                SL      BDDV
                        5
                        -MUMOON
                VXSC
                        28D
                STORE   G1              # ACCELERATION IN UNITS OF 2(-6) M/CS/CS
                RVQ

# ****************************************************************************************************************
# SERVICER SUBROUTINES (PIPASR APPEARS SEPARATELY)
# ****************************************************************************************************************

# ********************************
# PIPSRINE
# ********************************

#          SINCE SERVICER'S PIPA READING IS NOW IN-LINE, THIS PIPA READER IS PROVIDED FOR THE USE OF P57.
# PIPSRINE IS NOT RESTART PROTECTED BECAUSE P57 ONLY CARES ABOUT DIRECTION, NOT MAGNITUDE, OF DELV.

PIPAREAD        INHINT

## Page 880
                CS      ZERO
                XCH     PIPAX
                ZL
                DXCH    DELVX
                CS      ZERO
                XCH     PIPAY
                ZL
                DXCH    DELVY
                CS      ZERO
                XCH     PIPAZ
                ZL
                DXCH    DELVZ
                RELINT
                TC      Q

# ********************************
# SERVCHNG
# ********************************

#          SERVCHNG REPLACES THE 2CADR AT PHSNAME5 WITH THE 2CADR OF THE LOCATION SPECIFIED BY Q AND THE CURRENT
# BBANK.   THE OTHER GROUP 5 INFORMATION IS NOT TOUCHED.   SERVCHNG SHOULD BE USED WHEREVER POSSIBLE BY ROUTINES
# RUNNING AS PART OF THE SERVICER JOB.

                SETLOC  FFSERV
                BANK
                EBANK=  PHSNAME5
                COUNT*  $$/SERV

SERVCHNG        CAF     THREE           # FBANK 0, EBANK 3
                XCH     BBANK
                DXCH    L               # A --> L,  Q --> A
                DXCH    PHSNAME5
                EXTEND                  # PICK UP RETURN ADDRESS WHERE IT SURVIVES
                DCA     PHSNAME5
                DXCH    Z               # RETURN

                SETLOC  SERVICES
                BANK
                EBANK=  DVCNTR
                COUNT*  $$/SERV

# ********************************
# COPYCYC
# ********************************

COPYCYC         CAF     TWNTYTWO
 +1             INHINT
 +2             MASK    NEG1            # REDUCE BY 1 IF ODD
                TS      ITEMP1
                EXTEND
## Page 881
                INDEX   ITEMP1
                DCA     RN1
                INDEX   ITEMP1
                DXCH    RN
                CCS     ITEMP1
                TCF     COPYCYC +2
                TC      Q               # RETURN UNDER INHINT


# ********************************
# TMPTOSPT
# ********************************

TMPTOSPT        CA      CDUTEMPY        # THIS SUBROUTINE LOADS THE CDUS
                TS      CDUSPOTY        #   CORRESPONDING TO PIPTIME1 INTO THE
                CA      CDUTEMPZ        #   CDUSPOT VECTOR.   TMPTOSPT CAN BE
                TS      CDUSPOTZ        #   CALLED FROM INTERPRETIVE WITH AN RTB.
                CA      CDUTEMPX
                TS      CDUSPOTX
                TC      Q

# ********************************
# PIPNORM
# ********************************

#          PIPNORM, WHICH CORRECTS THE PIPA DIFFERENCE FOR POSSIBLE PIPA OVERFLOW, IS SEPARATE FROM PIPASR TO
# MAKE IT AVAILABLE TO ROUTINES WHICH READ THE PIPAS ASYNCHRONOUSLY, SUCH AS R10 AND THE R.O.D. EQUATION.

#          FUNCTIONAL DESCRIPTION OF PIPNORM:-

#          INPUT:         IN A - DIFFERENCE BETWEEN CURRENT AND PREVIOUS PIPA READING

#          OUTPUTS:       IN A - INPUT CORRECTED FOR POSSIBLE PIPA OVERFLOW BETWEEN READINGS
#                         IN L - ZERO

#          ASSUMPTIONS:   THAT A DELV OF NO MORE THAN 81.91 M/S WAS ACCUMULATED BETWEEN THE PIPA READINGS
#                         THAT PIPNORM IS CALLED IN INTERRUPT OR UNDER INHINT

PIPNORM         XCH     ITEMP1          # TO CLEAR POSSIBLE OVERFLOW
                CA      ITEMP1
                MASK    BIT14
                EXTEND
                BZF     +5
                CA      ITEMP1          # POS > 8191 OR NEG > -8192
                AD      NEG1/2
                AD      NEG1/2
                TCF     +4
 +5             CA      ITEMP1          # POS < 8192 OR NEG < -8191
                AD      HALF
                AD      HALF
## Page 882
 +4             ZL
                XCH     L               # CLEAR PROBABLE OVERFLOW
                XCH     L
                TC      Q

# ****************************************************************************************************************
# SERVICER CONSTANTS (EXCEPT THOSE IN THE CONTROLLED CONSTANTS SECTION)
# ****************************************************************************************************************
                EBANK=  DVCNTR
CYCLEADR        2CADR   PIPCYCLE



                EBANK=  DVCNTR
AVOUTCAD        2CADR   AVGEND



GETABADR        ADRES   GETABVAL


XNBPIPAD        ECADR   XNBPIP


XNBRADAD        ECADR   XNBRAD


PGMIN           =       2SECS


PGMAX           DEC     500


2SEC(18)        2DEC    200 B-18



4SEC(18)        2DEC    400 B-28



DP1/20          2DEC    0.05



1-30KFT         2DEC    16768072 B-24   # DPPOSMAX-30KFT

## Page 883
BIASFACT        2DEC    .0064           # SCALES PBIAS TO UNITS OF 2(-9) M/CS/CS



OCT21           =       ND1


OCT523          OCT     00523


BITS4-7         OCT     110


BITS6+7         =       SUPER110


66DEC           DEC     66


TWNTYTWO        DEC     22


1/200DP         2DEC    .005



# ****************************************************************************************************************
# QUARTASK (ALSO KNOWN AS R10,R11) AN AUXILLIARY OF SERVICER WHICH RUNS EVERY QUARTER OF A SECOND
# ****************************************************************************************************************

                SETLOC  R11
                BANK
                EBANK=  END-E7
                COUNT*  $$/R11

R10,R11         =       QUARTASK

QUARTASK        CA      FLAGWRD7        # IS SERVICER STILL RUNNING?
                MASK    AVEGFBIT
                EXTEND
                BZF     TASKOVER        # NO:   BUT LET AVGEND KILL GROUP 2

                CA      OCT31           # YES:  SET UP NEXT QUARTASK
                TC      TWIDDLE
                ADRES   QUARTASK

# ************************************************************************
# FLASH LANDING RADAR LIGHTS
# ************************************************************************

## Page 884
FLASHH?         CA      FLGWRD11
                MASK    HFLSHBIT
                EXTEND
                BZF     FLASHV?         # H FLASK OFF, SO LEAVE ALONE

                CA      HLITE
                TS      L
                TC      FLIP            # FLIP H LITE

FLASHV?         CA      FLGWRD11        # VFLASHBIT MUST BE BIT 2
                MASK    VFLSHBIT
                EXTEND
                BZF     10,11           # V FLASH OFF

                CA      VLITE
                TS      L
                TC      FLIP

# ************************************************************************
# CHECK FOR ABORT OR ABORT-STAGE
# ************************************************************************

10,11           CA      FLAGWRD9        # IS THE LETABORT FLAG SET?
                MASK    LETABBIT
                EXTEND
                BZF     VVCOMP          # NO:   GO ON TO THE VELOCITY COMPUTATION

P71NOW?         CS      MODREG          # ARE WE IN P71 NOW?
                AD      1DEC71
                EXTEND
                BZF     VVCOMP          # YES:  PROCEED TO VELOCITY COMPUTATION

                EXTEND                  # NO:   IS AN ABORT STAGE COMMANDED
                READ    CHAN30
                COM
                TS      L
                MASK    BIT4
                CCS     A
                TCF     P71A            # YES

P70NOW?         CS      MODREG          # NO:   ARE WE IN P70 NOW?
                AD      1DEC70
                EXTEND
                BZF     VVCOMP          # YES:  PROCEED TO VELOCITY COMPUTATION

                CA      L               # NO:   IS AN ABORT COMMANDED?
                MASK    BIT1
                CCS     A
                TCF     P70A            # YES

## Page 885
# ************************************************************************
# COMPUTE VELOCITY VECTOR
# ************************************************************************

# ONLY IF SWANDISP IS SET ARE ALL THE NUMBERS AVAILABLE NEEDED IN VVCOMP.

VVCOMP          CS      FLAGWRD7        # IS LANDING ANALOG DISPLAYS FLAG SET?
                MASK    SWANDBIT
                CCS     A
                TCF     DISPRSET +1     # NO:   GO RESET

# DO EVERYTHING POSSIBLE BEFORE READING PIPAS.

                EXTEND                  # YES:  COMPUTE VELOCITY VECTOR
                DCS     VSURFACE
                DXCH    VVECTX
                EXTEND
                DCA     V
                DDOUBL
                DDOUBL
                DAS     VVECTX

                EXTEND
                DCS     VSURFACE +2
                DXCH    VVECTY
                EXTEND
                DCA     V        +2
                DDOUBL
                DDOUBL
                DAS     VVECTY

                EXTEND
                DCS     VSURFACE +4
                DXCH    VVECTZ
                EXTEND
                DCA     V        +4
                DDOUBL
                DDOUBL
                DAS     VVECTZ

# PICK UP TIME.

# COMPUTE TIME SINCE PIPTIME.

                CS      PIPTIME  +1
                AD      TIME1
                AD      HALF
                AD      HALF
                XCH     DT              # DT IN UNITS OF 2(14) CS

## Page 886
# ADD IN PIPA PULSES.

                CS      PIPAXOLD
                AD      PIPAX
                TC      NORMPIP
                EXTEND
                MP      LANAKPIP
                DAS     VVECTX

                CS      PIPAYOLD
                AD      PIPAY
                TC      NORMPIP
                EXTEND
                MP      LANAKPIP
                DAS     VVECTY

                CS      PIPAZOLD
                AD      PIPAZ
                TC      NORMPIP
                EXTEND
                MP      LANAKPIP
QUARDUMP        DAS     VVECTZ

#     THE FOLLOWING CODING REFERS THE X-PIPA READING TO THE CENTER-OF-MASS OF THE SPACECRAFT BY SUBTRACTING
# THOSE PIPA COUNTS PRODUCED BY VERTICAL IMU MOTION RELATIVE TO THE CENTER-OF-MASS.  THE SPACECRAFT X-AXIS IS
# ASSUMED TO BE APPROXIMATELY VERTICAL (PARALLEL TO THE SM X-AXIS).  THE EQUATION IS:

#                                 P66PIPX = P66PIPX - OMEGAQ RIMUZ

# WHERE P66PIPX IS THE X-PIPA READING, OMEGAQ IS THE ATTITUDE-RATE ABOUT THE Q (Y) AXIS, AND RIMUZ IS THE
# Z-COORDINATE OF THE IMU.

# FINALLY, ADD IN CONTRIBUTIONS OF GRAVITY AND PIPA BIAS.

                CS      BIASACCX        # BIASACCX IS IN UNITS OF 2(-9) M/CS/CS
                AD      GRAVACCX        # GRAVACCX IS IN UNITS OF 2(-9) M/CS/CS
                EXTEND
                MP      DT
                DAS     VVECTX          # VVECTX IN UNITS OF 2(5) M/CS

                CS      BIASACCY        # BIASACCY IS IN UNITS OF 2(-9) M/CS/CS
                AD      GRAVACCY        # GRAVACCY IS IN UNITS OF 2(-9) M/CS/CS
                EXTEND
                MP      DT
                DAS     VVECTY          # VVECTY IN UNITS OF 2(5) M/CS

                CS      BIASACCZ        # BIASACCZ IS IN UNITS OF 2(-9) M/CS/CS
                AD      GRAVACCZ        # GRAVACCZ IS IN UNITS OF 2(-9) M/CS/CS
                EXTEND
                MP      DT
## Page 887
                DAS     VVECTZ          # VVECTZ IN UNITS OF 2(5) M/CS

# ************************************************************************
# SHOULD P66JOB BE SET UP?
# ************************************************************************

GUILDEN         CS      MODREG          # ARE WE IN P66?
STERN           AD      DEC66
                EXTEND
                BZF     P66SETUP        # YES:  OFF TO IT THEN

                CA      FLAGWRD1        # NO:   IS P66 SELECTION LOCKED OUT
                MASK    ALW66BIT
                EXTEND
                BZF     GUILDRET        # YES

                CCS     FLPASS0         # NO:   IS FLPASS0 = 0?
                TCF     ATTHOLD?        # NO:   GO CHECK UN-ATTITUDE-HOLD DISCRETE

                CS      WCHPHASE        # YES:  IS WCHPHASE = 2?
                AD      TWO
                EXTEND
                BZF     STARTP66        # YES:  GO START P66

ATTHOLD?        CAF     BIT13           # NO: IS UN-ATTITUDE-HOLD DISCRETE HERE?
                EXTEND
                RAND    CHAN31
                CCS     A
                TCF     GUILDRET        # YES: ALL'S WELL, OR AT LEAST AUTOMATIC

                CA      RODCOUNT        # NO:   HAS ROD SWITCH BEEN CLICKED?
                EXTEND
                BZF     GUILDRET        # NO:   STICK IN THERE, LANDING

STARTP66        EXTEND                  # YES:  INITIALIZE DESIRED ALTITUDE-RATE
                DCA     VVECTX          #   (FURTHER INITIALIZATION IS IN P66JOB)
                DXCH    VDGVERT

                CS      ZERO            # CANCEL LEFT-OVER P64 THROTTLE COMMAND
                TS      THRUST          #   (NEVER, NEVER LOAD THRUST WITH +0)

                INCR    FLPASS0

                EXTEND                  # DISCONNECT ALL GUIDANCE FROM SERVICER
                DCA     ADRPIPCY
                DXCH    AVGEXIT

                TC      UPFLAG          # SET FLAG TO CONTINUE P66 HORIZONTAL
                ADRES   P66PROFL        #   UNTIL "PROCEED" AFTER TOUCHDOWN

## Page 888
                TC      DOWNFLAG        # PERMIT X-AXIS OVERRIDE DESPITE THE
                ADRES   XOVINFLG        #   POSSIBILITY OF PITCH-ROLL CROSS-FEED

                TC      UPFLAG          # TERMINATE TERRAIN MODEL
                ADRES   NOTERFLG

P66SETUP        CCS     PHASE3          # AVOID MULTIPLE P66JOBS AFTER RESTART
                TCF     PRELAD

                CAF     PRIO24
                TC      FINDVAC
                EBANK=  TAURODL
P662CADR        2CADR   P66JOB


                CAF     EBANK3          # RESTART PROTECT BY HAND TO SAVE TIME
                TS      EBANK
                EBANK=  PHSNAME3
                CAF     PRIO24
                TS      PHSPRDT3
                EXTEND
                DCA     P662CADR
                DXCH    PHSNAME3
                CAF     TWO
                TS      L
                COM
                DXCH    -PHASE3
                CAF     EBANK7
                TS      EBANK
                EBANK=  END-E7

                TCF     PRELAD

GUILDRET        CAF     ZERO
                TS      RODCOUNT

PRELAD          CS      TIME1           # UPDATE TBASE2 AND PROCEED TO LANADISP
                TS      TBASE2
                TCF     LANADISP

# ************************************************************************
# QUARTASK CONSTANTS
# ************************************************************************

DEC66           DEC     66


                EBANK=  DVCNTR
ADRPIPCY        2CADR   PIPCYCLE

## Page 889
# ****************************************************************************************************************
# ****************************************************************************************************************

#     TEMPORARY DEFINITIONS TO AVOID CUSSES UNTIL CHANGES OUTSIDE OF ZFLY AND ZERASE CAN BE MADE.

REREADAC        =       TASKOVER


REDO5.5         =       TASKOVER


GDT/2           =       G


PIPASR          =       PIPAREAD -3     # SO PIPSRINE WILL EQUAL PIPAREAD
