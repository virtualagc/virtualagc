### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
## Purpose:     A section of an attempt to reconstruct Sundance revision 306
##              as closely as possible with available information. Sundance
##              306 is the source code for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 9. This program was created
##              using the mixed-revision SundanceXXX as a starting point, and
##              pulling back features from Luminary 69 believed to have been
##              added based on memos, checklists, observed address changes,
##              or the Sundance GSOPs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-07-24 MAS  Created from SundanceXXX.



                SETLOC          4000 
                        
                COUNT*          $$/RUPTS                # FIX-FIX LEAD INS
                INHINT                                  # GO
                CAF             GOBB    
                XCH             BBANK   
                TCF             GOPROG  
                                
                DXCH            ARUPT                   # T6RUPT
                EXTEND          
                DCA             T6ADR   
                DTCB            
                                
                DXCH            ARUPT                   # T5RUPT - AUTOPILOT
                CS              TIME5
                AD              .5SEC
                TCF             T5RUPT
                                
                DXCH            ARUPT                   # T3RUPT
                CAF             T3RPTBB 
                XCH             BBANK   
                TCF             T3RUPT  
                                
                DXCH            ARUPT                   # T4RUPT
                CAF             T4RPTBB 
                XCH             BBANK   
                TCF             T4RUPT  
                                
                DXCH            ARUPT                   # KEYRUPT1
                CAF             KEYRPTBB        
                XCH             BBANK   
                TCF             KEYRUPT1        
                                
                DXCH            ARUPT                   # KEYRUPT2
                CAF             MKRUPTBB        
                XCH             BBANK   
                TCF             MARKRUPT        
                                
                DXCH            ARUPT                   # UPRUPT
                CAF             UPRPTBB 
                XCH             BBANK   
                TCF             UPRUPT  
                                
                DXCH            ARUPT                   # DOWNRUPT
                CAF             DWNRPTBB        
                XCH             BBANK   
                TCF             DODOWNTM        
                                
                DXCH            ARUPT                   # RADAR RUPT
                CAF             RDRPTBB 
                XCH             BBANK   
                TCF             RADAREAD        
                                
                DXCH            ARUPT                   # RUPT10 IS USED ONLY BY LANDING GUIDANCE
                CA              RUPT10BB        
                XCH             BBANK   
                TCF             PITFALL 
                
                
                EBANK=          LST1                    # RESTART USES E0, E3
GOBB            BBCON           GOPROG  
                
                EBANK=          TIME1
T6RPTBB         BBCON           RESUME                  # ***FIX LATER***
                
                EBANK=          LST1    
T3RPTBB         BBCON           T3RUPT  
                
                EBANK=          KEYTEMP1        
KEYRPTBB        BBCON           KEYRUPT1        
                
                EBANK=          AOTAZ   
MKRUPTBB        BBCON           MARKRUPT        
                
UPRPTBB         =               KEYRPTBB        
                
                EBANK=          DNTMBUFF        
DWNRPTBB        BBCON           DODOWNTM        
                
                EBANK=          RADMODES        
RDRPTBB         BBCON           RADAREAD        
                
                EBANK=          M11     
T4RPTBB         BBCON           T4RUPT  
                
                EBANK=          ELVIRA  
RUPT10BB        BBCON           PITFALL 
                                        
T5RUPT          EXTEND
                BZMF            NOQBRSM
                EXTEND
                DCA             T5ADR
                DTCB
