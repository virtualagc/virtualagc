#!/usr/bin/env python3
# Copyright:    None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename:     dcsDefinitions.py
# Purpose:      Definitions for LVDC Digital Command System (DCS.
# Reference:    http://www.ibiblio.org/apollo/LVDC.html
# Mod history:  2023-08-14 RSB  Began.

dcsTypes = {
    "ANTENNA TO HIGH GAIN": {
        "name": "ANTENNA TO HIGH GAIN",
        "description": "Switch to PCM and CCS high-gain antennas",
        "dataValues": [],
        "numDataWords": 0
        },
    "ANTENNA TO LOW GAIN": {
        "name": "ANTENNA TO LOW GAIN",
        "description": "Switch to PCM and CCS low-gain antennas",
        "dataValues": [],
        "numDataWords": 0
        },
    "ANTENNA TO OMNI": {
        "name": "ANTENNA TO OMNI",
        "description": "Switch to PCM and CCS omni antennas",
        "dataValues": [],
        "numDataWords": 0
        },
    "COARSE TIME BASE UPDATE": {
        "name": "COARSE TIME BASE UPDATE",
        "description": "TBD",
        
        "numDataWords": 1
        },
    "EXECUTE ALTERNATE SEQUENCE": {
        "name": "EXECUTE ALTERNATE SEQUENCE",
        "description": "Initiate alternate sequence 4A or 4B",
        "dataValues": ["TSEQ", "SEQNUM"],
        "dataScales": [15, -1000],
        "dataUnits": ["SECONDS", ""],
        "numDataWords": 5
        },
    "EXECUTE GENERALIZED MANEUVER": {
        "name": "EXECUTE GENERALIZED MANEUVER",
        "description": "TBD",
        "dataValues": ["TSOM", "GOMTYP", "YREF", "ZREF", "XREF"],
        "dataScales": [15, -1000, 0, 0, 0],
        "dataUnits": ["SECONDS", "", "PIRADS", "PIRADS", "PIRADS"],
        "numDataWords": 20
        },
    "EXECUTE MANEUVER A": {
        "name": "EXECUTE MANEUVER A",
        "description": "Initiates a maneuver to local horizontal in a retrograde position",
        "dataValues": [],
        "numDataWords": 0
        },
    "EXECUTE MANEUVER B": {
        "name": "EXECUTE MANEUVER B",
        "description": "TBD",
        "dataValues": [],
        "numDataWords": 0
        },
    "FINE TIME BASE UPDATE": {
        "name": "FINE TIME BASE UPDATE",
        "description": "TBD",
        
        "numDataWords": 1
        },
    "GENERALIZED SWITCH SELECTOR": {
        "name": "GENERALIZED SWITCH SELECTOR",
        "description": "Issue a switch-selector function at the first opportunity",
        "dataValues": ["IU", "SIVB", "ADDRESS"],
        "numDataWords": 2
        },
    "INHIBIT MANEUVER": {
        "name": "INHIBIT MANEUVER",
        "description": "Inhibit coast phase attitude maneuver",
        "dataValues": [], 
        "numDataWords": 0
        },
    "INHIBIT WATER VALVE LOGIC": {
        "name": "INHIBIT WATER VALVE LOGIC",
        "description": "Inhibit water valve from changing position",
        "dataValues": [],
        "numDataWords": 0
        },
    "LADDER MAGNITUDE LIMIT": {
        "name": "LADDER MAGNITUDE LIMIT",
        "description": "TBD",
        
        "numDataWords": 1
        },
    "MEMORY DUMP": {
        "name": "MEMORY DUMP",
        "description": "The contents of the specified contiguous memory block are telemetered.",
        "dataValues": ["DM1", "DS1", "DLOC1", "DM2", "DS2", "DLOC2"],
        "numDataWords": 6
        },
    "NAVIGATION UPDATE": {
        "name": "NAVIGATION UPDATE",
        "description": "Re-initialize the navigation state vector at a specified time",
        "dataValues": ["ZDOT", "XDOT", "YDOT", "Z", "X", "Y", "T"],
        "dataScales": [14, 14, 14, 23, 23, 23, 15],
        "dataUnits":  ["METERS/SECOND", "METERS/SECOND", "METERS/SECOND", "METERS", "METERS", "METERS", "SECONDS"],
        "dataDescriptions": [
            "Inertial velocity along Z axis in fixed-space coordinate system",
            "Inertial velocity along X axis in fixed-space coordinate system",
            "Inertial velocity along Y axis in fixed-space coordinate system",
            "Position along Z axis in fixed-space coordinate system",
            "Position along X axis in fixed-space coordinate system",
            "Position along Y axis in fixed-space coordinate system",
            "Time at which the adjustment takes effect"
            ],
        "numDataWords": 35
        },
    "RETURN TO NOMINAL TIMELINE": {
        "name": "RETURN TO NOMINAL TIMELINE",
        "description": "Returns to the pre-programmed orbital attitude timeline in effect prior to DCS-initiated action having overridden it.",
        "dataValues": ["TRNTL"],
        "dataScales": [15],
        "dataUnits": ["SECONDS"],
        "numDataWords": 5
        },
    "S-IVB/IU LUNAR IMPACT": {
        "name": "S-IVB/IU LUNAR IMPACT",
        "description": "Initiate maneuver to crash the S-IVB onto the moon",
        
        "numDataWords": 4
        },
    "SECTOR DUMP": {
        "name": "SECTOR DUMP",
        "description": "The contents of the specified memory sector are telemetered",
        
        "numDataWords": 2
        },
    "TARGET UPDATE": {
        "name": "TARGET UPDATE",
        "description": "Replace targeting quantities for second S-IVB burn",
        
        "numDataWords": 35
        },
    "TD & E ENABLE": {
        "name": "TD & E ENABLE",
        "description": "Inhibits TLI so that Transposition, Docking, and Ejection can be accomplished in Earth orbit.",
        "dataValues": [],
        "numDataWords": 0
        },
    "TELEMETER SINGLE LOCATION": {
        "name": "TELEMETER SINGLE LOCATION",
        "description": "The content of a single selected memory location is telemetered",
        
        "numDataWords": 3
        },
    "TERMINATE": {
        "name": "TERMINATE",
        "description": "Stop DCS processing and reset for a new command",
        "dataValues": [],
        "numDataWords": 0
        },
    "TIME BASE 6D": {
        "name": "TIME BASE 6D",
        "description": "Initiates time base 6D, S-IVB ignition restart",
        "dataValues": [],
        "numDataWords": 0
        },
    "TIME BASE 8 ENABLE": {
        "name": "TIME BASE 8 ENABLE",
        "description": "Initiates time base 8, the post-S-IVB-separation maneuver",
        "dataValues": [],
        "numDataWords": 0
        },
    "TIME BASE UPDATE": {
        "name": "TIME BASE UPDATE",
        "description": "The time-base time is advanced or retarded by a selected amount",
        "dataValues": ["DELTAT"],
        "dataScales": [-1000],
        "dataUnits": ["SECONDS"],
        "dataDescriptions": [
            "Delta-time in current time base, in range -124 to +124, rounded to nearest 4-second multiple"
            ],
        "numDataWords": 1,
        },
    "UPDATE MANEUVER": {
        "name": "UPDATE MANEUVER",
        "description": "Change the time for starting the coast phase maneuver.",
        "dataValues": [],
        "numDataWords": 0
        },
    }

dcsForAS512 = {
    0o05: dcsTypes["INHIBIT MANEUVER"],
    0o10: dcsTypes["TIME BASE UPDATE"],
    0o11: dcsTypes["NAVIGATION UPDATE"],
    0o12: dcsTypes["GENERALIZED SWITCH SELECTOR"],
    0o13: dcsTypes["SECTOR DUMP"],
    0o14: dcsTypes["TELEMETER SINGLE LOCATION"],
    0o17: dcsTypes["TIME BASE 8 ENABLE"],
    0o20: dcsTypes["TERMINATE"],
    0o22: dcsTypes["UPDATE MANEUVER"],
    0o25: dcsTypes["TIME BASE 6D"],
    0o31: dcsTypes["TARGET UPDATE"],
    0o33: dcsTypes["EXECUTE MANEUVER A"],
    0o34: dcsTypes["EXECUTE MANEUVER B"],
    #0o40: dcsTypes["INHIBIT MANEUVER"],
    0o41: dcsTypes["LADDER MAGNITUDE LIMIT"],
    #0o43: dcsTypes["UPDATE MANEUVER"],
    0o45: dcsTypes["INHIBIT WATER VALVE LOGIC"],
    0o52: dcsTypes["S-IVB/IU LUNAR IMPACT"],
    0o53: dcsTypes["ANTENNA TO OMNI"],
    0o54: dcsTypes["ANTENNA TO LOW GAIN"],
    0o55: dcsTypes["ANTENNA TO HIGH GAIN"],
    0o60: dcsTypes["TD & E ENABLE"]
}

dcsForAS513 = {
    0o10: dcsTypes["FINE TIME BASE UPDATE"],
    0o11: dcsTypes["NAVIGATION UPDATE"],
    0o12: dcsTypes["GENERALIZED SWITCH SELECTOR"],
    0o13: dcsTypes["MEMORY DUMP"],
    0o20: dcsTypes["TERMINATE"],
    0o21: dcsTypes["EXECUTE ALTERNATE SEQUENCE"],
    0o35: dcsTypes["EXECUTE GENERALIZED MANEUVER"],
    0o36: dcsTypes["RETURN TO NOMINAL TIMELINE"],
    0o40: dcsTypes["COARSE TIME BASE UPDATE"],
    0o41: dcsTypes["LADDER MAGNITUDE LIMIT"],
    0o45: dcsTypes["INHIBIT WATER VALVE LOGIC"]
}
