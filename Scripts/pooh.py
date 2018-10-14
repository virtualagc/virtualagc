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
# LXT2 file.  Other dump formats might work, but I don't care ... LXT2
# is the scenario I support.  This program is used either to work with
# a single dumpfile,
#
#	lxt2vcd --flatearth DUMPED.lxt2 | pooh.py [OPTIONS] >OUTPUTFILE
#
# or else to compare two dumpfiles,
#
#	lxt2vcd --flatearth DUMPED2.lxt2 >DUMPED2.vcd
#	lxt2vcd --flatearth DUMPED1.lxt2 | pooh.py --compare=DUMPED2.vcd [OPTIONS] >OUTPUTFILE
#	rm DUMPED2.vcd
#
# 'lxt2vcd' is a utility program from Icarus Verilog.  You may think
# that having 'vvp' just dump to VCD format would be more straightforward,
# but that won't work since the --flatearth option is required; moreover,
# the dumped files would generally be enormously bigger.  Sadly, with the
# comparison functionality, I don't know any good way to get around having
# the temporary VCD file. I guess (in Linux at least) you could use a named
# pipe, although I hesitate to suggest such tricksy stuff.

import sys

# Here's a dictionary used to translate various of Mike's signal names that can't
# be dealt with formulaically into my signal names, even after they've already
# been normalized.
normalizedMikeNets = { 
	"A08.__A08_1___A1_":"A01_", "A08.__A08_1___A2_":"A02_",
	"A08.__A08_2___A1_":"A03_", "A08.__A08_2___A2_":"A04_",
	"A09.__A09_1___A1_":"A05_", "A09.__A09_1___A2_":"A06_",
	"A09.__A09_2___A1_":"A07_", "A09.__A09_2___A2_":"A08_",
	"A10.__A10_1___A1_":"A09_", "A10.__A10_1___A2_":"A10_",
	"A10.__A10_2___A1_":"A11_", "A10.__A10_2___A2_":"A12_",
	"A11.__A11_1___A1_":"A13_", "A11.__A11_1___A2_":"A14_",
	"A08.__L03_":"L03_", 
	"A09.__L05_":"L05_", "A09.__L06_":"L06_", "A09.__L07_":"L07_", 
	"A10.__L09_":"L09_", "A10.__L10_":"L10_", "A10.__L11_":"L11_",  
	"A11.__L13_":"L13_", "A11.__L14_":"L14_",
	"A08.__A08_1___Z1_":"Z01_", "A08.__A08_1___Z2_":"Z02_",
	"A08.__A08_2___Z1_":"Z03_", "A08.__A08_2___Z2_":"Z04_",
	"A09.__A09_1___Z1_":"Z05_", "A09.__A09_1___Z2_":"Z06_",
	"A09.__A09_2___Z1_":"Z07_", "A09.__A09_2___Z2_":"Z08_",
	"A10.__A10_1___Z1_":"Z09_", "A10.__A10_1___Z2_":"Z10_",
	"A10.__A10_2___Z1_":"Z11_", "A10.__A10_2___Z2_":"Z12_",
	"A11.__A11_1___Z1_":"Z13_", "A11.__A11_1___Z2_":"Z14_",
	"A15.__A15_1__FB16":"FB16", "A15.__A15_1__FB14":"FB14", 
	"A15.__A15_1__FB13":"FB13", "A15.__A15_1__FB12":"FB12", 
	"A15.__A15_1__FB11":"FB11", 
	"A15.__A15_1__EB11":"EB11"
}

wantTransitions = False
wantNets = False

def readVCD(nameOfVcd, openFile):
	
	netsByID = {}
	netsByPrimaryNetname = {}
	time = 0
	
	print >> sys.stderr, "Reading netnames for " + nameOfVcd
	
	# Read the input, line by line.  We'll only need a single pass on the input.
	inDumpvars = False
	for line in openFile:
		line = line.strip()
		fields = line.split()
		if inDumpvars:
			if len(fields) == 1:
				if fields[0][:1] == "#":
					time = int(fields[0][1:])
					if picosecondScale:
						time /= 1000
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
			if not wantTransitions:
				break
			print >> sys.stderr, "Reading transitions for " + nameOfVcd
		elif len(fields) == 3 and fields[0] == "$timescale" and fields[2] == "$end":
			if fields[1] == "1ps":
				picosecondScale = True
			elif fields[1] == "1ns":
				picosecondScale = False
		elif len(fields) == 7 and fields[0] == "$var" and fields[1] == "wire" and fields[6] == "$end":
			width = int(fields[2])
			id = fields[3]
			netname = fields[4]
			mask = fields[5]
			# Normalize the netnames a tad.
			rawNetname = netname
			if netname[:4] == "agc.":
				netname = netname[4:]
			elif netname[:9] == "main.AGC.":
				netname = netname[9:]
			elif netname[:5] == "main.":
				netname = netname[5:]
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
				netsByID[id] = { "netnames":[netname], "rawNetnames":[rawNetName], "width":width, 
					"mask":mask, "transitions":[], "values":[], "desired":False }
				if netname in desiredNetnames:
					netsByID[id]["desired"] = True
	
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
	elif argv[:1] == "-":
		print >> sys.stderr, "Unknown command-line argument: " + argv
		error = True
	else:
		desiredNetnames.append(argv)
if count != 1:
	print >> sys.stderr, "Must select exactly one of the following: --transitions --nets"
	error = True
if error:
	sys.exit(1)
error = False

if compare == "":
	# Single-file operation.
	vcd = readVCD("vcd", sys.stdin)
	for netname in desiredNetnames:
		if netname in vcd["byNetname"]:
			print "Net \"" + netname + "\" found in the input"
		else:
			print "Net \"" + netname + "\" not found in the input"
			error = True
	if error:
		sys.exit(1)
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
