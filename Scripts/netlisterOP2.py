#!/usr/bin/python2
# I, the author, Ron Burkey, declare this program to be in the public domain.
# Use it however you like.
#
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
import re

heuristicPattern1 = re.compile("_[AB][0-2][0-9]_[1-3]_")

# Can hard-code a few hints here to help out the processing if it stalls, or if the
# heuristic isn't quite right.  The hints are applied when the netlist is read in,
# before any other changes to the netnames have been made.
hints = { 
	# I decided to "fix" the following two items in the schematics instead.
	#"/A12_1/G02/":"ua12_1_G02_", 
	#"/A12_1_G03/":"ua12_1_G03_",
	# The following are net labels Mike and I used.
	"/A15_2/2510H":"uA15_2_2510H",
	"/A15_2/147H":"uA15_2_147H",
	"/A15_2/147L":"uA15_2_147L",
	"/A15_2/036H":"uA15_2_036H",
	"/A15_2/036L":"uA15_2_036L",
	"/A15_2/NE00":"uA15_2_NE00",
	"/A15_2/NE01":"uA15_2_NE01",
	"/A15_2/NE02":"uA15_2_NE02",
	"/A15_2/NE03":"uA15_2_NE03",
	"/A15_2/NE04":"uA15_2_NE04",
	"/A15_2/NE05":"uA15_2_NE05",
	"/A15_2/NE06":"uA15_2_NE06",
	"/A15_2/NE07":"uA15_2_NE07",
	"/A15_2/NE10":"uA15_2_NE10",
	"/A15_2/NE12/":"uA15_2_NE12_",
	"/A15_2/NE345/":"uA15_2_NE345_",
	"/A15_2/NE6710/":"uA15_2_NE6710_",
	# The following are just a few leftover nets that can't be automatched
	# without exponentially more effort.  The hints are potentially vulnerable
	# to redoing the netlist, since there're no guarantee that KiCad's
	# netlister will assign the same name to the net next time.  However,
	# if the net is renamed later by the netlister, it won't create a 
	# naming *conflict*, and new hints can be added without removing the
	# old ones (unless an actual change to the connectivity is made).
	"Net-(U11048-Pad13)":"g54444",
	"Net-(U14055-Pad11)":"g42445",
	"Net-(U18028-Pad13)":"g45407",
	"Net-(U18036-Pad13)":"g45410",
	"Net-(U18038-Pad13)":"g45417",
	"Net-(U18040-Pad12)":"g45425",
	"Net-(U18040-Pad13)":"g45424",
	"Net-(U18042-Pad12)":"g45432",
	"Net-(U18042-Pad13)":"g45431",
	"Net-(U22015-Pad5)":"g47141",
	"Net-(U23008-Pad13)":"g48147",
	"Net-(U23014-Pad13)":"g48239",
	"Net-(U23024-Pad2)":"g49327",
	"Net-(U24106-Pad5)":"g49214",
	"Net-(U24036-Pad2)":"g49248",
	"ZZZZZZZZZZZZZZZZ":"ZZZZZZZ"
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
			net = fields[2]
			#if "G02" in net or "G03" in net:
			#	print >> sys.stderr, "A " + net
			if net in hints:
				net = hints[net]
				#print >> sys.stderr, "B " + net
			net = net.replace("+","p")
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
					if out[:1] == "_":
						out = "u" + out[1:]
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
					for i in range(0, len(ins)):
						input = ins[i]
						if input[:1] == "_":
							ins[i] = "u" + input[1:]
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
		if name1 == "" or name2 == "":
			return
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
			#if refd == "U7007":
			#	print synonyms
			#	print pins
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
	
	# The stuff above allows input pins of "GND", which we don't want.
	for r in normalizedComponents:
		while "GND" in normalizedComponents[r]["ins"]:
			normalizedComponents[r]["ins"].remove("GND")
	
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

if len(sys.argv) < 3:
	print >> sys.stderr, "Try:  netlisterOP2.py MIKE_NETLIST RON_VERILOG [LEVEL]"
	sys.exit(1)
heuristicLevel = 0
if len(sys.argv) >= 4:
	heuristicLevel = int(sys.argv[3])

# Input the data and normalize it however we can.
mikeComponents = inputAndParseNetlistFile(sys.argv[1])
mikeNormalized = normalizeComponents(mikeComponents)
ronNormalized = inputAndParseVerilogFile(sys.argv[2])

# Make some helpful data structures to facilitate comparisons.
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

# Actually, it turns out that the xxxByOuts structures we just created are used for 
# almost everything, and the xxxComponents and xxxNormalized structures we created 
# first are used for nothing ever again.  Go figure!  Let's just get rid of them,
# to avoid confusion.
synonyms = mikeNormalized["synonyms"]
del mikeComponents
del mikeNormalized
del ronNormalized

# Let's apply the synonyms.  We'll just always use the first one in each equivalence class.
# First, all output nets.
for synonym in synonyms:
	master = synonym[0]
	for syn in synonym[1:]:
		if syn in mikeByOuts:
			if master in mikeByOuts:
				for input in mikeByOuts[syn]["ins"]:
					if input not in mikeByOuts[master]["ins"]:
						mikeByOuts[master]["ins"].append(input)
			else:
				mikeByOuts[master] = mikeByOuts[syn]
			mikeByOuts.pop(syn, None)
# Now all the input nets.
synonymsSecondary = {}
for synonym in synonyms:
	for syn in synonym[1:]:
		synonymsSecondary[syn] = synonym[0]
for output in mikeByOuts:
	for i in range(0, len(mikeByOuts[output]["ins"])):
		if mikeByOuts[output]["ins"][i] in synonymsSecondary:
			mikeByOuts[output]["ins"][i] = synonymsSecondary[mikeByOuts[output]["ins"][i]]

# Everything else below is just matching stuff between the Mike netlists and Ron netlists.  

bigDeducedNets = {}
passNumber = 0
count1 = 1
count1O = 1
count1I = 1
count1R = 0
for h in range(0, heuristicLevel + 1):
	print "Heuristic level " + str(h)
	
	# At "heuristic level" 0, we make only logically-inescapable inferences.  At level
	# 1, we first make some guesses related to the fact that Mike sometimes moved NOR
	# gates from one module to another, to avoid creating backplane signals that would 
	# otherwise have been needed to interconnect the modules.  Often, but not always,
	# these signals retained their names locally within a module, and therefore (in the
	# netlist) are systematically similar but not identical to the signals in my design
	# (which are all still passed on the backplane.
	if h == 1:
		# First, identify all possible candidate signals in Mike's design for 
		# possible truncation.  That basically means that signals like
		# "_Ann_n_SOMETHING" or "_Bnn_n_SOMETHING" are candidates to become
		# just "SOMETHING".  However, we can't determine that immediately, since
		# we'll only know if there might be some potential conflict if there are
		# multiple such cases but with differing _Ann_n_ or _Bnn_n_ prefixes.
		# So we store up a list of candidates, but only make the final decision
		# on them after all the candidates are known. 
		mikeSignalList = []
		for out in mikeByOuts:
			if out not in mikeSignalList:
				mikeSignalList.append(out)
			for input in mikeByOuts[out]["ins"]:
				if input not in mikeSignalList:
					mikeSignalList.append(input)
		ronSignalList = []
		for out in ronByOuts:
			if out not in ronSignalList:
				ronSignalList.append(out)
			for input in ronByOuts[out]["ins"]:
				if input not in ronSignalList:
					ronSignalList.append(input)
		candidates = {}
		for signal in mikeSignalList:
			matchedPrefix = False
			if signal[:16] == "_RestartMonitor_":
				truncatedSignalName = signal[16:]
				matchedPrefix = True
			elif heuristicPattern1.match(signal[:7]) != None:
				truncatedSignalName = signal[7:]
				matchedPrefix = True
			if matchedPrefix and truncatedSignalName in ronSignalList:
				if truncatedSignalName in candidates:
					if signal not in candidates[truncatedSignalName]:
						candidates[truncatedSignalName].append(signal)
				else:
					candidates[truncatedSignalName] = [ signal ]
		# Next, determine if there are potential conflicts among the candidates, and 
		# retain just the ones for which there aren't any conflicts.
		deducedNets = {}
		for signal in candidates:
			if len(candidates[signal]) == 1:
				deducedNets[candidates[signal][0]] = signal
		# Finally, act on the list of retained candidates, by actually translating
		# signal names based on it.
		count1 = 0
		count1O = 0
		count1I = 0
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
		print "In heuristic 1, " + str(count1O) + " outputs and " + str(count1I) + " inputs were translated"
	
	while count1 + count1O + count1I + count1R != 0:
		passNumber += 1
		count1 = 0
		count1O = 0
		count1I = 0
		count1R = 0
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
		if "RCH13_" in deducedNets:
			print "A RCH13_ => " + deducedNets["RCH13_"]
		if "CCH13" in deducedNets:
			print "A CCH13 => " + deducedNets["CCH13"]
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
		# inferred separately.  However, that doesn't always happen.)  Note that sometimes there 
		# may be two separate gates with identical sets of inputs.  I'm just going to ignore those.
		mikeByIns = {}
		mikeIgnore = []
		ronByIns = {}
		ronIgnore = []
		bypass = False
		for out in mikeByOuts:
			component = mikeByOuts[out]
			ins = component["ins"]
			ins.sort()
			inkey = str(ins)
			if inkey in mikeIgnore:
				continue
			if inkey in mikeByIns:
				mikeIgnore.append(inkey)
				mikeByIns.pop(inkey, None)
			else:
				mikeByIns[str(ins)] = { "refd":component["refd"], "out":out, "matched":component["matched"] }
		for out in ronByOuts:
			component = ronByOuts[out]
			ins = component["ins"]
			ins.sort()
			inkey = str(ins)
			if inkey in ronIgnore:
				continue
			if inkey in ronByIns:
				ronIgnore.append(inkey)
				ronByIns.pop(inkey, None)
			else:
				ronByIns[str(ins)] = { "refd":component["refd"], "out":out, "matched":component["matched"] }
		#testkey = "['F5ASB2']"
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
		
		if "RCH13_" in deducedNets:
			print "B RCH13_ => " + deducedNets["RCH13_"]
		if "CCH13" in deducedNets:
			print "B CCH13 => " + deducedNets["CCH13"]
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
		
		# Consider the following situation  
		#	out = UNMATCHED_NET1
		#	ins = [ UNMATCHED_NET2, MATCHED_NET1, MATCHED_NET2, ... ]
		# None of the stuff so far allows us to deduce the unmatched nets in this scenario.
		# But consider the following:  Suppose we know also that MATCHED_NETn feeds into
		# *only* one input, anywhere globally.  In that case, we can deduce that the 
		# stuff above is that single place MATCHED_NETn feeds into, and thus can match
		# the two unmatched nets in it.
		#
		# As it happens, we can loosen up the requirements a little bit.  Suppose that
		# MATCHED_NETn feeds not into just 1 other gate as an input, but into (say) N
		# other gates.  But suppose that N-1 of those other gates have already had
		# all of their inputs and outputs fully matched up, leaving just one of the 
		# gates being feed into that hasn't.  As long as we can eliminate those other
		# N-1 gates, we know that the last one must be the one we want to match to!
		mikeByIns = {}
		for output in mikeByOuts:
			for input in mikeByOuts[output]["ins"]:
				if input not in mikeByIns:
					mikeByIns[input] = [ output ]
				elif output not in mikeByIns[input]:
					mikeByIns[input].append(output)
		ronByIns = {}
		for output in ronByOuts:
			for input in ronByOuts[output]["ins"]:
				if input not in ronByIns:
					ronByIns[input] = [ output ]
				elif output not in ronByIns[input]:
					ronByIns[input].append(output)
		deducedNets = {}
		for input in mikeByIns:
			if input not in ronByIns:
				continue
			mikeFeeds = mikeByIns[input]
			ronFeeds = ronByIns[input]
			numFeeds = len(mikeFeeds)
			if len(ronFeeds) != numFeeds:
				continue
			mikeOutput = ""
			ronOutput = ""
			numUnmatched = 0
			for uo in mikeFeeds:
				if uo in ronFeeds:
					continue
				mikeOutput = uo
				numUnmatched += 1
			if numUnmatched != 1:
				continue
			for uo in ronFeeds:
				if uo not in mikeFeeds:
					ronOutput = uo
					break
			mikeInputs = mikeByOuts[mikeOutput]["ins"]
			ronInputs = ronByOuts[ronOutput]["ins"]
			if len(mikeInputs) != len(ronInputs):
				# This shouldn't be possible, logically, but still ...
				continue
			# Let's double-check that there's only one unmatched input.
			mikeInput = ""
			ronInput = ""
			numUnmatched = 0
			for ui in mikeInputs:
				if ui not in ronInputs:
					mikeInput = ui
					numUnmatched += 1
			if numUnmatched != 1:
				continue
			for ui in ronInputs:
				if ui not in mikeInputs:
					ronInput = ui
					break
			# All right, everything seems swell.
			deducedNets[mikeOutput] = ronOutput
			deducedNets[mikeInput] = ronInput
		if "RCH13_" in deducedNets:
			print "C RCH13_ => " + deducedNets["RCH13_"]
		if "CCH13" in deducedNets:
			print "C CCH13 => " + deducedNets["CCH13"]
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
for out in ronByOuts:
	if out == "":
		continue
	component = ronByOuts[out]
	component["ins"].sort()
for out in mikeByOuts:
	if out == "":
		continue
	component = mikeByOuts[out]
	component["ins"].sort()
f = open("netlisterOP2.ron", "w")
for out in ronByOuts:
	if out == "":
		continue
	component = ronByOuts[out]
	if out not in mikeByOuts:
		status = "+"
	elif str(component["ins"]) == str(mikeByOuts[out]["ins"]):
		status = "="
	else:
		status = "!"
	f.write(status + " " + component["refd"] + ": out=" + out + " ins=" + str(component["ins"]) + "\n")
f.close()
f = open("netlisterOP2.mike", "w")
for out in mikeByOuts:
	if out == "":
		continue
	component = mikeByOuts[out]
	if out not in ronByOuts:
		status = "+"
	elif str(component["ins"]) == str(ronByOuts[out]["ins"]):
		status = "="
	else:
		status = "!"
	f.write(status + " " + component["refd"] + ": out=" + out + " ins=" + str(component["ins"]) + "\n")
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
f.close()


