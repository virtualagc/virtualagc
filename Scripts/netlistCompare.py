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
				elif len(fields) == 11 and fields[0] == "F" and fields[10][:8] == '"Caption':
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
V3 = ["+3VDC", "+3A"]
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
	recovered2true[refd] = reverseTrueSchematic[gate]["refd"]
print recovered2true
 

