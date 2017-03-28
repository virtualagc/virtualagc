### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AOTMARK.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 255-274
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-23 HG   Transcribed
##              2016-11-25 HG   Fix label    MARKREJ -> MKREJ
##                                  operand  NOVAK   -> NOVAC
##                                           GOMARKER-> GOMARKFR
##                                           CMKCNTR -> XMKCNTR 
##              2016-12-07 HG   fix P00 -> POO
##              2016-12-11 HG   Fix operation CS NOMKCNT -> CA NOMKCNT
##		2016-12-23 RSB	Proofed comment text with octopus/ProoferComments
##				and fixed all errors found.
##		2017-03-14 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.

## Page 255
                SETLOC          AOTMARK1
                BANK

                EBANK=          XYMARK
                COUNT*          $$/MARK

AOTMARK         INHINT
                CAF             SIX                     # SEE IF EXT. VERB WORKING
                MASK            EXTVBACT
                CCS             A
                TCF             MKABORT                 # YES - ABORT

                CAF             BIT2                    # NO-DISALLOW SOME EXTENDED VERB ACTION
                ADS             EXTVBACT                # BIT2 RESET IN ENDMARK
MKVAC           CCS             VAC1USE                 # LOOK FOR A VAC AREA-DO ABORT IF
                TCF             MKVACFND                # NONE AVAILABLE
                CCS             VAC2USE
                TCF             MKVACFND
                CCS             VAC3USE
                TCF             MKVACFND
                CCS             VAC4USE
                TCF             MKVACFND
                CCS             VAC5USE
                TCF             MKVACFND
                DXCH            BUF2
                TC              BAILOUT1                # ALL VAC AREAS OCCUPIED - ABORT.
                OCT             31207

MKVACFND        AD              TWO
                TS              MARKSTAT                # STORE VAC ADR INLOW 9 OF MARKSTAT

                CAF             ZERO
                INDEX           MARKSTAT
                TS              0               -1      # ZERO IN VACUSE REG TO SHOW VAC  OCCUPIED

                CAF             PRIO15
                TC              FINDVAC                 # SET UP JOB FOR GETDAT
                EBANK=          XYMARK
                2CADR           GETDAT

                RELINT
                TCF             SWRETURN

MKABORT         DXCH            BUF2
                TC              BAILOUT1                # CONFLICT WITH EXTENDED VERB
                OCT             31211

MKRELEAS        CAF             ZERO
                XCH             MARKSTAT                # SET MARKSTAT TO ZERO

## Page 256
                MASK            LOW9                    # PICK UP VAC AREA ADR
                CCS             A
                INDEX           A
                TS              0                       # SHOW MKVAC AREA AVAILABLE
                CAF             ONE
                TC              IBNKCALL
                CADR            GOODEND                 # GO WAKE UP CALLING JOB

KILLAOT         CAF             ZERO
                TS              EXTVBACT                # TERMINATE AOTMARK-ALLOW EXT VERB
                TC              GOTOPOOH

## Page 257
# GETDAT ROUTINE

GETDAT          CS              MARKSTAT                # SET BIT12 TO DISCOURAGE MARKRUPT
                MASK            BIT12                   #   BIT12 RESET AT GETMARK
                ADS             MARKSTAT

N71DISP         CAF             V01N71                  # DISPLAY DETENT AND STAR CODE
                TC              BANKCALL
                CADR            GOMARKF

                TCF             KILLAOT                 # V34-DOES GOTOPOOH
                TCF             DODAT                   # V33-PROCEED-USE THIS STAR FOR MARKS
ENTERDAT        TCF             GETDAT                  # ENTER-REDISPLAY STAR CODE

DODAT           CAF             HIGH9                   # PICK DETENT CODE FROM BITS7-9 OF AOTCODE
                MASK            AOTCODE                 # AND SEE IF CODE 1 TO 6
                EXTEND
                MP              BIT9
                TS              XYMARK                  # STORE DETENT

                EXTEND
                BZMF            GETDAT                  # COAS CALIBRATION CODE-NO GOOD HERE

                AD              NEG7                    # SEE IF DETENT 7 FOR COAS
                EXTEND
                BZF             CODE7

                TCF             CODE1TO6

CODE7           CAF             V06N87*                 # CODE 7, COAS SIGHTING, GET OPTIC AXIS
                TC              BANKCALL                # AZ AND EL OF SIGHTING DEVICE FROM ASTRO
                CADR            GOMARKF

                TCF             KILLAOT                 # V34-DOES GOTOPOOH
                TCF             +2                      # PROCEED
                TCF             CODE7                   # ON ENTER, RECYCLE
                EXTEND
                DCA             AZ                      # PICK UP AZ AND EL IN SP 2S COMP
                INDEX           FIXLOC
                DXCH            8D                      # STORE IN 8D AND 9D OF LOCAL VAC
                CAF             ZERO                    # BACKUP SYSTEM TO BE USED
                TCF             COASCODE                # ZERO APPARENT ROTATION

CODE1TO6        INDEX           XYMARK                  # INDEX AOT POSITION BY DET CODE
                CA              AOTEL           -1
                INDEX           FIXLOC
                TS              9D                      # STORE ELEVATION IN VAC+9D

                INDEX           XYMARK                  # INDEX DET CODE 1,2 OR 3
                CA              AOTAZ           -1

## Page 258
                INDEX           FIXLOC
                TS              8D                      # STORE AZIMUTH IN VAC +8D

                CA              AOTAZ           +1      # COMPENSATION FOR APPARENT ROTATION OF
                EXTEND                                  # AOT FIELD OF VIEW IN LEFT AND RIGTHT
                INDEX           FIXLOC                  # DETENTS IS STORED IN VAC +10D IN SP
                MSU             8D                      # PRECISION ONES COMPLEMENT
COASCODE        INDEX           FIXLOC
                TS              10D                     # ROT ANGLE

                TC              INTPRET                 # COMPUTE X AND Y PLANE VECTORS

                CLEAR           GOTO
                                XDSPFLAG
                                OPTAXIS

## Page 259
# THE OPTAXIS SUBROUTINE COMPUTES THE X AND Y MARK PLANE VECS AND
# AND ROTATES THEM THRU THE APPARENT FIELD OF VIEW ROTATION UNIQUE TO AOT
# OPTAXIS USES OANB TO COMPUTE THE OPTIC AXIS
                SETLOC          P50S1
                BANK

OPTAXIS         CALL                                    # GO COMPUTE OA AND X AND Y PLANE VECS
                                OANB
                SLOAD           SR1                     # LOAD APP ROTATION IN ONES COMP
                                10D                     # RESCALE BY 2PI
                PUSH            SIN                     # 1/2SIN(ROT)  0-1
                PDDL            COS
                PUSH            VXSC                    # 1/2COS(ROT)  2-3
                                18D
                PDDL            VXSC                    # 1/4COS(ROT)UYP   4-9
                                0
                                24D                     # 1/4SIN(ROT)UXP
                BVSU            STADR                   # UP 4-9
                STODL           YPLANE                  # YPNB=1/4(COS(ROT)UYP-SIN(ROT)UXP)
                VXSC            PDDL                    # UP 2-3 UP 0-1   FOR EXCHANGE
                                24D                     # 1/4COS(ROT)UXP  PUSH 0-5
                VXSC            VAD                     # 1/4SIN(ROT)UYP
                                18D                     # UP 0-5
                STADR
                STOVL           XPLANE
                                LO6ZEROS                # INITIALIZE AVE STAR VEC ACCUMULATOR
                STORE           STARSAV2
                BOFF            EXIT                    # IF INFLIGHT &KM MARKING GET SIGHTING
                                FLT59FLG                # BODY VECTOR FOR THET EST IN ITERATION
                                ENDAXIS                 # LOOP
                EBANK=          XSM
                CA              EBANK5
                TS              EBANK                   # PLANET ROUTINE USES EBANK5
                TC              INTPRET
                RTB             CALL
                                LOADTIME
                                PLANET
                STORE           BODY
ENDAXIS         EXIT
                EBANK=          XYMARK
                CA              EBANK7                  # RESTORE EBANK IN CASE OF PLANET BRANCH
                TS              EBANK
                TC              BANKCALL
                CADR            GETMKS

## Page 260
# THE OANB ROUTINE COMPUTES THE OPTIC AXIS OF THE SIGHTING INSTRUMENT
# FROM AZIMUTH AND ELEVATION INPUT FROM THE ASTRONAUT.
                SETLOC          AOTMARK2
                BANK

                COUNT*          $$/MARK

OANB            SETPD           STQ
                                0
                                GCTR                    # STORE RETURN
                SLOAD           RTB
                                9D                      # PICK UP SP ELV
                                CDULOGIC
                PUSH            COS
                PDDL            SIN                     # 1/2COS(ELV)   PD 0-1
                STADR
                STODL           SCAXIS                  # OAX=1/2SIN(ELV)
                                8D                      # PICK UP AZ SP
                RTB
                                CDULOGIC
                PUSH            COS
                STORE           20D                     # STORE UYP(Y) 20-21
                PDDL            SIN                     # 1/2COS(AZ) PD 2-3
                PUSH            DCOMP                   # PUSH 1/2SIN(AZ) 4-5
                STODL           22D                     # STORE UYP(Z) 22-23
                                LO6ZEROS
                STODL           18D                     # STORE UYP(X) 18-19   UP 4-5
                DMP             SL1
                                0
                STODL           SCAXIS          +2      # OAY=1/2COS(ELV)SIN(AZ)
                DMP             SL1                     # UP 2-3
                STADR                                   # UP 0-1
                STOVL           SCAXIS          +4      # OAZ=1/2COS(ELV)COS(AZ)
                                18D                     # LOAD UYP VEC
                VXV             UNIT
                                SCAXIS                  # UXP VEC=UYP X OA
                STORE           24D                     # STORE UXP
                GOTO
                                GCTR

## Page 261
#    SURFSTAR COMPUTES A STAR VECTOR IN SM COORDINATES FOR LUNAR
#    SURFACE ALIGNMENT AND EXITS TO AVEIT TO AVERAGE STAR VECTORS.
                SETLOC          P50S
                BANK
                COUNT*          $$/R59

SURFSTAR        SSP             AXT,2                   # INITIALIZE LOOP COUNTER (X1)
                                S2
                                1
                                28D
                CLEAR           DLOAD
                                FREEFLAG
                                ONEDEG
                STOVL*          DELTHET
                                0,1                     # PICK UP CURSOR MARK CDUS
                STODL*          CDUSPOT
                                7,1                     # PICK UP SPIRAL FROM MK VAC
                RTB
                                CDULOGIC
                STCALL          8D                      # SPIRAL IN REVS
                                ROTCOMP
                STODL*          POINTVSM                # YPRIME VEC FOR SROT MEAS. COORDS.
                                6,1                     # PICK UP CURSOR
                RTB
                                CDULOGIC
                STCALL          10D                     # CURSOR IN REVS
                                ROTCOMP                 # COMPUTE YP VEC(NB)
                CALL
                                TRG*NBSM                # TRANSFORM YP VEC TO SM AT YROT MARK
                STOVL*          STARAD          +6
                                1,1                     # PICK UP SPIRAL CDUS
                STCALL          CDUSPOT                 # GET SINES AND COSINES OF CDUS
                                CD*TR*G
                BON             DLOAD
                                FLT59FLG
                                FLTTHET
                                8D                      # COMPUTE INITIAL THETA EST
                DSU             DAD
                                10D
                                ABOUTONE
THETRET         STORE           THETEST                 # INITIAL THET EST MUST BE BETWEEN
                DSU             BPL                     # 24 AND 342 DEGREES
                                DEG342
                                COOLIT
                DLOAD           DSU
                                THETEST
                                DEG24
                BMN             CALL
                                COOLIT
                                SNBCOMP                 # POMPUTE 2ST EST OF STAR(SM)

## Page 262
                DOT             SL1
                                STARAD          +6
SNBTEST         STORE           ESTER1                  # SEE IF STAR IN YROT PLANE
                ABS             DSU
                                COS.01
                BMN             DLOAD
                                AVEIT                   # LESS THAN EPSILON, GOT STAR(SM) IN 24D
                                DELTHET
                DAD
                                THETEST                 # INCREMENT THETA EST BY 1 DEG
                STCALL          THETEST
                                SNBCOMP                 # COMPUTE 2ND EST OF STAR VEC
                DOT             SL1
                                STARAD          +6
                STORE           ESTER2                  # SEE IF SOLUTION BETWEEN ESTER1, ESTER2
                BMN             DLOAD
                                NEGEST2
                                ESTER1
                BPL             GOTO
                                WHICHWAY                # NO SOLU, ARE WE GOING IN RIGHT DIRECTION
                                HOMEIN                  # SOLUTION BRACKETED, GET FINE CORRECTION
NEGEST2         DLOAD           BMN
                                ESTER1
                                WHICHWAY
HOMEIN          DSU             PDDL
                                ESTER2
                                ESTER2
                DDV
                DMP
                                DELTHET
                STCALL          DELTHET                 # FINE SOLUTION, THIS SHOULD GET SNB
                                NEXTIT

WHICHWAY        ABS             PDDL                    # ABS(ESTER1) 0-1
                                ESTER2
                ABS             BDSU                    # ABS(ESTER1)-ABS(ESTER2)
                BPL             BONSET
                                NEXTIT
                                FREEFLAG
                                COOLIT
                DLOAD           DCOMP                   # REVERSE DIRECTION OF ESTIMATION
                                DELTHET
                STORE           DELTHET
NEXTIT          DLOAD           TIX,2                   # SEE IF 10 ITERATIONS HAVE BEEN MADE
                                ESTER2
                                SNBTEST
COOLIT          EXIT
                INCR            NOMKCNT
                TC              BANKCALL
                CADR            COOLOUT

## Page 263
ROTCOMP         PUSH            COS                     # COS(ROT) 0-1
                PDDL            SIN                     # 1/8SIN(ROT)XP 0-5  1/2COS(ROT)  MPAC
                VXSC            PDDL
                                XPLANE
                VXSC            VSU
                                YPLANE
                UNIT            RVQ                     # 1/2UNIT(VEC) IN MPAC

DEG342          2DEC            .94999999
DEG24           2DEC            .06666666
COS.01          2DEC            .0001745
ABOUTONE        2DEC            .99999999
ONEDEG          2DEC            .00277777


                SETLOC          AOTMARK3
                BANK

FLTTHET         VLOAD           MXV
                                BODY
                                REFSMMAT                # FOR INFLIGHT P57 MARKING COMPUTE INITIAL
                UNIT            CALL                    # THET EST BY 12(STAR X OPTAXIS)
                                *SMNB*
                DOT             SL1
                                SCAXIS
                ARCCOS          DMP
                                3/4                     # 12 SCALED BY 16
                SL4             GOTO
                                THETRET

## Page 264
# SUBROUTINE TO COMPUTE STAR VEC IN NB COORDINATES
                SETLOC          P50S1
                BANK

SNBCOMP         STQ
                                QMIN
                DLOAD           DMP
                                THETEST
                                DP1/12
                PUSH            COS                     # COS(T/12) 0-1
                PDDL            SIN
                PDDL            PUSH                    # SIN(T/12) 2-3
                                THETEST
                SIN             PDDL                    # SIN(T) 4-5
                COS             DMP
                                2                       # COS(T)SIN(T/12) 6-7
                PDVL            VXV
                                POINTVSM
                                SCAXIS
                VSL1            VXSC                    # UP 6-7
                STADR
                STODL           24D                     # COS(T)SIN(T/12)(YP X OA)
                DMP					# UP 4-5  UP 2-3
                VXSC            BVSU
                                POINTVSM                # SIN(T)SIN(T/12)YP
                                24D
                STODL           24D
                VXSC            VSR1                    # UP 0-1
                                SCAXIS
                VAD             UNIT
                                24D
                STCALL          24D                     # STAR(NB)
                                *NBSM*
                STORE           24D                     # STAR(SM)
                GOTO
                                QMIN

DP1/12          2DEC            .083333333

## Page 265
# GETMKS ROUTINE
                SETLOC          AOTMARK1
                BANK
                COUNT*          $$/MARK

GETMKS          CAF             ZERO                    # INITIALIZE MARK ID REGISTER AND MARK CNT
                TS              NOMKCNT
                TS              XCOUNT
                TS              YCOUNT
                TS              XYMARK
                TS              XMKCNTR
                TS              YMKCNTR
                CS              FLAGWRD8
                MASK            BIT8
                EXTEND
                BZF             SETSURF                 # SURFFLAG FLAG SET, JAM ONE IN WHATMARK
                CA              FLAGWRD9
                MASK            BIT4                    # SEE IF CURSOR-SPIRAL MARKING
                CCS             A
SETSURF         CA              ONE
                TS              WHATMARK

PASTIT          CAF             LOW9                    # FREE UP MARKRUPT RETAINING MKVAC ADR
                MASK            MARKSTAT
                TS              MARKSTAT
                INDEX           WHATMARK
                CAF             MKVB54                  # DISPLAY MARK REQUEST
                TC              BANKCALL
                CADR            GOMARK2

                TCF             KILLAOT                 # V34-DOES GOTOPOOH
                TCF             MARKCHEX                # VB33-PROCEED, GOT MARKS, COMPUTE LOS
                CS              BIT6
                MASK            MPAC
                EXTEND
                BZF             GETDAT                  # VB32 RECYCLE TO V01N71
                CS              WHATMARK                # ENTER-REVERSE CURSOR OR SPIRAL REQUEST
                TS              WHATMARK
                CCS             XYMARK
                TCF             +2                      # IF ONE, SET ZERO
                CAF             ONE                     # IF ZERO, SET ONE
                TS              XYMARK
PREPAST         EXTEND
                DCA             XMKCNTR
                DXCH            XCOUNT                  # UPDATE DISPLAY COUNTERS
                CAF             BIT13
                INDEX           XYMARK
                ADS             XCOUNT
                TCF             PASTIT

## Page 266
MARKCHEX        CS              MARKSTAT                # SET BIT12 TO DISCOURAGE MARKRUPT
                MASK            BIT12
                ADS             MARKSTAT
                MASK            LOW9
                TS              XYMARK                  # JAM MARK VAC ADR IN XYMARK FOR AVESTAR
                CAF             ZERO
                TS              MKDEX                   # SET MKDEX ZERO FOR LOS VEC CNTR
                CCS             XMKCNTR
                TCF             +2
                TCF             MKALARM
                TS              XMKCNTR
                CCS             YMKCNTR
                TCF             +2
                TCF             MKALARM
                TS              YMKCNTR
                COM
                AD              XMKCNTR
                EXTEND
                BZMF            AVESTAR
                CA              YMKCNTR
                TS              XMKCNTR

AVESTAR         CS              XMKCNTR
                EXTEND
                MP              EIGHT                   # GET C(L)=-8 MARKCNTR
                CS              XYMARK
                AD              L                       # ADD - MARK VAC ADR SET IN MARKCHEX
                INDEX           FIXLOC
                TS              X1                      # JAM - CDU ADR OF X-MARK IN X1

                CA              FIXLOC                  # SET PD POINTER TO ZERO
                TS              PUSHLOC

                TC              INTPRET
                BON             BON
                                SURFFLAG
                                SURFSTAR
                                FLT59FLG
                                SURFSTAR
                VLOAD*
                                1,1
                STOVL           CDUSPOT
                                YPLANE
                CALL
                                TRG*NBSM                # CONVERT IT TO STABLE MEMBER
                PUSH            VLOAD*
                                0,1                     # PUT X-MARK CDUS IN CDUSPOT FOR TRG*NBSM
                STOVL           CDUSPOT
                                XPLANE
                CALL

## Page 267
                                TRG*NBSM                # CONVERT IT TO STABLE-MEMBER
                VXV             UNIT                    # UNIT(XPSM * YPSM)
                STADR
                STORE           24D

AVEIT           EXIT
                CAF             BIT12                   # INCREMENT STAR VEC COUNTER
                ADS             MKDEX                   # MKDEX WAS INITIALIZED ZERO IN MARKCHEX
                TC              INTPRET
                SLOAD           PDVL
                                MKDEX
                                24D                     # LOAD CURRENT VECTOR
                VSR3            V/SC
                                0
                STODL           24D                     # VEC/N
                                0
                DSU             DDV
                                DP1/8                   # (N-1)/N
                VXSC            VAD
                                STARSAV2                # ADD VEC TO PREVIOUSLY AVERAGED VEC
                                24D                     # (N-1)/N AVESTVEC + VEC/N
                UNIT
                STORE           STARSAV2
                EXIT
COOLOUT         CCS             XMKCNTR                 # SEE IF MARK PAIR IN MKVAC
                TCF             AVESTAR         -1      # THERE IS-GO GET IT-DECREMENT COUNTER
                CCS             NOMKCNT                 # IF ANY MKS NOT USED DISPLAY V50N25
                TCF             ASKASTR                 # AND THE NUMBER MKS NOT USED
ENDMARKS        CAF             FIVE
                TC              WAITLIST
                EBANK=          XYMARK
                2CADR           MKRELEAS
                TC              ENDMARK

MKALARM         TC              ALARM                   # NOT A PAIR TO PROCESS-DO GETMKS
                OCT             111
                TCF             GETMKS

ASKASTR         CAF             OCT16
                TS              DSPTEM1
                CA              NOMKCNT
                TS              DSPTEM1         +1
                CAF             V50N25
                TC              BANKCALL
                CADR            GOMARK2R

                TCF             KILLAOT                 # V34 TERMINATE
                TCF             ENDMARKS                # PRO - PROCEED ANYWAY

## Page 268
                TCF             GETDAT
                CAF             BIT3
                TC              BLANKET
                TC              ENDOFJOB

V50N25          VN              5025
V01N71          VN              171
V06N87*         VN              687

## Page 269
# MARKRUPT IS ENTERED FROM INTERUPT LEAD-INS AND PROCESSES CHANNEL 16
# CAUSED BY X,Y MARK OR MARK REJECT OR BY THE RATE OF DESCENT SWITCH

MARKRUPT        TS              BANKRUPT
                CA              CDUY                    # STORE CDUS AND TIME NOW-THEN SEE IF
                TS              ITEMP3                  # WE NEED THEM
                CA              CDUZ
                TS              ITEMP4
                CA              CDUX
                TS              ITEMP5
                EXTEND
                DCA             TIME2
                DXCH            ITEMP1
                XCH             Q
                TS              QRUPT

                CAF             OCT140                  # SEE IF ROD INPUT
                EXTEND
                RAND            NAVKEYIN
                EXTEND
                BZMF            FINDKEY

                TC              DESCBITS                # ROD INPUT
FINDKEY         TC              VALIDCHK                # NO ROD INPUT-SEE IF VALID MARKRUPT
                CAF             BIT5                    # GOOD RUPT-SEE IF MARK REJECT

                EXTEND
                RAND            NAVKEYIN
                CCS             A
                TCF             MKREJ                   # ITS A MARK REJECT

CHKWHAT         CCS             WHATMARK
                TCF             XMKRUPT                 # +1 FOR CURSOR MARK
                TCF             FINDMARK                # 0  FOR INFLIGHT MARK
                TCF             YMKRUPT                 # -1 FOR SPIRAL

FINDMARK        CAF             BIT4                    # SEE IF Y MARK
                EXTEND
                RAND            NAVKEYIN
                CCS             A

                TCF             YMKRUPT                 # ITS Y MARK OR SPIRAL MARK
                CAF             BIT3                    # SEE IF X MARK
                EXTEND
                RAND            NAVKEYIN
                CCS             A
                TCF             XMKRUPT                 # ITS A X MARK

113ALRM         TC              ALARM                   # NO INBITS IN CHANNEL 16
                OCT             113

## Page 270
                TC              RESUME

XMKRUPT         CAF             ZERO
                TCF             +2                      # SET STORE INDEX ZERO
YMKRUPT         CAF             ONE
                TS              XYMARK                  # SET MARK ID REG
                INDEX           A
                CS              XMKCNTR
                AD              FIVE
                EXTEND
                BZMF            VACSTOR                 # IF 7TH MARK. STORE DATA AS 6TH MARK
                INDEX           XYMARK
                INCR            XMKCNTR
                TCF             VACSTOR

DESCBITS        MASK            BIT7
                TS              L

                CAF             AVEGFBIT
                MASK            FLAGWRD7
                CCS             A
                TCF             RODIN
                TC              VALIDCHK
                TCF             CHKWHAT                 # THIS IS BACK UP MARK

VALIDCHK        CCS             MARKSTAT
                TCF             CHK12

ALM112          TC              ALARM                   # MARKRUPT NOT ALLOWED
                OCT             112
                TC              RESUME

CHK12           MASK            BIT12
                CCS             A
                TCF             ALM112
                TC              Q

RODIN           CCS             L
                CS              TWO
                AD              ONE
                ADS             RODCOUNT
                TC              RESUME

## Page 271
# DATA STORE ROUTINE

VACSTOR         EXTEND
                DCA             ITEMP1                  # STORE MARK TIME FOR DOWNLINK
                DXCH            TSIGHT

                CAF             LOW9
                MASK            MARKSTAT                # GRAB MARK VAC ADR
                TS              MKDEX
                INDEX           XYMARK
                CCS             XMKCNTR                 # DECREMENT COUNTER TO START STORE AT ZERO
                EXTEND
                MP              EIGHT
                XCH             L
                AD              XYMARK
                ADS             MKDEX                   # MK VAC ADR + 8(CNTR-1) + MARK ID
                CA              ITEMP3
                INDEX           MKDEX
                TS              0                       # STORE CDUY
                CA              ITEMP4
                INDEX           MKDEX
                TS              2                       # STORE CDUZ
                CA              ITEMP5
                INDEX           MKDEX
                TS              4                       # STORE CDUX
ENDSTOR         TCF             REMARK

## Page 272
# REMARK AND CURSOR-SPIRAL KEYIN ROUTINE

REMARK          CAF             PRIO15                  # ENTER JOB TO CHANGE DISPLAY
                TC              NOVAC
                EBANK=          XYMARK
                2CADR           CHANGEVB


                TC              RESUME

CHANGEVB        CA              WHATMARK
                EXTEND
                BZF             PREPAST                 # RE-DISPLAY VERB54 FOR INFLIGHT MARK
                CS              MARKSTAT                # SET BIT12 TO DISCOURAGE MARK
                MASK            BIT12
                ADS             MARKSTAT

                INDEX           WHATMARK
                CAF             V06N79*                 # EITHER V21N79 OR V 22N79 LOAD VERB
                TC              BANKCALL
                CADR            GOMARKFR

                TCF             KILLAOT                 # VB34-TERMINATE
                TCF             N79DISP
                TCF             N79DISP

                CAF             SEVEN
                TC              BLANKET
                TC              ENDOFJOB

N79DISP         CAF             V06N79*                 # ENTER-DISPLAY V06N79 FOR VERIFY
                TC              BANKCALL
                CADR            GOMARKFR

                TC              KILLAOT
                TCF             SURFAGAN
                TCF             N79DISP

                CS              XYMARK
                AD              SIX
                TC              BLANKET
                TC              ENDOFJOB

SURFAGAN        INDEX           XYMARK
                CA              CURSOR
                INDEX           MKDEX
                TS              6
                TCF             PREPAST

V22N79          VN              2279                    # SPIRAL LOAD DISPLAY

## Page 273
V06N79*         VN              679
V21N79          VN              2179                    # CURSOR LOAD DISPLAY

MKVB53          VN              5371                    # SPIRAL MARK REQUEST
MKVB54          VN              5471                    # X OR Y MARK
MKVB52          VN              5271                    # CURSOR MARK REQUEST
DP1/8           2DEC            .125

## Page 274
# MARK REJECT ROUTINE
MKREJ           INDEX           XYMARK
                CCS             XMKCNTR
                TCF             REJMK			# REJECT MARK

                TC              ALARM
                OCT             115			# NO MARK OF THIS KIND TO REJECT
                TC              RESUME

REJMK           INDEX           XYMARK
                TS              XMKCNTR			# STORE DECREMENTED MARK COUNTER

                CAF             PRIO15			# ENTER JOB TO RE-DISPLAY MARK REQUEST
                TC              NOVAC
                EBANK=          XYMARK
                2CADR           PREPAST
                TC              RESUME
