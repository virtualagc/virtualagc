### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    CONTROLLED_CONSTANTS.agc
## Purpose:     A section of a reconstructed, mixed version of Sundance
##              It is part of the reconstructed source code for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 9.
##              No original listings of this program are available;
##              instead, this file was created via disassembly of dumps
##              of various revisions of Sundance core rope modules.
## Reference:   pp. 53-69
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2020-06-17 MAS  Created from Luminary 69.


# ************************************************************************



# THROTTLING AND THRUST DETECTION PARAMETERS

                SETLOC          F2DPS*32
                BANK
                COUNT*          $$/F2DPS

DPSTHRSH        DEC             36                      # (THRESH1 + THRESH3 FOR P63)

                SETLOC          SERVICES
                BANK
                COUNT*          $$/SERV

# ************************************************************************


# PHYSICAL CONSTANTS ( TIME - INVARIANT )
# ************************************************************************
                SETLOC          SERVICES
                BANK
                COUNT*          $$/SERV

# ************************************************************************

-MUDTMUN        2DEC*           -9.8055560      E+10 B-38*
