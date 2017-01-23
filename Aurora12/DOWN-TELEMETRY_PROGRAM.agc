### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     DOWN_TELEMETRY_PROGRAM.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Hartmuth Gutsche <hgutsche@xplornet.com>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        370-376
## Mod history:  2016-09-20 JL   Created.
##               2016-09-21 HG   Initial transfer from scan
##               2016-10-08 HG   Add missed ECADR RSTACK +46D,
##                               Remove added decimal markes D  
##               2016-10-11 HG   fix label DNPAHSE1 -> DNPHASE1   
##                                         DNPAHSE2 -> DNPHASE3 
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 and fixed the errors found.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of 
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent 
## reduction in image quality) are available online at 
##       https://www.ibiblio.org/apollo.  
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 370
                BANK    15
                EBANK=  DNTMBUFF
LOWIDCOD        OCT     00437           # FOD'S CHOICE.
#       SPECIAL DOWNLINK LIST FOR AGS INITIALIZATION, MUST BE IN LOCATION 2001 OF DOWNLINK FBANK,
AGSLIST         ECADR   UPLOCK
                ECADR   TIME1
                ECADR   TIME2   
                ECADR   AGSWORD
                ECADR   AGSBUFF +27D
                ECADR   AGSBUFF +26D
                ECADR   AGSBUFF +25D
                ECADR   AGSBUFF +24D
                ECADR   AGSWORD
                ECADR   AGSBUFF +23D
                ECADR   AGSBUFF +22D
                ECADR   AGSBUFF +21D
                ECADR   AGSBUFF +20D
                ECADR   AGSWORD
                ECADR   AGSBUFF +19D
                ECADR   AGSBUFF +18D
                ECADR   AGSBUFF +17D
                ECADR   AGSBUFF +16D
                ECADR   AGSWORD
                ECADR   AGSBUFF +15D
                ECADR   AGSBUFF +14D
                ECADR   AGSBUFF +13D
                ECADR   AGSBUFF +12D
                ECADR   AGSWORD
                ECADR   AGSBUFF +11D
                ECADR   AGSBUFF +10D
                ADRES   AGSBUFF +9D
                ADRES   AGSBUFF +8D
                ADRES   AGSWORD
                ADRES   AGSBUFF +7
                ADRES   AGSBUFF +6
                ADRES   AGSBUFF +5
                ADRES   AGSBUFF +4
                ADRES   AGSWORD
                ADRES   AGSBUFF +3
                ADRES   AGSBUFF +2
                ADRES   AGSBUFF +1
                ADRES   AGSBUFF 
## Page 371
#       THIS ROUTINE IS INITITATED EVERY 20MS BY AN INTERRUPT TRIGGERED
# BY THE RECEIPT OF AN ENDPULSE FROM THE SPACECRAFT TELEMETRY PROGRAMMER.

DODOWNTM        TS      BANKRUPT        # DO APPROPRIATE TM PHASE.
                INDEX   DNTMGOTO
                TCF     0
                
DNPHASE1        CA      DNLSTADR        # ONCE PER CYCLE (1 SECOND), AN ID IS SENT
                TS      LDATALST        # AND THE DATA LIST SWITCHED TO THAT
                MASK    LOW10           # SELECTED BY A MISSION OR TEST PROGRAM.
                EXTEND
                WRITE   DNTM1
                CS      BIT7            # WORD ORDER BIT IS 0 FOR ID OWRD ONLY.
                EXTEND
                WAND    13
                
                CAF     LDNPHAS2        # SWITCH TO PHASE 2.
                TS      DNTMGOTO
                CAF     LOWIDCOD        # SPECIAL ID CODE IN L.
                TCF     TMEXITL
                
DNPHASE2        CAF     BIT7            # SET WORD ORDER BACK TO 1 FOR REMAINDER
                EXTEND                  # OF CYCLE AND SET UP TO PICK UP 12 PAIRS
                WOR     13              # FROM ANYWHERE IN COMMON ERASABLE OR E7.
                
                CAF     ZERO    
                TS      ITEMP1          # TAKE SNAPSHOT OF 12 DP WORDS.
                CAF     TEN
                
LOOP            TS      ITEMP2          # THESE 12 DP WORDS ARE READ INTO AN
                AD      LDATALST        # INTERMEDIATE BUFFER SO THEY REFER TO THE
                EXTEND                  # SAME POINT IN THE EXECUTION OF A MISSION
                INDEX   A               # PROGRAM. THE WORDS MAY BE IN NON-
                INDEX   26D
                DCA     0               # 12 OF THE DATA LIST ARE USED AS
                INDEX   ITEMP1          # ADDRESSES OF THE DESIRED DATA.
                DXCH    DNTMBUFF
                
                CAF     TWO
                ADS     ITEMP1
                CCS     ITEMP2
                TCF     LOOP
                
                CAF     DEC11           # SET UP TO SEND 11 REMAINING WORDS
                TS      TMINDEX
                CAF     LDNPHASX
                TS      DNTMGOTO
                
                EXTEND
                INDEX   LDATALST
## Page 372                
                INDEX   37D
                DCA     0
                TCF     DNTMEXIT
                
DNPHASXA        TS      TMINDEX
                EXTEND
                INDEX   A               # SENDS SNAPSHOT BUFFER.
                INDEX   FIXLISTB
                DCA     0
                TCF     DNTMEXIT
                
DNPHASEX        CCS     TMINDEX         # AT END OF SNAPSHOT TRANSMISSION, SET UP
                TCF     DNPHASXA        # TO SEND 26 PRS FROM ANY ERASABLE LOC AS
                
                CAF     LDNPHAS3        # SPECIFIED BY WORDS 1 - 26 OF THE DATA
                TS      DNTMGOTO        # LIST.
                CAF     NOGENWDS
                
PHASE3A         TS      TMINDEX         # GET DP WORD FROM ANY EBANK.
                AD      LDATALST
                EXTEND
                INDEX   A
                DCA     0               # THIS GETS THE ADDRESS - MUST USE DCA
                TS      EBANK
                MASK    LOW8
                EXTEND
                INDEX   A       
                DCA     3400            # (NOTE ASSEMBLY AS DCA 1400)
DNTMEXIT        EXTEND                  # GENERAL DNTM EXIT LOCATION.
                WRITE   DNTM1
                CA      L
TMEXITL         EXTEND
                WRITE   DNTM2
                TCF     NOQRSM
                
DNPHASE3        CCS     TMINDEX
                TCF     PHASE3A
                
                CAF     LDNPHAS4        # SEND FIXED FORMAT LIST OF DSPTAB AND
                TS      DNTMGOTO        # T2, T1.
                CAF     SIX
                
PHASE4A         TS      TMINDEX
                EXTEND                  # FIXED DATA LIST FOR DSPTAB AND TIME.
                INDEX   A
                INDEX   FIXLIST
                DCA     0
                TCF     DNTMEXIT
## Page 373       
DNPHASE4        CCS     TMINDEX
                TCF     PHASE4A
                
                CAF     LPHASE5         # SET UP FOR CHANNEL TRANSMISSION.
                TS      DNTMGOTO
                CAF     THREE           # FOUR PAIRS OF CHANNELS.
                
PHASE5A         TS      TMINDEX
                EXTEND
                INDEX   A
                INDEX   FIXLSTCL       
                READ    0
                TS      L
                EXTEND
                INDEX   TMINDEX
                INDEX   FIXLSTCA
                READ    0
                TCF     DNTMEXIT
DNPHASE5        CCS     TMINDEX
                TCF     PHASE5A
                TCF     DNPHASE1        # START NEXT CYCLE.
## Page 374
#       CONSTNATS AND FIXED FORMAT DATA LIST.
LDNPHAS2        ADRES   DNPHASE2
LDNPHASX        ADRES   DNPHASEX
LDNPHAS3        ADRES   DNPHASE3
LDNPHAS4        ADRES   DNPHASE4
LPHASE5         ADRES   DNPHASE5

NOGENWDS        DEC     25              # 26 WORDS SENT DURING PHASE 3.
DEC11           DEC     11

FIXLIST         ADRES   TIME2           # FIXED-FORMAT PORTION INCLUDES BUFFER,
                ADRES   DSPTAB +10D     # DSPTAB, AND TIME.
                ADRES   DSPTAB +8D
                ADRES   DSPTAB +6
                ADRES   DSPTAB +4
                ADRES   DSPTAB +2
                ADRES   DSPTAB 
                
FIXLISTB        ADRES   DNTMBUFF +20D
                ADRES   DNTMBUFF +18D
                ADRES   DNTMBUFF +16D
                ADRES   DNTMBUFF +14D
                ADRES   DNTMBUFF +12D
                ADRES   DNTMBUFF +10D
                ADRES   DNTMBUFF +8D
                ADRES   DNTMBUFF +6D
                ADRES   DNTMBUFF +4D
                ADRES   DNTMBUFF +2D
                ADRES   DNTMBUFF

FIXLSTCA        OCT     32              # CHANNEL ADDRESSES.
                OCT     30
                OCT     13
                OCT     11
                
FIXLSTCL        OCT     33
                OCT     31
                OCT     14
                OCT     12
## Page 375                
#       SPECIAL DATA LIST FOR HIGH SPEED RADAR SAMPLING. TELEMETERS TABLE OF 12 MEASUREMENTS OF 5 WORDS EACH -
# DATA IN WORDS 1 & 2, RR CDU ANGLES IN 3 & 4, AND TIME 1 IN 5.
FSTRADTM        ECADR   UPLOCK
                ECADR   RFAILCNT        # COUNTS BAD SAMPLES.
                ECADR   RSTACK +70D
                ECADR   RSTACK +68D
                ECADR   RSTACK +66D
                ECADR   RSTACK +64D
                ECADR   RSTACK +62D
                ECADR   RSTACK +60D
                ECADR   RSTACK +58D
                ECADR   RSTACK +56D
                ECADR   RSTACK +54D
                ECADR   RSTACK +52D
                ECADR   RSTACK +50D
                ECADR   RSTACK +48D
                ECADR   RSTACK +46D
                ECADR   RSTACK +44D
                ECADR   RSTACK +42D
                ECADR   RSTACK +40D
                ECADR   RSTACK +38D
                ECADR   RSTACK +36D
                ECADR   RSTACK +34D
                ECADR   RSTACK +32D
                ECADR   RSTACK +30D
                ECADR   RSTACK +28D
                ECADR   RSTACK +26D
                ECADR   RSTACK +24D
                ADRES   RSTACK +22D
                ADRES   RSTACK +20D
                ADRES   RSTACK +18D
                ADRES   RSTACK +16D
                ADRES   RSTACK +14D
                ADRES   RSTACK +12D
                ADRES   RSTACK +10D
                ADRES   RSTACK +8D
                ADRES   RSTACK +6
                ADRES   RSTACK +4
                ADRES   RSTACK +2
                ADRES   RSTACK
## Page 376        
#       NOMINAL AURORA DOWNLIST.
NOMDNLST        ECADR   UPLOCK
                ECADR   DATAPL +6
                ECADR   DATAPL +4
                ECADR   DATAPL +2
                ECADR   DATAPL
                ECADR   VLAUN +4
                ECADR   VLAUN
                ECADR   ANGX
                ECADR   ANGY
                ECADR   ANGZ
                ECADR   INTY
                ECADR   DRIFTT
                ECADR   DRIFTI
                ECADR   DRIFTO
                ECADR   MARKSTAT
                ECADR   THETAD +2
                ECADR   THETAD
                ECADR   TANG
                ECADR   LASTYCMD
                ECADR   LMPCMD
                ECADR   REDOCTR         # INCLUDES FAILREG.
                ECADR   STATE +2
                ECADR   STATE
                ECADR   OPTY
                ECADR   CDUZ
                ECADR   CDUX
                ADRES   FORVEL
                ADRES   FINALT
                ADRES   ALTSAVE
                ADRES   ALTRATE
                ADRES   ALT
                ADRES   TIMEHOLD
                ADRES   OPTYHOLD
                ADRES   SAMPLSUM
                ADRES   OLDATAGD
                ADRES   RADMODES
                ADRES   PIPAZ
                ADRES   PIPAX
ENDDNTMS        EQUALS
