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

# Parse command-line arguments.
import argparse
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC/yaAGS, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaLVDC, defaulting to 19653.", type=int)
cli.add_argument("--id", help="Unique ID of this peripheral (1-7), default=1.", type=int)
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

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.  This is the section to customize for specific applications.

# These functions are called by the GUI event loop when various events occur.
ProgRegA = -1
def cPRA():
	global ProgRegA
	n = 0
	if ProcessorDisplayPanel_support.bPRAS:
		n |= 0o200000000
	if ProcessorDisplayPanel_support.bPRA1:
		n |= 0o100000000
	if ProcessorDisplayPanel_support.bPRA2:
		n |= 0o040000000
	if ProcessorDisplayPanel_support.bPRA3:
		n |= 0o020000000
	if ProcessorDisplayPanel_support.bPRA4:
		n |= 0o010000000
	if ProcessorDisplayPanel_support.bPRA5:
		n |= 0o004000000
	if ProcessorDisplayPanel_support.bPRA6:
		n |= 0o002000000
	if ProcessorDisplayPanel_support.bPRA7:
		n |= 0o001000000
	if ProcessorDisplayPanel_support.bPRA8:
		n |= 0o000400000
	if ProcessorDisplayPanel_support.bPRA9:
		n |= 0o000200000
	if ProcessorDisplayPanel_support.bPRA10:
		n |= 0o000100000
	if ProcessorDisplayPanel_support.bPRA11:
		n |= 0o000040000
	if ProcessorDisplayPanel_support.bPRA12:
		n |= 0o000020000
	if ProcessorDisplayPanel_support.bPRA13:
		n |= 0o000010000
	if ProcessorDisplayPanel_support.bPRA14:
		n |= 0o000004000
	if ProcessorDisplayPanel_support.bPRA15:
		n |= 0o000002000
	if ProcessorDisplayPanel_support.bPRA16:
		n |= 0o000001000
	if ProcessorDisplayPanel_support.bPRA17:
		n |= 0o000000400
	if ProcessorDisplayPanel_support.bPRA18:
		n |= 0o000000200
	if ProcessorDisplayPanel_support.bPRA19:
		n |= 0o000000100
	if ProcessorDisplayPanel_support.bPRA20:
		n |= 0o000000040
	if ProcessorDisplayPanel_support.bPRA21:
		n |= 0o000000020
	if ProcessorDisplayPanel_support.bPRA22:
		n |= 0o000000010
	if ProcessorDisplayPanel_support.bPRA23:
		n |= 0o000000004
	if ProcessorDisplayPanel_support.bPRA24:
		n |= 0o000000002
	if ProcessorDisplayPanel_support.bPRA25:
		n |= 0o000000001
	ProgRegA = n
ProgRegB = -1
def cPRB():
	global ProgRegB
	n = 0
	if ProcessorDisplayPanel_support.bPRBS:
		n |= 0o200000000
	if ProcessorDisplayPanel_support.bPRB1:
		n |= 0o100000000
	if ProcessorDisplayPanel_support.bPRB2:
		n |= 0o040000000
	if ProcessorDisplayPanel_support.bPRB3:
		n |= 0o020000000
	if ProcessorDisplayPanel_support.bPRB4:
		n |= 0o010000000
	if ProcessorDisplayPanel_support.bPRB5:
		n |= 0o004000000
	if ProcessorDisplayPanel_support.bPRB6:
		n |= 0o002000000
	if ProcessorDisplayPanel_support.bPRB7:
		n |= 0o001000000
	if ProcessorDisplayPanel_support.bPRB8:
		n |= 0o000400000
	if ProcessorDisplayPanel_support.bPRB9:
		n |= 0o000200000
	if ProcessorDisplayPanel_support.bPRB10:
		n |= 0o000100000
	if ProcessorDisplayPanel_support.bPRB11:
		n |= 0o000040000
	if ProcessorDisplayPanel_support.bPRB12:
		n |= 0o000020000
	if ProcessorDisplayPanel_support.bPRB13:
		n |= 0o000010000
	if ProcessorDisplayPanel_support.bPRB14:
		n |= 0o000004000
	if ProcessorDisplayPanel_support.bPRB15:
		n |= 0o000002000
	if ProcessorDisplayPanel_support.bPRB16:
		n |= 0o000001000
	if ProcessorDisplayPanel_support.bPRB17:
		n |= 0o000000400
	if ProcessorDisplayPanel_support.bPRB18:
		n |= 0o000000200
	if ProcessorDisplayPanel_support.bPRB19:
		n |= 0o000000100
	if ProcessorDisplayPanel_support.bPRB20:
		n |= 0o000000040
	if ProcessorDisplayPanel_support.bPRB21:
		n |= 0o000000020
	if ProcessorDisplayPanel_support.bPRB22:
		n |= 0o000000010
	if ProcessorDisplayPanel_support.bPRB23:
		n |= 0o000000004
	if ProcessorDisplayPanel_support.bPRB24:
		n |= 0o000000002
	if ProcessorDisplayPanel_support.bPRB25:
		n |= 0o000000001
	ProgRegB = n

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
#delayCount = 0
#ioTypeCount = 0
#channelCount = 0
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
	
	if False:
		# This is just a little demo function to show that the communication
		# with yaLVDC, the protocol, and the parsing are okay.
		if delayCount >= 100:
			delayCount = 0
			if ioTypeCount == 0 and channelCount <= 0o377:
				returnValue = [(ioTypeCount, channelCount, 0o252525252 >> (channelCount & 1), 0o3777777777)]
				channelCount += 1
				if channelCount > 0o377:
					channelCount = 0
					ioTypeCount += 1
			elif ioTypeCount == 1 and channelCount <= 0o777:
				returnValue = [(ioTypeCount, channelCount, 0o125252525 << (channelCount & 1), 0o3777777777)]
				channelCount += 1
				if channelCount > 0o777:
					channelCount = 0
					ioTypeCount += 1
				
		else:
			delayCount += 1
	return returnValue

# This function is called by the event loop only when yaLVDC has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program.  The ioType argument is an index into the
# ioTypes[] array (see the top of this file), giving the class of i/o ports
# to which the channel belongs.  Only the PIO, CIO, and PRS channels are appicable
# for output from the CPU to peripherals.
def outputFromCPU(ioType, channel, value):
	
	# Demo
	if ioType == 0:
		print("Channel PIO-%03o = %09o" % (channel, value))
	elif ioType == 1:
		print("Channel CIO-%03o = %09o" % (channel, value))
	elif ioType == 2:
		print("Channel PRS = %09o" % value)
	else:
		print("Unimplemented type %d, channel %03o, value %09o" % (ioType, channel, value))
	
	return

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
				shutdownGPIO()
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
			elif (inputBuffer[2] & 0xA0) != 0x00:
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
					print("Illegal packet: 0x%02X%02X%02X%02X%02X%02X" % inputBuffer)
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
	
	root.after(10, mainLoopIteration)		
	
while False:
	mainLoopIteration()

root = tk.Tk()
ProcessorDisplayPanel_support.set_Tk_var()
top = topProcessorDisplayPanel (root)
ProcessorDisplayPanel_support.init(root, top)
ProcessorDisplayPanel_support.cPRA = cPRA
ProcessorDisplayPanel_support.cPRB = cPRB
root.after(10, mainLoopIteration)
root.mainloop()
