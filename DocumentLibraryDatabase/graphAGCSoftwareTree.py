#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     graphAGCSoftwareTree.py
# Purpose:	     The idea here is that a spreadsheet representation of the 
#               entire AGC software tree (Luminary, Colossus, Sundance, 
#               Skylark, and so on), showing the entire evolution, is 
#               maintained (for example, in Google Sheets) and then exported
#               to a tab-delimited file for processing by this script.  What
#               the script does is to create a file in the DOT language that
#               can be used by 'graphviz' to draw the entire structure. 
# Mod history:  2021-09-29 RSB  Began
#
# The structure of the spread sheet is this:
#
#   1st row     Headings, to be discarded.
#   other rows  Data.
#
#   Col A       Non-empty if the revision was released to manufacturing,
#               empty if not.
#   Col B       The program name ("LUMINARY", "COLOSSUS", "LM131", etc.)
#   Col C       The revision
#   Col D       Approximate date.  Only used for roughly synchronizing 
#               different branches (like LUMINARY and COLOSSUS) along the
#               time axis, so doesn't have to be very accurate.  Formatted
#               to make sorting as strings easy:  YYYY-MM-DD, zero-padded.
#   Col E       Program name of the immediate predecessor.
#   Col F       Revision code of the immediate predecessor.  So usually,
#               the program name of an item and its successor will be the same,
#               and the revision code of the item will be 1 higher than the
#               predecessor.  But this won't be true at branches.
#   Col G       A comma-delimited lists of the the PCRs, PCNs, Software
#               Anomaly Reports, and ACB Requests distinguishing this item
#               from its predecessor.
#   Col H       A reference supporting the assertions in the other columns.
#   Col I       A column for comments.  The comments don't appear on the graph.
#
# After the spreadsheet is exported to in tab-delimited format (TSV), 
# here's how to process it:
#
#   graphAGCSoftwareTree.py <AGCSoftwareTree.tsv >AGCSoftwareTree.gv
#   dot -Tsvg -Efontname=helvetica -Efontsize=10 -Nfontname=helvetica-bold \
#             -Nfontsize=12 AGCSoftwareTree.gv -o AGCSoftwareTree.svg
#
# The output SVG file can then be viewed in Chrome, Firefox, Inkscape, etc.
# The font and fontsize settings don't necessarily have to be as shown, but
# if the font is bigger, you might need to adjust the number of PCRs displayed
# on the edges.

import sys
import re

def sortKey(item):
    rev = re.split("[-,]", item[2])[-1].strip()
    if rev.isdigit():
        return "%s%-12s%03d" % (item[3], item[1], int(rev))
    else:
        return "%s%-12s%s" % (item[3], item[1], rev)

def makeItemId(item):
    itemName = item[1]
    itemRev = re.split("[-,]", item[2])[-1].strip()
    itemId = itemName.replace(" ", "_") + "_" + itemRev
    return (itemName, itemRev, itemId)

# Word-wrap a string for a note.
maxNoteWidth = 40
def wrap(sIn):
    words = sIn.strip().split()
    sOut = ""
    onThisLine = 0
    for word in words:
        if onThisLine + 1 + len(word) > maxNoteWidth:
            sOut += "\l"
            onThisLine = 0
        if onThisLine > 0:
            sOut += " "
            onThisLine += 1
        sOut += word
        onThisLine += len(word)
    return sOut

allVersions = []
lines = sys.stdin.readlines()
firstLine = True
for line in lines:
    if firstLine:
        firstLine = False
        continue
    if line.strip() == "":
        continue
    fields = line.split('\t')
    for n in range(len(fields)):
        if n != 8:
            fields[n] = fields[n].upper()
        fields[n] = fields[n].strip()
    if len(fields) != 9:
        print("Bad line: '%s'" % line, file=sys.stderr)
        continue
    allVersions.append(fields)
    
if False:
    # Find all items with same release label.
    releases = {}
    for item in allVersions:
        release = item[0]
        if release != "":
            if release not in releases:
                releases[release] = []
            (itemName, itemRev, itemId) = makeItemId(item)
            releases[release].append(itemId)
    
allVersions.sort(key=sortKey)

# Find all unique program names in the spreadsheet.
programs = []
for item in allVersions:
    if item[1] not in programs:
        programs.append(item[1])

# We want to generate a timeline, along with the data for roughly 
# synchronizing the bubbles to that timeline.  It would be nice if graphviz
# simply allowed us to supply the dates as something it could sort for ranking
# the bubbles, but alas it does not, for some reason.  (Seems like a natural
# thing to do.)  Instead, with the tools graphviz provides us, we instead have
# to explicitly provide all of the ranking ourselves.
if True:
    # In this method, every unique day is a rank.
    # First, find all of the unique dates.
    dates = {}
    for item in allVersions:
        itemDate = item[3].split("-")
        dateLabel = "D" + itemDate[0] + itemDate[1] + itemDate[2]
        if dateLabel not in dates:
            dates[dateLabel] = {}
    # Now, attach the appropriate revision of each unique program to the date.
    for item in allVersions:
        program = item[1]
        note = item[8].replace("\"", "\\\"")
        revision = re.split("[-,]", item[2])[-1]
        if revision.isdigit():
            revision = int(revision)
        itemDate = item[3].split("-")
        dateLabel = "D" + itemDate[0] + itemDate[1] + itemDate[2]
        if program not in dates[dateLabel]:
            dates[dateLabel][program] = { "label" : dateLabel, "revision" : revision, "item" : item }
        elif revision > dates[dateLabel][program]["revision"]:
            dates[dateLabel][program] = { "label" : dateLabel, "revision" : revision, "item" : item }
        if note != "":
            if "_NOTE_" not in dates[dateLabel]:
                dates[dateLabel]["_NOTE_"] = { "label" : dateLabel, "revision" : revision, "note" : wrap(note) + "\l" }
            else:
                dates[dateLabel]["_NOTE_"]["note"] += "\l" + wrap(note) + "\l"
    # Now, for the purpose of determining which date labels are actually 
    # visible on the timeline, for each month determine the date (in the dates
    # dictionary) that's closest to the middle of the month.  There may not 
    # even be one sometimes.  At most one day in each month (in the
    # dates dictionary) will be assigned a key "visible":True; none of the other
    # days in the month will have that key.
    checkingOrder = [16, 15, 17, 14, 18, 13, 19, 12, 20, 11, 21, 10, 22, 9, 23, 8, 24, 7, 25, 6, 26, 5, 27, 4, 28, 3, 29, 2, 30, 1, 31]
    startDate = allVersions[0][3].split("-")
    endDate = allVersions[-1][3].split("-")
    startYear = int(startDate[0])
    startMonth = int(startDate[1])
    endYear = int(endDate[0])
    endMonth = int(endDate[1])
    for year in range(startYear, endYear+1):
        sMonth = 1
        eMonth = 13
        if year == startYear:
            sMonth = startMonth
        if year == endYear:
            eMonth = endMonth + 1
        for month in range(sMonth, eMonth):
            for day in checkingOrder:
                dateLabel = "D%4d%02d%02d" % (year, month, day)
                if dateLabel in dates:
                    dates[dateLabel]["visible"] = True
                    break
else:
    # Generate a list of all months in the range of the database entries, and 
    # for each unique program name having a revision in any given month, find the
    # revision that's a closest match to the middle of the month.  These matches
    # will be ranked together for the purpose of drawing the diagram, which should
    # roughly synchronize the different branches.
    dates = {}
    startDate = allVersions[0][3].split("-")
    endDate = allVersions[-1][3].split("-")
    startYear = int(startDate[0])
    startMonth = int(startDate[1])
    endYear = int(endDate[0])
    endMonth = int(endDate[1])
    for year in range(startYear, endYear+1):
        sMonth = 1
        eMonth = 13
        if year == startYear:
            sMonth = startMonth
        if year == endYear:
            eMonth = endMonth + 1
        for month in range(sMonth, eMonth):
            dateLabel = "D%4d%02d" % (year, month)
            dates[dateLabel] = {}
    for item in allVersions:
        program = item[1]
        revision = re.split("[-,]", item[2])[-1]
        date = item[3].split("-")
        year = int(date[0])
        month = int(date[1])
        day = int(date[2])
        dateLabel = "D%4d%02d%02d" % (year, month, day)
        if program not in dates[dateLabel[:7]]:
            dates[dateLabel[:7]][program] = { "label" : dateLabel, "day" : day, "revision" : revision, "item" : item }
        else:
            midLabel = dateLabel[:7] + "15"
            savedDay = dates[dateLabel[:7]][program]["day"]
            if abs(day-15) < abs(savedDay-15):
                dates[dateLabel[:7]][program] = { "label" : dateLabel, "day" : day, "revision" : revision, "item" : item }
            elif abs(day-15) == abs(savedDay-15):
                if revision > dates[dateLabel[:7]][program]["revision"]:
                    dates[dateLabel[:7]][program] = { "label" : dateLabel, "day" : day, "revision" : revision, "item" : item }
if False:
    for label in sorted(dates):
        for program in programs:
            if program in dates[label]:
                print("%s %s %s %s" % (label, dates[label][program]["item"][3], program, dates[label][program]["revision"]), file=sys.stderr)

# Now generate the actual output.
monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
block1 = ["ECLIPSE", "SUNRISE", "CORONA", "SOLARIUM", "SUNSPOT", "MOONGLOW", "ARES", "TRIVIUM"]
lem = ["RETREAD", "AURORA", "SUNBURST", "SUNDANCE", "LUMINARY", "LUM131", "LUM131A", "LM131", "LMY99", "LUM69", "BURST116", "ZERLINA", "SHEPATIN", "DAP AURORA", "AP11ROPE"]
print("digraph G {")
for label in sorted(dates):
    if dates[label] != {}:
        if "visible" in dates[label]:
            year = label[1:5]
            month = label[5:7]
            print("\t%s [fontcolor=\"green\", shape=\"plaintext\", label=\"%s %s\"]" % (label, monthNames[int(month)-1], year))
        else:
            print("\t%s [style=\"invis\", shape=\"plaintext\"]" % label)            
for item in allVersions:
    released = item[0] != ""
    (itemName, itemRev, itemId) = makeItemId(item)
    itemDate = item[3]
    predName = item[4]
    predRev = item[5]
    itemForms = item[6].split(",")
    for n in range(len(itemForms)):
        itemForms[n] = itemForms[n].strip()
    itemForms = list(dict.fromkeys(itemForms)) # Remove duplicates.
    #print(itemForms, file=sys.stderr)
    itemForms.sort()
    #print(itemForms, file=sys.stderr)
    itemForm = ""
    numFormsToPrint = 25
    for n in range(numFormsToPrint):
        if n < len(itemForms):
            if itemForm != "":
                itemForm += "\l"
            itemForm += itemForms[n]
    if len(itemForms) > numFormsToPrint:
        itemForm += "\l..."
    itemForm += "\l"
    if predName == "":
        predId = ""
    else:
        predId = predName.replace(" ", "_") + "_" + predRev
    print("\t%s [label=\"%s\"" % (itemId, itemName + "\n" + item[2]), end="")
    if released:
        print(" fontcolor=\"red\"", end="")
    fillcolor = "#c4a484"
    if itemName in block1:
        fillcolor = "lightgray"
    if itemName in lem:
        fillcolor = "lightyellow"
    if "AGS " == itemName[:4]:
        fillcolor = "white"
    print(" style=\"filled\" fillcolor=\"%s\"" % fillcolor, end="")
    print("]")
    if predId != "":
        print("\t%s -> %s [label=\"%s\"]" % (predId, itemId, itemForm))
# Add a couple of "inspired by" connections between Block I and Block II code.
print("\tSUNRISE_69 -> RETREAD_0 [label=\"INFLUENCED\l(NOT BRANCHED)\", style=\"dotted\"]")
print("\tSUNSPOT_247 -> SUNDISK_0 [label=\"INFLUENCED\l(NOT BRANCHED)\", style=\"dotted\"]")
# Add in the y-axis rank constraints.
if True:
    lastLabel = ""
    lastNoteLabel = ""
    for label in sorted(dates):
        if dates[label] != {}:
            if lastLabel != "":
                print("\t%s -> %s [style=invis]" % (lastLabel, label))
            lastLabel = label
            print("\t{rank = same; %s;" % label, end="")
            for program in dates[label]:
                if program == "visible":
                    continue
                if program == "_NOTE_":
                    itemId = "note" + label
                else:
                    (itemName, itemRev, itemId) = makeItemId(dates[label][program]["item"])
                print(" %s;" % itemId, end="")
            print("}")
            if "_NOTE_" in dates[label]:
                thisNoteLabel = "note" + label
                print("\t%s [shape=\"note\", label=\"%s\", fontname=\"Courier\"]" % (thisNoteLabel, dates[label]["_NOTE_"]["note"]))
                if lastNoteLabel != "":
                    print("\t%s -> %s [style=\"invis\"]" % (lastNoteLabel, thisNoteLabel))
                lastNoteLabel = thisNoteLabel
else:
    for release in releases:
        constraint = "{rank = same;"
        for id in releases[release]:
            constraint += " " + id + ";"
        constraint += "}"
        print(constraint)
    #print(releases, file=sys.stderr)
print("}")