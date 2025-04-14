#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	piTelemetry.py
# Purpose:	Reverse engineering and/or proof-of-concept implementation
#         	of neglected AGC telemetry protocols.
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2025-04-11 RSB	Adapted from piPeripheral.py for AGC telemetry studies.

import sys
import datetime
import os
import glob
#import tkinter as tk

# Find out where piTelemetry.py itself is located.
scriptPath = os.path.abspath(__file__)
scriptDirectory = os.path.dirname(scriptPath)
#print(scriptDirectory, file=sys.stderr)

# Parse command-line arguments.
import argparse
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC/yaAGS, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaAGC/yaAGS, defaulting to 19799 for AGC or 19899 for AGS.", type=int)
cli.add_argument("--software", help="Select AGC software version, or omit for reverse engineering.")
cli.add_argument("--packet", help="Nominal packet size (default 40); omit if --software is used.")
cli.add_argument("--block", help="1 or 2 (default) for Block I or Block II; omit if --software is used.")
args = cli.parse_args()

host="AGC"

PULSE = 0.25

# Characteristics of the host and port being used for yaAGC/yaAGS communications.  
if args.host:
	TCP_IP = args.host
else:
	TCP_IP = 'localhost'
if args.port:
	TCP_PORT = args.port
else:
	TCP_PORT = 19799

# Read a TSV file (pit-ID-AGSSOFTWARE.tsv) containing a downlist definition.
downlistDefinitions = {}
def tsvRead(filename):
	fields = filename.split("-")
	id = fields[1]
	downlistDefinitions[id] = { "title": "TBD", "url": "TBD", "items": {}}
	downlistDefinition = downlistDefinitions[id]
	f = open(filename, "r")
	for line in f:
		if line[:1] == "#" or line.strip() == "":
			continue
		fields = line.rstrip("\r\n").split("\t")
		if len(fields) == 1:
			if "://" in fields[0]:
				downlistDefinition["url"] = fields[0]
			else:
				downlistDefinition["title"] = fields[0]
			continue
		offset = int(fields[0])
		item = { "name": "%d %s" % (offset+1, fields[1])}
		downlistDefinition["items"][offset] = item
	f.close

softwareEarly1 = { "Sunrise45", "Sunrise69"}
softwareLate1 = { "Corona261, Sunspot247, Solarium055"}
softwareEarly2 = { "SundialE", "Aurora88", "Aurora12", "Borealis", "Sunburst37", "Sunburst120"}
software = None
if args.software:
	raw = False
	software = args.software
	if software in softwareEarly1:
		block = 1
		early1 = True
	elif software in softwareLate1:
		block = 1
		late1 = True
	elif software in softwareEarly2:
		block = 2
		early2 = True
	else:
		print("Software version %s not supported." % software, file=sys.stderr)
		sys.exit(1)
	tsvFiles = glob.glob(scriptDirectory + os.sep + "pit-*-" + software + ".tsv")
	for tsvFile in tsvFiles:
		tsvRead(tsvFile)
	#print(downlistDefinitions)
else:
	raw = True
	if args.packet:
		packetWidth = int(args.packet)
	else:
		packetWidth = 40
	if args.block:
		block = int(args.block)
	else:
		block = 2

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.  This is the section to customize for specific applications.

# Convert an integer to 15-bit 1's-complement.  If the value doesn't fit into 15
# bits ... well, then, too bad!
def toOnesComplement(value):
	if value < 0:
		value -= 1
	return value & 0o77777

#------------------------------------------------------------------------------
# Various stuff useful in Block I

keycodesBlockI = {
	0o00: "(none)",
	0o20: "0",
	0o01: "1",
	0o02: "2",
	0o03: "3",
	0o04: "4",
	0o05: "5",
	0o06: "6",
	0o07: "7",
	0o10: "8",
	0o11: "9",
	0o21: "VERB",
	0o22: "ERROR RESET",
	0o31: "KEY RLSE",
	0o32: "+",
	0o33: "-",
	0o34: "ENTER",
	0o36: "CLEAR",
	0o37: "NOUN"
	}

digitsBlockI = {
	0o00: "(blank)",
	0o25: "0",
	0o03: "1",
	0o31: "2",
	0o33: "3",
	0o17: "4",
	0o36: "5",
	0o34: "6",
	0o23: "7",
	0o35: "8",
	0o37: "9"
	}

def printDigitBlockI(value):
	if value in digitsBlockI:
		return digitsBlockI[value]
	else:
		return "?(%02o)" % value
	
def printRelayBlockI(address, bit11, bits10to6, bits5to1):
	if address == 0o13:
		bit11 = ""
		bits10to6 = "MD1=" + printDigitBlockI(bits10to6)
		bits5to1 = "MD2=" + printDigitBlockI(bits5to1)
	elif address == 0o12:
		if bit11:
			bit11 = "FLASH"
		else:
			bit11 = "NOFLASH"
		bits10to6 = "VD1=" + printDigitBlockI(bits10to6)
		bits5to1 = "VD2=" + printDigitBlockI(bits5to1)
	elif address == 0o11:
		bit11 = ""
		bits10to6 = "ND1=" + printDigitBlockI(bits10to6)
		bits5to1 = "ND2=" + printDigitBlockI(bits5to1)
	elif address == 0o10:
		if bit11:
			bit11 = "UPACT"
		else:
			bit11 = "NOUPACT"
		bits10to6 = ""
		bits5to1 = "R1D1=" + printDigitBlockI(bits5to1)
	elif address == 0o07:
		if bit11:
			bit11 = "R1S=+"
		else:
			bit11 = "R1S="
		bits10to6 = "R1D2=" + printDigitBlockI(bits10to6)
		bits5to1 = "R1D3=" + printDigitBlockI(bits5to1)
	elif address == 0o06:
		if bit11:
			bit11 = "R1S=-"
		else:
			bit11 = "R1S="
		bits10to6 = "R1D4=" + printDigitBlockI(bits10to6)
		bits5to1 = "R1D5=" + printDigitBlockI(bits5to1)
	elif address == 0o05:
		if bit11:
			bit11 = "R2S=+"
		else:
			bit11 = "R2S="
		bits10to6 = "R2D1=" + printDigitBlockI(bits10to6)
		bits5to1 = "R2D2=" + printDigitBlockI(bits5to1)
	elif address == 0o04:
		if bit11:
			bit11 = "R2S=-"
		else:
			bit11 = "R2S="
		bits10to6 = "R1D3=" + printDigitBlockI(bits10to6)
		bits5to1 = "R1D4=" + printDigitBlockI(bits5to1)
	elif address == 0o03:
		bit11 = ""
		bits10to6 = "R1D5=" + printDigitBlockI(bits10to6)
		bits5to1 = "R3D1=" + printDigitBlockI(bits5to1)
	elif address == 0o02:
		if bit11:
			bit11 = "R3S=+"
		else:
			bit11 = "R3S="
		bits10to6 = "R3D2=" + printDigitBlockI(bits10to6)
		bits5to1 = "R3D3=" + printDigitBlockI(bits5to1)
	elif address == 0o01:
		if bit11:
			bit11 = "R3S=-"
		else:
			bit11 = "R3S="
		bits10to6 = "R3D4=" + printDigitBlockI(bits10to6)
		bits5to1 = "R3D5=" + printDigitBlockI(bits5to1)
	else:
		bit11 = "%d" % bit11
		bits10to6 = "%02o" % bits10to6
		bits5to1 = "%02o" % bits5to1
	print("Relay %s %s %s" % (bit11, bits10to6, bits5to1), file=sys.stderr)
	#print("Relay %02o: %04o" % \
	#	((pending >> 11) & 0o17, pending & 0o3777), \
	#	file=sys.stderr)

#----------------------------------------------------------------------------
# The output function.

# This function is called by the event loop only when yaAGC has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program.
if raw:
	pending = False
	col = 0
	lastWordOrder = 0
	def outputFromAGx(channel, value):
		global col, pending, lastWordOrder
		
		if block == 1:
			if pending:
				pending = False
				if channel == 0o11: # OUT1
					if 0 != (value & 0o00400): # word-order bit
						print('+', end="", file=sys.stderr)
					else:
						print('-', end="", file=sys.stderr)
					return
				else:
					pass
			if channel == 0o14: # CPU channel used for downlink data
				if col >= packetWidth:
					print(file=sys.stderr)
					col = 0
				print(" %05o" % (value), end="", file=sys.stderr)
				pending = True
				col += 1
		else: # block = 2
			if channel == 0o34:
				print(" %05oa" % value, end="", file=sys.stderr)
				col += 1
			elif channel == 0o35:
				print(" %05ob" % value, end="", file=sys.stderr)
				col += 1
			elif channel == 0o13:
				wordOrder = value & 0o00100
				if wordOrder != lastWordOrder:
					lastWordOrder = wordOrder
					if lastWordOrder:
						print(" +", end="", file=sys.stderr)
					else:
						print("\n-", end="", file=sys.stderr)
						col = 0
			if col >= packetWidth:
				print(file=sys.stderr)
				col = 0
		return
elif early1:
	tsv = downlistDefinitions["XXXXX"]["items"]
	downlistLength = len(tsv)
	downlistLengthWithoutIDsMinus1 = (4 * downlistLength) // 5 - 1
	#print("***DEBUG***", downlistLength)
	lastIndex = downlistLength - 1
	data = [""]*downlistLength
	pending = None
	ready = False
	index = 0
	def outputFromAGx(channel, value):
		global pending, ready, index, data
		import sys
		
		if channel == 0o11: # OUT1
			if pending != None:
				newline = False
				dataword = False
				indexword = False
				if value & 0o00400: # word-order bit
					dataword = True
				else:
					if pending == None:
						return
					if (pending & 0o76000) == 0o00000: # ID word
						if pending == 0:
							newline = True
							ready = True
						# In this protocol, the ID words have the index of the
						# previously-transmitted data word, but doesn't account
						# for the reversed ordering nor the insertion of the 
						# ID words themselves.  After compensating for those
						# things, we can double-check that it agrees with the
						# index we've been calculating internally.
						i = (pending * 5) // 4
						if i != index:
							print("Readjusting index from %d to %d" % (index, i), file=sys.stderr)
						indexword = True
						# Could cross check the index here vs our internal
						# one, but won't for now.
					elif (pending & 0o76000) == 0o02000: # character-indicator word
						if (pending >> 6) & 1:
							print("Mark", file=sys.stderr)
						else:
							if (pending >> 5) & 1:
								print("Uplink ", end="", file=sys.stderr)
							else:
								print("Key ", end="", file=sys.stderr)
							keycode = pending & 0o37
							if keycode in keycodesBlockI:
								print(keycodesBlockI[keycode], file=sys.stderr)
							else:
								print("unknown (%02o)" % keycode, file=sys.stderr)
						#print("Character %d %d %02o" % \
						#	((pending >> 6) & 1, (pending >> 5) & 1, pending & 0o37), \
						#	file=sys.stderr)
						pending = None
						return
					else: # relay word
						address = (pending >> 11) & 0o17
						bit11 = (pending >> 10) & 1
						bits10to6 = (pending >> 5) & 0o37
						bits5to1 = pending & 0o37
						printRelayBlockI(address, bit11, bits10to6, bits5to1)
						pending = None
						return
				#print("***DEBUG***", dataword, indexword, "%05o" % pending, index, file=sys.stderr)
				if ready and (dataword or indexword):
					data[index] = "%s: %05o" % (tsv[index]["name"], pending)
					index -= 1
					if index < 0:
						print("Downlist", file=sys.stderr)
						count = 0
						for item in data:
							print("%-20s" % item, end="", file=sys.stderr)
							count += 1
							if count >= 5:
								print(file=sys.stderr)
								count = 0
						index = lastIndex
						if count > 0:
							print(file=sys.stderr)
				pending = None
			return
		if channel == 0o14: # OUT4
			pending = value
	
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
	sys.stderr.write("Connecting to AGC " + TCP_IP + ":" + str(TCP_PORT) + "\n")
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			sys.stderr.write("Connected.\n")
			break
		except socket.error as msg:
			sys.stderr.write(str(msg) + "\n")
			time.sleep(1)

connectToAGC()

###################################################################################
# Event loop.  Just check periodically for output from yaAGC (in which case the
# user-defined callback function outputFromAGx is executed).

# Given a 3-tuple (channel,value,mask) for yaAGC, creates packet data and sends it to yaAGC.
# Or, given a 2-tuple (channel,value) for yaAGS, creates packet data and sends it to yaAGS.
def packetize(tuple):
	outputBuffer = bytearray(4)
	# First, create and output the mask command.
	outputBuffer[0] = 0x20 | ((tuple[0] >> 3) & 0x0F)
	outputBuffer[1] = 0x40 | ((tuple[0] << 3) & 0x38) | ((tuple[2] >> 12) & 0x07)
	outputBuffer[2] = 0x80 | ((tuple[2] >> 6) & 0x3F)
	outputBuffer[3] = 0xC0 | (tuple[2] & 0x3F)
	s.send(outputBuffer)
	# Now, the actual data for the channel.
	outputBuffer[0] = 0x00 | ((tuple[0] >> 3) & 0x0F)
	outputBuffer[1] = 0x40 | ((tuple[0] << 3) & 0x38) | ((tuple[1] >> 12) & 0x07)
	outputBuffer[2] = 0x80 | ((tuple[1] >> 6) & 0x3F)
	outputBuffer[3] = 0xC0 | (tuple[1] & 0x3F)
	s.send(outputBuffer)

# Buffer for a packet received from yaAGC/yaAGS.
packetSize = 4
inputBuffer = bytearray(packetSize)
leftToRead = packetSize
view = memoryview(inputBuffer)

didSomething = False
while True:
	if not didSomething:
		time.sleep(PULSE)
	didSomething = False
	
	# Check for packet data received from yaAGC/yaAGS and process it.
	# While these packets are always exactly 4
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
			if (inputBuffer[0] & 0xF0) != 0x00:
				ok = 0
			elif (inputBuffer[1] & 0xC0) != 0x40:
				ok = 0
			elif (inputBuffer[2] & 0xC0) != 0x80:
				ok = 0
			elif (inputBuffer[3] & 0xC0) != 0xC0:
				ok = 0
			# Packet has the various signatures we expect.
			if ok == 0:
				# Note that, depending on the yaAGC/yaAGS version, it occasionally
				# sends either a 1-byte packet (just 0xFF, older versions)
				# or a 4-byte packet (0xFF 0xFF 0xFF 0xFF, newer versions)
				# just for pinging the client.  These packets hold no
				# data and need to be ignored, but for other corrupted packets
				# we print a message. And try to realign past the corrupted
				# bytes.
				if inputBuffer[0] != 0xff or inputBuffer[1] != 0xff or inputBuffer[2] != 0xff or inputBuffer[2] != 0xff:
					if inputBuffer[0] != 0xff:
						print("Illegal packet: " + hex(inputBuffer[0]) + " " + hex(inputBuffer[1]) + " " + hex(inputBuffer[2]) + " " + hex(inputBuffer[3]))
					for i in range(1,packetSize):
						if (inputBuffer[i] & 0xC0) == 0:
							j = 0
							for k in range(i,4):
								inputBuffer[j] = inputBuffer[k]
								j += 1
							view = view[j:]
							leftToRead = packetSize - j
			else:
				channel = (inputBuffer[0] & 0x0F) << 3
				channel |= (inputBuffer[1] & 0x38) >> 3
				value = (inputBuffer[1] & 0x07) << 12
				value |= (inputBuffer[2] & 0x3F) << 6
				value |= (inputBuffer[3] & 0x3F)
				outputFromAGx(channel, value)
			didSomething = True
	
		