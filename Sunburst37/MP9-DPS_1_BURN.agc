### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MP9-DPS_1_BURN.agc
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
## Reference:   pp. 684-692
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-14 RSB	Transcribe
##              2017-06-14 HG   Fix operand THRUSTCMD -> THRSTCMD
##                                          AVEXIT    -> AVGEXIT
##              2017-06-15 HG   Fix value DELTAT9    B-35 -> B-38 
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 684
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
#

# INPUT- RN, VN, RP, MUEARTH, TDI

# OUTPUT- VG, TTHRUST, TIGN, UNITVG, TGO

# ERASABLE INITIALIZATION REQUIRED-

# DEBRIS- TDEC

MP9JOB          TC              NEWMODEX                        # DISPLAY PROGRAM NUMBER IN DSKY
                OCTAL           31

                EBANK=          TDEC
                EXTEND
                DCA             TIME2                           # PICK UP CURRENT TIME
                DXCH            TDI
                EXTEND
                DCA             5M15S
                DAS             TDI                             # SET TDI=TIME2+5M15S

## Page 685

                CAF             EQU2ADR                         # SET COMPUTATIINAL STEPS
                TS              SHJUMP1

                EXTEND
                DCA             TDI
                DXCH            TDEC
                EXTEND
                DCA             RVUPDADR                        # STATE VECTOR UPDATE FOR PRE-DPS1 BURN
                
                DXCH            Z

                TC              INTPRET
                CALL
                                VPATCHER                        # RESCALE AND LOAD TDI STATES IN RN AN VN
                GOTO
                                DPS1EQU1                        # COMPUTES VELOCITY TO BE GAINED

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

                EXTEND
                DCS             TTHRUST                         # COMPUTES TIGN
                DXCH            TIGN

                EXTEND
                DCA             TDI
                DAS             TIGN                            # TIGN=TDI-TTHRUST  (SCALED AT 2(+28)CS)
                CAF             EQU3ADR
                TS              SHJUMP1

		INHINT
                CAF             90SECS9                         # CALL POSTKALC 90 SECS LATER
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           POSTKALC
## Page 686
                CAF             PRIO30                          # CALL KALCMANU JOB- START INDICATOR UP*
                TC              FINDVAC
                EBANK=          MIS
                2CADR           VECPOINT

                TC              BANKCALL
                CADR            ATTSTALL                        # SEE IF KALCMANU FINISHED
CURT9           TC              CURTAINS                        # UNFINISHED MANEUVER

                TCF             ENDOFJOB                        # GOOD RETURN- END MP9JOB

POSTKALC	CAF		10SECS9				# CALL DFITMTSK 10SECS LATER
		TC		WAITLIST
		EBANK=		TGRR
		
		2CADR		DFITMTSK			# DFI T/M CALIBRATION ROUTINE
		
		CS		FLAGWRD2			# CHECK KALCMANU BIT
		MASK		BIT11
		CCS		A

                TC              GOODKALC                        # GOOD RETURN

                CAF             PRIO37                          # BAD RETURN
                TC		FINDVAC
                EBANK=          TDEC
                2CADR           CURT9

                TC              TASKOVER                        # END POSTKALC TASK

GOODKALC	CAF		11SECS9
		TC		WAITLIST
		EBANK=		TDEC
		2CADR		182LMP
		
                EXTEND                                          # CALL DPS1 BURN PROG. AT TIGN-36SECS.
                DCS             TIME2
                DXCH            ITEMP1
                
                EXTEND
                DCA             TIGN
                DAS             ITEMP1
                EXTEND
                DCS             36SECSD9
                DAS             ITEMP1
                DXCH            ITEMP1

                TC              LONGCALL
                EBANK=          TDEC
                2CADR           TIG9-36

                TCF             TASKOVER                        # END GOODKALC TASK
## Page 687

182LMP          TC              2LMP+DT
                DEC             182                             # LANDING RADAR POWER ON
                DEC             26                              # RADAR SELF TEST-ON
                DEC             4900

                TC              1LMP+DT
                DEC             4                               # ED BATTERY ACTIVATION -ON
                DEC             500

                TC              1LMP+DT
                DEC             8                               # LANDING GEAR DEPLOY -FIRE
                DEC             200

                TC              1LMP+DT
                DEC             9                               # LANDING GEAR DEPLOY- FIRE RESET
                DEC             400

                TC              1LMP
                DEC             27                              # RADAR SELF TEST-OFF

                TC              TASKOVER                        # END 182LMP TASK

TIG9-36         TC              NEWMODEX                        # DISPLAY PROGRAM NUMBER IN DSKY
                OCT             41

                TC              ENGINOF1			# MAKE SURE ENGINE OFF

                TC              2LMP
                DEC             150                             # ENGINE SELECT DESC ARM
                DEC             86                              # MANUAL THROTTLE ON (10PERCENT)

                CA              20SECS9
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           228LMP

                CAF             PRIO27
                TC              FINDVAC
                EBANK=          TDEC
                2CADR           ORBINTJB

                TCF             TASKOVER                        # END TIG9-36 TASK

ORBINTJB        EXTEND
                DCA             TIGN
                DXCH            TDEC
                CS              30SECS9
                TS              L
                CS              ZERO
                DAS             TDEC                            # TDEC NOW CONTAINS TIGN-30 SECS.

## Page 688
                EXTEND
                DCA             ORBINTAD
                
                DXCH            Z

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

                CS              30SECS9                         # CALL PREREAD AT TIGN-30SECS.
                TC              TASKSETR
                
                INHINT
                TC              WAITLIST
                EBANK=          DVTOTAL
                2CADR           PREREAD

                CS              4SECS9                          # CALL TVC FOR DPS1 AT TIG-4SECS
                TC              TASKSETR
                INHINT
                TC              WAITLIST
                EBANK=          AVGEXIT
                2CADR           TIG9-4

                TCF             ENDOFJOB                        # END ORBITAL INTEGRATION JOB

TIG9-4		CAF		4SECS9				# DO ENGINE ON AT TIG-0 SEC
		TC		WAITLIST
		EBANK=		THRSTCMD
		2CADR		TIG9-0
		
		EXTEND
		DCA		EQU1ADR
		DXCH		AVGEXIT				# AVG ROUTINE GOES TO VG COMPUTATION
		
		TCF		TASKOVER			# END TIG9-4 TASK

TIG9-0		TC		ENGINEON			# COMMAND ENGINE ON

		TC		FIXDELAY
		DEC		50
## Page 689

                TC              IBNKCALL
                CADR            NOULLAGE			# +X TRANSLATION-  OFF

		EBANK=		THRSTCMD			# DECLARE EBANK=6
		CAF		10PERTHR			# REPORT 10 PERCENT THRUST TO DAP
		TS		THRSTCMD
		
		TC		FIXDELAY
		
		DEC		250
		
		TC		1LMP+DT
		DEC		5				# ED BATTERY ACTIVATION-SAFE
		DEC		2300
		
MAXTHR9		CAF		POSMAX				# CALL FOR 92.5 PERCENT THRUST
		TS		PCNTF
		EXTEND
		DCA		PCNTFMAD
		DTCB
		
		CAF		92PERTHR			# REPORT THRUST TO DAP
		TS		THRSTCMD
		TCF		TASKOVER			# END TIG9-0 TASK
		
		EBANK=		TDEC				# DECLARE EBANK=4
		
DPS1EQU3        CALL
                                CALCTGO
                VLOAD
                                UNITVG
                STORE           AXISD                           # FINDCDUD INPUT
                CALL
                                FINDCDUD

                TCF		ENDOFJOB			# END DPS1EQU3 JOB DURING BURN ONLY

CALCTGO         DLOAD           DSU
                                LV                              # ABVAL(VG)
                                VTAILOFF
                DMP             DDV
                                DELTAT9
                                ABDELV
                STORE           TTGO                            # FOR DWLK ONLY

                STORE           TGO

                DSU             BPL
                                4SECSD9
                                QPRET
                EXIT
## Page 690

                INHINT						# CUTOFF SIGNAL COUNTER SET
                CA              TGO             +1
                TC              WAITLIST
                EBANK=          CDUXD
                2CADR           CUTOFF

                TCF             ENDOFJOB                        # END DPS1 BURN EQUATION JOB

CUTOFF		TC		ENGINOFF			# ENGINE OFF

                TC              IBNKCALL
                CADR            STOPRATE                        # HOLD VEHICLE ATTITUDE

                TCF             TASKOVER                        # END CUTOFF TASK

MP9TERM1	EXTEND
		DCA		EXITADR
		DXCH		AVGEXIT

	        INHINT
                CAF             5SECS9
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           87LMP

                TCF		ENDOFJOB			# END MP9TERM1 JOB

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

                TC              1LMP
                DEC             26                              # RADAR SELF TEST ON
                
                TC		FIXDELAY
                DEC             6000
## Page 691

                TC              2LMP
                DEC             27                              # RADAR SELF TEST POWER - OFF
                DEC             183                             # LANDING RADAR POWER - OFF

                TC              MPENTRY                         # CALL NEXT MISSION ENTRY ROUTINE
                DEC             1
                DEC             11
                ADRES           MP9-11DT

                TC              FLAG1DWN                        # KNOCK DOWN AVERAGEG FLAG
                OCT             00001

                TCF             TASKOVER                        # MISSION PHASE 9 COMPLETE

DPS1EQU1        VLOAD           VXV
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
## Page 692
                DEC             750

                TC              IBNKCALL
                CADR            ULLAGE                          # +X TRANSLATION- ON
                TCF             TASKOVER                        # END 228LMP TASK

#          ********************************

EQU2ADR         CADR            DPS1EQU2

EQU3ADR         CADR            DPS1EQU3

                EBANK=          TDEC
EQU1ADR         2CADR           DPS1EQU1

                EBANK=          TDEC
MP9TM1AD        2CADR           MP9TERM1

                EBANK=          TDEC
RVUPDADR        2CADR           RVUPDATE

4SECSD9         2DEC            400

36SECSD9        2DEC            3600

5M15S           2DEC            31500


DPA             2DEC            .09449          B-17            # SCALED AT 2(+17)M/CS

DPB             2DEC            .0002874        B+11            # SCALED AT 2(-11)M/CS(+2)

DPC             2DEC            2600.           B-28            # SCALED AT 2(+28)CS

VTAILOFF	2DEC		0				# ***** GET THE NUMBER

DELTAT9         2DEC            200             E+4 B-38        # 2SEC/KPIP

2MUERTH9        2DEC*           3.98603223      E+10 B-37*

1SEC9		DEC		100
4SECS9		DEC		400
5SECS9          DEC             500
10SECS9		DEC		1000
11SECS9		DEC		1100
20SECS9		DEC		2000
30SECS9		DEC		3000
90SECS9		DEC		9000
120SECS9	DEC		12000
#          ********************************
