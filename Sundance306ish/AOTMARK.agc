### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AOTMARK.agc
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



                BANK            12
                SETLOC          AOTMARK1
                BANK

                EBANK=          XYMARK
                COUNT*          $$/MARK

AOTMARK         INHINT
                CCS             MARKSTAT                # SEE IF AOTMARK BUSY
                TC              +2                      # MARK SYSTEM BUSY-DO ALARM
                TC              EXTVBCHK
                TC              ALARM
                OCT             00105
                TC              ENDOFJOB

EXTVBCHK        CAF             SIX                     # SEE IF EXT. VERB WORKING
                MASK            EXTVBACT
                CCS             A
                TCF             MKABORT                 # YES-ABORT

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
                TC              ABORT                   # ALL VAC AREAS OCCUPIED - ABORT.
                OCT             01207

MKVACFND        AD              TWO
                TS              MARKSTAT                # STORE VAC ADR IN LOW 9 OF MARKSTAT

                CAF             ZERO
                INDEX           MARKSTAT
                TS              0               -1      # ZERO IN VACUSE REG TO SHOW VAC OCCUPIED

                CAF             PRIO32
                TC              FINDVAC                 # SET UP JOB FOR GETDAT
                EBANK=          XYMARK
                2CADR           GETDAT

                RELINT
                TCF             SWRETURN

MKABORT         TC              ABORT                   # CONFLICT WITH EXTENDED VERB
                OCT             01211

MKRELEAS        CAF             ZERO
                XCH             MARKSTAT                # SET MARKSTAT TO ZERO
                MASK            LOW9                    # PICK UP VAC AREA ADR
                CCS             A
                INDEX           A
                TS              0                       # SHOW MKVAC AREA AVAILABLE
                CAF             ONE
                TC              IBNKCALL
                CADR            GOODEND                 # GO WAKE UP CALLING JOB

GETDAT          CAF             V01N71                  # DISPLAY DETENT AND STAR CODE
                TC              BANKCALL
                CADR            GOFLASH

                TC              GOTOPOOH                # V34-TERMINATE
                TCF             DODAT                   # V33-PROCEED-USE THIS STAR FOR MARKS
ENTERDAT        TCF             GETDAT                  # ENTER-REDISPLAY STAR CODE

DODAT           CS              MARKSTAT                # SET BIT12 TO DISCOURAGE MARKRUPT
                MASK            BIT12                   #   BIT12 RESET AT GETMARK
                ADS             MARKSTAT

                CAF             HIGH9                   # PICK DETENT CODE FROM BITS7-9 OF AOTCODE
                MASK            AOTCODE                 # AND SEE IF CODE IS 1,2 OR 3
                EXTEND
                MP              BIT9
                TS              XYMARK                  # STORE DETENT

                EXTEND
                BZMF            GETDAT                  # NO GOOD-MAKE REQUEST AGAIN

                MASK            BIT3                    # SEE IF DETENT CODE 4 OR 5
                EXTEND
                BZF             CODE123                 # NOT 4 OR 5, MUST BE 1,2 OR 3

                COUNT*          $$/COAS

CODE4OR5        CAF             V06N87*                 # CODE 4 OR 5, GET OPTIC AXIS CALIBRATIONS
                TC              BANKCALL                # AZ AND EL OF SIGHTING DEVICE FROM ASTRO
                CADR            GOFLASH

                TC              GOTOPOOH                # V34-TERMINATE
                TCF             +2                      # PROCEED
                TCF             CODE4OR5                # ON ENTER, RECYCLE
                EXTEND
                DCA             AZ                      # PICK UP AZ AND EL IN SP 2S COMP
                INDEX           FIXLOC
                DXCH            8D                      # STORE IN 8D AND 9D OF LOCAL VAC
                CAF             BIT1                    # IF CODE 4, REAR AOT POSITIONS USED
                MASK            XYMARK                  # SO CALC APPARENT ROTATION
                EXTEND                                  # IF CODE 5, BACKUP, ZERO ROTATION
                BZF             CODE4                   # REAR AOT DETENTS TO BE USED
                CAF             ZERO                    # BACKUP SYSTEM TO BE USED
                TCF             CODE5

                COUNT*          $$/MARK

CODE123         INDEX           XYMARK                  # INDEX DET CODE 1,2 OR 3
                CA              AOTEL -1
                INDEX           FIXLOC

                TS              9D                      # STORE ELEVATION IN VAC+9D

                INDEX           XYMARK                  # INDEX DET CODE 1,2 OR 3
                CA              AOTAZ -1
                INDEX           FIXLOC
                TS              8D                      # STORE AZIMUTH IN VAC+8D

CODE4           CA              AOTAZ +1                # COMPENSATION FOR APPARENT RATATION OF
                EXTEND                                  # AOT FIELD OF VIEW IN LEFT AND RIGTHT
                INDEX           FIXLOC                  # DETENTS IS STORED IN VAC +10D IN SP
                MSU             8D                      # PRECISION ONES COMPLEMENT
CODE5           INDEX           FIXLOC
                TS              10D                     # ROT ANGLE

                TC              INTPRET                 # COMPUTE X AND Y PLANE VECTORS

# THE OPTAXIS SUBROUTINE COMPUTES THE X AND Y MARK PLANE VECS AND
# AND ROTATES THEM THRU THE APPARENT FIELD OF VIEW ROTATION UNIQUE TO AOT
# OPTAXIS USES OANB TO COMPUTE THE OPTIC AXIS
#  INPUT-AZIMUTH ANGLE IN SINGLE PREC AT CDU SCALE IN 8D OF JOB VAC
#        ELEVATION ANGLE IN SINGLE PREC AT CDU SCALE IN 9D OF JOB VAC
#        ROTATION ANGLE IN SINGLE PREC 1S COMP SCALED BY PI IN 10D OF VAC
#  OUTPUT-OPTIC AXIS VEC IN NB COORDS IN SCAXIS
#         X-MARK PLANE 1/4VEC IN NB COORDS AT 18D OF JOB VAC
#         Y-MARK PLANE 1/4VEC IN NB COORDS AT 12D OF JOB VAC

OPTAXIS         CALL                            # GO COMPUTE OA AND X AND Y PLANE VECS
                        OANB
                SLOAD   SR1                     # LOAD APP ROTATION IN ONES COMP
                        10D                     # RESCALE BY 2PI
                PUSH    SIN                     # 1/2SIN(ROT)  0-1
                PDDL    COS
                PUSH    VXSC                    # 1/2COS(ROT)  2-3
                        18D
                PDDL    VXSC                    # 1/4COS(ROT)UYP   4-9
                        0
                        24D                     # 1/4SIN(ROT)UXP
                BVSU    STADR                   # UP 4-9
                STODL   12D                     # YPNB=1/4(COS(ROT)UYP-SIN(ROT)UXP)
                VXSC    PDDL                    # UP 2-3  UP 0-1  FOR EXCHANGE
                        24D                     # 1/4COS(ROT)UXP  PUSH 0-5
                VXSC    VAD                     # 1/4SIN(ROT)UYP
                        18D                     # UP 0-5
                STADR
                STOVL   18D                     # XPNB=1/4(COS(ROT)UXP+SIN(ROT)UYP)
                        LO6ZEROS                # INITIALIZE AVE STAR VEC ACCUMULATOR
                STORE   STARAD          +6
                EXIT
                TCF     GETMKS

# THE OANB SUBROUTINE COMPUTES THE OPTIC AXIS OF THE SIGHTING INSTRUMENT
# FROM AZIMUTH AND ELEVATION INPUT FROM THE ASTRONAUT.
#    INPUT- AZIMUTH ANGLE IN SINGLE PREC 2S COMP IN 8D OF JOB VAC
#           ELEVATION ANGLE IN SINGLE PREC 2S COMP IN 9D OF VAC
#    OUTPUT-OPTIC AXIS IN NB COORDS. IN SCAXIS
#           X-PLANE 1/2VEC IN NB COORDS AT 24D OF VAC
#           Y-PLANE 1/2VEC IN NB COORDS AT 18D OF VAC

OANB            SETPD           STQ
                                0
                                GCTR                    # STORE RETURN
                SLOAD           RTB
                                9D                      # PICK UP SP ELV
                                CDULOGIC
                PUSH            COS
                PDDL            SIN                     # 1/2COS(ELV)  PD 0-1
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
                VXV             VSL1
                                SCAXIS                  # UXP VEC=UYP X OA
                STORE           24D                     # STORE UXP
                GOTO
                                GCTR

# THE GETMKS ROUTINE INITIALIZES THE SIGHTING MARK PROCEDURE

GETMKS          CAF             ZERO                    # INITIALIZE MARK ID REGISTER AND MARK CNT
                TS              XYMARK
                TS              MARKCNTR
                CAF             LOW9                    # ZERO BITS10 TO 15 RETAINING MKVAC ADR
                MASK            MARKSTAT
                TS              MARKSTAT
                CAF             MKVB54*                 # DISPLAY VB54 INITIALLY
PASTIT          TC              BANKCALL
                CADR            GOMARK4

                TC              GOTOPOOH                # VB34 TERMINATE-THIS RELEASES MKVAC AREA
                TCF             MARKCHEX                # VB33-PROCEED, GOT MARKS, COMPUTE LOS
                TCF             GETDAT                  # ENTER- RECYCLE TO V01N71

MARKCHEX        CS              MARKSTAT                # SET BIT12 TO DISCOURAGE MARKRUPT
                MASK            BIT12
                ADS             MARKSTAT
                MASK            LOW9
                TS              XYMARK                  # JAM MARK VAC ADR IN XYMARK FOR AVESTAR
                CAF             ZERO
                TS              MKDEX                   # SET MKDEX ZERO FOR LOS VEC CNTR
                CA              MARKSTAT
                MASK            PRIO3                   # SEE IF LAST MK PARI COMPLETE
                TS              L
                CAF             PRIO3                   # BITS10 AND 11
                EXTEND
                RXOR            LCHAN
                EXTEND
                BZF             AVESTAR                 # LAST PAIR COMPLETE-GO COMPUTE LOS
CNTCHK          CCS             MARKCNTR                # NO PAIR SHOWING-SEE IF PAIR IN HOLD
                TCF             +2                      # PAIR BURIED-DECREMENT COUNTER
                TCF             MKALARM                 # NO PAIR-ALARM
                TS              MARKCNTR                # STORE DECREMENTED COUNTER

AVESTAR         CA              MARKCNTR
                EXTEND
                MP              SIX                     # GET C(L) = - 6 MARKCNTR
                XCH             L       
                AD              XYMARK                  # ADD - MARK VAC ADR SET IN MARKCHEX
                INDEX           FIXLOC
                TS              S1                      # JAM - CDU ADR OF X-MARK IN S1

                CAF             BIT12                   # INITIALIZE MKDEX FOR STAR LOS COUNTER
                ADS             MKDEX                   # MKDEX WAS INITIALIZED ZERO IN MARKCHEX

                TC              INTPRET

                SETPD           VLOAD
                                0                       # SET PD POINTER TO ZERO
                                18D                     # LOAD STAR VECTOR IN NB
                STCALL          32D
                                NBSM                    # CONVERT IT TO STABLE MEMBER
                STOVL           24D
                                12D
                XCHX,1          INCR,1
                                S1
                                1
                XCHX,1
                                S1
                STCALL          32D
                                NBSM
                VXV
                                24D
                VCOMP           UNIT
                STORE           24D

AVEIT           SLOAD           PDVL                    # N(NUMBER OF VECS) IN 0-1
                                MKDEX
                                24D                     # LOAD CURRENT VECTOR
                VSR3            V/SC
                                0
                STODL           24D                     # VEC/N
                                0
                DSU             DDV
                                DP1/8                   # (N-1)/N
                VXSC            VAD
                                STARAD          +6      # ADD VEC TO PREVIOUSLY AVERAGED VECTOR
                                24D                     # (N-1)/N AVESTVEC + VEC/N
                STORE           STARAD          +6      # AVERAGE STAR VECTOR
                STORE           STARSAV2
                EXIT
                CCS             MARKCNTR                # SEE IF ANOTHER MARK PAIR IN MKVAC
                TCF             AVESTAR         -1      # THERE IS-GO GET IT-DECREMENT COUNTER
ENDMARKS        CAF             FIVE                    # NO MORE MARKS-TERMINATE AOTMARK
                INHINT
                TC              WAITLIST
                EBANK=          XYMARK
                2CADR           MKRELEAS

                TC              ENDMARK

MKALARM         TC              ALARM                   # NOT A PAIR TO PROCESS-DO GETMKS
                OCT             111
                TCF             GETMKS

V01N71          VN              171
V06N87*         VN              687

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

                CAF             OCT34                   # SEE IF X OR Y MARK OR MKREJECT
                EXTEND
                RAND            NAVKEYIN
                CCS             A
                TCF             +2                      # ITS A LIVE ONE-SEE IF ITS WANTED
                TCF             SOMEKEY                 # ITS SOME OTHER KEY

                CAF             BIT12                   # ARE WE ASKING FOR A MARK
                MASK            MARKSTAT
                CCS             A
                TC              RESUME                  # DONT WANT MARK OR MKREJECT-DO NOTHING

                CCS             MARKSTAT                # ARE MARKS BEING ACCEPTED
                TCF             FINDKEY                 # THEY ARE-WHICH ONE IS IT
                TC              ALARM                   # MARKS NOT BEING ACCEPTED-DO ALARM
                OCT             112
                TC              RESUME

FINDKEY         CAF             BIT5                    # SEE IF MARK REJECT
                EXTEND
                RAND            NAVKEYIN
                CCS             A
                TCF             MKREJ                   # ITS A MARK REJECT

                CAF             BIT4                    # SEE IF Y MARK
                EXTEND
                RAND            NAVKEYIN
                CCS             A

                TCF             YMKRUPT                 # ITS A Y MARK

                CAF             BIT3                    # SEE IF X MARK
                EXTEND
                RAND            NAVKEYIN

                CCS             A
                TCF             XMKRUPT                 # ITS A X MARK

SOMEKEY         CAF             OCT140                  # NOT MARK OR MKREJECT-SEE IF DESCENT BITS
                EXTEND
                RAND            NAVKEYIN
                EXTEND
                BZF             +3                      # IF NO BITS

                TC              POSTJUMP                # IF DESCENT BITS
                CADR            DESCBITS

                TC              ALARM                   # NO INBITS IN CHANNEL 16
                OCT             113

                TC              RESUME

XMKRUPT         CAF             ZERO
                TS              RUPTREG1                # SET X MARK STORE INDEX TO ZERO
                CAF             BIT10
                TCF             +4
YMKRUPT         CAF             ONE
                TS              RUPTREG1                # SET Y MARK STORE INDEX TO ONE
                CAF             BIT11
                TS              XYMARK                  # SET MARK IDENTIFIATION

                CAF             BIT14                   # GOT A MARK-SEE IF MARK PAIR MADE
                MASK            MARKSTAT
                EXTEND
                BZF             VERIFYMK                # NOT A PAIR, NORMAL PROCEDURE
                CS              MARKCNTR                # GOT A PAIR, SEE IF ANOTHER CAN BE MADE
                AD              FOUR                    # IF SO, INCREMENT POINTER,CLEAR BITS10,11
                EXTEND
                BZMF            5MKALARM                # HAVE FIVE MARK PAIRS-DONT ALLOW MARK
                INCR            MARKCNTR                # OK FOR ANOTHER PAIR, INCR POINTER
                CS              PRIO23                  # CLEAR BITS10,11,14 FOR NEXT PAIR
                MASK            MARKSTAT
                TS              MARKSTAT

VERIFYMK        CA              XYMARK
                MASK            MARKSTAT
                CCS             A
                TCF             +2                      # THIS MARK NOT DESIRED
                TCF             VACSTOR                 # MARK DESIRED - STORE CDUS
                TC              ALARM
                OCT             114
                TC              RESUME                  # RESUME-DISPLAY UNCHANGED-WAIT FOR ACTION

5MKALARM        TC              ALARM                   # ATTEMPTING TO MAKE MORE THAN 5 MK PAIRS
                OCT             107
                TC              RESUME                  # DONT CHANGE DISPLAY-DO NOTHING

MKREJ           CAF             PRIO3                   # INFLIGHT-SEE IF MARKS MADE
                MASK            MARKSTAT
                CCS             A
                TCF             REJECT                  # MARKS MADE-REJECT ONE
                TC              ALARM                   # NO MARK TO REJECT-BAD PROCEDURE-ALARM
                OCT             115
                TC              RESUME                  # DESIRED ACTION DISPLAYED

REJECT          CS              PRIO30                  # ZERO BIT14,SHOW REJ.,SEE IF MARK SINCE
                MASK            MARKSTAT                # LAST REJECT
                AD              BIT13
                XCH             MARKSTAT
                MASK            BIT13
                CCS             A
                TCF             REJECT2                 # ANOTHER REJECT SET BIT 10+11 TO ZERO

                CS              XYMARK                  # MARK MADE SINCE REJECT-REJECT MARK IN 1D
RENEWMK         MASK            MARKSTAT
                TS              MARKSTAT
                TCF             REMARK                  # GO REQUEST NEW MARK ACTION

REJECT2         CS              PRIO3                   # ON SECOND REJECT-DISPLAY VB53 AGAIN
                TCF             RENEWMK

VACSTOR         CAF             LOW9
                MASK            MARKSTAT                # STORE MARK VAC ADR IN RUPTREG2
                TS              RUPTREG2
                EXTEND
                DCA             ITEMP1                  # PICK UP MARKTIME
                DXCH            TSIGHT                  # STORE LAST MARK TIME
                CA              MARKCNTR                # 6 X MARKCNTR FOR STORE INDEX
                EXTEND
                MP              SIX
                XCH             L                       # GET INDEX FROM LOW ORDER PART
                AD              RUPTREG2                # SET CDU STORE INDEX TO MARKVAC
                ADS             RUPTREG1                # INCREMENT VAC PICKUP BY MARK FOR FLIGHT
                CA              ITEMP3
                INDEX           RUPTREG1
                TS              0                       # STORE CDUY
                CA              ITEMP4
                INDEX           RUPTREG1
                TS              2                       # STORE CDUZ
                CA              ITEMP5
                INDEX           RUPTREG1
                TS              4                       # STORE CDUX

                CAF             BIT13                   # CLEAR BIT13 TO SHOW MARK MADE
                AD              XYMARK                  # SET MARK ID IN MARKSTAT
                COM
                MASK            MARKSTAT
                AD              XYMARK
                TS              MARKSTAT
                MASK            PRIO3                   # SEE IF X, Y MARK MADE
                TS              L

                CA              PRIO3
                EXTEND
                RXOR            LCHAN
                CCS             A
                TCF             REMARK                  # NOT PAIR YET, DISPLAY MARK ACTION
                CS              MARKSTAT                # MARK PAIR COMPLETE-SET BIT14
                MASK            BIT14
                ADS             MARKSTAT
                TCF             REMARK                  # GO DISPLAY V54

REMARK          CAF             PRIO3                   # BITS 10 AND 11
                MASK            MARKSTAT
                EXTEND
                MP              BIT6                    # SHIFT MARK IDS TO BE 0 TO 3 FOR INDEX
                TS              MKDEX                   # STORE VERB INDEX
                CAF             PRIO32
                TC              NOVAC                   # ENTER JOB TO CHANGE DISPLAY TO
                EBANK=          XYMARK                  # REQUEST NEXT ACTION
                2CADR           CHANGEVB

                TC              RESUME

CHANGEVB        INDEX           MKDEX                   # INFLIGHT-PICK UP MARK VB INDEX
                CAF             MKVB54
                TC              BANKCALL                # PASTE UP NEXT MK VERB DISPLAY
                CADR            PASTIT

# THE FOUR MKVBS ARE INDEXED-THEIR ORDER CANNOT BE CHANGED

MKVB54          VN              5471                    # MAKE X OR Y MARK
MKVB53          VN              5371                    # MAKE Y MARK
MKVB52          VN              5271                    # MAKE X MARK
MKVB54*         VN              5471                    # MAKE X OR Y MARK
DP1/8           2DEC            .125
OCT34           OCT             34
V06N71          VN              671
