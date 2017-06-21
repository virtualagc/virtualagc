### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RESTART_TABLES_AND_RESTARTS_ROUTINE.agc
## Purpose:     A section of Sunburst revision 37, or Shepatin revision 0.
##              It is part of an early development version of the software
##              for Apollo Guidance Computer (AGC) on the unmanned Lunar
##              Module (LM) flight Apollo 5. Sunburst 37 was the program
##              upon which Don Eyles's offline development program Shepatin
##              was based; the listing herein transcribed was actually for
##              the equivalent revision 0 of Shepatin.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 56-66
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-28 HG   Transcribed
##              2017-06-15 HG   Fix operator CS  -> CA
##              2017-06-15 HG   Fix operator -2CADR -> 2CADR      
##		2017-06-21 RSB	Proofed using octopus/ProoferComments.

## Page 56
# RESTART TABLES
#  DO NOT REMOVE FROM THE BEGINNING OF THIS BANK
# ------------------

# THERE ARE TWO FORMS OF RESTART TABLES FOR EACH GROUP.  THEY ARE KNOWN AS THE EVEN RESTART TABLES AND THE ODD
# RESTART TABLES.  THE ODD TABLES HAVE ONLY ONE ENTRY OF THREE LOCATIONS WHILE THE EVEN TABLES HAVE TWO ENTRIES
# EACH USING THREE LOCATIONS. THE INFORMATION AS TO WHETHER IT IS A JOB, WAITLIST, OR A LONGCALL IS GIVEN BY THE
# WAY THINGS ARE PUT INTO THE TABLES.
#      A JOB HAS ITS PRIORITY STORED IN PRDTTAB OF THE CORRECT PHASE SPOT WITH ITS 2CADR IN THE CADRTAB. FOR
# EXAMPLE,

#                                         5.7SPOT  OCT    23000
#                                                  2CADR  SOMEJOB

# A RESTART OF GROUP 5 WITH PHASE SEVEN WOULD THEN CAUSE SOMEJOB TO BE RESTARTED WITH A PRIORITY OF 23.

# A LONGCALL HAS ITS GENADR OF ITS 2CADR STORED NEGATIVELY AND ITS BBCON STORED POSITIVELY.  IN ITS PRDTTAB IS
# PLACED THE LOCATION OF A DP REGISTER THAT CONTAINS THE DELTA TIME THAT LONGCALL HAD BEEN ORIGINALLY STARTED
# WITH.  EXAMPLE,

#                                         3.6SPOT  GENADR DELTAT
#                                                 -GENADR LONGTASK
#                                                  BBCON  LONGTASK

#                                                  OCT    31000
#                                                  2CADR  JOBAGAIN

# THIS WOULD START UP LONGTASK AT THE APPROPRIATE TIME, OR IMMEDIATELY IF THE TIME HAD ALREADY PASSED. IT SHOULD
# BE NOTED THAT IF DELTAT IS IN A SWITCHED E BANK, THIS INFORMATOIN SHOULD BE IN THE BBCON OFTHE 2CADR OF THE
# TASK.  FROM ABOVE, WE SEE THAT THE SECOND PART OF THIS PHASE WOULD BE STARTED AS A JOB WITH A PRIORITY OF 31.

# WAITLIST CALLS ARE IDENTIFIED BY THE FACT THAT THEIR 2CADR IS STORED NEGATIVELY. IF PRDTTAB OF THE PHASE SPOT
# IS POSITIVE, THEN IT CONTAINS THE DELTA TIME, IF PRDTTAB IS NEGATIVE THEN IT IS THE -GENADR OF AN ERASABLE
# LOCATION CONTAINING THE DELTA TIME, THAT IS, THE TIME IS STORED INDIRECTLY.  IT SHOULD BE NOTED AS ABOVE, THAT
# IF THE TIME IS STORED INDIRECTLY, THE BBCON MUST CONTAIN THE NECESSARY E BANK INFORMATION IF APPLICABLE.  WITH
# WAITLIST WE HAVE ONE FURTHER OPTION, IF -0 IS STORED IN PRDTTAB, IT WILL CAUSE AN IMMEDIATE RESTART OF THE
# TASK.  EXAMPLES,

#                                                  OCT    77777           THIS WILL CAUSE AN IMMEDIATE RESTART
#                                                 -2CADR  ATASK           OF THE TASK :ATASK:

#                                                  DEC    200             IF THE TIME OF THE 2 SECONDS SINCE DUMMY
#                                                 -2CADR  DUMMY           WAS PUT ON WAITLIST IS UP, IT WILL BEGIN
#                                                                         IN 10 MS, OTHERWISE IT WILL BEGIN WHEN

#                                                                         IT NORMALLY WOULD HAVE BEGUN.

#                                                 -GENADR DTIME           WHERE DTIME CONTAINS THE DELTA TIME
#                                                 -2CADR  TASKTASK        OTHERWISE THIS IS AS ABOVE

# *****    NOW THE TABLES THEMSELVES *****

## Page 57

PRDTTAB         EQUALS          24000                   # USED TO FIND THE PRIORITY OR DELTA TIME
CADRTAB         EQUALS          24001                   # THIS AND THE NEXT LOCATION (RELATIVE)

                                                        #     CONTAIN THE RESTART CADR

                BANK            06

                EBANK=          LST1                    # GOPROG MUST SWITCH IN THIS EBANK

PHS2CADR        GENADR          PHSPART2                # DO NOT REMOVE THE FOLLOWING 6 LOCATIONS
PRT2CADR        GENADR          GETPART2                #     FROM BEGINNING OF BANK
LGCLCADR        GENADR          LONGCALL
FVACCADR        GENADR          FINDVAC
WTLTCADR        GENADR          WAITLIST
RTRNCADR        TC              SWRETURN

1.2SPOT         OCT             10000                   # TEMPORARY ENTRY TO ESTABLISH TABLE
                EBANK=          LST1
                2CADR           DUMMYJOB

                OCT             10000
                EBANK=          LST1
                2CADR           DUMMYJOB
# ANY MORE GROUP 1.EVEN RESTART VALUES SHOULD GO HERE

1.3SPOT         EQUALS          1.2SPOT

# ANY MORE GROUP 1.ODD RESTART VALUES SHOULD GO HERE

2.2SPOT         EQUALS          1.2SPOT

# ANY MORE GROUP 2.EVEN RESTART VALUES SHOULD GO HERE

2.3SPOT         OCT             77777                   # MISSION SCHEDULING PACKAGE TO SET UP
                EBANK=          LST1
               -2CADR           REDOMDUE

2.5SPOT         DEC             5500
                EBANK=          TDEC
               -2CADR           SIVB2

2.7SPOT         OCT             77777
                EBANK=          TDEC
               -2CADR           SBORBA

2.11SPOT        DEC             400
                EBANK=          TDEC
               -2CADR           SBORB8

# ANY MORE GROUP 2.0DD RESTART VALUES SHOULD GO HERE

## Page 58
3.2SPOT         EQUALS          1.2SPOT
# ANY MORE GROUP 3.EVEN RESTART VALUES SHOULD GO HERE

3.3SPOT         EQUALS          1.2SPOT
# ANY MORE GROUP 3.0DD RESTART VALUES SHOULD GO HERE

4.2SPOT         EQUALS          1.2SPOT

# ANY MORE GROUP 4.EVEN RESTART VALUES SHOULD GO HERE

4.3SPOT         EQUALS          1.2SPOT
# ANY MORE GROUP 4.0DD RESTART VALUES SHOULD GO HERE

5.2SPOT         OCT             21000
                EBANK=          RAVEGON
                2CADR           NORMLIZE

                DEC             200
                EBANK=          DVCNTR
               -2CADR           REREADAC

5.4SPOT         DEC             200
                EBANK=          BMEMORY
               -2CADR           PREREAD

                OCT             32000
                EBANK=          LST1
                2CADR           LASTBIAS

5.6SPOT         DEC             200
                EBANK=          DVCNTR
               -2CADR           REREADAC

                OCT             20000
                EBANK=          DVCNTR
                2CADR           SERVICER
# ANY MORE GROUP 5.EVEN RESTART VALUES SHOULD GO HERE

5.3SPOT         DEC             200
                EBANK=          DVCNTR
               -2CADR           REREADAC

5.5SPOT         OCT             77777                   # REPLACES INACTIVE 5.0 FOR FAKESTRT
                EBANK=          MTIMER4                 # * * * REMOVE IF RESTARTS RETURN * * *
               -2CADR           POOH2

5.7SPOT         OCT             20000
                EBANK=          XSM
                2CADR           RSTGTS1

## Page 59
5.11SPOT        OCT             77777
                EBANK=          XSM
               -2CADR           ALLOOP1

5.13SPOT        OCT             20000
                EBANK=          XSM
                2CADR           WTLISTNT

5.15SPOT        OCT             20000
                EBANK=          XSM
                2CADR           RESTEST1

5.17SPOT        OCT             20000
                EBANK=          XSM

                2CADR           GEOSTRT4

5.21SPOT        OCT             20000
                EBANK=          XSM
                2CADR           ALFLT1

5.23SPOT        OCT             77777
                EBANK=          XSM
               -2CADR           SPECSTS

5.25SPOT        OCT             20000
                EBANK=          XSM
                2CADR           RESTEST3

5.27SPOT        OCT             20000
                EBANK=          XSM
                2CADR           RESTAIER

5.31SPOT        OCT             77777
                EBANK=          XSM
               -2CADR           PIPSTRTS
# ANY MORE GROUP 5.ODD RESTART VALUES SHOULD GO HERE

6.2SPOT         EQUALS          1.2SPOT
# ANY MORE GROUP 6.EVEN RESTART VALUES SHOULD GO HERE

6.3SPOT         EQUALS          1.2SPOT
# ANY MORE GROUP 6.0DD RESTART VALUES SHOULD GO HERE

SIZETAB         GENADR          1.2SPOT         -24006
                GENADR          1.3SPOT         -24004
                GENADR          2.2SPOT         -24006
                GENADR          2.3SPOT         -24004
                GENADR          3.2SPOT         -24006
                GENADR          3.3SPOT         -24004

## Page 60
                GENADR          4.2SPOT         -24006
                GENADR          4.3SPOT         -24004
                GENADR          5.2SPOT         -24006
                GENADR          5.3SPOT         -24004
                GENADR          6.2SPOT         -24006
                GENADR          6.3SPOT         -24004

## Page 61
RESTARTS        CA              MPAC            +5      # GET GROUP NUMBER -1

                DOUBLE                                  # SAVE FOR INDEXING
                TS              TEMP2G

                CA              FVACCADR                # LET:S ASSUME THIS IS A JOB, THIS WILL
                TS              GOLOC           -1      # SAVE US A COUPLE OF LOCATIONS, BUT NOT
                                                        # NECESSARIALY ANY TIME  - SO BE IT -

                CA              PHS2CADR                # SET UP EXIT IN CASE IT IS AN EVEN
                TS              TEMPSWCH                # TABLE PHASE

                CA              RTRNCADR                # TO SAVE TIME ASSUME IT WILL GET NEXT
                TS              GOLOC           +2      # GROUP AFTER THIS

                CA              TEMPPHS
                MASK            OCT1400
                CCS             A                       # IS IT A VARIABLE OR TABLE RESTART
                TCF             ITSAVAR                 # IT;S A VARIABLE RESTART

GETPART2        CCS             TEMPPHS                 # IS IT AN X.1 RESTART
                CCS             A
                TCF             ITSATBL                 # NO, ITS A TABLE RESTART

                CA              PRIO14                  # IT IS AN X.1 RESTART, THEREFORE START

                TC              FINDVAC                 # THE DISPLAY RESTART JOB
                EBANK=          LST1
                2CADR           INITDSP

                TC              RTRNCADR                # FINISHED WITH THIS GROUP, GET NEXT ONE

INITDSP         EQUALS          ENDOFJOB

ITSAVAR         MASK            BIT10                   # SEE IF IT IS TYPE B
                CCS             A
                TCF             ITSLIKEB                # YES,IT IS TYPE B

                EXTEND                                  # STORE THE JOB (OR TASK) 2CADR FOR EXIT
                NDX             TEMP2G
                DCA             PHSNAME1
                DXCH            GOLOC

                CA              TEMPPHS                 # SEE IF THIS IS A JOB, TASK, OR A LONGCAL
                MASK            OCT7
                AD              MINUS2
                CCS             A
                TCF             ITSLNGCL                # ITS A LONGCALL

OCT37776        OCT             37776                   # CANT GET HERE

## Page 62
                TCF             ITSAWAIT

                TCF             ITSAJOB                 # ITS A JOB

ITSAWAIT        CA              WTLTCADR                # SET UP WAITLIST CALL
                TS              GOLOC           -1

                NDX             TEMP2G                  # DIRECTLY STORED

                CA              PHSPRDT1
TIMETEST        CCS             A                       # IS IT AN IMMEDIATE RESTART
                INCR            A                       # NO.
                TCF             FINDTIME                # FIND OUT WHEN IT SHOULD BEGIN

                TCF             ITSINDIR                # STORED INDIRECTLY

                TCF             IMEDIATE                # IT WANTS AN IMMEDIATE RESTART

# ***** THIS MUST BE IN FIXED FIXED *****

                BLOCK           02
ITSINDIR        LXCH            GOLOC           +1      # GET THE CORRECT E BANK IN CASE THIS IS
                LXCH            BB                      # SWITCHED ERRASIBLE

                NDX             A                       # GET THE TIME INDIRECTLY
                CA              1

                LXCH            BB                      # RESTORE THE BB AND GOLOC
                LXCH            GOLOC           +1

                TCF             FINDTIME                # FIND OUT WHEN IT SHOULD BEGIN

# ***** YOUB MAY RETURN TO SWITCHED FIXED *****

                BANK            06
FINDTIME        COM                                     # MAKE NEGITIVE SINCE IT WILL BE SUBTRACTD
                TS              L                       # AND SAVE
                NDX             TEMP2G
                CS              TBASE1
                EXTEND
                SU              TIME1
                CCS             A
                COM
                AD              OCT37776
                AD              ONE
                AD              L
                CCS             A
                CA              ZERO
                TCF             +2
                TCF             +1
IMEDIATE        AD              ONE

## Page 63
                TC              GOLOC           -1
ITSLIKEB        CA              RTRNCADR                # TYPE B,             SO STORE RETURN IN
                TS              TEMPSWCH                # TEMPSWCH IN CASE OF AN EVEN PHASE

                CA              PRT2CADR                # SET UP EXIT TO GET TABLE PART OF THIS
                TS              GOLOC           +2      # VARIABLE TYPE OF PHASE

                CA              TEMPPHS                 # MAKE THE PHASE LOOK RIGHT FOR THE TABLE
                MASK            OCT177                  # PART OF THIS VARIABLE PHASE
                TS              TEMPPHS

                EXTEND
                NDX             TEMP2G                  # OBTAIN THE JOB:S 2CADR
                DCA             PHSNAME1

                DXCH            GOLOC

ITSAJOB         NDX             TEMP2G                  # NOW ADD THE PRIORITY AND LET:S GO
                CA              PHSPRDT1
                TC              GOLOC           -1

ITSATBL         TS              CYR                     # FIND OUT IF THE PHASE IS ODD OR EVEN
                CCS             CYR
                TCF             +1                      # IT:S EVEN
                TCF             ITSEVEN

                CA              RTRNCADR                # IN CASE THIS IS THE SECOND PART OF A
                TS              GOLOC           +2      # TYPE B RESTART, WE NEED PROPER EXIT

                CA              TEMPPHS                 # SET UP POINTER FOR FINDING OUR PLACE IN
                TS              SR                      # THE RESTART TABLES
                AD              SR
                NDX             TEMP2G
                AD              SIZETAB         +1
                TS              POINTER

CONTBL2         EXTEND                                  # FIND OUT WHAT:S IN THE TABLE
                NDX             POINTER

                DCA             CADRTAB                 # GET THE 2CADR

                LXCH            GOLOC           +1      # STORE THE BB INFORMATION

                CCS             A                       # IS IT A JOB OR IS IT TIMED
                INCR            A                       # POSITIVE, MUST BE A JOB
                TCF             ITSAJOB2

                INCR            A                       # MUST BE EITHER A WAITLIST OR LONGCALL
                TS              GOLOC                   # LET-S STORE THE CORRECT CADR

                CA              WTLTCADR                # SET UP OUR EXIT TO WAITLIST
                TS              GOLOC           -1

## Page 64
                CA              GOLOC           +1      # NOW FIND OUT IF IT IS A WAITLIST CALL
                MASK            BIT10                   # THIS SHOULD BE ONE IF WE HAVE -BB
                CCS             A                       # FOR THAT MATTER SO SHOULD BE BITS 9,8,7,
                                                        # 6,5, AND LAST BUT NOT LEAST (PERHAPS NOT
                                                        # IN IMPORTANCE ANYWAY. BIT 4
                TCF             ITSWTLST                # IT IS A WAITLIST CALL

                NDX             POINTER                 # OBTAIN THE ORIGINAL DELTA T
                CA              PRDTTAB                 # ADDRESS FOR THIS LONGCALL

                TCF             ITSLGCL1                # NOW GO GET THE DELTA TIME

# ***** THIS MUST BE IN FIXED FIXED *****

                BLOCK           02
ITSLGCL1        LXCH            GOLOC           +1      # OBTAIN THE CORRECT E BANK
                LXCH            BB
                LXCH            GOLOC           +1      # AND PRESERVE OUR E AND F BANKS

                EXTEND                                  # GET THE DELTA TIME
                NDX             A
                DCA             0

                LXCH            GOLOC           +1      # RESTORE OUR E AND F BANK
                LXCH            BB                      # RESTORE THE TASKS E AND F BANKS
                LXCH            GOLOC           +1      # AND PRESERVE OUR L

                TCF             ITSLGCL2                # NOW LET:S PROCESS THIS LONGCALL

# ***** YOUB MAY RETURN TO SWITCHED FIXED *****

                BANK            06
ITSLGCL2        DXCH            LONGTIME

                EXTEND                                  # CALCULATE TIME LEFT
                DCS             TIME2
                DAS             LONGTIME
                EXTEND
                DCA             LONGBASE
                DAS             LONGTIME

                CCS             LONGTIME                # FIND OUT HOW THIS SHOULD BE RESTARTED
                TCF             LONGCLCL

                TCF             +2
                TCF             IMEDIATE        -3
                CCS             LONGTIME        +1
                TCF             LONGCLCL
                NOOP                                    # CAN:T GET HERE    *********
                TCF             IMEDIATE        -3
                TCF             IMEDIATE

## Page 65
LONGCLCL        CA              LGCLCADR                # WE WILL GO TO LONGCALL
                TS              GOLOC           -1

                EXTEND                                  # PREPARE OUR ENTRY TO LONGCALL
                DCA             LONGTIME
                TC              GOLOC           -1

ITSLNGCL        CA              WTLTCADR                # ASSUME IT WILL GO TO WAITLIST
                TS              GOLOC           -1

                NDX             TEMP2G
                CA              PHSPRDT1                # GET THE DELTA T ADDRESS

                TCF             ITSLGCL1                # NOW GET THE DELTA TIME

ITSWTLST        CS              GOLOC           +1      # CORRECT THE BBCON INFORMATION
                TS              GOLOC           +1

                NDX             POINTER                 # GET THE DT AND FIND OUT IF IT WAS STORED
                CA              PRDTTAB                 # DIRECTLY OR INDIRECTLY

                TCF             TIMETEST                # FIND OUT HOW THE TIME IS STORED

ITSAJOB2        XCH             GOLOC                   # STORE THE CADR

                NDX             POINTER                 # ADD THE PRIORITY AND LET:S GO
                CA              PRDTTAB

                TC              GOLOC           -1

ITSEVEN         CA              TEMPSWCH                # SET UP FOR EITHER THE SECOND PART OF THE
                TS              GOLOC           +2      # TABLE, OR A RETURN FOR THE NEXT GROUP

                NDX             TEMP2G                  # SET UP POINTER FOR OUR LOCATION WITHIN
                CA              SIZETAB                 # THE TABLE
                AD              TEMPPHS                 # THIS MAY LOOK BAD BUT LET:S SEE YOU DO
                AD              TEMPPHS                 # BETTER IN TIME OR NUMBERR OF LOCATIONS

                AD              TEMPPHS
                TS              POINTER

                TCF             CONTBL2                 # NOW PROCESS WHAT IS IN THE TABLE

PHSPART2        CA              THREE                   # SET THE POINTER FOR THE SECOND HALF OF
                ADS             POINTER                 # THE TABLE

                CA              RTRNCADR                # THIS WILL BE OUR LAST TIME THROUGH THE
                TS              GOLOC           +2      # EVEN TABLE , SO AFTER IT  GET THE NEXT
                                                        # GROUP
                TCF             CONTBL2                 # SO LET:S GET THE SECOND ENTRY IN THE TBL

## Page 66
TEMPPHS         EQUALS          MPAC
TEMP2G          EQUALS          MPAC            +1
POINTER         EQUALS          MPAC            +2
TEMPSWCH        EQUALS          MPAC            +3
GOLOC           EQUALS          OVFIND
MINUS2          EQUALS          NEG2
OCT177          EQUALS          LOW7
