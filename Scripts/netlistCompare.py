#!/usr/bin/python
# This is a limited-usage tool that (if I succeed in creating it)
# will be used to compare the netlists for Block I schematics that 
# I'm currently in the process of transcribing into KiCad against
# the netlists of KiCad schematics I previously created by "recovering"
# Block I schematics from AC Electronics document ND-1021041.  In
# other words, it is neither a general netlist comparator (since it
# can depend on the known properties of the netlists I'm using it for),
# nor will it be used again, probably, after I've exhausted the 7
# "recovered" schematics I've already created.

# Usage:
#	netlistCompare.py TRUEDRAWING.net RECOVEREDDRAWING.net TRUESCHEMATIC.sch RECOVEREDSCHEMATIC.sch
# Both netlists are in Orcad2 format.  The .sch files are really all of the 
# schematic files in the project folder, concatenated.

import sys

def readNetlist(filename):
	components = {}
	inComponent = False
	fp = open(filename, 'r')
	while True:
		line = fp.readline()
		if line:
			fields = line.strip().split()
			if inComponent:
				if len(fields) != 4 or fields[0] != "(" or fields[3] != ")":
					inComponent = False
				elif symbol[:5] != "D3NOR" or fields[1] not in ["2","6"]:
					components[refd]["pins"][fields[1]] = fields[2]
			else:
				if len(fields) == 5 and fields[0] == "(":
					inComponent = True
					refd = fields[3]
					symbol = fields[4]
					components[refd] = { "symbol": symbol, "pins": {} }
		else:
			fp.close()
			return components

def readSchematic(filename):
	schematic = {}
	inComponent = False
	fp = open(filename, 'r')
	while True:
		line = fp.readline()
		if line:
			fields = line.strip().split()
			if inComponent:
				if len(fields) == 1 and fields[0] == "$EndComp":
					inComponent = False
				elif len(fields) == 3 and fields[0] == "L":
					refd = fields[2]
					symbol = fields[1]
				elif len(fields) == 4 and fields[0] == "U":
					if refd[:1] == "J":
						unit = int(fields[1])
						if unit <= 26:
							refd += chr(64 + unit)
						else:
							high = (unit - 27) // 26
							low = (unit - 1) % 26
							refd += chr(65 + high)
							refd += chr(65 + low)
					schematic[refd] = { "symbol": symbol }
				elif len(fields) == 11 and fields[0] == "F" and fields[10] in ['"Location"','"agc5"']:
					schematic[refd]["gate"] = fields[2].strip('"')
				elif len(fields) == 11 and fields[0] == "F" and fields[10][:8] == '"Caption' and fields[2] != '""':
					schematic[refd][fields[10]] = fields[2].strip('"')
			else:
				if len(fields) == 1 and fields[0] == "$Comp":
					inComponent = True
		else:
			fp.close()
			return schematic

# Read all of the input files.
trueDrawingNet = readNetlist(sys.argv[1])
recoveredDrawingNet = readNetlist(sys.argv[2])
#print trueDrawingNet
#print recoveredDrawingNet
trueSchematic = readSchematic(sys.argv[3])
recoveredSchematic = readSchematic(sys.argv[4])
#print trueSchematic
#print recoveredSchematic

# At this point, we should be able to compare all backplane signals.
for refd in recoveredSchematic:
	if refd[:1] != "J":
		continue
	if refd not in trueSchematic:
		print "Connector " + refd + " in recovered schematic is missing from the true schematic."
		continue
	for key in recoveredSchematic[refd]:
		if key[:8] == '"Caption' and key not in trueSchematic[refd]:
			print "Key " + key + " is missing from true schematic " + refd
for refd in trueSchematic:
	if refd[:1] != "J":
		continue
	if refd not in recoveredSchematic:
		print "Connector " + refd + " in true schematic is missing from the recovered schematic."
		continue
	for key in trueSchematic[refd]:
		if key[:8] == '"Caption' and key not in recoveredSchematic[refd]:
			print "Key " + key + " is missing from recovered schematic " + refd
NC = ["(NC)", "N.C.", "0VDC"]
V3 = ["+3VDC", "+3A", "+3B"]
for refd in trueSchematic:
	if refd[:1] != "J":
		continue
	for key in trueSchematic[refd]:
		if key[:8] != '"Caption':
			continue
		try:
			trueValue = trueSchematic[refd][key]
			recoveredValue = recoveredSchematic[refd][key]
			if trueValue in NC and recoveredValue in NC:
				continue
			if trueValue in V3 and recoveredValue in V3:
				continue
			if trueValue != recoveredValue:
				fields = recoveredValue.split("_")
				if len(fields) > 1 and fields[0][:1] == "A" and fields[0][1:].isdigit():
					continue
				print "In " + refd + ", " + key + " differs: " + trueValue + " != " + recoveredValue
		except:
			continue

# As far as logic-flow diagrams are concerned -- and I think that's all we're dealing with here! --
# we should know enough to match all of the NOR gates between the two netlists, since we know from
# reading the schematics what gate numbers are mapped with what reference designators, and
# those gate numbers should be the same (or transformable in a known way) between the two schematics.
# Here's how the gate numbers should transform:
#
#	DRAWING		ORIGINAL	RECOVERED
#	-------		--------	---------
#	1006547		--NNN		52NNN

# Make a way, in the real schematic, to look up the refd by the gate number.  This will be the
# dictionary recovered2true, which will have key/value pairs like
#	"recoveredREFD" : "trueREFD"

def normalizeGate(gate):
	if gate[-2:] == "xx":	# For modules A1-A16.
		return gate[:-2]
	else:			# For all other modules.
		return gate[2:]

reverseTrueSchematic = {}
for refd in trueSchematic:
	if refd[:1] != "U":
		continue
	component = trueSchematic[refd]
	component["refd"] = refd
	gate = component["gate"]
	reverseTrueSchematic[normalizeGate(gate)] = component
recovered2true = {}
#print reverseTrueSchematic
for refd in recoveredSchematic:
	if refd[:1] != "U":
		continue
	gate = normalizeGate(recoveredSchematic[refd]["gate"])
	if gate in reverseTrueSchematic:
		recovered2true[refd] = reverseTrueSchematic[gate]["refd"]
#print recovered2true
 
# Now actually create a new recovered schematic, in which the REFDs match the true schematic.  We don't have to 
# rename the nets whose names contain the REFDs, because we're going to (eventually) rely only on those names
# being unique, and not on the formats of the names themselves.
renamedRecoveredDrawingNet = {}
for refd in recoveredDrawingNet:
	translatedRefd = refd
	if refd in recovered2true:
		translatedRefd = recovered2true[refd]
	component = recoveredDrawingNet[refd]
	component["originalRefd"] = refd
	renamedRecoveredDrawingNet[translatedRefd] = component

# So at this point, the dictionaries trueDrawingNet and renamedRecoveredDrawingNet have the same
# REFDs as keys.  Their values are components, which differ because the netnames, while unique,
# usually differ, because the input pins of the NORs are rearranged, and because the 
# components can have fields (used for tracking what's going on) that the corresponding 
# components don't have.  Almost every net has one or more of the following on it:  a connector
# pin, a NOR-gate output pin, or a pin of part with non-interchangeable pins (polarized capacitor,
# diode, transistor).  Therefore, if we look at what nets are on such pins in the true schematic,
# vs what nets are on such pins in the recovered schematic, we can make an almost-complete 
# table for translating the recovered net names to the true net names.  (In fact, for logic
# flow diagrams, I think it actually will be a complete list.)  We save the translated net names
# in the recovered netlist's trueNets arrays.
net2net = {}
for refd in renamedRecoveredDrawingNet:
	if refd not in trueDrawingNet:
		continue
	if refd[:1] == "J":
		for pin in renamedRecoveredDrawingNet[refd]["pins"]:
			if pin not in trueDrawingNet[refd]["pins"]:
				continue
			netFrom = renamedRecoveredDrawingNet[refd]["pins"][pin]
			netTo = trueDrawingNet[refd]["pins"][pin]
			if netFrom in net2net:
				if net2net[netFrom] != netTo:
					print "Net " + netFrom + " has multiple translations (" + netTo + ", " + net2net[netFrom] + ")"
			else:
				net2net[netFrom] = netTo
	elif renamedRecoveredDrawingNet[refd]["symbol"][:5] == "D3NOR":
		netFrom = renamedRecoveredDrawingNet[refd]["pins"]["7"]
		netTo = trueDrawingNet[refd]["pins"]["7"]
		if netFrom in net2net:
			if net2net[netFrom] != netTo:
				print "Net " + netFrom + " has multiple translations (" + netTo + ", " + net2net[netFrom] + ")"
		else:
			net2net[netFrom] = netTo
#print net2net
#print len(net2net)
#print len(trueDrawingNet)
#print len(recoveredDrawingNet)

# Now translate all of the net names in renamedRecoverdDrawingNet.
for refd in renamedRecoveredDrawingNet:
	component = renamedRecoveredDrawingNet[refd]
	for pin in component["pins"]:
		net = component["pins"][pin]
		if net in net2net:
			component["pins"][pin] = net2net[net]

# Check which components and component pins were not present in one or the other.
for refd in trueDrawingNet:
	if refd[:1] == "X":
		continue
	if refd not in renamedRecoveredDrawingNet:
		print "Component " + refd + " is in the official drawing, but not in ND-1021041"
for refd in renamedRecoveredDrawingNet:
	if refd[:1] == "X":
		continue
	if refd not in trueDrawingNet:
		print "Component " + refd + " is in ND-1021041, but not in the official drawing"
for refd in trueDrawingNet:
	if refd[:1] == "X":
		continue
	if refd in renamedRecoveredDrawingNet:
		trueComponent = trueDrawingNet[refd]
		recoveredComponent = renamedRecoveredDrawingNet[refd]
		for pin in trueComponent["pins"]:
			if pin not in trueComponent["pins"]:
				print "Pin " + pin + " for " + refd + " in ND-1021041 but not the official drawing"
		for pin in trueComponent["pins"]:
			if pin not in trueComponent["pins"]:
				print "Pin " + pin + " for " + refd + " in the official drawing but not in ND-1021041"

# Now compare the net names.  There are two cases for each component: pins which
# are interchangeable, and pins which are not.
for refd in renamedRecoveredDrawingNet:
	if refd not in trueDrawingNet:
		continue
	trueComponent = trueDrawingNet[refd]
	recoveredComponent = renamedRecoveredDrawingNet[refd]
	if trueComponent["symbol"][:5] == "D3NOR":
		if recoveredComponent["pins"]["7"] != trueComponent["pins"]["7"]:
			print "Net on pin 7 for " + refd + " does not match (" + trueComponent["pins"]["7"] + ", " + recoveredComponent["pins"]["7"] + ")"
		trueUnordered = set([trueComponent["pins"]["1"], trueComponent["pins"]["3"], trueComponent["pins"]["5"]])
		recoveredUnordered = set([recoveredComponent["pins"]["1"], recoveredComponent["pins"]["3"], recoveredComponent["pins"]["5"]])
		if len(trueUnordered - recoveredUnordered) != 0:
			print "Mismatch on pins 1,3,5 for " + refd
	else:
		for pin in recoveredComponent["pins"]:
			if pin in trueComponent["pins"]:
				if trueComponent["pins"][pin] != recoveredComponent["pins"][pin]:
					print "Net on pin " + pin + " of " + refd + " does not match (" + trueComponent["pins"][pin] + ", " + recoveredComponent["pins"][pin] + ")"


