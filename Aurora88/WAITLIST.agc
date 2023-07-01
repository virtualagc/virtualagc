### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    WAITLIST.agc
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


# GROUNDRULE....DELTA T SHOULD NOT EXCEED 12000 (= 2 MINUTES)

                SETLOC  ENDEXECF

                EBANK=  LST1            # TASK LISTS IN SWITCHED E BANK.

WAITLIST        XCH     Q               # SAVE DELTA T IN Q AND RETURN IN
                TS      WAITEXIT        # WAITEXIT.
                EXTEND
                INDEX   A
                DCA     0               # PICK UP 2CADR OF TASK.
                TS      WAITADR         # BBCON WILL REMAIN IN L.
DLY2            CAF     WAITBB          # ENTRY FROM FIXDELAY AND VARDELAY.
                XCH     BBANK
                TCF     WAIT2

# RETURN TO CALLER AFTER TASK INSERTION:

LVWTLIST        CA      WAITBANK
                TS      BBANK
                INDEX   WAITEXIT
                TC      2

WAITBB          BBCON   WAIT2

# RETURN TO CALLER +2 AFTER WAITING DT SPECIFIED AT CALLER +1.

FIXDELAY        INDEX   Q               # BOTH ROUTINES MUST BE CALLED UNDER
                CAF     0               # WAITLIST CONTROL AND TERMINATE THE TASK
                INCR    Q               # IN WHICH THEY WERE CALLED.

# RETURN TO CALLER +1 AFTER WAITING THE DT AS ARRIVING IN A.

VARDELAY        XCH     Q               # DT TO Q.  TASK ADRES TO WAITADR.
                TS      WAITADR
                CA      BBANK           # BBANK IS SAVED DURING DELAY.
                TS      L
                CAF     DELAYEX
                TS      WAITEXIT        # GO TO TASKOVER AFTER TASK ENTRY.
                TCF     DLY2

DELAYEX         TCF     TASKOVER -2     # RETURNS TO TASKOVER


# ENDTASK MUST BE ENTERED IN FIXED-FIXED SO IT IS DISTINGUISHABLE BY ITS ADRES ALONE.

ENDTASK         -2CADR  SVCT3

SVCT3           TCF     TASKOVER


# BEGIN TASK INSERTION.

                SETLOC  ENDEXECS

WAIT2           TS      WAITBANK        # BBANK OF CALLING PROGRAM.
                CS      TIME3
                AD      +1              # CCS  A  = + 1/4
                CCS     A               # TEST  1/4 - C(TIME3).  IF POSITIVE,
                                        # IT MEANS THAT TIME3 OVERFLOW HAS OCCURRED PRIOR TO CS  TIME3 AND THAT
                                        # C(TIME3) = T - T1, INSTEAD OF 1.0 - (T1 - T).  THE FOLLOWING FOUR
                                        # ORDERS SET C(A) = TD - T1 + 1 IN EITHER CASE.

                AD      OCT40001        # OVERFLOW HAS OCCURRED.  SET C(A) =
                CS      A               # T - T1 + 3/4 - 1

# NORMAL CASE (C(A) MINUS) YIELDS SAME C(A)  -(-(1.0-(T1 - T))+1/4)-1

                AD      OCT50001
                AD      Q               # RESULT = TD - T1 + 1.

                CCS     A               # TEST TD - T1 + 1

                AD      LST1            # IF TD - T1 POS, GO TO WTLST5 WITH
                TCF     WTLST5          # C(A) = (TD - T1) + C(LST1) = TD-T2+1

                NOOP
                CS      Q

# NOTE THAT THIS PROGRAM SECTION IS NEVER ENTERED WHEN T-T1 G/E -1,
# SINCE TD-T1+1 = (TD-T) + (T-T1+1), AND DELTA T = TD-T G/E +1 .  (G/E
# SYMBOL MEANS GREATER THAN OR EQUAL TO).  THUS THERE NEED BE NO CON-
# CERN OVER A PREVIOUS OR IMMINENT OVERFLOW OF TIME3 HERE.

                AD      POS1/2          # WHEN TD IS NEXT, FORM QUANTITY
                AD      POS1/2          #   1.0 - DELTA T = 1.0 - (TD - T)
                XCH     TIME3
                AD      NEGMAX
                AD      Q               # 1.0 - DELTAT T NOW COMPLETE.
                EXTEND                  # ZERO INDEX Q.
                QXCH    7               # (ZQ)


WTLST4          XCH     LST1
                XCH     LST1    +1
                XCH     LST1    +2
                XCH     LST1    +3
                XCH     LST1    +4
                XCH     LST1    +5
                XCH     LST1    +6
                XCH     LST1    +7

                CA      WAITADR         # (MINOR PART OF TASK CADR HAS BEEN IN L.)
                INDEX   Q
                TCF     +1

                DXCH    LST2
                DXCH    LST2    +2
                DXCH    LST2    +4
                DXCH    LST2    +6
                DXCH    LST2    +8D
                DXCH    LST2    +10D    # AT END, CHECK THAT C(LST2 +10) IS STD
                DXCH    LST2    +12D
                DXCH    LST2    +14D
                DXCH    LST2    +16D
                AD      ENDTASK         #   END ITEM, AS CHECK FOR EXCEEDING
                                        #   THE LENGTH OF THE LIST.
                EXTEND                  # DUMMY TASK ADRES SHOULD BE IN FIXED-
                BZF     LVWTLIST        # FIXED SO ITS ADRES ALONE DISTINGUISHES
                TCF     WTABORT         # IT.


WTLST5          CCS     A               # TEST TD - T2 + 1
                AD      LST1    +1
                TCF     +4
                AD      ONE
                TC      WTLST2
                OCT     1

 +4             CCS     A               # TEST TD - T3 + 1
                AD      LST1    +2
                TCF     +4
                AD      ONE
                TC      WTLST2
                OCT     2

 +4             CCS     A               # TEST TD - T4 + 1
                AD      LST1    +3
                TCF     +4
                AD      ONE
                TC      WTLST2
                OCT     3

 +4             CCS     A               # TEST TD - T5 + 1
                AD      LST1    +4
                TCF     +4
                AD      ONE
                TC      WTLST2
                OCT     4

 +4             CCS     A               # TEST TD - T6 + 1
                AD      LST1    +5
                TCF     +4
                AD      ONE
                TC      WTLST2
                OCT     5

 +4             CCS     A               # TEST TD - T7 + 1
                AD      LST1    +6
                TCF     +4
                AD      ONE
                TC      WTLST2
                OCT     6


 +4             CCS     A
                AD      LST1    +7
                TCF     +4
                AD      ONE
                TC      WTLST2
                OCT     7

 +4             CCS     A
WTABORT         TC      ABORT           # NO ROOM IN THE INN.
                OCT     1203

                AD      ONE
                TC      WTLST2
                OCT     10

OCT50001        OCT     50001


# THE ENTRY TO WTLST2 JUST PRECEDING OCT  N  IS FOR T  LE TD LE T   -1.
#                                                    N           N+1
#
# (LE MEANS LESS THAN OR EQUAL TO).  AT ENTRY, C(A) = -(TD - T   + 1)
#                                                             N+1
#
# THE LST1 ENTRY -(T   - T +1) IS TO BE REPLACED BY -(TD - T  + 1), AND
#                   N+1   N                                 N
#
# THE ENTRY -(T   - TD + 1) IS TO BE INSERTED IMMEDIATELY FOLLOWING.
#              N+1

WTLST2          TS      WAITTEMP        #     C(A) = -(TD - T   + 1)
                INDEX   Q
                CAF     0
                TS      Q               # INDEX VALUE INTO Q.

                CAF     ONE
                AD      WAITTEMP
                INDEX   Q               # C(A) = -(TD - T ) + 1.
                ADS     LST1    -1      #                N

                CS      WAITTEMP
                INDEX   Q
                TCF     WTLST4

# C(TIME3)  = 1.0 - (T1 - T)
#
# C(LST1  ) = - (T2 - T1) + 1
# C(LST1+1) = - (T3 - T2) + 1
# C(LST1+2) = - (T4 - T3) + 1
# C(LST1+3) = - (T5 - T4) + 1
# C(LST1+4) = - (T6 - T5) + 1
#
# C(LST2   ) = 2CADR  TASK1
# C(LST2+2 ) = 2CADR  TASK2
# C(LST2+4 ) = 2CADR  TASK3
# C(LST2+6 ) = 2CADR  TASK4
# C(LST2+8 ) = 2CADR  TASK5
# C(LST2+10) = 2CADR  TASK6


# ENTERS HERE ON T3 RUPT TO DISPATCH WAITLISTED TASK.

T3RUPT          TS      BANKRUPT
                EXTEND
                QXCH    QRUPT

T3RUPT2         CAF     NEG1/2          # DISPATCH WAITLIST TASK.
                XCH     LST1    +7
                XCH     LST1    +6
                XCH     LST1    +5
                XCH     LST1    +4      # 1.  MOVE UP LST1 CONTENTS, ENTERING
                XCH     LST1    +3      #     A VALUE OF 1/2 +1 AT THE BOTTOM
                XCH     LST1    +2      #     FOR T6-T5, CORRESPONDING TO THE
                XCH     LST1    +1      #     INTERVAL 81.91 SEC FOR ENDTASK.
                XCH     LST1
                AD      POSMAX          # 2. SET T3 = 1.0 - T2 -T USING LIST 1.
                ADS     TIME3           # SO T3 WONT TICK DURING UPDATE.
                TS      RUPTAGN
                CS      ZERO
                TS      RUPTAGN         # SETS RUPTAGN TO +1 ON OVERFLOW.

                EXTEND                  # DISPATCH TASK.
                DCS     ENDTASK
                DXCH    LST2    +16D
                DXCH    LST2    +14D
                DXCH    LST2    +12D
                DXCH    LST2    +10D
                DXCH    LST2    +8D
                DXCH    LST2    +6
                DXCH    LST2    +4
                DXCH    LST2    +2
                DXCH    LST2

                DTCB

ENDWAITS        EQUALS


# RETURN, AFTER EXECUTION OF T3 OVERFLOW TASK:

                BLOCK   02

TASKOVER        CCS     RUPTAGN         # IF +1 RETURN TO T3RUPT, IF -0 RESUME.
                CAF     WAITBB
                TS      BBANK
                TCF     T3RUPT2         # DISPATCH NEXT TASK IF IT WAS DUE.

RESUME          EXTEND
                QXCH    QRUPT
NOQRSM          CA      BANKRUPT
                TS      BBANK
NOQBRSM         DXCH    ARUPT
                RESUME

ENDWAITF        EQUALS                  # LAST FIXED-FIXED LOCATION OF T3RUPT.
