#!/usr/bin/env python3
# Copyright:    None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename:     yaPTC.py
# Purpose:      This is an LVDC telemetry and Digital Command System (DCS) 
#               emulator for use with the yaLVDC CPU emulator, and is connected
#               to yaLVDC with "virtual wires" ... i.e., via network sockets.
# Reference:    http://www.ibiblio.org/apollo/LVDC.html
# Mod history:  2023-08-13 RSB  Began adapting from yaPTC.py.
#               2023-08-21 RSB  Continued implementation of DCS commands ...
#                               however, had to incorporate the DCS status-
#                               command protocol, which at first I hadn't
#                               thought was useful for our model, but I now
#                               realize could result in data being overwritten
#                               before use if not implemented.
#               2023-08-22 RSB  Implemented last command (EXECUTE ALTERNATE
#                               SEQUENCE) and corrected yesterday's
#                               (EXECUTE GENERALIZED MANEUVER).

'''
Regarding how the Digital Command System (DCS) delivers commands and data to 
the LVDC, I interpret the documentation and the LVDC source code as follows.

What's supposed to happen:  The transmission from the ground is in packets that
contain either command or data, plus two bits (OM/D A and OM/D B) both having 
the same value) that indicate whether the packet is a command or whether it 
contains data, and two interrupt bits as well.  The LVDA is supposed to:
    1.  AND the OM/D bits together and present them to the LVDC as discrete
        input 2 (DI2), which is available to the LVDC software as "bit 22" of 
        PIO 057 (where the S is the most-significant bit, 1 the next-most,
        and so on).
    2.  Make the command or data available to the LVDC software as PIO 043.
    3.  Generate a DCS interrupt in the LVDC if the AND of the interrupt bits
        is 1.

After each packet is received by the LVDC (either a command packet or a date
packet, each of which can carry 6 bits of data), the LVDC (software) 
handshakes by sending back either two identical status words or else two 
identical error words.

Our CPU emulator receives data directly from mission control (i.e., from 
yaMccLvdc.py), without any intervening LVDA.  The obvious possibility is to
first send a PIO 057 (to set DI2), and then to send a PIO 043 (with the mode
or data), and assume that the LVDC emulator is written in such a way that it
will trigger a DCS interrupt after seeing the PIO 043.  The problem with this is
that there's a short window between the DI2 for PIO 057 and the data/mode 
for PIO 043, whereas in the real hardware these would have been simultanous.
Probably it wouldn't cause a problem, but still ....  A secondary concern is  
that this process would require transmission of a mask for PIO 057, followed by 
PIO 057, followed by PIO 043, and that's pretty inefficient because only 14 bits
of each PIO 043 are used anyway.

So here's the alternate procedure I intend to use:
    1.  Mode words will be transmitted just on PIO 043, but with all of the 
        otherwise unused bits set to 1.
    2.  Similarly, data words will be transmitted on PIO 043 also, but with all 
        of the otherwise unused bits set to 0.
    3.  The LVDC emulator will always generate a DCS interrupt upon detecting
        an incoming PIO 043, and will use the filler bits (all 0 or all 1) to
        set the DI2 bit appropriately at the same time.

(Recall that sending a PIO to the CPU emulator merely stores the data in a 
memory buffer, while subsequent PIO instructions by the LVDC software read from
the persistent data in the memory buffer.)
'''

'''
Let's talk for a moment about how the Flight Program processes incoming DCS
data.  (Not commands; it uses them to vector to subroutines corresponding to
the 6-bit mode codes, and that process doesn't really concerns us here.)
The 6-bit data from each incoming data word is extracted from the word, 
and stored in bits S,1,2,3,4,5 at V.DSBL, V.DSBL+1, V.DSBL+2, and so on.
'''

import sys
import argparse
import time
import socket
try:
  import Tkinter as tk
  import Tkinter.font as font
except ImportError:
  import tkinter as tk
  import tkinter.font as font
try:
  import ttk
  py3 = False
except ImportError:
  import tkinter.ttk as ttk
  py3 = True
from lvdcTelemetryDecoder import lvdcFormatData, lvdcModeReset, \
                                 lvdcSetVersion, lvdcTelemetryDecoder, \
                                 forAS206RAM, forAS512, forAS513, getLvdcMode
from dcsDefinitions import *
from decimal import Decimal, ROUND_HALF_UP

# Python's native round() function uses a silly method (in the sense that it is
# unlike the expectation of every programmer who ever lived) called "banker's
# rounding", wherein half-integers sometimes round up and sometimes
# round down.  Good for bankers, I suppose, because rounding errors tend to
# sum to zero, but no help whatever for us.  I've stolen the hround() function
# from my Shuttle HAL/S compiler.  It rounds half-integers upward.
# Returns None on error
def hround(x):
    try:
        i = int(Decimal(x).to_integral_value(rounding=ROUND_HALF_UP))
    except:
        #print("Implementation error, non-decimal:", x, file=sys.stderr)
        #sys.exit(1)
        return None
    return i


ioTypes = ["PIO", "CIO", "PRS", "INT" ]

refreshRate = 1 # Milliseconds
resizable = False
resize = 0
version = 2
showDcs = False
asciiOnly = False
abbreviateUnits = False
fontSize = 10
t0 = time.time_ns()

# Parse command-line arguments.
cli = argparse.ArgumentParser()
cli.add_argument("--host", \
                 help="Host address of yaLVDC, defaulting to localhost.")
cli.add_argument("--port", \
                 help="Port for yaLVDC, defaulting to 19653.", type=int)
cli.add_argument("--id", \
                 help="Unique ID of this LVDC peripheral (1-7), default=1.", \
                 type=int)
cli.add_argument("--dcs", \
                 help="Enable the Digital Command System window", \
                 action="store_true")
cli.add_argument("--resize", \
                 help="Make the window resizable.", \
                 action="store_true")
cli.add_argument("--ascii", \
                 help="Replace UTF-8 characters like superscripts with ASCII representations.", 
                 action="store_true")
cli.add_argument("--abbreviate", \
                 help="Abbreviate units (like METERS -> M).", \
                 action="store_true")
cli.add_argument("--fontsize", \
                 help="Change font size (default %d)" % fontSize, \
                 type=int)
cli.add_argument("--version", \
                 help="1=AS-206RAM, 2=AS-512 (default), 3=AS-513.", \
                 type=int)
args = cli.parse_args()

# Characteristics of the host and port being used for yaLVDC communications.  
if args.host:
    TCP_IP = args.host
else:
    TCP_IP = 'localhost'
if args.port:
    TCP_PORT = args.port
else:
    TCP_PORT = 19653

# Characteristics of this client being used for communicating with yaLVDC.
if args.id:
    ID = args.id
else:
    ID = 1

if args.dcs:
    showDcs = args.dcs
    
if args.resize:
    resize = args.resize
    resize = 1
    
if args.ascii:
    asciiOnly = args.ascii

if args.abbreviate:
    abbreviateUnits = args.abbreviate

if args.fontsize:
    fontSize = args.fontsize

if args.version:
    version = args.version
if version == 1:
    missionDesignation = "AS-206RAM"
    forMission = forAS206RAM
    showDcs = False
elif version == 2:
    missionDesignation = "AS-512"
    forMission = forAS512
    dcsForMission = dcsForAS512
elif version == 3:
    missionDesignation = "AS-513"
    forMission = forAS513
    try:
        dcsForMission = dcsForAS513
    except:
        showDcs = False
else:
    print("Unrecognized LVDC version (%d)." % version)
    sys.exit(1)
variables = {}
for pio in forMission:
    variables[forMission[pio][0]] = pio
if showDcs:
    modes = {}
    for mode in dcsForMission:
        modes[dcsForMission[mode]["name"]] = mode

lvdcSetVersion(version)

#-----------------------------------------------------------------------------
# Output DCS.

# Call this frequently in main loop to take care of actual transmissions to
# the lvdc.
pendingDcsTransmissions = []
pendingDcsStatusCodes = []
pdsEMPTY = 0
pdsWAIT1 = 1
pdsWAIT2 = 2
pendingDcsState = pdsEMPTY
pendingDcsDesiredStatus = 0
pendingDcsTimeout = 0
knownErrorCodes = { # Cut-and-pasted rom Saturn IB EDD
    0o04: "Orbital Mode/Data bit is invalid; data command was received when a mode command was expected",
    0o10: "True complement test failed for mode command; information bits 7-1 are not the complement of bits 14-8",
    0o14: "Mode command invalid; the mode command received is not defined for this mission ",
    0o20: "Orbital Mode/Data bit is invalid; mode command was received when expecting a data command",
    0o24: "Mode command sequence bit incorrect; the sequence bit received was 1 instead of 0",
    0o34: "Unable to issue generalized switch selector function at this time, the last requested generalized switch selector function has not been issued",
    0o44: "True complement test failed for data command; information bits 7-1 are not the complement of bits 14-8",
    0o50: "The start module, sector, and address requested by the memory dump command is greater than the end module, sector, and address; or one or more locations requested by the memory dump command are in a non-existing module",
    0o54: "The time of implementation of a navigation update, execute generalized maneuver, execute maneuver, or return to nominal timeline, is less than 10 sec in the future",
    0o60: "Data command sequence bit incorrect; the sequence bit must begin with 1 and alternate from 1 to 0 in each sequential data command of a set",
    0o64: "A DCS program is in progress at this time; however, no more data is required; only a terminate mode command can be processed at this time",
    0o74: "The mode command received is defined for this mission but is not acceptable in the present time frame"
    }

def servicePending():
    global pendingDcsTransmissions, pendingDcsStatusCodes, pendingDcsState, \
            pendingDcsDesiredStatus, pendingDcsTimeout
            
    def formatReception(receivedTuple):
        first, second = ("%03o,%09o" % receivedTuple, "")
        pio = receivedTuple[0]
        pendingStatus = receivedTuple[1]
        if pio == 0o055:
            errorCode = (pendingStatus >> 20) & 0o77
            count = (pendingStatus >> 14) & 0o7
            command = (pendingStatus >> 8) & 0o77
            first = "Error code %02o,%02o,%o" % (command,errorCode,count)
            if errorCode in knownErrorCodes:
                second = knownErrorCodes[errorCode]
        elif pio in [0o030, 0o574]:
            if pendingStatus & 2:
                first = "data status %02o" % ((pendingStatus >> 20) & 0o77)
            else:
                first = "mode status %02o" % ((pendingStatus >> 20) & 0o77)
        return first, second
            
    while True:
        if pendingDcsState == pdsEMPTY:
            if len(pendingDcsStatusCodes) > 0:
                msg = ""
                while len(pendingDcsStatusCodes) > 0:
                    if len(msg) > 0:
                        msg = msg + ", "
                    first, second = formatReception(pendingDcsStatusCodes.pop(0))
                    msg = msg + first
                print("Popping code(s):", msg)
                sys.stdout.flush()
            if len(pendingDcsTransmissions) > 0:
                pendingTransmission = pendingDcsTransmissions.pop(0)
                pendingDcsDesiredStatus = pendingTransmission[0]
                s.send(pendingTransmission[1])
                pendingDcsStatusCodes.clear()
                pendingDcsState = pdsWAIT1
                pendingDcsTimeout = time.time_ns() + 1000000000 
                first, second = formatReception((0o030, pendingDcsDesiredStatus))
                print("Waiting for %s" % first)
                sys.stdout.flush()
            return
        elif len(pendingDcsStatusCodes) == 0:
            if time.time_ns() >= pendingDcsTimeout:
                print("DCS timed out waiting for acknowledgement")
                sys.stdout.flush()
                pendingDcsTransmissions.clear()
                pendingDcsStatusCodes.clear()
                pendingDcsState = pdsEMPTY
            return
        else:
            pendingStatusTuple = pendingDcsStatusCodes.pop()
            channel = pendingStatusTuple[0]
            pendingStatus = pendingStatusTuple[1]
            sys.stdout.flush()
            if channel == 0o55:
                first, second = formatReception(pendingStatusTuple)
                print("Received %s" % first)
                if second != "":
                    print(second)
                sys.stdout.flush()
                pendingDcsTransmissions.clear()
                pendingDcsStatusCodes.clear()
                pendingDcsState = pdsEMPTY
                return
            # Note that below I don't actually distinguish between the PIO's
            # received for mode status (PIO 030) and those for data status
            # (PIO 0574).  In other words, if somehow a data status word arrived
            # on PIO 030 it would be accepted, while if a mode status word 
            # arrived on PIO 0574 then it would be accepted too.  That can't
            # happen, of course, but if I insisted on implementing it by the
            # book, I'd handle those cases separately.
            if pendingStatus != pendingDcsDesiredStatus:
                print("DCS protocol mismatch (%09o != %09o)" % \
                      (pendingStatus, pendingDcsDesiredStatus))
                pendingDcsTransmissions.clear()
                pendingDcsStatusCodes.clear()
                pendingDcsState = pdsEMPTY
                return
            elif pendingDcsState == pdsWAIT1:
                first, second = formatReception(pendingStatusTuple)
                print("Received first expected %s" % first)
                sys.stdout.flush()
                pendingDcsState = pdsWAIT2
            else: # pendingDcsState == pdsWAIT2
                first, second = formatReception(pendingStatusTuple)
                print("Received second expected %s" % first)
                sys.stdout.flush()
                pendingDcsState = pdsEMPTY

SIGN = 0o200000000
BIT6 = SIGN >> 6
BIT13 = SIGN >> 13
BIT22 = SIGN >> 22
BITS6and13 = BIT6 | BIT13
BITS7through13 = 0o177 * BIT13
BITSunused = BIT13 - 1
dcsSequenceNumber = 0
def dcsTransmit(isItCommand, sixBitValue):
    global dcsSequenceNumber, pendingDcsTransmissions
    outputBuffer = bytearray(6)
    if isItCommand:
        dcsSequenceNumber = 0
    encoded7 = ((sixBitValue & 0o77) << 1) | dcsSequenceNumber
    encoded26 = (encoded7 * BITS6and13) ^ BITS7through13
    if isItCommand:
        encoded26 |= BITSunused
        desiredStatus =  encoded26 & 0o374000000
    else:
        desiredStatus =  encoded26 | 0o000007777
    dcsSequenceNumber ^= 1
    # At this point, we now have a proper 26-bit word for the PIO's data, 
    # in the form the LVDC will expect to encounter it, but
    # we need to turn it into a 6-byte packet for transfer to the LVDC.
    # This is described in the comments at the top of virtualWire.c.
    channel = 0o043
    outputBuffer[0] = 0x80 | (ID & 7)
    outputBuffer[1] = channel
    outputBuffer[2] = ((channel & 0x180) >> 2) | ((encoded26 >> 21) & 0x1F)
    outputBuffer[3] = (encoded26 >> 14) & 0x7F
    outputBuffer[4] = (encoded26 >> 7) & 0x7F
    outputBuffer[5] = encoded26 & 0x7F
    pendingDcsTransmissions.append((desiredStatus, outputBuffer))
    
def dcsTransmit26(word):
    dcsTransmit(False, (word >> 20) & 0o77)
    dcsTransmit(False, (word >> 14) & 0o77)
    dcsTransmit(False, (word >> 8) & 0o77)
    dcsTransmit(False, (word >> 2) & 0o77)
    dcsTransmit(False, (word << 4) & 0o60)

def scaleData(value, dataScale):
    if dataScale == -1000:
        return value
    else:
        negate = False
        if value < 0:
            negate = True
            value = -value
        valueToUse = hround(value * 2**(25-dataScale))
        if valueToUse > 0o377777777:
            return None
        if negate:
            valueToUse ^= 0o377777777
        return valueToUse

def getMemLoc(dmStr, dsStr, locStr):
    try:
        dm = int(dmStr, 8)
        ds = int(dsStr, 8)
        loc = int(locStr, 8)
    except:
        print("Parameter not octal.")
        return 0,0,0,True
    if dm not in [0, 2, 4, 6]:
        print("DM not 0, 2, 4, or 6")
        return 0,0,0,True
    if ds < 0 or ds > 0o17:
        print("DS out of range")
        return 0,0,0,True
    if loc < 0 or loc > 0o377:
        print("LOC out of range")
        return 0,0,0,True
    return dm,ds,loc,False

def dcsButtonCallback(event):
    name = event.widget["text"]
    mode = modes[name]
    row = dcs.dict[name]
    dcsEntry = dcsTypes[name]
    
    # First take care of the simplest, generic cases, and then move on to 
    # the more-complex custom cases.  The simplest case is one with no
    # "dataValues" array, since that's one we haven't figured out how to 
    # implement yet.
    if "dataValues" not in dcsEntry:
        print("%s command insufficiently documented or reverse engineered" % name)
        sys.stdout.flush()
        return
    
    # The next-simplest case is that of commands that require no data words,
    # since they can all be encoded in precisely the same manner.
    if dcsEntry["numDataWords"] == 0:
        dcsTransmit(True, mode)
        return
    
    # The next-simplest case is that of commands that have data words, but with
    # the data words corresponding on a straightforward one-to-one basis with 
    # the items input from the UI.  In other words, where each input item can
    # just be converted to a data word in the obvious way.  Those items are
    # distinguished by the fact that their dcsEntry includes the key "simple".
    if "simple" in dcsEntry:
        # First let's convert each of the input data fields into an octal
        # word and abort on failure.  As far as I know, all input
        # values for these types of commands will be decimal, so I don't 
        # need to use the units to deduce decimal vs octal.  I'm not 
        # actually sure how the scaling is supposed to work, so I just undo
        # what lvdcFormatData() does to format the telemetry words.
        words = []
        for i in range(len(dcsEntry["dataValues"])):
            dataName = dcsEntry["dataValues"][i]
            try:
                value = float(row[2 + 2*i].get())
            except:
                print(dataName, "was not a decimal number")
                return
            dataScale = dcsEntry["dataScales"][i]
            dataUnits = dcsEntry["dataUnits"][i]
            valueToUse = scaleData(value, dataScale)
            if valueToUse == None:
                print("Overflow for", dataName)
                return
            if False: # Double check the scaling.
                checkValue = lvdcFormatData(valueToUse, dataScale, \
                                                dataUnits)
                print(dataName, dataScale, dataUnits, value, \
                        "%09o" % valueToUse, checkValue)
            words.append(valueToUse)
        # Data conversion was okay, so let's everything transmit!
        dcsTransmit(True, mode)
        for word in words:
            dcsTransmit26(word)
        return
    
    # Finally, we have various commands that do have data words, but with the
    # data packed into the upwords in some more-complex manner than the simpler
    # cases above, and so we have to encode their data into those data words in
    # whatever manner is appropriate to the individual command.  Usually this
    # will have been something undocumented that needed to be deduced somehow
    # via reverse engineering.
    if name == "SECTOR DUMP":
        '''
        This is undocumented, so let's start with a series of guesses.
        Looking at the 3 sector-dump commands (NAV update, PDU, ODU) on 
        p. 55-24 of the NOD document, here's my guess for the 12 data bits 
        sent (more-significant 6 in 1st data word, less-significant 6 in 
        2nd data word):
           MMM 0SS SSE EEE
        where:
           MMM is the module number.
           SSSS is the starting sector number
           EEEE is the ending sector number.
        This matches the MM-SSSS for the NAV UPDATE sector in AS-512 and 
        AS-513, namely the variables D.VUDZ, D.VUDX, D.VUDY, D.VUZS, D.VUXS,
        D.VUYS, and D.VNUT starting at 4-15-371.  Unfortunately, I don't know
        what PTU and OTU are, though the bit patterns are consistent with the
        guesses above.
        
        To test these guesses, we need to examine the Flight Program source 
        code D.S430.  I was going to detail my findings, but to make a long 
        story slightly shorter, I shockingly find that every detail of my 
        suppositions above is correct and easy to verify, except for the
        fact that the least-significant bit of MMM ends up being dropped after
        being read, so that only even-numbered modules can be dumped.  Which
        makes sense since there's no way for the CPU to read odd modues in a 
        duplex configuration.
        '''
        try:
            dm = int(row[2].get(), 8)
            ds0 = int(row[4].get(), 8)
            ds1 = int(row[6].get(), 8)
        except:
            print("Parameter not octal.")
            return
        if dm not in [0, 2, 4, 6]:
            print("DM not 0, 2, 4, or 6")
            return
        if ds0 < 0 or ds0 > 0o17:
            print("DS0 out of range")
            return
        if ds1 < ds0:
            print("DS1 less than DS0")
            return
        if ds1 > 0o17:
            print("DS1 out of range")
            return
        value1 = (dm << 3) | ((ds0 >> 2) & 3)
        value2 = ((ds0 & 3) << 4) | ds1
        dcsTransmit(True, mode)
        dcsTransmit(False, value1)
        dcsTransmit(False, value2)
        return
    if name == "TELEMETER SINGLE LOCATION":
        '''
        There are 9 of these commands shown on pp. 55-24 and 55-25 of the NOD
        document.  Unfortunately, I wasn't able to guess what addresses they're
        *supposed* to telemeter, so I couldn't infer anything from the commands'
        bit patterns, and had to rely entirely on the FP source code (D.S470).
        Denoting the 3 data words as AAAAAA, BBBBBB, and CCCCCC, what I found
        was this:
                AAAAAA BBBBBB CCCCCC
                MMMLLL LLLLL  SSSS
        where MMM is transparently masked to MM0 after extraction.  *Not* my
        best guess from the NOD commands.  :-)  The addresses turned out to be 
        2-06-200 through 2-06-210, which in AS-512 is an area denoted as
        "EXECUTABLE MANEUVERS TO BE INITIALIZED", and commented "MANEUVER 2" 
        through "MANEUVER 13" individually.  Which I'm forced to admit may 
        indeed have been guessable; but there's nothing corresponding in
        AS-513, so perhaps not all that guessable after all.
        '''
        dm,ds,loc,error = getMemLoc(row[2].get(), row[4].get(), row[6].get())
        value1 = (dm << 3) | ((loc >> 5) & 7)
        value2 = (loc & 0o37) << 1
        value3 = ds << 2
        dcsTransmit(True, mode)
        dcsTransmit(False, value1)
        dcsTransmit(False, value2)
        dcsTransmit(False, value3)
        return
    if name == "MEMORY DUMP":
        '''
        The only info on this presently is in the AS-513 FP source code 
        (D.S430).  There are 6 data words ... 3 for the starting address and
        3 for the ending address.  Each of the two is formatted the same as
        the other, so I'll just give you the formatting of one set of 3 words:
            AAAAAA BBBBBB CCCCCC
            LLLLLL LL MMM SSSS
        where MMM is transparently converted to MM0.  Note that this is 
        different than the 3-word format for TELEMETER SINGLE LOCATION.
        '''
        dm0,ds0,loc0,error = getMemLoc(row[2].get(), row[4].get(), row[6].get())
        if error:
            return
        dm1,ds1,loc1,error = getMemLoc(row[2].get(), row[4].get(), row[6].get())
        if error:
            return
        value1 = (loc0 >> 2) & 0o77
        value2 = ((loc0 << 4) & 0o60) | dm0
        value3 = (ds0 << 2) & 0o74
        value4 = (loc1 >> 2) & 0o77
        value5 = ((loc1 << 4) & 0o60) | dm1
        value6 = (ds1 << 2) & 0o74
        dcsTransmit(True, mode)
        dcsTransmit(False, value1)
        dcsTransmit(False, value2)
        dcsTransmit(False, value3)
        dcsTransmit(False, value4)
        dcsTransmit(False, value5)
        dcsTransmit(False, value6)
        return
    if name == "GENERALIZED SWITCH SELECTOR":
        '''
        There are a number of examples of this in NOD, with descriptions like
        "LH2 Vent Open", "LH2 Vent Closed", "LOX Pressure Safe", "S-IVB Cutoff",
        and so on, but without any explanation of what those are or what they
        have in commen, other than the fact that eash has 2 data words.  So we
        have to resort to examining the FP source code (D.S380).  My findings:
            AAAAAA BBBBBB
            TS  DD DDDDD
        where S is the S-IVB flag, but T and DDDDDDD are more uncertain.  Within
        the FP, this is converted to a "switch selector word" of the form
            T0S 000 DDD DDD D
        filled on the right with 0.  There's little explanation anywhere I've
        found of how a "switch selector word" works, but they seem to be formed
        by
            SSF2   FORM    5P,8O,13D
        with the 1st parameter being the "stage", the 2nd being an "address",
        and the 3rd being 0.  The stages for which symbolic constants are 
        provided by the FP are:
            IU     EQU     (-80)
            SIVB   EQU     (4)
            SII    EQU     (2)
            SIC    EQU     (1)
            SIB    EQU     (1)
        It's not 100% clear how -80 might be represented as a 5-bit pattern, 
        but it seems possible that the stages would convert to 5-bit patterns 
        10110, 00100, 00010, 00001, 00001.  So *perhaps* the possible 
        combinations could be
            TS = 11    IU
            TS = 01    S-IVB
            TS = 00    SII, SIC, or SIB.
        or perhaps
            TS = 10    IU
            TS = 01    S-IVB
        Examining the NOD requests already mentioned from p. 55-24, and others
        on p. 55-26, the only combinations that seem to appear are TS=01 and 10,
        so I'm thinking that those are the only choices.
        '''
        stage = row[2].get().upper()
        if stage not in ["IU", "SIVB", "S-IVB", "S4B", "S-4B"]:
            print("Stage must be IU or SIVB")
            return
        try:
            loc = int(row[4].get(), 8)
        except:
            print("Address not octal.")
            return
        if loc < 0 or loc > 0o177:
            print("Address out of range")
            return
        if stage == "IU":
            value1 = 0o40
        else:
            value1 = 0o20
        value1 |= (loc >> 5) & 3
        value2 = (loc << 1) & 0o76
        dcsTransmit(True, mode)
        dcsTransmit(False, value1)
        dcsTransmit(False, value2)
        return
    if name == "LADDER MAGNITUDE LIMIT":
        '''
        Again, no explicit documentation about this one, or for that matter,
        even aout "ladders".  I think "ladder" refers to D/A-converters used
        (in this case) to control pitch, yaw, and roll of the launch vehicle.
        The have a range of 0 to 255, representing angles of 0 to 15.3 degrees,
        or 0.06 degrees per "ladder unit".  In AS-512 at least, there the 
        variable D.VM06 is the maximum magnitude (in ladder units) for roll, 
        while D.VM16 is the maximum magnitude for pitch and yaw.  (Not the max
        *rate*, which is a different variable and not controlled by this DCS
        command.)  This command overwrites both D.VM06 and D.VM16 with the same
        value.  The relevant AS-512 source code is D.S980, and my finding is
        that the entire AAAAAA provides the limit as an unsigned integer 0-63
        decimal.
        '''
        try:
            value = hround(float(row[2].get()))
        except:
            print("Not a decimal number")
            return
        if value < 0 or value > 63:
            print("Out of range")
            return
        dcsTransmit(True, mode)
        dcsTransmit(False, value)
        return
    if name == "S-IVB/IU LUNAR IMPACT":
        '''
        No documentation.  The relevant AS-512 subroutine is D.S900.
            AAAAAA BBBBBB CCCCCC DDDDDD
               MMM MMMMMM SSSSSS SSSSSS
        where M...M is unsigned minutes and S...S is unsigned seconds.
        EEEEEE, FFFFFF, and GGGGGG are respectively delta-pitch, delta-yaw,
        and delta-roll.
        '''
        try:
            minutes = int(row[2].get())
            seconds = int(row[4].get())
            deltaPitch = int(row[6].get())
            deltaYaw = int(row[8].get())
            deltaRoll = int(row[10].get())
        except:
            print("Not integer")
            return
        if minutes < 0 or minutes > 511:
            print("Minutes out of range")
            return
        if seconds < 0 or seconds > 4095:
            print("Seconds out of range")
            return
        if abs(deltaPitch) > 31:
            print("Delta pitch out of range")
            return
        if abs(deltaYaw) > 31:
            print("Delta yaw out of range")
            return
        if abs(deltaRoll) > 31:
            print("Delta roll out of range")
            return
        value1 = minutes >> 6
        value2 = minutes & 0o77
        value3 = seconds >> 6
        value4 = seconds & 0o77
        value5 = deltaPitch & 0o77
        value6 = deltaYaw & 0o77
        value7 = deltaRoll & 0o77
        dcsTransmit(True, mode)
        dcsTransmit(False, value1)
        dcsTransmit(False, value2)
        dcsTransmit(False, value3)
        dcsTransmit(False, value4)
        dcsTransmit(False, value5)
        dcsTransmit(False, value6)
        dcsTransmit(False, value7)
        return
    if name in ["TIME BASE UPDATE", "FINE TIME BASE UPDATE"]:
        '''
        See AS-512/AS-513 subroutines D.S260.
        '''
        try:
            adjustment = float(row[2].get())
        except:
            print("Not decimal number")
            return
        value = hround(adjustment / 4.0)
        if value < -31 or value > 31:
            print("Out of range")
            return
        dcsTransmit(True, mode)
        dcsTransmit(False, value)
        return
    if name == "COARSE TIME BASE UPDATE":
        '''
        See AS-513 subroutines D.S270.
        '''
        try:
            adjustment = float(row[2].get())
        except:
            print("Not decimal number")
            return
        value = hround(adjustment / 128.0)
        if value < -31 or value > 31:
            print("Out of range")
            return
        dcsTransmit(True, mode)
        dcsTransmit(False, value)
        return
    if name == "EXECUTE GENERALIZED MANEUVER":
        '''
        See AS-513 subroutine D.S540.  *Almost* a "simple" configuration, 
        except that the first transmitted 5-word packet contains a packed time
        and a maneuver type; the remainint 5-word packets are "simple".
        '''
        try:
            seconds = int(row[2].get())
        except:
            print("TIME not integer")
            return
        if seconds < 0:
            print("TIME is negative")
            return
        maneuverType = row[4].get().upper()
        if maneuverType.startswith("HOLD"):
            maneuverType = 1
        elif maneuverType.startswith("TRACK"):
            maneuverType = 2
        else:
            print("TYPE must be HOLD or TRACK")
            return
        try:
            pitch = float(row[6].get())
            yaw = float(row[8].get())
            roll = float(row[10].get())
        except:
            print("PITCH, YAW, or ROLL not decimal")
            return
        dataScales = dcsEntry["dataScales"]
        seconds = scaleData(seconds, dataScales[0])
        pitch = scaleData(pitch, dataScales[2])
        yaw = scaleData(yaw, dataScales[3])
        roll = scaleData(roll, dataScales[4])
        dcsTransmit(True, mode)
        dcsTransmit(False, (seconds >> 20) & 0o77)
        dcsTransmit(False, (seconds >> 14) & 0o77)
        dcsTransmit(False, (seconds >> 8) & 0o77)
        dcsTransmit(False, (seconds >> 2) & 0o77)
        dcsTransmit(False, ((seconds << 4) & 0o60) | (maneuverType << 2))
        dcsTransmit26(pitch)
        dcsTransmit26(yaw)
        dcsTransmit26(roll)
        return
    if name == "EXECUTE ALTERNATE SEQUENCE":
        '''
        See AS-513 subroutine D.S800.  *Almost* a "simple" configuration with a 
        single data word, except that the normally-unused bits of the 
        transmitted data instead provide a 4-bit alternate-sequence number.
        '''
        try:
            seconds = int(row[2].get())
        except:
            print("TIME not integer")
            return
        if seconds < 0:
            print("TIME is negative")
            return
        try:
            sequenceType = int(row[4].get().upper())
        except:
            print("Requested sequence number not an integer")
            return
        if sequenceType < 0 or sequenceType > 15:
            print("Requested sequence number is out of range")
            return
        dataScales = dcsEntry["dataScales"]
        seconds = scaleData(seconds, dataScales[0])
        dcsTransmit(True, mode)
        dcsTransmit(False, (seconds >> 20) & 0o77)
        dcsTransmit(False, (seconds >> 14) & 0o77)
        dcsTransmit(False, (seconds >> 8) & 0o77)
        dcsTransmit(False, (seconds >> 2) & 0o77)
        dcsTransmit(False, ((seconds << 6) & 0o60) | sequenceType)
        return
    
    # Whatever's left over must not have been implemented yet.
    print("%s command not yet implemented" % name)
    sys.stdout.flush()

#-----------------------------------------------------------------------------

class ToolTip(object):

    def __init__(self, widget):
        self.widget = widget
        self.tipwindow = None
        self.id = None
        self.x = self.y = 0

    def showtip(self, text):
        self.text = text
        if self.tipwindow or not self.text:
            return
        x, y, cx, cy = self.widget.bbox("insert")
        x = x + self.widget.winfo_rootx() + 57
        y = y + cy + self.widget.winfo_rooty() +27
        self.tipwindow = tw = tk.Toplevel(self.widget)
        tw.wm_overrideredirect(1)
        tw.wm_geometry("+%d+%d" % (x, y))
        label = tk.Label(tw, text=self.text, justify=tk.LEFT,
                      background="#ffffe0", relief=tk.SOLID, borderwidth=1,
                      font="TkFixedFont")
        label.pack(ipadx=1)

    def hidetip(self):
        tw = self.tipwindow
        self.tipwindow = None
        if tw:
            tw.destroy()

def normalizeText(text):
    if not asciiOnly:
        text = text.replace("**2", "²").replace("**-1", "⁻¹")
        text = text.replace("DELTA ", "Δ")
    if abbreviateUnits:
        text = text.replace("METERS", "M")
        text = text.replace("METER", "M")
        text = text.replace("SECONDS", "S")
        text = text.replace("SECOND", "S")
        text = text.replace("KILOGRAM", "KG")
        text = text.replace("RADIANS", "RAD")
        text = text.replace("RADIAN", "RAD")
    return text

def CreateToolTip(widget, text):
    toolTip = ToolTip(widget)
    def enter(event):
        toolTip.showtip(normalizeText(text))
    def leave(event):
        toolTip.hidetip()
    widget.bind('<Enter>', enter)
    widget.bind('<Leave>', leave)

# An event for clicking on a variable name.  It cycles through my chosen
# set of colors.
gray = "#3f3f3f"
colors = ["#000000", "#ff0000", "#00ff00", "#0000ff"]
def varClick(event):
    color = event.widget["fg"]
    color = colors[(colors.index(color) + 1) % len(colors)]
    event.widget["fg"] = color

lightGray = "#cfcfcf"
yellow = "#ffff00"
doubleClicked = set()
doubleClickTimeouts = {}
doubleClickIds = {}

def telControlClickCallback(event):
    global doubleClicked
    widget = event.widget
    id = str(widget)
    if id in doubleClicked:
        doubleClicked.remove(id)
    else:
        doubleClicked.add(id)

def telChanged(widget):
    global doubleClickTimeouts, doubleClickIds
    id = str(widget)
    if id not in doubleClicked:
        return
    oldColor = widget["bg"]
    widget["bg"] = yellow
    timeout = (time.time_ns() - t0) // 1000000 + 1000
    if id not in doubleClickIds:
        doubleClickIds[id] = [timeout, widget, oldColor]
    else:
        oldTimeout = doubleClickIds[id][0]
        doubleClickIds[id][0] = timeout
        if oldTimeout in doubleClickTimeouts:
            if id in doubleClickTimeouts[oldTimeout]:
                doubleClickTimeouts[oldTimeout].remove(id)
    if timeout in doubleClickTimeouts:
        doubleClickTimeouts[timeout].append(id)
    else:
        doubleClickTimeouts[timeout] = [id]


class telPanel:
    def __init__(self, top=None):
    
        top.title(missionDesignation + " LVDC TELEMETRY")
        top.configure(highlightcolor="black")
        
        numPIOs = len(forMission)
        self.numCols = 5
        self.numRows = (numPIOs + self.numCols - 1) // self.numCols
        self.array = []
        for row in range(self.numRows):
            self.array.append([])
        self.locations = {}
        row = 0
        for var in sorted(variables):
            pio = variables[var]
            teld = forMission[pio]
            scale = ""
            if teld[1] != -1000:
                if teld[2] == -1000:
                    scale = "B%d" % teld[1]
                else:
                    scale = "B%d/B%d" % (teld[1], teld[2])
            tooltip = "Variable:     %s\n" % teld[0] + \
                      "Mode reg:     %o\n" % (pio >> 9) + \
                      "PIO channel:  %03o\n" % (pio & 0o177) + \
                      "Binary scale: %s\n" % scale + \
                      "Units:        %s\n" % teld[3] + \
                      "Description:  %s" % teld[4]
            rowArray = self.array[row]
            label = tk.Label(text=" "+teld[0]+": ", fg=gray, anchor="e")
            label.grid(row=row, column=len(rowArray), sticky=tk.W)
            rowArray.append(label)
            CreateToolTip(label, tooltip)
            self.locations[pio] = (row, len(rowArray))
            label = tk.Label(text="", width=12, fg=colors[0], \
                             anchor="w", name=str(pio))
            label.grid(row=row, column=len(rowArray), sticky=tk.W)
            label.bind("<Control-Button-1>", telControlClickCallback)
            label.bind('<Button-1>', varClick)
            rowArray.append(label)
            text = normalizeText(teld[3])
            label = tk.Label(text=text+" ", fg=gray, anchor="w")
            label.grid(row=row, column=len(rowArray), sticky=tk.W)
            rowArray.append(label)
            if len(rowArray) < 4 * self.numCols - 1:
                separator = tk.ttk.Separator(orient=tk.VERTICAL)
                separator.grid(row=row, column=len(rowArray), \
                               rowspan=1, sticky=tk.NS)
                rowArray.append(separator)
            row += 1
            if row >= self.numRows:
                row = 0

class dcsPanel:
    def __init__(self, root):
        
        def close():
            exit(0)
        
        self.root = root
        self.root.title(missionDesignation + " LVDC DIGITAL COMMAND SYSTEM (DCS)")
        self.root.protocol("WM_DELETE_WINDOW", close)
        self.root.geometry("+0-50")
        self.array = []
        self.dict = {}
        for dcs in sorted(dcsForMission):
            dcsEntry = dcsForMission[dcs]
            row = []
            button = tk.Button(master=self.root, text=dcsEntry["name"])
            button.grid(row=len(self.array), column=len(row), padx=8, sticky="ew")
            tooltip = ("Command Name: %s\n" % dcsEntry["name"]) + \
                      ("Octal Command: %02o\n" % dcs) + \
                      ("Description:   %s\n" % dcsEntry["description"]) + \
                      ("Data words:    %d" % dcsEntry["numDataWords"])
            CreateToolTip(button, tooltip)
            button.bind("<Button-1>", dcsButtonCallback)
            row.append(button)
            if "dataValues" in dcsEntry and "unimplemented" not in dcsEntry:
                if len(dcsEntry["dataValues"]) == 0:
                    if False:
                        label = tk.Label(master=self.root, text="(No data)", anchor=tk.W)
                        label.grid(row=len(self.array), column=len(row), sticky=tk.W)
                        row.append(label)
                else:
                    for d in range(len(dcsEntry["dataValues"])):
                        dataValue = dcsEntry["dataValues"][d]
                        label = tk.Label(master=self.root, \
                                         text=normalizeText(dataValue)+":", \
                                         anchor=tk.E)
                        label.grid(row=len(self.array), column=len(row), sticky=tk.E)
                        tooltip = ("Data Name:   %s" % dataValue)
                        if "dataDescriptions" in dcsEntry:
                            tooltip = tooltip + ("\nDescription: %s" % \
                                                dcsEntry["dataDescriptions"][d])
                        if "dataScales" in dcsEntry:
                            scale = dcsEntry["dataScales"][d]
                            if scale != -1000:
                                tooltip = tooltip + ("\nScale:       B%d" % \
                                                     scale)
                        if "dataUnits" in dcsEntry:
                            units = normalizeText(dcsEntry["dataUnits"][d])
                            if units != "":
                                tooltip = tooltip + ("\nUnits:       %s" % units)
                        CreateToolTip(label, tooltip)
                        row.append(label)
                        entry = tk.Entry(master=self.root, width=12)
                        entry.grid(row=len(self.array), column=len(row), padx=8, sticky=tk.W)
                        row.append(entry)
            else:
                if False:
                    label = tk.Label(master=self.root, text="(TBD)", anchor=tk.W)
                    label.grid(row=len(self.array), column=len(row), sticky=tk.W)
                    row.append(label)
                button["state"] = "disabled"

            self.array.append(row)
            self.dict[dcsEntry["name"]] = row
            
##############################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

newConnect = False
def connectToLVDC():
    global newConnect
    count = 0
    sys.stderr.write("Connecting to LVDC/PTC emulator at %s:%d\n" % \
                        (TCP_IP, TCP_PORT))
    while True:
        try:
            s.connect((TCP_IP, TCP_PORT))
            sys.stderr.write("Connected.\n")
            newConnect = True
            lvdcModeReset()
            break
        except socket.error as msg:
            sys.stderr.write(str(msg) + "\n")
            count += 1
            if count >= 50:
                sys.stderr.write("Too many retries ...\n")
                time.sleep(3)
                sys.exit(1)
            time.sleep(1)

connectToLVDC()

###############################################################################
# Event loop.  Just check periodically for output from yaLVDC (in which case 
# the user-defined callback function outputFromCPU is executed) or data in the 
# user-defined function inputsForCPU (in which case a message is sent to 
# yaLVDC). But this section has no target-specific code, and shouldn't need to 
# be modified unless there are bugs.

# Given a 4-tuple (ioType,channel,value,mask), creates packet data and sends it 
# to yaLVDC.
def packetize(tuple):
    outputBuffer = bytearray(6)
    source = ID
    ioType = tuple[0]
    channel = tuple[1]
    value = tuple[2]
    mask = tuple[3]
    if mask != 0o377777777:
        outputBuffer[0] = 0x80 | 0x40 | ((ioType & 7) << 3) | (ID & 7)
        outputBuffer[1] = channel & 0x7F
        outputBuffer[2] = ((channel & 0x180) >> 2) | ((mask >> 21) & 0x1F)
        outputBuffer[3] = (mask >> 14) & 0x7F
        outputBuffer[4] = (mask >> 7) & 0x7F
        outputBuffer[5] = mask & 0x7F
        s.send(outputBuffer)
    outputBuffer[0] = 0x80 | ((ioType & 7) << 3) | (ID & 7)
    outputBuffer[1] = channel & 0x7F
    outputBuffer[2] = ((channel & 0x180) >> 2) | ((value >> 21) & 0x1F)
    outputBuffer[3] = (value >> 14) & 0x7F
    outputBuffer[4] = (value >> 7) & 0x7F
    outputBuffer[5] = value & 0x7F
    s.send(outputBuffer)

def outputFromCPU(ioType, channel, value):
    var, val, sc1, sc2, units, desc, msg, aug = \
        lvdcTelemetryDecoder(ioType, channel, value)
    if aug == None:
        return
    if aug == 0o4470: # Block header
        mmm = (val >> 23) & 0o7
        ssss = (val >> 19) & 0o17
        loc = (val >> 11) & 0o377
        print("Memory header %o-%02o-%03o" % (mmm, ssss, loc))
        return
    if aug >= 0o4474 and aug <= 0o4570 and (aug & 3) == 0:
        print("Memory word +%02o: %09o (%09o)" % ((aug - 0o4474) // 4, val, val<<1))
        return
    if aug in top.locations:
        row, col = top.locations[aug]
        widget = root.grid_slaves(row=row, column=col)[0]
        raw, scaled = lvdcFormatData(val, sc1, units)
        if scaled == "":
            valueToUse = raw
        else:
            valueToUse = scaled
        if widget["text"] != valueToUse:
            telChanged(widget)
        widget["text"] = valueToUse

def inputsForCPU():
    return []

# Buffer for a packet received from yaLVDC.
packetSize = 6
inputBuffer = bytearray(packetSize)
leftToRead = packetSize
view = memoryview(inputBuffer)

didSomething = False
def mainLoopIteration():
    global didSomething, inputBuffer, leftToRead, view
    global doubleClickTimeouts, doubleClickIds
    global pendingDcsStatusCodes

    timeNow = (time.time_ns() - t0) // 1000000
    for timeout in sorted(doubleClickTimeouts.keys()):
        if timeout > timeNow:
            break;
        for id in doubleClickTimeouts[timeout]:
            record = doubleClickIds.pop(id)
            record[1]["bg"] = record[2]
        del doubleClickTimeouts[timeout]

    # State machine for processing DCS protocol (i.e., sending to LVDC and
    # receiving corresponding acknowledgements).
    servicePending()

    # Check for packet data received from yaLVDC and process it.
    # While these packets are always the same length in bytes,
    # since the socket is non-blocking any individual read
    # operation may yield less bytes than that, and the buffer may accumulate
    # data over time until it fills.    
    try:
        numNewBytes = s.recv_into(view, leftToRead)
    except:
        numNewBytes = 0
    if numNewBytes > 0:
        view = view[numNewBytes:]
        leftToRead -= numNewBytes 
        if leftToRead == 0:
            # Prepare for next read attempt.
            view = memoryview(inputBuffer)
            leftToRead = packetSize
            # Parse the packet just read, and call outputFromAGx().
            # Start with a sanity check.
            ok = 1
            if (inputBuffer[0] & 0x80) != 0x80:
                ok = 0
            elif (inputBuffer[1] & 0x80) != 0x00:
                ok = 0
            elif (inputBuffer[2] & 0x80) != 0x00:
                ok = 0
            elif (inputBuffer[3] & 0x80) != 0x00:
                ok = 0
            elif (inputBuffer[4] & 0x80) != 0x00:
                ok = 0
            elif (inputBuffer[5] & 0x80) != 0x00:
                ok = 0
            # Packet has the various signatures we expect.
            if ok == 0:
                # The protocol allows yaLVDC to send a byte that's 0xFF, 
                # which is intended as a ping and can be ignored.  I don't
                # know if there will actually be any such messages.  For 
                # other corrupted packets we print a message.  In either 
                # case, we try to realign past the corrupted/ping byte(s).
                if inputBuffer[0] != 0xff:
                    print("Illegal packet: %03o %03o %03o %03o %03o %03o" % \
                            tuple(inputBuffer))
                for i in range(1,packetSize):
                    if (inputBuffer[i] & 0x80) == 0x80 and \
                            inputBuffer[i] != 0xFF:
                        j = 0
                        for k in range(i,6):
                            inputBuffer[j] = inputBuffer[k]
                            j += 1
                        view = view[j:]
                        leftToRead = packetSize - j
            else:
                ioType = (inputBuffer[0] >> 3) & 7
                source = inputBuffer[0] & 7
                channel = ((inputBuffer[2] << 2) & 0x180) | \
                            (inputBuffer[1] & 0x7F)
                value = (inputBuffer[2] & 0x1F) << 21
                value |= (inputBuffer[3] & 0x7F) << 14
                value |= (inputBuffer[4] & 0x7F) << 7
                value |= inputBuffer[5] & 0x7F
                if source == 0 and getLvdcMode() == 4 and channel in [0o030, 0o055, 0o574]:
                    pendingDcsStatusCodes.append((channel,value))
                outputFromCPU(ioType, channel, value)
            didSomething = True
    
    # Check for locally-generated data for which we must generate messages to
    # yaLVDC over the socket.  In theory, the externalData list could contain
    # any number of channel operations, but in practice it will probably contain
    # only 0 or 1 operations.
    externalData = inputsForCPU()
    for i in range(0, len(externalData)):
        packetize(externalData[i])
        didSomething = True
    
    root.after(refreshRate, mainLoopIteration)

root = tk.Tk()
defaultFont = font.nametofont("TkFixedFont")
defaultFont.configure(size=fontSize)
root.option_add("*Font", defaultFont)
top = telPanel(root)
if showDcs:
    dcs = dcsPanel(tk.Toplevel(root))
    dcs.root.resizable(resize, resize)

root.resizable(resize, resize)
root.after(refreshRate, mainLoopIteration)
root.mainloop()
