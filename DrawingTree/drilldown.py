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
#	drilldown-ASSEMBLY.json
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
#			is not always.  It's really just present for debugging
#			purposes, so use it for anything else at your peril!

import sys
import os
import json

# This is a list of drawings for which warning messages are printed that
# have known problems that I (presently) don't know how to work around.
# Being in the list (or not) doesn't affect their processing in any way,
# but causes their warnings to be printed with a "*" next to them, so that
# I know not to trouble myself with them unnecessarily. 
knownProblems = [ "2008332", "MIL-A-25457", "MIL-I-8660", "MIL-I-15125", "MIL-L-4343", "MIL-T-23594" ]

github = "https://github.com/virtualagc/virtualagc/tree/schematics/Schematics/"
ibiblio = "https://www.ibiblio.org/apollo/KiCad/"
githubModels = "https://github.com/virtualagc/virtualagc/blob/mechanical/3D-models/"

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
drawingNumbers = []
prefixesMode1Up = []
f = open('drawings.csv', 'r')
for line in f:
	fields = line.strip().split("\t")
	if len(fields) == 1:
		prefixesMode1Up.append(fields[0])
		continue
	url = fields[0]
	if url[:1] == "@":
		ufields = url.split("@")
		url = prefixesMode1Up[int(ufields[1])] + ufields[2] + "/mode/1up"
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
	if drawingNumber not in drawingNumbers:
		drawingNumbers.append(drawingNumber)
f.close()

#for key in drawings:
#	print(key + " " + str(drawings[key]))

# Also, read list of drawing-numbers that are components rather than 
# assemblies.  For any number NOT in this list, the program will try to
# use heuristics to figure out if it's an assembly or not, so it doesn't
# 100% matter if components are missing from the list, but it's very 
# helpful for the list to be complete.
components = []
f = open('components.csv', 'r')
for line in f:
	components.append(int(line.strip()))
f.close()
#print(components, file=sys.stderr)

# Get a list of all schematics transcribed to CAD.
tdir = "../Schematics/"
files = os.listdir(tdir)
cads = []
for f in files:
	if f[:1] not in ["1", "2"]:
		continue
	if not os.path.isdir(tdir + f):
		continue
	if os.system("git ls-files --error-unmatch " + tdir + f + "/module.pro 2>/dev/null 1>/dev/null"):
		print("CAD directory " + f + " is present but not tracked in git, so any electrical schematics in it are ignored.", file=sys.stderr)
		continue
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

# Get a list of all 3D models created from the engineering drawings.  At this
# point, I assume they're all named NNNNNNNR (7 digits plus one revision code
# that's either - or else A-Z).
tdir = "../../virtualagc-mechanical/3D-models/"
files = os.listdir(tdir)
models = []
for f in files:
	if f[-4:] != ".stp":
		continue
	if os.system("git -C " + tdir + " ls-files --error-unmatch " + f + " 2>/dev/null 1>/dev/null"):
		print("STEP file " + f + " is present but not tracked in git, so it is ignored.", file=sys.stderr)
		continue
	f = f[:-4]
	if len(f) == 8:
		if not f[:7].isdigit():
			continue
		if f[7] not in [ '-', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']:
			continue
		models.append(f)
models.sort()
modelDrawings = {}
for d in models:
	modelDrawings[d[:7]] = d
#for d in sorted(modelDrawings):
#	print(str(d) + " " + str(modelDrawings[d]), file=sys.stderr)
#sys.exit(1)

# Splits an assembly name (like 1234567-011) or part name (like 1234567-001 or
# MS1234-567 or NAS1234C567) into its constituent part number and dash number
# (like ["1234567","011"] or ["NAS1234","C567"].  It's equivalent to returning
# a.split("-") normally, but it takes into account that some MS and NAS specs
# have a modifying letter like "A" or "C" following the base part number,
# rather than a hyphen, and that the "A" or "C" (or whatever) isn't part of
# the base number.  Or to put it differently, if we have a drawing for 
# MS1234, we don't want the burden of creating identical drawings for 
# MS1234A, MS1234C, and so on.
def splitPartNumber(assembly):
	fields = assembly.split()
	if len(fields) == 0:
		return [""]
	#if len(fields) > 1:
	#	print(fields, file=sys.stderr)
	a = fields[0]
	n = 0
	found = False
	for n in range(0, len(a)):
		if a[n].isdigit():
			found = True
			break
	if not found:
		return [a]
	found = False
	for m in range(n, len(a)):
		if not a[m].isdigit():
			found = True
			break
	if not found:
		return [a]
	start = a[:m]
	if a[m] == "-":
		m += 1
	return [start, a[m:]]
#print(splitPartNumber("1234567-011"))
#print(splitPartNumber("MS1234-567"))
#print(splitPartNumber("NAS1234C567"))
#print(splitPartNumber("NAS1234C-567D"))
#sys.exit(0)

# Returns a dictionary with the contents of an assembly, or else an empty dictionary
# if the find-table file wasn't found.
standardKeys = [ "level", "drawing", "title", "configuration", "assembly", "parents", "exists", "empty", "subbedFor" ]
findTables = [] # Every FIND table or component we actually locate.
findTablesAttempted = [] # Every FIND table we *attempt* to locate.
lastBaseDrawing = ""
def readFindTable(drawing, configuration, assembly, level, title):
	if drawing not in findTablesAttempted:
		findTablesAttempted.append(str(drawing))
	findTable = { "level": level, "drawing": drawing, "title": title, "configuration": configuration, 
			"assembly": assembly, "parents": [], "exists": False, "empty": True, "subbedFor": [] }
	if drawing not in components:
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
		titleIndex = -1
		progress = "pre " + filename + " " + str(f) + " "
		#print(progress, file=sys.stderr)
		try:
			progress = "start " + filename + " "
			for line in f:
				#print(line, file=sys.stderr)
				progress = "read \"" + line.strip() + "\" "
				#print(progress, file=sys.stderr)
				if first and line.strip() == "":
					break
				fields = line.strip("\n").split("\t")
				if first:
					progress += "A"
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
					titleIndex = fields.index("TITLE")
					for field in fields:
						if field not in ["FIND", "DRAWING", "QTY", "TITLE", "STRIKE", "NOTE"]:
							numConfigs += 1
					#print(headings)
					progress += "B"
				else:
					if fields[titleIndex] == "PROOFED":
						continue
					progress += "C"
					findTable["empty"] = False
					row = {}
					found = False
					titleField = -1
					currentDrawing = []
					currentQty = 0
					rowQty = 0
					progress += "D"
					if "FIND" not in headings:
						currentFind = str(find) 
						find += 1
					for n in range(0,len(headings)):
						if fields[n][:1] == "'":
							fields[n] = fields[n][1:]
						if headings[n] == "FIND":
							currentFind = fields[n]
							if currentFind == "":
								break
							if currentFind in findTable:
								currentFind += serializer
								serializer = chr(ord(serializer) + 1)
						elif headings[n] in ["DRAWING", "QTY", "TITLE", "STRIKE", "NOTE"]:
							if headings[n] == "QTY":
								rowQty = fields[n]
								currentQty = rowQty
							if headings[n] == "DRAWING":
								drawingField = (fields[n].split(" THRU "))[0]
								currentDrawing = drawingField.split(" or ")
								# The following code deals with a shortcut that
								# can be used when there's a bunch of successive
								# entries in the DRAWING column such as "1006750-124",
								# "1006750-32", "1006750-24", ....  With the shortcut,
								# only the first entry (in this case 1006750-124" 
								# needs to appear in full; the successive entries 
								# can appear simply as "-32", "-24", and so on.
								if "-" in fields[n]:
									dashSplit = fields[n].split("-")
									if len(dashSplit) == 2 and dashSplit[1] != "" and dashSplit[1].isdigit():
										if dashSplit[0] != "":
											lastBaseDrawing = dashSplit[0]
										else:
											drawingField = lastBaseDrawing + "-" + dashSplit[1]
											currentDrawing = [drawingField]
							row[headings[n]] = fields[n]
						elif int(headings[n]) == configuration or (numConfigs == 1 and configuration in [0, -11]):
							row["CELL"] = fields[n]
							currentQty = rowQty
							if qtyTable:
								currentQty = fields[n]
							isFraction = False
							fracFields = fields[n].split(".")
							if len(fracFields) == 1 and fracFields[0].isdigit():
								isFraction = True
							elif len(fracFields) == 2 and fracFields[0].isdigit() and fracFields[1].isdigit():
								isFraction = True
							rq = fields[n].split(",")
							isX = (fields[n] == "X")
							if not isX and len(rq) == 2 and rq[1] == "X":
								isX = True
							if not qtyTable or isX or fields[n] == "AR" or (isFraction and float(fields[n]) > 0):
								if not (not qtyTable and fields[n] == ""):
									found = True
							if found:
								if len(rq) > 2:
									continue
								elif len(rq) == 2:
									fields[n] = rq[0]
									currentDrawing = [ rq[0] ]
									currentQty = rq[1]
							if not qtyTable:
								currentDrawing = fields[n].split(" or ")
					progress += "E"
					row["DRAWING"] = currentDrawing
					row["QTY"] = currentQty
					if found and ("STRIKE" not in headings or row["STRIKE"] == "") and currentFind != "":
						row["URL"] = []
						for d in currentDrawing:
							fields = splitPartNumber(d)
							#dbg(d, str(fields))
							if fields[0] in drawings:
								row["TITLE"] = drawings[fields[0]]["title"]
								row["URL"].append(drawings[fields[0]]["url"])
							else:
								row["URL"].append("")
						if qtyTable or row["QTY"] != "":
							findTable[currentFind] = row
					progress += "F"
		except:
			print("Error in " + assembly, file=sys.stderr)	
			print(progress, file=sys.stderr)
		f.close()
	findTable["exists"] = True
	if str(drawing) not in findTables:
		findTables.append(str(drawing))
	
	# Yay!  All done.
	return findTable

# Similar to readFindTable(), but if it doesn't find the specific desired configuration
# dash number, tries other dash numbers as well.  The returned findTable isn't affected
# by any of the latter, but if the guessed dash numbers are found, the associated 
# substitute find table is stored in 'assemblies' anyway.
subbedFrom = {}
tabulatedList = []
def readFindTableWithSubbing(drawing, configuration, assembly, level, title):
	findTable = readFindTable(drawing, configuration, assembly, level, title)
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
			if assembly not in tabulatedList:
				tabulatedList.append(assembly)
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
			subbedFindTable = readFindTable(drawing, c, a, level, title)
			if len(subbedFindTable.keys()) > len(standardKeys):
				subbedFrom[assembly] = a
				subbedFindTable["subbedFor"].append(assembly)
				assemblies[a] = subbedFindTable
				break
	return findTable

# Now read the assembly-specific drawing.
assemblies = {}
assemblies[assemblyName] = readFindTableWithSubbing(drawing, configuration, assemblyName, 0, "")

#print(assemblyName, file=sys.stderr)
#for p in sorted(assemblies[assemblyName]):
#	print("  " + p + " " + str(assemblies[assemblyName][p]), file=sys.stderr)

# Descend recursively.
maxLevel = 0
recursed = []
def recurseFindTable(assemblyName, level):
	#print(str(level) + ": " + assemblyName, file=sys.stderr)
	if assemblyName in recursed:
		return
	recursed.append(assemblyName)
	global assemblies
	global maxLevel
	level += 1
	for findNumber in assemblies[assemblyName]:
		if findNumber in standardKeys:
			continue
		assembly = assemblies[assemblyName][findNumber]
		drawings = assembly['DRAWING']
		title = assembly['TITLE']
		for d in drawings:
			fields = splitPartNumber(d)
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
				a = readFindTableWithSubbing(dd, dc, d, level, title)
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
# While recurseFindTable() attempts to set the "level" keys of the assemblies,
# I realize belatedly that it can't reliably do this in the simplistic way
# I imagined, and deep sub-assemblies may be assigned larger level values than
# they ought to (if more than one level is possible).  Rather than try to fix
# it in recurseFindTable(), it's simply easier to do a final brute-force 
# assignment at the end.  The idea of the brute-force assignment is simply to
# check each assembly against its parents, and to keep doing passes until no
# changes have occurred.
changed = True
while changed:
	changed = False
	for a in assemblies:
		assembly = assemblies[a]
		level = assembly["level"]
		for p in assembly["parents"]:
			levelp = assemblies[p]["level"] + 1
			if level > levelp:
				changed = True
				level = levelp
				assembly["level"] = levelp
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

warnMS = {}
warnFIND = {}
refs = []
def makeHtml(findTable):
	global warnMS, warnFIND
	level = 0
	html = ""
	if asTables:
		html += '<table class="drawingIndex"><tbody>\n'
		html += '<tr><td><b>FIND</b></td><td><b>QTY</b></td><td><b>DRAWING</b></td><td><b>TITLE</b></td><td><b>NOTES</b></td></tr>\n'
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
				qty = str(findTable[key]["QTY"])
				if asTables:
					thisLine += "<tr>\n"
					thisLine += "<td>" + str(n) + "</td><td>" + qty + "</td>"
				else:
					thisLine += "<li>\n"
					thisLine += str(n) + ":  "
				expandedBelow = ""
				seeAlso = ""
				thisTitle = findTable[key]["TITLE"].replace("&", " & ").replace("  ", " ")
				markAsAssembly = False
				ref = False
				if 	qty != "" and qty.isdigit() and int(qty) > 0 \
					and "SPECIFICATION CONTROL DRAWING" not in thisTitle \
					and "SPECIFICATION CONTROL DWG" not in thisTitle \
					and "SOURCE CONTROL DRAWING" not in thisTitle \
					and "SOURCE CONTROL DWG" not in thisTitle \
					and "SCD" not in thisTitle:
					if 	"ASSEMBLY" in thisTitle \
						or "ASSY" in thisTitle \
						or "ASS'Y" in thisTitle \
						or "GROUP" in thisTitle \
						or " KIT" in thisTitle:
						markAsAssembly = True
				else:
					ref = True
				perhapsAssembly = markAsAssembly
				if asTables:
					thisLine += "<td>"
				for nn in range(0,len(findTable[key]['DRAWING'])):
					if nn > 0:
						thisLine += " or "
					thisDrawing = findTable[key]["DRAWING"][nn]
					dfields = splitPartNumber(thisDrawing)
					if dfields[0].isdigit() and int(dfields[0]) in components:
						markAsAssembly = False
						perhapsAssembly = False
					#if dfields[0] == "1006161":
					#	print("Warning: 1006161 " + str(perhapsAssembly), file=sys.stderr)
					if ref and dfields[0] not in refs:
						refs.append(dfields[0])
					thisURL = findTable[key]["URL"][nn]
					if thisURL == "" and (thisDrawing[:2] in ["MS", "AN", "QQ"] or thisDrawing[:3] in ["MIL", "DOD", "FED", "MMM"]):
						if thisDrawing in warnMS:
							warnMS[thisDrawing] += 1
						else:
							warnMS[thisDrawing] = 1
					thisExpanded = False
					cssClass = "normalDrawing"
					if thisDrawing in assemblies:
						if findTable is assemblies[thisDrawing]:
							perhapsAssembly = False
						elif assemblies[thisDrawing]["exists"] and assemblies[thisDrawing]["empty"]:
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
					#print(str(findTable["drawing"]) + " " + dfields[0], file=sys.stderr)
					if perhapsAssembly and not thisExpanded:
						if len(dfields) == 1 or (len(dfields) == 2 and len(dfields[1]) == 3 and \
						   dfields[1] != "001" and dfields[1][2] == "1" and dfields[1][0] in ["0", "1", "2" ]):
							cssClass = "earlyDrawing"
					#if perhapsAssembly and thisURL != "" and thisDrawing[-4:] != "-001" and \
					#		thisDrawing not in assemblies and thisDrawing not in subbedFrom and \
					#		thisDrawing not in tabulatedList and dfields[0] not in findTables:
					if perhapsAssembly and thisURL != "" and dfields[0] not in findTables:
						if thisDrawing in warnFIND:
							warnFIND[thisDrawing] += 1
						else:
							warnFIND[thisDrawing] = 1
					if "Documents/assist.dla.mil/" == thisURL[:25]:
						# Some MS and NAS part numbers have been assigned substitute
						# URLs (upstream from this script).  What the following code
						# tries to do is to detect that and flag it so that the 
						# link can be displayed in red. In some such URLs I've found
						# it necessary to replace hyphens with underlines, so that
						# has to be undone before the check.
						if thisURL[25:-5].replace("_", "-") not in thisDrawing:
							cssClass = "earlyDrawing"
					#dbg(thisDrawing, str(findTable[key]))
					#dbg(thisDrawing, str(nn))
					if thisURL != "":
						#dbg(thisDrawing, "A")
						thisLine += '<a class="' + cssClass + '" href=\"' + thisURL + "\">" + thisDrawing + "</a>"
					else:
						#dbg(thisDrawing, "B")
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
					if thisDrawing[:7] in modelDrawings:
						t = modelDrawings[thisDrawing[:7]]
						if seeAlso == "":
							if not asTables:
								seeAlso = '.&nbsp;&nbsp;'
						else:
							seeAlso += ', or '
						seeAlso += '<a href="' + githubModels + t + '.stp">3D model of drawing ' + t + '</a>'
				if asTables:
					thisLine += "</td>"
				if markAsAssembly or expandedBelow != "":
					thisTitle = "<b>" + thisTitle + "</b>"
				if asTables:
					thisLine += "<td>" + thisTitle + "</td>\n"
					note = ""
					if "NOTE" in findTable[key]:
						note = findTable[key]["NOTE"] + "  "
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
		aname = aname0 + " &mdash; " + assemblies[d]["title"]
		dname = splitPartNumber(aname)[0]
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

# Print warnings.
noFinds = list(set(findTablesAttempted) - set(findTables))
if len(warnMS) > 0:
	print("Missing mil-specs: ", file=sys.stderr)
	for w in sorted(warnMS):
		fields = w.split()
		star = ""
		if fields[0] in knownProblems:
			star = " *"
		print("Warning (M): " + fields[0] + star, file=sys.stderr)
if len(warnFIND) > 0:
	print("Possible assembly without FIND.csv: ", file=sys.stderr)
	for w in sorted(warnFIND):
		fields = w.split()
		if fields[0] not in refs:
			find = ""
			if fields[0] in noFinds:
				find = ",F"
			star = ""
			if fields[0] in knownProblems:
				star = " *"
			print("Warning (A" + find + "): " + fields[0] + star, file=sys.stderr)
if len(noFinds):
	print("Existing drawings without FIND.csv or entry in components.csv: ", file=sys.stderr)
	for w in sorted(noFinds):
		if w in drawingNumbers and w not in refs and w not in warnFIND:
			fields = w.split()
			star = ""
			if fields[0] in knownProblems:
				star = " *"
			print("Warning (F): " + fields[0] + star, file=sys.stderr)
	