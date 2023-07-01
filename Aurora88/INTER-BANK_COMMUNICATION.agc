### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTER-BANK_COMMUNICATION.agc
## Purpose:     A section of Aurora 88.
##              It is part of the reconstructed source code for the final
##              release of the Lunar Module system test software. No original
##              listings of this program are available; instead, this file
##              was created via disassembly of dumps of Aurora 88 core rope
##              modules and comparison with other AGC programs.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2023-06-30 MAS  Created from Aurora 12.
##              2023-07-12 MAS  Updated for Aurora 88.


#          THE FOLLOWING ROUTINE CAN BE USED TO CALL A SUBROUTINE IN ANOTHER BANK. IN THE BANKCALL VERSION, THE
# CADR OF THE SUBROUTINE IMMEDIATELY FOLLOWS THE  TC BANKCALL  INSTRUCTION, WITH C(A) AND C(L) PRESERVED.

                SETLOC  ENDINTFF
BANKCALL        DXCH    BUF2            # SAVE INCOMING A,L.
                INDEX   Q               # PICK UP CADR.
                CA      0
                INCR    Q               # SO WE RETURN TO THE LOC. AFTER THE CADR.

#          SWCALL IS IDENTICAL TO BANKCALL, EXCEPT THAT THE CADR ARRIVES IN A.

SWCALL          TS      L
                LXCH    FBANK           # SWITCH BANKS, SAVING RETURN.
                MASK    LOW10           # GET SUB-ADDRESS OF CADR.
                XCH     Q               # A,L NOW CONTAINS DP RETURN.
                DXCH    BUF2            # RESTORING INPUTS IF THIS IS A BANKCALL.
                INDEX   Q
                TC      10000           # SETTING Q TO SWRETURN.

SWRETURN        XCH     BUF2 +1         # COMES HERE TO RETURN TO CALLER. C(A,L)
                XCH     FBANK           # ARE PRESERVED FOR RETURN.
                XCH     BUF2 +1
                TC      BUF2

#          THE FOLLOWING ROUTINE CAN BE USED AS A UNILATERAL JUMP WITH C(A,L) PRESERVED AND THE CADR IMMEDIATELY
# FOLLOWING THE TC POSTJUMP INSTRUCTION.

POSTJUMP        XCH     Q               # SAVE INCOMING C(A).
                INDEX   A               # GET CADR.
                CA      0

#          BANKJUMP IS THE SAME AS POSTJUMP, EXCEPT THAT THE CADR ARRIVES IN A.

BANKJUMP        TS      FBANK
                MASK    LOW10
                XCH     Q               # RESTORING INPUT C(A) IF THIS WAS A
                INDEX   Q               # POSTJUMP.
                TCF     10000

# THE FOLLOWING ROUTINE GETS THE RETURN CADR SAVED BY SWCALL OR BANKCALL AND LEAVES IT IN A.

MAKECADR        CAF     LOW10
                MASK    BUF2
                AD      BUF2 +1
                TC      Q

# THE FOLLOWING ROUTINE OBTAINS THE TWO WORDS BEGINNING AT THE ADDRESS ARRIVING IN A, AND LEAVES THEM IN
# A,L.

DATACALL        TS      L
                LXCH    FBANK
                LXCH    MPTEMP          # SAVE FORMER BANK.
                MASK    LOW10
                EXTEND
                INDEX   A
                DCA     10000

                XCH     MPTEMP
                TS      FBANK           # RESTORE FBANK.
                CA      MPTEMP
                TC      Q

# THE FOLLOWING ROUTINES ARE IDENTICAL TO BANKCALL AND SWCALL EXCEPT THAT THEY ARE USED IN INTERRUPT.

IBNKCALL        DXCH    RUPTREG3        # USES RUPTREG3,4 FOR DP RETURN ADDRESS.
                INDEX   Q
                CAF     0
                INCR    Q

ISWCALL         TS      L
                LXCH    FBANK
                MASK    LOW10
                XCH     Q
                DXCH    RUPTREG3
                INDEX   Q
                TC      10000

ISWRETRN        XCH     RUPTREG4
                XCH     FBANK
                XCH     RUPTREG4
                TC      RUPTREG3

ENDIBNKF        EQUALS
