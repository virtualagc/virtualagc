### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AOTMARK.agc
## Purpose:     A section of Aurora 88.
##              It is part of the reconstructed source code for the final
##              release of the Lunar Module system test software. No original
##              listings of this program are available; instead, this file
##              was created via disassembly of dumps of Aurora 88 core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-30 MAS  Created from Aurora 12.
##              2023-07-12 MAS  Updated for Aurora 88.

                SETLOC  ENDIMODS

                EBANK=  AOTAZ
AOTMARK         INHINT
                TS      RUPTREG2        # BIT14=INFLIGHT 0=NONFLIGHT
                CCS     MARKSTAT        # ARE MARKS BUTTONS IN USE
                TC      +2              # MARKS BUTTONS NOT AVAILABLE
                TC      MKVAC           # FIND A VAC AREA
                TC      ALARM
                OCT     00105
                TC      ENDOFJOB

MKVAC           CCS     VAC1USE
                TC      MKVACFND
                CCS     VAC2USE
                TC      MKVACFND
                CCS     VAC3USE
                TC      MKVACFND
                CCS     VAC4USE
                TC      MKVACFND
                CCS     VAC5USE
                TC      MKVACFND
                TC      ABORT           # VAC AREAS OCCUPIED
                OCT     01207

MKVACFND        AD      TWO
                TS      MARKSTAT
                CAF     ZERO
                TS      XYMARK          # INITIALIZE MARK ID REGISTER
                INDEX   MARKSTAT
                TS      0 -1            # SHOW VAC OCCUPIED

                CA      RUPTREG2
                ADS     MARKSTAT

                CAF     PRIO32
                TC      NOVAC
                2CADR   GETMKS

                TC      MODEEXIT

MKRELEAS        CAF     ZERO
                XCH     MARKSTAT        # SET MARKSTAT ZERO
                CCS     A
                INDEX   A
                TS      0               # SHOW VAC AREA AVAILABLE
                TC      SWRETURN
GETMKS          CAF     ZERO
                TS      XYMARK
                CAF     BIT14           # FIND IF IN-FLIGHT OR NON-FLIGHT
                MASK    MARKSTAT
                CCS     A
                TC      MKVB53          # IN-FLIGHT
                CS      BIT11           # NON-FLIGHT, SET Y MARK =1
                MASK    MARKSTAT
                AD      BIT11
                TS      MARKSTAT
                CAF     VB51            # REQUEST X MARK
                TC      +2
MKVB53          CAF     VB53            # REQUEST X AND Y MARKS
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TC      GETMKS +1
                TC      GETMKS +1

MKCHEK          CAF     BIT10           # WAS X MARK MADE
                MASK    MARKSTAT
                CCS     A
                TC      +2              # X MARK MADE-LOOK AT Y MARK
                TC      MKALARM
                CAF     BIT11
                MASK    MARKSTAT
                CCS     A
                TC      GETDET          # BOTH MARKS MADE-SHOW ACCEPT-GET DETENT

MKALARM         TC      ALARM           # IF EITHER MARK IS MISSING AFTER ENTER
                OCT     111
                CS      PRIO17          # SET BITS 10,11,12,13 TO ZERO IN MARKSTAT
                MASK    MARKSTAT
                TS      MARKSTAT
                TC      GETMKS          # GETMKS AGAIN

GETDET          CS      BIT12
                MASK    MARKSTAT
                AD      BIT12           # SET BIT12=1 TO SHOW MARKS ACCEPTED
                TS      MARKSTAT
DETVB21         CAF     V21N43E
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      DETVB21
                TC      DETVB21

                CS      OCT3
                MASK    DETCODE
                CCS     A
                TC      DETVB21         # BAD CODE, REQUEST AGAIN
                TC      +3              # LOOKS GOOD BUT COULD BE ZERO
                TC      +1
                TC      DETVB21
                CAF     OCT3
                MASK    DETCODE         # SEE IF ZERO
                CCS     A
                TC      +2              # GOOD CODE-STORE ANGLES
                TC      DETVB21         # ZERO-BAD CODE-REQUEST AGAIN

                CAF     LOW9
                MASK    MARKSTAT
                TS      BASVAC          # STORE VAC AREA ADDRESS
                INDEX   DETCODE
                CA      AOTEL -1
                INDEX   BASVAC
                TS      9D              # STORE ELV ANGLE IN VAC +9
                INDEX   DETCODE
                CA      AOTAZ -1
                INDEX   BASVAC
                TS      8D              # STORE AZIMUTH IN VAC +8

                TCF     DETVB21A        # IN-FLIGHT OR NON-FLIGHT
DETVB21B        MASK    MARKSTAT
                CCS     A
                TC      MKOUT           # IN-FLIGHT, NO MORE DATA NEEDED
                TC      ROTVB24         # NON-FLIGHT, GET ROTATION ANGLES

ROTVB24         CAF     V24N42E         # REQUEST RETICLE ROTATION ANGLES
                TC      NVSBWAIT
                TC      ENDIDLE
                TC      ROTVB24
                TC      ROTVB24

                CAF     LOW9
                MASK    MARKSTAT
                TS      BASVAC
                CA      DSPTEM2         # YROT
                INDEX   BASVAC
                TS      3               # STORE Y RETICLE ROT ANGLE IN VAC +3
                CA      DSPTEM2 +1      # SROT
                INDEX   BASVAC
                TS      5               # STORE SPIRAL ROT ANGLE VAC +5

MKOUT           CAF     LOW9
                MASK    MARKSTAT
                TS      MARKSTAT        # SET HI5 ZERO

                INHINT
                CAF     ONE
                TC      WAITLIST
                2CADR   ENDMARKS
                TC      ENDOFJOB

ENDMARKS        CAF     ONE
                TCF     GOODEND
MARKRUPT        TS      BANKRUPT
                CA      CDUY            # STORE CDU DATA AND TIME IN TEMP
                TS      RUPTSTOR +2
                CA      CDUZ
                TS      RUPTSTOR +4
                CA      CDUX
                TS      RUPTSTOR +6
                EXTEND
                DCA     TIME2
                DXCH    RUPTSTOR

                XCH     Q
                TS      QRUPT

                CAF     OCT34           # SEE IF X OR Y MARK OR MKREJECT
                EXTEND
                RAND    NAVKEYIN
                CCS     A
                TC      +2              # ITS A LIVE ONE-CHECK FOR ACCEPT
                TC      SOMEKEY         # SOME OTHER KEY

                CAF     BIT12           # HAVE MARKS BEEN ACCEPTED
                MASK    MARKSTAT
                CCS     A
                TC      RESUME          # MARKS MADE AND ACCEPTED - DO NOTHING

                CCS     MARKSTAT        # ARE MARKS BEING ACCEPTED
                TC      FINDKEY
                TC      ALARM           # MARKS NOT BEING ACCEPTED
                OCT     112
                TC      RESUME

FINDKEY         CAF     BIT5
                EXTEND
                RAND    NAVKEYIN        # CHANNEL 16
                CCS     A
                TC      MKREJ           # ITS A MARK REJECT
                CAF     BIT4
                EXTEND
                RAND    NAVKEYIN
                CCS     A
                TC      YMKRUPT         # ITS A Y MARK
                CAF     BIT3
                EXTEND
                RAND    NAVKEYIN
                CCS     A
                TC      XMKRUPT         # ITS AN X MARK
SOMEKEY         CAF     OCT140          # NOT MARK OR MARK REJECT
                EXTEND
                RAND    NAVKEYIN
                EXTEND
                BZF     +3              # IF NO INBITS.

                TC      POSTJUMP        # IF DESCENT BITS.
                CADR    DESCBITS
 +3             TC      ALARM
                OCT     113
                TC      RESUME

XMKRUPT         CAF     ZERO
                TS      ITEMP1
                CAF     BIT10
                TC      +4
YMKRUPT         CAF     ONE
                TS      ITEMP1
                CAF     BIT11
                TS      XYMARK          # SET MARK ID

                MASK    MARKSTAT
                CCS     A
                TC      +2              # MARK MADE BUT NOT DESIRED
                TC      VACSTOR         # MARK DESIRED AND MADE-STORE CDUS
                TC      ALARM
                OCT     114
                TC      REMARK          # RENEW REQUEST

VACSTOR         CAF     LOW9            # STORE TIME AND CDUS IN VAC AREA
                MASK    MARKSTAT
                TS      ITEMP2
                EXTEND
                DCA     RUPTSTOR
                INDEX   ITEMP2
                DXCH    0               # STORE TIME1 AND TIME2 IN VAC
                CA      ITEMP2
                ADS     ITEMP1
                CA      RUPTSTOR +2
                INDEX   ITEMP1
                TS      2
                CA      RUPTSTOR +4
                INDEX   ITEMP1
                TS      4
                CA      RUPTSTOR +6
                INDEX   ITEMP1
                TS      6

                CAF     BIT13
                AD      XYMARK
                COM
                MASK    MARKSTAT
                AD      XYMARK          # SET MARK MADE BIT IN MARKSTAT=1
                TS      MARKSTAT        # AND SET BIT13 ZERO TO SHOW MARK
                TC      REMARK          # MADE BEFORE A REJECT - GO REMARK
REMARK          CAF     ZERO
                TS      MKDEX           # MKDEX=0
                CAF     BIT11           # LOOK A Y MARK
                MASK    MARKSTAT
                CCS     A
                TC      +3              # Y MARK MADE
                CAF     BIT8            # Y MARK REQUIRED
                TS      MKDEX

                CAF     BIT10           # LOOK AT X MARK
                MASK    MARKSTAT
                CCS     A
                TC      MKJOB
                CAF     BIT7            # X MARK REQUIRED
                ADS     MKDEX

MKJOB           CAF     PRIO32
                TC      NOVAC           # ENTER JOB TO PASTE VERB
                2CADR   CHANGVB

                CA      RUPTREG4
                INDEX   LOCCTR
                TS      MPAC
                TC      RESUME

CHANGVB         CCS     MPAC
                TC      SHOWVB
                CAF     VB21N30E
                TC      SHOWVB +2
SHOWVB          CAF     VB50
                AD      MPAC
                TS      NVTEMP
                CA      CADRSTOR        # NVSUB CLOBBERS THIS-USE LOC AS TEMP
                TS      LOC
                TC      NVSUB +3
VB51            OCT     5100
                CA      LOC             # RESTORE CADRSTOR
                TS      CADRSTOR
                TC      ENDOFJOB

MKREJ           CAF     BIT14           # IN-FLIGHT OR NON-FLIGHT
                MASK    MARKSTAT
                CCS     A
                TC      REJIN           # IN-FLIGHT
                CAF     BIT10           # NON-FLIGHT, SEE IF X MARK MADE
                MASK    MARKSTAT
                CCS     A
                TC      REJECT2         # XMARK MADE-REJECT IT
                TC      REJALARM        # X MARK NOT MADE-ALARM-NO MARKS TO REJ
REJIN           CAF     PRIO3           # WERE IN-FLIGHT MARKS MADE
                MASK    MARKSTAT
                CCS     A
                TC      REJECT          # MARKS MADE-REJECT ONE
REJALARM        TC      ALARM           # NO MARKS MADE TO REJECT-GET MARKS
                OCT     115
                TC      REJECT2
REJECT          CS      BIT13           # SHOW MKREJECT AND SEE MARK MADE
                MASK    MARKSTAT        # SINCE LAST REJECT
                AD      BIT13
                XCH     MARKSTAT
                MASK    BIT13
                CCS     A
                TC      REJECT2         # ANOTHER REJECT
                CS      XYMARK          # MARK MADE SINCE LAST REJECT-REJECT IT
                MASK    MARKSTAT
                TS      MARKSTAT
                TC      REMARK          # GO REQUEST MARKS

REJECT2         CS      PRIO3           # NO MARKS SINCE LAST REJECT SO SET
                MASK    MARKSTAT        # MARKSTAT TO WANT X AND Y MARKS
                XCH     MARKSTAT
                MASK    BIT14           # IN-FLIGHT OR NON-FLIGHT
                CCS     A
                TC      REMARK          # IN-FLIGHT, GO GET MARKS
                CAF     BIT11           # NON-FLIGHT, STILL REQUEST X MARK ONLY
                ADS     MARKSTAT
                TC      REMARK          # GO GET X MARK

OCT3            EQUALS  THREE
OCT34           OCT     00034
OCT140          OCT     00140
V21N43E         OCT     2143
V24N42E         OCT     2442
VB53            OCT     5300
MKDEX           EQUALS  RUPTREG4
DETCODE         EQUALS  XYMARK
BASVAC          EQUALS  Q
VB21N30E        OCT     2130
VB50            OCT     5000

## MAS 2023: The following chunks of code (down to ENDAMODS) were added as patches
## between Aurora 85 and Aurora 88. They were placed here at the end of the bank
## so as to not change addresses of existing symbols.

4SECSM          DEC     400



IMUZERO1        INHINT
                CS      DSPTAB +11D     # DONT ZERO CDUS IF IMU IN GIMBAL LOCK AND
                MASK    BITS4&6         # COARSE ALIGN.
                CCS     A

                TCF     IMUZEROA

                TC      ALARM           # IF SO.
                OCT     206

                TCF     CAGETSTJ +4
                TC      IMUZEROA

IMUZEROB        TC      NOATTOFF        # TURN OFF NO ATT LAMP.
                CAF     BIT5
                TC      IMUZEROC



SETCOARS        CAF     BIT4            # PUT ISS IN COARSE ALIGN.
                EXTEND
                WOR     12

NOATTON         CS      OCT40010        # TURN ON NO ATT LAMP.
                MASK    DSPTAB +11D
                AD      OCT40010
                TS      DSPTAB +11D

                CS      BIT4            # INHIBIT IMU FAIL.
                MASK    IMODES30
                AD      BIT4
                TS      IMODES30

                TC      Q

OCT40010        OCT     40010



IMUFINE1        TC      NOATTOFF        # TURN OFF NO ATT LAMP.
                CAF     BIT10
                TC      IMUFINE2



PFAILOK1        CS      BIT10           # MAKE PREVIOUS VALUE OF PIPA FAIL THE
                MASK    IMODES30        # NO FAIL STATE SO THAT IF THE FAILURE
                AD      BIT10           # INDICATION IS ON NOW, IT WILL BE PICKED
                TS      IMODES30        # UP (ROUTINE DETECTS ONLY CHANGES).

                CS      BIT13           # PIPA FAIL BIT IS KEPT IN TWO PLACES FOR
                MASK    IMODES33
                AD      BIT13
                TS      IMODES33

                CS      BIT5
                TCF     PFAILOK2



NOATTOFF        CS      OCT40010        # TURN OFF NO ATT LAMP.
                MASK    DSPTAB +11D
                AD      BIT15
                TS      DSPTAB +11D
                TC      Q



GLCKCHK1        TS      L

                CS      DSPTAB +11D
                EXTEND
                RAND    12
                MASK    BIT4
                CCS     A
                TC      NOATTON

                CA      L
                EXTEND
                BZMF    SETGLCK1        # NO LOCK.

                AD      -15DEGS         # SEE IF ABS(MGA) GREATER THAN 85 DEGREES.
                EXTEND
                BZMF    NOGIMRUN

                CAF     BIT4            # IF SO, SYSTEM SHOULD BE IN COARSE ALIGN
                EXTEND                  # TO PREVENT GIMBAL RUNAWAY.
                RAND    12
                CCS     A
                TCF     NOGIMRUN

                TC      SETCOARS

NOGIMRUN        CAF     BIT6            # TURN ON GIMBAL LOCK LAMP.
                TC      POSTJUMP
                CADR    GLOCKCHK +4

SETGLCK1        TC      POSTJUMP
                CADR    SETGLOCK -1

-15DEGS		DEC	-.08333



DETVB21A        CA      AOTAZ   +1      # COMPENSATION FOR THE APPARENT TILT OF
                EXTEND                  # AOT FIELD OF VIEW IN THE LEFT AND RIGHT
                INDEX   DETCODE         # DETENTS IS STORED IN LOC 10D OF VAC
                MSU     AOTAZ   -1      # IN ONES COMPLEMENT
                INDEX   BASVAC
                TS      10D             # SINGLE PREC. TILT COMPENSATION ANGLE

                CAF     BIT14           # IN-FLIGHT OR NON-FLIGHT
                TCF     DETVB21B

ENDAMODS        EQUALS
