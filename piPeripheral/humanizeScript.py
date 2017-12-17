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
# References:	Luminary 99 program listing
#		Luminary 210 program listing
#		Delco Apollo 16 manual
# Mod history:	2017-12-15 RSB	Wrote, beginning from bits and pieces
#				of convertNasspLog.py and piDSKY2.py.
#		2017-12-17 RSB	All of the input channels are going to
#				be added to the NASSP logs, so I've
#				fleshed this program out with the input
#				channels, as well as bunch of "fictitious"
#				i/o channels I previously ignored.
#
# Where the function of a bit is different for CM vs LM, they're listed
# as
#		CM function / LM function
#
# although of one of those functions is none (spare, or reserved, or whatever)
# it's simply omitted, and so you end up with just
#
#		CM function
#		     or
#		LM function
#
# as if it's the same for both, even though it really isn't.
# Similarly, a function shows up even if some missions didn't have it.
# So in other words, what's actually listed is every possible interpretation of
# the signal, as opposed to just the description that's appropriate to the
# specific mission that the playback script is for.  We don't actually
# have enough documentation to separate it out well mission by mission, even
# if I was so inclined to do that.

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
	print("Time %.3f: Channel 0%03o = 0%05o, %s" % (time, channel, value, name))

# Handle a single channel as a blob, but bypass repetition check; 
# i.e., always report even if duplicate.  This is for the "fictitious"
# i/o channels that bunch together groups of pulse counts.
def parseAndDisplayChannelGeneralAlways(time, channel, value, name):
	print("Time %.3f: Channel 0%03o = 0%05o, %s" % (time, channel, value, name))

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
		print("Time %.3f: Channel 0%03o = 0%05o, %s %s" % (time, channel, value, bitName, action))

def parseAndDisplayBitFieldsAlways(time, channel, value, bitNames, inverted):
	for bit in range(1, 16):
		bitName = bitNames[bit]
		if bitName == "none":
			continue
		bitValue = (value & (1 << (bit-1))) != 0
		if inverted:
			bitValue = not bitValue
		if bitValue:
			action = "on"
		else:
			action = "off"
		print("Time %.3f: Channel 0%03o = 0%05o, %s %s" % (time, channel, value, bitName, action))

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
	print("Time %.3f: Channel 0%03o = 0%05o, %s -> digit %s" % (time, channel, value, positionValue, positionName))

# Handle display of a sign.
def displaySign(time, channel, value, signMask, positionName):
	fullPositionName = oct(channel) + " " + positionName
	signMask &= 0o1
	if (fullPositionName in lastFields) and (lastFields[fullPositionName] == signMask):
		return
	lastFields[fullPositionName] = signMask
	print("Time %.3f: Channel 0%03o = 0%05o, %i -> sign %s" % (time, channel, value, signMask, positionName))

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
		print("Time %.3f: Channel 0%03o = 0%05o" % (time, channel, value))

def parseAndDisplayChannel5(time, channel, value):
	bitNames = [
		"none",
		"RCS C-3/1-3 +X/+P  / B4U +V/-X", 
		"RCS C-4/2-4 -X/-P  / A4D -V/+X", 
		"RCS A-3/2-3 -X/+P  / A3U +U/-X", 
		"RCS A-4/1-4 +X/-P  / B3D -U/+X", 
		"RCS D-3/2-5 +X/+Yw / B2U -V/-X", 
		"RCS D-4/1-6 -X/-Yw / A2D +V/+X", 
		"RCS B-3/1-5 -X/+Yw / A1U -U/-X", 
		"RCS B-4/2-6 +X/-Yw / B1D +U/+X", 
		"none", 
		"none",
		"none", 
		"none", 
		"none", 
		"none", 
		"none"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)

def parseAndDisplayChannel6(time, channel, value):
	bitNames = [
		"RCS B-1/1-1 +Z/+R / B3A +P/+Z", 
		"RCS B-2/1-2 -Z/-R / B4F -P/-Z", 
		"RCS D-1/2-1 -Z/+R / A1F +P/-Z", 
		"RCS D-2/2-2 +Z/-R / A2A -P/+Z", 
		"RCS A-1     +Y/+R / B2L +P/+Y", 
		"RCS A-2     -Y/-R / A3R -P/-Y", 
		"RCS C-1     -R/+R / A4R +P/-Y", 
		"RCS C-2     +Y/-R / B1L -P/+Y", 
		"none", 
		"none",
		"none", 
		"none", 
		"none", 
		"none", 
		"none"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)

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
		"TVC ENABLE / DISPLAY INERTIAL DATA", 
		"ENABLE SIVB TAKEOVER / -PITCH GIMBAL TRIM (BELL MOTION) DESCENT ENGINE", 
		"ZERO OPTICS / +PITCH GIMBAL TRIM (BELL MOTION) DESCENT ENGINE",
		"DISENGAGE OPTICS DAC / -ROLL GIMBAL TRIM (BELL MOTION) DESCENT ENGINE", 
		"+ROLL GIMBAL TRIM (BELL MOTION) DESCENT ENGINE", 
		"SIVB INJECTION SEQUENCE START / LR POSITION 2 COMMAND", 
		"SIVB CUTOFF / ENABLE RENDESVOUS RADAR LOCK-ON; AUTO ANGLE TRACK'G", 
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
		"INHIBIT UPLINK, ENABLE CROSSLINK", 
		"BLOCK INPUTS TO UPLINK CELL",
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
	print("Time %.3f: Channel 0%03o = 0%05o, Main DSKY %s key pressed" % (time, channel, value, keyNames[value & 0o37]))

def parseAndDisplayChannel16(time, channel, value):
	bitNames = [
		"none",
		"none", 
		"none", 
		"OPTICS X-AXIS MARK SIGNAL FOR ALIGN OPTICAL TSCOPE", 
		"OPTICS Y-AXIS MARK SIGNAL FOR AOT", 
		"OPTICS MARK REJECT SIGNAL", 
		"MARK BUTTON / DESCENT+ ; CREW DESIRED SLOWING RATE OF DESCENT",
		"MARK REJECT BUTTON / DESCENT- ; CREW DESIRED SPEEDING UP RATE OF D'CENT", 
		"none", 
		"none", 
		"none", 
		"none",
		"none", 
		"none", 
		"none", 
		"none" 
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)
	keyNames = [ 
		"none", "1", "2", "3", "4", 
		"5", "6", "7", "8", "9", 
		"none", "none", "none", "none", "none", 
		"none", "0", "VERB", "RSET", "none", 
		"none", "none", "none", "none", "none", 
		"KEY REL", "+", "-", "ENTR", "none",
		"CLR", "NOUN"
	]
	print("Time %.3f: Channel 0%03o = 0%05o, Nav DSKY %s key pressed" % (time, channel, value, keyNames[value & 0o37]))


def parseAndDisplayChannel30(time, channel, value):
	bitNames = [
		"none",
		"ULLAGE THRUST PRESENT / ABORT WITH DESCENT STAGE", 
		"CM/SM SEPARATE / DESCENT STAGE ATTACHED", 
		"SPS READY / ENGINE ARMED SIGNAL", 
		"SIVB SEPARATE ABORT /ABORT WITH ASCENT ENGINE STAGE", 
		"LIFTOFF / AUTO THROTTLE; COMPUTER CONTROL OF DESCENT ENGINE", 
		"GUIDANCE REFERENCE RELEASE / DISPLAY INERTIAL DATA", 
		"OPTICS CDU FAIL / RR CDU FAIL", 
		"none", 
		"IMU OPERATE WITH NO MALFUNCTION", 
		"S/C CONTROL OF SATURN / LM COMPUTER (NOT AGS) HAS CONTROL OF LM",
		"IMU CAGE COMMAND TO DRIVE IMU GIMBAL ANGLES TO 0", 
		"IMU CDU FAIL (MALFUNCTION OF IMU CDU,S)", 
		"IMU FAIL (MALFUNCTION OF IMU STABILIZATION LOOPS)", 
		"ISS TURN ON REQUESTED", 
		"TEMPERATURE OF STABLE MEMBER WITHIN DESIGN LIMITS"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, True)

def parseAndDisplayChannel31(time, channel, value):
	# Note that for conciseness, I've had to modify the descriptions of these 
	# events somewhat in relation to the ones in the AGC code comments.
	bitNames = [
		"none",
		"ROTATION (BY RHC) COMMANDED IN POSITIVE PITCH DIRECTION AND ELEVATION", 
		"ROTATION (BY RHC) COMMANDED IN NEGATIVE PITCH DIRECTION AND ELEVATION", 
		"ROTATION (BY RHC) COMMANDED IN POSITIVE YAW DIRECTION", 
		"ROTATION (BY RHC) COMMANDED IN NEGATIVE YAW DIRECTION", 
		"ROTATION (BY RHC) COMMANDED IN POSITIVE ROLL DIRECTION AND AZIMUTH", 
		"ROTATION (BY RHC) COMMANDED IN NEGATIVE ROLL DIRECTION AND AZIMUTH", 
		"TRANSLATION IN +X DIRECTION COMMANDED BY THC", 
		"TRANSLATION IN -X DIRECTION COMMANDED BY THC", 
		"TRANSLATION IN +Y DIRECTION COMMANDED BY THC", 
		"TRANSLATION IN -Y DIRECTION COMMANDED BY THC",
		"TRANSLATION IN +Z DIRECTION COMMANDED BY THC", 
		"TRANSLATION IN -Z DIRECTION COMMANDED BY THC", 
		"ATTITUDE HOLD MODE ON SCS MODE CONTROL SWITCH", 
		"FREE FUNCTION / AUTO STABILIZATION OF ATTITUDE ON SCS MODE SWITCH", 
		"G&N AUTOPILOT CONTROL / ATTITUDE CONTROL OUT OF DETENT (RHC NOT IN NEUTRAL)"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, True)

def parseAndDisplayChannel32(time, channel, value):
	bitNames = [
		"none",
		"+PITCH MINIMUM IMPULSE / THRUSTERS 2 & 4 DISABLED BY CREW", 
		"-PITCH MINIMUM IMPULSE / THRUSTERS 5 & 8 DISABLED BY CREW", 
		"+YAW MINIMUM IMPULSE / THRUSTERS 1 & 3 DISABLED BY CREW", 
		"-YAW MINIMUM IMPULSE / -YAW MINIMUM IMPULSE / THRUSTERS 6 & 7 DISABLED BY CREW", 
		"+ROLL MINIMUM IMPULSE / THRUSTERS 14 & 16 DISABLED BY CREW", 
		"-ROLL MINIMUM IMPULSE / THRUSTERS 13 & 15 DISABLED BY CREW", 
		"THRUSTERS 9 & 12 DISABLED BY CREW", 
		"THRUSTERS 10 & 11 DISABLED BY CREW", 
		"DESCENT ENGINE GIMBALS DISABLED BY CREW", 
		"APPARENT DESCENT ENGINE GIMBAL FAILURE",
		"LM ATTACHED", 
		"none", 
		"none", 
		"PROCEED KEY IS DEPRESSED", 
		"none"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, True)

def parseAndDisplayChannel33(time, channel, value):
	bitNames = [
		"none",
		"none", 
		"RANGE UNIT DATA GOOD / RR AUTO-POWER ON", 
		"RR RANGE LOW SCALE", 
		"ZERO OPTICS / RR DATA GOOD", 
		"CMC CONTROL / LR RANGE DATA GOOD", 
		"LR POS1", 
		"LR POS2", 
		"LR VEL DATA GOOD", 
		"LR RANGE LOW SCALE", 
		"BLOCK UPLINK INPUT",
		"UPLINK TOO FAST", 
		"DOWNLINK TOO FAST", 
		"PIPA FAIL", 
		"AGC WARNING / WARNING OF REPEATED ALARMS: RESTART,COUNTER FAIL, VOLTAGE FAIL,AND SCALAR DOUBLE", 
		"AGC OSCILLATOR ALARM / LGC OSCILLATOR STOPPED"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, True)

def parseAndDisplayChannel77(time, channel, value):
	bitNames = [
		"none",
		"PARITY FAIL (E or F)", 
		"PARITY FAIL (E MEMORY)", 
		"TC TRAP", 
		"RUPT LOCK", 
		"NIGHTWATCHMAN", 
		"VOLTAGE FAIL", 
		"COUNTER FAIL", 
		"SCALAR FAIL", 
		"SCALAR DOUBLE FREQUENCY ALARM", 
		"none",
		"none", 
		"none", 
		"none", 
		"none", 
		"none"
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, False)

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

def parseAndDisplayChannel177(time, channel, value):
	bitNames = [
		"none",
		"none", 
		"none", 
		"none", 
		"none", 
		"none", 
		"none", 
		"none", 
		"none", 
		"none",
		"none", 
		"none", 
		"GYRO ENABLE POWER FOR PULSES", 
		"GYRO SELECT B", 
		"GYRO SELECT A", 
		"GYRO TORQUING COMMAND IN NEGATIVE DIRECTION", 
	]
	parseAndDisplayBitFields(time, channel, value, bitNames, True)
	print("Time %.3f: Channel 0%03o = 0%05o, IMU fine alignment gyro pulses: %i" % (time, channel, value, value & 0o3777))

def parseAndDisplayCDUx(time, channel, value, name):
	if (value & 0o40000) == 0:
		sign = "+"
	else:
		sign = "-"
	print("Time %.3f: Channel 0%03o = 0%05o, %s pulses: %s%i" % (time, channel, value, name, sign, value & 0o37777))

def parseAndDisplayUplink(time, channel, value):
	field1 = (value >> 10) & 0o37
	field2 = (value >> 5) & 0o37
	field3 = value & 0o37
	print("Time %.3f: Channel 0%03o = 0%05o, UPLINK: %02o %02o %02o" % (time, channel, value, field1, field2, field3))

def parseAndDisplayDownlink(time, channel, value, name):
	print("Time %.3f: Channel 0%03o = 0%05o, %s: 0%05o" % (time, channel, value, name, value))

def parseAndDisplayOPTx(time, channel, value, name):
	print("Time %.3f: Channel 0%03o = 0%05o, %s pulses: %i" % (time, channel, value, name, value))

def parseAndDisplayRHCx(time, channel, value, name):
	if (value & 0o40000) != 0:
		value2 = -(value ^ 0o77777)
	else:
		value2 = value
	print("Time %.3f: Channel 0%03o = 0%05o, %s pulses: %i" % (time, channel, value, name, value2))

# Entry point for the various parseAndDisplayChannelXX() functions specific
# to particular i/o channels.
def parseAndDisplayChannel(time, channel, value):
	if channel == 0o5:
		parseAndDisplayChannel5(time, channel, value)
	elif channel == 0o6:
		parseAndDisplayChannel6(time, channel, value)
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
	elif channel == 0o16:
		parseAndDisplayChannel16(time, channel, value)
	elif channel == 0o30:
		parseAndDisplayChannel30(time, channel, value)
	elif channel == 0o31:
		parseAndDisplayChannel31(time, channel, value)
	elif channel == 0o32:
		parseAndDisplayChannel32(time, channel, value)
	elif channel == 0o33:
		parseAndDisplayChannel33(time, channel, value)
	elif channel == 0o34:
		parseAndDisplayDownlink(time, channel, value, "DOWNLINK 1")
	elif channel == 0o35:
		parseAndDisplayDownlink(time, channel, value, "DOWNLINK 2")
	elif channel == 0o77:
		parseAndDisplayChannel77(time, channel, value)
	elif channel == 0o177:
		parseAndDisplayChannel177(time, channel, value)
	elif channel == 0o176:
		parseAndDisplayCDUx(time, channel, value, "CDUZ")
	elif channel == 0o175:
		parseAndDisplayCDUx(time, channel, value, "CDUY")
	elif channel == 0o174:
		parseAndDisplayCDUx(time, channel, value, "CDUX")
	elif channel == 0o173:
		parseAndDisplayUplink(time, channel, value)
	elif channel == 0o172:
		parseAndDisplayOPTx(time, channel, value, "OPTX")
	elif channel == 0o172:
		parseAndDisplayOPTx(time, channel, value, "OPTY")
	elif channel == 0o171:
		parseAndDisplayRHCx(time, channel, value, "RHC ROLL DISPLACEMENT")
	elif channel == 0o167:
		parseAndDisplayRHCx(time, channel, value, "RHC YAW DISPLACEMENT")
	elif channel == 0o166:
		parseAndDisplayRHCx(time, channel, value, "RHC PITCH DISPLACEMENT")
	elif channel == 0o163:
		parseAndDisplayChannel163(time, channel, value)
	else:
		parseAndDisplayChannelGeneralAlways(time, channel, value, "UNCATEGORIZED")

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


