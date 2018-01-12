#!/usr/bin/python3
# Copyright:	None, placed in the PUBLIC DOMAIN by its author (Ron Burkey)
# Filename: 	piDSKY.py
# Purpose:	This is an illustration of how to use the skeleton peripheral program 
#		piPeripheral.py to create a simple simulated DSKY.
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2017-11-17 RSB	Began.
#               2017-11-21 RSB	Updated with some fixes to the PRO and NOUN
#				keys that had been identified for piDSKY2.py.
#		2017-12-02 RSB	Replaced the entire program with a stripped form
#				of piDSKY2.py (in which all hardware-specific stuff
#				has been removed), because it was easier than 
#				back-porting bug-fixes.
#		2018-01-06 MAS	Switched the TEMP light to use channel 163 instead
#				of channel 11.
#
# Note that certain functionality (I think the code for get_char_keyboard_nonblock)
# might not work under Windows, but everything should
# presumably work in Linux, Raspbian, Mac OS X, etc.
#
# In this skeleton form, the script acts as kind of a console-based DSKY, in which
# you can use keyboard keys (0 1 2 3 4 5 6 7 8 9 + - V N C P K R Enter) as surrogates
# for DSKY pushbuttons, and all DSKY-related outputs from yaAGC are simply parsed and
# displayed in textual form, though the idea is that in general, you'd rip out all of 
# that DSKY-specific stuff and replace it with whatever you wanted.
#
# The parts which need to be modified to be target-system specific are the 
# outputFromAGC() and inputsForAGC() functions, which are in the section *after* the following
# section.  The immediately following section, on the other hand, has some utility functions I use
# for the default outputFromAGC() and inputsForAGC() functions I provide, and
# can be deleted if they're not useful for the specific implementation desired.
#
# To run the program in its present form, you have to use yaAGC, and optionally
# yaDSKY2 (if you want to see the graphical DSKY and piPeripheral.py working in
# parallel).  To do that, assuming you had a directory setup in which all of the
# appropriate files could be found, you could run (presumably from different consoles)
#
#	yaDSKY2 --cfg=LM.ini --port=19797
#	yaAGC --core=Luminary099.bin --port=19797 --cfg=LM.ini
#	piDSKY.py
#
# If you didn't want to use yaDSKY2, then this stuff could all be run in a pure
# command-line environment without a GUI desktop.

import time
import os
import signal
import sys
import argparse
import threading
import termios
import fcntl
import socket

# Parse command-line arguments.
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaAGC, defaulting to 19798.", type=int)
cli.add_argument("--slow", help="For use on really slow host systems.")
args = cli.parse_args()

# Responsiveness settings.
if args.slow:
	PULSE = 0.25
	lampDeadtime = 0.25
else:
	PULSE = 0.05
	lampDeadtime = 0.1

# Characteristics of the host and port being used for yaAGC communications.  
if args.host:
	TCP_IP = args.host
else:
	TCP_IP = 'localhost'
if args.port:
	TCP_PORT = args.port
else:
	TCP_PORT = 19798

###################################################################################
# Some utilities I happen to use in my sample hardware abstraction functions, but
# not of value outside of that, unless you happen to be implementing DSKY functionality
# in a similar way.

# Given a 3-tuple (channel,value,mask), creates packet data and sends it to yaAGC.
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

# This particular function parses various keystrokes, like '0' or 'V' and creates
# packets as if they were DSKY keypresses.  It should be called occasionally as
# parseDskyKey(0) if there are no keystrokes, in order to make sure that the PRO
# key gets released.  

# The return value of this function is
# a list ([...]), of which each element is a 3-tuple consisting of an AGC channel
# number, a value for that channel, and a bitmask that tells which bit-positions
# of the value are valid.  The returned list can be empty.  For example, a
# return value of 
#	[ ( 0o15, 0o31, 0o37 ) ]
# would indicate that the lowest 5 bits of channel 15 (octal) were valid, and that
# the value of those bits were 11001 (binary), which collectively indicate that
# the KEY REL key on a DSKY is pressed.
resetCount = 0
def parseDskyKey(ch):
	global resetCount
	if ch == 'R':
		resetCount += 1
		if resetCount >= 5:
			print("Exiting ...")
			return ""
	elif ch != "":
		resetCount = 0
	returnValue = []
	if ch == '0':
		returnValue.append( (0o15, 0o20, 0o37) )
	elif ch == '1':
		returnValue.append( (0o15, 0o1, 0o37) )
	elif ch == '2':
    		returnValue.append( (0o15, 0o2, 0o37) )
	elif ch == '3':
    		returnValue.append( (0o15, 0o3, 0o37) )
	elif ch == '4':
    		returnValue.append( (0o15, 0o4, 0o37) )
	elif ch == '5':
    		returnValue.append( (0o15, 0o5, 0o37) )
	elif ch == '6':
    		returnValue.append( (0o15, 0o6, 0o37) )
	elif ch == '7':
    		returnValue.append( (0o15, 0o7, 0o37) )
	elif ch == '8':
    		returnValue.append( (0o15, 0o10, 0o37) )
	elif ch == '9':
    		returnValue.append( (0o15, 0o11, 0o37) )
	elif ch == '+':
    		returnValue.append( (0o15, 0o32, 0o37) )
	elif ch == '-':
    		returnValue.append( (0o15, 0o33, 0o37) )
	elif ch == 'V':
    		returnValue.append( (0o15, 0o21, 0o37) )
	elif ch == 'N':
    		returnValue.append( (0o15, 0o37, 0o37) )
	elif ch == 'R':
    		returnValue.append( (0o15, 0o22, 0o37) )
	elif ch == 'C':
    		returnValue.append( (0o15, 0o36, 0o37) )
	elif ch == 'P':
    		returnValue.append( (0o32, 0o00000, 0o20000) )
	elif ch == 'p' or ch == 'PR':
    		returnValue.append( (0o32, 0o20000, 0o20000) )
	elif ch == 'K':
    		returnValue.append( (0o15, 0o31, 0o37) )
	elif ch == '\n':
		returnValue.append( (0o15, 0o34, 0o37) )
	return returnValue	

# This function turns keyboard echo on or off.
def echoOn(control):
	fd = sys.stdin.fileno()
	new = termios.tcgetattr(fd)
	if control:
		print("Keyboard echo on")
		new[3] |= termios.ECHO
	else:
		print("Keyboard echo off")
		new[3] &= ~termios.ECHO
	termios.tcsetattr(fd, termios.TCSANOW, new)
echoOn(False)

# This function is a non-blocking read of a single character from the
# keyboard.  Returns either the key value (such as '0' or 'V'), or else
# the value "" if no key was pressed.  Note:  fakes a "key" 
# 'PR' 0.75 seconds after a key 'p' or 'P'.  This is in lieu of PRO
# press and release events.  Is is possible to get keypress and release
# events or other equivalent data from the Python "keyboard" module, but
# I didn't know about it at first, and am too lazy to go back and add
# that support.
pressedPRO = False
timePRO = 0
def get_char_keyboard_nonblock():
	global pressedPRO, timePRO
	fd = sys.stdin.fileno()
	oldterm = termios.tcgetattr(fd)
	newattr = termios.tcgetattr(fd)
	newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO
	termios.tcsetattr(fd, termios.TCSANOW, newattr)
	oldflags = fcntl.fcntl(fd, fcntl.F_GETFL)
	fcntl.fcntl(fd, fcntl.F_SETFL, oldflags | os.O_NONBLOCK)
	c = ""
	try:
    		c = sys.stdin.read(1)
	except IOError: pass
	termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
	fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)
	if c == 'p' or c == 'P':
		pressedPRO = True
		timePRO = time.time()
	if c == "" and pressedPRO and time.time() > timePRO + 0.75:
		pressedPRO = False
		c = 'PR'
	return c

# The following dictionary gives, for each indicator lamp:
#	Whether or not it is currently lit.
# This information isn't actually used for anything, but can be useful in a 
# specific hardware model as a way to know which lamp statuses have changed.
lampStatuses = {
	"UPLINK ACTY" : { "isLit" : False },
	"TEMP" : { "isLit" : False },
	"NO ATT" : { "isLit" : False },
	"GIMBAL LOCK" : { "isLit" : False },
	"DSKY STANDBY" : { "isLit" : False },
	"PROG" : { "isLit" : False },
	"KEY REL" : { "isLit" : False },
	"RESTART" : { "isLit" : False },
	"OPR ERR" : { "isLit" : False },
	"TRACKER" : { "isLit" : False },
	"PRIO DSP" : { "isLit" : False },
	"ALT" : { "isLit" : False },
	"NO DAP" : { "isLit" : False },
	"VEL" : { "isLit" : False }
}
# For modifying the lampStatuses[] array.
def updateLampStatuses(key, value):
	global lampStatuses
	if key in lampStatuses:
		lampStatuses[key]["isLit"] = value

# Converts a 5-bit code in channel 010 to " ", "0", ..., "9".
def codeToString(code):
	if code == 0:
		return " "
	elif code == 21:
		return "0"
	elif code == 3:
		return "1"
	elif code == 25:
		return "2"
	elif code == 27:
		return "3"
	elif code == 15:
		return "4"
	elif code == 30:
		return "5"
	elif code == 28:
		return "6"
	elif code == 19:
		return "7"
	elif code == 29:
		return "8"
	elif code == 31:
		return "9"
	return "?"

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.

# This function is automatically called periodically by the event loop to check for 
# conditions that will result in sending messages to yaAGC that are interpreted
# as changes to bits on its input channels.  For test purposes, it simply polls the
# keyboard, and interprets various keystrokes as DSKY keys if present.  The return
# value is supposed to be a list of 3-tuples of the form
#	[ (channel0,value0,mask0), (channel1,value1,mask1), ...]
# and may be en empty list.  
def inputsForAGC():
	ch = get_char_keyboard_nonblock()
	ch = ch.upper()
	if ch == '_':
		ch = '-'
	elif ch == '=':
		ch = '+'
	else:
		returnValue = parseDskyKey(ch)
	if len(returnValue) > 0:
        	print("Sending to yaAGC: " + oct(returnValue[0][1]) + "(mask " + oct(returnValue[0][2]) + ") -> channel " + oct(returnValue[0][0]))
	return returnValue

def updateLamps():
	# If there were actual hardware, this is where you could use
	# lampStatus[] to control the lamps.
	return
updateLamps()

# This function is called by the event loop only when yaAGC has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program. As a test, I simply display the outputs for 
# those channels relevant to the DSKY.
last10 = 1234567
last11 = 1234567
last13 = 1234567
last163 = 1234567
plusMinusState1 = 0
plusMinusState2 = 0
plusMinusState3 = 0
def outputFromAGC(channel, value):
	# These lastNN values are just used to cut down on the number of messages printed,
	# when the same value is output over and over again to the same channel, because
	# that makes debugging harder.  
	global last10, last11, last13, last163, plusMinusState1, plusMinusState2, plusMinusState3
	if (channel == 0o13):
		value &= 0o3000
	if (channel == 0o10 and value != last10) or (channel == 0o11 and value != last11) or (channel == 0o13 and value != last13) or (channel == 0o163 and value != last163):
		if channel == 0o10:
			last10 = value
			aaaa = (value >> 11) & 0x0F
			b = (value >> 10) & 0x01
			ccccc = (value >> 5) & 0x1F
			ddddd = value & 0x1F
			if aaaa != 12:
				sc = codeToString(ccccc)
				sd = codeToString(ddddd)
			if aaaa == 11:
				print(sc + " -> M1   " + sd + " -> M2")
			elif aaaa == 10:
				print(sc + " -> V1   " + sd + " -> V2")
			elif aaaa == 9:
				print(sc + " -> N1   " + sd + " -> N2")
			elif aaaa == 8:
				print("          " + sd + " -> 11")
			elif aaaa == 7:
				plusMinus = "  "
				if b != 0:
					plusMinus = "1+"
					plusMinusState1 |= 1
				else:
					plusMinusState1 &= ~1
				print(sc + " -> 12   " + sd + " -> 13   " + plusMinus)
			elif aaaa == 6:
				plusMinus = "  "
				if b != 0:
					plusMinus = "1-"
					plusMinusState1 |= 2
				else:
					plusMinusState1 &= ~2
				print(sc + " -> 14   " + sd + " -> 15   " + plusMinus)
			elif aaaa == 5:
				plusMinus = "  "
				if b != 0:
					plusMinus = "2+"
					plusMinusState2 |= 1
				else:
					plusMinusState2 &= ~1
				print(sc + " -> 21   " + sd + " -> 22   " + plusMinus)
			elif aaaa == 4:
				plusMinus = "  "
				if b != 0:
					plusMinus = "2-"
					plusMinusState2 |= 2
				else:
					plusMinusState2 &= ~2
				print(sc + " -> 23   " + sd + " -> 24   " + plusMinus)
			elif aaaa == 3:
				print(sc + " -> 25   " + sd + " -> 31")
			elif aaaa == 2:
				plusMinus = "  "
				if b != 0:
					plusMinus = "3+"
					plusMinusState3 |= 1
				else:
					plusMinusState3 &= ~1
				print(sc + " -> 32   " + sd + " -> 33   " + plusMinus)
			elif aaaa == 1:
				plusMinus = "  "
				if b != 0:
					plusMinus = "3-"
					plusMinusState3 |= 2
				else:
					plusMinusState3 &= ~2
				print(sc + " -> 34   " + sd + " -> 35   " + plusMinus)
			elif aaaa == 12:
				vel = "VEL OFF         "
				if (value & 0x04) != 0:
					vel = "VEL ON          "
					updateLampStatuses("VEL", True)
				else:
					updateLampStatuses("VEL", False)
				noAtt = "NO ATT OFF      "
				if (value & 0x08) != 0:
					noAtt = "NO ATT ON       "
					updateLampStatuses("NO ATT", True)
				else:
					updateLampStatuses("NO ATT", False)
				alt = "ALT OFF         "
				if (value & 0x10) != 0:
					alt = "ALT ON          "
					updateLampStatuses("ALT", True)
				else:
					updateLampStatuses("ALT", False)
				gimbalLock = "GIMBAL LOCK OFF "
				if (value & 0x20) != 0:
					gimbalLock = "GIMBAL LOCK ON  "
					updateLampStatuses("GIMBAL LOCK", True)
				else:
					updateLampStatuses("GIMBAL LOCK", False)
				tracker = "TRACKER OFF     "
				if (value & 0x80) != 0:
					tracker = "TRACKER ON      "
					updateLampStatuses("TRACKER", True)
				else:
					updateLampStatuses("TRACKER", False)
				prog = "PROG OFF        "
				if (value & 0x100) != 0:
					prog = "PROG ON         "
					updateLampStatuses("PROG", True)
				else:
					updateLampStatuses("PROG", False)
				print(vel + "   " + noAtt + "   " + alt + "   " + gimbalLock + "   " + tracker + "   " + prog)
				updateLamps()
		elif channel == 0o11:
			last11 = value
			compActy = "COMP ACTY OFF   "
			if (value & 0x02) != 0:
				compActy = "COMP ACTY ON    "
			uplinkActy = "UPLINK ACTY OFF "
			if (value & 0x04) != 0:
				uplinkActy = "UPLINK ACTY ON  "
				updateLampStatuses("UPLINK ACTY", True)
			else:
				updateLampStatuses("UPLINK ACTY", False)
			flashing = "V/N NO FLASH    "
			print(compActy + "   " + uplinkActy + "   " + "   " + flashing)
			updateLamps()
		elif channel == 0o13:
			last13 = value
			test = "DSKY TEST       "
			if (value & 0x200) == 0:
				test = "DSKY NO TEST    "
			print(test)
			updateLamps()
		elif channel == 0o163:
			last163 = value
			if (value & 0x08) != 0:
				temp = "TEMP ON         "
				updateLampStatuses("TEMP", True)
			else:
				temp = "TEMP OFF        "
				updateLampStatuses("TEMP", False)
			if (value & 0o400) != 0:
				standby = "DSKY STANDBY ON "
				updateLampStatuses("DSKY STANDBY", True)
			else:
				standby = "DSKY STANDBY OFF"
				updateLampStatuses("DSKY STANDBY", False)
			if (value & 0o20) != 0:
				keyRel = "KEY REL ON      "
				updateLampStatuses("KEY REL", True)
			else:
				keyRel = "KEY REL OFF     "
				updateLampStatuses("KEY REL", False)
			if (value & 0o100) != 0:
				oprErr = "OPR ERR FLASH   "
				updateLampStatuses("OPR ERR", True)
			else:
				oprErr = "OPR ERR OFF     "
				updateLampStatuses("OPR ERR", False)
			if (value & 0o200) != 0:
				restart = "RESTART ON    "
				updateLampStatuses("RESTART", True)
			else:
				restart = "RESTART OFF     "
				updateLampStatuses("RESTART", False)
			print(temp + "   " + standby + "   " + keyRel + "   " + oprErr + "   " + restart)
		else:
			print("Received from yaAGC: " + oct(value) + " -> channel " + oct(channel))
	return

###################################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

def connectToAGC():
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			print("Connected to yaAGC (" + TCP_IP + ":" + str(TCP_PORT) + ")")
			break
		except socket.error as msg:
			print("Could not connect to yaAGC (" + TCP_IP + ":" + str(TCP_PORT) + "), exiting: " + str(msg))
			time.sleep(1)
			# The following provides a clean exit from the program by simply 
			# hitting any key.  However if get_char_keyboard_nonblock isn't
			# defined, just delete the next 4 lines and use Ctrl-C to exit instead.
			ch = get_char_keyboard_nonblock()
			if ch != "":
				print("Exiting ...")
				sys.exit()

connectToAGC()

###################################################################################
# Event loop.  Just check periodically for output from yaAGC (in which case the
# user-defined callback function outputFromAGC is executed) or data in the 
# user-defined function inputsForAGC (in which case a message is sent to yaAGC).
# But this section has no target-specific code, and shouldn't need to be modified
# unless there are bugs.

def eventLoop():
	# Buffer for a packet received from yaAGC.
	packetSize = 4
	inputBuffer = bytearray(packetSize)
	leftToRead = packetSize
	view = memoryview(inputBuffer)
	
	didSomething = False
	while True:
		if not didSomething:
			time.sleep(PULSE)
		didSomething = False
		
		# Check for packet data received from yaAGC and process it.
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
				# Parse the packet just read, and call outputFromAGC().
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
					# Note that, depending on the yaAGC version, it occasionally
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
							if (inputBuffer[i] & 0xF0) == 0:
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
					outputFromAGC(channel, value)
				didSomething = True
		
		# Check for locally-generated data for which we must generate messages
		# to yaAGC over the socket.  In theory, the externalData list could contain
		# any number of channel operations, but in practice (at least for something
		# like a DSKY implementation) it will actually contain only 0 or 1 operations.
		externalData = inputsForAGC()
		if externalData == "":
			echoOn(True)
			return
		for i in range(0, len(externalData)):
			packetize(externalData[i])
			didSomething = True

eventLoop()

os._exit(0)



