### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    DOWNLINK_LISTS.agc
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



                BANK            22
                SETLOC          DOWNTELM
                BANK

                EBANK=          DNTMBUFF

# SPECIAL DOWNLINK OP CODES
#       OP CODE  ADDRESS(EXAMPLE) SENDS..     BIT 15  BITS 14-12 BITS 11
#                                                                     -0
#       ------  ----------      ----------    ------  ---------- -------
#                                                                     --
#       1DNADR  TIME2           (2 AGC WDS)     0         0      ECADR
#       2DNADR  TEPHEM          (4 AGC WDS)     0         1      ECADR
#       3DNADR  VGBODY          (6 AGC WDS)     0         2      ECADR
#       4DNADR  STATE           (8 AGC WDS)     0         3      ECADR
#       5DNADR  UPBUFF          (10 AGC WDS)    0         4      ECADR
#       6DNADR  DSPTAB          (12 AGC WDS)    0         5      ECADR
#       DNCHAN  30              CHANNELS        0         7      CHANNEL
#                                                                ADDRESS
#       DNPTR   NEXTLIST        POINTS TO NEXT  0         6      ADRES
#                                LIST.

# DOWNLIST FORMAT DEFINITIONS AND RULES-
# 1. END OF A LIST = -XDNADR (X = 1 TO 6), -DNPTR, OR -DNCHAN.
# 2. SNAPSHOT SUBLIST = LIST WHICH STARTS WITH A -1DNADR.
# 3. SNAPSHOT SUBLIST CAN ONLY CONTAIN 1DNADRS.
# 4. TIME2 1DNADR MUST BE LOCATED IN THE CONTROL LIST OF A DOWNLIST.
# 5. ERASABLE DOWN TELEMETRY WORDS SHOULD BE GROUPED IN SEQUENTIAL
#    LOCATIONS AS MUCH AS POSSIBLE TO SAVE STORAGE USED BY DOWNLINK LISTS.

                COUNT*          $$/DLIST
ERASZERO        EQUALS          7
UNKNOWN         EQUALS          ERASZERO
SPARE           EQUALS          ERASZERO                # USE SPARE TO INDICATE AVAILABLE SPACE
LOWIDCOD        OCT             77340                   # LOW ID CODE


NOMDNLST        EQUALS          LMCSTADL                # FRESH START AND POST P27 DOWNLIST

AGSLIST         EQUALS          LMAGSIDL

UPDNLIST        EQUALS          LMAGSIDL                # UPDATE PROGRAM (P27) DOWNLIST

# LM AGS INITIALIZATION AND UPDATE DOWNLIST

#     -----------------  CONTROL LIST  --------------------------

LMAGSIDL        EQUALS                                  # SEND IO BY SPECIAL CODING
                DNPTR           LMAGSI01                # COLLECT SNAPSHOT
                DNPTR           LMAGSI02                # SEND SNAPSHOT
                4DNADR          AGSBUFF         +7      # AGSBUFF+7...+13D,GARBAGE
                DNPTR           LMAGSI04                # COMMON DATA
                1DNADR          SPARE
                1DNADR          SPARE
                1DNADR          SPARE
                1DNADR          AGSK                    # AGSK,+1
                DNPTR           LMAGSI05                # COMMON DATA
                1DNADR          TIME2                   # TIME2/1
                DNPTR           LMAGSI03                # COLLECT SNAPSHOT
                DNPTR           LMAGSI02                # SEND SNAPSHOT
                2DNADR          REDOCTR                 # REDOCTR,THETAD,+1,+2
                1DNADR          SPARE
                1DNADR          SPARE
                DNPTR           LMAGSI04                # COMMON DATA
                1DNADR          SPARE
                1DNADR          SPARE
                1DNADR          SPARE
                1DNADR          RADMODES                # RADMODES,DAPBOOLS
                1DNADR          SUMRATEQ                # SUMRATEQ,SUMRATER
                -DNPTR          LMAGSI06                # COMMON DATA

#     -----------------  SUB-LISTS   ----------------------------

LMAGSI01        -1DNADR         AGSBUFF         +2      # AGSBUFF+2,+3             SNAPSHOT
                1DNADR          AGSBUFF         +4      # AGSBUFF+4,+5
                1DNADR          AGSBUFF         +12D    # AGSBUFF+12D,GARBAGE
                1DNADR          AGSBUFF         +1      # AGSBUFF+1,+2
                1DNADR          AGSBUFF         +3      # AGSBUFF+3,+4
                1DNADR          AGSBUFF         +5      # AGSBUFF+5,+6
                1DNADR          AGSBUFF         +13D    # AGSBUFF+13D, GARBAGE
                1DNADR          AGSBUFF         +6      # AGSBUFF+6,+7
                1DNADR          AGSBUFF         +8D     # AGSBUFF+8D,+9D
                1DNADR          AGSBUFF         +10D    # AGSBUFF+10D,+11D
                1DNADR          AGSBUFF         +12D    # AGSBUFF+12,GARBAGE
                -1DNADR         AGSBUFF                 # AGSBUFF+0,+1

LMAGSI02        6DNADR          DNTMBUFF                # SEND SNAPSHOT
                -5DNADR         DNTMBUFF        +12D

LMAGSI03        -1DNADR         RN              +2      # RN +2,+3                 SNAPSHOT
                1DNADR          RN              +4      # RN +4,+5
                1DNADR          VN                      # VN,+1
                1DNADR          VN              +2      # VN +2,+3
                1DNADR          VN              +4      # VN +4,+5
                1DNADR          PIPTIME                 # PIPTIME,+1
                1DNADR          ACCSET                  # GARBAGE,CDUXD
                1DNADR          CDUYD                   # CDUYD,CDUZD
                1DNADR          OMEGAP                  # OMEGAP,OMEGAQ
                1DNADR          OMEGAR                  # OMEGAR,GARBAGE
                1DNADR          SPARE
                -1DNADR         RN                      # RN,+1

LMAGSI04        6DNADR          COMPNUMB                # COMPNUMB,UPOLDMOD,UPVERB,UPCOUNT,
                                                        # UPBUFF+0...+7            COMMON DATA
                -6DNADR         UPBUFF          +8D     # UPBUFF +8D...+19D

LMAGSI05        1DNADR          MASS                    # MASS,+1                  COMMON DATA
                1DNADR          RSBBQ                   # RSBBQ,+1
                2DNADR          CDUS                    # CDUS,PIPAX,PIPAY,PIPAZ
                2DNADR          CDUX                    # CDUX,CDUY,CDUZ,CDUT
                5DNADR          STATE                   # STATE+0...+9D (FLAGWORDS)
                -6DNADR         DSPTAB                  # DSPTAB TABLES

LMAGSI06        3DNADR          CADRFLSH                # CADRFLSH,+1,+2,FAILREG,+1,+2
                2DNADR          CDUX                    # CDUX,CDUY,CDUZ,CDUT
                1DNADR          IMODES30                # IMODES30,IMODES33
                DNCHAN          11                      # CHANNELS11,12
                DNCHAN          13                      # CHANNELS13,14
                DNCHAN          30                      # CHANNELS30,31
                DNCHAN          32                      # CHANNELS32,33
                -6DNADR         DSPTAB                  # DSPTAB TABLES

#     ---------------------------------------------------------

# LM COAST AND ALIGNMENT DOWNLIST

#     -----------------  CONTROL LIST  --------------------------

LMCSTADL        EQUALS                                  # SEND ID BY SPECIAL CODING
                DNPTR           LMCSTA01                # COLLECT SNAPSHOT
                DNPTR           LMCSTA02                # SEND SNAPSHOT
                2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT
                1DNADR          TEVENT                  # TEVENT,+1
                1DNADR          DNRRANGE                # DNRRANGE,DNRRDOT
                6DNADR          REFSMMAT                # REFSMMAT+0...+11D
                6DNADR          STARAD                  # STARAD+0...+11D
                3DNADR          STARAD          +12D    # STARAD+12D...+17D
                1DNADR          AGSK                    # AGSK,+1
                DNPTR           LMCSTA05                # COMMON DATA
                1DNADR          TIME2                   # TIME2/1
                DNPTR           LMCSTA03                # COLLECT SNAPSHOT
                DNPTR           LMCSTA02                # SEND SNAPSHOT
                2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT
                3DNADR          OGC                     # OGC,+1,IGC,+1,MGC,+1
                3DNADR          STAR                    # STAR+0...+5
                2DNADR          REDOCTR                 # REDOCTR,THETAD,+1,+2
                1DNADR          SPARE
                1DNADR          SPARE
                1DNADR          BESTI                   # BESTI,BESTJ
                6DNADR          STARSAV1                # STARSAV1+0...+5, STARSAV2+0...+5
                1DNADR          RADMODES                # RADMODES,DAPBOOLS
                1DNADR          SUMRATEQ                # SUMRATEQ,SUMRATER
                -DNPTR          LMCSTA06                # COMMON DATA

#     -----------------  SUB-LISTS   ----------------------------

LMCSTA01        -1DNADR         R-OTHER         +2      # R-OTHER+2,+3             SNAPSHOT
                1DNADR          R-OTHER         +4      # R-OTHER+4,+5
                1DNADR          V-OTHER                 # V-OTHER,+1
                1DNADR          V-OTHER         +2      # V-OTHER+2,+3
                1DNADR          V-OTHER         +4      # V-OTHER+4,+5
                1DNADR          T-OTHER                 # T-OTHER,+1
                1DNADR          ACCSET                  # GARBAGE,CDUXD
                1DNADR          CDUYD                   # CDUYD,CDUZD
                1DNADR          OMEGAP                  # OMEGAP,OMEGAQ
                1DNADR          OMEGAR                  # OMEGAR,GARBAGE
                1DNADR          LASTYCMD                # LASTYCMD,LASTXCMD
                -1DNADR         R-OTHER                 # R-OTHER+0,+1

LMCSTA02        EQUALS          LMAGSI02                # COMMON DOWNLIST DATA

LMCSTA03        -1DNADR         RN              +2      # RN +2,+3                 SNAPSHOT
                1DNADR          RN              +4      # RN +4,+5
                1DNADR          VN                      # VN,+1
                1DNADR          VN              +2      # VN +2,+3
                1DNADR          VN              +4      # VN +4,+5
                1DNADR          PIPTIME                 # PIPTIME,+1
                1DNADR          ACCSET                  # GARBAGE,CDUXD
                1DNADR          CDUYD                   # CDUYD,CDUZD
                1DNADR          OMEGAP                  # OMEGAP,OMEGAQ
                1DNADR          OMEGAR                  # OMEGAR,GARBAGE
                1DNADR          LASTYCMD                # LASTYCMD,LASTXCMD
                -1DNADR         RN                      # RN,+1

LMCSTA05        EQUALS          LMAGSI05                # COMMON DOWNLIST DATA

LMCSTA06        EQUALS          LMAGSI06                # COMMON DOWNLIST DATA

#     ---------------------------------------------------------

# LM POWERED DOWNLIST

#     -----------------  CONTROL LIST  --------------------------

LMPWRDDL        EQUALS                                  # SEND ID BY SPECIAL CODING
                DNPTR           LMPWRD01                # COLLECT SNAPSHOT
                DNPTR           LMPWRD02                # SEND SNAPSHOT
                2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT
                1DNADR          TEVENT                  # TEVENT,+1
                1DNADR          DNRRANGE                # DNRRANGE,DNRRDOT
                6DNADR          REFSMMAT                # REFSMMAT+0...+11D
                3DNADR          GDT/2                   # GDT/2+0...+5
                2DNADR          REDOCTR                 # REDOCTR,THETAD,+1,+2
                2DNADR          OMEGAPD                 # OMEGAPD,OMEGAQD,OMEGARD,GARBAGE
                3DNADR          VRPREV                  # VRPREV+0...+5
                DNPTR           LMPWRD05                # COMMON DATA
                1DNADR          TIME2                   # TIME2/1
                DNPTR           LMPWRD03                # COLLECT SNAPSHOT
                DNPTR           LMPWRD02                # SEND SNAPSHOT
                2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT
                1DNADR          TIG                     # TIG,+1
                3DNADR          VGTIG                   # VGTIG+0...+5
                1DNADR          CENTANG                 # CENTANG,+1
                1DNADR          PIPTIME1                # PIPTIME,+1
                3DNADR          DELV                    # DELV+0...+5
                1DNADR          TGO                     # TGO,+1
                1DNADR          PIF                     # PIF,+1
                1DNADR          TTPI                    # TTPI,+1
                3DNADR          DELVEET3                # DELVEET3+0...+5
                1DNADR          ELEV                    # ELEV,+1
                1DNADR          TPASS4                  # TPASS4,+1
                1DNADR          RADMODES                # RADMODES,DAPBOOLS
                1DNADR          ALPHAQ                  # ALPHAQ,ALPHAR
                -DNPTR          LMPWRD06                # COMMON DATA

#     -----------------  SUB-LISTS  ----------------------------

LMPWRD01        EQUALS          LMCSTA01                # COMMON DOWNLIST DATA

LMPWRD02        EQUALS          LMAGSI02                # COMMON DOWNLIST DATA

LMPWRD03        EQUALS          LMCSTA03                # COMMON DOWNLIST DATA

LMPWRD05        EQUALS          LMAGSI05                # COMMON DOWNLIST DATA

LMPWRD06        EQUALS          LMAGSI06                # COMMON DOWNLIST DATA


#     -----------------------------------------------------------

# LM RENDEZVOUS AND PRE-THRUST DOWNLIST
#
#     -----------------  CONTROL LIST   --------------------------

LMRENDDL        EQUALS                                  # SEND ID BY SPECIAL CODING
                DNPTR           LMREND01                # COLLECT SNAPSHOT
                DNPTR           LMREND02                # SEND SNAPSHOT
                2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT
                1DNADR          SPARE
                1DNADR          DNRRANGE                # DNRRANGE,DNRRDOT
                2DNADR          AIG                     # AIG,AMG,AOG,TRKMKCNT
                1DNADR          TANGNB                  # TANGNB,+1
                2DNADR          MKTIME                  # MKTIME,+1,RM,+1
                1DNADR          RDOTM                   # RDOTM,+1
                2DNADR          X789                    # X789+0..+3
                1DNADR          TCSI                    # TCSI,+1
                3DNADR          DELVEET1                # DELVEET+0-..+5
                1DNADR          SPARE
                1DNADR          SPARE
                2DNADR          REDOCTR                 # REDOCTR,THETAD,+1,+2
                DNPTR           LMREND05                # COMMON DATA
                1DNADR          TIME2                   # TIME2/1
                DNPTR           LMREND03                # COLLECT SNAPSHOT
                DNPTR           LMREND02                # SEND SNAPSHOT
                2DNADR          DNLRVELX                # DNLRVELX,DNLRVELY,DNLRVELZ,DNLRALT
                1DNADR          TIG                     # TIG,+1
                3DNADR          DELVSLV                 # DELVSLV+0...+5
                1DNADR          CENTANG                 # CENTANG,+1
                1DNADR          TCDH                    # TCDH,+1
                3DNADR          DELVEET2                # DELVEET2+0...+5
                1DNADR          DIFFALT                 # DIFFALT,+1
                1DNADR          NN                      # NN,+1
                1DNADR          TTPI                    # TTPI,+1
                3DNADR          DELVEET3                # DELVEET3+0...+5
                1DNADR          ELEV                    # ELEV,+1
                1DNADR          TPASS4                  # TPASS4,+1
                1DNADR          RADMODES                # RADMODES,DAPBOOLS
                1DNADR          SUMRATEQ                # SUMRATEQ,SUMRATER
                -DNPTR          LMREND06                # COMMON DATA

#     -----------------  SUB-LISTS   ----------------------------

LMREND01        EQUALS          LMCSTA01                # COMMON DOWNLIST DATA

LMREND02        EQUALS          LMAGSI02                # COMMON DOWNLIST DATA

LMREND03        EQUALS          LMCSTA03                # COMMON DOWNLIST DATA

LMREND05        EQUALS          LMAGSI05                # COMMON DOWNLIST DATA

LMREND06        EQUALS          LMAGSI06                # COMMON DOWNLIST DATA

#     ---------------------------------------------------------

DNTABLE         GENADR          LMCSTADL                # LM COAST AND ALIGN DOWNLIST
                GENADR          LMAGSIDL                # LM AGS INITIALIZATION/UPDATE DOWNLIST
                GENADR          LMRENDDL                # LM RENDEZVOUS AND PRE-THRUST DOWNLIST
                GENADR          LMPWRDDL                # LM POWERED DOWNLIST

#     ---------------------------------------------------------------


