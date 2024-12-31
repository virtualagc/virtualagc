#!/usr/bin/env python3
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
# Filename: 	piDSKY2.py
# Purpose:	This is a variation of piDSKY.py (a "generic" DSKY
#		simulation for use with yaAGC) that is targeted for
#		a Raspberry Pi using a specific hardware model, and
#		is not really applicable for any other purpose.
# Reference:	http://www.ibiblio.org/apollo/developer.html
# Mod history:	2017-11-19 RSB	Began adapting from piDSKY.py.
#		2017-11-20 RSB	Added command-line arguments of various
#				kinds and fixed the keyboard binding
#				in the tkinter window.  Systematized
#				the widget positioning to just a few
#				variables rather than hardcoding them
#				lots of places.
#		2017-11-21 RSB	Changed PRO timeout from 0.25 to 0.5.
#		2017-11-22 RSB	Graphical rendering of widgets now made
#				lazy, so that they're not drawn at all
#				if they haven't changed.
#		2017-11-24 RSB	Added suggested stuff for numeric keypad.
#		2017-11-25 RSB	Added indicator-lamp controls based on
#				the external program 'led-panel', and 
#				duplicated (I hope) Mike Stewart's fixes
#				to yaDSKY2 a year or so ago, for the
#				RESTART, STANDBY, OPR ERR, and KEY REL
#				lamps.  For the STANDBY behavior to 
#				work properly, also changed the PRO
#				timeout to 0.75.  (Needed to be in the
#				range 0.64 to 1.92.)
#		2017-11-26 RSB	Added timing filters to prevent the led-panel
#				from being run when it is already running.
#				My dummy version of led-panel has been 
#				modified (to test this feature) to always
#				take around a second to run, and to include
#				a high-resolution time in its display message.
#				Fixed dumb bugs in TEMP, VEL, and UPLINK lamps.
#				Now expects key-repeat to be off, and detects
#				release of the PRO key directly.
#		2017-11-27 RSB	At Sam's request, emptied out the default 
#				command-string for led-panel (to eliminate,
#				apparently, the backlights for the keypad).
#				Added vncserverui detection.  Swapped the
#				BackSpace and Tab aliases (now for PRO and
#				KEY REL), so as to be able to implement a
#				key-release for the PRO alias.  The 
#				RRRRR exit had ceased working and, as far
#				as I can tell, should never have worked in
#				the first place.
#		2017-11-28 RSB	Replaced the single-character global buffers
#				I was using for buffering GUI keypresses
#				and releases with a proper queue that insures
#				no presses or releases are lost and that they
#				are all processed in the correct order.
#				Added some instrumentation that keeps a count
#				of all uses of V35E and prints them out on
#				stderr. Added code to catch exceptions in use
#				of psutil (that I think can happen when trying
#				to get the attributes of a process which has
#				just disappeared).
#		2017-11-29 RSB	Initial attempt at coding up a PIGPIO-based
#				solution for running the indicator lamps,
#				vs using the external program 'led-panel'.
#				The logic is "complete", but I don't have any
#				of the technical documentation for the LED
#				board and don't recall the part number of the
#				driver chip :-), so it's pretty much guaranteed
#				not to work as-is.  Nevertheless, stuff like
#				the SPI API can be checked out to a certain
#				degree.
#		2017-12-04 RSB	Fixed PIGPIO control of lamps, I think.
#		2017-12-06 RSB	Added 3 dots.
#		2017-12-09 RSB	Added --record and --playback.  Cleaned up
#				the record-keeping about the last values of
#				the input channels a lot, so that a lot of
#				unnecessary duplication of operations is 
#				presumably prevented.
#		2017-12-11 RSB	Now accepts floats as timestamps in playback
#				files, though hopefully that will never occur.
#		2017-12-12 RSB	Added AGC input channels (i.e., keystrokes) to
#				the --record and --playback features.  What I
#				intend to do with them in playback is to flash
#				the backlight on the associated keys momentarily,
#				but I don't have enough technical information to
#				do so, nor is it wired up on the DSKY I have yet,
#				so at the moment it does nothing in playback other
#				than hook it.
#		2017-12-13 RSB	Added the key-backlight on playback feature I 
#				simply hooked yesterday.  There was a bug in 
#				keeping track of which lamps had changed, that
#				became apparently only in adding an 8th digit
#				for the LED controller.
#		2017-12-16 RSB	Now allow AGC-connect operation to timeout
#				(currently 10 seconds).  Useful for connection
#				to yaAGC external to Pi.
#		2017-12-20 RSB	Added --lamptest.
#		2017-12-21 RSB	Added --manual.
#		2017-12-27 RSB	The SPI handle wasn't getting released in under
#				some circumstances when the program exited,
#				causing re-runs to eventually fail when no
#				more SPI handles were available in PIGPIOD.
#				I hope I tracked all those down and fixed them.
#		2017-12-28 RSB	Added a little extra (probably unnecessary) code
#				to insure shutdown of PIGPIO on termination.
#				Tests of yesterday's SPI-shutdown code have been
#				working fine, though.
#		2017-12-30 RSB	Allowed corrupted lines in playback scripts, 
#				in order to handle comment lines.
#		2017-12-31 RSB	Modified the playback scripts in two ways:  First,
#				it explicitly checks for '#...' and removes them
#				as being comments, and doesn't simply rely on 
#				the line being ill-formed.  Secondly, after 
#				removal of comments, any line NOT of the form
#				"float octal octal" is treated as "float command",
#				where the command is executed in the background
#				by shelling out.  Thus, arbitrary BASH commands such
#				as audio playback can be put into the script.
#		2018-01-06 MAS	Switched the TEMP light to use channel 163 instead
#				of channel 11.
#		2018-03-10 RSB	Added --gunmetal option.
#
# About the design of this program ... yes, a real Python developer would 
# objectify it and have lots and lots of individual modules defining the objects.
# However, I'm not a real Python developer, and this is simply one stand-alone
# file comprising all of the functionality.  In other words, I don't see that
# any of this code is particularly reusable, so I haven't bothered to attempt to
# encapsulate it into reusable modules.
#
# In this hardware model:
#
#    1.	yaAGC and piDSKY2.py are running on a Raspberry Pi, using the
#	Raspbian operating system.
#    2. There is a physical model of a DSKY, accessible via the Pi's GPIO.
#    3. The physical DSKY's keyboard is accessed as a normal keyboard (as
#	far as Raspbian is concerned) that provides the usual keycodes
#	(0 1 2 3 4 5 6 7 8 9 + - V N C P K R Enter) when the physical DSKY's
#	buttons are pressed.  Additionally, there are some keycode aliases
#	for the keycodes just mentioned, which can be used if alternate physical
#	keypads are used.
#    4. The DSKY's discrete indicator lamps (i.e., the upper left section
#	of the DSKY's front panel) are accessed either by shelling out to the
#	'led-panel' program for each interaction, or else by using the PIGPIO
#	module to directly control the Pi's SPI bus on the GPIO.  The former
#	is by default, and the latter is done if there is a command-line
#	parameter --pigpio=N (where N is a brightness level from 0 to 15).
#    5. The DSKY's upper right portion of the front panel (i.e., the 
#	numeric registers, COMP ACTY indicator, etc.) consists of an LCD
#	panel attached to the Pi via HDMI, composite video, or some other
#	means.  I.e., it is the display which Raspian uses for its GUI
#	desktop.  It is accessed using the tkinter module.
#
# One-time setups needed:
#
#	sudo apt-get install python3-tk python3-pip imagemagick \
#		python-imaging python-imaging-tk python3-psutil xterm
#	sudo pip3 install pyscreenshot pillow
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
#
# On a Pi, the entire software stack, including yaAGC, is probably best run by 
# using the script
#
#		xterm [-fullscreen] -e runPiDSKY2.sh [OPTIONS]
#
# In terms of the software model, you basically have two threads, the tkinter module's
# "root" thread (which is used for drawing the graphics mentioned in item #5 on the
# list above, either full-screen or in a 272x480 window), and the "eventLoop" thread,
# which handles all communication with yaAGC, receives keyboard inputs, and performs
# all non-graphical processing, but decides which graphical widgets are supposed to 
# be drawn.  All of the other code is just callbacks or auxiliary functions used by the
# eventLoop thread. Additionally, Raspbian's RAM disk (/run/user/$UID/) is used for all files
# created by the program, including any temporary files.

import time
import os
import signal
import sys
import argparse
import threading
from tkinter import Tk, Label, PhotoImage
import termios
import fcntl
from pyscreenshot import grab
import psutil
import socket

homeDir = os.path.expanduser("~")
#print("Home = " + homeDir)

# Parse command-line arguments.
cli = argparse.ArgumentParser()
cli.add_argument("--host", help="Host address of yaAGC, defaulting to localhost.")
cli.add_argument("--port", help="Port for yaAGC, defaulting to 19798.", type=int)
cli.add_argument("--window", help="Use window rather than full screen for LCD.")
cli.add_argument("--slow", help="For use on really slow host systems.")
cli.add_argument("--pigpio", help="Use PIGPIO rather than led-panel for lamp control. The value is a brightness-intensity setting, 0-15.", type=int)
cli.add_argument("--record", help="Record all incoming i/o-channel data for later playback.")
cli.add_argument("--playback", help="Play back recorded i/o-channel data from selected filename.")
cli.add_argument("--lamptest", help="Perform a lamp test and then exit.")
cli.add_argument("--manual", help="Manually control the display.")
cli.add_argument("--gunmetal", help="Use gunmetal versions of mounting posts and horizontal separator.")
cli.add_argument("--backlights", help="Turn on key backlights at startup.")
args = cli.parse_args()

if args.backlights:
	useBacklights = True
else:
	useBacklights = False

if args.manual:
	os.system('clear')
	print("Manual DSKY Instructions")
	print("------------------------")
	print("Area-selection mode:")
	print("     RSET    to exit.")
	print("     PRO     to select PROG area.")
	print("     VERB    to select VERB area.")
	print("     NOUN    to select NOUN area.")
	print("     1/2/3   to select R1/R2/R3.")
	print("     +       to select lamps.")
	print("     -       to select key-backlights.")
	print("     CLR     to toggle COMP ACTY.")
	print("In numerical-entry mode (after choosing")
	print("PRO, VERB, NOUN, 1, 2, or 3 in area-")
	print("selection mode), use these keys:")
	print("     +-0123456789 as usual for numbers")
	print("     CLR     for blank spaces")
	print("     KEY REL to backspace")
	print("     ENTR    returns to area selection")
	print("     RSET    screenshot")
	print("     PRO/VERB/NOUN also switch areas")
	print("For lamp-editing mode, the 14 lamps are")
	print("ordered ROW-WISE starting from the")
	print("upper left to the lower right.  For")
	print("key-backlight mode, the keys are")
	print("ordered COLUMN-WISE from upper left to")
	print("lower right (19 total), plus 3 hidden")
	print("lamps: VNC, TBD1, and TBD2.  In either")
	print("case, use these keys in these modes:")
	print("     +- for ON and OFF")
	print("     KEY REL to backspace")
	print("     ENTR    returns to area selection")
	print("     RSET    screenshot")
	print("     PRO/VERB/NOUN also switch areas")
	input("Hit ENTR to start ... ")

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

if args.record:
	lastRecordedTime = -1
	recordingFile = open(homeDir + "/Desktop/piDSKY2-recorded.canned", "w", 1)

if args.playback:
	useBacklights = False
	lastPlaybackTime = time.time()
	playbackEvents = []
	currentPlaybackIndex = 0
	try:
		playbackFile = open(args.playback, "r")
		playbackGenerator = (line.strip().split() for line in playbackFile)
		# Loop on the input-file's lines.
		for line in playbackGenerator:
			# If we find a field that begins with the '#' character,
			# we ignore all of the fields beyond it as constituting
			# a comment.
			for i in range(1, len(line)):
				if line[i][:1] == '#':
					line = line[:i]
					break
			# At minimum, we require there must be at least 2 fields in 
			# the line, that the first must be a float, and the 
			# second must not be empty.
			if len(line) < 2 or len(line[1]) < 1:
				continue
			try:
				differential = float(line[0])
			except:
				continue
			# There are two cases at this
			# point.  First, the line could be an i/o-channel event, in
			# which case it has 3 fields consisting of a float (already
			# verified) and two octals.  In the second, it consists of
			# a variable number of fields, of which the first is a float
			# (already verified), the second is non-empty (and consists
			# of the name of a program to be run), and the remainder (if
			# any) are the command-line parameters for that program.
			# When we append this to the event array, we distinguish by adding
			# an extra field that is either True for the former case or
			# False for the latter.
			entry = ()
			if len(line) == 3:			
				try:
					entry = ( True, differential, int(line[1], 8), int(line[2], 8)  )
				except:
					pass
			if len(entry) == 0:
				command = line[1];
				for i in range(2, len(line)):
					command += " " + line[i]
				entry = ( False, differential, command )
			playbackEvents.append( entry )
			#print(str(playbackEvents[len(playbackEvents)-1]))
	except:
		print("Problem with playback file: " + args.playback)
		time.sleep(2)
		echoOn(True)
		os._exit(1)

# Set up root viewport for tkinter graphics
root = Tk()
if args.window:
	root.geometry('272x480+0+0')
	root.title("piDSKY2")
else:
	root.attributes('-fullscreen', True)
	root.config(cursor="none")
root.configure(background='black')
# Preload images to make it go faster later.
imageDigitBlank = PhotoImage(file="piDSKY2-images/7Seg-0.gif")
imageDigit0 = PhotoImage(file="piDSKY2-images/7Seg-21.gif")
imageDigit1 = PhotoImage(file="piDSKY2-images/7Seg-3.gif")
imageDigit2 = PhotoImage(file="piDSKY2-images/7Seg-25.gif")
imageDigit3 = PhotoImage(file="piDSKY2-images/7Seg-27.gif")
imageDigit4 = PhotoImage(file="piDSKY2-images/7Seg-15.gif")
imageDigit5 = PhotoImage(file="piDSKY2-images/7Seg-30.gif")
imageDigit6 = PhotoImage(file="piDSKY2-images/7Seg-28.gif")
imageDigit7 = PhotoImage(file="piDSKY2-images/7Seg-19.gif")
imageDigit8 = PhotoImage(file="piDSKY2-images/7Seg-29.gif")
imageDigit9 = PhotoImage(file="piDSKY2-images/7Seg-31.gif")
imageCompActyOff = PhotoImage(file="piDSKY2-images/CompActyOff.gif")
imageCompActyOn = PhotoImage(file="piDSKY2-images/CompActyOn.gif")
imageMinusOn = PhotoImage(file="piDSKY2-images/MinusOn.gif")
imagePlusOn = PhotoImage(file="piDSKY2-images/PlusOn.gif")
imagePlusMinusOff = PhotoImage(file="piDSKY2-images/PlusMinusOff.gif")
imageProgOn = PhotoImage(file="piDSKY2-images/ProgOn.gif")
imageVerbOn = PhotoImage(file="piDSKY2-images/VerbOn.gif")
imageNounOn = PhotoImage(file="piDSKY2-images/NounOn.gif")
if args.gunmetal:
	imageSeparatorOn = PhotoImage(file="piDSKY2-images/SeparatorOn.gif")
	imageSeparatorOff = PhotoImage(file="piDSKY2-images/SeparatorOn.gif")
	imageDot = PhotoImage(file="piDSKY2-images/Dot.gif")
else:
	imageSeparatorOn = PhotoImage(file="piDSKY2-images/SeparatorOn-gunmetal.gif")
	imageSeparatorOff = PhotoImage(file="piDSKY2-images/SeparatorOff-gunmetal.gif")
	imageDot = PhotoImage(file="piDSKY2-images/Dot-gunmetal.gif")
# Initial placement of all graphical objects on LCD panel.
widgetStates = {}
widgetLabels = {}
def displayGraphic(x, y, img):
	global widgetStates, widgetLabels
	key = str(x) + "," + str(y)
	if key in widgetStates:
		if widgetStates[key] is img:
			#print("skipping " + key)
			return
	widgetStates[key] = img
	if key in widgetLabels:
		widgetLabels[key].destroy()
	widgetLabels[key] = Label(root, image=img, borderwidth=0, highlightthickness=0)
	widgetLabels[key].place(x=x, y=y)
topDot = 15
dotSpacing = 92
topProg = 36
topVN = 149
topR1 = 238
topR2 = 328
topR3 = 418
signWidth = 22
digitWidth = 50
colSign = 0
colDot = 133
colPN = 172
colD1 = colSign + signWidth
colD2 = colD1 + digitWidth
colD3 = colD2 + digitWidth
colD4 = colD3 + digitWidth
colD5 = colD4 + digitWidth
displayGraphic(colDot, topDot, imageDot)
displayGraphic(colDot, topDot + dotSpacing, imageDot)
displayGraphic(colDot, topDot + 2 * dotSpacing, imageDot)
displayGraphic(colPN, 0, imageProgOn)
displayGraphic(0, 113, imageVerbOn)
displayGraphic(colPN, 113, imageNounOn)
displayGraphic(0, 212, imageSeparatorOn)
displayGraphic(0, 302, imageSeparatorOff)
displayGraphic(0, 392, imageSeparatorOff)

###################################################################################
# Stuff related to control of the lamp board via PIGPIO and SPI on the Pi's GPIO.

# Initialize the PIGPIO API.  Note that LED-driver chip we're going to 
# interface to has a 10 Mbaud SPI bus, and the PIGPIO docs indicate that
# the SPI bus probably won't work above 30 Mbaud, so 10 Mbaud is probably
# okay.  I arbitrarily cut this down to 100K, but an optimal setting should 
# perhaps be determined empirically.
gpio = ""
spiHandle = -1
spiChannel = 0
spiBaud = 100000
spiErrorMessageWaitTime = 3

# Writes to a register of the LED driver chip via the SPI bus.  The
# register address is 0..15, and the value is 0..255.
def writeSpi(address, value):
	global gpio, spiHandle
	gpio.spi_write(spiHandle, [ address, value ])

def shutdownGPIO():
	if args.pigpio:
		global spiHandle, gpio
		if spiHandle >= 0:
			gpio.spi_close(spiHandle)
			spiHandle = -1
		if gpio != "":
			gpio.stop()
			gpio = ""
import atexit
atexit.register(shutdownGPIO)

if args.pigpio:
	import pigpio
	gpio = pigpio.pi()
	if not gpio.connected:
		sys.stderr.write("Cannot connect to PIGPIO server.\n")
		time.sleep(spiErrorMessageWaitTime)
		os.exit(1)
	spiHandle = gpio.spi_open(spiChannel, spiBaud, 0x0000) # CE0, main SPI device, mode 0.
	if spiHandle < 0:
		sys.stderr.write("Cannot open SPI channel.\n")
		time.sleep(spiErrorMessageWaitTime)
		if gpio != "":
			gpio.stop()
			gpio = ""
		os.exit(1)

	# Set up the LED-driver chip.
	for i in range(1, 9):
		writeSpi(i, 0) # The initial settings of the "digits".
	writeSpi(9, 0) # No BCD decoding.
	writeSpi(10, int(args.pigpio)) # Brightness-PWM setting, 0..15.
	writeSpi(11, 7) # All 8 digits are controlled.
	writeSpi(12, 1) # Not in shut-down mode.
	
	# Simply a test of the display and the code above, 
	# using the chip's display-test function.
	if False:
		print("SPI test ...")
		for i in range(0, 10):
			print("On " + str(i))
			writeSpi(15, 1)
			time.sleep(1)
			print("Off " + str(i))
			writeSpi(15, 0)
			time.sleep(1)
		print("SPI test completed.")

###################################################################################
# Some utilities I happen to use in my sample hardware abstraction functions, but
# not of value outside of that, unless you happen to be implementing DSKY functionality
# in a similar way.

# Given a 3-tuple (channel,value,mask), creates packet data and sends it to yaAGC.
def packetize(tuple):
	if args.playback:
		return
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
	if args.record:
		global lastRecordedTime, recordingFile, lastInputChannels
		currentTime = time.time()
		if lastRecordedTime < 0:
			lastRecordedTime = currentTime
		try:
			channelName = oct(tuple[0])
			if not (channelName in lastInputChannels) or lastInputChannels[channelName] != tuple[1]:
				lastInputChannels[channelName] = tuple[1]
				recordingFile.write(str(round(1000 * (currentTime - lastRecordedTime))) 
					+ " " + ("%o" % tuple[0]) + " " + ("%o" % tuple[1]) + "\n")
				lastRecordedTime = currentTime
		except:
			pass
		lastRecordedTime = currentTime

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
# stateV35E and countV35E are some instrumentation for printing out a count of how
# many times V35E has been used.  It is solely for debugging.
stateV35E = 0
countV35E = 0
def parseDskyKey(ch):
	global resetCount
	global stateV35E, countV35E
	if ch == 'R':
		resetCount += 1
		if resetCount >= 5:
			print("Exiting ...")
			return ""
	elif ch != "":
		resetCount = 0
	returnValue = []
	relatedToV35E = False
	if ch == '0':
		returnValue.append( (0o15, 0o20, 0o37) )
	elif ch == '1':
		returnValue.append( (0o15, 0o1, 0o37) )
	elif ch == '2':
    		returnValue.append( (0o15, 0o2, 0o37) )
	elif ch == '3':
    		returnValue.append( (0o15, 0o3, 0o37) )
    		if stateV35E == 1:
    			relatedToV35E = True
    			stateV35E = 2
	elif ch == '4':
    		returnValue.append( (0o15, 0o4, 0o37) )
	elif ch == '5':
    		returnValue.append( (0o15, 0o5, 0o37) )
    		if stateV35E == 2:
    			relatedToV35E = True
    			stateV35E = 3
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
    		relatedToV35E = True
    		stateV35E = 1
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
	elif ch == '\n' or ch == 'E':
		returnValue.append( (0o15, 0o34, 0o37) )
		if stateV35E == 3:
			countV35E += 1
			sys.stderr.write("V35E count = " + str(countV35E) + "\n")
	else:
		relatedToV35E = True
	if not relatedToV35E:
		stateV35E = 0
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

# Get a screenshot.
def screenshot(name):
	global args
	print("Creating screenshot ...")
	img = grab(bbox=(0, 0, 272, 480))
	img.save(name)
	print("Screenshot saved as " + name);

# This function is a non-blocking read of a single character from the
# keyboard.  Returns either the key value (such as '0' or 'V'), or else
# the value "" if no key was pressed.
def get_char_keyboard_nonblock():
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
	return c

###################################################################################
# Hardware abstraction / User-defined functions.  Also, any other platform-specific
# initialization.

# This function is automatically called periodically by the event loop to check for 
# conditions that will result in sending messages to yaAGC that are interpreted
# as changes to bits on its input channels.  For test purposes, it simply polls the
# keyboard, and interprets various keystrokes as DSKY keys if present.  The return
# value is supposed to be a list of 3-tuples of the form
#	[ (channel0,value0,mask0), (channel1,value1,mask1), ...]
# and may be en empty list.  The list guiKey is used to queue up keypresses (or
# relevant key releases) from the graphics window, so that they can be properly
# merged in with keystrokes from the console, without losing any of them.
guiKey = []
def getKey():
	global guiKey
	if len(guiKey) == 0:
		ch = get_char_keyboard_nonblock()
	else:
		ch = guiKey.pop(0)
	ch = ch.upper()
	if ch == '_':
		ch = '-'
	elif ch == '=':
		ch = '+'
	return ch
def inputsForAGC():
	returnValue = parseDskyKey(getKey())
	if len(returnValue) > 0:
        	print("Sending to yaAGC: " + oct(returnValue[0][1]) + "(mask " + oct(returnValue[0][2]) + ") -> channel " + oct(returnValue[0][0]))
	return returnValue

# Capture any keypress events from the LCD window.
# Many need to be translated for shifting, or due to being
# from the numeric keypad.
guiKeyTranslations = []
guiKeyTranslations.append(("Return", "\n"))
guiKeyTranslations.append(("KP_Enter", "\n"))
guiKeyTranslations.append(("equal", "+"))
guiKeyTranslations.append(("plus", "+"))
guiKeyTranslations.append(("KP_Add", "+"))
guiKeyTranslations.append(("minus", "-"))
guiKeyTranslations.append(("underscore", "-"))
guiKeyTranslations.append(("KP_Subtract", "-"))
guiKeyTranslations.append(("slash", "V"))
guiKeyTranslations.append(("KP_Divide", "V"))
guiKeyTranslations.append(("asterisk", "N"))
guiKeyTranslations.append(("KP_Multiply", "N"))
guiKeyTranslations.append(("Delete", "C"))
guiKeyTranslations.append(("KP_Decimal", "C"))
guiKeyTranslations.append(("KP_Delete", "C"))
guiKeyTranslations.append(("BackSpace", "P"))
guiKeyTranslations.append(("KP_0", "0"))
guiKeyTranslations.append(("KP_Insert", "0"))
guiKeyTranslations.append(("KP_1", "1"))
guiKeyTranslations.append(("KP_End", "1"))
guiKeyTranslations.append(("KP_2", "2"))
guiKeyTranslations.append(("KP_Down", "2"))
guiKeyTranslations.append(("KP_3", "3"))
guiKeyTranslations.append(("KP_Next", "3"))
guiKeyTranslations.append(("KP_4", "4"))
guiKeyTranslations.append(("KP_Left", "4"))
guiKeyTranslations.append(("KP_5", "5"))
guiKeyTranslations.append(("KP_Begin", "5"))
guiKeyTranslations.append(("KP_6", "6"))
guiKeyTranslations.append(("KP_Right", "6"))
guiKeyTranslations.append(("KP_7", "7"))
guiKeyTranslations.append(("KP_Home", "7"))
guiKeyTranslations.append(("KP_8", "8"))
guiKeyTranslations.append(("KP_Up", "8"))
guiKeyTranslations.append(("KP_9", "9"))
guiKeyTranslations.append(("KP_Prio", "9"))
debugKey = ""
def guiKeypress(event):
	global guiKey, debugKey, guiKeyTranslations
	if event.keysym == "Num_Lock":
		# Pressing the NUM LOCK key turns key-repeat back on.
		# So let's undo that.
		os.system("xset r off &")
	debugKey = event.keysym
	for i in range(0, len(guiKeyTranslations)):
		if debugKey == guiKeyTranslations[i][0]:
			guiKey.append(guiKeyTranslations[i][1])
			return
	guiKey.append(debugKey)
def guiKeyrelease(event):
	global guiKey
	if event.keysym == 'p' or event.keysym == 'P' or event.keysym == "BackSpace":
		guiKey.append("PR")
root.bind_all('<KeyPress>', guiKeypress)
root.bind_all('<KeyRelease>', guiKeyrelease)
# The tab key isn't captured by the stuff above.
def tabKeypress(event):
	global guiKey, debugKey
	debugKey = "Tab"
	guiKey.append("K")
root.bind_all('<Tab>', tabKeypress)
os.system("xset r off &")

# Converts a 5-bit code in channel 010 to " ", "0", ..., "9".
def codeToString(code):
	if code == 0:
		return " ", imageDigitBlank
	elif code == 21:
		return "0", imageDigit0
	elif code == 3:
		return "1", imageDigit1
	elif code == 25:
		return "2", imageDigit2
	elif code == 27:
		return "3", imageDigit3
	elif code == 15:
		return "4", imageDigit4
	elif code == 30:
		return "5", imageDigit5
	elif code == 28:
		return "6", imageDigit6
	elif code == 19:
		return "7", imageDigit7
	elif code == 29:
		return "8", imageDigit8
	elif code == 31:
		return "9", imageDigit9
	return "?", imageDigitBlank

def displaySign(x, y, state):
	if state == 1:
		displayGraphic(x, y, imagePlusOn)
	elif state == 2:
		displayGraphic(x, y, imageMinusOn)
	else:
		displayGraphic(x, y, imagePlusMinusOff)

# For flashing verb/noun area.
vnFlashing = False
vnTimer = ""
vnCurrentlyOn = True
vnImage1 = imageDigitBlank
vnImage2 = imageDigitBlank
vnImage3 = imageDigitBlank
vnImage4 = imageDigitBlank
def vnFlashingHandler():
	global vnFlashing, vnTimer, vnCurrentlyOn, vnImage1, vnImage2, vnImage3, vnImage4
	if vnFlashing:
		vnCurrentlyOn = not vnCurrentlyOn
		if vnCurrentlyOn:
			displayGraphic(0, topVN, vnImage1)
			displayGraphic(digitWidth, topVN, vnImage2)
			displayGraphic(colPN, topVN, vnImage3)
			displayGraphic(colPN + digitWidth, topVN, vnImage4)
		else:
			displayGraphic(0, topVN, imageDigitBlank)
			displayGraphic(digitWidth, topVN, imageDigitBlank)
			displayGraphic(colPN, topVN, imageDigitBlank)
			displayGraphic(colPN + digitWidth, topVN, imageDigitBlank)
		vnTimer = threading.Timer(0.75, vnFlashingHandler)
		vnTimer.start()

def vnFlashingStop():
	global vnFlashing, vnTimer, vnCurrentlyOn, vnImage1, vnImage2, vnImage3, vnImage4
	if vnFlashing:
		vnTimer.cancel()
		displayGraphic(0, topVN, vnImage1)
		displayGraphic(digitWidth, topVN, vnImage2)
		displayGraphic(colPN, topVN, vnImage3)
		displayGraphic(colPN + digitWidth, topVN, vnImage4)
		vnFlashing = False

# The following dictionary gives, for each controllable lighting element (indicator lamps
# and key backlights mostly):
#	Whether or not it is currently lit.
#	Command-line parameters for the shell function 'led-panel' to turn on that lamp.
#	A list of registers and bit-masks (for the registers) for an LED-driver chip
#		connected to the Pi via the SPI bus for turning that lamp.
# The hardware assumption is that there is a MAX7219 7-segment LED controller chip,
# which is a device that controls 8 7-segment(+decimal point) displays, thus 
# controlling 64 individual LEDs.  These are arranged as "DIGIT0" through "DIGIT1",
# controlled by chip registers 1 through 8.  Within an individual chip register, 
# the display segments are (from MSB to LSB)
#	DP a b c d e f g
# Thus to indicate which LEDs a given lighting element is associated with, we only
# have to list the chip registers and bit masks within the register those lighting
# elements are associated with.  Both these chip parameters and command-line parameters
# for the external program 'led-panel' are given.  Which of the two sets of parameters 
# ends up being used is dependendent on the --pigpio command-line parameter. 
lampStatuses = {
	"UPLINK ACTY" : { "isLit" : False, "cliParameter" : "3", "spiParameters" : [ { "register":1, "mask":0x70 } ] },
	"TEMP" : { "isLit" : False, "cliParameter" : "2", "spiParameters" : [ { "register":1, "mask":0x07 } ] },
	"NO ATT" : { "isLit" : False, "cliParameter" : "5", "spiParameters" : [ { "register":2, "mask":0x70 } ] },
	"GIMBAL LOCK" : { "isLit" : False, "cliParameter" : "4", "spiParameters" : [ { "register":2, "mask":0x07 } ] },
	"DSKY STANDBY" : { "isLit" : False, "cliParameter" : "7", "spiParameters" : [ { "register":3, "mask":0x70 } ] },
	"PROG" : { "isLit" : False, "cliParameter" : "6", "spiParameters" : [ { "register":3, "mask":0x07 } ] },
	"KEY REL" : { "isLit" : False, "cliParameter" : "B", "spiParameters" : [ { "register":4, "mask":0x70 } ] },
	"RESTART" : { "isLit" : False, "cliParameter" : "8", "spiParameters" : [ { "register":4, "mask":0x07 } ] },
	"OPR ERR" : { "isLit" : False, "cliParameter" : "9", "spiParameters" : [ { "register":5, "mask":0x70 } ] },
	"TRACKER" : { "isLit" : False, "cliParameter" : "A", "spiParameters" : [ { "register":5, "mask":0x07 } ] },
	"PRIO DSP" : { "isLit" : False, "cliParameter" : "D", "spiParameters" : [ { "register":6, "mask":0x70 } ] },
	"ALT" : { "isLit" : False, "cliParameter" : "C", "spiParameters" : [ { "register":6, "mask":0x07 } ] },
	"NO DAP" : { "isLit" : False, "cliParameter" : "F", "spiParameters" : [ { "register":7, "mask":0x70 } ] },
	"VEL" : { "isLit" : False, "cliParameter" : "E", "spiParameters" : [ { "register":7, "mask":0x07 } ] },
	"VERB KEY" : { "isLit" : not useBacklights, "cliParameter" : "G", "spiParameters" : [ { "register":1, "mask":0x08 } ] },
	"NOUN KEY" : { "isLit" : not useBacklights, "cliParameter" : "H", "spiParameters" : [ { "register":1, "mask":0x80 } ] },
	"+ KEY" : { "isLit" : not useBacklights, "cliParameter" : "I", "spiParameters" : [ { "register":2, "mask":0x08 } ] },
	"- KEY" : { "isLit" : not useBacklights, "cliParameter" : "J", "spiParameters" : [ { "register":2, "mask":0x80 } ] },
	"0 KEY" : { "isLit" : not useBacklights, "cliParameter" : "K", "spiParameters" : [ { "register":3, "mask":0x08 } ] },
	"7 KEY" : { "isLit" : not useBacklights, "cliParameter" : "L", "spiParameters" : [ { "register":3, "mask":0x80 } ] },
	"4 KEY" : { "isLit" : not useBacklights, "cliParameter" : "M", "spiParameters" : [ { "register":4, "mask":0x08 } ] },
	"1 KEY" : { "isLit" : not useBacklights, "cliParameter" : "N", "spiParameters" : [ { "register":4, "mask":0x80 } ] },
	"8 KEY" : { "isLit" : not useBacklights, "cliParameter" : "O", "spiParameters" : [ { "register":5, "mask":0x08 } ] },
	"5 KEY" : { "isLit" : not useBacklights, "cliParameter" : "P", "spiParameters" : [ { "register":5, "mask":0x80 } ] },
	"2 KEY" : { "isLit" : not useBacklights, "cliParameter" : "Q", "spiParameters" : [ { "register":6, "mask":0x08 } ] },
	"9 KEY" : { "isLit" : not useBacklights, "cliParameter" : "R", "spiParameters" : [ { "register":6, "mask":0x80 } ] },
	"6 KEY" : { "isLit" : not useBacklights, "cliParameter" : "S", "spiParameters" : [ { "register":7, "mask":0x08 } ] },
	"3 KEY" : { "isLit" : not useBacklights, "cliParameter" : "T", "spiParameters" : [ { "register":7, "mask":0x80 } ] },
	"CLR KEY" : { "isLit" : not useBacklights, "cliParameter" : "U", "spiParameters" : [ { "register":8, "mask":0x40 } ] },
	"PRO KEY" : { "isLit" : not useBacklights, "cliParameter" : "V", "spiParameters" : [ { "register":8, "mask":0x20 } ] },
	"KEY REL KEY" : { "isLit" : not useBacklights, "cliParameter" : "W", "spiParameters" : [ { "register":8, "mask":0x10 } ] },
	"ENTR KEY" : { "isLit" : not useBacklights, "cliParameter" : "X", "spiParameters" : [ { "register":8, "mask":0x08 } ] },
	"RSET KEY" : { "isLit" : not useBacklights, "cliParameter" : "Y", "spiParameters" : [ { "register":8, "mask":0x04 } ] },
	"VNCSERVERUI" : { "isLit" : False, "cliParameter" : "Z", "spiParameters" : [ { "register":8, "mask":0x02 } ] },
	"TBD1" : { "isLit" : False, "cliParameter" : "a", "spiParameters" : [ { "register":8, "mask":0x01 } ] },
	"TBD2" : { "isLit" : False, "cliParameter" : "b", "spiParameters" : [ { "register":8, "mask":0x80 } ] }
}
#lampCliStringDefault = "GHIJKLMNOPQRSTUVWXY"
lampCliStringDefault = ""
lastLampCliString = ""
def updateLampStatuses(key, value):
	global lampStatuses
	if key in lampStatuses:
		lampStatuses[key]["isLit"] = value
def flushLampUpdates(lampCliString):
	global lastLampCliString
	lastLampCliString = lampCliString
	os.system("sudo ./led-panel '" + lampCliString + "' &")
lampExecCheckCount = 0
lampUpdateTimer = threading.Timer(lampDeadtime, flushLampUpdates)
lastLedArray = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
def updateLamps():
	global lastLedArray
	if args.pigpio:
		# For directly accessing LED-controller chip via
		# SPI bus using PIGPIO library.
		
		# First step, determine what all bits need to be set in the chip's
		# digit registers.
		ledArray = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
		for key in lampStatuses:
			if lampStatuses[key]["isLit"]:
				parameters = lampStatuses[key]["spiParameters"]
				for i in range(0, len(parameters)):
					# Note that all the address fields should be 1..8.
					ledArray[parameters[i]["register"] - 1] |= parameters[i]["mask"]
		
		# Write out the registers that have changed.
		for i in range(0,8):
			if ledArray[i] != lastLedArray[i]:
				#print("write SPI " + str(1 + i) + " <- " + hex(ledArray[i]))
				writeSpi(i + 1, ledArray[i])
				lastLedArray[i] = ledArray[i]
	else:
		# For shelling out to 'led-panel' program.
		
		global lampUpdateTimer, lampExecCheckCount
		global lastLampCliString
		
		# First step, determine what led-panel's CLI parameter string will be.
		lampCliString = ""
		for key in lampStatuses:
			if lampStatuses[key]["isLit"]:
				lampCliString += lampStatuses[key]["cliParameter"]
		lampCliString += lampCliStringDefault
		
		# If unchanged, do nothing.
		if lampCliString == lastLampCliString:
			return
		
		# Have to determine if led-panel is still running from before, in
		# which case we can't start it again and have to retry later.			
		lampExecCheckCount += 1
		lampUpdateTimer.cancel()
		ledPanelRunning = False
		for proc in psutil.process_iter():
			try:
				info = proc.as_dict(attrs=['name'])
				if "led-panel" in info['name']:
					ledPanelRunning = True
					break
			except psutil.NoSuchProcess:
				pass
		if ledPanelRunning:
			print("Delaying lamp flush to avoid overlap ...")
			lampExecCheckCount = 0
			lampUpdateTimer = threading.Timer(lampDeadtime, updateLamps)
			lampUpdateTimer.start()
			return
		if lampExecCheckCount < 2:
				lampUpdateTimer = threading.Timer(lampDeadtime, updateLamps)
				lampUpdateTimer.start()
				return
		lampExecCheckCount = 0
		
		# Everything is swell, so run 'led-panel'.
		flushLampUpdates(lampCliString)
def updateLampStatusesAndLamps(key, value):
	#sys.stderr.write("BL " + key + " " + oct(value) + "\n")
	updateLampStatuses(key, value)
	updateLamps()

def backlightOn():
	for key in lampStatuses:
		if key[-3:] == "KEY":
			updateLampStatuses(key, True)
	updateLamps()
def backlightOff():
	for key in lampStatuses:
		if key[-3:] == "KEY":
			updateLampStatuses(key, False)
	updateLamps()

def everythingOff():
	for key in lampStatuses:
		updateLampStatuses(key, False)
	updateLamps()
	displayGraphic(0, 0, imageCompActyOff)
	displayGraphic(colPN, topProg, imageDigitBlank)
	displayGraphic(colPN + digitWidth, topProg, imageDigitBlank)
	displayGraphic(0, topVN, imageDigitBlank)
	displayGraphic(digitWidth, topVN, imageDigitBlank)
	displayGraphic(colPN, topVN, imageDigitBlank)
	displayGraphic(colPN + digitWidth, topVN, imageDigitBlank)
	displayGraphic(colSign, topR1, imagePlusMinusOff)
	displayGraphic(colD1, topR1, imageDigitBlank)
	displayGraphic(colD2, topR1, imageDigitBlank)
	displayGraphic(colD3, topR1, imageDigitBlank)
	displayGraphic(colD4, topR1, imageDigitBlank)
	displayGraphic(colD5, topR1, imageDigitBlank)
	displayGraphic(colSign, topR2, imagePlusMinusOff)
	displayGraphic(colD1, topR2, imageDigitBlank)
	displayGraphic(colD2, topR2, imageDigitBlank)
	displayGraphic(colD3, topR2, imageDigitBlank)
	displayGraphic(colD4, topR2, imageDigitBlank)
	displayGraphic(colD5, topR2, imageDigitBlank)
	displayGraphic(colSign, topR3, imagePlusMinusOff)
	displayGraphic(colD1, topR3, imageDigitBlank)
	displayGraphic(colD2, topR3, imageDigitBlank)
	displayGraphic(colD3, topR3, imageDigitBlank)
	displayGraphic(colD4, topR3, imageDigitBlank)
	displayGraphic(colD5, topR3, imageDigitBlank)

everythingOff()

# This checks to see if vncserverui is running, and turns on a lamp if so.
vncCheckTimer = ""
def checkForVncserver():
	global vncCheckTimer
	vncserveruiFound = False
	for proc in psutil.process_iter():
		try:
			info = proc.as_dict(attrs=['name'])
			if "vncserverui" in info['name']:
				vncserveruiFound = True
				break
		except psutil.NoSuchProcess:
			pass
	updateLampStatuses("VNCSERVERUI", vncserveruiFound)
	updateLamps()
	vncCheckTimer = threading.Timer(10, checkForVncserver)
	vncCheckTimer.start()
checkForVncserver()

def timersStop():
	global vnTimer, lampUpdateTimer, vncCheckTimer
	print("Canceling all timers ...")
	if vnTimer != "":
		vnTimer.cancel()
	if lampUpdateTimer != "":
		lampUpdateTimer.cancel()
	if vncCheckTimer != "":
		vncCheckTimer.cancel()

# This function is called by the event loop only when yaAGC has written
# to an output channel.  The function should do whatever it is that needs to be done
# with this output data, which is not processed additionally in any way by the 
# generic portion of the program. As a test, I simply display the outputs for 
# those channels relevant to the DSKY.
lastInputChannels = {
	"0o10-1" : 1234567,
	"0o10-2" : 1234567,
	"0o10-3" : 1234567,
	"0o10-4" : 1234567,
	"0o10-5" : 1234567,
	"0o10-6" : 1234567,
	"0o10-7" : 1234567,
	"0o10-8" : 1234567,
	"0o10-9" : 1234567,
	"0o10-10" : 1234567,
	"0o10-11" : 1234567,
	"0o10-12" : 1234567,
	"0o11" : 1234567,
	"0o13" : 1234567,
	"0o163" : 1234567,
	"0o15" : 1234567,
	"0o32" : 1234567
}
plusMinusState1 = 0
plusMinusState2 = 0
plusMinusState3 = 0
lastKeyRel = ""
def outputFromAGC(channel, value):
	# These lastInputChannels[] values are just used to avoid time-consuming redoing
	# of operations which aren't actual changes; cuts down on debugging messages
	# as well
	global lastInputChannels, plusMinusState1, plusMinusState2, plusMinusState3
	global vnFlashing, vnTimer, vnCurrentlyOn, vnImage1, vnImage2, vnImage3, vnImage4, vnTestOverride
	global lastKeyRel
	rawChannelValue = value
	if channel == 0o10:
		relay = (value >> 11) & 0o17
		channelName = "0o10-" + str(relay)
		value &= 0o3777
		if relay < 1 or relay > 12:
			return 
	elif channel == 0o11:
		channelName = "0o11"
		value &= 0x2E
	elif channel == 0o13:
		channelName = "0o13"
		value &= 0x200
	elif channel == 0o163:
		channelName = "0o163"
		value &= 0o720
	else:
		return
	if (channelName in lastInputChannels) and lastInputChannels[channelName] == value:
		return
	lastInputChannels[channelName] = value
	value = rawChannelValue
	if args.record:
		global lastRecordedTime
		currentTime = time.time()
		if lastRecordedTime < 0:
			lastRecordedTime = currentTime
		try:
			#recordingFile.write("lastInputChannels[\"" + channelName + "\"] = " + oct(lastInputChannels[channelName]) + "\n") 
			recordingFile.write(str(round(1000 * (currentTime - lastRecordedTime))) + " " + ("%o" % channel) + " " + ("%o" % value) + "\n")
		except:
			pass
		lastRecordedTime = currentTime
	if channel == 0o10:
		aaaa = relay
		b = (value >> 10) & 0x01
		ccccc = (value >> 5) & 0x1F
		ddddd = value & 0x1F
		if aaaa != 12:
			sc,ic = codeToString(ccccc)
			sd,id = codeToString(ddddd)
		if aaaa == 11:
			print(sc + " -> M1   " + sd + " -> M2")
			displayGraphic(colPN, topProg, ic)
			displayGraphic(colPN + digitWidth, topProg, id)
		elif aaaa == 10:
			print(sc + " -> V1   " + sd + " -> V2")
			vnImage1 = ic
			vnImage2 = id
			displayGraphic(0, topVN, ic)
			displayGraphic(digitWidth, topVN, id)
		elif aaaa == 9:
			print(sc + " -> N1   " + sd + " -> N2")
			vnImage3 = ic
			vnImage4 = id
			displayGraphic(colPN, topVN, ic)
			displayGraphic(colPN + digitWidth, topVN, id)
		elif aaaa == 8:
			print("          " + sd + " -> 11")
			displayGraphic(colD1, topR1, id)
		elif aaaa == 7:
			plusMinus = "  "
			if b != 0:
				plusMinus = "1+"
				plusMinusState1 |= 1
			else:
				plusMinusState1 &= ~1
			displaySign(colSign, topR1, plusMinusState1)
			print(sc + " -> 12   " + sd + " -> 13   " + plusMinus)
			displayGraphic(colD2, topR1, ic)
			displayGraphic(colD3, topR1, id)
		elif aaaa == 6:
			plusMinus = "  "
			if b != 0:
				plusMinus = "1-"
				plusMinusState1 |= 2
			else:
				plusMinusState1 &= ~2
			displaySign(colSign, topR1, plusMinusState1)
			print(sc + " -> 14   " + sd + " -> 15   " + plusMinus)
			displayGraphic(colD4, topR1, ic)
			displayGraphic(colD5, topR1, id)
		elif aaaa == 5:
			plusMinus = "  "
			if b != 0:
				plusMinus = "2+"
				plusMinusState2 |= 1
			else:
				plusMinusState2 &= ~1
			displaySign(colSign, topR2, plusMinusState2)
			print(sc + " -> 21   " + sd + " -> 22   " + plusMinus)
			displayGraphic(colD1, topR2, ic)
			displayGraphic(colD2, topR2, id)
		elif aaaa == 4:
			plusMinus = "  "
			if b != 0:
				plusMinus = "2-"
				plusMinusState2 |= 2
			else:
				plusMinusState2 &= ~2
			displaySign(colSign, topR2, plusMinusState2)
			print(sc + " -> 23   " + sd + " -> 24   " + plusMinus)
			displayGraphic(colD3, topR2, ic)
			displayGraphic(colD4, topR2, id)
		elif aaaa == 3:
			print(sc + " -> 25   " + sd + " -> 31")
			displayGraphic(colD5, topR2, ic)
			displayGraphic(colD1, topR3, id)
		elif aaaa == 2:
			plusMinus = "  "
			if b != 0:
				plusMinus = "3+"
				plusMinusState3 |= 1
			else:
				plusMinusState3 &= ~1
			displaySign(colSign, topR3, plusMinusState3)
			print(sc + " -> 32   " + sd + " -> 33   " + plusMinus)
			displayGraphic(colD2, topR3, ic)
			displayGraphic(colD3, topR3, id)
		elif aaaa == 1:
			plusMinus = "  "
			if b != 0:
				plusMinus = "3-"
				plusMinusState3 |= 2
			else:
				plusMinusState3 &= ~2
			displaySign(colSign, topR3, plusMinusState3)
			print(sc + " -> 34   " + sd + " -> 35   " + plusMinus)
			displayGraphic(colD4, topR3, ic)
			displayGraphic(colD5, topR3, id)
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
		compActy = "COMP ACTY OFF   "
		if (value & 0x02) != 0:
			compActy = "COMP ACTY ON    "
			displayGraphic(0, 0, imageCompActyOn)
		else:
			displayGraphic(0, 0, imageCompActyOff)
		uplinkActy = "UPLINK ACTY OFF "
		if (value & 0x04) != 0:
			uplinkActy = "UPLINK ACTY ON  "
			updateLampStatuses("UPLINK ACTY", True)
		else:
			updateLampStatuses("UPLINK ACTY", False)
		flashing = "V/N NO FLASH    "
		if (value & 0x20) != 0:
			if not vnFlashing:
				vnFlashing = True
				vnCurrentlyOn = True
				vnTimer = threading.Timer(0.75, vnFlashingHandler)
				vnTimer.start()
			flashing = "V/N FLASH       "
		else:
			if vnFlashing != False:
				vnFlashingStop()
		print(compActy + "   " + uplinkActy + "   " + "   " + "   " + flashing)
		updateLamps()
	elif channel == 0o13:
		test = "DSKY TEST       "
		if (value & 0x200) == 0:
			test = "DSKY NO TEST    "
		print(test)
		updateLamps()
	elif channel == 0o163:
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
			oprErr = "OPR ERR ON      "
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
		updateLamps()
	else:
		print("Received from yaAGC: " + oct(value) + " -> channel " + oct(channel))
	return

###################################################################################
# Lamp test

if args.lamptest:
	print("Turning on all lamps ...")
	for key in lampStatuses:
		updateLampStatuses(key, True)
	updateLamps()
	print("Wait for 10 seconds ...")
	time.sleep(10)
	print("Turning off all lamps ...")
	for key in lampStatuses:
		updateLampStatuses(key, False)
	updateLamps()
	print("Exiting lamp test ...")
	echoOn(True)
	timersStop()
	root.destroy()
	shutdownGPIO()
	os.system("xset r on &")
	os._exit(0)

###################################################################################
# Direct manual control of the lamps and numerical registers.

if args.manual:
	print("Direct manual control ...")
	everythingOff()
	
	def manualControl():
		# The state variable determines how an input key is interpreted.
		# The state consists of two parts, AREA and OFFSET, where AREA is
		#	0	No area selected
		#	1	PROG area
		#	2	VERB area
		#	3	NOUN area
		#	4	R1 area
		#	5	R2 area
		#	6	R3 area
		#	7	Lamp area
		#	8	Key-backlight area
		# (COMP ACTY has no AREA associated with it.)
		# The OFFSET is the position within the AREA, with 0 being
		# the leftmost.  For the lamp area, 0 is the upper left,
		# 1 the upper right, and so on, down to 13 for the lower right.
		# For the key-backlight area, the order is from upper left
		# downward, and then to the right:  VERB NOUN + - 0 7 4 1 .... 
		stateAREA = 0
		stateOFFSET = 0
		compActy = False
		stateBuffer = [
			[],
			[ 'c', 'c' ],
			[ 'c', 'c' ],
			[ 'c', 'c' ],
			[ 'c', 'c', 'c', 'c', 'c', 'c' ],
			[ 'c', 'c', 'c', 'c', 'c', 'c' ],
			[ 'c', 'c', 'c', 'c', 'c', 'c' ],
			[ '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0' ],
			[ '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0' ]
		]
		statePrefix = [ '', 'p', 'v', 'n', 'a', 'b', 'c', 'l', 'k' ]
		while True:
			ch = getKey()
			if ch == "":
				continue
			if ch == 'R':
				name = ''
				for i in range(1, len(statePrefix)):
					name += statePrefix[i]
					for j in range(0, len(stateBuffer[i])):
						name += stateBuffer[i][j]
				if compActy:
					name += "C"
				else:
					name += "c"
				name += ".png"
				screenshot(homeDir + '/' + name)
			if stateAREA == 0:
				stateOFFSET = 0
				if ch == 'R':
					break;
				elif ch == 'P':
					stateAREA = 1
				elif ch == 'V':
					stateAREA = 2
				elif ch == 'N':
					stateAREA = 3
				elif ch == '1':
					stateAREA = 4
				elif ch == '2':
					stateAREA = 5
				elif ch == '3':
					stateAREA = 6
				elif ch == '+':
					stateAREA = 7
				elif ch == '-':
					stateAREA = 8
				elif ch == 'C':
					compActy = not compActy
					if compActy:
						displayGraphic(0, 0, imageCompActyOn)
					else:
						displayGraphic(0, 0, imageCompActyOff)
			elif stateAREA >= 1 and stateAREA <= 6: # Numerical areas
				if stateAREA == 1:
					row = topProg
					col = colPN + stateOFFSET * digitWidth
					digits = 2	
				elif stateAREA == 2:
					row = topVN
					col = stateOFFSET * digitWidth
					digits = 2	
				elif stateAREA == 3:
					row = topVN
					col = colPN + stateOFFSET * digitWidth
					digits = 2	
				elif stateAREA == 4 or stateAREA == 5 or stateAREA == 6:
					if stateAREA == 4:
						row = topR1
					elif stateAREA == 5:
						row = topR2
					else:
						row = topR3
					if stateOFFSET == 0:
						col = colSign
					else:
						col = colD1 + (stateOFFSET - 1) * digitWidth
					digits = 6
				if ch == "K":
					if stateOFFSET > 0:
						stateOFFSET -= 1
				elif ch == "E" or ch == "\n":
					stateAREA = 0
				elif ch == "P":
					stateAREA = 1
					stateOFFSET = 0
				elif ch == "V":
					stateAREA = 2
					stateOFFSET = 0
				elif ch == "N":
					stateAREA = 3
					stateOFFSET = 0
				elif stateOFFSET >= digits:
					continue
				elif stateOFFSET == 0 and digits == 6:
					if ch == "C":
						displayGraphic(col, row, imagePlusMinusOff)
					elif ch == "+":
						displayGraphic(col, row, imagePlusOn)
					elif ch == "-":
						displayGraphic(col, row, imageMinusOn)
					else:
						continue
					stateBuffer[stateAREA][stateOFFSET] = ch
					stateOFFSET += 1
				else:
					if ch == "C":
						displayGraphic(col, row, imageDigitBlank)
					elif ch == "0":
						displayGraphic(col, row, imageDigit0)
					elif ch == "1":
						displayGraphic(col, row, imageDigit1)
					elif ch == "2":
						displayGraphic(col, row, imageDigit2)
					elif ch == "3":
						displayGraphic(col, row, imageDigit3)
					elif ch == "4":
						displayGraphic(col, row, imageDigit4)
					elif ch == "5":
						displayGraphic(col, row, imageDigit5)
					elif ch == "6":
						displayGraphic(col, row, imageDigit6)
					elif ch == "7":
						displayGraphic(col, row, imageDigit7)
					elif ch == "8":
						displayGraphic(col, row, imageDigit8)
					elif ch == "9":
						displayGraphic(col, row, imageDigit9)
					else:
						continue
					stateBuffer[stateAREA][stateOFFSET] = ch
					stateOFFSET += 1
			elif stateAREA == 7: # Lamp area
				lampNames = [ 	"UPLINK ACTY", "TEMP", "NO ATT", "GIMBAL LOCK",
						"DSKY STANDBY", "PROG", "KEY REL", "RESTART",
						"OPR ERR", "TRACKER", "PRIO DSP","ALT",
						"NO DAP", "VEL" ]
				if ch == "E" or ch == "\n":
					stateAREA = 0
				elif ch == "P":
					stateAREA = 1
					stateOFFSET = 0
				elif ch == "V":
					stateAREA = 2
					stateOFFSET = 0
				elif ch == "N":
					stateAREA = 3
					stateOFFSET = 0
				elif ch == "K":
					if stateOFFSET > 0:
						stateOFFSET -= 1
				elif stateOFFSET >= len(lampNames):
					continue
				elif ch == "-":
					updateLampStatuses(lampNames[stateOFFSET], False)
					updateLamps()
					stateBuffer[stateAREA][stateOFFSET] = ch
					stateOFFSET += 1
				elif ch == "+":
					updateLampStatuses(lampNames[stateOFFSET], True)
					updateLamps()
					stateBuffer[stateAREA][stateOFFSET] = ch
					stateOFFSET += 1
			elif stateAREA == 8: # Key-backlight area
				keyNames = [ 	"VERB KEY", "NOUN KEY", 
						"+ KEY", "- KEY", "0 KEY", "7 KEY",
						"4 KEY", "1 KEY", "8 KEY", "5 KEY",
						"2 KEY", "9 KEY", "6 KEY", "3 KEY",
						"CLR KEY", "PRO KEY", "KEY REL KEY", "ENTR KEY",
						"RSET KEY", "VNCSERVERUI", "TBD1", "TBD2"  ]
				if ch == "E" or ch == "\n":
					stateAREA = 0
				elif ch == "P":
					stateAREA = 1
					stateOFFSET = 0
				elif ch == "V":
					stateAREA = 2
					stateOFFSET = 0
				elif ch == "N":
					stateAREA = 3
					stateOFFSET = 0
				elif ch == "K":
					if stateOFFSET > 0:
						stateOFFSET -= 1
				elif stateOFFSET >= len(keyNames):
					continue
				elif ch == "-":
					updateLampStatuses(keyNames[stateOFFSET], False)
					updateLamps()
					stateBuffer[stateAREA][stateOFFSET] = ch
					stateOFFSET += 1
				elif ch == "+":
					updateLampStatuses(keyNames[stateOFFSET], True)
					updateLamps()
					stateBuffer[stateAREA][stateOFFSET] = ch
					stateOFFSET += 1
			else:
				stateAREA = 0
		
		print("Exiting manual control ...")
		everythingOff()
		echoOn(True)
		timersStop()
		root.destroy()
		shutdownGPIO()
		os.system("xset r on &")
		os._exit(0)
	
	manualThread = threading.Thread(target=manualControl)
	manualThread.start()
	root.mainloop()
	os._exit(0)
	
###################################################################################
# Generic initialization (TCP socket setup).  Has no target-specific code, and 
# shouldn't need to be modified unless there are bugs.

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setblocking(0)

def connectToAGC():
	count = 0
	sys.stderr.write("Connecting to AGC " + TCP_IP + ":" + str(TCP_PORT) + "\n")
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
				echoOn(True)
				os._exit(1)
			time.sleep(1)
			# The following provides a clean exit from the program by simply 
			# hitting any key.  However if get_char_keyboard_nonblock isn't
			# defined, just delete the next 4 lines and use Ctrl-C to exit instead.
			ch = get_char_keyboard_nonblock()
			if ch != "":
				sys.sderr.write("Exiting ...")
				echoOn(True)
				shutdownGPIO()
				os._exit(1)

if args.playback:
	pass
else:	
	connectToAGC()

if useBacklights:
	backlightOn()

###################################################################################
# Event loop.  Just check periodically for output from yaAGC (in which case the
# user-defined callback function outputFromAGC is executed) or data in the 
# user-defined function inputsForAGC (in which case a message is sent to yaAGC).
# But this section has no target-specific code, and shouldn't need to be modified
# unless there are bugs.
keyNames = [ 
	"none", "1 KEY", "2 KEY", "3 KEY", "4 KEY", 
	"5 KEY", "6 KEY", "7 KEY", "8 KEY", "9 KEY", 
	"none", "none", "none", "none", "none", 
	"none", "0 KEY", "VERB KEY", "RSET KEY", "none", 
	"none", "none", "none", "none", "none", 
	"KEY REL KEY", "+ KEY", "- KEY", "ENTR KEY", "none",
	"CLR KEY", "NOUN KEY"
]
def eventLoop():
	global debugKey
	# Buffer for a packet received from yaAGC.
	packetSize = 4
	inputBuffer = bytearray(packetSize)
	leftToRead = packetSize
	view = memoryview(inputBuffer)
	cannedRsetCount = 0
	
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
		if args.playback:
			global currentPlaybackIndex, playbackEvents, lastPlaybackTime
			# Get data from playback file.
			if currentPlaybackIndex < len(playbackEvents):
				#print(currentPlaybackIndex)
				timeNow = time.time()
				desiredTime = lastPlaybackTime + playbackEvents[currentPlaybackIndex][1] / 1000.0
				if timeNow >= desiredTime:
					lastPlaybackTime = desiredTime
					#print(playbackEvents[currentPlaybackIndex])
					if playbackEvents[currentPlaybackIndex][0]:
						# Channels 015 and 032 are AGC INPUT channels (hence
						# are outputs from the DSKY rather than inputs to it).
						# They indicate keypresses.  We won't do anything with
						# them other than possibly to flash backlights on the
						# associated keys.
						channel = playbackEvents[currentPlaybackIndex][2]
						value = playbackEvents[currentPlaybackIndex][3]
						if channel == 0o15:
							#print("Playback keystroke event " + oct(channel) + " " + oct(value))
							name = keyNames[value & 0o37]
							if name == "RSET KEY":
								cannedRsetCount += 1
								if cannedRsetCount >= 5:
									echoOn(True)
									timersStop()
									root.destroy()
									shutdownGPIO()
									os.system("xset r on &")
									return	
							else:
								cannedRsetCount == 0
							updateLampStatusesAndLamps(name, False)
							t = threading.Timer(0.32, updateLampStatusesAndLamps, (name, True))
							t.start()
						elif channel == 0o32:
							if (value & 0o20000) != 0:
								updateLampStatusesAndLamps("PRO KEY", True)
							else:
								updateLampStatusesAndLamps("PRO KEY", False)
						else:
							outputFromAGC(channel, value)
					else:
						sys.stderr.write("Command = \"" + playbackEvents[currentPlaybackIndex][2] + "\"\n")
						os.system(playbackEvents[currentPlaybackIndex][2] + ' &')
					currentPlaybackIndex += 1
					didSomething = True
		else:
			# Get input from socket to AGC.
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
			timersStop()
			screenshot(homeDir + "/lastscrn.png")
			root.destroy()
			shutdownGPIO()
			os.system("xset r on &")
			return
		for i in range(0, len(externalData)):
			packetize(externalData[i])
			didSomething = True
		if debugKey != "":
			print("GUI key = " + debugKey)
			debugKey = ""

eventLoopThread = threading.Thread(target=eventLoop)
eventLoopThread.start()

root.mainloop()

shutdownGPIO()
os._exit(0)



