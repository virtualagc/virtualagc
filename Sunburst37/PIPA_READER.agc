### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PIPA_READER.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-29 MAS  Adapted from Luminary 099.
## 		2016-10-31 RSB	Typos.
##		2016-12-06 RSB	Comment-proofing via octopus/ProoferComments;
##				changes were made.
##		2017-03-14 RSB	Comment-text fixes noted in proofing Luminary 116.

## Page 835
# *****  PIPA READER *****

#                 MOD NO. 00  BY D. LICKLY  DEC.9 1966

# FUNCTIONAL DESCRIPTION

#    SUBROUTINE TO READ PIPA COUNTERS, TRYING TO BE VERY CAREFUL SO THAT IT WILL BE RESTARTABLE.
#    PIPA READINGS ARE STORED IN THE VECTOR DELV. THE HIGH ORDER PART OF EACH COMPONENT CONTAINS THE PIPA READING,
#    RESTARTS BEGIN AT REREADAC.


#    AT THE END OF THE PIPA READER THE CDUS ARE READ AND STORED AS A
# VECTOR IN CDUTEMP.  THE HIGH ORDER PART OF EACH COMPONENT CONTAINS
# THE CDU READING IN 2S COMP IN THE ORDER CDUX,Y,Z.  THE THRUST
# VECTOR ESTIMATOR IN FINDCDUD REQUIRES THE CDUS BE READ AT PIPTIME.

# CALLING SEQUENCE AND EXIT

#    CALL VIA TC, ISWCALL, ETC.

#    EXIT IS VIA Q.


# INPUT

#    INPUT IS THROUGH THE COUNTERS PIPAX, PIPAY, PIPAZ, AND TIME2.

# OUTPUT

#    HIGH ORDER COMPONENTS OF THE VECTOR DELV CONTAIN THE PIPA READINGS.
#    PIPTIME CONTAINS TIME OF PIPA READING.


# DEBRIS (ERASABLE LOCATIONS DESTROYED BY PROGRAM)

#          TEMX   TEMY   TEMZ   PIPAGE


                BANK            30                              
PIPASR          EXTEND                                          
                DCA             TIME2                           
                DXCH            PIPTIME                         # CURRENT TIME  POSITIVE VALUE.

                CS              ZERO                            # INITIALIZE THESE AT NEG ZERO.
                TS              TEMX                            
                TS              TEMY                            
                TS              TEMZ                            

## Page 836
                CA              ZERO                            
                TS              DELVZ                           # OTHER DELVS OK INCLUDING LOW ORDER
                TS              DELVY                           

                TS              CDUTEMP         +1              # INITIALIZE THESE FOR FINDCDUD
                TS              CDUTEMP         +3
                TS              CDUTEMP         +5

                TS              PIPAGE                          # SHOW PIPA READING IN PROGRESS

REPIP1          EXTEND                                          
                DCS             PIPAX                           # X AND Y PIPS READ
                DXCH            TEMX                            
                DXCH            PIPAX                           # PIPAS SET TO NEG ZERO AS READ.
                TS              DELVX                           
                LXCH            DELVY                           

REPIP3          CS              PIPAZ                           # REPEAT PROCESS FOR Z PIP
                XCH             TEMZ                            
                XCH             PIPAZ                           
DODELVZ         TS              DELVZ                           

REPIP4          CA              CDUX                            # READ CDUS INTO HIGH ORDER CDUTEMPS
                TS              CDUTEMP                        
                CA              CDUY                            
                TS              CDUTEMP         +2
                CA              CDUZ                            
                TS              CDUTEMP         +4

                TC              Q                               



REREADAC        CCS             PHASE5                          # COMES HERE ON RESARTS.   IS PHASE 5 ON?
                TCF             +2                              # YES..  GO ON.
                TCF             TASKOVER                        # NO.. HAVE BEEN TO AVGEND SINCE GOJAM.

                CCS             PIPAGE                          # WAS 1 READING THE PIPS WHEN GOJAM OCCURD
                TCF             PIPREAD                         # PIP READING NOT STARTED. GO TO BEGINNING
                CAF             DONEADR                         # SET UP RETURN FROM PIPASR
                TS              Q                               

                CCS             DELVZ                           
                TCF             REPIP4                          # Z DONE, GO DO CDUS
                TCF             +3                              # Z NOT DONE, CHECK Y.
                TCF             REPIP4                          
                TCF             REPIP4                          

                ZL                                              
                CCS             DELVY                           
## Page 837
                TCF             +3                              
                TCF             CHKTEMX                         # Y NOT DONE, CHECK X.
                TCF             +1                              
                LXCH            PIPAZ                           # Y DONE, ZERO Z PIP.

                CCS             TEMZ                            
                CS              TEMZ                            # TEMZ NOT = -0, CONTAINS -PIPAZ VALUE.
                TCF             DODELVZ                         
                TCF             -2                              
                LXCH            DELVZ                           # TEMZ = -0, L HAS ZPIP VALUE.
                TCF             REPIP4                          

CHKTEMX         CCS             TEMX                            # HAS THIS CHANGED
                CS              TEMX                            # YES
                TCF             +3                              # YES
                TCF             -2                              # YES
                TCF             REPIP1                          # NO
                TS              DELVX                           

                CS              TEMY                            
                TS              DELVY                           

                CS              ZERO                            # ZERO X AND Y PIPS
                DXCH            PIPAX                           # L STILL ZERO FROM ABOVE

                TCF             REPIP3                          

DONEADR         GENADR          PIPSDONE                        
