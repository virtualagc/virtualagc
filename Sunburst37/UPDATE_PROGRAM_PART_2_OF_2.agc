### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    UPDATE_PROGRAM_PART_2_OF_2.agc
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
## Reference:   pp. 305-310
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-05-30 HG   Transcribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 305
                BANK            26
                EBANK=          STBUFF
UPPART2         CA              UPE4
                TS              EBANK
                TC              CHECKMM
                OCT             27
                TC              +2
                TC              21XCTALM

                CA              ONE
                TS              STCOUNT
                TC              GRABWAIT
                CA              MPAC
                TS              UPVERB
                CA              MODREG
                TS              UPOLDMOD
                TC              NEWMODEX
                OCT             27
                CS              UPVERB
                AD              21OCT75
                EXTEND
                BZF             +4
                CA              MPAC            +1
                TS              COMPNUMB
                TC              UPIN            +1
UPNO33          CA              ONE                     # CONTINUE V75
                AD              ASTBFM1
                TS              MPAC            +2
                CA              STATENV                 # FLASH V21 N01
                TC              UPNVCALL                # LOAD V33 OR OCTAL NO.
                TC              UPNO33                  # V33, IGNORE
                CA              FOUR                    # OCTAL NO. IN STBUFF

                TS              UPTEMP
                CA              STBUFF
                TC              UPRANGE                 # IS STBUFF GE 1 AND LE 4
                TC              UPNO33                  #  NO, TRY AGAIN
                INDEX           STBUFF                  #  YES
                CA              AOFC            -1
                TS              COMPNUMB
                CA              TWO
UPIN            TS              STCOUNT
                CA              ASTBFM1
                AD              STCOUNT
                TS              MPAC            +2
                CA              STATENV
                TC              UPNVCALL
                TC              UPIN            +1      # V33 , IGNORE
                CS              STCOUNT                 # OCTAL NO.
                AD              COMPNUMB
                EXTEND
                BZF             +3

## Page 306
                INCR            STCOUNT
                TC              UPIN            +1
UPHERE          CA              UPAOFTP1
                TS              MPAC            +2
                CA              OCTID
                TC              UPNVCALL
                TC              UPSTORE                 # V33, VERIFY
                CA              COMPNUMB                # OCTAL IDENTIFIER
                TS              UPTEMP
                CA              UPTEMP1
                TC              UPRANGE
                TC              UPHERE                  # BAD OCTAL IDENTIFIER
                CA              UPTEMP1
                AD              ASTBFM1

                TC              UPIN            +3
UPSTORE         TC              FREEDSP
                INHINT
                CS              FLAGWRD2                # INVERT VERIFLAG FOR GROUND VERIFY
                MASK            BIT6
                TS              Q
                CS              BIT6
                MASK            FLAGWRD2
                AD              Q
                TS              FLAGWRD2
                TC              CHECKMM
                OCT             27
                TC              UPRETURN
                CA              UPOLDMOD                # RESTORE PRE-P27 MODE
                TC              NEWMODEX        +3
UPRETURN        CA              BIT5
                MASK            FLAGWRD2
                EXTEND
                BZF             21XCTALM
                CS              21OCT64                 #   BEGIN STORING DATA FROM STBUFF
                AD              UPVERB                  # YES, CONTINUE
                INDEX           A
                TC              +1

                DXCH            STBUFF          +1
                DXCH            UPGET
                TC              UPEND64
                TC              UPEND67                 # V67
                TC              UPEND70                 # V70
                TC              UPEND71                 # V71
                TC              UPEND72                 # V72
                TC              UPEND73
21OCT64         OCT             00064
                TC              UPEND75                 # V75
UPEND76         CS              FLAGWRD2                # IS ORBITAL INTEGRATION ON
                MASK            BIT7
                EXTEND

## Page 307
                BZF             SETUPRCK                # YES, SET UP 3SEC CALL TO CHECK AGAIN
                EXTEND                                  # V76
                DCA             STBUFF                  # NO, BEGIN LOAD OF UPDATE PARAMETERS
                DXCH            REFRRECT
                EXTEND
                DCA             STBUFF
                DXCH            REFRCV
                EXTEND
                DCA             STBUFF          +2
                DXCH            REFRRECT        +2
                EXTEND
                DCA             STBUFF          +2
                DXCH            REFRCV          +2
                EXTEND
                DCA             STBUFF          +4
                DXCH            REFRRECT        +4
                EXTEND
                DCA             STBUFF          +4
                DXCH            REFRCV          +4

                EXTEND
                DCA             STBUFF          +6
                DXCH            REFVRECT
                EXTEND
                DCA             STBUFF          +6
                DXCH            REFVCV
                EXTEND
                DCA             STBUFF          +8D
                DXCH            REFVRECT        +2
                EXTEND
                DCA             STBUFF          +8D
                DXCH            REFVCV          +2
                EXTEND
                DCA             STBUFF          +10D
                DXCH            REFVRECT        +4
                EXTEND
                DCA             STBUFF          +10D
                DXCH            REFVCV          +4
                EXTEND
                DCA             STBUFF          +12D
                DXCH            TE
                CA              ZERO
                TS              DELTAV

                TS              DELTAV          +1
                TS              DELTAV          +2
                TS              DELTAV          +3
                TS              DELTAV          +4
                TS              DELTAV          +5
                TS              NUV
                TS              NUV             +1
                TS              NUV             +2

## Page 308
                TS              NUV             +3
                TS              NUV             +4

                TS              NUV             +5
                TS              REFTC
                TS              REFTC           +1
                TS              REFXKEP
                TS              REFXKEP         +1
                TC              UPQUIT
SETUPRCK        CA              3SEC21
                TC              WAITLIST
                EBANK=          STBUFF
                2CADR           UPDOAGN

                TC              ENDOFJOB
UPDOAGN         CA              PRIO27
                TC              NOVAC
                EBANK=          STBUFF
                2CADR           UPINHINT
                TC              TASKOVER
UPINHINT        INHINT
                TC              UPRETURN
UPEND64         CA              STBUFF
                TS              UPINDEX
                CA              PRIO27

                TC              FINDVAC
                EBANK=          STBUFF
                2CADR           MGETUP

                TC              UPQUIT
UPEND67         CA              STBUFF
                TS              UPINDEX
                TC              POSTJUMP
                CADR            DOV67
UPEND70         CA              STBUFF
                TS              UPINDEX
                CA              STBUFF          +1
                TS              UPDT
                TC              POSTJUMP
                CADR            DOV70
UPEND71         CA              STBUFF
                TS              UPINDEX
                CA              STBUFF          +1
                TS              UPPHASE
                TC              POSTJUMP
                CADR            DOV71
UPEND72         CA              STBUFF
                TS              UPINDEX

                CA              STBUFF          +1
                TS              UPPHASE

## Page 309
                CA              STBUFF          +2
                TS              UPDT
                TC              POSTJUMP
                CADR            DOV72
UPEND73         CA              STBUFF
                TS              UPINDEX
                TC              POSTJUMP
                CADR            DOV73

UPEND75         CS              BIT2                    # V75
                AD              COMPNUMB
                INDEX           A
                TC
I=1             EXTEND
                DCA             STBUFF          +1
                DXCH            RP
                TC              UPQUIT
                TC              I=2
21OCT75         OCT             75
                TC              I=4
STATENV         OCT             2101
I=3             EXTEND
                DCA             STBUFF          +1
                DXCH            R1VEC
                EXTEND
                DCA             STBUFF          +3
                DXCH            R1VEC           +2
                EXTEND
                DCA             STBUFF          +5
                DXCH            R1VEC           +4
                EXTEND
                DCA             STBUFF          +7

                DXCH            TINT
                EXTEND
                DCA             STBUFF          +9D
                DXCH            RCO
                TC              UPQUIT
I=2             EXTEND
                DCA             STBUFF          +1
                DXCH            CPT6/2
                EXTEND
                DCA             STBUFF          +3
                DXCH            CPT6/2          +2
                EXTEND
                DCA             STBUFF          +5
                DXCH            CPT6/2          +4
                TC              UPQUIT
I=4             EXTEND
                DCA             STBUFF          +1
                DXCH            R1VEC
                EXTEND

## Page 310
                DCA             STBUFF          +3
                DXCH            R1VEC           +2
                EXTEND
                DCA             STBUFF          +5
                DXCH            R1VEC           +4
                EXTEND
                DCA             STBUFF          +7
                DXCH            TINT
                TC              FREEDSP
                TC              CHECKMM
                OCT             27
                TC              +3
                CA              UPOLDMOD
                TC              NEWMODEX        +3

UPQUIT          TC              BANKCALL                # TERMINATES JOB
                CADR            ENDUP
UPNVCALL        EXTEND
                QXCH            UPTEMP
                TC              NVSBWAIT
                TC              ENDIDLE
                TC              UPQUIT          -6
                TC              UPTEMP                  # V33 RETURN TO Q
                INCR            UPTEMP                  #     RETURN TO Q+1
                TC              UPTEMP
UPRANGE         EXTEND
                BZMF            UPRAUS                  # C(A) LE ZERO RETURN TO Q
                CS              A
                INCR            A
                AD              UPTEMP
                EXTEND
                BZMF            UPRAUS                  # C(A) GT C(LOC) RETURN TO Q
                INCR            Q
UPRAUS          TC              Q                       # C(A) LE C(LOC) AND GT 0 RETURN TO Q+1
21XCTALM        TC              BANKCALL
                CADR            XACTALM

UPE4            OCT             2000

OCTID           OCT             02102
AOFC            OCT             00003
                OCT             00007
                OCT             00013
                OCT             00011
UPAOFTP1        ECADR           UPTEMP1
ASTBFM1         ECADR           STBUFF          -1
3SEC21          DEC             300
