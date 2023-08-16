#!/usr/bin/env python3
# Copyright:    None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename:     yaPTC.py
# Purpose:      This is an LVDC telemetry and Digital Command System (DCS) 
#               emulator for use with the yaLVDC CPU emulator, and is connected
#               to yaLVDC with "virtual wires" ... i.e., via network sockets.
# Reference:    http://www.ibiblio.org/apollo/LVDC.html
# Mod history:  2023-08-13 RSB  Began adapting from yaPTC.py.

'''
Regarding how the Digital Command System (DCS) delivers commands and data to 
the LVDC, I interpret the documentation and the LVDC source code as follows.

What's supposed to happen:  The transmission from the ground is in packets that
contain either code or data, plus two bits (OM/D A and OM/D B) both having the 
same value) that indicate whether the packet contains the mode or whether it 
contains data, and two interrupt bits as well.  The LVDA is supposed to:
    1.  AND the OM/D bits together and present them to the LVDC as discrete
        input 2 (DI2), which is available to the LVDC software as "bit 22" of 
        PIO 057 (where the S is the most-significant bit, 1 the next-most,
        and so on).
    2.  Make the command or data available to the LVDC software as PIO 043.
    3.  Generate a DCS interrupt in the LVDC if the AND of the interrupt bits
        is 1.

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
                                 forAS206RAM, forAS512, forAS513
from dcsDefinitions import *

ioTypes = ["PIO", "CIO", "PRS", "INT" ]

refreshRate = 1 # Milliseconds
resizable = False
resize = 0
version = 2
showDcs = False
asciiOnly = False
abbreviateUnits = False
fontSize = 10

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

SIGN = 0o200000000
BIT6 = SIGN >> 6
BIT13 = SIGN >> 13
BIT22 = SIGN >> 22
BITS6and13 = BIT6 | BIT13
BITS7through13 = 0o177 * BIT13
BITSunused = BIT13 - 1
dcsSequenceNumber = 0
def dcsTransmit(isItCommand, sixBitValue, sequenceNumber):
    global dcsSequenceNumber
    outputBuffer = bytearray(6)
    if isItCommand:
        dcsSequenceNumber = 0
    encoded7 = ((sixBitValue & 0o77) << 1) | dcsSequenceNumber
    encoded26 = (encoded7 * BITS6and13) ^ BITS7through13
    if isItCommand:
        encoded26 |= BITSunused
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
    s.send(outputBuffer)

def dcsButtonCallback(event):
    name = event.widget["text"]
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
        mode = modes[name]
        dcsTransmit(True, mode, 0)
        return
    # Next we have various commands that do have data words, and we have to
    # encode their data into those data words in whatever manner is appropriate
    # to the command itself.
    
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

def CreateToolTip(widget, text):
    toolTip = ToolTip(widget)
    def enter(event):
        toolTip.showtip(text)
    def leave(event):
        toolTip.hidetip()
    widget.bind('<Enter>', enter)
    widget.bind('<Leave>', leave)

def normalizeUnits(text):
    if not asciiOnly:
        text = text.replace("**2", "²").replace("**-1", "⁻¹")
    if abbreviateUnits:
        text = text.replace("METERS", "M")
        text = text.replace("METER", "M")
        text = text.replace("SECONDS", "S")
        text = text.replace("SECOND", "S")
        text = text.replace("KILOGRAM", "KG")
        text = text.replace("RADIANS", "RAD")
        text = text.replace("RADIAN", "RAD")
    return text

# An event for clicking on a variable name.  It cycles through my chosen
# set of colors.
gray = "#3f3f3f"
colors = ["#000000", "#ff0000", "#00ff00", "#0000ff"]
def varClick(event):
    var = event.widget["text"].split(":")[0]
    color = event.widget["fg"]
    color = colors[(colors.index(color) + 1) % len(colors)]
    event.widget["fg"] = color

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
            label = tk.Label(text="", width=12, fg=colors[0], anchor="w")
            label.grid(row=row, column=len(rowArray), sticky=tk.W)
            label.bind('<Button-1>', varClick)
            rowArray.append(label)
            text = normalizeUnits(teld[3])
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
            if "dataValues" in dcsEntry:
                if len(dcsEntry["dataValues"]) == 0:
                    label = tk.Label(master=self.root, text="(No data)", anchor=tk.W)
                    label.grid(row=len(self.array), column=len(row), sticky=tk.W)
                    row.append(label)
                else:
                    for d in range(len(dcsEntry["dataValues"])):
                        dataValue = dcsEntry["dataValues"][d]
                        label = tk.Label(master=self.root, text=dataValue+":", anchor=tk.E)
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
                            units = normalizeUnits(dcsEntry["dataUnits"][d])
                            if units != "":
                                tooltip = tooltip + ("\nUnits:       %s" % units)
                        CreateToolTip(label, tooltip)
                        row.append(label)
                        entry = tk.Entry(master=self.root, width=12)
                        entry.grid(row=len(self.array), column=len(row), padx=8, sticky=tk.W)
                        row.append(entry)
            else:
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
    if aug in top.locations:
        row, col = top.locations[aug]
        widget = root.grid_slaves(row=row, column=col)[0]
        raw, scaled = lvdcFormatData(val, sc1, units)
        if scaled == "":
            widget["text"] = raw
        else:
            widget["text"] = scaled

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
