#!/usr/bin/env python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	yaPTC.py
# Purpose:		This is an LVDC telemetry and Digital Command System (DCS) 
#				emulator for use with the yaLVDC CPU emulator, and is connected
#				to yaLVDC with "virtual wires" ... i.e., via network sockets.
# Reference:	http://www.ibiblio.org/apollo/LVDC.html
# Mod history:	2023-08-13 RSB	Began adapting from yaPTC.py.

import sys
import argparse
import time
import socket
try:
  import Tkinter as tk
except ImportError:
  import tkinter as tk
try:
  import ttk
  py3 = False
except ImportError:
  import tkinter.ttk as ttk
  py3 = True
from lvdcTelemetryDecoder import lvdcFormatData, lvdcModeReset, \
								 lvdcSetVersion, lvdcTelemetryDecoder, \
								 forAS206RAM, forAS512, forAS513

ioTypes = ["PIO", "CIO", "PRS", "INT" ]

refreshRate = 1 # Milliseconds
resizable = 0
version = 2

# Parse command-line arguments.
cli = argparse.ArgumentParser()
cli.add_argument("--host", \
				 help="Host address of yaLVDC, defaulting to localhost.")
cli.add_argument("--port", \
				 help="Port for yaLVDC, defaulting to 19653.", type=int)
cli.add_argument("--id", \
				 help="Unique ID of this peripheral (1-7), default=1.", \
				 type=int)
cli.add_argument("--resize", \
				 help="If 1 (default 0), make the window resizable.", \
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

if args.resize:
	resize = args.resize
	if resize != 0:
		resize = 1
else:
	resize = 0

if args.version:
	version = args.version
if version == 1:
	forMission = forAS206RAM
elif version == 2:
	forMission = forAS512
elif version == 3:
	forMission = forAS513
else:
	print("Unrecognized LVDC version (%d)." % version)
	sys.exit(1)

lvdcSetVersion(version)

class mccPanel:
    def __init__(self, top=None):
	    '''This class configures and populates the toplevel window.
	       top is the toplevel containing window.'''
	    _bgcolor = '#d9d9d9'  # X11 color: 'gray85'
	    _fgcolor = '#000000'  # X11 color: 'black'
	    _compcolor = '#d9d9d9' # X11 color: 'gray85'
	    _ana1color = '#d9d9d9' # X11 color: 'gray85'
	    _ana2color = '#ececec' # Closest X11 color: 'gray92'
	    #font = "-family {DejaVu Sans Mono} -size 12"
	    font = "TkFixedFont"
	    self.style = ttk.Style()
	    if sys.platform == "win32":
	      self.style.theme_use('winnative')
	    self.style.configure('.',background=_bgcolor)
	    self.style.configure('.',foreground=_fgcolor)
	    self.style.configure('.',font=font)
	    self.style.map('.',background=
	      [('selected', _compcolor), ('active',_ana2color)])
	
	    #top.geometry("1311x729+3241+107")
	    #top.minsize(1, 1)
	    #top.maxsize(5105, 1170)
	    #top.resizable(1, 0)
	    top.title("LVDC Telemetry and Digital Command System (DCS)")
	    top.configure(highlightcolor="black")
	    
	    numPIOs = len(forMission)
	    self.numCols = 5
	    self.numRows = (numPIOs + self.numCols - 1) // self.numCols
	    row = 0
	    col = 0
	    self.array = []
	    self.locations = {}
	    for pio in sorted(forMission):
	    	teld = forMission[pio]
	    	if col == 0:
	    		rowArray = []
	    		self.array.append(row)
	    	rowArray.append(tk.Label(text=" "+teld[0]+": ", anchor="e")\
								.grid(row=row, column=col, sticky=tk.W))
	    	col += 1
	    	rowArray.append(tk.Label(text="", width=12, anchor="w")\
								.grid(row=row, column=col, sticky=tk.W))
	    	self.locations[pio] = (row, col)
	    	col += 1
	    	rowArray.append(tk.Label(text=teld[3]+" ", anchor="w")\
								.grid(row=row, column=col, sticky=tk.W))
	    	col += 1
	    	if col >= 4 * self.numCols - 1:
	    		row += 1
	    		col = 0
	    	else:
	    		rowArray.append(tk.ttk.Separator(orient=tk.VERTICAL)\
	    						.grid(row=row, column=col, rowspan=1, sticky=tk.NS))
	    		col += 1
	    	
	    	
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
			if count >= 10:
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
top = mccPanel(root)


root.resizable(resize, resize)
root.after(refreshRate, mainLoopIteration)
root.mainloop()
