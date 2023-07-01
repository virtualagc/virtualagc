### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RADAR_TEST_PROGRAMS.agc
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


                SETLOC  ENDRMODS
                EBANK=  RSTKLOC

# RADAR SAMPLING LOOP.

RADSAMP         CCS     RSAMPDT         # TIMES NORMAL ONCE-PER-SECOND SAMPLING.
                TCF     +2

                TCF     TASKOVER        # +0 INSERTED MANUALLY TERMINATES TEST.

                TC      WAITLIST
                2CADR   RADSAMP

                CAF     PRIO25
                TC      NOVAC
                2CADR   DORSAMP

                CAF     1/6             # FOR CYCLIC SAMPLING, RTSTDEX =
                EXTEND                  # RTSTLOC/6 + RTSTBASE.
                MP      RTSTLOC
                AD      RTSTBASE        # 0 FOR RR, 2 FOR LR.
                TS      RTSTDEX

                TCF     TASKOVER

# DO THE ACTUAL RADAR SAMPLE.

DORSAMP         TC      VARADAR         # SELECTS VARIABLE RADAR CHANNEL.
                TC      BANKCALL
                CADR    RADSTALL
                INCR    RFAILCNT        # ADVANCE FAIL COUNTER BUT ACCEPT BAD DATA

DORSAMP2        INHINT                  # YES - UPDATE TM BUFFER.
                DXCH    SAMPLSUM
                INDEX   RSTKLOC
                DXCH    RSTACK

                DXCH    OPTYHOLD
                INDEX   RSTKLOC
                DXCH    RSTACK +2

                DXCH    TIMEHOLD
                INDEX   RSTKLOC
                DXCH    RSTACK +4

                CS      RTSTLOC         # CYCLE RTSTLOC.
                AD      RTSTMAX
                EXTEND
                BZF     +3
                CA      RSTKLOC
                AD      SIX
                TS      RSTKLOC

                CCS     RSAMPDT         # SEE IF TIME TO RE-SAMPLE.
                TCF     ENDOFJOB        # NO - WAIT FOR T3 (REGULAR SAMPLING).

                TCF     ENDOFJOB        # TEST TERMINATED.
                TCF     DORSAMP         # JUMP RIGHT BACK AND GET ANOTHER SAMPLE.

1/6             DEC     .17

# VARIABLE RADAR DATA CALLER FOR ONE MEASUREMENT ONLY.

VARADAR         CAF     ONE             # WILL BE SENT TO RADAR ROUTINE IN A BY
                TS      BUF2            # SWCALL.
                INDEX   RTSTDEX
                CAF     RDRLOCS
                TCF     SWCALL          # NOT TOUCHING Q.

RDRLOCS         CADR    RRRANGE         # =0
                CADR    RRRDOT          # =1
                CADR    LRVELX          # =2
                CADR    LRVELY          # =3
                CADR    LRVELZ          # =4
                CADR    LRALT           # =5


## MAS 2023: The following chunks of code (down to ENDRTSTS) were added as patches
## between Aurora 85 and Aurora 88. They were placed here at the end of the bank
## so as to not change addresses of existing symbols.

LRPSNXT1        TS      SAMPLIM
                TC      FIXDELAY        # SCAN ONCE PER SECOND 15 TIMES MAX AFTER
                DEC     100             # INITIAL DELAY OF 7 SECONDS.

                CAF     BIT7
                EXTEND
                RAND    33
                TC      LRPOSNXT +1

LASTLRDT        TC      FIXDELAY        # WAIT ONE SECOND AFTER RECEIPT OF INBIT
                DEC     100             # TO WAIT FOR ANTENNA BOUNCE TO DIE OUT.

                CS      BIT13           # REMOVE COMMAND
                EXTEND
                WAND    12
                TCF     RGOODEND

LRPOSCAN        CAF     BIT5            # SET UP FOR 15 SAMPLES.
                TCF     LRPOSNXT

6SECS           DEC     600

ENDRTSTS        EQUALS
