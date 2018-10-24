#!/usr/bin/python2
# Here's what I want this script to do:
#   1. 	Read and parse a netlist from Mike Stewart's schematics, in OrcadPCB2 format.  
#	I limit myself to the kinds of stuff I see in Mike's and my AGC schematics, 
#	and only to the stuff that help me deduce how the NOR gates are interconnected.
#   2.  Read and parse Verilog generated from my own schematics, again to build up
#	how it's interconnected.  It's easier to do this from the Verilog than from the
#	netlists, because it has already resolved all the issues about how to name
#	the nets, and how to interrelate them to refds and gate numbers.
#   3.	Use netlist structures to deduce as much of the relationship 
#	between Mike's net-naming (or almost equivalently, NOR-gate naming)
#	as can be done automatically.

import sys

# Can hard-code a few hints here to help out the processing if it stalls
hints = {
	"Net-(U15033-Pad6)":"g35341",  
	"_A18_1_F17A_":"F17A_"
}

# Just read the netlist from a file into a structure of the form:
#
#	{
#		refd1: {
#			type: "74HC..." etc,
#			pins: ["", "netnamePin1", "netnamePin2", ...]
#		},
#		refd2: ...
#	}
def inputAndParseNetlistFile(filename):
	
	#schCount = 0
	
	components = {}
	try:
		f = open (filename, "r")
		lines = f.readlines()
		f.close()
	except:
		print >> sys.stderr, "Could not read netlist file " + filename
		sys.exit(1)
	
	inComponent = False
	for line in lines:
		fields = line.strip().split()
		if len(fields) < 1:
			continue
		#if len(fields) >= 2 and fields[0] == "(" and fields[1] == "{":
		#	schCount += 1
		if not inComponent and len(fields) == 5 and fields[0] == "(":
			# Start of a component
			timestamp = fields[1]
			name = fields[2]
			refd = fields[3]
			type = fields[4]
			# Note that for convenience, we always have a pin 0, which has an empty
			# netname and simply isn't used for anything.  There may also be gaps
			# in the pin-numbering, and those gaps have empty netnames as well.
			pins = [ "" ]
			if refd[:1] != "U" or type in "74HC244" or type[:2] not in ["D3", "74"]:
				continue
			if type[:2] == "D3":
				type = "D3NOR"
			#urefd = str(schCount) + refd
			urefd = refd
			inComponent = True
		elif inComponent and len(fields) == 1 and fields[0] == ")":
			# End of a component
			inComponent = False
			components[urefd] = { "type":type, "pins":pins }
		elif inComponent and len(fields) == 4 and fields[0] == "(" and fields[3] == ")":
			# Pin of a component
			pinNumber = int(fields[1])
			net = fields[2].replace("+","p")
			if net[:4] != "Net-":
				net = net.replace("-","m").replace("/","_")
			if net[0].isdigit():
				net = "d" + net
			#if net[-1] == "/":
			#	net = net[:-1] + "_"
			#if net[:5] == "Net-(":
			#	net = net[:5] + str(schCount) + net[5:]
			while len(pins) < pinNumber:
				pins.append("")
			pins.append(net)
			
	return components

def inputAndParseVerilogFile(filename):
	count = 0
	f = open(filename, "r")
	lines = f.readlines()
	f.close()
	
	module = ""
	components = {}
	for line in lines:
		fields = line.strip().split()
		if len(fields) == 3 and fields[0] == "module" and fields[2] == "(":
			module = fields[1]
		elif len(fields) >= 2 and fields[0] == "//" and fields[1] == "Gate":
			gates = fields[2:]
		elif len(fields) >= 1 and fields[0] == "assign":
			j = 0
			for i in range(2, len(fields)):
				if fields[i] == "=":
					j = i
					out = fields[j - 1]
					break
			if j == 0:
				continue
			ins = []
			for i in range(j + 1, len(fields)):
				if fields[i][:4] in ["((0|", "!(0|"]:
					k = fields[i].find(")")
					if k < 5:
						continue
					stripped = fields[i][4:k]
					ins = stripped.split("|")
			if len(ins) < 1:
				continue
			if len(gates) < 1:
				count += 1
				refd = "Huh" + str(count)
			else:
				refd = gates[0]
				for g in gates[1:]:
					refd += "/" + g
			components[refd] = { "out":out, "ins":ins }
	
	# Now want to combine gates if they have the same output nets.
	# While this won't happen within any given drawing, it could happen
	# globally.
	byOuts = {}
	for refd in components:
		component = components[refd]
		out = component["out"]
		ins = component["ins"]
		if out not in byOuts:
			byOuts[out] = { "refd":refd, "ins":ins }
		else:
			byOuts[out]["refd"] += "/" + refd
			for n in ins:
				if n not in byOuts[out]["ins"]:
					byOuts[out]["ins"].append(n)
	superNormalizedComponents = {}
	for out in byOuts:
		component = byOuts[out]
		refd = component["refd"]
		ins = component["ins"]
		superNormalizedComponents[refd] = { "out":out, "ins":ins }
		
	return { "normalized":superNormalizedComponents, "synonyms":[] }

# Normalize the netlist info, by which I mean turn Mike's 74... series multiparts into a series
# of individual N-input NOR gates (i.e., not multipart), as well as to remove the non-inverting
# buffers he introduced, and to turn my possibly-tied-together NORs into individual N-input NORs.
# This operation has the side-effect of aliasing together some nets, because Mike's non-inverting
# buffers had the effect of introducing multiple net-names that were all carrying the same 
# signal.  We'll create a global synonyms dictionary to contain this info right now, but won't 
# actually use it just yet to change any netnames; that will come later.
def normalizeComponents(components):

	synonyms = []
	def addSynonym(name1, name2):
		index1 = -1
		index2 = -1
		for i in range(0, len(synonyms)):
			if name1 in synonyms[i]:
				index1 = i
			if name2 in synonyms[i]:
				index2 = i
		if index1 == -1 and index2 == -1:
			synonyms.append([name1, name2])
			return
		if index1 == index2:
			return
		if index2 == -1:
			synonyms[index1].append(name2)
			return
		if index1 == -1:
			synonyms[index2].append(name1)
			return
		synonyms[index1] += synonyms[index2]
		del synonyms[index2]
	
	normalizedComponents = {}
	
	# First step, is to break apart the multiparts into primitive N-input NOR gates. 
	for refd in components:
		type = components[refd]["type"]
		pins = components[refd]["pins"]
		if type == "74HC02":
			while len(pins) <= 14:
				pins.append("")
			normalizedComponents[refd + "A"] = { "out":pins[1], "ins":[pins[2], pins[3]] }
			normalizedComponents[refd + "B"] = { "out":pins[4], "ins":[pins[5], pins[6]] }
			normalizedComponents[refd + "C"] = { "out":pins[10], "ins":[pins[8], pins[9]] }
			normalizedComponents[refd + "D"] = { "out":pins[13], "ins":[pins[11], pins[12]] }
		elif type in ["74HC04", "74LVC06"]:
			while len(pins) <= 14:
				pins.append("")
			normalizedComponents[refd + "A"] = { "out":pins[2], "ins":[pins[1]] }
			normalizedComponents[refd + "B"] = { "out":pins[4], "ins":[pins[3]] }
			normalizedComponents[refd + "C"] = { "out":pins[6], "ins":[pins[5]] }
			normalizedComponents[refd + "D"] = { "out":pins[8], "ins":[pins[9]] }
			normalizedComponents[refd + "E"] = { "out":pins[10], "ins":[pins[11]] }
			normalizedComponents[refd + "F"] = { "out":pins[12], "ins":[pins[13]] }
		elif type == "74HC27":
			while len(pins) <= 14:
				pins.append("")
			normalizedComponents[refd + "A"] = { "out":pins[12], "ins":[pins[1], pins[2], pins[13]] }
			normalizedComponents[refd + "B"] = { "out":pins[6], "ins":[pins[3], pins[4], pins[5]] }
			normalizedComponents[refd + "C"] = { "out":pins[8], "ins":[pins[9], pins[10], pins[11]] }
		elif type == "74HC4002":
			while len(pins) <= 14:
				pins.append("")
			normalizedComponents[refd + "A"] = { "out":pins[1], "ins":[pins[2], pins[3], pins[4], pins[5]] }
			normalizedComponents[refd + "B"] = { "out":pins[13], "ins":[pins[9], pins[10], pins[11], pins[12]] }
		elif type == "74LVC07":
			while len(pins) <= 14:
				pins.append("")
			addSynonym(pins[1], pins[2])
			addSynonym(pins[3], pins[4])
			addSynonym(pins[5], pins[6])
			addSynonym(pins[8], pins[9])
			addSynonym(pins[10], pins[11])
			addSynonym(pins[12], pins[13])
		elif type == "D3NOR":
			while len(pins) <= 10:
				pins.append("")
			ins = []
			for i in range(2,5):
				if pins[i][:3] not in ["0VD", "GND"]:
					ins.append(pins[i])
			normalizedComponents[refd + "A"] = { "out":pins[1], "ins":ins }
			ins = []
			for i in range(6,9):
				if pins[i][:3] not in ["0VD", "GND"]:
					ins.append(pins[i])
			normalizedComponents[refd + "B"] = { "out":pins[9], "ins":ins }
		else:
			print >> sys.stderr, "Unsupported part type " + type
			sys.exit(1)
	
	# If there is unambiguously a backplane signal name among the synonyms, replace all of its
	# synonyms with it, and eliminate the synonym from the synonym table.
	newSynonyms = []
	for synonym in synonyms:
		backplaneSignal = ""
		disqualify = False
		for netname in synonym:
			if netname[:1] != "/" and netname[:4] != "Net-":
				if backplaneSignal != "":
					disqualify = True
					break
				backplaneSignal = netname
		if backplaneSignal == "":
			for netname in synonym:
				if netname[:2] == "/A" and netname[2:4].isdigit() and netname[4] == "_" and netname[5].isdigit() and netname[6] == "/":
					if backplaneSignal != "":
						disqualify = True
						break
					backplaneSignal = netname[7:]
		if disqualify or backplaneSignal == "":
			newSynonyms.append(synonym)
			continue
		for refd in normalizedComponents:
			if normalizedComponents[refd]["out"] in synonym:
				normalizedComponents[refd]["out"] = backplaneSignal
			for i in range(0, len(normalizedComponents[refd]["ins"])):
				if normalizedComponents[refd]["ins"][i] in synonym:
					normalizedComponents[refd]["ins"][i] = backplaneSignal
	
	# Now want to combine gates if they have the same output nets.
	byOuts = {}
	for refd in normalizedComponents:
		component = normalizedComponents[refd]
		out = component["out"]
		ins = component["ins"]
		if out not in byOuts:
			byOuts[out] = { "refd":refd, "ins":ins }
		else:
			byOuts[out]["refd"] += "/" + refd
			for n in ins:
				if n not in byOuts[out]["ins"]:
					byOuts[out]["ins"].append(n)
	superNormalizedComponents = {}
	for out in byOuts:
		component = byOuts[out]
		refd = component["refd"]
		ins = component["ins"]
		superNormalizedComponents[refd] = { "out":out, "ins":ins }
	
	return { "normalized":superNormalizedComponents, "synonyms":newSynonyms }

if len(sys.argv) != 3:
	print >> sys.stderr, "Try:  netlisterOP2.py MIKE_NETLIST RON_VERILOG"
	sys.exit(1)

# Input the data and normalize it however we can.
mikeComponents = inputAndParseNetlistFile(sys.argv[1])
mikeNormalized = normalizeComponents(mikeComponents)
ronNormalized = inputAndParseVerilogFile(sys.argv[2])

# Output what we just input, as files, for debugging purposes.
f = open("netlisterOP2.mike", "w")
for refd in mikeNormalized["normalized"]:
	component = mikeNormalized["normalized"][refd]
	f.write(refd + ": out=" + component["out"] + " ins=" + str(component["ins"]) + "\n")
f.close()
f = open("netlisterOP2.ron", "w")
for refd in ronNormalized["normalized"]:
	component = ronNormalized["normalized"][refd]
	f.write(refd + ": out=" + component["out"] + " ins=" + str(component["ins"]) + "\n")
f.close()

# Make some helpful, supplementary data structures to facilitate comparisons.
mikeByOuts = {}
ronByOuts = {}
for refd in mikeNormalized["normalized"]:
	component = mikeNormalized["normalized"][refd]
	mikeByOuts[component["out"]] = { "refd":refd, "ins":component["ins"], "matched":False }
	if "deducedRefd" in component:
		mikeByOuts[component["out"]]["deducedRefd"] = component["deducedRefd"]
for refd in ronNormalized["normalized"]:
	component = ronNormalized["normalized"][refd]
	ronByOuts[component["out"]] = { "refd":refd, "ins":component["ins"], "matched":False }

# Everything else below is just matching stuff between the Mike netlists and Ron netlists.  

bigDeducedNets = {}
passNumber = 0
count1 = 1
count1O = 1
count1I = 1
count1R = 0
while count1 + count1O + count1I + count1R != 0:
	passNumber += 1
	count1 = 0
	count1O = 0
	count1I = 0
	count1R = 0
	if passNumber == 1:
		deducedNets = hints
	else:
		deducedNets = {}
	
	# What this stuff does is to try to do matching where the output signal name matched,
	# and either all or all but one of the input signals match.
	for out in mikeByOuts:
		mikeComp = mikeByOuts[out]
		if mikeComp["matched"]:
			continue
		if out in ronByOuts and len(mikeComp["ins"]) == len(ronByOuts[out]["ins"]):
			ronComp = ronByOuts[out]
			unmatchedCount = 0
			mikeUnmatched = ""
			for i in mikeComp["ins"]:
				if i not in ronComp["ins"]:
					mikeUnmatched = i
					unmatchedCount += 1
			if unmatchedCount == 1:
				for i in ronComp["ins"]:
					if i not in mikeComp["ins"]:
						#print mikeUnmatched + " => " + i
						deducedNets[mikeUnmatched] = i
						break
			if unmatchedCount <= 1:
				count1 += 1
				#print mikeComp["refd"] + " => " + ronComp["refd"]
				mikeComp["matched"] = True
				if "deducedRefd" in mikeComp:
					mikeComp["deducedRefd"] += "/" + ronComp["refd"]
				else:
					mikeComp["deducedRefd"] = ronComp["refd"]
				ronComp["matched"] = True
	for m in deducedNets:
		r = deducedNets[m]
		if m in mikeByOuts:
			count1O += 1
			mikeByOuts[r] = mikeByOuts[m]
			mikeByOuts.pop(m, None)
	for out in mikeByOuts:
		ins = mikeByOuts[out]["ins"]
		for i in range(0, len(ins)):
			if ins[i] in deducedNets:
				count1I += 1
				ins[i] = deducedNets[ins[i]]
	for d in deducedNets:
		if d not in bigDeducedNets:
			bigDeducedNets[d] = deducedNets[d]
		else:
			if deducedNets[d] not in bigDeducedNets[d]:
				bigDeducedNets[d] += "/" + deducedNets[d]
	
	# What the stuff above can't do is directly deal with the case of all the inputs matching,
	# but the output not matching, from which the output can be inferred.  (Some of these are
	# taken care of indirectly, if the output netname happens to be an input netname which is
	# inferred separately.  However, that doesn't always happen.)
	mikeByIns = {}
	ronByIns = {}
	for out in mikeByOuts:
		component = mikeByOuts[out]
		ins = component["ins"]
		ins.sort()
		mikeByIns[str(ins)] = { "refd":component["refd"], "out":out, "matched":component["matched"] }
	for out in ronByOuts:
		component = ronByOuts[out]
		ins = component["ins"]
		ins.sort()
		ronByIns[str(ins)] = { "refd":component["refd"], "out":out }
	#testkey = "['WCHG_', 'XB7_', 'XT0_']"
	#print mikeByIns[testkey]
	#print ronByIns[testkey]
	for inputs in mikeByIns:
		#if inputs == testkey:
		#	print "here A"
		if inputs not in ronByIns or mikeByIns[inputs]["matched"]:
			continue
		#if inputs == testkey:
		#	print "here B"
		mikeRefd = mikeByIns[inputs]["refd"]
		mikeOut = mikeByIns[inputs]["out"]
		ronRefd = ronByIns[inputs]["refd"]
		ronOut = ronByIns[inputs]["out"]
		if mikeRefd != ronRefd:
			if "deducedRefd" in mikeByOuts[mikeOut]:
				mikeByOuts[mikeOut]["deducedRefd"] += "/" + ronRefd
			else:
				mikeByOuts[mikeOut]["deducedRefd"] = ronRefd
			count1R += 1
			#if inputs == testkey:
			#	print "here C"
		if mikeOut != ronOut:
			#if inputs == testkey:
			#	print "here D"
			#	print mikeOut
			#	print ronOut
			#	print mikeByOuts[mikeOut]
			deducedNets[mikeOut] = ronOut
			mikeByOuts[ronOut] = mikeByOuts[mikeOut]
			mikeByOuts.pop(mikeOut, None)
			#if inputs == testkey:
			#	print ronOut
			#	print mikeByOuts[ronOut]
			count1O += 1
		mikeByIns[inputs]["matched"] = True
		mikeByOuts[ronOut]["matched"] = True
	
	for m in deducedNets:
		r = deducedNets[m]
		if m in mikeByOuts:
			count1O += 1
			mikeByOuts[r] = mikeByOuts[m]
			mikeByOuts.pop(m, None)
	for out in mikeByOuts:
		ins = mikeByOuts[out]["ins"]
		for i in range(0, len(ins)):
			if ins[i] in deducedNets:
				count1I += 1
				ins[i] = deducedNets[ins[i]]
	for d in deducedNets:
		if d not in bigDeducedNets:
			bigDeducedNets[d] = deducedNets[d]
		else:
			if deducedNets[d] not in bigDeducedNets[d]:
				bigDeducedNets[d] += "/" + deducedNets[d]
	
	print str(count1) + " refds, " + str(len(deducedNets)) + " netnames, " + str(count1O) + " outputs, and " + str(count1I) + " inputs replaced on pass " + str(passNumber)
	
# Output debugging stuff.
f = open("netlisterOP2.mike1", "w")
for out in mikeByOuts:
	if out == "":
		continue
	component = mikeByOuts[out]
	f.write(component["refd"] + ": out=" + out + " ins=" + str(component["ins"]) + "\n")
f.close()
f = open("netlisterOP2.refd", "w")
for out in mikeByOuts:
	component = mikeByOuts[out]
	if "deducedRefd" not in component:
		component["deducedRefd"] = ""
	f.write(component["refd"] + " => " + component["deducedRefd"] + "\n")
f.close()
f = open("netlisterOP2.nets", "w")
for net in bigDeducedNets:
	f.write(net + " => " + bigDeducedNets[net] + "\n")
for net in mikeByOuts:
	if not mikeByOuts[net]["matched"]:
		f.write(net + " =>\n")
f.close()


