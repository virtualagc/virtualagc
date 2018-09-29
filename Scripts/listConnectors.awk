#!/usr/bin/awk
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# For generating a list of captioned connector pads from an AGC .sch file, for 
# diff'ing against a similar file derived from Mike Stewart's pin database.
# To generate the file from the .sch file, you do this in the folder 
# for the schematics of the module you're interested in, assuming there
# are no extraneous .sch files there that contain connector pads:
#	cat *.sch | awk -f listConnectors.awk | sed 's/"//g'  | sort >pinsLocal.txt
# To generate the file from Mike's database, which is an sqlite file, you first
# use sqlite itself and dump the PINS table to CSV, using a space as the field 
# delimiter and no quotes, and no header line with field names in it.  
# I call this dumped file pins.txt.  Then from pins.txt, you do this for the 
# module you're interested in (A1, A2, ..., B1, B2, ...), but let's say A8
# for concreteness:
#	awk '{if ($1 == "A8" && $3 != "SPARE" && !($3 == "NC" && (NF < 4 || $4 == "0VDCA"))) print $2 " " $4 ; else {}}' <pins.txt >pinsDB.txt
# You can then diff or kompare or whatever to see the differences between
# pinsLocal.txt and pinsDB.txt.

BEGIN {
	if (!CAPTION) CAPTION = "\"Caption\""
}

{
	if ($1 == "L") {
		if ($3 == "J1") offset = 100;
		else if ($3 == "J2") offset = 200;
		else if ($3 == "J3") offset = 300;
		else if ($3 == "J4") offset = 400;
		else offset = 0;
	} else if ($1 == "U") unit = $2;
	else if ($1 == "F" && $11 == CAPTION && offset > 0 && $3 != "\"\"" && $3 != "\"(NC)\"" && $3 != "\"NC\"") {
		print (offset+unit) " " $3
	} else {
	}
	
}
