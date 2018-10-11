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
# Filename: 	dumbInitialization.py
# Purpose:	In a dumb manner, try to create flip-flop initialization data for 
#		Verilog files made by dumbVerilog.py.  The idea is to set all of the
#		nets to 0, and then just keep reevaluating the logic (in a random
#		order that changes with each iteration) until the values no longer
#		change.  This is then a globally consistent initialization.
#		It works, and converges pretty fast.
# Mod history:	2018-10-03 RSB	Created.
#		2018-10-04 RSB	Handled nets driven from different modules.
#		2018-10-05 RSB	Now additionally outputs a file called
#				dumbInitialization.log, which lists the 
#				initialization values assigned to each 
#				applicable net, nicely alphabetized.
#		2018-10-11 RSB	Should work with both WIRETYPEs now (instead
#				of just with "wand").  For some reason, 
#				including STOPA in the list of nets that 
#				initialize to 0 causes the process not to
#				converge, so I've had to remove it.  Added
#				a number of other explicit initializations,
#				though, to help get a pretty simulation rather
#				than just a correct one.  Specifically, 
#				gets rid of a bunch of involuntaries at startup.

# Usage is:
#	cat VERILOG_FILES | dumbInitialization.py
# where the input VERILOG_FILES include files for A1 through A24.
# The result is a series of files A1.init, A2.init, ..., A24.init.
# You can use a smaller set of module files, but the initialization will
# be independent of the modules that aren't included, and therefore
# possibly inconsistent with them.

import sys
import random

# Certain flip-flops we want to make sure are initialized specifically to 0 or 1.  
# I'm told (and my experience is) that the only one that actually matters is STNDBY.  
# However, explicitly initializing other flip-flops can be helpful helpful in terms
# of getting a nice setup that produces a simulation without various extraneous stuff
# at startup (like PINCs) that I usually want to ignore, or that I'd like to use in
# making comparisons with other simulations (like Mike's) that initialize differently.  
# Realize that these wishes may not always be possible to achieve, in which case
# this process will never converge, or that the settings might be immediately
# undone at startup by some other flip-flops that are initialized wrong.  So
# some care needs to be taken in these selections.
want0 = [
	# STNDBY is controlled from a B-module that we're not simulating.
	"STNDBY"
]
want1 = [
	# This zeroes the 32-bit counter in scaler module A1.
	"g38104", "g38114", "g38124", "g38134", "g38144", "g38154", "g38164", "g38174",
	"g38204", "g38214", "g38224", "g38234", "g38244", "g38254", "g38264", "g38274",
	"g38304", "g38314", "g38324", "g38334", "g38344", "g38354", "g38364", "g38374",
	"g38404", "g38414", "g38424", "g38434", "g38444", "g38454", "g38464", "g38474",
	"g38105", "g38115", "g38125", "g38135", "g38145", "g38155", "g38165", "g38175",
	"g38205", "g38215", "g38225", "g38235", "g38245", "g38255", "g38265", "g38275",
	"g38305", "g38315", "g38325", "g38335", "g38345", "g38355", "g38365", "g38375",
	"g38405", "g38415", "g38425", "g38435", "g38445", "g38455", "g38465", "g38475",
	# This zeroes the flip-flops in counter modules A20-A21 can otherwise trigger
	# a bunch of involuntaries (PINC etc.) on registers 024-060 at startup.
	"g31132", "g31129", # 24
	"g31139", "g31136", # 25
	"g31146", "g31143", # 26
	"g31232", "g31229", # 27
	"g31239", "g31236", # 30
	"g31246", "g31243", # 31
	"g31106", "g31102", "g31109", # 32
	"g31119", "g31115", "g31124", # 33
	"g32108", "g31202", "g31209", # 34
	"g31219", "g31215", "g31224", # 35
	"g31306", "g31302", "g31309", # 36
	"g31319", "g31315", "g31324", # 37
	"g31406", "g31402", "g31409", # 40
	"g31419", "g31415", "g31424", # 41
	"g32506", "g32502", "g32509", # 42
	"g32519", "g32515", "g32524", # 43
	"g32608", "g32602", "g32609", # 44
	"g32619", "g32615", "g32624", # 45
	"g32632", "g32629", "g32636", # 46
	"g32646", "g32643", # 47
	"g31332", "g31329", # 50
	"g31341", "g31336", # 51
	"g31346", "g31343", # 52
	"g31432", "g31429", # 53
	"g31439", "g31436", # 54
	"g31446", "g31443", # 55
	"g32532", "g32529", # 56
	"g32539", "g32536", # 57
	"g32546", "g32543"  # 60
]

random.seed(12345)

# Read all of the concatenated input Verilog files.
lines = sys.stdin.readlines()

# The way dumbVerilog.py creates the Verilog files, each input, output, inout, 
# internal net is named uniquely.  Moreover, each "assign" statement is 
# accompanied by a comment that tells which specific gates' outputs it applies
# to.  Therefore, to build up the data describing the electrical structure,
# all we need to look at is the "assign" statements and their accompanying comments.
# For our purposes, each "assign" statement (i.e., each gate) is completely
# described by:
#	Its reference designator and pin (or in this case, the list of connected ones).
#	Its output netname.
#	Its input netnames.
nors = {}
netValues = {}
module = ""
for line in lines:
	fields = line.strip().split()
	# "module" line.
	if len(fields) == 3 and fields[0] == "module":
		module = fields[1]
		continue
	# Comment field associated with following "assign".
	if len(fields) >= 3 and fields[0] == "//" and fields[1] == "Gate":
		gates = fields[2:]
		continue
	# "assign" statements have several possible forms, but there's always one or 
	# the other of the following: 
	#	assign ... OUTNET = ... !(0|INNET1|INNET2|...)...
	#	assign ... OUTNET = ... ((0|INNET1|INNET2|...)...
	if len(fields) < 1:
		continue
	if fields[0] != "assign":
		continue
	j = 0
	for i in range(2, len(fields)):
		if fields[i] == "=":
			j = i
			outnet = fields[j - 1]
			break
	if j == 0:
		continue
	innets = []
	for i in range(j + 1, len(fields)):
		if fields[i][:4] in ["((0|", "!(0|"]:
			k = fields[i].find(")")
			if k < 5:
				continue
			stripped = fields[i][4:k]
			innets = stripped.split("|")
	if len(innets) < 1:
		continue
	#print outnet
	#print innets
	# Save the data in structures.
	if outnet not in nors:
		nors[outnet] = { "gates":gates, "innets":innets }
	else:
		nors[outnet] = { "gates":(nors[outnet]["gates"]+gates), "innets":(nors[outnet]["innets"]+innets) }
	if outnet not in netValues:
		netValues[outnet] = False
	for innet in innets:
		if innet not in netValues:
			netValues[innet] = False
if "STRT2" in netValues:
	netValues["STRT2"] = True
else:
	print >> sys.stderr, "Warning: Could not find signal STRT2."

# Now iterate the logic until nothing changes.  Once you've reached that 
# point, the ordering of the evaluations no longer matters at all, and you
# have a consistent setup.  Note that I put a limit of a thousand iterations
# on this.  For the full 2003200 design, it actually converges after about
# 15 iterations.  There are about 2300 changes in the first iteration, 1200
# in the second, 600 in the third, and so on.  In other words, works great! 
unchanged = 0
count = 0
numchanged = 0
changed = []
while unchanged < 2:
	count += 1
	if count > 1000:
		print "Did not converge."
		sys.exit(1)
	if numchanged <= 100:
		print "Iteration " + str(count) + " " + str(numchanged) + " " + str(changed)
	else:
		print "Iteration " + str(count) + " " + str(numchanged) + " [...]"
	unchanged += 1
	numchanged = 0
	changed = []
	# Certain flip-flops we want to make sure are initialized specifically to 0 or 1.  
	for netName in want0:
		netValues[netName] = False
	for netName in want1:
		netValues[netName] = True
	
	# Choose a random evaluation order.
	randomNors = []
	for netName in nors:
		randomNors.append(netName)
	random.shuffle(randomNors)
	
	# Evaluate all of the logic, in the chosen order.
	for norNet in randomNors:
		value = False
		for netName in nors[norNet]["innets"]:
			value = value or netValues[netName]
		value = not value
		if value != netValues[norNet]:
			unchanged = 0
			numchanged += 1
			changed.append(norNet)
		netValues[norNet] = value	

for netName in []:
	print netName + " = " + str(netValues[netName]) + ", " + str(nors[netName])
#print nors

ones = []
#zeroes = []
for norNet in nors:
	if not netValues[norNet]:
		#for nor in nors[norNet]["gates"]:
		#	zeroes.append(nor)
		continue
	for nor in nors[norNet]["gates"]:
		ones.append(nor)

# Create the MODULE.init files.
for moduleNumber in range(1, 25) + [99]:
	f = open("A" + str(moduleNumber) + ".init", "w")
	f.write("# Auto-generated for module A" + str(moduleNumber) + " by dumbInitialization.py.\n")
	for sheet in range(1, 5):
		for location in range(1, 72):
			localRefd = "U" + str(sheet)
			if location < 10:
				localRefd += "0"
			localRefd += str(location)
			refd = "A" + str(moduleNumber) + "-" + localRefd
			j = 0
			k = 0
			if (refd + "A") in ones:
				j = 1
			if (refd + "B") in ones:
				k = 1
			if j == 1 or k == 1:
				f.write(localRefd + " " + str(j) + " " + str(k) + "\n")
	f.close()

# Print out a nice report about this.
#ones.sort()
#print ones
netNames = []
for netName in netValues:
	netNames.append(netName)
netNames.sort()
f = open("dumbInitialization.log", "w")
for netName in netNames:
	if netName in netValues:
		if netValues[netName]:
			value = "1"
		else:
			value = "0"
	f.write(netName + " = " + value + "\n")
f.close()

	

