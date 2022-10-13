#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       searchSpecial.py
Purpose:        Patterns for the locations of subroutines which are "special"
                in the sense that the disassembler must treat them differently
                than everyday, run-of-the-mill subroutines.  
                This file is for Block II only.
History:        2022-09-28 RSB  Split off from disassemblerAGC.py.
                2022-10-13 RSB  Removed the search functions off to a separate
                                module, searchFunctions.py.
                                
See searchFunctions.py for documentation.
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


