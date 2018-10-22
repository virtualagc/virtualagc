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
#		2018-10-21 RSB	Added --snapshot/--gap options, for trying
#				to get the configuration once it has
#				settled down a bit.  I'd recommend using
#				--snapshot=5100 --gap=100 for that, though
#				the truth is it never really settles down
#				very much.
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
from normalizedMikeNets import normalizedMikeNets

wantTransitions = False
wantNets = False
wantConvert = False
wantSymbols = False
wantSnapshot = False
snapTimeNanoseconds = -1
snapGapNanoseconds = -1

def readVCD(nameOfVcd, openFile):
	scope = []
	scopeString = ""
	xScope = []
	xScopeString = ""
	inTimescale = False
	scopeCount = 0
	lastTime = 0
	
	netsByID = {}
	time = 0
	
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
						time = (time + 500) / 1000
						if wantConvert or wantSnapshot:
							line = "#" + str(time)
					#print >> sys.stderr, time
					if wantSnapshot:
						gap = time - lastTime
						lastTime = time
						if time >= snapTimeNanoseconds:
						   if gap >= snapGapNanoseconds:
						   	#for n in netsByID:
						   	#	print netsByID[n]
							return { "byID":netsByID, "snapped":time, "gap":gap }
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
			if not wantTransitions and not wantConvert and not wantSnapshot:
				break
			print >> sys.stderr, "Reading transitions for " + nameOfVcd
		elif len(fields) == 4 and fields[0] == "$scope" and fields[1] == "module" and fields[3] == "$end":
			rawModule = fields[2]
			scope.append(rawModule)
			scopeString += rawModule + "."
			scopeCount += 1
			module = rawModule
			if module == "main":
				module = "agc"
			elif module == "AGC":
				module = "agc"
				skip = True
				scopeCount -= 1
			elif module == "B01":
				module = "iA99"
			elif module[:1] == "A" and module[1:].isdigit():
				module = "iA" + str(int(module[1:]))
			if not skip:
				xScope.append(module)
				xScopeString += module + "."
			line = "$scope module " + module + " $end"
		elif len(fields) == 2 and fields[0] == "$upscope" and fields[1] == "$end":
			del scope[-1]
			scopeCount -= 1
			if scopeCount < 0:
				skip = True
			else:
				del xScope[-1]
			if len(scope) < 1:
				scopeString = ""
				xScopeString = ""
			else:
				scopeString = ""
				xScopeString = ""
				for field in scope:
					scopeString += field + "."
				for field in xScope:
					xScopeString += field + "."
		elif len(fields) == 3 and fields[0] == "$timescale" and fields[2] == "$end":
			if fields[1] == "1ps":
				picosecondScale = True
			elif fields[1] == "1ns":
				picosecondScale = False
			if wantConvert or wantSnapshot:
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
			netname = fields[4]
			if len(fields) == 6:
				mask = "[0]"
			else:
				mask = fields[5]
			# Normalize the netnames a tad.  More accurately, by "normalize" I mean
			# turn Mike's names into my names.
			rawNetname = scopeString + netname
			if False:
				if netname[:2] == "__" and netname[2:5] != rawModule:
					netname = netname[2:]
				elif netname in normalizedMikeNets:
					netname = normalizedMikeNets[netname]
				elif netname[:2] == "__" and netname[2:5] == rawModule and netname[5:9] in ["_1__", "_2__", "_3__"]:
					 if netname[9] != "_" and not (netname[9] in ["X", "Y"] and netname[10].isdigit()) \
					 	and not (rawModule == "A20" and netname[9] == "C" and netname[10].isdigit()):
					 	netname = netname[9:]
			else:
				m = ""
				e = ""
				if netname[:3] == "__A" and netname[5:9] in ["_1__", "_2__", "_3__"]:
					m = netname[3:5]
					e = netname[9:]
				if netname in normalizedMikeNets:
					netname = normalizedMikeNets[netname]
				elif m != "" and e[0] in [
								"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", 
								"E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", 
								"S", "T", "U", "V", "W", "X", "Y", "Z"
							 ]:
					netname = e
			if netname[0].isdigit():
				netname = "d" + netname
			if netname[0] == "n" and netname[1].isdigit():
				netname = "d" + netname[1:]
			if netname[-2:] == "_n":
				netname = netname[:-1]
			xRawNetname = xScopeString + netname
			if id in netsByID:
				if netsByID[id]["width"] != width or netsByID[id]["mask"] != mask:
					print >> sys.stderr, "Field width/mask discrepancy: " + line
					sys.exit(1)
				if netname in netsByID[id]["netnames"]:
					skip = True
				netsByID[id]["netnames"].append(netname)
				netsByID[id]["rawNetnames"].append(rawNetname)
				netsByID[id]["xRawNetnames"].append(xRawNetname)
			else:
				netsByID[id] = { "netnames":[netname], "rawNetnames":[rawNetname], "width":width, 
					"mask":mask, "transitions":[], "values":[], "desired":False,
					"xRawNetnames":[xRawNetname] }
				if wantSnapshot or netname in desiredNetnames:
					netsByID[id]["desired"] = True
			if wantConvert:
				line = "$var wire " + str(width) + " " + id + " " + netname + " " + mask + " $end"
		if wantConvert and not skip:
			print line
	
	return { "byID":netsByID }

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
	elif argv[:11] == "--snapshot=" and argv[11:].isdigit():
		wantSnapshot = True
		snapTimeNanoseconds = int(argv[11:])
		count += 1
	elif argv[:6] == "--gap=" and argv[6:].isdigit():
		snapGapNanoseconds = int(argv[6:])
	elif argv == "--transitions":
		wantTransitions = True
		count += 1
	elif argv == "--nets":
		wantNets = True
		count += 1
	elif argv == "--convert":
		wantConvert = True
		count += 1
	elif argv == "--symbols":
		wantSymbols = True
		count += 1
	elif argv[:1] == "-":
		print >> sys.stderr, "Unknown command-line argument: " + argv
		error = True
	else:
		desiredNetnames.append(argv)
if count != 1:
	print >> sys.stderr, "Must select exactly one of the following: --transitions --nets --convert --symbols --snapshot=ns"
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
	if wantSymbols:
		symbols = []
		for id in vcd["byID"]:
			for i in range(0, len(vcd["byID"][id]["rawNetnames"])):
				print vcd["byID"][id]["rawNetnames"][i] + " -> " + vcd["byID"][id]["xRawNetnames"][i]
	if wantSnapshot:
		print "time : " + str(vcd["snapped"]) + " (" + str(snapTimeNanoseconds) + ") ns"
		print "gap : " + str(vcd["gap"]) + " (" + str(snapGapNanoseconds) + ") ns"
		for id in vcd["byID"]:
			entry = vcd["byID"][id]
			chips = ""
			for rawName in entry["rawNetnames"]:
				rawFields = rawName.split(".")
				if len(rawFields) >= 3:
					refd = rawFields[-3]
					unit = rawFields[-2]
					if rawFields[-1] == "y" and unit in ["A", "B", "C", "D", "E", "F"] and len(refd) in [5, 6] and refd[0] == "U" and refd[1:].isdigit():
						chips += " " + refd + unit
				#if len(rawFields) >= 1:
				#	gate = rawFields[-1]
				#	if len(gate) == 6 and gate[0] == "g" and gate[1:].isdigit():
				#		chips += " " + gate
			if len(entry["values"]) == 0:
				print "x = " + entry["netnames"][0] + chips
			else:
				print entry["values"][-1] + " = " + entry["netnames"][0] + chips
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
