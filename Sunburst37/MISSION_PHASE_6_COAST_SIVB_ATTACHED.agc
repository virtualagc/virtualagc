### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MISSION_PHASE_6_COAST_SIVB_ATTACHED.agc
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
## Reference:   pp. 666-668
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-13 HG   Transcribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 666
# PROGRAM DESCRIPTION
#    COAST SIVB ATTACHED

# MOD NO   1      DATE - 4 NOV 66

# MOD BY - OVERBAUGH
# FUNCTIONAL DESCRIPTION
#    WHEN THE DV MONITOR DETECTS SIVB SHUTDOWN THE
#    THRUST MISSION CONTROL PROGRAM INITIATES MP6.
#    DURING THIS PHASE THE ABORT COMMAND MONITOR AND
#    THE TUMBLE MONITOR ARE TERMINATED AND THE C-BAND
#    XPONDER IS SET TO ON*.  WHEN THRUST DUE TO
#    VENTING BECOMES NEGLIGIBLE READING OF
#    THE PIPAS IS TERMINATED.

# NORMAL EXIT MODES -
#    TC   TASKOVER

# ERASABLE INITIALIZATION REQUIRED
#    MP6TO7

# OUTPUT
#    UPDATE MODREG
#    TERMINATE ABORT COMMAND MONITOR
#    TERMINATE TUMBLE MONITOR
#    MISSION SCHEDULING REGISTERS SET TO CALL MP7

# DEBRIS
#    CENTRALS,A,Q,Z

# SUBROUTINES CALLED
#    EXECUTIVE(ENDOFJOB)
#    WAITLIST
#    LONGCALL
#    NEWMODEX
#    1LMP
#    FLAG1DWN
#    FLAG2DWN
#    SCHEDULE ENTRY ROUTINE(MPENTRY)

                BANK            27
                EBANK=          MP6TO7

MP6JOB          TC              NEWMODEX                # UPDATE MODREG
                OCT             13

                CAF             SIX
                TS              PHASENUM

                TC              PHASCHNG
## Page 667
                OCT             47012
                DEC             6000
                EBANK=          MP6TO7
                2CADR           MP6A

                CAF             DEC6000                 # INITIALIZE 1 MIN DELAY
                INHINT
                TC              WAITLIST
                EBANK=          MP6TO7
                2CADR           MP6A

                RELINT
                TCF             ENDOFJOB
DEC6000         DEC             6000

MP6A            TC              PHASCHNG
                OCT             47012
                DEC             12000
                EBANK=          MP6TO7
                2CADR           MP6B


                CAF             DEC12000                # INITIALIZE 2 MIN WAIT
                TC              WAITLIST
                EBANK=          MP6TO7
                2CADR           MP6B
# REF   2 LAST 667     27,2514   56003 1  TERMINATE ABORT COMMAND MONITOR

                TC              FLAG2DWN
                OCT             00400                   # BIT 9

#                                         TERMINATE TUMBLE MONITOR

                TC              FLAG1DWN
                OCT             20000                   # BIT14
                TCF             TASKOVER
DEC12000        DEC             12000

MP6B            TC              PHASCHNG
                OCT             27042
               -GENADR          536SEC
                EBANK=          MP6TO7
                2CADR           CBXPNDR
# REF   1              27,2527   56003 1  CALL C-BAND TRANSPONDER-ON*

                EXTEND
                DCA             536SEC                  # SET LONGCALL= T+8M 56S
                TC              LONGCALL                # FOR C-BAND TRANSPONDER-ON*
                EBANK=          MP6TO7
                2CADR           CBXPNDR

## Page 668
                TCF             TASKOVER
536SEC          2DEC            53600

#                      27,2537   10540 1  C-BAND TRANSPONDER-ON*

CBXPNDR         TC              1LMP
                DEC             106

                TC              2PHSCHNG
                OCT             00002
                OCT             05013
                OCT             77777

#                                   CALL SCHEDULE ENTRY ROUTINE

                TC              MPENTRY
                DEC             1                       # J=1
                DEC             7                       # MP=7
                ADRES           MP6TO7                  # DT = 28 MIN

#                                   TERMINATE READING OF PIPAS.
#                                   THRUST DUE TO VENTING AFTER SIVB
#                                   SHUTDOWN HAS BECOME NEGLIGIBLE.

                TC              FLAG1DWN                # TERMINATE DV MONITOR
                OCT             1
                TCF             TASKOVER

# END OF MISSION PHASE 6
