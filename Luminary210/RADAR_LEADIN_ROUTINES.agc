### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    RADAR_LEADIN_ROUTINES.agc
## Purpose:     A section of Luminary revision 210.
##              It is part of the source code for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 15-17.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 505-506
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-11-17 JL   Created from Luminary131 version.
##              2016-11-27 HG   Transcribed
##		2016-12-25 RSB	Comment-text proofed using ProoferComments
##				and corrected errors found.

## Page 505
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
                ADRES           RADSAMP
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

## Page 506
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
