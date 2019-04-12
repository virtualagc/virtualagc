#!/usr/bin/awk -f
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# All of the KiCad schematics I've created for the AGC/DSKY schematics
# are on a 25-mil grid.  Unfortunately, I've run into a case where 
# I have a schematic in which everything is off-grid.  It was a bug
# in autoplaceKiCad.py that put them there.  At any rate, there doesn't
# seem to be anything in KiCad itself that allows me to snap everything
# back onto the grid.  So here's a tools for that.  It takes a .sch
# file on stdin and outputs the snapped version of that on stdout.

# Snap the input value to the nearest multiple of 25.
function snap(value) {
	quotient = int(value / 25)
	remainder = int(value) % 25
	if (remainder <= -12.5) remainder = -25 
	else if (remainder >= 12.5) remainder = 25 
	else remainder = 0 
	newValue = 25 * quotient + remainder
	return newValue	
}

BEGIN {
	unit = "blern"
	inwire = 0
}

{
	if (inwire) {
		$1 = "\t" snap($1)
		$2 = snap($2)
		$3 = snap($3)
		$4 = snap($4)
		inwire = 0
	} else if ($1 == "U") {
		unit = $2
	} else if ($1 == "NoConn") {
		$3 = snap($3)
		$4 = snap($4)
	} else if ($1 == "P") {
		$2 = snap($2)
		$3 = snap($3)
	#} else if ($1 == "F") {
	#	$5 = snap($5)
	#	$6 = snap($6)
	} else if ($1 == unit) {
		$1 = "\t" unit
		$2 = snap($2)
		$3 = snap($3)
		unit = "blern"
	} else if ($1 == "$EndComp") {
		unit = "blern"
	} else if ($1 == "Wire" && $2 == "Wire") {
		inwire = 1
	} else if ($1 == "Connection" && $2 == "-") {
		$3 = snap($3)
		$4 = snap($4)
	} else if ($1 == "Text" && $2 == "GLabel") {
		$3 = snap($3)
		$4 = snap($4)
	}
	print $0
}
