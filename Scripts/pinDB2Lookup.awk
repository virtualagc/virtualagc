#!/usr/bin/awk
# This script is used in conjunction with extractMikeGates.awk
# and the text dump (pins.txt) of the pins DB.  What it does
# is to construct a sed command that can act as a lookup table
# for replacing net names based on connector pins into backplane
# net names.
#
# The name of the module must be passed in on the command line.
# For example,
#
#	awk -v module=A08 -f pinDB2Lookup.awk pins.txt

BEGIN {	
	print "sed \\"
}

{
	gsub(/A0/,"A",module)
	if ($1 == module && NF == 5 && $4 != "") {
		gsub(/\//, "_")
		print " -e 's@Net[-](J[1234][-]Pad" $2 ")$@" $4 "@' \\"
	}
}

END {
	print ""
}



