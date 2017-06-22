### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    KALCMANU_STEERING.agc
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
## Reference:   pp. 627-631
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##		2017-06-13 RSB	Transcribed
##		2017-06-22 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 627
# GENERATION OF STEERING COMMANDS FOR DIGITAL AUTOPILOT FREE FALL MANEUVERS

# NEW COMMANDS WILL BE GENERATED EVERY ONE SECOND DURING THE MANEUVER

                EBANK=          TTEMP                           

NEWDELHI        TC              INTPRET                         
                AXC,1           AXC,2                           
                                MIS                             # COMPUTE THE NEW MATRIX FROM S/C TO
                                KEL                             # STABLE MEMBER AXES
                CALL                                            
                                MXM3                            
                VLOAD           STADR                           
                STOVL           MIS             +12D            # CALCULATE NEW DESIRED CDU ANGLES
                STADR                                           
                STOVL           MIS             +6D             
                STADR                                           
                STORE           MIS                             
                AXC,1           CALL      
                                      
                                MIS                             
                                DCMTOCDU                        # PICK UP THE NEW CDU ANGLES FROM MATRIX
                RTB                                             
                                V1STO2S                         
                STORE           NCDU                            # NEW CDU ANGLES
                BONCLR          EXIT                            
                                32D                        
                                MANUSTAT                        # TO START MANEUVER
                CAF             TWO                             #          +0 OTHERWISE
INCRDCDU        TS              SPNDX                           
                INDEX           SPNDX                           
                CA              BCDU                            # INITIAL CDU ANGLES
                EXTEND                                          # OR PREVIOUS DESIRED CDU ANGLES
                INDEX           SPNDX                           
                MSU             NCDU                            
                EXTEND                                          
                MP              DT/TAU                          
                CCS             A                               # CONVERT TO 2S COMPLEMENT
                AD              ONE                             
                TCF             +2                              
                COM                                             
                INDEX           SPNDX                           
                TS              DELDCDU                         # ANGLE INCREMENTS TO BE ADDED TO
                
                INDEX           SPNDX                           # CDUXD, CDUYD, CDUZD EVERY TENTH SECOND
                CA              NCDU                            # BY LEM DAP
                INDEX           SPNDX                           
                XCH             BCDU                            
                INDEX           SPNDX                           
                TS              CDUXD                           
                CCS             SPNDX                           
                TCF             INCRDCDU                        # LOOP FOR THREE AXES

## Page 628
# COMPARE PRESENT TIME WITH TIME TO TERMINATE MANEUVER

TMANUCHK        EXTEND                                          
                DCS             TIME2                           
                DXCH            TTEMP                           
                EXTEND                                          
                DCA             TM                              
                DAS             TTEMP                           # TM+T0-1-T
                CCS             TTEMP                           
                TCF             CONTMANU                        # (TM+T0)-T G 164 SEC
                TCF             +2                              
                TCF             OVERMANU                        # (TM+T0)-T L -164 SEC
                CCS             TTEMP           +1              
                TCF             CONTMANU                        # (TM+T0)-T G 1 SEC
                TCF             MANUOFF                         # (TM+T0)-T E 1 SEC
                COM                                             # (TM+T0)-T L 1 SEC
MANUOFF         AD              ONESEK          +1              # (TM+T0)-T E 1 SEC
                EXTEND                                          
                BZMF            OVERMANU                        # THIS IS A SAFETY PLAY
MANUSTAL        INHINT                                          # PREPARE TO STOP THE MANEUVER
                TC              WAITLIST                        
                EBANK=          TTEMP                           
                2CADR           MANUSTOP                        

                RELINT                                          
                TCF             ENDOFJOB                        

DT/TAU          DEC             .1                              

MANUSTAT        EXIT                                            # INITIALIZATION ROUTINE
                EXTEND                                          # FOR AUTOMATIC MANEUVERS
                DCA             TIME2                           
                DAS             TM                              # TM+T0    MANEUVER COMPLETION TIME
                EXTEND                                          
                DCS             ONESEK                          
                DAS             TM                              # (TM+T0)-1
                CA              BRATE                           # X-AXIS MANEUVER RATE
                TS              OMEGAPD
                CA              BRATE           +2              # Y-AXIS MANEUVER RATE
                TS              OMEGAQD
                CA              BRATE           +4              # Z-AXIS MANEUVER RATE
                TS              OMEGARD
                CA              TIME1
                AD              ONESEK          +1
                XCH             NEXTIME
                TC              FLAG2UP                         # SET BIT 11 OF FLAGWRD2
                OCT             2000                            # TO SIGNAL KALCMANU IN PROCESS
                TCF             INCRDCDU        -1

ONESEK          DEC             0   
## Page 629                            
                DEC             100                             

OVERMANU        CAF             ONE                             # SAFETY PLAY
                TCF             MANUSTAL

CONTMANU        CS              TIME1                           # RESET FOR NEXT DCDU UPDATE
                AD              NEXTIME                         
                CCS             A   
                                            
                AD              ONE                             
                TCF             MANUCALL                        
                AD              NEGMAX                          
                COM                                             
MANUCALL        INHINT                                          # CALL FOR NEXT UPDATE VIA WAITLIST
                TC              WAITLIST                        
                EBANK=          TTEMP                           
                2CADR           UPDTCALL                        

                RELINT
                CAF             ONESEK          +1              # INCREMENT TIME FOR NEXT UPDATE
                ADS             NEXTIME                         
                TCF             ENDOFJOB                        



UPDTCALL        CAF             PRIO34                          # SATELLITE PROGRAM TO CALL FOR UPDATE
                TC              FINDVAC                         # OF STEERING COMMANDS
                EBANK=          TTEMP                           
                2CADR           NEWDELHI                        

                TC              TASKOVER                        

## Page 630
# ROUTINE FOR TERMINATING AUTOMATIC MANEUVERS

MANUSTOP        CAF             ZERO                            # ZERO MANEUVER RATES
                TS              DELDCDU2                        
                TS              OMEGARD                         
                TS              DELDCDU1                        
                TS              OMEGAQD                         
                CA              CPSI                            # SET DESIRED GIMBAL ANGLES TO
                TS              CDUZD                           # DESIRED FINAL GIMBAL ANGLES
                CA              CTHETA                          
                TS              CDUYD                           
                CA              STATE           +2              # CHECK TO SEE IF A FINAL YAW NECESSARY
                MASK            BIT14
                EXTEND
                
                BZF             KALCROLL
ENDROLL         CA              CPHI                            # NO FINAL YAW
                TS              CDUXD                           
                CAF             ZERO                            
                TS              OMEGAPD                         # I.E. MANEUVER DID NOT GO THRU
                TS              DELDCDU                         # GIMBAL LOCK ORIGINALLY
GOODMANU        TC              FLAG2DWN                        # RESET BIT 11 OF FLAGWRD2 TO SIGNAL END
                OCT             2000                            # OF KALCMANU
                CAF		THREE
                TC              POSTJUMP                        # RETURN UNDER WAITLIST VIA GOODEND
                CADR            GOODEND				# AND WAKE UP USER

KALCROLL        CA              STATE           +2              # STATE SWITCH NO. 33
                MASK            BIT12                           # 0(OFF) = PERFORM A FINAL YAW
                EXTEND                                          #          IF NECESSARY
                BZF             DOROLL                          # 1(ON) = IGNORE ANY FINAL YAW
                TCF             ENDROLL         +2
DOROLL          CA              CPHI
                EXTEND                                          # PERFORM A FINAL ROLL  TO
                MSU             CDUXD                           # COMPLETE AUTOMATIC MANEUVER
                EXTEND
                BZMF            FROLLNEG
FROLLPOS        TS              L

                CA              ROLLRATE
                TS              OMEGAPD
                CS              DELFROLL
                AD              ONE
                TS              DELDCDU
                TCF             ROLLSTAL
FROLLNEG        COM
                TS              L
                CS              ROLLRATE
                TS              OMEGAPD
                CA              DELFROLL
                TS              DELDCDU
ROLLSTAL        CA              L                               # ABS(CPHI-CDUXD)
## Page 631
                EXTEND
                MP              INVRATE
                EXTEND
                BZMF            ENDROLL
                TC              WAITLIST
                EBANK=          TTEMP
                2CADR           ENDROLL

                TC              TASKOVER

ROLLRATE        DEC             720                             # = 1.98 DEGREES/SEC
DELFROLL        DEC             18                              # MUST BE A WHOLE NUMBER
INVRATE         DEC             .555555
