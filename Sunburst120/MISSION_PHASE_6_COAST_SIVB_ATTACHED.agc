### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     MISSION_PHASE_6_COAST_SIVB_ATTACHED.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-25 MAS  Transcribed.
##		 2016-12-06 RSB	 Comments proofed using octopus/ProoferComments,
##				 no changes made.

## Page 709
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

MP6JOB          TC              NEWMODEX                        # UPDATE MODREG
                OCT             13
                
                CAF             SIX
                TS              PHASENUM

                TC              PHASCHNG
## Page 710
                OCT             47012
                DEC             6000
                EBANK=          MP6TO7
                2CADR           MP6A

                CAF             BIT6
                TC              SETRSTRT                        # SET RESTART FLAG

                CAF             DEC6000                         # INITIALIZE 1 MIN DELAY
                INHINT
                TC              WAITLIST
                EBANK=          MP6TO7
                2CADR           MP6A

                TCF             ENDOFJOB
DEC6000         DEC             6000

MP6A            TC              FLAG2DWN                        # TERMINATE ABORT COMMAND MONITOR
                OCT             00400                           # BIT 9

#                                   TERMINATE TUMBLE MONITOR

                TC              FLAG1DWN
                OCT             20000                           # BIT14
MP6B            TC              PHASCHNG
                OCT             27042
               -GENADR          656SEC
                EBANK=          MP6TO7
                2CADR           CBXPNDR
# REF   1       27,2536   56063 1  CALL C-BAND TRANSPONDER-ON*

                EXTEND
                DCA             656SEC                          # LONGCALL 10 M 56 S
                TC              LONGCALL                        # FOR C-BAND TRANSPONDER-ON*
                EBANK=          MP6TO7
                2CADR           CBXPNDR

                TCF             TASKOVER
656SEC          2DEC            65600
#  		27,2546   00100 0  C-BAND TRANSPONDER-ON*

CBXPNDR         TC              1LMP
                DEC             106

                TC              2PHSCHNG
                OCT             00002
                OCT             05013
                OCT             77777

#                                   CALL SCHEDULE ENTRY ROUTINE

## Page 711
                TC              MPENTRY
                DEC             1                               # J=1
                DEC             7                               # MP=7
                ADRES           MP6TO7                          # DT = 28 MIN

#                                   TERMINATE READING OF PIPAS.
#                                   THRUST DUE TO VENTING AFTER SIVB
#                                   SHUTDOWN HAS BECOME NEGLIGIBLE.

                TC              FLAG1DWN                        # TERMINATE SERVICER
                OCT             1
                TCF             TASKOVER

# END OF MISSION PHASE 6
