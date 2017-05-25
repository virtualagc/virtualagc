### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     ASCENT_INERTIA_UPDATER.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        639-641
## Mod history:  2016-09-20 JL   Created.
##               2016-09-21 MC   Filled out.
##               2016-10-05 HG   Insert missed TC ASCENGON
##               2016-10-16 HG   Fix operand 1/3JTS -> 1/2JTS
##		 2016-12-08 RSB	 Proofed comments with octopus/ProoferComments
##				 but no errors found.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the private collection of 
## Don Eyles.  The digitization was performed by archive.org.

## Notations on the hardcopy document read, in part:

##       473423A YUL SYSTEM FOR BLK2: REVISION 12 of PROGRAM AURORA BY DAP GROUP
##       NOV 10, 1966

##       [Note that this is the date the hardcopy was made, not the
##       date of the program revision or the assembly.]

## The scan images (with suitable reduction in storage size and consequent 
## reduction in image quality) are available online at 
##       https://www.ibiblio.org/apollo.  
## The original high-quality digital images are available at archive.org:
##       https://archive.org/details/aurora00dapg

## Page 639

IXXTASK         TC              JACCESTP                        
                TC              ASCENGON                        

                EXTEND                                          
                DIM             IXX                             
                CAF             IXXTIME                         
                TC              WAITLIST                        
                2CADR           IXXTASK                         

                TCF             TASKOVER                        

IYYTASK         TC              JACCESTQ                        

                TC              ASCENGON                        

                EXTEND                                          
                DIM             IYY                             
                CAF             IYYTIME                         
                TC              WAITLIST                        
                2CADR           IYYTASK                         

                TCF             TASKOVER                        

IZZTASK         TC              JACCESTR    

                TC              ASCENGON

                EXTEND                                          
                DIM             IZZ                             
                CAF             IZZTIME                         
                TC              WAITLIST                        
                2CADR           IZZTASK                         

                TCF             TASKOVER                        

IXXTIME         DEC             200                             
IYYTIME         DEC             1300                            
IZZTIME         DEC             180                             

ASCENGON        CAF             BIT8                            
                MASK            DAPBOOLS                        
                CCS             A                               
                TC              Q                               
                TCF             TASKOVER                        

JACCESTP        CAE             IXX                             
                ZL                                              
                EXTEND                                          
                DV              4JETTORK                        

## Page 640
                DOUBLE                                          
                TS              1/2JTSP                         

                CAF             JETTORK                         
                ZL                                              
                EXTEND                                          
                DV              IXX                             
                TS              1JACC                           

                TC              Q                               

JACCESTQ        CAE             IYY                             
                ZL                                              
                EXTEND                                          
                DV              JETTORK4                        
                TS              1/NJTSQ                         

                DOUBLE                                          
                TS              1/2JTSQ                         

                CAF             JETTORK1                        
                ZL                                              
                EXTEND                                          
                DV              IYY                             
                TS              1JACCQ                          

                TC              Q                               
JACCESTR        CAE             IZZ                             
                ZL                                              
                EXTEND                                          
                DV              JETTORK4                        
                TS              1/NJTSR                         

                DOUBLE                                          
                TS              1/2JTSR                         

                CAF             JETTORK1                        
                ZL                                              
                EXTEND                                          
                DV              IZZ                             
                TS              1JACCR                          

COMMONQR        CAE             1/2JTSQ                         
                AD              1/2JTSR                         
                EXTEND                                          
                MP              .707WL                          
                TS              1/2JETSU                        # TEMP

                CAE             1/2JTSQ                         
                EXTEND                                          

## Page 641

                MP              1/2JTSR                         
                EXTEND                                          
                DV              1/2JETSU                        # TEMP
                TS              1/2JETSU                        
                TS              1/2JETSV                        

                CAE             1JACCQ                          
                AD              1JACCR                          
                EXTEND                                          
                MP              0.35356                         
                TS              1JACCU                          
                TS              1JACCV                          

                TC              Q                               

JETTORK         DEC             0.00243                         # 500 FT LBS. SCALED AT PI*2(+16)
JETTORK1        DEC             0.00267                         # 550 FT LBS. SCALED AT PI*2(+16)
0.35356         DEC             0.35356                         
ENDDAP25        EQUALS                                          
