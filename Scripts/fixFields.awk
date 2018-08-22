#!/usr/bin/awk
# Goes through a KiCad .sch file, and for all custom fields
# processes the *name* of the field as follows:
#
#	If it finds an underline, removes it and whatever follows it.
#	Suffixes an underline, the refd, and the multipart number.
#
# Usage:
#	awk -f fixFields.awk <original.sch >new.sch
#
# The original name cannot be the same as the new one.

BEGIN {
	refd = ""
	part = 0
}

{

	if ($1 == "L") refd = $3
	if ($1 == "U") part = $2
	if ($1 == "F" && $2 > 3) {
		name = $11
		split(name, nameParts, /_|"/)
		name = "\"" nameParts[2] "_" refd "_" part "\""
		$11 = name
	}

	print $0
}

