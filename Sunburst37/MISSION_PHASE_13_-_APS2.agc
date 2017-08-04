### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MISSION_PHASE_13_-_APS2.agc
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
## Reference:   pp. 704-710
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-05-24 MAS  Created from Sunburst 120.
##              2017-06-14 HG   Transcribed
##		2017-06-23 RSB	Proofed comment text with
##				octopus/ProoferComments.

## Page 704
# MISSION PHASE 13 EXERCISES THE ASCENT GUIDANCE EQUATIONS OF PROG 46
# THE PREREAD TASK IS SET TO OCCUR IN 140 SECS AT TIG-30 AND AVETOMID DONE
# THE PRE-APS2 PROG 34 IS EXECUTED AND KALCMANU JOB IS STARTED
# THE ENGINEON TASK IS STARTED AT TIG-30 AND IGN IS AT 170 SECS AFTER
# START OF MP13
# THE ASCENT GUIDANCE EQUATIONS START BETWEEN TIG+1 AND +2 SECS
# THE ASC FEED TEST STARTS AT TIG+9 AND TERMINATES 365 SECS LATER

                BANK            27
                EBANK=          AMEMORY

MP13JOB         EXTEND                                  
                DCA             TIME2                   # PICK UP CURRENT TIME
                DXCH            TDEC                    
                TC              NEWMODEX                # SET MODE
                OCT             34                      
                                                        
                ZL                                      # SET TDEC TO TIME AT TIG-30
                CAF             140SECS                 # TIME TO TIGN-30
                XCH             L                       
                DAS             TDEC                    # TDEC =TIGN-30 FOR MIDTOAVE
                                                        
                CAF             140SECS                 
                INHINT                                  
                TC              WAITLIST                # SET TASK FOR TIGN-30
                EBANK=          TDEC                    
                
                2CADR           TIG13-30                
                                                        
                RELINT                                  
                                                        
                EXTEND                                  
                DCA             MIDAVEAD                # DO MIDTOAVE COMPUTATION
                DXCH            Z                       
                                                        
                EXTEND                                  
                DCA             PREAP2AD                # DO PRE-APS2 TO GET DESIRED ATTITUDE
                DXCH            Z                       # STORES VECTORS POINTVSM AND SCAXIS
                                                        
                TC              INTPRET                 
                SSP             SET                     
                                RATEINDX                # SET KALCMANU FOR ANGULAR RATE OF 5DEG/S
                                4                       
                                33D                     
                EXIT                                    
                                                        
                CAF             PRIO30                  # SET ATTITUDE MANEUVER JOB
                INHINT                                  
                TC              FINDVAC                 
                EBANK=          MIS                     
                2CADR           VECPOINT                
                                      
## Page 705                                      
                CAF             BIT1                    
                INHINT                                  
                TC              WAITLIST                # SET UP DFI T/M CALIBRATE TASK
                EBANK=          TDEC                    
                2CADR           DFICAL                  # DFICAL REQUIRES 14 SECS AND ENDS ITSELF
                                                        
                TC              BANKCALL                # PUT MP13 TO SLEEP-KALCMANU WILL WAKE
                CADR            ATTSTALL                
                TC              CURTAINS                # BAD END RETURN FROM KALCMANU
                                                        
                TC              ENDOFJOB                # WAIT FOR TIG-30 TASK TO INTERUPT
                                                        
TIG13-30        CAF             BIT1                    # SET PREREAD FOR NOW
                TC              WAITLIST                
                EBANK=          DVTOTAL                 
                2CADR           PREREAD                 
                                                        
                CAF             BIT11                   # SEE IF ATTITUDE MANEUVER DONE
                MASK            FLAGWRD2                
                CCS             A                       
                TCF             CURTJOB                 # NO-SET UP CURTAINS JOB
                                                        
                TC              NEWMODEX                
                OCT             46                      # SET MODE TO PROG46
                                                        
                CAF             AVEG13AD                # GENADR OF AVEG IN DVSELECT
                TS              DVSELECT                
                                                        
                EXTEND                                  
                DCA             SVEX13AD                # 2CADR SERVEXIT IN AVEGEXIT
                DXCH            AVGEXIT                 
                                                        
                EXTEND                                  
                DCA             MP13TMAD                
                DXCH            DVMNEXIT                # SET MP RETURN FOR ENGINE SHUT DOWN
                                                        
                TC              ENGINOF1                # JUST TO ENSURE ENGINE OFF
                                                        
                TC              1LMP+DT                 
                DEC             134                     # ENGINE SELECT-APS ARM
                DEC             1750                    # DELAY 17.5 SECS
                                                        
                TC              IBNKCALL                
                CADR            ULLAGE                  # COMMAND 4 JET ULLAGE-ON
                                                        
                TC              FIXDELAY                
                DEC             1250                    # DELAY 12.5 SECS TO IGNITION
                                                        
TIG13           TC              ENGINEON                # FIRE UP APS ENGINE

## Page 706
                TC              FIXDELAY                
                DEC             50                      # DELAY .5 SECS
                                                        
                TC              IBNKCALL                
                CADR            NOULLAGE                # ULLAGE JETS OFF AT TIG + .5
                                                        
                TC              FIXDELAY
                DEC             50                      # DELAY .5 SEC AND START ASCENT GUIDANCE
                EXTEND
                DCA             ATMAGAD
                DXCH            AVGEXIT                 # SET AVEG LOOP TO THRUST MAGNITUDE FILTER

                TC              FIXDELAY
                DEC             800                     # DELAY 8 SECS AND DO FEED TEST
                TC              FEEDTEST                # START FEED TEST ROUTINE

                EXTEND
                DCA             342SECS
                TC              LONGCALL
                EBANK=          TDEC
                2CADR           MP13+544

                TC              TASKOVER
                
MP13+544        TC              FEEDREST                # DO FEED TEST RESET ROUTINE

                TC              TASKOVER                # WAIT FOR GUIDANCE TO DO ENGINE OFF

MP13TERM        CAF             BIT1                    # SET MP13 TERMINAL TASKS
                INHINT
                TC              WAITLIST
                EBANK=          TDEC
                2CADR           MP13OUT

                TC              ENDOFJOB                # KILL JOB SET BY DVMON

MP13OUT         EXTEND                                  # APS ENGINE OFF-TERMINATE MP13
                DCA             SVEXITAD                # REMOVE ASCENT PROG FROM SERVICER
                DXCH            AVGEXIT

                TC              IBNKCALL                # DEADBAND SELECT-MAX
                CADR            SETMAXDB
                
                TC              IBNKCALL                # SET ATTITUDE HOLD
                CADR            STOPRATE
                
                TC              FEEDREST                # DO THIS IN CASE OF EARLY ENG SHUT DOWN

                TC              FIXDELAY
                DEC             100                     # DELAY 1 SEC

## Page 707                
                TC              1LMP
                DEC             135                     # APS ARM OFF

                TC              FIXDELAY
                DEC             2900                    # DELAY 29 SECS TO KILL AVEG

                TC              FLAG1DWN                # KILL AVE G
                OCT             1

                TC              TASKOVER                # MISSION PHASE 13 COMPLETE

1SEC13          DEC             100
2SECS13         DEC             200
12SECS13        DEC             1200
140SECS         DEC             14000
342SECS         2DEC            34200                   # 342 SECONDS

AVEG13AD        GENADR          AVERAGEG
                EBANK=          TDEC
PREAP2AD        2CADR           PREAPS2

                EBANK=          TDEC
MP13TMAD        2CADR           MP13TERM

                EBANK=          TDEC
ATMAGAD         2CADR           ATMAG

                EBANK=          DVTOTAL
SVEX13AD        2CADR           SERVEXIT

## Page 708
CURTJOB         CAF             PRIO37                  # SET UP JOB TO GO TO CURTAINS
                TC              NOVAC
                EBANK=          SFAIL
                2CADR           CURTAINS

                TC              TASKOVER

DFICAL          TC              1LMP+DT                 # LMP COMMAND
                DEC             236                     # DFI T/M CALIBRATE - ON
                DEC             1200                    # DELAY 12 SECS

                TC              2LMP+DT                 # LMP COMMANDS
                DEC             237                     # DFI T/M CALIBRATE - OFF
                DEC             198                     # MASTER C+W ALARM RESET - COMMAND
                DEC             200                     # DELAY 2.0 SECONDS

                TC              1LMP                    # LMP COMMAND
                DEC             199                     # MASTER C+W ALARM RESET - COMMAND RESET
                TC              TASKOVER                # TERMINATE DFI CALIBRATE TASK

## Page 709
FEEDTEST        EXTEND
                QXCH            MPRETRN
                TC              FLAG2UP                 # SET ASC FEED TEST FLAG
                OCT             200

                TC              1LMP+DT                 # TIME T
                DEC             126                     # RCS ASCENT FEED VALVE - ARM
                DEC             100                     # DELAY 1 SEC

                TC              2LMP+DT                 # T+1
                DEC             60                      # RCS ASCENT FEED VALVES8 SYS A-OPEN
                DEC             172                     # RCS MAIN S/O VALVES SYS A-CLOSE
                DEC             200                     # DELAY FOR 2 SECS

                TC              2LMP+DT                 # T+3
                DEC             61                      # RCS ASCENT FEED VALVES SYS A-OPEN RESET
                DEC             173                     # RCS MAIN S/O VALVES SYS A-CLOSE RESET
                DEC             800                     # DELAY FOR 8 SECS

                TC              2LMP+DT                 # T+11
                DEC             62                      # RCS ASCENT FEED VALVES SYS B-OPEN
                DEC             174                     # RCS MAIN S/O VALVES SYS B -CLOSE
                DEC             200                     # DELAY FOR 2 SECS

                TC              2LMP+DT                 # T+13
                DEC             63                      # RCS ASCENT FEED VALVES SYS B-OPEN RESET
                DEC             175                     # RCS MAIN S/O VALVES SYS B-CLOSE RESET
                DEC             800                     # DELAY 8 SECS

                TC              1LMP+DT                 # T+21
                DEC             252                     # RCS MANIFOLD CROSSFEED VALVES-OPEN
                DEC             200                     # DELAY FOR 2 SECS

                TC              1LMP                    # T+23
                DEC             253                     # RCS MANIFOLD CROSSFEED VALVES-OPEN RESET

                TC              MPRETRN

## Page 710
FEEDREST        CS              FLAGWRD2                # CHECK FEED TEST FLAG
                MASK            BIT8
                CCS             A
                TC              Q                       # FLAG DOWN-NO RESET

                EXTEND                                  # FLAG UP - DO FEED TEST RESET
                QXCH            MPRETRN

                TC              FLAG2DWN                # FEED TEST FLAG DOWN
                OCT             200

                TC              1LMP+DT                 # TIME T
                DEC             254                     # RCS MANIFOLD CROSSFEED VALVES -CLOSE
                DEC             100                     # DELAY 1 SEC

                TC              2LMP+DT                 # T+1
                DEC             188                     # RCS MAIN S/O VALVES SYS A-OPEN
                DEC             76                      # RCS ASCENT FEED VALVES SYS A-CLOSE
                DEC             100                     # DELAY 1 SECS

                TC              1LMP+DT                 # T+2
                DEC             255                     # RCS MANIFOLD CROSSFEED VALVES-CLOSE RESE
                DEC             100                     # DELAY 1 SEC

                TC              2LMP+DT                 # T+3
                DEC             189                     # RCS MAIN S/O VALVES SYS A-OPEN RESET
                DEC             77                      # RCS ASCENT FEED VALVES SYS A-CLOSE RESET
                DEC             800                     # DELAY 8 SECS

                TC              2LMP+DT                 # T+11
                DEC             190                     # RCS MAIN S/O VALVES SYS B-OPEN
                DEC             78                      # RCS ASCENT FEED VALVES SYS B-CLOSE
                DEC             100                     # DELAY 1 SEC

                TC              1LMP+DT                 # T+12
                DEC             127                     # RCS ASCENT FEED VALVE-SAFE
                DEC             100                     # DELAY 1 SEC

                TC              2LMP                    # T+13
                DEC             191                     # RCS MAIN S/O VALVES SYS B-OPEN RESET
                DEC             79                      # RCS ASCENT FEED VALVES SYS B-CLOSE RESET

                TC              MPRETRN                 # RETURN TO MISSION PROGRAM
                