#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       searchSpecialBlockI.py
Purpose:        Search for the locations of subroutines which are "special"
                in the sense that the disassembler must treat them differently
                than everyday, run-of-the-mill subroutines.  
                This file is for Block I only.
History:        2022-10-13 RSB  Created.
                2022-10-22 RSB  Added MAKECADR.

See searchFunctions.py for documentation.
"""

searchPatterns = {
    "INTPRET": [{   # From Solarium 55.
                    "dataWords": 0,
                    "noReturn": False,
                    "pattern": [
                        [True, ["CCS"], ["Q"]],
                        [True, ["TS"], []],
                        [True, ["CS"], ["BANKREG"]],
                        [True, ["TS"], []],
                        [True, ["TC"], []],
                        [True, ["CS"], []],
                        [True, ["TS"], ["BANKREG"]],
                        [True, ["CAF"], []],
                        [True, ["TS"], []],
                        [True, ["AD"], []],
                        [True, ["TS"], []],
                        [True, ["INDEX"], ["A"]],
                        [True, ["COM"], [""]],
                        [True, ["AD"], []],
                        [True, ["TS"], []],
                        [True, ["MASK"], []],
                        [True, ["AD"], []],
                        [True, ["TS"], []],
                        [True, ["CAF"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "BANKCALL": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["AD"], []],
                        [True, ["TS"], ["Q"]],
                        [True, ["INDEX"], ["A"]],
                        [True, ["INDEX"], []],
                        [True, ["TS"], []],
                        [True, ["XCH"], ["BANKREG"]],
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["XCH"], []],
                        [True, ["TS"], []],
                        [True, ["MASK"], []],
                        [True, ["CCS"], ["A"]],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["CS"], ["BANKREG"]],
                        [True, ["AD"], []],
                        [True, ["AD"], []],
                        [True, ["XCH"], []],
                        [True, ["INDEX"], []],
                        [True, ["XAQ"], [""]],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "ABORT": [{
                    "dataWords": 1,
                    "noReturn": True,
                    "pattern": [
                        [True, ["INHINT"], [""]],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["NOOP"], [""]],
                        [True, ["TS"], []],
                        [True, ["CCS"], []],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["AD"], []],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["XCH"], []],
                        [True, ["TS"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "ALARM": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["INHINT"], [""]],
                        [True, ["XCH"], ["Q"]],
                        [True, ["TS"], []],
                        [True, ["CCS"], []],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["XCH"], []],
                        [True, ["RELINT"], [""]],
                        [True, ["INDEX"], ["A"]],
                        [True, ["RETURN"], [""]],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "CHECKMM": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["CAF"], []],
                        [True, ["AD"], ["Q"]],
                        [True, ["XCH"], ["Q"]],
                        [True, ["INDEX"], ["A"]],
                        [True, ["COM"], [""]],
                        [True, ["AD"], []],
                        [True, ["CCS"], ["A"]],
                        [True, ["RETURN"], [""]],
                        [True, [], []],
                        [True, ["RETURN"], [""]],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["RETURN"], [""]],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "ENDOFJOB": [{
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                        [True, ["CAF"], []],
                        [True, ["TS"], ["BANKREG"]],
                        [True, ["TC"], []],
                        [True, ["TS"], []],
                        [True, ["CAF"], []],
                        [True, ["TS"], ["BANKREG"]],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "FINDVAC": [{
                    "dataWords": 2,
                    "noReturn": False,
                    "pattern": [
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["TC"], []],
                        [True, ["CAF"], []],
                        [True, ["TS"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "IBNKCALL": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["AD"], []],
                        [True, ["TS"], ["Q"]],
                        [True, ["INDEX"], ["A"]],
                        [True, ["INDEX"], []],
                        [True, ["TS"], []],
                        [True, ["XCH"], ["BANKREG"]],
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["XCH"], []],
                        [True, ["MASK"], []],
                        [True, ["XCH"], []],
                        [True, ["INDEX"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "NEWPHASE": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["INHINT"], [""]],
                        [True, ["XCH"], ["Q"]],
                        [True, ["TS"], []],
                        [True, ["INDEX"], ["A"]],
                        [True, ["NOOP"], [""]],
                        [True, ["TS"], []],
                        [True, ["CS"], ["Q"]],
                        [True, ["INDEX"], []],
                        [True, ["TS"], []],
                        [True, ["COM"], [""]],
                        [True, ["INDEX"], []],
                        [True, ["XCH"], []],
                        [True, ["CCS"], ["A"]],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["CS"], []],
                        [True, ["AD"], []],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "NOVAC": [{
                    "dataWords": 2,
                    "noReturn": False,
                    "pattern": [
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["TC"], []],
                        [True, ["CAF"], []],
                        [True, ["TS"], []],
                        [True, ["TC"], []],
                        [True, ["TS"], []],
                        [True, ["CCS"], ["Q"]],
                        [True, ["TS"], []],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "PHASCHNG": [{
                    "dataWords": 1,
                    "noReturn": False,
                    "pattern": [
                        [True, ["XCH"], ["Q"]],
                        [True, ["INHINT"], [""]],
                        [True, ["TS"], []],
                        [True, ["INDEX"], ["A"]],
                        [True, ["NOOP"], [""]],
                        [True, ["TS"], []],
                        [True, ["MASK"], []],
                        [True, ["XCH"], []],
                        [True, ["EXTEND"], [""]],
                        [True, ["MP"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o01, 0o0000, 0o2000]]
                }],
    "POLY": [{
                    "dataWords": 0,
                    "noReturn": False,
                    "pattern": [
                        [True, ["CAF"], []],
                        [True, ["TS"], []],
                        [True, ["CAF"], []],
                        [True, ["TS"], []],
                        [True, ["TS"], []],
                        [True, ["XCH"], []],
                        [True, ["TS"], []],
                        [True, ["XCH"], []],
                        [True, ["TS"], []],
                        [True, ["CAF"], []],
                        [True, ["TS"], []],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["NOOP"], [""]],
                        [True, ["TS"], []],
                        [True, ["AD"], ["Q"]],
                        [True, ["AD"], []],
                        [True, ["TS"], []],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "POSTJUMP": [{
                    "dataWords": 1,
                    "noReturn": True,
                    "pattern": [
                        [True, ["XCH"], ["Q"]],
                        [True, ["INDEX"], ["A"]],
                        [True, ["NOOP"], [""]],
                        [True, ["TS"], ["BANKREG"]],
                        [True, ["MASK"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["TC"], []],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "SWCALL": [{
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                        [True, ["TS"], []],
                        [True, ["XCH"], ["BANKREG"]],
                        [True, ["TS"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["XCH"], []],
                        [True, ["TS"], []],
                        [True, ["MASK"], []],
                        [True, ["CCS"], ["A"]],
                        [True, ["TC"], []],
                        [True, ["TC"], []],
                        [True, ["CS"], ["BANKREG"]],
                        [True, ["AD"], []],
                        [True, ["AD"], []],
                        [True, ["XCH"], []],
                        [True, ["INDEX"], []],
                        [True, ["XAQ"], [""]],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "MAKECADR": [{
                    "dataWords": 0,
                    "noReturn": False,
                    "pattern": [
                        [True, ["CAF"], []],
                        [True, ["AD"], []],
                        [True, ["TS"], []],
                        [True, ["AD"], []],
                        [True, ["TS"], ["OVCTR"]],
                        [True, ["RETURN"], [""]],
                        [True, ["XCH"], ["OVCTR"]],
                        [True, ["AD"], []],
                        [True, ["TS"], []],
                        [True, ["RETURN"], [""]],
                     ],
                    "ranges": [[0o02, 0o0000, 0o2000]]
                }],
    "BANKJUMP": [{
                    "dataWords": 0,
                    "noReturn": True,
                    "pattern": [
                        [True, ["TS"], ["BANKREG"]],
                        [True, ["MASK"], []],
                        [True, ["XCH"], ["Q"]],
                        [True, ["INDEX"], ["Q"]],
                        [True, ["TC"], ["6000"]],
                     ],
                    "ranges": [[0o02, "MAKECADR", 0o2000]]
                }],
}

