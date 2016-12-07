### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     MP9-DPS_1_BURN.agc
## Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
##               is part of the source code for the Lunar Module's
##               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      www.ibiblio.org/apollo/index.html
## Mod history:  2016-09-30 RSB  Created draft version.
##               2016-10-28 MAS  Transcribed.
##		 2016-11-01 RSB	 Typos.
##		 2016-12-06 RSB	 Comments proofed using octopus/ProoferComments,
##				 changes made.

## Page 728
# MISSION PHASE 9
                
                BANK            33
                EBANK=          TDEC
# PROGRAM DESCRIPTION-MISSION PHASE9-DPS1 BURN                            DATE-28 OCT 66
# MOD NO-2                                                                LOG SECTION-MP9
# MOD BY- CHO                                                             ASSEMBLY-SUNBURST REV24

# FUNCTIONAL DESCRIPTION
#         THIS PHASE IS STARTED 3HOUR 1MIN AND 49SECS AFTER THE TERMINATI ON OF SIVB/LEM SEPARATION +X TRANSLATI
# ON AND BY THE INITIATION OF PROGRAM 31 (PRE-DPS1 BURN). PROGRAM 31      CALLS FOR DPS CUTOFF TDI 5MIN AND
# 15SECS LATER. IN ORDER TO ALIGN THE VEHICLE THRUST AXIS ALONG THE DESIRED ACCELERATION VECTOR DURING PRE-DPS1
# PHASE, THE FOLLOWING COMPUTATIONS ARE MADE - VEHICLE STATE VECTOR FORWARD INTEGRATION TO THE DESCENT
# INJECTION CUTOFF TIME TDI, VELOCITY TO BE GAINED VG, THE MANEUVER THRUST TIME TTHRUST, DPS1 IGNITION TIME TIGN
# AND FINALLY DESIRED THRUST DIRECTION UNITVG. PROGRAM 31 ALSO COMMANDS LANDING GEAR DEPLOYMENT AND CALL FOR
# A MANEUVER TO THE FIRING ATTITUDE.
#         PROGRAM 41, DPS1 BURN IS STARTED 36SECS BEFORE IGNITION. THIS PROGRAM ARMS THE DESCENT ENGINE,
# COMMANDS +X TRANSLATION AND COMMANDS ENGINE ON. DURING THE BURN, THE VELOCITY TO BE GAINED  AND TIME TO
# CUTOFF TGO ARE COMPUTED EVERY TWO SECONDS. WHEN TGO FALLS BELOW THE CRITICAL VALUE ENGINE OFF SIGNAL COUNTER
# IS SET. WHEN POST ENGINE CUTOFF ROUTINE IS PERFORMED, MPENTRY NO.1 IS SET TO START MP11 IN 31MIN 11SECS.

# CALLING SEQUENCE- AFTER THE TERMINATION OF SIVB/LEM SEPARATION +X TRANSLATION AND BY THE INITIATION OF
# PROGRAM 31.

# NORMAL EXIT MODES- TASKOVER (AWAITS MPENTRY INTO MP11 VIA NO.1)

# ALARM EXIT MODE- NONE

# SUBROUTINES CALLED- FIXDELAY, 1LMP, 2LMP, EXECUTIVE, MIDTOAVE, BANKCALL, IBNKCALL, WAITLIST, KALCMANU,
# UL4JETON, UL4JETOFF, ENGINEON, ENGINOFF, NEWMODEX, DFITCAL, RVUPDADR, TPAGREE, TASKOVER, ENDOFJOB, ENGOF1


# INPUT- RN, VN, RP, MUEARTH, TDI

# OUTPUT- VG, TTHRUST, TIGN, UNITVG, TGO

# ERASABLE INITIALIZATION REQUIRED-

# DEBRIS- TDEC

MP9JOB          CAF             BIT9
                TC              SETRSTRT                        # SET RESTART FLAG

                TC              NEWMODEX                        # DISPLAY PROG. NO.
                OCTAL           31

                EBANK=          TDEC
                EXTEND
                DCA             TIME2                           # PICK UP CURRENT TIME
                DXCH            TDI

## Page 729
                EXTEND
                DCA             5M15S
                DAS             TDI                             # SET TDI=TIME2+5M15S

                CAF             EQU2ADR                         # SET COMPUTATIINAL STEPS
                TS              SHJUMP1

                TC              PHASCHNG
                OCT             05022
                OCT             20000

                EXTEND
                DCA             TDI
                DXCH            TDEC
                EXTEND
                DCA             RVUPDADR                        # STATE VECTOR UPDATE FOR PRE-DPS1 BURN
                DXCH            Z

                TC              PHASCHNG
                OCT             04022

                TC              INTPRET
                CALL
                                VPATCHER                        # RESCALE AND LOAD TDI STATES IN RN AN VN
                GOTO
                                DPS1EQU1        +1              # COMPUTES VELOCITY TO BE GAINED.

DPS1EQU2        DLOAD                                           # COMPUTES MANEUVER THRUST TIME
                                LV                              # ABVAL(VG)
                SR              DSU
                                10D                             # NOW VG SCALED AT 2(+17)M/CS
                                DPA
                DDV             DAD
                                DPB
                                DPC
                STOVL           TTHRUST                         # SCALED AT 2(+28)CS
                                UNITVG
                STOVL           POINTVSM                        # KALCMANU INPUT REGISTER
                                BODYVECT                        # LOAD BODY AXES VECTOR IN SM COORD.
                STORE           SCAXIS                          # KALCMANU INPUT VECTOR
                SET             SSP
                                33D
                                RATEINDX
                                4                               # SET KALCMANU FOR ANGULAR RATE OF 5DEG/S
                EXIT

                TC              PHASCHNG
                OCT             04022

                INHINT

## Page 730
                EXTEND
                DCS             TTHRUST                         # COMPUTES TIGN
                DXCH            TIGN

                EXTEND
                DCA             TDI
                DAS             TIGN                            # TIGN=TDI-TTHRUST  (SCALED AT 2(+28)CS)
                CAF             EQU3ADR
                TS              SHJUMP1

                CAF             70SECS9                         # CALL POSTKALC 70 SECS LATER
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           POSTKALC

                TC              PHASCHNG
                OCT             40042

CALLKALC        INHINT
                CAF             PRIO16                          # CALL KALCMANU JOB.
                TC              FINDVAC
                EBANK=          MIS
                2CADR           VECPOINT

                TC              BANKCALL
                CADR            ATTSTALL                        # SEE IF KALCMANU FINISHED
CURT9           TC              CURTAINS                        # UNFINISHED MANEUVER

                TC              PHASCHNG
                OCT             00432                           # 2.43 FOR POSTKALC.  DON'T RESET TBASE.

                TCF             ENDOFJOB                        # GOOD RETURN- END MP9JOB

POSTKALC        CS              FLAGWRD2                        # CHECK WHETHER KALCMANU IS FINISHED.
                MASK            BIT11
                CCS             A

                TC              GOODKALC                        # GOOD RETURN

                CAF             PRIO37                          # BAD RETURN
                TC		FINDVAC
                EBANK=          TDEC
                2CADR           CURT9

                TC              TASKOVER                        # END POSTKALC TASK

GOODKALC        TC              1LMP+DT
                DEC             236                             # DFI T/M CALIBRATE - ON *
                DEC             1200

## Page 731
                TC              2LMP+DT
                DEC             237                             # DFI T/M CALIBRATE - OFF *
                DEC             198                             # MASTER C&W ALARM RESET - COMMAND **
                DEC             200

                TC              1LMP+DT
                DEC             199                             # MASTER C&W ALARM RESET - COMMAND RESET
                DEC             1

                EXTEND                                          # CALL DPS1 BURN PROG. AT TIGN-36SECS.
                DCS             TIME2
                DXCH            ITEMP1
                EXTEND
                DCA             TIGN
                DAS             ITEMP1
                EXTEND
                DCS             66SECSD9
                DAS             ITEMP1
                EXTEND
                DCA             ITEMP1
                DXCH            TDECTEMP                        # FOR RESTARTS.
                DXCH            ITEMP1

                TC              LONGCALL
                EBANK=          TDEC
                2CADR           TIG9-66

                TC              PHASCHNG
                OCT             20134                           # 4.13 FOR TIG9-66 LONGCALL.

                CAF             11SECS9
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           182LMP

                TC              PHASCHNG
                OCT             40452                           # 2.45 FOR 182LMP TASK.

                TCF             TASKOVER                        # END GOODKALC TASK

182LMP          TC              2LMP+DT
                DEC             182                             # LANDING RADAR POWER ON
                DEC             26                              # RADAR SELF TEST-ON
                DEC             4900

                TC              1LMP+DT
                DEC             4                               # ED BATTERY ACTIVATION -ON
                DEC             500

                TC              1LMP+DT
## Page 732
                DEC             8                               # LANDING GEAR DEPLOY -FIRE
                DEC             200

                TC              1LMP+DT
                DEC             9                               # LANDING GEAR DEPLOY- FIRE RESET
                DEC             400

                TC              1LMP
                DEC             27                              # RADAR SELF-TEST - OFF.

                TC              PHASCHNG
                OCT             00002                           # GROUP 2 OFF.

                TC              TASKOVER                        # END 182LMP TASK

TIG9-66         TC              NEWMODEX                        # DISPLAY PROGRAM NUMBER ON DSKY
                OCT             41

                TC              IBNKCALL
                CADR            ENGINOF1

                TC              2LMP
                DEC             150                             # ENGINE SELECT DESC ARM
                DEC             86                              # MANUAL THROTTLE ON (10PERCENT)

                CAF             50SECS9
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           228LMP

                CAF             PRIO27
                TC              FINDVAC
                EBANK=          TDEC
                2CADR           ORBINTJB

                TC              2PHSCHNG
                OCT             40472                           # 2.47 FOR 228LMP TASK.
                OCT             00154                           # 4.15 FOR ORBINTJB JOB.

                TCF             TASKOVER                        # END TIG9-66 TASK

ORBINTJB        EXTEND
                DCA             TIGN
                DXCH            TDEC
                CS              30SECS9
                TS              L
                CS              ZERO
                DAS             TDEC                            # TDEC NOW CONTAINS TIGN-30 SECS.

                EXTEND
## Page 733
                DCA             ORBINTAD
                DXCH            Z

                TC              PHASCHNG
                OCT             05024
                OCT             27000

# RN AND VN IN STABLE MEMBER COORDINATES. SCALING IS AS IN AVEG.

#          DELETE
                CAF             AVGENADR
                TS              DVSELECT                        # SELECT AGS MONITOR

                EXTEND
                DCA             EXITADR
                DXCH            AVGEXIT                         # SET AVERAGEG EXIT

                EXTEND
                DCA             MP9TM1AD
                DXCH            DVMNEXIT                        # SET MONITOR EXIT

                INHINT
                CS              30SECS9                         # CALL PREREAD AT TIGN-30SECS.
                TC              TASKSETR
                TS              RSDTTEMP                        # FOR RESTARTS.
                TC              WAITLIST
                EBANK=          DVTOTAL
                2CADR           PREREAD

                TC              2PHSCHNG
                OCT             40355                           # 5.35 FOR PREREAD.
                OCT             04024

                INHINT
                CS              ZERO                            # CALL TVC FOR DPS1 AT IGNITION TIME
                TC              TASKSETR
                TS              TDECTEMP        +1              # FOR RESTARTS.
                TC              WAITLIST
                EBANK=          AVGEXIT
                2CADR           TIG9-0

                TC              PHASCHNG
                OCT             40174                           # 4.17 FOR TIG9-0.

                TCF             ENDOFJOB                        # END ORBITAL INTEGRATION JOB

TIG9-0          EXTEND
                DCA             EQU1ADR
                DXCH            AVGEXIT                         # AVG ROUTINE GOES TO VG COMPUTATION

## Page 734
                TC              IBNKCALL
                CADR            DPSENGON
## The above line has a green arrow pointing to it.

                TC              2PHSCHNG
                OCT             00004
                OCT             40512                           # 2.51 FOR 9ULLOFF TASK.

                TC              FIXDELAY
                DEC             50

9ULLOFF         TC              IBNKCALL
                CADR            NOULLAGE                        # +X TRANSLATION-  OFF

                TC              PHASCHNG
                OCT             40532                           # 2.53 FOR 9EDBATT.

                TC              FIXDELAY
                DEC             250

9EDBATT         TC              1LMP+DT
                DEC             5                               # ED BATTERY ACTIVATION-SAFE
                DEC             2300

                TC              2PHSCHNG
                OCT             2
                OCT             05014                           # THROTTLE PROGRAM TAKES OVER GP 4.
                OCT             77777

                CAF             POSMAX                          # CALL FOR MAXIMUM THRUST.
                TS              PCNTF
                EXTEND
                DCA             PCNTFMAD
                DTCB

                TCF             TASKOVER                        # END TIG9-0 TASK

DPS1EQU3        CALL
                                CALCTGO
                VLOAD
                                UNITVG
                STORE           AXISD                           # FINDCDUD INPUT
                CALL
                                FINDCDUD

                EXIT
                TC              POSTJUMP
                CADR            SERVEXIT

CALCTGO         DLOAD           DSU
                                LV                              # ABVAL(VG)
## Page 735
                                VTAILOFF
                DMP             DDV
                                DELTAT9
                                ABDELV
                STORE           TTGO                            # FOR DWLK ONLY

                RTB             BDSU
                                LOADTIME
                                PIPTIME
                DAD             RTB
                                TTGO
                                SGNAGREE
                STORE           TGO

                DSU             BPL
                                4SECSD9
                                QPRET
                EXIT

                INHINT
                CAE             TGO             +1
                EXTEND
                BZMF            CUTOFF2                         # CUT OFF ENGINE IMMEDIATELY IF TGO NEG
CUTOFF1         TS              TDECTEMP                        # FOR RESTARTS.
                TC              WAITLIST
                EBANK=          CDUXD
                2CADR           CUTOFF

                EXTEND                                          # STOPS GUIDANCE EQUATION LOOP
                DCA             EXITADR
                DXCH            AVGEXIT

                TC              2PHSCHNG
                OCT             40552                           # 2.55 FOR CUTOFF TASK.
                OCT             00035                           # 5.3 FOR SERVICER.

                TCF             ENDOFJOB                        # END DPS1 BURN EQUATION JOB

CUTOFF          TC              IBNKCALL
                CADR            ENGINOFF

                TC              IBNKCALL
                CADR            STOPRATE                        # HOLD VEHICLE ATTITUDE

                TC              PHASCHNG
                OCT             2                               # 2 OFF.  SERVICER TO RETURN TO MP9TERM1.

                TCF             TASKOVER                        # END CUTOFF TASK

CUTOFF2         CAF             BIT1

## Page 736
                TCF             CUTOFF1

MP9TERM1        INHINT
                CAF             5SECS9
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           87LMP

                TC              PHASCHNG
                OCT             40572                           # 2.57 FOR 87LMP TASK.

                TC              POSTJUMP
                CADR            SERVEXIT

87LMP           TC              2LMP+DT
                DEC             87                              # MANUAL THROTTLE - RESET (30 PERCENT.)
                DEC             151                             # ENGINE SELECT-DESC ARM-OFF
                DEC             1000

                TC              2LMP+DT
                DEC             245                             # DPS PQGS NO1 - OFF
                DEC             213                             # DPS PQGS NO2 - OFF
                DEC             100

                TC              2LMP+DT
                DEC             229                             # DPS PQGS ARM NO1 DISABLE
                DEC             197                             # DPS PQGS ARM NO2 DISABLE
                DEC             1400

                TC              IBNKCALL
                CADR            SETMAXDB

                TC              1LMP+DT
                DEC             26                              # RADAR SELF TEST ON
                DEC             6000

                TC              2LMP
                DEC             27                              # RADAR SELF TEST POWER - OFF
                DEC             183                             # LANDING RADAR POWER - OFF

                TC              MPENTRY                         # CALL NEXT MISSION ENTRY ROUTINE
                DEC             1
                DEC             11
                ADRES           MP9-11DT

                TC              FLAG1DWN                        # KNOCK DOWN AVERAGEG FLAG
                OCT             00001

                TC              PHASCHNG
                OCT             2

## Page 737
                TCF             TASKOVER                        # MISSION PHASE 9 COMPLETE

DPS1EQU1        TC              INTPRET
 +1             VLOAD           VXV
                                VN                              # VN SCALED AT 2(+7)M/CS
                                UNITR                           # UNITR IS UNIT VECTOR ALONG RN
                UNIT            PDVL
                                UNITR
                VXV
                PDDL            DAD
                                RP                              # TARGET DISTANCE - PERIGEE OR APOGEE
                                RMAG                            # RP AND RMAG SCALED AT 2(+24)M
                DMP             PDDL
                                RMAG
                                RP
                DMP             DDV
                                2MUERTH9                        # SCALED AT 2(+38)M(3)/CS(2).
                SQRT            VXSC
                VSL2
                STORE           VDVECT                          # FOR DWNLK ONLY. SCALED AT 2(+7)M/CS

                VSU
                                VN
                STORE           VGVECT                          # FOR DWNLK ONLY. SCALED AT 2(+7)M/CS

                UNIT                                            # LEAVES ABVAL IN LV
                STORE           UNITVG

                GOTO
                                SHJUMP1

228LMP          TC              2LMP+DT
                DEC             228                             # DPS PQGS ARM NO1 - ENABLE
                DEC             196                             # DPS PQGS ARM NO2 - ENABLE
                DEC             100

                TC              2LMP+DT
                DEC             244                             # DPS PQGS NO1 - ON
                DEC             212                             # DPS PQGS NO2 - ON
                DEC             750

                TC              IBNKCALL
                CADR            ULLAGE                          # +X TRANSLATION ON.

                TC              PHASCHNG
                OCT             2

                TCF             TASKOVER                        # END 228LMP TASK

#          ********************************

## Page 738
EQU2ADR         CADR            DPS1EQU2

EQU3ADR         CADR            DPS1EQU3

                EBANK=          TDEC
EQU1ADR         2CADR           DPS1EQU1

                EBANK=          TDEC
MP9TM1AD        2CADR           MP9TERM1

                EBANK=          TDEC
RVUPDADR        2CADR           RVUPDATE

4SECSD9         2DEC            400

66SECSD9        2DEC            6600

5M15S           2DEC            31500

DPA             2DEC            .09449          B-17            # SCALED AT 2(+17)M/CS

DPB             2DEC            .0002874        B+11            # SCALED AT 2(-11)M/CS(+2)

DPC             2DEC            2600.           B-28            # SCALED AT 2(+28)CS

DELTAT9         2DEC            200             E+4 B-35        # 2SEC/KPIP

2MUERTH9        2DEC*           3.98603223      E+10 B-37*

5SECS9          DEC             500
50SECS9         DEC             5000
30SECS9         DEC             3000
11SECS9         DEC             1100
70SECS9         DEC             7000
#          ********************************
