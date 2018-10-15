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
# Filename: 	pooh.py
# Purpose:	Dump analyzer for iverilog simulation of AGC, optimized
#		for either my simulations or Mike Stewart's simulations,
#		and principally intended for comparisons between the two.
#		Where there's a netnaming discrepancy, Mike's netnames are
#		converted to mine, which are generally much more convenient,
#		when I'm able to figure out how and am motivated.
# References:	https://github.com/virtualagc/virtualagc/tree/schematics
#		https://github.com/virtualagc/agc_simulation
#		https://github.com/virtualagc/agc_hardware
# Mod history:	2018-10-14 RSB	Began.
#
# The idea here is that the simulations are performed with the Icarus
# Verilog program 'vvp' in such a way as to dump simulation data into an
# FST file.  Other dump formats might work, but I don't care ... FST
# is the scenario I support.  (Note, lxt2vcd has bugs that cause LXT2 not
# to work for this with a current stock version of iverilog.)  This program
# is used either to work with a single dumpfile,
#
#	fst2vcd DUMPED.fst | pooh.py [OPTIONS] >OUTPUTFILE
#
# or else to compare two dumpfiles,
#
#	fst2vcd DUMPED2.fst >DUMPED2.vcd
#	fst2vcd DUMPED1.fst | pooh.py --compare=DUMPED2.vcd [OPTIONS] >OUTPUTFILE
#	rm DUMPED2.vcd
#
# 'fst2vcd' is a utility program from gtkwave.  You may think
# that having 'vvp' just dump to VCD format would be more straightforward,
# and it would, but the dumped files would generally be enormously bigger.  
# Sadly, with the comparison functionality, I don't know any good way to 
# get around having the temporary VCD file. I guess (in Linux at least) 
# you could use a named pipe, although I hesitate to suggest such tricksy 
# stuff.

import sys

# Here's a dictionary used to translate various of Mike's signal names that can't
# be dealt with formulaically into my signal names, even after they've already
# been normalized.
normalizedMikeNets = { 
	"iA8.__A08_1___A1_":"A01_", "iA8.__A08_1___A2_":"A02_",
	"iA8.__A08_2___A1_":"A03_", "iA8.__A08_2___A2_":"A04_",
	"iA9.__A09_1___A1_":"A05_", "iA9.__A09_1___A2_":"A06_",
	"iA9.__A09_2___A1_":"A07_", "iA9.__A09_2___A2_":"A08_",
	"iA10.__A10_1___A1_":"A09_", "iA10.__A10_1___A2_":"A10_",
	"iA10.__A10_2___A1_":"A11_", "iA10.__A10_2___A2_":"A12_",
	"iA11.__A11_1___A1_":"A13_", "iA11.__A11_1___A2_":"A14_",
	"iA8.__L03_":"L03_", 
	"iA9.__L05_":"L05_", "iA9.__L06_":"L06_", "iA9.__L07_":"L07_", 
	"iA10.__L09_":"L09_", "A10.__L10_":"L10_", "iA10.__L11_":"L11_",  
	"iA11.__L13_":"L13_", "iA11.__L14_":"L14_",
	"iA8.__A08_1___Z1_":"Z01_", "iA8.__A08_1___Z2_":"Z02_",
	"iA8.__A08_2___Z1_":"Z03_", "iA8.__A08_2___Z2_":"Z04_",
	"iA9.__A09_1___Z1_":"Z05_", "iA9.__A09_1___Z2_":"Z06_",
	"iA9.__A09_2___Z1_":"Z07_", "iA9.__A09_2___Z2_":"Z08_",
	"iA10.__A10_1___Z1_":"Z09_", "iA10.__A10_1___Z2_":"Z10_",
	"iA10.__A10_2___Z1_":"Z11_", "iA10.__A10_2___Z2_":"Z12_",
	"iA11.__A11_1___Z1_":"Z13_", "iA11.__A11_1___Z2_":"Z14_",
	"iA15.__A15_1__FB16":"FB16", "iA15.__A15_1__FB14":"FB14", 
	"iA15.__A15_1__FB13":"FB13", "iA15.__A15_1__FB12":"FB12", 
	"iA15.__A15_1__FB11":"FB11", 
	"iA15.__A15_1__EB11":"EB11",
	"iA3.IC2":"IC2",
	"iA4.__A04_1__STG1":"STG1", "iA4.__A04_1__STG2":"STG2", "iA4.__A04_1__STG3":"STG3", 
	"iA3.__A03_1__WSQG_":"WSQG_",
	"iA3.__A03_1__RPTFRC":"RPTFRC",
	"iA21.__A21_1__SHINC":"SHINC", "iA21.__A21_1__SHANC":"SHANC"
}

wantTransitions = False
wantNets = False
wantConvert = False

def readVCD(nameOfVcd, openFile):
	scope = []
	scopeString = ""
	inTimescale = False
	
	netsByID = {}
	netsByPrimaryNetname = {}
	time = 0
	namesFound = {}
	
	print >> sys.stderr, "Reading netnames for " + nameOfVcd
	
	# Read the input, line by line.  We'll only need a single pass on the input.
	inDumpvars = False
	for line in openFile:
		line = line.strip()
		fields = line.split()
		skip = False
		if inDumpvars:
			if len(fields) == 1:
				if fields[0][:1] == "#":
					time = int(fields[0][1:])
					if picosecondScale:
						time /= 1000
						if wantConvert:
							line = "#" + str(time)
					#print >> sys.stderr, time
				else:
					value = fields[0][:1]
					id = fields[0][1:]
					if netsByID[id]["desired"]:
						netsByID[id]["transitions"].append(time)
						netsByID[id]["values"].append(value)
			elif len(fields) == 2:
				value = fields[0]
				id = fields[1]
				if netsByID[id]["desired"]:
					netsByID[id]["transitions"].append(time)
					netsByID[id]["values"].append(value)
			else:
				print >> sys.stderr, "Dumpvars corrupt line " + line
				sys.exit(1)
		elif len(fields) == 1 and fields[0] == "$dumpvars":
			inDumpvars = True
			for id in netsByID:
				netname = netsByID[id]["netnames"][0]
				width = netsByID[id]["width"]
				mask = netsByID[id]["mask"]
				if netname in netsByPrimaryNetname:
					print >> sys.stderr, "Duplication of primary netname: " + netname
					sys.exit(1)
				netsByPrimaryNetname[netname] = { "id":id, "width":width, "mask":mask }
			if not wantTransitions and not wantConvert:
				break
			print >> sys.stderr, "Reading transitions for " + nameOfVcd
		elif len(fields) == 4 and fields[0] == "$scope" and fields[1] == "module" and fields[3] == "$end":
			scope.append(fields[2])
			scopeString += fields[2] + "."
			skip = True
		elif len(fields) == 2 and fields[0] == "$upscope" and fields[1] == "$end":
			del scope[-1]
			if len(scope) < 1:
				scopeString = ""
			else:
				scopeString = ""
				for field in scope:
					scopeString += field + "."
			skip = True
		elif len(fields) == 3 and fields[0] == "$timescale" and fields[2] == "$end":
			if fields[1] == "1ps":
				picosecondScale = True
			elif fields[1] == "1ns":
				picosecondScale = False
			if wantConvert:
				line = "$timescale 1ns $end"
		elif len(fields) == 1 and fields[0] == "$timescale":
			inTimescale = True
		elif len(fields) == 1 and inTimescale:
			if fields[0] == "$end":
				inTimescale = False
			else:
				if fields[0] == "1ps":
					picosecondScale = True
				elif fields[0] == "1ns":
					picosecondScale = False
				if wantConvert:
					line = "        1ns"
		elif len(fields) in [6, 7] and fields[0] == "$var" and fields[1] in ["wire", "reg"]:
			width = int(fields[2])
			id = fields[3]
			netname = scopeString + fields[4]
			if len(fields) == 6:
				mask = "[0]"
			else:
				mask = fields[5]
			# Normalize the netnames a tad.  More accurately, by "normalize" I mean
			# turn Mike's names into my names.
			rawNetname = netname
			if netname[:4] == "agc.":
				netname = netname[4:]
			elif netname[:13] == "main.AGC.B01.":
				netname = "iA99." + netname[13:]
			elif netname[:13] in [
				"main.AGC.A01.", "main.AGC.A02.", "main.AGC.A03.", "main.AGC.A04.", 
				"main.AGC.A05.", "main.AGC.A06.", "main.AGC.A07.", "main.AGC.A08.", 
				"main.AGC.A09.", "main.AGC.A10.", "main.AGC.A11.", "main.AGC.A12.", 
				"main.AGC.A13.", "main.AGC.A14.", "main.AGC.A15.", "main.AGC.A16.", 
				"main.AGC.A17.", "main.AGC.A18.", "main.AGC.A19.", "main.AGC.A20.", 
				"main.AGC.A21.", "main.AGC.A22.", "main.AGC.A23.", "main.AGC.A24."]:
				netname = "iA" + str(int(netname[10:12])) + "." + netname[13:]
			elif netname[:9] == "main.AGC.":
				netname = netname[9:]
			elif netname[:5] == "main.":
				netname = netname[5:]
			if netname[:1] == "n" and netname[1:2].isdigit():
				netname = "d" + netname[1:]
			if netname[-2:] == "_n":
				netname = netname[:-1]
			if netname in normalizedMikeNets:
				netname = normalizedMikeNets[netname]
			if id in netsByID:
				if netsByID[id]["width"] != width or netsByID[id]["mask"] != mask:
					print >> sys.stderr, "Field width/mask discrepancy: " + line
					sys.exit(1)
				netsByID[id]["netnames"].append(netname)
				netsByID[id]["rawNetnames"].append(rawNetname)
			else:
				netsByID[id] = { "netnames":[netname], "rawNetnames":[rawNetname], "width":width, 
					"mask":mask, "transitions":[], "values":[], "desired":False }
				if netname in desiredNetnames:
					netsByID[id]["desired"] = True
			
			if netname in namesFound:
				if namesFound[netname]["id"] == id:
					skip = True
				else:
					print >> sys.stderr, "Implementation error, dupe net \"" + \
						netname + "\", raw nets \"" + rawNetname + "\" and \"" + \
						namesFound[netname]["rawName"] + "\""
			else:
				namesFound[netname] = { "id":id, "rawName":rawNetname }
			if wantConvert:
				line = "$var wire " + str(width) + " " + id + " agc." + netname + " " + mask + " $end"
		if wantConvert and not skip:
			print line
	
	return { "byID":netsByID, "byNetname":netsByPrimaryNetname }

def printNets(nameOfVCD, vcd):
	print "$vcd " + nameOfVCD
	for netname in desiredNetnames:
		id = vcd["byNetname"][netname]["id"]
		transitions = vcd["byID"][id]["transitions"]
		values = vcd["byID"][id]["values"]
		print "$net " + netname
		if transitions[0] > 0:
			print "0 0"
		for i in range(0,len(transitions)):
			print str(transitions[i]) + " " + str(values[i])

def analyzeNetHierarchy(nameOfVCD, vcd):
	return

# Parse the command line:
compare = ""
desiredNetnames = []
error = False
count = 0
for argv in sys.argv[1:]:
	if argv[:10] == "--compare=":
		compare = argv[10:]
	elif argv == "--transitions":
		wantTransitions = True
		count += 1
	elif argv == "--nets":
		wantNets = True
		count += 1
	elif argv == "--convert":
		wantConvert = True
		count += 1
	elif argv[:1] == "-":
		print >> sys.stderr, "Unknown command-line argument: " + argv
		error = True
	else:
		desiredNetnames.append(argv)
if count != 1:
	print >> sys.stderr, "Must select exactly one of the following: --transitions --nets --convert"
	error = True
if error:
	sys.exit(1)
error = False

if compare == "":
	# Single-file operation.
	vcd = readVCD("vcd", sys.stdin)
	for netname in desiredNetnames:
		if netname in vcd["byNetname"]:
			print >> sys.stderr, "Net \"" + netname + "\" found in the input"
		else:
			print >> sys.stderr, "Net \"" + netname + "\" not found in the input"
			error = True
	if error:
		sys.exit(1)
	if wantConvert:
		sys.exit(0)
	if wantTransitions:
		printNets("vcd", vcd)
	if wantNets:
		analyzeNetHierarchy("vcd", vcd)
else:
	# Dual-file comparison operation.
	vcd1 = readVCD("vcd1", sys.stdin)
	try:
		f = open(compare, "r")
	except:
		print >> sys.stderr, "Cannot open the comparison input \"" + compare + "\""
		sys.exit(1)
	vcd2 = readVCD("vcd2", f)
	f.close()
	for netname in desiredNetnames:
		if netname in vcd1["byNetname"] and netname in vcd2["byNetname"]:
			print >> sys.stderr, "Net \"" + netname + "\" found in both inputs"
		elif netname in vcd1["byNetname"]:
			print >> sys.stderr, "Net \"" + netname + "\" found only in first input"
			error = True
		elif netname in vcd2["byNetname"]:
			print >> sys.stderr, "Net \"" + netname + "\" found only in second input"
			error = True
		else:
			print >> sys.stderr, "Net \"" + netname + "\" found in neither input"
			error = True
	if error:
		sys.exit(1)
	if wantTransitions:
		printNets("vcd1", vcd1)
		printNets("vcd2", vcd2)
	if wantNets:
		analyzeNetHierarchy("vcd1", vcd1)
		analyzeNetHierarchy("vcd2", vcd2)
