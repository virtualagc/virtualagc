#!/usr/bin/python3
# Used for creating a Tipue Search (http://www.tipue.com/search/)
# content file (js) from a drawings.csv file (as described in 
# DrawingTree/README.txt).  Usage:
#
#	MakeTipueSearch.py <drawings.csv >tipuesearch_content.js

import sys

# Read the entire input file.
lines = sys.stdin.readlines()

titles = {}
print('var tipuesearch = {"pages": [')

for n in range(0, len(lines)):
	line = lines[n]
	fields = line.strip("\n").split("\t")
	url = fields[0]
	if fields[5] == "":
		fields[5] = "1"
	title = fields[1] + fields[2] + "-" + fields[3] + "-" + fields[4] + "-" + fields[5]
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
