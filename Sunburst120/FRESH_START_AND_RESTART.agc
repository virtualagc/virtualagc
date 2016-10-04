### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     FRESH_START_AND_RESTART.agc
# Purpose:      A module for revision 0 of BURST120 (Sunburst). It 
#               is part of the source code for the Lunar Module's
#               (LM) Apollo Guidance Computer (AGC) for Apollo 5.
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      www.ibiblio.org/apollo/index.html
# Mod history:  2016-09-30 RSB  Created draft version.

# Page 89
                BANK            01                              
                EBANK=          LST1                            

SLAP1           INHINT                                          # FRESH START.  COMES HERE FROM PINBALL.
                TC              STARTSUB                        # SUBROUTINE DOES MOST OF THE WORK

STARTSW         TCF             GOON                            # PATCH FOR SIMULATION

STARTSIM        CAF             BIT14                           

                TC              FINDVAC                         
                EBANK=          ITEMP1                          
                2CADR           BEGIN206                        

GOON            CAF             BIT14                           # TURN OFF ALL DSPTAB +11D LAMPS ONLY ON
                TS              DSPTAB          +11D            # REQUESTED FRESH START

                CS              ZERO                            
                TS              RSTRTWRD                        
                TS              THRUST                          # INITIALIZE THROTTLE COUNTER.
                TS              DAPOFFDT                        # OVERWRITE IN ERASABLE LOAD IF DESIRED.
                TS              JETRESET                        # PROPERTY OF RCSMONIT

                CA              EBANKS                          
                TS              L                               
                LXCH            EBANK                           
                EBANK=          ABDELV                          
                CA              ZERO                            
                TS              ABDELV                          # FOR DAP INITIALIZATON
                TS              ABDELV          +1              
                EBANK=          LST1                            
                LXCH            EBANK                           

                TS              THISCH32                        
                TS              LMPJFAIL                        
                TS              CH5MASK                         
                5S              CH5MASK                         

                TS              REDOCTR                         
                TS              FAILREG                         
                TS              FAILREG         +1              
                TS              FAILREG         +2              

                CA              TWO                             # SET UP VALUES FOR DVCNTR.  THESE MAY
                TS              STARTDVC                        # BE OVERWRITTEN IN ERASABLE LOAD IF
                TS              STOPDVC                         # ANYBODY WANTS TO.

                CA              POSMAX                          # TENTATIVELY LOAD WITH INFINITY.  MAY
                TS              SLOSHCTR                        # BE REPLACED VIA ERASABLE LOAD.

# Page 89
DDFSTART        CS              ZERO                            # MAKE ALL MTIMER/MPHASE PAIRS AVAILABLE
                TS              MTIMER4                         
                TS              MTIMER3                         
                TS              MTIMER2                         
                TS              MTIMER1                         
                TS              MPHASE4                         
                TS              MPHASE3                         
                TS              MPHASE2                         
                TS              MPHASE1                         

                CS              ONE                             
                TS              LMPOUTT                         

# INITIALIZE SWITCH REGISTERS INCLUDING DAPBOOLS:

                CA              FOUR                            # INITIALIZE STATE THRU STATE +4 ONLY.
INITSW          TS              L                               
                INDEX           L                               
                CA              SWINIT                          
                INDEX           L                               
                TS              STATF                           
                CCS             L                               
                TCF             INITSW                          

                TS              SMODE                           
                TS              ERESTORE                        
                TS              LMPCMD                          # RESET LMP COMMAND AREA.
                TS              LMPCMD          +1              
                TS              LMPCMD          +2              
                TS              LMPCMD          +3              
                TS              LMPCMD          +4              
                TS              LMPCMD          +5              
                TS              LMPCMD          +6              
                TS              LMPCMD          +7              
                TS              LMPIN                           
                TS              LMPOUT                          

                EXTEND                                          # TURN THE RCS JETS OFF.
                WRITE           5                               
                EXTEND                                          
                WRITE           6                               

                CAF             IM30TNIF                        # FRESH START IMU INITIALIZATION.
                TS              IMODES30                        

                CAF             BIT10                           # REMOVE IMU FAIL INHIBIT IN 5 SECS.
                TC              WAITLIST                        
                EBANK=          LST1                            
                2CADR           IFAILOK                         

# Page 90
                EXTEND                                          # SETTING T5RUPT FOR SETIDLER PROGRAM
                DCA             SETADR                          # THE SETIDLER PROGRAM ASSURES 1 SECOND
                DXCH            T5AD6                           # DELAY BEFORE THE DAPIDLER BEING.

                CAF             LNORMT4                         
                TS              T4LOC                           

                CA              LDNTMGO                         
                TS              L                               
                LXCH            EBANK                           

                EBANK=          DNTMGOTO                        

                CA              LDNPHAS1                        
                TS              DNTMGOTO                        

                CA              SETCDULM                        
                TS              CDULMIT                         # OVERWRITE IN ERASABLE LOAD IF DESIRED

                CA              IDNCDUN                         
                TS              DNCDUN                          # OVERWRITE IN ERASABLE LOAD IF DESIRED.

                LXCH            EBANK                           

                EBANK=          LST1                            

                TC              MR.CLEAN                        # DEACTIVATE ALL RESTART GROUPS.

                RELINT                                          # LET AN INTERRUPT IN.
                NOOP                                            
                INHINT                                          

                TC              IBNKCALL                        
                CADR            1STENGOF                        

P00H3           CA              ZERO                            
                TS              MODREG                          
                TS              PHASENUM                        

ENDRSTRT        RELINT                                          
                TC              BANKCALL                        # DISPLAY MAJOR MODE.
                CADR            DSPMM                           

                TC              FLAG1UP                         # TURN ON RESTARTABILITY FLAG.
                OCT             4000                            

                TCF             DUMMYJOB        +2              # DONT ZERO NEWJOB

# Page 91
MR.CLEAN        CAF             ELEVEN                          # INITIALIZE PHASE TABLE.  DO IT THIS WAY
 +1             TS              BUF                             # TO MINIMIZE THE TIME OF PHASE TABLE

                CS              ZERO                            # DISAGREEMENT.
                ZL                                              
                INDEX           BUF                             
                DXCH            -PHASE1         -1              

                CCS             BUF                             
                CCS             A                               
                TCF             MR.CLEAN        +1              

                TC              Q                               

# Page 92
# COMES HERE FROM LOCATION 4000, GOJAM, RESTART ANY PROGRAMS WHICH MAY HAVE BEEN RUNNING AT THE TIME.

GOPROG          INCR            REDOCTR                         # ANOTHER RESTART.

                LXCH            Q                               
                DXCH            RSB&Q                           # SAVE BBANK & Q FOR RESTART ANALYSIS

                TC              STARTSUB                        

                CA              BIT15                           # TEST THE OSC FAIL BIT TO SEE IF WE HAVE
                EXTEND                                          # HAD A POWER TRANSIENT.  IF SO, ATTEMPT
                WAND            33                              # A RESTART.  IF NOT, CHECK THE PRESENT
                EXTEND                                          # STATE OF AGC WARNING
                BZF             LIGHTSET                        

                CA              BIT14                           # IF AGC WARNING ON (BIT = 0), DO A FRESH
                EXTEND                                          # START ON THE ASSUMPTION THAT WE'RE IN A
                RAND            33                              # RESTART LOOP.
                EXTEND                                          
                BZF             DOFSTART                        

LIGHTSET        EXTEND                                          # DONT TRY TO RESTART IF ERROR
                READ            15                              # AND MARK REJECT BUTTONS DEPRESSED.
                AD              -ELR                            
                EXTEND                                          
                BZF             +2                              
                TCF             +7                              

                CAF             BIT5                            
                EXTEND                                          
                RAND            16                              
                AD              -MKREJ                          
                EXTEND                                          
                BZF             DOFSTART                        

                CA              ERESTORE                        # IF SELF-CHECK ERASABLE-MEMORY TEST WAS
                EXTEND                                          # INTERRUPTED BY A RESTART, DOUBT ERASABLE
                BZF             +2                              # AND DO A FRESH START.
                TCF             DOFSTART                        

                CA              9,6,4                           # LEAVE PROG ALARM, GIMBAL LOCK & NO ATT
                MASK            DSPTAB          +11D            # LAMPS INTACT ON RESTART.
                AD              BIT15                           
                XCH             DSPTAB          +11D            # IF NO ATT LAMP WAS ON, LEAVE ISS IN
                MASK            BIT4                            # COARSE ALIGN.
                EXTEND                                          
                WOR             12                              

                CAF             IFAILINH                        # LEAVE IMU FAILURE INHIBITS INTACT ON
                MASK            IMODES30                        # RESTART, RESETTING ALL FAILURE CODES.

# Page 93
                AD              IM30INIR                        # THE RECORD OF THE ISS OPERATE BIT IS
                TS              IMODES30                        # ALSO LEFT ALONE (206 ONLY).

                EXTEND                                          # SETTING T5RUPT FOR DAPIDLER PROGRAM
                DCA             IDLEADR                         
                DXCH            T5ADR                           

                CAF             PRIO37                          # DISPLAY FAILREG AS INDICATION OF RESTART
                TC              NOVAC                           # OR TO DISPLAY ABORT CODE AS ABOVE.
                EBANK=          LST1                            
                2CADR           DOALARM                         

                CS              T4LOC                           # SEE IF LMP COMMAND WAS SITTING IN CH 10
                AD              LLMPRS2                         # WHEN RESTART OCCURRED.  IF SO, SET BIT 15
                EXTEND                                          # BACK TO ZERO SO THE COMMAND WILL BE
                BZF             LMPRUPT                         # RESENT.

                CCS             LMPOUTT                         # IF NOT, SEE IF UPDATE OF REFERENCE
                AD              ONE                             # POINTER (LMPOUT) WAS IN PROCESS.  IF SO,
                TS              LMPOUT                          # LMPOUTT IS NON-NEGATIVE.
                CS              ONE                             # SHOW LMPOUT UPDATED.
                TS              LMPOUTT                         
                TCF             T4LOCRST                        

LMPRUPT         INDEX           LMPOUT                          
                CS              LMPCMD                          
                MASK            BIT15                           
                INDEX           LMPOUT                          
                ADS             LMPCMD                          

T4LOCRST        CAF             LNORMT4                         
                TS              T4LOC                           

                CA              BIT4                            # TURN THROTTLE COUNTER ON.  (IF EMPTY,
                EXTEND                                          # NO HARM DONE.  IF NON-EMPTY, ASSUME
                WOR             14                              # CONTENTS ARE VALID.)

                CAF             BIT12                           # TEST THE RESTARTABILITY FLAG.
                MASK            FLAGWRD1                        
                CCS             A                               
                TCF             +3                              # RESTARTABLE.
                TC              POSTJUMP                        # NOT RESTARTABLE.  DO A FAKESTART.
                CADR            FAKESTRT                        

GOPROG2         RELINT                                          
                NOOP                                            
                INHINT                                          # LET AN INTERRUPT IN

                CAF             NUMGRPS                         # VERIFY PHASE TABLE AGREEMENT.
PCLOOP          TS              MPAC            +5              
# Page 94
                DOUBLE                                          
                EXTEND                                          
                INDEX           A                               
                DCA             -PHASE1                         # COMPLEMENT INTO A - DIRECT INTO L.
                EXTEND                                          
                RXOR            L                               # RESULT MUST BE -0 FOR AGREEMENT.
                CCS             A                               
                TCF             PTBAD                           # RESTART FAILURE.
                TCF             PTBAD                           
                TCF             PTBAD                           

                CCS             MPAC            +5              # PROCESS ALL RESTART GROUPS.
                TCF             PCLOOP                          

                TS              MPAC            +6              # SET TO +0.

                CAF             NUMGRPS                         # SEE IF ANY GROUPS RUNNING.
NXTRST          TS              MPAC            +5              
                DOUBLE                                          
                INDEX           A                               
                CCS             PHASE1                          
                TCF             PACTIVE                         # PNZ - GROUP ACTIVE.
                TCF             PINACT                          # +0 - GROUP NOT RUNNING.

PACTIVE         TS              MPAC                            
                INCR            MPAC                            # ABS OF PHASE.
                INCR            MPAC            +6              # INDICATE GROUP DEMANDS PRESENT.
                CAF             RACTCADR                        # GO TO RESTARTS AND PROCESS PHASE INFO.
                TCF             SWCALL                          # MUST RETURN TO SWRETURN.

PINACT          CCS             MPAC            +5              # PROCESS ALL RESTART GROUPS.
                TCF             NXTRST                          

                CCS             MPAC            +6              # SEE IF ANY GROUPS WERE ACTIVE.
                TCF             ENDRSTRT                        # YES, THERE WERE.

                TC              ALARM                           # RESTART WITH NO ACTIVE GROUPS.
                OCT             1110                            

                CS              FLATWRD1                        # WAS THE RESTARTABILITY FLAG SET?
                MASK            BIT12                           
                CCS             A                               
                TCF             P00H2                           # NO.
                TS              MODREG                          # YES.  SET MAJOR MODE TO 00.
                TCF             ENDRSTRT                        

PTBAD           TC              ALARM                           # SET ALARM TO SHOW PHASE TABLE FAILURE.
                OCT             1107                            

                INHINT                                          
# Page 95
                TCF             DOFSTART                        

RACTCADR        CADR            RESTARTS                        

ENEMA           INHINT                                          # HAVING PRESET PHASE REGISTERS, DO A
                TC              STARTSB2                        # PSEUDO-RESTART.  (THE RESTARTABILITY
                TCF             GOPROG2                         # FLAG MUST BE SET WHEN ENEMA IS CALLED.)

# Page 96
# INITIALIZATION COMMON TO BOTH FRESH START AND RESTART.

STARTSUB        CA              ZERO                            
                EXTEND                                          # TURN THE RCS JETS OFF.
                WRITE           5                               
                EXTEND                                          
                WRITE           6                               

                EXTEND                                          
                WRITE           12                              # TURN OFF TRIM GIMBAL

                CA              POSMAX                          
                TS              TIME3                           # 37777 TO TIME3.
                AD              MINUS2                          
                TS              TIME4                           # 37775 TO TIME4.
                AD              NEGONE                          
                TS              TIME5                           # 37774 TO TIME5.

STARTSB2        CAF             ZERO                            # ENTRY FROM P00 AND FORGETIT.
                EXTEND                                          
                WRITE           7                               # NOTHING IN SUNBURST IS IN BANKS 40 - 43.
                EXTEND                                          
                WRITE           11                              
                EXTEND                                          
                WRITE           14                              

                CA              TRIMGIMB                        # TURN OFF ALL BITS BUT TRIM GIMBAL.
                EXTEND                                          
                WAND            12                              

                CAF             PRIO34                          # ENABLE INTERRUPTS
                EXTEND                                          
                WRITE           13                              

                EBANK=          LST1                            

                CAF             STARTEB                         
                TS              EBANK                           # SET FOR E3

                CAF             NEG1/2                          # INITIALIZE WAITLIST DELTA-TS.
                TS              LST1            +7              
                TS              LST1            +6              
                TS              LST1            +5              
                TS              LST1            +4              
                TS              LST1            +3              
                TS              LST1            +2              
                TS              LST1            +1              
                TS              LST1                            

                CS              ENDTASK                         
# Page 97                
                TS              LST2                            
                TS              LST2            +2              
                TS              LST2            +4              
                TS              LST2            +6              
                TS              LST2            +8D             
                TS              LST2            +10D            
                TS              LST2            +12D            
                TS              LST2            +14D            
                TS              LST2            +16D            
                CS              ENDTASK         +1              
                TS              LST2            +1              
                TS              LST2            +3              
                TS              LST2            +5              
                TS              LST2            +7              
                TS              LST2            +9D             
                TS              LST2            +11D            
                TS              LST2            +13D            
                TS              LST2            +15D            
                TS              LST2            +17D            

                CS              ZERO                            # MAKE ALL EXECUTIVE REGISTER SETS
                TS              PRIORITY                        # AVAILABLE.
                TS              PRIORITY        +12D            
                TS              PRIORITY        +24D            
                TS              PRIORITY        +36D            
                TS              PRIORITY        +48D            
                TS              PRIORITY        +60D            
                TS              PRIORITY        +72D            

                TS              NEWJOB                          # SHOWS NO ACTIVE JOBS.

                CAF             VAC1ADRC                        # MAKE ALL VAC AREAS AVAILABLE.
                TS              VAC1USE                         
                AD              LTHVACA                         
                TS              VAC2USE                         
                AD              LTHVACA                         
                TS              VAC3USE                         
                AD              LTHVACA                         
                TS              VAC4USE                         
                AD              LTHVACA                         
                TS              VAC5USE                         

                CAF             TEN                             # TURN OFF ALL DISPLAY SYSTEM RELAYS.
                TS              DIDFLG                          # DISPLAY INERTIAL DATA FLAG.
DSPOFF          TS              MPAC                            
                CS              BIT12                           
                INDEX           MPAC                            
                TS              DSPTAB                          
                CCS             MPAC                            
                TC              DSPOFF                          
# Page 98
                TS              INLINK                          
                TS              DSPCNT                          
                TS              CADRSTOR                        
                TS              REQRET                          
                TS              CLPASS                          
                TS              DSPLOCK                         
                TS              MONSAVE                         # KILL MONITOR
                TS              MONSAVE1                        
                TS              GRABLOCK                        
                TS              VERBREG                         
                TS              NOUNREG                         
                TS              DSPLIST                         
                TS              DSPLIST         +1              
                TS              DSPLIST         +2              

                TS              MARKSTAT                        
                TS              EXTVBACT                        # MAKE EXTENDED VERBS AVAILABLE
                TS              IMUCADR                         
                TS              OPTCADR                         
                TS              RADCADR                         
                TS              LGYRO                           
                TS              DSRUPTSW                        
                CAF             NOUTCON                         
                TS              NOUT                            

                CS              ONE                             # NO RADAR DESIGNATION.
                TS              SAMPLIM                         # NO RADAR RUPTS EXPECTED.

                CAF             IM33INIT                        # NO PIP OR TM FAILS.
                TS              IMODES33                        

                CAF             BIT6                            # SET LR POS.
                EXTEND                                          
                RAND            33                              
                AD              RMODINIT                        
                TS              RADMODES                        

                CAF             LESCHK                          # SELF CHECK GO-TO REGISTER.
                TS              SELFRET                         

                CS              VD1                             
                TS              DSPCOUNT                        

                CAF             NOMTMLST                        # SET UP NOMINAL DOWNLINK LIST.
                TS              DNLSTADR                        

                TC              Q                               

LDNPHAS1        GENADR          DNPHASE1                        
# Page 99
LDNTMGO         ECADR           DNTMGOTO                        
NOMTMLST        GENADR          NOMDNLST                        
SETCDULM        DEC             0.055555555                     # 10 DEGREES, SCALED IN HALF-REVS.
IDNCDUN         DEC             198                             # 199 CDU SAMPLES + ONE ID = 4 SES.
LESCHK          GENADR          SELFCHK                         
LLMPRS2         GENADR          LMPRESET                        
VAC1ADRC        ADRES           VAC1USE                         
LTHVACA         DEC             44                              
STARTEB         ECADR           LST1                            
NUMGRPS         EQUALS          FIVE                            # SIX GROUPS CURRENTLY.
-ELR            OCT             -22                             # -ERROR LIGHT RESET KEY CODE.
-MKREJ          OCT             -20                             # - MARK REJECT.
IM30INIF        OCT             37411                           # INHIBITS IMU FAIL FOR 5 SEC AND PIP ISSW
IM30INIR        OCT             37400                           # LEAVE FAIL INHIBITS ALONE.
IM33INIT        OCT             16000                           # NO PIP OR TM FAIL SIGNALS.
9,6,4           OCT             450                             
RMODINIT        OCT             00102                           

SWINIT          OCT             0                               
                OCT             0                               
                OCT             00005                           
DAPINIT         OCT             40512                           # DB SET IN SETIDLE
                OCT             0                               

                EBANK=          DT                              
IDLEADR         2CADR           DAPIDLER                        

                EBANK=          DT                              
SETADR          2CADR           SETIDLE                         
