### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_VERSION_CHECK.agc
## Purpose:     This program is designed to extensively test the Apollo Guidance Computer
##              (specifically the LM instantiation of it). It is built on top of a heavily
##              stripped-down Aurora 12, with all code ostensibly added by the DAP Group
##              removed. Instead Borealis expands upon the tests provided by Aurora,
##              including corrected tests from Retread 44 and tests from Ron Burkey's
##              Validation.
## Assembler:   yaYUL
## Contact:     Mike Stewart <mastewar1@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-01-15 MAS  Created to contain a simple program that exploits a bug
##                              in the original Block 2 design in an attempt to determine
##                              roughly which hardware version the code is running on.

                BANK            11

# This test attempts to identify if Borealis is running on an earlier (~2003100 - 2003200)
# AGC or a later one (~2003200 - 2003993), by exercising a hardware bug that was patched
# sometime between part numbers 2003200 and 2003100. It currently classifies the host AGC
# as either 2003100, or 2003200 and up, arbitrarily, since it's not clear whether this bug
# was fixed in 2003200 or only 2003993.

# The bug involves use of the "FUTEXT" signal to inhibit the check for pseudoinstructions
# in the case of a pseudo-instruction word (e.g. 00006) following an EXTEND instruction,
# since EXTEND EXTEND, EXTEND INHINT, and EXTEND RELINT are all illegal. FUTEXT is set,
# roughly, from the start of timepulse 8 of the MCT immediately preceding an EXTEND
# instruction, through to the beginning of timepulse 1 of that EXTEND's following extracode
# instruction.

# The pseudoinstruction check works by combining a signal from the parity pyramid, GNZRO,
# with the state of the three least significant bits in the G register. GNZRO is set high
# if the upper 13 bits of G are all 0, so the combined test is for the whole word to be
# 00006, 0004, or 00003. All of this must be true during phase 4 of timepulse 7; an
# additional signal, T7PHS4/, is constructed for the purpose of gating the check until
# that exact moment.

# The original 2003100 and 2003200 designs for the AGC inhibited the psuedoinstruction
# test by folding FUTEXT into GNZRO. Doing this prevented the upper 13 bits of G from
# being detected as all zero, even if they were, tricking the pseudoinstruction logic
# into thinking that the contents of G were different than they actually were.

# Unfortunately, GNZRO is also used in the construction of GEQZRO/, which is used by
# the TPZG control pulse to set branch register 2 if the contents of G are positive 0.
# TPZG would therefore fail if it occurred when the FUTEXT flip-flop was set. Normally
# this would not be an issue, since TPZG never occurs after timepulse 7 of an instruction,
# and FUTEXT is cleared at the end of the EXTEND.

# However, the exact conditions for clearing FUTEXT are that INKL be low at the start
# of timepulse 1. INKL is set high during all counter instructions. Since it is possible
# for a count to occur between an EXTEND and its following extracode instruction, it
# is possible for FUTEXT to remain set throughout that count instruction.

# The unprogrammed sequences PINC, MINC, PCDU, MCDU, and DINC all happen to generate
# TPZG. The first four all ignore the results; however, DINC uses TPZG to detect positive
# zero, in its check to see if it should 1) decrement the positive number and generate a
# POUT, 2) increment the negative number and generate a MOUT, or 3) leave the (plus or
# minus) zero alone and generate a ZOUT.

# If, therefore, a DINC count occurs between an EXTEND and its following instruction,
# and the contents of the counter being DINCed are positive zero, DINC will instead
# consider the register to be a non-zero positive number, decrement it to -1, and
# generate a POUT. The next DINC will increment it back to -0, generating an MOUT.
# And finally, a third DINC will detect the -0 and generate a ZOUT, as should have
# been done on the first DINC. So, in this situation, 3 DINCs and all three xOUT
# signals are generated, instead of just one DINC and one ZOUT as should happen.

# This issue was fixed sometime between 2003200 and 2003993 by moving the FUTEXT input
# from GNZRO to the construction of T7PHS4/. On MCTs during which FUTEXT is set, T7PHS4/
# will not go low during phase 4 of timepulse 7. This is not harmful, because T7PHS4/
# is not used for any other logic.

# This test attempts to trigger this hardware bug by putting +0 into TIME6, enabling
# it, and waiting for it to become non-zero. The waiting loop is constructed of only
# extracode instructions. Because counter interrupts are inhibited then the *next*
# instruction is a pseudoinstruction like EXTEND, but are permitted to occur between
# the EXTEND and its extracode, it's possible to construct a loop that guarantees all
# TIME6 DINCs will trigger the issue.  If it doesn't by the time a TIME6 count should
# have occurred, then we must be operating on a later AGC that has had the problem
# fixed.

AGCVER          CAF             VLOOPCNT        # Load the loop counter and store it in Q.
                TS              Q

                INHINT                          # Inhibit interrupts to make sure we don't
                                                # miss a TIME6 count
                CAF             ZERO
                TS              TIME6           # Load +0 into TIME6 and start it counting
                CAF             BIT15
                EXTEND
                WOR             CHAN13

VERLOOP         EXTEND                          # Decrement the loop counter using DIM
                DIM             Q
                EXTEND                          # Load it into A for checking
                READ            Q
                EXTEND                          # If the loop count has reached zero, we
                BZF             AGC200          # must be operation on a later AGC
                EXTEND
                DCA             TIME6           # Read in TIME6. If it is non-zero, then
                EXTEND                          # we have successfully triggered the bug
                BZF             VERLOOP         # and are on an earlier AGC

AGC100          CAF             PN100           # Load 100 for display as the part number
                TCF             +2

AGC200          CAF             PN200           # Load 200 for display as the part number
                TS              MPAC    +4
                CAF             PN2003          # Both part numbers start with 2003
                TS              MPAC    +3

                CAF             MPADR
                TS              MPAC    +2
                CAF             VERVNCON
                TC              NVSUB           # Display the part number (in MPAC+3 and
                TC              VERBUSY         # MPAC+4)
                TC              +2
                TC              +1
                TC              FREEDSP         # Free the display and exit

                TC              ENDOFJOB

VERBUSY         CAF             VERLCADR
                TC              NVSUBUSY

VLOOPCNT        OCT             6
MPADR           ADRES           MPAC    +3
VERLCADR        FCADR           VERLOOP
VERVNCON        OCT             00401
PN2003          OCT             2003
PN200           OCT             200
PN100           OCT             100

ENDVCHK         EQUALS
