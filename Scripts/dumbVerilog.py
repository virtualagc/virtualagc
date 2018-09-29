#!/usr/bin/python
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
# Mod history:	2018-07-29 RSB	First time I remembered to add the GPL and
#				other boilerplate at the top of the file.
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

error = False
delay = ""
inits = {}
if len(sys.argv) >= 3:
	
	moduleName = sys.argv[1]
	netlistFilename = sys.argv[2]
	if len(sys.argv) > 3:
		pathToPinsTxt = sys.argv[3]
	else:
		pathToPinsTxt = "pins.txt"
	if len(sys.argv) > 4 and sys.argv[4] != "":
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
	if len(moduleName) < 1 or moduleName[0] != "A" or not moduleName[1:].isdigit():
		print >> sys.stderr, "Module name is not A1 - A24."
		error = True 
	else:
		moduleNumber = int(moduleName[1:])
		if moduleNumber < 1 or moduleNumber > 24:
			print >> sys.stderr, "Module name is not A1 - A24."
			error = True
	
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
				pinsDB.append(fields[2:])
		f.close()
	except:
		print >> sys.stderr, "Could not read pin DB " + pathToPinsTxt
		error = True
	
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
	print >> sys.stderr, "\tdumbVerilog.py MODULE INPUT.net [/PATH/TO/pins.txt [DELAY [INPUT.init]] >OUTPUT.v"
	print >> sys.stderr, "MODULE is the name of the AGC module, A1 through A24."
	print >> sys.stderr, "INPUT.net is a netlist output by KiCad in OrcadPCB2 format."
	print >> sys.stderr, "If the optional path to pins.txt is omitted, it is assumed"
	print >> sys.stderr, "that pins.txt is in the current directory.  If the optional"
	print >> sys.stderr, "gate DELAY is omitted, then it is omitted from the Verilog."
	print >> sys.stderr, "The optional (but not really, in practice!) INPUT.init file"
	print >> sys.stderr, "provides initial conditions for any NOR gates that need it;"
	print >> sys.stderr, "i.e., for feedback within flip-flop circuits."
	sys.exit(1)

# Let's do a first pass on pinsDB, looking just at the connector components to 
# get dictionaries of the input and output nets, both in terms of the names assigned in the netlist 
# and the names assigned in the pins DB.
discards = {}
inputs = {}
outputs = {}
inouts = {}
inConnector = False
for line in lines:
	if line[:2] == " )":
		inConnector = False
		continue
	if line[:3] == " ( ":
		# This is the start of a component.
		fields = line.strip().split()
		refd = fields[3]
		if refd[:1] in ["J"]:  # ["J", "N"]:
			inConnector = True
			#isNode = (refd[:1] == "N")
		continue
	if not inConnector:
		continue
	if line[:4] == "  ( ":
		# This is a pin in the component.  The fields are
		# "(", pin number, net name, ").
		fields = line.strip().split()
		pinNumber = int(fields[1])
		if len(pinsDB[pinNumber]) < 2:
			continue
		pinName = pinsDB[pinNumber][1].replace("/", "_")
		if fields[2][:3] in ["0VD", "+4V", "+4S", "FAP"]:
			discards[fields[2]] = pinName
			continue
		if pinName[:3] in ["0VD", "+4V", "+4S", "FAP"]:
			discards[fields[2]] = pinName
			continue
		if pinsDB[pinNumber][0] in ["INOUT", "FIX", "FOX"]:
			# An inout net, or an unknown type.
			inouts[fields[2]] = pinName
			continue
		if pinsDB[pinNumber][0] in ["IN"]:
			# An input net.
			inputs[fields[2]] = pinName
			continue
		if pinsDB[pinNumber][0] in ["OUT", "NC"]:
			# An output net.
			outputs[fields[2]] = pinName
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

count = len(newInputs)
if count > 0:
	print ""
	line = "input wire rst"
	for name in newInputs:
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

count = len(newInouts)
if count > 0:
	print ""
	line = "inout wire"
	for name in newInouts:
		count -= 1
		if line == "inout wire":
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

count = len(newOutputs)
if count > 0:
	print ""
	line = "output wire"
	for name in newOutputs:
		count -= 1
		if line == "output wire":
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
inNOR = False
nors = []
for line in lines:
	if line[:2] == " )":
		if inNOR:
			# If we are in a dual-NOR, we need to finish it out by outputting all
			# of the equations for the individual NOR gates.
			inNOR = False
			if refd in inits:
				thisGatesInits = inits[refd]
			else:
				thisGatesInits = { "j": { "output":0, "delay":0 }, "k": { "output":0, "delay":0} }
			if norPins[1] != "":
				nors.append([refd + "A", norPins[1], thisGatesInits["j"], norPins[2], norPins[3], norPins[4]])
			if norPins[9] != "":
				nors.append([refd + "B", norPins[9], thisGatesInits["k"], norPins[6], norPins[7], norPins[8]])
		continue
	if line[:3] == " ( ":
		# This is the start of a component.
		fields = line.strip().split()
		if fields[3][:1] == "U":
			inNOR = True
			norPins = [ "", "", "", "", "", "", "", "", "", "", "" ]
			refd = fields[3]
		continue
	if not inNOR:
		continue
	if line[:4] == "  ( ":
		# This is a pin in the NOR.  The fields are
		# "(", pin number, net name, ").
		fields = line.strip().split()
		pinNumber = int(fields[1])
		if pinNumber == 5 or pinNumber == 10:
			# Ignore the chip's power and ground pins.
			continue
		netName = fields[2]		
		# Normalize the net name on the pin.
		if netName[:3] == "0VD" or netName in discards:
			netName = "0"
		elif netName[:3] in ["+4V", "+4S", "FAP"]:
			netName = "1"
		elif netName in inouts:
			netName = inouts[netName]
		elif netName in inputs:
			netName = inputs[netName]
		elif netName in outputs:
			netName = outputs[netName]
		else:
			netName = netName[5:].replace("-", "").replace(")", "")
		norPins[pinNumber] = netName

nets = {}
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
	for netName in nets:
		gate = nets[netName]
		#outLine = "nor" + delay + " " + gate[0] + "(" + netName + ",rst";
		#for input in gate[3:]:
		#	outLine += "," + input;
		#outLine += ")" + ";"
		thisInit = str(gate[2]["output"])
		thisDelay = delay
		if gate[2]["delay"] != 0:
			thisDelay = " #" + str(gate[2]["delay"])
		outLine = "assign" + thisDelay + " " + netName + " = rst ? " + thisInit + " : ~(0";
		for input in gate[3:]:
			outLine += "|" + input;
		outLine += ")" + ";"
		print outLine
print ""
print "endmodule"
	