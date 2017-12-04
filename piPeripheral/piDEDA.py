#!/usr/bin/python3
# Copyright 2017 Ronald S. Burkey <info@sandroid.org>
# 
# This file is part of yaAGC.
# 
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Filename: 	piDEDA.py
# Purpose:	This is a DEDA simulation program for use with a physical
#		fake DEDA (having a particular type of hardware electronics
#		configuration), interfacing to the yaAGS program, all running
#		on a Raspberry Pi.  In other words, the physical model of the
#		DEDA contains a Raspberry Pi and other (specific electronics),
#		which together provide the combined functionality of a
#		DEDA+AGS, with the latter running either the original 
#		Flight Program 6 (Apollo 11) or Flight Program 8 (Apollo 15-17). 
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2017-12-04 RSB	Began.
#
# This program is intended to be run using the runPiDEDA.sh script, so look
# at that script for details as to how to start up the program. 
#
# About the design of this program ... yes, a real Python developer would 
# objectify it and have lots and lots of individual models defining the objects.
# However, I'm not a real Python developer, and this is simply one stand-alone
# file comprising all of the functionality.  In other words, I don't see that
# any of this code is particularly reusable, so I haven't bothered to attempt to
# encapsulate it into reusable modules.
#
# In this hardware model (which DOES NOT EXIST at the time this is written):
#
#    1.	yaAGS and piDEDA.py are running on a Raspberry Pi, using the
#	Raspbian operating system.
#    2. There is a physical model of a DSKY, accessible via the Pi's GPIO.
#    3. The physical DSKY's keyboard is accessed as a normal keyboard (as
#	far as Raspbian is concerned) that provides the usual keycodes
#	(0 1 2 3 4 5 6 7 8 9 + - C R H Enter) when the physical DEDA's
#	buttons are pressed.
#    4. The DEDA's OPR ERR discrete indicator lamp, its 8 7-segment digits, and
#       its +/- sign are all controlled by the Pi via a circuit board (which I call
#       the "DEDA WARNING LAMP BOARD") attached to the Pi GPIO SPI bus.  That board
#       has a MAXIM MAX7210 chip that provides the necessary drive capacity for 8 
#       7-segment+decimal displays, which are connected to the indicated lamps and 
#       displays as follows:
#		Board			Indicator/Digits/Signs
#		-----			----------------------
#		Digit 0, segments	3-digit register number, left digit
#		Digit 1, segments	   "       "        "  , middle digit
#		Digit 2, segments	   "       "        "  , right digit
#		Digit 3, segments	5-digit register value, left digit
#		Digit 4, segments	5-digit register value, next digit
#		Digit 5, segments	5-digit register value, next digit
#		Digit 6, segments	5-digit register value, next digit
#		Digit 7, segments	5-digit register value, right digit
#		Digit 0, decimal	OPR ERR indicator
#		Digit 1, decimal	5-digit register value, minus sign
#		Digit 2, decimal	5-digit register value, vertical part of sign
#					(i.e, to get a plus sign, you combine the
#					minus sign and the vertical part of the sign)
#		Digits 3-5, decimal	Unused.  (Possibly useful for keyboard backlighting.)
#    5.	This is all runnable on a regular Linux desktop (at least Ubuntu,
#	Debian, or Mint) by using a regular keyboard.
#
# One-time setups needed (on any Linux computer or a Pi):
#
#	sudo apt-get install python3-pip xterm
#	sudo pip3 install pynput
#
# For using the --pigpio feature (on a Pi), the following setups are also needed:
# 
#	sudo apt-get install pigpio python3-pigpio
#
# Moreover, hardware SPI is not enabled in raspbian by default, so for --pigpio on a Pi:
#
#	sudo raspi-config
#
# and then use the Interfacing / SPI option to enable the hardware SPI device.

import time
import socket
import argparse
from pynput import keyboard
import sys
import termios
import atexit
import threading
import os

# Parse command-line arguments.
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGS, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaAGS, defaulting to 19898.", type=int)
cli.add_argument("--slow", help="For use on really slow host systems.")
cli.add_argument("--pigpio", help="Use PIGPIO for lamp/display control. The value is a brightness-intensity setting, 0-15.", type=int)
args = cli.parse_args()

# Responsiveness settings.
if args.slow:
	PULSE = 0.25
else:
	PULSE = 0.05

# Characteristics of the host and port being used for yaAGS communications.  
if args.host:
	TCP_IP = args.host
else:
	TCP_IP = 'localhost'
if args.port:
	TCP_PORT = args.port
else:
	TCP_PORT = 19898

###################################################################################
# Keyboard monitoring.

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
atexit.register(echoOn, True)

keyboardQueue = []
legalKeys = [ '+', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
	'C', 'c', 'R', 'r', 'H', 'h' ]
def translate_key(key):
	if key == '=':
		key = '+'
	elif key == '_':
		key = '-'
	elif key == 'c':
		key = 'C'
	elif key == 'r':
		key = 'R'
	elif key == 'h':
		key = 'H'
	return key

resetCount = 0
def on_press(key):
	global keyboardQueue, resetCount
	try:
		if key == keyboard.Key.enter:
			keyboardQueue.append('E')
			# print("Pressed Enter")
			resetCount = 0
			return
		key.char = translate_key(key.char)
		if key.char in legalKeys:
			# print("Pressed " + key.char)
			keyboardQueue.append(key.char)
			if key.char == 'C':
				resetCount += 1
			else:
				resetCount = 0
	except:
		pass

def on_release(key):
	global keyboardQueue
	try:
		if key == keyboard.Key.enter:
			# print("Released Enter")
			keyboardQueue.append("ER")
			return
		key.char = translate_key(key.char)
		if key.char in legalKeys:
			# print("Released " + key.char)
			if key.char == 'C':
				keyboardQueue.append("CR")
			elif key.char == 'H':
				keyboardQueue.append("HR")
			elif key.char == 'R':
				keyboardQueue.append("RR")
	except:
		pass

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.  This is the section to customize for specific applications.

# This function is automatically called periodically by the event loop to check for 
# conditions that will result in sending messages to yaAGS that are interpreted
# as changes to bits on its input channels.  The return
# value is supposed to be a list of 2-tuples of the form
#	[ (channel0,value0), (channel1,value1), ...]
# and may be an empty list.  The "values" are written to the AGS's input "channels".
lineBuffer = []
operatorError = False
shiftBuffer = []

def operatorErrorOn():
	global operatorError
	operatureError = True
	print("OPR ERR ON")

def inputsForAGS():
	global keyboardQueue, lineBuffer, operatorError, shiftBuffer
	n = len(lineBuffer)
	if len(keyboardQueue) > 0:
		key = keyboardQueue.pop(0)
		if key == 'H':
			return [ (0o5, 0o767010) ]
		elif key == 'CR':
			return [ (0o5, 0o777020) ]
		elif key == 'RR':
			return [ (0o5, 0o777002) ]
		elif key == 'ER':
			return [ (0o5, 0o777004) ]
		elif key == 'HR':
			return [ (0o5, 0o777010) ]
		elif key == 'C':
			lineBuffer = [ 'C' ]
			operatorError = False
			print('OPR ERR OFF, "   " -> register, "      " -> value')
			return [ (0o5, 0o757020) ]
		if operatorError:
			return []
		elif key >= '0' and key <= '7':
			if (n >= 1 and n <= 3) or (n >= 5 and n <= 9):
				lineBuffer.append(key)
			else:
				operatorErrorOn()
				
		elif key >= '8' and key <= '9':
			if n >= 5 and n <= 9:
				lineBuffer.append(key)
			else:
				operatorErrorOn()
		elif key == '+' or key == '-':
			if n == 4:
				lineBuffer.append(key)
			else:
				operatorError = True
		elif key == 'R':
			if n == 10:
				n = 4
			if n == 4:
				lineBuffer.append(key)
				shiftBuffer = [ 
					int(lineBuffer[1]), 
					int(lineBuffer[2]), 
					int(lineBuffer[3]) ]
				return [ (0o5, 0o775002) ]
			else:
				operatorErrorOn()
		elif key == 'E':
			if n == 10:
				lineBuffer.append(key)
				if lineBuffer[4] == '+':
					sign = 0
				else:
					sign = 1
				shiftBuffer = [ 
					int(lineBuffer[1]), 
					int(lineBuffer[2]), 
					int(lineBuffer[3]),
					sign,
					int(lineBuffer[5]),
					int(lineBuffer[6]),
					int(lineBuffer[7]),
					int(lineBuffer[8]),
					int(lineBuffer[9]) ]
				return [ (0o5, 0o773004) ]
			else:
				operatorErrorOn()
	return []

# This function is called by the event loop only when yaAGS has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program.
incomingBuffer = []
def outputFromAGS(channel, value):
	global shiftBuffer, incomingBuffer
	if channel == 0o40 or channel == 0o27:
		print ("Received " + oct(channel) + " data=" + oct(value))
	# Only a few types are of interest to us.  Note that the DEDA Shift Out discrete
	# isn't of interest to us, since it's merely internal to yaAGS, and the data
	# will simply appear in the DEDA shift register.  In other words, we never
	# even get to see it as anything other than 0.
	if channel == 0o40 and 0 == (value & 0o10): 
		# DEDA Shift In discrete, active 0
		if len(shiftBuffer) == 0:
			packetize( (0o7, 0x0f << 13) )
		else:
			packetize( (0o7, shiftBuffer.pop(0) << 13) )
	elif channel == 0o27: 
		# Incoming DEDA shift register.
		incomingBuffer.append((value >> 13) & 0x0f)
		if len(incomingBuffer) == 9:
			if incomingBuffer[3] == 0:
				sign = "+"
			else:
				sign = "-"
			print(	'"' + 
				str(incomingBuffer[0]) +
				str(incomingBuffer[1]) +
				str(incomingBuffer[2]) +
				'" -> register + "' +
				sign +
				str(incomingBuffer[4]) +
				str(incomingBuffer[5]) +
				str(incomingBuffer[6]) +
				str(incomingBuffer[7]) +
				str(incomingBuffer[8]) +
				'" -> value' )
			incomingBuffer = []

###################################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

def connectToAGS():
	while True:
		try:
			s.connect((TCP_IP, TCP_PORT))
			print("Connected to yaAGS (" + TCP_IP + ":" + str(TCP_PORT) + ")")
			break
		except socket.error as msg:
			print("Could not connect to yaAGS (" + TCP_IP + ":" + str(TCP_PORT) + "), exiting: " + str(msg))
			time.sleep(1)

connectToAGS()

###################################################################################
# Event loop.  Just check periodically for output from yaAGS (in which case the
# user-defined callback function outputFromAGS is executed) or data in the 
# user-defined function inputsForAGS (in which case a message is sent to yaAGS).
# But this section has no target-specific code, and shouldn't need to be modified
# unless there are bugs.

# Given a 2-tuple (channel,value) for yaAGS, creates packet data and sends it to yaAGS.
def packetize(tuple):
	print("Sending " + oct(tuple[0]) + " " + oct(tuple[1]))
	outputBuffer = bytearray(4)
	outputBuffer[0] = 0x00 | (tuple[0] & 0x3F)
	outputBuffer[1] = 0xC0 | ((tuple[0] >> 12) & 0x3F)
	outputBuffer[2] = 0x80 | ((tuple[1] >> 6) & 0x3F)
	outputBuffer[3] = 0x40 | (tuple[1] & 0x3F)
	s.send(outputBuffer)

def eventLoop():
	# Buffer for a packet received from yaAGS.
	packetSize = 4
	inputBuffer = bytearray(packetSize)
	leftToRead = packetSize
	view = memoryview(inputBuffer)
	didSomething = False
	while True:
		if not didSomething:
			time.sleep(PULSE)
		didSomething = False
		
		# Check for packet data received from yaAGS and process it.
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
			# print("Left to read: " + str(leftToRead))
			if leftToRead == 0:
				# Prepare for next read attempt.
				view = memoryview(inputBuffer)
				leftToRead = packetSize
				# Parse the packet just read, and call outputFromAGS().
				# Start with a sanity check.
				ok = 1
				if (inputBuffer[0] & 0xC0) != 0x00:
					ok = 0
				elif (inputBuffer[1] & 0xC0) != 0xC0:
					ok = 0
				elif (inputBuffer[2] & 0xC0) != 0x80:
					ok = 0
				elif (inputBuffer[3] & 0xC0) != 0x40:
					ok = 0
				# Packet has the various signatures we expect.
				if ok == 0:
					# Note that, depending on the yaAGS version, it occasionally
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
					channel = (inputBuffer[0] & 0x3F)
					value = (inputBuffer[1] & 0x3F) << 12
					value |= (inputBuffer[2] & 0x3F) << 6
					value |= (inputBuffer[3] & 0x3F)
					outputFromAGS(channel, value)
				didSomething = True
		
		# Check for locally-generated data for which we must generate messages
		# to yaAGS over the socket.  In theory, the externalData list could contain
		# any number of channel operations, but in practice (at least for something
		# like a DEDA implementation) it will actually contain only 0 or 1 operations.
		externalData = inputsForAGS()
		for i in range(0, len(externalData)):
			packetize(externalData[i])
			didSomething = True
		
		# Has the user requested termination via hitting CLR a bunch of times?
		if resetCount >= 5:
			os._exit(0)

eventLoopThread = threading.Thread(target=eventLoop)
eventLoopThread.start()

# Collect events until released
with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
	listener.join()

