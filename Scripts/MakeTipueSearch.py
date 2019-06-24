#!/usr/bin/python3
# Used for creating a Tipue Search (http://www.tipue.com/search/)
# content file (js) from a drawings.csv file (as described in 
# DrawingTree/README.txt).  Usage:
#
#	MakeTipueSearch.py <drawings.csv >tipuesearch_content.js

import sys
import datetime

now = datetime.datetime.now()
date = "%04d-%02d-%02d" % (now.year, now.month, now.day)

# Read the entire input file.
lines = sys.stdin.readlines()

titles = {}
print('var tipuesearch = {"date": "' + date + '",')

# Pick off all of the URL prefixes.
prefixesMode1Up = []
for n in range(0, len(lines)):
	line = lines[n]
	fields = line.strip("\n").split("\t")
	if len(fields) != 1:
		break
	prefixesMode1Up.append(fields[0])
print('"prefixes": [')
for n in range(0, len(prefixesMode1Up)):
	prefix = '"' + prefixesMode1Up[n] + '"'
	if n < len(prefixesMode1Up) - 1:
		prefix += ","
	print(prefix)
print('],')

# Now do the actual conversion.
print('"pages": [')
for n in range(0, len(lines)):
	line = lines[n]
	fields = line.strip("\n").split("\t")
	if len(fields) == 1:
		continue
	url = fields[0]
	number = fields[1]
	revision = fields[2]
	type = fields[3]
	sheet = fields[4]
	frame = fields[5]
	while len(type) > 1 and type[0] == '0':
		type = type[1:]
	while len(sheet) > 1 and sheet[0] == '0':
		sheet = sheet[1:]
	while len(frame) > 1 and frame[0] == '0':
		frame = frame[1:]
	if type == "":
		type = "?"
	if sheet == "":
		sheet = "1"
	if frame == "":
		frame = "1"
	title = number + revision + "-" + type + "-" + sheet + "-" + frame
	count = 0
	countString = ""
	if title+countString in titles:
		count += 1
		countString = " (" + str(count) + ")"
	title += countString
	text = fields[6].strip('"').replace('""', '\\"')
	if n == len(lines) - 1:
		endline = ""
	else:
		endline = ","
	print('\t{"title":"' + title + '" ,"text":"' + text + '" ,"url":"' + url + '"}' + endline)
	
print(']};')
