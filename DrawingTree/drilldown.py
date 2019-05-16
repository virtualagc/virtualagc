#!/usr/bin/python3
# This program is supposed to be able to take an assembly number 
# (from an assembly in the Apollo G&N system), and combine
# its find-table file (SOMETHING.csv) with the obligatory 
# drawings.csv file, producing a drawing drilldown from it.  
# The output in TBD format.

import sys
import os

if len(sys.argv) > 1:
	assemblyName = sys.argv[1]
	assembly = assemblyName.split("-")
	if len(assembly) not in [1, 2]:
		print("Assembly must be drawing[-configuration].", file=sys.stderr)
		sys.exit(1)
	drawing = assembly[0]
	if len(assembly) == 2:
		rawConfiguration = assembly[1]
	else:
		rawConfiguration = "000"
	if not drawing.isdigit() or not rawConfiguration.isdigit():
		print("Drawing number and/or configuration must be all digits.", file=sys.stderr)
		sys.exit(1)
	drawing = int(drawing)
	configuration = -int(rawConfiguration)
else:
	print("No assembly specified on command line.", file=sys.stderr)
	sys.exit(1)
	

# First step: read drawings.csv and keep it in a dictionary.
drawings = { }
f = open('drawings.csv', 'r')
for line in f:
	fields = line.strip().split("\t")
	url = fields[0]
	drawingNumber = fields[1]
	revision = fields[2]
	type = int(fields[3])
	sheet = fields[4]
	frame = fields[5]
	title = fields[6]
	if '""' in title:
		title = title.replace('""', '"').strip('"')
	if type != 1:
		continue
	if drawingNumber in drawings and len(revision) < len(drawings[drawingNumber]["revision"]):
		continue
	if drawingNumber in drawings and revision <= drawings[drawingNumber]["revision"]:
		continue
	drawings[drawingNumber] = { "revision": revision.strip(), "url": url, "title": title }
f.close()

#for key in drawings:
#	print(key + " " + str(drawings[key]))

# Get a list of all schematics transcribed to CAD.
files = os.listdir("../Schematics")
cads = []
for f in files:
	if len(f) in [8,9]:
		if not f[:7].isdigit():
			continue
		if len(f) > 8 and f[7:] != "-A":
			continue
		if f[7] not in [ 'r', '-', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']:
			continue
		cads.append(f)
cads.sort()
cadDrawings = {}
for d in cads:
	if d[:7] not in cadDrawings:
		cadDrawings[d[:7]] = [ "", "" ]
	if d[7:] == 'r':
		cadDrawings[d[:7]][1] = d
	else:
		cadDrawings[d[:7]][0] = d
#for d in sorted(cadDrawings):
#	print(str(d) + " " + str(cadDrawings[d]), file=sys.stderr)

# Returns a dictionary with the contents of an assembly, or else an empty dictionary
# if the find-table file wasn't found.
standardKeys = [ "level", "drawing", "configuration", "assembly", "parents" ]
def readFindTable(drawing, configuration, assembly, level):
	findTable = { "level": level, "drawing": drawing, "configuration": configuration, "assembly": assembly, "parents": [] }
	# First need to read the current folder to for all files with names of the form
	# 	drawing + rev + ".csv"
	# to determine the one with the highest rev.
	highestRev = ""
	files = os.listdir(".")
	for file in files:
		fields = file.split(".")
		if len(fields) != 2 or fields[1] != "csv":
			continue
		basename = fields[0]
		if len(basename) < 8:
			continue
		testDrawing = basename[:7]
		if not testDrawing.isdigit():
			continue
		if int(testDrawing) != drawing:
			continue
		rev = basename[7:] 
		if len(rev) not in [1, 2]:
			continue
		if rev[0] != "-" and not (rev[0] >= "A" and rev[0] <= "Z"):
			continue
		if len(rev) == 2 and rev[1] != "-" and not (rev[1] >= "A" and rev[1] <= "Z"):
			continue
		if len(rev) < len(highestRev):
			continue
		if rev < highestRev:
			continue
		highestRev = rev
	if highestRev == "":
		return findTable
	filename = str(drawing) + highestRev + ".csv"
	#print(filename, file=sys.stderr)
	
	# Now, read the file containing the find table.
	f = open(filename, "r")
	first = True
	find = 1
	serializer = "A"
	for line in f:
		fields = line.strip("\n").split("\t")
		if first:
			first = False
			headings = fields
			if "DRAWING" in headings and "QTY" not in headings:
				qtyTable = True
			elif "DRAWING" not in headings and "QTY" in headings:
				qtyTable = False
			else:
				print("Cannot distinguish table type from DRAWING/QTY columns.", file=sys.stderr)
				break
			numConfigs = 0
			for field in fields:
				if field not in ["FIND", "DRAWING", "QTY", "TITLE", "STRIKE"]:
					numConfigs += 1
			#print(headings)
		else:
			row = {}
			found = False
			titleField = -1
			currentDrawing = []
			if "FIND" not in headings:
				currentFind = str(find) 
				find += 1
			for n in range(0,len(headings)):
				if headings[n] == "FIND":
					currentFind = fields[n]
					if currentFind == "":
						break
					if currentFind in findTable:
						currentFind += serializer
						serializer = chr(ord(serializer) + 1)
				elif headings[n] in ["DRAWING", "QTY", "TITLE", "STRIKE"]:
					if headings[n] == "DRAWING":
						currentDrawing = fields[n].split(" or ")
					row[headings[n]] = fields[n]
				elif int(headings[n]) == configuration or (numConfigs == 1 and configuration in [0, -11]):
					row[headings[n]] = fields[n]
					if not qtyTable or fields[n] == "X" or fields[n] == "AR" or (fields[n].isdigit() and int(fields[n]) > 0):
						if not (not qtyTable and fields[n] == ""):
							found = True
					if not qtyTable:
						currentDrawing = fields[n].split(" or ")
			row["DRAWING"] = currentDrawing
			if found and ("STRIKE" not in headings or row["STRIKE"] == "") and currentFind != "":
				row["URL"] = []
				for d in currentDrawing:
					fields = d.split("-")
					if fields[0] in drawings:
						row["TITLE"] = drawings[fields[0]]["title"]
						row["URL"].append(drawings[fields[0]]["url"])
					else:
						row["URL"].append("")
				if qtyTable or row["QTY"] != "":
					findTable[currentFind] = row	
	f.close()
	
	# Yay!  All done.
	return findTable

# Now read the assembly-specific drawing.
assemblies = {}
assemblies[assemblyName] = readFindTable(drawing, configuration, assemblyName, 0)

# Descend recursively.
maxLevel = 0
def recurseFindTable(assemblyName, level):
	global assemblies
	global maxLevel
	level += 1
	for findNumber in assemblies[assemblyName]:
		if findNumber in standardKeys:
			continue
		assembly = assemblies[assemblyName][findNumber]
		drawings = assembly['DRAWING']
		for d in drawings:
			fields = d.split('-')
			if not fields[0].isdigit():
				continue
			if len(fields) > 1 and not fields[1].isdigit():
				continue
			dd = int(fields[0])
			if len(fields) > 1:
				dc = fields[1]
				if dc != "":
					dc = '-' + dc
			else:
				dc = "0"
			dc = int(dc)
			if d not in assemblies:
				a = readFindTable(dd, dc, d, level)
				#if d == "2003994-011":
				#	for f in sorted(a):
				#		print('\n' + str(f) + " " + str(a[f]), file=sys.stderr)
				if len(a.keys()) > len(standardKeys):
					assemblies[d] = a
					recurseFindTable(d, level)
			else:
				if level < assemblies[d]["level"]:
					assemblies[d]["level"] = level
			if d in assemblies:
				assemblies[d]["parents"].append(assemblyName)
			if d in assemblies and assemblies[d]["level"] > maxLevel:
				maxLevel = assemblies[d]["level"]
recurseFindTable(assemblyName, 0)
#for d in sorted(assemblies):
#	print(str(d) + " " + str(assemblies[d]["level"]), file=sys.stderr)

# Write the html header.
f = open("top.html", "r")
lines = f.readlines()
f.close()
sys.stdout.writelines(lines)

asTables = True
findTable = assemblies[assemblyName]
print("<script type=\"text/javascript\">")
print("document.write(headerTemplate.replace(\"@TITLE@\",\"G&N Assembly Drill-down\").replace(\"@SUBTITLE@\",\"Assembly " + assemblyName + "\"))")
print("</script>")

# Write additional good that needs to go between the banner and the page content.
f = open("middle.html", "r")
lines = f.readlines()
f.close()
sys.stdout.writelines(lines)

aname = assemblyName
if str(drawing) in drawings:
	aname = '<a href="' + drawings[str(drawing)]["url"] + '">' + assemblyName + "</a> &mdash; " + drawings[str(drawing)]["title"]
print('<br><a name="' + assemblyName + '"></a><h1>' + aname + '</h1>')

github = "https://github.com/virtualagc/virtualagc/tree/schematics/Schematics/"
ibiblio = "https://www.ibiblio.org/apollo/KiCad/"
def makeHtml(findTable):
	level = 0
	html = ""
	if asTables:
		html += '<table class="drawingIndex"><tbody>\n'
		html += '<tr><td><b>FIND</b></td><td><b>DRAWING</b></td><td><b>TITLE</b></td><td><b>NOTES</b></td></tr>\n'
	else:
		html += "<ul>\n"
	findNumbers = list(range(0, 200))
	findNumbers.append("REF")
	for n in findNumbers:
		for c in ["", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"]:
			thisLine = ""
			key = str(n) + c
			if key in findTable:
				if key == "level":
					level = findTable["level"]
					continue
				if key in standardKeys:
					continue
				if asTables:
					thisLine += "<tr>\n"
					thisLine += "<td>" + str(n) + "</td>"
				else:
					thisLine += "<li>\n"
					thisLine += str(n) + ":  "
				expandedBelow = ""
				seeAlso = ""
				thisTitle = findTable[key]["TITLE"]
				perhapsAssembly = False
				if "ASSEMBLY" in thisTitle or "ASSY" in thisTitle or "GROUP" in thisTitle or " KIT" in thisTitle:
					perhapsAssembly = True
				if asTables:
					thisLine += "<td>"
				for nn in range(0,len(findTable[key]['DRAWING'])):
					if nn > 0:
						thisLine += " or "
					thisDrawing = findTable[key]["DRAWING"][nn]
					thisExpanded = False
					cssClass = "normalDrawing"
					if thisDrawing in assemblies:
						thisExpanded = True
						if expandedBelow == "":
							if not asTables:
								expandedBelow = '.&nbsp;&nbsp;'
							expandedBelow += '<a href="#' +  thisDrawing + '">Expanded in more detail below</a>'
						else:
							expandedBelow += ', and <a href="#' + thisDrawing + '">here</a>'
					if perhapsAssembly and not thisExpanded:
						dfields = thisDrawing.split("-")
						if len(dfields) == 1 or (len(dfields) == 2 and len(dfields[1]) == 3 and \
						   dfields[1] != "001" and dfields[1][2] == "1" and dfields[1][0] in ["0", "1", "2" ]):
							cssClass = "earlyDrawing"
					if findTable[key]["URL"][nn] != "":
						thisLine += '<a class="' + cssClass + '" href=\"' + findTable[key]["URL"][nn] + "\">" + thisDrawing + "</a>"
					else:
						thisLine += thisDrawing
					if thisDrawing[:7] in cadDrawings:
						transcriptions = cadDrawings[thisDrawing[:7]]
						for t in transcriptions:
							if t != "":
								if seeAlso == "":
									if not asTables:
										seeAlso = '.&nbsp;&nbsp;'
									seeAlso += 'See also: CAD transcription of drawing ' + t + \
										' (<a href="' +  github + t + \
										'">design files</a> or <a href="' + ibiblio + t + \
										'">image files</a>)'
								else:
									seeAlso += ', or of ' + t + \
										' (<a href="' +  github + t + \
										'">design files</a> or <a href="' + ibiblio + t + \
										'">image files</a>)'
				if asTables:
					thisLine += "</td>"
				if asTables:
					thisLine += "<td>" + thisTitle + "</td>\n"
					note = ""
					if expandedBelow != "":
						note = expandedBelow + "."
					if seeAlso != "":
						if note == "":
							note = seeAlso + "."
						else:
							note += "  " + seeAlso + "."
					thisLine += "<td>" + note + "</td>\n"
					thisLine += "</tr>\n"
				else:
					thisLine += " &mdash; " + thisTitle + expandedBelow + seeAlso + "."
					thisLine += "</li>\n"
				html += thisLine
						
	if asTables:
		html += "</tbody></table>"
	else:
		html += "</ul>"
	return html

html = makeHtml(findTable)
print(html)

subassemblyOrders = ["Assemblies", "Subassemblies", "Sub-Subassemblies", "Deep Subassemblies" ]
if maxLevel > 3:
	maxLevel = 3
for level in range(1, maxLevel + 1):
	print('<br><br><hr style="width: 100%; height: 2px;"><br><h1>Expanded ' + subassemblyOrders[level] + '</h1>')
	for d in sorted(assemblies):
		if assemblies[d]["level"] != level:
			continue
		c = str(assemblies[d]["configuration"])
		while len(c) > 0 and len(c) < 4:
			c = c[:1] + "0" + c[1:]
		aname0 = assemblies[d]["assembly"]
		aname = aname0
		dname = aname.split("-")[0]
		if dname in drawings:
			ref = '<a href="' + drawings[dname]["url"] + '">' + aname0 + '</a>'
			aname = ref + " &mdash; " + drawings[dname]["title"]
		print('<a name="' + aname0 + '"></a><h2>' + aname + '</h2>')
		if len(assemblies[d]["parents"]) > 0:
			if len(assemblies[d]["parents"]) > 1:
				print("<center><i>Reference assemblies:</i>")
			else:
				print("<center><i>Reference assembly:</i>")
			for p in assemblies[d]["parents"]:
				print(' <a href="#' + p + '">' + p + '</a>')
			print("</center><br>")
		html = makeHtml(assemblies[d])
		print(html)

# Write the html footer.
f = open("bottom.html", "r")
lines = f.readlines()
f.close()
sys.stdout.writelines(lines)

