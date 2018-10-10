#!/usr/bin/python2
# Copyright 2018 Ronald S. Burkey <info@sandroid.org>
# 
# This file is part of yaAGC.
# 
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Filename: 	dumbVerilog.py
# Purpose:	Converts KiCad AGC "logic flow diagrams" to Verilog
# Mod history:	2018-09-29 RSB	First time I remembered to add the GPL and
#				other boilerplate at the top of the file.
#				Various new things, though, like: better formatting
#				of module parameters and wire lines in the output
#				Verilog; treatment of netnames that begin with a
#				digit (not allowed in Verilog).
#		2018-10-01 RSB	Added signal-name translations of "-" to "m". 
#				Now allow for case where output of NOR is directly
#				tied to ground.  Found that some netnames assigned
#				only by net labels had a weird form I wasn't 
#				accounting for.
#		2018-10-04 RSB	Replace my "assign" statements by 
#				"pullup; assign (highz1,strong0)" statements.  I 
#				thought they worked to solve my problem (which was
#				wire-anding the outputs of gates from different 
#				modules), but it didn't.  I then replaced all my
#				"wire" specifications by "wand" specifications and,
#				once again, I think that works.
#		2018-10-05 RSB	Added optional SCHEMATIC.sch input.  Also, began 
#				adding a way to use the command-line to specify
#				translating with pullups instead of wands, but that
#				doesn't yet work.  Wasn't treating net labels in 
#				sheets 2 or 3 properly --- i.e., they only worked
#				right in sheet 1.
#		2018-10-08 RSB	Think that the optional pullup/wire construct may
#				be working now.  I think my problem was using
#				bitwise negation something I hadn't specified to
#				be 1 bit wide, when I should have used logical 
#				negation.  Maybe.  For what it's worth, I did 
#				a full-AGC simulation (in its current state, of
#				of course, which isn't fully functional) for 20 ms.,
#				and compared all backplane signals for wand vs
#				wire/pullup/1bz, and they were all absolutely 
#				identical in level and timing.  Added some handling
#				for the "ROM", "RAM", and "BUFFER" symbols.
#		2018-10-10 RSB	Changed the default build type to "wire", since 
#				the simulation isn't currently working correctly
#				with "pullup".
#
# This script converts one of my KiCad transcriptions of AGC LOGIC FLOW DIAGRAMs
# into Verilog in the dumbest, most-straightforward way.  In other words, I don't
# claim it's good or efficient Verilog, but merely that it is functional and 
# easily verifiable.  I view this as a first stage in a possible process of
# producing successively more-efficient Verilog implementations, though if it
# works well enough, then possibly ... it works well enough.  :-)  We'll see.
#
# Right now, though, the Verilog don't trust the Verilog it generates too much,
# unless it has been verified in some way.

# The inputs required are these:
#
#	MODULE		The name of the AGC logic module: A1, A2, etc.
#	FILENAME.net	A netlist as output by KiCad in "OrcadPCB2" format of a single AGC
#			LOGIC FLOW module (A1-A24).  This is not just any arbitrary version
#			of the KiCad transcriptions, but rather one of the initial ones I 
#			intended to be visually accurate representations of the original
#			scans.  The translator understands only a couple of kinds of 
#			components.
#	/PATH/pins.txt	This is a "CSV" dump of the PINS table of Mike's pin DB from
#			https://github.com/virtualagc/agc_hardware/blob/block2/delphi.db.
#			The dump should use a space as the field delimiter and not quote
#			the fields, and no header line is needed.  This file is used only
#			to create names for the inputs and outputs, and to determine which
#			of the signals actually are inputs vs outputs.
#	DELAY		A global delay (in units of simulation cycles), applied to all NOR
#			gates.  By default there is no delay.
#	FILENAME.init	A file containing initial values for NOR-gate outputs, where 
#			needed ... which is only for logic with feedback, such as flip-flops.
#			The initializations don't have to be a "good" condition (since the
#			original hardware just settled into whatever state it happened to 
#			like), but rather any stable state.  Otherwise, in iverilog, the
#			circuit will simply oscillate uncontrollably.  The file can also
#			contain delays to be applied to specific NOR gate outputs, overriding
#			the global DELAY setting for those particular gates.
#
# The Verilog is output to stdout.
#
# The basic idea is this:  The FILENAME.net input represents a single AGC "module".  This
# AGC module will be transformed into a single Verilog module.  All of the inputs and outputs
# of the Verilog module will be the non-spare connector pads of the AGC module.  Which are
# inputs and which are outputs are determined by pins.txt, but *could* be determined by the
# following simple rule: if connected to the output of any NOR gate, they are outputs, while
# if connected to no NOR-gate outputs, they are inputs.  Any net with a name like 0VDC* is
# treated a logic low, and all pads connected to it are ignored, as are all pads connected 
# to the chassis ground symbol.  Any net with a name like +4* or FAP is treated as logic 
# high and its pads are similarly ignored.
#
# The only component other than connectors in these diagrams is the 10-pin dual 3-input NOR gate,
# and we can simply hard-code the properties of that component into the script.

import sys
import os

error = False
gateLocations = {}

# Hard-coded info about components from our custom symbol libraries.  It would probably be
# niftier to read the symbol libraries to deduce this info.  Entry 0 in these arrays is
# unused, since there is no pin 0 in the parts.  In the pinTypesXXX arrays, the following
# codes are used:
#	"N"	No connect, not applicable, not used, ...
#	"I"	Input
#	"O"	Output
#	"B"	Bidirectional
#	"T"	Tristate output
#	"P"	Power or ground
pinNamesNOR = [ "",
	"J", "A", "B", "C", "GND", "D", "E", "F", "K", "VCC"
]
pinTypesNOR = [ "",
	"O", "I", "I", "I", "P",   "I", "I", "I", "O", "P"
]
pinNamesROM = [ "",
	"A15",  "A14",  "A13",  "A12",  "A11",  "A10",  "A9",   "A8",
	"",     "",     "WE_",  "",     "",     "",     "",     "",
	"",     "A7",   "A6",   "A5",   "A4",   "A3",   "A2",   "A1", 
	"A0",   "CE_",  "GND",  "OE_",  "DQ0",  "DQ8",  "DQ1",  "DQ9",
	"DQ2",  "DQ10", "DQ3",  "DQ11", "VCC",  "DQ4",  "DQ12", "DQ5",
	"DQ13", "DQ6",  "DQ14", "DQ7",  "DQ15", "GND",  "",     "A16"
]
pinTypesROM = [ "",
	"I",    "I",    "I",    "I",    "I",    "I",    "I",    "I",    
	"N",    "N",    "I",    "N",    "N",    "N",    "N",    "N",
	"N",    "I",    "I",    "I",    "I",    "I",    "I",    "I",    
	"I",    "I",    "P",    "I",    "B",    "B",    "B",    "B",
	"B",    "B",    "B",    "B",    "B",    "B",    "B",    "B",    
	"B",    "B",    "B",    "B",    "B",    "P",    "N",    "I"
]
pinNamesRAM = [ "",
	"A0",   "A1",   "A2",   "A3",   "A4",   "E_",   "DQL0", "DQL1",
	"DQL2", "DQL3", "VCC",  "GND",  "DQL4", "DQL5", "DQL6", "DQL7",
	"W_",   "A5",   "A6",   "A7",   "A8",   "A9",   "A10",  "A11",
	"A12",  "GND",  "VCC",  "",     "DQU8", "DQU9", "DQU10","DQU11",
	"VCC",  "GND",  "DQU12","DQU13","DQU14","DQU15","LB_",  "UB_",
	"G_",   "A13",  "A14",  "A15"
]
pinTypesRAM = [ "",
	"I",    "I",    "I",    "I",    "I",    "I",    "B",    "B",    
	"B",    "B",    "P",    "P",    "B",    "B",    "B",    "B",    
	"I",    "I",    "I",    "I",    "I",    "I",    "I",    "I",    
	"I",    "P",    "P",    "N",    "B",    "B",    "B",    "B",    
	"P",    "P",    "B",    "B",    "B",    "B",    "I",    "I",    
	"I",    "I",    "I",    "I"
]
pinNamesBUFFER = [ "",
	"OEa_", "I0a",  "O3b",  "I1a",  "O2b",  "I2a",  "O1b",  "I3a",
	"O0b",  "GND",  "I0b",  "O3a",  "I1b",  "O2a",  "I2b",  "O1a",
	"I3b",  "O0a",  "OEb_", "VCC" 
]
pinTypesBUFFER = [ "",
	"I",    "I",    "T",    "I",    "T",    "I",    "T",    "I",    
	"T",    "P",    "I",    "T",    "I",    "T",    "I",    "T",    
	"I",    "T",    "I",    "P"
]
schPadsJ1 = [ "?" ] * 72
schPadsJ2 = [ "?" ] * 72
schPadsJ3 = [ "?" ] * 72
schPadsJ4 = [ "?" ] * 72

def readSchematicFile(filename):
	global gateLocations
	f = open(filename, "r")
	newLines = f.readlines();
	f.close();
	print >> sys.stderr, "Read file " + filename + ", " + str(len(newLines)) + " lines"
	inSheet = False
	inComp = False
	inNOR = False
	inConnector = False
	pathName = os.path.dirname(filename)
	for rawLine in newLines:
		line = rawLine.strip()
		if line == "$Sheet":
			inSheet = True
			continue
		if line == "$EndSheet":
			inSheet = False
			continue
		if line == "$Comp":
			inComp = True
			refd = ""
			unit = 0
			continue
		if line == "$EndComp":
			inComp = False
			inNOR = False
			inConnector = False
			continue
		if inSheet:
			fields = line.split()
			if len(fields) >= 2 and fields[0] == "F1":
				newFilename = pathName + "/" + fields[1].strip("\"")
				readSchematicFile(newFilename)
			continue
		if inComp:
			fields = line.split()
			if len(fields) >= 3 and fields[0] == "L":
				refd = fields[2]
				if fields[1][:5] == "D3NOR":
					inNOR = True
				if fields[1][:18] == "AGC_DSKY:Connector":
					inConnector = True
				if refd == "J1":
					schPads = schPadsJ1
				elif refd == "J2":
					schPads = schPadsJ2
				elif refd == "J3":
					schPads = schPadsJ3
				elif refd == "J4":
					schPads = schPadsJ4
				else:
					schPads = ""
				continue
			if len(fields) >= 2 and fields[0] == "U":
				unitNumber = int(fields[1])
				if inNOR:
					if unitNumber == 1:
						unit = "A"
					else:
						unit = "B"
				continue
			if inNOR and len(fields) >= 11 and fields[0] == "F" and fields[10] == "\"Location\"":
				gate = fields[2].strip("\"")
				gateLocations[refd + unit] = gate
				continue
			if inConnector and len(fields) >= 11 and fields[0] == "F" and fields[10] == "\"Caption\"":
				caption = fields[2].strip("\"")
				if caption[:3] in ["0VD", "+4V", "+4S", "FAP"]:
					continue
				if caption[:1].isdigit():
					caption = "d" + caption
				caption = caption.replace("+", "p").replace("-", "m")
				schPads[unitNumber] = caption

delay = ""
inits = {}
if len(sys.argv) >= 3:
	
	moduleName = sys.argv[1]
	netlistFilename = sys.argv[2]
	if len(sys.argv) > 3:
		pathToPinsTxt = sys.argv[3]
	else:
		pathToPinsTxt = "pins.txt"
	if len(sys.argv) > 4 and sys.argv[4] != "" and sys.argv[4] != "0":
		delay = " #" + sys.argv[4]
	if len(sys.argv) > 5:
		initsFile = sys.argv[5]
		try:
			# The format of the inits file is ASCII lines, each with 3 
			# space-delimited fields:
			#	NOR_REFD [ J_LEVEL [ K_LEVEL [ J_DELAY [ K_DELAY ]]]]
			# J_LEVEL and K_LEVEL are each either 0 or 1 and are the logic
			# of the associated output during reset.  J_DELAY and K_DELAY,
			# if non-zero, are the associated gate delay.  We're insensitive
			# to leading, trailing, and multiple spaces. Any NOR not in the
			# file defaults to levels of 0 0 0 0.
			f = open(initsFile, "r")
			lines = f.readlines()
			f.close()
			for line in lines:
				thisInit = { "j": { "output":0, "delay":0.0 }, "k": { "output":0, "delay":0.0 } }
				fields = line.strip().split()
				if len(fields) <= 1 or fields[0] == "#":
					continue
				if len(fields) > 1:
					thisInit["j"]["output"] = int(fields[1])
				if len(fields) > 2:
					thisInit["k"]["output"] = int(fields[2])
				if len(fields) > 3:
					thisInit["j"]["delay"] = float(fields[3])
				if len(fields) > 4:
					thisInit["k"]["delay"] = float(fields[4])
				inits[fields[0]] = thisInit
		except:
			print >> sys.stderr, "Could not read inits file " + initsFile
			error = True
				
	# Test validity of the moduleName
	usePinsDB = True
	if len(moduleName) < 1 or moduleName[0] != "A" or not moduleName[1:].isdigit():
		#print >> sys.stderr, "Module name invalid."
		usePinsDB = False 
	else:
		moduleNumber = int(moduleName[1:])
		if moduleNumber < 1 or moduleNumber > 24:
			#print >> sys.stderr, "Module name is not A1 - A64."
			usePinsDB = False
	
	if usePinsDB:
		# Load pins.txt into pinsDB[].  Each entry in pinsDB[] is itself a list
		# with either 1 or 2 entries, namely: type of signal and net name, even
		# though the original pins database has lines with either 3 or 4 fields.
		# All pins database entries for different AGC modules are silently discarded.
		# The list has been padded so that the index to the entry is always equal
		# to the pad number.  For example, pad 425 is pinsDB[425].
		try:
			f = open(pathToPinsTxt, "r")
			pinsDB = []
			lines = f.readlines()
			for line in lines:
				fields = line.rstrip().split(" ")
				if len(fields) >= 3 and fields[0] == moduleName:
					fields[1] = int(fields[1])
					while len(pinsDB) < fields[1]:
						pinsDB.append(["MISSING"])
					if len(fields) > 3:
						if fields[3][:1].isdigit() and fields[3][:3] != "0VD":
							fields[3] = "d" + fields[3]
						fields[3] = fields[3].replace("+", "p").replace("-", "m")
					pinsDB.append(fields[2:])
			f.close()
		except:
			print >> sys.stderr, "Could not read pin DB " + pathToPinsTxt
			error = True
	
	# Load the gate numbers of the NOR gates from the .sch file, if one has been specified.
	if len(sys.argv) > 6:
		schFile = sys.argv[6]
		try:
			# Read the entire schematic, including its child sheets, into the
			# schLines array.
			readSchematicFile(schFile)
			if not usePinsDB:
				# Since we're not using (or can't use) the pins DB, but we do
				# have the schematic (and later, the netlist), we try to 
				# regenerate the data that would be in the pins DB from those
				# items instead.
				pinsDB = [ None ] * 500
				for i in range(1, 72):
					if schPadsJ1[i] != "?":
						pinsDB[100 + i] = [ "?", schPadsJ1[i] ]
					if schPadsJ2[i] != "?":
						pinsDB[200 + i] = [ "?", schPadsJ2[i] ]
					if schPadsJ1[i] != "?":
						pinsDB[300 + i] = [ "?", schPadsJ3[i] ]
					if schPadsJ1[i] != "?":
						pinsDB[400 + i] = [ "?", schPadsJ4[i] ]
		except:
			print >> sys.stderr, "Could not read schematic file " + schFile
			error = True
	
	wireType = "wire"
	if len(sys.argv) > 7 and sys.argv[7] != "":
		wireType = sys.argv[7]
	
	# Let's read the netlist into memory.
	try:
		f = open(netlistFilename, "r")
		lines = f.readlines()
		f.close()
	except:
		print >> sys.stderr, "Could not read netlist " + netlistFilename
		error = True
	
else:
	print >> sys.stderr, "Wrong number of command-line arguments."
	error = True

if error:
	print >> sys.stderr, "USAGE:"
	print >> sys.stderr, "\tdumbVerilog.py MODULE INPUT.net [/PATH/TO/pins.txt [DELAY [INPUT.init [SCHEMATIC.sch [WIRETYPE]]]]] >OUTPUT.v"
	print >> sys.stderr, "MODULE is the name of the AGC module, A1 through A24."
	print >> sys.stderr, "For \"modules\" that weren't part of the original AGC, but"
	print >> sys.stderr, "are instead introduced for simulation purposes, any unique"
	print >> sys.stderr, "alphanumeric (or '_', not leading with a digit) can be used."
	print >> sys.stderr, "INPUT.net is a netlist output by KiCad in OrcadPCB2 format."
	print >> sys.stderr, "If the optional path to pins.txt is omitted, it is assumed"
	print >> sys.stderr, "that pins.txt is in the current directory.  If the optional"
	print >> sys.stderr, "gate DELAY is omitted, then it is omitted from the Verilog."
	print >> sys.stderr, "The optional (but not really, in practice!) INPUT.init file"
	print >> sys.stderr, "provides initial conditions for any NOR gates that need it;"
	print >> sys.stderr, "i.e., for feedback within flip-flop circuits.  The optional"
	print >> sys.stderr, "SCHEMATIC.sch file is used to find the gate numbers associated"
	print >> sys.stderr, "with the NOR gates, and to rename otherwise inconveniently-"
	print >> sys.stderr, "named nets according to the gates driving them.  The WIRETYPE"
	print >> sys.stderr, "argument, if present, chooses between the Verilog constructs"
	print >> sys.stderr, "used for wire-AND'ing.  The default is 'wire' (uses pullups +"
	print >> sys.stderr, "1'bz + wires), while the other choice is 'wand' (uses wands)."
	print >> sys.stderr, "the default is 'wire'."
	sys.exit(1)

# If we're not using the pins DB, then we need to try and regenerate the data that would 
# have been in it from the schematic data (which we've already used) and the netlist
# (which we haven't).  Basically, we have already gotten the backplane netnames on the
# connector pads, but we don't know yet if they're inputs, outputs, or inouts.
inWhat = ""
rawConnectorNets = {}

if not usePinsDB:
	
	# Let's do a pass on the netlist just to determine the raw
	# netnames (i.e., not normalized in any way) on the connector pins.
	for line in lines:
		if line[:2] == " )":
			inWhat = ""
			continue
		if line[:3] == " ( ":
			# This is the start of a component.
			fields = line.strip().split()
			refd = fields[3]
			if refd[:1] in ["J"]:
				inWhat = "CONNECTOR"
			continue
		if inWhat != "CONNECTOR":
			continue
		if line[:4] == "  ( ":
			# This is a pin in the component.  The fields are
			# "(", pin number, net name, ").
			fields = line.strip().split()
			pinNumber = int(fields[1])
			rawNetName = fields[2]
			if rawNetName in rawConnectorNets:
				rawConnectorNets[rawNetName].append(pinNumber)
			else:
				rawConnectorNets[rawNetName] = [ pinNumber ]
	
	#print >> sys.stderr, rawConnectorNets
	#print >> sys.stderr, pinsDB
	
	# Now let's do another pass in which we can see how those raw netnames relate
	# to component pins, for which we have hardcoded data telling us if they're 
	# inputs or outputs.
	for line in lines:
		if line[:2] == " )":
			inWhat = ""
			continue
		if line[:3] == " ( ":
			# This is the start of a component.
			fields = line.strip().split()
			if fields[4][:5] == "D3NOR":
				inWhat = "NOR"
				pinTypes = pinTypesNOR
			elif fields[4] == "RAM":
				inWhat = fields[4]
				pinTypes = pinTypesRAM
			elif fields[4] == "ROM":
				inWhat = fields[4]
				pinTypes = pinTypesROM
			elif fields[4] == "BUFFER":
				inWhat = fields[4]
				pinTypes = pinTypesBUFFER
			continue
		if inWhat not in [ "NOR", "RAM", "ROM", "BUFFER"]:
			continue
		if line[:4] == "  ( ":
			# This is a pin in the component.  The fields are
			# "(", pin number, net name, ").
			fields = line.strip().split()
			pinNumber = int(fields[1])
			rawNetName = fields[2]
			if rawNetName not in rawConnectorNets:
				continue
			type = pinTypes[pinNumber]
			if type == "I":
				type = "IN"
			elif type == "O" or type == "T":
				type = "OUT"
			else:
				type = "INOUT"
			connectorPinNumbers = rawConnectorNets[rawNetName]
			for n in connectorPinNumbers:
				if pinsDB[n] == None:
					pinsDB[n] = [ "?", "?" ]
				oldType = pinsDB[n][0]
				if oldType == "?":
					newType = type
				elif type != oldType:
					newType = "INOUT"
				pinsDB[n][0] = newType
		
	#print >> sys.stderr, pinsDB

# Now let's do a pass on the netlist, looking just at the connector components to 
# get dictionaries of the input and output nets, both in terms of the names assigned in the netlist 
# and the names assigned in the pins DB.
discards = {}
inputs = {}
outputs = {}
inouts = {}
for line in lines:
	if line[:2] == " )":
		inWhat = ""
		continue
	if line[:3] == " ( ":
		# This is the start of a component.
		fields = line.strip().split()
		refd = fields[3]
		if refd[:1] in ["J"]:  # ["J", "N"]:
			inWhat = "CONNECTOR"
			#isNode = (refd[:1] == "N")
		continue
	if inWhat != "CONNECTOR":
		continue
	if line[:4] == "  ( ":
		# This is a pin in the component.  The fields are
		# "(", pin number, net name, ").
		fields = line.strip().split()
		pinNumber = int(fields[1])
		rawNetName = fields[2]
		if rawNetName in rawConnectorNets:
			rawConnectorNets[rawNetName].append(pinNumber)
		else:
			rawConnectorNets[rawNetName] = [ pinNumber ]
		if len(pinsDB[pinNumber]) < 2:
			continue
		netName = pinsDB[pinNumber][1].replace("/", "_")
		if fields[2][:3] in ["0VD", "+4V", "+4S", "FAP"]:
			discards[fields[2]] = netName
			continue
		if netName[:3] in ["0VD", "+4V", "+4S", "FAP"]:
			discards[fields[2]] = netName
			continue
		if pinsDB[pinNumber][0] in ["INOUT", "FIX", "FOX"]:
			# An inout net, or an unknown type.
			inouts[fields[2]] = netName
			continue
		if pinsDB[pinNumber][0] in ["IN"]:
			# An input net.
			inputs[fields[2]] = netName
			continue
		if pinsDB[pinNumber][0] in ["OUT", "NC"]:
			# An output net.
			outputs[fields[2]] = netName
			continue
		print >> sys.stderr, "Netlist entry \"" + line.strip() + "\" is neither an input nor an output."
		sys.exit(1)

# Can now write out the beginning of the Verilog module.
print "// Verilog module auto-generated for AGC module " + moduleName + " by dumbVerilog.py"
print ""
print "module " + moduleName + " ( "

# The dictionaries inputs, outputs, and inouts may have items in common, and may have
# duplicates.  We want to remove duplicate, add items that are in both inputs and inouts,
# and then finally to make the three sets mutually exclusive.  We do this in newInputs,
# newOutputs, and newInouts rather than in the original dictionaries.
newInputs = []
newOutputs = []
newInouts = []
for key in inouts:
	if inouts[key] not in newInouts:
		newInouts.append(inouts[key])
for key in inputs:
	if inputs[key] not in newInputs:
		newInputs.append(inputs[key])
for key in outputs:
	if outputs[key] not in newOutputs:
		newOutputs.append(outputs[key])
for key in newInputs:
	if key in newOutputs:
		if key not in newInouts:
			newInouts.append(key)
for key in newInouts:
	if key in newOutputs:
		newOutputs.remove(key)
	if key in newInputs:
		newInputs.remove(key)

count = len(newInouts) + len(newInputs) + len(newOutputs)
newInouts.sort()
newInputs.sort()
newOutputs.sort()
desiredLineLength = 70
line = "  rst"
for name in newInputs + newInouts + newOutputs:
	count -= 1
	if line == "":
		line = "  " + name
	else:
		line += ", " + name
	if len(line) > desiredLineLength:
		if count > 0:
			line += ","
		print line
		line = ""
if len(line) > 0:
	print line
print ");"

# Force the following signals to be wires (as opposed to wands), regardless of which 
# wire-type has been chosen.  For example, SAx needs to do this because they come from
# Verilog which was manually created (ROM.v, RAM.v, BUFFER.v) rather than autogenerated,
# and are defined with wires and pullups instead of wands.  If we interface to them 
# with wands, they won't work properly.  Those are the only examples I know of at the
# moment.
forceWires = [ "SA01", "SA02", "SA03", "SA04", "SA05", "SA06", "SA07", "SA08", "SA09",
	"SA10", "SA11", "SA12", "SA13", "SA14", "SAP", "SA16" ]
# If there are any inputs in the forceWires[] list, we want to
# make sure they're defined as wires and not wands.
forces = []
newNewInputs = []
for item in newInputs:
	if item in forceWires:
		forces.append(item)
	else:
		newNewInputs.append(item)

count = len(newNewInputs)
if count > 0:
	print ""
	line = "input " + wireType + " rst"
	for name in newNewInputs:
		count -= 1
		if line == "":
			line = "  " + name
		else:
			line += ", " + name
		if len(line) > desiredLineLength:
			if count > 0:
				line += ","
			else:
				line += ";"
			print line
			line = ""
	if len(line) > 0:
		print line + ";"

count = len(forces)
if count > 0:
	print ""
	line = "input wire"
	for name in forces:
		if count == len(forces):
			line += " " + name
		elif line == "":
			line = "  " + name
		else:
			line += ", " + name
		count -= 1
		if len(line) > desiredLineLength:
			if count > 0:
				line += ","
			else:
				line += ";"
			print line
			line = ""
	if len(line) > 0:
		print line + ";"

forces = []
newNewInouts = []
for item in newInouts:
	if item in forceWires:
		forces.append(item)
	else:
		newNewInouts.append(item)

count = len(newNewInouts)
if count > 0:
	print ""
	line = "inout " + wireType
	for name in newNewInouts:
		count -= 1
		if line == ("inout " + wireType):
			line += " " + name
		elif line == "":
			line = "  " + name
		else:
			line += ", " + name
		if len(line) > desiredLineLength:
			if count > 0:
				line += ","
			else:
				line += ";"
			print line
			line = ""
	if len(line) > 0:
		print line + ";"

count = len(forces)
if count > 0:
	print ""
	line = "inout wire"
	for name in forces:
		if count == len(forces):
			line += " " + name
		elif line == "":
			line = "  " + name
		else:
			line += ", " + name
		count -= 1
		if len(line) > desiredLineLength:
			if count > 0:
				line += ","
			else:
				line += ";"
			print line
			line = ""
	if len(line) > 0:
		print line + ";"

count = len(newOutputs)
if count > 0:
	print ""
	line = "output " + wireType
	for name in newOutputs:
		count -= 1
		if line == ("output " + wireType):
			line += " " + name
		elif line == "":
			line = "  " + name
		else:
			line += ", " + name
		if len(line) > desiredLineLength:
			if count > 0:
				line += ","
			else:
				line += ";"
			print line
			line = ""
	if len(line) > 0:
		print line + ";"

print ""

# Now do another pass on the netlist to determine how the internal logic of the
# module works.  We only need to look at the NOR gate components, because we already
# have everything we need to know about the connectors.
inWhat = ""
nors = []
netToGate = {}
roms = []
rams = []
buffers = []
pinNetsB = [""] * 100
for line in lines:
	if line[:2] == " )":
		if inWhat == "NOR":
			# If we are in a dual-NOR, we need to finish it out by outputting all
			# of the equations for the individual NOR gates.
			if refd in inits:
				thisGatesInits = inits[refd]
			else:
				thisGatesInits = { "j": { "output":0, "delay":0 }, "k": { "output":0, "delay":0} }
			if norPins[1] != "":
				nors.append([moduleName + "-" + refd + "A", norPins[1], thisGatesInits["j"], norPins[2], norPins[3], norPins[4]])
			if norPins[9] != "":
				nors.append([moduleName + "-" + refd + "B", norPins[9], thisGatesInits["k"], norPins[6], norPins[7], norPins[8]])
		elif inWhat == "BUFFER":
			buffers.append( { "refd":(moduleName + "-" + refd), "pins":pinNetsB[:21] } )
		elif inWhat == "RAM":
			rams.append( { "refd":(moduleName + "-" + refd), "pins":pinNetsB[:45] } )
		elif inWhat == "ROM":
			roms.append( { "refd":(moduleName + "-" + refd), "pins":pinNetsB[:49] } )
		inWhat = ""
		continue
	if line[:3] == " ( ":
		# This is the start of a component.
		fields = line.strip().split()
		refd = fields[3]
		if fields[4][:6] == "D3NOR-":
			inWhat = "NOR"
			norPins = [ "" ] * 11
			pinNames = pinNamesNOR
			continue
		pinNetsB = [ "" ] * 101
		if fields[4] == "ROM":
			inWhat = fields[4]
			pinNames = pinNamesROM
			continue
		if fields[4] == "RAM":
			inWhat = fields[4]
			pinNames = pinNamesRAM
			continue
		if fields[4] == "BUFFER":
			inWhat = fields[4]
			pinNames = pinNamesBUFFER
			continue
		continue
	if inWhat == "":
		continue
	isPin = False
	if line[:4] == "  ( ":
		# This is a pin in a component  The fields are
		# "(", pin number, net name, ").
		isPin = True
		fields = line.strip().split()
		pinNumber = int(fields[1])
		if pinNames[pinNumber] in ["GND", "VCC"]:
			# Ignore the chip's power and ground pins.
			continue
		netName = fields[2]		
		# Normalize the net name on the pin.
		if netName[:3] in ["+4S", "+4V", "FAP"]:
			netName = "1"
		elif netName[:3] == "0VD" or netName in discards:
			netName = "0"
		elif netName in inouts:
			netName = inouts[netName]
		elif netName in inputs:
			netName = inputs[netName]
		elif netName in outputs:
			netName = outputs[netName]
		elif netName[:3] in ["/1/", "/2/", "/3/", "/4/", "/5/", "/6/", "/7/", "/8/", "/9/"]:
			rawNetName = netName[3:]
			netName = rawNetName
			if netName[:1].isdigit():
				netName = "d" + netName
			if netName not in newInouts+newOutputs+newInputs:
				netName = moduleName + rawNetName
		else:
			netName = moduleName + netName[5:].replace("-", "").replace(")", "")
			if inWhat == "NOR":
				if pinNumber == 1:
					netToGate[netName] = "g" + gateLocations[refd + "A"]
				elif pinNumber == 9:
					netToGate[netName] = "g" + gateLocations[refd + "B"]
	if not isPin:
		continue
	if inWhat == "NOR":
		norPins[pinNumber] = netName
		continue
	pinNetsB[pinNumber] = netName

nets = {}
translateToGates = True
if len(nors) > 0:
	# First, consolidate all of the gates whose outputs are connected together,
	# and eliminate all inputs that are 0.  There's always one rst input to the
	# gate, so it doesn't matter (in a boundary-case sense) if all the other ones 
	# are eliminated.
	for i in range(0, len(nors)):
		netName = nors[i][1]
		if netName not in nets:
			gateName = nors[i][0] 
			initLevel = nors[i][2]["output"]
			gateDelay = nors[i][2]["delay"]
			inputList = nors[i][3:]
		else:
			gateName = nets[netName][0] + "_" + nors[i][0]
			try:
				initLevel = nors[i][2]["output"] or nets[netName][2]["output"]
				gateDelay = max(nors[i][2]["delay"], nets[netName][2]["delay"])
			except:
				print >> sys.stderr, nors[i][2]
				print >> sys.stderr, nets[netName][2]
				sys.exit(1)
			inputList = nets[netName][3:] + nors[i][3:]
		finalArray = [gateName, netName, { "output":initLevel, "delay":gateDelay }]
		for input in inputList:
			if input != "0" and input not in finalArray[2:]:
				finalArray.append(input)
		nets[netName] = finalArray
	# Write out Verilog code for each of the consolidated gates.
	for rawNetName in nets:
		netName = rawNetName
		if netName == "0":
			continue
		gate = nets[netName]
		#outLine = "nor" + delay + " " + gate[0] + "(" + netName + ",rst";
		#for input in gate[3:]:
		#	outLine += "," + input;
		#outLine += ")" + ";"
		thisInit = str(gate[2]["output"])
		if wireType == "wire" and thisInit == "1":
			thisInit = "1'bz"
		thisDelay = delay
		if gate[2]["delay"] != 0:
			thisDelay = " #" + str(gate[2]["delay"])
		print "// Gate " + gate[0].replace("_", " ")	
		if translateToGates and netName in netToGate:
			netName = netToGate[netName]
		if wireType == "wire":
			print "pullup(" + netName + ");"		
			outLine = "assign" + thisDelay + " " + netName + " = rst ? " + thisInit + " : ((0";
		else:
			outLine = "assign" + thisDelay + " " + netName + " = rst ? " + thisInit + " : !(0";
		for rawInput in gate[3:]:
			input = rawInput
			if translateToGates and input in netToGate:
				input = netToGate[input]
			outLine += "|" + input;
		if wireType == "wire":
			outLine += ") ? 1'b0 : 1'bz"
		outLine += ")" + ";"
		print outLine
print "// End of NOR gates"

# And similarly, write out any Verilog for BUFFERs, RAMs, and ROMs:
for device in buffers:
	refd = device["refd"]
	pins = device["pins"]
	for n in range(0, len(pins)):
		if translateToGates and pins[n] in netToGate:
			pins[n] = netToGate[pins[n]]
		if pins[n] == "0":
			pins[n] = "1'b0"
		elif pins[n] == "1":
			pins[n] = "1'b1"
	print "BUFFER " + refd.replace("-","_") + "("
	print "  " + pins[1] + ", " + pins[19] + ", " + pins[2] + ", " + pins[4] + ", "	
	print "  " + pins[6] + ", " + pins[8] + ", " + pins[11] + ", " + pins[13] + ", "	
	print "  " + pins[15] + ", " + pins[17] + ", " + pins[18] + ", " + pins[16] + ", "	
	print "  " + pins[14] + ", " + pins[12] + ", " + pins[9] + ", " + pins[7] + ", "	
	print "  " + pins[5] + ", " + pins[3]
	print ");"	
for device in rams:
	refd = device["refd"]
	pins = device["pins"]
	for n in range(0, len(pins)):
		if translateToGates and pins[n] in netToGate:
			pins[n] = netToGate[pins[n]]
		if pins[n] == "0":
			pins[n] = "1'b0"
		elif pins[n] == "1":
			pins[n] = "1'b1"
	print "RAM " + refd.replace("-","_") + "("
	print "  " + pins[6] + ", " + pins[17] + ", " + pins[41] + ", " + pins[40] + ", "	
	print "  " + pins[39] + ", " + pins[1] + ", " + pins[2] + ", " + pins[3] + ", "	
	print "  " + pins[4] + ", " + pins[5] + ", " + pins[18] + ", " + pins[19] + ", "
	print "  " + pins[20] + ", " + pins[21] + ", " + pins[22] + ", " + pins[23] + ", "
	print "  " + pins[24] + ", " + pins[25] + ", " + pins[42] + ", " + pins[43] + ", "	
	print "  " + pins[44] + ", " + pins[7] + ", " + pins[8] + ", " + pins[9] + ", "
	print "  " + pins[10] + ", " + pins[13] + ", " + pins[14] + ", " + pins[15] + ", "
	print "  " + pins[16] + ", " + pins[29] + ", " + pins[30] + ", " + pins[31] + ", "
	print "  " + pins[32] + ", " + pins[35] + ", " + pins[36] + ", " + pins[37] + ", "
	print "  " + pins[38]
	print ");"	
for device in roms:
	refd = device["refd"]
	pins = device["pins"]
	for n in range(0, len(pins)):
		if translateToGates and pins[n] in netToGate:
			pins[n] = netToGate[pins[n]]
		if pins[n] == "0":
			pins[n] = "1'b0"
		elif pins[n] == "1":
			pins[n] = "1'b1"
	print "ROM " + refd.replace("-","_") + "("
	print "  " + pins[26] + ", " + pins[28] + ", " + pins[11] + ", " + pins[25] + ", "	
	print "  " + pins[24] + ", " + pins[23] + ", " + pins[22] + ", " + pins[21] + ", "	
	print "  " + pins[20] + ", " + pins[19] + ", " + pins[18] + ", " + pins[8] + ", "
	print "  " + pins[7] + ", " + pins[6] + ", " + pins[5] + ", " + pins[4] + ", "
	print "  " + pins[3] + ", " + pins[2] + ", " + pins[1] + ", " + pins[48] + ", "	
	print "  " + pins[29] + ", " + pins[31] + ", " + pins[33] + ", " + pins[35] + ", "
	print "  " + pins[38] + ", " + pins[40] + ", " + pins[42] + ", " + pins[44] + ", "
	print "  " + pins[30] + ", " + pins[32] + ", " + pins[34] + ", " + pins[36] + ", "
	print "  " + pins[39] + ", " + pins[41] + ", " + pins[43] + ", " + pins[45]
	print ");"	

print ""
print "endmodule"

