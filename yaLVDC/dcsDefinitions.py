#!/usr/bin/env python3
# Copyright:    None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename:     dcsDefinitions.py
# Purpose:      Definitions for LVDC Digital Command System (DCS.
# Reference:    http://www.ibiblio.org/apollo/LVDC.html
# Mod history:  2023-08-14 RSB  Began.

dcsForAS512 = {
    0o05: {
        "name": "INHIBIT MANEUVER",
        "description": "Inhibit coast phase attitude maneuver",
        "dataValues": [], 
        "numDataWords": 0
        },
    0o10: {
        "name": "TIME BASE UPDATE",
        "description": "The time-base time is advanced or retarded by a selected amount",
        "dataValues": ["DELTAT"],
        "dataScales": [""],
        "dataUnits": ["4 SECONDS"],
        "numDataWords": 1,
        },
    0o11: {
        "name": "NAVIGATION UPDATE",
        "description": "Re-initialize the navigation state vector at a specified time",
        "dataValues": ["ZDOT", "XDOT", "YDOT", "Z", "X", "Y", "T"],
        "dataScales": [14, 14, 14, 23, 23, 23, 15],
        "dataUnits":  ["M/SEC", "M/SEC", "M/SEC", "METERS", "METERS", "METERS", "SECONDS"],
        "numDataWords": 35
        },
    0o12: {
        "name": "GENERALIZED SWITCH SELECTOR",
        "description": "Issue a switch-selector function at the first opportunity",
        "dataValues": ["IU", "SIVB", "ADDRESS"],
        "numDataWords": 2
        },
    0o13: {
        "name": "SECTOR DUMP",
        "description": "The contents of the specified memory sector are telemetered",
        
        "numDataWords": 2
        },
    0o14: {
        "name": "TELEMETER SINGLE LOCATION",
        "description": "The content of a single selected memory location is telemetered",
        
        "numDataWords": 3
        },
    0o17: {
        "name": "TIME BASE 8 ENABLE",
        "description": "Initiates time base 8, the post-S-IVB-separation maneuver",
        "dataValues": [],
        "numDataWords": 0
        },
    0o20: {
        "name": "TERMINATE",
        "description": "Stop DCS processing and reset for a new command",
        "dataValues": [],
        "numDataWords": 0
        },
    0o22: {
        "name": "UPDATE MANEUVER",
        "description": "Change the time for starting the coast phase maneuver.",
        "dataValues": [],
        "numDataWords": 0
        },
    0o25: {
        "name": "TIME BASE 6D",
        "description": "Initiates time base 6D, S-IVB ignition restart",
        "dataValues": [],
        "numDataWords": 0
        },
    0o31: {
        "name": "TARGET UPDATE",
        "description": "Replace targeting quantities for second S-IVB burn",
        
        "numDataWords": 35
        },
    0o33: {
        "name": "EXECUTE MANEUVER A",
        "description": "Initiates a maneuver to local horizontal in a retrograde position",
        "dataValues": [],
        "numDataWords": 0
        },
    0o34: {
        "name": "EXECUTE MANEUVER B",
        "description": "TBD",
        "dataValues": [],
        "numDataWords": 0
        },
    #0o40: {
    #    "name": "INHIBIT MANEUVER",
    #    "description": "Same as command 05"
    #    },
    0o41: {
        "name": "LADDER MAGNITUDE LIMIT",
        "description": "TBD",
        
        "numDataWords": 1
        },
    #0o43: {
    #    "name": "UPDATE MANEUVER",
    #    "description": "Same as command 22"
    #    },
    0o45: {
        "name": "INHIBIT WATER LOGIC",
        "description": "Inhibit water valve from changing position",
        "dataValues": [],
        "numDataWords": 0
        },
    0o52: {
        "name": "S-IVB/IU LUNAR IMPACT",
        "description": "Initiate maneuver to crash the S-IVB onto the moon",
        
        "numDataWords": 4
        },
    0o53: {
        "name": "ANTENNA TO OMNI",
        "description": "Both the PCM and CCS antennas are switched",
        "dataValues": [],
        "numDataWords": 0
        },
    0o54: {
        "name": "ANTENNA TO LOW GAIN",
        "description": "Both the PCM and CCS antennas are switched",
        "dataValues": [],
        "numDataWords": 0
        },
    0o55: {
        "name": "ANTENNA TO HIGH GAIN",
        "description": "Both the PCM and CCS antennas are switched",
        "dataValues": [],
        "numDataWords": 0
        },
    0o60: {
        "name": "TD & E ENABLE",
        "description": "Inhibits T6 so that Transposition, Docking, and Ejection can be accomplished in Earth orbit.",
        "dataValues": [],
        "numDataWords": 0
        },

}

dcsForAS513 = {
    0o10: {
        "name": "FINE TIME BASE UPDATE",
        "description": "TBD",
        
        "numDataWords": 1
        },
    0o11: {
        "name": "NAVIGATION UPDATE",
        "description": "Re-initialize the navigation state vector at a specified time",
        "dataValues": ["ZDOT", "XDOT", "YDOT", "Z", "X", "Y", "T"],
        "dataScales": [14, 14, 14, 23, 23, 23, 15],
        "dataUnits":  ["M/SEC", "M/SEC", "M/SEC", "METERS", "METERS", "METERS", "SECONDS"],
        "numDataWords": 35
        },
    0o12: {
        "name": "GENERALIZED SWITCH SELECTOR",
        "description": "Issue a switch-selector function at the first opportunity",
        "dataValues": ["IU", "SIVB", "ADDRESS"],
        "numDataWords": 2
        },
    0o13: {
        "name": "MEMORY DUMP",
        "description": "The contents of the specified contiguous memory block are telemetered.",
        "dataValues": ["DM1", "DS1", "DLOC1", "DM2", "DS2", "DLOC2"],
        "numDataWords": 6
        },
    0o20: {
        "name": "TERMINATE",
        "description": "Stop DCS processing and reset for a new command",
        "dataValues": [],
        "numDataWords": 0
        },
    0o21: {
        "name": "EXECUTE ALTERNATE SEQUENCE",
        "description": "Initiate alternate sequence 4A or 4B",
        "dataValues": ["TSEQ", "SEQNUM"],
        "dataScales": [15, -1000],
        "dataUnits": ["SECONDS", ""],
        "numDataWords": 5
        },
    0o35: {
        "name": "EXECUTE GENERALIZED MANEUVER",
        "description": "TBD",
        "dataValues": ["TSOM", "GOMTYP", "YREF", "ZREF", "XREF"],
        "dataScales": [15, -1000, 0, 0, 0],
        "dataUnits": ["SECONDS", "", "PIRADS", "PIRADS", "PIRADS"],
        "numDataWords": 20
        },
    0o36: {
        "name": "RETURN TO NOMINAL TIMELINE",
        "description": "Returns to the pre-programmed orbital attitude timeline in effect prior to DCS-initiated action having overridden it.",
        "dataValues": ["TRNTL"],
        "dataScales": [15],
        "dataUnits": ["SECONDS"],
        "numDataWords": 5
        },
    0o40: {
        "name": "COARSE TIME BASE UPDATE",
        "description": "TBD",
        
        "numDataWords": 1
        },
    0o41: {
        "name": "LADDER MAGNITUDE LIMIT",
        "description": "TBD",
        
        "numDataWords": 1
        },
    0o45: {
        "name": "INHIBIT WATER VALVE LOGIC",
        "description": "Inhibit water valve from changing position",
        "dataValues": [],
        "numDataWords": 0
        }
}
