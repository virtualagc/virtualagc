### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	INFLIGHT_ALIGNMENT_ROUTINES.agc
## Purpose:	A module for revision 0 of BURST120 (Sunburst). It 
##		is part of the source code for the Lunar Module's
##		(LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2016-09-30 RSB	Created draft version.
##		2016-10-16 RSB	Transcribed.
##		2016-10-31 RSB	Typos.
##		2016-11-01 RSB	More typos.
##		2016-11-02 RSB	More typos.
##		2016-12-05 RSB	Comment-proofing pass with octopus/ProoferComments completed;
##				changes made.
##		2017-03-17 RSB	Comment-text fixes identified in diff'ing
##				Luminary 99 vs Comanche 55.
##		2021-05-30 ABS	Aligned various IAWs to field boundaries.

## Page 340
		BANK	15
		EBANK=	XSM


# CALCGTA COMPUTES THE GYRO TORQUE ANGLES REQUIRED TO BRING THE STABLE MEMBER INTO THE DESIRED ORIENTATION.

# THE INPUT IS THE DESIRED STABLE MEMBER COORDINATES REFERRED TO PRESENT STABLE MEMBER COORDINATES.  THE THREE
# HALF-UNIT VECTORS ARE STORED AT XDC, YDC, AND ZDC.

# THE OUTPUTS ARE THE THREE GYRO TORQUING ANGLES TO BE APPLIED TO THE Y, Z, AND X GYROS AND ARE STORED DP AT IGC,
# MGC, AND OGC RESPECTIVELY. ANGLES ARE SCALED PROPERLY FOR IMUPULSE.


CALCGTA		ITA	DLOAD		# PUSHDOWN 00,02,16D,18D,22D-26D,32D-36D
			S2		# XDC = (XD1 XD2 XD3)
			XDC		# YDC = (YD1 YD2 YD3)
		PDDL	PDDL		# ZDC = (ZD1 ZD2 ZD3)
			ZERODP
			XDC 	+4
		DCOMP	VDEF
		UNIT
		STODL	ZPRIME		# ZP = UNIT(-XD3 0 XD1) = (ZP1 ZP2 ZP3)
			ZPRIME

		SR1
		STODL	SINTH		# SIN(IGC) = ZP1
			ZPRIME 	+4
		SR1
		STCALL	COSTH		# COS(IGC) = ZP3
			ARCTRIG

		STODL	IGC		# Y GYRO TORQUING ANGLE   FRACTION OF REV.
			XDC 	+2
		SR1
		STODL	SINTH		# SIN(MGC) = XD2
			ZPRIME

		DMP	PDDL
			XDC 	+4	# PD00 = (ZP1)(XD3)
			ZPRIME 	+4

		DMP	DSU
			XDC		# MPAC = (ZP3)(XD1)
		STADR
		STCALL	COSTH		# COS(MGC) = MPAC - PD00
			ARCTRIG
			
		STOVL	MGC		# Z GYRO TORQUING ANGLE   FRACTION OF REV.
## Page 341
			ZPRIME
		DOT
			ZDC
		STOVL	COSTH		# COS(OGC) = ZP . ZDC
			ZPRIME
		DOT
			YDC
		STCALL	SINTH		# SIN(OGC) = ZP . YDC
			ARCTRIG

		STCALL	OGC		# X GYRO TORQUING ANGLE   FRACTION OF REV.
			S2

## Page 342
# ARCTRIG COMPUTES AN ANGLE GIVEN THE SINE AND COSINE OF THIS ANGLE.
#
# THE INPUTS ARE SIN/4 AND COS/4 STORED DP AT SINTH AND COSTH.
#
# THE OUTPUT IS THE CALCULATED ANGLE BETWEEN +.5 AND -.5 REVOLUTIONS AND STORED AT THETA. THE OUTPUT IS ALSO
# AVAILABLE AT MPAC.

ARCTRIG		DLOAD	ABS		# PUSHDOWN  16D,18D,20D,22D-26D
			SINTH
		DSU	BMN
			QTSN45		# ABS(SIN/4) - SIN(45)/4
			TRIG1		# IF (-45,45) OR (135,-135)


		DLOAD	SL1		# (45,135) OR (-135,-45)
			COSTH
		ACOS	SIGN
			SINTH
		STORE	THETA		# X = ARCCOS(COS) WITH SIGN(SIN)
		RVQ


TRIG1		DLOAD	SL1		# (-45,45) OR (135,-135)
			SINTH
		ASIN
		STODL	THETA		# X = ARCSIN(SIN) WITH SIGN(SIN)
			COSTH
		BMN
			TRIG2		# IF (135,-135)

		DLOAD	RVQ
			THETA		# X = ARCSIN(SIN)   (-45,45)


TRIG2		DLOAD	SIGN		# (135,-135)
			HALFDP
			SINTH
		DSU
			THETA
		STORE	THETA		# X = .5 WITH SIGN(SIN) - ARCSIN(SIN)
		RVQ			#	           (+) - (+) OR (-) - (-)

## Page 343
# SMNB TRANSFORMS A STAR DIRECTION FROM STABLE MEMBER TO NAVIGATION BASE COORDINATES.

# THE INPUTS ARE  1) THE STAR VECTOR REFERRED TO PRESENT STABLE MEMBER COORDINATES STORED AT LOCATION 32D OF THE
# VAC AREA.  2) THE GIMBAL ANGLES (CDUY,CDUZ,CDUX) STORED AT ALTERNATING LOCATIONS RESPECTIVELY. THE ANGLES ARE
# USUALLY STORED AT LOCATIONS 2,4, AND 6 OF THE MARK VAC AREA. THEY CAN BE STORED AT LOCATIONS 20,22, AND 24 OF
# YOUR JOB VAC AREA.  3) THE BASE ADDRESS OF THE GIMBAL ANGLES STORED SP AT LOCATION S1 OF YOUR JOB VAC AREA.

# THE OUTPUT IS THE STAR VECTOR REFERRED TO NAVIGATION BASE COORDINATES STORED AT 32D OF THE VAC AREA. THE OUTPUT
# IS ALSO AVAILABLE AT MPAC.



SMNB            ITA             CLEAR                           # PUSHDOWN 00,02,04-10D,30D,32D-36D
                                S2
                                NBSMBIT                         # SET NBSMBIT = 0

SMNB1           AXT,1           AXT,2                           # ROTATE X,Z, ABOUT Y
		                4                                               
		                0                                               
                CALL                                            
                		AXISROT                                         

                AXT,1           AXT,2                           # ROTATE Y,X ABOUT Z
                		2                                               
                		4                                               
                CALL                                            
                		AXISROT                                         

                AXT,1           AXT,2                           # ROTATE Z,Y ABOUT X
		                0                                               
		                2                                               
                CALL                                            
                		AXISROT                                         

                GOTO                                            
                		S2                                              
## Page 344

# NBSM TRANSFORMS A STAR DIRECTION FROM NAVIGATION BASE TO STABLE MEMBER COORDINATES.

# THE INPUTS ARE  1) THE STAR VECTOR REFERRED TO NAVIGATION BASE COORDINATES STORED AT LOCATION 32D OF THE VAC
# AREA.  2) THE GIMBAL ANGLES (CDUY,CDUZ,CDUX) STORED AT ALTERNATING LOCATIONS RESPECTIVELY. THE ANGLES ARE 
# USUALLY STORED AT LOCATIONS 2,4, AND 6 OF THE MARK VAC AREA. THEY CAN BE STORED AT LOCATIONS 20,22, AND 24 OF
# YOUR JOB VAC AREA.  3) THE BASE ADDRESS OF THE GIMBAL ANGLES STORED SP AT LOCATION S1 OF YOUR JOB VAC AREA.

# THE OUTPUT IS THE STAR VECTOR REFERRED TO PRESENT STABLE MEMBER COORDINATES STORED AT LOCATION 32D OF THE VAC
# AREA. THE OUTPUT IS ALSO AVAILABLE AT MPAC.



NBSM            ITA             SET                             # PUSHDOWN 00,02,04-10D,30D,32D-36D
                		S2                                              
                		NBSMBIT                         # SET NBSMBIT = 1

NBSM2           AXT,1           AXT,2                           # ROTATE Z,Y ABOUT X
		                0                                               
		                2                                               
                CALL                                            
                		AXISROT                                         

                AXT,1           AXT,2                           # ROTATE Y,X ABOUT Z
		                2                                               
		                4                                               
                CALL                                            
                		AXISROT                                         

                AXT,1           AXT,2                           # ROTATE X,Z, ABOUT Y
		                4                                               
		                0                                               
                CALL                                            
                		AXISROT                                         

                GOTO                                            
                		S2                                              
## Page 345

# AXISROT IS UTILIZED BY THE SMNB AND NBSM ROUTINES. SEE REMARKS ON THESE ROUTINES FOR INPUTS AND OUTPUTS.



AXISROT         XSU,1           SLOAD*                          
		                S1                              #      SMNB         .       NBSM
		                4,1                             # IG    MG    OG    .  OG    MG    IG
                RTB             XAD,1                           
		                CDULOGIC                                        
		                S1                                              
                STORE           30D                             

ACCUROT         COS                                             
                STORE           8D,1                            #              COS(ANGLE)
                DLOAD		SIN
                		30D
                STORE           10D,1                           #              SIN(ANGLE)

                DMP*            SL1                             
                		32D             +4,2                            
                PDDL*           DMP*                            #                  PD0
                		8D,1                            # S3SIN S1SIN S2SIN . S2SIN S1SIN S3SIN
                		32D             +4,2                            

                SL1             PDDL*                           #                  PD2
                		10D,1                           # S3COS S1COS S2COS . S2COS S1COS S3COS

                DMP*            SL1                             #                 MPAC
                		32D             +4,1            # S1SIN S2SIN S3SIN . S3SIN S2SIN S1SIN

                BOFF                                            
		                NBSMBIT                                         
		                AXISROT1                                        

                BDSU            STADR                           #                   .   PD2 - MPAC
                STORE	        32D             +4,2            #                   . S2    S1    S3
                DLOAD*
                		8D,1                                            

                DMP*            SL1                             #                   .      MPAC
                		32D             +4,1            #                   . S3COS S2COS S1COS

                DAD             STADR                           #                   .   PD0 + MPAC
                STORE           32D             +4,1            #                   . S3    S2    S1
                VLOAD		RVQ
                		32D
AXISROT1        DAD             STADR                           #   MPAC + PD2      .
		STORE		32D		+4,2		# S3    S1    S2
		DLOAD*
				8D,1
## Page 346
                DMP*            SL1                             #      MPAC         .
                                32D             +4,1            # S1COS S2COS S3COS .

                DSU             STADR                           #   MPAC - PD0      .
                STORE           32D             +4,1            # S1    S2    S3
                VLOAD		RVQ
                		32D                                             
# CALCGA COMPUTES THE CDU DRIVING ANGLES REQUIRED TO BRING THE STABLE MEMBER INTO THE DESIRED ORIENTATION.

# THE INPUTS ARE  1) THE NAVIGATION BASE COORDINATES REFERRED TO ANY COORDINATE SYSTEM. THE THREE HALF-UNIT
# VECTORS ARE STORED AT XNB,YNB, AND ZNB.  2) THE DESIRED STABLE MEMBER COORDINATES REFERRED TO THE SAME
# COORDINATE SYSTEM ARE STORED AT XSM, YSM, AND ZSM.

# THE OUTPUTS ARE THE THREE CDU DRIVING ANGLES AND ARE STORED SP AT THETAD, THETAD +1, AND THETAD +2.


CALCGA          VLOAD           VXV                             # PUSHDONW 00-04,16D,18D
		                XNB                             # XNB = OGA (OUTER GIMBAL AXIS)
		                YSM                             # YSM = IGA (INNER GIMBAL AXIS)
                UNIT            PUSH                            # PD0 = UNIT(OGA X IGA) = MGA

                DOT             ITA                             
		                ZNB                                             
		                S2                                              
                STOVL           COSTH                           # COS(OG) = MGA . ZNB
		                0                                               
		DOT                                             
		                YNB                                             
                STCALL          SINTH                           # SIN(OG) = MGA . YNB
                		ARCTRIG                                         
                STOVL           OGC                             
                		0                                               

                VXV             DOT                             # PROVISION FOR MG ANGLE OF 90 DEGREES
		                XNB                                             
		                YSM                                             
                SL1                                             
                STOVL           COSTH                           # COS(MG) = IGA . (MGA X OGA)
                		YSM                                             
                DOT                                             
                		XNB                                             
                STCALL          SINTH                           # SIN(MG) = IGA . OGA
                		ARCTRIG                                         
                STORE           MGC                             

                ABS             DSU                             
                		.166...                                         
                BPL                                             
                		GIMLOCK1                       # IF ANGLE GREATER THAN 60 DEGREES
## Page 347

CALCGA1         VLOAD           DOT                             
		                ZSM                                             
		                0                                               
                STOVL           COSTH                           # COS(IG) = ZSM . MGA
                		XSM                                             
                DOT             STADR                           
                STCALL          SINTH                           # SIN(IG) = XSM . MGA
                		ARCTRIG                                         

                STOVL           IGC                             
                		OGC                                             
                RTB                                             
                		V1STO2S                                         
                STCALL          THETAD                          
                		S2                                              

GIMLOCK1        EXIT                 
		TC		FLAG1UP				# SET GIMBAL LOCK FLAG
		OCT		200                           
                TC              ALARM                           
                OCT             00401                           
                TC              INTPRET                         
                GOTO                                            
                		CALCGA1                                         
## Page 348

# AXISGEN COMPUTES THE COORDINATES OF ONE COORDINATE SYSTEM REFERRED TO ANOTHER COORDINATE SYSTEM.

# THE INPUTS ARE  1) THE STAR1 VECTOR REFERRED TO COORDINATE SYSTEM A STORED AT STARAD.  2) THE STAR2 VECTOR
# REFERRED TO COORDINATE SYSTEM A STORED AT STARAD +6.  3) THE STAR1 VECTOR REFERRED TO COORDINATE SYSTEM B STORED
# AT LOCATION 6 OF THE VAC AREA.  4) THE STAR2 VECTOR REFERRED TO COORDINATE SYSTEM B STORED AT LOCATION 12D OF
# THE VAC AREA.

# THE OUTPUT DEFINES COORDINATE SYSTEM A REFERRED TO COORDINATE SYSTEM B. THE THREE HALF-UNIT VECTORS ARE STORED
# AT LOCATIONS XDC, XDC +6, XDC +12D, AND STARAD, STARAD +6, STARAD +12D.


AXISGEN         AXT,1           SSP                             # PUSHDOWN 00-22D,24D-28D,30D
		                STARAD          +6                              
		                S1                                              
		                STARAD          -6                              

AXISGEN1        VLOAD*          VXV*                            # 06D   UA = S1
		                STARAD          +12D,1          #       STARAD +00D     UB = S1
		                STARAD          +18D,1                          
                UNIT                                            # 12D   VA = UNIT(S1 X S2)
                STORE	        STARAD          +18D,1          #       STARAD +06D     VB = UNIT(S1 X S2)
                VLOAD*
                		STARAD          +12D,1                          

                VXV*            VSL1                            
                		STARAD          +18D,1          # 18D   WA = UA X VA
                STORE           STARAD          +24D,1          #       STARAD +12D     WB = UB X VB

                TIX,1                                           
                		AXISGEN1                                        

                AXC,1           SXA,1                           
		                6                                               
		                30D                                             

                AXT,1           SSP                             
		                18D                                             
		                S1                                              
		                6                                               

                AXT,2           SSP                             
		                6                                               
		                S2                                              
		                2                                               

AXISGEN2        XCHX,1          VLOAD*                          
		                30D                             # X1=-6 X2=+6   X1=-6 X2=+4     X1=-6 X2=+2
		                0,1                                             
                VXSC*           PDVL*                           # J=(UA)(UB1)   J=(UA)(UB2)     J=(UA)(UB3)
## Page 349
		                STARAD          +6,2                            
		                6,1                                             
                VXSC*                                           
                		STARAD          +12D,2                          
                STOVL*          24D                             # K=(VA)(VB1)   J=(VA)(VB2)     J=(VA)(VB3)
                		12D,1                                           

                VXSC*           VAD                             
                		STARAD          +18D,2          # L=(WA)(WB1)   J=(WA)(WB2)     J=(WA)(WB3)
                VAD             VSL1                            
                		24D                                             
                XCHX,1                                          
                		30D                                             
                STORE           XDC             +18D,1          # XDC = L+J+K   YDC = L+J+K     ZDC = L+J+K

                TIX,1                                           
                		AXISGEN3                                        

AXISGEN3        TIX,2                                           
                		AXISGEN2                                        

                VLOAD                                           
                		XDC                                             
                STOVL           STARAD                          
                		YDC                                             
                STOVL           STARAD          +6              
                		ZDC                                             
                STORE           STARAD          +12D            

                RVQ                                             

## Page 350

# TRANSPSE COMPUTES THE TRANSPOSE OF A MATRIX (TRANSPOSE = INVERSE OF ORTHOGONAL TRANSFORMATION).

# THE INPUT IS A MATRIX DEFINING COORDINATE SYSTEM A WITH RESPECT TO COORDINATE SYSTEM B STORED IN STARAD THRU
# STARAD +17D.

# THE OUTPUT IS A MATRIX DEFINING COORDINATE SYSTEM B WITH RESPECT TO COORDINATE SYSTEM A STORED IN STARAD THRU
# STARAD +17D.

TRANSPSE        DXCH            STARAD          +2              # PUSHDOWN NONE
                DXCH            STARAD          +6              
                DXCH            STARAD          +2              

                DXCH            STARAD          +4              
                DXCH            STARAD          +12D            
                DXCH            STARAD          +4              

                DXCH            STARAD          +10D            
                DXCH            STARAD          +14D            
                DXCH            STARAD          +10D            
                TCF             DANZIG                          



# SMD/EREF TRANSFORMS STABLE MEMBER DESIRED COORDINATES FROM STABLE MEMBER DESIRED (DESIRED = PRESENT HERE) TO
# EARTH REFERENCE COORDINATES TO ALIGN THE STABLE MEMBER TO SPECIFIED GIMBAL ANGLES.

# THE INPUTS ARE 1) THE MATRIX DEFINING THE EARTH REFERENCE COORDINATE FRAME WITH RESPECT TO THE NAVIGATION BASE
# COORDINATE FRAME. 2) SAME AS 3) AND 3) OF SMNB.

# THE OUTPUT IS THE DESIRED STABLE MEMBER COORDINATES WITH RESPECT TO THE EARTH REFERENCE COORDINATE FRAME. THE
# THREE UNIT VECTORS ARE STORED AT XSM, YSM, AND ZSM.

SMD/EREF        ITA             VLOAD                           # PUSHDOWN 00,02,04-10D,30D,32D-36D
		                12D                                             
		                XUNIT                                           
                STCALL          32D                             
                		SMNB                            # STABLE MEMBER TO NAVIGATION BASE
                MXV             VSL1                            
                		STARAD                          # THEN TO EARTH REFERENCE
                STOVL           XSM                             
                		YUNIT                                           

                STCALL          32D                             
                		SMNB                            # STABLE MEMBER TO NAVIGATION BASE
                MXV             VSL1                            
                		STARAD                          # THEN TO EARTH REFERENCE
                STOVL           YSM                             
                		ZUNIT                                           

                STCALL          32D                             
## Page 351
                		SMNB                            # STABLE MEMBER TO NAVIGATION BASE
                MXV             VSL1                            
                		STARAD                          # THEN TO EARTH REFERENCE
                STCALL          ZSM                             
                		12D                                             

270DEG          2DEC            -.25                            

QTSN45          2DEC            .1768                           

HALFDP          2DEC            .5                              

ZUNIT           2DEC            0                               

YUNIT           2DEC            0                               

XUNIT           2DEC            0.5                             

ZERODP          2DEC            0                               

                2DEC            0                               

                2DEC            0                               

.166...         2DEC            .1666666667                     

## Page 352

# AOTNB CONVERTS THE AOT RETICLE ROTATION ANGLE (YROT AND SROT) AND
# THE DETENT SETTING TO A HALF UNIT STAR VECTOR REFERRED TO THE
# NAVIGATION BASE FOR NON-FLIGHT ALIGNMENT MODES
#
# THE INPUTS ARE 
#
#    Y RET. LINE RATATION S(YROT) STORED IN LOC 3 OF THE MARK VAC AREA
#    SPIRAL ROTATION ANGLE S(SROT) STORED IN LOC 5 OF MARC VAC AREA
#    ANGLE OF CENTER OF FIELD OF VIEW S(ELV) STORED IN LOC 9 OF MARK VAC
#    AOT ASZIMUTH ANGLE S(DET) STORED IN LOC 8 OF MARK VAC AREA
#    THE COMPLEMENT OF BASE ADDRESS OF MARK VAC IS STORED AT X1
#    COMPENSATION FOR FIELD OF VIEW TILT IN LOC 10D
# THE ABOVE STORAGE IS DONE BY AOTMARK

#
# THE OUTPUT IS A HALF UNIT STAR VECTOR IN NB COORDINATES STORED
# AT 32D AND AVAILABLE IN VAC ON RETURN TO THE CALLING PROGRAM

AOTNB           SETPD           SLOAD*                          
		                0          
		                10D,1				# AOT FOV TILT COMPENSATION ANGLE
		SR1		PUSH				# RESCALE TILT TO 2PI                                     
               	SLOAD*          RTB                             
               			3,1
               			CDULOGIC
               	STORE		14D				# STORE UNCOMPENSATED YROT FOR S COMP
               	DAD		PUSH				# YROT NOW CORRECTED FOR TILT
               	COS		PDDL				# 1/2 COS(YROT) PD 0-1
               	SIN		PUSH				# 1/2 SIN(YROT) PD 2-3
               	SLOAD*		RTB
		                5,1                                             
		                CDULOGIC                                        
                STORE           16D                             # STORE S IF S AND Y ARE ZERO, S=0
                BZE             GOTO                            # S NOT ZERO
		                SISZ                            # S=0
		                SCOMP                                           
SISZ            DLOAD           BZE                             # IS Y ZERO
		                14D                                             
		                YISZ                            # Y=0
                GOTO                                            
                		SCOMP                                           
YISZ            DLOAD           GOTO                            
		                ZERODP                                          
		                SGOT                                            
SCOMP           DLOAD           DSU                             
		                14D                                             
		                16D                              # Y-S
                BDSU                                            
                		NEARONE                          # S=360-(Y-S)
SGOT            DMP             PUSH                            
## Page 353
                		DP1/12                                          
                COS             PDDL                            
                SIN             PUSH                            
                DMP             SL1                             
                		0                                               
                STODL           0                               
                		2                                               
                DMP             STADR                           
                STORE           2                               

                SLOAD*          RTB                             
		                9D,1                                            
		                CDULOGIC                                        
                PUSH            SIN                             
                PDDL            COS                             
                PUSH            DMP                             
                		0                                               
                PDDL            DMP                             
		                4                                               
		                6                                               
                DAD             SL1                             
                STADR                                           
                STODL           32D                             

                DMP                                             
                		4                                               
                STODL           4                               

                DMP             BDSU                            
                		0                                               
                PUSH            SLOAD*                          
                		8D,1                                            
                RTB             PUSH                            
                		CDULOGIC                                        
                COS             PDDL                            
                SIN                                             
                STORE           0                               

                DMP             PDDL                            
		                4                                               
		                6                                               
                DMP             DAD                             
                		2                                               
                SL2                                             
                STODL           34D                             

                DMP             STADR                           
                STODL           36D                             
## Page 354
                DMP                                             
                BDSU            SL2                             
                		36D                                             
                STOVL           36D                             
                		32D                                             
                RVQ                                             

DP1/12          2DEC            .0833333333           		# ; ;          

NEARONE         2DEC            .999999999                      

## Page 355

# AOTSM CALCULATES A HALF UNIT STAR VECTOR IN STABLE MEMBER COORDINATES
# FROM TWO PLANES CONTAINING THE STAR REFERRED TO NB

# THE INPUTS ARE

#    AOT AZIMUTH AND ELEVATION STORED IN 8D AND 9D RESP. OF VAC AREA
#    CDUY, CDUZ AND CDUX FROM A YMARK STORED AT 3, 5, AND 7 OF VAC AREA
#    CDUY, CDUZ AND CDUX FROM A XMARK STORED AT 2, 4, AND 6 OF VAC AREA
#    COMPENSATION FOR FIELD OF VIEW STORED AT 10D OF VAC AREA
# THE BASE ADDRESS OF THE CDUS IS STORED AT LOCATION S1

# THE OUTPUT IS A STAR VECTOR REFERRED TO STABLE MEMBER AT LOC 32D
# AND AVAILBLE IN MPAC

AOTSM           STQ		SETPD
				29D                             # SET UP RETURN
				0
		LXC,1		SLOAD*
				S1				# COMPLEMENT OF CDU ADR FOR XMARK
				8D,1				# LOAD APPARENT TILT ANGLE,ONES COMP
		SR1						# RESCALE TILT TO 2PI
		PUSH		COS
		PDDL		SIN				# 1/2 COS(TA)  0-1
		PUSH		SLOAD*				# 1/2 SIN(TA)  2-3
				6,1				# LOAD AZIMUTH, 2S COMP
		RTB		PUSH
				CDULOGIC
		COS		PDDL				# 1/2 COS(AZ)  4-5
		SIN		PUSH				# 1/2 SIN(AZ)  6-7
		DMP		PDDL
				0
		DMP		PDDL
				2
				4
		DMP		PDDL
				0
				4
		DMP		PUSH
		SLOAD*		RTB
				7,1				# LOAD ELEVATION, 2S COMP
				CDULOGIC
		PUSH		SIN
		PDDL		COS				# 1/2 SIN(ELV)  14-15
		PUSH		DMP				# 1/2 COS(ELV)  16-17
				0
		SL1
		STODL		32D				# X COMPONENT OF X-PLANE VECTOR
		
		DMP		SL1				# UP 16-17
				2
## Page 356

		DCOMP		PDDL				# X COMPONENT OF Y-PLANE VECTOR 16-17
		
				14D
		DMP		SL1
				6
		BDSU		SL1
				12D
		STODL		34D				# Y COMPONENT OF X-PLANE VEC   
		
				14D
		DMP		SL1
				10D
		DAD		SL1
				8D
		DCOMP
		STODL		36D				# Z COMPONENT OF X-PLANE VECTOR
		
				14D
		DMP		SL1
				8D
		DAD		SL1
				10D
		PDDL		DMP				# Y COMPONENT OF Y-PLANE VECTOR 18-19
		
				14D
				12D
		DSU		SL1
				6
		STCALL		20D				# Z COMPONENT OF Y-PLANE VECTOR 20-21
		
				NBSM				# TRANSFORM TO SM
		STOVL		10D				# STORE X-PLAVE VECTOR (SM)
		
				16D             		# LOAD Y-PLANE VECTOR (NB)
                XCHX,1          INCR,1                          
		                S1                              # INCREMENT CDU BASE ADR TO YMARK CDUS
		                1                                               
                XCHX,1                                      	# PUT IT BACK IN S1
		                S1  
		STCALL		32D
		                NBSM                            # GET Y-PLANE IN SM
                VXV             VSL1                            # YP CROSS XP
                		10D
                VCOMP           UNIT                            # UNIT (XP CROSS YP)
                STORE           32D                             # STAR VECTOR IN SM COORDINATES
                GOTO                                            
                		29D                             # RETURN

## Page 357

#          THE FOLLOWING ROUTINE TAKES A HALF UNIT TARGET VECTOR REFERRED TO NAV BASE COORDINATES AND FINDS BOTH
# GIMBAL ORIENTATIONS AT WHICH THE RR MIGHT SIGHT THE TARGET. THE GIMBAL ANGLES CORRESPONDING TO THE PRESENT MODE
# ARE LEFT IN MODEA AND THOSE WHICH WOULD BE USED AFTER A REMODE IN MODEB. THIS ROUTINE ASSUMES MODE 1 IS TRUNNION
# ANGLE LESS THAN 90 DEGS IN ABS VALUE WITH ARBITRARY SHAFT, WITH A CORRESPONDING DEFINITION FOR MODE 2. MODE
# SELECTION AND LIMIT CHECKING ARE DONE ELSEWHERE.

#           THE MODE 1 CONFIGURATION IS CALCULATED FROM THE VECTOR AND THEN MODE 2 IS FOUND USING THE RELATIONS

#           S(2) = 180 + S(1)
#           T(2) = 180 - T(1)

RRANGLES        DLOAD           DCOMP                           # SINCE WE WILL FIND THE MODE 1 SHAFT
                		34D                             # ANGLE LATER, WE CAN FIND THE MODE 1
                SETPD           ASIN                            # TRUNNION BY SIMPLY TAKING THE ARCSIN OF
                                0                               # THE Y COMPONENT, THE ASIN GIVING AN
                PUSH            BDSU                            # ANSWER WHOSE ABS VAL IS LESS THAN 90 DEG
                		HALFDP                                          
                STODL           4                               # MODE 2 TRUNNION TO 4.

                		ZERODP                                          
                STOVL           34D                             # UNIT THE PROJECTION OF THE VECTOR IN THE
                		32D                             # X-Z PLANE.
                UNIT            BOVB                            # CALL FOR S/C MANEUVER ON GIMBAL LOCK.
                		DESRETRN        +1                              
                STODL           32D                             # PROJECTION VECTOR.
                		32D                                             
                SR1             STQ                             
                		S2                                              
                STODL           SINTH                           # USE ARCTRIG SINCE SHAFT COULD BE ARB.
                		36D                                             
                SR1                                             
                STCALL          COSTH                           
                		ARCTRIG                                         
## Page 358
                PUSH            DAD                             # MODE 1 SHAFT TO 2.
                		HALFDP                          # (OVERFLOW DOESNT MATTER SINCE SCALED REV
                STOVL           6                               
                		4                                               
                RTB                                             # FIND MODE 2 CDU ANGLES.
                		2V1STO2S                                        
                STOVL           MODEB                           
                		0                                               
                RTB                                             # MODE 1 ANGLES TO MODE A.
                		2V1STO2S                                        
                STORE           MODEA                           
                EXIT                                            

                CS              RADMODES                        # SWAP MODEA AND MODEB IF RR IN MODE2.
                MASK            BIT12                           
                CCS             A                               
                TCF             +4                              

                DXCH            MODEA                           
                DXCH            MODEB                           
                DXCH            MODEA                           

                TC              INTPRET                         
                GOTO                                            
                                S2                              

## Page 359
#    GIVEN RR TRUNION AND SHAFT (T,S) IN TANG,+1, FIND THE ASSOCIATED
# LINE OF SIGHT IN NAV BASE AXES.  THE HALF UNIT VECTOR, .5(SIN(S)COS(T),
# -SIN(T),COS(S)COS(T)) IS LEFT IN MPAC AND 32D.

RRNB            SLOAD           RTB                             
		                TANG                                            
		                CDULOGIC                                        
                SETPD           PUSH                            # TRUNNION ANGLE TO 0
                		0                                               
                SIN             DCOMP                           
                STODL           34D                             # Y COMPONENT

                COS             PUSH                            # .5 COS(T) TO 0
                SLOAD           RTB                             
		                TANG            +1                              
		                CDULOGIC                                        
                PUSH            COS                             # SHAFT ANGLE TO 2
                DMP             SL1                             
                		0                                               
                STODL           36D                             # Z COMPONENT

                SIN             DMP                             
                SL1                                             
                STOVL           32D                             
                		32D                                             
                RVQ                                             

                              
