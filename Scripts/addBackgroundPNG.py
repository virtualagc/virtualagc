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
# Filename: 	addBackgroundPNG.py
# Purpose:	Insert a background PNG into a KiCad .sch file.  This is
#		part of my workflow for transcribing scanned AGC schematics
#		into KiCad.
# Mod history:	2018-07-29 RSB	First time I remembered to add the GPL and
#				other boilerplate at the top of the file.
#
# I've become fed up with eeschema's ability to work with background images.
# I can't do much about most of it, but I can certainly make it easier to 
# add a background image, position it properly, and scale it, whilst making
# sure it is at the lowest "Z" level.  I don't pretend any of this is done
# efficiently, and indeed it's not; it's just done as simply as I could do
# it without having to learn anything.

import sys
import os.path

if len(sys.argv) < 4:
	print >> sys.stderr, "USAGE:"
	print >> sys.stderr, "\taddBackgroundPNG.py INPUT.sch INPUT.png SCALE"
	sys.exit(1)

inputSch = sys.argv[1]
inputPng = sys.argv[2]
scale = sys.argv[3]
if not os.path.isfile(inputSch):
	print >> sys.stderr, "Input schematic " + inputSch + " not found."
	sys.exit(1)
if not os.path.isfile(inputPng):
	print >> sys.stderr, "Input schematic " + inputPng + " not found."
	sys.exit(1)
	
f = open(inputSch, "r")
schLines = f.readlines()
f.close()
numLines = len(schLines)
for line in range(0, numLines):
	schLines[line] = schLines[line].rstrip()
if schLines[0] != "EESchema Schematic File Version 4" or schLines[numLines - 1] != "$EndSCHEMATC":
	print >> sys.stderr, "Input schematic " + inputSch + " not in expected format. (No eeschema signature.)"
	sys.exit(1)
x = 0
y = 0
for i in range(1, numLines):
	fields = schLines[i].split()
	if fields[0] == "$Descr":
		x = int(fields[2])
		y = int(fields[3])
		break
if x == 0 or y == 0:
	print >> sys.stderr, "Input schematic " + inputSch + " not in expected format. (No $Descr.)"
	sys.exit(1)

EndDescr = 0
for i in range(2, numLines):
	if schLines[i] == "$EndDescr":
		EndDescr = i
		break
if EndDescr == 0:
	print >> sys.stderr, "Input schematic " + inputSch + " not in expected format. (No $EndDescr.)"
	sys.exit(1)

f = open(inputPng, "rb")
pngString = f.read()
f.close()
pngSize = len(pngString)
pngBytes = []
for i in range(0, pngSize):
	pngBytes.append(ord(pngString[i]))
del pngString
pngSignature = [137, 80, 78, 71, 13, 10, 26, 10]
for i in range(0,8):
	if pngBytes[i] != pngSignature[i]:
		print >> sys.stderr, "Input PNG file " + inputPng + " not in expected format."
		sys.exit(1)

os.rename(inputSch, inputSch + ".bak")

f = open(inputSch, "w")
for i in range(0, EndDescr + 1):
	f.write(schLines[i] + "\n")
f.write("$Bitmap\n")
f.write("Pos " + str(x//2) + " " + str(y//2) + "\n")
f.write("Scale " + scale + "\n")
f.write("Data\n")
for i in range(0, pngSize):
	if i % 32 != 0:
		f.write(" ")
	f.write("%02X" % pngBytes[i])
	if i % 32 == 31:
		f.write("\n")
if pngSize % 32 != 0:
	f.write("\n")
f.write("EndData\n")
f.write("$EndBitmap\n")
for i in range(EndDescr + 1, numLines):
	f.write(schLines[i] + "\n")
f.close()
