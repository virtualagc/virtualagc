#!/usr/bin/python
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Try to pull an initial NOR state from a VCD file.  The usage is:
#	cat module.net module.vcd | pullFromVcd.py [TICKNUMBER]

import sys

inModule = False
tokens = { }
sampleTime = -1
primed = False
refd = ""
netsToPins = {}

if len(sys.argv) < 2:
	cutoffTime = 200
else:
	cutoffTime = int(sys.argv[1])

for line in sys.stdin:
	fields = line.strip().split()
	if len(fields) == 1 and fields[0] == ")":
		refd = ""
		continue
	if len(fields) == 5 and fields[0] == "(":
		refd = fields[3]
		continue
	if len(fields) == 4 and fields[0] == "(" and fields[3] == ")":
		if refd[:1] != "U":
			continue
		pinNumber = int(fields[1])
		if fields[2][:5] == "Net-(":
			netName = fields[2][5:].replace("-", "").replace(")", "")
		else:
			netName = fields[2]
		if netName not in netsToPins:
			netsToPins[netName] = []
		if pinNumber == 1:
			netsToPins[netName].append(refd + "ABC")
		elif pinNumber == 9:
			netsToPins[netName].append(refd + "DEF")
		continue
	if len(fields) == 4 and fields[0] == "$scope" and fields[1] == "module":
		inModule = True
		continue
	if inModule and len(fields) == 6 and fields[0] == "$var" and fields[1] == "wire":
		token = fields[3]
		signal = fields[4]
		if token not in tokens:
			tokens[token] = { "signal":signal, "level":"x" }
		continue
	inModule = False
	if fields[0][:1] == "$":
		continue
	if fields[0][:1] == "#":
		if primed:
			break
		sampleTime = int(fields[0][1:])
		if sampleTime >= cutoffTime:
			primed = True
		continue
	if sampleTime >= 0:
		level = fields[0][:1]
		token = fields[0][1:]
		tokens[token]["level"] = level

#print sampleTime
for token in tokens:
	signal = tokens[token]["signal"]
	if signal in netsToPins:
		tokens[token]["signal"] = netsToPins[signal]
	#print tokens[token]["level"] + " " + str(tokens[token]["signal"])

nors = {}
for token in tokens:
	gates = tokens[token]["signal"]
	if not (type(gates) is list):
		continue
	for gate in gates:
		refd = gate[:4]
		part = gate[4:]
		if refd not in nors:
			nors[refd] = { "j":0, "k":0 }
		if part == "ABC":
			nors[refd]["j"] = int(tokens[token]["level"]) 
		if part == "DEF":
			nors[refd]["k"] = int(tokens[token]["level"]) 
for refd in nors:
	print refd + " " + str(nors[refd]["j"]) + " " + str(nors[refd]["k"])
