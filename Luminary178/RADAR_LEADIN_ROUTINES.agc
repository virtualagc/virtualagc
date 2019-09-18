### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RADAR_LEADIN_ROUTINES.agc
## Purpose:     A section of Luminary revision 178.
##              It is part of the reconstructed source code for the final
##              release of the flight software for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 14. The
##              code has been recreated from copies of Zerlina 56, Luminary
##              210, and Luminary 131, as well as many Luminary memos.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 178 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 498-499
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-14 MAS  Created from Zerlina 56.
##              2019-09-05 MAS  Changed an ADRES to a CADR to restore
##                              a bug present in Luminary 178.

## Page 498
                BANK            15
                SETLOC          RRLEADIN
                BANK

                EBANK=          RSTACK

# RADAR SAMPLING LOOP.

                COUNT*          $$/RLEAD
RADSAMP         CCS             RSAMPDT                 # TIMES NORMAL ONCE-PER-SECOND SAMPLING.
                TCF             +2
                TCF             TASKOVER                # +0 INSERTED MANUALLY TERMINATES TEST.

                TC              TWIDDLE
                CADR            RADSAMP
                CAF             PRIO25
                TC              NOVAC
                EBANK=          RSTACK
                2CADR           DORSAMP

                CAF             BIT14                   # FOR CYCLIC SAMPLING, RTSTDEX=
                EXTEND                                  # RTSTLOC/2 + RTSTBASE
                MP              RTSTLOC
                AD              RTSTBASE                # 0 FOR RR, 2 FOR LR.
                TS              RTSTDEX
                TCF             TASKOVER

                BANK            25
                SETLOC          DRSAMP
                BANK

                EBANK=          RSTACK
# DO THE ACTUAL RADAR SAMPLE.

DORSAMP         TC              VARADAR                 # SELECTS VARIABLE RADAR CHANNEL.
                TC              BANKCALL
                CADR            RADSTALL

                INCR            RFAILCNT                # ADVANCE FAIL COUNTER BUT ACCEPT BAD DATA

DORSAMP2        INHINT
                CA              FLAGWRD5                # DON'T UPDATE RSTACK IF IN R77.
                MASK            R77FLBIT
                CCS             A
                TCF             R77IN

                DXCH            SAMPLSUM
                INDEX           RTSTLOC
                DXCH            RSTACK

## Page 499
                CA              RADMODES
                EXTEND
                RXOR            CHAN33
                MASK            BIT6
                EXTEND
                BZF             R77IN

                TC              ALARM
                OCT             522
                INCR            RFAILCNT

R77IN           CS              RTSTLOC                 # CYCLE RTSTLOC
                AD              RTSTMAX
                EXTEND
                BZF             +3
                CA              RTSTLOC
                AD              TWO                     # STORAGE IS DP
                TS              RTSTLOC
                TCF             ENDOFJOB                # CONTINUOUS SAMPLING AND 2N TRIES - GONE.

# VARIABLE RADAR DATA CALLER FOR ONE MEASUREMENT ONLY.

VARADAR         CAF             ONE                     # WILL BE SENT TO RADAR ROUTINE IN A BY
                TS              BUF2                    # SWCALL.
                INDEX           RTSTDEX
                CAF             RDRLOCS
                TCF             SWCALL                  # NOT TOUCHING Q.

RDRLOCS         CADR            RRRANGE                 # = 0
                CADR            RRRDOT                  # = 1
                CADR            LRVELX                  # = 2
                CADR            LRVELY                  # = 3
                CADR            LRVELZ                  # = 4
                CADR            LRALT                   # = 5
