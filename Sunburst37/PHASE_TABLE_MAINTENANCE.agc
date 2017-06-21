### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PHASE_TABLE_MAINTENANCE.agc
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
## Reference:   pp. 67-77
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-29 HG   Transcribed
##		2017-06-21 RSB	Proofed using octopus/ProoferComments.

## Page 67
#          SUBROUTINE TO UPDATE THE PROGRAM NUMBER DISPLAY ON THE DSKY.

                BLOCK           02
NEWMODEX        INDEX           Q                       # UPDATE MODREG.
                CAF             0
                INCR            Q
                XCH             MODREG
                COM                                     # IF NO CHANGE IN MODE, RETURN IMMEDIATELY
                AD              MODREG
                EXTEND
                BZF             TCQ

                CAF             +3                      # CALL PINBALL SUBROUTINE
PREBJUMP        LXCH            BBANK                   # PUTS BBANK IN L

                TCF             BANKJUMP                # PUTS Q INTO A
                CADR            SETUPDSP

#          RETURN TO CALLER +3 IF MODE = THAT AT CALLER +1. OTHERWISE RETURN TO CALLER +2.

CHECKMM         INDEX           Q
                CS              0
                AD              MODREG
                EXTEND
                BZF             Q+2
                TCF             Q+1                     # NO MATCH

TCQ             =               Q+2             +1

                BANK            35

SETUPDSP        INHINT
                DXCH            RUPTREG1                # SAVE CALLER-S RETURN 2CADR
                CAF             PRIO30                  #   EITHER A TASK OR JOB CAN COME TO
                TC              NOVAC                   #   NEWMODEX
                EBANK=          MODREG
                2CADR           DSPMMJOB

                DXCH            RUPTREG1
                RELINT
                DXCH            Z                       # RETURN

DSPMMJOB        TC              BANKCALL
                CADR            DSPMM1
                TCF             ENDOFJOB

                BLOCK           02

## Page 68

# PHASCHNG IS THE MAIN WAY OF MAKING PHASE CHANGES FOR RESTARTS.  THERE ARE THREE FORMS OF PHASCHNG, KNOWN AS TYPE
# A, TYPE B, AND TYPE C. THEY ARE ALL CALLED AS FOLLOWS, WHERE OCT XXXXX   CONTAINS THE PHASE INFORMATION,

#                                                  TC     PHASCHNG
#                                                  OCT    XXXXX

# TYPE A IS CONCERNED WITH FIXED PHASE CHANGES, THAT IS, PHASE INFORMATIONTHAT IS STORED PERMANENTLY.  THESE
# OPTIONS ARE, WHERE G STANDS FOR A GROUP AND .X FOR THE PHASE.

#                 G.0             INACTIVE, WILLNOT PERMIT A GROUP G RESTART
#                 G.1             WILL CAUSE THE LAST DISPLAY TO BE REACTIVATED, USED MAINLY IN MANNED FLIGHTS
#                 G.EVEN          A DOUBLE TABLE RESTART, CAN CAUSE ANY COMBINATION OF TWO JOBS, TASKS, AND/OR
#                                 LONGCALL TO BE RESTARTED.
#                 G.ODD NOT .1    A SINGLE TABLE RESTART, CAN CAUSE EITHER A JOB, TASK, OR LONGCALL RESTART

# THIS INFORMATION IS PUT INTO THE OCTAL WORD AFTER TC PHASCHNG AS FOLLOWS

#                 TL0 00P PPP PPP GGG                                               ,

# WHERE EACH LETTER OR NUMBER STANDS FOR A BIT.  THE G:S STAND FOR THE GROUP, OCTAL 1 - 7, THE P:S FOR THE PHASE,
# OCTAL 0 - 127.  0:S MUST BE 0.              IF ONE WISHES TO HAVE THE TBASE OF GROUP G TO BE SET AT THIS TIME,
# T IS SET TO 1, OTHERWISE IT IS SET TO 0.  SIMIARLY IF ONE WISHES TO SET LONGBASE, THEN L IS SET TO 1, OTHERWISE
# IT IS SET TO 0.  SOME EXAMPLES,

#                                                  TC     PHASCHNG        THIS WILL CAUSE GROUP 3 TO BE SET TO 0,
#                                                  OCT    00003           MAKING GROUP 3 INACTIVE

#                                                  TC     PHASCHNG        IF A RESTART OCCURS THIS WOULD CAUSE
#                                                  OCT    00012           GROUP 2 TO RESTART THE LAST DISPLAY

#                                                  TC     PHASCHNG        THIS SETS THE TBASE OF GROUP 4 AND IN
#                                                  OCT    40064           CASE OF A RESTART WOULD START UP THE TWO
#                                                                         THINGS LOCATED IN THE DOUBLE 4.6 RESTART
#                                                                         LOCATION
#                                                  TC     PHASCHNG        THIS SETS LONGBASE AND UPON A RESTART
#                                                  OCT    20135           CAUSES 5.13 TO BE RESTARTED  (SINCE
#                                                                         LONGBASE WAS SET THIS SINGLE ENTRY
#                                                                         SHOULD BE A LONGCALL)
#                                                  TC     PHASCHNG        SINCE BOTH TBASE4 AND LONGBASE ARE SET,
#                                                  OCT    60124           4.12 SHOULD CONTAIN BOTH A TASK AND A
#                                                                         LONGCALL TO BE RESTARTED
#
# TYPE C PHASCHNG CONTAINS THE VARIABLE TYPE OF PHASCHNG INFORMATION. INSTEAD OF THE INFORMATION BEING IN A

# PERMANENT FORM, ONE STORES THE DESIRED RESTART INFORMATION IN A VARIABKE LOCATION. THE BITS ARE AS FOLLOWS,

#                 TL0 1AD XXX CJW GGG

# WHERE EACH LETTER OR NUMBER STANDS FOR A BIT.  THE G:S STAND FOR THE GROUP, OCTAL 1 - 7.  IF THE RESTART IS TO
# BE BY WAITLIST, W IS SET TO 1, IF IT IS A JOB, J IS SET TO 1, IF IT IS A LONGCALL, C IS SET TO 1. ONLY ONE OF
# THESE THREE BIT S MAY BE SET.  X:S ARE IGNORED  1 MUST BE 1, AND 0 MUST  BE 0.  AGAIN T STANDS FOR THE TBASE,

## Page 69
# AND L FOR LONGBASE.  THE BITS A AND D ARE CONCERNED WITH THE VARIABLE INFORMATION. IF D IS SET TO 1, A PRIORITY
# OR DELTA TIME WILL BE READ FROM THE NEXT LOCATION AFTER THE OCTAL INFORMATION, IF THIS IS TO BE INDIRECT, THAT

# IS, THE NAME OF A LOCATION CONTAINING THE INFORMATION (DELTA TIME ONLY), THEN THIS IS GIVEN AS THE -GENADR OF
# THAT LOCATION WHICH CONTAINS THE DELTA TIME.  IF THE OLD PRIORITY OR DELTA TIME IS TO BE USED, THAT WHICH IS
# ALREADY IN THE VARIABLE STORAGE, THEN D IS SET TO 0. NEXT THE A BIT IS USED.  IF IT IS SET TO 0, THE ADDRESS
# THAT WOULD BE RESTARTED DURING A RESTART IS THE NEXT LOCATION AFTER THE  PHASE INFORMATION, THAT IS, EITHER
# (TC PHASCHNG) +2 OR +3, DEPENDING ON WHETHER D HAD BEEN SET OR NOT.  IF A IS SET TO 1, THEN THE ADDRESS THAT
# WOULD BE RESTARTED IS THE 2CADR THAT IS READ FROM THE NEXT TWO LOCATIONS.  EXAMPLES,

#                                         AD       TC     PHASCHNG        THIS WOULD CAUSE LOCATION AD +3 TO BE
#                                         AD+1     OCT    05023           RESTARTED BY GROUP THREE WITHA PRIORITY
#                                         AD+2     OCT    23000           OF 23.  NOTE UPON RETURNING IT WOULD
#                                         AD+3                            ALSO GO TO AD+3

#                                         AD       TC     PHASCHNG        GROUP  1 WOULD CAUSE CAUSE CALLCALL TO
#                                         AD+1     OCT    27441           BE STARTED AS A LONGCALL FROM THE TIME
#                                         AD+2    -GENADR DELTIME         STORED IN LONGBASE (LONGBASE WAS SET) BY
#                                         AD+3     2CADR  CALLCALL        A DELTATIME STORED IN DELTIME.  THE
#                                         AD+4                            BBCON OF THE 2CADR SHOULD CONTAIN THE E
#                                         AD+5                            BANK OF DELTIME. PHASCHNG RETURNS TO
#                                                                         LOCATION AD+5

# TYPE B PHASCHNG IS A COMBINATION OF VARIABLE AND FIXED PHASE CHANGES. IT WILL START UP A JOB AS INDICATED
# BELOW AND ALSO START UP ONE FIXED RESTART, THAT IS EITHER AN G.1 OR  A G.ODD OR THE FIRST ENTRY OF G.EVEN
# DOUBLE ENTRY.  THE BIT INFORMATION IS AS FOLLOWS,

#                 TL1 DAP PPP PPP GGG

# WHERE EACH LETTER OR NUMBER STANDS FOR A BIT.  THE G:S STAND FOR THE GROUP, OCTAL 1 - 7, THE P:S FOR THE FIXED
# PHASE INFORMATION, OCTAL 0 - 127. 1 MUST BE 1.  AND AGAIN T STANDS FOR THE TBASE AND L FOR LONGBASE. D THIS
# TIME STANDS ONLY FOR PRIORITY SINCE THIS WILL BE CONSIDERED A JOB, AND IT MUST BE GIVEN DIRECTLY IF GIVEN.
# AGAIN A STANDS FOR THE ADDRESS OF THE LOCATION TO BE RESTARTED, 1 IF THE 2CADR IS GIVEN , OR 0 IF IT IS TO BE
# THE NEXT LOCATION.(THE RETURN LOCATION OF PHASCHNG) EXAMPLES,

#                                         AD       TC     PHASCHNG        TBASE IS SET AND ARESTART CAUSE GROUP 3
#                                         AD+1     OCT    56043           TO START THE JOB AJOBAJOB WITH PRIORITY

#                                         AD+2     OCT    31000           31 AND THE FIRST ENTRY OF 3.4SPOT(WE CAN
#                                         AD+3     2CADR  AJOBAJOB        ASSUME IT IS A TASK SINCE WE SET TBASE3)
#                                         AD+4                            UPON RETURN FROM PHASCHNG CONTROL WOULD
#                                         AD+5                            GO TO AD+5

#                                         AD       TC     PHASCHNG        UPON A RESTART THE LAST DISPLAY WOULD BE
#                                         AD+1     OCT    10015           RESTARTED AND A JOB WITH THE PREVIOUSLY
#                                         AD+2                            STORED PRIORITY WOULD BE BEGUN AT AD+2
#                                                                         BY MEANS OF GROUP 5

# SUMMARY OF BITS

# TYPE A          TL0 00P PPP PPP GGG

## Page 70
# TYPE B          TL1 DAP PPP PPP GGG

# TYPE C          TL0 1AD XXX CJW GGG

## Page 71
# 2PHSCHNG IS USED WHEN ONE WISHES TO START UP A GROUP OR CHANGE A GROUP WHILE UNDER THE CONTROL OF A DIFFERENT
# GROUP. FOR EXAMPLE, CHANGE THE PHASE OF GROUP 3 WHILE THE PORTION OF THE PROGRAM IS UNDER GROUP 5. ALL 2PHSCHNG
# CALLS ARE MADE IN THE FOLLOWING MANNER,

#                                                  TC     2PHSCHNG
#                                                  OCT    XXXXX
#                                                  OCT    YYYYY

# WHERE OCT XXXXX MUST BE OF TYPE A AND OCT YYYYY MAY BE OF EITHER TYPE A OR TYPE B OR TYPEC.  THERE IS ONE
# DIFFERENCE --- NOTE- IF LONGBASE IS TO BE SET THIS INFORMATION IS GIVEN IN THE OCT YYYYY INFORMATION, IT WILL
# BE DISREGARDED IF GIVEN WITH THE OCT XXXXX INFORMATION. A COUPLE OF EXAMPLES MAY HELP,

#                                         AD       TC     2PHSCHNG        SET TBASE3 AND IF A RESTART OCCURS START
#                                         AD+1     OCT    40083           THE TWO ENTRIES IN 3.8 TABLE LOCATION

#                                         AD+2     OCT    05025           THIS IS OF TYPE C, SET THE JOB TO BE
#                                         AD+3     OCT    18000           TO BE LOCATION AD+4, WITH A PRIORITY 18,
#                                         AD+4                            FOR GROUP 5 PHASE INFORMATION

2PHSCHNG        INHINT                                  # THE ENTRY FOR A DOUBLE PHASE CHANGE
                NDX             Q
                CA              0
                INCR            Q
                TS              TEMPP2

                MASK            OCT7
                DOUBLE
                TS              TEMPG2

                CA              TEMPP2
                MASK            OCT17770                # NEED ONLY 1770, BUT WHY GET A NEW CONST.
                EXTEND
                MP              BIT12
                XCH             TEMPP2

                MASK            BIT15
                TS              TEMPSW2                 # INDICATES WHETHER TO SET TBASE OR NOT

                TCF             PHASCHNG        +3


PHASCHNG        INHINT
                CA              ONE                     # INDICATESWE CAME FROM A PHASCHNG ENTRY
                TS              TEMPSW2

                NDX             Q
                CA              0
                INCR            Q
                TS              TEMPSW

                EXTEND

## Page 72
                DCA             ADRPCHN2                # OFF TO SWITCHED BANK
                DTCB

                EBANK=          LST1
ADRPCHN2        2CADR           PHSCHNG2

ONEORTWO        LXCH            TEMPBBCN
                LXCH            BBANK
                LXCH            TEMPBBCN

                MASK            OCT14000                # SEE WHAT KIND OF PHASE CHANGE IT IS
                CCS             A
                TCF             CHECKB                  #  IT IS OF TYPE :B:

                CA              TEMPP
                MASK            BIT7
                CCS             A                       #  SHALL WE USE THE OLD PRIORITY
                TCF             GETPRIO                 #  NO GET A NEW PRIORITY (OR DELTA T)

OLDPRIO         NDX             TEMPG                   #  USE THE OLD PRIORITY (OR DELTA T)
                CA              PHSPRDT1        -2
                TS              TEMPPR

CON1            CA              TEMPP                   # SEE IF A 2CADR IS GIVEN
                MASK            BIT8
                CCS             A
                TCF             GETNEWNM

                CA              Q
                TS              TEMPNM
                CA              BB
                TS              TEMPBB

TOCON2          CA              CON2ADR                 # BACK TO SWITCHED BANK
                LXCH            TEMPBBCN
                DTCB

CON2ADR         GENADR          CON2

GETPRIO         NDX             Q                       # DON:T CARE IF DIRECT OR INDIRECT
                CA              0                       # LEAVE THAT DECISION TO RESTARTS
                INCR            Q                       # OBTAIN RETURN ADDRESS

                TCF             CON1            -1

GETNEWNM        EXTEND
                INDEX           Q
                DCA             0
                DXCH            TEMPNM
                CA              TWO

## Page 73
                ADS             Q                       # OBTAIN RETURN ADDRESS

                TCF             TOCON2

OCT17770        OCT             17770
OCT14000        EQUALS          PRIO14
OCT7            EQUALS          SEVEN
TEMPG           EQUALS          ITEMP1
TEMPP           EQUALS          ITEMP2
TEMPNM          EQUALS          ITEMP3
TEMPBB          EQUALS          ITEMP4
TEMPSW          EQUALS          ITEMP5
TEMPSW2         EQUALS          ITEMP6
TEMPPR          EQUALS          RUPTREG1
TEMPG2          EQUALS          RUPTREG2
TEMPP2          EQUALS          RUPTREG3

TEMPBBCN        EQUALS          RUPTREG4
BB              EQUALS          BBANK



                BANK            06

                EBANK=          PHSNAME1
PHSCHNG2        LXCH            TEMPBBCN

                CA              TEMPSW
                MASK            OCT7
                DOUBLE
                TS              TEMPG

                CA              TEMPSW
                MASK            OCT17770
                EXTEND
                MP              BIT12
                TS              TEMPP

                CA              TEMPSW
                MASK            OCT60000
                XCH             TEMPSW
                MASK            OCT14000
                CCS             A

                TCF             ONEORTWO

                CA              TEMPP                   # START STORING THE PHASE INFORMATION
                NDX             TEMPG
                TS              PHASE1          -2

BELOW1          CCS             TEMPSW2                 # IS IT A PHASCHNG OR A 2PHSCHNG

## Page 74
                TCF             BELOW2                  # IT:S A PHASCHNG

                TCF             +1                      # IT:S A 2PHSCHNG
                CS              TEMPP2
                LXCH            TEMPP2
                NDX             TEMPG2
                DXCH            -PHASE1         -2

                CCS             TEMPSW2
                NOOP                                    # CAN:T GET HERE
                TCF             BELOW2

                CS              TIME1
                NDX             TEMPG2
                TS              TBASE1          -2

BELOW2          CCS             TEMPSW                  # SEE IF WE SHOULD SET TBASE OR LONGBASE
                TCF             BELOW3                  # SET LONGBASE ONLY
                TCF             BELOW4                  # SET NEITHER

                CS              TIME1                   # SET TBASE TO BEGIN WITH
                NDX             TEMPG
                TS              TBASE1          -2

                CA              TEMPSW                  #  SHALL WE NOW SET LONGBASE
                AD              BIT14COM
                CCS             A
OCT60000        OCT             60000                   # ***** CANT GET HERE *****
BIT14COM        OCT             17777                   # ***** CANT GET HERE *****
                TCF             BELOW4                  # NO WE NEED ONLY SET TBASE

BELOW3          EXTEND                                  # SET LONGBASE

                DCA             TIME2
                DXCH            LONGBASE

BELOW4          CS              TEMPP                   # AND STORE THE FINAL PART OF THE PHASE
                NDX             TEMPG
                TS              -PHASE1         -2

                CA              Q
                LXCH            TEMPBBCN
                RELINT
                DTCB
CON2            LXCH            TEMPBBCN

                CA              TEMPP
                NDX             TEMPG
                TS              PHASE1          -2

                CA              TEMPPR

## Page 75
                NDX             TEMPG
                TS              PHSPRDT1        -2

                EXTEND
                DCA             TEMPNM
                NDX             TEMPG
                DXCH            PHSNAME1        -2

                TCF             BELOW1

                BLOCK           02
CHECKB          MASK            BIT12                   # SINCE THIS IS OF TYPE B, THIS BIT SHOULD
                CCS             A                       #  BE HERE IF WE ARE TO GET A NEW PRIORITY
                TCF             GETPRIO                 # IT IS, SO GET NEW PRIORITY

                TCF             OLDPRIO                 # IT ISN:T, USE THE OLD PRIORITY

## Page 76
# PROGRAM DESCRIPTION: NEWPHASE                                           DATE: 11 NOV 1966
# MOD: 1                                                                  ASSEMBLY: SUNBURST REV
# MOD BY: COPPS                                                           LOG SECTION: PHASE TABLE MAINTENANCE
# FUNCTIONAL DESCRIPTION:
#               NEWPHASE IS THE QUICK WAY TO MAKE A NON VARIABLE PHASE CHANGE. IT INCLUDES THE OPTION OF SETTING
#          TBASE OF THE GROUP. IF TBASE IS TO BE SET,  -C(TIME1) IS STORED IN THE TBASE TABLE AS FOLLOWS:

#                 (L-1) TBASE0
#                 (L)   TBASE1 (IF GROUP=1)
#                 (L+1)
#                 (L+2) TBASE2 (IF GROUP=2)
#                 -----
#                 (L+6) TBASE4 (IF GROUP=4)
#                 (L+7)
#                 (L+8) TBASE5 (IF GROUP=5)

#          IN ANY CASE, THE NEGATIVE OF THE PHASE, FOLLOWED (IN THE NEXT REGISTER)  BY THE PHASE, IS STORED IN THE
#          PHASE TABLE AS FOLLOWS:

#                 (L)   -PHASE1 (IF GROUP=1)

#                 (L+1) PHASE1
#                 (L+2) -PHASE2 (IF GROUP=2)
#                 (L+3) PHASE2
#                 -----
#                 (L+7) PHASE 4
#                 (L+8) -PHASE5 (IF GROUP=5)
#                 (L+9) PHASE5

# CALLING SEQUENCE:
#               EXAMPLE IS FOR PLACING A PHASE OF FIVE INTO GROUP THREE:

#          1) IF TBASE IS NOT TO BE SET:
#                                         L-1      CA     FIVE
#                                         L        TC     NEWPHASE
#                                         L+1      OCT    00003

#          2) IF TBASE IS TO BE SET:
#                                         L-1      CS     FIVE
#                                         L        TC     NEWPHASE
#                                         L+1      OCT    00003

# SUBROUTINES CALLED: NONE

# NORMAL EXIT MODE: AT L+2 OF CALLING SEQUENCE

# ALARM OR ABORT EXITS: NONE

# OUTPUT: PHASE TABLE AND TBASE TABLE UPDATED

# ERASABLE INITIALIZATION REQ,D: NONE

## Page 77
# DEBRIS: A,L,TEMPG

# ***WARNING*** THIS PROGRAM IS TO BE PLACED IN FIXED-FIXED AND UNSWITCHED ERASABLE.

                BLOCK           02
NEWPHASE        INHINT

                TS              L                       # SAVE FOR FURTHER USE

                NDX             Q                       # OBTAIN THE GROUP NUMBER
                CA              0
                INCR            Q                       # OBTAIN THE RETURN ADDRESS
                DOUBLE                                  # SAVE THE GROUP IN A FORM USED FOR
                TS              TEMPG                   # INDEXING

                CCS             L                       # SEE IF WE ARE TO SET TBASE
                TCF             +7                      # NO, THE DELTA T WAS POSITIVE
                TCF             +6

                INCR            A                       # SET TBASE AND STORE PHASE CORRECTLY
                TS              L

                CS              TIME1                   # SET TBASE
                NDX             TEMPG
                TS              TBASE1          -2

                CS              L                       # NOW PUT THE PHASE IN THE RIGHT TABLE LOC
                NDX             TEMPG
                DXCH            -PHASE1         -2

                RELINT
                TC              Q                       # NOW RETURN TO CALLER

NUFAZ+10        INCR            A                       # SET TBASE AND STORE BASE CORRECTLY
