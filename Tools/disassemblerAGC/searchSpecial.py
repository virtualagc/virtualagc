#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       searchSpecial.py
Purpose:        Search for the locations of subroutines which are "special"
                in the sense that the disassembler must treat them differently
                than everyday, run-of-the-mill subroutines.  The 
                stereotypical example is INTPRET, since the disassembler has
                to recognize calls to it, to know when a transition has been 
                made from basic code to interpreter code.  Other examples are
                subroutines like BANKCALL that have an unusual calling 
                sequence that can fool the disassembler.
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
"""

import sys
from disassembleBasic import disassembleBasic
import parseCommandLine as cli

"""
A relatively general-purpose algorithm that we can reuse for a 
variety of different targets:  INTPRET, BANKCALL, ....

The idea that for each symbol of interest we define a kind of pattern 
which the general-purpose algorithm can search for within
a given set of address ranges.  The pattern must encompass matches
for opcodes, optional matches for the operands of the opcodes, and the
possibility that certain opcodes-matches are optional.

Each special symbol is associated with a list of 
dictionaries.  Each of the dictionaries is associated with an essentially 
different pattern of instructions for the symbol.  Usually there will be
single dictionary, but sometimes the implementation in
very early AGC versions may be quite different from the implementation
in later versions, so that no single pattern works for both.  This is
the case for the ALARM subroutine.  The individual dictionaries are 
as follows:

    A list of address ranges to search.  Each address range is a tuple
    consisting of a bank number, a starting offset, and an ending offset.
    The starting offset can also be a string for a different special
    symbol rather than a number, to avoid re-searching an area in which
    a symbol (having an identical pattern) has already been found.
    
    A list of tuples, one for each instruction in the pattern.  Each
    tuple has 3 elements:
        1st:    True if the instruction is required, False if optional.
        2nd:    A list of opcode strings which are acceptable.
                If empty, any opcode will match.
        3rd:    A list of operand strings which are acceptable.
                If empty, the operands are ignored by the matching.
                Optionally, rather than the numerical operands returned
                by disassembly, it's also possible to use the names
                of symbols (as strings), of special subroutines already
                found.  As each special symbol is found, it is replaced
                in these opcode lists by its numerical value.  However,
                this can only be done for special symbols in fixed-fixed.
    The opcode and operand strings are as output by disassemblerBasic().
    Do not put optional opcodes at the *end* of a pattern (where they 
    would contribute nothing anyway), but they can be at the beginning 
    or in the middle.
    
    A count of the number of data-words following the TC/TCF, usually 
    a non-negative integer.  A count of -1 is used for special cases
    like POLY, where the number of data words is variable.
    
    A boolean value which is True if the TC does not return.

NOTE: A drawback is that for the opcode and operand strings above, you have
to know how disassemblerBasic() is going to disassemble.  For example, you
need to know that 30000 is going to be disassembled as CA 0000 rather than 
as NOOP.  The, command-line switches 
    --pattern=SYMBOL
    --dbank=BANK
    --dstart=START
    --dend=END (the first location not used in the pattern)
help get around this by printing out a template for the pattern, which can
be cut-and-pasted into the searchPatterns list.  Such patterns require
manual tweaking, usually, but are less prone to error.

For example, in the INTPRET pattern below, we see that there is a single
address range to search, 03,0000 through 03,0200, and that the pattern of
opcodes we're looking for is RELINT, EXTEND, QXCH, CA, TS, MASK, TS.  
However the initial RELINT is optional, and we don't care about any of the 
operands except that CA's operand must be either 0004 or 0006.

It would be clever to somehow encode these things as regular expressions,
and thus get a much-more-flexible (and presumably more-efficient) matching
mechanism, but I haven't given that any thought.  The search is strictly
brute force at this point.

The output is a dictionary with a key for each special symbol, and values
of the form
        (bank, offset, fixedFixedAddress, searchPattern, symbol, dataWords)
If the symbol wasn't found, all of these fields will be -1.  The 
fixedFixedAddress, which is in the octal range 4000-7777 for banks 02 and 03,
will also be -1 for banks other then 02 or 03.
"""
searchPatterns = {
    "INTPRET": [{
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                                    [False, ["RELINT"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["QXCH"], []],
                                    [True, ["CA"], ["FB", "BB"]],
                                    [True, ["TS"], []],
                                    [True, ["MASK"], []],
                                    [True, ["TS"], []]
                                ],
                    "ranges": [[0o3, 0o0000, 0o2000]]
                }],
    "BANKCALL": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["DXCH"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["INCR"], ["Q"]],
                                    [True, ["TS"], ["L"]],
                                    [True, ["LXCH"], ["FB"]],
                                    [True, ["MASK"], []],
                                    [True, ["XCH"], ["Q"]]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "NOVAC": [{
                    "dataWords": 2,
                    "noReturn": False,
                    "pattern": [
                                    [False, ["INHINT"], []],
                                    [False, ["AD"], []],
                                    [True, ["TS"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["DCA"], ["A"]],
                                    [True, ["DXCH"], []],
                                    [True, ["CA"], []],
                                    [True, ["XCH"], ["FB"]],
                                    [True, ["TS"], []],
                                    [True, ["TCF"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "IBNKCALL": [{ # Identical to BANKCALL except for search range.
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["DXCH"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["INCR"], ["Q"]],
                                    [True, ["TS"], ["L"]],
                                    [True, ["LXCH"], ["FB"]],
                                    [True, ["MASK"], []],
                                    [True, ["XCH"], ["Q"]]
                                ],
                    "ranges": [[0o2, "BANKCALL", 0o2000]]
                }],
    "POSTJUMP": [{
                    "dataWords": 1,
                    "noReturn": True, # This is confusing.
                    "pattern": [
                                    [True, ["XCH"], ["Q"]],
                                    [True, ["INDEX"], ["A"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TS"], ["FB"]],
                                    [True, ["MASK"], []],
                                    [True, ["XCH"], ["Q"]],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["TCF"], ["2000"]]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "FINDVAC": [{
                    "dataWords": 2,
                    "noReturn": False,
                    "pattern": [
                                    [False, ["INHINT"], []],
                                    [True, ["TS"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["DCA"], ["A"]],
                                    [True, ["DXCH"], []],
                                    [True, ["CA"], []],
                                    [True, ["XCH"], ["FB"]],
                                    [True, ["TCF"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "USPRCADR": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["TS"], []],
                                    [True, ["CA"], []],
                                    [True, ["TS"], []],
                                    [True, ["CA"], ["FB", "BB"]],
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TS"], ["FB"]],
                                    [True, ["MASK"], []],
                                    [True, ["XCH"], ["Q"]],
                                    [True, ["XCH"], []],
                                    [False, ["INDEX"], []],
                                    [True, ["TCF"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "WAITLIST": [
                {  # CMC
                    "dataWords": 2,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["BZMF"], []],
                                    [True, ["XCH"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["INDEX"], []],
                                    [True, ["DCA"], ["A"]],
                                    [True, ["TS"], []],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                },
                { # LGC
                    "dataWords": 2,
                    "noReturn": False,
                    "pattern": [
                                    [False, ["INHINT"], []],
                                    [True, ["XCH"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["INDEX"], []],
                                    [True, ["DCA"], ["A"]],
                                    [True, ["TS"], []],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }
                ],
    "TWIDDLE": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["TS"], ["L"]],
                                    [True, ["CA"], []],
                                    [True, ["ADS"], ["Q"]],
                                    [True, ["CA"], ["BB"]],
                                    [True, ["EXTEND"], []],
                                    [True, ["ROR"], ["SUPERBNK"]],
                                    [True, ["XCH"], ["L"]],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "ALARM": [  { # Later versions
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["CA"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TS"], ["L"]],
                                    [True, ["CA"], ["BB"]],
                                    [True, ["EXTEND"], []],
                                    [True, ["ROR"], ["SUPERBNK"]],
                                    [True, ["TS"], []],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 },
                 { # Earlier versions
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["XCH"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["CCS"], []],
                                    [True, ["TC"], []],
                                    [True, ["TC"], []],
                                    [True, ["CA"], []],
                                    [True, ["RELINT"], []],
                                    [True, ["INDEX"], ["A"]],
                                    [True, ["TC"], ["L"]]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 }
             ],
    "ALARM2": [ { # Later versions
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TS"], ["L"]],
                                    [True, ["CA"], ["BB"]],
                                    [True, ["EXTEND"], []],
                                    [True, ["ROR"], ["SUPERBNK"]],
                                    [True, ["TS"], []],
                                ],
                    "ranges": [[0o2, "ALARM", 0o2000]]
                 },
                 { # Earlier versions
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["TS"], []],
                                    [True, ["CCS"], []],
                                    [True, ["TC"], []],
                                    [True, ["TC"], []],
                                    [True, ["CA"], []],
                                    [True, ["RELINT"], []],
                                    [True, ["INDEX"], ["A"]],
                                    [True, ["TC"], ["L"]]
                                ],
                    "ranges": [[0o2, "ALARM", 0o2000]]
                 }
             ],
    "BORTENT": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["TS"], ["L"]],
                                    [True, ["CA"], ["BB"]],
                                    [True, ["EXTEND"], []],
                                    [True, ["ROR"], ["SUPERBNK"]],
                                    [True, ["TS"], []],
                                ],
                    "ranges": [[0o2, "ALARM2", 0o2000]]
                 }],
    "PRIOENT": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["CA"], ["BB"]],
                                    [True, ["EXTEND"], []],
                                    [True, ["ROR"], ["SUPERBNK"]],
                                    [True, ["TS"], []],
                                ],
                    "ranges": [[0o2, "BORTENT", 0o2000]]
                 }],
    "PRIOENT +1": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                                    [True, ["EXTEND"], []],
                                    [True, ["ROR"], ["SUPERBNK"]],
                                    [True, ["TS"], []],
                                ],
                    "ranges": [[0o2, "PRIOENT", 0o2000]]
                 }],
    "BAILOUT": [{ # CMC
                    "dataWords": 1,
                    "noReturn": True,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["CA"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["TC"], ["BANKCALL"]],
                                    [True, [], []],
                                    [True, ["INDEX"], []],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TC"], ["BORTENT"]],
                                    [True, [], []],
                                    [True, ["INHINT"], []]
                                ],
                    "ranges": [[0o3, 0o0000, 0o2000]]
                 },
                 { # LGC
                    "dataWords": 1,
                    "noReturn": True,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["CA"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TC"], ["BORTENT"]],
                                    [True, [], []],
                                    [True, ["INHINT"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 },
                 ],
    "POLY": [{
                    "dataWords": 0, # This field is wrong, but ignored for POLY.
                    "noReturn": False,
                    "pattern": [
                                    [False, ["CA"], []],
                                    [False, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TS"], []],
                                    [True, ["AD"], ["A"]],
                                    [True, ["AD"], ["Q"]],
                                    [True, ["TS"], []],
                                    [False, ["AD"], []],
                                    [True, ["TS"], []]
                                ],
                    "ranges": [[0o3, 0o0000, 0o2000]]
                 }],
    "PHASCHNG": [{ # CMC
                    "dataWords": 1, 
                    "noReturn": False,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["CA"], []],
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["INCR"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["DCA"], []],
                                    [True, ["DXCH"], ["Z"]] # DTCB
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 },
                 { # LGC older
                    "dataWords": 1, 
                    "noReturn": False,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TS"], []],
                                    [True, ["MASK"], []],
                                    [True, ["AD"], ["A"]],
                                    [True, ["XCH"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["MP"], []],
                                    [True, ["TCF"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 },
                 { # LGC newer
                    "dataWords": 1, # This field is ignored for PHASCHNG
                    "noReturn": False,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["INCR"], ["Q"]],
                                    [True, ["INHINT"], []],
                                    [True, ["TS"], []],
                                    [True, ["CA"], []],
                                    [True, ["TS"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["DCA"], []],
                                    [True, ["DXCH"], ["Z"]]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 },
                 ],
    "POODOO": [{ # CMC
                    "dataWords": 1, # This field is ignored for PHASCHNG
                    "noReturn": True,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["CA"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["TC"], ["BANKCALL"]],
                                    [True, [], []],
                                    [True, ["INDEX"], []],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TC"], ["BORTENT"]],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 },
                 { # LGC
                    "dataWords": 1,
                    "noReturn": True,
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["CA"], ["Q"]],
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TC"], ["BORTENT"]],
                                    [True, [], []],
                                    [True, ["CCS"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                 },
                 ],
    "ABORT2": [{ # CMC
                    "dataWords": 1,
                    "noReturn": True,
                    "pattern": [
                                    [True, ["TC"], ["BORTENT"]],
                                    [True, [], []],
                                    [True, ["CA"], []],
                                    [True, ["MASK"], []]
                                ],
                    "ranges": [[0o2, "POODOO", 0o2000]]
                 },
                 { # LGC
                    "dataWords": 1,
                    "noReturn": True,
                    "pattern": [
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["TC"], ["BORTENT"]],
                                    [True, [], []],
                                    [True, ["CCS"], []]
                                ],
                    "ranges": [[0o2, "POODOO", 0o2000]]
                 },
                 ],
    "TASKOVER": [{
                    "dataWords": 0,
                    "noReturn": True, 
                    "pattern": [
                                    [True, ["CCS"], []],
                                    [True, ["CA"], []],
                                    [True, ["TS"], ["BB"]],
                                    [True, ["TCF"], []],
                                    [False, ["CA"], ["BBRUPT"]],
                                    [True, ["EXTEND"], []],
                                    [False, ["WRITE"], ["SUPERBNK"]],
                                    [False, ["EXTEND"], []],
                                    [True, ["QXCH"], ["QRUPT"]],
                                    [True, ["CA"], ["BBRUPT"]],
                                    [True, ["TS", "XCH"], ["BB"]],
                                    [True, ["DXCH"], ["ARUPT"]],
                                    [False, ["RELINT"], []],
                                    [True, ["RESUME"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    "2PHSCHNG": [{
                    "dataWords": 1, # This field ignored for 2PHSCHNG
                    "noReturn": False, 
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["INCR"], ["Q"]],
                                    [False, ["TS"], []],
                                    [True, ["MASK"], []],
                                    [True, ["AD"], ["A"]],
                                    [True, ["TS"], []],
                                    [True, ["CA"], []],
                                    [True, ["MASK"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["MP"], []],
                                    [True, ["XCH"], []],
                                    [True, ["MASK"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                }],
    # Note that while Luminary has a subroutine *called* NEWPHASE, it is
    # So unlike NEWPHASE from other program versions (including Sunburst)
    # in structure and usage that there's no point in supporting it here.
    "NEWPHASE": [{
                    "dataWords": 1,
                    "noReturn": False, 
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["TS"], ["L"]],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["INCR"], ["Q"]],
                                    [True, ["AD"], ["A"]],
                                    [True, ["TS"], []],
                                    [True, ["CCS"], ["L"]],
                                    [True, ["TCF"], []],
                                    [True, ["TCF"], []],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                },
                {
                    "dataWords": 1,
                    "noReturn": False, 
                    "pattern": [
                                    [True, ["INHINT"], []],
                                    [True, ["TS"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CA"], ["A"]],
                                    [True, ["AD"], ["A"]],
                                    [True, ["XCH"], []],
                                    [True, ["TS"], ["L"]],
                                    [True, ["CS"], ["A"]], # COM
                                    [True, ["INDEX"], []],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                },
                ],
    "CHECKMM": [{
                    "dataWords": 1,
                    "noReturn": False, 
                    "pattern": [
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CS"], ["A"]],
                                    [True, ["AD"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["BZF"], []],
                                    [True, ["TCF"], []],
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                },
                {
                    "dataWords": 1,
                    "noReturn": False, 
                    "pattern": [
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["CS"], ["A"]],
                                    [True, ["AD"], []],
                                    [True, ["EXTEND"], []],
                                    [True, ["BZF"], []],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["TC"], ["L"]],
                                    [True, ["INDEX"], ["Q"]],
                                    [True, ["RETURN"], []]
                                ],
                    "ranges": [[0o2, 0o0000, 0o2000]]
                },
                ],
    "ENDOFJOB": [{
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                        [True, ["CA"], []],
                        [True, ["TS"], ["FB"]],
                        [True, ["TCF"], []],
                        [True, ["CA"], []],
                        [True, ["TS"], ["FB"]],
                        [True, ["TCF"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                },
                {
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                        [True, ["CA"], []],
                        [True, ["TS"], ["FB"]],
                        [True, ["TCF"], []],
                        [True, ["CA"], []],
                        [True, ["TS"], ["FB"]],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["RETURN"], []]
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "FIXDELAY": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["INDEX"], ["Q"]],
                        [True, ["CA"], ["A"]],
                        [True, ["INCR"], ["Q"]],
                        [False, ["EXTEND"], []],
                        [False, ["BZMF"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["TS"], []],
                        [True, ["CA"], ["BB"]],
                        [False, ["EXTEND"], []],
                        [False, ["ROR"], ["SUPERBNK"]],
                        [True, ["TS"], ["L"]],
                        [True, ["CA"], []],
                        [True, ["TS"], []],
                        [True, ["TCF"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "SWCALL": [{
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                        [True, ["TS"], ["L"]],
                        [True, ["LXCH"], ["FB"]],
                        [True, ["MASK"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["DXCH"], []],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["TC"], []],
                        [True, ["XCH"], []],
                        [True, ["XCH"], ["FB"]],
                        [True, ["XCH"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "UPFLAG": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["CA"], ["Q"]],
                        [True, ["TC"], []],
                        [True, ["CS"], ["A"]],
                        [True, ["EXTEND"], [""]],
                        [True, ["ROR"], ["L"]],
                        [True, ["INDEX"], []],
                        [True, ["TS"], []],
                        [True, ["LXCH"], []],
                        [True, ["RELINT"], []],
                        [True, ["TC"], ["L"]],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "COMFLAG": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["INDEX"], []],
                        [True, ["TS"], []],
                        [True, ["LXCH"], []],
                        [True, ["RELINT"], [""]],
                        [True, ["TC"], ["L"]],
                     ],
                    "ranges": [[0o02, "UPFLAG", 0o2000]]
                }],
    "DOWNFLAG": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["CA"], ["Q"]],
                        [True, ["TC"], []],
                        [True, ["MASK"], ["L"]],
                        [True, ["TCF"], ["COMFLAG"]],
                     ],
                    "ranges": [[0o02, "COMFLAG", 0o2000]]
                }],
}

# If necessary, import patterns from a file specified by the --flex
# command-line switch, and append them to the searchPatterns dictionary
# above prior to searching for the special subroutines.
if cli.flexFilename != "":
    f = open(cli.flexFilename, "r")
    count = 0
    inPatterns = False
    for line in f:
        line = line.strip().replace(" ", "")
        if line[-1:] == ",":
            line = line[:-1]
        count += 1
        if count == 1: # Key (symbol)
            fields = line.split(":")
            symbol = fields[0].replace('"', '')
            flexDict = {
                "dataWords": 0,
                "noReturn": False,
                "pattern": [],
                "ranges": []
                }
        elif count == 2: # dataWords
            fields = line.split(":")
            dataWords = int(fields[1].replace(",", ""))
            flexDict["dataWords"] = dataWords
        elif count == 3: # noReturn
            fields = line.split(":")
            noReturn = (fields[1] == "True,")
            flexDict["noReturn"] = noReturn
        elif count == 4: # pattern
            inPatterns = True
        elif inPatterns: # lines of the pattern
            if line == "]": # End of the pattern?
                inPatterns = False
                continue
            if "True" in line:
                required = True
                line = line[6:]
            else:
                required = False
                line = line[7:]
            fields = line.split("],[")
            fields[0] = fields[0].replace("[", "").replace("]", "")
            fields[1] = fields[1].replace("[", "").replace("]", "")
            opcodeFields = fields[0].split('","')
            operandFields = fields[1].split('","')
            for i in range(len(opcodeFields)):
                opcodeFields[i] = \
                    opcodeFields[i].replace('"', '').replace(",", "")
            for i in range(len(operandFields)):
                operandFields[i] = \
                    operandFields[i].replace('"', '').replace(",", "")
            if opcodeFields == ['']:
                opcodeFields = []
            if operandFields == ['']:
                operandFields = []
            flexDict["pattern"].append([required, opcodeFields, operandFields])
        elif line == "}]":
            searchPatterns[symbol] = [flexDict]
            count = 0
            inPatterns = False
        else: # ranges
            fields = line.split(":")
            fields = fields[1].split("],[")
            for field in fields:
                field = field.replace("[", "").replace("]", "")
                rangeFields = field.split(",")
                for i in range(len(rangeFields)):
                    if "0o" == rangeFields[i][:2]:
                        rangeFields[i] = rangeFields[i][2:]
                    rangeFields[i] = int(rangeFields[i], 8)
                flexDict["ranges"].append(rangeFields)
    f.close()

# Search for all the special patterns listed above.
specialSubroutines = {}
def searchSpecial(core):
    global specialSubroutines
    for symbol in searchPatterns:
        specialSubroutines[symbol] = (-1, -1, -1, {}, symbol, 0) # Mark as not found.
        found = False
        for searchPattern in searchPatterns[symbol]:
            if found:
                break
            pattern = searchPattern["pattern"]
            for searchRange in searchPattern["ranges"]:
                if symbol == "no":
                    print(symbol)
                    print(pattern)
                    print(searchRange)
                if found:
                    break
                bank = searchRange[0]
                startingOffset = searchRange[1]
                # Usually searchRange[1] is a number, but if it's a string,
                # then it's the name of a special symbol whose pattern, we
                # fear, will unfortunately match the symbol we're now trying
                # to find.  BANKCALL and IBNKCALL have that relationship.
                # In that case, we adjust the starting range accordingly to
                # avoid that.  This only works if the 2nd symbol we're 
                # searching for is at a higher offset than the 1st symbol 
                # we already found.
                if startingOffset in specialSubroutines:
                    startingOffset = specialSubroutines[startingOffset][1] + 1
                endingOffset = searchRange[2]
                for testOffset in range(startingOffset, endingOffset):
                    if found:
                        break
                    iPat = 0 # Index into the pattern.
                    # Optional opcodes at the beginning of the pattern
                    # we can ignore for now, because they don't affect
                    # the match at all.  But we'll come back to them
                    # at the end if there has been a match, because
                    # they'll affect the address assigned to the symbol.
                    while not pattern[iPat][0]: 
                        iPat += 1
                    offset = testOffset
                    extended = False
                    lastOffset = -1
                    if symbol == "no":
                        print("------------------")
                    while offset < endingOffset and iPat < len(pattern):
                        # We need to disassemble the instruction at the current
                        # offset, but we don't need to do that if the offset
                        # hasn't changed since the last time we disassembled.  
                        # More importantly, we must *not* do so, because the 
                        # value of 'extended' may change if we do, and a 2nd
                        # disassembly may therefore not be correct.
                        if offset != lastOffset:
                            opcode, operand, extended = \
                                disassembleBasic(core[bank][offset], extended)
                        if symbol == "no":
                            print("%02o %04o %04o %s %s %r" % (bank, testOffset, 
                                offset, opcode, operand, extended))
                        lastOffset = offset
                        required = pattern[iPat][0]
                        desiredOpcodes = pattern[iPat][1]
                        desiredOperands = pattern[iPat][2]
                        if len(desiredOpcodes) == 0 or opcode in desiredOpcodes:
                            if len(desiredOperands) == 0 \
                                    or operand in desiredOperands:
                                iPat += 1
                                offset += 1
                                continue
                        if required:
                            break
                        iPat += 1 # Note: offset does not increment.
                    if iPat >= len(pattern):
                        # At this point, we know that the pattern has been
                        # found at bank,testOffset.  However, if there were
                        # optional matches at the beginning of the pattern,
                        # those haven't been checked, so we have to check 
                        # those in case testOffset needs to be decremented.
                        fixedFixed = -1
                        if bank in [2, 3]:
                            fixedFixed = bank * 0o2000 + testOffset
                        specialSubroutines[symbol] = (bank, testOffset, 
                                                      fixedFixed, searchPattern,
                                                      symbol, 
                                                      searchPattern["dataWords"])
                        iPat = 0
                        while not pattern[iPat][0]: 
                            iPat += 1
                        offset = testOffset
                        while iPat > 0 and offset > startingOffset:
                            iPat -= 1
                            offset -= 1
                            desiredOpcodes = pattern[iPat][1]
                            desiredOperands = pattern[iPat][2]
                            opcode, operand, extended = \
                                disassembleBasic(core[bank][offset], False)
                            if opcode in desiredOpcodes:
                                if len(desiredOperands) == 0 \
                                        or operand in desiredOperands:
                                    # testOffset -= 1
                                    fixedFixed = -1
                                    if bank in [2, 3]:
                                        fixedFixed = bank * 0o2000 + offset
                                    specialSubroutines[symbol] = \
                                        (bank, offset, fixedFixed, 
                                         searchPattern, symbol, 
                                         searchPattern["pattern"])
                                    continue
                                else: # Does not match!
                                    break
                        found = True
        if found and specialSubroutines[symbol][2] != -1:
            # A numerical address for the symbol has been found in fixed-fixed.
            # If any of these symbols were used in the patterns for operands,
            # we need to replace them by their numerical values for subsequent
            # searching.
            for s in searchPatterns:
                for searchPattern in searchPatterns[s]:
                    pattern = searchPattern["pattern"]
                    for p in pattern:
                        ops = p[2]
                        if symbol in ops:
                            ops[ops.index(symbol)] = "%04o" % \
                                            specialSubroutines[symbol][2]
                            
