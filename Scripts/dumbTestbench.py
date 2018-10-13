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
# Filename: 	dumbTestbench.py
# Purpose:	In a dumb manner, creates a Verilog testbench file for 
#		Verilog files made by dumbVerilog.py.
# Mod history:	2018-10-01 RSB	Created.
#		2018-10-04 RSB	Replaced wires by wands.  (Actually, works 
#				with either.)
#		2018-10-08 RSB	Replaced some hard-codeds stuff in the testbenches
#				with include-files.
#		2018-10-13 RSB	Added DEFAULT_GATE_DELAY.

# Usage is:
#	cat VERILOG_FILES | dumbTestbench.py >TESTBENCH.v

import sys

tbInclude = "tb.v"
if len(sys.argv) > 1:
	tbInclude = sys.argv[1]
DEFAULT_GATE_DELAY = "0.2"
if len(sys.argv) > 2:
	DEFAULT_GATE_DELAY = sys.argv[2]
# Read the tb.v file, so as to build up a list of the regs it defines, so that
# they can be removed from the list of the regs that we're going to autogenerate 
# later.
f = open(tbInclude, "r")
lines = f.readlines()
f.close()
tbIncludeRegs = []
for line in lines:
	fields = line.strip().split()
	if len(fields) >= 3 and fields[0] == "reg" and fields[2] == "=":
		tbIncludeRegs.append(fields[1])

wireType = "wire"

# Read all of the concatenated input Verlog files.
lines = sys.stdin.readlines()

# Parse the input we've just read for the inout/input/output wires.
inputs = []
outputs = []
inouts = []
declaration = ""
for line in lines:
	fields = line.strip().split();
	if len(fields) == 0:
		declaration = ""
		continue
	signals = []
	if len(fields) > 2 and fields[1] in ["wire", "wand"]:
		declaration = fields[0]
		signals = fields[2:]
	elif declaration != False:
		signals = fields
	else:
		continue
	for field in signals:
		signal = field.rstrip(",;")
		if signal in ["rst", "CLOCK"]:
			continue
		if declaration == "input":
			if signal not in inputs:
				inputs.append(signal)
		elif declaration == "output":
			if signal not in outputs:
				outputs.append(signal)
		elif declaration == "inout":
			if signal not in inouts:
				inouts.append(signal)

# Analyze the input/output/inout data to see what we want to classify
# as regs and what as wires.
regs = []
wires = []
for signal in inputs+inouts:
	if signal not in outputs:
		if signal not in inouts:
			if signal not in regs:
				if signal not in tbIncludeRegs:
					regs.append(signal)
for signal in inputs+inouts+outputs:
	if signal not in regs:
		if signal not in tbIncludeRegs:
			if signal not in wires:
				wires.append(signal)
regs.sort()
wires.sort()

# Write the output.
print "// Verilog testbench created by dumbTestbench.py"
print "`timescale 100ns / 1ns"
print ""
print "module agc;"
print ""
print "parameter GATE_DELAY = " + DEFAULT_GATE_DELAY + ";"
#print "initial $display(\"Gate Delay is %f ns.\", GATE_DELAY*100);"
print "`include \"" + tbInclude + "\""
print ""
desiredLineLength = 70
if len(regs) > 0:
	line = "reg"
	for i in range(0, len(regs)):
		reg = regs[i]
		if len(line) == 0:
			line = " "
		line += " " + reg + " = 0"
		if i < len(regs) - 1:
			line += ","
		else:
			line += ";"
		if len(line) >= desiredLineLength:
			print line
			line = ""
	if len(line) > 0:
		print line
	print ""
if len(wires) > 0:
	line = wireType
	for i in range(0, len(wires)):
		wire = wires[i]
		if len(line) == 0:
			line = " "
		line += " " + wire
		if i < len(wires) - 1:
			line += ","
		else:
			line += ";"
		if len(line) >= desiredLineLength:
			print line
			line = ""
	if len(line) > 0:
		print line
	print ""
inModule = False
for line in lines:
	fields = line.strip().split()
	if inModule and len(fields) == 1 and fields[0] == ");":
		inModule = False
		print ");"
		print "defparam " + moduleName + ".GATE_DELAY = GATE_DELAY;"
		print ""
		continue
	if len(fields) == 3 and fields[0] == "module" and not inModule:
		inModule = True
		moduleName = "i" + fields[1]
		print fields[1] + " " + moduleName + " ("
		continue
	if inModule:
		print line.rstrip()
print "endmodule"

