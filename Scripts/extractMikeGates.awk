#!/usr/bin/awk
# The idea behind this script is that you take a netlist
# created from one of the modules, and from that you pull out a list of all
# the nets driven by gates.
#
# Here's the complete workflow:
#
# 1. First, process Mike's module:
#	a. Make an OrcadPCB2 netlist from it.
#	b. Process it with this command:
#		awk -v module=MODULE -f ~/bin/extractMikeGates.awk NETLIST.net | \
#		sed -e 's@/$@_@' -e 's@/A[0-9][0-9]_[0-9]/@@' | \
#		sort --key=2 >pins.tmp
#	   The resulting pins.tmp has two columns: Mike's REFD for gate, 
#	   and a netname.  Where possible, the net netnames are backplane
#	   signal names.  Module is A01-A24.
# 2. Process my module:
#	a. Make an OrcadPCB2 netlist from it.
#	b. Create a script that can convert connector-pad numbers to
#	   backplane signal names:
#		awk -v module=MODULE -f ~/bin/pinDB2Lookup.awk \
#			<../../Scripts/pins.txt >temp.sh
#	   The MODULE designation is A1-A9, A10-A24.
#	c. Process the netlist file:
#		awk -v module=MODULE -f ~/bin/extractMikeGates.awk NETLIST.net | \
#		sed -e 's@/$@_@' -e 's@[^ ]*/@@' | \
#		sort --key=2 | \
#		./temp.sh | sort --key=2 >pins.tmp
#	   The resulting pins.tmp is like the "Mike" one, but with my REFD's.
# 3. Combine the two pins.tmp files:
#	join -1 2 -2 2 -a 1 ../../../agc_hardware/scaler/pins.tmp 
#		pins.tmp >gateTranslate.txt
#    The resulting gateTranslate.txt has (basically) 3 columns:  a net name,
#    Mike's REFD, and a space-delimited list of my REFD's.
# 4. Edit gateTranslate.txt to fill in my REFD's, where they're missing.
#    If Mike's gate represents several of the original AGC gates tied together
#    then potentially there will be several of my gates for each of his.
#    Mike's gates are numbered Amm-Unnnn[ABCDEF] and mine are Akk-U[1234]nn[AB].
#    Usually Amm=Akk, but sometimes Mike he has moved gates from one module 
#    to another, so if my gates aren't in the same module as his, Akk might not
#    be the same as Amm.

BEGIN {
	in74HC02 = 0
	in74HC04 = 0
	in74HC27 = 0
	in74HC4002 = 0
	inD3NOR = 0
}

{
	if ($1 == ")") {
		in74HC02 = 0
		in74HC04 = 0
		in74HC27 = 0
		in74HC4002 = 0
		inD3NOR = 0
	} else if ($1 == "(" && $5 == "74HC02") {
		in74HC02 = 1
		refd = module "-" $4
	} else if ($1 == "(" && ($5 == "74HC04" || $5 == "74HC06")) {
		in74HC04 = 1
		refd = module "-" $4
	} else if ($1 == "(" && $5 == "74HC27") {
		in74HC27 = 1
		refd = module "-" $4
	} else if ($1 == "(" && $5 == "74HC4002") {
		in74HC4002 = 1
		refd = module "-" $4
	} else if ($1 == "(" && substr($5, 1, 5) == "D3NOR") {
		inD3NOR = 1
		refd = module "-" $4
	} else if (in74HC02) {
		if ($1 == "(" && $2 == "1") print refd "A " $3
		else if ($1 == "(" && $2 == "4") print refd "B " $3
		else if ($1 == "(" && $2 == "10") print refd "C " $3
		else if ($1 == "(" && $2 == "13") print refd "D " $3
	} else if (in74HC04) {
		if ($1 == "(" && $2 == "2") print refd "A " $3
		else if ($1 == "(" && $2 == "4") print refd "B " $3
		else if ($1 == "(" && $2 == "6") print refd "C " $3
		else if ($1 == "(" && $2 == "8") print refd "D " $3
		else if ($1 == "(" && $2 == "10") print refd "E " $3
		else if ($1 == "(" && $2 == "12") print refd "F " $3
	} else if (in74HC27) {
		if ($1 == "(" && $2 == "12") print refd "A " $3
		else if ($1 == "(" && $2 == "6") print refd "B " $3
		else if ($1 == "(" && $2 == "8") print refd "C " $3
	} else if (in74HC4002) {
		if ($1 == "(" && $2 == "1") print refd "A " $3
		else if ($1 == "(" && $2 == "13") print refd "B " $3
	} else if (inD3NOR) {
		if ($1 == "(" && $2 == "1") print refd "A " $3
		else if ($1 == "(" && $2 == "9") print refd "B " $3
	}
}

