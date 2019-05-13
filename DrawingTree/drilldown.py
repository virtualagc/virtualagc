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

# Returns a dictionary with the contents of an assembly, or else an empty dictionary
# if the find-table file wasn't found.
def readFindTable(drawing, configuration):
	findTable = {}
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
				if field != ["FIND", "DRAWING", "QTY", "TITLE", "STRIKE"]:
					numConfigs != 1
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
				if qtyTable or int(row["QTY"]) > 0:
					findTable[currentFind] = row	
	f.close()
	
	# Yay!  All done.
	return findTable

# Now read the assembly-specific drawing.
assemblies = {}
assemblies[drawing] = readFindTable(drawing, configuration)

# Descend recursively.
def recurseFindTable(drawing):
	global assemblies
	for findNumber in assemblies[drawing]:
		assembly = assemblies[drawing][findNumber]
		drawings = assembly['DRAWING']
		for d in drawings:
			if d not in assemblies:
				fields = d.split('-')
				dd = fields[0]
				if len(fields) > 1:
					dc = fields[1]
					if dc != "":
						dc = '-' + dc
				else:
					dc = ""
				assemblies[d] = readFindTable(dd, dc)
recurseFindTable(drawing)
for d in assemblies:
	print(d, file=sys.stderr)

# Write the html header.
f = open("top.html", "r")
lines = f.readlines()
f.close()
sys.stdout.writelines(lines)

findTable = assemblies[drawing]
print("<script type=\"text/javascript\">")
print("document.write(headerTemplate.replace(\"@TITLE@\",\"G&N Assembly Drill-down\").replace(\"@SUBTITLE@\",\"Assembly " + assemblyName + "\"))")
print("</script>")

def makeHtml(findTable):
	html = ""
	html += "<ul>\n"
	for n in range(0,200):
		for c in ["", "A", "B", "C", "D"]:
			key = str(n) + c
			if key in findTable:
				html += "<li>\n"
				html += str(n) + ":  "
				for n in range(0,len(findTable[key]['DRAWING'])):
					if n > 0:
						html += " or "
					if findTable[key]["URL"][n] != "":
						html += "<a href=\"" + findTable[key]["URL"][n] + "\">" + findTable[key]["DRAWING"][n] + "</a>"
					else:
						html += findTable[key]["DRAWING"][n]
				html += " &mdash; " + findTable[key]["TITLE"]
				html += "</li>\n"
	html += "</ul>"
	return html

html = makeHtml(findTable)
print(html)

# Write the html footer.
f = open("bottom.html", "r")
lines = f.readlines()
f.close()
sys.stdout.writelines(lines)

