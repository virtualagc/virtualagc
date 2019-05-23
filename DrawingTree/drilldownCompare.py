#!/usr/bin/python3
# This program compares two drilldown JSON files created by drilldown.py.

import sys
import json

# Parse the command line.
if len(sys.argv) not in [3, 5]:
	print("Usage:  drilldownCompare.py ASSY1 ASSY2 [SUBASSY1 SUBASSY2]", file=sys.stderr)
	sys.exit(1)
assemblyName1 = sys.argv[1]
assemblyName2 = sys.argv[2]
targetName1 = assemblyName1
targetName2 = assemblyName2
if len(sys.argv) == 5:
	targetName1 = sys.argv[3]
	targetName2 = sys.argv[4]

# Read the JSON files for comparison.
assemblyFilename1 = "drilldown-" + assemblyName1 + ".json"
assemblyFilename2 = "drilldown-" + assemblyName2 + ".json"
f = open(assemblyFilename1, "r")
assemblies1 = json.load(f)
f.close()
f = open(assemblyFilename2, "r")
assemblies2 = json.load(f)
f.close()

# Create lists of subassemblies in the top assembly of each of the
# two collections.
assembly1 = assemblies1[targetName1]
assembly2 = assemblies2[targetName2]
subassemblies1 = []
subassemblies2 = []
for key in assembly1:
	if not key.isdigit():
		continue
	drawings = assembly1[key]["DRAWING"]
	for drawing in drawings:
		if drawing not in subassemblies1:
			subassemblies1.append(drawing)
for key in assembly2:
	if not key.isdigit():
		continue
	drawings = assembly2[key]["DRAWING"]
	for drawing in drawings:
		if drawing not in subassemblies2:
			subassemblies2.append(drawing)
both = sorted(subassemblies1 + subassemblies2)

# Compare.
for subassembly in both:
	if subassembly not in subassemblies2:
		print("Only in " + targetName1 + ": " + subassembly)
	if subassembly not in subassemblies1:
		print("Only in " + targetName2 + ": " + subassembly)
	