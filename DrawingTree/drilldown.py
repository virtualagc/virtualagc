#!/usr/bin/python3
# This program is supposed to be able to take an assembly number 
# (from an assembly in the Apollo G&N system), and combine
# its find-table file (SOMETHING.csv) with the obligatory 
# drawings.csv file, producing a drawing drilldown from it.  
# The usage is:
#	./drilldown.py ASSEMBLY >ASSEMBLY.html
# where ASSEMBLY is something like 6015000-071 (drawing number
# plus configuration dash number) or else just a drawing number
# (without revision code in either case).  Additionally, the
# file
#	drilldown.json
# is produced by this operation.  It has all of the same info that's
# in the HTML, plus quantities, except that the JSON doesn't provide
# any info about CAD transcriptions of the engineering drawings. 
#
# It's probably just as easy to look at the JSON itself, properly 
# formatted of course, to see what it provides, as opposed to my 
# giving a long explanation about it, but there are a couple of 
# points worth making.  What's in the JSON is a key/value dictionary,
# with the keys being the assemblies.  Thus, the top-level assembly
# will have the key ASSEMBLY, but all of the assemblies referenced
# by ASSEMBLY will be there, along with all those referenced by the 
# subassemblies, and so on.  The values for each of those assembly
# keys will also be key/value dictionaries, such as "parents" (which is
# a list of all assemblies using that assembly), but most of the keys
# will be the "FIND" numbers from the find tables in the drawings.
# The values for the FIND-number keys will themselves be dictionaries
# that describe the cell of the FIND-table that corresponds to that
# specific FIND-number row and the specific configuration-number column
# implied by the particular assembly.  The important characteristics of the
# cell are the keys
#	QTY		The quantity count.  Sometimes these may be "AR"
#			(for "as required") or "X" (for reference materials
#			like the schematic diagram, which aren't anything
#			used to actually build the assembly).
#	DRAWING		The subassembly or component associated with that
#			cell.  This is actually an array, though usually
#			only with one element in it, because any given cell
#			could actually call out several alternative 
#			subassemblies or components.  If a particular
#			entry is not present elsewhere in the JSON, it 
#			means either that it was a component (rather than 
#			an assembly), or else the FIND-table needed for the
#			drilldown has not yet been turned into a .csv file,
#			or that we don't have a revision of the drawing that's
#			new enough to contain the sought-after dash number.
#			It sometimes happens that as description of how to
#			determine the part number appears rather than the 
#			part number itself, such as "SEE NOTE 13".
#	TITLE		The title of the drawing associated with the assembly.
#			These come directly from the title blocks of the 
#			scanned drawings, where possible, but come from the
#			FIND tables if we don't actually have the scanned
#			drawing.
#	URL		An array of URLs associated with the DRAWING array.
#			These point to the scanned engineering drawings.
#			If a URL is blank, it means we don't have a scan
#			of the drawing.  URLs are provided even if the
#			particular configuration dash-number being sought
#			is not present in the scanned drawing, usually due
#			to the drawing being too early a revision.
#	CELL		This is simply the contents of the FIND-table cell,
#			as-is.  It usually looks like a QTY or DRAWING, but
#			is not always.  It's really just present for debuggin
#			purposes, so use it for anything else at your peril!

import sys
import os
import json

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
	
def dbg(str, msg):
	if str == "0-0":
		print(msg, file=sys.stderr)

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
standardKeys = [ "level", "drawing", "configuration", "assembly", "parents", "exists", "empty", "subbedFor" ]
def readFindTable(drawing, configuration, assembly, level):
	findTable = { "level": level, "drawing": drawing, "configuration": configuration, "assembly": assembly, "parents": [], 
			"exists": False, "empty": True, "subbedFor": [] }
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
		if first and line.strip() == "":
			break
		fields = line.strip("\n").split("\t")
		if first:
			first = False
			headings = fields
			if "DRAWING" in headings and "QTY" not in headings:
				qtyTable = True
			elif "DRAWING" not in headings and "QTY" in headings:
				qtyTable = False
			else:
				print("Cannot distinguish table type (" + assembly + ") from DRAWING/QTY columns.", file=sys.stderr)
				print(headings, file=sys.stderr)
				break
			numConfigs = 0
			for field in fields:
				if field not in ["FIND", "DRAWING", "QTY", "TITLE", "STRIKE"]:
					numConfigs += 1
			#print(headings)
		else:
			findTable["empty"] = False
			row = {}
			found = False
			titleField = -1
			currentDrawing = []
			currentQty = 0
			rowQty = 0
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
					if headings[n] == "QTY":
						rowQty = fields[n]
					if headings[n] == "DRAWING":
						drawingField = (fields[n].split(" THRU "))[0]
						currentDrawing = drawingField.split(" or ")
					row[headings[n]] = fields[n]
				elif int(headings[n]) == configuration or (numConfigs == 1 and configuration in [0, -11]):
					row["CELL"] = fields[n]
					currentQty = rowQty
					if qtyTable:
						currentQty = fields[n]
					if not qtyTable or fields[n] == "X" or fields[n] == "AR" or (fields[n].isdigit() and int(fields[n]) > 0):
						if not (not qtyTable and fields[n] == ""):
							found = True
					if found:
						rq = fields[n].split(",")
						if len(rq) > 2:
							continue
						elif len(rq) == 2:
							fields[n] = rq[0]
							currentQty = rq[1]
					if not qtyTable:
						currentDrawing = fields[n].split(" or ")
			row["DRAWING"] = currentDrawing
			row["QTY"] = currentQty
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
	findTable["exists"] = True
	
	# Yay!  All done.
	return findTable

# Similar to readFindTable(), but if it doesn't find the specific desired configuration
# dash number, tries other dash numbers as well.  The returned findTable isn't affected
# by any of the latter, but if the guessed dash numbers are found, the associated 
# substitute find table is stored in 'assemblies' anyway.
subbedFrom = {}
def readFindTableWithSubbing(drawing, configuration, assembly, level):
	findTable = readFindTable(drawing, configuration, assembly, level)
	c = configuration
	subbedFindTable = {}
	for key in findTable:
		subbedFindTable[key] = 0
	subbedFindTable["exists"] = findTable["exists"]
	subbedFindTable["empty"] = findTable["empty"]
	tabulated = False
	if str(drawing) in drawings:
		if "TABULATED" in drawings[str(drawing)]["title"]:
			tabulated = True
	while level > 0 and subbedFindTable["exists"] and not subbedFindTable["empty"] and \
			len(subbedFindTable.keys()) == len(standardKeys) and \
			not tabulated and c % 10 == 9 and c < -11:
		c += 10
		a = str(drawing) + "-" + "{:0>3d}".format(-c)
		if a in assemblies:
			subbedFrom[assembly] = a
			if assembly not in assemblies[a]["subbedFor"]:
				assemblies[a]["subbedFor"].append(assembly)
			if level < assemblies[a]["level"]:
				assemblies[a]["level"] = level
			break
		else:
			subbedFindTable = readFindTable(drawing, c, a, level)
			if len(subbedFindTable.keys()) > len(standardKeys):
				subbedFrom[assembly] = a
				subbedFindTable["subbedFor"].append(assembly)
				assemblies[a] = subbedFindTable
				break
	return findTable

# Now read the assembly-specific drawing.
assemblies = {}
assemblies[assemblyName] = readFindTableWithSubbing(drawing, configuration, assemblyName, 0)

#print(assemblyName, file=sys.stderr)
#for p in sorted(assemblies[assemblyName]):
#	print("  " + p + " " + str(assemblies[assemblyName][p]), file=sys.stderr)

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
				a = readFindTableWithSubbing(dd, dc, d, level)
				#if d == "2003994-011":
				#	for f in sorted(a):
				#		print('\n' + str(f) + " " + str(a[f]), file=sys.stderr)
				if a["exists"]:  
					if a["exists"] and a["empty"]:
						assemblies[d] =a
					elif len(a.keys()) > len(standardKeys):
						assemblies[d] = a
						recurseFindTable(d, level)
					elif d in subbedFrom:
						dd = subbedFrom[d]
						recurseFindTable(dd, level)
			else:
				if level < assemblies[d]["level"]:
					assemblies[d]["level"] = level
			if d in assemblies:
				assemblies[d]["parents"].append(assemblyName)
				if assemblies[d]["level"] > maxLevel:
					maxLevel = assemblies[d]["level"]
			elif d in subbedFrom:
				dd = subbedFrom[d]
				assemblies[dd]["parents"].append(assemblyName)
				if assemblies[dd]["level"] > maxLevel:
					maxLevel = assemblies[dd]["level"]
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
				markAsAssembly = False
				if "ASSEMBLY" in thisTitle or "ASSY" in thisTitle or "GROUP" in thisTitle or " KIT" in thisTitle:
					markAsAssembly = True
				perhapsAssembly = markAsAssembly
				if asTables:
					thisLine += "<td>"
				for nn in range(0,len(findTable[key]['DRAWING'])):
					if nn > 0:
						thisLine += " or "
					thisDrawing = findTable[key]["DRAWING"][nn]
					thisExpanded = False
					cssClass = "normalDrawing"
					if thisDrawing in assemblies:
						if assemblies[thisDrawing]["exists"] and assemblies[thisDrawing]["empty"]:
							perhapsAssembly = False
						else:
							thisExpanded = True
							if expandedBelow == "":
								if not asTables:
									expandedBelow = '.&nbsp;&nbsp;'
								expandedBelow += 'Expanded in more detail: <a href="#' +  thisDrawing + '">' + thisDrawing + '</a>'
							else:
								expandedBelow += ', and <a href="#' + thisDrawing + '">' + thisDrawing + '</a>'
					elif thisDrawing in subbedFrom:
							sub = subbedFrom[thisDrawing]
							if expandedBelow == "":
								if not asTables:
									expandedBelow = '.&nbsp;&nbsp;'
								expandedBelow += 'Expanded in more detail: by <a href="#' +  sub + '"><font color="red">substitute ' + sub + '</font></a>'
							else:
								expandedBelow += ', and by <a href="#' + sub + '"><font color="red">substitute ' + sub + '</font></a>'						
					dbg(thisDrawing, str(findTable[key]))
					dbg(thisDrawing, str(thisDrawing in assemblies))
					dbg(thisDrawing, perhapsAssembly)
					dbg(thisDrawing, thisExpanded)
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
				if markAsAssembly:
					thisTitle = "<b>" + thisTitle + "</b>"
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
assLevel = len(subassemblyOrders) - 1
for level in range(1, assLevel + 1):
	print('<br><br><hr style="width: 100%; height: 2px;"><br><h1>Expanded ' + subassemblyOrders[level] + '</h1>')
	for d in sorted(assemblies):
		if (level < assLevel and assemblies[d]["level"] != level) or (level == assLevel and assemblies[d]["level"] < assLevel):
			continue
		if assemblies[d]["empty"]:
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
		if dname not in drawings:
			print("<center><b>Note:</b> No copy of drawing " + dname + " is available, so this listing of its FIND table is partially speculative.</center><br>")
		if len(assemblies[d]["parents"]) > 0:
			if len(assemblies[d]["parents"]) > 1:
				print("<center><i>Reference assemblies:</i>")
			else:
				print("<center><i>Reference assembly:</i>")
			for p in sorted(assemblies[d]["parents"]):
				print(' <a href="#' + p + '">' + p + '</a>')
			print("</center><br>")
		if len(assemblies[d]["subbedFor"]) > 0:
			print('<center><font color = "red"><b>Warning:</b>  For some reference assemblies, a ')
			print('different, unavailable configuration is required: ')
			for p in sorted(assemblies[d]["subbedFor"]):
				print(' ' + p)
			print('</font></center><br>')
		html = makeHtml(assemblies[d])
		print(html)

# Write the html footer.
f = open("bottom.html", "r")
lines = f.readlines()
f.close()
sys.stdout.writelines(lines)

# Also, write a JSON object.
jsonString = json.dumps(assemblies)
f = open("drilldown-" + assemblyName + ".json", "w")
f.write(jsonString)
f.close()
