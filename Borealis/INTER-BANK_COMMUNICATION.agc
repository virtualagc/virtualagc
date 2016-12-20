### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTER-BANK_COMMUNICATION.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-20 MAS  Created from Aurora 12 (with much DAP stuff removed).

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
ENDIBNKF        EQUALS                                          
