### FILE="Main.annotation"
## Copyright:    Public domain.
## Filename:     INTER-BANK_COMMUNICATION.agc
## Purpose:      Part of the source code for Aurora (revision 12).
## Assembler:    yaYUL
## Contact:      Ron Burkey <info@sandroid.org>.
## Website:      https://www.ibiblio.org/apollo.
## Pages:        29-33
## Mod history:  2016-09-20 JL   Created.
##               2016-09-21 MAS  Filled out.
##               2016-10-15 HG   Fix label ISWCALLL -> ISWCALL
##		 2016-12-07 RSB	 Proofed the comments, mostly with 
##				 octopus/ProoferComments, but some pages
##				 needed to be done manually.  Only some
##				 column alignments were changed.

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

## Page 29
#          THE FOLLOWING ROUTINE CAN BE USED TO CALL A SUBROUTINE IN ANOTHER BANK. IN THE BANKCALL VERSION, THE
# CADR OF THE SUBROUTINE IMMEDIATELY FOLLOWS THE  TC BANKCALL  INSTRUCTION, WITH C(A) AND C(L) PRESERVED.

                SETLOC          ENDINTFF                        
BANKCALL        DXCH            BUF2                            # SAVE INCOMING A,L.
                INDEX           Q                               # PICK UP CADR.
                CA              0                               
                INCR            Q                               # SO WE RETURN TO THE LOC. AFTER THE CADR.

#          SWCALL IS IDENTICAL TO BANKCALL, EXCEPT THAT THE CADR ARRIVES IN A.

SWCALL          TS              L                               
                LXCH            FBANK                           # SWITCH BANKS, SAVING RETURN.
                MASK            LOW10                           # GET SUB-ADDRESS OF CADR.
                XCH             Q                               # A,L NOW CONTAINS DP RETURN.
                DXCH            BUF2                            # RESTORING INPUTS IF THIS IS A BANKCALL.
                INDEX           Q                               
                TC              10000                           # SETTING Q TO SWRETURN.

SWRETURN        XCH             BUF2            +1              # COMES HERE TO RETURN TO CALLER. C(A,L)
                XCH             FBANK                           # ARE PRESERVED FOR RETURN.
                XCH             BUF2            +1              
                TC              BUF2                            

#          THE FOLLOWING ROUTINE CAN BE USED AS A UNILATERAL JUMP WITH C(A,L) PRESERVED AND THE CADR IMMEDIATELY
# FOLLOWING THE TC POSTJUMP INSTRUCTION.

POSTJUMP        XCH             Q                               # SAVE INCOMING C(A).
                INDEX           A                               # GET CADR.
                CA              0                               

#          BANKJUMP IS THE SAME AS POSTJUMP, EXCEPT THAT THE CADR ARRIVES IN A.

BANKJUMP        TS              FBANK                           
                MASK            LOW10                           
                XCH             Q                               # RESTORING INPUT C(A) IF THIS WAS A
                INDEX           Q                               # POSTJUMP.
                TCF             10000                           

## Page 30
# THE FOLLOWING ROUTINE GETS THE RETURN CADR SAVED BY SWCALL OR BANKCALL AND LEAVES IT IN A.

MAKECADR        CAF             LOW10                           
                MASK            BUF2                            
                AD              BUF2            +1              
                TC              Q                               

# THE FOLLOWING ROUTINE OBTAINS THE TWO WORDS BEGINNING AT THE ADDRESS ARRIVING IN A, AND LEAVES THEM IN
# A,L.

DATACALL        TS              L                               
                LXCH            FBANK                           
                LXCH            MPTEMP                          # SAVE FORMER BANK.
                MASK            LOW10                           
                EXTEND                                          
                INDEX           A                               
                DCA             10000                           

                XCH             MPTEMP                          
                TS              FBANK                           # RESTORE FBANK.
                CA              MPTEMP                          
                TC              Q                               

## Page 31
# THE FOLLOWING SUBROUTINES PROVIDE TO THE BASIC PROGRAMMER ENTRY INTO AND RETURN FROM ANY INTERPRETIVE
# CODING WHICH DOES NOT USE THE ENTERING CONTENTS OF Q AND WHICH RETURNS VIA DANZIG. C(A) AND C(L) ARE SAVED.

# USER'S RESPONSIBILITY TO FILL IN ADVANCE THE APPROPRIATE OPERAND AND ADDRESS REGISTERS USED BY THE
# INTERPRETIVE CODING SUCH AS MPAC, BUF, ADDRWD, ETC.; AND TO CONFIRM THAT THE INTERPRETIVE CODING MEETS THE
# ABOVE RESTRICTIONS WITH RESPECT TO Q AND DANZIG.

# USEPRET AND USPRCADR MUST NOT BE USED IN INTERRUPT.

# 1. USEPRET ACCESSES INTERPRETIVE CODING WHICH CAN BE ENTERED WITHOUT CHANGING FBANK.
#    THE CALLING SEQUENCE IS AS FOLLOWS:

# L             TC              USEPRET
# L+1           TC,TCF          INTPRETX                        TC,TCF MEANS TC OR TCF
#                                                               INTPRETX IS THE INTERPRETIVE CODING
#                                                               RETURN IS TO L+2

# 2. USPRCADR ACCESSES INTERPRETIVE CODING IN OTHER THAN THE USER'S FBANK. THE CALLING SEQUENCE IS AS FOLLOWS:

# L             TC              USPRCADR
# L+1           CADR            INTPRETX                        INTPRETX IS THE INTERPRETIVE CODING
#                                                               RETURN IS TO L+2

USEPRET         XCH             Q                               # FETCH Q, SAVING A
                TS              LOC                             # L+1 TO LOC
                CA              FBANK                           
                TS              BANKSET                         # USERS BANK TO BANKSET
                CA              BIT8                            
                TS              EDOP                            # EXIT INSTRUCTION TO EDOP
                CA              Q                               # RETRIEVE ORIGINAL A
                TC              LOC                             

USPRCADR        TS              LOC                             # SAVE A
                CA              BIT8                            
                TS              EDOP                            # EXIT INSTRUCTION TO EDOP
                CA              FBANK                           
                TS              BANKSET                         # USERS BANK TO BANKSET
                INDEX           Q                               
                CA              0                               
                TS              FBANK                           # INTERPRETIVE BANK TO FBANK
                MASK            LOW10                           # YIELDS INTERPRETIVE RELATIVE ADDRESS
                XCH             Q                               # INTERPRETIVE ADDRESS TO Q, FETCHING L+1
                XCH             LOC                             # L+1 TO LOC, RETRIEVING ORIGINAL A
                INDEX           Q                               
                TCF             10000                           

## Page 32
# THE FOLLOWING ROUTINES ARE IDENTICAL TO BANKCALL AND SWCALL EXCEPT THAT THEY ARE USED IN INTERRUPT.

IBNKCALL        DXCH            RUPTREG3                        # USES RUPTREG3,4 FOR DP RETURN ADDRESS.
                INDEX           Q                               
                CAF             0                               
                INCR            Q                               

ISWCALL         TS              L                               
                LXCH            FBANK                           
                MASK            LOW10                           
                XCH             Q                               
                DXCH            RUPTREG3                        
                INDEX           Q                               
                TC              10000                           

ISWRETRN        XCH             RUPTREG4                        
                XCH             FBANK                           
                XCH             RUPTREG4                        
                TC              RUPTREG3                        

## Page 33
# T6-RUPT PROGRAMS.

# ENTER HERE AFTER A T6-RUPT.DETERMINE IF IT IS A GENUINE RUPT.

DOT6RUPT        TC              T6JOBCHK                        
                TCF             RESUME                          

# T6JOBCHK DETERMINES IF T6 = -0 ( A T6RUPT HAS OCCURRED ) OR IF T6
# EQUALS +0 ( T6 NOT COUNTING DOWN ) OR =SOME POS.OR NEG. NUMBER ( T6
# BEING DECREMENTED AND NO RUPT IS NEEDED ).

T6JOBCHK        CCS             TIME6                           
                TC              Q                               
                TC              Q                               
                TC              Q                               
# T6JOB EXECUTES A JET STATE CHANGE AND SETS UP ANY ADDITIONAL T6 RUPTS
# WHICH MIGHT BE NECESSARY.

T6JOB           CA              ZERO                            
                XCH             T6NEXT          +1              
                XCH             T6NEXT                          
                TS              TIME6                           
                EXTEND                                          
                BZF             T6ZERO                          
                CA              BIT15                           
                EXTEND                                          
                WOR             13                              
                CA              ZERO                            
                XCH             T6NEXTJT        +2              
                XCH             T6NEXTJT        +1              
                XCH             T6NEXTJT                        
WRITEJTS        EXTEND                                          
                BZMF            WRITEQR                         
                EXTEND                                          
                WRITE           6                               
                TC              Q                               
WRITEQR         EXTEND                                          
                WRITE           5                               
                TC              Q                               
T6ZERO          CA              T6NEXTJT                        
                TCF             WRITEJTS                        
ENDIBNKF        EQUALS                                          
