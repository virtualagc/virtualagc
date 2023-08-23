#!/usr/bin/env python3
'''
License:    The author (Ronald Burkey) declares this program to be in the 
            Public Domain, usable or modifiable in any way desired.
Filename:   lvdcTelemetryDecoder.py
Purpose:    Parses a "virtual wire" datastream from the yaLVDC CPU 
            emulator, and pulls out just a telemetry datastream.
History:    2023-08-09 RSB  Began.
            2023-08-10 RSB  Telemetry definitions now read from a file
                            (lvdcTelemetryDefinitions.tsv).
            2023-08-12 RSB  Added sign-correction for formatting decimal 
                            numbers.
'''

import sys

# Here are some substrings which *if* they appear in the the string defining
# the units for a telemetry definition, I assume they mean that I should 
# present the data in base 10.  If nont of these substrings appear, I assume
# octal. 
lvdcDecimalUnits = ["RADIAN", "PIRAD", "/", "**", "SECOND", "METER", "KG",
                    "QMS", "RTC", "DECIMAL"]
powers = []
for i in range(-100, 101):
    powers.append(2.0 ** i)
minusFlag = 0o200000000
minusMask = 0o377777777
def lvdcFormatData(value, scale, units):
    for n in lvdcDecimalUnits:
        if n in units:
            if value & minusFlag: # Is it negative?
                value = -(value ^ minusMask)
            scaled = value
            if scale != -1000 and scale != 0:
                scaled = value * powers[100 - 25 + scale]
            unscaled = "%d" % value
            scaled = "%g" % scaled
            return unscaled,scaled
    value = "O%09o" % value
    return value, ""

lvdcMode = None
def getLvdcMode():
    return lvdcMode

# Get lists of telemetry PIOs.  These are stored in a tab-delimited file so
# that they can be easily used by other software without being locked in a
# Python data structure. Once read into Python dictionaries, however, the keys 
# are the PIO 9-bit channel numbers, augmented
# by putting the 3-bit mode register (as I understand it) at the top, turning
# the channel numbers into 4 octal digits.  The values are 5-tuples:
#    Variable name (string)
#    Scale (or first scale, if two are specified as in "23/27")
#    Second scale, or -100 if none is specified.
#    Units (string)
#    Description (string)
# The tab-delimited file I mentioned, lvdcTelemetryDefinitions.tsv, is found
# in the same directory as this lvdcTelemetryDecoder.py program itself.
# The function sets up a series of dictionaries, forAS206RAM{}, forAS512{},
# forAS513{}, etc., however many are found in the tab-delimited file.
definitionFile = open(sys.path[0] + "/lvdcTelemetryDefinitions.tsv", "r")
lines = definitionFile.readlines()
definitionFile.close()
for line in lines:
    fields = line.strip().split("\t")
    if len(fields) == 1:
        temp = {}
        exec(fields[0] + " = temp")
    elif len(fields) == 6:
        temp[int(fields[0], 8)] = (
            fields[1], int(fields[2]), int(fields[3]), fields[4], fields[5])
    else:
        continue
del lines

def lvdcModeReset():
    global lvdcMode
    lvdcMode = None

# Sets the LVDC software version.  The input parameters are:
#                        0    PTC ADAPT Self-Test Program
#                        1    AS-206RAM
#                        2    AS-512
#                        3    AS-513
#                        4    AS-206
forMission = {}
def lvdcSetVersion(version):
    global forMission
    if version == 1:
        forMission = forAS206RAM
    elif version == 2:
        forMission = forAS512
    elif version == 3:
        forMission = forAS513
    else:
        forMission = {}

# Returns a tuple:
#    variableName    Name of the variable being telemetered (from TELD def'n).
#    value           Numerical value.
#    scale1          Scale (or 1st scale, if two are specified)
#    scale2          2nd scale, or -1000 if none specified
#    units           A string describing the units, possibly empty
#    description     A string describing the quantity, possibly empty
#    errorMessage    Self-explanatory.  None if none.
#    augmentedPIO    mode+channel
# If the packet doesn't hold any telemetered data, then variableName and value
# are returned as None.  If there is no error, then errorMessage is returned
# as None.
defaultReturn = (None, None, None, None, None, None, None, None)
def lvdcTelemetryDecoder(ioType, channelNumber, data):
    global lvdcMode
    if ioType != 0:
        return defaultReturn
    if channelNumber in [0o006, 0o206, 0o406, 0o606]:
        lvdcMode = (data >> 20) & 7
        return defaultReturn
    if lvdcMode == None:
        return defaultReturn
    augmentedPIO = (lvdcMode << 9) | channelNumber
    if augmentedPIO == 0o4470: # Block header
        return None, data, None, None, None, None, None, augmentedPIO
    if augmentedPIO >= 0o4474 and augmentedPIO <= 0o4570 and (augmentedPIO & 3) == 0:
        return None, data, None, None, None, None, None, augmentedPIO
    if augmentedPIO not in forMission:
        return defaultReturn
    teld = forMission[augmentedPIO]
    return teld[0],data,teld[1],teld[2],teld[3],teld[4],None,augmentedPIO
