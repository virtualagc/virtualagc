#!/usr/bin/python3
# Converts an AGC-output-port log from NASSP to a playback script
# for piDSKY2.py's --playback option.  The former has the format
#
#	absoluteTimestampSeconds octalChannelNumber octalChannelValue
#
# while the latter has the format
#
#	deltaTimeBetweenEventsMilliseconds octalChannelNumber octalChannelValue
#
# The point of the conversion is not merely to change the time references,
# but also to filter out output channels we don't need and to eliminate
# repetitions, so as to get the playback script as minimal as possible.
# However, the NASSP format is a bit more convenient as a starting point,
# since the absolute times make it easier to filter out channels we don't
# want and to sync up with (say) a video of the mission segment.

import sys

# Tests if prog, verb, noun parameters are formed correctly.
def test2(array):
	if len(array) != 2:
		return False
	for i in range(0, 2):
		if array[i] != " " and (array[i] < "0" or array[i] > "9"):
			return False
	return True

# Tests if r1, r2, r3 parameters are formed properly.
def test6(array):
	if len(array) != 6:
		return False
	if array[0] != " " and array[0] != "+" and array[0] != "-":
		return False
	for i in range(1, 6):
		if array[i] != " " and (array[i] < "0" or array[i] > "9"):
			return False
	return True

# Get the list of channel numbers.
if len(sys.argv) < 12:
	print("This program filters and reformats a NASSP log of AGC i/o-channel")
	print("activity, producing a playback script for the piDSKY2 program.")
	print("Usage:")
	print("\tconvertNasspLog.py value11 value13 value163 prog verb noun r1 r2 r3 \\")
	print("\t                   relay12 channel1 channel2 channel3 ... \\")
	print("\t                   <nasspLogFile >playbackScriptFile")
	print("The AGC channel numbers are in octal, although the you can also use the")
	print("words 'dsky' or 'all' as aliases for just the DSKY channels (10, 11, 13, 15, 32")
	print("and 163) or to accept all of the channels.  The various items preceding")
	print("the channel numbers are what should initially be displayed on the DSKY")
	print("at the start of the playback, just in case the playback script doesn't")
	print("instantly set everything the way one might want.  The value11, value13,")
	print("value163, and relay12 parameters are initial values in octal for channels")
	print("011, 013, 0163, and 010.  The value for channel 010 is a bit special, in")
	print("that it applies only to relay 12, and thus affects only indicator lamps")
	print("rather than numerical displays. The prog, verb, noun, r1, r2, and r3 parameters")
	print("are the initial strings to show in the corresponding numerical registers,")
	print("and should be limited to appropriate combinations of digits, signs, and")
	print("blanks.  If there are blanks, then the parameters should be quoted.")
	print("They should also be the proper number of characters long.  For example,")
	print("verb should be 2 characters and r2 should be 6 characters.")
	sys.exit(1)
value11 = int(sys.argv[1], 8)
value13 = int(sys.argv[2], 8)
value163 = int(sys.argv[3], 8)
prog = list(sys.argv[4])
if not test2(prog):
	print("Badly formed PROG parameter.")
	sys.exit(1)
verb = list(sys.argv[5])
if not test2(verb):
	print("Badly formed VERB parameter.")
	sys.exit(1)
noun = list(sys.argv[6])
if not test2(noun):
	print("Badly formed NOUN parameter.")
	sys.exit(1)
r1 = list(sys.argv[7])
if not test6(r1):
	print("Badly formed R1 parameter.")
	sys.exit(1)
r2 = list(sys.argv[8])
if not test6(r2):
	print("Badly formed R2 parameter.")
	sys.exit(1)
r3 = list(sys.argv[9])
if not test6(r3):
	print("Badly formed R3 parameter.")
	sys.exit(1)
relay12 = int(sys.argv[10], 8)
channels = []
for i in range(11, len(sys.argv)):
	if sys.argv[i] == "dsky":
		for c in [ 0o10, 0o11, 0o13, 0o15, 0o32, 0o163 ]:
			if not (c in channels):
				channels.append(c)
	elif sys.argv[i] == "all":
		for c in range(0o0, 0o177):
			if not (c in channels):
				channels.append(c)
	else:
		channels.append(int(sys.argv[i], 8))

# Display initial conditions on DSKY.
numberPatterns = {
	" " : 0,
	"0" : 21,
	"1" : 3,
	"2" : 25,
	"3" : 27,
	"4" : 15,
	"5" : 30,
	"6" : 28,
	"7" : 19,
	"8" : 29,
	"9" : 31
}
print("%d %o %o" % (0, 0o11, value11))
print("%d %o %o" % (0, 0o13, value13))
print("%d %o %o" % (0, 0o163, value163))
print("%d %o %o" % (0, 0o10, (12 << 11) + (relay12 & 0o3777)))
print("%d %o %o" % (0, 0o10, (11 << 11) + (numberPatterns[prog[0]] << 5) + numberPatterns[prog[1]]))
print("%d %o %o" % (0, 0o10, (10 << 11) + (numberPatterns[verb[0]] << 5) + numberPatterns[verb[1]]))
print("%d %o %o" % (0, 0o10, (9 << 11) + (numberPatterns[noun[0]] << 5) + numberPatterns[noun[1]]))
print("%d %o %o" % (0, 0o10, (8 << 11) + numberPatterns[r1[1]]))
if r1[0] == "+":
	sign = 1 << 10
else:
	sign = 0
print("%d %o %o" % (0, 0o10, (7 << 11) + sign + (numberPatterns[r1[2]] << 5) + numberPatterns[r1[3]]))
if r1[0] == "-":
	sign = 1 << 10
else:
	sign = 0
print("%d %o %o" % (0, 0o10, (6 << 11) + sign + (numberPatterns[r1[4]] << 5) + numberPatterns[r1[5]]))
if r2[0] == "+":
	sign = 1 << 10
else:
	sign = 0
print("%d %o %o" % (0, 0o10, (5 << 11) + sign + (numberPatterns[r2[1]] << 5) + numberPatterns[r2[2]]))
if r2[0] == "-":
	sign = 1 << 10
else:
	sign = 0
print("%d %o %o" % (0, 0o10, (4 << 11) + sign + (numberPatterns[r2[3]] << 5) + numberPatterns[r2[4]]))
print("%d %o %o" % (0, 0o10, (3 << 11) + (numberPatterns[r2[5]] << 5) + numberPatterns[r3[1]]))
if r3[0] == "+":
	sign = 1 << 10
else:
	sign = 0
print("%d %o %o" % (0, 0o10, (2 << 11) + sign + (numberPatterns[r3[2]] << 5) + numberPatterns[r3[3]]))
if r3[0] == "-":
	sign = 1 << 10
else:
	sign = 0
print("%d %o %o" % (0, 0o10, (1 << 11) + sign + (numberPatterns[r3[4]] << 5) + numberPatterns[r3[5]]))

# Use this dictionary to keep track of the last values from the output channels
# encountered, and use that info to eliminate repetitions.  Channel 010 is a 
# bit of a special case, because we track the repetitions not by the channel
# value, but additionally by the relay number.
lastValues = {}

# Process contents lines of stdin.
lastAbsoluteTime = -1
inputLines = (line.strip().split() for line in sys.stdin)
for line in inputLines:
	# Parse fields into normalized form.
	absoluteTime = float(line[0])
	if lastAbsoluteTime == -1:
		lastAbsoluteTime = absoluteTime
	channel = int(line[1], 8)
	value = int(line[2], 8)
	# Eliminate channels not specified on command line.
	if not (channel in channels):
		continue
	# Eliminate repetitions.
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
	# Convert absolute timestamps to differential times and output.
	differentialTime = round((absoluteTime - lastAbsoluteTime) * 1000)
	lastAbsoluteTime = absoluteTime
	print("%d %o %o" % (differentialTime, channel, value))
