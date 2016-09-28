### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     OPTIMUM_PRELAUNCH_ALIGNMENT_CALIBRATION.agc
# Purpose:      Part of the source code for Aurora (revision 12).
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      https://www.ibiblio.org/apollo.
# Pages:        414-434
# Mod history:  2016-09-20 JL   Created.
#               2016-09-27 MAS  Started.

# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the private collection of 
# Don Eyles.  The digitization was performed by archive.org.

# Notations on the hardcopy document read, in part:

#       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
#       NOV 10, 1966

#       [Note that this is the date the hardcopy was made, not the
#       date of the program revision or the assembly.]

# The scan images (with suitable reduction in storage size and consequent 
# reduction in image quality) are available online at 
#       https://www.ibiblio.org/apollo.  
# The original high-quality digital images are available at archive.org:
#       https://archive.org/details/aurora00dapg

## Page 514
# THIS PROGRAM USES A VERTICAL,SOUTH,EAST COORDINATE SYSTEM FOR PIPAS
                BANK            21
                EBANK=          XSM


# G SCHMIDT SIMPLIFIED ESTIMATION PROGRAM FOR ALIGNMENT CALIBRATION. THE
# PROGRAM IS COMPLETELY RESTART PROFED. DATA STORED IN BANK4.
ESTIMS          TC              PHASCHNG
                OCT             00101
RSTGTS1         INHINT                                          #  COMES HERE PHASE1 RESTART
                CA              TIME1
                TS              GTSWTLST
                CAF             ZERO                            # ZERO THE PIPAS
                TS              PIPAX                           
                TS              PIPAY                           
                TS              PIPAZ                           
                TS              DELVX           +1
                TS              DELVY           +1
                TS              DELVZ           +1
                RELINT                                          
                TC              SETUPER
                CA              77DECML                         
                TS              ZERONDX                         
                CA              ALXXXZ                          
                TC              BANKCALL
                CADR            ZEROING                         
                TC              INTPRET                         
                VLOAD                                           
                                INTVAL          +2
                STORE           ALX1S
                EXIT

                CCS             GEOCOMPS                        # GEOCOMPS IN NON ZERO IF COMPASS
                TC              +2
                TC              SLEEPIE         +1              
                TC              LENGTHOT                        #   TIMES FIVE IS THE NUM OF SEC ERECTING
                TS              ERECTIME

                TC              NEWMODEX
                OCT             05
                TC              BANKCALL
                CADR            GCOMPZER                        #   ZERO COMPENSATION PROGRAM REGISTERS
                TC              ANNNNNN

## Page 515
ALLOOP          INHINT                                          #  TASK EVERY .5 OR 1 SEC (COMPASS-DRIFT)
                CA              TIME1
                TS              GTSWTLST                        # STORE TIME TO SET UP NEXT WAITLIST
ALLOOP3         CA              ALTIM
                TS              GEOSAVED
                TC              PHASECHNG
                OCT             00201
                TC              +2

ALLOOP1         INHINT                                          # RESTARTS COME IN HERE
                CA              GEOSAVED
                TS              ALTIM
                CCS             A
                CA              A                               # SHOULD NEVER HIT THIS LOCATION
                TS              ALTIMS                          
                CS              A                               
                TS              ALTIM                           
                CA              PIPAX
                TS              DELVX
                CA              PIPAY
                TS              DELVY
                CA              PIPAZ
                TS              DELVZ
                CAF             ZERO                            
                TS              PIPAX                           
                TS              PIPAY                           
                TS              PIPAZ                           
                TC              PHASCHNG
                OCT             00701
                RELINT
SPECSTS         CAF             PRIO20                          
                TC              FINDVAC                         
                2CADR           ALFLT                           # START THE JOB

                TC              TASKOVER                        

## Page 516
ALFLT           TC              STOREDTA                        #  STORE DATA IN CASE OF RESTART IN JOB
                TC              PHASCHNG                        # THIS IS THE JOB DONE EVERY ITERATION
                OCT             00601
                CCS             GEOCOMPS                        
                TC              +2                              
                TC              NORMLOP                         
                TC              BANKCALL                        # COMPENSATION IF IN COMPASS
                CADR            1/PIPA                          
                TC              NORMLOP


ALFLT1          TC              LOADSTDT                        # COMES HERE ON RESTART

NORMLOP         TC              INTPRET                         
                DLOAD                                           
                                INTVAL                                          
                STORE           S1                              # STEP REGISTERS MAY HAVE BEEN WIPED OUT
                SLOAD           BZE
                                GEOCOMPS
                                ALCGKK
                GOTO
                                ALFLT2
ALCGKK          SLOAD           BMN                             
                                ALTIMS                                          
                                ALFLT2                                          
ALKCG           AXT,2           LXA,1                           # LOADS SLOPES AND TIME CONSTANTS AT RQST
                                12D                                             
                                ALX1S                                           
ALKCG2          DLOAD*          INCR,1                          
                                ALFDK           +144D,1                         
                DEC             -2                              
                STORE           ALDK            +10D,2          
                TIX,2           SXA,1                           
                                ALKCG2                                          
                                ALX1S                                           

ALFLT2          VLOAD           VXM
                                DELVX
                                GEOMTRX
                VLS1
                DLOAD           DCOMP
                                MPAC            +3
                STODL           DPIPAY
                                MPAC            +5
                STORE           DPIPAZ

                SETPD           AXT,1                           # MEASUREMENT INCORPORATION ROUTINES.
                                0
                                8D                                              
## Page 517

DELMLP          DLOAD*          DMP                             
                DPIPAY          +8D,1                           
                PIPASC                                          
                SLR             BDSU*                           
                9D                                              
                INTY            +8D,1                           
                STORE           INTY            +8D,1           
                PDDL            DMP*                            
                VELSC                                           
# Page 386
                VLAUN           +8D,1                           
                SL2R                                            
                DSU             STADR                           
                STORE           DELM            +8D,1           
                STORE           DELM            +10D,1          
                TIX,1           AXT,2                           
                DELMLP                                          
                4                                               
ALILP           DLOAD*          DMPR*                           
                ALK             +4,2                            
                ALDK            +4,2                            
                STORE           ALK             +4,2            
                TIX,2           AXT,2                           
                ALILP                                           
                8D                                              
ALKLP           LXC,1           SXA,1                           
                CMPX1                                           
                CMPX1                                           
                DLOAD*          DMPR*                           
                ALK             +1,1                            
                DELM            +8D,2                           
                DAD*                                            
                INTY            +8D,2                           
                STORE           INTY            +8D,2           
                DLOAD*          DAD*                            
                ALK             +12D,2                          
                ALDK            +12D,2                          
                STORE           ALK             +12D,2          
                DMPR*           DAD*                            
                DELM            +8D,2                           
                INTY            +16D,2                          
                STORE           INTY            +16D,2          
                DLOAD*          DMP*                            
                ALSK            +1,1                            
                DELM            +8D,2                           
                SL1R            DAD*                            
                VLAUN           +8D,2                           
                STORE           VLAUN           +8D,2           
                TIX,2           AXT,1                           
                ALKLP                                           
                8D                                              

LOOSE           DLOAD*          PDDL*                           
                ACCWD           +8D,1                           
                VLAUN           +8D,1                           
                PDDL*           VDEF                            
                POSNV           +8D,1                           
                MXV             VSL1                            
                TRANSM1                                         
# Page 387
                DLOAD                                           
                MPAC                                            
                STORE           POSNV           +8D,1           
                DLOAD                                           
                MPAC            +3                              
                STORE           VLAUN           +8D,1           
                DLOAD                                           
                MPAC            +5                              
                STORE           ACCWD           +8D,1           
                TIX,1                                           
                LOOSE                                           

                AXT,2           AXT,1                           # EVALUATE SINES AND COSINES
                6                                               
                2                                               
BOOP            DLOAD*          DMPR                            
                ANGX            +2,1                            
                GEORGEJ                                         
                SR2R                                            
                PUSH            SIN                             
                SL3R            XAD,1                           
                X1                                              
                STORE           16D,2                           
                DLOAD                                           
                COS                                             
                STORE           22D,2                           # COSINES
                TIX,2                                           
                BOOP                                            

PERFERAS        EXIT                                            
                CA              EBANK7                          
                TS              EBANK                           
                EBANK=          ATIGINC                         
                TC              ATIGINC                         # GOTO ERASABLE TO CALCULATE ONLY TO RETN

#                            CAUTION

# THE ERASABLE PROGRAM THAT DOES THE CALCULATIONS MUST BE LOADED
# BEFORE ANY ATTEMPT IS MAKE TO RUN THE IMU PERFORMANCE TEST

                EBANK=          AZIMUTH                         
                CCS             LENGTHOT                        
                TC              SLEEPIE                         
                CCS             TORQNDX                         
                TCF             +2                              
                TC              SETUPER1                        
                CA              CDUX                            
                TS              LOSVEC          +1              # FOR TROUBLESHOOTING VD POSNS 2$4

# Page 388
SETUPER1        TC              INTPRET                         
                DLOAD           PDDL                            # ANGLES FROM DRIFT TEST ONLY
                ANGZ                                            
                ANGY                                            
                PDDL            VDEF                            
                ANGX                                            
                VCOMP           VXSC                            
                GEORGEJ                                         
                MXV             VSR1                            
                XSM                                             
                STORE           OGC                             
                EXIT                                            

                CA              OGCPL                           
                TC              BANKCALL                        
                CADR            IMUPULSE                        
                TC              IMUSLLLG                        
GEOSTRT4        CCS             TORQNDX                         # ONLY POSITIVE IF IN VERTICAL DRIFT TEST
                TC              VALMIS                          
                TC              INTPRET                         
                CALL                                            
                ERTHRVSE                                        
                EXIT                                            
                TC              TORQUE                          

SLEEPIE         TS              LENGTHOT                        # TEST NOT OVER-DECREMENT LENGTHOT
                CCS             TORQNDX                         # ARE WE DOING VERTDRIFT
                TC              EARTHR*                         
                TC              ENDOFJOB                        

SOMEERRR        CA              EBANK5                          
                TS              EBANK                           
                CA              ONE                             
                TS              OVFLOWCK                        # STOP ALLOOP FROM CALLING ITSELF
                TC              ALARM                           
                OCT             1600                            
                TC              ENDTEST1                        
SOMERR2         CAF             OCT1601                         
                TC              VARALARM                        
                TC              DOWNFLAG                        
                ADRES           IMUSE                           
                TC              ENDOFJOB                        

OCT1601         OCT             01601                           
DEC585          OCT             06200                           # 3200 B+14 ORDER IS IMPORTANT
SCHZEROS        2DEC            .00000000                       
# Page 389
                2DEC            .00000000                       

                OCT             00000                           
ONEDPP          OCT             00000                           # ORDER IS IMPORTANT
                OCT             00001                           

INTVAL          OCT             4                               
                OCT             2                               
                DEC             144                             
                DEC             -1                              
SOUPLY          2DEC            .93505870                       # INITIAL GAINS FOR PIP OUTPUTS

                2DEC            .26266423                       # INITIAL GAINS/4 FOR ERECTION ANGLES

77DECML         DEC             77                              
ALXXXZ          GENADR          ALX1S           -1              
PIPASC          2DEC            .13055869                       

VELSC           2DEC            -.52223476                      # 512/980.402

ALSK            2DEC            .17329931                       # SSWAY VEL GAIN X 980.402/4096

                2DEC            -.00835370                      # SSWAY ACCEL GAIN X 980.402/4096

GEORGEJ         2DEC            .63661977                       

GEORGEK         2DEC            .59737013                       

