#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	yaPTC.py
# Purpose:	This is a very primitive PTC peripheral emulator for
#		use with the yaLVDC PTC CPU emulator, and is connected
#		to yaLVDC with "virtual wires" ... i.e., via network sockets.
#		It's not fully developed, and is just intended to help me
#		with developing and debugging yaLVDC.  But there's no reason
#		it couldn't be developed fully, if there were reason to do so.  
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2020-05-07 RSB	Began adapting from piPeripheral.py, which is
#				a skeleton program for developing peripherals
#				for the AGC or AGS CPU emulators.
#		2020-05-08 RSB	I've added a GUI, based on the standard
#				tkinter module in Python.  I've used the PAGE
#				(http://page.sourceforge.net/html/index.html)
#				tool to build it, and those are the files
#				ProcessorDisplayPanel.py and 
#				ProcessorDisplayPanel_support.py, which are
#				simply imported as a module called
#				"ProcessorDisplayPanel" at the top of this
#				file.  The sources PAGE uses to generate 
#				this code are in the guiDesign folder.
#		2020-05-10 RSB	Unfortunately, there's no way this can keep up
#				with yaLVDC in terms of speed.  It continues
#				to receive data from yaLVDC *long* after the
#				PTC program has been paused.  It may be 
#				possible to use it if the clock-rate in 
#				yaLVDC is cut way down, and I'll experiment
#				with that, because this program is nice enough
#				now that I'm not keen to reimplement it in 
#				another language and gui toolkit.
#		2020-05-11 RSB	Removed all of the "interrupt latch" 
#				processing (most of the input CIO's) and 
#				moved it all back locally to yaLVDC, because
#				the PAST software expects to read back changes
#				to the interrupt latch within one instruction
#				cycle.  I expect this will help with the
#				speed problem I complained about above as well.
#
# The parts which need to be modified from the skeleton form of the program 
# to make it peripheral-specific are the outputFromCPU() and inputsForCPU() 
# functions.
#
# To run the program in its present form, assuming you had a directory setup in 
# which all of the appropriate files could be found housed on the same computer,
# you can simply run yaLVDC and yaPTC.py from different consoles on that same 
# computer. 

from ProcessorDisplayPanel import *

ioTypes = ["PIO", "CIO", "PRS", "INT" ]
# BA8421 character set in its native encoding.  All of the unprintable
# characters are replaced by '?', which isn't a legal character anyway.
# Used only for --ptc.
BA8421 = [
	' ', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '#', '@', '?', '?', '?',
	'?', '/', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', '‡', ',', '(', '?', '?', '?',
	'-', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', '?', '$', '*', '?', '?', '?',
	'+', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'I', '?', '.', ')', '?', '?', '?'
]
refreshRate = 1 # Milliseconds
resizable = 0

# Parse command-line arguments.
import argparse
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC/yaAGS, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaLVDC, defaulting to 19653.", type=int)
cli.add_argument("--id", help="Unique ID of this peripheral (1-7), default=1.", type=int)
cli.add_argument("--resize", help="If 1 (default 0), make the window resizable.", type=int)
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

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.  This is the section to customize for specific applications.

# Callbacks for the GUI (tkinter) event loop.

ProgRegA = -1
def cPRA():
	global ProgRegA
	n = 0
	if ProcessorDisplayPanel_support.bPRAS.get():
		n |= 0o200000000
	if ProcessorDisplayPanel_support.bPRA1.get():
		n |= 0o100000000
	if ProcessorDisplayPanel_support.bPRA2.get():
		n |= 0o040000000
	if ProcessorDisplayPanel_support.bPRA3.get():
		n |= 0o020000000
	if ProcessorDisplayPanel_support.bPRA4.get():
		n |= 0o010000000
	if ProcessorDisplayPanel_support.bPRA5.get():
		n |= 0o004000000
	if ProcessorDisplayPanel_support.bPRA6.get():
		n |= 0o002000000
	if ProcessorDisplayPanel_support.bPRA7.get():
		n |= 0o001000000
	if ProcessorDisplayPanel_support.bPRA8.get():
		n |= 0o000400000
	if ProcessorDisplayPanel_support.bPRA9.get():
		n |= 0o000200000
	if ProcessorDisplayPanel_support.bPRA10.get():
		n |= 0o000100000
	if ProcessorDisplayPanel_support.bPRA11.get():
		n |= 0o000040000
	if ProcessorDisplayPanel_support.bPRA12.get():
		n |= 0o000020000
	if ProcessorDisplayPanel_support.bPRA13.get():
		n |= 0o000010000
	if ProcessorDisplayPanel_support.bPRA14.get():
		n |= 0o000004000
	if ProcessorDisplayPanel_support.bPRA15.get():
		n |= 0o000002000
	if ProcessorDisplayPanel_support.bPRA16.get():
		n |= 0o000001000
	if ProcessorDisplayPanel_support.bPRA17.get():
		n |= 0o000000400
	if ProcessorDisplayPanel_support.bPRA18.get():
		n |= 0o000000200
	if ProcessorDisplayPanel_support.bPRA19.get():
		n |= 0o000000100
	if ProcessorDisplayPanel_support.bPRA20.get():
		n |= 0o000000040
	if ProcessorDisplayPanel_support.bPRA21.get():
		n |= 0o000000020
	if ProcessorDisplayPanel_support.bPRA22.get():
		n |= 0o000000010
	if ProcessorDisplayPanel_support.bPRA23.get():
		n |= 0o000000004
	if ProcessorDisplayPanel_support.bPRA24.get():
		n |= 0o000000002
	if ProcessorDisplayPanel_support.bPRA25.get():
		n |= 0o000000001
	ProgRegA = n
ProcessorDisplayPanel_support.cPRA = cPRA
	
ProgRegB = -1
def cPRB():
	global ProgRegB
	n = 0
	if ProcessorDisplayPanel_support.bPRBS.get():
		n |= 0o200000000
	if ProcessorDisplayPanel_support.bPRB1.get():
		n |= 0o100000000
	if ProcessorDisplayPanel_support.bPRB2.get():
		n |= 0o040000000
	if ProcessorDisplayPanel_support.bPRB3.get():
		n |= 0o020000000
	if ProcessorDisplayPanel_support.bPRB4.get():
		n |= 0o010000000
	if ProcessorDisplayPanel_support.bPRB5.get():
		n |= 0o004000000
	if ProcessorDisplayPanel_support.bPRB6.get():
		n |= 0o002000000
	if ProcessorDisplayPanel_support.bPRB7.get():
		n |= 0o001000000
	if ProcessorDisplayPanel_support.bPRB8.get():
		n |= 0o000400000
	if ProcessorDisplayPanel_support.bPRB9.get():
		n |= 0o000200000
	if ProcessorDisplayPanel_support.bPRB10.get():
		n |= 0o000100000
	if ProcessorDisplayPanel_support.bPRB11.get():
		n |= 0o000040000
	if ProcessorDisplayPanel_support.bPRB12.get():
		n |= 0o000020000
	if ProcessorDisplayPanel_support.bPRB13.get():
		n |= 0o000010000
	if ProcessorDisplayPanel_support.bPRB14.get():
		n |= 0o000004000
	if ProcessorDisplayPanel_support.bPRB15.get():
		n |= 0o000002000
	if ProcessorDisplayPanel_support.bPRB16.get():
		n |= 0o000001000
	if ProcessorDisplayPanel_support.bPRB17.get():
		n |= 0o000000400
	if ProcessorDisplayPanel_support.bPRB18.get():
		n |= 0o000000200
	if ProcessorDisplayPanel_support.bPRB19.get():
		n |= 0o000000100
	if ProcessorDisplayPanel_support.bPRB20.get():
		n |= 0o000000040
	if ProcessorDisplayPanel_support.bPRB21.get():
		n |= 0o000000020
	if ProcessorDisplayPanel_support.bPRB22.get():
		n |= 0o000000010
	if ProcessorDisplayPanel_support.bPRB23.get():
		n |= 0o000000004
	if ProcessorDisplayPanel_support.bPRB24.get():
		n |= 0o000000002
	if ProcessorDisplayPanel_support.bPRB25.get():
		n |= 0o000000001
	ProgRegB = n
ProcessorDisplayPanel_support.cPRB = cPRB

# This function is automatically called periodically by the event loop to check for 
# conditions that will result in sending messages to yaLVDC that are interpreted
# as changes to bits on its input channels.  The return
# value is supposed to be a list of 4-tuples of the form
#	[ (ioType0,channel0,value0,mask0), (ioType1,channel1,value1,mask1), ...]
# and may be an empty list.  The "values" are written to the LVDC/PTC's input "channels",
# while the "masks" tell which bits of the "values" are valid.  The ioTypeN's are
# indices into ioTypes[] (see top of file) to tell which particular class of i/o
# channels is affected.  Only the PIO, CIO, and INT classes are possible for inputs
# to the CPU.
def inputsForCPU():
	#global delayCount, ioTypeCount, channelCount
	global ProgRegA, ProgRegB
	returnValue = []
	
	if ProgRegA != -1:
		n = ProgRegA
		ProgRegA = -1
		return [(1, 0o214, n, 0o377777777)]

	if ProgRegB != -1:
		n = ProgRegB
		ProgRegB = -1
		return [(1, 0o220, n, 0o377777777)]
		
	return returnValue

# GUI indicator functions.  These are implemented as canvas widgets,
# sometimes with callback functions bound to them when they're supposed
# to act like pushbuttons.  Each canvas just has two visible elements:
# a filling white rectangle (ID=1) that can be either opaque or invisible,
# and a textual caption (ID=5).
def indicatorReconfigure(event):
	width = event.width
	height = event.height
	event.widget.coords(1, 0, 0, width, height)
	event.widget.coords(2, width/2.0, height/2.0)
def indicatorInitialize(canvas, text):
	canvas.delete("all")
	canvas.create_rectangle(0, 0, 1, 1, fill="white", state = "hidden")
	canvas.create_text(1, 1, fill="white", text=text, font=("Sans", 6), justify=tk.CENTER)
	canvas.bind("<Configure>", indicatorReconfigure)
def indicatorOff(canvas):
	canvas.itemconfig(1, state = "hidden")
	canvas.itemconfig(2, fill = "white")
def indicatorOn(canvas):
	canvas.itemconfig(1, state = "normal")
	canvas.itemconfig(2, fill = "black")

# This function is called by the event loop only when yaLVDC has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program.  The ioType argument is an index into the
# ioTypes[] array (see the top of this file), giving the class of i/o ports
# to which the channel belongs.  Only the PIO, CIO, and PRS channels are applicable
# for output from the CPU to peripherals.
def outputFromCPU(ioType, channel, value):
	print("*", end="")
	
	if ioType == 0:
		# PIO
		print("\nChannel PIO-%03o = %09o" % (channel, value), end="  ")
		
	elif ioType == 1:
		# CIO
		if channel == 0o114:
			print("\nSingle step")
		elif channel == 0o120 or channel == 0o160:
			if channel == 0o120:
				destination = "Typewriter"
			else:
				destination = "Printer"
			string = ""
			shift = 20
			while shift >= 0:
				string += BA8421[(value >> shift) & 0o77]
				if channel == 0o120:
					shift = -1
				else:
					shift -= 6
			print("\n%s alphanumeric = %09o (%s)" % (destination, value, string), end="  ")
		elif channel == 0o124 or channel == 0o170:
			if channel == 0o124:
				destination = "Typewriter"
			else:
				destination = "Printer"
			string = ""
			shift = 22
			while shift >= 0:
				string += BA8421[(value >> shift) & 0o17]
				if channel == 0o124:
					shift = -1
				else:
					shift -= 4
			print("\n%s decimal = %09o (%s)" % (destination, value, string), end="  ")
		elif channel == 0o130 or channel == 0o164:
			if channel == 0o130:
				destination = "Typewriter"
			else:
				destination = "Printer"
			string = ""
			shift = 23
			while shift >= 0:
				character = BA8421[(value >> shift) & 0o07]
				if character == " ":
					character = "0"
				string += character
				if channel == 0o130:
					shift = -1
				else:
					shift -= 3
			print("\n%s octal = %09o (%s)" % (destination, value, string), end="  ")
		elif channel == 0o134:
			if value == 0o200000000:
				string = "space"
			elif value == 0o100000000:
				string = "black ribbon"
			elif value == 0o040000000:
				string = "red ribbon"
			elif value == 0o020000000:
				string = "index"
			elif value == 0o010000000:
				string = "return"
			elif value == 0o004000000:
				string = "tab"
			else:
				string = "illegal"
			print("\nTypewriter control = %09o (%s)" % (value, string), end="  ")
		elif channel == 0o140:
			print("\nX plot = %09o" % value, end="  ")
		elif channel == 0o144:
			print("\nY plot = %09o" % value, end="  ")
		elif channel == 0o150:
			print("\nZ plot = %09o" % value, end="  ")
		elif channel == 0o204:
			# Turn indicator lamps on or off.  I think this is actually
			# the full functionality of CIO-204
			if value & 0o1:
				indicatorOn(top.P1)
			else:
				indicatorOff(top.P1)
			if value & 0o2:
				indicatorOn(top.P2)
			else:
				indicatorOff(top.P2)
			if value & 0o4:
				indicatorOn(top.P4)
			else:
				indicatorOff(top.P4)
			if value & 0o10:
				indicatorOn(top.P10)
			else:
				indicatorOff(top.P10)
			if value & 0o20:
				indicatorOn(top.P20)
			else:
				indicatorOff(top.P20)
			if value & 0o40:
				indicatorOn(top.P40)
			else:
				indicatorOff(top.P40)
			return
		elif channel == 0o210:
			# All I'm doing here (CIO-210) is manipulating indicator lamps,
			# but the discretes additionally have some other functionality
			# in terms of latching signals or something which is
			# TBD.  ***FIXME***
			if value & 0o1:
				indicatorOn(top.D1)
			else:
				indicatorOff(top.D1)
			if value & 0o2:
				indicatorOn(top.D2)
			else:
				indicatorOff(top.D2)
			if value & 0o4:
				indicatorOn(top.D3)
			else:
				indicatorOff(top.D3)
			if value & 0o10:
				indicatorOn(top.D4)
			else:
				indicatorOff(top.D4)
			if value & 0o20:
				indicatorOn(top.D5)
			else:
				indicatorOff(top.D5)
			if value & 0o40:
				indicatorOn(top.D6)
			else:
				indicatorOff(top.D6)
			return
		elif channel == 0o240:
			indicatorOn(top.PROG_ERR)
		else:
			print("\nChannel CIO-%03o = %09o" % (channel, value), end="  ")
		
	elif ioType == 2:
		if value == 0o77:
			print("\nChannel PRS = %09o (group mark)" % value, end= "  ")
		else:
			shift = 18
			string = ""
			while shift >= 0:
				string += BA8421[(value >> shift) & 0o077]
				shift -= 6
			print("\nChannel PRS = %09o (%s)" % (value, string), end="  ")
	else:
		print("\nUnimplemented type %d, channel %03o, value %09o" % (ioType, channel, value), end="  ")
	
	return

def pressedPROG_ERR(event):
	indicatorOff(top.PROG_ERR)

###################################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

import time
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

def connectToAGC():
	import sys
	count = 0
	sys.stderr.write("Connecting to LVDC/PTC emulator at %s:%d\n" % (TCP_IP, TCP_PORT))
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			sys.stderr.write("Connected.\n")
			break
		except socket.error as msg:
			sys.stderr.write(str(msg) + "\n")
			count += 1
			if count >= 10:
				sys.stderr.write("Too many retries ...\n")
				time.sleep(3)
				sys.exit(1)
			time.sleep(1)

connectToAGC()

###################################################################################
# Event loop.  Just check periodically for output from yaLVDC (in which case the
# user-defined callback function outputFromCPU is executed) or data in the 
# user-defined function inputsForCPU (in which case a message is sent to yaLVDC).
# But this section has no target-specific code, and shouldn't need to be modified
# unless there are bugs.

# Given a 4-tuple (ioType,channel,value,mask), creates packet data and sends it to yaLVDC.
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

# Buffer for a packet received from yaLVDC.
packetSize = 6
inputBuffer = bytearray(packetSize)
leftToRead = packetSize
view = memoryview(inputBuffer)

didSomething = False
def mainLoopIteration():
	global didSomething, inputBuffer, leftToRead, view

	# Check for packet data received from yaLVDC and process it.
	# While these packets are always exactly 5
	# bytes long, since the socket is non-blocking, any individual read
	# operation may yield less bytes than that, so the buffer may accumulate data
	# over time until it fills.	
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
					print("Illegal packet: %03o %03o %03o %03o %03o %03o" % tuple(inputBuffer))
				for i in range(1,packetSize):
					if (inputBuffer[i] & 0x80) == 0x80 and inputBuffer[i] != 0xFF:
						j = 0
						for k in range(i,6):
							inputBuffer[j] = inputBuffer[k]
							j += 1
						view = view[j:]
						leftToRead = packetSize - j
			else:
				ioType = (inputBuffer[0] >> 3) & 7
				source = inputBuffer[0] & 7
				channel = ((inputBuffer[2] << 2) & 0x180) | (inputBuffer[1] & 0x7F)
				value = (inputBuffer[2] & 0x1F) << 21
				value |= (inputBuffer[3] & 0x7F) << 14
				value |= (inputBuffer[4] & 0x7F) << 7
				value |= inputBuffer[5] & 0x7F
				outputFromCPU(ioType, channel, value)
			didSomething = True
	
	# Check for locally-generated data for which we must generate messages
	# to yaLVDC over the socket.  In theory, the externalData list could contain
	# any number of channel operations, but in practice it will probably contain
	# only 0 or 1 operations.
	externalData = inputsForCPU()
	for i in range(0, len(externalData)):
		packetize(externalData[i])
		didSomething = True
	
	root.after(refreshRate, mainLoopIteration)		
	
while False:
	mainLoopIteration()

root = tk.Tk()

ProcessorDisplayPanel_support.set_Tk_var()
top = topProcessorDisplayPanel (root)
ProcessorDisplayPanel_support.init(root, top)
# Indicators for PDP DATA area:
indicatorInitialize(top.pdp1, "1")
indicatorInitialize(top.pdp2, "2")
indicatorInitialize(top.pdp3, "3")
indicatorInitialize(top.pdp4, "4")
indicatorInitialize(top.pdp5, "5")
indicatorInitialize(top.pdp6, "6")
indicatorInitialize(top.pdp7, "7")
indicatorInitialize(top.pdp8, "8")
indicatorInitialize(top.pdp9, "9")
indicatorInitialize(top.pdp10, "10")
indicatorInitialize(top.pdp11, "11")
indicatorInitialize(top.pdp12, "12")
indicatorInitialize(top.pdp13, "13")
indicatorInitialize(top.pdpERROR_RESET, "ERROR\nRESET")
indicatorInitialize(top.pdpPARITY_ERROR, "PAR ERR")
indicatorInitialize(top.pdpERROR_HOLD, "E HOLD")
indicatorInitialize(top.pdpMEM_BUFFER_PARITY, "MEM\nBUFFER\nPARITY")
indicatorInitialize(top.pdpMEM_BUFFER_REG, "MEM\nBUFFER\nREG")
indicatorInitialize(top.pdpTRANS_REG, "TRANS\nREG")
indicatorInitialize(top.pdpOP4, "OP4")
indicatorInitialize(top.pdpOP3, "OP3")
indicatorInitialize(top.pdpOP2, "OP2")
indicatorInitialize(top.pdpOP1, "OP1")
indicatorInitialize(top.pdpA1, "A1")
indicatorInitialize(top.pdpA2, "A2")
indicatorInitialize(top.pdpA3, "A3")
indicatorInitialize(top.pdpA4, "A4")
indicatorInitialize(top.pdpA5, "A5")
indicatorInitialize(top.pdpA6, "A6")
indicatorInitialize(top.pdpA7, "A7")
indicatorInitialize(top.pdpA8, "A8")
indicatorInitialize(top.pdpA9, "A9")
indicatorInitialize(top.pdpMEM_ADD_REG, "MEM\nADD\nREG")
indicatorInitialize(top.pdpHOPSAVE_REG, "HOP\nSAVE\nREG")
indicatorInitialize(top.pdpSYL0, "0")
indicatorInitialize(top.pdpSYL1, "0")
indicatorInitialize(top.pdpIS4, "IS4")
indicatorInitialize(top.pdpIS3, "IS3")
indicatorInitialize(top.pdpIS2, "IS2")
indicatorInitialize(top.pdpIS1, "IS1")
indicatorInitialize(top.pdpDS4, "DS4")
indicatorInitialize(top.pdpDS3, "DS3")
indicatorInitialize(top.pdpDS2, "DS2")
indicatorInitialize(top.pdpDS1, "DS1")
indicatorInitialize(top.pdpIM0, "IM0")
indicatorInitialize(top.pdpIM1, "IM1")
indicatorInitialize(top.pdpDM0, "DM0")
indicatorInitialize(top.pdpDM1, "DM1")
# Indicators for PDP INTERRUPTS area:
indicatorInitialize(top.iI1, "I1")
indicatorInitialize(top.iI2, "I2")
indicatorInitialize(top.iI3, "I3")
indicatorInitialize(top.iI4, "I4")
indicatorInitialize(top.iI5, "I5")
indicatorInitialize(top.iI6, "I6")
indicatorInitialize(top.iI7, "I7")
indicatorInitialize(top.iI8, "I8")
indicatorInitialize(top.iI9, "I9")
indicatorInitialize(top.iI10, "I10")
indicatorInitialize(top.iI11, "I11")
indicatorInitialize(top.iI12, "I12")
indicatorInitialize(top.iI13, "I13")
indicatorInitialize(top.iI14, "I14")
indicatorInitialize(top.iI15, "I15")
indicatorInitialize(top.iI16, "I16")
indicatorInitialize(top.iB1, "B1")
indicatorInitialize(top.iB2, "B2")
indicatorInitialize(top.iB3, "B3")
indicatorInitialize(top.iB4, "B4")
indicatorInitialize(top.iB5, "B5")
indicatorInitialize(top.iB6, "B6")
indicatorInitialize(top.iB7, "B7")
indicatorInitialize(top.iB8, "B8")
indicatorInitialize(top.iB9, "B9")
indicatorInitialize(top.iB10, "B10")
indicatorInitialize(top.iB11, "B11")
indicatorInitialize(top.iB12, "B12")
indicatorInitialize(top.iB13, "B13")
indicatorInitialize(top.iB14, "B14")
indicatorInitialize(top.iB15, "B15")
indicatorInitialize(top.iB16, "B16")
indicatorInitialize(top.INHIBIT_CTRL, "INHIBIT\nCTRL")
indicatorInitialize(top.PROG_ERR, "PROG ERR")
indicatorInitialize(top.SYNC_ERR, "SYNC ERR")
# Indicators for PDP PROGRAM CONTROL area:
indicatorInitialize(top.CST, "CST")
indicatorInitialize(top.MAN_CST, "MAN CST")
indicatorInitialize(top.ADVANCE, "ADVANCE")
indicatorInitialize(top.P1, "P1")
indicatorInitialize(top.P2, "P2")
indicatorInitialize(top.P4, "P4")
indicatorInitialize(top.P10, "P10")
indicatorInitialize(top.P20, "P20")
indicatorInitialize(top.P40, "P40")
indicatorInitialize(top.D1, "D1")
indicatorInitialize(top.D2, "D2")
indicatorInitialize(top.D3, "D3")
indicatorInitialize(top.D4, "D4")
indicatorInitialize(top.D5, "D5")
indicatorInitialize(top.D6, "D6")
indicatorInitialize(top.RESET_MACHINE, "RESET\nMACHINE")
indicatorInitialize(top.HALT, "HALT")
# Indicators for MLDD INSTRUCTION ADDRESS area:
indicatorInitialize(top.iaComputerM0, "0")
indicatorInitialize(top.iaComputerM1, "1")
indicatorInitialize(top.iaComputerSYL0, "0")
indicatorInitialize(top.iaComputerSYL1, "1")
indicatorInitialize(top.iaComputerIS4, "IS4")
indicatorInitialize(top.iaComputerIS3, "IS3")
indicatorInitialize(top.iaComputerIS2, "IS2")
indicatorInitialize(top.iaComputerIS1, "IS1")
indicatorInitialize(top.iaComputerA8, "A8")
indicatorInitialize(top.iaComputerA7, "A7")
indicatorInitialize(top.iaComputerA6, "A6")
indicatorInitialize(top.iaComputerA5, "A5")
indicatorInitialize(top.iaComputerA4, "A4")
indicatorInitialize(top.iaComputerA3, "A3")
indicatorInitialize(top.iaComputerA2, "A2")
indicatorInitialize(top.iaComputerA1, "A1")
indicatorInitialize(top.iaCommandM0, "0")
indicatorInitialize(top.iaCommandM1, "1")
indicatorInitialize(top.iaCommandSYL0, "0")
indicatorInitialize(top.iaCommandSYL1, "1")
indicatorInitialize(top.iaCommandIS4, "IS4")
indicatorInitialize(top.iaCommandIS3, "IS3")
indicatorInitialize(top.iaCommandIS2, "IS2")
indicatorInitialize(top.iaCommandIS1, "IS1")
indicatorInitialize(top.iaCommandA8, "A8")
indicatorInitialize(top.iaCommandA7, "A7")
indicatorInitialize(top.iaCommandA6, "A6")
indicatorInitialize(top.iaCommandA5, "A5")
indicatorInitialize(top.iaCommandA4, "A4")
indicatorInitialize(top.iaCommandA3, "A3")
indicatorInitialize(top.iaCommandA2, "A2")
indicatorInitialize(top.iaCommandA1, "A1")
# Indicators for MLDD DATA ADDRESS area:
indicatorInitialize(top.daPARITY_BIT, "BR")
indicatorInitialize(top.daComputerDS4, "DS4")
indicatorInitialize(top.daComputerDS3, "DS3")
indicatorInitialize(top.daComputerDS2, "DS2")
indicatorInitialize(top.daComputerDS1, "DS1")
indicatorInitialize(top.daComputerM0, "0")
indicatorInitialize(top.daComputerM1, "1")
indicatorInitialize(top.daComputerOP4, "OP4")
indicatorInitialize(top.daComputerOP3, "OP3")
indicatorInitialize(top.daComputerOP2, "OP2")
indicatorInitialize(top.daComputerOP1, "OP1")
indicatorInitialize(top.daComputerOA9, "OA9")
indicatorInitialize(top.daComputerOA8, "OA8")
indicatorInitialize(top.daComputerOA7, "OA7")
indicatorInitialize(top.daComputerOA6, "OA6")
indicatorInitialize(top.daComputerOA5, "OA5")
indicatorInitialize(top.daComputerOA4, "OA4")
indicatorInitialize(top.daComputerOA3, "OA3")
indicatorInitialize(top.daComputerOA2, "OA2")
indicatorInitialize(top.daComputerOA1, "OA1")
indicatorInitialize(top.daCommandDS4, "DS4")
indicatorInitialize(top.daCommandDS3, "DS3")
indicatorInitialize(top.daCommandDS2, "DS2")
indicatorInitialize(top.daCommandDS1, "DS1")
indicatorInitialize(top.daCommandM0, "0")
indicatorInitialize(top.daCommandM1, "1")
indicatorInitialize(top.daCommandOP4, "OP4")
indicatorInitialize(top.daCommandOP3, "OP3")
indicatorInitialize(top.daCommandOP2, "OP2")
indicatorInitialize(top.daCommandOP1, "OP1")
indicatorInitialize(top.daCommandOA9, "OA9")
indicatorInitialize(top.daCommandOA8, "OA8")
indicatorInitialize(top.daCommandOA7, "OA7")
indicatorInitialize(top.daCommandOA6, "OA6")
indicatorInitialize(top.daCommandOA5, "OA5")
indicatorInitialize(top.daCommandOA4, "OA4")
indicatorInitialize(top.daCommandOA3, "OA3")
indicatorInitialize(top.daCommandOA2, "OA2")
indicatorInitialize(top.daCommandOA1, "OA1")
# Indicators for MLDD DATA area:
indicatorInitialize(top.mlddLAMP_TEST, "LAMP\nTEST")
indicatorInitialize(top.mlddPARITY_BIT, "PARITY\nBIT")
indicatorInitialize(top.mlddComputerBR0, "B\nR")
indicatorInitialize(top.mlddComputerBR1, "B\nR")
indicatorInitialize(top.mlddComputerSIGN, "S")
indicatorInitialize(top.mlddComputer1, "1")
indicatorInitialize(top.mlddComputer2, "2")
indicatorInitialize(top.mlddComputer3, "3")
indicatorInitialize(top.mlddComputer4, "4")
indicatorInitialize(top.mlddComputer5, "5")
indicatorInitialize(top.mlddComputer6, "6")
indicatorInitialize(top.mlddComputer7, "7")
indicatorInitialize(top.mlddComputer8, "8")
indicatorInitialize(top.mlddComputer9, "9")
indicatorInitialize(top.mlddComputer10, "10")
indicatorInitialize(top.mlddComputer11, "11")
indicatorInitialize(top.mlddComputer12, "12")
indicatorInitialize(top.mlddComputer13, "13")
indicatorInitialize(top.mlddComputer14, "14")
indicatorInitialize(top.mlddComputer15, "15")
indicatorInitialize(top.mlddComputer16, "16")
indicatorInitialize(top.mlddComputer17, "17")
indicatorInitialize(top.mlddComputer18, "18")
indicatorInitialize(top.mlddComputer19, "19")
indicatorInitialize(top.mlddComputer20, "20")
indicatorInitialize(top.mlddComputer21, "21")
indicatorInitialize(top.mlddComputer22, "22")
indicatorInitialize(top.mlddComputer23, "23")
indicatorInitialize(top.mlddComputer24, "24")
indicatorInitialize(top.mlddComputer25, "25")
indicatorInitialize(top.mlddCommandSYL0, "S\nY\n0")
indicatorInitialize(top.mlddCommandSYL1, "S\nY\n1")
indicatorInitialize(top.mlddCommandSIGN, "S")
indicatorInitialize(top.mlddCommand1, "1")
indicatorInitialize(top.mlddCommand2, "2")
indicatorInitialize(top.mlddCommand3, "3")
indicatorInitialize(top.mlddCommand4, "4")
indicatorInitialize(top.mlddCommand5, "5")
indicatorInitialize(top.mlddCommand6, "6")
indicatorInitialize(top.mlddCommand7, "7")
indicatorInitialize(top.mlddCommand8, "8")
indicatorInitialize(top.mlddCommand9, "9")
indicatorInitialize(top.mlddCommand10, "10")
indicatorInitialize(top.mlddCommand11, "11")
indicatorInitialize(top.mlddCommand12, "12")
indicatorInitialize(top.mlddCommand13, "13")
indicatorInitialize(top.mlddCommand14, "14")
indicatorInitialize(top.mlddCommand15, "15")
indicatorInitialize(top.mlddCommand16, "16")
indicatorInitialize(top.mlddCommand17, "17")
indicatorInitialize(top.mlddCommand18, "18")
indicatorInitialize(top.mlddCommand19, "19")
indicatorInitialize(top.mlddCommand20, "20")
indicatorInitialize(top.mlddCommand21, "21")
indicatorInitialize(top.mlddCommand22, "22")
indicatorInitialize(top.mlddCommand23, "23")
indicatorInitialize(top.mlddCommand24, "24")
indicatorInitialize(top.mlddCommand25, "25")
# Indicators for MLDD DISPLAY MODE area:
indicatorInitialize(top.acDATA, "DATA")
indicatorInitialize(top.acINS, "INS")
# Indicators for MLDD ERRORS area:
indicatorInitialize(top.PARITY_SERIAL, "SER")
indicatorInitialize(top.TRS, "TRS")
indicatorInitialize(top.A13, "A13")
indicatorInitialize(top.SERIAL, "SER")
indicatorInitialize(top.HOPC1, "HOPC")
indicatorInitialize(top.SSMSC, "SMSC")
indicatorInitialize(top.SSMBR, "SMBR")
indicatorInitialize(top.OAC, "OAC")
indicatorInitialize(top.BR14, "BR14")
indicatorInitialize(top.ERROR_RESET, "ERROR\nRESET")
indicatorInitialize(top.INVERT_ERROR, "INVERT\nERROR")
# Indicators for MLDD MEMORY LOADER area:
indicatorInitialize(top.mlREPEAT, "REPEAT")
indicatorInitialize(top.mlREPEAT_INVERSE, "/REPEAT")
indicatorInitialize(top.mlADDRESS_CMPTR, "ADDRESS\nCOMPTR")
indicatorInitialize(top.mlCOMPTR_DISPLAY_RESET, "COMPTR\nDISPLAY\nRESET")
indicatorInitialize(top.mlCOMMAND_DISPLAY_RESET, "COMMAND\nDISPLAY\nRESET")
# Indicators for CE ACCUMULATOR area:
indicatorInitialize(top.A_S, "A/S")
indicatorInitialize(top.DLA2, "DLA2")
indicatorInitialize(top.DLA3, "DLA3")
indicatorInitialize(top.DLA4, "DLA4")
indicatorInitialize(top.DLA5, "DLA5")
indicatorInitialize(top.DLA6, "DLA6")
indicatorInitialize(top.DLA7, "DLA7")
indicatorInitialize(top.DLA8, "DLA8")
indicatorInitialize(top.DLA9, "DLA9")
indicatorInitialize(top.DLA10, "DLA10")
indicatorInitialize(top.DLA11, "DLA11")
indicatorInitialize(top.DLA12, "DLA12")
indicatorInitialize(top.DLA13, "DLA13")
indicatorInitialize(top.DLA14, "DLA14")
indicatorInitialize(top.DLA15, "DLA15")
indicatorInitialize(top.DLA16, "DLA16")
indicatorInitialize(top.DLA17, "DLA17")
indicatorInitialize(top.DLA18, "DLA18")
indicatorInitialize(top.DLA19, "DLA19")
indicatorInitialize(top.DLA20, "DLA20")
indicatorInitialize(top.DLA21, "DLA21")
indicatorInitialize(top.DLA22, "DLA22")
indicatorInitialize(top.DLA23, "DLA23")
indicatorInitialize(top.DLA24, "DLA24")
indicatorInitialize(top.DLA25, "DLA25")
indicatorInitialize(top.DLA26, "DLA26")
indicatorInitialize(top.DLA27, "DLA27")
indicatorInitialize(top.DLA28, "DLA28")
indicatorInitialize(top.DLA29, "DLA29")
indicatorInitialize(top.DLA30, "DLA30")
indicatorInitialize(top.ACC0, "ACC0")
indicatorInitialize(top.ACC1, "ACC1")
indicatorInitialize(top.DLB1, "DLB1")
indicatorInitialize(top.DLB2, "DLB2")
indicatorInitialize(top.DLB3, "DLB3")
indicatorInitialize(top.DLB4, "DLB4")
indicatorInitialize(top.DLB5, "DLB5")
indicatorInitialize(top.DLB6, "DLB6")
indicatorInitialize(top.DLB7, "DLB7")
indicatorInitialize(top.DLB8, "DLB8")
indicatorInitialize(top.DLB9, "DLB9")
indicatorInitialize(top.DLB10, "DLB10")
indicatorInitialize(top.DLB11, "DLB11")
indicatorInitialize(top.DLB12, "DLB12")
indicatorInitialize(top.DLB13, "DLB13")
indicatorInitialize(top.DLB14, "DLB14")
indicatorInitialize(top.DLB15, "DLB15")
indicatorInitialize(top.DLB16, "DLB16")
indicatorInitialize(top.DLB17, "DLB17")
indicatorInitialize(top.DLB18, "DLB18")
indicatorInitialize(top.DLB19, "DLB19")
indicatorInitialize(top.DLB20, "DLB20")
indicatorInitialize(top.DLB21, "DLB21")
indicatorInitialize(top.AI0, "AI0")
indicatorInitialize(top.AI1, "AI1")
indicatorInitialize(top.AI2, "AI2")
indicatorInitialize(top.AI3, "AI3")
indicatorInitialize(top.AI4, "AI4")
indicatorInitialize(top.ACC_DISPLAY_ENABLE, "ACC\nDISPLAY\nENABLE")
# Indicators for CE MEMORY BUFFER REGISTER area:
indicatorInitialize(top.mbrBIT1, "BIT1")
indicatorInitialize(top.mbrBIT2, "BIT2")
indicatorInitialize(top.mbrBIT3, "BIT3")
indicatorInitialize(top.mbrBIT4, "BIT4")
indicatorInitialize(top.mbrBIT5, "BIT5")
indicatorInitialize(top.mbrBIT6, "BIT6")
indicatorInitialize(top.mbrBIT7, "BIT7")
indicatorInitialize(top.mbrBIT8, "BIT8")
indicatorInitialize(top.mbrBIT9, "BIT9")
indicatorInitialize(top.mbrBIT10, "BIT10")
indicatorInitialize(top.mbrBIT11, "BIT11")
indicatorInitialize(top.mbrBIT12, "BIT12")
indicatorInitialize(top.mbrBIT13, "BIT13")
indicatorInitialize(top.mbrBIT14, "BIT14")
indicatorInitialize(top.mbrMBR1, "MB1")
indicatorInitialize(top.mbrMBR2, "MB2")
indicatorInitialize(top.mbrMBR3, "MB3")
indicatorInitialize(top.mbrMBR4, "MB4")
indicatorInitialize(top.mbrMBR5, "MB5")
indicatorInitialize(top.mbrMBR6, "MB6")
indicatorInitialize(top.mbrMBR7, "MB7")
indicatorInitialize(top.mbrMBR8, "MB8")
indicatorInitialize(top.mbrMBR9, "MB9")
indicatorInitialize(top.mbrMBR10, "MB10")
indicatorInitialize(top.mbrMBR11, "MB11")
indicatorInitialize(top.mbrMBR12, "MB12")
indicatorInitialize(top.mbrMBR13, "MB13")
indicatorInitialize(top.mbrODD_PARITY, "ODD PAR")
indicatorInitialize(top.mbrLOAD, "LOAD")
indicatorInitialize(top.mbrLAMP_TEST, "LAMP\nTEST")
# Callback bindings for indicators which are also pushbuttons.
top.PROG_ERR.bind("<Button-1>", pressedPROG_ERR)

root.resizable(resize, resize)
root.after(refreshRate, mainLoopIteration)
root.mainloop()
