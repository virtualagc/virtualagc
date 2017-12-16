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
# Filename: 	humanizeScript.py
# Purpose:	This program can read the AGC i/o-channel logs/scripts
#		created by piDSKY2.py/yaDSKY2/convertNasspLog.py and
#		used by piDSKY2.py/yaDSKY2, and turn them into a nice
#		human-readable form.  The usage scenario is to take
#		logs created by somebody else --- and particularly those
#		derived from NASSP --- and turn them into something
#		understandable and analyzable.
# Mod history:	2017-12-15 RSB	Wrote, beginning from bits and pieces
#				of convertNasspLog.py and piDSKY2.py.

import sys

# Use this dictionary to keep track of the last values from the i/o channels
# encountered in the input log/script, and use that info to eliminate repetitions.  
# Channel 010 is a bit of a special case, because we track the repetitions not 
# by the channel value, but additionally by the relay number specified in the
# value.
lastValues = {}

# Use *this* dictionary to keep track of how the individual fields in i/o channels
# change, so as to simplify the displayed reports to the extent possible.
lastFields = {}

# Handle a single channel as a blob
def parseAndDisplayChannelGeneral(time, channel, value, name):
	fullPositionName = oct(channel) + " " + name
	if (fullPositionName in lastFields) and (lastFields[fullPositionName] == value):
		return
	lastFields[fullPositionName] = value
	print("Time %.3f: Channel 0%o = 0%o, %s" % (time, channel, value, name))

# For channels consisting entirely of single-bit fields.  The parameter
# bitNames[] is a 16-entry list (position 0 being unused) of strings.  
# Unused bits are indicated by entries with the value "none".
def parseAndDisplayBitFields(time, channel, value, bitNames, inverted):
	for bit in range(1, 16):
		bitName = bitNames[bit]
		if bitName == "none":
			continue
		fullBitName = oct(channel) + " " + bitName
		bitValue = (value & (1 << (bit-1))) != 0
		if inverted:
			bitValue = not bitValue
		if (fullBitName in lastFields) and (lastFields[fullBitName] == bitValue):
			continue
		lastFields[fullBitName] = bitValue
		if bitValue:
			action = "on"
		else:
			action = "off"
		print("Time %.3f: Channel 0%o = 0%o, %s %s" % (time, channel, value, bitName, action))

# Handle display of a single digit.
def displayDigit(time, channel, value, digitMask, positionName):
	numberPatterns = [
		"blank", "nonsense", "nonsense", "1", "nonsense",
		"nonsense", "nonsense", "nonsense", "nonsense", "nonsense",
		"nonsense", "nonsense", "nonsense", "nonsense", "nonsense",
		"4", "nonsense", "nonsense", "nonsense", "7",
		"nonsense", "0", "nonsense", "nonsense", "nonsense",
		"2", "nonsense", "3", "6", "8",
		"5", "9"
	]
	fullPositionName = oct(channel) + " " + positionName
	positionValue = numberPatterns[digitMask & 0o37]
	if (fullPositionName in lastFields) and (lastFields[fullPositionName] == positionValue):
		return
	lastFields[fullPositionName] = positionValue
	print("Time %.3f: Channel 0%o = 0%o, %s -> digit %s" % (time, channel, value, positionValue, positionName))

# Handle display of a sign.
def displaySign(time, channel, value, signMask, positionName):
	fullPositionName = oct(channel) + " " + positionName
	signMask &= 0o1
	if (fullPositionName in lastFields) and (lastFields[fullPositionName] == signMask):
		return
	lastFields[fullPositionName] = signMask
	print("Time %.3f: Channel 0%o = 0%o, %i -> sign %s" % (time, channel, value, signMask, positionName))

def parseAndDisplayChannel10(time, channel, value):
	relay = (value >> 11) & 0o17
	b = (value >> 10) & 0o1
	ccccc = (value >> 5) & 0o37
	ddddd = value & 0o37
	if relay == 12:
		bitNames = [
			"none",
			"none", 
			"none",
			"LIGHT VEL LAMP", 
			"LIGHT NO ATT LAMP", 
			"LIGHT ALT LAMP", 
			"LIGHT GIMBAL LOCK LAMP", 
			"none", 
			"LIGHT TRACKER LAMP", 
			"LIGHT PROG LAMP", 
			"none", 
			"none",
			"none", 
			"none", 
			"none", 
			"none"
		]
		parseAndDisplayBitFields(time, channel, value, bitNames, False)
	elif relay == 11:
		displayDigit(time, channel, value, ccccc, "M1")
		displayDigit(time, channel, value, ddddd, "M2")
	elif relay == 10:
		displayDigit(time, channel, value, ccccc, "V1")
		displayDigit(time, channel, value, ddddd, "V2")
	elif relay == 9:
		displayDigit(time, channel, value, ccccc, "N1")
		displayDigit(time, channel, value, ddddd, "N2")
	elif relay == 8:
		displayDigit(time, channel, value, ddddd, "11")
	elif relay == 7:
		displaySign(time, channel, value, b, "1+")
		displayDigit(time, channel, value, ccccc, "12")
		displayDigit(time, channel, value, ddddd, "13")
	elif relay == 6:
		displaySign(time, channel, value, b, "1-")
		displayDigit(time, channel, value, ccccc, "14")
		displayDigit(time, channel, value, ddddd, "15")
	elif relay == 5:
		displaySign(time, channel, value, b, "2+")
		displayDigit(time, channel, value, ccccc, "21")
		displayDigit(time, channel, value, ddddd, "22")
	elif relay == 4:
		displaySign(time, channel, value, b, "2-")
		displayDigit(time, channel, value, ccccc, "23")
		displayDigit(time, channel, value, ddddd, "24")
	elif relay == 3:
		displayDigit(time, channel, value, ccccc, "25")
		displayDigit(time, channel, value, ddddd, "31")
	elif relay == 2:
		displaySign(time, channel, value, b, "3+")
		displayDigit(time, channel, value, ccccc, "32")
		displayDigit(time, channel, value, ddddd, "33")
	elif relay == 1:
		displaySign(time, channel, value, b, "3-")
		displayDigit(time, channel, value, ccccc, "34")
		displayDigit(time, channel, value, ddddd, "35")
	else:
		print("Time %.3f: Channel 0%o = 0%o" % (time, channel, value))

def parseAndDisplayChannel11(time, channel, value):
	bitNames = [
		"none",
		"ISS WARNING", 
		"LIGHT COMPUTER ACTIVITY LAMP", 
		"LIGHT UPLINK ACTIVITY LAMP", 
		"LIGHT TEMP CAUTION LAMP", 
		"LIGHT KEYBOARD RELEASE LAMP", 
		"FLASH VERB AND NOUN LAMPS", 
		"LIGHT OPERATOR ERROR LAMP", 
		"none", 
		"TEST CONNECTOR OUTBIT", 
		"CAUTION RESET",
		"none", 
		"none", 
		"ENGINE ON", 
		"ENGINE OFF", 
		"none"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)

def parseAndDisplayChannel12(time, channel, value):
	bitNames = [
		"none",
		"ZERO RR CDU; CDU'S GIVE RRADAR INFORMATION FOR LM", 
		"ENABLE CDU RADAR ERROR COUNTERS", 
		"none", 
		"COARSE ALIGN ENABLE OF IMU", 
		"ZERO IMU CDU'S", 
		"ENABLE IMU ERROR COUNTER, CDU ERROR COUNTER", 
		"none", 
		"DISPLAY INERTIAL DATA", 
		"-PITCH GIMBAL TRIM (BELL MOTION) DESCENT ENGINE", 
		"+PITCH GIMBAL TRIM (BELL MOTION) DESCENT ENGINE",
		"-ROLL GIMBAL TRIM (BELL MOTION) DESCENT ENGINE", 
		"+ROLL GIMBAL TRIM (BELL MOTION) DESCENT ENGINE", 
		"LR POSITION 2 COMMAND", 
		"ENABLE RENDESVOUS RADAR LOCK-ON; AUTO ANGLE TRACK'G", 
		"ISS TURN ON DELAY COMPLETE"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)

def parseAndDisplayChannel13(time, channel, value):
	bitNames = [
		"none",
		"RADAR C", 
		"RADAR B", 
		"RADAR A", 
		"RADAR ACTIVITY", 
		"none", 
		"none",
		"DOWNLINK TELEMETRY WORD ORDER CODE BIT", 
		"RHC COUNTER ENABLE", 
		"START RHC READ INTO COUNTERS IF RHC COUNTER ENABLE", 
		"TEST ALARMS, TEST DSKY LIGHTS", 
		"ENABLE STANDBY",
		"RESET TRAP 31-A", 
		"RESET TRAP 31-B", 
		"RESET TRAP 32", 
		"ENABLE T6 RUPT" 
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)

def parseAndDisplayChannel14(time, channel, value):
	bitNames = [
		"none",
		"OUTLINK ACTIVITY", 
		"ALTITUDE RATE OR ALTITUDE SELECTOR", 
		"ALTITUDE METER ACTIVITY", 
		"THRUST DRIVE ACTIVITY FOR DESCENT ENGINE", 
		"none", 
		"GYRO ENABLE POWER FOR PULSES", 
		"GYRO SELECT B", 
		"GYRO SELECT A", 
		"GYRO TORQUING COMMAND IN NEGATIVE DIRECTION", 
		"GYRO ACTIVITY",
		"DRIVE CDU S", 
		"DRIVE CDU T", 
		"DRIVE CDU Z", 
		"DRIVE CDU Y", 
		"DRIVE CDU X"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)

def parseAndDisplayChannel15(time, channel, value):
	# No need to check for repetitions on this one, I think.
	keyNames = [ 
		"none", "1", "2", "3", "4", 
		"5", "6", "7", "8", "9", 
		"none", "none", "none", "none", "none", 
		"none", "0", "VERB", "RSET", "none", 
		"none", "none", "none", "none", "none", 
		"KEY REL", "+", "-", "ENTR", "none",
		"CLR", "NOUN"
	]
	print("Time %.3f: Channel 0%o = 0%o, DSKY %s key pressed" % (time, channel, value, keyNames[value & 0o37]))

def parseAndDisplayChannel32(time, channel, value):
	bitNames = [
		"none",
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"THRUSTERS 2 & 4 DISABLED BY CREW", 
		"DESCENT ENGINE GIMBALS DISABLED BY CREW", 
		"APPARENT DESCENT ENGINE GIMBAL FAILURE",
		"none", 
		"none", 
		"none", 
		"PROCEED KEY IS DEPRESSED", 
		"none"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, True)

def parseAndDisplayChannel163(time, channel, value):
	bitNames = [
		"none",
		"DSKY AGC WARNING THRESHOLD", 
		"none", 
		"none", 
		"none", 
		"DSKY KEY REL", 
		"DSKY VN FLASH", 
		"DSKY OPR ERR", 
		"DSKY RESTART", 
		"DSKY STBY",
		"DSKY EL OFF", 
		"none", 
		"none", 
		"none", 
		"none",
		"none"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, True)

# Entry point for the various parseAndDisplayChannelXX() functions specific
# to particular i/o channels.
def parseAndDisplayChannel(time, channel, value):
	if channel == 0o5:
		parseAndDisplayChannelGeneral(time, channel, value, "PYJETS")
	elif channel == 0o6:
		parseAndDisplayChannelGeneral(time, channel, value, "ROLLJETS")
	elif channel == 0o10:
		parseAndDisplayChannel10(time, channel, value)
	elif channel == 0o11:
		parseAndDisplayChannel11(time, channel, value)
	elif channel == 0o12:
		parseAndDisplayChannel12(time, channel, value)
	elif channel == 0o13:
		parseAndDisplayChannel13(time, channel, value)
	elif channel == 0o14:
		parseAndDisplayChannel14(time, channel, value)
	elif channel == 0o15:
		parseAndDisplayChannel15(time, channel, value)
	elif channel == 0o32:
		parseAndDisplayChannel32(time, channel, value)
	elif channel == 0o34 or channel == 0o35:
		parseAndDisplayChannelGeneral(time, channel, value, "DOWNLINK")
	elif channel == 0o163:
		parseAndDisplayChannel163(time, channel, value)
	else:
		parseAndDisplayChannelGeneral(time, channel, value, "UNCATEGORIZED")

# Process contents lines of stdin.
firstPass = True
currentTimeSeconds = 0.0
inputLines = (line.strip().split() for line in sys.stdin)

for line in inputLines:

	# Parse fields into normalized form, which is 3 variables:
	# floating point absolute time, in seconds, integer channel number,
	# and integer channel value.
	inputTime = float(line[0])
	if firstPass:
		firstPass = False
	currentTimeSeconds += inputTime / 1000.0
	channel = int(line[1], 8)
	value = int(line[2], 8)
	
	# Eliminate repetitions ... i.e., channel values which are reported
	# but which aren't actual changes.
	if channel == 0o10:
		channelName = str(channel) + "-" + str(value >> 11)
		channelValue = value & 0o3777
	elif channel == 0o32:
		channelName = str(channel)
		channelValue = value & 0o20000
	else:
		channelName = str(channel)
		channelValue = value
	if (channelName in lastValues) and (lastValues[channelName] == channelValue):
		continue
	lastValues[channelName] = channelValue
	
	# Now turn the normalized forms into human readable forms.
	parseAndDisplayChannel(currentTimeSeconds, channel, value)


