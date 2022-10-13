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
}

