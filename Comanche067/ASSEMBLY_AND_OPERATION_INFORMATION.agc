




### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	ASSEMBLY_AND_OPERATION_INFORMATION.agc
## Purpose:	Part of the source code for Comanche 67 (Colossus 2C),
##		the one-and-only software release for the Apollo Guidance 
##		Computer (AGC) of Apollo 12's command module.  In the 
##		absence of a contemporary assembly listing for Comanche 67, 
##		the intention is to reconstruct the source code from a 
##		Comanche 55 (Colossus 2A, Apollo 11 CM) baseline and 
##		contemporary documentation describing the differences 
##		between the two.  Page numbers listed in the program 
##		comments follow Comanche 55 unless otherwise noted.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Mod history: 2020-12-25 RSB	Began adaptation from Comanche 55 baseline.
##				Added fix for PCR801.1.

## Page 2

# ASSEMBLY AND OPERATIONS INFORMATION
# TAGS FOR RELATIVE SETLOC AND BLANK BANK CARDS
# SUBROUTINE CALLS
#	COMERASE
#		ERASABLE ASSIGNMENTS
#	COMAID
#		INTERRUPT LEAD INS
#		T4RUPT PROGRAM
#		DOWNLINK LISTS
#		FRESH START AND RESTART
#		RESTART TABLES
#		SXTMARK
#		EXTENDED VERBS
#		PINBALL NOUN TABLES
#		CSM GEOMETRY
#		IMU COMPENSATION PACKAGE
#		PINBALL GAME BUTTONS AND LIGHTS
#		R60,R62
#		ANGLFIND
#		GIMBAL LOCK AVOIDANCE
#		KALCMANU STEERING
#		SYSTEM TEST STANDARD LEAD INS
#		IMU CALIBRATION AND ALIGNMENT
#	COMEKISS
#		GROUND TRACKING DETERMINATION PROGRAM - P21
#		P34-P35, P74-P75
#		R31
#		P76
#		R30
#		STABLE ORBIT - P38-P39
#	TROUBLE
#		P11
#		TPI SEARCH
#		P20-P25
#		P30,P37
#		P32-P33, P72-P73
#		P40-P47
#		P51-P53
#		LUNAR AND SOLAR EPHEMERIDES SUBROUTINES
#		P61-P67
#		SERVICER207
#		ENTRY LEXICON
#		REENTRY CONTROL
#		CM BODY ATTITUDE
#		P37,P70
#		S-BAND ANTENNA FOR CM
#	TVCDAPS
#		TVC INITIALIZE

## Page 3

#		TVCEXECUTIVE
#		TVCMASSPROP
#		TVCRESTARTS
#		TVCDAPS
#		TVCSTROKETEST
#		TVCROLLDAP
#		MYSUBS
#		RCS-CSM DIGITAL AUTOPILOT
#		AUTOMATIC MANEUVERS
#		RCS-CSM DAP EXECUTIVE PROGRAMS
#		JET SELECTION LOGIC
#		CM ENTRY DIGITAL AUTOPILOT
#	CHIEFTAN
#		DOWN-TELEMETRY PROGRAM
#		INTER-BANK COMMUNICATION
#		INTERPRETER
#		FIXED-FIXED CONSTANT POOL
#		INTERPRETIVE CONSTANTS
#		SINGLE PRECISION SUBROUTINES
#		EXECUTIVE
#		WAITLIST
#		LATITUDE LONGITUDE SUBROUTINES
#		PLANETARY INERTIAL ORIENTATION
#		MEASUREMENT INCORPORATION
#		CONIC SUBROUTINES
#		INTEGRATION INITIALIZATION
#		ORBITAL INTEGRATION
#		INFLIGHT ALIGNMENT ROUTINES
#		POWERED FLIGHT SUBROUTINES
#		TIME OF FREE FALL
#		STAR TABLES
#		AGC BLOCK TWO SELF-CHECK
#		PHASE TABLE MAINTENANCE
#		RESTARTS ROUTINE
#		IMU MODE SWITCHING ROUTINES
#		KEYRUPT, UPRUPT
#		DISPLAY INTERFACE ROUTINES
#		SERVICE ROUTINES
#		ALARM AND ABORT
#		UPDATE PROGRAM
#		RTB OP CODES
# SYMBOL TABLE LISTING
# UNREFERENCED SYMBOL LISTING
# ERASABLE & EQUALS CROSS-REFERENCE TABLE
# SUMMARY OF SYMBOL TABLE LISTINGS
# MEMORY TYPE & AVAILABLITY DISPLAY
# COUNT TABLE
# PARAGRAPHS GENERATED FOR THIS ASSEMBLY

## Page 4

# OCTAL LISTING
# OCCUPIED LOCATIONS TABLE
# SUBROS CALLED & PROGRAM STATUS

## Page 5
# VERB LIST FOR CSM

# REGULAR VERBS

# 00	NOT IN USE
# 01	DISPLAY OCTAL COMP 1 IN R1
# 02	DISPLAY OCTAL COMP 2 IN R1
# 03	DISPLAY OCTAL COMP 3 IN R1
# 04	DISPLAY OCTAL COMP 1,2 IN R1,R2
# 05	DISPLAY OCTAL COMP 1,2,3 IN R1,R2,R3
# 06	DISPLAY DECIMAL IN R1 OR R1,R2 OR R1,R2,R3
# 07	DISPLAY DP DECIMAL IN R1,R2 (TEST ONLY)
# 08
# 09
# 10
# 11	MONITOR OCTAL COMP 1 IN R1
# 12 	MONITOR OCTAL COMP 2 IN R1
# 13	MONITOR OCTAL COMP 3 IN R1
# 14	MONITOR OCTAL COMP 1,2 IN R1,R2
# 15	MONITOR OCTAL COMP 1,2,3 IN R1,R2,R3
# 16	MONITOR DECIMAL IN R1 OR R1,R2 OR R1,R2,R3
# 17	MONITOR DP DECIMAL IN R1,R2 (TEST ONLY)
# 18
# 19
# 20
# 21	LOAD COMPONENT 1 INTO R1
# 22	LOAD COMPONENT 2 INTO R2
# 23	LOAD COMPONENT 3 INTO R3
# 24	LOAD COMPONENT 1,2 INTO R1,R2
# 25	LOAD COMPONENT 1,2,3 INTO R1,R2,R3
# 26
# 27	DISPLAY FIXED MEMORY
# 28
# 29
# 30	REQUEST EXECUTIVE
# 31	REQUEST WAITLIST
# 32	RECYCLE PROGRAM
# 33	PROCEED WITHOUT DSKY INPUTS
# 34	TERMINATE FUNCTION
# 35	TEST LIGHTS
# 36	REQUEST FRESH START
# 37	CHANGE PROGRAM (MAJOR MODE)
# 38
# 39

## Page 6

# EXTENDED VERBS

# 40	ZERO CDU-S
# 41	COARSE ALIGN CDU-S
# 42	FINE ALIGN IMU-S
# 43	LOAD IMU ATT ERROR METERS
# 44	SET   SURFACE FLAG
# 45	RESET SURFACE FLAG
# 46	ESTABLISH G+C CONTROL
# 47	MOVE LM STATE VECTOR INTO CM STATE VECTOR.
# 48	REQUEST DAP DATA LOAD ROUTINE (R03)
# 49	REQUEST CREW DEFINED MANEUVER ROUTINE (R62)
# 50	PLEASE PERFORM
# 51	PLEASE MARK
# 52	MARK ON OFFSET LANDING SITE
# 53	PLEASE PERFORM ALTERNATE LOS MARK
# 54	REQUEST RENDEZVOUS BACKUP SIGHTING MARK ROUTINE (R23)
# 55	INCREMENT AGC TIME (DECIMAL)
# 56	TERMINATE TRACKING (P20 + P25)
# 57	REQUEST RENDEZVOUS SIGHTING MARK ROUTINE (R21)
# 58	RESET STICK FLAG
# 59	PLEASE CALIBRATE
# 60	SET ASTRONAUT TOTAL ATTITUDE (N17) TO PRESENT ATTITUDE
# 61	DISPLAY DAP ATTITUDE ERROR
# 62	DISPLAY TOTAL ATTITUDE ERROR (WRT N22 (THETAD))
# 63	DISPLAY TOTAL ASTRONAUT ATTITUDE ERROR (WRT N17 (CPHIX))
# 64	REQUEST S-BAND ANTENNA ROUTINE
# 65	OPTICAL VERIFICATION OF PRELAUNCH ALIGNMENT
# 66	VEHICLES ARE ATTACHED.  MOVE THIS VEHICLE STATE TO OTHER VEHICLE.
# 67
# 68	CSM STROKE TEST ON
# 69	CAUSE RESTART
# 70	UPDATE LIFTOFF TIME
# 71	UNIVERSAL UPDATE - BLOCK ADR
# 72	UNIVERSAL UPDATE - SINGLE ADR
# 73	UPDATE AGC TIME (OCTAL)
# 74	INITIALIZE ERASABLE DUMP VIA DOWNLINK
# 75	BACKUP LIFTOFF
# 76	SET PREFERRED ATTITUDE FLAG
# 77	RESET PREFERRED ATTITUDE FLAG
# 78	UPDATE PRELAUNCH AZIMUTH
# 79	REQUEST LUNAR LANDMARK SELECTION ROUTINE (R35)
# 80	UPDATE LEM STATE VECTOR
# 81	UPDATE CSM STATE VECTOR
# 82	REQUEST ORBIT PARAM DISPLAY (R30)
# 83	REQUEST REND  PARAM DISPLAY (R31)
# 84	START TARGET DELTA V (R32)
# 85	REQUEST RENDEZVOUS PARAMETER DISPLAY NO. 2 (R34)
# 86	REJECT RENDEZVOUS BACKUP SIGHTING MARK
# 87	SET VHF RANGE FLAG

## Page 7

# 88	RESET VHF RANGE FLAG
# 89	REQUEST RENDEZVOUS FINAL ATTITUDE ROUTINE (R63)
# 90	REQUEST RENDEZVOUS OUT OF PLANE DISPLAY ROUTINE (R36)
# 91	DISPLAY BANK SUM
# 92	OPERATE IMU PERFORMANCE TEST (P07)
# 93	ENABLE W MATRIX INITIALIZATION
# 94	PERFORM CYSLUNAR ATTITUDE MANEUVER (P23)
# 95	NO UPDATE OF EITHER STATE VECTOR (P20 OR P22)
# 96	TERMINATE INTEGRATION AND GO TO P00
# 97	PERFORM ENGINE FAIL PROCEDURE
# 98	ENABLE TRANSLUNAR INJECT
# 99	PLEASE ENABLE ENGINE

## Page 8
# IN THE FOLLOWING NOUN LIST THE :NO LOAD: RESTRICTION MEANS THE NOUN
# CONTAINS AT LEAST ONE COMPONENT WHICH CANNOT BE LOADED, I.E. OF
# SCALE TYPE L (MIN/SEC) OR PP (2 INTEGERS).

# IN THIS CASE VERBS 24 AND 25 ARE NOT ALLOWED, BUT VERBS 21, 22 OR 23
# MAY BE USED TO LOAD ANY OF THE NOUN:S COMPONENTS WHICH ARE NOT OF THE
# ABOVE SCALE TYPES.

# THE :DEC ONLY: RESTRICTION MEANS ONLY DECIMAL OPERATION IS ALLOWED ON
# EVERY COMPONENT IN THENOUN.  (NOTE THAT :NO LOAD: IMPLIES :DEC ONLY:.)

# NORMAL NOUNS				   COMPONENTS	SCALE AND DECIMAL POINT	RESTRICTIONS
#
# 00	NOT IN USE
# 01	SPECIFY MACHINE ADDRESS (FRACTIONAL)	3COMP	.XXXXX FOR EACH
# 02	SPECIFY MACHINE ADDRESS (WHOLE)		3COMP	XXXXX. FOR EACH
# 03	SPECIFY MACHINE ADDRESS (DEGREES)	3COMP	XXX.XX DEG FOR EACH
# 04	SPARE
# 05	ANGULAR ERROR/DIFFERENCE		1COMP	XXX.XX DEG
# 06	OPTION CODE				2COMP	OCTAL ONLY FOR EACH
# LOADING NOUN 07 WILL SET OR RESET SELECTED BITS IN ANY ERASABLE REGISTER
# 07	ECADR OF WORD TO BE MODIFIED		3COMP	OCTAL ONLY FOR EACH
#	ONES FOR BITS TO BE MODIFIED
#	1 TO SET OR 0 TO RESET SELECTED BITS
# 08	ALARM DATA				3COMP	OCTAL ONLY FOR EACH
# 09	ALARM CODES				3COMP	OCTAL ONLY FOR EACH
# 10	CHANNEL TO BE SPECIFIED			1COMP	OCTAL ONLY
# 11	TIG OF CSI				3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 12	OPTION CODE				2COMP	OCTAL ONLY FOR EACH
#	(USED BY EXTENDED VERBS ONLY)
# 13	TIG OF CDH				3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 14	SPARE
# 15	INCREMENT MACHINE ADDRESS		1COMP	OCTAL ONLY
# 16	TIME OF EVENT				3COMP	00XXX. HRS		DEC ONLY
#	(USED BY EXTENDED VERBS ONLY)			000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 17	ASTRONAUT TOTAL ATTITUDE		3COMP	XXX.XX DEG FOR EACH
# 18	AUTO MANEUVER BALL ANGLES		3COMP	XXX.XX DEG FOR EACH
# 19	BYPASS ATTITUDE TRIM MANEUVER		3COMP	XXX.XX DEG FOR EACH
# 20	ICDU ANGLES				3COMP	XXX.XX DEG FOR EACH
# 21	PIPAS					3COMP	XXXXX. PULSES FOR EACH
# 22	NEW ICDU ANGLES				3COMP	XXX.XX DEG FOR EACH
# 23	SPARE
# 24	DELTA TIME FOR AGC CLOCK		3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 25	CHECKLIST				3COMP	XXXXX. FOR EACH
#	(USED WITH PLEASE PERFORM ONLY)

## Page 9

# 26	PRIORITY/DELAY, ADRES, BBCON		3COMP	OCTAL ONLY FOR EACH
# 27	SELF TEST ON/OFF SWITCH			1COMP	XXXXX.
# 28	SPARE
# 29	XSM LAUNCH AZIMUTH			1COMP	XXX.XX DEG		DEC ONLY

## Page 10

# 30	TARGET CODES				3COMP	XXXXX. FOR EACH
# 31	TIME OF LANDING SITE			3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
# 							0XX.XX SEC
# 32	TIME FROM PERIGEE			3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 33	TIME OF IGNITION			3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 34	TIME OF EVENT				3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 35	TIME FROM EVENT				3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 36	TIME OF AGC CLOCK			3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 37	TIG OF TPI				3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 38	TIME OF STATE VECTOR			3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 39	DELTA TIME FOR TRANSFER			3COMP	00XXX. HRS		DEC ONLY
#							000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC

## Page 11

# MIXED NOUNS				   COMPONENTS	SCALE AND DECIMAL POINT	RESTRICTIONS
#
# 40	TIME FROM IGNITION/CUTOFF		3COMP	XXBXX  MIN/SEC		NO LOAD, DEC ONLY
#	VG,						XXXX.X FT/SEC
#	DELTA V (ACCUMULATED)				XXXX.X FT/SEC
# 41	TARGET	AZIMUTH,			2COMP	XXX.XX DEG
#		ELEVATION				XX.XXX DEG
# 42	APOGEE,					3COMP	XXXX.X NAUT MI		DEC ONLY
#	PERIGEE,					XXXX.X NAUT MI
#	DELTA V (REQUIRED)				XXXX.X FT/SEC
# 43	LATITUDE,				3COMP	XXX.XX DEG		DEC ONLY
#	LONGITUDE,					XXX.XX DEG
#	ALTITUDE					XXXX.X NAUT MI
# 44	APOGEE,					3COMP	XXXX.X NAUT MI		NO LOAD, DEC ONLY
#	PERIGEE,					XXXX.X NAUT MI
#	TFF						XXBXX  MIN/SEC
# 45	MARKS (VHF - OPTICS)			3COMP	+XXBXX			NO LOAD, DEC ONLY
#	TFI OF NEXT BURN				XXBXX  MIN/SEC
#	MGA						XXX.XX DEG
# 46	AUTOPILOT CONFIGURATION			2COMP	OCTAL ONLY FOR EACH
# 47	THIS VEHICLE WEIGHT			2COMP	XXXXX. LBS		DEC ONLY
#	OTHER VEHICLE WEIGHT				XXXXX. LBS
# 48	PITCH TRIM				2COMP	XXX.XX DEG		DEC ONLY
#	YAW TRIM,					XXX.XX DEG
# 49	DELTA R					3COMP	XXXX.X NAUT MI		DEC ONLY
#	DELTA V						XXXX.X FT/SEC
#	VHF OR OPTICS CODE				XXXXX.
# 50	SPLASH ERROR,				3COMP	XXXX.X NAUT MI		NO LOAD, DEC ONLY
#	PERIGEE,					XXXX.X NAUT MI
#	TFF						XXBXX  MIN/SEC
# 51	S-BAND ANTENNA ANGLES	PITCH		2COMP	XXX.XX DEG		DEC ONLY
#				YAW			XXX.XX DEG
# 52	CENTRAL ANGLE OF ACTIVE VEHICLE		1COMP	XXX.XX DEG
# 53	RANGE,					3COMP	XXX.XX NAUT MI		DEC ONLY
#	RANGE RATE,					XXXX.X FT/SEC
#	PHI						XXX.XX DEG
# 54	RANGE,					3COMP	XXX.XX NAUT MI		DEC ONLY
#	RANGE RATE,					XXXX.X FT/SEC
#	THETA						XXX.XX DEG
# 55	PERIGEE CODE				3COMP	XXXXX.			DEC ONLY
#	ELEVATION ANGLE					XXX.XX DEG
#	CENTRAL ANGLE OF PASSIVE VEHICLE		XXX.XX DEG
# 56	REENTRY ANGLE,				2COMP	XXX.XX DEG		DEC ONLY
#	DELTA V						XXXXX. FT/SEC
# 57	DELTA R					1COMP	XXXX.X NAUT MI		DEC ONLY
# 58	PERIGEE ALT (POST TPI)			3COMP	XXXX.X NAUT MI		DEC ONLY
#	DELTA V TPI					XXXX.X FT/SEC
#	DELTA V TPF					XXXX.X FT/SEC
# 59	DELTA VELOCITY LOS			3COMP	XXXX.X FT/SEC FOR EA.	DEC ONLY
# 60	GMAX,					3COMP	XXX.XX G		DEC ONLY
## Page 12
#	VPRED,						XXXXX. FT/SEC
#	GAMMA EI					XXX.XX DEG
# 61	IMPACT LATITUDE,			3COMP	XXX.XX DEG		DEC ONLY
#	IMPACT LONGITUDE,				XXX.XX DEG
#	HEADS UP/DOWN					+/- 00001
# 62	INERTIAL VEL MAG (VI),			3COMP	XXXXX. FT/SEC		DEC ONLY
#	ALT RATE CHANGE (HDOT),				XXXXX. FT/SEC
#	ALT ABOVE PAD RADIUS (H)			XXXX.X NAUT MI
# 63	RANGE 297,431 TO SPLASH (RTGO),		3COMP	XXXX.X NAUT MI		NO LOAD, DEC ONLY
#	PREDICTED INERT VEL (VIO),			XXXXX. FT/SEC
#	TIME FROM 297,431 (TFE)				XXBXX  MIN/SEC
# 64	DRAG ACCELERATION,			3COMP	XXX.XX G		DEC ONLY
#	INERTIAL VELOCITY (VI),				XXXXX. FT/SEC
#	RANGE TO SPLASH					XXXX.X NAUT MI
# 65	SAMPLED AGC TIME			3COMP	00XXX. HRS		DEC ONLY
#	(FETCHED IN INTERRUPT)				000XX. MIN		MUST LOAD 3 COMPS
#							0XX.XX SEC
# 66	COMMAND BANK ANGLE (BETA),		3COMP	XXX.XX DEG		DEC ONLY
#	CROSS RANGE ERROR,				XXXX.X NAUT MI
#	DOWN RANGE ERROR				XXXX.X NAUT MI
# 67	RANGE TO TARGET,			3COMP	XXXX.X NAUT MI		DEC ONLY
#	PRESENT LATITUDE,				XXX.XX DEG
#	PRESENT LONGITUDE				XXX.XX DEG
# 68	COMMAND BANK ANGLE (BETA),		3COMP	XXX.XX DEG		DEC ONLY
#	INERTIAL VELOCITY (VI),				XXXXX. FT/SEC
#	ALT RATE CHANGE (RDOT)				XXXXX. FT/SEC
# 69	BETA					3COMP	XXX.XX DEG		DEC ONLY
#	DL						XXX.XX G
#	VL						XXXXX. FT/SEC
# 70	STAR CODE,				3COMP	OCTAL ONLY
#	LANDMARK DATA,					OCTAL ONLY
#	HORIZON DATA					OCTAL ONLY
# 71	STAR CODE				3COMP	OCTAL ONLY
#	LANDMARK DATA					OCTAL ONLY
#	HORIZON DATA					OCTAL ONLY
# 72	DELT ANG				3COMP	XXX.XX DEG		DEC ONLY
# 73	ALTITUDE				3COMP	XXXXXB. NAUT MI
#	VELOCITY					XXXXX.  FT/SEC
#	FLIGHT PATH ANGLE				XXX.XX  DEG
# 74	COMMAND BANK ANGLE (BETA)		3COMP	XXX.XX DEG
#	INERTIAL VELOCITY (VI)				XXXXX. FT/SEC
#	DRAG ACCELERATION				XXX.XX G
# 75	DELTA ALTITUDE CDH			3COMP	XXXX.X NAUT MI		NO LOAD, DEC ONLY
#	DELTA TIME (CDH-CSI OR TPI-CDH)			XXBXX  MIN/SEC
#	DELTA TIME (TPI-CDH OR TPI-NOMTPI)		XXBXX  MIN/SEC
# 76	SPARE
# 77	SPARE
# 78	SPARE
# 79	SPARE
# 80	TIME FROM IGNITION/CUTOFF		3COMP	XXBXX  MIN/SEC		NO LOAD, DEC ONLY

## Page 13

#	VG						XXXXX. FT/SEC
#	DELTA V (ACCUMULATED)				XXXXX. FT/SEC
# 81	DELTA V (LV)				3COMP	XXXX.X FT/SEC FOR EACH	DEC ONLY
# 82	DELTA V (LV)				3COMP	XXXX.X FT/SEC FOR EACH	DEC ONLY
# 83	DELTA V (BODY)				3COMP	XXXX.X FT/SEC FOR EACH	DEC ONLY
# 84	DELTA V (OTHER VEHICLE)			3COMP	XXXX.X FT/SEC FOR EACH	DEC ONLY
# 85	VG (BODY)				3COMP	XXXX.X FT/SEC FOR EACH	DEC ONLY
# 86	DELTA V (LV)				3COMP	XXXXX. FT/SEC FOR EACH	DEC ONLY
# 87	MARK DATA	SHAFT,			2COMP	XXX.XX DEG
#			TRUNION				XX.XXX DEG
# 88	HALF UNIT SUN OR PLANET VECTOR		3COMP	.XXXXX FOR EACH		DEC ONLY
# 89	LANDMARK	LATITUDE,		3COMP	XX.XXX DEG		DEC ONLY
#			LONGITUDE/2,			XX.XXX DEG
#			ALTITUDE			XXX.XX NAUT MI
# 90	Y					3COMP	XXX.XX NM		DEC ONLY
#	Y DOT						XXXX.X FPS
#	PSI						XXX.XX DEG
# 91	OCDU ANGLES	SHAFT,			2COMP	XXX.XX DEG
#			TRUNION				XX.XXX DEG
# 92	NEW OPTICS ANGLES	SHAFT,		2COMP	XXX.XX DEG
#				TRUNION			XX.XXX DEG
# 93	DELTA GYRO ANGLES			3COMP	XX.XXX DEG FOR EACH
# 94	NEW OPTICS ANGLES	SHAFT		2COMP	XXX.XX DEG
#				TRUNNION		XX.XXX DEG
# 95	PREFERRED ATTITUDE ICDU ANGLES		3COMP	XXX.XX DEG FOR EACH
# 96	+X-AXIS ATTITUDE ICDU ANGLES		3COMP	XXX.XX DEG FOR EACH
# 97	SYSTEM TEST INPUTS			3COMP	XXXXX. FOR EACH
# 98	SYSTEM TEST RESULTS AND INPUTS		3COMP	XXXXX.
#							.XXXXX
#							XXXXX.
# 99	RMS IN POSITION				3COMP	XXXXX.FT		DEC ONLY
#	RMS IN VELOCITY					XXXX.X FT/SEC
#	RMS OPTION					XXXXX.

## Page 14

# REGISTERS AND SCALING FOR NORMAL NOUNS
#
# NOUN	REGISTER		SCALE TYPE
#
# 00	NOT IN USE
# 01	SPECIFY ADDRESS		B
# 02	SPECIFY ADDRESS		C
# 03	SPECIFY ADDRESS		D
# 04	SPARE
# 05		DSPTEM1		H
# 06		OPTION1		A
# 07		XREG		A
# 08		ALMCADR		A
# 09		FAILREG		A
# 10	SPECIFY CHANNEL		A
# 11		TCSI		K
# 12		OPTIONX		A
# 13		TCDH		K
# 14	SPARE
# 15	INCREMENT ADDRESS	A
# 16		DSPTEMX		C
# 17		CPHIX		D
# 18		THETAD		D
# 19		THETAD		D
# 20		CDUX		D
# 21		PIPAX		C
# 22		THETAD		D
# 23	SPARE
# 24		DSPTEM2 +1	K
# 25		DSPTEM1		C
# 26		DSPTEM1		A
# 27		SMODE		C
# 28	SPARE
# 29		DSPTEM1		D
# 30		DSPTEM1		C
# 31		DSPTEM1		K
# 32		-TPER		K
# 33		TIG		K
# 34		DSPTEM1		K
# 35		TTOGO		K
# 36		TIME2		K
# 37		TTPI		K
# 38		TET		K
# 39		T3TOT4		K

## Page 15

# REGISTERS AND SCALING FOR MIXED NOUNS
#
# NOUN	COMP	REGISTER	SCALE TYPE
#
# 40	1	TTOGO		L
#	2	VGDISP		S
#	3	DVTOTAL		S
# 41	1	DSPTEM1		D
#	2	DSPTEM1 +1	E
# 42	1	HAPO		Q
#	2	HPER		Q
#	3	VGDISP		S
# 43	1	LAT		H
#	2	LONG		H
#	3	ALT		Q
# 44	1	HAPOX		Q
#	2	HPERX		Q
#	3	TFF		L
# 45	1	VHFCNT		PP
#	2	TTOGO		L
#	3	+MGA		H
# 46	1	DAPDATR1	A
#	2	DAPDATR2	A
# 47	1	CSMMASS		KK
#	2	LEMMASS		KK
# 48	1	PACTOFF		FF
#	2	YACTOFF		FF
# 49	1	N49DISP		Q
#	2	N49DISP +2	S
#	3	N49DISP +4	C
# 50	1	RSP-RREC	LL
#	2	HPERX		Q
#	3	TFF		L
# 51	1	RHOSB		H
#	2	GAMMASB		H
# 52	1	ACTCENT		H
# 53	1	RANGE		JJ
#	2	RRATE		S
# 	3	RTHETA		H
# 54	1	RANGE		JJ
#	2	RRATE		S
# 	3	RTHETA		H
# 55	1	NN1		C
# 	2	ELEV		H
#	3	CENTANG		H
# 56	1	RTEGAM2D	H
#	2	RTEDVD		P
# 57	1	DELTAR		Q
# 58	1	POSTTPI		Q
#	2	DELVTPI		S

## Page 16

#	3	DELVTPF		S
# 59	1	DVLOS		S
#	2	DVLOS +2	S
#	3	DVLOS +4	S
# 60	1	GMAX		T
#	2	VPRED		P
#	3	GAMMAEI		H
# 61	1	LAT (SPL)	H
#	2	LNG (SPL)	H
#	3	HEADSUP		C
# 62	1	VMAGI		P
#	2	HDOT		P
#	3	ALTI		Q
# 63	1	RTGO		LL
#	2	VIO		P
#	3	TTE		L
# 64	1	D		MM
#	2	VMAGI		P
#	3	RTGON64		LL
# 65	1	SAMPTIME	K
#	2	SAMPTIME	K
#	3	SAMPTIME	K
# 66	1	ROLLC		H
#	2	XRNGERR		VV
#	3	DNRNGERR	LL
# 67	1	RTGON67		LL
#	2	LAT		H
#	3	LONG		H
# 68	1	ROLLC		H
#	2	VMAGI		P
#	3	RDOT		UU
# 69	1	ROLLC		H
#	2	Q7		MM
#	3	VL		UU
# 70	1	STARCODE	A
#	2	LANDMARK	A
#	3	HORIZON		A
# 71	1	STARCODE	A
#	2	LANDMARK	A
#	3	HORIZON		A
# 72	1	THETZERO	H
# 73	1	P21ALT		Q (MEMORY/100 TO DISPLAY TENS N.M.)
#	2	P21VEL		P
#	3	P21GAM		H
# 74	1	ROLLC		H
#	2	VMAGI		P
#	3	D		MM
# 75	1	DIFFALT		Q
#	2	T1TOT2		L
#	3	T2TOT3		L

## Page 17

# 76	SPARE
# 77	SPARE
# 78	SPARE
# 79	SPARE
# 80	1	TTOGO		L
#	2	VGDISP		P
#	3	DVTOTAL		P
# 81	1	DELVLVC		S
#	2	DELVLVC +2	S
#	3	DELVLVC +4	S
# 82	1	DELVLVC		S
#	2	DELVLVC +2	S
#	3	DELVLVC +4	S
# 83	1	DELVIMU		S
#	2	DELVIMU +2	S
#	3	DELVIMU +4	S
# 84	1	DELVOV		S
#	2	DELVOV +2	S
#	3	DELVOV +4	S
# 85	1	VGBODY		S
#	2	VGBODY +2	S
#	3	VGBODY +4	S
# 86	1	DELVLVC		P
#	2	DELVLVC +2	P
#	3	DELVLVC +4	P
# 87	1	MRKBUF1 +3	D
#	2	MRKBUF1 +5	J
# 88	1	STARSAV3	ZZ
#	2	STARSAV3 +2	ZZ
#	3	STARSAV3 +4	ZZ
# 89	1	LANDLAT		G
#	2	LANDLONG	G
#	3	LANDALT		JJ
# 90	1	RANGE		JJ
#	2	RRATE		S
#	3	RTHETA		H
# 91	1	CDUS		D
#	2	CDUT		J
# 92	1	SAC		D
#	2	PAC		J
# 93	1	OGC		G
#	2	OGC +2		G
#	3	OGC +4		G
# 94	1	MRKBUF1 +3	D
#	2	MRKBUF1 +5	J
# 95	1	PRAXIS		D
#	2	PRAXIS +1	D
#	3	PRAXIS +2	D
# 96	1	CPHIX		D
#	2	CPHIX +1	D

## Page 18

#	3	CPHIX +2	D
# 97	1	DSPTEM1		C
#	2	DSPTEM1 +1	C
# 	3	DSPTEM1 +2	C
# 98	1	DSPTEM2		C
#	2	DSPTEM2 +1	B
#	3	DSPTEM2 +2	C
# 99	1	WWPOS		XX
#	2	WWVEL		YY
#	3	WWOPT		C

## Page 19

# NOUN SCALES AND FORMATS
#
# -SCALE TYPE-				PRECISION
# UNITS			DECIMAL FORMAT		--	AGC FORMAT
# ------------		--------------		--	----------
#
# -A-
# OCTAL			XXXXX			SP	OCTAL
#
# -B-								 -14
# FRACTIONAL		.XXXXX			SP	BIT 1 = 2    UNITS
#			(MAX .99996)
#
# -C-
# WHOLE			XXXXX.			SP	BIT 1 = 1 UNIT
#			(MAX 16383.)
#
# -D-								     15
# CDU DEGREES		XXX.XX DEGREES		SP	BIT 1 = 360/2   DEGREES
#			(MAX 359.99)			(USES 15 BITS FOR MAGNI-
#							TUDE AND 2-S COMP.)
#
# -E-								    14
# ELEVATION DEGREES	XX.XXX DEGREES		SP	BIT 1 = 90/2   DEGREES
#			(MAX 89.999)
#
# -F-								     14
# DEGREES (180)		XXX.XX DEGREES		SP	BIT 1 = 180/2   DEGREES
#			(MAX 179.99)
#
# -G-
# DP DEGREES (90)	XX.XXX DEGREES		DP	BIT 1 OF LOW REGISTER =
#							     28
#							360/2   DEGREES
#
# -H-
# DP DEGREES (360)	XXX.XX DEGREES		DP	BIT 1 OF LOW REGISTER =
#						             28
#			(MAX 359.99)			360/2   DEGREES
#
# -J-								    15
# Y OPTICS DEGREES	XX.XXX DEGREES		SP	BIT 1 = 90/2   DEGREES
#			(BIAS OF 19.775			(USES 15 BITS FOR MAGNI-
#			DEGREES ADDED FOR		TUDE AND 2-S COMP.)
#			DISPLAY, SUBTRACTED
#			FOR LOAD.)
#			NOTE:  NEGATIVE NUM-
#			BERS CANNOT BE 
#			LOADED.
#
# -K-

## Page 20

# TIME (HR, MIN, SEC)	00XXX. HR		DP	BIT 1 OF LOW REGISTER =
#			000XX. MIN			  -2
#			0XX.XX SEC			10   SEC
#			(DECIMAL ONLY.
#			MAX MIN COMP = 59
#			MAX SEC COMP = 59.99
#			MAX CAPACITY = 745 HRS
#					39 MINS
#					14.55 SECS.
#			WHEN LOADING, ALL 3
#			COMPONENTS MUST BE
#			SUPPLIED.)
#
# -L-
# TIME (MIN/SEC)	XXBXX MIN/SEC		DP	BIT 1 OF LOW REGISTER =
#			(B IS A BLANK			  -2
#			POSITION, DECIMAL		10   SEC
#			ONLY, DISPLAY OR 
#			MONITOR ONLY.  CANNOT
#			BE LOADED.
#			MAX MIN COMP = 59
#			MAX SEC COMP = 59
#			VALUES GREATER THAN
#			59 MIN 59 SEC
#			ARE DISPLAYED AS
#			59 MIN 59 SEC.)
#
# -M-								  -2
# TIME (SEC)		XXX.XX SEC		SP	BIT 1 = 10   SEC
#			(MAX 163.83)
#
# -N-
# TIME (SEC) DP		XXX.XX SEC		DP	BIT 1 OF LOW REGISTER =
#							  -2
#							10   SEC
#
# -P-
# VELOCITY 2		XXXXX. FEET/SEC		DP	BIT 1 OF HIGH REGISTER =
#			(MAX 41994.)			 -7
#							2   METERS/CENTI-SEC
#
# -Q-
# POSITION 4		XXXX.X NAUTICAL MILES	DP	BIT 1 OF LOW REGISTER =
#							2 METERS
#
# -S-
# VELOCITY 3		XXXX.X FT/SEC		DP	BIT 1 OF HIGH REGISTER =
#							 -7
#							2   METERS/CENTI-SEC

## Page 21

# -T-								  -2
# G			XXX.XX G		SP	BIT 1 = 10   G
#			(MAX 163.83)
#
# -FF-
# TRIM DEGREES		XXX.XX DEG.		SP	LOW ORDER BIT = 85.41 SEC
#			(MAX 388.69)			OF ARC
#
# -GG-
# INERTIA		XXXXXBB. SLUG FT SQ	SP	FRACTIONAL PART OF
#			(MAX 07733BB.)			 20     2
#							2   KG M
#
# -II-									    20
# THRUST MOMENT		XXXXXBB. FT LBS		SP	FRACTIONAL PART OF 2
#			(MAX 07733BB.)			NEWTON METER
#
# -JJ-
# POSITION5		XXX.XX NAUT MI		DP	BIT 1 OF LOW REGISTER =
#							2 METERS
#
# -KK-									    16
# WEIGHT2		XXXXX. LBS		SP	FRACTIONAL PART OF 2   KG
#
# -LL-
# POSITION6		XXXX.X NAUT MI		DP	BIT 1 OF LOW REG =
#									    -28
#							(6,373,338)(2(PI))X2
#							-----------------------
#								1852
#							NAUT. MI.
#
# -MM-
# DRAG ACCELERATION	XXX.XX G		DP	BIT 1 OF LOW REGISTER =
#			MAX (024.99)			    -28
#							25X2    G
#
# -PP-
# 2 INTEGERS		+XXBYY			DP	BIT 1 OF HIGH REGISTER =
#			(B IS A BLANK				1 UNIT OF XX
#			POSITION.  DECIMAL		BIT 1 OF LOW REGISTER =
#			ONLY, DISPLAY OR			1 UNIT OF YY
#			MONITOR ONLY.  CANNOT		(EACH REGISTER MUST
#			BE LOADED.)		        CONTAIN A POSITIVE INTEGER
#			(MAX 99B99)			 LESS THAN 100)
#
# -UU-
# VELOCITY/2VS		XXXXX. FEET/SEC		DP	FRACTIONAL PART OF 
#			(MAX 51532.)			2VS FEET/SEC
#							(VS = 25766.1973)

## Page 22

# -VV-
# POSITION8		XXXX.X NAUT MI		DP	BIT 1 OF LOW REGISTER =
#									 -28
#							4 X 6,373,338 X 2
#							--------------------
#								1852
#							NAUT MI
#
# -XX-
# POSITION 9		XXXXX. FEET		DP	BIT 1 OF LOW REGISTER =
#			 				 -9
#							2   METERS
#
# -YY-
# VELOCITY 4		XXXX.X FEET/SEC		DP	FRACTIONAL PART OF
#			(MAX 328.0)			METERS/CENTI-SEC
#
# -ZZ-
# DP FRACTIONAL		.XXXXX			DP	BIT 1 OF HIGH REGISTER =
#							 -14
#							2    UNITS


# THAT-S ALL ON THE NOUNS.

## Page 23

## <b>Reconstruction:<b>  Due to PCR801.1, all alarm codes (17 places) of "ABORT TYPE" have their leading
## digit changed from 0 to 2 (for POODOO) or 3 (for BAILOUT).  There's no way to know whether the 
## list of alarm codes was re-sorted in numerical order in the original Comanche 67 source, or whether
## the list remained in the original sorting order.  In Artemis 71, the list has been re-sorted, so
## we've chosen to do that here as well.
##		
# ALARM CODES FOR 504

# REPORT DEFICIENCIES TO JOHN SUTHERLAND @ MIT 617-864-6900 X1458

# *9		*18						*60					*25  COLUMN
#
# CODE       *	TYPE						SET BY					ALARM ROUTINE
#
# 00110		NO MARK SINCE LAST MARK REJECT			SXTMARK					ALARM
# 00112		MARK NOT BEING ACCEPTED				SXTMARK					ALARM
# 00113		NO INBITS					SXTMARK					ALARM
# 00114		MARK MADE BUT NOT DESIRED			SXTMARK					ALARM
# 00115		OPTICS TORQUE REQUESTWITH SWITCH NOT AT		EXT VERB OPTICS CDU			ALARM
# 			CGC
# 00116		OPTICS SWITCH ALTERED BEFORE 15 SEC ZERO	T4RUPT					ALARM
#			TIME ELAPSED.
# 00117		OPTICS TORQUE REQUEST WITH OPTICS NOT		EXT VERB OPTICS CDU			ALARM
#			AVAILABLE (OPTIND=-0)
# 00120		OPTICS TORQUE REQUEST WITH OPTICS		T4RUPT					ALARM
#			NOT ZEROED
# 00121		CDUS NO GOOD AT TIME OF MARK			SXTMARK					ALARM
# 00122		MARKING NOT CALLED FOR				SXTMARK					ALARM
# 00124		P17 TPI SEARCH - NO SAFE PERICTR HERE.		TPI SEARCH				ALARM
# 00205		BAD PIPA READING				SERVICER				ALARM
# 00206		ZERO ENCODE NOT ALLOWED WITH COARSE ALIGN	IMU MODE SWITCHING			ALARM
# 			+ GIMBAL LOCK
# 00207		ISS TURNON REQUEST NOT PRESENT FOR 90 SEC	T4RUPT					ALARM
# 00210		IMU NOT OPERATING				IMU MODE SWITCH, IMU-2, R02, P51	ALARM,VARALARM
# 00211		COARSE ALIGN ERROR - DRIVE > 2 DEGREES		IMU MODE SWITCH				ALARM
# 00212		PIPA FAIL BUT PIPA IS NOT BEING USED		IMU MODE SWITCH, T4RPT			ALARM
# 00213		IMU NOT OPERATING WITH TURN-ON REQUEST		T4RUPT					ALARM
# 00214		PROGRAM USING IMU WHEN TURNED OFF		T4RUPT					ALARM
# 00215		PREFERRED ORIENTATION NOT SPECIFIED		P52,P54					ALARM
# 00217		BAD RETURN FROM STALL ROUTINES.			CURTAINS				ALARM2
# 00220		IMU NOT ALIGNED - NO REFSMMAT			R02,P51					VARALARM
# 00401		DESIRED GIMBAL ANGLES YIELD GIMBAL LOCK		IMF ALIGN, IMU-2			ALARM
# 00404		TARGET OUT OF VIEW - TRUN ANGLE > 90 DEG	R52					PRIOLARM
# 00405		TWO STARS NOT AVAILABLE				P52,P54					ALARM
# 00406		REND NAVIGATION NOT OPERATING			R21,R23					ALARM
# 00407		AUTO OPTICS REQUEST TRUN ANGLE > 50 DEG.	R52					ALARM
# 00421		W-MATRIX OVERFLOW				INTEGRV					VARALARM
# 00600		IMAGINARY ROOTS ON FIRST ITERATION		P32, P72				VARALARM
# 00601		PERIGEE ALTITUDE LT PMIN1			P32,P72,				VARALARM
# 00602		PERIGEE ALTITUDE LT PMIN2			P32,P72,				VARALARM
# 00603		CSI TO CDH TIME LT PMIN22			P32,P72,P33,P73				VARALARM
# 00604		CDH TO TPI TIME LT PMIN23			P32,P72					VARALARM
# 00605		NUMBER OF ITERATIONS EXCEEDS LOOP MAXIMUM	P32,P72,P37				VARALARM
# 00606		DV EXCEEDS MAXIMUM				P32,P72					VARALARM

## Page 24

# 00611		NO TIG FOR GIVEN ELEV ANGLE			P34,P74					VARALARM
# 00612		STATE VECTOR IN WRONG SPHERE OF INFLUENCE	P37					VARALARM
# 00613		REENTRY ANGLE OUT OF LIMITS			P37					VARALARM
# 00777		PIPA FAIL CAUSED ISS WARNING.			T4RUPT					VARALARM
# 01102		CMC SELF TEST ERROR									ALARM2
# 01105		DOWNLINK TOO FAST				T4RUPT					ALARM
# 01106		UPLINK TOO FAST					T4RUPT					ALARM
# 01107		PHASE TABLE FAILURE.  ASSUME			RESATRT					ALARM
#		ERASABLE MEMORY IS DESTROYED
# 01301		ARCSIN-ARCCOS ARGUMENT TOO LARGE		INTERPRETER				ALARM
# 01407		VG INCREASING					S40.8					ALARM
# 01426		IMU UNSATISFACTORY				P61,P62					ALARM
# 01427		IMU REVERSED					P61,P62					ALARM
# 01520		V37 REQUEST NOT PERMITTED AT THIS TIME		V37					ALARM
# 01600		OVERFLOW IN DRIFT TEST				OPT PRE ALIGN CALIB			ALARM
# 01601       	BAD IMU TORQUE					OPT PRE ALIGN CALIB			ALARM
# 01602		BAD OPTICS DURING VERIFICATION			OPTALGN CALIB (CSM)			ALARM
# 01703		INSUF. TIME FOR INTEG., TIG WAS SLIPPED		R41					ALARM
# 03777		ICDU FAIL CAUSED THE ISS WARNING		T4RUPT					VARALARM
# 04777		ICDU, PIPA FAILS CAUSED THE ISS WARNING		T4RUPT					VARALARM
# 07777		IMU FAIL CAUSED THE ISS WARNING			T4RUPT					VARALARM
# 10777		IMU, PIPA FAILS CAUSED THE ISS WARNING		T4RUPT					VARALARM
# 13777		IMU, ICDU FAILS CAUSED THE ISS WARNING		T4RUPT					VARALARM
# 14777		IMU,ICDU,PIPA FAILS CAUSED THE ISSWNING		T4RUPT					VARALARM
# 20430	     *	INTEG. ABORT DUE TO SUBSURFACE S. V.		ALL CALLS TO INTEG			POODOO
# 20607	     *	NO SOLN FROM TIME-THETA OR TIME-RADIUS		TIMETHET,TIMERAD			POODOO
# 20610      *	LAMBDA LESS THAN UNITY				P37					POODOO
# 21103      *	UNUSED CCS BRANCH EXECUTED			ABORT					POODOO
# 21204      *	NEGATIVE OR ZERO WAITLIST CALL			WAITLIST				POODOO
# 21206      *	SECOND JOB ATTEMPTS TO GO TO SLEEP		PINBALL					POODOO
#			VIA KEYBOARD AND DISPLAY PROGRAM
# 21210	     *	TWO PROGRAMS USING DEVICE AT SAME TIME		IMU MODE SWITCH				POODOO
# 21302      *	SQRT CALLED WITH NEGATIVE ARGUMENT.ABORT	INTERPRETER				POODOO
# 21501	     *	KEYBOARD AND DISPLAY ALARM DURING		PINBALL					POODOO
#			INTERNAL USE (NVSUB). ABORT.
# 21502	     *	ILLEGAL FLASHING DISPLAY			GOPLAY					POODOO
# 21521	     *	P01 ILLEGALLY SELECTED				P01, P07				POODOO
# 31104      *	DELAY ROUTINE BUSY				EXEC					BAILOUT
# 31201	     *	EXECUTIVE OVERFLOW - NO VAC AREAS		EXEC					BAILOUT
# 31202	     *	EXECUTIVE OVERFLOW - NO CORE SETS		EXEC					BAILOUT
# 31203      *	WAITLIST OVERFLOW - TOO MANY TASKS		WAITLIST				BAILOUT
# 31207      *	NO VAC AREA FOR MARKS				SXTMARK					BAILOUT
# 31211      *	ILLEGAL INTERRUPT OF EXTENDED VERB		SXTMARK					BAILOUT
#
# 	     *	INDICATES ABORT TYPE. ALL OTHERS ARE NON-ABORTIVE

## Page 25

# CHECKLIST CODES FOR 504

# PLEASE REPORT ANY DEFICIENCIES IN THIS LIST TO JOHN SUTHERLAND

# *9		*17		*26  COLUMN
#
# R1 CODE	   ACTION TO BE EFFECTED
#
# 00014		KEY IN		FINE ALIGNMENT OPTION
# 00015		PERFORM		CELESTIAL BODY ACQUISITION
# 00016		KEY IN		TERMINATE MARK SEQUENCE
# 00041		SWITCH		CM/SM SEPARATION TO UP
# 00062		SWITCH		AGC POWER DOWN
# 00202		PERFORM		GNCS AUTOMATIC MANEUVER
# 00203		SWITCH		TO CMC-AUTO
# 00204		PERFORM		SPS GIMBAL TRIM
# 00403		SWITCH		OPTICS TO MANUAL OR ZERO
#
#		SWITCH DENOTES CHANGE POSITION OF A CONSOLE SWITCH
#		PERFORM DENOTES START OR END OF A TASK
#		KEY IN DENOTES KEY IN OF DATA THRU THE DSKY

## Page 26

# OPTION CODES FOR 504

# PLEASE REPORT ANY DEFICIENCIES IN THIS LIST TO JOHN SUTHERLAND

# THE SPECIFIED OPTION CODES WILL BE FLASHED IN COMPONENT R1 IN 
# CONJUNCTION WITH VERB04NOUN06 TO REQUEST THE ASTRONAUT TO LOAD INTO
# COMPONENT R2 THE OPTION HE DESIRES.

# *9		*17					*52				*11		*25  COLUMN
#
# OPTION	
# CODE		PURPOSE					INPUT FOR COMPONENT 2		PROGRAM(S)	APPLICABILITY
#
# 00001		SPECIFY IMU ORIENTATION			1=PREF 2=NOM 3=REFSMMAT		P50'S		ALL
# 00002		SPECIFY VEHICLE				1=THIS 2=OTHER			P21,R30		ALL
# 00003		SPECIFY TRACKING ATTITUDE		1=PREFERRED 2=OTHER		R63		ALL
# 00004		SPECIFY RADAR				1=RR 2=LR			R04		SUNDANCE + LUMINARY
# 00005		SPECIFY SOR PHASE			1=FIRST 2=SECOND		P38		COLOSSUS + LUMINARY
# 00006		SPECIFY RR COARSE ALIGN OPTION		1=LOCKON 2=CONTINUOUS DESIG.	V41N72		SUNDANCE + LUMINARY
# 00007		SPECIFY PROPULSION SYSTEM		1=SPS 2=RCS			P37		COLOSSUS
# 00010		SPECIFY ALIGNMENT MODE			0=ANY TIME 1=REFSMMAT +G	P57		LUMINARY	
#							2=TWO BODIES 3=ONE BODY + G
# 00011		SPECIFY SEPARATION MONITOR PHASE	1=DELTAV 2=STATE VECTOR UPDATE	P46		LUMINARY
# 00012		SPECIFY CSM ORBIT OPTION		1=NO ORBIT CHANGE 2=CHANGE	P22		LUMINARY
#							ORBIT TO PASS OVER LM

