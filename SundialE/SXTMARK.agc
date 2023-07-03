### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SXTMARK.agc
## Purpose:     A section of Sundial E.
##              It is part of the reconstructed source code for the final
##              release of the Block II Command Module system test software. No
##              original listings of this program are available; instead, this
##              file was created via disassembly of dumps of Sundial core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-22 MAS  Created from Aurora 12.
##              2023-06-30 MAS  Updated for Sundial E.
##              2023-07-03 MAS  Moved in patch from IMU MODE SWITCHING ROUTINES.


                SETLOC  ENDIMODS

                EBANK=  MARKSTAT
SXTMARK         INHINT
                TS      RUPTREG1        # BIT14=INFLIGHT 0=NONFLIGHT
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

MKVACFND        AD      TWO             # ADDRESS OF VAC AREA
                TS      MARKSTAT
                INDEX   A
                TS      QPRET           # STORE NEXT AVAILABLE MARK SLOT

                CAF     ZERO            # SHOW VAC AREA OCCUPIED
                INDEX   MARKSTAT
                TS      0 -1

                CAF     BIT12           # DESIRED NUMBER OF MARKS IN 12-14
                EXTEND
                MP      RUPTREG1
                XCH     L
                ADS     MARKSTAT

                CAF     PRIO32          # ENTER MARK JOB
                TC      NOVAC
                EBANK=  MARKSTAT
                2CADR   MKVB51

                RELINT
                TCF     SWRETURN        # SAME AS MODEEXIT

MKRELEAS        CS      BIT9            # COARSE OPTICS RETURN FLAG.
                MASK    OPTMODES
                TS      OPTMODES

                CA      NEGONE
                TS      OPTIND          # KILL COARS OPTICS
                CAF     ZERO
                XCH     MARKSTAT        # SET MARKSTAT ZERO
                CCS     A
                INDEX   A
                TS      0               # SHOW VAC AREA AVAILABLE
                TC      SWRETURN

MARKRUPT        TS      BANKRUPT
                CA      OPTY            # STORE CDU DATA AND TIME IN TEMP
                TS      RUPTSTOR +5
                CA      OPTX
                TS      RUPTSTOR +3
                CA      CDUY
                TS      RUPTSTOR +2
                CA      CDUZ
                TS      RUPTSTOR +4
                CA      CDUX
                TS      RUPTSTOR +6
                EXTEND
                DCA     TIME2
                DXCH    RUPTSTOR
                EXTEND
                DCA     RUPTSTOR
                DXCH    SAMPTIME        # RUPT TIME FOR NOUN 65.

                XCH     Q
                TS      QRUPT

                CAF     BIT6            # SEE IF MARK OR MKREJECT
                EXTEND
                RAND    NAVKEYIN
                CCS     A
                TC      MARKIT          # ITS A MARK

                CAF     BIT7            # NOT A MARK, SEE IF MKREJECT
                EXTEND
                RAND    NAVKEYIN
                CCS     A
                TC      MKREJECT        # ITS A MARK REJECT

KEYCALL         CAF     OCT37           # NOT MARK OR MKREJECT, SEE IF KEYCODE
                EXTEND
                RAND    NAVKEYIN
                EXTEND
                BZF     +3              # IF NO INBITS
                TC      POSTJUMP
                CADR    KEYCOM          # IT,S A KEY CODE, NOT A MARK.

 +3             TC      ALARM           # ALARM IF NO INBITS
                OCT     113
                TC      RESUME

MARKIT          CCS     MARKSTAT        # SEE IF MARKS BEING CALLED FOR.
                TC      MARK2

                CA      RUPTSTOR +3     # STORE IN OBTAINED MPAC COMPLEMENTED.
                TS      RUPTREG1        # OPTICS ANGLES AND MINOR PART OF TIME.
                CA      RUPTSTOR +5     # -OPTX, -OPTY, AND -TIME1.
                TS      RUPTREG2
                CA      RUPTSTOR +1
                TS      RUPTREG3

                CAF     PRIO5           # CALL SPECIAL DISPLAY JOB
                TC      NOVAC
                EBANK=  MARKSTAT
                2CADR   MARKDISP

                CA      RUPTREG1        # PLANT INFORMATION IN MPAC OF REGISTER
                INDEX   LOCCTR          # SET.
                TS      MPAC
                CA      RUPTREG2
                INDEX   LOCCTR
                TS      MPAC +1
                CA      RUPTREG3
                INDEX   LOCCTR
                TS      MPAC +2

                TC      RESUME

MARK2           AD      74K             # SEE IF ANY MORE MARKS CALLED FOR.
                EXTEND
                BZMF    BADMARK
                TS      MARKSTAT
                TC      MARK3

BADMARK         TC      ALARM
                OCT     00114
                TC      RESUME          # NO FURTHER ACTION HERE.

MARK3           CS      BIT10           # SET BIT 10 = 1 TO ENABLE MARK
                MASK    MARKSTAT        # REJECT.
                AD      BIT10
                TS      MARKSTAT

                MASK    LOW9
                TS      ITEMP1
                INDEX   A
                XCH     QPRET           # PICK UP MARK SLOT-POINTER
                TS      ITEMP2          # SAVE CURRENT POINTER
                AD      SEVEN           # INCREMENT POINTER
                INDEX   ITEMP1
                TS      QPRET           # STORE ADVANCED POINTER

VACSTOR         EXTEND
                DCA     RUPTSTOR
                INDEX   ITEMP2
                DXCH    0
                CA      RUPTSTOR +2
                INDEX   ITEMP2
                TS      2
                CA      RUPTSTOR +3
                INDEX   ITEMP2
                TS      3
                CA      RUPTSTOR +4
                INDEX   ITEMP2
                TS      4
                CA      RUPTSTOR +5
                INDEX   ITEMP2
                TS      5
                CA      RUPTSTOR +6
                INDEX   ITEMP2
                TS      6

                CAF     PRIO34          # IF ALL MARKS MADE FLASH VB50
                MASK    MARKSTAT
                EXTEND
                BZF     +2
                TC      RESUME
                CAF     PRIO32
                TC      NOVAC
                EBANK=  MARKSTAT
                2CADR   MKVB50
                TC      RESUME

MKREJECT        CCS     MARKSTAT        # SEE IF MARKS BEING ACCEPTED
                TC      REJECT2
                TC      ALARM           # MARKS NOT BEING ACCEPTED
                OCT     112
                TC      RESUME

REJECT2         CS      BIT10           # SEE IF MARK HAD BEEN MADE SINCE LAST
                MASK    MARKSTAT        # REJECT, AND SET BIT10 TO ZERO TO
                XCH     MARKSTAT        # SHOW MARK REJECT
                MASK    BIT10
                CCS     A
                TC      REJECT3

                TC      ALARM           # DONT ACCEPT TWO REJECTS TOGETHER
                OCT     110
                TC      RESUME

REJECT3         CAF     LOW9            # DECREMENT POINTER TO REJECT MARK
                MASK    MARKSTAT
                TS      ITEMP1
                CS      SEVEN
                INDEX   ITEMP1
                ADS     QPRET           # NEW POINTER

                CAF     BIT12           # INCREMENT MARKS WANTED AND IF FIELD
                AD      MARKSTAT        # IS NOW NON-ZERO, CHANGE TO VB51 TO
                XCH     MARKSTAT        # INDICATE MORE MARKS WANTED
                MASK    PRIO34          # INDICATE MORE MARKS WANTED
                CCS     A
                TC      RESUME
                CAF     PRIO32
                TC      NOVAC
                EBANK=  MARKSTAT
                2CADR   REMKVB51
                TC      RESUME

MKVB51          CAF     VB51            # ASSUME USING PROGRAM HAS GRABBED DSP.
                TC      NVSBWAIT
                TC      FLASHON
                TC      ENDIDLE
                TC      MKVB5X          # DONT RESPOND TO PROCEED OR TERMINATE.
                TC      MKVB5X

                CAF     OCT76           # ON ENTER, SEE IF DATA LOADED INSTEAD.
                MASK    VERBREG
                AD      -OCT50          # VERBS 50 AND 51 CAUSE END MARK ROUTINES.
                CCS     A
                TC      MKVB5X          # ON DATA LOAD, RE-DISPLAY ORIGINAL VERB.
-OCT50          OCT     -50
                TC      MKVB5X

                CAF     LOW9
                MASK    MARKSTAT
                TS      MARKSTAT        # VAC ADR IN MARKSTAT AND NO. MARKS MADE
                COM
                INDEX   MARKSTAT        # WILL BE LEFT IN QPRET.
                AD      QPRET
                EXTEND
                MP      BIT12
                AD      ONE
                INDEX   MARKSTAT
                TS      QPRET

                INHINT                  # GO SERVICE OPTSTALL INTERFACE WITH
                CAF     ONE             # USING PROGRAM.
                TC      WAITLIST
                EBANK=  MARKSTAT
                2CADR   ENDMARKS
                TC      ENDOFJOB

ENDMARKS        CAF     ONE
                TCF     GOODEND

MKVB5X          CAF     PRIO34          # RE-DISPLAY VERB 51 IF MORE MARKS
                MASK    MARKSTAT        # WANTED AND VERB 50 IF ALL IN.
                CCS     A
                CAF     BIT7            # (MAKES VERB 51).
                AD      VB50
                TC      MKVB51 +1

#       ON RECEIPT OF LAST REQUESTED MARK, DISPLAY VERB 50 (STILL FLASHING).

MKVB50          CAF     VB50
                TS      NVTEMP          # SPECIAL ENTRY TO NVSUB WHICH AVOIDS BUSY
                TC      NVSUB +3        # TEST.
VB51            OCT     5100
                TC      ENDOFJOB

#       IF THE ABOVE IS REJECTED, REVERT TO VERB 51.

REMKVB51        CAF     VB51
                TC      MKVB50 +1

MARKDISP        TC      GRABDSP         # SPECIAL JOB TO DISPLAY UNCALLED-FOR MARK
                TC      PREGBSY

REMKDSP         CA      MPAC            # THE MPAC REGISTERS CONTIN -OPTX, -OPTY,
                TS      DSPTEM1
                CA      MPAC +1
                TS      DSPTEM1 +1
                CA      MPAC +2
                TS      DSPTEM2
                CAF     ZERO
                TS      DSPTEM1 +2

                CAF     MKDSPCOD        # NOUN-VERB FOR MARK DISPLAY.
                TC      NVSUB
                TC      MKDSPBSY        # IF BUSY.

ENDMKDSP        TC      FREEDSP

                TC      ENDOFJOB

MKDSPBSY        CAF     LREMKDSP        # TAKE DATA OUT OF MPAC WHEN RE-AWAKENED.
                TC      NVSUBUSY

VB50            =       PRIO5
MKDSPCOD        OCT     00656
LREMKDSP        CADR    REMKDSP
OCT37           OCT     37
OCT76           OCT     76

## MAS 2023: The following chunk of code was added as a patch
## in Sundial D. It was placed here at the end of the bank
## so as to not change addresses of existing symbols.

IMUZERO1        CAF     BIT4            # DONT ZERO CDUS IF IMU IN GIMBAL LOCK AND
                EXTEND                  # COARSE ALIGN.
                RAND    12
                DOUBLE
                DOUBLE
                MASK    DSPTAB +11D
                CCS     A
                TCF     +3

                CS      IMUSEFLG
                TCF     IMUZERO +2

                TC      ALARM           # IF SO.
                OCT     206

                TCF     CAGETSTJ +4

ENDSMODS        EQUALS
