#!/usr/bin/python
# This script converts one of my KiCad transcriptions of AGC LOGIC FLOW DIAGRAMs
# into Verilog in the dumbest, most-straightforward way.  In other words, I don't
# claim it's good or efficient Verilog, but merely that it is functional and 
# easily verifiable.  I view this as a first stage in a possible process of
# producing successively more-efficient Verilog implementations, though if it
# works well enough, then possibly ... it works well enough.  :-)  We'll see.
#
# Right now, though, the Verilog it creates is just garbage, since I don't know
# Verilog as of yet.  So far I'm really just looking at the various other factors
# that are involved, and the fact that it outputs something that looks vaguely
# like Verilog is just a coincidence.

# The inputs required are these:
#
#	pins.txt	This is a "CSV" dump of the PINS table of Mike's pin DB from
#			https://github.com/virtualagc/agc_hardware/blob/block2/delphi.db.
#			The dump should use a space as the field delimiiter and not quote
#			the fields, and no header line is needed.  This file is used only
#			to create names for the inputs and outputs, and to determine which
#			of the signals actually are inputs vs outputs.  None if that is 
#			actually necessary to produce functional Verilog, but as long as
#			it's available we may as well use it.
#	FILENAME.net	A netlist as output by KiCad in "OrcadPCB2" format of a single AGC
#			LOGIC FLOW module (A1-A24).  This is not just any arbitrary version
#			of the KiCad transcriptions, but rather one of the initial ones I 
#			intended to be visually accurate representations of the original
#			scans.
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
if len(sys.argv) >= 3:
	
	moduleName = sys.argv[1]
	netlistFilename = sys.argv[2]
	if len(sys.argv) > 3:
		pathToPinsTxt = sys.argv[3]
	else:
		pathToPinsTxt = "pins.txt"
	if len(sys.argv) > 4:
		delay = " #" + sys.argv[4]
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
	print >> sys.stderr, "\tdumbVerilog.py MODULE INPUT.net [/PATH/TO/pins.txt [DELAY]] >OUTPUT.v"
	print >> sys.stderr, "MODULE is the name of the AGC module, A1 through A24."
	print >> sys.stderr, "INPUT.net is a netlist output by KiCad in OrcadPCB2 format."
	print >> sys.stderr, "If the optional path to pins.txt is omitted, it is assumed"
	print >> sys.stderr, "that pins.txt is in the current directory.  If the optional"
	print >> sys.stderr, "gate DELAY is omitted, then it is omitted from the Verilog."
	sys.exit(1)

# Let's do a first pass on pinsDB, looking just at the connector components (which are assumed
# to be J* and to have pin numbers corresponding to the 276-pin connector) to get dictionaries 
# of the input and output nets, both in terms of the names assigned in the netlist and the names
# assigned in the pins DB.
discards = {}
inputs = {}
outputs = {}
inConnector = False
for line in lines:
	if line[:2] == " )":
		inConnector = False
		continue
	if line[:3] == " ( ":
		# This is the start of a component.
		fields = line.strip().split()
		if fields[3][:1] == "J":
			inConnector = True
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
		#if (fields[2] in inputs) or (fields[2] in outputs) or (fields[2] in discards):
		#	continue
		if pinName[:3] in ["0VD", "+4V", "+4S", "FAP"]:
			discards[fields[2]] = pinName
			continue
		if pinsDB[pinNumber][0] in ["IN"]:
			# An input net.
			inputs[fields[2]] = pinName
			continue
		if pinsDB[pinNumber][0] in ["OUT", "NC"]:
			# An input net.
			outputs[fields[2]] = pinName
			continue
		print >> sys.stderr, "Netlist entry \"" + line.strip() + "\" is neither an input nor an output."
		sys.exit(1)

# Can now write out the beginning of the Verilog module.
print "// Verilog module auto-generated for AGC module " + moduleName + " by dumbVerilog.py"
print "module " + moduleName + " ( "
print "  rst,"
newInputs = []
newOutputs = []
for key in inputs:
	if inputs[key] not in newInputs:
		newInputs.append(inputs[key])
for key in outputs:
	if outputs[key] not in newOutputs:
		newOutputs.append(outputs[key])
inouts = []
for key in newInputs:
	if key in newOutputs:
		inouts.append(key)
count = len(newInputs) + len(newOutputs) - len(inouts)
inouts.sort()
newInputs.sort()
newOutputs.sort()
for name in inouts:
	if count > 1:
		ending = ","
	else:
		ending = ""
	count -= 1
	print "  " + name + ending
for name in newInputs:
	if name in inouts:
		continue
	if count > 1:
		ending = ","
	else:
		ending = ""
	count -= 1
	print "  " + name + ending
for name in newOutputs:
	if name in inouts:
		continue
	if count > 1:
		ending = ","
	else:
		ending = ""
	count -= 1
	print "  " + name + ending
print ");"
print "input wire rst;"
for name in inouts:
	print "inout wire " + name + ";"
for name in newInputs:
	if name in inouts:
		continue
	print "input wire " + name + ";"
for name in newOutputs:
	if name in inouts:
		continue
	print "output wire " + name + ";"
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
			if norPins[1] != "":
				nors.append([refd + "A", norPins[1], norPins[2], norPins[3], norPins[4]])
			if norPins[9] != "":
				nors.append([refd + "B", norPins[9], norPins[6], norPins[7], norPins[8]])
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
			inputList = nors[i][2:]
		else:
			gateName = nets[netName][0] + "_" + nors[i][0]
			inputList = nets[netName][2:] + nors[i][2:]
		finalArray = [gateName, netName]
		for input in inputList:
			if input != "0" and input not in finalArray[2:]:
				finalArray.append(input)
		nets[netName] = finalArray
	# Write out Verilog code for each of the consolidated gates.
	for netName in nets:
		gate = nets[netName]
		#outLine = "nor" + delay + " " + gate[0] + "(" + netName + ",rst";
		#for input in gate[2:]:
		#	outLine += "," + input;
		#outLine += ")" + ";"
		outLine = "assign" + delay + " " + netName + " = ~(rst";
		for input in gate[2:]:
			outLine += "|" + input;
		outLine += ")" + ";"
		print outLine
print ""
print "endmodule"
	