#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       playingWithListsBlockI.py
Purpose:        This is just something I'm using to see if I can work out
                how Block I interpretive "equations" work, in terms of how
                many arguments there are supposed to be.  The only hard info
                at hand, as far as I know, is The Compleat Sunrise
                (http://www.ibiblio.org/apollo/hrst/archive/1721.pdf.)
                and the Solarium files FIXED-FIXED_INTERPRETER_SECTION.agc
                and BANK_03_INTERPRETER_SECTION.agc.
History:        2022-10-14 RSB  Created.

from disassembleInterpretiveBlockI import interpreterOpcodes

# The two most-significant bits of the 7-bit opcode ... maybe. -1 = don't know.
prefixBitVsNumOperands = { 0: 1, 1: -1, 2: 1, 3:0 }

# The left-hand opcodes which are allowed (and one of which must be used) only
# in the first word of an "equation".
firstOpcode = ["DMOVE", "TMOVE", "VMOVE"]
