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
# Mod history:	2018-08-03 RSB	Created.
#		2018-08-04 RSB	Handled nets driven from different modules.

# Usage is:
#	cat VERILOG_FILES | dumbInitialization.py
# where the input VERILOG_FILES include files for A1 through A24.
# The result is a series of files A1.init, A2.init, ..., A24.init.
# You can use a smaller set of module files, but the initialization will
# be independent of the modules that aren't included, and therefore
# possibly inconsistent with them.

import sys
import random

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
	# "assign" statements have several possible forms: 
	#	assign [STRENGTH] [#DELAY] OUTNET = rst ? INIT : ~(0|INNET1|INNET2|...);
	if len(fields) == 8 and fields[0] == "assign" and fields[2] == "=":
		outnet = fields[1]
		innets = fields[7].strip("~();").split("|")[1:]
	elif len(fields) == 9 and fields[0] == "assign" and fields[3] == "=":
		outnet = fields[2]
		innets = fields[8].strip("~();").split("|")[1:]
	elif len(fields) == 10 and fields[0] == "assign" and fields[4] == "=":
		outnet = fields[3]
		innets = fields[9].strip("~();").split("|")[1:]
	else:
		continue
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
while unchanged < 2:
	count += 1
	if count > 1000:
		print "Did not converge."
		sys.exit(1)
	print "Iteration " + str(count) + " " + str(numchanged)
	unchanged += 1
	numchanged = 0
	# Certain flip-flops we want to make sure are initialized specifically to 0 or 1.  
	# I'm led to believe that this doesn't actually matter, but it's helpful
	# to me whilst debugging without any software running on the simulated AGC.
	# Realize that these wishes may not always be possible to achieve.
	for netName in ["STNDBY", "STOPA"]:
		netValues[netName] = False
	for netName in []:
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
for moduleNumber in range(1, 25):
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

#ones.sort()
#print ones
