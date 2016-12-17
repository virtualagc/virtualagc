### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	UPDATE_PROGRAM_PART_1_OF_2.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##		2016-10-14 RSB	Transcribed.
##		2016-10-31 RSB	Typo.
##		2016-12-05 RSB	Proofed with octopus/ProoferComments
##				and various comments corrected, but the
##				proofing process is not yet completed.
##		2016-12-05 RSB	Comment-proofing pass with octopus/ProoferComments completed.

## Page 316
# PROGRAM NAME- UPDATE PROGRAM
# PROGRAM WRITTEN BY- RHODE
# MOD NO.- 2
# MOD BY- KILROY TO ADD AGC CLOCK AND TE(V75E4ETTTTTE) UPDATE FEATURE.
# DATE- 01FEB67
# LOG SECTIONS- UPDATE PROGRAM PART 1 OF 2
#               UPDATE PROGRAM PART 2 OF 2
# ASSEMBLY- REV 93 OF SUNBURST
# FUNCTIONAL DESCRIPTION- TO PROCESS COMMANDS AND DATA INSERTIONS
#          REQUESTED BY THE GROUND VIA UPLINK.
#	   VERBS V64, V67, V70, V71, V72, V73, V75 AND V76 WILL NOT BE
#          PROCESSED IF THE MISSION TIMERS ARE DISABLED(I.E. AN MP IS IN
#	   PROGRESS). OPERATOR ERROR LIGHT WILL BE TURNED ON.
#	   V65, V66 AND V74 WILL BE PROCESSED EVEN IF A MP IS IN PROGRESS
# CALLING SEQUENCE- TCF XXUPDAT   WHERE XX = EXTENDED VERGS(64 TO 76)
#				  LST2FAN CONTAINS A LIST OF TCF XXUPDAT
#				  WHICH ARE USED BY VERBFAN IN PINBALL TO
#				  GIVE CONTROL TO THE UPDATE PROGRAM.
# SUBROUTINES CALLED- POSTJUMP,IBNKCALL, BANKCALL, CHECKMM, GRABWAIT,
#          NEWMODEX, FREEDSP, WAITLIST, ENDOFJOB, NOVAC, TASKOVER, FINDVAC
#          ENDUP, DOV67, DOV70, DOV71, DOV72, DOV73, DOV74, DFITMCAL,
#	   GRRPLACE, NVSBWAIT, ENDIDLE, XACTALM, MGETUP, UPDATINT, TPAGREE
# NORMAL EXIT MODE- TC    BANKCALL
#		    CADR  ENDUP
# ALARM OR ABORT EXIT MODE- BZF   XACTALM    IF MP IN PROGRESS
#
#                           TC    BANKCALL   IF MP IN PROGRESS
#                           CADR  XACTALM
# RESTART PROTECTION- NONE FOR VERBS 64 TO 74. RESTART PROTECTION IS
#          INCLUDED FOR V75 AND V76 UNDER THE FOLLOWING CIRCUMSTANCES-----
#	   1. THE DATA HAS BEEN SENT AND VERIFIED(I.E. V33E HAS BEEN SENT)
#	   2. PROGRAM IS IN THE PROCESS OF MOVING DATA FROM STBUFF TO
#	      APPROPRIATE REGISTERS OR
#	      VERB 75 OR VERB 75(INDEX = 4 ONLY) PROGRAM(S) ARE WAITING(VIA WAITLIST
#	      3 SEC CALL) FOR ORBITAL INTEGRATION TO BE TURNED OFF.
#          ***OF COURSE ALL GROUND UPDATES(IF LOST DUE TO A RESTART) CAN
#	   BE RESTARTED BY SENDING THE COMMANDS AND DATA A SECOND TIME***
# INPUT(SEE LATEST AS206 GSOP:R527:FOR MORE INFO)-    ..................DESCRIPTION OF UPDATE COMPONENTS..........
#                                                     COMP.
# UPDATE ENTRY    DESCRIPTION OF UPDATE VERBS         NO.  SYMBOL VALUES           DEFINITION  (WHERE STORED)
# --------------- ----------------------------------- ---- ------ ---------------- -------------------------------
# V64EIEXXXXXE    SET MISSION TIMER I TO ELAPSE AT A   1.    I    1,2,3,4          MISSION TIMERS
#       XXXXXE    GIVEN GROUND ELAPSED TIME(GET).X-S   2.  XXXXX                   MSB OF GET(MUST BE IN)
#                 ARE THE GET(IN CENTISECONDS OF THE   3.  XXXXX                   LSB OF GET(THE FUTURE)
#                 DESIRED EVENT.
# V65E		  SET GUIDANCE REFERENCE RELEASE       NONE
#		  DISCRETE.
# V66E		  INITIATE THE LGC DFI TLM CALIBRATE   NONE
#		  ROUTINE.
# V67EXXXE        ENTER A THREE DIGIT OCTAL NUMBER     1.   XXX   1-377(OCTAL)     SEE GSOP FOR LIST OF COMMANDS
## Page 317
#                 REPRESENTING THE 8 BIT COMMAND TO
#                 BE SENT TO THE LMP.
# V70EIETTTTTE    INCREMENT TIMER I BY TTTTT OCTAL     1.    I    1,2,3,4          MISSION TIMERS
#		  SECONDS.                             2.  TTTTT                   **SEE NOTES TO LEFT**
#                 **SEE BELOW FOR DESCRIPTION OF
#		  :UPDATE OF TIMERI LOGIC : AND
#		  :TIMER MAINTENANCE LOGIC:**
# V71EIEPPE       SET MISSION PHASE REGISTER I TO      1.    I    1,2,3,4          MISSION PHASE REGISTERS
#                 MISSION PHASE PP (OCTAL)             2.   PP 7,10,11,13,15(OCT)  MISSION PHASES
# V72EIEPPETTTTTE (--COMBINATION OF V70 AND V71.--)
# V73EIE          CHANGE THE STATE OF THE DPS COLD     1.    I     1               ENABLE/INHIBIT RCS TESTING
#                 SOAK (MISSION PHASE 8) DISCRETE(I=2)       I     2		   ENABLE/INHIBIT DPS COLD SOAK
#                                                            I     3               ENABLE/INHIBIT RCS COLD SOAK
#                                                                                  (I = 1 OR 3 WILL ONLY INVERT
#										   RESPECTIVE BITS OF FLAGWRD2 AND
#										   HAVE NO OTHER EFFECT ON 206)
# V74E            MISSION IDLE COMMAND.                NONE
#		  (VERB 15,NOUN 50, R1 = FAILREG,
#		  R2 = FAILREG +1, R3 = FAILREG +2
#		  WILL APPEAR ON DSKY)
# V75E1EXXXXXE    UPDATE TARGET PARAMETERS FOR DPS1    1.    I     1               DPS1 TARGET PARAMS UPDATE CODE
#       XXXXXE    BURN.(MISSION PHASE 9).              2.  XXXXX                   MSB OF R(P)   (RP   )
#                                                      3.  XXXXX                   LSB OF R(P)   (RP +1)
#                                                                         (RP IS THE DESIRED PERIGEE OR APOGEE
#									  RADIUS SCALED AT METERS  2(24))
# V75E2EXXXXXE	  UPDATE TARGET PARAMETERS FOR DPS2    1.    I     2               DPS2 TARGET PARAMS UPDATE CODE
#       XXXXXE    BURN (MISSION PHASE 11).             2.  XXXXX                   MSB OF CPT(6) (CPT6/2   )
#	XXXXXE                                         3.  XXXXX		   LSB OF CPT(6) (CPT6/2 +1)
#	XXXXXE                                         4.  XXXXX                   MSB OF CPT(7) (CPT6/2 +2)
#       XXXXXE                                         5.  XXXXX                   LSB OF CPT(7) (CPT6/2 +3)
#       XXXXXE                                         6.  XXXXX                   MSB OF CPT(8) (CPT6/2 +4)
#                                                      7.  XXXXX                   LSB OF CPT(8) (CPT6/2 +5)
#                                                                         (CPT/6 IS 1/2 UNIT NORMAL TO THE
#									  DESIRED ORBITAL PLANE IN STABLE MEMBER
#                                                                         COORDINATES)
# V75E3EXXXXXE    UPDATE TARGET PARAMETERS FOR APS2    1.    I     3               APS2 TARGET PARAMS UPDATE CODE
#       XXXXXE	  BURN (MISSION PHASE 13).             2.  XXXXX                   MSB OF RCSM(TA)0  (RIVEC   )
#       XXXXXE                                         3.  XXXXX                   LSB OF RCSM(TA)0  (RIVEC +1)
#       XXXXXE                                         4.  XXXXX                   MSB OF RCSM(TA)1  (RIVEC +2)
#       XXXXXE                                         5.  XXXXX                   LSB OF RCSM(TA)1  (RIVEC +3)
#       XXXXXE                                         6.  XXXXX                   MSB OF RCSM(TA)2  (RIVEC +4)
#       XXXXXE                                         7.  XXXXX                   LSB OF RCSM(TA)2  (RIVEC +5)
#       XXXXXE                                         8.  XXXXX                   MSB OF TA         (TINT    )
#       XXXXXE                                         9.  XXXXX                   LSB OF TA         (TINT  +1)
#       XXXXXE                                        10.  XXXXX                   MSB OF RD         (RCO     )
#                                                     11.  XXXXX                   LSB OF RD         (RCO   +1)
#									  (RIVEC IS THE POSITION VECTOR OF THE
#									   DESIRED INTERCEPT POINT IN STABLE
#									   MEMBER COORD SCALED AT METERS 2(25).
#									   TINT IS THE TIME SCALED AT CSEC 2(28).
## Page 318
#                                                                          RCO IS THE DESIRED RADIUS AT CUTOFF
#                                                                           SCALED AT METERS 2(25))
# V75E4ETTTTTE    UPDATE LGC CLOCK(TIME2,TIME1)        1.    I     4               LGC AND SV CLOCK UPDATE CODE
#                 AND STATE VECTOR TIME(TE,TE +1)      2.  TTTTT                   DELTA TIME(SP,OCTAL,CSEC) TO
#                 WITH TTTTT(IN CENTISECONDS)                                      BE ADDED TO TIME1 AND TE +1
# V76E  XXXXXE    STATE VECTOR UPDATE.                 1.  XXXXX                   MSB OF X POSITION (REFRRECT   )
#       XXXXXE                                         2.  XXXXX                   LSB OF X POSITION (REFRRECT +1)
#       XXXXXE                                         3.  XXXXX                   MSB OF Y POSITION (REFRRECT +2)
#       XXXXXE                                         4.  XXXXX                   LSB OF Y POSITION (REFRRECT +3)
#       XXXXXE                                         5.  XXXXX                   MSB OF Z POSITION (REFRRECT +4)
#       XXXXXE                                         6.  XXXXX                   LSB OF Z POSITION (REFRRECT +5)
#       XXXXXE                                         7.  XXXXX                   MSB OF X VELOCITY (REFVRECT   )
#       XXXXXE                                         8.  XXXXX                   LSB OF X VELOCITY (REFVRECT +1)
#       XXXXXE                                         9.  XXXXX                   MSB OF Y VELOCITY (REFVRECT +2)
#       XXXXXE                                        10.  XXXXX                   LSB OF Y VELOCITY (REFVRECT +3)
#       XXXXXE                                        11.  XXXXX                   MSB OF Z VELOCITY (REFVRECT +4)
#       XXXXXE                                        12.  XXXXX                   LSB OF Z VELOCITY (REFVRECT +5)
#       XXXXXE                                        13.  XXXXX                   MSB OF TIME       (TE         )
#       XXXXXE                                        14.  XXXXX                   LSB OF TIME       (TE +1      )
#                                                                         (POSITION SCALED AT KILOMETERS 2(14).
#                                                                         VELOCITY SCALED AT METERS/CSEC
#                                                                          2(7) / 1.29753638
#                                                                         TIME SCALED AT CENTISECONDS 2(23) )
# UPTATE OF TIMERI LOGIC(UPDT = TTTTT TIME SENT VIA UPLINK)-
#                                                       T
# BEFORE   A        A                 A                 H
# UPDATE   N        N                 N                 E
# TIMERI = D UPDT = D TIMERI + UPDT = D TIMERI + UPDT = N TIMERI =
# -------- - ------ - --------------- - --------------- - -------------
#          (        (
#          (        ( OVERFLOW                            NO CHANGE (EXCEPT OPERATOR ERROR = ON)
#          (        (
#          (        (
#          (        (                 (
#          ( .GT. +0(                 (  .GE. +0          TIMERI + UPDT
#          ( .LT. -0(   NO            (
#          (        ( OVERFLOW        (  .LT. -0             0
#  .GE. +0 (        (                 (
#          (        (                 (  .EQ. -0             0
#          (        (                 (
#          (        (
#          (
#          (        (
#          ( .EQ. +0(                                       UPDT
#          ( .EQ. -0(
#          (        (
#          (
#
#  .LE. -0                                                  UPDT

## Page 319
# TIMER MAINTENANCE LOGIC(BY MMAINT)-
# TIMERI =  MEANS
# --------  --------------------------------------------------------------
#  .GT. +0  TIMERI IS COUNTING DOWN
#  .EQ. +0  MISSION PHASE IN ASSOCIATED MISSION PHASE REGISTER IS NOW DUE
#  .LT. -0  FREE BUT LOADED BY GROUND
#  .EQ. -0  FREE
# OUTPUT- PERFORM UPDATES AS DESCRIBED IN GSOP AND :INPUT:
# ERASABLE INITIALIZATION REQUIRED- NONE
# DEBRIS(ERASABLE LOCATIONS DESTROYED BY THIS PROGRAM)- MPAC - MPAC +2,
#          STCOUNT, EBANK, UPVERB, UPOLDMOD, FLAGWRD2(BIT6),UPTEMP,
#	   UPTEMP1, COMPNUMB, REFRRECT - REFRRECT +5, REFRCV - REFRCV +5,
#          REFVRECT - REFVRECT +5, REFVCV - REFVCV +5, TE - TE +1,
#          DELTAV - DELTAV +5, NUV - NUV +5, REFTC -REFTC +1,
#          REFKEP - REFKEP +1, UPINDEX, UPDT
#          AND CENTRAL REGISTERS

		BANK	11
		EBANK=	STBUFF
65UPDAT		TC	POSTJUMP
		CADR	GRRPLACE
74UPDAT		TC	POSTJUMP
		CADR	DOV74
66UPDAT		INHINT
		TC	IBNKCALL
		CADR	DFITMCAL
		TCF	ENDOFJOB
		
73UPDAT		CA	OCT73
		TC	67UPDAT	+1
67UPDAT		CA	OCT67
		TS	MPAC
		CA	ONE
		TC	76UPDAT	+3
70UPDAT		CA	OCT70
		TC	71UPDAT	+1
71UPDAT		CA	OCT71
		TS	MPAC
		CA	TWO
		TC	76UPDAT	+3
64UPDAT		CA	11OCT64
		TC	72UPDAT	+1
72UPDAT		CA	OCT72
		TS	MPAC
		CA	THREE
		TC	76UPDAT	+3
76UPDAT		CA	OCT76
		TS	MPAC
		CA	11OCT16
		TS	MPAC	+1
## Page 320
		TC	75UPDAT	+2
75UPDAT		CA	11OCT75
		TS	MPAC
		CA	FLAGWRD2		# TEST IF TIMERS ENABLED
		MASK	BIT5
		EXTEND
		BZF	XACTALM			# NO, RETURN
		TC	BANKCALL
		CADR	UPPART2
OCT73		OCT	00073
OCT67		OCT	00067
OCT70		OCT	00070
OCT71		OCT	00071
11OCT64		OCT	00064
OCT72		OCT	00072
OCT76		OCT	00076
11OCT16		OCT	16
11OCT75		OCT	00075
