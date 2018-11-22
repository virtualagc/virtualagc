#!/usr/bin/python

import sys

header = """EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 29 0
EELAYER END
$Descr E 60000 34000
encoding utf-8
Sheet 2 2
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr"""

footer = "$EndSCHEMATC"

lines = sys.stdin.readlines()
records = {}
for line in lines:
	record = line.strip().split()
	while len(record[1]) < 3:
		record[1] = '0' + record[1]
	record[2] = record[2].strip('"')
	if record[1] not in records:
		records[record[1]] = { record[0]: record[2], "colSize": len(record[2]) }
	else:
		if len(record[2]) > records[record[1]]["colSize"]:
			records[record[1]]["colSize"] = len(record[2])
		records[record[1]][record[0]] = record[2]
numRecords = len(records)
charWidth = 120
width = 5 * charWidth
for key in records:
	records[key]["colSize"] = (records[key]["colSize"] + 2) * charWidth
	width += records[key]["colSize"]
rowHeight = 250
height = 17 * rowHeight
yMargin = 25
left = 1000
top = 1000
right = left + width
bottom = top + height

print header

for j in range(0, 18):
	y = str(top + j * rowHeight)
	print "Wire Notes Line style solid"
	print "\t" + str(left) + " " + y + " " + str(right) + " " + y
	if j > 1:
		print "Text Notes " + str(left + charWidth) + " " + y + " 0    130  ~ 26"
		print "A" + str(j-1)

print "Wire Notes Line style solid"
print "\t" + str(left) + " " + str(top) + " " + str(left) + " " + str(bottom)
left += 5 * charWidth
print "Wire Notes Line style solid"
print "\t" + str(left) + " " + str(top) + " " + str(left) + " " + str(bottom)

for key in sorted(records):
	record = records[key]
	print "Text Notes " + str(left + charWidth) + " " + str(top + rowHeight - yMargin) + " 0    130  ~ 26"
	print key.lstrip("0")
	for j in range(2, 18):
		k = j - 1
		y = str(top + j * rowHeight - yMargin)
		if k < 10:
			module = "A0" + str(k)
		else:
			module = "A" + str(k)
		print "Text Notes " + str(left + charWidth) + " " + y + " 0    130  ~ 26"
		print record[module]
	left += record["colSize"]
	print "Wire Notes Line style solid"
	print "\t" + str(left) + " " + str(top) + " " + str(left) + " " + str(bottom)

print footer
