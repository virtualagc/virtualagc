#!/usr/bin/awk -f
# This script is used for finding funky wires in a KiCad schematic.  Specifically,
# wires that are at a very tiny inclination from exact horizontal or vertical,
# ones that are very short, or ones not on a 25-mil grid.
#
# A list of the locations of the "errors" is output to stderr.
# A new schematic with error markers added (component "eelint") is output to stdout.
#
# The script can be used on a bunch of files like so:
#
#	for n in ListOfSchFiles ; do eelint.awk $n 2>errors.txt >errors.sch ; if [[ -s errors.txt ]] ; then eeschema errors.sch & less errors.txt ; fi ; done 
# 
# This doesn't modify any existing .sch files, but when it finds one with errors in it
# (i.e., if eelint output something to stderr) it opens up errors.sch in a separate copy
# of eeschema, allowing you to easily see where the error markers are.  If you fix the
# errors and do an appropriate "save current sheet as", then you will have fixed the 
# original schematic. The errors.txt file is opened up as well, so you can see both the 
# filename and the explanations of the errors.

function abs(v) { return v < 0 ? -v : v }

function errorMessage(msg) { 
	if (!titled) {
		titled = 1
		for (i = 0; i < ARGC; i++)
			print ARGV[i] > "/dev/stderr"
	}
	print x1/1000, ", ", y1/1000, ", ", x2/1000, ", ", y2/1000, ": ", msg > "/dev/stderr" 
} 

BEGIN {
	nextLine = 0
	short = 49.9
	# medium = 299.9
	medium = 49.9
	grid = 25
	lowSlope = 0.05
	timestamp = 12345678
	titled = 0
}

{
	funky = 0
	if ($1 == "L" && $2 == "AGC_DSKY:eelint") {
		errorMessage("Already an eelint marker")
		# Don't mark as funky.  Just the error message is good enough!
	}
	if ($1 == "Wire" && $2 == "Wire") {
		nextLine = 1
	} else if (nextLine) {
		nextLine = 0
		x1 = $1
		y1 = $2
		x2 = $3
		y2 = $4
		
		len1 = abs(x1 - x2)
		len2 = abs(y1 - y2)
		if (len1 > len2) {
			len = len1
			len1 = len2
			len2 = len
		}
		len = sqrt(len1 * len1 + len2 * len2)
		slope = len1 / len2
		
		# Off grid?
		if (x1 % grid != 0 || x2 % grid != 0 || y1 % grid != 0 || y2 % grid != 0) {
			errorMessage("Off grid")
			funky = 1
		} 
		
		else if (len < short) {
			# Too short?
			errorMessage("Too short")
			funky = 1
		}
		
		# Poor angle for short wires?  This will have a false positive
		# for short wires I sometimes add at transistor leads. 
		else if (slope > 0 && len < medium) {
			errorMessage("Short incline")
			funky = 1
		}
		
		# Poor angle for long wires? 
		else if (slope > 0 && slope < lowSlope) {
			errorMessage("Slight incline")
			funky = 1
		}
		
	}

	# Output
	print $0
	if (funky) {
		print "$Comp"
		print "L AGC_DSKY:eelint X?"
		print "U 1 1 ", timestamp
		timestamp = timestamp + 1
		print "P ", x1, " ", y1
		print "F 0 \"X?\" H ", x1, " ", y1, " 140 0001 C CNN"
		print "F 1 \"eelint\" H ", x1, " ", y1, " 140 0001 C CNN"
		print "F 2 \"\" H ", x1, " ", y1, " 140 0001 C CNN"
		print "F 3 \"\" H ", x1, " ", y1, " 140 0001 C CNN"
		print "	1    ", x1, " ", y1
		print "	1    0    0    -1"  
		print "$EndComp"
	}
}
