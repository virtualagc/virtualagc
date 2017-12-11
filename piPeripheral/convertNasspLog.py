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

# Get the list of channel numbers.
if len(sys.argv) < 2:
	print("This program filters and reformats a NASSP log of AGC i/o-channel")
	print("activity, producing a playback script for the piDSKY2 program.")
	print("Usage:")
	print("\tconvertNasspLog.py channel1 channel2 channel3 ...  <nasspLog >playbackScript")
	print("The AGC channel numbers are in octal.")
	sys.exit(1)
channels = []
for i in range(1, len(sys.argv)):
	channels.append(int(sys.argv[i], 8))

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
	if channel != 0o10:
		channelName = str(channel)
		channelValue = value
	else:
		channelName = str(channel) + "-" + str(value >> 11)
		channelValue = value & 0o3777
	if (channelName in lastValues) and (lastValues[channelName] == channelValue):
		continue
	lastValues[channelName] = channelValue
	# Convert absolute timestamps to differential times and output.
	differentialTime = round((absoluteTime - lastAbsoluteTime) * 1000)
	lastAbsoluteTime = absoluteTime
	print("%d %o %o" % (differentialTime, channel, value))
